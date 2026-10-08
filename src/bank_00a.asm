INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $00a", ROMX[$4000], BANK[$a]

BankNumber_0A::
	db $0a

FarTable_0A::
	dw RunServiceScreen0A

RunServiceScreen0A::
	ld a, [wScriptMenu]
	rst $00

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

ServiceScreenNone0A::
	ret


RoundToTile::
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


NextScreenColumn::
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


OffsetToScreenMap::
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


OffsetToTilemapBuffer::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


PosToScreenMap::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call OffsetToScreenMap
	ld a, b
	and $1f
	jr z, jr_00a_4076

	ld b, a

jr_00a_4070:
	call NextScreenColumn
	dec b
	jr nz, jr_00a_4070

jr_00a_4076:
	pop bc
	ret


DrawWindowLayoutVRAM::
	db $1a, $6f, $13, $1a, $67, $13, $cd, $61, $40, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $35, $40, $18, $d3

Call_0A_40B4::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call OffsetToTilemapBuffer
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a

jr_00a_40c3:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_00a_40e2

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
	jr jr_00a_40c3

jr_00a_40e2:
	ld [hli], a
	jr jr_00a_40c3

ShowTilemapBuffer::
	ld a, [wWindowBgMap]
	ld l, a
	ld a, [$c90a]
	ld h, a
	ld de, wTilemapBuffer
	ld c, $12

jr_00a_40f2:
	ld b, $20
	push hl

jr_00a_40f5:
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
	jr nz, jr_00a_40f5

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
	jr nz, jr_00a_40f2

	ret


RenderTextTiles::
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


RenderNameTiles::
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


RenderCharTile::
	db $ea, $80, $c1, $3e, $f0, $ea, $81, $c1, $fa, $27, $c8, $4f, $fa, $28, $c8, $47
	db $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8, $47, $c5, $7d, $ea, $27, $c8, $7c, $ea
	db $28, $c8, $11, $01, $01, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $3e, $02, $ea
	db $22, $c8, $3e, $00, $ea, $23, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27
	db $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9

RestoreFieldTilemap::
	ld hl, wTilemapBuffer
	ld de, wSavedTilemap
	ld bc, $0200

jr_00a_41f8:
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_00a_41f8

	ld de, wPartyBarTiles
	ld c, $02

jr_00a_4205:
	ld b, $14

jr_00a_4207:
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, jr_00a_4207

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
	jr nz, jr_00a_4205

	ret


	db $21, $00, $c5, $01, $40, $02, $3e, $e0, $22, $0b, $78, $b1, $20, $f8, $c9

ClearScreenMap::
	db $21
	db $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6, $c9

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
	call Call_0A_4387
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
	jr nz, Call_0A_42CA

	ld a, [wListLastRows]
	inc a
	ld b, a

Call_0A_42CA::
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
	call Call_0A_4328
	ret


UpdateMenuCursorH::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

Call_0A_4323::
	xor a
	ld [wCursorBlink], a
	ret


Call_0A_4328::
	ld c, a
	bit 7, a
	jr nz, jr_00a_433d

	ld a, [wCursorBlink]
	and $0f
	push af
	ld a, [wCursorBlink]
	inc a
	ld [wCursorBlink], a
	pop af
	ld a, c
	ret nz

jr_00a_433d:
	ld c, a
	ld b, $00

jr_00a_4340:
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
	call PosToScreenMap
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_00a_4370

	ld a, $e9
	bit 7, c
	jr nz, jr_00a_4370

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_00a_4370

	ld a, $e8

jr_00a_4370:
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
	jr jr_00a_4340

Call_0A_4387::
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
	call PosToScreenMap
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


DrawListCursor::
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
	jr nc, jr_00a_43d9

	ld a, $e7

jr_00a_43d9:
	ld [hld], a
	pop bc
	jr nc, jr_00a_43e1

	ld a, [bc]
	add $f1
	ld [hl], a

jr_00a_43e1:
	pop af

