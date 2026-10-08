INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $016", ROMX[$4000], BANK[$16]

BankNumber_16::
	db $16

FarTable_16::
	dw Call_16_4015
	dw Call_16_485C
	dw Call_16_456E
	dw Call_16_45A3
	dw Call_16_474A
	dw Call_16_5B4E
	dw Call_16_5FE4
	dw Call_16_6DB0
	dw Call_16_6F05
	dw Call_16_7033

Call_16_4015::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_016_401c:
	ld a, [de]
	or a
	jr z, jr_016_402d

	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_016_401c

	ret


jr_016_402d:
	ld a, c
	ld [wCurPartyMember], a
	ld [wLeaderSlot], a
	ld hl, wMonsters
	call Call_16_41B1
	ld bc, $0095
	xor a
	call FillMemory
	ld hl, wMonSkills
	call Call_16_41B1
	ld bc, $0008
	ld a, $ff
	call FillMemory
	ld hl, wMonSkillList
	call Call_16_41B1
	ld bc, $0019
	ld a, $ff
	call FillMemory
	ld hl, wMonsters
	call Call_16_41B1
	ld [hl], $01
	ld a, [$d66e]
	ld [wBreedQuery], a
	ld a, [$d703]
	ld [wBreedSpecies2], a
	ld a, $14
	ld [wBreedSlot1], a
	ld a, $15
	ld [wBreedSlot2], a
	call Call_16_456E
	ld hl, wMonRecSpecies
	call Call_16_41B1
	ld a, [wBreedPair]
	ld [hl], a
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonSpecies]
	ld hl, wLibraryFlags
	call SetFlag
	ld hl, wMonFamily
	call Call_16_41B1
	ld a, [wMonStats]
	ld [hl], a
	ld a, [wOffspringPlus]
	push af
	ld hl, wMonPlus
	call Call_16_41B1
	pop af
	cp $63
	jr c, jr_016_40b3

	ld a, $63

jr_016_40b3:
	ld [hl], a
	ld hl, wMonPlus
	call Call_16_41B1
	ld a, [hl]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, [$da34]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, h
	or a
	jr nz, jr_016_40d7

	ld a, l
	cp $02
	jr nc, jr_016_40d3

	ld a, $02

jr_016_40d3:
	cp $63
	jr c, jr_016_40d9

jr_016_40d7:
	ld a, $63

jr_016_40d9:
	push af
	ld hl, wMonMaxLevel
	call Call_16_41B1
	pop af
	ld [hl], a
	ld hl, wMonLevel
	call Call_16_41B1
	ld [hl], $01
	ld hl, wMonMaxHP
	call Call_16_41B8
	push bc
	ld hl, wMonHP
	call Call_16_41B1
	pop bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ld hl, wMonMaxMP
	call Call_16_41B8
	push bc
	ld hl, wMonMP
	call Call_16_41B1
	pop bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ld hl, wMonAttack
	call Call_16_41B8
	ld hl, wMonDefense
	call Call_16_41B8
	ld hl, wMonAgility
	call Call_16_41B8
	ld hl, wMonIntelligence
	call Call_16_41B8
	ld hl, wMonStat64
	call Call_16_41FF
	ld hl, wMonStat65
	call Call_16_41FF
	ld hl, wMonStat67
	call Call_16_41FF
	ld hl, wMonStat66
	call Call_16_41FF
	ld hl, $cb29
	ld de, wMonResistances
	ld b, $1b
	call Call_16_4227
	call Call_16_4360
	call Random
	ld hl, $44cc
	ld a, [$da36]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wRandomHigh]
	cp [hl]
	jr z, jr_016_4169

	jr nc, jr_016_4169

	ld hl, wMonGender
	call Call_16_41B1
	ld [hl], $01

jr_016_4169:
	ld hl, wMonEgg
	call Call_16_41B1
	ld [hl], $01
	call Call_16_4238
	ld de, $da39
	ld b, $03
	call Call_16_4496
	ld a, [$d66e]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld de, $da39
	ld b, $03
	call Call_16_4496
	ld a, [$d703]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld de, $da39
	ld b, $03
	call Call_16_4496
	ld de, $d68e
	ld b, $08
	call Call_16_4496
	ld de, $d723
	ld b, $08
	call Call_16_4496
	ret


Call_16_41B1::
	ld a, [wCurPartyMember]
	call MonsterField
	ret


Call_16_41B8::
	push hl
	ld a, l
	add $a4
	ld l, a
	ld a, h
	adc $0b
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, l
	add $94
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	add c
	ld c, a
	ld a, [hl]
	adc b
	ld b, a
	srl b
	rr c
	srl b
	rr c
	pop hl
	push bc
	call Call_16_41B1
	pop bc
	push hl
	push bc
	push bc
	call Call_16_4313
	pop bc
	call Multiply24
	ld a, $32
	call Divide16
	pop bc
	add hl, bc
	ld c, l
	ld b, h
	ld a, c
	or b
	jr nz, jr_016_41fa

	ld bc, $0001

jr_016_41fa:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


Call_16_41FF::
	push hl
	ld a, l
	add $a4
	ld l, a
	ld a, h
	adc $0b
	ld h, a
	ld a, [hl]
	ld c, a
	ld b, $00
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
	ld a, $00
	add b
	ld b, a
	srl b
	rr c
	pop hl
	push bc
	call Call_16_41B1
	pop bc
	ld [hl], c
	ret


Call_16_4227::
	push bc
	push de
	ld a, [wCurPartyMember]
	call MonsterField
	pop de
	pop bc

jr_016_4231:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_016_4231

	ret


Call_16_4238::
	ld a, [$d670]
	and $01
	or a
	jp nz, Jump_016_42aa

	ld hl, wMonParent1
	call Call_16_41B1
	ld a, [$d66e]
	ld [hl], a
	ld hl, wMonParent1Master
	ld de, $d671
	ld b, $08
	call Call_16_4227
	ld hl, $cae0
	call Call_16_41B1
	ld a, [$ca4a]
	ld [hl], a
	ld hl, wMonParent1Name
	ld de, $d666
	ld b, $08
	call Call_16_4227
	ld hl, wMonParent1Plus
	call Call_16_41B1
	ld a, [$d6c7]
	ld [hl], a
	ld hl, wMonParent2
	call Call_16_41B1
	ld a, [$d703]
	ld [hl], a
	ld hl, wMonParent2Master
	ld de, $d706
	ld b, $08
	call Call_16_4227
	ld hl, $cae9
	call Call_16_41B1
	ld a, [$ca4a]
	ld [hl], a
	ld hl, wMonParent2Name
	ld de, $d6fb
	ld b, $08
	call Call_16_4227
	ld hl, wMonParent2Plus
	call Call_16_41B1
	ld a, [$d75c]
	ld [hl], a
	ret


Jump_016_42aa:
	ld hl, wMonParent1
	call Call_16_41B1
	ld a, [$d703]
	ld [hl], a
	ld hl, wMonParent1Master
	ld de, $d706
	ld b, $08
	call Call_16_4227
	ld hl, $cae0
	call Call_16_41B1
	ld a, [$ca4a]
	ld [hl], a
	ld hl, wMonParent1Name
	ld de, $d6fb
	ld b, $08
	call Call_16_4227
	ld hl, wMonParent1Plus
	call Call_16_41B1
	ld a, [$d75c]
	ld [hl], a
	ld hl, wMonParent2
	call Call_16_41B1
	ld a, [$d66e]
	ld [hl], a
	ld hl, wMonParent2Master
	ld de, $d671
	ld b, $08
	call Call_16_4227
	ld hl, $cae9
	call Call_16_41B1
	ld a, [$ca4a]
	ld [hl], a
	ld hl, wMonParent2Name
	ld de, $d666
	ld b, $08
	call Call_16_4227
	ld hl, wMonParent2Plus
	call Call_16_41B1
	ld a, [$d6c7]
	ld [hl], a
	ret


Call_16_4313::
	ld c, $00
	ld hl, $d671
	call Call_16_434F
	ld a, [$d67a]
	cp $ff
	ld hl, $d6e8
	call nz, Call_16_434F
	ld a, [$d67b]
	cp $ff
	ld hl, $d6f1
	call nz, Call_16_434F
	ld hl, $d706
	call Call_16_434F
	ld a, [$d70f]
	cp $ff
	ld hl, $d77d
	call nz, Call_16_434F
	ld a, [$d710]
	cp $ff
	ld hl, $d786
	call nz, Call_16_434F
	ld a, c
	ret


Call_16_434F::
	ld de, wPlayerName
	ld b, $09

jr_016_4354:
	ld a, [de]
	cp [hl]
	jr z, jr_016_435a

	inc c
	ret


jr_016_435a:
	inc de
	inc hl
	dec b
	jr nz, jr_016_4354

	ret


Call_16_4360::
	xor a
	ld [$da72], a
	ld b, $1b

jr_016_4366:
	push bc
	call Call_16_4373
	ld hl, $da72
	inc [hl]
	pop bc
	dec b
	jr nz, jr_016_4366

	ret


Call_16_4373::
	ld a, [$da72]
	ld hl, $cb29
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_16_41B1
	ld a, [hl]
	cp $03
	ret z

	cp $02
	jp z, Jump_016_43fc

	ld a, [$da72]
	ld hl, $d6cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld a, [$da72]
	ld hl, $d762
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	add [hl]
	and $07
	rst $00

JumpTable_16_43AA::
	dw Jump_16_43B8
	dw Jump_16_43B8
	dw Jump_16_43B8
	dw Jump_16_43B9
	dw Jump_16_43C6
	dw Jump_16_43D3
	dw Jump_16_43EC

Jump_16_43B8::
	ret


Jump_16_43B9::
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $64
	call Call_16_4444
	call c, Call_16_4481
	ret


Jump_16_43C6::
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $1e
	call Call_16_4444
	call c, Call_16_4481
	ret


Jump_16_43D3::
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $0a
	call Call_16_4444
	call c, Call_16_4481
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $1e
	call Call_16_4444
	call c, Call_16_4481
	ret


Jump_16_43EC::
	call Call_16_4481
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $14
	call Call_16_4444
	call c, Call_16_4481
	ret


Jump_016_43fc:
	ld a, [$da72]
	ld hl, $d6cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld a, [$da72]
	ld hl, $d762
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	add [hl]
	and $07
	rst $00

JumpTable_16_441B::
	dw Jump_16_4429
	dw Jump_16_4429
	dw Jump_16_4429
	dw Jump_16_4429
	dw Jump_16_4429
	dw Jump_16_442A
	dw Jump_16_4437

Jump_16_4429::
	ret


Jump_16_442A::
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $c8
	call Call_16_4444
	call c, Call_16_446C
	ret


Jump_16_4437::
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $28
	call Call_16_4444
	call c, Call_16_446C
	ret


Call_16_4444::
	push bc
	push af
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	pop af
	call Divide16
	pop bc
	cp b
	ret


	db $fa, $72, $da, $21, $29, $cb, $85, $6f, $3e, $00, $8c, $67, $cd, $b1, $41, $7e
	db $b7, $c8, $35, $c9

Call_16_446C::
	ld a, [$da72]
	ld hl, $cb29
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_16_41B1
	ld a, [hl]
	cp $03
	ret z

	inc [hl]
	ret


Call_16_4481::
	ld a, [$da72]
	ld hl, $cb29
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_16_41B1
	ld a, [hl]
	cp $02
	ret z

	inc [hl]
	ret


Call_16_4496::
	ld a, [de]
	inc de
	push bc
	push de
	call Call_16_44A3
	pop de
	pop bc
	dec b
	jr nz, Call_16_4496

	ret


Call_16_44A3::
	cp $ff
	ret z

	ld hl, $4874
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
	call Call_16_41B1
	pop af
	ld b, $19
	ld c, a

jr_016_44be:
	ld a, [hl]
	cp c
	ret z

	cp $ff
	jr nz, jr_016_44c7

	ld [hl], c
	ret


jr_016_44c7:
	inc hl
	dec b
	jr nz, jr_016_44be

	ret


	db $00, $1a, $80, $d6

Call_16_44D0::
	ld a, [wLinkActive]
	or a
	ret nz

	xor a
	ld [$d9e6], a
	ret


	db $fa, $71, $da, $fe, $ff, $28, $2e, $cd, $d0, $12, $fa, $99, $c8, $fe, $03, $d0
	db $06, $c8, $16, $d7, $cd, $3d, $45, $fa, $9a, $c8, $47, $79, $b7, $c8, $cd, $fb
	db $1d, $06, $c8, $16, $d7, $5f, $cd, $53, $45, $78, $ea, $71, $da, $21, $e6, $d9
	db $34, $fe, $ff, $c8, $c9, $cd, $d0, $12, $fa, $99, $c8, $fe, $0e, $d0, $06, $00
	db $16, $c8, $cd, $3d, $45, $fa, $9a, $c8, $47, $79, $b7, $c8, $cd, $fb, $1d, $06
	db $00, $16, $c8, $5f, $cd, $53, $45, $78, $ea, $71, $da, $fe, $ff, $c8, $21, $e6
	db $d9, $34, $c9, $0e, $00, $c5, $d5, $21, $94, $ca, $78, $cd, $7e, $26, $d1, $c1
	db $28, $01, $0c, $04, $78, $ba, $20, $ed, $c9, $0e, $00, $c5, $d5, $21, $94, $ca
	db $78, $cd, $7e, $26, $d1, $c1, $28, $04, $79, $bb, $c8, $0c, $04, $78, $ba, $20
	db $ea, $06, $ff, $c9

Call_16_456E::
	ld a, $ff
	ld [wBreedPair], a
	ld a, $ff
	ld [$da72], a
	ld a, $ff
	ld [$da73], a
	ld a, $ff
	ld [$da74], a
	ld a, $ff
	ld [wOffspringPlus], a
	call Call_16_4653
	ld a, [wBreedPair]
	cp $ff
	ret nz

	call Call_16_45D5
	call Call_16_44D0
	ld a, [wBreedPair]
	cp $ff
	ret nz

	ld a, [wBreedQuery]
	ld [wBreedPair], a
	ret


Call_16_45A3::
	ld a, $ff
	ld [wBreedPair], a
	ld a, $ff
	ld [$da72], a
	ld a, $ff
	ld [$da73], a
	ld a, $ff
	ld [$da74], a
	ld a, $ff
	ld [wOffspringPlus], a
	call Call_16_4653
	ld a, [wBreedPair]
	cp $ff
	ret nz

	call Call_16_45D5
	ld a, [wBreedPair]
	cp $ff
	ret nz

	ld a, [wBreedQuery]
	ld [wBreedPair], a
	ret


