"""The walking sprites of the field: Terry, the people and every monster, frame by frame, put together with
their metasprite frame tables (DrawMetasprite format) in the field sprite colours."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, SPECIES, packed_image, card  # noqa: E402

GROUP = 'sprites'
CELL = 24                      # each frame drawn in a 24 x 24 box, the sprite's origin at (12, 20)
OX, OY = 12, 20


def read_sets(rom, label, nsets):
    """[[frame address, ...] per set] of a DrawMetasprite table (pointers into the same bank)."""
    t = rom.lin(label)
    bank = t - (t & 0x3FFF)
    lists = [bank + rom.word(t + 2 * s) - 0x4000 for s in range(nsets)]
    starts = sorted(set(lists))
    out = []
    for fl in lists:
        nxt = min([x for x in starts if x > fl] + [fl + 32])
        frames, p, lowest = [], fl, None
        while p < nxt and len(frames) < 12:
            f = bank + rom.word(p) - 0x4000
            if not bank <= f < bank + 0x4000:
                break
            lowest = f if lowest is None else min(lowest, f)
            if p >= lowest:
                break
            frames.append(f)
            p += 2
        out.append(frames)
    return out


def frame_entries(r, f):
    out = []
    while r[f] != 0x80 and len(out) < 16:
        y, x, t, a = r[f:f + 4]
        out.append((y - 256 if y > 127 else y, x - 256 if x > 127 else x, t, a))
        f += 4
    return out


def bounds(frame_lists):
    """(width, height, origin x, origin y) of a box that holds every frame."""
    ys = [y for fl in frame_lists for f in fl for y, _, _, _ in f if -40 <= y <= 32] or [0]
    xs = [x for fl in frame_lists for f in fl for _, x, _, _ in f if -40 <= x <= 32] or [0]
    return max(xs) + 8 - min(xs), max(ys) + 8 - min(ys), -min(xs), -min(ys)


def draw_frame(img, x0, y0, entries, tiles, pal, box=None):
    """Draws one frame's 8 x 8 sprites at (x0, y0) + origin; colour palette * 4 + colour (0 = clear)."""
    cw, ch, OX, OY = box or (CELL, CELL, 12, 20)
    for y, x, t, a in entries:
        if 16 * t + 16 > len(tiles):
            continue
        p = (pal | a) & 7
        for ry in range(8):
            sy = 7 - ry if a & 0x40 else ry
            lo, hi = tiles[16 * t + 2 * sy], tiles[16 * t + 2 * sy + 1]
            py = y0 + OY + y + ry
            if not y0 <= py < y0 + ch:
                continue
            for rx in range(8):
                sh = rx if a & 0x20 else 7 - rx
                c = (hi >> sh & 1) << 1 | (lo >> sh & 1)
                px = x0 + OX + x + rx
                if c and x0 <= px < x0 + cw:
                    img[py][px] = 4 * p + c


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    names = rom.texts('SysText_MonsterNames', SPECIES)
    fa = rom.lin('FieldObjPalettes')
    colors = [rom.color(rom.word(fa + 2 * i)) for i in range(32)]

    def sheet(rows, name, title, doc, users, unit):
        """rows: [(label, tiles, frames entries, palette)] -> one picture, a row of frames each."""
        ncol = max(len(f) for _, _, f, _ in rows)
        box = bounds([f for _, _, f, _ in rows])
        cw, ch = box[0] + 2, box[1] + 2
        box = (cw, ch, box[2] + 1, box[3] + 1)
        img = [bytearray([255] * (ncol * cw)) for _ in range(len(rows) * ch)]
        marks = []
        for i, (lab, tiles, frames, pal) in enumerate(rows):
            for k, ent in enumerate(frames):
                draw_frame(img, k * cw, i * ch, ent, tiles, pal, box)
            marks.append({'x': 0, 'y': i * ch, 'w': len(frames) * cw, 'h': ch, 'label': lab[0],
                          'text': lab[1], **({'link': lab[2], 'linkText': 'card'} if lab[2] else {})})
        return packed_image(img, colors, scale=3, name=name, title=title, marks=marks, doc=doc, users=users,
                            unit=unit)

    out = []
    # ---- Terry and the people: CharacterMetasprites set n with ActorGfx n
    sets = read_sets(rom, 'CharacterMetasprites', 0x60)
    cpal = rom.lin('CharacterPalettes')
    ag = rom.lin('ActorGfx')
    rows = []
    for n in range(0x60):
        g = rom.word(ag + 2 * n)
        try:
            tiles = bytearray(rom.decompress(rom.far_entry(g >> 8, g & 0xFF)))
        except Exception:  # noqa: BLE001
            continue
        if n == 0 and rom.has('TerryExtraTiles'):          # Terry's eight extra tiles go to $8180 (tile $18)
            tiles = tiles[:0x180].ljust(0x180, b'\0') + rom.decompress(rom.lin('TerryExtraTiles'))
        frames = [frame_entries(r, f) for f in sets[n]]
        if not frames:
            continue
        lab = rom.label_at(rom.far_entry(g >> 8, g & 0xFF)) or '{:02X}:{:02X}'.format(g >> 8, g & 0xFF)
        rows.append((('${:02X}'.format(n), 'sprite set ${:02X}, tiles {}'.format(n, lab), None), tiles, frames,
                     r[cpal + n] & 7))
    out.append(sheet(rows, 'people-sprites', 'Terry and the people',
                     ['The characters of the field, one row per sprite set (Terry is set $00): the frames of '
                      'CharacterMetasprites (bank $05), each a list of 8 x 8 sprites (Y, X, tile, attributes), drawn '
                      'with the tiles of the same graphics number in ActorGfx and the set\'s colour from '
                      'CharacterPalettes (one of the eight field sprite palettes, FieldObjPalettes). Usually six '
                      'frames: down, up and sideways, two steps each; the other side is the sideways frames '
                      'flipped.'],
                     ['DrawCharacterSprite', 'CharacterMetasprites', 'CharacterPalettes', 'ActorGfx', 'LoadActorGfx'],
                     'CharacterMetasprites'))
    # ---- the monsters: field object sprite number species + $10 (bank $10 below $90, bank $11 from there)
    s10 = read_sets(rom, 'FieldSpriteSets_10', 0x80)
    s11 = read_sets(rom, 'FieldSpriteSets_11', 87)
    p10, p11 = rom.lin('FieldSpritePalettes_10'), rom.lin('FieldSpritePalettes_11')
    refs = rom.lin('MonsterGfxRefs')
    rows, firsts = [], {}
    for s in range(SPECIES):
        num = s + 0x10
        if num < 0x90:
            fl, pal = s10[num - 0x10], r[p10 + num - 0x10]
        elif num - 0x90 < len(s11):
            fl, pal = s11[num - 0x90], r[p11 + num - 0x90]
        else:
            continue
        e, b = r[refs + 2 * num], r[refs + 2 * num + 1]
        try:
            tiles = rom.decompress(rom.far_entry(b, e))
        except Exception:  # noqa: BLE001
            continue
        frames = [frame_entries(r, f) for f in fl]
        if not frames:
            continue
        rows.append((('#{} {}'.format(s, names[s]), 'sprite ${:02X}, {} frames'.format(num, len(frames)), card(s)),
                     tiles, frames, pal & 7))
        b1 = bounds([frames[:1]])
        one = [bytearray([255] * b1[0]) for _ in range(b1[1])]
        draw_frame(one, 0, 0, frames[0], tiles, pal & 7, b1)
        firsts[s] = (one, pal & 7)
    out.append(sheet(rows, 'monster-sprites', 'Monster walking sprites',
                     ['The monsters as they walk behind Terry on the field, one row per species: field object sprite '
                      'species + $10, whose frames are in FieldSpriteSets_10 (bank $10, sprites $10-$8F) or '
                      'FieldSpriteSets_11 (bank $11, from $90), with the tiles MonsterGfxRefs names (the MonSprite_ '
                      'blocks) and the set\'s colour from FieldSpritePalettes_10/11. Click a row for the card.'],
                     ['DrawFieldSprite_10', 'DrawFieldSprite_11', 'FieldSpriteSets_10', 'FieldSpriteSets_11',
                      'MonsterGfxRefs'], 'FieldSpriteSets_10'))
    if os.environ.get('XDEBUG'):
        print('no walking sprite:', [s for s in range(SPECIES) if s not in firsts], file=sys.stderr)
    ctx_firsts = {s: packed_image(img, colors, scale=3) for s, (img, _) in firsts.items()}
    global WALKERS
    WALKERS = ctx_firsts
    return out


WALKERS = {}


def walkers(ctx):
    """species -> a small image of its first walking frame (for the monster cards)."""
    if not WALKERS:
        build(ctx)
    return WALKERS
