INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $00a", ROMX[$4000], BANK[$a]

BankNumber_0A::
	db $0a

FarTable_0A::
	dw Call_0A_4003

Call_0A_4003::
	ld a, [$c8ef]
	rst $00

JumpTable_0A_4007::
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_442D
	dw Jump_0A_4BC3
	dw Jump_0A_6095
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_6966
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_4027
	dw Jump_0A_4027

Jump_0A_4027::
	ret


Call_0A_4028::
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


Call_0A_4035::
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


Call_0A_4044::
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


Call_0A_4058::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_0A_4061::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_0A_4044
	ld a, b
	and $1f
	jr z, jr_00a_4076

	ld b, a

jr_00a_4070:
	call Call_0A_4035
	dec b
	jr nz, jr_00a_4070

jr_00a_4076:
	pop bc
	ret


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
	call Call_0A_4058
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a

jr_00a_40c3:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_00a_40e2

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
	jr jr_00a_40c3

jr_00a_40e2:
	ld [hli], a
	jr jr_00a_40c3

Call_0A_40E5::
	ld a, [$c909]
	ld l, a
	ld a, [$c90a]
	ld h, a
	ld de, $c500
	ld c, $12

jr_00a_40f2:
	ld b, $20
	push hl

jr_00a_40f5:
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


Call_0A_411A::
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


Call_0A_4153::
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

Call_0A_41EF::
	ld hl, $c500
	ld de, $c300
	ld bc, $0200

jr_00a_41f8:
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_00a_41f8

	ld de, $c1c0
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


	db $21, $00, $c5, $01, $40, $02, $3e, $e0, $22, $0b, $78, $b1, $20, $f8, $c9, $21
	db $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6, $c9

Call_0A_4241::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_00a_42a8

	ld a, [$c847]
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
	call Call_1DFB
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
	ld a, [$c847]
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
	call Call_1DFB
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
	call Call_1DFB
	ld [$c8e1], a
	ld a, b
	pop bc
	pop de
	ld c, a
	inc hl
	ld a, [hld]
	cp c
	jr nz, Call_0A_42CA

	ld a, [$c8e1]
	inc a
	ld b, a

Call_0A_42CA::
	res 7, [hl]
	ld a, [$c847]
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
	ld a, [$c847]
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
	ld [$c90c], a
	push hl
	push de
	pop de
	pop hl

jr_00a_42f3:
	ld a, [$c846]
	bit 0, a
	jr z, jr_00a_42fc

	set 7, [hl]

jr_00a_42fc:
	ld a, [hl]
	call Call_0A_4328
	ret


	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

Call_0A_4323::
	xor a
	ld [$c90c], a
	ret


Call_0A_4328::
	ld c, a
	bit 7, a
	jr nz, jr_00a_433d

	ld a, [$c90c]
	and $0f
	push af
	ld a, [$c90c]
	inc a
	ld [$c90c], a
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_0A_4061
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

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_00a_4370

	ld a, $e8

jr_00a_4370:
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_0A_4061
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


Call_0A_43C0::
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_0A_4061
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_00a_440d

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_00a_440d

	ld a, $e8

jr_00a_440d:
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


Call_0A_441F::
	ld a, [$c8f0]
	add l
	ld l, a
	ld a, [$c8f1]
	adc h
	ld h, a
	call Call_0AD9
	ret


Jump_0A_442D::
	ld a, [$c905]
	rst $00

JumpTable_0A_4431::
	dw Jump_0A_443B
	dw Jump_0A_448A
	dw Jump_0A_44B6
	dw Jump_0A_450E
	dw Jump_0A_4516

Jump_0A_443B::
	ld hl, $ffb7
	call Call_0A_4028
	ld hl, $ffbb
	call Call_0A_4028
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
	call Call_0A_41EF
	ld de, $2e11
	ld hl, $8800
	call Call_1577
	call Call_0A_4323
	ld a, $78
	ldh [$ffd4], a
	ld hl, $c905
	inc [hl]
	ret


Jump_0A_448A::
	ld hl, $c905
	inc [hl]
	ld a, $5c
	call Call_1B2C
	call Call_0A_41EF
	call Call_0A_449D
	call Call_0A_40E5
	ret


Call_0A_449D::
	ld de, $6f3c
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4508
	ld a, [$c8da]
	call Call_0A_43E2
	ret


Jump_0A_44B6::
	ld de, $4508
	ld hl, $c8da
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	and $0a
	jr z, jr_00a_44d2

	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	jr jr_00a_4507

jr_00a_44d2:
	ld a, [$c846]
	bit 0, a
	jr z, jr_00a_4507

	ld a, $59
	call Call_1B2C
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8da
	set 7, [hl]
	ld a, [hl]
	ld [$c907], a
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	jr jr_00a_4507

jr_00a_4507:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_0A_450E::
	ld a, [$c907]
	rst $00

JumpTable_0A_4512::
	dw Jump_0A_4538
	dw Jump_0A_4516

Jump_0A_4516::
	call Call_0A_41EF
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	xor a
	ld [$c8ec], a
	ld a, $80
	ldh [$ffd3], a
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ld hl, far_Call_01_484E
	rst $10
	ret


Jump_0A_4538::
	ld a, [$c906]
	rst $00

JumpTable_0A_453C::
	dw Jump_0A_455E
	dw Jump_0A_45D2
	dw Jump_0A_479D
	dw Jump_0A_482B
	dw Jump_0A_4836
	dw Jump_0A_487D
	dw Jump_0A_491A
	dw Jump_0A_4925
	dw Jump_0A_4949
	dw Jump_0A_498E
	dw Jump_0A_49AB
	dw Jump_0A_49CF
	dw Jump_0A_4A10
	dw Jump_0A_4AD3
	dw Jump_0A_4B1B
	dw Jump_0A_4B46
	dw Jump_0A_4B81

Jump_0A_455E::
	call Call_0A_4572
	call Call_0A_459C
	call Call_0A_4BA2
	ld hl, $0002
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Call_0A_4572::
	ld de, $cac1
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
	ld [$c8e9], a
	ret


Call_0A_459C::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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


Jump_0A_45D2::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_46C9
	call Call_0A_4610
	call Call_0A_45E5
	ld hl, $c906
	inc [hl]
	ret


Call_0A_45E5::
	call Call_0A_41EF
	call Call_0A_449D
	ld de, $7731
	call Call_0A_40B4
	call Call_0A_474B
	ld de, $7409
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $481f
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	call Call_0A_40E5
	ret


Call_0A_4610::
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
	call Call_0A_462A
	call Call_0A_462A
	call Call_0A_462A

Call_0A_462A::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_4657

	push de
	ld hl, $cb24
	call Call_223B
	pop de
	ld a, [hl]
	or a
	jr nz, jr_00a_4671

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0A_4153
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
	call Call_1AB9
	xor a
	call Call_1AB9
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
	ld [$c823], a
	ld a, $02
	ld [$c822], a
	ld de, $0401
	pop hl
	push hl
	call Call_0A_411A
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
	ld hl, $cacb
	call Call_223B
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
	call Call_1577
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

Call_0A_46C9::
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
	ld hl, $9780
	call Call_0A_4153
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $97c0
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


Call_0A_474B::
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
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $0161
	call Call_0A_4058
	ld a, $de
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
	call Call_0A_6027
	pop af
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_00a_4793

	ld hl, $0169
	call Call_0A_4058
	ld a, $e3
	ld [hl], a
	ret


jr_00a_4793:
	ld hl, $0169
	call Call_0A_4058
	ld a, $e0
	ld [hl], a
	ret


Jump_0A_479D::
	ld a, [$c825]
	or a
	ret nz

	ld de, $481f
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_0A_4241
	pop af
	ld hl, $c8e2
	cp [hl]
	jr z, jr_00a_47c6

	call Call_0A_46C9
	call Call_0A_474B
	call Call_0A_40E5