Call_16_45D5::
	ld a, [wBreedSpecies2]
	cp $f0
	jr nc, Call_16_45FF

	ld a, [wBreedQuery]
	push af
	call Call_16_45FF
	pop af
	ld [wBreedQuery], a
	ld a, [wBreedPair]
	cp $ff
	ret nz

	ld a, [wBreedSpecies2]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	add $f0
	ld [wBreedSpecies2], a

Call_16_45FF::
	ld a, [wBreedQuery]
	cp $f0
	jr nc, jr_016_4615

	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	add $f0
	ld [$da72], a

jr_016_4615:
	ld hl, $4974
	ld d, $ff

jr_016_461a:
	inc d
	ld b, [hl]
	inc hl
	ld c, [hl]
	inc hl
	ld a, b
	or c
	ret z

	ld a, b
	and c
	cp $ff
	jr z, jr_016_461a

	ld a, [wBreedSpecies2]
	and $f0
	cp $f0
	jr nz, jr_016_4636

	ld a, c
	cp $fa
	jr z, jr_016_463c

jr_016_4636:
	ld a, [wBreedSpecies2]
	cp c
	jr nz, jr_016_461a

jr_016_463c:
	ld a, [wBreedQuery]
	cp b
	jr z, jr_016_464e

	ld a, [$da72]
	cp b
	jr nz, jr_016_464c

	ld a, d
	ld [wBreedPair], a

jr_016_464c:
	jr jr_016_461a

jr_016_464e:
	ld a, d
	ld [wBreedPair], a
	ret


Call_16_4653::
	ld a, [wBreedSlot1]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_016_467d

	ld a, [wBreedSlot1]
	ld hl, wMonPlus
	call MonsterField
	ld b, [hl]
	push bc
	ld a, [wBreedSlot2]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	pop bc
	cp b
	jr nc, jr_016_467e

jr_016_467d:
	ld a, b

jr_016_467e:
	inc a
	ld [wOffspringPlus], a
	ld a, [wBreedSlot1]
	ld hl, wMonLevel
	call MonsterField
	ld b, [hl]
	push bc
	ld a, [wBreedSlot2]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	pop bc
	add b
	ld c, $04
	cp $64
	jr nc, jr_016_46b3

	ld c, $03
	cp $4c
	jr nc, jr_016_46b3

	ld c, $02
	cp $3c
	jr nc, jr_016_46b3

	ld c, $01
	cp $28
	jr nc, jr_016_46b3

	ld c, $00

jr_016_46b3:
	ld a, [wOffspringPlus]
	add c
	ld [wOffspringPlus], a
	ld a, [wOffspringPlus]
	cp $63
	jr c, jr_016_46c6

	ld a, $63
	ld [wOffspringPlus], a

jr_016_46c6:
	ld a, [wBreedQuery]
	cp $f0
	jr nc, jr_016_46dc

	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	add $f0
	ld [$da73], a

jr_016_46dc:
	ld a, [wBreedSpecies2]
	cp $f0
	jr nc, jr_016_46f2

	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	add $f0
	ld [$da74], a

jr_016_46f2:
	ld hl, $4b30

jr_016_46f5:
	ld a, [hl]
	cp $ff
	jr z, jr_016_4710

	push hl
	call Call_16_471C
	pop hl
	ld a, [wBreedPair]
	cp $ff
	jr nz, jr_016_4710

	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_016_46f5

jr_016_4710:
	ld a, [wOffspringPlus]
	cp $63
	ret c

	ld a, $63
	ld [wOffspringPlus], a
	ret


Call_16_471C::
	ld a, [wBreedQuery]
	cp [hl]
	jr z, jr_016_4728

	ld a, [$da73]
	cp [hl]
	jr nz, jr_016_4749

jr_016_4728:
	inc hl
	ld a, [wBreedSpecies2]
	cp [hl]
	jr z, jr_016_4735

	ld a, [$da74]
	cp [hl]
	jr nz, jr_016_4749

jr_016_4735:
	inc hl
	ld a, [wOffspringPlus]
	cp [hl]
	jr c, jr_016_4749

	inc hl
	ld a, [hl]
	ld [wBreedPair], a
	inc hl
	ld a, [wOffspringPlus]
	add [hl]
	ld [wOffspringPlus], a

jr_016_4749:
	ret


Call_16_474A::
	ld hl, wMonWildness
	call Call_16_47E0
	xor a
	ld [hli], a
	ld [hl], a
	ld hl, wMonMaster
	ld de, wPlayerName
	ld b, $08
	call Call_16_47E7
	ld hl, $cad5
	call Call_16_47E0
	ld a, [$ca4a]
	ld [hl], a
	ld hl, wSceneObjects
	ld bc, $0019
	ld a, $ff
	call FillMemory
	ld hl, wMonRecSpecies
	call Call_16_47E0
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld de, $da39
	ld b, $03
	call Call_16_47F8
	ld hl, wMonParent1
	call Call_16_47E0
	ld a, [hl]
	cp $ff
	jr z, jr_016_47b9

	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld de, $da39
	ld b, $03
	call Call_16_47F8
	ld hl, wMonParent2
	call Call_16_47E0
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld de, $da39
	ld b, $03
	call Call_16_47F8

jr_016_47b9:
	ld hl, wMonSkillList
	call Call_16_47E0
	ld e, l
	ld d, h
	ld b, $19
	call Call_16_4805
	ld hl, wMonSkillList
	call Call_16_47E0
	ld de, wSceneObjects
	ld b, $19

jr_016_47d1:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_016_47d1

	ld hl, wMonEgg
	call Call_16_47E0
	ld [hl], $00
	ret


Call_16_47E0::
	ld a, [wCurPartyMember]
	call MonsterField
	ret


Call_16_47E7::
	push bc
	push de
	ld a, [wCurPartyMember]
	call MonsterField
	pop de
	pop bc

jr_016_47f1:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_016_47f1

	ret


Call_16_47F8::
	ld a, [de]
	inc de
	push bc
	push de
	call Call_16_4838
	pop de
	pop bc
	dec b
	jr nz, Call_16_47F8

	ret


Call_16_4805::
	push bc
	push de
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $64
	call Divide16
	ld b, a
	push bc
	ld hl, wMonPlus
	call Call_16_47E0
	pop bc
	ld a, [hl]
	cp b
	pop de
	pop bc
	jr jr_016_482b

	db $13, $05, $20, $db, $c9

jr_016_482b:
	ld a, [de]
	inc de
	push bc
	push de
	call Call_16_4838
	pop de
	pop bc
	dec b
	jr nz, Call_16_4805

	ret


Call_16_4838::
	cp $ff
	ret z

	ld hl, $4874
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	ld hl, wSceneObjects
	ld b, $19
	ld c, a

jr_016_484e:
	ld a, [hl]
	cp c
	ret z

	cp $ff
	jr nz, jr_016_4857

	ld [hl], c
	ret


jr_016_4857:
	inc hl
	dec b
	jr nz, jr_016_484e

	ret


