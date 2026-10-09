"""The staff credits of the ending: each page's heading, names and monster."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, SPECIES, decode, packed_image, species_cell  # noqa: E402

GROUP = 'texts'
PAGES = 27


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    names = rom.texts('SysText_MonsterNames', SPECIES)
    heads = rom.lin('TextGroup_4C_5')
    body = rom.lin('TextGroup_4C_6')
    base = 0x4C * 0x4000 - 0x4000
    mons = rom.lin('CreditsMonsters')
    rows = []
    for p in range(PAGES):
        h = decode(r, base + rom.word(heads + 2 * p)).replace(' / ', ' ')
        n = decode(r, base + rom.word(body + 2 * p))
        s = r[mons + p]
        if s < SPECIES:
            img, _ = rom.picture(s)
            m = [{'image': packed_image(img, rom.palette(s))}, species_cell(names, s)]
        else:
            m = ''
        rows.append([p + 1, h, n.replace(' / ', ', '), m])
    return [{'name': 'credits', 'type': 'card', 'title': 'Staff credits', 'unit': 'CreditsMonsters',
             'subtitle': '{} pages'.format(PAGES), 'summary': 'the ending\'s staff credits, page by page',
             'sections': [{'columns': ['Page', 'Heading', 'Names', 'Monster'], 'rows': rows, 'wide': True}],
             'doc': ['The staff credits after the ending: every page shows a heading (text group 5 of bank $4C), '
                     'the names (group 6) and a monster picture (CreditsMonsters, one species per page) for 5 '
                     'seconds, then fades to the next (EndingCredits, PrintCreditsPage, LoadCreditsMonster). '
                     'Line breaks are shown as commas.'],
             'users': ['EndingCredits', 'PrintCreditsPage', 'LoadCreditsMonster', 'CreditsMonsters',
                       'TextGroup_4C_5', 'TextGroup_4C_6']}]
