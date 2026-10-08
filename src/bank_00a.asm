INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $00a", ROMX[$4000], BANK[$a]

;@ path: system/banks
;@ Bank number byte: RST $10 reads it to know which bank to switch back to.
BankNumber_0A::
	db $0a

;@ path: system/banks
;@ Far-call entry points of bank $0A: one entry, the breeding / egg service screens.
FarTable_0A::
	dw RunServiceScreen0A

;@ def RunServiceScreen0A()
;@ path: breed/screens
;@ Runs one frame of the service screen a script opened over the field
;@ (wScriptMenu). This bank holds screen 5 (breeding with a monster the
;@ script offers), 6 (the breeding house: breed two monsters, hatch eggs),
;@ 7 (the egg appraiser) and 11 (a hatched monster joins the party); the
;@ other numbers are handled by banks $09 and $12.
;@ test: skip jumps through a table
RunServiceScreen0A::
;> ServiceScreens0A[wScriptMenu]()
	ld a, [wScriptMenu]
	rst $00

;@ path: breed/screens
;@ Handler of each service screen number (RST $00 jump table indexed by wScriptMenu).
ServiceScreens0A::
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw PartnerBreedScreen
	dw BreedingScreen
	dw EggAppraiserScreen
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw JoinPartyScreen
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A
	dw ServiceScreenNone0A

;@ def ServiceScreenNone0A()
;@ path: breed/screens
;@ Screen numbers this bank does not handle: nothing to do.
ServiceScreenNone0A::
;> return
	ret


;@ def RoundToTile(p: hl)
;@ path: menu/window
;@ Rounds the 16-bit pixel coordinate at `p` to the nearest multiple of 8, so
;@ the window drawn over the field lines up with whole background tiles.
;@ test: p = 0xC100
RoundToTile::
;> v = mem16[p] + 4
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
;> mem16[p] = v & 0xFFF8
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


;@ def NextScreenColumn(addr: hl) -> hl
;@ path: menu/window
;@ Steps a BG map address one tile to the right, wrapping around inside its
;@ 32-tile row.
NextScreenColumn::
;>@r return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@r
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@r
	ret


;@ def OffsetToScreenMap(offset: hl) -> hl
;@ path: menu/window
;@ Turns a tile offset on the screen (row * 32 + column) into a BG map address,
;@ counted from the screen's top left tile wWindowBgMap and wrapping inside the
;@ 1 KiB map.
;@ test: mem[0xC90A] = rng.choice([0x98, 0x99, 0x9A, 0x9B])
OffsetToScreenMap::
;> a = wWindowBgMap + offset
	ld a, [wWindowBgMap]
	add l
	ld l, a
	ld a, [wWindowBgMap + 1]
	adc h
;>@r return (wWindowBgMap & 0xFC00) | (a & 0x03FF)
	and $03
	ld h, a
	ld a, [wWindowBgMap + 1]
	and $fc
	or h
;=@r
	ld h, a
	ret


;@ def OffsetToTilemapBuffer(offset: hl) -> hl
;@ path: menu/window
;@ Turns a tile offset on the screen (row * 32 + column) into its address in
;@ wTilemapBuffer.
OffsetToTilemapBuffer::
;>@r return (wTilemapBuffer + offset) & 0xFFFF
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@r
	ret


;@ def PosToScreenMap(pos: hl) -> hl
;@ path: menu/window
;@ Turns a tile position on the screen (row * 32 + column) into its BG map
;@ address: the row is found from wWindowBgMap, then the column is stepped
;@ one tile at a time so it wraps around inside the 32-tile map row.
;@ test: mem[0xC90A] = rng.choice([0x98, 0x99, 0x9A, 0x9B]); hl = rand(0, 0x23F)
PosToScreenMap::
;> addr = OffsetToScreenMap(pos & 0xFFE0)
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call OffsetToScreenMap
;>@for for _ in range(pos & 0x1F):
	ld a, b
	and $1f
	jr z, .done

	ld b, a
.column
;>     addr = NextScreenColumn(addr)
	call NextScreenColumn
;=@for
	dec b
	jr nz, .column

.done
;> return addr
	pop bc
	ret


;@ def DrawWindowLayoutVRAM(layout: de)
;@ path: unused
;@ Unused: draws a window layout (see DrawWindowLayout0A) straight to the BG
;@ map instead of into wTilemapBuffer. Nothing calls it.
;@ test: skip writes VRAM while waiting for the LCD
DrawWindowLayoutVRAM::
;>@row row = PosToScreenMap(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@row
	call PosToScreenMap
;> addr = row
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
.loop
;> while True:
;>     t = mem[layout]
	ld a, [de]
;>     layout += 1
	inc de
;>     if t == 0xD9:              # end of the layout
	cp $d9
;>         return
	ret z

;>     if t == 0xD8:              # next row
	cp $d8
	jr nz, .tile

;>@nl         row = 0x9800 | ((row + 32) & 0x03FF)
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $20
;=@nl
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, h
	and $03
;=@nl
	or $98
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
;>         addr = row
	jr .loop

;>     else:
.tile
;>         WriteVRAM(addr, t)
	call WriteVRAM
;>         addr = NextScreenColumn(addr)
	call NextScreenColumn
	jr .loop

;@ def DrawWindowLayout0A(layout: de)
;@ path: menu/window
;@ Draws a window layout into wTilemapBuffer. A layout is a word, the tile
;@ position of its top left corner (row * 32 + column), followed by the tile
;@ numbers row by row: $D8 starts the next row, $D9 ends the layout.
;@ test: skip walks a data list
DrawWindowLayout0A::
;>@row row = OffsetToTilemapBuffer(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@row
	call OffsetToTilemapBuffer
;> p = row
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
.loop
;> while True:
;>     t = mem[layout]
	ld a, [de]
;>     layout += 1
	inc de
;>     if t == 0xD9:              # end of the layout
	cp $d9
;>         return
	ret z

;>     if t == 0xD8:              # next row
	cp $d8
	jr nz, .tile

;>@nl         row += 32
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $20
;=@nl
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hNumber], a
;=@nl
	ld a, h
	ldh [$ffd6], a
;>         p = row
	jr .loop

;>     else:
.tile
;>         mem[p] = t
;>         p += 1
	ld [hli], a
	jr .loop

;@ def ShowTilemapBuffer()
;@ path: menu/window
;@ Copies wTilemapBuffer (18 rows of 32 tiles) to the BG map, starting at the
;@ screen's top left tile wWindowBgMap and wrapping around the map, so the
;@ windows drawn into the buffer appear over the field.
;@ test: skip writes VRAM while waiting for the LCD
ShowTilemapBuffer::
;> row = wWindowBgMap
	ld a, [wWindowBgMap]
	ld l, a
	ld a, [wWindowBgMap + 1]
	ld h, a
;> src = wTilemapBuffer
	ld de, wTilemapBuffer
;>@rows for _ in range(18):
	ld c, $12
.row
;>     addr = row
	ld b, $20
	push hl
;>@cols     for _ in range(32):
.column
;>         WriteVRAM(addr, mem[src])
	ld a, [de]
	call WriteVRAM
;>@next         addr = NextScreenColumn(addr)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@next
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;>         src += 1
	inc de
;=@cols
	dec b
	jr nz, .column

;>@down     row = 0x9800 | ((row + 32) & 0x03FF)
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@down
	or $98
	ld h, a
	pop bc
;=@rows
	dec c
	jr nz, .row

	ret


;@ def RenderTextTiles(dest: hl, lines: e, length: d)
;@ path: text/tiles
;@ Draws text (wTextGroup, wTextIndex) into letter tiles at VRAM `dest`, as a
;@ box of `lines` lines of `length` characters (bank $41 does the drawing).
;@ The text printer's box settings are kept and put back afterwards.
;@ test: skip calls a routine in another bank
RenderTextTiles::
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
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
	ld [$c828], a
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = length
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_41()                      # render the text into the tiles
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def RenderNameTiles(dest: hl, name: de)
;@ path: text/tiles
;@ Draws a 4-letter monster or player name into letter tiles at VRAM `dest`
;@ (a box 4 tiles wide, one line high), through text 2:0, which prints
;@ wTextArg0.
;@ test: skip calls a routine in another bank
RenderNameTiles::
;> CopyName(name, wTextArg0)
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
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
	ld [$c828], a
;> wTextBoxLines = 1
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def RenderCharTile(c: a, dest: hl)
;@ path: unused
;@ Unused: draws the single character `c` into one letter tile at VRAM
;@ `dest` (what the gender marks do inline). Nothing calls it.
;@ test: skip calls a routine in another bank
RenderCharTile::
;> wTextArg0[0] = c
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0                 # end mark
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
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
	ld [$c828], a
;> wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
	ret

;@ def RestoreFieldTilemap()
;@ path: menu/window
;@ Rebuilds wTilemapBuffer from the field as it was when the screen opened:
;@ rows 0-15 from wSavedTilemap, rows 16-17 (20 tiles each) from
;@ wPartyBarTiles. Windows are then drawn on top of it.
;@ test: skip large copy
RestoreFieldTilemap::
;>@c1 copy(wTilemapBuffer, wSavedTilemap, 0x200)
	ld hl, wTilemapBuffer
	ld de, wSavedTilemap
	ld bc, $0200
.copy
;=@c1
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
;=@c1
	jr nz, .copy

;> src = wPartyBarTiles
;> dest = wTilemapBuffer + 0x200
	ld de, wPartyBarTiles
;>@rows for _ in range(2):
	ld c, $02
.row
;>@c2     copy(dest, src, 20)
	ld b, $14
.column
	ld a, [de]
	inc de
	ld [hli], a
	dec b
;=@c2
	jr nz, .column

;>     src += 12                 # 20 copied + 12 past the screen's right edge = one 32-tile row
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>     dest += 12
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


;@ def ClearTilemapBuffer0A()
;@ path: unused
;@ Unused: fills wTilemapBuffer (576 tiles) with the blank tile $E0.
ClearTilemapBuffer0A::
;>@f fill(wTilemapBuffer, 0xE0, 0x240)
	ld hl, wTilemapBuffer
	ld bc, $0240
.loop
	ld a, $e0
	ld [hli], a
	dec bc
;=@f
	ld a, b
	or c
	jr nz, .loop

	ret

;@ def ClearScreenMap()
;@ path: unused
;@ Unused: fills the whole BG map at $9800 with the blank tile $E0.
;@ test: skip writes VRAM while waiting for the LCD
ClearScreenMap::
;>@l for i in range(0x400):
	ld hl, $9800
	ld bc, $0400
.loop
;>     WriteVRAMInc(0x9800 + i, 0xE0)
	ld a, $e0
	call WriteVRAMInc
;=@l
	dec bc
	ld a, b
	or c
	jr nz, .loop

	ret

;@ def UpdateListCursor(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Moves the cursor of a paged list of `count` entries, `rows` per page.
;@ `cursor` points at the row (bit 7 = chosen), followed by the page;
;@ `table` is the list's cursor table (page marker position first). Left and
;@ Right (with auto-repeat) turn the page, wrapping around, and keep the row
;@ inside the last, shorter page; otherwise the page number is drawn and Up /
;@ Down move the row within the page (UpdateMenuCursor0A, which also handles
;@ A). Nothing turns while a message is printing.
;@ test: skip draws to VRAM
UpdateListCursor::
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> table += 2                               # past the page marker position
	inc de
	inc de
;> if not wTextState and wJoyRepeat & 0x30:  # Left or Right: turn the page
	ld a, [wTextState]
	or a
	jp nz, .rows

;>     if wJoyRepeat & 0x20:                 # Left
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .notLeft

;>@pl         page = (mem[cursor + 1] - 1) & 0xFF
	inc hl
	ld a, [hl]
	dec a
	push af
	push de
	push bc
;>@pn         pages = (count - 1) // rows + 1
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
;=@pn
	pop bc
	pop de
	ld c, a
;>         if page >= pages:                 # turned back from the first page
	pop af
	cp c
	jr c, .setPage

;>             page = pages - 1
	ld a, c
	dec a
;=@sp
	jr .setPage

.notLeft
;>     elif wJoyRepeat & 0x10:               # Right
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .rows

;>@pl2         page = mem[cursor + 1] + 1
	inc hl
	ld a, [hl]
	inc a
	push af
	push de
	push bc
;>@pn2         pages = (count - 1) // rows + 1
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
;=@pn2
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
;>@sp     mem[cursor + 1] = page
	ld [hld], a
;>@last     if page == pages - 1:                 # the last page may be shorter
	dec c
	cp c
	jr nz, jr_00a_42eb

;>@lr         left = count % rows
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
;>@cl         if left and left - 1 < mem[cursor]:
	or a
	jr z, jr_00a_42eb

	dec a
	cp [hl]
	jr nc, jr_00a_42eb

;>             mem[cursor] = left - 1       # onto its last row
	ld [hl], a
;=@mv
	jr jr_00a_42eb

;>@mv     jr_00a_42eb(cursor, table)            # the end of UpdateMenuCursor0A: blink reset, A, redraw
;>     return
;> else:
.rows
;>@dp     DrawPageNumber0A(cursor, table, rows, count)
	push bc
	push de
	push hl
	call DrawPageNumber0A
	pop hl
	pop de
;=@dp
	pop bc
;>@lp     last_page = (count - 1) // rows
;>     wListLastRows = (count - 1) % rows     # rows on the last page - 1
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
;>     if mem[cursor + 1] == last_page:
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateMenuCursor0A

;>         rows = wListLastRows + 1
	ld a, [wListLastRows]
	inc a
	ld b, a
;>     UpdateMenuCursor0A(cursor, table, rows)

;@ def UpdateMenuCursor0A(cursor: hl, table: de, n: b)
;@ path: menu/cursor
;@ Moves a menu cursor (row in mem[cursor], bit 7 = chosen) among `n` rows
;@ with Up and Down (auto-repeat), wrapping around; a move restarts the
;@ blink. A sets bit 7. Then the cursor column is redrawn from the cursor
;@ table `table` (DrawMenuCursor0A).
;@ test: skip draws to VRAM
UpdateMenuCursor0A::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:                     # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_00a_42dc

;>     row = mem[cursor] - 1
;>     if row >= n:                          # (also from 0 to 255)
	ld a, [hl]
	dec a
	cp b
	jr c, jr_00a_42ea

;>         row = n - 1
	dec b
	ld a, b
;=@st
	jr jr_00a_42ea

jr_00a_42dc:
;> elif wJoyRepeat & 0x80:                   # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_00a_42f3

;>     row = mem[cursor] + 1
;>     if row >= n:
	ld a, [hl]
	inc a
	cp b
	jr c, jr_00a_42ea

;>         row = 0
	ld a, $00

jr_00a_42ea:
;>@st if wJoyRepeat & 0xC0:
;>     mem[cursor] = row
	ld [hl], a

jr_00a_42eb:
;>     wCursorBlink = 0                      # (UpdateListCursor jumps here after turning a page)
	xor a
	ld [wCursorBlink], a
	push hl
	push de
	pop de
	pop hl

jr_00a_42f3:
;> if wJoyPressed & 0x01:                    # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_00a_42fc

;>     mem[cursor] |= 0x80
	set 7, [hl]

jr_00a_42fc:
;> DrawMenuCursor0A(mem[cursor], table)
	ld a, [hl]
	call DrawMenuCursor0A
	ret


;@ path: unused
;@ Unused code, kept as bytes: a left/right version of UpdateMenuCursor0A
;@ (Left steps the cursor back, Right forward, wrapping at the ends). Nothing
;@ jumps here, and its branches jump into UpdateMenuCursor0A.
UpdateMenuCursorH::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

;@ def ResetCursorBlink0A()
;@ path: menu/cursor
;@ Restarts the cursor blink, so the next DrawMenuCursor0A draws at once.
ResetCursorBlink0A::
;> wCursorBlink = 0
	xor a
	ld [wCursorBlink], a
	ret


;@ def DrawMenuCursor0A(sel: a, table: de)
;@ path: menu/cursor
;@ Redraws the cursor column of a menu: every row of the cursor table (tile
;@ positions up to $FFFF) gets a blank $E0, except row sel & $7F, which gets
;@ the arrow $E8 (blinking: blank while wCursorBlink bit 4 is set) or the
;@ filled arrow $E9 once chosen (bit 7). Drawn to the screen and into
;@ wTilemapBuffer. While nothing is chosen it only redraws every 16th frame.
;@ test: skip writes VRAM while waiting for the LCD
DrawMenuCursor0A::
;> if not sel & 0x80:
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
;>     if t != 0:
;>         return
	pop af
	ld a, c
	ret nz

.draw
;> row = 0
	ld c, a
	ld b, $00
.loop
;> while True:
;>     pos = mem16[table]; table += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if pos == 0xFFFF:
	and l
	cp $ff
;>         return
	ret z

;>@a     addr = PosToScreenMap(pos)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
;=@a
	call PosToScreenMap
	pop bc
	pop de
;>     if sel & 0x7F != row:
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .tile

;>         tile = 0xE0
;>     elif sel & 0x80:
	ld a, $e9
	bit 7, c
	jr nz, .tile

;>         tile = 0xE9
;>     elif wCursorBlink & 0x10:
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .tile

;>         tile = 0xE0
;>     else:
;>         tile = 0xE8
	ld a, $e8

.tile
;>     WriteVRAM(addr, tile)
	call WriteVRAM
;>@buf     mem[OffsetToTilemapBuffer(pos)] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
;=@buf
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@buf
	ld [hl], a
;>     row += 1
	inc b
	jr .loop

;@ def DrawPageNumber0A(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ When the list has more entries than a page has rows, draws the page
;@ number (cursor[1] + 1, as tile $F1 + page) one tile left of the page
;@ marker position (the first entry of the cursor table; `table` points just
;@ past it), on the screen and in wTilemapBuffer.
;@ test: skip writes VRAM while waiting for the LCD
DrawPageNumber0A::
;> if rows >= count:
	ld a, b
	cp c
;>     return
	ret nc

;> page = mem[cursor + 1]
	inc hl
	ld c, [hl]
;>@pos pos = mem16[table - 2]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
;=@pos
	ld h, a
	inc de
;> if pos == 0xFFFF:
	and l
	cp $ff
;>     return
	ret z

;> pos -= 1
	dec hl
;>@w WriteVRAM(PosToScreenMap(pos), (page & 0x7F) + 0xF1)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
;=@w
	call PosToScreenMap
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
;=@w
	call WriteVRAM
;>@buf mem[OffsetToTilemapBuffer(pos)] = (page & 0x7F) + 0xF1
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
;=@buf
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@buf
	ld [hl], a
	ret


;@ def DrawListCursor(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws a paged monster list's markers into wTilemapBuffer. `cursor` points
;@ at the cursor row (bit 7 = chosen), followed by the page number; `table`
;@ is the list's cursor table: the position of the page marker, then the
;@ position of each row. When the list has more entries than a page has rows
;@ the marker shows an arrow ($E7) with the page number ($F1 = "1") left of
;@ it, else a plain frame tile ($EE). Then the row cursor is drawn.
;@ test: skip draws a list from tables
DrawListCursor::
;> sel = mem[cursor]
	ld a, [hli]
	push af
	push hl
;>@p p = OffsetToTilemapBuffer(mem16[table])
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
;=@p
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
;=@p
	ld h, a
;> tile = 0xE7 if rows < count else 0xEE    # more than one page: an arrow
	ld a, b
	cp c
	ld a, $ee
	jr nc, .onePage

	ld a, $e7

.onePage
;> mem[p] = tile
	ld [hld], a
	pop bc
;> if rows < count:
	jr nc, .marked

;>     mem[p - 1] = mem[cursor + 1] + 0xF1     # page number
	ld a, [bc]
	add $f1
	ld [hl], a
.marked
;> DrawCursorAt0A(sel, table + 2)
	pop af

;@ def DrawCursorAt0A(sel: a, table: de)
;@ path: menu/cursor
;@ Draws the cursor of entry sel & $7F of a menu cursor table (a list of
;@ tile positions) into wTilemapBuffer: a filled arrow $E9 once chosen
;@ (bit 7), else the arrow $E8 or, in the blinking-off phase, a blank $E0.
;@ test: skip draws from a table
DrawCursorAt0A::
;>@pos pos = mem16[table + 2 * (sel & 0x7F)]
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;=@pos
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;>@ps PosToScreenMap(pos)                  # result not used
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
;=@ps
	call PosToScreenMap
	pop bc
	pop de
;> if sel & 0x80:
	ld a, $e9
	bit 7, c
	jr nz, .draw

;>     tile = 0xE9
;> elif wCursorBlink & 0x10:
	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, .draw

;>     tile = 0xE0
;> else:
;>     tile = 0xE8
	ld a, $e8

.draw
;>@d mem[OffsetToTilemapBuffer(pos)] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
;=@d
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@d
	ld [hl], a
	ret


;@ def PrintServiceMessage(n: hl)
;@ path: breed/screens
;@ Prints message `n` of the open service screen: its messages are numbered
;@ from wScriptMenuText, which the script that opened the screen set.
;@ test: skip prints a message through other banks
PrintServiceMessage::
;>@m PrintMessage(wScriptMenuText + n)
	ld a, [wScriptMenuText]
	add l
	ld l, a
	ld a, [wScriptMenuText + 1]
	adc h
	ld h, a
;=@m
	call PrintMessage
	ret


;@ def PartnerBreedScreen()
;@ path: breed/partner
;@ Service screen 5, breeding with a mate the script offers (species in
;@ wScriptMenuArg): a two-entry menu, breed or quit. One step per frame,
;@ wMenuStep picks it.
;@ test: skip jumps through a table
PartnerBreedScreen::
;> PartnerBreedSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: breed/partner
;@ Steps of the partner breeding screen (RST $00 table indexed by wMenuStep).
PartnerBreedSteps::
	dw PartnerBreedInit
	dw PartnerBreedOpenMenu
	dw PartnerBreedMenuInput
	dw PartnerBreedRunChoice
	dw PartnerBreedClose

;@ def PartnerBreedInit()
;@ path: breed/partner
;@ Step 0: lines the scroll up with whole tiles, clears the menu cursors, works
;@ out the BG map address of the visible screen, restores the field's tiles in
;@ wTilemapBuffer and loads the window graphics (bank $2E entry $11).
;@ test: skip decompresses into VRAM
PartnerBreedInit::
;> RoundToTile(hScrollX)
	ld hl, hScrollX
	call RoundToTile
;> RoundToTile(hScrollY)
	ld hl, hScrollY
	call RoundToTile
;> FillMemory(wMenuChoice, 8, 0)            # the menu cursors $C8DA-$C8E1
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@map a = (hScrollY >> 3) * 32 + (hScrollX >> 3)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@map
	rrca
	rrca
	rrca
	add l
	ld l, a
;>@bg wWindowBgMap = 0x9800 | (a & 0x03FF)
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
;=@bg
	ld h, a
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DecompressVRAM(0x2E, 0x11, 0x8800)     # window graphics
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> hSpriteBGTile = 0x78
	ld a, $78
	ldh [hSpriteBGTile], a
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def PartnerBreedOpenMenu()
;@ path: breed/partner
;@ Step 1: draws the menu window and shows it.
;@ test: skip draws to VRAM
PartnerBreedOpenMenu::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawPartnerBreedMenu()
	call DrawPartnerBreedMenu
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def DrawPartnerBreedMenu()
;@ path: breed/partner
;@ Draws the two-entry menu window and the message box frame into
;@ wTilemapBuffer, with the cursor on wMenuChoice (used here as the menu
;@ cursor).
;@ test: skip draws from tables
DrawPartnerBreedMenu::
;> DrawWindowLayout0A(LayoutYesNo)
	ld de, LayoutYesNo
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice, PartnerBreedMenuCursorPos)
	ld de, PartnerBreedMenuCursorPos
	ld a, [wMenuChoice]
	call DrawCursorAt0A
	ret


;@ def PartnerBreedMenuInput()
;@ path: breed/partner
;@ Step 2: moves the menu cursor. B or Start closes the screen; A chooses
;@ (bit 7 of the cursor is set, the choice kept in wItemsHandedIn) and
;@ clears the list cursors for the chosen service.
;@ test: skip calls the cursor drawing
PartnerBreedMenuInput::
;> UpdateMenuCursor0A(wMenuChoice, PartnerBreedMenuCursorPos, 2)
	ld de, PartnerBreedMenuCursorPos
	ld hl, wMenuChoice
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x0A:                    # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .notCancel

;>     wMenuStep += 2                       # close
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
;=@ret
	jr .done

.notCancel
;> elif wJoyPressed & 0x01:                  # A
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
;>     wItemsHandedIn = wMenuChoice           # the menu entry to run
	ld a, [hl]
	ld [wItemsHandedIn], a
;>     FillMemory(wMenuChoice2, 7, 0)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     FillMemory(wListCursor, 8, 0)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr .done

.done
;>@ret return
	ret


;@ path: breed/partner
;@ Cursor positions (tile offsets row * 32 + column, $FFFF ends) of the
;@ partner breeding menu: the two entries of LayoutYesNo.
PartnerBreedMenuCursorPos::
	dw $012f, $016f, $ffff

;@ def PartnerBreedRunChoice()
;@ path: breed/partner
;@ Step 3: runs the chosen menu entry, one step per frame.
;@ test: skip jumps through a table
PartnerBreedRunChoice::
;> PartnerBreedChoices[wItemsHandedIn & 0x7F]()
	ld a, [wItemsHandedIn]
	rst $00

;@ path: breed/partner
;@ The two menu entries (RST $00 table): breed, quit.
PartnerBreedChoices::
	dw PartnerBreedFlow
	dw PartnerBreedClose

;@ def PartnerBreedClose()
;@ path: breed/partner
;@ Step 4 (and the quit entry): puts the field's tiles back, ends the service
;@ screen (wFieldFlags bit 4) and reloads the party sprites.
;@ test: skip draws to VRAM and calls another bank
PartnerBreedClose::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> hSpriteClip = 0x80
	ld a, $80
	ldh [hSpriteClip], a
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


;@ def PartnerBreedFlow()
;@ path: breed/partner
;@ The breed entry: runs its steps, one per frame, picked by wMenuSubStep.
;@ test: skip jumps through a table
PartnerBreedFlow::
;> PartnerBreedFlowSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: breed/partner
;@ Steps of the partner breeding (RST $00 table indexed by wMenuSubStep).
PartnerBreedFlowSteps::
	dw PBListMonsters
	dw PBShowList
	dw PBListInput
	dw PBAskConfirm
	dw PBOpenConfirm
	dw PBConfirmInput
	dw PBAskSave
	dw PBOpenSaveMenu
	dw PBSaveMenuInput
	dw PBShowSaveInfo
	dw PBOpenSaveConfirm
	dw PBSaveConfirmInput
	dw PBBreedAndSave
	dw PBWarpToBreeding
	dw PBOpenStatus
	dw PBReturnFromStatus
	dw PBBackToList

;@ def PBListMonsters()
;@ path: breed/partner
;@ Breed step 0: lists the monsters that can be the pedigree parent (all
;@ hatched monsters, no eggs), fetches the offered mate's name and prints
;@ the "which monster?" message.
;@ test: skip prints a message through other banks
PBListMonsters::
;> PBCountMonsters()
	call PBCountMonsters
;> PBBuildMonsterList()
	call PBBuildMonsterList
;> GetPartnerName()
	call GetPartnerName
;> PrintServiceMessage(0x0002)
	ld hl, $0002
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def PBCountMonsters()
;@ path: breed/partner
;@ Counts the 20 monster records that hold a monster (not empty, not an egg)
;@ into wListLength.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
PBCountMonsters::
;> n = 0
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for _ in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] == 0:     # a monster, and not an egg (wMonEgg)
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
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
;=@for
	ld d, a
	dec b
	jr nz, .loop

;> wListLength = n
	ld a, c
	ld [wListLength], a
	ret


;@ def PBBuildMonsterList()
;@ path: breed/partner
;@ Writes the slot numbers of those monsters (see PBCountMonsters) into the
;@ 20-byte list at wSceneObjects, $FF after the last.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
PBBuildMonsterList::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = wSceneObjects
;> rec = wMonsters
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for m in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] == 0:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr nz, .next

;>         mem[p] = m
;>         p += 1
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
;=@for
	ld d, a
	inc c
	dec b
	jr nz, .loop

	ret


;@ def PBShowList()
;@ path: breed/partner
;@ Breed step 1: once the message is out, draws the monster list.
;@ test: skip draws to VRAM
PBShowList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PBDrawCursorMonster()
	call PBDrawCursorMonster
;> PBDrawPageNames()
	call PBDrawPageNames
;> DrawPBListScreen()
	call DrawPBListScreen
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawPBListScreen()
;@ path: breed/partner
;@ Draws the whole list screen: the menu, the box with the chosen monster's
;@ level, the list window with its cursor, and shows it.
;@ test: skip draws to VRAM
DrawPBListScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawPartnerBreedMenu()
	call DrawPartnerBreedMenu
;> DrawWindowLayout0A(LayoutPartnerInfo)
	ld de, LayoutPartnerInfo
	call DrawWindowLayout0A
;> PBDrawLevel()
	call PBDrawLevel
;> DrawWindowLayout0A(LayoutPartnerList)
	ld de, LayoutPartnerList
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawListCursor(wListCursor, PBListCursorPos, 4, wListLength)
	ld de, PBListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def PBDrawPageNames()
;@ path: breed/partner
;@ Draws the names of the 4 monsters on the list page wListPage into the
;@ tiles from $8800 on (4 tiles each), which the list window shows.
;@ test: skip draws to VRAM
PBDrawPageNames::
;>@e entry = wSceneObjects + wListPage * 4
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
;> tiles = 0x8800
	ld hl, $8800
;> for _ in range(4):
;>     entry, tiles = PBDrawListEntry(entry, tiles)
	call PBDrawListEntry
	call PBDrawListEntry
	call PBDrawListEntry

;@ def PBDrawListEntry(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/partner
;@ Draws one list entry into 4 tiles at `tiles`: the monster's name; for an
;@ egg the word of text 2:$0E in 3 tiles and its family icon; for an empty
;@ entry ($FF) 4 tiles of plain colour 1. Returns the next entry and tiles.
;@ test: skip draws to VRAM
PBDrawListEntry::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> empty = m == 0xFF
	cp $ff
	jr z, .empty

;>@egg egg = not empty and mem[MonsterField(m, wMonEgg)] != 0
	push de
	ld hl, wMonEgg
	call MonsterField
	pop de
	ld a, [hl]
	or a
;=@egg
	jr nz, .egg

;>@rn if not empty and not egg:
;>     RenderNameTiles(tiles, MonsterField(m, wMonName))
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
;=@rn
	push hl
	call RenderNameTiles
	pop hl
;>@r0     return entry + 1, tiles + 0x40
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r0
	pop de
	inc de
	ret


.empty
;> elif empty:
;>@cl     for _ in range(32):
	ld b, $20
.clear
;>         WriteVRAMInc(tiles, 0xFF)
;>         WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


.egg
;> else:
;>     wTextIndex = 0x0E
	ld a, $0e
	ld [wTextIndex], a
;>     wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;>     RenderTextTiles(tiles, 1, 4)              # the word for an egg
	ld de, $0401
	pop hl
	push hl
	call RenderTextTiles
	pop hl
;>     tiles += 0x30
	ld a, l
	add $30
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>@icon     icon = FamilyIconGfx0A[mem[MonsterField(m, wMonFamily)]]
	pop de
	push de
	push hl
	ld a, [de]
	ld hl, wMonFamily
	call MonsterField
;=@icon
	ld a, [hl]
	add a
	ld hl, FamilyIconGfx0A
	add l
	ld l, a
	ld a, $00
;=@icon
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
;>     DecompressVRAM(icon & 0xFF, icon >> 8, tiles)   # into the 4th tile
	push hl
	call DecompressVRAM
	pop hl
;>@r2     return entry + 1, tiles + 0x10
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r2
	pop de
	inc de
	ret


;@ path: breed/partner
;@ Graphics of the 10 monster family icons (one tile each), as DecompressVRAM
;@ references: bank $2E, entries 3-12 (slime, dragon, beast, bird, plant,
;@ bug, devil, zombie, material, boss).
FamilyIconGfx0A::
	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

;@ def PBDrawCursorMonster()
;@ path: breed/partner
;@ Draws the name of the monster under the cursor into tiles $9780 and its
;@ gender mark ($A7 + gender) into tile $97C0.
;@ test: skip draws to VRAM
PBDrawCursorMonster::
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;>@n RenderNameTiles(0x9780, MonsterField(m, wMonName))
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, $9780
;=@n
	call RenderNameTiles
;>@g wTextArg0[0] = 0xA7 + (mem[MonsterField(m, wMonGender)] & 1)   # gender mark
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $97c0
	and $01
;=@g
	add $a7
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x97C0
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def PBDrawLevel()
;@ path: breed/partner
;@ Writes the level of the monster under the cursor into wTilemapBuffer
;@ ("Lv" tile $DE at row 11, column 1, then the digits) and a party mark $E3
;@ at column 9 when it is in the party.
;@ test: skip draws from tables
PBDrawLevel::
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;> level = mem[MonsterField(m, wMonLevel)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = OffsetToTilemapBuffer(0x0161)
	ld hl, $0161
	call OffsetToTilemapBuffer
;> mem[p] = 0xDE                         # "Lv"
	ld a, $de
	ld [hli], a
;> mem[p + 1] = 0xE0
	ld a, $e0
	ld [hli], a
;> mem[p + 2] = 0xE0
	ld a, $e0
	ld [hld], a
;> DrawTwoDigits0A(level, p + 1)
	call DrawTwoDigits0A
;> if mem[MonsterField(m, wMonsters)] == 2:          # in the party
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
;=@else
	jr nz, .notInParty

;>     mem[OffsetToTilemapBuffer(0x0169)] = 0xE3
	ld hl, $0169
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


.notInParty
;>@else else:
;>     mem[OffsetToTilemapBuffer(0x0169)] = 0xE0
	ld hl, $0169
	call OffsetToTilemapBuffer
	ld a, $e0
	ld [hl], a
	ret


;@ def PBListInput()
;@ path: breed/partner
;@ Breed step 2: the monster list. The cursor moves through the list (up and
;@ down, pages with left and right); the name, gender and level of the
;@ monster under it are redrawn when it moves, the whole page when the page
;@ changes. B goes back to the menu, A picks the monster (wCurPartyMember)
;@ and opens the confirmation window.
;@ test: skip draws to VRAM
PBListInput::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;>@u old_row = wListCursor
;> old_page = wListPage
	ld de, PBListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@u
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;>@u2 UpdateListCursor(wListCursor, PBListCursorPos, 4, wListLength)
	call UpdateListCursor
;> if wListCursor != old_row:
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, .samePos

;>     PBDrawCursorMonster()
	call PBDrawCursorMonster
;>     PBDrawLevel()
	call PBDrawLevel
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer

.samePos
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .samePage

;>     PBDrawCursorMonster()
	call PBDrawCursorMonster
;>     PBDrawPageNames()
	call PBDrawPageNames
;>     PBDrawLevel()
	call PBDrawLevel
;>     DrawPBListScreen()
	call DrawPBListScreen

.samePage
;> if wJoyPressed & 0x02:                    # B: back to the menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     GetPartnerName()
	call GetPartnerName
;>     PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;=@ret
	jr .done

.notB
;> elif wJoyPressed & 0x01:                  # A: this monster
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@m     wCurPartyMember = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ path: breed/partner
;@ Cursor table of the partner breeding monster list (tile offsets row * 32 +
;@ column): the page marker, then the 4 rows; $FFFF ends.
PBListCursorPos::
	dw $0145, $0061, $00a1, $00e1, $0121, $ffff

;@ def PBAskConfirm()
;@ path: breed/partner
;@ Breed step 3: prints the question about the picked monster (message 5).
;@ test: skip prints a message through other banks
PBAskConfirm::
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def PBOpenConfirm()
;@ path: breed/partner
;@ Breed step 4: once the message is out, opens the two-choice window.
;@ test: skip draws to VRAM
PBOpenConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> DrawPBConfirmScreen()
	call DrawPBConfirmScreen
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawPBConfirmScreen()
;@ path: breed/partner
;@ Draws the list screen with the two-choice window (view the monster's
;@ status / take it) on top, cursor on wConfirmChoice, and shows it.
;@ test: skip draws to VRAM
DrawPBConfirmScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawPartnerBreedMenu()
	call DrawPartnerBreedMenu
;> DrawWindowLayout0A(LayoutPartnerInfo)
	ld de, LayoutPartnerInfo
	call DrawWindowLayout0A
;> PBDrawLevel()
	call PBDrawLevel
;> DrawWindowLayout0A(LayoutPartnerList)
	ld de, LayoutPartnerList
	call DrawWindowLayout0A
;> DrawListCursor(wListCursor, PBListCursorPos, 4, wListLength)
	ld de, PBListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;> DrawWindowLayout0A(LayoutConfirm)
	ld de, LayoutConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wConfirmChoice, PBConfirmCursorPos)
	ld de, PBConfirmCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def PBConfirmInput()
;@ path: breed/partner
;@ Breed step 5: the two-choice window. B goes back to the list. The first
;@ choice opens the monster status screen (step 14). The second takes the
;@ monster, unless it is below level 10 (message 3) or it is the only
;@ monster in the party (message 4); then the breeding question follows.
;@ test: skip prints messages through other banks
PBConfirmInput::
;> UpdateMenuCursor0A(wConfirmChoice, PBConfirmCursorPos, 2)
	ld de, PBConfirmCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     DrawPBListScreen()
	call DrawPBListScreen
;>     GetPartnerName()
	call GetPartnerName
;>     PrintServiceMessage(0x0002)
	ld hl, $0002
	call PrintServiceMessage
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
;=@ret
	jr .done

.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wConfirmChoice != 0x81:                # first choice: the status screen
	ld a, [wConfirmChoice]
	cp $81
	jr z, .take

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep = 0x0E
	ld a, $0e
	ld [wMenuSubStep], a
;=@ret
	jr .done

.take
;> elif mem[MonsterField(wCurPartyMember, wMonLevel)] < 10:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, .levelOk

;>     PrintServiceMessage(0x0003)          # too young
	ld hl, $0003
	call PrintServiceMessage
;>     wMenuSubStep = 0x10
	ld a, $10
	ld [wMenuSubStep], a
;=@ret
	jr .done

.levelOk
;>@only elif wPartyCount not in (2, 3) and wParty[0] == wCurPartyMember:
	ld a, [wPartyCount]
	cp $02
	jr z, .ok

	cp $03
	jr z, .ok

;=@only
	ld a, [wParty]
	ld hl, wCurPartyMember
	cp [hl]
	jr nz, .ok

;>     PrintServiceMessage(0x0004)          # the only party monster
	ld hl, $0004
	call PrintServiceMessage
;>     wMenuSubStep = 0x10
	ld a, $10
	ld [wMenuSubStep], a
;=@ret
	jr .done

.ok
;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a

.done
;>@ret return
	ret


;@ path: breed/partner
;@ Cursor positions (tile offsets) of the two-choice window LayoutConfirm; $FFFF ends.
PBConfirmCursorPos::
	dw $002e, $006e, $ffff

;@ def PBAskSave()
;@ path: breed/partner
;@ Breed step 6: asks whether to breed (message 6).
;@ test: skip prints a message through other banks
PBAskSave::
;> PrintServiceMessage(0x0006)
	ld hl, $0006
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def PBOpenSaveMenu()
;@ path: breed/partner
;@ Breed step 7: once the message is out, opens a yes/no window (cursor
;@ wMenuChoice3).
;@ test: skip draws to VRAM
PBOpenSaveMenu::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout0A(LayoutYesNo)
	ld de, LayoutYesNo
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice3, PBSaveMenuCursorPos)
	ld de, PBSaveMenuCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def PBSaveMenuInput()
;@ path: breed/partner
;@ Breed step 8: yes/no. No or B goes back to the menu (message 1); yes moves
;@ on to the save question.
;@ test: skip prints messages through other banks
PBSaveMenuInput::
;> UpdateMenuCursor0A(wMenuChoice3, PBSaveMenuCursorPos, 2)
	ld de, PBSaveMenuCursorPos
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor0A
;> no = wJoyPressed & 0x02
	ld a, [wJoyPressed]
	bit 1, a
;> while True:
;>     if no:
	jr z, .notB

.no
;>         GetPartnerName()
	call GetPartnerName
;>         PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>         wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;>         return
	jr .done

.notB
;>     if not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>         return
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:              # "no" counts like B
	ld a, [wMenuChoice3]
	cp $81
;>         no = True
;>         continue
	jr z, .no

;>     break
;> wLinkRefused = 0                          # $C8DF: the next yes/no cursor
	xor a
	ld [wLinkRefused], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: breed/partner
;@ Cursor positions (tile offsets) of the yes/no window LayoutYesNo; $FFFF ends.
PBSaveMenuCursorPos::
	dw $012f, $016f, $ffff

;@ def PBShowSaveInfo()
;@ path: breed/partner
;@ Breed step 9: shows the saved game's summary (breeding saves the game)
;@ and asks whether to save (message 7).
;@ test: skip draws to VRAM
PBShowSaveInfo::
;> DrawWindowLayout0A(LayoutSaveFile)
	ld de, LayoutSaveFile
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> PBDrawSaveInfo()
	call PBDrawSaveInfo
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x0007)
	ld hl, $0007
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def PBOpenSaveConfirm()
;@ path: breed/partner
;@ Breed step 10: once the message is out, opens a yes/no window (cursor
;@ $C8DF, named wLinkRefused for its link use).
;@ test: skip draws to VRAM
PBOpenSaveConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout0A(LayoutYesNo)
	ld de, LayoutYesNo
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wLinkRefused, PBSaveConfirmCursorPos)
	ld de, PBSaveConfirmCursorPos
	ld a, [wLinkRefused]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def PBSaveConfirmInput()
