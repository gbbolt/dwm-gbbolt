INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $014", ROMX[$4000], BANK[$14]

BankNumber_14::
	db $14

FarTable_14::
	dw LoadMonTemplate
	dw LoadMonTemplate2
	dw CreateMonster
	dw CreateMonsterUnlisted
	dw CheckFieldItemUse
	dw UseFieldItem
	dw RemapMonId

LoadMonTemplate::
	ld de, wNewMonNameText
	call LoadMonTemplateTo
	ret


LoadMonTemplate2::
	ld de, wNewMonNameText
	call LoadMonTemplateTo
	ret


CreateMonsterUnlisted::
	ld hl, wMonsters
	ld a, [wNewMonSlot]
	call MonsterField
	ld bc, $0095
	xor a
	call FillMemory
	ld hl, wMonParent1
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld hl, wMonSkills
	ld a, [wNewMonSlot]
	call MonsterField
	ld bc, $0008
	ld a, $ff
	call FillMemory
	ld hl, wMonSkillList
	ld a, [wNewMonSlot]
	call MonsterField
	ld bc, $0019
	ld a, $ff
	call FillMemory
	ld hl, wMonParent1Name
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonParent1Master
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonParent2Name
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonParent2Master
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonsters
	ld a, [wNewMonSlot]
	call MonsterField
	ld [hl], $01
	ld hl, wMonMaster
	ld de, wPlayerName
	ld b, $08
	call CopyToNewMon
	ld hl, $cad5
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, [$ca4a]
	ld [hl], a
	ld de, wNewMonNameText
	call LoadMonTemplateTo
	jp CreateMonsterFromTemplate


CreateMonster::
	ld hl, wMonsters
	ld a, [wNewMonSlot]
	call MonsterField
	ld bc, $0095
	xor a
	call FillMemory
	ld hl, wMonParent1
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld hl, wMonSkills
	ld a, [wNewMonSlot]
	call MonsterField
	ld bc, $0008
	ld a, $ff
	call FillMemory
	ld hl, wMonSkillList
	ld a, [wNewMonSlot]
	call MonsterField
	ld bc, $0019
	ld a, $ff
	call FillMemory
	ld hl, wMonParent1Name
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonParent1Master
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonParent2Name
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonParent2Master
	ld de, $477a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonsters
	ld a, [wNewMonSlot]
	call MonsterField
	ld [hl], $01
	ld hl, wMonMaster
	ld de, wPlayerName
	ld b, $08
	call CopyToNewMon
	ld hl, $cad5
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, [$ca4a]
	ld [hl], a
	ld de, wNewMonNameText
	call LoadMonTemplateTo
	ld a, [wNewMonSlot]
	cp $15
	jr z, jr_014_4158

	ld a, [wNewMonNameText]
	ld hl, wLibraryFlags
	call SetFlag

CreateMonsterFromTemplate:
jr_014_4158:
	ld hl, wMonRecSpecies
	ld de, wNewMonNameText
	call SetNewMonByte
	ld hl, wMonSkills
	ld de, wTemplateSkills
	call CopyToNewMon4
	ld hl, wMonLevel
	ld de, wTemplateLevel
	call SetNewMonByte
	ld hl, wMonMaxHP
	ld de, wTemplateHP
	call CopyToNewMonWord
	ld hl, wMonMaxHP
	call RandomizeNewMonWord
	ld hl, wMonMaxHP
	ld a, [wNewMonSlot]
	call MonsterField
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	ld hl, wMonHP
	ld a, [wNewMonSlot]
	call MonsterField
	pop bc
	ld [hl], c
	inc hl
	ld [hl], b
	ld hl, wMonMaxMP
	ld de, wTemplateMP
	call CopyToNewMonWord
	ld hl, wMonMaxMP
	call RandomizeNewMonWord
	ld hl, wMonMaxMP
	ld a, [wNewMonSlot]
	call MonsterField
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	ld hl, wMonMP
	ld a, [wNewMonSlot]
	call MonsterField
	pop bc
	ld [hl], c
	inc hl
	ld [hl], b
	ld hl, wMonAttack
	ld de, wTemplateAttack
	call CopyToNewMonWord
	ld hl, wMonAttack
	call RandomizeNewMonWord
	ld hl, wMonDefense
	ld de, wTemplateDefense
	call CopyToNewMonWord
	ld hl, wMonDefense
	call RandomizeNewMonWord
	ld hl, wMonAgility
	ld de, wTemplateAgility
	call CopyToNewMonWord
	ld hl, wMonIntelligence
	ld de, wTemplateIntelligence
	call CopyToNewMonWord
	ld hl, wMonIntelligence
	call RandomizeNewMonWord
	ld hl, wMonStat64
	ld de, wTemplatePersonality1
	call SetNewMonByte
	ld hl, wMonStat64
	call RandomizeNewMonByte
	ld hl, wMonStat65
	ld de, wTemplatePersonality2
	call SetNewMonByte
	ld hl, wMonStat65
	call RandomizeNewMonByte
	ld hl, wMonStat66
	ld de, wTemplatePersonality3
	call SetNewMonByte
	ld hl, wMonStat66
	call RandomizeNewMonByte
	ld hl, wMonStat67
	ld de, wTemplateStat67
	call SetNewMonByte
	ld hl, wMonStat67
	call RandomizeNewMonByte
	ld hl, wMonLevel
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, [hl]
	ld bc, $0005
	call Multiply24
	push hl
	ld a, [wScriptBossIndex]
	ld bc, $000a
	call Multiply24
	pop bc
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	jr nc, jr_014_425d

	ld bc, $0000

jr_014_425d:
	ld a, b
	or a
	jr z, jr_014_4264

	ld bc, $00ff

jr_014_4264:
	push bc
	ld hl, wMonWildness
	ld a, [wNewMonSlot]
	call MonsterField
	pop bc
	ld [hl], c
	ld a, [wNewMonNameText]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld hl, wMonFamily
	ld de, wMonStats
	call SetNewMonByte
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	sub $02
	ld b, a
	ld a, [$da34]
	add b
	push af
	ld hl, wMonMaxLevel
	ld a, [wNewMonSlot]
	call MonsterField
	pop af
	ld [hl], a
	ld hl, wMonResist
	ld de, wMonResistances
	ld b, $1b
	call CopyToNewMon
	ld hl, wMonSkillList
	ld de, $da39
	ld b, $03
	call CopyToNewMon
	call DropSupersededSkills
	ld hl, wMonGender
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, [wNewMonId]
	ld e, a
	ld a, [$da13]
	ld d, a
	ld a, e
	add $1d
	ld e, a
	ld a, d
	adc $4a
	ld d, a
	ld a, [de]
	ld [hl], a
	cp $ff
	jr nz, jr_014_42fe

	ld [hl], $00
	call Random
	ld hl, $459e
	ld a, [wMonSexChance]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wRandomHigh]
	cp [hl]
	jr z, jr_014_42fe

	jr nc, jr_014_42fe

	ld hl, wMonGender
	ld a, [wNewMonSlot]
	call MonsterField
	ld [hl], $01

jr_014_42fe:
	ld a, [wNewMonSlot]
	ld [wCurPartyMember], a
	ld hl, far_SetExpForLevel
	rst $10
	ld a, [$da13]
	or a
	jp nz, Jump_014_4413

	ld a, [wNewMonId]
	cp $01
	ld de, $45a2
	jp z, Jump_014_4469

	cp $0c
	ld de, $45aa
	jp z, Jump_014_4469

	cp $34
	ld de, $45c2
	jp z, Jump_014_4469

	cp $36
	ld de, $45ca
	jp z, Jump_014_4469

	cp $38
	ld de, $45d2
	jp z, Jump_014_4469

	cp $4c
	ld de, $45da
	jp z, Jump_014_4469

	cp $4e
	ld de, $45e2
	jp z, Jump_014_4469

	cp $50
	ld de, $45ea
	jp z, Jump_014_4469

	cp $64
	ld de, $45f2
	jp z, Jump_014_4469

	cp $66
	ld de, $45fa
	jp z, Jump_014_4469

	cp $68
	ld de, $4602
	jp z, Jump_014_4469

	cp $7c
	ld de, $460a
	jp z, Jump_014_4469

	cp $7e
	ld de, $4612
	jp z, Jump_014_4469

	cp $80
	ld de, $461a
	jp z, Jump_014_4469

	cp $94
	ld de, $4622
	jp z, Jump_014_4469

	cp $96
	ld de, $462a
	jp z, Jump_014_4469

	cp $9a
	ld de, $4632
	jp z, Jump_014_4469

	cp $b0
	ld de, $463a
	jp z, Jump_014_4469

	cp $b2
	ld de, $4642
	jp z, Jump_014_4469

	cp $b4
	ld de, $464a
	jp z, Jump_014_4469

	cp $c8
	ld de, $4652
	jp z, Jump_014_4469

	cp $ca
	ld de, $465a
	jp z, Jump_014_4469

	cp $cc
	ld de, $4662
	jp z, Jump_014_4469

	cp $ce
	ld de, $466a
	jp z, Jump_014_4469

	cp $d0
	ld de, $4672
	jp z, Jump_014_4469

	cp $d2
	ld de, $467a
	jp z, Jump_014_4469

	cp $d4
	ld de, $4682
	jp z, Jump_014_4469

	cp $d6
	ld de, $468a
	jp z, Jump_014_4469

	cp $d8
	ld de, $4692
	jp z, Jump_014_4469

	cp $da
	ld de, $469a
	jp z, Jump_014_4469

	cp $dc
	ld de, $46a2
	jp z, Jump_014_4469

	cp $df
	ld de, $46aa
	jp z, Jump_014_4469

	ret


Jump_014_4413:
	ld a, [wNewMonId]
	cp $31
	jr z, jr_014_4472

	cp $32
	jr z, jr_014_4489

	cp $33
	jp z, Jump_014_44a0

	cp $34
	jp z, Jump_014_44b7

	cp $35
	jp z, Jump_014_44ce

	cp $36
	jp z, Jump_014_44e5

	cp $37
	jp z, Jump_014_44fc

	cp $38
	jp z, Jump_014_4513

	cp $39
	jp z, Jump_014_452a

	cp $3a
	jp z, Jump_014_4541

	cp $3b
	jp z, Jump_014_4558

	cp $3c
	jp z, Jump_014_456f

	cp $5e
	jp z, Jump_014_4586

	cp $5f
	jp z, Jump_014_4592

	cp $e4
	ld de, $45b2
	jr z, jr_014_4469

	cp $e5
	ld de, $45ba
	jr z, jr_014_4469

	ret


Jump_014_4469:
jr_014_4469:
	ld hl, wMonName
	ld b, $08
	call CopyToNewMon
	ret


jr_014_4472:
	ld hl, wMonMaster
	ld de, $46ba
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $46c2
	ld b, $08
	call CopyToNewMon
	ret


jr_014_4489:
	ld hl, wMonMaster
	ld de, $46ca
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $46d2
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_44a0:
	ld hl, wMonMaster
	ld de, $46da
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $46e2
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_44b7:
	ld hl, wMonMaster
	ld de, $46ea
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $46f2
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_44ce:
	ld hl, wMonMaster
	ld de, $46fa
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4702
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_44e5:
	ld hl, wMonMaster
	ld de, $470a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4712
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_44fc:
	ld hl, wMonMaster
	ld de, $471a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4722
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_4513:
	ld hl, wMonMaster
	ld de, $472a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4732
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_452a:
	ld hl, wMonMaster
	ld de, $473a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4742
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_4541:
	ld hl, wMonMaster
	ld de, $474a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4752
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_4558:
	ld hl, wMonMaster
	ld de, $475a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4762
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_456f:
	ld hl, wMonMaster
	ld de, $476a
	ld b, $08
	call CopyToNewMon
	ld hl, wMonName
	ld de, $4772
	ld b, $08
	call CopyToNewMon
	ret


Jump_014_4586:
	ld hl, wMonEgg
	ld a, [wNewMonSlot]
	call MonsterField
	ld [hl], $01
	ret


Jump_014_4592:
	ld hl, wMonName
	ld de, $46b2
	ld b, $08
	call CopyToNewMon
	ret


FemaleChance::
	db $00, $1a, $80, $d6

FixedMonNames::
	db $36, $49, $46, $3f, $f0, $f0, $f0, $f0, $2b, $3e, $49, $42
	db $f0, $f0, $f0, $f0, $27, $4f, $3e, $4b, $f0, $f0, $f0, $f0, $2a, $4c, $49, $4a
	db $f0, $f0, $f0, $f0, $2a, $46, $44, $f0, $f0, $f0, $f0, $f0, $29, $3e, $40, $42
	db $f0, $f0, $f0, $f0, $33, $3e, $50, $45, $f0, $f0, $f0, $f0, $29, $3e, $4b, $44
	db $f0, $f0, $f0, $f0, $76, $8d, $62, $56, $58, $f0, $f0, $f0, $2a, $3e, $4b, $51
	db $f0, $f0, $f0, $f0, $26, $2d, $8d, $2b, $32, $8d, $f0, $f0, $3a, $4f, $42, $55
	db $f0, $f0, $f0, $f0, $30, $46, $4a, $42, $f0, $f0, $f0, $f0, $29, $52, $4b, $40
	db $f0, $f0, $f0, $f0, $67, $60, $6f, $8d, $85, $f0, $f0, $f0, $28, $3f, $46, $f0
	db $f0, $f0, $f0, $f0, $66, $8d, $80, $7b, $85, $f0, $f0, $f0, $30, $3e, $51, $50
	db $f0, $f0, $f0, $f0, $2e, $46, $55, $f0, $f0, $f0, $f0, $f0, $27, $3e, $4f, $48
	db $f0, $f0, $f0, $f0, $56, $62, $75, $8d, $9c, $f0, $f0, $f0, $28, $52, $34, $f0
	db $f0, $f0, $f0, $f0, $6e, $8d, $82, $85, $8c, $f0, $f0, $f0, $4f, $4b, $26, $28
	db $f0, $f0, $f0, $f0, $75, $9c, $64, $8d, $8c, $f0, $f0, $f0, $66, $6f, $8d, $9c
	db $f0, $f0, $f0, $f0, $75, $8d, $85, $7e, $67, $f0, $f0, $f0, $69, $8d, $9c, $7a
	db $f0, $f0, $f0, $f0, $76, $8e, $65, $89, $f0, $f0, $f0, $f0, $5c, $67, $6a, $62
	db $f0, $f0, $f0, $f0, $7b, $87, $6f, $8d, $85, $f0, $f0, $f0, $7c, $6f, $8d, $9c
	db $f0, $f0, $f0, $f0, $7c, $9c, $56, $f0, $f0, $f0, $f0, $f0, $3a, $3e, $51, $3e
	db $f0, $f0, $f0, $f0, $36, $49, $46, $4c, $f0, $f0, $f0, $f0, $30, $46, $40, $48
	db $f0, $f0, $f0, $f0, $2f, $46, $57, $41, $f0, $f0, $f0, $f0, $27, $4c, $3f, $f0
	db $f0, $f0, $f0, $f0, $29, $52, $44, $3e, $f0, $f0, $f0, $f0, $30, $46, $40, $48
	db $f0, $f0, $f0, $f0, $25, $4c, $4b, $42, $f0, $f0, $f0, $f0, $37, $42, $51, $4c
	db $f0, $f0, $f0, $f0, $2e, $52, $4f, $42, $f0, $f0, $f0, $f0, $30, $3e, $56, $f0
	db $f0, $f0, $f0, $f0, $3d, $42, $42, $f0, $f0, $f0, $f0, $f0, $37, $42, $51, $4c
	db $f0, $f0, $f0, $f0, $33, $3e, $40, $45, $f0, $f0, $f0, $f0, $30, $42, $51, $3e
	db $f0, $f0, $f0, $f0, $30, $4c, $45, $3e, $f0, $f0, $f0, $f0, $30, $3e, $44, $46
	db $f0, $f0, $f0, $f0, $62, $87, $6f, $9c, $f0, $f0, $f0, $f0, $37, $42, $51, $4c
	db $f0, $f0, $f0, $f0, $27, $46, $57, $f0, $f0, $f0, $f0, $f0, $30, $3e, $56, $f0
	db $f0, $f0, $f0, $f0, $33, $42, $51, $42, $f0, $f0, $f0, $f0, $30, $42, $51, $3e
	db $f0, $f0, $f0, $f0, $30, $42, $51, $3e, $f0, $f0, $f0, $f0, $30, $46, $49, $3e
	db $f0, $f0, $f0, $f0, $2e, $3e, $46, $f0, $f0, $f0, $f0, $f0

UnknownName::
	db $64, $64, $64, $f0
	db $f0, $f0, $f0, $f0

CopyToNewMon::
	push bc
	push de
	ld a, [wNewMonSlot]
	call MonsterField
	pop de
	pop bc

jr_014_478c:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_014_478c

	ret


SetNewMonByte::
	push de
	ld a, [wNewMonSlot]
	call MonsterField
	pop de
	ld a, [de]
	ld [hl], a
	ret


CopyToNewMonWord::
	ld b, $02
	jp CopyToNewMon


	db $06, $03, $c3, $82, $47

CopyToNewMon4::
	ld b, $04
	jp CopyToNewMon


DropSupersededSkills::
	ld hl, wMonSkills
	ld a, [wNewMonSlot]
	call MonsterField
	ld e, l
	ld d, h
	ld b, $08

jr_014_47ba:
	ld a, [de]
	push bc
	push de
	call DropSupersededSkill
	pop de
	pop bc
	inc de
	dec b
	jr nz, jr_014_47ba

	ret