Call_0A_43E2::
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
	call PosToScreenMap
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_00a_440d

	ld a, [wCursorBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_00a_440d

	ld a, $e8

jr_00a_440d:
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


PrintServiceMessage::
	ld a, [wScriptMenuText]
	add l
	ld l, a
	ld a, [$c8f1]
	adc h
	ld h, a
	call PrintMessage
	ret


PartnerBreedScreen::
	ld a, [wMenuStep]
	rst $00

PartnerBreedSteps::
	dw PartnerBreedInit
	dw PartnerBreedOpenMenu
	dw PartnerBreedMenuInput
	dw PartnerBreedRunChoice
	dw PartnerBreedClose

PartnerBreedInit::
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
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
	call Call_0A_4323
	ld a, $78
	ldh [hSpriteBGTile], a
	ld hl, wMenuStep
	inc [hl]
	ret


PartnerBreedOpenMenu::
	ld hl, wMenuStep
	inc [hl]
	ld a, $5c
	call QueueSound
	call RestoreFieldTilemap
	call DrawPartnerBreedMenu
	call ShowTilemapBuffer
	ret


DrawPartnerBreedMenu::
	ld de, $6f3c
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4508
	ld a, [wLinkChoice]
	call Call_0A_43E2
	ret


PartnerBreedMenuInput::
	ld de, $4508
	ld hl, wLinkChoice
	ld b, $02
	call Call_0A_42CA
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_00a_44d2

	ld hl, wMenuStep
	inc [hl]
	ld hl, wMenuStep
	inc [hl]
	jr jr_00a_4507

jr_00a_44d2:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_00a_4507

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
	jr jr_00a_4507

jr_00a_4507:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

PartnerBreedRunChoice::
	ld a, [wItemsHandedIn]
	rst $00

PartnerBreedChoices::
	dw PartnerBreedFlow
	dw PartnerBreedClose

PartnerBreedClose::
	call RestoreFieldTilemap
	ld de, $2e07
	call Call_0A_40B4
	call ShowTilemapBuffer
	xor a
	ld [wMenuOverlay], a
	ld a, $80
	ldh [hSpriteClip], a
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


PartnerBreedFlow::
	ld a, [wMenuSubStep]
	rst $00

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
	call Call_0A_40B4
	call PBDrawLevel
	ld de, $7409
	call Call_0A_40B4
	call Call_0A_4323
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
	call Call_0A_6027
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


PBListInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $481f
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
	ld hl, wListCursor
	cp [hl]
	jr z, jr_00a_47c6

	call PBDrawCursorMonster
	call PBDrawLevel
	call ShowTilemapBuffer

jr_00a_47c6:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_00a_47d9

	call PBDrawCursorMonster
	call PBDrawPageNames
	call PBDrawLevel
	call DrawPBListScreen

jr_00a_47d9:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_47f0

	call GetPartnerName
	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_481e

jr_00a_47f0:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_481e

	ld a, $59
	call QueueSound
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
	xor a
	ld [wConfirmChoice], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_481e:
jr_00a_481e:
	ret


	db $45, $01, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

PBAskConfirm::
	ld hl, $0005
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


PBOpenConfirm::
	ld a, [wTextState]
	or a
	ret nz

	call DrawPBConfirmScreen
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawPBConfirmScreen::
	call RestoreFieldTilemap
	call DrawPartnerBreedMenu
	ld de, $7731
	call Call_0A_40B4
	call PBDrawLevel
	ld de, $7409
	call Call_0A_40B4
	ld de, $481f
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4914
	ld a, [wConfirmChoice]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ret


PBConfirmInput::
	ld de, $4914
	ld hl, wConfirmChoice
	ld b, $02
	call Call_0A_42CA
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_48ad

	call DrawPBListScreen
	call GetPartnerName
	ld hl, $0002
	call PrintServiceMessage
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	ld hl, wMenuSubStep
	dec [hl]
	jr jr_00a_4913

jr_00a_48ad:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4913

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_00a_48cf

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $0e
	ld [wMenuSubStep], a
	jr jr_00a_4913

jr_00a_48cf:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, jr_00a_48ea

	ld hl, $0003
	call PrintServiceMessage
	ld a, $10
	ld [wMenuSubStep], a
	jr jr_00a_4913

jr_00a_48ea:
	ld a, [wPartyCount]
	cp $02
	jr z, jr_00a_490b

	cp $03
	jr z, jr_00a_490b

	ld a, [wParty]
	ld hl, wCurPartyMember
	cp [hl]
	jr nz, jr_00a_490b

	ld hl, $0004
	call PrintServiceMessage
	ld a, $10
	ld [wMenuSubStep], a
	jr jr_00a_4913

jr_00a_490b:
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wConfirmChoice2], a

