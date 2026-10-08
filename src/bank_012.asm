INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $012", ROMX[$4000], BANK[$12]

BankNumber_12::
	db $12

FarTable_12::
	db $03, $40

	ld a, [wScriptMenu]
	rst $00

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

ScriptMenuNone::
	ret


SnapToTile::
	ld a, [hl]
	add $04
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hld], a
	ld a, [hl]
	and $f8
	ld [hl], a
	ret


NextBgColumn::
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


WindowBgAddr::
	ld a, [wWindowBgMap]
	add l
	ld l, a
	ld a, [$c90a]
	adc h
	and $03
	ld h, a
	ld a, [$c90a]
	and $fc
	or h
	ld h, a
	ret


TilemapBufferAddr::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


WindowBgAddrWrapped::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call WindowBgAddr
	ld a, b
	and $1f
	jr z, jr_012_4076

	ld b, a

jr_012_4070:
	call NextBgColumn
	dec b
	jr nz, jr_012_4070

jr_012_4076:
	pop bc
	ret


DrawLayoutToVram::
	db $1a, $6f, $13, $1a, $67, $13, $cd, $61, $40, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $35, $40, $18, $d3

DrawWindowLayout::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call TilemapBufferAddr
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a

jr_012_40c3:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_012_40e2

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
	jr jr_012_40c3

jr_012_40e2:
	ld [hli], a
	jr jr_012_40c3

CopyTilemapBufferToVram::
	ld a, [wWindowBgMap]
	ld l, a
	ld a, [$c90a]
	ld h, a
	ld de, wTilemapBuffer
	ld c, $12

jr_012_40f2:
	ld b, $20
	push hl

jr_012_40f5:
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
	jr nz, jr_012_40f5

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
	jr nz, jr_012_40f2

	ret


DrawTextTiles::
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


DrawNameTiles::
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


DrawCharTile::
	db $ea, $80, $c1, $3e, $f0, $ea, $81, $c1, $fa, $27, $c8, $4f, $fa, $28, $c8, $47
	db $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8, $47, $c5, $7d, $ea, $27, $c8, $7c, $ea
	db $28, $c8, $11, $01, $01, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $3e, $02, $ea
	db $22, $c8, $3e, $00, $ea, $23, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27
	db $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9

RestoreTilemapBuffer::
	ld hl, wTilemapBuffer
	ld de, wSavedTilemap
	ld bc, $0200

jr_012_41f8:
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_012_41f8

	ld de, wPartyBarTiles
	ld c, $02

jr_012_4205:
	ld b, $14

jr_012_4207:
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, jr_012_4207

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
	jr nz, jr_012_4205

	ret


ClearTilemapBuffer::
	ld hl, wTilemapBuffer
	ld bc, $0240

jr_012_4227:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_012_4227

	ret


ClearBgMap::
	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

UpdatePagedList::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_012_42a8

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_012_426e

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
	jr c, jr_012_428c

	ld a, c
	dec a
	jr jr_012_428c

jr_012_426e:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_012_42a8

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
	jr c, jr_012_428c

	ld a, $00

jr_012_428c:
	ld [hld], a
	dec c
	cp c
	jr nz, MenuCursorMoved

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
	jr z, MenuCursorMoved

	dec a
	cp [hl]
	jr nc, MenuCursorMoved

	ld [hl], a
	jr MenuCursorMoved

Jump_012_42a8:
jr_012_42a8:
	push bc
	push de
	push hl
	call DrawPageNumber
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
	jr nz, UpdateMenuCursor

	ld a, [wListLastRows]
	inc a
	ld b, a

UpdateMenuCursor::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_012_42dc

	ld a, [hl]
	dec a
	cp b
	jr c, jr_012_42ea

	dec b
	ld a, b
	jr jr_012_42ea

jr_012_42dc:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, MenuCursorCheckA

	ld a, [hl]
	inc a
	cp b
	jr c, jr_012_42ea

	ld a, $00

jr_012_42ea:
	ld [hl], a

MenuCursorMoved::
	xor a
	ld [wCursorBlink], a
	push hl
	push de
	pop de
	pop hl

MenuCursorCheckA::
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_012_42fc

	set 7, [hl]

