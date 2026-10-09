"""The four Super Game Boy borders, drawn 256 x 224 the way the Super Game Boy shows them around the game."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, packed_image  # noqa: E402

GROUP = 'gfx'
# LoadSGBBorder: (bank, entry) of the two tile halves (CHR_TRN $10 / $11) and the map + colours (PCT_TRN)
BORDERS = [((0x08, 0x05), (0x08, 0x06), (0x08, 0x07)), ((0x08, 0x08), (0x2C, 0x00), (0x08, 0x09)),
           ((0x2C, 0x01), (0x32, 0x11), (0x32, 0x12)), ((0x2E, 0x24), (0x2E, 0x25), (0x32, 0x13))]


def snes_color(w):
    return '#%02x%02x%02x' % ((w & 31) * 255 // 31, (w >> 5 & 31) * 255 // 31, (w >> 10 & 31) * 255 // 31)


def build(ctx):
    rom = Rom(ctx)
    r = ctx.rom
    out = []
    for n, (a, b, pct) in enumerate(BORDERS):
        pa, pb = rom.far_entry(*a), rom.far_entry(*b)
        chr_ = r[pa:pa + 0x1000] + r[pb:pb + 0x1000]
        pp = rom.far_entry(*pct)
        p = rom.decompress(pp)
        colors = []
        for k in range(4):                           # palettes 4-7, 16 colours each
            colors += [snes_color(p[0x800 + 32 * k + 2 * i] | p[0x801 + 32 * k + 2 * i] << 8) for i in range(16)]
        img = [bytearray([255] * 256) for _ in range(224)]
        for ty in range(28):
            for tx in range(32):
                e = p[2 * (ty * 32 + tx)] | p[2 * (ty * 32 + tx) + 1] << 8
                t, pal = e & 0xFF, (e >> 10) & 7
                xf, yf = e & 0x4000, e & 0x8000
                base = 32 * t
                for y in range(8):
                    sy = 7 - y if yf else y
                    b0, b1 = chr_[base + 2 * sy], chr_[base + 2 * sy + 1]
                    b2, b3 = chr_[base + 16 + 2 * sy], chr_[base + 17 + 2 * sy]
                    row = img[ty * 8 + y]
                    for x in range(8):
                        sh = x if xf else 7 - x
                        c = (b0 >> sh & 1) | (b1 >> sh & 1) << 1 | (b2 >> sh & 1) << 2 | (b3 >> sh & 1) << 3
                        if c:
                            row[tx * 8 + x] = 16 * ((pal - 4) & 3) + c
        labels = [rom.label_at(x) for x in (pa, pb, pp)]
        unit = labels[0] or labels[2]
        a_ = packed_image(img, colors, scale=2, name='sgb-border-{}'.format(n), title='Super Game Boy border {}'.format(n),
                          subtitle='256 x 224',
                          doc=['Super Game Boy border {} as LoadSGBBorder sends it: two halves of $1000 bytes of '
                               '4-bit SNES tiles (CHR_TRN, {:02X}:{:02X} and {:02X}:{:02X}, uncompressed) and the '
                               'compressed border map with its colours (PCT_TRN, {:02X}:{:02X}): 32 x 28 tile entries '
                               '(tile, palette 4-7, flips), then the 16 colours of palettes 4-7. The empty middle '
                               'is where the Game Boy screen shows.'.format(n, a[0], a[1], b[0], b[1], pct[0], pct[1])],
                          users=['LoadSGBBorder', 'SGBTransfer', 'SGBTransferCompressed'] + [x for x in labels if x])
        if unit:
            a_['unit'] = unit
        out.append(a_)
    return out