Call_16_485C::
	ld a, [wBreedQuery]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $74
	ld l, a
	ld a, h
	adc $49
	ld h, a
	ld a, [hli]
	ld [wBreedPair], a
	ld a, [hl]
	ld [$da72], a
	ret


	db $00, $00, $00, $03, $03, $03, $06, $06, $06, $09, $09, $09, $0c, $0c, $0c, $0f
	db $0f, $0f, $12, $12, $14, $15, $15, $17, $18, $19, $1a, $1a, $1c, $1c, $1e, $1e
	db $20, $20, $22, $22, $24, $25, $26, $27, $27, $29, $2a, $2b, $2b, $2b, $2e, $2e
	db $30, $30, $32, $33, $34, $35, $36, $37, $38, $39, $ff, $3b, $3c, $3d, $3e, $3f
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
	db $50, $50, $52, $52, $54, $55, $56, $57, $58, $58, $5a, $5b, $5c, $5c, $5c, $5c
	db $60, $60, $60, $60, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6c, $6e, $6f
	db $70, $71, $72, $73, $74, $75, $75, $77, $78, $79, $79, $7b, $7b, $7d, $7e, $7f
	db $80, $81, $82, $83, $84, $84, $84, $84, $88, $88, $8a, $8a, $8c, $ff, $8e, $8f
	db $90, $91, $92, $93, $94, $95, $96, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $d5, $d6, $d7, $d8, $d9, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $f0, $f1, $f0, $f2, $f0, $f3, $f0, $f4, $f0, $f5, $f0, $f6, $f0, $f7, $f0, $f8
	db $ff, $ff, $f0, $5a, $f0, $2e, $f0, $c6, $f0, $bd, $f0, $33, $ff, $ff, $f0, $f9
	db $f0, $b9, $10, $10, $11, $11, $12, $12, $f1, $f0, $f1, $f2, $f1, $f3, $f1, $f4
	db $f1, $f5, $f1, $f6, $f1, $f7, $f1, $f8, $14, $14, $f1, $46, $f1, $32, $f1, $53
	db $f1, $b8, $f1, $77, $f1, $5f, $f1, $06, $f1, $7d, $ff, $ff, $f1, $4f, $26, $26
	db $27, $27, $22, $8c, $f1, $8d, $f1, $55, $2b, $29, $f2, $f0, $f2, $f1, $f2, $f3
	db $f2, $f4, $f2, $f5, $ff, $ff, $f2, $f7, $f2, $f8, $ff, $ff, $f2, $a4, $f2, $15
	db $f2, $4a, $f2, $62, $f2, $f6, $f2, $8f, $f2, $bb, $f2, $21, $f2, $0a, $f2, $00
	db $f2, $4b, $40, $40, $41, $41, $f2, $f9, $f2, $1c, $f2, $87, $f3, $f0, $f3, $f1
	db $f3, $f2, $f3, $f4, $f3, $f5, $f3, $f6, $f3, $f7, $f3, $f8, $ff, $ff, $ff, $ff
	db $f3, $0b, $ff, $ff, $f3, $7c, $f3, $b2, $f3, $c1, $f3, $bf, $f3, $f9, $f3, $1f
	db $f3, $64, $54, $55, $f4, $f0, $f4, $f1, $f4, $f2, $f4, $f3, $f4, $f5, $f4, $f6
	db $f4, $f7, $f4, $f8, $ff, $ff, $f4, $70, $f4, $b3, $f4, $82, $f4, $a5, $f4, $58
	db $f4, $30, $f4, $86, $69, $69, $6a, $6a, $f4, $f9, $ff, $ff, $f5, $f0, $f5, $f1
	db $f5, $f2, $f5, $f3, $f5, $f4, $f5, $f6, $f5, $f7, $f5, $f8, $ff, $ff, $ff, $ff
	db $f5, $5c, $f5, $37, $f5, $61, $f5, $31, $f5, $9b, $f5, $a0, $f5, $3d, $75, $75
	db $7f, $7f, $f5, $f9, $f6, $f0, $f6, $f9, $ff, $ff, $f6, $f3, $f6, $f4, $f6, $f5
	db $f6, $f7, $f6, $f8, $ff, $ff, $f6, $f2, $f6, $f1, $f6, $19, $f6, $43, $f6, $68
	db $f6, $39, $85, $85, $8a, $8a, $f6, $1e, $93, $93, $f6, $b6, $f6, $45, $ff, $ff
	db $f6, $79, $94, $59, $97, $c7, $f7, $f0, $f7, $1b, $f7, $f2, $f7, $f3, $f7, $f4
	db $f7, $f5, $f7, $f6, $f7, $f8, $ff, $ff, $f7, $6e, $f7, $4d, $f7, $f1, $f7, $34
	db $f7, $72, $a1, $a1, $f7, $f9, $a3, $a3, $ab, $ab, $ac, $ac, $ff, $ff, $f8, $f0
	db $f8, $f1, $f8, $f2, $f8, $f3, $f8, $f4, $f8, $f5, $f8, $f6, $f8, $f7, $ff, $ff
	db $f8, $74, $f8, $22, $f8, $f9, $f8, $73, $f8, $5d, $f8, $88, $f8, $04, $b7, $5b
	db $b9, $83, $bd, $42, $f8, $07, $b7, $b7, $c3, $c3, $c4, $c4, $b4, $b4, $c1, $c0
	db $ad, $25, $c8, $2c, $aa, $12, $99, $6c, $ca, $29, $c8, $cb, $9a, $2c, $ce, $42
	db $cf, $13, $d0, $24, $cc, $43, $cd, $d0, $d3, $80, $d4, $d2, $d5, $6d, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $1b, $00, $0c
	db $00, $00, $24, $00, $0c, $00, $00, $25, $00, $0c, $00, $00, $2a, $00, $0c, $00
	db $00, $2b, $00, $0c, $00, $05, $1b, $00, $0c, $00, $05, $24, $00, $0c, $00, $05
	db $25, $00, $0c, $00, $05, $2a, $00, $0c, $00, $05, $2b, $00, $0c, $00, $0b, $1b
	db $00, $0c, $00, $0b, $24, $00, $0c, $00, $0b, $25, $00, $0c, $00, $0b, $2a, $00
	db $0c, $00, $0b, $2b, $00, $0c, $00, $11, $1b, $00, $0c, $00, $11, $24, $00, $0c
	db $00, $11, $25, $00, $0c, $00, $11, $2a, $00, $0c, $00, $11, $2b, $00, $0c, $00
	db $0f, $25, $00, $0e, $00, $0f, $2a, $00, $0e, $00, $0f, $2c, $00, $0e, $00, $0f
	db $3e, $00, $0e, $00, $0f, $42, $00, $0e, $00, $0f, $53, $00, $0e, $00, $0f, $56
	db $00, $0e, $00, $0f, $57, $00, $0e, $00, $0f, $96, $00, $0e, $00, $0f, $97, $00
	db $0e, $00, $0f, $a9, $00, $0e, $00, $0f, $aa, $00, $0e, $00, $12, $25, $00, $0e
	db $00, $12, $2a, $00, $0e, $00, $12, $2c, $00, $0e, $00, $12, $3e, $00, $0e, $00
	db $12, $42, $00, $0e, $00, $12, $53, $00, $0e, $00, $12, $56, $00, $0e, $00, $12
	db $57, $00, $0e, $00, $12, $96, $00, $0e, $00, $12, $97, $00, $0e, $00, $12, $a9
	db $00, $0e, $00, $12, $aa, $00, $0e, $00, $0e, $25, $00, $0f, $00, $0e, $2a, $00
	db $0f, $00, $0e, $2c, $00, $0f, $00, $0e, $3e, $00, $0f, $00, $0e, $42, $00, $0f
	db $00, $0e, $53, $00, $0f, $00, $0e, $56, $00, $0f, $00, $0e, $57, $00, $0f, $00
	db $0e, $96, $00, $0f, $00, $0e, $97, $00, $0f, $00, $0e, $a9, $00, $0f, $00, $0e
	db $aa, $00, $0f, $00, $08, $08, $05, $0f, $00, $01, $01, $05, $0e, $00, $0e, $c7
	db $00, $13, $00, $0f, $c7, $00, $13, $00, $12, $c7, $00, $13, $00, $0e, $b9, $00
	db $12, $00, $0f, $b9, $00, $12, $00, $14, $14, $04, $25, $00, $14, $14, $00, $1c
	db $00, $1c, $1c, $04, $25, $00, $17, $3f, $00, $22, $00, $17, $41, $00, $22, $00
	db $17, $53, $00, $22, $00, $17, $57, $00, $22, $00, $17, $58, $00, $22, $00, $17
	db $83, $00, $22, $00, $17, $8d, $00, $22, $00, $17, $8e, $00, $22, $00, $17, $90
	db $00, $22, $00, $17, $94, $00, $22, $00, $17, $a9, $00, $22, $00, $17, $c4, $00
	db $22, $00, $1e, $3f, $00, $22, $00, $1e, $41, $00, $22, $00, $1e, $53, $00, $22
	db $00, $1e, $57, $00, $22, $00, $1e, $58, $00, $22, $00, $1e, $83, $00, $22, $00
	db $1e, $8d, $00, $22, $00, $1e, $8e, $00, $22, $00, $1e, $90, $00, $22, $00, $1e
	db $94, $00, $22, $00, $1e, $a9, $00, $22, $00, $1e, $c4, $00, $22, $00, $2a, $3f
	db $00, $22, $00, $2a, $41, $00, $22, $00, $2a, $53, $00, $22, $00, $2a, $57, $00
	db $22, $00, $2a, $58, $00, $22, $00, $2a, $83, $00, $22, $00, $2a, $8d, $00, $22
	db $00, $2a, $8e, $00, $22, $00, $2a, $90, $00, $22, $00, $2a, $94, $00, $22, $00
	db $2a, $a9, $00, $22, $00, $2a, $c4, $00, $22, $00, $2b, $3f, $00, $22, $00, $2b
	db $41, $00, $22, $00, $2b, $53, $00, $22, $00, $2b, $57, $00, $22, $00, $2b, $58
	db $00, $22, $00, $2b, $83, $00, $22, $00, $2b, $8d, $00, $22, $00, $2b, $8e, $00
	db $22, $00, $2b, $90, $00, $22, $00, $2b, $94, $00, $22, $00, $2b, $a9, $00, $22
	db $00, $2b, $c4, $00, $22, $00, $19, $02, $00, $1f, $00, $19, $41, $00, $1f, $00
	db $19, $44, $00, $1f, $00, $19, $66, $00, $1f, $00, $19, $8d, $00, $1f, $00, $19
	db $8e, $00, $1f, $00, $19, $91, $00, $1f, $00, $19, $96, $00, $1f, $00, $16, $43
	db $00, $28, $00, $16, $95, $00, $28, $00, $16, $ae, $00, $28, $00, $16, $c5, $00
	db $28, $00, $17, $43, $00, $28, $00, $17, $95, $00, $28, $00, $17, $ae, $00, $28
	db $00, $17, $c5, $00, $28, $00, $19, $43, $00, $28, $00, $19, $95, $00, $28, $00
	db $19, $ae, $00, $28, $00, $19, $c5, $00, $28, $00, $2a, $43, $00, $28, $00, $2a
	db $95, $00, $28, $00, $2a, $ae, $00, $28, $00, $2a, $c5, $00, $28, $00, $2b, $43
	db $00, $28, $00, $2b, $95, $00, $28, $00, $2b, $ae, $00, $28, $00, $2b, $c5, $00
	db $28, $00, $22, $0c, $00, $b9, $00, $22, $0f, $00, $b9, $00, $22, $81, $00, $b9
	db $00, $22, $9c, $00, $b9, $00, $22, $bd, $00, $b9, $00, $22, $c4, $00, $b9, $00
	db $22, $c5, $00, $b9, $00, $24, $0c, $00, $b9, $00, $24, $0f, $00, $b9, $00, $24
	db $81, $00, $b9, $00, $24, $9c, $00, $b9, $00, $24, $bd, $00, $b9, $00, $24, $c4
	db $00, $b9, $00, $24, $c5, $00, $b9, $00, $25, $0c, $00, $b9, $00, $25, $0f, $00
	db $b9, $00, $25, $81, $00, $b9, $00, $25, $9c, $00, $b9, $00, $25, $bd, $00, $b9
	db $00, $25, $c4, $00, $b9, $00, $25, $c5, $00, $b9, $00, $22, $8c, $00, $29, $00
	db $25, $8c, $00, $29, $00, $37, $16, $00, $3b, $00, $37, $17, $00, $3b, $00, $37
	db $1b, $00, $3b, $00, $37, $1e, $00, $3b, $00, $37, $2a, $00, $3b, $00, $37, $2b
	db $00, $3b, $00, $3f, $16, $00, $3b, $00, $3f, $17, $00, $3b, $00, $3f, $1b, $00
	db $3b, $00, $3f, $1e, $00, $3b, $00, $3f, $2a, $00, $3b, $00, $3f, $2b, $00, $3b
	db $00, $40, $16, $00, $3b, $00, $40, $17, $00, $3b, $00, $40, $1b, $00, $3b, $00
	db $40, $1e, $00, $3b, $00, $40, $2a, $00, $3b, $00, $40, $2b, $00, $3b, $00, $44
	db $16, $00, $3b, $00, $44, $17, $00, $3b, $00, $44, $1b, $00, $3b, $00, $44, $1e
	db $00, $3b, $00, $44, $2a, $00, $3b, $00, $44, $2b, $00, $3b, $00, $2d, $03, $00
	db $36, $00, $2d, $0a, $00, $36, $00, $2d, $1e, $00, $36, $00, $2d, $58, $00, $36
	db $00, $2d, $5a, $00, $36, $00, $2d, $66, $00, $36, $00, $2d, $74, $00, $36, $00
	db $2d, $85, $00, $36, $00, $2d, $8b, $00, $36, $00, $2d, $ae, $00, $36, $00, $2d
	db $af, $00, $36, $00, $2d, $c2, $00, $36, $00, $32, $03, $00, $36, $00, $32, $0a
	db $00, $36, $00, $32, $1e, $00, $36, $00, $32, $58, $00, $36, $00, $32, $5a, $00
	db $36, $00, $32, $66, $00, $36, $00, $32, $74, $00, $36, $00, $32, $85, $00, $36
	db $00, $32, $8b, $00, $36, $00, $32, $ae, $00, $36, $00, $32, $af, $00, $36, $00
	db $32, $c2, $00, $36, $00, $2d, $51, $00, $41, $00, $2d, $53, $00, $41, $00, $2d
	db $56, $00, $41, $00, $2d, $57, $00, $41, $00, $32, $51, $00, $41, $00, $32, $53
	db $00, $41, $00, $32, $56, $00, $41, $00, $32, $57, $00, $41, $00, $3a, $51, $00
	db $41, $00, $3a, $53, $00, $41, $00, $3a, $56, $00, $41, $00, $3a, $57, $00, $41
	db $00, $3b, $51, $00, $41, $00, $3b, $53, $00, $41, $00, $3b, $56, $00, $41, $00
	db $3b, $57, $00, $41, $00, $2d, $81, $00, $32, $00, $2d, $9c, $00, $32, $00, $2d
	db $a9, $00, $32, $00, $2d, $aa, $00, $32, $00, $2d, $ac, $00, $32, $00, $3a, $81
	db $00, $32, $00, $3a, $9c, $00, $32, $00, $3a, $a9, $00, $32, $00, $3a, $aa, $00
	db $32, $00, $3a, $ac, $00, $32, $00, $3b, $81, $00, $32, $00, $3b, $9c, $00, $32
	db $00, $3b, $a9, $00, $32, $00, $3b, $aa, $00, $32, $00, $3b, $ac, $00, $32, $00
	db $3e, $81, $00, $32, $00, $3e, $9c, $00, $32, $00, $3e, $a9, $00, $32, $00, $3e
	db $aa, $00, $32, $00, $3e, $ac, $00, $32, $00, $40, $81, $00, $32, $00, $40, $9c
	db $00, $32, $00, $40, $a9, $00, $32, $00, $40, $aa, $00, $32, $00, $40, $ac, $00
	db $32, $00, $41, $81, $00, $32, $00, $41, $9c, $00, $32, $00, $41, $a9, $00, $32
	db $00, $41, $aa, $00, $32, $00, $41, $ac, $00, $32, $00, $37, $b9, $00, $32, $00
	db $37, $bd, $00, $32, $00, $37, $c0, $00, $32, $00, $37, $c1, $00, $32, $00, $37
	db $c4, $00, $32, $00, $37, $c5, $00, $32, $00, $3a, $b9, $00, $32, $00, $3a, $bd
	db $00, $32, $00, $3a, $c0, $00, $32, $00, $3a, $c1, $00, $32, $00, $3a, $c4, $00
	db $32, $00, $3a, $c5, $00, $32, $00, $3b, $b9, $00, $32, $00, $3b, $bd, $00, $32
	db $00, $3b, $c0, $00, $32, $00, $3b, $c1, $00, $32, $00, $3b, $c4, $00, $32, $00
	db $3b, $c5, $00, $32, $00, $3e, $b9, $00, $32, $00, $3e, $bd, $00, $32, $00, $3e
	db $c0, $00, $32, $00, $3e, $c1, $00, $32, $00, $3e, $c4, $00, $32, $00, $3e, $c5
	db $00, $32, $00, $3f, $b9, $00, $32, $00, $3f, $bd, $00, $32, $00, $3f, $c0, $00
	db $32, $00, $3f, $c1, $00, $32, $00, $3f, $c4, $00, $32, $00, $3f, $c5, $00, $32
	db $00, $40, $b9, $00, $32, $00, $40, $bd, $00, $32, $00, $40, $c0, $00, $32, $00
	db $40, $c1, $00, $32, $00, $40, $c4, $00, $32, $00, $40, $c5, $00, $32, $00, $32
	db $b9, $00, $41, $00, $32, $ba, $00, $41, $00, $32, $bd, $00, $41, $00, $32, $c0
	db $00, $41, $00, $32, $c1, $00, $41, $00, $32, $c4, $00, $41, $00, $32, $c5, $00
	db $41, $00, $41, $b9, $00, $42, $00, $41, $ba, $00, $42, $00, $41, $c7, $00, $42
	db $00, $51, $0b, $00, $57, $00, $51, $0c, $00, $57, $00, $51, $81, $00, $57, $00
	db $51, $b9, $00, $57, $00, $51, $c4, $00, $57, $00, $51, $c5, $00, $57, $00, $52
	db $0b, $00, $57, $00, $52, $0c, $00, $57, $00, $52, $81, $00, $57, $00, $52, $b9
	db $00, $57, $00, $52, $c4, $00, $57, $00, $52, $c5, $00, $57, $00, $53, $0b, $00
	db $57, $00, $53, $0c, $00, $57, $00, $53, $81, $00, $57, $00, $53, $b9, $00, $57
	db $00, $53, $c4, $00, $57, $00, $53, $c5, $00, $57, $00, $54, $0b, $00, $57, $00
	db $54, $0c, $00, $57, $00, $54, $81, $00, $57, $00, $54, $b9, $00, $57, $00, $54
	db $c4, $00, $57, $00, $54, $c5, $00, $57, $00, $56, $0b, $00, $57, $00, $56, $0c
	db $00, $57, $00, $56, $81, $00, $57, $00, $56, $b9, $00, $57, $00, $56, $c4, $00
	db $57, $00, $56, $c5, $00, $57, $00, $53, $bf, $00, $56, $00, $55, $bf, $00, $56
	db $00, $57, $bf, $00, $56, $00, $71, $71, $00, $7c, $00, $71, $78, $00, $7c, $00
	db $71, $7a, $00, $7c, $00, $78, $71, $00, $7c, $00, $78, $78, $00, $7c, $00, $78
	db $7a, $00, $7c, $00, $7a, $71, $00, $7c, $00, $7a, $78, $00, $7c, $00, $7a, $7a
	db $00, $7c, $00, $84, $0e, $00, $83, $00, $84, $0f, $00, $83, $00, $84, $12, $00
	db $83, $00, $84, $22, $00, $83, $00, $84, $25, $00, $83, $00, $84, $29, $00, $83
	db $00, $84, $41, $00, $83, $00, $84, $42, $00, $83, $00, $84, $56, $00, $83, $00
	db $84, $57, $00, $83, $00, $84, $b9, $00, $83, $00, $84, $c5, $00, $83, $00, $93
	db $0e, $00, $83, $00, $93, $0f, $00, $83, $00, $93, $12, $00, $83, $00, $93, $22
	db $00, $83, $00, $93, $25, $00, $83, $00, $93, $29, $00, $83, $00, $93, $41, $00
	db $83, $00, $93, $42, $00, $83, $00, $93, $56, $00, $83, $00, $93, $57, $00, $83
	db $00, $93, $b9, $00, $83, $00, $93, $c5, $00, $83, $00, $96, $0e, $00, $83, $00
	db $96, $0f, $00, $83, $00, $96, $12, $00, $83, $00, $96, $22, $00, $83, $00, $96
	db $25, $00, $83, $00, $96, $29, $00, $83, $00, $96, $41, $00, $83, $00, $96, $42
	db $00, $83, $00, $96, $56, $00, $83, $00, $96, $57, $00, $83, $00, $96, $b9, $00
	db $83, $00, $96, $c5, $00, $83, $00, $84, $0c, $00, $91, $00, $84, $1b, $00, $91
	db $00, $84, $28, $00, $91, $00, $84, $4d, $00, $91, $00, $84, $53, $00, $91, $00
	db $84, $6c, $00, $91, $00, $84, $7b, $00, $91, $00, $84, $9c, $00, $91, $00, $84
	db $a9, $00, $91, $00, $84, $aa, $00, $91, $00, $93, $0c, $00, $91, $00, $93, $1b
	db $00, $91, $00, $93, $28, $00, $91, $00, $93, $4d, $00, $91, $00, $93, $53, $00
	db $91, $00, $93, $6c, $00, $91, $00, $93, $7b, $00, $91, $00, $93, $9c, $00, $91
	db $00, $93, $a9, $00, $91, $00, $93, $aa, $00, $91, $00, $96, $0c, $00, $91, $00
	db $96, $1b, $00, $91, $00, $96, $28, $00, $91, $00, $96, $4d, $00, $91, $00, $96
	db $53, $00, $91, $00, $96, $6c, $00, $91, $00, $96, $7b, $00, $91, $00, $96, $9c
	db $00, $91, $00, $96, $a9, $00, $91, $00, $96, $aa, $00, $91, $00, $84, $32, $00
	db $90, $00, $84, $3e, $00, $90, $00, $84, $81, $00, $90, $00, $84, $bd, $00, $90
	db $00, $93, $32, $00, $90, $00, $93, $3e, $00, $90, $00, $93, $81, $00, $90, $00
	db $93, $bd, $00, $90, $00, $96, $32, $00, $90, $00, $96, $3e, $00, $90, $00, $96
	db $81, $00, $90, $00, $96, $bd, $00, $90, $00, $83, $91, $00, $94, $00, $9f, $0b
	db $00, $ab, $00, $9f, $0c, $00, $ab, $00, $9f, $51, $00, $ab, $00, $9f, $52, $00
	db $ab, $00, $9f, $5c, $00, $ab, $00, $9f, $7f, $00, $ab, $00, $9f, $8b, $00, $ab
	db $00, $a1, $0b, $00, $ab, $00, $a1, $0c, $00, $ab, $00, $a1, $51, $00, $ab, $00
	db $a1, $52, $00, $ab, $00, $a1, $5c, $00, $ab, $00, $a1, $7f, $00, $ab, $00, $a1
	db $8b, $00, $ab, $00, $a3, $0b, $00, $ab, $00, $a3, $0c, $00, $ab, $00, $a3, $51
	db $00, $ab, $00, $a3, $52, $00, $ab, $00, $a3, $5c, $00, $ab, $00, $a3, $7f, $00
	db $ab, $00, $a3, $8b, $00, $ab, $00, $9f, $32, $00, $ac, $00, $9f, $3a, $00, $ac
	db $00, $9f, $44, $00, $ac, $00, $9f, $4c, $00, $ac, $00, $9f, $53, $00, $ac, $00
	db $9f, $89, $00, $ac, $00, $9f, $90, $00, $ac, $00, $9f, $c4, $00, $ac, $00, $9f
	db $c5, $00, $ac, $00, $a1, $32, $00, $ac, $00, $a1, $3a, $00, $ac, $00, $a1, $44
	db $00, $ac, $00, $a1, $4c, $00, $ac, $00, $a1, $53, $00, $ac, $00, $a1, $89, $00
	db $ac, $00, $a1, $90, $00, $ac, $00, $a1, $c4, $00, $ac, $00, $a1, $c5, $00, $ac
	db $00, $a3, $32, $00, $ac, $00, $a3, $3a, $00, $ac, $00, $a3, $44, $00, $ac, $00
	db $a3, $4c, $00, $ac, $00, $a3, $53, $00, $ac, $00, $a3, $89, $00, $ac, $00, $a3
	db $90, $00, $ac, $00, $a3, $c4, $00, $ac, $00, $a3, $c5, $00, $ac, $00, $a4, $32
	db $00, $ac, $00, $a4, $3a, $00, $ac, $00, $a4, $44, $00, $ac, $00, $a4, $4c, $00
	db $ac, $00, $a4, $53, $00, $ac, $00, $a4, $89, $00, $ac, $00, $a4, $90, $00, $ac
	db $00, $a4, $c4, $00, $ac, $00, $a4, $c5, $00, $ac, $00, $a4, $83, $00, $a9, $00
	db $a4, $8d, $00, $a9, $00, $a4, $91, $00, $a9, $00, $a4, $b9, $00, $a9, $00, $a4
	db $bd, $00, $a9, $00, $a6, $83, $00, $a9, $00, $a6, $8d, $00, $a9, $00, $a6, $91
	db $00, $a9, $00, $a6, $b9, $00, $a9, $00, $a6, $bd, $00, $a9, $00, $ab, $83, $00
	db $a9, $00, $ab, $8d, $00, $a9, $00, $ab, $91, $00, $a9, $00, $ab, $b9, $00, $a9
	db $00, $ab, $bd, $00, $a9, $00, $ac, $83, $00, $a9, $00, $ac, $8d, $00, $a9, $00
	db $ac, $91, $00, $a9, $00, $ac, $b9, $00, $a9, $00, $ac, $bd, $00, $a9, $00, $9c
	db $0e, $00, $aa, $00, $9c, $0f, $00, $aa, $00, $9c, $12, $00, $aa, $00, $9c, $22
	db $00, $aa, $00, $9c, $25, $00, $aa, $00, $9c, $42, $00, $aa, $00, $9c, $54, $00
	db $aa, $00, $9c, $56, $00, $aa, $00, $9c, $57, $00, $aa, $00, $9c, $c7, $00, $aa
	db $00, $a9, $0e, $00, $aa, $00, $a9, $0f, $00, $aa, $00, $a9, $12, $00, $aa, $00
	db $a9, $22, $00, $aa, $00, $a9, $25, $00, $aa, $00, $a9, $42, $00, $aa, $00, $a9
	db $54, $00, $aa, $00, $a9, $56, $00, $aa, $00, $a9, $57, $00, $aa, $00, $a9, $c7
	db $00, $aa, $00, $ab, $0e, $00, $aa, $00, $ab, $0f, $00, $aa, $00, $ab, $12, $00
	db $aa, $00, $ab, $22, $00, $aa, $00, $ab, $25, $00, $aa, $00, $ab, $42, $00, $aa
	db $00, $ab, $54, $00, $aa, $00, $ab, $56, $00, $aa, $00, $ab, $57, $00, $aa, $00
	db $ab, $c7, $00, $aa, $00, $ac, $0e, $00, $aa, $00, $ac, $0f, $00, $aa, $00, $ac
	db $12, $00, $aa, $00, $ac, $22, $00, $aa, $00, $ac, $25, $00, $aa, $00, $ac, $42
	db $00, $aa, $00, $ac, $54, $00, $aa, $00, $ac, $56, $00, $aa, $00, $ac, $57, $00
	db $aa, $00, $ac, $c7, $00, $aa, $00, $9c, $ae, $00, $a9, $00, $a1, $ae, $00, $a9
	db $00, $a4, $ae, $00, $a9, $00, $ab, $ae, $00, $a9, $00, $ac, $ae, $00, $a9, $00
	db $c4, $00, $00, $b8, $00, $c4, $04, $00, $b8, $00, $c4, $05, $00, $b8, $00, $c4
	db $0b, $00, $b8, $00, $c5, $00, $00, $b8, $00, $c5, $04, $00, $b8, $00, $c5, $05
	db $00, $b8, $00, $c5, $0b, $00, $b8, $00, $b0, $51, $00, $bb, $00, $b0, $52, $00
	db $bb, $00, $b0, $55, $00, $bb, $00, $b0, $58, $00, $bb, $00, $b8, $51, $00, $bb
	db $00, $b8, $52, $00, $bb, $00, $b8, $55, $00, $bb, $00, $b8, $58, $00, $bb, $00
	db $c4, $51, $00, $bb, $00, $c4, $52, $00, $bb, $00, $c4, $55, $00, $bb, $00, $c4
	db $58, $00, $bb, $00, $c5, $51, $00, $bb, $00, $c5, $52, $00, $bb, $00, $c5, $55
	db $00, $bb, $00, $c5, $58, $00, $bb, $00, $b1, $00, $00, $bf, $00, $b1, $47, $00
	db $bf, $00, $b1, $4d, $00, $bf, $00, $b1, $55, $00, $bf, $00, $b1, $5b, $00, $bf
	db $00, $b1, $69, $00, $bf, $00, $b5, $00, $00, $bf, $00, $b5, $47, $00, $bf, $00
	db $b5, $4d, $00, $bf, $00, $b5, $55, $00, $bf, $00, $b5, $5b, $00, $bf, $00, $b5
	db $69, $00, $bf, $00, $b7, $00, $00, $bf, $00, $b7, $47, $00, $bf, $00, $b7, $4d
	db $00, $bf, $00, $b7, $55, $00, $bf, $00, $b7, $5b, $00, $bf, $00, $b7, $69, $00
	db $bf, $00, $bb, $0c, $00, $bd, $00, $bb, $25, $00, $bd, $00, $bb, $3e, $00, $bd
	db $00, $bb, $90, $00, $bd, $00, $bb, $93, $00, $bd, $00, $bb, $98, $00, $bd, $00
	db $bb, $a9, $00, $bd, $00, $bb, $ac, $00, $bd, $00, $b9, $9c, $00, $c1, $00, $b9
	db $aa, $00, $c1, $00, $b9, $29, $00, $c0, $00, $b9, $42, $00, $c0, $00, $b9, $56
	db $00, $c0, $00, $b9, $83, $00, $c0, $00, $b9, $97, $00, $c0, $00, $bd, $32, $00
	db $42, $00, $bd, $36, $00, $42, $00, $bd, $3e, $00, $42, $00, $bd, $41, $00, $42
	db $00, $bd, $43, $00, $42, $00, $bd, $44, $00, $42, $00, $bd, $42, $00, $c1, $00
	db $94, $59, $00, $99, $00, $59, $94, $00, $99, $00, $c7, $97, $00, $9a, $00, $97
	db $c7, $00, $9a, $00, $ad, $22, $00, $c8, $00, $ad, $25, $00, $c8, $00, $aa, $12
	db $00, $ca, $00, $99, $6c, $00, $cb, $00, $ca, $29, $00, $cc, $00, $c8, $cb, $00
	db $cd, $00, $c9, $cb, $00, $cd, $00, $9a, $2c, $00, $ce, $00, $ce, $42, $00, $cf
	db $00, $cf, $13, $00, $d0, $00, $d0, $24, $00, $d1, $00, $cc, $43, $00, $d2, $00
	db $cd, $d0, $00, $d3, $00, $cd, $d1, $00, $d3, $00, $d0, $cd, $00, $d3, $00, $d1
	db $cd, $00, $d3, $00, $d3, $80, $00, $d4, $00, $d4, $d2, $00, $d5, $00, $d5, $6d
	db $00, $d6, $00, $17, $f2, $00, $1e, $00, $3a, $f1, $00, $32, $00, $3b, $f1, $00
	db $32, $00, $41, $f1, $00, $32, $00, $45, $f1, $00, $32, $00, $2e, $f1, $00, $40
	db $00, $36, $f1, $00, $41, $00, $2d, $f0, $00, $3e, $00, $32, $f0, $00, $3e, $00
	db $3a, $f0, $00, $3e, $00, $3b, $f0, $00, $3e, $00, $3f, $f0, $00, $3e, $00, $40
	db $f0, $00, $3e, $00, $41, $f0, $00, $3e, $00, $2f, $f3, $00, $34, $00, $3a, $f6
	db $00, $32, $00, $31, $f1, $00, $35, $00, $47, $f1, $00, $52, $00, $51, $f1, $00
	db $52, $00, $53, $f1, $00, $52, $00, $55, $f1, $00, $52, $00, $48, $f2, $00, $51
	db $00, $51, $f6, $00, $53, $00, $47, $f7, $00, $52, $00, $51, $f7, $00, $52, $00
	db $53, $f7, $00, $52, $00, $55, $f7, $00, $52, $00, $46, $f0, $00, $4e, $00, $5a
	db $f2, $00, $64, $00, $64, $f6, $00, $67, $00, $67, $f1, $00, $66, $00, $61, $f2
	db $00, $62, $00, $6e, $f0, $00, $76, $00, $74, $f0, $00, $7c, $00, $6f, $f2, $00
	db $7a, $00, $73, $f8, $00, $79, $00, $71, $f6, $00, $7b, $00, $7a, $f7, $00, $7e
	db $00, $7c, $f7, $00, $7e, $00, $72, $f4, $00, $78, $00, $7c, $f1, $00, $79, $00
	db $79, $f6, $00, $7f, $00, $82, $f0, $00, $8a, $00, $85, $f0, $00, $8a, $00, $87
	db $f0, $00, $8a, $00, $86, $f7, $00, $8c, $00, $8a, $f7, $00, $8c, $00, $8b, $f7
	db $00, $8c, $00, $88, $f1, $00, $84, $00, $89, $f1, $00, $84, $00, $8b, $f1, $00
	db $84, $00, $8c, $f1, $00, $84, $00, $88, $f2, $00, $93, $00, $89, $f2, $00, $93
	db $00, $8b, $f2, $00, $93, $00, $8c, $f2, $00, $93, $00, $88, $f7, $00, $96, $00
	db $89, $f7, $00, $96, $00, $8b, $f7, $00, $96, $00, $8c, $f7, $00, $96, $00, $83
	db $f1, $00, $97, $00, $83, $f8, $00, $98, $00, $83, $f7, $00, $8d, $00, $83, $f2
	db $00, $8e, $00, $91, $f1, $00, $90, $00, $91, $f8, $00, $98, $00, $91, $f7, $00
	db $83, $00, $91, $f2, $00, $97, $00, $90, $f1, $00, $83, $00, $90, $f8, $00, $98
	db $00, $90, $f2, $00, $97, $00, $90, $f7, $00, $91, $00, $9b, $f2, $00, $a3, $00
	db $9b, $f6, $00, $a8, $00, $a3, $f6, $00, $a8, $00, $a0, $f6, $00, $a5, $00, $a6
	db $f6, $00, $a5, $00, $9c, $f3, $00, $a6, $00, $a1, $f3, $00, $a6, $00, $a4, $f3
	db $00, $a6, $00, $a9, $f3, $00, $a6, $00, $ab, $f3, $00, $a6, $00, $ac, $f3, $00
	db $a6, $00, $9e, $f3, $00, $a7, $00, $aa, $f6, $00, $ad, $00, $9c, $f1, $00, $9c
	db $00, $a9, $f1, $00, $9c, $00, $aa, $f1, $00, $9c, $00, $ab, $f1, $00, $9c, $00
	db $ac, $f1, $00, $9c, $00, $a6, $f1, $00, $ac, $00, $af, $f0, $00, $b7, $00, $bd
	db $f1, $00, $b9, $00, $bf, $f6, $00, $be, $00, $c0, $f6, $00, $ba, $00, $c1, $f6
	db $00, $ba, $00, $b9, $f1, $00, $b9, $02, $bd, $f5, $00, $c6, $00, $bd, $f7, $00
	db $c2, $00, $bd, $f3, $00, $bc, $00, $f0, $30, $00, $09, $00, $f0, $58, $00, $09
	db $00, $f0, $ae, $00, $09, $00, $f0, $1a, $00, $06, $00, $f0, $7b, $00, $06, $00
	db $f0, $f9, $00, $0f, $02, $f0, $a1, $00, $0b, $00, $f0, $c4, $00, $0b, $00, $f0
	db $c5, $00, $0b, $00, $f0, $32, $00, $0a, $00, $f0, $41, $00, $0a, $00, $f0, $42
	db $00, $0a, $00, $f0, $43, $00, $0a, $00, $f0, $44, $00, $0a, $00, $f0, $b9, $00
	db $10, $00, $f0, $81, $00, $0b, $00, $f1, $f9, $00, $29, $00, $f1, $0e, $00, $25
	db $00, $f1, $0f, $00, $25, $00, $f1, $12, $00, $25, $00, $f1, $2a, $00, $25, $00
	db $f1, $3e, $00, $25, $00, $f1, $56, $00, $25, $00, $f1, $57, $00, $25, $00, $f1
	db $96, $00, $25, $00, $f1, $97, $00, $25, $00, $f1, $42, $00, $2a, $00, $f1, $90
	db $00, $2a, $00, $f1, $95, $00, $2a, $00, $f1, $98, $00, $2a, $00, $f1, $9c, $00
	db $9c, $00, $f1, $a9, $00, $9c, $00, $f1, $aa, $00, $9c, $00, $f1, $ad, $00, $9c
	db $00, $f1, $81, $00, $24, $00, $f2, $19, $00, $3f, $00, $f2, $b9, $00, $3a, $00
	db $f2, $bd, $00, $3a, $00, $f2, $c0, $00, $3a, $00, $f2, $c1, $00, $3a, $00, $f2
	db $c4, $00, $3a, $00, $f2, $c5, $00, $3a, $00, $f3, $00, $00, $55, $00, $f3, $32
	db $00, $55, $00, $f3, $37, $00, $55, $00, $f3, $3a, $00, $55, $00, $f3, $83, $00
	db $55, $00, $f3, $ae, $00, $55, $00, $f3, $c0, $00, $55, $00, $f3, $10, $00, $54
	db $00, $f3, $11, $00, $54, $00, $f3, $36, $00, $54, $00, $f3, $3b, $00, $54, $00
	db $f3, $3f, $00, $54, $00, $f3, $41, $00, $54, $00, $f3, $9c, $00, $54, $00, $f3
	db $a9, $00, $54, $00, $f3, $aa, $00, $54, $00, $f3, $ac, $00, $54, $00, $f3, $ad
	db $00, $54, $00, $f4, $0b, $00, $69, $00, $f4, $45, $00, $69, $00, $f4, $4a, $00
	db $69, $00, $f4, $71, $00, $69, $00, $f4, $7a, $00, $69, $00, $f4, $87, $00, $69
	db $00, $f4, $b5, $00, $69, $00, $f7, $1b, $00, $9c, $00, $f7, $1b, $00, $9c, $00
	db $f7, $1f, $00, $9c, $00, $f7, $22, $00, $9c, $00, $f7, $25, $00, $9c, $00, $f7
	db $29, $00, $9c, $00, $f7, $2a, $00, $9c, $00, $f7, $2c, $00, $9c, $00, $f7, $07
	db $00, $a4, $00, $f7, $0a, $00, $a4, $00, $f7, $2d, $00, $a4, $00, $f7, $3b, $00
	db $a4, $00, $f7, $58, $00, $a4, $00, $f7, $5a, $00, $a4, $00, $f7, $64, $00, $a4
	db $00, $f7, $74, $00, $a4, $00, $f7, $7c, $00, $a4, $00, $f8, $32, $00, $bd, $00
	db $f8, $3a, $00, $bd, $00, $f8, $41, $00, $bd, $00, $f8, $42, $00, $bd, $00, $f8
	db $7f, $00, $c5, $00, $f8, $81, $00, $c5, $00, $ff

