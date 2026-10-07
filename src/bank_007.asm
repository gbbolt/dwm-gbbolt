INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $007", ROMX[$4000], BANK[$7]

BankNumber_07::
	db $07

FarTable_07::
	dw Call_07_4009
	dw Call_07_6456
	dw Call_07_6468
	dw Call_07_56E8

Call_07_4009::
	ld a, [$c90d]
	rst $00

JumpTable_07_400D::
	dw Jump_07_6AAF
	dw Jump_07_4017
	dw Jump_07_43C8
	dw Jump_07_44A8
	dw Jump_07_6B04

Jump_07_4017::
	ld hl, $c90d
	inc [hl]
	call Call_07_6A8F
	call Call_07_402B
	call Call_07_690D
	call Call_07_405C
	call Call_07_690D
	ret


Call_07_402B::
	ld de, $704d
	call Call_07_68DC
	ld de, $7090
	call Call_07_68DC
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_07_6880
	call Call_1FB9
	call Call_07_6C8F
	ld de, $44b4
	ld a, [$c8da]
	call Call_07_6D4E
	ret


Call_07_405C::
	ld a, [$ca8d]
	or a
	jr z, jr_007_40c4

	ld a, $00
	ld hl, $caca
	call Call_224A
	ld hl, $95c0
	call Call_07_43AB
	ld a, $00
	ld hl, $caca
	call Call_224A
	ld hl, $8500
	call Call_07_66B1
	ld a, [$ca8d]
	cp $01
	jr z, jr_007_40c4

	ld a, $01
	ld hl, $caca
	call Call_224A
	ld hl, $8800
	call Call_07_43AB
	ld a, $01
	ld hl, $caca
	call Call_224A
	ld hl, $8600
	call Call_07_66B1
	ld a, [$ca8d]
	cp $02
	jr z, jr_007_40c4

	ld a, $02
	ld hl, $caca
	call Call_224A
	ld hl, $8a40
	call Call_07_43AB
	ld a, $02
	ld hl, $caca
	call Call_224A
	ld hl, $8700
	call Call_07_66B1

jr_007_40c4:
	call Call_07_4469
	call Call_07_4226
	ld a, [$ca8d]
	or a
	ret z

	ld a, $5c
	ld hl, $00e1
	call Call_07_4154
	ld a, $20
	ld hl, $01c1
	call Call_07_4173
	ld hl, $00e1
	ld a, $00
	call Call_07_4181
	ld a, $00
	ld hl, $9590
	call Call_07_41AA
	ld hl, $01e1
	ld a, $00
	call Call_07_41B7
	ld a, [$ca8d]
	cp $01
	ret z

	ld a, $80
	ld hl, $00e7
	call Call_07_4154
	ld a, $24
	ld hl, $01c7
	call Call_07_4173
	ld hl, $00e7
	ld a, $01
	call Call_07_4181
	ld a, $01
	ld hl, $95a0
	call Call_07_41AA
	ld hl, $01e7
	ld a, $01
	call Call_07_41B7
	ld a, [$ca8d]
	cp $02
	ret z

	ld a, $a4
	ld hl, $00ed
	call Call_07_4154
	ld a, $28
	ld hl, $01cd
	call Call_07_4173
	ld hl, $00ed
	ld a, $02
	call Call_07_4181
	ld a, $02
	ld hl, $95b0
	call Call_07_41AA
	ld hl, $01ed
	ld a, $02
	call Call_07_41B7
	ret


Call_07_4154::
	ld c, a
	ld a, [$c92f]
	or a
	ret nz

	ld a, c
	ld c, $06

jr_007_415d:
	push hl
	push af
	call Call_07_6880
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


Call_07_4173::
	push af
	call Call_07_6880
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


Call_07_4181::
	push af
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	pop af
	push af
	ld hl, $caca
	call Call_2229
	ld a, [hl]
	ld [$c81e], a
	pop af
	add $04
	ld [$c81f], a
	ld a, [$c92f]
	or a
	ret nz

	ld hl, far_Call_17_41D0
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ret


Call_07_41AA::
	push hl
	ld hl, $cacc
	call Call_2229
	ld a, [hl]
	pop hl
	call Call_07_6A3D
	ret


Call_07_41B7::
	push hl
	ldh [$ffd5], a
	call Call_07_6880
	ld a, $de
	ld [hli], a
	ld a, $df
	ld [hli], a
	ld a, $e4
	ld [hli], a
	ldh a, [$ffd5]
	add $59
	inc hl
	inc hl
	ld [hld], a
	dec hl
	push hl
	ld hl, $cb0c
	ldh a, [$ffd5]
	call Call_224A
	pop hl
	ld c, a
	ld b, $00
	call Call_07_7007
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	push hl
	call Call_07_6880
	ld a, $e0
	ld [hli], a
	ld a, $e1
	ld [hli], a
	ld a, $e4
	ld [hli], a
	push hl
	ld hl, $cb11
	ldh a, [$ffd5]
	call Call_224F
	pop hl
	call Call_07_6FE2
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	push hl
	call Call_07_6880
	ld a, $e0
	ld [hli], a
	ld a, $e2
	ld [hli], a
	ld a, $e4
	ld [hli], a
	push hl
	ld hl, $cb15
	ldh a, [$ffd5]
	call Call_224F
	pop hl
	call Call_07_6FE2
	pop hl
	ret


Call_07_4226::
	ld a, [$c92f]
	or a
	ret z

	ld a, $59
	ld [$c823], a
	ld a, $02
	ld [$c822], a
	ld hl, $95c0
	ld de, $1401
	call Call_07_69B6
	ld de, $ca42
	ld hl, $93c0
	call Call_07_69EF
	ld de, $7cee
	call Call_07_68DC
	ld b, $00
	ld c, $00

jr_007_4251:
	push bc
	ld hl, $ca94
	ld a, b
	call Call_267E
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
	call Call_07_6880
	call Call_2071
	ld a, [$cab8]
	ld c, a
	ld b, $00
	ld hl, $00ae
	call Call_07_6880
	call Call_20AD
	ld a, [$cab7]
	ld c, a
	ld b, $00
	ld hl, $00b1
	call Call_07_6880
	call Call_20AD
	call Call_07_42B4
	ret


Call_07_4290::
	ld a, [$c92f]
	or a
	ret z

	ld a, [$cab8]
	ld c, a
	ld b, $00
	ld hl, $00ae
	call Call_07_6889
	call Call_20AD
	ld a, [$cab7]
	ld c, a
	ld b, $00
	ld hl, $00b1
	call Call_07_6889
	call Call_20AD
	ret


Call_07_42B4::
	ld hl, HeaderOldLicenseeCode
	call Call_07_42CD
	ld hl, $0151
	call Call_07_4301
	ld hl, $016b
	call Call_07_4331
	ld hl, $0171
	call Call_07_436E
	ret


Call_07_42CD::
	call Call_07_6880
	push hl
	ld de, $cac1
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
	call Call_2082
	ret


Call_07_4301::
	call Call_07_6880
	push hl
	ld de, $cac1
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
	call Call_2082
	ret


Call_07_4331::
	call Call_07_6880
	ld c, $00
	ld a, [$ca41]
	bit 7, a
	jr z, jr_007_4368

	push hl
	ld hl, $b124
	ld b, $14
	ld c, $00

jr_007_4345:
	push hl
	call Call_20EE
	or a
	jr z, jr_007_435b

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_20EE
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
	call Call_2082
	ret


Call_07_436E::
	call Call_07_6880
	ld c, $00
	ld a, [$ca41]
	bit 7, a
	jr z, jr_007_43a5

	push hl
	ld hl, $b124
	ld b, $14
	ld c, $00

jr_007_4382:
	push hl
	call Call_20EE
	or a
	jr z, jr_007_4398

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_20EE
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
	call Call_2082
	ret


Call_07_43AB::
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
	ld a, [$c92f]
	or a
	ret nz

	call Call_1577
	ret


Jump_07_43C8::
	call Call_07_4290
	ld hl, $c8da
	res 7, [hl]
	ld a, [$c846]
	and $30
	jr z, jr_007_43e1

	ld a, [$c8da]
	xor $01
	ld [$c8da], a
	jr jr_007_43f0

jr_007_43e1:
	ld a, [$c846]
	and $c0
	jr z, jr_007_43f6

	ld a, [$c8da]
	xor $02
	ld [$c8da], a

jr_007_43f0:
	xor a
	ld [$c914], a
	jr jr_007_445c

jr_007_43f6:
	ld a, [$c846]
	and $08
	jr z, jr_007_441b

	ld a, [$c92f]
	xor $01
	ld [$c92f], a
	ld hl, $c5a0
	ld bc, $0100
	ld a, $e0
	call Call_12C7
	call Call_07_690D
	call Call_07_405C
	call Call_07_690D
	jr jr_007_445c

jr_007_441b:
	ld a, [$c846]
	and $06
	jr z, jr_007_442c

	ld hl, $c90d
	inc [hl]
	ld hl, $c90d
	inc [hl]
	jr jr_007_445c

jr_007_442c:
	ld a, [$c846]
	bit 0, a
	jr z, jr_007_445c

	ld a, $59
	call Call_1B2C
	ld hl, $c90d
	inc [hl]
	call Call_07_6A8F
	call Call_07_402B
	call Call_07_690D
	xor a
	ld [$c90e], a
	ld hl, $c8da
	set 7, [hl]
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	call Call_07_4469

jr_007_445c:
	ld de, $44b4
	ld a, [$c8da]
	call Call_07_6C94
	call Call_07_6779
	ret


Call_07_4469::
	ld hl, $9200
	ld a, $01
	call Call_07_4482
	ld hl, $9240
	ld a, $02
	call Call_07_4482
	ld hl, $9280
	ld a, $03
	call Call_07_4482
	ret


Call_07_4482::
	ld b, a
	ld a, [$ca8d]
	cp b
	jr nc, jr_007_4498

	ld b, $20

jr_007_448b:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_007_448b

	ret


jr_007_4498:
	push hl
	ld a, b
	dec a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	pop hl
	call Call_07_69EF
	ret


Jump_07_44A8::
	ld a, [$c8da]
	rst $00

