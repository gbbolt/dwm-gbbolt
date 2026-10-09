"""The interface tiles of bank $2E: window letters, family icons, gate floor objects, fonts and name-entry keys,
each block unpacked and drawn as a tile sheet."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, packed_image  # noqa: E402

GROUP = 'gfx'
GREY = ['#ffffff', '#a8a8a8', '#585858', '#000000']
BANK = 0x2E


def build(ctx):
    rom = Rom(ctx)
    o = BANK * 0x4000
    first = rom.far_entry(BANK, 0)
    n = (first - o - 1) // 2
    out, icons = [], []
    for e in range(n):
        a = rom.far_entry(BANK, e)
        lab = rom.label_at(a)
        if not lab or lab.startswith('SGBBorder') or lab.startswith('Unused_'):
            continue                                 # the border halves are drawn with the borders
        try:
            data = rom.decompress(a)
        except Exception:  # noqa: BLE001
            continue
        count = len(data) // 16
        if not count:
            continue
        if lab.startswith('FamilyIcon_'):
            icons.append((lab, data))
            continue
        cols = min(16, count)
        img = rom.tiles(data, count, cols)
        out.append(packed_image(img, GREY, scale=3, name='ui-' + lab, title=lab, unit=lab,
                                subtitle='{} tiles, entry {:02X}:{:02X}'.format(count, BANK, e),
                                doc=['{}: {} tiles of 8 x 8, 2 bits per pixel, unpacked from entry {:02X}:{:02X} '
                                     '(DecompressCore format) - see the block\'s description in the disassembly for '
                                     'who loads it where. Drawn in plain grey shades; the game colours them with '
                                     'the palette of the screen they appear on.'.format(lab, count, BANK, e)],
                                users=[lab, 'DecompressVRAM']))
    if icons:
        img = rom.tiles(b''.join(d[:16] for _, d in icons), len(icons), len(icons))
        marks = [{'x': 8 * i, 'y': 0, 'w': 8, 'h': 8, 'label': lab[len('FamilyIcon_'):], 'text': lab}
                 for i, (lab, _) in enumerate(icons)]
        out.append(packed_image(img, GREY, scale=6, name='ui-family-icons', title='Family icons',
                                unit=icons[0][0], marks=marks,
                                doc=['The ten family icons (one tile each), in the order of the families: '
                                     + ', '.join(l[len('FamilyIcon_'):] for l, _ in icons) +
                                     '. Read through FamilyIconRefs.'],
                                users=[l for l, _ in icons] + ['FamilyIconRefs']))
    return out