DropSupersededSkill::
	cp $ff
	ret z

	cp $db
	jr nz, jr_014_47d2

	ld a, $ff
	ld [de], a
	ret


jr_014_47d2:
	ld hl, $491d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	push af
	ld hl, wMonSkillList
	ld a, [wNewMonSlot]
	call MonsterField
	pop af
	ld b, $19
	ld c, a

jr_014_47ed:
	ld a, [hl]
	cp $ff
	jr z, jr_014_47f8

	cp c
	jr nz, jr_014_47f8

	ld [hl], $ff
	ret


jr_014_47f8:
	inc hl
	dec b
	jr nz, jr_014_47ed

	ret


RandomizeNewMonByte::
	push hl
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $34
	call Divide8
	add $cd
	pop hl
	ret z

	push af
	ld a, [wNewMonSlot]
	call MonsterField
	ld c, [hl]
	ld b, $00
	pop af
	push hl
	call Multiply24
	ld c, h
	pop hl
	ld [hl], c
	ret


RandomizeNewMonWord::
	push hl
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $34
	call Divide8
	add $cd
	pop hl
	ret z

	push af
	ld a, [wNewMonSlot]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop af
	dec hl
	push hl
	call Multiply24
	ld c, h
	ld b, e
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	ret


LoadMonTemplateTo::
	push de
	ld a, [wNewMonId]
	ld c, a
	ld a, [$da13]
	ld b, a
	ld a, $19
	call Multiply24
	ld a, l
	add $1d
	ld l, a
	ld a, h
	adc $4c
	ld h, a
	pop de
	ld b, $19

jr_014_4862:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_014_4862

	ret


RemapMonId::
	ld a, [wNewMonId]
	ld c, a
	ld a, [$da13]
	ld b, a
	ld hl, $4893

jr_014_4874:
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	and e
	cp $ff
	jr nz, jr_014_487e

	ret


jr_014_487e:
	ld a, e
	cp c
	jr nz, jr_014_488f

	ld a, d
	cp b
	jr nz, jr_014_488f

	ld a, [hli]
	ld [wNewMonId], a
	ld a, [hli]
	ld [$da13], a
	ret


jr_014_488f:
	inc hl
	inc hl
	jr jr_014_4874

MonIdRemap::
	db $04, $00, $e6, $01, $0b, $00, $0c, $00, $1f, $00, $e4, $01, $20, $00, $e5, $01
	db $33, $00, $34, $00, $35, $00, $36, $00, $37, $00, $38, $00, $4b, $00, $4c, $00
	db $4d, $00, $4e, $00, $4f, $00, $50, $00, $63, $00, $64, $00, $65, $00, $66, $00
	db $67, $00, $68, $00, $7b, $00, $7c, $00, $7d, $00, $7e, $00, $7f, $00, $80, $00
	db $93, $00, $94, $00, $95, $00, $96, $00, $99, $00, $9a, $00, $af, $00, $b0, $00
	db $b1, $00, $b2, $00, $b3, $00, $b4, $00, $c7, $00, $c8, $00, $c9, $00, $ca, $00
	db $cb, $00, $cc, $00, $cd, $00, $ce, $00, $cf, $00, $d0, $00, $d1, $00, $d2, $00
	db $d3, $00, $d4, $00, $d5, $00, $d6, $00, $d7, $00, $d8, $00, $d9, $00, $da, $00
	db $db, $00, $dc, $00, $dd, $00, $de, $00, $ff, $ff

SkillSupersedes::
	db $00, $00, $00, $03, $03, $03
	db $06, $06, $06, $09, $09, $09, $0c, $0c, $0c, $0f, $0f, $0f, $12, $12, $14, $15
	db $15, $17, $18, $19, $1a, $1a, $1c, $1c, $1e, $1e, $20, $20, $22, $22, $24, $25
	db $26, $27, $27, $29, $2a, $2b, $2b, $2b, $2e, $2e, $30, $30, $32, $33, $34, $35
	db $36, $37, $38, $39, $ff, $3b, $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45
	db $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $50, $52, $52, $54, $55
	db $56, $57, $58, $58, $5a, $5b, $5c, $5c, $5c, $5c, $60, $60, $60, $60, $64, $65
	db $66, $67, $68, $69, $6a, $6b, $6c, $6c, $6e, $6f, $70, $71, $72, $73, $74, $75
	db $75, $77, $78, $79, $79, $7b, $7b, $7d, $7e, $7f, $80, $81, $82, $83, $84, $84
	db $84, $84, $88, $88, $8a, $8a, $8c, $ff, $8e, $8f, $90, $91, $92, $93, $94, $95
	db $96, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d5
	db $d6, $d7, $d8, $d9, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

MonGenderTable::
	db $ff, $00, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $01
	db $01, $01, $01, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

