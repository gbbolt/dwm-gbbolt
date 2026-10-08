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


WindowBgAddrWrapped9::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call WindowBgAddr9
	ld a, b
	and $1f
	jr z, jr_009_408b

	ld b, a

jr_009_4085:
	call NextBgColumn9
	dec b
	jr nz, jr_009_4085

jr_009_408b:
	pop bc
	ret


DrawLayoutToVram9::
	db $1a, $6f, $13, $1a, $67, $13, $cd, $76, $40, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $4a, $40, $18, $d3

DrawWindowLayout9::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call TilemapBufferAddr9
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a

jr_009_40d8:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_009_40f7

	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	jr jr_009_40d8

jr_009_40f7:
	ld [hli], a
	jr jr_009_40d8

CopyTilemapBufferToVram9::
	ld a, [wWindowBgMap]
	ld l, a
	ld a, [$c90a]
	ld h, a
	ld de, wTilemapBuffer
	ld c, $12

jr_009_4107:
	ld b, $20
	push hl

jr_009_410a:
	ld a, [de]
	call WriteVRAM
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
	inc de
	dec b
	jr nz, jr_009_410a

	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, jr_009_4107

	ret


DrawTextTiles9::
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ret


DrawNameTiles9::
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0401
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
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
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ret


DrawCharTile9::
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0101
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
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
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ret


RestoreTilemapBuffer9::
	ld hl, wTilemapBuffer
	ld de, wSavedTilemap
	ld bc, $0200

jr_009_420d:
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_009_420d

	ld de, wPartyBarTiles
	ld c, $02

jr_009_421a:
	ld b, $14

jr_009_421c:
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, jr_009_421c

	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, l
	add $0c
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec c
	jr nz, jr_009_421a

	ret


ClearTilemapBuffer9::
	ld hl, wTilemapBuffer
	ld bc, $0240

jr_009_423c:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_009_423c

	ret


ClearBgMap9::
	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

UpdatePagedList9::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_009_42cf

	ld a, [wJoyPressed]
	bit 5, a
	jr z, jr_009_428c

	ld a, [wPageToggle]
	inc a
	and $01
	ld [wPageToggle], a
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
	jr c, jr_009_42b3

	ld a, c
	dec a
	jr jr_009_42b3

jr_009_428c:
	ld a, [wJoyPressed]
	bit 4, a
	jr z, jr_009_42cf

	ld a, [wPageToggle]
	inc a
	and $01
	ld [wPageToggle], a
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
	jr c, jr_009_42b3

	ld a, $00

jr_009_42b3:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_009_4312

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
	jr z, jr_009_4312

	dec a
	cp [hl]
	jr nc, jr_009_4312

	ld [hl], a
	jr jr_009_4312

Jump_009_42cf:
jr_009_42cf:
	push bc
	push de
	push hl
	call DrawPageNumber9
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
	jr nz, UpdateMenuCursor9

	ld a, [wListLastRows]
	inc a
	ld b, a

UpdateMenuCursor9::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_009_4303

	ld a, [hl]
	dec a
	cp b
	jr c, jr_009_4311

	dec b
	ld a, b
	jr jr_009_4311

jr_009_4303:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_009_431a

	ld a, [hl]
	inc a
	cp b
	jr c, jr_009_4311

	ld a, $00

jr_009_4311:
	ld [hl], a

jr_009_4312:
	xor a
	ld [wCursorBlink], a
	push hl
	push de
	pop de
	pop hl

jr_009_431a:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_009_4323

	set 7, [hl]

jr_009_4323:
	ld a, [hl]
	call DrawMenuCursor9
	ret


UpdateMenuCursorLeftRight9::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

UpdateNumberEntry::
	res 7, [hl]
	ld a, c
	ldh [$ffd7], a
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_009_4360

	ld a, $10
	ld [wCursorBlink], a
	call NumberEntryDigitDown
	jr jr_009_4394

jr_009_4360:
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_009_4371

	ld a, $10
	ld [wCursorBlink], a
	call NumberEntryDigitUp
	jr jr_009_4394

jr_009_4371:
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_009_4381

	ld a, [hl]
	dec a
	cp b
	jr c, jr_009_438f

	dec b
	ld a, b
	jr jr_009_438f

jr_009_4381:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_009_4398

	ld a, [hl]
	inc a
	cp b
	jr c, jr_009_438f

	ld a, $00

jr_009_438f:
	ld [hl], a
	xor a
	ld [wCursorBlink], a

jr_009_4394:
	push hl
	push de
	pop de
	pop hl

jr_009_4398:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_009_43a1

	set 7, [hl]

jr_009_43a1:
	ldh a, [$ffd7]
	inc hl
	cp [hl]
	dec hl
	jr nc, jr_009_43aa

	inc hl
	ld [hld], a

jr_009_43aa:
	inc hl
	ld a, [hl]
	or a
	jr nz, jr_009_43b1

	ld [hl], $01

jr_009_43b1:
	dec hl
	ld a, [hl]
	call DrawNumberEntry
	ret


NumberEntryDigitDown::
	push de
	ld a, [hl]
	push hl
	inc hl
	ld c, [hl]
	ld b, $00
	ld hl, wNumberBackup
	call PrintNumber2Zeros
	pop hl
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	and $0f
	dec a
	ld [de], a
	cp $ff
	jr nz, jr_009_43db

	ld a, $09
	ld [de], a

jr_009_43db:
	call NumberEntryDigitsToValue
	pop de
	or a
	ret nz

	ld a, [hl]
	or a
	ret z

	ld a, $09
	inc hl
	ld [hld], a
	ret


NumberEntryDigitsToValue::
	push hl
	ld a, [wNumberBackup]
	and $0f
	ld c, $0a
	call Multiply
	ld a, [$c0a1]
	and $0f
	add l
	pop hl
	inc hl
	ld [hld], a
	ret


NumberEntryDigitUp::
	push de
	ld a, [hl]
	push hl
	inc hl
	ld c, [hl]
	ld b, $00
	ld hl, wNumberBackup
	call PrintNumber2Zeros
	pop hl
	ld de, $c0a1
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	and $0f
	inc a
	ld [de], a
	cp $0a
	jr nz, jr_009_4425

	ld a, $00
	ld [de], a

jr_009_4425:
	call NumberEntryDigitsToValue
	pop de
	ret


ResetCursorBlink9::
	xor a
	ld [wCursorBlink], a
	ret


DrawMenuCursor9::
	ld c, a
	bit 7, a
	jr nz, jr_009_4444

	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
	pop af
	ld a, c
	ret nz

jr_009_4444:
	ld c, a
	ld b, $00

jr_009_4447:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_009_4477

	ld a, $e9
	bit 7, c
	jr nz, jr_009_4477

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_4477

	ld a, $e8

jr_009_4477:
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	inc b
	jr jr_009_4447

DrawPageNumber9::
	ld a, b
	cp c
	ret nc

	inc hl
	ld c, [hl]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	dec hl
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, c
	and $7f
	cp $09
	jr z, jr_009_44b6

	add $f1
	call PutWindowTile
	ld a, $ee
	jr jr_009_44bd

jr_009_44b6:
	ld a, $f0
	call PutWindowTile
	ld a, $f1

jr_009_44bd:
	push af
	ldh a, [hNumber]
	sub $01
	ldh [hNumber], a
	ldh a, [$ffd6]
	sbc $00
	ldh [$ffd6], a
	pop af
	call PutWindowTile
	ldh a, [hNumber]
	add $01
	ldh [hNumber], a
	ldh a, [$ffd6]
	adc $00
	ldh [$ffd6], a
	ret


PutWindowTile::
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	pop af
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


DrawListFrame9::
	ld a, [hli]
	push af
	push hl
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, b
	cp c
	ld a, $ee
	jr nc, jr_009_4518

	ld a, $e7

jr_009_4518:
	ld [hld], a
	pop bc
	jr nc, jr_009_452f

	ld a, [bc]
	cp $09
	jr z, jr_009_4529

	add $f1
	ld [hld], a
	ld a, $ee
	ld [hli], a
	jr jr_009_452f

jr_009_4529:
	ld a, $f0
	ld [hld], a
	ld a, $f1
	ld [hli], a

jr_009_452f:
	pop af

DrawCursorAt9::
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_009_455b

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_455b

	ld a, $e8

jr_009_455b:
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


DrawNumberEntry::
	ld c, a
	inc hl
	push de
	push bc
	ld c, [hl]
	ld b, $00
	ld hl, wNumberBackup
	call PrintNumber2Zeros
	pop bc
	pop de
	bit 7, c
	jr nz, jr_009_4590

	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
	pop af
	ld a, c
	ret nz

jr_009_4590:
	ld c, a
	ld b, $00

jr_009_4593:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_009_45bd

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_45bd

	ld a, $e6

jr_009_45bd:
	cp $e0
	jr nz, jr_009_45ce

	push hl
	ld a, b
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl

jr_009_45ce:
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	inc b
	jr jr_009_4593

PrintMenuText9::
	ld a, [wScriptMenuText]
	add l
	ld l, a
	ld a, [$c8f1]
	adc h
	ld h, a
	call PrintMessage
	ret


ShopMenu::
	ld a, [wMenuStep]
	rst $00

ShopSteps::
	dw ShopInit
	dw ShopOpenMenu
	dw ShopMainMenuInput
	dw ShopRunOption
	dw ShopClose

ShopInit::
	ld hl, hScrollX
	call SnapToTile9
	ld hl, hScrollY
	call SnapToTile9
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
	call RestoreTilemapBuffer9
	ld de, $2e0e
	ld hl, $8800
	call DecompressVRAM
	call ResetCursorBlink9
	ld hl, wMenuStep
	inc [hl]
	ret


ShopOpenMenu::
	ld hl, wMenuStep
	inc [hl]
	call RestoreTilemapBuffer9
	call DrawShopMainMenu
	call CopyTilemapBufferToVram9
	ret


DrawShopMainMenu::
	ld de, $6f3c
	call DrawWindowLayout9
	ld de, $6f1f
	call DrawWindowLayout9
	ld de, $2e07
	call DrawWindowLayout9
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
	call ResetCursorBlink9
	ld de, $46df
	ld a, [wLinkChoice]
	call DrawCursorAt9
	ret


ShopMainMenuInput::
	ld de, $46df
	ld hl, wLinkChoice
	ld b, $03
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_009_46ad

	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr jr_009_46de

jr_009_46ad:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_009_46de

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
	jr jr_009_46de

jr_009_46de:
	ret


ShopMainMenuCursor::
	db $21, $00, $61, $00, $a1, $00, $ff, $ff

ShopRunOption::
	ld a, [wLinkChoice]
	rst $00

ShopOptionTable::
	dw ShopBuyOption
	dw ShopSellOption
	dw ShopClose

ShopClose::
	call RestoreTilemapBuffer9
	ld de, $2e07
	call DrawWindowLayout9
	call CopyTilemapBufferToVram9
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


ShopBuyOption::
	ld a, [wMenuSubStep]
	rst $00

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

ShopBuyStart::
	ld hl, $0003
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ld a, [wMapId]
	ld hl, $478c
	cp $50
	jr z, jr_009_4754

	ld a, [wMapScreen]
	ld hl, $476b
	cp $00
	jr z, jr_009_4754

	ld hl, $4774
	cp $02
	jr z, jr_009_4754

	ld hl, $477d
	cp $04
	jr z, jr_009_4754

	ld hl, $4784
	cp $05
	jr z, jr_009_4754

jr_009_4754:
	push hl
	ld hl, wSceneObjects
	ld bc, $0014
	xor a
	call FillMemory
	pop hl
	ld de, wSceneObjects

jr_009_4763:
	ld a, [hli]
	ld [de], a
	inc de
	cp $ff
	ret z

	jr jr_009_4763

