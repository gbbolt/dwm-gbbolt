INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $012", ROMX[$4000], BANK[$12]

;@ path: system/banks
;@ Bank number byte at the start of the bank (read by the far-call routine to know which bank is mapped).
BankNumber_12::
	db $12

;@ def FarTable_12()
;@ path: menu/script
;@ Far-call table of bank $12 with a single entry, the routine right behind it: runs one frame of the menu a script opened (wScriptMenu): the farm keeper (3), the
;@ monster library (8), choosing one of the player's own monsters (9) or the item collector (10).
;@ The other menu numbers are handled in other banks; here they do nothing.
;@ test: skip jumps through a table to routines that call other banks
FarTable_12::
	dw FarTable_12 + 2
;> return ScriptMenuTable[wScriptMenu]()
	ld a, [wScriptMenu]
	rst $00

;@ path: menu/script
;@ Routine of each script menu number ($00-$0F) that bank $12 runs; unused numbers point at ScriptMenuNone.
ScriptMenuTable::
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw FarmKeeperMenu
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw LibraryMenu
	dw ChooseMonsterMenu
	dw CollectorMenu
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw ScriptMenuNone
	dw ScriptMenuNone

;@ def ScriptMenuNone()
;@ path: menu/script
;@ Placeholder for script menus this bank does not run.
ScriptMenuNone::
;> return
	ret


;@ def SnapToTile(coord: hl)
;@ path: menu/window
;@ Rounds the 16-bit position at `coord` (a scroll position) to the nearest multiple of 8,
;@ so menu windows line up with the background tiles.
;@ test: hl = rand(0xC000, 0xDFFE)
SnapToTile::
;> value = mem16[coord] + 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
;> mem16[coord] = value & 0xFFF8
	ld a, [hl]
	and $f8
	ld [hl], a
;> return
	ret


;@ def NextBgColumn(addr: hl) -> hl
;@ path: menu/window
;@ Moves a BG map address one column right, wrapping around within its 32-tile row.
NextBgColumn::
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


;@ def WindowBgAddr(offset: hl) -> hl
;@ path: menu/window
;@ BG map address of a window offset (row * 32 + column) measured from the screen's top
;@ left corner (wWindowBgMap), wrapping around inside the 1 KiB BG map.
WindowBgAddr::
;> addr = wWindowBgMap + offset
	ld a, [wWindowBgMap]
	add l
	ld l, a
	ld a, [wWindowBgMap + 1]
	adc h
;> addr &= 0x03FF
	and $03
	ld h, a
;> return (wWindowBgMap & 0xFC00) | addr
	ld a, [wWindowBgMap + 1]
	and $fc
	or h
	ld h, a
	ret


;@ def TilemapBufferAddr(offset: hl) -> hl
;@ path: menu/window
;@ Address of a window offset (row * 32 + column) in wTilemapBuffer.
TilemapBufferAddr::
;> addr = wTilemapBuffer + offset
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
;> return addr
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	ret


;@ def WindowBgAddrWrapped(offset: hl) -> hl
;@ path: menu/window
;@ Like WindowBgAddr, but the column also wraps around inside its BG map row, so a window
;@ near the right edge of the 32-tile map continues at its left edge.
WindowBgAddrWrapped::
;> addr = WindowBgAddr(offset & 0xFFE0)              # start of the row
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call WindowBgAddr
;> for _ in range(offset & 0x1F):
	ld a, b
	and $1f
	jr z, .done
	ld b, a
.column
;>     addr = NextBgColumn(addr)
	call NextBgColumn
	dec b
	jr nz, .column
.done
;> return addr
	pop bc
	ret


;@ def DrawLayoutToVram(layout: de)
;@ path: unused
;@ Unused: draws a window layout (format see DrawWindowLayout) straight into the BG map
;@ instead of into wTilemapBuffer, wrapping rows and columns inside the map.
;@ test: skip writes to VRAM with the LCD-safe write
DrawLayoutToVram::
;> offset = mem16[layout]
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;> addr = row = WindowBgAddrWrapped(offset)         # row is kept in hNumber
	call WindowBgAddrWrapped
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
.loop
;>@loop for b in layout_bytes(layout + 2):
	ld a, [de]
	inc de
;>     if b == 0xD9: return                             # end of the layout
	cp $d9
	ret z
;>     if b == 0xD8:                                    # next row
	cp $d8
	jr nz, .tile
;>         row += 32                                   # row is kept in hNumber
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;>         row = 0x9800 | (row & 0x03FF)               # wrap inside the BG map
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, h
	and $03
;>         addr = row
	or $98
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;=@loop
	jr .loop
.tile
;>     else:
;>         WriteVRAM(addr, b)
	call WriteVRAM
;>         addr = NextBgColumn(addr)
	call NextBgColumn
;=@loop
	jr .loop

;@ def DrawWindowLayout(layout: de)
;@ path: menu/window
;@ Draws a window layout into wTilemapBuffer. A layout is a u16 offset (row * 32 + column
;@ in the 32-wide buffer) followed by tile numbers; $D8 starts the next row below the
;@ first tile of the current one, $D9 ends the layout. Window tiles: $FA/$EF/$FB top
;@ frame, $FE/$FF left and right sides, $FC/$EE/$FD bottom frame, $E0 blank.
;@ test: skip reads a layout from ROM
DrawWindowLayout::
;> offset = mem16[layout]
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;> addr = row = TilemapBufferAddr(offset)            # row is kept in hNumber
	call TilemapBufferAddr
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
.loop
;>@loop for b in layout_bytes(layout + 2):
	ld a, [de]
	inc de
;>     if b == 0xD9: return                             # end of the layout
	cp $d9
	ret z
;>     if b == 0xD8:                                    # next row
	cp $d8
	jr nz, .tile
;>@add         row += 32
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;=@add
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>         addr = row
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;=@loop
	jr .loop
.tile
;>     else:
;>         mem[addr] = b; addr += 1
	ld [hli], a
;=@loop
	jr .loop

;@ def CopyTilemapBufferToVram()
;@ path: menu/window
;@ Copies the whole wTilemapBuffer (18 rows of 32 tiles) into the BG map at wWindowBgMap,
;@ wrapping rows and columns inside the 32 x 32 map.
;@ test: skip writes to VRAM with the LCD-safe write
CopyTilemapBufferToVram::
;> row = wWindowBgMap
	ld a, [wWindowBgMap]
	ld l, a
	ld a, [wWindowBgMap + 1]
	ld h, a
;> src = wTilemapBuffer
	ld de, wTilemapBuffer
;> for _ in range(18):
	ld c, $12
.row
;>     addr = row
	ld b, $20
	push hl
.column
;>     for _ in range(32):
;>         WriteVRAM(addr, mem[src])
	ld a, [de]
	call WriteVRAM
;>@nc         addr = NextBgColumn(addr)
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
	jr nz, .column
;>@wrap     row = 0x9800 | ((row + 32) & 0x03FF)
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@wrap
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .row
;> return
	ret


;@ def DrawTextTiles(dest: hl, size: de)
;@ path: menu/window
;@ Renders text number wTextGroup:wTextIndex into letter tiles at VRAM address `dest`
;@ (e = number of lines, d = characters per line for the printer in bank $41), keeping the
;@ settings of the text box that is open.
;@ test: skip calls bank $41
DrawTextTiles::
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)    # on the stack
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = dest
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = lo(size)
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = hi(size)
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>@restore restore(saved)                                  # wTextTiles, wTextBoxLines, wTextBoxLineLength
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@restore
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawNameTiles(dest: hl, name: de)
;@ path: menu/window
;@ Copies a 4-letter monster name into wTextArg0 and renders it (text $0200, the
;@ argument string) into letter tiles at VRAM address `dest`.
;@ test: skip calls bank $41
DrawNameTiles::
;> CopyName(wTextArg0, name)
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
;>@save2 saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)    # on the stack
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save2
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = dest
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0                                   # text $0200: the string in wTextArg0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>@restore2 restore(saved)                                  # wTextTiles, wTextBoxLines, wTextBoxLineLength
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@restore2
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawCharTile(char: a, dest: hl)
;@ path: unused
;@ Unused: renders a single character (followed by the end code $F0) into a letter tile at
;@ VRAM address `dest`, like DrawNameTiles does for a name.
;@ test: skip calls bank $41
DrawCharTile::
;> wTextArg0[0] = char
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0                              # end of the string
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save3 saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)    # on the stack
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save3
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = dest
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
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0                                   # text $0200: the string in wTextArg0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>@restore3 restore(saved)                                  # wTextTiles, wTextBoxLines, wTextBoxLineLength
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@restore3
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret

;@ def RestoreTilemapBuffer()
;@ path: menu/window
;@ Rebuilds wTilemapBuffer from the background saved when the menu opened
;@ (wSavedTilemap, rows 0-15) and the party bar (wPartyBarTiles, rows 16-17), which
;@ removes all windows drawn into it.
RestoreTilemapBuffer::
;>@cp copy(wTilemapBuffer, wSavedTilemap, 0x200)
	ld hl, wTilemapBuffer
	ld de, wSavedTilemap
	ld bc, $0200
.copy
	ld a, [de]
	inc de
	ld [hli], a
;=@cp
	dec bc
	ld a, b
	or c
	jr nz, .copy
;> for row in range(2):
	ld de, wPartyBarTiles
	ld c, $02
.row
;>@rows     copy(wTilemapBuffer + 0x200 + row * 32, wPartyBarTiles + row * 32, 20)
	ld b, $14
.tile
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .tile
;=@rows
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@rows
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


;@ def ClearTilemapBuffer()
;@ path: menu/window
;@ Fills all of wTilemapBuffer (18 rows of 32) with the blank tile $E0.
ClearTilemapBuffer::
;>@fill fill(wTilemapBuffer, 0xE0, 0x240)
	ld hl, wTilemapBuffer
	ld bc, $0240
.loop
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
;=@fill
	or c
	jr nz, .loop
	ret


;@ def ClearBgMap()
;@ path: unused
;@ Unused: fills the whole BG map at $9800 (32 x 32 tiles) with the blank tile $E0.
;@ test: skip writes to VRAM with the LCD-safe write
ClearBgMap::
;> for addr in range(0x9800, 0x9C00):
	ld hl, $9800
	ld bc, $0400
.loop
;>     WriteVRAMInc(addr, 0xE0)
	ld a, $e0
	call WriteVRAMInc
	dec bc
	ld a, b
	or c
	jr nz, .loop
;> return
	ret

;@ def UpdatePagedList(cursor: hl, rows: b, count: c, table: de)
;@ path: menu/cursor
;@ Handles a list of `count` entries shown `rows` at a time. mem[cursor] is the row of
;@ the cursor (bit 7 = chosen), mem[cursor + 1] the page. Left/Right turn the page (with
;@ wrap-around; on a short last page the cursor is pulled up onto its last entry). Without
;@ a page turn, Up/Down/A are handled by UpdateMenuCursor on the rows of the current page.
;@ `table` is a cursor table whose first entry is where the page number is shown.
;@ test: skip draws into VRAM
UpdatePagedList::
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> rows_table = table + 2                             # skip the page number position
	inc de
	inc de
;> if wTextState == 0 and wJoyRepeat & 0x20:          # Left: previous page
	ld a, [wTextState]
	or a
	jp nz, .rows
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .notLeft
;>     page = u8(mem[cursor + 1] - 1)
	inc hl
	ld a, [hl]
	dec a
	push af
;>@p1     pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@p1
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>     if page >= pages: page = pages - 1                # wrap from the first page to the last
	pop af
	cp c
	jr c, .setPage
	ld a, c
	dec a
	jr .setPage
.notLeft
;> elif wJoyRepeat & 0x10:                            # Right: next page
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .rows
;>     page = mem[cursor + 1] + 1
	inc hl
	ld a, [hl]
	inc a
	push af
;>@p2     pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@p2
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>     if page >= pages: page = 0
	pop af
	cp c
	jr c, .setPage
	ld a, $00
