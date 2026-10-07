INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $009", ROMX[$4000], BANK[$9]

BankNumber_09::
	db $09

FarTable_09::
	dw $4005
	dw Call_09_6120

	ld a, [$c8ef]
	rst $00

JumpTable_09_4009::
	dw Jump_09_45F3
	dw Jump_09_4033
	dw Jump_09_4EF9
	dw Jump_09_402E
	dw Jump_09_5B64
	dw Jump_09_4029
	dw Jump_09_4029
	dw Jump_09_4029
	dw Jump_09_402E
	dw Jump_09_402E
	dw Jump_09_402E
	dw Jump_09_4029
	dw Jump_09_45F3
	dw Jump_09_5ECA
	dw Jump_09_4033
	dw Call_09_6120

Jump_09_4029::
	ld hl, far_Call_0A_4003
	rst $10
	ret


Jump_09_402E::
	ld hl, $1200
	rst $10
	ret


Jump_09_4033::
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Call_09_403D::
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


Call_09_404A::
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


Call_09_4059::
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


Call_09_406D::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_09_4076::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_09_4059
	ld a, b
	and $1f
	jr z, jr_009_408b

	ld b, a

jr_009_4085:
	call Call_09_404A
	dec b
	jr nz, jr_009_4085

jr_009_408b:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $76, $40, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $4a, $40, $18, $d3

Call_09_40C9::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_09_406D
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a

jr_009_40d8:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_009_40f7

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
	jr jr_009_40d8

jr_009_40f7:
	ld [hli], a
	jr jr_009_40d8

Call_09_40FA::
	ld a, [$c909]
	ld l, a
	ld a, [$c90a]
	ld h, a
	ld de, $c500
	ld c, $12

jr_009_4107:
	ld b, $20
	push hl

jr_009_410a:
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


Call_09_412F::
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


Call_09_4168::
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


Call_09_41B6::
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


Call_09_4204::
	ld hl, $c500
	ld de, $c300
	ld bc, $0200

jr_009_420d:
	ld a, [de]
	inc de
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_009_420d

	ld de, $c1c0
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


Call_09_4236::
	ld hl, $c500
	ld bc, $0240

jr_009_423c:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_009_423c

	ret


	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

Call_09_4256::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_009_42cf

	ld a, [$c846]
	bit 5, a
	jr z, jr_009_428c

	ld a, [$df0d]
	inc a
	and $01
	ld [$df0d], a
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
	jr c, jr_009_42b3

	ld a, c
	dec a
	jr jr_009_42b3

jr_009_428c:
	ld a, [$c846]
	bit 4, a
	jr z, jr_009_42cf

	ld a, [$df0d]
	inc a
	and $01
	ld [$df0d], a
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
	jr c, jr_009_42b3

	ld a, $00

jr_009_42b3:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_009_4312

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
	call Call_09_448E
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
	jr nz, Call_09_42F1

	ld a, [$c8e1]
	inc a
	ld b, a

Call_09_42F1::
	res 7, [hl]
	ld a, [$c847]
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
	ld a, [$c847]
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
	ld [$c90c], a
	push hl
	push de
	pop de
	pop hl

jr_009_431a:
	ld a, [$c846]
	bit 0, a
	jr z, jr_009_4323

	set 7, [hl]

jr_009_4323:
	ld a, [hl]
	call Call_09_442F
	ret


	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

Call_09_434A::
	res 7, [hl]
	ld a, c
	ldh [$ffd7], a
	ld a, [$c847]
	bit 7, a
	jr z, jr_009_4360

	ld a, $10
	ld [$c90c], a
	call Call_09_43B7
	jr jr_009_4394

jr_009_4360:
	ld a, [$c847]
	bit 6, a
	jr z, jr_009_4371

	ld a, $10
	ld [$c90c], a
	call Call_09_43FE
	jr jr_009_4394

jr_009_4371:
	ld a, [$c847]
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
	ld a, [$c847]
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
	ld [$c90c], a

jr_009_4394:
	push hl
	push de
	pop de
	pop hl

jr_009_4398:
	ld a, [$c846]
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
	call Call_09_456D
	ret


Call_09_43B7::
	push de
	ld a, [hl]
	push hl
	inc hl
	ld c, [hl]
	ld b, $00
	ld hl, $c0a0
	call Call_20AD
	pop hl
	ld a, [hl]
	ld de, $c0a0
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
	call Call_09_43E9
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


Call_09_43E9::
	push hl
	ld a, [$c0a0]
	and $0f
	ld c, $0a
	call Call_1DBE
	ld a, [$c0a1]
	and $0f
	add l
	pop hl
	inc hl
	ld [hld], a
	ret


Call_09_43FE::
	push de
	ld a, [hl]
	push hl
	inc hl
	ld c, [hl]
	ld b, $00
	ld hl, $c0a0
	call Call_20AD
	pop hl
	ld de, $c0a1
	ld a, [hl]
	ld de, $c0a0
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
	call Call_09_43E9
	pop de
	ret


Call_09_442A::
	xor a
	ld [$c90c], a
	ret


Call_09_442F::
	ld c, a
	bit 7, a
	jr nz, jr_009_4444

	ld a, [$c90c]
	and $0f
	push af
	ld a, [$c90c]
	inc a
	ld [$c90c], a
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_09_4076
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

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_4477

	ld a, $e8

jr_009_4477:
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
	jr jr_009_4447

Call_09_448E::
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
	ld a, c
	and $7f
	cp $09
	jr z, jr_009_44b6

	add $f1
	call Call_09_44DB
	ld a, $ee
	jr jr_009_44bd

jr_009_44b6:
	ld a, $f0
	call Call_09_44DB
	ld a, $f1

jr_009_44bd:
	push af
	ldh a, [$ffd5]
	sub $01
	ldh [$ffd5], a
	ldh a, [$ffd6]
	sbc $00
	ldh [$ffd6], a
	pop af
	call Call_09_44DB
	ldh a, [$ffd5]
	add $01
	ldh [$ffd5], a
	ldh a, [$ffd6]
	adc $00
	ldh [$ffd6], a
	ret


Call_09_44DB::
	push af
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	push de
	push bc
	call Call_09_4076
	pop bc
	pop de
	pop af
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


Call_09_44FF::
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

Call_09_4530::
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
	call Call_09_4076
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_009_455b

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_455b

	ld a, $e8

jr_009_455b:
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


Call_09_456D::
	ld c, a
	inc hl
	push de
	push bc
	ld c, [hl]
	ld b, $00
	ld hl, $c0a0
	call Call_20AD
	pop bc
	pop de
	bit 7, c
	jr nz, jr_009_4590

	ld a, [$c90c]
	and $0f
	push af
	ld a, [$c90c]
	inc a
	ld [$c90c], a
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_09_4076
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_009_45bd

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_45bd

	ld a, $e6

jr_009_45bd:
	cp $e0
	jr nz, jr_009_45ce

	push hl
	ld a, b
	ld hl, $c0a0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl

jr_009_45ce:
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
	jr jr_009_4593

Call_09_45E5::
	ld a, [$c8f0]
	add l
	ld l, a
	ld a, [$c8f1]
	adc h
	ld h, a
	call Call_0AD9
	ret


Jump_09_45F3::
	ld a, [$c905]
	rst $00

JumpTable_09_45F7::
	dw Jump_09_4601
	dw Jump_09_464C
	dw Jump_09_4691
	dw Jump_09_46E7
	dw Jump_09_46F1

Jump_09_4601::
	ld hl, $ffb7
	call Call_09_403D
	ld hl, $ffbb
	call Call_09_403D
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
	call Call_09_4204
	ld de, $2e0e
	ld hl, $8800
	call Call_1577
	call Call_09_442A
	ld hl, $c905
	inc [hl]
	ret


Jump_09_464C::
	ld hl, $c905
	inc [hl]
	call Call_09_4204
	call Call_09_465A
	call Call_09_40FA
	ret


Call_09_465A::
	ld de, $6f3c
	call Call_09_40C9
	ld de, $6f1f
	call Call_09_40C9
	ld de, $2e07
	call Call_09_40C9
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_09_406D
	call Call_1FB9
	call Call_09_442A
	ld de, $46df
	ld a, [$c8da]
	call Call_09_4530
	ret


Jump_09_4691::
	ld de, $46df
	ld hl, $c8da
	ld b, $03
	call Call_09_42F1
	ld a, [$c846]
	and $0a
	jr z, jr_009_46ad

	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	jr jr_009_46de

jr_009_46ad:
	ld a, [$c846]
	bit 0, a
	jr z, jr_009_46de

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
	jr jr_009_46de

