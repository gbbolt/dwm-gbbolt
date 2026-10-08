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
;@ test: skip the test harness cannot run the original (it stops inside the next routine)
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


;@ def NextBgColumn(ptr: hl) -> hl
;@ path: menu/window
;@ Moves a BG map address one column right, wrapping around within its 32-tile row.
NextBgColumn::
;> row = ptr & 0xFFE0
	push af
	ld a, l
	and $e0
	push af
;> column = (ptr + 1) & 0x1F
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
;> ptr = wWindowBgMap + offset
	ld a, [wWindowBgMap]
	add l
	ld l, a
	ld a, [wWindowBgMap + 1]
	adc h
;> ptr &= 0x03FF
	and $03
	ld h, a
;> return (wWindowBgMap & 0xFC00) | ptr
	ld a, [wWindowBgMap + 1]
	and $fc
	or h
	ld h, a
	ret


;@ def TilemapBufferAddr(offset: hl) -> hl
;@ path: menu/window
;@ Address of a window offset (row * 32 + column) in wTilemapBuffer.
TilemapBufferAddr::
;> ptr = addr(wTilemapBuffer) + offset
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
;> return ptr
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
	ret


;@ def WindowBgAddrWrapped(offset: hl) -> hl
;@ path: menu/window
;@ Like WindowBgAddr, but the column also wraps around inside its BG map row, so a window
;@ near the right edge of the 32-tile map continues at its left edge.
WindowBgAddrWrapped::
;> ptr = WindowBgAddr(offset & 0xFFE0)              # start of the row
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
;>     ptr = NextBgColumn(ptr)
	call NextBgColumn
	dec b
	jr nz, .column
.done
;> return ptr
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
;> ptr = row = WindowBgAddrWrapped(offset); p = layout + 2    # row is kept in hNumber
	call WindowBgAddrWrapped
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
.loop
;>@loop while True:
;>@loop     b = mem[p]; p += 1
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
;>         ptr = row
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
;>         WriteVRAM(ptr, b)
	call WriteVRAM
;>         ptr = NextBgColumn(ptr)
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
;> ptr = row = TilemapBufferAddr(offset); p = layout + 2    # row is kept in hNumber
	call TilemapBufferAddr
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
.loop
;>@loop while True:
;>@loop     b = mem[p]; p += 1
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
;>         ptr = row
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;=@loop
	jr .loop
.tile
;>     else:
;>         mem[ptr] = b; ptr += 1
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
;> src = addr(wTilemapBuffer)
	ld de, wTilemapBuffer
;> for _ in range(18):
	ld c, $12
.row
;>     ptr = row
	ld b, $20
	push hl
.column
;>     for _ in range(32):
;>         WriteVRAM(ptr, mem[src])
	ld a, [de]
	call WriteVRAM
;>@nc         ptr = NextBgColumn(ptr)
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
;> CopyName(addr(wTextArg0), name)
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
;>@cp copy(addr(wTilemapBuffer), addr(wSavedTilemap), 0x200)
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
;>@rows     copy(addr(wTilemapBuffer) + 0x200 + row * 32, addr(wPartyBarTiles) + row * 32, 20)
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
;>@fill fill(addr(wTilemapBuffer), 0xE0, 0x240)
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
;> for ptr in range(0x9800, 0x9C00):
	ld hl, $9800
	ld bc, $0400
.loop
;>     WriteVRAMInc(ptr, 0xE0)
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
;>@addr     ptr = WindowBgAddrWrapped(offset)
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
;>     WriteVRAM(ptr, tile)
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
;>@addr ptr = WindowBgAddrWrapped(offset - 1)
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
;> WriteVRAM(ptr, 0xF1 + (page & 0x7F))
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
;> SnapToTile(addr(hScrollX))
	ld hl, hScrollX
	call SnapToTile
;> SnapToTile(addr(hScrollY))
	ld hl, hScrollY
	call SnapToTile
;> fill(addr(wMenuChoice), 0, 8)                            # wMenuChoice .. wListLastRows: the menu cursors
	ld hl, wMenuChoice
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
;@ with the cursor on the option in wMenuChoice (the menu choice byte).
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawFarmMainMenu::
;> DrawWindowLayout(FarmMainMenuWindow)
	ld de, FarmMainMenuWindow
	call DrawWindowLayout
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice, FarmMainMenuCursorPos)
	ld de, FarmMainMenuCursorPos
	ld a, [wMenuChoice]
	call DrawCursorAt
	ret


;@ def FarmMainMenuInput()
;@ path: menu/farm
;@ Farm menu: moves the cursor over the six options. B or Start closes the menu, A runs
;@ the option (after clearing the cursors the options use).
;@ test: skip draws into VRAM
FarmMainMenuInput::
;> UpdateMenuCursor(addr(wMenuChoice), 6, FarmMainMenuCursorPos)
	ld de, FarmMainMenuCursorPos
	ld hl, wMenuChoice
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
;>     wMenuChoice |= 0x80                              # shown as chosen
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


;@ path: menu/farm
;@ Cursor positions of the six farm menu options: u16 window offsets (row * 32 + column), $FFFF ends.
FarmMainMenuCursorPos::
	dw $0021, $0061, $00a1, $00e1, $0121, $0161, $ffff

;@ def FarmRunOption()
;@ path: menu/farm
;@ Runs the chosen farm menu option.
;@ test: skip jumps through a table to routines that call other banks
FarmRunOption::
;> return FarmOptionTable[wMenuChoice]()             # bit 7 doubles away in the table index
	ld a, [wMenuChoice]
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
;> CopyPartyBarRow(0xC13C, addr(wPartyBarTiles))
	ld hl, $c13c
	ld de, wPartyBarTiles
	call CopyPartyBarRow
;> CopyPartyBarRow(0xC150, addr(wPartyBarTiles) + 32)
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
;@ test: skip the test harness cannot run the original (it stops in VRAM)
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
;> name = PartyMonsterField(slot - 1, addr(wMonName))
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
;>@dn DrawNameTiles(0x9650, MonsterField(mon, addr(wMonName)))
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, $9650
;=@dn
	call DrawNameTiles
	pop af
;> sex = mem[MonsterField(mon, addr(wMonGender))] & 1
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
;> level = mem[MonsterField(mon, addr(wMonLevel))]
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
;> if mem[MonsterField(mon, addr(wMonsters))] == 2:          # in the party
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
;> UpdateMenuCursor(addr(wMenuChoice2), wPartyCount, PartyListCursorPos)
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
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
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
;> UpdateMenuCursor(addr(wConfirmChoice), 2, DepositChoiceCursorPos)
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
;> wViewList = addr(wParty)
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
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
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
;> UpdateMenuCursor(addr(wConfirmChoice2), 2, SwapYesNoCursorPos)
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
;> DrawListFrame(addr(wListCursor), FarmListCursorPos, 4, wListLength)
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
;> UpdatePagedList(addr(wListCursor), 4, wListLength, FarmListCursorPos)
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
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
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
;> UpdateMenuCursor(addr(wConfirmChoice), 2, SwapChoiceCursorPos)
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
;>@cn CopyName(addr(wTextArg0), MonsterField(wParty[0], addr(wMonName)))
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
;>@cn2 CopyName(addr(wTextArg1), MonsterField(mon, addr(wMonName)))
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
;> wViewList = addr(wSceneObjects)
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


;@ def FarmWithdrawOption()
;@ path: menu/farm/withdraw
;@ Farm option "take a monster out": runs the current step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
FarmWithdrawOption::
;> return FarmWithdrawSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/farm/withdraw
;@ Steps of taking a monster out of the farm: 0-9 choose a farm monster and take it;
;@ 10-30 with a full party: exchange a party monster for a farm monster.
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

;@ def FarmWithdrawStart()
;@ path: menu/farm/withdraw
;@ Withdraw, step 0: with no monster at the farm prints message 12 and ends; with a full
;@ party (3) offers an exchange (message 13); else lists the farm monsters (message 11).
;@ test: skip draws letter tiles
FarmWithdrawStart::
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
;> if CountFarmMonsters() == 0:
	call CountFarmMonsters
	or a
	jr nz, .haveMonsters
;>     PrintMenuText(12)
	ld hl, $000c
	call PrintMenuText
;>     wMenuSubStep = 7
	ld a, $07
	ld [wMenuSubStep], a
	ret
.haveMonsters
;> elif wPartyCount == 3:
	ld a, [wPartyCount]
	cp $03
	jr nz, .room
;>     PrintMenuText(13)                                # the party is full
	ld hl, $000d
	call PrintMenuText
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a
;>     wMenuSubStep = 10
	ld a, $0a
	ld [wMenuSubStep], a
	ret
.room
;> else:
;>     ListFarmMonsters()
	call ListFarmMonsters
;>     PrintMenuText(11)
	ld hl, $000b
	call PrintMenuText
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def CountFarmMonsters() -> a
;@ path: monster/farm
;@ Counts the monsters at the farm: records that are used, not in the party and not
;@ eggs. The count also goes to wListLength.
CountFarmMonsters::
;> rec = addr(wMonsters)
	ld de, wMonsters
;> n = 0
	ld b, $14
	ld c, $00
.loop
;>@loop for _ in range(20):
;>@egg     if mem[rec] not in (0, 2) and mem[rec + 0x63] == 0:     # at the farm, not an egg
	push de
	ld a, [de]
	or a
	jr z, .next
	cp $02
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next
;>         n += 1
	inc c
.next
;>     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	dec b
	jr nz, .loop
;> wListLength = n
	ld a, c
	ld [wListLength], a
;> return n
	ret


;@ def ListFarmMonsters()
;@ path: monster/farm
;@ Fills the list buffer wSceneObjects with the record numbers of the farm monsters (the
;@ ones CountFarmMonsters counts); unused entries are $FF.
ListFarmMonsters::
;> fill(addr(wSceneObjects), 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = addr(wSceneObjects)
	ld hl, wSceneObjects
;> rec = addr(wMonsters)
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for slot in range(20):
;>@egg2     if mem[rec] not in (0, 2) and mem[rec + 0x63] == 0:     # at the farm, not an egg
	push de
	ld a, [de]
	or a
	jr z, .next
	cp $02
	jr z, .next
;=@egg2
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg2
	ld a, [de]
	or a
	jr nz, .next
;>         mem[out] = slot; out += 1
	ld [hl], c
	inc hl
.next
;>     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	inc c
	dec b
	jr nz, .loop
	ret


;@ def FarmWithdrawShowList()
;@ path: menu/farm/withdraw
;@ Withdraw, step 1: once the message is printed, shows the farm list.
;@ test: skip draws into VRAM
FarmWithdrawShowList::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;> DrawFarmWithdrawList()
	call DrawFarmWithdrawList
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmWithdrawList()
;@ path: menu/farm/withdraw
;@ Draws the farm menu with the level window and the farm list (4 rows a page) and
;@ copies it to the screen.
;@ test: skip draws into VRAM
DrawFarmWithdrawList::
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
;> DrawListFrame(addr(wListCursor), FarmListCursorPos, 4, wListLength)
	ld de, FarmListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def LoadFarmListNameTiles()
;@ path: menu/farm
;@ Renders the names of the 4 list entries of the current page into the letter tiles at
;@ $8800, $8840, $8880 and $88C0.
;@ test: skip draws letter tiles
LoadFarmListNameTiles::
;>@e entry = addr(wSceneObjects) + wListPage * 4
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@e
	ld a, $00
	adc d
	ld d, a
;> dest = 0x8800
	ld hl, $8800
;> for _ in range(4):
;>@four     dest, entry = LoadListNameSlot(dest, entry)
	call LoadListNameSlot
;=@four
	call LoadListNameSlot
	call LoadListNameSlot

;@ def LoadListNameSlot(dest: hl, entry: de) -> (hl, de)
;@ path: menu/farm
;@ Renders the name of monster record mem[entry] into 4 letter tiles at `dest` (blank
;@ tiles for $FF) and returns the next tile address and list entry.
;@ test: skip draws letter tiles
LoadListNameSlot::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank
;>@name     DrawNameTiles(dest, MonsterField(mem[entry], addr(wMonName)))
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
;=@name
	call DrawNameTiles
;>@ret     return dest + 0x40, entry + 1
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@ret
	ld h, a
	pop de
	inc de
	ret
.blank
;> for _ in range(0x20):
	ld b, $20
.loop
;>     WriteVRAMInc(dest, 0xFF); dest += 1
	ld a, $ff
	call WriteVRAMInc
;>     WriteVRAMInc(dest, 0x00); dest += 1
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .loop
;>@ret2 return dest + 0x40, entry + 1
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@ret2
	ld h, a
	pop de
	inc de
	ret


;@ def FarmWithdrawListInput()
;@ path: menu/farm/withdraw
;@ Withdraw, step 2: moves the cursor over the farm list; B goes back to the farm menu,
;@ A asks to confirm.
;@ test: skip draws into VRAM
FarmWithdrawListInput::
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
;> UpdatePagedList(addr(wListCursor), 4, wListLength, FarmListCursorPos)
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
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm
;@ Cursor table of the farm list window: the page number position, then the 4 rows
;@ (u16 window offsets), $FFFF ends.
FarmListCursorPos::
	dw $0152, $006e, $00ae, $00ee, $012e, $ffff

;@ def FarmWithdrawAskConfirm()
;@ path: menu/farm/withdraw
;@ Withdraw, step 3: asks about the chosen farm monster (message 14).
;@ test: skip prints a message
FarmWithdrawAskConfirm::
;> PrintMenuText(14)
	ld hl, $000e
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmWithdrawShowChoice()
;@ path: menu/farm/withdraw
;@ Withdraw, step 4: once the question is printed, opens the two-choice window (status / take it).
;@ test: skip draws into VRAM
FarmWithdrawShowChoice::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWithdrawChoice()
	call DrawWithdrawChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawWithdrawChoice()
;@ path: menu/farm/withdraw
;@ Draws the two-choice window of the withdrawal with the cursor on wConfirmChoice.
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawWithdrawChoice::
;> DrawWindowLayout(StatusOrOkWindow)
	ld de, StatusOrOkWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice, WithdrawChoiceCursorPos)
	ld de, WithdrawChoiceCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


;@ def FarmWithdrawChoiceInput()
;@ path: menu/farm/withdraw
;@ Withdraw, step 5: B goes back to the list (step 2), the first choice opens the status
;@ screen (step 8), the second takes the monster (step 6).
;@ test: skip draws into VRAM
FarmWithdrawChoiceInput::
;> UpdateMenuCursor(addr(wConfirmChoice), 2, WithdrawChoiceCursorPos)
	ld de, WithdrawChoiceCursorPos
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
;>     DrawFarmWithdrawList()
	call DrawFarmWithdrawList
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     PrintMenuText(11)
	ld hl, $000b
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
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/withdraw
;@ Cursor positions of the withdrawal's two-choice window: 2 u16 window offsets, $FFFF ends.
WithdrawChoiceCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmWithdrawDoIt()
;@ path: menu/farm/withdraw
;@ Withdraw, step 6: puts the chosen farm monster into the third party slot (CompactMonsters
;@ then packs the party and marks the records) and prints message 15. With an empty party
;@ record 0 becomes the only party monster instead, and event flag 7 is set.
;@ test: skip calls bank 1
FarmWithdrawDoIt::
;> if wPartyCount == 0:
	ld a, [wPartyCount]
	or a
	jr nz, .join
;>     wParty[0] = 0                                    # record 0 becomes the party
	xor a
	ld [wParty], a
;>     wMonsters[0] = 2                                 # in the party
	ld a, $02
	ld [wMonsters], a
;>     wParty[1] = 0xFF
	ld a, $ff
	ld [wParty + 1], a
;>     wParty[2] = 0xFF
	ld a, $ff
	ld [wParty + 2], a
;>     wPartyCount = 1
	ld a, $01
	ld [wPartyCount], a
;>     RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;>     SetEventFlag(7)
	ld bc, $0007
	call SetEventFlag
;>     PrintMenuText(15)
	ld hl, $000f
	call PrintMenuText
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret
.join
;> else:
;>@t1     wParty[2] = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@t1
	ld h, a
	ld a, [hl]
	ld [wParty + 2], a
;>     CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>     RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;>     PrintMenuText(15)
	ld hl, $000f
	call PrintMenuText
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmWithdrawDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu.
;@ test: skip draws letter tiles
FarmWithdrawDone::
;> if wTextState: return                              # wait for the message
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


;@ def FarmWithdrawViewStatus()
;@ path: menu/farm/withdraw
;@ Withdraw, step 8: opens the monster status screen on the farm list, at the chosen entry.
;@ test: skip calls bank 7
FarmWithdrawViewStatus::
;> wViewList = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;>@t1 wViewIndex = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
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


;@ def FarmWithdrawStatusReturn()
;@ path: menu/farm/withdraw
;@ Withdraw, step 9: after the status screen, puts the cursor on the entry shown last,
;@ reloads the menu graphics and redraws the list with the two-choice window (step 5).
;@ test: skip draws into VRAM
FarmWithdrawStatusReturn::
;>@t1 wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@t1
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
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> DrawFarmWithdrawList()
	call DrawFarmWithdrawList
