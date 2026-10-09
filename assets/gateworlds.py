"""The gate worlds as GateWorldTable describes them, and the objects and items their floors are made with."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, SPECIES, WORLDS, species_cell  # noqa: E402

GROUP = 'gates'
ITEMS = 44


def item_cell(names, i):
    if 0 < i < len(names):
        return {'asset': 'item-list@i{}'.format(i), 'text': names[i]}
    return '#{}'.format(i)


def cumulative(d):
    """{index: percent} of a cumulative percent list (PickByPercent; 0 = never)."""
    prev, got = 0, {}
    for i, v in enumerate(d):
        if v > prev:
            got[i] = v - prev
            prev = v
    return got


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    names = rom.texts('SysText_MonsterNames', SPECIES)
    n_items = min(ITEMS, rom.table_length('SysText_ItemNames', 'SysText_ItemDescriptions'))
    items = rom.texts('SysText_ItemNames', n_items)
    worlds = rom.floor_worlds()

    # ---- the worlds
    rows, ids = [], []
    for g, (nfloors, parts, w) in enumerate(worlds):
        seen = {}
        for lo, hi, e in parts:
            for n, wt, _ in rom.floor_table(e)['mons']:
                if wt and n:
                    t = rom.template(n)
                    lv = seen.setdefault(t['species'], [t['level'], t['level']])
                    lv[0], lv[1] = min(lv[0], t['level']), max(lv[1], t['level'])
        mons = [[species_cell(names, s), 'Lv {}'.format(a if a == b else '{}-{}'.format(a, b))]
                for s, (a, b) in seen.items()]
        tables = '{}-{}'.format(parts[0][2], parts[-1][2]) if len(parts) > 1 else str(parts[0][2])
        rows.append([g, nfloors, w[0], w[1], {'asset': 'floor-items@c{}'.format(w[2]), 'text': str(w[2])},
                     '${:02X}'.format(w[4]), '{}, {}'.format(w[5], w[6]), w[7], tables, mons])
        ids.append('w{}'.format(g))
    # the bosses that events start (EventBossBattles: monster number, $DA04 value)
    a = rom.lin('EventBossBattles')
    end = a + 18
    boss_rows = []
    for i in range((end - a) // 2):
        num = rom.word(a + 2 * i)
        t = rom.template(num)
        boss_rows.append([i, '${:03X}'.format(num), species_cell(names, t['species']), t['level'],
                          ', '.join(str(v) for v in t['stats'])])
    out = [{'name': 'gate-worlds', 'type': 'card', 'title': 'Gate worlds', 'unit': 'GateWorldTable',
            'subtitle': '{} worlds'.format(WORLDS), 'summary': 'the 32 worlds behind the gates: floors, class, boss map, monsters',
            'sections': [
                {'columns': ['World', 'Floors', 'Floor set', 'Special set', 'Class', 'Boss map', 'Boss room x, y',
                             'Loot', 'Floor tables', 'Wild monsters (level)'], 'rows': rows, 'ids': ids, 'wide': True},
                {'title': 'Battles started by events (EventBossBattles): a Mimic of rising strength',
                 'columns': ['Index', 'Monster number', 'Species', 'Level', 'HP, MP, Atk, Def, Agl, Int'],
                 'rows': boss_rows, 'wide': True}],
            'doc': ['Each world behind a gate, from GateWorldTable (8 bytes: floor set, special floor set, class, '
                    'number of floors, boss map, the tile where the boss room is entered, loot). The floor set '
                    'picks the floor maps (FloorMapTables), the special set the special floors '
                    '(SpecialFloorChances), the class the objects and chest items (floor-items). The wild '
                    'monsters come from the world\'s run of FloorTables entries (GateWorldFirstTable, '
                    'GateWorldFloorSplits); their numbers are monster numbers, whose template '
                    '(monster-numbers) gives the species and level.',
                    'StartEventBossBattle starts a battle against one monster of EventBossBattles, picked by '
                    'wScriptBossIndex. All nine entries are a Mimic, from level 1 to 38 - the treasure chest that '
                    'turns out to be a monster; which script picks which strength is set by the scripts.'],
            'users': ['GateWorldTable', 'MakeGateFloor', 'SelectFloorTable', 'StartEventBossBattle',
                      'EventBossBattles']}]

    # ---- the classes: objects and chest items
    objs = rom.lin('FloorObjectTable')
    npc = rom.lin('FloorNpcChance')
    chest = rom.lin('FloorItemTables')
    rows, ids = [], []
    used = {}
    for g, (_, _, w) in enumerate(worlds):
        used.setdefault(w[2], []).append(g)
    for c in range(16):
        o = r[objs + 16 * c: objs + 16 * c + 16]
        kinds = cumulative(o[:9])
        its = cumulative(r[chest + 48 * c: chest + 48 * c + 48])
        rows.append([c, [{'asset': 'gate-worlds@w{}'.format(g), 'text': str(g)} for g in used.get(c, [])],
                     '{} + 0-{}'.format(o[9], o[10]) if o[10] else str(o[9]), '{}%'.format(o[11]),
                     ', '.join('kind {} {}%'.format(k, p) for k, p in kinds.items()),
                     '{:.0f}%'.format(100 * r[npc + c] / 256),
                     [[item_cell(items, i), '{}%'.format(p)] for i, p in sorted(its.items(), key=lambda x: -x[1])]])
        ids.append('c{}'.format(c))
    out.append({'name': 'floor-items', 'type': 'card', 'title': 'Floor objects and chest items',
                'unit': 'FloorItemTables', 'subtitle': '16 classes',
                'summary': 'what the gate floors hold, by the world\'s class',
                'sections': [{'columns': ['Class', 'Worlds', 'Objects per floor', 'Variant $10', 'Object kinds',
                                          'Special character', 'Items (chance)'],
                              'rows': rows, 'ids': ids, 'wide': True}],
                'doc': ['A gate world\'s class (GateWorldTable byte 2) decides what MakeGateFloor scatters over a '
                        'floor: FloorObjectTable gives the number of objects (a base count plus a random extra), '
                        'the chance of each object kind (kinds 0-6 hold an item, see ObjectIsChestTable) and the '
                        'chance that an object takes the $10 variant (a closed chest instead of a loose item, see '
                        'FloorObjectTiles); FloorNpcChance the chance of a special character on the floor; '
                        'FloorItemTables the item an object holds (cumulative percent chances over the item '
                        'numbers).'],
                'users': ['MakeGateFloor', 'FloorObjectTable', 'ObjectIsChestTable', 'FloorNpcChance',
                          'FloorItemTables']})
    return out
