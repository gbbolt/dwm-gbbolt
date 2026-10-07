INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $05f", ROMX[$4000], BANK[$5f]

BankNumber_5F::
	db $5f

FarTable_5F::
	dw Call_5F_4017
	dw Call_5F_40F7
	dw Call_5F_441C
	dw $4619
	dw Call_5F_4A60
	dw Call_5F_4B1B
	dw Call_5F_52F0
	dw Call_5F_5630
	dw Call_5F_5BB7
	dw Call_5F_5C8D
	dw Call_5F_6251

Call_5F_4017::
	call Call_1264
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld hl, $9800
	ld bc, $0400
	ld a, $e0
	call Call_12C7
	ld a, [$c88b]
	rst $00

JumpTable_5F_4035::
	dw Jump_5F_4039
	dw Jump_5F_4095

Jump_5F_4039::
	ld hl, $8000
	ld bc, $0c00
	call Call_5F_40EB
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld de, $66b3
	ld hl, $9800
	ld bc, Call_1412
	call Call_5F_424A
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	call Call_5F_439D
	call Call_5F_43BA
	ld a, $fc
	call Call_1688
	ld a, $21
	call Call_1AE1
	xor a
	ldh [$ffb7], a
	xor a
	ldh [$ffbb], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	xor a
	ld [$c892], a
	ld a, $11
	ld [$c8a1], a
	ld a, $01
	jp Jump_000_11cb


Jump_5F_4095::
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld hl, $8800
	ld bc, $0800
	call Call_5F_40EB
	ld de, $42cf
	ld hl, $99a0
	ld bc, $1404
	call Call_5F_424A
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	ld a, $fc
	call Call_1688
	ld a, $31
	call Call_1AE1
	xor a
	ldh [$ffb7], a
	xor a
	ldh [$ffbb], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	xor a
	ld [$c892], a
	ld a, $01
	ld [$c8a1], a
	ld a, $01
	jp Jump_000_11cb


Call_5F_40EB::
	ld [hl], $ff
	inc hl
	ld [hl], $00
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, Call_5F_40EB

	ret


Call_5F_40F7::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c88b]
	rst $00

JumpTable_5F_4100::
	dw Jump_5F_4104
	dw Jump_5F_4112

Jump_5F_4104::
	ld a, [$c0d8]
	rst $00

JumpTable_5F_4108::
	dw Jump_5F_4120
	dw Jump_5F_4140
	dw Jump_5F_4155
	dw Jump_5F_4163
	dw Jump_5F_4178

Jump_5F_4112::
	ld a, [$c0d8]
	rst $00

JumpTable_5F_4116::
	dw Jump_5F_41DA
	dw Jump_5F_41ED
	dw Jump_5F_41F6
	dw Jump_5F_4210
	dw Jump_5F_4244

Jump_5F_4120::
	ld hl, $c0da
	inc [hl]
	ld a, [hl]
	cp $3c
	ret c

	ld a, $00
	ld [hli], a
	inc [hl]
	ld a, [hl]
	cp $05
	ret c

	ld [hl], $00
	ld hl, $c0d8
	inc [hl]
	ld hl, $c88f
	inc [hl]
	ld a, $04
	call Call_1688
	ret


Jump_5F_4140::
	ld hl, $c0d9
	inc [hl]
	ld a, [hl]
	cp $1a
	call z, Call_5F_440F
	call Call_5F_439D
	call Call_5F_43BA
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_4155::
	ld hl, far_Call_08_422C
	rst $10
	ld a, $fc
	call Call_1688
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_4163::
	xor a
	ld [$c88f], a
	ld a, [$c0d9]
	cp $1a
	jr z, jr_05f_4173

	xor a
	ld [$c0d8], a
	ret


jr_05f_4173:
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_4178::
	ld hl, $c0da
	inc [hl]
	ld a, [hl]
	cp $3c
	ret c

	ld a, $00
	ld [hli], a
	inc [hl]
	ld a, [hl]
	cp $05
	ret c

	ld [hl], $00
	ld hl, $002f
	ld a, l
	ld [$c96d], a
	ld a, h
	ld [$c96e], a
	ld hl, $0038
	ld a, l
	ld [$c96f], a
	ld a, h
	ld [$c970], a
	ld hl, $00c8
	ld a, l
	ld [$c971], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	xor a
	ldh [$ff90], a
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	ld a, $01
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c88e
	inc [hl]
	ld a, $04
	call Call_1688
	ret


Jump_5F_41DA::
	ld a, $07
	ld [$c822], a
	ld a, $00
	ld [$c823], a
	ld hl, Jump_5F_4C02
	rst $10
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_41ED::
	xor a
	ld [$c88f], a
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_41F6::
	ld a, [$c846]
	and $0f
	ret z

	ld hl, $0256
	call Call_096D
	ld de, $2e07
	ld hl, $9800
	call Call_5F_4298
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_4210::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c83c]
	or a
	ld hl, $0258
	jr nz, jr_05f_423c

	xor a
	ldh [$ff90], a
	xor a
	ld [$d8d7], a
	ld a, $01
	ld [$c8ea], a
	ld hl, $c8eb
	res 0, [hl]
	di
	call Call_2128
	ei
	ld a, $59
	call Call_1B2C
	ld hl, $0257

jr_05f_423c:
	call Call_096D
	ld hl, $c0d8
	inc [hl]
	ret


Jump_5F_4244::
	ld a, [$c825]
	or a
	ret nz

	ret


Call_5F_424A::
	push bc
	push hl

jr_05f_424c:
	ld a, [de]
	call Call_1AAD
	inc hl
	inc de
	dec b
	jr nz, jr_05f_424c

	pop hl
	pop bc
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec c
	jr nz, Call_5F_424A

	ret


Call_5F_4263::
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	add hl, bc
	ld a, l
	ld [$c0fe], a
	ld a, h
	ld [$c0ff], a

jr_05f_4272:
	ld a, [de]
	inc de
	cp $d8
	jr z, jr_05f_427e

	cp $d9
	ret z

	ld [hli], a
	jr jr_05f_4272

jr_05f_427e:
	ld a, [$c0fe]
	ld l, a
	ld a, [$c0ff]
	ld h, a
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [$c0fe], a
	ld a, h
	ld [$c0ff], a
	jr jr_05f_4272

Call_5F_4298::
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	add hl, bc
	ld a, l
	ld [$c0fe], a
	ld a, h
	ld [$c0ff], a

jr_05f_42a7:
	ld a, [de]
	inc de
	cp $d8
	jr z, jr_05f_42b5

	cp $d9
	ret z

	call Call_1AB9
	jr jr_05f_42a7

jr_05f_42b5:
	ld a, [$c0fe]
	ld l, a
	ld a, [$c0ff]
	ld h, a
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [$c0fe], a
	ld a, h
	ld [$c0ff], a
	jr jr_05f_42a7

	db $e0, $e0, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $e0, $e0, $fe, $b0, $b1, $b2, $e0, $b3, $b4, $e0, $b5, $b6
	db $b7, $b8, $b9, $ba, $bb, $bc, $bd, $ff, $e0, $e0, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $e0, $e0, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd

Call_5F_431F::
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
	ld hl, $8000
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld de, $1402
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld hl, Jump_5F_4C02
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c828], a
	ld a, d
	ld [$c829], a
	ret


Call_5F_435E::
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
	ld hl, $8260
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld de, $0b0c
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld hl, Jump_5F_4C02
	rst $10
	pop de
	pop hl
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c828], a
	ld a, d
	ld [$c829], a
	ret


Call_5F_439D::
	ld a, [$c0d9]
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	call Call_5F_431F
	ld a, [$c0d9]
	ld [$c823], a
	ld a, $06
	ld [$c822], a
	call Call_5F_435E
	ret


Call_5F_43BA::
	ld a, [$c0d9]
	ld hl, $43f4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	ld [$c0de], a
	ld [$c81e], a
	ld a, $04
	ld [$c81f], a
	ld hl, $016d
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld hl, $8aa0
	ld a, l
	ld [$c0dc], a
	ld a, h
	ld [$c0dd], a
	ld hl, far_Call_51_5569
	rst $10
	ld hl, far_Call_17_41D0
	rst $10
	ret


	db $6d, $13, $59, $49, $42, $0a, $a4, $1b, $81, $84, $c7, $95, $96, $97, $44, $7f
	db $c2, $91, $9a, $2c, $6d, $13, $59, $49, $42, $0a, $08

Call_5F_440F::
	ld de, $681b
	ld hl, $9800
	ld bc, Call_140B
	call Call_5F_424A
	ret


Call_5F_441C::
	ld a, [$c88c]
	rst $00

JumpTable_5F_4420::
	dw Jump_5F_442E
	dw Jump_5F_4520
	dw Jump_5F_4520
	dw Jump_5F_4520
	dw Jump_5F_4572
	dw Jump_5F_4520
	dw Jump_5F_45C0

Jump_5F_442E::
	ld a, [$c88d]
	rst $00

JumpTable_5F_4432::
	dw Jump_5F_4439
	dw Jump_5F_4486
	dw Jump_5F_44D3
	db $c9

Jump_5F_4439::
	ld a, $02
	call Call_1C89
	call Call_1013
	xor a
	ld hl, $9800
	ld bc, $0400
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld de, $560e
	ld hl, $9000
	call Call_14CF
	ld de, $669d
	ld hl, $9800
	call Call_5F_4263
	ld a, $00
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	ret


Jump_5F_4486::
	ld a, $02
	call Call_1C89
	call Call_1013
	xor a
	ld hl, $9800
	ld bc, $0400
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld de, $560c
	ld hl, $9000
	call Call_14CF
	ld de, $666e
	ld hl, $9800
	call Call_5F_4263
	ld a, $00
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	ret


Jump_5F_44D3::
	ld a, $02
	call Call_1C89
	call Call_1013
	xor a
	ld hl, $9800
	ld bc, $0400
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld de, $5b1f
	ld hl, $9000
	call Call_14CF
	ld de, $6457
	ld hl, $9800
	call Call_5F_4263
	ld a, $00
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	ret