jr_00a_47c6:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_00a_47d9

	call Call_0A_46C9
	call Call_0A_4610
	call Call_0A_474B
	call Call_0A_45E5

jr_00a_47d9:
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_47f0

	call Call_0A_4BA2
	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_481e

jr_00a_47f0:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_481e

	ld a, $59
	call Call_1B2C
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
	xor a
	ld [$c8dc], a
	ld hl, $c906
	inc [hl]

Jump_00a_481e:
jr_00a_481e:
	ret


	db $45, $01, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

Jump_0A_482B::
	ld hl, $0005
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_4836::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_4843
	ld hl, $c906
	inc [hl]
	ret


Call_0A_4843::
	call Call_0A_41EF
	call Call_0A_449D
	ld de, $7731
	call Call_0A_40B4
	call Call_0A_474B
	ld de, $7409
	call Call_0A_40B4
	ld de, $481f
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4914
	ld a, [$c8dc]
	call Call_0A_43E2
	call Call_0A_40E5
	ret


Jump_0A_487D::
	ld de, $4914
	ld hl, $c8dc
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_48ad

	call Call_0A_45E5
	call Call_0A_4BA2
	ld hl, $0002
	call Call_0A_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_00a_4913

jr_00a_48ad:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_4913

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_00a_48cf

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $0e
	ld [$c906], a
	jr jr_00a_4913

jr_00a_48cf:
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $0a
	jr nc, jr_00a_48ea

	ld hl, $0003
	call Call_0A_441F
	ld a, $10
	ld [$c906], a
	jr jr_00a_4913

jr_00a_48ea:
	ld a, [$ca8d]
	cp $02
	jr z, jr_00a_490b

	cp $03
	jr z, jr_00a_490b

	ld a, [$ca8e]
	ld hl, $cac0
	cp [hl]
	jr nz, jr_00a_490b

	ld hl, $0004
	call Call_0A_441F
	ld a, $10
	ld [$c906], a
	jr jr_00a_4913

jr_00a_490b:
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8dd], a

Jump_00a_4913:
jr_00a_4913:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Jump_0A_491A::
	ld hl, $0006
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_4925::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6f3c
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4988
	ld a, [$c8de]
	call Call_0A_43E2
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_4949::
	ld de, $4988
	ld hl, $c8de
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_496b

jr_00a_495b:
	call Call_0A_4BA2
	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_4987

jr_00a_496b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_4987

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_00a_495b

	xor a
	ld [$c8df], a
	ld hl, $c906
	inc [hl]

Jump_00a_4987:
jr_00a_4987:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_0A_498E::
	ld de, $748d
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4B9E
	call Call_0A_40E5
	ld hl, $0007
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_49AB::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6f3c
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4a0a
	ld a, [$c8df]
	call Call_0A_43E2
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_49CF::
	ld de, $4a0a
	ld hl, $c8df
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_49f1

jr_00a_49e1:
	call Call_0A_4BA2
	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_4a09

jr_00a_49f1:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_4a09

	ld a, $59
	call Call_1B2C
	ld a, [$c8df]
	cp $81
	jr z, jr_00a_49e1

	ld hl, $c906
	inc [hl]

Jump_00a_4a09:
jr_00a_4a09:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_0A_4A10::
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	ld hl, $0008
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	add $10
	ld [$d7ca], a
	ld a, $01
	ld [$d7cb], a
	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld de, $d665
	call Call_0A_57B0
	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld [hl], $00
	ld a, [$c8f7]
	ld c, a
	ld a, [$c8f8]
	ld b, a
	ld a, c
	ld [$da12], a
	ld a, b
	ld [$da13], a
	ld a, $15
	ld [$da14], a
	ld hl, far_Call_14_40B4
	rst $10
	ld a, [$d670]
	xor $01
	ld [$d705], a
	ld a, $15
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	add $10
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, HeaderLogo
	rst $10
	ld hl, far_Call_16_4015
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
	ld a, [$d951]
	push af
	xor a
	ld [$d951], a
	di
	call Call_2128
	ei
	pop af
	ld [$d951], a
	pop af
	ld [$c8ec], a
	pop af
	ld [$d8d7], a
	pop af
	ld [$c905], a
	pop af
	ld [$c8eb], a
	ret


Jump_0A_4AD3::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8eb
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [$c905], a
	ld a, $08
	ld [$c96d], a
	ld a, $00
	ld [$c96e], a
	ld hl, $0048
	ld a, l
	ld [$c96f], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [$c971], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld a, $04
	ld [$d951], a
	xor a
	ld [$d8d7], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	ret


Jump_0A_4B1B::
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


Jump_0A_4B46::
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
	ld de, $2e11
	ld hl, $8800
	call Call_1577
	call Call_0A_46C9
	call Call_0A_4610
	ld hl, $0005
	call Call_0A_441F
	call Call_0A_4843
	xor a
	ld [$c8ec], a
	ld a, $05
	ld [$c906], a
	ret


Jump_0A_4B81::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_4572
	call Call_0A_459C
	call Call_0A_4BA2
	ld hl, $0002
	call Call_0A_441F
	call Call_0A_45E5
	ld a, $01
	ld [$c906], a
	ret


Call_0A_4B9E::
	call Call_0A_5E1E
	ret


Call_0A_4BA2::
	ld a, [$c8f7]
	ld c, a
	ld a, [$c8f8]
	ld b, a
	ld a, c
	ld [$da12], a
	ld a, b
	ld [$da13], a
	ld hl, far_Call_14_400F
	rst $10
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c180
	call Call_097A
	ret


Jump_0A_4BC3::
	ld a, [$c905]
	rst $00

JumpTable_0A_4BC7::
	dw Jump_0A_4BD1
	dw Jump_0A_4C3C
	dw Jump_0A_4C81
	dw Jump_0A_4CD3
	dw Jump_0A_4CE2

Jump_0A_4BD1::
	ld hl, $ffb7
	call Call_0A_4028
	ld hl, $ffbb
	call Call_0A_4028
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
	call Call_0A_41EF
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	ld de, $2e12
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $10
	ld [$c823], a
	ld hl, $9400
	ld de, $0801
	call Call_0A_411A
	call Call_0A_4323
	ld a, $40
	ldh [$ffd4], a
	ld hl, $c905
	inc [hl]
	ret


Jump_0A_4C3C::
	ld hl, $c905
	inc [hl]
	call Call_0A_41EF
	call Call_0A_4C4A
	call Call_0A_40E5
	ret


Call_0A_4C4A::
	ld de, $6f86
	call Call_0A_40B4
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_0A_4058
	call Call_1FB9
	ld de, $75ab
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $4ccb
	ld a, [$c8da]
	call Call_0A_43E2
	ret


Jump_0A_4C81::
	ld de, $4ccb
	ld hl, $c8da
	ld b, $03
	call Call_0A_42CA
	ld a, [$c846]
	and $0a
	jr z, jr_00a_4c95

	jr Jump_0A_4CDD

jr_00a_4c95:
	ld a, [$c846]
	bit 0, a
	jr z, jr_00a_4cca

	ld a, $59
	call Call_1B2C
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8da
	set 7, [hl]
	ld a, [hl]
	ld [$c907], a
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	jr jr_00a_4cca

jr_00a_4cca:
	ret


	db $21, $00, $61, $00, $a1, $00, $ff, $ff

Jump_0A_4CD3::
	ld a, [$c907]
	rst $00

JumpTable_0A_4CD7::
	dw Jump_0A_4D04
	dw Jump_0A_5907
	dw Jump_0A_4CDD

Jump_0A_4CDD::
	ld a, [$c825]
	or a
	ret nz

