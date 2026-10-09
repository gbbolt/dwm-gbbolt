"""The items: names, descriptions, the 12-byte records of ItemData, where they are found and won."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom  # noqa: E402

GROUP = 'items'
ITEMS = 44


def chest_chances(rom):
    """class -> {item: percent} from FloorItemTables (48 cumulative percent bytes per class)."""
    a = rom.lin('FloorItemTables')
    out = []
    for c in range(16):
        d = rom.r[a + 48 * c: a + 48 * c + 48]
        prev, got = 0, {}
        for i, v in enumerate(d):
            if v > prev:
                got[i] = v - prev
                prev = v
        out.append(got)
    return out


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    n = min(ITEMS, rom.table_length('SysText_ItemNames', 'SysText_ItemDescriptions'))
    names = rom.texts('SysText_ItemNames', n)
    descs = rom.texts('SysText_ItemDescriptions', n)
    nsk = rom.table_length('SysText_SkillNames', 'SysText_MonsterInitials')
    chests = chest_chances(rom)
    prizes = set(r[rom.lin('TournamentPrizes'): rom.lin('TournamentPrizes') + 16])
    late = set(r[rom.lin('TournamentPrizesLate'): rom.lin('TournamentPrizesLate') + 16])
    a = rom.lin('ItemData')
    rows, ids = [], []
    for i in range(1, n):
        d = r[a + 12 * i: a + 12 * i + 12]
        price = d[1] | d[2] << 8
        amount = '' if d[9] in (0, 0xFF) else '{}-{}'.format(d[9], d[10]) if d[10] not in (0, 0xFF) else d[9]
        found = [{'asset': 'floor-items@c{}'.format(c), 'text': '{} {}%'.format(c, ch[i])}
                 for c, ch in enumerate(chests) if i in ch]
        won = ', '.join(x for x, s in (('classes 1-8', prizes), ('from class 9', late)) if i in s)
        sk = 0xAF + i
        battle = {'asset': 'skill-list@s{}'.format(sk), 'text': 'in battle'} if sk < nsk else ''
        rows.append([i, names[i], descs[i], d[0], price, '{}%'.format(d[3]), amount, battle, found, won])
        ids.append('i{}'.format(i))
    return [{'name': 'item-list', 'type': 'card', 'title': 'Items', 'unit': 'ItemData',
             'subtitle': '{} items'.format(n - 1),
             'summary': '{} items: price, effect, where they are found'.format(n - 1),
             'sections': [{'columns': ['No.', 'Name', 'Description', 'Kind', 'Price', 'Used up', 'Amount', 'Effect',
                                       'In chests (class, chance)', 'Tournament prize'],
                           'rows': rows, 'ids': ids, 'wide': True}],
             'doc': ['Every item with its record from ItemData (12 bytes each, copied by CopyItemData): the kind '
                     '(0 restores HP or MP, 1 cures or revives, 2-7 other groups), the price in gold, the chance '
                     'that using it uses it up, and the amount it heals or raises (base and upper value). Names '
                     'and descriptions are the game\'s own texts (SysText_ItemNames, SysText_ItemDescriptions). '
                     'Used in battle, item n works as battle action $AF + n of the skill list. The chests of the '
                     'gate floors draw their item from FloorItemTables by the world\'s class (see floor-items); '
                     'the Starry Night tournament gives one of TournamentPrizes, from the 9th class on one of '
                     'TournamentPrizesLate. The SageStone\'s text promises 60 to 70 HP, but its record heals 45 '
                     'to 55.'],
             'users': ['ItemData', 'CopyItemData', 'SysText_ItemNames', 'SysText_ItemDescriptions',
                       'FloorItemTables', 'TournamentPrizes']}]