;>@else else:                                         # no page turn
;>@pn     DrawPageNumber(cursor, rows, count, rows_table)
;>@ret     return UpdateMenuCursor(cursor, rows if mem[cursor + 1] != (count - 1) // rows else (count - 1) % rows + 1, rows_table)
.setPage
;> mem[cursor + 1] = page
	ld [hld], a
;> if page == pages - 1:                              # turned to the last page
	dec c
	cp c
	jr nz, MenuCursorMoved
;>@lr     last_rows = count % rows
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
;>     if last_rows != 0 and last_rows - 1 < mem[cursor]:
	or a
	jr z, MenuCursorMoved
	dec a
	cp [hl]
	jr nc, MenuCursorMoved
;>         mem[cursor] = last_rows - 1                  # pull the cursor onto the last entry
	ld [hl], a
;> return MenuCursorMoved(cursor, rows_table)
	jr MenuCursorMoved
.rows
;=@pn
	push bc
	push de
	push hl
	call DrawPageNumber
;=@pn
	pop hl
	pop de
	pop bc
;=@ret
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@ret
	ld [wListLastRows], a                               ; rows on the last page - 1
	ld a, b
	pop bc
	pop de
	ld c, a
;=@ret
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateMenuCursor
	ld a, [wListLastRows]
	inc a
;=@ret
	ld b, a

;@ def UpdateMenuCursor(cursor: hl, n: b, table: de)
;@ path: menu/cursor
;@ Moves a menu cursor over `n` entries: Up/Down (with auto-repeat) move it with
;@ wrap-around, A marks it chosen (bit 7); then the cursor is drawn at its position from
;@ `table` (u16 window offsets, $FFFF ends the table).
;@ test: skip draws into VRAM
UpdateMenuCursor::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:                              # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp
;>     row = u8(mem[cursor] - 1)
	ld a, [hl]
	dec a
;>     if row >= n: row = n - 1                         # wrap to the bottom
	cp b
	jr c, .move
	dec b
	ld a, b
	jr .move
.notUp
;> elif wJoyRepeat & 0x80:                            # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, MenuCursorCheckA
;>     row = mem[cursor] + 1
	ld a, [hl]
	inc a
;>     if row >= n: row = 0                             # wrap to the top
	cp b
	jr c, .move
	ld a, $00
;> else:
;>     return MenuCursorCheckA(cursor, table)
.move
;> mem[cursor] = row
	ld [hl], a
;> return MenuCursorMoved(cursor, table)

;@ def MenuCursorMoved(cursor: hl, table: de)
;@ path: menu/cursor
;@ Restarts the cursor blink after the cursor moved, then goes on like MenuCursorCheckA.
;@ test: skip draws into VRAM
MenuCursorMoved::
;> wCursorBlink = 0                                   # show the cursor at once
	xor a
	ld [wCursorBlink], a
	push hl
	push de
	pop de
	pop hl
;> return MenuCursorCheckA(cursor, table)

;@ def MenuCursorCheckA(cursor: hl, table: de)
;@ path: menu/cursor
;@ Marks the cursor chosen (bit 7) when A was pressed and draws it.
;@ test: skip draws into VRAM
MenuCursorCheckA::
;> if wJoyPressed & 0x01:                             # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw
;>     mem[cursor] |= 0x80
	set 7, [hl]
.draw
;> DrawMenuCursor(mem[cursor], table)
	ld a, [hl]
	call DrawMenuCursor
	ret


;@ path: unused
;@ Unused code fragment: a Left/Right version of the cursor movement of UpdateMenuCursor
;@ (res 7,[hl]; Left = previous, Right = next entry), which jumps back into that routine's
;@ store / draw part with relative jumps. Nothing calls it.
UpdateMenuCursorLeftRight::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

;@ def ResetCursorBlink()
;@ path: menu/cursor
;@ Restarts the cursor blink so the cursor is drawn at once.
ResetCursorBlink::
;> wCursorBlink = 0
	xor a
	ld [wCursorBlink], a
	ret


;@ def DrawMenuCursor(cursor: a, table: de)
;@ path: menu/cursor
;@ Draws the cursor tiles of a menu into the BG map and wTilemapBuffer: at every
;@ position of `table` (u16 window offsets up to $FFFF) a blank ($E0), except at
;@ entry cursor & $7F: $E9 when chosen (bit 7), else the blinking arrow $E8 (blank
;@ while wCursorBlink bit 4 is set). Unless chosen this only happens every 16th call.
;@ test: skip writes to VRAM with the LCD-safe write
DrawMenuCursor::
;> if not cursor & 0x80:
	ld c, a
	bit 7, a
	jr nz, .draw
;>     t = wCursorBlink & 0x0F
	ld a, [wCursorBlink]
	and $0f
	push af
;>     wCursorBlink += 1
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
;>     if t != 0: return
	pop af
	ld a, c
	ret nz
.draw
;> for i in range(0x100):
	ld c, a
	ld b, $00
.loop
;>@loop     offset = mem16[table + 2 * i]
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if offset == 0xFFFF: return
	and l
	cp $ff
	ret z
;>@addr     addr = WindowBgAddrWrapped(offset)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@addr
	call WindowBgAddrWrapped
	pop bc
	pop de
;>     tile = 0xE0
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .put
;>     if i == cursor & 0x7F:
;>@tile         tile = 0xE9 if cursor & 0x80 else 0xE0 if wCursorBlink & 0x10 else 0xE8
	ld a, $e9
	bit 7, c
	jr nz, .put
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
;=@tile
	jr nz, .put
	ld a, $e8
.put
;>     WriteVRAM(addr, tile)
	call WriteVRAM
;>@buf     mem[TilemapBufferAddr(offset)] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@buf
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	pop af
;=@buf
	ld [hl], a
	inc b
;=@loop
	jr .loop

;@ def DrawPageNumber(cursor: hl, rows: b, count: c, table: de)
;@ path: menu/cursor
;@ When a list does not fit on one page (rows < count), draws the page number
;@ (tile $F1 + page, i.e. 1, 2, ...) one tile left of the page position, the u16 entry
;@ just before `table`; mem[cursor + 1] is the page.
;@ test: skip writes to VRAM with the LCD-safe write
DrawPageNumber::
;> if rows >= count: return
	ld a, b
	cp c
	ret nc
;> page = mem[cursor + 1]
	inc hl
	ld c, [hl]
;>@off offset = mem16[table - 2]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
;=@off
	ld h, a
	inc de
;> if offset == 0xFFFF: return
	and l
	cp $ff
	ret z
;>@addr addr = WindowBgAddrWrapped(offset - 1)
	dec hl
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
;=@addr
	push bc
	call WindowBgAddrWrapped
	pop bc
	pop de
;> WriteVRAM(addr, 0xF1 + (page & 0x7F))
	ld a, c
	and $7f
	add $f1
	call WriteVRAM
;>@buf mem[TilemapBufferAddr(offset - 1)] = 0xF1 + (page & 0x7F)
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@buf
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	pop af
;=@buf
	ld [hl], a
	ret


;@ def DrawListFrame(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws the page mark of a list window into wTilemapBuffer at the first entry of
;@ `table`: when the list has more entries than rows, the "more" mark $E7 with the page
;@ number ($F1 + page) left of it, else the plain bottom frame $EE. Then draws the cursor
;@ (DrawCursorAt) at row mem[cursor] using the rest of the table.
;@ test: skip writes to VRAM with the LCD-safe write
DrawListFrame::
;> row = mem[cursor]
	ld a, [hli]
	push af
	push hl
;>@pos pos = TilemapBufferAddr(mem16[table])
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	ld h, a
;=@pos
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
;> mem[pos] = 0xE7 if rows < count else 0xEE
	ld a, b
	cp c
	ld a, $ee
	jr nc, .mark
	ld a, $e7
.mark
	ld [hld], a
;> if rows < count:
	pop bc
	jr nc, .done
;>     mem[pos - 1] = 0xF1 + mem[cursor + 1]          # page number
	ld a, [bc]
	add $f1
	ld [hl], a
.done
;> return DrawCursorAt(row, table + 2)
	pop af

;@ def DrawCursorAt(cursor: a, table: de)
;@ path: menu/cursor
;@ Draws the cursor tile into wTilemapBuffer at entry cursor & $7F of `table`:
;@ $E9 when chosen (bit 7), else the arrow $E8 or a blank while wCursorBlink bit 4 is set.
;@ The other entries are left as they are.
;@ test: skip calls a routine that works on the VRAM address of the cursor
DrawCursorAt::
;>@off offset = mem16[table + 2 * cursor]            # (bit 7 doubles away)
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;=@off
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;>@wb WindowBgAddrWrapped(offset)                      # its result is not used
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@wb
	call WindowBgAddrWrapped
	pop bc
	pop de
;>@tile2 tile = 0xE9 if cursor & 0x80 else 0xE0 if wCursorBlink & 0x10 else 0xE8
	ld a, $e9
	bit 7, c
	jr nz, .put
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
;=@tile2
	jr nz, .put
	ld a, $e8
.put
;>@buf2 mem[TilemapBufferAddr(offset)] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@buf2
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	pop af
;=@buf2
	ld [hl], a
	ret


;@ def PrintMenuText(n: hl)
;@ path: menu/script
;@ Prints message number wScriptMenuText + n (the open script menu's n-th message).
;@ test: skip prints a message
PrintMenuText::
;>@pm PrintMessage(wScriptMenuText + n)
	ld a, [wScriptMenuText]
	add l
	ld l, a
	ld a, [wScriptMenuText + 1]
	adc h
	ld h, a
;=@pm
	call PrintMessage
	ret


;@ def FarmKeeperMenu()
;@ path: menu/farm
;@ Script menu 3, the farm keeper: runs the current step (wMenuStep) of the farm menu.
;@ test: skip jumps through a table to routines that call other banks
FarmKeeperMenu::
;> return FarmKeeperSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: menu/farm
;@ Steps of the farm keeper menu: set up, open the menu, choose an option, run it, close.
FarmKeeperSteps::
	dw FarmKeeperInit
	dw FarmKeeperOpenMenu
	dw FarmMainMenuInput
	dw FarmRunOption
	dw FarmKeeperClose

;@ def FarmKeeperInit()
;@ path: menu/farm
;@ Sets the farm menu up: lines the scroll position up with the tiles so the windows sit
;@ on the background grid, clears the menu cursors, loads the menu font and renders the
;@ menu words into letter tiles.
;@ test: skip decompresses graphics into VRAM
FarmKeeperInit::
;> SnapToTile(hScrollX)
	ld hl, hScrollX
	call SnapToTile
;> SnapToTile(hScrollY)
	ld hl, hScrollY
	call SnapToTile
;> fill(wLinkChoice, 0, 8)                            # wLinkChoice .. wListLastRows: the menu cursors
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@bg wWindowBgMap = 0x9800 + ((lo(hScrollY) * 4 + lo(hScrollX) // 8) & 0x03FF)    # top left corner of the screen
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@bg
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
;=@bg
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
;=@bg
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DecompressVRAM(0x2E10, 0x8800)                     # menu font tiles
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x44
	ld a, $44
	ld [wTextIndex], a
;> DrawTextTiles(0x9600, 0x0501)
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> ResetCursorBlink()
	call ResetCursorBlink
;> hSpriteBGTile = 0x60                               # window tiles cover the sprites
	ld a, $60
	ldh [hSpriteBGTile], a
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def FarmKeeperOpenMenu()
;@ path: menu/farm
;@ Once the keeper's greeting is printed, draws the farm menu.
;@ test: skip draws into VRAM
FarmKeeperOpenMenu::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def DrawFarmMainMenu()
;@ path: menu/farm
;@ Draws the farm menu window (six options) and the message window into wTilemapBuffer,
;@ with the cursor on the option in wLinkChoice (the menu choice byte).
DrawFarmMainMenu::
;> DrawWindowLayout(FarmMainMenuWindow)
	ld de, FarmMainMenuWindow
	call DrawWindowLayout
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wLinkChoice, FarmMainMenuCursorPos)
	ld de, FarmMainMenuCursorPos
	ld a, [wLinkChoice]
	call DrawCursorAt
	ret


;@ def FarmMainMenuInput()
;@ path: menu/farm
;@ Farm menu: moves the cursor over the six options. B or Start closes the menu, A runs
;@ the option (after clearing the cursors the options use).
;@ test: skip draws into VRAM
FarmMainMenuInput::
;> UpdateMenuCursor(wLinkChoice, 6, FarmMainMenuCursorPos)
	ld de, FarmMainMenuCursorPos
	ld hl, wLinkChoice
	ld b, $06
	call UpdateMenuCursor
;> if wJoyPressed & 0x0A:                             # B or Start: close
	ld a, [wJoyPressed]
	and $0a
	jr z, .notB
;>     wMenuStep += 2
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A: run the option
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
;>     wLinkChoice |= 0x80                              # shown as chosen
	ld hl, wLinkChoice
	set 7, [hl]
;>     fill(wMenuChoice2, 0, 7)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     fill(wListCursor, 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr .done
.done
	ret


;@ path: menu/farm
;@ Cursor positions of the six farm menu options: u16 window offsets (row * 32 + column), $FFFF ends.
FarmMainMenuCursorPos::
	dw $0021, $0061, $00a1, $00e1, $0121, $0161, $ffff

;@ def FarmRunOption()
;@ path: menu/farm
;@ Runs the chosen farm menu option.
;@ test: skip jumps through a table to routines that call other banks
FarmRunOption::
;> return FarmOptionTable[wLinkChoice]()             # bit 7 doubles away in the table index
	ld a, [wLinkChoice]
	rst $00

;@ path: menu/farm
;@ The farm menu options: leave a monster, take one out, look at the farm, send one away,
;@ switch to the other pen, and quit.
FarmOptionTable::
	dw FarmDepositOption
	dw FarmWithdrawOption
	dw FarmViewOption
	dw FarmReleaseOption
	dw FarmSwitchOption
	dw FarmKeeperClose

;@ def FarmKeeperClose()
;@ path: menu/farm
;@ Closes the farm menu: removes its windows, rebuilds the party bar (copying its two
;@ rows into the field's party bar buffer at $C13C/$C150) and ends the script menu.
;@ test: skip draws into VRAM
FarmKeeperClose::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> BuildStatusBar()
	call BuildStatusBar
;> CopyPartyBarRow(0xC13C, wPartyBarTiles)
	ld hl, $c13c
	ld de, wPartyBarTiles
	call CopyPartyBarRow
;> CopyPartyBarRow(0xC150, wPartyBarTiles + 32)
	ld hl, $c150
	ld de, wPartyBarTiles + 32
	call CopyPartyBarRow
;> hSpriteClip = 0x80
	ld a, $80
	ldh [hSpriteClip], a
;> wFieldFlags &= ~0x10                               # the script menu is closed
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def CopyPartyBarRow(dest: hl, src: de)
;@ path: menu/farm
;@ Copies one 20-tile row.
;@ test: hl = rand(0xC000, 0xC100); de = rand(0xC200, 0xC300)
CopyPartyBarRow::
;>@cp copy(dest, src, 20)
	ld b, $14
.loop
	ld a, [de]
	ld [hli], a
	inc de
;=@cp
	dec b
	jr nz, .loop
	ret


;@ def FarmDepositOption()
;@ path: menu/farm/deposit
;@ Farm option "leave a monster": runs the current step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
FarmDepositOption::
;> return FarmDepositSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/farm/deposit
;@ Steps of leaving a monster at the farm: 0-9 choose a party monster and leave it; 10-22
;@ with only one monster in the party: exchange it for a farm monster instead.
FarmDepositSteps::
	dw FarmDepositStart
	dw FarmDepositShowParty
	dw FarmDepositPartyInput
	dw FarmDepositAskConfirm
	dw FarmDepositShowChoice
	dw FarmDepositChoiceInput
	dw FarmDepositDoIt
	dw FarmDepositDone
	dw FarmDepositViewStatus
	dw FarmDepositStatusReturn
	dw FarmSwapAsk
	dw FarmSwapShowYesNo
	dw FarmSwapYesNoInput
	dw FarmSwapBuildList
	dw FarmSwapShowList
	dw FarmSwapListInput
	dw FarmSwapAskConfirm
	dw FarmSwapShowChoice
	dw FarmSwapChoiceInput
	dw FarmSwapDoIt
	dw FarmSwapDone
	dw FarmSwapViewStatus
	dw FarmSwapStatusReturn

;@ def FarmDepositStart()
;@ path: menu/farm/deposit
;@ Deposit, step 0: without monsters there is nothing to leave. With a single party
;@ monster it can only be exchanged (message 4; offers the exchange when the farm has
;@ monsters, else ends); otherwise asks which monster to leave (message 3).
;@ test: skip prints a message
FarmDepositStart::
;> if wPartyCount == 0: return FarmNoMonsters()
	ld a, [wPartyCount]
	cp $00
	jr z, FarmNoMonsters
;> if wPartyCount == 1:
	cp $01
	jr nz, .several
;>     PrintMenuText(4)
	ld hl, $0004
	call PrintMenuText
;>     if CountFarmMonsters() == 0:
	call CountFarmMonsters
	or a
	jr nz, .canSwap
;>         wMenuSubStep = 7                               # nothing to exchange with
	ld a, $07
	ld [wMenuSubStep], a
	ret
.canSwap
;>     else:
;>         wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a
;>         wMenuSubStep = 10                              # offer the exchange
	ld a, $0a
	ld [wMenuSubStep], a
	ret
.several
;> else:
;>     PrintMenuText(3)
	ld hl, $0003
	call PrintMenuText
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmNoMonsters()
;@ path: menu/farm
;@ The player has no monster: prints message $06E1 and goes back to the farm menu.
;@ test: skip draws letter tiles
FarmNoMonsters::
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> PrintMessage(0x06E1)
	ld hl, $06e1
	call PrintMessage
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def FarmDepositShowParty()
;@ path: menu/farm/deposit
;@ Deposit, step 1: once the question is printed, shows the party list window with the
;@ selected monster's name, sex and level.
;@ test: skip draws into VRAM
FarmDepositShowParty::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> ShowSelectedPartyMonster()
	call ShowSelectedPartyMonster
;> LoadPartyNameTiles()
	call LoadPartyNameTiles
;> DrawFarmPartyWindow()
	call DrawFarmPartyWindow
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmPartyWindow()
;@ path: menu/farm
;@ Draws the farm menu with the party list window and the level window of the
;@ selected party monster into wTilemapBuffer, with the cursor on wMenuChoice2.
;@ test: skip draws letter tiles
DrawFarmPartyWindow::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(FarmPartyWindow)
	ld de, FarmPartyWindow
	call DrawWindowLayout
;> DrawWindowLayout(LevelWindow)
	ld de, LevelWindow
	call DrawWindowLayout
;> DrawSelectedPartyLevel()
	call DrawSelectedPartyLevel
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice2, PartyListCursorPos)
	ld de, PartyListCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt
	ret


;@ def LoadPartyNameTiles()
;@ path: menu/farm
;@ Renders the names of the three party slots into the letter tiles at $8800, $8840 and
;@ $8880 (empty slots get blank tiles) for the party list window.
;@ test: skip draws letter tiles
LoadPartyNameTiles::
;> LoadPartyNameSlot(0x8800, 1)
	ld hl, $8800
	ld a, $01
	call LoadPartyNameSlot
;> LoadPartyNameSlot(0x8840, 2)
	ld hl, $8840
	ld a, $02
	call LoadPartyNameSlot
;> LoadPartyNameSlot(0x8880, 3)
	ld hl, $8880
	ld a, $03
	call LoadPartyNameSlot
	ret


;@ def LoadPartyNameSlot(dest: hl, slot: a)
;@ path: menu/farm
;@ Renders the name of party member `slot` (1-3) into 4 letter tiles at `dest`, or
;@ blanks the 4 tiles ($FF/$00 rows: white) when the party has fewer monsters.
;@ test: skip draws letter tiles
LoadPartyNameSlot::
;> if wPartyCount < slot:
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr nc, .name
;>     for _ in range(0x20):                            # 4 tiles of 8 rows
	ld b, $20
.blank
;>         WriteVRAMInc(dest, 0xFF); dest += 1
	ld a, $ff
	call WriteVRAMInc
;>         WriteVRAMInc(dest, 0x00); dest += 1
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blank
;>     return
	ret
.name
;> name = PartyMonsterField(slot - 1, wMonName)
	push hl
	ld a, b
	dec a
	ld hl, wMonName
	call PartyMonsterField
;> DrawNameTiles(dest, name)
	ld e, l
	ld d, h
	pop hl
	call DrawNameTiles
	ret


;@ def ShowSelectedPartyMonster()
;@ path: menu/farm
;@ Shows name and sex of the party monster under the cursor (wMenuChoice2).
;@ test: skip draws letter tiles
ShowSelectedPartyMonster::
;>@mon return DrawMonsterNameAndSex(wParty[wMenuChoice2 & 0x7F])
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@mon
	adc h
	ld h, a
	ld a, [hl]

;@ def DrawMonsterNameAndSex(mon: a)
;@ path: menu/farm
;@ Renders the name of monster record `mon` into the letter tiles at $9650 and its sex
;@ mark (tile $A7 male / $A8 female) into the tile at $9690.
;@ test: skip draws letter tiles
DrawMonsterNameAndSex::
;>@dn DrawNameTiles(0x9650, MonsterField(mon, wMonName))
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, $9650
;=@dn
	call DrawNameTiles
	pop af
;> sex = mem[MonsterField(mon, wMonGender)] & 1
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9690
	and $01
;> wTextArg0[0] = 0xA7 + sex                          # sex mark
	add $a7
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)    # on the stack
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x9690
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
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0                                     # text $0200: the string in wTextArg0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>@restore restore(saved)                             # wTextTiles, wTextBoxLines, wTextBoxLineLength
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@restore
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawSelectedPartyLevel()
;@ path: menu/farm
;@ Fills the level window for the party monster under the cursor (wMenuChoice2).
;@ test: skip calls a routine that writes with the LCD-safe write
DrawSelectedPartyLevel::
;>@mon return DrawMonsterLevel(wParty[wMenuChoice2 & 0x7F])
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@mon
	adc h
	ld h, a
	ld a, [hl]

;@ def DrawMonsterLevel(mon: a)
;@ path: menu/farm
;@ Writes "Lv" (tile $DE) and the level of monster record `mon` into the level window of
;@ wTilemapBuffer (row 11, column 10), plus the party mark $E3 at column 18 when the
;@ monster is in the party (blank otherwise).
;@ test: skip calls a routine that writes with the LCD-safe write
DrawMonsterLevel::
;> level = mem[MonsterField(mon, wMonLevel)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> pos = TilemapBufferAddr(0x016A)
	ld hl, $016a
	call TilemapBufferAddr
;> mem[pos] = 0xDE                                    # "Lv"
	ld a, $de
	ld [hli], a
;> mem[pos + 1] = mem[pos + 2] = 0xE0
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
;> DrawTwoDigits(level, pos + 1)
	call DrawTwoDigits
;> if mem[MonsterField(mon, wMonsters)] == 2:          # in the party
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, .notInParty
;>     mem[TilemapBufferAddr(0x0172)] = 0xE3
	ld hl, $0172
	call TilemapBufferAddr
	ld a, $e3
	ld [hl], a
	ret
.notInParty
;> else:
;>     mem[TilemapBufferAddr(0x0172)] = 0xE0
	ld hl, $0172
	call TilemapBufferAddr
	ld a, $e0
	ld [hl], a
	ret


;@ def FarmDepositPartyInput()
;@ path: menu/farm/deposit
;@ Deposit, step 2: moves the cursor over the party list (updating name, sex and level
;@ when it moves). B goes back to the farm menu, A asks to confirm the chosen monster.
;@ test: skip draws into VRAM
FarmDepositPartyInput::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> old = wMenuChoice2
	ld de, PartyListCursorPos
	ld hl, wMenuChoice2
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
;> UpdateMenuCursor(wMenuChoice2, wPartyCount, PartyListCursorPos)
	call UpdateMenuCursor
;> if wMenuChoice2 != old:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .keys
;>     ShowSelectedPartyMonster()
	call ShowSelectedPartyMonster
;>     DrawWindowLayout(LevelWindow)
	ld de, LevelWindow
	call DrawWindowLayout
;>     DrawSelectedPartyLevel()
	call DrawSelectedPartyLevel
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.keys
;> if wJoyPressed & 0x02:                             # B: back to the farm menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;>     wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;>     DrawTextTiles(0x8AA0, 0x0601)                    # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;>     PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm
;@ Cursor positions of the party list window: 3 u16 window offsets (row * 32 + column), $FFFF ends.
PartyListCursorPos::
	dw $006e, $00ae, $00ee, $ffff

;@ def FarmDepositAskConfirm()
;@ path: menu/farm/deposit
;@ Deposit, step 3: prints the farm keeper's question about the chosen monster (message 5).
;@ test: skip prints a message
FarmDepositAskConfirm::
;> PrintMenuText(5)
	ld hl, $0005
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmDepositShowChoice()
;@ path: menu/farm/deposit
;@ Deposit, step 4: once the question is printed, opens the two-choice window (look at the
;@ monster's status / leave it).
;@ test: skip draws into VRAM
FarmDepositShowChoice::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawDepositChoice()
	call DrawDepositChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawDepositChoice()
;@ path: menu/farm/deposit
;@ Draws the two-choice window of the deposit with the cursor on wConfirmChoice.
DrawDepositChoice::
;> DrawWindowLayout(StatusOrOkWindow)
	ld de, StatusOrOkWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice, DepositChoiceCursorPos)
	ld de, DepositChoiceCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


;@ def FarmDepositChoiceInput()
;@ path: menu/farm/deposit
;@ Deposit, step 5: B closes the window and goes back to the party list; the first
;@ choice opens the monster's status screen (step 8), the second leaves it at the farm (step 6).
;@ test: skip draws into VRAM
FarmDepositChoiceInput::
;> UpdateMenuCursor(wConfirmChoice, 2, DepositChoiceCursorPos)
	ld de, DepositChoiceCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                             # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;>     DrawFarmPartyWindow()
	call DrawFarmPartyWindow
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     PrintMenuText(3)
	ld hl, $0003
	call PrintMenuText
;>     wMenuSubStep = 2
	ld a, $02
	ld [wMenuSubStep], a
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:                       # first choice: status screen
	ld a, [wConfirmChoice]
	cp $81
	jr z, .second
;>         wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>         wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>         wMenuSubStep = 8
	ld a, $08
	ld [wMenuSubStep], a
	jp .done
.second
;>     else:
;>         wMenuSubStep += 1                              # leave it at the farm
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/deposit
;@ Cursor positions of the deposit's two-choice window: 2 u16 window offsets, $FFFF ends.
DepositChoiceCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmDepositDoIt()
;@ path: menu/farm/deposit
;@ Deposit, step 6: takes the chosen monster out of the party (the record stays and is
;@ marked as a farm monster by CompactMonsters) and prints message 6.
;@ test: skip calls bank 1
FarmDepositDoIt::
;>@slot wParty[wMenuChoice2 & 0x7F] = 0xFF
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@slot
	adc h
	ld h, a
	ld [hl], $ff
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> PrintMenuText(6)
	ld hl, $0006
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmDepositDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu (redraws its words, message 1).
;@ test: skip draws letter tiles
FarmDepositDone::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def FarmDepositViewStatus()
;@ path: menu/farm/deposit
;@ Deposit, step 8: opens the monster status screen on the party, starting at the chosen
;@ monster; it runs over the menu (wMenuOverlay) and returns to step 9.
;@ test: skip calls bank 7
FarmDepositViewStatus::
;> wViewList = wParty
	ld hl, wParty
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;> wViewIndex = wMenuChoice2 & 0x7F
	ld a, [wMenuChoice2]
	and $7f
	ld [wViewIndex], a
;> wViewCount = wPartyCount
	ld a, [wPartyCount]
	ld [wViewCount], a
;> UpdateMonsterStatus()
	ld hl, far_UpdateMonsterStatus
	rst $10
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
	ret


;@ def FarmDepositStatusReturn()
;@ path: menu/farm/deposit
;@ Deposit, step 9: after the status screen, puts the cursor on the monster shown last,
;@ reloads the menu graphics and redraws the party list with the two-choice window.
;@ test: skip draws into VRAM
FarmDepositStatusReturn::
;> wMenuChoice2 = (wMenuChoice2 & 0x80) | wViewResult
	ld a, [wMenuChoice2]
	and $80
	ld b, a
	ld a, [wViewResult]
	or b
	ld [wMenuChoice2], a
;> DecompressVRAM(0x2E10, 0x8800)                     # menu font tiles
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x44
	ld a, $44
	ld [wTextIndex], a
;> DrawTextTiles(0x9600, 0x0501)
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> ShowSelectedPartyMonster()
	call ShowSelectedPartyMonster
;> LoadPartyNameTiles()
	call LoadPartyNameTiles
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> DrawFarmPartyWindow()
	call DrawFarmPartyWindow
;> DrawDepositChoice()
	call DrawDepositChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> PrintMenuText(5)
	ld hl, $0005
	call PrintMenuText
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def FarmSwapAsk()
;@ path: menu/farm/deposit
;@ Deposit with a single party monster, step 10: offers to exchange it for a farm
;@ monster (message 7).
;@ test: skip prints a message
FarmSwapAsk::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> PrintMenuText(7)
	ld hl, $0007
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmSwapShowYesNo()
;@ path: menu/farm/deposit
;@ Step 11: once the question is printed, opens the yes/no window.
;@ test: skip draws into VRAM
FarmSwapShowYesNo::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawSwapYesNo()
	call DrawSwapYesNo
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawSwapYesNo()
;@ path: menu/farm/deposit
;@ Draws the yes/no window of the exchange offer with the cursor on wConfirmChoice2.
DrawSwapYesNo::
;> DrawWindowLayout(FarmYesNoWindow)
	ld de, FarmYesNoWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice2, SwapYesNoCursorPos)
	ld de, SwapYesNoCursorPos
	ld a, [wConfirmChoice2]
	call DrawCursorAt
	ret


;@ def FarmSwapYesNoInput()
;@ path: menu/farm/deposit
;@ Step 12: yes goes on to the list of farm monsters; no or B back to the farm menu.
;@ test: skip draws into VRAM
FarmSwapYesNoInput::
;> UpdateMenuCursor(wConfirmChoice2, 2, SwapYesNoCursorPos)
	ld de, SwapYesNoCursorPos
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor
;> if not wJoyPressed & 0x02:
;>@a     if not wJoyPressed & 0x01: return
;>@b     QueueSound(0x59)
;>@c     if wConfirmChoice2 != 0x81:                     # yes
;>@d         wMenuSubStep += 1
;>@d         return
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
.back
;> # B, or A on "no": back to the farm menu
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	jr .done
.notB
;=@a
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;=@b
	ld a, $59
	call QueueSound
;=@c
	ld a, [wConfirmChoice2]
	cp $81
	jr z, .back
;=@d
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/deposit
;@ Cursor positions of the yes/no window: 2 u16 window offsets, $FFFF ends.
SwapYesNoCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmSwapBuildList()
;@ path: menu/farm/deposit
;@ Step 13: lists the farm monsters (wSceneObjects) and asks which one to take (message 8).
;@ test: skip prints a message
FarmSwapBuildList::
;> CountFarmMonsters()
	call CountFarmMonsters
;> ListFarmMonsters()
	call ListFarmMonsters
;> PrintMenuText(8)
	ld hl, $0008
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmSwapShowList()
;@ path: menu/farm/deposit
;@ Step 14: once the message is printed, shows the farm monster list.
;@ test: skip draws into VRAM
FarmSwapShowList::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;> DrawFarmSwapList()
	call DrawFarmSwapList
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmSwapList()
;@ path: menu/farm/deposit
;@ Draws the farm menu, the level window of the selected farm monster, the farm list
;@ window (4 rows a page) and the yes/no window into wTilemapBuffer.
;@ test: skip draws letter tiles
DrawFarmSwapList::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(LevelWindow)
	ld de, LevelWindow
	call DrawWindowLayout
;> DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;> DrawWindowLayout(FarmListWindow)
	ld de, FarmListWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawListFrame(wListCursor, FarmListCursorPos, 4, wListLength)
	ld de, FarmListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
;> DrawSwapYesNo()
	call DrawSwapYesNo
	ret


;@ def ShowSelectedFarmMonster()
;@ path: menu/farm
;@ Shows name and sex of the list entry under the cursor (page * 4 + row of wSceneObjects).
;@ test: skip draws letter tiles
ShowSelectedFarmMonster::
;>@i i = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@i
	add b
;>@m DrawMonsterNameAndSex(wSceneObjects[i])
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@m
	ld a, [hl]
	call DrawMonsterNameAndSex
	ret


;@ def DrawSelectedFarmLevel()
;@ path: menu/farm
;@ Fills the level window for the list entry under the cursor.
;@ test: skip calls a routine that writes with the LCD-safe write
DrawSelectedFarmLevel::
;>@i i = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@i
	add b
;>@m DrawMonsterLevel(wSceneObjects[i])
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@m
	ld a, [hl]
	call DrawMonsterLevel
	ret


;@ def FarmSwapListInput()
;@ path: menu/farm/deposit
;@ Step 15: moves the cursor over the farm list (pages with Left/Right), updating the
;@ name, sex and level shown. B goes back to the yes/no question, A asks to confirm.
;@ test: skip draws into VRAM
FarmSwapListInput::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;>@old old_row = wListCursor; old_page = wListPage
	ld de, FarmListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdatePagedList(wListCursor, 4, wListLength, FarmListCursorPos)
	call UpdatePagedList
;> if wListCursor != old_row:
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, .samePos
;>     ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>     DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.samePos
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .keys
;>     LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;>     ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>     DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.keys
;> if wJoyPressed & 0x02:                             # B: back to the yes/no question
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;>     RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;>     DrawFarmMainMenu()
	call DrawFarmMainMenu
;>     DrawSwapYesNo()
	call DrawSwapYesNo
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     PrintMenuText(7)
	ld hl, $0007
	call PrintMenuText
;>     wMenuSubStep = 12
	ld a, $0c
	ld [wMenuSubStep], a
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
.done
	ret


;@ def FarmSwapAskConfirm()
;@ path: menu/farm/deposit
;@ Step 16: asks about the chosen farm monster (message 9).
;@ test: skip prints a message
FarmSwapAskConfirm::
;> PrintMenuText(9)
	ld hl, $0009
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmSwapShowChoice()
;@ path: menu/farm/deposit
;@ Step 17: once the question is printed, opens the two-choice window (status / exchange).
;@ test: skip draws into VRAM
FarmSwapShowChoice::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawSwapChoice()
	call DrawSwapChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawSwapChoice()
;@ path: menu/farm/deposit
;@ Draws the two-choice window of the exchange with the cursor on wConfirmChoice.
DrawSwapChoice::
;> DrawWindowLayout(StatusOrOkWindow)
	ld de, StatusOrOkWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice, SwapChoiceCursorPos)
	ld de, SwapChoiceCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


;@ def FarmSwapChoiceInput()
;@ path: menu/farm/deposit
;@ Step 18: B goes back to the farm list (step 15), the first choice opens the status
;@ screen (step 21), the second makes the exchange (step 19).
;@ test: skip draws into VRAM
FarmSwapChoiceInput::
;> UpdateMenuCursor(wConfirmChoice, 2, SwapChoiceCursorPos)
	ld de, SwapChoiceCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                             # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;>     ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>     LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;>     DrawFarmSwapList()
	call DrawFarmSwapList
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     PrintMenuText(8)
	ld hl, $0008
	call PrintMenuText
;>     wMenuSubStep = 15
	ld a, $0f
	ld [wMenuSubStep], a
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:                       # first choice: status screen
	ld a, [wConfirmChoice]
	cp $81
	jr z, .second
;>         wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>         wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>         wMenuSubStep = 21
	ld a, $15
	ld [wMenuSubStep], a
	jr .done
.second
;>     else:
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/deposit
;@ Cursor positions of the exchange's two-choice window: 2 u16 window offsets, $FFFF ends.
SwapChoiceCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmSwapDoIt()
;@ path: menu/farm/deposit
;@ Step 19: puts the chosen farm monster in place of the only party monster (which stays at
;@ the farm), with both names in wTextArg0/wTextArg1 for message 10.
;@ test: skip calls bank 1
FarmSwapDoIt::
;>@cn CopyName(wTextArg0, MonsterField(wParty[0], wMonName))
	ld a, [wParty]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@cn
	call CopyName
;>@i i = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@i
	add b
;>@m mon = wSceneObjects[i]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@m
	ld a, [hl]
;>@cn2 CopyName(wTextArg1, MonsterField(mon, wMonName))
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@cn2
	call CopyName
;> wParty[0] = mon
	pop af
	ld [wParty], a
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> PrintMenuText(10)
	ld hl, $000a
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmSwapDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu.
;@ test: skip draws letter tiles
FarmSwapDone::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def FarmSwapViewStatus()
;@ path: menu/farm/deposit
;@ Step 21: opens the monster status screen on the farm list, at the chosen entry.
;@ test: skip calls bank 7
FarmSwapViewStatus::
;> wViewList = wSceneObjects
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;>@i wViewIndex = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@i
	add b
	ld a, a
	ld [wViewIndex], a
;> wViewCount = wListLength
	ld a, [wListLength]
	ld [wViewCount], a
;> UpdateMonsterStatus()
	ld hl, far_UpdateMonsterStatus
	rst $10
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
	ret


;@ def FarmSwapStatusReturn()
;@ path: menu/farm/deposit
;@ Step 22: after the status screen, puts the list cursor on the entry shown last,
;@ reloads the menu graphics and redraws the list with the two-choice window (step 18).
;@ test: skip draws into VRAM
FarmSwapStatusReturn::
;>@lc wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@lc
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;> DecompressVRAM(0x2E10, 0x8800)                     # menu font tiles
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x44
	ld a, $44
	ld [wTextIndex], a
;> DrawTextTiles(0x9600, 0x0501)
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;> CountFarmMonsters()
	call CountFarmMonsters
;> ListFarmMonsters()
	call ListFarmMonsters
;> LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> DrawFarmSwapList()
	call DrawFarmSwapList
;> DrawSwapChoice()
	call DrawSwapChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> PrintMenuText(9)
	ld hl, $0009
	call PrintMenuText
;> wMenuSubStep = 18
	ld a, $12
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


FarmWithdrawOption::
	ld a, [wMenuSubStep]
	rst $00

FarmWithdrawSteps::
	dw FarmWithdrawStart
	dw FarmWithdrawShowList
	dw FarmWithdrawListInput
	dw FarmWithdrawAskConfirm
	dw FarmWithdrawShowChoice
	dw FarmWithdrawChoiceInput
	dw FarmWithdrawDoIt
	dw FarmWithdrawDone
	dw FarmWithdrawViewStatus
	dw FarmWithdrawStatusReturn
	dw FarmPartyFullAsk
	dw FarmPartyFullShowYesNo
	dw FarmPartyFullYesNoInput
	dw FarmExchangeBuildList
	dw FarmExchangeShowList
	dw FarmExchangeListInput
	dw FarmExchangeAskConfirm
	dw FarmExchangeShowChoice
	dw FarmExchangeChoiceInput
	dw FarmExchangeDoIt
	dw FarmExchangeDone
	dw FarmExchangeViewStatus
	dw FarmExchangeStatusReturn
	dw FarmExchangeAskPartySlot
	dw FarmExchangeShowParty
	dw FarmExchangePartyInput
	dw FarmExchangeAskPartyConfirm
	dw FarmExchangeShowPartyChoice
	dw FarmExchangePartyChoiceInput
	dw FarmExchangeViewPartyStatus
	dw FarmExchangePartyStatusReturn

FarmWithdrawStart::
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	call CountFarmMonsters
	or a
	jr nz, jr_012_4c92

	ld hl, $000c
	call PrintMenuText
	ld a, $07
	ld [wMenuSubStep], a
	ret


jr_012_4c92:
	ld a, [wPartyCount]
	cp $03
	jr nz, jr_012_4ca9

	ld hl, $000d
	call PrintMenuText
	xor a
	ld [wConfirmChoice2], a
	ld a, $0a
	ld [wMenuSubStep], a
	ret


jr_012_4ca9:
	call ListFarmMonsters
	ld hl, $000b
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


CountFarmMonsters::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_4cbe:
	push de
	ld a, [de]
	or a
	jr z, jr_012_4cd4

	cp $02
	jr z, jr_012_4cd4

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_012_4cd4

	inc c

jr_012_4cd4:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_012_4cbe

	ld a, c
	ld [wListLength], a
	ret


ListFarmMonsters::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_4cfa:
	push de
	ld a, [de]
	or a
	jr z, jr_012_4d11

	cp $02
	jr z, jr_012_4d11

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_012_4d11

	ld [hl], c
	inc hl

jr_012_4d11:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_012_4cfa

	ret


FarmWithdrawShowList::
	ld a, [wTextState]
	or a
	ret nz

	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	call DrawFarmWithdrawList
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmWithdrawList::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $759a
	call DrawWindowLayout
	call DrawSelectedFarmLevel
	ld de, $71f4
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $4e26
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	call CopyTilemapBufferToVram
	ret


LoadFarmListNameTiles::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call LoadListNameSlot
	call LoadListNameSlot
	call LoadListNameSlot

LoadListNameSlot::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_4d97

	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call DrawNameTiles
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


jr_012_4d97:
	ld b, $20

jr_012_4d99:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_012_4d99

	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


FarmWithdrawListInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $4e26
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, jr_012_4dda

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_4dda:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_4ded

	call LoadFarmListNameTiles
	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_4ded:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4e14

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_4e25

jr_012_4e14:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_4e25

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_4e25:
jr_012_4e25:
	ret


FarmListCursorPos::
	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff

FarmWithdrawAskConfirm::
	ld hl, $000e
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmWithdrawShowChoice::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawWithdrawChoice
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawWithdrawChoice::
	ld de, $7b42
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $4eb6
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


FarmWithdrawChoiceInput::
	ld de, $4eb6
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4e8e

	ld hl, far_Call_56_4485
	rst $10
	call DrawFarmWithdrawList
	call CopyTilemapBufferToVram
	ld hl, $000b
	call PrintMenuText
	ld a, $02
	ld [wMenuSubStep], a
	jr jr_012_4eb5

jr_012_4e8e:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_4eb5

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_4eb1

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $08
	ld [wMenuSubStep], a
	jp Jump_012_4eb5


jr_012_4eb1:
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_4eb5:
jr_012_4eb5:
	ret


WithdrawChoiceCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmWithdrawDoIt::
	ld a, [wPartyCount]
	or a
	jr nz, jr_012_4eef

	xor a
	ld [wParty], a
	ld a, $02
	ld [wMonsters], a
	ld a, $ff
	ld [$ca8f], a
	ld a, $ff
	ld [$ca90], a
	ld a, $01
	ld [wPartyCount], a
	ld hl, far_RefreshPartyGfx
	rst $10
	ld bc, $0007
	call SetEventFlag
	ld hl, $000f
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


jr_012_4eef:
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$ca90], a
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, $000f
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmWithdrawDone::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	ret


FarmWithdrawViewStatus::
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld a, a
	ld [wViewIndex], a
	ld a, [wListLength]
	ld [wViewCount], a
	ld hl, far_UpdateMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


FarmWithdrawStatusReturn::
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
	ld [wListCursor], a
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $44
	ld [wTextIndex], a
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	ld hl, far_Call_56_4485
	rst $10
	call DrawFarmWithdrawList
	call DrawWithdrawChoice
	call CopyTilemapBufferToVram
	ld hl, $000e
	call PrintMenuText
	ld a, $05
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


FarmPartyFullAsk::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0010
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmPartyFullShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawPartyFullYesNo
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawPartyFullYesNo::
	ld de, $6f54
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $5059
	ld a, [wConfirmChoice2]
	call DrawCursorAt
	ret


FarmPartyFullYesNoInput::
	ld de, $5059
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_503f

jr_012_501f:
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_5058

jr_012_503f:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5058

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice2]
	cp $81
	jr z, jr_012_501f

	ld a, $17
	ld [wMenuSubStep], a

Jump_012_5058:
jr_012_5058:
	ret


PartyFullYesNoCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmExchangeBuildList::
	call ListFarmMonsters
	ld hl, $0013
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmExchangeShowList::
	ld a, [wTextState]
	or a
	ret nz

	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	call DrawFarmExchangeList
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmExchangeList::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $759a
	call DrawWindowLayout
	call DrawSelectedFarmLevel
	ld de, $71f4
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $4e26
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	call DrawPartyFullYesNo
	ret


FarmExchangeListInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $4e26
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, jr_012_50d7

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_50d7:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_50ea

	call LoadFarmListNameTiles
	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_50ea:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_510a

	call ShowExchangePartyMonster
	call LoadPartyNameTiles
	call DrawExchangePartyWindow
	ld hl, $0011
	call PrintMenuText
	call CopyTilemapBufferToVram
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_012_511f

jr_012_510a:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_511f

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wConfirmChoice], a