MonTemplates::
	db $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $08, $00, $00, $00, $01, $1e, $00, $00, $00, $0a, $00, $06, $00
	db $05, $00, $01, $00, $64, $c8, $64, $c8, $ff, $ff, $ff, $ff, $08, $03, $00, $02
	db $01, $08, $00, $00, $00, $08, $00, $05, $00, $07, $00, $01, $00, $c8, $32, $64
	db $c8, $ff, $ff, $ff, $ff, $35, $09, $00, $01, $01, $0c, $00, $00, $00, $13, $00
	db $04, $00, $04, $00, $03, $00, $96, $00, $32, $c8, $ff, $ff, $ff, $ff, $4e, $04
	db $00, $01, $01, $08, $00, $14, $00, $0c, $00, $04, $00, $0c, $00, $0e, $00, $c8
	db $00, $00, $c8, $33, $ff, $ff, $ff, $62, $09, $00, $02, $02, $14, $00, $06, $00
	db $17, $00, $08, $00, $0c, $00, $0a, $00, $64, $32, $c8, $c8, $15, $ff, $ff, $ff
	db $77, $0a, $00, $02, $02, $18, $00, $02, $00, $12, $00, $06, $00, $0a, $00, $08
	db $00, $64, $32, $00, $c8, $41, $ff, $ff, $ff, $8b, $0a, $00, $02, $02, $1a, $00
	db $09, $00, $0e, $00, $09, $00, $09, $00, $1c, $00, $32, $96, $c8, $c8, $03, $2b
	db $ff, $ff, $9b, $12, $00, $03, $03, $25, $00, $03, $00, $19, $00, $09, $00, $1f
	db $00, $0d, $00, $c8, $64, $c8, $c8, $79, $ff, $ff, $ff, $b7, $10, $00, $03, $05
	db $29, $00, $03, $00, $1c, $00, $08, $00, $08, $00, $06, $00, $96, $32, $96, $c8
	db $7b, $ff, $ff, $ff, $76, $0c, $00, $02, $03, $18, $00, $03, $00, $1d, $00, $09
	db $00, $0b, $00, $0d, $00, $fa, $32, $00, $c8, $68, $ff, $ff, $ff, $09, $00, $00
	db $00, $06, $28, $00, $07, $00, $14, $00, $0c, $00, $0c, $00, $1c, $00, $64, $fa
	db $64, $c8, $2b, $ff, $ff, $ff, $09, $00, $00, $00, $06, $1e, $00, $12, $00, $10
	db $00, $0a, $00, $20, $00, $1c, $00, $64, $fa, $c8, $c8, $2b, $ff, $ff, $ff, $1d
	db $20, $00, $03, $04, $2d, $00, $05, $00, $20, $00, $0a, $00, $12, $00, $06, $00
	db $96, $64, $96, $96, $72, $ff, $ff, $ff, $46, $19, $00, $02, $04, $20, $00, $06
	db $00, $1e, $00, $0c, $00, $1a, $00, $0c, $00, $c8, $64, $96, $96, $1c, $ff, $ff
	db $ff, $30, $1b, $00, $03, $04, $1d, $00, $0c, $00, $1a, $00, $0c, $00, $1e, $00
	db $0d, $00, $64, $32, $64, $96, $77, $ff, $ff, $ff, $a3, $2d, $00, $03, $05, $33
	db $00, $06, $00, $23, $00, $0a, $00, $0a, $00, $0a, $00, $96, $32, $32, $96, $6c
	db $79, $ff, $ff, $14, $37, $00, $03, $06, $20, $00, $07, $00, $20, $00, $14, $00
	db $23, $00, $0b, $00, $96, $64, $64, $96, $6a, $8c, $ff, $ff, $69, $32, $00, $02
	db $07, $2b, $00, $05, $00, $1d, $00, $19, $00, $0f, $00, $1c, $00, $c8, $00, $fa
	db $96, $4e, $69, $ff, $ff, $6f, $40, $00, $03, $08, $26, $00, $10, $00, $2c, $00
	db $1d, $00, $0c, $00, $0a, $00, $c8, $32, $64, $96, $1e, $ff, $ff, $ff, $3d, $37
	db $00, $02, $06, $30, $00, $12, $00, $20, $00, $0e, $00, $28, $00, $1e, $00, $64
	db $32, $c8, $96, $20, $d6, $ff, $ff, $4f, $43, $00, $02, $08, $30, $00, $12, $00
	db $1c, $00, $10, $00, $2a, $00, $09, $00, $c8, $96, $96, $96, $72, $8c, $ff, $ff
	db $85, $41, $00, $02, $07, $29, $00, $03, $00, $22, $00, $0e, $00, $28, $00, $13
	db $00, $64, $64, $fa, $96, $01, $ff, $ff, $ff, $ab, $43, $00, $03, $07, $35, $00
	db $14, $00, $35, $00, $0f, $00, $18, $00, $2d, $00, $32, $00, $00, $96, $45, $4b
	db $ff, $ff, $bb, $40, $00, $02, $07, $2d, $00, $14, $00, $3c, $00, $18, $00, $1a
	db $00, $2a, $00, $fa, $00, $64, $96, $1a, $4c, $ff, $ff, $01, $48, $00, $02, $08
	db $30, $00, $0b, $00, $27, $00, $0e, $00, $32, $00, $0b, $00, $64, $64, $64, $96
	db $52, $79, $ff, $ff, $26, $49, $00, $02, $08, $3e, $00, $08, $00, $20, $00, $21
	db $00, $0f, $00, $09, $00, $c8, $64, $32, $96, $17, $67, $ff, $ff, $68, $5a, $00
	db $02, $08, $3d, $00, $0b, $00, $28, $00, $22, $00, $1e, $00, $0a, $00, $fa, $00
	db $c8, $96, $1a, $25, $ff, $ff, $8a, $51, $00, $02, $09, $36, $00, $0e, $00, $2a
	db $00, $14, $00, $26, $00, $1e, $00, $c8, $00, $fa, $96, $01, $ff, $ff, $ff, $b2
	db $4e, $00, $03, $09, $42, $00, $1e, $00, $22, $00, $16, $00, $34, $00, $11, $00
	db $64, $c8, $64, $96, $34, $35, $ff, $ff, $10, $25, $0d, $06, $0a, $06, $00, $78
	db $00, $16, $00, $2c, $01, $82, $00, $20, $00, $64, $64, $64, $96, $00, $db, $ff
	db $ff, $1c, $00, $00, $00, $06, $5a, $00, $3c, $00, $28, $00, $19, $00, $0f, $00
	db $0a, $00, $fa, $32, $00, $96, $44, $5c, $ff, $ff, $c4, $00, $00, $00, $07, $64
	db $00, $14, $00, $2d, $00, $14, $00, $14, $00, $46, $00, $96, $96, $96, $96, $41
	db $56, $8e, $ff, $2e, $82, $00, $03, $0a, $39, $00, $2e, $00, $30, $00, $19, $00
	db $32, $00, $0f, $00, $96, $32, $64, $64, $15, $3d, $41, $ff, $48, $90, $00, $03
	db $0c, $48, $00, $11, $00, $40, $00, $15, $00, $39, $00, $0a, $00, $c8, $32, $c8
	db $64, $3c, $41, $d8, $ff, $5c, $79, $00, $03, $0c, $44, $00, $50, $00, $1e, $00
	db $1a, $00, $27, $00, $41, $00, $64, $96, $fa, $64, $04, $33, $36, $ff, $73, $7e
	db $00, $03, $0c, $3e, $00, $14, $00, $3b, $00, $18, $00, $2d, $00, $28, $00, $fa
	db $00, $c8, $64, $4a, $75, $ff, $ff, $88, $af, $00, $03, $0b, $50, $00, $14, $00
	db $3f, $00, $2d, $00, $2a, $00, $13, $00, $96, $00, $64, $64, $44, $57, $7b, $ff
	db $6e, $84, $00, $02, $0c, $3c, $00, $12, $00, $33, $00, $19, $00, $2b, $00, $15
	db $00, $64, $c8, $c8, $64, $79, $8c, $ff, $ff, $c3, $90, $00, $03, $0c, $4f, $00
	db $2c, $00, $38, $00, $1c, $00, $16, $00, $2c, $00, $96, $64, $c8, $64, $75, $77
	db $ff, $ff, $03, $97, $00, $03, $0c, $56, $00, $16, $00, $2c, $00, $1c, $00, $45
	db $00, $2e, $00, $64, $32, $c8, $64, $1c, $69, $6a, $ff, $1a, $96, $00, $03, $0c
	db $41, $00, $2b, $00, $3b, $00, $32, $00, $1a, $00, $17, $00, $96, $64, $64, $64
	db $67, $6c, $ff, $ff, $2f, $92, $00, $02, $0d, $43, $00, $2e, $00, $38, $00, $1a
	db $00, $43, $00, $31, $00, $96, $32, $96, $64, $17, $20, $ff, $ff, $5d, $a0, $00
	db $03, $0d, $45, $00, $3c, $00, $43, $00, $1e, $00, $34, $00, $28, $00, $c8, $64
	db $c8, $64, $32, $4d, $ff, $ff, $7a, $9c, $00, $03, $10, $36, $00, $0f, $00, $46
	db $00, $5a, $00, $55, $00, $32, $00, $32, $96, $c8, $64, $03, $2b, $ff, $ff, $9d
	db $91, $00, $03, $0e, $54, $00, $34, $00, $4c, $00, $23, $00, $1e, $00, $1a, $00
	db $c8, $00, $c8, $64, $1c, $20, $ff, $ff, $00, $99, $00, $03, $0e, $4b, $00, $1a
	db $00, $3a, $00, $20, $00, $60, $00, $34, $00, $96, $64, $c8, $64, $43, $5d, $ff
	db $ff, $18, $a8, $00, $03, $0e, $42, $00, $33, $00, $35, $00, $21, $00, $33, $00
	db $1b, $00, $96, $64, $96, $64, $18, $6a, $ff, $ff, $33, $aa, $00, $03, $0f, $5f
	db $00, $18, $00, $4f, $00, $1f, $00, $39, $00, $37, $00, $32, $32, $32, $64, $41
	db $6e, $ff, $ff, $71, $b0, $00, $02, $0f, $44, $00, $39, $00, $3b, $00, $24, $00
	db $4e, $00, $1c, $00, $c8, $00, $96, $64, $18, $6f, $ff, $ff, $4c, $be, $00, $03
	db $11, $49, $00, $37, $00, $43, $00, $31, $00, $50, $00, $55, $00, $c8, $32, $96
	db $64, $42, $8a, $ff, $ff, $44, $00, $00, $00, $0c, $c8, $00, $1e, $00, $3f, $00
	db $23, $00, $3f, $00, $23, $00, $fa, $00, $c8, $64, $46, $55, $7b, $ff, $44, $00
	db $00, $00, $0c, $50, $00, $1e, $00, $3f, $00, $32, $00, $3f, $00, $23, $00, $fa
	db $fa, $c8, $64, $46, $55, $7b, $ff, $66, $00, $00, $00, $0c, $90, $01, $64, $00
	db $3c, $00, $1e, $00, $26, $00, $37, $00, $c8, $32, $c8, $64, $17, $6f, $75, $ff
	db $66, $00, $00, $00, $0c, $64, $00, $64, $00, $2d, $00, $32, $00, $26, $00, $37
	db $00, $64, $96, $c8, $64, $17, $6f, $75, $ff, $95, $00, $00, $00, $0c, $2c, $01
	db $3c, $00, $4d, $00, $3c, $00, $28, $00, $32, $00, $fa, $00, $c8, $64, $3f, $4a
	db $ff, $ff, $95, $00, $00, $00, $0c, $55, $00, $3c, $00, $4d, $00, $4b, $00, $28
	db $00, $32, $00, $fa, $00, $c8, $32, $3f, $4a, $ff, $ff, $a4, $1c, $01, $03, $10
	db $4e, $00, $28, $00, $3a, $00, $2e, $00, $22, $00, $46, $00, $32, $c8, $fa, $32
	db $12, $2b, $ff, $ff, $b3, $1a, $01, $03, $10, $40, $00, $71, $00, $31, $00, $22
	db $00, $5f, $00, $6e, $00, $96, $32, $64, $32, $0a, $95, $ff, $ff, $04, $22, $01
	db $02, $10, $43, $00, $1e, $00, $41, $00, $73, $00, $6e, $00, $3c, $00, $fa, $fa
	db $32, $32, $0c, $52, $ff, $ff, $31, $f6, $00, $03, $11, $5f, $00, $3d, $00, $58
	db $00, $81, $00, $23, $00, $3e, $00, $96, $32, $96, $32, $1e, $56, $ff, $ff, $4b
	db $42, $01, $03, $16, $44, $00, $20, $00, $7e, $00, $46, $00, $7a, $00, $3d, $00
	db $fa, $00, $96, $32, $0a, $1c, $ff, $ff, $5f, $20, $01, $03, $11, $60, $00, $52
	db $00, $4b, $00, $64, $00, $42, $00, $4a, $00, $c8, $64, $96, $32, $0a, $68, $ff
	db $ff, $87, $40, $01, $03, $12, $62, $00, $43, $00, $4c, $00, $48, $00, $45, $00
	db $44, $00, $c8, $32, $fa, $32, $27, $7d, $ff, $ff, $9f, $56, $01, $03, $12, $82
	db $00, $44, $00, $4d, $00, $37, $00, $2a, $00, $26, $00, $c8, $32, $96, $32, $40
	db $52, $69, $ff, $06, $38, $01, $03, $12, $52, $00, $23, $00, $50, $00, $2c, $00
	db $78, $00, $3c, $00, $96, $64, $96, $32, $18, $67, $ff, $ff, $16, $96, $01, $03
	db $13, $8c, $00, $28, $00, $67, $00, $46, $00, $7b, $00, $50, $00, $c8, $64, $96
	db $32, $03, $58, $8a, $ff, $2d, $64, $01, $03, $13, $6c, $00, $3e, $00, $5a, $00
	db $3d, $00, $2d, $00, $28, $00, $fa, $32, $c8, $32, $68, $79, $ff, $ff, $49, $03
	db $01, $03, $13, $4b, $00, $56, $00, $41, $00, $2a, $00, $8e, $00, $78, $00, $c8
	db $96, $96, $32, $23, $4a, $95, $ff, $5a, $76, $01, $03, $14, $74, $00, $8c, $00
	db $48, $00, $32, $00, $87, $00, $5b, $00, $fa, $64, $fa, $32, $1c, $20, $34, $ff
	db $79, $c2, $01, $04, $18, $7d, $00, $25, $00, $77, $00, $7f, $00, $32, $00, $44
	db $00, $fa, $32, $c8, $32, $1e, $25, $3b, $ff, $8c, $31, $01, $04, $12, $52, $00
	db $44, $00, $42, $00, $60, $00, $58, $00, $40, $00, $64, $32, $64, $32, $18, $1c
	db $d8, $ff, $b1, $0a, $02, $03, $15, $5f, $00, $26, $00, $64, $00, $87, $00, $5b
	db $00, $43, $00, $c8, $64, $96, $32, $01, $56, $ff, $ff, $02, $66, $01, $04, $15
	db $4c, $00, $44, $00, $42, $00, $2c, $00, $96, $00, $44, $00, $64, $32, $64, $32
	db $55, $58, $8a, $ff, $3c, $9a, $01, $03, $15, $6a, $00, $44, $00, $61, $00, $2d
	db $00, $36, $00, $30, $00, $fa, $96, $c8, $32, $41, $4b, $4d, $ff, $0a, $00, $00
	db $00, $14, $90, $01, $28, $00, $57, $00, $32, $00, $50, $00, $41, $00, $c8, $64
	db $96, $00, $41, $52, $7d, $ff, $0a, $00, $00, $00, $14, $46, $00, $28, $00, $55
	db $00, $34, $00, $5a, $00, $41, $00, $c8, $c8, $c8, $32, $41, $52, $7d, $ff, $45
	db $dc, $05, $07, $14, $f4, $01, $28, $00, $50, $00, $28, $00, $3e, $00, $50, $00
	db $96, $96, $96, $32, $0d, $2b, $61, $ff, $45, $00, $00, $00, $14, $50, $00, $39
	db $00, $50, $00, $30, $00, $3e, $00, $50, $00, $96, $c8, $64, $32, $0d, $2b, $61
	db $ff, $96, $a4, $06, $06, $0e, $58, $02, $0a, $00, $82, $00, $1e, $00, $44, $00
	db $0f, $00, $fa, $fa, $fa, $32, $40, $41, $4d, $ff, $96, $00, $00, $00, $0e, $96
	db $00, $0a, $00, $82, $00, $2e, $00, $30, $00, $0f, $00, $fa, $fa, $fa, $32, $40
	db $41, $4d, $ff, $0d, $db, $01, $03, $16, $82, $00, $28, $00, $5b, $00, $3c, $00
	db $a2, $00, $69, $00, $96, $64, $96, $00, $77, $7c, $ff, $ff, $17, $fe, $01, $04
	db $16, $8d, $00, $6f, $00, $71, $00, $3b, $00, $1e, $00, $49, $00, $c8, $fa, $64
	db $00, $32, $3d, $ff, $ff, $34, $e0, $01, $03, $16, $6e, $00, $84, $00, $4e, $00
	db $51, $00, $82, $00, $69, $00, $c8, $96, $c8, $00, $0a, $0c, $46, $ff, $50, $4c
	db $02, $04, $17, $5b, $00, $54, $00, $aa, $00, $8c, $00, $5a, $00, $52, $00, $fa
	db $32, $c8, $00, $25, $57, $d7, $ff, $63, $f4, $01, $03, $17, $64, $00, $6e, $00
	db $5f, $00, $32, $00, $7e, $00, $8f, $00, $96, $64, $c8, $00, $1a, $41, $6a, $ff
	db $70, $ea, $01, $03, $17, $ac, $00, $37, $00, $5f, $00, $70, $00, $36, $00, $2b
	db $00, $00, $00, $00, $00, $12, $27, $52, $ff, $82, $06, $02, $03, $18, $5a, $00
	db $2e, $00, $66, $00, $44, $00, $50, $00, $3e, $00, $64, $64, $96, $00, $23, $25
	db $33, $ff, $a1, $76, $02, $04, $18, $79, $00, $57, $00, $8c, $00, $63, $00, $69
	db $00, $5c, $00, $fa, $c8, $c8, $00, $2b, $35, $36, $ff, $b4, $30, $02, $03, $18
	db $5d, $00, $2e, $00, $64, $00, $5d, $00, $32, $00, $3f, $00, $96, $32, $96, $00
	db $14, $42, $d6, $ff, $05, $49, $02, $04, $19, $90, $00, $2f, $00, $88, $00, $66
	db $00, $98, $00, $60, $00, $c8, $96, $96, $00, $1f, $2b, $4a, $ff, $23, $94, $02
	db $03, $19, $7e, $00, $2e, $00, $5f, $00, $52, $00, $82, $00, $2f, $00, $fa, $00
	db $64, $00, $67, $6f, $ff, $ff, $38, $58, $02, $04, $19, $7d, $00, $42, $00, $55
	db $00, $50, $00, $87, $00, $aa, $00, $96, $96, $c8, $00, $0d, $78, $92, $ff, $4d
	db $3d, $02, $03, $1a, $83, $00, $5e, $00, $69, $00, $69, $00, $84, $00, $64, $00
	db $96, $64, $96, $00, $18, $24, $74, $ff, $75, $80, $02, $03, $1a, $6a, $00, $31
	db $00, $8d, $00, $9b, $00, $60, $00, $31, $00, $c8, $32, $c8, $00, $15, $5d, $7b
	db $ff, $86, $d0, $02, $04, $14, $61, $00, $85, $00, $4d, $00, $5f, $00, $69, $00
	db $66, $00, $96, $00, $96, $00, $48, $6b, $73, $ff, $a5, $9a, $02, $03, $1b, $65
	db $00, $4a, $00, $3a, $00, $87, $00, $8c, $00, $6f, $00, $c8, $64, $96, $00, $58
	db $5a, $5d, $ff, $b6, $0c, $03, $03, $1b, $a0, $00, $26, $00, $a6, $00, $c8, $00
	db $4b, $00, $4f, $00, $fa, $fa, $96, $00, $2b, $40, $48, $ff, $07, $e4, $02, $04
	db $1b, $66, $00, $31, $00, $70, $00, $52, $00, $91, $00, $4c, $00, $64, $32, $96
	db $00, $01, $1e, $3c, $ff, $c5, $00, $19, $07, $14, $20, $03, $24, $00, $82, $00
	db $5a, $00, $2d, $00, $5a, $00, $fa, $64, $32, $00, $88, $8f, $ff, $ff, $c5, $00
	db $00, $00, $14, $aa, $00, $24, $00, $82, $00, $6e, $00, $2d, $00, $5a, $00, $fa
	db $32, $32, $00, $88, $8f, $ff, $ff, $2a, $00, $00, $00, $14, $e8, $03, $32, $00
	db $aa, $00, $50, $00, $50, $00, $46, $00, $fa, $64, $96, $00, $48, $5d, $ff, $ff
	db $2a, $00, $00, $00, $14, $a5, $00, $5a, $00, $8c, $00, $50, $00, $64, $00, $46
	db $00, $fa, $fa, $96, $00, $48, $5d, $ff, $ff, $ae, $00, $00, $00, $14, $20, $03
	db $30, $00, $5f, $00, $46, $00, $3c, $00, $3c, $00, $32, $32, $fa, $00, $29, $76
	db $7f, $ff, $ae, $00, $00, $00, $14, $50, $00, $30, $00, $64, $00, $55, $00, $3c
	db $00, $3c, $00, $c8, $32, $fa, $00, $29, $76, $7f, $ff, $8f, $c6, $02, $03, $1c
	db $a0, $00, $28, $00, $82, $00, $58, $00, $56, $00, $8c, $00, $c8, $00, $64, $00
	db $1c, $4b, $ff, $ff, $a8, $ee, $02, $04, $1c, $6e, $00, $87, $00, $9c, $00, $28
	db $00, $82, $00, $aa, $00, $c8, $32, $fa, $00, $4c, $6f, $74, $ff, $bf, $bc, $02
	db $04, $1c, $98, $00, $34, $00, $51, $00, $78, $00, $8e, $00, $8e, $00, $96, $96
	db $96, $00, $43, $5d, $61, $ff, $0b, $3e, $03, $04, $1d, $ba, $00, $09, $00, $8c
	db $00, $8a, $00, $59, $00, $37, $00, $fa, $c8, $96, $00, $42, $5b, $8e, $ff, $20
	db $08, $03, $04, $1d, $a0, $00, $95, $00, $5a, $00, $58, $00, $8a, $00, $55, $00
	db $c8, $32, $c8, $00, $19, $69, $ff, $ff, $3f, $8e, $03, $04, $1d, $dc, $00, $78
	db $00, $ac, $00, $5c, $00, $83, $00, $84, $00, $c8, $32, $c8, $00, $04, $21, $6a
	db $ff, $4a, $72, $03, $03, $1c, $75, $00, $73, $00, $8f, $00, $8a, $00, $a5, $00
	db $8c, $00, $96, $32, $64, $00, $15, $19, $6f, $ff, $5e, $d1, $03, $03, $1c, $c0
	db $00, $a5, $00, $8c, $00, $41, $00, $87, $00, $82, $00, $fa, $96, $fa, $00, $42
	db $69, $75, $ff, $78, $c0, $03, $04, $1e, $a0, $00, $3a, $00, $74, $00, $5a, $00
	db $79, $00, $58, $00, $96, $32, $96, $00, $47, $6c, $73, $ff, $84, $ed, $03, $04
	db $1f, $a0, $00, $5a, $00, $94, $00, $7d, $00, $5a, $00, $8e, $00, $c8, $32, $96
	db $00, $04, $6a, $ff, $ff, $a7, $4c, $04, $04, $1f, $74, $00, $8e, $00, $62, $00
	db $b0, $00, $7a, $00, $a5, $00, $96, $64, $c8, $00, $0b, $24, $36, $ff, $72, $bd
	db $03, $04, $1f, $8f, $00, $5a, $00, $41, $00, $8c, $00, $5a, $00, $8d, $00, $64
	db $96, $c8, $00, $1a, $24, $26, $ff, $0e, $b0, $04, $05, $20, $2c, $01, $3e, $00
	db $ce, $00, $63, $00, $73, $00, $aa, $00, $c8, $96, $96, $00, $4e, $68, $92, $ff
	db $21, $de, $03, $04, $1c, $78, $00, $5d, $00, $bc, $00, $63, $00, $5d, $00, $5a
	db $00, $c8, $64, $96, $00, $04, $58, $5d, $ff, $39, $0b, $04, $04, $20, $88, $00
	db $3c, $00, $9c, $00, $64, $00, $76, $00, $3e, $00, $fa, $00, $32, $00, $3e, $40
	db $41, $ff, $52, $d7, $03, $04, $1c, $b4, $00, $c5, $00, $a7, $00, $be, $00, $b4
	db $00, $60, $00, $96, $64, $c8, $00, $19, $75, $78, $ff, $65, $47, $04, $04, $21
	db $d5, $00, $b9, $00, $68, $00, $64, $00, $9c, $00, $b9, $00, $c8, $c8, $c8, $00
	db $0d, $2c, $36, $ff, $7c, $80, $04, $04, $21, $84, $00, $28, $00, $8e, $00, $64
	db $00, $44, $00, $7e, $00, $96, $00, $64, $00, $21, $d8, $ff, $ff, $58, $00, $00
	db $00, $1e, $b0, $04, $a0, $00, $64, $00, $8c, $00, $62, $00, $a0, $00, $96, $32
	db $96, $00, $6e, $94, $96, $ff, $58, $00, $00, $00, $1e, $78, $00, $a0, $00, $64
	db $00, $8c, $00, $62, $00, $a0, $00, $96, $32, $fa, $00, $6e, $94, $96, $ff, $2b
	db $78, $1e, $07, $1e, $b0, $04, $96, $00, $aa, $00, $78, $00, $50, $00, $50, $00
	db $c8, $32, $c8, $00, $43, $5e, $ff, $ff, $2b, $00, $00, $00, $1e, $7d, $00, $96
	db $00, $aa, $00, $9b, $00, $50, $00, $50, $00, $96, $32, $c8, $00, $43, $5e, $ff
	db $ff, $81, $00, $00, $00, $2d, $e8, $03, $55, $00, $be, $00, $96, $00, $3c, $00
	db $8c, $00, $96, $00, $96, $00, $8e, $8f, $ff, $ff, $81, $00, $00, $00, $2d, $e6
	db $00, $55, $00, $be, $00, $a0, $00, $3c, $00, $8c, $00, $96, $c8, $96, $00, $8e
	db $8f, $ff, $ff, $7b, $a3, $04, $04, $1c, $9b, $00, $a5, $00, $9b, $00, $a8, $00
	db $ba, $00, $a2, $00, $c8, $64, $c8, $00, $58, $69, $73, $ff, $83, $b8, $06, $05
	db $22, $e6, $00, $62, $00, $e6, $00, $b4, $00, $48, $00, $fa, $00, $c8, $32, $96
	db $00, $07, $45, $4b, $ff, $a6, $58, $05, $05, $22, $a0, $00, $a2, $00, $cb, $00
	db $a8, $00, $64, $00, $42, $00, $c8, $64, $fa, $00, $6a, $73, $83, $ff, $bc, $bd
	db $04, $04, $28, $c8, $00, $cc, $00, $b6, $00, $b4, $00, $66, $00, $c8, $00, $c8
	db $32, $c8, $00, $1f, $23, $25, $ff, $15, $19, $05, $04, $21, $a2, $00, $68, $00
	db $d4, $00, $fa, $00, $48, $00, $68, $00, $96, $64, $64, $00, $28, $5a, $ff, $ff
	db $40, $e2, $04, $04, $21, $a0, $00, $44, $00, $c3, $00, $4b, $00, $9e, $00, $64
	db $00, $fa, $00, $96, $00, $3b, $53, $7c, $ff, $51, $f8, $05, $05, $21, $f0, $00
	db $47, $00, $04, $01, $6e, $00, $6e, $00, $46, $00, $c8, $00, $96, $00, $0b, $45
	db $77, $ff, $61, $72, $04, $04, $24, $b4, $00, $c0, $00, $73, $00, $8c, $00, $b4
	db $00, $46, $00, $c8, $64, $fa, $00, $24, $25, $26, $ff, $7d, $13, $05, $05, $24
	db $82, $00, $6c, $00, $a0, $00, $e6, $00, $37, $00, $48, $00, $c8, $64, $c8, $00
	db $1f, $48, $53, $ff, $89, $b3, $04, $05, $1e, $96, $00, $47, $00, $ca, $00, $a2
	db $00, $38, $00, $ba, $00, $c8, $32, $c8, $00, $04, $61, $ff, $ff, $a2, $e8, $04
	db $05, $25, $d9, $00, $86, $00, $d2, $00, $d2, $00, $76, $00, $b9, $00, $fa, $32
	db $fa, $00, $61, $71, $83, $ff, $b0, $3f, $05, $04, $25, $ac, $00, $82, $00, $a7
	db $00, $e6, $00, $be, $00, $64, $00, $96, $32, $96, $00, $35, $61, $ff, $ff, $0c
	db $a4, $05, $05, $26, $fa, $00, $49, $00, $cd, $00, $c0, $00, $c8, $00, $64, $00
	db $fa, $c8, $c8, $00, $57, $5a, $90, $ff, $19, $43, $05, $04, $26, $d2, $00, $49
	db $00, $b6, $00, $6e, $00, $69, $00, $64, $00, $fa, $64, $32, $00, $40, $4a, $ff
	db $ff, $3a, $18, $06, $05, $26, $e6, $00, $12, $00, $1d, $01, $52, $00, $c8, $00
	db $50, $00, $fa, $00, $96, $00, $3b, $55, $7c, $ff, $47, $2c, $06, $04, $27, $c1
	db $00, $69, $00, $a5, $00, $82, $00, $a0, $00, $cd, $00, $c8, $64, $96, $00, $16
	db $2c, $61, $ff, $5b, $a0, $05, $04, $24, $b4, $00, $c8, $00, $53, $00, $80, $00
	db $9b, $00, $93, $00, $fa, $96, $c8, $00, $01, $35, $6b, $ff, $7e, $64, $05, $06
	db $26, $e9, $00, $69, $00, $a7, $00, $70, $00, $d2, $00, $78, $00, $c8, $00, $c8
	db $00, $67, $69, $8b, $ff, $99, $c8, $32, $07, $23, $40, $06, $af, $00, $04, $01
	db $a0, $00, $96, $00, $91, $00, $fa, $fa, $fa, $00, $02, $51, $8b, $ff, $99, $00
	db $00, $00, $23, $c8, $00, $af, $00, $04, $01, $c8, $00, $96, $00, $91, $00, $fa
	db $fa, $fa, $00, $02, $51, $8b, $ff, $ad, $e4, $3a, $05, $23, $e8, $03, $fa, $00
	db $a0, $00, $a0, $00, $c8, $00, $aa, $00, $fa, $96, $fa, $00, $02, $0e, $54, $ff
	db $ad, $00, $00, $00, $23, $a0, $00, $fa, $00, $a0, $00, $b4, $00, $c8, $00, $aa
	db $00, $fa, $fa, $fa, $00, $02, $0e, $54, $ff, $97, $00, $00, $07, $1e, $dc, $00
	db $73, $00, $cd, $00, $8c, $00, $40, $01, $c8, $00, $fa, $64, $c8, $00, $17, $44
	db $57, $ff, $98, $00, $00, $07, $1c, $af, $00, $62, $00, $aa, $00, $dc, $00, $84
	db $00, $92, $00, $fa, $32, $96, $00, $44, $45, $49, $ff, $0f, $68, $42, $05, $26
	db $d0, $07, $4b, $00, $c8, $00, $82, $00, $be, $00, $be, $00, $fa, $96, $c8, $00
	db $24, $2c, $ff, $ff, $0f, $00, $00, $00, $26, $e6, $00, $4b, $00, $c8, $00, $a0
	db $00, $be, $00, $be, $00, $96, $fa, $c8, $00, $24, $2c, $31, $ff, $60, $2c, $01
	db $05, $0a, $2d, $00, $11, $00, $19, $00, $17, $00, $28, $00, $24, $00, $00, $00
	db $00, $00, $68, $6a, $92, $ff, $74, $fa, $00, $05, $0a, $17, $00, $11, $00, $17
	db $00, $16, $00, $14, $00, $48, $00, $00, $00, $00, $00, $68, $70, $79, $ff, $8d
	db $3a, $07, $05, $28, $0c, $01, $82, $00, $ca, $00, $f6, $00, $d2, $00, $a0, $00
	db $96, $96, $c8, $00, $0b, $2e, $46, $ff, $9e, $90, $06, $04, $21, $9b, $00, $91
	db $00, $a7, $00, $84, $00, $f4, $00, $d2, $00, $96, $32, $96, $00, $3e, $45, $5a
	db $ff, $af, $d0, $07, $05, $26, $8a, $00, $7e, $00, $da, $00, $f6, $00, $b4, $00
	db $f0, $00, $64, $00, $32, $00, $04, $17, $19, $ff, $1b, $7b, $07, $04, $29, $f6
	db $00, $a5, $00, $be, $00, $d5, $00, $80, $00, $73, $00, $fa, $c8, $fa, $00, $4e
	db $57, $90, $ff, $36, $50, $07, $05, $29, $14, $01, $50, $00, $94, $00, $5a, $00
	db $da, $00, $9a, $00, $fa, $64, $c8, $00, $71, $7f, $94, $ff, $53, $1b, $08, $05
	db $29, $be, $00, $82, $00, $00, $01, $e0, $00, $a0, $00, $a0, $00, $c8, $64, $00
	db $00, $04, $2e, $ff, $ff, $6a, $cc, $07, $06, $2a, $c0, $00, $e1, $00, $b0, $00
	db $5a, $00, $73, $00, $6e, $00, $fa, $00, $c8, $00, $49, $56, $6a, $ff, $93, $52
	db $08, $05, $2a, $30, $01, $52, $00, $04, $01, $36, $01, $e2, $00, $e2, $00, $fa
	db $c8, $c8, $00, $44, $49, $89, $ff, $a0, $cf, $07, $04, $1c, $fe, $00, $87, $00
	db $04, $01, $de, $00, $55, $00, $8c, $00, $c8, $64, $00, $00, $26, $2a, $ff, $ff
	db $b5, $88, $08, $05, $26, $1c, $01, $5c, $00, $91, $00, $cc, $00, $e8, $00, $aa
	db $00, $96, $96, $96, $00, $28, $29, $ff, $ff, $27, $ee, $07, $04, $2b, $1c, $01
	db $8a, $00, $e6, $00, $b1, $00, $aa, $00, $8c, $00, $fa, $00, $96, $00, $42, $55
	db $6d, $ff, $3b, $1c, $07, $05, $26, $1f, $01, $8c, $00, $08, $01, $e6, $00, $64
	db $00, $8c, $00, $fa, $96, $c8, $00, $0d, $47, $7d, $ff, $64, $ea, $06, $04, $2c
	db $b0, $00, $7a, $00, $7c, $00, $f0, $00, $3c, $01, $96, $00, $c8, $64, $c8, $00
	db $71, $77, $78, $ff, $90, $10, $09, $04, $21, $20, $01, $8c, $00, $eb, $00, $eb
	db $00, $68, $00, $e6, $00, $fa, $00, $64, $00, $3f, $48, $57, $ff, $9c, $d4, $09
	db $05, $2b, $a4, $01, $57, $00, $02, $01, $50, $00, $87, $00, $e6, $00, $fa, $64
	db $96, $00, $3b, $47, $61, $ff, $b8, $70, $08, $04, $21, $cc, $00, $b4, $00, $dc
	db $00, $00, $01, $96, $00, $aa, $00, $c8, $32, $fa, $00, $18, $19, $1d, $ff, $1f
	db $2c, $0a, $06, $21, $ce, $00, $6e, $00, $eb, $00, $73, $00, $09, $01, $6e, $00
	db $fa, $64, $96, $00, $46, $4c, $67, $ff, $37, $c8, $08, $05, $2b, $2c, $01, $78
	db $00, $02, $01, $c8, $00, $78, $00, $b4, $00, $64, $fa, $fa, $00, $28, $89, $8e
	db $ff, $43, $54, $52, $05, $28, $d0, $07, $82, $00, $e1, $00, $78, $00, $50, $00
	db $d2, $00, $fa, $00, $c8, $00, $16, $17, $56, $ff, $43, $00, $00, $00, $28, $aa
	db $00, $82, $00, $f5, $00, $96, $00, $50, $00, $fa, $00, $fa, $00, $fa, $00, $16
	db $17, $56, $ff, $94, $d8, $59, $07, $28, $d0, $07, $90, $01, $e6, $00, $f0, $00
	db $fa, $00, $ff, $00, $c8, $64, $c8, $00, $08, $54, $62, $ff, $94, $00, $00, $00
	db $28, $2c, $01, $90, $01, $c8, $00, $2c, $01, $fa, $00, $ff, $00, $fa, $64, $c8
	db $00, $08, $54, $62, $ff, $29, $60, $6d, $07, $28, $d0, $07, $6e, $00, $2c, $01
	db $d2, $00, $82, $00, $82, $00, $fa, $00, $fa, $00, $44, $51, $5e, $ff, $29, $00
	db $00, $00, $28, $36, $01, $6e, $00, $2c, $01, $04, $01, $82, $00, $82, $00, $fa
	db $00, $fa, $00, $44, $51, $5e, $ff, $11, $e8, $fd, $06, $26, $08, $00, $ea, $01
	db $5f, $00, $02, $03, $ff, $01, $ff, $00, $fa, $fa, $fa, $00, $05, $08, $db, $ff
	db $32, $b0, $09, $05, $26, $68, $01, $5a, $00, $2c, $01, $b9, $00, $96, $00, $5a
	db $00, $fa, $00, $96, $00, $3d, $3f, $7d, $ff, $ba, $00, $0a, $05, $26, $5e, $01
	db $a5, $00, $fa, $00, $40, $01, $18, $01, $b4, $00, $fa, $64, $c8, $00, $08, $10
	db $ff, $ff, $24, $8c, $0a, $05, $1c, $fa, $00, $17, $00, $0e, $01, $54, $01, $5a
	db $00, $71, $00, $fa, $96, $96, $00, $3d, $3e, $5b, $ff, $41, $f0, $0a, $05, $2f
	db $0e, $01, $96, $00, $4a, $01, $d2, $00, $be, $00, $82, $00, $c8, $64, $96, $00
	db $3d, $72, $7d, $ff, $ac, $d2, $0a, $05, $2f, $b4, $00, $af, $00, $36, $01, $04
	db $01, $91, $00, $b4, $00, $fa, $32, $fa, $00, $1d, $4b, $51, $ff, $b9, $20, $0d
	db $06, $2b, $4a, $01, $69, $00, $18, $01, $04, $01, $fa, $00, $82, $00, $96, $32
	db $64, $00, $3f, $5b, $72, $ff, $1e, $4e, $0c, $05, $21, $dc, $00, $18, $00, $4f
	db $01, $82, $00, $5a, $00, $1e, $00, $fa, $00, $96, $00, $3f, $40, $78, $ff, $6b
	db $40, $0b, $05, $30, $eb, $00, $b9, $00, $fa, $00, $8c, $00, $8c, $00, $e6, $00
	db $c8, $64, $96, $00, $17, $53, $57, $ff, $8e, $c0, $0d, $06, $21, $0e, $01, $be
	db $00, $04, $01, $96, $00, $be, $00, $f0, $00, $fa, $64, $fa, $00, $08, $0b, $0e
	db $ff, $a9, $ae, $0b, $05, $30, $68, $01, $f0, $00, $54, $01, $18, $01, $18, $01
	db $d7, $00, $fa, $64, $c8, $00, $13, $2f, $ff, $ff, $bd, $d4, $0d, $05, $26, $2c
	db $01, $2d, $00, $54, $01, $e6, $00, $68, $01, $d2, $00, $fa, $32, $c8, $00, $51
	db $55, $57, $ff, $c6, $c4, $09, $04, $30, $36, $01, $be, $00, $af, $00, $fa, $00
	db $19, $00, $8c, $00, $c8, $64, $96, $00, $14, $32, $93, $ff, $22, $98, $0d, $05
	db $30, $68, $01, $18, $01, $e6, $00, $40, $01, $c8, $00, $fa, $00, $fa, $00, $c8
	db $00, $0b, $18, $6d, $ff, $3e, $30, $0c, $05, $30, $b4, $00, $4a, $01, $b4, $00
	db $96, $00, $22, $01, $ff, $00, $fa, $c8, $fa, $00, $2d, $31, $33, $ff, $25, $fc
	db $0d, $05, $33, $72, $01, $82, $00, $04, $01, $d2, $00, $aa, $00, $d2, $00, $fa
	db $c8, $fa, $00, $47, $62, $8f, $ff, $56, $f8, $0c, $05, $30, $18, $01, $78, $00
	db $d2, $00, $c8, $00, $f0, $00, $ff, $00, $fa, $96, $96, $00, $45, $5a, $ff, $ff
	db $57, $04, $0c, $06, $33, $f4, $01, $c8, $00, $af, $00, $fa, $00, $f0, $00, $e6
	db $00, $c8, $64, $96, $00, $2a, $83, $ff, $ff, $9a, $18, $79, $07, $2d, $b8, $0b
	db $4a, $01, $a4, $01, $7c, $01, $72, $01, $0a, $00, $c8, $00, $64, $00, $49, $4b
	db $59, $ff, $9a, $00, $00, $00, $2d, $dc, $00, $4a, $01, $7c, $01, $fa, $00, $be
	db $00, $ff, $00, $c8, $00, $c8, $00, $49, $4b, $59, $ff, $c8, $90, $65, $07, $30
	db $a0, $0f, $26, $02, $54, $01, $40, $01, $e6, $00, $ff, $00, $fa, $c8, $c8, $00
	db $05, $93, $d5, $ff, $c8, $00, $00, $00, $30, $fa, $00, $26, $02, $54, $01, $04
	db $01, $e6, $00, $ff, $00, $64, $c8, $fa, $00, $05, $93, $d5, $ff, $ca, $70, $94
	db $07, $32, $a0, $0f, $26, $02, $04, $01, $90, $01, $e6, $00, $ff, $00, $fa, $32
	db $fa, $00, $05, $08, $87, $ff, $ca, $00, $00, $00, $32, $be, $00, $26, $02, $04
	db $01, $54, $01, $e6, $00, $ff, $00, $96, $32, $fa, $00, $05, $08, $87, $ff, $cb
	db $70, $94, $07, $32, $70, $17, $e7, $03, $12, $02, $54, $01, $e6, $00, $0a, $00
	db $c8, $00, $c8, $00, $5f, $63, $64, $ff, $cb, $00, $00, $00, $32, $72, $01, $26
	db $02, $72, $01, $54, $01, $e6, $00, $ff, $00, $c8, $00, $c8, $00, $5f, $65, $80
	db $ff, $cc, $f8, $a7, $07, $32, $a0, $0f, $e7, $03, $9a, $01, $26, $02, $e6, $00
	db $0a, $00, $fa, $00, $96, $00, $08, $5b, $64, $ff, $cc, $00, $00, $00, $32, $fa
	db $00, $26, $02, $04, $01, $04, $01, $e6, $00, $ff, $00, $fa, $00, $64, $00, $19
	db $64, $65, $ff, $cd, $14, $b0, $07, $37, $94, $11, $e7, $03, $b8, $01, $90, $01
	db $04, $01, $ff, $00, $fa, $00, $c8, $00, $63, $65, $80, $ff, $cd, $00, $00, $00
	db $37, $90, $01, $58, $02, $a4, $01, $5e, $01, $04, $01, $ff, $00, $fa, $00, $c8
	db $00, $54, $63, $80, $ff, $ce, $a4, $98, $07, $37, $70, $17, $58, $02, $fe, $01
	db $c2, $01, $04, $01, $14, $00, $fa, $32, $c8, $00, $51, $5f, $64, $ff, $ce, $00
	db $00, $00, $37, $68, $01, $58, $02, $a4, $01, $5e, $01, $04, $01, $ff, $00, $64
	db $fa, $c8, $00, $51, $63, $82, $ff, $cf, $5c, $a4, $07, $3c, $d8, $0e, $bc, $02
	db $30, $02, $08, $02, $c2, $01, $ff, $00, $fa, $00, $fa, $00, $57, $80, $d9, $ff
	db $cf, $00, $00, $00, $3c, $58, $02, $bc, $02, $cc, $01, $c2, $01, $2c, $01, $ff
	db $00, $fa, $00, $fa, $00, $54, $5f, $80, $ff, $d0, $cc, $bb, $07, $3c, $88, $13
	db $e7, $03, $08, $02, $e0, $01, $2c, $01, $0a, $00, $fa, $00, $c8, $00, $02, $08
	db $11, $ff, $d0, $00, $00, $00, $3c, $7c, $01, $bc, $02, $cc, $01, $7c, $01, $2c
	db $01, $ff, $00, $fa, $00, $c8, $00, $02, $08, $0e, $ff, $d2, $14, $b0, $07, $3c
	db $88, $13, $e7, $03, $12, $02, $c2, $01, $2c, $01, $0a, $00, $fa, $64, $96, $00
	db $5f, $63, $6d, $ff, $d2, $00, $00, $00, $3c, $7c, $01, $bc, $02, $cc, $01, $c2
	db $01, $2c, $01, $ff, $00, $32, $64, $96, $00, $5f, $63, $6a, $ff, $d3, $50, $c3
	db $07, $3a, $28, $23, $bc, $02, $cc, $01, $08, $02, $c2, $01, $ff, $00, $fa, $00
	db $c8, $00, $64, $65, $86, $ff, $d3, $00, $00, $00, $3a, $7c, $01, $bc, $02, $cc
	db $01, $7c, $01, $2c, $01, $ff, $00, $fa, $00, $fa, $00, $08, $64, $6d, $ff, $d6
	db $e8, $fd, $00, $46, $28, $23, $52, $03, $0c, $03, $08, $02, $86, $01, $0a, $00
	db $fa, $96, $fa, $00, $50, $5f, $63, $ff, $d6, $00, $00, $00, $46, $e7, $03, $52
	db $03, $e7, $03, $08, $02, $86, $01, $ff, $00, $fa, $fa, $fa, $00, $50, $5f, $63
	db $ff, $6d, $00, $00, $00, $14, $96, $00, $cc, $01, $a0, $00, $cd, $00, $72, $01
	db $ff, $00, $00, $fa, $fa, $00, $39, $7e, $7f, $ff, $4e, $00, $00, $07, $01, $08
	db $00, $14, $00, $0c, $00, $04, $00, $0c, $00, $0e, $00, $c8, $00, $00, $96, $ff
	db $ff, $ff, $ff, $35, $00, $00, $07, $01, $0c, $00, $00, $00, $11, $00, $04, $00
	db $04, $00, $03, $00, $96, $00, $32, $c8, $ff, $ff, $ff, $ff, $4e, $00, $00, $07
	db $01, $08, $00, $14, $00, $0b, $00, $03, $00, $0a, $00, $0e, $00, $c8, $00, $00
	db $96, $ff, $ff, $ff, $ff, $08, $00, $00, $07, $01, $08, $00, $00, $00, $08, $00
	db $05, $00, $07, $00, $01, $00, $c8, $32, $64, $c8, $ff, $ff, $ff, $ff, $62, $00
	db $00, $07, $02, $10, $00, $06, $00, $13, $00, $07, $00, $0a, $00, $0a, $00, $64
	db $32, $c8, $64, $15, $ff, $ff, $ff, $08, $00, $00, $07, $01, $07, $00, $00, $00
	db $08, $00, $05, $00, $06, $00, $01, $00, $c8, $32, $64, $c8, $ff, $ff, $ff, $ff
	db $9b, $00, $00, $07, $07, $10, $00, $08, $00, $0d, $00, $0c, $00, $11, $00, $10
	db $00, $c8, $00, $c8, $c8, $79, $ff, $ff, $ff, $a3, $00, $00, $07, $05, $14, $00
	db $06, $00, $14, $00, $06, $00, $0a, $00, $0a, $00, $64, $00, $00, $32, $6c, $79
	db $ff, $ff, $9b, $00, $00, $07, $07, $0e, $00, $08, $00, $0f, $00, $09, $00, $0b
	db $00, $0d, $00, $c8, $00, $c8, $c8, $79, $ff, $ff, $ff, $01, $00, $00, $07, $08
	db $1a, $00, $0b, $00, $1e, $00, $11, $00, $1e, $00, $0b, $00, $c8, $00, $64, $96
	db $52, $ff, $ff, $ff, $01, $00, $00, $07, $09, $14, $00, $0c, $00, $1a, $00, $0f
	db $00, $1e, $00, $20, $00, $32, $00, $96, $00, $79, $ff, $ff, $ff, $01, $00, $00
	db $07, $08, $18, $00, $0f, $00, $1c, $00, $0e, $00, $20, $00, $0b, $00, $c8, $00
	db $c8, $96, $7f, $ff, $ff, $ff, $c3, $00, $00, $07, $0c, $26, $00, $14, $00, $16
	db $00, $12, $00, $18, $00, $2c, $00, $64, $00, $fa, $32, $75, $ff, $ff, $ff, $2e
	db $00, $00, $07, $0a, $2a, $00, $1a, $00, $1a, $00, $14, $00, $28, $00, $16, $00
	db $96, $00, $64, $64, $15, $3c, $41, $ff, $c3, $00, $00, $07, $0c, $28, $00, $2c
	db $00, $14, $00, $16, $00, $16, $00, $2c, $00, $32, $00, $fa, $32, $77, $ff, $ff
	db $ff, $9d, $00, $00, $07, $0c, $4b, $00, $0a, $00, $1c, $00, $18, $00, $1e, $00
	db $14, $00, $c8, $00, $96, $96, $1c, $20, $ff, $ff, $4c, $00, $00, $07, $0c, $32
	db $00, $0c, $00, $1e, $00, $18, $00, $3c, $00, $50, $00, $c8, $00, $64, $96, $42
	db $8a, $ff, $ff, $33, $00, $00, $07, $0c, $3a, $00, $08, $00, $26, $00, $12, $00
	db $32, $00, $32, $00, $96, $00, $64, $32, $41, $6e, $ff, $ff, $26, $00, $00, $07
	db $08, $3c, $00, $08, $00, $14, $00, $1e, $00, $0f, $00, $09, $00, $c8, $00, $64
	db $64, $17, $67, $d5, $ff, $03, $00, $00, $07, $0c, $46, $00, $08, $00, $1e, $00
	db $1a, $00, $31, $00, $2e, $00, $64, $00, $fa, $c8, $1c, $69, $6a, $ff, $1a, $00
	db $00, $07, $0c, $32, $00, $0e, $00, $23, $00, $1e, $00, $1a, $00, $17, $00, $96
	db $00, $32, $00, $67, $6c, $ff, $ff, $00, $00, $00, $07, $0e, $28, $00, $10, $00
	db $1e, $00, $1a, $00, $60, $00, $34, $00, $64, $00, $c8, $96, $43, $5c, $ff, $ff
	db $1c, $00, $00, $07, $0f, $41, $00, $14, $00, $2d, $00, $28, $00, $1e, $00, $1a
	db $00, $fa, $00, $00, $fa, $44, $5c, $ff, $ff, $18, $00, $00, $07, $0e, $28, $00
	db $15, $00, $19, $00, $1e, $00, $33, $00, $1b, $00, $96, $00, $64, $32, $18, $6a
	db $ff, $ff, $04, $00, $00, $07, $10, $2d, $00, $14, $00, $1e, $00, $3c, $00, $6e
	db $00, $3c, $00, $96, $64, $00, $96, $0c, $ff, $ff, $ff, $79, $00, $00, $07, $14
	db $50, $00, $1b, $00, $28, $00, $48, $00, $28, $00, $44, $00, $fa, $00, $64, $32
	db $1e, $25, $3b, $ff, $04, $00, $00, $07, $10, $28, $00, $14, $00, $20, $00, $37
	db $00, $6e, $00, $3c, $00, $96, $32, $00, $96, $52, $ff, $ff, $ff, $31, $00, $00
	db $07, $11, $50, $00, $1f, $00, $30, $00, $52, $00, $09, $00, $3e, $00, $96, $00
	db $c8, $64, $1e, $56, $ff, $ff, $49, $00, $00, $07, $13, $32, $00, $38, $00, $37
	db $00, $2a, $00, $8e, $00, $78, $00, $64, $32, $64, $fa, $23, $4a, $95, $ff, $5a
	db $00, $00, $07, $14, $64, $00, $64, $00, $34, $00, $32, $00, $87, $00, $5b, $00
	db $c8, $00, $fa, $64, $1c, $20, $34, $ff, $8c, $00, $00, $07, $14, $46, $00, $30
	db $00, $28, $00, $60, $00, $30, $00, $2c, $00, $64, $00, $64, $fa, $18, $1c, $d8
	db $ff, $3c, $00, $00, $07, $15, $64, $00, $26, $00, $3d, $00, $2d, $00, $36, $00
	db $30, $00, $fa, $00, $00, $c8, $41, $4b, $4d, $ff, $8c, $00, $00, $07, $14, $46
	db $00, $44, $00, $2c, $00, $5a, $00, $30, $00, $2c, $00, $64, $00, $64, $fa, $18
	db $1c, $d8, $ff, $44, $00, $00, $07, $14, $64, $00, $1c, $00, $41, $00, $3c, $00
	db $50, $00, $2d, $00, $c8, $32, $c8, $fa, $46, $55, $7b, $ff, $b6, $00, $00, $07
	db $1b, $6e, $00, $26, $00, $50, $00, $64, $00, $32, $00, $4f, $00, $fa, $fa, $96
	db $c8, $2b, $40, $48, $ff, $44, $00, $00, $07, $14, $64, $00, $1c, $00, $48, $00
	db $32, $00, $50, $00, $2d, $00, $fa, $32, $c8, $fa, $46, $55, $7b, $ff, $b4, $00
	db $00, $07, $18, $50, $00, $1a, $00, $46, $00, $53, $00, $32, $00, $3f, $00, $96
	db $64, $64, $fa, $14, $42, $d6, $ff, $50, $00, $00, $07, $17, $64, $00, $2c, $00
	db $64, $00, $78, $00, $5a, $00, $52, $00, $fa, $32, $32, $64, $25, $57, $d7, $ff
	db $b4, $00, $00, $07, $18, $50, $00, $2e, $00, $4b, $00, $53, $00, $32, $00, $3f
	db $00, $96, $64, $64, $fa, $14, $42, $d6, $ff, $09, $00, $00, $07, $16, $50, $00
	db $32, $00, $10, $00, $50, $00, $25, $00, $fa, $00, $c8, $fa, $64, $c8, $2b, $ff
	db $ff, $ff, $b6, $00, $00, $07, $1b, $b4, $00, $30, $00, $96, $00, $78, $00, $32
	db $00, $4f, $00, $fa, $32, $96, $c8, $2b, $40, $48, $ff, $09, $00, $00, $07, $16
	db $5a, $00, $32, $00, $10, $00, $50, $00, $25, $00, $fa, $00, $c8, $fa, $64, $c8
	db $2b, $ff, $ff, $ff, $07, $00, $00, $07, $1b, $f0, $00, $27, $00, $7a, $00, $64
	db $00, $91, $00, $4c, $00, $64, $32, $c8, $96, $1e, $3c, $ff, $ff, $0b, $00, $00
	db $07, $1d, $aa, $00, $14, $00, $9b, $00, $a0, $00, $59, $00, $37, $00, $c8, $64
	db $96, $fa, $42, $8e, $ff, $ff, $07, $00, $00, $07, $1b, $f0, $00, $1d, $00, $7a
	db $00, $64, $00, $91, $00, $4c, $00, $c8, $96, $96, $96, $01, $3c, $ff, $ff, $39
	db $00, $00, $07, $20, $96, $00, $1e, $00, $6e, $00, $5a, $00, $76, $00, $3e, $00
	db $fa, $00, $32, $fa, $3e, $40, $41, $ff, $39, $00, $00, $07, $20, $82, $00, $23
	db $00, $78, $00, $55, $00, $76, $00, $3e, $00, $fa, $00, $32, $fa, $3e, $41, $ff
	db $ff, $39, $00, $00, $07, $20, $78, $00, $1e, $00, $73, $00, $50, $00, $76, $00
	db $3e, $00, $fa, $00, $32, $fa, $3e, $40, $41, $ff, $84, $00, $00, $07, $1f, $c8
	db $00, $3c, $00, $62, $00, $73, $00, $5a, $00, $8e, $00, $c8, $32, $96, $96, $04
	db $6a, $ff, $ff, $a7, $00, $00, $07, $1f, $96, $00, $50, $00, $44, $00, $7e, $00
	db $7a, $00, $a5, $00, $c8, $64, $c8, $64, $0b, $24, $36, $ff, $65, $00, $00, $07
	db $21, $c8, $00, $55, $00, $40, $00, $50, $00, $9c, $00, $b9, $00, $c8, $c8, $c8
	db $32, $0c, $2b, $36, $ff, $7d, $00, $00, $07, $24, $aa, $00, $4e, $00, $64, $00
	db $96, $00, $69, $00, $48, $00, $fa, $32, $fa, $00, $1f, $48, $ff, $ff, $1e, $00
	db $00, $07, $21, $dc, $00, $14, $00, $c8, $00, $46, $00, $96, $00, $14, $00, $fa
	db $00, $96, $96, $3f, $40, $78, $ff, $7d, $00, $00, $07, $24, $82, $00, $4e, $00
	db $6e, $00, $8c, $00, $69, $00, $48, $00, $c8, $32, $fa, $00, $1f, $48, $52, $ff
	db $5b, $00, $00, $07, $27, $a0, $00, $50, $00, $49, $00, $6c, $00, $6e, $00, $93
	db $00, $fa, $00, $96, $64, $01, $35, $6b, $ff, $89, $00, $00, $07, $25, $96, $00
	db $3c, $00, $ac, $00, $84, $00, $6a, $00, $ba, $00, $fa, $32, $fa, $96, $04, $61
	db $ff, $ff, $47, $00, $00, $07, $27, $a0, $00, $4b, $00, $87, $00, $64, $00, $a0
	db $00, $cd, $00, $96, $96, $96, $fa, $16, $2c, $61, $ff, $3a, $00, $00, $07, $26
	db $fa, $00, $14, $00, $04, $01, $48, $00, $c8, $00, $50, $00, $fa, $00, $00, $c8
	db $55, $7c, $ff, $ff, $8d, $00, $00, $07, $28, $04, $01, $64, $00, $7a, $00, $c8
	db $00, $d2, $00, $a0, $00, $96, $96, $96, $32, $0b, $2e, $46, $ff, $3a, $00, $00
	db $07, $26, $f0, $00, $14, $00, $fa, $00, $48, $00, $c8, $00, $50, $00, $fa, $00
	db $00, $c8, $3b, $55, $7c, $ff, $60, $00, $00, $07, $28, $fa, $00, $78, $00, $96
	db $00, $a0, $00, $96, $00, $78, $00, $00, $00, $00, $00, $68, $6a, $92, $ff, $74
	db $00, $00, $07, $26, $5e, $01, $6e, $00, $aa, $00, $64, $00, $b4, $00, $96, $00
	db $32, $00, $32, $00, $68, $70, $79, $ff, $60, $00, $00, $07, $28, $fa, $00, $64
	db $00, $8c, $00, $96, $00, $78, $00, $78, $00, $00, $00, $00, $00, $68, $6a, $92
	db $ff, $64, $00, $00, $07, $2c, $a0, $00, $50, $00, $54, $00, $c8, $00, $78, $00
	db $96, $00, $c8, $00, $c8, $64, $71, $77, $78, $ff, $b8, $00, $00, $07, $21, $be
	db $00, $78, $00, $a8, $00, $d8, $00, $96, $00, $aa, $00, $fa, $00, $c8, $fa, $18
	db $19, $1d, $ff, $64, $00, $00, $07, $2c, $aa, $00, $55, $00, $56, $00, $be, $00
	db $3c, $01, $96, $00, $c8, $00, $96, $64, $71, $77, $78, $ff, $08, $00, $00, $07
	db $26, $fa, $00, $78, $00, $c8, $00, $82, $00, $04, $01, $8c, $00, $64, $00, $64
	db $c8, $05, $73, $ff, $ff, $4e, $00, $00, $07, $26, $b4, $00, $96, $00, $aa, $00
	db $82, $00, $a0, $00, $c8, $00, $c8, $00, $c8, $96, $16, $1a, $73, $ff, $76, $00
	db $00, $07, $21, $d2, $00, $64, $00, $fa, $00, $c8, $00, $96, $00, $5a, $00, $fa
	db $00, $00, $c8, $3e, $53, $68, $ff, $11, $00, $00, $07, $26, $0a, $00, $ea, $01
	db $6e, $00, $9e, $02, $ff, $01, $ff, $00, $fa, $fa, $fa, $00, $05, $08, $ff, $ff
	db $bd, $00, $00, $07, $26, $36, $01, $91, $00, $e6, $00, $b4, $00, $68, $01, $d2
	db $00, $fa, $32, $32, $32, $51, $55, $57, $ff, $b9, $00, $00, $07, $2b, $90, $01
	db $69, $00, $fa, $00, $c8, $00, $fa, $00, $82, $00, $c8, $32, $96, $64, $3f, $72
	db $ff, $ff, $97, $00, $00, $07, $2b, $40, $01, $55, $00, $cd, $00, $f0, $00, $40
	db $01, $c8, $00, $fa, $32, $c8, $fa, $17, $44, $57, $ff, $29, $00, $00, $07, $32
	db $2c, $01, $c8, $00, $a0, $00, $40, $01, $fa, $00, $b4, $00, $fa, $00, $fa, $c8
	db $44, $51, $5e, $ff, $1b, $00, $00, $07, $30, $fa, $00, $64, $00, $b4, $00, $d2
	db $00, $64, $00, $82, $00, $c8, $c8, $c8, $fa, $4e, $57, $90, $ff, $22, $00, $00
	db $07, $30, $54, $01, $b4, $00, $b9, $00, $04, $01, $c8, $00, $fa, $00, $c8, $00
	db $c8, $c8, $0b, $18, $6d, $ff, $3e, $00, $00, $07, $30, $dc, $00, $e6, $00, $aa
	db $00, $96, $00, $22, $01, $ff, $00, $fa, $fa, $fa, $fa, $2d, $31, $33, $ff, $1e
	db $00, $00, $07, $21, $dc, $00, $14, $00, $31, $01, $78, $00, $c8, $00, $1e, $00
	db $fa, $00, $c8, $96, $3f, $40, $78, $ff, $12, $00, $00, $07, $32, $08, $00, $bc
	db $02, $96, $00, $bc, $02, $ff, $01, $ff, $00, $fa, $fa, $fa, $c8, $10, $ff, $ff
	db $ff, $28, $00, $00, $07, $32, $2c, $01, $b4, $00, $dc, $00, $f0, $00, $40, $01
	db $c8, $00, $fa, $64, $96, $64, $08, $40, $45, $ff, $59, $00, $00, $07, $32, $7c
	db $01, $32, $00, $c8, $00, $dc, $00, $40, $01, $ff, $00, $c8, $96, $32, $fa, $66
	db $81, $ff, $ff, $19, $00, $00, $00, $14, $50, $00, $28, $00, $82, $00, $46, $00
	db $46, $00, $46, $00, $64, $64, $64, $64, $2b, $30, $8e, $ff, $2f, $00, $00, $00
	db $14, $32, $00, $28, $00, $50, $00, $32, $00, $64, $00, $46, $00, $c8, $00, $32
	db $c8, $1a, $1e, $25, $ff, $a1, $00, $00, $00, $14, $50, $00, $50, $00, $46, $00
	db $5a, $00, $3c, $00, $5a, $00, $fa, $32, $96, $96, $49, $4c, $d6, $ff, $c1, $00
	db $00, $00, $14, $50, $00, $28, $00, $50, $00, $96, $00, $32, $00, $28, $00, $00
	db $00, $00, $00, $88, $8a, $ff, $ff, $1f, $00, $00, $00, $1e, $96, $00, $50, $00
	db $a0, $00, $64, $00, $dc, $00, $5a, $00, $fa, $96, $64, $c8, $00, $03, $06, $ff
	db $7a, $00, $00, $00, $1e, $64, $00, $3c, $00, $82, $00, $78, $00, $8c, $00, $64
	db $00, $32, $96, $c8, $64, $76, $77, $78, $ff, $0a, $00, $00, $00, $1e, $5a, $00
	db $3c, $00, $aa, $00, $82, $00, $aa, $00, $5a, $00, $c8, $c8, $c8, $c8, $43, $50
	db $90, $ff, $7c, $00, $00, $00, $1e, $50, $00, $78, $00, $64, $00, $64, $00, $50
	db $00, $78, $00, $96, $00, $64, $64, $4b, $d6, $d7, $ff, $3b, $00, $00, $00, $26
	db $dc, $00, $8c, $00, $e6, $00, $d2, $00, $64, $00, $8c, $00, $96, $fa, $c8, $00
	db $17, $91, $92, $ff, $c5, $00, $00, $00, $28, $2c, $01, $78, $00, $c8, $00, $f0
	db $00, $5a, $00, $aa, $00, $fa, $32, $32, $c8, $2e, $32, $70, $ff, $10, $00, $00
	db $00, $14, $0a, $00, $c8, $00, $1e, $00, $2c, $01, $c8, $00, $32, $00, $00, $64
	db $64, $00, $88, $96, $ff, $ff, $ac, $00, $00, $00, $28, $a0, $00, $aa, $00, $36
	db $01, $04, $01, $8c, $00, $b4, $00, $fa, $32, $fa, $96, $4e, $4f, $d9, $ff, $c2
	db $0a, $00, $04, $01, $0c, $00, $02, $00, $0a, $00, $06, $00, $05, $00, $08, $00
	db $c8, $64, $64, $32, $ff, $ff, $ff, $ff, $c2, $1e, $00, $04, $05, $14, $00, $09
	db $00, $14, $00, $0c, $00, $0a, $00, $1e, $00, $c8, $64, $64, $32, $00, $ff, $ff
	db $ff, $c2, $5a, $00, $04, $0a, $2d, $00, $14, $00, $28, $00, $14, $00, $14, $00
	db $50, $00, $c8, $64, $64, $32, $00, $12, $ff, $ff, $c2, $2c, $01, $04, $14, $50
	db $00, $28, $00, $3c, $00, $28, $00, $28, $00, $82, $00, $c8, $64, $64, $32, $01
	db $12, $ff, $ff, $c2, $58, $02, $04, $1e, $7d, $00, $3c, $00, $50, $00, $3c, $00
	db $3c, $00, $aa, $00, $c8, $64, $64, $32, $01, $12, $ff, $ff, $c2, $b0, $04, $04
	db $26, $a5, $00, $50, $00, $64, $00, $50, $00, $50, $00, $d2, $00, $c8, $64, $64
	db $32, $02, $13, $ff, $ff, $c2, $04, $0c, $04, $26, $27, $01, $a0, $00, $78, $00
	db $6e, $00, $5a, $00, $e1, $00, $c8, $64, $64, $32, $02, $13, $ff, $ff, $c2, $bc
	db $17, $04, $26, $4a, $01, $dc, $00, $c8, $00, $96, $00, $6e, $00, $e1, $00, $c8
	db $64, $64, $32, $02, $13, $ff, $ff, $08, $00, $00, $00, $01, $04, $00, $02, $00
	db $03, $00, $04, $00, $08, $00, $05, $00, $00, $fa, $64, $96, $ff, $ff, $ff, $ff
	db $14, $00, $00, $00, $01, $08, $00, $04, $00, $0a, $00, $07, $00, $06, $00, $08
	db $00, $fa, $32, $00, $fa, $ff, $ff, $ff, $ff, $35, $00, $00, $00, $01, $06, $00
	db $03, $00, $06, $00, $04, $00, $07, $00, $05, $00, $64, $96, $fa, $32, $ff, $ff
	db $ff, $ff, $8a, $00, $00, $00, $01, $07, $00, $08, $00, $05, $00, $03, $00, $06
	db $00, $0a, $00, $32, $64, $fa, $96, $ff, $ff, $ff, $ff, $54, $00, $00, $00, $01
	db $0f, $00, $0a, $00, $0c, $00, $08, $00, $12, $00, $0a, $00, $96, $c8, $64, $c8
	db $ff, $ff, $ff, $ff, $55, $00, $00, $00, $01, $0f, $00, $0a, $00, $0c, $00, $08
	db $00, $12, $00, $0a, $00, $96, $c8, $64, $c8, $ff, $ff, $ff, $ff, $c0, $00, $00
	db $00, $01, $12, $00, $08, $00, $0c, $00, $12, $00, $04, $00, $06, $00, $fa, $64
	db $32, $96, $ff, $ff, $ff, $ff, $c1, $00, $00, $00, $01, $12, $00, $08, $00, $0c
	db $00, $12, $00, $04, $00, $06, $00, $fa, $64, $32, $96, $ff, $ff, $ff, $ff, $a5
	db $00, $00, $00, $01, $14, $00, $14, $00, $14, $00, $0f, $00, $19, $00, $0f, $00
	db $c8, $64, $c8, $c8, $ff, $ff, $ff, $ff, $79, $00, $00, $00, $01, $1e, $00, $14
	db $00, $14, $00, $1e, $00, $0f, $00, $0f, $00, $c8, $96, $64, $c8, $ff, $ff, $ff
	db $ff, $6a, $00, $00, $00, $01, $1e, $00, $1e, $00, $19, $00, $14, $00, $14, $00
	db $14, $00, $c8, $32, $96, $64, $ff, $ff, $ff, $ff, $56, $00, $00, $00, $01, $1e
	db $00, $19, $00, $1e, $00, $19, $00, $1e, $00, $14, $00, $96, $c8, $c8, $96, $ff
	db $ff, $ff, $ff, $41, $00, $00, $00, $01, $23, $00, $19, $00, $23, $00, $1e, $00
	db $19, $00, $19, $00, $fa, $96, $64, $64, $ff, $ff, $ff, $ff, $92, $00, $00, $00
	db $01, $23, $00, $14, $00, $23, $00, $14, $00, $23, $00, $14, $00, $c8, $64, $c8
	db $c8, $ff, $ff, $ff, $ff, $24, $00, $00, $00, $01, $28, $00, $1e, $00, $28, $00
	db $3c, $00, $14, $00, $1e, $00, $fa, $c8, $96, $96, $ff, $ff, $ff, $ff, $11, $00
	db $00, $00, $01, $0a, $00, $32, $00, $14, $00, $c8, $00, $c8, $00, $1e, $00, $00
	db $96, $64, $00, $ff, $ff, $ff, $ff, $62, $2c, $01, $04, $14, $50, $00, $78, $00
	db $28, $00, $1e, $00, $1e, $00, $64, $00, $64, $32, $c8, $64, $16, $4d, $ff, $ff
	db $ad, $00, $00, $06, $37, $2c, $01, $5e, $01, $7c, $01, $dc, $00, $32, $01, $ff
	db $00, $fa, $32, $64, $fa, $02, $0e, $ff, $ff, $d7, $00, $00, $07, $3c, $d0, $07
	db $c8, $00, $86, $01, $dc, $00, $90, $01, $ff, $00, $fa, $32, $64, $c8, $40, $45
	db $57, $ff, $d8, $00, $00, $07, $1e, $c8, $00, $64, $00, $b4, $00, $96, $00, $50
	db $00, $96, $00, $fa, $fa, $fa, $fa, $2c, $5a, $88, $ff, $d9, $00, $00, $07, $28
	db $2c, $01, $c8, $00, $d2, $00, $a0, $00, $78, $00, $64, $00, $fa, $fa, $fa, $fa
	db $25, $5e, $7a, $ff, $da, $00, $00, $07, $32, $c2, $01, $c8, $00, $fa, $00, $be
	db $00, $96, $00, $c8, $00, $fa, $fa, $fa, $fa, $40, $55, $57, $ff, $db, $00, $00
	db $07, $3c, $bc, $02, $90, $01, $5e, $01, $2c, $01, $64, $00, $fa, $00, $fa, $fa
	db $fa, $fa, $62, $64, $80, $ff, $dc, $00, $00, $07, $32, $e7, $03, $2c, $01, $2c
	db $01, $c8, $00, $c8, $00, $c8, $00, $fa, $00, $00, $fa, $5f, $63, $80, $ff, $14
	db $e8, $03, $04, $17, $46, $00, $3c, $00, $64, $00, $3c, $00, $5a, $00, $5a, $00
	db $96, $32, $96, $fa, $5d, $6a, $8c, $ff, $2b, $00, $00, $00, $01, $14, $00, $1b
	db $00, $1c, $00, $14, $00, $0f, $00, $10, $00, $96, $32, $c8, $fa, $ff, $ff, $ff
	db $ff, $08, $00, $00, $00, $01, $3c, $00, $32, $00, $40, $00, $36, $00, $78, $00
	db $41, $00, $00, $00, $64, $c8, $ff, $ff, $ff, $ff, $39, $46, $00, $05, $05, $19
	db $00, $0c, $00, $1c, $00, $0e, $00, $16, $00, $2d, $00, $c8, $32, $64, $c8, $45
	db $46, $47, $ff, $3f, $50, $00, $05, $06, $1a, $00, $0a, $00, $20, $00, $16, $00
	db $1a, $00, $19, $00, $fa, $00, $96, $c8, $3b, $3c, $3d, $ff, $75, $53, $00, $05
	db $05, $1b, $00, $0c, $00, $1a, $00, $1c, $00, $0f, $00, $1c, $00, $fa, $64, $32
	db $96, $46, $47, $48, $ff, $0e, $56, $00, $05, $06, $20, $00, $14, $00, $19, $00
	db $14, $00, $20, $00, $2b, $00, $c8, $64, $64, $fa, $50, $52, $57, $ff, $21, $5a
	db $00, $05, $06, $24, $00, $10, $00, $1c, $00, $10, $00, $0a, $00, $1e, $00, $c8
	db $00, $c8, $32, $5c, $60, $ff, $ff, $4a, $58, $00, $05, $05, $16, $00, $18, $00
	db $19, $00, $15, $00, $1f, $00, $22, $00, $c8, $32, $00, $64, $4a, $4b, $d6, $ff
	db $86, $51, $00, $05, $06, $16, $00, $2a, $00, $15, $00, $0e, $00, $24, $00, $29
	db $00, $64, $32, $96, $96, $25, $27, $77, $ff, $5e, $64, $00, $05, $06, $20, $00
	db $25, $00, $19, $00, $18, $00, $11, $00, $26, $00, $64, $64, $c8, $64, $78, $79
	db $90, $ff, $6b, $32, $00, $05, $05, $1e, $00, $17, $00, $14, $00, $0a, $00, $0c
	db $00, $22, $00, $96, $32, $fa, $c8, $12, $20, $72, $ff, $a8, $4c, $00, $05, $06
	db $1f, $00, $11, $00, $1d, $00, $0d, $00, $16, $00, $27, $00, $64, $00, $96, $64
	db $17, $91, $92, $ff, $4d, $44, $00, $05, $06, $23, $00, $22, $00, $10, $00, $18
	db $00, $20, $00, $1e, $00, $32, $00, $fa, $96, $15, $7d, $8a, $ff, $17, $4b, $00
	db $05, $05, $1a, $00, $06, $00, $22, $00, $19, $00, $0e, $00, $20, $00, $96, $96
	db $96, $64, $2b, $8c, $ff, $ff, $05, $3f, $00, $05, $05, $1d, $00, $18, $00, $1e
	db $00, $12, $00, $22, $00, $21, $00, $96, $64, $32, $fa, $1e, $22, $2b, $ff, $78
	db $4c, $00, $05, $06, $17, $00, $14, $00, $15, $00, $14, $00, $18, $00, $1c, $00
	db $c8, $96, $96, $32, $27, $2b, $ff, $ff, $65, $4c, $00, $05, $05, $25, $00, $2d
	db $00, $10, $00, $15, $00, $13, $00, $25, $00, $64, $96, $c8, $c8, $0c, $2b, $30
	db $ff, $84, $56, $00, $05, $05, $1e, $00, $24, $00, $20, $00, $17, $00, $17, $00
	db $2d, $00, $c8, $96, $c8, $c8, $3d, $88, $8e, $ff, $47, $b7, $00, $05, $0c, $2e
	db $00, $20, $00, $34, $00, $1c, $00, $30, $00, $54, $00, $c8, $32, $64, $00, $50
	db $55, $58, $ff, $61, $ba, $00, $05, $0d, $24, $00, $40, $00, $32, $00, $24, $00
	db $27, $00, $2a, $00, $fa, $00, $00, $96, $03, $4c, $5d, $ff, $83, $c8, $00, $05
	db $0c, $30, $00, $2e, $00, $35, $00, $2a, $00, $12, $00, $58, $00, $c8, $64, $c8
	db $96, $44, $46, $47, $ff, $c1, $d8, $00, $03, $0c, $26, $00, $29, $00, $2f, $00
	db $28, $00, $15, $00, $33, $00, $c8, $00, $00, $c8, $3f, $55, $d8, $ff, $0c, $cb
	db $00, $05, $0c, $34, $00, $18, $00, $2b, $00, $1f, $00, $31, $00, $3d, $00, $fa
	db $64, $64, $96, $4e, $56, $7d, $ff, $7d, $be, $00, $05, $0c, $2e, $00, $1f, $00
	db $32, $00, $24, $00, $1c, $00, $32, $00, $64, $00, $96, $32, $6f, $75, $d7, $ff
	db $a2, $a6, $00, $05, $0d, $3b, $00, $28, $00, $36, $00, $32, $00, $1a, $00, $2e
	db $00, $96, $32, $c8, $96, $15, $1a, $23, $ff, $19, $b0, $00, $05, $0d, $37, $00
	db $22, $00, $34, $00, $22, $00, $20, $00, $30, $00, $c8, $64, $c8, $00, $19, $78
	db $7b, $ff, $7e, $d2, $00, $06, $0d, $3c, $00, $25, $00, $36, $00, $1f, $00, $36
	db $00, $37, $00, $96, $32, $c8, $fa, $6f, $72, $8a, $ff, $5b, $99, $00, $05, $0c
	db $31, $00, $2a, $00, $28, $00, $1d, $00, $1e, $00, $2e, $00, $64, $00, $fa, $96
	db $6e, $79, $7d, $ff, $a7, $c4, $00, $05, $0c, $2c, $00, $2d, $00, $26, $00, $28
	db $00, $28, $00, $33, $00, $96, $64, $32, $c8, $2b, $88, $8a, $ff, $8f, $b4, $00
	db $05, $0d, $33, $00, $1d, $00, $24, $00, $19, $00, $2c, $00, $39, $00, $c8, $c8
	db $c8, $32, $2b, $30, $78, $ff, $7c, $96, $00, $05, $0c, $27, $00, $32, $00, $28
	db $00, $1c, $00, $1f, $00, $37, $00, $00, $c8, $c8, $fa, $2b, $83, $88, $ff, $55
	db $c1, $00, $05, $0c, $32, $00, $2f, $00, $35, $00, $1b, $00, $29, $00, $2f, $00
	db $c8, $c8, $c8, $fa, $2b, $5d, $8a, $ff, $7b, $aa, $00, $05, $0c, $29, $00, $2e
	db $00, $28, $00, $24, $00, $1d, $00, $39, $00, $c8, $96, $c8, $64, $2b, $67, $75
	db $ff, $3a, $b7, $00, $06, $0d, $39, $00, $2b, $00, $3e, $00, $17, $00, $30, $00
	db $18, $00, $fa, $fa, $fa, $fa, $2b, $3f, $73, $ff, $40, $f4, $01, $05, $14, $41
	db $00, $2e, $00, $4e, $00, $26, $00, $33, $00, $2f, $00, $fa, $00, $00, $64, $41
	db $48, $4e, $ff, $54, $01, $02, $05, $14, $48, $00, $35, $00, $47, $00, $2e, $00
	db $2e, $00, $39, $00, $c8, $64, $64, $96, $0a, $3b, $42, $ff, $b0, $0e, $02, $05
	db $15, $42, $00, $37, $00, $3b, $00, $2d, $00, $35, $00, $2d, $00, $fa, $00, $c8
	db $64, $01, $07, $41, $ff, $c0, $22, $02, $05, $15, $50, $00, $2b, $00, $58, $00
	db $31, $00, $28, $00, $33, $00, $c8, $32, $32, $96, $01, $44, $48, $ff, $bc, $29
	db $02, $05, $14, $3c, $00, $46, $00, $3e, $00, $32, $00, $2a, $00, $3b, $00, $fa
	db $64, $64, $00, $0d, $14, $49, $ff, $a6, $22, $02, $05, $14, $3f, $00, $44, $00
	db $55, $00, $37, $00, $40, $00, $3c, $00, $96, $00, $c8, $64, $19, $1d, $28, $ff
	db $bf, $33, $02, $05, $15, $39, $00, $2f, $00, $45, $00, $34, $00, $48, $00, $2e
	db $00, $96, $32, $96, $64, $16, $21, $6d, $ff, $a1, $04, $02, $05, $14, $50, $00
	db $41, $00, $48, $00, $43, $00, $34, $00, $4d, $00, $64, $00, $64, $64, $23, $7d
	db $91, $ff, $b6, $15, $02, $05, $15, $4b, $00, $3d, $00, $67, $00, $78, $00, $28
	db $00, $3d, $00, $c8, $64, $c8, $c8, $1b, $6f, $7a, $ff, $23, $33, $02, $05, $15
	db $64, $00, $27, $00, $50, $00, $48, $00, $6e, $00, $29, $00, $96, $32, $96, $00
	db $12, $25, $74, $ff, $55, $15, $02, $05, $14, $51, $00, $2e, $00, $4d, $00, $33
	db $00, $42, $00, $28, $00, $c8, $96, $00, $96, $2b, $26, $46, $ff, $1c, $33, $02
	db $05, $15, $69, $00, $24, $00, $53, $00, $3f, $00, $30, $00, $40, $00, $c8, $c8
	db $c8, $c8, $2b, $52, $88, $ff, $10, $a0, $0f, $06, $14, $0a, $00, $c8, $00, $2d
	db $00, $2c, $01, $fa, $00, $42, $00, $fa, $c8, $c8, $fa, $2b, $3f, $89, $ff, $51
	db $04, $02, $05, $15, $5f, $00, $39, $00, $6e, $00, $39, $00, $35, $00, $30, $00
	db $c8, $c8, $c8, $fa, $0a, $2b, $81, $ff, $89, $22, $02, $05, $14, $54, $00, $35
	db $00, $6e, $00, $47, $00, $40, $00, $64, $00, $fa, $fa, $fa, $00, $0f, $2b, $7c
	db $ff, $74, $4d, $01, $05, $14, $34, $00, $2b, $00, $2e, $00, $2e, $00, $24, $00
	db $39, $00, $fa, $fa, $fa, $fa, $2e, $32, $3e, $ff, $8d, $e8, $03, $05, $1a, $6e
	db $00, $46, $00, $64, $00, $6a, $00, $7a, $00, $75, $00, $fa, $96, $c8, $c8, $04
	db $43, $5e, $ff, $1f, $ee, $03, $05, $1a, $5d, $00, $37, $00, $68, $00, $3e, $00
	db $88, $00, $41, $00, $c8, $00, $00, $fa, $5a, $62, $69, $ff, $6a, $09, $04, $05
	db $1b, $58, $00, $72, $00, $5d, $00, $2d, $00, $2a, $00, $39, $00, $c8, $64, $96
	db $c8, $10, $5b, $79, $ff, $9e, $fc, $03, $05, $1a, $43, $00, $54, $00, $72, $00
	db $46, $00, $78, $00, $66, $00, $96, $32, $64, $00, $12, $46, $50, $ff, $90, $13
	db $04, $05, $1b, $86, $00, $48, $00, $78, $00, $6b, $00, $34, $00, $73, $00, $32
	db $00, $00, $00, $3b, $4a, $59, $ff, $37, $fc, $03, $05, $1a, $8c, $00, $3c, $00
	db $82, $00, $64, $00, $3d, $00, $5b, $00, $64, $64, $64, $64, $14, $24, $84, $ff
	db $ae, $2a, $04, $05, $1a, $37, $00, $2d, $00, $52, $00, $3d, $00, $40, $00, $39
	db $00, $96, $96, $96, $32, $26, $7f, $83, $ff, $a0, $ee, $03, $05, $19, $82, $00
	db $40, $00, $88, $00, $6f, $00, $36, $00, $46, $00, $32, $00, $96, $fa, $17, $76
	db $7a, $ff, $27, $24, $04, $05, $1a, $84, $00, $4d, $00, $78, $00, $59, $00, $55
	db $00, $4e, $00, $64, $32, $64, $64, $1d, $6e, $d8, $ff, $64, $2a, $04, $05, $19
	db $53, $00, $3d, $00, $3b, $00, $78, $00, $9c, $00, $55, $00, $fa, $fa, $fa, $fa
	db $25, $78, $92, $ff, $93, $e4, $03, $05, $1a, $63, $00, $29, $00, $87, $00, $9b
	db $00, $70, $00, $71, $00, $96, $96, $96, $64, $2c, $56, $95, $ff, $af, $1a, $04
	db $05, $19, $44, $00, $4c, $00, $7b, $00, $7e, $00, $28, $00, $82, $00, $c8, $c8
	db $c8, $32, $2e, $77, $85, $ff, $55, $10, $04, $05, $1a, $6e, $00, $41, $00, $7d
	db $00, $46, $00, $64, $00, $4b, $00, $64, $64, $64, $fa, $52, $6d, $94, $ff, $3f
	db $ff, $03, $05, $19, $85, $00, $6b, $00, $9b, $00, $52, $00, $62, $00, $80, $00
	db $c8, $96, $c8, $96, $2d, $30, $55, $ff, $66, $10, $04, $05, $1a, $7d, $00, $77
	db $00, $43, $00, $4a, $00, $33, $00, $56, $00, $32, $00, $32, $00, $26, $89, $d7
	db $ff, $1b, $45, $04, $05, $19, $7e, $00, $5f, $00, $5f, $00, $80, $00, $2e, $00
	db $43, $00, $fa, $c8, $c8, $fa, $10, $1f, $2c, $ff, $36, $82, $06, $05, $21, $9c
	db $00, $3c, $00, $4d, $00, $3c, $00, $88, $00, $4e, $00, $64, $00, $64, $c8, $05
	db $44, $51, $ff, $b5, $82, $06, $05, $21, $a4, $00, $3e, $00, $47, $00, $40, $00
	db $aa, $00, $78, $00, $96, $32, $32, $fa, $07, $4b, $57, $ff, $3b, $aa, $06, $05
	db $22, $c6, $00, $6e, $00, $aa, $00, $aa, $00, $50, $00, $5e, $00, $fa, $96, $64
	db $64, $0b, $42, $59, $ff, $9c, $b8, $06, $05, $21, $a4, $00, $3f, $00, $84, $00
	db $ae, $00, $55, $00, $a9, $00, $c8, $64, $32, $fa, $02, $3b, $55, $ff, $97, $dc
	db $06, $05, $21, $c8, $00, $7e, $00, $e1, $00, $0e, $01, $40, $01, $dc, $00, $fa
	db $32, $32, $96, $14, $59, $67, $ff, $98, $b4, $06, $05, $22, $b9, $00, $66, $00
	db $e5, $00, $a4, $01, $87, $00, $94, $00, $c8, $32, $fa, $64, $16, $24, $57, $ff
	db $b8, $e0, $06, $05, $21, $9a, $00, $94, $00, $a8, $00, $a4, $00, $78, $00, $85
	db $00, $64, $32, $96, $c8, $28, $6d, $7d, $ff, $c4, $bb, $06, $05, $21, $d2, $00
	db $3b, $00, $6c, $00, $b6, $00, $34, $00, $c0, $00, $64, $64, $64, $fa, $6e, $76
	db $94, $ff, $c0, $b1, $06, $05, $21, $b4, $00, $3f, $00, $9e, $00, $b3, $00, $57
	db $00, $65, $00, $c8, $32, $c8, $96, $6f, $74, $86, $ff, $54, $d2, $06, $05, $21
	db $b6, $00, $67, $00, $79, $00, $74, $00, $98, $00, $6b, $00, $c8, $64, $c8, $96
	db $72, $7a, $8b, $ff, $44, $be, $06, $05, $22, $a6, $00, $40, $00, $9f, $00, $7c
	db $00, $a3, $00, $6b, $00, $96, $96, $96, $fa, $2c, $47, $78, $ff, $c5, $cc, $06
	db $05, $22, $dc, $00, $60, $00, $93, $00, $dc, $00, $47, $00, $7d, $00, $c8, $96
	db $c8, $c8, $05, $2e, $8f, $ff, $45, $a7, $06, $05, $21, $9b, $00, $86, $00, $a2
	db $00, $7a, $00, $89, $00, $64, $00, $fa, $fa, $fa, $fa, $2e, $32, $42, $ff, $10
	db $bc, $17, $06, $1e, $0f, $00, $2c, $01, $41, $00, $90, $01, $5e, $01, $56, $00
	db $fa, $c8, $fa, $64, $2b, $3e, $8f, $ff, $17, $d2, $06, $05, $22, $a4, $00, $3a
	db $00, $43, $00, $75, $00, $50, $00, $61, $00, $96, $32, $64, $00, $2c, $53, $8f
	db $ff, $96, $c2, $06, $05, $21, $d2, $00, $14, $00, $e2, $00, $54, $00, $80, $00
	db $12, $00, $64, $64, $64, $64, $7f, $89, $d6, $ff, $ac, $69, $0d, $05, $27, $91
	db $00, $a0, $00, $10, $01, $e0, $00, $80, $00, $a6, $00, $c8, $32, $32, $96, $4b
	db $54, $d7, $ff, $6b, $c0, $0d, $05, $28, $ba, $00, $a1, $00, $ea, $00, $7c, $00
	db $7f, $00, $76, $00, $fa, $00, $64, $c8, $43, $5f, $d8, $ff, $c0, $da, $0d, $05
	db $26, $be, $00, $71, $00, $c6, $00, $9f, $00, $8c, $00, $65, $00, $c8, $32, $32
	db $96, $11, $3b, $55, $ff, $55, $cd, $0d, $05, $28, $b5, $00, $74, $00, $b1, $00
	db $79, $00, $9b, $00, $51, $00, $c8, $32, $00, $96, $4c, $68, $87, $ff, $0f, $9b
	db $0d, $05, $26, $fa, $00, $5e, $00, $da, $00, $b5, $00, $ce, $00, $c8, $00, $fa
	db $96, $00, $c8, $0e, $40, $49, $ff, $4b, $bc, $0d, $05, $26, $8b, $00, $58, $00
	db $c5, $00, $73, $00, $ba, $00, $7f, $00, $c8, $00, $c8, $64, $16, $25, $4a, $ff
	db $c6, $a8, $0d, $05, $28, $04, $01, $ae, $00, $9c, $00, $e9, $00, $14, $00, $86
	db $00, $96, $32, $96, $00, $29, $6b, $7c, $ff, $0a, $e1, $0d, $05, $21, $b8, $00
	db $4e, $00, $a6, $00, $97, $00, $37, $01, $8d, $00, $64, $00, $c8, $fa, $1f, $74
	db $7d, $ff, $56, $ff, $0d, $05, $27, $e0, $00, $57, $00, $bb, $00, $a7, $00, $d2
	db $00, $de, $00, $64, $64, $64, $32, $82, $91, $92, $ff, $24, $8a, $0d, $05, $1c
	db $cc, $00, $12, $00, $b1, $00, $2c, $01, $51, $00, $68, $00, $c8, $c8, $c8, $64
	db $28, $67, $83, $ff, $97, $d4, $0d, $05, $28, $fb, $00, $7c, $00, $22, $01, $60
	db $01, $52, $01, $d3, $00, $c8, $c8, $c8, $c8, $30, $44, $70, $ff, $c6, $9b, $0d
	db $05, $27, $d2, $00, $9d, $00, $8a, $00, $ef, $00, $12, $00, $84, $00, $64, $64
	db $64, $96, $46, $81, $92, $ff, $2b, $bc, $0d, $05, $21, $a5, $00, $a4, $00, $c6
	db $00, $af, $00, $7b, $00, $70, $00, $fa, $fa, $fa, $fa, $14, $23, $31, $ff, $2a
	db $91, $0d, $05, $27, $bb, $00, $7a, $00, $1e, $01, $bb, $00, $c8, $00, $8d, $00
	db $c8, $96, $96, $00, $63, $6f, $94, $ff, $58, $d4, $0d, $05, $27, $b2, $00, $c5
	db $00, $97, $00, $e3, $00, $8f, $00, $c6, $00, $32, $32, $32, $00, $1f, $2e, $5a
	db $ff, $c5, $a8, $0d, $05, $28, $de, $00, $7e, $00, $c7, $00, $01, $01, $6b, $00
	db $b8, $00, $64, $64, $64, $64, $17, $87, $89, $ff, $32, $e4, $1b, $06, $26, $54
	db $01, $5a, $00, $2c, $01, $b9, $00, $96, $00, $5a, $00, $fa, $00, $64, $32, $0e
	db $42, $4d, $ff, $25, $5c, $1c, $06, $2d, $5e, $01, $82, $00, $f0, $00, $d2, $00
	db $aa, $00, $d2, $00, $fa, $00, $32, $c8, $0b, $41, $d6, $ff, $41, $38, $1d, $06
	db $2d, $be, $00, $96, $00, $4a, $01, $d2, $00, $be, $00, $82, $00, $c8, $32, $64
	db $c8, $02, $45, $4c, $ff, $b9, $9c, $1e, $06, $2b, $36, $01, $69, $00, $f0, $00
	db $dc, $00, $fa, $00, $82, $00, $96, $32, $32, $64, $08, $40, $47, $ff, $56, $fd
	db $1e, $06, $2d, $04, $01, $78, $00, $d2, $00, $c8, $00, $f0, $00, $ff, $00, $fa
	db $32, $96, $64, $3f, $46, $59, $ff, $57, $69, $1c, $06, $2d, $e0, $01, $c8, $00
	db $96, $00, $fa, $00, $f0, $00, $e6, $00, $c8, $c8, $96, $fa, $32, $51, $72, $ff
	db $11, $a8, $76, $06, $26, $17, $00, $ea, $01, $be, $00, $9e, $02, $ff, $01, $ff
	db $00, $64, $32, $96, $00, $28, $3c, $53, $ff, $ba, $67, $1e, $06, $21, $4a, $01
	db $a5, $00, $d2, $00, $40, $01, $18, $01, $b4, $00, $fa, $64, $c8, $fa, $16, $69
	db $78, $ff, $1e, $08, $1c, $06, $21, $c8, $00, $18, $00, $4f, $01, $82, $00, $be
	db $00, $1e, $00, $fa, $00, $c8, $96, $43, $63, $92, $ff, $8e, $20, $1c, $06, $21
	db $96, $00, $be, $00, $dc, $00, $96, $00, $be, $00, $f0, $00, $c8, $96, $fa, $00
	db $1d, $6f, $7a, $ff, $a9, $74, $1d, $06, $2e, $54, $01, $f0, $00, $54, $01, $18
	db $01, $18, $01, $d7, $00, $c8, $fa, $c8, $c8, $2d, $44, $8c, $ff, $bd, $79, $1b
	db $06, $26, $18, $01, $f5, $00, $54, $01, $e6, $00, $68, $01, $d2, $00, $fa, $fa
	db $fa, $32, $2e, $4f, $8b, $ff, $22, $cc, $1b, $06, $2d, $54, $01, $18, $01, $c8
	db $00, $40, $01, $c8, $00, $fa, $00, $fa, $fa, $c8, $c8, $31, $81, $8f, $ff, $3e
	db $22, $25, $06, $2d, $c8, $00, $4a, $01, $c8, $00, $96, $00, $22, $01, $ff, $00
	db $c8, $fa, $fa, $fa, $55, $78, $89, $ff, $81, $79, $1b, $06, $2e, $0b, $01, $73
	db $00, $c5, $00, $01, $01, $6e, $00, $b9, $00, $96, $96, $96, $32, $94, $96, $d8
	db $ff, $ae, $59, $1d, $06, $26, $d2, $00, $d2, $00, $78, $00, $a7, $00, $8a, $00
	db $c8, $00, $fa, $fa, $fa, $fa, $29, $3e, $63, $ff, $25, $58, $34, $06, $32, $72
	db $01, $96, $00, $fa, $00, $dc, $00, $be, $00, $e6, $00, $fa, $fa, $fa, $fa, $25
	db $4f, $7a, $ff, $bd, $bc, $34, $06, $26, $2c, $01, $04, $01, $5e, $01, $f0, $00
	db $7c, $01, $fa, $00, $fa, $fa, $fa, $fa, $2c, $54, $55, $ff, $ba, $62, $35, $06
	db $21, $7c, $01, $be, $00, $f0, $00, $54, $01, $2c, $01, $d2, $00, $fa, $fa, $fa
	db $fa, $11, $2e, $83, $ff, $57, $30, $35, $06, $32, $f4, $01, $c8, $00, $b4, $00
	db $04, $01, $fa, $00, $ff, $00, $fa, $fa, $fa, $fa, $40, $87, $94, $ff, $b9, $3d
	db $34, $06, $2b, $4a, $01, $78, $00, $04, $01, $f0, $00, $fa, $00, $a0, $00, $fa
	db $fa, $fa, $fa, $39, $6e, $7c, $ff, $91, $cc, $34, $06, $30, $54, $01, $2c, $01
	db $4a, $01, $d2, $00, $96, $00, $d2, $00, $fa, $fa, $fa, $fa, $63, $7f, $89, $ff
	db $92, $20, $35, $06, $30, $36, $01, $2c, $01, $2c, $01, $c8, $00, $04, $01, $ff
	db $00, $fa, $fa, $fa, $fa, $14, $54, $93, $ff, $12, $a8, $76, $06, $32, $19, $00
	db $bc, $02, $22, $01, $bc, $02, $ff, $01, $ff, $00, $fa, $fa, $fa, $fa, $68, $89
	db $96, $ff, $29, $80, $34, $06, $32, $68, $01, $96, $00, $68, $01, $5e, $01, $c8
	db $00, $b4, $00, $fa, $fa, $fa, $fa, $13, $78, $94, $ff, $41, $20, $35, $06, $30
	db $dc, $00, $aa, $00, $fa, $00, $dc, $00, $d2, $00, $96, $00, $fa, $fa, $fa, $fa
	db $08, $7d, $91, $ff, $6b, $52, $35, $06, $32, $fa, $00, $d2, $00, $fa, $00, $a0
	db $00, $a0, $00, $c8, $00, $fa, $fa, $fa, $fa, $42, $4f, $7a, $ff, $7f, $f4, $34
	db $06, $30, $7c, $01, $be, $00, $f0, $00, $fa, $00, $2c, $01, $c8, $00, $fa, $fa
	db $fa, $fa, $67, $72, $93, $ff, $a9, $d6, $34, $06, $30, $54, $01, $5e, $01, $5e
	db $01, $be, $00, $22, $01, $e6, $00, $fa, $fa, $fa, $fa, $66, $77, $8e, $ff, $ad
	db $05, $35, $06, $32, $f0, $00, $54, $01, $d2, $00, $40, $01, $22, $01, $fa, $00
	db $fa, $fa, $fa, $fa, $5f, $6f, $8b, $ff, $c5, $68, $34, $06, $30, $68, $01, $a0
	db $00, $f0, $00, $68, $01, $64, $00, $c8, $00, $fa, $fa, $fa, $fa, $43, $63, $74
	db $ff, $c6, $3e, $35, $06, $30, $22, $01, $c8, $00, $b4, $00, $04, $01, $14, $00
	db $96, $00, $fa, $fa, $fa, $fa, $57, $7f, $d5, $ff, $08, $e8, $fd, $01, $01, $02
	db $00, $00, $00, $02, $00, $02, $00, $02, $00, $02, $00, $64, $64, $64, $64, $ff
	db $ff, $ff, $ff, $13, $00, $00, $07, $46, $84, $03, $58, $02, $90, $01, $e7, $03
	db $9b, $01, $ff, $00, $00, $fa, $00, $fa, $2e, $31, $81, $ff, $2c, $00, $00, $07
	db $46, $64, $19, $e7, $03, $bc, $02, $90, $01, $18, $01, $ff, $00, $fa, $00, $fa
	db $fa, $40, $54, $64, $ff, $6c, $00, $00, $07, $46, $08, $07, $e7, $03, $58, $02
	db $f4, $01, $90, $01, $ff, $00, $00, $00, $fa, $fa, $7f, $80, $8b, $ff, $1c, $00
	db $00, $00, $06, $3c, $00, $14, $00, $28, $00, $19, $00, $14, $00, $1e, $00, $fa
	db $32, $00, $fa, $44, $5c, $ff, $ff, $c4, $00, $00, $00, $07, $50, $00, $14, $00
	db $2d, $00, $23, $00, $0f, $00, $46, $00, $96, $96, $96, $c8, $41, $56, $8e, $ff
	db $4e, $04, $00, $01, $01, $0e, $00, $14, $00, $0c, $00, $04, $00, $0c, $00, $0e
	db $00, $c8, $00, $00, $c8, $33, $ff, $ff, $ff

