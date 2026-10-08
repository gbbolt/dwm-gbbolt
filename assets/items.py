"""The items: names, descriptions and the 12-byte records of ItemData."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from monsters import Rom  # noqa: E402

GROUP = 'items'
ITEMS = 44


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    n = min(ITEMS, rom.table_length('SysText_ItemNames', 'SysText_ItemDescriptions'))
    names = rom.texts('SysText_ItemNames', n)
    descs = rom.texts('SysText_ItemDescriptions', n)
    a = rom.lin('ItemData')
    rows = []
    for i in range(1, n):
        d = r[a + 12 * i: a + 12 * i + 12]
        price = d[1] | d[2] << 8
        amount = '' if d[9] in (0, 0xFF) else '{}-{}'.format(d[9], d[10]) if d[10] not in (0, 0xFF) else d[9]
        rows.append([i, names[i], descs[i], d[0], price, '{}%'.format(d[3]), amount])
    return [{'name': 'item-list', 'type': 'table', 'title': 'Items',
             'columns': ['No.', 'Name', 'Description', 'Kind', 'Price', 'Used up', 'Amount'], 'rows': rows,
             'doc': ['Every item with its record from ItemData (12 bytes each, copied by CopyItemData): the kind '
                     '(0 restores HP or MP, 1 cures or revives, 2-7 other groups), the price in gold, the chance '
                     'that using it uses it up, and the amount it heals or raises (base and upper value). Names '
                     'and descriptions are the game\'s own texts (system text groups 8 and 9). The SageStone\'s text '
                     'promises 60 to 70 HP, but its record heals 45 to 55.'],
             'users': ['ItemData', 'CopyItemData', 'SysText_ItemNames', 'SysText_ItemDescriptions']}]