Jump_5F_4520::
	xor a
	ld hl, $9800
	ld bc, $0400
	call Call_12C7
	ld a, $ff
	ld hl, $9000
	ld bc, $0010
	call Call_12C7
	ld de, $5b18
	ld hl, $8000
	call Call_1577
	ld de, $5b19
	ld hl, $8040
	call Call_1577
	ld a, $00
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld a, $00
	ld [$c81e], a
	ld hl, $170c
	rst $10
	ld a, $01
	ldh [rVBK], a
	xor a
	ld hl, $9800
	ld bc, $0400
	ld a, [$c81d]
	or a
	ld a, $00
	call nz, Call_12C7
	ld a, $00
	ldh [rVBK], a
	ret


Jump_5F_4572::
	xor a
	ld hl, $9800
	ld bc, $0400
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld de, $5b20
	ld hl, $9000
	call Call_14CF
	ld de, $5b21
	ld hl, $8800
	call Call_14CF
	ld de, $64f1
	ld hl, $9800
	call Call_5F_4263
	ld a, $01
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f02
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	ret


Jump_5F_45C0::
	xor a
	ld hl, $9800
	ld bc, $0400
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld de, $5b20
	ld hl, $9000
	call Call_1577
	ld de, $5b21
	ld hl, $8800
	call Call_1577
	ld de, $6583
	ld hl, $9800
	call Call_5F_4263
	ld a, $06
	call Call_1AE1
	ld a, $01
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	jr nz, jr_05f_460c

	jr jr_05f_4614

jr_05f_460c:
	ld a, $05
	ld [hli], a
	ld a, h
	cp $9b
	jr nz, jr_05f_460c

jr_05f_4614:
	ld a, $00
	ldh [rVBK], a
	ret


	ld a, $f4
	call Call_1275
	ld a, [$c846]
	bit 0, a
	jr nz, jr_05f_463f

	bit 1, a
	jr nz, jr_05f_463f

	bit 3, a
	jr nz, jr_05f_463f

	ld a, [$c88c]
	rst $00

JumpTable_5F_4631::
	dw Jump_5F_46A6
	dw Jump_5F_471A
	dw Jump_5F_47B0
	dw Jump_5F_4841
	dw Jump_5F_48D5
	dw Jump_5F_4908
	dw Jump_5F_49B3

jr_05f_463f:
	ld a, [$c88c]
	cp $06
	jr nc, jr_05f_4663

	cp $00
	jr z, jr_05f_467c

Jump_05f_464a:
	ld a, $04
	call Call_1688
	ld a, $00
	ld [$c88b], a
	ld a, $06
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c88e
	inc [hl]
	ret


jr_05f_4663:
	ld a, $04
	call Call_1688
	ld a, $01
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c88e
	inc [hl]
	ret


jr_05f_467c:
	ld a, [$c88d]
	cp $00
	jp nz, Jump_05f_4685

	ret


Jump_05f_4685:
	ld a, [$c88d]
	cp $01
	jp nz, Jump_05f_464a

	ld a, $04
	call Call_1688
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $02
	ld [$c88d], a
	ld hl, $c88e
	inc [hl]
	ret


Jump_5F_46A6::
	ld a, [$c88d]
	rst $00

JumpTable_5F_46AA::
	dw Jump_5F_46B1
	dw Jump_5F_46D2
	dw Jump_5F_46F3
	db $c9

Jump_5F_46B1::
	ld a, [$c850]
	or a
	ret nz

	ld hl, $c0d8
	inc [hl]
	ld a, [$c0d8]
	cp $3c
	ret nz

	ld a, $04
	call Call_1688
	xor a
	ld [$c0d8], a
	ld hl, $c88d
	inc [hl]
	ld hl, $c88e
	inc [hl]
	ret


Jump_5F_46D2::
	ld a, [$c850]
	or a
	ret nz

	ld hl, $c0d8
	inc [hl]
	ld a, [$c0d8]
	cp $b4
	ret nz

	ld a, $04
	call Call_1688
	xor a
	ld [$c0d8], a
	ld hl, $c88d
	inc [hl]
	ld hl, $c88e
	inc [hl]
	ret


Jump_5F_46F3::
	ld a, [$c850]
	or a
	ret nz

	ld hl, $c0d8
	inc [hl]
	ld a, [$c0d8]
	cp $b4
	ret nz

	ld a, $04
	call Call_1688
	xor a
	ld [$c0d8], a
	ld hl, $c88c
	inc [hl]
	ld hl, $c88e
	inc [hl]
	ld hl, $c0dc
	call Call_5F_49CC
	ret


Jump_5F_471A::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c0d8]
	or a
	jr nz, jr_05f_472a

	ld a, $5d
	call Call_1B2C

jr_05f_472a:
	ld a, $01
	ld [$c0d8], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_4777

	ld a, $00
	ldh [$ffc7], a
	ld a, $00
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0dc
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $40
	jr z, jr_05f_4772

	cp $e0
	jr nz, jr_05f_4777

	ld a, $01
	ld [$c0dc], a
	jr jr_05f_4777

jr_05f_4772:
	ld a, $00
	ld [$c0e2], a

jr_05f_4777:
	ld a, [$c0e2]
	or a
	ret nz

	ld a, $01
	ldh [$ffc7], a
	ld a, $04
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0e2
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	xor a
	ld [$c0d8], a
	ld hl, $c88c
	inc [hl]
	ld hl, $c0dc
	call Call_5F_49F1
	ret


Jump_5F_47B0::
	ld a, [$c0d8]
	or a
	jr nz, jr_05f_47bb

	ld a, $5d
	call Call_1B2C

jr_05f_47bb:
	ld a, $01
	ld [$c0d8], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_4808

	ld a, $00
	ldh [$ffc7], a
	ld a, $00
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0dc
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $10
	jr z, jr_05f_4803

	cp $e0
	jr nz, jr_05f_4808

	ld a, $01
	ld [$c0dc], a
	jr jr_05f_4808

jr_05f_4803:
	ld a, $00
	ld [$c0e2], a

jr_05f_4808:
	ld a, [$c0e2]
	or a
	ret nz

	ld a, $01
	ldh [$ffc7], a
	ld a, $04
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0e2
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	xor a
	ld [$c0d8], a
	ld hl, $c88c
	inc [hl]
	ld hl, $c0dc
	call Call_5F_4A16
	ret


Jump_5F_4841::
	ld a, [$c0d8]
	or a
	jr nz, jr_05f_484c

	ld a, $5d
	call Call_1B2C

jr_05f_484c:
	ld a, $01
	ld [$c0d8], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_4899

	ld a, $00
	ldh [$ffc7], a
	ld a, $00
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0dc
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $70
	jr z, jr_05f_4894

	cp $20
	jr nz, jr_05f_4899

	ld a, $01
	ld [$c0dc], a
	jr jr_05f_4899

jr_05f_4894:
	ld a, $00
	ld [$c0e2], a

jr_05f_4899:
	ld a, [$c0e2]
	or a
	ret nz

	ld a, $01
	ldh [$ffc7], a
	ld a, $04
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0e2
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	ld a, $04
	call Call_1688
	xor a
	ld [$c0d8], a
	ld hl, $c88c
	inc [hl]
	ld hl, $c88e
	inc [hl]
	ret


Jump_5F_48D5::
	ld a, [$c850]
	or a
	ret nz

	ld hl, $c0d8
	inc [hl]
	ld a, [$c0d8]
	cp $78
	ret nz

	ld a, $04
	call Call_1688
	xor a
	ld [$c0d8], a
	ld hl, $c88c
	inc [hl]
	ld hl, $c88e
	inc [hl]
	xor a
	ld [$c0e8], a
	xor a
	ld [$c0e9], a
	xor a
	ld [$c0ea], a
	ld hl, $c0dc
	call Call_5F_4A3B
	ret


Jump_5F_4908::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c0d8]
	or a
	jr nz, jr_05f_4918

	ld a, $5d
	call Call_1B2C

jr_05f_4918:
	ld a, $01
	ld [$c0d8], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_495a

	ld a, $00
	ldh [$ffc7], a
	ld a, $00
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0dc
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $36
	jr nz, jr_05f_495a

	ld a, $01
	ld [$c0dc], a

jr_05f_495a:
	ld a, [$c0e2]
	or a
	jr nz, jr_05f_4997

	ld a, $00
	ldh [$ffc7], a
	ld a, $00
	ldh [$ffc9], a
	ld a, $00
	ldh [$ffca], a
	ld hl, $c0e2
	ld a, l
	ld [$c0fc], a
	ld a, h
	ld [$c0fd], a
	ld hl, $0204
	rst $10
	ld hl, $c0e3
	dec [hl]
	ld hl, $c0e3
	dec [hl]
	ld hl, $c0e4
	inc [hl]
	ld hl, $c0e4
	inc [hl]
	ld a, [$c0e3]
	cp $59
	jr nz, jr_05f_4997

	ld a, $01
	ld [$c0e2], a

jr_05f_4997:
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	ld a, $04
	call Call_1688
	xor a
	ld [$c0d8], a
	ld hl, $c88c
	inc [hl]
	ld hl, $c88e
	inc [hl]
	ret


Jump_5F_49B3::
	ld a, [$ddb4]
	ld hl, $ddce
	and [hl]
	ld hl, $dde8
	and [hl]
	ld hl, $de02
	and [hl]
	cp $ff
	ret nz

	ld a, $06
	di
	call Call_1AE1
	ret


Call_5F_49CC::
	ld a, $00
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $30
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


Call_5F_49F1::
	ld a, $00
	ld [hli], a
	ld a, $40
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $20
	ld [hli], a
	ld a, $20
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


Call_5F_4A16::
	ld a, $00
	ld [hli], a
	ld a, $a0
	ld [hli], a
	ld a, $30
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


Call_5F_4A3B::
	ld a, $00
	ld [hli], a
	ld a, $86
	ld [hli], a
	ld a, $fe
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $a9
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