jr_009_46de:
	ret


	db $21, $00, $61, $00, $a1, $00, $ff, $ff

Jump_09_46E7::
	ld a, [$c8da]
	rst $00

JumpTable_09_46EB::
	dw Jump_09_4707
	dw Jump_09_4AEB
	dw Jump_09_46F1

Jump_09_46F1::
	call Call_09_4204
	ld de, $2e07
	call Call_09_40C9
	call Call_09_40FA
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Jump_09_4707::
	ld a, [$c906]
	rst $00

JumpTable_09_470B::
	dw Jump_09_4721
	dw Jump_09_4795
	dw Jump_09_4890
	dw Jump_09_48F8
	dw Jump_09_4908
	dw Jump_09_494C
	dw Jump_09_4993
	dw Jump_09_49FA
	dw Jump_09_4A1E
	dw Jump_09_4A6A
	dw Jump_09_4ACA

Jump_09_4721::
	ld hl, $0003
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ld a, [$c968]
	ld hl, $478c
	cp $50
	jr z, jr_009_4754

	ld a, [$c925]
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
	ld hl, $c0d8
	ld bc, $0014
	xor a
	call Call_12C7
	pop hl
	ld de, $c0d8

jr_009_4763:
	ld a, [hli]
	ld [de], a
	inc de
	cp $ff
	ret z

	jr jr_009_4763

	db $01, $02, $07, $28, $13, $14, $1d, $26, $ff, $05, $04, $03, $0c, $2a, $2b, $15
	db $1a, $ff, $1f, $20, $21, $22, $23, $24, $ff, $17, $29, $19, $1b, $18, $1c, $25
	db $ff, $01, $02, $07, $08, $0b, $09, $0a, $0c, $ff

Jump_09_4795::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_4875
	call Call_09_47CD
	call Call_09_47A8
	ld hl, $c906
	inc [hl]
	ret


Call_09_47A8::
	call Call_09_4204
	call Call_09_465A
	ld de, $6f7d
	call Call_09_40C9
	call Call_09_480A
	call Call_09_442A
	ld de, $48ec
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_09_44FF
	call Call_09_40FA
	ret


Call_09_47CD::
	ld de, $c0d8
	ld a, [$c8e3]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call Call_09_47E7
	call Call_09_47E7
	call Call_09_47E7

Call_09_47E7::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_009_47f0

	ld a, $00

jr_009_47f0:
	ld [$c823], a
	ld a, $08
	ld [$c822], a
	ld de, $0901
	call Call_09_412F
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


Call_09_480A::
	ld de, $c0d8
	ld a, [$c8e3]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $00ad
	call Call_09_4824
	call Call_09_4824
	call Call_09_4824

Call_09_4824::
	push de
	push hl
	ld a, [de]
	cp $00
	jr z, jr_009_482f

	cp $ff
	jr nz, jr_009_483c

jr_009_482f:
	call Call_09_406D
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
	ld [$da5e], a
	ld hl, far_Call_03_6980
	rst $10
	pop hl
	push hl
	call Call_09_406D
	ld a, [$da63]
	ldh [$ffd5], a
	ld a, [$da64]
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	call Call_1FB9
	pop hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_09_406D
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


Call_09_4875::
	ld hl, $c0d8
	call Call_09_4880
	ld a, c
	ld [$c8e9], a
	ret


Call_09_4880::
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


Jump_09_4890::
	ld de, $48ec
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_09_4256
	pop af
	ld hl, $c8e2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_009_48b1

jr_009_48b1:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_009_48c1

	call Call_09_47CD
	call Call_09_480A
	call Call_09_40FA

jr_009_48c1:
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_48d5

	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c905], a
	jr jr_009_48eb

jr_009_48d5:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_48eb

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	ld a, $01
	ld [$c8dd], a

Jump_009_48eb:
jr_009_48eb:
	ret


	db $92, $01, $a2, $00, $e2, $00, $22, $01, $62, $01, $ff, $ff

Jump_09_48F8::
	ld hl, $0005
	call Call_09_45E5
	ld a, $01
	ld [$c8dc], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4908::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_4915
	ld hl, $c906
	inc [hl]
	ret


Call_09_4915::
	call Call_09_4204
	call Call_09_465A
	ld de, $6f7d
	call Call_09_40C9
	call Call_09_480A
	ld de, $48ec
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_09_44FF
	ld de, $7033
	call Call_09_40C9
	call Call_09_442A
	ld de, $498d
	ld hl, $c8dc
	ld b, $02
	ld a, [hl]
	call Call_09_456D
	call Call_09_40FA
	ret


Jump_09_494C::
	ld de, $498d
	ld hl, $c8dc
	ld b, $02
	ld c, $14
	call Call_09_434A
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_497b

	call Call_09_47A8
	ld hl, $0004
	call Call_09_45E5
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_009_498c

jr_009_497b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_498c

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_009_498c:
jr_009_498c:
	ret


	db $61, $01, $62, $01, $ff, $ff

Jump_09_4993::
	ld hl, $c0d8
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
	ld l, a
	ld h, $08
	ld de, $c180
	call Call_097A
	ld a, [$c8dd]
	ld hl, $c190
	call Call_09A4
	ld hl, far_Call_03_6980
	rst $10
	ld a, [$da63]
	ld c, a
	ld a, [$da64]
	ld b, a
	ld a, [$c8dd]
	call Call_1DE6
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
	ld hl, $c1a0
	call Call_09C7
	ld hl, $0006
	call Call_09_45E5
	xor a
	ld [$c8de], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_49FA::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6efa
	call Call_09_40C9
	call Call_09_442A
	ld de, $4a64
	ld a, [$c8de]
	call Call_09_4530
	call Call_09_40FA
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4A1E::
	ld de, $4a64
	ld hl, $c8de
	ld b, $02
	call Call_09_42F1
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_4a4b

jr_009_4a30:
	call Call_09_4915
	ld hl, $0005
	call Call_09_45E5
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_009_4a63

jr_009_4a4b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_4a63

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_009_4a30

	ld hl, $c906
	inc [hl]

Jump_009_4a63:
jr_009_4a63:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_09_4A6A::
	ld hl, far_Call_03_7160
	rst $10
	ld hl, $c8e4
	ld a, [$ca4b]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc [hl]
	ld hl, $0007
	jr c, jr_009_4ac2

	ld hl, $ca51
	call Call_09_4880
	ld a, [$c8dd]
	add c
	cp $15
	ld hl, $0008
	jr nc, jr_009_4ac2

	ld a, [$c8e4]
	ld l, a
	ld a, [$c8e5]
	ld h, a
	ld a, [$c8e6]
	ld e, a
	call Call_2424
	ld hl, $ca51
	call Call_09_4880
	ld a, c
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c8dd]
	ld b, a
	ld a, [$da5e]

jr_009_4abb:
	ld [hli], a
	dec b
	jr nz, jr_009_4abb

	ld hl, $0009

jr_009_4ac2:
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4ACA::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld a, $00
	ld [$c906], a
	ret


Jump_09_4AEB::
	ld a, [$c906]
	rst $00

JumpTable_09_4AEF::
	dw Jump_09_4B09
	dw Jump_09_4B27
	dw Jump_09_4C81
	dw Jump_09_4CE9
	dw Jump_09_4CF9
	dw Jump_09_4D6B
	dw Jump_09_4DBB
	dw Jump_09_4E05
	dw Jump_09_4E29
	dw Jump_09_4E73
	dw Jump_09_4EBC
	dw Jump_09_4EDD
	dw Jump_09_4EE8

Jump_09_4B09::
	call Call_09_4C24
	ld hl, $c0d8
	call Call_09_4880
	ld a, c
	or a
	jr nz, jr_009_4b1c

	ld a, $0b
	ld [$c906], a
	ret


jr_009_4b1c:
	ld hl, $000a
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4B27::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_4C24
	call Call_09_4875
	call Call_09_47CD
	call Call_09_4B3D
	ld hl, $c906
	inc [hl]
	ret


Call_09_4B3D::
	call Call_09_4204
	call Call_09_465A
	ld de, $6f7d
	call Call_09_40C9
	call Call_09_4B62
	call Call_09_442A
	ld de, $4cdd
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_09_44FF
	call Call_09_40FA
	ret


Call_09_4B62::
	ld de, $c0d8
	ld a, [$c8e3]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $00ad
	call Call_09_4B7C
	call Call_09_4B7C
	call Call_09_4B7C