;@ path: breed/partner
;@ Breed step 11: yes/no. No or B goes back to the menu; yes breeds and saves.
;@ test: skip prints messages through other banks
PBSaveConfirmInput::
;> UpdateMenuCursor0A(wLinkRefused, PBSaveConfirmCursorPos, 2)
	ld de, PBSaveConfirmCursorPos
	ld hl, wLinkRefused
	ld b, $02
	call UpdateMenuCursor0A
;> no = wJoyPressed & 0x02
	ld a, [wJoyPressed]
	bit 1, a
;> while True:
;>     if no:
	jr z, .notB

.no
;>         GetPartnerName()
	call GetPartnerName
;>         PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>         wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;>         return
	jr .done

.notB
;>     if not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>         return
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wLinkRefused == 0x81:              # "no" counts like B
	ld a, [wLinkRefused]
	cp $81
;>         no = True
;>         continue
	jr z, .no

;>     break
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: breed/partner
;@ Cursor positions (tile offsets) of the yes/no window LayoutYesNo; $FFFF ends.
PBSaveConfirmCursorPos::
	dw $012f, $016f, $ffff

;@ def PBBreedAndSave()
;@ path: breed/partner
;@ Breed step 12: the breeding itself. The picked monster's record moves to
;@ wBreedParent1 (monster slot 20) and leaves the player's monsters; the
;@ offered mate is created in wBreedParent2 (slot 21) with the opposite
;@ gender. The two pictures for the breeding scene go to wEncGfx. Then the
;@ monster list is compacted and the game is saved, with the menu and script
;@ state cleared so the save resumes on the field.
;@ test: skip calls other banks and saves the game
PBBreedAndSave::
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x0008)
	ld hl, $0008
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;> wEncGfx[0] = mem[MonsterField(wCurPartyMember, wMonRecSpecies)] + 0x10   # its picture
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx], a
;> wEncGfx[1] = 1
	ld a, $01
	ld [wEncGfx + 1], a
;> CopyMonsterRecord(MonsterField(wCurPartyMember, wMonsters), wBreedParent1)
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	call CopyMonsterRecord
;> mem[MonsterField(wCurPartyMember, wMonsters)] = 0           # it leaves
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;>@id wNewMonId = wScriptMenuArg            # the offered mate
	ld a, [wScriptMenuArg]
	ld c, a
	ld a, [wScriptMenuArg + 1]
	ld b, a
	ld a, c
	ld [wNewMonId], a
;=@id
	ld a, b
	ld [wNewMonId + 1], a
;> wNewMonSlot = 0x15                      # monster slot 21 = wBreedParent2
	ld a, $15
	ld [wNewMonSlot], a
;> CreateMonster()
	ld hl, far_CreateMonster
	rst $10
;> wBreedParent2[0x0B] = wBreedParent1[0x0B] ^ 1    # gender: opposite of the pedigree
	ld a, [wBreedParent1 + $0b]
	xor $01
	ld [wBreedParent2 + $0b], a
;> wEncGfx[2] = mem[MonsterField(0x15, wMonRecSpecies)] + 0x10
	ld a, $15
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx + 2], a
;> wEncGfx[3] = 1
	ld a, $01
	ld [wEncGfx + 3], a
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> SortPartyOrClearIcons()                 # bank 1 entry 4
	ld hl, HeaderLogo
	rst $10
;> MakeOffspring()
	ld hl, far_MakeOffspring
	rst $10
;> s0 = wFieldFlags
;> wFieldFlags = 0
	ld a, [wFieldFlags]
	push af
	xor a
	ld [wFieldFlags], a
;> s1 = wMenuStep
;> wMenuStep = 0
	ld a, [wMenuStep]
	push af
	xor a
	ld [wMenuStep], a
;> s2 = wScriptRunning
;> wScriptRunning = 0
	ld a, [wScriptRunning]
	push af
	xor a
	ld [wScriptRunning], a
;> s3 = wMenuOverlay
;> wMenuOverlay = 0
	ld a, [wMenuOverlay]
	push af
	xor a
	ld [wMenuOverlay], a
;> s4 = wStoryStep
;> wStoryStep = 0
	ld a, [wStoryStep]
	push af
	xor a
	ld [wStoryStep], a
;> SaveGame()
	di
	call SaveGame
	ei
;> wStoryStep = s4
	pop af
	ld [wStoryStep], a
;> wMenuOverlay = s3
	pop af
	ld [wMenuOverlay], a
;> wScriptRunning = s2
	pop af
	ld [wScriptRunning], a
;> wMenuStep = s1
	pop af
	ld [wMenuStep], a
;> wFieldFlags = s0
	pop af
	ld [wFieldFlags], a
	ret


;@ def PBWarpToBreeding()
;@ path: breed/partner
;@ Breed step 13: once the message is out, closes the screen and warps to
;@ map 8 at (72, 72) with wStoryStep 4, which plays the breeding scene there.
;@ test: skip starts a fade
PBWarpToBreeding::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wFieldFlags &= ~0x11
	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wWarpMap = 0x08
	ld a, $08
	ld [wWarpMap], a
;> wWarpOnGateFloor = 0
	ld a, $00
	ld [wWarpOnGateFloor], a
;> wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [wWarpX + 1], a
;> wWarpY = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> wStoryStep = 4
	ld a, $04
	ld [wStoryStep], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
	ret


;@ def PBOpenStatus()
;@ path: breed/partner
;@ Breed step 14: opens the monster status screen (bank $07) on the list,
;@ starting at the monster under the cursor; wMenuOverlay keeps it running.
;@ test: skip calls another bank
PBOpenStatus::
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


;@ def PBReturnFromStatus()
;@ path: breed/partner
;@ Breed step 15: after the status screen, puts the list cursor on the
;@ monster it showed last, reloads the window graphics and reopens the
;@ two-choice window (step 5).
;@ test: skip draws to VRAM
PBReturnFromStatus::
;>@c wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@c
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;> DecompressVRAM(0x2E, 0x11, 0x8800)     # window graphics
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
;> PBDrawCursorMonster()
	call PBDrawCursorMonster
;> PBDrawPageNames()
	call PBDrawPageNames
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> DrawPBConfirmScreen()
	call DrawPBConfirmScreen
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
	ret


;@ def PBBackToList()
;@ path: breed/partner
;@ Breed step 16: after a refusal message (too young, the only party
;@ monster), rebuilds and redraws the monster list and goes on with its input.
;@ test: skip draws to VRAM
PBBackToList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PBCountMonsters()
	call PBCountMonsters
;> PBBuildMonsterList()
	call PBBuildMonsterList
;> GetPartnerName()
	call GetPartnerName
;> PrintServiceMessage(0x0002)
	ld hl, $0002
	call PrintServiceMessage
;> DrawPBListScreen()
	call DrawPBListScreen
;> wMenuSubStep = 1
	ld a, $01
	ld [wMenuSubStep], a
	ret


;@ def PBDrawSaveInfo()
;@ path: breed/partner
;@ Draws the saved game's summary into the save window.
;@ test: skip reads cartridge RAM and draws to VRAM
PBDrawSaveInfo::
;> DrawSaveFileInfo()
	call DrawSaveFileInfo
	ret


;@ def GetPartnerName()
;@ path: breed/partner
;@ Copies the species name of the offered mate (wScriptMenuArg) into
;@ wTextArg0 for the messages.
;@ test: skip calls another bank
GetPartnerName::
;>@id wNewMonId = wScriptMenuArg
	ld a, [wScriptMenuArg]
	ld c, a
	ld a, [wScriptMenuArg + 1]
	ld b, a
	ld a, c
	ld [wNewMonId], a
;=@id
	ld a, b
	ld [wNewMonId + 1], a
;> LoadMonTemplate()
	ld hl, far_LoadMonTemplate
	rst $10
