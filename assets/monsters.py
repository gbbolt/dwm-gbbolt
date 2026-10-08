"""The monsters: every species' picture in its own colours and its record from MonsterStats."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _game import image  # noqa: E402
import build as engine  # noqa: E402

GROUP = 'monsters'
SPECIES = 217                 # records 217-220 have no picture and no stats: unused
FAMILIES = ['Slime', 'Dragon', 'Beast', 'Bird', 'Plant', 'Bug', 'Devil', 'Zombie', 'Material', 'Boss']
GROWTH = ['HP', 'MP', 'Atk', 'Def', 'Agl', 'Int']


class Rom:
    def __init__(self, ctx):
        self.r = ctx.rom
        self.syms = ctx.syms

    def lin(self, name):
        return engine.sym_linear(name, self.syms)

    def far_entry(self, bank, entry):
        """Linear address of entry `entry` of bank `bank`'s table at $4001."""
        o = bank * 0x4000
        return o + (self.r[o + 1 + 2 * entry] | self.r[o + 2 + 2 * entry] << 8) - 0x4000

    def decompress(self, src):
        """The format of DecompressCore: length, marker byte, then literal bytes and back-references."""
        r = self.r
        n, marker, p = r[src] | r[src + 1] << 8, r[src + 2], src + 3
        out = bytearray()
        while len(out) < n:
            b = r[p]
            p += 1
            if b != marker:
                out.append(b)
                continue
            ll, hc = r[p], r[p + 1]
            p += 2
            pos = (hc >> 4) << 8 | ll
            count = hc & 0xF
            if count == 0xF:
                count = r[p] + 0x13
                p += 1
            else:
                count += 4
            for _ in range(count):
                if len(out) >= n:
                    break
                q = pos - 0x1000 if pos >= len(out) else pos
                out.append(out[q] if 0 <= q < len(out) else 0)
                pos += 1
        return bytes(out)

    def text(self, a):
        out = ''
        while self.r[a] != 0xF0:
            x = self.r[a]
            out += (chr(65 + x - 0x24) if 0x24 <= x < 0x3E else chr(97 + x - 0x3E) if 0x3E <= x < 0x58 else
                    chr(48 + x - 0x1A) if 0x1A <= x < 0x24 else ' ' if x == 0x62 else '')
            a += 1
        return out

    def texts(self, label, n):
        """Texts of a system text group: the label is a table of pointers into its bank."""
        a = self.lin(label)
        base = a - 0x4000 - (a & 0x3FFF)
        return [self.text(base + (self.r[a + 2 * i] | self.r[a + 2 * i + 1] << 8)) for i in range(n)]

    def table_length(self, label, nxt):
        return (self.lin(nxt) - self.lin(label)) // 2

    def picture(self, species):
        """6 x 6 tiles, row by row: graphics reference from the home-bank table read by LoadMonsterPicture."""
        g = self.r[0x2B9F + 2 * species] | self.r[0x2BA0 + 2 * species] << 8
        data = self.decompress(self.far_entry(g >> 8, g & 0xFF))
        img = [bytearray(48) for _ in range(48)]
        for t in range(36):
            tx, ty = t % 6, t // 6
            for y in range(8):
                lo, hi = data[16 * t + 2 * y], data[16 * t + 2 * y + 1]
                for x in range(8):
                    img[ty * 8 + y][tx * 8 + x] = (hi >> (7 - x) & 1) << 1 | (lo >> (7 - x) & 1)
        return img, g

    def palette(self, species):
        """The picture's four colours: 8 bytes per species from the table LoadMonPicPalette reads (bank $17)."""
        a = 0x17 * 0x4000 + 0x62FD - 0x4000 + 8 * species
        out = []
        for i in range(4):
            w = self.r[a + 2 * i] | self.r[a + 2 * i + 1] << 8
            out.append('#%02x%02x%02x' % ((w & 31) * 255 // 31, (w >> 5 & 31) * 255 // 31, (w >> 10 & 31) * 255 // 31))
        return out


def build_assets(ctx):
    rom = Rom(ctx)
    names = rom.texts('SysText_MonsterNames', SPECIES)
    nskills = rom.table_length('SysText_SkillNames', 'SysText_MonsterInitials')
    skills = rom.texts('SysText_SkillNames', nskills)
    stats = rom.lin('MonsterStats')
    pics = [rom.picture(s) for s in range(SPECIES)]
    pals = [rom.palette(s) for s in range(SPECIES)]

    # the gallery: each species' four colours are a palette of their own, so one picture holds at most
    # 63 species (colour numbers up to 254): four pictures of 60 (15 x 4)
    cols, per = 15, 60
    out = []
    for part, lo in enumerate(range(0, SPECIES, per)):
        hi = min(SPECIES, lo + per)
        rows = (hi - lo + cols - 1) // cols
        pix = [bytearray([255] * (cols * 50)) for _ in range(rows * 50)]
        colors, marks = [], []
        for s in range(lo, hi):
            img, _ = pics[s]
            k = s - lo
            x0, y0 = (k % cols) * 50 + 1, (k // cols) * 50 + 1
            for y in range(48):
                row = pix[y0 + y]
                for x in range(48):
                    row[x0 + x] = 4 * k + img[y][x]
            colors += pals[s]
            marks.append({'x': x0, 'y': y0, 'w': 48, 'h': 48, 'label': '{} {}'.format(s, names[s]),
                          'text': '#{} {} ({} family)'.format(s, names[s], FAMILIES[ctx.rom[stats + 43 * s]])})
        out.append(image(pix, colors, name='monster-gallery-{}'.format(part + 1),
                         title='Monster pictures {}-{}'.format(lo, hi - 1), scale=2, marks=marks,
                         doc=['The monsters\' big pictures, in the order of their species numbers, each in its '
                              'own four colours. A picture is 6 x 6 tiles, packed in the game\'s compression '
                              'format (see DecompressCore); the home-bank table read by LoadMonsterPicture gives '
                              'the bank and entry of each, and LoadMonPicPalette\'s table the colours. Hover a '
                              'picture for its name.'],
                         users=['LoadMonsterPicture', 'DecompressCore', 'LoadMonPicPalette']))

    # the list: one row per species
    rowsout = []
    for s in range(SPECIES):
        r = ctx.rom[stats + 43 * s: stats + 43 * s + 43]
        img, g = pics[s]
        rowsout.append([
            {'image': image(img, pals[s], scale=1)},
            s, names[s], FAMILIES[r[0]] if r[0] < len(FAMILIES) else r[0], r[1],
            ', '.join(skills[k] if k < len(skills) else '#{}'.format(k) for k in r[6:9]),
        ] + list(r[9:15]))
    out.append({'name': 'monster-list', 'type': 'table', 'title': 'Monster list',
                'columns': ['', 'No.', 'Name', 'Family', 'Max level', 'Skills at birth'] + GROWTH,
                'rows': rowsout,
                'doc': ['Every species with its record from MonsterStats (43 bytes each): the family, the highest '
                        'level it can reach, the three skills it is born with, and its growth values for HP, MP, '
                        'attack, defense, agility and intelligence (how fast each stat rises per level). The '
                        'names come from the game\'s own name list (system texts, group 5) and the skill names '
                        'from group 6. Species 217-220 have no record and no picture.'],
                'users': ['CopyMonsterStats', 'MonsterStats', 'SysText_MonsterNames', 'SysText_SkillNames']})
    return out


def build(ctx):  # noqa: F811 - the plugin entry point
    return build_assets(ctx)
