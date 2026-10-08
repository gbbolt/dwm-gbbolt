"""The gate worlds: their floors and the wild monsters met on each floor range."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from monsters import Rom, SPECIES  # noqa: E402

GROUP = 'gates'
WORLDS = 32


def pct(ws):
    t = sum(ws)
    return [round(100 * w / t) if t else 0 for w in ws]


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    names = rom.texts('SysText_MonsterNames', SPECIES)
    first = rom.lin('GateWorldFirstTable')
    splits = rom.lin('GateWorldFloorSplits')
    worlds = rom.lin('GateWorldTable')
    tables = rom.lin('FloorTables')
    bank = splits - (splits & 0x3FFF)
    rows = []
    for g in range(WORLDS):
        w = r[worlds + 8 * g: worlds + 8 * g + 8]
        nfloors = w[3]
        p = bank + (r[splits + 2 * g] | r[splits + 2 * g + 1] << 8) - 0x4000
        # floor f (0-based) uses entry first + (number of thresholds <= f + 1)
        lo = 1
        for n in range(16):
            t = r[p + n]
            hi = min(t - 1, nfloors) if t <= nfloors else nfloors
            e = r[first + g] + n
            d = r[tables + 26 * e: tables + 26 * e + 26]
            sp = [d[0x0A + 2 * i] for i in range(5)]
            ws = pct(d[5:10])
            mons = ['{} {}%{}'.format(names[s] if s < SPECIES else '#{}'.format(s), q,
                                      ' (alone)' if d[0x14 + i] == 1 else '')
                    for i, (s, q) in enumerate(zip(sp, ws)) if q and s != 0xFF]
            sizes = '/'.join(str(q) for q in pct(d[2:5]))
            rows.append([g, nfloors, '{}-{}'.format(lo, hi) if hi > lo else str(lo), e,
                         ', '.join(mons), sizes, d[0x19]])
            if t > nfloors:
                break
            lo = hi + 1
    return [{'name': 'gate-encounters', 'type': 'table', 'title': 'Gate worlds and their monsters',
             'columns': ['Gate world', 'Floors', 'On floors', 'Table', 'Wild monsters (chance)',
                         'Group of 1/2/3 (%)', 'Music'],
             'rows': rows,
             'doc': ['The wild monsters of each gate world, floor by floor. GateWorldTable gives a world\'s '
                     'number of floors; SelectFloorTable picks the FloorTables entry from the world\'s first '
                     'entry (GateWorldFirstTable) and how many of its floor thresholds (GateWorldFloorSplits) '
                     'are reached, so deeper floors move on to stronger tables. Each entry weighs five species '
                     'and the size of a group; "alone" species never come with others (RollEncounterGroup).'],
             'users': ['GateWorldTable', 'GateWorldFirstTable', 'GateWorldFloorSplits', 'FloorTables',
                       'SelectFloorTable', 'RollEncounterGroup']}]