ShopStock0::
	db $01, $02, $07, $28, $13, $14, $1d, $26, $ff

ShopStock2::
	db $05, $04, $03, $0c, $2a, $2b, $15
	db $1a, $ff

ShopStock4::
	db $1f, $20, $21, $22, $23, $24, $ff

ShopStock5::
	db $17, $29, $19, $1b, $18, $1c, $25
	db $ff

ShopStockMap50::
	db $01, $02, $07, $08, $0b, $09, $0a, $0c, $ff

ShopBuyShowList::
	ld a, [wTextState]
	or a
	ret nz

	call CountShopList
	call LoadItemNameTiles
	call DrawShopBuyWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawShopBuyWindow::
	call RestoreTilemapBuffer9
	call DrawShopMainMenu
	ld de, $6f7d
	call DrawWindowLayout9
	call DrawBuyPrices
	call ResetCursorBlink9
	ld de, $48ec
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
	call CopyTilemapBufferToVram9
	ret


LoadItemNameTiles::
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call LoadItemNameSlot
	call LoadItemNameSlot
	call LoadItemNameSlot

LoadItemNameSlot::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_009_47f0

	ld a, $00

jr_009_47f0:
	ld [wTextIndex], a
	ld a, $08
	ld [wTextGroup], a
	ld de, $0901
	call DrawTextTiles9
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


DrawBuyPrices::
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $00ad
	call DrawBuyPriceSlot
	call DrawBuyPriceSlot
	call DrawBuyPriceSlot

DrawBuyPriceSlot::
	push de
	push hl
	ld a, [de]
	cp $00
	jr z, jr_009_482f

	cp $ff
	jr nz, jr_009_483c

jr_009_482f:
	call TilemapBufferAddr9
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	jr jr_009_4869

jr_009_483c:
	push hl
	ld a, [de]
	ld [wItemId], a
	ld hl, far_GetItemData
	rst $10
	pop hl
	push hl
	call TilemapBufferAddr9
	ld a, [$da63]
	ldh [hNumber], a
	ld a, [$da64]
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	call PrintNumber5
	pop hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call TilemapBufferAddr9
	ld [hl], $dd

jr_009_4869:
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


CountShopList::
	ld hl, wSceneObjects
	call CountItems20
	ld a, c
	ld [wListLength], a
	ret


CountItems20::
	ld b, $14
	ld c, $00

jr_009_4884:
	ld a, [hli]
	cp $00
	ret z

	cp $ff
	ret z

	inc c
	dec b
	jr nz, jr_009_4884

	ret


ShopBuyListInput::
	ld de, $48ec
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList9
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_009_48b1

jr_009_48b1:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_009_48c1

	call LoadItemNameTiles
	call DrawBuyPrices
	call CopyTilemapBufferToVram9

jr_009_48c1:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_48d5

	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuStep], a
	jr jr_009_48eb

jr_009_48d5:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_48eb

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	ld a, $01
	ld [wConfirmChoice2], a

Jump_009_48eb:
jr_009_48eb:
	ret


ShopBuyListCursor::
	db $92, $01, $a2, $00, $e2, $00, $22, $01, $62, $01, $ff, $ff

ShopBuyAskQuantity::
	ld hl, $0005
	call PrintMenuText9
	ld a, $01
	ld [wConfirmChoice], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopBuyShowQuantity::
	ld a, [wTextState]
	or a
	ret nz

	call DrawBuyQuantityWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawBuyQuantityWindow::
	call RestoreTilemapBuffer9
	call DrawShopMainMenu
	ld de, $6f7d
	call DrawWindowLayout9
	call DrawBuyPrices
	ld de, $48ec
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
	ld de, $7033
	call DrawWindowLayout9
	call ResetCursorBlink9
	ld de, $498d
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
	call CopyTilemapBufferToVram9
	ret


ShopBuyQuantityInput::
	ld de, $498d
	ld hl, wConfirmChoice
	ld b, $02
	ld c, $14
	call UpdateNumberEntry
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_497b

	call DrawShopBuyWindow
	ld hl, $0004
	call PrintMenuText9
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_009_498c

jr_009_497b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_498c

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_009_498c:
jr_009_498c:
	ret


	db $61, $01, $62, $01, $ff, $ff

ShopBuyAskConfirm::
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	ld a, [wConfirmChoice2]
	ld hl, wTextArg1
	call ByteToDecimal
	ld hl, far_GetItemData
	rst $10
	ld a, [$da63]
	ld c, a
	ld a, [$da64]
	ld b, a
	ld a, [wConfirmChoice2]
	call Multiply24
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
	ld hl, wTextArg2
	call Number24ToDecimal
	ld hl, $0006
	call PrintMenuText9
	xor a
	ld [wMenuChoice3], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopBuyShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6efa
	call DrawWindowLayout9
	call ResetCursorBlink9
	ld de, $4a64
	ld a, [wMenuChoice3]
	call DrawCursorAt9
	call CopyTilemapBufferToVram9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopBuyYesNoInput::
	ld de, $4a64
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_4a4b

jr_009_4a30:
	call DrawBuyQuantityWindow
	ld hl, $0005
	call PrintMenuText9
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_009_4a63

jr_009_4a4b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_4a63

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_009_4a30

	ld hl, wMenuSubStep
	inc [hl]

Jump_009_4a63:
jr_009_4a63:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

ShopBuyDoIt::
	ld hl, far_CompactBag
	rst $10
	ld hl, wListCursor2
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc [hl]
	ld hl, $0007
	jr c, jr_009_4ac2

	ld hl, wBagItems
	call CountItems20
	ld a, [wConfirmChoice2]
	add c
	cp $15
	ld hl, $0008
	jr nc, jr_009_4ac2

	ld a, [wListCursor2]
	ld l, a
	ld a, [wListPage2]
	ld h, a
	ld a, [$c8e6]
	ld e, a
	call SpendGold
	ld hl, wBagItems
	call CountItems20
	ld a, c
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice2]
	ld b, a
	ld a, [wItemId]

jr_009_4abb:
	ld [hli], a
	dec b
	jr nz, jr_009_4abb

	ld hl, $0009

jr_009_4ac2:
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopBuyDone::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld a, $00
	ld [wMenuSubStep], a
	ret


ShopSellOption::
	ld a, [wMenuSubStep]
	rst $00

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

ShopSellStart::
	call BuildSellList
	ld hl, wSceneObjects
	call CountItems20
	ld a, c
	or a
	jr nz, jr_009_4b1c

	ld a, $0b
	ld [wMenuSubStep], a
	ret


jr_009_4b1c:
	ld hl, $000a
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopSellShowList::
	ld a, [wTextState]
	or a
	ret nz

	call BuildSellList
	call CountShopList
	call LoadItemNameTiles
	call DrawShopSellWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawShopSellWindow::
	call RestoreTilemapBuffer9
	call DrawShopMainMenu
	ld de, $6f7d
	call DrawWindowLayout9
	call DrawSellPrices
	call ResetCursorBlink9
	ld de, $4cdd
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
	call CopyTilemapBufferToVram9
	ret


DrawSellPrices::
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $00ad
	call DrawSellPriceSlot
	call DrawSellPriceSlot
	call DrawSellPriceSlot

DrawSellPriceSlot::
	push de
	push hl
	ld a, [de]
	cp $00
	jr z, jr_009_4b87

	cp $ff
	jr nz, jr_009_4b94

jr_009_4b87:
	call TilemapBufferAddr9
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	jr jr_009_4bbc

jr_009_4b94:
	push hl
	push hl
	ld a, [de]
	ld [wItemId], a
	call GetSellPrice
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	pop hl
	call TilemapBufferAddr9
	call PrintNumber5
	pop hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call TilemapBufferAddr9
	ld [hl], $dd

jr_009_4bbc:
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


GetSellPrice::
	ld hl, far_GetItemData
	rst $10
	ld a, [$da63]
	ld l, a
	ld a, [$da64]
	ld h, a
	ld a, [wMapId]
	cp $50
	ret z

	ld a, [wItemId]
	cp $18
	jr z, jr_009_4bfb

	cp $19
	jr z, jr_009_4bfb

	cp $1a
	jr z, jr_009_4bfb

	cp $1b
	jr z, jr_009_4bfb

	cp $1c
	jr z, jr_009_4bfb

	cp $25
	jr z, jr_009_4bfb

	cp $27
	jr z, jr_009_4bfb

	jr jr_009_4c09

jr_009_4bfb:
	ld a, [$da63]
	ld l, a
	ld a, [$da64]
	ld h, a
	ld a, $0a
	call Divide16
	ret


jr_009_4c09:
	ld a, [$da63]
	ld l, a
	ld a, [$da64]
	ld h, a
	srl h
	rr l
	srl h
	rr l
	ld a, [$da63]
	sub l
	ld l, a
	ld a, [$da64]
	sbc h
	ld h, a
	ret


BuildSellList::
	ld hl, far_CompactBag
	rst $10
	ld hl, wBreedParent1
	ld bc, $0030
	xor a
	call FillMemory
	ld hl, wSceneObjects
	ld bc, $0014
	xor a
	call FillMemory
	ld de, wBagItems
	ld b, $14

jr_009_4c41:
	ld a, [de]
	or a
	jr z, jr_009_4c6b

	cp $ff
	jr z, jr_009_4c6b

	ld [wItemId], a
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	push de
	push bc
	ld hl, far_GetItemData
	rst $10
	pop bc
	pop de
	pop hl
	inc de
	ld a, [$da6d]
	bit 0, a
	jr nz, jr_009_4c68

	inc [hl]

jr_009_4c68:
	dec b
	jr nz, jr_009_4c41

jr_009_4c6b:
	ld hl, $d666
	ld de, wSceneObjects
	ld b, $2f
	ld c, $01

jr_009_4c75:
	ld a, [hli]
	or a
	jr z, jr_009_4c7c

	ld a, c
	ld [de], a
	inc de

jr_009_4c7c:
	inc c
	dec b
	jr nz, jr_009_4c75

	ret


ShopSellListInput::
	ld de, $4cdd
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList9
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_009_4ca2

jr_009_4ca2:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_009_4cb2

	call LoadItemNameTiles
	call DrawSellPrices
	call CopyTilemapBufferToVram9

jr_009_4cb2:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_4cc6

	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuStep], a
	jr jr_009_4cdc

jr_009_4cc6:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_4cdc

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	ld a, $01
	ld [wConfirmChoice2], a

Jump_009_4cdc:
jr_009_4cdc:
	ret


	db $92, $01, $a2, $00, $e2, $00, $22, $01, $62, $01, $ff, $ff

ShopSellAskQuantity::
	ld hl, $000c
	call PrintMenuText9
	ld a, $01
	ld [wConfirmChoice], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopSellShowQuantity::
	ld a, [wTextState]
	or a
	ret nz

	call DrawSellQuantityWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawSellQuantityWindow::
	call RestoreTilemapBuffer9
	call DrawShopMainMenu
	ld de, $6f7d
	call DrawWindowLayout9
	call DrawSellPrices
	ld de, $4cdd
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
	ld de, $7044
	call DrawWindowLayout9
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call TilemapBufferAddr9
	call PrintNumber2
	call ResetCursorBlink9
	ld de, $4db5
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
	call CopyTilemapBufferToVram9
	ret


ShopSellQuantityInput::
	ld de, $4db5
	ld hl, wBreedParent1
	ld a, [wItemId]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, wConfirmChoice
	call UpdateNumberEntry
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_4da3

	call DrawShopSellWindow
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
	jr jr_009_4db4

jr_009_4da3:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_4db4

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_009_4db4:
jr_009_4db4:
	ret


	db $61, $01, $62, $01, $ff, $ff