Jump_00a_4913:
jr_00a_4913:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

PBAskSave::
	ld hl, $0006
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


PBOpenSaveMenu::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6f3c
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4988
	ld a, [wMenuChoice3]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


PBSaveMenuInput::
	ld de, $4988
	ld hl, wMenuChoice3
	ld b, $02
	call Call_0A_42CA
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_496b

jr_00a_495b:
	call GetPartnerName
	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_4987

jr_00a_496b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4987

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_00a_495b

	xor a
	ld [wLinkRefused], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_4987:
jr_00a_4987:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

PBShowSaveInfo::
	ld de, $748d
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call PBDrawSaveInfo
	call ShowTilemapBuffer
	ld hl, $0007
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


PBOpenSaveConfirm::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld de, $6f3c
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4a0a
	ld a, [wLinkRefused]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


PBSaveConfirmInput::
	ld de, $4a0a
	ld hl, wLinkRefused
	ld b, $02
	call Call_0A_42CA
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_49f1

jr_00a_49e1:
	call GetPartnerName
	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_4a09

jr_00a_49f1:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4a09

	ld a, $59
	call QueueSound
	ld a, [wLinkRefused]
	cp $81
	jr z, jr_00a_49e1

	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_4a09:
jr_00a_4a09:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

PBBreedAndSave::
	ld de, $2e07
	call Call_0A_40B4
	call ShowTilemapBuffer
	ld hl, $0008
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	call CopyMonsterRecord
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	ld a, [wScriptMenuArg]
	ld c, a
	ld a, [$c8f8]
	ld b, a
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [$da13], a
	ld a, $15
	ld [wNewMonSlot], a
	ld hl, far_CreateMonster
	rst $10
	ld a, [$d670]
	xor $01
	ld [$d705], a
	ld a, $15
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld hl, far_CompactMonsters
	rst $10
	ld hl, HeaderLogo
	rst $10
	ld hl, far_Call_16_4015
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


PBWarpToBreeding::
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
	ld a, $04
	ld [wStoryStep], a
	xor a
	ld [wScriptRunning], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	ret


PBOpenStatus::
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


PBReturnFromStatus::
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
	ld de, $2e11
	ld hl, $8800
	call DecompressVRAM
	call PBDrawCursorMonster
	call PBDrawPageNames
	ld hl, $0005
	call PrintServiceMessage
	call DrawPBConfirmScreen
	xor a
	ld [wMenuOverlay], a
	ld a, $05
	ld [wMenuSubStep], a
	ret


PBBackToList::
	ld a, [wTextState]
	or a
	ret nz

	call PBCountMonsters
	call PBBuildMonsterList
	call GetPartnerName
	ld hl, $0002
	call PrintServiceMessage
	call DrawPBListScreen
	ld a, $01
	ld [wMenuSubStep], a
	ret


PBDrawSaveInfo::
	call DrawSaveFileInfo
	ret


GetPartnerName::
	ld a, [wScriptMenuArg]
	ld c, a
	ld a, [$c8f8]
	ld b, a
	ld a, c
	ld [wNewMonId], a
	ld a, b
	ld [$da13], a
	ld hl, far_LoadMonTemplate
	rst $10
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ret


BreedingScreen::
	ld a, [wMenuStep]
	rst $00

BreedingSteps::
	dw BreedingInit
	dw BreedingOpenMenu
	dw BreedingMenuInput
	dw BreedingRunChoice
	dw BreedingClose

BreedingInit::
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
	call Call_0A_40B4
	call ShowTilemapBuffer
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
	call Call_0A_4323
	ld a, $40
	ldh [hSpriteBGTile], a
	ld hl, wMenuStep
	inc [hl]
	ret


BreedingOpenMenu::
	ld hl, wMenuStep
	inc [hl]
	call RestoreFieldTilemap
	call DrawBreedingMenu
	call ShowTilemapBuffer
	ret


