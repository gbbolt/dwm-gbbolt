INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $017", ROMX[$4000], BANK[$17]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_17::
	db $17

;@ path: system/banks
;@ Entry points of bank $17, the Game Boy Color palettes: field palettes and attribute maps,
;@ palette sets, the CGB fade and the emulation of Game Boy palette writes.
FarTable_17::
	dw LoadMapPalettes
	dw LoadMapAttrBuffer
	dw LoadFieldObjPalettes
	dw ApplyDMGPalettes
	dw StartCGBFade
	dw UpdateCGBFade
	dw LoadMonPicPalette
	dw DrawMonPicAttrs
	dw UploadCGBPalettes
	dw SetSharedBGColors
	dw ClearAttrMap
	dw LoadPaletteSet
	dw LoadObjPaletteA
	dw LoadObjPaletteB

;@ def LoadMapPalettes()
;@ path: gfx/palettes
;@ On a Game Boy Color, loads background palettes 0-3 of the current map screen into
;@ wCGBBGPalettes. Normal maps: MapPaletteTable[wMapId] lists one entry per map screen
;@ (wMapScreen); an entry is the address of a story byte, then 4-byte records (attribute map
;@ as entry and bank for Decompress, palette address) picked by that byte's value. Gate
;@ floors: the palettes GatePaletteTable[wMapId]. Then SetSharedBGColors.
;@ test: skip reads pointer tables in this bank
LoadMapPalettes::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> if wOnGateFloor:
;>@g1     CopyBGPalettes(mem16[GatePaletteTable + 2 * wMapId], 0, 4)   # (the floor's attribute map is looked up too, unused)
;>@g2     return SetSharedBGColors()
	ld a, [wOnGateFloor]
	or a
	jp nz, .gate

;> entry = MapPaletteTable + 2 * wMapId
	ld hl, MapPaletteTable
	ld a, [wMapId]
	add a
	add l
	ld l, a
	ld a, $00
;> screens = mem16[entry]
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> entry = screens + 2 * wMapScreen
	ld a, [wMapScreen]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;> screen = mem16[entry]
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> flag = mem16[screen]                 # the story byte that picks the version
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
;> record = screen + 2 + 4 * mem[flag]
	ld a, [de]
	add a
	add a
	add l
	ld l, a
	ld a, $00
;> palettes = mem16[record + 2]         # (the first word is the attribute map)
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
;> CopyBGPalettes(palettes, 0, 4)
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, $00
	ld b, $04
	call CopyBGPalettes
;> return SetSharedBGColors()
	jp SetSharedBGColors

.gate
;=@g1
	ld de, GateAttrMaps1
	ld a, [$c93f]
	cp $02
	jr nz, .gateMaps

	ld de, GateAttrMaps2

.gateMaps
;=@g1
	ld a, [wMapScreen]
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
;=@g1
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	add hl, de
	ld a, [hli]
;=@g1
	ld d, [hl]
	ld e, a
	ld hl, GatePaletteTable
	ld a, [wMapId]
	add a
	add l
;=@g1
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@g1
	ld l, a
	ld c, $00
	ld b, $04
	call CopyBGPalettes
;=@g2
	jr SetSharedBGColors

;@ def LoadMapAttrBuffer()
;@ path: gfx/palettes
;@ Unpacks the attribute map of the current map screen (picked like the palettes in
;@ LoadMapPalettes; on gate floors GateAttrMaps1/2 by the room's layout byte in wFloorLayout) into
;@ wScreenMap, 4 bits per map cell.
;@ test: skip reads pointer tables in this bank
LoadMapAttrBuffer::
;> if wOnGateFloor:
;>@g     return Decompress(GateAttrMaps[wFloorLayout[wMapScreen]], wScreenMap)
	ld a, [wOnGateFloor]
	or a
	jp nz, .gate

;> entry = MapPaletteTable + 2 * wMapId
	ld hl, MapPaletteTable
	ld a, [wMapId]
	add a
	add l
	ld l, a
	ld a, $00
;> screens = mem16[entry]
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> entry = screens + 2 * wMapScreen
	ld a, [wMapScreen]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;> screen = mem16[entry]
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> flag = mem16[screen]
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
;> record = screen + 2 + 4 * mem[flag]
	ld a, [de]
	add a
	add a
	add l
	ld l, a
	ld a, $00
;> source = mem16[record]              # entry and bank of the attribute map
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
;> Decompress(source, wScreenMap)
	ld hl, wScreenMap
	call Decompress
	ret

.gate
;=@g
	ld de, GateAttrMaps1
	ld a, [$c93f]
	cp $02
	jr nz, .gateMaps

	ld de, GateAttrMaps2

.gateMaps
;=@g
	ld a, [wMapScreen]
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
;=@g
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	add hl, de
	ld a, [hli]
;=@g
	ld d, [hl]
	ld e, a
	ld hl, wScreenMap
	call Decompress
	ret


;@ def SetSharedBGColors()
;@ path: gfx/palettes
;@ Loads background palette 7 (FieldBGPalette7, the text box colors) and copies its colors 1
;@ and 3 into colors 1 and 3 of palettes 0-6, so text and window frames look the same on
;@ every palette.
SetSharedBGColors::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> CopyBGPalettes(FieldBGPalette7, 7, 1)
	ld hl, FieldBGPalette7
	ld c, $07
	ld b, $01
	call CopyBGPalettes
;> color1 = mem16[wCGBBGPalettes + 7 * 8 + 2]
	ld a, [wCGBBGPalettes + 58]
	ld l, a
	ld a, [wCGBBGPalettes + 59]
	ld h, a
;>@c1 for p in range(7): mem16[wCGBBGPalettes + 8 * p + 2] = color1
	ld a, l
	ld [wCGBBGPalettes + 2], a
	ld a, h
	ld [wCGBBGPalettes + 3], a
	ld a, l
	ld [wCGBBGPalettes + 10], a
;=@c1
	ld a, h
	ld [wCGBBGPalettes + 11], a
	ld a, l
	ld [wCGBBGPalettes + 18], a
	ld a, h
	ld [wCGBBGPalettes + 19], a
;=@c1
	ld a, l
	ld [wCGBBGPalettes + 26], a
	ld a, h
	ld [wCGBBGPalettes + 27], a
	ld a, l
	ld [wCGBBGPalettes + 34], a
;=@c1
	ld a, h
	ld [wCGBBGPalettes + 35], a
	ld a, l
	ld [wCGBBGPalettes + 42], a
	ld a, h
	ld [wCGBBGPalettes + 43], a
;=@c1
	ld a, l
	ld [wCGBBGPalettes + 50], a
	ld a, h
	ld [wCGBBGPalettes + 51], a
;> color3 = mem16[wCGBBGPalettes + 7 * 8 + 6]
	ld a, [wCGBBGPalettes + 62]
	ld l, a
	ld a, [wCGBBGPalettes + 63]
	ld h, a
;>@c3 for p in range(7): mem16[wCGBBGPalettes + 8 * p + 6] = color3
	ld a, l
	ld [wCGBBGPalettes + 6], a
	ld a, h
	ld [wCGBBGPalettes + 7], a
	ld a, l
	ld [wCGBBGPalettes + 14], a
;=@c3
	ld a, h
	ld [wCGBBGPalettes + 15], a
	ld a, l
	ld [wCGBBGPalettes + 22], a
	ld a, h
	ld [wCGBBGPalettes + 23], a
;=@c3
	ld a, l
	ld [wCGBBGPalettes + 30], a
	ld a, h
	ld [wCGBBGPalettes + 31], a
	ld a, l
	ld [wCGBBGPalettes + 38], a
;=@c3
	ld a, h
	ld [wCGBBGPalettes + 39], a
	ld a, l
	ld [wCGBBGPalettes + 46], a
	ld a, h
	ld [wCGBBGPalettes + 47], a
;=@c3
	ld a, l
	ld [wCGBBGPalettes + 54], a
	ld a, h
	ld [wCGBBGPalettes + 55], a
	ret


;@ def ClearAttrMap()
;@ path: gfx/palettes
;@ On a Game Boy Color, sets every cell of the BG map at $9800 to attribute 7 (palette 7).
;@ test: skip writes VRAM
ClearAttrMap::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> disable_interrupts(); WaitVRAMAccess(); rVBK = 1; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
;> addr = 0x9800
	ld b, $00
	ld hl, $9800

.loop
;>@loop for i in range(256 * 4):
;>     addr = WriteVRAMInc(7, addr)
	ld a, $07
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
	call WriteVRAMInc
;=@loop
	dec b
	jr nz, .loop

;> disable_interrupts(); WaitVRAMAccess(); rVBK = 0; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
	ret


;@ def LoadFieldObjPalettes()
;@ path: gfx/palettes
;@ On a Game Boy Color, loads the eight sprite palettes of the field (FieldObjPalettes).
LoadFieldObjPalettes::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> CopyObjPalettes(FieldObjPalettes, 0, 8)
	ld hl, FieldObjPalettes
	ld c, $00
	ld b, $08
	call CopyObjPalettes
	ret


;@ def LoadMonPicPalette()
;@ path: gfx/palettes
;@ On a Game Boy Color, loads the palette of monster picture wPaletteSet (MonPicPalettes, one
;@ palette each) into background palette number $C81F, then DrawMonPicAttrs.
;@ test: skip writes VRAM
LoadMonPicPalette::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;>@pal CopyBGPalettes(MonPicPalettes + 8 * wPaletteSet, mem[0xC81F], 1)
	ld a, [wPaletteSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@pal
	ld a, l
	add LOW(MonPicPalettes)
	ld l, a
	ld a, h
	adc HIGH(MonPicPalettes)
	ld h, a
;=@pal
	ld a, [$c81f]
	ld c, a
	ld b, $01
	call CopyBGPalettes
;> SetSharedBGColors()
	call SetSharedBGColors
;> DrawMonPicAttrs()                     # falls through

;@ def DrawMonPicAttrs()
;@ path: gfx/palettes
;@ On a Game Boy Color, gives the 6 x 6 tiles of a monster picture palette $C81F: the block
;@ starts at screen offset $C820 (row * 32 + column) from the screen's top left corner.
;@ test: skip writes VRAM
DrawMonPicAttrs::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> row_offset = (hScrollY & 0xF8) * 4
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
;> corner = 0x9800 + row_offset
	sla l
	rla
	ld h, $98
	add h
	ld h, a
;> corner += (hScrollX >> 3) & 0x1F      # the screen's top left corner
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
;> offset = mem16[0xC820]
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c820]
	ld c, a
;> pos = corner + (offset & 0xFFE0)      # down to the picture's first row
	ld a, [$c821]
	ld b, a
	ld a, c
	and $e0
	ld c, a
	add hl, bc
;> pos &= ~0x0400                        # stay inside the map at $9800
	res 2, h
;>@cols for i in range(mem[0xC820] & 0x1F):
	ld a, [$c820]
	and $1f
	ld b, a

.column
;>     pos = NextMapColumn_17(pos)
	call NextMapColumn_17
;=@cols
	dec b
	jr nz, .column

;> disable_interrupts(); WaitVRAMAccess(); rVBK = 1; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
;>@rows for row in range(6):
	ld c, $06

.row
;>     line = pos
	ld b, $06
	push hl

.cell
;>@cells     for col in range(6):
;>         WriteVRAM(mem[0xC81F], pos); pos = NextMapColumn_17(pos)
	ld a, [$c81f]
	call WriteVRAM
	call NextMapColumn_17
;=@cells
	dec b
	jr nz, .cell

;>     pos = line + 0x20
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;>     pos = 0x9800 | (pos & 0x3FF)
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
;=@rows
	dec c
	jr nz, .row

;> disable_interrupts(); WaitVRAMAccess(); rVBK = 0; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
	ret


;@ def NextMapColumn_17(pos: hl) -> hl
;@ path: gfx/palettes
;@ Moves a BG map address one column right, wrapping around within its 32-tile row.
NextMapColumn_17::
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


;@ def ApplyDMGPalettes()
;@ path: gfx/palettes
;@ On a Game Boy Color, makes a change of the Game Boy palette wBGP visible: when wBGP differs
;@ from the value in effect (wDefaultPalettes[0]), every background palette is rewritten with
;@ its colors rearranged the way wBGP rearranges the four shades (WriteBGPaletteDMG). Then
;@ the same for the sprite palettes and wOBP0 (ApplyDMGObjPalettes).
;@ test: skip writes the palette registers
ApplyDMGPalettes::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> if wBGP != wDefaultPalettes[0]:
	ld hl, wDefaultPalettes
	ld a, [wBGP]
	cp [hl]
	jp z, ApplyDMGObjPalettes

;>     WaitVRAMAccess(); rBCPS = 0x80       # palette 0, color 0, auto-increment
	call WaitVRAMAccess
	ld a, $80
	ldh [rBCPS], a
;>@pals     for p in range(8):
;>         WriteBGPaletteDMG(wCGBBGPalettes + 8 * p)
	ld hl, wCGBBGPalettes
	call WriteBGPaletteDMG
	call WriteBGPaletteDMG
	call WriteBGPaletteDMG
	call WriteBGPaletteDMG
	call WriteBGPaletteDMG
;=@pals
	call WriteBGPaletteDMG
	call WriteBGPaletteDMG
	call WriteBGPaletteDMG
;>     wDefaultPalettes[0] = wBGP
	ld a, [wBGP]
	ld [wDefaultPalettes], a
;> ApplyDMGObjPalettes()
	jp ApplyDMGObjPalettes


;@ def WriteBGPaletteDMG(pal: hl) -> hl
;@ path: gfx/palettes
;@ Writes the CGB background palette at `pal` to rBCPD with its four colors rearranged like the
;@ Game Boy palette wBGP rearranges the shades: color n is the palette color picked by
;@ shade field n of wBGP (through .shadeOffsets). Returns pal + 8.
;@ test: skip writes the palette registers
WriteBGPaletteDMG::
;>@s0 rBCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wBGP >> 0) & 3]]   # color 0
	push hl
	ld a, [wBGP]
	and $03
	ld de, WriteObjPaletteDMG.shadeOffsets
	add e
	ld e, a
;=@s0
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add l
	ld l, a
;=@s0
	ld a, $00
	adc h
	ld h, a
	call WaitVRAMAccess
	ld a, [hli]
	ldh [rBCPD], a
