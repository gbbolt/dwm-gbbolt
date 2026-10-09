"""Levels: the experience curves (ExpTables) and the stat growth curves (StatGrowthTables) of bank $13."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, SPECIES, GROWTH, species_cell  # noqa: E402

GROUP = 'monsters'
MARK_LEVELS = (10, 20, 30, 40, 50, 60, 70, 80, 90, 99)


def build(ctx):
    rom = Rom(ctx)
    names = rom.texts('SysText_MonsterNames', SPECIES)
    stats = [rom.stats(s) for s in range(SPECIES)]
    exp = [rom.exp_table(t) for t in range(32)]
    curves = [rom.growth_curve(c) for c in range(32)]
    by_exp, by_growth = {}, {}
    for s, d in enumerate(stats):
        by_exp.setdefault(d[2], []).append(s)
        for i in range(6):
            by_growth.setdefault(d[9 + i], []).append((s, i))

    rows, ids = [], []
    for t in range(32):
        rows.append([t] + ['{:,}'.format(exp[t][lv - 1]) for lv in MARK_LEVELS] +
                    [[species_cell(names, s) for s in by_exp.get(t, [])]])
        ids.append('c{}'.format(t))
    used = sorted(by_exp)
    out = [{'name': 'exp-tables', 'type': 'card', 'title': 'Experience curves', 'unit': 'ExpTables',
            'subtitle': '32 curves of 99 levels', 'summary': 'experience needed per level, and who uses each curve',
            'sections': [{'columns': ['Curve'] + ['Lv {}'.format(lv) for lv in MARK_LEVELS] + ['Species'],
                          'rows': rows, 'ids': ids, 'wide': True}],
            'doc': ['ExpTables: 32 curves of 99 levels, 3 bytes per level (24 bits, little endian): the experience '
                    'total at which a monster reaches that level. Byte 2 of the species record picks the curve '
                    '(GetExpForNextLevel, SetExpForLevel); the experience chart draws them all.'],
            'users': ['ExpTables', 'GetExpForNextLevel', 'SetExpForLevel']},
           {'name': 'exp-chart', 'type': 'chart', 'title': 'Experience curves (chart)', 'kind': 'line',
            'x': 'level', 'y': 'experience',
            'series': [{'name': 'curve {} ({} species)'.format(t, len(by_exp[t])),
                        'points': [[lv, exp[t][lv - 1]] for lv in range(1, 100, 2)] + [[99, exp[t][98]]]}
                       for t in used],
            'doc': ['The experience curves of ExpTables that species use, level against the experience total '
                    'needed (see exp-tables for the numbers and which species use each).'],
            'users': ['ExpTables', 'GetExpForNextLevel']}]

    rows, ids = [], []
    for c in range(32):
        cv = curves[c]
        users = by_growth.get(c, [])
        per_stat = ', '.join('{} {}'.format(GROWTH[i], sum(1 for _, k in users if k == i)) for i in range(6)
                             if any(k == i for _, k in users))
        rows.append([c] + [sum(cv[:lv]) for lv in MARK_LEVELS] + [max(cv), per_stat or '—'])
        ids.append('g{}'.format(c))
    out.append({'name': 'growth-curves', 'type': 'card', 'title': 'Stat growth curves', 'unit': 'StatGrowthTables',
                'subtitle': '32 curves of 99 levels', 'summary': 'what a stat gains by level, per curve',
                'sections': [{'title': 'Stat points gained in total by level',
                              'columns': ['Curve'] + ['Lv {}'.format(lv) for lv in MARK_LEVELS] +
                                         ['Largest step', 'Used for (number of species)'],
                              'rows': rows, 'ids': ids, 'wide': True}],
                'doc': ['StatGrowthTables: 32 curves of 99 bytes, the gain of a stat at each level-up '
                        '(GetStatGain). Bytes 9-14 of the species record pick one curve for each of HP, MP, attack, '
                        'defense, agility and intelligence. The table adds the gains up to the level shown; past '
                        'its level limit a monster gains gain x level / 100 + 1 instead, and from level 14 on a '
                        'high plus value adds bonuses (AddPlusBonuses).'],
                'users': ['StatGrowthTables', 'GetStatGain', 'RollLevelUpGains', 'AddPlusBonuses']})
    return out
