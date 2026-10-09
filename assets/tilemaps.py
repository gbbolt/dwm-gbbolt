"""The fixed screen layouts of bank $5F drawn with the tiles the game really puts under them: the staff credits
and the closing screen of the ending (as the ending's own code builds them), and the three places of an enemy
picture in battle."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, SPECIES, packed_image  # noqa: E402
from _dwm import ram_names  # noqa: E402
from _game import Machine  # noqa: E402

GROUP = 'screens'
BOOT_FRAMES = 60                    # the game's set-up is done and its main loop runs
SAMPLE = ['Slime', 'Dracky', 'Anteater']


def ram(name):
    for a, (n, _) in ram_names().items():
        if n == name:
            return a
    raise KeyError(name)


def start_mode(m, mode, step):
    """Leave the running game mode for game mode `mode`, step `step` (as wGameModeChange does)."""
    m.mem[ram('wGameMode')] = mode
    m.mem[ram('wGameModeStep')] = step
    m.mem[ram('wFadeState')] = 0
    m.mem[ram('wGameModeChange')] = 1


def crop(img, h):
    return [bytearray(r) for r in img[:h]]


def compact(img, colors):
    """Renumber the pixels to the colours actually used."""
    used, cmap, cols = {}, {}, []
    out = []
    for row in img:
        nr = bytearray(len(row))
        for x, p in enumerate(row):
            c = colors[p]
            k = cmap.get(c)
            if k is None:
                k = cmap[c] = len(cols)
                cols.append(c)
            nr[x] = k
        out.append(nr)
    return out, cols


def build(ctx):
    rom = Rom(ctx)
    out = []
    users = ['EndingInitCredits', 'EndingInitSavePrompt', 'CopyTileRect_5F', 'PrintCreditsPage',
             'LoadCreditsMonster', 'DrawCreditsLastPage']

    # ---- the staff credits: the first page, then the last
    m = Machine(ctx.rom)
    m.run(BOOT_FRAMES)
    start_mode(m, 4, 0)
    m.run(150)
    first, cols = compact(m.screen(), m.colors())
    out.append(packed_image(first, cols, scale=2, name='credits-screen', title='Credits page',
                            unit='CreditsTilemap', subtitle='20 x 18 tiles, the first page',
                            doc=['CreditsTilemap as the ending shows it: EndingInitCredits copies it to the screen, '
                                 'PrintCreditsPage prints the page\'s heading into tiles $00-$25 and its names from '
                                 'tile $26 on (the text printer writes the letters into those tiles), and '
                                 'LoadCreditsMonster puts the page\'s monster picture into tiles $AA-$CD. Every page '
                                 'uses this layout with new letters and a new monster; tile $E0 is the plain '
                                 'background. Drawn here by running the ending\'s own code.'],
                            users=users + ['CreditsTilemap']))
    m.mem[ram('wSceneObjects') + 1] = 25          # the next page is the last one
    for _ in range(8):
        m.run(100)
        if m.mem[ram('wSceneObjects') + 1] == 26 and m.mem[ram('wSceneObjects')] >= 3:
            break
    m.run(40)
    last, cols = compact(m.screen(), m.colors())
    out.append(packed_image(crop(last, 88), cols[:], scale=2, name='credits-last-page', title='Last credits page',
                            unit='CreditsLastTilemap', subtitle='20 x 11 tiles',
                            doc=['CreditsLastTilemap, the top 11 rows of the last credits page, which '
                                 'DrawCreditsLastPage copies over the usual layout before the page is printed: '
                                 'three lines of text and no monster. Drawn here by running the ending\'s own code.'],
                            users=users + ['CreditsLastTilemap']))
    # the unused rest of the last page: its tile numbers in the tiles the last page has loaded
    v0 = bytes(m.vram_bank(0))
    lin = rom.lin('CreditsLastUnusedRows')
    tm = ctx.rom[lin:lin + 20 * 7]
    pal = m.colors()[0:4]
    img = [bytearray(160) for _ in range(56)]
    for ty in range(7):
        for tx in range(20):
            t = tm[ty * 20 + tx]
            for y in range(8):
                lo, hi = v0[16 * t + 2 * y], v0[16 * t + 2 * y + 1]
                for x in range(8):
                    img[ty * 8 + y][tx * 8 + x] = (hi >> (7 - x) & 1) << 1 | (lo >> (7 - x) & 1)
    out.append(packed_image(img, pal, scale=2, name='credits-unused-rows', title='Credits, unused rows',
                            unit='CreditsLastUnusedRows', subtitle='20 x 7 tiles, never shown',
                            doc=['The rows 11-17 that follow CreditsLastTilemap: the bottom of a page with a monster '
                                 'picture (tiles $AA-$CD) beside more text lines, like CreditsTilemap. '
                                 'DrawCreditsLastPage copies only 11 rows, so the game never shows them. Drawn here '
                                 'with the tiles and the first palette of the last credits page; the picture tiles '
                                 'still hold the previous page\'s monster.'],
                            users=['DrawCreditsLastPage', 'CreditsLastUnusedRows']))

    # ---- the closing screen with its text box
    m = Machine(ctx.rom)
    m.run(BOOT_FRAMES)
    start_mode(m, 4, 1)
    m.run(400)
    shot, cols = compact(m.screen(), m.colors())
    box = [bytearray(r) for r in shot[13 * 8:17 * 8]]
    box, cols = compact([[p for p in r] for r in box], cols)
    out.append(packed_image(box, cols, scale=2, name='ending-text-box', title='Closing text box',
                            unit='EndingSaveBoxTilemap', subtitle='20 x 4 tiles',
                            doc=['EndingSaveBoxTilemap, the text box of the closing screen after the credits '
                                 '(EndingInitSavePrompt puts it in rows 13-16): the window frame tiles from entry '
                                 '2E:00 at tile $D0 on ($EE/$EF/$FA-$FF the frame, $E0 plain), and the letters, which '
                                 'the text printer writes into tiles $B0-$BD and below. Drawn here by running the '
                                 'ending\'s own code, with the first words of the closing text printed.'],
                            users=['EndingInitSavePrompt', 'SavePromptPrintEnd', 'EndingSaveBoxTilemap']))

    # ---- the enemy picture slots of a battle
    names = rom.texts('SysText_MonsterNames', SPECIES)
    for i in range(3):
        s = names.index(SAMPLE[i]) if SAMPLE[i] in names else i
        pic, _ = rom.picture(s)
        lab = 'MonPicTiles{}'.format(i)
        lin = rom.lin(lab)
        tm = ctx.rom[lin:lin + 36]
        first_tile = tm[0]
        img = [bytearray(48) for _ in range(48)]
        for k, t in enumerate(tm):
            n = t - first_tile                       # the picture's own tile n
            sx, sy = (n % 6) * 8, (n // 6) * 8
            dx, dy = (k % 6) * 8, (k // 6) * 8
            for y in range(8):
                img[dy + y][dx:dx + 8] = pic[sy + y][sx:sx + 8]
        out.append(packed_image(img, rom.palette(s), scale=3, name='enemy-picture-{}'.format(i),
                                title='Enemy picture {}'.format(i), unit=lab,
                                subtitle='6 x 6 tiles ${:02X}-${:02X}'.format(first_tile, first_tile + 35),
                                doc=['{}: the 6 x 6 tile numbers of the {} enemy\'s picture in battle, row by row. The '
                                     'battle loads each enemy\'s picture (LoadMonsterPicture) into tiles ${:02X}-${:02X}, '
                                     'and the screen effects copy this block back to put the picture on the screen '
                                     '(CopyTileRectVRAM_5F, PicTileLayouts). Shown here with {}\'s picture as an '
                                     'example; in a fight these tiles hold whatever monster stands in that '
                                     'place.'.format(lab, ['first', 'second', 'third'][i], first_tile,
                                                     first_tile + 35, names[s])],
                                users=['PicTileLayouts', lab, 'CopyTileRectVRAM_5F']))
    return out