JumpTable_07_44AC::
	dw Jump_07_44BE
	dw Jump_07_4A8A
	dw Jump_07_5362
	dw Jump_07_5C94
	dw $0021
	dw $0026
	dw $0061
	dw $0066
	dw $ffff

Jump_07_44BE::
	ld a, [$c90e]
	rst $00

JumpTable_07_44C2::
	dw Jump_07_44E0
	dw Jump_07_45FB
	dw Call_07_4655
	dw Jump_07_46AB
	dw Jump_07_46B0
	dw Jump_07_46B9
	dw Call_07_46CA
	dw Jump_07_47FE
	dw Jump_07_4830
	dw Jump_07_48AB
	dw Call_07_48E6
	dw Jump_07_4A12
	dw Jump_07_4A5A
	dw Jump_07_4A66
	dw Jump_07_4A78

Jump_07_44E0::
	call Call_07_4469

Call_07_44E3::
	ld de, $70ad
	call Call_07_68DC
	ld de, $70f7
	call Call_07_68DC
	ld de, $71af
	call Call_07_68DC
	ld a, [$c8db]
	ld [$cac0], a
	call Call_07_466D
	call Call_07_4689
	ld de, $724f
	call Call_07_68DC
	call Call_07_451E
	call Call_07_6C8F
	ld de, $4632
	ld a, [$c8db]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_451E::
	call Call_07_45EE
	ld hl, $cac2
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $93c0
	call Call_07_69EF
	ld hl, $cacc
	call Call_07_6DBA
	ld hl, $9300
	call Call_07_6A3D
	ld hl, $cb0c
	call Call_07_6DBA
	push af
	ld hl, $cb0d
	call Call_07_6DA8
	pop af
	cp [hl]
	ld a, $90
	jr c, jr_007_4550

	ld a, $ac

jr_007_4550:
	ld hl, $8800
	call Call_07_6A41
	ld hl, $cb0c
	call Call_07_6DBA
	ld c, a
	ld b, $00
	ld hl, $0031
	call Call_07_6880
	call Call_2082
	ld hl, $cb19
	ld de, $0070
	call Call_07_45E2
	ld hl, $cb1b
	ld de, $00b0
	call Call_07_45E2
	ld hl, $cb1d
	ld de, $00f0
	call Call_07_45E2
	ld hl, $cb1f
	ld de, $0130
	call Call_07_45E2
	ld hl, $cb21
	ld de, $0170
	call Call_07_45E2
	ld hl, $cb11
	ld de, $01cc
	call Call_07_45E2
	ld hl, $cb13
	ld de, $01d0
	call Call_07_45E2
	ld hl, $cb15
	ld de, $020c
	call Call_07_45E2
	ld hl, $cb17
	ld de, $0210
	call Call_07_45E2
	ld hl, $cb0b
	call Call_07_6DBA
	ld b, a
	ld hl, $01f0
	call Call_07_6880
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


Call_07_45E2::
	push de
	call Call_07_6DCD
	pop hl
	call Call_07_6880
	call Call_2071
	ret


Call_07_45EE::
	ld a, [$c8eb]
	bit 1, a
	ret z

	ld a, [$c8db]
	ld [$cac0], a
	ret


Jump_07_45FB::
	call Call_07_463A
	jr z, jr_007_460f

	call Call_07_45EE
	call Call_07_451E
	call Call_07_690D
	call Call_07_466D
	call Call_07_4689

jr_007_460f:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_4620

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	jr jr_007_4631

jr_007_4620:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_4631

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_4631:
jr_007_4631:
	ret


	db $61, $00, $a1, $00, $e1, $00, $ff, $ff

Call_07_463A::
	ld de, $4632
	ld hl, $c8db
	ld a, [$ca8d]
	ld b, a
	ld a, [hl]
	push af
	call Call_07_6C3F
	pop af
	ld hl, $c8db
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	ret


Call_07_4655::
	call Call_07_466D
	call Call_07_4689
	ld de, $724f
	call Call_07_68DC
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	xor a
	ld [$c90f], a
	ret


Call_07_466D::
	ld hl, $caca
	call Call_07_6DBA
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
	call Call_1577
	ret


Call_07_4689::
	ld hl, $0141
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld hl, $caca
	call Call_07_6DBA
	ld [$c81e], a
	ld a, $04
	ld [$c81f], a
	ld hl, far_Call_17_41D0
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ret


Jump_07_46AB::
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_46B0::
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_46B9::
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ret


Call_07_46CA::
	call Call_07_46D2
	ld hl, $c90e
	inc [hl]
	ret


Call_07_46D2::
	call Call_07_45EE
	ld hl, $cac2
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $93c0
	call Call_07_69EF
	ld hl, $cacc
	call Call_07_6DBA
	ld hl, $9300
	call Call_07_6A3D
	ld hl, $cb0c
	call Call_07_6DBA
	push af
	ld hl, $cb0d
	call Call_07_6DA8
	pop af
	cp [hl]
	ld a, $90
	jr c, jr_007_4704

	ld a, $ac

jr_007_4704:
	ld hl, $8800
	call Call_07_6A41
	call Call_07_6D8B
	ld d, a
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	ld [$c823], a
	ld a, $0a
	ld [$c822], a
	ld hl, $9330
	ld de, $0901
	call Call_07_69B6
	ld hl, $cacb
	call Call_07_6DBA
	ld c, a
	push bc
	ld hl, $cb23
	call Call_07_6DBA
	ld hl, $95b0
	pop bc
	call Call_07_6942
	ld hl, $caca
	call Call_07_6DBA
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld hl, $94c0
	ld de, $0901
	call Call_07_69B6
	ld hl, $cacd
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $9550
	call Call_07_69EF
	ld de, $727b
	call Call_07_68DC
	ld de, $7333
	call Call_07_68DC
	ld hl, $cb0c
	call Call_07_6DBA
	ld c, a
	ld b, $00
	ld hl, $0031
	call Call_07_6880
	call Call_2082
	ld hl, $cb0e
	call Call_07_6DA8
	ld a, [hli]
	ldh [$ffd5], a
	ld a, [hli]
	ldh [$ffd6], a
	ld a, [hl]
	ldh [$ffd7], a
	ld hl, $016b
	call Call_07_6880
	call Call_1F90
	ld hl, $cb0e
	call Call_07_6DA8
	ld a, [hli]
	ldh [$ffd5], a
	ld a, [hli]
	ldh [$ffd6], a
	ld a, [hl]
	ldh [$ffd7], a
	ld a, [$cac0]
	push af
	call Call_07_6D8B
	ld [$cac0], a
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $63
	jr z, jr_007_47ca

	push af
	ld a, [$cac0]
	ld hl, $cb0d
	call Call_223B
	pop af
	cp [hl]
	jr z, jr_007_47ca

	ld hl, far_Call_13_4009
	rst $10

jr_007_47ca:
	pop af
	ld [$cac0], a
	ld hl, $cb0e
	call Call_07_6DA8
	ldh a, [$ffd5]
	sub [hl]
	inc hl
	ldh [$ffd5], a
	ldh a, [$ffd6]
	sbc [hl]
	inc hl
	ldh [$ffd6], a
	ldh a, [$ffd7]
	sbc [hl]
	ldh [$ffd7], a
	ld hl, $020b
	call Call_07_6880
	call Call_1F90
	call Call_07_690D
	ld hl, $caca
	call Call_07_6DBA
	ld hl, $8500
	call Call_07_66B1
	ret


Jump_07_47FE::
	call Call_07_463A
	jr z, jr_007_480a

	ld a, $0d
	ld [$c90e], a
	jr jr_007_482f

jr_007_480a:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_481b

	call Call_07_44E3
	ld a, $01
	ld [$c90e], a
	jr jr_007_482f

jr_007_481b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_482c

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_482c:
	call Call_07_66C8

jr_007_482f:
	ret


Jump_07_4830::
	ld de, $71f7
	call Call_07_68A0
	call Call_07_486B
	ld de, $737b
	call Call_07_68DC
	call Call_07_690D
	ld hl, $caca
	call Call_07_6DBA
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
	call Call_1577
	ld de, $724f
	call Call_07_68DC
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_486B::
	ld hl, $caea
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $9650
	call Call_07_488E
	call Call_07_488E
	call Call_07_488E
	ld hl, $8830
	call Call_07_488E
	call Call_07_488E
	call Call_07_488E
	call Call_07_488E

Call_07_488E::
	push de
	push hl
	ld a, [de]
	ld [$c823], a
	ld a, $06
	ld [$c822], a
	ld de, $0901
	call Call_07_69B6
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


Jump_07_48AB::
	call Call_07_463A
	jr z, Call_07_48BF

	call Call_07_45EE
	call Call_07_486B
	call Call_07_690D
	call Call_07_466D
	call Call_07_4689

Call_07_48BF::
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_48d4

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_48e5

jr_007_48d4:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_48e5

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_48e5:
jr_007_48e5:
	ret


Call_07_48E6::
	ld de, $746b
	call Call_07_68DC
	call Call_07_690D
	call Call_07_48F7
	ld hl, $c90e
	inc [hl]
	ret


Call_07_48F7::
	ld hl, $cb44
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $88c0
	call Call_07_69EF
	ld hl, $cad8
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $8900
	call Call_07_69EF
	ld hl, $cad6
	call Call_07_6DBA
	cp $ff
	jr z, jr_007_4927

	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld a, [$da33]

jr_007_4927:
	ld c, a
	push bc
	ld hl, $cb4c
	call Call_07_6DBA
	ld hl, $95e0
	pop bc
	call Call_07_6942
	ld hl, $cad6
	call Call_07_6DBA
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld hl, $94c0
	ld de, $0901
	call Call_07_69A5
	ld hl, $cb4d
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $8940
	call Call_07_69EF
	ld hl, $cae1
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $8980
	call Call_07_69EF
	ld hl, $cad7
	call Call_07_6DBA
	cp $ff
	jr z, jr_007_497d

	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld a, [$da33]