Call_16_5B4E::
	ld a, [wOnGateFloor]
	or a
	ret z

	ld a, [wGameStarted]
	bit 7, a
	ret nz

	ld hl, wGateFloor
	inc [hl]
	xor a
	ld [wWorldFlags], a
	ld a, [wOnGateFloor]
	bit 7, a
	jr nz, jr_016_5b72

	ld a, [wMapId]
	ld [wGateWorld], a
	xor a
	ld [wGateFloor], a

jr_016_5b72:
	ld hl, far_LoadFloorMusic
	rst $10
	ld a, [wGateWorld]
	add a
	add a
	add a
	ld hl, $70a6
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$c936], a
	ld a, [hli]
	ld [$c937], a
	ld a, [hli]
	ld [$c938], a
	push hl
	ld a, [hli]
	ld [wGateFloors], a
	ld a, [hli]
	ld [wGateWorldMap], a
	inc hl
	inc hl
	ld a, [hl]
	ld [wFloorLoot], a
	pop hl
	ld a, [wGateFloor]
	ld b, a
	inc a
	cp [hl]
	jr z, jr_016_5be1

	ld a, [wGateWorld]
	or a
	jr z, jr_016_5bbf

	ld a, [wRandomHigh]
	bit 4, a
	jr z, jr_016_5bbf

	ld a, $03
	call Divide8
	cp $02
	jr z, jr_016_5c1c

