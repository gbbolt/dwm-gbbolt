"""The monster numbers: the templates every monster the game creates is built from (wild monsters, the
Starry Night tournament teams, bosses, gifts), and the tournament teams themselves."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, SPECIES, species_cell  # noqa: E402

GROUP = 'monsters'
ITEMS = 44
CLASSES = ['G', 'F', 'E', 'D', 'C', 'B', 'A', 'S', '8', 'final']


def arena_team(c, rnd):
    if c == 9:
        return [0x1E1, 0x1E2, 0x1E3]
    b = 0xE0 + 3 * (3 * c + rnd)
    return [b, b + 1, b + 2]


def ranges(rom, label):
    """(below level, base, count) for each `ld hl, base << 8 | count` / `cp level` of a level-range routine."""
    r = rom.r
    a = rom.lin(label)
    out = []
    for p in range(a, a + 120):
        if r[p] == 0x21:
            hl = rom.word(p + 1)
            if r[p + 3] == 0xFE:
                out.append((r[p + 4], hl >> 8, hl & 0xFF))
            elif r[p + 3] in (0x18, 0xC3):            # the last range: jr / jp to the picker
                out.append((None, hl >> 8, hl & 0xFF))
                break
    return out


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    names = rom.texts('SysText_MonsterNames', SPECIES)
    nsk = rom.table_length('SysText_SkillNames', 'SysText_MonsterInitials')
    skills = rom.texts('SysText_SkillNames', nsk)
    n_items = min(ITEMS, rom.table_length('SysText_ItemNames', 'SysText_ItemDescriptions'))
    items = rom.texts('SysText_ItemNames', n_items)
    count = rom.templates_count()
    tpl = [rom.template(n) for n in range(count)]

    def num_cell(n):
        return {'asset': 'monster-numbers@n{}'.format(n), 'text': '${:03X}'.format(n)}

    def mon_text(n):
        t = tpl[n]
        return [species_cell(names, t['species']), 'Lv {}'.format(t['level'])]

    # what each number is used for
    use = {}
    for g, (_, parts, _) in enumerate(rom.floor_worlds()):
        for lo, hi, e in parts:
            for n, wt, _ in rom.floor_table(e)['mons']:
                if wt and n:
                    use.setdefault(n, set()).add('gate world {}'.format(g))
    for c in range(10):
        for rnd in range(3):
            for n in arena_team(c, rnd):
                use.setdefault(n, set()).add('tournament class {}'.format(CLASSES[c]))
    ea = rom.lin('EventBossBattles')
    for i in range(9):
        use.setdefault(rom.word(ea + 2 * i), set()).add('event battle {}'.format(i))
    tranges = ranges(rom, 'RollTournamentTeam')
    for _, base, cnt in tranges:
        for n in range(base, base + cnt):
            use.setdefault(n, set()).add('random tournament team')

    rows, ids = [], []
    for n in range(1, count):
        t = tpl[n]
        if t['species'] == 0 and t['level'] == 0:
            continue
        rows.append(['${:03X}'.format(n), species_cell(names, t['species']), t['level']] + t['stats'] +
                    [[{'asset': 'skill-list@s{}'.format(k), 'text': skills[k]} if k < nsk else '#{}'.format(k)
                      for k in t['skills']], ', '.join(sorted(use.get(n, ())))])
        ids.append('n{}'.format(n))
    out = [{'name': 'monster-numbers', 'type': 'card', 'title': 'Monster numbers', 'unit': 'MonTemplates',
            'subtitle': '{} templates'.format(len(rows)),
            'summary': 'the templates wild monsters, tournament teams and bosses are made from',
            'sections': [{'columns': ['No.', 'Species', 'Level', 'HP', 'MP', 'Atk', 'Def', 'Agl', 'Int', 'Skills',
                                      'Used by'], 'rows': rows, 'ids': ids, 'wide': True}],
            'doc': ['Every monster the game creates outside breeding is built by CreateMonster from a template of '
                    'MonTemplates, 25 bytes per monster number: +0 the species, +4 the level, +5..+16 max HP, max '
                    'MP, attack, defense, agility and intelligence (16 bits each), +17..+20 four more byte stats, '
                    '+21..+24 the skills it knows. CreateMonster lowers most stats at random to 80-100 %. The gate '
                    'floors (FloorTables), the Starry Night tournament and the event bosses all name monsters by '
                    'these numbers; "Used by" lists the places found in those tables. Empty templates are left '
                    'out.'],
            'users': ['CreateMonster', 'LoadMonTemplateTo', 'MonTemplates']}]

    # ---- the tournament
    gfx = rom.lin('ArenaOpponentGfx')
    rows = []
    for c in range(10):
        for rnd in range(3):
            team = arena_team(c, rnd)
            rows.append([CLASSES[c], rnd + 1] + [[num_cell(n)] + mon_text(n) for n in team] +
                        [rom.word(gfx + 2 * (3 * c + rnd))])
    trows = []
    lo = 1
    for below, base, cnt in tranges:
        trows.append(['{}-{}'.format(lo, below - 1) if below else '{}+'.format(lo),
                      ['{}..{}'.format(num_cell(base)['text'], num_cell(base + cnt - 1)['text'])] +
                      [species_cell(names, tpl[n]['species']) for n in range(base, base + cnt) if n < count]])
        lo = below or lo
    pa, pl = rom.lin('TournamentPrizes'), rom.lin('TournamentPrizesLate')

    def prize_chips(a):
        seen = []
        for i in r[a:a + 16]:
            if i not in seen:
                seen.append(i)
        return [{'asset': 'item-list@i{}'.format(i), 'text': items[i]} if 0 < i < len(items) else '#{}'.format(i)
                for i in seen]
    out.append({'name': 'arena-teams', 'type': 'card', 'title': 'Starry Night tournament', 'unit': 'ArenaOpponentGfx',
                'subtitle': '10 classes of 3 rounds', 'summary': 'the teams of every class and round, and the prizes',
                'sections': [
                    {'title': 'Fixed teams', 'columns': ['Class', 'Round', 'First', 'Second', 'Third', 'Opponent sprite'],
                     'rows': rows, 'wide': True},
                    {'title': 'Random teams by the party\'s best level (RollTournamentTeam)',
                     'columns': ['Best level', 'Monster numbers'], 'rows': trows, 'wide': True},
                    {'title': 'Prizes, classes 1-8 (TournamentPrizes)', 'chips': prize_chips(pa)},
                    {'title': 'Prizes from class 9 on (TournamentPrizesLate)', 'chips': prize_chips(pl)},
                ],
                'doc': ['The fixed teams: ScriptCmdSetupArenaBattle takes monster numbers $E0 + 3 x (3 x class + '
                        'round) and the two after it; class 9, the final, always uses $1E1-$1E3. The opponent\'s '
                        'sprite comes from ArenaOpponentGfx. Classes 0-7 are the letter classes G to S the texts '
                        'speak of. The random teams: ScriptCmdSetupTournament rolls three teams of three from a '
                        'range of monster numbers chosen by the strongest party monster\'s level, and the prize '
                        'from one of the two prize lists (16 entries, one drawn at random).'],
                'users': ['ScriptCmdSetupArenaBattle', 'ArenaOpponentGfx', 'ScriptCmdSetupTournament',
                          'RollTournamentTeam', 'TournamentPrizes', 'TournamentPrizesLate']})
    return out
