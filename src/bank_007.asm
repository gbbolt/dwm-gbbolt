INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $007", ROMX[$4000], BANK[$7]

BankNumber_07::
	db $07

FarTable_07::
	dw FieldMenu
	dw ShowMonsterStatus
	dw UpdateMonsterStatus
	dw GetSkillMPCost

FieldMenu::
	ld a, [wStatusViewVars]
	rst $00

FieldMenuStates::
	dw FieldMenuOpen
	dw FieldMenuDraw
	dw FieldMenuInput
	dw FieldMenuRunOption
	dw FieldMenuClose

FieldMenuDraw::
	ld hl, wStatusViewVars
	inc [hl]
	call MenuClearBuffer
	call DrawMainMenuWindows
	call MenuShowBuffer
	call DrawPartyPanel
	call MenuShowBuffer
	ret


DrawMainMenuWindows::
	ld de, $704d
	call DrawWindow
	ld de, $7090
	call DrawWindow
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
	call MenuResetBlink
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
	ret


DrawPartyPanel::
	ld a, [wPartyCount]
	or a
	jr z, jr_007_40c4

	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $95c0
	call LoadMonsterPicture
	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8500
	call LoadMonsterSprite
	ld a, [wPartyCount]
	cp $01
	jr z, jr_007_40c4

	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8800
	call LoadMonsterPicture
	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8600
	call LoadMonsterSprite
	ld a, [wPartyCount]
	cp $02
	jr z, jr_007_40c4

	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8a40
	call LoadMonsterPicture
	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $8700
	call LoadMonsterSprite

jr_007_40c4:
	call MenuLoadPartyNames
	call DrawInfoPage
	ld a, [wPartyCount]
	or a
	ret z

	ld a, $5c
	ld hl, $00e1
	call DrawPicTiles
	ld a, $20
	ld hl, $01c1
	call DrawNameTileRow
	ld hl, $00e1
	ld a, $00
	call SetPartyPicPalette
	ld a, $00
	ld hl, $9590
	call LoadPartySexMark
	ld hl, $01e1
	ld a, $00
	call DrawPartyMemberStats
	ld a, [wPartyCount]
	cp $01
	ret z

	ld a, $80
	ld hl, $00e7
	call DrawPicTiles
	ld a, $24
	ld hl, $01c7
	call DrawNameTileRow
	ld hl, $00e7
	ld a, $01
	call SetPartyPicPalette
	ld a, $01
	ld hl, $95a0
	call LoadPartySexMark
	ld hl, $01e7
	ld a, $01
	call DrawPartyMemberStats
	ld a, [wPartyCount]
	cp $02
	ret z

	ld a, $a4
	ld hl, $00ed
	call DrawPicTiles
	ld a, $28
	ld hl, $01cd
	call DrawNameTileRow
	ld hl, $00ed
	ld a, $02
	call SetPartyPicPalette
	ld a, $02
	ld hl, $95b0
	call LoadPartySexMark
	ld hl, $01ed
	ld a, $02
	call DrawPartyMemberStats
	ret


DrawPicTiles::
	ld c, a
	ld a, [wMenuInfoPage]
	or a
	ret nz

	ld a, c
	ld c, $06

jr_007_415d:
	push hl
	push af
	call BufferAddress
	pop af
	ld b, $06

jr_007_4165:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_007_4165

	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, jr_007_415d

	ret


DrawNameTileRow::
	push af
	call BufferAddress
	pop af
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	inc a
	ret


SetPartyPicPalette::
	push af
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	pop af
	push af
	ld hl, wMonRecSpecies
	call PartyMonsterField
	ld a, [hl]
	ld [wPaletteSet], a
	pop af
	add $04
	ld [$c81f], a
	ld a, [wMenuInfoPage]
	or a
	ret nz

	ld hl, far_LoadMonPicPalette
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ret


LoadPartySexMark::
	push hl
	ld hl, wMonGender
	call PartyMonsterField
	ld a, [hl]
	pop hl
	call DrawSexMark
	ret


DrawPartyMemberStats::
	push hl
	ldh [hNumber], a
	call BufferAddress
	ld a, $de
	ld [hli], a
	ld a, $df
	ld [hli], a
	ld a, $e4
	ld [hli], a
	ldh a, [hNumber]
	add $59
	inc hl
	inc hl
	ld [hld], a
	dec hl
	push hl
	ld hl, wMonLevel
	ldh a, [hNumber]
	call GetPartyMonsterByte
	pop hl
	ld c, a
	ld b, $00
	call DrawNumber2
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	push hl
	call BufferAddress
	ld a, $e0
	ld [hli], a
	ld a, $e1
	ld [hli], a
	ld a, $e4
	ld [hli], a
	push hl
	ld hl, wMonHP
	ldh a, [hNumber]
	call GetPartyMonsterWord
	pop hl
	call DrawNumber3
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	push hl
	call BufferAddress
	ld a, $e0
	ld [hli], a
	ld a, $e2
	ld [hli], a
	ld a, $e4
	ld [hli], a
	push hl
	ld hl, wMonMP
	ldh a, [hNumber]
	call GetPartyMonsterWord
	pop hl
	call DrawNumber3
	pop hl
	ret


DrawInfoPage::
	ld a, [wMenuInfoPage]
	or a
	ret z

	ld a, $59
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	ld hl, $95c0
	ld de, $1401
	call MenuDrawTextTiles
	ld de, wPlayerName
	ld hl, $93c0
	call MenuDrawNameTiles
	ld de, $7cee
	call DrawWindow
	ld b, $00
	ld c, $00

jr_007_4251:
	push bc
	ld hl, wLibraryFlags
	ld a, b
	call TestFlag
	pop bc
	jr z, jr_007_425d

	inc c

jr_007_425d:
	inc b
	ld a, b
	cp $f0
	jr nz, jr_007_4251

	ld b, $00
	ld hl, $0110
	call BufferAddress
	call PrintNumber3
	ld a, [wPlayHours]
	ld c, a
	ld b, $00
	ld hl, $00ae
	call BufferAddress
	call PrintNumber2Zeros
	ld a, [wPlayMinutes]
	ld c, a
	ld b, $00
	ld hl, $00b1
	call BufferAddress
	call PrintNumber2Zeros
	call DrawMonsterCounts
	ret


UpdateInfoPlayTime::
	ld a, [wMenuInfoPage]
	or a
	ret z

	ld a, [wPlayHours]
	ld c, a
	ld b, $00
	ld hl, $00ae
	call MenuMapAddress
	call PrintNumber2Zeros
	ld a, [wPlayMinutes]
	ld c, a
	ld b, $00
	ld hl, $00b1
	call MenuMapAddress
	call PrintNumber2Zeros
	ret


DrawMonsterCounts::
	ld hl, HeaderOldLicenseeCode
	call CountFarmMonstersMenu
	ld hl, $0151
	call CountEggs
	ld hl, $016b
	call CountFarm2Monsters
	ld hl, $0171
	call CountFarm2Eggs
	ret


CountFarmMonstersMenu::
	call BufferAddress
	push hl
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_007_42d8:
	push de
	ld a, [de]
	or a
	jr z, jr_007_42ee

	cp $02
	jr z, jr_007_42ee

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_007_42ee

	inc c

jr_007_42ee:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_007_42d8

	pop hl
	ld b, $00
	call PrintNumber2
	ret


CountEggs::
	call BufferAddress
	push hl
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_007_430c:
	push de
	ld a, [de]
	or a
	jr z, jr_007_431e

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_007_431e

	inc c

jr_007_431e:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_007_430c

	pop hl
	ld b, $00
	call PrintNumber2
	ret


CountFarm2Monsters::
	call BufferAddress
	ld c, $00
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, jr_007_4368

	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00

jr_007_4345:
	push hl
	call ReadSRAMByte
	or a
	jr z, jr_007_435b

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call ReadSRAMByte
	or a
	jr nz, jr_007_435b

	inc c

jr_007_435b:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_007_4345

	pop hl

jr_007_4368:
	ld b, $00
	call PrintNumber2
	ret


CountFarm2Eggs::
	call BufferAddress
	ld c, $00
	ld a, [wFarm2Flags]
	bit 7, a
	jr z, jr_007_43a5

	push hl
	ld hl, sFarm2
	ld b, $14
	ld c, $00

jr_007_4382:
	push hl
	call ReadSRAMByte
	or a
	jr z, jr_007_4398

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call ReadSRAMByte
	or a
	jr z, jr_007_4398

	inc c

jr_007_4398:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_007_4382

	pop hl

jr_007_43a5:
	ld b, $00
	call PrintNumber2
	ret


LoadMonsterPicture::
	cp $ff
	ret z

	push hl
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
	pop hl
	ld a, [wMenuInfoPage]
	or a
	ret nz

	call DecompressVRAM
	ret


FieldMenuInput::
	call UpdateInfoPlayTime
	ld hl, wLinkChoice
	res 7, [hl]
	ld a, [wJoyPressed]
	and $30
	jr z, jr_007_43e1

	ld a, [wLinkChoice]
	xor $01
	ld [wLinkChoice], a
	jr jr_007_43f0

jr_007_43e1:
	ld a, [wJoyPressed]
	and $c0
	jr z, jr_007_43f6

	ld a, [wLinkChoice]
	xor $02
	ld [wLinkChoice], a

jr_007_43f0:
	xor a
	ld [wMenuBlink], a
	jr jr_007_445c

jr_007_43f6:
	ld a, [wJoyPressed]
	and $08
	jr z, jr_007_441b

	ld a, [wMenuInfoPage]
	xor $01
	ld [wMenuInfoPage], a
	ld hl, $c5a0
	ld bc, $0100
	ld a, $e0
	call FillMemory
	call MenuShowBuffer
	call DrawPartyPanel
	call MenuShowBuffer
	jr jr_007_445c

jr_007_441b:
	ld a, [wJoyPressed]
	and $06
	jr z, jr_007_442c

	ld hl, wStatusViewVars
	inc [hl]
	ld hl, wStatusViewVars
	inc [hl]
	jr jr_007_445c

jr_007_442c:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_007_445c

	ld a, $59
	call QueueSound
	ld hl, wStatusViewVars
	inc [hl]
	call MenuClearBuffer
	call DrawMainMenuWindows
	call MenuShowBuffer
	xor a
	ld [wFieldMenuStep], a
	ld hl, wLinkChoice
	set 7, [hl]
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
	call MenuLoadPartyNames

jr_007_445c:
	ld de, $44b4
	ld a, [wLinkChoice]
	call BlinkMenuCursor
	call DrawPartySprites
	ret


MenuLoadPartyNames::
	ld hl, $9200
	ld a, $01
	call LoadPartyNameTile
	ld hl, $9240
	ld a, $02
	call LoadPartyNameTile
	ld hl, $9280
	ld a, $03
	call LoadPartyNameTile
	ret


LoadPartyNameTile::
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr nc, jr_007_4498

	ld b, $20

jr_007_448b:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_007_448b

	ret


jr_007_4498:
	push hl
	ld a, b
	dec a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	call MenuDrawNameTiles
	ret


FieldMenuRunOption::
	ld a, [wLinkChoice]
	rst $00

FieldMenuOptions::
	dw StatusMenu
	dw ItemMenu
	dw SkillMenu
	dw OptionMenu
	dw $0021
	dw $0026
	dw $0061
	dw $0066
	dw $ffff

StatusMenu::
	ld a, [wFieldMenuStep]
	rst $00

StatusMenuSteps::
	dw StatusMenuOpen
	dw StatusPage1Input
	dw StatusShowPicture
	dw StatusStepNext
	dw StatusStepSkip
	dw StatusStepBack4
	dw StatusShowPage2
	dw StatusPage2Input
	dw StatusShowSkills
	dw StatusSkillsInput
	dw StatusShowPedigree
	dw StatusPedigreeInput
	dw StatusClose
	dw StatusRedrawPage2
	dw StatusRedrawPedigree

StatusMenuOpen::
	call MenuLoadPartyNames

StatusDrawPage1::
	ld de, $70ad
	call DrawWindow
	ld de, $70f7
	call DrawWindow
	ld de, $71af
	call DrawWindow
	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
	call LoadStatusPicture
	call SetStatusPicPalette
	ld de, $724f
	call DrawWindow
	call DrawStatusStats
	call MenuResetBlink
	ld de, $4632
	ld a, [wMenuChoice2]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawStatusStats::
	call SyncStatusMonster
	ld hl, wMonName
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $93c0
	call MenuDrawNameTiles
	ld hl, wMonGender
	call GetViewedMonsterByte
	ld hl, $9300
	call DrawSexMark
	ld hl, wMonLevel
	call GetViewedMonsterByte
	push af
	ld hl, wMonMaxLevel
	call GetViewedMonsterField
	pop af
	cp [hl]
	ld a, $90
	jr c, jr_007_4550

	ld a, $ac