jr_012_42fc:
	ld a, [hl]
	call DrawMenuCursor
	ret


UpdateMenuCursorLeftRight::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

ResetCursorBlink::
	xor a
	ld [wCursorBlink], a
	ret


DrawMenuCursor::
	ld c, a
	bit 7, a
	jr nz, jr_012_433d

	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
	pop af
	ld a, c
	ret nz

jr_012_433d:
	ld c, a
	ld b, $00

jr_012_4340:
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
	call WindowBgAddrWrapped
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_012_4370

	ld a, $e9
	bit 7, c
	jr nz, jr_012_4370

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_012_4370

	ld a, $e8

jr_012_4370:
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
	jr jr_012_4340

DrawPageNumber::
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
	push de
	push bc
	call WindowBgAddrWrapped
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
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


DrawListFrame::
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
	jr nc, jr_012_43d9

	ld a, $e7

jr_012_43d9:
	ld [hld], a
	pop bc
	jr nc, jr_012_43e1

	ld a, [bc]
	add $f1
	ld [hl], a

jr_012_43e1:
	pop af

DrawCursorAt::
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
	call WindowBgAddrWrapped
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_012_440d

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_012_440d

	ld a, $e8

jr_012_440d:
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


PrintMenuText::
	ld a, [wScriptMenuText]
	add l
	ld l, a
	ld a, [$c8f1]
	adc h
	ld h, a
	call PrintMessage
	ret


FarmKeeperMenu::
	ld a, [wMenuStep]
	rst $00

FarmKeeperSteps::
	dw FarmKeeperInit
	dw FarmKeeperOpenMenu
	dw FarmMainMenuInput
	dw FarmRunOption
	dw FarmKeeperClose

FarmKeeperInit::
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
	call RestoreTilemapBuffer
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
	call ResetCursorBlink
	ld a, $60
	ldh [hSpriteBGTile], a
	ld hl, far_CompactMonsters
	rst $10
	ld hl, wMenuStep
	inc [hl]
	ret


FarmKeeperOpenMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wMenuOverlay], a
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	call CopyTilemapBufferToVram
	ret


DrawFarmMainMenu::
	ld de, $710c
	call DrawWindowLayout
	ld de, $2e07
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $4532
	ld a, [wLinkChoice]
	call DrawCursorAt
	ret


FarmMainMenuInput::
	ld de, $4532
	ld hl, wLinkChoice
	ld b, $06
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_012_4500

	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr jr_012_4531

jr_012_4500:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_012_4531

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
	jr jr_012_4531

jr_012_4531:
	ret


FarmMainMenuCursorPos::
	db $21, $00, $61, $00, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

FarmRunOption::
	ld a, [wLinkChoice]
	rst $00

FarmOptionTable::
	dw FarmDepositOption
	dw FarmWithdrawOption
	dw FarmViewOption
	dw FarmReleaseOption
	dw FarmSwitchOption
	dw FarmKeeperClose

FarmKeeperClose::
	call RestoreTilemapBuffer
	ld de, $2e07
	call DrawWindowLayout
	call CopyTilemapBufferToVram
	call BuildStatusBar
	ld hl, $c13c
	ld de, wPartyBarTiles
	call CopyPartyBarRow
	ld hl, $c150
	ld de, $c1e0
	call CopyPartyBarRow
	ld a, $80
	ldh [hSpriteClip], a
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ret


CopyPartyBarRow::
	ld b, $14

jr_012_4581:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_012_4581

	ret


FarmDepositOption::
	ld a, [wMenuSubStep]
	rst $00

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

FarmDepositStart::
	ld a, [wPartyCount]
	cp $00
	jr z, jr_012_45ec

	cp $01
	jr nz, jr_012_45e1

	ld hl, $0004
	call PrintMenuText
	call CountFarmMonsters
	or a
	jr nz, jr_012_45d7

	ld a, $07
	ld [wMenuSubStep], a
	ret


jr_012_45d7:
	xor a
	ld [wConfirmChoice2], a
	ld a, $0a
	ld [wMenuSubStep], a
	ret