Call_5F_4A60::
	ld a, [$db8a]
	cp $12
	jp c, Jump_05f_4ae8

	cp $39
	jr z, jr_05f_4ae8

	cp $37
	ret c

	cp $41
	jr c, jr_05f_4ae8

	cp $42
	ret c

	cp $43
	jr c, jr_05f_4ae8

	cp $44
	ret c

	cp $54
	jr c, jr_05f_4ae8

	cp $55
	ret c

	cp $6a
	jr c, jr_05f_4ae8

	cp $73
	ret c

	cp $75
	jr c, jr_05f_4ae8

	cp $7d
	ret c

	cp $7f
	jr c, jr_05f_4ae8

	cp $81
	ret c

	cp $84
	jr c, jr_05f_4ae8

	cp $88
	jr c, jr_05f_4b0b

	cp $99
	ret c

	cp $9c
	jr c, jr_05f_4ae8

	cp $a5
	ret c

	cp $a6
	jr c, jr_05f_4ae8

	cp $ab
	ret c

	cp $ac
	jr c, jr_05f_4ae8

	cp $af
	ret c

	cp $b0
	jr c, jr_05f_4ae8

	cp $c7
	ret c

	cp $c9
	jr c, jr_05f_4ae8

	cp $ca
	ret c

	cp $cc
	jr c, jr_05f_4ae8

	cp $d4
	ret c

	cp $d5
	jr c, jr_05f_4ae8

	cp $d6
	ret c

	cp $da
	jr c, jr_05f_4ae8

	cp $dd
	ret c

	cp $de
	jr c, jr_05f_4ae8

	cp $df
	ret c

	cp $e0
	jr c, jr_05f_4ae8

	ret


Jump_05f_4ae8:
jr_05f_4ae8:
	xor a
	ld hl, $da82
	ld bc, $0006
	call Call_12C7
	ld b, $03
	ld a, [$c863]
	bit 1, a
	jr z, jr_05f_4afd

	ld b, $02

jr_05f_4afd:
	ld a, [$db89]
	cp $04
	ld a, b
	jr c, jr_05f_4b07

	xor $01

jr_05f_4b07:
	ld [$da83], a
	ret


jr_05f_4b0b:
	xor a
	ld hl, $da82
	ld bc, $0006
	call Call_12C7
	ld a, $04
	ld [$da83], a
	ret


Call_5F_4B1B::
	ld a, [$da34]
	inc a
	cp $05
	ld [$da34], a
	ret c

	xor a
	ld [$da34], a
	ld a, [$da82]
	or a
	ret nz

	ld a, [$db54]
	cp $80
	jr nz, jr_05f_4b40

	ld a, $6c
	call Call_1B2C
	ld a, $ff
	ld [$db54], a
	ret


jr_05f_4b40:
	ld a, [$da83]
	rst $00

JumpTable_5F_4B44::
	dw Jump_5F_4B60
	dw Jump_5F_4B60
	dw Jump_5F_4B6A
	dw Jump_5F_4C02
	dw Jump_5F_4C4A
	dw Jump_5F_4C89
	dw Jump_5F_4CD8
	dw Jump_5F_4D14
	dw Jump_5F_4D69
	dw Jump_5F_4D86
	dw Jump_5F_4DA9
	dw Jump_5F_4DF8
	dw Jump_5F_51A1
	dw Jump_5F_5246

Jump_5F_4B60::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4B6A::
	ld a, [$c863]
	ld b, a
	ld a, [$db89]
	and $03
	cp $03
	jr z, Jump_5F_4BF4

	ld a, [$db89]
	bit 1, b
	jr nz, jr_05f_4b84

	cp $04
	jr c, Jump_5F_4BF4

	jr jr_05f_4b88

jr_05f_4b84:
	cp $04
	jr nc, Jump_5F_4BF4

jr_05f_4b88:
	ld a, [$d9ed]
	cp $0a
	jr z, jr_05f_4b97

	ld a, [$db89]
	call Call_2FA5
	jr c, Jump_5F_4BF4

jr_05f_4b97:
	ld a, [$da84]
	rst $00

JumpTable_5F_4B9B::
	dw Jump_5F_4BA5
	dw Jump_5F_4BCB
	dw Jump_5F_4BA5
	dw Jump_5F_4BCB
	dw Jump_5F_4BF4

Jump_5F_4BA5::
	ld a, $06
	ld [$da85], a
	call Call_5F_4E3C
	ld hl, $50ff
	call Call_5F_50F4
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, $03
	ld hl, $5109
	call Call_5F_50F4
	ld c, $06
	call Call_5F_4E1F
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4BCB::
	ld a, $06
	ld [$da85], a
	call Call_5F_4E3C
	ld hl, $50ff
	call Call_5F_50F4
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, [$db89]
	and $03
	ld hl, $5109
	call Call_5F_50F4
	ld c, $06
	call Call_5F_4E1F
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4BF4::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	xor a
	ld [$da85], a
	ret


Jump_5F_4C02::
	ld a, [$db8a]
	cp $81
	jr z, Jump_5F_4C3A

	ld a, [$da84]
	rst $00

JumpTable_5F_4C0D::
	dw Jump_5F_4C15
	dw Jump_5F_4C2F
	dw Jump_5F_4C15
	dw Jump_5F_4C3A

Jump_5F_4C15::
	ld a, $02
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


	db $3e, $00, $e0, $bb, $3e, $01, $e0, $b7, $21, $84, $da, $34, $c9

Jump_5F_4C2F::
	xor a
	ldh [$ffbb], a
	xor a
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4C3A::
	ld a, $01
	ld [$da82], a
	xor a
	ldh [$ffbb], a
	xor a
	ldh [$ffb7], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4C4A::
	ld a, [$da84]
	rst $00

JumpTable_5F_4C4E::
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C7C

Jump_5F_4C5C::
	ld hl, $c89b
	ld [hl], $00
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, $da84
	inc [hl]
	ret


Call_5F_4C6C::
	ld hl, $c89b
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4C7C::
	call Call_5F_4C6C
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4C89::
	ld a, [$da84]
	rst $00

JumpTable_5F_4C8D::
	dw Jump_5F_4C95
	dw Jump_5F_4CAB
	dw Jump_5F_4CBE
	dw Jump_5F_4CCE

Jump_5F_4C95::
	call Call_5F_506E
	ld a, [$da87]
	cp $04
	ret c

	xor a
	ld [$da86], a
	xor a
	ld [$da87], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4CAB::
	ld hl, $da85
	inc [hl]
	ld a, [$da85]
	cp $0a
	ret nz

	ld hl, $da84
	inc [hl]
	xor a
	ld [$da85], a
	ret


Jump_5F_4CBE::
	ld hl, $c89b
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4CCE::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4CD8::
	ld a, [$da84]
	rst $00

JumpTable_5F_4CDC::
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4CF6
	dw Jump_5F_4D0A

Jump_5F_4CF6::
	ld hl, $c89b
	ld a, [hl]
	xor $ff
	ld [hli], a
	ld a, [hl]
	xor $ff
	ld [hli], a
	ld a, [hl]
	xor $ff
	ld [hl], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4D0A::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4D14::
	ld a, [$da84]
	rst $00

JumpTable_5F_4D18::
	dw Jump_5F_4D26
	dw Jump_5F_4D3C
	dw Jump_5F_4D4F
	dw Jump_5F_4D26
	dw Jump_5F_4D3C
	dw Jump_5F_4D4F
	dw Jump_5F_4D5F

Jump_5F_4D26::
	call Call_5F_506E
	ld a, [$da87]
	cp $04
	ret c

	xor a
	ld [$da86], a
	xor a
	ld [$da87], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4D3C::
	ld hl, $da85
	inc [hl]
	ld a, [$da85]
	cp $05
	ret nz

	ld hl, $da84
	inc [hl]
	xor a
	ld [$da85], a
	ret


Jump_5F_4D4F::
	ld hl, $c89b
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4D5F::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4D69::
	ld a, [$da84]
	or a
	call z, Call_5F_4ED5
	call Call_5F_4F49
	ld a, [$da84]
	or a
	ret z

	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	xor a
	ld [$da85], a
	ret


Jump_5F_4D86::
	ld a, [$da87]
	or a
	jr nz, jr_05f_4da1

	ld hl, $da87
	inc [hl]
	xor a
	ld [$c905], a
	xor a
	ld [$c906], a
	xor a
	ld [$c907], a
	xor a
	ld [$c908], a
	ret


jr_05f_4da1:
	call Call_5F_4F9B
	ld hl, $da87
	inc [hl]
	ret


Jump_5F_4DA9::
	ld a, [$da84]
	rst $00

JumpTable_5F_4DAD::
	dw Jump_5F_4DB5
	dw Jump_5F_4DCB
	dw Jump_5F_4DDE
	dw Jump_5F_4DEE

Jump_5F_4DB5::
	call Call_5F_50B5
	ld a, [$da87]
	cp $04
	ret c

	xor a
	ld [$da86], a
	xor a
	ld [$da87], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4DCB::
	ld hl, $da85
	inc [hl]
	ld a, [$da85]
	cp $0a
	ret nz

	ld hl, $da84
	inc [hl]
	xor a
	ld [$da85], a
	ret


Jump_5F_4DDE::
	ld hl, $c89b
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_4DEE::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_4DF8::
	ld a, [$da84]
	rst $00

JumpTable_5F_4DFC::
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C5C
	dw Call_5F_4C6C
	dw Jump_5F_4C7C
	db $c9

Call_5F_4E1F::
	push de
	ld a, [$da85]
	ld b, a

jr_05f_4e24:
	di
	call Call_1AA6
	ld a, [hli]
	ld [de], a
	ei
	inc de
	dec b
	jr nz, jr_05f_4e24

	pop de
	dec c
	ret z

	ld a, $20
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	jr Call_5F_4E1F

Call_5F_4E3C::
	ld a, [$c86c]
	or a
	jr z, jr_05f_4e4e

	ld a, [$c863]
	bit 1, a
	jr z, jr_05f_4e4e

	ld a, [$db74]
	jr jr_05f_4e51

jr_05f_4e4e:
	ld a, [$db75]

jr_05f_4e51:
	cp $01
	jr z, jr_05f_4e7d

	cp $02
	jr z, jr_05f_4e6c

	ld a, [$db89]
	and $03
	cp $01
	jr z, jr_05f_4e7d

	jr c, jr_05f_4e68

	ld a, $04
	jr jr_05f_4e7f

jr_05f_4e68:
	ld a, $03
	jr jr_05f_4e7f

jr_05f_4e6c:
	ld a, [$db89]
	and $03
	cp $01
	jr z, jr_05f_4e79

	ld a, $01
	jr jr_05f_4e7f