jr_007_4550:
	ld hl, $8800
	call MenuDrawCharTile
	ld hl, wMonLevel
	call GetViewedMonsterByte
	ld c, a
	ld b, $00
	ld hl, $0031
	call BufferAddress
	call PrintNumber2
	ld hl, wMonAttack
	ld de, $0070
	call DrawStatValue
	ld hl, wMonDefense
	ld de, $00b0
	call DrawStatValue
	ld hl, wMonAgility
	ld de, $00f0
	call DrawStatValue
	ld hl, wMonIntelligence
	ld de, $0130
	call DrawStatValue
	ld hl, wMonWildness
	ld de, $0170
	call DrawStatValue
	ld hl, wMonHP
	ld de, $01cc
	call DrawStatValue
	ld hl, wMonMaxHP
	ld de, $01d0
	call DrawStatValue
	ld hl, wMonMP
	ld de, $020c
	call DrawStatValue
	ld hl, wMonMaxMP
	ld de, $0210
	call DrawStatValue
	ld hl, wMonStatus
	call GetViewedMonsterByte
	ld b, a
	ld hl, $01f0
	call BufferAddress
	bit 0, b
	ld a, $e0
	jr z, jr_007_45ce

	ld a, $d7

jr_007_45ce:
	ld [hli], a
	bit 2, b
	ld a, $e0
	jr z, jr_007_45d7

	ld a, $d8

jr_007_45d7:
	ld [hli], a
	bit 7, b
	ld a, $e0
	jr z, jr_007_45e0

	ld a, $d9

jr_007_45e0:
	ld [hl], a
	ret


DrawStatValue::
	push de
	call GetViewedMonsterWord
	pop hl
	call BufferAddress
	call PrintNumber3
	ret


SyncStatusMonster::
	ld a, [wFieldFlags]
	bit 1, a
	ret z

	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
	ret


StatusPage1Input::
	call MoveStatusMonCursor
	jr z, jr_007_460f

	call SyncStatusMonster
	call DrawStatusStats
	call MenuShowBuffer
	call LoadStatusPicture
	call SetStatusPicPalette

jr_007_460f:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_4620

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	jr jr_007_4631

jr_007_4620:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_4631

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_4631:
jr_007_4631:
	ret


StatusMonCursorPos::
	db $61, $00, $a1, $00, $e1, $00, $ff, $ff

MoveStatusMonCursor::
	ld de, $4632
	ld hl, wMenuChoice2
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
	call MoveMenuCursorNoSelect
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	ret


StatusShowPicture::
	call LoadStatusPicture
	call SetStatusPicPalette
	ld de, $724f
	call DrawWindow
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	xor a
	ld [wMenuCount], a
	ret


LoadStatusPicture::
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
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
	ld hl, $8b00
	call DecompressVRAM
	ret


SetStatusPicPalette::
	ld hl, $0141
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld [wPaletteSet], a
	ld a, $04
	ld [$c81f], a
	ld hl, far_LoadMonPicPalette
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ret


StatusStepNext::
	ld hl, wFieldMenuStep
	inc [hl]
	ret


StatusStepSkip::
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ret


StatusStepBack4::
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ret


StatusShowPage2::
	call DrawStatusPage2
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawStatusPage2::
	call SyncStatusMonster
	ld hl, wMonName
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $93c0
	call MenuDrawNameTiles
	ld hl, wMonGender
	call GetViewedMonsterByte
	ld hl, $9300
	call DrawSexMark
	ld hl, wMonLevel
	call GetViewedMonsterByte
	push af
	ld hl, wMonMaxLevel
	call GetViewedMonsterField
	pop af
	cp [hl]
	ld a, $90
	jr c, jr_007_4704

	ld a, $ac

jr_007_4704:
	ld hl, $8800
	call MenuDrawCharTile
	call GetViewedMonster
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	ld [wTextIndex], a
	ld a, $0a
	ld [wTextGroup], a
	ld hl, $9330
	ld de, $0901
	call MenuDrawTextTiles
	ld hl, wMonFamily
	call GetViewedMonsterByte
	ld c, a
	push bc
	ld hl, wMonPlus
	call GetViewedMonsterByte
	ld hl, $95b0
	pop bc
	call DrawFamilyPlus
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld hl, $94c0
	ld de, $0901
	call MenuDrawTextTiles
	ld hl, wMonMaster
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $9550
	call MenuDrawNameTiles
	ld de, $727b
	call DrawWindow
	ld de, $7333
	call DrawWindow
	ld hl, wMonLevel
	call GetViewedMonsterByte
	ld c, a
	ld b, $00
	ld hl, $0031
	call BufferAddress
	call PrintNumber2
	ld hl, wMonExp
	call GetViewedMonsterField
	ld a, [hli]
	ldh [hNumber], a
	ld a, [hli]
	ldh [$ffd6], a
	ld a, [hl]
	ldh [$ffd7], a
	ld hl, $016b
	call BufferAddress
	call PrintNumber7
	ld hl, wMonExp
	call GetViewedMonsterField
	ld a, [hli]
	ldh [hNumber], a
	ld a, [hli]
	ldh [$ffd6], a
	ld a, [hl]
	ldh [$ffd7], a
	ld a, [wCurPartyMember]
	push af
	call GetViewedMonster
	ld [wCurPartyMember], a
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	jr z, jr_007_47ca

	push af
	ld a, [wCurPartyMember]
	ld hl, wMonMaxLevel
	call MonsterField
	pop af
	cp [hl]
	jr z, jr_007_47ca

	ld hl, far_GetExpForNextLevel
	rst $10

jr_007_47ca:
	pop af
	ld [wCurPartyMember], a
	ld hl, wMonExp
	call GetViewedMonsterField
	ldh a, [hNumber]
	sub [hl]
	inc hl
	ldh [hNumber], a
	ldh a, [$ffd6]
	sbc [hl]
	inc hl
	ldh [$ffd6], a
	ldh a, [$ffd7]
	sbc [hl]
	ldh [$ffd7], a
	ld hl, $020b
	call BufferAddress
	call PrintNumber7
	call MenuShowBuffer
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	ld hl, $8500
	call LoadMonsterSprite
	ret


StatusPage2Input::
	call MoveStatusMonCursor
	jr z, jr_007_480a

	ld a, $0d
	ld [wFieldMenuStep], a
	jr jr_007_482f

jr_007_480a:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_481b

	call StatusDrawPage1
	ld a, $01
	ld [wFieldMenuStep], a
	jr jr_007_482f

jr_007_481b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_482c

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_482c:
	call DrawStatusSprite

jr_007_482f:
	ret


StatusShowSkills::
	ld de, $71f7
	call DrawWindowToMap
	call DrawMonSkillNames
	ld de, $737b
	call DrawWindow
	call MenuShowBuffer
	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
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
	ld hl, $8b00
	call DecompressVRAM
	ld de, $724f
	call DrawWindow
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawMonSkillNames::
	ld hl, wMonSkills
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $9650
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	ld hl, $8830
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName

DrawSkillName::
	push de
	push hl
	ld a, [de]
	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a
	ld de, $0901
	call MenuDrawTextTiles
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


StatusSkillsInput::
	call MoveStatusMonCursor
	jr z, StatusSkillsButtons

	call SyncStatusMonster
	call DrawMonSkillNames
	call MenuShowBuffer
	call LoadStatusPicture
	call SetStatusPicPalette

StatusSkillsButtons::
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_48d4

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_48e5

jr_007_48d4:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_48e5

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_48e5:
jr_007_48e5:
	ret


StatusShowPedigree::
	ld de, $746b
	call DrawWindow
	call MenuShowBuffer
	call DrawPedigree
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawPedigree::
	ld hl, wMonParent1Name
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $88c0
	call MenuDrawNameTiles
	ld hl, wMonParent1Master
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8900
	call MenuDrawNameTiles
	ld hl, wMonParent1
	call GetViewedMonsterByte
	cp $ff
	jr z, jr_007_4927

	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]

jr_007_4927:
	ld c, a
	push bc
	ld hl, wMonParent1Plus
	call GetViewedMonsterByte
	ld hl, $95e0
	pop bc
	call DrawFamilyPlus
	ld hl, wMonParent1
	call GetViewedMonsterByte
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld hl, $94c0
	ld de, $0901
	call DrawTextOrBlank
	ld hl, wMonParent2Name
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8940
	call MenuDrawNameTiles
	ld hl, wMonParent2Master
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8980
	call MenuDrawNameTiles
	ld hl, wMonParent2
	call GetViewedMonsterByte
	cp $ff
	jr z, jr_007_497d

	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]

jr_007_497d:
	ld c, a
	push bc
	ld hl, wMonParent2Plus
	call GetViewedMonsterByte
	ld hl, $9660
	pop bc
	call DrawFamilyPlus
	ld hl, wMonParent2
	call GetViewedMonsterByte
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld hl, $9550
	ld de, $0901
	call DrawTextOrBlank
	ld de, $755b
	call DrawWindow
	ld de, $75db
	call DrawWindow
	call MenuShowBuffer
	ld hl, wMonParent2
	call GetViewedMonsterByte
	cp $ff
	jr nz, jr_007_49c6

	ld de, $7223
	call DrawWindow
	call MenuShowBuffer
	ret


jr_007_49c6:
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
	ld de, $724f
	call DrawWindow
	ld de, $765b
	call DrawWindow
	call MenuShowBuffer
	ld hl, wMonParent1
	call GetViewedMonsterByte
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
	ld hl, wMonParent1
	call GetViewedMonsterByte
	ld hl, $8600
	call LoadMonsterSprite
	ld hl, wMonParent2
	call GetViewedMonsterByte
	ld hl, $8700
	call LoadMonsterSprite
	ret


StatusPedigreeInput::
	call MoveStatusMonCursor
	jr z, StatusPedigreeButtons

	ld a, $0e
	ld [wFieldMenuStep], a
	jr jr_007_4a59

StatusPedigreeButtons::
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_4a45

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld de, $71f7
	call DrawWindow
	call MenuShowBuffer
	ld de, $746b
	call DrawWindow
	call MenuShowBuffer
	jr jr_007_4a59

jr_007_4a45:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_4a56

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_4a56:
	call DrawPedigreeSprites

jr_007_4a59:
	ret


StatusClose::
	call MenuClearBuffer
	call MenuShowBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


StatusRedrawPage2::
	call SyncStatusMonster
	call DrawStatusPage2
	call LoadStatusPicture
	call SetStatusPicPalette
	ld a, $07
	ld [wFieldMenuStep], a
	ret


StatusRedrawPedigree::
	call SyncStatusMonster
	call DrawPedigree
	call LoadStatusPicture
	call SetStatusPicPalette
	ld a, $0b
	ld [wFieldMenuStep], a
	ret


ItemMenu::
	ld a, [wFieldMenuStep]
	rst $00

ItemMenuSteps::
	dw ItemMenuOpen
	dw ItemMenuDraw
	dw ItemListInput
	dw ItemShowUseDiscard
	dw ItemUseDiscardInput
	dw ItemShowTargets
	dw ItemTargetInput
	dw ItemStartUse
	dw ItemShowMessage
	dw ItemApply
	dw ItemCloseAfterText
	dw ItemStepIdle
	dw ItemMenuEmpty
	dw ItemEmptyInput
	dw ItemAskDiscard
	dw ItemDiscardInput
	dw ItemDiscard

ItemMenuOpen::
	call DrawItemDescription
	call DrawBagPage
	ld hl, wFieldMenuStep
	inc [hl]
	call CountBagItems
	ld a, [wMenuCount]
	or a
	ret nz

	ld a, $0c
	ld [wFieldMenuStep], a
	ret


ItemMenuDraw::
	call CountBagItems
	call MenuClearBuffer
	ld de, $704d
	call DrawWindow
	ld de, $7090
	call DrawWindow
	ld de, $7748
	call DrawWindow
	ld de, $77d9
	call DrawWindow
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
	call MenuResetBlink
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
	ld de, $4c53
	ld b, $05
	ld a, [wMenuCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListMarks
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawBagPage::
	ld de, wBagItems
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9700
	call DrawItemName
	ld hl, $8800
	call DrawItemName
	call DrawItemName
	call DrawItemName
	call DrawItemName

DrawItemName::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_007_4b4f

	ld a, $00

jr_007_4b4f:
	ld [wTextIndex], a
	ld a, $08
	ld [wTextGroup], a
	ld de, $0901
	call MenuDrawTextTiles
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


DrawItemDescription::
	ld hl, wBagItems
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr nz, jr_007_4b87

	ld a, $00

jr_007_4b87:
	ld [wTextIndex], a
	ld a, $09
	ld [wTextGroup], a
	ld hl, $94c0
	ld de, $1202
	call MenuDrawTextTiles
	ret


CountBagItems::
	ld hl, wBagItems
	ld b, $14
	ld c, $00

jr_007_4ba0:
	ld a, [hli]
	cp $00
	jr z, jr_007_4bad

	cp $ff
	jr z, jr_007_4bad

	inc c
	dec b
	jr nz, jr_007_4ba0

jr_007_4bad:
	ld a, c
	ld [wMenuCount], a
	ret


ItemListInput::
	ld de, $4c53
	ld hl, wMenuChoice2
	ld a, [wMenuCount]
	ld c, a
	ld b, $05
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call MoveListCursor
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_4bd6

	call DrawItemDescription

jr_007_4bd6:
	pop af
	ld hl, wConfirmChoice
	cp [hl]
	jr z, jr_007_4be3

	call DrawBagPage
	call DrawItemDescription

jr_007_4be3:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_4bf4

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	jr jr_007_4c27

jr_007_4bf4:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_4c07

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]
	jr jr_007_4c27

