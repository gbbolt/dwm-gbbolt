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
;@ test: hl = 0xC100
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
;>@c1 copy(wSavedTilemap, wTilemapBuffer, 0x200)
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
;>@c2     copy(src, dest, 20)
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
;>@f fill(wTilemapBuffer, 0x240, 0xE0)
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

UpdateListCursor::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_00a_42a8

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_00a_426e

	inc hl
	ld a, [hl]
	dec a
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
	cp c
	jr c, jr_00a_428c

	ld a, c
	dec a
	jr jr_00a_428c

jr_00a_426e:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_00a_42a8

	inc hl
	ld a, [hl]
	inc a
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
	cp c
	jr c, jr_00a_428c

	ld a, $00

jr_00a_428c:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_00a_42eb

	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
	call Divide8
	pop bc
	pop de
	or a
	jr z, jr_00a_42eb

	dec a
	cp [hl]
	jr nc, jr_00a_42eb

	ld [hl], a
	jr jr_00a_42eb

Jump_00a_42a8:
jr_00a_42a8:
	push bc
	push de
	push hl
	call DrawPageNumber0A
	pop hl
	pop de
	pop bc
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld [wListLastRows], a
	ld a, b
	pop bc
	pop de
	ld c, a
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateMenuCursor0A

	ld a, [wListLastRows]
	inc a
	ld b, a

UpdateMenuCursor0A::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_00a_42dc

	ld a, [hl]
	dec a
	cp b
	jr c, jr_00a_42ea

	dec b
	ld a, b
	jr jr_00a_42ea

jr_00a_42dc:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_00a_42f3

	ld a, [hl]
	inc a
	cp b
	jr c, jr_00a_42ea

	ld a, $00

jr_00a_42ea:
	ld [hl], a

jr_00a_42eb:
	xor a
	ld [wCursorBlink], a
	push hl
	push de
	pop de
	pop hl

jr_00a_42f3:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_00a_42fc

	set 7, [hl]

jr_00a_42fc:
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
;> FillMemory(wLinkChoice, 8, 0)            # the menu cursors $C8DA-$C8E1
	ld hl, wLinkChoice
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
;@ wTilemapBuffer, with the cursor on wLinkChoice (used here as the menu
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
;> DrawCursorAt0A(wLinkChoice, PartnerBreedMenuCursorPos)
	ld de, PartnerBreedMenuCursorPos
	ld a, [wLinkChoice]
	call DrawCursorAt0A
	ret


;@ def PartnerBreedMenuInput()
;@ path: breed/partner
;@ Step 2: moves the menu cursor. B or Start closes the screen; A chooses
;@ (bit 7 of the cursor is set, the choice kept in wItemsHandedIn) and
;@ clears the list cursors for the chosen service.
;@ test: skip calls the cursor drawing
PartnerBreedMenuInput::
;> UpdateMenuCursor0A(wLinkChoice, PartnerBreedMenuCursorPos, 2)
	ld de, PartnerBreedMenuCursorPos
	ld hl, wLinkChoice
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
;>     wLinkChoice |= 0x80
	ld hl, wLinkChoice
	set 7, [hl]
;>     wItemsHandedIn = wLinkChoice           # the menu entry to run
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

PBListMonsters::
	call PBCountMonsters
	call PBBuildMonsterList
	call GetPartnerName
	ld hl, $0002
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


PBCountMonsters::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_4579:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_458b

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_00a_458b

	inc c

jr_00a_458b:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_00a_4579

	ld a, c
	ld [wListLength], a
	ret


PBBuildMonsterList::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_45b1:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_45c4

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_00a_45c4

	ld [hl], c
	inc hl

jr_00a_45c4:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_00a_45b1

	ret


PBShowList::
	ld a, [wTextState]
	or a
	ret nz

	call PBDrawCursorMonster
	call PBDrawPageNames
	call DrawPBListScreen
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawPBListScreen::
	call RestoreFieldTilemap
	call DrawPartnerBreedMenu
	ld de, $7731
	call DrawWindowLayout0A
	call PBDrawLevel
	ld de, $7409
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $481f
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	call ShowTilemapBuffer
	ret


PBDrawPageNames::
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
	call PBDrawListEntry
	call PBDrawListEntry
	call PBDrawListEntry

PBDrawListEntry::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_4657

	push de
	ld hl, wMonEgg
	call MonsterField
	pop de
	ld a, [hl]
	or a
	jr nz, jr_00a_4671

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call RenderNameTiles
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


jr_00a_4657:
	ld b, $20

jr_00a_4659:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_4659

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


jr_00a_4671:
	ld a, $0e
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	ld de, $0401
	pop hl
	push hl
	call RenderTextTiles
	pop hl
	ld a, l
	add $30
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	push de
	push hl
	ld a, [de]
	ld hl, wMonFamily
	call MonsterField
	ld a, [hl]
	add a
	ld hl, $46b5
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	push hl
	call DecompressVRAM
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


FamilyIconGfx0A::
	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

PBDrawCursorMonster::
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
	ld hl, $9780
	call RenderNameTiles
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $97c0
	and $01
	add $a7
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
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
	ret


PBDrawLevel::
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
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
	ld hl, $0161
	call OffsetToTilemapBuffer
	ld a, $de
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
	call DrawTwoDigits0A
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, jr_00a_4793

	ld hl, $0169
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


jr_00a_4793:
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
	ld de, $7731
	call DrawWindowLayout0A
;> PBDrawLevel()
	call PBDrawLevel
;> DrawWindowLayout0A(LayoutPartnerList)
	ld de, $7409
	call DrawWindowLayout0A
;> DrawListCursor(wListCursor, PBListCursorPos, 4, wListLength)
	ld de, PBListCursorPos
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
;> DrawWindowLayout0A(LayoutConfirm)
	ld de, $7463
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
	ld de, $748d
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
;> FillMemory(wLinkChoice, 8, 0)            # the menu cursors $C8DA-$C8E1
	ld hl, wLinkChoice
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
;@ wLinkChoice (used here as the menu cursor).
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
	ld de, $75ab
	call DrawWindowLayout0A
;> DrawWindowLayout0A(0x2E07)            # message box frame (bank 0)
	ld de, $2e07
	call DrawWindowLayout0A
;> ResetCursorBlink0A()
	call ResetCursorBlink0A
;> DrawCursorAt0A(wLinkChoice, BreedingMenuCursorPos)
	ld de, BreedingMenuCursorPos
	ld a, [wLinkChoice]
	call DrawCursorAt0A
	ret


;@ def BreedingMenuInput()
;@ path: breed/house
;@ Step 2: moves the menu cursor. B or Start closes the screen; A chooses
;@ (bit 7 of the cursor is set, the choice kept in wItemsHandedIn) and
;@ clears the list cursors for the chosen service.
;@ test: skip calls the cursor drawing
BreedingMenuInput::
;> UpdateMenuCursor0A(wLinkChoice, BreedingMenuCursorPos, 3)
	ld de, BreedingMenuCursorPos
	ld hl, wLinkChoice
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
;>     wLinkChoice |= 0x80
	ld hl, wLinkChoice
	set 7, [hl]
;>     wItemsHandedIn = wLinkChoice           # the menu entry to run
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

BRListMonsters::
	call BRCountMonsters
	call BRBuildMonsterList
	ld hl, $0003
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


BRCountMonsters::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_4d54:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_4d66

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_00a_4d66

	inc c

jr_00a_4d66:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_00a_4d54

	ld a, c
	ld [wListLength], a
	ret


BRBuildMonsterList::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_4d8c:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_4d9f

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_00a_4d9f

	ld [hl], c
	inc hl

jr_00a_4d9f:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_00a_4d8c

	ret


BRShowList::
	ld a, [wTextState]
	or a
	ret nz

	call BRClearInfo
	call BRDrawPageNames
	call DrawBRListScreen
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawBRListScreen::
	call RestoreFieldTilemap
	call DrawBreedingMenu
	ld de, $75f3
	call DrawWindowLayout0A
	ld de, $76a7
	call DrawWindowLayout0A
	call BRDrawLevel
	call ResetCursorBlink0A
	ld de, $4fa8
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	call ShowTilemapBuffer
	ret


BRDrawPageNames::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9610
	call DrawNameEntry
	call DrawNameEntry
	call DrawNameEntry

DrawNameEntry::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_4e26

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call RenderNameTiles
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


jr_00a_4e26:
	ld b, $20

jr_00a_4e28:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_4e28

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


BRClearInfo::
	call BRDrawCursorMonster
	ld hl, $9760
	ld b, $28

jr_00a_4e48:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_4e48

	ret


BRDrawCursorMonster::
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $9710
	call DrawNameEntry
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9750
	call DrawGenderTile
	ret


DrawGenderTile::
	and $01
	add $a7
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
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
	ret


BRDrawLevel::
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
	ld hl, $012a
	call OffsetToTilemapBuffer
	ld a, $de
	ld [hli], a
	call DrawTwoDigits0A
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	ret nz

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
	ld de, $76a7
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
	ld de, $76a7
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
	ld de, $75f3
	call DrawWindowLayout0A
;> DrawWindowLayout0A(LayoutPairInfo)
	ld de, $76a7
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
	ld de, $7463
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
;@ test: wListKnown = rand(0, 19); for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
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
;@ test: wListKnown = rand(0, 19); for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
BRBuildMateList::
;> fill(wSceneObjects, 20, 0xFF)
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


DrawBRMateScreen::
	call RestoreFieldTilemap
	call DrawBreedingMenu
	ld de, $764d
	call DrawWindowLayout0A
	ld de, $76a7
	call DrawWindowLayout0A
	call BRDrawPairLevels
	call ResetCursorBlink0A
	ld de, $52dd
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor2
	call DrawListCursor
	call ShowTilemapBuffer
	ret


BRDrawMatePage::
	ld a, [wListPage2]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9610
	call DrawNameEntry
	call DrawNameEntry
	call DrawNameEntry
	call DrawNameEntry
	ret


BRDrawPair::
	ld de, wListKnown
	ld a, [de]
	push af
	ld hl, $9710
	call DrawNameEntry
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9750
	call DrawGenderTile

BRDrawMateCursor::
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
	and $7f
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $9760
	call DrawNameEntry
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $97a0
	call DrawGenderTile
	ret


BRDrawPairLevels::
	ld de, wListKnown
	ld a, [de]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
	ld hl, $012a
	call OffsetToTilemapBuffer
	ld a, $de
	ld [hli], a
	call DrawTwoDigits0A
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, jr_00a_51f0

	ld hl, $0132
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a

jr_00a_51f0:
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
	and $7f
	add b
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
	ld hl, $016a
	call OffsetToTilemapBuffer
	ld a, $de
	ld [hli], a
	call DrawTwoDigits0A
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	ret nz

	ld hl, $0172
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


BRMateInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $52dd
	ld hl, wListCursor2
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdateListCursor
	pop af
	ld hl, wListCursor2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_00a_5266

	call BRDrawMateCursor
	ld de, $76a7
	call DrawWindowLayout0A
	call BRDrawPairLevels
	call ShowTilemapBuffer

jr_00a_5266:
	pop af
	ld hl, wListPage2
	cp [hl]
	jr z, jr_00a_527f

	call BRDrawMateCursor
	call BRDrawMatePage
	ld de, $76a7
	call DrawWindowLayout0A
	call BRDrawPairLevels
	call ShowTilemapBuffer

jr_00a_527f:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_52ae

	ld hl, $0003
	call PrintServiceMessage
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_00a_52dc

jr_00a_52ae:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4fa7

	ld a, $59
	call QueueSound
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
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
	xor a
	ld [wConfirmChoice2], a
	ld hl, wMenuSubStep
	inc [hl]

jr_00a_52dc:
	ret


BRMateCursorPos::
	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

BRAskMate::
	ld hl, $0005
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


BROpenMateConfirm::
	ld a, [wTextState]
	or a
	ret nz

	call DrawBRMateConfirm
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawBRMateConfirm::
	call RestoreFieldTilemap
	call DrawBreedingMenu
	ld de, $764d
	call DrawWindowLayout0A
	ld de, $76a7
	call DrawWindowLayout0A
	call BRDrawPairLevels
	ld de, $52dd
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor2
	call DrawListCursor
	ld de, $7463
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $541f
	ld a, [wConfirmChoice2]
	call DrawCursorAt0A
	call ShowTilemapBuffer
	ret


BRMateConfirmInput::
	ld de, $541f
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_5369

	call DrawBRMateScreen
	ld hl, $0004
	call PrintServiceMessage
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jp Jump_00a_541e


jr_00a_5369:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_541e

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice2]
	cp $81
	jr z, jr_00a_538c

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $17
	ld [wMenuSubStep], a
	jp Jump_00a_541e