;> CopySystemText(0x0500 | wNewMonNameText, wTextArg0)
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ret


;@ def BreedingScreen()
;@ path: breed/house
;@ Service screen 6, the breeding house: a menu with breed, hatch an egg and
;@ quit, the player's gold shown above it. One step per frame, picked by
;@ wMenuStep.
;@ test: skip jumps through a table
BreedingScreen::
;> BreedingSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: breed/house
;@ Steps of the breeding house screen (RST $00 table indexed by wMenuStep).
BreedingSteps::
	dw BreedingInit
	dw BreedingOpenMenu
	dw BreedingMenuInput
	dw BreedingRunChoice
	dw BreedingClose

;@ def BreedingInit()
;@ path: breed/house
;@ Step 0: lines the scroll up with whole tiles, clears the menu cursors,
;@ works out the BG map address of the visible screen, shows the field with
;@ the message box frame, loads the window graphics (bank $2E entry $12)
;@ and draws text 2:$10 (8 letters) into the tiles at $9400.
;@ test: skip decompresses into VRAM
BreedingInit::
;> RoundToTile(hScrollX)
	ld hl, hScrollX
	call RoundToTile
;> RoundToTile(hScrollY)
	ld hl, hScrollY
	call RoundToTile
;> FillMemory(wMenuChoice, 8, 0)            # the menu cursors $C8DA-$C8E1
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@map a = (hScrollY >> 3) * 32 + (hScrollX >> 3)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@map
	rrca
	rrca
	rrca
	add l
	ld l, a
;>@bg wWindowBgMap = 0x9800 | (a & 0x03FF)
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
;=@bg
	ld h, a
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> DecompressVRAM(0x2E, 0x12, 0x8800)     # window graphics
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x10
	ld a, $10
	ld [wTextIndex], a
;> RenderTextTiles(0x9400, 1, 8)
	ld hl, $9400
	ld de, $0801
	call RenderTextTiles
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> hSpriteBGTile = 0x40
	ld a, $40
	ldh [hSpriteBGTile], a
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def BreedingOpenMenu()
;@ path: breed/house
;@ Step 1: draws the menu and shows it.
;@ test: skip draws to VRAM
BreedingOpenMenu::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawBreedingMenu()
	call DrawBreedingMenu
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def DrawBreedingMenu()
;@ path: breed/house
;@ Draws the gold window with the player's gold (row 1, column 14), the
;@ three-entry menu and the message box frame into wTilemapBuffer, cursor on
;@ wMenuChoice (used here as the menu cursor).
;@ test: skip draws from tables
DrawBreedingMenu::
;> DrawWindowLayout0A(LayoutGold)
	ld de, LayoutGold
	call DrawWindowLayout0A
;>@g hNumber = wGold                      # 24 bits
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(OffsetToTilemapBuffer(0x002E))
	ld hl, $002e
	call OffsetToTilemapBuffer
	call PrintNumber5
;> DrawWindowLayout0A(LayoutBreedingMenu)
	ld de, LayoutBreedingMenu
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice, BreedingMenuCursorPos)
	ld de, BreedingMenuCursorPos
	ld a, [wMenuChoice]
	call DrawCursorAt0A
	ret


;@ def BreedingMenuInput()
;@ path: breed/house
;@ Step 2: moves the menu cursor. B or Start closes the screen; A chooses
;@ (bit 7 of the cursor is set, the choice kept in wItemsHandedIn) and
;@ clears the list cursors for the chosen service.
;@ test: skip calls the cursor drawing
BreedingMenuInput::
;> UpdateMenuCursor0A(wMenuChoice, BreedingMenuCursorPos, 3)
	ld de, BreedingMenuCursorPos
	ld hl, wMenuChoice
	ld b, $03
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x0A:                    # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .notCancel

;>     BreedingCloseAfterText()
;>     return
	jr BreedingCloseAfterText

.notCancel
;> if wJoyPressed & 0x01:                    # A
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
;>     wItemsHandedIn = wMenuChoice           # the menu entry to run
	ld a, [hl]
	ld [wItemsHandedIn], a
;>     FillMemory(wMenuChoice2, 7, 0)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     FillMemory(wListCursor, 8, 0)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr .done

.done
	ret


;@ path: breed/house
;@ Cursor positions (tile offsets row * 32 + column, $FFFF ends) of the
;@ breeding house menu: breed, hatch, quit.
BreedingMenuCursorPos::
	dw $0021, $0061, $00a1, $ffff

;@ def BreedingRunChoice()
;@ path: breed/house
;@ Step 3: runs the chosen menu entry, one step per frame.
;@ test: skip jumps through a table
BreedingRunChoice::
;> BreedingChoices[wItemsHandedIn & 0x7F]()
	ld a, [wItemsHandedIn]
	rst $00

;@ path: breed/house
;@ The three menu entries (RST $00 table): breed two monsters, hatch an egg, quit.
BreedingChoices::
	dw BreedFlow
	dw HatchFlow
	dw BreedingCloseAfterText

;@ def BreedingCloseAfterText()
;@ path: breed/house
;@ The quit entry (and B): waits for the message to finish, then closes.
;@ test: skip draws to VRAM and calls another bank
BreedingCloseAfterText::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> BreedingClose()

;@ def BreedingClose()
;@ path: breed/house
;@ Step 4: puts the field's tiles back, ends the service screen (wFieldFlags
;@ bit 4) and reloads the party sprites.
;@ test: skip draws to VRAM and calls another bank
BreedingClose::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> hSpriteClip = 0x80
	ld a, $80
	ldh [hSpriteClip], a
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


;@ def BreedFlow()
;@ path: breed/house
;@ The breed entry: runs its steps, one per frame, picked by wMenuSubStep.
;@ test: skip jumps through a table
BreedFlow::
;> BreedFlowSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: breed/house
;@ Steps of breeding two of the player's monsters (RST $00 table indexed by
;@ wMenuSubStep): pick the pedigree parent, pick the mate, see the offspring,
;@ save, breed.
BreedFlowSteps::
	dw BRListMonsters
	dw BRShowList
	dw BRPedigreeInput
	dw BRAskPedigree
	dw BROpenPedigreeConfirm
	dw BRPedigreeConfirmInput
	dw BRListMates
	dw BRShowMates
	dw BRMateInput
	dw BRAskMate
	dw BROpenMateConfirm
	dw BRMateConfirmInput
	dw BRPredictOffspring
	dw BRWaitPrediction
	dw BRResetSaveCursor
	dw BRShowSaveInfo
	dw BROpenSaveConfirm
	dw BRSaveConfirmInput
	dw BRBreedAndSave
	dw BRWarpToBreeding
	dw BROpenPedigreeStatus
	dw BRReturnFromPedigreeStatus
	dw BRBackToList
	dw BROpenMateStatus
	dw BRReturnFromMateStatus
	dw BRBackToMates

;@ def BRListMonsters()
;@ path: breed/house
;@ Breed step 0: lists the monsters that can breed (all hatched monsters, no
;@ eggs) and asks for the pedigree parent (message 3).
;@ test: skip prints a message through other banks
BRListMonsters::
;> BRCountMonsters()
	call BRCountMonsters
;> BRBuildMonsterList()
	call BRBuildMonsterList
;> PrintServiceMessage(0x0003)
	ld hl, $0003
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BRCountMonsters()
;@ path: breed/house
;@ Counts the 20 monster records that hold a monster (not empty, not an egg)
;@ into wListLength.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
BRCountMonsters::
;> n = 0
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for _ in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] == 0:     # a monster, and not an egg (wMonEgg)
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
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
;=@for
	ld d, a
	dec b
	jr nz, .loop

;> wListLength = n
	ld a, c
	ld [wListLength], a
	ret


;@ def BRBuildMonsterList()
;@ path: breed/house
;@ Writes the slot numbers of those monsters (see BRCountMonsters) into the
;@ 20-byte list at wSceneObjects, $FF after the last.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
BRBuildMonsterList::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = wSceneObjects
;> rec = wMonsters
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for m in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] == 0:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr nz, .next

;>         mem[p] = m
;>         p += 1
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
;=@for
	ld d, a
	inc c
	dec b
	jr nz, .loop

	ret


;@ def BRShowList()
;@ path: breed/house
;@ Breed step 1: once the message is out, draws the monster list.
;@ test: skip draws to VRAM
BRShowList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> BRClearInfo()
	call BRClearInfo
;> BRDrawPageNames()
	call BRDrawPageNames
;> DrawBRListScreen()
	call DrawBRListScreen
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawBRListScreen()
;@ path: breed/house
;@ Draws the breeding list screen: the menu with the gold, the list window,
;@ the pair window with the level of the monster under the cursor, and the
;@ list cursor; then shows it.
;@ test: skip draws to VRAM
DrawBRListScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawBreedingMenu()
	call DrawBreedingMenu
;> DrawWindowLayout0A(LayoutMonsterList)
	ld de, LayoutMonsterList
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;> BRDrawLevel()
	call BRDrawLevel
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawListCursor(wListCursor, BRListCursorPos, 4, wListLength)
	ld de, BRListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def BRDrawPageNames()
;@ path: breed/house
;@ Draws the names of the 4 monsters on the list page wListPage into the
;@ tiles from $9610 on (4 tiles each).
;@ test: skip draws to VRAM
BRDrawPageNames::
;>@e entry = wSceneObjects + wListPage * 4
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
;> tiles = 0x9610
	ld hl, $9610
;> for _ in range(4):
;>     entry, tiles = DrawNameEntry(entry, tiles)
	call DrawNameEntry
	call DrawNameEntry
	call DrawNameEntry

;@ def DrawNameEntry(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/house
;@ Draws the name of list entry `entry` into 4 tiles at `tiles` (4 tiles of
;@ plain colour 1 for an empty entry, $FF). Returns the next entry and tiles.
;@ test: skip draws to VRAM
DrawNameEntry::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>@rn     RenderNameTiles(tiles, MonsterField(m, wMonName))
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
;=@rn
	push hl
	call RenderNameTiles
	pop hl
;>@r0     return entry + 1, tiles + 0x40
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r0
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(32):
	ld b, $20
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def BRClearInfo()
;@ path: breed/house
;@ Draws the name and gender of the monster under the cursor (BRDrawCursorMonster)
;@ and blanks the 5 tiles from $9760 on (where the mate is shown later).
;@ test: skip draws to VRAM
BRClearInfo::
;> BRDrawCursorMonster()
	call BRDrawCursorMonster
;> tiles = 0x9760
	ld hl, $9760
;>@cl for _ in range(40):
	ld b, $28
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

	ret


;@ def BRDrawCursorMonster()
;@ path: breed/house
;@ Draws the name of the monster under the list cursor into tiles $9710 and
;@ its gender mark into tile $9750.
;@ test: skip draws to VRAM
BRDrawCursorMonster::
;>@m entry = wSceneObjects + wListPage * 4 + (wListCursor & 0x7F); m = mem[entry]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
;=@m
	ld d, a
	ld a, [de]
;> DrawNameEntry(entry, 0x9710)
	push af
	ld hl, $9710
	call DrawNameEntry
;>@k1 DrawGenderTile(mem[MonsterField(m, wMonGender)], 0x9750)
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9750
	call DrawGenderTile
;=@k1
	ret


;@ def DrawGenderTile(gender: a, tiles: hl)
;@ path: breed/house
;@ Draws the gender mark of `gender` (bit 0: $A7 or $A8) into the letter tile
;@ at VRAM `tiles`.
;@ test: skip calls a routine in another bank
DrawGenderTile::
;> wTextArg0[0] = 0xA7 + (gender & 1)
	and $01
	add $a7
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def BRDrawLevel()
;@ path: breed/house
;@ Writes the level of the monster under the list cursor into wTilemapBuffer
;@ ("Lv" tile $DE at row 9, column 10, then the digits) and a party mark $E3
;@ at column 18 when it is in the party.
;@ test: skip draws from tables
BRDrawLevel::
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
;=@m
	ld d, a
	ld a, [de]
;> level = mem[MonsterField(m, wMonLevel)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = OffsetToTilemapBuffer(0x012A)
	ld hl, $012a
	call OffsetToTilemapBuffer
;> mem[p] = 0xDE                         # "Lv"
	ld a, $de
	ld [hli], a
;> DrawTwoDigits0A(level, p + 1)
	call DrawTwoDigits0A
;> if mem[MonsterField(m, wMonsters)] != 2:          # not in the party
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
;>     return
	ret nz

;> mem[OffsetToTilemapBuffer(0x0132)] = 0xE3
	ld hl, $0132
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


;@ def BRPedigreeInput()
;@ path: breed/house
;@ Breed step 2: the list for the pedigree parent. The cursor moves through
;@ the list; the info of the monster under it is redrawn when it moves, the
;@ page when the page changes. B goes back to the menu, A picks the monster
;@ (wCurPartyMember, and wListKnown keeps it as the pedigree slot).
;@ test: skip draws to VRAM
BRPedigreeInput::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;>@u old_row = wListCursor
;> old_page = wListPage
	ld de, BRListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@u
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdateListCursor(wListCursor, BRListCursorPos, 4, wListLength)
	call UpdateListCursor
;>@r if wListCursor & 0x7F != old_row & 0x7F:
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@r
	cp b
	jr z, .samePos

;>     BRClearInfo()
	call BRClearInfo
;>     DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;>     BRDrawLevel()
	call BRDrawLevel
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer

.samePos
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .samePage

;>     BRClearInfo()
	call BRClearInfo
;>     BRDrawPageNames()
	call BRDrawPageNames
;>     DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;>     BRDrawLevel()
	call BRDrawLevel
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer

.samePage
;> if wJoyPressed & 0x02:                    # B: back to the menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;=@ret
	jr Jump_00a_4fa7

.notB
;> elif wJoyPressed & 0x01:                  # A: this monster
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4fa7

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@m     m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;>     wCurPartyMember = m
	ld [wCurPartyMember], a
;>     wListKnown = m                       # the pedigree parent
	ld [wListKnown], a
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_4fa7:
;>@ret return
	ret


;@ path: breed/house
;@ Cursor positions for the breeding monster list, as tilemap offsets
;@ (row * 32 + column) ending with $FFFF. The first entry is where the page
;@ marker sits; the other four are the rows of the list.
BRListCursorPos::
	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

;@ def BRAskPedigree()
;@ path: breed/house
;@ Breed step 3: prints the question about the picked monster (message 5).
;@ test: skip prints a message through other banks
BRAskPedigree::
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BROpenPedigreeConfirm()
;@ path: breed/house
;@ Breed step 4: once the message is out, opens the two-choice window.
;@ test: skip draws to VRAM
BROpenPedigreeConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> DrawBRPedigreeConfirm()
	call DrawBRPedigreeConfirm
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawBRPedigreeConfirm()
;@ path: breed/house
;@ Draws the list screen with the two-choice window (view the status / take
;@ it) on top, cursor on wConfirmChoice, and shows it.
;@ test: skip draws to VRAM
DrawBRPedigreeConfirm::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawBreedingMenu()
	call DrawBreedingMenu
;> DrawWindowLayout0A(LayoutMonsterList)
	ld de, LayoutMonsterList
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;> BRDrawLevel()
	call BRDrawLevel
;> DrawListCursor(wListCursor, BRListCursorPos, 4, wListLength)
	ld de, BRListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;> DrawWindowLayout0A(LayoutConfirm)
	ld de, LayoutConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wConfirmChoice, BRPedigreeConfirmCursorPos)
	ld de, BRPedigreeConfirmCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def BRPedigreeConfirmInput()
;@ path: breed/house
;@ Breed step 5: the two-choice window. B goes back to the list. The first
;@ choice opens the status screen (step 20). The second takes the monster as
;@ pedigree parent unless it is below level 10 (message 7) or the only
;@ monster in the party (message 6); then the mate list follows.
;@ test: skip prints messages through other banks
BRPedigreeConfirmInput::
;> UpdateMenuCursor0A(wConfirmChoice, BRPedigreeConfirmCursorPos, 2)
	ld de, BRPedigreeConfirmCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     DrawBRListScreen()
	call DrawBRListScreen
;>     PrintServiceMessage(0x0003)
	ld hl, $0003
	call PrintServiceMessage
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
;=@ret
	jr .done

.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wConfirmChoice != 0x81:                # first choice: the status screen
	ld a, [wConfirmChoice]
	cp $81
	jr z, .take

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep = 0x14
	ld a, $14
	ld [wMenuSubStep], a
;=@ret
	jr .done

.take
;> elif mem[MonsterField(wCurPartyMember, wMonLevel)] < 10:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, .levelOk

;>     PrintServiceMessage(0x0007)          # too young
	ld hl, $0007
	call PrintServiceMessage
;>     wMenuSubStep = 0x16
	ld a, $16
	ld [wMenuSubStep], a
;=@ret
	jr .done

.levelOk
;>@only elif wPartyCount not in (2, 3) and wParty[0] == wCurPartyMember:
	ld a, [wPartyCount]
	cp $02
	jr z, .ok

	cp $03
	jr z, .ok

;=@only
	ld a, [wParty]
	ld hl, wCurPartyMember
	cp [hl]
	jr nz, .ok

;>     PrintServiceMessage(0x0006)          # the only party monster
	ld hl, $0006
	call PrintServiceMessage
;>     wMenuSubStep = 0x16
	ld a, $16
	ld [wMenuSubStep], a
;=@ret
	jr .done

.ok
;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a

.done
;>@ret return
	ret


;@ path: breed/house
;@ Cursor positions (tile offsets) of the two-choice window LayoutConfirm; $FFFF ends.
BRPedigreeConfirmCursorPos::
	dw $002e, $006e, $ffff

;@ def BRListMates()
;@ path: breed/house
;@ Breed step 6: lists the possible mates (every other hatched monster) and
;@ asks for one (message 4).
;@ test: skip prints a message through other banks
BRListMates::
;> BRCountMates()
	call BRCountMates
;> BRBuildMateList()
	call BRBuildMateList
;> PrintServiceMessage(0x0004)
	ld hl, $0004
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BRCountMates()
;@ path: breed/house
;@ Counts the monster records that hold a hatched monster other than the
;@ pedigree parent (wListKnown) into wListLength.
;@ test: for i in range(20): wListKnown = rand(0, 19); mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
BRCountMates::
;> n = 0
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00
	ld h, $00
.loop
;>@for for m in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] == 0 and m != wListKnown:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr nz, .next

;=@if
	ld a, [wListKnown]
	cp h
	jr z, .next

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
;=@for
	ld d, a
	inc h
	dec b
	jr nz, .loop

;> wListLength = n
	ld a, c
	ld [wListLength], a
	ret


;@ def BRBuildMateList()
;@ path: breed/house
;@ Writes the slot numbers of the possible mates (see BRCountMates) into the
;@ 20-byte list at wSceneObjects, $FF after the last.
;@ test: for i in range(20): wListKnown = rand(0, 19); mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
BRBuildMateList::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = wSceneObjects
;> rec = wMonsters
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for m in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] == 0 and m != wListKnown:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr nz, .next

;=@if
	ld a, [wListKnown]
	cp c
	jr z, .next

;>         mem[p] = m
;>         p += 1
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
;=@for
	ld d, a
	inc c
	dec b
	jr nz, .loop

	ret


;@ def BRShowMates()
;@ path: breed/house
;@ Breed step 7: once the message is out, draws the mate list.
;@ test: skip draws to VRAM
BRShowMates::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> BRDrawPair()
	call BRDrawPair
;> BRDrawMatePage()
	call BRDrawMatePage
;> DrawBRMateScreen()
	call DrawBRMateScreen
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawBRMateScreen()
;@ path: breed/house
;@ Draws the mate list screen: the menu with the gold, the mate list window,
;@ the pair window with both levels and the list cursor (wListCursor2); then
;@ shows it.
;@ test: skip draws to VRAM
DrawBRMateScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawBreedingMenu()
	call DrawBreedingMenu
;> DrawWindowLayout0A(LayoutMateList)
	ld de, LayoutMateList
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;> BRDrawPairLevels()
	call BRDrawPairLevels
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawListCursor(wListCursor2, BRMateCursorPos, 4, wListLength)
	ld de, BRMateCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor2
	call DrawListCursor
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def BRDrawMatePage()
;@ path: breed/house
;@ Draws the names of the 4 mates on page wListPage2 into the tiles from
;@ $9610 on (4 tiles each).
;@ test: skip draws to VRAM
BRDrawMatePage::
;>@e entry = wSceneObjects + wListPage2 * 4
	ld a, [wListPage2]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@e
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9610
	ld hl, $9610
;> for _ in range(4):
;>     entry, tiles = DrawNameEntry(entry, tiles)
	call DrawNameEntry
	call DrawNameEntry
	call DrawNameEntry
	call DrawNameEntry
	ret


;@ def BRDrawPair()
;@ path: breed/house
;@ Draws the pedigree parent (wListKnown) into tiles $9710 (name) and $9750
;@ (gender), then the mate under the cursor (BRDrawMateCursor).
;@ test: skip draws to VRAM
BRDrawPair::
;> DrawNameEntry(addr(wListKnown), 0x9710)
	ld de, wListKnown
	ld a, [de]
	push af
	ld hl, $9710
	call DrawNameEntry
;> DrawGenderTile(mem[MonsterField(wListKnown, wMonGender)], 0x9750)
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9750
	call DrawGenderTile
;> BRDrawMateCursor()

;@ def BRDrawMateCursor()
;@ path: breed/house
;@ Draws the mate under the list cursor into tiles $9760 (name) and $97A0
;@ (gender).
;@ test: skip draws to VRAM
BRDrawMateCursor::
;>@m entry = wSceneObjects + wListPage2 * 4 + (wListCursor2 & 0x7F); m = mem[entry]
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
	and $7f
;=@m
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
;=@m
	ld d, a
	ld a, [de]
;> DrawNameEntry(entry, 0x9760)
	push af
	ld hl, $9760
	call DrawNameEntry
;>@k2 DrawGenderTile(mem[MonsterField(m, wMonGender)], 0x97A0)
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $97a0
	call DrawGenderTile
;=@k2
	ret


;@ def BRDrawPairLevels()
;@ path: breed/house
;@ Writes the levels of the pedigree parent (row 9, column 10) and of the
;@ mate under the cursor (row 11, column 10) into wTilemapBuffer, each "Lv"
;@ ($DE) and digits, with the party mark $E3 eight columns on when that
;@ monster is in the party.
;@ test: skip draws from tables
BRDrawPairLevels::
;> m = wListKnown
	ld de, wListKnown
	ld a, [de]