jr_05f_4e79:
	ld a, $02
	jr jr_05f_4e7f

jr_05f_4e7d:
	ld a, $00

jr_05f_4e7f:
	ret


Call_5F_4E80::
	ld a, [$c86c]
	or a
	jr z, jr_05f_4ea3

	call Call_5F_52D6
	jr nz, jr_05f_4e97

	ld a, [$c863]
	bit 1, a
	jr z, jr_05f_4ea3

	ld a, [$db74]
	jr jr_05f_4ea6

jr_05f_4e97:
	ld a, [$c863]
	bit 1, a
	jr nz, jr_05f_4ea3

	ld a, [$db74]
	jr jr_05f_4ea6

jr_05f_4ea3:
	ld a, [$db75]

jr_05f_4ea6:
	cp $01
	jr z, jr_05f_4ed2

	cp $02
	jr z, jr_05f_4ec1

	ld a, [$db88]
	and $03
	cp $01
	jr z, jr_05f_4ed2

	jr c, jr_05f_4ebd

	ld a, $04
	jr jr_05f_4ed4

jr_05f_4ebd:
	ld a, $03
	jr jr_05f_4ed4

jr_05f_4ec1:
	ld a, [$db88]
	and $03
	cp $01
	jr z, jr_05f_4ece

	ld a, $01
	jr jr_05f_4ed4

jr_05f_4ece:
	ld a, $02
	jr jr_05f_4ed4

jr_05f_4ed2:
	ld a, $00

jr_05f_4ed4:
	ret


Call_5F_4ED5::
	ld a, [$da84]
	or a
	ret nz

	ld a, [$da85]
	rst $00

JumpTable_5F_4EDE::
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F2E
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F2E
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F2E
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F2E
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F2E
	dw Jump_5F_4F14
	dw Jump_5F_4F2E
	dw Jump_5F_4F21
	dw Jump_5F_4F39

Jump_5F_4F14::
	ld a, $04
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffb7], a
	ld hl, $da85
	inc [hl]
	ret


Jump_5F_4F21::
	ld a, $00
	ldh [$ffbb], a
	ld a, $03
	ldh [$ffb7], a
	ld hl, $da85
	inc [hl]
	ret


Jump_5F_4F2E::
	xor a
	ldh [$ffbb], a
	xor a
	ldh [$ffb7], a
	ld hl, $da85
	inc [hl]
	ret


Jump_5F_4F39::
	ld a, $01
	ld [$da84], a
	xor a
	ldh [$ffbb], a
	xor a
	ldh [$ffb7], a
	xor a
	ld [$da85], a
	ret


Call_5F_4F49::
	ld a, [$da85]
	rst $00

JumpTable_5F_4F4D::
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F
	dw Jump_5F_4F83
	dw Jump_5F_4F8F

Jump_5F_4F83::
	ld hl, $c89b
	ld [hl], $00
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], $00
	ret


Jump_5F_4F8F::
	ld hl, $c89b
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ret


Call_5F_4F9B::
	ld a, [$c905]
	rst $00

JumpTable_5F_4F9F::
	dw Jump_5F_4FA7
	dw Jump_5F_4FC5
	dw Jump_5F_5035
	dw Jump_5F_504F

Jump_5F_4FA7::
	ld hl, $c905
	inc [hl]
	ld hl, $c100
	ld b, $80

jr_05f_4fb0:
	ldh a, [$ffb7]
	ld [hli], a
	dec b
	jr nz, jr_05f_4fb0

	ld a, $01
	ld [$c907], a
	ld a, $02
	ldh [rLYC], a
	ld a, $02
	ld [$c892], a
	ret


Jump_5F_4FC5::
	ld a, [$da87]
	and $07
	jr nz, Call_5F_4FE8

	ld a, [$c907]
	swap a
	and $0f
	inc a
	ld b, a
	ld a, [$c907]
	add b
	ld [$c907], a
	cp $1c
	jr c, Call_5F_4FE8

	ld hl, $c905
	inc [hl]
	xor a
	ld [$c908], a

Call_5F_4FE8::
	ld a, [$c907]
	ldh [$ffd5], a
	ld a, [$da87]
	rra
	rra
	and $0f
	ld e, a
	ld d, $00
	ld bc, $c12e
	ld a, $66
	ldh [$ffd6], a

jr_05f_4ffe:
	inc e
	ld a, e
	and $0f
	ld e, a
	ld hl, $5025
	add hl, de
	push bc
	ld c, [hl]
	ldh a, [$ffd5]
	call Call_1DBE
	pop bc
	bit 3, e
	jr z, jr_05f_5018

	ldh a, [$ffb7]
	sub h
	jr jr_05f_501b

jr_05f_5018:
	ldh a, [$ffb7]
	add h

jr_05f_501b:
	ld [bc], a
	inc c
	ld [bc], a
	inc c
	ldh a, [$ffd6]
	cp c
	jr nz, jr_05f_4ffe

	ret


	db $00, $30, $5b, $76, $7f, $76, $5b, $30, $00, $30, $5b, $76, $7f, $76, $5b, $30

Jump_5F_5035::
	ld a, [$da87]
	and $0f
	jr nz, jr_05f_504b

	ld a, [$c908]
	inc a
	ld [$c908], a
	cp $04
	jr nz, jr_05f_504b

	ld hl, $c905
	inc [hl]

jr_05f_504b:
	call Call_5F_4FE8
	ret


Jump_5F_504F::
	ld a, $00
	ld [$c892], a
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da87], a
	xor a
	ld [$c905], a
	xor a
	ld [$c906], a
	xor a
	ld [$c907], a
	xor a
	ld [$c908], a
	ret


Call_5F_506E::
	xor a
	ld [$da86], a
	ld hl, $da87
	inc [hl]
	ld b, $03
	ld c, $00
	ld hl, $c89b

jr_05f_507d:
	ld a, [hl]
	and $03
	add $01
	cp $04
	jr c, jr_05f_5088

	ld a, $03

jr_05f_5088:
	or c
	ld c, a
	ld a, [hl]
	and $0c
	add $04
	cp $0d
	jr c, jr_05f_5095

	ld a, $0c

jr_05f_5095:
	or c
	ld c, a
	ld a, [hl]
	and $30
	add $10
	cp $31
	jr c, jr_05f_50a2

	ld a, $30

jr_05f_50a2:
	or c
	ld c, a
	ld a, [hl]
	and $c0
	add $40
	cp $c1
	jr c, jr_05f_50af

	ld a, $c0

jr_05f_50af:
	or c
	ld [hli], a
	dec b
	jr nz, jr_05f_507d

	ret


Call_5F_50B5::
	xor a
	ld [$da86], a
	ld hl, $da87
	inc [hl]
	ld b, $03
	ld c, $00
	ld hl, $c89b

jr_05f_50c4:
	ld a, [hl]
	and $03
	cp $00
	jr z, jr_05f_50cd

	sub $01

jr_05f_50cd:
	or c
	ld c, a
	ld a, [hl]
	and $0c
	cp $00
	jr z, jr_05f_50d8

	sub $04

jr_05f_50d8:
	or c
	ld c, a
	ld a, [hl]
	and $30
	cp $00
	jr z, jr_05f_50e3

	sub $10

jr_05f_50e3:
	or c
	ld c, a
	ld a, [hl]
	and $c0
	cp $00
	jr z, jr_05f_50ee

	sub $40

jr_05f_50ee:
	or c
	ld [hli], a
	dec b
	jr nz, jr_05f_50c4

	ret


Call_5F_50F4::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


	db $c7, $00, $c4, $00, $ca, $00, $c1, $00, $cd, $00, $11, $51, $35, $51, $59, $51
	db $7d, $51, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d
	db $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d
	db $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d
	db $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d
	db $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d
	db $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d
	db $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0

Jump_5F_51A1::
	ld a, [$da84]
	rst $00

JumpTable_5F_51A5::
	dw Jump_5F_51E7
	dw Jump_5F_51DD
	dw Jump_5F_51F0
	dw Jump_5F_51DD
	dw Jump_5F_51F9
	dw Jump_5F_51DD
	dw Jump_5F_5202
	dw Jump_5F_51DD
	dw Jump_5F_520B
	dw Jump_5F_51DD
	dw Jump_5F_5214
	dw Jump_5F_51DD
	dw Jump_5F_521D
	dw Jump_5F_51DD
	dw Jump_5F_522A
	dw Jump_5F_51DD
	dw Jump_5F_521D
	dw Jump_5F_51DD
	dw Jump_5F_522A
	dw Jump_5F_51DD
	dw Jump_5F_521D
	dw Jump_5F_51DD
	dw Jump_5F_522A
	dw Jump_5F_51DD
	dw Jump_5F_521D
	dw Jump_5F_51DD
	dw Jump_5F_522A
	dw Jump_5F_5237

Jump_5F_51DD::
	xor a
	ldh [$ffb7], a
	ldh [$ffbb], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_51E7::
	ld a, $fe
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_51F0::
	ld a, $02
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_51F9::
	ld a, $fc
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_5202::
	ld a, $04
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_520B::
	ld a, $f8
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_5214::
	ld a, $08
	ldh [$ffb7], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_521D::
	ld a, $f8
	ldh [$ffb7], a
	ld a, $02
	ldh [$ffbb], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_522A::
	ld a, $08
	ldh [$ffb7], a
	ld a, $02
	ldh [$ffbb], a
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_5237::
	xor a
	ldh [$ffb7], a
	ldh [$ffbb], a
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	ret


Jump_5F_5246::
	ld a, [$c863]
	ld b, a
	ld a, [$db88]
	cp $07
	jr nc, Jump_5F_52C8

	cp $03
	jr z, Jump_5F_52C8

	bit 1, b
	jr nz, jr_05f_525f

	cp $04
	jr c, Jump_5F_52C8

	jr jr_05f_5263

jr_05f_525f:
	cp $04
	jr nc, Jump_5F_52C8

jr_05f_5263:
	ld a, [$db88]
	call Call_2FA5
	jr c, Jump_5F_52C8

	ld a, [$da84]
	rst $00

JumpTable_5F_526F::
	dw Jump_5F_5279
	dw Jump_5F_529F
	dw Jump_5F_5279
	dw Jump_5F_529F
	dw Jump_5F_52C8