jr_016_5bbf:
	ld a, [$c936]
	add a
	add a
	add a
	add a
	ld hl, $71a6
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_16_5FC0
	ld [$c936], a
	ld a, [$c936]
	ld [wMapId], a
	ld a, $01
	ld [wOnGateFloor], a
	ret


jr_016_5be1:
	ld a, [wGateWorld]
	add a
	add a
	add a
	ld hl, $70aa
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	or $08
	ld [wWarpX], a
	ld a, b
	and $0f
	ld [$c970], a
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	or $08
	ld [wWarpY], a
	ld a, b
	and $0f
	ld [$c972], a
	ret


jr_016_5c1c:
	ld a, [$c937]
	add a
	add a
	add a
	ld hl, $72a6
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_16_5FC0
	ld [$c937], a
	rst $00

JumpTable_16_5C32::
	dw Jump_16_5C42
	dw Jump_16_5CB9
	dw Jump_16_5CCB
	dw Jump_16_5CEC
	dw Jump_16_5D0D
	dw Jump_16_5D2E
	dw Jump_16_5ED8
	dw Jump_16_5F4C

Jump_16_5C42::
	call Call_16_6DB0

Call_16_5C45::
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
	cp $01
	jr z, jr_016_5c77

	cp $02
	jr z, jr_016_5c98

	ld a, $5a
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
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
	ret


jr_016_5c77:
	ld a, $5b
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
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
	ret


jr_016_5c98:
	ld a, $5c
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0068
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


Jump_16_5CB9::
	ld hl, wArenaWins
	ld bc, $0008
	ld a, $ff
	call FillMemory
	call Call_16_6DDB
	call Call_16_5C45
	ret


Jump_16_5CCB::
	ld a, $53
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


Jump_16_5CEC::
	ld a, $51
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


Jump_16_5D0D::
	ld a, $50
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


Jump_16_5D2E::
	xor a
	ld [wArenaWins], a
	ld [wArenaPrize], a
	call Call_16_5E38
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [$d9d1], a
	ld a, h
	ld [$d9d2], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$d9d3], a
	ld a, h
	ld [$d9d4], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$d9d5], a
	ld a, h
	ld [$d9d6], a
	call Call_16_5E38
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [$d9d9], a
	ld a, h
	ld [$d9da], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$d9db], a
	ld a, h
	ld [$d9dc], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$d9dd], a
	ld a, h
	ld [$d9de], a
	call Call_16_5E38
	ld hl, wEncGfx
	call Call_16_5DC6
	ld a, $52
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0068
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	xor a
	ld [wArenaRound], a
	ret


Call_16_5DC6::
	push hl
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
	ld [hl], a
	pop hl
	push hl
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	call Call_16_5E2E
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, [wEncCount]
	or a
	ret z

	push hl
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	call Call_16_5E2E
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, [wEncCount]
	cp $01
	ret z

	push hl
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	call Call_16_5E2E
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ret


Call_16_5E2E::
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wNewMonNameText]
	add $10
	ret


Call_16_5E38::
	ld hl, $0000
	ld c, $00
	ld a, [wParty]
	call Call_16_5E91
	ld a, [$ca8f]
	call Call_16_5E91
	ld a, [$ca90]
	call Call_16_5E91
	ld a, c
	call Divide16
	ld a, l
	ld hl, $0209
	cp $04
	jr c, jr_016_5ea7

	ld hl, $0d12
	cp $0a
	jr c, jr_016_5ea7

	ld hl, $2112
	cp $10
	jr c, jr_016_5ea7

	ld hl, $3912
	cp $16
	jr c, jr_016_5ea7

	ld hl, $5112
	cp $1c
	jr c, jr_016_5ea7

	ld hl, $6912
	cp $22
	jr c, jr_016_5ea7

	ld hl, $8112
	cp $28
	jr c, jr_016_5ea7

	ld hl, $9d12
	cp $2e
	jr c, jr_016_5ea7

	ld hl, $b512
	jr jr_016_5ea7

Call_16_5E91::
	cp $ff
	ret z

	push bc
	push hl
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	pop hl
	pop bc
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	inc c
	ret


jr_016_5ea7:
	ld a, $02
	ld [wEncCount], a
	call Call_16_5EC9
	ld [wEncSpecies], a
	call Call_16_5EC9
	ld [$da05], a
	call Call_16_5EC9
	ld [$da07], a
	xor a
	ld [$da04], a
	ld [$da06], a
	ld [$da08], a
	ret


Call_16_5EC9::
	push hl
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, l
	call Divide8
	pop hl
	add h
	ret


Jump_16_5ED8::
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
	cp $01
	jr z, jr_016_5f0a

	cp $02
	jr z, jr_016_5f2b

	ld a, $57
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $00f8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $00b8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


jr_016_5f0a:
	ld a, $58
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0018
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0028
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


jr_016_5f2b:
	ld a, $59
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0018
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0028
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


Jump_16_5F4C::
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
	cp $01
	jr z, jr_016_5f7e

	cp $02
	jr z, jr_016_5f9f

	ld a, $54
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $00d8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $00d8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


jr_016_5f7e:
	ld a, $55
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0168
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


jr_016_5f9f:
	ld a, $56
	ld [wMapId], a
	ld a, $00
	ld [wOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $00b8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


Call_16_5FC0::
	push hl
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $64
	call Divide16
	pop hl
	ld c, a
	ld b, $ff

jr_016_5fd5:
	ld a, [hl]
	inc b
	inc hl
	or a
	jr z, jr_016_5fd5

	cp $64
	jr z, jr_016_5fe2

	cp c
	jr c, jr_016_5fd5

jr_016_5fe2:
	ld a, b
	ret


Call_16_5FE4::
	call Call_16_6E14
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_016_6002

	ld a, $ff
	ld [$c926], a
	xor a
	ld [$c92b], a
	ld [$c92c], a
	xor a
	ld [wFloorEvent], a
	xor a
	ld [wFloorSteps], a
	ret


jr_016_6002:
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
	ld a, [wGameStarted]
	bit 7, a
	jr z, jr_016_605b

	xor a
	ld [wMenuOverlay], a
	ret


	db $00, $00, $00, $01, $02

Jump_016_605b:
jr_016_605b:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	ld hl, $6056
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c93f], a
	ld hl, wFloorsSeen
	ld bc, $0010
	xor a
	call FillMemory
	ld hl, $c940
	ld bc, $0010
	ld a, $ff
	call FillMemory
	ld a, [$c93f]
	cp $02
	jr nz, jr_016_60b9

	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $15
	call Divide8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	add $36
	ld l, a
	ld a, h
	adc $77
	ld h, a
	ld de, $c940
	ld b, $10

jr_016_60b0:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_016_60b0

	jp Jump_016_616c


jr_016_60b9:
	ld hl, $7096
	ld a, [wFloorMusic]
	inc a
	ld b, a
	push hl
	ld a, [hl]
	ld c, a
	push bc
	ld a, b
	cp $09
	ld bc, $0000
	jr nc, jr_016_60d8

	ld a, [wRandomHigh]
	ld b, a

jr_016_60d1:
	inc b
	ld a, b
	and $05
	jr z, jr_016_60d1

	ld b, a

jr_016_60d8:
	push bc
	call Call_16_6800
	pop bc
	cp $0f
	jr z, jr_016_60d8

	pop bc
	push af
	ld a, c
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a
	pop hl
	inc hl
	dec b

jr_016_60f2:
	push hl
	ld a, [hl]
	ld c, a
	push bc
	call Call_16_6744
	ld a, b
	or a
	ld a, $ff
	jr z, jr_016_6102

	call Call_16_6800

jr_016_6102:
	pop bc
	push af
	ld a, c
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a
	pop hl
	inc hl
	dec b
	jr nz, jr_016_60f2

	ld hl, $7096
	ld b, $10

jr_016_611a:
	push hl
	ld a, [hl]
	cp $ff
	jr z, jr_016_6140

	ld c, a
	push bc
	call Call_16_6744
	ld a, b
	or a
	ld a, $0f
	jr z, jr_016_6132

	ld a, b
	xor $0f
	ld c, a
	call Call_16_6800

jr_016_6132:
	pop bc
	push af
	ld a, c
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a

jr_016_6140:
	pop hl
	inc hl
	dec b
	jr nz, jr_016_611a

	ld hl, $c940
	ld b, $10

