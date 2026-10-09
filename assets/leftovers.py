"""Leftovers of an earlier program in banks $61 and $62: two run-length packed window maps and a 1-bit font."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, packed_image  # noqa: E402

GROUP = 'gfx'
GREY = ['#000000', '#ffffff']


def unrle(r, a, limit=0x1000):
    """n < $80: the next byte n times; $80 + n: n bytes as they are; 0 ends."""
    out = bytearray()
    while r[a] and len(out) < limit:
        n = r[a]
        if n < 0x80:
            out += bytes([r[a + 1]]) * n
            a += 2
        else:
            out += r[a + 1:a + 1 + n - 0x80]
            a += 1 + n - 0x80
    return bytes(out)


def glyphs1(font, count, cols):
    rows = (count + cols - 1) // cols
    img = [bytearray(cols * 8) for _ in range(rows * 8)]
    for t in range(count):
        for y in range(8):
            b = font[8 * t + y]
            for x in range(8):
                img[(t // cols) * 8 + y][(t % cols) * 8 + x] = b >> (7 - x) & 1
    return img


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    font = unrle(r, rom.lin('LeftoverFontRLE_61'))
    count = len(font) // 8
    out = [packed_image(glyphs1(font, count, 16), GREY, scale=3, name='leftover-font', title='Leftover 1-bit font',
                        unit='LeftoverFontRLE_61', subtitle='{} characters'.format(count),
                        doc=['A 1-bit font (8 bytes a character) packed with a run-length code: a byte n below $80 '
                             'repeats the next byte n times, $80 + n copies the next n bytes, 0 ends. It is left over '
                             'from an earlier program; nothing in Dragon Warrior Monsters reads it.'],
                        users=['LeftoverFontRLE_61', 'LeftoverShowScreen_61'])]
    for b in (0x61, 0x62):
        lab = 'LeftoverScreenRLE_{:02X}'.format(b)
        m = unrle(r, rom.lin(lab), 0x400).ljust(0x400, b'\0')
        img = [bytearray(256) for _ in range(256)]
        for ty in range(32):
            for tx in range(32):
                t = m[ty * 32 + tx]
                for y in range(8):
                    g = font[8 * t + y] if 8 * t + 8 <= len(font) else 0
                    for x in range(8):
                        img[ty * 8 + y][tx * 8 + x] = g >> (7 - x) & 1
        out.append(packed_image(img, GREY, scale=2, name='leftover-screen-{:02x}'.format(b),
                                title='Leftover window map ${:02X}'.format(b), unit=lab, subtitle='32 x 32 tiles',
                                doc=['A 32 x 32-tile background map from an earlier program, packed with the same '
                                     'run-length code; LeftoverShowScreen_{:02X} would have drawn it, but nothing '
                                     'calls that. Drawn here with the leftover 1-bit font as its tiles (tile n = '
                                     'character n), which is a guess: the program\'s own tiles are not in the '
                                     'ROM.'.format(b)],
                                users=[lab, 'LeftoverShowScreen_{:02X}'.format(b)]))
    return out