Jump_0A_4CE2::
	call Call_0A_41EF
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	xor a
	ld [$c8ec], a
	ld a, $80
	ldh [$ffd3], a
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ld hl, far_Call_01_484E
	rst $10
	ret


Jump_0A_4D04::
	ld a, [$c906]
	rst $00

JumpTable_0A_4D08::
	dw Jump_0A_4D3C
	dw Jump_0A_4DAD
	dw Jump_0A_4F14
	dw Jump_0A_4FB4
	dw Jump_0A_4FBF
	dw Jump_0A_5006
	dw Jump_0A_50A0
	dw Jump_0A_5120
	dw Jump_0A_5231
	dw Jump_0A_52E9
	dw Jump_0A_52F4
	dw Jump_0A_533B
	dw Jump_0A_5425
	dw Jump_0A_55C7
	dw Jump_0A_55D1
	dw Jump_0A_55E0
	dw Jump_0A_55FD
	dw Jump_0A_5621
	dw Jump_0A_565F
	dw Jump_0A_573E
	dw Jump_0A_57B9
	dw Jump_0A_57E4
	dw Jump_0A_584E
	dw Jump_0A_5868
	dw Jump_0A_5893
	dw Jump_0A_58ED

Jump_0A_4D3C::
	call Call_0A_4D4D
	call Call_0A_4D77
	ld hl, $0003
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Call_0A_4D4D::
	ld de, $cac1
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
	ld [$c8e9], a
	ret


Call_0A_4D77::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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


Jump_0A_4DAD::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_4E40
	call Call_0A_4DEB
	call Call_0A_4DC0
	ld hl, $c906
	inc [hl]
	ret


Call_0A_4DC0::
	call Call_0A_41EF
	call Call_0A_4C4A
	ld de, $75f3
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_4ED3
	call Call_0A_4323
	ld de, $4fa8
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	call Call_0A_40E5
	ret


Call_0A_4DEB::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9610
	call Call_0A_4E05
	call Call_0A_4E05
	call Call_0A_4E05

Call_0A_4E05::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_4e26

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0A_4153
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Call_0A_4E40::
	call Call_0A_4E55
	ld hl, $9760
	ld b, $28

jr_00a_4e48:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_00a_4e48

	ret


Call_0A_4E55::
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $9710
	call Call_0A_4E05
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $9750
	call Call_0A_4E81
	ret


Call_0A_4E81::
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


Call_0A_4ED3::
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $012a
	call Call_0A_4058
	ld a, $de
	ld [hli], a
	call Call_0A_6027
	pop af
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	ret nz

	ld hl, $0132
	call Call_0A_4058
	ld a, $e3
	ld [hl], a
	ret


Jump_0A_4F14::
	ld a, [$c825]
	or a
	ret nz

	ld de, $4fa8
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_0A_4241
	pop af
	ld hl, $c8e2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_00a_4f49

	call Call_0A_4E40
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_4ED3
	call Call_0A_40E5

jr_00a_4f49:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_00a_4f62

	call Call_0A_4E40
	call Call_0A_4DEB
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_4ED3
	call Call_0A_40E5

jr_00a_4f62:
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_4f76

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_4fa7

jr_00a_4f76:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_4fa7

	ld a, $59
	call Call_1B2C
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
	ld [$c8e8], a
	xor a
	ld [$c8dc], a
	ld hl, $c906
	inc [hl]

Jump_00a_4fa7:
jr_00a_4fa7:
	ret


	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_0A_4FB4::
	ld hl, $0005
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_4FBF::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_4FCC
	ld hl, $c906
	inc [hl]
	ret


Call_0A_4FCC::
	call Call_0A_41EF
	call Call_0A_4C4A
	ld de, $75f3
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_4ED3
	ld de, $4fa8
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $509a
	ld a, [$c8dc]
	call Call_0A_43E2
	call Call_0A_40E5
	ret


Jump_0A_5006::
	ld de, $509a
	ld hl, $c8dc
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_5033

	call Call_0A_4DC0
	ld hl, $0003
	call Call_0A_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_00a_5099

jr_00a_5033:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_5099

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_00a_5055

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $14
	ld [$c906], a
	jr jr_00a_5099

jr_00a_5055:
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $0a
	jr nc, jr_00a_5070

	ld hl, $0007
	call Call_0A_441F
	ld a, $16
	ld [$c906], a
	jr jr_00a_5099

jr_00a_5070:
	ld a, [$ca8d]
	cp $02
	jr z, jr_00a_5091

	cp $03
	jr z, jr_00a_5091

	ld a, [$ca8e]
	ld hl, $cac0
	cp [hl]
	jr nz, jr_00a_5091

	ld hl, $0006
	call Call_0A_441F
	ld a, $16
	ld [$c906], a
	jr jr_00a_5099

jr_00a_5091:
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8dd], a

Jump_00a_5099:
jr_00a_5099:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Jump_0A_50A0::
	call Call_0A_50B1
	call Call_0A_50E4
	ld hl, $0004
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Call_0A_50B1::
	ld de, $cac1
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

	ld a, [$c8e8]
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
	ld [$c8e9], a
	ret


Call_0A_50E4::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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

	ld a, [$c8e8]
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


Jump_0A_5120::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_517C
	call Call_0A_515E
	call Call_0A_5133
	ld hl, $c906
	inc [hl]
	ret


Call_0A_5133::
	call Call_0A_41EF
	call Call_0A_4C4A
	ld de, $764d
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_51C1
	call Call_0A_4323
	ld de, $52dd
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e4
	call Call_0A_43C0
	call Call_0A_40E5
	ret


Call_0A_515E::
	ld a, [$c8e5]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9610
	call Call_0A_4E05
	call Call_0A_4E05
	call Call_0A_4E05
	call Call_0A_4E05
	ret


Call_0A_517C::
	ld de, $c8e8
	ld a, [de]
	push af
	ld hl, $9710
	call Call_0A_4E05
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $9750
	call Call_0A_4E81

Call_0A_5195::
	ld a, [$c8e5]
	add a
	add a
	ld b, a
	ld a, [$c8e4]
	and $7f
	add b
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $9760
	call Call_0A_4E05
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $97a0
	call Call_0A_4E81
	ret


Call_0A_51C1::
	ld de, $c8e8
	ld a, [de]
	push af
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $012a
	call Call_0A_4058
	ld a, $de
	ld [hli], a
	call Call_0A_6027
	pop af
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_00a_51f0

	ld hl, $0132
	call Call_0A_4058
	ld a, $e3
	ld [hl], a

jr_00a_51f0:
	ld a, [$c8e5]
	add a
	add a
	ld b, a
	ld a, [$c8e4]
	and $7f
	add b
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $016a
	call Call_0A_4058
	ld a, $de
	ld [hli], a
	call Call_0A_6027
	pop af
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	ret nz

	ld hl, $0172
	call Call_0A_4058
	ld a, $e3
	ld [hl], a
	ret


Jump_0A_5231::
	ld a, [$c825]
	or a
	ret nz

	ld de, $52dd
	ld hl, $c8e4
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_0A_4241
	pop af
	ld hl, $c8e4
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_00a_5266

	call Call_0A_5195
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_51C1
	call Call_0A_40E5

jr_00a_5266:
	pop af
	ld hl, $c8e5
	cp [hl]
	jr z, jr_00a_527f

	call Call_0A_5195
	call Call_0A_515E
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_51C1
	call Call_0A_40E5

jr_00a_527f:
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_52ae

	ld hl, $0003
	call Call_0A_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_00a_52dc

jr_00a_52ae:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_4fa7

	ld a, $59
	call Call_1B2C
	ld a, [$c8e5]
	add a
	add a
	ld b, a
	ld a, [$c8e4]
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
	xor a
	ld [$c8dd], a
	ld hl, $c906
	inc [hl]

