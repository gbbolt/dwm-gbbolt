INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $012", ROMX[$4000], BANK[$12]

	db $12, $03, $40

	ld a, [$c8ef]
	rst $00

JumpTable_12_4007::
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_442D
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_6061
	dw Jump_12_6842
	dw Jump_12_6AFE
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_4027
	dw Jump_12_4027

Jump_12_4027::
	ret


Call_12_4028::
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


Call_12_4035::
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


Call_12_4044::
	ld a, [$c909]
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


Call_12_4058::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_12_4061::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_12_4044
	ld a, b
	and $1f
	jr z, jr_012_4076

	ld b, a

jr_012_4070:
	call Call_12_4035
	dec b
	jr nz, jr_012_4070

jr_012_4076:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $61, $40, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $35, $40, $18, $d3

Call_12_40B4::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_12_4058
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a

jr_012_40c3:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_012_40e2

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
	jr jr_012_40c3

jr_012_40e2:
	ld [hli], a
	jr jr_012_40c3

Call_12_40E5::
	ld a, [$c909]
	ld l, a
	ld a, [$c90a]
	ld h, a
	ld de, $c500
	ld c, $12

jr_012_40f2:
	ld b, $20
	push hl

jr_012_40f5:
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


Call_12_411A::
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


Call_12_4153::
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


	db $ea, $80, $c1, $3e, $f0, $ea, $81, $c1, $fa, $27, $c8, $4f, $fa, $28, $c8, $47
	db $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8, $47, $c5, $7d, $ea, $27, $c8, $7c, $ea
	db $28, $c8, $11, $01, $01, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $3e, $02, $ea
	db $22, $c8, $3e, $00, $ea, $23, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27
	db $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9

Call_12_41EF::
	ld hl, $c500
	ld de, $c300
	ld bc, $0200

jr_012_41f8:
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_012_41f8

	ld de, $c1c0
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


Call_12_4221::
	ld hl, $c500
	ld bc, $0240

jr_012_4227:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_012_4227

	ret


	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

Call_12_4241::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_012_42a8

	ld a, [$c847]
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
	call Call_1DFB
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
	ld a, [$c847]
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
	call Call_1DFB
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
	jr nz, jr_012_42eb

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
	jr z, jr_012_42eb

	dec a
	cp [hl]
	jr nc, jr_012_42eb

	ld [hl], a
	jr jr_012_42eb

Jump_012_42a8:
jr_012_42a8:
	push bc
	push de
	push hl
	call Call_12_4387
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
	jr nz, Call_12_42CA

	ld a, [$c8e1]
	inc a
	ld b, a

Call_12_42CA::
	res 7, [hl]
	ld a, [$c847]
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
	ld a, [$c847]
	bit 7, a
	jr z, jr_012_42f3

	ld a, [hl]
	inc a
	cp b
	jr c, jr_012_42ea

	ld a, $00

jr_012_42ea:
	ld [hl], a

jr_012_42eb:
	xor a
	ld [$c90c], a
	push hl
	push de
	pop de
	pop hl

jr_012_42f3:
	ld a, [$c846]
	bit 0, a
	jr z, jr_012_42fc

	set 7, [hl]

jr_012_42fc:
	ld a, [hl]
	call Call_12_4328
	ret


	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

Call_12_4323::
	xor a
	ld [$c90c], a
	ret


Call_12_4328::
	ld c, a
	bit 7, a
	jr nz, jr_012_433d

	ld a, [$c90c]
	and $0f
	push af
	ld a, [$c90c]
	inc a
	ld [$c90c], a
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_12_4061
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

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_012_4370

	ld a, $e8

jr_012_4370:
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
	jr jr_012_4340

Call_12_4387::
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
	call Call_12_4061
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


Call_12_43C0::
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

Call_12_43E2::
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
	call Call_12_4061
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_012_440d

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_012_440d

	ld a, $e8

jr_012_440d:
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


Call_12_441F::
	ld a, [$c8f0]
	add l
	ld l, a
	ld a, [$c8f1]
	adc h
	ld h, a
	call Call_0AD9
	ret


Jump_12_442D::
	ld a, [$c905]
	rst $00

JumpTable_12_4431::
	dw Jump_12_443B
	dw Jump_12_44B4
	dw Jump_12_44E4
	dw Jump_12_4540
	dw Jump_12_4550

Jump_12_443B::
	ld hl, $ffb7
	call Call_12_4028
	ld hl, $ffbb
	call Call_12_4028
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
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
	ld [$c909], a
	ld a, h
	ld [$c90a], a
	call Call_12_41EF
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_4323
	ld a, $60
	ldh [$ffd4], a
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, $c905
	inc [hl]
	ret


Jump_12_44B4::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c905
	inc [hl]
	xor a
	ld [$c8ec], a
	call Call_12_41EF
	call Call_12_44CB
	call Call_12_40E5
	ret


Call_12_44CB::
	ld de, $710c
	call Call_12_40B4
	ld de, $2e07
	call Call_12_40B4
	call Call_12_4323
	ld de, $4532
	ld a, [$c8da]
	call Call_12_43E2
	ret


Jump_12_44E4::
	ld de, $4532
	ld hl, $c8da
	ld b, $06
	call Call_12_42CA
	ld a, [$c846]
	and $0a
	jr z, jr_012_4500

	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	jr jr_012_4531

jr_012_4500:
	ld a, [$c846]
	bit 0, a
	jr z, jr_012_4531

	ld a, $59
	call Call_1B2C
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8da
	set 7, [hl]
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	jr jr_012_4531

jr_012_4531:
	ret


	db $21, $00, $61, $00, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_12_4540::
	ld a, [$c8da]
	rst $00

JumpTable_12_4544::
	dw Jump_12_4588
	dw Jump_12_4C2B
	dw Jump_12_54AF
	dw Jump_12_59C6
	dw Jump_12_5DEC
	dw Jump_12_4550

Jump_12_4550::
	call Call_12_41EF
	ld de, $2e07
	call Call_12_40B4
	call Call_12_40E5
	call Call_2518
	ld hl, $c13c
	ld de, $c1c0
	call Call_12_457F
	ld hl, $c150
	ld de, $c1e0
	call Call_12_457F
	ld a, $80
	ldh [$ffd3], a
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Call_12_457F::
	ld b, $14

jr_012_4581:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_012_4581

	ret


Jump_12_4588::
	ld a, [$c906]
	rst $00

JumpTable_12_458C::
	dw Jump_12_45BA
	dw Jump_12_460B
	dw Jump_12_4748
	dw Jump_12_47B7
	dw Jump_12_47C2
	dw Jump_12_47EA
	dw Jump_12_4841
	dw Jump_12_4864
	dw Jump_12_4888
	dw Jump_12_48AB
	dw Jump_12_490A
	dw Jump_12_491A
	dw Jump_12_4942
	dw Jump_12_4993
	dw Jump_12_49A4
	dw Jump_12_4A19
	dw Jump_12_4A8F
	dw Jump_12_4A9A
	dw Jump_12_4AC2
	dw Jump_12_4B1E
	dw Jump_12_4B6B
	dw Jump_12_4B8F
	dw Jump_12_4BBA

Jump_12_45BA::
	ld a, [$ca8d]
	cp $00
	jr z, jr_012_45ec

	cp $01
	jr nz, jr_012_45e1

	ld hl, $0004
	call Call_12_441F
	call Call_12_4CB7
	or a
	jr nz, jr_012_45d7

	ld a, $07
	ld [$c906], a
	ret