;> level = mem[MonsterField(m, wMonLevel)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = OffsetToTilemapBuffer(0x012A)
	ld hl, $012a
	call OffsetToTilemapBuffer
;> mem[p] = 0xDE                         # "Lv"
	ld a, $de
	ld [hli], a
;> DrawTwoDigits0A(level, p + 1)
	call DrawTwoDigits0A
;> if mem[MonsterField(m, wMonsters)] == 2:          # in the party
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, .mate

;>     mem[OffsetToTilemapBuffer(0x0132)] = 0xE3
	ld hl, $0132
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a

.mate
;>@m m = wSceneObjects[wListPage2 * 4 + (wListCursor2 & 0x7F)]
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
	and $7f
;=@m
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
;=@m
	ld d, a
	ld a, [de]
;> level = mem[MonsterField(m, wMonLevel)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = OffsetToTilemapBuffer(0x016A)
	ld hl, $016a
	call OffsetToTilemapBuffer
;> mem[p] = 0xDE
	ld a, $de
	ld [hli], a
;> DrawTwoDigits0A(level, p + 1)
	call DrawTwoDigits0A
;> if mem[MonsterField(m, wMonsters)] != 2:
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
;>     return
	ret nz

;> mem[OffsetToTilemapBuffer(0x0172)] = 0xE3
	ld hl, $0172
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


;@ def BRMateInput()
;@ path: breed/house
;@ Breed step 8: the mate list (cursor wListCursor2, page wListPage2). The
;@ mate's info is redrawn when the cursor moves, the page when it changes.
;@ B goes back to the pedigree list (step 0), A picks the mate
;@ (wCurPartyMember).
;@ test: skip draws to VRAM
BRMateInput::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;>@u old_row = wListCursor2
;> old_page = wListPage2
	ld de, BRMateCursorPos
	ld hl, wListCursor2
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@u
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdateListCursor(wListCursor2, BRMateCursorPos, 4, wListLength)
	call UpdateListCursor
;>@r if wListCursor2 & 0x7F != old_row & 0x7F:
	pop af
	ld hl, wListCursor2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@r
	cp b
	jr z, .samePos

;>     BRDrawMateCursor()
	call BRDrawMateCursor
;>     DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;>     BRDrawPairLevels()
	call BRDrawPairLevels
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer

.samePos
;> if wListPage2 != old_page:
	pop af
	ld hl, wListPage2
	cp [hl]
	jr z, .samePage

;>     BRDrawMateCursor()
	call BRDrawMateCursor
;>     BRDrawMatePage()
	call BRDrawMatePage
;>     DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;>     BRDrawPairLevels()
	call BRDrawPairLevels
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer

.samePage
;> if wJoyPressed & 0x02:                    # B: back to the pedigree list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintServiceMessage(0x0003)
	ld hl, $0003
	call PrintServiceMessage
;>@back     wMenuSubStep -= 8
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@back
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@back
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
;=@ret
	jr .done

.notB
;> elif wJoyPressed & 0x01:                  # A: this mate
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4fa7                     ; (a plain ret in BRPedigreeInput)

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@m     wCurPartyMember = wSceneObjects[wListPage2 * 4 + (wListCursor2 & 0x7F)]
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ path: breed/house
;@ Cursor table of the mate list (tile offsets row * 32 + column): the page
;@ marker, then the 4 rows; $FFFF ends.
BRMateCursorPos::
	dw $0185, $00a1, $00e1, $0121, $0161, $ffff

;@ def BRAskMate()
;@ path: breed/house
;@ Breed step 9: prints the question about the picked mate (message 5).
;@ test: skip prints a message through other banks
BRAskMate::
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BROpenMateConfirm()
;@ path: breed/house
;@ Breed step 10: once the message is out, opens the two-choice window.
;@ test: skip draws to VRAM
BROpenMateConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> DrawBRMateConfirm()
	call DrawBRMateConfirm
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawBRMateConfirm()
;@ path: breed/house
;@ Draws the mate list screen with the two-choice window (view the status /
;@ take it) on top, cursor on wConfirmChoice2, and shows it.
;@ test: skip draws to VRAM
DrawBRMateConfirm::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawBreedingMenu()
	call DrawBreedingMenu
;> DrawWindowLayout0A(LayoutMateList)
	ld de, LayoutMateList
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;> BRDrawPairLevels()
	call BRDrawPairLevels
;> DrawListCursor(wListCursor2, BRMateCursorPos, 4, wListLength)
	ld de, BRMateCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor2
	call DrawListCursor
;> DrawWindowLayout0A(LayoutConfirm)
	ld de, LayoutConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wConfirmChoice2, BRMateConfirmCursorPos)
	ld de, BRMateConfirmCursorPos
	ld a, [wConfirmChoice2]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def BRMateConfirmInput()
;@ path: breed/house
;@ Breed step 11: the two-choice window for the mate. B goes back to the mate
;@ list. The first choice opens the status screen (step 23). The second takes
;@ the mate unless it is below level 10 (message 7), the pair would leave
;@ the party empty (message 6), or both have the same gender (message 8);
;@ then the offspring is worked out.
;@ test: skip prints messages through other banks
BRMateConfirmInput::
;> UpdateMenuCursor0A(wConfirmChoice2, BRMateConfirmCursorPos, 2)
	ld de, BRMateConfirmCursorPos
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the mate list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     DrawBRMateScreen()
	call DrawBRMateScreen
;>     PrintServiceMessage(0x0004)
	ld hl, $0004
	call PrintServiceMessage
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
;=@ret
	jp .done


.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wConfirmChoice2 != 0x81:               # first choice: the status screen
	ld a, [wConfirmChoice2]
	cp $81
	jr z, .take

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep = 0x17
	ld a, $17
	ld [wMenuSubStep], a
;=@ret
	jp .done


.take
;> elif mem[MonsterField(wCurPartyMember, wMonLevel)] < 10:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, .levelOk

;>     PrintServiceMessage(0x0007)          # too young
	ld hl, $0007
	call PrintServiceMessage
;>     wMenuSubStep = 0x19
	ld a, $19
	ld [wMenuSubStep], a
;=@ret
	jr .done

.levelOk
;>@p elif wPartyCount != 3 and ((wPartyCount == 2 and mem[MonsterField(wListKnown, wMonsters)] == 2 and mem[MonsterField(wCurPartyMember, wMonsters)] == 2) or (wPartyCount != 2 and wParty[0] in (wListKnown, wCurPartyMember))):
	ld a, [wPartyCount]
	cp $03
	jr z, .partyOk

	cp $02
	jr nz, .oneInParty

;=@p
	ld a, [wListKnown]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, .partyOk

;=@p
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, .partyOk

;=@p
	jr .partyEmpty

.oneInParty
;=@p
	ld a, [wParty]
	ld hl, wListKnown
	cp [hl]
	jr z, .partyEmpty

;=@p
	ld a, [wParty]
	ld hl, wCurPartyMember
	cp [hl]
	jr nz, .partyOk

.partyEmpty
;>     PrintServiceMessage(0x0006)          # the party would be left empty
	ld hl, $0006
	call PrintServiceMessage
;>     wMenuSubStep = 0x19
	ld a, $19
	ld [wMenuSubStep], a
;=@ret
	jr .done

.partyOk
;>@g elif mem[MonsterField(wListKnown, wMonGender)] & 1 == mem[MonsterField(wCurPartyMember, wMonGender)] & 1:
	ld a, [wListKnown]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	and $01
	push af
;=@g
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	pop af
	ld b, a
	ld a, [hl]
;=@g
	and $01
	cp b
	jr nz, .gendersOk

;>     PrintServiceMessage(0x0008)          # same gender
	ld hl, $0008
	call PrintServiceMessage
;>     wMenuSubStep = 0x19
	ld a, $19
	ld [wMenuSubStep], a
;=@ret
	jr .done

.gendersOk
;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ path: breed/house
;@ Cursor positions (tile offsets) of the two-choice window LayoutConfirm; $FFFF ends.
BRMateConfirmCursorPos::
	dw $002e, $006e, $ffff

;@ def BRPredictOffspring()
;@ path: breed/house
;@ Breed step 12: puts both names into wTextArg0 / wTextArg1 and lets bank
;@ $16 work out the offspring of the pair (wBreedPair, plus value
;@ wOffspringPlus). The breeder then names it with its plus value
;@ (wTextArg2): message 9 when the library already has the species, message
;@ $1C when it has not but BreedableFlags allows naming it, else message $0A
;@ without a name.
;@ test: skip calls another bank and prints messages
BRPredictOffspring::
;>@n1 CopyName(MonsterField(wListKnown, wMonName), wTextArg0)
	ld a, [wListKnown]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@n1
	call CopyName
;>@n2 CopyName(MonsterField(wCurPartyMember, wMonName), wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@n2
	call CopyName
;> wBreedQuery = mem[MonsterField(wListKnown, wMonRecSpecies)]
	ld a, [wListKnown]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wBreedQuery], a
;> wBreedSpecies2 = mem[MonsterField(wCurPartyMember, wMonRecSpecies)]
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wBreedSpecies2], a
;> wBreedSlot1 = wListKnown & 0x7F
	ld a, [wListKnown]
	and $7f
	ld [wBreedSlot1], a
;> wBreedSlot2 = wCurPartyMember & 0x7F
	ld a, [wCurPartyMember]
	and $7f
	ld [wBreedSlot2], a
;> BreedResultPreview()                          # works out the offspring
	ld hl, far_BreedResultPreview
	rst $10
;> known = TestFlag(wBreedPair[0], wLibraryFlags)
	ld a, [wBreedPair]
	ld hl, wLibraryFlags
	call TestFlag
;>@nm if known or BreedableFlags[wBreedPair[0]]:
	jr nz, .name

	ld a, [wBreedPair]
	ld hl, BreedableFlags
	add l
	ld l, a
	ld a, $00
;=@nm
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, .unknown

.name
;>@cs     CopySystemText(0x0500 | wBreedPair[0], wTextArg2)    # the species name
	ld a, [wBreedPair]
	ld l, a
	ld h, $05
	ld de, wTextArg2
	call CopySystemText
;>     AppendPlusValue(wOffspringPlus, wTextArg2)
	ld a, [wOffspringPlus]
	ld de, wTextArg2
	call AppendPlusValue
;>     if TestFlag(wBreedPair[0], wLibraryFlags):
	ld a, [wBreedPair]
	ld hl, wLibraryFlags
	call TestFlag
	jr z, .notInLibrary

;>         msg = 0x0009
	ld hl, $0009
;=@pm
	jr .print

.unknown
;>     else:
;>@m1c         msg = 0x001C
;> else:
;>     msg = 0x000A
	ld hl, $000a
;=@pm
	jr .print

.notInLibrary
;=@m1c
	ld hl, $001c
;=@pm
	jr .print

.print
;>@pm PrintServiceMessage(msg)
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ path: breed/house
;@ One byte per offspring species (256): 1 if the breeder names the offspring
;@ even when the monster library has no entry for it yet, 0 if the result is
;@ kept secret until then.
BreedableFlags::
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $00, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $01, $00, $01, $00, $00, $01
	db $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01

;@ def BRWaitPrediction()
;@ path: breed/house
;@ Breed step 13: waits for the message to finish.
;@ test: wTextState = rand(0, 1)
BRWaitPrediction::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BRResetSaveCursor()
;@ path: breed/house
;@ Breed step 14: clears the yes/no cursor of the save question ($C8DF).
BRResetSaveCursor::
;> wLinkRefused = 0
	xor a
	ld [wLinkRefused], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ path: unused
;@ Unused cursor table (two yes/no rows at row 9 and 11, column 1).
BRUnusedCursorPos::
	dw $0121, $0161, $ffff

;@ def BRShowSaveInfo()
;@ path: breed/house
;@ Breed step 15: shows the saved game's summary (breeding saves the game)
;@ and asks whether to save (message $0B).
;@ test: skip draws to VRAM
BRShowSaveInfo::
;> DrawWindowLayout0A(LayoutSaveFile)
	ld de, LayoutSaveFile
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> DrawSaveFileInfo()
	call DrawSaveFileInfo
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x000B)
	ld hl, $000b
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BROpenSaveConfirm()
;@ path: breed/house
;@ Breed step 16: once the message is out, opens a yes/no window at the left
;@ (cursor $C8DF, named wLinkRefused for its link use).
;@ test: skip draws to VRAM
BROpenSaveConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawWindowLayout0A(LayoutYesNoLeft)
	ld de, LayoutYesNoLeft
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wLinkRefused, BRSaveConfirmCursorPos)
	ld de, BRSaveConfirmCursorPos
	ld a, [wLinkRefused]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def BRSaveConfirmInput()
;@ path: breed/house
;@ Breed step 17: yes/no. No or B goes back to the menu (message 1); yes
;@ breeds and saves.
;@ test: skip prints messages through other banks
BRSaveConfirmInput::
;> UpdateMenuCursor0A(wLinkRefused, BRSaveConfirmCursorPos, 2)
	ld de, BRSaveConfirmCursorPos
	ld hl, wLinkRefused
	ld b, $02
	call UpdateMenuCursor0A
;> no = wJoyPressed & 0x02
	ld a, [wJoyPressed]
	bit 1, a
;> while True:
;>     if no:
	jr z, .notB

.no
;>         PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>         wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;>         return
	jr .done

.notB
;>     if not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>         return
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wLinkRefused == 0x81:              # "no" counts like B
	ld a, [wLinkRefused]
	cp $81
;>         no = True
;>         continue
	jr z, .no

;>     break
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
	ret


;@ path: breed/house
;@ Cursor positions (tile offsets) of the yes/no window LayoutYesNoLeft; $FFFF ends.
BRSaveConfirmCursorPos::
	dw $0121, $0161, $ffff

;@ def BRBreedAndSave()
;@ path: breed/house
;@ Breed step 18: the breeding itself. Both parents' records move to
;@ wBreedParent1 / wBreedParent2 and leave the player's monsters; their
;@ pictures for the breeding scene go to wEncGfx. Then the monster list is
;@ compacted and the game is saved, with the menu and script state cleared so
;@ the save resumes on the field.
;@ test: skip calls other banks and saves the game
BRBreedAndSave::
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x000C)
	ld hl, $000c
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>@n1 CopyName(MonsterField(wListKnown, wMonName), wTextArg0)
	ld a, [wListKnown]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@n1
	call CopyName
;>@n2 CopyName(MonsterField(wCurPartyMember, wMonName), wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
;=@n2
	call CopyName
;> wEncGfx[0] = mem[MonsterField(wListKnown, wMonRecSpecies)] + 0x10   # pictures
	ld a, [wListKnown]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx], a
;> wEncGfx[1] = 1
	ld a, $01
	ld [wEncGfx + 1], a
;> CopyMonsterRecord(MonsterField(wListKnown, wMonsters), wBreedParent1)
	ld a, [wListKnown]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	call CopyMonsterRecord
;> mem[MonsterField(wListKnown, wMonsters)] = 0
	ld a, [wListKnown]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;> wEncGfx[2] = mem[MonsterField(wCurPartyMember, wMonRecSpecies)] + 0x10
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx + 2], a
;> wEncGfx[3] = 1
	ld a, $01
	ld [wEncGfx + 3], a
;> CopyMonsterRecord(MonsterField(wCurPartyMember, wMonsters), wBreedParent2)
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent2
	call CopyMonsterRecord
;> mem[MonsterField(wCurPartyMember, wMonsters)] = 0
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> SortPartyOrClearIcons()                 # bank 1 entry 4
	ld hl, HeaderLogo
	rst $10
;> MakeOffspring()
	ld hl, far_MakeOffspring
	rst $10
;> s0 = wFieldFlags
;> wFieldFlags = 0
	ld a, [wFieldFlags]
	push af
	xor a
	ld [wFieldFlags], a
;> s1 = wMenuStep
;> wMenuStep = 0
	ld a, [wMenuStep]
	push af
	xor a
	ld [wMenuStep], a
;> s2 = wScriptRunning
;> wScriptRunning = 0
	ld a, [wScriptRunning]
	push af
	xor a
	ld [wScriptRunning], a
;> s3 = wMenuOverlay
;> wMenuOverlay = 0
	ld a, [wMenuOverlay]
	push af
	xor a
	ld [wMenuOverlay], a
;> s4 = wStoryStep
;> wStoryStep = 0
	ld a, [wStoryStep]
	push af
	xor a
	ld [wStoryStep], a
;> SaveGame()
	di
	call SaveGame
	ei
;> wStoryStep = s4
	pop af
	ld [wStoryStep], a
;> wMenuOverlay = s3
	pop af
	ld [wMenuOverlay], a
;> wScriptRunning = s2
	pop af
	ld [wScriptRunning], a
;> wMenuStep = s1
	pop af
	ld [wMenuStep], a
;> wFieldFlags = s0
	pop af
	ld [wFieldFlags], a
	ret


;@ def BRWarpToBreeding()
;@ path: breed/house
;@ Breed step 19: once the message is out, closes the screen and warps to
;@ map 8 at (72, 72) with wStoryStep 0, for the breeding scene there. The
;@ species name of wCurPartyMember and (its plus value + 1) * 10 are left in
;@ wTextArg2 and wTextArgs for the scene's messages.
;@ test: skip starts a fade
BRWarpToBreeding::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wFieldFlags &= ~0x11
	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wWarpMap = 0x08
	ld a, $08
	ld [wWarpMap], a
;> wWarpOnGateFloor = 0
	ld a, $00
	ld [wWarpOnGateFloor], a
;> wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [wWarpX + 1], a
;> wWarpY = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> wStoryStep = 0
	ld a, $00
	ld [wStoryStep], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;>@cs CopySystemText(0x0500 | mem[MonsterField(wCurPartyMember, wMonRecSpecies)], wTextArg2)
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg2
;=@cs
	call CopySystemText
;>@nb Number16ToDecimal((mem[MonsterField(wCurPartyMember, wMonPlus)] + 1) * 10, wTextArgs)
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
;=@nb
	call Multiply
	ld c, l
	ld b, h
	ld hl, wTextArgs
	call Number16ToDecimal
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
	ret


;@ def CopyMonsterRecord(src: hl, dest: de)
;@ path: monster/records
;@ Copies one $95-byte monster record.
;@ test: src = 0xC100; dest = 0xC300
CopyMonsterRecord::
;>@c copy(dest, src, 0x95)
	ld b, $95
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
;=@c
	jr nz, .loop

	ret


;@ def BROpenPedigreeStatus()
;@ path: breed/house
;@ Breed step 20: opens the monster status screen (bank $07) on the list,
;@ starting at the monster under the cursor; wMenuOverlay keeps it running.
;@ test: skip calls another bank
BROpenPedigreeStatus::
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


;@ def BRReturnFromPedigreeStatus()
;@ path: breed/house
;@ Breed step 21: after the status screen, puts the list cursor on the
;@ monster it showed last (also wListKnown), reloads the window graphics and
;@ the text tiles, and reopens the two-choice window (step 5).
;@ test: skip draws to VRAM
BRReturnFromPedigreeStatus::
;>@c wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@c
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;>@k wListKnown = wSceneObjects[wViewResult]
	ld a, [wViewResult]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@k
	ld h, a
	ld a, [hl]
	ld [wListKnown], a
;> DecompressVRAM(0x2E, 0x12, 0x8800)     # window graphics
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x10
	ld a, $10
	ld [wTextIndex], a
;> RenderTextTiles(0x9400, 1, 8)
	ld hl, $9400
	ld de, $0801
	call RenderTextTiles
;> BRClearInfo()
	call BRClearInfo
;> BRDrawPageNames()
	call BRDrawPageNames
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;> BRDrawLevel()
	call BRDrawLevel
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> DrawBRPedigreeConfirm()
	call DrawBRPedigreeConfirm
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def BRBackToList()
;@ path: breed/house
;@ Breed step 22: after a refusal message, rebuilds and redraws the
;@ pedigree list and goes on with its input.
;@ test: skip draws to VRAM
BRBackToList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> BRCountMonsters()
	call BRCountMonsters
;> BRBuildMonsterList()
	call BRBuildMonsterList
;> PrintServiceMessage(0x0003)
	ld hl, $0003
	call PrintServiceMessage
;> DrawBRListScreen()
	call DrawBRListScreen
;> wMenuSubStep = 1
	ld a, $01
	ld [wMenuSubStep], a
	ret


;@ def BROpenMateStatus()
;@ path: breed/house
;@ Breed step 23: opens the monster status screen on the mate list, starting
;@ at the mate under the cursor.
;@ test: skip calls another bank
BROpenMateStatus::
;> wViewList = wSceneObjects
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;>@i wViewIndex = wListPage2 * 4 + (wListCursor2 & 0x7F)
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
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


;@ def BRReturnFromMateStatus()
;@ path: breed/house
;@ Breed step 24: after the status screen, puts the mate list cursor on the
;@ monster it showed last, reloads the graphics and reopens the mate's
;@ two-choice window (step 11).
;@ test: skip draws to VRAM
BRReturnFromMateStatus::
;>@c wListCursor2 = (wListCursor2 & 0x80) | (wViewResult & 3)
	ld a, [wListCursor2]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@c
	ld [wListCursor2], a
;> wListPage2 = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage2], a
;> DecompressVRAM(0x2E, 0x12, 0x8800)     # window graphics
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x10
	ld a, $10
	ld [wTextIndex], a
;> RenderTextTiles(0x9400, 1, 8)
	ld hl, $9400
	ld de, $0801
	call RenderTextTiles
;> BRDrawPair()
	call BRDrawPair
;> BRDrawMatePage()
	call BRDrawMatePage
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, LayoutPairInfo
	call DrawWindowLayout0A
;> BRDrawPairLevels()
	call BRDrawPairLevels
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> DrawBRMateConfirm()
	call DrawBRMateConfirm
;> wMenuSubStep = 0x0B
	ld a, $0b
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def BRBackToMates()
;@ path: breed/house
;@ Breed step 25: after a refusal message, rebuilds and redraws the mate
;@ list and goes on with its input (step 7).
;@ test: skip draws to VRAM
BRBackToMates::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> BRCountMates()
	call BRCountMates
;> BRBuildMateList()
	call BRBuildMateList
;> PrintServiceMessage(0x0004)
	ld hl, $0004
	call PrintServiceMessage
;> DrawBRMateScreen()
	call DrawBRMateScreen
;> wMenuSubStep = 7
	ld a, $07
	ld [wMenuSubStep], a
	ret


;@ def HatchFlow()
;@ path: breed/hatch
;@ The hatch entry of the breeding house: runs its steps, one per frame,
;@ picked by wMenuSubStep. Hatching an egg costs (plus value + 1) * 10 gold.
;@ test: skip jumps through a table
HatchFlow::
;> HatchFlowSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: breed/hatch
;@ Steps of hatching an egg (RST $00 table indexed by wMenuSubStep).
HatchFlowSteps::
	dw HTListEggs
	dw HTShowList
	dw HTListInput
	dw HTQuotePrice
	dw HTOpenConfirm
	dw HTConfirmInput
	dw HTStep6
	dw HTStep7
	dw HTStep8
	dw HTHatch
	dw HTWarpToHatching
	dw HTBackToMenu
	dw HTOpenStatus
	dw HTReturnFromStatus

;@ def HTListEggs()
;@ path: breed/hatch
;@ Hatch step 0: lists the eggs; with none, says so (message $13) and goes
;@ back to the menu (step 11), else asks which one (message $12).
;@ test: skip prints a message through other banks
HTListEggs::
;> if HTCountEggs() == 0:
	call HTCountEggs
	or a
	jr nz, .haveEggs

;>     PrintServiceMessage(0x0013)
	ld hl, $0013
	call PrintServiceMessage
;>     wMenuSubStep = 0x0B
	ld a, $0b
	ld [wMenuSubStep], a
;>     return
	ret


.haveEggs
;> HTBuildEggList()
	call HTBuildEggList
;> PrintServiceMessage(0x0012)
	ld hl, $0012
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def HTCountEggs() -> a
;@ path: breed/hatch
;@ Counts the monster records that hold an egg (wMonEgg set) into
;@ wListLength and returns the count.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
HTCountEggs::
;> n = 0
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for _ in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] != 0:     # an egg (wMonEgg)
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr z, .next

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
;=@for
	ld d, a
	dec b
	jr nz, .loop

;> wListLength = n
	ld a, c
	ld [wListLength], a
;> return n
	ret


;@ def HTBuildEggList()
;@ path: breed/hatch
;@ Writes the slot numbers of the eggs into the 20-byte list at
;@ wSceneObjects, $FF after the last.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
HTBuildEggList::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = wSceneObjects
;> rec = wMonsters
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for m in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] != 0:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr z, .next

;>         mem[p] = m
;>         p += 1
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
;=@for
	ld d, a
	inc c
	dec b
	jr nz, .loop

	ret


;@ def HTShowList()
;@ path: breed/hatch
;@ Hatch step 1: once the message is out, draws and shows the egg list.
;@ test: skip draws to VRAM
HTShowList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> HTDrawPage()
	call HTDrawPage
;> DrawHTListScreen()
	call DrawHTListScreen
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawHTListScreen()
;@ path: breed/hatch
;@ Draws the menu with the gold and the egg list window with its cursor into
;@ wTilemapBuffer.
;@ test: skip draws from tables
DrawHTListScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawBreedingMenu()
	call DrawBreedingMenu
;> DrawWindowLayout0A(LayoutEggList)
	ld de, LayoutEggList
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;>@k3 DrawListCursor(wListCursor, HTListCursorPos, 4, wListLength)
	ld de, HTListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;=@k3
	ret


;@ def HTDrawPage()
;@ path: breed/hatch
;@ Draws the 4 eggs of page wListPage: their species names (9 tiles each:
;@ three at $9650 on, the fourth at $8800) and their gender marks.
;@ test: skip draws to VRAM
HTDrawPage::
;>@e entry = wSceneObjects + wListPage * 4
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
;> tiles = 0x9650
	ld hl, $9650
;> for _ in range(3):
;>     entry, tiles = DrawSpeciesEntry(entry, tiles)
	call DrawSpeciesEntry
	call DrawSpeciesEntry
	call DrawSpeciesEntry
;> DrawSpeciesEntry(entry, 0x8800)
	ld hl, $8800
	call DrawSpeciesEntry
;> HTDrawGenders()
	call HTDrawGenders
	ret


