"""The character set of the texts: the 256 letters of the font in bank $4F, with what each code means."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, packed_image, char  # noqa: E402

GROUP = 'texts'
GREY = ['#ffffff', '#a8a8a8', '#585858', '#000000']
CONTROL = {0xE7: 'yes/no choice, "no" first', 0xE8: 'move the cursor (x, y follow)', 0xE9: 'play a sound (n follows)',
           0xEA: 'letter beep, voice $5B', 0xEB: 'letter beep, voice $5A', 0xEC: 'pause by the message speed',
           0xED: 'print the rest at once', 0xEE: 'clear the line', 0xEF: 'new line (scrolls)',
           0xF0: 'end of text', 0xF1: 'next line', 0xF2: 'clear the box', 0xF3: 'cursor to the top left',
           0xF4: 'normal speed', 0xF5: 'no letter delay', 0xF6: 'the player\'s name', 0xF7: 'wait for a button',
           0xF8: 'frames per letter (n follows)', 0xF9: 'insert a word (n follows)', 0xFA: 'blinking arrow',
           0xFB: 'wait n frames, a button cuts it short', 0xFC: 'pause n frames', 0xFD: 'letter beep on',
           0xFE: 'letter beep off', 0xFF: 'yes/no choice'}
for _c in range(0xE0, 0xE7):
    CONTROL[_c] = 'yes/no choice'


def build(ctx):
    rom = Rom(ctx)
    a = rom.lin('Font')
    data = ctx.rom[a: a + 0x1000]
    tiles = rom.tiles(data, 256, 16)
    # a grid with a 1-pixel gap so the letters stand apart
    img = [bytearray([0] * (16 * 9 + 1)) for _ in range(16 * 9 + 1)]
    marks = []
    for n in range(256):
        tx, ty = n % 16, n // 16
        for y in range(8):
            for x in range(8):
                img[1 + ty * 9 + y][1 + tx * 9 + x] = tiles[ty * 8 + y][tx * 8 + x]
        c = char(n)
        what = CONTROL.get(n) or ('family icon' if 0x10 <= n <= 0x19 else
                                  'accent on the letter before' if n in (0x8D, 0x8E) else
                                  '"{}"'.format(c) if c else 'no meaning in the decoder')
        marks.append({'x': 1 + tx * 9, 'y': 1 + ty * 9, 'w': 8, 'h': 8, 'label': '${:02X}'.format(n), 'text': what})
    return [packed_image(img, GREY, scale=3, name='charset', title='Character set',
                         subtitle='256 font letters, code by code', marks=marks,
                         doc=['The font the text printer draws with (Font in bank $4F, 16 bytes a letter), laid '
                              'out by character code: $00 top left, $0F top right, $F0 bottom left. Hover a letter '
                              'for its code and meaning. Codes $E0-$FF are control codes of the text format (see '
                              'TextGroup_1A_0), not printed; their tiles are whatever the font holds there. Among '
                              'the punctuation, $61 and $A4 are dots, $66-$71 an apostrophe joined with a letter '
                              '(\'l \'t \'s ...), $10-$19 the family icons.'],
                         users=['Font', 'TextPrinterStep', 'TextGroup_1A_0'])]