jr_012_45d7:
	xor a
	ld [$c8dd], a
	ld a, $0a
	ld [$c906], a
	ret


jr_012_45e1:
	ld hl, $0003
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_012_45ec:
jr_012_45ec:
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $06e1
	call Call_0AD9
	ld a, $01
	ld [$c905], a
	ret


Jump_12_460B::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_4682
	call Call_12_4643
	call Call_12_4621
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_4621::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $71aa
	call Call_12_40B4
	ld de, $759a
	call Call_12_40B4
	call Call_12_46FD
	call Call_12_4323
	ld de, $47af
	ld a, [$c8db]
	call Call_12_43E2
	ret


Call_12_4643::
	ld hl, $8800
	ld a, $01
	call Call_12_465C
	ld hl, $8840
	ld a, $02
	call Call_12_465C
	ld hl, $8880
	ld a, $03
	call Call_12_465C
	ret


Call_12_465C::
	ld b, a
	ld a, [$ca8d]
	cp b
	jr nc, jr_012_4672

	ld b, $20

jr_012_4665:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_012_4665

	ret


jr_012_4672:
	push hl
	ld a, b
	dec a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	pop hl
	call Call_12_4153
	ret


Call_12_4682::
	ld a, [$c8db]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]

Call_12_4691::
	push af
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $9650
	call Call_12_4153
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $9690
	and $01
	add $a7
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


Call_12_46FD::
	ld a, [$c8db]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]

Call_12_470C::
	push af
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $016a
	call Call_12_4058
	ld a, $de
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
	call Call_12_601B
	pop af
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_012_473e

	ld hl, $0172
	call Call_12_4058
	ld a, $e3
	ld [hl], a
	ret


jr_012_473e:
	ld hl, $0172
	call Call_12_4058
	ld a, $e0
	ld [hl], a
	ret


Jump_12_4748::
	ld a, [$c825]
	or a
	ret nz

	ld de, $47af
	ld hl, $c8db
	ld a, [$ca8d]
	ld b, a
	ld a, [hl]
	push af
	call Call_12_42CA
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_012_4772

	call Call_12_4682
	ld de, $759a
	call Call_12_40B4
	call Call_12_46FD
	call Call_12_40E5

jr_012_4772:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4799

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_47ae

jr_012_4799:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_47ae

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8dc], a
	ld hl, $c906
	inc [hl]

Jump_012_47ae:
jr_012_47ae:
	ret


	db $6e, $00, $ae, $00, $ee, $00, $ff, $ff

Jump_12_47B7::
	ld hl, $0005
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_47C2::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_47D7
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_47D7::
	ld de, $7b42
	call Call_12_40B4
	call Call_12_4323
	ld de, $483b
	ld a, [$c8dc]
	call Call_12_43E2
	ret


Jump_12_47EA::
	ld de, $483b
	ld hl, $c8dc
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4813

	ld hl, far_Call_56_4485
	rst $10
	call Call_12_4621
	call Call_12_40E5
	ld hl, $0003
	call Call_12_441F
	ld a, $02
	ld [$c906], a
	jr jr_012_483a

jr_012_4813:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_483a

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_012_4836

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $08
	ld [$c906], a
	jp Jump_012_483a


jr_012_4836:
	ld hl, $c906
	inc [hl]

Jump_012_483a:
jr_012_483a:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_4841::
	ld a, [$c8db]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $0006
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_4864::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_12_4888::
	ld hl, $ca8e
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8db]
	and $7f
	ld [$c932], a
	ld a, [$ca8d]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_12_48AB::
	ld a, [$c8db]
	and $80
	ld b, a
	ld a, [$c934]
	or b
	ld [$c8db], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_4682
	call Call_12_4643
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_4621
	call Call_12_47D7
	call Call_12_40E5
	ld hl, $0005
	call Call_12_441F
	ld a, $05
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_12_490A::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0007
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_491A::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_492F
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_492F::
	ld de, $6f54
	call Call_12_40B4
	call Call_12_4323
	ld de, $498d
	ld a, [$c8dd]
	call Call_12_43E2
	ret


Jump_12_4942::
	ld de, $498d
	ld hl, $c8dd
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4974

jr_012_4954:
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_498c

jr_012_4974:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_498c

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $81
	jr z, jr_012_4954

	ld hl, $c906
	inc [hl]

Jump_012_498c:
jr_012_498c:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_4993::
	call Call_12_4CB7
	call Call_12_4CE5
	ld hl, $0008
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_49A4::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_49E5
	call Call_12_4D5D
	call Call_12_49BA
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_49BA::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $759a
	call Call_12_40B4
	call Call_12_49FF
	ld de, $71f4
	call Call_12_40B4
	call Call_12_4323
	ld de, $4e26
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	call Call_12_492F
	ret


Call_12_49E5::
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call Call_12_4691
	ret


Call_12_49FF::
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call Call_12_470C
	ret


Jump_12_4A19::
	ld a, [$c825]
	or a
	ret nz

	ld de, $4e26
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	ld hl, $c8e2
	cp [hl]
	jr z, jr_012_4a42

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_4a42:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_4a55

	call Call_12_4D5D
	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_4a55:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4a79

	ld hl, far_Call_56_4485
	rst $10
	call Call_12_41EF
	call Call_12_44CB
	call Call_12_492F
	call Call_12_40E5
	ld hl, $0007
	call Call_12_441F
	ld a, $0c
	ld [$c906], a
	jr jr_012_4a8e

jr_012_4a79:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_4a8e

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8dc], a

Jump_012_4a8e:
jr_012_4a8e:
	ret


Jump_12_4A8F::
	ld hl, $0009
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_4A9A::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_4AAF
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_4AAF::
	ld de, $7b42
	call Call_12_40B4
	call Call_12_4323
	ld de, $4b18
	ld a, [$c8dc]
	call Call_12_43E2
	ret


Jump_12_4AC2::
	ld de, $4b18
	ld hl, $c8dc
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4af1

	ld hl, far_Call_56_4485
	rst $10
	call Call_12_49E5
	call Call_12_4D5D
	call Call_12_49BA
	call Call_12_40E5
	ld hl, $0008
	call Call_12_441F
	ld a, $0f
	ld [$c906], a
	jr jr_012_4b17

jr_012_4af1:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_4b17

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_012_4b13

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $15
	ld [$c906], a
	jr jr_012_4b17

jr_012_4b13:
	ld hl, $c906
	inc [hl]

Jump_012_4b17:
jr_012_4b17:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_4B1E::
	ld a, [$ca8e]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	pop af
	ld [$ca8e], a
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $000a
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_4B6B::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_12_4B8F::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld a, a
	ld [$c932], a
	ld a, [$c8e9]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_12_4BBA::
	ld a, [$c8e2]
	and $80
	ld b, a
	ld a, [$c934]
	and $03
	or b
	ld [$c8e2], a
	ld a, [$c934]
	srl a
	srl a
	ld [$c8e3], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_4CB7
	call Call_12_4CE5
	call Call_12_4D5D
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_49E5
	call Call_12_49BA
	call Call_12_4AAF
	call Call_12_40E5
	ld hl, $0009
	call Call_12_441F
	ld a, $12
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_12_4C2B::
	ld a, [$c906]
	rst $00