jr_00a_538c:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, jr_00a_53a7

	ld hl, $0007
	call PrintServiceMessage
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_00a_541e

jr_00a_53a7:
	ld a, [wPartyCount]
	cp $03
	jr z, jr_00a_53ef

	cp $02
	jr nz, jr_00a_53d0

	ld a, [wListKnown]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, jr_00a_53ef

	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, jr_00a_53ef

	jr jr_00a_53e2

jr_00a_53d0:
	ld a, [wParty]
	ld hl, wListKnown
	cp [hl]
	jr z, jr_00a_53e2

	ld a, [wParty]
	ld hl, wCurPartyMember
	cp [hl]
	jr nz, jr_00a_53ef

jr_00a_53e2:
	ld hl, $0006
	call PrintServiceMessage
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_00a_541e

jr_00a_53ef:
	ld a, [wListKnown]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	and $01
	push af
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	pop af
	ld b, a
	ld a, [hl]
	and $01
	cp b
	jr nz, jr_00a_541a

	ld hl, $0008
	call PrintServiceMessage
	ld a, $19
	ld [wMenuSubStep], a
	jr jr_00a_541e

jr_00a_541a:
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_541e:
jr_00a_541e:
	ret


BRMateConfirmCursorPos::
	db $2e, $00, $6e, $00, $ff, $ff

BRPredictOffspring::
	ld a, [wListKnown]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld a, [wListKnown]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wBreedQuery], a
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wBreedSpecies2], a
	ld a, [wListKnown]
	and $7f
	ld [wBreedSlot1], a
	ld a, [wCurPartyMember]
	and $7f
	ld [wBreedSlot2], a
	ld hl, far_BreedResultPreview
	rst $10
	ld a, [wBreedPair]
	ld hl, wLibraryFlags
	call TestFlag
	jr nz, jr_00a_5490

	ld a, [wBreedPair]
	ld hl, $54c7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_00a_54b5

jr_00a_5490:
	ld a, [wBreedPair]
	ld l, a
	ld h, $05
	ld de, wTextArg2
	call CopySystemText
	ld a, [wOffspringPlus]
	ld de, wTextArg2
	call AppendPlusValue
	ld a, [wBreedPair]
	ld hl, wLibraryFlags
	call TestFlag
	jr z, jr_00a_54ba

	ld hl, $0009
	jr jr_00a_54bf

jr_00a_54b5:
	ld hl, $000a
	jr jr_00a_54bf

jr_00a_54ba:
	ld hl, $001c
	jr jr_00a_54bf

jr_00a_54bf:
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


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

BRWaitPrediction::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuSubStep
	inc [hl]
	ret


BRResetSaveCursor::
	xor a
	ld [wLinkRefused], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


BRUnusedCursorPos::
	db $21, $01, $61, $01, $ff, $ff