ShopSellAskConfirm::
	ld a, [wItemId]
	ld l, a
	ld h, $08
	ld de, wTextArg0
	call CopySystemText
	ld a, [wConfirmChoice2]
	ld hl, wTextArg1
	call ByteToDecimal
	call GetSellPrice
	ld c, l
	ld b, h
	ld a, [wConfirmChoice2]
	call Multiply24
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
	ld hl, wTextArg2
	call Number24ToDecimal
	ld hl, $000d
	call PrintMenuText9
	xor a
	ld [wMenuChoice3], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopSellShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6efa
	call DrawWindowLayout9
	call ResetCursorBlink9
	ld de, $4e6d
	ld a, [wMenuChoice3]
	call DrawCursorAt9
	call CopyTilemapBufferToVram9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopSellYesNoInput::
	ld de, $4e6d
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_4e54

jr_009_4e3b:
	call DrawSellQuantityWindow
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
	jr jr_009_4e6c

jr_009_4e54:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_4e6c

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_009_4e3b

	ld hl, wMenuSubStep
	inc [hl]

Jump_009_4e6c:
jr_009_4e6c:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

ShopSellDoIt::
	ld hl, wListCursor2
	ld a, [wGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [$ca4c]
	adc [hl]
	ld d, a
	inc hl
	ld a, [$ca4d]
	adc [hl]
	ld c, a
	ld a, e
	sub $a0
	ld a, d
	sbc $86
	ld a, c
	sbc $01
	ld hl, $000e
	jr nc, jr_009_4eb4

	ld a, [wListCursor2]
	ld l, a
	ld a, [wListPage2]
	ld h, a
	ld a, [$c8e6]
	ld e, a
	call AddGold
	ld a, [wConfirmChoice2]
	ld b, a

jr_009_4ea8:
	push bc
	ld hl, far_RemoveItemFromBag
	rst $10
	pop bc
	dec b
	jr nz, jr_009_4ea8

	ld hl, $000f

jr_009_4eb4:
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopSellDone::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld a, $00
	ld [wMenuSubStep], a
	ret


ShopSellNothing::
	ld hl, $000b
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ShopSellNothingClose::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuStep], a
	ret


VaultMenu::
	ld a, [wMenuStep]
	rst $00

VaultSteps::
	dw VaultInit
	dw VaultOpenMenu
	dw VaultMainMenuInput
	dw VaultOpenWhatMenu
	dw VaultWhatMenuInput
	dw VaultRunOption
	dw VaultClose

VaultInit::
	ld hl, hScrollX
	call SnapToTile9
	ld hl, hScrollY
	call SnapToTile9
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
	call RestoreTilemapBuffer9
	ld de, $2e0f
	ld hl, $8800
	call DecompressVRAM
	call ResetCursorBlink9
	ld hl, wMenuStep
	inc [hl]
	ret


VaultOpenMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuStep
	inc [hl]
	call RestoreTilemapBuffer9
	call DrawVaultMainMenu
	call CopyTilemapBufferToVram9
	ret


DrawVaultMainMenu::
	ld a, $02
	ld [wTextGroup], a
	ld a, $0b
	ld [wTextIndex], a
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
	ld de, $7838
	call DrawWindowLayout9
	ld de, $6f1f
	call DrawWindowLayout9
	ld de, $2e07
	call DrawWindowLayout9
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
	call ResetCursorBlink9
	ld de, $501b
	ld a, [wLinkChoice]
	call DrawCursorAt9
	ret


VaultMainMenuInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $501b
	ld hl, wLinkChoice
	ld b, $03
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_009_4fdc

	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr jr_009_501a

jr_009_4fdc:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_009_501a

	ld a, $59
	call QueueSound
	ld a, [wLinkChoice]
	cp $82
	jp z, VaultClose

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
	ld hl, $0003
	ld a, [wLinkChoice]
	and $7f
	jr z, jr_009_5015

	ld hl, $000e

jr_009_5015:
	call PrintMenuText9
	jr jr_009_501a

jr_009_501a:
	ret


	db $21, $00, $61, $00, $a1, $00, $ff, $ff

VaultOpenWhatMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuStep
	inc [hl]
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	call CopyTilemapBufferToVram9
	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
	ret


DrawVaultWhatMenu::
	ld de, $7838
	call DrawWindowLayout9
	ld de, $6f1f
	call DrawWindowLayout9
	ld de, $2e07
	call DrawWindowLayout9
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
	call ResetCursorBlink9
	ld de, $50b0
	ld a, [wMenuChoice2]
	call DrawCursorAt9
	ret


VaultWhatMenuInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $50b0
	ld hl, wMenuChoice2
	ld b, $03
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_009_50b8

	call RestoreTilemapBuffer9
	call DrawVaultMainMenu
	call CopyTilemapBufferToVram9
	ld hl, $0001
	call PrintMenuText9
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	jr jr_009_50e7

	db $21, $00, $61, $00, $a1, $00, $ff, $ff

jr_009_50b8:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_009_50e7

	ld a, $59
	call QueueSound
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuSubStep], a
	ld hl, wMenuChoice2
	set 7, [hl]
	ld hl, wConfirmChoice
	ld bc, $0006
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory

jr_009_50e7:
	ret


VaultRunOption::
	ld a, [wLinkChoice]
	rst $00

VaultDirectionTable::
	dw VaultDepositOption
	dw VaultWithdrawOption

VaultDepositOption::
	ld a, [wMenuChoice2]
	rst $00

VaultDepositTable::
	dw VaultStoreItem
	dw VaultDepositGold
	dw VaultClose

VaultWithdrawOption::
	ld a, [wMenuChoice2]
	rst $00

VaultWithdrawTable::
	dw VaultTakeItem
	dw VaultWithdrawGold
	dw VaultClose

VaultClose::
	call RestoreTilemapBuffer9
	ld de, $2e07
	call DrawWindowLayout9
	call CopyTilemapBufferToVram9
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


VaultStoreItem::
	ld a, [wMenuSubStep]
	rst $00

VaultStoreItemSteps::
	dw VaultStoreItemStart
	dw $5161
	dw $5200
	dw $527e
	dw $528e
	dw $52fd
	dw $534f
	dw $537d
	dw $539e

VaultStoreItemStart::
	ld hl, wBagItems
	call CountItems40
	ld a, c
	or a
	ld hl, $0005
	jr z, jr_009_5158

	ld hl, wStoredItems
	ld b, $28
	call CountItemsN
	ld a, c
	cp $28
	ld hl, $0006
	jr nc, jr_009_5158

	ld hl, wMenuSubStep
	inc [hl]
	ld hl, $0004
	call PrintMenuText9
	ret


jr_009_5158:
	call PrintMenuText9
	ld a, $08
	ld [wMenuSubStep], a
	ret


	db $fa, $25, $c8, $b7, $c0, $cd, $99, $51, $cd, $e5, $51, $cd, $cd, $47, $cd, $77
	db $51, $21, $06, $c9, $34, $c9, $cd, $04, $42, $cd, $49, $50, $11, $53, $71, $cd
	db $c9, $40, $cd, $2a, $44, $11, $72, $52, $06, $04, $fa, $e9, $c8, $4f, $21, $e2
	db $c8, $cd, $ff, $44, $cd, $fa, $40, $c9, $21, $05, $03, $d7, $21, $65, $d6, $01
	db $30, $00, $af, $cd, $c7, $12, $21, $d8, $c0, $01, $28, $00, $af, $cd, $c7, $12
	db $11, $51, $ca, $06, $14, $1a, $b7, $28, $15, $fe, $ff, $28, $11, $ea, $5e, $da
	db $21, $65, $d6, $85, $6f, $3e, $00, $8c, $67, $13, $34, $05, $20, $e7, $21, $66
	db $d6, $11, $d8, $c0, $06, $2f, $0e, $01, $2a, $b7, $28, $03, $79, $12, $13, $0c
	db $05, $20, $f5, $c9

CountVaultList::
	ld hl, wSceneObjects
	call CountItems40
	ld a, c
	ld [wListLength], a
	ret


CountItems40::
	ld b, $28

CountItemsN::
	ld c, $00

jr_009_51f4:
	ld a, [hli]
	cp $00
	ret z

	cp $ff
	ret z

	inc c
	dec b
	jr nz, jr_009_51f4

	ret


	db $11, $72, $52, $21, $e2, $c8, $fa, $e9, $c8, $4f, $06, $04, $23, $3a, $f5, $7e
	db $f5, $cd, $56, $42, $f1, $21, $e2, $c8, $e6, $7f, $47, $7e, $e6, $7f, $b8, $28
	db $00, $f1, $21, $e3, $c8, $be, $28, $03, $cd, $cd, $47, $fa, $46, $c8, $cb, $4f
	db $28, $29, $3e, $02, $ea, $22, $c8, $3e, $0c, $ea, $23, $c8, $21, $40, $8a, $11
	db $01, $0c, $cd, $2f, $41, $cd, $04, $42, $cd, $49, $50, $cd, $fa, $40, $21, $03
	db $00, $cd, $e5, $45, $3e, $04, $ea, $05, $c9, $18, $16, $fa, $46, $c8, $cb, $47
	db $ca, $71, $52, $3e, $59, $cd, $2c, $1b, $21, $06, $c9, $34, $3e, $01, $ea, $de
	db $c8, $c9, $72, $01, $89, $00, $c9, $00, $09, $01, $49, $01, $ff, $ff, $21, $07
	db $00, $cd, $e5, $45, $3e, $01, $ea, $dd, $c8, $21, $06, $c9, $34, $c9, $fa, $25
	db $c8, $b7, $c0, $cd, $9b, $52, $21, $06, $c9, $34, $c9, $cd, $04, $42, $cd, $49
	db $50, $11, $53, $71, $cd, $c9, $40, $11, $72, $52, $06, $04, $fa, $e9, $c8, $4f
	db $21, $e2, $c8, $cd, $ff, $44, $11, $44, $70, $cd, $c9, $40, $21, $d8, $c0, $fa
	db $e3, $c8, $87, $87, $47, $fa, $e2, $c8, $e6, $7f, $80, $85, $6f, $3e, $00, $8c
	db $67, $7e, $ea, $5e, $da, $21, $65, $d6, $85, $6f, $3e, $00, $8c, $67, $4e, $06
	db $00, $21, $64, $01, $cd, $6d, $40, $cd, $82, $20, $cd, $2a, $44, $11, $49, $53
	db $21, $dd, $c8, $06, $02, $7e, $cd, $6d, $45, $cd, $fa, $40, $c9, $11, $49, $53
	db $21, $65, $d6, $fa, $5e, $da, $85, $6f, $3e, $00, $8c, $67, $4e, $06, $02, $21
	db $dd, $c8, $cd, $4a, $43, $fa, $46, $c8, $cb, $4f, $28, $1b, $cd, $77, $51, $21
	db $04, $00, $cd, $e5, $45, $21, $06, $c9, $35, $21, $06, $c9, $35, $21, $06, $c9
	db $35, $21, $06, $c9, $35, $18, $11, $fa, $46, $c8, $cb, $47, $ca, $48, $53, $3e
	db $59, $cd, $2c, $1b, $21, $06, $c9, $34, $c9, $61, $01, $62, $01, $ff, $ff, $21
	db $65, $ca, $06, $28, $cd, $f2, $51, $fa, $de, $c8, $81, $fe, $29, $21, $08, $00
	db $30, $13, $fa, $de, $c8, $47, $c5, $21, $07, $03, $d7, $cd, $1a, $5b, $c1, $05
	db $20, $f4, $21, $09, $00, $cd, $e5, $45, $21, $06, $c9, $34, $c9, $fa, $25, $c8
	db $b7, $c0, $21, $dc, $c8, $01, $06, $00, $3e, $00, $cd, $c7, $12, $21, $e2, $c8
	db $01, $08, $00, $3e, $00, $cd, $c7, $12, $3e, $00, $ea, $06, $c9, $c9, $fa, $25
	db $c8, $b7, $c0, $21, $01, $00, $cd, $e5, $45, $3e, $01, $ea, $05, $c9, $c9

