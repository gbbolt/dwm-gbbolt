INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $009", ROMX[$4000], BANK[$9]

;@ path: system/banks
;@ Bank number byte at the start of the bank (read by the far-call routine).
BankNumber_09::
	db $09

;@ def FarTable_09()
;@ path: menu/script
;@ Far-call entry points of bank 9: entry 0 runs the script menu of this bank (the shop, the vault,
;@ the tournament entry, the picture list, the name entry; the rest is passed on to banks $0A and $12),
;@ entry 1 is the name entry. Entry 0 is the dispatcher right after the table: it calls one frame of
;@ the menu wScriptMenu names.
;@ test: skip jumps through a table of menu routines
FarTable_09::
	dw FarTable_09 + 4                   ; the dispatcher below
	dw NameEntryMenu

;> return ScriptMenuTable9[wScriptMenu]()
	ld a, [wScriptMenu]
	rst $00

;@ path: menu/script
;@ The script menus by wScriptMenu ($00-$0F): 0 and 12 the item shop, 2 the vault, 4 the Starry
;@ Night tournament entry, 13 the picture list, 15 the name entry; 3 and 8-10 run in bank $12
;@ (farm keeper, monster library, choose a monster, item collector), 5-7 and 11 in bank $0A.
ScriptMenuTable9::
	dw ShopMenu
	dw ScriptMenuNone9
	dw VaultMenu
	dw ScriptMenuBank12
	dw ArenaEntryMenu
	dw ScriptMenuBank0A
	dw ScriptMenuBank0A
	dw ScriptMenuBank0A
	dw ScriptMenuBank12
	dw ScriptMenuBank12
	dw ScriptMenuBank12
	dw ScriptMenuBank0A
	dw ShopMenu
	dw GalleryMenu
	dw ScriptMenuNone9
	dw NameEntryMenu

;@ def ScriptMenuBank0A()
;@ path: menu/script
;@ Script menus 5-7 and 11 are run by bank $0A's menu code.
;@ test: skip far call
ScriptMenuBank0A::
;> RunServiceScreen0A()
	ld hl, far_RunServiceScreen0A
	rst $10
	ret


;@ def ScriptMenuBank12()
;@ path: menu/script
;@ Script menus 3 and 8-10 are run by bank $12's menu dispatcher (its far entry 0).
;@ test: skip far call
ScriptMenuBank12::
;> far_call(0x12, 0)                   # bank $12's own ScriptMenuTable
	ld hl, $1200
	rst $10
	ret


;@ def ScriptMenuNone9()
;@ path: menu/script
;@ Menu numbers without a menu: closes at once (gives the field back and resets the menu step).
ScriptMenuNone9::
;> wFieldFlags &= ~0x10                # the field runs again
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def SnapToTile9(pos: hl)
;@ path: menu/window
;@ Rounds the 16-bit scroll position at `pos` to the nearest multiple of 8 pixels, so the menu
;@ windows line up with the background tiles.
;@ test: skip writes through a pointer
SnapToTile9::
;> v = mem16[pos] + 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
;> mem16[pos] = u16(v) & 0xFFF8
	ld [hld], a
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


;@ def NextBgColumn9(addr: hl) -> hl
;@ path: menu/window
;@ The BG map address one tile to the right of `addr`, wrapping around within the 32-tile row.
NextBgColumn9::
;> row = addr & 0xFFE0
	push af
	ld a, l
	and $e0
	push af
;> column = (addr + 1) & 0x1F
	ld a, l
	inc a
	and $1f
	ld l, a
;> return row | column
	pop af
	or l
	ld l, a
	pop af
	ret


;@ def WindowBgAddr9(offset: hl) -> hl
;@ path: menu/window
;@ BG map address of the tile `offset` bytes after the screen's top left corner (wWindowBgMap),
;@ wrapping around at the end of the 32x32 map (only the row part wraps correctly; see
;@ WindowBgAddrWrapped9 for the column).
WindowBgAddr9::
;> base = wWindowBgMap
;> addr = base + offset
	ld a, [wWindowBgMap]
	add l
	ld l, a
	ld a, [wWindowBgMap + 1]
	adc h
;> addr &= 0x3FF
	and $03
	ld h, a
;> return (base & 0xFC00) | addr
	ld a, [wWindowBgMap + 1]
	and $fc
	or h
	ld h, a
	ret


;@ def TilemapBufferAddr9(offset: hl) -> hl
;@ path: menu/window
;@ Address of tile `offset` (row * 32 + column) in wTilemapBuffer.
TilemapBufferAddr9::
;> addr = u16(wTilemapBuffer + offset)
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;> return addr
	ret


;@ def WindowBgAddrWrapped9(offset: hl) -> hl
;@ path: menu/window
;@ BG map address of window tile `offset` (row * 32 + column, counted from the screen's top left
;@ corner), wrapping around both at the bottom and at the right edge of the 32x32 BG map.
WindowBgAddrWrapped9::
;> column = offset & 0x1F
	push bc
	ld b, l
;> addr = WindowBgAddr9(offset & 0xFFE0)         # start of the row
	ld a, l
	and $e0
	ld l, a
	call WindowBgAddr9
;> for _ in range(column):
	ld a, b
	and $1f
	jr z, .done

	ld b, a

.step
;>     addr = NextBgColumn9(addr)
	call NextBgColumn9
	dec b
	jr nz, .step

.done
;> return addr
	pop bc
	ret


;@ def DrawLayoutToVram9(layout: de)
;@ path: unused/menu
;@ Not called: draws a window layout (see DrawWindowLayout9) straight into the BG map instead of
;@ wTilemapBuffer.
;@ test: skip writes VRAM
DrawLayoutToVram9::
;> offset = mem16[layout]; layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;> addr = WindowBgAddrWrapped9(offset)
;> row_start = addr
	call WindowBgAddrWrapped9
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a

.loop
;> while (tile := mem[layout]) != 0xD9:           # $D9 ends the layout
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     if tile == 0xD8:                          # next row
	cp $d8
	jr nz, .tile

;>@nx         addr = ((row_start + 32) & 0x3FF) | 0x9800
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;=@nx
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@nx
	ld a, h
	and $03
	or $98
	ld h, a
;>         row_start = addr
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	jr .loop

.tile
;>     else:
;>         WriteVRAM(tile, addr)
	call WriteVRAM
;>         addr = NextBgColumn9(addr)
	call NextBgColumn9
	jr .loop

;@ def DrawWindowLayout9(layout: de)
;@ path: menu/window
;@ Draws a window layout into wTilemapBuffer (CopyTilemapBufferToVram9 shows it). A layout is
;@ a word, the buffer offset of its top left corner (row * 32 + column), then the tiles row by
;@ row: $D8 starts the next row, $D9 ends the layout. The window frame tiles are $FA/$FB top
;@ corners, $EF top edge, $FE/$FF sides, $FC/$FD bottom corners, $EE bottom edge, $E0 blank.
;@ test: skip needs a real layout
DrawWindowLayout9::
;> offset = mem16[layout]; layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;> dest = TilemapBufferAddr9(offset)
	call TilemapBufferAddr9
;> row_start = dest
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a

.loop
;> while (tile := mem[layout]) != 0xD9:
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     if tile == 0xD8:
	cp $d8
	jr nz, .tile

;>@nr         row_start += 32
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;=@nr
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>         dest = row_start
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	jr .loop

.tile
;>     else:
;>         mem[dest] = tile; dest += 1
	ld [hli], a
	jr .loop

;@ def CopyTilemapBufferToVram9()
;@ path: menu/window
;@ Copies all of wTilemapBuffer (18 rows of 32 tiles) to the BG map, starting at the screen's
;@ top left corner wWindowBgMap and wrapping around the 32x32 map in both directions.
;@ test: skip writes VRAM
CopyTilemapBufferToVram9::
;> row_addr = wWindowBgMap
	ld a, [wWindowBgMap]
	ld l, a
	ld a, [wWindowBgMap + 1]
	ld h, a
;> src = wTilemapBuffer
	ld de, wTilemapBuffer
;> for row in range(18):
	ld c, $12

.row
;>     addr = row_addr
	ld b, $20
	push hl

.tile
;>     for column in range(32):
;>         WriteVRAM(mem[src], addr)
	ld a, [de]
	call WriteVRAM
;>@nc         addr = NextBgColumn9(addr)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@nc
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
	dec b
	jr nz, .tile

;>@nw     row_addr = ((row_addr + 32) & 0x3FF) | 0x9800
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@nw
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .row

	ret