BRShowSaveInfo::
	ld de, $748d
	call DrawWindowLayout0A
	ld de, $2e07
	call DrawWindowLayout0A
	call DrawSaveFileInfo
	call ShowTilemapBuffer
	ld hl, $000b
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


BROpenSaveConfirm::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $70c5
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $5659
	ld a, [wLinkRefused]
	call DrawCursorAt0A
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


BRSaveConfirmInput::
	ld de, $5659
	ld hl, wLinkRefused
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_5640

jr_00a_5633:
	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_5658

jr_00a_5640:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_5658

	ld a, $59
	call QueueSound
	ld a, [wLinkRefused]
	cp $81
	jr z, jr_00a_5633

	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_5658:
jr_00a_5658:
	ret


BRSaveConfirmCursorPos::
	db $21, $01, $61, $01, $ff, $ff

BRBreedAndSave::
	ld de, $2e07
	call DrawWindowLayout0A
	call ShowTilemapBuffer
	ld hl, $000c
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ld a, [wListKnown]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld a, [wListKnown]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wListKnown]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	call CopyMonsterRecord
	ld a, [wListKnown]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent2
	call CopyMonsterRecord
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	ld hl, far_CompactMonsters
	rst $10
	ld hl, HeaderLogo
	rst $10
	ld hl, far_MakeOffspring
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
	ld a, [wStoryStep]
	push af
	xor a
	ld [wStoryStep], a
	di
	call SaveGame
	ei
	pop af
	ld [wStoryStep], a
	pop af
	ld [wMenuOverlay], a
	pop af
	ld [wScriptRunning], a
	pop af
	ld [wMenuStep], a
	pop af
	ld [wFieldFlags], a
	ret


BRWarpToBreeding::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $08
	ld [wWarpMap], a
	ld a, $00
	ld [wWarpOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld a, $00
	ld [wStoryStep], a
	xor a
	ld [wScriptRunning], a
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg2
	call CopySystemText
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
	ld c, l
	ld b, h
	ld hl, wTextArgs
	call Number16ToDecimal
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	ret


;@ def CopyMonsterRecord(src: hl, dest: de)
;@ path: monster/records
;@ Copies one $95-byte monster record.
;@ test: hl = 0xC100; de = 0xC300
CopyMonsterRecord::
;>@c copy(src, dest, 0x95)
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
	ld de, $76a7
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
	ld de, $76a7
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
;> fill(wSceneObjects, 20, 0xFF)
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


HTShowList::
	ld a, [wTextState]
	or a
	ret nz

	call HTDrawPage
	call DrawHTListScreen
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawHTListScreen::
	call RestoreFieldTilemap
	call DrawBreedingMenu
	ld de, $7757
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $5b3a
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	ret


HTDrawPage::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9650
	call DrawSpeciesEntry
	call DrawSpeciesEntry
	call DrawSpeciesEntry
	ld hl, $8800
	call DrawSpeciesEntry
	call HTDrawGenders
	ret


DrawSpeciesEntry::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_5a27

	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call RenderTextTiles
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


jr_00a_5a27:
	ld b, $48

jr_00a_5a29:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_5a29

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


HTDrawGenders::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8a00
	call DrawEggGenderEntry
	call DrawEggGenderEntry
	call DrawEggGenderEntry

DrawEggGenderEntry::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_5ad7

	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, jr_00a_5a7c

	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	and $01
	add $a7

jr_00a_5a7c:
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


jr_00a_5ad7:
	ld b, $08

jr_00a_5ad9:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_5ad9

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


HTListInput::
	ld de, $5b3a
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdateListCursor
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_00a_5b10

	call HTDrawPage

jr_00a_5b10:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_5b24

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_5b39

jr_00a_5b24:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_5b39

	ld a, $59
	call QueueSound
	xor a
	ld [wMenuChoice3], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_5b39:
jr_00a_5b39:
	ret


HTListCursorPos::
	db $92, $01, $a8, $00, $e8, $00, $28, $01, $68, $01, $ff, $ff

HTQuotePrice::
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
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
	ld c, l
	ld b, h
	ld hl, wTextArgs
	call Number16ToDecimal
	ld hl, $0014
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTOpenConfirm::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $79be
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $5c46
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTConfirmInput::
	ld de, $5c46
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_5bcb

	ld hl, $0012
	call PrintServiceMessage
	call DrawHTListScreen
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_00a_5c45

jr_00a_5bcb:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_5c45

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_00a_5bed

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $0c
	ld [wMenuSubStep], a
	jr jr_00a_5c45

jr_00a_5bed:
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
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
	ld a, [wGold]
	sub l
	ld a, [$ca4c]
	sbc h
	ld a, [$ca4d]
	sbc $00
	jr nc, jr_00a_5c2c

	ld hl, $001e
	call PrintServiceMessage
	ld a, $0b
	ld [wMenuSubStep], a
	jr jr_00a_5c45

jr_00a_5c2c:
	ld e, $00
	call SpendGold
	xor a
	ld [wLinkRefused], a
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_5c45:
jr_00a_5c45:
	ret


HTConfirmCursorPos::
	db $2d, $00, $6d, $00, $ff, $ff

HTStep6::
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTStep7::
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTStep8::
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTHatch::
	ld de, $2e07
	call DrawWindowLayout0A
	call ShowTilemapBuffer
	ld hl, $0015
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
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
	ld [wHatchSlot], a
	ld [wLeaderSlot], a
	ld hl, far_InitJoinedMonster
	rst $10
	ret


HTWarpToHatching::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wFieldFlags
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [wMenuStep], a
	ld a, [wHatchSlot]
	ld [wCurPartyMember], a
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendPlusValue
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg1
	call AppendGenderMark
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wChosenMonPic], a
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
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
	ld a, $08
	ld [wWarpMap], a
	ld a, $00
	ld [wWarpOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld a, $02
	ld [wStoryStep], a
	xor a
	ld [wScriptRunning], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	ret


HTBackToMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	ret


HTOpenStatus::
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


HTReturnFromStatus::
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
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $10
	ld [wTextIndex], a
	ld hl, $9400
	ld de, $0801
	call RenderTextTiles
	call HTCountEggs
	call HTBuildEggList
	call HTDrawPage
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
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	inc a
	ld c, $0a
	call Multiply
	ld c, l
	ld b, h
	ld hl, wTextArgs
	call Number16ToDecimal
	ld hl, $0014
	call PrintServiceMessage
	call DrawHTListScreen
	ld de, $79be
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $5c46
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
	call ShowTilemapBuffer
	ld a, $04
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


DrawSaveFileInfo::
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr nz, jr_00a_5e84

	ld hl, $0021
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0041
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0061
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0081
	call OffsetToTilemapBuffer
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0044
	call OffsetToTilemapBuffer
	ld b, $0a
	ld a, $a4

jr_00a_5e69:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_00a_5e69

	ld a, $31
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	ld hl, $8a40
	ld de, $0a01
	call RenderTextTiles
	jp Jump_00a_5f2b


jr_00a_5e84:
	di
	ld a, $0a
	ld [$0100], a
	ld de, sPlayerName
	ld hl, $8a00
	call RenderNameTiles
	call DrawSaveFileParty
	ld hl, sPlayHours
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $002d
	call OffsetToTilemapBuffer
	call PrintNumber2Zeros
	ld hl, sPlayMinutes
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $0030
	call OffsetToTilemapBuffer
	call PrintNumber2Zeros
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr z, jr_00a_5f31

	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [sParty]
	call MonsterField
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $0084
	call OffsetToTilemapBuffer
	call PrintNumber2
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $01
	jr z, jr_00a_5f37

	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [$a1c9]
	call MonsterField
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $008a
	call OffsetToTilemapBuffer
	call PrintNumber2
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $02
	jr z, jr_00a_5f3d

	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonLevel
	ld a, [$a1ca]
	call MonsterField
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $0090
	call OffsetToTilemapBuffer
	call PrintNumber2

Jump_00a_5f2b:
	ld a, $00
	ld [$0100], a
	ret


jr_00a_5f31:
	ld hl, $0061
	call ClearSaveInfoSlot

jr_00a_5f37:
	ld hl, $0067
	call ClearSaveInfoSlot

jr_00a_5f3d:
	ld hl, $006d
	call ClearSaveInfoSlot
	ld a, $00
	ld [$0100], a
	ret


ClearSaveInfoSlot::
	push hl
	call OffsetToTilemapBuffer
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	pop hl
	ld a, l
	add $21
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call OffsetToTilemapBuffer
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


DrawSaveFileParty::
	ld hl, $8da0
	ld b, $18
	call ClearTiles
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [sParty]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $8a40
	ld a, $01
	call DrawSaveFileMember
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [$a1c9]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $8a80
	ld a, $02
	call DrawSaveFileMember
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [$a1ca]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $8ac0
	ld a, $03
	call DrawSaveFileMember
	ret


DrawSaveFileMember::
	ld b, a
	di
	ld a, $0a
	ld [$0100], a
	ld a, [sPartyCount]
	cp b
	ei
	jr nc, jr_00a_5fd9

	ld b, $20

ClearTiles::
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, ClearTiles

	ret


jr_00a_5fd9:
	push bc
	call RenderNameTiles
	pop bc
	dec b
	push bc
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sParty
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, sSavedMonFamily
	call MonsterField
	ld a, [hl]
	ei
	add a
	ld hl, $6013
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop bc
	ld a, b
	swap a
	add $a0
	ld l, a
	ld h, $8d
	call DecompressVRAM
	ret


SaveFamilyIconGfx::
	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

DrawTwoDigits0A::
	ld de, $000a
	push bc
	call CountDivisions
	pop bc
	or a
	jr z, jr_00a_603e

	ld de, $000a
	call CountDivisions
	call DrawDigit
	call NextScreenColumn2

jr_00a_603e:
	ld a, c
	call DrawDigit
	ret


CountDivisions::
	push hl
	ld h, $ff

jr_00a_6046:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_00a_6046

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


DrawDigit::
	add $f0
	call WriteVRAM
	ret


NextScreenColumn2::
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


AppendPlusValue::
	or a
	ret z

	push af

jr_00a_6070:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_00a_6070

	dec de
	ld a, $a2
	ld [de], a
	inc de
	pop af
	ld l, e
	ld h, d
	call ByteToDecimal
	ret


AppendGenderMark::
	push af

jr_00a_6083:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_00a_6083

	dec de
	pop af
	and $01
	add $a7
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
	ret


EggAppraiserScreen::
	ld a, [wMenuStep]
	rst $00

EggAppraiserSteps::
	dw EAInit
	dw EAOpenMenu
	dw EAMenuInput
	dw EARunChoice
	dw EAClose

EAInit::
	ld hl, hScrollX
	call RoundToTile
	ld hl, hScrollY
	call RoundToTile
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
	call RestoreFieldTilemap
	ld de, $2e13
	ld hl, $8800
	call DecompressVRAM
	call ResetCursorBlink0A
	ld hl, wMenuStep
	inc [hl]
	ret


EAOpenMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuStep
	inc [hl]
	call RestoreFieldTilemap
	call DrawEAMenu
	call ShowTilemapBuffer
	ret


DrawEAMenu::
	ld de, $77d7
	call DrawWindowLayout0A
	ld de, $6f86
	call DrawWindowLayout0A
	ld de, $2e07
	call DrawWindowLayout0A
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call OffsetToTilemapBuffer
	call PrintNumber5
	call ResetCursorBlink0A
	ld de, $6186
	ld a, [wLinkChoice]
	call DrawCursorAt0A
	ret


EAMenuInput::
	ld de, $6186
	ld hl, wLinkChoice
	ld b, $03
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_00a_6154

	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr jr_00a_6185

jr_00a_6154:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_00a_6185

	ld a, $59
	call QueueSound
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuSubStep], a
	ld hl, wLinkChoice
	set 7, [hl]
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr jr_00a_6185