Jump_012_511f:
jr_012_511f:
	ret


FarmExchangeAskConfirm::
	ld hl, $0014
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmExchangeShowChoice::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawExchangeChoice
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawExchangeChoice::
	ld de, $7b42
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $51a5
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


FarmExchangeChoiceInput::
	ld de, $51a5
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_517e

	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	call DrawFarmExchangeList
	ld hl, $0013
	call PrintMenuText
	call CopyTilemapBufferToVram
	ld a, $0f
	ld [wMenuSubStep], a
	jr jr_012_51a4

jr_012_517e:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_51a4

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_51a0

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $15
	ld [wMenuSubStep], a
	jr jr_012_51a4

jr_012_51a0:
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_51a4:
jr_012_51a4:
	ret


ExchangeChoiceCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmExchangeDoIt::
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, $0015
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmExchangeDone::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	ret


FarmExchangeViewStatus::
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld a, a
	ld [wViewIndex], a
	ld a, [wListLength]
	ld [wViewCount], a
	ld hl, far_UpdateMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


FarmExchangeStatusReturn::
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
	ld [wListCursor], a
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $44
	ld [wTextIndex], a
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	call ListFarmMonsters
	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	ld hl, far_Call_56_4485
	rst $10
	call DrawFarmExchangeList
	call DrawExchangeChoice
	call CopyTilemapBufferToVram
	ld hl, $0014
	call PrintMenuText
	ld a, $12
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