;> DrawWithdrawChoice()
	call DrawWithdrawChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> PrintMenuText(14)
	ld hl, $000e
	call PrintMenuText
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def FarmPartyFullAsk()
;@ path: menu/farm/withdraw
;@ Withdraw with a full party, step 10: offers to exchange a party monster (message 16).
;@ test: skip prints a message
FarmPartyFullAsk::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> PrintMenuText(16)
	ld hl, $0010
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmPartyFullShowYesNo()
;@ path: menu/farm/withdraw
;@ Step 11: once the question is printed, opens the yes/no window.
;@ test: skip draws into VRAM
FarmPartyFullShowYesNo::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawPartyFullYesNo()
	call DrawPartyFullYesNo
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawPartyFullYesNo()
;@ path: menu/farm/withdraw
;@ Draws the yes/no window of the exchange offer with the cursor on wConfirmChoice2.
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawPartyFullYesNo::
;> DrawWindowLayout(FarmYesNoWindow)
	ld de, FarmYesNoWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice2, PartyFullYesNoCursorPos)
	ld de, PartyFullYesNoCursorPos
	ld a, [wConfirmChoice2]
	call DrawCursorAt
	ret


;@ def FarmPartyFullYesNoInput()
;@ path: menu/farm/withdraw
;@ Step 12: yes goes on to the party list of the exchange (step 23); no or B back to the farm menu.
;@ test: skip draws into VRAM
FarmPartyFullYesNoInput::
;> UpdateMenuCursor(addr(wConfirmChoice2), 2, PartyFullYesNoCursorPos)
	ld de, PartyFullYesNoCursorPos
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor
;> if not wJoyPressed & 0x02:
;>@a     if not wJoyPressed & 0x01: return
;>@b     QueueSound(0x59)
;>@c     if wConfirmChoice2 != 0x81:                     # yes
;>@d         wMenuSubStep = 23
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
	ld a, $17
	ld [wMenuSubStep], a
.done
	ret


;@ path: menu/farm/withdraw
;@ Cursor positions of the yes/no window: 2 u16 window offsets, $FFFF ends.
PartyFullYesNoCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmExchangeBuildList()
;@ path: menu/farm/withdraw
;@ Exchange, step 13: lists the farm monsters and asks which one to take (message 19).
;@ test: skip prints a message
FarmExchangeBuildList::
;> ListFarmMonsters()
	call ListFarmMonsters
;> PrintMenuText(19)
	ld hl, $0013
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmExchangeShowList()
;@ path: menu/farm/withdraw
;@ Step 14: once the message is printed, shows the farm list.
;@ test: skip draws into VRAM
FarmExchangeShowList::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;> DrawFarmExchangeList()
	call DrawFarmExchangeList
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmExchangeList()
;@ path: menu/farm/withdraw
;@ Draws the farm menu with the level window, the farm list (4 rows a page) and the
;@ yes/no window into wTilemapBuffer.
;@ test: skip draws letter tiles
DrawFarmExchangeList::
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
;> DrawListFrame(addr(wListCursor), FarmListCursorPos, 4, wListLength)
	ld de, FarmListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
;> DrawPartyFullYesNo()
	call DrawPartyFullYesNo
	ret


;@ def FarmExchangeListInput()
;@ path: menu/farm/withdraw
;@ Step 15: moves the cursor over the farm list; B goes back to the party list (step 25),
;@ A asks to confirm.
;@ test: skip draws into VRAM
FarmExchangeListInput::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;>@t1 old_row, old_page = wListCursor, wListPage
	ld de, FarmListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@t1
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdatePagedList(addr(wListCursor), 4, wListLength, FarmListCursorPos)
	call UpdatePagedList
;> if wListCursor != old_row:
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, jr_012_50d7
;>     ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>     DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
jr_012_50d7:
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_50ea
;>     LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;>     ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>     DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
jr_012_50ea:
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_510a
;>     ShowExchangePartyMonster()
	call ShowExchangePartyMonster
;>     LoadPartyNameTiles()
	call LoadPartyNameTiles
;>     DrawExchangePartyWindow()
	call DrawExchangePartyWindow
;>     PrintMenuText(17)
	ld hl, $0011
	call PrintMenuText
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     wMenuSubStep = 25
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_012_511f
jr_012_510a:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_511f
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
Jump_012_511f:
jr_012_511f:
	ret


;@ def FarmExchangeAskConfirm()
;@ path: menu/farm/withdraw
;@ Step 16: asks about the chosen farm monster (message 20).
;@ test: skip prints a message
FarmExchangeAskConfirm::
;> PrintMenuText(20)
	ld hl, $0014
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmExchangeShowChoice()
;@ path: menu/farm/withdraw
;@ Step 17: once the question is printed, opens the two-choice window (status / exchange).
;@ test: skip draws into VRAM
FarmExchangeShowChoice::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawExchangeChoice()
	call DrawExchangeChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawExchangeChoice()
;@ path: menu/farm/withdraw
;@ Draws the two-choice window of the exchange with the cursor on wConfirmChoice.
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawExchangeChoice::
;> DrawWindowLayout(StatusOrOkWindow)
	ld de, StatusOrOkWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice, ExchangeChoiceCursorPos)
	ld de, ExchangeChoiceCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


;@ def FarmExchangeChoiceInput()
;@ path: menu/farm/withdraw
;@ Step 18: B goes back to the farm list (step 15), the first choice opens the status
;@ screen (step 21), the second makes the exchange (step 19).
;@ test: skip draws into VRAM
FarmExchangeChoiceInput::
;> UpdateMenuCursor(addr(wConfirmChoice), 2, ExchangeChoiceCursorPos)
	ld de, ExchangeChoiceCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_517e
;>     ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>     LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;>     DrawFarmExchangeList()
	call DrawFarmExchangeList
;>     PrintMenuText(19)
	ld hl, $0013
	call PrintMenuText
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     wMenuSubStep = 15
	ld a, $0f
	ld [wMenuSubStep], a
	jr jr_012_51a4
jr_012_517e:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_51a4
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_51a0
;>         wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>         wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>         wMenuSubStep = 21
	ld a, $15
	ld [wMenuSubStep], a
	jr jr_012_51a4
jr_012_51a0:
;>     else:
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
Jump_012_51a4:
jr_012_51a4:
	ret


;@ path: menu/farm/withdraw
;@ Cursor positions of the exchange's two-choice window: 2 u16 window offsets, $FFFF ends.
ExchangeChoiceCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmExchangeDoIt()
;@ path: menu/farm/withdraw
;@ Step 19: the chosen farm monster takes the place of the chosen party monster (which
;@ stays at the farm); both names go to wTextArg0/wTextArg1 for message 21.
;@ test: skip calls bank 1
FarmExchangeDoIt::
;>@t1 CopyName(addr(wTextArg0), MonsterField(wParty[wMenuChoice3 & 0x7F], addr(wMonName)))
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@t1
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wMonName
	call MonsterField
	ld e, l
;=@t1
	ld d, h
	ld hl, wTextArg0
	call CopyName
;>@t2 mon = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t2
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@t2
	ld h, a
	ld a, [hl]
;>@t3 CopyName(addr(wTextArg1), MonsterField(mon, addr(wMonName)))
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@t3
	call CopyName
;>@t4 wParty[wMenuChoice3 & 0x7F] = mon
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@t4
	adc h
	ld h, a
	pop af
	ld [hl], a
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> PrintMenuText(21)
	ld hl, $0015
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmExchangeDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu.
;@ test: skip draws letter tiles
FarmExchangeDone::
;> if wTextState: return                              # wait for the message
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


;@ def FarmExchangeViewStatus()
;@ path: menu/farm/withdraw
;@ Step 21: opens the monster status screen on the farm list, at the chosen entry.
;@ test: skip calls bank 7
FarmExchangeViewStatus::
;> wViewList = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;>@t1 wViewIndex = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
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


;@ def FarmExchangeStatusReturn()
;@ path: menu/farm/withdraw
;@ Step 22: after the status screen, puts the cursor on the entry shown last, reloads the
;@ menu graphics and redraws the farm list with the two-choice window (step 18).
;@ test: skip draws into VRAM
FarmExchangeStatusReturn::
;>@t1 wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@t1
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;> DecompressVRAM(0x2E10, 0x8800)
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
;> ListFarmMonsters()
	call ListFarmMonsters
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmListNameTiles()
	call LoadFarmListNameTiles
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> DrawFarmExchangeList()
	call DrawFarmExchangeList
;> DrawExchangeChoice()
	call DrawExchangeChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> PrintMenuText(20)
	ld hl, $0014
	call PrintMenuText
;> wMenuSubStep = 18
	ld a, $12
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def FarmExchangeAskPartySlot()
;@ path: menu/farm/withdraw
;@ Exchange, step 23: asks which party monster to give to the farm (message 17).
;@ test: skip prints a message
FarmExchangeAskPartySlot::
;> PrintMenuText(17)
	ld hl, $0011
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmExchangeShowParty()
;@ path: menu/farm/withdraw
;@ Step 24: once the message is printed, shows the party list.
;@ test: skip draws into VRAM
FarmExchangeShowParty::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> ShowExchangePartyMonster()
	call ShowExchangePartyMonster
;> LoadPartyNameTiles()
	call LoadPartyNameTiles
;> DrawExchangePartyWindow()
	call DrawExchangePartyWindow
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawExchangePartyWindow()
;@ path: menu/farm/withdraw
;@ Draws the farm menu with the party list, the level window and the yes/no window,
;@ cursor on wMenuChoice3.
;@ test: skip draws letter tiles
DrawExchangePartyWindow::
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
;> DrawExchangePartyLevel()
	call DrawExchangePartyLevel
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice3, ExchangePartyCursorPos)
	ld de, ExchangePartyCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt
;> DrawPartyFullYesNo()
	call DrawPartyFullYesNo
	ret


;@ def ShowExchangePartyMonster()
;@ path: menu/farm/withdraw
;@ Shows name and sex of the party monster under the exchange cursor (wMenuChoice3).
;@ test: skip draws letter tiles
ShowExchangePartyMonster::
;>@t1 DrawMonsterNameAndSex(wParty[wMenuChoice3 & 0x7F])
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@t1
	adc h
	ld h, a
	ld a, [hl]
	call DrawMonsterNameAndSex
	ret


;@ def DrawExchangePartyLevel()
;@ path: menu/farm/withdraw
;@ Fills the level window for the party monster under the exchange cursor.
;@ test: skip calls a routine that writes with the LCD-safe write
DrawExchangePartyLevel::
;>@t1 DrawMonsterLevel(wParty[wMenuChoice3 & 0x7F])
	ld a, [wMenuChoice3]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
;=@t1
	adc h
	ld h, a
	ld a, [hl]
	call DrawMonsterLevel
	ret


;@ def FarmExchangePartyInput()
;@ path: menu/farm/withdraw
;@ Step 25: moves the cursor over the party; B goes back to the yes/no question (step 12),
;@ A asks to confirm.
;@ test: skip draws into VRAM
FarmExchangePartyInput::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> old = wMenuChoice3
	ld de, ExchangePartyCursorPos
	ld hl, wMenuChoice3
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
;> UpdateMenuCursor(addr(wMenuChoice3), wPartyCount, ExchangePartyCursorPos)
	push af
	call UpdateMenuCursor
;> if wMenuChoice3 != old:
	pop af
	ld hl, wMenuChoice3
	cp [hl]
	jr z, jr_012_5363
;>     ShowExchangePartyMonster()
	call ShowExchangePartyMonster
;>     DrawWindowLayout(LevelWindow)
	ld de, LevelWindow
	call DrawWindowLayout
;>     DrawExchangePartyLevel()
	call DrawExchangePartyLevel
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
jr_012_5363:
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5383
;>     RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;>     DrawFarmMainMenu()
	call DrawFarmMainMenu
;>     DrawPartyFullYesNo()
	call DrawPartyFullYesNo
;>     PrintMenuText(16)
	ld hl, $0010
	call PrintMenuText
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     wMenuSubStep = 12
	ld a, $0c
	ld [wMenuSubStep], a
	jr jr_012_5398
jr_012_5383:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5398
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
Jump_012_5398:
jr_012_5398:
	ret


;@ path: menu/farm/withdraw
;@ Cursor positions of the party list window: 3 u16 window offsets, $FFFF ends.
ExchangePartyCursorPos::
	dw $006e, $00ae, $00ee, $ffff

;@ def FarmExchangeAskPartyConfirm()
;@ path: menu/farm/withdraw
;@ Step 26: asks about the chosen party monster (message 18).
;@ test: skip prints a message
FarmExchangeAskPartyConfirm::
;> PrintMenuText(18)
	ld hl, $0012
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmExchangeShowPartyChoice()
;@ path: menu/farm/withdraw
;@ Step 27: once the question is printed, opens the two-choice window (status / this one).
;@ test: skip draws into VRAM
FarmExchangeShowPartyChoice::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawExchangePartyChoice()
	call DrawExchangePartyChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawExchangePartyChoice()
;@ path: menu/farm/withdraw
;@ Draws the two-choice window for the party monster with the cursor on wConfirmChoice.
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawExchangePartyChoice::
;> DrawWindowLayout(StatusOrOkWindow)
	ld de, StatusOrOkWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice, ExchangePartyChoiceCursorPos)
	ld de, ExchangePartyChoiceCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


;@ def FarmExchangePartyChoiceInput()
;@ path: menu/farm/withdraw
;@ Step 28: B goes back to the party list (step 25), the first choice opens the status
;@ screen (step 29), the second goes on to the farm list (step 13).
;@ test: skip draws into VRAM
FarmExchangePartyChoiceInput::
;> UpdateMenuCursor(addr(wConfirmChoice), 2, ExchangePartyChoiceCursorPos)
	ld de, ExchangePartyChoiceCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_53ff
;>     ShowExchangePartyMonster()
	call ShowExchangePartyMonster
;>     LoadPartyNameTiles()
	call LoadPartyNameTiles
;>     DrawExchangePartyWindow()
	call DrawExchangePartyWindow
;>     PrintMenuText(17)
	ld hl, $0011
	call PrintMenuText
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     wMenuSubStep = 25
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_012_5426
jr_012_53ff:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5426
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_5421
;>         wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>         wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>         wMenuSubStep = 29
	ld a, $1d
	ld [wMenuSubStep], a
	jr jr_012_5426
jr_012_5421:
;>     else:
;>         wMenuSubStep = 13
	ld a, $0d
	ld [wMenuSubStep], a
Jump_012_5426:
jr_012_5426:
	ret


;@ path: menu/farm/withdraw
;@ Cursor positions of the two-choice window: 2 u16 window offsets, $FFFF ends.
ExchangePartyChoiceCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmExchangeViewPartyStatus()
;@ path: menu/farm/withdraw
;@ Step 29: opens the monster status screen on the party, at the chosen monster.
;@ test: skip calls bank 7
FarmExchangeViewPartyStatus::
;> wViewList = addr(wParty)
	ld hl, wParty
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;> wViewIndex = wMenuChoice3 & 0x7F
	ld a, [wMenuChoice3]
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


;@ def FarmExchangePartyStatusReturn()
;@ path: menu/farm/withdraw
;@ Step 30: after the status screen, puts the cursor on the monster shown last, reloads
;@ the menu graphics and redraws the party list with the two-choice window (step 28).
;@ test: skip draws into VRAM
FarmExchangePartyStatusReturn::
;> wMenuChoice3 = (wMenuChoice3 & 0x80) | wViewResult
	ld a, [wMenuChoice3]
	and $80
	ld b, a
	ld a, [wViewResult]
	or b
	ld [wMenuChoice3], a
;> DecompressVRAM(0x2E10, 0x8800)
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
;> ShowExchangePartyMonster()
	call ShowExchangePartyMonster
;> LoadPartyNameTiles()
	call LoadPartyNameTiles
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> DrawExchangePartyWindow()
	call DrawExchangePartyWindow
;> DrawExchangePartyChoice()
	call DrawExchangePartyChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> PrintMenuText(18)
	ld hl, $0012
	call PrintMenuText
;> wMenuSubStep = 28
	ld a, $1c
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def FarmViewOption()
;@ path: menu/farm/view
;@ Farm option "look at the farm": runs the current step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
FarmViewOption::
;> return FarmViewSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/farm/view
;@ Steps of looking at the farm: counts and monsters/eggs choice, list, status screen.
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

;@ def FarmViewStart()
;@ path: menu/farm/view
;@ Farm view, step 0: with no monsters back to the menu, else message 22.
;@ test: skip prints a message
FarmViewStart::
;> if wPartyCount == 0: return FarmNoMonsters()
	ld a, [wPartyCount]
	cp $00
	jp z, FarmNoMonsters
;> PrintMenuText(22)
	ld hl, $0016
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmViewShowCounts()
;@ path: menu/farm/view
;@ Step 1: once the message is printed, shows the counts window.
;@ test: skip draws into VRAM
FarmViewShowCounts::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> DrawFarmCounts()
	call DrawFarmCounts
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmCounts()
;@ path: menu/farm/view
;@ Draws the farm menu with the counts window (monsters and eggs at the farm and in the
;@ second pen) and the monsters/eggs cursor, and copies it to the screen.
;@ test: skip draws into VRAM
DrawFarmCounts::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(FarmCountsWindow)
	ld de, FarmCountsWindow
	call DrawWindowLayout