JumpTable_12_4C2F::
	dw Jump_12_4C6D
	dw Jump_12_4D1F
	dw Jump_12_4DB1
	dw Jump_12_4E32
	dw Jump_12_4E3D
	dw Jump_12_4E65
	dw Jump_12_4EBC
	dw Jump_12_4F1B
	dw Jump_12_4F3F
	dw Jump_12_4F6A
	dw Jump_12_4FD5
	dw Jump_12_4FE5
	dw Jump_12_500D
	dw Jump_12_505F
	dw Jump_12_506D
	dw Jump_12_50AE
	dw Jump_12_5120
	dw Jump_12_512B
	dw Jump_12_5153
	dw Jump_12_51AB
	dw Jump_12_5210
	dw Jump_12_5234
	dw Jump_12_525F
	dw Jump_12_52CD
	dw Jump_12_52D8
	dw Jump_12_5339
	dw Jump_12_53A1
	dw Jump_12_53AC
	dw Jump_12_53D4
	dw Jump_12_542D
	dw Jump_12_5450

Jump_12_4C6D::
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_4CB7
	or a
	jr nz, jr_012_4c92

	ld hl, $000c
	call Call_12_441F
	ld a, $07
	ld [$c906], a
	ret


jr_012_4c92:
	ld a, [$ca8d]
	cp $03
	jr nz, jr_012_4ca9

	ld hl, $000d
	call Call_12_441F
	xor a
	ld [$c8dd], a
	ld a, $0a
	ld [$c906], a
	ret


jr_012_4ca9:
	call Call_12_4CE5
	ld hl, $000b
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Call_12_4CB7::
	ld de, $cac1
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
	ld [$c8e9], a
	ret


Call_12_4CE5::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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


Jump_12_4D1F::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_49E5
	call Call_12_4D5D
	call Call_12_4D32
	ld hl, $c906
	inc [hl]
	ret


Call_12_4D32::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $759a
	call Call_12_40B4
	call Call_12_49FF
	ld de, $71f4
	call Call_12_40B4
	call Call_12_4323
	ld de, $4e26
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	call Call_12_40E5
	ret


Call_12_4D5D::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call Call_12_4D77
	call Call_12_4D77
	call Call_12_4D77

Call_12_4D77::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_4d97

	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_12_4153
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_12_4DB1::
	ld a, [$c825]
	or a
	ret nz

	ld de, $4e26
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	ld hl, $c8e2
	cp [hl]
	jr z, jr_012_4dda

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_4dda:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_4ded

	call Call_12_4D5D
	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_4ded:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4e14

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_4e25

jr_012_4e14:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_4e25

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_012_4e25:
jr_012_4e25:
	ret


	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff

Jump_12_4E32::
	ld hl, $000e
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_4E3D::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_4E52
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_4E52::
	ld de, $7b42
	call Call_12_40B4
	call Call_12_4323
	ld de, $4eb6
	ld a, [$c8dc]
	call Call_12_43E2
	ret


Jump_12_4E65::
	ld de, $4eb6
	ld hl, $c8dc
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_4e8e

	ld hl, far_Call_56_4485
	rst $10
	call Call_12_4D32
	call Call_12_40E5
	ld hl, $000b
	call Call_12_441F
	ld a, $02
	ld [$c906], a
	jr jr_012_4eb5

jr_012_4e8e:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_4eb5

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_012_4eb1

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $08
	ld [$c906], a
	jp Jump_012_4eb5


jr_012_4eb1:
	ld hl, $c906
	inc [hl]

Jump_012_4eb5:
jr_012_4eb5:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_4EBC::
	ld a, [$ca8d]
	or a
	jr nz, jr_012_4eef

	xor a
	ld [$ca8e], a
	ld a, $02
	ld [$cac1], a
	ld a, $ff
	ld [$ca8f], a
	ld a, $ff
	ld [$ca90], a
	ld a, $01
	ld [$ca8d], a
	ld hl, far_Call_01_484E
	rst $10
	ld bc, $0007
	call Call_26A0
	ld hl, $000f
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


jr_012_4eef:
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$ca90], a
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $000f
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_4F1B::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_12_4F3F::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld a, a
	ld [$c932], a
	ld a, [$c8e9]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_12_4F6A::
	ld a, [$c8e2]
	and $80
	ld b, a
	ld a, [$c934]
	and $03
	or b
	ld [$c8e2], a
	ld a, [$c934]
	srl a
	srl a
	ld [$c8e3], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_49E5
	call Call_12_4D5D
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_4D32
	call Call_12_4E52
	call Call_12_40E5
	ld hl, $000e
	call Call_12_441F
	ld a, $05
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_12_4FD5::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0010
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_4FE5::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_4FFA
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_4FFA::
	ld de, $6f54
	call Call_12_40B4
	call Call_12_4323
	ld de, $5059
	ld a, [$c8dd]
	call Call_12_43E2
	ret


Jump_12_500D::
	ld de, $5059
	ld hl, $c8dd
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_503f

jr_012_501f:
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_5058

jr_012_503f:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5058

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $81
	jr z, jr_012_501f

	ld a, $17
	ld [$c906], a

Jump_012_5058:
jr_012_5058:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_505F::
	call Call_12_4CE5
	ld hl, $0013
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_506D::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_49E5
	call Call_12_4D5D
	call Call_12_5083
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_5083::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $759a
	call Call_12_40B4
	call Call_12_49FF
	ld de, $71f4
	call Call_12_40B4
	call Call_12_4323
	ld de, $4e26
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	call Call_12_4FFA
	ret


Jump_12_50AE::
	ld a, [$c825]
	or a
	ret nz

	ld de, $4e26
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	ld hl, $c8e2
	cp [hl]
	jr z, jr_012_50d7

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_50d7:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_50ea

	call Call_12_4D5D
	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_50ea:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_510a

	call Call_12_5313
	call Call_12_4643
	call Call_12_52EE
	ld hl, $0011
	call Call_12_441F
	call Call_12_40E5
	ld a, $19
	ld [$c906], a
	jr jr_012_511f

jr_012_510a:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_511f

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8dc], a

Jump_012_511f:
jr_012_511f:
	ret


Jump_12_5120::
	ld hl, $0014
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_512B::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_5140
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_5140::
	ld de, $7b42
	call Call_12_40B4
	call Call_12_4323
	ld de, $51a5
	ld a, [$c8dc]
	call Call_12_43E2
	ret


Jump_12_5153::
	ld de, $51a5
	ld hl, $c8dc
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_517e

	call Call_12_49E5
	call Call_12_4D5D
	call Call_12_5083
	ld hl, $0013
	call Call_12_441F
	call Call_12_40E5
	ld a, $0f
	ld [$c906], a
	jr jr_012_51a4

jr_012_517e:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_51a4

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_012_51a0

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $15
	ld [$c906], a
	jr jr_012_51a4

jr_012_51a0:
	ld hl, $c906
	inc [hl]

Jump_012_51a4:
jr_012_51a4:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_51AB::
	ld a, [$c8de]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld a, [$c8de]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $0015
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_5210::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_12_5234::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld a, a
	ld [$c932], a
	ld a, [$c8e9]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_12_525F::
	ld a, [$c8e2]
	and $80
	ld b, a
	ld a, [$c934]
	and $03
	or b
	ld [$c8e2], a
	ld a, [$c934]
	srl a
	srl a
	ld [$c8e3], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_4CE5
	call Call_12_49E5
	call Call_12_4D5D
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_5083
	call Call_12_5140
	call Call_12_40E5
	ld hl, $0014
	call Call_12_441F
	ld a, $12
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_12_52CD::
	ld hl, $0011
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_52D8::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_5313
	call Call_12_4643
	call Call_12_52EE
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_52EE::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $71aa
	call Call_12_40B4
	ld de, $759a
	call Call_12_40B4
	call Call_12_5326
	call Call_12_4323
	ld de, $5399
	ld a, [$c8de]
	call Call_12_43E2
	call Call_12_4FFA
	ret