jr_016_614a:
	push bc
	push hl
	ld c, $0c
	ld a, [$c93f]
	cp $01
	jr z, jr_016_6162

	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $0c
	call Divide8
	ld c, a

jr_016_6162:
	pop hl
	ld a, [hl]
	swap a
	add c
	ld [hli], a
	pop bc
	dec b
	jr nz, jr_016_614a

Jump_016_616c:
	ld a, $40
	ld [$c0a9], a

jr_016_6171:
	ld a, [$c0a9]
	dec a
	ld [$c0a9], a
	jp z, Jump_016_605b

	call Call_16_66AE
	ld a, [wMapScreen]
	ld [$c960], a
	ldh a, [hTestX]
	ld [$c0a5], a
	ldh a, [$ffa6]
	ld [$c0a6], a
	ldh a, [hTestY]
	ld [$c0a7], a
	ldh a, [$ffa8]
	ld [$c0a8], a
	call Call_16_6AFB
	jr z, jr_016_6171

	ld a, [$c0a7]
	ld [wGoalY], a
	and $f0
	ld l, a
	ld a, [$c0a8]
	ld [$c967], a
	sla l
	rla
	sla l
	rla
	ld h, a
	ld a, [$c0a6]
	ld [$c965], a
	ld d, a
	ld a, [$c0a5]
	ld [wGoalX], a
	srl d
	rra
	srl d
	rra
	srl d
	rra
	and $1e
	ld e, a
	ld d, $00
	add hl, de
	ld a, l
	ld [$c962], a
	ld a, h
	ld [$c963], a
	ld a, [$c960]
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wGoalX]
	add [hl]
	ld [wGoalX], a
	inc hl
	ld a, [$c965]
	adc [hl]
	ld [$c965], a
	inc hl
	ld a, [wGoalY]
	add [hl]
	ld [wGoalY], a
	inc hl
	ld a, [$c967]
	adc [hl]
	ld [$c967], a
	inc hl
	ld a, $40
	ld [$c0a9], a

jr_016_620a:
	ld a, [$c0a9]
	dec a
	ld [$c0a9], a
	jp z, Jump_016_605b

	call Call_16_6585
	ld a, [$c960]
	ld b, a
	ld a, [wMapScreen]
	cp b
	jr z, jr_016_620a

	ld a, [wMapScreen]
	ld [$c926], a
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$c927], a
	ld a, [hli]
	ld [$c928], a
	ld a, [hli]
	ld [$c929], a
	ld a, [hli]
	ld [$c92a], a
	ld hl, $c927
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
	ld [hl], a
	ld hl, $c929
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
	ld [hl], a
	ld a, [wScriptBossIndex]
	or a
	jr z, jr_016_6262

	cp $01
	jr nz, jr_016_6266

jr_016_6262:
	xor a
	ld [wFloorEvent], a

jr_016_6266:
	ld a, [wFloorEvent]
	ld [$c92b], a
	cp $04
	jr z, jr_016_627e

	cp $05
	jr z, jr_016_627e

	cp $06
	jr z, jr_016_627e

	cp $07
	jr z, jr_016_627e

	jr jr_016_628a

jr_016_627e:
	call Random
	ld a, [wRandomHigh]
	bit 0, a
	jr z, jr_016_62cf

	jr jr_016_629f

jr_016_628a:
	call Random
	ld a, [$c938]
	ld hl, $7886
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wRandomHigh]
	cp [hl]
	jr c, jr_016_62b5

jr_016_629f:
	xor a
	ld [$c92b], a
	ld [$c92c], a
	xor a
	ld [wFloorEvent], a
	xor a
	ld [wFloorSteps], a
	ld a, $ff
	ld [$c926], a
	jr jr_016_62cf

jr_016_62b5:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	ld [$c92c], a
	call Random
	ld a, [wRandomHigh]
	and $03
	ld [$c92b], a

jr_016_62cf:
	xor a
	ld [wFloorEvent], a
	ld a, $40
	ld [$c0a9], a

Jump_016_62d8:
jr_016_62d8:
	ld a, [$c0a9]
	dec a
	ld [$c0a9], a
	jp z, Jump_016_605b

	call Call_16_661B
	ld hl, $c960
	ld a, [wMapScreen]
	cp [hl]
	jr nz, jr_016_62f1

	call Call_16_661B

jr_016_62f1:
	ld a, [wMapScreen]
	ld [$c0af], a
	call Call_16_68C6
	jp z, Jump_016_62d8

	ld a, [$c926]
	ld b, a
	ld a, [wMapScreen]
	cp b
	jr z, jr_016_62d8

	ld a, [wMapScreen]
	ld [wNumberBackup], a
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wWarpX], a
	ld a, [hli]
	ld [$c970], a
	ld a, [hli]
	ld [wWarpY], a
	ld a, [hli]
	ld [$c972], a
	ldh a, [hTestX]
	ld [$c0a1], a
	ldh a, [$ffa6]
	ld [$c0a2], a
	ldh a, [hTestY]
	ld [wLineUpOrder], a
	ldh a, [$ffa8]
	ld [$c0a4], a
	ld hl, wWarpX
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
	ld [hl], a
	ld hl, wWarpY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
	ld [hl], a
	ld hl, wLineScroll
	ld bc, $0010
	xor a
	call FillMemory
	ld a, [$c938]
	ld hl, $732f
	add a
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	push af
	ld a, [wRandomHigh]
	ld b, a
	ld a, [hli]
	inc a
	push hl
	call Divide8
	pop hl
	ld b, a
	pop af
	add b
	ld b, a
	ld c, [hl]
	push bc
	ld hl, $c940
	ld b, $10
	ld c, $00

jr_016_6386:
	ld a, [hli]
	and $f0
	cp $f0
	jr z, jr_016_638e

	inc c

jr_016_638e:
	dec b
	jr nz, jr_016_6386

	ld a, c
	pop bc
	cp $06
	jr nc, jr_016_639b

	srl b
	res 7, b

jr_016_639b:
	ld hl, wFloorObjects
	ld a, b
	or a
	jr z, jr_016_63ac

jr_016_63a2:
	push bc
	ld [hl], $ff
	call Call_16_6432
	pop bc
	dec b
	jr nz, jr_016_63a2

jr_016_63ac:
	ld [hl], $ff
	ret


Call_16_63AF::
	call Random
	ld a, [wRandomHigh]
	ld b, a

jr_016_63b6:
	inc b
	ld a, b
	and $0f
	ld [wMapScreen], a
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_63b6

	ld hl, far_Call_0B_4239
	rst $10
	ld hl, wSavedTilemap
	call Decompress
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a

jr_016_63e1:
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

	jr jr_016_63e1

Call_16_6432::
	push hl
	ld a, $10
	ld [$c0a9], a
	push bc
	ld a, [$c938]
	ld hl, $7326
	add a
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_16_5FC0
	ld [$c0ae], a
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $64
	call Divide16
	pop bc
	cp c
	jr z, jr_016_646d

	jr nc, jr_016_646d

	ld a, [$c0ae]
	add $10
	ld [$c0ae], a

Jump_016_646d:
jr_016_646d:
	ld a, [$c0a9]
	dec a
	ld [$c0a9], a
	jr nz, jr_016_6478

	pop hl
	ret


jr_016_6478:
	call Call_16_63AF
	ld a, [wMapScreen]
	ld b, a
	ld a, [$c960]
	cp b
	jr nz, jr_016_6488

	call Call_16_63AF

jr_016_6488:
	ld a, [wMapScreen]
	ld b, a
	ld a, [$c0af]
	cp b
	jr nz, jr_016_6495

	call Call_16_63AF

jr_016_6495:
	ld a, [wMapScreen]
	ld hl, wLineScroll
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_016_64a8

	call Call_16_63AF

jr_016_64a8:
	ldh a, [hTestX]
	ld [$c0aa], a
	ldh a, [$ffa6]
	ld [$c0ab], a
	ldh a, [hTestY]
	ld [$c0ac], a
	ldh a, [$ffa8]
	ld [$c0ad], a
	call Call_16_6955
	jr z, jr_016_646d

	ld a, [$c0aa]
	ldh [hTestX], a
	ld a, [$c0ab]
	ldh [$ffa6], a
	ld a, [$c0ac]
	ldh [hTestY], a
	ld a, [$c0ad]
	ldh [$ffa8], a
	call Call_16_68C6
	jr z, jr_016_646d

	call Call_16_68EA
	jr z, jr_016_646d

	call Call_16_690E
	jr z, jr_016_646d

	ld a, [wMapScreen]
	ld b, a
	ld a, [$c926]
	cp b
	jp z, Jump_016_646d

	ld a, [wMapScreen]
	ld hl, wLineScroll
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	jp z, Jump_016_646d

	inc [hl]
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
	ldh [hDivisorHigh], a
	ld a, [hli]
	ldh [$ffdc], a
	ld a, [hli]
	ldh [hFindY], a
	ld a, [hli]
	ldh [$ffde], a
	ld hl, hDivisorHigh
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
	ld [hl], a
	ld hl, hFindY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
	ld [hl], a
	pop hl
	ld a, [$c0ae]
	ld [hli], a
	push hl
	ld a, [$c0ae]
	and $0f
	ld hl, $7426
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_016_6564

	ld a, [$c938]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, l
	ld d, h
	add hl, hl
	add hl, de
	ld a, l
	add $36
	ld l, a
	ld a, h
	adc $74
	ld h, a
	call Call_16_5FC0

jr_016_6564:
	pop hl
	ld [hli], a
	ldh a, [hDivisorHigh]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffdc]
	swap a
	and $f0
	or b
	ld [hli], a
	ldh a, [hFindY]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffde]
	swap a
	and $f0
	or b
	ld [hli], a
	ret


Call_16_6585::
	call Random
	ld a, [wRandomHigh]
	ld b, a

Jump_016_658c:
jr_016_658c:
	inc b
	ld a, b
	and $0f
	ld [wMapScreen], a
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_658c

	ld hl, far_Call_0B_4239
	rst $10
	ld hl, wSavedTilemap
	call Decompress
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a
	ld a, $40
	ldh [hNumber], a

jr_016_65bb:
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

	cp $0e
	ret z

	ldh a, [hNumber]
	dec a
	ldh [hNumber], a
	jr nz, jr_016_65bb

	ld a, [wMapScreen]
	ld b, a
	jp Jump_016_658c


Call_16_661B::
	call Random
	ld a, [wRandomHigh]
	ld b, a

Jump_016_6622:
jr_016_6622:
	inc b
	ld a, b
	and $0f
	ld [wMapScreen], a
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_6622

	ld hl, far_Call_0B_4239
	rst $10
	ld hl, wSavedTilemap
	call Decompress
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a
	ld a, $40
	ldh [hNumber], a

jr_016_6651:
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

	ldh a, [hNumber]
	dec a
	ldh [hNumber], a
	jr nz, jr_016_6651

	ld a, [wMapScreen]
	ld b, a
	jp Jump_016_6622


Call_16_66AE::
	call Random
	ld a, [wRandomHigh]
	ld b, a

Jump_016_66b5:
jr_016_66b5:
	inc b
	ld a, b
	and $0f
	ld [wMapScreen], a
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_66b5

	ld hl, far_Call_0B_4239
	rst $10
	ld hl, wSavedTilemap
	call Decompress
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a
	ld a, $40
	ldh [hNumber], a

jr_016_66e4:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $02
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
	ld a, $04
	call Divide8
	add $02
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

	cp $0e
	ret z

	ldh a, [hNumber]
	dec a
	ldh [hNumber], a
	jr nz, jr_016_66e4

	ld a, [wMapScreen]
	ld b, a
	jp Jump_016_66b5


Call_16_6744::
	ld bc, $0000
	ld d, a
	sub $04
	jr c, jr_016_676f

	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_016_6773

	add a
	add a
	ld hl, $7055
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 2, [hl]
	jr z, jr_016_676f

	ld a, $08
	or b
	ld b, a
	jr jr_016_6773

jr_016_676f:
	ld a, $08
	or c
	ld c, a

jr_016_6773:
	ld a, d
	add $04
	cp $10
	jr nc, jr_016_679d

	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_016_67a1

	add a
	add a
	ld hl, $7055
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr z, jr_016_679d

	ld a, $04
	or b
	ld b, a
	jr jr_016_67a1

jr_016_679d:
	ld a, $04
	or c
	ld c, a

jr_016_67a1:
	ld a, d
	and $03
	jr z, jr_016_67cb

	ld a, d
	dec a
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_016_67cf

	add a
	add a
	ld hl, $7055
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	jr z, jr_016_67cb

	ld a, $02
	or b
	ld b, a
	jr jr_016_67cf

jr_016_67cb:
	ld a, $02
	or c
	ld c, a

jr_016_67cf:
	ld a, d
	and $03
	cp $03
	jr z, jr_016_67fb

	ld a, d
	inc a
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_016_67ff

	add a
	add a
	ld hl, $7055
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 1, [hl]
	jr z, jr_016_67fb

	ld a, $01
	or b
	ld b, a
	jr jr_016_67ff

jr_016_67fb:
	ld a, $01
	or c
	ld c, a

jr_016_67ff:
	ret


Call_16_6800::
	ld de, wTilemapBuffer
	ld hl, $7055

jr_016_6806:
	ld a, [hl]
	cp $ff
	jr z, jr_016_6826

	and c
	jr nz, jr_016_681c

	ld a, [hl]
	and b
	cp b
	jr nz, jr_016_681c

	push hl
	inc hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	pop hl

jr_016_681c:
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_016_6806

jr_016_6826:
	ld [de], a
	inc de
	ld [de], a
	ld hl, wNumberBackup
	ld bc, $0005
	ld a, $00
	call FillMemory
	ld hl, $c501

jr_016_6837:
	ld a, [hli]
	cp $ff
	jr z, jr_016_684b

	inc hl
	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	jr jr_016_6837

jr_016_684b:
	xor a
	ld [wNumberBackup], a
	ld a, [$c0a1]
	ld b, $14
	call Divide8
	ld a, b
	ld [$c0a1], a
	ld a, [$c0a2]
	ld b, $28
	call Divide8
	ld a, b
	ld [$c0a2], a
	ld a, [wLineUpOrder]
	ld b, $3c
	call Divide8
	ld a, b
	ld [wLineUpOrder], a
	ld a, [$c0a4]
	ld b, $50
	call Divide8
	ld a, b
	ld [$c0a4], a
	ld hl, $c501
	ld b, $00