Jump_007_4c07:
	ld a, [wJoyPressed]
	bit 2, a
	jp z, Jump_007_4c27

	ld a, $59
	call QueueSound
	call SortBag
	xor a
	ld [wMenuChoice2], a
	ld [wConfirmChoice], a
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ret


Jump_007_4c27:
jr_007_4c27:
	ret


SortBag::
	ld hl, wBagItems
	ld b, $14

jr_007_4c2d:
	ld a, [hl]
	or a
	jr nz, jr_007_4c33

	ld [hl], $ff

jr_007_4c33:
	inc hl
	dec b
	jr nz, jr_007_4c2d

	ld c, $14

jr_007_4c39:
	ld hl, wBagItems
	ld de, $ca52
	ld b, $13

jr_007_4c41:
	ld a, [de]
	cp [hl]
	jr nc, jr_007_4c4a

	push af
	ld a, [hl]
	ld [de], a
	pop af
	ld [hl], a

jr_007_4c4a:
	inc de
	inc hl
	dec b
	jr nz, jr_007_4c41

	dec c
	jr nz, jr_007_4c39

	ret


ItemListCursorPos::
	db $91, $01, $69, $00, $a9, $00, $e9, $00, $29, $01, $69, $01, $ff, $ff

ItemShowUseDiscard::
	call MenuClearBuffer
	call MenuResetBlink
	ld de, $704d
	call DrawWindow
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
	ld de, $7090
	call DrawWindow
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
	ld de, $7748
	call DrawWindow
	ld de, $4c53
	ld b, $05
	ld a, [wMenuCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListMarks
	ld de, $77d9
	call DrawWindow
	ld de, $798b
	call DrawWindow
	ld de, $4d4b
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld de, $560b
	ld hl, $8e50
	call DecompressVRAM
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ItemUseDiscardInput::
	ld de, $4d4b
	ld hl, wConfirmChoice2
	ld b, $02
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_4cef

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_4d4a

jr_007_4cef:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_4d4a

	ld hl, wBagItems
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	ld hl, far_GetItemData
	rst $10
	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]
	ld a, [wConfirmChoice2]
	cp $80
	jr z, jr_007_4d4a

	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_4d4a:
jr_007_4d4a:
	ret


UseDiscardCursorPos::
	db $61, $00, $a1, $00, $ff, $ff

ItemShowTargets::
	ld a, [$da66]
	cp $02
	jr z, jr_007_4d6b

	cp $03
	jr z, jr_007_4d6b

	ld a, [$da67]
	cp $00
	jr z, jr_007_4d74

	cp $02
	jr z, jr_007_4d74

	cp $04
	jr z, jr_007_4d74

jr_007_4d6b:
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ret


jr_007_4d74:
	ld de, $7748
	call DrawWindow
	ld de, $4c53
	ld b, $05
	ld a, [wMenuCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListMarks
	ld de, $79be
	call DrawWindow
	call DrawItemTargetStats
	call MenuResetBlink
	ld de, $4ef5
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawItemTargetStats::
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	cp $05
	jp z, Jump_007_4e56

	cp $06
	jp z, Jump_007_4e56

	cp $0e
	jp z, Jump_007_4e56

	cp $08
	jp z, Jump_007_4eab

	cp $09
	jp z, Jump_007_4eab

	cp $0b
	jp z, Jump_007_4eab

	cp $0f
	jp z, Jump_007_4eab

	cp $10
	jp z, Jump_007_4eab

	cp $11
	jp z, Jump_007_4eab

	cp $12
	jp z, Jump_007_4eab

	cp $13
	jp z, Jump_007_4eab

	cp $14
	jp z, Jump_007_4eab

	cp $15
	jp z, Jump_007_4eab

	cp $16
	jp z, Jump_007_4eab

	cp $17
	jp z, Jump_007_4eab

	cp $1f
	jp z, Jump_007_4eab

	cp $20
	jp z, Jump_007_4eab

	cp $21
	jp z, Jump_007_4eab

	cp $22
	jp z, Jump_007_4eab

	cp $23
	jp z, Jump_007_4eab

	cp $24
	jp z, Jump_007_4eab

	ld de, $7957
	call DrawWindow
	ld hl, wMonHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
	ld hl, wMonMaxHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3
	jr jr_007_4e80

Jump_007_4e56:
	ld de, $7a08
	call DrawWindow
	ld hl, wMonMP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
	ld hl, wMonMaxMP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3

jr_007_4e80:
	ld hl, wMonStatus
	ld a, [wMenuChoice3]
	call GetPartyMonsterByte
	ld b, a
	ld hl, $01c5
	call BufferAddress
	bit 0, b
	ld a, $e0
	jr z, jr_007_4e98

	ld a, $d7

jr_007_4e98:
	ld [hli], a
	bit 2, b
	ld a, $e0
	jr z, jr_007_4ea1

	ld a, $d8

jr_007_4ea1:
	ld [hli], a
	bit 7, b
	ld a, $e0
	jr z, jr_007_4eaa

	ld a, $d9

jr_007_4eaa:
	ld [hl], a

Jump_007_4eab:
	ret


ItemTargetInput::
	ld de, $4ef5
	ld hl, wMenuChoice3
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
	call MoveMenuCursor
	pop af
	ld hl, wMenuChoice3
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_4ece

	call DrawItemTargetStats
	call MenuShowBuffer

jr_007_4ece:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_4ee3

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_4ef4

jr_007_4ee3:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_4ef4

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_4ef4:
jr_007_4ef4:
	ret


ItemTargetCursorPos::
	db $e1, $00, $21, $01, $61, $01, $ff, $ff

ItemStartUse::
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
	ld hl, wMonName
	ld a, [wMenuChoice3]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	ld l, a
	ld h, $08
	ld de, wTextArg2
	call CopySystemText
	ld a, [$da66]
	cp $00
	jr z, jr_007_4f55

	cp $01
	jr z, jr_007_4f55

	ld h, $0d
	ld a, $01
	ld l, a
	call PrintSystemText
	ld a, $ff
	ld [wItemId], a
	jr jr_007_4f68

jr_007_4f55:
	ld h, $0d
	ld a, [$da69]
	ld l, a
	call PrintSystemText
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
	ld hl, far_CheckItemUsable
	rst $10

jr_007_4f68:
	ld de, $2e07
	call DrawWindow
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ld a, [wItemId]
	cp $1d
	ret nz

	ld a, $57
	call QueueSound
	ret


ItemShowMessage::
	ld a, [wTextState]
	or a
	ret nz

	ld h, $0d
	ld a, [wItemMessage]
	ld l, a
	or a
	jr nz, jr_007_4f96

	ld a, [wItemId]
	cp $ff
	jr nz, jr_007_4fa2

jr_007_4f96:
	ld a, [wItemId]
	cp $ff
	jr nz, jr_007_4f9f

	ld l, $02

jr_007_4f9f:
	call PrintSystemText

jr_007_4fa2:
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ItemApply::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wItemId]
	cp $1d
	jr z, jr_007_5012

	cp $27
	jp z, Jump_007_5077

	ld a, [wItemId]
	cp $ff
	jr z, jr_007_5002

	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld [wItemBagSlot], a
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
	ld hl, far_UseItem
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	call BuildStatusBar
	ld a, [wTextState]
	or a
	jr nz, jr_007_4ffc

	ld a, [wItemId]
	cp $ff
	jr nz, jr_007_5002

	ld a, [wItemUseUpChance]
	cp $64
	jr z, jr_007_5002

	ld h, $0d
	ld l, $00
	call PrintSystemText

jr_007_4ffc:
	ld hl, wFieldMenuStep
	inc [hl]
	jr jr_007_5011

jr_007_5002:
	ld a, [wFieldFlags]
	bit 6, a
	ret nz

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


jr_007_5011:
	ret


jr_007_5012:
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld [wItemBagSlot], a
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
	ld hl, far_UseItem
	rst $10
	call BuildStatusBar
	ld a, $06
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld hl, wFieldFlags
	res 1, [hl]
	ld a, $01
	ld [wMenuOverlay], a
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	call IsInGateWorld
	ret z

	ld hl, far_HealAllMonsters
	rst $10
	ret


Jump_007_5077:
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld [wItemBagSlot], a
	ld a, [wMenuChoice3]
	ld [wItemTarget], a
	ld hl, far_UseItem
	rst $10
	call BuildStatusBar
	ldh a, [hScrollX]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	push hl
	ldh a, [hScrollY]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	push hl
	ld a, [$c960]
	ld [wMapScreen], a
	ld hl, far_Call_0B_4239
	rst $10
	ld hl, wSavedTilemap
	call Decompress
	ld de, wSavedTilemap
	ld a, [$c962]
	ld l, a
	ld a, [$c963]
	ld h, a
	add hl, de
	ld a, $3c
	ld [hli], a
	inc a
	ld [hl], a
	ld a, l
	add $1f
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $3e
	ld [hli], a
	inc a
	ld [hl], a
	ld hl, far_LoadMapAttrBuffer
	rst $10
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a

jr_007_50df:
	call PickRandomFloorSpot
	ld a, [wMapScreen]
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ldh [hPlayerX], a
	ld a, [hli]
	ldh [$ff93], a
	ld a, [hli]
	ldh [hPlayerY], a
	ld a, [hli]
	ldh [$ff96], a
	ld hl, hPlayerX
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
	ld [hl], a
	ld hl, hPlayerY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
	ld [hl], a
	call CheckPlayerOnFloorObject
	jr z, jr_007_50df

	pop hl
	ld a, l
	ldh [hScrollY], a
	ld a, h
	ldh [$ffbc], a
	pop hl
	ld a, l
	ldh [hScrollX], a
	ld a, h
	ldh [$ffb8], a
	ld b, $31
	ld hl, wPlayerTrail

jr_007_512a:
	ldh a, [hPlayerX]
	ld [hli], a
	ldh a, [hPlayerY]
	ld [hli], a
	ldh a, [$ff93]
	swap a
	ld c, a
	ldh a, [$ff96]
	or c
	ld [hli], a
	ldh a, [hPlayerFrame]
	ld c, a
	ldh a, [hPlayerAttr]
	or c
	ld [hli], a
	dec b
	jr nz, jr_007_512a

	xor a
	ld [wTrailPos], a
	ld a, $01
	ld [wMenuOverlay], a
	ld hl, wGameStarted
	set 7, [hl]
	ld hl, wFieldFlags
	res 1, [hl]
	ld a, $03
	call StartFade
	ld hl, wMapLoadState
	inc [hl]
	ret


PickRandomFloorSpot::
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $08
	call Divide8
	add $01
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $01
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call GetCollisionAt
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
	ret z

	jr PickRandomFloorSpot

CheckPlayerOnFloorObject::
	ld hl, wFloorObjects

jr_007_51b4:
	ld a, [hl]
	cp $ff
	jr nz, jr_007_51bb

	or a
	ret


jr_007_51bb:
	bit 7, a
	jr nz, jr_007_51c5

	push hl
	call IsPlayerAtObject
	pop hl
	ret z

jr_007_51c5:
	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_007_51b4

IsPlayerAtObject::
	inc hl
	inc hl
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	or $08
	ld c, a
	ld a, b
	and $0f
	ld b, a
	ldh a, [hPlayerX]
	ld e, a
	ldh a, [$ff93]
	ld d, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld a, d
	or e
	ret nz

	ld a, [hl]
	swap a
	ld b, a
	and $f0
	or $08
	ld c, a
	ld a, b
	and $0f
	ld b, a
	ldh a, [hPlayerY]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld a, d
	or e
	ret


ItemCloseAfterText::
	ld a, [wTextState]
	or a
	ret nz

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


ItemStepIdle::
	ret