;=@s0
	ld a, [hl]
	ldh [rBCPD], a
	pop hl
;>@s1 rBCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wBGP >> 2) & 3]]   # color 1
	push hl
	ld a, [wBGP]
	srl a
	srl a
	and $03
	ld de, WriteObjPaletteDMG.shadeOffsets
;=@s1
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
;=@s1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call WaitVRAMAccess
;=@s1
	ld a, [hli]
	ldh [rBCPD], a
	ld a, [hl]
	ldh [rBCPD], a
	pop hl
;>@s2 rBCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wBGP >> 4) & 3]]   # color 2
	push hl
	ld a, [wBGP]
	swap a
	and $03
	ld de, WriteObjPaletteDMG.shadeOffsets
	add e
;=@s2
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add l
;=@s2
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call WaitVRAMAccess
	ld a, [hli]
;=@s2
	ldh [rBCPD], a
	ld a, [hl]
	ldh [rBCPD], a
	pop hl
;>@s3 rBCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wBGP >> 6) & 3]]   # color 3
	push hl
	ld a, [wBGP]
	swap a
	srl a
	srl a
	and $03
;=@s3
	ld de, WriteObjPaletteDMG.shadeOffsets
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;=@s3
	ld a, [de]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@s3
	call WaitVRAMAccess
	ld a, [hli]
	ldh [rBCPD], a
	ld a, [hl]
	ldh [rBCPD], a
	pop hl
;> pal += 8
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
;> return pal
	ret


;@ def ApplyDMGObjPalettes()
;@ path: gfx/palettes
;@ The sprite half of ApplyDMGPalettes: when wOBP0 differs from the value in effect
;@ (wDefaultPalettes[1]), all eight sprite palettes (the buffer at wSGBPalettes) are
;@ rewritten through WriteObjPaletteDMG.
;@ test: skip writes the palette registers
ApplyDMGObjPalettes::
;> if wOBP0 == wDefaultPalettes[1]:
;>     return
	ld hl, wDefaultPalettes + 1
	ld a, [wOBP0]
	cp [hl]
	jp z, WriteObjPaletteDMG.done

;> WaitVRAMAccess(); rOCPS = 0x80
	call WaitVRAMAccess
	ld a, $80
	ldh [rOCPS], a
;>@pals for p in range(8):
;>     WriteObjPaletteDMG(wSGBPalettes + 8 * p)
	ld hl, wSGBPalettes
	call WriteObjPaletteDMG
	call WriteObjPaletteDMG
	call WriteObjPaletteDMG
	call WriteObjPaletteDMG
	call WriteObjPaletteDMG
;=@pals
	call WriteObjPaletteDMG
	call WriteObjPaletteDMG
	call WriteObjPaletteDMG
;> wDefaultPalettes[1] = wOBP0
	ld a, [wOBP0]
	ld [wDefaultPalettes + 1], a
	jp WriteObjPaletteDMG.done


;@ def WriteObjPaletteDMG(pal: hl) -> hl
;@ path: gfx/palettes
;@ Writes the CGB sprite palette at `pal` to rOCPD with its four colors rearranged like the
;@ Game Boy palette wOBP0 rearranges the shades: color n is the palette color picked by
;@ shade field n of wOBP0. After it: .shadeOffsets, the byte offset of the color each Game
;@ Boy shade stands for (shade 0 -> color 1, 1 -> 2, 2 -> 0, 3 -> 3).
;@ test: skip writes the palette registers
WriteObjPaletteDMG::
;>@s0 rOCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wOBP0 >> 0) & 3]]   # color 0
	push hl
	ld a, [wOBP0]
	and $03
	ld de, WriteObjPaletteDMG.shadeOffsets
	add e
	ld e, a
;=@s0
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add l
	ld l, a
;=@s0
	ld a, $00
	adc h
	ld h, a
	call WaitVRAMAccess
	ld a, [hli]
	ldh [rOCPD], a
;=@s0
	ld a, [hl]
	ldh [rOCPD], a
	pop hl
;>@s1 rOCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wOBP0 >> 2) & 3]]   # color 1
	push hl
	ld a, [wOBP0]
	srl a
	srl a
	and $03
	ld de, WriteObjPaletteDMG.shadeOffsets
;=@s1
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
;=@s1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call WaitVRAMAccess
;=@s1
	ld a, [hli]
	ldh [rOCPD], a
	ld a, [hl]
	ldh [rOCPD], a
	pop hl
;>@s2 rOCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wOBP0 >> 4) & 3]]   # color 2
	push hl
	ld a, [wOBP0]
	swap a
	and $03
	ld de, WriteObjPaletteDMG.shadeOffsets
	add e
;=@s2
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add l
;=@s2
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call WaitVRAMAccess
	ld a, [hli]
;=@s2
	ldh [rOCPD], a
	ld a, [hl]
	ldh [rOCPD], a
	pop hl
;>@s3 rOCPD = mem16[pal + WriteObjPaletteDMG.shadeOffsets[(wOBP0 >> 6) & 3]]   # color 3
	push hl
	ld a, [wOBP0]
	swap a
	srl a
	srl a
	and $03
;=@s3
	ld de, WriteObjPaletteDMG.shadeOffsets
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;=@s3
	ld a, [de]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@s3
	call WaitVRAMAccess
	ld a, [hli]
	ldh [rOCPD], a
	ld a, [hl]
	ldh [rOCPD], a
	pop hl
;> pal += 8
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
;> return pal
	ret

.done
	ret

.shadeOffsets
	db $02, $04, $00, $06

;@ def StartCGBFade()
;@ path: gfx/fade
;@ Starts a palette fade on a Game Boy Color (StartFade calls it). wFadeState bit 7 clear:
;@ a fade out to white from level 0, speed wFadeState / 4; bit 7 set: a fade in from white,
;@ level $20, speed ~wFadeState / 4, and every palette color is set to white ($7FFF) first.
;@ test: skip writes the palette registers
StartCGBFade::
;> if not wFadeState & 0x80:              # fade out
	ld a, [wFadeState]
	ld b, a
	bit 7, b
	jr nz, .fadeIn

;>     wFadeLevel = 0
	ld a, $00
	ld [wFadeLevel], a
;>     wFadeSpeed = wFadeState >> 2
	ld a, [wFadeState]
	srl a
	srl a
	ld [wFadeSpeed], a
;>     wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;>     StartMusicFadeOut()
	call StartMusicFadeOut
;>     return
	ret

.fadeIn
;> wFadeLevel = 0x20
	ld a, $20
	ld [wFadeLevel], a
;> wFadeSpeed = (~wFadeState & 0xFF) >> 2
	ld a, [wFadeState]
	cpl
	srl a
	srl a
	ld [wFadeSpeed], a
;> wFadeTimer = wFadeSpeed
	ld [wFadeTimer], a
;> disable_interrupts(); WaitVRAMAccess(); rBCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rBCPS], a
	ei
;>@bg for i in range(32):                 # all background colors white
	ld b, $20

.bg
;>     disable_interrupts(); WaitVRAMAccess(); rBCPD = 0xFF; rBCPD = 0x7F; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $ff
	ldh [rBCPD], a
	ld a, $7f
	ldh [rBCPD], a
;=@bg
	ei
	dec b
	jr nz, .bg

;> disable_interrupts(); WaitVRAMAccess(); rOCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rOCPS], a
	ei
;>@obj for i in range(32):                # all sprite colors white
	ld b, $20

.obj
;>     disable_interrupts(); WaitVRAMAccess(); rOCPD = 0xFF; rOCPD = 0x7F; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $ff
	ldh [rOCPD], a
	ld a, $7f
	ldh [rOCPD], a
;=@obj
	ei
	dec b
	jr nz, .obj

	ret


;@ def UpdateCGBFade()
;@ path: gfx/fade
;@ One frame of the CGB fade: every wFadeSpeed frames the level moves 5 steps (out: up to
;@ $1F, in: down to 0) and all palettes are written lightened by it (WriteFadeOutPalettes /
;@ WriteFadeInPalettes). At the end wFadeState is cleared.
;@ test: skip writes the palette registers
UpdateCGBFade::
;> if not wFadeState & 0x80:              # fading out
	ld a, [wFadeState]
	bit 7, a
	jr nz, .fadeIn

;>     if wFadeTimer:
;>         wFadeTimer -= 1; return
	ld a, [wFadeTimer]
	or a
	jr z, .stepOut

	dec a
	ld [wFadeTimer], a
	ret

.stepOut
;>     wFadeLevel = min(wFadeLevel + 5, 0x1F)
	ld a, [wFadeLevel]
	add $05
	cp $1f
	jr c, .setOut

	ld a, $1f

.setOut
	ld [wFadeLevel], a
;>     WriteFadeOutPalettes()
	call WriteFadeOutPalettes
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     if wFadeLevel == 0x1F:
;>@endo         wFadeState = 0
	ld a, [wFadeLevel]
	cp $1f
	jp z, .end

	ret

.fadeIn
;> else:
;>     if wFadeTimer:
;>         wFadeTimer -= 1; return
	ld a, [wFadeTimer]
	or a
	jr z, .stepIn

	dec a
	ld [wFadeTimer], a
	ret

.stepIn
;>     wFadeLevel = max(wFadeLevel - 5, 0)
	ld a, [wFadeLevel]
	sub $05
	bit 7, a
	jr z, .setIn

	xor a

.setIn
	ld [wFadeLevel], a
;>     WriteFadeInPalettes()
	call WriteFadeInPalettes
;>     wFadeTimer = wFadeSpeed
	ld a, [wFadeSpeed]
	ld [wFadeTimer], a
;>     if wFadeLevel == 0:
;>@endi         wFadeState = 0
	ld a, [wFadeLevel]
	or a
	jp z, .end

	ret

.end
;=@endo
	xor a
	ld [wFadeState], a
	ret


;@ def WriteFadeOutPalettes()
;@ path: gfx/fade
;@ Writes all eight background palettes (wCGBBGPalettes) and all eight sprite palettes
;@ (wSGBPalettes) to the CGB palette RAM, faded towards white by wFadeLevel.
;@ test: skip writes the palette registers
WriteFadeOutPalettes::
;> disable_interrupts(); WaitVRAMAccess(); rBCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rBCPS], a
	ei
;>@bg for p in range(8):
;>     WriteFadeOutBGPalette(wCGBBGPalettes + 8 * p)
	ld hl, wCGBBGPalettes
	call WriteFadeOutBGPalette
	call WriteFadeOutBGPalette
	call WriteFadeOutBGPalette
	call WriteFadeOutBGPalette
	call WriteFadeOutBGPalette
;=@bg
	call WriteFadeOutBGPalette
	call WriteFadeOutBGPalette
	call WriteFadeOutBGPalette
;> disable_interrupts(); WaitVRAMAccess(); rOCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rOCPS], a
	ei
;>@obj for p in range(8):
;>     WriteFadeOutObjPalette(wSGBPalettes + 8 * p)
	ld hl, wSGBPalettes
	call WriteFadeOutObjPalette
	call WriteFadeOutObjPalette
	call WriteFadeOutObjPalette
	call WriteFadeOutObjPalette
	call WriteFadeOutObjPalette
;=@obj
	call WriteFadeOutObjPalette
	call WriteFadeOutObjPalette
	call WriteFadeOutObjPalette
	ret