;@ def CheckFieldItemUse()
;@ path: item/field
;@ Before an item is used outside battle: sets wItemId to $FF when it would have no effect,
;@ so it is not used up. Items $2B-$2D (heal one) need a living hurt target, $2E/$2F (heal
;@ all) a living hurt party member, $30/$31 (revive) a dead target, $33 a poisoned and $36 a
;@ paralyzed living target; $37 works once per world visit (wWorldFlags bit 0), $38 while a
;@ room of the floor map is still missing, $7E only on a gate floor. Any other item: $FF.
;@ test: skip reads the party records through helpers
CheckFieldItemUse::
;> if wItemId == 0xFF:
;>     return
	ld a, [wItemId]
	cp $ff
	ret z

;> if wItemId in (0x2B, 0x2C, 0x2D):
;>@h1     if not CheckItemTargetAlive() and GetPartyMonsterWord(wItemTarget, wMonHP) == GetPartyMonsterWord(wItemTarget, wMonMaxHP): wItemId = 0xFF
	cp $2b
	jp z, .healOne

	cp $2c
	jp z, .healOne

	cp $2d
	jp z, .healOne

;> elif wItemId in (0x2E, 0x2F):
;>@ha     if not any(not CheckMonAlive(s) and GetPartyMonsterWord(s, wMonHP) != GetPartyMonsterWord(s, wMonMaxHP) for s in range(wPartyCount)): wItemId = 0xFF
	cp $2e
	jp z, .healAll

	cp $2f
	jp z, .healAll

