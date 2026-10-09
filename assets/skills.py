"""The skills: what each does in battle (its record from SkillPointers) and what a monster needs to learn it
(SkillTable)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, GROWTH, SPECIES, species_cell  # noqa: E402

GROUP = 'skills'
SKILLS = 256                  # capped by the number of names
KIND = {1: 'attack', 2: 'status', 3: 'support', 4: 'run / daze', 5: 'confused', 6: 'boss', 8: 'item'}
SIDE = {1: 'enemy', 2: 'own side', 3: 'either side', 4: 'self'}
WHERE = {1: 'field', 2: 'battle', 3: 'both'}


def skill_label(rom, a):
    return rom.label_at(a)


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    n = min(SKILLS, rom.table_length('SysText_SkillNames', 'SysText_MonsterInitials'),
            rom.table_length('SkillPointers', 'Skill_Blaze'))
    names = rom.texts('SysText_SkillNames', n)
    mnames = rom.texts('SysText_MonsterNames', SPECIES)
    resist, _ = rom.resist_names(names)
    born = {}
    for s in range(SPECIES):
        for k in rom.stats(s)[6:9]:
            born.setdefault(k, []).append(s)
    a = rom.lin('SkillTable')
    learnable = (rom.next_label(a) - a) // 18
    rows, ids = [], []
    for s in range(n):
        d = r[a + 18 * s: a + 18 * s + 18] if s < learnable else bytes([0] * 13 + [0xFF] * 5)
        mins = [d[1 + 2 * i] | d[2 + 2 * i] << 8 for i in range(6)]
        pre = [{'asset': 'skill-list@s{}'.format(k), 'text': names[k]} if k < n else '#{}'.format(k)
               for k in d[13:18] if k != 0xFF]
        try:
            rec, ra = rom.skill_record(s)
        except Exception:  # noqa: BLE001
            rec, ra = None, None
        lab = skill_label(rom, ra) if ra is not None else None
        name = {'text': names[s], 'code': lab} if lab else names[s]
        if rec is not None:
            amount = rec[11] | rec[12] << 8
            kind = KIND.get(rec[1] >> 4, rec[1] >> 4)
            target = '{} {}'.format(SIDE.get(rec[2] >> 4, rec[2] >> 4), 'all' if rec[2] & 0xF == 2 else 'one'
                                    if rec[2] & 0xF == 1 else '')
            res = resist[rec[5] - 1] if 1 <= rec[5] <= 27 else ''
            extra = [kind, target.strip(), rec[4], 'all' if amount == 999 else amount or '',
                     WHERE.get(rec[10], ''), res]
        else:
            extra = [''] * 6
        whoborn = [species_cell(mnames, m) for m in born.get(s, [])]
        rows.append([s, name] + extra + [d[0] or ''] + [v or '' for v in mins] + [pre, whoborn])
        ids.append('s{}'.format(s))
    return [{'name': 'skill-list', 'type': 'card', 'title': 'Skills', 'unit': 'SkillTable',
             'subtitle': '{} skills and battle actions'.format(n),
             'summary': '{} skills: kind, targets, MP, amount, resistance, what it takes to learn'.format(n),
             'sections': [{'columns': ['No.', 'Name', 'Kind', 'Targets', 'MP', 'Amount', 'Use', 'Resisted by',
                                       'Level'] + ['Min ' + g for g in GROWTH] + ['Needs skills', 'Born with it'],
                           'rows': rows, 'ids': ids, 'wide': True}],
             'doc': ['Every skill. The first columns come from its battle record (SkillPointers, 19 bytes: kind, '
                     'targets, MP cost, the base amount when a monster of your side uses it, where it can be '
                     'used, and the resistance it is met with; a name opens the record). The rest is what a '
                     'monster needs to learn it (SkillTable, 18 bytes each): the level (it is learned from one '
                     'level before), the lowest max HP, max MP, attack, defense, agility and intelligence, and up '
                     'to five skills it must already know. A skill with such prerequisites can be learned by any '
                     'monster that knows all of them; the others only from the monster\'s own list (see '
                     'FindLearnableSkill). "Born with it" lists the species that start with the skill. Entries '
                     '151-212 are not skills a monster learns but battle actions sharing the numbering: running, '
                     'personality quirks (Daze, Trip, HitAlly...), boss moves and the items used in battle, '
                     'some still with their capitalised working names.'],
             'users': ['SkillTable', 'SkillPointers', 'FindLearnableSkill', 'SysText_SkillNames']}]