DrawBreedingMenu::
	ld de, $6f86
	call Call_0A_40B4
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call OffsetToTilemapBuffer
	call PrintNumber5
	ld de, $75ab
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4ccb
	ld a, [wLinkChoice]
	call Call_0A_43E2
	ret


BreedingMenuInput::
	ld de, $4ccb
	ld hl, wLinkChoice
	ld b, $03
	call Call_0A_42CA
	ld a, [wJoyPressed]
	and $0a
	jr z, jr_00a_4c95

	jr BreedingCloseAfterText

jr_00a_4c95:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_00a_4cca

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
	jr jr_00a_4cca

jr_00a_4cca:
	ret


	db $21, $00, $61, $00, $a1, $00, $ff, $ff

BreedingRunChoice::
	ld a, [wItemsHandedIn]
	rst $00

BreedingChoices::
	dw BreedFlow
	dw HatchFlow
	dw BreedingCloseAfterText

BreedingCloseAfterText::
	ld a, [wTextState]
	or a
	ret nz

BreedingClose::
	call RestoreFieldTilemap
	ld de, $2e07
	call Call_0A_40B4
	call ShowTilemapBuffer
	xor a
	ld [wMenuOverlay], a
	ld a, $80
	ldh [hSpriteClip], a
	ld hl, wFieldFlags
	res 4, [hl]
	xor a
	ld [wMenuStep], a
	ld hl, far_RefreshPartyGfx
	rst $10
	ret


BreedFlow::
	ld a, [wMenuSubStep]
	rst $00

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
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawLevel
	call Call_0A_4323
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
	call Call_0A_6027
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


BRPedigreeInput::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $4fa8
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
	ld hl, wListCursor
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_00a_4f49

	call BRClearInfo
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawLevel
	call ShowTilemapBuffer

jr_00a_4f49:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_00a_4f62

	call BRClearInfo
	call BRDrawPageNames
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawLevel
	call ShowTilemapBuffer

jr_00a_4f62:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_4f76

	ld hl, $0001
	call PrintServiceMessage
	ld a, $01
	ld [wMenuStep], a
	jr jr_00a_4fa7

jr_00a_4f76:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_4fa7

	ld a, $59
	call QueueSound
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
	ld [wListKnown], a
	xor a
	ld [wConfirmChoice], a
	ld hl, wMenuSubStep
	inc [hl]

Jump_00a_4fa7:
jr_00a_4fa7:
	ret


	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

BRAskPedigree::
	ld hl, $0005
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


BROpenPedigreeConfirm::
	ld a, [wTextState]
	or a
	ret nz

	call DrawBRPedigreeConfirm
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawBRPedigreeConfirm::
	call RestoreFieldTilemap
	call DrawBreedingMenu
	ld de, $75f3
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawLevel
	ld de, $4fa8
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawListCursor
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $509a
	ld a, [wConfirmChoice]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ret


BRPedigreeConfirmInput::
	ld de, $509a
	ld hl, wConfirmChoice
	ld b, $02
	call Call_0A_42CA
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_00a_5033

	call DrawBRListScreen
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
	jr jr_00a_5099

jr_00a_5033:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_00a_5099

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice]
	cp $81
	jr z, jr_00a_5055

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld a, $14
	ld [wMenuSubStep], a
	jr jr_00a_5099

jr_00a_5055:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, jr_00a_5070

	ld hl, $0007
	call PrintServiceMessage
	ld a, $16
	ld [wMenuSubStep], a
	jr jr_00a_5099

jr_00a_5070:
	ld a, [wPartyCount]
	cp $02
	jr z, jr_00a_5091

	cp $03
	jr z, jr_00a_5091

	ld a, [wParty]
	ld hl, wCurPartyMember
	cp [hl]
	jr nz, jr_00a_5091

	ld hl, $0006
	call PrintServiceMessage
	ld a, $16
	ld [wMenuSubStep], a
	jr jr_00a_5099

jr_00a_5091:
	ld hl, wMenuSubStep
	inc [hl]
	xor a
	ld [wConfirmChoice2], a

Jump_00a_5099:
jr_00a_5099:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

