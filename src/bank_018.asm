INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $018", ROMX[$4000], BANK[$18]

BankNumber_18::
	db $18

FarTable_18::
	dw Call_18_400B
	dw Call_18_42DE
	dw Call_18_567F
	dw Call_18_5686
	dw Call_18_568D

Call_18_400B::
	xor a
	ld hl, wLinkChoice
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
	xor a
	ld hl, wTitleStep
	ld bc, $0008
	call FillMemory
	ld hl, $9800
	ld a, l
	ld [wTitleBgMap], a
	ld a, h
	ld [$c8d7], a
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ld hl, far_SetSharedBGColors
	rst $10
	ld hl, far_ClearAttrMap
	rst $10
	ld a, $fc
	call StartFade
	ld hl, $9800
	ld bc, $0400
	ld a, $e0
	call FillMemory
	ld de, $3f03
	ld hl, $8800
	call Decompress
	ld de, $2e00
	ld hl, $8d00
	call Decompress
	ld de, $2f00
	ld hl, $8000
	call Decompress
	ld a, [wVSTeamCount]
	ld [wPartyCount], a
	ld a, [wVSTeamSlots]
	ld [wParty], a
	ld a, [$c8c5]
	ld [$ca8f], a
	ld a, [$c8c6]
	ld [$ca90], a
	call Call_18_42D1
	cp $ff
	jr z, jr_018_40d0

	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr z, jr_018_40d0

	ld de, $313f
	push de
	call Call_18_42D1
	ld hl, wMonEgg
	call MonsterField
	pop de
	ld a, [hl]
	or a
	jr nz, jr_018_40ca

	call Call_18_42D1
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, l
	add $23
	ld l, a
	ld a, h
	adc $41
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a

jr_018_40ca:
	ld hl, $8200
	call Decompress

jr_018_40d0:
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
	ld hl, far_Call_56_4485
	rst $10
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [$c83f], a
	ld hl, wMonsters
	ld de, sMonsters
	ld bc, $0ba4
	call Call_18_4604
	call Call_18_5340
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
	call DisableSTATInterrupts
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
	xor a
	ld [wLCDEffect], a
	xor a
	ld [wLinkMode], a
	ld a, $03
	ld [wLCDC], a
	ld a, $01
	jp EnableLCDAndInterrupts


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

Call_18_42D1::
	ld a, [$db55]
	or a
	jr nz, jr_018_42da

	ld a, $15
	ret


jr_018_42da:
	ld a, [wLinkPrizeSlot]
	ret


Call_18_42DE::
	call Call_18_4DDA
	ld a, [wTitleStep]
	rst $00

JumpTable_18_42E5::
	dw Jump_18_4325
	dw Jump_18_434F
	dw Jump_18_4369
	dw Jump_18_4379
	dw Jump_18_4395
	dw Jump_18_43B1
	dw Jump_18_43CD
	dw Jump_18_4405
	dw Jump_18_4468
	dw Jump_18_44AD
	dw Jump_18_44E1
	dw Jump_18_4515
	dw Jump_18_458B
	dw Jump_18_462A
	dw Jump_18_4659
	dw Jump_18_4696
	dw Jump_18_46A1
	dw Jump_18_46AC
	dw Jump_18_47BB
	dw Jump_18_4A5A
	dw Jump_18_4B04
	dw Jump_18_4B09
	dw Jump_18_4B46
	dw Jump_18_4BE3
	dw Jump_18_4BF9
	dw Jump_18_4C49
	dw Jump_18_4CDD
	dw Jump_18_4D1A
	dw Jump_18_4D25
	dw Jump_18_4D4E
	dw Jump_18_4D96
	dw Jump_18_4DB0

Jump_18_4325::
	ld a, $02
	ld [wTextGroup], a
	ld a, $4a
	ld [wTextIndex], a
	ld hl, $96c0
	ld de, $1001
	call Call_18_503B
	call Call_18_5142
	call Call_18_5390
	ld de, $2e07
	call Call_18_4FD5
	call Call_18_5006
	call Call_18_5244
	ld hl, wTitleStep
	inc [hl]
	ret


Jump_18_434F::
	ld a, [wFadeState]
	or a
	jr nz, jr_018_4368

	ld hl, $0246
	ld a, [$db55]
	or a
	jr z, jr_018_4361

	ld hl, $0247

jr_018_4361:
	call PrintSystemText
	ld hl, wTitleStep
	inc [hl]

jr_018_4368:
	ret


Jump_18_4369::
	ld a, [wTextState]
	or a
	jr nz, jr_018_4378

	ld hl, wTitleStep
	inc [hl]
	ld a, $0c
	ld [wLinkChoice], a

jr_018_4378:
	ret


Jump_18_4379::
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	ret nz

	ld a, $00
	call Call_18_4E8F
	ld a, $07
	call Call_18_4E8F
	ld hl, wTitleStep
	inc [hl]
	ld a, $0c
	ld [wLinkChoice], a
	ret


Jump_18_4395::
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	ret nz

	ld a, $01
	call Call_18_4E8F
	ld a, $06
	call Call_18_4E8F
	ld hl, wTitleStep
	inc [hl]
	ld a, $0c
	ld [wLinkChoice], a
	ret


Jump_18_43B1::
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	ret nz

	ld a, $02
	call Call_18_4E8F
	ld a, $05
	call Call_18_4E8F
	ld hl, wTitleStep
	inc [hl]
	ld a, $0c
	ld [wLinkChoice], a
	ret


Jump_18_43CD::
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	ret nz

	ld a, $03
	call Call_18_4E8F
	ld a, $04
	call Call_18_4E8F
	ld hl, wTitleStep
	inc [hl]
	ld a, $20
	ld [wLinkChoice], a
	ld a, $00
	ld [wMenuChoice2], a
	call Call_18_42D1
	cp $ff
	jr z, jr_018_43ff

	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr z, jr_018_43ff

	ret


jr_018_43ff:
	ld a, $1a
	ld [wTitleStep], a
	ret