;> elif wItemId in (0x30, 0x31):
;>@rv     if not GetPartyMonsterByte(wItemTarget, wMonStatus) & 0x80: wItemId = 0xFF   # must be dead
	cp $30
	jp z, .revive

	cp $31
	jp z, .revive

;> elif wItemId == 0x33:
;>@po     if not CheckItemTargetAlive() and not GetPartyMonsterByte(wItemTarget, wMonStatus) & 0x04: wItemId = 0xFF
	cp $33
	jp z, .poison

;> elif wItemId == 0x36:
;>@pa     if not CheckItemTargetAlive() and not GetPartyMonsterByte(wItemTarget, wMonStatus) & 0x01: wItemId = 0xFF
	cp $36
	jp z, .paralysis

;> elif wItemId == 0x37:
;>@wf     if wWorldFlags & 0x01: wItemId = 0xFF
	cp $37
	jp z, .worldFlag

;> elif wItemId == 0x38:
;>@fm     if all(wFloorsSeen[r] for r in range(16)): wItemId = 0xFF
	cp $38
	jp z, .floorMap

;> elif wItemId == 0x7E:
;>@gf     if not wOnGateFloor: wItemId = 0xFF
	cp $7e
	jp z, .gateFloor

;> else:
;>     wItemId = 0xFF
	ld a, $ff
	ld [wItemId], a
	ret