jr_007_497d:
	ld c, a
	push bc
	ld hl, $cb55
	call Call_07_6DBA
	ld hl, $9660
	pop bc
	call Call_07_6942
	ld hl, $cad7
	call Call_07_6DBA
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld hl, $9550
	ld de, $0901
	call Call_07_69A5
	ld de, $755b
	call Call_07_68DC
	ld de, $75db
	call Call_07_68DC
	call Call_07_690D
	ld hl, $cad7
	call Call_07_6DBA
	cp $ff
	jr nz, jr_007_49c6

	ld de, $7223
	call Call_07_68DC
	call Call_07_690D
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
	call Call_07_68DC
	ld de, $765b
	call Call_07_68DC
	call Call_07_690D
	ld hl, $cad6
	call Call_07_6DBA
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
	ld hl, $cad6
	call Call_07_6DBA
	ld hl, $8600
	call Call_07_66B1
	ld hl, $cad7
	call Call_07_6DBA
	ld hl, $8700
	call Call_07_66B1
	ret


Jump_07_4A12::
	call Call_07_463A
	jr z, Call_07_4A1E

	ld a, $0e
	ld [$c90e], a
	jr jr_007_4a59

Call_07_4A1E::
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_4a45

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld de, $71f7
	call Call_07_68DC
	call Call_07_690D
	ld de, $746b
	call Call_07_68DC
	call Call_07_690D
	jr jr_007_4a59

jr_007_4a45:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_4a56

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_4a56:
	call Call_07_670E

jr_007_4a59:
	ret


Jump_07_4A5A::
	call Call_07_6A8F
	call Call_07_690D
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_4A66::
	call Call_07_45EE
	call Call_07_46D2
	call Call_07_466D
	call Call_07_4689
	ld a, $07
	ld [$c90e], a
	ret


Jump_07_4A78::
	call Call_07_45EE
	call Call_07_48F7
	call Call_07_466D
	call Call_07_4689
	ld a, $0b
	ld [$c90e], a
	ret


Jump_07_4A8A::
	ld a, [$c90e]
	rst $00

JumpTable_07_4A8E::
	dw Jump_07_4AB0
	dw Jump_07_4AC8
	dw Jump_07_4BB2
	dw Jump_07_4C61
	dw Jump_07_4CCF
	dw Jump_07_4D51
	dw Jump_07_4EAC
	dw Jump_07_4EFD
	dw Jump_07_4F81
	dw Jump_07_4FA7
	dw Jump_07_5205
	dw Jump_07_5213
	dw Jump_07_5214
	dw Jump_07_5265
	dw Jump_07_527A
	dw Jump_07_52C5
	dw Jump_07_5337

Jump_07_4AB0::
	call Call_07_4B69
	call Call_07_4B21
	ld hl, $c90e
	inc [hl]
	call Call_07_4B99
	ld a, [$c90f]
	or a
	ret nz

	ld a, $0c
	ld [$c90e], a
	ret


Jump_07_4AC8::
	call Call_07_4B99
	call Call_07_6A8F
	ld de, $704d
	call Call_07_68DC
	ld de, $7090
	call Call_07_68DC
	ld de, $7748
	call Call_07_68DC
	ld de, $77d9
	call Call_07_68DC
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_07_6880
	call Call_1FB9
	call Call_07_6C8F
	ld de, $44b4
	ld a, [$c8da]
	call Call_07_6D4E
	ld de, $4c53
	ld b, $05
	ld a, [$c90f]
	ld c, a
	ld hl, $c8db
	call Call_07_6D2C
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_4B21::
	ld de, $ca51
	ld a, [$c8dc]
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
	call Call_07_4B46
	ld hl, $8800
	call Call_07_4B46
	call Call_07_4B46
	call Call_07_4B46
	call Call_07_4B46

Call_07_4B46::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_007_4b4f

	ld a, $00

jr_007_4b4f:
	ld [$c823], a
	ld a, $08
	ld [$c822], a
	ld de, $0901
	call Call_07_69B6
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


Call_07_4B69::
	ld hl, $ca51
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
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
	ld [$c823], a
	ld a, $09
	ld [$c822], a
	ld hl, $94c0
	ld de, $1202
	call Call_07_69B6
	ret


Call_07_4B99::
	ld hl, $ca51
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
	ld [$c90f], a
	ret


Jump_07_4BB2::
	ld de, $4c53
	ld hl, $c8db
	ld a, [$c90f]
	ld c, a
	ld b, $05
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_07_6B7F
	pop af
	ld hl, $c8db
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_4bd6

	call Call_07_4B69

jr_007_4bd6:
	pop af
	ld hl, $c8dc
	cp [hl]
	jr z, jr_007_4be3

	call Call_07_4B21
	call Call_07_4B69

jr_007_4be3:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_4bf4

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	jr jr_007_4c27

jr_007_4bf4:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_4c07

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]
	jr jr_007_4c27

Jump_007_4c07:
	ld a, [$c846]
	bit 2, a
	jp z, Jump_007_4c27

	ld a, $59
	call Call_1B2C
	call Call_07_4C28
	xor a
	ld [$c8db], a
	ld [$c8dc], a
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ret


Jump_007_4c27:
jr_007_4c27:
	ret


Call_07_4C28::
	ld hl, $ca51
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
	ld hl, $ca51
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


	db $91, $01, $69, $00, $a9, $00, $e9, $00, $29, $01, $69, $01, $ff, $ff

Jump_07_4C61::
	call Call_07_6A8F
	call Call_07_6C8F
	ld de, $704d
	call Call_07_68DC
	ld de, $44b4
	ld a, [$c8da]
	call Call_07_6D4E
	ld de, $7090
	call Call_07_68DC
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_07_6880
	call Call_1FB9
	ld de, $7748
	call Call_07_68DC
	ld de, $4c53
	ld b, $05
	ld a, [$c90f]
	ld c, a
	ld hl, $c8db
	call Call_07_6D2C
	ld de, $77d9
	call Call_07_68DC
	ld de, $798b
	call Call_07_68DC
	ld de, $4d4b
	ld a, [$c8dd]
	call Call_07_6D4E
	call Call_07_690D
	ld de, $560b
	ld hl, $8e50
	call Call_1577
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_4CCF::
	ld de, $4d4b
	ld hl, $c8dd
	ld b, $02
	call Call_07_6C08
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_4cef

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_4d4a

jr_007_4cef:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_4d4a

	ld hl, $ca51
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
	ld hl, far_Call_03_6980
	rst $10
	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]
	ld a, [$c8dd]
	cp $80
	jr z, jr_007_4d4a

	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]

Jump_007_4d4a:
jr_007_4d4a:
	ret


	db $61, $00, $a1, $00, $ff, $ff

Jump_07_4D51::
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
	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ret


jr_007_4d74:
	ld de, $7748
	call Call_07_68DC
	ld de, $4c53
	ld b, $05
	ld a, [$c90f]
	ld c, a
	ld hl, $c8db
	call Call_07_6D2C
	ld de, $79be
	call Call_07_68DC
	call Call_07_4DA6
	call Call_07_6C8F
	ld de, $4ef5
	ld a, [$c8de]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_4DA6::
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
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
	call Call_07_68DC
	ld hl, $cb11
	ld a, [$c8de]
	call Call_224F
	ld hl, $0201
	call Call_07_6880
	call Call_2071
	ld hl, $cb13
	ld a, [$c8de]
	call Call_224F
	ld hl, $0205
	call Call_07_6880
	call Call_2071
	jr jr_007_4e80

Jump_007_4e56:
	ld de, $7a08
	call Call_07_68DC
	ld hl, $cb15
	ld a, [$c8de]
	call Call_224F
	ld hl, $0201
	call Call_07_6880
	call Call_2071
	ld hl, $cb17
	ld a, [$c8de]
	call Call_224F
	ld hl, $0205
	call Call_07_6880
	call Call_2071

jr_007_4e80:
	ld hl, $cb0b
	ld a, [$c8de]
	call Call_224A
	ld b, a
	ld hl, $01c5
	call Call_07_6880
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


Jump_07_4EAC::
	ld de, $4ef5
	ld hl, $c8de
	ld a, [$ca8d]
	ld b, a
	ld a, [hl]
	push af
	call Call_07_6C08
	pop af
	ld hl, $c8de
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_4ece

	call Call_07_4DA6
	call Call_07_690D

jr_007_4ece:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_4ee3

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_4ef4

jr_007_4ee3:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_4ef4

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_4ef4:
jr_007_4ef4:
	ret


	db $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_07_4EFD::
	ld de, $ca42
	ld hl, $c180
	call Call_0C80
	ld hl, $cac2
	ld a, [$c8de]
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
	ld l, a
	ld h, $08
	ld de, $c1a0
	call Call_097A
	ld a, [$da66]
	cp $00
	jr z, jr_007_4f55

	cp $01
	jr z, jr_007_4f55

	ld h, $0d
	ld a, $01
	ld l, a
	call Call_096D
	ld a, $ff
	ld [$da5e], a
	jr jr_007_4f68

jr_007_4f55:
	ld h, $0d
	ld a, [$da69]
	ld l, a
	call Call_096D
	ld a, [$c8de]
	ld [$da60], a
	ld hl, far_Call_03_69A2
	rst $10

jr_007_4f68:
	ld de, $2e07
	call Call_07_68DC
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ld a, [$da5e]
	cp $1d
	ret nz

	ld a, $57
	call Call_1B2C
	ret


Jump_07_4F81::
	ld a, [$c825]
	or a
	ret nz

	ld h, $0d
	ld a, [$da6a]
	ld l, a
	or a
	jr nz, jr_007_4f96

	ld a, [$da5e]
	cp $ff
	jr nz, jr_007_4fa2

jr_007_4f96:
	ld a, [$da5e]
	cp $ff
	jr nz, jr_007_4f9f

	ld l, $02

jr_007_4f9f:
	call Call_096D

jr_007_4fa2:
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_4FA7::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$da5e]
	cp $1d
	jr z, jr_007_5012

	cp $27
	jp z, Jump_007_5077

	ld a, [$da5e]
	cp $ff
	jr z, jr_007_5002

	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld [$da5f], a
	ld a, [$c8de]
	ld [$da60], a
	ld hl, far_Call_03_6E24
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	call Call_2518
	ld a, [$c825]
	or a
	jr nz, jr_007_4ffc

	ld a, [$da5e]
	cp $ff
	jr nz, jr_007_5002

	ld a, [$da65]
	cp $64
	jr z, jr_007_5002

	ld h, $0d
	ld l, $00
	call Call_096D

