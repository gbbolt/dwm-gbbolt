INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $00c", ROMX[$4000], BANK[$c]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_0C::
	db $0c

;@ path: system/banks
;@ Entry points of bank $0C for far calls (rst $10 with far_ constants). Banks $0C-$0F hold the
;@ map scripts and the same three helpers; the script interpreter in bank 4 calls the copy in the
;@ bank that holds the scripts of wScriptMap (maps 0-5 here).
FarTable_0C::
	dw GetScriptWord_0C
	dw DrawScriptTiles_0C
	dw DrawScriptAttrs_0C

;@ def GetScriptWord_0C() -> (bc, hl)
;@ path: event/script
;@ Reads word number wScriptPos of the map script wScriptMap / wScriptId from this bank's
;@ MapScripts_0C table. Returns the word in bc and its address in hl.
GetScriptWord_0C::
;> entry = MapScripts_0C + 2 * wScriptMap
	ld a, [wScriptMap]
	ld l, a
	ld h, $00
	add hl, hl
	ld de, MapScripts_0C
	add hl, de
;> scripts = mem16[entry]               # the map's list of scripts
	ld e, [hl]
	inc hl
	ld d, [hl]
;> entry = scripts + 2 * wScriptId
	ld a, [wScriptId]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
;> script = mem16[entry]
	ld e, [hl]
	inc hl
	ld d, [hl]
;> addr = script + 2 * wScriptPos
	ld a, [wScriptPos]
	ld l, a
	ld a, [wScriptPos + 1]
	ld h, a
	add hl, hl
	add hl, de
;> word = mem16[addr]
	ld c, [hl]
	inc hl
	ld b, [hl]
	dec hl
;> return word, addr
	ret