Call_12_5313::
	ld a, [$c8de]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call Call_12_4691
	ret


Call_12_5326::
	ld a, [$c8de]
	and $7f
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call Call_12_470C
	ret


Jump_12_5339::
	ld a, [$c825]
	or a
	ret nz

	ld de, $5399
	ld hl, $c8de
	ld a, [$ca8d]
	ld b, a
	ld a, [hl]
	push af
	call Call_12_42CA
	pop af
	ld hl, $c8de
	cp [hl]
	jr z, jr_012_5363

	call Call_12_5313
	ld de, $759a
	call Call_12_40B4
	call Call_12_5326
	call Call_12_40E5

jr_012_5363:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_5383

	call Call_12_41EF
	call Call_12_44CB
	call Call_12_4FFA
	ld hl, $0010
	call Call_12_441F
	call Call_12_40E5
	ld a, $0c
	ld [$c906], a
	jr jr_012_5398

jr_012_5383:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5398

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8dc], a

Jump_012_5398:
jr_012_5398:
	ret


	db $6e, $00, $ae, $00, $ee, $00, $ff, $ff

Jump_12_53A1::
	ld hl, $0012
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_53AC::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_53C1
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_53C1::
	ld de, $7b42
	call Call_12_40B4
	call Call_12_4323
	ld de, $5427
	ld a, [$c8dc]
	call Call_12_43E2
	ret


Jump_12_53D4::
	ld de, $5427
	ld hl, $c8dc
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_53ff

	call Call_12_5313
	call Call_12_4643
	call Call_12_52EE
	ld hl, $0011
	call Call_12_441F
	call Call_12_40E5
	ld a, $19
	ld [$c906], a
	jr jr_012_5426

jr_012_53ff:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5426

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_012_5421

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $1d
	ld [$c906], a
	jr jr_012_5426

jr_012_5421:
	ld a, $0d
	ld [$c906], a

Jump_012_5426:
jr_012_5426:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_542D::
	ld hl, $ca8e
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8de]
	and $7f
	ld [$c932], a
	ld a, [$ca8d]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_12_5450::
	ld a, [$c8de]
	and $80
	ld b, a
	ld a, [$c934]
	or b
	ld [$c8de], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	call Call_12_5313
	call Call_12_4643
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_52EE
	call Call_12_53C1
	call Call_12_40E5
	ld hl, $0012
	call Call_12_441F
	ld a, $1c
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_12_54AF::
	ld a, [$c906]
	rst $00

JumpTable_12_54B3::
	dw Jump_12_54C5
	dw Jump_12_54D8
	dw Jump_12_55FB
	dw Jump_12_5650
	dw Jump_12_56EA
	dw Jump_12_5880
	dw Jump_12_592B
	dw Jump_12_5951
	dw Jump_12_59A2

Jump_12_54C5::
	ld a, [$ca8d]
	cp $00
	jp z, Jump_012_45ec

	ld hl, $0016
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_54D8::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_54E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_54E5::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $7768
	call Call_12_40B4
	call Call_12_5504
	call Call_12_4323
	ld de, $564a
	ld a, [$c8db]
	call Call_12_43E2
	call Call_12_40E5
	ret


Call_12_5504::
	ld hl, $00a6
	call Call_12_551D
	ld hl, $00e6
	call Call_12_5551
	ld hl, $0126
	call Call_12_5581
	ld hl, $0166
	call Call_12_55BE
	ret


Call_12_551D::
	call Call_12_4058
	push hl
	ld de, $cac1
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
	call Call_2082
	ret


Call_12_5551::
	call Call_12_4058
	push hl
	ld de, $cac1
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
	call Call_2082
	ret


Call_12_5581::
	call Call_12_4058
	ld c, $00
	ld a, [$ca41]
	bit 7, a
	jr z, jr_012_55b8

	push hl
	ld hl, $b124
	ld b, $14
	ld c, $00

jr_012_5595:
	push hl
	call Call_20EE
	or a
	jr z, jr_012_55ab

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_20EE
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
	call Call_2082
	ret


Call_12_55BE::
	call Call_12_4058
	ld c, $00
	ld a, [$ca41]
	bit 7, a
	jr z, jr_012_55f5

	push hl
	ld hl, $b124
	ld b, $14
	ld c, $00

jr_012_55d2:
	push hl
	call Call_20EE
	or a
	jr z, jr_012_55e8

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_20EE
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
	call Call_2082
	ret


Jump_12_55FB::
	ld de, $564a
	ld hl, $c8db
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_562d

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_5649

jr_012_562d:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5649

	ld a, $59
	call Call_1B2C
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld hl, $c906
	inc [hl]

Jump_012_5649:
jr_012_5649:
	ret


	db $a1, $00, $e1, $00, $ff, $ff

Jump_12_5650::
	call Call_12_5670
	or a
	jr nz, jr_012_5662

	ld hl, $0017
	call Call_12_441F
	ld a, $08
	ld [$c906], a
	ret


jr_012_5662:
	call Call_12_56A6
	ld hl, $0018
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Call_12_5670::
	ld de, $cac1
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
	ld a, [$c8db]
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
	ld [$c8e9], a
	ret


Call_12_56A6::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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
	ld a, [$c8db]
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


Jump_12_56EA::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_49E5
	call Call_12_5751
	call Call_12_56FD
	ld hl, $c906
	inc [hl]
	ret


Call_12_56FD::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $7768
	call Call_12_40B4
	call Call_12_5504
	call Call_12_4323
	ld de, $564a
	ld a, [$c8db]
	call Call_12_43E2
	ld de, $77cd
	ld a, [$c8db]
	and $01
	jr nz, jr_012_572e

	ld de, $759a
	call Call_12_40B4
	call Call_12_49FF
	ld de, $71f4

jr_012_572e:
	call Call_12_40B4
	call Call_12_4323
	ld de, $5913
	ld a, [$c8db]
	and $01
	jr z, jr_012_5741

	ld de, $591f

jr_012_5741:
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	call Call_12_40E5
	ret


Call_12_5751::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [$c8db]
	and $01
	jr nz, jr_012_5776

	ld hl, $8800
	call Call_12_4D77
	call Call_12_4D77
	call Call_12_4D77
	call Call_12_4D77
	ret


jr_012_5776:
	ld hl, $9650
	call Call_12_578C
	call Call_12_578C
	call Call_12_578C
	ld hl, $8800
	call Call_12_578C
	call Call_12_57D0
	ret


Call_12_578C::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_57b6

	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld de, $0901
	pop hl
	push hl
	call Call_12_411A
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Call_12_57D0::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call Call_12_57EA
	call Call_12_57EA
	call Call_12_57EA

Call_12_57EA::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_5866

	ld hl, $cb24
	call Call_223B
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
	ld [$c180], a
	ld a, $f0
	ld [$c181], a
	pop hl
	push hl
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_12_5880::
	ld a, [$c825]
	or a
	ret nz

	ld de, $5913
	ld a, [$c8db]
	and $01
	jr z, jr_012_5892

	ld de, $591f

jr_012_5892:
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	ld hl, $c8e2
	cp [hl]
	jr z, jr_012_58ba

	ld a, [$c8db]
	and $01
	jr nz, jr_012_58ba

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_58ba:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_58d4

	call Call_12_5751
	ld a, [$c8db]
	and $01
	jr nz, jr_012_58d4

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_58d4:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_58fa

	call Call_12_54E5
	ld hl, $0016
	call Call_12_441F
	xor a
	ld [$c8ec], a
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_012_5912