FarmExchangeAskPartySlot::
	ld hl, $0011
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmExchangeShowParty::
	ld a, [wTextState]
	or a
	ret nz

	call ShowExchangePartyMonster
	call LoadPartyNameTiles
	call DrawExchangePartyWindow
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawExchangePartyWindow::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $71aa
	call DrawWindowLayout
	ld de, $759a
	call DrawWindowLayout
	call DrawExchangePartyLevel
	call ResetCursorBlink
	ld de, $5399
	ld a, [wMenuChoice3]
	call DrawCursorAt
	call DrawPartyFullYesNo
	ret


ShowExchangePartyMonster::
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call DrawMonsterNameAndSex
	ret


DrawExchangePartyLevel::
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call DrawMonsterLevel
	ret


FarmExchangePartyInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $5399
	ld hl, wMenuChoice3
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
	call UpdateMenuCursor
	pop af
	ld hl, wMenuChoice3
	cp [hl]
	jr z, jr_012_5363

	call ShowExchangePartyMonster
	ld de, $759a
	call DrawWindowLayout
	call DrawExchangePartyLevel
	call CopyTilemapBufferToVram

jr_012_5363:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5383

	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	call DrawPartyFullYesNo
	ld hl, $0010
	call PrintMenuText
	call CopyTilemapBufferToVram
	ld a, $0c
	ld [wMenuSubStep], a
	jr jr_012_5398