VaultDepositGold::
	ld a, [wMenuSubStep]
	rst $00

VaultDepositGoldSteps::
	dw VaultDepositGoldStart
	dw VaultDepositGoldShow
	dw VaultDepositGoldInput
	dw VaultDepositGoldDoIt
	dw VaultDepositGoldDone

VaultDepositGoldStart::
	ld hl, $000a
	call PrintMenuText9
	ld a, $02
	ld [wConfirmChoice], a
	ld a, $00
	ld [wLinkRefused], a
	ld a, $00
	ld [wLinkPartnerChoice], a
	ld a, $00
	ld [wListLastRows], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


VaultDepositGoldShow::
	ld a, [wTextState]
	or a
	ret nz

	call DrawDepositGoldWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawDepositGoldWindow::
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	ld a, $02
	ld [wTextGroup], a
	ld a, $55
	ld [wTextIndex], a
	ld hl, $8a00
	ld de, $0401
	call DrawTextTiles9
	ld de, $71ca
	call DrawWindowLayout9
	ld de, $71e7
	call DrawWindowLayout9
	ld a, [wBankedGold]
	ldh [hNumber], a
	ld a, [$ca4f]
	ldh [$ffd6], a
	ld a, [$ca50]
	ldh [$ffd7], a
	ld hl, $016d
	call TilemapBufferAddr9
	call PrintNumber6
	call ResetCursorBlink9
	ld de, $548f
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawGoldEntry
	call CopyTilemapBufferToVram9
	ret


VaultDepositGoldInput::
	ld de, $548f
	ld hl, wConfirmChoice
	ld b, $03
	call UpdateGoldEntry
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_5474

	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	call CopyTilemapBufferToVram9
	ld hl, $0003
	call PrintMenuText9
	ld a, $04
	ld [wMenuStep], a
	jr jr_009_548e

jr_009_5474:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_548e

	ld hl, wLinkRefused
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_009_548e

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_009_548e:
jr_009_548e:
	ret


	db $8e, $00, $8f, $00, $90, $00, $91, $00, $92, $00, $ff, $ff

VaultDepositGoldDoIt::
	ld hl, wLinkRefused
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc [hl]
	ld hl, $000b
	jr c, jr_009_54f7

	ld hl, wLinkRefused
	ld a, [wBankedGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [$ca4f]
	adc [hl]
	ld d, a
	inc hl
	ld a, [$ca50]
	adc [hl]
	ld c, a
	ld a, e
	sub $40
	ld a, d
	sbc $42
	ld a, c
	sbc $0f
	ld hl, $000c
	jr nc, jr_009_54f7

	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
	call SpendGold
	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
	call AddBankGold
	call DrawDepositGoldWindow
	ld hl, $000d

jr_009_54f7:
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


VaultDepositGoldDone::
	ld a, [wTextState]
	or a
	ret nz

	call RestoreTilemapBuffer9
	call DrawVaultMainMenu
	call CopyTilemapBufferToVram9
	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuStep], a
	ret


VaultTakeItem::
	ld a, [wMenuSubStep]
	rst $00

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

VaultTakeItemStart::
	ld hl, wStoredItems
	ld b, $28
	call CountItemsN
	ld a, c
	or a
	ld hl, $0011
	jr z, jr_009_5557

	ld hl, wBagItems
	call CountItems40
	ld a, c
	cp $14
	ld hl, $0012
	jr nc, jr_009_5557

	ld hl, wMenuSubStep
	inc [hl]
	ld hl, $0010
	call PrintMenuText9
	ret


jr_009_5557:
	call PrintMenuText9
	ld a, $08
	ld [wMenuSubStep], a
	ret


VaultTakeItemShowList::
	ld a, [wTextState]
	or a
	ret nz

	call BuildStoredItemList
	call CountVaultList
	call LoadItemNameTiles
	call DrawVaultTakeWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawVaultTakeWindow::
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	ld de, $7153
	call DrawWindowLayout9
	call ResetCursorBlink9
	ld de, $5652
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
	call CopyTilemapBufferToVram9
	ret


BuildStoredItemList::
	call CompactStoredItems
	ld hl, wBreedParent1
	ld bc, $0030
	xor a
	call FillMemory
	ld hl, wSceneObjects
	ld bc, $0028
	xor a
	call FillMemory
	ld de, wStoredItems
	ld b, $28

jr_009_55b4:
	ld a, [de]
	or a
	jr z, jr_009_55ca

	cp $ff
	jr z, jr_009_55ca

	inc de
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	inc [hl]
	dec b
	jr nz, jr_009_55b4

jr_009_55ca:
	ld hl, $d666
	ld de, wSceneObjects
	ld b, $2f
	ld c, $01

jr_009_55d4:
	ld a, [hli]
	or a
	jr z, jr_009_55db

	ld a, c
	ld [de], a
	inc de

jr_009_55db:
	inc c
	dec b
	jr nz, jr_009_55d4

	ret


VaultTakeListInput::
	ld de, $5652
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call UpdatePagedList9
	pop af
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_009_5601

jr_009_5601:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_009_560b

	call LoadItemNameTiles

jr_009_560b:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_563b

	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	call CopyTilemapBufferToVram9
	ld hl, $000e
	call PrintMenuText9
	ld a, $04
	ld [wMenuStep], a
	jr jr_009_5651

jr_009_563b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_5651

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	ld a, $01
	ld [wMenuChoice3], a

Jump_009_5651:
jr_009_5651:
	ret


	db $72, $01, $89, $00, $c9, $00, $09, $01, $49, $01, $ff, $ff

VaultTakeAskQuantity::
	ld hl, $0013
	call PrintMenuText9
	ld a, $01
	ld [wConfirmChoice2], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


VaultTakeShowQuantity::
	ld a, [wTextState]
	or a
	ret nz

	call DrawVaultTakeQuantity
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawVaultTakeQuantity::
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	ld de, $7153
	call DrawWindowLayout9
	ld de, $5652
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListFrame9
	ld de, $7044
	call DrawWindowLayout9
	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	ld hl, wBreedParent1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call TilemapBufferAddr9
	call PrintNumber2
	call ResetCursorBlink9
	ld de, $5729
	ld hl, wConfirmChoice2
	ld b, $02
	ld a, [hl]
	call DrawNumberEntry
	call CopyTilemapBufferToVram9
	ret


VaultTakeQuantityInput::
	ld de, $5729
	ld hl, wBreedParent1
	ld a, [wItemId]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, wConfirmChoice2
	call UpdateNumberEntry
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_5717

	call DrawVaultTakeWindow
	ld hl, $0010
	call PrintMenuText9
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_009_5728

jr_009_5717:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_5728

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_009_5728:
jr_009_5728:
	ret


	db $61, $01, $62, $01, $ff, $ff

VaultTakeDoIt::
	ld hl, wBagItems
	call CountItems40
	ld a, [wMenuChoice3]
	add c
	cp $15
	ld hl, $0014
	jr nc, jr_009_5753

	ld a, [wMenuChoice3]
	ld b, a

jr_009_5744:
	push bc
	call TakeStoredItem
	ld hl, far_AddItemToBag
	rst $10
	pop bc
	dec b
	jr nz, jr_009_5744

	ld hl, $0015

jr_009_5753:
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


VaultTakeDone::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wConfirmChoice
	ld bc, $0006
	ld a, $00
	call FillMemory
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld a, $00
	ld [wMenuSubStep], a
	ret


VaultTakeFinish::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuStep], a
	ret


VaultWithdrawGold::
	ld a, [wMenuSubStep]
	rst $00

VaultWithdrawGoldSteps::
	dw VaultWithdrawGoldStart
	dw VaultWithdrawGoldShow
	dw VaultWithdrawGoldInput
	dw VaultWithdrawGoldDoIt
	dw VaultWithdrawGoldDone

VaultWithdrawGoldStart::
	ld hl, wBankedGold
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr nz, jr_009_57b0

	ld hl, $000f
	call PrintMenuText9
	ld a, $04
	ld [wMenuSubStep], a
	ret


jr_009_57b0:
	ld hl, $0016
	call PrintMenuText9
	ld a, $02
	ld [wConfirmChoice], a
	ld a, $00
	ld [wLinkRefused], a
	ld a, $00
	ld [wLinkPartnerChoice], a
	ld a, $00
	ld [wListLastRows], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


VaultWithdrawGoldShow::
	ld a, [wTextState]
	or a
	ret nz

	call DrawWithdrawGoldWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawWithdrawGoldWindow::
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	ld a, $02
	ld [wTextGroup], a
	ld a, $55
	ld [wTextIndex], a
	ld hl, $8a00
	ld de, $0401
	call DrawTextTiles9
	ld de, $71ca
	call DrawWindowLayout9
	ld de, $71e7
	call DrawWindowLayout9
	ld a, [wBankedGold]
	ldh [hNumber], a
	ld a, [$ca4f]
	ldh [$ffd6], a
	ld a, [$ca50]
	ldh [$ffd7], a
	ld hl, $016d
	call TilemapBufferAddr9
	call PrintNumber6
	call ResetCursorBlink9
	ld de, $5882
	ld hl, wConfirmChoice
	ld b, $02
	ld a, [hl]
	call DrawGoldEntry
	call CopyTilemapBufferToVram9
	ret


VaultWithdrawGoldInput::
	ld de, $5882
	ld hl, wConfirmChoice
	ld b, $03
	call UpdateGoldEntry
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_5867

	ld a, $02
	ld [wTextGroup], a
	ld a, $0c
	ld [wTextIndex], a
	ld hl, $8a40
	ld de, $0c01
	call DrawTextTiles9
	call RestoreTilemapBuffer9
	call DrawVaultWhatMenu
	call CopyTilemapBufferToVram9
	ld hl, $000e
	call PrintMenuText9
	ld a, $04
	ld [wMenuStep], a
	jr jr_009_5881

jr_009_5867:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_5881

	ld hl, wLinkRefused
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_009_5881

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]

Jump_009_5881:
jr_009_5881:
	ret


	db $8e, $00, $8f, $00, $90, $00, $91, $00, $92, $00, $ff, $ff

VaultWithdrawGoldDoIt::
	ld hl, wLinkRefused
	ld a, [wBankedGold]
	sub [hl]
	inc hl
	ld a, [$ca4f]
	sbc [hl]
	inc hl
	ld a, [$ca50]
	sbc [hl]
	ld hl, $0017
	jr c, jr_009_58ea

	ld hl, wLinkRefused
	ld a, [wGold]
	add [hl]
	ld e, a
	inc hl
	ld a, [$ca4c]
	adc [hl]
	ld d, a
	inc hl
	ld a, [$ca4d]
	adc [hl]
	ld c, a
	ld a, e
	sub $a0
	ld a, d
	sbc $86
	ld a, c
	sbc $01
	ld hl, $0018
	jr nc, jr_009_58ea

	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
	call TakeBankGold
	ld a, [wLinkRefused]
	ld l, a
	ld a, [wLinkPartnerChoice]
	ld h, a
	ld a, [wListLastRows]
	ld e, a
	call AddGold
	call DrawWithdrawGoldWindow
	ld hl, $0019

jr_009_58ea:
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


VaultWithdrawGoldDone::
	ld a, [wTextState]
	or a
	ret nz

	call RestoreTilemapBuffer9
	call DrawVaultMainMenu
	call CopyTilemapBufferToVram9
	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuStep], a
	ret


UpdateGoldEntry::
	res 7, [hl]
	push de
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_009_5920

	ld a, $10
	ld [wCursorBlink], a
	call GoldEntryDigitDown
	jr jr_009_5954