Call_09_4B7C::
	push de
	push hl
	ld a, [de]
	cp $00
	jr z, jr_009_4b87

	cp $ff
	jr nz, jr_009_4b94

jr_009_4b87:
	call Call_09_406D
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
	ld [$da5e], a
	call Call_09_4BC8
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	pop hl
	call Call_09_406D
	call Call_1FB9
	pop hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_09_406D
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


Call_09_4BC8::
	ld hl, far_Call_03_6980
	rst $10
	ld a, [$da63]
	ld l, a
	ld a, [$da64]
	ld h, a
	ld a, [$c968]
	cp $50
	ret z

	ld a, [$da5e]
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
	call Call_1E0D
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


Call_09_4C24::
	ld hl, far_Call_03_7160
	rst $10
	ld hl, $d665
	ld bc, $0030
	xor a
	call Call_12C7
	ld hl, $c0d8
	ld bc, $0014
	xor a
	call Call_12C7
	ld de, $ca51
	ld b, $14

jr_009_4c41:
	ld a, [de]
	or a
	jr z, jr_009_4c6b

	cp $ff
	jr z, jr_009_4c6b

	ld [$da5e], a
	ld hl, $d665
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	push de
	push bc
	ld hl, far_Call_03_6980
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
	ld de, $c0d8
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


Jump_09_4C81::
	ld de, $4cdd
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_09_4256
	pop af
	ld hl, $c8e2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_009_4ca2

jr_009_4ca2:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_009_4cb2

	call Call_09_47CD
	call Call_09_4B62
	call Call_09_40FA

jr_009_4cb2:
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_4cc6

	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c905], a
	jr jr_009_4cdc

jr_009_4cc6:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_4cdc

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	ld a, $01
	ld [$c8dd], a

Jump_009_4cdc:
jr_009_4cdc:
	ret


	db $92, $01, $a2, $00, $e2, $00, $22, $01, $62, $01, $ff, $ff

Jump_09_4CE9::
	ld hl, $000c
	call Call_09_45E5
	ld a, $01
	ld [$c8dc], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4CF9::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_4D06
	ld hl, $c906
	inc [hl]
	ret


Call_09_4D06::
	call Call_09_4204
	call Call_09_465A
	ld de, $6f7d
	call Call_09_40C9
	call Call_09_4B62
	ld de, $4cdd
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_09_44FF
	ld de, $7044
	call Call_09_40C9
	ld hl, $c0d8
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
	ld hl, $d665
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call Call_09_406D
	call Call_2082
	call Call_09_442A
	ld de, $4db5
	ld hl, $c8dc
	ld b, $02
	ld a, [hl]
	call Call_09_456D
	call Call_09_40FA
	ret


Jump_09_4D6B::
	ld de, $4db5
	ld hl, $d665
	ld a, [$da5e]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, $c8dc
	call Call_09_434A
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_4da3

	call Call_09_4B3D
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
	jr jr_009_4db4

jr_009_4da3:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_4db4

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_009_4db4:
jr_009_4db4:
	ret


	db $61, $01, $62, $01, $ff, $ff

Jump_09_4DBB::
	ld a, [$da5e]
	ld l, a
	ld h, $08
	ld de, $c180
	call Call_097A
	ld a, [$c8dd]
	ld hl, $c190
	call Call_09A4
	call Call_09_4BC8
	ld c, l
	ld b, h
	ld a, [$c8dd]
	call Call_1DE6
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
	ld hl, $c1a0
	call Call_09C7
	ld hl, $000d
	call Call_09_45E5
	xor a
	ld [$c8de], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4E05::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6efa
	call Call_09_40C9
	call Call_09_442A
	ld de, $4e6d
	ld a, [$c8de]
	call Call_09_4530
	call Call_09_40FA
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4E29::
	ld de, $4e6d
	ld hl, $c8de
	ld b, $02
	call Call_09_42F1
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_4e54

jr_009_4e3b:
	call Call_09_4D06
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
	jr jr_009_4e6c

jr_009_4e54:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_4e6c

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_009_4e3b

	ld hl, $c906
	inc [hl]

Jump_009_4e6c:
jr_009_4e6c:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_09_4E73::
	ld hl, $c8e4
	ld a, [$ca4b]
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

	ld a, [$c8e4]
	ld l, a
	ld a, [$c8e5]
	ld h, a
	ld a, [$c8e6]
	ld e, a
	call Call_241A
	ld a, [$c8dd]
	ld b, a

jr_009_4ea8:
	push bc
	ld hl, far_Call_03_71B6
	rst $10
	pop bc
	dec b
	jr nz, jr_009_4ea8

	ld hl, $000f

jr_009_4eb4:
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4EBC::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld a, $00
	ld [$c906], a
	ret


Jump_09_4EDD::
	ld hl, $000b
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_4EE8::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c905], a
	ret


Jump_09_4EF9::
	ld a, [$c905]
	rst $00

JumpTable_09_4EFD::
	dw Jump_09_4F0B
	dw Jump_09_4F56
	dw Jump_09_4FB3
	dw Jump_09_5023
	dw Jump_09_5080
	dw Jump_09_50E8
	dw Jump_09_5104

Jump_09_4F0B::
	ld hl, $ffb7
	call Call_09_403D
	ld hl, $ffbb
	call Call_09_403D
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
	call Call_09_4204
	ld de, $2e0f
	ld hl, $8800
	call Call_1577
	call Call_09_442A
	ld hl, $c905
	inc [hl]
	ret


Jump_09_4F56::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c905
	inc [hl]
	call Call_09_4204
	call Call_09_4F69
	call Call_09_40FA
	ret


Call_09_4F69::
	ld a, $02
	ld [$c822], a
	ld a, $0b
	ld [$c823], a
	ld hl, $8a40
	ld de, $0c01
	call Call_09_412F
	ld de, $7838
	call Call_09_40C9
	ld de, $6f1f
	call Call_09_40C9
	ld de, $2e07
	call Call_09_40C9
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_09_406D
	call Call_1FB9
	call Call_09_442A
	ld de, $501b
	ld a, [$c8da]
	call Call_09_4530
	ret


Jump_09_4FB3::
	ld a, [$c825]
	or a
	ret nz

	ld de, $501b
	ld hl, $c8da
	ld b, $03
	call Call_09_42F1
	ld a, [$c846]
	and $0a
	jr z, jr_009_4fdc

	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	jr jr_009_501a

jr_009_4fdc:
	ld a, [$c846]
	bit 0, a
	jr z, jr_009_501a

	ld a, $59
	call Call_1B2C
	ld a, [$c8da]
	cp $82
	jp z, Jump_09_5104

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
	ld hl, $0003
	ld a, [$c8da]
	and $7f
	jr z, jr_009_5015

	ld hl, $000e

jr_009_5015:
	call Call_09_45E5
	jr jr_009_501a

jr_009_501a:
	ret


	db $21, $00, $61, $00, $a1, $00, $ff, $ff

Jump_09_5023::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c905
	inc [hl]
	call Call_09_4204
	call Call_09_5049
	call Call_09_40FA
	ld a, $02
	ld [$c822], a
	ld a, $0c
	ld [$c823], a
	ld hl, $8a40
	ld de, $0c01
	call Call_09_412F
	ret


Call_09_5049::
	ld de, $7838
	call Call_09_40C9
	ld de, $6f1f
	call Call_09_40C9
	ld de, $2e07
	call Call_09_40C9
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_09_406D
	call Call_1FB9
	call Call_09_442A
	ld de, $50b0
	ld a, [$c8db]
	call Call_09_4530
	ret


Jump_09_5080::
	ld a, [$c825]
	or a
	ret nz

	ld de, $50b0
	ld hl, $c8db
	ld b, $03
	call Call_09_42F1
	ld a, [$c846]
	and $0a
	jr z, jr_009_50b8

	call Call_09_4204
	call Call_09_4F69
	call Call_09_40FA
	ld hl, $0001
	call Call_09_45E5
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	jr jr_009_50e7

	db $21, $00, $61, $00, $a1, $00, $ff, $ff

jr_009_50b8:
	ld a, [$c846]
	bit 0, a
	jr z, jr_009_50e7

	ld a, $59
	call Call_1B2C
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c906], a
	ld hl, $c8db
	set 7, [hl]
	ld hl, $c8dc
	ld bc, $0006
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7

jr_009_50e7:
	ret


Jump_09_50E8::
	ld a, [$c8da]
	rst $00

JumpTable_09_50EC::
	dw Jump_09_50F0
	dw Jump_09_50FA

Jump_09_50F0::
	ld a, [$c8db]
	rst $00