jr_00a_52dc:
	ret


	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_0A_52E9::
	ld hl, $0005
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_52F4::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_5301
	ld hl, $c906
	inc [hl]
	ret


Call_0A_5301::
	call Call_0A_41EF
	call Call_0A_4C4A
	ld de, $764d
	call Call_0A_40B4
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_51C1
	ld de, $52dd
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e4
	call Call_0A_43C0
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $541f
	ld a, [$c8dd]
	call Call_0A_43E2
	call Call_0A_40E5
	ret


Jump_0A_533B::
	ld de, $541f
	ld hl, $c8dd
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_5369

	call Call_0A_5133
	ld hl, $0004
	call Call_0A_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jp Jump_00a_541e


jr_00a_5369:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_541e

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $81
	jr z, jr_00a_538c

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $17
	ld [$c906], a
	jp Jump_00a_541e


jr_00a_538c:
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $0a
	jr nc, jr_00a_53a7

	ld hl, $0007
	call Call_0A_441F
	ld a, $19
	ld [$c906], a
	jr jr_00a_541e

jr_00a_53a7:
	ld a, [$ca8d]
	cp $03
	jr z, jr_00a_53ef

	cp $02
	jr nz, jr_00a_53d0

	ld a, [$c8e8]
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_00a_53ef

	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_00a_53ef

	jr jr_00a_53e2

jr_00a_53d0:
	ld a, [$ca8e]
	ld hl, $c8e8
	cp [hl]
	jr z, jr_00a_53e2

	ld a, [$ca8e]
	ld hl, $cac0
	cp [hl]
	jr nz, jr_00a_53ef

jr_00a_53e2:
	ld hl, $0006
	call Call_0A_441F
	ld a, $19
	ld [$c906], a
	jr jr_00a_541e

jr_00a_53ef:
	ld a, [$c8e8]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	and $01
	push af
	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	pop af
	ld b, a
	ld a, [hl]
	and $01
	cp b
	jr nz, jr_00a_541a

	ld hl, $0008
	call Call_0A_441F
	ld a, $19
	ld [$c906], a
	jr jr_00a_541e

jr_00a_541a:
	ld hl, $c906
	inc [hl]

Jump_00a_541e:
jr_00a_541e:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Jump_0A_5425::
	ld a, [$c8e8]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, [$cac0]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld a, [$c8e8]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$da6f], a
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$da70], a
	ld a, [$c8e8]
	and $7f
	ld [$da75], a
	ld a, [$cac0]
	and $7f
	ld [$da76], a
	ld hl, far_Call_16_45A3
	rst $10
	ld a, [$da71]
	ld hl, $ca94
	call Call_267E
	jr nz, jr_00a_5490

	ld a, [$da71]
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
	ld a, [$da71]
	ld l, a
	ld h, $05
	ld de, $c1a0
	call Call_097A
	ld a, [$da77]
	ld de, $c1a0
	call Call_0A_606D
	ld a, [$da71]
	ld hl, $ca94
	call Call_267E
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
	call Call_0A_441F
	ld hl, $c906
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

Jump_0A_55C7::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c906
	inc [hl]
	ret


Jump_0A_55D1::
	xor a
	ld [$c8df], a
	ld hl, $c906
	inc [hl]
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_0A_55E0::
	ld de, $748d
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_5E1E
	call Call_0A_40E5
	ld hl, $000b
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_55FD::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $70c5
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5659
	ld a, [$c8df]
	call Call_0A_43E2
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_5621::
	ld de, $5659
	ld hl, $c8df
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_5640

jr_00a_5633:
	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_5658

jr_00a_5640:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_5658

	ld a, $59
	call Call_1B2C
	ld a, [$c8df]
	cp $81
	jr z, jr_00a_5633

	ld hl, $c906
	inc [hl]

Jump_00a_5658:
jr_00a_5658:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_0A_565F::
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	ld hl, $000c
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ld a, [$c8e8]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, [$cac0]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld a, [$c8e8]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	add $10
	ld [$d7ca], a
	ld a, $01
	ld [$d7cb], a
	ld a, [$c8e8]
	ld hl, $cac1
	call Call_223B
	ld de, $d665
	call Call_0A_57B0
	ld a, [$c8e8]
	ld hl, $cac1
	call Call_223B
	ld [hl], $00
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	add $10
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld de, $d6fa
	call Call_0A_57B0
	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld [hl], $00
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, HeaderLogo
	rst $10
	ld hl, far_Call_16_4015
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
	ld a, [$d951]
	push af
	xor a
	ld [$d951], a
	di
	call Call_2128
	ei
	pop af
	ld [$d951], a
	pop af
	ld [$c8ec], a
	pop af
	ld [$d8d7], a
	pop af
	ld [$c905], a
	pop af
	ld [$c8eb], a
	ret


Jump_0A_573E::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8eb
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [$c905], a
	ld a, $08
	ld [$c96d], a
	ld a, $00
	ld [$c96e], a
	ld hl, $0048
	ld a, l
	ld [$c96f], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [$c971], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld a, $00
	ld [$d951], a
	xor a
	ld [$d8d7], a
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld l, [hl]
	ld h, $05
	ld de, $c1a0
	call Call_097A
	ld a, [$cac0]
	ld hl, $cb23
	call Call_223B
	ld a, [hl]
	inc a
	ld c, $0a
	call Call_1DBE
	ld c, l
	ld b, h
	ld hl, $c1b0
	call Call_0A7C
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	ret


Call_0A_57B0::
	ld b, $95

jr_00a_57b2:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_00a_57b2

	ret


Jump_0A_57B9::
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


Jump_0A_57E4::
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
	ld a, [$c934]
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c8e8], a
	ld de, $2e12
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $10
	ld [$c823], a
	ld hl, $9400
	ld de, $0801
	call Call_0A_411A
	call Call_0A_4E40
	call Call_0A_4DEB
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_4ED3
	call Call_0A_40E5
	ld hl, $0005
	call Call_0A_441F
	call Call_0A_4FCC
	ld a, $05
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_0A_584E::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_4D4D
	call Call_0A_4D77
	ld hl, $0003
	call Call_0A_441F
	call Call_0A_4DC0
	ld a, $01
	ld [$c906], a
	ret


Jump_0A_5868::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8e5]
	add a
	add a
	ld b, a
	ld a, [$c8e4]
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


Jump_0A_5893::
	ld a, [$c8e4]
	and $80
	ld b, a
	ld a, [$c934]
	and $03
	or b
	ld [$c8e4], a
	ld a, [$c934]
	srl a
	srl a
	ld [$c8e5], a
	ld de, $2e12
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $10
	ld [$c823], a
	ld hl, $9400
	ld de, $0801
	call Call_0A_411A
	call Call_0A_517C
	call Call_0A_515E
	ld de, $76a7
	call Call_0A_40B4
	call Call_0A_51C1
	call Call_0A_40E5
	ld hl, $0005
	call Call_0A_441F
	call Call_0A_5301
	ld a, $0b
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_0A_58ED::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_50B1
	call Call_0A_50E4
	ld hl, $0004
	call Call_0A_441F
	call Call_0A_5133
	ld a, $07
	ld [$c906], a
	ret


Jump_0A_5907::
	ld a, [$c906]
	rst $00

JumpTable_0A_590B::
	dw Jump_0A_5927
	dw Jump_0A_59A7
	dw Jump_0A_5AF1
	dw Jump_0A_5B46
	dw Jump_0A_5B7C
	dw Jump_0A_5B9B
	dw Jump_0A_5C4C
	dw Jump_0A_5C51
	dw Jump_0A_5C56
	dw Jump_0A_5C5B
	dw Jump_0A_5C92
	dw Jump_0A_5D51
	dw Jump_0A_5D62
	dw Jump_0A_5D8D

