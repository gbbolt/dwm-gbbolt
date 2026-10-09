"""The Game Boy Color palettes of bank $17: field sprites, the text box, the maps, the gate floors and the
full palette sets."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom  # noqa: E402

GROUP = 'gfx'
SWATCH = 'AAECAw=='                     # a 4 x 1 picture of the colours 0, 1, 2, 3


def build(ctx):
    rom = Rom(ctx)
    bank17 = 0x17 * 0x4000 - 0x4000

    def colors(a):
        return [rom.color(rom.word(a + 2 * i)) for i in range(4)]

    def swatch(a):
        return {'image': {'type': 'image', 'width': 4, 'height': 1, 'pixels': SWATCH, 'scale': 8,
                          'fixedColors': True, 'colors': colors(a)}}

    def addr(a):
        return '${:04X}'.format(a - bank17)

    sections = []
    a = rom.lin('FieldObjPalettes')
    sections.append({'title': 'Field sprites (FieldObjPalettes)', 'columns': ['Palette', 'Colours'],
                     'rows': [[i, swatch(a + 8 * i)] for i in range(8)]})
    a = rom.lin('FieldBGPalette7')
    sections.append({'title': 'Text box (FieldBGPalette7)', 'columns': ['Palette', 'Colours'], 'rows': [[7, swatch(a)]]})
    g = rom.lin('GatePaletteTable')
    rows = []
    for m in range(16):
        p = bank17 + rom.word(g + 2 * m)
        rows.append([m, addr(p)] + [swatch(p + 8 * i) for i in range(4)])
    sections.append({'title': 'Gate floors by floor map (GatePaletteTable)',
                     'columns': ['Map', 'Address', 'Palette 0', '1', '2', '3'], 'rows': rows, 'wide': True})
    # the map palette groups between FieldBGPalette7 and MonPicPalettes, as MapPaletteTable's records name them
    start, end = rom.lin('FieldBGPalette7') + 8, rom.lin('MonPicPalettes')
    mt, mend = rom.lin('MapPaletteTable'), rom.lin('GatePaletteTable')
    refs = {}
    for p in range(mt, mend - 1):
        w = rom.word(p)
        if start - bank17 <= w < end - bank17 and (w - (start - bank17)) % 32 == 0:
            refs[w] = refs.get(w, 0) + 1
    gate = {rom.word(g + 2 * m) for m in range(16)}
    rows = []
    for p in range(start, end - 31, 32):
        if p - bank17 in gate and not refs.get(p - bank17):
            continue
        rows.append([addr(p), refs.get(p - bank17, 0)] + [swatch(p + 8 * i) for i in range(4)])
    sections.append({'title': 'Map palettes (groups of four that MapPaletteTable\'s screen records point to)',
                     'columns': ['Address', 'Records', 'Palette 0', '1', '2', '3'], 'rows': rows, 'wide': True})
    a = rom.lin('PaletteSets')
    n = (rom.next_label(a) - a) // 64
    sections.append({'title': 'Full palette sets (PaletteSets)', 'columns': ['Set'] + [str(i) for i in range(8)],
                     'rows': [[k] + [swatch(a + 64 * k + 8 * i) for i in range(8)] for k in range(n)], 'wide': True})
    for lab in ('ObjPaletteSetsA', 'ObjPaletteSetsB'):
        a = rom.lin(lab)
        n = min(32, (rom.next_label(a) - a) // 8)
        sections.append({'title': 'Sprite palette 0 by set ({})'.format(lab), 'columns': ['Set', 'Colours'],
                         'rows': [[k, swatch(a + 8 * k)] for k in range(n)]})
    return [{'name': 'palettes', 'type': 'card', 'title': 'Colour palettes', 'unit': 'MapPaletteTable',
             'subtitle': 'bank $17', 'summary': 'the Game Boy Color palettes of the field, maps, gates and scenes',
             'sections': sections,
             'doc': ['The Game Boy Color palettes of bank $17, four colours each (15-bit RGB, colour 0 first). '
                     'LoadFieldObjPalettes loads the eight sprite palettes of the field; SetSharedBGColors the text '
                     'box palette 7 and its colours 1 and 3 into every other palette; LoadMapPalettes background '
                     'palettes 0-3 of a map screen - on the gate floors from GatePaletteTable by the floor map, '
                     'elsewhere from the group of four a MapPaletteTable screen record points to (picked by a '
                     'story byte, so a place can change colour as the story goes on). LoadPaletteSet loads a whole '
                     'set of eight for the scenes, LoadObjPaletteA/B one sprite palette. The monster pictures\' '
                     'palettes (MonPicPalettes) are shown with the monsters.'],
             'users': ['LoadMapPalettes', 'LoadFieldObjPalettes', 'SetSharedBGColors', 'LoadPaletteSet',
                       'LoadObjPaletteA', 'LoadObjPaletteB']}]