Jump_5F_5279::
	ld a, $06
	ld [$da85], a
	call Call_5F_4E80
	ld hl, $50ff
	call Call_5F_50F4
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, $03
	ld hl, $5109
	call Call_5F_50F4
	ld c, $06
	call Call_5F_4E1F
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_529F::
	ld a, $06
	ld [$da85], a
	call Call_5F_4E80
	ld hl, $50ff
	call Call_5F_50F4
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, [$db88]
	and $03
	ld hl, $5109
	call Call_5F_50F4
	ld c, $06
	call Call_5F_4E1F
	ld hl, $da84
	inc [hl]
	ret


Jump_5F_52C8::
	ld a, $01
	ld [$da82], a
	xor a
	ld [$da84], a
	xor a
	ld [$da85], a
	ret


Call_5F_52D6::
	ld a, [$db8a]
	cp $3b
	jr z, jr_05f_52e4

	cp $3c
	jr z, jr_05f_52e4

	cp $3e
	ret nz

jr_05f_52e4:
	ld a, [$d9ec]
	cp $07
	ret nz

	ld a, [$d9ed]
	cp $04
	ret


Call_5F_52F0::
	ld a, [$db8a]
	cp $15
	jp c, Jump_05f_53a4

	cp $24
	jp c, Jump_05f_5382

	cp $25
	jp c, Jump_05f_53a4

	cp $2a
	jp z, Jump_05f_53a4

	cp $37
	jr c, jr_05f_5382

	cp $3b
	jp z, Jump_05f_53be

	cp $3c
	jp z, Jump_05f_53be

	cp $3e
	jp z, Jump_05f_53be

	cp $67
	jp c, Jump_05f_53a4

	cp $6a
	jp c, Jump_05f_53be

	cp $71
	jr z, jr_05f_53a4

	cp $73
	jr c, jr_05f_5382

	cp $75
	jr c, jr_05f_53a4

	cp $77
	jr c, jr_05f_5382

	cp $78
	jr c, jr_05f_53a4

	cp $7b
	jr c, jr_05f_5382

	cp $80
	jr z, jr_05f_5382

	cp $84
	jr c, jr_05f_53a4

	cp $88
	jr c, jr_05f_5382

	cp $91
	jr c, jr_05f_53a4

	cp $95
	jr z, jr_05f_53a4

	cp $97
	jr c, jr_05f_5382

	cp $a3
	jr z, jr_05f_5382

	cp $a4
	jr c, jr_05f_53a4

	cp $a7
	jr c, jr_05f_53a4

	cp $a9
	jr z, jr_05f_53a4

	cp $ab
	jr c, jr_05f_5382

	cp $ae
	jr z, jr_05f_5382

	cp $b0
	jr c, jr_05f_53a4

	cp $c7
	jr c, jr_05f_5382

	cp $c9
	jr z, jr_05f_5382

	cp $d5
	jr c, jr_05f_53cd

	cp $d5
	jr z, jr_05f_5382

	jr jr_05f_53a4

Jump_05f_5382:
jr_05f_5382:
	ld a, [$db8a]
	cp $80
	jp z, Jump_05f_53e9

	ld a, [$d9ec]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [$d9ed]
	cp $0a
	jr z, jr_05f_53e3

	cp $01
	jr nz, jr_05f_53e9

	ld a, [$d9ee]
	cp $0e
	jr nc, jr_05f_53e9

	ret


Jump_05f_53a4:
jr_05f_53a4:
	ld a, [$d9ec]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [$d9ed]
	cp $0a
	jr z, jr_05f_53e3

	cp $01
	jr nz, jr_05f_53e9

	ld a, [$d9ee]
	cp $05
	jr z, jr_05f_53e9

	ret


Jump_05f_53be:
	ld a, [$d9ec]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [$d9ed]
	cp $04
	jr z, jr_05f_53e9

	ret


jr_05f_53cd:
	ld a, [$d9ec]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [$d9ed]
	cp $0a
	jr nz, jr_05f_53e9

	ld a, [$d9ef]
	cp $04
	jr nz, jr_05f_53e9

	ret


jr_05f_53e3:
	ld a, [$d9ef]
	cp $01
	ret z

Jump_05f_53e9:
jr_05f_53e9:
	ld a, [$db88]
	cp $10
	jr z, jr_05f_5409

	ld a, [$c863]
	bit 1, a
	jr nz, jr_05f_5400

	ld a, [$db88]
	cp $04
	jr c, jr_05f_540d

	jr jr_05f_5412

jr_05f_5400:
	ld a, [$db88]
	cp $04
	jr c, jr_05f_5412

	jr jr_05f_540d

jr_05f_5409:
	call Call_5F_5BA3
	ret c

jr_05f_540d:
	ld hl, $58dd
	jr jr_05f_5433

jr_05f_5412:
	ld hl, $59c3
	ld a, [$c86c]
	or a
	jr z, jr_05f_5433

	ld a, [$d9ec]
	cp $07
	jr nz, jr_05f_5433

	ld a, [$d9ed]
	cp $01
	jr nz, jr_05f_5433

	ld a, [$d9ee]
	cp $05
	jr nz, jr_05f_5433

	ld hl, $5aa9

jr_05f_5433:
	ld a, [$db8a]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call Call_5F_5441
	ret


Call_5F_5441::
	ld c, a
	ld b, $00
	ld hl, $58bd
	add hl, bc
	add hl, bc
	call RST_08
	ret


	db $e9, $fa, $8a, $db, $fe, $1a, $38, $6e, $fe, $1c, $38, $08, $fe, $29, $28, $04
	db $fe, $76, $20, $62, $cd, $8f, $5b, $38, $5d, $21, $74, $db, $fa, $63, $c8, $e6
	db $02, $cb, $3f, $ee, $01, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $53, $db, $7e
	db $fe, $01, $28, $32, $fe, $02, $28, $18, $fa, $88, $db, $e6, $03, $fe, $01, $28
	db $25, $38, $09, $fe, $03, $d2, $23, $55, $3e, $06, $18, $26, $3e, $04, $18, $22
	db $fa, $88, $db, $e6, $03, $fe, $03, $d2, $23, $55, $fe, $01, $28, $04, $3e, $02
	db $18, $10, $3e, $03, $18, $0c, $fa, $88, $db, $e6, $03, $fe, $03, $d2, $23, $55
	db $3e, $01, $ea, $54, $db, $c9, $cd, $8f, $5b, $30, $61, $21, $74, $db, $fa, $63
	db $c8, $e6, $02, $cb, $3f, $ee, $01, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $53
	db $db, $7e, $fe, $01, $28, $30, $fe, $02, $28, $17, $fa, $89, $db, $e6, $03, $fe
	db $01, $28, $23, $38, $08, $fe, $03, $30, $2d, $3e, $06, $18, $25, $3e, $04, $18
	db $21, $fa, $89, $db, $e6, $03, $fe, $01, $28, $08, $fe, $03, $30, $18, $3e, $02
	db $18, $10, $3e, $03, $18, $0c, $fa, $89, $db, $e6, $03, $fe, $03, $d2, $23, $55
	db $3e, $01, $ea, $54, $db, $c9, $3e, $08, $ea, $54, $db, $c9, $fa, $89, $db, $e6
	db $03, $fe, $03, $30, $f1, $cd, $a3, $5b, $30, $91, $21, $74, $db, $fa, $63, $c8
	db $e6, $02, $cb, $3f, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $53, $db, $7e, $fe
	db $01, $28, $33, $fe, $02, $28, $19, $fa, $88, $db, $e6, $03, $fe, $01, $28, $26
	db $38, $0a, $e6, $03, $fe, $03, $30, $be, $3e, $06, $18, $b6, $3e, $04, $18, $b2
	db $fa, $88, $db, $e6, $03, $fe, $01, $28, $09, $fe, $03, $d2, $23, $55, $3e, $02
	db $18, $a0, $3e, $03, $18, $9c, $fa, $88, $db, $e6, $03, $fe, $03, $d2, $23, $55
	db $3e, $01, $18, $8e, $cd, $4e, $54, $3e, $01, $ea, $68, $dd, $18, $20, $3e, $01
	db $ea, $54, $db, $3e, $01, $ea, $68, $dd, $18, $14, $cd, $4e, $54, $3e, $02, $ea
	db $68, $dd, $18, $0a, $3e, $00, $ea, $54, $db, $3e, $00, $ea, $68, $dd, $cd, $30
	db $56, $fe, $ff, $c8, $cd, $96, $56, $cd, $03, $31, $3e, $01, $ea, $80, $da, $c9
	db $cd, $60, $4a, $3e, $04, $ea, $83, $da, $c9, $cd, $60, $4a, $3e, $05, $ea, $83
	db $da, $c9, $cd, $60, $4a, $3e, $06, $ea, $83, $da, $c9, $cd, $60, $4a, $3e, $07
	db $ea, $83, $da, $c9, $cd, $60, $4a, $3e, $08, $ea, $83, $da, $c9, $cd, $60, $4a
	db $3e, $09, $ea, $83, $da, $c9, $cd, $60, $4a, $3e, $0a, $ea, $83, $da, $c9, $cd
	db $60, $4a, $3e, $0b, $ea, $83, $da, $c9, $cd, $60, $4a, $3e, $0c, $ea, $83, $da
	db $c9, $cd, $60, $4a, $3e, $03, $ea, $83, $da, $c9, $cd, $60, $4a, $3e, $0d, $ea
	db $83, $da, $c9

Call_5F_5630::
	ld a, [$db88]
	cp $10
	jr z, jr_05f_5649

	call Call_5F_5B8F
	jr c, jr_05f_563e

	jr jr_05f_565f

jr_05f_563e:
	call Call_5F_5BA3
	jr nc, jr_05f_564e

	ld a, $ff
	ld [$da81], a
	ret


jr_05f_5649:
	call Call_5F_5BA3
	jr c, jr_05f_5690

jr_05f_564e:
	ld a, [$db8a]
	ld de, $56ed
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [$da81], a
	ret