jr_009_5920:
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_009_5931

	ld a, $10
	ld [wCursorBlink], a
	call GoldEntryDigitUp
	jr jr_009_5954

jr_009_5931:
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_009_5941

	ld a, [hl]
	dec a
	cp b
	jr c, jr_009_594f

	dec b
	ld a, b
	jr jr_009_594f

jr_009_5941:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_009_5956

	ld a, [hl]
	inc a
	cp b
	jr c, jr_009_594f

	ld a, $00

jr_009_594f:
	ld [hl], a
	xor a
	ld [wCursorBlink], a

jr_009_5954:
	push hl
	pop hl

jr_009_5956:
	ld a, [wJoyRepeat]
	bit 0, a
	jr z, jr_009_595f

	set 7, [hl]

jr_009_595f:
	pop de
	ld a, [hl]
	call DrawGoldEntry
	ret


GoldEntryDigitDown::
	push de
	ld a, [hl]
	push hl
	ld a, [wLinkRefused]
	ldh [hNumber], a
	ld a, [wLinkPartnerChoice]
	ldh [$ffd6], a
	ld a, [wListLastRows]
	ldh [$ffd7], a
	ld hl, wNumberBackup
	call PrintNumber5Zeros
	pop hl
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	and $0f
	dec a
	ld [de], a
	cp $ff
	jr nz, jr_009_5994

	ld a, $09
	ld [de], a

jr_009_5994:
	call GoldEntryDigitsToValue
	pop de
	ret


GoldEntryDigitsToValue::
	push hl
	ld bc, $2710
	ld a, [wNumberBackup]
	and $0f
	call Multiply24
	ld a, l
	ld [wLinkRefused], a
	ld a, h
	ld [wLinkPartnerChoice], a
	ld a, e
	ld [wListLastRows], a
	ld bc, $03e8
	ld a, [$c0a1]
	and $0f
	call Multiply24
	ld a, [wLinkRefused]
	add l
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc h
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc e
	ld [wListLastRows], a
	ld bc, $0064
	ld a, [$c0a2]
	and $0f
	call Multiply24
	ld a, [wLinkRefused]
	add l
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc h
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc e
	ld [wListLastRows], a
	ld bc, $000a
	ld a, [wLineUpOrder]
	and $0f
	call Multiply24
	ld a, [wLinkRefused]
	add l
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc h
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc e
	ld [wListLastRows], a
	ld a, [$c0a4]
	and $0f
	ld l, a
	ld a, [wLinkRefused]
	add l
	ld [wLinkRefused], a
	ld a, [wLinkPartnerChoice]
	adc $00
	ld [wLinkPartnerChoice], a
	ld a, [wListLastRows]
	adc $00
	ld [wListLastRows], a
	pop hl
	ret


GoldEntryDigitUp::
	push de
	ld a, [hl]
	push hl
	ld a, [wLinkRefused]
	ldh [hNumber], a
	ld a, [wLinkPartnerChoice]
	ldh [$ffd6], a
	ld a, [wListLastRows]
	ldh [$ffd7], a
	ld hl, wNumberBackup
	call PrintNumber5Zeros
	pop hl
	ld de, $c0a1
	ld a, [hl]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	and $0f
	inc a
	ld [de], a
	cp $0a
	jr nz, jr_009_5a62

	ld a, $00
	ld [de], a

jr_009_5a62:
	call GoldEntryDigitsToValue
	pop de
	ret


DrawGoldEntry::
	ld c, a
	push de
	push bc
	ld a, [wLinkRefused]
	ldh [hNumber], a
	ld a, [wLinkPartnerChoice]
	ldh [$ffd6], a
	ld a, [wListLastRows]
	ldh [$ffd7], a
	ld hl, wNumberBackup
	call PrintNumber5Zeros
	pop bc
	pop de
	bit 7, c
	jr nz, jr_009_5a95

	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
	pop af
	ld a, c
	ret nz

jr_009_5a95:
	ld c, a
	ld b, $00

jr_009_5a98:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_009_5ac2

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_5ac2

	ld a, $e6

jr_009_5ac2:
	cp $e0
	jr nz, jr_009_5ad3

	push hl
	ld a, b
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl

jr_009_5ad3:
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	inc b
	jr jr_009_5a98

CompactStoredItems::
	ld hl, wBreedParent1
	ld de, wStoredItems
	ld b, $28

jr_009_5af2:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_009_5af2

	ld hl, wStoredItems
	ld bc, $0028
	ld a, $ff
	call FillMemory
	ld hl, wBreedParent1
	ld de, wStoredItems
	ld b, $28

jr_009_5b0b:
	ld a, [hli]
	cp $ff
	jr z, jr_009_5b16

	cp $00
	jr z, jr_009_5b16

	ld [de], a
	inc de

jr_009_5b16:
	dec b
	jr nz, jr_009_5b0b

	ret


	db $fa, $5e, $da, $fe, $00, $c8, $fe, $ff, $c8, $21, $65, $ca, $06, $28, $7e, $fe
	db $00, $28, $0e, $fe, $ff, $28, $0a, $23, $05, $20, $f3, $3e, $ff, $ea, $5e, $da
	db $c9, $fa, $5e, $da, $77, $c9

TakeStoredItem::
	ld a, [wItemId]
	cp $00
	ret z

	cp $ff
	ret z

	ld hl, wStoredItems
	ld b, $28

jr_009_5b4e:
	ld a, [wItemId]
	cp [hl]
	jr z, jr_009_5b5e

	inc hl
	dec b
	jr nz, jr_009_5b4e

	ld a, $ff
	ld [wItemId], a
	ret


jr_009_5b5e:
	ld [hl], $ff
	call CompactStoredItems
	ret


ArenaEntryMenu::
	ld a, [wMenuStep]
	rst $00

ArenaEntrySteps::
	dw ArenaEntryInit
	dw ArenaEntryWait
	dw ArenaEntryOpen
	dw ArenaEntryRunOption
	dw ArenaEntryClose

ArenaEntryInit::
	ld hl, hScrollX
	call SnapToTile9
	ld hl, hScrollY
	call SnapToTile9
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
	call RestoreTilemapBuffer9
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
	ld hl, wMenuStep
	inc [hl]
	ret


ArenaEntryWait::
	ld hl, wMenuStep
	inc [hl]
	ret


ArenaEntryOpen::
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
	ld a, [wScriptBossIndex]
	and $03
	ld [wListCursor], a
	ld a, [wScriptBossIndex]
	cp $04
	ret c

	ld a, $01
	ld [wListPage], a
	ret


ArenaEntryRunOption::
	jp ArenaClassMenu


ArenaEntryClose::
	call RestoreTilemapBuffer9
	ld de, $2e07
	call DrawWindowLayout9
	call CopyTilemapBufferToVram9
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


ArenaClassMenu::
	ld a, [wMenuSubStep]
	rst $00

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

ArenaClassStart::
	call MarkClearedClasses
	ld hl, wMenuSubStep
	inc [hl]
	ret


MarkClearedClasses::
	ld hl, wSceneObjects
	ld bc, $0008
	ld a, $90
	call FillMemory
	ld a, [wScriptBossIndex]
	or a
	ret z

	ld b, a
	ld hl, wSceneObjects

jr_009_5c3c:
	ld [hl], $ac
	inc hl
	dec b
	jr nz, jr_009_5c3c

	ret


ArenaClassShowList::
	ld a, [wTextState]
	or a
	ret nz

	call LoadClassLetterTiles
	call DrawArenaClassWindow
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawArenaClassWindow::
	call RestoreTilemapBuffer9
	ld de, $2e07
	call DrawWindowLayout9
	ld de, $74a0
	call DrawWindowLayout9
	ld de, $6f1f
	call DrawWindowLayout9
	call DrawEntryFees
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call TilemapBufferAddr9
	call PrintNumber5
	call ResetCursorBlink9
	ld de, $5da2
	ld b, $04
	ld c, $04
	ld hl, wListCursor
	call DrawListFrame9
	call CopyTilemapBufferToVram9
	ret


LoadClassLetterTiles::
	ld de, $5d1b
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call LoadCharSlot
	call LoadCharSlot
	call LoadCharSlot
	call LoadCharSlot
	ld de, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8840
	call LoadCharSlot
	call LoadCharSlot
	call LoadCharSlot

LoadCharSlot::
	push de
	push hl
	ld a, [de]
	call DrawCharTile9
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


DrawEntryFees::
	ld de, $5d23
	ld a, [wListPage]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $00ab
	call DrawEntryFeeSlot
	call DrawEntryFeeSlot
	call DrawEntryFeeSlot

DrawEntryFeeSlot::
	push de
	push hl
	ld a, [de]
	ldh [hNumber], a
	inc de
	ld a, [de]
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	call TilemapBufferAddr9
	call PrintNumber5
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	inc de
	ret


	db $2a, $29, $28, $27, $26, $25, $24, $36, $00, $00, $0a, $00, $32, $00, $64, $00
	db $f4, $01, $e8, $03, $88, $13, $10, $27

ArenaClassListInput::
	ld de, $5da4
	ld hl, wListCursor
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call UpdateMenuCursor9
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_009_5d51

	call LoadClassLetterTiles
	call DrawEntryFees
	call CopyTilemapBufferToVram9

jr_009_5d51:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_5d90

	ld hl, wSceneObjects
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $90
	jp z, Jump_009_5d81

	ld hl, $0006
	call PrintMenuText9
	ld a, $08
	ld [wMenuSubStep], a
	jr jr_009_5da1

Jump_009_5d81:
	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wMenuChoice3], a
	jr jr_009_5da1

Jump_009_5d90:
	ld a, [wJoyPressed]
	bit 1, a
	jp z, Jump_009_5da1

	ld a, $ff
	ld [wArenaRound], a
	ld hl, wMenuStep
	inc [hl]

Jump_009_5da1:
jr_009_5da1:
	ret


	db $8c, $01, $a2, $00, $e2, $00, $22, $01, $62, $01, $ff, $ff

ArenaCheckFee::
	ld hl, $5d23
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wGold]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc $00
	jr nc, jr_009_5de1

	ld hl, $0005
	call PrintMenuText9
	ld a, $08
	ld [wMenuSubStep], a
	ret


jr_009_5de1:
	ld de, $5d1b
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
	ld hl, $0004
	call PrintMenuText9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ArenaShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6ed5
	call DrawWindowLayout9
	call ResetCursorBlink9
	ld de, $5ea1
	ld a, [wMenuChoice3]
	call DrawCursorAt9
	call CopyTilemapBufferToVram9
	ld hl, wMenuSubStep
	inc [hl]
	ret


ArenaYesNoInput::
	ld de, $5ea1
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_5e5b

jr_009_5e40:
	call DrawArenaClassWindow
	ld hl, $0001
	call PrintMenuText9
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_009_5ea0

jr_009_5e5b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_5ea0

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_009_5e40

	ld hl, $5d23
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld e, $00
	call SpendGold
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld [wArenaClass], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_009_5ea0:
jr_009_5ea0:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

ArenaEntryNext::
	ld hl, wMenuSubStep
	inc [hl]
	ret


ArenaEntryFinish::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuStep
	inc [hl]
	ret


ArenaEntryRefused::
	ld a, [wTextState]
	or a
	ret nz

	call DrawArenaClassWindow
	ld hl, $0001
	call PrintMenuText9
	ld a, $01
	ld [wMenuSubStep], a
	ret


GalleryMenu::
	ld a, [wMenuStep]
	rst $00

GallerySteps::
	dw GalleryInit
	dw GalleryOpen
	dw GalleryInput
	dw GalleryClose