;> DrawFarmCountNumbers()
	call DrawFarmCountNumbers
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice2, FarmViewKindCursorPos)
	ld de, FarmViewKindCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def DrawFarmCountNumbers()
;@ path: menu/farm/view
;@ Writes the four counts into the counts window (rows 5, 7, 9 and 11, column 6).
;@ test: skip calls a routine that writes with the LCD-safe write
DrawFarmCountNumbers::
;> DrawCountFarmMonsters(0x00A6)
	ld hl, $00a6
	call DrawCountFarmMonsters
;> DrawCountFarmEggs(0x00E6)
	ld hl, $00e6
	call DrawCountFarmEggs
;> DrawCountFarm2Monsters(0x0126)
	ld hl, $0126
	call DrawCountFarm2Monsters
;> DrawCountFarm2Eggs(0x0166)
	ld hl, $0166
	call DrawCountFarm2Eggs
	ret


;@ def DrawCountFarmMonsters(offset: hl)
;@ path: menu/farm/view
;@ Writes the number of monsters at the farm (used records, not in the party, not eggs)
;@ at window offset `offset` of wTilemapBuffer.
;@ test: skip calls a routine that writes with the LCD-safe write
DrawCountFarmMonsters::
;> pos = TilemapBufferAddr(offset)
	call TilemapBufferAddr
	push hl
;> n = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for rec in range(addr(wMonsters), addr(wMonsters) + 20 * 0x95, 0x95):
;>@egg     if mem[rec] not in (0, 2) and mem[rec + 0x63] == 0:
	push de
	ld a, [de]
	or a
	jr z, .next
	cp $02
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next
;>         n += 1
	inc c
.next
;=@loop
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	dec b
	jr nz, .loop
;> PrintNumber2(pos, n)
	pop hl
	ld b, $00
	call PrintNumber2
	ret


;@ def DrawCountFarmEggs(offset: hl)
;@ path: menu/farm/view
;@ Writes the number of eggs among the player's monster records (party or farm) at window
;@ offset `offset` of wTilemapBuffer.
;@ test: skip calls a routine that writes with the LCD-safe write
DrawCountFarmEggs::
;> pos = TilemapBufferAddr(offset)
	call TilemapBufferAddr
	push hl
;> n = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for rec in range(addr(wMonsters), addr(wMonsters) + 20 * 0x95, 0x95):
;>@egg     if mem[rec] != 0 and mem[rec + 0x63] != 0:
	push de
	ld a, [de]
	or a
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr z, .next
;>         n += 1
	inc c
.next
;=@loop
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	dec b
	jr nz, .loop
;> PrintNumber2(pos, n)
	pop hl
	ld b, $00
	call PrintNumber2
	ret


;@ def DrawCountFarm2Monsters(offset: hl)
;@ path: menu/farm/view
;@ Writes the number of monsters (not eggs) in the second pen in cartridge RAM at window
;@ offset `offset` of wTilemapBuffer (0 while that pen is not set up).
;@ test: skip reads cartridge RAM
DrawCountFarm2Monsters::
;> pos = TilemapBufferAddr(offset)
	call TilemapBufferAddr
;> n = 0
	ld c, $00
;> if wFarm2Flags & 0x80:
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, .print
;>     for rec in range(addr(sFarm2), addr(sFarm2) + 20 * 0x95, 0x95):
	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00
.loop
;>@used         if ReadSRAMByte(rec) != 0 and ReadSRAMByte(rec + 0x63) == 0:
	push hl
	call ReadSRAMByte
	or a
	jr z, .next
	ld a, l
	add $63
;=@used
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call ReadSRAMByte
	or a
;=@used
	jr nz, .next
;>             n += 1
	inc c
.next
;=@used
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@used
	ld h, a
	dec b
	jr nz, .loop
	pop hl
.print
;> PrintNumber2(pos, n)
	ld b, $00
	call PrintNumber2
	ret


;@ def DrawCountFarm2Eggs(offset: hl)
;@ path: menu/farm/view
;@ Writes the number of eggs in the second pen in cartridge RAM at window offset `offset`
;@ of wTilemapBuffer (0 while that pen is not set up).
;@ test: skip reads cartridge RAM
DrawCountFarm2Eggs::
;> pos = TilemapBufferAddr(offset)
	call TilemapBufferAddr
;> n = 0
	ld c, $00
;> if wFarm2Flags & 0x80:
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, .print
;>     for rec in range(addr(sFarm2), addr(sFarm2) + 20 * 0x95, 0x95):
	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00
.loop
;>@used         if ReadSRAMByte(rec) != 0 and ReadSRAMByte(rec + 0x63) != 0:
	push hl
	call ReadSRAMByte
	or a
	jr z, .next
	ld a, l
	add $63
;=@used
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call ReadSRAMByte
	or a
;=@used
	jr z, .next
;>             n += 1
	inc c
.next
;=@used
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
;=@used
	ld h, a
	dec b
	jr nz, .loop
	pop hl
.print
;> PrintNumber2(pos, n)
	ld b, $00
	call PrintNumber2
	ret


;@ def FarmViewKindInput()
;@ path: menu/farm/view
;@ Step 2: chooses monsters or eggs; B goes back to the farm menu, A builds the list.
;@ test: skip draws into VRAM
FarmViewKindInput::
;> UpdateMenuCursor(addr(wMenuChoice2), 2, FarmViewKindCursorPos)
	ld de, FarmViewKindCursorPos
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_562d
;>     wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;>     wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;>     DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;>     PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_5649
jr_012_562d:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5649
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     fill(addr(wListCursor), 0x00, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
Jump_012_5649:
jr_012_5649:
	ret


;@ path: menu/farm/view
;@ Cursor positions of the monsters/eggs choice: 2 u16 window offsets, $FFFF ends.
FarmViewKindCursorPos::
	dw $00a1, $00e1, $ffff

;@ def FarmViewBuildList()
;@ path: menu/farm/view
;@ Step 3: lists the records of the chosen kind; none: message 23 and back to the menu
;@ (step 8), else message 24.
;@ test: skip prints a message
FarmViewBuildList::
;> if CountMonstersOfKind() == 0:
	call CountMonstersOfKind
	or a
	jr nz, jr_012_5662
;>     PrintMenuText(23)
	ld hl, $0017
	call PrintMenuText
;>     wMenuSubStep = 8
	ld a, $08
	ld [wMenuSubStep], a
;>     return
	ret
jr_012_5662:
;> ListMonstersOfKind()
	call ListMonstersOfKind
;> PrintMenuText(24)
	ld hl, $0018
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def CountMonstersOfKind() -> a
;@ path: menu/farm/view
;@ Counts the player's records of the kind chosen in wMenuChoice2: bit 0 clear = monsters,
;@ set = eggs (egg field 1 or 2), party members included. The count goes to wListLength.
CountMonstersOfKind::
;> n = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for rec in range(addr(wMonsters), addr(wMonsters) + 20 * 0x95, 0x95):
;>@egg     egg = mem[rec + 0x63]
	push de
	ld a, [de]
	or a
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@kind     if mem[rec] != 0 and ((egg | egg >> 1) & 1) == wMenuChoice2 & 1:
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
;=@kind
	or h
	and $01
	xor l
	jr nz, .next
;>         n += 1
	inc c
.next
;=@loop
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	dec b
	jr nz, .loop
;> wListLength = n
	ld a, c
	ld [wListLength], a
;> return n
	ret


;@ def ListMonstersOfKind()
;@ path: menu/farm/view
;@ Fills the list buffer wSceneObjects with the record numbers CountMonstersOfKind counts
;@ ($FF for the rest of the 20 entries).
ListMonstersOfKind::
;> fill(addr(wSceneObjects), 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for slot in range(20):
;>@egg     egg = mem[addr(wMonsters) + slot * 0x95 + 0x63]
	push de
	ld a, [de]
	or a
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@kind     if wMonsters[slot * 0x95] != 0 and ((egg | egg >> 1) & 1) == wMenuChoice2 & 1:
	push hl
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
;=@kind
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, .next
;>         mem[out] = slot; out += 1
	ld [hl], c
	inc hl
.next
;=@loop
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	inc c
	dec b
	jr nz, .loop
	ret


;@ def FarmViewShowList()
;@ path: menu/farm/view
;@ Step 4: once the message is printed, shows the list.
;@ test: skip draws into VRAM
FarmViewShowList::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmViewListTiles()
	call LoadFarmViewListTiles
;> DrawFarmViewList()
	call DrawFarmViewList
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmViewList()
;@ path: menu/farm/view
;@ Draws the farm view: the counts window with the monsters/eggs cursor, and the list of the
;@ chosen kind (monsters: farm list window plus level window; eggs: the egg list window).
;@ test: skip draws into VRAM
DrawFarmViewList::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(FarmCountsWindow)
	ld de, FarmCountsWindow
	call DrawWindowLayout
;> DrawFarmCountNumbers()
	call DrawFarmCountNumbers
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice2, FarmViewKindCursorPos)
	ld de, FarmViewKindCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt
;> window = EggListWindow
	ld de, EggListWindow
;> if not wMenuChoice2 & 1:                           # monsters
	ld a, [wMenuChoice2]
	and $01
	jr nz, .window
;>     DrawWindowLayout(LevelWindow)
	ld de, LevelWindow
	call DrawWindowLayout
;>     DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>     window = FarmListWindow
	ld de, FarmListWindow
.window
;> DrawWindowLayout(window)
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> table = FarmViewEggCursorPos if wMenuChoice2 & 1 else FarmViewMonsterCursorPos
	ld de, FarmViewMonsterCursorPos
	ld a, [wMenuChoice2]
	and $01
	jr z, .table
	ld de, FarmViewEggCursorPos
.table
;> DrawListFrame(addr(wListCursor), table, 4, wListLength)
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def LoadFarmViewListTiles()
;@ path: menu/farm/view
;@ Renders the current page of the farm view list into letter tiles: monsters get their
;@ names at $8800.. (4 tiles each); eggs get the species name (9 tiles) at $9650, $96E0,
;@ $9770 and $8800 and their sex mark at $88C0..$88F0.
;@ test: skip draws letter tiles
LoadFarmViewListTiles::
;>@e entry = addr(wSceneObjects) + wListPage * 4
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@e
	ld a, $00
	adc d
	ld d, a
;> if not wMenuChoice2 & 1:                           # monsters
	ld a, [wMenuChoice2]
	and $01
	jr nz, .eggs
;>@m     dest, entry = LoadListNameSlot(0x8800, entry)  # 4 times
	ld hl, $8800
	call LoadListNameSlot
	call LoadListNameSlot
	call LoadListNameSlot
	call LoadListNameSlot
;>     return
	ret
.eggs
;> for _ in range(3):
;>     dest, entry = LoadSpeciesNameSlot(0x9650, entry)  # $9650, $96E0, $9770
	ld hl, $9650
	call LoadSpeciesNameSlot
	call LoadSpeciesNameSlot
	call LoadSpeciesNameSlot
;> LoadSpeciesNameSlot(0x8800, entry)
	ld hl, $8800
	call LoadSpeciesNameSlot
;> LoadEggMarkTiles()
	call LoadEggMarkTiles
	ret


;@ def LoadSpeciesNameSlot(dest: hl, entry: de) -> (hl, de)
;@ path: menu/farm/view
;@ Renders the species name (text group 5) of monster record mem[entry] into 9 letter tiles
;@ at `dest` (blank tiles for $FF); returns the next tile address and list entry.
;@ test: skip draws letter tiles
LoadSpeciesNameSlot::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank
;>     wTextIndex = mem[MonsterField(mem[entry], addr(wMonRecSpecies))]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
;>     wTextGroup = 5                                   # species names
	ld a, $05
	ld [wTextGroup], a
;>     DrawTextTiles(dest, 0x0901)
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles
;>@r     return dest + 0x90, entry + 1
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
.blank
;> for _ in range(0x48):                              # 9 blank tiles
	ld b, $48
.loop
;>     WriteVRAMInc(dest, 0xFF); dest += 1
	ld a, $ff
	call WriteVRAMInc
;>     WriteVRAMInc(dest, 0x00); dest += 1
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .loop
;>@r2 return dest + 0x90, entry + 1                  # dest restored first
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r2
	ld h, a
	pop de
	inc de
	ret


;@ def LoadEggMarkTiles()
;@ path: menu/farm/view
;@ Renders the marks of the 4 eggs of the current page into the tiles at $88C0..$88F0.
;@ test: skip draws letter tiles
LoadEggMarkTiles::
;>@e entry = addr(wSceneObjects) + wListPage * 4
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@e
	ld a, $00
	adc d
	ld d, a
;> dest = 0x88C0
	ld hl, $88c0
;> for _ in range(4):                                 # the fourth by running into LoadEggMarkSlot
;>     dest, entry = LoadEggMarkSlot(dest, entry)
	call LoadEggMarkSlot
	call LoadEggMarkSlot
	call LoadEggMarkSlot

;@ def LoadEggMarkSlot(dest: hl, entry: de) -> (hl, de)
;@ path: menu/farm/view
;@ Renders the mark of egg record mem[entry] into one tile at `dest`: its sex mark
;@ ($A7/$A8) when known (egg field 2), else $98. Returns the next tile and list entry.
;@ test: skip draws letter tiles
LoadEggMarkSlot::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank
;>     egg = MonsterField(mem[entry], addr(wMonEgg))
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
;>     mark = 0x98
	cp $02
	ld a, $98
	jr nz, .mark
;>@sex     if mem[egg] == 2: mark = 0xA7 + (mem[egg - 0x58] & 1)    # wMonGender
	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@sex
	ld a, [hl]
	and $01
	add $a7
.mark
;>     wTextArg0[0] = mark
	ld [wTextArg0], a
;>     wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save     saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)    # on the stack
	pop hl
	push hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
;=@save
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;>     wTextTiles = dest
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;>     wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;>     wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;>     wTextIndex = 0                                   # text $0200: the string in wTextArg0
	ld a, $00
	ld [wTextIndex], a
;>     PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>@restore     restore(saved)
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
;>@r     return dest + 0x10, entry + 1
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
.blank
;> for _ in range(8):                                 # one blank tile
	ld b, $08
.loop
;>     WriteVRAMInc(dest, 0xFF); dest += 1
	ld a, $ff
	call WriteVRAMInc
;>     WriteVRAMInc(dest, 0x00); dest += 1
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .loop
;>@r2 return dest + 0x10, entry + 1
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r2
	ld h, a
	pop de
	inc de
	ret


;@ def FarmViewListInput()
;@ path: menu/farm/view
;@ Farm view, step 5: moves the cursor over the list (the level window follows for
;@ monsters). B goes back to the counts window (step 1), A opens the status screen (step 6).
;@ test: skip draws into VRAM
FarmViewListInput::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> table = FarmViewEggCursorPos if wMenuChoice2 & 1 else FarmViewMonsterCursorPos
	ld de, FarmViewMonsterCursorPos
	ld a, [wMenuChoice2]
	and $01
	jr z, .table
	ld de, FarmViewEggCursorPos
.table
;>@old old_row, old_page = wListCursor, wListPage
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
;=@old
	push af
	ld a, [hl]
	push af
;> UpdatePagedList(addr(wListCursor), 4, wListLength, table)
	call UpdatePagedList
;>@c1 if wListCursor != old_row and not wMenuChoice2 & 1:
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, .samePos
	ld a, [wMenuChoice2]
	and $01
;=@c1
	jr nz, .samePos
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
;>     LoadFarmViewListTiles()
	call LoadFarmViewListTiles
;>     if not wMenuChoice2 & 1:
	ld a, [wMenuChoice2]
	and $01
	jr nz, .keys
;>         ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>         DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>         CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.keys
;> if wJoyPressed & 0x02:                             # B: back to the counts
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     DrawFarmCounts()
	call DrawFarmCounts
;>     PrintMenuText(22)
	ld hl, $0016
	call PrintMenuText
;>     wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;>@back     wMenuSubStep -= 4
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@back
	ld hl, wMenuSubStep
	dec [hl]
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A: status screen
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/view
;@ Cursor table of the monster list: page number position, 4 rows, $FFFF ends.
FarmViewMonsterCursorPos::
	dw $0152, $006e, $00ae, $00ee, $012e, $ffff

;@ path: menu/farm/view
;@ Cursor table of the egg list: page number position, 4 rows, $FFFF ends.
FarmViewEggCursorPos::
	dw $0192, $00a8, $00e8, $0128, $0168, $ffff

;@ def FarmViewStatus()
;@ path: menu/farm/view
;@ Step 6: opens the monster status screen on the list, at the chosen entry.
;@ test: skip calls bank 7
FarmViewStatus::
;> wViewList = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;>@t1 wViewIndex = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
	add b
	ld a, a
	ld [wViewIndex], a