ItemMenuEmpty::
	ld a, $02
	ld [wTextGroup], a
	ld a, $0d
	ld [wTextIndex], a
	ld hl, $9700
	ld de, $0901
	call MenuDrawTextTiles
	ld de, $704d
	call DrawWindow
	ld de, $7090
	call DrawWindow
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
	call MenuResetBlink
	ld de, $7748
	call DrawWindow
	ld de, $44b4
	ld a, [wLinkChoice]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ItemEmptyInput::
	ld a, [wJoyPressed]
	and $03
	jr z, jr_007_5279

	ld a, $59
	call QueueSound
	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a

jr_007_5279:
	ret


ItemAskDiscard::
	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $08
	ld de, wTextArg1
	call CopySystemText
	ld hl, $0201
	call PrintSystemText
	ld a, $5c
	call QueueSound
	ld de, $2e07
	call DrawWindow
	ld de, $7a3c
	call DrawWindow
	call MenuResetBlink
	ld de, $5331
	ld a, [wLinkRefused]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ItemDiscardInput::
	ld de, $5331
	ld hl, wLinkRefused
	ld b, $02
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_5309

jr_007_52d7:
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_5330

jr_007_5309:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_5330

	ld a, $59
	call QueueSound
	ld a, [wLinkRefused]
	cp $81
	jr z, jr_007_52d7

	ld hl, wFieldMenuStep
	inc [hl]
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
	ld hl, $0202
	call PrintSystemText

Jump_007_5330:
jr_007_5330:
	ret


DiscardCursorPos::
	db $21, $01, $61, $01, $ff, $ff

ItemDiscard::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wConfirmChoice]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld hl, far_CompactBag
	rst $10
	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


SkillMenu::
	ld a, [wFieldMenuStep]
	rst $00

SkillMenuSteps::
	dw SkillMenuOpen
	dw SkillMenuDraw
	dw SkillMonInput
	dw SkillListShow
	dw SkillListInput
	dw SkillShowTargets
	dw SkillTargetInput
	dw SkillStartUse
	dw SkillApply
	dw SkillCloseAfterText
	dw SkillShowTextWindow
	dw SkillCloseAfterText2
	dw SkillHealAllReport0
	dw SkillHealAllReport1
	dw SkillHealAllReport2
	dw SkillHealAllApply

SkillMenuOpen::
	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
	call CountMonSkills
	call DrawSkillListPage
	ld hl, wFieldMenuStep
	inc [hl]
	ret


SkillMenuDraw::
	call MenuClearBuffer
	ld de, $704d
	call DrawWindow
	ld de, $7090
	call DrawWindow
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
	ld de, $76d1
	call DrawWindow
	ld de, $7687
	call DrawWindow
	call MenuResetBlink
	ld de, $544e
	ld a, [wMenuChoice2]
	call MenuDrawCursorAt
	call MenuShowBuffer
	call DrawSkillListPage
	ld hl, wFieldMenuStep
	inc [hl]
	ret


SkillMonInput::
	ld de, $544e
	ld hl, wMenuChoice2
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
	call MoveMenuCursor
	pop af
	ld hl, wMenuChoice2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_5409

	ld a, [wMenuChoice2]
	ld [wCurPartyMember], a
	call CountMonSkills
	call DrawSkillListPage

jr_007_5409:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_541a

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	jr jr_007_5441

jr_007_541a:
	ld a, [wMenuCount]
	or a
	jr z, jr_007_5441

	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_007_5441

	ld hl, wMonStatus
	ld a, [wMenuChoice2]
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_5442

	ld a, $59
	call QueueSound
	xor a
	ld [wConfirmChoice], a
	ld hl, wFieldMenuStep
	inc [hl]

jr_007_5441:
	ret


jr_007_5442:
	ld hl, $0e0b
	call PrintSystemText
	ld a, $0a
	ld [wFieldMenuStep], a
	ret


SkillMonCursorPos::
	db $a1, $00, $e1, $00, $21, $01, $ff, $ff

DrawSkillListPage::
	ld a, [wMenuCount]
	or a
	jr nz, DrawSkillPage

	ld a, $02
	ld [wTextGroup], a
	ld a, $0d
	ld [wTextIndex], a
	ld hl, $8800
	ld de, $0901
	call MenuDrawTextTiles
	ld hl, $8890
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48
	call ClearTextTiles
	ld b, $48

ClearTextTiles::
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, ClearTextTiles

	ret


DrawSkillPage::
	ld a, [wConfirmChoice2]
	cp $00
	jr z, jr_007_54ab

	ld hl, $caee
	jr jr_007_54ae

jr_007_54ab:
	ld hl, wMonSkills

jr_007_54ae:
	call GetViewedMonsterField
	ld e, l
	ld d, h
	ld hl, $8800
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	call DrawSkillName
	ret


SkillListShow::
	call DrawSkillDescription
	ld de, $7844
	call DrawWindow
	ld de, $78d9
	call DrawWindow
	call DrawSkillMPCost
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call GetPartyMonsterWord
	ld hl, $0125
	call BufferAddress
	call PrintNumber3
	call MenuResetBlink
	ld de, $56a4
	ld a, [wConfirmChoice]
	ld b, $04
	ld hl, wConfirmChoice
	ld a, [wMenuCount]
	ld c, a
	call DrawListMarks
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawSkillDescription::
	ld a, [wConfirmChoice2]
	cp $00
	jr z, jr_007_5510

	ld hl, $caee
	jr jr_007_5513

jr_007_5510:
	ld hl, wMonSkills

jr_007_5513:
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr nz, jr_007_552b

	ld a, $0f

jr_007_552b:
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	ld hl, $94a0
	ld de, $1203
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
	ld hl, far_Call_56_490F
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


CountMonSkills::
	ld hl, wMonSkills
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld b, $08
	ld c, $00

jr_007_557f:
	ld a, [hli]
	cp $ff
	jr z, jr_007_5588

	inc c
	dec b
	jr nz, jr_007_557f

jr_007_5588:
	ld a, c
	ld [wMenuCount], a
	ret


DrawSkillMPCost::
	ld a, [wConfirmChoice2]
	cp $00
	jr z, jr_007_5599

	ld hl, $caee
	jr jr_007_559c

jr_007_5599:
	ld hl, wMonSkills

jr_007_559c:
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	ld d, $00
	call GetSkillMPCost
	ld c, e
	ld b, d
	ld a, e
	add $19
	ld e, a
	ld a, d
	adc $fc
	ld d, a
	ld a, d
	or e
	jr z, jr_007_55cb

	ld hl, $0121
	call BufferAddress
	call PrintNumber3
	ret


jr_007_55cb:
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call GetPartyMonsterWord
	ld hl, $0121
	call BufferAddress
	call PrintNumber3
	ret


SkillListInput::
	ld de, $56a4
	ld hl, wConfirmChoice
	ld a, [wMenuCount]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call MoveListCursor
	pop af
	ld hl, wConfirmChoice
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_5608

	call DrawSkillMPCost
	call MenuShowBuffer
	call DrawSkillDescription

jr_007_5608:
	pop af
	ld hl, wConfirmChoice2
	cp [hl]
	jr z, jr_007_561b

	call DrawSkillPage
	call DrawSkillMPCost
	call MenuShowBuffer
	call DrawSkillDescription

jr_007_561b:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_5635

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	xor a
	ld [wConfirmChoice2], a
	jp Jump_007_56a3


jr_007_5635:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_56a3

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wMonSkills
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice2]
	and $7f
	add a
	add a
	ld b, a
	ld a, [wConfirmChoice]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	cp $2b
	jr z, jr_007_56a3

	cp $2c
	jr z, jr_007_56a3

	cp $2d
	jr z, jr_007_56a3

	cp $2e
	jr z, jr_007_56a3

	cp $2f
	jr z, jr_007_56a3

	cp $30
	jr z, jr_007_56a3

	cp $31
	jr z, jr_007_56a3

	cp $33
	jr z, jr_007_56a3

	cp $36
	jr z, jr_007_56a3

	cp $37
	jr z, jr_007_56a3

	cp $38
	jr z, jr_007_56a3

	cp $7e
	jr z, jr_007_56a3

	ld hl, $0e0a
	call PrintSystemText
	ld a, $0a
	ld [wFieldMenuStep], a
	ret


Jump_007_56a3:
jr_007_56a3:
	ret


SkillListCursorPos::
	db $51, $01, $69, $00, $a9, $00, $e9, $00, $29, $01, $ff, $ff

UnusedDrawSkillPageMark::
	db $21, $50, $01, $cd
	db $89, $68, $fa, $dd, $c8, $e6, $01, $c6, $f1, $cd, $ad, $1a, $f5, $21, $50, $01
	db $7d, $c6, $00, $6f, $7c, $ce, $c5, $67, $f1, $77, $21, $51, $01, $cd, $89, $68
	db $3e, $e7, $cd, $ad, $1a, $f5, $21, $51, $01, $7d, $c6, $00, $6f, $7c, $ce, $c5
	db $67, $f1, $77, $c9

GetSkillMPCost::
	ld a, e
	cp $70
	jr nz, jr_007_56fd

	ld hl, wMonGender
	call GetViewedMonsterByte
	and $01
	cp $00
	jr nz, jr_007_56fd

	ld a, e
	inc a
	inc a
	ld e, a

jr_007_56fd:
	ld l, e
	ld h, d
	add hl, hl
	ld a, l
	add $0c
	ld l, a
	ld a, h
	adc $57
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret


SkillMPCosts::
	db $02, $00, $04, $00, $0a, $00, $04, $00, $06, $00, $0a, $00, $05, $00, $08, $00
	db $0f, $00, $02, $00, $04, $00, $08, $00, $03, $00, $05, $00, $0c, $00, $05, $00
	db $0a, $00, $0f, $00, $04, $00, $07, $00, $01, $00, $03, $00, $05, $00, $03, $00
	db $03, $00, $05, $00, $00, $00, $02, $00, $03, $00, $04, $00, $02, $00, $03, $00
	db $03, $00, $04, $00, $02, $00, $03, $00, $03, $00, $06, $00, $03, $00, $04, $00
	db $04, $00, $05, $00, $02, $00, $02, $00, $05, $00, $07, $00, $12, $00, $24, $00
	db $0a, $00, $14, $00, $e7, $03, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $14, $00, $00, $00, $02, $00, $01, $00, $01, $00, $01, $00, $03, $00
	db $03, $00, $00, $00, $05, $00, $00, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $14, $00
	db $03, $00, $06, $00, $04, $00, $08, $00, $00, $00, $02, $00, $03, $00, $05, $00
	db $03, $00, $06, $00, $03, $00, $05, $00, $02, $00, $04, $00, $08, $00, $10, $00
	db $02, $00, $04, $00, $08, $00, $10, $00, $19, $00, $1e, $00, $e7, $03, $02, $00
	db $02, $00, $03, $00, $03, $00, $04, $00, $03, $00, $04, $00, $04, $00, $03, $00
	db $01, $00, $06, $00, $02, $00, $02, $00, $02, $00, $00, $00, $00, $00, $01, $00
	db $02, $00, $02, $00, $04, $00, $01, $00, $03, $00, $03, $00, $00, $00, $04, $00
	db $07, $00, $07, $00, $07, $00, $08, $00, $14, $00, $14, $00, $14, $00, $14, $00
	db $02, $00, $04, $00, $06, $00, $0a, $00, $04, $00, $00, $00, $03, $00, $02, $00
	db $03, $00, $06, $00, $06, $00, $08, $00, $0c, $00, $14, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $00, $03, $00, $03, $00
	db $03, $00, $14, $00, $05, $00, $00, $00, $02, $00, $02, $00, $00, $00, $00, $00

SkillShowTargets::
	ld a, [wItemId]
	cp $2b
	jr z, jr_007_58f4

	cp $2c
	jr z, jr_007_58f4

	cp $2d
	jr z, jr_007_58f4

	cp $30
	jr z, jr_007_58f4

	cp $31
	jr z, jr_007_58f4

	cp $33
	jr z, jr_007_58f4

	cp $36
	jr z, jr_007_58f4

	ld hl, wFieldMenuStep
	inc [hl]
	ld hl, wFieldMenuStep
	inc [hl]
	ret


jr_007_58f4:
	ld de, $76d1
	call DrawWindow
	ld de, $790d
	call DrawWindow
	ld de, $7957
	call DrawWindow
	call DrawSkillTargetHP
	call MenuResetBlink
	ld de, $544e
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt
	ld de, $56a4
	ld a, [wConfirmChoice]
	ld b, $04
	ld hl, wConfirmChoice
	ld a, [wMenuCount]
	ld c, a
	call DrawListMarks
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