JumpTable_09_50F4::
	dw Jump_09_511A
	dw Jump_09_53AF
	dw Jump_09_5104

Jump_09_50FA::
	ld a, [$c8db]
	rst $00

JumpTable_09_50FE::
	dw Jump_09_5519
	dw Jump_09_578D
	dw Jump_09_5104

Jump_09_5104::
	call Call_09_4204
	ld de, $2e07
	call Call_09_40C9
	call Call_09_40FA
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Jump_09_511A::
	ld a, [$c906]
	rst $00

JumpTable_09_511E::
	dw Jump_09_5130
	dw $5161
	dw $5200
	dw $527e
	dw $528e
	dw $52fd
	dw $534f
	dw $537d
	dw $539e

Jump_09_5130::
	ld hl, $ca51
	call Call_09_51F0
	ld a, c
	or a
	ld hl, $0005
	jr z, jr_009_5158

	ld hl, $ca65
	ld b, $28
	call Call_09_51F2
	ld a, c
	cp $28
	ld hl, $0006
	jr nc, jr_009_5158

	ld hl, $c906
	inc [hl]
	ld hl, $0004
	call Call_09_45E5
	ret


jr_009_5158:
	call Call_09_45E5
	ld a, $08
	ld [$c906], a
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

Call_09_51E5::
	ld hl, $c0d8
	call Call_09_51F0
	ld a, c
	ld [$c8e9], a
	ret


Call_09_51F0::
	ld b, $28

Call_09_51F2::
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

Jump_09_53AF::
	ld a, [$c906]
	rst $00

JumpTable_09_53B3::
	dw Jump_09_53BD
	dw Jump_09_53DC
	dw Jump_09_5439
	dw Jump_09_549B
	dw Jump_09_54FF

Jump_09_53BD::
	ld hl, $000a
	call Call_09_45E5
	ld a, $02
	ld [$c8dc], a
	ld a, $00
	ld [$c8df], a
	ld a, $00
	ld [$c8e0], a
	ld a, $00
	ld [$c8e1], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_53DC::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_53E9
	ld hl, $c906
	inc [hl]
	ret


Call_09_53E9::
	call Call_09_4204
	call Call_09_5049
	ld a, $02
	ld [$c822], a
	ld a, $55
	ld [$c823], a
	ld hl, $8a00
	ld de, $0401
	call Call_09_412F
	ld de, $71ca
	call Call_09_40C9
	ld de, $71e7
	call Call_09_40C9
	ld a, [$ca4e]
	ldh [$ffd5], a
	ld a, [$ca4f]
	ldh [$ffd6], a
	ld a, [$ca50]
	ldh [$ffd7], a
	ld hl, $016d
	call Call_09_406D
	call Call_1FA5
	call Call_09_442A
	ld de, $548f
	ld hl, $c8dc
	ld b, $02
	ld a, [hl]
	call Call_09_5A67
	call Call_09_40FA
	ret


Jump_09_5439::
	ld de, $548f
	ld hl, $c8dc
	ld b, $03
	call Call_09_590C
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_5474

	ld a, $02
	ld [$c822], a
	ld a, $0c
	ld [$c823], a
	ld hl, $8a40
	ld de, $0c01
	call Call_09_412F
	call Call_09_4204
	call Call_09_5049
	call Call_09_40FA
	ld hl, $0003
	call Call_09_45E5
	ld a, $04
	ld [$c905], a
	jr jr_009_548e

jr_009_5474:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_548e

	ld hl, $c8df
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_009_548e

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_009_548e:
jr_009_548e:
	ret


	db $8e, $00, $8f, $00, $90, $00, $91, $00, $92, $00, $ff, $ff

Jump_09_549B::
	ld hl, $c8df
	ld a, [$ca4b]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc [hl]
	ld hl, $000b
	jr c, jr_009_54f7

	ld hl, $c8df
	ld a, [$ca4e]
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

	ld a, [$c8df]
	ld l, a
	ld a, [$c8e0]
	ld h, a
	ld a, [$c8e1]
	ld e, a
	call Call_2424
	ld a, [$c8df]
	ld l, a
	ld a, [$c8e0]
	ld h, a
	ld a, [$c8e1]
	ld e, a
	call Call_242E
	call Call_09_53E9
	ld hl, $000d

jr_009_54f7:
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_54FF::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_4204
	call Call_09_4F69
	call Call_09_40FA
	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c905], a
	ret


Jump_09_5519::
	ld a, [$c906]
	rst $00

JumpTable_09_551D::
	dw Jump_09_552F
	dw Jump_09_5560
	dw Jump_09_55E0
	dw Jump_09_565E
	dw Jump_09_566E
	dw Jump_09_56DD
	dw Jump_09_572F
	dw Jump_09_575B
	dw Jump_09_577C

Jump_09_552F::
	ld hl, $ca65
	ld b, $28
	call Call_09_51F2
	ld a, c
	or a
	ld hl, $0011
	jr z, jr_009_5557

	ld hl, $ca51
	call Call_09_51F0
	ld a, c
	cp $14
	ld hl, $0012
	jr nc, jr_009_5557

	ld hl, $c906
	inc [hl]
	ld hl, $0010
	call Call_09_45E5
	ret


jr_009_5557:
	call Call_09_45E5
	ld a, $08
	ld [$c906], a
	ret


Jump_09_5560::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_5598
	call Call_09_51E5
	call Call_09_47CD
	call Call_09_5576
	ld hl, $c906
	inc [hl]
	ret


Call_09_5576::
	call Call_09_4204
	call Call_09_5049
	ld de, $7153
	call Call_09_40C9
	call Call_09_442A
	ld de, $5652
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_09_44FF
	call Call_09_40FA
	ret


Call_09_5598::
	call Call_09_5AEA
	ld hl, $d665
	ld bc, $0030
	xor a
	call Call_12C7
	ld hl, $c0d8
	ld bc, $0028
	xor a
	call Call_12C7
	ld de, $ca65
	ld b, $28

jr_009_55b4:
	ld a, [de]
	or a
	jr z, jr_009_55ca

	cp $ff
	jr z, jr_009_55ca

	inc de
	ld hl, $d665
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
	ld de, $c0d8
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


Jump_09_55E0::
	ld de, $5652
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_09_4256
	pop af
	ld hl, $c8e2
	and $7f
	ld b, a
	ld a, [hl]
	and $7f
	cp b
	jr z, jr_009_5601

jr_009_5601:
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_009_560b

	call Call_09_47CD

jr_009_560b:
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_563b

	ld a, $02
	ld [$c822], a
	ld a, $0c
	ld [$c823], a
	ld hl, $8a40
	ld de, $0c01
	call Call_09_412F
	call Call_09_4204
	call Call_09_5049
	call Call_09_40FA
	ld hl, $000e
	call Call_09_45E5
	ld a, $04
	ld [$c905], a
	jr jr_009_5651

jr_009_563b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_5651

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	ld a, $01
	ld [$c8de], a

Jump_009_5651:
jr_009_5651:
	ret


	db $72, $01, $89, $00, $c9, $00, $09, $01, $49, $01, $ff, $ff

Jump_09_565E::
	ld hl, $0013
	call Call_09_45E5
	ld a, $01
	ld [$c8dd], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_566E::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_567B
	ld hl, $c906
	inc [hl]
	ret


Call_09_567B::
	call Call_09_4204
	call Call_09_5049
	ld de, $7153
	call Call_09_40C9
	ld de, $5652
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_09_44FF
	ld de, $7044
	call Call_09_40C9
	ld hl, $c0d8
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da5e], a
	ld hl, $d665
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $00
	ld hl, $0164
	call Call_09_406D
	call Call_2082
	call Call_09_442A
	ld de, $5729
	ld hl, $c8dd
	ld b, $02
	ld a, [hl]
	call Call_09_456D
	call Call_09_40FA
	ret


Jump_09_56DD::
	ld de, $5729
	ld hl, $d665
	ld a, [$da5e]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $02
	ld hl, $c8dd
	call Call_09_434A
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_5717

	call Call_09_5576
	ld hl, $0010
	call Call_09_45E5
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_009_5728

jr_009_5717:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_5728

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_009_5728:
jr_009_5728:
	ret


	db $61, $01, $62, $01, $ff, $ff

Jump_09_572F::
	ld hl, $ca51
	call Call_09_51F0
	ld a, [$c8de]
	add c
	cp $15
	ld hl, $0014
	jr nc, jr_009_5753

	ld a, [$c8de]
	ld b, a