jr_012_58fa:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5912

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c906
	inc [hl]

Jump_012_5912:
jr_012_5912:
	ret


	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff, $92, $01, $a8, $00
	db $e8, $00, $28, $01, $68, $01, $ff, $ff

Jump_12_592B::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld a, a
	ld [$c932], a
	ld a, [$c8e9]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ret


Jump_12_5951::
	ld a, [$c8e2]
	and $80
	ld b, a
	ld a, [$c934]
	and $03
	or b
	ld [$c8e2], a
	ld a, [$c934]
	srl a
	srl a
	ld [$c8e3], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_49E5
	call Call_12_5751
	call Call_12_56FD
	ld hl, $0018
	call Call_12_441F
	call Call_0609
	ld a, $05
	ld [$c906], a
	ret


Jump_12_59A2::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_12_59C6::
	ld a, [$c906]
	rst $00

JumpTable_12_59CA::
	dw Jump_12_59E4
	dw Jump_12_59F7
	dw Jump_12_5A23
	dw Jump_12_5A94
	dw Jump_12_5B36
	dw Jump_12_5B9D
	dw Jump_12_5C48
	dw Jump_12_5C53
	dw Jump_12_5C85
	dw Jump_12_5CDF
	dw Jump_12_5D3F
	dw Jump_12_5D63
	dw Jump_12_5D8E

Jump_12_59E4::
	ld a, [$ca8d]
	cp $00
	jp z, Jump_012_45ec

	ld hl, $001a
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_59F7::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_5A07
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_5A07::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $7768
	call Call_12_40B4
	call Call_12_5504
	call Call_12_4323
	ld de, $5a8e
	ld a, [$c8db]
	call Call_12_43E2
	ret


Jump_12_5A23::
	ld de, $5a8e
	ld hl, $c8db
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_5a55

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_5a74

jr_012_5a55:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5a74

	ld a, $59
	call Call_1B2C
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	call Call_12_5A75
	ld hl, $c906
	inc [hl]

Jump_012_5a74:
jr_012_5a74:
	ret


Call_12_5A75::
	ld a, $02
	ld [$c822], a
	ld a, [$c8db]
	and $01
	add $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ret


	db $a1, $00, $e1, $00, $ff, $ff

Jump_12_5A94::
	call Call_12_5AB4
	or a
	jr nz, jr_012_5aa6

	ld hl, $001b
	call Call_12_441F
	ld a, $0a
	ld [$c906], a
	ret


jr_012_5aa6:
	call Call_12_5AEE
	ld hl, $001c
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Call_12_5AB4::
	ld de, $cac1
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
	ld a, [$c8db]
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
	ld [$c8e9], a
	ret


Call_12_5AEE::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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
	ld a, [$c8db]
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


Jump_12_5B36::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_49E5
	call Call_12_5751
	call Call_12_41EF
	call Call_12_5B4F
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_5B4F::
	call Call_12_44CB
	ld de, $7768
	call Call_12_40B4
	call Call_12_5504
	call Call_12_4323
	ld de, $5a8e
	ld a, [$c8db]
	call Call_12_43E2
	ld de, $77cd
	ld a, [$c8db]
	and $01
	jr nz, jr_012_5b7d

	ld de, $759a
	call Call_12_40B4
	call Call_12_49FF
	ld de, $71f4

jr_012_5b7d:
	call Call_12_40B4
	call Call_12_4323
	ld de, $5c30
	ld a, [$c8db]
	and $01
	jr z, jr_012_5b90

	ld de, $5c3c

jr_012_5b90:
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	ret


Jump_12_5B9D::
	ld a, [$c825]
	or a
	ret nz

	ld de, $5c30
	ld a, [$c8db]
	and $01
	jr z, jr_012_5baf

	ld de, $5c3c

jr_012_5baf:
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	ld hl, $c8e2
	cp [hl]
	jr z, jr_012_5bd7

	ld a, [$c8db]
	and $01
	jr nz, jr_012_5bd7

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_5bd7:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_5bf1

	call Call_12_5751
	ld a, [$c8db]
	and $01
	jr nz, jr_012_5bf1

	call Call_12_49E5
	call Call_12_49FF
	call Call_12_40E5

jr_012_5bf1:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_5c1a

	call Call_12_5A07
	call Call_12_40E5
	ld hl, $001a
	call Call_12_441F
	xor a
	ld [$c8ec], a
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_012_5c2f

jr_012_5c1a:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5c2f

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8de], a
	ld hl, $c906
	inc [hl]

Jump_012_5c2f:
jr_012_5c2f:
	ret


	db $52, $01, $6e, $00, $ae, $00, $ee, $00, $2e, $01, $ff, $ff, $92, $01, $a8, $00
	db $e8, $00, $28, $01, $68, $01, $ff, $ff

Jump_12_5C48::
	ld hl, $001d
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_5C53::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_12_5C68
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_5C68::
	ld de, $7b42
	ld a, [$c8db]
	and $01
	jr z, jr_012_5c75

	ld de, $7b6c

jr_012_5c75:
	call Call_12_40B4
	call Call_12_4323
	ld de, $5cd9
	ld a, [$c8de]
	call Call_12_43E2
	ret


Jump_12_5C85::
	ld de, $5cd9
	ld hl, $c8de
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_5cb1

	xor a
	ld [$c8ec], a
	call Call_12_41EF
	call Call_12_5B4F
	ld hl, $001c
	call Call_12_441F
	call Call_12_40E5
	ld a, $05
	ld [$c906], a
	jr jr_012_5cd8

jr_012_5cb1:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5cd8

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_012_5cd4

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $0b
	ld [$c906], a
	jp Jump_012_5cd8


jr_012_5cd4:
	ld hl, $c906
	inc [hl]

Jump_012_5cd8:
jr_012_5cd8:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_12_5CDF::
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	pop af
	push af
	ld hl, $cac1
	call Call_223B
	ld [hl], $00
	pop af
	ld hl, $cb24
	call Call_223B
	ld a, [hl]
	or a
	jr z, jr_012_5d2c

	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $0b1d
	call Call_096D
	ld hl, $c906
	inc [hl]
	ret


jr_012_5d2c:
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $001e
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_5D3F::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_12_5D63::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld a, a
	ld [$c932], a
	ld a, [$c8e9]
	ld [$c933], a
	ld hl, far_Call_07_6468
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_12_5D8E::
	ld a, [$c8e2]
	and $80
	ld b, a
	ld a, [$c934]
	and $03
	or b
	ld [$c8e2], a
	ld a, [$c934]
	srl a
	srl a
	ld [$c8e3], a
	ld de, $2e10
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $44
	ld [$c823], a
	ld hl, $9600
	ld de, $0501
	call Call_12_411A
	call Call_12_5A75
	call Call_12_49E5
	call Call_12_5751
	ld hl, far_Call_56_4485
	rst $10
	call Call_12_41EF
	call Call_12_5B4F
	call Call_12_5C68
	call Call_12_40E5
	ld hl, $001d
	call Call_12_441F
	ld a, $08
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_12_5DEC::
	ld a, [$c906]
	rst $00

JumpTable_12_5DF0::
	dw Jump_12_5DFE
	dw Jump_12_5E58
	dw Jump_12_5E81
	dw Jump_12_5ED2
	dw Jump_12_5F29
	dw Jump_12_5F3D
	dw Jump_12_5FF7