UnusedDrawTargetHP::
	db $21, $11, $cb, $fa, $dd, $c8, $cd, $4f, $22, $21, $01, $02, $cd, $80, $68, $cd
	db $71, $20, $21, $13, $cb, $fa, $dd, $c8, $cd, $4f, $22, $21, $05, $02, $cd, $80
	db $68, $cd, $71, $20, $21, $0b, $cb, $fa, $dd, $c8, $cd, $4a, $22, $47, $21, $c5
	db $01, $cd, $80, $68, $cb, $40, $3e, $e0, $28, $02, $3e, $d7, $22, $cb, $50, $3e
	db $e0, $28, $02, $3e, $d8, $22, $cb, $78, $3e, $e0, $28, $02, $3e, $d9, $77, $c9

SkillTargetInput::
	ld de, $544e
	ld hl, wMenuChoice3
	ld a, [wPartyCount]
	ld b, a
	ld a, [hl]
	push af
	call MoveMenuCursor
	pop af
	and $7f
	ld b, a
	ld hl, wMenuChoice3
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_59a1

	call DrawSkillTargetHP
	call MenuShowBuffer

jr_007_59a1:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_59b6

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_59dd

jr_007_59b6:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_59dd

	ld a, [wMenuChoice3]
	and $7f
	ld [wItemTarget], a
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_59dd:
jr_007_59dd:
	ret


DrawSkillTargetHP::
	ld hl, wMonHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0201
	call BufferAddress
	call PrintNumber3
	ld hl, wMonMaxHP
	ld a, [wMenuChoice3]
	call GetPartyMonsterWord
	ld hl, $0205
	call BufferAddress
	call PrintNumber3
	ld hl, wMonStatus
	ld a, [wMenuChoice3]
	call GetPartyMonsterByte
	ld b, a
	ld hl, $01c5
	call BufferAddress
	bit 0, b
	ld a, $e0
	jr z, jr_007_5a1a

	ld a, $d7

jr_007_5a1a:
	ld [hli], a
	bit 2, b
	ld a, $e0
	jr z, jr_007_5a23

	ld a, $d8

jr_007_5a23:
	ld [hli], a
	bit 7, b
	ld a, $e0
	jr z, jr_007_5a2c

	ld a, $d9

jr_007_5a2c:
	ld [hl], a
	ret


SkillStartUse::
	ld hl, wMonName
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld a, [wItemId]
	ld l, a
	ld h, $06
	ld de, wTextArg2
	call CopySystemText
	ld hl, $0e00
	ld a, [wItemId]
	cp $7e
	jr nz, jr_007_5a58

	ld hl, $0e09

jr_007_5a58:
	call PrintSystemText
	ld de, $2e07
	call DrawWindow
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ld a, $65
	call QueueSound
	ret


SkillApply::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wConfirmChoice2]
	cp $00
	jr z, jr_007_5a7f

	ld hl, $caee
	jr jr_007_5a82

jr_007_5a7f:
	ld hl, wMonSkills

jr_007_5a82:
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, l
	add $0c
	ld l, a
	ld a, h
	adc $57
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call PartyMonsterField
	pop bc
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	ld hl, $0e02
	jp c, Jump_007_5b16

	ld a, [wItemId]
	push af
	ld hl, far_CheckFieldItemUse
	rst $10
	pop bc
	ld a, [wItemId]
	cp $ff
	ld a, b
	jr z, jr_007_5b0c

	ld a, [wItemId]
	cp $2e
	jr z, jr_007_5b06

	cp $2f
	jr z, jr_007_5b06

	cp $37
	jr z, jr_007_5afe

	cp $38
	jr z, jr_007_5afe

	cp $7e
	jr z, jr_007_5afe

	ld hl, $0e07
	cp $36
	jr z, jr_007_5afb

	ld hl, $0e06
	cp $33
	jr z, jr_007_5afb

	ld hl, $0e04
	cp $30
	jr z, jr_007_5afb

	cp $31
	jr z, jr_007_5afb

	ld hl, $0e03

jr_007_5afb:
	call PrintSystemText

jr_007_5afe:
	ld hl, wFieldMenuStep
	inc [hl]
	call PaySkillMP
	ret


jr_007_5b06:
	ld a, $0c
	ld [wFieldMenuStep], a
	ret


jr_007_5b0c:
	ld hl, $0e08
	cp $38
	jr z, jr_007_5b16

	ld hl, $0e01

Jump_007_5b16:
jr_007_5b16:
	call PrintSystemText
	ld hl, wFieldMenuStep
	inc [hl]
	ret


PaySkillMP::
	ld hl, far_UseFieldItem
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	call BuildStatusBar
	ld a, [wConfirmChoice2]
	cp $00
	jr z, jr_007_5b35

	ld hl, $caee
	jr jr_007_5b38

jr_007_5b35:
	ld hl, wMonSkills

jr_007_5b38:
	ld a, [wMenuChoice2]
	call PartyMonsterField
	ld a, [wConfirmChoice]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, l
	add $0c
	ld l, a
	ld a, h
	adc $57
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	ld hl, wMonMP
	ld a, [wMenuChoice2]
	call PartyMonsterField
	pop bc
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret


SkillCloseAfterText::
	ld a, [wTextState]
	or a
	ret nz

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


SkillShowTextWindow::
	ld de, $2e07
	call DrawWindow
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


SkillCloseAfterText2::
	ld a, [wTextState]
	or a
	ret nz

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


SkillHealAllReport0::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wMonStatus
	ld a, $00
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_5be0

	ld a, $00
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr z, jr_007_5be0

	ld hl, wMonName
	ld a, $00
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld hl, $0e03
	call PrintSystemText
	ld de, $2e07
	call DrawWindow
	call MenuShowBuffer

jr_007_5be0:
	ld hl, wFieldMenuStep
	inc [hl]
	ret


SkillHealAllReport1::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [$ca8f]
	cp $ff
	jr z, jr_007_5c2f

	ld hl, wMonStatus
	ld a, $01
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_5c2f

	ld a, $01
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $01
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr z, jr_007_5c2f

	ld hl, wMonName
	ld a, $01
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld hl, $0e03
	call PrintSystemText

jr_007_5c2f:
	ld hl, wFieldMenuStep
	inc [hl]
	ret


SkillHealAllReport2::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [$ca90]
	cp $ff
	jr z, jr_007_5c7e

	ld hl, wMonStatus
	ld a, $02
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_5c7e

	ld a, $02
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $02
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
	or l
	jr z, jr_007_5c7e

	ld hl, wMonName
	ld a, $02
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld hl, $0e03
	call PrintSystemText

jr_007_5c7e:
	ld hl, wFieldMenuStep
	inc [hl]
	ret


SkillHealAllApply::
	ld a, [wTextState]
	or a
	ret nz

	call PaySkillMP
	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


OptionMenu::
	ld a, [wFieldMenuStep]
	rst $00

OptionMenuSteps::
	dw OptionMenuDraw
	dw OptionMenuInput
	dw MessageSpeedShow
	dw MessageSpeedInput
	dw LineUpShow
	dw LineUpInput
	dw SaveShow
	dw SaveInput
	dw SaveDone
	dw OptionCloseAfterText
	dw TacticsStart
	dw TacticsInput

OptionMenuDraw::
	ld de, $2e0d
	ld hl, $9000
	call DecompressVRAM
	call MenuClearBuffer
	ld de, $704d
	call DrawWindow
	ld de, $7090
	call DrawWindow
	ld a, [wGold]
	ldh [hNumber], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call BufferAddress
	call PrintNumber5
	ld de, $7a61
	call DrawWindow
	call MenuResetBlink
	ld de, $5d43
	ld a, [wMenuChoice2]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


OptionMenuInput::
	ld de, $5d43
	ld hl, wMenuChoice2
	ld b, $04
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_5d16

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	jr jr_007_5d42

jr_007_5d16:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_5d42

	ld a, $59
	call QueueSound
	ld b, $02
	ld a, [wMenuChoice2]
	cp $80
	jr z, jr_007_5d3e

	ld b, $04
	cp $81
	jr z, jr_007_5d3e

	ld b, $06
	cp $83
	jr z, jr_007_5d3e

	xor a
	ld [wLinkPartnerChoice], a
	ld b, $0a

jr_007_5d3e:
	ld a, b
	ld [wFieldMenuStep], a

Jump_007_5d42:
jr_007_5d42:
	ret


OptionCursorPos::
	db $66, $00, $a6, $00, $e6, $00, $26, $01, $ff, $ff

MessageSpeedShow::
	ld de, $7ae7
	call DrawWindow
	call MenuResetBlink
	ld de, $5dab
	ld a, [$c8ee]
	ld [wConfirmChoice], a
	ld a, [wConfirmChoice]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


MessageSpeedInput::
	ld de, $5dab
	ld hl, wConfirmChoice
	ld b, $08
	call MoveMenuCursorSideways
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_5d8d

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_5daa

jr_007_5d8d:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_5daa

	ld a, [wConfirmChoice]
	and $7f
	ld [$c8ee], a
	ld a, $59
	call QueueSound
	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a

Jump_007_5daa:
jr_007_5daa:
	ret


	db $c3, $01, $c5, $01, $c7, $01, $c9, $01, $cb, $01, $cd, $01, $cf, $01, $d1, $01
	db $ff, $ff

LineUpShow::
	call MenuLoadPartyNames
	ld b, $00
	ld a, $00
	push bc
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop bc
	bit 7, a
	jr nz, jr_007_5dd1

	inc b

jr_007_5dd1:
	ld a, [wPartyCount]
	cp $01
	jr z, jr_007_5dfd

	ld a, $01
	push bc
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop bc
	bit 7, a
	jr nz, jr_007_5de7

	inc b

jr_007_5de7:
	ld a, [wPartyCount]
	cp $02
	jr z, jr_007_5dfd

	ld a, $02
	push bc
	ld hl, wMonStatus
	call GetPartyMonsterByte
	pop bc
	bit 7, a
	jr nz, jr_007_5dfd

	inc b

jr_007_5dfd:
	ld a, b
	ld [wMenuCount], a
	ld hl, wNumberBackup
	ld a, $00
	ld [hli], a
	ld b, $ff
	ld a, [wMenuCount]
	cp $02
	jr c, jr_007_5e12

	ld b, $01

jr_007_5e12:
	ld [hl], b
	inc hl
	ld b, $ff
	ld a, [wMenuCount]
	cp $03
	jr c, jr_007_5e1f

	ld b, $02

jr_007_5e1f:
	ld [hl], b
	inc hl
	ld a, $ff
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [wLineUpPlaced], a
	ld de, $7b48
	call DrawWindow
	ld de, $7b89
	call DrawWindow
	call DrawLineUp
	call MenuResetBlink
	ld de, $6045
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawLineUp::
	ld a, [wNumberBackup]
	cp $ff
	jr z, jr_007_5e61

	ld a, [$c0a1]
	cp $ff
	jr z, jr_007_5e67

	jr jr_007_5e72

jr_007_5e61:
	ld a, [$c0a1]
	ld [wNumberBackup], a

jr_007_5e67:
	ld a, [$c0a2]
	ld [$c0a1], a
	ld a, $ff
	ld [$c0a2], a

jr_007_5e72:
	ld hl, $c685
	ld a, [wNumberBackup]
	add $f1
	ld b, a
	ld a, [wNumberBackup]
	call DrawLineUpEntry
	ld hl, $c6c5
	ld a, [$c0a1]
	add $f1
	ld b, a
	ld a, [$c0a1]
	call DrawLineUpEntry
	ld hl, $c705
	ld a, [$c0a2]
	add $f1
	ld b, a
	ld a, [$c0a2]
	call DrawLineUpEntry
	ld hl, $c68d
	ld b, $f1
	ld a, [wLineUpOrder]
	call DrawLineUpEntry
	ld hl, $c6cd
	ld b, $f2
	ld a, [$c0a4]
	call DrawLineUpEntry
	ld hl, $c70d
	ld b, $f3
	ld a, [$c0a5]
	call DrawLineUpEntry
	ret


DrawLineUpEntry::
	cp $ff
	jr z, jr_007_5ed4

	ld [hl], b
	inc hl
	inc hl
	add a
	add a
	add $20
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	ret


jr_007_5ed4:
	ld a, $e0
	ld [hli], a
	inc hl
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret


LineUpInput::
	ld a, [wMenuCount]
	ld c, a
	ld a, [wLineUpPlaced]
	cp c
	jr z, jr_007_5ef7

	ld de, $6045
	ld hl, wConfirmChoice2
	ld a, [wLineUpPlaced]
	ld b, a
	ld a, c
	sub b
	ld b, a
	call MoveMenuCursor