;@ def DrawSpeciesEntry(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/hatch
;@ Draws the species name of list entry `entry` (text group 5) into 9 tiles
;@ at `tiles`, or 9 tiles of plain colour 1 for an empty entry ($FF).
;@ Returns the next entry and tiles.
;@ test: skip draws to VRAM
DrawSpeciesEntry::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>     wTextIndex = mem[MonsterField(m, wMonRecSpecies)]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
;>     wTextGroup = 0x05                     # species names
	ld a, $05
	ld [wTextGroup], a
;>     RenderTextTiles(tiles, 1, 9)
	ld de, $0901
	pop hl
	push hl
	call RenderTextTiles
	pop hl
;>@r0     return entry + 1, tiles + 0x90
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r0
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(72):
	ld b, $48
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def HTDrawGenders()
;@ path: breed/hatch
;@ Draws the gender marks of the 4 eggs of page wListPage into the tiles from
;@ $8A00 on (one tile each).
;@ test: skip draws to VRAM
HTDrawGenders::
;>@e entry = wSceneObjects + wListPage * 4
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
;> tiles = 0x8A00
	ld hl, $8a00
;> for _ in range(4):
;>     entry, tiles = DrawEggGenderEntry(entry, tiles)
	call DrawEggGenderEntry
	call DrawEggGenderEntry
	call DrawEggGenderEntry

;@ def DrawEggGenderEntry(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/hatch
;@ Draws the gender mark of the egg in list entry `entry` into the tile at
;@ `tiles`: $A7 + gender once the appraiser has told it (wMonEgg = 2), else
;@ "?" ($98); a blank tile for an empty entry. Returns the next entry and tile.
;@ test: skip draws to VRAM
DrawEggGenderEntry::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>     if mem[MonsterField(m, wMonEgg)] == 2:          # gender known
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, .mark

;>@g         c = 0xA7 + (mem[MonsterField(m, wMonGender)] & 1)
	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@g
	ld a, [hl]
	and $01
	add $a7
;>     else:
;>         c = 0x98                         # "?"
.mark
;>     wTextArg0[0] = c
	ld [wTextArg0], a
;>     wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save     saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	pop hl
	push hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
;=@save
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;>     wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;>     wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;>     wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;>     wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;>     PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>     wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;>     wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
;>@r0     return entry + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r0
	ld h, a
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(8):
	ld b, $08
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def HTListInput()
;@ path: breed/hatch
;@ Hatch step 2: the egg list. The page is redrawn when it changes. B goes
;@ back to the menu (message 1), A picks the egg under the cursor.
;@ test: skip draws to VRAM
HTListInput::
;>@u old_page = wListPage
	ld de, HTListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@u
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdateListCursor(wListCursor, HTListCursorPos, 4, wListLength)
	call UpdateListCursor
;> if wListPage != old_page:
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .samePage

;>     HTDrawPage()
	call HTDrawPage

.samePage
;> if wJoyPressed & 0x02:                    # B: back to the menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;=@ret
	jr .done

.notB
;> elif wJoyPressed & 0x01:                  # A: this egg
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
;>@ret return
	ret


;@ path: breed/hatch
;@ Cursor table of the egg list (tile offsets row * 32 + column): the page
;@ marker, then the 4 rows; $FFFF ends.
HTListCursorPos::
	dw $0192, $00a8, $00e8, $0128, $0168, $ffff

;@ def HTQuotePrice()
;@ path: breed/hatch
;@ Hatch step 3: tells the price of hatching the picked egg, (plus value +
;@ 1) * 10 gold, in wTextArgs (message $14).
;@ test: skip prints a message through other banks
HTQuotePrice::
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;>@p Number16ToDecimal((mem[MonsterField(m, wMonPlus)] + 1) * 10, wTextArgs)
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
;=@p
	ld c, l
	ld b, h
	ld hl, wTextArgs
	call Number16ToDecimal
;> PrintServiceMessage(0x0014)
	ld hl, $0014
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def HTOpenConfirm()
;@ path: breed/hatch
;@ Hatch step 4: once the message is out, opens the two-choice window (view
;@ the egg / hatch it), cursor wMenuChoice3.
;@ test: skip draws to VRAM
HTOpenConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> DrawWindowLayout0A(LayoutHatchConfirm)
	ld de, LayoutHatchConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice3, HTConfirmCursorPos)
	ld de, HTConfirmCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def HTConfirmInput()
;@ path: breed/hatch
;@ Hatch step 5: the two-choice window. B goes back to the egg list. The
;@ first choice opens the status screen (step 12). The second pays the price
;@ and hatches (step 9), or says the gold is not enough (message $1E, step
;@ 11).
;@ test: skip prints messages through other banks
HTConfirmInput::
;> UpdateMenuCursor0A(wMenuChoice3, HTConfirmCursorPos, 2)
	ld de, HTConfirmCursorPos
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintServiceMessage(0x0012)
	ld hl, $0012
	call PrintServiceMessage
;>     DrawHTListScreen()
	call DrawHTListScreen
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer
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
;=@ret
	jr .done

.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wMenuChoice3 != 0x81:                  # first choice: the status screen
	ld a, [wMenuChoice3]
	cp $81
	jr z, .hatch

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep = 0x0C
	ld a, $0c
	ld [wMenuSubStep], a
;=@ret
	jr .done

.hatch
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;> price = (mem[MonsterField(m, wMonPlus)] + 1) * 10
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
;>@g if wGold < price:
	ld a, [wGold]
	sub l
	ld a, [wGold + 1]
	sbc h
	ld a, [wGold + 2]
	sbc $00
;=@g
	jr nc, .pay

;>     PrintServiceMessage(0x001E)          # not enough gold
	ld hl, $001e
	call PrintServiceMessage
;>     wMenuSubStep = 0x0B
	ld a, $0b
	ld [wMenuSubStep], a
;=@ret
	jr .done

.pay
;> else:
;>     SpendGold(price)
	ld e, $00
	call SpendGold
;>     wLinkRefused = 0
	xor a
	ld [wLinkRefused], a
;>@f     wMenuSubStep += 4                    # on to HTHatch
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
;=@f
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ path: breed/hatch
;@ Cursor positions (tile offsets) of the two-choice window LayoutHatchConfirm; $FFFF ends.
HTConfirmCursorPos::
	dw $002d, $006d, $ffff

;@ def HTStep6()
;@ path: breed/hatch
;@ Hatch step 6: does nothing but move on (HTConfirmInput skips it).
HTStep6::
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def HTStep7()
;@ path: breed/hatch
;@ Hatch step 7: does nothing but move on.
HTStep7::
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def HTStep8()
;@ path: breed/hatch
;@ Hatch step 8: does nothing but move on.
HTStep8::
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def HTHatch()
;@ path: breed/hatch
;@ Hatch step 9: prints the hatching message ($15) and lets bank $16 hatch
;@ the egg under the cursor (wCurPartyMember = wHatchSlot = wLeaderSlot).
;@ test: skip calls another bank
HTHatch::
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> PrintServiceMessage(0x0015)
	ld hl, $0015
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;> wCurPartyMember = m
	ld [wCurPartyMember], a
;> wHatchSlot = m
	ld [wHatchSlot], a
;> wLeaderSlot = m
	ld [wLeaderSlot], a
;> InitJoinedMonster()
	ld hl, far_InitJoinedMonster
	rst $10
	ret


;@ def HTWarpToHatching()
;@ path: breed/hatch
;@ Hatch step 10: once the message is out, closes the screen, puts the new
;@ monster's species name with plus value and gender mark into wTextArg1 and
;@ its picture, name, gender and species into the wChosenMon variables, and
;@ warps to map 8 at (72, 72) with wStoryStep 2, where the hatching scene
;@ plays.
;@ test: skip starts a fade
HTWarpToHatching::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wFieldFlags &= ~0x11
	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> m = wHatchSlot
;> wCurPartyMember = m
	ld a, [wHatchSlot]
	ld [wCurPartyMember], a
;> CopySystemText(0x0500 | mem[MonsterField(m, wMonRecSpecies)], wTextArg1)
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
;> AppendPlusValue(mem[MonsterField(m, wMonPlus)], wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendPlusValue
;> AppendGenderMark(mem[MonsterField(m, wMonGender)], wTextArg1)
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendGenderMark
;> pic = mem[MonsterField(m, wMonRecSpecies)] + 0x10
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
;> wChosenMonPic = pic
	ld [wChosenMonPic], a
;> wEncGfx[0] = pic
	ld [wEncGfx], a
;> wEncGfx[1] = 1
	ld a, $01
	ld [wEncGfx + 1], a
;> wChosenMonName = MonsterField(m, wMonName)
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
	ld a, h
;=@nm
	ld [wChosenMonName + 1], a
;>@nm wChosenMonGender = mem[MonsterField(m, wMonGender)]
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
;> wChosenMonSpecies = mem[MonsterField(m, wMonRecSpecies)]
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wChosenMonSpecies], a
;> wWarpMap = 0x08
	ld a, $08
	ld [wWarpMap], a
;> wWarpOnGateFloor = 0
	ld a, $00
	ld [wWarpOnGateFloor], a
;> wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [wWarpX + 1], a
;> wWarpY = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> wStoryStep = 2
	ld a, $02
	ld [wStoryStep], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> StartFade(3)
	ld a, $03
	call StartFade
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
	ret


;@ def HTBackToMenu()
;@ path: breed/hatch
;@ Hatch step 11: after a message (no eggs, not enough gold), goes back to
;@ the breeding house menu.
;@ test: skip prints a message through other banks
HTBackToMenu::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def HTOpenStatus()
;@ path: breed/hatch
;@ Hatch step 12: opens the monster status screen on the egg list.
;@ test: skip calls another bank
HTOpenStatus::
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


;@ def HTReturnFromStatus()
;@ path: breed/hatch
;@ Hatch step 13: after the status screen, puts the cursor on the egg it
;@ showed last, reloads graphics and list, repeats the price and reopens the
;@ two-choice window (step 4).
;@ test: skip draws to VRAM
HTReturnFromStatus::
;>@c wListCursor = (wListCursor & 0x80) | (wViewResult & 3)
	ld a, [wListCursor]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
;=@c
	ld [wListCursor], a
;> wListPage = wViewResult >> 2
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage], a
;> DecompressVRAM(0x2E, 0x12, 0x8800)     # window graphics
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x10
	ld a, $10
	ld [wTextIndex], a
;> RenderTextTiles(0x9400, 1, 8)
	ld hl, $9400
	ld de, $0801
	call RenderTextTiles
;> HTCountEggs()
	call HTCountEggs
;> HTBuildEggList()
	call HTBuildEggList
;> HTDrawPage()
	call HTDrawPage
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;>@p Number16ToDecimal((mem[MonsterField(m, wMonPlus)] + 1) * 10, wTextArgs)
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
;=@p
	ld c, l
	ld b, h
	ld hl, wTextArgs
	call Number16ToDecimal
;> PrintServiceMessage(0x0014)
	ld hl, $0014
	call PrintServiceMessage
;> DrawHTListScreen()
	call DrawHTListScreen
;> DrawWindowLayout0A(LayoutHatchConfirm)
	ld de, LayoutHatchConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice3, HTConfirmCursorPos)
	ld de, HTConfirmCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep = 4
	ld a, $04
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def DrawSaveFileInfo()
;@ path: save/summary
;@ Fills the save window (LayoutSaveFile) with the saved game's summary from
;@ battery RAM: player name (tiles $8A00), play time (hours at row 1 column
;@ 13, minutes at column 16), the party's names and family icons and their
;@ levels (row 4, columns 4, 10 and 16). Without a saved game the window's
;@ four rows are blanked and text 2:$31 is shown instead (10 tiles at row 2,
;@ column 4).
;@ test: skip reads cartridge RAM and draws to VRAM
DrawSaveFileInfo::
;> if not ReadSRAMByte(sSaveValid):
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr nz, .saved

;>@b     for row in range(1, 5):
;>         fill(OffsetToTilemapBuffer(row * 32 + 1), 0xE0, 17)
	ld hl, $0021
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
;=@b
	ld hl, $0041
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
;=@b
	ld hl, $0061
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
;=@b
	ld hl, $0081
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
;>@t     for i in range(10):
;>         mem[OffsetToTilemapBuffer(0x0044) + i] = 0xA4 + i
	ld hl, $0044
	call OffsetToTilemapBuffer
	ld b, $0a
	ld a, $a4
.tiles
	ld [hli], a
	inc a
;=@t
	dec b
	jr nz, .tiles

;>     wTextIndex = 0x31
	ld a, $31
	ld [wTextIndex], a
;>     wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;>     RenderTextTiles(0x8A40, 1, 10)       # the "no saved game" text into those tiles
	ld hl, $8a40
	ld de, $0a01
	call RenderTextTiles
;=@end
	jp .done


.saved
;> else:
;>     mem[0x0100] = 0x0A                   # enable cartridge RAM
	di
	ld a, $0a
	ld [$0100], a
;>     RenderNameTiles(0x8A00, sPlayerName)
	ld de, sPlayerName
	ld hl, $8a00
	call RenderNameTiles
;>     DrawSaveFileParty()
	call DrawSaveFileParty
;>@h     PrintNumber2Zeros(ReadSRAMByte(sPlayHours), OffsetToTilemapBuffer(0x002D))
	ld hl, sPlayHours
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $002d
	call OffsetToTilemapBuffer
;=@h
	call PrintNumber2Zeros
;>@mi     PrintNumber2Zeros(ReadSRAMByte(sPlayMinutes), OffsetToTilemapBuffer(0x0030))
	ld hl, sPlayMinutes
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $0030
	call OffsetToTilemapBuffer
;=@mi
	call PrintNumber2Zeros
;>     count = ReadSRAMByte(sPartyCount)
	ld hl, sPartyCount
	call ReadSRAMByte
;>@lp     for i in range(min(count, 3)):
	or a
	jr z, .clear0

;>@lv         mem[0x0100] = 0x0A; level = mem[MonsterField(sParty[i], sSavedMonLevel)]
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [sParty]
	call MonsterField
;=@lv
	ld c, [hl]
	ei
;>@pr         PrintNumber2(level, OffsetToTilemapBuffer(0x0084 + 6 * i))
	ld b, $00
	ld hl, $0084
	call OffsetToTilemapBuffer
	call PrintNumber2
;=@lp
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $01
	jr z, .clear1

;=@lv
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [sParty + 1]
	call MonsterField
;=@lv
	ld c, [hl]
	ei
;=@pr
	ld b, $00
	ld hl, $008a
	call OffsetToTilemapBuffer
	call PrintNumber2
;=@lp
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $02
	jr z, .clear2

;=@lv
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [sParty + 2]
	call MonsterField
;=@lv
	ld c, [hl]
	ei
;=@pr
	ld b, $00
	ld hl, $0090
	call OffsetToTilemapBuffer
	call PrintNumber2

.done
;>     if count >= 3:
;>@end         mem[0x0100] = 0x00               # disable cartridge RAM
	ld a, $00
	ld [$0100], a
;>         return
	ret


.clear0
;>@cs     for j in range(count, 3):            # empty party slots: no name, no level
;>         ClearSaveInfoSlot(0x0061 + 6 * j)
	ld hl, $0061
	call ClearSaveInfoSlot

.clear1
;=@cs
	ld hl, $0067
	call ClearSaveInfoSlot

.clear2
;=@cs
	ld hl, $006d
	call ClearSaveInfoSlot
;>     mem[0x0100] = 0x00
	ld a, $00
	ld [$0100], a
	ret


;@ def ClearSaveInfoSlot(pos: hl)
;@ path: save/summary
;@ Blanks one party slot of the save window: 5 tiles at `pos` and 2 tiles at
;@ `pos` + 33 (the row below, one column on).
;@ test: pos = rand(0, 0x1DF)
ClearSaveInfoSlot::
;>@a fill(OffsetToTilemapBuffer(pos), 0xE0, 5)
	push hl
	call OffsetToTilemapBuffer
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@a
	ld [hli], a
	ld [hl], a
;>@q fill(OffsetToTilemapBuffer(pos + 0x21), 0xE0, 2)
	pop hl
	ld a, l
	add $21
	ld l, a
	ld a, h
	adc $00
;=@q
	ld h, a
	call OffsetToTilemapBuffer
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


;@ def DrawSaveFileParty()
;@ path: save/summary
;@ Clears the 24 family-icon tiles at $8DA0 and draws the saved party's
;@ names (4 tiles each at $8A40, $8A80, $8AC0) and family icons.
;@ test: skip reads cartridge RAM and draws to VRAM
DrawSaveFileParty::
;> ClearTiles(0x8DA0, 0x18)
	ld hl, $8da0
	ld b, $18
	call ClearTiles
;>@p for i in range(3):
;>     mem[0x0100] = 0x0A                   # enable cartridge RAM
	di
	ld a, $0a
	ld [$0100], a
;>     name = MonsterField(sParty[i], sSavedMonName)
	ld hl, sSavedMonName
	ld a, [sParty]
	call MonsterField
	ei
;>     DrawSaveFileMember(i + 1, name, 0x8A40 + 0x40 * i)
	ld e, l
	ld d, h
	ld hl, $8a40
	ld a, $01
	call DrawSaveFileMember
;=@p
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [sParty + 1]
	call MonsterField
;=@p
	ei
	ld e, l
	ld d, h
	ld hl, $8a80
	ld a, $02
	call DrawSaveFileMember
;=@p
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [sParty + 2]
	call MonsterField
;=@p
	ei
	ld e, l
	ld d, h
	ld hl, $8ac0
	ld a, $03
	call DrawSaveFileMember
;> return
	ret


;@ def DrawSaveFileMember(n: a, name: de, tiles: hl)
;@ path: save/summary
;@ Draws saved party member `n` (1-3): its name into 4 tiles at `tiles` and
;@ its family icon (from SaveFamilyIconGfx) into tile $8DA0 + (n - 1) * 16;
;@ when the saved party has fewer members, 4 blank tiles instead. The
;@ drawing part sits behind ClearTiles (label jr_00a_5fd9).
;@ test: skip reads cartridge RAM and draws to VRAM
DrawSaveFileMember::
;> mem[0x0100] = 0x0A                       # enable cartridge RAM
	ld b, a
	di
	ld a, $0a
	ld [$0100], a
;> if sPartyCount < n:
	ld a, [sPartyCount]
	cp b
	ei
	jr nc, jr_00a_5fd9

;>     ClearTiles(tiles, 0x20)              # (falls into ClearTiles)
;>     return
	ld b, $20
;> # else: the name and icon are drawn at jr_00a_5fd9

;@ def ClearTiles(tiles: hl, count: b, name: de) -> hl
;@ path: menu/window
;@ Fills `count` tile rows (2 bytes each) at VRAM `tiles` with plain colour 1
;@ ($FF, $00); `name` is not used by this part. The code after its `ret` (jr_00a_5fd9) is the drawing part of
;@ DrawSaveFileMember: the member's name and its family icon.
;@ test: skip writes VRAM while waiting for the LCD
ClearTiles::
;>@l for _ in range(count):
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@l
	dec b
	jr nz, ClearTiles

;> return
	ret


jr_00a_5fd9:
;> # --- DrawSaveFileMember goes on here; `name` (de) is only used by this part
;> n = count                     # on this path b holds the member number
	push bc
;> RenderNameTiles(tiles, name)
	call RenderNameTiles
	pop bc
;> mem[0x0100] = 0x0A
	dec b
	push bc
	di
	ld a, $0a
	ld [$0100], a
;>@f family = mem[MonsterField(sParty[n - 1], sSavedMonFamily)]
	ld hl, sParty
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;=@f
	ld h, a
	ld a, [hl]
	ld hl, sSavedMonFamily
	call MonsterField
	ld a, [hl]
	ei
;>@i icon = SaveFamilyIconGfx[family]
	add a
	ld hl, SaveFamilyIconGfx
	add l
	ld l, a
	ld a, $00
	adc h
;=@i
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;>@d DecompressVRAM(icon & 0xFF, icon >> 8, 0x8DA0 + (n - 1) * 16)
	pop bc
	ld a, b
	swap a
	add $a0
	ld l, a
	ld h, $8d
;=@d
	call DecompressVRAM
	ret


;@ path: save/summary
;@ The 10 monster family icons (one tile each) for the save window, as
;@ DecompressVRAM references: bank $2E, entries 3-12.
SaveFamilyIconGfx::
	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

;@ def DrawTwoDigits0A(value: bc, dest: hl)
;@ path: menu/numbers
;@ Writes `value` (0-99) as one or two digit tiles ($F0 + digit) from `dest`
;@ on: the tens digit only when it is not 0. `dest` is a screen-like address
;@ (the column wraps inside its 32-tile row).
;@ test: value = rand(0, 99); dest = 0xC500
DrawTwoDigits0A::
;> tens, _ = CountDivisions(value, 10)
	ld de, $000a
	push bc
	call CountDivisions
	pop bc
;> if tens:
	or a
	jr z, .ones

;>     tens, value = CountDivisions(value, 10)
	ld de, $000a
	call CountDivisions
;>     DrawDigit(tens, dest)
	call DrawDigit
;>     dest = NextScreenColumn2(dest)
	call NextScreenColumn2

.ones
;> DrawDigit(value, dest)
	ld a, c
	call DrawDigit
	ret


;@ def CountDivisions(value: bc, divisor: de) -> (a, bc)
;@ path: menu/numbers
;@ Divides `value` by `divisor` by repeated subtraction: returns the quotient
;@ in a and the remainder in bc.
;@ test: bc = rand(0, 999); de = rand(1, 100)
CountDivisions::
;> q = -1
	push hl
	ld h, $ff
.loop
;> while True:
;>     q += 1
	inc h
;>@s     value -= divisor
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
;>     if value < 0:
;>         break
	jr nc, .loop

;>@r value += divisor
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
;> return q, value
	ld a, h
	pop hl
	ret


;@ def DrawDigit(d: a, dest: hl)
;@ path: menu/numbers
;@ Writes the digit tile $F0 + d at `dest` (waiting for VRAM access).
;@ test: skip writes VRAM while waiting for the LCD
DrawDigit::
;> WriteVRAM(dest, 0xF0 + d)
	add $f0
	call WriteVRAM
	ret


;@ def NextScreenColumn2(addr: hl) -> hl
;@ path: menu/window
;@ Steps an address one tile to the right, wrapping around inside its 32-tile
;@ row (a copy of NextScreenColumn).
NextScreenColumn2::
;>@r return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@r
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@r
	ret


;@ def AppendPlusValue(plus: a, text: de)
;@ path: text/names
;@ When `plus` is not 0, appends "+" ($A2) and its decimal digits to the
;@ $F0-terminated string `text` (a monster's name gets its plus value).
;@ test: skip writes a string through a helper
AppendPlusValue::
;> if plus == 0:
	or a
;>     return
	ret z

;> while mem[text] != 0xF0:                 # find the end mark
	push af
.find
;>     text += 1
	ld a, [de]
	inc de
	cp $f0
	jr nz, .find

;> mem[text] = 0xA2                         # "+" over the end mark
	dec de
	ld a, $a2
	ld [de], a
;> ByteToDecimal(plus, text + 1)
	inc de
	pop af
	ld l, e
	ld h, d
	call ByteToDecimal
	ret


;@ def AppendGenderMark(gender: a, text: de)
;@ path: text/names
;@ Appends the gender mark $A7 + (gender & 1) to the $F0-terminated string
;@ `text`.
;@ test: text = 0xC100; mem[0xC100 + rand(0, 8)] = 0xF0
AppendGenderMark::
;> while mem[text] != 0xF0:
	push af
.find
;>     text += 1
	ld a, [de]
	inc de
	cp $f0
	jr nz, .find

;> mem[text] = 0xA7 + (gender & 1)
	dec de
	pop af
	and $01
	add $a7
	ld [de], a
;> mem[text + 1] = 0xF0
	inc de
	ld a, $f0
	ld [de], a
	ret


;@ def EggAppraiserScreen()
;@ path: breed/appraiser
;@ Service screen 7, the egg appraiser: a menu with appraise an egg (20
;@ gold), change an egg's gender and quit, the player's gold shown above it.
;@ One step per frame, picked by wMenuStep.
;@ test: skip jumps through a table
EggAppraiserScreen::
;> EggAppraiserSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: breed/appraiser
;@ Steps of the egg appraiser screen (RST $00 table indexed by wMenuStep).
EggAppraiserSteps::
	dw EAInit
	dw EAOpenMenu
	dw EAMenuInput
	dw EARunChoice
	dw EAClose

;@ def EAInit()
;@ path: breed/appraiser
;@ Step 0: lines the scroll up with whole tiles, clears the menu cursors,
;@ works out the BG map address of the visible screen, restores the field's
;@ tiles in wTilemapBuffer and loads the window graphics (bank $2E entry $13).
;@ test: skip decompresses into VRAM
EAInit::
;> RoundToTile(hScrollX)
	ld hl, hScrollX
	call RoundToTile
;> RoundToTile(hScrollY)
	ld hl, hScrollY
	call RoundToTile
;> FillMemory(wMenuChoice, 8, 0)            # the menu cursors $C8DA-$C8E1
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@map a = (hScrollY >> 3) * 32 + (hScrollX >> 3)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@map
	rrca
	rrca
	rrca
	add l
	ld l, a
;>@bg wWindowBgMap = 0x9800 | (a & 0x03FF)
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
;=@bg
	ld h, a
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DecompressVRAM(0x2E, 0x13, 0x8800)     # window graphics
	ld de, $2e13
	ld hl, $8800
	call DecompressVRAM
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def EAOpenMenu()
;@ path: breed/appraiser
;@ Step 1: once the message is out, draws the menu and shows it.
;@ test: skip draws to VRAM
EAOpenMenu::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawEAMenu()
	call DrawEAMenu
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def DrawEAMenu()
;@ path: breed/appraiser
;@ Draws the three-entry menu, the gold window with the player's gold (row 1,
;@ column 14) and the message box frame into wTilemapBuffer, cursor on
;@ wMenuChoice (used here as the menu cursor).
;@ test: skip draws from tables
DrawEAMenu::
;> DrawWindowLayout0A(LayoutAppraiserMenu)
	ld de, LayoutAppraiserMenu
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutGold)
	ld de, LayoutGold
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;>@g hNumber = wGold                      # 24 bits
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [wGold + 1]
	ldh [hNumber + 1], a
	ld a, [wGold + 2]
	ldh [hNumber + 2], a