jr_00a_6185:
	ret


EAMenuCursorPos::
	db $21, $00, $61, $00, $a1, $00, $ff, $ff

EARunChoice::
	ld a, [wLinkChoice]
	rst $00

EAChoices::
	dw AppraiseFlow
	dw GenderFlow
	dw EAClose

EAClose::
	call RestoreFieldTilemap
	ld de, $2e07
	call DrawWindowLayout0A
	call ShowTilemapBuffer
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


AppraiseFlow::
	ld a, [wMenuSubStep]
	rst $00

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

APListEggs::
	call EACountEggs
	or a
	jr nz, jr_00a_61e4

	ld hl, $0004
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	ret


jr_00a_61e4:
	call EABuildEggList
	ld hl, $0003
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


EACountEggs::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_61f9:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_620b

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_00a_620b

	inc c

jr_00a_620b:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_00a_61f9

	ld a, c
	ld [wListLength], a
	ret


EABuildEggList::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_6231:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_6244

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_00a_6244

	ld [hl], c
	inc hl

jr_00a_6244:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_00a_6231

	ret


APShowList::
	ld a, [wTextState]
	or a
	ret nz

	call EADrawPage
	call EADrawGenders
	call DrawAPListScreen
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawAPListScreen::
	call RestoreFieldTilemap
	call DrawEAMenu
	ld de, $781f
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $63eb
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	ret


EADrawPage::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9700
	call DrawSpeciesEntry2
	ld hl, $8800
	call DrawSpeciesEntry2
	call DrawSpeciesEntry2

DrawSpeciesEntry2::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_62ce

	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call RenderTextTiles
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


jr_00a_62ce:
	ld b, $48

jr_00a_62d0:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_62d0

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


EADrawGenders::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $89b0
	call DrawEggGenderEntry2
	call DrawEggGenderEntry2
	call DrawEggGenderEntry2

DrawEggGenderEntry2::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_637e

	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, jr_00a_6323

	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	and $01
	add $a7

jr_00a_6323:
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


jr_00a_637e:
	ld b, $08

jr_00a_6380:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_6380

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


APListInput::
	ld de, $63eb
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdateListCursor
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_00a_63ba

	call EADrawPage
	call EADrawGenders

jr_00a_63ba:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_63ce

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_63ea

jr_00a_63ce:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_63ea

	ld a, $59
	call QueueSound
	ld a, $0a
	ld [wMenuSubStep], a
	ld a, $00
	ld [wConfirmChoice], a
	ld a, $01
	ld [wConfirmChoice2], a

Jump_00a_63ea:
jr_00a_63ea:
	ret


APListCursorPos::
	db $92, $01, $a8, $00, $e8, $00, $28, $01, $68, $01, $ff, $ff

APPay::
	ld a, [wGold]
	sub $14
	ld a, [$ca4c]
	sbc $00
	ld a, [$ca4d]
	sbc $00
	jr c, jr_00a_6453

	ld hl, $0014
	ld e, $00
	call SpendGold
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
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld de, wTextArg0
	call AppendPlusValue
	ld hl, $0006
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


jr_00a_6453:
	ld hl, $001c
	call PrintServiceMessage
	ld a, $09
	ld [wMenuSubStep], a
	ret


APJudgeStats::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCurPartyMember]
	ld hl, wMonHP
	call MonsterField
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, d
	cp $10
	jr nc, jr_00a_64e3

	push de
	ld a, [wCurPartyMember]
	ld hl, wMonMP
	call MonsterField
	pop de
	ld a, e
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
	ld a, d
	cp $10
	jr nc, jr_00a_64e3

	push de
	ld a, [wCurPartyMember]
	ld hl, wMonAttack
	call MonsterField
	pop de
	ld a, e
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
	ld a, d
	cp $10
	jr nc, jr_00a_64e3

	push de
	ld a, [wCurPartyMember]
	ld hl, wMonDefense
	call MonsterField
	pop de
	ld a, e
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
	ld a, d
	cp $10
	jr nc, jr_00a_64e3

	push de
	ld a, [wCurPartyMember]
	ld hl, wMonAgility
	call MonsterField
	pop de
	ld a, e
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a
	ld a, d
	cp $10
	jr nc, jr_00a_64e3

	push de
	ld a, [wCurPartyMember]
	ld hl, wMonIntelligence
	call MonsterField
	pop de
	ld a, e
	add [hl]
	inc hl
	ld e, a
	ld a, d
	adc [hl]
	ld d, a