.healOne
;=@h1
	call CheckItemTargetAlive
	ret nz

	ld a, [wItemTarget]
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
;=@h1
	push bc
	ld a, [wItemTarget]
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
;=@h1
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
;=@h1
	or l
	ret nz

	ld a, $ff
	ld [wItemId], a
	ret

.healAll
;=@ha
	ld a, [wPartyCount]
	or a
	jr z, .noneHurt

	ld a, $00
	call CheckMonAlive
	jr nz, .member1

;=@ha
	ld a, $00
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	push bc
	ld a, $00
	ld hl, wMonHP
;=@ha
	call GetPartyMonsterWord
	pop hl
	ld a, l
	sub c
	ld l, a
	ld a, h
;=@ha
	sbc b
	ld h, a
	ld a, h
	or l
	ret nz

	ld a, [wPartyCount]
;=@ha
	cp $01
	jr z, .noneHurt

.member1
;=@ha
	ld a, $01
	call CheckMonAlive
	jr nz, .member2

	ld a, $01
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
;=@ha
	push bc
	ld a, $01
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
;=@ha
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
;=@ha
	or l
	ret nz

	ld a, [wPartyCount]
	cp $02
	jr z, .noneHurt

.member2
;=@ha
	ld a, $02
	call CheckMonAlive
	jr nz, .noneHurt

	ld a, $02
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
;=@ha
	push bc
	ld a, $02
	ld hl, wMonHP
	call GetPartyMonsterWord
	pop hl
	ld a, l