;@ def DrawTextTiles9(tiles: hl, lines: e, length: d)
;@ path: menu/text
;@ Renders the text wTextGroup / wTextIndex into letter tiles at VRAM `tiles` (a box of `lines`
;@ lines of `length` tiles) without touching the text box the printer uses:
;@ its settings are saved and put back.
;@ test: skip far call
DrawTextTiles9::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_size = (wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = lines
;> wTextBoxLineLength = length
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_41()                      # render the text into the tiles
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_size[0]
;> wTextBoxLineLength = saved_size[1]
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawNameTiles9(name: de, tiles: hl)
;@ path: menu/text
;@ Renders a 4-letter name into 4 letter tiles at VRAM `tiles` (through wTextArg0 and system
;@ text $0200, which prints that buffer).
;@ test: skip far call
DrawNameTiles9::
;> CopyName(name, wTextArg0)
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_size = (wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1                    # one line
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4                   # of 4 tiles
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2
;> wTextIndex = 0
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_size[0]
;> wTextBoxLineLength = saved_size[1]
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawCharTile9(char: a, tiles: hl)
;@ path: menu/text
;@ Renders the single character `char` into one letter tile at VRAM `tiles`.
;@ test: skip far call
DrawCharTile9::
;> wTextArg0[0] = char
;> wTextArg0[1] = 0xF0                  # end mark
	ld [wTextArg0], a
	ld a, $f0
	ld [wTextArg0 + 1], a
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_size = (wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2
;> wTextIndex = 0
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_size[0]
;> wTextBoxLineLength = saved_size[1]
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def RestoreTilemapBuffer9()
;@ path: menu/window
;@ Puts the screen as it was before the menu opened back into wTilemapBuffer: the 16 saved field
;@ rows (wSavedTilemap) and the two rows of the party bar (20 tiles each).
RestoreTilemapBuffer9::
;> dest = wTilemapBuffer
	ld hl, wTilemapBuffer
	ld de, wSavedTilemap
	ld bc, $0200

.copy
;>@cp copy(dest, wSavedTilemap, 0x200); dest += 0x200
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
;=@cp
	jr nz, .copy

;> src = wPartyBarTiles
	ld de, wPartyBarTiles
;>@rows for row in range(2):
	ld c, $02

.row
;>     copy(dest, src, 20)
	ld b, $14

.tile
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .tile

;>     src += 32
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>     dest += 32
	ld a, l
	add $0c
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@rows
	dec c
	jr nz, .row

	ret


;@ def ClearTilemapBuffer9()
;@ path: menu/window
;@ Fills all of wTilemapBuffer (18 rows of 32) with the blank tile $E0.
ClearTilemapBuffer9::
;>@f fill(wTilemapBuffer, 0xE0, 0x240)
	ld hl, wTilemapBuffer
	ld bc, $0240

.loop
;=@f
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
;=@f
	jr nz, .loop

	ret


;@ def ClearBgMap9()
;@ path: unused/menu
;@ Not called: fills the whole BG map at $9800 with the blank tile $E0.
;@ test: skip writes VRAM
ClearBgMap9::
;> addr = 0x9800
	ld hl, $9800
	ld bc, $0400
.loop
;> for _ in range(0x400):
;>     addr = WriteVRAMInc(0xE0, addr)
	ld a, $e0
	call WriteVRAMInc
	dec bc
	ld a, b
	or c
	jr nz, .loop

;> return
	ret

;@ def UpdatePagedList9(cursor: hl, positions: de, rows: b, count: c)
;@ path: menu/cursor
;@ One frame of a paged list of `count` entries shown `rows` at a time: Left / Right turn the page
;@ (mem[cursor + 1], wrapping around), Up / Down move the cursor row (mem[cursor]), A marks the row
;@ chosen (bit 7). `positions` is the cursor table: first the page-number position, then the
;@ window offsets of the cursor rows, ending with $FFFF. On the last page only its rows are used.
;@ test: skip continues in the middle of UpdateMenuCursor9
UpdatePagedList9::
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> positions += 2                      # skip the page-number position
	inc de
	inc de
;> if wTextState == 0:                 # no page turning while text is printed
	ld a, [wTextState]
	or a
	jp nz, .noPageTurn

;>     if wJoyPressed & 0x20:          # Left: previous page
	ld a, [wJoyPressed]
	bit 5, a
	jr z, .right

;>         wPageToggle ^= 1
	ld a, [wPageToggle]
	inc a
	and $01
	ld [wPageToggle], a
;>         page = u8(mem[cursor + 1] - 1)
	inc hl
	ld a, [hl]
	dec a
;>@p1         pages = (count - 1) // rows + 1
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
;=@p1
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>         if page >= pages:           # went below the first page
	pop af
	cp c
	jr c, .setPage

;>             page = pages - 1
	ld a, c
	dec a
	jr .setPage

.right
;>     elif wJoyPressed & 0x10:        # Right: next page
	ld a, [wJoyPressed]
	bit 4, a
	jr z, .noPageTurn

;>         wPageToggle ^= 1
	ld a, [wPageToggle]
	inc a
	and $01
	ld [wPageToggle], a
;>         page = mem[cursor + 1] + 1
	inc hl
	ld a, [hl]
	inc a
;>@p2         pages = (count - 1) // rows + 1
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
;=@p2
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>         if page >= pages:
	pop af
	cp c
	jr c, .setPage

;>             page = 0
	ld a, $00

.setPage
;>     if wJoyPressed & 0x30:
;>         mem[cursor + 1] = page
	ld [hld], a
;>         if page == pages - 1:       # the last page may have fewer rows
	dec c
	cp c
	jr nz, MenuCursorMoved9

;>@lr             last = count % rows
	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
;=@lr
	call Divide8
	pop bc
	pop de
;>             if last and mem[cursor] > last - 1:
	or a
	jr z, MenuCursorMoved9

	dec a
	cp [hl]
	jr nc, MenuCursorMoved9

;>                 mem[cursor] = last - 1
	ld [hl], a
;>         return MenuCursorMoved9(cursor, positions)   # resets the blink, takes A, draws the cursor
	jr MenuCursorMoved9

.noPageTurn
;>@dp DrawPageNumber9(rows, count, positions, cursor)
	push bc
	push de
	push hl
	call DrawPageNumber9
	pop hl
	pop de
;=@dp
	pop bc
;> last_page = (count - 1) // rows
;>@lp wListLastRows = (count - 1) % rows
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@lp
	ld [wListLastRows], a
	ld a, b
	pop bc
	pop de
	ld c, a
;> if mem[cursor + 1] == last_page:
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateMenuCursor9

;>     rows = wListLastRows + 1         # only the rows of the last page
	ld a, [wListLastRows]
	inc a
	ld b, a
;> return UpdateMenuCursor9(cursor, rows, positions)

;@ def UpdateMenuCursor9(cursor: hl, rows: b, positions: de)
;@ path: menu/cursor
;@ One frame of a menu cursor: Up / Down (with auto-repeat) move mem[cursor] through `rows`
;@ entries, wrapping around; a move restarts the blink. A sets bit 7 (chosen). Then the cursor is
;@ drawn at the window offsets in `positions` (DrawMenuCursor9). MenuCursorMoved9 and
;@ MenuCursorCheckA9 are entry points into the second half.
;@ test: skip draws to VRAM
UpdateMenuCursor9::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:               # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .down

;>     row = u8(mem[cursor] - 1)
	ld a, [hl]
	dec a
;>     if row >= rows:
;>         row = rows - 1
	cp b
	jr c, .store

	dec b
	ld a, b
	jr .store

.down
;> elif wJoyRepeat & 0x80:             # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, MenuCursorCheckA9

;>     row = mem[cursor] + 1
	ld a, [hl]
	inc a
;>     if row >= rows:
;>         row = 0
	cp b
	jr c, .store

	ld a, $00

.store
;> if wJoyRepeat & 0xC0:
;>     mem[cursor] = row
	ld [hl], a

MenuCursorMoved9:
;>     wCursorBlink = 0                # show the cursor at once
	xor a
	ld [wCursorBlink], a
	push hl
	push de
	pop de
	pop hl

MenuCursorCheckA9:
;> if wJoyPressed & 0x01:              # A
;>     mem[cursor] |= 0x80
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw

	set 7, [hl]

.draw
;> DrawMenuCursor9(mem[cursor], positions)
	ld a, [hl]
	call DrawMenuCursor9
	ret


;@ path: unused/menu
;@ Not called: the Left / Right version of UpdateMenuCursor9 (code kept as bytes; it jumps into
;@ the middle of UpdateMenuCursor9).
UpdateMenuCursorLeftRight9::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

;@ def UpdateNumberEntry(digit: hl, positions: de, digits: b, limit: c)
;@ path: menu/number
;@ One frame of a two-digit number entry (how many to buy, sell, store or take): mem[digit] is the
;@ digit the cursor is on, mem[digit + 1] the number. Down / Up lower / raise that digit (wrapping
;@ 0-9), Left / Right move between the `digits` digits, A sets bit 7 of mem[digit]. The number is
;@ kept between 1 and `limit`. Then the digits are drawn at the window offsets in `positions`.
;@ test: skip draws to VRAM
UpdateNumberEntry::
;> mem[digit] &= 0x7F
	res 7, [hl]
;> hNumber[2] = limit
	ld a, c
	ldh [hNumber + 2], a
;> if wJoyRepeat & 0x80:               # Down: the digit goes down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .up

;>     wCursorBlink = 0x10             # show the digit, not the cursor
;>     NumberEntryDigitDown(digit)
	ld a, $10
	ld [wCursorBlink], a
	call NumberEntryDigitDown
	jr .moved

.up
;> elif wJoyRepeat & 0x40:             # Up: the digit goes up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .left

;>     wCursorBlink = 0x10
;>     NumberEntryDigitUp(digit)
	ld a, $10
	ld [wCursorBlink], a
	call NumberEntryDigitUp
	jr .moved

.left
;> elif wJoyRepeat & 0x20:             # Left: the digit to the left
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .right

;>     d = u8(mem[digit] - 1)
	ld a, [hl]
	dec a
;>     if d >= digits:
;>         d = digits - 1
	cp b
	jr c, .store

	dec b
	ld a, b
	jr .store

.right
;> elif wJoyRepeat & 0x10:             # Right: the digit to the right
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .checkA

;>     d = mem[digit] + 1
;>     if d >= digits:
	ld a, [hl]
	inc a
	cp b
	jr c, .store

;>         d = 0
	ld a, $00

.store
;> if wJoyRepeat & 0x30:
;>     mem[digit] = d
	ld [hl], a
;>     wCursorBlink = 0
	xor a
	ld [wCursorBlink], a

.moved
;> pass
	push hl
	push de
	pop de
	pop hl

.checkA
;> if wJoyPressed & 0x01:              # A
;>     mem[digit] |= 0x80
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .limit

	set 7, [hl]

.limit
;> if limit < mem[digit + 1]:
	ldh a, [hNumber + 2]
	inc hl
	cp [hl]
	dec hl
	jr nc, .notZero

;>     mem[digit + 1] = limit
	inc hl
	ld [hld], a

.notZero
;> if mem[digit + 1] == 0:
;>     mem[digit + 1] = 1
	inc hl
	ld a, [hl]
	or a
	jr nz, .draw

	ld [hl], $01

.draw
;> DrawNumberEntry(mem[digit], digit, positions)
	dec hl
	ld a, [hl]
	call DrawNumberEntry
	ret


;@ def NumberEntryDigitDown(digit: hl)
;@ path: menu/number
;@ Lowers digit mem[digit] (0 tens, 1 ones) of the number mem[digit + 1], 0 wrapping to 9. When the
;@ ones digit takes the number down to 0 it becomes 9 instead.
;@ test: skip uses the home number routines
NumberEntryDigitDown::
;>@pn PrintNumber2Zeros(mem[digit + 1], wNumberBackup)    # its two digits
	push de
	ld a, [hl]
	push hl
	inc hl
	ld c, [hl]
	ld b, $00
;=@pn
	ld hl, wNumberBackup
	call PrintNumber2Zeros
	pop hl
;>@dg d = wNumberBackup[mem[digit]] & 0x0F
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
;=@dg
	ld d, a
	ld a, [de]
	and $0f
;> wNumberBackup[mem[digit]] = 9 if d == 0 else d - 1
	dec a
	ld [de], a
	cp $ff
	jr nz, .value

	ld a, $09
	ld [de], a

.value
;> value = NumberEntryDigitsToValue(digit)
	call NumberEntryDigitsToValue
;> if value == 0 and mem[digit] != 0:
	pop de
	or a
	ret nz

	ld a, [hl]
	or a
	ret z

;>     mem[digit + 1] = 9
	ld a, $09
	inc hl
	ld [hld], a
	ret


;@ def NumberEntryDigitsToValue(digit: hl) -> a
;@ path: menu/number
;@ Puts the two digits in wNumberBackup together into the number mem[digit + 1] and returns it.
;@ test: skip uses the home multiply routine
NumberEntryDigitsToValue::
;>@v value = (wNumberBackup[0] & 0x0F) * 10 + (wNumberBackup[1] & 0x0F)
	push hl
	ld a, [wNumberBackup]
	and $0f
	ld c, $0a
	call Multiply
;=@v
	ld a, [wNumberBackup + 1]
	and $0f
	add l
;> mem[digit + 1] = value
	pop hl
	inc hl
	ld [hld], a
;> return value
	ret


;@ def NumberEntryDigitUp(digit: hl)
;@ path: menu/number
;@ Raises digit mem[digit] (0 tens, 1 ones) of the number mem[digit + 1], 9 wrapping to 0.
;@ test: skip uses the home number routines
NumberEntryDigitUp::
;>@pn PrintNumber2Zeros(mem[digit + 1], wNumberBackup)
	push de
	ld a, [hl]
	push hl
	inc hl
	ld c, [hl]
	ld b, $00
;=@pn
	ld hl, wNumberBackup
	call PrintNumber2Zeros
	pop hl
;>@dg d = wNumberBackup[mem[digit]] & 0x0F
	ld de, wNumberBackup + 1
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
;=@dg
	adc d
	ld d, a
	ld a, [de]
	and $0f
;> wNumberBackup[mem[digit]] = 0 if d == 9 else d + 1
	inc a
	ld [de], a
	cp $0a
	jr nz, .value

	ld a, $00
	ld [de], a

.value
;> NumberEntryDigitsToValue(digit)
	call NumberEntryDigitsToValue
	pop de
	ret


;@ def ResetCursorBlink9()
;@ path: menu/cursor
;@ Restarts the cursor blink, so the next DrawMenuCursor9 draws the cursor at once.
ResetCursorBlink9::
;> wCursorBlink = 0
	xor a
	ld [wCursorBlink], a
	ret


;@ def DrawMenuCursor9(cursor: a, positions: de)
;@ path: menu/cursor
;@ Draws the menu cursor among the window offsets in `positions` (ending with $FFFF): the arrow
;@ $E8 at entry cursor & $7F (blinking: it is off while wCursorBlink bit 4 is set), the filled
;@ arrow $E9 once chosen (bit 7), blank $E0 at all the others. Unless chosen, it only redraws every
;@ 16 frames. Tiles go both to the BG map and to wTilemapBuffer.
;@ test: skip writes VRAM
DrawMenuCursor9::
;> if not cursor & 0x80:
	ld c, a
	bit 7, a
	jr nz, .draw

;>     t = wCursorBlink & 0x0F
;>     wCursorBlink += 1
	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
;>     if t:
;>         return
	pop af
	ld a, c
	ret nz

.draw
;> i = 0
	ld c, a
	ld b, $00

.loop
;>@wh while (pos := mem16[positions + 2 * i]) != 0xFFFF:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@wh
	and l
	cp $ff
	ret z

;>@w     addr = WindowBgAddrWrapped9(pos)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@w
	call WindowBgAddrWrapped9
	pop bc
	pop de
;>     if (cursor & 0x7F) != i:
;>         tile = 0xE0
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .put

;>     elif cursor & 0x80:
;>         tile = 0xE9                 # chosen
	ld a, $e9
	bit 7, c
	jr nz, .put

;>     elif wCursorBlink & 0x10:
;>         tile = 0xE0                 # blink phase: hidden
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .put

;>     else:
;>         tile = 0xE8
	ld a, $e8

.put
;>     WriteVRAM(tile, addr)
	call WriteVRAM
;>@b     wTilemapBuffer[pos] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
;>     i += 1
	inc b
	jr .loop

;@ def DrawPageNumber9(rows: b, count: c, positions: de, cursor: hl)
;@ path: menu/cursor
;@ If the list has more than one page, writes the page number (page + 1, one or two digits, tiles
;@ $F0-$F9 are the digits 0-9) into the window frame just left of the position at positions - 2.
;@ test: skip writes VRAM
DrawPageNumber9::
;> if rows >= count:
;>     return
	ld a, b
	cp c
	ret nc

;> page = mem[cursor + 1]
	inc hl
	ld c, [hl]
;>@ps pos = mem16[positions - 2]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
;=@ps
	ld h, a
	inc de
;> if pos == 0xFFFF:
;>     return
	and l
	cp $ff
	ret z

;> pos -= 1                            # hNumber holds the position for PutWindowTile
	dec hl
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;> if (page & 0x7F) != 9:
	ld a, c
	and $7f
	cp $09
	jr z, .ten

;>     PutWindowTile(0xF1 + page)      # digit page + 1
;>     tile = 0xEE                     # frame edge in front
	add $f1
	call PutWindowTile
	ld a, $ee
	jr .left

.ten
;> else:
;>     PutWindowTile(0xF0)             # "10"
;>     tile = 0xF1
	ld a, $f0
	call PutWindowTile
	ld a, $f1

.left
;>@l mem16[hNumber] = pos - 1
	push af
	ldh a, [hNumber]
	sub $01
	ldh [hNumber], a
	ldh a, [hNumber + 1]
	sbc $00
;=@l
	ldh [hNumber + 1], a
;> PutWindowTile(tile)
	pop af
	call PutWindowTile
;>@hb mem16[hNumber] = pos             # put the position back
	ldh a, [hNumber]
	add $01
	ldh [hNumber], a
	ldh a, [hNumber + 1]
;=@hb
	adc $00
	ldh [hNumber + 1], a
	ret


;@ def PutWindowTile(tile: a)
;@ path: menu/window
;@ Puts `tile` at the window offset in hNumber (u16): into the BG map and into wTilemapBuffer.
;@ test: skip writes VRAM
PutWindowTile::
;> pos = mem16[hNumber]
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
;>@v WriteVRAM(tile, WindowBgAddrWrapped9(pos))
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	pop af
;=@v
	call WriteVRAM
;>@t wTilemapBuffer[pos] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@t
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@t
	ld [hl], a
	ret


;@ def DrawListFrame9(cursor: hl, positions: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws the list marks into wTilemapBuffer: at the first position of `positions` the arrow $E7 if
;@ the list has more pages (else the frame edge $EE) with the page number (mem[cursor + 1] + 1)
;@ in front of it, then the cursor (DrawCursorAt9 with the rest of the table).
;@ test: skip uses hNumber as scratch
DrawListFrame9::
;> row = mem[cursor]
	ld a, [hli]
	push af
	push hl
;>@bf buf = wTilemapBuffer + mem16[positions]; positions += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	ld h, a
;=@bf
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;> more = rows < count
;> mem[buf] = 0xE7 if more else 0xEE
	ld a, b
	cp c
	ld a, $ee
	jr nc, .mark

	ld a, $e7

.mark
	ld [hld], a
;> if more:
	pop bc
	jr nc, .cursor

;>     page = mem[cursor + 1]
;>     if page != 9:
	ld a, [bc]
	cp $09
	jr z, .ten

;>         mem[buf - 1] = 0xF1 + page
;>         mem[buf - 2] = 0xEE
	add $f1
	ld [hld], a
	ld a, $ee
	ld [hli], a
	jr .cursor

.ten
;>     else:
;>         mem[buf - 1] = 0xF0         # "10"
;>         mem[buf - 2] = 0xF1
	ld a, $f0
	ld [hld], a
	ld a, $f1
	ld [hli], a

.cursor
;> return DrawCursorAt9(row, positions)
	pop af

;@ def DrawCursorAt9(row: a, positions: de)
;@ path: menu/cursor
;@ Puts the cursor tile of entry `row` of `positions` into wTilemapBuffer only (the caller copies
;@ the buffer to the screen): $E9 if chosen (bit 7), else $E8, or $E0 in the hidden blink phase.
;@ test: skip needs a real position table
DrawCursorAt9::
;>@p pos = mem16[positions + 2 * (row & 0x7F)]
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;=@p
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;=@p
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;> WindowBgAddrWrapped9(pos)            # (result not used)
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
;> if row & 0x80:
;>     tile = 0xE9
	ld a, $e9
	bit 7, c
	jr nz, .put

;> elif wCursorBlink & 0x10:
;>     tile = 0xE0
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .put

;> else:
;>     tile = 0xE8
	ld a, $e8

.put
;>@b wTilemapBuffer[pos] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
	ret


;@ def DrawNumberEntry(cursor: a, digit: hl, positions: de)
;@ path: menu/number
;@ Draws the two digits of the number mem[digit + 1] at the window offsets in `positions`; the digit
;@ the cursor is on blinks with the cursor tile $E6. Unless the entry is chosen (bit 7), it only
;@ redraws every 16 frames.
;@ test: skip writes VRAM
DrawNumberEntry::
;>@pn PrintNumber2Zeros(mem[digit + 1], wNumberBackup)
	ld c, a
	inc hl
	push de
	push bc
	ld c, [hl]
	ld b, $00
;=@pn
	ld hl, wNumberBackup
	call PrintNumber2Zeros
	pop bc
	pop de
;> if not cursor & 0x80:
	bit 7, c
	jr nz, .draw

;>     t = wCursorBlink & 0x0F
;>     wCursorBlink += 1
	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
;>     if t:
;>         return
	pop af
	ld a, c
	ret nz

.draw
;> i = 0
	ld c, a
	ld b, $00

.loop
;>@wh while (pos := mem16[positions + 2 * i]) != 0xFFFF:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@wh
	and l
	cp $ff
	ret z

;>@w     addr = WindowBgAddrWrapped9(pos)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@w
	call WindowBgAddrWrapped9
	pop bc
	pop de
;>@c     if (cursor & 0x7F) == i and not (wCursorBlink & 0x10):
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .check

;=@c
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .check

;>         tile = 0xE6                 # the cursor
	ld a, $e6

.check
;>     else:
;>@d         tile = wNumberBackup[i]     # the digit
	cp $e0
	jr nz, .put

	push hl
	ld a, b
	ld hl, wNumberBackup
	add l
;=@d
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl

.put
;>     WriteVRAM(tile, addr)
	call WriteVRAM
;>@b     wTilemapBuffer[pos] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
;>     i += 1
	inc b
	jr .loop

;@ def PrintMenuText9(n: hl)
;@ path: menu/script
;@ Prints message wScriptMenuText + `n`: the messages of a script menu follow each other, the
;@ script that opened the menu sets the first one.
;@ test: skip prints text
PrintMenuText9::
;> msg = wScriptMenuText + n
	ld a, [wScriptMenuText]
	add l
	ld l, a
	ld a, [wScriptMenuText + 1]
	adc h
	ld h, a
;> PrintMessage(msg)
	call PrintMessage
	ret


;@ def ShopMenu()
;@ path: item/shop
;@ The item shop (script menus 0 and 12), one frame: runs step wMenuStep.
;@ test: skip jumps through a table
ShopMenu::
;> return ShopSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: item/shop
;@ Steps of the item shop: set up, draw the Buy / Sell / Quit menu, its input, the chosen option,
;@ close.
ShopSteps::
	dw ShopInit
	dw ShopOpenMenu
	dw ShopMainMenuInput
	dw ShopRunOption
	dw ShopClose

;@ def ShopInit()
;@ path: item/shop
;@ Lines the background up with the tile grid, works out where the screen's top left corner is in
;@ the BG map (wWindowBgMap), takes the field picture into wTilemapBuffer and loads the shop's
;@ window graphics (bank $2E entry $0E) to tiles $8800.
;@ test: skip decompresses graphics
ShopInit::
;> SnapToTile9(hScrollX)
	ld hl, hScrollX
	call SnapToTile9
;> SnapToTile9(hScrollY)
	ld hl, hScrollY
	call SnapToTile9
;> fill(addr(wMenuChoice), 0, 8)              # the menu cursors
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@m map = 0x9800 + (hScrollY // 8) * 32 + hScrollX // 8
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@m
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
;=@m
	adc $98
	ld h, a
;>@s wWindowBgMap = (map & 0x3FF) | 0x9800
	ld a, h
	and $03
	or $98
	ld h, a
;=@s
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DecompressVRAM(0x2E, 0x0E, 0x8800)
	ld de, $2e0e
	ld hl, $8800
	call DecompressVRAM
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ShopOpenMenu()
;@ path: item/shop
;@ Draws the shop's main menu over the field.
;@ test: skip writes VRAM
ShopOpenMenu::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawShopMainMenu()
	call DrawShopMainMenu
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def DrawShopMainMenu()
;@ path: item/shop
;@ Draws the Buy / Sell / Quit window, the gold window with the purse, and the message window
;@ (layout $2E07 in bank 0) into wTilemapBuffer, with the cursor at wMenuChoice.
;@ test: skip uses the home number routines
DrawShopMainMenu::
;> DrawWindowLayout9(ShopMainMenuLayout)
	ld de, ShopMainMenuLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(GoldWindowLayout)
	ld de, GoldWindowLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(0x2E07)            # message window at the bottom (bank 0)
	ld de, $2e07
	call DrawWindowLayout9
;> copy(hNumber, wGold, 3)
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(TilemapBufferAddr9(0x2E))      # row 1, column 14
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice, ShopMainMenuCursor)
	ld de, ShopMainMenuCursor
	ld a, [wMenuChoice]
	call DrawCursorAt9
	ret


;@ def ShopMainMenuInput()
;@ path: item/shop
;@ Buy / Sell / Quit: B or Start leaves the shop, A picks the option (wMenuChoice gets bit 7).
;@ test: skip draws to VRAM
ShopMainMenuInput::
;> UpdateMenuCursor9(wMenuChoice, 3, ShopMainMenuCursor)
	ld de, ShopMainMenuCursor
	ld hl, wMenuChoice
	ld b, $03
	call UpdateMenuCursor9
;> if wJoyPressed & 0x0A:               # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .checkA

;>     wMenuStep += 2                  # close
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;>     wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;>     wMenuChoice |= 0x80
	ld hl, wMenuChoice
	set 7, [hl]
;>     fill(addr(wMenuChoice2), 0, 7)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr .done

.done
	ret


;@ path: item/shop
;@ Cursor table of the shop's main menu: window offsets (row * 32 + column) of Buy, Sell, Quit;
;@ $FFFF ends it.
ShopMainMenuCursor::
	dw $0021, $0061, $00a1, $ffff

;@ def ShopRunOption()
;@ path: item/shop
;@ Runs the chosen shop option.
;@ test: skip jumps through a table
ShopRunOption::
;> return ShopOptionTable[wMenuChoice & 0x7F]()     # (bit 7 is ignored by the jump)
	ld a, [wMenuChoice]
	rst $00

;@ path: item/shop
;@ The shop options: buy, sell, quit.
ShopOptionTable::
	dw ShopBuyOption
	dw ShopSellOption
	dw ShopClose

;@ def ShopClose()
;@ path: item/shop
;@ Leaves the shop: the field picture comes back with an empty message window, and the field runs
;@ again.
;@ test: skip writes VRAM
ShopClose::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawWindowLayout9(0x2E07)
	ld de, $2e07
	call DrawWindowLayout9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def ShopBuyOption()
;@ path: item/shop/buy
;@ Buying, one frame: runs step wMenuSubStep.
;@ test: skip jumps through a table
ShopBuyOption::
;> return ShopBuySteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: item/shop/buy
;@ Steps of buying: pick the item from the shop's list, the quantity, confirm, pay.
ShopBuySteps::
	dw ShopBuyStart
	dw ShopBuyShowList
	dw ShopBuyListInput
	dw ShopBuyAskQuantity
	dw ShopBuyShowQuantity
	dw ShopBuyQuantityInput
	dw ShopBuyAskConfirm
	dw ShopBuyShowYesNo
	dw ShopBuyYesNoInput
	dw ShopBuyDoIt
	dw ShopBuyDone

;@ def ShopBuyStart()
;@ path: item/shop/buy
;@ Asks what the player wants and copies the shop's goods into wSceneObjects: map $50 has its
;@ own list, the town shops pick theirs by the screen of the map they are on (wMapScreen 0, 2, 4,
;@ 5; any other screen gets the screen-5 list).
;@ test: skip prints a message
ShopBuyStart::
;> PrintMenuText9(3)                    # "What would you like?"
	ld hl, $0003
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;> if wMapId == 0x50:
;>     stock = ShopStockMap50
	ld a, [wMapId]
	ld hl, ShopStockMap50
	cp $50
	jr z, .copy

;> elif wMapScreen == 0:
;>     stock = ShopStock0
	ld a, [wMapScreen]
	ld hl, ShopStock0
	cp $00
	jr z, .copy

;> elif wMapScreen == 2:
;>     stock = ShopStock2
	ld hl, ShopStock2
	cp $02
	jr z, .copy

;> elif wMapScreen == 4:
;>     stock = ShopStock4
	ld hl, ShopStock4
	cp $04
	jr z, .copy

;> else:
;>     stock = ShopStock5
	ld hl, ShopStock5
	cp $05
	jr z, .copy

.copy
;> fill(wSceneObjects, 0, 20)
	push hl
	ld hl, wSceneObjects
	ld bc, $0014
	xor a
	call FillMemory
	pop hl
;> dest = wSceneObjects
	ld de, wSceneObjects

.loop
;> while True:                         # copy up to and with the $FF end
;>     item = mem[stock]; stock += 1
	ld a, [hli]
;>     mem[dest] = item; dest += 1
	ld [de], a
	inc de
;>     if item == 0xFF:
;>         return
	cp $ff
	ret z

	jr .loop

;@ path: item/shop/buy
;@ Goods of the shop on screen 0 of its map: item numbers, $FF ends the list.
ShopStock0::
	db $01, $02, $07, $28, $13, $14, $1d, $26, $ff

;@ path: item/shop/buy
;@ Goods of the shop on screen 2.
ShopStock2::
	db $05, $04, $03, $0c, $2a, $2b, $15
	db $1a, $ff

;@ path: item/shop/buy
;@ Goods of the shop on screen 4.
ShopStock4::
	db $1f, $20, $21, $22, $23, $24, $ff

;@ path: item/shop/buy
;@ Goods of the shop on screen 5 (and any other screen).
ShopStock5::
	db $17, $29, $19, $1b, $18, $1c, $25
	db $ff

;@ path: item/shop/buy
;@ Goods of the shop on map $50.
ShopStockMap50::
	db $01, $02, $07, $08, $0b, $09, $0a, $0c, $ff

;@ def ShopBuyShowList()
;@ path: item/shop/buy
;@ Once the question is printed: counts the goods, renders the names of the first page and draws the
;@ list with the prices.
;@ test: skip draws to VRAM
ShopBuyShowList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> CountShopList()
	call CountShopList
;> LoadItemNameTiles()
	call LoadItemNameTiles
;> DrawShopBuyWindow()
	call DrawShopBuyWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawShopBuyWindow()
;@ path: item/shop/buy
;@ Draws the shop's main menu, the list of goods with their prices, the page mark and the cursor.
;@ test: skip writes VRAM
DrawShopBuyWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawShopMainMenu()
	call DrawShopMainMenu
;> DrawWindowLayout9(ShopListLayout)
	ld de, ShopListLayout
	call DrawWindowLayout9
;> DrawBuyPrices()
	call DrawBuyPrices
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawListFrame9(wListCursor, ShopBuyListCursor, 4, wListLength)
	ld de, ShopBuyListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def LoadItemNameTiles()
;@ path: item/shop
;@ Renders the names of the 4 items of page wListPage of the list in wSceneObjects into tiles
;@ $8800 on (9 tiles each; ShopListLayout shows them).
;@ test: skip far call
LoadItemNameTiles::
;>@i item = wSceneObjects + wListPage * 4
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
;=@i
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x8800
	ld hl, $8800
;> for _ in range(4):
;>     item, tiles = LoadItemNameSlot(item, tiles)
	call LoadItemNameSlot
	call LoadItemNameSlot
	call LoadItemNameSlot

;@ def LoadItemNameSlot(item: de, tiles: hl) -> (de, hl)
;@ path: item/shop
;@ Renders the name of item mem[item] (text group 8; $FF = entry 0, empty) into 9 tiles at
;@ `tiles`; returns the next item and the next 9 tiles.
;@ test: skip far call
LoadItemNameSlot::
;>@t wTextIndex = 0 if mem[item] == 0xFF else mem[item]
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, .text

	ld a, $00

.text
;=@t
	ld [wTextIndex], a
;> wTextGroup = 8                      # item names
	ld a, $08
	ld [wTextGroup], a
;> DrawTextTiles9(tiles, 1, 9)
	ld de, $0901
	call DrawTextTiles9
;>@r return item + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret


;@ def DrawBuyPrices()
;@ path: item/shop/buy
;@ Writes the price (and the gold mark $DD) of the 4 items on page wListPage into wTilemapBuffer,
;@ from row 5, column 13 down, every second row.
;@ test: skip uses far calls
DrawBuyPrices::
;>@i item = wSceneObjects + wListPage * 4
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
;=@i
	ld a, $00
	adc d
	ld d, a
;> pos = 0x00AD
	ld hl, $00ad
;> for _ in range(4):
;>     item, pos = DrawBuyPriceSlot(item, pos)
	call DrawBuyPriceSlot
	call DrawBuyPriceSlot
	call DrawBuyPriceSlot

;@ def DrawBuyPriceSlot(item: de, pos: hl) -> (de, hl)
;@ path: item/shop/buy
;@ Writes the buy price of item mem[item] (bytes 1-2 of its ItemData record) as 5 digits and the
;@ gold mark at window offset `pos`, or 6 blanks for an empty entry; returns the next item and the
;@ position two rows down.
;@ test: skip uses far calls
DrawBuyPriceSlot::
;>@x if mem[item] in (0x00, 0xFF):
	push de
	push hl
	ld a, [de]
	cp $00
	jr z, .empty

;=@x
	cp $ff
	jr nz, .price

.empty
;>@e     fill(TilemapBufferAddr9(pos), 0xE0, 6)
	call TilemapBufferAddr9
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@e
	ld [hli], a
	ld [hli], a
	jr .next

.price
;> else:
;>     wItemId = mem[item]
	push hl
	ld a, [de]
	ld [wItemId], a
;>     GetItemData()
	ld hl, far_GetItemData
	rst $10
;>     mem[hNumber + 2] = 0
;>@n     mem16[hNumber] = mem16[wItemData + 1]    # the price
	pop hl
	push hl
	call TilemapBufferAddr9
	ld a, [wItemData + 1]
	ldh [hNumber], a
	ld a, [wItemData + 2]
;=@n
	ldh [hNumber + 1], a
	ld a, $00
	ldh [hNumber + 2], a
;>     PrintNumber5(TilemapBufferAddr9(pos))
	call PrintNumber5
;>@g     mem[TilemapBufferAddr9(pos + 5)] = 0xDD # gold mark
	pop hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
;=@g
	ld h, a
	call TilemapBufferAddr9
	ld [hl], $dd

.next
;>@r return item + 1, pos + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret


;@ def CountShopList()
;@ path: item/shop
;@ wListLength = number of items in the list in wSceneObjects.
CountShopList::
;> wListLength = CountItems20(wSceneObjects)
	ld hl, wSceneObjects
	call CountItems20
	ld a, c
	ld [wListLength], a
	ret


;@ def CountItems20(items: hl) -> c
;@ path: item/bag
;@ Counts the items of a list of up to 20 (the bag's size) before the first 0 or $FF.
CountItems20::
;> n = 0
	ld b, $14
	ld c, $00

.loop
;> while n < 20 and mem[items + n] not in (0x00, 0xFF):
	ld a, [hli]
	cp $00
	ret z

	cp $ff
	ret z

;>     n += 1
	inc c
	dec b
	jr nz, .loop

;> return n
	ret


;@ def ShopBuyListInput()
;@ path: item/shop/buy
;@ The list of goods: Left / Right page, Up / Down pick (a new page renders its names and prices),
;@ B goes back to Buy / Sell / Quit, A takes the item and starts the quantity at 1.
;@ test: skip draws to VRAM
ShopBuyListInput::
;>@op old_page = wListPage
	ld de, ShopBuyListCursor
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@op
	ld a, [hld]
	push af
;> old_row = wListCursor
	ld a, [hl]
	push af
;> UpdatePagedList9(wListCursor, ShopBuyListCursor, 4, wListLength)
	call UpdatePagedList9
;>@cmp pass                             # (the row is compared, but nothing depends on it)
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@cmp
	cp b
	jr z, .samePage

.samePage
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .buttons

;>     LoadItemNameTiles()
	call LoadItemNameTiles
;>     DrawBuyPrices()
	call DrawBuyPrices
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9

.buttons
;> if wJoyPressed & 0x02:              # B: back to the main menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice2 = 1             # the quantity
	ld a, $01
	ld [wConfirmChoice2], a

.done
	ret


;@ path: item/shop/buy
;@ Cursor table of the list of goods: the page-number position, then the 4 rows (window offsets);
;@ $FFFF ends it.
ShopBuyListCursor::
	dw $0192, $00a2, $00e2, $0122, $0162, $ffff

;@ def ShopBuyAskQuantity()
;@ path: item/shop/buy
;@ Asks how many; the number entry starts on the ones digit.
;@ test: skip prints text
ShopBuyAskQuantity::
;> PrintMenuText9(5)                    # "How many?"
	ld hl, $0005
	call PrintMenuText9
;> wConfirmChoice = 1                   # digit cursor on the ones
	ld a, $01
	ld [wConfirmChoice], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopBuyShowQuantity()
;@ path: item/shop/buy
;@ Once the question is printed, shows the quantity window.
;@ test: skip draws to VRAM
ShopBuyShowQuantity::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawBuyQuantityWindow()
	call DrawBuyQuantityWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawBuyQuantityWindow()
;@ path: item/shop/buy
;@ Draws the list of goods with the chosen row and the small quantity window (two digits, the
;@ quantity is wConfirmChoice2, the digit cursor wConfirmChoice).
;@ test: skip writes VRAM
DrawBuyQuantityWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawShopMainMenu()
	call DrawShopMainMenu
;> DrawWindowLayout9(ShopListLayout)
	ld de, ShopListLayout
	call DrawWindowLayout9
;> DrawBuyPrices()
	call DrawBuyPrices
;> DrawListFrame9(wListCursor, ShopBuyListCursor, 4, wListLength)
	ld de, ShopBuyListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> DrawWindowLayout9(BuyQuantityLayout)
	ld de, BuyQuantityLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawNumberEntry(wConfirmChoice, wConfirmChoice, ShopBuyDigitCursor)
	ld de, ShopBuyDigitCursor
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def ShopBuyQuantityInput()
;@ path: item/shop/buy
;@ The quantity (1-20): B goes back to the list, A goes on.
;@ test: skip draws to VRAM
ShopBuyQuantityInput::
;> UpdateNumberEntry(wConfirmChoice, ShopBuyDigitCursor, 2, 20)
	ld de, ShopBuyDigitCursor
	ld hl, wConfirmChoice
	ld b, $02
	ld c, $14
	call UpdateNumberEntry
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     DrawShopBuyWindow()
	call DrawShopBuyWindow
;>     PrintMenuText9(4)
	ld hl, $0004
	call PrintMenuText9
;>@b     wMenuSubStep -= 4               # back to the list input
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@b
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/shop/buy
;@ Positions of the two quantity digits (window offsets), $FFFF ends them.
ShopBuyDigitCursor::
	dw $0161, $0162, $ffff

;@ def ShopBuyAskConfirm()
;@ path: item/shop/buy
;@ Works out the price (quantity x the item's price, 24-bit, kept in wListCursor2..$C8E6) and asks
;@ "<quantity> <item> will be <price> gold. OK?" (the three parts in wTextArg0-2).
;@ test: skip uses far calls
ShopBuyAskConfirm::
;>@it wItemId = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@it
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
;=@it
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;> CopySystemText(0x0800 | wItemId, wTextArg0)    # its name
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;> ByteToDecimal(wConfirmChoice2, wTextArg1)
	ld a, [wConfirmChoice2]
	ld hl, wTextArg1
	call ByteToDecimal
;> GetItemData()
	ld hl, far_GetItemData
	rst $10
;> price = wConfirmChoice2 * mem16[wItemData + 1]
	ld a, [wItemData + 1]
	ld c, a
	ld a, [wItemData + 2]
	ld b, a
	ld a, [wConfirmChoice2]
	call Multiply24
;> mem16[hNumber] = price & 0xFFFF; hNumber[2] = price >> 16
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	ld a, e
	ldh [hNumber + 2], a
;> wListCursor2 = lo(price); wListPage2 = hi(price); mem[0xC8E6] = price >> 16
	ld a, l
	ld [wListCursor2], a
	ld a, h
	ld [wListPage2], a
	ld a, e
	ld [$c8e6], a
;> Number24ToDecimal(wTextArg2)
	ld hl, wTextArg2
	call Number24ToDecimal
;> PrintMenuText9(6)
	ld hl, $0006
	call PrintMenuText9
;> wMenuChoice3 = 0                     # yes
	xor a
	ld [wMenuChoice3], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopBuyShowYesNo()
;@ path: item/shop/buy
;@ Once the question is printed, shows the yes / no window.
;@ test: skip writes VRAM
ShopBuyShowYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout9(ShopYesNoLayout)
	ld de, ShopYesNoLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice3, ShopBuyYesNoCursor)
	ld de, ShopBuyYesNoCursor
	ld a, [wMenuChoice3]
	call DrawCursorAt9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopBuyYesNoInput()
;@ path: item/shop/buy
;@ Yes buys; No or B goes back to the quantity.
;@ test: skip draws to VRAM
ShopBuyYesNoInput::
;> UpdateMenuCursor9(wMenuChoice3, 2, ShopBuyYesNoCursor)
	ld de, ShopBuyYesNoCursor
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

.no
;>     DrawBuyQuantityWindow()
	call DrawBuyQuantityWindow
;>     PrintMenuText9(5)
	ld hl, $0005
	call PrintMenuText9
;>@no     wMenuSubStep -= 4               # back to the quantity input
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@no
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:        # No: as B above
;>         DrawBuyQuantityWindow(); PrintMenuText9(5); wMenuSubStep -= 4
	ld a, [wMenuChoice3]
	cp $81
	jr z, .no

;>     else:
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/shop/buy
;@ Positions of Yes and No in the yes / no window; $FFFF ends them.
ShopBuyYesNoCursor::
	dw $012f, $016f, $ffff

;@ def ShopBuyDoIt()
;@ path: item/shop/buy
;@ Buys: not enough gold (message 7) or no room in the bag for all of them (message 8, the bag
;@ holds 20), else the gold is paid and the items go at the end of the bag (message 9).
;@ test: skip uses far calls
ShopBuyDoIt::
;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;>@g price = wListCursor2 | wListPage2 << 8 | mem[0xC8E6] << 16
;> if wGold[0] | wGold[1] << 8 | wGold[2] << 16 < price:
	ld hl, wListCursor2
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [wGold + 1]
	sbc [hl]
;=@g
	inc hl
	ld a, [wGold + 2]
	sbc [hl]
;>     msg = 7                         # not enough gold
	ld hl, $0007
	jr c, .print

;> elif CountItems20(wBagItems) + wConfirmChoice2 >= 21:
	ld hl, wBagItems
	call CountItems20
	ld a, [wConfirmChoice2]
	add c
	cp $15
;>     msg = 8                         # the bag is full
	ld hl, $0008
	jr nc, .print

;> else:
;>@sg     SpendGold(price)
	ld a, [wListCursor2]
	ld l, a
	ld a, [wListPage2]
	ld h, a
	ld a, [$c8e6]
	ld e, a
;=@sg
	call SpendGold
;>@sl     slot = wBagItems + CountItems20(wBagItems)
	ld hl, wBagItems
	call CountItems20
	ld a, c
	ld hl, wBagItems
	add l
	ld l, a
;=@sl
	ld a, $00
	adc h
	ld h, a
;>     fill(slot, wItemId, wConfirmChoice2)
	ld a, [wConfirmChoice2]
	ld b, a
	ld a, [wItemId]

.add
	ld [hli], a
	dec b
	jr nz, .add

;>     msg = 9                         # thank you
	ld hl, $0009

.print
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopBuyDone()
;@ path: item/shop/buy
;@ After the message: clears the menu variables and starts buying over (step 0 asks again).
ShopBuyDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> fill(addr(wMenuChoice2), 0, 7)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;> wMenuSubStep = 0
	ld a, $00
	ld [wMenuSubStep], a
	ret


;@ def ShopSellOption()
;@ path: item/shop/sell
;@ Selling, one frame: runs step wMenuSubStep.
;@ test: skip jumps through a table
ShopSellOption::
;> return ShopSellSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: item/shop/sell
;@ Steps of selling: pick one of the item kinds in the bag, the quantity, confirm, get paid; the
;@ last two steps say there is nothing to sell.
ShopSellSteps::
	dw ShopSellStart
	dw ShopSellShowList
	dw ShopSellListInput
	dw ShopSellAskQuantity
	dw ShopSellShowQuantity
	dw ShopSellQuantityInput
	dw ShopSellAskConfirm
	dw ShopSellShowYesNo
	dw ShopSellYesNoInput
	dw ShopSellDoIt
	dw ShopSellDone
	dw ShopSellNothing
	dw ShopSellNothingClose

;@ def ShopSellStart()
;@ path: item/shop/sell
;@ Builds the list of sellable items; with none, goes to "nothing to sell", else asks what to sell.
;@ test: skip uses far calls
ShopSellStart::
;> BuildSellList()
	call BuildSellList
;> if CountItems20(wSceneObjects) == 0:
	ld hl, wSceneObjects
	call CountItems20
	ld a, c
	or a
	jr nz, .ask

;>     wMenuSubStep = 11               # ShopSellNothing
;>     return
	ld a, $0b
	ld [wMenuSubStep], a
	ret

.ask
;> PrintMenuText9(10)                   # "What will you sell?"
	ld hl, $000a
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopSellShowList()
;@ path: item/shop/sell
;@ Once the question is printed: renders the item names of the first page and draws the list with
;@ the selling prices.
;@ test: skip draws to VRAM
ShopSellShowList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> BuildSellList()
	call BuildSellList
;> CountShopList()
	call CountShopList
;> LoadItemNameTiles()
	call LoadItemNameTiles
;> DrawShopSellWindow()
	call DrawShopSellWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawShopSellWindow()
;@ path: item/shop/sell
;@ Draws the shop's main menu, the list of items to sell with their prices, page mark and cursor.
;@ test: skip writes VRAM
DrawShopSellWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawShopMainMenu()
	call DrawShopMainMenu
;> DrawWindowLayout9(ShopListLayout)
	ld de, ShopListLayout
	call DrawWindowLayout9
;> DrawSellPrices()
	call DrawSellPrices
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawListFrame9(wListCursor, ShopSellListCursor, 4, wListLength)
	ld de, ShopSellListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def DrawSellPrices()
;@ path: item/shop/sell
;@ Writes the selling price (GetSellPrice) and the gold mark of the 4 items on page wListPage.
;@ test: skip uses far calls
DrawSellPrices::
;>@i item = wSceneObjects + wListPage * 4
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
;=@i
	ld a, $00
	adc d
	ld d, a
;> pos = 0x00AD
	ld hl, $00ad
;> for _ in range(4):
;>     item, pos = DrawSellPriceSlot(item, pos)
	call DrawSellPriceSlot
	call DrawSellPriceSlot
	call DrawSellPriceSlot

;@ def DrawSellPriceSlot(item: de, pos: hl) -> (de, hl)
;@ path: item/shop/sell
;@ Like DrawBuyPriceSlot, with the price the shop pays (GetSellPrice).
;@ test: skip uses far calls
DrawSellPriceSlot::
;>@x if mem[item] in (0x00, 0xFF):
	push de
	push hl
	ld a, [de]
	cp $00
	jr z, .empty

;=@x
	cp $ff
	jr nz, .price

.empty
;>@e     fill(TilemapBufferAddr9(pos), 0xE0, 6)
	call TilemapBufferAddr9
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@e
	ld [hli], a
	ld [hli], a
	jr .next

.price
;> else:
;>     wItemId = mem[item]
	push hl
	push hl
	ld a, [de]
	ld [wItemId], a
;>@n     mem16[hNumber] = GetSellPrice(); hNumber[2] = 0
	call GetSellPrice
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	ld a, $00
;=@n
	ldh [hNumber + 2], a
;>     PrintNumber5(TilemapBufferAddr9(pos))
	pop hl
	call TilemapBufferAddr9
	call PrintNumber5
;>@g     mem[TilemapBufferAddr9(pos + 5)] = 0xDD # gold mark
	pop hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
;=@g
	ld h, a
	call TilemapBufferAddr9
	ld [hl], $dd

.next
;>@r return item + 1, pos + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret


;@ def GetSellPrice() -> hl
;@ path: item/shop/sell
;@ What the shop pays for item wItemId: the full price at the shop of map $50; for items $18-$1C,
;@ $25 and $27 a tenth of their price; for all others three quarters (price - price / 4).
;@ test: skip far call
GetSellPrice::
;> GetItemData()
	ld hl, far_GetItemData
	rst $10
;> price = mem16[wItemData + 1]
	ld a, [wItemData + 1]
	ld l, a
	ld a, [wItemData + 2]
	ld h, a
;> if wMapId == 0x50:
;>     return price
	ld a, [wMapId]
	cp $50
	ret z

;>@ten if wItemId in (0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x25, 0x27):
	ld a, [wItemId]
	cp $18
	jr z, .tenth

	cp $19
	jr z, .tenth

;=@ten
	cp $1a
	jr z, .tenth

	cp $1b
	jr z, .tenth

	cp $1c
	jr z, .tenth

;=@ten
	cp $25
	jr z, .tenth

	cp $27
	jr z, .tenth

	jr .quarter

.tenth
;>@t     return Divide16(price, 10)[0]
	ld a, [wItemData + 1]
	ld l, a
	ld a, [wItemData + 2]
	ld h, a
	ld a, $0a
	call Divide16
;=@t
	ret

.quarter
;>@q return price - (price >> 2)
	ld a, [wItemData + 1]
	ld l, a
	ld a, [wItemData + 2]
	ld h, a
	srl h
	rr l
;=@q
	srl h
	rr l
	ld a, [wItemData + 1]
	sub l
	ld l, a
	ld a, [wItemData + 2]
;=@q
	sbc h
	ld h, a
	ret


;@ def BuildSellList()
;@ path: item/shop/sell
;@ Packs the bag, counts how many of each item kind it holds (in wBreedParent1, used as a count per
;@ item number) leaving out the items that cannot be sold (ItemData byte 11 bit 0), and writes the
;@ item numbers found ($01-$2F, in order) into wSceneObjects.
;@ test: skip uses far calls
BuildSellList::
;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;> fill(wBreedParent1, 0, 0x30)         # count per item number
	ld hl, wBreedParent1
	ld bc, $0030
	xor a
	call FillMemory
;> fill(wSceneObjects, 0, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	xor a
	call FillMemory
;> for slot in range(20):
	ld de, wBagItems
	ld b, $14

.count
;>     item = wBagItems[slot]
;>     if item in (0x00, 0xFF):
	ld a, [de]
	or a
	jr z, .list

	cp $ff
	jr z, .list

;>         break
;>     wItemId = item
	ld [wItemId], a
;>@ct     count = wBreedParent1 + item
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@gd     GetItemData()
	push hl
	push de
	push bc
	ld hl, far_GetItemData
	rst $10
;=@gd
	pop bc
	pop de
	pop hl
	inc de
;>     if not wItemData[11] & 0x01:    # can be sold
;>         mem[count] += 1
	ld a, [wItemData + 11]
	bit 0, a
	jr nz, .nextSlot

	inc [hl]

.nextSlot
	dec b
	jr nz, .count

.list
;> dest = wSceneObjects
	ld hl, wBreedParent1 + 1
	ld de, wSceneObjects
;>@lp for item in range(1, 0x30):
	ld b, $2f
	ld c, $01

.find
;>     if wBreedParent1[item]:
	ld a, [hli]
	or a
	jr z, .notOwned

;>         mem[dest] = item; dest += 1
	ld a, c
	ld [de], a
	inc de

.notOwned
;=@lp
	inc c
	dec b
	jr nz, .find

	ret


;@ def ShopSellListInput()
;@ path: item/shop/sell
;@ The list of items to sell: as ShopBuyListInput (B back to the main menu, A takes the item and
;@ starts the quantity at 1).
;@ test: skip draws to VRAM
ShopSellListInput::
;>@op old_page = wListPage
	ld de, ShopSellListCursor
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@op
	ld a, [hld]
	push af
;> old_row = wListCursor
	ld a, [hl]
	push af
;> UpdatePagedList9(wListCursor, ShopSellListCursor, 4, wListLength)
	call UpdatePagedList9
;>@cmp pass                             # (the row is compared, but nothing depends on it)
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@cmp
	cp b
	jr z, .samePage

.samePage
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .buttons

;>     LoadItemNameTiles()
	call LoadItemNameTiles
;>     DrawSellPrices()
	call DrawSellPrices
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9

.buttons
;> if wJoyPressed & 0x02:              # B: back to the main menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice2 = 1             # the quantity
	ld a, $01
	ld [wConfirmChoice2], a

.done
	ret


;@ path: item/shop/sell
;@ Cursor table of the list of items to sell (as ShopBuyListCursor).
ShopSellListCursor::
	dw $0192, $00a2, $00e2, $0122, $0162, $ffff

;@ def ShopSellAskQuantity()
;@ path: item/shop/sell
;@ Asks how many to sell; the number entry starts on the ones digit.
;@ test: skip prints text
ShopSellAskQuantity::
;> PrintMenuText9(12)
	ld hl, $000c
	call PrintMenuText9
;> wConfirmChoice = 1
	ld a, $01
	ld [wConfirmChoice], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopSellShowQuantity()
;@ path: item/shop/sell
;@ Once the question is printed, shows the quantity window.
;@ test: skip draws to VRAM
ShopSellShowQuantity::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawSellQuantityWindow()
	call DrawSellQuantityWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawSellQuantityWindow()
;@ path: item/shop/sell
;@ Draws the list with the chosen row and the quantity window: the quantity to sell (two digits)
;@ next to the number of that item in the bag.
;@ test: skip writes VRAM
DrawSellQuantityWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawShopMainMenu()
	call DrawShopMainMenu
;> DrawWindowLayout9(ShopListLayout)
	ld de, ShopListLayout
	call DrawWindowLayout9
;> DrawSellPrices()
	call DrawSellPrices
;> DrawListFrame9(wListCursor, ShopSellListCursor, 4, wListLength)
	ld de, ShopSellListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> DrawWindowLayout9(SellQuantityLayout)
	ld de, SellQuantityLayout
	call DrawWindowLayout9
;>@it wItemId = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@it
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
;=@it
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;>@ow PrintNumber2(wBreedParent1[wItemId], TilemapBufferAddr9(0x0164))   # how many are carried
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@ow
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call TilemapBufferAddr9
	call PrintNumber2
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawNumberEntry(wConfirmChoice, wConfirmChoice, ShopSellDigitCursor)
	ld de, ShopSellDigitCursor
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def ShopSellQuantityInput()
;@ path: item/shop/sell
;@ The quantity, at most the number carried: B starts selling over, A goes on.
;@ test: skip draws to VRAM
ShopSellQuantityInput::
;>@u UpdateNumberEntry(wConfirmChoice, ShopSellDigitCursor, 2, wBreedParent1[wItemId])
	ld de, ShopSellDigitCursor
	ld hl, wBreedParent1
	ld a, [wItemId]
	add l
	ld l, a
	ld a, $00
;=@u
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, wConfirmChoice
	call UpdateNumberEntry
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     DrawShopSellWindow()
	call DrawShopSellWindow
;>@b     wMenuSubStep -= 5               # back to ShopSellStart
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@b
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/shop/sell
;@ Positions of the two quantity digits in the sell quantity window.
ShopSellDigitCursor::
	dw $0161, $0162, $ffff

;@ def ShopSellAskConfirm()
;@ path: item/shop/sell
;@ Works out what the shop pays (quantity x GetSellPrice, kept in wListCursor2..$C8E6) and asks
;@ "<quantity> <item> for <price> gold?".
;@ test: skip uses far calls
ShopSellAskConfirm::
;> CopySystemText(0x0800 | wItemId, wTextArg0)
	ld a, [wItemId]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
;> ByteToDecimal(wConfirmChoice2, wTextArg1)
	ld a, [wConfirmChoice2]
	ld hl, wTextArg1
	call ByteToDecimal
;> price = wConfirmChoice2 * GetSellPrice()
	call GetSellPrice
	ld c, l
	ld b, h
	ld a, [wConfirmChoice2]
	call Multiply24
;> mem16[hNumber] = price & 0xFFFF; hNumber[2] = price >> 16
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	ld a, e
	ldh [hNumber + 2], a
;> wListCursor2 = lo(price); wListPage2 = hi(price); mem[0xC8E6] = price >> 16
	ld a, l
	ld [wListCursor2], a
	ld a, h
	ld [wListPage2], a
	ld a, e
	ld [$c8e6], a
;> Number24ToDecimal(wTextArg2)
	ld hl, wTextArg2
	call Number24ToDecimal
;> PrintMenuText9(13)
	ld hl, $000d
	call PrintMenuText9
;> wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopSellShowYesNo()
;@ path: item/shop/sell
;@ Once the question is printed, shows the yes / no window.
;@ test: skip writes VRAM
ShopSellShowYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout9(ShopYesNoLayout)
	ld de, ShopYesNoLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice3, ShopSellYesNoCursor)
	ld de, ShopSellYesNoCursor
	ld a, [wMenuChoice3]
	call DrawCursorAt9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopSellYesNoInput()
;@ path: item/shop/sell
;@ Yes sells; No or B goes back to the quantity.
;@ test: skip draws to VRAM
ShopSellYesNoInput::
;> UpdateMenuCursor9(wMenuChoice3, 2, ShopSellYesNoCursor)
	ld de, ShopSellYesNoCursor
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

.no
;>     DrawSellQuantityWindow()
	call DrawSellQuantityWindow
;>@no     wMenuSubStep -= 5               # back to ShopSellAskQuantity's next step
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@no
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:        # No: as B
;>         DrawSellQuantityWindow(); wMenuSubStep -= 5
	ld a, [wMenuChoice3]
	cp $81
	jr z, .no

;>     else:
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/shop/sell
;@ Positions of Yes and No.
ShopSellYesNoCursor::
	dw $012f, $016f, $ffff

;@ def ShopSellDoIt()
;@ path: item/shop/sell
;@ Sells: if the purse would reach 100,000 gold the shop refuses (message 14), else the gold is paid
;@ and the items leave the bag (message 15).
;@ test: skip uses far calls
ShopSellDoIt::
;>@s total = wGold[0] | wGold[1] << 8 | wGold[2] << 16
;>@s total += wListCursor2 | wListPage2 << 8 | mem[0xC8E6] << 16
	ld hl, wListCursor2
	ld a, [wGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [wGold + 1]
;=@s
	adc [hl]
	ld d, a
	inc hl
	ld a, [wGold + 2]
	adc [hl]
	ld c, a
;> if total >= 100000:
	ld a, e
	sub $a0
	ld a, d
	sbc $86
	ld a, c
	sbc $01
;>     msg = 14                        # the purse is full
	ld hl, $000e
	jr nc, .print

;> else:
;>@ag     AddGold(wListCursor2 | wListPage2 << 8 | mem[0xC8E6] << 16)
	ld a, [wListCursor2]
	ld l, a
	ld a, [wListPage2]
	ld h, a
	ld a, [$c8e6]
	ld e, a
;=@ag
	call AddGold
;>     for _ in range(wConfirmChoice2):
	ld a, [wConfirmChoice2]
	ld b, a

.remove
;>         RemoveItemFromBag()         # removes one wItemId
	push bc
	ld hl, far_RemoveItemFromBag
	rst $10
	pop bc
	dec b
	jr nz, .remove

;>     msg = 15
	ld hl, $000f

.print
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopSellDone()
;@ path: item/shop/sell
;@ After the message: clears the menu variables and starts selling over.
ShopSellDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> fill(addr(wMenuChoice2), 0, 7)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;> wMenuSubStep = 0
	ld a, $00
	ld [wMenuSubStep], a
	ret


;@ def ShopSellNothing()
;@ path: item/shop/sell
;@ "You have nothing to sell" (message 11).
;@ test: skip prints text
ShopSellNothing::
;> PrintMenuText9(11)
	ld hl, $000b
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ShopSellNothingClose()
;@ path: item/shop/sell
;@ After that message, back to Buy / Sell / Quit.
;@ test: skip prints text
ShopSellNothingClose::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def VaultMenu()
;@ path: item/vault
;@ The vault (script menu 2), where items and gold are left and taken back; one frame.
;@ test: skip jumps through a table
VaultMenu::
;> return VaultSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: item/vault
;@ Steps of the vault: set up, Deposit / Withdraw / Quit, Items / Gold / Quit, the chosen action,
;@ close.
VaultSteps::
	dw VaultInit
	dw VaultOpenMenu
	dw VaultMainMenuInput
	dw VaultOpenWhatMenu
	dw VaultWhatMenuInput
	dw VaultRunOption
	dw VaultClose

;@ def VaultInit()
;@ path: item/vault
;@ As ShopInit, with the vault's window graphics (bank $2E entry $0F).
;@ test: skip decompresses graphics
VaultInit::
;> SnapToTile9(hScrollX)
	ld hl, hScrollX
	call SnapToTile9
;> SnapToTile9(hScrollY)
	ld hl, hScrollY
	call SnapToTile9
;> fill(addr(wMenuChoice), 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@m map = 0x9800 + (hScrollY // 8) * 32 + hScrollX // 8
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@m
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
;=@m
	adc $98
	ld h, a
;>@s wWindowBgMap = (map & 0x3FF) | 0x9800
	ld a, h
	and $03
	or $98
	ld h, a
;=@s
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DecompressVRAM(0x2E, 0x0F, 0x8800)
	ld de, $2e0f
	ld hl, $8800
	call DecompressVRAM
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def VaultOpenMenu()
;@ path: item/vault
;@ Once the greeting is printed, draws Deposit / Withdraw / Quit.
;@ test: skip writes VRAM
VaultOpenMenu::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultMainMenu()
	call DrawVaultMainMenu
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def DrawVaultMainMenu()
;@ path: item/vault
;@ Renders the menu words (system text $020B) into tiles $8A40 and draws the vault's menu window,
;@ the gold window with the purse and the message window, cursor at wMenuChoice.
;@ test: skip far call
DrawVaultMainMenu::
;> wTextGroup = 2
;> wTextIndex = 0x0B
	ld a, $02
	ld [wTextGroup], a
	ld a, $0b
	ld [wTextIndex], a
;> DrawTextTiles9(0x8A40, 1, 12)
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
;> DrawWindowLayout9(VaultMainMenuLayout)
	ld de, VaultMainMenuLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(GoldWindowLayout)
	ld de, GoldWindowLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(0x2E07)            # message window (bank 0)
	ld de, $2e07
	call DrawWindowLayout9
;> copy(hNumber, wGold, 3)
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(TilemapBufferAddr9(0x2E))
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice, VaultMainMenuCursor)
	ld de, VaultMainMenuCursor
	ld a, [wMenuChoice]
	call DrawCursorAt9
	ret


;@ def VaultMainMenuInput()
;@ path: item/vault
;@ Deposit / Withdraw / Quit: B, Start or Quit close the vault; Deposit or Withdraw ask what
;@ (message 3 or 14).
;@ test: skip draws to VRAM
VaultMainMenuInput::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> UpdateMenuCursor9(wMenuChoice, 3, VaultMainMenuCursor)
	ld de, VaultMainMenuCursor
	ld hl, wMenuChoice
	ld b, $03
	call UpdateMenuCursor9
;> if wJoyPressed & 0x0A:               # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .checkA

;>@c     wMenuStep += 4                  # VaultClose
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
;=@c
	ld hl, wMenuStep
	inc [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice == 0x82:         # Quit
;>         return VaultClose()
	ld a, [wMenuChoice]
	cp $82
	jp z, VaultClose

;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;>     wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;>     wMenuChoice |= 0x80
	ld hl, wMenuChoice
	set 7, [hl]
;>     fill(addr(wMenuChoice2), 0, 7)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>@pm     PrintMenuText9(3 if (wMenuChoice & 0x7F) == 0 else 14)
	ld hl, $0003
	ld a, [wMenuChoice]
	and $7f
	jr z, .print

	ld hl, $000e

.print
;=@pm
	call PrintMenuText9
	jr .done

.done
	ret


;@ path: item/vault
;@ Positions of Deposit, Withdraw, Quit; $FFFF ends them.
VaultMainMenuCursor::
	dw $0021, $0061, $00a1, $ffff

;@ def VaultOpenWhatMenu()
;@ path: item/vault
;@ Once the question is printed, draws Items / Gold / Quit and renders its words (system text
;@ $020C) into the tiles.
;@ test: skip far call
VaultOpenWhatMenu::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wTextGroup = 2
;> wTextIndex = 0x0C
	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
;> DrawTextTiles9(0x8A40, 1, 12)
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
	ret


;@ def DrawVaultWhatMenu()
;@ path: item/vault
;@ Draws the Items / Gold / Quit window (the same layout, other words in its tiles), the gold
;@ window and the message window; cursor at wMenuChoice2.
;@ test: skip uses the home number routines
DrawVaultWhatMenu::
;> DrawWindowLayout9(VaultMainMenuLayout)
	ld de, VaultMainMenuLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(GoldWindowLayout)
	ld de, GoldWindowLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(0x2E07)
	ld de, $2e07
	call DrawWindowLayout9
;> copy(hNumber, wGold, 3)
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(TilemapBufferAddr9(0x2E))
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice2, VaultWhatMenuInput.cursorTable)
	ld de, VaultWhatMenuInput.cursorTable
	ld a, [wMenuChoice2]
	call DrawCursorAt9
	ret


;@ def VaultWhatMenuInput()
;@ path: item/vault
;@ Items / Gold / Quit: B or Start go back to Deposit / Withdraw / Quit, A picks (Quit closes the
;@ vault through VaultDepositTable / VaultWithdrawTable). Its cursor table sits in the middle of
;@ the code (.cursorTable).
;@ test: skip draws to VRAM
VaultWhatMenuInput::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> UpdateMenuCursor9(wMenuChoice2, 3, VaultWhatMenuInput.cursorTable)
	ld de, .cursorTable
	ld hl, wMenuChoice2
	ld b, $03
	call UpdateMenuCursor9
;> if wJoyPressed & 0x0A:               # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .checkA

;>     RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;>     DrawVaultMainMenu()
	call DrawVaultMainMenu
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;>     wMenuStep -= 2
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	jr .done

.cursorTable                             ; Items, Gold, Quit
	dw $0021, $0061, $00a1, $ffff

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;>     wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;>     wMenuChoice2 |= 0x80
	ld hl, wMenuChoice2
	set 7, [hl]
;>     fill(addr(wConfirmChoice), 0, 6)
	ld hl, wConfirmChoice
	ld bc, $0006
	ld a, $00
	call FillMemory
;>     fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory

.done
	ret


;@ def VaultRunOption()
;@ path: item/vault
;@ Runs Deposit or Withdraw.
;@ test: skip jumps through a table
VaultRunOption::
;> return VaultDirectionTable[wMenuChoice & 0x7F]()
	ld a, [wMenuChoice]
	rst $00

;@ path: item/vault
;@ Deposit, Withdraw.
VaultDirectionTable::
	dw VaultDepositOption
	dw VaultWithdrawOption

;@ def VaultDepositOption()
;@ path: item/vault
;@ Deposit: items, gold or quit.
;@ test: skip jumps through a table
VaultDepositOption::
;> return VaultDepositTable[wMenuChoice2 & 0x7F]()
	ld a, [wMenuChoice2]
	rst $00

;@ path: item/vault
;@ Deposit an item, deposit gold, quit.
VaultDepositTable::
	dw VaultStoreItem
	dw VaultDepositGold
	dw VaultClose

;@ def VaultWithdrawOption()
;@ path: item/vault
;@ Withdraw: items, gold or quit.
;@ test: skip jumps through a table
VaultWithdrawOption::
;> return VaultWithdrawTable[wMenuChoice2 & 0x7F]()
	ld a, [wMenuChoice2]
	rst $00

;@ path: item/vault
;@ Take an item back, withdraw gold, quit.
VaultWithdrawTable::
	dw VaultTakeItem
	dw VaultWithdrawGold
	dw VaultClose

;@ def VaultClose()
;@ path: item/vault
;@ Leaves the vault: the field picture comes back and the field runs again.
;@ test: skip writes VRAM
VaultClose::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawWindowLayout9(0x2E07)
	ld de, $2e07
	call DrawWindowLayout9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def VaultStoreItem()
;@ path: item/vault/items
;@ Leaving items in the vault, one frame: runs step wMenuSubStep.
;@ test: skip jumps through a table
VaultStoreItem::
;> return VaultStoreItemSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: item/vault/items
;@ Steps of leaving items: check there is something to leave and room for it, pick the item kind
;@ from the bag, the quantity, store them, start over / finish.
VaultStoreItemSteps::
	dw VaultStoreItemStart
	dw VaultStoreItemShowList
	dw VaultStoreListInput
	dw VaultStoreAskQuantity
	dw VaultStoreShowQuantity
	dw VaultStoreQuantityInput
	dw VaultStoreDoIt
	dw VaultStoreDone
	dw VaultStoreFinish

;@ def VaultStoreItemStart()
;@ path: item/vault/items
;@ An empty bag (message 5) or a full vault (40 items, message 6) ends it; else asks which item
;@ (message 4).
;@ test: skip prints text
VaultStoreItemStart::
;> if CountItems40(wBagItems) == 0:
;>     msg = 5                         # nothing to leave
	ld hl, wBagItems
	call CountItems40
	ld a, c
	or a
	ld hl, $0005
	jr z, .refuse

;>@f elif CountItemsN(wStoredItems, 40) >= 40:
;>     msg = 6                         # the vault is full
	ld hl, wStoredItems
	ld b, $28
	call CountItemsN
	ld a, c
	cp $28
	ld hl, $0006
;=@f
	jr nc, .refuse

;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     PrintMenuText9(4)
;>     return
	ld hl, $0004
	call PrintMenuText9
	ret

.refuse
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep = 8                     # VaultStoreFinish
	ld a, $08
	ld [wMenuSubStep], a
	ret


;@ def VaultStoreItemShowList()
;@ path: item/vault/items
;@ Once the question is printed: lists the item kinds in the bag and draws the list.
;@ test: skip draws to VRAM
VaultStoreItemShowList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> BuildBagItemList()
	call BuildBagItemList
;> CountVaultList()
	call CountVaultList
;> LoadItemNameTiles()
	call LoadItemNameTiles
;> DrawVaultStoreWindow()
	call DrawVaultStoreWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret

;@ def DrawVaultStoreWindow()
;@ path: item/vault/items
;@ Draws the Items / Gold / Quit menu and the item list window with page mark and cursor.
;@ test: skip writes VRAM
DrawVaultStoreWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> DrawWindowLayout9(VaultItemListLayout)
	ld de, VaultItemListLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawListFrame9(wListCursor, VaultStoreListCursor, 4, wListLength)
	ld de, VaultStoreListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret

;@ def BuildBagItemList()
;@ path: item/vault/items
;@ Like BuildSellList, without the "cannot be sold" check: packs the bag, counts each item kind in
;@ wBreedParent1 (one count per item number) and lists the kinds carried ($01-$2F, in order) in
;@ wSceneObjects.
;@ test: skip far call
BuildBagItemList::
;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;> fill(wBreedParent1, 0, 0x30)
	ld hl, wBreedParent1
	ld bc, $0030
	xor a
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	ld hl, wSceneObjects
	ld bc, $0028
	xor a
	call FillMemory
;> for slot in range(20):
	ld de, wBagItems
	ld b, $14

.count
;>     item = wBagItems[slot]
;>     if item in (0x00, 0xFF):
	ld a, [de]
	or a
	jr z, .list

	cp $ff
	jr z, .list

;>         break
;>     wItemId = item
	ld [wItemId], a
;>@c     wBreedParent1[item] += 1
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@c
	inc de
	inc [hl]
	dec b
	jr nz, .count

.list
;> dest = wSceneObjects
	ld hl, wBreedParent1 + 1
	ld de, wSceneObjects
;>@lp for item in range(1, 0x30):
	ld b, $2f
	ld c, $01

.find
;>     if wBreedParent1[item]:
	ld a, [hli]
	or a
	jr z, .notCarried

;>         mem[dest] = item; dest += 1
	ld a, c
	ld [de], a
	inc de

.notCarried
;=@lp
	inc c
	dec b
	jr nz, .find

	ret

;@ def CountVaultList()
;@ path: item/vault/items
;@ wListLength = number of entries in the list in wSceneObjects (up to 40).
CountVaultList::
;> wListLength = CountItems40(wSceneObjects)
	ld hl, wSceneObjects
	call CountItems40
	ld a, c
	ld [wListLength], a
	ret


;@ def CountItems40(items: hl) -> c
;@ path: item/bag
;@ Counts the entries of a list of up to 40 (the vault's size) before the first 0 or $FF.
CountItems40::
;> return CountItemsN(items, 40)
	ld b, $28

;@ def CountItemsN(items: hl, size: b) -> c
;@ path: item/bag
;@ Counts the entries of a list of up to `size` before the first 0 or $FF.
CountItemsN::
;> n = 0
	ld c, $00

.loop
;> while n < size and mem[items + n] not in (0x00, 0xFF):
	ld a, [hli]
	cp $00
	ret z

	cp $ff
	ret z

;>     n += 1
	inc c
	dec b
	jr nz, .loop

;> return n
	ret


;@ def VaultStoreListInput()
;@ path: item/vault/items
;@ The list of item kinds in the bag: Left / Right page (only the names change), Up / Down pick,
;@ B goes back to Items / Gold / Quit, A takes the item and starts the quantity at 1.
;@ test: skip draws to VRAM
VaultStoreListInput::
;>@op old_page = wListPage
	ld de, VaultStoreListCursor
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@op
	ld a, [hld]
	push af
;> old_row = wListCursor
	ld a, [hl]
	push af
;> UpdatePagedList9(wListCursor, VaultStoreListCursor, 4, wListLength)
	call UpdatePagedList9
;>@cmp pass                             # (the row is compared, but nothing depends on it)
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@cmp
	cp b
	jr z, .samePage

.samePage
;> if wListPage != old_page:
;>     LoadItemNameTiles()
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .buttons

	call LoadItemNameTiles

.buttons
;> if wJoyPressed & 0x02:              # B: back to Items / Gold / Quit
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     wTextGroup = 2
;>     wTextIndex = 0x0C
	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
;>     DrawTextTiles9(0x8A40, 1, 12)
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
;>     RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;>     DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     PrintMenuText9(3)
	ld hl, $0003
	call PrintMenuText9
;>     wMenuStep = 4
	ld a, $04
	ld [wMenuStep], a
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wMenuChoice3 = 1                # the quantity
	ld a, $01
	ld [wMenuChoice3], a

.done
	ret

;@ path: item/vault/items
;@ Cursor table of the vault's item lists: page-number position, then the 4 rows; $FFFF ends it.
VaultStoreListCursor::
	dw $0172, $0089, $00c9, $0109, $0149, $ffff

;@ def VaultStoreAskQuantity()
;@ path: item/vault/items
;@ Asks how many (message 7); the digit cursor starts on the ones.
;@ test: skip prints text
VaultStoreAskQuantity::
;> PrintMenuText9(7)
	ld hl, $0007
	call PrintMenuText9
;> wConfirmChoice2 = 1                  # digit cursor
	ld a, $01
	ld [wConfirmChoice2], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret

;@ def VaultStoreShowQuantity()
;@ path: item/vault/items
;@ Once the question is printed, shows the quantity window.
;@ test: skip draws to VRAM
VaultStoreShowQuantity::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawVaultStoreQuantity()
	call DrawVaultStoreQuantity
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret

;@ def DrawVaultStoreQuantity()
;@ path: item/vault/items
;@ Draws the item list with the chosen row and the quantity window (the quantity wMenuChoice3
;@ next to the number carried).
;@ test: skip writes VRAM
DrawVaultStoreQuantity::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> DrawWindowLayout9(VaultItemListLayout)
	ld de, VaultItemListLayout
	call DrawWindowLayout9
;> DrawListFrame9(wListCursor, VaultStoreListCursor, 4, wListLength)
	ld de, VaultStoreListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> DrawWindowLayout9(SellQuantityLayout)
	ld de, SellQuantityLayout
	call DrawWindowLayout9
;>@it wItemId = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@it
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
;=@it
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;>@ow PrintNumber2(wBreedParent1[wItemId], TilemapBufferAddr9(0x0164))
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@ow
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call TilemapBufferAddr9
	call PrintNumber2
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawNumberEntry(wConfirmChoice2, wConfirmChoice2, VaultStoreDigitCursor)
	ld de, VaultStoreDigitCursor
	ld hl, wConfirmChoice2
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret

;@ def VaultStoreQuantityInput()
;@ path: item/vault/items
;@ The quantity, at most the number carried: B goes back to the list, A goes on.
;@ test: skip draws to VRAM
VaultStoreQuantityInput::
;>@u UpdateNumberEntry(wConfirmChoice2, VaultStoreDigitCursor, 2, wBreedParent1[wItemId])
	ld de, VaultStoreDigitCursor
	ld hl, wBreedParent1
	ld a, [wItemId]
	add l
	ld l, a
	ld a, $00
;=@u
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, wConfirmChoice2
	call UpdateNumberEntry
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     DrawVaultStoreWindow()
	call DrawVaultStoreWindow
;>     PrintMenuText9(4)
	ld hl, $0004
	call PrintMenuText9
;>@b     wMenuSubStep -= 4               # back to the list input
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@b
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret

;@ path: item/vault/items
;@ Positions of the two quantity digits.
VaultStoreDigitCursor::
	dw $0161, $0162, $ffff

;@ def VaultStoreDoIt()
;@ path: item/vault/items
;@ Stores the items: if they would not all fit in the vault's 40 places, message 8; else each one
;@ leaves the bag and goes into the vault (message 9).
;@ test: skip far call
VaultStoreDoIt::
;>@f if CountItemsN(wStoredItems, 40) + wMenuChoice3 >= 41:
;>     msg = 8                         # no room
	ld hl, wStoredItems
	ld b, $28
	call CountItemsN
	ld a, [wMenuChoice3]
	add c
	cp $29
;=@f
	ld hl, $0008
	jr nc, .print

;> else:
;>     for _ in range(wMenuChoice3):
	ld a, [wMenuChoice3]
	ld b, a

.loop
;>         RemoveItemFromBag()
	push bc
	ld hl, far_RemoveItemFromBag
	rst $10
;>         StoreItem()
	call StoreItem
	pop bc
	dec b
	jr nz, .loop

;>     msg = 9
	ld hl, $0009

.print
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret

;@ def VaultStoreDone()
;@ path: item/vault/items
;@ After the message: clears the menu variables and starts over (step 0 checks and asks again).
VaultStoreDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> fill(addr(wConfirmChoice), 0, 6)
	ld hl, wConfirmChoice
	ld bc, $0006
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;> wMenuSubStep = 0
	ld a, $00
	ld [wMenuSubStep], a
	ret

;@ def VaultStoreFinish()
;@ path: item/vault/items
;@ After a refusal: back to Deposit / Withdraw / Quit.
;@ test: skip prints text
VaultStoreFinish::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret

;@ def VaultDepositGold()
;@ path: item/vault/gold
;@ Depositing gold, one frame: runs step wMenuSubStep. The amount being entered is a 24-bit number
;@ in wLinkRefused, wLinkPartnerChoice, wListLastRows ($C8DF-$C8E1, shared menu scratch).
;@ test: skip jumps through a table
VaultDepositGold::
;> return VaultDepositGoldSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: item/vault/gold
;@ Steps of depositing gold: ask, show the amount entry, enter it, pay in, finish.
VaultDepositGoldSteps::
	dw VaultDepositGoldStart
	dw VaultDepositGoldShow
	dw VaultDepositGoldInput
	dw VaultDepositGoldDoIt
	dw VaultDepositGoldDone

;@ def VaultDepositGoldStart()
;@ path: item/vault/gold
;@ Asks how much (message 10); the amount starts at 0 with the cursor on the hundreds digit.
;@ test: skip prints text
VaultDepositGoldStart::
;> PrintMenuText9(10)
	ld hl, $000a
	call PrintMenuText9
;> wConfirmChoice = 2                   # digit cursor: the hundreds
	ld a, $02
	ld [wConfirmChoice], a
;> amount = 0
	ld a, $00
	ld [wLinkRefused], a
	ld a, $00
	ld [wLinkPartnerChoice], a
	ld a, $00
	ld [wListLastRows], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def VaultDepositGoldShow()
;@ path: item/vault/gold
;@ Once the question is printed, shows the amount entry.
;@ test: skip draws to VRAM
VaultDepositGoldShow::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawDepositGoldWindow()
	call DrawDepositGoldWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawDepositGoldWindow()
;@ path: item/vault/gold
;@ Draws Items / Gold / Quit, the window with the gold kept in the vault (6 digits, its label is
;@ system text $0255 rendered into tiles $8A00) and the 5-digit amount entry.
;@ test: skip writes VRAM
DrawDepositGoldWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> wTextGroup = 2
;> wTextIndex = 0x55
	ld a, $02
	ld [wTextGroup], a
	ld a, $55
	ld [wTextIndex], a
;> DrawTextTiles9(0x8A00, 1, 4)
	ld hl, $8a00
	ld de, $0401
	call DrawTextTiles9
;> DrawWindowLayout9(BankedGoldLayout)
	ld de, BankedGoldLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(GoldEntryLayout)
	ld de, GoldEntryLayout
	call DrawWindowLayout9
;> copy(hNumber, wBankedGold, 3)
	ld a, [wBankedGold]
	ldh [hNumber], a
	ld a, [wBankedGold + 1]
	ldh [hNumber + 1], a
	ld a, [wBankedGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber6(TilemapBufferAddr9(0x016D))
	ld hl, $016d
	call TilemapBufferAddr9
	call PrintNumber6
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawGoldEntry(wConfirmChoice, DepositGoldDigitCursor)
	ld de, DepositGoldDigitCursor
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawGoldEntry
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def VaultDepositGoldInput()
;@ path: item/vault/gold
;@ The amount entry (the top three of its five digits can be changed, so deposits go in hundreds):
;@ B goes back to Items / Gold / Quit, A with a nonzero amount goes on (amount: the 24-bit number in
;@ $C8DF-$C8E1).
;@ test: skip draws to VRAM
VaultDepositGoldInput::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;> UpdateGoldEntry(wConfirmChoice, DepositGoldDigitCursor, 3)
	ld de, DepositGoldDigitCursor
	ld hl, wConfirmChoice
	ld b, $03
	call UpdateGoldEntry
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     wTextGroup = 2
;>     wTextIndex = 0x0C
	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
;>     DrawTextTiles9(0x8A40, 1, 12)
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
;>     RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;>     DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     PrintMenuText9(3)
	ld hl, $0003
	call PrintMenuText9
;>     wMenuStep = 4
	ld a, $04
	ld [wMenuStep], a
	jr .done

.checkA
;>@a elif wJoyPressed & 0x01 and amount != 0:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

	ld hl, wLinkRefused
	ld a, [hli]
	or [hl]
;=@a
	inc hl
	or [hl]
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/vault/gold
;@ Positions of the five digits of the gold amount entry; $FFFF ends them.
DepositGoldDigitCursor::
	dw $008e, $008f, $0090, $0091, $0092, $ffff

;@ def VaultDepositGoldDoIt()
;@ path: item/vault/gold
;@ Pays the amount in: not that much gold carried (message 11), or the vault would reach 1,000,000
;@ (message 12); else it moves from the purse to the vault (message 13). amount: the 24-bit number
;@ in $C8DF-$C8E1.
;@ test: skip uses the home gold routines
VaultDepositGoldDoIt::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;>@g if wGold[0] | wGold[1] << 8 | wGold[2] << 16 < amount:
	ld hl, wLinkRefused
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [wGold + 1]
	sbc [hl]
;=@g
	inc hl
	ld a, [wGold + 2]
	sbc [hl]
;>     msg = 11
	ld hl, $000b
	jr c, .print

;>@v elif (wBankedGold[0] | wBankedGold[1] << 8 | wBankedGold[2] << 16) + amount >= 1000000:
	ld hl, wLinkRefused
	ld a, [wBankedGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [wBankedGold + 1]
;=@v
	adc [hl]
	ld d, a
	inc hl
	ld a, [wBankedGold + 2]
	adc [hl]
	ld c, a
;=@v
	ld a, e
	sub $40
	ld a, d
	sbc $42
	ld a, c
	sbc $0f
;>     msg = 12
	ld hl, $000c
	jr nc, .print

;> else:
;>@sp     SpendGold(amount)
	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
;=@sp
	call SpendGold
;>@ab     AddBankGold(amount)
	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
;=@ab
	call AddBankGold
;>     DrawDepositGoldWindow()
	call DrawDepositGoldWindow
;>     msg = 13
	ld hl, $000d

.print
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def VaultDepositGoldDone()
;@ path: item/vault/gold
;@ After the message: back to Deposit / Withdraw / Quit.
;@ test: skip writes VRAM
VaultDepositGoldDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultMainMenu()
	call DrawVaultMainMenu
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def VaultTakeItem()
;@ path: item/vault/items
;@ Taking items back from the vault, one frame: runs step wMenuSubStep.
;@ test: skip jumps through a table
VaultTakeItem::
;> return VaultTakeItemSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: item/vault/items
;@ Steps of taking items back: check, pick the item kind, the quantity, take them, start over /
;@ finish.
VaultTakeItemSteps::
	dw VaultTakeItemStart
	dw VaultTakeItemShowList
	dw VaultTakeListInput
	dw VaultTakeAskQuantity
	dw VaultTakeShowQuantity
	dw VaultTakeQuantityInput
	dw VaultTakeDoIt
	dw VaultTakeDone
	dw VaultTakeFinish

;@ def VaultTakeItemStart()
;@ path: item/vault/items
;@ An empty vault (message 17) or a full bag (20 items, message 18) ends it; else asks which item
;@ (message 16).
;@ test: skip prints text
VaultTakeItemStart::
;>@f if CountItemsN(wStoredItems, 40) == 0:
;>     msg = 17
	ld hl, wStoredItems
	ld b, $28
	call CountItemsN
	ld a, c
	or a
	ld hl, $0011
;=@f
	jr z, .refuse

;>@g elif CountItems40(wBagItems) >= 20:
;>     msg = 18
	ld hl, wBagItems
	call CountItems40
	ld a, c
	cp $14
	ld hl, $0012
;=@g
	jr nc, .refuse

;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     PrintMenuText9(16)
;>     return
	ld hl, $0010
	call PrintMenuText9
	ret

.refuse
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep = 8                     # VaultTakeFinish
	ld a, $08
	ld [wMenuSubStep], a
	ret


;@ def VaultTakeItemShowList()
;@ path: item/vault/items
;@ Once the question is printed: lists the item kinds in the vault and draws the list.
;@ test: skip draws to VRAM
VaultTakeItemShowList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> BuildStoredItemList()
	call BuildStoredItemList
;> CountVaultList()
	call CountVaultList
;> LoadItemNameTiles()
	call LoadItemNameTiles
;> DrawVaultTakeWindow()
	call DrawVaultTakeWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawVaultTakeWindow()
;@ path: item/vault/items
;@ Draws Items / Gold / Quit and the list of item kinds in the vault.
;@ test: skip writes VRAM
DrawVaultTakeWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> DrawWindowLayout9(VaultItemListLayout)
	ld de, VaultItemListLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawListFrame9(wListCursor, VaultTakeListCursor, 4, wListLength)
	ld de, VaultTakeListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def BuildStoredItemList()
;@ path: item/vault/items
;@ Packs the vault, counts each item kind in it (wBreedParent1, one count per item number) and lists
;@ the kinds kept ($01-$2F, in order) in wSceneObjects.
;@ test: skip calls CompactStoredItems
BuildStoredItemList::
;> CompactStoredItems()
	call CompactStoredItems
;> fill(wBreedParent1, 0, 0x30)
	ld hl, wBreedParent1
	ld bc, $0030
	xor a
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	ld hl, wSceneObjects
	ld bc, $0028
	xor a
	call FillMemory
;> for slot in range(40):
	ld de, wStoredItems
	ld b, $28

.count
;>     item = wStoredItems[slot]
;>     if item in (0x00, 0xFF):
	ld a, [de]
	or a
	jr z, .list

	cp $ff
	jr z, .list

;>         break
;>@c     wBreedParent1[item] += 1
	inc de
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	inc [hl]
	dec b
	jr nz, .count

.list
;> dest = wSceneObjects
	ld hl, wBreedParent1 + 1
	ld de, wSceneObjects
;>@lp for item in range(1, 0x30):
	ld b, $2f
	ld c, $01

.find
;>     if wBreedParent1[item]:
	ld a, [hli]
	or a
	jr z, .notKept

;>         mem[dest] = item; dest += 1
	ld a, c
	ld [de], a
	inc de

.notKept
;=@lp
	inc c
	dec b
	jr nz, .find

	ret


;@ def VaultTakeListInput()
;@ path: item/vault/items
;@ The list of item kinds in the vault: as VaultStoreListInput (B back to Items / Gold / Quit with
;@ message 14).
;@ test: skip draws to VRAM
VaultTakeListInput::
;>@op old_page = wListPage
	ld de, VaultTakeListCursor
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@op
	ld a, [hld]
	push af
;> old_row = wListCursor
	ld a, [hl]
	push af
;> UpdatePagedList9(wListCursor, VaultTakeListCursor, 4, wListLength)
	call UpdatePagedList9
;>@cmp pass                             # (the row is compared, but nothing depends on it)
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@cmp
	cp b
	jr z, .samePage

.samePage
;> if wListPage != old_page:
;>     LoadItemNameTiles()
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .buttons

	call LoadItemNameTiles

.buttons
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     wTextGroup = 2
;>     wTextIndex = 0x0C
	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
;>     DrawTextTiles9(0x8A40, 1, 12)
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
;>     RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;>     DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     PrintMenuText9(14)
	ld hl, $000e
	call PrintMenuText9
;>     wMenuStep = 4
	ld a, $04
	ld [wMenuStep], a
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wMenuChoice3 = 1                # the quantity
	ld a, $01
	ld [wMenuChoice3], a

.done
	ret


;@ path: item/vault/items
;@ Cursor table of the list of item kinds in the vault (as VaultStoreListCursor).
VaultTakeListCursor::
	dw $0172, $0089, $00c9, $0109, $0149, $ffff

;@ def VaultTakeAskQuantity()
;@ path: item/vault/items
;@ Asks how many (message 19); the digit cursor starts on the ones.
;@ test: skip prints text
VaultTakeAskQuantity::
;> PrintMenuText9(19)
	ld hl, $0013
	call PrintMenuText9
;> wConfirmChoice2 = 1
	ld a, $01
	ld [wConfirmChoice2], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def VaultTakeShowQuantity()
;@ path: item/vault/items
;@ Once the question is printed, shows the quantity window.
;@ test: skip draws to VRAM
VaultTakeShowQuantity::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawVaultTakeQuantity()
	call DrawVaultTakeQuantity
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawVaultTakeQuantity()
;@ path: item/vault/items
;@ Draws the vault's item list with the chosen row and the quantity window (the quantity
;@ wMenuChoice3 next to the number kept).
;@ test: skip writes VRAM
DrawVaultTakeQuantity::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> DrawWindowLayout9(VaultItemListLayout)
	ld de, VaultItemListLayout
	call DrawWindowLayout9
;> DrawListFrame9(wListCursor, VaultTakeListCursor, 4, wListLength)
	ld de, VaultTakeListCursor
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
;> DrawWindowLayout9(SellQuantityLayout)
	ld de, SellQuantityLayout
	call DrawWindowLayout9
;>@it wItemId = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@it
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
;=@it
	ld h, a
	ld a, [hl]
	ld [wItemId], a
;>@ow PrintNumber2(wBreedParent1[wItemId], TilemapBufferAddr9(0x0164))
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@ow
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call TilemapBufferAddr9
	call PrintNumber2
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawNumberEntry(wConfirmChoice2, wConfirmChoice2, VaultTakeDigitCursor)
	ld de, VaultTakeDigitCursor
	ld hl, wConfirmChoice2
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def VaultTakeQuantityInput()
;@ path: item/vault/items
;@ The quantity, at most the number kept: B goes back to the list, A goes on.
;@ test: skip draws to VRAM
VaultTakeQuantityInput::
;>@u UpdateNumberEntry(wConfirmChoice2, VaultTakeDigitCursor, 2, wBreedParent1[wItemId])
	ld de, VaultTakeDigitCursor
	ld hl, wBreedParent1
	ld a, [wItemId]
	add l
	ld l, a
	ld a, $00
;=@u
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, wConfirmChoice2
	call UpdateNumberEntry
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     DrawVaultTakeWindow()
	call DrawVaultTakeWindow
;>     PrintMenuText9(16)
	ld hl, $0010
	call PrintMenuText9
;>@b     wMenuSubStep -= 4               # back to the list input
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@b
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/vault/items
;@ Positions of the two quantity digits.
VaultTakeDigitCursor::
	dw $0161, $0162, $ffff

;@ def VaultTakeDoIt()
;@ path: item/vault/items
;@ Takes the items: if they would not all fit in the bag (20), message 20; else each one leaves
;@ the vault and goes into the bag (message 21).
;@ test: skip far call
VaultTakeDoIt::
;>@f if CountItems40(wBagItems) + wMenuChoice3 >= 21:
;>     msg = 20
	ld hl, wBagItems
	call CountItems40
	ld a, [wMenuChoice3]
	add c
	cp $15
	ld hl, $0014
;=@f
	jr nc, .print

;> else:
;>     for _ in range(wMenuChoice3):
	ld a, [wMenuChoice3]
	ld b, a

.loop
;>         TakeStoredItem()
	push bc
	call TakeStoredItem
;>         AddItemToBag()
	ld hl, far_AddItemToBag
	rst $10
	pop bc
	dec b
	jr nz, .loop

;>     msg = 21
	ld hl, $0015

.print
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def VaultTakeDone()
;@ path: item/vault/items
;@ After the message: clears the menu variables and starts over.
VaultTakeDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> fill(addr(wConfirmChoice), 0, 6)
	ld hl, wConfirmChoice
	ld bc, $0006
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;> wMenuSubStep = 0
	ld a, $00
	ld [wMenuSubStep], a
	ret


;@ def VaultTakeFinish()
;@ path: item/vault/items
;@ After a refusal: back to Deposit / Withdraw / Quit.
;@ test: skip prints text
VaultTakeFinish::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def VaultWithdrawGold()
;@ path: item/vault/gold
;@ Withdrawing gold, one frame: runs step wMenuSubStep (amount in $C8DF-$C8E1 as for deposits).
;@ test: skip jumps through a table
VaultWithdrawGold::
;> return VaultWithdrawGoldSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: item/vault/gold
;@ Steps of withdrawing gold: ask, show the amount entry, enter it, pay out, finish.
VaultWithdrawGoldSteps::
	dw VaultWithdrawGoldStart
	dw VaultWithdrawGoldShow
	dw VaultWithdrawGoldInput
	dw VaultWithdrawGoldDoIt
	dw VaultWithdrawGoldDone

;@ def VaultWithdrawGoldStart()
;@ path: item/vault/gold
;@ With no gold in the vault: message 15 and finish. Else asks how much (message 22), amount 0,
;@ cursor on the hundreds.
;@ test: skip prints text
VaultWithdrawGoldStart::
;> if wBankedGold[0] | wBankedGold[1] | wBankedGold[2] == 0:
	ld hl, wBankedGold
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr nz, .ask

;>     PrintMenuText9(15)
	ld hl, $000f
	call PrintMenuText9
;>     wMenuSubStep = 4                # VaultWithdrawGoldDone
;>     return
	ld a, $04
	ld [wMenuSubStep], a
	ret

.ask
;> PrintMenuText9(22)
	ld hl, $0016
	call PrintMenuText9
;> wConfirmChoice = 2
	ld a, $02
	ld [wConfirmChoice], a
;> amount = 0
	ld a, $00
	ld [wLinkRefused], a
	ld a, $00
	ld [wLinkPartnerChoice], a
	ld a, $00
	ld [wListLastRows], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def VaultWithdrawGoldShow()
;@ path: item/vault/gold
;@ Once the question is printed, shows the amount entry.
;@ test: skip draws to VRAM
VaultWithdrawGoldShow::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawWithdrawGoldWindow()
	call DrawWithdrawGoldWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawWithdrawGoldWindow()
;@ path: item/vault/gold
;@ Same windows as DrawDepositGoldWindow.
;@ test: skip writes VRAM
DrawWithdrawGoldWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;> wTextGroup = 2
;> wTextIndex = 0x55
	ld a, $02
	ld [wTextGroup], a
	ld a, $55
	ld [wTextIndex], a
;> DrawTextTiles9(0x8A00, 1, 4)
	ld hl, $8a00
	ld de, $0401
	call DrawTextTiles9
;> DrawWindowLayout9(BankedGoldLayout)
	ld de, BankedGoldLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(GoldEntryLayout)
	ld de, GoldEntryLayout
	call DrawWindowLayout9
;> copy(hNumber, wBankedGold, 3)
	ld a, [wBankedGold]
	ldh [hNumber], a
	ld a, [wBankedGold + 1]
	ldh [hNumber + 1], a
	ld a, [wBankedGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber6(TilemapBufferAddr9(0x016D))
	ld hl, $016d
	call TilemapBufferAddr9
	call PrintNumber6
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawGoldEntry(wConfirmChoice, WithdrawGoldDigitCursor)
	ld de, WithdrawGoldDigitCursor
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawGoldEntry
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def VaultWithdrawGoldInput()
;@ path: item/vault/gold
;@ The amount entry: B goes back to Items / Gold / Quit (message 14), A with a nonzero amount goes
;@ on.
;@ test: skip draws to VRAM
VaultWithdrawGoldInput::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;> UpdateGoldEntry(wConfirmChoice, WithdrawGoldDigitCursor, 3)
	ld de, WithdrawGoldDigitCursor
	ld hl, wConfirmChoice
	ld b, $03
	call UpdateGoldEntry
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

;>     wTextGroup = 2
;>     wTextIndex = 0x0C
	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
;>     DrawTextTiles9(0x8A40, 1, 12)
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
;>     RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;>     DrawVaultWhatMenu()
	call DrawVaultWhatMenu
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     PrintMenuText9(14)
	ld hl, $000e
	call PrintMenuText9
;>     wMenuStep = 4
	ld a, $04
	ld [wMenuStep], a
	jr .done

.checkA
;>@a elif wJoyPressed & 0x01 and amount != 0:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

	ld hl, wLinkRefused
	ld a, [hli]
	or [hl]
;=@a
	inc hl
	or [hl]
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: item/vault/gold
;@ Positions of the five digits of the gold amount entry.
WithdrawGoldDigitCursor::
	dw $008e, $008f, $0090, $0091, $0092, $ffff

;@ def VaultWithdrawGoldDoIt()
;@ path: item/vault/gold
;@ Pays the amount out: not that much in the vault (message 23), or the purse would reach 100,000
;@ (message 24); else it moves from the vault to the purse (message 25).
;@ test: skip uses the home gold routines
VaultWithdrawGoldDoIt::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;>@v if wBankedGold[0] | wBankedGold[1] << 8 | wBankedGold[2] << 16 < amount:
	ld hl, wLinkRefused
	ld a, [wBankedGold]
	sub [hl]
	inc hl
	ld a, [wBankedGold + 1]
	sbc [hl]
;=@v
	inc hl
	ld a, [wBankedGold + 2]
	sbc [hl]
;>     msg = 23
	ld hl, $0017
	jr c, .print

;>@g elif (wGold[0] | wGold[1] << 8 | wGold[2] << 16) + amount >= 100000:
	ld hl, wLinkRefused
	ld a, [wGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [wGold + 1]
;=@g
	adc [hl]
	ld d, a
	inc hl
	ld a, [wGold + 2]
	adc [hl]
	ld c, a
;=@g
	ld a, e
	sub $a0
	ld a, d
	sbc $86
	ld a, c
	sbc $01
;>     msg = 24
	ld hl, $0018
	jr nc, .print

;> else:
;>@tb     TakeBankGold(amount)
	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
;=@tb
	call TakeBankGold
;>@ag     AddGold(amount)
	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
;=@ag
	call AddGold
;>     DrawWithdrawGoldWindow()
	call DrawWithdrawGoldWindow
;>     msg = 25
	ld hl, $0019

.print
;> PrintMenuText9(msg)
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def VaultWithdrawGoldDone()
;@ path: item/vault/gold
;@ After the message: back to Deposit / Withdraw / Quit.
;@ test: skip writes VRAM
VaultWithdrawGoldDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawVaultMainMenu()
	call DrawVaultMainMenu
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def UpdateGoldEntry(digit: hl, positions: de, digits: b)
;@ path: menu/number
;@ One frame of the five-digit gold amount entry (the amount is the 24-bit number in $C8DF-$C8E1):
;@ Down / Up lower / raise the digit mem[digit] (wrapping 0-9), Left / Right move among the first
;@ `digits` digits, A (read from wJoyRepeat) sets bit 7. Then the digits are drawn.
;@ test: skip draws to VRAM
UpdateGoldEntry::
;> mem[digit] &= 0x7F
	res 7, [hl]
	push de
;> if wJoyRepeat & 0x80:               # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, .up

;>     wCursorBlink = 0x10
;>     GoldEntryDigitDown(digit)
	ld a, $10
	ld [wCursorBlink], a
	call GoldEntryDigitDown
	jr .moved

.up
;> elif wJoyRepeat & 0x40:             # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .left

;>     wCursorBlink = 0x10
;>     GoldEntryDigitUp(digit)
	ld a, $10
	ld [wCursorBlink], a
	call GoldEntryDigitUp
	jr .moved

.left
;> elif wJoyRepeat & 0x20:             # Left
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .right

;>     d = u8(mem[digit] - 1)
	ld a, [hl]
	dec a
;>     if d >= digits:
;>         d = digits - 1
	cp b
	jr c, .store

	dec b
	ld a, b
	jr .store

.right
;> elif wJoyRepeat & 0x10:             # Right
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .checkA

;>     d = mem[digit] + 1
;>     if d >= digits:
	ld a, [hl]
	inc a
	cp b
	jr c, .store

;>         d = 0
	ld a, $00

.store
;> if wJoyRepeat & 0x30:
;>     mem[digit] = d
	ld [hl], a
;>     wCursorBlink = 0
	xor a
	ld [wCursorBlink], a

.moved
;> pass
	push hl
	pop hl

.checkA
;> if wJoyRepeat & 0x01:               # A
;>     mem[digit] |= 0x80
	ld a, [wJoyRepeat]
	bit 0, a
	jr z, .draw

	set 7, [hl]

.draw
;> DrawGoldEntry(mem[digit], positions)
	pop de
	ld a, [hl]
	call DrawGoldEntry
	ret


;@ def GoldEntryDigitDown(digit: hl)
;@ path: menu/number
;@ Lowers digit mem[digit] (0 = ten thousands ... 4 = ones) of the amount, 0 wrapping to 9.
;@ test: skip uses the home number routines
GoldEntryDigitDown::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;>@pn PrintNumber5Zeros(amount, wNumberBackup)    # its five digits
	push de
	ld a, [hl]
	push hl
	ld a, [wLinkRefused]
	ldh [hNumber], a
	ld a, [wLinkPartnerChoice]
;=@pn
	ldh [hNumber + 1], a
	ld a, [wListLastRows]
	ldh [hNumber + 2], a
	ld hl, wNumberBackup
	call PrintNumber5Zeros
	pop hl
;>@dg d = wNumberBackup[mem[digit]] & 0x0F
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
;=@dg
	ld d, a
	ld a, [de]
	and $0f
;> wNumberBackup[mem[digit]] = 9 if d == 0 else d - 1
	dec a
	ld [de], a
	cp $ff
	jr nz, .value

	ld a, $09
	ld [de], a

.value
;> GoldEntryDigitsToValue()
	call GoldEntryDigitsToValue
	pop de
	ret


;@ def GoldEntryDigitsToValue()
;@ path: menu/number
;@ Puts the five digits in wNumberBackup together into the amount ($C8DF-$C8E1).
;@ test: skip uses the home multiply routine
GoldEntryDigitsToValue::
;>@a amount = (wNumberBackup[0] & 0x0F) * 10000
	push hl
	ld bc, $2710
	ld a, [wNumberBackup]
	and $0f
	call Multiply24
	ld a, l
;=@a
	ld [wLinkRefused], a
	ld a, h
	ld [wLinkPartnerChoice], a
	ld a, e
	ld [wListLastRows], a
;>@b amount += (wNumberBackup[1] & 0x0F) * 1000
	ld bc, $03e8
	ld a, [wNumberBackup + 1]
	and $0f
	call Multiply24
	ld a, [wLinkRefused]
	add l
;=@b
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc h
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc e
;=@b
	ld [wListLastRows], a
;>@c amount += (wNumberBackup[2] & 0x0F) * 100
	ld bc, $0064
	ld a, [wNumberBackup + 2]
	and $0f
	call Multiply24
	ld a, [wLinkRefused]
	add l
;=@c
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc h
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc e
;=@c
	ld [wListLastRows], a
;>@d amount += (wNumberBackup[3] & 0x0F) * 10
	ld bc, $000a
	ld a, [wNumberBackup + 3]
	and $0f
	call Multiply24
	ld a, [wLinkRefused]
	add l
;=@d
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc h
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc e
;=@d
	ld [wListLastRows], a
;>@e amount += wNumberBackup[4] & 0x0F
	ld a, [wNumberBackup + 4]
	and $0f
	ld l, a
	ld a, [wLinkRefused]
	add l
	ld [wLinkRefused], a
;=@e
	ld a, [wLinkPartnerChoice]
	adc $00
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc $00
	ld [wListLastRows], a
;=@e
	pop hl
	ret


;@ def GoldEntryDigitUp(digit: hl)
;@ path: menu/number
;@ Raises digit mem[digit] of the amount, 9 wrapping to 0.
;@ test: skip uses the home number routines
GoldEntryDigitUp::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;>@pn PrintNumber5Zeros(amount, wNumberBackup)
	push de
	ld a, [hl]
	push hl
	ld a, [wLinkRefused]
	ldh [hNumber], a
	ld a, [wLinkPartnerChoice]
;=@pn
	ldh [hNumber + 1], a
	ld a, [wListLastRows]
	ldh [hNumber + 2], a
	ld hl, wNumberBackup
	call PrintNumber5Zeros
	pop hl
;>@dg d = wNumberBackup[mem[digit]] & 0x0F
	ld de, wNumberBackup + 1
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
;=@dg
	adc d
	ld d, a
	ld a, [de]
	and $0f
;> wNumberBackup[mem[digit]] = 0 if d == 9 else d + 1
	inc a
	ld [de], a
	cp $0a
	jr nz, .value

	ld a, $00
	ld [de], a

.value
;> GoldEntryDigitsToValue()
	call GoldEntryDigitsToValue
	pop de
	ret


;@ def DrawGoldEntry(cursor: a, positions: de)
;@ path: menu/number
;@ Draws the five digits of the amount at the window offsets in `positions`; the digit the cursor
;@ is on blinks with the cursor tile $E6. Unless chosen (bit 7), it only redraws every 16 frames.
;@ test: skip writes VRAM
DrawGoldEntry::
;> amount = wLinkRefused | mem[addr(wLinkRefused) + 1] << 8 | mem[addr(wLinkRefused) + 2] << 16   # the 24-bit amount at $C8DF
;>@pn PrintNumber5Zeros(amount, wNumberBackup)
	ld c, a
	push de
	push bc
	ld a, [wLinkRefused]
	ldh [hNumber], a
	ld a, [wLinkPartnerChoice]
;=@pn
	ldh [hNumber + 1], a
	ld a, [wListLastRows]
	ldh [hNumber + 2], a
	ld hl, wNumberBackup
	call PrintNumber5Zeros
	pop bc
;=@pn
	pop de
;> if not cursor & 0x80:
	bit 7, c
	jr nz, .draw

;>     t = wCursorBlink & 0x0F
;>     wCursorBlink += 1
	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
;>     if t:
;>         return
	pop af
	ld a, c
	ret nz

.draw
;> i = 0
	ld c, a
	ld b, $00

.loop
;>@wh while (pos := mem16[positions + 2 * i]) != 0xFFFF:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@wh
	and l
	cp $ff
	ret z

;>@w     addr = WindowBgAddrWrapped9(pos)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@w
	call WindowBgAddrWrapped9
	pop bc
	pop de
;>@c     if (cursor & 0x7F) == i and not (wCursorBlink & 0x10):
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .check

;=@c
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .check

;>         tile = 0xE6
	ld a, $e6

.check
;>     else:
;>@d         tile = wNumberBackup[i]
	cp $e0
	jr nz, .put

	push hl
	ld a, b
	ld hl, wNumberBackup
	add l
;=@d
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl

.put
;>     WriteVRAM(tile, addr)
	call WriteVRAM
;>@b     wTilemapBuffer[pos] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
;>     i += 1
	inc b
	jr .loop

;@ def CompactStoredItems()
;@ path: item/vault/items
;@ Packs the vault's 40 places: the items move to the front in their order, the rest becomes
;@ $FF (wBreedParent1 is the scratch copy).
CompactStoredItems::
;>@c copy(wBreedParent1, wStoredItems, 40)
	ld hl, wBreedParent1
	ld de, wStoredItems
	ld b, $28

.copy
;=@c
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .copy

;> fill(wStoredItems, 0xFF, 40)
	ld hl, wStoredItems
	ld bc, $0028
	ld a, $ff
	call FillMemory
;> dest = wStoredItems
	ld hl, wBreedParent1
	ld de, wStoredItems
;> for i in range(40):
	ld b, $28

.pack
;>     if wBreedParent1[i] not in (0xFF, 0x00):
	ld a, [hli]
	cp $ff
	jr z, .next

	cp $00
	jr z, .next

;>         mem[dest] = wBreedParent1[i]; dest += 1
	ld [de], a
	inc de

.next
	dec b
	jr nz, .pack

	ret


;@ def StoreItem()
;@ path: item/vault/items
;@ Puts item wItemId into the first free place of the vault; with no free place wItemId becomes
;@ $FF. Nothing happens for item 0 or $FF.
StoreItem::
;> if wItemId in (0x00, 0xFF):
;>     return
	ld a, [wItemId]
	cp $00
	ret z

	cp $ff
	ret z

;>@lp for i in range(40):
	ld hl, wStoredItems
	ld b, $28

.find
;>     if wStoredItems[i] in (0x00, 0xFF):
;>@pt         wStoredItems[i] = wItemId; return
	ld a, [hl]
	cp $00
	jr z, .put

	cp $ff
	jr z, .put

;=@lp
	inc hl
	dec b
	jr nz, .find

;> wItemId = 0xFF                       # the vault is full
	ld a, $ff
	ld [wItemId], a
	ret

.put
;=@pt
	ld a, [wItemId]
	ld [hl], a
	ret

;@ def TakeStoredItem()
;@ path: item/vault/items
;@ Takes one item wItemId out of the vault (the places are packed again); if there is none,
;@ wItemId becomes $FF. Nothing happens for item 0 or $FF.
;@ test: skip calls CompactStoredItems
TakeStoredItem::
;> if wItemId in (0x00, 0xFF):
;>     return
	ld a, [wItemId]
	cp $00
	ret z

	cp $ff
	ret z

;> for i in range(40):
	ld hl, wStoredItems
	ld b, $28

.find
;>     if wStoredItems[i] == wItemId:
;>@tk         wStoredItems[i] = 0xFF; CompactStoredItems(); return
	ld a, [wItemId]
	cp [hl]
	jr z, .take

	inc hl
	dec b
	jr nz, .find

;> wItemId = 0xFF                       # not found
	ld a, $ff
	ld [wItemId], a
	ret

.take
;=@tk
	ld [hl], $ff
	call CompactStoredItems
	ret


;@ def ArenaEntryMenu()
;@ path: arena/entry
;@ The Starry Night tournament reception (script menu 4), one frame: runs step wMenuStep.
;@ test: skip jumps through a table
ArenaEntryMenu::
;> return ArenaEntrySteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: arena/entry
;@ Steps of the tournament entry: set up, a frame's pause, start, the class menu, close.
ArenaEntrySteps::
	dw ArenaEntryInit
	dw ArenaEntryWait
	dw ArenaEntryOpen
	dw ArenaEntryRunOption
	dw ArenaEntryClose

;@ def ArenaEntryInit()
;@ path: arena/entry
;@ As ShopInit, with the reception's window graphics (bank $2E entry $11).
;@ test: skip decompresses graphics
ArenaEntryInit::
;> SnapToTile9(hScrollX)
	ld hl, hScrollX
	call SnapToTile9
;> SnapToTile9(hScrollY)
	ld hl, hScrollY
	call SnapToTile9
;> fill(addr(wMenuChoice), 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@m map = 0x9800 + (hScrollY // 8) * 32 + hScrollX // 8
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@m
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
;=@m
	adc $98
	ld h, a
;>@s wWindowBgMap = (map & 0x3FF) | 0x9800
	ld a, h
	and $03
	or $98
	ld h, a
;=@s
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DecompressVRAM(0x2E, 0x11, 0x8800)
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ArenaEntryWait()
;@ path: arena/entry
;@ Does nothing for a frame.
ArenaEntryWait::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ArenaEntryOpen()
;@ path: arena/entry
;@ Clears the menu variables and puts the cursor on the next class to win: classes won so far =
;@ wScriptBossIndex (G, F, E, D on page 0, C, B, A, S on page 1).
ArenaEntryOpen::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> fill(addr(wMenuChoice), 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;> wListCursor = wScriptBossIndex & 3
	ld a, [wScriptBossIndex]
	and $03
	ld [wListCursor], a
;> if wScriptBossIndex >= 4:
;>     wListPage = 1
	ld a, [wScriptBossIndex]
	cp $04
	ret c

	ld a, $01
	ld [wListPage], a
	ret


;@ def ArenaEntryRunOption()
;@ path: arena/entry
;@ The class menu.
;@ test: skip jumps through a table
ArenaEntryRunOption::
;> return ArenaClassMenu()
	jp ArenaClassMenu


;@ def ArenaEntryClose()
;@ path: arena/entry
;@ Leaves the reception: the field picture comes back and the field runs again.
;@ test: skip writes VRAM
ArenaEntryClose::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawWindowLayout9(0x2E07)
	ld de, $2e07
	call DrawWindowLayout9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def ArenaClassMenu()
;@ path: arena/entry
;@ The class menu, one frame: runs step wMenuSubStep.
;@ test: skip jumps through a table
ArenaClassMenu::
;> return ArenaClassSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: arena/entry
;@ Steps of the class menu: mark the classes, show them with their fees, pick one, check the fee,
;@ confirm, enter; or refuse.
ArenaClassSteps::
	dw ArenaClassStart
	dw ArenaClassShowList
	dw ArenaClassListInput
	dw ArenaCheckFee
	dw ArenaShowYesNo
	dw ArenaYesNoInput
	dw ArenaEntryNext
	dw ArenaEntryFinish
	dw ArenaEntryRefused

;@ def ArenaClassStart()
;@ path: arena/entry
;@ Marks the classes already won.
ArenaClassStart::
;> MarkClearedClasses()
	call MarkClearedClasses
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def MarkClearedClasses()
;@ path: arena/entry
;@ wSceneObjects[0..7]: the mark shown next to each class, $AC for the wScriptBossIndex classes
;@ won so far, $90 for the others.
MarkClearedClasses::
;> fill(wSceneObjects, 0x90, 8)
	ld hl, wSceneObjects
	ld bc, $0008
	ld a, $90
	call FillMemory
;> if wScriptBossIndex == 0:
;>     return
	ld a, [wScriptBossIndex]
	or a
	ret z

;>@mk fill(wSceneObjects, 0xAC, wScriptBossIndex)
	ld b, a
	ld hl, wSceneObjects

.mark
;=@mk
	ld [hl], $ac
	inc hl
	dec b
	jr nz, .mark

	ret


;@ def ArenaClassShowList()
;@ path: arena/entry
;@ Once the greeting is printed, renders the page's letters and marks and draws the class window.
;@ test: skip draws to VRAM
ArenaClassShowList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> LoadClassLetterTiles()
	call LoadClassLetterTiles
;> DrawArenaClassWindow()
	call DrawArenaClassWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawArenaClassWindow()
;@ path: arena/entry
;@ Draws the message window, the class window with the 4 classes of the page and their entry fees,
;@ the gold window with the purse, and the cursor.
;@ test: skip writes VRAM
DrawArenaClassWindow::
;> RestoreTilemapBuffer9()
	call RestoreTilemapBuffer9
;> DrawWindowLayout9(0x2E07)
	ld de, $2e07
	call DrawWindowLayout9
;> DrawWindowLayout9(ArenaClassLayout)
	ld de, ArenaClassLayout
	call DrawWindowLayout9
;> DrawWindowLayout9(GoldWindowLayout)
	ld de, GoldWindowLayout
	call DrawWindowLayout9
;> DrawEntryFees()
	call DrawEntryFees
;> copy(hNumber, wGold, 3)
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(TilemapBufferAddr9(0x2E))
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawListFrame9(wListCursor, ArenaClassCursor, 4, 4)
	ld de, ArenaClassCursor
	ld b, $04
	ld c, $04
	ld hl, wListCursor
	call DrawListFrame9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def LoadClassLetterTiles()
;@ path: arena/entry
;@ Renders the class letters of page wListPage (ArenaClassLetters) into tiles $8800-$8830 and their
;@ marks (wSceneObjects) into tiles $8840-$8870.
;@ test: skip far call
LoadClassLetterTiles::
;>@l c = ArenaClassLetters + wListPage * 4
	ld de, ArenaClassLetters
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
;=@l
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x8800
	ld hl, $8800
;> for _ in range(4):
;>     c, tiles = LoadCharSlot(c, tiles)
	call LoadCharSlot
	call LoadCharSlot
	call LoadCharSlot
	call LoadCharSlot
;>@k c = wSceneObjects + wListPage * 4
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
;=@k
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x8840
	ld hl, $8840
;> for _ in range(4):
;>     c, tiles = LoadCharSlot(c, tiles)
	call LoadCharSlot
	call LoadCharSlot
	call LoadCharSlot

;@ def LoadCharSlot(char: de, tiles: hl) -> (de, hl)
;@ path: arena/entry
;@ Renders the character mem[char] into the tile at `tiles`; returns the next character and tile.
;@ test: skip far call
LoadCharSlot::
;> DrawCharTile9(mem[char], tiles)
	push de
	push hl
	ld a, [de]
	call DrawCharTile9
;>@r return char + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret


;@ def DrawEntryFees()
;@ path: arena/entry
;@ Writes the entry fees of the 4 classes of page wListPage into wTilemapBuffer (5 digits each,
;@ from row 5, column 11 down, every second row).
;@ test: skip uses the home number routines
DrawEntryFees::
;>@f fee = ArenaEntryFees + wListPage * 8
	ld de, ArenaEntryFees
	ld a, [wListPage]
	add a
	add a
	add a
	add e
;=@f
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> pos = 0x00AB
	ld hl, $00ab
;> for _ in range(4):
;>     fee, pos = DrawEntryFeeSlot(fee, pos)
	call DrawEntryFeeSlot
	call DrawEntryFeeSlot
	call DrawEntryFeeSlot

;@ def DrawEntryFeeSlot(fee: de, pos: hl) -> (de, hl)
;@ path: arena/entry
;@ Writes the 16-bit fee at `fee` as 5 digits at window offset `pos`; returns the next fee and the
;@ position two rows down.
;@ test: skip uses the home number routines
DrawEntryFeeSlot::
;>@n mem16[hNumber] = mem16[fee]; hNumber[2] = 0
	push de
	push hl
	ld a, [de]
	ldh [hNumber], a
	inc de
	ld a, [de]
;=@n
	ldh [hNumber + 1], a
	ld a, $00
	ldh [hNumber + 2], a
;> PrintNumber5(TilemapBufferAddr9(pos))
	call TilemapBufferAddr9
	call PrintNumber5
;>@r return fee + 2, pos + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	inc de
	ret


;@ path: arena/entry
;@ The letters of the eight tournament classes in the order of the menu: G, F, E, D, C, B, A, S.
ArenaClassLetters::
	db $2a, $29, $28, $27, $26, $25, $24, $36

;@ path: arena/entry
;@ Entry fee of each class, 16-bit: G 0, F 10, E 50, D 100, C 500, B 1000, A 5000, S 10000 gold.
ArenaEntryFees::
	dw 0, 10, 50, 100, 500, 1000, 5000, 10000

;@ def ArenaClassListInput()
;@ path: arena/entry
;@ The class menu: Up / Down within the page; A on a class not marked as won goes on (a won class
;@ gets message 6); B gives up the entry (wArenaRound = $FF) and closes.
;@ test: skip draws to VRAM
ArenaClassListInput::
;> old_page = wListPage
	ld de, ArenaClassCursor + 2
	ld hl, wListCursor
	ld b, $04
	inc hl
	ld a, [hld]
	push af
;> UpdateMenuCursor9(wListCursor, 4, ArenaClassCursor + 2)
	call UpdateMenuCursor9
;> if wListPage != old_page:           # (the page does not change here)
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .buttons

;>     LoadClassLetterTiles()
	call LoadClassLetterTiles
;>     DrawEntryFees()
	call DrawEntryFees
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9

.buttons
;> if wJoyPressed & 0x01:              # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .checkB

;>@k     mark = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@k
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
;=@k
	ld h, a
	ld a, [hl]
;>     if mark != 0x90:                # already won
	cp $90
	jp z, .enter

;>         PrintMenuText9(6)
	ld hl, $0006
	call PrintMenuText9
;>         wMenuSubStep = 8            # ArenaEntryRefused
	ld a, $08
	ld [wMenuSubStep], a
	jr .done

.enter
;>     else:
;>         QueueSound(0x59)
	ld a, $59
	call QueueSound
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>         wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
	jr .done

.checkB
;> elif wJoyPressed & 0x02:            # B
	ld a, [wJoyPressed]
	bit 1, a
	jp z, .done

;>     wArenaRound = 0xFF              # no entry
	ld a, $ff
	ld [wArenaRound], a
;>     wMenuStep += 1                  # ArenaEntryClose
	ld hl, wMenuStep
	inc [hl]

.done
	ret


;@ path: arena/entry
;@ Cursor table of the class window: the page-number position, then the 4 rows; $FFFF ends it.
ArenaClassCursor::
	dw $018c, $00a2, $00e2, $0122, $0162, $ffff

;@ def ArenaCheckFee()
;@ path: arena/entry
;@ Not enough gold for the chosen class's fee: message 5 and refuse. Else asks "Enter class <letter>?"
;@ (message 4, the letter in wTextArg0).
;@ test: skip prints text
ArenaCheckFee::
;>@i cls = wListPage * 4 + (wListCursor & 0x7F)
;>@i fee = mem16[ArenaEntryFees + 2 * cls]
	ld hl, ArenaEntryFees
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@i
	and $7f
	add b
	add a
	add l
	ld l, a
	ld a, $00
;=@i
	adc h
	ld h, a
;>@g if wGold[0] | wGold[1] << 8 | wGold[2] << 16 < fee:
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [wGold + 1]
;=@g
	sbc [hl]
	inc hl
	ld a, [wGold + 2]
	sbc $00
	jr nc, .ask

;>     PrintMenuText9(5)
	ld hl, $0005
	call PrintMenuText9
;>     wMenuSubStep = 8                # ArenaEntryRefused
;>     return
	ld a, $08
	ld [wMenuSubStep], a
	ret

.ask
;>@l wTextArg0[0] = ArenaClassLetters[cls]
	ld de, ArenaClassLetters
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@l
	and $7f
	add b
	add e
	ld e, a
	ld a, $00
	adc d
;=@l
	ld d, a
	ld a, [de]
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;> PrintMenuText9(4)
	ld hl, $0004
	call PrintMenuText9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ArenaShowYesNo()
;@ path: arena/entry
;@ Once the question is printed, shows the yes / no window.
;@ test: skip writes VRAM
ArenaShowYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout9(ArenaYesNoLayout)
	ld de, ArenaYesNoLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice3, ArenaYesNoCursor)
	ld de, ArenaYesNoCursor
	ld a, [wMenuChoice3]
	call DrawCursorAt9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ArenaYesNoInput()
;@ path: arena/entry
;@ Yes pays the fee and enters the class (wArenaClass = class number 0-7); No or B goes back to the
;@ class menu.
;@ test: skip draws to VRAM
ArenaYesNoInput::
;> UpdateMenuCursor9(wMenuChoice3, 2, ArenaYesNoCursor)
	ld de, ArenaYesNoCursor
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
;> if wJoyPressed & 0x02:              # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

.no
;>     DrawArenaClassWindow()
	call DrawArenaClassWindow
;>     PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;>@no     wMenuSubStep -= 4               # back to the class menu
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@no
	ld hl, wMenuSubStep
	dec [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:        # No: as B
;>         DrawArenaClassWindow(); PrintMenuText9(1); wMenuSubStep -= 4
	ld a, [wMenuChoice3]
	cp $81
	jr z, .no

;>     else:
;>@f         cls = wListPage * 4 + (wListCursor & 0x7F)
	ld hl, ArenaEntryFees
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
;=@f
	and $7f
	add b
	add a
	add l
	ld l, a
	ld a, $00
;>@sp         SpendGold(mem16[ArenaEntryFees + 2 * cls])
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld e, $00
;=@sp
	call SpendGold
;>@c         wArenaClass = cls
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@c
	add b
	ld [wArenaClass], a
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: arena/entry
;@ Positions of Yes and No.
ArenaYesNoCursor::
	dw $012f, $016f, $ffff

;@ def ArenaEntryNext()
;@ path: arena/entry
;@ Goes on to the next step.
ArenaEntryNext::
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ArenaEntryFinish()
;@ path: arena/entry
;@ After the message, closes the reception (the class is entered).
ArenaEntryFinish::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wMenuStep += 1                       # ArenaEntryClose
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ArenaEntryRefused()
;@ path: arena/entry
;@ After a refusal, back to the class menu.
;@ test: skip writes VRAM
ArenaEntryRefused::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawArenaClassWindow()
	call DrawArenaClassWindow
;> PrintMenuText9(1)
	ld hl, $0001
	call PrintMenuText9
;> wMenuSubStep = 1                     # ArenaClassShowList
	ld a, $01
	ld [wMenuSubStep], a
	ret


;@ def GalleryMenu()
;@ path: menu/gallery
;@ Script menu 13, a full-screen list of 16 monster pictures (8 per page, two pages): an entry
;@ appears once its event flag is set (GalleryEntryFlags), its monster's name once a second flag
;@ is set (GalleryNameFlags). One frame: runs step wMenuStep.
;@ test: skip jumps through a table
GalleryMenu::
;> return GallerySteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: menu/gallery
;@ Steps of the picture list: clear the screen, draw it, page through, close.
GallerySteps::
	dw GalleryInit
	dw GalleryOpen
	dw GalleryInput
	dw GalleryClose

;@ def GalleryInit()
;@ path: menu/gallery
;@ Lines the screen up with the tiles and blanks it; marks a menu as covering the field.
;@ test: skip writes VRAM
GalleryInit::
;> SnapToTile9(hScrollX)
	ld hl, hScrollX
	call SnapToTile9
;> SnapToTile9(hScrollY)
	ld hl, hScrollY
	call SnapToTile9
;> fill(addr(wMenuChoice), 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@m map = 0x9800 + (hScrollY // 8) * 32 + hScrollX // 8
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@m
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
;=@m
	adc $98
	ld h, a
;>@s wWindowBgMap = (map & 0x3FF) | 0x9800
	ld a, h
	and $03
	or $98
	ld h, a
;=@s
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> ClearTilemapBuffer9()
	call ClearTilemapBuffer9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
;> wPageToggle = 0
	xor a
	ld [wPageToggle], a
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def GalleryOpen()
;@ path: menu/gallery
;@ Builds the list and draws the first page.
;@ test: skip writes VRAM
GalleryOpen::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> ClearTilemapBuffer9()
	call ClearTilemapBuffer9
;> BuildGalleryList()
	call BuildGalleryList
;> LoadGalleryPage()
	call LoadGalleryPage
;> DrawGalleryFrame()
	call DrawGalleryFrame
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def DrawGalleryFrame()
;@ path: menu/gallery
;@ Draws the full-screen frame (GalleryFrameLayout) and, with more than 8 entries, the arrow $E7 for
;@ the second page at row 16, column 18.
;@ test: skip needs a real layout
DrawGalleryFrame::
;> DrawWindowLayout9(GalleryFrameLayout)
	ld de, GalleryFrameLayout
	call DrawWindowLayout9
;> if wListLength >= 9:
	ld a, [wListLength]
	cp $09
	ret c

;>     mem[TilemapBufferAddr9(0x0212)] = 0xE7
	ld hl, $0212
	call TilemapBufferAddr9
	ld [hl], $e7
	ret


;@ def LoadGalleryPage()
;@ path: menu/gallery
;@ Loads the 8 pictures of page wMenuChoice2 into tiles $9380 on (9 tiles each) and renders their
;@ names into tiles $8880 on (9 tiles each).
;@ test: skip decompresses graphics
LoadGalleryPage::
;>@e entry = wSceneObjects + wMenuChoice2 * 8
	ld de, wSceneObjects
	ld a, [wMenuChoice2]
	add a
	add a
	add a
	add e
;=@e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9380
	ld hl, $9380
;>@p for _ in range(8):
;>@p     entry, tiles = LoadGalleryPicture(entry, tiles)
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
;=@p
	call LoadGalleryPicture
	call LoadGalleryPicture
;>@f entry = wSceneObjects + wMenuChoice2 * 8
	ld de, wSceneObjects
	ld a, [wMenuChoice2]
	add a
	add a
	add a
	add e
;=@f
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x8880
	ld hl, $8880
;>@n for _ in range(8):
;>@n     entry, tiles = LoadGalleryName(entry, tiles)
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
;=@n
	call LoadGalleryName
	call LoadGalleryName
	ret


;@ def LoadGalleryPicture(entry: de, tiles: hl) -> (de, hl)
;@ path: menu/gallery
;@ Loads the picture of list entry mem[entry] (GalleryPictures) into the 9 tiles at `tiles`; an
;@ empty entry ($FF) gets system text $026F rendered there instead.
;@ test: skip decompresses graphics
LoadGalleryPicture::
;> if mem[entry] == 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, .picture

;>     wTextIndex = 0x6F
;>     wTextGroup = 2
	ld a, $6f
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
;>     DrawTextTiles9(tiles, 1, 9)
	ld de, $0901
	call DrawTextTiles9
;>@r     return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret

.picture
;>@g DecompressVRAM(GalleryPictures[mem[entry]], tiles)
	push hl
	ld hl, GalleryPictures
	add a
	add l
	ld l, a
	ld a, $00
;=@g
	adc h
	ld h, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
;=@g
	pop hl
	call DecompressVRAM
;>@q return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@q
	ld h, a
	pop de
	inc de
	ret


;@ path: menu/gallery
;@ Graphics of the 16 pictures (bank << 8 | entry for DecompressVRAM): bank $56 entries $0F-$1E.
GalleryPictures::
	dw $560f, $5610, $5611, $5612, $5613, $5614, $5615, $5616
	dw $5617, $5618, $5619, $561a, $561b, $561c, $561d, $561e

;@ def LoadGalleryName(entry: de, tiles: hl) -> (de, hl)
;@ path: menu/gallery
;@ Renders the monster name of list entry mem[entry] into the 9 tiles at `tiles`: the species name
;@ (text group 5, GalleryNames) once event flag GalleryNameFlags[entry] is set, else text $05E0.
;@ test: skip far call
LoadGalleryName::
;> e = mem[entry]
	push de
	push hl
	ld a, [de]
;> if e == 0xFF:
;>     wTextIndex = 0xE0
	cp $ff
	ld a, $e0
	jr z, .draw

;>@f elif not TestEventFlag(GalleryNameFlags[e]):
	ld a, [de]
	push de
	ld de, GalleryNameFlags
	add e
	ld e, a
	ld a, $00
;=@f
	adc d
	ld d, a
	push bc
	ld a, [de]
	ld c, a
	ld b, $00
;=@f
	push hl
	call TestEventFlag
	pop hl
	pop bc
	pop de
;>     wTextIndex = 0xE0
	ld a, $e0
	jr z, .draw

;> else:
;>@n     wTextIndex = GalleryNames[e]
	ld a, [de]
	ld de, GalleryNames
	add e
	ld e, a
	ld a, $00
	adc d
;=@n
	ld d, a
	ld a, [de]

.draw
;=@n
	ld [wTextIndex], a
;> wTextGroup = 5                       # monster names
	ld a, $05
	ld [wTextGroup], a
;> DrawTextTiles9(tiles, 1, 9)
	ld de, $0901
	call DrawTextTiles9
;>@r return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret


;@ def BuildGalleryList()
;@ path: menu/gallery
;@ wSceneObjects[0..15] = the numbers (0-15) of the entries whose GalleryEntryFlags event flag is
;@ set, in order, then $FF; wListLength = how many.
;@ test: skip reads the event flags through a home routine
BuildGalleryList::
;> fill(wSceneObjects, 0xFF, 16); count = 0      # (FillMemory leaves c at 0)
	ld hl, wSceneObjects
	ld bc, $0010
	ld a, $ff
	call FillMemory
;> dest = wSceneObjects
	ld hl, wSceneObjects
	ld de, GalleryEntryFlags
;>@lp for i in range(16):
	ld b, $00

.loop
;>@t     if TestEventFlag(GalleryEntryFlags[i]):
	push bc
	push de
	push hl
	ld a, [de]
	ld c, a
	ld b, $00
;=@t
	call TestEventFlag
	pop hl
	pop de
	pop bc
	jr z, .next

;>         mem[dest] = i; dest += 1; count += 1
	ld [hl], b
	inc hl
	inc c

.next
;=@lp
	inc de
	inc b
	ld a, b
	cp $10
	jr nz, .loop

;> wListLength = count
	ld a, c
	ld [wListLength], a
	ret


;@ path: menu/gallery
;@ For each of the 16 entries: the event flag that shows its monster's name.
GalleryNameFlags::
	db $10, $11, $12, $13, $14, $16, $17, $19, $1d, $1c, $1a, $1f, $20, $22, $23, $25
;@ path: menu/gallery
;@ For each of the 16 entries: its monster's name, an entry of text group 5 (species names).
GalleryNames::
	db $09, $1c, $c4, $44, $66, $0a, $45, $c5, $2a, $58, $2b, $99, $ad, $43, $94, $9a
;@ path: menu/gallery
;@ For each of the 16 entries: the event flag that puts it on the list (two entries per flag).
GalleryEntryFlags::
	db $00, $30, $30, $31, $31, $32, $32, $33, $33, $34, $34, $35, $35, $36, $36, $37

;@ def GalleryInput()
;@ path: menu/gallery
;@ Left / Right turn the page (two pages with more than 8 entries; no cursor); A, B or Start
;@ close the list.
;@ test: skip draws to VRAM
GalleryInput::
;>@pg pages = 2 if wListLength >= 9 else 1
	ld de, GalleryPageCursor
	ld hl, wMenuChoice
	ld c, $01
	ld a, [wListLength]
	cp $09
	jr c, .update

;=@pg
	ld c, $02

.update
;> old_page = wMenuChoice2
	ld b, $01
	ld a, [wMenuChoice2]
	push af
;> UpdatePagedList9(wMenuChoice, GalleryPageCursor, 1, pages)    # one "row" per page
	call UpdatePagedList9
;> if wMenuChoice2 != old_page:
;>     LoadGalleryPage()
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .buttons

	call LoadGalleryPage

.buttons
;> if wJoyPressed & 0x0A:               # B or Start
;>     wMenuStep += 1
	ld a, [wJoyPressed]
	and $0a
	jr z, .checkA

	ld hl, wMenuStep
	inc [hl]
	jr .done

.checkA
;> elif wJoyPressed & 0x01:            # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	jr .done

.done
	ret


;@ path: menu/gallery
;@ Cursor table of the picture list: only the page-number position (row 16, column 18); no rows.
GalleryPageCursor::
	dw $0212, $ffff, $ffff, $ffff

;@ def GalleryClose()
;@ path: menu/gallery
;@ Blanks the screen, rebuilds the field's map, status bar and sprites, and lets the field run.
;@ test: skip far calls
GalleryClose::
;> ClearTilemapBuffer9()
	call ClearTilemapBuffer9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> ReloadMapTileset()
	ld hl, far_ReloadMapTileset
	rst $10
;> DrawMapScreen()
	ld hl, far_DrawMapScreen
	rst $10
;> BuildStatusBar()
	call BuildStatusBar
;> DrawStatusBar()
	call DrawStatusBar
;> LoadFieldActorGfx()
	ld hl, far_LoadFieldActorGfx
	rst $10
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def NameEntryMenu()
;@ path: menu/names
;@ The name entry (script menu 15, also far entry 1 of this bank), used to name Terry or a monster:
;@ wChosenMonName points at the name (up to 8 letters), wChosenMonPic is 0 for Terry or the
;@ monster's species + $10, wChosenMonSpecies / wChosenMonGender describe the monster. One frame:
;@ while the screen is up (steps 2-8) the picture of who is being named is drawn as a sprite (two
;@ frames, switching every 16 frames), then step wMenuStep runs.
;@ test: skip far calls and a jump table
NameEntryMenu::
;> if 2 <= wMenuStep < 9:
	ld a, [wMenuStep]
	cp $09
	jr nc, .step

	cp $02
	jr c, .step

;>     hSpriteX = 0x0019
	ld hl, hSpriteX
	ld a, $19
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteY = 0x0021
	ld a, $21
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteSet = wChosenMonPic
	ld a, [wChosenMonPic]
	ld [hli], a
;>@fr     hSpriteFrame = 1 if wFrameCounter & 0x10 else 0
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame

	ld b, $01

.frame
;=@fr
	ld a, b
	ld [hli], a
;>     hSpriteTileBase = 0x50          # the picture loaded at $8500
;>     hSpriteAttr = 0
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
;>     DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10

.step
;> return NameEntrySteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: menu/names
;@ Steps of the name entry: wait for the fade, set up, draw, type, check the name (rejected: a
;@ message and back), ask to confirm, yes / no, finish.
NameEntrySteps::
	dw NameEntryWaitFade
	dw NameEntryInit
	dw NameEntryOpen
	dw NameEntryInput
	dw NameEntryCheckName
	dw NameEntryRejected
	dw NameEntryAskConfirm
	dw NameEntryShowYesNo
	dw NameEntryYesNoInput
	dw NameEntryNext
	dw NameEntryFinish

;@ def NameEntryNext()
;@ path: menu/names
;@ Goes on to the next step.
NameEntryNext::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def NameEntryWaitFade()
;@ path: menu/names
;@ Step 0: with no fade running, the set-up follows next frame; during a fade it runs at once.
;@ test: skip runs on into NameEntryInit
NameEntryWaitFade::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> if wFadeState == 0:
;>     return
	ld a, [wFadeState]
	or a
	ret z

;> return NameEntryInit()

;@ def NameEntryInit()
;@ path: menu/names
;@ Sets the name entry up: the name so far (or the species' default name) into wNameInput, the
;@ message box at row 14, a blank screen, the keyboard graphics (bank $2E entries $1E, $1F, $20 to
;@ $9000, $8800, $8A00), the picture of who is named (NamePictures) to $8500 and its palettes.
;@ test: skip decompresses graphics
NameEntryInit::
;> SnapToTile9(hScrollX)
	ld hl, hScrollX
	call SnapToTile9
;> SnapToTile9(hScrollY)
	ld hl, hScrollY
	call SnapToTile9
;> fill(wNameInput, 0x9F, 16)           # empty letters (and wNameLetterRows)
	ld hl, wNameInput
	ld bc, $0010
	ld a, $9f
	call FillMemory
;> LoadCurrentName()
	call LoadCurrentName
;> fill(addr(wMenuChoice), 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@m map = 0x9800 + (hScrollY // 8) * 32 + hScrollX // 8
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@m
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
;=@m
	adc $98
	ld h, a
;>@s wWindowBgMap = (map & 0x3FF) | 0x9800
	ld a, h
	and $03
	or $98
	ld h, a
;=@s
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;>@tb wTextBoxMap = NextBgColumn9(WindowBgAddr9(0x01C0))   # row 14, column 1
	ld hl, $01c0
	call WindowBgAddr9
	call NextBgColumn9
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
;=@tb
	ld [wTextBoxMap + 1], a
;> ClearTilemapBuffer9()
	call ClearTilemapBuffer9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> DecompressVRAM(0x2E, 0x1E, 0x9000)
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x20, 0x8A00)
	ld de, $2e20
	ld hl, $8a00
	call DecompressVRAM
;>@p pic = mem16[NamePictures + 2 * wChosenMonPic]
	ld a, [wChosenMonPic]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(NamePictures)
;=@p
	ld l, a
	ld a, h
	adc HIGH(NamePictures)
	ld h, a
	ld e, [hl]
	inc hl
;=@p
	ld d, [hl]
;> DecompressVRAM(hi(pic), lo(pic), 0x8500)
	ld hl, $8500
	call DecompressVRAM
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawNameBuffer()
	call DrawNameBuffer
;> LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def LoadCurrentName()
;@ path: menu/names
;@ Copies the current name at wChosenMonName (up to 8 letters, ending at 0, $F0 or $9F) into
;@ wNameInput. A monster with no name yet gets its species' default name (text group 7).
;@ test: skip far call
LoadCurrentName::
;>@c CopyNameToBuffer(wChosenMonName, wNameInput, 8)
	ld b, $08
	ld a, [wChosenMonName]
	ld l, a
	ld a, [wChosenMonName + 1]
	ld h, a
	ld de, wNameInput
;=@c
	call CopyNameToBuffer
;> if wChosenMonPic == 0:                # Terry
;>     return
	ld a, [wChosenMonPic]
	cp $00
	ret z

;> if wNameInput[0] != 0x9F:
;>     return
	ld a, [wNameInput]
	cp $9f
	ret nz

;> CopySystemText(0x0700 | wChosenMonSpecies, wTextArg0)     # the default name
	ld a, [wChosenMonSpecies]
	ld l, a
	ld h, $07
	ld de, wTextArg0
	call CopySystemText
;> return CopyNameToBuffer(wTextArg0, wNameInput, b)
	ld hl, wTextArg0
	ld de, wNameInput

;@ def CopyNameToBuffer(src: hl, dest: de, count: b)
;@ path: menu/names
;@ Copies up to `count` letters from `src` to `dest`, stopping at 0, $F0 or $9F.
;@ test: skip copies through pointers
CopyNameToBuffer::
;> for _ in range(count):
;>     c = mem[src]; src += 1
	ld a, [hli]
;>     if c in (0x00, 0xF0, 0x9F):
;>         return
	cp $00
	ret z

	cp $f0
	ret z

	cp $9f
	ret z

;>     mem[dest] = c; dest += 1
	ld [de], a
	inc de
	dec b
	jr nz, CopyNameToBuffer

	ret


;@ def DrawNameBuffer()
;@ path: menu/names
;@ Renders the name typed so far into the tiles at $9000 and draws the letter cursor under it.
;@ test: skip far call
DrawNameBuffer::
;> DrawNameTiles9(wNameInput, 0x9000)
	ld de, wNameInput
	ld hl, $9000
	call DrawNameTiles9
;> DrawNameCursor()
	call DrawNameCursor
	ret


;@ def NameEntryOpen()
;@ path: menu/names
;@ Draws the name entry screen.
;@ test: skip writes VRAM
NameEntryOpen::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> ClearTilemapBuffer9()
	call ClearTilemapBuffer9
;> DrawNameEntryScreen()
	call DrawNameEntryScreen
;> DrawNameCursor()
	call DrawNameCursor
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
	ret


;@ def DrawNameEntryScreen()
;@ path: menu/names
;@ For a monster, renders its sex mark ($A7 / $A8) into tile $8AF0 and puts that tile ($AF) at row
;@ 3, column 4. Then draws the name box and one of the two keyboards (KeyboardLayout1 when
;@ wConfirmChoice is set, else KeyboardLayout0) and the keyboard cursor.
;@ test: skip far call
DrawNameEntryScreen::
;> if wChosenMonPic != 0:
	ld a, [wChosenMonPic]
	or a
	jr z, .layout

;>     wTextArg0[0] = 0xA7 + (wChosenMonGender & 1)
	ld a, [wChosenMonGender]
	and $01
	add $a7
	ld [wTextArg0], a
;>     wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>     saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;>     saved_size = (wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;>     wTextTiles = 0x8AF0
	ld hl, $8af0
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;>     wTextBoxLines = 1
;>     wTextBoxLineLength = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;>     wTextGroup = 2
;>     wTextIndex = 0
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
;>     PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>     wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;>     wTextBoxLines = saved_size[0]
;>     wTextBoxLineLength = saved_size[1]
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;>     mem[TilemapBufferAddr9(0x0064)] = 0xAF
	ld hl, $0064
	call TilemapBufferAddr9
	ld [hl], $af

.layout
;> DrawWindowLayout9(NameBoxLayout)
	ld de, NameBoxLayout
	call DrawWindowLayout9
;>@k DrawWindowLayout9(KeyboardLayout1 if wConfirmChoice else KeyboardLayout0)
	ld de, KeyboardLayout1
	ld a, [wConfirmChoice]
	or a
	jr nz, .keyboard

	ld de, KeyboardLayout0

.keyboard
;=@k
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawKeyboardCursor()
	call DrawKeyboardCursor
	ret


;@ def NameEntryInput()
;@ path: menu/names
;@ One frame of typing a name. The keyboard is 5 rows (wMenuChoice2) of 17 columns (wMenuChoice),
;@ key = row * 17 + column; some keys are gaps the cursor jumps over (row 4 columns 7-12, rows 3-4
;@ columns 14-16). Key $40 is Back, $51 End. B or Back erases (the first B on Terry's default name
;@ erases all of it), A types the letter shown on the key, Start puts the cursor on End. A name
;@ holds 4 letters; the voicing marks $8D / $8E go on the last letter and do not count, but only
;@ after letters of certain 5-key groups (key // 5, kept per letter in wNameLetterRows).
;@ test: skip draws to VRAM
NameEntryInput::
;> if wJoyRepeat & 0x20:                # Left
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .right

;>     if wMenuChoice2 >= 3:           # rows 3-4 end at column 13
	ld a, [wMenuChoice2]
	cp $03
	jr c, .leftUpper

;>         wMenuChoice = u8(wMenuChoice - 1)
;>@la         if wMenuChoice >= 17: wMenuChoice = 13
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
	cp $11
	jp c, .moved

;=@la
	ld a, $0d
	ld [wMenuChoice], a
	jp .moved

.leftUpper
;>     else:
;>         wMenuChoice = u8(wMenuChoice - 1)
;>@lb         if wMenuChoice >= 17: wMenuChoice = 16
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
	cp $11
	jp c, .moved

;=@lb
	ld a, $10
	ld [wMenuChoice], a
	jp .moved

.right
;> elif wJoyRepeat & 0x10:              # Right
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .up

;>     wMenuChoice += 1
;>@rr     if wMenuChoice >= 17: wMenuChoice = 0
	ld a, [wMenuChoice]
	inc a
	ld [wMenuChoice], a
	cp $11
	jp c, .moved

;=@rr
	ld a, $00
	ld [wMenuChoice], a
	jp .moved

.up
;> elif wJoyRepeat & 0x40:              # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .down

;>     if wMenuChoice < 6:
;>@ul         wMenuChoice2 = 4 if wMenuChoice2 == 0 else wMenuChoice2 - 1
	ld a, [wMenuChoice]
	cp $06
	jr c, .upLeft

;>     elif wMenuChoice >= 13:         # the Back / End column
;>@ur         wMenuChoice2 = u8(wMenuChoice2 - 1)
;>@us         if wMenuChoice2 >= 5: wMenuChoice2 = 4; wMenuChoice = 13
	cp $0d
	jp nc, .upRight

;>     else:
;>@um         wMenuChoice2 = 3 if wMenuChoice2 == 0 else wMenuChoice2 - 1    # rows 0-3
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	cp $05
	jp c, .moved

;=@um
	ld a, $03
	ld [wMenuChoice2], a
	jp .moved

.upRight
;=@ur
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	cp $05
	jr c, .moved

;=@us
	ld a, $04
	ld [wMenuChoice2], a
	ld a, $0d
	ld [wMenuChoice], a
	jr .moved

.upLeft
;=@ul
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	cp $05
	jr c, .moved

;=@ul
	ld a, $04
	ld [wMenuChoice2], a
	jr .moved

.down
;> elif wJoyRepeat & 0x80:              # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jp z, .input

;>@d1     if wMenuChoice < 6 or (wMenuChoice >= 13 and wMenuChoice2 < 2):
;>@dl         wMenuChoice2 = (wMenuChoice2 + 1) % 5
	ld a, [wMenuChoice]
	cp $06
	jr c, .downLeft

	cp $0d
	jr nc, .downRight

;>     elif wMenuChoice < 13:
;>@dm         wMenuChoice2 = (wMenuChoice2 + 1) % 4     # rows 0-3
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	cp $04
	jr c, .moved

;=@dm
	ld a, $00
	ld [wMenuChoice2], a
	jr .moved

.downRight
;>     else:
;>@dr         wMenuChoice = 13; wMenuChoice2 = (wMenuChoice2 + 1) % 5
;=@d1
	ld a, [wMenuChoice2]
	cp $02
	jr c, .downLeft

;=@dr
	ld a, [wMenuChoice]
	ld a, $0d
	ld [wMenuChoice], a
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
;=@dr
	cp $05
	jr c, .moved

	ld a, $00
	ld [wMenuChoice2], a
	jr .moved

.downLeft
;=@dl
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	cp $05
	jr c, .moved

;=@dl
	ld a, $00
	ld [wMenuChoice2], a
	jr .moved

.moved
;> if wJoyRepeat & 0xF0:                # the cursor moved: skip the gaps
;>     wCursorBlink = 0
	xor a
	ld [wCursorBlink], a
;>     key = wMenuChoice2 * 17 + wMenuChoice
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wMenuChoice]
	add l
;>     if key == 0x4A:                 # row 4, column 6
	cp $4a
	jr nz, .not4A

;>@g1         wMenuChoice = 13 if wJoyRepeat & 0x10 else 6
	ld a, $06
	ld [wMenuChoice], a
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .input

;=@g1
	ld a, $0d
	ld [wMenuChoice], a
	jr .input

.not4A
;>     elif key == 0x50:               # row 4, column 12
	cp $50
	jr nz, .not50

;>@g2         wMenuChoice = 5 if wJoyRepeat & 0x20 else 13
	ld a, $0d
	ld [wMenuChoice], a
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .input

;=@g2
	ld a, $05
	ld [wMenuChoice], a
	jr .input

.not50
;>@g3     elif key in (0x41, 0x42, 0x43, 0x52, 0x53, 0x54):   # rows 3-4, columns 14-16
;>@g4         wMenuChoice = 0 if wJoyRepeat & 0x10 else 10
	cp $41
	jr z, .gap

	cp $42
	jr z, .gap

	cp $43
	jr z, .gap

;=@g3
	cp $52
	jr z, .gap

	cp $53
	jr z, .gap

	cp $54
	jr z, .gap

;=@g3
	jr .input

.gap
;=@g4
	ld a, $0a
	ld [wMenuChoice], a
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .input

;=@g4
	ld a, $00
	ld [wMenuChoice], a
	jr .input

.input
;> DrawKeyboardCursor()
	call DrawKeyboardCursor
;> if wJoyPressed & 0x02 or (wJoyPressed & 0x01 and wMenuChoice2 * 17 + wMenuChoice == 0x40):   # B, or A on Back: erase
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

.erase
;>     if wNameInput[0] == 0x9F:       # nothing to erase
;>         return
	ld de, wNameInput
	ld a, [de]
	cp $9f
	jp z, .done

.findEnd
;>     last = next(a for a in range(wNameInput + 1, wNameInput + 16) if mem[a] == 0x9F) - 1
	inc de
	ld a, [de]
	cp $9f
	jr nz, .findEnd

	dec de
;>     if wNameCleared == 0 and wChosenMonPic == 0:      # Terry's default name goes at once
	ld a, [wNameCleared]
	cp $00
	jp nz, .eraseOne

	ld a, [wChosenMonPic]
	cp $00
	jp nz, .eraseOne

;>         wNameCleared = 1
	ld a, $01
	ld [wNameCleared], a
;>         fill(wNameInput, 0x9F, 4)
	ld a, $9f
	ld [wNameInput], a
	ld [wNameInput + 1], a
	ld [wNameInput + 2], a
	ld [wNameInput + 3], a
	jp .redraw

.eraseOne
;>     else:
;>         mem[last] = 0x9F
	ld a, $9f
	ld [de], a

.redraw
;>     DrawNameBuffer()
;>     return
	call DrawNameBuffer
	jp .done

.checkA
;> elif wJoyPressed & 0x01:             # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .checkStart

;>     key = wMenuChoice2 * 17 + wMenuChoice
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wMenuChoice]
	add l
;>     if key == 0x51:                 # End: the name is done
;>         wMenuStep += 1; return
	cp $51
	jr nz, .notEnd

	ld hl, wMenuStep
	inc [hl]
	jp .done

.notEnd
;>     if key == 0x40:                 # Back: jumps to the erasing above
;>         pass
	cp $40
	jp z, .erase

;>@rm     key = {0x1E: 0x0D, 0x1F: 0x0E, 0x20: 0x0F, 0x21: 0x10, 0x2F: 0x1E, 0x30: 0x1F,
;>@rm            0x0D: 0x20, 0x0E: 0x21, 0x0F: 0x2F, 0x10: 0x30}.get(key, key)  # (each also stored to ROM space, no effect)
	cp $1e
	jr nz, .key1F

	ld a, $0d
	ld [hl], a
	jr .keyChar

.key1F
;=@rm
	cp $1f
	jr nz, .key20

	ld a, $0e
	ld [hl], a
	jr .keyChar

.key20
;=@rm
	cp $20
	jr nz, .key21

	ld a, $0f
	ld [hl], a
	jr .keyChar

.key21
;=@rm
	cp $21
	jr nz, .key2F

	ld a, $10
	ld [hl], a
	jr .keyChar

.key2F
;=@rm
	cp $2f
	jr nz, .key30

	ld a, $1e
	ld [hl], a
	jr .keyChar

.key30
;=@rm
	cp $30
	jr nz, .key0D

	ld a, $1f
	ld [hl], a
	jr .keyChar

.key0D
;=@rm
	cp $0d
	jr nz, .key0E

	ld a, $20
	ld [hl], a
	jr .keyChar

.key0E
;=@rm
	cp $0e
	jr nz, .key0F

	ld a, $21
	ld [hl], a
	jr .keyChar

.key0F
;=@rm
	cp $0f
	jr nz, .key10

	ld a, $2f
	ld [hl], a
	jr .keyChar

.key10
;=@rm
	cp $10
	jr nz, .keyChar

	ld a, $30
	ld [hl], a

.keyChar
;>@ch     ch_addr = wTilemapBuffer + mem16[KeyboardKeyPositions + 2 * key] - 32     # the letter above the key
	ld hl, KeyboardKeyPositions
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@ch
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	add $e0
;=@ch
	ld l, a
	ld a, h
	adc $c4
	ld h, a
;>     ch = mem[ch_addr]
;>     n = CountNameLetters()
	push hl
	call CountNameLetters
	pop hl
;>     if n == 4:                      # the name is full: only a mark can still go on
	ld a, c
	cp $04
	jr nz, .notFull

;>         wMenuChoice = 13
;>         wMenuChoice2 = 4            # cursor to End
	ld a, $0d
	ld [wMenuChoice], a
	ld a, $04
	ld [wMenuChoice2], a
;>         if ch not in (0x8D, 0x8E):
;>             return
	ld a, [hl]
	cp $8d
	jr z, .add

	cp $8e
	jr z, .add

	jp .done

.notFull
;>@nf     elif n == 0 and ch in (0x8D, 0x8E):   # a mark cannot come first
;>         return
	or a
	jr nz, .add

	ld a, [hl]
	cp $8d
	jp z, .done

	cp $8e
;=@nf
	jp z, .done

.add
;>@e     end = next(a for a in range(wNameInput, wNameInput + 16) if mem[a] == 0x9F)
	ld de, wNameInput

.findEnd2
;=@e
	ld a, [de]
	inc de
	cp $9f
	jr nz, .findEnd2

	dec de
;>     if ch in (0x8D, 0x8E):          # a voicing mark
	ld a, [hl]
	cp $8d
	jr z, .mark

	cp $8e
	jr nz, .put

.mark
;>@mk         if mem[end - 1] in (0x8D, 0x8E):    # the letter has a mark already
;>             return
	dec de
	ld a, [de]
	inc de
	cp $8d
	jp z, .done

	cp $8e
;=@mk
	jr z, .done

;>@gr         group = wNameLetterRows[n]  # 5-key group of the last letter
	push hl
	ld a, c
	ld hl, wNameLetterRows
	add l
	ld l, a
	ld a, $00
;=@gr
	adc h
	ld h, a
	ld b, [hl]
	pop hl
;>         if group != 1:
	ld a, b
	cp $01
	jr z, .put

;>             if ch == 0x8E:          # this mark only goes on group-1 letters
;>                 return
	ld a, [hl]
	cp $8e
	jr z, .done

;>@ot             if group not in (3, 6, 9) and mem[end - 1] != 0x5A:
;>                 return
	ld a, b
	cp $03
	jr z, .put

	cp $06
	jr z, .put

	cp $09
;=@ot
	jr z, .put

	dec de
	ld a, [de]
	inc de
	cp $5a
	jr nz, .done

.put
;>     mem[end] = ch
	ld a, [hl]
	ld [de], a
;>     DrawNameBuffer()
	call DrawNameBuffer
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@rw     wNameLetterRows[CountNameLetters()] = key // 5     # (key before the swap above)
	call CountNameLetters
	ld a, c
	ld hl, wNameLetterRows
	add l
	ld l, a
	ld a, $00
;=@rw
	adc h
	ld h, a
	push hl
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
;=@rw
	ld a, [wMenuChoice]
	add l
	ld b, a
	ld a, $05
	call Divide8
	ld a, b
;=@rw
	pop hl
	ld [hl], a
;>     if CountNameLetters() == 4:
	call CountNameLetters
	ld a, c
	cp $04
	jr nz, .done

;>         wMenuChoice = 13
;>         wMenuChoice2 = 4
	ld a, $0d
	ld [wMenuChoice], a
	ld a, $04
	ld [wMenuChoice2], a
	jr .done

.checkStart
;> elif wJoyPressed & 0x08:             # Start: cursor to End
	ld a, [wJoyPressed]
	bit 3, a
	jr z, .done

;>     wMenuChoice = 13
;>     wMenuChoice2 = 4
	ld a, $0d
	ld [wMenuChoice], a
	ld a, $04
	ld [wMenuChoice2], a
	jr .done

.done
	ret


;@ path: menu/names
;@ Cursor position (window offset) of each of the 85 keys, row by row (5 rows of 17); the letter
;@ of a key is the tile one row above it. $FFFF ends the table.
KeyboardKeyPositions::
	dw $00e1, $00e2, $00e3, $00e4, $00e5, $00e6, $00e7, $00e8, $00e9, $00ea, $00eb, $00ec, $00ed, $00ef, $00f0, $00f1, $00f2
	dw $0121, $0122, $0123, $0124, $0125, $0126, $0127, $0128, $0129, $012a, $012b, $012c, $012d, $012f, $0130, $0131, $0132
	dw $0161, $0162, $0163, $0164, $0165, $0166, $0167, $0168, $0169, $016a, $016b, $016c, $016d, $016f, $0170, $0171, $0172
	dw $01a1, $01a2, $01a3, $01a4, $01a5, $01a6, $01a7, $01a8, $01a9, $01aa, $01ab, $01ac, $01ad, $01af, $01b0, $01b1, $01b2
	dw $01e1, $01e2, $01e3, $01e4, $01e5, $01e6, $01e7, $01e8, $01e9, $01ea, $01eb, $01ec, $01ed, $01ef, $01f0, $01f1, $01f2
	dw $ffff

;@ def NameEntryCheckName()
;@ path: menu/names
;@ End was chosen: an empty name gets a default one (PickDefaultName); a forbidden name prints
;@ system text $020A and goes back to typing, any other goes on to the confirmation.
;@ test: skip prints text
NameEntryCheckName::
;> wCursorBlink = 0
	xor a
	ld [wCursorBlink], a
;> DrawKeyboardCursor()
	call DrawKeyboardCursor
;> if wNameInput[0] == 0x9F:            # nothing typed
	ld a, [wNameInput]
	cp $9f
	jr nz, .check

;>     PickDefaultName()
	call PickDefaultName
;>     PadNameBuffer()
	call PadNameBuffer
;>     DrawNameBuffer()
	call DrawNameBuffer

.check
;> if not CheckForbiddenName():
	call CheckForbiddenName
	jr c, .forbidden

;>     wMenuStep += 2                  # NameEntryAskConfirm
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr .done

.forbidden
;> else:
;>     PrintSystemText(0x020A)
	ld hl, $020a
	call PrintSystemText
;>     DrawWindowLayout9(0x2E07)       # message window (bank 0)
	ld de, $2e07
	call DrawWindowLayout9
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     wMenuStep += 1                  # NameEntryRejected
	ld hl, wMenuStep
	inc [hl]

.done
	ret


;@ def NameEntryRejected()
;@ path: menu/names
;@ After the "can't use that name" message: back to typing.
;@ test: skip far call
NameEntryRejected::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> DrawNameBuffer()
	call DrawNameBuffer
;>@b wMenuStep -= 3                      # NameEntryInput
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
;=@b
	ret


;@ def NameEntryAskConfirm()
;@ path: menu/names
;@ Asks to confirm the name (in wTextArg0): for Terry system text $0209; for a monster (whose
;@ species name and sex mark go into wTextArg1) $020F, or $0245 when another monster already has
;@ that name.
;@ test: skip prints text
NameEntryAskConfirm::
;> if wChosenMonPic != 0:
	ld a, [wChosenMonPic]
	cp $00
	jr z, .name

;>     CopySystemText(0x0500 | wChosenMonSpecies, wTextArg1)      # species name
	ld a, [wChosenMonSpecies]
	ld l, a
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
;>     p = wTextArg1
	ld hl, wTextArg1

.findEnd
;>     while mem[p] != 0xF0: p += 1
	ld a, [hli]
	cp $f0
	jr nz, .findEnd

;>     mem[p] = 0xA7 + (wChosenMonGender & 1)   # the sex mark
	dec hl
	ld a, [wChosenMonGender]
	and $01
	add $a7
	ld [hli], a
;>     mem[p + 1] = 0xF0
	ld [hl], $f0

.name
;> p = wTextArg0
;> for i in range(8):                   # the name, up to its first empty slot
	ld hl, wTextArg0
	ld de, wNameInput
	ld b, $08

.copy
;>     if wNameInput[i] == 0x9F:
;>         break
	ld a, [de]
	cp $9f
	jr z, .end

;>     mem[p] = wNameInput[i]; p += 1
	ld [hli], a
	inc de
	dec b
	jr nz, .copy

.end
;> wNameCleared = 0
	ld a, $00
	ld [wNameCleared], a
;> mem[p] = 0xF0
	ld [hl], $f0
;>@m msg = 0x0209 if wChosenMonPic == 0 else (0x0245 if CheckNameTaken() else 0x020F)
	ld hl, $0209
	ld a, [wChosenMonPic]
	cp $00
	jr z, .print

	call CheckNameTaken
	ld hl, $0245
;=@m
	jr c, .print

	ld hl, $020f

.print
;> PrintSystemText(msg)
	call PrintSystemText
;> DrawWindowLayout9(0x2E07)
	ld de, $2e07
	call DrawWindowLayout9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
	ret


;@ def NameEntryShowYesNo()
;@ path: menu/names
;@ Once the question is printed, shows the yes / no window.
;@ test: skip writes VRAM
NameEntryShowYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout9(NameYesNoLayout)
	ld de, NameYesNoLayout
	call DrawWindowLayout9
;> ResetCursorBlink9()
	call ResetCursorBlink9
;> DrawCursorAt9(wMenuChoice3, NameYesNoCursor)
	ld de, NameYesNoCursor
	ld a, [wMenuChoice3]
	call DrawCursorAt9
;> CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def NameEntryYesNoInput()
;@ path: menu/names
;@ Yes keeps the name; No or B goes back to typing.
;@ test: skip draws to VRAM
NameEntryYesNoInput::
;> UpdateMenuCursor9(wMenuChoice3, 2, NameYesNoCursor)
	ld de, NameYesNoCursor
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
;> if wJoyPressed & 0x02:               # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .checkA

.no
;>     DrawNameBuffer()
	call DrawNameBuffer
;>@no     wMenuStep -= 6                  # NameEntryOpen's next step: typing
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
;=@no
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
;=@no
	jr .done

.checkA
;> elif wJoyPressed & 0x01:             # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:        # No: as B
;>         DrawNameBuffer(); wMenuStep -= 6
	ld a, [wMenuChoice3]
	cp $81
	jr z, .no

;>     else:
;>         wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]

.done
	ret


;@ path: menu/names
;@ Positions of Yes and No in the name entry's yes / no window.
NameYesNoCursor::
	dw $012f, $016f, $ffff

;@ def NameEntryFinish()
;@ path: menu/names
;@ Writes the name to wChosenMonName (8 bytes, $F0 after the letters). Unless the menu was opened
;@ with wScriptMenu = $FF (and wFieldFlags bit 7 clear), the field screen is rebuilt: map, status
;@ bar and the field sprites (on a gate floor its own sprite graphics, bank $2E entries $15-$1C).
;@ Then the field runs again (with wFieldFlags bit 7 set only that bit is cleared).
;@ test: skip decompresses graphics
NameEntryFinish::
;>@f fill(wChosenMonName, 0xF0, 8)
	ld a, [wChosenMonName]
	ld l, a
	ld a, [wChosenMonName + 1]
	ld h, a
	ld bc, $0008
	ld a, $f0
;=@f
	call FillMemory
;> dest = wChosenMonName
	ld a, [wChosenMonName]
	ld l, a
	ld a, [wChosenMonName + 1]
	ld h, a
;> for i in range(8):
	ld de, wNameInput
	ld b, $08

.copy
;>     if wNameInput[i] == 0x9F:
;>         break
	ld a, [de]
	cp $9f
	jr z, .copied

;>     mem[dest] = wNameInput[i]; dest += 1
	ld [hli], a
	inc de
	dec b
	jr nz, .copy

.copied
;> if wFieldFlags & 0x80 or wScriptMenu != 0xFF:
	ld hl, wFieldFlags
	bit 7, [hl]
	jr nz, .redraw

	ld a, [wScriptMenu]
	cp $ff
	jr z, .close

.redraw
;>     ClearTilemapBuffer9()
	call ClearTilemapBuffer9
;>     CopyTilemapBufferToVram9()
	call CopyTilemapBufferToVram9
;>     ReloadMapTileset()
	ld hl, far_ReloadMapTileset
	rst $10
;>     DrawMapScreen()
	ld hl, far_DrawMapScreen
	rst $10
;>     BuildStatusBar()
	call BuildStatusBar
;>     DrawStatusBar()
	call DrawStatusBar
;>     if wOnGateFloor == 0:
;>         LoadFieldActorGfx()
	ld a, [wOnGateFloor]
	or a
	jr nz, .gateFloor

	ld hl, far_LoadFieldActorGfx
	rst $10
	jr .close

.gateFloor
;>@gf     else:
;>@gf         for i in range(8):          # $8500-$86C0, $40 bytes apart
;>@gf             DecompressVRAM(0x2E, 0x15 + i, 0x8500 + 0x40 * i)
	ld de, $2e15
	ld hl, $8500
	call DecompressVRAM
	ld de, $2e16
	ld hl, $8540
	call DecompressVRAM
;=@gf
	ld de, $2e17
	ld hl, $8580
	call DecompressVRAM
	ld de, $2e18
	ld hl, $85c0
	call DecompressVRAM
;=@gf
	ld de, $2e19
	ld hl, $8600
	call DecompressVRAM
	ld de, $2e1a
	ld hl, $8640
	call DecompressVRAM
;=@gf
	ld de, $2e1b
	ld hl, $8680
	call DecompressVRAM
	ld de, $2e1c
	ld hl, $86c0
	call DecompressVRAM

.close
;> if not wFieldFlags & 0x80:
;>     wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	bit 7, [hl]
	jr nz, .keepMenu

	res 4, [hl]
;>     wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret

.keepMenu
;> else:
;>     wFieldFlags &= ~0x80
	ld hl, wFieldFlags
	res 7, [hl]
	ret


;@ def PickDefaultName()
;@ path: menu/names
;@ An empty name: Terry gets $D3 $D4 $D5 $D6; a monster one of 8 names (text group 3) picked at
;@ random from the 16 of its family (wMonStats byte 0), the second 8 for females.
;@ test: skip far call
PickDefaultName::
;> if wChosenMonPic == 0:
	ld a, [wChosenMonPic]
	cp $00
	jr nz, .monster

;>     wNameInput[0] = 0xD3
;>     wNameInput[1] = 0xD4
	ld a, $d3
	ld [wNameInput], a
	ld a, $d4
	ld [wNameInput + 1], a
;>     wNameInput[2] = 0xD5
;>     wNameInput[3] = 0xD6
	ld a, $d5
	ld [wNameInput + 2], a
	ld a, $d6
	ld [wNameInput + 3], a
	ret

.monster
;> else:
;>     Random()
	call Random
;>     wMonSpecies = wChosenMonPic - 0x10
	ld a, [wChosenMonPic]
	sub $10
	ld [wMonSpecies], a
;>     GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;>@n     n = (swap(wMonStats[0]) | (wRandomHigh & 7)) + (wChosenMonGender & 1) * 8
	ld a, [wMonStats]
	ld c, a
	ld a, [wRandomHigh]
	and $07
	swap c
	or c
;=@n
	ld c, a
	ld a, [wChosenMonGender]
	and $01
	add a
	add a
	add a
;=@n
	add c
;>     CopySystemText(0x0300 | n, wNameInput)
	ld l, a
	ld h, $03
	ld de, wNameInput
	call CopySystemText
	ret


;@ def PadNameBuffer()
;@ path: menu/names
;@ Replaces the $F0 end mark in wNameInput and everything after it (up to 16 bytes) with $9F.
PadNameBuffer::
;> for i in range(16):
	ld hl, wNameInput
	ld b, $10

.find
;>     if wNameInput[i] == 0xF0:
;>         break
	ld a, [hl]
	cp $f0
	jr z, .pad

	inc hl
	dec b
	jr nz, .find

;> else:
;>     return                           # no end mark
	ret

.pad
;> fill(wNameInput + i, 0x9F, 16 - i)
	ld a, $9f
	ld [hli], a
	dec b
	jr nz, .pad

	ret


;@ def CheckForbiddenName() -> carry
;@ path: menu/names
;@ Carry for a name that may not be used: four times the same letter, or one of ForbiddenNames.
CheckForbiddenName::
;> n = wNameInput
	ld hl, wNameInput
;>@s if n[0] == n[1] == n[2] == n[3] and n[4] == 0x9F:
;>     return True
	ld a, [hli]
	cp [hl]
	jr nz, .list

	inc hl
	cp [hl]
	jr nz, .list

;=@s
	inc hl
	cp [hl]
	jr nz, .list

	inc hl
	ld a, [hl]
	cp $9f
;=@s
	jr z, .forbidden

.list
;> p = ForbiddenNames
	ld hl, ForbiddenNames

.next
;> while True:
;>@cmp     if all(wNameInput[i] == mem[p + i] for i in range(8)):
	ld de, wNameInput
	ld b, $08
	push hl

.compare
;=@cmp
	ld a, [de]
	cp [hl]
	inc hl
	inc de
	jr nz, .differs

	dec b
;=@cmp
	jr nz, .compare

	pop hl

.forbidden
;>         return True
	scf
	ret

.differs
;>@nx     p += 8
	pop hl
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
;=@nx
	ld h, a
;>     if mem[p] == 0xFF:
;>         return False
	ld a, [hl]
	cp $ff
	jr nz, .next

	scf
	ccf
	ret


;@ def CheckNameTaken() -> carry
;@ path: menu/names
;@ Carry when another of the 20 monster records already has the name in wNameInput (the record
;@ being named, wChosenMonName, is skipped). Names match up to their first $9F, $F0 or 0.
;@ The loop stops at the first empty record.
;@ test: skip uses RAM addresses
CheckNameTaken::
;> for c in range(20):
	ld c, $00

.record
;>     p = MonsterField(wMonsters, c)
	ld a, c
	push bc
	ld hl, wMonsters
	call MonsterField
	pop bc
;>     if mem[p] == 0:                  # empty record: no more monsters
;>         return False
	ld a, [hl]
	or a
	jr z, .free

;>     p += 1                          # the name
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>@s     if p == wChosenMonName:   # the monster being named
;>         continue
	ld a, [wChosenMonName]
	ld e, a
	ld a, [wChosenMonName + 1]
	ld d, a
	ld a, e
	sub l
;=@s
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld a, d
	or e
;=@s
	jr z, .nextRecord

;>     for i in range(8):
	ld de, wNameInput
	ld b, $08

.letter
;>         ch = wNameInput[i]
;>@e         if ch in (0x9F, 0xF0, 0):      # end of the new name
;>             break
	ld a, [de]
	cp $9f
	jr z, .nameEnd

	cp $f0
	jr z, .nameEnd

;=@e
	cp $00
	jr z, .nameEnd

;>@d         if ch != mem[p + i]:
;>             break
	cp [hl]
	inc hl
	inc de
	jr nz, .nextRecord

;=@d
	dec b
	jr nz, .letter

.taken
;>     else:
;>         return True                  # 8 letters equal
	scf
	ret

.nameEnd
;>@n     if ch in (0x9F, 0xF0, 0) and mem[p + i] in (0x9F, 0xF0, 0):   # both names end here
;>         return True
	ld a, [hl]
	cp $9f
	jr z, .taken

	cp $f0
	jr z, .taken

;=@n
	cp $00
	jr z, .taken

.nextRecord
	inc c
	ld a, c
	cp $14
	jr nz, .record

.free
;> return False
	scf
	ccf
	ret


;@ path: menu/names
;@ Names that may not be given (8 bytes each, padded with $9F; $FF ends the list).
ForbiddenNames::
	db $34, $55, $42, $8e, $9f, $9f, $9f, $9f
	db $34, $55, $42, $8e, $2d, $9f, $9f, $9f
	db $34, $55, $34, $55, $9f, $9f, $9f, $9f
	db $28, $43, $55, $2d, $9f, $9f, $9f, $9f
	db $43, $55, $2d, $9f, $9f, $9f, $9f, $9f
	db $28, $46, $2d, $9f, $9f, $9f, $9f, $9f
	db $31, $36, $2b, $30, $9f, $9f, $9f, $9f
	db $68, $6d, $62, $67, $9f, $9f, $9f, $9f
	db $26, $55, $2d, $9f, $9f, $9f, $9f, $9f
	db $2a, $55, $33, $43, $9f, $9f, $9f, $9f
	db $62, $9f, $9f, $9f, $9f, $9f, $9f, $9f
	db $62, $62, $9f, $9f, $9f, $9f, $9f, $9f
	db $62, $62, $62, $9f, $9f, $9f, $9f, $9f
	db $62, $62, $62, $62, $9f, $9f, $9f, $9f
	db $ff

;@ def DrawKeyboardCursor()
;@ path: menu/names
;@ Draws the keyboard cursor: tile $A0 under the key wMenuChoice2 * 17 + wMenuChoice (from
;@ KeyboardKeyPositions), tile $E0 under all others. A moving cursor blinks (redrawn every 16 calls,
;@ off while wCursorBlink bit 4 is set); one with bit 7 set (chosen) stays on. The wide keys are
;@ covered whole: key $40 is four tiles wide, key $51 three, keys $41-$43 and $52-$54 draw nothing.
;@ The screen offset is kept in hNumber / $FFD6 and the tile in $FFD7 for the two helpers below.
;@ test: skip writes VRAM
DrawKeyboardCursor::
;> cur = wMenuChoice2 * 17 + wMenuChoice
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wMenuChoice]
	add l
;> keys = KeyboardKeyPositions
	ld de, KeyboardKeyPositions
	ld c, a
;> if not cur & 0x80:
	bit 7, a
	jr nz, .draw

;>@b     t = wCursorBlink & 0x0F
;>     wCursorBlink += 1
	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
;=@b
	pop af
;>     if t:
;>         return                       # only every 16th call
	ld a, c
	ret nz

.draw
;> b = 0
	ld c, a
	ld b, $00

.next
;> while True:
;>@k     pos = mem16[keys + 2 * b]
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if pos == 0xFFFF:
;>         return
	and l
	cp $ff
	ret z

;>@o     mem16[hNumber] = pos; WindowBgAddrWrapped9(pos)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
;=@o
	call WindowBgAddrWrapped9
	pop bc
	pop de
;>     if (cur & 0x7F) != b: tile = 0xE0
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .tile

;>     elif cur & 0x80: tile = 0xA0
	ld a, $a0
	bit 7, c
	jr nz, .tile

;>     else: tile = 0xE0 if wCursorBlink & 0x10 else 0xA0
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .tile

	ld a, $a0

.tile
;>     mem[0xFFD7] = tile
	ldh [$ffd7], a
;>@w     if b not in (0x41, 0x42, 0x43, 0x52, 0x53, 0x54):
	ld a, b
	cp $41
	jr z, .skip

	cp $42
	jr z, .skip

;=@w
	cp $43
	jr z, .skip

	cp $52
	jr z, .skip

	cp $53
	jr z, .skip

;=@w
	cp $54
	jr z, .skip

;>         PutKeyboardCursorTile()
	call PutKeyboardCursorTile
;>         extra = 3 if b == 0x40 else 2 if b == 0x51 else 0
	ld a, b
	cp $40
	jr z, .four

	cp $51
	jr z, .three

	jr .skip

.four
;>         for i in range(extra):
;>             KeyboardCursorNextTile()
	call KeyboardCursorNextTile

.three
	call KeyboardCursorNextTile
	call KeyboardCursorNextTile

.skip
;>     b += 1
	inc b
	jp .next


;@ def KeyboardCursorNextTile()
;@ path: menu/names
;@ Moves the saved screen offset one tile right and draws the cursor tile there
;@ (falls through to PutKeyboardCursorTile).
;@ test: skip writes VRAM
KeyboardCursorNextTile::
;> mem[hNumber] += 1
	push af
	ld hl, hNumber
	inc [hl]
;>@a WindowBgAddrWrapped9(mem16[hNumber])
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	push de
	push bc
;=@a
	call WindowBgAddrWrapped9
	pop bc
	pop de
	pop af
;> PutKeyboardCursorTile()             # falls through

;@ def PutKeyboardCursorTile(hl)
;@ path: menu/names
;@ Writes the tile in $FFD7 to VRAM at hl and to the tilemap buffer at the offset in hNumber.
;@ test: skip writes VRAM
PutKeyboardCursorTile::
;> WriteVRAM(hl, mem[0xFFD7])
	ldh a, [$ffd7]
	call WriteVRAM
;>@b wTilemapBuffer[mem16[hNumber]] = mem[0xFFD7]
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
;=@b
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	pop af
;=@b
	ld [hl], a
	ret


;@ def CountNameLetters() -> c
;@ path: menu/names
;@ Counts the letters in the first 7 slots of wNameInput, not counting $8D, $8E and empty ($9F).
;@ The byte after it is a lone, unused ret.
CountNameLetters::
;> c = 0
;> for i in range(8):
	ld hl, wNameInput
	ld b, $08
	ld c, $00

.loop
;>     ch = wNameInput[i]
;>@e     if i == 7: return c                 # (the 8th slot is never looked at)
	ld a, [hli]
	dec b
	ret z

	inc de
;>@s     if ch not in (0x8D, 0x8E, 0x9F):
;>         c += 1
	cp $8d
	jr z, .loop

	cp $8e
	jr z, .loop

;=@s
	cp $9f
	jr z, .loop

	inc c
	jr .loop

	db $c9

;@ def DrawNameCursor()
;@ path: menu/names
;@ Draws the name cursor: tile $A0 under the slot after the last letter (NameSlotPositions,
;@ CountNameLetters), tile $E0 under the others.
;@ test: skip writes VRAM
DrawNameCursor::
;> n = CountNameLetters()
	call CountNameLetters
;> b = 0
	ld de, NameSlotPositions
	ld b, $00

.next
;> while True:
;>@k     pos = mem16[NameSlotPositions + 2 * b]
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if pos == 0xFFFF:
;>         return
	and l
	cp $ff
	ret z

;>@o     mem16[hNumber] = pos; WindowBgAddrWrapped9(pos)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
;=@o
	call WindowBgAddrWrapped9
	pop bc
	pop de
;>     tile = 0xA0 if b == n else 0xE0
	ld a, c
	cp b
	ld a, $e0
	jr nz, .put

	ld a, $a0

.put
;>     WriteVRAM(hl, tile)
	call WriteVRAM
;>@w     wTilemapBuffer[pos] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
;=@w
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	pop af
;=@w
	ld [hl], a
;>     b += 1
	inc b
	jr .next

;@ path: menu/names
;@ Screen offsets (row * 32 + column) of the name entry's 4 letter slots.
NameSlotPositions::
	dw $0068, $0069, $006a, $006b, $ffff

;@ path: menu/names
;@ Picture shown in the name entry for each wChosenMonPic: graphics (bank, entry) as high, low
;@ byte. 0 is Terry, 1-15 are all $3140, and from 16 on come the monsters (wChosenMonPic - $10 is
;@ the species).
NamePictures::
	dw $2f00, $3140, $3140, $3140, $3140, $3140, $3140, $3140
	dw $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140
	dw $2f01, $2f02, $2f03, $2f04, $2f05, $2f06, $2f07, $2f08
	dw $2f09, $2f0a, $2f0b, $2f0c, $2f0d, $2f0e, $2f0f, $2f10
	dw $3800, $3801, $3802, $3803, $3804, $3805, $3806, $3807
	dw $3808, $3809, $380a, $380b, $380c, $380d, $380e, $380f
	dw $3810, $3811, $3812, $3813, $3814, $3815, $3816, $3817
	dw $3818, $3819, $381a, $381b, $381c, $381d, $381e, $381f
	dw $3820, $3821, $3822, $3823, $3824, $3825, $3826, $3827
	dw $3828, $3829, $382a, $382b, $382c, $382d, $382e, $382f
	dw $3830, $3831, $3832, $3833, $3834, $3835, $3836, $3837
	dw $3838, $3839, $383a, $383b, $383c, $383d, $383e, $383f
	dw $3840, $3841, $3842, $3843, $3844, $3845, $3846, $3847
	dw $3900, $3901, $3902, $3903, $3904, $3905, $3906, $3907
	dw $3908, $3909, $390a, $390b, $390c, $390d, $390e, $390f
	dw $3910, $3911, $3912, $3913, $3914, $3915, $3916, $3917
	dw $3918, $3919, $391a, $391b, $391c, $391d, $391e, $391f
	dw $3920, $3921, $3922, $3923, $3924, $3925, $3926, $3927
	dw $3928, $3929, $392a, $392b, $392c, $392d, $392e, $392f
	dw $3930, $3931, $3932, $3933, $3934, $3935, $3936, $3937
	dw $3938, $3939, $393a, $393b, $393c, $393d, $393e, $393f
	dw $3940, $3941, $3942, $3943, $3944, $3945, $3946, $3947
	dw $3a00, $3a01, $3a02, $3a03, $3a04, $3a05, $3a06, $3a07
	dw $3a08, $3a09, $3a0a, $3a0b, $3a0c, $3a0d, $3a0e, $3a0f
	dw $3a10, $3a11, $3a12, $3a13, $3a14, $3a15, $3a16, $3a17
	dw $3a18, $3a19, $3a1a, $3a1b, $3a1c, $3a1d, $3a1e, $3a1f
	dw $3a20, $3a21, $3a22, $3a23, $3a24, $3a25, $3a26, $3a27
	dw $3a28, $3a29, $3a2a, $3a2b, $3a2c, $3a2d, $3a2e, $3a2f
	dw $3a30, $3a31, $3a32, $3a33, $3a34, $3a35, $3a36

;@ path: menu/gallery
;@ The picture gallery's frame with the monster picture tiles ($38-$40, $88-$90, ...), 20 x 17 tiles at row 0, column 0. Window layouts: dw screen offset (row * 32 + column), then the tiles, $D8 starts the next row, $D9 ends.
GalleryFrameLayout::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $38, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $88, $89, $8a, $8b, $8c, $8d, $8e
	db $8f, $90, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $41, $42, $43, $44, $45, $46
	db $47, $48, $49, $91, $92, $93, $94, $95, $96, $97, $98, $99, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $4a, $4b, $4c, $4d, $4e, $4f, $50, $51, $52, $9a, $9b, $9c
	db $9d, $9e, $9f, $a0, $a1, $a2, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $53, $54
	db $55, $56, $57, $58, $59, $5a, $5b, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $5c, $5d, $5e, $5f, $60, $61, $62, $63
	db $64, $ac, $ad, $ae, $af, $b0, $b1, $b2, $b3, $b4, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $b5, $b6, $b7, $b8, $b9
	db $ba, $bb, $bc, $bd, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $6e, $6f, $70, $71
	db $72, $73, $74, $75, $76, $be, $bf, $c0, $c1, $c2, $c3, $c4, $c5, $c6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $c7
	db $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 20 x 5 tiles at row 0, column 0.
UnusedLayout6E45::
	db $00
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8
	db $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0
	db $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/names
;@ Yes / No window of the name entry, 6 x 5 tiles at row 8, column 14.
NameYesNoLayout::
	db $0e, $01, $fa, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: arena/entry
;@ Yes / No window of the arena entry, 6 x 5 tiles at row 8, column 14.
ArenaYesNoLayout::
	db $0e
	db $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: item/shop
;@ Yes / No window of the shop, 6 x 5 tiles at row 8, column 14.
ShopYesNoLayout::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4
	db $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a7, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: item/shop
;@ The window showing the gold carried, 8 x 3 tiles at row 0, column 12.
GoldWindowLayout::
	db $0c, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: item/shop
;@ The shop's Buy / Sell / Quit menu, 8 x 7 tiles at row 0, column 0.
ShopMainMenuLayout::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: item/shop
;@ The shop's item list window (names and prices), 19 x 9 tiles at row 4, column 1.
ShopListLayout::
	db $81, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80
	db $81, $82, $83, $84, $85, $86, $87, $88, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92
	db $93, $94, $95, $96, $97, $98, $99, $9a, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: item/shop
;@ The quantity window when buying, 4 x 3 tiles at row 10, column 0.
BuyQuantityLayout::
	db $40, $01, $fa
	db $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd, $d9

;@ path: item/shop
;@ The quantity window when selling, 7 x 3 tiles at row 10, column 0.
SellQuantityLayout::
	db $40, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 6 x 5 tiles at row 8, column 0.
UnusedLayout705E::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 12 x 9 tiles at row 4, column 8.
UnusedLayout7083::
	db $88, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81
	db $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90
	db $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e
	db $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 8 x 5 tiles at row 0, column 0.
UnusedLayout70FA::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 5 tiles at row 0, column 0.
UnusedLayout7129::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a4
	db $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8
	db $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: item/vault
;@ The vault's item list window, 12 x 9 tiles at row 3, column 8.
VaultItemListLayout::
	db $68, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81
	db $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90
	db $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e
	db $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: item/vault/gold
;@ The window showing the gold kept in the vault, 8 x 3 tiles at row 3, column 12.
BankedGoldLayout::
	db $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: item/vault/gold
;@ The gold amount entry window, 14 x 3 tiles at row 10, column 6.
GoldEntryLayout::
	db $46, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused/layouts
;@ A window layout nothing uses, 11 x 13 tiles at row 0, column 0.
UnusedLayout7216::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $92, $98, $9c, $e3, $e0, $9c, $93, $93, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e3, $95, $91, $96, $e0, $9a, $e3, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $91, $94, $d5, $91, $96, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $e3, $90, $98, $90, $99, $d5
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $d6, $97, $d5, $d5, $e3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $a2, $95, $99, $e0, $e0, $e0, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 9 tiles at row 0, column 13.
UnusedLayout72B4::
	db $0d, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 11 tiles at row 0, column 13.
UnusedLayout72FE::
	db $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb
	db $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 9 tiles at row 0, column 0.
UnusedLayout7358::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94
	db $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81
	db $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85
	db $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89
	db $8a, $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 11 tiles at row 0, column 0.
UnusedLayout73A2::
	db $00, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb
	db $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 5 tiles at row 0, column 13.
UnusedLayout73FC::
	db $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused/layouts
;@ A window layout nothing uses, 19 x 6 tiles at row 0, column 0.
UnusedLayout7426::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9e, $90, $d6, $99, $d5, $98, $e4, $a0, $a1
	db $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $da
	db $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac, $ad, $ae, $af
	db $ff, $d8, $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0, $e0, $e0, $e0
	db $9f, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: arena/entry
;@ The arena's class list window (class letters and entry fees), 17 x 9 tiles at row 4, column 0.
ArenaClassLayout::
	db $80, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $84
	db $e0, $80, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $85, $e0, $81, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $86, $e0, $82, $e0, $91, $97, $90, $d6, $d6
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $87, $e0, $83, $e0, $91
	db $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 9 x 7 tiles at row 0, column 0.
UnusedLayout7544::
	db $00, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8a, $98, $d5, $d5
	db $92, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $94, $90, $99, $91, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 11 tiles at row 2, column 0.
UnusedLayout758C::
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $61, $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $65, $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 11 tiles at row 2, column 0.
UnusedLayout75E6::
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0
	db $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $61, $62, $63, $64
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $65, $66, $67, $68
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $69, $6a, $6b, $6c
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6d, $6e, $6f, $70
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 11 x 5 tiles at row 8, column 9.
UnusedLayout7640::
	db $09, $01, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73, $74
	db $75, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 11 x 3 tiles at row 5, column 9.
UnusedLayout767E::
	db $a9, $00, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73, $74, $75, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 11 x 3 tiles at row 10, column 9.
UnusedLayout76A4::
	db $49, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0
	db $65, $66, $67, $68, $69, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 11 x 3 tiles at row 10, column 0.
UnusedLayout76CA::
	db $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 13 x 9 tiles at row 4, column 7.
UnusedLayout76F0::
	db $87, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $65, $66, $67, $68
	db $69, $6a, $6b, $6c, $6d, $a0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74, $75
	db $76, $a1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $a2, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $a3, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 9 x 7 tiles at row 0, column 0.
UnusedLayout7770::
	db $00, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d5, $df, $9f, $de, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $de, $d5, $d6
	db $d6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 13 x 9 tiles at row 4, column 7.
UnusedLayout77B8::
	db $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $70, $71, $72, $73, $74, $75, $76, $77, $78, $9b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $9c, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c
	db $8d, $8e, $8f, $90, $91, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99
	db $9a, $9e, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: item/vault
;@ The vault's main menu window, 7 x 7 tiles at row 0, column 0.
VaultMainMenuLayout::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a4, $a5
	db $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a9
	db $aa, $ab, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $ac, $ad
	db $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 10 x 9 tiles at row 4, column 0.
UnusedLayout7872::
	db $80, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $9e, $9f, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $a0, $a1
	db $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 13 x 9 tiles at row 4, column 7.
UnusedLayout78D7::
	db $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $8c, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e
	db $6f, $70, $71, $72, $73, $74, $75, $76, $8d, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b
	db $7c, $7d, $7e, $7f, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88
	db $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 8 x 5 tiles at row 0, column 12.
UnusedLayout7957::
	db $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $95, $9d
	db $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused/layouts
;@ A window layout nothing uses, 8 x 5 tiles at row 8, column 0.
UnusedLayout7986::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a1, $a7, $a9
	db $a4, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a4
	db $a2, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 6 x 5 tiles at row 8, column 14.
UnusedLayout79B5::
	db $0e
	db $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 8 x 11 tiles at row 0, column 0.
UnusedLayout79DA::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $67, $68, $69, $6a, $6b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $6c, $6d, $6e, $6f, $70, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $71, $72, $73, $74, $75, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $76, $77, $78, $79, $7a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $7b, $7c, $7d, $7e, $7f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 12 x 11 tiles at row 0, column 8.
UnusedLayout7A3F::
	db $08, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85
	db $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93
	db $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2
	db $a3, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/layouts
;@ A full-screen layout nothing uses, 20 x 18 tiles at row 0, column 0.
UnusedScreen7AD0::
	db $00, $00, $01, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $03
	db $d8, $04, $80, $81, $82, $83, $84, $85, $00, $00, $14, $15, $16, $17, $18, $19
	db $1a, $1b, $1c, $00, $05, $d8, $04, $86, $87, $88, $89, $8a, $8b, $00, $0a, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $05, $d8, $04, $8c, $8d, $8e, $8f
	db $90, $91, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $05, $d8
	db $04, $92, $93, $94, $95, $96, $97, $11, $00, $00, $1d, $1e, $1f, $20, $21, $22
	db $23, $24, $25, $05, $d8, $04, $98, $99, $9a, $9b, $9c, $9d, $12, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $05, $d8, $04, $9e, $9f, $a0, $a1, $a2
	db $a3, $00, $00, $00, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $05, $d8, $04
	db $0d, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0f, $05, $d8, $04, $a5, $a6, $a7, $a8, $a9, $aa, $00, $00, $00, $2f, $30
	db $31, $32, $33, $34, $35, $36, $37, $05, $d8, $04, $10, $10, $10, $10, $10, $10
	db $10, $10, $00, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $05, $d8, $04, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $41, $42, $43, $44, $45, $46, $47, $48
	db $49, $05, $d8, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $05, $d8, $04, $4a, $4b, $4c, $4d, $4e, $4f, $50
	db $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $05, $d8, $04, $13, $13
	db $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13
	db $05, $d8, $04, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $67, $68
	db $69, $6a, $6b, $6c, $6d, $05, $d8, $04, $13, $13, $13, $13, $13, $13, $13, $13
	db $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $05, $d8, $04, $6e, $6f, $70
	db $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $05
	db $d8, $06, $07, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $09, $d9

;@ path: unused/layouts
;@ A window layout nothing uses, 7 x 5 tiles at row 8, column 0.
UnusedLayout7C4C::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused/layouts
;@ A window layout nothing uses, 8 x 5 tiles at row 8, column 0.
UnusedLayout7C76::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $95, $9d, $93
	db $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9c
	db $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/names
;@ The box the typed name is shown in, 8 x 4 tiles at row 1, column 6.
NameBoxLayout::
	db $26
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $00, $01, $02, $03
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: menu/names
;@ The name entry keyboard, second page, 20 x 12 tiles at row 5, column 0.
KeyboardLayout1::
	db $a0, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $24, $25, $26
	db $27, $28, $e0, $3e, $3f, $40, $41, $42, $e0, $e0, $91, $92, $93, $94, $95, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $29, $2a, $2b, $2c, $2d, $e0, $43, $44, $45
	db $46, $47, $e0, $e0, $49, $4b, $4d, $8d, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $2e, $2f, $30, $31, $32, $e0, $48, $e0, $4a, $e0, $4c, $e0, $e0, $60, $6a
	db $60, $70, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $33, $34, $35, $37, $38
	db $e0, $4e, $4f, $50, $51, $52, $e0, $e0, $47, $98, $50, $e0, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $39, $3a, $3b, $3c, $3d, $e0, $53, $54, $55, $36, $9c
	db $e0, $e0, $28, $53, $50, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: menu/names
;@ The name entry keyboard, first page, 20 x 12 tiles at row 5, column 0.
KeyboardLayout0::
	db $a0, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $24, $25, $26, $27, $28
	db $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $e0, $04, $05, $06, $07, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b
	db $3c, $3d, $e0, $08, $09, $0a, $0b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $3e
	db $3f, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $e0, $0c, $0d, $63
	db $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $4b, $4c, $4d, $4e, $4f, $50, $51
	db $52, $53, $54, $55, $56, $57, $e0, $25, $24, $26, $2e, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $5c, $5e, $5f, $60, $61, $62, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $28, $31, $27, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: unused/padding
;@ Unused space at the end of the bank.
Bank09Padding::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