jr_012_45e1:
	ld hl, $0003
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmNoMonsters::
jr_012_45ec:
	ld a, $02
	ld [wTextGroup], a
	ld a, $33
	ld [wTextIndex], a
	ld hl, $8aa0
	ld de, $0601
	call DrawTextTiles
	ld hl, $06e1
	call PrintMessage
	ld a, $01
	ld [wMenuStep], a
	ret


FarmDepositShowParty::
	ld a, [wTextState]
	or a
	ret nz

	call ShowSelectedPartyMonster
	call LoadPartyNameTiles
	call DrawFarmPartyWindow
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmPartyWindow::
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	ld de, $71aa
	call DrawWindowLayout
	ld de, $759a
	call DrawWindowLayout
	call DrawSelectedPartyLevel
	call ResetCursorBlink
	ld de, $47af
	ld a, [wMenuChoice2]
	call DrawCursorAt
	ret


LoadPartyNameTiles::
	ld hl, $8800
	ld a, $01
	call LoadPartyNameSlot
	ld hl, $8840
	ld a, $02
	call LoadPartyNameSlot
	ld hl, $8880
	ld a, $03
	call LoadPartyNameSlot
	ret


LoadPartyNameSlot::
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr nc, jr_012_4672

	ld b, $20

jr_012_4665:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_012_4665

	ret


jr_012_4672:
	push hl
	ld a, b
	dec a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	call DrawNameTiles
	ret


ShowSelectedPartyMonster::
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]

DrawMonsterNameAndSex::
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, $9650
	call DrawNameTiles
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9690
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


DrawSelectedPartyLevel::
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]

DrawMonsterLevel::
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
	ld hl, $016a
	call TilemapBufferAddr
	ld a, $de
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
	call DrawTwoDigits
	pop af
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, jr_012_473e

	ld hl, $0172
	call TilemapBufferAddr
	ld a, $e3
	ld [hl], a
	ret


jr_012_473e:
	ld hl, $0172
	call TilemapBufferAddr
	ld a, $e0
	ld [hl], a
	ret


FarmDepositPartyInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $47af
	ld hl, wMenuChoice2
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
	call UpdateMenuCursor
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, jr_012_4772

	call ShowSelectedPartyMonster
	ld de, $759a
	call DrawWindowLayout
	call DrawSelectedPartyLevel
	call CopyTilemapBufferToVram

jr_012_4772:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4799

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
	jr jr_012_47ae

jr_012_4799:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_47ae

	ld a, $59
	call QueueSound
	xor a
	ld [wConfirmChoice], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_47ae:
jr_012_47ae:
	ret


PartyListCursorPos::
	db $6e, $00, $ae, $00, $ee, $00, $ff, $ff

FarmDepositAskConfirm::
	ld hl, $0005
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmDepositShowChoice::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawDepositChoice
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawDepositChoice::
	ld de, $7b42
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $483b
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


FarmDepositChoiceInput::
	ld de, $483b
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4813

	ld hl, far_Call_56_4485
	rst $10
	call DrawFarmPartyWindow
	call CopyTilemapBufferToVram
	ld hl, $0003
	call PrintMenuText
	ld a, $02
	ld [wMenuSubStep], a
	jr jr_012_483a

jr_012_4813:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_483a

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_4836

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $08
	ld [wMenuSubStep], a
	jp Jump_012_483a


jr_012_4836:
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_483a:
jr_012_483a:
	ret


DepositChoiceCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmDepositDoIt::
	ld a, [wMenuChoice2]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, $0006
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmDepositDone::
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


FarmDepositViewStatus::
	ld hl, wParty
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wMenuChoice2]
	and $7f
	ld [wViewIndex], a
	ld a, [wPartyCount]
	ld [wViewCount], a
	ld hl, far_UpdateMonsterStatus
	rst $10
	ld a, $01
	ld [wMenuOverlay], a
	ret


FarmDepositStatusReturn::
	ld a, [wMenuChoice2]
	and $80
	ld b, a
	ld a, [wViewResult]
	or b
	ld [wMenuChoice2], a
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
	call ShowSelectedPartyMonster
	call LoadPartyNameTiles
	ld hl, far_Call_56_4485
	rst $10
	call DrawFarmPartyWindow
	call DrawDepositChoice
	call CopyTilemapBufferToVram
	ld hl, $0005
	call PrintMenuText
	ld a, $05
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


