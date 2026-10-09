"""Shared readers for the asset plugins: the ROM's tables (species, monster numbers, skills, items, gate
floors), the game's character set, the compressed graphics, and small helpers for linked cells."""
import base64
import os
import sys
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build as engine  # noqa: E402

SPECIES = 217                 # records 217-220 have no picture and no stats: unused
FAMILIES = ['Slime', 'Dragon', 'Beast', 'Bird', 'Plant', 'Bug', 'Devil', 'Zombie', 'Material', 'Boss']
GROWTH = ['HP', 'MP', 'Atk', 'Def', 'Agl', 'Int']
GROWTH_LONG = ['HP', 'MP', 'Attack', 'Defense', 'Agility', 'Intelligence']
FEMALE = ['always male', '10% female', '50% female', '84% female']     # FemaleChance by sex class
WORLDS = 32


def card(s):
    """The name of species s's card."""
    return 'monster-{:03d}'.format(s)


def packed_image(img, colors, scale=1, **fields):
    """An image part with deflated pixels (much smaller in the page than plain ones)."""
    out = {'type': 'image', 'width': len(img[0]), 'height': len(img), 'packed': 'zlib',
           'pixels': base64.b64encode(zlib.compress(b''.join(bytes(r) for r in img), 9)).decode(),
           'colors': list(colors), 'fixedColors': True, 'scale': scale}
    out.update(fields)
    return out


# ---- the character set of the texts (see TextGroup_1A_0)
CHARS = {0x5C: "'", 0x5D: '▶', 0x5E: ',', 0x5F: '.', 0x60: ';', 0x61: '..', 0x62: ' ', 0x63: '!', 0x64: '?',
         0x65: '"', 0x96: '[', 0x97: ']', 0x9A: '.', 0x9C: '-', 0x9D: '~', 0x9E: '/', 0x9F: '*', 0xA0: '(',
         0xA1: ')', 0xA2: '+', 0xA3: ':', 0xA4: '...', 0xA8: '♀', 0xB6: '&', 0x98: '?', 0x99: '!', 0x9B: '·',
         0xA5: 'Lv', 0xA6: 'Ex', 0xAC: '★', 0xB5: '©'}
for _i, _s in enumerate(['l', 't', 's', 'r', 'm', 'y', 'v', 'd', 'e', 'c', 'n', 'T']):
    CHARS[0x66 + _i] = "'" + _s
ARG = {0x00: 'monster', 0x10: 'item', 0x20: 'target', 0x30: 'word 4'}
SKIP1 = {0xE9, 0xF8, 0xFB, 0xFC}           # control codes with one parameter byte
SKIP0 = {0xEA, 0xEB, 0xFD, 0xFE, 0xEC, 0xED, 0xF4, 0xF5, 0xF3, 0xFA, 0xEE}


def char(x):
    if x < 10:
        return chr(48 + x)
    if 0x0A <= x <= 0x0D:
        return chr(48 + x - 0x0A)
    if 0x10 <= x <= 0x19:
        return '◆'
    if 0x1A <= x < 0x24:
        return chr(48 + x - 0x1A)
    if 0x24 <= x < 0x3E:
        return chr(65 + x - 0x24)
    if 0x3E <= x < 0x58:
        return chr(97 + x - 0x3E)
    return CHARS.get(x)


def decode(r, a, limit=2000):
    """A dialogue text from a text bank, readable: ' / ' a new line, '▼' a wait for a button, '¶' a new
    box, <player> the player's name, <monster>/<item>/... words the code puts in, <yes/no> a choice."""
    out, n = '', 0
    while n < limit:
        x = r[a]
        a += 1
        n += 1
        if x == 0xF0:
            break
        c = char(x)
        if c is not None:
            out += c
        elif x in (0x8D, 0x8E):
            pass
        elif x in (0xEF, 0xF1):
            out += ' / '
        elif x == 0xF2:
            out += ' ¶ '
        elif x == 0xF7:
            out += ' ▼'
        elif x == 0xF6:
            out += '<player>'
        elif x == 0xF9:
            out += '<{}>'.format(ARG.get(r[a], 'word ${:02X}'.format(r[a])))
            a += 1
        elif x == 0xE8:
            a += 2
        elif x in SKIP1:
            a += 1
        elif x in SKIP0:
            pass
        elif 0xE0 <= x <= 0xE6 or x == 0xFF:
            out += ' <yes/no>'
        elif x == 0xE7:
            out += ' <no/yes>'
        else:
            out += '{{{:02X}}}'.format(x)
    while '  ' in out:
        out = out.replace('  ', ' ')
    while ' /  / ' in out or ' / / ' in out:
        out = out.replace(' / / ', ' / ')
    return out.strip(' /')