jr_007_4ffc:
	ld hl, $c90e
	inc [hl]
	jr jr_007_5011

jr_007_5002:
	ld a, [$c8eb]
	bit 6, a
	ret nz

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


jr_007_5011:
	ret


jr_007_5012:
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld [$da5f], a
	ld a, [$c8de]
	ld [$da60], a
	ld hl, far_Call_03_6E24
	rst $10
	call Call_2518
	ld a, $06
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [$c96d], a
	ld a, h
	ld [$c96e], a
	ld hl, $00e8
	ld a, l
	ld [$c96f], a
	ld a, h
	ld [$c970], a
	ld hl, $0058
	ld a, l
	ld [$c971], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld hl, $c8eb
	res 1, [hl]
	ld a, $01
	ld [$c8ec], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	call Call_2652
	ret z

	ld hl, far_Call_01_4BC1
	rst $10
	ret


Jump_007_5077:
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld [$da5f], a
	ld a, [$c8de]
	ld [$da60], a
	ld hl, far_Call_03_6E24
	rst $10
	call Call_2518
	ldh a, [$ffb7]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	push hl
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	push hl
	ld a, [$c960]
	ld [$c925], a
	ld hl, far_Call_0B_4239
	rst $10
	ld hl, $c300
	call Call_14CF
	ld de, $c300
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
	ld hl, far_Call_17_409E
	rst $10
	xor a
	ldh [$ffb7], a
	ldh [$ffb8], a
	xor a
	ldh [$ffbb], a
	ldh [$ffbc], a

jr_007_50df:
	call Call_07_5160
	ld a, [$c925]
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ldh [$ff92], a
	ld a, [hli]
	ldh [$ff93], a
	ld a, [hli]
	ldh [$ff95], a
	ld a, [hli]
	ldh [$ff96], a
	ld hl, $ff92
	ldh a, [$ffa5]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
	ld [hl], a
	ld hl, $ff95
	ldh a, [$ffa7]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
	ld [hl], a
	call Call_07_51B1
	jr z, jr_007_50df

	pop hl
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	pop hl
	ld a, l
	ldh [$ffb7], a
	ld a, h
	ldh [$ffb8], a
	ld b, $31
	ld hl, $c973

jr_007_512a:
	ldh a, [$ff92]
	ld [hli], a
	ldh a, [$ff95]
	ld [hli], a
	ldh a, [$ff93]
	swap a
	ld c, a
	ldh a, [$ff96]
	or c
	ld [hli], a
	ldh a, [$ff8b]
	ld c, a
	ldh a, [$ff8d]
	or c
	ld [hli], a
	dec b
	jr nz, jr_007_512a

	xor a
	ld [$ca37], a
	ld a, $01
	ld [$c8ec], a
	ld hl, $c8ea
	set 7, [hl]
	ld hl, $c8eb
	res 1, [hl]
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	ret


Call_07_5160::
	call Call_12D0
	ld a, [$c899]
	ld b, a
	ld a, $08
	call Call_1DFB
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
	ldh [$ffa5], a
	ld a, h
	ldh [$ffa6], a
	call Call_12D0
	ld a, [$c899]
	ld b, a
	ld a, $06
	call Call_1DFB
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
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	call Call_1E31
	ldh a, [$ffaa]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
	ret z

	jr Call_07_5160

Call_07_51B1::
	ld hl, $d793

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
	call Call_07_51CB
	pop hl
	ret z

jr_007_51c5:
	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_007_51b4

Call_07_51CB::
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
	ldh a, [$ff92]
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
	ldh a, [$ff95]
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


Jump_07_5205::
	ld a, [$c825]
	or a
	ret nz

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_5213::
	ret


Jump_07_5214::
	ld a, $02
	ld [$c822], a
	ld a, $0d
	ld [$c823], a
	ld hl, $9700
	ld de, $0901
	call Call_07_69B6
	ld de, $704d
	call Call_07_68DC
	ld de, $7090
	call Call_07_68DC
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_07_6880
	call Call_1FB9
	call Call_07_6C8F
	ld de, $7748
	call Call_07_68DC
	ld de, $44b4
	ld a, [$c8da]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5265::
	ld a, [$c846]
	and $03
	jr z, jr_007_5279

	ld a, $59
	call Call_1B2C
	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a

jr_007_5279:
	ret


Jump_07_527A::
	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $08
	ld de, $c190
	call Call_097A
	ld hl, $0201
	call Call_096D
	ld a, $5c
	call Call_1B2C
	ld de, $2e07
	call Call_07_68DC
	ld de, $7a3c
	call Call_07_68DC
	call Call_07_6C8F
	ld de, $5331
	ld a, [$c8df]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_52C5::
	ld de, $5331
	ld hl, $c8df
	ld b, $02
	call Call_07_6C08
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_5309

jr_007_52d7:
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_5330

jr_007_5309:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_5330

	ld a, $59
	call Call_1B2C
	ld a, [$c8df]
	cp $81
	jr z, jr_007_52d7

	ld hl, $c90e
	inc [hl]
	ld de, $ca42
	ld hl, $c180
	call Call_0C80
	ld hl, $0202
	call Call_096D

Jump_007_5330:
jr_007_5330:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_07_5337::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c8dc]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld hl, far_Call_03_7160
	rst $10
	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_5362::
	ld a, [$c90e]
	rst $00

JumpTable_07_5366::
	dw Jump_07_5386
	dw Jump_07_5397
	dw Jump_07_53E1
	dw Jump_07_54C3
	dw Jump_07_55DE
	dw Jump_07_58CC
	dw Jump_07_597F
	dw Jump_07_5A2E
	dw Jump_07_5A6E
	dw Jump_07_5B6A
	dw Jump_07_5B78
	dw Jump_07_5B86
	dw Jump_07_5B94
	dw Jump_07_5BE5
	dw Jump_07_5C34
	dw Jump_07_5C83

Jump_07_5386::
	ld a, [$c8db]
	ld [$cac0], a
	call Call_07_5572
	call Call_07_5456
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5397::
	call Call_07_6A8F
	ld de, $704d
	call Call_07_68DC
	ld de, $7090
	call Call_07_68DC
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_07_6880
	call Call_1FB9
	ld de, $76d1
	call Call_07_68DC
	ld de, $7687
	call Call_07_68DC
	call Call_07_6C8F
	ld de, $544e
	ld a, [$c8db]
	call Call_07_6D4E
	call Call_07_690D
	call Call_07_5456
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_53E1::
	ld de, $544e
	ld hl, $c8db
	ld a, [$ca8d]
	ld b, a
	ld a, [hl]
	push af
	call Call_07_6C08
	pop af
	ld hl, $c8db
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_5409

	ld a, [$c8db]
	ld [$cac0], a
	call Call_07_5572
	call Call_07_5456

jr_007_5409:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_541a

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	jr jr_007_5441

jr_007_541a:
	ld a, [$c90f]
	or a
	jr z, jr_007_5441

	ld a, [$c846]
	bit 0, a
	jr z, jr_007_5441

	ld hl, $cb0b
	ld a, [$c8db]
	call Call_2229
	bit 7, [hl]
	jr nz, jr_007_5442

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8dc], a
	ld hl, $c90e
	inc [hl]

jr_007_5441:
	ret


jr_007_5442:
	ld hl, $0e0b
	call Call_096D
	ld a, $0a
	ld [$c90e], a
	ret


	db $a1, $00, $e1, $00, $21, $01, $ff, $ff

Call_07_5456::
	ld a, [$c90f]
	or a
	jr nz, Call_07_549F

	ld a, $02
	ld [$c822], a
	ld a, $0d
	ld [$c823], a
	ld hl, $8800
	ld de, $0901
	call Call_07_69B6
	ld hl, $8890
	ld b, $48
	call Call_07_5492
	ld b, $48
	call Call_07_5492
	ld b, $48
	call Call_07_5492
	ld b, $48
	call Call_07_5492
	ld b, $48
	call Call_07_5492
	ld b, $48
	call Call_07_5492
	ld b, $48

Call_07_5492::
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, Call_07_5492

	ret


Call_07_549F::
	ld a, [$c8dd]
	cp $00
	jr z, jr_007_54ab

	ld hl, $caee
	jr jr_007_54ae

jr_007_54ab:
	ld hl, $caea

jr_007_54ae:
	call Call_07_6DA8
	ld e, l
	ld d, h
	ld hl, $8800
	call Call_07_488E
	call Call_07_488E
	call Call_07_488E
	call Call_07_488E
	ret


Jump_07_54C3::
	call Call_07_5504
	ld de, $7844
	call Call_07_68DC
	ld de, $78d9
	call Call_07_68DC
	call Call_07_558D
	ld hl, $cb15
	ld a, [$c8db]
	call Call_224F
	ld hl, $0125
	call Call_07_6880
	call Call_2071
	call Call_07_6C8F
	ld de, $56a4
	ld a, [$c8dc]
	ld b, $04
	ld hl, $c8dc
	ld a, [$c90f]
	ld c, a
	call Call_07_6D2C
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_5504::
	ld a, [$c8dd]
	cp $00
	jr z, jr_007_5510

	ld hl, $caee
	jr jr_007_5513

jr_007_5510:
	ld hl, $caea

jr_007_5513:
	ld a, [$c8db]
	call Call_2229
	ld a, [$c8dc]
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
	ld [$c823], a
	ld a, $01
	ld [$c822], a
	ld hl, $94a0
	ld de, $1203
	ld a, [$c827]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [$c829]
	ld c, a
	ld a, [$c82a]
	ld b, a
	push bc
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld hl, far_Call_56_490F
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ret


Call_07_5572::
	ld hl, $caea
	ld a, [$c8db]
	call Call_2229
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
	ld [$c90f], a
	ret


Call_07_558D::
	ld a, [$c8dd]
	cp $00
	jr z, jr_007_5599

	ld hl, $caee
	jr jr_007_559c

jr_007_5599:
	ld hl, $caea

jr_007_559c:
	ld a, [$c8db]
	call Call_2229
	ld a, [$c8dc]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	ld d, $00
	call Call_07_56E8
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
	call Call_07_6880
	call Call_2071
	ret