jr_016_6884:
	ld a, [hl]
	cp $ff
	jr z, jr_016_689a

	ld de, wNumberBackup
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add b
	ld b, a
	ld [hl], a
	inc hl
	inc hl
	jr jr_016_6884

jr_016_689a:
	push bc
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	pop af
	or a
	jr z, jr_016_68ad

	call Divide16

jr_016_68ad:
	ld b, a
	ld hl, $c501

jr_016_68b1:
	ld a, [hl]
	cp $ff
	jr nz, jr_016_68ba

	ld a, $0f
	jr jr_016_68c5

jr_016_68ba:
	cp b
	jr c, jr_016_68c1

	dec hl
	ld a, [hl]
	jr jr_016_68c5

jr_016_68c1:
	inc hl
	inc hl
	jr jr_016_68b1

jr_016_68c5:
	ret


Call_16_68C6::
	ld hl, $c960
	ld a, [wMapScreen]
	cp [hl]
	ret nz

	ld hl, hTestX
	ld a, [$c0a5]
	cp [hl]
	ret nz

	inc hl
	ld a, [$c0a6]
	cp [hl]
	ret nz

	ld hl, hTestY
	ld a, [$c0a7]
	cp [hl]
	ret nz

	inc hl
	ld a, [$c0a8]
	cp [hl]
	ret


Call_16_68EA::
	ld hl, wNumberBackup
	ld a, [wMapScreen]
	cp [hl]
	ret nz

	ld hl, hTestX
	ld a, [$c0a1]
	cp [hl]
	ret nz

	inc hl
	ld a, [$c0a2]
	cp [hl]
	ret nz

	ld hl, hTestY
	ld a, [wLineUpOrder]
	cp [hl]
	ret nz

	inc hl
	ld a, [$c0a4]
	cp [hl]
	ret


Call_16_690E::
	ld hl, wFloorObjects

jr_016_6911:
	ld a, [hl]
	cp $ff
	jr nz, jr_016_6918

	or a
	ret


jr_016_6918:
	push hl
	call Call_16_6924
	pop hl
	ret z

	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_016_6911

Call_16_6924::
	inc hl
	inc hl
	ld b, [hl]
	inc hl
	push hl
	ld a, $0a
	call Divide8
	ld a, b
	ldh [$ffda], a
	pop hl
	ld a, [hl]
	and $f8
	srl a
	ld b, a
	ldh a, [$ffda]
	add b
	ldh [$ffda], a
	ld a, [hl]
	and $07
	swap a
	or $08
	ldh [hDivisorHigh], a
	ld hl, $ffda
	ld a, [wMapScreen]
	cp [hl]
	ret nz

	ld hl, hTestY
	ldh a, [hDivisorHigh]
	cp [hl]
	ret


Call_16_6955::
	ld a, [$c0ae]
	and $f0
	jp z, Jump_016_6d93

	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b0], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b1], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b2], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b3], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b4], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b5], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b6], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b7], a
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b8], a
	jp Jump_016_6c96


Call_16_6AFB::
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b0], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b1], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b2], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b3], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b4], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b5], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b6], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b7], a
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call Call_16_6D99
	ld a, b
	ld [$c0b8], a

Jump_016_6c96:
	ld a, [$c0b3]
	or a
	jr z, jr_016_6cb1

	ld a, [$c0b2]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b5]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b8]
	or a
	jp nz, Jump_016_6d97

jr_016_6cb1:
	ld a, [$c0b7]
	or a
	jr z, jr_016_6ccc

	ld a, [$c0b0]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b1]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b2]
	or a
	jp nz, Jump_016_6d97

jr_016_6ccc:
	ld a, [$c0b1]
	or a
	jr z, jr_016_6ce7

	ld a, [$c0b6]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b7]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b8]
	or a
	jp nz, Jump_016_6d97

jr_016_6ce7:
	ld a, [$c0b5]
	or a
	jr z, jr_016_6d02

	ld a, [$c0b0]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b3]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b6]
	or a
	jp nz, Jump_016_6d97

jr_016_6d02:
	ld a, [$c0b0]
	or a
	jr z, jr_016_6d27

	ld a, [$c0b1]
	or a
	jr nz, jr_016_6d15

	ld a, [$c0b2]
	or a
	jp nz, Jump_016_6d97

jr_016_6d15:
	ld a, [$c0b3]
	or a
	jr nz, jr_016_6d21

	ld a, [$c0b6]
	or a
	jr nz, jr_016_6d97

jr_016_6d21:
	ld a, [$c0b8]
	or a
	jr nz, jr_016_6d97

jr_016_6d27:
	ld a, [$c0b2]
	or a
	jr z, jr_016_6d4b

	ld a, [$c0b1]
	or a
	jr nz, jr_016_6d39

	ld a, [$c0b0]
	or a
	jr nz, jr_016_6d97

jr_016_6d39:
	ld a, [$c0b5]
	or a
	jr nz, jr_016_6d45

	ld a, [$c0b8]
	or a
	jr nz, jr_016_6d97

jr_016_6d45:
	ld a, [$c0b6]
	or a
	jr nz, jr_016_6d97

jr_016_6d4b:
	ld a, [$c0b6]
	or a
	jr z, jr_016_6d6f

	ld a, [$c0b3]
	or a
	jr nz, jr_016_6d5d

	ld a, [$c0b0]
	or a
	jr nz, jr_016_6d97

jr_016_6d5d:
	ld a, [$c0b7]
	or a
	jr nz, jr_016_6d69

	ld a, [$c0b8]
	or a
	jr nz, jr_016_6d97

jr_016_6d69:
	ld a, [$c0b2]
	or a
	jr nz, jr_016_6d97

jr_016_6d6f:
	ld a, [$c0b8]
	or a
	jr z, jr_016_6d93

	ld a, [$c0b5]
	or a
	jr nz, jr_016_6d81

	ld a, [$c0b2]
	or a
	jr nz, jr_016_6d97

jr_016_6d81:
	ld a, [$c0b7]
	or a
	jr nz, jr_016_6d8d

	ld a, [$c0b6]
	or a
	jr nz, jr_016_6d97

jr_016_6d8d:
	ld a, [$c0b0]
	or a
	jr nz, jr_016_6d97

Jump_016_6d93:
jr_016_6d93:
	ld a, $01
	or a
	ret


Jump_016_6d97:
jr_016_6d97:
	xor a
	ret


Call_16_6D99::
	call GetCollisionAt
	ld b, $00
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
	ret z

	cp $0e
	ret z

	ld b, $01
	ret


Call_16_6DB0::
	ld hl, wArenaWins
	ld b, $08

jr_016_6db5:
	push bc
	push hl
	call Call_16_6DC1
	pop hl
	pop bc
	ld [hli], a
	dec b
	jr nz, jr_016_6db5

	ret


Call_16_6DC1::
	ld a, [$c938]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, l
	ld d, h
	add hl, hl
	add hl, de
	ld a, l
	add $36
	ld l, a
	ld a, h
	adc $74
	ld h, a
	call Call_16_5FC0
	ret


Call_16_6DDB::
	call Random
	ld a, [wRandomHigh]
	and $03
	ld hl, wArenaWins
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld de, $6e04
	push de
	push hl
	call Random
	ld a, [wRandomHigh]
	and $0f
	pop hl
	pop de
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ret


	db $03, $04, $06, $0c, $15, $17, $18, $19, $1a, $1b, $1c, $25, $1a, $1b, $1c, $25

Call_16_6E14::
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $65
	call Divide16
	ld hl, $6e3d

jr_016_6e27:
	cp [hl]
	jr z, jr_016_6e32

	jr c, jr_016_6e32

	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_016_6e27

jr_016_6e32:
	inc hl
	inc hl
	ld a, [hli]
	ld [$ca39], a
	ld a, [hli]
	ld [$ca3a], a
	ret


	db $02, $00, $4c, $04, $04, $00, $b0, $04, $06, $00, $14, $05, $08, $00, $78, $05
	db $0a, $00, $dc, $05, $0c, $00, $40, $06, $0e, $00, $a4, $06, $10, $00, $08, $07
	db $12, $00, $6c, $07, $14, $00, $d0, $07, $16, $00, $34, $08, $18, $00, $98, $08
	db $1a, $00, $fc, $08, $1c, $00, $60, $09, $1e, $00, $c4, $09, $20, $00, $28, $0a
	db $22, $00, $8c, $0a, $24, $00, $f0, $0a, $26, $00, $54, $0b, $28, $00, $b8, $0b
	db $2a, $00, $1c, $0c, $2c, $00, $80, $0c, $2e, $00, $e4, $0c, $30, $00, $48, $0d
	db $32, $00, $ac, $0d, $34, $00, $10, $0e, $36, $00, $74, $0e, $38, $00, $d8, $0e
	db $3a, $00, $3c, $0f, $3c, $00, $a0, $0f, $3e, $00, $04, $10, $40, $00, $68, $10
	db $42, $00, $cc, $10, $44, $00, $30, $11, $46, $00, $94, $11, $48, $00, $f8, $11
	db $4a, $00, $5c, $12, $4c, $00, $c0, $12, $4e, $00, $24, $13, $50, $00, $88, $13
	db $52, $00, $ec, $13, $54, $00, $50, $14, $56, $00, $b4, $14, $58, $00, $18, $15
	db $5a, $00, $7c, $15, $5c, $00, $e0, $15, $5e, $00, $44, $16, $60, $00, $a8, $16
	db $62, $00, $0c, $17, $ff, $00, $70, $17

Call_16_6F05::
	ld a, [wFieldFlags]
	bit 2, a
	ret nz

	bit 5, a
	ret nz

	bit 6, a
	ret nz

	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wWorldFlags]
	bit 1, a
	ret nz

	ld a, [wOnGateFloor]
	or a
	jr nz, jr_016_6f39

	ld bc, $0050
	ld a, [wMapId]
	cp $54
	jr z, jr_016_6f62

	cp $55
	jr z, jr_016_6f62

	cp $56
	jr z, jr_016_6f62

	ld bc, $0064
	jr jr_016_6f62

jr_016_6f39:
	ld hl, $6fab
	ld a, [wMapId]
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	jr z, jr_016_6f5f

	inc hl
	inc hl
	cp $0d
	jr z, jr_016_6f5f

	inc hl
	inc hl
	cp $0e
	jr z, jr_016_6f5f

	ret


jr_016_6f5f:
	ld a, [hli]
	ld b, [hl]
	ld c, a

jr_016_6f62:
	push bc
	ld hl, far_SelectFloorTable
	rst $10
	ld hl, $702b
	ld a, [wFloorStyle]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop bc
	call Multiply24
	ld a, $40
	call Divide24
	ld e, l
	ld d, h
	ld a, [$ca39]
	ld l, a
	ld a, [$ca3a]
	ld h, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	jr nc, jr_016_6fa2

	ld hl, far_RollEncounterGroup
	rst $10
	ld hl, wFieldFlags
	set 6, [hl]
	xor a
	ld [wMenuStep], a
	ld a, $00
	ld [wBattleKind], a
	ret


jr_016_6fa2:
	ld a, l
	ld [$ca39], a
	ld a, h
	ld [$ca3a], a
	ret


	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $8a, $00, $8a, $00, $8a, $00, $00, $00
	db $8a, $00, $96, $00, $8a, $00, $00, $00, $8a, $00, $8a, $00, $8c, $00, $00, $00
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $8a, $00, $8a, $00, $8a, $00, $00, $00
	db $8a, $00, $8a, $00, $8c, $00, $00, $00, $8a, $00, $8a, $00, $8a, $00, $00, $00
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $96, $00, $96, $00, $96, $00, $00, $00
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $64, $00, $b4, $00, $fa, $00, $00, $00
	db $64, $00, $b4, $00, $b4, $00, $00, $00, $64, $00, $b4, $00, $fa, $00, $00, $00
	db $64, $00, $b4, $00, $b4, $00, $00, $00, $96, $00, $b4, $00, $96, $00, $00, $00
	db $10, $15, $20, $40, $50, $60, $70, $80

Call_16_7033::
	ld de, $7896
	ld a, [$c93f]
	cp $02
	jr nz, jr_016_7040

	ld de, $7a96