GalleryInit::
	ld hl, hScrollX
	call SnapToTile9
	ld hl, hScrollY
	call SnapToTile9
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
	call ClearTilemapBuffer9
	call CopyTilemapBufferToVram9
	call ResetCursorBlink9
	ld a, $01
	ld [wMenuOverlay], a
	xor a
	ld [wPageToggle], a
	ld hl, wMenuStep
	inc [hl]
	ret


GalleryOpen::
	ld hl, wMenuStep
	inc [hl]
	call ClearTilemapBuffer9
	call BuildGalleryList
	call LoadGalleryPage
	call DrawGalleryFrame
	call CopyTilemapBufferToVram9
	ret


DrawGalleryFrame::
	ld de, $6cde
	call DrawWindowLayout9
	ld a, [wListLength]
	cp $09
	ret c

	ld hl, $0212
	call TilemapBufferAddr9
	ld [hl], $e7
	ret


LoadGalleryPage::
	ld de, wSceneObjects
	ld a, [wMenuChoice2]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9380
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	call LoadGalleryPicture
	ld de, wSceneObjects
	ld a, [wMenuChoice2]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8880
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	call LoadGalleryName
	ret


LoadGalleryPicture::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_009_5fc5

	ld a, $6f
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	ld de, $0901
	call DrawTextTiles9
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


jr_009_5fc5:
	push hl
	ld hl, $5fe4
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	pop hl
	call DecompressVRAM
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


	db $0f, $56, $10, $56, $11, $56, $12, $56, $13, $56, $14, $56, $15, $56, $16, $56
	db $17, $56, $18, $56, $19, $56, $1a, $56, $1b, $56, $1c, $56, $1d, $56, $1e, $56

LoadGalleryName::
	push de
	push hl
	ld a, [de]
	cp $ff
	ld a, $e0
	jr z, jr_009_6033

	ld a, [de]
	push de
	ld de, $607e
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	push bc
	ld a, [de]
	ld c, a
	ld b, $00
	push hl
	call TestEventFlag
	pop hl
	pop bc
	pop de
	ld a, $e0
	jr z, jr_009_6033

	ld a, [de]
	ld de, $608e
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]

jr_009_6033:
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	call DrawTextTiles9
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


BuildGalleryList::
	ld hl, wSceneObjects
	ld bc, $0010
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, $609e
	ld b, $00

jr_009_6060:
	push bc
	push de
	push hl
	ld a, [de]
	ld c, a
	ld b, $00
	call TestEventFlag
	pop hl
	pop de
	pop bc
	jr z, jr_009_6072

	ld [hl], b
	inc hl
	inc c

jr_009_6072:
	inc de
	inc b
	ld a, b
	cp $10
	jr nz, jr_009_6060

	ld a, c
	ld [wListLength], a
	ret


	db $10, $11, $12, $13, $14, $16, $17, $19, $1d, $1c, $1a, $1f, $20, $22, $23, $25
	db $09, $1c, $c4, $44, $66, $0a, $45, $c5, $2a, $58, $2b, $99, $ad, $43, $94, $9a
	db $00, $30, $30, $31, $31, $32, $32, $33, $33, $34, $34, $35, $35, $36, $36, $37

GalleryInput::
	ld de, $60f2
	ld hl, wLinkChoice
	ld c, $01
	ld a, [wListLength]
	cp $09
	jr c, jr_009_60bf

	ld c, $02

jr_009_60bf:
	ld b, $01
	ld a, [wMenuChoice2]
	push af
	call UpdatePagedList9
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, jr_009_60d2

	call LoadGalleryPage

jr_009_60d2:
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_009_60df

	ld hl, wMenuStep
	inc [hl]
	jr jr_009_60f1

jr_009_60df:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_009_60f1

	ld a, $59
	call QueueSound
	ld hl, wMenuStep
	inc [hl]
	jr jr_009_60f1

jr_009_60f1:
	ret


	db $12, $02, $ff, $ff, $ff, $ff, $ff, $ff

GalleryClose::
	call ClearTilemapBuffer9
	call CopyTilemapBufferToVram9
	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_0B_40CE
	rst $10
	call BuildStatusBar
	call DrawStatusBar
	ld hl, far_Call_06_4D5A
	rst $10
	xor a
	ld [wMenuOverlay], a
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


NameEntryMenu::
	ld a, [wMenuStep]
	cp $09
	jr nc, jr_009_6155

	cp $02
	jr c, jr_009_6155

	ld hl, hSpriteX
	ld a, $19
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $21
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, [wChosenMonPic]
	ld [hli], a
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_009_6149

	ld b, $01

jr_009_6149:
	ld a, b
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10

jr_009_6155:
	ld a, [wMenuStep]
	rst $00

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

NameEntryNext::
	ld hl, wMenuStep
	inc [hl]
	ret


NameEntryWaitFade::
	ld hl, wMenuStep
	inc [hl]
	ld a, [wFadeState]
	or a
	ret z

NameEntryInit::
	ld hl, hScrollX
	call SnapToTile9
	ld hl, hScrollY
	call SnapToTile9
	ld hl, wNameInput
	ld bc, $0010
	ld a, $9f
	call FillMemory
	call LoadCurrentName
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
	ld hl, $01c0
	call WindowBgAddr9
	call NextBgColumn9
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [$c83f], a
	call ClearTilemapBuffer9
	call CopyTilemapBufferToVram9
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
	ld de, $2e20
	ld hl, $8a00
	call DecompressVRAM
	ld a, [wChosenMonPic]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $6b
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $8500
	call DecompressVRAM
	call ResetCursorBlink9
	call DrawNameBuffer
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld hl, wMenuStep
	inc [hl]
	ret


LoadCurrentName::
	ld b, $08
	ld a, [wChosenMonName]
	ld l, a
	ld a, [$c8f3]
	ld h, a
	ld de, wNameInput
	call CopyNameToBuffer
	ld a, [wChosenMonPic]
	cp $00
	ret z

	ld a, [wNameInput]
	cp $9f
	ret nz

	ld a, [wChosenMonSpecies]
	ld l, a
	ld h, $07
	ld de, wTextArg0
	call CopySystemText
	ld hl, wTextArg0
	ld de, wNameInput

CopyNameToBuffer::
	ld a, [hli]
	cp $00
	ret z

	cp $f0
	ret z

	cp $9f
	ret z

	ld [de], a
	inc de
	dec b
	jr nz, CopyNameToBuffer

	ret


DrawNameBuffer::
	ld de, wNameInput
	ld hl, $9000
	call DrawNameTiles9
	call DrawNameCursor
	ret


NameEntryOpen::
	ld hl, wMenuStep
	inc [hl]
	call ClearTilemapBuffer9
	call DrawNameEntryScreen
	call DrawNameCursor
	call CopyTilemapBufferToVram9
	ret


DrawNameEntryScreen::
	ld a, [wChosenMonPic]
	or a
	jr z, jr_009_62e0

	ld a, [wChosenMonGender]
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
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	push bc
	ld hl, $8af0
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0101
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
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
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ld hl, $0064
	call TilemapBufferAddr9
	ld [hl], $af

jr_009_62e0:
	ld de, $7ca5
	call DrawWindowLayout9
	ld de, $7ccb
	ld a, [wConfirmChoice]
	or a
	jr nz, jr_009_62f2

	ld de, $7dc9

jr_009_62f2:
	call DrawWindowLayout9
	call ResetCursorBlink9
	call DrawKeyboardCursor
	ret


NameEntryInput::
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_009_6332

	ld a, [wMenuChoice2]
	cp $03
	jr c, jr_009_631e

	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	cp $11
	jp c, Jump_009_63f5

	ld a, $0d
	ld [wLinkChoice], a
	jp Jump_009_63f5


jr_009_631e:
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	cp $11
	jp c, Jump_009_63f5

	ld a, $10
	ld [wLinkChoice], a
	jp Jump_009_63f5


jr_009_6332:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_009_634d

	ld a, [wLinkChoice]
	inc a
	ld [wLinkChoice], a
	cp $11
	jp c, Jump_009_63f5

	ld a, $00
	ld [wLinkChoice], a
	jp Jump_009_63f5


jr_009_634d:
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_009_639d

	ld a, [wLinkChoice]
	cp $06
	jr c, jr_009_638b

	cp $0d
	jp nc, Jump_009_6374

	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	cp $05
	jp c, Jump_009_63f5

	ld a, $03
	ld [wMenuChoice2], a
	jp Jump_009_63f5


Jump_009_6374:
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	cp $05
	jr c, jr_009_63f5

	ld a, $04
	ld [wMenuChoice2], a
	ld a, $0d
	ld [wLinkChoice], a
	jr jr_009_63f5

jr_009_638b:
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	cp $05
	jr c, jr_009_63f5

	ld a, $04
	ld [wMenuChoice2], a
	jr jr_009_63f5

jr_009_639d:
	ld a, [wJoyRepeat]
	bit 7, a
	jp z, Jump_009_6460

	ld a, [wLinkChoice]
	cp $06
	jr c, jr_009_63e3

	cp $0d
	jr nc, jr_009_63c2

	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	cp $04
	jr c, jr_009_63f5

	ld a, $00
	ld [wMenuChoice2], a
	jr jr_009_63f5

jr_009_63c2:
	ld a, [wMenuChoice2]
	cp $02
	jr c, jr_009_63e3

	ld a, [wLinkChoice]
	ld a, $0d
	ld [wLinkChoice], a
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	cp $05
	jr c, jr_009_63f5

	ld a, $00
	ld [wMenuChoice2], a
	jr jr_009_63f5

jr_009_63e3:
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	cp $05
	jr c, jr_009_63f5

	ld a, $00
	ld [wMenuChoice2], a
	jr jr_009_63f5

Jump_009_63f5:
jr_009_63f5:
	xor a
	ld [wCursorBlink], a
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wLinkChoice]
	add l
	cp $4a
	jr nz, jr_009_641c

	ld a, $06
	ld [wLinkChoice], a
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_009_6460

	ld a, $0d
	ld [wLinkChoice], a
	jr jr_009_6460

jr_009_641c:
	cp $50
	jr nz, jr_009_6433

	ld a, $0d
	ld [wLinkChoice], a
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_009_6460

	ld a, $05
	ld [wLinkChoice], a
	jr jr_009_6460

jr_009_6433:
	cp $41
	jr z, jr_009_644d

	cp $42
	jr z, jr_009_644d

	cp $43
	jr z, jr_009_644d

	cp $52
	jr z, jr_009_644d

	cp $53
	jr z, jr_009_644d

	cp $54
	jr z, jr_009_644d

	jr jr_009_6460

jr_009_644d:
	ld a, $0a
	ld [wLinkChoice], a
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_009_6460

	ld a, $00
	ld [wLinkChoice], a
	jr jr_009_6460

Jump_009_6460:
jr_009_6460:
	call DrawKeyboardCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_64a9

Jump_009_646a:
	ld de, wNameInput
	ld a, [de]
	cp $9f
	jp z, Jump_009_6606

jr_009_6473:
	inc de
	ld a, [de]
	cp $9f
	jr nz, jr_009_6473

	dec de
	ld a, [wNameCleared]
	cp $00
	jp nz, Jump_009_64a0

	ld a, [wChosenMonPic]
	cp $00
	jp nz, Jump_009_64a0

	ld a, $01
	ld [wNameCleared], a
	ld a, $9f
	ld [wNameInput], a
	ld [$c0c9], a
	ld [$c0ca], a
	ld [$c0cb], a
	jp Jump_009_64a3


Jump_009_64a0:
	ld a, $9f
	ld [de], a

Jump_009_64a3:
	call DrawNameBuffer
	jp Jump_009_6606


jr_009_64a9:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_65f3

	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wLinkChoice]
	add l
	cp $51
	jr nz, jr_009_64c8

	ld hl, wMenuStep
	inc [hl]
	jp Jump_009_6606