;> PrintNumber5(OffsetToTilemapBuffer(0x002E))
	ld hl, $002e
	call OffsetToTilemapBuffer
	call PrintNumber5
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice, EAMenuCursorPos)
	ld de, EAMenuCursorPos
	ld a, [wMenuChoice]
	call DrawCursorAt0A
	ret


;@ def EAMenuInput()
;@ path: breed/appraiser
;@ Step 2: moves the menu cursor. B or Start closes the screen; A chooses
;@ (bit 7 of the cursor is set) and clears the list cursors.
;@ test: skip calls the cursor drawing
EAMenuInput::
;> UpdateMenuCursor0A(wMenuChoice, EAMenuCursorPos, 3)
	ld de, EAMenuCursorPos
	ld hl, wMenuChoice
	ld b, $03
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x0A:                    # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .notCancel

;>     wMenuStep += 2                       # close
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
;=@ret
	jr .done

.notCancel
;> elif wJoyPressed & 0x01:                  # A
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
;>     FillMemory(wMenuChoice2, 7, 0)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     FillMemory(wListCursor, 8, 0)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr .done

.done
;>@ret return
	ret


;@ path: breed/appraiser
;@ Cursor positions (tile offsets row * 32 + column, $FFFF ends) of the
;@ appraiser menu: appraise, change gender, quit.
EAMenuCursorPos::
	dw $0021, $0061, $00a1, $ffff

;@ def EARunChoice()
;@ path: breed/appraiser
;@ Step 3: runs the chosen menu entry, one step per frame.
;@ test: skip jumps through a table
EARunChoice::
;> EAChoices[wMenuChoice & 0x7F]()
	ld a, [wMenuChoice]
	rst $00

;@ path: breed/appraiser
;@ The three menu entries (RST $00 table): appraise, change gender, quit.
EAChoices::
	dw AppraiseFlow
	dw GenderFlow
	dw EAClose

;@ def EAClose()
;@ path: breed/appraiser
;@ Step 4 (and the quit entry): puts the field's tiles back and ends the
;@ service screen (wFieldFlags bit 4).
;@ test: skip draws to VRAM
EAClose::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wFieldFlags &= ~0x10
	ld hl, wFieldFlags
	res 4, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
	ret


;@ def AppraiseFlow()
;@ path: breed/appraiser
;@ The appraise entry: runs its steps, one per frame, picked by wMenuSubStep.
;@ The appraiser judges an egg's stats, skills, growth, gender and
;@ resistances for 20 gold.
;@ test: skip jumps through a table
AppraiseFlow::
;> AppraiseFlowSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: breed/appraiser
;@ Steps of appraising an egg (RST $00 table indexed by wMenuSubStep).
AppraiseFlowSteps::
	dw APListEggs
	dw APShowList
	dw APListInput
	dw APPay
	dw APJudgeStats
	dw APJudgeSkills
	dw APJudgeGrowth
	dw APTellGender
	dw APMarkAppraised
	dw APBackToMenu
	dw APAskPay
	dw APOpenPayConfirm
	dw APPayConfirmInput
	dw APOpenStatus
	dw APReturnFromStatus
	dw APJudgeResistances

;@ def APListEggs()
;@ path: breed/appraiser
;@ Appraise step 0: lists the eggs; with none, says so (message 4) and goes
;@ back to the menu, else asks which one (message 3).
;@ test: skip prints a message through other banks
APListEggs::
;> if EACountEggs() == 0:
	call EACountEggs
	or a
	jr nz, .haveEggs

;>     PrintServiceMessage(0x0004)
	ld hl, $0004
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;>     return
	ret


.haveEggs
;> EABuildEggList()
	call EABuildEggList
;> PrintServiceMessage(0x0003)
	ld hl, $0003
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def EACountEggs() -> a
;@ path: breed/appraiser
;@ Counts the monster records that hold an egg (wMonEgg set) into
;@ wListLength and returns the count.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
EACountEggs::
;> n = 0
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for _ in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] != 0:     # an egg (wMonEgg)
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr z, .next

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
;=@for
	ld d, a
	dec b
	jr nz, .loop

;> wListLength = n
	ld a, c
	ld [wListLength], a
;> return n
	ret


;@ def EABuildEggList()
;@ path: breed/appraiser
;@ Writes the slot numbers of the eggs into the 20-byte list at
;@ wSceneObjects, $FF after the last.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
EABuildEggList::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = wSceneObjects
;> rec = wMonsters
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00
.loop
;>@for for m in range(20):
;>@if     if mem[rec] != 0 and mem[rec + 0x63] != 0:
	push de
	ld a, [de]
	or a
	jr z, .next

;=@if
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@if
	ld a, [de]
	or a
	jr z, .next

;>         mem[p] = m
;>         p += 1
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
;=@for
	ld d, a
	inc c
	dec b
	jr nz, .loop

	ret


;@ def APShowList()
;@ path: breed/appraiser
;@ Appraise step 1: once the message is out, draws and shows the egg list.
;@ test: skip draws to VRAM
APShowList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> EADrawPage()
	call EADrawPage
;> EADrawGenders()
	call EADrawGenders
;> DrawAPListScreen()
	call DrawAPListScreen
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawAPListScreen()
;@ path: breed/appraiser
;@ Draws the menu with the gold and the egg list window with its cursor into
;@ wTilemapBuffer.
;@ test: skip draws from tables
DrawAPListScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawEAMenu()
	call DrawEAMenu
;> DrawWindowLayout0A(LayoutEggList2)
	ld de, LayoutEggList2
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;>@k4 DrawListCursor(wListCursor, APListCursorPos, 4, wListLength)
	ld de, APListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;=@k4
	ret


;@ def EADrawPage()
;@ path: breed/appraiser
;@ Draws the species names of the 4 eggs of page wListPage (9 tiles each:
;@ the first at $9700, the others from $8800 on).
;@ test: skip draws to VRAM
EADrawPage::
;>@e entry = wSceneObjects + wListPage * 4
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
;> entry, _ = DrawSpeciesEntry2(entry, 0x9700)
	ld hl, $9700
	call DrawSpeciesEntry2
;> entry, tiles = DrawSpeciesEntry2(entry, 0x8800)
	ld hl, $8800
	call DrawSpeciesEntry2
;> for _ in range(2):                    # the second time by running into it
;>     entry, tiles = DrawSpeciesEntry2(entry, tiles)
	call DrawSpeciesEntry2

;@ def DrawSpeciesEntry2(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/appraiser
;@ Draws the species name of list entry `entry` (text group 5) into 9 tiles
;@ at `tiles`, or 9 tiles of plain colour 1 for an empty entry ($FF).
;@ Returns the next entry and tiles (a copy of DrawSpeciesEntry).
;@ test: skip draws to VRAM
DrawSpeciesEntry2::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>     wTextIndex = mem[MonsterField(m, wMonRecSpecies)]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
;>     wTextGroup = 0x05                     # species names
	ld a, $05
	ld [wTextGroup], a
;>     RenderTextTiles(tiles, 1, 9)
	ld de, $0901
	pop hl
	push hl
	call RenderTextTiles
	pop hl
;>@r0     return entry + 1, tiles + 0x90
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r0
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(72):
	ld b, $48
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def EADrawGenders()
;@ path: breed/appraiser
;@ Draws the gender marks of the 4 eggs of page wListPage into the tiles from
;@ $89B0 on (one tile each).
;@ test: skip draws to VRAM
EADrawGenders::
;>@e entry = wSceneObjects + wListPage * 4
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
;> tiles = 0x89B0
	ld hl, $89b0
;> for _ in range(4):
;>     entry, tiles = DrawEggGenderEntry2(entry, tiles)
	call DrawEggGenderEntry2
	call DrawEggGenderEntry2
	call DrawEggGenderEntry2

;@ def DrawEggGenderEntry2(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/appraiser
;@ Draws the gender mark of the egg in list entry `entry` into the tile at
;@ `tiles`: $A7 + gender once it has been appraised (wMonEgg = 2), else "?"
;@ ($98); a blank tile for an empty entry (a copy of DrawEggGenderEntry).
;@ test: skip draws to VRAM
DrawEggGenderEntry2::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>     if mem[MonsterField(m, wMonEgg)] == 2:          # gender known
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, .mark

;>@g         c = 0xA7 + (mem[MonsterField(m, wMonGender)] & 1)
	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@g
	ld a, [hl]
	and $01
	add $a7
;>     else:
;>         c = 0x98                         # "?"
.mark
;>     wTextArg0[0] = c
	ld [wTextArg0], a
;>     wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save     saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	pop hl
	push hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
;=@save
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;>     wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;>     wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;>     wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;>     wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;>     PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>     wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;>     wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
;>@r0     return entry + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r0
	ld h, a
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(8):
	ld b, $08
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def APListInput()
;@ path: breed/appraiser
;@ Appraise step 2: the egg list. The page is redrawn when it changes. B goes
;@ back to the menu (message 1), A picks the egg and asks about the fee (step
;@ 10).
;@ test: skip draws to VRAM
APListInput::
;>@u old_page = wListPage
	ld de, APListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@u
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdateListCursor(wListCursor, APListCursorPos, 4, wListLength)
	call UpdateListCursor
;> if wListPage != old_page:
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .samePage

;>     EADrawPage()
	call EADrawPage
;>     EADrawGenders()
	call EADrawGenders

.samePage
;> if wJoyPressed & 0x02:                    # B: back to the menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;=@ret
	jr .done

.notB
;> elif wJoyPressed & 0x01:                  # A: this egg
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep = 0x0A
	ld a, $0a
	ld [wMenuSubStep], a
;>     wConfirmChoice = 0
	ld a, $00
	ld [wConfirmChoice], a
;>     wConfirmChoice2 = 1
	ld a, $01
	ld [wConfirmChoice2], a

.done
;>@ret return
	ret


;@ path: breed/appraiser
;@ Cursor table of the appraiser's egg list (tile offsets row * 32 + column):
;@ the page marker, then the 4 rows; $FFFF ends.
APListCursorPos::
	dw $0192, $00a8, $00e8, $0128, $0168, $ffff

;@ def APPay()
;@ path: breed/appraiser
;@ Appraise step 3: takes the 20 gold fee and starts the appraisal of the
;@ picked egg (its species name with plus value in wTextArg0, message 6); with
;@ less gold, message $1C and back to the menu (step 9).
;@ test: skip prints messages through other banks
APPay::
;> poor = wGold < 20
	ld a, [wGold]
	sub $14
	ld a, [wGold + 1]
	sbc $00
	ld a, [wGold + 2]
	sbc $00
;> if not poor:
	jr c, .poor

;>     SpendGold(20)
	ld hl, $0014
	ld e, $00
	call SpendGold
;>@m     m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;>     wCurPartyMember = m
	ld [wCurPartyMember], a
;>     CopySystemText(0x0500 | mem[MonsterField(m, wMonRecSpecies)], wTextArg0)
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
;>     AppendPlusValue(mem[MonsterField(m, wMonPlus)], wTextArg0)
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld de, wTextArg0
	call AppendPlusValue
;>     PrintServiceMessage(0x0006)
	ld hl, $0006
	call PrintServiceMessage
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


.poor
;> else:
;>     PrintServiceMessage(0x001C)
	ld hl, $001c
	call PrintServiceMessage
;>     wMenuSubStep = 9
	ld a, $09
	ld [wMenuSubStep], a
	ret


;@ def APJudgeStats()
;@ path: breed/appraiser
;@ Appraise step 4: adds up the egg's HP, MP, attack, defense, agility and
;@ intelligence (stopping early once the sum reaches $1000) and comments on
;@ it: nothing below 120, message 7 below 300, 8 below 600, else 9.
;@ test: skip prints messages through other banks
APJudgeStats::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> m = wCurPartyMember
;> total = mem16[MonsterField(m, wMonHP)]
	ld a, [wCurPartyMember]
	ld hl, wMonHP
	call MonsterField
	ld e, [hl]
	inc hl
	ld d, [hl]
;>@s for stat in (wMonMP, wMonAttack, wMonDefense, wMonAgility, wMonIntelligence):
;>     if total >= 0x1000: break
	ld a, d
	cp $10
	jr nc, .judge

;>@add     total += mem16[MonsterField(m, stat)]
	push de
	ld a, [wCurPartyMember]
	ld hl, wMonMP
	call MonsterField
	pop de
	ld a, e
;=@add
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
;=@s
	ld a, d
	cp $10
	jr nc, .judge

;=@add
	push de
	ld a, [wCurPartyMember]
	ld hl, wMonAttack
	call MonsterField
	pop de
	ld a, e
;=@add
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
;=@s
	ld a, d
	cp $10
	jr nc, .judge

;=@add
	push de
	ld a, [wCurPartyMember]
	ld hl, wMonDefense
	call MonsterField
	pop de
	ld a, e
;=@add
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
;=@s
	ld a, d
	cp $10
	jr nc, .judge

;=@add
	push de
	ld a, [wCurPartyMember]
	ld hl, wMonAgility
	call MonsterField
	pop de
	ld a, e
;=@add
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
;=@s
	ld a, d
	cp $10
	jr nc, .judge

;=@add
	push de
	ld a, [wCurPartyMember]
	ld hl, wMonIntelligence
	call MonsterField
	pop de
	ld a, e
;=@add
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a

.judge
;>@j if total >= 120:
	push de
	ld a, e
	sub $78
	ld e, a
	ld a, d
	sbc $00
;=@j
	ld d, a
	pop de
	jr c, .next

;>@m     if total < 300:
;>         msg = 0x0007
	ld hl, $0007
	push de
	ld a, e
	sub $2c
	ld e, a
;=@m
	ld a, d
	sbc $01
	ld d, a
	pop de
	jr c, .print

;>@m2     elif total < 600:
;>         msg = 0x0008
	ld hl, $0008
	push de
	ld a, e
	sub $58
	ld e, a
;=@m2
	ld a, d
	sbc $02
	ld d, a
	pop de
	jr c, .print

;>     else:
;>         msg = 0x0009
	ld hl, $0009

.print
;>     PrintServiceMessage(msg)
	call PrintServiceMessage

.next
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def APJudgeSkills()
;@ path: breed/appraiser
;@ Appraise step 5: counts the skills the egg can still learn (wMonSkillList,
;@ 25 entries, $FF = none) and comments: nothing below 10, message $0A below
;@ 15, $0B below 20, else $0C.
;@ test: skip prints messages through other banks
APJudgeSkills::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> p = MonsterField(wCurPartyMember, wMonSkillList)
	ld a, [wCurPartyMember]
	ld hl, wMonSkillList
	call MonsterField
;> n = 0
	ld b, $19
	ld c, $00
.loop
;>@c for _ in range(25):
;>     if mem[p] != 0xFF:
	ld a, [hli]
	cp $ff
	jr z, .skip

;>         n += 1
	inc c

.skip
;>     p += 1
;=@c
	dec b
	jr nz, .loop

;> if n >= 10:
	ld a, c
	cp $0a
	jr c, .next

;>     if n < 15:
;>         msg = 0x000A
	ld hl, $000a
	cp $0f
	jr c, .print

;>     elif n < 20:
;>         msg = 0x000B
	ld hl, $000b
	cp $14
	jr c, .print

;>     else:
;>         msg = 0x000C
	ld hl, $000c

.print
;>     PrintServiceMessage(msg)
	call PrintServiceMessage

.next
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def APJudgeGrowth()
;@ path: breed/appraiser
;@ Appraise step 6: comments on the egg's highest level (wMonMaxLevel):
;@ message $0D below 30, $0E below 40, none below 50, $0F below 80, else
;@ $10. Then the resistances are judged (step 15).
;@ test: skip prints messages through other banks
APJudgeGrowth::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> top = mem[MonsterField(wCurPartyMember, wMonMaxLevel)]
	ld a, [wCurPartyMember]
	ld hl, wMonMaxLevel
	call MonsterField
	ld a, [hl]
;> if top < 30:
;>     PrintServiceMessage(0x000D)
	ld hl, $000d
	cp $1e
	jr c, .print

;> elif top < 40:
;>     PrintServiceMessage(0x000E)
	ld hl, $000e
	cp $28
	jr c, .print

;> elif top < 50:
;>     pass                                 # no comment
	cp $32
	jr c, .next

;> elif top < 80:
;>     PrintServiceMessage(0x000F)
	ld hl, $000f
	cp $50
	jr c, .print

;> else:
;>     PrintServiceMessage(0x0010)
	ld hl, $0010

.print
	call PrintServiceMessage

.next
;> wMenuSubStep = 0x0F
	ld a, $0f
	ld [wMenuSubStep], a
	ret


;@ def APTellGender()
;@ path: breed/appraiser
;@ Appraise step 7: tells the egg's gender (message $13 or $14).
;@ test: skip prints messages through other banks
APTellGender::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> gender = mem[MonsterField(wCurPartyMember, wMonGender)] & 1
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
;> PrintServiceMessage(0x0014 if gender else 0x0013)
	ld hl, $0013
	and $01
	jr z, .print

	ld hl, $0014

.print
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def APMarkAppraised()
;@ path: breed/appraiser
;@ Appraise step 8: the closing message ($15); the egg's gender is now known
;@ (wMonEgg = 2), so lists show its gender mark.
;@ test: skip prints messages through other banks
APMarkAppraised::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PrintServiceMessage(0x0015)
	ld hl, $0015
	call PrintServiceMessage
;> mem[MonsterField(wCurPartyMember, wMonEgg)] = 2
	ld a, [wCurPartyMember]
	ld hl, wMonEgg
	call MonsterField
	ld [hl], $02
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def APBackToMenu()
;@ path: breed/appraiser
;@ Appraise step 9: goes back to the appraiser menu (message 1).
;@ test: skip prints messages through other banks
APBackToMenu::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def APAskPay()
;@ path: breed/appraiser
;@ Appraise step 10: asks whether to pay the fee (message 5).
;@ test: skip prints a message through other banks
APAskPay::
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def APOpenPayConfirm()
;@ path: breed/appraiser
;@ Appraise step 11: once the message is out, opens the two-choice window.
;@ test: skip draws to VRAM
APOpenPayConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> DrawAPListScreen()
	call DrawAPListScreen
;> DrawAPPayConfirm()
	call DrawAPPayConfirm
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawAPPayConfirm()
;@ path: breed/appraiser
;@ Draws the two-choice window (view the egg / appraise it) with its cursor
;@ wConfirmChoice into wTilemapBuffer.
;@ test: skip draws from tables
DrawAPPayConfirm::
;> DrawWindowLayout0A(LayoutAppraiseConfirm)
	ld de, LayoutAppraiseConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wConfirmChoice, APPayConfirmCursorPos)
	ld de, APPayConfirmCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt0A
	ret


;@ def APPayConfirmInput()
;@ path: breed/appraiser
;@ Appraise step 12: the two-choice window. B goes back to the list (step 2).
;@ The first choice opens the status screen (step 13), the second pays and
;@ appraises (step 3).
;@ test: skip prints messages through other banks
APPayConfirmInput::
;> UpdateMenuCursor0A(wConfirmChoice, APPayConfirmCursorPos, 2)
	ld de, APPayConfirmCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     DrawAPListScreen()
	call DrawAPListScreen
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer
;>     PrintServiceMessage(0x0003)
	ld hl, $0003
	call PrintServiceMessage
;>     wMenuSubStep = 2
	ld a, $02
	ld [wMenuSubStep], a
;=@ret
	jr .done

.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wConfirmChoice != 0x81:                # first choice: the status screen
	ld a, [wConfirmChoice]
	cp $81
	jr z, .pay

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;=@ret
	jr .done

.pay
;> else:
;>     wMenuSubStep = 3
	ld a, $03
	ld [wMenuSubStep], a
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a

.done
;>@ret return
	ret


;@ path: breed/appraiser
;@ Cursor positions (tile offsets) of the two-choice window LayoutAppraiseConfirm; $FFFF ends.
APPayConfirmCursorPos::
	dw $0121, $0161, $ffff

;@ def APOpenStatus()
;@ path: breed/appraiser
;@ Appraise step 13: opens the monster status screen (bank $07) for the egg
;@ under the cursor.
;@ test: skip calls another bank
APOpenStatus::
;>@m wCurPartyMember = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
	ret


;@ def APReturnFromStatus()
;@ path: breed/appraiser
;@ Appraise step 14: after the status screen, reloads the graphics, rebuilds
;@ and redraws the egg list and reopens the two-choice window (step 11).
;@ test: skip draws to VRAM
APReturnFromStatus::
;> DecompressVRAM(0x2E, 0x13, 0x8800)     # window graphics
	ld de, $2e13
	ld hl, $8800
	call DecompressVRAM
;> EACountEggs()
	call EACountEggs
;> EABuildEggList()
	call EABuildEggList
;> EADrawPage()
	call EADrawPage
;> EADrawGenders()
	call EADrawGenders
;> PrintServiceMessage(0x0005)
	ld hl, $0005
	call PrintServiceMessage
;> DrawAPListScreen()
	call DrawAPListScreen
;> DrawAPPayConfirm()
	call DrawAPPayConfirm
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep = 0x0B
	ld a, $0b
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def APJudgeResistances()
;@ path: breed/appraiser
;@ Appraise step 15: compares the sum of the egg's 27 resistances with the
;@ sum of its species' standard ones (GetMonsterStats): message $11 when it
;@ is lower, $12 when higher, none when equal. Then the gender is told (step
;@ 7).
;@ test: skip calls another bank
APJudgeResistances::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wMonSpecies = mem[MonsterField(wCurPartyMember, wMonRecSpecies)]
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> standard = SumResistances(wMonResistances, 0)
	ld hl, wMonResistances
	xor a
	call SumResistances
;> own = SumResistances(MonsterField(wCurPartyMember, wMonsters + 0x68), 0)   # the egg's own resistances
	push af
	ld a, [wCurPartyMember]
	ld hl, $cb29
	call MonsterField
	xor a
	call SumResistances
;> if own != standard:
	pop bc
	cp b
	jr z, .next

;>     PrintServiceMessage(0x0011 if own < standard else 0x0012)
	ld hl, $0011
	jr c, .print

	ld hl, $0012

.print
	call PrintServiceMessage

.next
;> wMenuSubStep = 7
	ld a, $07
	ld [wMenuSubStep], a
	ret


;@ def SumResistances(p: hl, sum: a) -> a
;@ path: breed/appraiser
;@ Adds the 27 resistance bytes at `p` to `sum` (8 bits, wrapping).
;@ test: hl = 0xC100
SumResistances::
;> for i in range(27):
;>     sum = (sum + mem[p + i]) & 0xFF
	ld b, $1b
.loop
	add [hl]
	inc hl
	dec b
	jr nz, .loop

;> return sum
	ret


;@ def GenderFlow()
;@ path: breed/appraiser
;@ The change-gender entry of the egg appraiser: for 50 gold per plus value
;@ + 100 (at most 99,999) an egg's gender is swapped. Runs its steps, one
;@ per frame, picked by wMenuSubStep.
;@ test: skip jumps through a table
GenderFlow::
;> GenderFlowSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: breed/appraiser
;@ Steps of the egg gender change (RST $00 table indexed by wMenuSubStep).
GenderFlowSteps::
	dw GCListEggs
	dw GCShowList
	dw GCListInput
	dw GCQuotePrice
	dw GCOpenConfirm
	dw GCConfirmInput
	dw GCPay
	dw GCDone
	dw GCBackToMenu
	dw GCOpenStatus
	dw GCReturnFromStatus

;@ def GCListEggs()
;@ path: breed/appraiser
;@ Gender step 0: lists the eggs; with none, says so (message $17) and goes
;@ back to the menu, else asks which one (message $16).
;@ test: skip prints a message through other banks
GCListEggs::
;> if EACountEggs() == 0:
	call EACountEggs
	or a
	jr nz, .haveEggs

;>     PrintServiceMessage(0x0017)
	ld hl, $0017
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;>     return
	ret


.haveEggs
;> EABuildEggList()
	call EABuildEggList
;> PrintServiceMessage(0x0016)
	ld hl, $0016
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def GCShowList()
;@ path: breed/appraiser
;@ Gender step 1: once the message is out, draws and shows the egg list.
;@ test: skip draws to VRAM
GCShowList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> EADrawPage()
	call EADrawPage
;> EADrawGenders()
	call EADrawGenders
;> DrawGCListScreen()
	call DrawGCListScreen
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawGCListScreen()
;@ path: breed/appraiser
;@ Draws the menu with the gold and the egg list window with its cursor into
;@ wTilemapBuffer.
;@ test: skip draws from tables
DrawGCListScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawEAMenu()
	call DrawEAMenu
;> DrawWindowLayout0A(LayoutEggList2)
	ld de, LayoutEggList2
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;>@k5 DrawListCursor(wListCursor, GCListCursorPos, 4, wListLength)
	ld de, GCListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;=@k5
	ret


;@ def GCListInput()
;@ path: breed/appraiser
;@ Gender step 2: the egg list. The page is redrawn when it changes. B goes
;@ back to the menu (message 1), A picks the egg.
;@ test: skip draws to VRAM
GCListInput::
;>@u old_page = wListPage
	ld de, GCListCursorPos
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
;=@u
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> UpdateListCursor(wListCursor, GCListCursorPos, 4, wListLength)
	call UpdateListCursor
;> if wListPage != old_page:
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .samePage

;>     EADrawPage()
	call EADrawPage
;>     EADrawGenders()
	call EADrawGenders

.samePage
;> if wJoyPressed & 0x02:                    # B: back to the menu
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;=@ret
	jr .done

.notB
;> elif wJoyPressed & 0x01:                  # A: this egg
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice2 = 1
	ld a, $01
	ld [wConfirmChoice2], a

.done
;>@ret return
	ret


;@ path: breed/appraiser
;@ Cursor table of the gender change egg list (tile offsets row * 32 +
;@ column): the page marker, then the 4 rows; $FFFF ends.
GCListCursorPos::
	dw $0192, $00a8, $00e8, $0128, $0168, $ffff

;@ def GCQuotePrice()
;@ path: breed/appraiser
;@ Gender step 3: works out the price for the picked egg, plus value * 50 +
;@ 100, at most 99,999 (24 bits, kept in $C8E4-$C8E6), writes it into
;@ wTextArg0 and asks (message $18).
;@ test: skip prints a message through other banks
GCQuotePrice::
;>@m m = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@m
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
;> wCurPartyMember = m
	ld [wCurPartyMember], a
;>@pr price = Multiply(mem[MonsterField(m, wMonPlus)], 50) + 100
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld c, [hl]
	ld a, $32
	call Multiply
;=@pr
	ld a, l
	add $64
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>@cap if price >= 99999:
	ld e, $00
	ld a, l
	sub $9f
	ld a, h
	sbc $86
	ld a, e
;=@cap
	sbc $01
	jr c, .ok

;>     price = 99999
	ld hl, $869f
	ld e, $01

.ok
;> mem16[hNumber] = price & 0xFFFF        # 24 bits
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
;> mem[hNumber + 2] = price >> 16
	ld a, e
	ldh [hNumber + 2], a
;> mem16[wListCursor2] = price & 0xFFFF   # $C8E4-$C8E6
	ld a, l
	ld [wListCursor2], a
	ld a, h
	ld [wListPage2], a
;> mem[wListCursor2 + 2] = price >> 16
	ld a, e
	ld [wListCursor2 + 2], a
;> Number24ToDecimal(wTextArg0)
	ld hl, wTextArg0
	call Number24ToDecimal
;> PrintServiceMessage(0x0018)
	ld hl, $0018
	call PrintServiceMessage
;> wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def GCOpenConfirm()
;@ path: breed/appraiser
;@ Gender step 4: once the message is out, opens the yes/no window.
;@ test: skip draws to VRAM
GCOpenConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> DrawGCConfirm()
	call DrawGCConfirm
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawGCConfirm()
;@ path: breed/appraiser
;@ Draws the two-choice window with its cursor wMenuChoice3 into wTilemapBuffer.
;@ test: skip draws from tables
DrawGCConfirm::
;> DrawWindowLayout0A(LayoutAppraiseConfirm)
	ld de, LayoutAppraiseConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice3, GCConfirmCursorPos)
	ld de, GCConfirmCursorPos
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
	ret