jr_05f_565f:
	ld a, [$db8a]
	cp $1a
	jr z, jr_05f_567f

	cp $1b
	jr z, jr_05f_567f

	cp $80
	jr z, jr_05f_567f

	cp $29
	jr z, jr_05f_567f

	cp $d5
	jr z, jr_05f_567f

	cp $aa
	jr z, jr_05f_567f

	call Call_5F_5BA3
	jr c, jr_05f_5690

jr_05f_567f:
	ld a, [$db8a]
	ld de, $57d5
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [$da81], a
	ret


jr_05f_5690:
	ld a, $ff
	ld [$da81], a
	ret


	db $cd, $b9, $56, $fa, $a4, $da, $ea, $64, $dd, $3e, $60, $ea, $63, $dd, $3e, $00
	db $ea, $62, $dd, $21, $62, $dd, $7d, $ea, $b4, $d7, $7c, $ea, $b5, $d7, $21, $00
	db $02, $d7, $c9, $fa, $88, $db, $fe, $10, $28, $07, $cd, $8f, $5b, $38, $02, $18
	db $15, $cd, $a3, $5b, $d8, $fa, $8a, $db, $21, $ed, $56, $85, $6f, $3e, $00, $8c
	db $67, $7e, $ea, $a4, $da, $c9, $fa, $8a, $db, $21, $d5, $57, $85, $6f, $3e, $00
	db $8c, $67, $7e, $ea, $a4, $da, $c9, $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $ff, $ff, $ff, $15, $15, $12, $17
	db $16, $12, $ff, $12, $12, $ff, $ff, $12, $12, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $1d, $ff, $ff, $ff, $1d, $1d, $ff, $ff, $ff, $1e, $1f, $20, $21, $25
	db $1d, $1d, $23, $24, $24, $25, $27, $ff, $ff, $ff, $ff, $ff, $1d, $ff, $1d, $09
	db $0b, $0f, $1b, $03, $04, $05, $1c, $0c, $0d, $0e, $1a, $28, $29, $2a, $15, $15
	db $15, $15, $15, $15, $15, $16, $16, $16, $ff, $17, $ff, $ff, $12, $12, $ff, $16
	db $15, $15, $ff, $ff, $ff, $ff, $ff, $2b, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $12, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $14, $ff, $ff, $ff, $15, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $14, $14, $14, $14, $14, $14, $14, $14, $14
	db $14, $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $2c, $2c, $2c, $15, $2c, $0f, $09
	db $12, $04, $0e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $02, $ff, $22, $22, $1d
	db $26, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $13, $13, $ff, $ff, $13, $13, $ff
	db $ff, $13, $13, $ff, $13, $ff, $19, $19, $18, $ff, $14, $14, $14, $14, $14, $ff
	db $ff, $14, $14, $14, $14, $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $13, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $2b
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $14, $14, $ff, $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $14, $ff, $ff, $ff, $15, $12, $ff, $18, $ff, $ff, $ff, $14, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $18, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $91, $55, $9b, $55, $a7, $55, $b1, $55, $cd
	db $55, $d6, $55, $df, $55, $e8, $55, $f1, $55, $fa, $55, $03, $56, $0c, $56, $15
	db $56, $cc, $55, $1e, $56, $27, $56, $00, $00, $00, $03, $03, $01, $02, $02, $01
	db $02, $03, $01, $03, $02, $01, $02, $02, $01, $0d, $0d, $0d, $00, $00, $00, $00
	db $00, $00, $0d, $00, $00, $0d, $0d, $00, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $06, $0d, $0e, $0e, $0d, $0e, $00, $00, $0d, $0d, $0d, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $0d, $0d, $0d, $0d, $0d, $00, $0d, $02, $00
	db $01, $02, $02, $03, $03, $01, $01, $03, $02, $01, $01, $02, $01, $01, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $0d, $00, $04, $04, $00, $00, $0d, $00
	db $00, $00, $0d, $0d, $0d, $0d, $0d, $01, $04, $05, $05, $04, $04, $04, $04, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $0d, $05, $0d, $00, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $00, $00, $00, $02, $02
	db $00, $03, $01, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $0d, $00, $00, $00
	db $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $0d, $0d, $00, $00, $0d, $0d, $00
	db $00, $0d, $00, $02, $00, $00, $00, $0d, $00, $00, $00, $00, $00, $0d, $0d, $00
	db $00, $00, $00, $00, $0d, $0d, $06, $0d, $0f, $0f, $0d, $0f, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $04, $04, $0d, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $01, $04, $05
	db $05, $04, $04, $04, $04, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $00, $00, $0d, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $00, $0d, $05, $0d, $00, $00, $0d, $00, $0d, $0d, $0d, $00, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0b, $0b, $0b, $04, $04, $08, $0d, $0c, $0c, $0b
	db $04, $0b, $04, $04, $08, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $06, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0a, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0c, $0a, $0d, $0b
	db $0b, $0b, $0a, $0b, $04, $0b, $0a, $06, $08, $08, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $04, $04, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $01, $04, $05, $05, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $05, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d

Call_5F_5B8F::
	ld a, [$c863]
	bit 1, a
	jr nz, jr_05f_5b9c

	ld a, [$db88]
	cp $04
	ret


jr_05f_5b9c:
	ld a, [$db88]
	cp $04
	ccf
	ret


Call_5F_5BA3::
	ld a, [$c863]
	bit 1, a
	jr nz, jr_05f_5bb0

	ld a, [$db89]
	cp $04
	ret


jr_05f_5bb0:
	ld a, [$db89]
	cp $04
	ccf
	ret


Call_5F_5BB7::
	xor a
	ld hl, $c8da
	ld bc, $0008
	call Call_12C7
	xor a
	ld hl, $c827
	ld bc, $0012
	call Call_12C7
	call Call_1264
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld a, $e0
	ld hl, $c500
	ld bc, $0240
	call Call_12C7
	xor a
	ld hl, $da82
	ld bc, $0006
	call Call_12C7
	ld de, $ff00
	ld hl, $9000
	ld bc, $0120
	call Call_5F_5ECC
	ld de, $6093
	ld hl, $c500
	call Call_5F_4263
	ld de, $60fe
	ld hl, $c500
	call Call_5F_4263
	ld de, $6169
	ld hl, $c500
	call Call_5F_4263
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld hl, $6195
	ld de, $8b90
	call Call_5F_5F58
	ld hl, $61ad
	ld de, $8ab0
	call Call_5F_5F58
	call Call_5F_5F86
	call Call_5F_5FA5
	call Call_5F_5FBC
	call Call_5F_5FDB
	ld a, $fc
	call Call_1688
	ld hl, $9800
	ld a, l
	ld [$d9f8], a
	ld a, h
	ld [$d9f9], a
	ld hl, far_Call_50_768E
	rst $10
	ld a, $01
	ld [$dd68], a
	ld a, $01
	ld [$db54], a
	ld a, $01
	ld [$da82], a
	ld a, $03
	ld [$c8da], a
	ld a, $07
	ldh [$ffb5], a
	ld a, $ff
	ldh [$ffb6], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffb7], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	xor a
	ld [$c892], a
	ld a, $03
	ld [$c8a1], a
	call Call_125D
	ld a, $03
	jp Jump_000_11cb


Call_5F_5C8D::
	ld a, [$da83]
	cp $09
	jr nz, jr_05f_5c9b

	ld a, [$da82]
	or a
	jp z, Jump_05f_5ec1

jr_05f_5c9b:
	ld a, [$c850]
	or a
	ret nz

	ld a, [$dd62]
	or a
	jp nz, Jump_05f_5ea3

	ld a, [$c8da]
	rst $00

JumpTable_5F_5CAB::
	dw Jump_5F_5CB3
	dw Jump_5F_5CD3
	dw Jump_5F_5CEF
	dw Jump_5F_5D0A

Jump_5F_5CB3::
	ld a, [$c846]
	bit 0, a
	jp nz, Jump_05f_5dd7

	bit 1, a
	jp nz, Jump_05f_5e3e

	bit 6, a
	jp nz, Jump_05f_5d75

	bit 7, a
	jp nz, Jump_05f_5d61

	bit 5, a
	jr nz, jr_05f_5d4c

	bit 4, a
	jr nz, jr_05f_5d36

	ret


Jump_5F_5CD3::
	ld a, [$c846]
	bit 1, a
	jp nz, Jump_05f_5e3e

	bit 6, a
	jp nz, Jump_05f_5d75

	bit 7, a
	jr nz, jr_05f_5d61

	bit 5, a
	jp nz, Jump_05f_5d91

	bit 4, a
	jp nz, Jump_05f_5d91

	ret


Jump_5F_5CEF::
	ld a, [$c846]
	bit 1, a
	jp nz, Jump_05f_5e3e

	bit 6, a
	jr nz, jr_05f_5d75

	bit 7, a
	jr nz, jr_05f_5d61

	bit 5, a
	jp nz, Jump_05f_5dc2

	bit 4, a
	jp nz, Jump_05f_5da4

	ret


Jump_5F_5D0A::
	ld a, [$da82]
	or a
	jr z, jr_05f_5d30

	ld a, [$c846]
	bit 0, a
	jp nz, Jump_05f_5e87

	bit 1, a
	jp nz, Jump_05f_5e3e

	bit 6, a
	jr nz, jr_05f_5d75

	bit 7, a
	jr nz, jr_05f_5d61

	bit 5, a
	jp nz, Jump_05f_5e72

	bit 4, a
	jp nz, Jump_05f_5e5c

	ret


jr_05f_5d30:
	call Call_5F_5E27
	jp Jump_05f_5ec1


jr_05f_5d36:
	ld a, [$c8db]
	inc a
	ld [$c8db], a
	ld a, [$c8db]
	cp $2d
	jr c, jr_05f_5d48

	xor a
	ld [$c8db], a

jr_05f_5d48:
	call Call_5F_5F86
	ret


jr_05f_5d4c:
	ld a, [$c8db]
	dec a
	ld [$c8db], a
	ld a, [$c8db]
	cp $2d
	jr c, jr_05f_5d48

	ld a, $2c
	ld [$c8db], a
	jr jr_05f_5d48

Jump_05f_5d61:
jr_05f_5d61:
	ld a, [$c8da]
	inc a
	ld [$c8da], a
	ld a, [$c8da]
	cp $04
	jr c, jr_05f_5d88

	xor a
	ld [$c8da], a
	jr jr_05f_5d88