Jump_12_5DFE::
	ld a, [$ca8d]
	cp $00
	jp z, Jump_012_45ec

	ld hl, $cac1
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

	ld a, [$ca41]
	bit 7, a
	jr z, jr_012_5e3c

	ld hl, $b124
	ld b, $14

jr_012_5e27:
	push hl
	push bc
	call Call_20EE
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
	call Call_0AD9
	ld a, $06
	ld [$c906], a
	ret


jr_012_5e48:
	ld hl, $0025
	jr jr_012_5e50

jr_012_5e4d:
	ld hl, $0022

jr_012_5e50:
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_12_5E58::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_5E65
	ld hl, $c906
	inc [hl]
	ret


Call_12_5E65::
	call Call_12_41EF
	call Call_12_44CB
	ld de, $78ab
	call Call_12_40B4
	call Call_12_4323
	ld de, $5ecc
	ld a, [$c8dc]
	call Call_12_43E2
	call Call_12_40E5
	ret


Jump_12_5E81::
	ld de, $5ecc
	ld hl, $c8e2
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_5eb3

jr_012_5e93:
	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	jr jr_012_5ecb

jr_012_5eb3:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_5ecb

	ld a, $59
	call Call_1B2C
	ld a, [$c8e2]
	cp $81
	jr z, jr_012_5e93

	ld hl, $c906
	inc [hl]

Jump_012_5ecb:
jr_012_5ecb:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_12_5ED2::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_5FDE
	ld hl, $cac1
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
	ld a, [$ca41]
	bit 7, a
	jr z, jr_012_5f15

	ld hl, $b124
	ld b, $14

jr_012_5f00:
	push hl
	push bc
	call Call_20EE
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
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ld hl, $c906
	inc [hl]
	ret


Jump_12_5F29::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0022
	call Call_12_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ret


Jump_12_5F3D::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld bc, $0000

jr_012_5f58:
	ld a, b
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr z, jr_012_5f68

	call Call_12_5FB3
	inc c

jr_012_5f68:
	inc b
	ld a, b
	cp $14
	jr nz, jr_012_5f58

	ld hl, far_Call_01_46F6
	rst $10
	ld a, [$c8eb]
	push af
	xor a
	ld [$c8eb], a
	ld a, [$c905]
	push af
	xor a
	ld [$c905], a
	ld a, [$d8d7]
	push af
	xor a
	ld [$d8d7], a
	ld a, [$c8ec]
	push af
	xor a
	ld [$c8ec], a
	di
	call Call_2128
	ei
	pop af
	ld [$c8ec], a
	pop af
	ld [$d8d7], a
	pop af
	ld [$c905], a
	pop af
	ld [$c8eb], a
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Call_12_5FB3::
	push bc
	ld a, b
	ld hl, $cac1
	call Call_223B
	push hl
	ld a, c
	ld c, $95
	call Call_1DBE
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
	call Call_20EE
	ld [de], a
	pop af
	call Call_20FE
	inc de
	inc hl
	dec b
	jr nz, jr_012_5fcd

	pop bc
	ret


Call_12_5FDE::
	ld hl, $ca41
	bit 7, [hl]
	ret nz

	set 7, [hl]
	ld hl, $b124
	ld bc, $0ba4

jr_012_5fec:
	xor a
	call Call_20FE
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, jr_012_5fec

	ret


Jump_12_5FF7::
	ld a, [$c825]
	or a
	ret nz

	ld a, $02
	ld [$c822], a
	ld a, $33
	ld [$c823], a
	ld hl, $8aa0
	ld de, $0601
	call Call_12_411A
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c905], a
	ret


Call_12_601B::
	ld de, $000a
	push bc
	call Call_12_6037
	pop bc
	or a
	jr z, jr_012_6032

	ld de, $000a
	call Call_12_6037
	call Call_12_604C
	call Call_12_6052

jr_012_6032:
	ld a, c
	call Call_12_604C
	ret


Call_12_6037::
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


Call_12_604C::
	add $f0
	call Call_1AAD
	ret


Call_12_6052::
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


Jump_12_6061::
	ld a, [$c905]
	rst $00

JumpTable_12_6065::
	dw Jump_12_606F
	dw Jump_12_60CC
	dw Jump_12_60D1
	dw Jump_12_60F0
	dw Jump_12_60F3

Jump_12_606F::
	ld hl, $ffb7
	call Call_12_4028
	ld hl, $ffbb
	call Call_12_4028
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
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
	ld [$c909], a
	ld a, h
	ld [$c90a], a
	ld hl, far_Call_17_4192
	rst $10
	call Call_12_4221
	ld de, $2e07
	call Call_12_40B4
	call Call_12_40E5
	ld de, $2e14
	ld hl, $9000
	call Call_1577
	call Call_12_4323
	ld a, $01
	ld [$c8ec], a
	ld hl, $c905
	inc [hl]
	ret


Jump_12_60CC::
	ld hl, $c905
	inc [hl]
	ret


Jump_12_60D1::
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ret


Jump_12_60F0::
	jp Jump_012_6119


Jump_12_60F3::
	call Call_12_4221
	call Call_12_40E5
	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_0B_40CE
	rst $10
	call Call_2518
	call Call_25F1
	ld hl, far_Call_06_4D5A
	rst $10
	xor a
	ld [$c8ec], a
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Jump_012_6119:
	ld a, [$c906]
	rst $00

JumpTable_12_611D::
	dw Jump_12_6133
	dw Jump_12_6138
	dw Jump_12_61B8
	dw Jump_12_6234
	dw Jump_12_629F
	dw Jump_12_632A
	dw Jump_12_63AC
	dw Jump_12_64C9
	dw Jump_12_6554
	dw Jump_12_6569
	dw Jump_12_657A

Jump_12_6133::
	ld hl, $c906
	inc [hl]
	ret


Jump_12_6138::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_616E
	call Call_12_614E
	call Call_12_61A0
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_12_614E::
	call Call_12_4221
	ld de, $2e07
	call Call_12_40B4
	ld de, $78d0
	call Call_12_40B4
	call Call_12_4323
	ld de, $6226
	ld b, $05
	ld c, $0a
	ld hl, $c8da
	call Call_12_43C0
	ret


Call_12_616E::
	ld a, [$c8db]
	ld b, a
	add a
	add a
	add b
	ld hl, $9670
	call Call_12_6184
	call Call_12_6184
	call Call_12_6184
	call Call_12_6184

Call_12_6184::
	push af
	push hl
	ld [$c823], a
	ld a, $04
	ld [$c822], a
	ld de, $0501
	call Call_12_411A
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


Call_12_61A0::
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	call Call_12_6242
	call Call_12_62CE
	ld de, $7935
	call Call_12_40B4
	ret


Jump_12_61B8::
	ld de, $6226
	ld hl, $c8da
	ld c, $0a
	ld b, $05
	ld a, [hli]
	push af
	ld a, [hld]
	push af
	call Call_12_4241
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_012_61d9

	call Call_12_616E
	call Call_12_61A0
	call Call_12_40E5

jr_012_61d9:
	pop af
	ld hl, $c8da
	cp [hl]
	jr z, jr_012_61e6

	call Call_12_61A0
	call Call_12_40E5

jr_012_61e6:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_6219

	call Call_12_6242
	ld a, [$c8e8]
	or a
	jr nz, jr_012_6205

	ld hl, $0004
	call Call_12_441F
	ld a, $09
	ld [$c906], a
	jp Jump_012_6225


jr_012_6205:
	ld a, $59
	call Call_1B2C
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld hl, $c906
	inc [hl]

Jump_012_6219:
	ld a, [$c846]
	bit 1, a
	jp z, Jump_012_6225

	ld hl, $c905
	inc [hl]