jr_007_5ef7:
	ld a, [wConfirmChoice2]
	and $7f
	ld [wConfirmChoice2], a
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_5f64

	ld a, [wLineUpPlaced]
	cp $00
	jr z, jr_007_5f4d

	dec a
	ld hl, wLineUpOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [hl], $ff
	ld [$c0a2], a
	ld hl, wNumberBackup
	call SortStep
	call SortStep
	ld hl, wNumberBackup
	call SortStep
	call SortStep
	ld hl, wNumberBackup
	call SortStep
	call SortStep
	call DrawLineUp
	call MenuShowBuffer
	ld hl, wLineUpPlaced
	dec [hl]
	jp Jump_007_6044


SortStep::
	ld a, [hli]
	ld b, [hl]
	cp b
	ret c

	ld [hld], a
	ld [hl], b
	inc hl
	ret


jr_007_5f4d:
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jp Jump_007_6044


jr_007_5f64:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_6044

	ld a, $59
	call QueueSound
	ld a, [wMenuCount]
	ld c, a
	ld a, [wLineUpPlaced]
	cp c
	jr z, jr_007_5fc9

	ld hl, wLineUpOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice2]
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ld a, $ff
	ld [de], a
	ld a, [wMenuCount]
	ld c, a
	dec c
	ld a, [wLineUpPlaced]
	cp c
	jr nz, jr_007_5fa8

	ld de, $7b48
	call DrawWindow
	jr jr_007_5fbc

jr_007_5fa8:
	ld b, a
	ld a, c
	sub b
	ld b, a
	ld a, [wConfirmChoice2]
	cp b
	jr c, jr_007_5fbc

	dec a
	ld [wConfirmChoice2], a
	ld de, $6045
	call MenuDrawCursorMarks

jr_007_5fbc:
	call DrawLineUp
	call MenuShowBuffer
	ld hl, wLineUpPlaced
	inc [hl]
	jp Jump_007_6044


jr_007_5fc9:
	ld a, [wLineUpOrder]
	call LineUpGetSlot
	ld [wNumberBackup], a
	ld a, [$c0a4]
	call LineUpGetSlot
	ld [$c0a1], a
	ld a, [$c0a5]
	call LineUpGetSlot
	ld [$c0a2], a
	ld a, [wNumberBackup]
	ld [wParty], a
	ld a, [wMenuCount]
	cp $01
	jr z, jr_007_6004

	ld a, [$c0a1]
	ld [$ca8f], a
	ld a, [wMenuCount]
	cp $02
	jr z, jr_007_6004

	ld a, [$c0a2]
	ld [$ca90], a

jr_007_6004:
	ld hl, far_RefreshPartyGfx
	rst $10
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_007_6039

	ld a, [wMapId]
	cp $06
	jr nz, jr_007_6039

	ld a, [wMapScreen]
	or a
	jr nz, jr_007_6039

	ld a, [wPartyGfx]
	cp $ff
	jr z, jr_007_6022

jr_007_6022:
	ld [$d803], a
	ld a, [$ca92]
	cp $ff
	jr z, jr_007_602c

jr_007_602c:
	ld [$d823], a
	ld a, [$ca93]
	cp $ff
	jr z, jr_007_6036

jr_007_6036:
	ld [$d843], a

jr_007_6039:
	call BuildStatusBar
	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a

Jump_007_6044:
	ret


	db $86, $01, $c6, $01, $06, $02, $ff, $ff

LineUpGetSlot::
	cp $ff
	ret z

	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


SaveShow::
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_007_6090

	ld a, [wMapId]
	cp $60
	jr z, jr_007_6090

	cp $61
	jr z, jr_007_6090

	cp $62
	jr z, jr_007_6090

	cp $63
	jr z, jr_007_6090

	cp $64
	jr z, jr_007_6090

	cp $30
	jr c, jr_007_60a5

	cp $5a
	jr z, jr_007_60a5

	cp $5b
	jr z, jr_007_60a5

	cp $5c
	jr z, jr_007_60a5

	cp $50
	jr z, jr_007_60a5

	cp $51
	jr z, jr_007_60a5

jr_007_6090:
	ld hl, $0243
	call PrintSystemText
	ld de, $2e07
	call DrawWindow
	call MenuShowBuffer
	ld a, $09
	ld [wFieldMenuStep], a
	ret


jr_007_60a5:
	ld a, $5c
	call QueueSound
	ld de, $7bca
	call DrawWindow
	ld de, $7c44
	call DrawWindow
	ld de, $2e07
	call DrawWindow
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr nz, jr_007_6122

	ld hl, $0021
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0041
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0061
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0081
	call BufferAddress
	ld bc, $0011
	ld a, $e0
	call FillMemory
	ld hl, $0044
	call BufferAddress
	ld b, $0a
	ld a, $40

jr_007_6107:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_007_6107

	ld a, $31
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	ld hl, $9400
	ld de, $0a01
	call MenuDrawTextTiles
	jp Jump_007_61de


jr_007_6122:
	di
	ld a, $0a
	ld [$0100], a
	ld de, sPlayerName
	ld hl, $93c0
	call MenuDrawNameTiles
	ei
	call DrawSaveParty
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr z, jr_007_61a8

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
	call BufferAddress
	call PrintNumber2
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $01
	jr z, jr_007_61ae

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
	call BufferAddress
	call PrintNumber2
	ld hl, sPartyCount
	call ReadSRAMByte
	cp $02
	jr z, jr_007_61b4

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
	call BufferAddress
	call PrintNumber2
	jr jr_007_61ba

jr_007_61a8:
	ld hl, $0061
	call ClearSaveMemberLevel

jr_007_61ae:
	ld hl, $0067
	call ClearSaveMemberLevel

jr_007_61b4:
	ld hl, $006d
	call ClearSaveMemberLevel

jr_007_61ba:
	ld hl, sPlayHours
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $002d
	call BufferAddress
	call PrintNumber2Zeros
	ld hl, sPlayMinutes
	call ReadSRAMByte
	ld c, a
	ld b, $00
	ld hl, $0030
	call BufferAddress
	call PrintNumber2Zeros

Jump_007_61de:
	ld a, $00
	ld [$0100], a
	ld hl, $0207
	call PrintSystemText
	call MenuResetBlink
	ld de, $6330
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ld hl, wFieldMenuStep
	inc [hl]
	ret


DrawSaveParty::
	ld hl, $8da0
	ld b, $18
	call ClearTextTiles2
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [sParty]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $9400
	ld a, $01
	call DrawSaveMember
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [$a1c9]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $9440
	ld a, $02
	call DrawSaveMember
	di
	ld a, $0a
	ld [$0100], a
	ld hl, sSavedMonName
	ld a, [$a1ca]
	call MonsterField
	ei
	ld e, l
	ld d, h
	ld hl, $9480
	ld a, $03
	call DrawSaveMember
	ret


DrawSaveMember::
	ld b, a
	di
	ld a, $0a
	ld [$0100], a
	ld a, [sPartyCount]
	cp b
	ei
	jr nc, jr_007_6271

	ld b, $20

ClearTextTiles2::
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, ClearTextTiles2

	ret


jr_007_6271:
	push bc
	call MenuDrawNameTiles
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
	ld hl, $62ab
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

ClearSaveMemberLevel::
	push hl
	call BufferAddress
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
	call BufferAddress
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


SaveInput::
	ld de, $6330
	ld hl, wMenuChoice3
	ld b, $02
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_630b

jr_007_62ed:
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_632f

jr_007_630b:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_632f

	ld a, [wMenuChoice3]
	cp $81
	jr nz, jr_007_6321

	ld a, $59
	call QueueSound
	jr jr_007_62ed

jr_007_6321:
	di
	call SaveGame
	ei
	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_632f:
jr_007_632f:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

SaveDone::
	ld hl, $0232
	call PrintSystemText
	ld hl, wFieldMenuStep
	inc [hl]
	ret


OptionCloseAfterText::
	ld a, [wTextState]
	or a
	ret nz

	call MenuClearBuffer
	ld a, $01
	ld [wStatusViewVars], a
	ret


TacticsStart::
	ld a, [wPartyCount]
	or a
	jr z, jr_007_637c

	ld hl, wMonStatus

jr_007_6358:
	ld a, [wLinkPartnerChoice]
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	jr z, jr_007_6374

	ld hl, wLinkPartnerChoice
	inc [hl]
	ld a, [wLinkPartnerChoice]
	ld hl, wPartyCount
	cp [hl]
	jr nz, jr_007_6358

	jr jr_007_637c

jr_007_6374:
	call TacticsShow
	ld hl, wFieldMenuStep
	inc [hl]
	ret


jr_007_637c:
	call MenuClearBuffer
	ld a, $00
	ld [wFieldMenuStep], a
	ret


TacticsShow::
	ld hl, wMonName
	ld a, [wLinkPartnerChoice]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, $93c0
	call MenuDrawNameTiles
	ld de, $7c69
	call DrawWindow
	ld de, $7cd7
	call DrawWindow
	ld hl, wMonGender
	ld a, [wLinkPartnerChoice]
	call PartyMonsterField
	ld a, [hl]
	swap a
	and $03
	ld [wLinkRefused], a
	call MenuResetBlink
	ld de, $644c
	ld a, [wLinkRefused]
	call MenuDrawCursorAt
	call MenuShowBuffer
	ret


TacticsInput::
	ld de, $644c
	ld hl, wLinkRefused
	ld b, $04
	call MoveMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_63fc

jr_007_63d5:
	ld a, [wLinkPartnerChoice]
	or a
	jr z, jr_007_63f2

	ld hl, wLinkPartnerChoice
	dec [hl]
	ld a, [wLinkPartnerChoice]
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_63d5

	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_644b

jr_007_63f2:
	call MenuClearBuffer
	ld a, $00
	ld [wFieldMenuStep], a
	jr jr_007_644b

jr_007_63fc:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_007_644b

	ld a, $59
	call QueueSound
	ld a, [wLinkRefused]
	and $03
	swap a
	ld b, a
	push bc
	ld hl, wMonGender
	ld a, [wLinkPartnerChoice]
	call PartyMonsterField
	ld a, [hl]
	and $cf
	pop bc
	or b
	ld [hl], a

jr_007_6420:
	ld hl, wLinkPartnerChoice
	inc [hl]
	ld a, [wPartyCount]
	ld b, a
	ld a, [wLinkPartnerChoice]
	cp b
	jr z, jr_007_6441

	ld a, [wLinkPartnerChoice]
	ld hl, wMonStatus
	call PartyMonsterField
	bit 7, [hl]
	jr nz, jr_007_6420

	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_644b

jr_007_6441:
	call MenuClearBuffer
	ld a, $00
	ld [wFieldMenuStep], a
	jr jr_007_644b

jr_007_644b:
	ret


	db $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

ShowMonsterStatus::
	ld hl, wCurPartyMember
	ld a, l
	ld [wViewList], a
	ld a, h
	ld [$c931], a
	xor a
	ld [wViewIndex], a
	ld [wViewCount], a

UpdateMonsterStatus::
	ld a, [wFieldMenuStep]
	rst $00

MonsterStatusSteps::
	dw ViewerStart
	dw ViewerOpen
	dw ViewerDrawPage1
	dw ViewerPage1Input
	dw ViewerShowPage2
	dw ViewerPage2Input
	dw ViewerShowSkills
	dw ViewerSkillsInput
	dw ViewerShowPedigree
	dw ViewerPedigreeInput
	dw ViewerStepNext
	dw ViewerClose
	dw ViewerRedrawPage2
	dw ViewerRedrawPedigree

ViewerStart::
	ld a, $01
	ld [wMenuOverlay], a
	ld a, [wViewIndex]
	ld [wViewResult], a
	ld a, [wViewList]
	ld l, a
	ld a, [$c931]
	ld h, a
	ld a, [wViewIndex]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ViewerOpen::
	call SetUpMenuScreen
	ld hl, wFieldMenuStep
	inc [hl]
	ld a, [wCurPartyMember]
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	ret z

	call StatusShowPicture
	ld a, $08
	ld [wFieldMenuStep], a
	ret


ViewerDrawPage1::
	ld de, $70f7
	call DrawWindow
	ld de, $71af
	call DrawWindow
	call DrawStatusStats
	call StatusShowPicture
	ret


ViewerPage1Input::
	call ViewerChangeMonster
	jr z, jr_007_64e8

	call ViewerDrawPage1
	ld hl, wFieldMenuStep
	dec [hl]

jr_007_64e8:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_64f2

	jp ViewerClose


jr_007_64f2:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_6503

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_6503:
	ret


ViewerChangeMonster::
	ld a, [wViewResult]
	push af
	ld a, [wViewCount]
	ld b, a
	or a
	jr z, jr_007_654b

	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_007_6521

	ld a, [wViewResult]
	dec a
	cp b
	jr c, jr_007_6531

	dec b
	ld a, b
	jr jr_007_6531

jr_007_6521:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_007_654b

	ld a, [wViewResult]
	inc a
	cp b
	jr c, jr_007_6531

	ld a, $00