Jump_05f_5d75:
jr_05f_5d75:
	ld a, [$c8da]
	dec a
	ld [$c8da], a
	ld a, [$c8da]
	cp $04
	jr c, jr_05f_5d88

	ld a, $03
	ld [$c8da], a

jr_05f_5d88:
	rst $00

JumpTable_5F_5D89::
	dw Jump_5F_5EE0
	dw Jump_5F_5EF4
	dw Jump_5F_5F0B
	dw Jump_5F_5F1F

Jump_05f_5d91:
	ld a, [$c8dc]
	xor $01
	ld [$c8dc], a
	call Call_5F_5FA5
	ld a, [$c8dc]
	rst $00

JumpTable_5F_5DA0::
	dw Jump_5F_606D
	dw Call_5F_607A

Jump_05f_5da4:
	ld a, [$c8dd]
	inc a
	ld [$c8dd], a
	ld a, [$c8dd]
	cp $d8
	jr c, jr_05f_5db6

	xor a
	ld [$c8dd], a

jr_05f_5db6:
	call Call_5F_5FBC
	ld a, [$c8dc]
	or a
	ret z

	call Call_5F_607A
	ret


Jump_05f_5dc2:
	ld a, [$c8dd]
	dec a
	ld [$c8dd], a
	ld a, [$c8dd]
	cp $d8
	jr c, jr_05f_5db6

	ld a, $d7
	ld [$c8dd], a
	jr jr_05f_5db6

Jump_05f_5dd7:
	ld a, [$c8db]
	ld hl, $61ee
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $8000
	call Call_1577
	ld a, [$c8db]
	ld [$c81e], a
	ld hl, far_Call_17_4751
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ld a, [$c8db]
	ld [$daa4], a
	ld a, [$c8db]
	ld [$da81], a
	ld a, [$daa4]
	ld [$dd64], a
	ld a, $60
	ld [$dd63], a
	ld a, $00
	ld [$dd62], a
	ld hl, $dd62
	ld a, l
	ld [$d7b4], a
	ld a, h
	ld [$d7b5], a
	ld hl, far_Call_02_400D
	rst $10
	call Call_5F_6014

Call_5F_5E27::
	ld hl, $c6cd
	call Call_5F_5F36
	call Call_5F_5F36
	call Call_5F_5F36
	ld hl, $c56d
	call Call_5F_5F36
	ld hl, far_Call_50_768E
	rst $10
	ret


Jump_05f_5e3e:
	ld a, $04
	call Call_1688
	ld a, $07
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c88e
	inc [hl]
	ret


Jump_05f_5e5c:
	ld a, [$c8e1]
	inc a
	ld [$c8e1], a
	ld a, [$c8e1]
	cp $0d
	jr c, jr_05f_5e6e

	xor a
	ld [$c8e1], a

jr_05f_5e6e:
	call Call_5F_5FDB
	ret


Jump_05f_5e72:
	ld a, [$c8e1]
	dec a
	ld [$c8e1], a
	ld a, [$c8e1]
	cp $0d
	jr c, jr_05f_5e6e

	ld a, $0c
	ld [$c8e1], a
	jr jr_05f_5e6e

Jump_05f_5e87:
	ld a, $04
	ld [$db89], a
	ld a, $01
	ld [$db75], a
	xor a
	ld hl, $da82
	ld bc, $0006
	call Call_12C7
	ld a, [$c8e1]
	ld [$da83], a
	jr Call_5F_5E27

Jump_05f_5ea3:
	ld a, [$dd62]
	or a
	jr z, jr_05f_5eb5

	call Call_5F_5FFA
	ld hl, far_Call_02_400D
	rst $10
	ld a, [$dd62]
	or a
	ret nz

jr_05f_5eb5:
	ld a, [$c8da]
	rst $00

JumpTable_5F_5EB9::
	dw Jump_5F_5EE0
	dw Jump_5F_5EF4
	dw Jump_5F_5F0B
	dw Jump_5F_5F1F

Jump_05f_5ec1:
	ld hl, far_Call_5F_4B1B
	rst $10
	ld a, [$da82]
	or a
	ret z

	jr Jump_5F_5F1F

Call_5F_5ECC::
	di
	call Call_1AA6
	ld a, d
	ld [hli], a
	ei
	di
	call Call_1AA6
	ld a, e
	ld [hli], a
	ei
	dec bc
	ld a, b
	or c
	jr nz, Call_5F_5ECC

	ret


Jump_5F_5EE0::
	ld hl, $c6cd
	call Call_5F_5F47
	call Call_5F_5F33
	ld hl, $c56d
	call Call_5F_5F36
	ld hl, far_Call_50_768E
	rst $10
	ret


Jump_5F_5EF4::
	ld hl, $c6cd
	call Call_5F_5F36
	call Call_5F_5F47
	call Call_5F_5F36
	ld hl, $c56d
	call Call_5F_5F36
	ld hl, far_Call_50_768E
	rst $10
	ret


Jump_5F_5F0B::
	ld hl, $c6cd
	call Call_5F_5F33
	call Call_5F_5F47
	ld hl, $c56d
	call Call_5F_5F36
	ld hl, far_Call_50_768E
	rst $10
	ret


Jump_5F_5F1F::
	ld hl, $c6cd
	call Call_5F_5F36
	call Call_5F_5F33
	ld hl, $c56d
	call Call_5F_5F47
	ld hl, far_Call_50_768E
	rst $10
	ret


Call_5F_5F33::
	call Call_5F_5F36

Call_5F_5F36::
	di
	call Call_1AA6
	ld a, $e0
	ld [hl], a
	ei
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ret


Call_5F_5F47::
	di
	call Call_1AA6
	ld a, $e8
	ld [hl], a
	ei
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ret


Call_5F_5F58::
	ld a, [hli]
	cp $ff
	ret z

	push hl
	push de
	ld hl, $c180
	push de
	call Call_0D40
	pop de
	ld hl, $c180
	call Call_5F_5F78
	pop de
	pop hl
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	jr Call_5F_5F58

Call_5F_5F78::
	ld b, $10

jr_05f_5f7a:
	di
	call Call_1AA6
	ld a, [hli]
	ld [de], a
	ei
	inc de
	dec b
	jr nz, jr_05f_5f7a

	ret


Call_5F_5F86::
	ld hl, $c8de
	ld a, [$c8db]
	and $f0
	call Call_5F_6248
	ld [hli], a
	ld a, [$c8db]
	and $0f
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld de, $8b40
	ld hl, $c8de
	call Call_5F_5F58
	ret


Call_5F_5FA5::
	ld hl, $61b5
	ld a, [$c8dc]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, $8b60
	call Call_5F_5F58
	ret


Call_5F_5FBC::
	ld hl, $c8de
	ld a, [$c8dd]
	and $f0
	call Call_5F_6248
	ld [hli], a
	ld a, [$c8dd]
	and $0f
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld de, $8b20
	ld hl, $c8de
	call Call_5F_5F58
	ret


Call_5F_5FDB::
	ld hl, $c8de
	ld a, [$c8e1]
	and $f0
	call Call_5F_6248
	ld [hli], a
	ld a, [$c8e1]
	and $0f
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld de, $8a90
	ld hl, $c8de
	call Call_5F_5F58
	ret


Call_5F_5FFA::
	ld a, [$c8db]
	cp $0e
	jr c, jr_05f_600a

	cp $21
	jr c, jr_05f_600f

	ld hl, far_Call_5E_4005
	rst $10
	ret


jr_05f_600a:
	ld hl, far_Call_5C_4005
	rst $10
	ret


jr_05f_600f:
	ld hl, far_Call_5D_4005
	rst $10
	ret


Call_5F_6014::
	ld hl, $c89b
	inc hl
	ld a, $d0
	ld [hli], a
	ld a, $e0
	ld [hl], a
	ld hl, $61c1
	ld a, [$c8db]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c89c], a
	ld a, [$c8db]
	cp $03
	jr z, jr_05f_6049

	cp $04
	jr z, jr_05f_6049

	cp $0a
	jr z, jr_05f_6049

	ld a, $01
	ld [$dd68], a
	ld a, $01
	ld [$db54], a
	jr jr_05f_6053

jr_05f_6049:
	ld a, $00
	ld [$dd68], a
	ld a, $00
	ld [$db54], a

jr_05f_6053:
	ld a, [$c8db]
	cp $0e
	jr c, jr_05f_6063

	cp $21
	jr c, jr_05f_6068

	ld hl, far_Call_5E_40CB
	rst $10
	ret


jr_05f_6063:
	ld hl, far_Call_5C_408D
	rst $10
	ret


jr_05f_6068:
	ld hl, far_Call_5D_40B3
	rst $10
	ret


Jump_5F_606D::
	ld de, $ff00
	ld hl, $9000
	ld bc, $0120
	call Call_5F_5ECC
	ret


Call_5F_607A::
	ld a, [$c8dd]
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
	ld hl, $9000
	call Call_1577
	ret


	db $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $c4, $c5, $c6, $e0, $c7
	db $c8, $e0, $e0, $e0, $e0, $b4, $b5, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $c9, $ca, $cb, $cc, $cd, $ce, $cf, $e0, $e0, $e0, $b6, $b7, $b8, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $b2
	db $b3, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $e0, $e0, $b9, $ba, $bb, $bc, $bd, $be, $e0, $bf, $c0, $c1
	db $c2, $c3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $ab, $ac, $ad, $ae, $af, $e0, $b0, $b1, $e0, $e8, $a9, $aa, $e0, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $c7, $00, $00, $01, $02, $03, $04, $05, $d8, $06
	db $07, $08, $09, $0a, $0b, $d8, $0c, $0d, $0e, $0f, $10, $11, $d8, $12, $13, $14
	db $15, $16, $17, $d8, $18, $19, $1a, $1b, $1c, $1d, $d8, $1e, $1f, $20, $21, $22
	db $23, $d9, $0b, $0a, $1d, $1d, $15, $0e, $0e, $0f, $0e, $0c, $1d, $18, $0b, $13
	db $17, $18, $16, $18, $17, $1c, $1d, $0e, $1b, $ff, $0e, $0f, $0e, $0c, $1d, $17
	db $18, $ff, $b9, $61, $bd, $61, $18, $0f, $0f, $ff, $18, $17, $90, $ff, $e0, $e0
	db $e0, $e0, $e0, $e0, $d0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $d0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d0, $00, $5a, $01, $5a, $02
	db $5a, $03, $5a, $04, $5a, $05, $5a, $06, $5a, $07, $5a, $08, $5a, $09, $5a, $0a
	db $5a, $0b, $5a, $0c, $5a, $0d, $5a, $0e, $5a, $0f, $5a, $10, $5a, $11, $5a, $12
	db $5a, $13, $5a, $14, $5a, $15, $5a, $16, $5a, $17, $5a, $18, $5a, $19, $5a, $1a
	db $5a, $1b, $5a, $1c, $5a, $1d, $5a, $1e, $5a, $1f, $5a, $0a, $5b, $0b, $5b, $0c
	db $5b, $0d, $5b, $0e, $5b, $0f, $5b, $10, $5b, $11, $5b, $12, $5b, $13, $5b, $14
	db $5b, $15, $5b, $16, $5b