class Rom:
    def __init__(self, ctx):
        self.r = ctx.rom
        self.syms = ctx.syms

    def lin(self, name):
        return engine.sym_linear(name, self.syms)

    def has(self, name):
        try:
            return self.lin(name) is not None
        except Exception:  # noqa: BLE001
            return False

    def label_at(self, lin):
        """The label at a linear ROM address, or None."""
        if not hasattr(self, '_at'):
            self._at = {}
            for n in self.syms:
                if not isinstance(self.syms[n], int) or self.syms[n] >= 0x8000:
                    continue                    # RAM and constants
                try:
                    a = self.lin(n)
                except Exception:  # noqa: BLE001
                    continue
                if a is not None and '.' not in n:
                    self._at.setdefault(a, n)
        return self._at.get(lin)

    def next_label(self, lin):
        """Linear address of the first label after `lin` (the end of a data block)."""
        self.label_at(lin)
        later = [a for a in self._at if a > lin]
        return min(later) if later else lin

    def word(self, a):
        return self.r[a] | self.r[a + 1] << 8

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
                    chr(48 + x - 0x1A) if 0x1A <= x < 0x24 else chr(48 + x) if x < 10 else
                    ' ' if x in (0x62, 0xF1) else '')
            a += 1
        return out

    def texts(self, label, n):
        """Texts of a system text group: the label is a table of pointers into its bank."""
        a = self.lin(label)
        base = a - 0x4000 - (a & 0x3FFF)
        return [self.text(base + (self.r[a + 2 * i] | self.r[a + 2 * i + 1] << 8)) for i in range(n)]

    def table_length(self, label, nxt):
        return (self.lin(nxt) - self.lin(label)) // 2

    @staticmethod
    def tiles(data, count, cols):
        """2bpp tiles as rows of colour numbers, `cols` tiles per row."""
        rows = (count + cols - 1) // cols
        img = [bytearray(cols * 8) for _ in range(rows * 8)]
        for t in range(count):
            tx, ty = t % cols, t // cols
            for y in range(8):
                lo, hi = data[16 * t + 2 * y], data[16 * t + 2 * y + 1]
                for x in range(8):
                    img[ty * 8 + y][tx * 8 + x] = (hi >> (7 - x) & 1) << 1 | (lo >> (7 - x) & 1)
        return img

    def picture(self, species):
        """6 x 6 tiles, row by row: graphics reference from MonsterPicRefs (read by LoadMonsterPicture)."""
        a = self.lin('MonsterPicRefs') + 2 * species
        g = self.r[a] | self.r[a + 1] << 8
        data = self.decompress(self.far_entry(g >> 8, g & 0xFF))
        return self.tiles(data, 36, 6), g

    @staticmethod
    def color(w):
        return '#%02x%02x%02x' % ((w & 31) * 255 // 31, (w >> 5 & 31) * 255 // 31, (w >> 10 & 31) * 255 // 31)

    def palette(self, species):
        """The picture's four colours: 8 bytes per species from MonPicPalettes (read by LoadMonPicPalette)."""
        a = self.lin('MonPicPalettes') + 8 * species
        return [self.color(self.word(a + 2 * i)) for i in range(4)]

    # ---- tables
    def stats(self, s):
        a = self.lin('MonsterStats') + 43 * s
        return self.r[a:a + 43]

    def exp_table(self, t):
        a = self.lin('ExpTables') + 3 * 99 * t
        return [self.r[a + 3 * i] | self.r[a + 3 * i + 1] << 8 | self.r[a + 3 * i + 2] << 16 for i in range(99)]

    def growth_curve(self, c):
        a = self.lin('StatGrowthTables') + 99 * c
        return list(self.r[a:a + 99])

    def template(self, n):
        """Monster number n's 25-byte template (MonTemplates): species, level, stats, skills."""
        a = self.lin('MonTemplates') + 25 * n
        d = self.r[a:a + 25]
        w = [d[5 + 2 * i] | d[6 + 2 * i] << 8 for i in range(6)]
        return {'species': d[0], 'b1': d[1], 'b2': d[2], 'b3': d[3], 'level': d[4], 'stats': w,
                'bytes': list(d[17:21]), 'skills': [k for k in d[21:25] if k != 0xFF], 'raw': d}

    def templates_count(self):
        a = self.lin('MonTemplates')
        end = self.lin('CheckFieldItemUse') if self.has('CheckFieldItemUse') else a + 25 * 512
        return (end - a) // 25

    def skill_record(self, k):
        """The 19-byte record of skill k (SkillPointers)."""
        p = self.lin('SkillPointers')
        bank = p - (p & 0x3FFF)
        a = bank + self.word(p + 2 * k) - 0x4000
        return self.r[a:a + 19], a

    def resist_names(self, skills):
        """Names of the 27 resistances: after the skills that are met with each (skill record +5 = number + 1;
        resistance 26 shares the packed byte with 'none' and has no skill)."""
        groups = {}
        for k in range(len(skills)):
            try:
                rec, _ = self.skill_record(k)
            except Exception:  # noqa: BLE001
                continue
            if rec[5]:
                groups.setdefault(rec[5] - 1, []).append(skills[k])
        return [groups[i][0] if i in groups else '#{}'.format(i) for i in range(27)], groups

    def floor_worlds(self):
        """Each gate world: (number of floors, [(first floor, last floor, FloorTables entry)])."""
        r = self.r
        first = self.lin('GateWorldFirstTable')
        splits = self.lin('GateWorldFloorSplits')
        worlds = self.lin('GateWorldTable')
        bank = splits - (splits & 0x3FFF)
        out = []
        for g in range(WORLDS):
            w = r[worlds + 8 * g: worlds + 8 * g + 8]
            nfloors = w[3]
            p = bank + self.word(splits + 2 * g) - 0x4000
            lo, parts = 1, []
            for n in range(16):
                t = r[p + n]
                hi = min(t - 1, nfloors) if t <= nfloors else nfloors
                parts.append((lo, hi, r[first + g] + n))
                if t > nfloors:
                    break
                lo = hi + 1
            out.append((nfloors, parts, w))
        return out

    def floor_table(self, e):
        """FloorTables entry e: the five (monster number, weight, alone) and the group-size weights."""
        a = self.lin('FloorTables') + 26 * e
        d = self.r[a:a + 26]
        mons = [(self.word(a + 0x0A + 2 * i), d[5 + i], d[0x14 + i] == 1) for i in range(5)]
        return {'mons': mons, 'sizes': list(d[2:5]), 'music': d[0x19], 'style': d[0]}


def ram_names():
    """{address: (name, size)} of src/ram.inc."""
    import re
    out = {}
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'src', 'ram.inc')
    try:
        for line in open(path, encoding='utf-8'):
            m = re.match(r'DEF (\w+) EQU \$([0-9A-Fa-f]+)\s*;@\s*(\S+)', line)
            if m:
                t = m.group(3)
                k = re.match(r'u8\[(\d+)\]', t)
                size = int(k.group(1)) if k else 2 if t == 'u16' else 1
                out[int(m.group(2), 16)] = (m.group(1), size)
    except OSError:
        pass
    return out