Jump_0A_5927::
	call Call_0A_5947
	or a
	jr nz, jr_00a_5939

	ld hl, $0013
	call Call_0A_441F
	ld a, $0b
	ld [$c906], a
	ret


jr_00a_5939:
	call Call_0A_5971
	ld hl, $0012
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Call_0A_5947::
	ld de, $cac1
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
	ld [$c8e9], a
	ret


Call_0A_5971::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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


Jump_0A_59A7::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_59D9
	call Call_0A_59BA
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_0A_59BA::
	call Call_0A_41EF
	call Call_0A_4C4A
	ld de, $7757
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5b3a
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	ret


Call_0A_59D9::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9650
	call Call_0A_59FD
	call Call_0A_59FD
	call Call_0A_59FD
	ld hl, $8800
	call Call_0A_59FD
	call Call_0A_5A41
	ret


Call_0A_59FD::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_5a27

	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld de, $0901
	pop hl
	push hl
	call Call_0A_411A
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Call_0A_5A41::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8a00
	call Call_0A_5A5B
	call Call_0A_5A5B
	call Call_0A_5A5B

Call_0A_5A5B::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_5ad7

	ld hl, $cb24
	call Call_223B
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


jr_00a_5ad7:
	ld b, $08

jr_00a_5ad9:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_0A_5AF1::
	ld de, $5b3a
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_0A_4241
	pop af
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_00a_5b10

	call Call_0A_59D9

jr_00a_5b10:
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_5b24

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_5b39

jr_00a_5b24:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_5b39

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8de], a
	ld hl, $c906
	inc [hl]

Jump_00a_5b39:
jr_00a_5b39:
	ret


	db $92, $01, $a8, $00, $e8, $00, $28, $01, $68, $01, $ff, $ff

Jump_0A_5B46::
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
	ld hl, $cb23
	call Call_223B
	ld a, [hl]
	inc a
	ld c, $0a
	call Call_1DBE
	ld c, l
	ld b, h
	ld hl, $c1b0
	call Call_0A7C
	ld hl, $0014
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_5B7C::
	ld a, [$c825]
	or a
	ret nz

	ld de, $79be
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5c46
	ld a, [$c8de]
	call Call_0A_43E2
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_5B9B::
	ld de, $5c46
	ld hl, $c8de
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_5bcb

	ld hl, $0012
	call Call_0A_441F
	call Call_0A_59BA
	call Call_0A_40E5
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_00a_5c45

jr_00a_5bcb:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_5c45

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_00a_5bed

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $0c
	ld [$c906], a
	jr jr_00a_5c45

jr_00a_5bed:
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
	ld hl, $cb23
	call Call_223B
	ld a, [hl]
	inc a
	ld c, $0a
	call Call_1DBE
	ld a, [$ca4b]
	sub l
	ld a, [$ca4c]
	sbc h
	ld a, [$ca4d]
	sbc $00
	jr nc, jr_00a_5c2c

	ld hl, $001e
	call Call_0A_441F
	ld a, $0b
	ld [$c906], a
	jr jr_00a_5c45

jr_00a_5c2c:
	ld e, $00
	call Call_2424
	xor a
	ld [$c8df], a
	ld hl, $c906
	inc [hl]
	ld hl, $c906
	inc [hl]
	ld hl, $c906
	inc [hl]
	ld hl, $c906
	inc [hl]

Jump_00a_5c45:
jr_00a_5c45:
	ret


	db $2d, $00, $6d, $00, $ff, $ff

Jump_0A_5C4C::
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_5C51::
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_5C56::
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_5C5B::
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	ld hl, $0015
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
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
	ld [$c908], a
	ld [$ca40], a
	ld hl, far_Call_16_474A
	rst $10
	ret


Jump_0A_5C92::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8eb
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [$c905], a
	ld a, [$c908]
	ld [$cac0], a
	ld hl, $caca
	call Call_223B
	ld l, [hl]
	ld h, $05
	ld de, $c190
	call Call_097A
	ld a, [$cac0]
	ld hl, $cb23
	call Call_223B
	ld a, [hl]
	ld de, $c190
	call Call_0A_606D
	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld de, $c190
	call Call_0A_6082
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	add $10
	ld [$c8f4], a
	ld [$d7ca], a
	ld a, $01
	ld [$d7cb], a
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
	ld a, $08
	ld [$c96d], a
	ld a, $00
	ld [$c96e], a
	ld hl, $0048
	ld a, l
	ld [$c96f], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [$c971], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld a, $02
	ld [$d951], a
	xor a
	ld [$d8d7], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	ret


Jump_0A_5D51::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_0A_5D62::
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


Jump_0A_5D8D::
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
	ld de, $2e12
	ld hl, $8800
	call Call_1577
	ld a, $02
	ld [$c822], a
	ld a, $10
	ld [$c823], a
	ld hl, $9400
	ld de, $0801
	call Call_0A_411A
	call Call_0A_5947
	call Call_0A_5971
	call Call_0A_59D9
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
	ld hl, $cb23
	call Call_223B
	ld a, [hl]
	inc a
	ld c, $0a
	call Call_1DBE
	ld c, l
	ld b, h
	ld hl, $c1b0
	call Call_0A7C
	ld hl, $0014
	call Call_0A_441F
	call Call_0A_59BA
	ld de, $79be
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $5c46
	ld a, [$c8de]
	call Call_0A_43E2
	call Call_0A_40E5
	ld a, $04
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Call_0A_5E1E::
	ld hl, $a002
	call Call_20EE
	or a
	jr nz, jr_00a_5e84

	ld hl, $0021
	call Call_0A_4058
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0041
	call Call_0A_4058
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0061
	call Call_0A_4058
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0081
	call Call_0A_4058
	ld bc, $0011
	ld a, $e0
	call Call_12C7
	ld hl, $0044
	call Call_0A_4058
	ld b, $0a
	ld a, $a4

jr_00a_5e69:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_00a_5e69

	ld a, $31
	ld [$c823], a
	ld a, $02
	ld [$c822], a
	ld hl, $8a40
	ld de, $0a01
	call Call_0A_411A
	jp Jump_00a_5f2b


jr_00a_5e84:
	di
	ld a, $0a
	ld [$0100], a
	ld de, $a17c
	ld hl, $8a00
	call Call_0A_4153
	call Call_0A_5F65
	ld hl, $a1f2
	call Call_20EE
	ld c, a
	ld b, $00
	ld hl, $002d
	call Call_0A_4058
	call Call_20AD
	ld hl, $a1f1
	call Call_20EE
	ld c, a
	ld b, $00
	ld hl, $0030
	call Call_0A_4058
	call Call_20AD
	ld hl, $a1c7
	call Call_20EE
	or a
	jr z, jr_00a_5f31

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
	call Call_0A_4058
	call Call_2082
	ld hl, $a1c7
	call Call_20EE
	cp $01
	jr z, jr_00a_5f37

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
	call Call_0A_4058
	call Call_2082
	ld hl, $a1c7
	call Call_20EE
	cp $02
	jr z, jr_00a_5f3d

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
	call Call_0A_4058
	call Call_2082

Jump_00a_5f2b:
	ld a, $00
	ld [$0100], a
	ret


jr_00a_5f31:
	ld hl, $0061
	call Call_0A_5F49

jr_00a_5f37:
	ld hl, $0067
	call Call_0A_5F49

jr_00a_5f3d:
	ld hl, $006d
	call Call_0A_5F49
	ld a, $00
	ld [$0100], a
	ret


Call_0A_5F49::
	push hl
	call Call_0A_4058
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
	call Call_0A_4058
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