Call_5F_6248::
	srl a
	srl a
	srl a
	srl a
	ret


Call_5F_6251::
	ld a, [$c8da]
	bit 7, a
	ret nz

	ld a, [$da88]
	or a
	jr nz, jr_05f_62d7

	ld a, [$c846]
	bit 2, a
	ret z

	ld a, $01
	ld [$da88], a
	ld hl, $6452
	ld de, $8860
	call Call_5F_5F58
	ld de, $63b0
	ld hl, $c500
	call Call_5F_4263
	ld a, [$c863]
	and $02
	rlca
	ld [$db4c], a
	inc a
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$db4d], a
	ld a, h
	ld [$db4e], a
	call Call_5F_62E5
	ld a, [$db4d]
	ld l, a
	ld a, [$db4e]
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_05f_62d2

	inc hl
	ld a, l
	ld [$db4d], a
	ld a, h
	ld [$db4e], a
	ld hl, $db4c
	inc [hl]
	call Call_5F_62E5
	ld a, [$db4d]
	ld l, a
	ld a, [$db4e]
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_05f_62d2

	inc hl
	ld a, l
	ld [$db4d], a
	ld a, h
	ld [$db4e], a
	ld hl, $db4c
	inc [hl]
	call Call_5F_62E5

jr_05f_62d2:
	ld hl, far_Call_50_768E
	rst $10
	ret


jr_05f_62d7:
	ld a, [$c846]
	bit 2, a
	ret z

	xor a
	ld [$da88], a
	ld [$d9f4], a
	ret


Call_5F_62E5::
	call Call_5F_633D
	ld a, [$db4c]
	ld hl, $dc44
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_5F_6348
	ld hl, $643a
	call Call_5F_6360
	ld a, [$db4c]
	ld hl, $dc54
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_5F_6348
	ld hl, $6440
	call Call_5F_6360
	ld a, [$db4c]
	ld hl, $dc4c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_5F_6348
	ld hl, $6446
	call Call_5F_6360
	ld a, [$db4c]
	ld hl, $dc5c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_5F_6348
	ld hl, $644c
	call Call_5F_6360
	ret


Call_5F_633D::
	xor a
	ld hl, $db4f
	ld bc, $0003
	call Call_12C7
	ret


Call_5F_6348::
	ld b, [hl]
	ld a, $64
	call Call_1DFB
	ld hl, $db4f
	ld [hl], b
	ld b, a
	ld a, $0a
	call Call_1DFB
	ld hl, $db50
	ld [hl], b
	ld [$db51], a
	ret


Call_5F_6360::
	ld a, [$db4c]
	and $03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, $c500
	add hl, de
	ld c, $00
	ld a, [$db4f]
	or c
	jr z, jr_05f_638a

	inc c
	ld a, [$db4f]
	ld de, $6430
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a

jr_05f_638a:
	inc hl
	ld a, [$db50]
	or c
	jr z, jr_05f_63a0

	inc c
	ld a, [$db50]
	ld de, $6430
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a

jr_05f_63a0:
	inc hl
	ld a, [$db51]
	ld de, $6430
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ret


	db $80, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $86, $e0, $e0
	db $e0, $e0, $e0, $86, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $87, $e0, $e0, $e0, $e0, $e0, $87, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $88, $e0, $e0, $e0, $e0, $e0, $88, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $89, $e0, $e0, $e0
	db $e0, $e0, $89, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $a2, $01, $a8, $01, $ae, $01
	db $c2, $01, $c8, $01, $ce, $01, $e2, $01, $e8, $01, $ee, $01, $02, $02, $08, $02
	db $0e, $02, $4a, $28, $2f, $48, $ff, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $02, $03, $04, $05, $d8, $00, $00, $00, $00, $00, $00, $00, $06
	db $07, $08, $09, $0a, $0b, $0c, $d8, $00, $00, $00, $00, $00, $00, $0d, $0e, $0f
	db $10, $11, $12, $13, $14, $d8, $00, $00, $00, $00, $00, $00, $15, $16, $17, $18
	db $19, $1a, $1b, $1c, $d8, $00, $00, $00, $00, $00, $1d, $1e, $1f, $20, $21, $22
	db $23, $24, $25, $26, $d8, $00, $00, $00, $00, $00, $27, $28, $29, $2a, $2b, $2c
	db $2d, $2e, $2f, $30, $d8, $00, $00, $00, $00, $00, $00, $31, $32, $33, $34, $35
	db $36, $00, $38, $d8, $00, $00, $00, $00, $00, $00, $39, $3a, $3b, $3c, $3d, $3e
	db $3f, $40, $d8, $00, $00, $00, $00, $00, $00, $41, $42, $43, $44, $45, $46, $47
	db $48, $d8, $00, $00, $00, $00, $00, $00, $49, $4a, $4b, $4c, $4d, $4e, $4f, $37
	db $d9, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $d8, $00, $6a, $6b, $6c, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $6d, $6e, $6f, $00, $d8, $00, $70, $71, $72, $73, $74
	db $75, $76, $77, $00, $00, $00, $78, $79, $7a, $7b, $7c, $7d, $7e, $00, $d8, $00
	db $00, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $00, $d8, $00, $00, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99
	db $9a, $9b, $9c, $9d, $9e, $9f, $a0, $00, $d8, $00, $00, $a1, $a2, $a3, $a4, $61
	db $62, $63, $64, $65, $66, $67, $68, $69, $ae, $af, $be, $00, $00, $d8, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $d9, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $d8, $00, $6a, $6b, $6c, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $6d, $6e, $6f, $00, $d8, $00, $70
	db $71, $72, $73, $74, $75, $76, $77, $00, $00, $00, $78, $79, $7a, $7b, $7c, $7d
	db $7e, $00, $d8, $00, $00, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89
	db $8a, $8b, $8c, $8d, $8e, $8f, $00, $d8, $00, $00, $90, $91, $92, $93, $94, $95
	db $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $a0, $00, $d8, $00, $00, $a1
	db $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $be, $00
	db $00, $d8, $00, $00, $00, $00, $00, $00, $bf, $cd, $ce, $cf, $d0, $d1, $d2, $d3
	db $d4, $00, $00, $00, $c0, $00, $d8, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $d8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $d8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $d8, $00, $00, $00, $ba, $bb, $bc, $bd, $b0, $b1, $b2, $b3, $b4
	db $b5, $b6, $b7, $b8, $b9, $00, $00, $00, $d8, $00, $00, $00, $00, $c1, $c2, $c3
	db $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $00, $00, $00, $00, $d9, $03, $01
	db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $d8, $0f
	db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $d8, $1d, $1e
	db $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $d9, $00, $01, $00
	db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10
	db $11, $12, $d9, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $00, $01, $02, $03
	db $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $e0
	db $e0, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22
	db $23, $24, $25, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $26, $27, $28, $29, $2a, $2b, $2c
	db $2d, $2e, $2f, $30, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $31, $32, $33
	db $34, $35, $36, $37, $38, $39, $3a, $3b, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50
	db $51, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $52, $53, $54, $55, $56, $57, $58
	db $59, $5a, $5b, $5c, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $5d, $5e
	db $5f, $60, $61, $62, $63, $64, $65, $66, $67, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f, $70, $71, $72, $aa, $ab, $ac, $ad
	db $ae, $af, $e0, $e0, $e0, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $e0, $e0
	db $b0, $b1, $b2, $b3, $b4, $b5, $e0, $e0, $e0, $7e, $7f, $80, $81, $82, $83, $84
	db $85, $86, $87, $88, $b6, $b7, $b8, $b9, $ba, $bb, $e0, $e0, $e0, $e0, $89, $8a
	db $8b, $8c, $8d, $8e, $8f, $90, $91, $92, $bc, $bd, $be, $bf, $c0, $c1, $e0, $e0
	db $e0, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $c2, $c3, $c4, $c5
	db $c6, $c7, $e0, $e0, $e0, $e0, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $e0
	db $c8, $c9, $ca, $cb, $cc, $cd, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b
	db $0c, $0d, $0e, $0f, $10, $11, $12, $e0, $e0, $14, $e0, $15, $16, $17, $18, $19
	db $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $24, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31
	db $32, $33, $34, $35, $36, $37, $38, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $3c, $3d, $3e, $3f
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d
	db $5e, $5f, $60, $61, $62, $63, $64, $e0, $e0, $68, $69, $6a, $6b, $6c, $6d, $6e
	db $6f, $70, $71, $72, $aa, $ab, $ac, $ad, $ae, $af, $e0, $e0, $e0, $e0, $e0, $73
	db $74, $75, $76, $77, $78, $79, $7a, $7b, $b0, $b1, $b2, $b3, $b4, $b5, $e0, $e0
	db $e0, $7e, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $b6, $b7, $b8, $b9
	db $ba, $bb, $e0, $e0, $e0, $e0, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
	db $bc, $bd, $be, $bf, $c0, $c1, $e0, $e0, $e0, $94, $95, $96, $97, $98, $99, $9a
	db $9b, $9c, $9d, $9e, $c2, $c3, $c4, $c5, $c6, $c7, $e0, $e0, $e0, $e0, $e0, $9f
	db $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $c8, $c9, $ca, $cb, $cc, $cd, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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