jr_009_5744:
	push bc
	call Call_09_5B40
	ld hl, far_Call_03_7190
	rst $10
	pop bc
	dec b
	jr nz, jr_009_5744

	ld hl, $0015

jr_009_5753:
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_575B::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8dc
	ld bc, $0006
	ld a, $00
	call Call_12C7
	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld a, $00
	ld [$c906], a
	ret


Jump_09_577C::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c905], a
	ret


Jump_09_578D::
	ld a, [$c906]
	rst $00

JumpTable_09_5791::
	dw Jump_09_579B
	dw Jump_09_57CF
	dw Jump_09_582C
	dw Jump_09_588E
	dw Jump_09_58F2

Jump_09_579B::
	ld hl, $ca4e
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr nz, jr_009_57b0

	ld hl, $000f
	call Call_09_45E5
	ld a, $04
	ld [$c906], a
	ret


jr_009_57b0:
	ld hl, $0016
	call Call_09_45E5
	ld a, $02
	ld [$c8dc], a
	ld a, $00
	ld [$c8df], a
	ld a, $00
	ld [$c8e0], a
	ld a, $00
	ld [$c8e1], a
	ld hl, $c906
	inc [hl]
	ret


Jump_09_57CF::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_57DC
	ld hl, $c906
	inc [hl]
	ret


Call_09_57DC::
	call Call_09_4204
	call Call_09_5049
	ld a, $02
	ld [$c822], a
	ld a, $55
	ld [$c823], a
	ld hl, $8a00
	ld de, $0401
	call Call_09_412F
	ld de, $71ca
	call Call_09_40C9
	ld de, $71e7
	call Call_09_40C9
	ld a, [$ca4e]
	ldh [$ffd5], a
	ld a, [$ca4f]
	ldh [$ffd6], a
	ld a, [$ca50]
	ldh [$ffd7], a
	ld hl, $016d
	call Call_09_406D
	call Call_1FA5
	call Call_09_442A
	ld de, $5882
	ld hl, $c8dc
	ld b, $02
	ld a, [hl]
	call Call_09_5A67
	call Call_09_40FA
	ret


Jump_09_582C::
	ld de, $5882
	ld hl, $c8dc
	ld b, $03
	call Call_09_590C
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_5867

	ld a, $02
	ld [$c822], a
	ld a, $0c
	ld [$c823], a
	ld hl, $8a40
	ld de, $0c01
	call Call_09_412F
	call Call_09_4204
	call Call_09_5049
	call Call_09_40FA
	ld hl, $000e
	call Call_09_45E5
	ld a, $04
	ld [$c905], a
	jr jr_009_5881

jr_009_5867:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_5881

	ld hl, $c8df
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_009_5881

	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]

Jump_009_5881:
jr_009_5881:
	ret


	db $8e, $00, $8f, $00, $90, $00, $91, $00, $92, $00, $ff, $ff

Jump_09_588E::
	ld hl, $c8df
	ld a, [$ca4e]
	sub [hl]
	inc hl
	ld a, [$ca4f]
	sbc [hl]
	inc hl
	ld a, [$ca50]
	sbc [hl]
	ld hl, $0017
	jr c, jr_009_58ea

	ld hl, $c8df
	ld a, [$ca4b]
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

	ld a, [$c8df]
	ld l, a
	ld a, [$c8e0]
	ld h, a
	ld a, [$c8e1]
	ld e, a
	call Call_2438
	ld a, [$c8df]
	ld l, a
	ld a, [$c8e0]
	ld h, a
	ld a, [$c8e1]
	ld e, a
	call Call_241A
	call Call_09_57DC
	ld hl, $0019

jr_009_58ea:
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_58F2::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_4204
	call Call_09_4F69
	call Call_09_40FA
	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c905], a
	ret


Call_09_590C::
	res 7, [hl]
	push de
	ld a, [$c847]
	bit 7, a
	jr z, jr_009_5920

	ld a, $10
	ld [$c90c], a
	call Call_09_5965
	jr jr_009_5954

jr_009_5920:
	ld a, [$c847]
	bit 6, a
	jr z, jr_009_5931

	ld a, $10
	ld [$c90c], a
	call Call_09_5A30
	jr jr_009_5954

jr_009_5931:
	ld a, [$c847]
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
	ld a, [$c847]
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
	ld [$c90c], a

jr_009_5954:
	push hl
	pop hl

jr_009_5956:
	ld a, [$c847]
	bit 0, a
	jr z, jr_009_595f

	set 7, [hl]

jr_009_595f:
	pop de
	ld a, [hl]
	call Call_09_5A67
	ret


Call_09_5965::
	push de
	ld a, [hl]
	push hl
	ld a, [$c8df]
	ldh [$ffd5], a
	ld a, [$c8e0]
	ldh [$ffd6], a
	ld a, [$c8e1]
	ldh [$ffd7], a
	ld hl, $c0a0
	call Call_1FF8
	pop hl
	ld a, [hl]
	ld de, $c0a0
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
	call Call_09_5999
	pop de
	ret


Call_09_5999::
	push hl
	ld bc, $2710
	ld a, [$c0a0]
	and $0f
	call Call_1DE6
	ld a, l
	ld [$c8df], a
	ld a, h
	ld [$c8e0], a
	ld a, e
	ld [$c8e1], a
	ld bc, $03e8
	ld a, [$c0a1]
	and $0f
	call Call_1DE6
	ld a, [$c8df]
	add l
	ld [$c8df], a
	ld a, [$c8e0]
	adc h
	ld [$c8e0], a
	ld a, [$c8e1]
	adc e
	ld [$c8e1], a
	ld bc, $0064
	ld a, [$c0a2]
	and $0f
	call Call_1DE6
	ld a, [$c8df]
	add l
	ld [$c8df], a
	ld a, [$c8e0]
	adc h
	ld [$c8e0], a
	ld a, [$c8e1]
	adc e
	ld [$c8e1], a
	ld bc, $000a
	ld a, [$c0a3]
	and $0f
	call Call_1DE6
	ld a, [$c8df]
	add l
	ld [$c8df], a
	ld a, [$c8e0]
	adc h
	ld [$c8e0], a
	ld a, [$c8e1]
	adc e
	ld [$c8e1], a
	ld a, [$c0a4]
	and $0f
	ld l, a
	ld a, [$c8df]
	add l
	ld [$c8df], a
	ld a, [$c8e0]
	adc $00
	ld [$c8e0], a
	ld a, [$c8e1]
	adc $00
	ld [$c8e1], a
	pop hl
	ret


Call_09_5A30::
	push de
	ld a, [hl]
	push hl
	ld a, [$c8df]
	ldh [$ffd5], a
	ld a, [$c8e0]
	ldh [$ffd6], a
	ld a, [$c8e1]
	ldh [$ffd7], a
	ld hl, $c0a0
	call Call_1FF8
	pop hl
	ld de, $c0a1
	ld a, [hl]
	ld de, $c0a0
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
	call Call_09_5999
	pop de
	ret


Call_09_5A67::
	ld c, a
	push de
	push bc
	ld a, [$c8df]
	ldh [$ffd5], a
	ld a, [$c8e0]
	ldh [$ffd6], a
	ld a, [$c8e1]
	ldh [$ffd7], a
	ld hl, $c0a0
	call Call_1FF8
	pop bc
	pop de
	bit 7, c
	jr nz, jr_009_5a95

	ld a, [$c90c]
	and $0f
	push af
	ld a, [$c90c]
	inc a
	ld [$c90c], a
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_09_4076
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_009_5ac2

	ld a, [$c90c]
	bit 4, a
	ld a, $e0
	jr nz, jr_009_5ac2

	ld a, $e6

jr_009_5ac2:
	cp $e0
	jr nz, jr_009_5ad3

	push hl
	ld a, b
	ld hl, $c0a0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl

jr_009_5ad3:
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
	jr jr_009_5a98

Call_09_5AEA::
	ld hl, $d665
	ld de, $ca65
	ld b, $28

jr_009_5af2:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_009_5af2

	ld hl, $ca65
	ld bc, $0028
	ld a, $ff
	call Call_12C7
	ld hl, $d665
	ld de, $ca65
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

Call_09_5B40::
	ld a, [$da5e]
	cp $00
	ret z

	cp $ff
	ret z

	ld hl, $ca65
	ld b, $28

jr_009_5b4e:
	ld a, [$da5e]
	cp [hl]
	jr z, jr_009_5b5e

	inc hl
	dec b
	jr nz, jr_009_5b4e

	ld a, $ff
	ld [$da5e], a
	ret


jr_009_5b5e:
	ld [hl], $ff
	call Call_09_5AEA
	ret