BRListMates::
	call BRCountMates
	call BRBuildMateList
	ld hl, $0004
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


BRCountMates::
	ld de, wMonsters
	ld b, $14
	ld c, $00
	ld h, $00

jr_00a_50ba:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_50d2

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_00a_50d2

	ld a, [wListKnown]
	cp h
	jr z, jr_00a_50d2

	inc c

jr_00a_50d2:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc h
	dec b
	jr nz, jr_00a_50ba

	ld a, c
	ld [wListLength], a
	ret


BRBuildMateList::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_50f9:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_5112

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_00a_5112

	ld a, [wListKnown]
	cp c
	jr z, jr_00a_5112

	ld [hl], c
	inc hl

jr_00a_5112:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_00a_50f9

	ret


BRShowMates::
	ld a, [wTextState]
	or a
	ret nz

	call BRDrawPair
	call BRDrawMatePage
	call DrawBRMateScreen
	ld hl, wMenuSubStep
	inc [hl]
	ret


DrawBRMateScreen::
	call RestoreFieldTilemap
	call DrawBreedingMenu
	ld de, $764d
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawPairLevels
	call Call_0A_4323
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
	call Call_0A_6027
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
	call Call_0A_6027
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
	call Call_0A_40B4
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
	call Call_0A_40B4
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
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawPairLevels
	ld de, $52dd
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor2
	call DrawListCursor
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $541f
	ld a, [wConfirmChoice2]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ret


BRMateConfirmInput::
	ld de, $541f
	ld hl, wConfirmChoice2
	ld b, $02
	call Call_0A_42CA
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
	ld hl, far_Call_16_45A3
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


	db $21, $01, $61, $01, $ff, $ff

BRShowSaveInfo::
	ld de, $748d
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
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
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5659
	ld a, [wLinkRefused]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


BRSaveConfirmInput::
	ld de, $5659
	ld hl, wLinkRefused
	ld b, $02
	call Call_0A_42CA
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


	db $21, $01, $61, $01, $ff, $ff

BRBreedAndSave::
	ld de, $2e07
	call Call_0A_40B4
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
	ld hl, far_Call_16_4015
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


CopyMonsterRecord::
	ld b, $95

jr_00a_57b2:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_00a_57b2

	ret


BROpenPedigreeStatus::
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


BRReturnFromPedigreeStatus::
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
	ld a, [wViewResult]
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wListKnown], a
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
	call BRClearInfo
	call BRDrawPageNames
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawLevel
	call ShowTilemapBuffer
	ld hl, $0005
	call PrintServiceMessage
	call DrawBRPedigreeConfirm
	ld a, $05
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


BRBackToList::
	ld a, [wTextState]
	or a
	ret nz

	call BRCountMonsters
	call BRBuildMonsterList
	ld hl, $0003
	call PrintServiceMessage
	call DrawBRListScreen
	ld a, $01
	ld [wMenuSubStep], a
	ret


BROpenMateStatus::
	ld hl, wSceneObjects
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	ld a, [wListPage2]
	add a
	add a
	ld b, a
	ld a, [wListCursor2]
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


BRReturnFromMateStatus::
	ld a, [wListCursor2]
	and $80
	ld b, a
	ld a, [wViewResult]
	and $03
	or b
	ld [wListCursor2], a
	ld a, [wViewResult]
	srl a
	srl a
	ld [wListPage2], a
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
	call BRDrawPair
	call BRDrawMatePage
	ld de, $76a7
	call Call_0A_40B4
	call BRDrawPairLevels
	call ShowTilemapBuffer
	ld hl, $0005
	call PrintServiceMessage
	call DrawBRMateConfirm
	ld a, $0b
	ld [wMenuSubStep], a
	xor a
	ld [wMenuOverlay], a
	ret


BRBackToMates::
	ld a, [wTextState]
	or a
	ret nz

	call BRCountMates
	call BRBuildMateList
	ld hl, $0004
	call PrintServiceMessage
	call DrawBRMateScreen
	ld a, $07
	ld [wMenuSubStep], a
	ret


HatchFlow::
	ld a, [wMenuSubStep]
	rst $00

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