jr_012_5383:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5398

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wConfirmChoice], a

Jump_012_5398:
jr_012_5398:
	ret


ExchangePartyCursorPos::
	db $6e, $00, $ae, $00, $ee, $00, $ff, $ff

FarmExchangeAskPartyConfirm::
	ld hl, $0012
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmExchangeShowPartyChoice::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawExchangePartyChoice
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawExchangePartyChoice::
	ld de, $7b42
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $5427
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


FarmExchangePartyChoiceInput::
	ld de, $5427
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_53ff

	call ShowExchangePartyMonster
	call LoadPartyNameTiles
	call DrawExchangePartyWindow
	ld hl, $0011
	call PrintMenuText
	call CopyTilemapBufferToVram
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_012_5426

jr_012_53ff:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5426

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_5421

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $1d
	ld [wMenuSubStep], a
	jr jr_012_5426

jr_012_5421:
	ld a, $0d
	ld [wMenuSubStep], a

Jump_012_5426:
jr_012_5426:
	ret


ExchangePartyChoiceCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmExchangeViewPartyStatus::
	ld hl, wParty
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wMenuChoice3]
	and $7f
	ld [wViewIndex], a
	ld a, [wPartyCount]
	ld [wViewCount], a
	ld hl, far_UpdateMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


FarmExchangePartyStatusReturn::
	ld a, [wMenuChoice3]
	and $80
	ld b, a
	ld a, [wViewResult]
	or b
	ld [wMenuChoice3], a
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $44
	ld [wTextIndex], a
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	call ShowExchangePartyMonster
	call LoadPartyNameTiles
	ld hl, far_Call_56_4485
	rst $10
	call DrawExchangePartyWindow
	call DrawExchangePartyChoice
	call CopyTilemapBufferToVram
	ld hl, $0012
	call PrintMenuText
	ld a, $1c
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


FarmViewOption::
	ld a, [wMenuSubStep]
	rst $00

FarmViewSteps::
	dw FarmViewStart
	dw FarmViewShowCounts
	dw FarmViewKindInput
	dw FarmViewBuildList
	dw FarmViewShowList
	dw FarmViewListInput
	dw FarmViewStatus
	dw FarmViewStatusReturn
	dw FarmViewDone

FarmViewStart::
	ld a, [wPartyCount]
	cp $00
	jp z, FarmNoMonsters

	ld hl, $0016
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmViewShowCounts::
	ld a, [wTextState]
	or a
	ret nz

	call DrawFarmCounts
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmCounts::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $7768
	call DrawWindowLayout
	call DrawFarmCountNumbers
	call ResetCursorBlink
	ld de, $564a
	ld a, [wMenuChoice2]
	call DrawCursorAt
	call CopyTilemapBufferToVram
	ret


DrawFarmCountNumbers::
	ld hl, $00a6
	call DrawCountFarmMonsters
	ld hl, $00e6
	call DrawCountFarmEggs
	ld hl, $0126
	call DrawCountFarm2Monsters
	ld hl, $0166
	call DrawCountFarm2Eggs
	ret


DrawCountFarmMonsters::
	call TilemapBufferAddr
	push hl
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_5528:
	push de
	ld a, [de]
	or a
	jr z, jr_012_553e

	cp $02
	jr z, jr_012_553e

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_012_553e

	inc c

jr_012_553e:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_012_5528

	pop hl
	ld b, $00
	call PrintNumber2
	ret


DrawCountFarmEggs::
	call TilemapBufferAddr
	push hl
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_555c:
	push de
	ld a, [de]
	or a
	jr z, jr_012_556e

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_012_556e

	inc c

jr_012_556e:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_012_555c

	pop hl
	ld b, $00
	call PrintNumber2
	ret


DrawCountFarm2Monsters::
	call TilemapBufferAddr
	ld c, $00
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, jr_012_55b8

	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00

jr_012_5595:
	push hl
	call ReadSRAMByte
	or a
	jr z, jr_012_55ab

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call ReadSRAMByte
	or a
	jr nz, jr_012_55ab

	inc c

jr_012_55ab:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_012_5595

	pop hl

jr_012_55b8:
	ld b, $00
	call PrintNumber2
	ret


DrawCountFarm2Eggs::
	call TilemapBufferAddr
	ld c, $00
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, jr_012_55f5

	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00

jr_012_55d2:
	push hl
	call ReadSRAMByte
	or a
	jr z, jr_012_55e8

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call ReadSRAMByte
	or a
	jr z, jr_012_55e8

	inc c

jr_012_55e8:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_012_55d2

	pop hl

jr_012_55f5:
	ld b, $00
	call PrintNumber2
	ret


FarmViewKindInput::
	ld de, $564a
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_562d

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_5649

jr_012_562d:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5649

	ld a, $59
	call QueueSound
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_5649:
jr_012_5649:
	ret


FarmViewKindCursorPos::
	db $a1, $00, $e1, $00, $ff, $ff

FarmViewBuildList::
	call CountMonstersOfKind
	or a
	jr nz, jr_012_5662

	ld hl, $0017
	call PrintMenuText
	ld a, $08
	ld [wMenuSubStep], a
	ret


jr_012_5662:
	call ListMonstersOfKind
	ld hl, $0018
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


CountMonstersOfKind::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_5677:
	push de
	ld a, [de]
	or a
	jr z, jr_012_5695

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	jr nz, jr_012_5695

	inc c

jr_012_5695:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_012_5677

	ld a, c
	ld [wListLength], a
	ret


ListMonstersOfKind::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_56bb:
	push de
	ld a, [de]
	or a
	jr z, jr_012_56dc

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push hl
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, jr_012_56dc

	ld [hl], c
	inc hl

jr_012_56dc:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_012_56bb

	ret


FarmViewShowList::
	ld a, [wTextState]
	or a
	ret nz

	call ShowSelectedFarmMonster
	call LoadFarmViewListTiles
	call DrawFarmViewList
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmViewList::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $7768
	call DrawWindowLayout
	call DrawFarmCountNumbers
	call ResetCursorBlink
	ld de, $564a
	ld a, [wMenuChoice2]
	call DrawCursorAt
	ld de, $77cd
	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_572e

	ld de, $759a
	call DrawWindowLayout
	call DrawSelectedFarmLevel
	ld de, $71f4

jr_012_572e:
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $5913
	ld a, [wMenuChoice2]
	and $01
	jr z, jr_012_5741

	ld de, $591f

jr_012_5741:
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	call CopyTilemapBufferToVram
	ret


LoadFarmViewListTiles::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_5776

	ld hl, $8800
	call LoadListNameSlot
	call LoadListNameSlot
	call LoadListNameSlot
	call LoadListNameSlot
	ret


jr_012_5776:
	ld hl, $9650
	call LoadSpeciesNameSlot
	call LoadSpeciesNameSlot
	call LoadSpeciesNameSlot
	ld hl, $8800
	call LoadSpeciesNameSlot
	call LoadEggMarkTiles
	ret


LoadSpeciesNameSlot::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_57b6

	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


jr_012_57b6:
	ld b, $48

jr_012_57b8:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_012_57b8

	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


LoadEggMarkTiles::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call LoadEggMarkSlot
	call LoadEggMarkSlot
	call LoadEggMarkSlot

LoadEggMarkSlot::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_5866

	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, jr_012_580b

	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	and $01
	add $a7

jr_012_580b:
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
	pop hl
	push hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


jr_012_5866:
	ld b, $08

jr_012_5868:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_012_5868

	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


FarmViewListInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $5913
	ld a, [wMenuChoice2]
	and $01
	jr z, jr_012_5892

	ld de, $591f

jr_012_5892:
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, jr_012_58ba

	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_58ba

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_58ba:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_58d4

	call LoadFarmViewListTiles
	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_58d4

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_58d4:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_58fa

	call DrawFarmCounts
	ld hl, $0016
	call PrintMenuText
	xor a
	ld [wMenuOverlay], a
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_012_5912

jr_012_58fa:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5912

	ld a, $59
	call QueueSound
	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_5912:
jr_012_5912:
	ret


FarmViewMonsterCursorPos::
	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff

FarmViewEggCursorPos::
	db $92, $01, $a8, $00
	db $e8, $00, $28, $01, $68, $01, $ff, $ff

FarmViewStatus::
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld a, a
	ld [wViewIndex], a
	ld a, [wListLength]
	ld [wViewCount], a
	ld hl, far_UpdateMonsterStatus
	rst $10
	ret


FarmViewStatusReturn::
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
	ld [wListCursor], a
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $44
	ld [wTextIndex], a
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
	ld hl, far_Call_56_4485
	rst $10
	call ShowSelectedFarmMonster
	call LoadFarmViewListTiles
	call DrawFarmViewList
	ld hl, $0018
	call PrintMenuText
	call RunTextToEnd
	ld a, $05
	ld [wMenuSubStep], a
	ret


FarmViewDone::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	ret


FarmReleaseOption::
	ld a, [wMenuSubStep]
	rst $00

FarmReleaseSteps::
	dw FarmReleaseStart
	dw FarmReleaseShowCounts
	dw FarmReleaseKindInput
	dw FarmReleaseBuildList
	dw FarmReleaseShowList
	dw FarmReleaseListInput
	dw FarmReleaseAskConfirm
	dw FarmReleaseShowChoice
	dw FarmReleaseChoiceInput
	dw FarmReleaseDoIt
	dw FarmReleaseDone
	dw FarmReleaseViewStatus
	dw FarmReleaseStatusReturn

FarmReleaseStart::
	ld a, [wPartyCount]
	cp $00
	jp z, FarmNoMonsters

	ld hl, $001a
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmReleaseShowCounts::
	ld a, [wTextState]
	or a
	ret nz

	call DrawReleaseCounts
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawReleaseCounts::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $7768
	call DrawWindowLayout
	call DrawFarmCountNumbers
	call ResetCursorBlink
	ld de, $5a8e
	ld a, [wMenuChoice2]
	call DrawCursorAt
	ret