Jump_09_5B64::
	ld a, [$c905]
	rst $00

JumpTable_09_5B68::
	dw Jump_09_5B72
	dw Jump_09_5BBA
	dw Jump_09_5BBF
	dw Jump_09_5BF1
	dw Jump_09_5BF4

Jump_09_5B72::
	ld hl, $ffb7
	call Call_09_403D
	ld hl, $ffbb
	call Call_09_403D
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
	call Call_09_4204
	ld de, $2e11
	ld hl, $8800
	call Call_1577
	ld hl, $c905
	inc [hl]
	ret


Jump_09_5BBA::
	ld hl, $c905
	inc [hl]
	ret


Jump_09_5BBF::
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
	ld a, [$cab4]
	and $03
	ld [$c8e2], a
	ld a, [$cab4]
	cp $04
	ret c

	ld a, $01
	ld [$c8e3], a
	ret


Jump_09_5BF1::
	jp Jump_009_5c0a


Jump_09_5BF4::
	call Call_09_4204
	ld de, $2e07
	call Call_09_40C9
	call Call_09_40FA
	ld hl, $c8eb
	res 4, [hl]
	xor a
	ld [$c905], a
	ret


Jump_009_5c0a:
	ld a, [$c906]
	rst $00

JumpTable_09_5C0E::
	dw Jump_09_5C20
	dw Jump_09_5C43
	dw Jump_09_5D33
	dw Jump_09_5DAE
	dw Jump_09_5E0A
	dw Jump_09_5E2E
	dw Jump_09_5EA7
	dw Jump_09_5EAC
	dw Jump_09_5EB6

Jump_09_5C20::
	call Call_09_5C28
	ld hl, $c906
	inc [hl]
	ret


Call_09_5C28::
	ld hl, $c0d8
	ld bc, $0008
	ld a, $90
	call Call_12C7
	ld a, [$cab4]
	or a
	ret z

	ld b, a
	ld hl, $c0d8

jr_009_5c3c:
	ld [hl], $ac
	inc hl
	dec b
	jr nz, jr_009_5c3c

	ret


Jump_09_5C43::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_5C97
	call Call_09_5C53
	ld hl, $c906
	inc [hl]
	ret


Call_09_5C53::
	call Call_09_4204
	ld de, $2e07
	call Call_09_40C9
	ld de, $74a0
	call Call_09_40C9
	ld de, $6f1f
	call Call_09_40C9
	call Call_09_5CE0
	ld a, [$ca4b]
	ldh [$ffd5], a
	ld a, [$ca4c]
	ldh [$ffd6], a
	ld a, [$ca4d]
	ldh [$ffd7], a
	ld hl, $002e
	call Call_09_406D
	call Call_1FB9
	call Call_09_442A
	ld de, $5da2
	ld b, $04
	ld c, $04
	ld hl, $c8e2
	call Call_09_44FF
	call Call_09_40FA
	ret


Call_09_5C97::
	ld de, $5d1b
	ld a, [$c8e3]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8800
	call Call_09_5CCE
	call Call_09_5CCE
	call Call_09_5CCE
	call Call_09_5CCE
	ld de, $c0d8
	ld a, [$c8e3]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8840
	call Call_09_5CCE
	call Call_09_5CCE
	call Call_09_5CCE

Call_09_5CCE::
	push de
	push hl
	ld a, [de]
	call Call_09_41B6
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


Call_09_5CE0::
	ld de, $5d23
	ld a, [$c8e3]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $00ab
	call Call_09_5CFB
	call Call_09_5CFB
	call Call_09_5CFB

Call_09_5CFB::
	push de
	push hl
	ld a, [de]
	ldh [$ffd5], a
	inc de
	ld a, [de]
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	call Call_09_406D
	call Call_1FB9
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

Jump_09_5D33::
	ld de, $5da4
	ld hl, $c8e2
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call Call_09_42F1
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_009_5d51

	call Call_09_5C97
	call Call_09_5CE0
	call Call_09_40FA

jr_009_5d51:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_5d90

	ld hl, $c0d8
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
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
	call Call_09_45E5
	ld a, $08
	ld [$c906], a
	jr jr_009_5da1

Jump_009_5d81:
	ld a, $59
	call Call_1B2C
	ld hl, $c906
	inc [hl]
	xor a
	ld [$c8de], a
	jr jr_009_5da1

Jump_009_5d90:
	ld a, [$c846]
	bit 1, a
	jp z, Jump_009_5da1

	ld a, $ff
	ld [$d9cd], a
	ld hl, $c905
	inc [hl]

Jump_009_5da1:
jr_009_5da1:
	ret


	db $8c, $01, $a2, $00, $e2, $00, $22, $01, $62, $01, $ff, $ff

Jump_09_5DAE::
	ld hl, $5d23
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$ca4b]
	sub [hl]
	inc hl
	ld a, [$ca4c]
	sbc [hl]
	inc hl
	ld a, [$ca4d]
	sbc $00
	jr nc, jr_009_5de1

	ld hl, $0005
	call Call_09_45E5
	ld a, $08
	ld [$c906], a
	ret


jr_009_5de1:
	ld de, $5d1b
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [$c180], a
	ld a, $f0
	ld [$c181], a
	ld hl, $0004
	call Call_09_45E5
	ld hl, $c906
	inc [hl]
	ret


Jump_09_5E0A::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6ed5
	call Call_09_40C9
	call Call_09_442A
	ld de, $5ea1
	ld a, [$c8de]
	call Call_09_4530
	call Call_09_40FA
	ld hl, $c906
	inc [hl]
	ret


Jump_09_5E2E::
	ld de, $5ea1
	ld hl, $c8de
	ld b, $02
	call Call_09_42F1
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_5e5b

jr_009_5e40:
	call Call_09_5C53
	ld hl, $0001
	call Call_09_45E5
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	ld hl, $c906
	dec [hl]
	jr jr_009_5ea0

jr_009_5e5b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_5ea0

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_009_5e40

	ld hl, $5d23
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
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
	call Call_2424
	ld a, [$c8e3]
	add a
	add a
	ld b, a
	ld a, [$c8e2]
	and $7f
	add b
	ld [$d9ce], a
	ld hl, $c906
	inc [hl]

Jump_009_5ea0:
jr_009_5ea0:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_09_5EA7::
	ld hl, $c906
	inc [hl]
	ret


Jump_09_5EAC::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c905
	inc [hl]
	ret


Jump_09_5EB6::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_5C53
	ld hl, $0001
	call Call_09_45E5
	ld a, $01
	ld [$c906], a
	ret


Jump_09_5ECA::
	ld a, [$c905]
	rst $00

JumpTable_09_5ECE::
	dw Jump_09_5ED6
	dw Jump_09_5F24
	dw Jump_09_60AE
	dw Jump_09_60FA

Jump_09_5ED6::
	ld hl, $ffb7
	call Call_09_403D
	ld hl, $ffbb
	call Call_09_403D
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
	call Call_09_4236
	call Call_09_40FA
	call Call_09_442A
	ld a, $01
	ld [$c8ec], a
	xor a
	ld [$df0d], a
	ld hl, $c905
	inc [hl]
	ret


Jump_09_5F24::
	ld hl, $c905
	inc [hl]
	call Call_09_4236
	call Call_09_604D
	call Call_09_5F4D
	call Call_09_5F38
	call Call_09_40FA
	ret


Call_09_5F38::
	ld de, $6cde
	call Call_09_40C9
	ld a, [$c8e9]
	cp $09
	ret c

	ld hl, $0212
	call Call_09_406D
	ld [hl], $e7
	ret


Call_09_5F4D::
	ld de, $c0d8
	ld a, [$c8db]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9380
	call Call_09_5FA2
	call Call_09_5FA2
	call Call_09_5FA2
	call Call_09_5FA2
	call Call_09_5FA2
	call Call_09_5FA2
	call Call_09_5FA2
	call Call_09_5FA2
	ld de, $c0d8
	ld a, [$c8db]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $8880
	call Call_09_6004
	call Call_09_6004
	call Call_09_6004
	call Call_09_6004
	call Call_09_6004
	call Call_09_6004
	call Call_09_6004
	call Call_09_6004
	ret


Call_09_5FA2::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_009_5fc5

	ld a, $6f
	ld [$c823], a
	ld a, $02
	ld [$c822], a
	ld de, $0901
	call Call_09_412F
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
	call Call_1577
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

Call_09_6004::
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
	call Call_26AE
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
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld de, $0901
	call Call_09_412F
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