class MessageFinder:
    """Where message n (PrintMessage, $000-$9FF) lives: PrintMessage is run on a bare CPU until the text
    printer looks the text up (LookUpTextPointer). That follows the handlers of MessageGroupTable and the text
    banks that hand some groups on to another bank. where(n) = (bank, group, index, group table address)."""

    def __init__(self, ctx, rom):
        from _game import Machine
        self.rom = rom
        self.m = Machine(ctx.rom)
        self.start = rom.lin('PrintMessage')
        self.lookup = rom.lin('LookUpTextPointer')
        names = {n: a for a, (n, _) in ram_names().items()}
        self.w_group, self.w_index = names['wTextGroup'], names['wTextIndex']
        self.cache = {}

    def where(self, n):
        if n in self.cache:
            return self.cache[n]
        m, c = self.m, self.m.cpu
        got = None
        if 0 <= n < 0xA00:
            m.mem[0xC000:0xE000] = bytes(0x2000)
            c.pc, c.sp, c.ime = self.start, 0xDFF0, False
            c.h, c.l = n >> 8, n & 0xFF
            c.push(0xFFFF)
            for _ in range(20000):
                if c.pc == self.lookup:
                    bank = m.mbc.rom_bank
                    o = bank * 0x4000 - 0x4000
                    de = c.d << 8 | c.e
                    g, i = m.mem[self.w_group], m.mem[self.w_index]
                    t = self.rom.word(o + de + 2 * g)
                    if 0x4000 <= de < 0x8000 and 0x4000 <= t < 0x8000:
                        got = (bank, g, i, o + t)
                    break
                if c.pc == 0xFFFF:
                    break
                c.step()
        self.cache[n] = got
        return got


def group_length(rom, table, bound):
    """Number of text pointers in a group table: up to `bound` (the next table) or the first text."""
    bank = table - (table & 0x3FFF)
    o = bank - 0x4000
    lowest, n = bound, 0
    while table + 2 * n < lowest and n < 256:
        v = rom.word(table + 2 * n)
        if not 0x4000 <= v < 0x8000:
            break
        if table < o + v:
            lowest = min(lowest, o + v)
        n += 1
    return n


def species_cell(names, s, text=None):
    """A link to species s's card."""
    if 0 <= s < SPECIES:
        return {'asset': card(s), 'text': text or names[s]}
    return text or '#{}'.format(s)