FarmSwapAsk::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0007
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmSwapShowYesNo::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawSwapYesNo
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawSwapYesNo::
	ld de, $6f54
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $498d
	ld a, [wConfirmChoice2]
	call DrawCursorAt
	ret


FarmSwapYesNoInput::
	ld de, $498d
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4974

jr_012_4954:
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
	jr jr_012_498c

jr_012_4974:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_498c

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice2]
	cp $81
	jr z, jr_012_4954

	ld hl, wMenuSubStep
	inc [hl]

Jump_012_498c:
jr_012_498c:
	ret


SwapYesNoCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmSwapBuildList::
	call CountFarmMonsters
	call ListFarmMonsters
	ld hl, $0008
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmSwapShowList::
	ld a, [wTextState]
	or a
	ret nz

	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	call DrawFarmSwapList
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawFarmSwapList::
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
	call DrawSwapYesNo
	ret


ShowSelectedFarmMonster::
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
	call DrawMonsterNameAndSex
	ret


DrawSelectedFarmLevel::
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
	call DrawMonsterLevel
	ret


FarmSwapListInput::
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
	jr z, jr_012_4a42

	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_4a42:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_012_4a55

	call LoadFarmListNameTiles
	call ShowSelectedFarmMonster
	call DrawSelectedFarmLevel
	call CopyTilemapBufferToVram

jr_012_4a55:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4a79

	ld hl, far_Call_56_4485
	rst $10
	call RestoreTilemapBuffer
	call DrawFarmMainMenu
	call DrawSwapYesNo
	call CopyTilemapBufferToVram
	ld hl, $0007
	call PrintMenuText
	ld a, $0c
	ld [wMenuSubStep], a
	jr jr_012_4a8e

jr_012_4a79:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_4a8e

	ld a, $59
	call QueueSound
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wConfirmChoice], a

Jump_012_4a8e:
jr_012_4a8e:
	ret


FarmSwapAskConfirm::
	ld hl, $0009
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmSwapShowChoice::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	call DrawSwapChoice
	call CopyTilemapBufferToVram
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawSwapChoice::
	ld de, $7b42
	call DrawWindowLayout
	call ResetCursorBlink
	ld de, $4b18
	ld a, [wConfirmChoice]
	call DrawCursorAt
	ret


FarmSwapChoiceInput::
	ld de, $4b18
	ld hl, wConfirmChoice
	ld b, $02
	call UpdateMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_012_4af1

	ld hl, far_Call_56_4485
	rst $10
	call ShowSelectedFarmMonster
	call LoadFarmListNameTiles
	call DrawFarmSwapList
	call CopyTilemapBufferToVram
	ld hl, $0008
	call PrintMenuText
	ld a, $0f
	ld [wMenuSubStep], a
	jr jr_012_4b17

jr_012_4af1:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_012_4b17

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_012_4b13

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $15
	ld [wMenuSubStep], a
	jr jr_012_4b17

jr_012_4b13:
	ld hl, wMenuSubStep
	inc [hl]

Jump_012_4b17:
jr_012_4b17:
	ret


SwapChoiceCursorPos::
	db $21, $01, $61, $01, $ff, $ff

FarmSwapDoIt::
	ld a, [wParty]
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
	pop af
	ld [wParty], a
	ld hl, far_CompactMonsters
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, $000a
	call PrintMenuText
	ld hl, wMenuSubStep
	inc [hl]
	ret


FarmSwapDone::
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


FarmSwapViewStatus::
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