Jump_012_6225:
	ret


	db $46, $01, $21, $00, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

Jump_12_6234::
	call Call_12_6242
	ld hl, $0003
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Call_12_6242::
	ld hl, $c0d8
	ld bc, $0020
	ld a, $ff
	call Call_12C7
	ld a, [$c8db]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8da]
	and $7f
	add b
	ld [$cac0], a
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
	ld hl, $c0d8

jr_012_6271:
	push bc
	push de
	push hl
	ld hl, $ca94
	ld a, b
	call Call_267E
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
	ld [$c8e9], a
	ld a, e
	ld [$c8e8], a
	ret


	db $00, $14, $2d, $46, $5a, $6e, $82, $9b, $af, $c8, $d7

Jump_12_629F::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_62CE
	call Call_12_62AF
	ld hl, $c906
	inc [hl]
	ret


Call_12_62AF::
	call Call_12_614E
	ld de, $7935
	call Call_12_40B4
	call Call_12_4323
	ld de, $639e
	ld b, $05
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	call Call_12_40E5
	ret


Call_12_62CE::
	ld a, [$c8e3]
	ld b, a
	add a
	add a
	add b
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call Call_12_62ED
	call Call_12_62ED
	call Call_12_62ED
	call Call_12_62ED

Call_12_62ED::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_6310

	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld de, $0901
	pop hl
	push hl
	call Call_12_411A
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


Jump_012_6310:
jr_012_6310:
	ld b, $48

jr_012_6312:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_12_632A::
	ld de, $639e
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $05
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_6349

	call Call_12_62CE

jr_012_6349:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_6369

	call Call_12_614E
	ld de, $7935
	call Call_12_40B4
	call Call_12_40E5
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c906], a
	jr jr_012_639d

jr_012_6369:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_639d

	ld a, [$c8e3]
	ld b, a
	add a
	add a
	add b
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld [$c8dc], a
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$cac0], a
	cp $e0
	jp z, Jump_012_639d

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_012_639d:
jr_012_639d:
	ret


	db $52, $01, $29, $00, $69, $00, $a9, $00, $e9, $00, $29, $01, $ff, $ff

Jump_12_63AC::
	call Call_12_4221
	call Call_12_40E5
	call Call_12_63D0
	call Call_12_63BD
	ld hl, $c906
	inc [hl]
	ret


Call_12_63BD::
	ld de, $2e26
	ld hl, $8a50
	call Call_1577
	ld de, $79c6
	call Call_12_40B4
	call Call_12_40E5
	ret


Call_12_63D0::
	ld a, [$cac0]
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld hl, $9140
	ld de, $0901
	call Call_12_411A
	ld hl, $ca94
	ld a, [$cac0]
	call Call_267E
	ld a, $ff
	jr z, jr_012_63f4

	ld a, [$cac0]

jr_012_63f4:
	ld [$c823], a
	ld a, $00
	ld [$c822], a
	ld hl, $91d0
	ld de, $1201
	call Call_12_6456
	ld a, [$cac0]
	ld [$c823], a
	ld a, $01
	ld [$c822], a
	ld hl, $94a0
	ld de, $1203
	call Call_12_6456
	call Call_12_648F
	ld a, [$cac0]
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
	call Call_1577
	ld hl, $0021
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld a, [$cac0]
	ld [$c81e], a
	ld a, $04
	ld [$c81f], a
	ld hl, far_Call_17_41D0
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	call Call_12_65A8
	ret


Call_12_6456::
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
	ld hl, far_Call_4D_43C7
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


Call_12_648F::
	ld a, [$cac0]
	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld de, $da39
	ld hl, $92f0
	call Call_12_64A5
	call Call_12_64A5

Call_12_64A5::
	push de
	push hl
	ld a, [de]
	cp $ff
	jp z, Jump_012_6310

	ld [$c823], a
	ld a, $06
	ld [$c822], a
	ld de, $0901
	pop hl
	push hl
	call Call_12_411A
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


Jump_12_64C9::
	ld a, [$c8e9]
	or a
	jr z, jr_012_6526

	cp $01
	jr z, jr_012_6526

	ld a, [$c846]
	bit 5, a
	jr z, jr_012_64fd

jr_012_64da:
	ld a, [$c8e9]
	ld c, a
	cp $01
	jr z, jr_012_64fd

	ld a, [$c8dc]
	dec a
	ld [$c8dc], a
	cp c
	jr c, jr_012_64f1

	dec c
	ld a, c
	ld [$c8dc], a

jr_012_64f1:
	call Call_12_6544
	jr z, jr_012_64da

	ld a, $0a
	ld [$c906], a
	jr jr_012_6543

jr_012_64fd:
	ld a, [$c846]
	bit 4, a
	jr z, jr_012_6526

jr_012_6504:
	ld a, [$c8e9]
	ld c, a
	cp $01
	jr z, jr_012_6526

	ld a, [$c8dc]
	inc a
	ld [$c8dc], a
	cp c
	jr c, jr_012_651a

	xor a
	ld [$c8dc], a

jr_012_651a:
	call Call_12_6544
	jr z, jr_012_6504

	ld a, $0a
	ld [$c906], a
	jr jr_012_6543

jr_012_6526:
	ld a, [$c846]
	bit 1, a
	jr nz, jr_012_6535

	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_6540

jr_012_6535:
	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	jr jr_012_6543

Jump_012_6540:
	call Call_12_67C0

jr_012_6543:
	ret


Call_12_6544::
	ld a, [$c8dc]
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $e0
	ret


Jump_12_6554::
	call Call_12_4221
	call Call_12_40E5
	call Call_12_616E
	call Call_12_62CE
	call Call_12_62AF
	ld a, $05
	ld [$c906], a
	ret


Jump_12_6569::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c906], a
	ret


Jump_12_657A::
	ld a, [$c8dc]
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$cac0], a
	call Call_12_63D0
	call Call_12_63BD
	ld a, $07
	ld [$c906], a
	ld a, [$c8dc]
	ld b, a
	ld a, $05
	call Call_1DFB
	or $80
	ld [$c8e2], a
	ld a, b
	ld [$c8e3], a
	ret


Call_12_65A8::
	ld a, [$cac0]
	ld [$da6f], a
	ld hl, far_Call_16_485C
	rst $10
	ld a, [$da71]
	ld hl, $8600
	call Call_12_65CB
	ld [$da71], a
	ld a, [$da72]
	ld hl, $8700
	call Call_12_65CB
	ld [$da72], a
	ret


Call_12_65CB::
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
	call Call_1577
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

Call_12_67C0::
	ld hl, $ca94
	ld a, [$cac0]
	call Call_267E
	ret z

	ld a, [$da71]
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
	ld a, [$da71]
	cp $ff
	jr z, jr_012_6810

	push af
	ld hl, $ffc3
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
	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10

jr_012_6810:
	ld a, [$da72]
	cp $ff
	ret z

	push af
	ld hl, $ffc3
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
	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10
	ret


Jump_12_6842::
	ld a, [$c905]
	rst $00

JumpTable_12_6846::
	dw Jump_12_6850
	dw Jump_12_68A0
	dw Jump_12_68A5
	dw Jump_12_68C4
	dw Jump_12_68C6

Jump_12_6850::
	ld hl, $ffb7
	call Call_12_4028
	ld hl, $ffbb
	call Call_12_4028
	ld a, $ff
	ld [$c8f4], a
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
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
	ld [$c909], a
	ld a, h
	ld [$c90a], a
	call Call_12_41EF
	ld de, $2e11
	ld hl, $8800
	call Call_1577
	call Call_12_4323
	ld hl, $c905
	inc [hl]
	ret