jr_007_55cb:
	ld hl, $cb15
	ld a, [$c8db]
	call Call_224F
	ld hl, $0121
	call Call_07_6880
	call Call_2071
	ret


Jump_07_55DE::
	ld de, $56a4
	ld hl, $c8dc
	ld a, [$c90f]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_07_6B7F
	pop af
	ld hl, $c8dc
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_5608

	call Call_07_558D
	call Call_07_690D
	call Call_07_5504

jr_007_5608:
	pop af
	ld hl, $c8dd
	cp [hl]
	jr z, jr_007_561b

	call Call_07_549F
	call Call_07_558D
	call Call_07_690D
	call Call_07_5504

jr_007_561b:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_5635

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	xor a
	ld [$c8dd], a
	jp Jump_007_56a3


jr_007_5635:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_56a3

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]
	ld hl, $caea
	ld a, [$c8db]
	call Call_2229
	ld a, [$c8dd]
	and $7f
	add a
	add a
	ld b, a
	ld a, [$c8dc]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
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
	call Call_096D
	ld a, $0a
	ld [$c90e], a
	ret


Jump_007_56a3:
jr_007_56a3:
	ret


	db $51, $01, $69, $00, $a9, $00, $e9, $00, $29, $01, $ff, $ff, $21, $50, $01, $cd
	db $89, $68, $fa, $dd, $c8, $e6, $01, $c6, $f1, $cd, $ad, $1a, $f5, $21, $50, $01
	db $7d, $c6, $00, $6f, $7c, $ce, $c5, $67, $f1, $77, $21, $51, $01, $cd, $89, $68
	db $3e, $e7, $cd, $ad, $1a, $f5, $21, $51, $01, $7d, $c6, $00, $6f, $7c, $ce, $c5
	db $67, $f1, $77, $c9

Call_07_56E8::
	ld a, e
	cp $70
	jr nz, jr_007_56fd

	ld hl, $cacc
	call Call_07_6DBA
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

Jump_07_58CC::
	ld a, [$da5e]
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

	ld hl, $c90e
	inc [hl]
	ld hl, $c90e
	inc [hl]
	ret


jr_007_58f4:
	ld de, $76d1
	call Call_07_68DC
	ld de, $790d
	call Call_07_68DC
	ld de, $7957
	call Call_07_68DC
	call Call_07_59DE
	call Call_07_6C8F
	ld de, $544e
	ld a, [$c8dd]
	call Call_07_6D4E
	ld de, $56a4
	ld a, [$c8dc]
	ld b, $04
	ld hl, $c8dc
	ld a, [$c90f]
	ld c, a
	call Call_07_6D2C
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


	db $21, $11, $cb, $fa, $dd, $c8, $cd, $4f, $22, $21, $01, $02, $cd, $80, $68, $cd
	db $71, $20, $21, $13, $cb, $fa, $dd, $c8, $cd, $4f, $22, $21, $05, $02, $cd, $80
	db $68, $cd, $71, $20, $21, $0b, $cb, $fa, $dd, $c8, $cd, $4a, $22, $47, $21, $c5
	db $01, $cd, $80, $68, $cb, $40, $3e, $e0, $28, $02, $3e, $d7, $22, $cb, $50, $3e
	db $e0, $28, $02, $3e, $d8, $22, $cb, $78, $3e, $e0, $28, $02, $3e, $d9, $77, $c9

Jump_07_597F::
	ld de, $544e
	ld hl, $c8de
	ld a, [$ca8d]
	ld b, a
	ld a, [hl]
	push af
	call Call_07_6C08
	pop af
	and $7f
	ld b, a
	ld hl, $c8de
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_007_59a1

	call Call_07_59DE
	call Call_07_690D

jr_007_59a1:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_59b6

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_59dd

jr_007_59b6:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_59dd

	ld a, [$c8de]
	and $7f
	ld [$da60], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_59dd:
jr_007_59dd:
	ret


Call_07_59DE::
	ld hl, $cb11
	ld a, [$c8de]
	call Call_224F
	ld hl, $0201
	call Call_07_6880
	call Call_2071
	ld hl, $cb13
	ld a, [$c8de]
	call Call_224F
	ld hl, $0205
	call Call_07_6880
	call Call_2071
	ld hl, $cb0b
	ld a, [$c8de]
	call Call_224A
	ld b, a
	ld hl, $01c5
	call Call_07_6880
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


Jump_07_5A2E::
	ld hl, $cac2
	ld a, [$c8db]
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, [$da5e]
	ld l, a
	ld h, $06
	ld de, $c1a0
	call Call_097A
	ld hl, $0e00
	ld a, [$da5e]
	cp $7e
	jr nz, jr_007_5a58

	ld hl, $0e09

jr_007_5a58:
	call Call_096D
	ld de, $2e07
	call Call_07_68DC
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ld a, $65
	call Call_1B2C
	ret


Jump_07_5A6E::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c8dd]
	cp $00
	jr z, jr_007_5a7f

	ld hl, $caee
	jr jr_007_5a82

jr_007_5a7f:
	ld hl, $caea

jr_007_5a82:
	ld a, [$c8db]
	call Call_2229
	ld a, [$c8dc]
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
	ld hl, $cb15
	ld a, [$c8db]
	call Call_2229
	pop bc
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	ld hl, $0e02
	jp c, Jump_007_5b16

	ld a, [$da5e]
	push af
	ld hl, far_Call_14_7BAC
	rst $10
	pop bc
	ld a, [$da5e]
	cp $ff
	ld a, b
	jr z, jr_007_5b0c

	ld a, [$da5e]
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
	call Call_096D

jr_007_5afe:
	ld hl, $c90e
	inc [hl]
	call Call_07_5B1E
	ret


jr_007_5b06:
	ld a, $0c
	ld [$c90e], a
	ret


jr_007_5b0c:
	ld hl, $0e08
	cp $38
	jr z, jr_007_5b16

	ld hl, $0e01

Jump_007_5b16:
jr_007_5b16:
	call Call_096D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_5B1E::
	ld hl, far_Call_14_7D12
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	call Call_2518
	ld a, [$c8dd]
	cp $00
	jr z, jr_007_5b35

	ld hl, $caee
	jr jr_007_5b38

jr_007_5b35:
	ld hl, $caea

jr_007_5b38:
	ld a, [$c8db]
	call Call_2229
	ld a, [$c8dc]
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
	ld hl, $cb15
	ld a, [$c8db]
	call Call_2229
	pop bc
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret


Jump_07_5B6A::
	ld a, [$c825]
	or a
	ret nz

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_5B78::
	ld de, $2e07
	call Call_07_68DC
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5B86::
	ld a, [$c825]
	or a
	ret nz

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_5B94::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $cb0b
	ld a, $00
	call Call_2229
	bit 7, [hl]
	jr nz, jr_007_5be0

	ld a, $00
	ld hl, $cb13
	call Call_224F
	push bc
	ld a, $00
	ld hl, $cb11
	call Call_224F
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

	ld hl, $cac2
	ld a, $00
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld hl, $0e03
	call Call_096D
	ld de, $2e07
	call Call_07_68DC
	call Call_07_690D

jr_007_5be0:
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5BE5::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$ca8f]
	cp $ff
	jr z, jr_007_5c2f

	ld hl, $cb0b
	ld a, $01
	call Call_2229
	bit 7, [hl]
	jr nz, jr_007_5c2f

	ld a, $01
	ld hl, $cb13
	call Call_224F
	push bc
	ld a, $01
	ld hl, $cb11
	call Call_224F
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

	ld hl, $cac2
	ld a, $01
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld hl, $0e03
	call Call_096D

jr_007_5c2f:
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5C34::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$ca90]
	cp $ff
	jr z, jr_007_5c7e

	ld hl, $cb0b
	ld a, $02
	call Call_2229
	bit 7, [hl]
	jr nz, jr_007_5c7e

	ld a, $02
	ld hl, $cb13
	call Call_224F
	push bc
	ld a, $02
	ld hl, $cb11
	call Call_224F
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

	ld hl, $cac2
	ld a, $02
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld hl, $0e03
	call Call_096D

jr_007_5c7e:
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5C83::
	ld a, [$c825]
	or a
	ret nz

	call Call_07_5B1E
	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_5C94::
	ld a, [$c90e]
	rst $00

JumpTable_07_5C98::
	dw Jump_07_5CB0
	dw Jump_07_5CFA
	dw Jump_07_5D4D
	dw Jump_07_5D6D
	dw Jump_07_5DBD
	dw Jump_07_5EDD
	dw Jump_07_605B
	dw Jump_07_62DB
	dw Jump_07_6336
	dw Jump_07_6341
	dw Jump_07_634F
	dw Jump_07_63C3

Jump_07_5CB0::
	ld de, $2e0d
	ld hl, $9000
	call Call_1577
	call Call_07_6A8F
	ld de, $704d
	call Call_07_68DC
	ld de, $7090
	call Call_07_68DC
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_07_6880
	call Call_1FB9
	ld de, $7a61
	call Call_07_68DC
	call Call_07_6C8F
	ld de, $5d43
	ld a, [$c8db]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5CFA::
	ld de, $5d43
	ld hl, $c8db
	ld b, $04
	call Call_07_6C08
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_5d16

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	jr jr_007_5d42

jr_007_5d16:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_5d42

	ld a, $59
	call Call_1B2C
	ld b, $02
	ld a, [$c8db]
	cp $80
	jr z, jr_007_5d3e

	ld b, $04
	cp $81
	jr z, jr_007_5d3e

	ld b, $06
	cp $83
	jr z, jr_007_5d3e

	xor a
	ld [$c8e0], a
	ld b, $0a

jr_007_5d3e:
	ld a, b
	ld [$c90e], a

Jump_007_5d42:
jr_007_5d42:
	ret


	db $66, $00, $a6, $00, $e6, $00, $26, $01, $ff, $ff

Jump_07_5D4D::
	ld de, $7ae7
	call Call_07_68DC
	call Call_07_6C8F
	ld de, $5dab
	ld a, [$c8ee]
	ld [$c8dc], a
	ld a, [$c8dc]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_5D6D::
	ld de, $5dab
	ld hl, $c8dc
	ld b, $08
	call Call_07_6C6D
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_5d8d

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_5daa