jr_00a_64e3:
	push de
	ld a, e
	sub $78
	ld e, a
	ld a, d
	sbc $00
	ld d, a
	pop de
	jr c, jr_00a_6513

	ld hl, $0007
	push de
	ld a, e
	sub $2c
	ld e, a
	ld a, d
	sbc $01
	ld d, a
	pop de
	jr c, jr_00a_6510

	ld hl, $0008
	push de
	ld a, e
	sub $58
	ld e, a
	ld a, d
	sbc $02
	ld d, a
	pop de
	jr c, jr_00a_6510

	ld hl, $0009

jr_00a_6510:
	call PrintServiceMessage

jr_00a_6513:
	ld hl, wMenuSubStep
	inc [hl]
	ret


APJudgeSkills::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCurPartyMember]
	ld hl, wMonSkillList
	call MonsterField
	ld b, $19
	ld c, $00

jr_00a_652a:
	ld a, [hli]
	cp $ff
	jr z, jr_00a_6530

	inc c

jr_00a_6530:
	dec b
	jr nz, jr_00a_652a

	ld a, c
	cp $0a
	jr c, jr_00a_654c

	ld hl, $000a
	cp $0f
	jr c, jr_00a_6549

	ld hl, $000b
	cp $14
	jr c, jr_00a_6549

	ld hl, $000c

jr_00a_6549:
	call PrintServiceMessage

jr_00a_654c:
	ld hl, wMenuSubStep
	inc [hl]
	ret


APJudgeGrowth::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCurPartyMember]
	ld hl, wMonMaxLevel
	call MonsterField
	ld a, [hl]
	ld hl, $000d
	cp $1e
	jr c, jr_00a_657c

	ld hl, $000e
	cp $28
	jr c, jr_00a_657c

	cp $32
	jr c, jr_00a_657f

	ld hl, $000f
	cp $50
	jr c, jr_00a_657c

	ld hl, $0010

jr_00a_657c:
	call PrintServiceMessage

jr_00a_657f:
	ld a, $0f
	ld [wMenuSubStep], a
	ret


APTellGender::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $0013
	and $01
	jr z, jr_00a_659e

	ld hl, $0014

jr_00a_659e:
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


APMarkAppraised::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0015
	call PrintServiceMessage
	ld a, [wCurPartyMember]
	ld hl, wMonEgg
	call MonsterField
	ld [hl], $02
	ld hl, wMenuSubStep
	inc [hl]
	ret


APBackToMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	ret


APAskPay::
	ld hl, $0005
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


APOpenPayConfirm::
	ld a, [wTextState]
	or a
	ret nz

	call DrawAPListScreen
	call DrawAPPayConfirm
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawAPPayConfirm::
	ld de, $79ed
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $6653
	ld a, [wConfirmChoice]
	call DrawCursorAt0A
	ret


APPayConfirmInput::
	ld de, $6653
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_6628

	call DrawAPListScreen
	call ShowTilemapBuffer
	ld hl, $0003
	call PrintServiceMessage
	ld a, $02
	ld [wMenuSubStep], a
	jr jr_00a_6652

jr_00a_6628:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_6652

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_00a_6649

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld hl, wMenuSubStep
	inc [hl]
	jr jr_00a_6652

jr_00a_6649:
	ld a, $03
	ld [wMenuSubStep], a
	xor a
	ld [wConfirmChoice2], a

Jump_00a_6652:
jr_00a_6652:
	ret


APPayConfirmCursorPos::
	db $21, $01, $61, $01, $ff, $ff

APOpenStatus::
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
	ld hl, far_ShowMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


APReturnFromStatus::
	ld de, $2e13
	ld hl, $8800
	call DecompressVRAM
	call EACountEggs
	call EABuildEggList
	call EADrawPage
	call EADrawGenders
	ld hl, $0005
	call PrintServiceMessage
	call DrawAPListScreen
	call DrawAPPayConfirm
	call ShowTilemapBuffer
	ld a, $0b
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


APJudgeResistances::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wMonSpecies], a
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld hl, wMonResistances
	xor a
	call SumResistances
	push af
	ld a, [wCurPartyMember]
	ld hl, wMonResist
	call MonsterField
	xor a
	call SumResistances
	pop bc
	cp b
	jr z, jr_00a_66e7

	ld hl, $0011
	jr c, jr_00a_66e4

	ld hl, $0012

jr_00a_66e4:
	call PrintServiceMessage

jr_00a_66e7:
	ld a, $07
	ld [wMenuSubStep], a
	ret


SumResistances::
	ld b, $1b

jr_00a_66ef:
	add [hl]
	inc hl
	dec b
	jr nz, jr_00a_66ef

	ret


GenderFlow::
	ld a, [wMenuSubStep]
	rst $00

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

GCListEggs::
	call EACountEggs
	or a
	jr nz, jr_00a_6721

	ld hl, $0017
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	ret


jr_00a_6721:
	call EABuildEggList
	ld hl, $0016
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


GCShowList::
	ld a, [wTextState]
	or a
	ret nz

	call EADrawPage
	call EADrawGenders
	call DrawGCListScreen
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawGCListScreen::
	call RestoreFieldTilemap
	call DrawEAMenu
	ld de, $781f
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $67b1
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	ret


GCListInput::
	ld de, $67b1
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdateListCursor
	pop af
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_00a_6786

	call EADrawPage
	call EADrawGenders

jr_00a_6786:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_679a

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_67b0

jr_00a_679a:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_67b0

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	ld a, $01
	ld [wConfirmChoice2], a

Jump_00a_67b0:
jr_00a_67b0:
	ret


GCListCursorPos::
	db $92, $01, $a8, $00, $e8, $00, $28, $01, $68, $01, $ff, $ff

GCQuotePrice::
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
	ld a, [wCurPartyMember]
	ld hl, wMonPlus
	call MonsterField
	ld c, [hl]
	ld a, $32
	call Multiply
	ld a, l
	add $64
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld e, $00
	ld a, l
	sub $9f
	ld a, h
	sbc $86
	ld a, e
	sbc $01
	jr c, jr_00a_67ff

	ld hl, $869f
	ld e, $01

jr_00a_67ff:
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld a, l
	ld [wListCursor2], a
	ld a, h
	ld [wListPage2], a
	ld a, e
	ld [$c8e6], a
	ld hl, wTextArg0
	call Number24ToDecimal
	ld hl, $0018
	call PrintServiceMessage
	xor a
	ld [wMenuChoice3], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


GCOpenConfirm::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawGCConfirm
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawGCConfirm::
	ld de, $79ed
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $68a8
	ld a, [wMenuChoice3]
	call DrawCursorAt0A
	ret


GCConfirmInput::
	ld de, $68a8
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_6881

	call DrawGCListScreen
	call ShowTilemapBuffer
	ld hl, $0016
	call PrintServiceMessage
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_00a_68a7

jr_00a_6881:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_68a7

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_00a_68a3

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $09
	ld [wMenuSubStep], a
	jr jr_00a_68a7

jr_00a_68a3:
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_68a7:
jr_00a_68a7:
	ret


GCConfirmCursorPos::
	db $21, $01, $61, $01, $ff, $ff

GCPay::
	ld hl, wListCursor2
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc [hl]
	jr nc, jr_00a_68d1

	ld hl, $001c
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ld hl, wMenuSubStep
	inc [hl]
	jr jr_00a_68f7