;=@ha
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, h
;=@ha
	or l
	ret nz

.noneHurt
;=@ha
	ld a, $ff
	ld [wItemId], a
	ret

.revive
;=@rv
	ld a, [wItemTarget]
	ld hl, wMonStatus
	call GetPartyMonsterByte
	bit 7, a
	ret nz

	ld a, $ff
;=@rv
	ld [wItemId], a
	ret

.poison
;=@po
	call CheckItemTargetAlive
	ret nz

	ld a, [wItemTarget]
	ld hl, wMonStatus
	call GetPartyMonsterByte
	bit 2, a
;=@po
	ret nz

	ld a, $ff
	ld [wItemId], a
	ret

.paralysis
;=@pa
	call CheckItemTargetAlive
	ret nz

	ld a, [wItemTarget]
	ld hl, wMonStatus
	call GetPartyMonsterByte
	bit 0, a
;=@pa
	ret nz

	ld a, $ff
	ld [wItemId], a
	ret

.worldFlag
;=@wf
	ld a, [wWorldFlags]
	bit 0, a
	ret z

	ld a, $ff
	ld [wItemId], a
	ret

.floorMap
;=@fm
	ld b, $10
	ld hl, wFloorsSeen

.room
;=@fm
	ld a, [hli]
	ret z

	dec b
	jr nz, .room

	ld a, $ff
	ld [wItemId], a