jr_016_7040:
	ld a, [wMapScreen]
	ld hl, $c940
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret


	db $0f, $00, $04, $00, $07, $01, $03, $00, $0b, $02, $03, $00, $0d, $03, $03, $00
	db $0e, $04, $03, $00, $03, $05, $02, $00, $05, $06, $02, $00, $06, $07, $02, $00
	db $09, $08, $02, $00, $0a, $09, $02, $00, $0c, $0a, $02, $00, $08, $0b, $01, $00
	db $04, $0c, $01, $00, $02, $0d, $01, $00, $01, $0e, $01, $00, $00, $0f, $00, $00
	db $ff, $05, $06, $0a, $09, $08, $04, $00, $01, $02, $03, $07, $0b, $0f, $0e, $0d
	db $0c, $00, $00, $00, $05, $30, $07, $02, $01, $01, $01, $01, $05, $31, $01, $06
	db $01, $01, $01, $02, $06, $32, $05, $01, $01, $02, $01, $02, $05, $33, $04, $06
	db $01, $02, $02, $03, $06, $34, $00, $07, $01, $03, $02, $03, $09, $35, $01, $06
	db $01, $03, $02, $04, $08, $36, $05, $01, $02, $03, $03, $04, $09, $37, $05, $07
	db $02, $04, $03, $05, $0c, $38, $08, $03, $02, $04, $04, $05, $0b, $39, $02, $01
	db $02, $04, $04, $05, $0b, $3c, $02, $06, $02, $04, $04, $06, $0c, $10, $08, $05
	db $02, $05, $06, $06, $0e, $3b, $04, $01, $02, $05, $06, $06, $0f, $3a, $01, $07
	db $02, $05, $06, $07, $10, $3d, $04, $07, $02, $06, $07, $07, $12, $3e, $04, $01
	db $03, $07, $07, $08, $14, $3f, $06, $03, $03, $07, $05, $08, $13, $40, $04, $06
	db $03, $08, $08, $09, $17, $42, $04, $06, $03, $08, $09, $09, $19, $43, $05, $05
	db $03, $08, $05, $09, $19, $44, $00, $03, $03, $09, $0a, $0a, $1d, $45, $04, $07
	db $03, $0a, $0b, $0b, $1e, $46, $05, $06, $03, $0a, $0b, $0b, $1d, $47, $05, $06
	db $03, $0a, $0b, $0b, $1b, $48, $04, $07, $03, $0b, $0c, $0c, $1e, $49, $04, $07
	db $03, $0b, $0c, $0c, $1e, $4a, $09, $07, $03, $0b, $0d, $0d, $1e, $4b, $04, $07
	db $03, $0c, $0d, $0d, $1e, $4c, $05, $05, $03, $0d, $0e, $0e, $1b, $4d, $05, $07
	db $03, $0e, $0e, $0e, $1e, $4e, $08, $0c, $03, $0f, $0f, $0f, $63, $4f, $05, $06
	db $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $28, $00, $64, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $28, $00, $00, $00, $64, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $14, $00, $1e, $28, $64, $00
	db $00, $14, $28, $3c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $00, $00, $1e, $3c, $00, $00, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $1e, $3c, $00, $00, $00, $00, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $00, $00, $00, $00, $1e, $3c, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $00, $00, $00, $14, $00, $28, $00, $00, $00, $3c, $00, $64
	db $00, $0a, $14, $1e, $23, $28, $00, $32, $00, $3c, $46, $00, $00, $50, $00, $64
	db $00, $00, $00, $00, $0a, $00, $00, $14, $00, $28, $00, $00, $00, $3c, $00, $50
	db $64, $00, $00, $00, $0a, $00, $00, $14, $00, $28, $00, $3c, $00, $50, $00, $64
	db $00, $0a, $00, $00, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $00, $0a, $00, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $00, $00, $0a, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $05, $0a, $00, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $14, $00, $00, $46, $64, $00, $00, $00, $00, $00, $00, $32, $64, $00, $00
	db $00, $28, $00, $00, $46, $64, $00, $00, $00, $00, $00, $00, $1e, $3c, $00, $64
	db $00, $00, $00, $28, $46, $64, $00, $00, $00, $00, $00, $00, $2d, $4b, $64, $00
	db $00, $00, $00, $00, $1e, $3c, $00, $00, $64, $0f, $14, $1e, $3c, $5a, $64, $00
	db $00, $0f, $14, $00, $32, $50, $00, $5a, $64, $1e, $00, $2d, $3c, $4b, $5a, $5f
	db $64, $0a, $1e, $28, $37, $46, $50, $5a, $64, $05, $19, $28, $2d, $32, $3c, $50
	db $64, $05, $1e, $28, $32, $37, $46, $50, $64, $05, $23, $32, $3c, $41, $50, $5a
	db $64, $05, $23, $32, $46, $4b, $5a, $5f, $64, $05, $19, $23, $2d, $37, $50, $5a
	db $64, $64, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02, $00, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $64, $00, $02, $04, $0a, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5f, $64, $02, $04, $0a, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5f, $64, $02, $04, $0a, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $06, $1e, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $06, $1e, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $06, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $46, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $02, $1e, $00, $00, $00
	db $00, $01, $01, $01, $01, $01, $01, $01, $00, $ff, $01, $01, $01, $01, $01, $01
	db $01, $00, $5d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $62, $63
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $33, $00
	db $34, $35, $00, $00, $53, $58, $5b, $00, $00, $00, $00, $00, $00, $00, $60, $61
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $33
	db $00, $00, $34, $35, $53, $58, $5b, $00, $00, $00, $00, $00, $00, $00, $60, $61
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $24, $2a, $00, $00, $00, $00, $2c, $2e, $30, $32, $34, $00, $35, $00
	db $36, $37, $00, $00, $4f, $54, $57, $00, $00, $00, $5a, $5b, $00, $00, $60, $61
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $16, $20, $00, $00, $25, $00, $2a, $2c, $2e, $30, $32, $00, $00, $33
	db $00, $00, $34, $35, $49, $4e, $51, $52, $53, $00, $56, $58, $59, $00, $5e, $5f
	db $00, $00, $00, $00, $00, $00, $00, $00, $61, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $11, $25, $00, $00, $29, $2a, $2f, $31, $33, $35, $37, $38, $39, $00
	db $3a, $3b, $00, $00, $40, $4f, $52, $53, $54, $55, $00, $57, $59, $00, $5d, $5e
	db $00, $00, $00, $00, $00, $00, $00, $00, $61, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $02, $1b, $00, $20, $23, $24, $29, $2b, $2d, $2f, $31, $32, $00, $33
	db $00, $00, $34, $35, $00, $49, $53, $54, $55, $56, $00, $58, $00, $59, $5c, $5d
	db $00, $00, $00, $00, $00, $00, $00, $00, $61, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $1f, $00, $24, $26, $28, $2a, $2c, $2e, $30, $32, $33, $34, $00
	db $35, $00, $00, $00, $00, $44, $53, $54, $55, $56, $00, $58, $00, $59, $5b, $5c
	db $00, $00, $00, $00, $00, $00, $00, $00, $60, $61, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $1b, $00, $20, $21, $24, $26, $28, $2a, $2c, $2e, $2f, $30, $00
	db $00, $31, $32, $33, $00, $3d, $51, $53, $55, $56, $00, $58, $00, $59, $5b, $5c
	db $00, $00, $00, $00, $00, $00, $00, $00, $60, $61, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $12, $00, $17, $00, $1b, $1d, $1f, $21, $23, $25, $26, $27, $28
	db $00, $29, $2a, $2b, $00, $30, $49, $4b, $4e, $4f, $00, $50, $00, $52, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $12, $00, $17, $00, $1b, $1d, $1f, $21, $23, $25, $26, $27, $00
	db $28, $29, $2a, $2b, $00, $00, $49, $4b, $4e, $4f, $00, $50, $00, $52, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1b, $1e, $20, $22, $24, $25, $00, $26
	db $28, $00, $29, $00, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1c, $1e, $20, $22, $24, $25, $26, $00
	db $00, $27, $00, $29, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1c, $1e, $20, $22, $24, $25, $00, $27
	db $28, $00, $29, $00, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1c, $1e, $20, $22, $24, $25, $26, $00
	db $00, $28, $00, $29, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $0f, $00, $14, $00, $18, $1a, $1c, $1e, $20, $22, $23, $24, $25
	db $26, $27, $28, $29, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $60, $10, $10, $70, $30, $00, $00, $40, $30, $00, $00, $40, $80, $20, $20
	db $90, $60, $70, $60, $70, $30, $40, $30, $40, $30, $40, $30, $40, $80, $22, $23
	db $90, $60, $70, $60, $70, $80, $0c, $0d, $90, $60, $0b, $0a, $70, $80, $90, $80
	db $90, $60, $70, $60, $70, $30, $40, $33, $90, $30, $40, $31, $70, $80, $22, $23
	db $90, $60, $70, $60, $70, $30, $40, $80, $42, $30, $07, $10, $41, $80, $20, $20
	db $90, $61, $72, $61, $72, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $b0, $82, $92
	db $b0, $64, $50, $50, $74, $a0, $f0, $f0, $a0, $a0, $f0, $f0, $a0, $84, $50, $50
	db $94, $64, $50, $12, $74, $a0, $60, $41, $a0, $a0, $80, $90, $a0, $84, $50, $50
	db $94, $64, $16, $16, $74, $36, $01, $01, $46, $36, $01, $01, $46, $84, $26, $26
	db $94, $64, $50, $50, $74, $84, $50, $50, $45, $64, $50, $50, $44, $84, $50, $50
	db $94, $64, $14, $15, $74, $35, $94, $84, $45, $34, $74, $64, $44, $84, $24, $25
	db $94, $64, $16, $16, $74, $35, $26, $26, $94, $34, $16, $16, $74, $84, $26, $26
	db $94, $64, $12, $50, $74, $a0, $34, $74, $a0, $a0, $84, $94, $a0, $84, $50, $50
	db $94, $60, $10, $70, $c0, $30, $00, $40, $a0, $80, $20, $42, $a0, $e0, $50, $21
	db $94, $60, $70, $e0, $74, $30, $07, $11, $43, $30, $08, $90, $a0, $80, $90, $e0
	db $94, $e0, $71, $c0, $c0, $64, $21, $45, $a0, $a0, $64, $21, $45, $b0, $b0, $e0
	db $91, $f0, $64, $74, $f0, $64, $94, $84, $74, $84, $74, $64, $94, $f0, $84, $94
	db $f0, $64, $16, $16, $74, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $84, $26, $26
	db $94, $e0, $71, $62, $d0, $61, $0a, $0b, $72, $b0, $33, $42, $b0, $e0, $91, $81
	db $d0, $64, $71, $62, $74, $a0, $31, $41, $a0, $a0, $33, $42, $a0, $84, $91, $81
	db $94, $64, $71, $62, $74, $b0, $a1, $a1, $b0, $62, $94, $84, $71, $81, $51, $52
	db $91, $00, $0d, $0d, $0d, $0d, $0d, $1a, $1a, $1a, $1a, $1a, $26, $26, $26, $26
	db $26, $10, $28, $11, $28, $12, $28, $13, $28, $14, $28, $15, $28, $00, $2b, $01
	db $2b, $02, $2b, $03, $2b, $04, $2b, $05, $2b, $14, $2c, $10, $28, $10, $28, $10
	db $28, $16, $28, $17, $28, $18, $28, $19, $28, $1a, $28, $1b, $28, $06, $2b, $07
	db $2b, $08, $2b, $09, $2b, $0a, $2b, $0b, $2b, $15, $2c, $10, $28, $10, $28, $10
	db $28, $00, $27, $01, $27, $02, $27, $03, $27, $04, $27, $05, $27, $0c, $2b, $0d
	db $2b, $0e, $2b, $0f, $2b, $10, $2b, $11, $2b, $16, $2c, $10, $28, $10, $28, $10
	db $28, $06, $27, $07, $27, $08, $27, $09, $27, $0a, $27, $0b, $27, $12, $2b, $13
	db $2b, $14, $2b, $15, $2b, $16, $2b, $17, $2b, $17, $2c, $10, $28, $10, $28, $10
	db $28, $0c, $27, $0d, $27, $0e, $27, $0f, $27, $10, $27, $11, $27, $18, $2b, $19
	db $2b, $1a, $2b, $1b, $2b, $1c, $2b, $1d, $2b, $18, $2c, $10, $28, $10, $28, $10
	db $28, $12, $27, $13, $27, $14, $27, $15, $27, $16, $27, $17, $27, $1e, $2b, $1f
	db $2b, $20, $2b, $21, $2b, $22, $2b, $23, $2b, $19, $2c, $10, $28, $10, $28, $10
	db $28, $18, $27, $19, $27, $1a, $27, $1b, $27, $1c, $27, $1d, $27, $24, $2b, $25
	db $2b, $26, $2b, $27, $2b, $28, $2b, $29, $2b, $1a, $2c, $10, $28, $10, $28, $10
	db $28, $1e, $27, $1f, $27, $20, $27, $21, $27, $22, $27, $23, $27, $2a, $2b, $2b
	db $2b, $2c, $2b, $2d, $2b, $2e, $2b, $2f, $2b, $1b, $2c, $10, $28, $10, $28, $10
	db $28, $24, $27, $25, $27, $26, $27, $27, $27, $28, $27, $29, $27, $30, $2b, $31
	db $2b, $32, $2b, $33, $2b, $34, $2b, $35, $2b, $1c, $2c, $10, $28, $10, $28, $10
	db $28, $2a, $27, $2b, $27, $2c, $27, $2d, $27, $2e, $27, $2f, $27, $36, $2b, $37
	db $2b, $38, $2b, $39, $2b, $3a, $2b, $3b, $2b, $1d, $2c, $10, $28, $10, $28, $10
	db $28, $30, $27, $31, $27, $32, $27, $33, $27, $34, $27, $35, $27, $3c, $2b, $3d
	db $2b, $3e, $2b, $3f, $2b, $40, $2b, $41, $2b, $1e, $2c, $10, $28, $10, $28, $10
	db $28, $36, $27, $37, $27, $38, $27, $39, $27, $3a, $27, $3b, $27, $42, $2b, $43
	db $2b, $44, $2b, $45, $2b, $46, $2b, $47, $2b, $1f, $2c, $10, $28, $10, $28, $10
	db $28, $3c, $27, $3d, $27, $3e, $27, $3f, $27, $40, $27, $41, $27, $02, $2c, $03
	db $2c, $04, $2c, $05, $2c, $06, $2c, $07, $2c, $20, $2c, $10, $28, $10, $28, $10
	db $28, $42, $27, $43, $27, $44, $27, $45, $27, $46, $27, $47, $27, $08, $2c, $09
	db $2c, $0a, $2c, $0b, $2c, $0c, $2c, $0d, $2c, $21, $2c, $10, $28, $10, $28, $10
	db $28, $48, $27, $49, $27, $4a, $27, $4b, $27, $4c, $27, $4d, $27, $0e, $2c, $0f
	db $2c, $10, $2c, $11, $2c, $12, $2c, $13, $2c, $22, $2c, $10, $28, $10, $28, $10
	db $28, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $23, $2c, $24, $2c, $25, $2c, $26, $2c, $27, $2c, $28, $2c, $29, $2c, $2a
	db $2c, $2b, $2c, $2c, $2c, $2d, $2c, $2e, $2c, $2f, $2c, $30, $2c, $23, $2c, $23
	db $2c, $00, $3b, $01, $3b, $02, $3b, $03, $3b, $04, $3b, $05, $3b, $06, $3b, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $07, $3b, $08, $3b, $09, $3b, $0a, $3b, $0b, $3b, $0c, $3b, $0d, $3b, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $0e, $3b, $0f, $3b, $10, $3b, $11, $3b, $12, $3b, $13, $3b, $14, $3b, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $37, $3a, $38, $3a, $39, $3a, $3a, $3a, $3b, $3a, $3c, $3a, $3d, $3a, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $3e, $3a, $3f, $3a, $40, $3a, $41, $3a, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $42, $3a, $43, $3a, $44, $3a, $45, $3a, $46, $3a, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $47, $3a, $48, $3a, $49, $3a, $4a, $3a, $4b, $3a, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $4c, $3a, $4d, $3a, $4e, $3a, $4f, $3a, $50, $3a, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $15, $3b, $16, $3b, $17, $3b, $18, $3b, $19, $3b, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $1a, $3b, $1b, $3b, $1c, $3b, $1d, $3b, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $1e, $3b, $1f, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $20, $3b, $21, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $22, $3b, $23, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $24, $3b, $25, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