Call_0A_5F65::
	ld hl, $8da0
	ld b, $18
	call Call_0A_5FCC
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1fc
	ld a, [$a1c8]
	call Call_223B
	ei
	ld e, l
	ld d, h
	ld hl, $8a40
	ld a, $01
	call Call_0A_5FBC
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1fc
	ld a, [$a1c9]
	call Call_223B
	ei
	ld e, l
	ld d, h
	ld hl, $8a80
	ld a, $02
	call Call_0A_5FBC
	di
	ld a, $0a
	ld [$0100], a
	ld hl, $a1fc
	ld a, [$a1ca]
	call Call_223B
	ei
	ld e, l
	ld d, h
	ld hl, $8ac0
	ld a, $03
	call Call_0A_5FBC
	ret


Call_0A_5FBC::
	ld b, a
	di
	ld a, $0a
	ld [$0100], a
	ld a, [$a1c7]
	cp b
	ei
	jr nc, jr_00a_5fd9

	ld b, $20

Call_0A_5FCC::
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, Call_0A_5FCC

	ret


jr_00a_5fd9:
	push bc
	call Call_0A_4153
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
	call Call_1577
	ret


	db $03, $2e, $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e
	db $0b, $2e, $0c, $2e

Call_0A_6027::
	ld de, $000a
	push bc
	call Call_0A_6043
	pop bc
	or a
	jr z, jr_00a_603e

	ld de, $000a
	call Call_0A_6043
	call Call_0A_6058
	call Call_0A_605E

jr_00a_603e:
	ld a, c
	call Call_0A_6058
	ret


Call_0A_6043::
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


Call_0A_6058::
	add $f0
	call Call_1AAD
	ret


Call_0A_605E::
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


Call_0A_606D::
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
	call Call_09A4
	ret


Call_0A_6082::
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


Jump_0A_6095::
	ld a, [$c905]
	rst $00

JumpTable_0A_6099::
	dw Jump_0A_60A3
	dw Jump_0A_60EE
	dw Jump_0A_6138
	dw Jump_0A_618E
	dw Jump_0A_6198

Jump_0A_60A3::
	ld hl, $ffb7
	call Call_0A_4028
	ld hl, $ffbb
	call Call_0A_4028
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
	call Call_0A_41EF
	ld de, $2e13
	ld hl, $8800
	call Call_1577
	call Call_0A_4323
	ld hl, $c905
	inc [hl]
	ret


Jump_0A_60EE::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c905
	inc [hl]
	call Call_0A_41EF
	call Call_0A_6101
	call Call_0A_40E5
	ret


Call_0A_6101::
	ld de, $77d7
	call Call_0A_40B4
	ld de, $6f86
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_0A_4058
	call Call_1FB9
	call Call_0A_4323
	ld de, $6186
	ld a, [$c8da]
	call Call_0A_43E2
	ret


Jump_0A_6138::
	ld de, $6186
	ld hl, $c8da
	ld b, $03
	call Call_0A_42CA
	ld a, [$c846]
	and $0a
	jr z, jr_00a_6154

	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	jr jr_00a_6185

jr_00a_6154:
	ld a, [$c846]
	bit 0, a
	jr z, jr_00a_6185

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
	jr jr_00a_6185

jr_00a_6185:
	ret


	db $21, $00, $61, $00, $a1, $00, $ff, $ff

Jump_0A_618E::
	ld a, [$c8da]
	rst $00

JumpTable_0A_6192::
	dw Jump_0A_61AE
	dw Jump_0A_66F5
	dw Jump_0A_6198

Jump_0A_6198::
	call Call_0A_41EF
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Jump_0A_61AE::
	ld a, [$c906]
	rst $00

JumpTable_0A_61B2::
	dw Jump_0A_61D2
	dw Jump_0A_6252
	dw Jump_0A_6398
	dw Jump_0A_63F7
	dw Jump_0A_645F
	dw Jump_0A_6518
	dw Jump_0A_6551
	dw Jump_0A_6585
	dw Jump_0A_65A6
	dw Jump_0A_65C1
	dw Jump_0A_65D2
	dw Jump_0A_65DD
	dw Jump_0A_6603
	dw Jump_0A_6659
	dw Jump_0A_667C
	dw Jump_0A_66AA

Jump_0A_61D2::
	call Call_0A_61F2
	or a
	jr nz, jr_00a_61e4

	ld hl, $0004
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	ret


jr_00a_61e4:
	call Call_0A_621C
	ld hl, $0003
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Call_0A_61F2::
	ld de, $cac1
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
	ld [$c8e9], a
	ret


Call_0A_621C::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
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


Jump_0A_6252::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_6287
	call Call_0A_62E8
	call Call_0A_6268
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_0A_6268::
	call Call_0A_41EF
	call Call_0A_6101
	ld de, $781f
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $63eb
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	ret


Call_0A_6287::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9700
	call Call_0A_62A4
	ld hl, $8800
	call Call_0A_62A4
	call Call_0A_62A4

Call_0A_62A4::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_62ce

	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld de, $0901
	pop hl
	push hl
	call Call_0A_411A
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Call_0A_62E8::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $89b0
	call Call_0A_6302
	call Call_0A_6302
	call Call_0A_6302

Call_0A_6302::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_637e

	ld hl, $cb24
	call Call_223B
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


jr_00a_637e:
	ld b, $08

jr_00a_6380:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_0A_6398::
	ld de, $63eb
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_0A_4241
	pop af
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_00a_63ba

	call Call_0A_6287
	call Call_0A_62E8

jr_00a_63ba:
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_63ce

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_63ea

jr_00a_63ce:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_63ea

	ld a, $59
	call Call_1B2C
	ld a, $0a
	ld [$c906], a
	ld a, $00
	ld [$c8dc], a
	ld a, $01
	ld [$c8dd], a

Jump_00a_63ea:
jr_00a_63ea:
	ret


	db $92, $01, $a8, $00, $e8, $00, $28, $01, $68, $01, $ff, $ff

Jump_0A_63F7::
	ld a, [$ca4b]
	sub $14
	ld a, [$ca4c]
	sbc $00
	ld a, [$ca4d]
	sbc $00
	jr c, jr_00a_6453

	ld hl, $0014
	ld e, $00
	call Call_2424
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
	ld hl, $caca
	call Call_223B
	ld l, [hl]
	ld h, $05
	ld de, $c180
	call Call_097A
	ld a, [$cac0]
	ld hl, $cb23
	call Call_223B
	ld a, [hl]
	ld de, $c180
	call Call_0A_606D
	ld hl, $0006
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


jr_00a_6453:
	ld hl, $001c
	call Call_0A_441F
	ld a, $09
	ld [$c906], a
	ret


Jump_0A_645F::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$cac0]
	ld hl, $cb11
	call Call_223B
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, d
	cp $10
	jr nc, jr_00a_64e3

	push de
	ld a, [$cac0]
	ld hl, $cb15
	call Call_223B
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
	ld a, [$cac0]
	ld hl, $cb19
	call Call_223B
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
	ld a, [$cac0]
	ld hl, $cb1b
	call Call_223B
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
	ld a, [$cac0]
	ld hl, $cb1d
	call Call_223B
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
	ld a, [$cac0]
	ld hl, $cb1f
	call Call_223B
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
	call Call_0A_441F

jr_00a_6513:
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_6518::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$cac0]
	ld hl, $caf2
	call Call_223B
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
	call Call_0A_441F

jr_00a_654c:
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_6551::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$cac0]
	ld hl, $cb0d
	call Call_223B
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
	call Call_0A_441F

jr_00a_657f:
	ld a, $0f
	ld [$c906], a
	ret


Jump_0A_6585::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $0013
	and $01
	jr z, jr_00a_659e

	ld hl, $0014