;@ def DrawScriptTiles_0C()
;@ path: event/script
;@ Script helper: the next word of the script points to a tile block, which is copied into
;@ wSavedTilemap and drawn on the background map with the screen's top left corner as its origin
;@ (hScrollX / hScrollY are rounded down to whole tiles first). A block is a 2-byte offset from
;@ that corner (row * 32 + column) and then tile numbers: $D8 starts the next row (under the
;@ block's first column), $D9 ends the block.
DrawScriptTiles_0C::
;> hScrollX &= 0xFFF8                  # (the low byte)
	ld hl, hScrollX
	ld a, [hl]
	and $f8
	ld [hl], a
;> hScrollY &= 0xFFF8
	ld hl, hScrollY
	ld a, [hl]
	and $f8
	ld [hl], a
;> row_offset = (hScrollY & 0xFF) * 4             # tile row * 32
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;> column = (hScrollX & 0xFF) >> 3
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
;> corner = 0x9800 + row_offset + column
	add l
	ld l, a
	ld a, h
	adc $98
	ld h, a
;> corner = 0x9800 | (corner & 0x3FF)    # wrap inside the 32x32 map
	ld a, h
	and $03
	or $98
	ld h, a
;> wScriptBlockPtr = corner
	ld a, l
	ld [wScriptBlockPtr], a
	ld a, h
	ld [wScriptBlockPtr + 1], a
;> wScriptPos += 1                       # the argument word
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> block, addr = GetScriptWord_0C()
	call GetScriptWord_0C
;> CopyBlockToTileBuffer_0C(block)
	push bc
	call CopyBlockToTileBuffer_0C
	pop bc
;> WriteBlockToBGMap_0C(block)           # falls through

;@ def WriteBlockToBGMap_0C(block: bc)
;@ path: event/script
;@ Writes the values of a tile block (see DrawScriptTiles_0C) into the background map at
;@ wScriptBlockPtr plus the block's offset, each through WriteVRAM. Rows and columns wrap around
;@ inside the 32x32 map. Used for the tile numbers and, with VRAM bank 1, for CGB attributes.
;@ test: skip writes VRAM
WriteBlockToBGMap_0C::
;> offset = mem16[block]; block += 2
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
;> columns = offset & 0x1F
	push bc
	ld b, l
;> row_part = offset & 0xFFE0
	ld a, l
	and $e0
	ld l, a
;> pos = wScriptBlockPtr + row_part
	ld a, [wScriptBlockPtr]
	add l
	ld l, a
	ld a, [wScriptBlockPtr + 1]
	adc h
;> pos = (wScriptBlockPtr & 0xFC00) | (pos & 0x3FF)   # stay inside the map
	and $03
	ld h, a
	ld a, [wScriptBlockPtr + 1]
	and $fc
	or h
	ld h, a
;>@cols for i in range(columns):
	ld a, b
	and $1f
	jr z, .rowStart

	ld b, a

.column
;>     pos = NextMapColumn_0C(pos)
	call NextMapColumn_0C
;=@cols
	dec b
	jr nz, .column

.rowStart
;> wScriptBlockPtr = pos                 # start of the block's first row
	ld a, l
	ld [wScriptBlockPtr], a
	ld a, h
	ld [wScriptBlockPtr + 1], a
	pop bc

.next
;>@loop while True:
;>     c = mem[block]; block += 1
	ld a, [bc]
	inc bc
;>     if c == 0xD9:                     # end of the block
;>         return
	cp $d9
	ret z

;>     if c == 0xD8:                     # next row
	cp $d8
	jr nz, .value

;>         pos = wScriptBlockPtr
	ld a, [wScriptBlockPtr]
	ld l, a
	ld a, [wScriptBlockPtr + 1]
	ld h, a
;>         pos += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;>         pos = 0x9800 | (pos & 0x3FF)
	ld a, h
	and $03
	or $98
	ld h, a
;>         wScriptBlockPtr = pos
	ld a, l
	ld [wScriptBlockPtr], a
	ld a, h
	ld [wScriptBlockPtr + 1], a
;=@loop
	jr .next

.value
;>     else:
;>         WriteVRAM(c, pos)
	call WriteVRAM
;>         pos = NextMapColumn_0C(pos)
	call NextMapColumn_0C
;=@loop
	jr .next

;@ def NextMapColumn_0C(pos: hl) -> hl
;@ path: event/script
;@ Moves a BG map address one column right, wrapping around within its 32-tile row.
NextMapColumn_0C::
;> column = (pos + 1) & 0x1F
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;> pos = (pos & 0xFFE0) | column
	ld l, a
	pop af
	or l
	ld l, a
;> return pos
	ret


;@ def CopyBlockToTileBuffer_0C(block: bc)
;@ path: event/script
;@ Copies the tile numbers of a tile block (see DrawScriptTiles_0C) into wSavedTilemap, the
;@ RAM copy of the background map; the block's offset is taken from the buffer's start.
;@ test: skip reads a block through a pointer from the script
CopyBlockToTileBuffer_0C::
;> offset = mem16[block]; block += 2
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
;> dest = wSavedTilemap + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c3
	ld h, a

.row
;>@rows while True:
;>     line = dest
	push hl

.next
;>@vals     while True:
;>         c = mem[block]; block += 1
	ld a, [bc]
	inc bc
;>         if c == 0xD9:
	cp $d9
	jr z, .end

;>@end             return
;>         if c == 0xD8:
	cp $d8
	jr nz, .value

;>             break
;>@val         mem[dest] = c; dest += 1
;>     dest = line
	pop hl
;>     dest += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@rows
	jr .row

.value
;=@val
	ld [hli], a
;=@vals
	jr .next

.end
;=@end
	pop hl
	ret


;@ def DrawScriptAttrs_0C()
;@ path: event/script
;@ Script helper: like DrawScriptTiles_0C, but the block holds palette attributes. They go into
;@ wScreenMap (4 bits per cell) and, on a Game Boy Color, into the attribute map (VRAM bank 1)
;@ at the same place.
DrawScriptAttrs_0C::
;> hScrollX &= 0xFFF8                  # (the low byte)
	ld hl, hScrollX
	ld a, [hl]
	and $f8
	ld [hl], a
;> hScrollY &= 0xFFF8
	ld hl, hScrollY
	ld a, [hl]
	and $f8
	ld [hl], a
;> row_offset = hScrollY * 4
	ldh a, [hScrollY]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
;> column = (hScrollX & 0xFF) >> 3
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
;> corner = 0x9800 + row_offset + column
	add l
	ld l, a
	ld a, h
	adc $98
	ld h, a
;> corner = 0x9800 | (corner & 0x3FF)
	ld a, h
	and $03
	or $98
	ld h, a
;> wScriptBlockPtr = corner
	ld a, l
	ld [wScriptBlockPtr], a
	ld a, h
	ld [wScriptBlockPtr + 1], a
;> wScriptPos += 1
	ld a, [wScriptPos]
	add $01
	ld [wScriptPos], a
	ld a, [wScriptPos + 1]
	adc $00
	ld [wScriptPos + 1], a
;> block, addr = GetScriptWord_0C()
	call GetScriptWord_0C
;> CopyBlockToAttrBuffer_0C(block)
	push bc
	call CopyBlockToAttrBuffer_0C
	pop bc
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> disable_interrupts()
	di
;> WaitVRAMAccess()
	call WaitVRAMAccess
;> rVBK = 1                              # the attribute map
	ld a, $01
	ldh [rVBK], a
;> enable_interrupts()
	ei
;> WriteBlockToBGMap_0C(block)
	call WriteBlockToBGMap_0C
;> disable_interrupts()
	di
;> WaitVRAMAccess()
	call WaitVRAMAccess
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> enable_interrupts()
	ei
	ret


;@ def CopyBlockToAttrBuffer_0C(block: bc)
;@ path: event/script
;@ Stores the values of an attribute block in wScreenMap (SetAttrNibble_0C); the block's
;@ offset is the number of the first map cell.
;@ test: skip reads a block through a pointer from the script
CopyBlockToAttrBuffer_0C::
;> cell = mem16[block]; block += 2
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc

.row
;>@rows while True:
;>     line = cell
	push hl

.next
;>@vals     while True:
;>         c = mem[block]; block += 1
	ld a, [bc]
	inc bc
;>         if c == 0xD9:
	cp $d9
	jr z, .end

;>@end             return
;>         if c == 0xD8:
	cp $d8
	jr nz, .value

;>             break
;>@val         SetAttrNibble_0C(cell, c); cell += 1
;>     cell = line
	pop hl
;>     cell += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@rows
	jr .row

.value
;=@val
	call SetAttrNibble_0C
	inc hl
;=@vals
	jr .next

.end
;=@end
	pop hl
	ret


;@ def SetAttrNibble_0C(cell: hl, value: a)
;@ path: event/script
;@ Stores the 4-bit `value` for map cell `cell` (0-1023) in wScreenMap: two cells per byte,
;@ the even cell in the high nibble, the odd one in the low nibble.
;@ test: skip writes through a pointer argument
SetAttrNibble_0C::
;> odd = cell & 1
	push hl
	srl h
	rr l
;> addr = wScreenMap + cell // 2
	push af
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c2
;> if not odd:
	ld h, a
	pop af
	jr c, .odd

;>     mem[addr] = ((value << 4) & 0xF0) | (mem[addr] & 0x0F)
	swap a
	and $f0
	ld d, a
	ld a, [hl]
	and $0f
	jr .store

.odd
;> else:
;>     mem[addr] = (value & 0x0F) | (mem[addr] & 0xF0)
	and $0f
	ld d, a
	ld a, [hl]
	and $f0

.store
	or d
	ld [hl], a
;> return
	pop hl
	ret


;@ path: event/script
;@ The map scripts of maps 0-5: one pointer per map number to its list of scripts (one
;@ pointer per wScriptId), then the lists and the scripts. A script is a run of 16-bit words
;@ read by the interpreter in bank 4: $FFxx is command xx, other words are its arguments
;@ (tile blocks, text numbers, positions); $FFFF ends the script. A tile block is a 2-byte
;@ offset from the screen corner (row * 32 + column), then tile numbers, $D8 for the next
;@ row, $D9 at the end.
MapScripts_0C::
	db $c6, $41, $fb, $55, $1d, $5e, $33, $66, $7f, $68, $cf, $71, $ee, $41, $ed, $50
	db $ff, $50, $11, $51, $91, $51, $11, $52, $23, $52, $35, $52, $3d, $52, $47, $52
	db $77, $52, $d1, $52, $d5, $52, $01, $53, $df, $54, $6b, $55, $6f, $55, $87, $55
	db $a9, $55, $e9, $55, $0e, $ff, $01, $00, $46, $42, $0e, $ff, $05, $00, $fc, $41
	db $ff, $ff, $15, $ff, $51, $d9, $ff, $00, $12, $42, $01, $ff, $f1, $00, $fa, $41
	db $01, $ff, $ee, $00, $a8, $50, $ff, $ff, $0d, $ff, $00, $00, $90, $ff, $00, $00
	db $08, $ff, $0b, $ff, $04, $00, $20, $00, $07, $ff, $15, $00, $06, $ff, $0b, $ff
	db $04, $00, $80, $ff, $03, $ff, $01, $00, $12, $ff, $2c, $d9, $01, $00, $12, $ff
	db $2d, $d9, $01, $00, $12, $ff, $51, $d9, $00, $00, $ff, $ff, $15, $ff, $2b, $d9
	db $00, $00, $70, $42, $15, $ff, $2b, $d9, $04, $00, $70, $42, $15, $ff, $2b, $d9
	db $06, $00, $0a, $49, $15, $ff, $2b, $d9, $07, $00, $e0, $47, $15, $ff, $2b, $d9
	db $08, $00, $0a, $49, $ff, $ff, $01, $ff, $f1, $00, $fa, $41, $01, $ff, $ee, $00
	db $ba, $44, $01, $ff, $9a, $00, $fa, $41, $01, $ff, $37, $00, $38, $44, $01, $ff
	db $69, $00, $fa, $41, $01, $ff, $33, $00, $0c, $44, $01, $ff, $3e, $00, $fa, $41
	db $01, $ff, $30, $00, $8c, $43, $01, $ff, $08, $00, $fa, $41, $01, $ff, $07, $00
	db $ec, $42, $01, $ff, $02, $00, $fa, $41, $10, $ff, $00, $00, $e8, $00, $0b, $ff
	db $00, $00, $e0, $ff, $07, $ff, $20, $00, $06, $ff, $12, $ff, $f4, $c8, $00, $00
	db $13, $ff, $f2, $c8, $42, $ca, $04, $ff, $0f, $00, $00, $00, $29, $ff, $01, $00
	db $07, $ff, $21, $00, $06, $ff, $03, $ff, $02, $00, $12, $ff, $2c, $d9, $02, $00
	db $ff, $ff, $10, $ff, $00, $00, $e8, $00, $0b, $ff, $00, $00, $e0, $ff, $07, $ff
	db $45, $00, $06, $ff, $22, $ff, $1b, $ff, $02, $00, $60, $00, $19, $ff, $09, $ff
	db $18, $00, $22, $ff, $1b, $ff, $02, $00, $a0, $ff, $19, $ff, $48, $ff, $02, $00
	db $0d, $ff, $04, $00, $00, $00, $00, $00, $22, $ff, $1b, $ff, $04, $00, $e0, $ff
	db $19, $ff, $07, $ff, $46, $00, $47, $00, $48, $00, $49, $00, $06, $ff, $4c, $ff
	db $0b, $ff, $00, $00, $f0, $ff, $3d, $ff, $07, $ff, $4a, $00, $06, $ff, $09, $ff
	db $02, $00, $1c, $ff, $04, $04, $19, $ff, $09, $ff, $02, $00, $3d, $ff, $07, $ff
	db $4b, $00, $4c, $00, $06, $ff, $03, $ff, $08, $00, $12, $ff, $2b, $d9, $01, $00
	db $12, $ff, $2c, $d9, $03, $00, $12, $ff, $3c, $d9, $01, $00, $12, $ff, $3f, $d9
	db $01, $00, $12, $ff, $40, $d9, $01, $00, $12, $ff, $44, $d9, $01, $00, $14, $ff
	db $ee, $46, $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff, $00, $00, $12, $ff
	db $ec, $c8, $00, $00, $12, $ff, $ed, $c8, $0e, $00, $0d, $ff, $06, $00, $00, $00
	db $00, $00, $08, $ff, $07, $ff, $47, $01, $0b, $ff, $06, $00, $d0, $ff, $09, $ff
	db $02, $00, $07, $ff, $48, $01, $09, $ff, $02, $00, $49, $ff, $06, $00, $09, $ff
	db $02, $00, $07, $ff, $49, $01, $09, $ff, $02, $00, $47, $ff, $06, $00, $09, $ff
	db $02, $00, $07, $ff, $4a, $01, $09, $ff, $02, $00, $48, $ff, $06, $00, $09, $ff
	db $02, $00, $0b, $ff, $06, $00, $30, $00, $0d, $ff, $06, $00, $00, $00, $40, $00
	db $07, $ff, $4b, $01, $03, $ff, $3e, $00, $12, $ff, $2b, $d9, $03, $00, $14, $ff
	db $ee, $46, $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff, $00, $00, $12, $ff
	db $ec, $c8, $00, $00, $12, $ff, $ed, $c8, $0e, $00, $08, $ff, $07, $ff, $72, $02
	db $03, $ff, $69, $00, $12, $ff, $2b, $d9, $03, $00, $14, $ff, $ee, $46, $0d, $ff
	db $00, $00, $90, $ff, $00, $00, $47, $ff, $00, $00, $12, $ff, $ec, $c8, $00, $00
	db $12, $ff, $ed, $c8, $0e, $00, $0d, $ff, $06, $00, $00, $00, $00, $00, $08, $ff
	db $07, $ff, $10, $04, $0b, $ff, $06, $00, $d0, $ff, $09, $ff, $02, $00, $07, $ff
	db $11, $04, $12, $04, $09, $ff, $02, $00, $49, $ff, $06, $00, $09, $ff, $02, $00
	db $07, $ff, $13, $04, $09, $ff, $02, $00, $47, $ff, $06, $00, $09, $ff, $02, $00
	db $07, $ff, $14, $04, $09, $ff, $02, $00, $48, $ff, $06, $00, $09, $ff, $02, $00
	db $0b, $ff, $06, $00, $30, $00, $0d, $ff, $06, $00, $00, $00, $40, $00, $07, $ff
	db $15, $04, $03, $ff, $9a, $00, $12, $ff, $2b, $d9, $03, $00, $14, $ff, $ee, $46
	db $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff, $00, $00, $12, $ff, $ec, $c8
	db $00, $00, $12, $ff, $ed, $c8, $0e, $00, $08, $ff, $0b, $ff, $03, $00, $f0, $ff
	db $0a, $ff, $03, $00, $f0, $ff, $4a, $ff, $03, $00, $09, $ff, $02, $00, $0b, $ff
	db $00, $00, $e0, $ff, $07, $ff, $b8, $05, $12, $ff, $ed, $c8, $0f, $00, $0d, $ff
	db $07, $00, $00, $00, $00, $00, $08, $ff, $0a, $ff, $00, $00, $10, $00, $0b, $ff
	db $00, $00, $10, $00, $0a, $ff, $00, $00, $f0, $ff, $0b, $ff, $00, $00, $f0, $ff
	db $47, $ff, $00, $00, $08, $ff, $45, $ff, $16, $ff, $15, $ff, $b9, $ca, $01, $00
	db $ac, $45, $21, $ff, $00, $00, $0d, $ff, $08, $00, $00, $00, $00, $00, $12, $ff
	db $9b, $c8, $00, $00, $09, $ff, $01, $00, $12, $ff, $9b, $c8, $d2, $00, $48, $ff
	db $07, $00, $09, $ff, $08, $00, $12, $ff, $ed, $c8, $0d, $00, $0d, $ff, $08, $00
	db $00, $00, $40, $00, $0d, $ff, $08, $00, $18, $00, $f8, $00, $15, $ff, $b9, $ca
	db $02, $00, $ac, $45, $21, $ff, $00, $00, $0d, $ff, $08, $00, $00, $00, $00, $00
	db $12, $ff, $9b, $c8, $00, $00, $09, $ff, $01, $00, $12, $ff, $9b, $c8, $d2, $00
	db $09, $ff, $08, $00, $12, $ff, $ed, $c8, $09, $00, $0d, $ff, $08, $00, $00, $00
	db $40, $00, $0d, $ff, $08, $00, $18, $00, $f8, $00, $0d, $ff, $08, $00, $1a, $00
	db $58, $00, $21, $ff, $00, $00, $0d, $ff, $08, $00, $00, $00, $00, $00, $12, $ff
	db $9b, $c8, $00, $00, $09, $ff, $01, $00, $12, $ff, $9b, $c8, $d2, $00, $09, $ff
	db $01, $00, $12, $ff, $9b, $c8, $00, $00, $09, $ff, $01, $00, $12, $ff, $9b, $c8
	db $d2, $00, $15, $ff, $b9, $ca, $01, $00, $f0, $45, $15, $ff, $b9, $ca, $02, $00
	db $f0, $45, $4a, $ff, $07, $00, $09, $ff, $08, $00, $12, $ff, $ed, $c8, $01, $00
	db $0d, $ff, $08, $00, $00, $00, $40, $00, $09, $ff, $08, $00, $1c, $ff, $07, $01
	db $19, $ff, $09, $ff, $04, $00, $48, $ff, $07, $00, $09, $ff, $04, $00, $1c, $ff
	db $07, $04, $19, $ff, $09, $ff, $04, $00, $0d, $ff, $07, $00, $00, $00, $40, $00
	db $12, $ff, $ed, $c8, $00, $00, $09, $ff, $04, $00, $07, $ff, $b9, $05, $22, $ff
	db $1a, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff
	db $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00
	db $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00, $10, $00
	db $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff
	db $09, $ff, $02, $00, $0a, $ff, $02, $00, $10, $00, $49, $ff, $02, $00, $09, $ff
	db $02, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff, $03, $00
	db $24, $ff, $e2, $50, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff
	db $01, $00, $21, $ff, $51, $00, $09, $ff, $01, $00, $0d, $ff, $05, $00, $00, $00
	db $40, $00, $48, $ff, $02, $00, $09, $ff, $08, $00, $03, $ff, $f1, $00, $12, $ff
	db $2b, $d9, $05, $00, $12, $ff, $2c, $d9, $04, $00, $12, $ff, $2d, $d9, $03, $00
	db $12, $ff, $33, $d9, $02, $00, $12, $ff, $34, $d9, $02, $00, $12, $ff, $ed, $c8
	db $00, $00, $ff, $ff, $22, $ff, $1a, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff
	db $03, $00, $22, $ff, $1b, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00
	db $22, $ff, $1a, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff
	db $1a, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff
	db $05, $00, $f0, $ff, $19, $ff, $09, $ff, $02, $00, $0a, $ff, $02, $00, $10, $00
	db $49, $ff, $02, $00, $09, $ff, $02, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff
	db $19, $ff, $09, $ff, $03, $00, $24, $ff, $e2, $50, $22, $ff, $1b, $ff, $05, $00
	db $f0, $ff, $19, $ff, $09, $ff, $01, $00, $21, $ff, $51, $00, $09, $ff, $01, $00
	db $0d, $ff, $05, $00, $00, $00, $40, $00, $0a, $ff, $02, $00, $f0, $ff, $48, $ff
	db $02, $00, $01, $ff, $ee, $00, $9a, $47, $01, $ff, $37, $00, $b6, $47, $01, $ff
	db $33, $00, $9a, $47, $01, $ff, $30, $00, $a2, $47, $01, $ff, $07, $00, $9a, $47
	db $12, $ff, $ed, $c8, $00, $00, $ff, $ff, $09, $ff, $08, $00, $49, $ff, $00, $00
	db $07, $ff, $4c, $01, $12, $ff, $ed, $c8, $00, $00, $ff, $ff, $09, $ff, $08, $00
	db $49, $ff, $00, $00, $07, $ff, $16, $04, $06, $ff, $12, $ff, $8a, $c8, $03, $00
	db $12, $ff, $8b, $c8, $03, $00, $3e, $ff, $08, $ff, $07, $ff, $17, $04, $12, $ff
	db $ed, $c8, $00, $00, $ff, $ff, $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff
	db $00, $00, $12, $ff, $ec, $c8, $00, $00, $12, $ff, $ed, $c8, $0e, $00, $01, $ff
	db $1d, $00, $04, $48, $01, $ff, $33, $00, $70, $49, $15, $ff, $e3, $d9, $4e, $00
	db $c6, $4e, $15, $ff, $e3, $d9, $4d, $00, $bc, $4e, $15, $ff, $e3, $d9, $4c, $00
	db $b2, $4e, $15, $ff, $e3, $d9, $4b, $00, $a8, $4e, $15, $ff, $e3, $d9, $4a, $00
	db $9e, $4e, $15, $ff, $e3, $d9, $49, $00, $94, $4e, $15, $ff, $e3, $d9, $48, $00
	db $8a, $4e, $15, $ff, $e3, $d9, $c7, $00, $80, $4e, $15, $ff, $e3, $d9, $47, $00
	db $76, $4e, $15, $ff, $e3, $d9, $46, $00, $48, $4e, $15, $ff, $e3, $d9, $45, $00
	db $98, $4c, $01, $ff, $f1, $00, $80, $49, $15, $ff, $e3, $d9, $44, $00, $8e, $4c
	db $15, $ff, $e3, $d9, $43, $00, $84, $4c, $15, $ff, $e3, $d9, $42, $00, $58, $4c
	db $15, $ff, $e3, $d9, $41, $00, $2c, $4c, $15, $ff, $e3, $d9, $3f, $00, $22, $4c
	db $15, $ff, $e3, $d9, $3e, $00, $f6, $4b, $15, $ff, $e3, $d9, $3d, $00, $ec, $4b
	db $15, $ff, $e3, $d9, $3b, $00, $e2, $4b, $15, $ff, $e3, $d9, $3a, $00, $b6, $4b
	db $15, $ff, $e3, $d9, $10, $00, $ac, $4b, $15, $ff, $e3, $d9, $39, $00, $80, $4b
	db $15, $ff, $e3, $d9, $3c, $00, $f0, $4a, $15, $ff, $e3, $d9, $38, $00, $e6, $4a
	db $15, $ff, $e3, $d9, $37, $00, $dc, $4a, $15, $ff, $e3, $d9, $36, $00, $b0, $4a
	db $15, $ff, $e3, $d9, $35, $00, $84, $4a, $15, $ff, $e3, $d9, $34, $00, $7a, $4a
	db $15, $ff, $e3, $d9, $33, $00, $4e, $4a, $15, $ff, $e3, $d9, $32, $00, $44, $4a
	db $15, $ff, $e3, $d9, $31, $00, $18, $4a, $15, $ff, $e3, $d9, $30, $00, $ac, $49
	db $0d, $ff, $00, $00, $90, $ff, $00, $00, $49, $ff, $00, $00, $12, $ff, $ec, $c8
	db $00, $00, $12, $ff, $ed, $c8, $0e, $00, $01, $ff, $09, $00, $30, $49, $0d, $ff
	db $04, $00, $00, $00, $00, $00, $00, $ff, $f1, $00, $46, $49, $0d, $ff, $02, $00
	db $00, $00, $40, $00, $0d, $ff, $05, $00, $00, $00, $00, $00, $08, $ff, $12, $ff
	db $2b, $d9, $05, $00, $01, $ff, $f1, $00, $66, $49, $12, $ff, $2b, $d9, $03, $00
	db $01, $ff, $09, $00, $66, $49, $12, $ff, $2b, $d9, $01, $00, $12, $ff, $e3, $d9
	db $ff, $00, $14, $ff, $00, $50, $08, $ff, $07, $ff, $75, $02, $12, $ff, $2b, $d9
	db $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $c5, $05, $1c, $ff, $01, $04
	db $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01
	db $06, $ff, $3d, $ff, $07, $ff, $ce, $07, $12, $ff, $2b, $d9, $05, $00, $14, $ff
	db $d6, $4e, $0d, $ff, $04, $00, $00, $00, $00, $00, $08, $ff, $07, $ff, $5a, $00
	db $1c, $ff, $04, $04, $19, $ff, $09, $ff, $02, $00, $4a, $ff, $04, $00, $09, $ff
	db $02, $00, $47, $ff, $04, $00, $09, $ff, $02, $00, $49, $ff, $04, $00, $09, $ff
	db $02, $00, $07, $ff, $5b, $00, $0b, $ff, $04, $00, $20, $00, $0d, $ff, $04, $00
	db $00, $00, $40, $00, $07, $ff, $5c, $00, $03, $ff, $09, $00, $12, $ff, $2b, $d9
	db $03, $00, $12, $ff, $2c, $d9, $04, $00, $12, $ff, $2d, $d9, $02, $00, $12, $ff
	db $2f, $d9, $01, $00, $12, $ff, $3c, $d9, $02, $00, $14, $ff, $6a, $4f, $08, $ff
	db $07, $ff, $4d, $01, $1c, $ff, $01, $04, $19, $ff, $4d, $ff, $06, $00, $4a, $ff
	db $01, $00, $3c, $ff, $07, $ff, $41, $01, $06, $ff, $3d, $ff, $07, $ff, $4e, $01
	db $12, $ff, $2b, $d9, $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $51, $01
	db $14, $ff, $1e, $4a, $08, $ff, $07, $ff, $ab, $01, $1c, $ff, $01, $04, $19, $ff
	db $4d, $ff, $06, $00, $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01, $06, $ff
	db $3d, $ff, $07, $ff, $ac, $01, $12, $ff, $2b, $d9, $03, $00, $14, $ff, $6a, $4f
	db $08, $ff, $07, $ff, $ae, $01, $14, $ff, $54, $4a, $08, $ff, $07, $ff, $1a, $02
	db $1c, $ff, $01, $04, $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00, $3c, $ff
	db $07, $ff, $41, $01, $06, $ff, $3d, $ff, $07, $ff, $4e, $01, $12, $ff, $2b, $d9
	db $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $f4, $01, $1c, $ff, $01, $04
	db $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01
	db $06, $ff, $3d, $ff, $07, $ff, $ac, $01, $12, $ff, $2b, $d9, $03, $00, $14, $ff
	db $6a, $4f, $08, $ff, $07, $ff, $f2, $01, $14, $ff, $b6, $4a, $08, $ff, $07, $ff
	db $b6, $03, $14, $ff, $b6, $4a, $0d, $ff, $06, $00, $00, $00, $00, $00, $08, $ff
	db $07, $ff, $a9, $02, $0b, $ff, $06, $00, $f0, $ff, $09, $ff, $08, $00, $0b, $ff
	db $06, $00, $f0, $ff, $09, $ff, $08, $00, $0b, $ff, $06, $00, $f0, $ff, $09, $ff
	db $08, $00, $07, $ff, $aa, $02, $09, $ff, $04, $00, $49, $ff, $06, $00, $09, $ff
	db $04, $00, $07, $ff, $ab, $02, $09, $ff, $04, $00, $47, $ff, $06, $00, $09, $ff
	db $04, $00, $07, $ff, $ac, $02, $09, $ff, $08, $00, $48, $ff, $06, $00, $09, $ff
	db $08, $00, $0b, $ff, $06, $00, $10, $00, $09, $ff, $08, $00, $0b, $ff, $06, $00
	db $10, $00, $09, $ff, $08, $00, $0b, $ff, $06, $00, $10, $00, $0d, $ff, $06, $00
	db $00, $00, $40, $00, $09, $ff, $08, $00, $07, $ff, $ad, $02, $12, $ff, $2b, $d9
	db $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $b6, $02, $1c, $ff, $01, $04
	db $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01
	db $06, $ff, $3d, $ff, $07, $ff, $63, $08, $12, $ff, $2b, $d9, $03, $00, $14, $ff
	db $6a, $4f, $08, $ff, $07, $ff, $50, $01, $14, $ff, $86, $4b, $08, $ff, $07, $ff
	db $37, $03, $1c, $ff, $01, $04, $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00
	db $3c, $ff, $07, $ff, $41, $01, $06, $ff, $3d, $ff, $07, $ff, $b7, $02, $12, $ff
	db $2b, $d9, $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $3a, $03, $14, $ff
	db $bc, $4b, $08, $ff, $07, $ff, $3b, $03, $14, $ff, $bc, $4b, $08, $ff, $07, $ff
	db $66, $03, $1c, $ff, $01, $04, $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00
	db $3c, $ff, $07, $ff, $41, $01, $06, $ff, $3d, $ff, $07, $ff, $67, $03, $12, $ff
	db $2b, $d9, $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $69, $03, $14, $ff
	db $fc, $4b, $08, $ff, $07, $ff, $40, $01, $1c, $ff, $01, $04, $19, $ff, $4d, $ff
	db $06, $00, $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01, $06, $ff, $3d, $ff
	db $07, $ff, $42, $01, $12, $ff, $2b, $d9, $03, $00, $14, $ff, $6a, $4f, $08, $ff
	db $07, $ff, $e5, $03, $1c, $ff, $01, $04, $19, $ff, $4d, $ff, $06, $00, $4a, $ff
	db $01, $00, $3c, $ff, $07, $ff, $41, $01, $06, $ff, $3d, $ff, $07, $ff, $67, $03
	db $12, $ff, $2b, $d9, $03, $00, $14, $ff, $6a, $4f, $08, $ff, $07, $ff, $e6, $03
	db $14, $ff, $5e, $4c, $08, $ff, $07, $ff, $6a, $03, $14, $ff, $5e, $4c, $08, $ff
	db $07, $ff, $85, $04, $09, $ff, $04, $00, $41, $ff, $02, $00, $12, $ff, $9b, $c8
	db $d2, $00, $12, $ff, $9c, $c8, $d2, $00, $12, $ff, $9d, $c8, $e2, $00, $09, $ff
	db $02, $00, $12, $ff, $9b, $c8, $e7, $00, $12, $ff, $9c, $c8, $e7, $00, $12, $ff
	db $9d, $c8, $f7, $00, $09, $ff, $02, $00, $12, $ff, $9b, $c8, $fb, $00, $12, $ff
	db $9c, $c8, $fb, $00, $12, $ff, $9d, $c8, $fb, $00, $09, $ff, $02, $00, $12, $ff
	db $9b, $c8, $ff, $00, $12, $ff, $9c, $c8, $ff, $00, $12, $ff, $9d, $c8, $ff, $00
	db $12, $ff, $ec, $c8, $01, $00, $09, $ff, $08, $00, $62, $ff, $12, $ff, $9b, $c8
	db $d2, $00, $08, $ff, $07, $ff, $d1, $08, $06, $ff, $12, $ff, $9b, $c8, $ff, $00
	db $08, $ff, $63, $ff, $27, $ff, $16, $ff, $41, $ff, $3f, $00, $46, $ff, $09, $ff
	db $18, $00, $12, $ff, $ec, $c8, $00, $00, $12, $ff, $9b, $c8, $ff, $00, $12, $ff
	db $9c, $c8, $ff, $00, $12, $ff, $9d, $c8, $ff, $00, $09, $ff, $02, $00, $12, $ff
	db $9b, $c8, $fb, $00, $12, $ff, $9c, $c8, $fb, $00, $12, $ff, $9d, $c8, $fb, $00
	db $09, $ff, $02, $00, $12, $ff, $9b, $c8, $e7, $00, $12, $ff, $9c, $c8, $e7, $00
	db $12, $ff, $9d, $c8, $f7, $00, $09, $ff, $02, $00, $12, $ff, $9b, $c8, $d2, $00
	db $12, $ff, $9c, $c8, $d2, $00, $12, $ff, $9d, $c8, $e2, $00, $09, $ff, $04, $00
	db $41, $ff, $09, $00, $09, $ff, $02, $00, $07, $ff, $86, $04, $1c, $ff, $01, $04
	db $19, $ff, $4d, $ff, $06, $00, $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01
	db $06, $ff, $3d, $ff, $07, $ff, $88, $04, $12, $ff, $2b, $d9, $03, $00, $22, $ff
	db $1a, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff
	db $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00
	db $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00, $10, $00
	db $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff
	db $09, $ff, $02, $00, $0a, $ff, $02, $00, $10, $00, $49, $ff, $02, $00, $09, $ff
	db $02, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff, $03, $00
	db $24, $ff, $e2, $50, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff
	db $01, $00, $21, $ff, $51, $00, $09, $ff, $01, $00, $0d, $ff, $05, $00, $00, $00
	db $40, $00, $0a, $ff, $02, $00, $f0, $ff, $48, $ff, $02, $00, $ff, $ff, $08, $ff
	db $07, $ff, $c2, $05, $c3, $05, $1c, $ff, $01, $04, $19, $ff, $4d, $ff, $06, $00
	db $4a, $ff, $01, $00, $3c, $ff, $07, $ff, $41, $01, $06, $ff, $3d, $ff, $07, $ff
	db $c4, $05, $12, $ff, $2b, $d9, $05, $00, $14, $ff, $d6, $4e, $08, $ff, $07, $ff
	db $c6, $05, $14, $ff, $4e, $4e, $08, $ff, $07, $ff, $c7, $05, $14, $ff, $4e, $4e
	db $08, $ff, $07, $ff, $c8, $05, $14, $ff, $4e, $4e, $08, $ff, $07, $ff, $c9, $05
	db $14, $ff, $4e, $4e, $08, $ff, $07, $ff, $ca, $05, $14, $ff, $4e, $4e, $08, $ff
	db $07, $ff, $cb, $05, $14, $ff, $4e, $4e, $08, $ff, $07, $ff, $cc, $05, $14, $ff
	db $4e, $4e, $08, $ff, $07, $ff, $cd, $05, $14, $ff, $4e, $4e, $08, $ff, $07, $ff
	db $ce, $05, $12, $ff, $2b, $d9, $05, $00, $14, $ff, $d6, $4e, $22, $ff, $1a, $ff
	db $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff, $05, $00
	db $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00, $10, $00
	db $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00, $10, $00, $19, $ff
	db $09, $ff, $03, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff
	db $02, $00, $0a, $ff, $02, $00, $10, $00, $49, $ff, $02, $00, $09, $ff, $02, $00
	db $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff, $03, $00, $24, $ff
	db $e2, $50, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff, $01, $00
	db $21, $ff, $51, $00, $09, $ff, $01, $00, $0d, $ff, $05, $00, $00, $00, $40, $00
	db $48, $ff, $02, $00, $09, $ff, $08, $00, $49, $ff, $00, $00, $14, $ff, $00, $50
	db $22, $ff, $1a, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff
	db $1b, $ff, $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff
	db $05, $00, $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1a, $ff, $05, $00
	db $10, $00, $19, $ff, $09, $ff, $03, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff
	db $19, $ff, $09, $ff, $02, $00, $0a, $ff, $02, $00, $10, $00, $49, $ff, $02, $00
	db $09, $ff, $02, $00, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff, $09, $ff
	db $03, $00, $24, $ff, $e2, $50, $22, $ff, $1b, $ff, $05, $00, $f0, $ff, $19, $ff
	db $09, $ff, $01, $00, $21, $ff, $51, $00, $09, $ff, $01, $00, $0d, $ff, $05, $00
	db $00, $00, $40, $00, $0a, $ff, $02, $00, $f0, $ff, $48, $ff, $02, $00, $09, $ff
	db $08, $00, $49, $ff, $00, $00, $07, $ff, $4e, $00, $12, $ff, $9b, $c8, $00, $00
	db $12, $ff, $9c, $c8, $ff, $00, $12, $ff, $9d, $c8, $ff, $00, $4d, $ff, $06, $00
	db $12, $ff, $9b, $c8, $d2, $00, $12, $ff, $9c, $c8, $d2, $00, $12, $ff, $9d, $c8
	db $e2, $00, $09, $ff, $01, $00, $12, $ff, $ed, $c8, $00, $00, $12, $ff, $9b, $c8
	db $2d, $00, $12, $ff, $9c, $c8, $ff, $00, $12, $ff, $9d, $c8, $ff, $00, $4d, $ff
	db $06, $00, $12, $ff, $9b, $c8, $d2, $00, $12, $ff, $9c, $c8, $d2, $00, $12, $ff
	db $9d, $c8, $e2, $00, $09, $ff, $04, $00, $27, $ff, $16, $ff, $15, $ff, $e3, $d9
	db $30, $00, $8a, $50, $15, $ff, $e3, $d9, $3c, $00, $90, $50, $2c, $ff, $84, $50
	db $07, $ff, $cb, $08, $2a, $ff, $01, $00, $ff, $ff, $07, $ff, $cc, $08, $ff, $ff
	db $07, $ff, $5e, $00, $ff, $ff, $12, $ff, $8a, $c8, $03, $00, $12, $ff, $8b, $c8
	db $03, $00, $3e, $ff, $08, $ff, $07, $ff, $ae, $02, $ff, $ff, $ff, $ff, $0d, $ff
	db $05, $00, $00, $00, $00, $00, $08, $ff, $0b, $ff, $04, $00, $20, $00, $07, $ff
	db $b7, $05, $06, $ff, $1b, $ff, $04, $00, $70, $ff, $1b, $ff, $05, $00, $70, $ff
	db $19, $ff, $12, $ff, $2c, $d9, $03, $00, $12, $ff, $2d, $d9, $04, $00, $0f, $ff
	db $00, $00, $e8, $00, $78, $00, $ff, $ff, $2e, $00, $44, $45, $d8, $70, $71, $d8
	db $72, $73, $d9, $24, $00, $15, $ff, $3c, $c8, $01, $00, $fb, $50, $25, $00, $ff
	db $ff, $26, $00, $ff, $ff, $27, $00, $15, $ff, $3c, $c8, $01, $00, $0d, $51, $28
	db $00, $ff, $ff, $26, $00, $ff, $ff, $01, $ff, $3a, $00, $83, $51, $01, $ff, $3b
	db $00, $55, $51, $01, $ff, $08, $00, $27, $51, $79, $03, $ff, $ff, $21, $ff, $60
	db $00, $24, $ff, $87, $51, $07, $ff, $1b, $00, $2c, $ff, $49, $51, $1c, $00, $03
	db $ff, $3a, $00, $12, $ff, $2a, $d9, $01, $00, $2a, $ff, $01, $00, $ff, $ff, $1d
	db $00, $21, $ff, $60, $00, $24, $ff, $8c, $51, $ff, $ff, $21, $ff, $60, $00, $24
	db $ff, $87, $51, $07, $ff, $1b, $00, $2c, $ff, $77, $51, $1c, $00, $03, $ff, $3a
	db $00, $12, $ff, $2a, $d9, $03, $00, $2a, $ff, $01, $00, $ff, $ff, $1d, $00, $21
	db $ff, $60, $00, $24, $ff, $8c, $51, $ff, $ff, $3c, $01, $ff, $ff, $86, $00, $0c
	db $0d, $d9, $86, $00, $0e, $0f, $d9, $01, $ff, $3b, $00, $03, $52, $01, $ff, $3a
	db $00, $d5, $51, $01, $ff, $08, $00, $a7, $51, $79, $03, $ff, $ff, $21, $ff, $60
	db $00, $24, $ff, $07, $52, $07, $ff, $1e, $00, $2c, $ff, $c9, $51, $27, $01, $03
	db $ff, $3b, $00, $12, $ff, $2a, $d9, $02, $00, $2a, $ff, $01, $00, $ff, $ff, $28
	db $01, $21, $ff, $60, $00, $24, $ff, $0c, $52, $ff, $ff, $21, $ff, $60, $00, $24
	db $ff, $07, $52, $07, $ff, $1e, $00, $2c, $ff, $f7, $51, $27, $01, $03, $ff, $3b
	db $00, $12, $ff, $2a, $d9, $03, $00, $2a, $ff, $01, $00, $ff, $ff, $28, $01, $21
	db $ff, $60, $00, $24, $ff, $0c, $52, $ff, $ff, $3c, $01, $ff, $ff, $88, $00, $0c
	db $0d, $d9, $88, $00, $0e, $0f, $d9, $3b, $08, $2c, $ff, $1f, $52, $3c, $08, $2a
	db $ff, $17, $00, $ff, $ff, $3d, $08, $ff, $ff, $3b, $08, $2c, $ff, $31, $52, $3e
	db $08, $2a, $ff, $1d, $00, $ff, $ff, $3d, $08, $ff, $ff, $40, $08, $33, $ff, $10
	db $27, $ff, $ff, $41, $08, $05, $ff, $e0, $01, $27, $ff, $ff, $ff, $01, $ff, $f1
	db $00, $73, $52, $01, $ff, $37, $00, $6f, $52, $01, $ff, $32, $00, $5d, $52, $23
	db $00, $ff, $ff, $e4, $01, $15, $ff, $3c, $c8, $01, $00, $6b, $52, $e6, $01, $ff
	db $ff, $e5, $01, $ff, $ff, $0f, $04, $ff, $ff, $bb, $05, $ff, $ff, $01, $ff, $f1
	db $00, $cd, $52, $01, $ff, $18, $01, $c9, $52, $01, $ff, $37, $00, $af, $52, $01
	db $ff, $32, $00, $9d, $52, $01, $ff, $08, $00, $99, $52, $22, $00, $ff, $ff, $53
	db $00, $ff, $ff, $e7, $01, $15, $ff, $3c, $c8, $01, $00, $ab, $52, $e9, $01, $ff
	db $ff, $e8, $01, $ff, $ff, $0b, $04, $15, $ff, $3c, $c8, $01, $00, $c1, $52, $0c
	db $04, $03, $ff, $18, $01, $ff, $ff, $0d, $04, $03, $ff, $18, $01, $ff, $ff, $0e
	db $04, $ff, $ff, $ba, $05, $ff, $ff, $2a, $00, $ff, $ff, $01, $ff, $f1, $00, $fd
	db $52, $01, $ff, $25, $00, $f9, $52, $01, $ff, $32, $00, $f5, $52, $01, $ff, $08
	db $00, $f1, $52, $2f, $00, $ff, $ff, $4f, $00, $ff, $ff, $f5, $01, $ff, $ff, $8c
	db $04, $ff, $ff, $c1, $05, $ff, $ff, $01, $ff, $f1, $00, $cd, $54, $01, $ff, $ac
	db $00, $bb, $54, $01, $ff, $25, $00, $b3, $54, $01, $ff, $37, $00, $a1, $54, $01
	db $ff, $36, $00, $73, $54, $01, $ff, $35, $00, $45, $54, $01, $ff, $34, $00, $17
	db $54, $01, $ff, $1d, $00, $e9, $53, $01, $ff, $33, $00, $e5, $53, $01, $ff, $32
	db $00, $b7, $53, $01, $ff, $31, $00, $89, $53, $01, $ff, $30, $00, $69, $53, $01
	db $ff, $03, $00, $57, $53, $2c, $00, $03, $ff, $03, $00, $ff, $ff, $2d, $00, $15
	db $ff, $3c, $c8, $01, $00, $65, $53, $2e, $00, $ff, $ff, $1a, $00, $ff, $ff, $52
	db $01, $15, $ff, $3c, $c8, $01, $00, $81, $53, $54, $01, $15, $ff, $3c, $c8, $01
	db $00, $85, $53, $55, $01, $ff, $ff, $53, $01, $ff, $ff, $56, $01, $ff, $ff, $a5
	db $01, $15, $ff, $3c, $c8, $01, $00, $ab, $53, $a7, $01, $15, $ff, $3c, $c8, $01
	db $00, $af, $53, $a9, $01, $15, $ff, $3c, $c8, $01, $00, $b3, $53, $55, $01, $ff
	db $ff, $a6, $01, $ff, $ff, $a8, $01, $ff, $ff, $aa, $01, $ff, $ff, $ec, $01, $15
	db $ff, $3c, $c8, $01, $00, $d9, $53, $ee, $01, $15, $ff, $3c, $c8, $01, $00, $dd
	db $53, $a9, $01, $15, $ff, $3c, $c8, $01, $00, $e1, $53, $55, $01, $ff, $ff, $ed
	db $01, $ff, $ff, $ef, $01, $ff, $ff, $f1, $01, $ff, $ff, $74, $02, $ff, $ff, $b0
	db $02, $15, $ff, $3c, $c8, $01, $00, $0b, $54, $b2, $02, $15, $ff, $3c, $c8, $01
	db $00, $0f, $54, $a9, $01, $15, $ff, $3c, $c8, $01, $00, $13, $54, $55, $01, $ff
	db $ff, $b1, $02, $ff, $ff, $b3, $02, $ff, $ff, $b5, $02, $ff, $ff, $32, $03, $15
	db $ff, $3c, $c8, $01, $00, $39, $54, $34, $03, $15, $ff, $3c, $c8, $01, $00, $3d
	db $54, $a9, $01, $15, $ff, $3c, $c8, $01, $00, $41, $54, $55, $01, $ff, $ff, $33
	db $03, $ff, $ff, $35, $03, $ff, $ff, $36, $03, $ff, $ff, $61, $03, $15, $ff, $3c
	db $c8, $01, $00, $67, $54, $63, $03, $15, $ff, $3c, $c8, $01, $00, $6b, $54, $a9
	db $01, $15, $ff, $3c, $c8, $01, $00, $6f, $54, $55, $01, $ff, $ff, $62, $03, $ff
	db $ff, $64, $03, $ff, $ff, $65, $03, $ff, $ff, $e0, $03, $15, $ff, $3c, $c8, $01
	db $00, $95, $54, $e2, $03, $15, $ff, $3c, $c8, $01, $00, $99, $54, $a9, $01, $15
	db $ff, $3c, $c8, $01, $00, $9d, $54, $55, $01, $ff, $ff, $e1, $03, $ff, $ff, $e3
	db $03, $ff, $ff, $e4, $03, $ff, $ff, $19, $04, $15, $ff, $3c, $c8, $01, $00, $af
	db $54, $1b, $04, $ff, $ff, $1a, $04, $ff, $ff, $8a, $04, $03, $ff, $ac, $00, $ff
	db $ff, $2d, $00, $15, $ff, $3c, $c8, $01, $00, $c9, $54, $2e, $00, $ff, $ff, $8b
	db $04, $ff, $ff, $be, $05, $15, $ff, $3c, $c8, $01, $00, $db, $54, $bf, $05, $ff
	db $ff, $c0, $05, $ff, $ff, $00, $ff, $2f, $00, $eb, $54, $01, $ff, $11, $01, $67
	db $55, $01, $ff, $f1, $00, $63, $55, $01, $ff, $25, $00, $5f, $55, $01, $ff, $37
	db $00, $5b, $55, $01, $ff, $35, $00, $57, $55, $01, $ff, $1d, $00, $53, $55, $01
	db $ff, $33, $00, $4f, $55, $01, $ff, $49, $00, $4b, $55, $01, $ff, $32, $00, $47
	db $55, $01, $ff, $31, $00, $43, $55, $01, $ff, $30, $00, $3f, $55, $01, $ff, $09
	db $00, $3b, $55, $01, $ff, $08, $00, $37, $55, $2b, $00, $ff, $ff, $4d, $00, $ff
	db $ff, $5e, $00, $ff, $ff, $4c, $01, $ff, $ff, $a4, $01, $ff, $ff, $ea, $01, $ff
	db $ff, $eb, $01, $ff, $ff, $73, $02, $ff, $ff, $af, $02, $ff, $ff, $60, $03, $ff
	db $ff, $18, $04, $ff, $ff, $89, $04, $ff, $ff, $bc, $05, $ff, $ff, $bd, $05, $ff
	db $ff, $50, $00, $ff, $ff, $01, $ff, $08, $00, $83, $55, $01, $ff, $02, $00, $7f
	db $55, $16, $00, $ff, $ff, $30, $00, $ff, $ff, $51, $00, $ff, $ff, $01, $ff, $09
	db $00, $a5, $55, $01, $ff, $08, $00, $a1, $55, $01, $ff, $02, $00, $9d, $55, $17
	db $00, $ff, $ff, $31, $00, $ff, $ff, $52, $00, $ff, $ff, $5f, $00, $ff, $ff, $01
	db $ff, $f1, $00, $e5, $55, $01, $ff, $25, $00, $e1, $55, $01, $ff, $34, $00, $dd
	db $55, $01, $ff, $1d, $00, $d9, $55, $01, $ff, $32, $00, $d5, $55, $01, $ff, $09
	db $00, $d1, $55, $18, $00, $ff, $ff, $60, $00, $ff, $ff, $f6, $01, $ff, $ff, $b9
	db $02, $ff, $ff, $57, $08, $ff, $ff, $8d, $04, $ff, $ff, $cf, $05, $ff, $ff, $51
	db $08, $2c, $ff, $f7, $55, $4b, $08, $2a, $ff, $1e, $00, $ff, $ff, $4c, $08, $ff
	db $ff, $25, $56, $1d, $59, $2b, $59, $2f, $59, $73, $59, $8b, $59, $8f, $59, $93
	db $59, $cd, $59, $2b, $5a, $6b, $5a, $73, $5a, $8b, $5a, $8f, $5a, $d3, $5a, $eb
	db $5a, $2f, $5b, $9d, $5d, $cf, $5d, $f1, $5d, $07, $5e, $15, $ff, $51, $d9, $ff
	db $00, $41, $56, $0e, $ff, $00, $00, $99, $57, $0e, $ff, $01, $00, $47, $58, $0e
	db $ff, $0c, $00, $7f, $58, $ff, $ff, $0e, $ff, $0c, $00, $5b, $56, $0e, $ff, $08
	db $00, $bd, $56, $0e, $ff, $04, $00, $d7, $56, $0e, $ff, $00, $00, $37, $57, $ff
	db $ff, $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff, $00, $00, $08, $ff, $09
	db $ff, $04, $00, $48, $ff, $01, $00, $09, $ff, $02, $00, $07, $ff, $10, $00, $06
	db $ff, $1a, $ff, $01, $00, $f0, $ff, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a
	db $ff, $01, $00, $f0, $ff, $1a, $ff, $00, $00, $f0, $ff, $19, $ff, $1b, $ff, $01
	db $00, $f0, $ff, $1a, $ff, $00, $00, $f0, $ff, $19, $ff, $1b, $ff, $01, $00, $a0
	db $ff, $1b, $ff, $00, $00, $a0, $ff, $19, $ff, $0f, $ff, $01, $00, $28, $00, $78
	db $01, $ff, $ff, $08, $ff, $1b, $ff, $01, $00, $80, $ff, $1b, $ff, $00, $00, $80
	db $ff, $19, $ff, $0f, $ff, $01, $00, $28, $00, $f8, $00, $ff, $ff, $08, $ff, $1b
	db $ff, $01, $00, $e0, $ff, $1b, $ff, $00, $00, $e0, $ff, $19, $ff, $0d, $ff, $03
	db $00, $00, $00, $00, $00, $0b, $ff, $03, $00, $10, $00, $0a, $ff, $03, $00, $f0
	db $ff, $07, $ff, $11, $00, $06, $ff, $4a, $ff, $01, $00, $07, $ff, $12, $00, $06
	db $ff, $0b, $ff, $03, $00, $10, $00, $49, $ff, $03, $00, $4a, $ff, $00, $00, $07
	db $ff, $13, $00, $06, $ff, $1b, $ff, $01, $00, $90, $ff, $1b, $ff, $00, $00, $90
	db $ff, $19, $ff, $0f, $ff, $01, $00, $28, $00, $78, $00, $ff, $ff, $08, $ff, $1b
	db $ff, $01, $00, $f0, $ff, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a, $ff, $01
	db $00, $10, $00, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a, $ff, $01, $00, $20
	db $00, $1a, $ff, $00, $00, $20, $00, $19, $ff, $49, $ff, $01, $00, $07, $ff, $14
	db $00, $06, $ff, $47, $ff, $00, $00, $09, $ff, $01, $00, $0b, $ff, $00, $00, $f0
	db $ff, $21, $ff, $51, $00, $09, $ff, $02, $00, $0d, $ff, $00, $00, $90, $ff, $40
	db $00, $09, $ff, $04, $00, $0f, $ff, $00, $00, $e8, $00, $f8, $00, $ff, $ff, $01
	db $ff, $f1, $00, $b7, $57, $01, $ff, $ee, $00, $d9, $57, $01, $ff, $0a, $00, $b7
	db $57, $01, $ff, $09, $00, $b9, $57, $01, $ff, $01, $00, $b7, $57, $ff, $ff, $08
	db $ff, $07, $ff, $61, $00, $21, $ff, $55, $00, $22, $ff, $1b, $ff, $01, $00, $40
	db $00, $19, $ff, $03, $ff, $0a, $00, $12, $ff, $2d, $d9, $03, $00, $ff, $ff, $08
	db $ff, $1b, $ff, $01, $00, $f0, $ff, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a
	db $ff, $01, $00, $10, $00, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a, $ff, $01
	db $00, $20, $00, $1a, $ff, $00, $00, $20, $00, $19, $ff, $49, $ff, $01, $00, $07
	db $ff, $14, $00, $06, $ff, $47, $ff, $00, $00, $09, $ff, $01, $00, $0b, $ff, $00
	db $00, $f0, $ff, $21, $ff, $51, $00, $09, $ff, $02, $00, $0d, $ff, $00, $00, $90
	db $ff, $40, $00, $09, $ff, $04, $00, $12, $ff, $2c, $d9, $00, $00, $12, $ff, $2d
	db $d9, $03, $00, $0f, $ff, $00, $00, $e8, $00, $f8, $00, $ff, $ff, $01, $ff, $21
	db $00, $65, $58, $00, $ff, $1e, $01, $59, $58, $01, $ff, $ee, $00, $73, $58, $01
	db $ff, $43, $00, $65, $58, $01, $ff, $1e, $01, $67, $58, $ff, $ff, $12, $ff, $5e
	db $d9, $01, $00, $03, $ff, $43, $00, $ff, $ff, $12, $ff, $5e, $d9, $04, $00, $03
	db $ff, $43, $00, $ff, $ff, $01, $ff, $f1, $00, $8b, $58, $01, $ff, $ee, $00, $8d
	db $58, $ff, $ff, $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff, $00, $00, $08
	db $ff, $09, $ff, $08, $00, $12, $ff, $8a, $c8, $03, $00, $12, $ff, $8b, $c8, $03
	db $00, $3e, $ff, $08, $ff, $0d, $ff, $00, $00, $90, $ff, $00, $00, $47, $ff, $00
	db $00, $08, $ff, $09, $ff, $04, $00, $48, $ff, $01, $00, $09, $ff, $02, $00, $07
	db $ff, $b6, $05, $06, $ff, $1a, $ff, $01, $00, $f0, $ff, $1b, $ff, $00, $00, $f0
	db $ff, $19, $ff, $1a, $ff, $01, $00, $f0, $ff, $1a, $ff, $00, $00, $f0, $ff, $19
	db $ff, $1b, $ff, $01, $00, $f0, $ff, $1a, $ff, $00, $00, $f0, $ff, $19, $ff, $1b
	db $ff, $01, $00, $a0, $ff, $1b, $ff, $00, $00, $a0, $ff, $19, $ff, $12, $ff, $33
	db $d9, $03, $00, $12, $ff, $2d, $d9, $04, $00, $0f, $ff, $01, $00, $28, $00, $78
	db $00, $ff, $ff, $01, $ff, $02, $00, $27, $59, $19, $00, $ff, $ff, $32, $00, $ff
	db $ff, $1f, $00, $ff, $ff, $01, $ff, $f1, $00, $6f, $59, $01, $ff, $9b, $00, $6b
	db $59, $01, $ff, $37, $00, $63, $59, $01, $ff, $35, $00, $5f, $59, $01, $ff, $1d
	db $00, $5b, $59, $01, $ff, $32, $00, $57, $59, $2f, $01, $ff, $ff, $f7, $01, $ff
	db $ff, $ba, $02, $ff, $ff, $6b, $03, $ff, $ff, $1c, $04, $03, $ff, $9b, $00, $ff
	db $ff, $1d, $04, $ff, $ff, $d0, $05, $ff, $ff, $01, $ff, $f1, $00, $87, $59, $01
	db $ff, $25, $00, $83, $59, $62, $00, $ff, $ff, $8e, $04, $ff, $ff, $d1, $05, $ff
	db $ff, $63, $00, $ff, $ff, $64, $00, $ff, $ff, $01, $ff, $f1, $00, $c9, $59, $01
	db $ff, $9c, $00, $c5, $59, $01, $ff, $37, $00, $bd, $59, $01, $ff, $35, $00, $b9
	db $59, $01, $ff, $1d, $00, $b5, $59, $af, $01, $ff, $ff, $bb, $02, $ff, $ff, $6c
	db $03, $ff, $ff, $1e, $04, $03, $ff, $9c, $00, $ff, $ff, $1f, $04, $ff, $ff, $d2
	db $05, $ff, $ff, $01, $ff, $f1, $00, $19, $5a, $01, $ff, $25, $00, $07, $5a, $01
	db $ff, $0b, $00, $f5, $59, $2b, $01, $15, $ff, $3c, $c8, $01, $00, $f1, $59, $2d
	db $01, $03, $ff, $0b, $00, $ff, $ff, $2c, $01, $ff, $ff, $2b, $01, $15, $ff, $3c
	db $c8, $01, $00, $03, $5a, $2e, $01, $ff, $ff, $2c, $01, $ff, $ff, $2b, $01, $15
	db $ff, $3c, $c8, $01, $00, $15, $5a, $90, $04, $ff, $ff, $8f, $04, $ff, $ff, $d3
	db $05, $15, $ff, $3c, $c8, $01, $00, $27, $5a, $d4, $05, $ff, $ff, $d5, $05, $ff
	db $ff, $01, $ff, $f1, $00, $67, $5a, $01, $ff, $25, $00, $63, $5a, $01, $ff, $37
	db $00, $5f, $5a, $01, $ff, $35, $00, $5b, $5a, $01, $ff, $1d, $00, $57, $5a, $01
	db $ff, $32, $00, $53, $5a, $65, $00, $ff, $ff, $f8, $01, $ff, $ff, $bc, $02, $ff
	db $ff, $6d, $03, $ff, $ff, $20, $04, $ff, $ff, $91, $04, $ff, $ff, $d6, $05, $ff
	db $ff, $57, $01, $03, $ff, $80, $00, $ff, $ff, $01, $ff, $f1, $00, $87, $5a, $01
	db $ff, $25, $00, $83, $5a, $59, $01, $ff, $ff, $92, $04, $ff, $ff, $d7, $05, $ff
	db $ff, $58, $01, $ff, $ff, $01, $ff, $14, $01, $cf, $5a, $01, $ff, $f1, $00, $c7
	db $5a, $01, $ff, $25, $00, $c3, $5a, $01, $ff, $37, $00, $bf, $5a, $01, $ff, $35
	db $00, $bb, $5a, $01, $ff, $1d, $00, $b7, $5a, $b0, $01, $ff, $ff, $bd, $02, $ff
	db $ff, $6e, $03, $ff, $ff, $21, $04, $ff, $ff, $93, $04, $ff, $ff, $d8, $05, $03
	db $ff, $14, $01, $ff, $ff, $4f, $08, $ff, $ff, $01, $ff, $f1, $00, $e7, $5a, $01
	db $ff, $25, $00, $e3, $5a, $5a, $01, $ff, $ff, $94, $04, $ff, $ff, $d9, $05, $ff
	db $ff, $01, $ff, $f1, $00, $2b, $5b, $01, $ff, $ad, $00, $27, $5b, $01, $ff, $25
	db $00, $1f, $5b, $01, $ff, $37, $00, $1b, $5b, $01, $ff, $35, $00, $17, $5b, $01
	db $ff, $1d, $00, $13, $5b, $5b, $01, $ff, $ff, $be, $02, $ff, $ff, $6f, $03, $ff
	db $ff, $22, $04, $ff, $ff, $95, $04, $03, $ff, $ad, $00, $ff, $ff, $96, $04, $ff
	db $ff, $da, $05, $ff, $ff, $01, $ff, $2f, $00, $8b, $5d, $01, $ff, $f4, $00, $87
	db $5d, $01, $ff, $07, $01, $7f, $5d, $01, $ff, $06, $01, $7f, $5d, $01, $ff, $f3
	db $00, $7b, $5d, $00, $ff, $f2, $00, $59, $5b, $01, $ff, $05, $01, $4b, $5c, $01
	db $ff, $f2, $00, $2b, $5c, $01, $ff, $f1, $00, $23, $5c, $01, $ff, $ae, $00, $11
	db $5c, $01, $ff, $25, $00, $fb, $5b, $01, $ff, $37, $00, $f3, $5b, $01, $ff, $36
	db $00, $d9, $5b, $01, $ff, $35, $00, $d1, $5b, $01, $ff, $34, $00, $c9, $5b, $01
	db $ff, $1d, $00, $af, $5b, $01, $ff, $33, $00, $a7, $5b, $01, $ff, $32, $00, $9f
	db $5b, $b1, $01, $ff, $ff, $f9, $01, $03, $ff, $80, $00, $ff, $ff, $77, $02, $03
	db $ff, $80, $00, $ff, $ff, $bf, $02, $15, $ff, $3c, $c8, $01, $00, $c1, $5b, $c0
	db $02, $03, $ff, $80, $00, $ff, $ff, $c1, $02, $03, $ff, $80, $00, $ff, $ff, $3c
	db $03, $03, $ff, $80, $00, $ff, $ff, $70, $03, $03, $ff, $80, $00, $ff, $ff, $e7
	db $03, $15, $ff, $3c, $c8, $01, $00, $eb, $5b, $e8, $03, $03, $ff, $80, $00, $ff
	db $ff, $e9, $03, $03, $ff, $80, $00, $ff, $ff, $23, $04, $03, $ff, $80, $00, $ff
	db $ff, $97, $04, $15, $ff, $3c, $c8, $01, $00, $0d, $5c, $98, $04, $03, $ff, $ae
	db $00, $ff, $ff, $9a, $04, $ff, $ff, $97, $04, $15, $ff, $3c, $c8, $01, $00, $1f
	db $5c, $99, $04, $ff, $ff, $9b, $04, $ff, $ff, $dc, $05, $03, $ff, $f2, $00, $ff
	db $ff, $dd, $05, $15, $ff, $3c, $c8, $01, $00, $43, $5c, $df, $05, $15, $ff, $3c
	db $c8, $01, $00, $47, $5c, $e1, $05, $ff, $ff, $de, $05, $ff, $ff, $e0, $05, $ff
	db $ff, $dd, $05, $15, $ff, $3c, $c8, $01, $00, $73, $5d, $df, $05, $15, $ff, $3c
	db $c8, $01, $00, $77, $5d, $e2, $05, $0d, $ff, $01, $00, $05, $00, $00, $00, $1c
	db $ff, $00, $06, $19, $ff, $15, $ff, $92, $ff, $27, $00, $b5, $5c, $15, $ff, $92
	db $ff, $28, $00, $b5, $5c, $15, $ff, $92, $ff, $29, $00, $b5, $5c, $1a, $ff, $01
	db $00, $10, $00, $1b, $ff, $00, $00, $10, $00, $19, $ff, $1b, $ff, $01, $00, $f0
	db $ff, $1a, $ff, $00, $00, $10, $00, $19, $ff, $1b, $ff, $01, $00, $f0, $ff, $1b
	db $ff, $00, $00, $f0, $ff, $19, $ff, $14, $ff, $df, $5c, $1b, $ff, $01, $00, $f0
	db $ff, $1a, $ff, $00, $00, $f0, $ff, $19, $ff, $1a, $ff, $01, $00, $10, $00, $1b
	db $ff, $00, $00, $f0, $ff, $19, $ff, $1b, $ff, $01, $00, $f0, $ff, $1a, $ff, $00
	db $00, $10, $00, $19, $ff, $1b, $ff, $01, $00, $e0, $ff, $1b, $ff, $00, $00, $e0
	db $ff, $19, $ff, $1a, $ff, $01, $00, $10, $00, $1b, $ff, $00, $00, $f0, $ff, $19
	db $ff, $1a, $ff, $01, $00, $20, $00, $1a, $ff, $00, $00, $20, $00, $19, $ff, $49
	db $ff, $01, $00, $4a, $ff, $00, $00, $07, $ff, $e3, $05, $0b, $ff, $01, $00, $f0
	db $ff, $09, $ff, $04, $00, $21, $ff, $51, $00, $0d, $ff, $01, $00, $00, $00, $40
	db $00, $09, $ff, $20, $00, $21, $ff, $51, $00, $0d, $ff, $01, $00, $00, $00, $00
	db $00, $48, $ff, $01, $00, $09, $ff, $08, $00, $0b, $ff, $01, $00, $10, $00, $49
	db $ff, $01, $00, $07, $ff, $e4, $05, $0a, $ff, $01, $00, $10, $00, $0b, $ff, $01
	db $00, $30, $00, $0a, $ff, $01, $00, $b0, $ff, $0b, $ff, $01, $00, $10, $00, $48
	db $ff, $01, $00, $03, $ff, $f3, $00, $ff, $ff, $de, $05, $ff, $ff, $e0, $05, $ff
	db $ff, $e5, $05, $ff, $ff, $e6, $05, $03, $ff, $f4, $00, $ff, $ff, $e7, $05, $ff
	db $ff, $e8, $05, $15, $ff, $3c, $c8, $01, $00, $99, $5d, $ea, $05, $ff, $ff, $e9
	db $05, $ff, $ff, $01, $ff, $f1, $00, $cb, $5d, $00, $ff, $25, $00, $af, $5d, $01
	db $ff, $83, $00, $c7, $5d, $01, $ff, $35, $00, $c3, $5d, $01, $ff, $1d, $00, $bf
	db $5d, $b2, $01, $ff, $ff, $c2, $02, $ff, $ff, $71, $03, $ff, $ff, $9c, $04, $ff
	db $ff, $db, $05, $ff, $ff, $12, $ff, $e8, $d9, $01, $00, $21, $ff, $55, $00, $22
	db $ff, $1b, $ff, $00, $00, $60, $00, $19, $ff, $12, $ff, $42, $c8, $00, $00, $12
	db $ff, $46, $c8, $00, $00, $ff, $ff, $12, $ff, $e8, $d9, $01, $00, $21, $ff, $55
	db $00, $22, $ff, $1b, $ff, $00, $00, $60, $00, $19, $ff, $ff, $ff, $12, $ff, $e8
	db $d9, $01, $00, $21, $ff, $55, $00, $22, $ff, $1b, $ff, $00, $00, $30, $00, $19
	db $ff, $ff, $ff, $4f, $5e, $8f, $5e, $af, $5e, $b3, $5e, $b7, $5e, $f5, $5e, $21
	db $5f, $43, $5f, $93, $60, $bf, $60, $01, $61, $69, $61, $6d, $61, $79, $61, $a3
	db $61, $d9, $61, $31, $62, $a3, $62, $a7, $62, $ab, $62, $b7, $62, $c5, $62, $d3
	db $62, $55, $64, $7d, $65, $0e, $ff, $01, $00, $57, $5e, $ff, $ff, $01, $ff, $37
	db $00, $8d, $5e, $00, $ff, $1d, $00, $69, $5e, $01, $ff, $4b, $00, $8d, $5e, $00
	db $ff, $1d, $00, $75, $5e, $01, $ff, $4a, $00, $89, $5e, $01, $ff, $1d, $00, $8d
	db $5e, $01, $ff, $4b, $00, $8d, $5e, $01, $ff, $4a, $00, $89, $5e, $ff, $ff, $03
	db $ff, $4b, $00, $ff, $ff, $01, $ff, $3f, $00, $ab, $5e, $3a, $00, $2c, $ff, $a7
	db $5e, $29, $01, $03, $ff, $3f, $00, $2a, $ff, $1e, $00, $ff, $ff, $2a, $01, $ff
	db $ff, $5d, $01, $ff, $ff, $5e, $01, $ff, $ff, $5e, $01, $ff, $ff, $01, $ff, $15
	db $01, $d9, $5e, $01, $ff, $f1, $00, $e5, $5e, $01, $ff, $12, $01, $d9, $5e, $96
	db $01, $03, $ff, $12, $01, $04, $ff, $00, $00, $80, $06, $82, $06, $ff, $ff, $80
	db $06, $04, $ff, $00, $00, $80, $06, $82, $06, $ff, $ff, $4a, $02, $03, $ff, $15
	db $01, $04, $ff, $00, $00, $80, $06, $82, $06, $ff, $ff, $01, $ff, $f1, $00, $1d
	db $5f, $01, $ff, $37, $00, $19, $5f, $01, $ff, $35, $00, $15, $5f, $01, $ff, $1d
	db $00, $11, $5f, $5c, $01, $ff, $ff, $c3, $02, $ff, $ff, $72, $03, $ff, $ff, $24
	db $04, $ff, $ff, $eb, $05, $ff, $ff, $01, $ff, $f1, $00, $3f, $5f, $01, $ff, $37
	db $00, $3b, $5f, $01, $ff, $35, $00, $37, $5f, $c4, $02, $ff, $ff, $73, $03, $ff
	db $ff, $25, $04, $ff, $ff, $ec, $05, $ff, $ff, $01, $ff, $f1, $00, $8f, $60, $01
	db $ff, $37, $00, $8b, $60, $01, $ff, $35, $00, $87, $60, $01, $ff, $4b, $00, $83
	db $60, $01, $ff, $4a, $00, $7f, $60, $01, $ff, $32, $00, $6b, $5f, $5f, $01, $ff
	db $ff, $fa, $01, $09, $ff, $04, $00, $48, $ff, $02, $00, $09, $ff, $02, $00, $47
	db $ff, $02, $00, $09, $ff, $04, $00, $4a, $ff, $02, $00, $09, $ff, $02, $00, $49
	db $ff, $02, $00, $09, $ff, $04, $00, $07, $ff, $fb, $01, $09, $ff, $04, $00, $0d
	db $ff, $03, $00, $00, $00, $00, $00, $13, $ff, $e3, $d8, $05, $03, $1c, $ff, $03
	db $15, $19, $ff, $0d, $ff, $01, $00, $05, $00, $00, $00, $15, $ff, $92, $ff, $d7
	db $00, $d1, $5f, $15, $ff, $92, $ff, $d8, $00, $d1, $5f, $15, $ff, $92, $ff, $d9
	db $00, $d1, $5f, $14, $ff, $d7, $5f, $11, $ff, $00, $00, $38, $00, $10, $ff, $00
	db $00, $f8, $00, $11, $ff, $00, $00, $68, $00, $0a, $ff, $03, $00, $f0, $ff, $09
	db $ff, $04, $00, $48, $ff, $02, $00, $47, $ff, $03, $00, $09, $ff, $08, $00, $0d
	db $ff, $02, $00, $05, $00, $80, $00, $22, $ff, $1b, $ff, $03, $00, $f0, $ff, $19
	db $ff, $21, $ff, $54, $00, $1d, $ff, $22, $ff, $1b, $ff, $02, $00, $b0, $ff, $19
	db $ff, $1e, $ff, $09, $ff, $04, $00, $0d, $ff, $02, $00, $05, $00, $00, $00, $4a
	db $ff, $02, $00, $09, $ff, $04, $00, $49, $ff, $02, $00, $09, $ff, $04, $00, $48
	db $ff, $02, $00, $09, $ff, $08, $00, $0d, $ff, $02, $00, $05, $00, $01, $00, $09
	db $ff, $0c, $00, $21, $ff, $55, $00, $0d, $ff, $02, $00, $00, $00, $40, $00, $09
	db $ff, $10, $00, $49, $ff, $03, $00, $09, $ff, $01, $00, $13, $ff, $e3, $d8, $04
	db $04, $1c, $ff, $03, $17, $19, $ff, $0d, $ff, $03, $00, $00, $00, $40, $00, $03
	db $ff, $4a, $00, $ff, $ff, $fc, $01, $ff, $ff, $fd, $01, $ff, $ff, $74, $03, $ff
	db $ff, $26, $04, $ff, $ff, $ed, $05, $ff, $ff, $01, $ff, $f1, $00, $bb, $60, $01
	db $ff, $37, $00, $b7, $60, $01, $ff, $35, $00, $b3, $60, $01, $ff, $4b, $00, $af
	db $60, $60, $01, $ff, $ff, $fe, $01, $ff, $ff, $75, $03, $ff, $ff, $27, $04, $ff
	db $ff, $ee, $05, $ff, $ff, $01, $ff, $f1, $00, $fd, $60, $01, $ff, $37, $00, $f9
	db $60, $01, $ff, $79, $00, $e7, $60, $c5, $02, $15, $ff, $3c, $c8, $01, $00, $e3
	db $60, $c6, $02, $03, $ff, $79, $00, $ff, $ff, $c7, $02, $ff, $ff, $c5, $02, $15
	db $ff, $3c, $c8, $01, $00, $f5, $60, $29, $00, $ff, $ff, $c7, $02, $ff, $ff, $28
	db $04, $ff, $ff, $ef, $05, $ff, $ff, $01, $ff, $f1, $00, $61, $61, $01, $ff, $37
	db $00, $4f, $61, $01, $ff, $7a, $00, $3d, $61, $01, $ff, $1d, $00, $27, $61, $01
	db $ff, $32, $00, $23, $61, $61, $01, $ff, $ff, $ff, $01, $ff, $ff, $c8, $02, $15
	db $ff, $3c, $c8, $01, $00, $39, $61, $ca, $02, $03, $ff, $7a, $00, $ff, $ff, $c9
	db $02, $ff, $ff, $cb, $02, $15, $ff, $3c, $c8, $01, $00, $4b, $61, $ca, $02, $ff
	db $ff, $c9, $02, $ff, $ff, $29, $04, $15, $ff, $3c, $c8, $01, $00, $5d, $61, $ca
	db $02, $ff, $ff, $2a, $04, $ff, $ff, $f0, $05, $ff, $ff, $f1, $05, $ff, $ff, $49
	db $ff, $03, $00, $80, $06, $04, $ff, $00, $00, $80, $06, $82, $06, $ff, $ff, $01
	db $ff, $f1, $00, $91, $61, $2b, $04, $15, $ff, $3c, $c8, $01, $00, $8d, $61, $2d
	db $04, $ff, $ff, $2c, $04, $ff, $ff, $f2, $05, $15, $ff, $3c, $c8, $01, $00, $9f
	db $61, $f4, $05, $ff, $ff, $f3, $05, $ff, $ff, $01, $ff, $9d, $00, $cd, $61, $01
	db $ff, $37, $00, $bd, $61, $01, $ff, $32, $00, $b9, $61, $63, $01, $ff, $ff, $00
	db $02, $ff, $ff, $2f, $04, $03, $ff, $9d, $00, $04, $ff, $00, $00, $80, $06, $82
	db $06, $ff, $ff, $80, $06, $04, $ff, $00, $00, $80, $06, $82, $06, $ff, $ff, $01
	db $ff, $f1, $00, $23, $62, $01, $ff, $25, $00, $15, $62, $01, $ff, $37, $00, $03
	db $62, $01, $ff, $1d, $00, $ff, $61, $01, $ff, $32, $00, $fb, $61, $62, $01, $ff
	db $ff, $01, $02, $ff, $ff, $cc, $02, $ff, $ff, $2e, $04, $15, $ff, $3c, $c8, $01
	db $00, $11, $62, $83, $03, $ff, $ff, $a4, $04, $ff, $ff, $ef, $03, $15, $ff, $3c
	db $c8, $01, $00, $11, $62, $83, $03, $ff, $ff, $f5, $05, $15, $ff, $3c, $c8, $01
	db $00, $11, $62, $83, $03, $ff, $ff, $01, $ff, $f1, $00, $91, $62, $01, $ff, $37
	db $00, $7f, $62, $01, $ff, $35, $00, $6d, $62, $01, $ff, $1d, $00, $5b, $62, $64
	db $01, $15, $ff, $3c, $c8, $01, $00, $57, $62, $ce, $08, $ff, $ff, $cf, $08, $ff
	db $ff, $cd, $02, $15, $ff, $3c, $c8, $01, $00, $69, $62, $ce, $02, $ff, $ff, $cf
	db $02, $ff, $ff, $76, $03, $15, $ff, $3c, $c8, $01, $00, $7b, $62, $78, $03, $ff
	db $ff, $77, $03, $ff, $ff, $30, $04, $15, $ff, $3c, $c8, $01, $00, $8d, $62, $78
	db $03, $ff, $ff, $31, $04, $ff, $ff, $f6, $05, $15, $ff, $3c, $c8, $01, $00, $9f
	db $62, $78, $03, $ff, $ff, $f7, $05, $ff, $ff, $79, $03, $ff, $ff, $79, $03, $ff
	db $ff, $80, $06, $04, $ff, $00, $00, $80, $06, $82, $06, $ff, $ff, $01, $ff, $f1
	db $00, $c1, $62, $32, $04, $ff, $ff, $f8, $05, $ff, $ff, $01, $ff, $f1, $00, $cf
	db $62, $65, $01, $ff, $ff, $5f, $04, $ff, $ff, $01, $ff, $f6, $00, $31, $64, $01
	db $ff, $f1, $00, $2d, $64, $01, $ff, $9e, $00, $29, $64, $00, $ff, $37, $00, $f1
	db $62, $01, $ff, $40, $00, $13, $64, $01, $ff, $40, $00, $0f, $64, $66, $01, $15
	db $ff, $3c, $c8, $00, $00, $05, $63, $67, $01, $ff, $ff, $15, $ff, $8d, $ca, $01
	db $00, $23, $63, $23, $ff, $00, $00, $27, $63, $23, $ff, $01, $00, $65, $63, $23
	db $ff, $02, $00, $7b, $63, $68, $01, $ff, $ff, $d9, $04, $ff, $ff, $69, $01, $6a
	db $01, $15, $ff, $3c, $c8, $00, $00, $8b, $63, $23, $ff, $01, $00, $43, $63, $23
	db $ff, $02, $00, $57, $63, $6d, $01, $ff, $ff, $6e, $01, $15, $ff, $3c, $c8, $00
	db $00, $8b, $63, $23, $ff, $02, $00, $57, $63, $6d, $01, $ff, $ff, $6e, $01, $15
	db $ff, $3c, $c8, $00, $00, $8b, $63, $6d, $01, $ff, $ff, $69, $01, $6a, $01, $15
	db $ff, $3c, $c8, $00, $00, $8b, $63, $23, $ff, $02, $00, $57, $63, $6d, $01, $ff
	db $ff, $69, $01, $6a, $01, $15, $ff, $3c, $c8, $00, $00, $8b, $63, $6d, $01, $ff
	db $ff, $6b, $01, $d3, $08, $06, $ff, $25, $ff, $61, $ff, $3d, $64, $24, $ff, $35
	db $64, $09, $ff, $01, $00, $61, $ff, $4d, $64, $24, $ff, $45, $64, $09, $ff, $01
	db $00, $61, $ff, $3d, $64, $24, $ff, $35, $64, $09, $ff, $01, $00, $61, $ff, $4d
	db $64, $24, $ff, $45, $64, $09, $ff, $01, $00, $61, $ff, $3d, $64, $24, $ff, $35
	db $64, $09, $ff, $01, $00, $61, $ff, $4d, $64, $24, $ff, $45, $64, $09, $ff, $01
	db $00, $61, $ff, $3d, $64, $24, $ff, $35, $64, $09, $ff, $01, $00, $61, $ff, $4d
	db $64, $24, $ff, $45, $64, $09, $ff, $01, $00, $61, $ff, $3d, $64, $24, $ff, $35
	db $64, $09, $ff, $04, $00, $07, $ff, $6c, $01, $03, $ff, $40, $00, $12, $ff, $3a
	db $d9, $01, $00, $ff, $ff, $6f, $01, $ff, $ff, $34, $04, $15, $ff, $3c, $c8, $01
	db $00, $21, $64, $35, $04, $ff, $ff, $36, $04, $03, $ff, $9e, $00, $ff, $ff, $37
	db $04, $ff, $ff, $f9, $05, $ff, $ff, $a0, $07, $ff, $ff, $46, $00, $70, $71, $d8
	db $72, $73, $d9, $46, $00, $03, $03, $d8, $03, $03, $d9, $46, $00, $40, $41, $d8
	db $42, $43, $d9, $46, $00, $02, $02, $d8, $02, $02, $d9, $01, $ff, $f6, $00, $59
	db $65, $01, $ff, $f5, $00, $8d, $64, $01, $ff, $f1, $00, $85, $64, $00, $ff, $37
	db $00, $73, $64, $01, $ff, $40, $00, $81, $64, $01, $ff, $40, $00, $7d, $64, $70
	db $01, $ff, $ff, $71, $01, $ff, $ff, $38, $04, $ff, $ff, $fa, $05, $03, $ff, $f5
	db $00, $ff, $ff, $fb, $05, $38, $ff, $00, $00, $a5, $64, $38, $ff, $01, $00, $a5
	db $64, $38, $ff, $02, $00, $a5, $64, $04, $02, $ff, $ff, $fc, $05, $fd, $05, $fe
	db $05, $06, $ff, $61, $ff, $65, $65, $24, $ff, $5d, $65, $09, $ff, $01, $00, $61
	db $ff, $75, $65, $24, $ff, $6d, $65, $09, $ff, $01, $00, $61, $ff, $65, $65, $24
	db $ff, $5d, $65, $09, $ff, $01, $00, $61, $ff, $75, $65, $24, $ff, $6d, $65, $09
	db $ff, $01, $00, $61, $ff, $65, $65, $24, $ff, $5d, $65, $09, $ff, $01, $00, $61
	db $ff, $75, $65, $24, $ff, $6d, $65, $09, $ff, $01, $00, $61, $ff, $65, $65, $24
	db $ff, $5d, $65, $09, $ff, $01, $00, $61, $ff, $75, $65, $24, $ff, $6d, $65, $09
	db $ff, $01, $00, $61, $ff, $65, $65, $24, $ff, $5d, $65, $09, $ff, $04, $00, $07
	db $ff, $ff, $05, $03, $ff, $f6, $00, $00, $ff, $15, $00, $2d, $65, $01, $ff, $2d
	db $00, $51, $65, $01, $ff, $2d, $00, $49, $65, $01, $ff, $15, $00, $41, $65, $12
	db $ff, $3a, $d9, $05, $00, $ff, $ff, $12, $ff, $3a, $d9, $06, $00, $ff, $ff, $12
	db $ff, $3a, $d9, $07, $00, $ff, $ff, $12, $ff, $3a, $d9, $08, $00, $ff, $ff, $a1
	db $07, $ff, $ff, $0e, $01, $70, $71, $d8, $72, $73, $d9, $0e, $01, $03, $03, $d8
	db $03, $03, $d9, $0e, $01, $40, $41, $d8, $42, $43, $d9, $0e, $01, $02, $02, $d8
	db $02, $02, $d9, $01, $ff, $f3, $00, $1d, $66, $01, $ff, $f1, $00, $0f, $66, $01
	db $ff, $25, $00, $01, $66, $01, $ff, $37, $00, $f3, $65, $01, $ff, $35, $00, $e5
	db $65, $01, $ff, $1d, $00, $d7, $65, $01, $ff, $45, $00, $c9, $65, $01, $ff, $31
	db $00, $bb, $65, $72, $01, $15, $ff, $3c, $c8, $01, $00, $2f, $66, $73, $01, $ff
	db $ff, $72, $01, $15, $ff, $3c, $c8, $01, $00, $2f, $66, $b3, $01, $ff, $ff, $72
	db $01, $15, $ff, $3c, $c8, $01, $00, $2f, $66, $02, $02, $ff, $ff, $72, $01, $15
	db $ff, $3c, $c8, $01, $00, $2f, $66, $d0, $02, $ff, $ff, $72, $01, $15, $ff, $3c
	db $c8, $01, $00, $2f, $66, $7a, $03, $ff, $ff, $72, $01, $15, $ff, $3c, $c8, $01
	db $00, $2f, $66, $33, $04, $ff, $ff, $72, $01, $15, $ff, $3c, $c8, $01, $00, $2f
	db $66, $9d, $04, $ff, $ff, $72, $01, $15, $ff, $3c, $c8, $01, $00, $2f, $66, $58
	db $03, $ff, $ff, $72, $01, $15, $ff, $3c, $c8, $01, $00, $2b, $66, $d7, $03, $ff
	db $ff, $49, $03, $ff, $ff, $74, $01, $ff, $ff, $5b, $66, $5d, $66, $61, $66, $65
	db $66, $69, $66, $71, $67, $73, $67, $77, $67, $7b, $67, $89, $67, $8d, $67, $ef
	db $67, $f3, $67, $f7, $67, $fb, $67, $35, $68, $67, $68, $69, $68, $6b, $68, $6d
	db $68, $ff, $ff, $33, $01, $ff, $ff, $32, $01, $ff, $ff, $34, $01, $ff, $ff, $01
	db $ff, $f1, $00, $59, $67, $01, $ff, $25, $00, $41, $67, $01, $ff, $37, $00, $29
	db $67, $01, $ff, $35, $00, $11, $67, $01, $ff, $34, $00, $f9, $66, $01, $ff, $1d
	db $00, $e1, $66, $01, $ff, $33, $00, $c9, $66, $01, $ff, $32, $00, $b1, $66, $66
	db $00, $15, $ff, $3c, $c8, $01, $00, $ad, $66, $04, $ff, $0d, $00, $00, $00, $08
	db $ff, $07, $ff, $7e, $04, $ff, $ff, $66, $00, $15, $ff, $3c, $c8, $01, $00, $c5
	db $66, $04, $ff, $0d, $00, $00, $00, $08, $ff, $07, $ff, $03, $02, $ff, $ff, $66
	db $00, $15, $ff, $3c, $c8, $01, $00, $dd, $66, $04, $ff, $0d, $00, $00, $00, $08
	db $ff, $07, $ff, $78, $02, $ff, $ff, $66, $00, $15, $ff, $3c, $c8, $01, $00, $f5
	db $66, $04, $ff, $0d, $00, $00, $00, $08, $ff, $07, $ff, $d1, $02, $ff, $ff, $66
	db $00, $15, $ff, $3c, $c8, $01, $00, $0d, $67, $04, $ff, $0d, $00, $00, $00, $08
	db $ff, $07, $ff, $3d, $03, $ff, $ff, $66, $00, $15, $ff, $3c, $c8, $01, $00, $25
	db $67, $04, $ff, $0d, $00, $00, $00, $08, $ff, $07, $ff, $7b, $03, $ff, $ff, $66
	db $00, $15, $ff, $3c, $c8, $01, $00, $3d, $67, $04, $ff, $0d, $00, $00, $00, $08
	db $ff, $07, $ff, $39, $04, $ff, $ff, $66, $00, $15, $ff, $3c, $c8, $01, $00, $55
	db $67, $04, $ff, $0d, $00, $00, $00, $08, $ff, $07, $ff, $9e, $04, $ff, $ff, $66
	db $00, $15, $ff, $3c, $c8, $01, $00, $6d, $67, $04, $ff, $0d, $00, $00, $00, $08
	db $ff, $07, $ff, $a2, $07, $ff, $ff, $ff, $ff, $30, $01, $ff, $ff, $31, $01, $ff
	db $ff, $01, $ff, $09, $00, $85, $67, $54, $00, $ff, $ff, $67, $00, $ff, $ff, $55
	db $00, $ff, $ff, $01, $ff, $f8, $00, $eb, $67, $01, $ff, $f1, $00, $e3, $67, $01
	db $ff, $37, $00, $df, $67, $01, $ff, $1d, $00, $db, $67, $01, $ff, $33, $00, $d7
	db $67, $01, $ff, $32, $00, $d3, $67, $01, $ff, $31, $00, $cf, $67, $01, $ff, $30
	db $00, $cb, $67, $01, $ff, $10, $00, $c7, $67, $56, $00, $ff, $ff, $87, $04, $ff
	db $ff, $75, $01, $ff, $ff, $b4, $01, $ff, $ff, $d0, $08, $ff, $ff, $79, $02, $ff
	db $ff, $d2, $02, $ff, $ff, $3b, $04, $ff, $ff, $a4, $07, $03, $ff, $f8, $00, $ff
	db $ff, $a5, $07, $ff, $ff, $36, $01, $ff, $ff, $35, $01, $ff, $ff, $dd, $00, $ff
	db $ff, $01, $ff, $f1, $00, $31, $68, $01, $ff, $a0, $00, $2d, $68, $01, $ff, $37
	db $00, $25, $68, $01, $ff, $36, $00, $21, $68, $01, $ff, $35, $00, $1d, $68, $67
	db $00, $ff, $ff, $7c, $03, $ff, $ff, $ea, $03, $ff, $ff, $3c, $04, $03, $ff, $a0
	db $00, $ff, $ff, $3d, $04, $ff, $ff, $a6, $07, $ff, $ff, $01, $ff, $25, $00, $63
	db $68, $00, $ff, $22, $00, $47, $68, $01, $ff, $37, $00, $5f, $68, $01, $ff, $36
	db $00, $5b, $68, $01, $ff, $35, $00, $57, $68, $68, $00, $ff, $ff, $7d, $03, $ff
	db $ff, $eb, $03, $ff, $ff, $3e, $04, $ff, $ff, $a0, $04, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $01, $ff, $fa, $00, $7b, $68, $a8, $07, $03, $ff, $fa, $00, $ff
	db $ff, $a9, $07, $ff, $ff, $d5, $68, $bb, $6a, $e1, $6a, $ab, $6b, $c3, $6b, $d1
	db $6b, $e3, $6b, $1f, $6c, $23, $6c, $4f, $6c, $71, $6c, $75, $6c, $87, $6c, $91
	db $6c, $9b, $6c, $9f, $6c, $a9, $6c, $ad, $6c, $e3, $6c, $e7, $6c, $a9, $6d, $ad
	db $6d, $0d, $6e, $43, $6e, $5b, $6e, $91, $6e, $95, $6e, $07, $6f, $fd, $6f, $1f
	db $70, $73, $70, $77, $70, $7b, $70, $7f, $70, $8d, $70, $af, $70, $d7, $70, $15
	db $71, $19, $71, $2b, $71, $2f, $71, $33, $71, $81, $71, $0e, $ff, $01, $00, $e3
	db $68, $0e, $ff, $06, $00, $65, $69, $ff, $ff, $01, $ff, $ee, $00, $e1, $68, $01
	db $ff, $e5, $00, $e1, $68, $01, $ff, $e4, $00, $f7, $68, $ff, $ff, $47, $ff, $00
	db $00, $07, $ff, $ef, $04, $0a, $ff, $00, $00, $10, $00, $0b, $ff, $00, $00, $f0
	db $ff, $09, $ff, $04, $00, $47, $ff, $01, $00, $47, $ff, $02, $00, $47, $ff, $03
	db $00, $47, $ff, $04, $00, $47, $ff, $05, $00, $47, $ff, $06, $00, $09, $ff, $10
	db $00, $12, $ff, $8a, $c8, $03, $00, $12, $ff, $8b, $c8, $00, $00, $3e, $ff, $03
	db $ff, $e5, $00, $09, $ff, $04, $00, $4a, $ff, $01, $00, $09, $ff, $04, $00, $49
	db $ff, $00, $00, $09, $ff, $04, $00, $07, $ff, $f0, $04, $15, $ff, $3c, $c8, $00
	db $00, $61, $69, $f1, $04, $ff, $ff, $f2, $04, $ff, $ff, $15, $ff, $e2, $d9, $00
	db $00, $e1, $68, $0d, $ff, $00, $00, $90, $ff, $40, $00, $47, $ff, $00, $00, $09
	db $ff, $02, $00, $61, $ff, $55, $6a, $24, $ff, $ef, $69, $09, $ff, $02, $00, $61
	db $ff, $5d, $6a, $24, $ff, $f7, $69, $09, $ff, $02, $00, $61, $ff, $6b, $6a, $24
	db $ff, $05, $6a, $09, $ff, $02, $00, $61, $ff, $7f, $6a, $24, $ff, $19, $6a, $09
	db $ff, $02, $00, $61, $ff, $93, $6a, $24, $ff, $2d, $6a, $09, $ff, $02, $00, $61
	db $ff, $a7, $6a, $24, $ff, $41, $6a, $09, $ff, $02, $00, $0d, $ff, $00, $00, $90
	db $ff, $00, $00, $0b, $ff, $00, $00, $b0, $ff, $49, $ff, $00, $00, $09, $ff, $02
	db $00, $1c, $ff, $00, $07, $19, $ff, $1c, $ff, $00, $06, $19, $ff, $12, $ff, $e2
	db $d9, $00, $00, $ff, $ff, $d0, $01, $40, $41, $d8, $42, $43, $d9, $90, $01, $40
	db $41, $d8, $42, $43, $d8, $44, $45, $d8, $46, $47, $d9, $50, $01, $40, $41, $d8
	db $42, $43, $d8, $44, $45, $d8, $46, $47, $d8, $48, $49, $d8, $4a, $4b, $d9, $10
	db $01, $40, $41, $d8, $42, $43, $d8, $44, $45, $d8, $46, $47, $d8, $48, $49, $d8
	db $4a, $4b, $d9, $d0, $00, $40, $41, $d8, $42, $43, $d8, $44, $45, $d8, $46, $47
	db $d8, $48, $49, $d8, $4a, $4b, $d9, $90, $00, $40, $41, $d8, $42, $43, $d8, $44
	db $45, $d8, $46, $47, $d8, $48, $49, $d8, $4a, $4b, $d9, $d0, $01, $00, $00, $d8
	db $00, $00, $d9, $90, $01, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8, $00, $00
	db $d9, $50, $01, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8, $00
	db $00, $d8, $00, $00, $d9, $10, $01, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8
	db $00, $00, $d8, $00, $00, $d8, $00, $00, $d9, $d0, $00, $00, $00, $d8, $00, $00
	db $d8, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8, $00, $00, $d9, $90, $00, $00
	db $00, $d8, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8, $00, $00, $d8, $00, $00
	db $d9, $01, $ff, $45, $00, $dd, $6a, $01, $ff, $31, $00, $d9, $6a, $69, $00, $15
	db $ff, $3c, $c8, $01, $00, $d5, $6a, $6e, $08, $ff, $ff, $6d, $08, $ff, $ff, $b5
	db $01, $ff, $ff, $06, $02, $ff, $ff, $0d, $ff, $01, $00, $00, $00, $00, $00, $10
	db $ff, $01, $00, $68, $00, $0d, $ff, $03, $00, $1a, $00, $18, $00, $0d, $ff, $03
	db $00, $00, $00, $00, $00, $22, $ff, $1b, $ff, $03, $00, $40, $00, $19, $ff, $0d
	db $ff, $03, $00, $00, $00, $40, $00, $01, $ff, $f1, $00, $8f, $6b, $01, $ff, $35
	db $00, $87, $6b, $01, $ff, $1d, $00, $7f, $6b, $00, $ff, $0d, $00, $2f, $6b, $01
	db $ff, $32, $00, $77, $6b, $01, $ff, $0d, $00, $6f, $6b, $01, $ff, $0c, $00, $43
	db $6b, $07, $ff, $6a, $00, $14, $ff, $97, $6b, $07, $ff, $6b, $00, $28, $ff, $69
	db $6b, $6c, $00, $06, $ff, $0d, $ff, $01, $00, $00, $00, $02, $00, $0d, $ff, $01
	db $00, $08, $00, $01, $00, $03, $ff, $0d, $00, $29, $ff, $5e, $01, $ff, $ff, $6d
	db $00, $14, $ff, $97, $6b, $07, $ff, $6e, $00, $14, $ff, $97, $6b, $07, $ff, $05
	db $02, $14, $ff, $97, $6b, $07, $ff, $d3, $02, $14, $ff, $97, $6b, $07, $ff, $7e
	db $03, $14, $ff, $97, $6b, $07, $ff, $aa, $07, $14, $ff, $97, $6b, $06, $ff, $0d
	db $ff, $01, $00, $00, $00, $02, $00, $0d, $ff, $01, $00, $08, $00, $01, $00, $ff
	db $ff, $01, $ff, $f1, $00, $bf, $6b, $01, $ff, $35, $00, $bb, $6b, $d4, $02, $ff
	db $ff, $7f, $03, $ff, $ff, $ab, $07, $ff, $ff, $01, $ff, $94, $00, $cd, $6b, $eb
	db $04, $ff, $ff, $ec, $04, $ff, $ff, $01, $ff, $e3, $00, $df, $6b, $ed, $04, $03
	db $ff, $e3, $00, $ff, $ff, $ee, $04, $ff, $ff, $01, $ff, $f1, $00, $0f, $6c, $01
	db $ff, $32, $00, $ff, $6b, $49, $ff, $01, $00, $0d, $ff, $01, $00, $14, $00, $02
	db $00, $35, $00, $ff, $ff, $49, $ff, $01, $00, $0d, $ff, $01, $00, $14, $00, $02
	db $00, $09, $02, $ff, $ff, $49, $ff, $01, $00, $0d, $ff, $01, $00, $14, $00, $02
	db $00, $ae, $07, $ff, $ff, $34, $00, $ff, $ff, $01, $ff, $f1, $00, $4b, $6c, $01
	db $ff, $35, $00, $47, $6c, $01, $ff, $32, $00, $43, $6c, $01, $ff, $09, $00, $3f
	db $6c, $33, $00, $ff, $ff, $6f, $00, $ff, $ff, $07, $02, $ff, $ff, $80, $03, $ff
	db $ff, $ac, $07, $ff, $ff, $01, $ff, $f1, $00, $6d, $6c, $01, $ff, $35, $00, $69
	db $6c, $01, $ff, $32, $00, $65, $6c, $70, $00, $ff, $ff, $08, $02, $ff, $ff, $81
	db $03, $ff, $ff, $ad, $07, $ff, $ff, $f3, $04, $ff, $ff, $01, $ff, $e6, $00, $83
	db $6c, $f4, $04, $03, $ff, $e6, $00, $ff, $ff, $f5, $04, $ff, $ff, $f7, $04, $1c
	db $ff, $03, $09, $19, $ff, $ff, $ff, $f9, $04, $1c, $ff, $04, $09, $19, $ff, $ff
	db $ff, $f6, $04, $ff, $ff, $f8, $04, $1c, $ff, $06, $09, $19, $ff, $ff, $ff, $37
	db $00, $ff, $ff, $01, $ff, $f1, $00, $df, $6c, $00, $ff, $7c, $00, $bf, $6c, $01
	db $ff, $25, $00, $db, $6c, $01, $ff, $1d, $00, $d3, $6c, $01, $ff, $30, $00, $cf
	db $6c, $36, $00, $ff, $ff, $76, $01, $ff, $ff, $d5, $02, $03, $ff, $7c, $00, $ff
	db $ff, $a1, $04, $ff, $ff, $af, $07, $ff, $ff, $d6, $02, $ff, $ff, $01, $ff, $e7
	db $00, $9b, $6d, $fb, $04, $15, $ff, $3c, $c8, $00, $00, $ff, $6c, $fd, $04, $03
	db $ff, $e7, $00, $ff, $ff, $fc, $04, $47, $ff, $03, $00, $1b, $ff, $03, $00, $f0
	db $ff, $10, $ff, $00, $00, $88, $01, $11, $ff, $00, $00, $58, $00, $19, $ff, $1b
	db $ff, $03, $00, $f0, $ff, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a, $ff, $03
	db $00, $10, $00, $1b, $ff, $00, $00, $f0, $ff, $19, $ff, $1a, $ff, $03, $00, $10
	db $00, $1a, $ff, $00, $00, $10, $00, $19, $ff, $1b, $ff, $03, $00, $10, $00, $1a
	db $ff, $00, $00, $10, $00, $19, $ff, $1b, $ff, $03, $00, $10, $00, $1b, $ff, $00
	db $00, $10, $00, $19, $ff, $1a, $ff, $03, $00, $10, $00, $1b, $ff, $00, $00, $10
	db $00, $19, $ff, $0d, $ff, $03, $00, $00, $00, $40, $00, $21, $ff, $55, $00, $1a
	db $ff, $00, $00, $10, $00, $19, $ff, $0d, $ff, $00, $00, $90, $ff, $40, $00, $21
	db $ff, $55, $00, $09, $ff, $08, $00, $0f, $ff, $09, $00, $18, $01, $08, $00, $ff
	db $ff, $fe, $04, $15, $ff, $3c, $c8, $00, $00, $ff, $6c, $fd, $04, $ff, $ff, $fa
	db $04, $ff, $ff, $01, $ff, $f1, $00, $05, $6e, $01, $ff, $e4, $00, $01, $6e, $01
	db $ff, $7b, $00, $fd, $6d, $01, $ff, $1d, $00, $eb, $6d, $01, $ff, $04, $00, $e7
	db $6d, $01, $ff, $09, $00, $d5, $6d, $3b, $00, $ff, $ff, $3a, $00, $2c, $ff, $09
	db $6e, $29, $01, $03, $ff, $04, $00, $2a, $ff, $1e, $00, $ff, $ff, $3b, $00, $ff
	db $ff, $3a, $00, $2c, $ff, $09, $6e, $29, $01, $03, $ff, $7b, $00, $2a, $ff, $1e
	db $00, $ff, $ff, $3b, $00, $ff, $ff, $02, $05, $ff, $ff, $b1, $07, $ff, $ff, $2a
	db $01, $ff, $ff, $01, $ff, $f1, $00, $3f, $6e, $01, $ff, $e4, $00, $3b, $6e, $01
	db $ff, $25, $00, $37, $6e, $01, $ff, $1d, $00, $33, $6e, $01, $ff, $32, $00, $2f
	db $6e, $39, $00, $ff, $ff, $0b, $02, $ff, $ff, $d8, $02, $ff, $ff, $a3, $04, $ff
	db $ff, $ff, $04, $ff, $ff, $b0, $07, $ff, $ff, $01, $ff, $32, $00, $57, $6e, $01
	db $ff, $09, $00, $53, $6e, $38, $00, $ff, $ff, $71, $00, $ff, $ff, $0a, $02, $ff
	db $ff, $01, $ff, $fc, $00, $8d, $6e, $01, $ff, $f1, $00, $89, $6e, $01, $ff, $e4
	db $00, $85, $6e, $01, $ff, $25, $00, $81, $6e, $01, $ff, $35, $00, $7d, $6e, $d7
	db $02, $ff, $ff, $82, $03, $ff, $ff, $a2, $04, $ff, $ff, $00, $05, $ff, $ff, $b2
	db $07, $ff, $ff, $b3, $07, $ff, $ff, $01, $05, $ff, $ff, $01, $ff, $f1, $00, $e7
	db $6e, $01, $ff, $e4, $00, $03, $6f, $01, $ff, $1d, $00, $e7, $6e, $01, $ff, $0c
	db $00, $e7, $6e, $01, $ff, $09, $00, $f3, $6e, $01, $ff, $05, $00, $e7, $6e, $3c
	db $00, $15, $ff, $3c, $c8, $01, $00, $d5, $6e, $3d, $00, $3f, $00, $03, $ff, $05
	db $00, $04, $ff, $03, $00, $c0, $06, $c2, $06, $ff, $ff, $3e, $00, $3f, $00, $03
	db $ff, $05, $00, $04, $ff, $03, $00, $c0, $06, $c2, $06, $ff, $ff, $c0, $06, $04
	db $ff, $03, $00, $c0, $06, $c2, $06, $ff, $ff, $72, $00, $03, $ff, $0c, $00, $04
	db $ff, $03, $00, $c0, $06, $c2, $06, $ff, $ff, $04, $05, $ff, $ff, $00, $ff, $e4
	db $00, $13, $6f, $01, $ff, $a2, $00, $f9, $6f, $01, $ff, $a3, $00, $e7, $6f, $01
	db $ff, $a2, $00, $cd, $6f, $00, $ff, $f1, $00, $31, $6f, $01, $ff, $a1, $00, $9f
	db $6f, $01, $ff, $37, $00, $71, $6f, $01, $ff, $e4, $00, $c9, $6f, $01, $ff, $a1
	db $00, $9f, $6f, $01, $ff, $37, $00, $71, $6f, $01, $ff, $06, $00, $5f, $6f, $40
	db $00, $03, $ff, $06, $00, $15, $ff, $3c, $c8, $01, $00, $5b, $6f, $41, $00, $ff
	db $ff, $42, $00, $ff, $ff, $43, $00, $15, $ff, $3c, $c8, $01, $00, $6d, $6f, $41
	db $00, $ff, $ff, $42, $00, $ff, $ff, $3f, $04, $03, $ff, $a1, $00, $15, $ff, $3c
	db $c8, $01, $00, $97, $6f, $28, $ff, $9b, $6f, $42, $04, $03, $ff, $a2, $00, $29
	db $ff, $5f, $01, $0d, $ff, $02, $00, $00, $00, $40, $00, $ff, $ff, $40, $04, $ff
	db $ff, $41, $04, $ff, $ff, $43, $04, $15, $ff, $3c, $c8, $01, $00, $c1, $6f, $28
	db $ff, $c5, $6f, $42, $04, $03, $ff, $a2, $00, $29, $ff, $5f, $01, $0d, $ff, $02
	db $00, $00, $00, $40, $00, $ff, $ff, $40, $04, $ff, $ff, $41, $04, $ff, $ff, $5d
	db $00, $ff, $ff, $44, $04, $15, $ff, $3c, $c8, $01, $00, $df, $6f, $46, $04, $03
	db $ff, $a3, $00, $ff, $ff, $45, $04, $03, $ff, $a3, $00, $ff, $ff, $47, $04, $15
	db $ff, $3c, $c8, $01, $00, $f5, $6f, $46, $04, $ff, $ff, $45, $04, $ff, $ff, $03
	db $05, $ff, $ff, $01, $ff, $32, $00, $1b, $70, $01, $ff, $30, $00, $17, $70, $01
	db $ff, $0c, $00, $13, $70, $44, $00, $ff, $ff, $73, $00, $ff, $ff, $77, $01, $ff
	db $ff, $0c, $02, $ff, $ff, $d9, $02, $15, $ff, $3c, $c8, $01, $00, $6f, $70, $15
	db $ff, $8d, $ca, $00, $00, $6b, $70, $5f, $ff, $00, $00, $3d, $70, $c7, $08, $14
	db $ff, $3f, $70, $d2, $08, $15, $ff, $8d, $ca, $01, $00, $6b, $70, $5f, $ff, $01
	db $00, $53, $70, $c7, $08, $14, $ff, $55, $70, $d2, $08, $15, $ff, $8d, $ca, $02
	db $00, $6b, $70, $5f, $ff, $02, $00, $69, $70, $c7, $08, $14, $ff, $6b, $70, $d2
	db $08, $cd, $08, $ff, $ff, $ca, $08, $ff, $ff, $05, $05, $ff, $ff, $06, $05, $ff
	db $ff, $07, $05, $ff, $ff, $01, $ff, $32, $00, $89, $70, $74, $00, $ff, $ff, $0d
	db $02, $ff, $ff, $01, $ff, $f1, $00, $ab, $70, $01, $ff, $25, $00, $a7, $70, $01
	db $ff, $35, $00, $a3, $70, $da, $02, $ff, $ff, $84, $03, $ff, $ff, $a5, $04, $ff
	db $ff, $b5, $07, $ff, $ff, $01, $ff, $f1, $00, $d3, $70, $01, $ff, $25, $00, $cf
	db $70, $00, $ff, $35, $00, $c7, $70, $01, $ff, $6a, $00, $cb, $70, $db, $02, $ff
	db $ff, $85, $03, $ff, $ff, $a6, $04, $ff, $ff, $b6, $07, $ff, $ff, $01, $ff, $e8
	db $00, $11, $71, $68, $03, $03, $ff, $e8, $00, $0d, $ff, $06, $00, $10, $00, $00
	db $00, $0d, $ff, $06, $00, $18, $00, $90, $00, $0d, $ff, $06, $00, $1a, $00, $90
	db $00, $0d, $ff, $06, $00, $00, $00, $00, $00, $09, $ff, $10, $00, $0d, $ff, $06
	db $00, $00, $00, $40, $00, $ff, $ff, $38, $03, $ff, $ff, $08, $05, $ff, $ff, $09
	db $05, $15, $ff, $3c, $c8, $01, $00, $27, $71, $0a, $05, $ff, $ff, $0b, $05, $ff
	db $ff, $0c, $05, $ff, $ff, $0d, $05, $ff, $ff, $09, $ff, $02, $00, $21, $ff, $55
	db $00, $12, $ff, $ed, $c8, $01, $00, $0b, $ff, $00, $00, $10, $00, $12, $ff, $ed
	db $c8, $03, $00, $0b, $ff, $00, $00, $10, $00, $12, $ff, $ed, $c8, $07, $00, $0b
	db $ff, $00, $00, $10, $00, $12, $ff, $ed, $c8, $0f, $00, $0d, $ff, $00, $00, $90
	db $ff, $40, $00, $09, $ff, $04, $00, $12, $ff, $e5, $d9, $01, $00, $0f, $ff, $07
	db $00, $98, $01, $d8, $00, $ff, $ff, $09, $ff, $02, $00, $21, $ff, $55, $00, $12
	db $ff, $ed, $c8, $01, $00, $0b, $ff, $00, $00, $10, $00, $12, $ff, $ed, $c8, $03
	db $00, $0b, $ff, $00, $00, $10, $00, $12, $ff, $ed, $c8, $07, $00, $0b, $ff, $00
	db $00, $10, $00, $12, $ff, $ed, $c8, $0f, $00, $0d, $ff, $00, $00, $90, $ff, $40
	db $00, $09, $ff, $04, $00, $12, $ff, $e5, $d9, $01, $00, $0f, $ff, $09, $00, $18
	db $01, $58, $00, $ff, $ff, $f9, $71, $fb, $71, $13, $72, $17, $72, $2f, $72, $57
	db $72, $83, $72, $a5, $72, $d1, $72, $31, $73, $59, $73, $83, $73, $ab, $73, $c3
	db $73, $db, $73, $fb, $73, $2b, $74, $bb, $75, $bf, $75, $d7, $75, $47, $76, $ff
	db $ff, $01, $ff, $34, $00, $0f, $72, $01, $ff, $33, $00, $0b, $72, $0e, $02, $ff
	db $ff, $7a, $02, $ff, $ff, $3e, $03, $ff, $ff, $0f, $02, $ff, $ff, $01, $ff, $34
	db $00, $2b, $72, $01, $ff, $33, $00, $27, $72, $10, $02, $ff, $ff, $7b, $02, $ff
	db $ff, $3f, $03, $ff, $ff, $00, $ff, $22, $00, $41, $72, $01, $ff, $f1, $00, $53
	db $72, $01, $ff, $25, $00, $4f, $72, $01, $ff, $22, $00, $4b, $72, $89, $03, $ff
	db $ff, $8a, $03, $ff, $ff, $a9, $04, $ff, $ff, $ba, $07, $ff, $ff, $01, $ff, $f1
	db $00, $7f, $72, $01, $ff, $25, $00, $7b, $72, $01, $ff, $37, $00, $77, $72, $01
	db $ff, $36, $00, $73, $72, $86, $03, $ff, $ff, $ec, $03, $ff, $ff, $48, $04, $ff
	db $ff, $a7, $04, $ff, $ff, $b7, $07, $ff, $ff, $01, $ff, $f1, $00, $a1, $72, $01
	db $ff, $37, $00, $9d, $72, $01, $ff, $36, $00, $99, $72, $87, $03, $ff, $ff, $ed
	db $03, $ff, $ff, $49, $04, $ff, $ff, $b8, $07, $ff, $ff, $01, $ff, $f1, $00, $cd
	db $72, $01, $ff, $25, $00, $c9, $72, $01, $ff, $37, $00, $c5, $72, $01, $ff, $36
	db $00, $c1, $72, $88, $03, $ff, $ff, $ee, $03, $ff, $ff, $4a, $04, $ff, $ff, $a8
	db $04, $ff, $ff, $b9, $07, $ff, $ff, $01, $ff, $f1, $00, $2d, $73, $00, $ff, $83
	db $00, $f5, $72, $00, $ff, $1e, $01, $ef, $72, $00, $ff, $25, $00, $ef, $72, $01
	db $ff, $20, $01, $29, $73, $01, $ff, $1e, $01, $25, $73, $01, $ff, $83, $00, $21
	db $73, $01, $ff, $7c, $00, $1d, $73, $01, $ff, $1d, $00, $0b, $73, $11, $02, $ff
	db $ff, $dc, $02, $15, $ff, $3c, $c8, $01, $00, $19, $73, $dd, $02, $ff, $ff, $de
	db $02, $ff, $ff, $df, $02, $ff, $ff, $8b, $03, $ff, $ff, $8c, $03, $ff, $ff, $aa
	db $04, $ff, $ff, $bb, $07, $ff, $ff, $01, $ff, $f1, $00, $55, $73, $00, $ff, $22
	db $00, $43, $73, $01, $ff, $25, $00, $51, $73, $01, $ff, $22, $00, $4d, $73, $8d
	db $03, $ff, $ff, $8e, $03, $ff, $ff, $ab, $04, $ff, $ff, $bc, $07, $ff, $ff, $01
	db $ff, $f1, $00, $7d, $73, $00, $ff, $22, $00, $6b, $73, $01, $ff, $25, $00, $79
	db $73, $01, $ff, $22, $00, $75, $73, $8f, $03, $ff, $ff, $90, $03, $ff, $ff, $ac
	db $04, $ff, $ff, $bd, $07, $be, $07, $ff, $ff, $01, $ff, $f1, $00, $a7, $73, $00
	db $ff, $22, $00, $95, $73, $01, $ff, $25, $00, $a3, $73, $01, $ff, $22, $00, $9f
	db $73, $91, $03, $ff, $ff, $92, $03, $ff, $ff, $ad, $04, $ff, $ff, $bf, $07, $ff
	db $ff, $01, $ff, $f1, $00, $bf, $73, $01, $ff, $35, $00, $bb, $73, $19, $02, $ff
	db $ff, $9c, $03, $ff, $ff, $19, $02, $ff, $ff, $01, $ff, $f1, $00, $d7, $73, $01
	db $ff, $35, $00, $d3, $73, $19, $02, $ff, $ff, $9c, $03, $ff, $ff, $19, $02, $ff
	db $ff, $01, $ff, $4e, $00, $f7, $73, $d1, $01, $2c, $ff, $f3, $73, $29, $01, $03
	db $ff, $4e, $00, $2a, $ff, $1e, $00, $ff, $ff, $d2, $01, $ff, $ff, $8a, $02, $ff
	db $ff, $01, $ff, $f1, $00, $0d, $74, $01, $ff, $90, $00, $27, $74, $01, $ff, $35
	db $00, $11, $74, $1b, $02, $ff, $ff, $d1, $01, $2c, $ff, $23, $74, $9d, $03, $03
	db $ff, $90, $00, $2a, $ff, $1d, $00, $ff, $ff, $9e, $03, $ff, $ff, $8a, $02, $ff
	db $ff, $00, $ff, $2f, $00, $f1, $74, $00, $ff, $2e, $00, $f1, $74, $00, $ff, $2d
	db $00, $f1, $74, $00, $ff, $2c, $00, $f1, $74, $00, $ff, $2b, $00, $f1, $74, $00
	db $ff, $2a, $00, $f1, $74, $00, $ff, $29, $00, $f1, $74, $00, $ff, $28, $00, $f1
	db $74, $00, $ff, $27, $00, $f1, $74, $00, $ff, $26, $00, $f1, $74, $00, $ff, $25
	db $00, $f1, $74, $00, $ff, $24, $00, $f1, $74, $00, $ff, $23, $00, $f1, $74, $00
	db $ff, $22, $00, $f1, $74, $00, $ff, $21, $00, $f1, $74, $00, $ff, $20, $00, $f1
	db $74, $00, $ff, $1f, $00, $f1, $74, $00, $ff, $1e, $00, $f1, $74, $00, $ff, $1d
	db $00, $f1, $74, $00, $ff, $1c, $00, $f1, $74, $00, $ff, $1b, $00, $f1, $74, $00
	db $ff, $1a, $00, $f1, $74, $00, $ff, $19, $00, $f1, $74, $00, $ff, $18, $00, $f1
	db $74, $00, $ff, $17, $00, $f1, $74, $00, $ff, $16, $00, $f1, $74, $00, $ff, $15
	db $00, $f1, $74, $00, $ff, $14, $00, $f1, $74, $00, $ff, $13, $00, $f1, $74, $00
	db $ff, $12, $00, $f1, $74, $00, $ff, $11, $00, $f1, $74, $00, $ff, $10, $00, $f1
	db $74, $01, $ff, $fb, $00, $67, $75, $01, $ff, $fb, $00, $63, $75, $01, $ff, $f1
	db $00, $5b, $75, $01, $ff, $4d, $00, $19, $75, $01, $ff, $4c, $00, $11, $75, $12
	db $02, $03, $ff, $4c, $00, $ff, $ff, $13, $02, $03, $ff, $4d, $00, $ff, $ff, $14
	db $02, $15, $ff, $3c, $c8, $01, $00, $25, $75, $15, $02, $16, $02, $0d, $ff, $03
	db $00, $00, $00, $00, $00, $0d, $ff, $03, $00, $05, $00, $00, $00, $49, $ff, $03
	db $00, $09, $ff, $01, $00, $13, $ff, $e3, $d8, $03, $00, $1c, $ff, $03, $17, $19
	db $ff, $0d, $ff, $03, $00, $00, $00, $40, $00, $12, $ff, $47, $d9, $01, $00, $ff
	db $ff, $c0, $07, $03, $ff, $fb, $00, $ff, $ff, $c1, $07, $ff, $ff, $c2, $07, $15
	db $ff, $3c, $c8, $01, $00, $b3, $75, $28, $ff, $b7, $75, $c5, $07, $03, $ff, $fc
	db $00, $29, $ff, $df, $00, $12, $ff, $47, $d9, $01, $00, $0d, $ff, $03, $00, $00
	db $00, $00, $00, $0d, $ff, $03, $00, $05, $00, $00, $00, $49, $ff, $03, $00, $09
	db $ff, $01, $00, $13, $ff, $e3, $d8, $03, $00, $1c, $ff, $03, $17, $19, $ff, $0d
	db $ff, $03, $00, $00, $00, $40, $00, $ff, $ff, $c3, $07, $ff, $ff, $c4, $07, $ff
	db $ff, $18, $02, $ff, $ff, $01, $ff, $f1, $00, $d3, $75, $01, $ff, $34, $00, $cf
	db $75, $17, $02, $ff, $ff, $40, $03, $ff, $ff, $c6, $07, $ff, $ff, $01, $ff, $8e
	db $00, $f3, $75, $01, $ff, $8d, $00, $eb, $75, $93, $03, $03, $ff, $8d, $00, $ff
	db $ff, $94, $03, $03, $ff, $8e, $00, $ff, $ff, $95, $03, $15, $ff, $3c, $c8, $01
	db $00, $05, $76, $96, $03, $97, $03, $14, $ff, $13, $76, $98, $03, $15, $ff, $3c
	db $c8, $01, $00, $05, $76, $99, $03, $9a, $03, $0d, $ff, $03, $00, $00, $00, $00
	db $00, $0d, $ff, $03, $00, $05, $00, $00, $00, $49, $ff, $03, $00, $09, $ff, $01
	db $00, $13, $ff, $e3, $d8, $03, $00, $1c, $ff, $03, $17, $19, $ff, $0d, $ff, $03
	db $00, $00, $00, $40, $00, $12, $ff, $47, $d9, $03, $00, $ff, $ff, $01, $ff, $f1
	db $00, $6f, $76, $01, $ff, $25, $00, $6b, $76, $01, $ff, $37, $00, $67, $76, $01
	db $ff, $36, $00, $63, $76, $9b, $03, $ff, $ff, $f0, $03, $ff, $ff, $4c, $04, $ff
	db $ff, $ae, $04, $ff, $ff, $c6, $07, $ff, $ff, $75, $76, $ff, $ff, $00, $00, $00
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
	db $00, $00, $00, $00, $00, $00