jr_00a_68d1:
	ld a, [wListCursor2]
	ld l, a
	ld a, [wListPage2]
	ld h, a
	ld a, [$c8e6]
	ld e, a
	call SpendGold
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	xor $01
	ld [hl], a
	ld hl, $001a
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]

jr_00a_68f7:
	ret


GCDone::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $001b
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


GCBackToMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	ret


GCOpenStatus::
	ld hl, far_ShowMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


GCReturnFromStatus::
	ld de, $2e13
	ld hl, $8800
	call DecompressVRAM
	call EACountEggs
	call EABuildEggList
	call EADrawPage
	call EADrawGenders
	ld a, [wListCursor2]
	ldh [hNumber], a
	ld a, [wListPage2]
	ldh [$ffd6], a
	ld a, [$c8e6]
	ldh [$ffd7], a
	ld hl, wTextArg0
	call Number24ToDecimal
	ld hl, $0018
	call PrintServiceMessage
	call DrawGCListScreen
	call DrawGCConfirm
	call ShowTilemapBuffer
	ld a, $05
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


JoinPartyScreen::
	ld a, [wMenuStep]
	rst $00

JoinPartySteps::
	dw JPInit
	dw JPOpenMenu
	dw JPMenuInput
	dw JPRunChoice
	dw JPClose

JPInit::
	ld hl, hScrollX
	call RoundToTile
	ld hl, hScrollY
	call RoundToTile
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
	call RestoreFieldTilemap
	ld de, $2e07
	call DrawWindowLayout0A
	call ShowTilemapBuffer
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
	call ResetCursorBlink0A
	ld a, $40
	ldh [hSpriteBGTile], a
	ld a, $00
	ld [wTextChoice], a
	ld hl, wMenuStep
	inc [hl]
	ret


JPOpenMenu::
	ld hl, wMenuStep
	inc [hl]
	call RestoreFieldTilemap
	call DrawJPMenu
	call ShowTilemapBuffer
	ret


DrawJPMenu::
	ld de, $6f3c
	call DrawWindowLayout0A
	ld de, $2e07
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $6a42
	ld a, [wLinkChoice]
	call DrawCursorAt0A
	ret


JPMenuInput::
	ld de, $6a42
	ld hl, wLinkChoice
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_00a_6a0c

	jr JPDecline

jr_00a_6a0c:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_00a_6a41

	ld a, $59
	call QueueSound
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuSubStep], a
	ld hl, wLinkChoice
	set 7, [hl]
	ld a, [hl]
	ld [wItemsHandedIn], a
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	jr jr_00a_6a41

jr_00a_6a41:
	ret


JPMenuCursorPos::
	db $2f, $01, $6f, $01, $ff, $ff

JPRunChoice::
	ld a, [wItemsHandedIn]
	rst $00

JPChoices::
	dw JoinFlow
	dw JPDecline

JPDecline::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $01
	ld [wTextChoice], a

JPClose::
	call RestoreFieldTilemap
	ld de, $2e07
	call DrawWindowLayout0A
	call ShowTilemapBuffer
	xor a
	ld [wMenuOverlay], a
	ld a, $80
	ldh [hSpriteClip], a
	ld hl, wFieldFlags
	res 4, [hl]
	set 0, [hl]
	xor a
	ld [wMenuStep], a
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


JoinFlow::
	ld a, [wMenuSubStep]
	rst $00

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

JFAddToParty::
	ld a, [wPartyCount]
	cp $03
	jr z, jr_00a_6abc

	inc a
	ld [wPartyCount], a
	ld hl, wPartyCount
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wLeaderSlot]
	ld [hl], a
	ld hl, $001f
	call PrintServiceMessage
	ld a, $0a
	ld [wMenuSubStep], a
	ret


jr_00a_6abc:
	call JFCountChoices
	call JFBuildList
	ld hl, $0019
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


JFCountChoices::
	ld a, [wPartyCount]
	inc a
	ld [wListLength], a
	ret


JFBuildList::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld a, [wParty]
	cp $ff
	jr z, jr_00a_6afb

	ld [hli], a
	ld a, [$ca8f]
	cp $ff
	jr z, jr_00a_6afb

	ld [hli], a
	ld a, [$ca90]
	cp $ff
	jr z, jr_00a_6afb

	ld [hli], a

jr_00a_6afb:
	ld a, [wLeaderSlot]
	ld [hl], a
	ret


JFShowList::
	ld a, [wTextState]
	or a
	ret nz

	call JFDrawCursorMonster
	call JFDrawNames
	call DrawJFListScreen
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawJFListScreen::
	call RestoreFieldTilemap
	call DrawJPMenu
	ld de, $75f3
	call DrawWindowLayout0A
	ld de, $76e5
	call DrawWindowLayout0A
	call JFDrawLevel
	call ResetCursorBlink0A
	ld de, $6cef
	ld a, [wMenuChoice2]
	call DrawCursorAt0A
	call ShowTilemapBuffer
	ret


JFDrawNames::
	ld de, wSceneObjects
	ld hl, $9610
	call DrawNameEntry2
	call DrawNameEntry2
	call DrawNameEntry2

DrawNameEntry2::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_6b68

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call RenderNameTiles
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


jr_00a_6b68:
	ld b, $20

jr_00a_6b6a:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_6b6a

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


JFDrawLevel::
	ld a, [wMenuChoice2]
	and $7f
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
	ld hl, $00ca
	call OffsetToTilemapBuffer
	ld a, $de
	ld [hli], a
	call DrawTwoDigits0A
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	ret nz

	ld hl, $00d2
	call OffsetToTilemapBuffer
	ld a, $e3
	ld [hl], a
	ret


JFDrawCursorMonster::
	ld a, [wMenuChoice2]
	and $7f
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $9710
	call DrawNameEntry3
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9750
	call DrawGenderTile2
	ret


DrawGenderTile2::
	and $01
	add $a7
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
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
	ret


DrawNameEntry3::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_6c54

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call RenderNameTiles
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


jr_00a_6c54:
	ld b, $20

jr_00a_6c56:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_00a_6c56

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


JFListInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $6cef
	ld hl, wMenuChoice2
	ld a, [wListLength]
	ld b, a
	ld a, [hl]
	push af
	call UpdateMenuCursor0A
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_00a_6c9e

	call JFDrawCursorMonster
	ld de, $76e5
	call DrawWindowLayout0A
	call JFDrawLevel
	call ShowTilemapBuffer

jr_00a_6c9e:
	ld a, [wJoyPressed]
	bit 1, a
	jp z, Jump_00a_6cc4

	ld a, [$c0db]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld hl, $0018
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_6cee

Jump_00a_6cc4:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_6cee

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	ld [wListKnown], a
	xor a
	ld [wConfirmChoice], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_6cee:
jr_00a_6cee:
	ret


JFListCursorPos::
	db $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

JFAskConfirm::
	ld hl, $001a
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


JFOpenConfirm::
	ld a, [wTextState]
	or a
	ret nz

	call DrawJFConfirm
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawJFConfirm::
	call JFDrawCursorMonster
	call RestoreFieldTilemap
	call DrawJPMenu
	ld de, $75f3
	call DrawWindowLayout0A
	ld de, $76e5
	call DrawWindowLayout0A
	call JFDrawLevel
	ld de, $6cef
	ld a, [wMenuChoice2]
	call DrawCursorAt0A
	ld de, $7463
	call DrawWindowLayout0A
	call ResetCursorBlink0A
	ld de, $6da0
	ld a, [wConfirmChoice]
	call DrawCursorAt0A
	call ShowTilemapBuffer
	ret


JFConfirmInput::
	ld de, $6da0
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor0A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_6d75

	call DrawJFListScreen
	ld hl, $0019
	call PrintServiceMessage
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_00a_6d9f

jr_00a_6d75:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_6d9f

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_00a_6d97

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $08
	ld [wMenuSubStep], a
	jr jr_00a_6d9f