;=@fm
	ret

.gateFloor
;=@gf
	ld a, [wOnGateFloor]
	or a
	ret nz

	ld a, $ff
	ld [wItemId], a
	ret


;@ def CheckItemTargetAlive() -> nz
;@ path: item/field
;@ CheckMonAlive for the item's target wItemTarget.
;@ test: skip reads the party records through helpers
CheckItemTargetAlive::
;> slot = wItemTarget                    # falls through
	ld a, [wItemTarget]

;@ def CheckMonAlive(slot: a) -> nz
;@ path: item/field
;@ Returns NZ (True) and sets wItemId to $FF when party member `slot` is dead (status bit 7),
;@ else Z.
;@ test: skip reads the party records through helpers
CheckMonAlive::
;> if not GetPartyMonsterByte(slot, wMonStatus) & 0x80:
;>     return False
	ld hl, wMonStatus
	call GetPartyMonsterByte
	bit 7, a
	ret z

;> wItemId = 0xFF
	ld a, $ff
	ld [wItemId], a
;> return True
	ret


;@ def UseFieldItem()
;@ path: item/field
;@ The effect of item wItemId used outside battle on wItemTarget (after CheckFieldItemUse):
;@ $2B heals 30-40 HP, $2C 75-90 HP, $2D all HP; $2E heals each living party member by
;@ 90-120 HP, $2F fully; $30 revives with half the HP (a 50% chance, else message $0E05),
;@ $31 with all HP; $33 cures poison, $36 paralysis; $37 sets wWorldFlags bit 0; $38 marks
;@ every room of the floor as seen; $7E starts a battle with a random encounter group.
;@ test: skip changes the party through helpers
UseFieldItem::
;> if wItemId == 0xFF:
;>     return
	ld a, [wItemId]
	cp $ff
	ret z

;> if wItemId == 0x2B:
;>@i1     HealPartyHP(wItemTarget, 30 + wRandomHigh % 11)
	cp $2b
	jp z, .heal30

;> elif wItemId == 0x2C:
;>@i2     HealPartyHP(wItemTarget, 75 + wRandomHigh % 16)
	cp $2c
	jp z, .heal75

;> elif wItemId == 0x2D:
;>@i3     SetPartyMonsterWord(wItemTarget, wMonHP, GetPartyMonsterWord(wItemTarget, wMonMaxHP))
	cp $2d
	jp z, .healFull

;> elif wItemId == 0x2E:
;>@i4     for s in range(3): wItemTarget = s; HealMonSomewhat(s)
	cp $2e
	jp z, .healAll

;> elif wItemId == 0x2F:
;>     UseItemFullHealParty()
	cp $2f
	jp z, UseItemFullHealParty

;> elif wItemId == 0x30:
;>     UseItemReviveHalf()
	cp $30
	jp z, UseItemReviveHalf

;> elif wItemId == 0x31:
;>     UseItemReviveFull()
	cp $31
	jp z, UseItemReviveFull

;> elif wItemId == 0x33:
;>     UseItemCurePoison()
	cp $33
	jp z, UseItemCurePoison

;> elif wItemId == 0x36:
;>     UseItemCureParalysis()
	cp $36
	jp z, UseItemCureParalysis

;> elif wItemId == 0x37:
;>     UseItemWorldFlag()
	cp $37
	jp z, UseItemWorldFlag

;> elif wItemId == 0x38:
;>     UseItemFloorMap()
	cp $38
	jp z, UseItemFloorMap

;> elif wItemId == 0x7E:
;>     UseItemStartBattle()
	cp $7e
	jp z, UseItemStartBattle

	ret

.heal30
;=@i1
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $0b
	call Divide8
	add $1e
;=@i1
	ld l, a
	ld h, $00
	ld a, [wItemTarget]
	call HealPartyHP
	ret

.heal75
;=@i2
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $10
	call Divide8
	add $4b
;=@i2
	ld l, a
	ld h, $00
	ld a, [wItemTarget]
	call HealPartyHP
	ret

.healFull
;=@i3
	ld a, [wItemTarget]
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	ld a, [wItemTarget]
	ld hl, wMonHP
	call SetPartyMonsterWord
;=@i3
	ret

.healAll
;=@i4
	ld a, $00
	ld [wItemTarget], a
	ld a, $00
	call HealMonSomewhat
	ld a, $01
	ld [wItemTarget], a
;=@i4
	ld a, $01
	call HealMonSomewhat
	ld a, $02
	ld [wItemTarget], a
	ld a, $02
	call HealMonSomewhat
;=@i4
	ret


;@ def HealMonSomewhat(slot: a)
;@ path: item/field
;@ Heals party member `slot` (also in wItemTarget) by 90-120 HP, unless it is dead.
;@ test: skip changes the party through helpers
HealMonSomewhat::
;> if GetPartyMonsterByte(slot, wMonStatus) & 0x80:
;>     return
	ld hl, wMonStatus
	call GetPartyMonsterByte
	bit 7, a
	ret nz

;> Random()
	call Random
;> amount = 90 + wRandomHigh % 31
	ld a, [wRandomHigh]
	ld b, a
	ld a, $1f
	call Divide8
	add $5a
;> HealPartyHP(wItemTarget, amount)
	ld l, a
	ld h, $00
	ld a, [wItemTarget]
	call HealPartyHP
	ret


;@ def UseItemFullHealParty()
;@ path: item/field
;@ Item $2F: every living party member gets all its HP back.
;@ test: skip changes the party through helpers
UseItemFullHealParty::
;>@slots for slot in range(3):
;>     if not CheckMonAlive(slot):
	ld a, $00
	call CheckMonAlive
	jr nz, .member1

;>         SetPartyMonsterWord(slot, wMonHP, GetPartyMonsterWord(slot, wMonMaxHP))
	ld a, $00
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	ld a, $00
	ld hl, wMonHP
	call SetPartyMonsterWord

.member1
;=@slots
	ld a, $01
	call CheckMonAlive
	jr nz, .member2

	ld a, $01
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
;=@slots
	ld a, $01
	ld hl, wMonHP
	call SetPartyMonsterWord

.member2
;=@slots
	ld a, $02
	call CheckMonAlive
	jr nz, .done

	ld a, $02
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
;=@slots
	ld a, $02
	ld hl, wMonHP
	call SetPartyMonsterWord

.done
	ret


;@ def UseItemReviveHalf()
;@ path: item/field
;@ Item $30: on an even random number the target comes back to life with half its HP;
;@ otherwise message $0E05 (it failed).
;@ test: skip changes the party through helpers
UseItemReviveHalf::
;> if wRandomHigh & 0x01:
;>@fail     return PrintSystemText(0x0E05)
	ld a, [wRandomHigh]
	bit 0, a
	jr nz, .failed

;> mem[PartyMonsterField(wItemTarget, wMonStatus)] = 0
	ld a, [wItemTarget]
	ld hl, wMonStatus
	call PartyMonsterField
	ld [hl], $00
;> hp = GetPartyMonsterWord(wItemTarget, wMonMaxHP) >> 1
	ld a, [wItemTarget]
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	srl b
	rr c
;> SetPartyMonsterWord(wItemTarget, wMonHP, hp)
	ld a, [wItemTarget]
	ld hl, wMonHP
	call SetPartyMonsterWord
	ret

.failed
;=@fail
	ld hl, $0e05
	call PrintSystemText
	ret


;@ def UseItemReviveFull()
;@ path: item/field
;@ Item $31: the target comes back to life with all its HP.
;@ test: skip changes the party through helpers
UseItemReviveFull::
;> mem[PartyMonsterField(wItemTarget, wMonStatus)] = 0
	ld a, [wItemTarget]
	ld hl, wMonStatus
	call PartyMonsterField
	ld [hl], $00
;> max_hp = GetPartyMonsterWord(wItemTarget, wMonMaxHP)
	ld a, [wItemTarget]
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
;> SetPartyMonsterWord(wItemTarget, wMonHP, max_hp)
	ld a, [wItemTarget]
	ld hl, wMonHP
	call SetPartyMonsterWord
	ret


;@ def UseItemCurePoison()
;@ path: item/field
;@ Item $33: clears the target's poison (status bit 2).
;@ test: skip changes the party through helpers
UseItemCurePoison::
;> mem[PartyMonsterField(wItemTarget, wMonStatus)] &= ~0x04
	ld a, [wItemTarget]
	ld hl, wMonStatus
	call PartyMonsterField
	res 2, [hl]
	ret


;@ def UseItemCureParalysis()
;@ path: item/field
;@ Item $36: clears the target's paralysis (status bit 0).
;@ test: skip changes the party through helpers
UseItemCureParalysis::
;> mem[PartyMonsterField(wItemTarget, wMonStatus)] &= ~0x01
	ld a, [wItemTarget]
	ld hl, wMonStatus
	call PartyMonsterField
	res 0, [hl]
	ret


;@ def UseItemWorldFlag()
;@ path: item/field
;@ Item $37: sets wWorldFlags bit 0 for the rest of the world visit.
UseItemWorldFlag::
;> wWorldFlags |= 0x01
	ld hl, wWorldFlags
	set 0, [hl]
	ret


;@ def UseItemFloorMap()
;@ path: item/field
;@ Item $38: marks all 16 rooms of the floor as seen, so the floor map shows them all.
UseItemFloorMap::
;> FillMemory(wFloorsSeen, 16, 1)
	ld hl, wFloorsSeen
	ld bc, $0010
	ld a, $01
	call FillMemory
	ret


;@ def UseItemStartBattle()
;@ path: item/field
;@ Item $7E: rolls an encounter group and starts the battle wipe (wFieldFlags bit 6).
;@ test: skip calls a routine in another bank
UseItemStartBattle::
;> RollEncounterGroup()
	ld hl, far_RollEncounterGroup
	rst $10
;> wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wBattleKind = 0
	ld a, $00
	ld [wBattleKind], a
;> wStatusViewVars[0] += 1
	ld hl, wStatusViewVars
	inc [hl]
	ret

	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00