;@ def GCConfirmInput()
;@ path: breed/appraiser
;@ Gender step 5: the two-choice window. B goes back to the list. The first
;@ choice opens the status screen (step 9), the second pays (step 6).
;@ test: skip prints messages through other banks
GCConfirmInput::
;> UpdateMenuCursor0A(wMenuChoice3, GCConfirmCursorPos, 2)
	ld de, GCConfirmCursorPos
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     DrawGCListScreen()
	call DrawGCListScreen
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer
;>     PrintServiceMessage(0x0016)
	ld hl, $0016
	call PrintServiceMessage
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
;=@ret
	jr .done

.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wMenuChoice3 != 0x81:                  # first choice: the status screen
	ld a, [wMenuChoice3]
	cp $81
	jr z, .pay

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep = 9
	ld a, $09
	ld [wMenuSubStep], a
;=@ret
	jr .done

.pay
;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ path: breed/appraiser
;@ Cursor positions (tile offsets) of the two-choice window LayoutAppraiseConfirm; $FFFF ends.
GCConfirmCursorPos::
	dw $0121, $0161, $ffff

;@ def GCPay()
;@ path: breed/appraiser
;@ Gender step 6: with enough gold pays the price and swaps the egg's gender
;@ (message $1A, then step 7); else message $1C and back to the menu (step 8).
;@ test: skip prints messages through other banks
GCPay::
;>@g if mem16[wGold] | mem[wGold + 2] << 16 < mem16[wListCursor2] | mem[wListCursor2 + 2] << 16:
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
	jr nc, .pay

;>     PrintServiceMessage(0x001C)          # not enough gold
	ld hl, $001c
	call PrintServiceMessage
;>     wMenuSubStep += 2
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
;=@ret
	jr .done

.pay
;> else:
;>@sp     SpendGold(mem16[wListCursor2] | mem[wListCursor2 + 2] << 16)
	ld a, [wListCursor2]
	ld l, a
	ld a, [wListPage2]
	ld h, a
	ld a, [wListCursor2 + 2]
	ld e, a
;=@sp
	call SpendGold
;>     mem[MonsterField(wCurPartyMember, wMonGender)] ^= 1
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	xor $01
	ld [hl], a
;>     PrintServiceMessage(0x001A)
	ld hl, $001a
	call PrintServiceMessage
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ def GCDone()
;@ path: breed/appraiser
;@ Gender step 7: the closing message ($1B).
;@ test: skip prints a message through other banks
GCDone::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PrintServiceMessage(0x001B)
	ld hl, $001b
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def GCBackToMenu()
;@ path: breed/appraiser
;@ Gender step 8: goes back to the appraiser menu (message 1).
;@ test: skip prints a message through other banks
GCBackToMenu::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> PrintServiceMessage(0x0001)
	ld hl, $0001
	call PrintServiceMessage
;> wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
	ret


;@ def GCOpenStatus()
;@ path: breed/appraiser
;@ Gender step 9: opens the monster status screen (bank $07) for the picked
;@ egg.
;@ test: skip calls another bank
GCOpenStatus::
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
	ret


;@ def GCReturnFromStatus()
;@ path: breed/appraiser
;@ Gender step 10: after the status screen, reloads the graphics, rebuilds
;@ and redraws the egg list, repeats the price question and reopens the
;@ two-choice window (step 5).
;@ test: skip draws to VRAM
GCReturnFromStatus::
;> DecompressVRAM(0x2E, 0x13, 0x8800)     # window graphics
	ld de, $2e13
	ld hl, $8800
	call DecompressVRAM
;> EACountEggs()
	call EACountEggs
;> EABuildEggList()
	call EABuildEggList
;> EADrawPage()
	call EADrawPage
;> EADrawGenders()
	call EADrawGenders
;> mem16[hNumber] = mem16[wListCursor2]   # the 24-bit price
	ld a, [wListCursor2]
	ldh [hNumber], a
	ld a, [wListPage2]
	ldh [hNumber + 1], a
;> mem[hNumber + 2] = mem[wListCursor2 + 2]
	ld a, [wListCursor2 + 2]
	ldh [hNumber + 2], a
;> Number24ToDecimal(wTextArg0)
	ld hl, wTextArg0
	call Number24ToDecimal
;> PrintServiceMessage(0x0018)
	ld hl, $0018
	call PrintServiceMessage
;> DrawGCListScreen()
	call DrawGCListScreen
;> DrawGCConfirm()
	call DrawGCConfirm
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def JoinPartyScreen()
;@ path: breed/join
;@ Service screen 11: a monster that has just hatched (wLeaderSlot) may join
;@ the party. A yes/no menu; with a full party one party monster goes to the
;@ farm in its place. One step per frame, picked by wMenuStep. The answer is
;@ left in wTextChoice (0 yes, 1 no) for the script.
;@ test: skip jumps through a table
JoinPartyScreen::
;> JoinPartySteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: breed/join
;@ Steps of the join-party screen (RST $00 table indexed by wMenuStep).
JoinPartySteps::
	dw JPInit
	dw JPOpenMenu
	dw JPMenuInput
	dw JPRunChoice
	dw JPClose

;@ def JPInit()
;@ path: breed/join
;@ Step 0: lines the scroll up with whole tiles, clears the menu cursors,
;@ works out the BG map address of the visible screen, shows the field with
;@ the message box frame, loads the window graphics (bank $2E entry $12) and
;@ sets the answer to yes.
;@ test: skip decompresses into VRAM
JPInit::
;> RoundToTile(hScrollX)
	ld hl, hScrollX
	call RoundToTile
;> RoundToTile(hScrollY)
	ld hl, hScrollY
	call RoundToTile
;> FillMemory(wMenuChoice, 8, 0)            # the menu cursors $C8DA-$C8E1
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;>@map a = (hScrollY >> 3) * 32 + (hScrollX >> 3)
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [hScrollX]
;=@map
	rrca
	rrca
	rrca
	add l
	ld l, a
;>@bg wWindowBgMap = 0x9800 | (a & 0x03FF)
	ld a, h
	adc $98
	ld h, a
	ld a, h
	and $03
	or $98
;=@bg
	ld h, a
	ld a, l
	ld [wWindowBgMap], a
	ld a, h
	ld [wWindowBgMap + 1], a
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> DecompressVRAM(0x2E, 0x12, 0x8800)     # window graphics
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> hSpriteBGTile = 0x40
	ld a, $40
	ldh [hSpriteBGTile], a
;> wTextChoice = 0
	ld a, $00
	ld [wTextChoice], a
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def JPOpenMenu()
;@ path: breed/join
;@ Step 1: draws the yes/no menu and shows it.
;@ test: skip draws to VRAM
JPOpenMenu::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawJPMenu()
	call DrawJPMenu
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def DrawJPMenu()
;@ path: breed/join
;@ Draws the yes/no window and the message box frame into wTilemapBuffer,
;@ cursor on wMenuChoice (used here as the menu cursor).
;@ test: skip draws from tables
DrawJPMenu::
;> DrawWindowLayout0A(LayoutYesNo)
	ld de, LayoutYesNo
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice, JPMenuCursorPos)
	ld de, JPMenuCursorPos
	ld a, [wMenuChoice]
	call DrawCursorAt0A
	ret


;@ def JPMenuInput()
;@ path: breed/join
;@ Step 2: yes/no. B or Start declines; A chooses (bit 7 of the cursor is
;@ set, the choice kept in wItemsHandedIn) and clears the list cursors.
;@ test: skip calls the cursor drawing
JPMenuInput::
;> UpdateMenuCursor0A(wMenuChoice, JPMenuCursorPos, 2)
	ld de, JPMenuCursorPos
	ld hl, wMenuChoice
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x0A:                    # B or Start
	ld a, [wJoyPressed]
	and $0a
	jr z, .notCancel

;>     JPDecline()
;>     return
	jr JPDecline

.notCancel
;> if wJoyPressed & 0x01:                    # A
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
;>     wItemsHandedIn = wMenuChoice           # the menu entry to run
	ld a, [hl]
	ld [wItemsHandedIn], a
;>     FillMemory(wMenuChoice2, 7, 0)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
;>     FillMemory(wListCursor, 8, 0)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr .done

.done
	ret


;@ path: breed/join
;@ Cursor positions (tile offsets) of the yes/no window LayoutYesNo; $FFFF ends.
JPMenuCursorPos::
	dw $012f, $016f, $ffff

;@ def JPRunChoice()
;@ path: breed/join
;@ Step 3: runs the chosen entry, one step per frame.
;@ test: skip jumps through a table
JPRunChoice::
;> JPChoices[wItemsHandedIn & 0x7F]()
	ld a, [wItemsHandedIn]
	rst $00

;@ path: breed/join
;@ The two entries (RST $00 table): yes (join), no.
JPChoices::
	dw JoinFlow
	dw JPDecline

;@ def JPDecline()
;@ path: breed/join
;@ The no entry (and B): once the message is out, answers no
;@ (wTextChoice = 1) and closes.
;@ test: skip draws to VRAM and calls another bank
JPDecline::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> wTextChoice = 1
	ld a, $01
	ld [wTextChoice], a
;> JPClose()

;@ def JPClose()
;@ path: breed/join
;@ Step 4: puts the field's tiles back, ends the service screen (wFieldFlags
;@ bit 4, and bit 0 so the script goes on) and reloads the party sprites.
;@ test: skip draws to VRAM and calls another bank
JPClose::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> hSpriteClip = 0x80
	ld a, $80
	ldh [hSpriteClip], a
;> wFieldFlags = (wFieldFlags & ~0x10) | 0x01
	ld hl, wFieldFlags
	res 4, [hl]
	set 0, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


;@ def JoinFlow()
;@ path: breed/join
;@ The yes entry: runs its steps, one per frame, picked by wMenuSubStep.
;@ test: skip jumps through a table
JoinFlow::
;> JoinFlowSteps[wMenuSubStep]()
	ld a, [wMenuSubStep]
	rst $00

;@ path: breed/join
;@ Steps of the yes entry (RST $00 table indexed by wMenuSubStep).
JoinFlowSteps::
	dw JFAddToParty
	dw JFShowList
	dw JFListInput
	dw JFAskConfirm
	dw JFOpenConfirm
	dw JFConfirmInput
	dw JFSendToFarm
	dw JFRebuildParty
	dw JFOpenStatus
	dw JFReturnFromStatus
	dw JFFinish

;@ def JFAddToParty()
;@ path: breed/join
;@ Join step 0: with room in the party the new monster (wLeaderSlot) joins at
;@ the end (message $1F, step 10). With three party monsters the list of the
;@ party plus the new one is built and the player is asked which one goes to
;@ the farm (message $19).
;@ test: skip prints a message through other banks
JFAddToParty::
;> if wPartyCount != 3:
	ld a, [wPartyCount]
	cp $03
	jr z, .full

;>     wPartyCount += 1
	inc a
	ld [wPartyCount], a
;>@p     wParty[wPartyCount - 1] = wLeaderSlot
	ld hl, wPartyCount
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@p
	ld a, [wLeaderSlot]
	ld [hl], a
;>     PrintServiceMessage(0x001F)
	ld hl, $001f
	call PrintServiceMessage
;>     wMenuSubStep = 0x0A
	ld a, $0a
	ld [wMenuSubStep], a
;>     return
	ret


.full
;> JFCountChoices()
	call JFCountChoices
;> JFBuildList()
	call JFBuildList
;> PrintServiceMessage(0x0019)
	ld hl, $0019
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def JFCountChoices()
;@ path: breed/join
;@ The list has the party monsters and the new one: wListLength =
;@ wPartyCount + 1.
;@ test: wPartyCount = rand(0, 3)
JFCountChoices::
;> wListLength = wPartyCount + 1
	ld a, [wPartyCount]
	inc a
	ld [wListLength], a
	ret


;@ def JFBuildList()
;@ path: breed/join
;@ Builds the 20-byte list at wSceneObjects: the party slots (up to the first
;@ $FF), then the new monster wLeaderSlot; $FF fills the rest.
;@ test: skip fills memory through a helper
JFBuildList::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = wSceneObjects
	ld hl, wSceneObjects
;> for i in range(3):
;>@pa     if wParty[i] == 0xFF: break
	ld a, [wParty]
	cp $ff
	jr z, .new

;>@pi     mem[p] = wParty[i]; p += 1
	ld [hli], a
;=@pa
	ld a, [wParty + 1]
	cp $ff
	jr z, .new

;=@pi
	ld [hli], a
;=@pa
	ld a, [wParty + 2]
	cp $ff
	jr z, .new

;=@pi
	ld [hli], a

.new
;> mem[p] = wLeaderSlot
	ld a, [wLeaderSlot]
	ld [hl], a
	ret


;@ def JFShowList()
;@ path: breed/join
;@ Join step 1: once the message is out, draws the list.
;@ test: skip draws to VRAM
JFShowList::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> JFDrawCursorMonster()
	call JFDrawCursorMonster
;> JFDrawNames()
	call JFDrawNames
;> DrawJFListScreen()
	call DrawJFListScreen
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawJFListScreen()
;@ path: breed/join
;@ Draws the yes/no menu, the monster list and the info window with the
;@ level of the monster under the cursor (wMenuChoice2), and shows it.
;@ test: skip draws to VRAM
DrawJFListScreen::
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawJPMenu()
	call DrawJPMenu
;> DrawWindowLayout0A(LayoutMonsterList)
	ld de, LayoutMonsterList
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutMonsterInfo)
	ld de, LayoutMonsterInfo
	call DrawWindowLayout0A
;> JFDrawLevel()
	call JFDrawLevel
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wMenuChoice2, JFListCursorPos)
	ld de, JFListCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def JFDrawNames()
;@ path: breed/join
;@ Draws the names of the 4 list entries into the tiles from $9610 on (4
;@ tiles each).
;@ test: skip draws to VRAM
JFDrawNames::
;> entry = wSceneObjects
	ld de, wSceneObjects
;> tiles = 0x9610
	ld hl, $9610
;> for _ in range(4):
;>     entry, tiles = DrawNameEntry2(entry, tiles)
	call DrawNameEntry2
	call DrawNameEntry2
	call DrawNameEntry2

;@ def DrawNameEntry2(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/join
;@ Draws the name of list entry `entry` into 4 tiles at `tiles` (4 tiles of
;@ plain colour 1 for an empty entry, $FF). A copy of DrawNameEntry.
;@ test: skip draws to VRAM
DrawNameEntry2::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>@rn     RenderNameTiles(tiles, MonsterField(m, wMonName))
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
;=@rn
	push hl
	call RenderNameTiles
	pop hl
;>@r0     return entry + 1, tiles + 0x40
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r0
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(32):
	ld b, $20
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def JFDrawLevel()
;@ path: breed/join
;@ Writes the level of the list entry under the cursor (wMenuChoice2) into
;@ wTilemapBuffer ("Lv" tile $DE at row 6, column 10, then the digits) and a
;@ party mark $E3 at column 18 when it is in the party.
;@ test: skip draws from tables
JFDrawLevel::
;> m = wSceneObjects[wMenuChoice2 & 0x7F]
	ld a, [wMenuChoice2]
	and $7f
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
;=@m
	adc d
	ld d, a
	ld a, [de]
;>@m level = mem[MonsterField(m, wMonLevel)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = OffsetToTilemapBuffer(0x00CA)
	ld hl, $00ca
	call OffsetToTilemapBuffer
;> mem[p] = 0xDE                         # "Lv"
	ld a, $de
	ld [hli], a
;> DrawTwoDigits0A(level, p + 1)
	call DrawTwoDigits0A
;> if mem[MonsterField(m, wMonsters)] != 2:
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
;>     return
	ret nz

;> mem[OffsetToTilemapBuffer(0x00D2)] = 0xE3
	ld hl, $00d2
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


;@ def JFDrawCursorMonster()
;@ path: breed/join
;@ Draws the name of the list entry under the cursor (wMenuChoice2) into
;@ tiles $9710 and its gender mark into tile $9750.
;@ test: skip draws to VRAM
JFDrawCursorMonster::
;> entry = wSceneObjects + (wMenuChoice2 & 0x7F); m = mem[entry]
	ld a, [wMenuChoice2]
	and $7f
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
;=@e
	adc d
	ld d, a
	ld a, [de]
;>@e DrawNameEntry3(entry, 0x9710)
	push af
	ld hl, $9710
	call DrawNameEntry3
;>@k6 DrawGenderTile2(mem[MonsterField(m, wMonGender)], 0x9750)
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9750
	call DrawGenderTile2
;=@k6
	ret


;@ def DrawGenderTile2(gender: a, tiles: hl)
;@ path: breed/join
;@ Draws the gender mark of `gender` (bit 0: $A7 or $A8) into the letter tile
;@ at VRAM `tiles`. A copy of DrawGenderTile.
;@ test: skip calls a routine in another bank
DrawGenderTile2::
;> wTextArg0[0] = 0xA7 + (gender & 1)
	and $01
	add $a7
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@save saved = (wTextTiles, wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
;=@save
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 1
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 0x02
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0x00
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved[0]
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = saved[1]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved[2]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawNameEntry3(entry: de, tiles: hl) -> (de, hl)
;@ path: breed/join
;@ Draws the name of list entry `entry` into 4 tiles at `tiles` (4 tiles of
;@ plain colour 1 for an empty entry, $FF). A copy of DrawNameEntry.
;@ test: skip draws to VRAM
DrawNameEntry3::
;> m = mem[entry]
	push de
	push hl
	ld a, [de]
;> if m != 0xFF:
	cp $ff
	jr z, .empty

;>@rn     RenderNameTiles(tiles, MonsterField(m, wMonName))
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
;=@rn
	push hl
	call RenderNameTiles
	pop hl
;>@r0     return entry + 1, tiles + 0x40
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r0
	pop de
	inc de
	ret


.empty
;>@cl for _ in range(32):
	ld b, $20
.clear
;>     WriteVRAMInc(tiles, 0xFF)
;>     WriteVRAMInc(tiles + 1, 0x00)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@cl
	dec b
	jr nz, .clear

;>@r1 return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r1
	ld h, a
	pop de
	inc de
	ret


;@ def JFListInput()
;@ path: breed/join
;@ Join step 2: picks the monster that goes to the farm (cursor wMenuChoice2,
;@ up and down). B gives up: the new monster goes to the farm itself
;@ (message $18 with its name, back to the yes/no menu); A picks the monster
;@ under the cursor.
;@ test: skip draws to VRAM
JFListInput::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> old = wMenuChoice2
	ld de, JFListCursorPos
	ld hl, wMenuChoice2
	ld a, [wListLength]
	ld b, a
	ld a, [hl]
	push af
;> UpdateMenuCursor0A(wMenuChoice2, JFListCursorPos, wListLength)
	call UpdateMenuCursor0A
;>@r if wMenuChoice2 & 0x7F != old & 0x7F:
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
;=@r
	cp b
	jr z, .samePos

;>     JFDrawCursorMonster()
	call JFDrawCursorMonster
;>     DrawWindowLayout0A(LayoutMonsterInfo)
	ld de, LayoutMonsterInfo
	call DrawWindowLayout0A
;>     JFDrawLevel()
	call JFDrawLevel
;>     ShowTilemapBuffer()
	call ShowTilemapBuffer

.samePos
;> if wJoyPressed & 0x02:                    # B: the new monster stays at the farm
	ld a, [wJoyPressed]
	bit 1, a
	jp z, .notB

;>     CopyName(MonsterField(wSceneObjects[3], wMonName), wTextArg0)
	ld a, [wSceneObjects + 3]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@cn
	call CopyName
;>@cn     PrintServiceMessage(0x0018)
	ld hl, $0018
	call PrintServiceMessage
;>     wMenuStep = 1
	ld a, $01
	ld [wMenuStep], a
;=@ret
	jr .done

.notB
;> elif wJoyPressed & 0x01:                  # A: this one goes to the farm
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>@m     m = wSceneObjects[wMenuChoice2 & 0x7F]
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hl]
;>     wCurPartyMember = m
	ld [wCurPartyMember], a
;>     wListKnown = m
	ld [wListKnown], a
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]

.done
;>@ret return
	ret


;@ path: breed/join
;@ Cursor positions (tile offsets) of the 4 rows of the join list; $FFFF ends.
JFListCursorPos::
	dw $00a1, $00e1, $0121, $0161, $ffff

;@ def JFAskConfirm()
;@ path: breed/join
;@ Join step 3: asks about the picked monster (message $1A).
;@ test: skip prints a message through other banks
JFAskConfirm::
;> PrintServiceMessage(0x001A)
	ld hl, $001a
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def JFOpenConfirm()
;@ path: breed/join
;@ Join step 4: once the message is out, opens the two-choice window.
;@ test: skip draws to VRAM
JFOpenConfirm::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> DrawJFConfirm()
	call DrawJFConfirm
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


;@ def DrawJFConfirm()
;@ path: breed/join
;@ Draws the list screen with the two-choice window (view the status / send
;@ it to the farm) on top, cursor on wConfirmChoice, and shows it.
;@ test: skip draws to VRAM
DrawJFConfirm::
;> JFDrawCursorMonster()
	call JFDrawCursorMonster
;> RestoreFieldTilemap()
	call RestoreFieldTilemap
;> DrawJPMenu()
	call DrawJPMenu
;> DrawWindowLayout0A(LayoutMonsterList)
	ld de, LayoutMonsterList
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutMonsterInfo)
	ld de, LayoutMonsterInfo
	call DrawWindowLayout0A