jr_00a_659e:
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_65A6::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0015
	call Call_0A_441F
	ld a, [$cac0]
	ld hl, $cb24
	call Call_223B
	ld [hl], $02
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_65C1::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_0A_65D2::
	ld hl, $0005
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_65DD::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_6268
	call Call_0A_65F0
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_0A_65F0::
	ld de, $79ed
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $6653
	ld a, [$c8dc]
	call Call_0A_43E2
	ret


Jump_0A_6603::
	ld de, $6653
	ld hl, $c8dc
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_6628

	call Call_0A_6268
	call Call_0A_40E5
	ld hl, $0003
	call Call_0A_441F
	ld a, $02
	ld [$c906], a
	jr jr_00a_6652

jr_00a_6628:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_6652

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_00a_6649

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c906
	inc [hl]
	jr jr_00a_6652

jr_00a_6649:
	ld a, $03
	ld [$c906], a
	xor a
	ld [$c8dd], a

Jump_00a_6652:
jr_00a_6652:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_0A_6659::
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
	ld hl, far_Call_07_6456
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_0A_667C::
	ld de, $2e13
	ld hl, $8800
	call Call_1577
	call Call_0A_61F2
	call Call_0A_621C
	call Call_0A_6287
	call Call_0A_62E8
	ld hl, $0005
	call Call_0A_441F
	call Call_0A_6268
	call Call_0A_65F0
	call Call_0A_40E5
	ld a, $0b
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_0A_66AA::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$da31], a
	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld hl, $da42
	xor a
	call Call_0A_66ED
	push af
	ld a, [$cac0]
	ld hl, $cb29
	call Call_223B
	xor a
	call Call_0A_66ED
	pop bc
	cp b
	jr z, jr_00a_66e7

	ld hl, $0011
	jr c, jr_00a_66e4

	ld hl, $0012

jr_00a_66e4:
	call Call_0A_441F

jr_00a_66e7:
	ld a, $07
	ld [$c906], a
	ret


Call_0A_66ED::
	ld b, $1b

jr_00a_66ef:
	add [hl]
	inc hl
	dec b
	jr nz, jr_00a_66ef

	ret


Jump_0A_66F5::
	ld a, [$c906]
	rst $00

JumpTable_0A_66F9::
	dw Jump_0A_670F
	dw Jump_0A_672F
	dw Jump_0A_6764
	dw Jump_0A_67BD
	dw Jump_0A_6829
	dw Jump_0A_6851
	dw Jump_0A_68AE
	dw Jump_0A_68F8
	dw Jump_0A_6908
	dw Jump_0A_6919
	dw Jump_0A_6923

Jump_0A_670F::
	call Call_0A_61F2
	or a
	jr nz, jr_00a_6721

	ld hl, $0017
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	ret


jr_00a_6721:
	call Call_0A_621C
	ld hl, $0016
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_672F::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_6287
	call Call_0A_62E8
	call Call_0A_6745
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_0A_6745::
	call Call_0A_41EF
	call Call_0A_6101
	ld de, $781f
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $67b1
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_0A_43C0
	ret


Jump_0A_6764::
	ld de, $67b1
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_0A_4241
	pop af
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_00a_6786

	call Call_0A_6287
	call Call_0A_62E8

jr_00a_6786:
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_679a

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_67b0

jr_00a_679a:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_67b0

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	ld a, $01
	ld [$c8dd], a

Jump_00a_67b0:
jr_00a_67b0:
	ret


	db $92, $01, $a8, $00, $e8, $00, $28, $01, $68, $01, $ff, $ff

Jump_0A_67BD::
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
	ld a, [$cac0]
	ld hl, $cb23
	call Call_223B
	ld c, [hl]
	ld a, $32
	call Call_1DBE
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld a, l
	ld [$c8e4], a
	ld a, h
	ld [$c8e5], a
	ld a, e
	ld [$c8e6], a
	ld hl, $c180
	call Call_09C7
	ld hl, $0018
	call Call_0A_441F
	xor a
	ld [$c8de], a
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_6829::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_0A_683E
	call Call_0A_40E5
	ld hl, $c906
	inc [hl]
	ret


Call_0A_683E::
	ld de, $79ed
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $68a8
	ld a, [$c8de]
	call Call_0A_43E2
	ret


Jump_0A_6851::
	ld de, $68a8
	ld hl, $c8de
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_6881

	call Call_0A_6745
	call Call_0A_40E5
	ld hl, $0016
	call Call_0A_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_00a_68a7

jr_00a_6881:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_68a7

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_00a_68a3

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $09
	ld [$c906], a
	jr jr_00a_68a7

jr_00a_68a3:
	ld hl, $c906
	inc [hl]

Jump_00a_68a7:
jr_00a_68a7:
	ret


	db $21, $01, $61, $01, $ff, $ff

Jump_0A_68AE::
	ld hl, $c8e4
	ld a, [$ca4b]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc [hl]
	jr nc, jr_00a_68d1

	ld hl, $001c
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ld hl, $c906
	inc [hl]
	jr jr_00a_68f7

jr_00a_68d1:
	ld a, [$c8e4]
	ld l, a
	ld a, [$c8e5]
	ld h, a
	ld a, [$c8e6]
	ld e, a
	call Call_2424
	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	xor $01
	ld [hl], a
	ld hl, $001a
	call Call_0A_441F
	ld hl, $c906
	inc [hl]

jr_00a_68f7:
	ret


Jump_0A_68F8::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $001b
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_6908::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	ret


Jump_0A_6919::
	ld hl, far_Call_07_6456
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_0A_6923::
	ld de, $2e13
	ld hl, $8800
	call Call_1577
	call Call_0A_61F2
	call Call_0A_621C
	call Call_0A_6287
	call Call_0A_62E8
	ld a, [$c8e4]
	ldh [$ffd5], a
	ld a, [$c8e5]
	ldh [$ffd6], a
	ld a, [$c8e6]
	ldh [$ffd7], a
	ld hl, $c180
	call Call_09C7
	ld hl, $0018
	call Call_0A_441F
	call Call_0A_6745
	call Call_0A_683E
	call Call_0A_40E5
	ld a, $05
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_0A_6966::
	ld a, [$c905]
	rst $00

JumpTable_0A_696A::
	dw Jump_0A_6974
	dw Jump_0A_69D1
	dw Jump_0A_69F8
	dw Jump_0A_6A48
	dw Jump_0A_6A5A

Jump_0A_6974::
	ld hl, $ffb7
	call Call_0A_4028
	ld hl, $ffbb
	call Call_0A_4028
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
	call Call_0A_41EF
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	ld de, $2e12
	ld hl, $8800
	call Call_1577
	call Call_0A_4323
	ld a, $40
	ldh [$ffd4], a
	ld a, $00
	ld [$c83c], a
	ld hl, $c905
	inc [hl]
	ret


Jump_0A_69D1::
	ld hl, $c905
	inc [hl]
	call Call_0A_41EF
	call Call_0A_69DF
	call Call_0A_40E5
	ret


Call_0A_69DF::
	ld de, $6f3c
	call Call_0A_40B4
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $6a42
	ld a, [$c8da]
	call Call_0A_43E2
	ret


Jump_0A_69F8::
	ld de, $6a42
	ld hl, $c8da
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	and $0a
	jr z, jr_00a_6a0c

	jr Jump_0A_6A50

jr_00a_6a0c:
	ld a, [$c846]
	bit 0, a
	jr z, jr_00a_6a41

	ld a, $59
	call Call_1B2C
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8da
	set 7, [hl]
	ld a, [hl]
	ld [$c907], a
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	jr jr_00a_6a41

jr_00a_6a41:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_0A_6A48::
	ld a, [$c907]
	rst $00