jr_00a_6d97:
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wConfirmChoice2], a

Jump_00a_6d9f:
jr_00a_6d9f:
	ret


JFConfirmCursorPos::
	db $2e, $00, $6e, $00, $ff, $ff

JFSendToFarm::
	ld hl, wSceneObjects
	ld a, [wMenuChoice2]
	and $7f
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
	ld hl, $001b
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


	db $c9

JFRebuildParty::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wSceneObjects]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
	ld a, [$c0d9]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
	ld a, [$c0da]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
	ld a, [$c0db]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $02
	ld hl, wSceneObjects
	ld a, [wMenuChoice2]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $01
	ld de, wParty
	ld a, [wSceneObjects]
	call AddIfInParty
	ld a, [$c0d9]
	call AddIfInParty
	ld a, [$c0da]
	call AddIfInParty
	ld a, [$c0db]
	call AddIfInParty
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, wMenuStep
	inc [hl]
	ret


AddIfInParty::
	ld b, a
	push bc
	push de
	ld hl, wMonsters
	call MonsterField
	pop de
	pop bc
	ld a, [hl]
	cp $02
	jr nz, jr_00a_6e52

	ld a, b
	ld [de], a
	inc de

jr_00a_6e52:
	ret


JFOpenStatus::
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wMenuChoice2]
	and $7f
	ld a, a
	ld [wViewIndex], a
	ld a, [wListLength]
	ld [wViewCount], a
	ld hl, far_ShowMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


JFReturnFromStatus::
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
	ld hl, far_Call_56_4485
	rst $10
	call JFDrawNames
	call DrawJFConfirm
	ld hl, $001a
	call PrintServiceMessage
	ld a, $05
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


JFFinish::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, wMenuStep
	inc [hl]
	ret


Layout_0A_6EAC::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7
	db $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf
	db $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Layout_0A_6F17::
	db $0e, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
LayoutYesNo::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $fd, $d9

Layout_0A_6F61::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a7
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

LayoutGold::
	db $0c, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

Layout_0A_6FA3::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Layout_0A_6FE4::
	db $81, $00, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90
	db $91, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $92, $93, $94, $95, $96, $97, $98, $99, $9a, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2
	db $a3, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Layout_0A_709A::
	db $40, $01
	db $fa, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd, $d9

Layout_0A_70AB::
	db $40
	db $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

LayoutYesNoLeft::
	db $00, $01, $fa, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

Layout_0A_70EA::
	db $88, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80
	db $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f
	db $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d
	db $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

Layout_0A_7161::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

Layout_0A_7190::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $a8, $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Layout_0A_71BA::
	db $68, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80
	db $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f
	db $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d
	db $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