Call_09_604D::
	ld hl, $c0d8
	ld bc, $0010
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $609e
	ld b, $00

jr_009_6060:
	push bc
	push de
	push hl
	ld a, [de]
	ld c, a
	ld b, $00
	call Call_26AE
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
	ld [$c8e9], a
	ret


	db $10, $11, $12, $13, $14, $16, $17, $19, $1d, $1c, $1a, $1f, $20, $22, $23, $25
	db $09, $1c, $c4, $44, $66, $0a, $45, $c5, $2a, $58, $2b, $99, $ad, $43, $94, $9a
	db $00, $30, $30, $31, $31, $32, $32, $33, $33, $34, $34, $35, $35, $36, $36, $37

Jump_09_60AE::
	ld de, $60f2
	ld hl, $c8da
	ld c, $01
	ld a, [$c8e9]
	cp $09
	jr c, jr_009_60bf

	ld c, $02

jr_009_60bf:
	ld b, $01
	ld a, [$c8db]
	push af
	call Call_09_4256
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_009_60d2

	call Call_09_5F4D

jr_009_60d2:
	ld a, [$c846]
	and $0a
	jr z, jr_009_60df

	ld hl, $c905
	inc [hl]
	jr jr_009_60f1

jr_009_60df:
	ld a, [$c846]
	bit 0, a
	jr z, jr_009_60f1

	ld a, $59
	call Call_1B2C
	ld hl, $c905
	inc [hl]
	jr jr_009_60f1

jr_009_60f1:
	ret


	db $12, $02, $ff, $ff, $ff, $ff, $ff, $ff

Jump_09_60FA::
	call Call_09_4236
	call Call_09_40FA
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


Call_09_6120::
	ld a, [$c905]
	cp $09
	jr nc, jr_009_6155

	cp $02
	jr c, jr_009_6155

	ld hl, $ffc3
	ld a, $19
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $21
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, [$c8f4]
	ld [hli], a
	ld b, $00
	ld a, [$c8a4]
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
	ld hl, far_Call_04_40A7
	rst $10

jr_009_6155:
	ld a, [$c905]
	rst $00

JumpTable_09_6159::
	dw Jump_09_6174
	dw Jump_09_617D
	dw Jump_09_626A
	dw Jump_09_62FC
	dw Jump_09_66B3
	dw Jump_09_66ED
	dw Jump_09_6702
	dw Jump_09_676B
	dw Jump_09_678F
	dw Jump_09_616F
	dw Jump_09_67DD

Jump_09_616F::
	ld hl, $c905
	inc [hl]
	ret


Jump_09_6174::
	ld hl, $c905
	inc [hl]
	ld a, [$c850]
	or a
	ret z

Jump_09_617D::
	ld hl, $ffb7
	call Call_09_403D
	ld hl, $ffbb
	call Call_09_403D
	ld hl, $c0c8
	ld bc, $0010
	ld a, $9f
	call Call_12C7
	call Call_09_621F
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
	ld hl, $01c0
	call Call_09_4059
	call Call_09_404A
	ld a, l
	ld [$c83e], a
	ld a, h
	ld [$c83f], a
	call Call_09_4236
	call Call_09_40FA
	ld de, $2e1e
	ld hl, $9000
	call Call_1577
	ld de, $2e1f
	ld hl, $8800
	call Call_1577
	ld de, $2e20
	ld hl, $8a00
	call Call_1577
	ld a, [$c8f4]
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
	call Call_1577
	call Call_09_442A
	call Call_09_625D
	ld hl, far_Call_17_41C0
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ld hl, $c905
	inc [hl]
	ret


Call_09_621F::
	ld b, $08
	ld a, [$c8f2]
	ld l, a
	ld a, [$c8f3]
	ld h, a
	ld de, $c0c8
	call Call_09_624D
	ld a, [$c8f4]
	cp $00
	ret z

	ld a, [$c0c8]
	cp $9f
	ret nz

	ld a, [$c8f5]
	ld l, a
	ld h, $07
	ld de, $c180
	call Call_097A
	ld hl, $c180
	ld de, $c0c8

Call_09_624D::
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
	jr nz, Call_09_624D

	ret


Call_09_625D::
	ld de, $c0c8
	ld hl, $9000
	call Call_09_4168
	call Call_09_6AC8
	ret


Jump_09_626A::
	ld hl, $c905
	inc [hl]
	call Call_09_4236
	call Call_09_627B
	call Call_09_6AC8
	call Call_09_40FA
	ret


Call_09_627B::
	ld a, [$c8f4]
	or a
	jr z, jr_009_62e0

	ld a, [$c8f6]
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
	ld hl, $8af0
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
	ld hl, $0064
	call Call_09_406D
	ld [hl], $af

jr_009_62e0:
	ld de, $7ca5
	call Call_09_40C9
	ld de, $7ccb
	ld a, [$c8dc]
	or a
	jr nz, jr_009_62f2

	ld de, $7dc9

jr_009_62f2:
	call Call_09_40C9
	call Call_09_442A
	call Call_09_69F6
	ret


Jump_09_62FC::
	ld a, [$c847]
	bit 5, a
	jr z, jr_009_6332

	ld a, [$c8db]
	cp $03
	jr c, jr_009_631e

	ld a, [$c8da]
	dec a
	ld [$c8da], a
	cp $11
	jp c, Jump_009_63f5

	ld a, $0d
	ld [$c8da], a
	jp Jump_009_63f5


jr_009_631e:
	ld a, [$c8da]
	dec a
	ld [$c8da], a
	cp $11
	jp c, Jump_009_63f5

	ld a, $10
	ld [$c8da], a
	jp Jump_009_63f5


jr_009_6332:
	ld a, [$c847]
	bit 4, a
	jr z, jr_009_634d

	ld a, [$c8da]
	inc a
	ld [$c8da], a
	cp $11
	jp c, Jump_009_63f5

	ld a, $00
	ld [$c8da], a
	jp Jump_009_63f5


jr_009_634d:
	ld a, [$c847]
	bit 6, a
	jr z, jr_009_639d

	ld a, [$c8da]
	cp $06
	jr c, jr_009_638b

	cp $0d
	jp nc, Jump_009_6374

	ld a, [$c8db]
	dec a
	ld [$c8db], a
	cp $05
	jp c, Jump_009_63f5

	ld a, $03
	ld [$c8db], a
	jp Jump_009_63f5


Jump_009_6374:
	ld a, [$c8db]
	dec a
	ld [$c8db], a
	cp $05
	jr c, jr_009_63f5

	ld a, $04
	ld [$c8db], a
	ld a, $0d
	ld [$c8da], a
	jr jr_009_63f5

jr_009_638b:
	ld a, [$c8db]
	dec a
	ld [$c8db], a
	cp $05
	jr c, jr_009_63f5

	ld a, $04
	ld [$c8db], a
	jr jr_009_63f5

jr_009_639d:
	ld a, [$c847]
	bit 7, a
	jp z, Jump_009_6460

	ld a, [$c8da]
	cp $06
	jr c, jr_009_63e3

	cp $0d
	jr nc, jr_009_63c2

	ld a, [$c8db]
	inc a
	ld [$c8db], a
	cp $04
	jr c, jr_009_63f5

	ld a, $00
	ld [$c8db], a
	jr jr_009_63f5

jr_009_63c2:
	ld a, [$c8db]
	cp $02
	jr c, jr_009_63e3

	ld a, [$c8da]
	ld a, $0d
	ld [$c8da], a
	ld a, [$c8db]
	inc a
	ld [$c8db], a
	cp $05
	jr c, jr_009_63f5

	ld a, $00
	ld [$c8db], a
	jr jr_009_63f5

jr_009_63e3:
	ld a, [$c8db]
	inc a
	ld [$c8db], a
	cp $05
	jr c, jr_009_63f5

	ld a, $00
	ld [$c8db], a
	jr jr_009_63f5

Jump_009_63f5:
jr_009_63f5:
	xor a
	ld [$c90c], a
	ld a, [$c8db]
	ld c, $11
	call Call_1DBE
	ld a, [$c8da]
	add l
	cp $4a
	jr nz, jr_009_641c

	ld a, $06
	ld [$c8da], a
	ld a, [$c847]
	bit 4, a
	jr z, jr_009_6460

	ld a, $0d
	ld [$c8da], a
	jr jr_009_6460

jr_009_641c:
	cp $50
	jr nz, jr_009_6433

	ld a, $0d
	ld [$c8da], a
	ld a, [$c847]
	bit 5, a
	jr z, jr_009_6460

	ld a, $05
	ld [$c8da], a
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
	ld [$c8da], a
	ld a, [$c847]
	bit 4, a
	jr z, jr_009_6460

	ld a, $00
	ld [$c8da], a
	jr jr_009_6460