jr_007_6531:
	ld [wViewResult], a
	ld b, a
	ld a, [wViewList]
	ld l, a
	ld a, [$c931]
	ld h, a
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	pop af
	cp b
	ret


jr_007_654b:
	pop af
	xor a
	ret


ViewerShowPage2::
	call StatusShowPage2
	ret


ViewerPage2Input::
	call ViewerChangeMonster
	jr z, jr_007_655e

	ld a, $0c
	ld [wFieldMenuStep], a
	jr jr_007_6587

jr_007_655e:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_007_6573

	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	ld hl, wFieldMenuStep
	dec [hl]
	jr jr_007_6587

jr_007_6573:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_007_6584

	ld a, $59
	call QueueSound
	ld hl, wFieldMenuStep
	inc [hl]

Jump_007_6584:
	call DrawStatusSprite

jr_007_6587:
	ret


ViewerShowSkills::
	ld a, [wCurPartyMember]
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	jr nz, ViewerClose

	call DrawMonSkillNames
	ld de, $737b
	call DrawWindow
	call MenuShowBuffer
	call LoadStatusPicture
	call SetStatusPicPalette
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ViewerSkillsInput::
	call ViewerChangeMonster
	jr z, jr_007_65b8

	call ViewerShowSkills
	ld hl, wFieldMenuStep
	dec [hl]

jr_007_65b8:
	call StatusSkillsButtons
	ret


ViewerShowPedigree::
	call StatusShowPedigree
	ret


ViewerPedigreeInput::
	call ViewerChangeMonster
	jr z, jr_007_65cc

	ld a, $0d
	ld [wFieldMenuStep], a
	jr jr_007_65cf

jr_007_65cc:
	call StatusPedigreeButtons

jr_007_65cf:
	ret


ViewerStepNext::
	ld hl, wFieldMenuStep
	inc [hl]
	ret


ViewerRedrawPage2::
	call SyncStatusMonster
	call DrawStatusPage2
	call LoadStatusPicture
	call SetStatusPicPalette
	ld a, $05
	ld [wFieldMenuStep], a
	ret


ViewerRedrawPedigree::
	call SyncStatusMonster
	call DrawPedigree
	call LoadStatusPicture
	call SetStatusPicPalette
	ld a, $09
	ld [wFieldMenuStep], a
	ret


ViewerClose::
	call MenuClearBuffer
	call MenuShowBuffer
	call ClearMenuBgMap
	ld a, [wGameMode]
	or a
	jr z, jr_007_661b

	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_LoadMapPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	call RestoreFieldAttrMap
	ld hl, far_Call_06_4D5A
	rst $10

jr_007_661b:
	ld a, $00
	ld [wMenuOverlay], a
	ld hl, wMenuSubStep
	inc [hl]
	ret


RestoreFieldAttrMap::
	ld a, [wOnCGB]
	or a
	ret z

	di
	call WaitVRAMAccess
	ld a, $01
	ldh [rVBK], a
	ei
	ldh a, [hScrollY]
	and $f8
	ld l, a
	xor a
	sla l
	rla
	sla l
	rla
	ld h, $98
	add h
	ld h, a
	ldh a, [hScrollX]
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld de, wScreenMap
	ld c, $10

jr_007_6655:
	ld b, $0a
	push hl

jr_007_6658:
	ld a, [de]
	swap a
	and $0f
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
	ld a, [de]
	and $0f
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
	jr nz, jr_007_6658

	pop hl
	ld a, e
	add $06
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, jr_007_6655

	di
	call WaitVRAMAccess
	ld a, $00
	ldh [rVBK], a
	ei
	ret


AlignScrollToTile::
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


LoadMonsterSprite::
	push hl
	add $10
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $6e
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call DecompressVRAM
	ret


DrawStatusSprite::
	ld a, [wGameMode]
	or a
	ret z

	ld hl, wMonRecSpecies
	call GetViewedMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $40
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	push bc
	push hl
	ld hl, wMonStatus
	call GetViewedMonsterByte
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_6701

	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_007_6701

	ld b, $01

jr_007_6701:
	ld a, b
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


DrawPedigreeSprites::
	ld a, [wGameMode]
	or a
	ret z

	ld hl, wMonParent1
	call GetViewedMonsterByte
	cp $ff
	ret z

	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $30
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_007_673b

	ld b, $01

jr_007_673b:
	ld a, b
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ld hl, wMonParent2
	call GetViewedMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_007_676c

	ld b, $01

jr_007_676c:
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


DrawPartySprites::
	ld a, [wStatusViewVars]
	cp $02
	ret nz

	ld a, [wPartyCount]
	or a
	ret z

	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $2f
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	push bc
	push hl
	ld hl, wMonStatus
	ld a, $00
	call GetPartyMonsterByte
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_67bc

	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_007_67bc

	ld b, $01

jr_007_67bc:
	ld a, b
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ld a, [wPartyCount]
	cp $01
	ret z

	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $5f
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	push bc
	push hl
	ld hl, wMonStatus
	ld a, $01
	call GetPartyMonsterByte
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_6806

	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_007_6806

	ld b, $01

jr_007_6806:
	ld a, b
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ld a, [wPartyCount]
	cp $02
	ret z

	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	push af
	ld hl, hSpriteX
	ld a, $8f
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
	pop af
	add $10
	ld [hli], a
	ld b, $00
	push bc
	push hl
	ld hl, wMonStatus
	ld a, $02
	call GetPartyMonsterByte
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_6850

	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_007_6850

	ld b, $01

jr_007_6850:
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


NextMapColumn::
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


AddMenuBgMap::
	ld a, [wMenuBgMap]
	add l
	ld l, a
	ld a, [$c912]
	adc h
	and $03
	ld h, a
	ld a, [$c912]
	and $fc
	or h
	ld h, a
	ret


BufferAddress::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


MenuMapAddress::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call AddMenuBgMap
	ld a, b
	and $1f
	jr z, jr_007_689e

	ld b, a

jr_007_6898:
	call NextMapColumn
	dec b
	jr nz, jr_007_6898

jr_007_689e:
	pop bc
	ret


DrawWindowToMap::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call MenuMapAddress
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a

jr_007_68af:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_007_68d4

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
	ld a, h
	and $03
	or $98
	ld h, a
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	jr jr_007_68af

jr_007_68d4:
	call WriteVRAM
	call NextMapColumn
	jr jr_007_68af

DrawWindow::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call BufferAddress
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a

jr_007_68eb:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_007_690a

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
	jr jr_007_68eb

jr_007_690a:
	ld [hli], a
	jr jr_007_68eb

MenuShowBuffer::
	ld a, [wMenuBgMap]
	ld l, a
	ld a, [$c912]
	ld h, a
	ld de, wTilemapBuffer
	ld c, $12

jr_007_691a:
	ld b, $20
	push hl

jr_007_691d:
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
	jr nz, jr_007_691d

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
	jr nz, jr_007_691a

	ret


DrawFamilyPlus::
	ld b, a
	ld de, $0801
	ld a, c
	cp $ff
	jr z, DrawBlankEntryText

	ld a, b
	push hl
	push af
	ld l, c
	ld h, $04
	ld de, wTextArg0
	call CopySystemText
	pop af
	ld de, wTextArg0
	call MenuAppendPlus
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
	ld de, $0801
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


DrawTextOrBlank::
	ld a, [wTextIndex]
	cp $ff
	jr nz, MenuDrawTextTiles

DrawBlankEntryText:
	ld a, $0a
	ld [wTextIndex], a
	ld a, $04
	ld [wTextGroup], a

MenuDrawTextTiles::
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


MenuDrawNameTiles::
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


DrawSexMark::
	and $01
	add $a7

MenuDrawCharTile::
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


MenuClearBuffer::
	ld hl, wTilemapBuffer
	ld bc, $0240

jr_007_6a95:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_007_6a95

	ret


ClearMenuBgMap::
	ld hl, $9800
	ld bc, $0400

jr_007_6aa4:
	ld a, $e0
	call WriteVRAMInc
	dec bc
	ld a, b
	or c
	jr nz, jr_007_6aa4

	ret


FieldMenuOpen::
	ld hl, wLinkChoice
	ld bc, $0008
	ld a, $00
	call FillMemory

SetUpMenuScreen::
	ld hl, hScrollX
	call AlignScrollToTile
	ld hl, hScrollY
	call AlignScrollToTile
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
	ld [wMenuBgMap], a
	ld a, h
	ld [$c912], a
	call MenuClearBuffer
	call MenuShowBuffer
	call ClearMenuBgMap
	ld de, $2e0d
	ld hl, $9000
	call DecompressVRAM
	call MenuResetBlink
	ld hl, far_ClearAttrMap
	rst $10
	ld hl, wStatusViewVars
	inc [hl]
	ret


FieldMenuClose::
	call MenuClearBuffer
	call MenuShowBuffer
	ld hl, far_ClearAttrMap
	rst $10
	ld hl, far_RefreshPartyGfx
	rst $10
	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_0B_40CE
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	call BuildStatusBar
	call DrawStatusBar
	ld hl, far_Call_06_4D5A
	rst $10
	ld hl, wFieldFlags
	res 1, [hl]
	xor a
	ld [wStatusViewVars], a
	ld a, [wOnGateFloor]
	or a
	ret z

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
	ret


MoveListCursor::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_007_6be6

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_007_6bac

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
	jr c, jr_007_6bca

	ld a, c
	dec a
	jr jr_007_6bca

jr_007_6bac:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_007_6be6

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
	jr c, jr_007_6bca

	ld a, $00

jr_007_6bca:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_007_6c29

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
	jr z, jr_007_6c29

	dec a
	cp [hl]
	jr nc, jr_007_6c29

	ld [hl], a
	jr jr_007_6c29

Jump_007_6be6:
jr_007_6be6:
	push bc
	push de
	push hl
	call DrawListPageDigit
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
	jr nz, MoveMenuCursor

	ld a, [wListLastRows]
	inc a
	ld b, a

MoveMenuCursor::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_007_6c1a

	ld a, [hl]
	dec a
	cp b
	jr c, MenuCursorStore

	dec b
	ld a, b
	jr MenuCursorStore

jr_007_6c1a:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, MenuCursorDone

	ld a, [hl]
	inc a
	cp b
	jr c, MenuCursorStore

	ld a, $00

MenuCursorStore:
	ld [hl], a

jr_007_6c29:
	xor a
	ld [wMenuBlink], a
	push hl
	push de
	pop de
	pop hl

MenuCursorDone:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_007_6c3a

	set 7, [hl]

jr_007_6c3a:
	ld a, [hl]
	call BlinkMenuCursor
	ret


MoveMenuCursorNoSelect::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_007_6c51

	ld a, [hl]
	dec a
	cp b
	jr c, jr_007_6c5f

	dec b
	ld a, b
	jr jr_007_6c5f

jr_007_6c51:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_007_6c68

	ld a, [hl]
	inc a
	cp b
	jr c, jr_007_6c5f

	ld a, $00

jr_007_6c5f:
	ld [hl], a
	xor a
	ld [wMenuBlink], a
	push hl
	push de
	pop de
	pop hl

jr_007_6c68:
	ld a, [hl]
	call BlinkMenuCursor
	ret


MoveMenuCursorSideways::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_007_6c7f

	ld a, [hl]
	dec a
	cp b
	jr c, MenuCursorStore

	dec b
	ld a, b
	jr MenuCursorStore

jr_007_6c7f:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, MenuCursorDone

	ld a, [hl]
	inc a
	cp b
	jr c, MenuCursorStore

	ld a, $00
	jr MenuCursorStore

MenuResetBlink::
	xor a
	ld [wMenuBlink], a
	ret


BlinkMenuCursor::
	ld c, a
	bit 7, a
	jr nz, MenuDrawCursorMarks

	ld a, [wMenuBlink]
	and $0f
	push af
	ld a, [wMenuBlink]
	inc a
	ld [wMenuBlink], a
	pop af
	ld a, c
	ret nz

MenuDrawCursorMarks::
	ld c, a
	ld b, $00