FarmReleaseKindInput::
	ld de, $5a8e
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5a55

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_5a74

jr_012_5a55:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5a74

	ld a, $59
	call QueueSound
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	call LoadReleaseMenuWords
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_5a74:
jr_012_5a74:
	ret


LoadReleaseMenuWords::
	ld a, $02
	ld [wTextGroup], a
	ld a, [wMenuChoice2]
	and $01
	add $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ret


ReleaseKindCursorPos::
	db $a1, $00, $e1, $00, $ff, $ff

FarmReleaseBuildList::
	call CountFarmOfKind
	or a
	jr nz, jr_012_5aa6

	ld hl, $001b
	call PrintMenuText
	ld a, $0a
	ld [wMenuSubStep], a
	ret


jr_012_5aa6:
	call ListFarmOfKind
	ld hl, $001c
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


CountFarmOfKind::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_5abb:
	push de
	ld a, [de]
	or a
	jr z, jr_012_5add

	cp $02
	jr z, jr_012_5add

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	jr nz, jr_012_5add

	inc c

jr_012_5add:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_012_5abb

	ld a, c
	ld [wListLength], a
	ret


ListFarmOfKind::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_012_5b03:
	push de
	ld a, [de]
	or a
	jr z, jr_012_5b28

	cp $02
	jr z, jr_012_5b28

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push hl
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, jr_012_5b28

	ld [hl], c
	inc hl

jr_012_5b28:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_012_5b03

	ret


FarmReleaseShowList::
	ld a, [wTextState]
	or a
	ret nz

	call ShowSelectedFarmMonster
	call LoadFarmViewListTiles
	call RestoreTilemapBuffer
	call DrawFarmReleaseList
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmReleaseList::
	call DrawFarmMainMenu
	ld de, $7768
	call DrawWindowLayout
	call DrawFarmCountNumbers
	call ResetCursorBlink
	ld de, $5a8e
	ld a, [wMenuChoice2]
	call DrawCursorAt
	ld de, $77cd
	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_5b7d

	ld de, $759a
	call DrawWindowLayout
	call DrawSelectedFarmLevel
	ld de, $71f4

jr_012_5b7d:
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $5c30
	ld a, [wMenuChoice2]
	and $01
	jr z, jr_012_5b90

	ld de, $5c3c

jr_012_5b90:
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	ret


FarmReleaseListInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $5c30
	ld a, [wMenuChoice2]
	and $01
	jr z, jr_012_5baf

	ld de, $5c3c

jr_012_5baf:
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, jr_012_5bd7

	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_5bd7

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_5bd7:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_5bf1

	call LoadFarmViewListTiles
	ld a, [wMenuChoice2]
	and $01
	jr nz, jr_012_5bf1

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_5bf1:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5c1a

	call DrawReleaseCounts
	call CopyTilemapBufferToVram
	ld hl, $001a
	call PrintMenuText
	xor a
	ld [wMenuOverlay], a
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_012_5c2f

jr_012_5c1a:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5c2f

	ld a, $59
	call QueueSound
	xor a
	ld [wMenuChoice3], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_5c2f:
jr_012_5c2f:
	ret


ReleaseMonsterCursorPos::
	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff

ReleaseEggCursorPos::
	db $92, $01, $a8, $00
	db $e8, $00, $28, $01, $68, $01, $ff, $ff

FarmReleaseAskConfirm::
	ld hl, $001d
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmReleaseShowChoice::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawReleaseChoice
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawReleaseChoice::
	ld de, $7b42
	ld a, [wMenuChoice2]
	and $01
	jr z, jr_012_5c75

	ld de, $7b6c

jr_012_5c75:
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $5cd9
	ld a, [wMenuChoice3]
	call DrawCursorAt
	ret


FarmReleaseChoiceInput::
	ld de, $5cd9
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5cb1

	xor a
	ld [wMenuOverlay], a
	call RestoreTilemapBuffer
	call DrawFarmReleaseList
	ld hl, $001c
	call PrintMenuText
	call CopyTilemapBufferToVram
	ld a, $05
	ld [wMenuSubStep], a
	jr jr_012_5cd8

jr_012_5cb1:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5cd8

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_012_5cd4

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $0b
	ld [wMenuSubStep], a
	jp Jump_012_5cd8


jr_012_5cd4:
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_5cd8:
jr_012_5cd8:
	ret


ReleaseChoiceCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmReleaseDoIt::
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	pop af
	push af
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	pop af
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	jr z, jr_012_5d2c

	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, $0b1d
	call PrintSystemText
	ld hl, wMenuSubStep
	inc [hl]
	ret


jr_012_5d2c:
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, $001e
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmReleaseDone::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	ret


FarmReleaseViewStatus::
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld a, a
	ld [wViewIndex], a
	ld a, [wListLength]
	ld [wViewCount], a
	ld hl, far_UpdateMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


FarmReleaseStatusReturn::
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
	ld [wListCursor], a
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
	ld de, $2e10
	ld hl, $8800
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $44
	ld [wTextIndex], a
	ld hl, $9600
	ld de, $0501
	call DrawTextTiles
	call LoadReleaseMenuWords
	call ShowSelectedFarmMonster
	call LoadFarmViewListTiles
	ld hl, far_Call_56_4485
	rst $10
	call RestoreTilemapBuffer
	call DrawFarmReleaseList
	call DrawReleaseChoice
	call CopyTilemapBufferToVram
	ld hl, $001d
	call PrintMenuText
	ld a, $08
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


FarmSwitchOption::
	ld a, [wMenuSubStep]
	rst $00

FarmSwitchSteps::
	dw FarmSwitchStart
	dw FarmSwitchShowYesNo
	dw FarmSwitchYesNoInput
	dw FarmSwitchCheck
	dw FarmSwitchAskAgain
	dw FarmSwitchDoIt
	dw FarmSwitchDone

FarmSwitchStart::
	ld a, [wPartyCount]
	cp $00
	jp z, FarmNoMonsters

	ld hl, wMonsters
	ld b, $14

jr_012_5e0b:
	ld a, [hl]
	cp $01
	jr z, jr_012_5e4d

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_012_5e0b

	ld a, [wFarm2Flags]
	bit 7, a
	jr z, jr_012_5e3c

	ld hl, sFarm2
	ld b, $14

jr_012_5e27:
	push hl
	push bc
	call ReadSRAMByte
	pop bc
	pop hl
	or a
	jr nz, jr_012_5e48

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_012_5e27

jr_012_5e3c:
	ld hl, $06cc
	call PrintMessage
	ld a, $06
	ld [wMenuSubStep], a
	ret


jr_012_5e48:
	ld hl, $0025
	jr jr_012_5e50

jr_012_5e4d:
	ld hl, $0022

jr_012_5e50:
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmSwitchShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	call DrawFarmSwitchYesNo
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmSwitchYesNo::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $78ab
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $5ecc
	ld a, [wConfirmChoice]
	call DrawCursorAt
	call CopyTilemapBufferToVram
	ret


FarmSwitchYesNoInput::
	ld de, $5ecc
	ld hl, wListCursor
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5eb3

jr_012_5e93:
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_5ecb

jr_012_5eb3:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5ecb

	ld a, $59
	call QueueSound
	ld a, [wListCursor]
	cp $81
	jr z, jr_012_5e93

	ld hl, wMenuSubStep
	inc [hl]

Jump_012_5ecb:
jr_012_5ecb:
	ret


FarmSwitchCursorPos::
	db $2f, $01, $6f, $01, $ff, $ff

FarmSwitchCheck::
	ld a, [wTextState]
	or a
	ret nz

	call InitFarm2
	ld hl, wMonsters
	ld b, $14

jr_012_5edf:
	ld a, [hl]
	cp $01
	jr z, jr_012_5ef4

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_012_5edf

	ld hl, $0026
	jr jr_012_5f1d

jr_012_5ef4:
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, jr_012_5f15

	ld hl, sFarm2
	ld b, $14

jr_012_5f00:
	push hl
	push bc
	call ReadSRAMByte
	pop bc
	pop hl
	or a
	jr nz, jr_012_5f1a

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_012_5f00

jr_012_5f15:
	ld hl, $0023
	jr jr_012_5f1d

jr_012_5f1a:
	ld hl, $0024

jr_012_5f1d:
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmSwitchAskAgain::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0022
	call PrintMenuText
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ret


FarmSwitchDoIt::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld bc, $0000

jr_012_5f58:
	ld a, b
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr z, jr_012_5f68

	call SwapRecordWithFarm2
	inc c

jr_012_5f68:
	inc b
	ld a, b
	cp $14
	jr nz, jr_012_5f58

	ld hl, far_CompactMonsters
	rst $10
	ld a, [wFieldFlags]
	push af
	xor a
	ld [wFieldFlags], a
	ld a, [wMenuStep]
	push af
	xor a
	ld [wMenuStep], a
	ld a, [wScriptRunning]
	push af
	xor a
	ld [wScriptRunning], a
	ld a, [wMenuOverlay]
	push af
	xor a
	ld [wMenuOverlay], a
	di
	call SaveGame
	ei
	pop af
	ld [wMenuOverlay], a
	pop af
	ld [wScriptRunning], a
	pop af
	ld [wMenuStep], a
	pop af
	ld [wFieldFlags], a
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	ret


SwapRecordWithFarm2::
	push bc
	ld a, b
	ld hl, wMonsters
	call MonsterField
	push hl
	ld a, c
	ld c, $95
	call Multiply
	ld a, l
	add $24
	ld l, a
	ld a, h
	adc $b1
	ld h, a
	pop de
	ld b, $95

jr_012_5fcd:
	ld a, [de]
	push af
	call ReadSRAMByte
	ld [de], a
	pop af
	call WriteSRAMByte
	inc de
	inc hl
	dec b
	jr nz, jr_012_5fcd

	pop bc
	ret


InitFarm2::
	ld hl, wFarm2Flags
	bit 7, [hl]
	ret nz

	set 7, [hl]
	ld hl, sFarm2
	ld bc, $0ba4

jr_012_5fec:
	xor a
	call WriteSRAMByte
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, jr_012_5fec

	ret


FarmSwitchDone::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuStep], a
	ret


DrawTwoDigits::
	ld de, $000a
	push bc
	call DivideBcByDe
	pop bc
	or a
	jr z, jr_012_6032

	ld de, $000a
	call DivideBcByDe
	call PutDigitTile
	call NextBgColumn2

jr_012_6032:
	ld a, c
	call PutDigitTile
	ret


DivideBcByDe::
	push hl
	ld h, $ff

jr_012_603a:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_012_603a

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


PutDigitTile::
	add $f0
	call WriteVRAM
	ret


NextBgColumn2::
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
	ret


LibraryMenu::
	ld a, [wMenuStep]
	rst $00

LibrarySteps::
	dw LibraryInit
	dw LibraryWait
	dw LibraryResetCursors
	dw LibraryRun
	dw LibraryClose

LibraryInit::
	ld hl, hScrollX
	call SnapToTile
	ld hl, hScrollY
	call SnapToTile
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [$c90a], a
	ld hl, far_ClearAttrMap
	rst $10
	call ClearTilemapBuffer
	ld de, $2e07
	call DrawWindowLayout
	call CopyTilemapBufferToVram
	ld de, $2e14
	ld hl, $9000
	call DecompressVRAM
	call ResetCursorBlink
	ld a, $01
	ld [wMenuOverlay], a
	ld hl, wMenuStep
	inc [hl]
	ret


LibraryWait::
	ld hl, wMenuStep
	inc [hl]
	ret


LibraryResetCursors::
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuSubStep], a
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ret


LibraryRun::
	jp LibraryDispatch


LibraryClose::
	call ClearTilemapBuffer
	call CopyTilemapBufferToVram
	ld hl, far_ReloadMapTileset
	rst $10
	ld hl, far_DrawMapScreen
	rst $10
	call BuildStatusBar
	call DrawStatusBar
	ld hl, far_LoadFieldActorGfx
	rst $10
	xor a
	ld [wMenuOverlay], a
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


LibraryDispatch::
	ld a, [wMenuSubStep]
	rst $00

LibrarySubSteps::
	dw LibraryStart
	dw LibraryShowFamilies
	dw LibraryFamilyInput
	dw LibraryEnterFamily
	dw LibraryShowMonsters
	dw LibraryMonsterInput
	dw LibraryShowMonster
	dw LibraryMonsterPageInput
	dw LibraryBackToList
	dw LibraryFamilyEmpty
	dw LibraryTurnPage

LibraryStart::
	ld hl, wMenuSubStep
	inc [hl]
	ret


LibraryShowFamilies::
	ld a, [wTextState]
	or a
	ret nz

	call LoadFamilyNameTiles
	call DrawLibraryWindows
	call ShowFamilyMonsters
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawLibraryWindows::
	call ClearTilemapBuffer
	ld de, $2e07
	call DrawWindowLayout
	ld de, $78d0
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $6226
	ld b, $05
	ld c, $0a
	ld hl, wLinkChoice
	call DrawListFrame
	ret


LoadFamilyNameTiles::
	ld a, [wMenuChoice2]
	ld b, a
	add a
	add a
	add b
	ld hl, $9670
	call LoadFamilyNameSlot
	call LoadFamilyNameSlot
	call LoadFamilyNameSlot
	call LoadFamilyNameSlot

LoadFamilyNameSlot::
	push af
	push hl
	ld [wTextIndex], a
	ld a, $04
	ld [wTextGroup], a
	ld de, $0501
	call DrawTextTiles
	pop hl
	ld a, l
	add $50
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	inc a
	ret


ShowFamilyMonsters::
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	call BuildFamilyList
	call LoadMonsterListNames
	ld de, $7935
	call DrawWindowLayout
	ret


LibraryFamilyInput::
	ld de, $6226
	ld hl, wLinkChoice
	ld c, $0a
	ld b, $05
	ld a, [hli]
	push af
	ld a, [hld]
	push af
	call UpdatePagedList
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, jr_012_61d9

	call LoadFamilyNameTiles
	call ShowFamilyMonsters
	call CopyTilemapBufferToVram