Jump_009_6460:
jr_009_6460:
	call Call_09_69F6
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_64a9

Jump_009_646a:
	ld de, $c0c8
	ld a, [de]
	cp $9f
	jp z, Jump_009_6606

jr_009_6473:
	inc de
	ld a, [de]
	cp $9f
	jr nz, jr_009_6473

	dec de
	ld a, [$df0e]
	cp $00
	jp nz, Jump_009_64a0

	ld a, [$c8f4]
	cp $00
	jp nz, Jump_009_64a0

	ld a, $01
	ld [$df0e], a
	ld a, $9f
	ld [$c0c8], a
	ld [$c0c9], a
	ld [$c0ca], a
	ld [$c0cb], a
	jp Jump_009_64a3


Jump_009_64a0:
	ld a, $9f
	ld [de], a

Jump_009_64a3:
	call Call_09_625D
	jp Jump_009_6606


jr_009_64a9:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_65f3

	ld a, [$c8db]
	ld c, $11
	call Call_1DBE
	ld a, [$c8da]
	add l
	cp $51
	jr nz, jr_009_64c8

	ld hl, $c905
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
	call Call_09_6AAD
	pop hl
	ld a, c
	cp $04
	jr nz, jr_009_655a

	ld a, $0d
	ld [$c8da], a
	ld a, $04
	ld [$c8db], a
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
	ld de, $c0c8

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
	ld hl, $c0d2
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
	call Call_09_625D
	ld a, $59
	call Call_1B2C
	call Call_09_6AAD
	ld a, c
	ld hl, $c0d2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [$c8db]
	ld c, $11
	call Call_1DBE
	ld a, [$c8da]
	add l
	ld b, a
	ld a, $05
	call Call_1DFB
	ld a, b
	pop hl
	ld [hl], a
	call Call_09_6AAD
	ld a, c
	cp $04
	jr nz, jr_009_6606

	ld a, $0d
	ld [$c8da], a
	ld a, $04
	ld [$c8db], a
	jr jr_009_6606

Jump_009_65f3:
	ld a, [$c846]
	bit 3, a
	jr z, jr_009_6606

	ld a, $0d
	ld [$c8da], a
	ld a, $04
	ld [$c8db], a
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

Jump_09_66B3::
	xor a
	ld [$c90c], a
	call Call_09_69F6
	ld a, [$c0c8]
	cp $9f
	jr nz, jr_009_66ca

	call Call_09_688E
	call Call_09_68D9
	call Call_09_625D

jr_009_66ca:
	call Call_09_68EF
	jr c, jr_009_66d9

	ld hl, $c905
	inc [hl]
	ld hl, $c905
	inc [hl]
	jr jr_009_66ec

jr_009_66d9:
	ld hl, $020a
	call Call_096D
	ld de, $2e07
	call Call_09_40C9
	call Call_09_40FA
	ld hl, $c905
	inc [hl]

jr_009_66ec:
	ret


Jump_09_66ED::
	ld a, [$c825]
	or a
	ret nz

	call Call_09_625D
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	ret


Jump_09_6702::
	ld a, [$c8f4]
	cp $00
	jr z, jr_009_6728

	ld a, [$c8f5]
	ld l, a
	ld h, $05
	ld de, $c190
	call Call_097A
	ld hl, $c190

jr_009_6718:
	ld a, [hli]
	cp $f0
	jr nz, jr_009_6718

	dec hl
	ld a, [$c8f6]
	and $01
	add $a7
	ld [hli], a
	ld [hl], $f0

jr_009_6728:
	ld hl, $c180
	ld de, $c0c8
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
	ld [$df0e], a
	ld [hl], $f0
	ld hl, $0209
	ld a, [$c8f4]
	cp $00
	jr z, jr_009_6756

	call Call_09_692A
	ld hl, $0245
	jr c, jr_009_6756

	ld hl, $020f

jr_009_6756:
	call Call_096D
	ld de, $2e07
	call Call_09_40C9
	call Call_09_40FA
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c8de], a
	ret


Jump_09_676B::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld de, $6eb0
	call Call_09_40C9
	call Call_09_442A
	ld de, $67d7
	ld a, [$c8de]
	call Call_09_4530
	call Call_09_40FA
	ld hl, $c905
	inc [hl]
	ret


Jump_09_678F::
	ld de, $67d7
	ld hl, $c8de
	ld b, $02
	call Call_09_42F1
	ld a, [$c846]
	bit 1, a
	jr z, jr_009_67be

jr_009_67a1:
	call Call_09_625D
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	ld hl, $c905
	dec [hl]
	jr jr_009_67d6

jr_009_67be:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_009_67d6

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_009_67a1

	ld hl, $c905
	inc [hl]

Jump_009_67d6:
jr_009_67d6:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_09_67DD::
	ld a, [$c8f2]
	ld l, a
	ld a, [$c8f3]
	ld h, a
	ld bc, $0008
	ld a, $f0
	call Call_12C7
	ld a, [$c8f2]
	ld l, a
	ld a, [$c8f3]
	ld h, a
	ld de, $c0c8
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
	ld hl, $c8eb
	bit 7, [hl]
	jr nz, jr_009_6812

	ld a, [$c8ef]
	cp $ff
	jr z, jr_009_687a

jr_009_6812:
	call Call_09_4236
	call Call_09_40FA
	ld hl, far_Call_0B_4088
	rst $10
	ld hl, far_Call_0B_40CE
	rst $10
	call Call_2518
	call Call_25F1
	ld a, [$c969]
	or a
	jr nz, jr_009_6832

	ld hl, far_Call_06_4D5A
	rst $10
	jr jr_009_687a

jr_009_6832:
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

jr_009_687a:
	ld hl, $c8eb
	bit 7, [hl]
	jr nz, jr_009_6888

	res 4, [hl]
	xor a
	ld [$c905], a
	ret


jr_009_6888:
	ld hl, $c8eb
	res 7, [hl]
	ret


Call_09_688E::
	ld a, [$c8f4]
	cp $00
	jr nz, jr_009_68aa

	ld a, $d3
	ld [$c0c8], a
	ld a, $d4
	ld [$c0c9], a
	ld a, $d5
	ld [$c0ca], a
	ld a, $d6
	ld [$c0cb], a
	ret


jr_009_68aa:
	call Call_12D0
	ld a, [$c8f4]
	sub $10
	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld a, [$da33]
	ld c, a
	ld a, [$c899]
	and $07
	swap c
	or c
	ld c, a
	ld a, [$c8f6]
	and $01
	add a
	add a
	add a
	add c
	ld l, a
	ld h, $03
	ld de, $c0c8
	call Call_097A
	ret


Call_09_68D9::
	ld hl, $c0c8
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


Call_09_68EF::
	ld hl, $c0c8
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
	ld de, $c0c8
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


Call_09_692A::
	ld c, $00

jr_009_692c:
	ld a, c
	push bc
	ld hl, $cac1
	call Call_223B
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
	ld a, [$c8f2]
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

	ld de, $c0c8
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

Call_09_69F6::
	ld a, [$c8db]
	ld c, $11
	call Call_1DBE
	ld a, [$c8da]
	add l
	ld de, $6607
	ld c, a
	bit 7, a
	jr nz, jr_009_6a1a

	ld a, [$c90c]
	and $0f
	push af
	ld a, [$c90c]
	inc a
	ld [$c90c], a
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_09_4076
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

	ld a, [$c90c]
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

	call Call_09_6A96
	ld a, b
	cp $40
	jr z, jr_009_6a76

	cp $51
	jr z, jr_009_6a79

	jr jr_009_6a7f

jr_009_6a76:
	call Call_09_6A83

jr_009_6a79:
	call Call_09_6A83
	call Call_09_6A83

jr_009_6a7f:
	inc b
	jp Jump_009_6a1d


Call_09_6A83::
	push af
	ld hl, $ffd5
	inc [hl]
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	push de
	push bc
	call Call_09_4076
	pop bc
	pop de
	pop af

Call_09_6A96::
	ldh a, [$ffd7]
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


Call_09_6AAD::
	ld hl, $c0c8
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

Call_09_6AC8::
	call Call_09_6AAD
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
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call Call_09_4076
	pop bc
	pop de
	ld a, c
	cp b
	ld a, $e0
	jr nz, jr_009_6aef

	ld a, $a0

jr_009_6aef:
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