Jump_18_4405::
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	ret nz

	ld hl, $98c0
	ld a, [wMenuChoice2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_18_4455
	ld hl, $98d3
	ld a, [wMenuChoice2]
	ld b, a
	ld a, l
	sub b
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	call Call_18_4455
	ld a, $04
	ld [wLinkChoice], a
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	cp $0a
	ret nz

	ld hl, wTitleStep
	inc [hl]
	ld a, $b0
	ld [wLinkChoice], a
	ld a, $c0
	ld [wMenuChoice2], a
	ld a, $f8
	ld [wConfirmChoice], a
	ld a, $1e
	ld [wConfirmChoice2], a
	ret


Call_18_4455::
	ld b, $06

jr_018_4457:
	ld a, $e0
	call WriteVRAM
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_018_4457

	ret


Jump_18_4468::
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	jr nz, jr_018_449a

	ld a, $01
	ld [wConfirmChoice2], a
	ld a, [wLinkChoice]
	dec a
	ld [wLinkChoice], a
	call Call_18_4DFC
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	call Call_18_4E2C
	ld a, [wLinkChoice]
	cp $60
	ret nz

	ld hl, wTitleStep
	inc [hl]
	ld a, $1e
	ld [wConfirmChoice2], a
	ret


Jump_018_449a:
jr_018_449a:
	ld a, [wLinkChoice]
	call Call_18_4DFC
	ld a, [wMenuChoice2]
	call Call_18_4E2C
	ld a, [wConfirmChoice]
	call Call_18_4E00
	ret


Jump_18_44AD::
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	jr nz, jr_018_449a

	ld a, $01
	ld [wConfirmChoice2], a
	ld a, [wLinkChoice]
	call Call_18_4DFC
	ld a, [wConfirmChoice]
	call Call_18_4E00
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	call Call_18_4E2C
	ld a, [wMenuChoice2]
	cp $50
	ret nz

	ld hl, wTitleStep
	inc [hl]
	ld a, $1e
	ld [wConfirmChoice2], a
	ret


Jump_18_44E1::
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	jr nz, jr_018_449a

	ld a, $01
	ld [wConfirmChoice2], a
	ld a, [wLinkChoice]
	call Call_18_4DFC
	ld a, [wMenuChoice2]
	call Call_18_4E2C
	ld a, [wConfirmChoice]
	inc a
	ld [wConfirmChoice], a
	call Call_18_4E00
	ld a, [wConfirmChoice]
	cp $40
	ret nz

	ld hl, wTitleStep
	inc [hl]
	ld a, $3c
	ld [wConfirmChoice2], a
	ret


Jump_18_4515::
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	jr z, jr_018_4525

	cp $1e
	jr c, jr_018_4578

	jp Jump_018_449a


jr_018_4525:
	ld a, $01
	ld [wConfirmChoice2], a
	ld a, [wLinkChoice]
	call Call_18_4DFC
	ld a, [wConfirmChoice]
	dec a
	ld [wConfirmChoice], a
	call Call_18_4DFC
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	call Call_18_4E2C
	ld a, [wMenuChoice2]
	cp $fe
	ret nz

	ld hl, wTitleStep
	inc [hl]
	ld de, $c8bb
	ld hl, wTextArg0
	call CopyName
	call Call_18_42D1
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld hl, $0248
	ld a, [$db55]
	or a
	jr z, jr_018_4574

	ld hl, $0249

jr_018_4574:
	call PrintSystemText
	ret


jr_018_4578:
	ld a, [wLinkChoice]
	call Call_18_4DFC
	ld a, [wMenuChoice2]
	call Call_18_4E2C
	ld a, [wConfirmChoice]
	call Call_18_4DFC
	ret


Jump_18_458B::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [$db55]
	or a
	jr nz, jr_018_45fe

	ld de, wMonsters
	ld b, $00

jr_018_459b:
	ld a, [de]
	or a
	jr z, jr_018_45b8

	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc b
	ld a, b
	cp $14
	jr nz, jr_018_459b

	ld hl, $024b
	call PrintSystemText
	ld hl, wTitleStep
	inc [hl]
	ret


jr_018_45b8:
	ld hl, $d5d0
	ld de, wBreedParent2
	ld b, $95

jr_018_45c0:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_018_45c0

	di
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call Call_18_4604
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call Call_18_4604
	ei
	ld hl, wLibraryFlags
	ld a, [$d703]
	call SetFlag
	ld hl, far_CompactMonsters
	rst $10
	di
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call Call_18_4617
	call SaveMonsters
	ei

jr_018_45fe:
	ld a, $1a
	ld [wTitleStep], a
	ret


Call_18_4604::
	ld a, $0a
	ld [$0100], a

jr_018_4609:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_018_4609

	ld a, $00
	ld [$0100], a
	ret


Call_18_4617::
	ld a, $0a
	ld [$0100], a

jr_018_461c:
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_018_461c

	ld a, $00
	ld [$0100], a
	ret


Jump_18_462A::
	ld a, [wTextState]
	or a
	ret nz

	call Call_18_5142
	call Call_18_463D
	call Call_18_5006
	ld hl, wTitleStep
	inc [hl]
	ret


Call_18_463D::
	call Call_18_4EEE
	ld de, $2e07
	call Call_18_4FD5
	ld de, $547a
	call Call_18_4FD5
	call Call_18_5244
	ld de, $4690
	ld a, [wMenuChoice3]
	call Call_18_5303
	ret


Jump_18_4659::
	ld de, $4690
	ld hl, wMenuChoice3
	ld b, $02
	call Call_18_51EB
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_018_4672

jr_018_466b:
	ld hl, wTitleStep
	inc [hl]
	jp Jump_018_468f


jr_018_4672:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_018_468f

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_018_466b

	xor a
	ld [wLinkPartnerChoice], a
	ld a, $1b
	ld [wTitleStep], a

Jump_018_468f:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_18_4696::
	ld hl, $024c
	call PrintSystemText
	ld hl, wTitleStep
	inc [hl]
	ret


Jump_18_46A1::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $1a
	ld [wTitleStep], a
	ret


Jump_18_46AC::
	call Call_18_46D6
	or a
	jr nz, jr_018_46be

	ld hl, $0252
	call PrintSystemText
	ld a, $1e
	ld [wTitleStep], a
	ret


jr_018_46be:
	call Call_18_471E
	ld hl, $024d
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_46ce

	ld hl, $0253

jr_018_46ce:
	call PrintSystemText
	ld hl, wTitleStep
	inc [hl]
	ret


Call_18_46D6::
	ld de, wMonsters
	ld b, $00
	ld c, $00

jr_018_46dd:
	push de
	ld a, [de]
	or a
	jr z, jr_018_470a

	cp $02
	jr z, jr_018_470a

	push bc
	push de
	push hl
	call Call_18_4774
	pop hl
	pop de
	pop bc
	jr nz, jr_018_470a

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [wLinkPartnerChoice]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	jr nz, jr_018_470a

	inc c

jr_018_470a:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc b
	ld a, b
	cp $14
	jr nz, jr_018_46dd

	ld a, c
	ld [wTitleListCount], a
	ret


Call_18_471E::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $00
	ld c, $00

jr_018_4733:
	push de
	ld a, [de]
	or a
	jr z, jr_018_4763

	cp $02
	jr z, jr_018_4763

	push bc
	push de
	push hl
	call Call_18_4774
	pop hl
	pop de
	pop bc
	jr nz, jr_018_4763

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push hl
	ld a, [wLinkPartnerChoice]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, jr_018_4763

	ld [hl], c
	inc hl

jr_018_4763:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	inc b
	ld a, b
	cp $14
	jr nz, jr_018_4733

	ret


Call_18_4774::
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr nz, jr_018_47b5

	ld hl, sStashedParty
	call ReadSRAMByte
	or a
	jr z, jr_018_47b5

	ld hl, $a1f4
	call ReadSRAMByte
	cp b
	jr z, jr_018_47b7

	ld hl, sStashedParty
	call ReadSRAMByte
	cp $01
	jr z, jr_018_47b5

	ld hl, $a1f5
	call ReadSRAMByte
	cp b
	jr z, jr_018_47b7

	ld hl, sStashedParty
	call ReadSRAMByte
	cp $02
	jr z, jr_018_47b5

	ld hl, $a1f6
	call ReadSRAMByte
	cp b
	jr z, jr_018_47b7

jr_018_47b5:
	xor a
	ret


jr_018_47b7:
	ld a, $01
	or a
	ret


Jump_18_47BB::
	ld a, [wTextState]
	or a
	ret nz

	call Call_18_5142
	call Call_18_4970
	call Call_18_480D
	call Call_18_47D4
	call Call_18_5006
	ld hl, wTitleStep
	inc [hl]
	ret


Call_18_47D4::
	call Call_18_4D38
	ld de, $5577
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, jr_018_47ed

	ld de, $55f7
	call Call_18_4FD5
	call Call_18_49F8
	ld de, $549f

jr_018_47ed:
	call Call_18_4FD5
	call Call_18_5244
	ld de, $4aec
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4800

	ld de, $4af8

jr_018_4800:
	ld b, $04
	ld a, [wTitleListCount]
	ld c, a
	ld hl, wListCursor
	call Call_18_52E1
	ret


Call_18_480D::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, jr_018_4869

	ld hl, $9000
	call Call_18_482E
	call Call_18_482E
	call Call_18_482E

Call_18_482E::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_018_484f

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_18_5074
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


jr_018_484f:
	ld b, $20

jr_018_4851:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_018_4851

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


jr_018_4869:
	ld hl, $9000
	call Call_18_487C
	call Call_18_487C
	call Call_18_487C
	call Call_18_487C
	call Call_18_48C0
	ret


Call_18_487C::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_018_48a6

	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call Call_18_503B
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


jr_018_48a6:
	ld b, $48

jr_018_48a8:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_018_48a8

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


Call_18_48C0::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9240
	call Call_18_48DA
	call Call_18_48DA
	call Call_18_48DA

Call_18_48DA::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_018_4956

	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, jr_018_48fb

	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	and $01
	add $a7

jr_018_48fb:
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


jr_018_4956:
	ld b, $08

jr_018_4958:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_018_4958

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


Call_18_4970::
	ld a, [wLinkPartnerChoice]
	and $01
	ret nz

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
	ld hl, $9100
	call Call_18_5074
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9140
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


Call_18_49F8::
	ld a, [wLinkPartnerChoice]
	and $01
	ret nz

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
	call Call_18_4F79
	ld a, $de
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
	call Call_18_5434
	pop af
	push af
	ld hl, wMonsters
	call MonsterField
	pop af
	ld b, a
	ld a, [hl]
	cp $02
	jr z, jr_018_4a46

	call Call_18_4774
	jr nz, jr_018_4a46

	jr jr_018_4a50

jr_018_4a46:
	ld hl, $0169
	call Call_18_4F79
	ld a, $e3
	ld [hl], a
	ret


jr_018_4a50:
	ld hl, $0169
	call Call_18_4F79
	ld a, $e0
	ld [hl], a
	ret


Jump_18_4A5A::
	ld a, [wTextState]
	or a
	ret nz

	ld de, $4aec
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4a6c

	ld de, $4af8

jr_018_4a6c:
	ld hl, wListCursor
	ld a, [wTitleListCount]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_18_5162
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, jr_018_4a8d

	call Call_18_4970
	call Call_18_49F8
	call Call_18_5006

jr_018_4a8d:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_018_4aa0

	call Call_18_480D
	call Call_18_4970
	call Call_18_49F8
	call Call_18_5006

jr_018_4aa0:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_018_4abd

	ld hl, $0251
	call PrintSystemText
	call Call_18_5142
	call Call_18_4D38
	call Call_18_5006
	ld a, $1d
	ld [wTitleStep], a
	jr jr_018_4aeb

jr_018_4abd:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_018_4aeb

	ld a, $59
	call QueueSound
	xor a
	ld [wLinkRefused], a
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
	ld hl, wTitleStep
	inc [hl]

Jump_018_4aeb:
jr_018_4aeb:
	ret


	db $45, $01, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff, $0b, $01, $21, $00
	db $61, $00, $a1, $00, $e1, $00, $ff, $ff

Jump_18_4B04::
	ld hl, wTitleStep
	inc [hl]
	ret


Jump_18_4B09::
	ld a, [wTextState]
	or a
	ret nz

	call Call_18_5142
	call Call_18_4B1C
	call Call_18_5006
	ld hl, wTitleStep
	inc [hl]
	ret


Call_18_4B1C::
	call Call_18_47D4
	ld de, $54f9
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4b2c

	ld de, $5523

jr_018_4b2c:
	call Call_18_4FD5
	call Call_18_5244
	ld de, $4bb8
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4b3f

	ld de, $4bbe

jr_018_4b3f:
	ld a, [wLinkRefused]
	call Call_18_5303
	ret


Jump_18_4B46::
	ld de, $4bb8
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4b53

	ld de, $4bbe

jr_018_4b53:
	ld hl, wLinkRefused
	ld b, $02
	call Call_18_51EB
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_018_4b80

	call Call_18_5142
	call Call_18_4970
	call Call_18_480D
	call Call_18_47D4
	call Call_18_5006
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
	jp Jump_018_4bb7


jr_018_4b80:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_018_4bb7

	ld a, $59
	call QueueSound
	ld a, [wLinkRefused]
	cp $81
	jr z, jr_018_4ba2

	xor a
	ld [wStatusViewVars], a
	ld [wFieldMenuStep], a
	ld hl, wTitleStep
	inc [hl]
	jp Jump_018_4bb7


jr_018_4ba2:
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr z, jr_018_4bb7

Jump_018_4bb7:
jr_018_4bb7:
	ret


	db $2e, $00, $6e, $00, $ff, $ff, $2d, $00, $6d, $00, $ff, $ff, $c5, $cd, $ee, $20
	db $c1, $fe, $ff, $c8, $4f, $fa, $c0, $ca, $b9, $c8, $c5, $79, $21, $45, $a2, $cd
	db $3b, $22, $cd, $ee, $20, $c1, $cb, $7f, $c0, $04, $c9

Jump_18_4BE3::
	xor a
	ld [wMenuSubStep], a
	xor a
	ld [wFieldFlags], a
	ld hl, far_ShowMonsterStatus
	rst $10
	ld a, [wMenuSubStep]
	or a
	ret z

	ld hl, wTitleStep
	inc [hl]
	ret


Jump_18_4BF9::
	ld de, $3f03
	ld hl, $8800
	call DecompressVRAM
	ld de, $2e00
	ld hl, $8d00
	call DecompressVRAM
	ld de, $2f00
	ld hl, $8000
	call DecompressVRAM
	ld a, $02
	ld [wTextGroup], a
	ld a, $4a
	ld [wTextIndex], a
	ld hl, $96c0
	ld de, $1001
	call Call_18_503B
	ld hl, $024d
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4c34

	ld hl, $0253

jr_018_4c34:
	call PrintSystemText
	call RunTextToEnd
	call Call_18_5142
	call Call_18_4970
	call Call_18_480D
	ld a, $14
	ld [wTitleStep], a
	ret


Jump_18_4C49::
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
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, jr_018_4c76

	push hl
	ld a, [hl]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	pop hl

jr_018_4c76:
	push hl
	di
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call Call_18_4604
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call Call_18_4604
	ei
	ld hl, wLibraryFlags
	ld a, [$d703]
	call SetFlag
	pop hl
	ld a, [hl]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	ld hl, far_CompactMonsters
	rst $10
	ld hl, $d5d0
	ld de, wBreedParent2
	ld b, $95

jr_018_4cb0:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_018_4cb0

	ld hl, far_CompactMonsters
	rst $10
	di
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call Call_18_4617
	call SaveMonsters
	ei
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, jr_018_4cd8

	ld hl, $0254
	call PrintSystemText

jr_018_4cd8:
	ld hl, wTitleStep
	inc [hl]
	ret


Jump_18_4CDD::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wGameMode
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld [hl], $00
	ld hl, wGameModeChange
	inc [hl]
	ld a, $00
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
	xor a
	ld [wLinkFlags], a
	ld [wSerialLock], a
	ld [wLinkActive], a
	xor a
	ld [wLinkReceivedLast], a
	xor a
	ld [wLinkSendByte], a
	xor a
	ld [wLinkCommand], a
	ld a, $04
	call StartFade
	ret


Jump_18_4D1A::
	ld hl, $0251
	call PrintSystemText
	ld hl, wTitleStep
	inc [hl]
	ret


Jump_18_4D25::
	ld a, [wTextState]
	or a
	ret nz

	call Call_18_5142
	call Call_18_4D38
	call Call_18_5006
	ld hl, wTitleStep
	inc [hl]
	ret


Call_18_4D38::
	call Call_18_463D
	ld de, $5552
	call Call_18_4FD5
	call Call_18_5244
	ld de, $4d90
	ld a, [wLinkPartnerChoice]
	call Call_18_5303
	ret


Jump_18_4D4E::
	ld de, $4d90
	ld hl, wLinkPartnerChoice
	ld b, $02
	call Call_18_51EB
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_018_4d76

	ld hl, $024f
	call PrintSystemText
	call Call_18_5142
	call Call_18_463D
	call Call_18_5006
	ld a, $0e
	ld [wTitleStep], a
	jr jr_018_4d8f

jr_018_4d76:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_018_4d8f

	ld a, $59
	call QueueSound
	ld a, $11
	ld [wTitleStep], a
	xor a
	ld [wListCursor], a
	ld [wListPage], a

Jump_018_4d8f:
jr_018_4d8f:
	ret


	db $2f, $00, $6f, $00, $ff, $ff

Jump_18_4D96::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0251
	call PrintSystemText
	call Call_18_5142
	call Call_18_4D38
	call Call_18_5006
	ld a, $1d
	ld [wTitleStep], a
	ret


Jump_18_4DB0::
	ld a, [wTextState]
	or a
	ret nz

	call Call_18_5142
	call Call_18_4970
	call Call_18_480D
	call Call_18_47D4
	call Call_18_5006
	ld hl, $024d
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, jr_018_4dd1

	ld hl, $0253

jr_018_4dd1:
	call PrintSystemText
	ld a, $13
	ld [wTitleStep], a
	ret


Call_18_4DDA::
	call Call_18_42D1
	cp $ff
	ret z

	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	ret z

	ld a, [wTitleStep]
	cp $0c
	ret c

	cp $17
	ret z

	cp $18
	ret z

	ld a, [wLinkChoice]
	call Call_18_4DFC
	ret


Call_18_4DFC::
	ld c, $20
	jr jr_018_4e02

Call_18_4E00::
	ld c, $00

jr_018_4e02:
	cp $e0
	ret nc

	ld hl, hSpriteX
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $58
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld b, $02
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_018_4e20

	ld b, $03

jr_018_4e20:
	ld a, b
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, c
	ld [hl], a
	ld hl, far_DrawActorSprite
	rst $10
	ret


Call_18_4E2C::
	ld c, $20
	jr jr_018_4e32

	db $0e, $00

jr_018_4e32:
	cp $e0
	ret nc

	ld hl, hSpriteX
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $58
	ld [hli], a
	ld a, $00
	ld [hli], a
	push bc
	push de
	push hl
	call Call_18_42D1
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	pop hl
	pop de
	pop bc
	or a
	jr nz, jr_018_4e7f

	push bc
	push de
	push hl
	call Call_18_42D1
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	pop hl
	pop de
	pop bc
	add $10
	ld [hli], a
	ld b, $02
	ld a, [wFrameCounter]
	bit 4, a
	jr z, jr_018_4e73

	ld b, $03

jr_018_4e73:
	ld a, b
	ld [hli], a
	ld a, $20
	ld [hli], a
	ld a, c
	ld [hl], a
	ld hl, far_DrawActorSprite
	rst $10
	ret


jr_018_4e7f:
	ld a, $55
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $20
	ld [hli], a
	ld a, c
	ld [hl], a
	ld hl, far_DrawCharacterSprite
	rst $10
	ret


Call_18_4E8F::
	push af
	ld de, $4f46
	ld a, [$db55]
	or a
	jr z, jr_018_4e9c

	ld de, $4f4e

jr_018_4e9c:
	pop af
	push af
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	add a
	ld hl, $0042
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [de]
	cp $ff
	ret z

	add $80
	call Call_18_4ED1
	inc hl
	inc a
	call Call_18_4ED1
	push af
	ld a, l
	add $1f
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	inc a
	call Call_18_4ED1
	inc hl
	inc a
	call Call_18_4ED1
	ret


Call_18_4ED1::
	push hl
	push af
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	pop hl
	push hl
	push af
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $98
	ld h, a
	pop af
	call WriteVRAM
	pop hl
	ret


Call_18_4EEE::
	ld a, $00
	call Call_18_4F0E
	ld a, $01
	call Call_18_4F0E
	ld a, $02
	call Call_18_4F0E
	ld a, $04
	call Call_18_4F0E
	ld a, $05
	call Call_18_4F0E
	ld a, $06
	call Call_18_4F0E
	ld a, $07

Call_18_4F0E::
	push af
	ld de, $4f46
	ld a, [$db55]
	or a
	jr z, jr_018_4f1b

	ld de, $4f4e

jr_018_4f1b:
	pop af
	push af
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	add a
	ld hl, $c542
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [de]
	cp $ff
	ret z

	add $80
	ld [hli], a
	inc a
	ld [hl], a
	push af
	ld a, l
	add $1f
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	ret


	db $00, $04, $08, $ff, $0c, $10, $14, $18, $00, $04, $08, $ff, $1c, $04, $20, $24

Call_18_4F56::
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


Call_18_4F65::
	ld a, [wTitleBgMap]
	add l
	ld l, a
	ld a, [$c8d7]
	adc h
	and $03
	ld h, a
	ld a, [$c8d7]
	and $fc
	or h
	ld h, a
	ret


Call_18_4F79::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_18_4F82::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_18_4F65
	ld a, b
	and $1f
	jr z, jr_018_4f97

	ld b, a

jr_018_4f91:
	call Call_18_4F56
	dec b
	jr nz, jr_018_4f91

jr_018_4f97:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $82, $4f, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $56, $4f, $18, $d3

Call_18_4FD5::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_18_4F79
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a

jr_018_4fe4:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_018_5003

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
	jr jr_018_4fe4

jr_018_5003:
	ld [hli], a
	jr jr_018_4fe4

Call_18_5006::
	ld a, [wTitleBgMap]
	ld l, a
	ld a, [$c8d7]
	ld h, a
	ld de, wTilemapBuffer
	ld c, $12

jr_018_5013:
	ld b, $20
	push hl

jr_018_5016:
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
	jr nz, jr_018_5016

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
	jr nz, jr_018_5013

	ret


Call_18_503B::
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


Call_18_5074::
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
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
	ld de, $0401
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


	db $ea, $80, $c1, $3e, $f0, $ea, $81, $c1, $fa, $27, $c8, $4f, $fa, $28, $c8, $47
	db $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8, $47, $c5, $7d, $ea, $27, $c8, $7c, $ea
	db $28, $c8, $11, $01, $01, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $3e, $02, $ea
	db $22, $c8, $3e, $00, $ea, $23, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27
	db $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9, $21, $00
	db $c5, $11, $00, $c3, $01, $00, $02, $1a, $13, $22, $0b, $78, $b1, $20, $f8, $11
	db $c0, $c1, $0e, $02, $06, $14, $1a, $13, $22, $05, $20, $fa, $7b, $c6, $0c, $5f
	db $7a, $ce, $00, $57, $7d, $c6, $0c, $6f, $7c, $ce, $00, $67, $0d, $20, $e5, $c9

Call_18_5142::
	ld hl, wTilemapBuffer
	ld bc, $0240

jr_018_5148:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_018_5148

	ret


	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

Call_18_5162::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_018_51c9

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_018_518f

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
	jr c, jr_018_51ad

	ld a, c
	dec a
	jr jr_018_51ad

jr_018_518f:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_018_51c9

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
	jr c, jr_018_51ad

	ld a, $00

jr_018_51ad:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_018_520c

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
	jr z, jr_018_520c

	dec a
	cp [hl]
	jr nc, jr_018_520c

	ld [hl], a
	jr jr_018_520c

Jump_018_51c9:
jr_018_51c9:
	push bc
	push de
	push hl
	call Call_18_52A8
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
	jr nz, Call_18_51EB

	ld a, [wListLastRows]
	inc a
	ld b, a

Call_18_51EB::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_018_51fd

	ld a, [hl]
	dec a
	cp b
	jr c, jr_018_520b

	dec b
	ld a, b
	jr jr_018_520b

jr_018_51fd:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_018_5214

	ld a, [hl]
	inc a
	cp b
	jr c, jr_018_520b

	ld a, $00

jr_018_520b:
	ld [hl], a

jr_018_520c:
	xor a
	ld [wTitleBlink], a
	push hl
	push de
	pop de
	pop hl

jr_018_5214:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_018_521d

	set 7, [hl]

jr_018_521d:
	ld a, [hl]
	call Call_18_5249
	ret


	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

Call_18_5244::
	xor a
	ld [wTitleBlink], a
	ret


Call_18_5249::
	ld c, a
	bit 7, a
	jr nz, jr_018_525e

	ld a, [wTitleBlink]
	and $0f
	push af
	ld a, [wTitleBlink]
	inc a
	ld [wTitleBlink], a
	pop af
	ld a, c
	ret nz

jr_018_525e:
	ld c, a
	ld b, $00

jr_018_5261:
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
	call Call_18_4F82
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_018_5291

	ld a, $e9
	bit 7, c
	jr nz, jr_018_5291

	ld a, [wTitleBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_018_5291

	ld a, $e8

jr_018_5291:
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
	jr jr_018_5261

Call_18_52A8::
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
	call Call_18_4F82
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


Call_18_52E1::
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
	jr nc, jr_018_52fa

	ld a, $e7

jr_018_52fa:
	ld [hld], a
	pop bc
	jr nc, jr_018_5302

	ld a, [bc]
	add $f1
	ld [hl], a

jr_018_5302:
	pop af

Call_18_5303::
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
	call Call_18_4F82
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_018_532e

	ld a, [wTitleBlink]
	bit 4, a
	ld a, $e0
	jr nz, jr_018_532e

	ld a, $e8

jr_018_532e:
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


Call_18_5340::
	ld a, [wPartyCount]
	or a
	ret z

	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $9000
	call Call_18_5378
	ld a, [wPartyCount]
	cp $01
	ret z

	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $9240
	call Call_18_5378
	ld a, [wPartyCount]
	cp $02
	ret z

	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $9480

Call_18_5378::
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
	call Decompress
	ret


Call_18_5390::
	ld a, [wPartyCount]
	cp $03
	jr z, jr_018_53cb

	cp $02
	jr z, jr_018_53ac

	ld a, $00
	ld hl, $00c7
	call Call_18_53F8
	ld a, $00
	ld hl, $00c7
	call Call_18_5410
	ret


jr_018_53ac:
	ld a, $00
	ld hl, $00c4
	call Call_18_53F8
	ld hl, $00ca
	call Call_18_53F8
	ld a, $00
	ld hl, $00c4
	call Call_18_5410
	ld a, $01
	ld hl, $00ca
	call Call_18_5410
	ret


jr_018_53cb:
	ld a, $00
	ld hl, $00c1
	call Call_18_53F8
	ld hl, $00c7
	call Call_18_53F8
	ld hl, $00cd
	call Call_18_53F8
	ld a, $00
	ld hl, $00c1
	call Call_18_5410
	ld a, $01
	ld hl, $00c7
	call Call_18_5410
	ld a, $02
	ld hl, $00cd
	call Call_18_5410
	ret


Call_18_53F8::
	ld c, $06

jr_018_53fa:
	push hl
	push af
	call Call_18_4F79
	pop af
	ld b, $06

jr_018_5402:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_018_5402

	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, jr_018_53fa

	ret


Call_18_5410::
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
	ld hl, far_LoadMonPicPalette
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ret


Call_18_5434::
	ld de, $000a
	push bc
	call Call_18_5450
	pop bc
	or a
	jr z, jr_018_544b

	ld de, $000a
	call Call_18_5450
	call Call_18_5465
	call Call_18_546B

jr_018_544b:
	ld a, c
	call Call_18_5465
	ret


Call_18_5450::
	push hl
	ld h, $ff

jr_018_5453:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_018_5453

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


Call_18_5465::
	add $f0
	call WriteVRAM
	ret


Call_18_546B::
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


	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a9, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $6c, $6d, $6e, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e0, $00, $01, $02, $03, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $04, $05, $06, $07, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $08, $09, $0a, $0b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $0c, $0d, $0e, $0f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $6f, $70, $71, $72, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $73, $74, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0c, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $6f, $70, $71, $72, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $73, $74, $e0, $e0, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $00, $fa, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $75, $76, $77, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $78, $79, $7a, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $00
	db $01, $02, $03, $04, $05, $06, $07, $08, $24, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $09, $0a, $0b, $0c, $0d
	db $0e, $0f, $10, $11, $25, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $12, $13, $14, $15, $16, $17, $18, $19, $1a
	db $26, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $27, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $10
	db $11, $12, $13, $14, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $1f, $56, $94, $56, $89, $58, $51, $5a, $a8, $5a, $a2, $5b, $31
	db $5c, $dd, $5c, $15, $5d, $c2, $5d, $8a, $5e, $7a, $5f, $a6, $5f, $b8, $60, $4b
	db $61, $90, $61, $3e, $62, $47, $63, $a7, $63, $bf, $64, $e9, $64, $61, $65, $c9
	db $65, $ca, $66, $ea, $66, $09, $67, $2a, $67, $48, $67, $69, $67, $89, $67, $b1
	db $67, $d0, $67, $36, $69, $67, $69, $e2, $69, $19, $6a, $8e, $6a, $02, $6b, $38
	db $6b, $55, $6b, $b0, $6b, $a0, $6c, $32, $6d, $75, $6d, $b6, $6d, $3d, $6e, $f3
	db $6e, $31, $6f, $4e, $6f

Call_18_567F::
	ld de, $561d
	call StartText
	ret


Call_18_5686::
	ld de, $561d
	call CopyTextString
	ret


Call_18_568D::
	call Call_18_567F
	call RunTextToEnd
	ret


	db $ea, $9f, $a3, $2b, $3e, $62, $45, $3e, $62, $45, $3e, $63, $ef, $ee, $fa, $f7
	db $ef, $ee, $9f, $a3, $2d, $52, $50, $51, $62, $3f, $42, $40, $3e, $52, $50, $42
	db $62, $2c, $ef, $ee, $49, $42, $51, $62, $56, $4c, $52, $62, $4d, $49, $3e, $56
	db $5f, $5f, $5f, $fa, $f7, $ef, $ee, $3c, $4c, $52, $62, $45, $3e, $53, $42, $62
	db $50, $52, $40, $45, $ef, $ee, $40, $4c, $4b, $40, $42, $46, $51, $5f, $5f, $5f
	db $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $54, $3e, $50, $62, $44, $4c, $46, $4b
	db $44, $62, $51, $4c, $ef, $ee, $50, $4a, $3e, $50, $45, $62, $56, $4c, $52, $62
	db $3e, $49, $49, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $37, $45, $42, $4b, $62, $56
	db $4c, $52, $62, $50, $45, $4c, $54, $42, $41, $ef, $ee, $52, $4d, $5f, $5f, $fa
	db $f7, $ef, $ee, $9f, $a3, $36, $52, $40, $45, $62, $3e, $62, $50, $46, $4a, $4d
	db $49, $42, $ef, $ee, $4a, $4c, $4f, $51, $3e, $49, $63, $fa, $f7, $ef, $ee, $9f
	db $a3, $2c, $62, $41, $4c, $4b, $67, $62, $4b, $42, $42, $41, $62, $51, $4c, $ef
	db $ee, $46, $4b, $51, $4f, $4c, $41, $52, $40, $42, $62, $4a, $56, $50, $42, $49
	db $43, $5f, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $3e, $4a, $62, $44, $4c
	db $46, $4b, $44, $62, $51, $4c, $ef, $ee, $3f, $42, $62, $51, $45, $42, $62, $2e
	db $46, $4b, $44, $62, $4c, $43, $62, $51, $45, $42, $fa, $f7, $ef, $ee, $42, $4b
	db $51, $46, $4f, $42, $62, $54, $4c, $4f, $49, $41, $5f, $5f, $5f, $ef, $ee, $fa
	db $f7, $ef, $ee, $9f, $a3, $37, $45, $42, $62, $44, $4f, $42, $3e, $51, $62, $ef
	db $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $63, $fa, $f7, $ef, $ee, $27
	db $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $26, $4c, $4a, $42, $62, $4c, $4b
	db $63, $ef, $ee, $54, $4c, $4f, $51, $45, $49, $42, $50, $50, $62, $4a, $4c, $4f
	db $51, $3e, $49, $50, $63, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c
	db $4f, $42, $a3, $2c, $62, $54, $46, $49, $49, $62, $ef, $ee, $51, $42, $3e, $40
	db $45, $62, $56, $4c, $52, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $27, $42, $3e, $51
	db $45, $30, $4c, $4f, $42, $a3, $5f, $5f, $5f, $45, $4c, $54, $ef, $ee, $45, $42
	db $49, $4d, $49, $42, $50, $50, $62, $3e, $4b, $41, $fa, $f7, $ef, $ee, $46, $4a
	db $4d, $42, $4f, $43, $42, $40, $51, $62, $56, $4c, $52, $ef, $ee, $3e, $4f, $42
	db $63, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $2c
	db $6a, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $5e, $fa, $f7, $ef
	db $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $37, $45, $42, $62, $2e
	db $46, $4b, $44, $ef, $ee, $4c, $43, $62, $3e, $49, $49, $62, $43, $49, $42, $50
	db $45, $63, $63, $f7, $f0, $ea, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3
	db $2b, $3e, $62, $45, $3e, $62, $45, $3e, $ef, $ee, $3c, $4c, $52, $62, $40, $3e
	db $4a, $42, $62, $3f, $3e, $40, $48, $5f, $fa, $f7, $ef, $ee, $27, $42, $3e, $51
	db $45, $30, $4c, $4f, $42, $a3, $2b, $4c, $54, $62, $40, $3e, $4b, $ef, $ee, $56
	db $4c, $52, $62, $3f, $42, $62, $50, $4c, $fa, $f7, $ef, $ee, $43, $4c, $4c, $49
	db $46, $50, $45, $5f, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45
	db $30, $4c, $4f, $42, $a3, $4b, $4c, $51, $62, $ef, $ee, $51, $4c, $62, $4f, $42
	db $3e, $49, $46, $57, $42, $62, $56, $4c, $52, $4f, $fa, $f7, $ef, $ee, $45, $42
	db $49, $4d, $49, $42, $50, $50, $4b, $42, $50, $50, $5e, $ef, $ee, $fa, $f7, $ef
	db $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $3e, $43, $51, $42, $4f
	db $ef, $ee, $50, $52, $40, $45, $62, $3e, $62, $4a, $46, $50, $42, $4f, $3e, $3f
	db $49, $42, $fa, $f7, $ef, $ee, $41, $42, $43, $42, $3e, $51, $63, $ef, $ee, $fa
	db $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $3c, $4c, $52
	db $4f, $ef, $ee, $42, $55, $4d, $42, $4f, $46, $42, $4b, $40, $42, $62, $b6, $fa
	db $f7, $ef, $ee, $51, $4f, $3e, $46, $4b, $46, $4b, $44, $62, $46, $50, $62, $ef
	db $ee, $52, $50, $42, $49, $42, $50, $50, $63, $fa, $f7, $ef, $ee, $27, $42, $3e
	db $51, $45, $30, $4c, $4f, $42, $a3, $3c, $4c, $52, $69, $42, $ef, $ee, $54, $4c
	db $4f, $51, $45, $49, $42, $50, $50, $5f, $fa, $f7, $ef, $ee, $27, $42, $3e, $51
	db $45, $30, $4c, $4f, $42, $a3, $29, $46, $4b, $42, $5f, $ef, $ee, $2c, $62, $54
	db $46, $49, $49, $62, $51, $42, $3e, $40, $45, $62, $56, $4c, $52, $fa, $f7, $ef
	db $ee, $4c, $53, $42, $4f, $62, $3e, $4b, $41, $62, $4c, $53, $42, $4f, $5e, $ef
	db $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $52
	db $4b, $51, $46, $49, $ef, $ee, $56, $4c, $52, $62, $43, $46, $4b, $3e, $49, $49
	db $56, $62, $fa, $f7, $ef, $ee, $52, $4b, $41, $42, $4f, $50, $51, $3e, $4b, $41
	db $5f, $ef, $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42
	db $a3, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $62, $46, $50, $62
	db $51, $45, $42, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $62, $4c, $43, $62, $ef
	db $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $3e
	db $49, $49, $62, $ef, $ee, $43, $49, $42, $50, $45, $63, $f7, $f0, $ea, $27, $42
	db $3e, $51, $45, $30, $4c, $4f, $42, $a3, $24, $4f, $44, $45, $5f, $5f, $ef, $ee
	db $2c, $5f, $5f, $49, $4c, $50, $51, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $27, $42
	db $3e, $51, $45, $30, $4c, $4f, $42, $a3, $2c, $62, $44, $52, $42, $50, $50, $ef
	db $ee, $2c, $62, $40, $3e, $4b, $4b, $4c, $51, $62, $54, $46, $4b, $62, $46, $4b
	db $fa, $f7, $ef, $ee, $51, $45, $46, $50, $62, $43, $4c, $4f, $4a, $5f, $5f, $5f
	db $ef, $ee, $f7, $f0, $eb, $3a, $3e, $51, $3e, $3f, $4c, $52, $a3, $ef, $ee, $27
	db $42, $3e, $51, $45, $30, $4c, $4f, $42, $62, $46, $50, $62, $51, $45, $42, $fa
	db $f7, $ef, $ee, $4a, $4c, $50, $51, $62, $4d, $4c, $54, $42, $4f, $43, $52, $49
	db $ef, $ee, $4c, $43, $62, $51, $45, $42, $62, $42, $53, $46, $49, $fa, $f7, $ef
	db $ee, $49, $4c, $4f, $41, $50, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $3a, $3e, $51
	db $3e, $3f, $4c, $52, $a3, $24, $40, $51, $52, $3e, $49, $49, $56, $ef, $ee, $45
	db $42, $62, $50, $45, $4c, $52, $49, $41, $62, $3f, $42, $fa, $f7, $ef, $ee, $50
	db $51, $4f, $4c, $4b, $44, $42, $4f, $62, $51, $45, $3e, $4b, $ef, $ee, $51, $45
	db $3e, $51, $5f, $fa, $f7, $ef, $ee, $3a, $3e, $51, $3e, $3f, $4c, $52, $a3, $2c
	db $62, $54, $4c, $4b, $41, $42, $4f, $ef, $ee, $46, $43, $62, $46, $51, $68, $62
	db $3f, $42, $40, $3e, $52, $50, $42, $62, $fa, $f7, $ef, $ee, $45, $42, $62, $51
	db $4c, $4c, $48, $62, $3e, $4b, $62, $4c, $49, $41, $62, $ef, $ee, $44, $52, $56
	db $68, $62, $43, $4c, $4f, $4a, $64, $62, $32, $45, $62, $fa, $f7, $ef, $ee, $54
	db $42, $49, $49, $63, $ef, $ee, $fa, $f7, $ef, $ee, $3a, $3e, $51, $3e, $3f, $4c
	db $52, $a3, $31, $4c, $54, $5e, $ef, $ee, $f6, $62, $2f, $42, $51, $68, $62, $44
	db $4c, $fa, $f7, $ef, $ee, $3f, $3e, $40, $48, $63, $ef, $ee, $f7, $f0, $eb, $3a
	db $3e, $51, $3e, $3f, $4c, $52, $a3, $2a, $4c, $4c, $41, $ef, $ee, $4a, $4c, $4f
	db $4b, $46, $4b, $44, $62, $f6, $63, $fa, $f7, $ef, $ee, $2c, $51, $68, $62, $51
	db $46, $4a, $42, $62, $51, $4c, $62, $50, $42, $51, $ef, $ee, $3e, $62, $43, $4c
	db $4c, $51, $62, $4c, $4b, $62, $3e, $4b, $4c, $51, $45, $42, $4f, $fa, $f7, $ef
	db $ee, $47, $4c, $52, $4f, $4b, $42, $56, $63, $ef, $ee, $fa, $f7, $ef, $ee, $3a
	db $3e, $51, $3e, $3f, $4c, $52, $a3, $2c, $66, $49, $62, $3f, $42, $ef, $ee, $54
	db $3e, $46, $51, $46, $4b, $44, $62, $43, $4c, $4f, $62, $56, $3e, $fa, $f7, $ef
	db $ee, $3e, $51, $62, $51, $45, $42, $62, $50, $51, $3e, $3f, $49, $42, $5f, $ef
	db $ee, $26, $4c, $4a, $42, $62, $50, $4c, $4c, $4b, $63, $f7, $f0, $ea, $9f, $a3
	db $32, $45, $5e, $62, $f6, $63, $ef, $ee, $3a, $42, $49, $40, $4c, $4a, $42, $62
	db $3f, $3e, $40, $48, $63, $63, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $3f, $42
	db $49, $46, $42, $53, $42, $41, $62, $ef, $ee, $56, $4c, $52, $6d, $62, $4f, $42
	db $51, $52, $4f, $4b, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $28, $53, $42, $4f, $56
	db $3f, $4c, $41, $56, $62, $4a, $46, $50, $50, $42, $41, $ef, $ee, $56, $4c, $52
	db $62, $54, $45, $46, $49, $42, $62, $56, $4c, $52, $62, $54, $42, $4f, $42, $fa
	db $f7, $ef, $ee, $3e, $54, $3e, $56, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3
	db $37, $45, $42, $62, $2e, $46, $4b, $44, $62, $4a, $46, $50, $50, $42, $41, $ef
	db $ee, $56, $4c, $52, $62, $53, $42, $4f, $56, $62, $4a, $52, $40, $45, $5f, $fa
	db $f7, $ef, $ee, $9f, $a3, $2a, $4c, $62, $50, $42, $42, $62, $51, $45, $42, $62
	db $2e, $46, $4b, $44, $63, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $32, $45, $5e, $62
	db $2a, $4f, $42, $3e, $51, $37, $4f, $42, $42, $62, $46, $50, $ef, $ee, $50, $45
	db $3e, $48, $46, $4b, $44, $63, $62, $2c, $51, $68, $62, $fa, $f7, $ef, $ee, $54
	db $42, $49, $40, $4c, $4a, $46, $4b, $44, $62, $56, $4c, $52, $63, $ef, $ee, $f7
	db $f0, $ea, $9f, $a3, $32, $45, $5e, $62, $30, $4c, $4b, $50, $51, $42, $4f, $ef
	db $ee, $30, $3e, $50, $51, $42, $4f, $62, $f6, $63, $fa, $f7, $ef, $ee, $3a, $45
	db $42, $4f, $42, $62, $45, $3e, $53, $42, $ef, $ee, $56, $4c, $52, $62, $3f, $42
	db $42, $4b, $64, $fa, $f7, $ef, $ee, $9f, $a3, $37, $45, $42, $62, $2e, $46, $4b
	db $44, $62, $3e, $4b, $41, $ef, $ee, $42, $53, $42, $4f, $56, $3f, $4c, $41, $56
	db $62, $54, $42, $4f, $42, $62, $fa, $f7, $ef, $ee, $49, $4c, $4c, $48, $46, $4b
	db $44, $62, $43, $4c, $4f, $62, $56, $4c, $52, $63, $ef, $ee, $fa, $f7, $ef, $ee
	db $9f, $a3, $2b, $46, $50, $62, $4a, $3e, $47, $42, $50, $51, $56, $62, $46, $50
	db $ef, $ee, $54, $3e, $46, $51, $46, $4b, $44, $62, $43, $4c, $4f, $62, $56, $4c
	db $52, $5f, $fa, $f7, $ef, $ee, $2a, $4c, $62, $4d, $4f, $42, $50, $42, $4b, $51
	db $62, $ef, $ee, $56, $4c, $52, $4f, $50, $42, $49, $43, $63, $f7, $f0, $ea, $2e
	db $46, $4b, $44, $a3, $f6, $63, $ef, $ee, $2c, $51, $68, $62, $56, $4c, $52, $62
	db $f6, $63, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3a, $45, $42, $4f, $42
	db $62, $46, $4b, $62, $51, $45, $42, $ef, $ee, $54, $4c, $4f, $49, $41, $62, $45
	db $3e, $53, $42, $62, $56, $4c, $52, $fa, $f7, $ef, $ee, $3f, $42, $42, $4b, $64
	db $62, $36, $52, $41, $41, $42, $4b, $49, $56, $ef, $ee, $41, $46, $50, $3e, $4d
	db $4d, $42, $3e, $4f, $46, $4b, $44, $62, $49, $46, $48, $42, $fa, $f7, $ef, $ee
	db $51, $45, $3e, $51, $63, $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3
	db $3a, $42, $6c, $42, $62, $3f, $42, $42, $4b, $62, $ef, $ee, $54, $3e, $46, $51
	db $46, $4b, $44, $62, $43, $4c, $4f, $62, $56, $4c, $52, $5f, $fa, $f7, $ef, $ee
	db $2e, $46, $4b, $44, $a3, $32, $45, $63, $62, $37, $45, $42, $50, $42, $ef, $ee
	db $43, $4c, $49, $48, $50, $62, $54, $42, $4f, $42, $62, $54, $3e, $46, $51, $46
	db $4b, $44, $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $56, $4c, $52, $62, $51, $4c
	db $4c, $63, $ef, $ee, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $2c, $62, $45, $3e
	db $53, $42, $62, $ef, $ee, $4d, $4f, $42, $4d, $3e, $4f, $42, $41, $62, $3e, $62
	db $4d, $4f, $46, $57, $42, $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $56, $4c, $52
	db $4f, $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $ef, $ee, $fa, $f7, $ef, $ee
	db $2e, $46, $4b, $44, $a3, $2a, $4c, $62, $51, $4c, $62, $51, $45, $42, $ef, $ee
	db $26, $45, $3e, $4a, $3f, $42, $4f, $62, $4c, $43, $fa, $f7, $ef, $ee, $37, $4f
	db $3e, $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51, $42, $50, $5f, $ef
	db $ee, $37, $45, $42, $4f, $42, $62, $54, $46, $49, $49, $62, $3f, $42, $62, $4b
	db $42, $54, $fa, $f7, $ef, $ee, $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c
	db $62, $2a, $3e, $51, $42, $50, $ef, $ee, $54, $3e, $46, $51, $46, $4b, $44, $62
	db $43, $4c, $4f, $62, $56, $4c, $52, $5f, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44
	db $a3, $3a, $42, $49, $49, $5e, $62, $2c, $62, $3e, $4a, $62, $ef, $ee, $3f, $52
	db $50, $56, $5f, $62, $3c, $4c, $52, $69, $42, $fa, $f7, $ef, $ee, $41, $46, $50
	db $4a, $46, $50, $50, $42, $41, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b
	db $44, $a3, $25, $52, $50, $56, $63, $62, $25, $52, $50, $56, $63, $ef, $ee, $25
	db $52, $50, $56, $63, $f7, $f0, $eb, $9f, $a3, $36, $46, $4f, $62, $f6, $5e, $ef
	db $ee, $37, $45, $3e, $4b, $48, $62, $56, $4c, $52, $62, $43, $4c, $4f, $62, $51
	db $45, $42, $fa, $f7, $ef, $ee, $53, $46, $40, $51, $4c, $4f, $56, $5f, $ef, $ee
	db $f7, $f0, $eb, $9f, $a3, $f6, $5e, $62, $51, $45, $3e, $4b, $48, $50, $ef, $ee
	db $51, $4c, $62, $56, $4c, $52, $5e, $62, $46, $51, $62, $54, $3e, $50, $62, $51
	db $45, $42, $fa, $f7, $ef, $ee, $3f, $42, $50, $51, $62, $36, $51, $3e, $4f, $4f
	db $56, $62, $31, $46, $44, $45, $51, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3
	db $2f, $46, $50, $51, $42, $4b, $5e, $62, $2c, $62, $45, $42, $3e, $4f, $41, $ef
	db $ee, $3e, $4b, $62, $46, $4b, $51, $42, $4f, $42, $50, $51, $46, $4b, $44, $62
	db $fa, $f7, $ef, $ee, $50, $3e, $56, $46, $4b, $44, $5f, $62, $2c, $51, $62, $44
	db $4c, $42, $50, $60, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $30, $4c, $4b, $48
	db $42, $56, $50, $62, $54, $46, $49, $49, $62, $3f, $42, $ef, $ee, $4f, $42, $3f
	db $4c, $4f, $4b, $62, $3e, $50, $62, $fa, $f7, $ef, $ee, $42, $49, $42, $4d, $45
	db $3e, $4b, $51, $50, $5e, $62, $51, $45, $42, $4b, $ef, $ee, $41, $4f, $42, $3e
	db $4a, $62, $3e, $3f, $4c, $52, $51, $62, $49, $46, $4c, $4b, $50, $fa, $f7, $ef
	db $ee, $50, $4c, $4a, $42, $62, $41, $3e, $56, $5f, $ef, $ee, $fa, $f7, $ef, $ee
	db $9f, $a3, $2c, $62, $54, $4c, $4b, $41, $42, $4f, $62, $54, $45, $3e, $51, $62
	db $ef, $ee, $46, $51, $62, $40, $4c, $52, $49, $41, $62, $4a, $42, $3e, $4b, $64
	db $fa, $f7, $ef, $ee, $24, $62, $4a, $4c, $4b, $48, $42, $56, $62, $3f, $42, $40
	db $4c, $4a, $42, $50, $ef, $ee, $3e, $4b, $62, $42, $49, $42, $4d, $45, $3e, $4b
	db $51, $64, $f7, $f0, $ea, $9f, $a3, $2b, $46, $50, $62, $4a, $3e, $47, $42, $50
	db $51, $56, $ef, $ee, $44, $3e, $53, $42, $62, $56, $4c, $52, $62, $3e, $62, $4f
	db $42, $54, $3e, $4f, $41, $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $51, $45, $42
	db $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f
	db $a3, $37, $45, $42, $4f, $42, $62, $3e, $4f, $42, $62, $4b, $42, $54, $ef, $ee
	db $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51, $42, $50
	db $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $56, $4c, $52, $62, $46, $4b, $62, $51
	db $45, $42, $ef, $ee, $26, $45, $3e, $4a, $3f, $42, $4f, $62, $4c, $43, $fa, $f7
	db $ef, $ee, $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51
	db $42, $50, $63, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $30, $3e, $50, $51, $42, $4f
	db $62, $30, $4c, $4b, $50, $51, $42, $4f, $ef, $ee, $f6, $5e, $62, $4d, $49, $42
	db $3e, $50, $42, $fa, $f7, $ef, $ee, $50, $51, $3e, $56, $62, $45, $42, $4f, $42
	db $62, $46, $4b, $62, $51, $45, $46, $50, $ef, $ee, $48, $46, $4b, $44, $41, $4c
	db $4a, $62, $43, $4c, $4f, $42, $53, $42, $4f, $63, $f7, $f0, $eb, $9f, $a3, $37
	db $45, $42, $62, $2e, $46, $4b, $44, $62, $44, $3e, $53, $42, $62, $ef, $ee, $56
	db $4c, $52, $62, $3e, $62, $50, $4d, $42, $40, $46, $3e, $49, $fa, $f7, $ef, $ee
	db $4d, $42, $4f, $4a, $46, $50, $50, $46, $4c, $4b, $5f, $ef, $ee, $fa, $f7, $ef
	db $ee, $9f, $a3, $29, $4f, $4c, $4a, $62, $4b, $4c, $54, $62, $4c, $4b, $5e, $ef
	db $ee, $51, $45, $46, $50, $62, $50, $42, $40, $4f, $42, $51, $62, $4d, $3e, $51
	db $45, $fa, $f7, $ef, $ee, $46, $50, $62, $3e, $49, $49, $62, $56, $4c, $52, $4f
	db $50, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $5f, $5f, $3a, $4c, $52, $49
	db $41, $62, $56, $4c, $52, $62, $49, $46, $48, $42, $ef, $ee, $51, $4c, $62, $45
	db $42, $3e, $4f, $62, $51, $45, $42, $62, $49, $42, $44, $42, $4b, $41, $fa, $f7
	db $ef, $ee, $4c, $43, $62, $51, $45, $42, $62, $36, $51, $3e, $4f, $4f, $56, $62
	db $ef, $ee, $31, $46, $44, $45, $51, $64, $ff, $f0, $eb, $9f, $a3, $37, $45, $42
	db $62, $36, $51, $3e, $4f, $4f, $56, $62, $31, $46, $44, $45, $51, $ef, $ee, $40
	db $4c, $4a, $42, $50, $62, $3e, $43, $51, $42, $4f, $62, $42, $53, $42, $4f, $56
	db $62, $fa, $f7, $ef, $ee, $04, $07, $51, $45, $62, $43, $52, $49, $49, $62, $4a
	db $4c, $4c, $4b, $5f, $62, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $2b, $52, $4b
	db $41, $4f, $42, $41, $50, $62, $4c, $43, $62, $ef, $ee, $51, $45, $4c, $52, $50
	db $3e, $4b, $41, $50, $62, $4c, $43, $62, $50, $51, $3e, $4f, $50, $fa, $f7, $ef
	db $ee, $9f, $a3, $43, $3e, $49, $49, $62, $51, $4c, $62, $43, $46, $49, $49, $62
	db $51, $45, $42, $ef, $ee, $50, $48, $56, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $29
	db $4f, $3e, $44, $4a, $42, $4b, $51, $50, $62, $4c, $43, $62, $ef, $ee, $49, $46
	db $44, $45, $51, $62, $40, $4c, $53, $42, $4f, $62, $51, $45, $42, $fa, $f7, $ef
	db $ee, $54, $4c, $4f, $49, $41, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $37
	db $45, $3e, $51, $68, $62, $51, $45, $42, $62, $ef, $ee, $36, $51, $3e, $4f, $4f
	db $56, $62, $31, $46, $44, $45, $51, $5f, $62, $fa, $f7, $ef, $ee, $9f, $a3, $37
	db $45, $42, $62, $4b, $46, $44, $45, $51, $62, $54, $45, $42, $4b, $ef, $ee, $40
	db $4c, $52, $4b, $51, $49, $42, $50, $50, $62, $49, $46, $53, $42, $50, $62, $fa
	db $f7, $ef, $ee, $50, $45, $4c, $54, $42, $4f, $62, $41, $4c, $54, $4b, $5f, $ef
	db $ee, $f7, $f0, $eb, $9f, $a3, $37, $45, $42, $62, $50, $51, $4c, $4f, $56, $62
	db $4c, $43, $ef, $ee, $30, $4c, $4b, $50, $51, $42, $4f, $62, $30, $3e, $50, $51
	db $42, $4f, $fa, $f7, $ef, $ee, $f6, $62, $54, $46, $49, $49, $62, $3f, $42, $ef
	db $ee, $45, $3e, $4b, $41, $42, $41, $62, $41, $4c, $54, $4b, $62, $43, $4f, $4c
	db $4a, $fa, $f7, $ef, $ee, $44, $42, $4b, $42, $4f, $3e, $51, $46, $4c, $4b, $62
	db $51, $4c, $ef, $ee, $44, $42, $4b, $42, $4f, $3e, $51, $46, $4c, $4b, $5f, $5f
	db $5f, $f7, $f0, $eb, $9f, $a3, $2f, $4c, $4b, $44, $62, $49, $4c, $4b, $44, $62
	db $3e, $44, $4c, $5f, $5f, $ef, $ee, $24, $4b, $62, $3e, $4b, $40, $42, $50, $51
	db $4c, $4f, $62, $4c, $43, $fa, $f7, $ef, $ee, $3a, $3e, $51, $3e, $3f, $4c, $52
	db $62, $49, $4c, $40, $48, $42, $41, $ef, $ee, $4a, $4c, $4b, $50, $51, $42, $4f
	db $50, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $3f, $42, $45, $46, $4b, $41
	db $62, $51, $45, $42, $ef, $ee, $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c
	db $62, $2a, $3e, $51, $42, $50, $fa, $f7, $ef, $ee, $3f, $42, $40, $3e, $52, $50
	db $42, $62, $51, $45, $42, $56, $62, $54, $42, $4f, $42, $ef, $ee, $3e, $62, $3f
	db $3e, $4b, $42, $62, $51, $4c, $62, $45, $52, $4a, $3e, $4b, $50, $5f, $fa, $f7
	db $ef, $ee, $9f, $a3, $32, $52, $4f, $50, $62, $3e, $4b, $40, $42, $50, $51, $4c
	db $4f, $50, $62, $ef, $ee, $41, $42, $4a, $3e, $4b, $41, $42, $41, $62, $54, $42
	db $a4, $fa, $f7, $ef, $ee, $9f, $a3, $a4, $45, $4c, $49, $41, $62, $3e, $62, $ef
	db $ee, $51, $4c, $52, $4f, $4b, $3e, $4a, $42, $4b, $51, $62, $42, $53, $42, $4f
	db $56, $fa, $f7, $ef, $ee, $36, $51, $3e, $4f, $4f, $56, $62, $31, $46, $44, $45
	db $51, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $24, $43, $51, $42, $4f, $62
	db $4a, $3e, $4b, $56, $62, $ef, $ee, $40, $42, $4b, $51, $52, $4f, $46, $42, $50
	db $5e, $62, $fa, $f7, $ef, $ee, $f6, $62, $54, $3e, $50, $62, $ef, $ee, $53, $46
	db $40, $51, $4c, $4f, $46, $4c, $52, $50, $63, $f7, $f0, $ea, $2e, $46, $4b, $44
	db $a3, $32, $45, $5e, $62, $f6, $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e
	db $51, $62, $fa, $f7, $ef, $ee, $27, $4f, $3e, $40, $4c, $2f, $4c, $4f, $41, $63
	db $ef, $ee, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $3c, $4c, $52, $62, $40
	db $4c, $52, $49, $41, $62, $ef, $ee, $3f, $42, $3e, $51, $62, $3e, $4b, $62, $42
	db $53, $46, $49, $62, $49, $4c, $4f, $41, $5f, $fa, $f7, $ef, $ee, $2e, $46, $4b
	db $44, $a3, $2c, $62, $40, $3e, $4b, $4b, $4c, $51, $62, $43, $46, $4b, $41, $ef
	db $ee, $3e, $62, $43, $46, $51, $51, $46, $4b, $44, $62, $4d, $4f, $3e, $46, $50
	db $42, $5f, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3c, $4c, $52, $62, $50
	db $45, $4c, $52, $49, $41, $62, $3f, $42, $ef, $ee, $51, $45, $42, $62, $2e, $46
	db $4b, $44, $62, $46, $4b, $50, $51, $42, $3e, $41, $63, $f7, $f0, $ea, $2e, $46
	db $4b, $44, $a3, $2d, $52, $50, $51, $62, $48, $46, $41, $41, $46, $4b, $44, $63
	db $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $2b, $3e, $62, $45, $3e
	db $62, $45, $3e, $62, $45, $3e, $63, $ef, $ee, $3a, $4c, $4f, $48, $62, $45, $3e
	db $4f, $41, $63, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3c, $4c, $52, $69
	db $42, $ef, $ee, $41, $46, $50, $4a, $46, $50, $50, $42, $41, $5f, $fa, $f7, $ef
	db $ee, $25, $52, $50, $56, $63, $62, $25, $52, $50, $56, $63, $ef, $ee, $25, $52
	db $50, $56, $63, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $ef
	db $ee, $3c, $4c, $52, $62, $45, $3e, $53, $42, $62, $44, $4c, $4c, $41, $fa, $f7
	db $ef, $ee, $46, $4b, $51, $42, $4b, $51, $46, $4c, $4b, $50, $63, $ef, $ee, $fa
	db $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3a, $4c, $4f, $48, $46, $4b, $44, $62
	db $45, $3e, $4f, $41, $62, $ef, $ee, $51, $4c, $62, $43, $46, $4b, $41, $62, $4a
	db $4c, $4b, $50, $51, $42, $4f, $50, $62, $fa, $f7, $ef, $ee, $42, $53, $42, $4b
	db $62, $3e, $43, $51, $42, $4f, $62, $56, $4c, $52, $4f, $62, $ef, $ee, $53, $46
	db $40, $51, $4c, $4f, $56, $63, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $f6
	db $62, $46, $50, $62, $ef, $ee, $51, $4f, $52, $49, $56, $62, $51, $45, $42, $62
	db $46, $4a, $3e, $44, $42, $62, $4c, $43, $fa, $f7, $ef, $ee, $3e, $62, $4a, $3e
	db $50, $51, $42, $4f, $63, $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3
	db $28, $53, $42, $4f, $56, $3f, $4c, $41, $56, $62, $ef, $ee, $4c, $52, $44, $45
	db $51, $62, $51, $4c, $62, $4d, $4f, $3e, $56, $fa, $f7, $ef, $ee, $51, $45, $3e
	db $51, $62, $51, $45, $42, $56, $62, $4a, $3e, $56, $ef, $ee, $45, $3e, $53, $42
	db $62, $4c, $4b, $42, $62, $fa, $f7, $ef, $ee, $51, $45, $4c, $52, $50, $3e, $4b
	db $41, $51, $45, $62, $4c, $43, $62, $56, $4c, $52, $4f, $ef, $ee, $53, $46, $4f
	db $51, $52, $42, $5f, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6
	db $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $2b, $3e, $4f, $44
	db $4c, $4b, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6
	db $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $36, $46, $41, $4c
	db $45, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63
	db $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $25, $3e, $4f, $3e, $4a
	db $4c, $50, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6
	db $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $3d, $4c, $4a, $3e
	db $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63, $ef
	db $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $33, $46, $57, $57, $3e, $4f
	db $4c, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63
	db $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $28, $50, $51, $42, $4f
	db $48, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63
	db $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $fa, $f7, $ef, $ee, $30, $46
	db $4f, $52, $41, $4f, $3e, $3e, $50, $63, $ef, $ee, $fa, $f7, $f0, $ea, $2e, $46
	db $4b, $44, $a3, $32, $45, $62, $f6, $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42
	db $3e, $51, $62, $30, $52, $41, $4c, $52, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b
	db $44, $a3, $32, $45, $62, $f6, $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e
	db $51, $62, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $63
	db $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $37, $45, $3e, $51, $62
	db $4a, $4c, $4b, $50, $51, $42, $4f, $ef, $ee, $46, $50, $62, $51, $45, $42, $62
	db $50, $51, $4f, $4c, $4b, $44, $42, $50, $51, $fa, $f7, $ef, $ee, $4c, $4b, $42
	db $62, $3f, $42, $45, $46, $4b, $41, $62, $51, $45, $42, $ef, $ee, $37, $4f, $3e
	db $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51, $42, $63, $fa, $f7, $ef
	db $ee, $2e, $46, $4b, $44, $a3, $37, $45, $3e, $51, $68, $62, $4a, $56, $ef, $ee
	db $f6, $63, $62, $37, $45, $42, $62, $4a, $4c, $50, $51, $fa, $f7, $ef, $ee, $4d
	db $4c, $54, $42, $4f, $43, $52, $49, $62, $4a, $3e, $50, $51, $42, $4f, $ef, $ee
	db $46, $4b, $62, $51, $45, $42, $62, $52, $4b, $46, $53, $42, $4f, $50, $42, $63
	db $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $37, $45, $42, $62, $4b, $42, $55
	db $51, $62, $ef, $ee, $36, $51, $3e, $4f, $4f, $56, $62, $31, $46, $44, $45, $51
	db $62, $54, $4c, $4b, $67, $fa, $f7, $ef, $ee, $40, $4c, $4a, $42, $62, $43, $4c
	db $4f, $62, $3e, $62, $49, $4c, $4b, $44, $ef, $ee, $51, $46, $4a, $42, $5f, $fa
	db $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $25, $52, $51, $62, $2c, $6a, $62, $ef
	db $ee, $40, $4c, $52, $4b, $51, $46, $4b, $44, $62, $4c, $4b, $62, $56, $4c, $52
	db $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $4b, $42, $55, $51, $62, $51, $46, $4a
	db $42, $62, $3e, $50, $ef, $ee, $54, $42, $49, $49, $63, $fa, $f7, $ef, $ee, $2e
	db $46, $4b, $44, $a3, $24, $4b, $41, $62, $43, $4c, $4f, $62, $51, $45, $42, $ef
	db $ee, $37, $46, $4b, $56, $30, $42, $41, $3e, $49, $50, $62, $51, $4c, $4c, $63
	db $62, $fa, $f7, $ef, $ee, $2b, $3e, $62, $45, $3e, $62, $45, $3e, $63, $ef, $ee
	db $f7, $f0, $ea, $9f, $a3, $3c, $42, $50, $5e, $62, $56, $4c, $52, $69, $42, $ef
	db $ee, $3e, $51, $62, $51, $45, $42, $62, $40, $3e, $50, $51, $49, $42, $62, $4c
	db $43, $fa, $f7, $ef, $ee, $2a, $4f, $42, $3e, $51, $37, $4f, $42, $42, $63, $ef
	db $ee, $f7, $f0, $eb, $9f, $a3, $3a, $45, $56, $62, $41, $46, $41, $ef, $ee, $3a
	db $3e, $51, $3e, $3f, $4c, $52, $68, $fa, $f7, $ef, $ee, $3e, $4b, $40, $42, $50
	db $51, $4c, $4f, $62, $54, $3e, $4b, $51, $ef, $ee, $51, $45, $42, $62, $51, $4c
	db $52, $4f, $4b, $3e, $4a, $42, $4b, $51, $fa, $f7, $ef, $ee, $51, $4c, $62, $3f
	db $42, $62, $45, $42, $49, $41, $5f, $5f, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f
	db $a3, $27, $46, $41, $62, $56, $4c, $52, $62, $43, $46, $4b, $41, $62, $4c, $52
	db $51, $ef, $ee, $3e, $43, $51, $42, $4f, $62, $56, $4c, $52, $4f, $62, $fa, $f7
	db $ef, $ee, $53, $46, $40, $51, $4c, $4f, $56, $64, $ef, $ee, $f7, $f0, $eb, $9f
	db $a3, $37, $45, $42, $62, $53, $46, $49, $49, $3e, $44, $42, $62, $4c, $43, $ef
	db $ee, $2a, $4f, $42, $3e, $51, $37, $4f, $42, $42, $62, $46, $50, $fa, $f7, $ef
	db $ee, $43, $46, $49, $49, $42, $41, $62, $54, $46, $51, $45, $62, $47, $4c, $56
	db $63, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $37, $45, $42, $62, $44, $46, $4f, $49
	db $ef, $ee, $41, $4c, $54, $4b, $50, $51, $3e, $46, $4f, $50, $62, $45, $3e, $50
	db $fa, $f7, $ef, $ee, $3f, $42, $42, $4b, $62, $49, $4c, $4c, $48, $46, $4b, $44
	db $62, $43, $4c, $4f, $ef, $ee, $56, $4c, $52, $5f, $fa, $f7, $ef, $ee, $9f, $a3
	db $2c, $62, $45, $3e, $53, $42, $4b, $67, $62, $50, $42, $42, $4b, $ef, $ee, $56
	db $4c, $52, $62, $43, $4c, $4f, $62, $3e, $62, $54, $45, $46, $49, $42, $5f, $fa
	db $f7, $ef, $ee, $3a, $45, $42, $4f, $42, $62, $45, $3e, $53, $42, $62, $56, $4c
	db $52, $ef, $ee, $3f, $42, $42, $4b, $64, $f7, $f0, $ea, $9f, $a3, $28, $53, $42
	db $4b, $62, $46, $43, $62, $51, $45, $42, $4f, $42, $62, $46, $50, $ef, $ee, $4b
	db $4c, $62, $4a, $4c, $4f, $42, $62, $4f, $42, $54, $3e, $4f, $41, $50, $fa, $f7
	db $ef, $ee, $44, $46, $53, $42, $4b, $62, $3f, $56, $62, $30, $42, $41, $3e, $49
	db $ef, $ee, $30, $3e, $4b, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $54, $46
	db $49, $49, $62, $56, $4c, $52, $ef, $ee, $40, $4c, $4b, $51, $46, $4b, $52, $42
	db $62, $51, $4c, $fa, $f7, $ef, $ee, $40, $4c, $49, $49, $42, $40, $51, $62, $51
	db $45, $42, $ef, $ee, $4a, $42, $41, $3e, $49, $50, $63, $64, $ff, $f0, $ea, $9f
	db $a3, $2a, $4f, $42, $3e, $51, $5e, $62, $46, $51, $68, $62, $50, $4c, $ef, $ee
	db $44, $4f, $42, $3e, $51, $5f, $62, $25, $52, $51, $62, $2c, $fa, $f7, $ef, $ee
	db $54, $4c, $52, $49, $41, $62, $4b, $4c, $51, $62, $41, $4c, $62, $46, $51, $5f
	db $ef, $ee, $f7, $f0, $ea, $9f, $a3, $3c, $42, $50, $5f, $62, $2c, $51, $68, $62
	db $51, $45, $42, $ef, $ee, $4f, $46, $44, $45, $51, $62, $54, $3e, $56, $5f, $f7
	db $f0, $eb, $9f, $a3, $2c, $62, $43, $42, $42, $49, $62, $51, $45, $42, $62, $3e
	db $46, $4f, $ef, $ee, $46, $50, $62, $50, $4d, $3e, $4f, $48, $49, $46, $4b, $44
	db $5f, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $54, $4c, $4b, $41, $42, $4f, $62
	db $46, $43, $62, $51, $45, $42, $ef, $ee, $50, $51, $3e, $4f, $50, $62, $3e, $4f
	db $42, $62, $50, $51, $46, $49, $49, $fa, $f7, $ef, $ee, $46, $4b, $62, $51, $45
	db $42, $62, $3e, $46, $4f, $5f, $5f, $5f, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $37
	db $45, $42, $62, $53, $46, $40, $51, $4c, $4f, $46, $4c, $52, $50, $ef, $ee, $4a
	db $3e, $50, $51, $42, $4f, $fa, $f7, $ef, $ee, $42, $53, $42, $4b, $51, $52, $3e
	db $49, $49, $56, $62, $3f, $42, $40, $4c, $4a, $42, $50, $ef, $ee, $51, $45, $42
	db $62, $30, $3e, $50, $51, $42, $4f, $62, $30, $4c, $4b, $50, $51, $42, $4f, $fa
	db $f7, $ef, $ee, $37, $3e, $4a, $42, $4f, $5f, $5f, $5f, $ef, $ee, $fa, $f7, $ef
	db $ee, $9f, $a3, $2c, $62, $54, $4c, $4b, $41, $42, $4f, $62, $46, $43, $62, $2c
	db $ef, $ee, $40, $3e, $4b, $62, $3f, $42, $40, $4c, $4a, $42, $62, $4c, $4b, $42
	db $fa, $f7, $ef, $ee, $51, $4c, $4c, $64, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3
	db $2c, $62, $4f, $42, $3e, $41, $62, $3e, $3f, $4c, $52, $51, $62, $46, $51, $62
	db $ef, $ee, $46, $4b, $62, $51, $45, $42, $62, $3f, $4c, $4c, $48, $62, $2c, $62
	db $fa, $f7, $ef, $ee, $3f, $4c, $4f, $4f, $4c, $54, $42, $41, $62, $43, $4f, $4c
	db $4a, $62, $51, $45, $42, $62, $ef, $ee, $49, $46, $3f, $4f, $3e, $4f, $56, $62
	db $3f, $52, $51, $62, $2c, $62, $fa, $f7, $ef, $ee, $41, $46, $41, $4b, $67, $62
	db $52, $4b, $41, $42, $4f, $50, $51, $3e, $4b, $41, $62, $ef, $ee, $46, $51, $62
	db $51, $45, $3e, $51, $62, $54, $42, $49, $49, $5f, $f7, $f0, $eb, $9f, $a3, $24
	db $62, $54, $42, $49, $49, $62, $54, $4c, $4b, $62, $ef, $ee, $53, $46, $40, $51
	db $4c, $4f, $56, $63, $62, $2c, $6a, $62, $50, $4c, $fa, $f7, $ef, $ee, $45, $3e
	db $4d, $4d, $56, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $45, $42
	db $3e, $4f, $41, $62, $54, $46, $50, $45, $42, $50, $ef, $ee, $40, $4c, $4a, $42
	db $62, $51, $4f, $52, $42, $62, $3e, $43, $51, $42, $4f, $fa, $f7, $ef, $ee, $51
	db $45, $42, $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $5f, $5f, $ef, $ee, $fa
	db $f7, $ef, $ee, $9f, $a3, $3f, $52, $51, $62, $2c, $62, $3e, $4a, $62, $45, $3e
	db $4d, $4d, $56, $62, $ef, $ee, $51, $45, $3e, $51, $62, $56, $4c, $52, $62, $54
	db $4c, $4b, $5e, $62, $fa, $f7, $ef, $ee, $f6, $5f, $ef, $ee, $f7, $f0, $ea, $9f
	db $a3, $28, $4b, $51, $42, $4f, $62, $45, $42, $4f, $42, $62, $51, $4c, $ef, $ee
	db $51, $45, $42, $62, $39, $3e, $52, $49, $51, $5f, $fa, $f7, $ef, $ee, $26, $4c
	db $4b, $44, $4f, $3e, $51, $52, $49, $3e, $51, $46, $4c, $4b, $50, $ef, $ee, $4c
	db $4b, $62, $56, $4c, $52, $4f, $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $f7
	db $f0, $eb, $9f, $a3, $2a, $4c, $62, $4f, $46, $44, $45, $51, $62, $51, $4c, $62
	db $51, $45, $42, $ef, $ee, $25, $3e, $57, $3e, $3e, $4f, $63, $62, $fa, $f7, $ef
	db $ee, $2b, $42, $56, $62, $56, $4c, $52, $62, $54, $42, $4f, $42, $62, $50, $4c
	db $62, $ef, $ee, $40, $4c, $4c, $49, $62, $3f, $4f, $4c, $51, $45, $42, $4f, $63
	db $f7, $f0, $ea, $9f, $a3, $26, $4c, $4b, $44, $4f, $3e, $51, $52, $49, $3e, $51
	db $46, $4c, $4b, $50, $63, $ef, $ee, $27, $4c, $54, $4b, $62, $51, $45, $42, $62
	db $50, $51, $3e, $46, $4f, $50, $62, $51, $4c, $fa, $f7, $ef, $ee, $51, $45, $42
	db $62, $36, $45, $4f, $46, $4b, $42, $62, $4c, $43, $ef, $ee, $36, $51, $3e, $4f
	db $4f, $56, $62, $31, $46, $44, $45, $51, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $37
	db $45, $42, $4f, $42, $62, $46, $50, $62, $3e, $62, $4b, $42, $54, $ef, $ee, $4f
	db $4c, $4c, $4a, $62, $51, $4c, $62, $51, $45, $42, $62, $4f, $46, $44, $45, $51
	db $fa, $f7, $ef, $ee, $41, $52, $42, $62, $51, $4c, $62, $51, $45, $42, $62, $4e
	db $52, $3e, $48, $42, $5f, $ef, $ee, $f7, $f0, $eb, $9f, $a3, $3c, $4c, $52, $62
	db $43, $4c, $4c, $49, $63, $62, $3a, $45, $42, $4f, $42, $ef, $ee, $45, $3e, $53
	db $42, $62, $56, $4c, $52, $62, $3f, $42, $42, $4b, $62, $43, $4c, $4f, $fa, $f7
	db $ef, $ee, $50, $52, $40, $45, $62, $3e, $62, $49, $4c, $4b, $44, $62, $51, $46
	db $4a, $42, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $27, $3e, $4f, $4b, $62
	db $53, $46, $40, $51, $4c, $4f, $56, $63, $ef, $ee, $3a, $45, $3e, $51, $62, $3e
	db $4f, $42, $62, $56, $4c, $52, $62, $50, $4c, $fa, $f7, $ef, $ee, $4d, $52, $43
	db $43, $42, $41, $62, $52, $4d, $62, $3e, $3f, $4c, $52, $51, $63, $ef, $ee, $fa
	db $f7, $ef, $ee, $9f, $a3, $3c, $4c, $52, $62, $40, $45, $42, $3e, $51, $42, $41
	db $63, $ef, $ee, $2c, $51, $62, $54, $3e, $50, $62, $52, $4b, $43, $3e, $46, $4f
	db $63, $63, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $54, $3e, $50, $5f, $5f, $5f
	db $ef, $ee, $5f, $5f, $5f, $54, $4c, $4f, $4f, $46, $42, $41, $5f, $f7, $f0, $eb
	db $9f, $a3, $2c, $62, $54, $3e, $50, $5f, $5f, $5f, $ef, $ee, $5f, $5f, $5f, $54
	db $4c, $4f, $4f, $46, $42, $41, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $5f, $5f, $5f
	db $2b, $42, $56, $62, $56, $4c, $52, $63, $ef, $ee, $3c, $4c, $52, $62, $48, $4b
	db $4c, $54, $62, $4a, $56, $62, $4b, $3e, $4a, $42, $64, $f7, $f0, $eb, $9f, $a3
	db $2b, $52, $43, $43, $5e, $62, $ef, $ee, $2c, $62, $41, $4c, $4b, $67, $62, $4b
	db $42, $42, $41, $62, $56, $4c, $52, $63, $f7, $f0, $eb, $9f, $a3, $37, $45, $42
	db $4b, $62, $50, $3e, $56, $62, $46, $51, $63, $ef, $ee, $ff, $f0, $31, $82, $33
	db $35, $82, $30, $82, $32, $82, $34, $b1, $01, $00, $13, $6f, $bd, $00, $bc, $4a
	db $be, $0a, $bf, $78, $d1, $44, $1f, $82, $46, $82, $45, $82, $46, $82, $45, $82
	db $46, $82, $45, $82, $46, $82, $45, $82, $46, $82, $45, $82, $46, $82, $45, $82
	db $46, $82, $45, $82, $46, $82, $45, $82, $44, $82, $43, $82, $42, $82, $43, $82
	db $44, $82, $45, $82, $46, $82, $47, $82, $b1, $bd, $00, $bc, $4a, $be, $65, $bf
	db $78, $d1, $3e, $1f, $82, $40, $82, $41, $82, $42, $82, $41, $82, $42, $82, $41
	db $82, $42, $82, $41, $82, $42, $82, $41, $82, $42, $82, $41, $82, $42, $82, $41
	db $82, $42, $82, $41, $82, $40, $82, $3f, $82, $3e, $82, $3f, $82, $40, $82, $41
	db $82, $42, $82, $43, $82, $b1, $02, $00, $70, $6f, $ad, $6f, $bd, $00, $bc, $4a
	db $be, $34, $bf, $78, $d1, $31, $1f, $86, $37, $82, $b1, $01, $00, $f0, $6f, $bd
	db $00, $bc, $4a, $be, $45, $bf, $78, $d5, $4e, $1f, $86, $d1, $4e, $09, $82, $d1
	db $4e, $0c, $82, $d1, $4e, $04, $82, $b1, $01, $00, $03, $70, $bd, $00, $bc, $4a
	db $be, $10, $bf, $55, $c2, $0e, $c1, $40, $d6, $30, $1b, $81, $c1, $42, $81, $45
	db $81, $4a, $81, $64, $81, $78, $81, $7f, $81, $c1, $40, $d6, $30, $13, $81, $c1
	db $42, $81, $45, $81, $4a, $81, $64, $81, $78, $81, $7f, $81, $b1, $01, $00, $20
	db $70, $bd, $00, $bc, $4a, $be, $64, $bf, $5e, $d1, $4e, $16, $86, $5f, $82, $b1
	db $01, $00, $55, $70, $bd, $00, $bc, $4a, $be, $10, $c5, $50, $bf, $4b, $d3, $54
	db $13, $84, $58, $84, $57, $84, $56, $84, $5f, $84, $5e, $84, $5d, $84, $59, $84
	db $b1, $01, $00, $68, $70, $bd, $00, $bc, $4a, $be, $3b, $bf, $4b, $d1, $30, $18
	db $82, $3a, $82, $39, $82, $35, $82, $b1, $01, $00, $89, $70, $bd, $00, $bc, $4a
	db $be, $65, $bf, $5e, $d2, $3c, $18, $83, $3d, $83, $3e, $83, $3f, $83, $d2, $3d
	db $16, $83, $3e, $83, $3f, $83, $40, $83, $d2, $3e, $13, $83, $3f, $83, $40, $83
	db $41, $83, $d2, $3f, $11, $83, $40, $83, $41, $83, $42, $83, $d2, $40, $0e, $83
	db $41, $83, $42, $83, $43, $83, $d2, $41, $0c, $83, $42, $83, $43, $83, $44, $83
	db $d2, $42, $09, $83, $43, $83, $44, $83, $45, $83, $d2, $43, $07, $83, $44, $83
	db $45, $83, $46, $83, $b1, $01, $00, $a0, $70, $bd, $00, $bc, $4a, $be, $65, $bf
	db $71, $d5, $37, $0b, $86, $d5, $37, $0c, $86, $d5, $37, $0d, $86, $d5, $37, $0e
	db $86, $d5, $37, $0f, $86, $d5, $37, $10, $86, $d5, $37, $11, $86, $d5, $37, $12
	db $86, $d5, $37, $13, $86, $d5, $37, $14, $86, $d5, $37, $15, $86, $d5, $37, $16
	db $86, $d5, $37, $14, $86, $d5, $37, $12, $86, $d5, $37, $10, $86, $d5, $37, $0e
	db $86, $d5, $37, $0c, $86, $d5, $37, $0b, $86, $b1, $01, $00, $fd, $70, $bd, $00
	db $bc, $4a, $be, $6c, $bf, $67, $d3, $35, $18, $86, $04, $84, $b1, $01, $00, $52
	db $71, $bd, $00, $bc, $4a, $be, $10, $bf, $71, $d0, $34, $1d, $83, $d0, $35, $1b
	db $83, $b1, $01, $00, $65, $71, $bd, $00, $bc, $4a, $be, $40, $bf, $78, $c1, $40
	db $db, $34, $18, $81, $c1, $44, $81, $c5, $2b, $c1, $44, $81, $c5, $27, $c1, $3c
	db $81, $c5, $20, $c1, $2c, $81, $27, $81, $c5, $18, $c1, $1b, $81, $c5, $0b, $c1
	db $16, $81, $c5, $07, $c1, $15, $81, $c5, $06, $c1, $14, $81, $13, $81, $c5, $04
	db $81, $07, $c1, $40, $db, $13, $81, $c1, $44, $81, $c5, $15, $c1, $44, $81, $c5
	db $21, $c1, $3c, $81, $c5, $29, $c1, $2c, $81, $c5, $31, $c1, $27, $81, $c5, $33
	db $c1, $1b, $81, $c5, $36, $c1, $16, $81, $c5, $35, $c1, $15, $81, $14, $81, $c5
	db $2b, $c1, $13, $81, $c5, $25, $81, $c1, $40, $db, $0c, $81, $c5, $19, $c1, $44
	db $81, $c5, $16, $c1, $44, $81, $3c, $81, $2c, $81, $c5, $1a, $c1, $27, $81, $c5
	db $22, $c1, $1b, $81, $c5, $2e, $c1, $16, $81, $15, $81, $c5, $4d, $c1, $14, $81
	db $c5, $51, $c1, $13, $82, $40, $db, $07, $81, $c5, $4d, $c1, $44, $81, $c5, $44
	db $c1, $44, $81, $3c, $81, $c5, $37, $c1, $2c, $81, $c5, $1c, $c1, $27, $81, $1b
	db $81, $c5, $12, $c1, $16, $81, $c5, $0c, $c1, $15, $81, $14, $81, $c5, $0f, $c1
	db $13, $82, $c5, $25, $81, $34, $81, $43, $81, $49, $81, $4b, $81, $49, $81, $44
	db $81, $3d, $81, $35, $81, $2c, $81, $25, $81, $20, $81, $1f, $83, $22, $81, $2e
	db $81, $3c, $81, $4b, $81, $53, $81, $58, $81, $5a, $82, $59, $81, $53, $81, $4c
	db $81, $44, $81, $3d, $82, $35, $81, $2f, $81, $2a, $81, $26, $81, $24, $81, $21
	db $81, $20, $81, $1f, $b1, $01, $00, $7a, $71, $bd, $00, $bc, $4a, $be, $6a, $bf
	db $78, $d3, $32, $1f, $86, $09, $84, $b1, $01, $00, $8d, $72, $bd, $00, $bc, $4a
	db $be, $0d, $c3, $7f, $c4, $00, $c5, $32, $c6, $00, $bf, $67, $d4, $4c, $1b, $8c
	db $e7, $98, $c5, $00, $be, $64, $bf, $78, $c2, $0a, $e7, $62, $1f, $81, $c1, $42
	db $81, $41, $81, $3e, $81, $3c, $81, $3a, $81, $35, $81, $33, $82, $30, $82, $2e
	db $82, $2f, $82, $32, $82, $36, $82, $38, $82, $3d, $82, $40, $81, $d4, $13, $85
	db $b1, $bd, $00, $be, $5d, $c3, $7f, $c4, $00, $c5, $32, $c6, $00, $bf, $67, $d4
	db $4a, $1b, $8c, $e7, $98, $c5, $00, $be, $68, $bf, $55, $db, $3b, $10, $8c, $be
	db $65, $d3, $3b, $12, $84, $d7, $3b, $14, $88, $d7, $3b, $16, $88, $df, $3b, $18
	db $90, $eb, $3b, $1b, $9c, $d7, $3b, $16, $88, $be, $66, $e7, $3b, $12, $98, $b1
	db $02, $00, $a0, $72, $e5, $72, $bd, $00, $bc, $4a, $be, $0a, $bf, $5e, $c5, $64
	db $d3, $48, $18, $81, $4a, $81, $4c, $81, $4e, $81, $50, $81, $52, $81, $4a, $81
	db $4c, $81, $4e, $81, $50, $81, $52, $81, $54, $81, $4c, $81, $4e, $81, $50, $81
	db $52, $81, $54, $81, $56, $81, $4e, $81, $50, $81, $52, $81, $54, $81, $56, $81
	db $58, $84, $b1, $01, $00, $2a, $73, $bd, $00, $bc, $4a, $be, $37, $bf, $67, $ed
	db $30, $18, $9e, $40, $b1, $01, $00, $6b, $73, $bd, $00, $bc, $4a, $be, $0a, $c5
	db $14, $bf, $71, $d1, $39, $1d, $82, $36, $82, $38, $82, $35, $82, $37, $82, $34
	db $82, $36, $82, $33, $82, $35, $82, $32, $82, $34, $82, $31, $82, $33, $82, $30
	db $82, $32, $82, $2f, $82, $31, $82, $2e, $82, $30, $82, $2d, $82, $2f, $82, $2c
	db $82, $2e, $82, $2b, $82, $b1, $bd, $00, $bc, $4a, $be, $6d, $bf, $78, $d2, $47
	db $1f, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83
	db $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83
	db $46, $83, $45, $83, $b1, $02, $00, $7d, $73, $ba, $73, $bd, $00, $bc, $4a, $be
	db $3c, $c5, $14, $bf, $71, $d1, $3a, $1d, $82, $37, $82, $39, $82, $36, $82, $38
	db $82, $35, $82, $3a, $16, $82, $37, $82, $39, $82, $36, $82, $38, $82, $35, $82
	db $b1, $01, $00, $ef, $73, $bd, $00, $bc, $4a, $be, $0a, $c5, $14, $bf, $71, $d1
	db $3a, $1d, $82, $37, $82, $39, $82, $36, $82, $38, $82, $35, $82, $3a, $16, $82
	db $37, $82, $39, $82, $36, $82, $38, $82, $35, $82, $b1, $bd, $00, $bc, $4a, $be
	db $6d, $bf, $78, $d2, $47, $1f, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45
	db $83, $47, $83, $46, $83, $45, $83, $b1, $02, $00, $19, $74, $3f, $74, $bd, $00
	db $bc, $4a, $be, $63, $c5, $14, $bf, $78, $d1, $41, $1f, $82, $3e, $82, $40, $82
	db $3d, $82, $3f, $82, $3c, $82, $3e, $82, $3b, $82, $3d, $82, $3a, $82, $3c, $82
	db $39, $82, $3b, $82, $38, $82, $3a, $82, $37, $82, $39, $82, $36, $82, $38, $82
	db $35, $82, $37, $82, $34, $82, $36, $82, $33, $82, $35, $82, $32, $82, $34, $82
	db $31, $82, $33, $82, $30, $82, $32, $82, $2f, $82, $31, $82, $2e, $82, $30, $82
	db $2d, $82, $2f, $82, $2c, $82, $2e, $82, $2b, $82, $b1, $bd, $00, $bc, $4a, $be
	db $6d, $bf, $78, $d2, $47, $1f, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45
	db $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46
	db $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47
	db $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $b1, $02, $00, $62, $74
	db $bf, $74, $bd, $00, $bc, $4a, $be, $65, $bf, $71, $c5, $00, $d5, $39, $1f, $8c
	db $d1, $12, $82, $b1, $01, $00, $06, $75, $bd, $00, $bc, $4a, $be, $0a, $c5, $14
	db $bf, $4b, $d1, $3a, $13, $82, $37, $82, $3b, $82, $38, $82, $3c, $82, $39, $82
	db $3d, $82, $3a, $82, $3e, $82, $3b, $82, $3f, $82, $3c, $82, $40, $82, $3d, $82
	db $41, $82, $3e, $82, $42, $82, $3f, $82, $43, $82, $40, $82, $44, $82, $41, $82
	db $45, $82, $42, $82, $b1, $bd, $00, $bc, $4a, $be, $6d, $bf, $78, $d2, $47, $1f
	db $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45
	db $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46
	db $83, $45, $83, $b1, $02, $00, $1c, $75, $59, $75, $bd, $00, $bc, $4a, $be, $3c
	db $c5, $14, $bf, $5e, $d1, $4a, $18, $84, $49, $84, $48, $84, $d1, $4a, $11, $84
	db $49, $84, $48, $84, $b1, $01, $00, $8e, $75, $bd, $00, $bc, $4a, $be, $32, $bf
	db $71, $d3, $35, $1d, $85, $d3, $85, $d3, $39, $85, $b1, $01, $00, $ad, $75, $bd
	db $00, $bc, $4a, $be, $63, $bf, $71, $d1, $24, $1d, $82, $26, $82, $28, $82, $29
	db $82, $2b, $82, $2d, $82, $2f, $82, $30, $82, $32, $82, $34, $82, $35, $82, $37
	db $82, $39, $82, $3b, $82, $3c, $82, $3b, $82, $3a, $82, $39, $82, $3a, $82, $3b
	db $82, $3a, $82, $39, $82, $38, $82, $37, $82, $38, $82, $39, $82, $38, $82, $37
	db $82, $36, $82, $35, $82, $36, $82, $37, $82, $36, $82, $35, $82, $34, $82, $33
	db $82, $34, $82, $35, $82, $b1, $01, $00, $c3, $75, $bd, $00, $bc, $4a, $be, $3f
	db $bf, $71, $d5, $37, $1d, $86, $be, $36, $d3, $35, $1d, $86, $b1, $01, $00, $1e
	db $76, $bd, $00, $bc, $4a, $be, $63, $c5, $64, $bf, $71, $d1, $48, $1d, $82, $42
	db $82, $3d, $82, $47, $82, $41, $82, $3c, $82, $46, $82, $40, $82, $3b, $82, $45
	db $82, $3f, $82, $3a, $82, $44, $82, $3e, $82, $39, $82, $43, $82, $3d, $82, $38
	db $82, $42, $82, $3c, $82, $37, $82, $41, $82, $3b, $82, $36, $82, $40, $82, $3a
	db $82, $35, $82, $3f, $82, $39, $82, $34, $82, $3e, $82, $38, $82, $33, $82, $3d
	db $82, $37, $82, $32, $82, $3c, $82, $31, $82, $36, $82, $b1, $01, $00, $35, $76
	db $bd, $00, $bc, $4a, $be, $63, $bf, $71, $d2, $30, $1d, $83, $31, $83, $32, $83
	db $33, $83, $34, $83, $35, $83, $36, $83, $37, $83, $38, $83, $39, $83, $d2, $30
	db $11, $83, $31, $83, $32, $83, $33, $83, $34, $83, $35, $83, $36, $83, $37, $83
	db $38, $83, $39, $83, $b1, $01, $00, $94, $76, $bd, $00, $bc, $4a, $be, $33, $bf
	db $78, $d3, $30, $1f, $88, $b1, $01, $00, $cd, $76, $bd, $00, $bc, $4a, $be, $55
	db $bf, $78, $d0, $5b, $1f, $83, $63, $83, $5a, $83, $56, $83, $65, $83, $55, $83
	db $4f, $aa, $b1, $bd, $00, $be, $10, $bf, $2f, $92, $d2, $5b, $0c, $83, $63, $83
	db $5a, $83, $56, $83, $65, $83, $55, $83, $4f, $a4, $b1, $bd, $00, $be, $25, $bf
	db $55, $86, $d2, $5b, $16, $83, $63, $83, $5a, $83, $56, $83, $65, $83, $55, $83
	db $4f, $a8, $b1, $03, $00, $de, $76, $f7, $76, $0f, $77, $bd, $00, $bc, $4a, $be
	db $10, $bf, $5e, $d0, $30, $18, $83, $3e, $83, $46, $82, $b1, $01, $00, $2f, $77
	db $bd, $00, $bc, $4a, $be, $63, $c5, $50, $bf, $71, $c1, $40, $df, $4b, $18, $8a
	db $c1, $37, $82, $31, $82, $28, $82, $24, $82, $22, $82, $21, $82, $d6, $4b, $0c
	db $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6
	db $48, $18, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81
	db $40, $d6, $48, $0c, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81
	db $21, $81, $40, $d6, $41, $18, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81
	db $22, $81, $21, $81, $40, $d6, $41, $0c, $81, $c1, $37, $81, $31, $81, $28, $81
	db $24, $81, $22, $81, $21, $81, $40, $d6, $3e, $18, $81, $c1, $37, $81, $31, $81
	db $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6, $3e, $0c, $81, $c1, $37, $81
	db $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6, $3d, $18, $81, $c1
	db $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6, $3d, $0c
	db $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6
	db $3c, $18, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81
	db $40, $d6, $3c, $0c, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81
	db $21, $81, $40, $b4, $b1, $bd, $01, $bc, $4a, $be, $0a, $c5, $50, $bf, $71, $c1
	db $40, $86, $b3, $50, $77, $b1, $02, $00, $44, $77, $29, $78, $bd, $00, $bc, $4a
	db $be, $6a, $bf, $71, $d0, $40, $1d, $81, $40, $19, $81, $40, $17, $81, $3e, $1d
	db $81, $3e, $19, $81, $3e, $17, $81, $3c, $1d, $81, $3c, $19, $81, $3c, $17, $81
	db $3b, $1d, $81, $3b, $19, $81, $3b, $17, $81, $39, $1d, $81, $39, $18, $81, $39
	db $17, $81, $37, $1d, $81, $37, $19, $81, $37, $17, $81, $35, $1d, $81, $35, $19
	db $81, $35, $17, $81, $34, $1d, $81, $34, $19, $81, $34, $17, $81, $32, $1d, $81
	db $32, $19, $81, $32, $17, $81, $30, $1d, $81, $30, $19, $81, $30, $17, $81, $32
	db $1d, $81, $32, $19, $81, $32, $17, $81, $34, $1d, $81, $34, $19, $81, $34, $17
	db $81, $35, $1d, $81, $35, $19, $81, $35, $17, $81, $37, $1d, $81, $37, $19, $81
	db $37, $17, $81, $39, $1d, $81, $39, $19, $81, $39, $17, $81, $3b, $1d, $81, $3b
	db $19, $81, $3b, $17, $81, $3c, $1d, $81, $3c, $19, $81, $3c, $17, $81, $3e, $1d
	db $81, $3e, $19, $81, $3e, $17, $81, $40, $1d, $81, $40, $19, $81, $40, $17, $81
	db $b1, $01, $00, $40, $78, $bd, $00, $bc, $4a, $be, $63, $c5, $64, $bf, $71, $d1
	db $60, $1d, $82, $54, $82, $48, $82, $3c, $82, $5f, $82, $53, $82, $47, $82, $3b
	db $82, $5e, $82, $52, $82, $46, $82, $3a, $82, $5d, $82, $51, $82, $45, $82, $39
	db $82, $5c, $82, $50, $82, $44, $82, $38, $82, $5b, $18, $82, $4f, $82, $43, $82
	db $37, $82, $5b, $11, $82, $4f, $82, $43, $82, $37, $82, $5b, $0c, $82, $4f, $82
	db $43, $82, $37, $82, $b1, $01, $00, $f9, $78, $bd, $00, $bc, $4a, $be, $33, $bf
	db $78, $d6, $2b, $13, $88, $d6, $2d, $16, $88, $d6, $2f, $18, $88, $d6, $30, $1b
	db $88, $d6, $32, $1f, $88, $b1, $01, $00, $4d, $79, $bd, $00, $bc, $4a, $be, $36
	db $bf, $78, $d6, $30, $1f, $88, $d6, $2f, $1b, $88, $d6, $2e, $18, $88, $d6, $2d
	db $16, $88, $d6, $2b, $13, $88, $b1, $01, $00, $6e, $79, $bd, $00, $bc, $4a, $be
	db $6a, $bf, $78, $d5, $3a, $1f, $8c, $d1, $12, $82, $d1, $0c, $82, $b1, $01, $00
	db $8f, $79, $bd, $00, $bc, $4a, $be, $3a, $bf, $4b, $e3, $60, $13, $94, $b1, $01
	db $00, $a6, $79, $bd, $00, $bc, $4a, $be, $65, $bf, $5e, $d0, $4a, $18, $82, $d0
	db $47, $0c, $82, $b1, $01, $00, $b7, $79, $bd, $00, $bc, $4a, $be, $6a, $bf, $78
	db $d6, $38, $1f, $88, $d4, $38, $0e, $86, $d3, $37, $07, $85, $b1, $01, $00, $cc
	db $79, $bd, $00, $bc, $4a, $be, $65, $c5, $00, $bf, $5e, $d0, $4f, $1d, $81, $4e
	db $81, $4d, $81, $4c, $81, $4b, $81, $4a, $81, $49, $81, $48, $81, $47, $81, $46
	db $81, $45, $81, $44, $81, $43, $81, $42, $07, $81, $41, $81, $40, $81, $3f, $05
	db $81, $3e, $81, $3d, $03, $81, $3c, $81, $3b, $01, $81, $3a, $81, $39, $81, $38
	db $00, $81, $37, $81, $b1, $01, $00, $e5, $79, $bd, $00, $bc, $4a, $be, $10, $bf
	db $4b, $c2, $0e, $c1, $40, $d6, $48, $13, $81, $c1, $42, $81, $45, $81, $4a, $81
	db $64, $81, $78, $81, $7f, $81, $b1, $01, $00, $2d, $7a, $bd, $00, $bc, $4a, $be
	db $6a, $c5, $00, $bf, $5e, $d0, $43, $18, $81, $0c, $81, $46, $18, $81, $0c, $81
	db $45, $18, $81, $0c, $81, $b1, $01, $00, $4f, $7a, $bd, $00, $bc, $4a, $be, $10
	db $bf, $71, $d0, $48, $18, $84, $55, $84, $3e, $84, $63, $84, $4c, $84, $59, $84
	db $42, $84, $5b, $84, $68, $84, $51, $84, $52, $84, $47, $84, $60, $84, $b1, $01
	db $00, $6e, $7a, $bd, $00, $bc, $4a, $be, $5d, $bf, $67, $d0, $54, $18, $81, $0c
	db $82, $18, $81, $0c, $82, $b1, $01, $00, $97, $7a, $bd, $00, $bc, $4a, $be, $65
	db $bf, $78, $d7, $38, $1f, $8a, $d7, $38, $04, $8a, $b1, $01, $00, $ae, $7a, $bd
	db $00, $bc, $4a, $be, $65, $bf, $71, $d7, $35, $1f, $88, $d7, $35, $18, $88, $b1
	db $01, $00, $c3, $7a, $bd, $00, $bc, $4a, $be, $3a, $bf, $4b, $e3, $54, $13, $94
	db $b1, $01, $00, $d8, $7a, $bd, $00, $bc, $4a, $be, $6a, $bf, $78, $be, $0b, $e1
	db $60, $1f, $92, $b1, $01, $00, $e9, $7a, $bd, $00, $bc, $4a, $be, $6a, $c5, $32
	db $bf, $71, $db, $49, $1d, $8c, $b1, $01, $00, $fc, $7a, $bd, $00, $bc, $4a, $be
	db $10, $bf, $5e, $c1, $40, $c2, $0a, $e7, $57, $15, $87, $c1, $3f, $88, $3e, $89
	db $e7, $57, $0e, $c1, $3d, $8a, $3c, $88, $3b, $82, $3a, $83, $39, $81, $e9, $57
	db $09, $c1, $38, $8b, $37, $87, $36, $86, $35, $86, $e1, $57, $07, $c1, $34, $88
	db $33, $83, $32, $84, $31, $83, $da, $57, $04, $c1, $30, $84, $2f, $87, $b1, $01
	db $00, $0f, $7b, $bd, $03, $bc, $4a, $be, $3c, $c5, $14, $bf, $71, $d1, $4a, $18
	db $84, $4b, $84, $4c, $84, $d1, $4d, $11, $84, $4e, $84, $4f, $84, $b1, $01, $00
	db $57, $7b, $bd, $00, $bc, $4a, $be, $1f, $bf, $5e, $c1, $5f, $d5, $64, $19, $81
	db $c1, $40, $81, $01, $84, $d5, $64, $0e, $81, $c1, $40, $81, $01, $84, $b1, $01
	db $00, $76, $7b, $bd, $00, $bc, $4a, $be, $65, $bf, $5e, $d0, $56, $18, $83, $51
	db $81, $b1, $01, $00, $97, $7b, $bd, $00, $bc, $4a, $be, $65, $bf, $67, $d0, $4a
	db $1b, $83, $b1, $01, $00, $aa, $7b, $bd, $00, $bc, $4a, $be, $6a, $bf, $5e, $d0
	db $43, $18, $83, $0c, $83, $b1, $01, $00, $bb, $7b, $bd, $00, $bc, $4a, $be, $63
	db $bf, $78, $d0, $58, $1f, $86, $d0, $54, $1f, $86, $d0, $58, $1f, $86, $5b, $82
	db $b1, $01, $00, $ce, $7b, $bd, $00, $bc, $4a, $be, $35, $bf, $78, $d7, $48, $18
	db $88, $d7, $88, $d7, $88, $d7, $88, $b1, $01, $00, $e9, $7b, $bd, $00, $bc, $4a
	db $be, $3c, $bf, $4b, $d7, $40, $13, $88, $b1, $01, $00, $00, $7c, $bd, $00, $bc
	db $4a, $be, $10, $bf, $4b, $d1, $54, $13, $83, $43, $83, $40, $83, $30, $83, $32
	db $83, $45, $83, $b1, $01, $00, $11, $7c, $bd, $00, $bc, $4a, $be, $3b, $bf, $78
	db $d5, $41, $18, $83, $65, $86, $b1, $01, $00, $2c, $7c, $bd, $00, $bc, $4a, $be
	db $10, $bf, $38, $c1, $40, $c2, $0a, $ce, $57, $0e, $87, $c1, $3f, $88, $3e, $8a
	db $3d, $89, $3c, $88, $3b, $82, $3a, $83, $39, $83, $38, $8b, $37, $87, $36, $86
	db $35, $86, $34, $88, $33, $83, $32, $82, $31, $83, $30, $84, $2f, $87, $2e, $87
	db $2d, $85, $2c, $86, $2b, $88, $2a, $86, $29, $86, $28, $84, $27, $85, $26, $85
	db $25, $85, $24, $81, $23, $82, $22, $82, $21, $86, $20, $84, $1f, $81, $1e, $81
	db $1d, $82, $1c, $83, $1b, $82, $1a, $84, $cf, $b1, $01, $00, $3f, $7c, $bd, $00
	db $bc, $4a, $be, $10, $bf, $5e, $c1, $40, $c2, $0a, $ce, $57, $15, $87, $c1, $3f
	db $88, $3e, $8a, $3d, $89, $3c, $88, $3b, $82, $3a, $83, $39, $83, $38, $8b, $37
	db $87, $36, $86, $35, $86, $34, $88, $33, $83, $32, $82, $31, $83, $30, $84, $2f
	db $87, $2e, $87, $2d, $85, $2c, $86, $2b, $88, $2a, $86, $29, $86, $28, $84, $27
	db $85, $26, $85, $25, $85, $24, $81, $23, $82, $22, $82, $21, $86, $20, $84, $1f
	db $81, $1e, $81, $1d, $82, $1c, $83, $1b, $82, $1a, $84, $cf, $b1, $01, $00, $a2
	db $7c, $bd, $00, $bc, $4a, $be, $6a, $bf, $4b, $d1, $3c, $13, $83, $b1, $01, $00
	db $05, $7d, $bd, $00, $bc, $4a, $be, $0a, $bf, $00, $d0, $3c, $00, $81, $b1, $bd
	db $00, $be, $14, $bf, $00, $d0, $3c, $00, $81, $b1, $bd, $00, $be, $1e, $bf, $00
	db $d0, $3c, $00, $81, $b1, $bd, $00, $be, $65, $bf, $00, $d0, $3c, $00, $81, $b1
	db $04, $00, $16, $7d, $23, $7d, $2e, $7d, $39, $7d, $bd, $00, $bc, $4a, $be, $65
	db $bf, $00, $d0, $3c, $00, $81, $b1, $01, $00, $4e, $7d, $bd, $00, $bc, $4a, $be
	db $3a, $bf, $4b, $e3, $54, $13, $94, $b1, $01, $00, $5f, $7d, $bd, $00, $bc, $4a
	db $be, $10, $bf, $5e, $d1, $54, $11, $82, $d1, $56, $11, $82, $d1, $58, $11, $82
	db $b1, $01, $00, $70, $7d, $bd, $00, $bc, $4a, $be, $10, $bf, $5e, $d1, $58, $11
	db $82, $d1, $56, $11, $82, $d1, $54, $11, $82, $b1, $01, $00, $89, $7d, $bd, $00
	db $bc, $4a, $be, $6a, $bf, $5e, $d1, $3c, $18, $84, $3d, $84, $3e, $82, $b1, $01
	db $00, $a2, $7d, $bd, $00, $bc, $4a, $be, $10, $bf, $4b, $c2, $14, $c1, $41, $e1
	db $35, $13, $85, $c1, $42, $81, $45, $81, $4a, $82, $53, $81, $56, $81, $5e, $81
	db $66, $81, $69, $81, $6d, $81, $73, $81, $7a, $81, $7e, $81, $b1, $01, $00, $b7
	db $7d, $bd, $00, $bc, $4a, $be, $10, $bf, $4b, $c2, $14, $c1, $3f, $e1, $48, $13
	db $85, $c1, $3e, $81, $3b, $81, $36, $82, $2d, $81, $2a, $81, $22, $81, $1a, $81
	db $17, $81, $13, $81, $0d, $81, $06, $81, $02, $81, $b1, $01, $00, $e5, $7d, $bd
	db $00, $bc, $4a, $be, $10, $bf, $71, $d1, $48, $1d, $83, $4c, $83, $4f, $83, $54
	db $83, $48, $18, $83, $4c, $83, $4f, $83, $54, $83, $48, $0e, $83, $4c, $83, $4f
	db $83, $54, $83, $b1, $01, $00, $13, $7e, $bd, $02, $bc, $4a, $be, $0d, $c3, $7f
	db $c4, $00, $c5, $32, $c6, $00, $bf, $78, $d4, $35, $1f, $8c, $e7, $98, $b1, $bd
	db $02, $be, $5d, $c3, $7f, $c4, $00, $c5, $32, $c6, $00, $bf, $78, $d4, $33, $1f
	db $8c, $e7, $98, $b1, $02, $00, $3c, $7e, $53, $7e, $bd, $00, $be, $4a, $bf, $5e
	db $d0, $5f, $18, $81, $0c, $82, $d0, $60, $18, $81, $0c, $82, $d0, $5f, $18, $81
	db $0c, $82, $d0, $60, $18, $81, $0c, $82, $d0, $5f, $18, $81, $0c, $82, $d0, $60
	db $18, $81, $0c, $82, $d7, $5f, $18, $81, $0c, $82, $d7, $60, $18, $81, $0c, $82
	db $d7, $5f, $11, $81, $07, $82, $d7, $60, $11, $81, $07, $82, $d0, $5f, $11, $81
	db $07, $82, $d0, $60, $11, $81, $07, $82, $d7, $5f, $11, $81, $07, $82, $d7, $60
	db $11, $81, $07, $82, $b1, $01, $00, $6e, $7e, $bd, $00, $bc, $4a, $be, $11, $bf
	db $5e, $e7, $54, $18, $98, $b1, $01, $00, $cd, $7e, $bd, $00, $bc, $4a, $be, $11
	db $bf, $5e, $e7, $60, $18, $98, $b1, $01, $00, $de, $7e, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