jr_007_6cac:
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
	call MenuMapAddress
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_007_6cdc

	ld a, $e9
	bit 7, c
	jr nz, jr_007_6cdc

	ld a, [wMenuBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_007_6cdc

	ld a, $e8

jr_007_6cdc:
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
	jr jr_007_6cac

DrawListPageDigit::
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
	call MenuMapAddress
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


DrawListMarks::
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
	jr nc, jr_007_6d45

	ld a, $e7

jr_007_6d45:
	ld [hld], a
	pop bc
	jr nc, jr_007_6d4d

	ld a, [bc]
	add $f1
	ld [hl], a

jr_007_6d4d:
	pop af

MenuDrawCursorAt::
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
	call MenuMapAddress
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_007_6d79

	ld a, [wMenuBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_007_6d79

	ld a, $e8

jr_007_6d79:
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


GetViewedMonster::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6da2

	ld a, [wCurPartyMember]
	and $7f
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


jr_007_6da2:
	ld a, [wCurPartyMember]
	and $7f
	ret


GetViewedMonsterField::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6db3

	call CurMonsterField
	ret


jr_007_6db3:
	ld a, [wCurPartyMember]
	call MonsterField
	ret


GetViewedMonsterByte::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6dc5

	call GetCurMonsterByte
	ret


jr_007_6dc5:
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
	ret


GetViewedMonsterWord::
	ld a, [wFieldFlags]
	bit 1, a
	jr z, jr_007_6dd8

	call GetCurMonsterWord
	ret


jr_007_6dd8:
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


MenuAppendPlus::
	push af

jr_007_6de3:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_007_6de3

	dec de
	ld a, $a2
	ld [de], a
	pop af
	or a
	jr z, jr_007_6df8

	inc de
	ld l, e
	ld h, d
	call ByteToDecimal
	ret


jr_007_6df8:
	ld a, $43
	ld [de], a
	inc de
	ld a, $3e
	ld [de], a
	inc de
	ld a, $4a
	ld [de], a
	inc de
	ld a, $46
	ld [de], a
	inc de
	ld a, $49
	ld [de], a
	inc de
	ld a, $56
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
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

DrawNumber3::
	ld de, $0064
	push bc
	call DivideDigit
	pop bc
	or a
	jr z, DrawNumber2

	ld de, $0064
	call DivideDigit
	call MenuDrawDigit
	call NextMapColumn2
	ld de, $000a
	call DivideDigit
	call MenuDrawDigit
	call NextMapColumn2
	jr jr_007_701e

DrawNumber2::
	ld de, $000a
	push bc
	call DivideDigit
	pop bc
	or a
	jr z, jr_007_701e

	ld de, $000a
	call DivideDigit
	call MenuDrawDigit
	call NextMapColumn2

jr_007_701e:
	ld a, c
	call MenuDrawDigit
	ret


DivideDigit::
	push hl
	ld h, $ff

jr_007_7026:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_007_7026

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


MenuDrawDigit::
	add $f0
	call WriteVRAM
	ret


NextMapColumn2::
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


	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $05, $08, $03, $09, $e0, $05, $0b, $d5, $07, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $d6, $06, $05, $de, $e0
	db $09, $e3, $0b, $08, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $0c, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $dd
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $05, $08, $03, $09
	db $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22, $23
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26, $27
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a, $2b
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $07, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $3c, $3d, $3e, $3f, $e0
	db $30, $80, $12, $e4, $e0, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $00, $0b, $06, $e0, $e0, $e4, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $02, $d5, $03, $e0, $e0, $e4, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $00, $dd, $de, $e0, $e0, $e4, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $05, $08, $0b, $e0
	db $e0, $e4, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $0d, $de, $02, $e0, $e0, $e4, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $a7, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $e1, $e3, $e4, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $e2, $e3, $e4, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $55, $01, $e0, $e0, $e0, $e0
	db $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0
	db $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0
	db $e0, $e0, $e0, $e0, $e0, $d9, $35, $00, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0
	db $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0
	db $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0, $e0, $d8, $e0, $e0, $e0, $e0, $e0
	db $e0, $d9, $41, $01, $b0, $b1, $b2, $b3, $b4, $b5, $d8, $b6, $b7, $b8, $b9, $ba
	db $bb, $d8, $bc, $bd, $be, $bf, $c0, $c1, $d8, $c2, $c3, $c4, $c5, $c6, $c7, $d8
	db $c8, $c9, $ca, $cb, $cc, $cd, $d8, $ce, $cf, $d0, $d1, $d2, $d3, $d9, $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $3c
	db $3d, $3e, $3f, $e0, $30, $80, $12, $e4, $e0, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $33, $34, $35, $36
	db $37, $38, $39, $3a, $3b, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $4c, $4d, $4e, $4f, $50, $51, $52, $53
	db $54, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $07
	db $00, $d6, $0b, $d5, $0a, $e4, $55, $56, $57, $58, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $13, $e4, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $a7, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $08, $d5, $0f, $0b, $e0, $de, $df, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $13, $e4, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $6e, $6f, $70, $71
	db $72, $73, $74, $75, $76, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $77, $78, $79, $7a, $7b, $7c, $7d, $7e
	db $7f, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $95, $96, $97, $98
	db $99, $9a, $9b, $9c, $9d, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5
	db $a6, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $07, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $02
	db $00, $02, $e4, $8c, $8d, $8e, $8f, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $4c, $4d, $4e, $4f
	db $50, $51, $52, $53, $54, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $5e, $5f, $60, $61, $62, $63, $64, $65
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $e4, $90, $91, $92, $93, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $27, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $07
	db $09, $07, $e4, $94, $95, $96, $97, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $55, $56, $57, $58
	db $59, $5a, $5b, $5c, $5d, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $66, $67, $68, $69, $6a, $6b, $6c, $6d
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $e4, $98, $99, $9a, $9b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $55, $01
	db $8c, $8d, $8e, $8f, $90, $91, $d8, $92, $93, $94, $95, $96, $97, $d8, $98, $99
	db $9a, $9b, $9c, $9d, $d8, $9e, $9f, $a0, $a1, $a2, $a3, $d8, $a4, $a5, $a6, $a7
	db $a8, $a9, $d8, $aa, $ab, $ac, $ad, $ae, $af, $d9, $40, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d6, $06, $05, $de, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22, $23, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26, $27, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a, $2b, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $48, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $89
	db $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97, $98
	db $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $48, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $70, $71, $72, $73
	db $74, $75, $76, $77, $78, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $80, $81, $82, $83, $84, $85, $86, $87, $88, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $95, $96, $97
	db $98, $99, $9a, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57
	db $58, $59, $5a, $5b, $5c, $5d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $5e, $5f
	db $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $4a
	db $4b, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a
	db $5b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $5c, $5d, $5e, $5f, $60, $61, $62
	db $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a
	db $7b, $7c, $7d, $7e, $7f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $c0, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $0c, $d6, $d5, $e0, $e2, $e3, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $40, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $0d, $04, $09, $e0
	db $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22, $23
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26, $27
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a, $2b
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e1, $e3, $e4, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e5, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $05, $0b, $d5, $07, $ff, $d8, $ec, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $0c, $d6, $d5, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $02, $d5, $de, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd
	db $d9, $80, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $0d, $04, $09
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $20, $21, $22
	db $23, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $24, $25, $26
	db $27, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $29, $2a
	db $2b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e2, $e3, $e4, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e5
	db $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00
	db $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $08, $09, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $fd, $d9, $05, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $09, $e3, $0b, $08, $e0, $e0, $e0, $e0, $ff, $d8, $ec, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $0b, $d5, $0f, $0b
	db $e0, $d6, $e3, $02, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $01, $04, $e0, $09, $0a, $02, $d5, $0a, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $01, $04, $e0, $e3
	db $de, $00, $08, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $0e, $09, $0c, $0a, $08, $00, $de, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $62, $01, $fa, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $03, $00, $d6, $0b, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d6, $de, $09, $0d
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $f1, $e0, $f2, $e0, $f3, $e0, $f4, $e0, $f5
	db $e0, $f6, $e0, $f7, $e0, $f8, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $64, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $6c, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $e4, $3c, $3d, $3e, $3f, $e0
	db $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $da, $40, $41, $42
	db $43, $e0, $db, $44, $45, $46, $47, $e0, $dc, $48, $49, $4a, $4b, $ff, $d8, $fe
	db $e0, $12, $e4, $e0, $e0, $e0, $e0, $12, $e4, $e0, $e0, $e0, $e0, $12, $e4, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $08, $09, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $20, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $01, $04, $00, $0a
	db $dd, $d5, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $07, $05, $0f, $d5, $02, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $01, $00, $0c, $0b
	db $05, $09, $0c, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $01, $09, $07, $07, $00, $08, $02, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $c0, $00, $fa, $ef, $ef, $ef
	db $ef, $fb, $d8, $fe, $3c, $3d, $3e, $3f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd
	db $d9, $a0, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $e0, $e0, $e4, $e0, $e0, $fb, $d8, $fe, $07, $00, $d6, $0b, $d5, $0a, $15
	db $15, $15, $15, $15, $15, $15, $15, $3c, $3d, $3e, $3f, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $0e, $09, $05, $08, $d5, $02, $15, $15, $15, $15, $15, $15, $15
	db $15, $15, $15, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $03, $00, $0a
	db $07, $e0, $e0, $e0, $07, $09, $08, $e0, $e0, $e0, $d5, $dd, $dd, $e0, $e0, $ff
	db $d8, $fe, $d6, $de, $d5, $d5, $e3, $e0, $16, $07, $09, $08, $e0, $e0, $16, $d5
	db $dd, $dd, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0f, $05, $fc, $a7, $04
	db $ac, $00, $01, $24, $13, $11, $8c, $60, $ff, $9e, $86, $79, $7d, $82, $f2, $0d
	db $06, $ff, $f9, $ca, $35, $07, $04, $fd, $fc, $fe, $9f, $fe, $bf, $7f, $0b, $07
	db $2c, $03, $c7, $00, $80, $f9, $00, $25, $24, $1a, $21, $82, $7c, $e4, $02, $c0
	db $7f, $02, $40, $16, $80, $96, $7e, $fc, $54, $10, $3e, $cf, $12, $0b, $04, $07
	db $08, $07, $d9, $1f, $eb, $16, $1f, $f4, $08, $f8, $04, $f8, $f9, $1f, $0b, $20
	db $45, $07, $83, $08, $1f, $00, $45, $fa, $85, $02, $fe, $00, $02, $06, $46, $fa
	db $82, $10, $08, $4e, $07, $88, $99, $77, $11, $11, $77, $11, $77, $11, $43, $07
	db $87, $87, $67, $27, $07, $e7, $99, $99, $43, $ff, $83, $00, $ff, $00, $45, $5a
	db $95, $42, $ff, $23, $11, $77, $77, $11, $77, $11, $11, $ff, $4b, $37, $4b, $37
	db $4b, $37, $4b, $37, $81, $7f, $43, $01, $8b, $7f, $01, $7f, $01, $7f, $01, $7f
	db $01, $01, $7f, $ff, $48, $5a, $02, $44, $ff, $42, $99, $8a, $c3, $89, $00, $00
	db $7e, $bd, $c3, $ff, $3f, $c0, $46, $80, $82, $8e, $71, $06, $82, $7f, $81, $06
	db $84, $ff, $c0, $60, $10, $04, $83, $fe, $30, $18, $05, $87, $80, $c0, $e0, $b8
	db $9e, $88, $54, $06, $82, $80, $c0, $05, $83, $20, $28, $1c, $06, $82, $02, $07
	db $04, $95, $32, $11, $3a, $d8, $04, $01, $01, $ff, $aa, $fa, $aa, $bf, $a1, $80
	db $80, $b6, $80, $be, $9c, $88, $80, $7f, $45, $10, $83, $17, $0f, $00, $45, $06
	db $85, $fe, $fc, $00, $fc, $02, $46, $06, $81, $0f, $4f, $10, $81, $66, $47, $99
	db $43, $10, $87, $70, $90, $90, $f0, $70, $22, $66, $03, $42, $ff, $81, $00, $45
	db $63, $42, $7b, $81, $c6, $43, $99, $8e, $ff, $99, $ff, $ff, $66, $87, $cf, $87
	db $cf, $87, $cf, $87, $cf, $7e, $49, $81, $82, $ff, $81, $43, $ff, $81, $7e, $48
	db $63, $81, $ff, $05, $89, $22, $66, $3c, $42, $91, $ff, $81, $42, $3c, $04, $85
	db $37, $25, $25, $27, $35, $03, $85, $4e, $4a, $4e, $4a, $6a, $03, $42, $8a, $83
	db $da, $aa, $8a, $03, $82, $ea, $4a, $43, $44, $89, $00, $01, $01, $dd, $51, $9d
	db $05, $1d, $00, $45, $01, $8c, $08, $7f, $00, $dd, $15, $d5, $1d, $15, $00, $ff
	db $00, $bb, $43, $12, $93, $93, $00, $ff, $00, $ba, $aa, $b1, $a9, $a9, $00, $ff
	db $01, $81, $81, $01, $02, $04, $24, $f8, $10, $ff, $9f, $70, $00, $88, $70, $80
	db $78, $84, $78, $40, $3c, $12, $0c, $04, $02, $01, $00, $0e, $00, $11, $0e, $01
	db $1e, $21, $1e, $02, $3c, $48, $30, $20, $40, $80, $02, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $07