jr_007_5d8d:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_5daa

	ld a, [$c8dc]
	and $7f
	ld [$c8ee], a
	ld a, $59
	call Call_1B2C
	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a

Jump_007_5daa:
jr_007_5daa:
	ret


	db $c3, $01, $c5, $01, $c7, $01, $c9, $01, $cb, $01, $cd, $01, $cf, $01, $d1, $01
	db $ff, $ff

Jump_07_5DBD::
	call Call_07_4469
	ld b, $00
	ld a, $00
	push bc
	ld hl, $cb0b
	call Call_224A
	pop bc
	bit 7, a
	jr nz, jr_007_5dd1

	inc b

jr_007_5dd1:
	ld a, [$ca8d]
	cp $01
	jr z, jr_007_5dfd

	ld a, $01
	push bc
	ld hl, $cb0b
	call Call_224A
	pop bc
	bit 7, a
	jr nz, jr_007_5de7

	inc b

jr_007_5de7:
	ld a, [$ca8d]
	cp $02
	jr z, jr_007_5dfd

	ld a, $02
	push bc
	ld hl, $cb0b
	call Call_224A
	pop bc
	bit 7, a
	jr nz, jr_007_5dfd

	inc b

jr_007_5dfd:
	ld a, b
	ld [$c90f], a
	ld hl, $c0a0
	ld a, $00
	ld [hli], a
	ld b, $ff
	ld a, [$c90f]
	cp $02
	jr c, jr_007_5e12

	ld b, $01

jr_007_5e12:
	ld [hl], b
	inc hl
	ld b, $ff
	ld a, [$c90f]
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
	ld [$c913], a
	ld de, $7b48
	call Call_07_68DC
	ld de, $7b89
	call Call_07_68DC
	call Call_07_5E51
	call Call_07_6C8F
	ld de, $6045
	ld a, [$c8dd]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_5E51::
	ld a, [$c0a0]
	cp $ff
	jr z, jr_007_5e61

	ld a, [$c0a1]
	cp $ff
	jr z, jr_007_5e67

	jr jr_007_5e72

jr_007_5e61:
	ld a, [$c0a1]
	ld [$c0a0], a

jr_007_5e67:
	ld a, [$c0a2]
	ld [$c0a1], a
	ld a, $ff
	ld [$c0a2], a

jr_007_5e72:
	ld hl, $c685
	ld a, [$c0a0]
	add $f1
	ld b, a
	ld a, [$c0a0]
	call Call_07_5EC1
	ld hl, $c6c5
	ld a, [$c0a1]
	add $f1
	ld b, a
	ld a, [$c0a1]
	call Call_07_5EC1
	ld hl, $c705
	ld a, [$c0a2]
	add $f1
	ld b, a
	ld a, [$c0a2]
	call Call_07_5EC1
	ld hl, $c68d
	ld b, $f1
	ld a, [$c0a3]
	call Call_07_5EC1
	ld hl, $c6cd
	ld b, $f2
	ld a, [$c0a4]
	call Call_07_5EC1
	ld hl, $c70d
	ld b, $f3
	ld a, [$c0a5]
	call Call_07_5EC1
	ret


Call_07_5EC1::
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


Jump_07_5EDD::
	ld a, [$c90f]
	ld c, a
	ld a, [$c913]
	cp c
	jr z, jr_007_5ef7

	ld de, $6045
	ld hl, $c8dd
	ld a, [$c913]
	ld b, a
	ld a, c
	sub b
	ld b, a
	call Call_07_6C08

jr_007_5ef7:
	ld a, [$c8dd]
	and $7f
	ld [$c8dd], a
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_5f64

	ld a, [$c913]
	cp $00
	jr z, jr_007_5f4d

	dec a
	ld hl, $c0a3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [hl], $ff
	ld [$c0a2], a
	ld hl, $c0a0
	call Call_07_5F45
	call Call_07_5F45
	ld hl, $c0a0
	call Call_07_5F45
	call Call_07_5F45
	ld hl, $c0a0
	call Call_07_5F45
	call Call_07_5F45
	call Call_07_5E51
	call Call_07_690D
	ld hl, $c913
	dec [hl]
	jp Jump_007_6044


Call_07_5F45::
	ld a, [hli]
	ld b, [hl]
	cp b
	ret c

	ld [hld], a
	ld [hl], b
	inc hl
	ret


jr_007_5f4d:
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jp Jump_007_6044


jr_007_5f64:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_6044

	ld a, $59
	call Call_1B2C
	ld a, [$c90f]
	ld c, a
	ld a, [$c913]
	cp c
	jr z, jr_007_5fc9

	ld hl, $c0a3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c8dd]
	ld de, $c0a0
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ld a, $ff
	ld [de], a
	ld a, [$c90f]
	ld c, a
	dec c
	ld a, [$c913]
	cp c
	jr nz, jr_007_5fa8

	ld de, $7b48
	call Call_07_68DC
	jr jr_007_5fbc

jr_007_5fa8:
	ld b, a
	ld a, c
	sub b
	ld b, a
	ld a, [$c8dd]
	cp b
	jr c, jr_007_5fbc

	dec a
	ld [$c8dd], a
	ld de, $6045
	call Call_07_6CA9

jr_007_5fbc:
	call Call_07_5E51
	call Call_07_690D
	ld hl, $c913
	inc [hl]
	jp Jump_007_6044


jr_007_5fc9:
	ld a, [$c0a3]
	call Call_07_604D
	ld [$c0a0], a
	ld a, [$c0a4]
	call Call_07_604D
	ld [$c0a1], a
	ld a, [$c0a5]
	call Call_07_604D
	ld [$c0a2], a
	ld a, [$c0a0]
	ld [$ca8e], a
	ld a, [$c90f]
	cp $01
	jr z, jr_007_6004

	ld a, [$c0a1]
	ld [$ca8f], a
	ld a, [$c90f]
	cp $02
	jr z, jr_007_6004

	ld a, [$c0a2]
	ld [$ca90], a

jr_007_6004:
	ld hl, far_Call_01_484E
	rst $10
	ld a, [$c969]
	or a
	jr nz, jr_007_6039

	ld a, [$c968]
	cp $06
	jr nz, jr_007_6039

	ld a, [$c925]
	or a
	jr nz, jr_007_6039

	ld a, [$ca91]
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
	call Call_2518
	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a

Jump_007_6044:
	ret


	db $86, $01, $c6, $01, $06, $02, $ff, $ff

Call_07_604D::
	cp $ff
	ret z

	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Jump_07_605B::
	ld a, [$c969]
	or a
	jr nz, jr_007_6090

	ld a, [$c968]
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
	call Call_096D
	ld de, $2e07
	call Call_07_68DC
	call Call_07_690D
	ld a, $09
	ld [$c90e], a
	ret


jr_007_60a5:
	ld a, $5c
	call Call_1B2C
	ld de, $7bca
	call Call_07_68DC
	ld de, $7c44
	call Call_07_68DC
	ld de, $2e07
	call Call_07_68DC
	ld hl, $a002
	call Call_20EE
	or a
	jr nz, jr_007_6122

	ld hl, $0021
	call Call_07_6880
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0041
	call Call_07_6880
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0061
	call Call_07_6880
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0081
	call Call_07_6880
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0044
	call Call_07_6880
	ld b, $0a
	ld a, $40

jr_007_6107:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_007_6107

	ld a, $31
	ld [$c823], a
	ld a, $02
	ld [$c822], a
	ld hl, $9400
	ld de, $0a01
	call Call_07_69B6
	jp Jump_007_61de


jr_007_6122:
	di
	ld a, $0a
	ld [$0100], a
	ld de, $a17c
	ld hl, $93c0
	call Call_07_69EF
	ei
	call Call_07_61FD
	ld hl, $a1c7
	call Call_20EE
	or a
	jr z, jr_007_61a8

	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a246
	ld a, [$a1c8]
	call Call_223B
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $0084
	call Call_07_6880
	call Call_2082
	ld hl, $a1c7
	call Call_20EE
	cp $01
	jr z, jr_007_61ae

	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a246
	ld a, [$a1c9]
	call Call_223B
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $008a
	call Call_07_6880
	call Call_2082
	ld hl, $a1c7
	call Call_20EE
	cp $02
	jr z, jr_007_61b4

	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a246
	ld a, [$a1ca]
	call Call_223B
	ld c, [hl]
	ei
	ld b, $00
	ld hl, $0090
	call Call_07_6880
	call Call_2082
	jr jr_007_61ba

jr_007_61a8:
	ld hl, $0061
	call Call_07_62BF

jr_007_61ae:
	ld hl, $0067
	call Call_07_62BF

jr_007_61b4:
	ld hl, $006d
	call Call_07_62BF

jr_007_61ba:
	ld hl, $a1f2
	call Call_20EE
	ld c, a
	ld b, $00
	ld hl, $002d
	call Call_07_6880
	call Call_20AD
	ld hl, $a1f1
	call Call_20EE
	ld c, a
	ld b, $00
	ld hl, $0030
	call Call_07_6880
	call Call_20AD

Jump_007_61de:
	ld a, $00
	ld [$0100], a
	ld hl, $0207
	call Call_096D
	call Call_07_6C8F
	ld de, $6330
	ld a, [$c8de]
	call Call_07_6D4E
	call Call_07_690D
	ld hl, $c90e
	inc [hl]
	ret


Call_07_61FD::
	ld hl, $8da0
	ld b, $18
	call Call_07_6264
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1fc
	ld a, [$a1c8]
	call Call_223B
	ei
	ld e, l
	ld d, h
	ld hl, $9400
	ld a, $01
	call Call_07_6254
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1fc
	ld a, [$a1c9]
	call Call_223B
	ei
	ld e, l
	ld d, h
	ld hl, $9440
	ld a, $02
	call Call_07_6254
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1fc
	ld a, [$a1ca]
	call Call_223B
	ei
	ld e, l
	ld d, h
	ld hl, $9480
	ld a, $03
	call Call_07_6254
	ret


Call_07_6254::
	ld b, a
	di
	ld a, $0a
	ld [$0100], a
	ld a, [$a1c7]
	cp b
	ei
	jr nc, jr_007_6271

	ld b, $20

Call_07_6264::
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, Call_07_6264

	ret