JumpTable_0A_6A4C::
	dw Jump_0A_6A7E
	dw Jump_0A_6A50

Jump_0A_6A50::
	ld a, [$c825]
	or a
	ret nz

	ld a, $01
	ld [$c83c], a

Jump_0A_6A5A::
	call Call_0A_41EF
	ld de, $2e07
	call Call_0A_40B4
	call Call_0A_40E5
	xor a
	ld [$c8ec], a
	ld a, $80
	ldh [$ffd3], a
	ld hl, $c8eb
	res 4, [hl]
	set 0, [hl]
	xor a
	ld [$c905], a
	ld hl, far_Call_01_484E
	rst $10
	ret


Jump_0A_6A7E::
	ld a, [$c906]
	rst $00

JumpTable_0A_6A82::
	dw Jump_0A_6A98
	dw Jump_0A_6B00
	dw Jump_0A_6C6E
	dw Jump_0A_6CF9
	dw Jump_0A_6D04
	dw Jump_0A_6D48
	dw Jump_0A_6DA6
	dw Jump_0A_6DCF
	dw Jump_0A_6E53
	dw Jump_0A_6E77
	dw Jump_0A_6E9A

Jump_0A_6A98::
	ld a, [$ca8d]
	cp $03
	jr z, jr_00a_6abc

	inc a
	ld [$ca8d], a
	ld hl, $ca8d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$ca40]
	ld [hl], a
	ld hl, $001f
	call Call_0A_441F
	ld a, $0a
	ld [$c906], a
	ret


jr_00a_6abc:
	call Call_0A_6ACD
	call Call_0A_6AD5
	ld hl, $0019
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Call_0A_6ACD::
	ld a, [$ca8d]
	inc a
	ld [$c8e9], a
	ret


Call_0A_6AD5::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld a, [$ca8e]
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
	ld a, [$ca40]
	ld [hl], a
	ret


Jump_0A_6B00::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_6BBC
	call Call_0A_6B38
	call Call_0A_6B13
	ld hl, $c906
	inc [hl]
	ret


Call_0A_6B13::
	call Call_0A_41EF
	call Call_0A_69DF
	ld de, $75f3
	call Call_0A_40B4
	ld de, $76e5
	call Call_0A_40B4
	call Call_0A_6B82
	call Call_0A_4323
	ld de, $6cef
	ld a, [$c8db]
	call Call_0A_43E2
	call Call_0A_40E5
	ret


Call_0A_6B38::
	ld de, $c0d8
	ld hl, $9610
	call Call_0A_6B47
	call Call_0A_6B47
	call Call_0A_6B47

Call_0A_6B47::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_6b68

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0A_4153
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Call_0A_6B82::
	ld a, [$c8db]
	and $7f
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $00ca
	call Call_0A_4058
	ld a, $de
	ld [hli], a
	call Call_0A_6027
	pop af
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	ret nz

	ld hl, $00d2
	call Call_0A_4058
	ld a, $e3
	ld [hl], a
	ret


Call_0A_6BBC::
	ld a, [$c8db]
	and $7f
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push af
	ld hl, $9710
	call Call_0A_6C33
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $9750
	call Call_0A_6BE1
	ret


Call_0A_6BE1::
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


Call_0A_6C33::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_00a_6c54

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0A_4153
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
	call Call_1AB9
	xor a
	call Call_1AB9
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


Jump_0A_6C6E::
	ld a, [$c825]
	or a
	ret nz

	ld de, $6cef
	ld hl, $c8db
	ld a, [$c8e9]
	ld b, a
	ld a, [hl]
	push af
	call Call_0A_42CA
	pop af
	ld hl, $c8db
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_00a_6c9e

	call Call_0A_6BBC
	ld de, $76e5
	call Call_0A_40B4
	call Call_0A_6B82
	call Call_0A_40E5

jr_00a_6c9e:
	ld a, [$c846]
	bit 1, a
	jp z, Jump_00a_6cc4

	ld a, [$c0db]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld hl, $0018
	call Call_0A_441F
	ld a, $01
	ld [$c905], a
	jr jr_00a_6cee

Jump_00a_6cc4:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_6cee

	ld a, $59
	call Call_1B2C
	ld a, [$c8db]
	and $7f
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$cac0], a
	ld [$c8e8], a
	xor a
	ld [$c8dc], a
	ld hl, $c906
	inc [hl]

Jump_00a_6cee:
jr_00a_6cee:
	ret


	db $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_0A_6CF9::
	ld hl, $001a
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


Jump_0A_6D04::
	ld a, [$c825]
	or a
	ret nz

	call Call_0A_6D11
	ld hl, $c906
	inc [hl]
	ret


Call_0A_6D11::
	call Call_0A_6BBC
	call Call_0A_41EF
	call Call_0A_69DF
	ld de, $75f3
	call Call_0A_40B4
	ld de, $76e5
	call Call_0A_40B4
	call Call_0A_6B82
	ld de, $6cef
	ld a, [$c8db]
	call Call_0A_43E2
	ld de, $7463
	call Call_0A_40B4
	call Call_0A_4323
	ld de, $6da0
	ld a, [$c8dc]
	call Call_0A_43E2
	call Call_0A_40E5
	ret


Jump_0A_6D48::
	ld de, $6da0
	ld hl, $c8dc
	ld b, $02
	call Call_0A_42CA
	ld a, [$c846]
	bit 1, a
	jr z, jr_00a_6d75

	call Call_0A_6B13
	ld hl, $0019
	call Call_0A_441F
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_00a_6d9f

jr_00a_6d75:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_00a_6d9f

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_00a_6d97

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $08
	ld [$c906], a
	jr jr_00a_6d9f

jr_00a_6d97:
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8dd], a

Jump_00a_6d9f:
jr_00a_6d9f:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Jump_0A_6DA6::
	ld hl, $c0d8
	ld a, [$c8db]
	and $7f
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
	ld hl, $001b
	call Call_0A_441F
	ld hl, $c906
	inc [hl]
	ret


	db $c9

Jump_0A_6DCF::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c0d8]
	ld hl, $cac1
	call Call_223B
	ld [hl], $02
	ld a, [$c0d9]
	ld hl, $cac1
	call Call_223B
	ld [hl], $02
	ld a, [$c0da]
	ld hl, $cac1
	call Call_223B
	ld [hl], $02
	ld a, [$c0db]
	ld hl, $cac1
	call Call_223B
	ld [hl], $02
	ld hl, $c0d8
	ld a, [$c8db]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, $cac1
	call Call_223B
	ld [hl], $01
	ld de, $ca8e
	ld a, [$c0d8]
	call Call_0A_6E3F
	ld a, [$c0d9]
	call Call_0A_6E3F
	ld a, [$c0da]
	call Call_0A_6E3F
	ld a, [$c0db]
	call Call_0A_6E3F
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $c905
	inc [hl]
	ret


Call_0A_6E3F::
	ld b, a
	push bc
	push de
	ld hl, $cac1
	call Call_223B
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


Jump_0A_6E53::
	ld hl, $c0d8
	ld a, l
	ld [$c930], a
	ld a, h
	ld [$c931], a
	ld a, [$c8db]
	and $7f
	ld a, a
	ld [$c932], a
	ld a, [$c8e9]
	ld [$c933], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, $01
	ld [$c8ec], a
	ret


Jump_0A_6E77::
	ld de, $2e12
	ld hl, $8800
	call Call_1577
	ld hl, far_Call_56_4485
	rst $10
	call Call_0A_6B38
	call Call_0A_6D11
	ld hl, $001a
	call Call_0A_441F
	ld a, $05
	ld [$c906], a
	xor a
	ld [$c8ec], a
	ret


Jump_0A_6E9A::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	ld hl, $c905
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
