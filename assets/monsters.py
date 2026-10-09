"""The monsters: every species' picture in its own colours, its record from MonsterStats, the breeding
tables, and a card per species with everything the ROM says about it."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _game import image  # noqa: E402,F401  (kept for the other plugins)
from _dwm import (Rom, SPECIES, FAMILIES, GROWTH, GROWTH_LONG, FEMALE, card, packed_image,  # noqa: E402,F401
                  species_cell)

GROUP = 'monsters'
RESIST_LEVEL = ['none', 'some', 'strong', 'immune']


def skill_cell(skills, k):
    if k < len(skills):
        return {'asset': 'skill-list@s{}'.format(k), 'text': skills[k]}
    return '#{}'.format(k)


def family_text(v):
    if v < len(FAMILIES):
        return FAMILIES[v]
    return str(v)


def build_assets(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    names = rom.texts('SysText_MonsterNames', SPECIES)
    nskills = rom.table_length('SysText_SkillNames', 'SysText_MonsterInitials')
    skills = rom.texts('SysText_SkillNames', nskills)
    stats = [rom.stats(s) for s in range(SPECIES)]
    pics = [rom.picture(s) for s in range(SPECIES)]
    pals = [rom.palette(s) for s in range(SPECIES)]
    small = [packed_image(pics[s][0], pals[s], scale=1) for s in range(SPECIES)]

    def mon(s):
        return species_cell(names, s)

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
                          'text': '#{} {} ({} family)'.format(s, names[s], family_text(stats[s][0])),
                          'link': card(s), 'linkText': 'card'})
        out.append(packed_image(pix, colors, scale=2, name='monster-gallery-{}'.format(part + 1),
                                title='Monster pictures {}-{}'.format(lo, hi - 1), marks=marks,
                                doc=['The monsters\' big pictures, in the order of their species numbers, each in '
                                     'its own four colours. A picture is 6 x 6 tiles, packed in the game\'s '
                                     'compression format (see DecompressCore); MonsterPicRefs gives the bank and '
                                     'entry of each, MonPicPalettes the colours. Click a picture for its card.'],
                                users=['LoadMonsterPicture', 'DecompressCore', 'LoadMonPicPalette', 'MonsterPicRefs',
                                       'MonPicPalettes']))

    # the list: one row per species
    rowsout = []
    for s in range(SPECIES):
        d = stats[s]
        rowsout.append([{'image': small[s]}, s, mon(s), family_text(d[0]), d[1],
                        [skill_cell(skills, k) for k in d[6:9]]] + list(d[9:15]))
    out.append({'name': 'monster-list', 'type': 'table', 'title': 'Monster list', 'unit': 'MonsterStats',
                'columns': ['', 'No.', 'Name', 'Family', 'Max level', 'Skills at birth'] +
                           ['{} curve'.format(g) for g in GROWTH],
                'rows': rowsout,
                'doc': ['Every species with its record from MonsterStats (43 bytes each): the family, the highest '
                        'level it can reach, the three skills it is born with, and the growth curve of each of its '
                        'six stats (a curve of StatGrowthTables: what the stat gains at each level-up). A name '
                        'opens the species\' card with the rest of the record. The names come from the game\'s '
                        'own name list (SysText_MonsterNames), the skill names from SysText_SkillNames. Species '
                        '217-220 have no record and no picture.'],
                'users': ['CopyMonsterStats', 'MonsterStats', 'SysText_MonsterNames', 'SysText_SkillNames']})
    br = breeding(ctx, rom, names, small)
    out += br['assets']
    out += cards(ctx, rom, names, skills, stats, pics, pals, br)
    return out


def who_cell(names, v):
    if v < SPECIES:
        return species_cell(names, v)
    if 0xF0 <= v < 0xF0 + len(FAMILIES):
        return 'any {}'.format(FAMILIES[v - 0xF0])
    if v == 0xFA:
        return 'any monster'
    return '${:02X}'.format(v)


def breeding(ctx, rom, names, small):
    """The breeding chart from BreedPairTable and SpecialPairTable."""
    r = ctx.rom
    a = rom.lin('BreedPairTable')
    rows, nopair, pairs = [], [], []
    for s in range(SPECIES):
        p, m = r[a + 2 * s], r[a + 2 * s + 1]
        if (p, m) == (0, 0):
            break
        if (p, m) == (0xFF, 0xFF):
            nopair.append(names[s])
            continue
        pairs.append((s, p, m))
        rows.append([{'image': small[s]}, species_cell(names, s), who_cell(names, p), who_cell(names, m)])
    out = [{'name': 'breeding-chart', 'type': 'table', 'title': 'Breeding chart', 'unit': 'BreedPairTable',
            'columns': ['', 'Offspring', 'Pedigree', 'Mate'], 'rows': rows,
            'doc': ['What two monsters breed: BreedPairTable has one entry per offspring species, the pedigree and '
                    'the mate it needs. A parent can be a species or "any monster of a family"; the family of the '
                    'pedigree decides the offspring when no exact pair fits (BreedResult looks for an exact pair '
                    'first). The pairs of breeding-special are checked before this chart. {} species have no '
                    'pair at all: {}.'.format(len(nopair), ', '.join(nopair))],
            'users': ['BreedPairTable', 'MakeOffspring', 'BreedResult']}]
    a = rom.lin('SpecialPairTable')
    rows, special = [], []
    while r[a] != 0xFF and len(rows) < 1000:
        p, m, plus, child, bonus = r[a:a + 5]
        special.append((child, p, m, plus, bonus))
        rows.append([who_cell(names, child), who_cell(names, p), who_cell(names, m),
                     '+{}'.format(plus) if plus else '', '+{}'.format(bonus) if bonus else ''])
        a += 5
    out.append({'name': 'breeding-special', 'type': 'table', 'title': 'Special pairs', 'unit': 'SpecialPairTable',
                'columns': ['Offspring', 'Pedigree', 'Mate', 'Lowest plus', 'Plus bonus'], 'rows': rows,
                'doc': ['The pairs checked before the breeding-chart (SpecialPairTable, 5 bytes each: pedigree, '
                        'mate, lowest plus, offspring, plus bonus). CheckSpecialPair goes through them in order and '
                        'the first that fits wins; a few only work once the parents\' plus value reaches a minimum, '
                        'which is how two Slimes of +5 or more make a KingSlime.'],
                'users': ['SpecialPairTable', 'MakeOffspring', 'CheckSpecialPair']})
    return {'assets': out, 'pairs': pairs, 'special': special}


def wild_places(rom, names):
    """species -> [(world, first floor, last floor, level, percent)] from the gate floor tables (the floor
    tables hold monster numbers; their template gives the species and level)."""
    out = {}
    for g, (nfloors, parts, _w) in enumerate(rom.floor_worlds()):
        for lo, hi, e in parts:
            ft = rom.floor_table(e)
            tot = sum(w for n, w, _ in ft['mons'] if w and n)
            for n, w, alone in ft['mons']:
                if not w or not tot:
                    continue
                t = rom.template(n)
                out.setdefault(t['species'], []).append((g, lo, hi, t['level'], round(100 * w / tot), alone, e))
    return out


def cards(ctx, rom, names, skills, stats, pics, pals, br):
    resist, groups = rom.resist_names(skills)
    exp = [rom.exp_table(t) for t in range(32)]
    curves = [rom.growth_curve(c) for c in range(32)]
    wild = wild_places(rom, names)
    try:
        import sprites
        walk = sprites.walkers(ctx)
    except Exception:  # noqa: BLE001
        walk = {}
    totals = [[sum(curves[d[9 + i]][:max(1, d[1])]) for i in range(6)] for d in stats]
    top = [max(t[i] for t in totals) for i in range(6)]
    born = {}
    for s, d in enumerate(stats):
        for k in d[6:9]:
            born.setdefault(k, []).append(s)
    # who breeds what
    bred_from, parent_of, family_parent = {}, {}, {}
    for child, p, m in br['pairs']:
        bred_from.setdefault(child, []).append((p, m, ''))
        for v, other, role in ((p, m, 'pedigree'), (m, p, 'mate')):
            if v < SPECIES:
                parent_of.setdefault(v, []).append((child, role, other, ''))
            elif 0xF0 <= v < 0xF0 + len(FAMILIES):
                family_parent.setdefault((v - 0xF0, role), []).append(child)
    for child, p, m, plus, bonus in br['special']:
        note = 'special pair' + (', plus {} or more'.format(plus) if plus else '')
        bred_from.setdefault(child, []).append((p, m, note))
        for v, other, role in ((p, m, 'pedigree'), (m, p, 'mate')):
            if v < SPECIES:
                parent_of.setdefault(v, []).append((child, role, other, note))
    out = []
    for s in range(SPECIES):
        d = stats[s]
        fam = d[0]
        maxlv = d[1]
        e = exp[d[2]]
        img = packed_image(pics[s][0], pals[s], scale=3)
        lv_rows = [[lv, '{:,}'.format(e[lv - 1])] for lv in (5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99) if lv <= maxlv]
        if maxlv not in (5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99) and 1 <= maxlv <= 99:
            lv_rows.append([maxlv, '{:,}'.format(e[maxlv - 1])])
        lv_rows.sort()
        from_rows = [[who_cell(names, p), who_cell(names, m), note] for p, m, note in bred_from.get(s, [])]
        par_rows = [[species_cell(names, c), role, who_cell(names, o), note] for c, role, o, note in parent_of.get(s, [])]
        fam_chips = []
        for role in ('pedigree', 'mate'):
            kids = family_parent.get((fam, role), [])
            if kids and fam < len(FAMILIES):
                fam_chips.append('as any {} ({}):'.format(FAMILIES[fam], role))
                fam_chips += [species_cell(names, c) for c in kids]
        wild_rows = [['world {}'.format(g), '{}-{}'.format(lo, hi) if hi > lo else str(lo), lv, '{}%{}'.format(p, ', alone' if alone else ''),
                      {'asset': 'gate-worlds@w{}'.format(g), 'text': 'table {}'.format(e_)}]
                     for g, lo, hi, lv, p, alone, e_ in wild.get(s, [])]
        sections = [
            {'title': 'Record', 'fields': [
                ['number', '#{} (MonsterStats record {})'.format(s, s)],
                ['family', family_text(fam)],
                ['max level', maxlv],
                ['sex', FEMALE[d[3]] if d[3] < len(FEMALE) else d[3]],
                ['experience', {'asset': 'exp-tables@c{}'.format(d[2]), 'text': 'curve {}'.format(d[2])}],
                ['skills at birth', [skill_cell(skills, k) for k in d[6:9]]],
                ['growth curves', [{'asset': 'growth-curves@g{}'.format(d[9 + i]),
                                    'text': '{} {}'.format(GROWTH[i], d[9 + i])} for i in range(6)]],
            ] + ([['walking sprite', {'asset': 'monster-sprites', 'text': 'all frames'}]] if s in walk else [])},
            {'title': 'Growth (stat points gained up to level {})'.format(maxlv),
             'bars': [['{} (curve {})'.format(GROWTH_LONG[i], d[9 + i]), totals[s][i], top[i]] for i in range(6)]},
            {'title': 'Experience needed', 'columns': ['level', 'experience'], 'rows': lv_rows},
            {'title': 'Resistances (0 none - 3 immune)',
             'bars': [[resist[i], d[15 + i], 3] for i in range(27)]},
            {'title': 'Bred from', 'columns': ['pedigree', 'mate', ''], 'rows': from_rows,
             'empty': 'no pair of its own: only bred through a family rule, or not at all'},
            {'title': 'Parent of', 'columns': ['offspring', 'as', 'with', ''], 'rows': par_rows,
             'empty': 'not named in any pair'},
        ]
        if fam_chips:
            sections.append({'title': 'Through its family', 'chips': fam_chips, 'wide': True})
        sections.append({'title': 'Met in the gates', 'columns': ['gate', 'floors', 'level', 'chance', 'floor table'],
                         'rows': wild_rows, 'empty': 'not met as a wild monster'})
        out.append({'name': card(s), 'type': 'card', 'group': 'monsters',
                    'title': '#{} {}'.format(s, names[s]), 'subtitle': '{} family'.format(family_text(fam)),
                    'summary': '{} family, up to level {}'.format(family_text(fam), maxlv),
                    'images': [img] + ([walk[s]] if s in walk else []), 'sections': sections,
                    'doc': ['{}: record {} of MonsterStats (43 bytes: +0 family, +1 max level, +2 experience '
                            'curve, +3 sex class, +6..+8 skills at birth, +9..+14 growth curves, +15..+41 '
                            'resistances), picture {:02X}:{:02X} (MonsterPicRefs), colours from MonPicPalettes. '
                            'Growth bars add up the curve\'s gains (StatGrowthTables) from level 1 to the max '
                            'level, before the plus bonuses; the bar is full for the species with the most. '
                            'Resistance names follow the skills that are checked against them (skill record '
                            '+5).'.format(names[s], s, pics[s][1] >> 8, pics[s][1] & 0xFF)],
                    'users': ['CopyMonsterStats', 'LoadMonsterPicture', 'GetExpForNextLevel', 'GetStatGain',
                              'BreedResult', 'SelectFloorTable']})
    return out


def build(ctx):  # noqa: F811 - the plugin entry point
    return build_assets(ctx)