jr_012_61d9:
	pop af
	ld hl, wLinkChoice
	cp [hl]
	jr z, jr_012_61e6

	call ShowFamilyMonsters
	call CopyTilemapBufferToVram

jr_012_61e6:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_6219

	call BuildFamilyList
	ld a, [wListKnown]
	or a
	jr nz, jr_012_6205

	ld hl, $0004
	call PrintMenuText
	ld a, $09
	ld [wMenuSubStep], a
	jp Jump_012_6225


jr_012_6205:
	ld a, $59
	call QueueSound
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_6219:
	ld a, [wJoyPressed]
	bit 1, a
	jp z, Jump_012_6225

	ld hl, wMenuStep
	inc [hl]

Jump_012_6225:
	ret


FamilyCursorPos::
	db $46, $01, $21, $00, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

LibraryEnterFamily::
	call BuildFamilyList
	ld hl, $0003
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


BuildFamilyList::
	ld hl, wSceneObjects
	ld bc, $0020
	ld a, $ff
	call FillMemory
	ld a, [wMenuChoice2]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wLinkChoice]
	and $7f
	add b
	ld [wCurPartyMember], a
	ld hl, $6294
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld c, [hl]
	ld b, a
	ld d, $00
	ld e, $00
	ld hl, wSceneObjects

jr_012_6271:
	push bc
	push de
	push hl
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop hl
	pop de
	pop bc
	ld [hl], $e0
	jr z, jr_012_6284

	ld [hl], b
	inc e

jr_012_6284:
	inc d
	inc hl
	inc b
	ld a, b
	cp c
	jr nz, jr_012_6271

	ld a, d
	ld [wListLength], a
	ld a, e
	ld [wListKnown], a
	ret


FamilyFirstSpecies::
	db $00, $14, $2d, $46, $5a, $6e, $82, $9b, $af, $c8, $d7

LibraryShowMonsters::
	ld a, [wTextState]
	or a
	ret nz

	call LoadMonsterListNames
	call DrawLibraryMonsterList
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawLibraryMonsterList::
	call DrawLibraryWindows
	ld de, $7935
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $639e
	ld b, $05
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	call CopyTilemapBufferToVram
	ret


LoadMonsterListNames::
	ld a, [wListPage]
	ld b, a
	add a
	add a
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call LoadSpeciesNameSlot2
	call LoadSpeciesNameSlot2
	call LoadSpeciesNameSlot2
	call LoadSpeciesNameSlot2

LoadSpeciesNameSlot2::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_6310

	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


ClearNameSlot9::
jr_012_6310:
	ld b, $48

jr_012_6312:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_012_6312

	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


LibraryMonsterInput::
	ld de, $639e
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $05
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_6349

	call LoadMonsterListNames

jr_012_6349:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_6369

	call DrawLibraryWindows
	ld de, $7935
	call DrawWindowLayout
	call CopyTilemapBufferToVram
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuSubStep], a
	jr jr_012_639d

jr_012_6369:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_639d

	ld a, [wListPage]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld [wConfirmChoice], a
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	cp $e0
	jp z, Jump_012_639d

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_639d:
jr_012_639d:
	ret


MonsterListCursorPos::
	db $52, $01, $29, $00, $69, $00, $a9, $00, $e9, $00, $29, $01, $ff, $ff

LibraryShowMonster::
	call ClearTilemapBuffer
	call CopyTilemapBufferToVram
	call DrawMonsterPage
	call DrawMonsterPageFrame
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawMonsterPageFrame::
	ld de, $2e26
	ld hl, $8a50
	call DecompressVRAM
	ld de, $79c6
	call DrawWindowLayout
	call CopyTilemapBufferToVram
	ret


DrawMonsterPage::
	ld a, [wCurPartyMember]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld hl, $9140
	ld de, $0901
	call DrawTextTiles
	ld hl, wLibraryFlags
	ld a, [wCurPartyMember]
	call TestFlag
	ld a, $ff
	jr z, jr_012_63f4

	ld a, [wCurPartyMember]

jr_012_63f4:
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, $91d0
	ld de, $1201
	call DrawLongTextTiles
	ld a, [wCurPartyMember]
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	ld hl, $94a0
	ld de, $1203
	call DrawLongTextTiles
	call LoadSkillNameTiles
	ld a, [wCurPartyMember]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $8800
	call DecompressVRAM
	ld hl, $0021
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld a, [wCurPartyMember]
	ld [wPaletteSet], a
	ld a, $04
	ld [$c81f], a
	ld hl, far_LoadMonPicPalette
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	call LoadBreedingIcons
	ret


DrawLongTextTiles::
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld hl, far_PrintText_4D
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret


LoadSkillNameTiles::
	ld a, [wCurPartyMember]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld de, $da39
	ld hl, $92f0
	call LoadSkillNameSlot
	call LoadSkillNameSlot

LoadSkillNameSlot::
	push de
	push hl
	ld a, [de]
	cp $ff
	jp z, ClearNameSlot9

	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


LibraryMonsterPageInput::
	ld a, [wListLength]
	or a
	jr z, jr_012_6526

	cp $01
	jr z, jr_012_6526

	ld a, [wJoyPressed]
	bit 5, a
	jr z, jr_012_64fd

jr_012_64da:
	ld a, [wListLength]
	ld c, a
	cp $01
	jr z, jr_012_64fd

	ld a, [wConfirmChoice]
	dec a
	ld [wConfirmChoice], a
	cp c
	jr c, jr_012_64f1

	dec c
	ld a, c
	ld [wConfirmChoice], a

jr_012_64f1:
	call IsListEntryUnknown
	jr z, jr_012_64da

	ld a, $0a
	ld [wMenuSubStep], a
	jr jr_012_6543

jr_012_64fd:
	ld a, [wJoyPressed]
	bit 4, a
	jr z, jr_012_6526

jr_012_6504:
	ld a, [wListLength]
	ld c, a
	cp $01
	jr z, jr_012_6526

	ld a, [wConfirmChoice]
	inc a
	ld [wConfirmChoice], a
	cp c
	jr c, jr_012_651a

	xor a
	ld [wConfirmChoice], a

jr_012_651a:
	call IsListEntryUnknown
	jr z, jr_012_6504

	ld a, $0a
	ld [wMenuSubStep], a
	jr jr_012_6543

jr_012_6526:
	ld a, [wJoyPressed]
	bit 1, a
	jr nz, jr_012_6535

	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_6540

jr_012_6535:
	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	jr jr_012_6543

Jump_012_6540:
	call DrawBreedingIcons

jr_012_6543:
	ret


IsListEntryUnknown::
	ld a, [wConfirmChoice]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $e0
	ret


LibraryBackToList::
	call ClearTilemapBuffer
	call CopyTilemapBufferToVram
	call LoadFamilyNameTiles
	call LoadMonsterListNames
	call DrawLibraryMonsterList
	ld a, $05
	ld [wMenuSubStep], a
	ret


LibraryFamilyEmpty::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuSubStep], a
	ret


LibraryTurnPage::
	ld a, [wConfirmChoice]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	call DrawMonsterPage
	call DrawMonsterPageFrame
	ld a, $07
	ld [wMenuSubStep], a
	ld a, [wConfirmChoice]
	ld b, a
	ld a, $05
	call Divide8
	or $80
	ld [wListCursor], a
	ld a, b
	ld [wListPage], a
	ret


LoadBreedingIcons::
	ld a, [wCurPartyMember]
	ld [wBreedQuery], a
	ld hl, far_LookupBreedPair
	rst $10
	ld a, [wBreedPair]
	ld hl, $8600
	call LoadBreedIconTiles
	ld [wBreedPair], a
	ld a, [wBreedTemp]
	ld hl, $8700
	call LoadBreedIconTiles
	ld [wBreedTemp], a
	ret


LoadBreedIconTiles::
	cp $ff
	ret z

	cp $fa
	jr z, jr_012_65ef

	cp $f0
	jr nc, jr_012_65ef

	push af
	push hl
	add $10
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $f2
	ld l, a
	ld a, h
	adc $65
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call DecompressVRAM
	pop af
	ret


jr_012_65ef:
	ld a, $ff
	ret


BreedIconGfx::
	db $00, $2f, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $01, $2f, $02, $2f, $03, $2f, $04, $2f, $05, $2f, $06, $2f, $07, $2f, $08, $2f
	db $09, $2f, $0a, $2f, $0b, $2f, $0c, $2f, $0d, $2f, $0e, $2f, $0f, $2f, $10, $2f
	db $00, $38, $01, $38, $02, $38, $03, $38, $04, $38, $05, $38, $06, $38, $07, $38
	db $08, $38, $09, $38, $0a, $38, $0b, $38, $0c, $38, $0d, $38, $0e, $38, $0f, $38
	db $10, $38, $11, $38, $12, $38, $13, $38, $14, $38, $15, $38, $16, $38, $17, $38
	db $18, $38, $19, $38, $1a, $38, $1b, $38, $1c, $38, $1d, $38, $1e, $38, $1f, $38
	db $20, $38, $21, $38, $22, $38, $23, $38, $24, $38, $25, $38, $26, $38, $27, $38
	db $28, $38, $29, $38, $2a, $38, $2b, $38, $2c, $38, $2d, $38, $2e, $38, $2f, $38
	db $30, $38, $31, $38, $32, $38, $33, $38, $34, $38, $35, $38, $36, $38, $37, $38
	db $38, $38, $39, $38, $3a, $38, $3b, $38, $3c, $38, $3d, $38, $3e, $38, $3f, $38
	db $40, $38, $41, $38, $42, $38, $43, $38, $44, $38, $45, $38, $46, $38, $47, $38
	db $00, $39, $01, $39, $02, $39, $03, $39, $04, $39, $05, $39, $06, $39, $07, $39
	db $08, $39, $09, $39, $0a, $39, $0b, $39, $0c, $39, $0d, $39, $0e, $39, $0f, $39
	db $10, $39, $11, $39, $12, $39, $13, $39, $14, $39, $15, $39, $16, $39, $17, $39
	db $18, $39, $19, $39, $1a, $39, $1b, $39, $1c, $39, $1d, $39, $1e, $39, $1f, $39
	db $20, $39, $21, $39, $22, $39, $23, $39, $24, $39, $25, $39, $26, $39, $27, $39
	db $28, $39, $29, $39, $2a, $39, $2b, $39, $2c, $39, $2d, $39, $2e, $39, $2f, $39
	db $30, $39, $31, $39, $32, $39, $33, $39, $34, $39, $35, $39, $36, $39, $37, $39
	db $38, $39, $39, $39, $3a, $39, $3b, $39, $3c, $39, $3d, $39, $3e, $39, $3f, $39
	db $40, $39, $41, $39, $42, $39, $43, $39, $44, $39, $45, $39, $46, $39, $47, $39
	db $00, $3a, $01, $3a, $02, $3a, $03, $3a, $04, $3a, $05, $3a, $06, $3a, $07, $3a
	db $08, $3a, $09, $3a, $0a, $3a, $0b, $3a, $0c, $3a, $0d, $3a, $0e, $3a, $0f, $3a
	db $10, $3a, $11, $3a, $12, $3a, $13, $3a, $14, $3a, $15, $3a, $16, $3a, $17, $3a
	db $18, $3a, $19, $3a, $1a, $3a, $1b, $3a, $1c, $3a, $1d, $3a, $1e, $3a, $1f, $3a
	db $20, $3a, $21, $3a, $22, $3a, $23, $3a, $24, $3a, $25, $3a, $26, $3a, $27, $3a
	db $28, $3a, $29, $3a, $2a, $3a, $2b, $3a, $2c, $3a, $2d, $3a, $2e, $3a, $2f, $3a
	db $30, $3a, $31, $3a, $32, $3a, $33, $3a, $34, $3a, $35, $3a, $36, $3a

DrawBreedingIcons::
	ld hl, wLibraryFlags
	ld a, [wCurPartyMember]
	call TestFlag
	ret z

	ld a, [wBreedPair]
	cp $ff
	jr z, jr_012_67d4

	cp $f0
	ret nc

jr_012_67d4:
	ld a, [wBreedTemp]
	cp $ff
	jr z, jr_012_67de

	cp $f0
	ret nc

jr_012_67de:
	ld a, [wBreedPair]
	cp $ff
	jr z, jr_012_6810

	push af
	ld hl, hSpriteX
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $28
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_012_6804

	ld b, $01

jr_012_6804:
	ld a, b
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10

jr_012_6810:
	ld a, [wBreedTemp]
	cp $ff
	ret z

	push af
	ld hl, hSpriteX
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $38
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_012_6835

	ld b, $01

jr_012_6835:
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


ChooseMonsterMenu::
	ld a, [wMenuStep]
	rst $00

ChooseMonsterSteps::
	dw ChooseMonsterInit
	dw ChooseMonsterWait
	dw ChooseMonsterResetCursors
	dw ChooseMonsterRun
	dw ChooseMonsterClose

ChooseMonsterInit::
	ld hl, hScrollX
	call SnapToTile
	ld hl, hScrollY
	call SnapToTile
	ld a, $ff
	ld [wChosenMonPic], a
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [$c90a], a
	call RestoreTilemapBuffer
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
	call ResetCursorBlink
	ld hl, wMenuStep
	inc [hl]
	ret


ChooseMonsterWait::
	ld hl, wMenuStep
	inc [hl]
	ret


ChooseMonsterResetCursors::
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuSubStep], a
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ret


ChooseMonsterRun::
	jr ChooseMonsterDispatch

ChooseMonsterClose::
	call RestoreTilemapBuffer
	ld de, $2e07
	call DrawWindowLayout
	call CopyTilemapBufferToVram
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


ChooseMonsterDispatch::
	ld a, [wMenuSubStep]
	rst $00

ChooseMonsterSubSteps::
	dw ChooseMonsterStart
	dw ChooseMonsterShowList
	dw ChooseMonsterListInput
	dw ChooseMonsterAskConfirm
	dw ChooseMonsterShowYesNo
	dw ChooseMonsterYesNoInput
	dw ChooseMonsterCheckMaster
	dw ChooseMonsterAccept
	dw ChooseMonsterNotYours