HTListEggs::
	call HTCountEggs
	or a
	jr nz, jr_00a_5939

	ld hl, $0013
	call PrintServiceMessage
	ld a, $0b
	ld [wMenuSubStep], a
	ret


jr_00a_5939:
	call HTBuildEggList
	ld hl, $0012
	call PrintServiceMessage
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTCountEggs::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_594e:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_5960

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_00a_5960

	inc c

jr_00a_5960:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_00a_594e

	ld a, c
	ld [wListLength], a
	ret


HTBuildEggList::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_00a_5986:
	push de
	ld a, [de]
	or a
	jr z, jr_00a_5999

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_00a_5999

	ld [hl], c
	inc hl

jr_00a_5999:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_00a_5986

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
	call Call_0A_40B4
	call Call_0A_4323
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
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5c46
	ld a, [wMenuChoice3]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ld hl, wMenuSubStep
	inc [hl]
	ret


HTConfirmInput::
	ld de, $5c46
	ld hl, wMenuChoice3
	ld b, $02
	call Call_0A_42CA
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
	call Call_0A_40B4
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
	ld hl, far_Call_16_474A
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
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5c46
	ld a, [wMenuChoice3]
	call Call_0A_43E2
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


	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

Call_0A_6027::
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
	call Call_0A_4323
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
	call Call_0A_40B4
	ld de, $6f86
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call OffsetToTilemapBuffer
	call PrintNumber5
	call Call_0A_4323
	ld de, $6186
	ld a, [wLinkChoice]
	call Call_0A_43E2
	ret


EAMenuInput::
	ld de, $6186
	ld hl, wLinkChoice
	ld b, $03
	call Call_0A_42CA
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
	call Call_0A_40B4
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
	call Call_0A_40B4
	call Call_0A_4323
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
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $6653
	ld a, [wConfirmChoice]
	call Call_0A_43E2
	ret


APPayConfirmInput::
	ld de, $6653
	ld hl, wConfirmChoice
	ld b, $02
	call Call_0A_42CA
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
	ld hl, $cb29
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
	call Call_0A_40B4
	call Call_0A_4323
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
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $68a8
	ld a, [wMenuChoice3]
	call Call_0A_43E2
	ret


GCConfirmInput::
	ld de, $68a8
	ld hl, wMenuChoice3
	ld b, $02
	call Call_0A_42CA
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
	call Call_0A_40B4
	call ShowTilemapBuffer
	ld de, $2e12
	ld hl, $8800
	call DecompressVRAM
	call Call_0A_4323
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
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $6a42
	ld a, [wLinkChoice]
	call Call_0A_43E2
	ret


JPMenuInput::
	ld de, $6a42
	ld hl, wLinkChoice
	ld b, $02
	call Call_0A_42CA
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
	call Call_0A_40B4
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
	call Call_0A_40B4
	ld de, $76e5
	call Call_0A_40B4
	call JFDrawLevel
	call Call_0A_4323
	ld de, $6cef
	ld a, [wMenuChoice2]
	call Call_0A_43E2
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
	call Call_0A_6027
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
	call Call_0A_42CA
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
	call Call_0A_40B4
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
	call Call_0A_40B4
	ld de, $76e5
	call Call_0A_40B4
	call JFDrawLevel
	ld de, $6cef
	ld a, [wMenuChoice2]
	call Call_0A_43E2
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $6da0
	ld a, [wConfirmChoice]
	call Call_0A_43E2
	call ShowTilemapBuffer
	ret


JFConfirmInput::
	ld de, $6da0
	ld hl, wConfirmChoice
	ld b, $02
	call Call_0A_42CA
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


	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7
	db $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf
	db $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a7
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $0c, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $dd, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $a4, $aa, $d4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $d6, $d5, $de, $de, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d5, $ab, $a5, $a9, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $81, $00, $fa, $ef, $ef, $ef, $ef, $ef
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
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $01
	db $fa, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $fd, $d9, $40
	db $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e5, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9c, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $88, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80
	db $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f
	db $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d
	db $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a4, $d5, $a7, $a8, $a9, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $aa, $ab, $ac, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $a4, $a5, $a6, $a7, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $a8, $a9, $aa, $ab, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $68, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80
	db $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f
	db $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9b, $9c, $9d
	db $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $6c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
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
