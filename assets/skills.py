"""The skills: what a monster needs to learn each one (SkillTable)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from monsters import Rom, GROWTH  # noqa: E402

GROUP = 'skills'
SKILLS = 218


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    n = min(SKILLS, rom.table_length('SysText_SkillNames', 'SysText_MonsterInitials'))
    names = rom.texts('SysText_SkillNames', n)
    a = rom.lin('SkillTable')
    rows = []
    for s in range(n):
        d = r[a + 18 * s: a + 18 * s + 18]
        mins = [d[1 + 2 * i] | d[2 + 2 * i] << 8 for i in range(6)]
        pre = [names[k] if k < n else '#{}'.format(k) for k in d[13:18] if k != 0xFF]
        rows.append([s, names[s], d[0]] + [v or '' for v in mins] + [', '.join(pre)])
    return [{'name': 'skill-list', 'type': 'table', 'title': 'Skills',
             'columns': ['No.', 'Name', 'Level'] + ['Min ' + g for g in GROWTH] + ['Needs skills'],
             'rows': rows,
             'doc': ['What a monster needs to learn each skill (SkillTable, 18 bytes each): the level (it is '
                     'learned from one level before), the lowest max HP, max MP, attack, defense, agility and '
                     'intelligence, and up to five skills it must already know. A skill with such prerequisites '
                     'can be learned by any monster that knows all of them; the others only from the monster\'s '
                     'own list (see FindLearnableSkill). The names are the game\'s own (system text group 6). Entries '
                     '151-212 are not skills a monster learns but battle actions sharing the numbering: running, '
                     'personality quirks (Daze, Trip, HitAlly...), boss moves and the items used in battle, '
                     'some still with their capitalised working names.'],
             'users': ['SkillTable', 'FindLearnableSkill', 'SysText_SkillNames']}]