jr_009_64c8:
	cp $40
	jp z, Jump_009_646a

	cp $1e
	jr nz, jr_009_64d6

	ld a, $0d
	ld [hl], a
	jr jr_009_6525

jr_009_64d6:
	cp $1f
	jr nz, jr_009_64df

	ld a, $0e
	ld [hl], a
	jr jr_009_6525

jr_009_64df:
	cp $20
	jr nz, jr_009_64e8

	ld a, $0f
	ld [hl], a
	jr jr_009_6525

jr_009_64e8:
	cp $21
	jr nz, jr_009_64f1

	ld a, $10
	ld [hl], a
	jr jr_009_6525

jr_009_64f1:
	cp $2f
	jr nz, jr_009_64fa

	ld a, $1e
	ld [hl], a
	jr jr_009_6525

jr_009_64fa:
	cp $30
	jr nz, jr_009_6503

	ld a, $1f
	ld [hl], a
	jr jr_009_6525

jr_009_6503:
	cp $0d
	jr nz, jr_009_650c

	ld a, $20
	ld [hl], a
	jr jr_009_6525

jr_009_650c:
	cp $0e
	jr nz, jr_009_6515

	ld a, $21
	ld [hl], a
	jr jr_009_6525

jr_009_6515:
	cp $0f
	jr nz, jr_009_651e

	ld a, $2f
	ld [hl], a
	jr jr_009_6525

jr_009_651e:
	cp $10
	jr nz, jr_009_6525

	ld a, $30
	ld [hl], a

jr_009_6525:
	ld hl, $6607
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	add $e0
	ld l, a
	ld a, h
	adc $c4
	ld h, a
	push hl
	call CountNameLetters
	pop hl
	ld a, c
	cp $04
	jr nz, jr_009_655a

	ld a, $0d
	ld [wLinkChoice], a
	ld a, $04
	ld [wMenuChoice2], a
	ld a, [hl]
	cp $8d
	jr z, jr_009_6568

	cp $8e
	jr z, jr_009_6568

	jp Jump_009_6606


jr_009_655a:
	or a
	jr nz, jr_009_6568

	ld a, [hl]
	cp $8d
	jp z, Jump_009_6606

	cp $8e
	jp z, Jump_009_6606

jr_009_6568:
	ld de, wNameInput

jr_009_656b:
	ld a, [de]
	inc de
	cp $9f
	jr nz, jr_009_656b

	dec de
	ld a, [hl]
	cp $8d
	jr z, jr_009_657b

	cp $8e
	jr nz, jr_009_65b2

jr_009_657b:
	dec de
	ld a, [de]
	inc de
	cp $8d
	jp z, Jump_009_6606

	cp $8e
	jr z, jr_009_6606

	push hl
	ld a, c
	ld hl, wNameLetterRows
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	pop hl
	ld a, b
	cp $01
	jr z, jr_009_65b2

	ld a, [hl]
	cp $8e
	jr z, jr_009_6606

	ld a, b
	cp $03
	jr z, jr_009_65b2

	cp $06
	jr z, jr_009_65b2

	cp $09
	jr z, jr_009_65b2

	dec de
	ld a, [de]
	inc de
	cp $5a
	jr nz, jr_009_6606

jr_009_65b2:
	ld a, [hl]
	ld [de], a
	call DrawNameBuffer
	ld a, $59
	call QueueSound
	call CountNameLetters
	ld a, c
	ld hl, wNameLetterRows
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wLinkChoice]
	add l
	ld b, a
	ld a, $05
	call Divide8
	ld a, b
	pop hl
	ld [hl], a
	call CountNameLetters
	ld a, c
	cp $04
	jr nz, jr_009_6606

	ld a, $0d
	ld [wLinkChoice], a
	ld a, $04
	ld [wMenuChoice2], a
	jr jr_009_6606

Jump_009_65f3:
	ld a, [wJoyPressed]
	bit 3, a
	jr z, jr_009_6606

	ld a, $0d
	ld [wLinkChoice], a
	ld a, $04
	ld [wMenuChoice2], a
	jr jr_009_6606

Jump_009_6606:
jr_009_6606:
	ret


	db $e1, $00, $e2, $00, $e3, $00, $e4, $00, $e5, $00, $e6, $00, $e7, $00, $e8, $00
	db $e9, $00, $ea, $00, $eb, $00, $ec, $00, $ed, $00, $ef, $00, $f0, $00, $f1, $00
	db $f2, $00, $21, $01, $22, $01, $23, $01, $24, $01, $25, $01, $26, $01, $27, $01
	db $28, $01, $29, $01, $2a, $01, $2b, $01, $2c, $01, $2d, $01, $2f, $01, $30, $01
	db $31, $01, $32, $01, $61, $01, $62, $01, $63, $01, $64, $01, $65, $01, $66, $01
	db $67, $01, $68, $01, $69, $01, $6a, $01, $6b, $01, $6c, $01, $6d, $01, $6f, $01
	db $70, $01, $71, $01, $72, $01, $a1, $01, $a2, $01, $a3, $01, $a4, $01, $a5, $01
	db $a6, $01, $a7, $01, $a8, $01, $a9, $01, $aa, $01, $ab, $01, $ac, $01, $ad, $01
	db $af, $01, $b0, $01, $b1, $01, $b2, $01, $e1, $01, $e2, $01, $e3, $01, $e4, $01
	db $e5, $01, $e6, $01, $e7, $01, $e8, $01, $e9, $01, $ea, $01, $eb, $01, $ec, $01
	db $ed, $01, $ef, $01, $f0, $01, $f1, $01, $f2, $01, $ff, $ff

NameEntryCheckName::
	xor a
	ld [wCursorBlink], a
	call DrawKeyboardCursor
	ld a, [wNameInput]
	cp $9f
	jr nz, jr_009_66ca

	call PickDefaultName
	call PadNameBuffer
	call DrawNameBuffer

jr_009_66ca:
	call CheckForbiddenName
	jr c, jr_009_66d9

	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr jr_009_66ec

jr_009_66d9:
	ld hl, $020a
	call PrintSystemText
	ld de, $2e07
	call DrawWindowLayout9
	call CopyTilemapBufferToVram9
	ld hl, wMenuStep
	inc [hl]

jr_009_66ec:
	ret


NameEntryRejected::
	ld a, [wTextState]
	or a
	ret nz

	call DrawNameBuffer
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ret


NameEntryAskConfirm::
	ld a, [wChosenMonPic]
	cp $00
	jr z, jr_009_6728

	ld a, [wChosenMonSpecies]
	ld l, a
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
	ld hl, wTextArg1

jr_009_6718:
	ld a, [hli]
	cp $f0
	jr nz, jr_009_6718

	dec hl
	ld a, [wChosenMonGender]
	and $01
	add $a7
	ld [hli], a
	ld [hl], $f0

jr_009_6728:
	ld hl, wTextArg0
	ld de, wNameInput
	ld b, $08

jr_009_6730:
	ld a, [de]
	cp $9f
	jr z, jr_009_673a

	ld [hli], a
	inc de
	dec b
	jr nz, jr_009_6730

jr_009_673a:
	ld a, $00
	ld [wNameCleared], a
	ld [hl], $f0
	ld hl, $0209
	ld a, [wChosenMonPic]
	cp $00
	jr z, jr_009_6756

	call CheckNameTaken
	ld hl, $0245
	jr c, jr_009_6756

	ld hl, $020f

jr_009_6756:
	call PrintSystemText
	ld de, $2e07
	call DrawWindowLayout9
	call CopyTilemapBufferToVram9
	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuChoice3], a
	ret


NameEntryShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6eb0
	call DrawWindowLayout9
	call ResetCursorBlink9
	ld de, $67d7
	ld a, [wMenuChoice3]
	call DrawCursorAt9
	call CopyTilemapBufferToVram9
	ld hl, wMenuStep
	inc [hl]
	ret


NameEntryYesNoInput::
	ld de, $67d7
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateMenuCursor9
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_009_67be

jr_009_67a1:
	call DrawNameBuffer
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	ld hl, wMenuStep
	dec [hl]
	jr jr_009_67d6

jr_009_67be:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_009_67d6

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_009_67a1

	ld hl, wMenuStep
	inc [hl]

Jump_009_67d6:
jr_009_67d6:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

NameEntryFinish::
	ld a, [wChosenMonName]
	ld l, a
	ld a, [$c8f3]
	ld h, a
	ld bc, $0008
	ld a, $f0
	call FillMemory
	ld a, [wChosenMonName]
	ld l, a
	ld a, [$c8f3]
	ld h, a
	ld de, wNameInput
	ld b, $08

jr_009_67fa:
	ld a, [de]
	cp $9f
	jr z, jr_009_6804

	ld [hli], a
	inc de
	dec b
	jr nz, jr_009_67fa

jr_009_6804:
	ld hl, wFieldFlags
	bit 7, [hl]
	jr nz, jr_009_6812

	ld a, [wScriptMenu]
	cp $ff
	jr z, jr_009_687a

jr_009_6812:
	call ClearTilemapBuffer9
	call CopyTilemapBufferToVram9
	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_0B_40CE
	rst $10
	call BuildStatusBar
	call DrawStatusBar
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_009_6832

	ld hl, far_Call_06_4D5A
	rst $10
	jr jr_009_687a

jr_009_6832:
	ld de, $2e15
	ld hl, $8500
	call DecompressVRAM
	ld de, $2e16
	ld hl, $8540
	call DecompressVRAM
	ld de, $2e17
	ld hl, $8580
	call DecompressVRAM
	ld de, $2e18
	ld hl, $85c0
	call DecompressVRAM
	ld de, $2e19
	ld hl, $8600
	call DecompressVRAM
	ld de, $2e1a
	ld hl, $8640
	call DecompressVRAM
	ld de, $2e1b
	ld hl, $8680
	call DecompressVRAM
	ld de, $2e1c
	ld hl, $86c0
	call DecompressVRAM

jr_009_687a:
	ld hl, wFieldFlags
	bit 7, [hl]
	jr nz, jr_009_6888

	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


jr_009_6888:
	ld hl, wFieldFlags
	res 7, [hl]
	ret


PickDefaultName::
	ld a, [wChosenMonPic]
	cp $00
	jr nz, jr_009_68aa

	ld a, $d3
	ld [wNameInput], a
	ld a, $d4
	ld [$c0c9], a
	ld a, $d5
	ld [$c0ca], a
	ld a, $d6
	ld [$c0cb], a
	ret


jr_009_68aa:
	call Random
	ld a, [wChosenMonPic]
	sub $10
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	ld c, a
	ld a, [wRandomHigh]
	and $07
	swap c
	or c
	ld c, a
	ld a, [wChosenMonGender]
	and $01
	add a
	add a
	add a
	add c
	ld l, a
	ld h, $03
	ld de, wNameInput
	call CopySystemText
	ret


PadNameBuffer::
	ld hl, wNameInput
	ld b, $10

jr_009_68de:
	ld a, [hl]
	cp $f0
	jr z, jr_009_68e8

	inc hl
	dec b
	jr nz, jr_009_68de

	ret


jr_009_68e8:
	ld a, $9f
	ld [hli], a
	dec b
	jr nz, jr_009_68e8

	ret


CheckForbiddenName::
	ld hl, wNameInput
	ld a, [hli]
	cp [hl]
	jr nz, jr_009_6904

	inc hl
	cp [hl]
	jr nz, jr_009_6904

	inc hl
	cp [hl]
	jr nz, jr_009_6904

	inc hl
	ld a, [hl]
	cp $9f
	jr z, jr_009_6917

jr_009_6904:
	ld hl, $6985

jr_009_6907:
	ld de, wNameInput
	ld b, $08
	push hl