;@ def WriteFadeOutObjPalette(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the four colors of the sprite palette at `pal` (WriteFadeOutObjColor) and returns pal + 8.
;@ test: skip writes the palette registers
WriteFadeOutObjPalette::
;>@c for i in range(4):
;>     pal = WriteFadeOutObjColor(pal)            # the fourth time by falling through
	call WriteFadeOutObjColor
	call WriteFadeOutObjColor
	call WriteFadeOutObjColor

;@ def WriteFadeOutObjColor(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the RGB555 color at `pal` to rOCPD with each of its components raised to at least wFadeLevel, and
;@ returns pal + 2.
;@ test: skip writes the palette registers
WriteFadeOutObjColor::
;> color = mem16[pal]; pal += 2
	ld a, [wFadeLevel]
	ld d, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
;> out = 0
	ld de, $0000
;>@comp for i in range(3):              # red, green, blue: each moves into `out`
;>     color, out = FadeOutComponent(color, out)
	call FadeOutComponent
	call FadeOutComponent
	call FadeOutComponent
;> out >>= 1                           # (the last bit into place)
	rr b
	rr c
	rr d
	rr e
;> disable_interrupts(); WaitVRAMAccess()
	di
	call WaitVRAMAccess
;> rOCPD = out & 0xFF; rOCPD = out >> 8
	ld a, e
	ldh [rOCPD], a
	ld a, d
	ldh [rOCPD], a
;> enable_interrupts()
	ei
	ret


;@ def WriteFadeOutBGPalette(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the four colors of the background palette at `pal` (WriteFadeOutBGColor) and returns pal + 8.
;@ test: skip writes the palette registers
WriteFadeOutBGPalette::
;>@c for i in range(4):
;>     pal = WriteFadeOutBGColor(pal)            # the fourth time by falling through
	call WriteFadeOutBGColor
	call WriteFadeOutBGColor
	call WriteFadeOutBGColor

;@ def WriteFadeOutBGColor(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the RGB555 color at `pal` to rBCPD with each of its components raised to at least wFadeLevel, and
;@ returns pal + 2.
;@ test: skip writes the palette registers
WriteFadeOutBGColor::
;> color = mem16[pal]; pal += 2
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
;> out = 0
	ld de, $0000
;>@comp for i in range(3):              # red, green, blue: each moves into `out`
;>     color, out = FadeOutComponent(color, out)
	call FadeOutComponent
	call FadeOutComponent
	call FadeOutComponent
;> out >>= 1                           # (the last bit into place)
	rr b
	rr c
	rr d
	rr e
;> disable_interrupts(); WaitVRAMAccess()
	di
	call WaitVRAMAccess
;> rBCPD = out & 0xFF; rBCPD = out >> 8
	ld a, e
	ldh [rBCPD], a
	ld a, d
	ldh [rBCPD], a
;> enable_interrupts()
	ei
	ret


;@ def FadeOutComponent(color: bc, out: de) -> (bc, de)
;@ path: gfx/fade
;@ Replaces the low 5-bit component of `color` by max(component, wFadeLevel), then shifts
;@ color:out (32 bits) right by 5, so the next component comes to the bottom.
FadeOutComponent::
;> comp = color & 0x1F
	push de
	ld a, c
	and $1f
	ld d, a
;> value = max(comp, wFadeLevel)
	ld a, [wFadeLevel]
	cp d
	jr nc, .keep

	ld a, d

.keep
;> color = (color & 0xFFE0) | value
	ld e, a
	ld a, c
	and $e0
	or e
	ld c, a
	pop de
;>@sh for i in range(5):
;>     color, out = shift_right_32(color, out)
	rr b
	rr c
	rr d
	rr e
	rr b
	rr c
;=@sh
	rr d
	rr e
	rr b
	rr c
	rr d
	rr e
;=@sh
	rr b
	rr c
	rr d
	rr e
	rr b
	rr c
;=@sh
	rr d
	rr e
	ret


;@ def WriteFadeInPalettes()
;@ path: gfx/fade
;@ Writes all eight background palettes (wCGBBGPalettes) and all eight sprite palettes
;@ (wSGBPalettes) to the CGB palette RAM, lightened by wFadeLevel.
;@ test: skip writes the palette registers
WriteFadeInPalettes::
;> disable_interrupts(); WaitVRAMAccess(); rBCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rBCPS], a
	ei
;>@bg for p in range(8):
;>     WriteFadeInBGPalette(wCGBBGPalettes + 8 * p)
	ld hl, wCGBBGPalettes
	call WriteFadeInBGPalette
	call WriteFadeInBGPalette
	call WriteFadeInBGPalette
	call WriteFadeInBGPalette
	call WriteFadeInBGPalette
;=@bg
	call WriteFadeInBGPalette
	call WriteFadeInBGPalette
	call WriteFadeInBGPalette
;> disable_interrupts(); WaitVRAMAccess(); rOCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rOCPS], a
	ei
;>@obj for p in range(8):
;>     WriteFadeInObjPalette(wSGBPalettes + 8 * p)
	ld hl, wSGBPalettes
	call WriteFadeInObjPalette
	call WriteFadeInObjPalette
	call WriteFadeInObjPalette
	call WriteFadeInObjPalette
	call WriteFadeInObjPalette
;=@obj
	call WriteFadeInObjPalette
	call WriteFadeInObjPalette
	call WriteFadeInObjPalette
	ret


;@ def WriteFadeInObjPalette(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the four colors of the sprite palette at `pal` (WriteFadeInObjColor) and returns pal + 8.
;@ test: skip writes the palette registers
WriteFadeInObjPalette::
;>@c for i in range(4):
;>     pal = WriteFadeInObjColor(pal)            # the fourth time by falling through
	call WriteFadeInObjColor
	call WriteFadeInObjColor
	call WriteFadeInObjColor

;@ def WriteFadeInObjColor(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the RGB555 color at `pal` to rOCPD with each of its components raised by wFadeLevel (up to 31), and
;@ returns pal + 2.
;@ test: skip writes the palette registers
WriteFadeInObjColor::
;> color = mem16[pal]; pal += 2
	ld a, [wFadeLevel]
	ld d, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
;> out = 0
	ld de, $0000
;>@comp for i in range(3):              # red, green, blue: each moves into `out`
;>     color, out = FadeInComponent(color, out)
	call FadeInComponent
	call FadeInComponent
	call FadeInComponent
;> out >>= 1                           # (the last bit into place)
	rr b
	rr c
	rr d
	rr e
;> disable_interrupts(); WaitVRAMAccess()
	di
	call WaitVRAMAccess
;> rOCPD = out & 0xFF; rOCPD = out >> 8
	ld a, e
	ldh [rOCPD], a
	ld a, d
	ldh [rOCPD], a
;> enable_interrupts()
	ei
	ret


;@ def WriteFadeInBGPalette(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the four colors of the background palette at `pal` (WriteFadeInBGColor) and returns pal + 8.
;@ test: skip writes the palette registers
WriteFadeInBGPalette::
;>@c for i in range(4):
;>     pal = WriteFadeInBGColor(pal)            # the fourth time by falling through
	call WriteFadeInBGColor
	call WriteFadeInBGColor
	call WriteFadeInBGColor

;@ def WriteFadeInBGColor(pal: hl) -> hl
;@ path: gfx/fade
;@ Writes the RGB555 color at `pal` to rBCPD with each of its components raised by wFadeLevel (up to 31), and
;@ returns pal + 2.
;@ test: skip writes the palette registers
WriteFadeInBGColor::
;> color = mem16[pal]; pal += 2
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
;> out = 0
	ld de, $0000
;>@comp for i in range(3):              # red, green, blue: each moves into `out`
;>     color, out = FadeInComponent(color, out)
	call FadeInComponent
	call FadeInComponent
	call FadeInComponent
;> out >>= 1                           # (the last bit into place)
	rr b
	rr c
	rr d
	rr e
;> disable_interrupts(); WaitVRAMAccess()
	di
	call WaitVRAMAccess
;> rBCPD = out & 0xFF; rBCPD = out >> 8
	ld a, e
	ldh [rBCPD], a
	ld a, d
	ldh [rBCPD], a
;> enable_interrupts()
	ei
	ret


;@ def FadeInComponent(color: bc, out: de) -> (bc, de)
;@ path: gfx/fade
;@ Replaces the low 5-bit component of `color` by min(component + wFadeLevel, 31), then shifts
;@ color:out (32 bits) right by 5, so the next component comes to the bottom.
FadeInComponent::
;> comp = color & 0x1F
	push de
	ld a, c
	and $1f
	ld d, a
;> value = min(comp + wFadeLevel, 0x1F)
	ld a, [wFadeLevel]
	add d
	cp $1f
	jr c, .keep

	ld a, $1f

.keep
;> color = (color & 0xFFE0) | value
	ld e, a
	ld a, c
	and $e0
	or e
	ld c, a
	pop de
;>@sh for i in range(5):
;>     color, out = shift_right_32(color, out)
	rr b
	rr c
	rr d
	rr e
	rr b
	rr c
;=@sh
	rr d
	rr e
	rr b
	rr c
	rr d
	rr e
;=@sh
	rr b
	rr c
	rr d
	rr e
	rr b
	rr c
;=@sh
	rr d
	rr e
	ret


;@ def CopyBGPalettes(src: hl, first: c, count: b)
;@ path: gfx/palettes
;@ On a Game Boy Color, copies `count` palettes (8 bytes each) from `src` into
;@ wCGBBGPalettes from palette `first` on (UploadCGBPalettes sends them to the LCD).
CopyBGPalettes::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> size = 8 * count
	ld a, b
	add a
	add a
	add a
	ld b, a
;>@d dest = wCGBBGPalettes + 8 * first
	ld a, c
	add a
	add a
	add a
	ld de, wCGBBGPalettes
	add e
;=@d
	ld e, a
	ld a, $00
	adc d
	ld d, a

.copy
;> copy(dest, src, size)
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy

	ret


;@ def CopyObjPalettes(src: hl, first: c, count: b)
;@ path: gfx/palettes
;@ The same for the sprite palettes (the buffer at wSGBPalettes).
CopyObjPalettes::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> size = 8 * count
	ld a, b
	add a
	add a
	add a
	ld b, a
;>@d dest = wSGBPalettes + 8 * first
	ld a, c
	add a
	add a
	add a
	ld de, wSGBPalettes
	add e
;=@d
	ld e, a
	ld a, $00
	adc d
	ld d, a

.copy
;> copy(dest, src, size)
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy

	ret


;@ def UploadCGBPalettes()
;@ path: gfx/palettes
;@ On a Game Boy Color, sends all 8 background palettes (wCGBBGPalettes) and all 8 sprite
;@ palettes (the 64 bytes after them, at wSGBPalettes) to the palette RAM.
;@ test: skip writes the palette registers
UploadCGBPalettes::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> disable_interrupts(); WaitVRAMAccess(); rBCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rBCPS], a
	ei
;> src = wCGBBGPalettes
	ld hl, wCGBBGPalettes
	ld b, $40

.bg
;>@bg for i in range(64):
;>     disable_interrupts(); WaitVRAMAccess(); rBCPD = mem[src]; src += 1; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, [hli]
	ldh [rBCPD], a
	ei
;=@bg
	dec b
	jr nz, .bg

;> disable_interrupts(); WaitVRAMAccess(); rOCPS = 0x80; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, $80
	ldh [rOCPS], a
	ei
	ld b, $40

.obj
;>@obj for i in range(64):                # src continues into the sprite palettes
;>     disable_interrupts(); WaitVRAMAccess(); rOCPD = mem[src]; src += 1; enable_interrupts()
	di
	call WaitVRAMAccess
	ld a, [hli]
	ldh [rOCPD], a
	ei
;=@obj
	dec b
	jr nz, .obj

	ret


;@ def LoadPaletteSet()
;@ path: gfx/palettes
;@ On a Game Boy Color, loads background palette set wPaletteSet: all 8 palettes (64 bytes)
;@ from PaletteSets.
LoadPaletteSet::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;>@off offset = 64 * wPaletteSet
	ld a, [wPaletteSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@off
	add hl, hl
	add hl, hl
	add hl, hl
;>@cp CopyBGPalettes(PaletteSets + offset, 0, 8)
	ld a, l
	add LOW(PaletteSets)
	ld l, a
	ld a, h
	adc HIGH(PaletteSets)
	ld h, a
;=@cp
	ld c, $00
	ld b, $08
	call CopyBGPalettes
	ret


;@ def LoadObjPaletteA()
;@ path: gfx/palettes
;@ On a Game Boy Color, loads sprite palette 0 from ObjPaletteSetsA[wPaletteSet] (8 bytes).
LoadObjPaletteA::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;>@p CopyObjPalettes(ObjPaletteSetsA + 8 * wPaletteSet, 0, 1)
	ld a, [wPaletteSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@p
	ld a, l
	add LOW(ObjPaletteSetsA)
	ld l, a
	ld a, h
	adc HIGH(ObjPaletteSetsA)
	ld h, a
;=@p
	ld c, $00
	ld b, $01
	call CopyObjPalettes
	ret


;@ def LoadObjPaletteB()
;@ path: gfx/palettes
;@ On a Game Boy Color, loads sprite palette 0 from ObjPaletteSetsB[wPaletteSet] (8 bytes).
;@ The palette tables of the bank follow.
LoadObjPaletteB::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;>@p CopyObjPalettes(ObjPaletteSetsB + 8 * wPaletteSet, 0, 1)
	ld a, [wPaletteSet]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@p
	ld a, l
	add LOW(ObjPaletteSetsB)
	ld l, a
	ld a, h
	adc HIGH(ObjPaletteSetsB)
	ld h, a
;=@p
	ld c, $00
	ld b, $01
	call CopyObjPalettes
	ret


;@ path: gfx/palettes
;@ Game Boy Color colors of the normal maps, read by LoadMapPalettes and LoadMapAttrBuffer:
;@ one pointer per map number to a list with one pointer per map screen (wMapScreen). Such a
;@ screen entry is the address of a story byte, then 4-byte records picked by that byte's
;@ value: the compressed attribute map (entry and bank for Decompress) and the address of its
;@ 4 background palettes.
MapPaletteTable::
	db $3f, $48, $9d, $48, $25, $49, $9d, $49, $f5, $49, $6d, $4a, $99, $4a, $b3, $4a
	db $07, $4b, $2f, $4b, $65, $4b, $3f, $48, $79, $4b, $81, $4b, $3f, $48, $8d, $4b
	db $95, $4b, $3f, $48, $a1, $4b, $c1, $4b, $3f, $48, $3f, $48, $cd, $4b, $95, $4b
	db $e9, $4b, $0d, $4c, $15, $4c, $1d, $4c, $2d, $4c, $39, $4c, $41, $4c, $4d, $4c
	db $3f, $48, $3f, $48, $3f, $48, $5d, $4c, $69, $4c, $7d, $4c, $91, $4c, $a5, $4c
	db $b5, $4c, $c9, $4c, $dd, $4c, $f1, $4c, $fd, $4c, $11, $4d, $25, $4d, $39, $4d
	db $6d, $4d, $79, $4d, $85, $4d, $91, $4d, $9d, $4d, $a9, $4d, $b5, $4d, $c1, $4d
	db $cd, $4d, $d9, $4d, $e5, $4d, $f1, $4d, $fd, $4d, $0d, $4e, $19, $4e, $25, $4e
	db $31, $4e, $39, $4e, $4d, $4e, $85, $4e, $91, $4e, $9d, $4e, $ad, $4e, $b9, $4e
	db $c9, $4e, $d5, $4e, $e1, $4e, $ed, $4e, $f9, $4e, $05, $4f, $11, $4f, $31, $4f
	db $3d, $4f, $45, $4f, $4d, $4f, $55, $4f, $7d, $4f, $db, $4f, $39, $50, $97, $50
	db $f5, $50, $53, $51, $b1, $51, $b9, $51, $c1, $51, $c9, $51, $e1, $51, $3d, $4f
	db $4f, $4e, $57, $4f, $59, $4f, $5b, $4f, $5d, $4f, $4f, $4e, $4f, $4e, $4f, $4e
	db $4f, $48, $61, $48, $ff, $ff, $ff, $ff, $ff, $ff, $87, $48, $ff, $ff, $ff, $ff
	db $2a, $d9, $00, $3c, $5d, $56, $01, $3c, $5d, $56, $02, $3c, $5d, $56, $03, $3c
	db $5d, $56, $2b, $d9, $04, $3c, $5d, $56, $05, $3c, $5d, $56, $05, $3c, $5d, $56
	db $05, $3c, $5d, $56, $05, $3c, $5d, $56, $05, $3c, $5d, $56, $04, $3c, $5d, $56
	db $04, $3c, $5d, $56, $04, $3c, $5d, $56, $2c, $d9, $06, $3c, $5d, $56, $06, $3c
	db $5d, $56, $06, $3c, $5d, $56, $06, $3c, $5d, $56, $06, $3c, $5d, $56, $bd, $48
	db $d3, $48, $ff, $ff, $ff, $ff, $d9, $48, $eb, $48, $ff, $ff, $ff, $ff, $f1, $48
	db $ff, $48, $ff, $ff, $ff, $ff, $05, $49, $17, $49, $ff, $ff, $ff, $ff, $2d, $d9
	db $07, $3c, $7d, $56, $07, $3c, $7d, $56, $07, $3c, $7d, $56, $07, $3c, $7d, $56
	db $07, $3c, $7d, $56, $2e, $d9, $08, $3c, $7d, $56, $2f, $d9, $09, $3c, $7d, $56
	db $09, $3c, $7d, $56, $09, $3c, $7d, $56, $09, $3c, $7d, $56, $30, $d9, $0a, $3c
	db $7d, $56, $31, $d9, $0b, $3c, $7d, $56, $0b, $3c, $7d, $56, $0b, $3c, $7d, $56
	db $32, $d9, $0c, $3c, $7d, $56, $33, $d9, $0d, $3c, $7d, $56, $0d, $3c, $7d, $56
	db $0e, $3c, $7d, $56, $0e, $3c, $7d, $56, $34, $d9, $0f, $3c, $7d, $56, $10, $3c
	db $7d, $56, $11, $3c, $7d, $56, $35, $49, $3f, $49, $4d, $49, $ff, $ff, $5b, $49
	db $69, $49, $77, $49, $ff, $ff, $35, $d9, $12, $3c, $9d, $56, $12, $3c, $9d, $56
	db $36, $d9, $13, $3c, $9d, $56, $13, $3c, $9d, $56, $13, $3c, $9d, $56, $37, $d9
	db $14, $3c, $9d, $56, $15, $3c, $9d, $56, $15, $3c, $9d, $56, $38, $d9, $16, $3c
	db $9d, $56, $17, $3c, $9d, $56, $16, $3c, $9d, $56, $39, $d9, $18, $3c, $9d, $56
	db $19, $3c, $9d, $56, $19, $3c, $9d, $56, $3a, $d9, $1a, $3c, $9d, $56, $1b, $3c
	db $9d, $56, $1b, $3c, $9d, $56, $1c, $3c, $9d, $56, $1c, $3c, $9d, $56, $1d, $3c
	db $9d, $56, $1d, $3c, $9d, $56, $1d, $3c, $9d, $56, $1d, $3c, $9d, $56, $ad, $49
	db $bf, $49, $ff, $ff, $ff, $ff, $d5, $49, $eb, $49, $ff, $ff, $ff, $ff, $3b, $d9
	db $1e, $3c, $bd, $56, $1f, $3c, $bd, $56, $20, $3c, $bd, $56, $21, $3c, $bd, $56
	db $3c, $d9, $22, $3c, $bd, $56, $23, $3c, $bd, $56, $23, $3c, $bd, $56, $24, $3c
	db $bd, $56, $25, $3c, $bd, $56, $3d, $d9, $26, $3c, $bd, $56, $27, $3c, $bd, $56
	db $28, $3c, $bd, $56, $29, $3c, $bd, $56, $29, $3c, $bd, $56, $3e, $d9, $2a, $3c
	db $bd, $56, $2b, $3c, $bd, $56, $05, $4a, $17, $4a, $25, $4a, $ff, $ff, $3b, $4a
	db $4d, $4a, $5b, $4a, $ff, $ff, $3f, $d9, $2c, $3c, $dd, $56, $2c, $3c, $dd, $56
	db $2c, $3c, $dd, $56, $2c, $3c, $dd, $56, $40, $d9, $2d, $3c, $dd, $56, $2d, $3c
	db $dd, $56, $2d, $3c, $dd, $56, $41, $d9, $2e, $3c, $dd, $56, $2e, $3c, $dd, $56
	db $2f, $3c, $dd, $56, $2f, $3c, $dd, $56, $2f, $3c, $dd, $56, $42, $d9, $30, $3c
	db $dd, $56, $30, $3c, $dd, $56, $30, $3c, $dd, $56, $30, $3c, $dd, $56, $43, $d9
	db $31, $3c, $dd, $56, $31, $3c, $dd, $56, $31, $3c, $dd, $56, $44, $d9, $32, $3c
	db $dd, $56, $32, $3c, $dd, $56, $32, $3c, $dd, $56, $32, $3c, $dd, $56, $73, $4a
	db $7d, $4a, $87, $4a, $45, $d9, $33, $3c, $fd, $56, $34, $3c, $fd, $56, $46, $d9
	db $35, $3c, $fd, $56, $35, $3c, $fd, $56, $47, $d9, $36, $3c, $fd, $56, $36, $3c
	db $fd, $56, $36, $3c, $fd, $56, $36, $3c, $fd, $56, $a1, $4a, $a7, $4a, $ad, $4a
	db $ff, $ff, $48, $d9, $37, $3c, $1d, $57, $49, $d9, $38, $3c, $1d, $57, $4a, $d9
	db $39, $3c, $1d, $57, $c3, $4a, $c9, $4a, $eb, $4a, $ff, $ff, $f1, $4a, $fb, $4a
	db $01, $4b, $ff, $ff, $4b, $d9, $3a, $3c, $3d, $57, $4c, $d9, $3b, $3c, $3d, $57
	db $3c, $3c, $3d, $57, $3d, $3c, $3d, $57, $3d, $3c, $3d, $57, $3e, $3c, $3d, $57
	db $3e, $3c, $3d, $57, $3e, $3c, $3d, $57, $3e, $3c, $3d, $57, $4d, $d9, $3f, $3c
	db $3d, $57, $4e, $d9, $40, $3c, $3d, $57, $40, $3c, $3d, $57, $4f, $d9, $41, $3c
	db $3d, $57, $50, $d9, $42, $3c, $3d, $57, $09, $4b, $51, $d9, $43, $3c, $5d, $57
	db $43, $3c, $5d, $57, $43, $3c, $5d, $57, $43, $3c, $5d, $57, $43, $3c, $5d, $57
	db $43, $3c, $5d, $57, $43, $3c, $5d, $57, $43, $3c, $5d, $57, $43, $3c, $5d, $57
	db $ff, $ff, $3f, $4b, $ff, $ff, $ff, $ff, $4d, $4b, $5b, $4b, $ff, $ff, $ff, $ff
	db $52, $d9, $44, $3c, $7d, $57, $44, $3c, $7d, $57, $44, $3c, $7d, $57, $53, $d9
	db $45, $3c, $7d, $57, $45, $3c, $7d, $57, $45, $3c, $7d, $57, $54, $d9, $46, $3c
	db $7d, $57, $46, $3c, $7d, $57, $6d, $4b, $73, $4b, $ff, $ff, $ff, $ff, $55, $d9
	db $47, $3c, $9d, $57, $56, $d9, $48, $3c, $9d, $57, $7b, $4b, $57, $d9, $49, $3c
	db $bd, $57, $83, $4b, $58, $d9, $4a, $3c, $dd, $57, $4a, $3c, $dd, $57, $8f, $4b
	db $59, $d9, $4b, $3c, $fd, $57, $97, $4b, $5a, $d9, $4c, $3c, $1d, $58, $4d, $3c
	db $1d, $58, $b1, $4b, $ff, $ff, $ff, $ff, $ff, $ff, $b7, $4b, $ff, $ff, $ff, $ff
	db $ff, $ff, $5b, $d9, $4e, $3c, $3d, $58, $5c, $d9, $4f, $3c, $3d, $58, $4f, $3c
	db $3d, $58, $c3, $4b, $5d, $d9, $50, $3c, $3d, $58, $50, $3c, $3d, $58, $cf, $4b
	db $5e, $d9, $51, $3c, $5d, $58, $52, $3c, $5d, $58, $52, $3c, $5d, $58, $51, $3c
	db $5d, $58, $52, $3c, $5d, $58, $52, $3c, $5d, $58, $f9, $4b, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $4b, $ff, $ff, $ff, $ff, $ff, $ff, $5f, $d9, $53, $3c, $7d, $58
	db $60, $d9, $54, $3c, $7d, $58, $55, $3c, $7d, $58, $55, $3c, $7d, $58, $0f, $4c
	db $61, $d9, $56, $3c, $9d, $58, $17, $4c, $62, $d9, $57, $3c, $bd, $58, $1f, $4c
	db $63, $d9, $58, $3c, $dd, $58, $58, $3c, $dd, $58, $58, $3c, $dd, $58, $2f, $4c
	db $64, $d9, $59, $3c, $fd, $58, $59, $3c, $fd, $58, $3b, $4c, $65, $d9, $5a, $3c
	db $1d, $59, $43, $4c, $66, $d9, $5b, $3c, $1d, $59, $5b, $3c, $1d, $59, $4f, $4c
	db $67, $d9, $5c, $3c, $3d, $59, $5c, $3c, $3d, $59, $5c, $3c, $3d, $59, $5f, $4c
	db $68, $d9, $5d, $3c, $5d, $59, $5d, $3c, $5d, $59, $6b, $4c, $69, $d9, $5e, $3c
	db $7d, $59, $5e, $3c, $7d, $59, $5e, $3c, $7d, $59, $5e, $3c, $7d, $59, $7f, $4c
	db $6a, $d9, $5f, $3c, $9d, $59, $5f, $3c, $9d, $59, $5f, $3c, $9d, $59, $5f, $3c
	db $9d, $59, $93, $4c, $6b, $d9, $60, $3c, $bd, $59, $60, $3c, $bd, $59, $60, $3c
	db $bd, $59, $60, $3c, $bd, $59, $a7, $4c, $6c, $d9, $61, $3c, $dd, $59, $61, $3c
	db $dd, $59, $61, $3c, $dd, $59, $b7, $4c, $6d, $d9, $62, $3c, $fd, $59, $62, $3c
	db $fd, $59, $62, $3c, $fd, $59, $62, $3c, $fd, $59, $cb, $4c, $6e, $d9, $63, $3c
	db $1d, $5a, $63, $3c, $1d, $5a, $63, $3c, $1d, $5a, $63, $3c, $1d, $5a, $df, $4c
	db $6f, $d9, $64, $3c, $3d, $5a, $64, $3c, $3d, $5a, $64, $3c, $3d, $5a, $64, $3c
	db $3d, $5a, $f3, $4c, $70, $d9, $65, $3c, $5d, $5a, $65, $3c, $5d, $5a, $ff, $4c
	db $71, $d9, $66, $3c, $7d, $5a, $66, $3c, $7d, $5a, $66, $3c, $7d, $5a, $66, $3c
	db $7d, $5a, $13, $4d, $72, $d9, $67, $3c, $9d, $5a, $67, $3c, $9d, $5a, $67, $3c
	db $9d, $5a, $67, $3c, $9d, $5a, $27, $4d, $73, $d9, $68, $3c, $bd, $5a, $68, $3c
	db $bd, $5a, $68, $3c, $bd, $5a, $68, $3c, $bd, $5a, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $45, $4d, $63, $4d, $74, $d9, $69, $3c, $dd, $5a, $69, $3c, $dd, $5a
	db $69, $3c, $dd, $5a, $69, $3c, $dd, $5a, $69, $3c, $dd, $5a, $69, $3c, $dd, $5a
	db $69, $3c, $dd, $5a, $75, $d9, $6a, $3c, $dd, $5a, $6a, $3c, $dd, $5a, $6f, $4d
	db $76, $d9, $6b, $3c, $fd, $5a, $6c, $3c, $fd, $5a, $7b, $4d, $77, $d9, $6d, $3c
	db $1d, $5b, $6e, $3c, $1d, $5b, $87, $4d, $78, $d9, $6f, $3c, $3d, $5b, $70, $3c
	db $3d, $5b, $93, $4d, $79, $d9, $71, $3c, $5d, $5b, $72, $3c, $5d, $5b, $9f, $4d
	db $7a, $d9, $73, $3c, $7d, $5b, $74, $3c, $7d, $5b, $ab, $4d, $7b, $d9, $75, $3c
	db $9d, $5b, $76, $3c, $9d, $5b, $b7, $4d, $7c, $d9, $77, $3c, $bd, $5b, $78, $3c
	db $bd, $5b, $c3, $4d, $7d, $d9, $79, $3c, $dd, $5b, $7a, $3c, $dd, $5b, $cf, $4d
	db $7e, $d9, $7b, $3c, $fd, $5b, $7c, $3c, $fd, $5b, $db, $4d, $7f, $d9, $7d, $3c
	db $1d, $5c, $7e, $3c, $1d, $5c, $e7, $4d, $80, $d9, $7f, $3c, $3d, $5c, $80, $3c
	db $3d, $5c, $f3, $4d, $81, $d9, $81, $3c, $5d, $5c, $82, $3c, $5d, $5c, $ff, $4d
	db $82, $d9, $83, $3c, $7d, $5c, $85, $3c, $7d, $5c, $84, $3c, $7d, $5c, $0f, $4e
	db $83, $d9, $86, $3c, $9d, $5c, $86, $3c, $9d, $5c, $1b, $4e, $84, $d9, $87, $3c
	db $bd, $5c, $88, $3c, $bd, $5c, $27, $4e, $85, $d9, $89, $3c, $dd, $5c, $8a, $3c
	db $fd, $5c, $33, $4e, $86, $d9, $8b, $3c, $1d, $5d, $3b, $4e, $87, $d9, $8c, $3c
	db $1d, $5d, $8c, $3c, $1d, $5d, $8c, $3c, $1d, $5d, $8d, $3c, $1d, $5d, $51, $4e
	db $7b, $4e, $88, $d9, $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d
	db $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d
	db $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d, $8e, $3c, $3d, $5d, $89, $d9, $8f, $3c
	db $5d, $5d, $8f, $3c, $5d, $5d, $87, $4e, $8a, $d9, $90, $3c, $7d, $5d, $91, $3c
	db $7d, $5d, $93, $4e, $8b, $d9, $92, $3c, $9d, $5d, $93, $3c, $9d, $5d, $9f, $4e
	db $8c, $d9, $94, $3c, $bd, $5d, $95, $3c, $bd, $5d, $94, $3c, $bd, $5d, $af, $4e
	db $8d, $d9, $96, $3c, $dd, $5d, $97, $3c, $dd, $5d, $bb, $4e, $8e, $d9, $98, $3c
	db $fd, $5d, $98, $3c, $fd, $5d, $99, $3c, $fd, $5d, $cb, $4e, $8f, $d9, $9a, $3c
	db $1d, $5e, $9b, $3c, $1d, $5e, $d7, $4e, $90, $d9, $9c, $3c, $3d, $5e, $9d, $3c
	db $3d, $5e, $e3, $4e, $91, $d9, $9e, $3c, $5d, $5e, $9f, $3c, $5d, $5e, $ef, $4e
	db $92, $d9, $a0, $3c, $7d, $5e, $a1, $3c, $7d, $5e, $fb, $4e, $93, $d9, $a2, $3c
	db $9d, $5e, $a3, $3c, $9d, $5e, $07, $4f, $94, $d9, $a4, $3c, $bd, $5e, $a5, $3c
	db $bd, $5e, $21, $4f, $ff, $ff, $ff, $ff, $ff, $ff, $2b, $4f, $ff, $ff, $ff, $ff
	db $ff, $ff, $95, $d9, $a6, $3c, $dd, $5e, $a7, $3c, $dd, $5e, $96, $d9, $a8, $3c
	db $dd, $5e, $33, $4f, $97, $d9, $a9, $3c, $fd, $5e, $aa, $3c, $fd, $5e, $3f, $4f
	db $98, $d9, $ab, $3c, $1d, $5f, $47, $4f, $98, $d9, $ac, $3c, $3d, $5f, $4f, $4f
	db $98, $d9, $ad, $3c, $5d, $5f, $5f, $4f, $65, $4f, $6b, $4f, $71, $4f, $77, $4f
	db $98, $d9, $ae, $3c, $7d, $5f, $98, $d9, $af, $3c, $7d, $5f, $98, $d9, $b0, $3c
	db $7d, $5f, $98, $d9, $b1, $3c, $7d, $5f, $98, $d9, $b2, $3c, $7d, $5f, $95, $4f
	db $9b, $4f, $a1, $4f, $ff, $ff, $a7, $4f, $ad, $4f, $b3, $4f, $ff, $ff, $b9, $4f
	db $bf, $4f, $c5, $4f, $ff, $ff, $98, $d9, $b3, $3c, $9d, $5f, $98, $d9, $b4, $3c
	db $9d, $5f, $98, $d9, $b5, $3c, $9d, $5f, $98, $d9, $b6, $3c, $9d, $5f, $98, $d9
	db $b7, $3c, $9d, $5f, $98, $d9, $b8, $3c, $9d, $5f, $98, $d9, $b9, $3c, $9d, $5f
	db $98, $d9, $ba, $3c, $9d, $5f, $98, $d9, $bb, $3c, $9d, $5f, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $08, $02, $00, $80, $00, $00, $00, $ff, $f3, $4f, $f9, $4f
	db $ff, $4f, $ff, $ff, $05, $50, $0b, $50, $11, $50, $ff, $ff, $17, $50, $1d, $50
	db $23, $50, $ff, $ff, $98, $d9, $bc, $3c, $bd, $5f, $98, $d9, $bd, $3c, $bd, $5f
	db $98, $d9, $be, $3c, $bd, $5f, $98, $d9, $bf, $3c, $bd, $5f, $98, $d9, $c0, $3c
	db $bd, $5f, $98, $d9, $c1, $3c, $bd, $5f, $98, $d9, $c2, $3c, $bd, $5f, $98, $d9
	db $c3, $3c, $bd, $5f, $98, $d9, $c4, $3c, $bd, $5f, $ff, $ff, $ff, $ff, $ff, $ff
	db $06, $06, $00, $80, $00, $00, $00, $ff, $ff, $ff, $51, $50, $57, $50, $5d, $50
	db $ff, $ff, $63, $50, $69, $50, $6f, $50, $ff, $ff, $75, $50, $7b, $50, $81, $50
	db $ff, $ff, $98, $d9, $c5, $3c, $dd, $5f, $98, $d9, $c6, $3c, $dd, $5f, $98, $d9
	db $c7, $3c, $dd, $5f, $98, $d9, $c8, $3c, $dd, $5f, $98, $d9, $c9, $3c, $dd, $5f
	db $98, $d9, $ca, $3c, $dd, $5f, $98, $d9, $cb, $3c, $dd, $5f, $98, $d9, $cc, $3c
	db $dd, $5f, $98, $d9, $cd, $3c, $dd, $5f, $ff, $ff, $03, $03, $00, $80, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $af, $50, $b5, $50, $bb, $50, $ff, $ff
	db $c1, $50, $c7, $50, $cd, $50, $ff, $ff, $d3, $50, $d9, $50, $df, $50, $ff, $ff
	db $98, $d9, $ce, $3c, $fd, $5f, $98, $d9, $cf, $3c, $fd, $5f, $98, $d9, $d0, $3c
	db $fd, $5f, $98, $d9, $d1, $3c, $fd, $5f, $98, $d9, $d2, $3c, $fd, $5f, $98, $d9
	db $d3, $3c, $fd, $5f, $98, $d9, $d4, $3c, $fd, $5f, $98, $d9, $d5, $3c, $fd, $5f
	db $98, $d9, $d6, $3c, $fd, $5f, $ff, $ff, $ff, $ff, $ff, $ff, $01, $06, $00, $80
	db $00, $00, $00, $ff, $ff, $ff, $0d, $51, $13, $51, $19, $51, $ff, $ff, $1f, $51
	db $25, $51, $2b, $51, $ff, $ff, $31, $51, $37, $51, $3d, $51, $ff, $ff, $98, $d9
	db $d7, $3c, $1d, $60, $98, $d9, $d8, $3c, $1d, $60, $98, $d9, $d9, $3c, $1d, $60
	db $98, $d9, $da, $3c, $1d, $60, $98, $d9, $db, $3c, $1d, $60, $98, $d9, $dc, $3c
	db $1d, $60, $98, $d9, $dd, $3c, $1d, $60, $98, $d9, $de, $3c, $1d, $60, $98, $d9
	db $df, $3c, $1d, $60, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $03, $06, $00, $80, $00
	db $00, $00, $ff, $ff, $6b, $51, $71, $51, $77, $51, $ff, $ff, $7d, $51, $83, $51
	db $89, $51, $ff, $ff, $8f, $51, $95, $51, $9b, $51, $ff, $ff, $98, $d9, $e0, $3c
	db $3d, $60, $98, $d9, $e1, $3c, $3d, $60, $98, $d9, $e2, $3c, $3d, $60, $98, $d9
	db $e3, $3c, $3d, $60, $98, $d9, $e4, $3c, $3d, $60, $98, $d9, $e5, $3c, $3d, $60
	db $98, $d9, $e6, $3c, $3d, $60, $98, $d9, $e7, $3c, $3d, $60, $98, $d9, $e8, $3c
	db $3d, $60, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $08, $06, $00, $80, $00, $00
	db $00, $ff, $b3, $51, $98, $d9, $e9, $3c, $5d, $60, $bb, $51, $98, $d9, $ea, $3c
	db $7d, $60, $c3, $51, $98, $d9, $eb, $3c, $9d, $60, $cb, $51, $99, $d9, $ec, $3c
	db $bd, $60, $ed, $3c, $bd, $60, $ed, $3c, $bd, $60, $ed, $3c, $bd, $60, $ed, $3c
	db $bd, $60, $e3, $51, $9a, $d9, $ee, $3c, $dd, $60, $ee, $3c, $dd, $60, $ee, $3c
	db $dd, $60, $ee, $3c, $dd, $60

;@ path: gfx/palettes
;@ The background palettes 0-3 of the gate floors: one pointer per map number (16 maps) to
;@ 4 palettes of 8 bytes.
GatePaletteTable::
	db $fd, $60, $1d, $61, $3d, $61, $5d, $61, $7d, $61
	db $9d, $61, $bd, $61, $dd, $61, $fd, $61, $1d, $62, $3d, $62, $5d, $62, $7d, $62
	db $9d, $62, $bd, $62, $dd, $62

;@ path: gfx/palettes
;@ Attribute maps of the gate floor screens, by the screen's layout byte (wFloorLayout): one
;@ compressed block each (entry and bank for Decompress).
GateAttrMaps1::
	db $00, $3d, $01, $3d, $02, $3d, $03, $3d, $04, $3d
	db $05, $3d, $06, $3d, $07, $3d, $08, $3d, $09, $3d, $0a, $3d, $0b, $3d, $b5, $3d
	db $00, $3d, $00, $3d, $00, $3d, $0c, $3d, $0d, $3d, $0e, $3d, $0f, $3d, $10, $3d
	db $11, $3d, $12, $3d, $13, $3d, $14, $3d, $15, $3d, $16, $3d, $17, $3d, $b6, $3d
	db $00, $3d, $00, $3d, $00, $3d, $18, $3d, $19, $3d, $1a, $3d, $1b, $3d, $1c, $3d
	db $1d, $3d, $1e, $3d, $1f, $3d, $20, $3d, $21, $3d, $22, $3d, $23, $3d, $b7, $3d
	db $00, $3d, $00, $3d, $00, $3d, $24, $3d, $25, $3d, $26, $3d, $27, $3d, $28, $3d
	db $29, $3d, $2a, $3d, $2b, $3d, $2c, $3d, $2d, $3d, $2e, $3d, $2f, $3d, $b8, $3d
	db $00, $3d, $00, $3d, $00, $3d, $30, $3d, $31, $3d, $32, $3d, $33, $3d, $34, $3d
	db $35, $3d, $36, $3d, $37, $3d, $38, $3d, $39, $3d, $3a, $3d, $3b, $3d, $b9, $3d
	db $00, $3d, $00, $3d, $00, $3d, $3c, $3d, $3d, $3d, $3e, $3d, $3f, $3d, $40, $3d
	db $41, $3d, $42, $3d, $43, $3d, $44, $3d, $45, $3d, $46, $3d, $47, $3d, $ba, $3d
	db $00, $3d, $00, $3d, $00, $3d, $48, $3d, $49, $3d, $4a, $3d, $4b, $3d, $4c, $3d
	db $4d, $3d, $4e, $3d, $4f, $3d, $50, $3d, $51, $3d, $52, $3d, $53, $3d, $bb, $3d
	db $00, $3d, $00, $3d, $00, $3d, $54, $3d, $55, $3d, $56, $3d, $57, $3d, $58, $3d
	db $59, $3d, $5a, $3d, $5b, $3d, $5c, $3d, $5d, $3d, $5e, $3d, $5f, $3d, $bc, $3d
	db $00, $3d, $00, $3d, $00, $3d, $60, $3d, $61, $3d, $62, $3d, $63, $3d, $64, $3d
	db $65, $3d, $66, $3d, $67, $3d, $68, $3d, $69, $3d, $6a, $3d, $6b, $3d, $bd, $3d
	db $00, $3d, $00, $3d, $00, $3d, $6c, $3d, $6d, $3d, $6e, $3d, $6f, $3d, $70, $3d
	db $71, $3d, $72, $3d, $73, $3d, $74, $3d, $75, $3d, $76, $3d, $77, $3d, $be, $3d
	db $00, $3d, $00, $3d, $00, $3d, $78, $3d, $79, $3d, $7a, $3d, $7b, $3d, $7c, $3d
	db $7d, $3d, $7e, $3d, $7f, $3d, $80, $3d, $81, $3d, $82, $3d, $83, $3d, $bf, $3d
	db $00, $3d, $00, $3d, $00, $3d, $84, $3d, $85, $3d, $86, $3d, $87, $3d, $88, $3d
	db $89, $3d, $8a, $3d, $8b, $3d, $8c, $3d, $8d, $3d, $8e, $3d, $8f, $3d, $c0, $3d
	db $00, $3d, $00, $3d, $00, $3d, $90, $3d, $91, $3d, $92, $3d, $93, $3d, $94, $3d
	db $95, $3d, $96, $3d, $97, $3d, $98, $3d, $99, $3d, $9a, $3d, $9b, $3d, $c1, $3d
	db $00, $3d, $00, $3d, $00, $3d, $9c, $3d, $9d, $3d, $9e, $3d, $9f, $3d, $a0, $3d
	db $a1, $3d, $a2, $3d, $a3, $3d, $a4, $3d, $a5, $3d, $a6, $3d, $a7, $3d, $c2, $3d
	db $00, $3d, $00, $3d, $00, $3d, $a8, $3d, $a9, $3d, $aa, $3d, $ab, $3d, $ac, $3d
	db $ad, $3d, $ae, $3d, $af, $3d, $b0, $3d, $b1, $3d, $b2, $3d, $b3, $3d, $c3, $3d
	db $00, $3d, $00, $3d, $00, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d
	db $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d
	db $b4, $3d, $b4, $3d, $b4, $3d

;@ path: gfx/palettes
;@ The same for the floors where the byte at $C93F is 2.
GateAttrMaps2::
	db $00, $3e, $01, $3e, $02, $3e, $03, $3e, $04, $3e
	db $05, $3e, $06, $3e, $07, $3e, $08, $3e, $09, $3e, $0a, $3e, $0b, $3e, $0c, $3e
	db $0d, $3e, $00, $3e, $00, $3e, $0e, $3e, $0f, $3e, $10, $3e, $11, $3e, $12, $3e
	db $13, $3e, $14, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $15, $3e, $16, $3e, $17, $3e, $18, $3e, $19, $3e
	db $1a, $3e, $1b, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $1c, $3e, $1d, $3e, $1e, $3e, $1f, $3e, $20, $3e
	db $21, $3e, $22, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $23, $3e, $24, $3e, $25, $3e, $26, $3e, $27, $3e
	db $28, $3e, $29, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $2a, $3e, $2b, $3e, $2c, $3e, $2d, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $2e, $3e, $2f, $3e, $30, $3e, $31, $3e, $32, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $33, $3e, $34, $3e, $35, $3e, $36, $3e, $37, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $38, $3e, $39, $3e, $3a, $3e, $3b, $3e, $3c, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $3d, $3e, $3e, $3e, $3f, $3e, $40, $3e, $41, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $42, $3e, $43, $3e, $44, $3e, $45, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $46, $3e, $47, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $48, $3e, $49, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $4a, $3e, $4b, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $4c, $3e, $4d, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e, $00, $3e
	db $00, $3e, $00, $3e, $00, $3e, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d
	db $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d, $b4, $3d
	db $b4, $3d, $b4, $3d, $b4, $3d

;@ path: gfx/palettes
;@ The eight sprite palettes of the field (8 bytes each, 4 colors of 15 bits).
FieldObjPalettes::
	db $ad, $35, $7f, $4b, $9f, $00, $42, $00, $ad, $35
	db $7f, $4b, $20, $17, $42, $00, $00, $7c, $7f, $4b, $ab, $7d, $42, $00, $00, $7c
	db $7f, $4b, $ff, $02, $42, $00, $b9, $36, $7f, $4b, $b6, $58, $42, $00, $00, $7c
	db $7f, $4b, $0f, $42, $42, $00, $00, $7c, $7f, $4b, $1f, $02, $42, $00, $00, $7c
	db $7f, $4b, $18, $22, $42, $00

;@ path: gfx/palettes
;@ Background palette 7 of the field, the colors of the text box (SetSharedBGColors copies its
;@ colors 1 and 3 into the other palettes); the map palettes that MapPaletteTable points to
;@ follow it.
FieldBGPalette7::
	db $39, $01, $ff, $6b, $3f, $03, $00, $00, $7c, $08
	db $ff, $6b, $7c, $08, $00, $00, $15, $00, $ff, $6b, $9f, $02, $00, $00, $ae, $29
	db $ff, $6b, $d6, $4a, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $70, $01
	db $ff, $6b, $37, $1a, $00, $00, $20, $17, $ff, $6b, $f0, $03, $00, $00, $20, $17
	db $ff, $6b, $37, $1a, $00, $00, $20, $17, $ff, $6b, $42, $7f, $00, $00, $20, $17
	db $ff, $6b, $f0, $03, $00, $00, $20, $17, $ff, $6b, $42, $7f, $00, $00, $15, $00
	db $ff, $6b, $9f, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $ac, $39
	db $ff, $6b, $70, $22, $00, $00, $ac, $39, $ff, $6b, $70, $22, $00, $00, $09, $15
	db $ff, $6b, $70, $22, $00, $00, $2c, $19, $ff, $6b, $b2, $19, $00, $00, $20, $17
	db $ff, $6b, $f0, $03, $00, $00, $30, $01, $ff, $6b, $f4, $11, $00, $00, $51, $00
	db $ff, $6b, $75, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $cb, $01
	db $57, $37, $ad, $1e, $80, $00, $30, $01, $57, $37, $f4, $11, $42, $00, $85, $49
	db $57, $37, $ad, $3e, $44, $00, $20, $1e, $36, $1f, $ec, $02, $80, $00, $d0, $19
	db $ff, $6b, $3d, $43, $00, $00, $32, $05, $ff, $6b, $9f, $02, $00, $00, $32, $05
	db $ff, $6b, $99, $2e, $00, $00, $32, $05, $ff, $6b, $99, $2e, $00, $00, $32, $05
	db $ff, $6b, $99, $2e, $00, $00, $6d, $4d, $ff, $6b, $99, $2e, $00, $00, $32, $05
	db $ff, $6b, $99, $2e, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $ed, $04
	db $ff, $6b, $1a, $1a, $00, $00, $15, $20, $ff, $6b, $1f, $20, $00, $00, $42, $7d
	db $ff, $6b, $75, $7e, $00, $00, $2e, $15, $ff, $6b, $3a, $2e, $00, $00, $0b, $7c
	db $ff, $6b, $12, $7f, $00, $00, $ce, $39, $ff, $6b, $51, $3a, $00, $00, $20, $17
	db $ff, $6b, $f0, $03, $00, $00, $15, $00, $ff, $6b, $9f, $02, $00, $00, $ae, $29
	db $ff, $6b, $d6, $4a, $00, $00, $15, $00, $ff, $6b, $7c, $08, $00, $00, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $20, $06, $ff, $6b, $3a, $02, $00, $00, $20, $17
	db $ff, $6b, $9f, $03, $00, $00, $18, $24, $ff, $6b, $5c, $41, $00, $00, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $ed, $04, $ff, $6b, $3a, $02, $00, $00, $0f, $7c
	db $ff, $6b, $42, $7f, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $f2, $04, $ff, $6b, $da, $3a, $00, $00, $2c, $19
	db $ff, $6b, $cf, $31, $00, $00, $15, $00, $ff, $6b, $ff, $02, $00, $00, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $ed, $04, $ff, $6b, $3a, $02, $00, $00, $20, $17
	db $ff, $6b, $9f, $03, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $18, $00, $ff, $6b, $3a, $02, $00, $00, $20, $06
	db $ff, $6b, $3a, $02, $42, $00, $00, $7d, $ff, $6b, $42, $7f, $42, $00, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $ec, $04, $ff, $6b, $3a, $02, $00, $00, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $86, $01
	db $f0, $42, $0c, $22, $80, $00, $ec, $04, $fd, $2a, $f6, $01, $42, $00, $ea, $04
	db $b8, $3a, $ce, $39, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $32, $05
	db $ff, $6b, $99, $2e, $00, $00, $f1, $04, $ff, $6b, $9f, $02, $00, $00, $00, $7d
	db $ff, $6b, $42, $7f, $00, $00, $17, $14, $ff, $6b, $99, $2e, $00, $00, $32, $05
	db $ff, $6b, $99, $2e, $00, $00, $f1, $04, $ff, $6b, $9f, $02, $00, $00, $00, $7d
	db $ff, $6b, $42, $7f, $00, $00, $17, $14, $ff, $6b, $99, $2e, $00, $00, $20, $17
	db $ff, $6b, $f0, $03, $00, $00, $15, $00, $ff, $6b, $9a, $01, $00, $00, $00, $7d
	db $ff, $6b, $42, $7f, $00, $00, $15, $00, $ff, $6b, $9a, $01, $00, $00, $20, $17
	db $ff, $6b, $f0, $03, $00, $00, $00, $7d, $ff, $6b, $15, $1a, $00, $00, $6b, $2d
	db $ff, $6b, $7c, $08, $00, $00, $ed, $04, $ff, $6b, $3a, $02, $00, $00, $ed, $04
	db $ff, $6b, $15, $1a, $00, $00, $e9, $5c, $ff, $6b, $2b, $7e, $00, $00, $20, $02
	db $ff, $6b, $ff, $7f, $42, $00, $ec, $04, $ff, $6b, $f6, $01, $42, $00, $0c, $7c
	db $ff, $6b, $ab, $7e, $00, $00, $12, $18, $ff, $6b, $ba, $34, $00, $00, $20, $17
	db $ff, $6b, $9f, $03, $00, $00, $70, $01, $ff, $6b, $37, $1a, $00, $00, $ac, $39
	db $ff, $6b, $d6, $4a, $00, $00, $6a, $25, $ff, $6b, $f0, $42, $00, $00, $9f, $02
	db $ff, $6b, $7c, $08, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $ac, $39
	db $ff, $6b, $d6, $4a, $42, $00, $ae, $29, $30, $22, $d6, $4a, $42, $00, $ea, $04
	db $90, $42, $c9, $31, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ac, $39
	db $ff, $6b, $d6, $4a, $42, $00, $6a, $25, $90, $42, $c9, $31, $42, $00, $ea, $04
	db $1f, $13, $79, $1a, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ac, $39
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $78, $04
	db $9f, $03, $76, $36, $85, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $6a, $25, $90, $42, $c9, $31, $42, $00, $ea, $04
	db $3d, $43, $36, $1a, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ac, $39
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $ea, $04
	db $1f, $13, $79, $1a, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $78, $04
	db $9f, $03, $76, $36, $85, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $78, $04
	db $9f, $03, $76, $36, $85, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $ea, $04
	db $1f, $13, $79, $1a, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $78, $04
	db $9f, $03, $76, $36, $85, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $ea, $04, $90, $42, $c9, $31, $42, $00, $ea, $04
	db $1f, $13, $79, $1a, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ae, $29
	db $ff, $6b, $d6, $4a, $42, $00, $78, $04, $9f, $03, $76, $36, $85, $00, $ea, $04
	db $1f, $13, $79, $1a, $42, $00, $00, $7d, $f7, $7f, $42, $7f, $e3, $48, $ee, $64
	db $ff, $6b, $33, $7e, $00, $00, $7f, $00, $ff, $6b, $1f, $02, $00, $00, $20, $07
	db $ff, $6b, $33, $7e, $00, $00, $2f, $09, $ff, $6b, $57, $1a, $00, $00, $69, $05
	db $ff, $6b, $51, $02, $00, $00, $07, $15, $ff, $6b, $2d, $32, $00, $00, $50, $00
	db $ff, $6b, $9f, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $d0, $00
	db $ff, $6b, $12, $22, $00, $00, $4a, $1d, $ff, $6b, $94, $3e, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $23, $02
	db $ff, $6b, $ee, $03, $00, $00, $69, $41, $ff, $6b, $b3, $5e, $00, $00, $13, $4d
	db $ff, $6b, $5d, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $e8, $00
	db $ff, $6b, $bb, $16, $00, $00, $0a, $09, $ff, $6b, $57, $0e, $00, $00, $e8, $00
	db $ff, $6b, $10, $1a, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $49, $02
	db $ff, $6b, $ee, $03, $00, $00, $6f, $05, $ff, $6b, $bb, $02, $00, $00, $cd, $00
	db $ff, $6b, $34, $12, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $2b, $02
	db $ff, $6b, $ee, $03, $00, $00, $0e, $05, $ff, $6b, $ba, $16, $00, $00, $13, $4d
	db $ff, $6b, $5d, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $32, $1c
	db $ff, $6b, $bf, $4d, $00, $00, $32, $1c, $ff, $6b, $18, $46, $00, $00, $52, $00
	db $ff, $6b, $7f, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $0a, $51
	db $ff, $6b, $11, $7f, $00, $00, $2a, $21, $ff, $6b, $74, $46, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $66, $00
	db $ff, $6b, $75, $01, $00, $00, $8c, $19, $ff, $6b, $b5, $3e, $00, $00, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $e5, $30
	db $ff, $6b, $f4, $62, $00, $00, $a5, $28, $ff, $6b, $cd, $41, $00, $00, $50, $00
	db $ff, $6b, $9f, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $2a, $15
	db $ff, $6b, $b7, $2a, $00, $00, $05, $19, $ff, $6b, $a9, $35, $00, $00, $53, $0d
	db $ff, $6b, $1a, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $06, $35
	db $ff, $6b, $91, $7e, $00, $00, $0c, $21, $ff, $6b, $99, $5e, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $4d, $01
	db $ff, $6b, $97, $3a, $00, $00, $68, $01, $ff, $6b, $6d, $0e, $00, $00, $3f, $01
	db $ff, $6b, $d9, $3e, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $49, $02
	db $ff, $6b, $ee, $03, $00, $00, $70, $1d, $00, $7c, $00, $7c, $00, $00, $40, $26
	db $ff, $6b, $e0, $3b, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $0e, $0d
	db $ff, $6b, $7f, $22, $00, $00, $14, $00, $ff, $6b, $9f, $01, $00, $00, $50, $0d
	db $ff, $6b, $fd, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $10, $00
	db $ff, $6b, $df, $05, $00, $00, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $49, $02
	db $00, $7c, $ee, $03, $00, $00, $4f, $11, $ff, $6b, $98, $16, $00, $00, $cc, $21
	db $ff, $6b, $34, $43, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $6d, $14
	db $ff, $6b, $98, $42, $00, $00, $ed, $00, $ff, $6b, $b9, $32, $00, $00, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $13, $01
	db $ff, $6b, $f7, $1d, $00, $00, $15, $02, $ff, $6b, $16, $1b, $00, $00, $50, $00
	db $ff, $6b, $9f, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $13, $01
	db $ff, $6b, $f7, $1d, $00, $00, $15, $02, $ff, $6b, $16, $1b, $00, $00, $50, $00
	db $ff, $6b, $9f, $02, $00, $00, $00, $7d, $ff, $6b, $55, $7d, $00, $00, $c7, $18
	db $ff, $6b, $11, $42, $00, $00, $a7, $34, $ff, $6b, $73, $72, $00, $00, $a7, $34
	db $ff, $6b, $11, $42, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $4b, $25
	db $ff, $6b, $10, $36, $00, $00, $13, $01, $ff, $6b, $10, $36, $00, $00, $df, $01
	db $ff, $6b, $ff, $1a, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $26, $19
	db $ff, $6b, $70, $42, $00, $00, $64, $11, $ff, $6b, $42, $6b, $00, $00, $67, $1d
	db $ff, $6b, $8e, $3a, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $ec, $14, $ff, $6b, $d6, $19, $00, $00, $ec, $14
	db $ff, $6b, $dd, $19, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $89, $08
	db $ff, $6b, $70, $1d, $00, $00, $4c, $01, $ff, $6b, $d6, $1a, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $52, $00
	db $ff, $6b, $3f, $01, $00, $00, $8f, $34, $ff, $6b, $38, $5e, $00, $00, $52, $00
	db $ff, $6b, $9f, $02, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $6b, $24
	db $ff, $6b, $29, $5d, $00, $00, $f2, $34, $ff, $6b, $98, $5e, $00, $00, $f2, $34
	db $ff, $6b, $3f, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $26, $01
	db $ff, $6b, $91, $16, $00, $00, $26, $01, $ff, $6b, $18, $23, $00, $00, $26, $01
	db $ff, $6b, $0e, $2a, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $2a, $01
	db $ff, $6b, $97, $16, $00, $00, $69, $11, $ff, $6b, $52, $2a, $00, $00, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $42, $40
	db $ff, $6b, $87, $61, $00, $00, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $4e, $01
	db $ff, $6b, $35, $2a, $00, $00, $52, $00, $ff, $6b, $3f, $01, $00, $00, $b5, $04
	db $ff, $6b, $fe, $01, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $cd, $25
	db $ff, $6b, $d4, $46, $00, $00, $0b, $11, $ff, $6b, $cf, $21, $00, $00, $49, $09
	db $ff, $6b, $d5, $3e, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $4a, $25
	db $ff, $6b, $30, $4a, $00, $00, $4a, $25, $ff, $6b, $30, $4a, $00, $00, $6b, $21
	db $ff, $6b, $31, $3e, $00, $00, $00, $7d, $ff, $6b, $42, $7f, $00, $00, $50, $01
	db $ff, $6b, $59, $12, $00, $00, $ec, $00, $ff, $6b, $59, $12, $00, $00, $0e, $14
	db $ff, $6b, $7d, $14, $00, $00, $4d, $2c, $ff, $6b, $b8, $3c, $00, $00, $51, $00
	db $ff, $6b, $9c, $1c, $00, $00, $06, $19, $ff, $6b, $50, $46, $00, $00, $2d, $05
	db $ff, $6b, $5b, $02, $00, $00, $23, $05, $ff, $6b, $8f, $02, $00, $00, $6e, $05
	db $ff, $6b, $37, $02, $00, $00, $e6, $18, $ff, $6b, $50, $46, $00, $00, $4c, $28
	db $ff, $6b, $b6, $24, $00, $00, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $a0, $01, $ff, $6b, $a6, $02, $00, $00, $89, $05
	db $ff, $6b, $11, $02, $00, $00, $a0, $01, $ff, $6b, $a6, $02, $00, $00, $29, $65
	db $ff, $6b, $0f, $7f, $00, $00, $6b, $04, $ff, $6b, $77, $0d, $00, $00, $ae, $08
	db $ff, $6b, $76, $0d, $00, $00, $0f, $09, $ff, $6b, $38, $02, $00, $00, $73, $01
	db $ff, $6b, $dd, $02, $00, $00, $c4, $18, $ff, $6b, $4b, $32, $00, $00, $05, $1d
	db $ff, $6b, $0b, $32, $00, $00, $28, $11, $ff, $6b, $ad, $15, $00, $00, $07, $02
	db $ff, $6b, $70, $03, $00, $00, $c6, $0c, $ff, $6b, $10, $1e, $00, $00, $28, $0d
	db $ff, $6b, $ce, $15, $00, $00, $02, $45, $ff, $6b, $c7, $61, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $08, $0d, $ff, $6b, $70, $2e, $00, $00, $28, $0d
	db $ff, $6b, $ed, $21, $00, $00, $e3, $2c, $ff, $6b, $aa, $55, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $c6, $24, $ff, $6b, $0f, $52, $00, $00, $07, $31
	db $ff, $6b, $aa, $41, $00, $00, $ab, $14, $ff, $6b, $74, $1d, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $8b, $14, $ff, $6b, $96, $29, $00, $00, $ad, $14
	db $ff, $6b, $33, $21, $00, $00, $26, $15, $ff, $6b, $2a, $32, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $2d, $1c, $ff, $6b, $f8, $44, $00, $00, $0e, $14
	db $ff, $6b, $7d, $14, $00, $00, $54, $01, $ff, $6b, $1a, $02, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $2d, $1c, $ff, $6b, $f8, $44, $00, $00, $0e, $14
	db $ff, $6b, $7d, $14, $00, $00, $54, $01, $ff, $6b, $1a, $02, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $2d, $1c, $ff, $6b, $f8, $44, $00, $00, $0e, $14
	db $ff, $6b, $7d, $14, $00, $00, $54, $01, $ff, $6b, $1a, $02, $00, $00, $43, $25
	db $ff, $6b, $16, $0c, $00, $00, $ea, $04, $ff, $6b, $ff, $16, $00, $00, $43, $25
	db $ff, $6b, $e5, $62, $00, $00, $ee, $00, $ff, $6b, $18, $02, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $6b, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $eb, $08
	db $ff, $6b, $b4, $11, $00, $00, $c8, $21, $ff, $6b, $f0, $2e, $00, $00, $c8, $21
	db $ff, $6b, $f0, $2e, $00, $00, $eb, $08, $ff, $6b, $b4, $11, $00, $00, $ab, $14
	db $ff, $6b, $35, $29, $00, $00, $07, $2d, $ff, $6b, $0f, $4a, $00, $00, $07, $2d
	db $ff, $6b, $0f, $4a, $00, $00, $ab, $14, $ff, $6b, $35, $29, $00, $00, $ce, $08
	db $ff, $6b, $13, $05, $00, $00, $51, $05, $ff, $6b, $ba, $1a, $00, $00, $51, $05
	db $ff, $6b, $ba, $1a, $00, $00, $ce, $08, $ff, $6b, $13, $05, $00, $00, $14, $00
	db $ff, $6b, $1f, $15, $00, $00, $8f, $08, $ff, $6b, $78, $0d, $00, $00, $8f, $08
	db $ff, $6b, $78, $0d, $00, $00, $90, $14, $ff, $6b, $d4, $1c, $00, $00, $00, $7d
	db $ff, $6b, $20, $7f, $00, $00, $a4, $4c, $ff, $6b, $ea, $7d, $00, $00, $a4, $4c
	db $ff, $6b, $ea, $7d, $00, $00, $00, $7d, $ff, $6b, $20, $7f, $00, $00, $45, $11
	db $ff, $6b, $4a, $2a, $00, $00, $8b, $28, $ff, $6b, $54, $5d, $00, $00, $8b, $28
	db $ff, $6b, $54, $5d, $00, $00, $45, $11, $ff, $6b, $4a, $2a, $00, $00, $05, $7c
	db $ff, $6b, $1f, $7c, $00, $00, $8b, $28, $ff, $6b, $54, $5d, $00, $00, $8b, $28
	db $ff, $6b, $54, $5d, $00, $00, $45, $11, $ff, $6b, $4a, $2a, $00, $00, $e8, $1d
	db $ff, $6b, $6c, $1e, $00, $00, $2c, $01, $ff, $6b, $36, $02, $00, $00, $2c, $01
	db $ff, $6b, $36, $02, $00, $00, $e8, $1d, $ff, $6b, $6c, $1e, $00, $00, $cc, $10
	db $ff, $6b, $32, $1d, $00, $00, $4a, $19, $ff, $6b, $94, $42, $00, $00, $4a, $19
	db $ff, $6b, $94, $42, $00, $00, $cc, $10, $ff, $6b, $32, $1d, $00, $00, $a0, $01
	db $ff, $6b, $a6, $02, $00, $00, $a0, $01, $ff, $6b, $c9, $02, $00, $00, $a0, $01
	db $ff, $6b, $c9, $02, $00, $00, $a0, $01, $ff, $6b, $a6, $02, $00, $00, $c9, $21
	db $ff, $6b, $e8, $56, $00, $00, $2c, $01, $ff, $6b, $36, $02, $00, $00, $2c, $01
	db $ff, $6b, $36, $02, $00, $00, $c9, $21, $ff, $6b, $e8, $56, $00, $00, $ee, $04
	db $ff, $6b, $7a, $02, $00, $00, $ca, $4d, $ff, $6b, $b2, $76, $00, $00, $ca, $4d
	db $ff, $6b, $b2, $76, $00, $00, $c1, $01, $ff, $6b, $cd, $03, $00, $00, $0d, $2c
	db $ff, $6b, $15, $3c, $00, $00, $ca, $4d, $ff, $6b, $b2, $76, $00, $00, $ca, $4d
	db $ff, $6b, $b2, $76, $00, $00, $c1, $01, $ff, $6b, $cd, $03, $00, $00, $ee, $04
	db $ff, $6b, $7a, $02, $00, $00, $40, $7d, $ff, $6b, $81, $7f, $00, $00, $f0, $00
	db $ff, $6b, $1a, $02, $00, $00, $a1, $01, $ff, $6b, $aa, $03, $00, $00, $0d, $2c
	db $ff, $6b, $15, $3c, $00, $00, $40, $7d, $ff, $6b, $81, $7f, $00, $00, $f0, $00
	db $ff, $6b, $1a, $02, $00, $00, $a1, $01, $ff, $6b, $aa, $03, $00, $00, $ee, $04
	db $ff, $6b, $7a, $02, $00, $00, $ca, $4d, $ff, $6b, $b2, $76, $00, $00, $ca, $4d
	db $ff, $6b, $b2, $76, $00, $00, $ee, $04, $ff, $6b, $7a, $02, $00, $00

;@ path: gfx/palettes
;@ One background palette (8 bytes) per monster picture, by wPaletteSet (LoadMonPicPalette).
MonPicPalettes::
	db $bd, $01
	db $ff, $6b, $5f, $03, $00, $00, $bd, $01, $ff, $6b, $5f, $03, $00, $00, $00, $26
	db $ff, $6b, $80, $47, $00, $00, $34, $00, $ff, $6b, $b4, $78, $00, $00, $02, $06
	db $ff, $6b, $90, $03, $00, $00, $00, $7d, $ff, $6b, $40, $1b, $00, $00, $c1, $01
	db $ff, $6b, $6c, $03, $00, $00, $16, $0c, $ff, $6b, $7e, $15, $00, $00, $0f, $5c
	db $ff, $6b, $a0, $7e, $00, $00, $e1, $7c, $ff, $6b, $bf, $02, $00, $00, $20, $46
	db $ff, $6b, $8d, $03, $00, $00, $f0, $00, $ff, $6b, $fa, $05, $00, $00, $e4, $34
	db $ff, $6b, $ee, $39, $00, $00, $15, $24, $ff, $6b, $1f, $61, $00, $00, $bd, $01
	db $ff, $6b, $5f, $03, $00, $00, $e4, $74, $ff, $6b, $40, $7e, $00, $00, $6a, $29
	db $ff, $6b, $51, $4a, $00, $00, $6a, $29, $ff, $6b, $51, $4a, $00, $00, $6a, $29
	db $ff, $6b, $51, $4a, $00, $00, $df, $01, $ff, $6b, $1f, $03, $00, $00, $de, $01
	db $ff, $6b, $7f, $03, $00, $00, $55, $01, $ff, $6b, $80, $7e, $00, $00, $ca, $55
	db $ff, $6b, $71, $73, $00, $00, $37, $1c, $ff, $6b, $9f, $02, $00, $00, $11, $2c
	db $ff, $6b, $9d, $20, $00, $00, $e8, $0d, $ff, $6b, $27, $5b, $00, $00, $69, $0d
	db $ff, $6b, $d7, $02, $00, $00, $0a, $68, $ff, $6b, $00, $7e, $00, $00, $c3, $01
	db $ff, $6b, $a0, $32, $00, $00, $19, $01, $ff, $6b, $bf, $02, $00, $00, $20, $4d
	db $ff, $6b, $80, $7e, $00, $00, $52, $02, $ff, $6b, $9f, $03, $00, $00, $a0, $01
	db $ff, $6b, $a0, $06, $00, $00, $86, $02, $ff, $6b, $b6, $03, $00, $00, $8c, $31
	db $ff, $6b, $b2, $4e, $00, $00, $46, $15, $ff, $6b, $dd, $08, $00, $00, $f1, $00
	db $ff, $6b, $51, $3e, $00, $00, $ee, $10, $ff, $6b, $5c, $07, $00, $00, $9c, $1c
	db $ff, $6b, $c5, $06, $00, $00, $a1, $01, $ff, $6b, $60, $7e, $00, $00, $e3, $05
	db $ff, $6b, $f8, $00, $00, $00, $31, $01, $ff, $6b, $86, $02, $00, $00, $00, $1e
	db $ff, $6b, $6f, $07, $00, $00, $08, $02, $ff, $6b, $7f, $02, $00, $00, $26, $12
	db $ff, $6b, $0c, $1b, $00, $00, $13, $01, $ff, $6b, $1a, $02, $00, $00, $f9, $01
	db $ff, $6b, $f7, $7c, $00, $00, $d9, $00, $ff, $6b, $3f, $02, $00, $00, $07, $02
	db $ff, $6b, $33, $03, $00, $00, $60, $59, $ff, $6b, $b7, $01, $00, $00, $f2, $00
	db $ff, $6b, $90, $02, $00, $00, $79, $01, $ff, $6b, $5f, $03, $00, $00, $a0, $69
	db $ff, $6b, $00, $7f, $00, $00, $e3, $64, $ff, $6b, $23, $7e, $00, $00, $71, $6c
	db $ff, $6b, $7f, $02, $00, $00, $37, $01, $ff, $6b, $34, $03, $00, $00, $0e, $3e
	db $ff, $6b, $ff, $6b, $00, $00, $36, $24, $ff, $6b, $7f, $02, $00, $00, $26, $35
	db $ff, $6b, $0c, $4a, $00, $00, $12, $01, $ff, $6b, $1f, $5e, $00, $00, $6c, $6c
	db $ff, $6b, $87, $7a, $00, $00, $d1, $74, $ff, $6b, $df, $79, $00, $00, $1b, $01
	db $ff, $6b, $d9, $71, $00, $00, $e0, $79, $ff, $6b, $3e, $02, $00, $00, $6c, $48
	db $ff, $6b, $d6, $6c, $00, $00, $44, $61, $ff, $6b, $f0, $76, $00, $00, $2d, $06
	db $ff, $6b, $c4, $7a, $00, $00, $4c, $02, $ff, $6b, $bf, $02, $00, $00, $bc, $00
	db $ff, $6b, $5f, $02, $00, $00, $ef, $00, $ff, $6b, $d8, $01, $00, $00, $b8, $58
	db $ff, $6b, $7f, $02, $00, $00, $bc, $01, $ff, $6b, $5f, $03, $00, $00, $4e, $1c
	db $ff, $6b, $53, $01, $00, $00, $57, $18, $ff, $6b, $2a, $7e, $00, $00, $95, $58
	db $ff, $6b, $50, $03, $00, $00, $5b, $02, $ff, $6b, $76, $6d, $00, $00, $e9, $01
	db $ff, $6b, $bb, $02, $00, $00, $dd, $00, $ff, $6b, $bf, $02, $00, $00, $7b, $00
	db $ff, $6b, $97, $2a, $00, $00, $37, $58, $ff, $6b, $ff, $02, $00, $00, $e0, $7d
	db $ff, $6b, $5f, $02, $00, $00, $0f, $3c, $ff, $6b, $37, $58, $00, $00, $03, $02
	db $ff, $6b, $36, $7d, $00, $00, $4d, $5c, $ff, $6b, $76, $6d, $00, $00, $61, $69
	db $ff, $6b, $2a, $7f, $00, $00, $fd, $00, $ff, $6b, $df, $02, $00, $00, $ed, $7c
	db $ff, $6b, $69, $7e, $00, $00, $db, $00, $ff, $6b, $7f, $02, $00, $00, $52, $7d
	db $ff, $6b, $8a, $7f, $00, $00, $4f, $7c, $ff, $6b, $5f, $65, $00, $00, $00, $02
	db $ff, $6b, $8d, $03, $00, $00, $70, $64, $ff, $6b, $e8, $7e, $00, $00, $b2, $60
	db $ff, $6b, $6e, $7e, $00, $00, $c4, $01, $ff, $6b, $f1, $02, $00, $00, $e1, $01
	db $ff, $6b, $2a, $03, $00, $00, $05, $02, $ff, $6b, $8d, $03, $00, $00, $70, $64
	db $ff, $6b, $36, $03, $00, $00, $c1, $6d, $ff, $6b, $ff, $01, $00, $00, $10, $01
	db $ff, $6b, $1b, $02, $00, $00, $b5, $01, $ff, $6b, $d0, $02, $00, $00, $da, $00
	db $ff, $6b, $5f, $02, $00, $00, $10, $01, $ff, $6b, $7f, $02, $00, $00, $c5, $01
	db $ff, $6b, $14, $02, $00, $00, $c1, $01, $ff, $6b, $17, $02, $00, $00, $e1, $11
	db $ff, $6b, $2c, $03, $00, $00, $56, $30, $ff, $6b, $7e, $02, $00, $00, $5b, $00
	db $ff, $6b, $d3, $78, $00, $00, $40, $02, $ff, $6b, $93, $03, $00, $00, $54, $00
	db $ff, $6b, $1f, $01, $00, $00, $e0, $58, $ff, $6b, $a6, $7e, $00, $00, $18, $00
	db $ff, $6b, $71, $03, $00, $00, $12, $48, $ff, $6b, $c9, $02, $00, $00, $10, $38
	db $ff, $6b, $7f, $02, $00, $00, $7b, $00, $ff, $6b, $ce, $7d, $00, $00, $60, $6d
	db $ff, $6b, $40, $47, $00, $00, $50, $44, $ff, $6b, $18, $5d, $00, $00, $9c, $01
	db $ff, $6b, $4e, $03, $00, $00, $78, $01, $ff, $6b, $3f, $02, $00, $00, $61, $09
	db $ff, $6b, $a1, $1e, $00, $00, $bd, $01, $ff, $6b, $4f, $03, $00, $00, $55, $44
	db $ff, $6b, $76, $3e, $00, $00, $16, $04, $ff, $6b, $9f, $01, $00, $00, $6f, $5c
	db $ff, $6b, $ff, $02, $00, $00, $52, $01, $ff, $6b, $7e, $02, $00, $00, $10, $30
	db $ff, $6b, $9d, $51, $00, $00, $18, $00, $ff, $6b, $de, $01, $00, $00, $11, $04
	db $ff, $6b, $bf, $02, $00, $00, $af, $00, $ff, $6b, $9b, $01, $00, $00, $5b, $01
	db $ff, $6b, $bf, $02, $00, $00, $6d, $40, $ff, $6b, $bd, $04, $00, $00, $60, $79
	db $ff, $6b, $3f, $02, $00, $00, $c3, $01, $ff, $6b, $b9, $64, $00, $00, $e3, $58
	db $ff, $6b, $e7, $7e, $00, $00, $f0, $04, $ff, $6b, $78, $34, $00, $00, $60, $6d
	db $ff, $6b, $57, $7d, $00, $00, $40, $69, $ff, $6b, $a4, $7e, $00, $00, $60, $6d
	db $ff, $6b, $9f, $02, $00, $00, $71, $45, $ff, $6b, $18, $6a, $00, $00, $9b, $00
	db $ff, $6b, $7f, $02, $00, $00, $36, $01, $ff, $6b, $bc, $71, $00, $00, $5f, $02
	db $ff, $6b, $00, $7a, $00, $00, $77, $40, $ff, $6b, $9f, $02, $00, $00, $43, $65
	db $ff, $6b, $da, $00, $00, $00, $32, $01, $ff, $6b, $5d, $02, $00, $00, $26, $65
	db $ff, $6b, $68, $0f, $00, $00, $6d, $40, $ff, $6b, $17, $59, $00, $00, $86, $7d
	db $ff, $6b, $b9, $58, $00, $00, $a6, $01, $ff, $6b, $a0, $7e, $00, $00, $bb, $00
	db $ff, $6b, $9f, $02, $00, $00, $c3, $1d, $ff, $6b, $4f, $7e, $00, $00, $80, $65
	db $ff, $6b, $20, $77, $00, $00, $a0, $71, $ff, $6b, $20, $77, $00, $00, $e7, $41
	db $ff, $6b, $1a, $00, $00, $00, $14, $44, $ff, $6b, $7f, $02, $00, $00, $11, $58
	db $ff, $6b, $df, $01, $00, $00, $15, $58, $ff, $6b, $ff, $02, $00, $00, $f3, $25
	db $ff, $6b, $f9, $3e, $00, $00, $0c, $60, $ff, $6b, $20, $7a, $00, $00, $a0, $19
	db $ff, $6b, $76, $74, $00, $00, $cc, $78, $ff, $6b, $f7, $70, $c4, $00, $e8, $6c
	db $ff, $6b, $b1, $7e, $e0, $10, $10, $34, $ff, $6b, $96, $01, $00, $00, $0b, $42
	db $ff, $6b, $3f, $03, $00, $00, $c0, $75, $ff, $6b, $78, $01, $85, $00, $14, $44
	db $ff, $6b, $3f, $03, $00, $18, $7f, $02, $ff, $6b, $80, $7e, $00, $18, $0f, $38
	db $ff, $6b, $39, $69, $00, $18, $40, $61, $ff, $6b, $e3, $7e, $00, $18, $dc, $00
	db $ff, $6b, $bf, $02, $a6, $00, $58, $20, $ff, $6b, $e8, $7d, $a6, $00, $11, $30
	db $ff, $6b, $ed, $02, $60, $18, $e4, $05, $ff, $6b, $fd, $01, $00, $00, $31, $20
	db $ff, $6b, $1a, $5d, $00, $00, $29, $1d, $ff, $6b, $90, $41, $00, $00, $a0, $75
	db $ff, $6b, $5f, $03, $60, $10, $16, $0c, $ff, $6b, $1f, $03, $00, $00, $ef, $00
	db $ff, $6b, $1a, $02, $00, $00, $1f, $02, $ff, $6b, $0a, $7f, $00, $00, $e9, $7d
	db $ff, $6b, $ff, $02, $00, $00, $49, $02, $ff, $6b, $1f, $03, $00, $00, $44, $02
	db $ff, $6b, $6d, $03, $00, $00, $17, $14, $ff, $6b, $5f, $03, $00, $00, $33, $50
	db $ff, $6b, $24, $7e, $00, $00, $53, $01, $ff, $6b, $5c, $02, $00, $00, $0c, $44
	db $ff, $6b, $15, $58, $00, $00, $c9, $71, $ff, $6b, $54, $7f, $00, $00, $29, $71
	db $ff, $6b, $c4, $7e, $00, $00, $df, $02, $ff, $6b, $0b, $7f, $00, $00, $fa, $00
	db $ff, $6b, $bf, $02, $00, $00, $58, $01, $ff, $6b, $c5, $7e, $00, $00, $38, $01
	db $ff, $6b, $1f, $03, $00, $00, $cd, $4d, $ff, $6b, $d4, $62, $00, $00, $18, $00
	db $ff, $6b, $5f, $02, $00, $00, $9e, $02, $ff, $6b, $09, $7e, $00, $00, $53, $5c
	db $ff, $6b, $41, $0a, $00, $00, $c2, $01, $ff, $6b, $fc, $01, $00, $00, $d3, $00
	db $ff, $6b, $5b, $02, $00, $00, $ce, $25, $ff, $6b, $b5, $4a, $00, $00, $86, $61
	db $ff, $6b, $6c, $72, $00, $00, $71, $60, $ff, $6b, $ff, $02, $00, $00, $89, $75
	db $ff, $6b, $b9, $68, $60, $10, $aa, $01, $ff, $6b, $78, $6c, $00, $00, $b9, $00
	db $ff, $6b, $0c, $7e, $00, $00, $a7, $01, $ff, $6b, $20, $7e, $00, $00, $69, $02
	db $ff, $6b, $5a, $6d, $00, $00, $58, $00, $ff, $6b, $9f, $02, $00, $00, $81, $01
	db $ff, $6b, $eb, $0e, $00, $00, $f3, $00, $ff, $6b, $df, $02, $00, $00, $53, $4c
	db $ff, $6b, $10, $03, $00, $00, $17, $10, $ff, $6b, $3f, $49, $00, $00, $36, $01
	db $ff, $6b, $51, $03, $a3, $00, $53, $4c, $ff, $6b, $f9, $03, $02, $00, $17, $10
	db $ff, $6b, $5f, $59, $00, $08, $17, $10, $ff, $6b, $39, $75, $00, $08, $83, $55
	db $ff, $6b, $dd, $01, $00, $00, $aa, $0d, $ff, $6b, $e0, $7e, $00, $00

;@ path: gfx/palettes
;@ Full sets of the 8 background palettes (64 bytes each), by wPaletteSet (LoadPaletteSet).
PaletteSets::
	db $33, $46
	db $be, $77, $f8, $5e, $44, $08, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c
	db $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $00, $7c, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $a0, $31, $ff, $6b, $4e, $5e, $00, $00, $a0, $31
	db $ff, $6b, $8f, $66, $00, $00, $a0, $31, $ff, $6b, $d0, $6e, $00, $00, $48, $5e
	db $ff, $6b, $11, $7b, $00, $00, $12, $00, $ff, $6b, $de, $01, $00, $00, $15, $00
	db $ff, $6b, $1f, $02, $00, $00, $17, $00, $ff, $6b, $9f, $02, $00, $00, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $47, $1d, $ff, $6b, $ec, $29, $00, $00, $47, $1d
	db $ff, $6b, $ec, $29, $00, $00, $62, $19, $ff, $6b, $24, $36, $00, $00, $e5, $6e
	db $ff, $6b, $f3, $7f, $00, $00, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $a0, $31, $ff, $6b, $e8, $66, $00, $00, $a0, $31
	db $ff, $6b, $09, $6b, $00, $00, $0d, $01, $ff, $6b, $9f, $02, $00, $00, $6a, $49
	db $ff, $6b, $1f, $7c, $00, $00, $6a, $49, $ff, $6b, $1f, $7c, $00, $00, $e6, $6e
	db $ff, $6b, $f3, $7f, $00, $00, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c, $1f, $7c
	db $1f, $7c, $1f, $7c, $1f, $7c, $03, $01, $ff, $6b, $a2, $02, $00, $00, $0c, $05
	db $ff, $6b, $42, $02, $00, $00, $11, $01, $ff, $6b, $f9, $7f, $00, $00, $11, $01
	db $ff, $6b, $f9, $7f, $00, $00, $11, $01, $ff, $6b, $f9, $7f, $00, $00, $11, $01
	db $ff, $6b, $f9, $7f, $00, $00, $28, $7f, $ff, $6b, $f9, $7f, $00, $00

;@ path: gfx/palettes
;@ Sprite palette 0 by wPaletteSet (8 bytes each), for LoadObjPaletteA.
ObjPaletteSetsA::
	db $00, $00
	db $ff, $6b, $8f, $7f, $1f, $7c, $10, $42, $1f, $7c, $1f, $7c, $1f, $7c

;@ path: gfx/palettes
;@ Sprite palette 0 by wPaletteSet (8 bytes each), for LoadObjPaletteB.
ObjPaletteSetsB::
	db $00, $00
	db $ff, $02, $17, $00, $df, $01, $00, $00, $ff, $02, $17, $00, $df, $01, $00, $00
	db $ff, $02, $17, $00, $df, $01, $00, $00, $5f, $03, $1f, $00, $ff, $01, $00, $00
	db $5f, $03, $1f, $00, $ff, $01, $00, $00, $5f, $03, $1f, $00, $ff, $01, $00, $00
	db $ff, $7f, $ff, $4b, $ff, $02, $00, $00, $ff, $7f, $7f, $03, $b8, $4a, $00, $00
	db $ff, $7f, $ff, $03, $15, $7e, $00, $00, $ff, $4b, $72, $53, $c5, $2a, $00, $00
	db $ff, $4b, $72, $53, $c5, $2a, $00, $00, $ff, $4b, $72, $53, $c5, $2a, $00, $00
	db $34, $7f, $0c, $5a, $c0, $7d, $00, $00, $34, $7f, $0c, $5a, $c0, $7d, $00, $00
	db $34, $7f, $0c, $5a, $c0, $7d, $00, $00, $ff, $03, $72, $53, $37, $7d, $00, $00
	db $ff, $03, $72, $53, $37, $7d, $00, $00, $ff, $03, $72, $53, $37, $7d, $00, $00
	db $df, $2d, $b8, $4a, $f2, $7d, $00, $00, $e0, $4b, $ff, $02, $c8, $7d, $00, $00
	db $ff, $02, $b9, $60, $00, $00, $00, $00, $1c, $4b, $7b, $3d, $00, $00, $00, $00
	db $e0, $4b, $3f, $7e, $f3, $64, $00, $00, $b2, $56, $37, $1e, $f3, $64, $00, $00
	db $1c, $4b, $9f, $11, $b1, $20, $00, $00, $72, $5f, $37, $7d, $b1, $20, $00, $00
	db $f5, $6b, $0c, $5a, $c8, $7d, $00, $00, $1c, $4b, $f4, $1d, $e9, $00, $00, $00
	db $ff, $02, $ff, $00, $b1, $00, $00, $00, $ff, $4b, $7f, $01, $00, $00, $00, $00
	db $ff, $4b, $7f, $01, $00, $00, $00, $00, $ff, $4b, $b5, $7d, $00, $00, $00, $00
	db $ff, $4b, $72, $53, $c5, $2a, $00, $00, $34, $7f, $0c, $5a, $c0, $7d, $00, $00
	db $1c, $4b, $f4, $1d, $e9, $00, $00, $00, $ff, $5f, $ff, $16, $e9, $00, $00, $00
	db $ff, $5f, $eb, $6b, $e9, $00, $00, $00, $ff, $5f, $df, $01, $e9, $00, $00, $00
	db $59, $7f, $37, $7d, $e9, $00, $00, $00, $ff, $5f, $bf, $03, $df, $01, $00, $00
	db $9f, $33, $91, $69, $bf, $60, $00, $00, $d9, $7f, $ff, $47, $37, $7d, $00, $00
	db $f9, $63, $df, $01, $15, $00, $00, $00, $fd, $7f, $a5, $7e, $0e, $7f, $00, $00
	db $ff, $7f, $ff, $7f, $bf, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00