jr_007_6271:
	push bc
	call Call_07_69EF
	pop bc
	dec b
	push bc
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1c8
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, $a205
	call Call_223B
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
	call Call_1577
	ret


	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

Call_07_62BF::
	push hl
	call Call_07_6880
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
	call Call_07_6880
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


Jump_07_62DB::
	ld de, $6330
	ld hl, $c8de
	ld b, $02
	call Call_07_6C08
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_630b

jr_007_62ed:
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_632f

jr_007_630b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_632f

	ld a, [$c8de]
	cp $81
	jr nz, jr_007_6321

	ld a, $59
	call Call_1B2C
	jr jr_007_62ed

jr_007_6321:
	di
	call Call_2128
	ei
	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_632f:
jr_007_632f:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_07_6336::
	ld hl, $0232
	call Call_096D
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_6341::
	ld a, [$c825]
	or a
	ret nz

	call Call_07_6A8F
	ld a, $01
	ld [$c90d], a
	ret


Jump_07_634F::
	ld a, [$ca8d]
	or a
	jr z, jr_007_637c

	ld hl, $cb0b

jr_007_6358:
	ld a, [$c8e0]
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	jr z, jr_007_6374

	ld hl, $c8e0
	inc [hl]
	ld a, [$c8e0]
	ld hl, $ca8d
	cp [hl]
	jr nz, jr_007_6358

	jr jr_007_637c

jr_007_6374:
	call Call_07_6385
	ld hl, $c90e
	inc [hl]
	ret


jr_007_637c:
	call Call_07_6A8F
	ld a, $00
	ld [$c90e], a
	ret


Call_07_6385::
	ld hl, $cac2
	ld a, [$c8e0]
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $93c0
	call Call_07_69EF
	ld de, $7c69
	call Call_07_68DC
	ld de, $7cd7
	call Call_07_68DC
	ld hl, $cacc
	ld a, [$c8e0]
	call Call_2229
	ld a, [hl]
	swap a
	and $03
	ld [$c8df], a
	call Call_07_6C8F
	ld de, $644c
	ld a, [$c8df]
	call Call_07_6D4E
	call Call_07_690D
	ret


Jump_07_63C3::
	ld de, $644c
	ld hl, $c8df
	ld b, $04
	call Call_07_6C08
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_63fc

jr_007_63d5:
	ld a, [$c8e0]
	or a
	jr z, jr_007_63f2

	ld hl, $c8e0
	dec [hl]
	ld a, [$c8e0]
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	jr nz, jr_007_63d5

	ld hl, $c90e
	dec [hl]
	jr jr_007_644b

jr_007_63f2:
	call Call_07_6A8F
	ld a, $00
	ld [$c90e], a
	jr jr_007_644b

jr_007_63fc:
	ld a, [$c846]
	bit 0, a
	jr z, jr_007_644b

	ld a, $59
	call Call_1B2C
	ld a, [$c8df]
	and $03
	swap a
	ld b, a
	push bc
	ld hl, $cacc
	ld a, [$c8e0]
	call Call_2229
	ld a, [hl]
	and $cf
	pop bc
	or b
	ld [hl], a

jr_007_6420:
	ld hl, $c8e0
	inc [hl]
	ld a, [$ca8d]
	ld b, a
	ld a, [$c8e0]
	cp b
	jr z, jr_007_6441

	ld a, [$c8e0]
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	jr nz, jr_007_6420

	ld hl, $c90e
	dec [hl]
	jr jr_007_644b

jr_007_6441:
	call Call_07_6A8F
	ld a, $00
	ld [$c90e], a
	jr jr_007_644b

jr_007_644b:
	ret


	db $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Call_07_6456::
	ld hl, $cac0
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	xor a
	ld [$c932], a
	ld [$c933], a

Call_07_6468::
	ld a, [$c90e]
	rst $00

JumpTable_07_646C::
	dw Jump_07_6488
	dw Jump_07_64AD
	dw Call_07_64C9
	dw Jump_07_64DC
	dw Jump_07_654E
	dw Jump_07_6552
	dw Call_07_6588
	dw Jump_07_65AC
	dw Jump_07_65BC
	dw Jump_07_65C0
	dw Jump_07_65D0
	dw Jump_07_65F9
	dw Jump_07_65D5
	dw Jump_07_65E7

Jump_07_6488::
	ld a, $01
	ld [$c8ec], a
	ld a, [$c932]
	ld [$c934], a
	ld a, [$c930]
	ld l, a
	ld a, [$c931]
	ld h, a
	ld a, [$c932]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$cac0], a
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_64AD::
	call Call_07_6ABA
	ld hl, $c90e
	inc [hl]
	ld a, [$cac0]
	ld hl, $cb24
	call Call_223B
	ld a, [hl]
	or a
	ret z

	call Call_07_4655
	ld a, $08
	ld [$c90e], a
	ret


Call_07_64C9::
	ld de, $70f7
	call Call_07_68DC
	ld de, $71af
	call Call_07_68DC
	call Call_07_451E
	call Call_07_4655
	ret


Jump_07_64DC::
	call Call_07_6504
	jr z, jr_007_64e8

	call Call_07_64C9
	ld hl, $c90e
	dec [hl]

jr_007_64e8:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_64f2

	jp Jump_07_65F9


jr_007_64f2:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_6503

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_6503:
	ret


Call_07_6504::
	ld a, [$c934]
	push af
	ld a, [$c933]
	ld b, a
	or a
	jr z, jr_007_654b

	ld a, [$c847]
	bit 6, a
	jr z, jr_007_6521

	ld a, [$c934]
	dec a
	cp b
	jr c, jr_007_6531

	dec b
	ld a, b
	jr jr_007_6531

jr_007_6521:
	ld a, [$c847]
	bit 7, a
	jr z, jr_007_654b

	ld a, [$c934]
	inc a
	cp b
	jr c, jr_007_6531

	ld a, $00

jr_007_6531:
	ld [$c934], a
	ld b, a
	ld a, [$c930]
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
	ld [$cac0], a
	pop af
	cp b
	ret


jr_007_654b:
	pop af
	xor a
	ret


Jump_07_654E::
	call Call_07_46CA
	ret


Jump_07_6552::
	call Call_07_6504
	jr z, jr_007_655e

	ld a, $0c
	ld [$c90e], a
	jr jr_007_6587

jr_007_655e:
	ld a, [$c846]
	bit 1, a
	jr z, jr_007_6573

	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	ld hl, $c90e
	dec [hl]
	jr jr_007_6587

jr_007_6573:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_007_6584

	ld a, $59
	call Call_1B2C
	ld hl, $c90e
	inc [hl]

Jump_007_6584:
	call Call_07_66C8

jr_007_6587:
	ret


Call_07_6588::
	ld a, [$cac0]
	ld hl, $cb24
	call Call_223B
	ld a, [hl]
	or a
	jr nz, Jump_07_65F9

	call Call_07_486B
	ld de, $737b
	call Call_07_68DC
	call Call_07_690D
	call Call_07_466D
	call Call_07_4689
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_65AC::
	call Call_07_6504
	jr z, jr_007_65b8

	call Call_07_6588
	ld hl, $c90e
	dec [hl]

jr_007_65b8:
	call Call_07_48BF
	ret


Jump_07_65BC::
	call Call_07_48E6
	ret


Jump_07_65C0::
	call Call_07_6504
	jr z, jr_007_65cc

	ld a, $0d
	ld [$c90e], a
	jr jr_007_65cf

jr_007_65cc:
	call Call_07_4A1E

jr_007_65cf:
	ret


Jump_07_65D0::
	ld hl, $c90e
	inc [hl]
	ret


Jump_07_65D5::
	call Call_07_45EE
	call Call_07_46D2
	call Call_07_466D
	call Call_07_4689
	ld a, $05
	ld [$c90e], a
	ret


Jump_07_65E7::
	call Call_07_45EE
	call Call_07_48F7
	call Call_07_466D
	call Call_07_4689
	ld a, $09
	ld [$c90e], a
	ret


Jump_07_65F9::
	call Call_07_6A8F
	call Call_07_690D
	call Call_07_6A9E
	ld a, [$c88a]
	or a
	jr z, jr_007_661b

	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_17_401D
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	call Call_07_6625
	ld hl, far_Call_06_4D5A
	rst $10

jr_007_661b:
	ld a, $00
	ld [$c8ec], a
	ld hl, $c906
	inc [hl]
	ret


Call_07_6625::
	ld a, [$c81d]
	or a
	ret z

	di
	call Call_1AA6
	ld a, $01
	ldh [rVBK], a
	ei
	ldh a, [$ffbb]
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
	ldh a, [$ffb7]
	rrca
	rrca
	rrca
	and $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld de, $c200
	ld c, $10

jr_007_6655:
	ld b, $0a
	push hl

jr_007_6658:
	ld a, [de]
	swap a
	and $0f
	call Call_1AAD
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
	call Call_1AAD
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
	call Call_1AA6
	ld a, $00
	ldh [rVBK], a
	ei
	ret


Call_07_66A4::
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


Call_07_66B1::
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
	call Call_1577
	ret


Call_07_66C8::
	ld a, [$c88a]
	or a
	ret z

	ld hl, $caca
	call Call_07_6DBA
	push af
	ld hl, $ffc3
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
	ld hl, $cb0b
	call Call_07_6DBA
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_6701

	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ret


Call_07_670E::
	ld a, [$c88a]
	or a
	ret z

	ld hl, $cad6
	call Call_07_6DBA
	cp $ff
	ret z

	push af
	ld hl, $ffc3
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
	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ld hl, $cad7
	call Call_07_6DBA
	push af
	ld hl, $ffc3
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
	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ret


Call_07_6779::
	ld a, [$c90d]
	cp $02
	ret nz

	ld a, [$ca8d]
	or a
	ret z

	ld a, $00
	ld hl, $caca
	call Call_224A
	push af
	ld hl, $ffc3
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
	ld hl, $cb0b
	ld a, $00
	call Call_224A
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_67bc

	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ld a, [$ca8d]
	cp $01
	ret z

	ld a, $01
	ld hl, $caca
	call Call_224A
	push af
	ld hl, $ffc3
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
	ld hl, $cb0b
	ld a, $01
	call Call_224A
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_6806

	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ld a, [$ca8d]
	cp $02
	ret z

	ld a, $02
	ld hl, $caca
	call Call_224A
	push af
	ld hl, $ffc3
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
	ld hl, $cb0b
	ld a, $02
	call Call_224A
	ld a, [hl]
	pop hl
	pop bc
	bit 7, a
	jr nz, jr_007_6850

	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ret


