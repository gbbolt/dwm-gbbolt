"""The maps: every fixed map (the town, the Great Tree's rooms, the worlds' fixed places) drawn screen by
screen from its tile set, its screens' tilemaps and their Game Boy Color attributes and palettes, and the
preset gate floors."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _dwm import Rom, packed_image  # noqa: E402

GROUP = 'maps'
MAPS = 112
BLANK = '#000000'


class MapDrawer:
    def __init__(self, rom):
        self.rom = rom
        self.r = rom.r
        self.b0b = 0x0B * 0x4000 - 0x4000
        self.b17 = 0x17 * 0x4000 - 0x4000
        self.b16 = 0x16 * 0x4000 - 0x4000
        self.shared = [rom.color(rom.word(rom.lin('FieldBGPalette7') + 2 * i)) for i in range(4)]

    def ref(self, e, bank):
        return self.rom.decompress(self.rom.far_entry(bank, e))

    def palettes(self, a):
        """Background palettes 0-3 at `a`, with colours 1 and 3 taken from the text box palette
        (SetSharedBGColors)."""
        out = []
        for p in range(4):
            c = [self.rom.color(self.rom.word(a + 8 * p + 2 * i)) for i in range(4)]
            c[1], c[3] = self.shared[1], self.shared[3]
            out.append(c)
        return out

    def draw_screen(self, tiles, tilemap, attrs, pals, img, colors, cmap, x0, y0):
        """Draws a 20 x 16-tile screen (tilemap rows 32 bytes apart) at pixel (x0, y0) of img."""
        r = self.rom
        for ty in range(16):
            for tx in range(20):
                t = tilemap[ty * 32 + tx] if ty * 32 + tx < len(tilemap) else 0
                at = 0
                if attrs:
                    b = attrs[ty * 16 + tx // 2] if ty * 16 + tx // 2 < len(attrs) else 0
                    at = (b >> 4) if tx % 2 == 0 else b & 0x0F
                pal = pals[at & 3] if at & 7 < 4 else pals[0]
                base = 16 * t if t < 0x80 else None
                for y in range(8):
                    row = img[y0 + ty * 8 + y]
                    if base is None or base + 16 > len(tiles) or at & 8:
                        if BLANK not in cmap:
                            cmap[BLANK] = len(colors)
                            colors.append(BLANK)
                        for x in range(8):
                            row[x0 + tx * 8 + x] = cmap[BLANK]
                        continue
                    lo, hi = tiles[base + 2 * y], tiles[base + 2 * y + 1]
                    for x in range(8):
                        c = pal[(hi >> (7 - x) & 1) << 1 | (lo >> (7 - x) & 1)]
                        k = cmap.get(c)
                        if k is None:
                            k = cmap[c] = len(colors)
                            colors.append(c)
                        row[x0 + tx * 8 + x] = k

    def fixed_map(self, m):
        r, rom = self.r, self.rom
        info = rom.lin('MapInfo') + 8 * m
        d = r[info:info + 8]
        w, h = (d[2] | d[3] << 8) // 160, (d[4] | d[5] << 8) // 128
        tiles = self.ref(d[0], d[1])
        lst = self.b0b + rom.word(rom.lin('MapScreenTable') + 2 * m)
        plist = self.b17 + rom.word(rom.lin('MapPaletteTable') + 2 * m)
        img = [bytearray([255] * (w * 160)) for _ in range(h * 128)]
        colors, cmap, screens = [], {}, []
        for sy in range(h):
            for sx in range(w):
                s = sy * 4 + sx
                p = rom.word(lst + 2 * s)
                if p == 0xFFFF:
                    continue
                q = self.b0b + p                     # version 0: the story variable's starting value
                tilemap = self.ref(r[q + 2], r[q + 3])
                pp = rom.word(plist + 2 * s)
                attrs, pals = None, [[BLANK, self.shared[1], BLANK, self.shared[3]]] * 4
                if pp != 0xFFFF and 0x4000 <= pp < 0x8000:
                    rec = self.b17 + pp + 2
                    attrs = self.ref(r[rec], r[rec + 1])
                    pals = self.palettes(self.b17 + rom.word(rec + 2))
                self.draw_screen(tiles, tilemap, attrs, pals, img, colors, cmap, sx * 160, sy * 128)
                screens.append(s)
        return img, colors, (w, h), screens, d

    def gate_screen(self, floor_map, b, img, colors, cmap, x0, y0, refs='ScreenMapRefs'):
        """Screen of layout byte b (shape * 16 + variant) in the look of gate floor map `floor_map`."""
        rom, r = self.rom, self.r
        info = rom.lin('GateFloorMapInfo') + 8 * floor_map
        tiles = self.ref(r[info], r[info + 1])
        pals = self.palettes(self.b17 + rom.word(rom.lin('GatePaletteTable') + 2 * floor_map))
        ra = rom.lin(refs)
        amaps = rom.lin('GateAttrMaps1')
        tilemap = self.ref(r[ra + 2 * b], r[ra + 2 * b + 1])
        attrs = self.ref(r[amaps + 2 * b], r[amaps + 2 * b + 1])
        self.draw_screen(tiles, tilemap, attrs, pals, img, colors, cmap, x0, y0)


def build(ctx):
    rom = Rom(ctx)
    md = MapDrawer(rom)
    out, seen = [], {}
    for m in range(1, MAPS):
        try:
            img, colors, (w, h), screens, d = md.fixed_map(m)
        except Exception:  # noqa: BLE001 - an unused slot with no screens
            continue
        key = (bytes(d), tuple(screens))
        if not screens or len(colors) > 254:
            continue
        if key in seen:
            continue
        seen[key] = m
        extra = {'unit': 'MapScreenTable'} if not out else {}
        out.append(packed_image(img, colors, scale=2 if w * h <= 4 else 1, name='map-{:02x}'.format(m), **extra,
                                title='Map ${:02X}'.format(m),
                                subtitle='{} x {} screens'.format(w, h),
                                doc=['Fixed map ${:02X} as the game builds it: its tile set (MapInfo: {:02X}:{:02X}, '
                                     'first solid tile ${:02X}), each screen\'s tilemap from MapScreenTable and its '
                                     'colours from MapPaletteTable, in the first version of every screen (the one '
                                     'a new game starts with; story events switch some screens to later '
                                     'versions). Black marks tiles the screen takes from outside the map\'s own '
                                     'tile set.'.format(m, d[1], d[0], d[6])],
                                users=['DrawMapScreen', 'LoadMapTileset', 'GetScreenTilemapRef', 'LoadMapPalettes',
                                       'LoadMapAttrBuffer', 'MapInfo', 'MapScreenTable', 'MapPaletteTable']))
    # the 16 looks of the gate floors: the same open screen (shape 0, variant 0) in each floor map's tiles
    img = [bytearray([255] * (4 * 162)) for _ in range(4 * 130)]
    colors, cmap, marks = [], {}, []
    try:
        for k in range(16):
            x0, y0 = (k % 4) * 162 + 1, (k // 4) * 130 + 1
            md.gate_screen(k, 0x00, img, colors, cmap, x0, y0)
            marks.append({'x': x0, 'y': y0, 'w': 160, 'h': 128, 'label': 'floor map {}'.format(k),
                          'text': 'tiles from GateFloorMapInfo entry {}, colours GatePaletteTable {}'.format(k, k)})
        if len(colors) <= 254:
            out.append(packed_image(img, colors, scale=1, name='gate-floor-looks', title='Gate floor looks',
                                    unit='GateFloorMapInfo',
                                    subtitle='16 floor maps', marks=marks,
                                    doc=['The gate floors are put together at random from screens of 16 shapes '
                                         '(ScreenShapeTable, ScreenMapRefs), but each floor map has its own tile set '
                                         '(GateFloorMapInfo, bank $28) and colours (GatePaletteTable): here the same '
                                         'open screen (shape 0, variant 0, with exits on all four sides) in each of '
                                         'the 16 looks. A world\'s floor set (FloorMapTables) decides which looks its '
                                         'floors get.'],
                                    users=['MakeGateFloor', 'GetFloorScreenMap', 'GateFloorMapInfo', 'ScreenMapRefs',
                                           'GatePaletteTable', 'GateAttrMaps1']))
    except Exception:  # noqa: BLE001
        pass
    return out