jr_009_690d:
	ld a, [de]
	cp [hl]
	inc hl
	inc de
	jr nz, jr_009_6919

	dec b
	jr nz, jr_009_690d

	pop hl

jr_009_6917:
	scf
	ret


jr_009_6919:
	pop hl
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $ff
	jr nz, jr_009_6907

	scf
	ccf
	ret


CheckNameTaken::
	ld c, $00

jr_009_692c:
	ld a, c
	push bc
	ld hl, wMonsters
	call MonsterField
	pop bc
	ld a, [hl]
	or a
	jr z, jr_009_6982

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [wChosenMonName]
	ld e, a
	ld a, [$c8f3]
	ld d, a
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld a, d
	or e
	jr z, jr_009_697c

	ld de, wNameInput
	ld b, $08

jr_009_6958:
	ld a, [de]
	cp $9f
	jr z, jr_009_696f

	cp $f0
	jr z, jr_009_696f

	cp $00
	jr z, jr_009_696f

	cp [hl]
	inc hl
	inc de
	jr nz, jr_009_697c

	dec b
	jr nz, jr_009_6958

jr_009_696d:
	scf
	ret


jr_009_696f:
	ld a, [hl]
	cp $9f
	jr z, jr_009_696d

	cp $f0
	jr z, jr_009_696d

	cp $00
	jr z, jr_009_696d

jr_009_697c:
	inc c
	ld a, c
	cp $14
	jr nz, jr_009_692c

jr_009_6982:
	scf
	ccf
	ret


	db $34, $55, $42, $8e, $9f, $9f, $9f, $9f, $34, $55, $42, $8e, $2d, $9f, $9f, $9f
	db $34, $55, $34, $55, $9f, $9f, $9f, $9f, $28, $43, $55, $2d, $9f, $9f, $9f, $9f
	db $43, $55, $2d, $9f, $9f, $9f, $9f, $9f, $28, $46, $2d, $9f, $9f, $9f, $9f, $9f
	db $31, $36, $2b, $30, $9f, $9f, $9f, $9f, $68, $6d, $62, $67, $9f, $9f, $9f, $9f
	db $26, $55, $2d, $9f, $9f, $9f, $9f, $9f, $2a, $55, $33, $43, $9f, $9f, $9f, $9f
	db $62, $9f, $9f, $9f, $9f, $9f, $9f, $9f, $62, $62, $9f, $9f, $9f, $9f, $9f, $9f
	db $62, $62, $62, $9f, $9f, $9f, $9f, $9f, $62, $62, $62, $62, $9f, $9f, $9f, $9f
	db $ff

DrawKeyboardCursor::
	ld a, [wMenuChoice2]
	ld c, $11
	call Multiply
	ld a, [wLinkChoice]
	add l
	ld de, $6607
	ld c, a
	bit 7, a
	jr nz, jr_009_6a1a

	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
	pop af
	ld a, c
	ret nz

jr_009_6a1a:
	ld c, a
	ld b, $00

Jump_009_6a1d:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_009_6a4d

	ld a, $a0
	bit 7, c
	jr nz, jr_009_6a4d

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_6a4d

	ld a, $a0

jr_009_6a4d:
	ldh [$ffd7], a
	ld a, b
	cp $41
	jr z, jr_009_6a7f

	cp $42
	jr z, jr_009_6a7f

	cp $43
	jr z, jr_009_6a7f

	cp $52
	jr z, jr_009_6a7f

	cp $53
	jr z, jr_009_6a7f

	cp $54
	jr z, jr_009_6a7f

	call PutKeyboardCursorTile
	ld a, b
	cp $40
	jr z, jr_009_6a76

	cp $51
	jr z, jr_009_6a79

	jr jr_009_6a7f

jr_009_6a76:
	call KeyboardCursorNextTile

jr_009_6a79:
	call KeyboardCursorNextTile
	call KeyboardCursorNextTile

jr_009_6a7f:
	inc b
	jp Jump_009_6a1d


KeyboardCursorNextTile::
	push af
	ld hl, hNumber
	inc [hl]
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	pop af

PutKeyboardCursorTile::
	ldh a, [$ffd7]
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


CountNameLetters::
	ld hl, wNameInput
	ld b, $08
	ld c, $00

jr_009_6ab4:
	ld a, [hli]
	dec b
	ret z

	inc de
	cp $8d
	jr z, jr_009_6ab4

	cp $8e
	jr z, jr_009_6ab4

	cp $9f
	jr z, jr_009_6ab4

	inc c
	jr jr_009_6ab4

	db $c9

DrawNameCursor::
	call CountNameLetters
	ld de, $6b06
	ld b, $00

jr_009_6ad0:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call WindowBgAddrWrapped9
	pop bc
	pop de
	ld a, c
	cp b
	ld a, $e0
	jr nz, jr_009_6aef

	ld a, $a0

jr_009_6aef:
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	inc b
	jr jr_009_6ad0

	db $68, $00, $69, $00, $6a, $00, $6b, $00, $ff, $ff, $00, $2f, $40, $31, $40, $31
	db $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $40, $31
	db $40, $31, $40, $31, $40, $31, $40, $31, $40, $31, $01, $2f, $02, $2f, $03, $2f
	db $04, $2f, $05, $2f, $06, $2f, $07, $2f, $08, $2f, $09, $2f, $0a, $2f, $0b, $2f
	db $0c, $2f, $0d, $2f, $0e, $2f, $0f, $2f, $10, $2f, $00, $38, $01, $38, $02, $38
	db $03, $38, $04, $38, $05, $38, $06, $38, $07, $38, $08, $38, $09, $38, $0a, $38
	db $0b, $38, $0c, $38, $0d, $38, $0e, $38, $0f, $38, $10, $38, $11, $38, $12, $38
	db $13, $38, $14, $38, $15, $38, $16, $38, $17, $38, $18, $38, $19, $38, $1a, $38
	db $1b, $38, $1c, $38, $1d, $38, $1e, $38, $1f, $38, $20, $38, $21, $38, $22, $38
	db $23, $38, $24, $38, $25, $38, $26, $38, $27, $38, $28, $38, $29, $38, $2a, $38
	db $2b, $38, $2c, $38, $2d, $38, $2e, $38, $2f, $38, $30, $38, $31, $38, $32, $38
	db $33, $38, $34, $38, $35, $38, $36, $38, $37, $38, $38, $38, $39, $38, $3a, $38
	db $3b, $38, $3c, $38, $3d, $38, $3e, $38, $3f, $38, $40, $38, $41, $38, $42, $38
	db $43, $38, $44, $38, $45, $38, $46, $38, $47, $38, $00, $39, $01, $39, $02, $39
	db $03, $39, $04, $39, $05, $39, $06, $39, $07, $39, $08, $39, $09, $39, $0a, $39
	db $0b, $39, $0c, $39, $0d, $39, $0e, $39, $0f, $39, $10, $39, $11, $39, $12, $39
	db $13, $39, $14, $39, $15, $39, $16, $39, $17, $39, $18, $39, $19, $39, $1a, $39
	db $1b, $39, $1c, $39, $1d, $39, $1e, $39, $1f, $39, $20, $39, $21, $39, $22, $39
	db $23, $39, $24, $39, $25, $39, $26, $39, $27, $39, $28, $39, $29, $39, $2a, $39
	db $2b, $39, $2c, $39, $2d, $39, $2e, $39, $2f, $39, $30, $39, $31, $39, $32, $39
	db $33, $39, $34, $39, $35, $39, $36, $39, $37, $39, $38, $39, $39, $39, $3a, $39
	db $3b, $39, $3c, $39, $3d, $39, $3e, $39, $3f, $39, $40, $39, $41, $39, $42, $39
	db $43, $39, $44, $39, $45, $39, $46, $39, $47, $39, $00, $3a, $01, $3a, $02, $3a
	db $03, $3a, $04, $3a, $05, $3a, $06, $3a, $07, $3a, $08, $3a, $09, $3a, $0a, $3a
	db $0b, $3a, $0c, $3a, $0d, $3a, $0e, $3a, $0f, $3a, $10, $3a, $11, $3a, $12, $3a
	db $13, $3a, $14, $3a, $15, $3a, $16, $3a, $17, $3a, $18, $3a, $19, $3a, $1a, $3a
	db $1b, $3a, $1c, $3a, $1d, $3a, $1e, $3a, $1f, $3a, $20, $3a, $21, $3a, $22, $3a
	db $23, $3a, $24, $3a, $25, $3a, $26, $3a, $27, $3a, $28, $3a, $29, $3a, $2a, $3a
	db $2b, $3a, $2c, $3a, $2d, $3a, $2e, $3a, $2f, $3a, $30, $3a, $31, $3a, $32, $3a
	db $33, $3a, $34, $3a, $35, $3a, $36, $3a, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef
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
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8
	db $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0
	db $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $0e
	db $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4
	db $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a7, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $0c, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $81, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
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
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $01, $fa
	db $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd, $d9, $40, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $88, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81
	db $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90
	db $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e
	db $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a4
	db $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8
	db $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $68, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81
	db $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90
	db $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e
	db $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $46, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $92, $98, $9c, $e3, $e0, $9c, $93, $93, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e3, $95, $91, $96, $e0, $9a, $e3, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $91, $94, $d5, $91, $96, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $e3, $90, $98, $90, $99, $d5
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $d6, $97, $d5, $d5, $e3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $a2, $95, $99, $e0, $e0, $e0, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb
	db $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94
	db $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81
	db $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85
	db $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89
	db $8a, $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb
	db $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9e, $90, $d6, $99, $d5, $98, $e4, $a0, $a1
	db $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $da
	db $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac, $ad, $ae, $af
	db $ff, $d8, $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0, $e0, $e0, $e0
	db $9f, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $84
	db $e0, $80, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $85, $e0, $81, $e0, $91, $97, $90, $d6, $d6, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $86, $e0, $82, $e0, $91, $97, $90, $d6, $d6
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $87, $e0, $83, $e0, $91
	db $97, $90, $d6, $d6, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8a, $98, $d5, $d5
	db $92, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $94, $90, $99, $91, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $61, $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $65, $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0
	db $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $61, $62, $63, $64
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $65, $66, $67, $68
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $69, $6a, $6b, $6c
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6d, $6e, $6f, $70
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $09, $01, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73, $74
	db $75, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a9, $00, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73, $74, $75, $e0
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $49, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0
	db $65, $66, $67, $68, $69, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $87, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $65, $66, $67, $68
	db $69, $6a, $6b, $6c, $6d, $a0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74, $75
	db $76, $a1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $a2, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $a3, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d5, $df, $9f, $de, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $de, $d5, $d6
	db $d6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $70, $71, $72, $73, $74, $75, $76, $77, $78, $9b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $9c, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c
	db $8d, $8e, $8f, $90, $91, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99
	db $9a, $9e, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a4, $a5
	db $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a9
	db $aa, $ab, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $ac, $ad
	db $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $9e, $9f, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $a0, $a1
	db $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $8c, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e
	db $6f, $70, $71, $72, $73, $74, $75, $76, $8d, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b
	db $7c, $7d, $7e, $7f, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88
	db $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $95, $9d
	db $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a1, $a7, $a9
	db $a4, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a4
	db $a2, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e
	db $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $67, $68, $69, $6a, $6b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $6c, $6d, $6e, $6f, $70, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $71, $72, $73, $74, $75, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $76, $77, $78, $79, $7a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $7b, $7c, $7d, $7e, $7f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $08, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85
	db $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93
	db $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2
	db $a3, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $01, $02, $02, $02
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
	db $08, $08, $08, $08, $09, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $95, $9d, $93
	db $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9c
	db $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $26
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $00, $01, $02, $03
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $a0, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
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
	db $ee, $fd, $d9, $a0, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
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
	db $d9, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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
