"""The system texts of bank $41, group by group, decoded with the game's character set."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from monsters import Rom  # noqa: E402

GROUP = 'texts'
GROUPS = ['SysText_DebugMenus', 'SysText_DebugLabels', 'SysText_FieldItems', 'SysText_ShortNames',
          'SysText_FamilyIcons', 'SysText_MonsterNames', 'SysText_SkillNames', 'SysText_MonsterInitials',
          'SysText_ItemNames', 'SysText_ItemDescriptions', 'SysText_Personalities', 'SysText_Battle',
          'SysText_Watabou', 'SysText_ItemUse', 'SysText_Spells']
PUNCT = {0x5E: ',', 0x5F: '.', 0x63: '!', 0x64: '?', 0x68: "'s", 0xA0: '(', 0xA1: ')',
         0xF2: ' | ', 0xF6: '<Terry>', 0xF7: ' ▼'}


def decode(r, a):
    out, n = '', 0
    while r[a] != 0xF0 and n < 400:
        x = r[a]
        a += 1
        n += 1
        if 0x24 <= x < 0x3E:
            out += chr(65 + x - 0x24)
        elif 0x3E <= x < 0x58:
            out += chr(97 + x - 0x3E)
        elif 0x1A <= x < 0x24:
            out += chr(48 + x - 0x1A)
        elif x < 10:
            out += chr(48 + x)
        elif x == 0x62:
            out += ' '
        elif x == 0xF1:
            out += ' / '
        elif x in PUNCT:
            out += PUNCT[x]
        elif x == 0xF9:
            out += '<{}>'.format(r[a] // 16 + 1 if r[a] % 16 == 0 else '${:02X}'.format(r[a]))
            a += 1
        else:
            out += '{{{:02X}}}'.format(x)
    return out


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    rows = []
    for g, label in enumerate(GROUPS):
        a = rom.lin(label)
        base = a - 0x4000 - (a & 0x3FFF)
        ptrs = []
        while True:
            p = base + (r[a + 2 * len(ptrs)] | r[a + 2 * len(ptrs) + 1] << 8)
            ptrs.append(p)
            end = rom.lin(GROUPS[g + 1]) if g + 1 < len(GROUPS) else min(ptrs)
            if a + 2 * len(ptrs) >= min(end, min(ptrs)) or len(ptrs) > 400:
                break
        for i, p in enumerate(ptrs):
            rows.append(['${:02X}{:02X}'.format(g, i), label[len('SysText_'):], decode(r, p)])
    return [{'name': 'system-texts', 'type': 'table', 'title': 'System texts', 'unit': 'SysText_DebugMenus',
             'columns': ['Number', 'Group', 'Text'], 'rows': rows,
             'doc': ['Every system text of bank $41 as PrintSystemText numbers it (group in the high byte, '
                     'entry in the low byte). The character set: $24-$3D A-Z, $3E-$57 a-z, $1A-$23 and '
                     '$00-$09 digits, $62 a space, $5E-$68 and $A0/$A1 punctuation, $F1 a new line (shown as /), '
                     '$F7 waits for a button (▼), $F2 starts a new box (|), $F6 is the player\'s name, $F9 '
                     'followed by $00/$10/$20 inserts the first, second or third word the caller gives (a '
                     'monster, item or amount; shown as <1> to <3>), $F0 ends a text. Codes not worked out yet '
                     'are shown as {XX}.'],
             'users': ['PrintSystemText'] + GROUPS}]