Jump_12_68A0::
	ld hl, $c905
	inc [hl]
	ret


Jump_12_68A5::
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ret


Jump_12_68C4::
	jr jr_012_68dc

Jump_12_68C6::
	call Call_12_41EF
	ld de, $2e07
	call Call_12_40B4
	call Call_12_40E5
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


jr_012_68dc:
	ld a, [$c906]
	rst $00

JumpTable_12_68E0::
	dw Jump_12_68F2
	dw Jump_12_6928
	dw Jump_12_69AF
	dw Jump_12_69F7
	dw Jump_12_6A06
	dw Jump_12_6A2A
	dw Jump_12_6A68
	dw Jump_12_6AE3
	dw Jump_12_6AED

Jump_12_68F2::
	call Call_12_6903
	call Call_12_690A
	ld hl, $0003
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ret


Call_12_6903::
	ld a, [$ca8d]
	ld [$c8e9], a
	ret


Call_12_690A::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld a, [$ca8e]
	ld [$c0d8], a
	ld a, [$ca8f]
	ld [$c0d9], a
	ld a, [$ca90]
	ld [$c0da], a
	ret


Jump_12_6928::
	ld a, [$c825]
	or a
	ret nz

	call Call_12_695D
	call Call_12_6938
	ld hl, $c906
	inc [hl]
	ret


Call_12_6938::
	call Call_12_41EF
	ld de, $2e07
	call Call_12_40B4
	ld de, $724e
	call Call_12_40B4
	call Call_12_4323
	ld de, $69ed
	ld b, $03
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_12_43C0
	call Call_12_40E5
	ret


Call_12_695D::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call Call_12_6974
	call Call_12_6974

Call_12_6974::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_012_6995

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_12_4153
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_12_69AF::
	ld de, $69ed
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $03
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_12_4241
	pop af
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_012_69ce

	call Call_12_695D

jr_012_69ce:
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_69db

	ld hl, $c905
	inc [hl]
	jr jr_012_69ec

jr_012_69db:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_69ec

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_012_69ec:
jr_012_69ec:
	ret


	db $05, $01, $61, $00, $a1, $00, $e1, $00, $ff, $ff

Jump_12_69F7::
	ld hl, $0005
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8de], a
	ret


Jump_12_6A06::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6dcb
	call Call_12_40B4
	call Call_12_4323
	ld de, $6a62
	ld a, [$c8de]
	call Call_12_43E2
	call Call_12_40E5
	ld hl, $c906
	inc [hl]
	ret


Jump_12_6A2A::
	ld de, $6a62
	ld hl, $c8de
	ld b, $02
	call Call_12_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_012_6a49

jr_012_6a3c:
	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c906], a
	jr jr_012_6a61

jr_012_6a49:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_012_6a61

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_012_6a3c

	ld hl, $c906
	inc [hl]

Jump_012_6a61:
jr_012_6a61:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_12_6A68::
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$cac0], a
	ld hl, $cacd
	call Call_223B
	ld de, $ca42
	ld b, $09

jr_012_6a8c:
	ld a, [de]
	cp [hl]
	jr z, jr_012_6a9f

	ld hl, $0004
	call Call_12_441F
	ld hl, $c906
	inc [hl]
	ld hl, $c906
	inc [hl]
	ret


jr_012_6a9f:
	inc de
	inc hl
	dec b
	jr nz, jr_012_6a8c

	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	add $10
	ld [$c8f4], a
	ld a, [$cac0]
	ld hl, $cac2
	call Call_223B
	ld a, l
	ld [$c8f2], a
	ld a, h
	ld [$c8f3], a
	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld [$c8f6], a
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$c8f5], a
	ld hl, $c906
	inc [hl]
	ret


Jump_12_6AE3::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c905
	inc [hl]
	ret


Jump_12_6AED::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_12_441F
	ld a, $01
	ld [$c906], a
	ret


Jump_12_6AFE::
	ld a, [$c905]
	rst $00

JumpTable_12_6B02::
	dw Jump_12_6B0E
	dw Jump_12_6B7C
	dw Jump_12_6BEE
	dw Jump_12_6C90
	dw Jump_12_6CAA
	dw Jump_12_6D1A

Jump_12_6B0E::
	ld hl, $ca51
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
	ld [$c907], a
	or a
	jr z, jr_012_6b77

	ld a, [$c903]
	ld l, a
	ld a, [$c904]
	ld h, a
	ld a, [$c907]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$c903], a
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
	ld [$c903], a
	ld a, h
	ld [$c904], a

jr_012_6b56:
	ld hl, far_Call_03_7160
	rst $10
	ld a, [$d9e1]
	cp $04
	jr z, jr_012_6b6c

	ld hl, $0001
	call Call_12_441F
	ld hl, $c905
	inc [hl]
	ret


jr_012_6b6c:
	ld hl, $000f
	call Call_12_441F
	ld hl, $c905
	inc [hl]
	ret


jr_012_6b77:
	ld hl, $c905
	inc [hl]
	ret


Jump_12_6B7C::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c903]
	ld c, a
	ld a, [$c904]
	ld b, a
	ld hl, $c180
	call Call_0A7C
	ld a, [$d9e1]
	cp $04
	jr z, jr_012_6bd0

	ld a, [$d9e1]
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
	ld hl, $c190
	call Call_0A7C
	pop bc
	ld a, [$c903]
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
	call Call_12_441F
	ld hl, $c905
	inc [hl]
	ret


jr_012_6bca:
	ld a, $04
	ld [$c905], a
	ret


jr_012_6bd0:
	ld a, [$c907]
	or a
	jr z, jr_012_6bca

	ld a, [$c907]
	ld c, a
	ld b, $00
	ld hl, $c180
	call Call_0A7C
	ld hl, $0010
	call Call_12_441F
	ld a, $04
	ld [$c905], a
	ret


Jump_12_6BEE::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $cac1
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
	ld [$da14], a
	ld a, [$d9e1]
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
	ld [$da12], a
	ld a, b
	ld [$da13], a
	ld hl, far_Call_14_40B4
	rst $10
	ld a, [$da14]
	ld hl, $cb24
	call Call_223B
	ld [hl], $01
	ld a, [$d9e1]
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
	call Call_26A0

jr_012_6c7b:
	ld hl, $d9e1
	inc [hl]
	ld hl, $c905
	inc [hl]
	ret


jr_012_6c84:
	ld hl, $000b
	call Call_12_441F
	ld a, $05
	ld [$c905], a
	ret


Jump_12_6C90::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$d9e1]
	ld hl, $0002
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_12_441F
	ld a, $05
	ld [$c905], a
	ret


Jump_12_6CAA::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c903]
	ld c, a
	ld a, [$c904]
	ld b, a
	ld hl, $c180
	call Call_0A7C
	ld a, [$d9e1]
	cp $04
	jr z, jr_012_6d0f

	ld a, [$d9e1]
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
	ld hl, $c190
	call Call_0A7C
	ld a, [$d9e1]
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
	ld [$da12], a
	ld a, b
	ld [$da13], a
	ld hl, far_Call_14_400F
	rst $10
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c1a0
	call Call_097A
	ld hl, $000c
	call Call_12_441F
	ld hl, $c905
	inc [hl]
	ret


jr_012_6d0f:
	ld hl, $0011
	call Call_12_441F
	ld hl, $c905
	inc [hl]
	ret


Jump_12_6D1A::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
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