;> wViewCount = wListLength
	ld a, [wListLength]
	ld [wViewCount], a
;> UpdateMonsterStatus()
	ld hl, far_UpdateMonsterStatus
	rst $10
	ret


;@ def FarmViewStatusReturn()
;@ path: menu/farm/view
;@ Step 7: after the status screen, puts the cursor on the entry shown last and redraws
;@ the farm view (step 5).
;@ test: skip draws into VRAM
FarmViewStatusReturn::
;>@t1 wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@t1
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;> DecompressVRAM(0x2E10, 0x8800)
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
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmViewListTiles()
	call LoadFarmViewListTiles
;> DrawFarmViewList()
	call DrawFarmViewList
;> PrintMenuText(24)
	ld hl, $0018
	call PrintMenuText
;> RunTextToEnd()
	call RunTextToEnd
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
	ret


;@ def FarmViewDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu.
;@ test: skip draws letter tiles
FarmViewDone::
;> if wTextState: return                              # wait for the message
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


;@ def FarmReleaseOption()
;@ path: menu/farm/release
;@ Farm option "send a monster away": runs the current step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
FarmReleaseOption::
;> return FarmReleaseSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/farm/release
;@ Steps of sending a farm monster or egg away for good: counts and monsters/eggs choice,
;@ list, confirmation (with the status screen), release.
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

;@ def FarmReleaseStart()
;@ path: menu/farm/release
;@ Release, step 0: with no monsters back to the menu, else message 26.
;@ test: skip prints a message
FarmReleaseStart::
;> if wPartyCount == 0: return FarmNoMonsters()
	ld a, [wPartyCount]
	cp $00
	jp z, FarmNoMonsters
;> PrintMenuText(26)
	ld hl, $001a
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmReleaseShowCounts()
;@ path: menu/farm/release
;@ Step 1: once the message is printed, shows the counts window.
;@ test: skip draws into VRAM
FarmReleaseShowCounts::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> DrawReleaseCounts()
	call DrawReleaseCounts
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawReleaseCounts()
;@ path: menu/farm/release
;@ Draws the farm menu with the counts window and the monsters/eggs cursor (wMenuChoice2).
;@ test: skip calls a routine that writes with the LCD-safe write
DrawReleaseCounts::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(FarmCountsWindow)
	ld de, FarmCountsWindow
	call DrawWindowLayout
;> DrawFarmCountNumbers()
	call DrawFarmCountNumbers
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice2, ReleaseKindCursorPos)
	ld de, ReleaseKindCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt
	ret


;@ def FarmReleaseKindInput()
;@ path: menu/farm/release
;@ Step 2: chooses monsters or eggs; B goes back to the farm menu, A builds the list.
;@ test: skip draws into VRAM
FarmReleaseKindInput::
;> UpdateMenuCursor(addr(wMenuChoice2), 2, ReleaseKindCursorPos)
	ld de, ReleaseKindCursorPos
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5a55
;>     wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;>     wTextIndex = 0x33
	ld a, $33
	ld [wTextIndex], a
;>     DrawTextTiles(0x8AA0, 0x0601)                      # the farm menu's words
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
;>     PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	jr jr_012_5a74
jr_012_5a55:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5a74
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     fill(addr(wListCursor), 0x00, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;>     LoadReleaseMenuWords()
	call LoadReleaseMenuWords
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
Jump_012_5a74:
jr_012_5a74:
	ret


;@ def LoadReleaseMenuWords()
;@ path: menu/farm/release
;@ Renders the farm menu's words with the variant for monsters or eggs (text $0233 / $0234).
;@ test: skip draws letter tiles
LoadReleaseMenuWords::
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x33 + (wMenuChoice2 & 1)
	ld a, [wMenuChoice2]
	and $01
	add $33
	ld [wTextIndex], a
;> DrawTextTiles(0x8AA0, 0x0601)
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ret


;@ path: menu/farm/release
;@ Cursor positions of the monsters/eggs choice: 2 u16 window offsets, $FFFF ends.
ReleaseKindCursorPos::
	dw $00a1, $00e1, $ffff

;@ def FarmReleaseBuildList()
;@ path: menu/farm/release
;@ Step 3: lists the farm records of the chosen kind; none: message 27 and back to the
;@ menu (step 10), else message 28.
;@ test: skip prints a message
FarmReleaseBuildList::
;> if CountFarmOfKind() == 0:
	call CountFarmOfKind
	or a
	jr nz, jr_012_5aa6
;>     PrintMenuText(27)
	ld hl, $001b
	call PrintMenuText
;>     wMenuSubStep = 10
	ld a, $0a
	ld [wMenuSubStep], a
;>     return
	ret
jr_012_5aa6:
;> ListFarmOfKind()
	call ListFarmOfKind
;> PrintMenuText(28)
	ld hl, $001c
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def CountFarmOfKind() -> a
;@ path: menu/farm/view
;@ Counts the farm records (not in the party) of the kind chosen in wMenuChoice2: bit 0
;@ clear = monsters, set = eggs. The count goes to wListLength.
CountFarmOfKind::
;> n = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for rec in range(addr(wMonsters), addr(wMonsters) + 20 * 0x95, 0x95):
;>@egg     egg = mem[rec + 0x63]
	push de
	ld a, [de]
	or a
	jr z, .next
	cp $02
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@kind     if mem[rec] not in (0, 2) and ((egg | egg >> 1) & 1) == wMenuChoice2 & 1:
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
;=@kind
	or h
	and $01
	xor l
	jr nz, .next
;>         n += 1
	inc c
.next
;=@loop
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	dec b
	jr nz, .loop
;> wListLength = n
	ld a, c
	ld [wListLength], a
;> return n
	ret


;@ def ListFarmOfKind()
;@ path: menu/farm/view
;@ Fills the list buffer wSceneObjects with the record numbers CountFarmOfKind counts
;@ ($FF for the rest of the 20 entries).
ListFarmOfKind::
;> fill(addr(wSceneObjects), 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@loop for slot in range(20):
;>@egg     egg = mem[addr(wMonsters) + slot * 0x95 + 0x63]
	push de
	ld a, [de]
	or a
	jr z, .next
	cp $02
	jr z, .next
;=@egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@kind     if wMonsters[slot * 0x95] not in (0, 2) and ((egg | egg >> 1) & 1) == wMenuChoice2 & 1:
	push hl
	ld a, [wMenuChoice2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
;=@kind
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, .next
;>         mem[out] = slot; out += 1
	ld [hl], c
	inc hl
.next
;=@loop
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@loop
	ld d, a
	inc c
	dec b
	jr nz, .loop
	ret


;@ def FarmReleaseShowList()
;@ path: menu/farm/release
;@ Step 4: once the message is printed, shows the list.
;@ test: skip draws into VRAM
FarmReleaseShowList::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmViewListTiles()
	call LoadFarmViewListTiles
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmReleaseList()
	call DrawFarmReleaseList
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmReleaseList()
;@ path: menu/farm/view
;@ Draws the release screen into wTilemapBuffer (over the restored background): the farm
;@ menu, the counts window with the monsters/eggs cursor and the list of the chosen kind.
;@ test: skip draws letter tiles
DrawFarmReleaseList::
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(FarmCountsWindow)
	ld de, FarmCountsWindow
	call DrawWindowLayout
;> DrawFarmCountNumbers()
	call DrawFarmCountNumbers
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice2, ReleaseKindCursorPos)
	ld de, ReleaseKindCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt
;> window = EggListWindow
	ld de, EggListWindow
;> if not wMenuChoice2 & 1:                           # monsters
	ld a, [wMenuChoice2]
	and $01
	jr nz, .window
;>     DrawWindowLayout(LevelWindow)
	ld de, LevelWindow
	call DrawWindowLayout
;>     DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>     window = FarmListWindow
	ld de, FarmListWindow
.window
;> DrawWindowLayout(window)
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> table = ReleaseEggCursorPos if wMenuChoice2 & 1 else ReleaseMonsterCursorPos
	ld de, ReleaseMonsterCursorPos
	ld a, [wMenuChoice2]
	and $01
	jr z, .table
	ld de, ReleaseEggCursorPos
.table
;> DrawListFrame(addr(wListCursor), table, 4, wListLength)
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
	ret


;@ def FarmReleaseListInput()
;@ path: menu/farm/view
;@ Release, step 5: moves the cursor over the list (the level window follows for monsters).
;@ B goes back to the counts window (step 1), A asks to confirm (step 6).
;@ test: skip draws into VRAM
FarmReleaseListInput::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> table = ReleaseEggCursorPos if wMenuChoice2 & 1 else ReleaseMonsterCursorPos
	ld de, ReleaseMonsterCursorPos
	ld a, [wMenuChoice2]
	and $01
	jr z, .table
	ld de, ReleaseEggCursorPos
.table
;>@old old_row, old_page = wListCursor, wListPage
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
;=@old
	push af
	ld a, [hl]
	push af
;> UpdatePagedList(addr(wListCursor), 4, wListLength, table)
	call UpdatePagedList
;>@c1 if wListCursor != old_row and not wMenuChoice2 & 1:
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, .samePos
	ld a, [wMenuChoice2]
	and $01
;=@c1
	jr nz, .samePos
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
;>     LoadFarmViewListTiles()
	call LoadFarmViewListTiles
;>     if not wMenuChoice2 & 1:
	ld a, [wMenuChoice2]
	and $01
	jr nz, .keys
;>         ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;>         DrawSelectedFarmLevel()
	call DrawSelectedFarmLevel
;>         CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.keys
;> if wJoyPressed & 0x02:                             # B: back to the counts
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     DrawReleaseCounts()
	call DrawReleaseCounts
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     PrintMenuText(26)
	ld hl, $001a
	call PrintMenuText
;>     wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;>@back     wMenuSubStep -= 4
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@back
	ld hl, wMenuSubStep
	dec [hl]
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/release
;@ Cursor table of the monster list: page number position, 4 rows, $FFFF ends.
ReleaseMonsterCursorPos::
	dw $0152, $006e, $00ae, $00ee, $012e, $ffff

;@ path: menu/farm/release
;@ Cursor table of the egg list: page number position, 4 rows, $FFFF ends.
ReleaseEggCursorPos::
	dw $0192, $00a8, $00e8, $0128, $0168, $ffff

;@ def FarmReleaseAskConfirm()
;@ path: menu/farm/release
;@ Step 6: asks about the chosen monster or egg (message 29).
;@ test: skip prints a message
FarmReleaseAskConfirm::
;> PrintMenuText(29)
	ld hl, $001d
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmReleaseShowChoice()
;@ path: menu/farm/release
;@ Step 7: once the question is printed, opens the two-choice window (status / send away).
;@ test: skip draws into VRAM
FarmReleaseShowChoice::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawReleaseChoice()
	call DrawReleaseChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawReleaseChoice()
;@ path: menu/farm/release
;@ Draws the two-choice window of the release (the egg variant for eggs) with the cursor on
;@ wMenuChoice3.
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawReleaseChoice::
;> window = EggStatusOrOkWindow if wMenuChoice2 & 1 else StatusOrOkWindow
	ld de, StatusOrOkWindow
	ld a, [wMenuChoice2]
	and $01
	jr z, .draw
	ld de, EggStatusOrOkWindow
.draw
;> DrawWindowLayout(window)
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice3, ReleaseChoiceCursorPos)
	ld de, ReleaseChoiceCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt
	ret


;@ def FarmReleaseChoiceInput()
;@ path: menu/farm/release
;@ Step 8: B goes back to the list (step 5), the first choice opens the status screen
;@ (step 11), the second sends it away (step 9).
;@ test: skip draws into VRAM
FarmReleaseChoiceInput::
;> UpdateMenuCursor(addr(wMenuChoice3), 2, ReleaseChoiceCursorPos)
	ld de, ReleaseChoiceCursorPos
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor
;> if wJoyPressed & 0x02:                      # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_5cb1
;>     wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;>     RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;>     DrawFarmReleaseList()
	call DrawFarmReleaseList
;>     PrintMenuText(28)
	ld hl, $001c
	call PrintMenuText
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
	jr jr_012_5cd8
jr_012_5cb1:
;> elif wJoyPressed & 0x01:                      # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_5cd8
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 != 0x81:
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_012_5cd4
;>         wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>         wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>         wMenuSubStep = 11
	ld a, $0b
	ld [wMenuSubStep], a
	jp Jump_012_5cd8
jr_012_5cd4:
;>     else:
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
Jump_012_5cd8:
jr_012_5cd8:
	ret


;@ path: menu/farm/release
;@ Cursor positions of the two-choice window: 2 u16 window offsets, $FFFF ends.
ReleaseChoiceCursorPos::
	dw $0121, $0161, $ffff

;@ def FarmReleaseDoIt()
;@ path: menu/farm/release
;@ Release, step 9: frees the record of the chosen monster or egg (its name goes to
;@ wTextArg0) and prints the farewell: system text $0B1D for an egg, message 30 for a monster.
;@ test: skip calls bank 1
FarmReleaseDoIt::
;>@t1 mon = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@t1
	ld h, a
	ld a, [hl]
;>@cn CopyName(addr(wTextArg0), MonsterField(mon, addr(wMonName)))
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@cn
	call CopyName
;> mem[MonsterField(mon, addr(wMonsters))] = 0              # the record is free again
	pop af
	push af
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;> if mem[MonsterField(mon, addr(wMonEgg))] != 0:           # an egg
	pop af
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	jr z, .monster
;>     CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>     RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;>     PrintSystemText(0x0B1D)
	ld hl, $0b1d
	call PrintSystemText
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret
.monster
;> else:
;>     CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>     RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;>     PrintMenuText(30)
	ld hl, $001e
	call PrintMenuText
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmReleaseDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu.
;@ test: skip draws letter tiles
FarmReleaseDone::
;> if wTextState: return                              # wait for the message
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


;@ def FarmReleaseViewStatus()
;@ path: menu/farm/release
;@ Step 11: opens the monster status screen on the list, at the chosen entry.
;@ test: skip calls bank 7
FarmReleaseViewStatus::
;> wViewList = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;>@t1 wViewIndex = wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
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


;@ def FarmReleaseStatusReturn()
;@ path: menu/farm/release
;@ Step 12: after the status screen, puts the cursor on the entry shown last and redraws
;@ the list with the two-choice window (step 8).
;@ test: skip draws into VRAM
FarmReleaseStatusReturn::
;>@t1 wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@t1
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;> DecompressVRAM(0x2E10, 0x8800)
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
;> LoadReleaseMenuWords()
	call LoadReleaseMenuWords
;> ShowSelectedFarmMonster()
	call ShowSelectedFarmMonster
;> LoadFarmViewListTiles()
	call LoadFarmViewListTiles
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmReleaseList()
	call DrawFarmReleaseList
;> DrawReleaseChoice()
	call DrawReleaseChoice
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> PrintMenuText(29)
	ld hl, $001d
	call PrintMenuText
;> wMenuSubStep = 8
	ld a, $08
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def FarmSwitchOption()
;@ path: menu/farm/switch
;@ Farm option "switch pens": runs the current step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
FarmSwitchOption::
;> return FarmSwitchSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/farm/switch
;@ Steps of switching the farm's monsters with those of the second pen in cartridge RAM.
FarmSwitchSteps::
	dw FarmSwitchStart
	dw FarmSwitchShowYesNo
	dw FarmSwitchYesNoInput
	dw FarmSwitchCheck
	dw FarmSwitchAskAgain
	dw FarmSwitchDoIt
	dw FarmSwitchDone

;@ def FarmSwitchStart()
;@ path: menu/farm/switch
;@ Switch pens, step 0: with no monsters back to the menu. Offers the switch with message
;@ 34 when the farm has a monster, with message 37 when only the second pen has one; with
;@ both empty prints message $06CC and ends (step 6).
;@ test: skip reads cartridge RAM
FarmSwitchStart::
;> if wPartyCount == 0: return FarmNoMonsters()
	ld a, [wPartyCount]
	cp $00
	jp z, FarmNoMonsters
;>@scan if any(wMonsters[i * 0x95] == 1 for i in range(20)):     # a monster at the farm
	ld hl, wMonsters
	ld b, $14
.scan
	ld a, [hl]
	cp $01
	jr z, .farmUsed
;=@scan
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@scan
	dec b
	jr nz, .scan
;>@msg1     n = 34
;>@pen2 elif wFarm2Flags & 0x80 and any(ReadSRAMByte(sFarm2 + i * 0x95) for i in range(20)):
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, .none
	ld hl, sFarm2
	ld b, $14
.scan2
	push hl
;=@pen2
	push bc
	call ReadSRAMByte
	pop bc
	pop hl
	or a
	jr nz, .pen2Used
;=@pen2
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@pen2
	dec b
	jr nz, .scan2
;>@msg2     n = 37
;> else:
.none
;>     PrintMessage(0x06CC)                             # nothing to switch
	ld hl, $06cc
	call PrintMessage
;>     wMenuSubStep = 6
	ld a, $06
	ld [wMenuSubStep], a
;>     return
	ret
.pen2Used
;=@msg2
	ld hl, $0025
	jr .print
.farmUsed
;=@msg1
	ld hl, $0022
.print
;> PrintMenuText(n)
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmSwitchShowYesNo()
;@ path: menu/farm/switch
;@ Step 1: once the question is printed, opens the yes/no window.
;@ test: skip draws into VRAM
FarmSwitchShowYesNo::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> DrawFarmSwitchYesNo()
	call DrawFarmSwitchYesNo
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawFarmSwitchYesNo()
;@ path: menu/farm/switch
;@ Draws the farm menu with the yes/no window of the switch and copies it to the screen.
;@ test: skip draws into VRAM
DrawFarmSwitchYesNo::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawFarmMainMenu()
	call DrawFarmMainMenu
;> DrawWindowLayout(FarmSwitchWindow)
	ld de, FarmSwitchWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wConfirmChoice, FarmSwitchCursorPos)
	ld de, FarmSwitchCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def FarmSwitchYesNoInput()