FarmSwapStatusReturn::
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
	call CountFarmMonsters
	call ListFarmMonsters
	call LoadFarmListNameTiles
	ld hl, far_Call_56_4485
	rst $10
	call ShowSelectedFarmMonster
	call DrawFarmSwapList
	call DrawSwapChoice
	call CopyTilemapBufferToVram
	ld hl, $0009
	call PrintMenuText
	ld a, $12
	ld [wMenuSubStep], a
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


	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff, $92, $01, $a8, $00
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


	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff, $92, $01, $a8, $00
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
	ld hl, far_PrintText_4D
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
	ld hl, far_Call_16_485C
	rst $10
	ld a, [wBreedPair]
	ld hl, $8600
	call LoadBreedIconTiles
	ld [wBreedPair], a
	ld a, [$da72]
	ld hl, $8700
	call LoadBreedIconTiles
	ld [$da72], a
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
	ld a, [$da72]
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
	ld a, [$da72]
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


	db $0d, $00, $50, $01, $12, $00, $51, $01, $19, $00, $53, $01, $1e, $00, $54, $01
	db $ff, $ff, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5
	db $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
	db $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $a8, $a7, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $0c, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $81, $00, $fa, $ef, $ef, $ef
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
	db $40, $01, $fa, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd
	db $d9, $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
	db $88, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b
	db $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a8, $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $68, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b
	db $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $46, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $a0, $a1, $a2, $a3, $e0, $dd, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $92, $98, $9c, $e3, $e0, $9c, $93, $93, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e3, $95, $91, $96, $e0
	db $9a, $e3, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $91, $94, $d5, $91, $96, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $e3, $90, $98
	db $90, $99, $d5, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $d6, $97, $d5, $d5, $e3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $a2, $95, $99, $e0
	db $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $0d, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82
	db $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86
	db $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a
	db $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e0, $80, $81, $82, $83, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $84, $85, $86, $87, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $88, $89, $8a, $8b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff
	db $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $80, $81, $82, $83, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $85, $86, $87, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $88, $89, $8a, $8b, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9e, $90, $d6, $99, $d5, $98
	db $e4, $a0, $a1, $a2, $a3, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $da, $a4, $a5, $a6, $a7, $e0, $db, $a8, $a9, $aa, $ab, $e0, $dc, $ac
	db $ad, $ae, $af, $ff, $d8, $fe, $e0, $9f, $e4, $e0, $e0, $e0, $e0, $9f, $e4, $e0
	db $e0, $e0, $e0, $9f, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa
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
	db $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8a
	db $98, $d5, $d5, $92, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $94, $90, $99, $91, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $40, $41, $42, $43, $e0, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $9b, $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb
	db $eb, $ed, $d8, $fe, $e0, $61, $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $65, $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $69, $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $6d, $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9b
	db $94, $9c, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $61
	db $62, $63, $64, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $65
	db $66, $67, $68, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $69
	db $6a, $6b, $6c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6d
	db $6e, $6f, $70, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $09, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71
	db $72, $73, $74, $75, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $76, $77, $78, $79, $7a, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a9, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $71, $72, $73
	db $74, $75, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $49, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $e0, $e0, $65, $66, $67, $68, $69, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $78, $79, $7a, $7b, $7c, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $87, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $65
	db $66, $67, $68, $69, $6a, $6b, $6c, $6d, $a0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71, $72
	db $73, $74, $75, $76, $a1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f
	db $a2, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $a3, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d5, $df, $9f, $de, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8
	db $de, $d5, $d6, $d6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $d5, $a5, $a1, $a3, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $70, $71, $72, $73, $74, $75, $76, $77, $78
	db $9b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $9c, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89
	db $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96
	db $97, $98, $99, $9a, $9e, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $a8, $a9, $aa, $ab, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $ac, $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $80
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $9e
	db $9f, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63, $e0, $9e, $9f, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $63
	db $e0, $a0, $a1, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $87, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $8c
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $8d, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78
	db $79, $7a, $7b, $7c, $7d, $7e, $7f, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85
	db $86, $87, $88, $8f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $95, $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $a1, $a7, $a9, $a4, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a4, $a2, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $67, $68, $69, $6a, $6b, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $6c, $6d, $6e, $6f, $70, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $71, $72, $73, $74, $75, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $76, $77, $78, $79, $7a, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $7b, $7c, $7d, $7e
	db $7f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $08, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $81, $82
	db $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f
	db $a0, $a1, $a2, $a3, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $01
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
	db $08, $08, $08, $08, $08, $08, $08, $09, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $95, $9d, $93, $9c, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9c, $96, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $95, $9d, $93, $9c, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9c, $96, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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