Call_07_685D::
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


Call_07_686C::
	ld a, [$c911]
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


Call_07_6880::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_07_6889::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_07_686C
	ld a, b
	and $1f
	jr z, jr_007_689e

	ld b, a

jr_007_6898:
	call Call_07_685D
	dec b
	jr nz, jr_007_6898

jr_007_689e:
	pop bc
	ret


Call_07_68A0::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_07_6889
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a

jr_007_68af:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_007_68d4

	ldh a, [$ffd5]
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	jr jr_007_68af

jr_007_68d4:
	call Call_1AAD
	call Call_07_685D
	jr jr_007_68af

Call_07_68DC::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_07_6880
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a

jr_007_68eb:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_007_690a

	ldh a, [$ffd5]
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	jr jr_007_68eb

jr_007_690a:
	ld [hli], a
	jr jr_007_68eb

Call_07_690D::
	ld a, [$c911]
	ld l, a
	ld a, [$c912]
	ld h, a
	ld de, $c500
	ld c, $12

jr_007_691a:
	ld b, $20
	push hl

jr_007_691d:
	ld a, [de]
	call Call_1AAD
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


Call_07_6942::
	ld b, a
	ld de, $0801
	ld a, c
	cp $ff
	jr z, jr_007_69ac

	ld a, b
	push hl
	push af
	ld l, c
	ld h, $04
	ld de, $c180
	call Call_097A
	pop af
	ld de, $c180
	call Call_07_6DE2
	pop hl
	ld a, [$c827]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [$c829]
	ld c, a
	ld a, [$c82a]
	ld b, a
	push bc
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld de, $0801
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld a, $02
	ld [$c822], a
	ld a, $00
	ld [$c823], a
	ld hl, far_Call_41_4AA1
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ret


Call_07_69A5::
	ld a, [$c823]
	cp $ff
	jr nz, Call_07_69B6

jr_007_69ac:
	ld a, $0a
	ld [$c823], a
	ld a, $04
	ld [$c822], a

Call_07_69B6::
	ld a, [$c827]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [$c829]
	ld c, a
	ld a, [$c82a]
	ld b, a
	push bc
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld hl, far_Call_41_4AA1
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ret


Call_07_69EF::
	push hl
	ld hl, $c180
	call Call_0C80
	pop hl
	ld a, [$c827]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [$c829]
	ld c, a
	ld a, [$c82a]
	ld b, a
	push bc
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld de, $0401
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld a, $02
	ld [$c822], a
	ld a, $00
	ld [$c823], a
	ld hl, far_Call_41_4AA1
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ret


Call_07_6A3D::
	and $01
	add $a7

Call_07_6A41::
	ld [$c180], a
	ld a, $f0
	ld [$c181], a
	ld a, [$c827]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [$c829]
	ld c, a
	ld a, [$c82a]
	ld b, a
	push bc
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld de, $0101
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld a, $02
	ld [$c822], a
	ld a, $00
	ld [$c823], a
	ld hl, far_Call_41_4AA1
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ret


Call_07_6A8F::
	ld hl, $c500
	ld bc, $0240

jr_007_6a95:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_007_6a95

	ret


Call_07_6A9E::
	ld hl, $9800
	ld bc, $0400

jr_007_6aa4:
	ld a, $e0
	call Call_1AB9
	dec bc
	ld a, b
	or c
	jr nz, jr_007_6aa4

	ret


Jump_07_6AAF::
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7

Call_07_6ABA::
	ld hl, $ffb7
	call Call_07_66A4
	ld hl, $ffbb
	call Call_07_66A4
	ldh a, [$ffbb]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [$ffb7]
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
	ld [$c911], a
	ld a, h
	ld [$c912], a
	call Call_07_6A8F
	call Call_07_690D
	call Call_07_6A9E
	ld de, $2e0d
	ld hl, $9000
	call Call_1577
	call Call_07_6C8F
	ld hl, far_Call_17_4192
	rst $10
	ld hl, $c90d
	inc [hl]
	ret


Jump_07_6B04::
	call Call_07_6A8F
	call Call_07_690D
	ld hl, far_Call_17_4192
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_0B_40CE
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	call Call_2518
	call Call_25F1
	ld hl, far_Call_06_4D5A
	rst $10
	ld hl, $c8eb
	res 1, [hl]
	xor a
	ld [$c90d], a
	ld a, [$c969]
	or a
	ret z

	ld de, $2e15
	ld hl, $8500
	call Call_1577
	ld de, $2e16
	ld hl, $8540
	call Call_1577
	ld de, $2e17
	ld hl, $8580
	call Call_1577
	ld de, $2e18
	ld hl, $85c0
	call Call_1577
	ld de, $2e19
	ld hl, $8600
	call Call_1577
	ld de, $2e1a
	ld hl, $8640
	call Call_1577
	ld de, $2e1b
	ld hl, $8680
	call Call_1577
	ld de, $2e1c
	ld hl, $86c0
	call Call_1577
	ret


Call_07_6B7F::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_007_6be6

	ld a, [$c847]
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
	call Call_1DFB
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
	ld a, [$c847]
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
	call Call_1DFB
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

	ld a, [$c8e1]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
	call Call_1DFB
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
	call Call_07_6CF3
	pop hl
	pop de
	pop bc
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Call_1DFB
	ld [$c8e1], a
	ld a, b
	pop bc
	pop de
	ld c, a
	inc hl
	ld a, [hld]
	cp c
	jr nz, Call_07_6C08

	ld a, [$c8e1]
	inc a
	ld b, a

Call_07_6C08::
	res 7, [hl]
	ld a, [$c847]
	bit 6, a
	jr z, jr_007_6c1a

	ld a, [hl]
	dec a
	cp b
	jr c, jr_007_6c28

	dec b
	ld a, b
	jr jr_007_6c28

jr_007_6c1a:
	ld a, [$c847]
	bit 7, a
	jr z, jr_007_6c31

	ld a, [hl]
	inc a
	cp b
	jr c, jr_007_6c28

	ld a, $00

jr_007_6c28:
	ld [hl], a

jr_007_6c29:
	xor a
	ld [$c914], a
	push hl
	push de
	pop de
	pop hl

jr_007_6c31:
	ld a, [$c846]
	bit 0, a
	jr z, jr_007_6c3a

	set 7, [hl]

jr_007_6c3a:
	ld a, [hl]
	call Call_07_6C94
	ret


Call_07_6C3F::
	res 7, [hl]
	ld a, [$c847]
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
	ld a, [$c847]
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
	ld [$c914], a
	push hl
	push de
	pop de
	pop hl

jr_007_6c68:
	ld a, [hl]
	call Call_07_6C94
	ret


Call_07_6C6D::
	res 7, [hl]
	ld a, [$c847]
	bit 5, a
	jr z, jr_007_6c7f

	ld a, [hl]
	dec a
	cp b
	jr c, jr_007_6c28

	dec b
	ld a, b
	jr jr_007_6c28

jr_007_6c7f:
	ld a, [$c847]
	bit 4, a
	jr z, jr_007_6c31

	ld a, [hl]
	inc a
	cp b
	jr c, jr_007_6c28

	ld a, $00
	jr jr_007_6c28

Call_07_6C8F::
	xor a
	ld [$c914], a
	ret


Call_07_6C94::
	ld c, a
	bit 7, a
	jr nz, Call_07_6CA9

	ld a, [$c914]
	and $0f
	push af
	ld a, [$c914]
	inc a
	ld [$c914], a
	pop af
	ld a, c
	ret nz

Call_07_6CA9::
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_07_6889
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

	ld a, [$c914]
	bit 4, a
	ld a, $e0
	jr nz, jr_007_6cdc

	ld a, $e8

jr_007_6cdc:
	call Call_1AAD
	push af
	ldh a, [$ffd5]
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

Call_07_6CF3::
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_07_6889
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
	call Call_1AAD
	push af
	ldh a, [$ffd5]
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


Call_07_6D2C::
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

Call_07_6D4E::
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_07_6889
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_007_6d79

	ld a, [$c914]
	bit 4, a
	ld a, $e0
	jr nz, jr_007_6d79

	ld a, $e8

jr_007_6d79:
	push af
	ldh a, [$ffd5]
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


Call_07_6D8B::
	ld a, [$c8eb]
	bit 1, a
	jr z, jr_007_6da2

	ld a, [$cac0]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


jr_007_6da2:
	ld a, [$cac0]
	and $7f
	ret


Call_07_6DA8::
	ld a, [$c8eb]
	bit 1, a
	jr z, jr_007_6db3

	call Call_2266
	ret


jr_007_6db3:
	ld a, [$cac0]
	call Call_223B
	ret


Call_07_6DBA::
	ld a, [$c8eb]
	bit 1, a
	jr z, jr_007_6dc5

	call Call_2284
	ret


jr_007_6dc5:
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
	ret


Call_07_6DCD::
	ld a, [$c8eb]
	bit 1, a
	jr z, jr_007_6dd8

	call Call_2289
	ret


jr_007_6dd8:
	ld a, [$cac0]
	call Call_223B
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


Call_07_6DE2::
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
	call Call_09A4
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

Call_07_6FE2::
	ld de, $0064
	push bc
	call Call_07_7023
	pop bc
	or a
	jr z, Call_07_7007

	ld de, $0064
	call Call_07_7023
	call Call_07_7038
	call Call_07_703E
	ld de, $000a
	call Call_07_7023
	call Call_07_7038
	call Call_07_703E
	jr jr_007_701e

Call_07_7007::
	ld de, $000a
	push bc
	call Call_07_7023
	pop bc
	or a
	jr z, jr_007_701e

	ld de, $000a
	call Call_07_7023
	call Call_07_7038
	call Call_07_703E

jr_007_701e:
	ld a, c
	call Call_07_7038
	ret


Call_07_7023::
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


Call_07_7038::
	add $f0
	call Call_1AAD
	ret


Call_07_703E::
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