Layout_0A_7231::
	db $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $46, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $92, $98, $9c, $e3, $e0, $9c, $93, $93, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e3, $95, $91, $96, $e0, $9a, $e3
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $91, $94, $d5, $91, $96, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $e3, $90, $98, $90, $99
	db $d5, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $d6, $97, $d5, $d5, $e3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $a2, $95, $99, $e0, $e0, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff
	db $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb
	db $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b
	db $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80
	db $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84
	db $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88
	db $89, $8a, $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec
	db $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9e, $90, $d6, $99, $d5, $98, $e4, $a0
	db $a1, $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $da, $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac, $ad, $ae
	db $af, $ff, $d8, $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0, $e0, $e0
	db $e0, $9f, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $84, $e0, $80, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $85, $e0, $81, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $86, $e0, $82, $e0, $91, $97, $90, $d6
	db $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $87, $e0, $83, $e0
	db $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8a, $98, $d5
	db $d5, $92, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $94, $90, $99, $91, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e0, $61, $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $65, $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $61, $62, $63
	db $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $65, $66, $67
	db $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $69, $6a, $6b
	db $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6d, $6e, $6f
	db $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $09, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73
	db $74, $75, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a9, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73, $74, $75
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $49
	db $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0
	db $e0, $65, $66, $67, $68, $69, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $87, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $65, $66, $67
	db $68, $69, $6a, $6b, $6c, $6d, $a0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74
	db $75, $76, $a1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $a2, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $a3, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d5, $df, $9f, $de, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $de, $d5
	db $d6, $d6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $70, $71, $72, $73, $74, $75, $76, $77, $78, $9b, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $9c, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b
	db $8c, $8d, $8e, $8f, $90, $91, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98
	db $99, $9a, $9e, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a4
	db $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8
	db $a9, $aa, $ab, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $ac
	db $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $9e, $9f, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $a0
	db $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $8c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $8d, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a
	db $7b, $7c, $7d, $7e, $7f, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87
	db $88, $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $95
	db $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a1, $a7
	db $a9, $a4, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $a4, $a2, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $fd, $d9, $7a, $00, $2d, $00, $2d, $00, $2d, $00, $2d, $07, $02
	db $79, $00, $20, $2f, $04, $11, $24, $23, $46, $00, $34, $2f, $02, $0e, $08, $02
	db $79, $00, $20, $2f, $04, $11, $14, $12, $35, $00, $16, $2f, $04, $11, $25, $23
	db $46, $00, $34, $2f, $02, $0e, $09, $02, $8a, $00, $50, $2f, $04, $11, $03, $01
	db $35, $00, $2a, $2f, $04, $11, $06, $02, $57, $00, $34, $2f, $04, $11, $11, $02
	db $13, $00, $40, $2f, $04, $11, $10, $13, $01, $10, $16, $2f, $04, $11, $20, $13
	db $01, $10, $16, $2f, $04, $11, $04, $01, $35, $00, $2a, $2f, $04, $11, $19, $02
	db $8a, $00, $50, $2f, $04, $11, $21, $23, $14, $00, $4d, $2f, $06, $02, $22, $23
	db $14, $00, $4d, $2f, $06, $02, $16, $02, $57, $00, $34, $2f, $04, $11, $13, $12
	db $35, $00, $16, $2f, $04, $11, $17, $02, $79, $00, $20, $2f, $04, $11, $18, $02
	db $79, $00, $20, $2f, $04, $11, $02, $02, $13, $00, $40, $2f, $04, $11, $05, $02
	db $57, $00, $34, $2f, $04, $11, $36, $7b, $37, $7b, $42, $7b, $4d, $7b, $58, $7b
	db $63, $7b, $6e, $7b, $79, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b
	db $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b
	db $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b
	db $36, $7b, $36, $7b, $36, $7b, $36, $7b, $36, $7b, $ff, $4c, $e4, $48, $4c, $1d
	db $4d, $00, $42, $00, $42, $02, $4c, $9e, $4f, $4c, $c7, $53, $00, $40, $00, $40
	db $02, $7b, $51, $44, $43, $6d, $69, $00, $68, $00, $6a, $09, $4c, $f3, $5d, $4c
	db $9c, $62, $00, $4a, $00, $68, $04, $4c, $f3, $5d, $4c, $9c, $62, $00, $4e, $00
	db $4c, $04, $4c, $f3, $5d, $43, $ff, $6e, $00, $58, $00, $58, $05, $4c, $f3, $5d
	db $4c, $9c, $62, $00, $4e, $00, $4e, $04, $30, $a0, $0e, $00, $40, $00, $40, $c1
	db $41, $4c, $9e, $4f, $4c, $c7, $53, $00, $40, $00, $40, $02, $30, $a0, $0e, $f0
	db $4a, $aa, $40, $c1, $41, $4c, $e4, $48, $4c, $a0, $56, $00, $44, $00, $44, $03
	db $30, $a0, $0e, $4c, $54, $31, $41, $c1, $41, $4c, $e4, $48, $43, $4e, $6c, $00
	db $46, $00, $46, $03, $30, $a0, $0e, $d8, $5d, $cf, $41, $c1, $41, $4c, $e4, $48
	db $4c, $31, $59, $00, $48, $00, $48, $02, $30, $a0, $0d, $00, $40, $59, $42, $c1
	db $41, $4c, $e4, $48, $4c, $31, $59, $00, $48, $00, $48, $02, $30, $a0, $0d, $58
	db $48, $be, $42, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4c, $00, $4a, $04
	db $30, $a0, $0d, $a4, $50, $35, $43, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00
	db $4e, $00, $4c, $04, $30, $a0, $0d, $91, $5b, $d2, $43, $c1, $41, $43, $63, $48
	db $43, $25, $51, $00, $50, $00, $50, $03, $30, $a0, $07, $00, $40, $9c, $44, $c1
	db $41, $43, $a4, $4c, $43, $25, $51, $00, $52, $00, $52, $06, $30, $a0, $29, $00
	db $40, $4d, $45, $c1, $41, $43, $a4, $4c, $43, $25, $51, $00, $52, $00, $52, $06
	db $30, $a0, $0e, $d4, $66, $cd, $45, $c1, $41, $43, $63, $48, $43, $25, $51, $00
	db $50, $00, $50, $03, $30, $a0, $07, $5f, $4c, $75, $46, $c1, $41, $4c, $f3, $5d
	db $4c, $9c, $62, $00, $4e, $00, $4c, $04, $30, $a0, $07, $5d, $59, $0c, $47, $c1
	db $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4e, $00, $4c, $04, $30, $a0, $07, $96
	db $68, $d5, $47, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4e, $00, $4c, $04
	db $30, $a0, $2a, $00, $40, $6c, $48, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00
	db $4e, $00, $4e, $04, $30, $a0, $2a, $9a, $48, $f1, $48, $c1, $41, $43, $00, $40
	db $43, $09, $44, $00, $5e, $00, $5e, $07, $30, $a0, $2a, $c8, $52, $b0, $49, $c1
	db $41, $4c, $d7, $6b, $4c, $58, $70, $00, $60, $00, $60, $07, $30, $a0, $2a, $b8
	db $64, $85, $4a, $c1, $41, $4c, $d7, $6b, $43, $f9, $73, $00, $62, $00, $62, $07
	db $30, $a0, $2b, $00, $40, $81, $4b, $c1, $41, $43, $60, $5b, $43, $b1, $5f, $00
	db $64, $00, $64, $08, $30, $a0, $2b, $30, $4f, $10, $4c, $c1, $41, $4c, $d7, $6b
	db $4c, $58, $70, $00, $60, $00, $60, $07, $30, $a0, $2b, $a6, $5b, $ac, $4c, $c1
	db $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4a, $00, $68, $04, $30, $a0, $2b, $bb
	db $68, $77, $4d, $c1, $41, $7b, $51, $44, $43, $6d, $69, $00, $6c, $00, $6c, $09
	db $30, $a0, $2c, $00, $40, $3e, $4e, $c1, $41, $7b, $51, $44, $43, $6d, $69, $00
	db $6c, $00, $6c, $09, $30, $a0, $2c, $af, $4e, $df, $4e, $c1, $41, $7b, $51, $44
	db $43, $6d, $69, $00, $6e, $00, $6e, $09, $30, $a0, $2c, $75, $5e, $8a, $4f, $c1
	db $41, $7b, $51, $44, $43, $6d, $69, $00, $6c, $00, $6c, $09, $30, $a0, $2c, $73
	db $6a, $59, $50, $c1, $41, $4c, $f3, $5d, $4c, $9c, $62, $00, $4e, $00, $4c, $04
	db $30, $a0, $2d, $00, $40, $ef, $50, $c1, $41, $4c, $e4, $48, $43, $20, $71, $00
	db $70, $00, $70, $02, $30, $a0, $2d, $6d, $51, $c1, $51, $c1, $41, $4c, $e4, $48
	db $7b, $ca, $48, $00, $72, $00, $72, $02, $30, $a0, $2d, $14, $5d, $4c, $52, $c1
	db $41, $4c, $e4, $48, $7b, $ca, $48, $00, $72, $00, $72, $02, $30, $a0, $2d, $f9
	db $6a, $05, $53, $c1, $41, $4c, $e4, $48, $7b, $ca, $48, $00, $72, $00, $72, $02
	db $30, $a0, $2e, $00, $40, $b1, $53, $c1, $41, $4c, $2d, $65, $4c, $c6, $69, $00
	db $56, $00, $56, $05, $30, $a0, $2e, $80, $4b, $6c, $54, $c1, $41, $4c, $2d, $65
	db $4c, $c6, $69, $00, $56, $00, $56, $05, $30, $a0, $2e, $15, $5c, $35, $55, $c1
	db $41, $43, $00, $40, $43, $22, $46, $00, $5e, $00, $5e, $07, $30, $a0, $2e, $6b
	db $65, $01, $56, $c1, $41, $4c, $2d, $65, $4c, $c6, $69, $00, $56, $00, $56, $05
	db $30, $a0, $3a, $00, $40, $bc, $56, $c1, $41, $4c, $2d, $65, $4c, $c6, $69, $00
	db $56, $00, $56, $05, $30, $a0, $29, $5e, $65, $68, $57, $c1, $41, $43, $a4, $4c
	db $43, $25, $51, $00, $52, $00, $52, $03, $30, $a0, $3a, $25, $4d, $26, $58, $c1
	db $41, $43, $06, $54, $43, $a7, $58, $00, $5a, $00, $5a, $0a, $30, $a0, $3a, $d6
	db $62, $cd, $58, $c1, $41, $43, $06, $54, $43, $a7, $58, $00, $5a, $00, $5a, $0a
	db $30, $a0, $1d, $00, $40, $63, $59, $c1, $41, $43, $06, $54, $43, $a7, $58, $00
	db $5a, $00, $5a, $0a, $30, $a0, $29, $8a, $56, $39, $5a, $c1, $41, $43, $06, $54
	db $43, $a7, $58, $00, $5a, $00, $5a, $0a, $30, $a0, $1d, $2e, $56, $d3, $5a, $c1
	db $41, $7b, $00, $40, $43, $e4, $66, $00, $54, $00, $54, $0b, $30, $a0, $1d, $59
	db $63, $89, $5b, $c1, $41, $7b, $00, $40, $43, $e4, $66, $00, $54, $00, $54, $0b
	db $30, $a0, $1e, $00, $40, $5d, $5c, $c1, $41, $7b, $00, $40, $43, $e4, $66, $00
	db $54, $00, $54, $0b, $30, $a0, $1e, $3b, $49, $36, $5d, $c1, $41, $7b, $00, $40
	db $43, $e4, $66, $00, $54, $00, $54, $0b, $30, $a0, $1e, $64, $51, $d0, $5d, $c1
	db $41, $7b, $00, $40, $43, $e4, $66, $00, $54, $00, $54, $0b, $30, $a0, $1e, $0f
	db $5b, $7d, $5e, $c1, $41, $4c, $d7, $6b, $43, $f9, $73, $00, $62, $00, $62, $07
	db $30, $a0, $1f, $00, $40, $60, $5f, $c1, $41, $43, $60, $5b, $43, $b1, $5f, $00
	db $64, $00, $64, $08, $30, $a0, $1f, $a5, $4f, $13, $60, $c1, $41, $43, $60, $5b
	db $43, $b1, $5f, $00, $66, $00, $66, $08, $30, $a0, $1f, $e7, $5e, $d6, $60, $c1
	db $41, $43, $60, $5b, $43, $b1, $5f, $00, $64, $00, $64, $08, $30, $a0, $1f, $07
	db $6d, $67, $61, $c1, $41, $43, $60, $5b, $43, $b1, $5f, $00, $64, $00, $64, $08
	db $30, $a0, $29, $57, $49, $09, $62, $c1, $41, $7b, $5b, $4b, $7b, $7c, $4f, $00
	db $5c, $00, $5c, $0b, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00