;@ path: menu/farm/switch
;@ Step 2: yes goes on to the switch; no or B back to the farm menu.
;@ test: skip draws into VRAM
FarmSwitchYesNoInput::
;> UpdateMenuCursor(addr(wListCursor), 2, FarmSwitchCursorPos)
	ld de, FarmSwitchCursorPos
	ld hl, wListCursor
	ld b, $02
	call UpdateMenuCursor
;> if not wJoyPressed & 0x02:
;>@a     if not wJoyPressed & 0x01: return
;>@b     QueueSound(0x59)
;>@c     if wListCursor != 0x81:                        # yes
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
	ld a, [wListCursor]
	cp $81
	jr z, .back
;=@d
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/farm/switch
;@ Cursor positions of the yes/no window: 2 u16 window offsets, $FFFF ends.
FarmSwitchCursorPos::
	dw $012f, $016f, $ffff

;@ def FarmSwitchCheck()
;@ path: menu/farm/switch
;@ Step 3: sets the second pen up if this is its first use, then prints what the switch
;@ will do: message 38 when the farm is empty, 36 when both pens have monsters, 35 when
;@ only the farm has; goes on to step 5.
;@ test: skip reads cartridge RAM
FarmSwitchCheck::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> InitFarm2()
	call InitFarm2
;>@scan if not any(wMonsters[i * 0x95] == 1 for i in range(20)):
	ld hl, wMonsters
	ld b, $14
.scan
	ld a, [hl]
	cp $01
	jr z, .farmUsed
;=@scan
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@scan
	dec b
	jr nz, .scan
;>     n = 38                                           # the farm is empty
	ld hl, $0026
	jr .print
.farmUsed
;>@pen2 elif wFarm2Flags & 0x80 and any(ReadSRAMByte(sFarm2 + i * 0x95) for i in range(20)):
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, .pen2Empty
	ld hl, sFarm2
	ld b, $14
.scan2
	push hl
;=@pen2
	push bc
	call ReadSRAMByte
	pop bc
	pop hl
	or a
	jr nz, .pen2Used
;=@pen2
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@pen2
	dec b
	jr nz, .scan2
;>@both     n = 36
;>@one else:
.pen2Empty
;>     n = 35
	ld hl, $0023
	jr .print
.pen2Used
;=@both
	ld hl, $0024
.print
;> PrintMenuText(n)
	call PrintMenuText
;> wMenuSubStep += 2
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def FarmSwitchAskAgain()
;@ path: menu/farm/switch
;@ Step 4 (not reached): prints message 34 again and goes back to the yes/no window.
;@ test: skip prints a message
FarmSwitchAskAgain::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> PrintMenuText(34)
	ld hl, $0022
	call PrintMenuText
;> wMenuSubStep -= 2
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ret


;@ def FarmSwitchDoIt()
;@ path: menu/farm/switch
;@ Step 5: switches pens: every record that is not in the party trades places with the
;@ next record of the second pen in cartridge RAM. Then the game is saved (with the field
;@ and menu state cleared for the save) and the farm menu comes back.
;@ test: skip writes cartridge RAM and saves the game
FarmSwitchDoIt::
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
;> slot2 = 0
	ld bc, $0000
.loop
;>@loop for rec in range(20):
;>     if mem[MonsterField(rec, addr(wMonsters))] != 2:       # not in the party
	ld a, b
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr z, .next
;>         SwapRecordWithFarm2(rec, slot2)
	call SwapRecordWithFarm2
;>         slot2 += 1
	inc c
.next
;=@loop
	inc b
	ld a, b
	cp $14
	jr nz, .loop
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>@s saved = (wFieldFlags, wMenuStep, wScriptRunning, wMenuOverlay)    # on the stack
	ld a, [wFieldFlags]
	push af
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;=@s
	ld a, [wMenuStep]
	push af
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;=@s
	ld a, [wScriptRunning]
	push af
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;=@s
	ld a, [wMenuOverlay]
	push af
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> SaveGame()
	di
	call SaveGame
	ei
;>@r restore(saved)
	pop af
	ld [wMenuOverlay], a
	pop af
	ld [wScriptRunning], a
	pop af
	ld [wMenuStep], a
;=@r
	pop af
	ld [wFieldFlags], a
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def SwapRecordWithFarm2(rec: b, slot2: c)
;@ path: monster/farm
;@ Exchanges monster record `rec` with record `slot2` of the second pen in cartridge RAM
;@ ($95 bytes each way).
;@ test: skip reads and writes cartridge RAM
SwapRecordWithFarm2::
;> a = MonsterField(rec, addr(wMonsters))
	push bc
	ld a, b
	ld hl, wMonsters
	call MonsterField
	push hl
;>@b b = addr(sFarm2) + Multiply(slot2, 0x95)
	ld a, c
	ld c, $95
	call Multiply
	ld a, l
	add LOW(sFarm2)
	ld l, a
;=@b
	ld a, h
	adc HIGH(sFarm2)
	ld h, a
	pop de
;> for i in range(0x95):
	ld b, $95
.loop
;>@x     mem[a + i], sram = ReadSRAMByte(b + i), mem[a + i]
	ld a, [de]
	push af
	call ReadSRAMByte
	ld [de], a
;>     WriteSRAMByte(b + i, sram)
	pop af
	call WriteSRAMByte
;=@x
	inc de
	inc hl
	dec b
	jr nz, .loop
	pop bc
	ret


;@ def InitFarm2()
;@ path: monster/farm
;@ Sets the second pen in cartridge RAM up on its first use: clears its 20 records and
;@ sets wFarm2Flags bit 7.
;@ test: skip writes cartridge RAM
InitFarm2::
;> if wFarm2Flags & 0x80: return
	ld hl, wFarm2Flags
	bit 7, [hl]
	ret nz
;> wFarm2Flags |= 0x80
	set 7, [hl]
;>@l for ptr in range(addr(sFarm2), addr(sFarm2) + 0x0BA4):
	ld hl, sFarm2
	ld bc, $0ba4
.loop
;>     WriteSRAMByte(ptr, 0)
	xor a
	call WriteSRAMByte
;=@l
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret


;@ def FarmSwitchDone()
;@ path: menu/farm
;@ Once the message is printed: back to the farm menu.
;@ test: skip draws letter tiles
FarmSwitchDone::
;> if wTextState: return                              # wait for the message
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


;@ def DrawTwoDigits(n: bc, dest: hl)
;@ path: menu/window
;@ Writes a number below 100 as one or two digit tiles ($F0 + digit, no leading zero).
;@ test: skip writes with the LCD-safe write
DrawTwoDigits::
;> if n // 10 != 0:
	ld de, $000a
	push bc
	call DivideBcByDe
	pop bc
	or a
	jr z, .ones
;>     tens, n = DivideBcByDe(n, 10)
	ld de, $000a
	call DivideBcByDe
;>     PutDigitTile(dest, tens)
	call PutDigitTile
;>     dest = NextBgColumn2(dest)
	call NextBgColumn2
.ones
;> PutDigitTile(dest, n)
	ld a, c
	call PutDigitTile
	ret


;@ def DivideBcByDe(n: bc, d: de) -> (a, bc)
;@ path: menu/window
;@ Divides by repeated subtraction: returns the quotient in a and the remainder in bc.
;@ test: de = rand(1, 0x40); bc = rand(0, 0x400)
DivideBcByDe::
;> q = 0
	push hl
	ld h, $ff
.loop
;>@sub while n >= d:
;>@sub     n -= d; q += 1
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
;=@sub
	ld b, a
	jr nc, .loop
;=@sub
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
;> return q, n
	ld a, h
	pop hl
	ret


;@ def PutDigitTile(dest: hl, digit: a)
;@ path: menu/window
;@ Writes the digit tile $F0 + digit at `dest` (with the LCD-safe write).
;@ test: skip writes with the LCD-safe write
PutDigitTile::
;> WriteVRAM(dest, 0xF0 + digit)
	add $f0
	call WriteVRAM
	ret


;@ def NextBgColumn2(ptr: hl) -> hl
;@ path: menu/window
;@ Same as NextBgColumn: one column right, wrapping within the 32-tile row.
NextBgColumn2::
;> row = ptr & 0xFFE0
	push af
	ld a, l
	and $e0
	push af
;> column = (ptr + 1) & 0x1F
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


;@ def LibraryMenu()
;@ path: menu/library
;@ Script menu 8, the monster library: runs the current step (wMenuStep).
;@ test: skip jumps through a table to routines that call other banks
LibraryMenu::
;> return LibrarySteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: menu/library
;@ Steps of the library: set up, wait a frame, clear the cursors, run, close.
LibrarySteps::
	dw LibraryInit
	dw LibraryWait
	dw LibraryResetCursors
	dw LibraryRun
	dw LibraryClose

;@ def LibraryInit()
;@ path: menu/library
;@ Script menu 8, the monster library, step 0: lines the windows up with the background,
;@ clears the cursors and the screen (only the message window stays), loads the library's
;@ window tiles and covers the field (wMenuOverlay).
;@ test: skip decompresses graphics into VRAM
LibraryInit::
;> SnapToTile(addr(hScrollX))
	ld hl, hScrollX
	call SnapToTile
;> SnapToTile(addr(hScrollY))
	ld hl, hScrollY
	call SnapToTile
;> fill(addr(wMenuChoice), 0, 8)                            # the menu cursors
	ld hl, wMenuChoice
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
;> ClearAttrMap()
	ld hl, far_ClearAttrMap
	rst $10
;> ClearTilemapBuffer()
	call ClearTilemapBuffer
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> DecompressVRAM(0x2E14, 0x9000)                     # library window tiles
	ld de, $2e14
	ld hl, $9000
	call DecompressVRAM