;> JFDrawLevel()
	call JFDrawLevel
;> DrawCursorAt0A(wMenuChoice2, JFListCursorPos)
	ld de, JFListCursorPos
	ld a, [wMenuChoice2]
	call DrawCursorAt0A
;> DrawWindowLayout0A(LayoutConfirm)
	ld de, LayoutConfirm
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wConfirmChoice, JFConfirmCursorPos)
	ld de, JFConfirmCursorPos
	ld a, [wConfirmChoice]
	call DrawCursorAt0A
;> ShowTilemapBuffer()
	call ShowTilemapBuffer
	ret


;@ def JFConfirmInput()
;@ path: breed/join
;@ Join step 5: the two-choice window. B goes back to the list (message $19).
;@ The first choice opens the status screen (step 8), the second sends the
;@ monster to the farm (step 6).
;@ test: skip prints messages through other banks
JFConfirmInput::
;> UpdateMenuCursor0A(wConfirmChoice, JFConfirmCursorPos, 2)
	ld de, JFConfirmCursorPos
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor0A
;> if wJoyPressed & 0x02:                    # B: back to the list
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     DrawJFListScreen()
	call DrawJFListScreen
;>     PrintServiceMessage(0x0019)
	ld hl, $0019
	call PrintServiceMessage
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
;=@ret
	jr .done

.notB
;> elif not wJoyPressed & 0x01:
	ld a, [wJoyPressed]
	bit 0, a
;>     return
	jp z, .done

;> QueueSound(0x59)
	ld a, $59
	call QueueSound
;> if wConfirmChoice != 0x81:                # first choice: the status screen
	ld a, [wConfirmChoice]
	cp $81
	jr z, .send

;>     wStatusViewVars[0] = 0
	xor a
	ld [wStatusViewVars], a
;>     wFieldMenuStep = 0
	ld [wFieldMenuStep], a
;>     wMenuSubStep = 8
	ld a, $08
	ld [wMenuSubStep], a
;=@ret
	jr .done

.send
;> else:
;>     wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a

.done
;>@ret return
	ret


;@ path: breed/join
;@ Cursor positions (tile offsets) of the two-choice window LayoutConfirm; $FFFF ends.
JFConfirmCursorPos::
	dw $002e, $006e, $ffff

;@ def JFSendToFarm()
;@ path: breed/join
;@ Join step 6: puts the picked monster's name into wTextArg0 and says it
;@ goes to the farm (message $1B). An unused `ret` byte follows.
;@ test: skip prints a message through other banks
JFSendToFarm::
;>@m m = wSceneObjects[wMenuChoice2 & 0x7F]
	ld hl, wSceneObjects
	ld a, [wMenuChoice2]
	and $7f
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hl]
;>@cn CopyName(MonsterField(m, wMonName), wTextArg0)
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;> PrintServiceMessage(0x001B)
	ld hl, $001b
	call PrintServiceMessage
;> wMenuSubStep += 1
	ld hl, wMenuSubStep
	inc [hl]
	ret


	db $c9

;@ def JFRebuildParty()
;@ path: breed/join
;@ Join step 7: once the message is out, marks the four listed monsters as
;@ party monsters (state 2), then the picked one as a farm monster (state 1),
;@ rebuilds wParty from the list in order, compacts the records and reloads
;@ the party sprites.
;@ test: skip calls other banks
JFRebuildParty::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;>@f for i in range(4):
;>     mem[MonsterField(wSceneObjects[i], wMonsters)] = 2
	ld a, [wSceneObjects]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
;=@f
	ld a, [wSceneObjects + 1]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
;=@f
	ld a, [wSceneObjects + 2]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
;=@f
	ld a, [wSceneObjects + 3]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
;>@fm mem[MonsterField(wSceneObjects[wMenuChoice2 & 0x7F], wMonsters)] = 1   # to the farm
	ld hl, wSceneObjects
	ld a, [wMenuChoice2]
	and $7f
	add l
	ld l, a
	ld a, $00
;=@fm
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $01
;> p = wParty
	ld de, wParty
;>@ap for i in range(4):
;>     p = AddIfInParty(wSceneObjects[i], p)
	ld a, [wSceneObjects]
	call AddIfInParty
	ld a, [wSceneObjects + 1]
	call AddIfInParty
	ld a, [wSceneObjects + 2]
	call AddIfInParty
;=@ap
	ld a, [wSceneObjects + 3]
	call AddIfInParty
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ def AddIfInParty(m: a, p: de) -> de
;@ path: breed/join
;@ Writes monster slot `m` at `p` and steps on when that monster is a party
;@ monster (state 2).
;@ test: a = rand(0, 19); de = 0xC100; mem[0xCAC1 + a * 0x95] = rand(0, 2)
AddIfInParty::
;> if mem[MonsterField(m, wMonsters)] == 2:
	ld b, a
	push bc
	push de
	ld hl, wMonsters
	call MonsterField
	pop de
;=@i
	pop bc
	ld a, [hl]
	cp $02
	jr nz, .done

;>@i     mem[p] = m
;>     p += 1
	ld a, b
	ld [de], a
	inc de

.done
;> return p
	ret


;@ def JFOpenStatus()
;@ path: breed/join
;@ Join step 8: opens the monster status screen (bank $07) on the list,
;@ starting at the entry under the cursor.
;@ test: skip calls another bank
JFOpenStatus::
;> wViewList = wSceneObjects
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [wViewList + 1], a
;> wViewIndex = wMenuChoice2 & 0x7F
	ld a, [wMenuChoice2]
	and $7f
	ld a, a
	ld [wViewIndex], a
;> wViewCount = wListLength
	ld a, [wListLength]
	ld [wViewCount], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> wMenuOverlay = 1
	ld a, $01
	ld [wMenuOverlay], a
	ret


;@ def JFReturnFromStatus()
;@ path: breed/join
;@ Join step 9: after the status screen, reloads the window graphics and the
;@ names and reopens the two-choice window (step 5).
;@ test: skip draws to VRAM
JFReturnFromStatus::
;> DecompressVRAM(0x2E, 0x12, 0x8800)     # window graphics
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> JFDrawNames()
	call JFDrawNames
;> DrawJFConfirm()
	call DrawJFConfirm
;> PrintServiceMessage(0x001A)
	ld hl, $001a
	call PrintServiceMessage
;> wMenuSubStep = 5
	ld a, $05
	ld [wMenuSubStep], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ def JFFinish()
;@ path: breed/join
;@ Join step 10: once the message is out, compacts the monster records,
;@ reloads the party sprites and closes the screen (wMenuStep 4).
;@ test: skip calls other banks
JFFinish::
;> if wTextState:
	ld a, [wTextState]
	or a
;>     return
	ret nz

;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
	ret


;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 20 x 5 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_6EAC::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 6 x 5 tiles at row 8, column 14: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_6F17::
	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $31, $32, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 6 x 5 tiles at row 8, column 14: the yes/no window at the right (partner breeding menu, save questions, join menu).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutYesNo::
	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 6 x 5 tiles at row 8, column 14: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_6F61::
	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $a7, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 8 x 3 tiles at row 0, column 12: the gold window at the top right (the gold is printed at row 1, column 14).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutGold::
	dw $000c
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 8 x 7 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_6FA3::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 19 x 9 tiles at row 4, column 1: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_6FE4::
	dw $0081
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 4 x 3 tiles at row 10, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_709A::
	dw $0140
	db $fa, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 3 tiles at row 10, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_70AB::
	dw $0140
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e5, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 6 x 5 tiles at row 8, column 0: a yes/no window at the left (breeding house save question).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutYesNoLeft::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 12 x 9 tiles at row 4, column 8: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_70EA::
	dw $0088
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 8 x 5 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_7161::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 5 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_7190::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $a9, $aa, $ab, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 12 x 9 tiles at row 3, column 8: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_71BA::
	dw $0068
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 8 x 3 tiles at row 3, column 12: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_7231::
	dw $006c
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 14 x 3 tiles at row 10, column 6: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_724E::
	dw $0146
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 11 x 13 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_727D::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $92, $98, $9c, $e3, $e0, $9c, $93, $93, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e3, $95, $91, $96, $e0, $9a, $e3, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $91, $94, $d5, $91, $96, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d6, $d5, $e3, $90, $98, $90, $99, $d5, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d6, $97, $d5, $d5, $e3, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $a2, $95, $99, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 9 tiles at row 0, column 13: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_731B::
	dw $000d
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $80, $81, $82, $83, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $85, $86, $87, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $89, $8a, $8b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 11 tiles at row 0, column 13: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_7365::
	dw $000d
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $80, $81, $82, $83, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $85, $86, $87, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $89, $8a, $8b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 9 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_73BF::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $80, $81, $82, $83, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $85, $86, $87, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $89, $8a, $8b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 11 tiles at row 0, column 0: the monster list of the partner breeding screen (4 names of 4 tiles).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutPartnerList::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $80, $81, $82, $83, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $85, $86, $87, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $89, $8a, $8b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 5 tiles at row 0, column 13: the two-choice window (status / take) over the monster lists.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutConfirm::
	dw $000d
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $95, $9d, $93, $9c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 19 x 6 tiles at row 0, column 0: the saved game summary (player name, play time, party with levels).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutSaveFile::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $9e, $90, $d6, $99, $d5, $98, $e4, $a0, $a1, $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $da, $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac, $ad, $ae, $af, $ff, $d8
	db $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 17 x 9 tiles at row 4, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_7507::
	dw $0080
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $84, $e0, $80, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $85, $e0, $81, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $86, $e0, $82, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $87, $e0, $83, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 9 x 7 tiles at row 0, column 0: the breeding house menu (breed, hatch, quit).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutBreedingMenu::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8a, $98, $d5, $d5, $92, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $94, $90, $99, $91, $94, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 11 tiles at row 2, column 0: the pedigree / party list of the breeding house and the join screen.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutMonsterList::
	dw $0040
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $61, $62, $63, $64, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $65, $66, $67, $68, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 11 tiles at row 2, column 0: the mate list of the breeding house.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutMateList::
	dw $0040
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $61, $62, $63, $64, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $65, $66, $67, $68, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 11 x 5 tiles at row 8, column 9: the pair window of the breeding house: both parents with gender and level.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutPairInfo::
	dw $0109
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e0, $71, $72, $73, $74, $75, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 11 x 3 tiles at row 5, column 9: the info line of the join screen: name, gender and level.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutMonsterInfo::
	dw $00a9
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e0, $71, $72, $73, $74, $75, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 11 x 3 tiles at row 10, column 9: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_770B::
	dw $0149
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e0, $65, $66, $67, $68, $69, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 11 x 3 tiles at row 10, column 0: the info line of the partner breeding screen: name, gender and level.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutPartnerInfo::
	dw $0140
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 13 x 9 tiles at row 4, column 7: the egg list of the hatching service (species names and gender marks).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutEggList::
	dw $0087
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $a0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $a1, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $a2, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $a3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 9 x 7 tiles at row 0, column 0: the egg appraiser menu (appraise, change gender, quit).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutAppraiserMenu::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d5, $df, $9f, $de, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $de, $d5, $d6, $d6, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 13 x 9 tiles at row 4, column 7: the egg list of the egg appraiser.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutEggList2::
	dw $0087
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $70, $71, $72, $73, $74, $75, $76, $77, $78, $9b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $9c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9e, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 7 x 7 tiles at row 0, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_789F::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $a9, $aa, $ab, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 10 x 9 tiles at row 4, column 0: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_78D9::
	dw $0080
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $9e, $9f, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $63, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 13 x 9 tiles at row 4, column 7: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_793E::
	dw $0087
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $8c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $8d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $8e, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $8f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 8 x 5 tiles at row 0, column 12: the two-choice window of the hatching service.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutHatchConfirm::
	dw $000c
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $95, $9d, $93, $9c, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 8 x 5 tiles at row 8, column 0: the two-choice window of the egg appraiser.
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
LayoutAppraiseConfirm::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a1, $a7, $a9, $a4, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a4, $a2, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: breed/windows
;@ Window layout for DrawWindowLayout0A, 6 x 5 tiles at row 8, column 14: not drawn by the code of this bank (the other service banks have their own copies of this layout set).
;@ Format: tile position (row * 32 + column), then the tiles row by row, $D8 = next row, $D9 = end.
Layout_0A_7A1C::
	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Unused data: 177 bytes that nothing in the game reads (they look like 8-byte records of
;@ small numbers, left over from development).
UnusedData_0A_7A41::
	db $7a, $00, $2d, $00, $2d, $00, $2d, $00, $2d, $07, $02, $79, $00, $20, $2f, $04
	db $11, $24, $23, $46, $00, $34, $2f, $02, $0e, $08, $02, $79, $00, $20, $2f, $04
	db $11, $14, $12, $35, $00, $16, $2f, $04, $11, $25, $23, $46, $00, $34, $2f, $02
	db $0e, $09, $02, $8a, $00, $50, $2f, $04, $11, $03, $01, $35, $00, $2a, $2f, $04
	db $11, $06, $02, $57, $00, $34, $2f, $04, $11, $11, $02, $13, $00, $40, $2f, $04
	db $11, $10, $13, $01, $10, $16, $2f, $04, $11, $20, $13, $01, $10, $16, $2f, $04
	db $11, $04, $01, $35, $00, $2a, $2f, $04, $11, $19, $02, $8a, $00, $50, $2f, $04
	db $11, $21, $23, $14, $00, $4d, $2f, $06, $02, $22, $23, $14, $00, $4d, $2f, $06
	db $02, $16, $02, $57, $00, $34, $2f, $04, $11, $13, $12, $35, $00, $16, $2f, $04
	db $11, $17, $02, $79, $00, $20, $2f, $04, $11, $18, $02, $79, $00, $20, $2f, $04
	db $11, $02, $02, $13, $00, $40, $2f, $04, $11, $05, $02, $57, $00, $34, $2f, $04
	db $11

;@ path: unused
;@ Unused table of 34 pointers into UnusedRecords_0A_7B36: entry 0 and entries 8-33 point at its
;@ first byte ($FF, nothing), entries 1-7 at its 11-byte records. Nothing reads it.
UnusedPointers_0A_7AF2::
	dw $7b36, $7b37, $7b42, $7b4d, $7b58, $7b63, $7b6e, $7b79
	dw $7b36, $7b36, $7b36, $7b36, $7b36, $7b36, $7b36, $7b36
	dw $7b36, $7b36, $7b36, $7b36, $7b36, $7b36, $7b36, $7b36
	dw $7b36, $7b36, $7b36, $7b36, $7b36, $7b36, $7b36, $7b36
	dw $7b36, $7b36

;@ path: unused
;@ Unused records for UnusedPointers_0A_7AF2: a $FF byte (empty entry), then 11-byte records
;@ (they hold pairs of a bank number and an address, e.g. $4C:$48E4), then zero padding to
;@ the end of the bank.
UnusedRecords_0A_7B36::
	db $ff
	db $4c, $e4, $48, $4c, $1d, $4d, $00, $42, $00, $42, $02
	db $4c, $9e, $4f, $4c, $c7, $53, $00, $40, $00, $40, $02
	db $7b, $51, $44, $43, $6d, $69, $00, $68, $00, $6a, $09
	db $4c, $f3, $5d, $4c, $9c, $62, $00, $4a, $00, $68, $04
	db $4c, $f3, $5d, $4c, $9c, $62, $00, $4e, $00, $4c, $04
	db $4c, $f3, $5d, $43, $ff, $6e, $00, $58, $00, $58, $05
	db $4c, $f3, $5d, $4c, $9c, $62, $00, $4e, $00, $4e, $04
	db $30, $a0, $0e, $00, $40, $00, $40, $c1, $41, $4c, $9e
	db $4f, $4c, $c7, $53, $00, $40, $00, $40, $02, $30, $a0
	db $0e, $f0, $4a, $aa, $40, $c1, $41, $4c, $e4, $48, $4c
	db $a0, $56, $00, $44, $00, $44, $03, $30, $a0, $0e, $4c
	db $54, $31, $41, $c1, $41, $4c, $e4, $48, $43, $4e, $6c
	db $00, $46, $00, $46, $03, $30, $a0, $0e, $d8, $5d, $cf
	db $41, $c1, $41, $4c, $e4, $48, $4c, $31, $59, $00, $48
	db $00, $48, $02, $30, $a0, $0d, $00, $40, $59, $42, $c1
	db $41, $4c, $e4, $48, $4c, $31, $59, $00, $48, $00, $48
	db $02, $30, $a0, $0d, $58, $48, $be, $42, $c1, $41, $4c
	db $f3, $5d, $4c, $9c, $62, $00, $4c, $00, $4a, $04, $30
	db $a0, $0d, $a4, $50, $35, $43, $c1, $41, $4c, $f3, $5d
	db $4c, $9c, $62, $00, $4e, $00, $4c, $04, $30, $a0, $0d
	db $91, $5b, $d2, $43, $c1, $41, $43, $63, $48, $43, $25
	db $51, $00, $50, $00, $50, $03, $30, $a0, $07, $00, $40
	db $9c, $44, $c1, $41, $43, $a4, $4c, $43, $25, $51, $00
	db $52, $00, $52, $06, $30, $a0, $29, $00, $40, $4d, $45
	db $c1, $41, $43, $a4, $4c, $43, $25, $51, $00, $52, $00
	db $52, $06, $30, $a0, $0e, $d4, $66, $cd, $45, $c1, $41
	db $43, $63, $48, $43, $25, $51, $00, $50, $00, $50, $03
	db $30, $a0, $07, $5f, $4c, $75, $46, $c1, $41, $4c, $f3
	db $5d, $4c, $9c, $62, $00, $4e, $00, $4c, $04, $30, $a0
	db $07, $5d, $59, $0c, $47, $c1, $41, $4c, $f3, $5d, $4c
	db $9c, $62, $00, $4e, $00, $4c, $04, $30, $a0, $07, $96
	db $68, $d5, $47, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62
	db $00, $4e, $00, $4c, $04, $30, $a0, $2a, $00, $40, $6c
	db $48, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4e
	db $00, $4e, $04, $30, $a0, $2a, $9a, $48, $f1, $48, $c1
	db $41, $43, $00, $40, $43, $09, $44, $00, $5e, $00, $5e
	db $07, $30, $a0, $2a, $c8, $52, $b0, $49, $c1, $41, $4c
	db $d7, $6b, $4c, $58, $70, $00, $60, $00, $60, $07, $30
	db $a0, $2a, $b8, $64, $85, $4a, $c1, $41, $4c, $d7, $6b
	db $43, $f9, $73, $00, $62, $00, $62, $07, $30, $a0, $2b
	db $00, $40, $81, $4b, $c1, $41, $43, $60, $5b, $43, $b1
	db $5f, $00, $64, $00, $64, $08, $30, $a0, $2b, $30, $4f
	db $10, $4c, $c1, $41, $4c, $d7, $6b, $4c, $58, $70, $00
	db $60, $00, $60, $07, $30, $a0, $2b, $a6, $5b, $ac, $4c
	db $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4a, $00
	db $68, $04, $30, $a0, $2b, $bb, $68, $77, $4d, $c1, $41
	db $7b, $51, $44, $43, $6d, $69, $00, $6c, $00, $6c, $09
	db $30, $a0, $2c, $00, $40, $3e, $4e, $c1, $41, $7b, $51
	db $44, $43, $6d, $69, $00, $6c, $00, $6c, $09, $30, $a0
	db $2c, $af, $4e, $df, $4e, $c1, $41, $7b, $51, $44, $43
	db $6d, $69, $00, $6e, $00, $6e, $09, $30, $a0, $2c, $75
	db $5e, $8a, $4f, $c1, $41, $7b, $51, $44, $43, $6d, $69
	db $00, $6c, $00, $6c, $09, $30, $a0, $2c, $73, $6a, $59
	db $50, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4e
	db $00, $4c, $04, $30, $a0, $2d, $00, $40, $ef, $50, $c1
	db $41, $4c, $e4, $48, $43, $20, $71, $00, $70, $00, $70
	db $02, $30, $a0, $2d, $6d, $51, $c1, $51, $c1, $41, $4c
	db $e4, $48, $7b, $ca, $48, $00, $72, $00, $72, $02, $30
	db $a0, $2d, $14, $5d, $4c, $52, $c1, $41, $4c, $e4, $48
	db $7b, $ca, $48, $00, $72, $00, $72, $02, $30, $a0, $2d
	db $f9, $6a, $05, $53, $c1, $41, $4c, $e4, $48, $7b, $ca
	db $48, $00, $72, $00, $72, $02, $30, $a0, $2e, $00, $40
	db $b1, $53, $c1, $41, $4c, $2d, $65, $4c, $c6, $69, $00
	db $56, $00, $56, $05, $30, $a0, $2e, $80, $4b, $6c, $54
	db $c1, $41, $4c, $2d, $65, $4c, $c6, $69, $00, $56, $00
	db $56, $05, $30, $a0, $2e, $15, $5c, $35, $55, $c1, $41
	db $43, $00, $40, $43, $22, $46, $00, $5e, $00, $5e, $07
	db $30, $a0, $2e, $6b, $65, $01, $56, $c1, $41, $4c, $2d
	db $65, $4c, $c6, $69, $00, $56, $00, $56, $05, $30, $a0
	db $3a, $00, $40, $bc, $56, $c1, $41, $4c, $2d, $65, $4c
	db $c6, $69, $00, $56, $00, $56, $05, $30, $a0, $29, $5e
	db $65, $68, $57, $c1, $41, $43, $a4, $4c, $43, $25, $51
	db $00, $52, $00, $52, $03, $30, $a0, $3a, $25, $4d, $26
	db $58, $c1, $41, $43, $06, $54, $43, $a7, $58, $00, $5a
	db $00, $5a, $0a, $30, $a0, $3a, $d6, $62, $cd, $58, $c1
	db $41, $43, $06, $54, $43, $a7, $58, $00, $5a, $00, $5a
	db $0a, $30, $a0, $1d, $00, $40, $63, $59, $c1, $41, $43
	db $06, $54, $43, $a7, $58, $00, $5a, $00, $5a, $0a, $30
	db $a0, $29, $8a, $56, $39, $5a, $c1, $41, $43, $06, $54
	db $43, $a7, $58, $00, $5a, $00, $5a, $0a, $30, $a0, $1d
	db $2e, $56, $d3, $5a, $c1, $41, $7b, $00, $40, $43, $e4
	db $66, $00, $54, $00, $54, $0b, $30, $a0, $1d, $59, $63
	db $89, $5b, $c1, $41, $7b, $00, $40, $43, $e4, $66, $00
	db $54, $00, $54, $0b, $30, $a0, $1e, $00, $40, $5d, $5c
	db $c1, $41, $7b, $00, $40, $43, $e4, $66, $00, $54, $00
	db $54, $0b, $30, $a0, $1e, $3b, $49, $36, $5d, $c1, $41
	db $7b, $00, $40, $43, $e4, $66, $00, $54, $00, $54, $0b
	db $30, $a0, $1e, $64, $51, $d0, $5d, $c1, $41, $7b, $00
	db $40, $43, $e4, $66, $00, $54, $00, $54, $0b, $30, $a0
	db $1e, $0f, $5b, $7d, $5e, $c1, $41, $4c, $d7, $6b, $43
	db $f9, $73, $00, $62, $00, $62, $07, $30, $a0, $1f, $00
	db $40, $60, $5f, $c1, $41, $43, $60, $5b, $43, $b1, $5f
	db $00, $64, $00, $64, $08, $30, $a0, $1f, $a5, $4f, $13
	db $60, $c1, $41, $43, $60, $5b, $43, $b1, $5f, $00, $66
	db $00, $66, $08, $30, $a0, $1f, $e7, $5e, $d6, $60, $c1
	db $41, $43, $60, $5b, $43, $b1, $5f, $00, $64, $00, $64
	db $08, $30, $a0, $1f, $07, $6d, $67, $61, $c1, $41, $43
	db $60, $5b, $43, $b1, $5f, $00, $64, $00, $64, $08, $30
	db $a0, $29, $57, $49, $09, $62, $c1, $41, $7b, $5b, $4b
	db $7b, $7c, $4f, $00, $5c, $00, $5c, $0b
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