ChooseMonsterStart::
	call SetListLengthToParty
	call ListPartyMonsters
	ld hl, $0003
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


SetListLengthToParty::
	ld a, [wPartyCount]
	ld [wListLength], a
	ret


ListPartyMonsters::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld a, [wParty]
	ld [wSceneObjects], a
	ld a, [$ca8f]
	ld [$c0d9], a
	ld a, [$ca90]
	ld [$c0da], a
	ret


ChooseMonsterShowList::
	ld a, [wTextState]
	or a
	ret nz

	call LoadChooseNameTiles
	call DrawChooseMonsterWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawChooseMonsterWindow::
	call RestoreTilemapBuffer
	ld de, $2e07
	call DrawWindowLayout
	ld de, $724e
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $69ed
	ld b, $03
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	call CopyTilemapBufferToVram
	ret


LoadChooseNameTiles::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call LoadChooseNameSlot
	call LoadChooseNameSlot

LoadChooseNameSlot::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_6995

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call DrawNameTiles
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


jr_012_6995:
	ld b, $20

jr_012_6997:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_012_6997

	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


ChooseMonsterListInput::
	ld de, $69ed
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $03
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_69ce

	call LoadChooseNameTiles

jr_012_69ce:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_69db

	ld hl, wMenuStep
	inc [hl]
	jr jr_012_69ec

jr_012_69db:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_69ec

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_69ec:
jr_012_69ec:
	ret


ChooseListCursorPos::
	db $05, $01, $61, $00, $a1, $00, $e1, $00, $ff, $ff

ChooseMonsterAskConfirm::
	ld hl, $0005
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wMenuChoice3], a
	ret


ChooseMonsterShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6dcb
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $6a62
	ld a, [wMenuChoice3]
	call DrawCursorAt
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


ChooseMonsterYesNoInput::
	ld de, $6a62
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_6a49

jr_012_6a3c:
	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuSubStep], a
	jr jr_012_6a61

jr_012_6a49:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_6a61

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_012_6a3c

	ld hl, wMenuSubStep
	inc [hl]

Jump_012_6a61:
jr_012_6a61:
	ret


ChooseYesNoCursorPos::
	db $2f, $01, $6f, $01, $ff, $ff

ChooseMonsterCheckMaster::
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	ld hl, wMonMaster
	call MonsterField
	ld de, wPlayerName
	ld b, $09

jr_012_6a8c:
	ld a, [de]
	cp [hl]
	jr z, jr_012_6a9f

	ld hl, $0004
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	ret


jr_012_6a9f:
	inc de
	inc hl
	dec b
	jr nz, jr_012_6a8c

	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wChosenMonPic], a
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
	ld a, h
	ld [$c8f3], a
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wChosenMonSpecies], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


ChooseMonsterAccept::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuStep
	inc [hl]
	ret


ChooseMonsterNotYours::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintMenuText
	ld a, $01
	ld [wMenuSubStep], a
	ret


CollectorMenu::
	ld a, [wMenuStep]
	rst $00

CollectorSteps::
	dw CollectorTakeItems
	dw CollectorReport
	dw CollectorGiveEgg
	dw CollectorRewardText
	dw CollectorNextGoal
	dw CollectorClose

CollectorTakeItems::
	ld hl, wBagItems
	ld b, $14
	ld c, $00

jr_012_6b15:
	ld a, [hl]
	cp $1e
	jr nz, jr_012_6b1d

	ld [hl], $ff
	inc c

jr_012_6b1d:
	inc hl
	dec b
	jr nz, jr_012_6b15

	ld a, c
	ld [wItemsHandedIn], a
	or a
	jr z, jr_012_6b77

	ld a, [wCollectedItems]
	ld l, a
	ld a, [$c904]
	ld h, a
	ld a, [wItemsHandedIn]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wCollectedItems], a
	ld a, h
	ld [$c904], a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	jr c, jr_012_6b56

	ld hl, $03e7
	ld a, l
	ld [wCollectedItems], a
	ld a, h
	ld [$c904], a

jr_012_6b56:
	ld hl, far_CompactBag
	rst $10
	ld a, [wCollectorStep]
	cp $04
	jr z, jr_012_6b6c

	ld hl, $0001
	call PrintMenuText
	ld hl, wMenuStep
	inc [hl]
	ret


jr_012_6b6c:
	ld hl, $000f
	call PrintMenuText
	ld hl, wMenuStep
	inc [hl]
	ret


jr_012_6b77:
	ld hl, wMenuStep
	inc [hl]
	ret


CollectorReport::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCollectedItems]
	ld c, a
	ld a, [$c904]
	ld b, a
	ld hl, wTextArg0
	call Number16ToDecimal
	ld a, [wCollectorStep]
	cp $04
	jr z, jr_012_6bd0

	ld a, [wCollectorStep]
	add a
	add a
	ld hl, $6d29
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
	ld hl, wTextArg1
	call Number16ToDecimal
	pop bc
	ld a, [wCollectedItems]
	ld l, a
	ld a, [$c904]
	ld h, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr c, jr_012_6bca

	ld hl, $0002
	call PrintMenuText
	ld hl, wMenuStep
	inc [hl]
	ret


jr_012_6bca:
	ld a, $04
	ld [wMenuStep], a
	ret


jr_012_6bd0:
	ld a, [wItemsHandedIn]
	or a
	jr z, jr_012_6bca

	ld a, [wItemsHandedIn]
	ld c, a
	ld b, $00
	ld hl, wTextArg0
	call Number16ToDecimal
	ld hl, $0010
	call PrintMenuText
	ld a, $04
	ld [wMenuStep], a
	ret


CollectorGiveEgg::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMonsters
	ld b, $14
	ld c, $00

jr_012_6bfa:
	ld a, [hl]
	or a
	jr z, jr_012_6c0a

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_012_6bfa

jr_012_6c0a:
	ld a, c
	cp $14
	jr nc, jr_012_6c84

	ld a, c
	ld [wNewMonSlot], a
	ld a, [wCollectorStep]
	add a
	add a
	ld hl, $6d2b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [$da13], a
	ld hl, far_CreateMonster
	rst $10
	ld a, [wNewMonSlot]
	ld hl, wMonEgg
	call MonsterField
	ld [hl], $01
	ld a, [wCollectorStep]
	ld bc, $0050
	cp $00
	jr z, jr_012_6c78

	ld bc, $0051
	cp $01
	jr z, jr_012_6c78

	ld bc, $0052
	cp $02
	jr z, jr_012_6c78

	ld bc, $0053
	cp $03
	jr z, jr_012_6c78

	ld bc, $0054
	cp $04
	jr z, jr_012_6c78

	ld bc, $0055
	cp $05
	jr z, jr_012_6c78

	ld bc, $0056
	cp $06
	jr z, jr_012_6c78

	ld bc, $0057
	cp $07
	jr z, jr_012_6c78

	jr jr_012_6c7b

jr_012_6c78:
	call SetEventFlag

jr_012_6c7b:
	ld hl, wCollectorStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	ret


jr_012_6c84:
	ld hl, $000b
	call PrintMenuText
	ld a, $05
	ld [wMenuStep], a
	ret


CollectorRewardText::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCollectorStep]
	ld hl, $0002
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call PrintMenuText
	ld a, $05
	ld [wMenuStep], a
	ret


CollectorNextGoal::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCollectedItems]
	ld c, a
	ld a, [$c904]
	ld b, a
	ld hl, wTextArg0
	call Number16ToDecimal
	ld a, [wCollectorStep]
	cp $04
	jr z, jr_012_6d0f

	ld a, [wCollectorStep]
	add a
	add a
	ld hl, $6d29
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wTextArg1
	call Number16ToDecimal
	ld a, [wCollectorStep]
	add a
	add a
	ld hl, $6d2b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [$da13], a
	ld hl, far_LoadMonTemplate
	rst $10
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg2
	call CopySystemText
	ld hl, $000c
	call PrintMenuText
	ld hl, wMenuStep
	inc [hl]
	ret


jr_012_6d0f:
	ld hl, $0011
	call PrintMenuText
	ld hl, wMenuStep
	inc [hl]
	ret


CollectorClose::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


CollectorRewards::
	db $0d, $00, $50, $01, $12, $00, $51, $01, $19, $00, $53, $01, $1e, $00, $54, $01
	db $ff, $ff

UnusedWindow6D3B::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5
	db $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
	db $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow6DA6::
	db $0e, $01, $fa
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $fd, $d9

ChooseYesNoWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow6DF0::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $a8, $a7, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow6E15::
	db $0c, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow6E32::
	db $00, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow6E73::
	db $81, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e
	db $8f, $90, $91, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0
	db $a1, $a2, $a3, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
UnusedWindow6F29::
	db $40, $01, $fa, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd
	db $d9

UnusedWindow6F3A::
	db $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

FarmYesNoWindow::
	db $00, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
UnusedWindow6F79::
	db $88, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b
	db $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow6FF0::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow701F::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
UnusedWindow7049::
	db $68, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b
	db $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow70C0::
	db $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

UnusedWindow70DD::
	db $46, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

FarmMainMenuWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $92, $98, $9c, $e3, $e0, $9c, $93, $93, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e3, $95, $91, $96, $e0
	db $9a, $e3, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $91, $94, $d5, $91, $96, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $e3, $90, $98
	db $90, $99, $d5, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $d6, $97, $d5, $d5, $e3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $a2, $95, $99, $e0
	db $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

FarmPartyWindow::
	db $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82
	db $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86
	db $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a
	db $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

FarmListWindow::
	db $0d, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

ChooseMonsterWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $88, $89, $8a, $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow7298::
	db $00
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff
	db $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow72F2::
	db $0d, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

UnusedWindow731C::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9e, $90, $d6, $99, $d5, $98
	db $e4, $a0, $a1, $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $da, $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac
	db $ad, $ae, $af, $ff, $d8, $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0
	db $e0, $e0, $e0, $9f, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow7396::
	db $80, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $84, $e0, $80, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $85, $e0, $81, $e0, $91, $97, $90, $d6, $d6, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $86, $e0, $82, $e0, $91, $97
	db $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $87, $e0
	db $83, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

UnusedWindow743A::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8a
	db $98, $d5, $d5, $92, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $94, $90, $99, $91, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow7482::
	db $40, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb
	db $eb, $ed, $d8, $fe, $e0, $61, $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $65, $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

UnusedWindow74DC::
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b
	db $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $61
	db $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $65
	db $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $69
	db $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6d
	db $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow7536::
	db $09, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71
	db $72, $73, $74, $75, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow7574::
	db $a9, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73
	db $74, $75, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

LevelWindow::
	db $49, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $e0, $e0, $65, $66, $67, $68, $69, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow75C0::
	db $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow75E6::
	db $87, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $65
	db $66, $67, $68, $69, $6a, $6b, $6c, $6d, $a0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71, $72
	db $73, $74, $75, $76, $a1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f
	db $a2, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $a3, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedWindow7666::
	db $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d5, $df, $9f, $de, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8
	db $de, $d5, $d6, $d6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

UnusedWindow76AE::
	db $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $70, $71, $72, $73, $74, $75, $76, $77, $78
	db $9b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $9c, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89
	db $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96
	db $97, $98, $99, $9a, $9e, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

UnusedWindow772E::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $a8, $a9, $aa, $ab, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $ac, $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

FarmCountsWindow::
	db $80
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $9e
	db $9f, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63
	db $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

EggListWindow::
	db $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $8c
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $8d, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78
	db $79, $7a, $7b, $7c, $7d, $7e, $7f, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85
	db $86, $87, $88, $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

UnusedWindow784D::
	db $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $95, $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

UnusedWindow787C::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $a1, $a7, $a9, $a4, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a4, $a2, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

FarmSwitchWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

LibraryFamilyWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $67, $68, $69, $6a, $6b, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $6c, $6d, $6e, $6f, $70, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $71, $72, $73, $74, $75, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $76, $77, $78, $79, $7a, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $7b, $7c, $7d, $7e
	db $7f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

LibraryMonsterListWindow::
	db $08, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81, $82
	db $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f
	db $a0, $a1, $a2, $a3, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

LibraryMonsterPageWindow::
	db $00, $00, $01
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $03, $d8, $04, $80, $81, $82, $83, $84, $85, $00, $00, $14, $15, $16
	db $17, $18, $19, $1a, $1b, $1c, $00, $05, $d8, $04, $86, $87, $88, $89, $8a, $8b
	db $00, $0a, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $05, $d8, $04, $8c
	db $8d, $8e, $8f, $90, $91, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $05, $d8, $04, $92, $93, $94, $95, $96, $97, $11, $00, $00, $1d, $1e, $1f
	db $20, $21, $22, $23, $24, $25, $05, $d8, $04, $98, $99, $9a, $9b, $9c, $9d, $12
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $05, $d8, $04, $9e, $9f
	db $a0, $a1, $a2, $a3, $00, $00, $00, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e
	db $05, $d8, $04, $0d, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0f, $05, $d8, $04, $a5, $a6, $a7, $a8, $a9, $aa, $00, $00
	db $00, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $05, $d8, $04, $10, $10, $10
	db $10, $10, $10, $10, $10, $00, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $05
	db $d8, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $41, $42, $43, $44, $45
	db $46, $47, $48, $49, $05, $d8, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $05, $d8, $04, $4a, $4b, $4c, $4d
	db $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $05, $d8
	db $04, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13
	db $13, $13, $13, $05, $d8, $04, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65
	db $66, $67, $68, $69, $6a, $6b, $6c, $6d, $05, $d8, $04, $13, $13, $13, $13, $13
	db $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $13, $05, $d8, $04
	db $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d
	db $7e, $7f, $05, $d8, $06, $07, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $09, $d9

StatusOrOkWindow::
	db $00, $01, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

EggStatusOrOkWindow::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $95, $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

Bank12Padding::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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
	db $00, $00, $00, $00, $00, $00, $00