;> ResetCursorBlink()
	call ResetCursorBlink
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def LibraryWait()
;@ path: menu/library
;@ Library step 1: goes on to step 2 (one frame for the new tiles).
LibraryWait::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def LibraryResetCursors()
;@ path: menu/library
;@ Library step 2: starts the browsing at sub-step 0 with all cursors cleared.
LibraryResetCursors::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> fill(addr(wMenuChoice), 0x00, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0x00, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ret


;@ def LibraryRun()
;@ path: menu/library
;@ Library step 3: runs the current sub-step.
;@ test: skip jumps through a table to routines that call other banks
LibraryRun::
;> return LibraryDispatch()
	jp LibraryDispatch


;@ def LibraryClose()
;@ path: menu/library
;@ Library step 4: clears the windows, redraws the map and the party bar and ends the
;@ script menu.
;@ test: skip calls other banks
LibraryClose::
;> ClearTilemapBuffer()
	call ClearTilemapBuffer
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
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
;> wFieldFlags &= ~0x10                               # the script menu is closed
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def LibraryDispatch()
;@ path: menu/library
;@ Runs the current library sub-step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
LibraryDispatch::
;> return LibrarySubSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/library
;@ Sub-steps of the library: families, a family's monsters, one monster's page.
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

;@ def LibraryStart()
;@ path: menu/library
;@ Sub-step 0: goes on to the family list.
LibraryStart::
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def LibraryShowFamilies()
;@ path: menu/library
;@ Sub-step 1: once the message is printed, shows the family list with the monsters of the
;@ family under the cursor.
;@ test: skip draws into VRAM
LibraryShowFamilies::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> LoadFamilyNameTiles()
	call LoadFamilyNameTiles
;> DrawLibraryWindows()
	call DrawLibraryWindows
;> ShowFamilyMonsters()
	call ShowFamilyMonsters
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawLibraryWindows()
;@ path: menu/library
;@ Draws the message window and the family list window (10 families, 5 a page) with its
;@ cursor (wMenuChoice row, wMenuChoice2 page) into the cleared wTilemapBuffer.
;@ test: skip leaves its scratch row pointer in hNumber and draws with the home cursor routine
DrawLibraryWindows::
;> ClearTilemapBuffer()
	call ClearTilemapBuffer
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> DrawWindowLayout(LibraryFamilyWindow)
	ld de, LibraryFamilyWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawListFrame(addr(wMenuChoice), FamilyCursorPos, 5, 10)
	ld de, FamilyCursorPos
	ld b, $05
	ld c, $0a
	ld hl, wMenuChoice
	call DrawListFrame
	ret


;@ def LoadFamilyNameTiles()
;@ path: menu/library
;@ Renders the names of the 5 families of the current page (text group 4) into the letter
;@ tiles at $9670, $96C0, ...
;@ test: skip draws letter tiles
LoadFamilyNameTiles::
;> family = wMenuChoice2 * 5
	ld a, [wMenuChoice2]
	ld b, a
	add a
	add a
	add b
;> dest = 0x9670
	ld hl, $9670
;> for _ in range(5):                                 # the fifth by running into LoadFamilyNameSlot
;>     dest, family = LoadFamilyNameSlot(dest, family)
	call LoadFamilyNameSlot
	call LoadFamilyNameSlot
	call LoadFamilyNameSlot
	call LoadFamilyNameSlot

;@ def LoadFamilyNameSlot(dest: hl, family: a) -> (hl, a)
;@ path: menu/library
;@ Renders family name `family` (text group 4, 5 letters) into the tiles at `dest`;
;@ returns the next tile address ($50 bytes on) and the next family.
;@ test: skip draws letter tiles
LoadFamilyNameSlot::
;> wTextIndex = family
	push af
	push hl
	ld [wTextIndex], a
;> wTextGroup = 4                                     # family names
	ld a, $04
	ld [wTextGroup], a
;> DrawTextTiles(dest, 0x0501)
	ld de, $0501
	call DrawTextTiles
;>@r return dest + 0x50, family + 1
	pop hl
	ld a, l
	add $50
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop af
	inc a
	ret


;@ def ShowFamilyMonsters()
;@ path: menu/library
;@ Lists the monsters of the family under the cursor and draws them in the monster list window.
;@ test: skip draws letter tiles
ShowFamilyMonsters::
;> fill(addr(wListCursor), 0x00, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;> BuildFamilyList()
	call BuildFamilyList
;> LoadMonsterListNames()
	call LoadMonsterListNames
;> DrawWindowLayout(LibraryMonsterListWindow)
	ld de, LibraryMonsterListWindow
	call DrawWindowLayout
	ret


;@ def LibraryFamilyInput()
;@ path: menu/library
;@ Library step 2: moves the cursor over the families (Left/Right turn the page) and shows
;@ the monsters of the family under it. A opens the family (or message 4 when no monster
;@ of it is known yet), B closes the library.
;@ test: skip draws into VRAM
LibraryFamilyInput::
;>@old old_row, old_page = wMenuChoice, wMenuChoice2
	ld de, FamilyCursorPos
	ld hl, wMenuChoice
	ld c, $0a
	ld b, $05
	ld a, [hli]
	push af
;=@old
	ld a, [hld]
	push af
;> UpdatePagedList(addr(wMenuChoice), 5, 10, FamilyCursorPos)
	call UpdatePagedList
;> if wMenuChoice2 != old_page:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .samePage
;>     LoadFamilyNameTiles()
	call LoadFamilyNameTiles
;>     ShowFamilyMonsters()
	call ShowFamilyMonsters
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.samePage
;> if wMenuChoice != old_row:
	pop af
	ld hl, wMenuChoice
	cp [hl]
	jr z, .keys
;>     ShowFamilyMonsters()
	call ShowFamilyMonsters
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
.keys
;> if wJoyPressed & 0x01:                             # A: open the family
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .notA
;>     BuildFamilyList()
	call BuildFamilyList
;>     if wListKnown == 0:
	ld a, [wListKnown]
	or a
	jr nz, .known
;>         PrintMenuText(4)                             # none of them met yet
	ld hl, $0004
	call PrintMenuText
;>         wMenuSubStep = 9
	ld a, $09
	ld [wMenuSubStep], a
;>         return
	jp .done
.known
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     fill(addr(wListCursor), 0, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.notA
;> if wJoyPressed & 0x02:                             # B: close the library
	ld a, [wJoyPressed]
	bit 1, a
	jp z, .done
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
.done
	ret


;@ path: menu/library
;@ Cursor table of the family list: page number position, 5 rows, $FFFF ends.
FamilyCursorPos::
	dw $0146, $0021, $0061, $00a1, $00e1, $0121, $ffff

;@ def LibraryEnterFamily()
;@ path: menu/library
;@ Sub-step 3: lists the family's monsters and prints message 3 (choose one).
;@ test: skip prints a message
LibraryEnterFamily::
;> BuildFamilyList()
	call BuildFamilyList
;> PrintMenuText(3)
	ld hl, $0003
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BuildFamilyList()
;@ path: menu/library
;@ Lists the species of the family under the cursor (FamilyFirstSpecies) in wSceneObjects:
;@ the species number when its library flag is set, else $E0 (not met yet). wListLength
;@ gets the family size, wListKnown the number already met, wCurPartyMember the family.
;@ test: skip reads flags through a home routine
BuildFamilyList::
;> fill(addr(wSceneObjects), 0xFF, 0x20)
	ld hl, wSceneObjects
	ld bc, $0020
	ld a, $ff
	call FillMemory
;>@f family = wMenuChoice2 * 5 + (wMenuChoice & 0x7F)
	ld a, [wMenuChoice2]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@f
	ld a, [wMenuChoice]
	and $7f
	add b
;> wCurPartyMember = family
	ld [wCurPartyMember], a
;>@r first, end = FamilyFirstSpecies[family], FamilyFirstSpecies[family + 1]
	ld hl, FamilyFirstSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ld a, [hli]
	ld c, [hl]
	ld b, a
;> total = known = 0
	ld d, $00
	ld e, $00
;> out = addr(wSceneObjects)
	ld hl, wSceneObjects
.loop
;>@loop for species in range(first, end):
;>@met     met = TestFlag(addr(wLibraryFlags), species)
	push bc
	push de
	push hl
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
;=@met
	pop hl
	pop de
	pop bc
;>     mem[out] = 0xE0
	ld [hl], $e0
;>     if met:
	jr z, .next
;>         mem[out] = species; known += 1
	ld [hl], b
	inc e
.next
;>     total += 1; out += 1
	inc d
	inc hl
;=@loop
	inc b
	ld a, b
	cp c
	jr nz, .loop
;> wListLength = total
	ld a, d
	ld [wListLength], a
;> wListKnown = known
	ld a, e
	ld [wListKnown], a
	ret


;@ path: data/monsters
;@ First species number of each of the 10 monster families, plus the end (215): the
;@ species are sorted by family (sizes 20, 25, 25, 20, 20, 20, 25, 20, 25, 15).
FamilyFirstSpecies::
	db $00, $14, $2d, $46, $5a, $6e, $82, $9b, $af, $c8, $d7

;@ def LibraryShowMonsters()
;@ path: menu/library
;@ Sub-step 4: once the message is printed, shows the family's monster list.
;@ test: skip draws into VRAM
LibraryShowMonsters::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> LoadMonsterListNames()
	call LoadMonsterListNames
;> DrawLibraryMonsterList()
	call DrawLibraryMonsterList
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawLibraryMonsterList()
;@ path: menu/library
;@ Draws the family list and the monster list window (5 rows a page) and copies it to the screen.
;@ test: skip draws into VRAM
DrawLibraryMonsterList::
;> DrawLibraryWindows()
	call DrawLibraryWindows
;> DrawWindowLayout(LibraryMonsterListWindow)
	ld de, LibraryMonsterListWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawListFrame(addr(wListCursor), MonsterListCursorPos, 5, wListLength)
	ld de, MonsterListCursorPos
	ld b, $05
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def LoadMonsterListNames()
;@ path: menu/library
;@ Renders the names of the 5 list entries of the current page (species names, text group
;@ 5, or blanks) into the letter tiles from $8800 on.
;@ test: skip draws letter tiles
LoadMonsterListNames::
;>@e entry = addr(wSceneObjects) + wListPage * 5
	ld a, [wListPage]
	ld b, a
	add a
	add a
	add b
	ld de, wSceneObjects
;=@e
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> dest = 0x8800
	ld hl, $8800
;> for _ in range(5):                                 # the fifth by running into LoadSpeciesNameSlot2
;>     dest, entry = LoadSpeciesNameSlot2(dest, entry)
	call LoadSpeciesNameSlot2
	call LoadSpeciesNameSlot2
	call LoadSpeciesNameSlot2
	call LoadSpeciesNameSlot2

;@ def LoadSpeciesNameSlot2(dest: hl, entry: de) -> (hl, de)
;@ path: menu/library
;@ Renders species name mem[entry] (text group 5) into 9 letter tiles at `dest`; for $FF
;@ the tiles are blanked by ClearNameSlot9. (An unknown entry $E0 shows text $05E0.)
;@ test: skip draws letter tiles
LoadSpeciesNameSlot2::
;> if mem[entry] == 0xFF: return ClearNameSlot9(dest, entry)
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, ClearNameSlot9
;> wTextIndex = mem[entry]
	ld [wTextIndex], a
;> wTextGroup = 5                                     # species names
	ld a, $05
	ld [wTextGroup], a
;> DrawTextTiles(dest, 0x0901)
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles
;>@r return dest + 0x90, entry + 1
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


;@ def ClearNameSlot9(dest: hl, entry: de) -> (hl, de)
;@ path: menu/library
;@ Blanks 9 letter tiles at `dest` (the entry address and `dest` were pushed by the
;@ caller) and returns the next tile address and list entry.
;@ test: skip writes with the LCD-safe write
ClearNameSlot9::
;> for _ in range(0x48):
	ld b, $48
.loop
;>     WriteVRAMInc(dest, 0xFF); dest += 1
	ld a, $ff
	call WriteVRAMInc
;>     WriteVRAMInc(dest, 0x00); dest += 1
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .loop
;>@r return dest + 0x90, entry + 1                  # dest restored first
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


;@ def LibraryMonsterInput()
;@ path: menu/library
;@ Library step 5: moves the cursor over the family's monsters (5 a page). B goes back
;@ to the families (step 1), A on a monster already met opens its page.
;@ test: skip draws into VRAM
LibraryMonsterInput::
;>@old old_page = wListPage
	ld de, MonsterListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $05
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdatePagedList(addr(wListCursor), 5, wListLength, MonsterListCursorPos)
	call UpdatePagedList
;> if wListPage != old_page:
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .keys
;>     LoadMonsterListNames()
	call LoadMonsterListNames
.keys
;> if wJoyPressed & 0x02:                             # B: back to the families
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     DrawLibraryWindows()
	call DrawLibraryWindows
;>     DrawWindowLayout(LibraryMonsterListWindow)
	ld de, LibraryMonsterListWindow
	call DrawWindowLayout
;>     CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;>     PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;>     wMenuSubStep = 1
	ld a, $01
	ld [wMenuSubStep], a
	jr .done
.notB
;> elif wJoyPressed & 0x01:                           # A
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done
;>@i     wConfirmChoice = wListPage * 5 + (wListCursor & 0x7F)    # entry in the family list
	ld a, [wListPage]
	ld b, a
	add a
	add a
	add b
	ld b, a
;=@i
	ld a, [wListCursor]
	and $7f
	add b
	ld [wConfirmChoice], a
;>@s     wCurPartyMember = wSceneObjects[wConfirmChoice]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@s
	ld a, [hl]
	ld [wCurPartyMember], a
;>     if wCurPartyMember != 0xE0:                      # met already
	cp $e0
	jp z, .done
;>         QueueSound(0x59)
	ld a, $59
	call QueueSound
;>         wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/library
;@ Cursor table of the library's monster list: page number position, 5 rows, $FFFF ends.
MonsterListCursorPos::
	dw $0152, $0029, $0069, $00a9, $00e9, $0129, $ffff

;@ def LibraryShowMonster()
;@ path: menu/library
;@ Sub-step 6: clears the screen and shows the page of the chosen monster.
;@ test: skip decompresses graphics and calls other banks
LibraryShowMonster::
;> ClearTilemapBuffer()
	call ClearTilemapBuffer
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> DrawMonsterPage()
	call DrawMonsterPage
;> DrawMonsterPageFrame()
	call DrawMonsterPageFrame
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawMonsterPageFrame()
;@ path: menu/library
;@ Loads the frame tiles of the monster page ($2E26 to $8A50) and draws its full-screen window.
;@ test: skip decompresses graphics into VRAM
DrawMonsterPageFrame::
;> DecompressVRAM(0x2E26, 0x8A50)
	ld de, $2e26
	ld hl, $8a50
	call DecompressVRAM
;> DrawWindowLayout(LibraryMonsterPageWindow)
	ld de, LibraryMonsterPageWindow
	call DrawWindowLayout
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def DrawMonsterPage()
;@ path: menu/library
;@ Fills the library page of species wCurPartyMember: its name (group 5) at $9140, its
;@ one-line title (group 0; text $00FF while not met) at $91D0, its three-line description
;@ (group 1) at $94A0, its skills, its picture (MonPicGfx in the home bank, at $8800, with
;@ its colors) and its breeding pair.
;@ test: skip decompresses graphics and calls other banks
DrawMonsterPage::
;> wTextIndex = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wTextIndex], a
;> wTextGroup = 5
	ld a, $05
	ld [wTextGroup], a
;> DrawTextTiles(0x9140, 0x0901)
	ld hl, $9140
	ld de, $0901
	call DrawTextTiles
;> met = TestFlag(addr(wLibraryFlags), wCurPartyMember)
	ld hl, wLibraryFlags
	ld a, [wCurPartyMember]
	call TestFlag
;> wTextIndex = wCurPartyMember if met else 0xFF
	ld a, $ff
	jr z, .unknown
	ld a, [wCurPartyMember]
.unknown
	ld [wTextIndex], a
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;> DrawLongTextTiles(0x91D0, 0x1201)
	ld hl, $91d0
	ld de, $1201
	call DrawLongTextTiles
;> wTextIndex = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> DrawLongTextTiles(0x94A0, 0x1203)
	ld hl, $94a0
	ld de, $1203
	call DrawLongTextTiles
;> LoadSkillNameTiles()
	call LoadSkillNameTiles
;>@pic gfx = mem16[0x2B9F + 2 * wCurPartyMember]    # picture graphics of the species
	ld a, [wCurPartyMember]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
;=@pic
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
;=@pic
	ld d, [hl]
;> DecompressVRAM(gfx, 0x8800)
	ld hl, $8800
	call DecompressVRAM
;> mem16[0xC820] = 0x0021
	ld hl, $0021
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [$c821], a
;> wPaletteSet = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wPaletteSet], a
;> mem[0xC81F] = 4
	ld a, $04
	ld [wMonPicPalette], a
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> LoadBreedingIcons()
	call LoadBreedingIcons
	ret


;@ def DrawLongTextTiles(dest: hl, size: de)
;@ path: menu/library
;@ Like DrawTextTiles, but with the text printer of bank $4D (the library's long texts).
;@ test: skip calls bank $4D
DrawLongTextTiles::
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
;> PrintText_4D()
	ld hl, far_PrintText_4D
	rst $10
;>@restore restore(saved)
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


;@ def LoadSkillNameTiles()
;@ path: menu/library
;@ Looks the species up (GetMonsterStats) and renders the names of its 3 skills (record
;@ bytes 6-8, text group 6) into the letter tiles at $92F0, $9380, $9410.
;@ test: skip calls bank 3
LoadSkillNameTiles::
;> wMonSpecies = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> entry = addr(wMonStats) + 6                              # the skills
	ld de, wMonStats + 6
;> dest = 0x92F0
	ld hl, $92f0
;> for _ in range(3):                                 # the third by running into LoadSkillNameSlot
;>     dest, entry = LoadSkillNameSlot(dest, entry)
	call LoadSkillNameSlot
	call LoadSkillNameSlot

;@ def LoadSkillNameSlot(dest: hl, entry: de) -> (hl, de)
;@ path: menu/library
;@ Renders skill name mem[entry] (text group 6) into 9 letter tiles at `dest`, or blanks
;@ them for $FF (no skill).
;@ test: skip draws letter tiles
LoadSkillNameSlot::
;> if mem[entry] == 0xFF: return ClearNameSlot9(dest, entry)
	push de
	push hl
	ld a, [de]
	cp $ff
	jp z, ClearNameSlot9
;> wTextIndex = mem[entry]
	ld [wTextIndex], a
;> wTextGroup = 6                                     # skill names
	ld a, $06
	ld [wTextGroup], a
;> DrawTextTiles(dest, 0x0901)
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles
;>@r return dest + 0x90, entry + 1
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


;@ def LibraryMonsterPageInput()
;@ path: menu/library
;@ Library step 7, the page of one monster: Left/Right turn to the previous/next monster
;@ of the family already met (step 10 draws it), A or B goes back to the list (step 8);
;@ meanwhile the breeding pair sprites are drawn.
;@ test: skip draws sprites through bank 4
LibraryMonsterPageInput::
;> if wListLength >= 2:
	ld a, [wListLength]
	or a
	jr z, .keys
	cp $01
	jr z, .keys
;>     if wJoyPressed & 0x20:                           # Left
	ld a, [wJoyPressed]
	bit 5, a
	jr z, .notLeft
.left
;>@l         while True:                                # step back to the previous one met
;>@l             wConfirmChoice -= 1
	ld a, [wListLength]
	ld c, a
	cp $01
	jr z, .notLeft
	ld a, [wConfirmChoice]
	dec a
;=@l
	ld [wConfirmChoice], a
;>             if wConfirmChoice >= wListLength: wConfirmChoice = wListLength - 1
	cp c
	jr c, .checkLeft
	dec c
	ld a, c
	ld [wConfirmChoice], a
.checkLeft
;>@l2             if not IsListEntryUnknown(): break
	call IsListEntryUnknown
	jr z, .left
;>         wMenuSubStep = 10
	ld a, $0a
	ld [wMenuSubStep], a
;>         return
	jr .done
.notLeft
;>     if wJoyPressed & 0x10:                           # Right
	ld a, [wJoyPressed]
	bit 4, a
	jr z, .keys
.right
;>@r         while True:                                # on to the next one met
;>@r             wConfirmChoice += 1
	ld a, [wListLength]
	ld c, a
	cp $01
	jr z, .keys
	ld a, [wConfirmChoice]
	inc a
;=@r
	ld [wConfirmChoice], a
;>             if wConfirmChoice >= wListLength: wConfirmChoice = 0
	cp c
	jr c, .checkRight
	xor a
	ld [wConfirmChoice], a
.checkRight
;>@r2             if not IsListEntryUnknown(): break
	call IsListEntryUnknown
	jr z, .right
;>         wMenuSubStep = 10
	ld a, $0a
	ld [wMenuSubStep], a
;>         return
	jr .done
.keys
;> if wJoyPressed & 0x03:                             # A or B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr nz, .back
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .icons
.back
;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	jr .done
.icons
;> else:
;>     DrawBreedingIcons()
	call DrawBreedingIcons
.done
	ret


;@ def IsListEntryUnknown() -> zero
;@ path: menu/library
;@ Zero flag set when entry wConfirmChoice of the list is $E0 (a monster not met yet).
IsListEntryUnknown::
;>@e return wSceneObjects[wConfirmChoice] == 0xE0
	ld a, [wConfirmChoice]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@e
	ld h, a
	ld a, [hl]
	cp $e0
	ret


;@ def LibraryBackToList()
;@ path: menu/library
;@ Sub-step 8: from a monster's page back to the family's monster list (sub-step 5).
;@ test: skip draws into VRAM
LibraryBackToList::
;> ClearTilemapBuffer()
	call ClearTilemapBuffer
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> LoadFamilyNameTiles()
	call LoadFamilyNameTiles
;> LoadMonsterListNames()
	call LoadMonsterListNames
;> DrawLibraryMonsterList()
	call DrawLibraryMonsterList
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
	ret


;@ def LibraryFamilyEmpty()
;@ path: menu/library
;@ Sub-step 9: after "none met yet", back to the family list with message 1.
;@ test: skip prints a message
LibraryFamilyEmpty::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuSubStep = 1
	ld a, $01
	ld [wMenuSubStep], a
	ret


;@ def LibraryTurnPage()
;@ path: menu/library
;@ Library step 10: shows the page of list entry wConfirmChoice and moves the list cursor
;@ onto it (back to step 7).
;@ test: skip decompresses graphics and calls other banks
LibraryTurnPage::
;>@s wCurPartyMember = wSceneObjects[wConfirmChoice]
	ld a, [wConfirmChoice]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;> DrawMonsterPage()
	call DrawMonsterPage
;> DrawMonsterPageFrame()
	call DrawMonsterPageFrame
;> wMenuSubStep = 7
	ld a, $07
	ld [wMenuSubStep], a
;> page, row = divmod(wConfirmChoice, 5)
	ld a, [wConfirmChoice]
	ld b, a
	ld a, $05
	call Divide8
;> wListCursor = row | 0x80
	or $80
	ld [wListCursor], a
;> wListPage = page
	ld a, b
	ld [wListPage], a
	ret


;@ def LoadBreedingIcons()
;@ path: menu/library
;@ Looks up the breeding pair of species wCurPartyMember (bank $16) and loads the sprite
;@ tiles of both partners to $8600 and $8700 (entries that cannot be shown become $FF).
;@ test: skip calls bank $16
LoadBreedingIcons::
;> wBreedQuery = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wBreedQuery], a
;> LookupBreedPair()
	ld hl, far_LookupBreedPair
	rst $10
;> wBreedPair[0] = LoadBreedIconTiles(wBreedPair[0], 0x8600)
	ld a, [wBreedPair]
	ld hl, $8600
	call LoadBreedIconTiles
	ld [wBreedPair], a
;> wBreedPair[1] = LoadBreedIconTiles(wBreedPair[1], 0x8700)
	ld a, [wBreedPair + 1]
	ld hl, $8700
	call LoadBreedIconTiles
	ld [wBreedPair + 1], a
	ret


;@ def LoadBreedIconTiles(partner: a, dest: hl) -> a
;@ path: menu/library
;@ Loads the sprite graphics of breeding partner `partner` (sprite set partner + $10, from
;@ BreedIconGfx) to `dest`. $FF stays $FF; $FA and $F0-$FE return $FF (nothing to show).
;@ test: skip decompresses graphics into VRAM
LoadBreedIconTiles::
;> if partner == 0xFF: return 0xFF
	cp $ff
	ret z
;> if partner == 0xFA or partner >= 0xF0: return 0xFF
	cp $fa
	jr z, .none
	cp $f0
	jr nc, .none
;>@g DecompressVRAM(BreedIconGfx[partner + 0x10], dest)
	push af
	push hl
	add $10
	ld l, a
	ld h, $00
	add hl, hl
;=@g
	ld a, l
	add LOW(BreedIconGfx)
	ld l, a
	ld a, h
	adc HIGH(BreedIconGfx)
	ld h, a
;=@g
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call DecompressVRAM
;> return partner
	pop af
	ret
.none
	ld a, $ff
	ret


;@ path: menu/library
;@ Sprite graphics of each sprite set, u16 graphics numbers (bank << 8 | entry, for
;@ DecompressVRAM): sets 0-15 (other sprites, $2F00 / $3140), 16-31 bank $2F entries 1-16,
;@ then the monster sprites in banks $38-$3A. LoadBreedIconTiles reads entry partner + $10.
BreedIconGfx::
	dw $2f00
	dw $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140, $3140
	dw $2f01, $2f02, $2f03, $2f04, $2f05, $2f06, $2f07, $2f08, $2f09, $2f0a, $2f0b, $2f0c, $2f0d, $2f0e, $2f0f, $2f10
	dw $3800, $3801, $3802, $3803, $3804, $3805, $3806, $3807, $3808, $3809, $380a, $380b, $380c, $380d, $380e, $380f
	dw $3810, $3811, $3812, $3813, $3814, $3815, $3816, $3817, $3818, $3819, $381a, $381b, $381c, $381d, $381e, $381f
	dw $3820, $3821, $3822, $3823, $3824, $3825, $3826, $3827, $3828, $3829, $382a, $382b, $382c, $382d, $382e, $382f
	dw $3830, $3831, $3832, $3833, $3834, $3835, $3836, $3837, $3838, $3839, $383a, $383b, $383c, $383d, $383e, $383f
	dw $3840, $3841, $3842, $3843, $3844, $3845, $3846, $3847
	dw $3900, $3901, $3902, $3903, $3904, $3905, $3906, $3907, $3908, $3909, $390a, $390b, $390c, $390d, $390e, $390f
	dw $3910, $3911, $3912, $3913, $3914, $3915, $3916, $3917, $3918, $3919, $391a, $391b, $391c, $391d, $391e, $391f
	dw $3920, $3921, $3922, $3923, $3924, $3925, $3926, $3927, $3928, $3929, $392a, $392b, $392c, $392d, $392e, $392f
	dw $3930, $3931, $3932, $3933, $3934, $3935, $3936, $3937, $3938, $3939, $393a, $393b, $393c, $393d, $393e, $393f
	dw $3940, $3941, $3942, $3943, $3944, $3945, $3946, $3947
	dw $3a00, $3a01, $3a02, $3a03, $3a04, $3a05, $3a06, $3a07, $3a08, $3a09, $3a0a, $3a0b, $3a0c, $3a0d, $3a0e, $3a0f
	dw $3a10, $3a11, $3a12, $3a13, $3a14, $3a15, $3a16, $3a17, $3a18, $3a19, $3a1a, $3a1b, $3a1c, $3a1d, $3a1e, $3a1f
	dw $3a20, $3a21, $3a22, $3a23, $3a24, $3a25, $3a26, $3a27, $3a28, $3a29, $3a2a, $3a2b, $3a2c, $3a2d, $3a2e, $3a2f
	dw $3a30, $3a31, $3a32, $3a33, $3a34, $3a35, $3a36

;@ def DrawBreedingIcons()
;@ path: menu/library
;@ On the page of a monster already met, draws the two breeding partners as animated
;@ sprites (frame from wFrameCounter bit 4) at Y $28 and $38, X $48, with the tiles
;@ loaded to $8600 / $8700. Nothing is drawn while a partner cannot be shown.
;@ test: skip draws sprites through bank 4
DrawBreedingIcons::
;> if not TestFlag(addr(wLibraryFlags), wCurPartyMember): return
	ld hl, wLibraryFlags
	ld a, [wCurPartyMember]
	call TestFlag
	ret z
;> if wBreedPair[0] != 0xFF and wBreedPair[0] >= 0xF0: return
	ld a, [wBreedPair]
	cp $ff
	jr z, .first
	cp $f0
	ret nc
.first
;> if wBreedPair[1] != 0xFF and wBreedPair[1] >= 0xF0: return
	ld a, [wBreedPair + 1]
	cp $ff
	jr z, .second
	cp $f0
	ret nc
.second
;> if wBreedPair[0] != 0xFF:
	ld a, [wBreedPair]
	cp $ff
	jr z, .partner2
;>     hSpriteX = 0x48
	push af
	ld hl, hSpriteX
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteY = 0x28
	ld a, $28
	ld [hli], a
	ld a, $00
	ld [hli], a
;>     hSpriteSet = wBreedPair[0] + 0x10
	pop af
	add $10
	ld [hli], a
;>@f1     hSpriteFrame = 1 if wFrameCounter & 0x10 else 0
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame1
	ld b, $01
.frame1
;=@f1
	ld a, b
	ld [hli], a
;>     hSpriteTileBase = 0x60
	ld a, $60
	ld [hli], a
;>     hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;>     DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
.partner2
;> if wBreedPair[1] == 0xFF: return
	ld a, [wBreedPair + 1]
	cp $ff
	ret z
;> hSpriteX = 0x48
	push af
	ld hl, hSpriteX
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x38
	ld a, $38
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = wBreedPair[1] + 0x10
	pop af
	add $10
	ld [hli], a
;>@f2 hSpriteFrame = 1 if wFrameCounter & 0x10 else 0
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame2
	ld b, $01
.frame2
;=@f2
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x70
	ld a, $70
	ld [hli], a
;> hSpriteAttr = 0
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def ChooseMonsterMenu()
;@ path: menu/choose
;@ Script menu 9, choose one of the player's own monsters: runs the current step.
;@ test: skip jumps through a table to routines that call other banks
ChooseMonsterMenu::
;> return ChooseMonsterSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: menu/choose
;@ Steps: set up, wait a frame, clear the cursors, run, close.
ChooseMonsterSteps::
	dw ChooseMonsterInit
	dw ChooseMonsterWait
	dw ChooseMonsterResetCursors
	dw ChooseMonsterRun
	dw ChooseMonsterClose

;@ def ChooseMonsterInit()
;@ path: menu/choose
;@ Script menu 9, choose one of the player's own monsters, step 0: nothing chosen yet
;@ (wChosenMonPic = $FF), lines the windows up with the background, clears the cursors and
;@ loads the menu font.
;@ test: skip decompresses graphics into VRAM
ChooseMonsterInit::
;> SnapToTile(addr(hScrollX))
	ld hl, hScrollX
	call SnapToTile
;> SnapToTile(addr(hScrollY))
	ld hl, hScrollY
	call SnapToTile
;> wChosenMonPic = 0xFF                               # nothing chosen
	ld a, $ff
	ld [wChosenMonPic], a
;> fill(addr(wMenuChoice), 0, 8)                            # the menu cursors
	ld hl, wMenuChoice
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
;> DecompressVRAM(0x2E11, 0x8800)                     # menu font tiles
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
;> ResetCursorBlink()
	call ResetCursorBlink
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ChooseMonsterWait()
;@ path: menu/choose
;@ Step 1: goes on to step 2.
ChooseMonsterWait::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ChooseMonsterResetCursors()
;@ path: menu/choose
;@ Step 2: starts at sub-step 0 with all cursors cleared.
ChooseMonsterResetCursors::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> fill(addr(wMenuChoice), 0x00, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(addr(wListCursor), 0x00, 8)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ret


;@ def ChooseMonsterRun()
;@ path: menu/choose
;@ Step 3: runs the current sub-step.
;@ test: skip jumps through a table to routines that call other banks
ChooseMonsterRun::
;> return ChooseMonsterDispatch()
	jr ChooseMonsterDispatch

;@ def ChooseMonsterClose()
;@ path: menu/choose
;@ Step 4: removes the windows and ends the script menu (the result is in wChosenMonPic etc.).
;@ test: skip draws into VRAM
ChooseMonsterClose::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wFieldFlags &= ~0x10                               # the script menu is closed
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def ChooseMonsterDispatch()
;@ path: menu/choose
;@ Runs the current sub-step (wMenuSubStep).
;@ test: skip jumps through a table to routines that call other banks
ChooseMonsterDispatch::
;> return ChooseMonsterSubSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: menu/choose
;@ Sub-steps: list the party, choose, confirm, check the master, accept or refuse.
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

;@ def ChooseMonsterStart()
;@ path: menu/choose
;@ Sub-step 0: lists the party and asks which monster (message 3).
;@ test: skip prints a message
ChooseMonsterStart::
;> SetListLengthToParty()
	call SetListLengthToParty
;> ListPartyMonsters()
	call ListPartyMonsters
;> PrintMenuText(3)
	ld hl, $0003
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def SetListLengthToParty()
;@ path: menu/choose
;@ The list has as many entries as the party.
SetListLengthToParty::
;> wListLength = wPartyCount
	ld a, [wPartyCount]
	ld [wListLength], a
	ret


;@ def ListPartyMonsters()
;@ path: menu/choose
;@ Copies the three party slots into the list buffer wSceneObjects (the rest $FF).
ListPartyMonsters::
;> fill(addr(wSceneObjects), 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> wSceneObjects[0] = wParty[0]
	ld a, [wParty]
	ld [wSceneObjects], a
;> wSceneObjects[1] = wParty[1]
	ld a, [wParty + 1]
	ld [wSceneObjects + 1], a
;> wSceneObjects[2] = wParty[2]
	ld a, [wParty + 2]
	ld [wSceneObjects + 2], a
	ret


;@ def ChooseMonsterShowList()
;@ path: menu/choose
;@ Sub-step 1: once the message is printed, shows the party list.
;@ test: skip draws into VRAM
ChooseMonsterShowList::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> LoadChooseNameTiles()
	call LoadChooseNameTiles
;> DrawChooseMonsterWindow()
	call DrawChooseMonsterWindow
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawChooseMonsterWindow()
;@ path: menu/choose
;@ Draws the message window and the party list window (3 rows) and copies it to the screen.
;@ test: skip draws into VRAM
DrawChooseMonsterWindow::
;> RestoreTilemapBuffer()
	call RestoreTilemapBuffer
;> DrawWindowLayout(0x2E07)                           # message window (home bank)
	ld de, $2e07
	call DrawWindowLayout
;> DrawWindowLayout(ChooseMonsterWindow)
	ld de, ChooseMonsterWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawListFrame(addr(wListCursor), ChooseListCursorPos, 3, wListLength)
	ld de, ChooseListCursorPos
	ld b, $03
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
	ret


;@ def LoadChooseNameTiles()
;@ path: menu/choose
;@ Renders the names of the listed party monsters into the letter tiles at $8800, $8840, $8880.
;@ test: skip draws letter tiles
LoadChooseNameTiles::
;>@e entry = addr(wSceneObjects) + wListPage * 4
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@e
	ld a, $00
	adc d
	ld d, a
;> dest = 0x8800
	ld hl, $8800
;> for _ in range(3):                                 # the third by running into LoadChooseNameSlot
;>     dest, entry = LoadChooseNameSlot(dest, entry)
	call LoadChooseNameSlot
	call LoadChooseNameSlot

;@ def LoadChooseNameSlot(dest: hl, entry: de) -> (hl, de)
;@ path: menu/choose
;@ Renders the name of monster record mem[entry] into 4 letter tiles at `dest` (blank
;@ tiles for $FF) and returns the next tile address and list entry.
;@ test: skip draws letter tiles
LoadChooseNameSlot::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank
;>@name     DrawNameTiles(dest, MonsterField(mem[entry], addr(wMonName)))
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
;=@name
	push hl
	call DrawNameTiles
;>@ret     return dest + 0x40, entry + 1
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@ret
	ld h, a
	pop de
	inc de
	ret
.blank
;> for _ in range(0x20):
	ld b, $20
.loop
;>     WriteVRAMInc(dest, 0xFF); dest += 1
	ld a, $ff
	call WriteVRAMInc
;>     WriteVRAMInc(dest, 0x00); dest += 1
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .loop
;>@ret2 return dest + 0x40, entry + 1                # dest restored first
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@ret2
	ld h, a
	pop de
	inc de
	ret


;@ def ChooseMonsterListInput()
;@ path: menu/choose
;@ Step 2: moves the cursor over the party; B ends the menu with nothing chosen, A asks to
;@ confirm.
;@ test: skip draws into VRAM
ChooseMonsterListInput::
;>@old old_page = wListPage
	ld de, ChooseListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $03
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdatePagedList(addr(wListCursor), 3, wListLength, ChooseListCursorPos)
	call UpdatePagedList
;> if wListPage != old_page:
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .keys
;>     LoadChooseNameTiles()
	call LoadChooseNameTiles
.keys
;> if wJoyPressed & 0x02:                             # B: end, nothing chosen
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
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
.done
	ret


;@ path: menu/choose
;@ Cursor table of the party list: page number position, 3 rows, $FFFF ends.
ChooseListCursorPos::
	dw $0105, $0061, $00a1, $00e1, $ffff

;@ def ChooseMonsterAskConfirm()
;@ path: menu/choose
;@ Sub-step 3: asks about the chosen monster (message 5).
;@ test: skip prints a message
ChooseMonsterAskConfirm::
;> PrintMenuText(5)
	ld hl, $0005
	call PrintMenuText
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;> wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
	ret


;@ def ChooseMonsterShowYesNo()
;@ path: menu/choose
;@ Sub-step 4: once the question is printed, opens the yes/no window.
;@ test: skip draws into VRAM
ChooseMonsterShowYesNo::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout(ChooseYesNoWindow)
	ld de, ChooseYesNoWindow
	call DrawWindowLayout
;> ResetCursorBlink()
	call ResetCursorBlink
;> DrawCursorAt(wMenuChoice3, ChooseYesNoCursorPos)
	ld de, ChooseYesNoCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt
;> CopyTilemapBufferToVram()
	call CopyTilemapBufferToVram
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ChooseMonsterYesNoInput()
;@ path: menu/choose
;@ Step 5: yes checks the chosen monster (step 6); no or B goes back to the list (step 1).
;@ test: skip draws into VRAM
ChooseMonsterYesNoInput::
;> UpdateMenuCursor(addr(wMenuChoice3), 2, ChooseYesNoCursorPos)
	ld de, ChooseYesNoCursorPos
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor
;> if not wJoyPressed & 0x02:
;>@a     if not wJoyPressed & 0x01: return
;>@b     QueueSound(0x59)
;>@c     if wMenuChoice3 != 0x81:                       # yes
;>@d         wMenuSubStep += 1
;>@d         return
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB
.back
;> # B, or A on "no": back to the list
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuSubStep = 1
	ld a, $01
	ld [wMenuSubStep], a
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
	ld a, [wMenuChoice3]
	cp $81
	jr z, .back
;=@d
	ld hl, wMenuSubStep
	inc [hl]
.done
	ret


;@ path: menu/choose
;@ Cursor positions of the yes/no window: 2 u16 window offsets, $FFFF ends.
ChooseYesNoCursorPos::
	dw $012f, $016f, $ffff

;@ def ChooseMonsterCheckMaster()
;@ path: menu/choose
;@ Step 6: only a monster whose master is the player can be chosen (all 9 bytes of
;@ wMonMaster must match wPlayerName); otherwise message 4 and step 8. A good choice
;@ fills wChosenMonPic (species + $10), wChosenMonName, wChosenMonGender and
;@ wChosenMonSpecies (step 7).
;@ test: skip prints a message
ChooseMonsterCheckMaster::
;>@t1 wCurPartyMember = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@t1
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@t1
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;> master = MonsterField(wCurPartyMember, addr(wMonMaster))
	ld hl, wMonMaster
	call MonsterField
;> for i in range(9):
	ld de, wPlayerName
	ld b, $09
.loop
;>     if wPlayerName[i] != mem[master + i]:            # not the player's monster
	ld a, [de]
	cp [hl]
	jr z, .same
;>         PrintMenuText(4)
	ld hl, $0004
	call PrintMenuText
;>         wMenuSubStep += 2
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
;>         return
	ret
.same
	inc de
	inc hl
	dec b
	jr nz, .loop
;> wChosenMonPic = mem[MonsterField(wCurPartyMember, addr(wMonRecSpecies))] + 0x10
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wChosenMonPic], a
;>@n wChosenMonName = MonsterField(wCurPartyMember, addr(wMonName))
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
	ld a, h
;=@n
	ld [wChosenMonName + 1], a
;> wChosenMonGender = mem[MonsterField(wCurPartyMember, addr(wMonGender))]
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
;> wChosenMonSpecies = mem[MonsterField(wCurPartyMember, addr(wMonRecSpecies))]
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wChosenMonSpecies], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def ChooseMonsterAccept()
;@ path: menu/choose
;@ Sub-step 7: once the message is printed, closes the menu (step 4).
ChooseMonsterAccept::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def ChooseMonsterNotYours()
;@ path: menu/choose
;@ Sub-step 8: after "not your monster", back to the list (sub-step 1) with message 1.
;@ test: skip prints a message
ChooseMonsterNotYours::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;> wMenuSubStep = 1
	ld a, $01
	ld [wMenuSubStep], a
	ret


;@ def CollectorMenu()
;@ path: menu/collector
;@ Script menu 10, the item collector: runs the current step (wMenuStep).
;@ test: skip jumps through a table to routines that call other banks
CollectorMenu::
;> return CollectorSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: menu/collector
;@ Steps: take the items, report, give an egg, its message, the next goal, close.
CollectorSteps::
	dw CollectorTakeItems
	dw CollectorReport
	dw CollectorGiveEgg
	dw CollectorRewardText
	dw CollectorNextGoal
	dw CollectorClose

;@ def CollectorTakeItems()
;@ path: menu/collector
;@ Script menu 10, the item collector, step 0: takes every item $1E out of the bag and adds
;@ them to wCollectedItems (at most 999). Prints message 1, or message 15 once all four
;@ rewards were given; without such items goes straight on.
;@ test: skip calls bank 3
CollectorTakeItems::
;> n = 0
	ld hl, wBagItems
	ld b, $14
	ld c, $00
.loop
;>@loop for i in range(20):
;>     if wBagItems[i] == 0x1E:
	ld a, [hl]
	cp $1e
	jr nz, .next
;>         wBagItems[i] = 0xFF; n += 1
	ld [hl], $ff
	inc c
.next
;=@loop
	inc hl
	dec b
	jr nz, .loop
;> wItemsHandedIn = n
	ld a, c
	ld [wItemsHandedIn], a
;> if n == 0:
;>@none     wMenuStep += 1
;>@none     return
	or a
	jr z, .none
;>@sum total = wCollectedItems + n
	ld a, [wCollectedItems]
	ld l, a
	ld a, [wCollectedItems + 1]
	ld h, a
	ld a, [wItemsHandedIn]
	add l
;=@sum
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wCollectedItems = total
	ld a, l
	ld [wCollectedItems], a
	ld a, h
	ld [wCollectedItems + 1], a
;>@cap if total >= 999: wCollectedItems = 999
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
;=@cap
	jr c, .counted
	ld hl, $03e7
	ld a, l
	ld [wCollectedItems], a
	ld a, h
	ld [wCollectedItems + 1], a
.counted
;> CompactBag()
	ld hl, far_CompactBag
	rst $10
;> if wCollectorStep != 4:
	ld a, [wCollectorStep]
	cp $04
	jr z, .allGiven
;>     PrintMenuText(1)
	ld hl, $0001
	call PrintMenuText
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret
.allGiven
;> else:
;>     PrintMenuText(15)
	ld hl, $000f
	call PrintMenuText
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret
.none
;=@none
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def CollectorReport()
;@ path: menu/collector
;@ Step 1: once the message is printed, puts the collected count into wTextArg0. While
;@ rewards are left, the next goal goes to wTextArg1; when it is reached message 2 and the
;@ reward (step 2), else the goal message (step 4). With all rewards given, message 16
;@ thanks for the items handed in this time.
;@ test: skip prints a message
CollectorReport::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> Number16ToDecimal(wCollectedItems, addr(wTextArg0))
	ld a, [wCollectedItems]
	ld c, a
	ld a, [wCollectedItems + 1]
	ld b, a
	ld hl, wTextArg0
	call Number16ToDecimal
;> if wCollectorStep != 4:
	ld a, [wCollectorStep]
	cp $04
	jr z, .allGiven
;>@goal     goal = CollectorRewards[wCollectorStep].count
	ld a, [wCollectorStep]
	add a
	add a
	ld hl, CollectorRewards
	add l
	ld l, a
;=@goal
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>     Number16ToDecimal(goal, addr(wTextArg1))
	push bc
	ld hl, wTextArg1
	call Number16ToDecimal
	pop bc
;>@cmp     if wCollectedItems >= goal:
	ld a, [wCollectedItems]
	ld l, a
	ld a, [wCollectedItems + 1]
	ld h, a
	ld a, l
	sub c
;=@cmp
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr c, .notYet
;>         PrintMenuText(2)
	ld hl, $0002
	call PrintMenuText
;>         wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret
.notYet
;>     else:
;>         wMenuStep = 4
	ld a, $04
	ld [wMenuStep], a
	ret
.allGiven
;> elif wItemsHandedIn == 0:
;>@nh     wMenuStep = 4                                    # (jumps to the code above)
	ld a, [wItemsHandedIn]
	or a
	jr z, .notYet
;> else:
;>     Number16ToDecimal(wItemsHandedIn, addr(wTextArg0))
	ld a, [wItemsHandedIn]
	ld c, a
	ld b, $00
	ld hl, wTextArg0
	call Number16ToDecimal
;>     PrintMenuText(16)
	ld hl, $0010
	call PrintMenuText
;>     wMenuStep = 4
	ld a, $04
	ld [wMenuStep], a
	ret


;@ def CollectorGiveEgg()
;@ path: menu/collector
;@ Step 2: gives the reward: an egg of monster CollectorRewards[wCollectorStep].monster in
;@ the first free record, sets event flag $50 + reward number and counts the reward
;@ (step 3). With all 20 records in use: message 11 and the end (step 5).
;@ test: skip calls bank $14
CollectorGiveEgg::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> slot = 0
	ld hl, wMonsters
	ld b, $14
	ld c, $00
.find
;>@find while slot < 20 and wMonsters[slot * 0x95] != 0: slot += 1    # first free record
	ld a, [hl]
	or a
	jr z, .found
	ld a, l
	add $95
	ld l, a
;=@find
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, .find
.found
;> if slot >= 20:
	ld a, c
	cp $14
	jr nc, .full
;>     wNewMonSlot = slot
	ld a, c
	ld [wNewMonSlot], a
;>@id     wNewMonId = CollectorRewards[wCollectorStep].monster
	ld a, [wCollectorStep]
	add a
	add a
	ld hl, CollectorRewards + 2
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@id
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [wNewMonId + 1], a
;>     CreateMonster()
	ld hl, far_CreateMonster
	rst $10
;>     mem[MonsterField(wNewMonSlot, addr(wMonEgg))] = 1      # it is an egg
	ld a, [wNewMonSlot]
	ld hl, wMonEgg
	call MonsterField
	ld [hl], $01
;>@flag     SetEventFlag(0x50 + wCollectorStep)          # (steps 0-7 have a flag)
	ld a, [wCollectorStep]
	ld bc, $0050
	cp $00
	jr z, .flag
	ld bc, $0051
	cp $01
;=@flag
	jr z, .flag
	ld bc, $0052
	cp $02
	jr z, .flag
	ld bc, $0053
	cp $03
;=@flag
	jr z, .flag
	ld bc, $0054
	cp $04
	jr z, .flag
	ld bc, $0055
	cp $05
;=@flag
	jr z, .flag
	ld bc, $0056
	cp $06
	jr z, .flag
	ld bc, $0057
	cp $07
;=@flag
	jr z, .flag
	jr .noFlag
.flag
	call SetEventFlag
.noFlag
;>     wCollectorStep += 1
	ld hl, wCollectorStep
	inc [hl]
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret
.full
;> else:
;>     PrintMenuText(11)                                # no room for the egg
	ld hl, $000b
	call PrintMenuText
;>     wMenuStep = 5
	ld a, $05
	ld [wMenuStep], a
	ret


;@ def CollectorRewardText()
;@ path: menu/collector
;@ Step 3: once the message is printed, prints the message of the reward just given
;@ (message 2 + rewards given, 3-6) and ends (step 5).
;@ test: skip prints a message
CollectorRewardText::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;>@t PrintMenuText(2 + wCollectorStep)
	ld a, [wCollectorStep]
	ld hl, $0002
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	call PrintMenuText
;> wMenuStep = 5
	ld a, $05
	ld [wMenuStep], a
	ret


;@ def CollectorNextGoal()
;@ path: menu/collector
;@ Step 4: once the message is printed, tells how many items are collected: while rewards
;@ are left with the next goal and the name of its monster (wTextArg1/wTextArg2, message
;@ 12), else message 17. Then the end (step 5).
;@ test: skip calls bank $14
CollectorNextGoal::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz
;> Number16ToDecimal(wCollectedItems, addr(wTextArg0))
	ld a, [wCollectedItems]
	ld c, a
	ld a, [wCollectedItems + 1]
	ld b, a
	ld hl, wTextArg0
	call Number16ToDecimal
;> if wCollectorStep != 4:
	ld a, [wCollectorStep]
	cp $04
	jr z, .allGiven
;>@goal     Number16ToDecimal(CollectorRewards[wCollectorStep].count, addr(wTextArg1))
	ld a, [wCollectorStep]
	add a
	add a
	ld hl, CollectorRewards
	add l
	ld l, a
;=@goal
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@goal
	ld hl, wTextArg1
	call Number16ToDecimal
;>@id     wNewMonId = CollectorRewards[wCollectorStep].monster
	ld a, [wCollectorStep]
	add a
	add a
	ld hl, CollectorRewards + 2
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@id
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [wNewMonId + 1], a
;>     LoadMonTemplate()
	ld hl, far_LoadMonTemplate
	rst $10
;>     CopySystemText(0x0500 + wNewMonNameText, addr(wTextArg2))    # the monster's name
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg2
	call CopySystemText
;>     PrintMenuText(12)
	ld hl, $000c
	call PrintMenuText
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret
.allGiven
;> else:
;>     PrintMenuText(17)
	ld hl, $0011
	call PrintMenuText
;>     wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def CollectorClose()
;@ path: menu/collector
;@ Step 5: once the message is printed, ends the script menu.
CollectorClose::
;> if wTextState: return                              # wait for the message
	ld a, [wTextState]
	or a
	ret nz
;> wFieldFlags &= ~0x10                               # the script menu is closed
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ path: menu/collector
;@ Rewards of the item collector, one 4-byte record per reward: u16 number of items $1E
;@ collected in all, u16 monster whose egg is given (the egg maker's monster number);
;@ $FFFF ends. Goals 13, 18, 25 and 30.
CollectorRewards::
	db $0d, $00, $50, $01, $12, $00, $51, $01, $19, $00, $53, $01, $1e, $00, $54, $01
	db $ff, $ff

;@ path: unused
;@ Window layout not used by this bank (20 x 5 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6D3B::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5
	db $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
	db $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (6 x 5 tiles at row 8, column 14).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6DA6::
	db $0e, $01, $fa
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: menu/windows
;@ Window layout: the yes/no window of the choose-a-monster menu, 6 x 5 tiles at row 8, column 14.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
ChooseYesNoWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (6 x 5 tiles at row 8, column 14).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6DF0::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $a8, $a7, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (8 x 3 tiles at row 0, column 12).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6E15::
	db $0c, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (8 x 7 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6E32::
	db $00, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (19 x 9 tiles at row 4, column 1).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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
;@ path: unused
;@ Window layout not used by this bank (4 x 3 tiles at row 10, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6F29::
	db $40, $01, $fa, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd
	db $d9

;@ path: unused
;@ Window layout not used by this bank (7 x 3 tiles at row 10, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6F3A::
	db $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the yes/no window of the farm keeper, 6 x 5 tiles at row 8, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
FarmYesNoWindow::
	db $00, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused
;@ Window layout not used by this bank (12 x 9 tiles at row 4, column 8).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6F79::
	db $88, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b
	db $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (8 x 5 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow6FF0::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (7 x 5 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow701F::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: unused
;@ Window layout not used by this bank (12 x 9 tiles at row 3, column 8).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow7049::
	db $68, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b
	db $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (8 x 3 tiles at row 3, column 12).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow70C0::
	db $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (14 x 3 tiles at row 10, column 6).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow70DD::
	db $46, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the farm menu with its six options, 11 x 13 tiles at row 0, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: menu/windows
;@ Window layout: the party list of the farm (3 names), 7 x 9 tiles at row 0, column 13.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
FarmPartyWindow::
	db $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82
	db $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86
	db $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a
	db $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the farm monster list (4 names a page, page number in the bottom frame), 7 x 11 tiles at row 0, column 13.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
FarmListWindow::
	db $0d, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the party list of the choose-a-monster menu, 7 x 9 tiles at row 0, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
ChooseMonsterWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $88, $89, $8a, $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (7 x 11 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow7298::
	db $00
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff
	db $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (7 x 5 tiles at row 0, column 13).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow72F2::
	db $0d, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (19 x 6 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow731C::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9e, $90, $d6, $99, $d5, $98
	db $e4, $a0, $a1, $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $da, $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac
	db $ad, $ae, $af, $ff, $d8, $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0
	db $e0, $e0, $e0, $9f, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (17 x 9 tiles at row 4, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: unused
;@ Window layout not used by this bank (9 x 7 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow743A::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8a
	db $98, $d5, $d5, $92, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $94, $90, $99, $91, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (7 x 11 tiles at row 2, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow7482::
	db $40, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb
	db $eb, $ed, $d8, $fe, $e0, $61, $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $65, $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (7 x 11 tiles at row 2, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow74DC::
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b
	db $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $61
	db $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $65
	db $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $69
	db $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6d
	db $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (11 x 5 tiles at row 8, column 9).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow7536::
	db $09, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71
	db $72, $73, $74, $75, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (11 x 3 tiles at row 5, column 9).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow7574::
	db $a9, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73
	db $74, $75, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: menu/windows
;@ Window layout: the level window (level and party mark of the monster under the cursor), 11 x 3 tiles at row 10, column 9.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
LevelWindow::
	db $49, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $e0, $e0, $65, $66, $67, $68, $69, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (11 x 3 tiles at row 10, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow75C0::
	db $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (13 x 9 tiles at row 4, column 7).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: unused
;@ Window layout not used by this bank (9 x 7 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow7666::
	db $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d5, $df, $9f, $de, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8
	db $de, $d5, $d6, $d6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (13 x 9 tiles at row 4, column 7).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: unused
;@ Window layout not used by this bank (7 x 7 tiles at row 0, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow772E::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $a8, $a9, $aa, $ab, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $ac, $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the farm counts window (monsters and eggs at the farm and in the second pen) with the monsters/eggs choice, 10 x 9 tiles at row 4, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
FarmCountsWindow::
	db $80
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $9e
	db $9f, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63
	db $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the egg list (species names and sex marks), 13 x 9 tiles at row 4, column 7.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: unused
;@ Window layout not used by this bank (8 x 5 tiles at row 0, column 12).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow784D::
	db $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $95, $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: unused
;@ Window layout not used by this bank (8 x 5 tiles at row 8, column 0).
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
UnusedWindow787C::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $a1, $a7, $a9, $a4, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a4, $a2, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: menu/windows
;@ Window layout: the yes/no window of the pen switch, 6 x 5 tiles at row 8, column 14.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
FarmSwitchWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the library family list (5 a page), 8 x 11 tiles at row 0, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
LibraryFamilyWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $67, $68, $69, $6a, $6b, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $6c, $6d, $6e, $6f, $70, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $71, $72, $73, $74, $75, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $76, $77, $78, $79, $7a, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $7b, $7c, $7d, $7e
	db $7f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the library monster list (5 names a page), 12 x 11 tiles at row 0, column 8.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: menu/windows
;@ Window layout: the full-screen page of one monster in the library, 20 x 18 tiles at row 0, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
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

;@ path: menu/windows
;@ Window layout: the two-choice window "status / do it" of the farm, 7 x 5 tiles at row 8, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
StatusOrOkWindow::
	db $00, $01, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: menu/windows
;@ Window layout: the two-choice window of the farm for eggs, 8 x 5 tiles at row 8, column 0.
;@ Format (DrawWindowLayout): u16 offset in the 32-wide tilemap buffer, tile numbers, $D8 next row, $D9 end.
EggStatusOrOkWindow::
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $95, $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: unused
;@ Unused space at the end of bank $12 (zero bytes).
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
