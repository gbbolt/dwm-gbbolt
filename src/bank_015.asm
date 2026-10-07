INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $015", ROMX[$4000], BANK[$15]

BankNumber_15::
	db $15

FarTable_15::
	dw Call_15_4009
	dw $42b3
	dw Call_15_46D7
	dw Call_15_547C

Call_15_4009::
	ld hl, sp+$00
	ld a, l
	ld [$da7b], a
	ld a, h
	ld [$da7c], a
	xor a
	ld hl, $c8da
	ld bc, $0008
	call Call_12C7
	xor a
	ld hl, $c827
	ld bc, $0012
	call Call_12C7
	ld hl, $99c1
	ld a, l
	ld [$c83e], a
	ld a, h
	ld [$c83f], a
	xor a
	ld hl, $c8d2
	ld bc, $0008
	call Call_12C7
	call Call_1264
	xor a
	ld [$c8c7], a
	ld a, [$c88b]
	rst $00

JumpTable_15_4047::
	dw Jump_15_404F
	dw Jump_15_40A0
	dw Jump_15_4172
	dw Jump_15_4218

Jump_15_404F::
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld hl, far_Call_5F_441C
	rst $10
	ld a, $fc
	call Call_1688
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
	ld a, $00
	ld [$c865], a
	ld a, $00
	ld [$c866], a
	ld [$c86c], a
	ld [$c86d], a
	xor a
	ld [$c863], a
	ld [$c864], a
	ld a, $03
	ld [$c8a1], a
	ld a, $01
	jp Jump_000_11cb


Jump_15_40A0::
	ld a, $02
	call Call_1C89
	call Call_1013
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld hl, far_Call_17_4102
	rst $10
	ld hl, far_Call_17_4192
	rst $10
	ld a, $fc
	call Call_1688
	ld hl, $ff8a
	ld bc, $0021
	xor a
	call Call_12C7
	ld hl, $c8ea
	ld bc, $1100
	xor a
	call Call_12C7
	ld a, $04
	ld [$c8ee], a
	call Call_15_60DF
	ld de, $2e1e
	ld hl, $9000
	call Call_14CF
	ld de, $2e1f
	ld hl, $8800
	call Call_14CF
	ld de, $2e20
	ld hl, $8a00
	call Call_14CF
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	xor a
	ld hl, $c8d2
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$c8d6], a
	ld a, h
	ld [$c8d7], a
	call Call_15_5E8B
	ld a, $24
	call Call_1AE1
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
	ld a, $00
	ld [$c865], a
	ld a, $00
	ld [$c866], a
	xor a
	ld [$c864], a
	ld [$c86c], a
	ld [$c86d], a
	xor a
	ld [$c863], a
	ld [$c864], a
	ld a, $03
	ld [$c8a1], a
	ld a, $09
	jp Jump_000_11cb


Jump_15_4172::
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld a, $fc
	call Call_1688
	ld a, $04
	ld [$c8ee], a
	call Call_15_60DF
	ld de, $2e1e
	ld hl, $9000
	call Call_14CF
	ld de, $2e1f
	ld hl, $8800
	call Call_14CF
	ld de, $2e20
	ld hl, $8a00
	call Call_14CF
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	xor a
	ld hl, $c8d2
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$c8d6], a
	ld a, h
	ld [$c8d7], a
	call Call_15_5E8B
	ld hl, $c0d8
	ld bc, $0017
	ld a, $ff
	call Call_12C7
	ld a, $24
	call Call_1AE1
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
	xor a
	ld [$c873], a
	xor a
	ld [$c86e], a
	ld a, $03
	ld [$c8a1], a
	ld a, $09
	jp Jump_000_11cb


Jump_15_4218::
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld a, $fc
	call Call_1688
	ld a, $04
	ld [$c8ee], a
	call Call_15_60DF
	ld de, $2e1e
	ld hl, $9000
	call Call_14CF
	ld de, $2e1f
	ld hl, $8800
	call Call_14CF
	ld de, $2e20
	ld hl, $8a00
	call Call_14CF
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	xor a
	ld hl, $c8d2
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$c8d6], a
	ld a, h
	ld [$c8d7], a
	call Call_15_5E8B
	ld a, $24
	call Call_1AE1
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
	xor a
	ld [$c873], a
	xor a
	ld [$c86e], a
	ld a, $03
	ld [$c8a1], a
	ld a, $09
	jp Jump_000_11cb


	ld a, [$c88b]
	rst $00

JumpTable_15_42B7::
	dw Jump_15_42C0
	dw Jump_15_42CA
	dw Jump_15_46B9
	dw Jump_15_5462
	db $c9

Jump_15_42C0::
	ld a, $f4
	call Call_1275
	ld hl, $5f03
	rst $10
	ret


Jump_15_42CA::
	call Call_15_42F1
	di
	ld a, [$c86d]
	or a
	jr z, jr_015_42ef

	ld a, [$c86d]
	ld b, a
	xor a
	ld [$c86d], a
	ld a, [$c88e]
	or a
	jr nz, jr_015_42ef

	ld a, b
	call Call_126B

jr_015_42e6:
	ld a, [$c864]
	and $03
	cp $03
	jr nz, jr_015_42e6

jr_015_42ef:
	ei
	ret


Call_15_42F1::
	ld a, [$c8d2]
	rst $00

JumpTable_15_42F5::
	dw Jump_15_4301
	dw Jump_15_4342
	dw Jump_15_43C5
	dw Jump_15_43DF
	dw Jump_15_4402
	dw Jump_15_4436

Jump_15_4301::
	ld a, $f4
	call Call_1275
	call Call_15_5E7C
	ld de, $6454
	ld hl, $a002
	call Call_20EE
	or a
	jr z, jr_015_4318

	ld de, $647d

jr_015_4318:
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $43b2
	ld hl, $a002
	call Call_20EE
	or a
	jr z, jr_015_432d

	ld de, $43b7

jr_015_432d:
	xor a
	ld [$c8df], a
	ld a, [$c8da]
	ld [$c8e0], a
	call Call_15_60A2
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4342::
	ld a, [$c850]
	or a
	ld a, $f4
	call nz, Call_1275
	ret nz

	ld de, $43b2
	ld b, $01
	ld hl, $a002
	call Call_20EE
	or a
	jr z, jr_015_435f

	ld de, $43b7
	ld b, $04

jr_015_435f:
	ld hl, $c8da
	ld a, [$c8e0]
	ld [$c8da], a
	call Call_15_5F85
	ld a, [$c8da]
	ld [$c8e0], a
	ld de, $43b6
	ld hl, $a002
	call Call_20EE
	or a
	jr z, jr_015_4380

	ld de, $43c1

jr_015_4380:
	ld a, [$c8da]
	and $7f
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	call Call_1275
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_43b1

	ld a, [$c8da]
	and $7f
	cp $02
	jr z, jr_015_43a9

	cp $03
	jr z, jr_015_43a9

	ld a, $59
	call Call_1B2C

jr_015_43a9:
	ld hl, $c8d2
	inc [hl]
	xor a
	ld [$c8d3], a

Jump_015_43b1:
	ret


	db $21, $00, $ff, $ff, $f4, $21, $00, $61, $00, $a1, $00, $e1, $00, $ff, $ff, $f4
	db $f4, $f2, $f3

Jump_15_43C5::
	ld a, [$c8da]
	and $7f
	ld b, a
	ld hl, $a002
	call Call_20EE
	or a
	jr nz, jr_015_43d5

	inc b

jr_015_43d5:
	ld a, b
	rst $00

JumpTable_15_43D7::
	dw Jump_15_4445
	dw Jump_15_461E
	dw Jump_15_4677
	dw Jump_15_4698

Jump_15_43DF::
	ld a, $f4
	call Call_1275
	ld a, $04
	call Call_1688
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
	ret


Jump_15_4402::
	ld a, $f4
	call Call_1275
	ld a, [$c81c]
	cp $01
	jr nz, jr_015_4422

	ld hl, $0270
	call Call_096D
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


jr_015_4422:
	ld hl, $021b
	call Call_096D
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4436::
	ld a, $f4
	call Call_1275
	ld a, [$c825]
	or a
	ret nz

	xor a
	ld [$c8d2], a
	ret


Jump_15_4445::
	ld a, $f4
	call Call_1275
	ld a, [$c8d3]
	rst $00

JumpTable_15_444E::
	dw Jump_15_4452
	dw Jump_15_45FC

Jump_15_4452::
	di
	call Call_21B2
	ei
	ld hl, far_Call_17_401D
	rst $10
	jr jr_015_44d7

	db $fa, $69, $c9, $b7, $28, $74, $fa, $e7, $d9, $b7, $28, $64, $3e, $01, $ea, $ea
	db $c8, $3e, $01, $ea, $6c, $c9, $3e, $00, $ea, $6d, $c9, $ea, $6e, $c9, $21, $e8
	db $00, $7d, $ea, $6f, $c9, $7c, $ea, $70, $c9, $21, $58, $00, $7d, $ea, $71, $c9
	db $7c, $ea, $72, $c9, $3e, $00, $e0, $8d, $3e, $02, $e0, $8f, $3e, $02, $e0, $8e
	db $f0, $8f, $c6, $00, $ea, $b8, $d7, $af, $ea, $ba, $d7, $ea, $bb, $d7, $ea, $b6
	db $d7, $21, $b6, $d7, $7d, $ea, $b4, $d7, $7c, $ea, $b5, $d7, $f0, $8a, $ea, $b7
	db $d7, $21, $00, $02, $d7, $fa, $ba, $d7, $e0, $8b, $21, $09, $01, $d7, $18, $16
	db $3e, $01, $ea, $e7, $d9, $f3, $cd, $28, $21, $fb

jr_015_44d7:
	ld a, [$d974]
	cp $06
	jr z, jr_015_44e3

	ld a, $80
	ld [$c8ea], a

jr_015_44e3:
	ld a, [$c8eb]
	bit 4, a
	jr nz, jr_015_44ee

	xor a
	ld [$c8eb], a

jr_015_44ee:
	xor a
	ld [$d9e7], a
	ld hl, far_Call_01_484E
	rst $10
	ld de, $ca42
	ld hl, $9000
	call Call_15_5E2E
	call Call_15_45AE
	ld de, $673b
	call Call_15_5D8F
	ld a, [$cab8]
	ld c, a
	ld b, $00
	ld hl, HeaderComplementCheck
	call Call_15_5D33
	call Call_20AD
	ld a, [$cab7]
	ld c, a
	ld b, $00
	ld hl, $0150
	call Call_15_5D33
	call Call_20AD
	ld a, [$ca8d]
	or a
	jr z, jr_015_4578

	ld hl, $cb0c
	ld a, $00
	call Call_224A
	ld c, a
	ld b, $00
	ld hl, $01a4
	call Call_15_5D33
	call Call_2082
	ld a, [$ca8d]
	cp $01
	jr z, jr_015_457e

	ld hl, $cb0c
	ld a, $01
	call Call_224A
	ld c, a
	ld b, $00
	ld hl, $01aa
	call Call_15_5D33
	call Call_2082
	ld a, [$ca8d]
	cp $02
	jr z, jr_015_4584

	ld hl, $cb0c
	ld a, $02
	call Call_224A
	ld c, a
	ld b, $00
	ld hl, $01b0
	call Call_15_5D33
	call Call_2082
	jr jr_015_458a

jr_015_4578:
	ld hl, $0181
	call Call_15_4592

jr_015_457e:
	ld hl, $0187
	call Call_15_4592

jr_015_4584:
	ld hl, $018d
	call Call_15_4592

jr_015_458a:
	call Call_15_5DC0
	ld hl, $c8d3
	inc [hl]
	ret


Call_15_4592::
	push hl
	call Call_15_5D33
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
	call Call_15_5D33
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


Call_15_45AE::
	ld hl, $cac2
	ld a, $00
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $9040
	ld a, $01
	call Call_15_45E5
	ld hl, $cac2
	ld a, $01
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $9080
	ld a, $02
	call Call_15_45E5
	ld hl, $cac2
	ld a, $02
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $90c0
	ld a, $03
	call Call_15_45E5
	ret


Call_15_45E5::
	ld b, a
	ld a, [$ca8d]
	cp b
	jp nc, Call_15_5E2E

	ld b, $20

jr_015_45ef:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_015_45ef

	ret


Jump_15_45FC::
	ld a, [$c846]
	bit 0, a
	jr z, jr_015_460e

	ld a, $59
	call Call_1B2C
	ld hl, $c8d2
	inc [hl]
	jr jr_015_461d

jr_015_460e:
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_461d

	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]

jr_015_461d:
	ret


Jump_15_461E::
	ld a, $f4
	call Call_1275
	ld a, [$c8d3]
	rst $00

JumpTable_15_4627::
	dw Jump_15_462D
	dw Jump_15_462D
	dw Jump_15_462D

Jump_15_462D::
	ld hl, $ff8a
	ld bc, $0021
	xor a
	call Call_12C7
	ld hl, $c8ea
	ld bc, $1100
	xor a
	call Call_12C7
	ld a, $04
	ld [$c8ee], a
	xor a
	ld [$c8ea], a
	ld hl, $c8d2
	inc [hl]
	xor a
	ld [$d8d7], a
	ld a, $2f
	ld [$c968], a
	ld [$c96a], a
	ld a, $00
	ld [$c969], a
	ld [$c96b], a
	ld a, $00
	ld [$ca8d], a
	ld a, $ff
	ld [$ca8e], a
	ld a, $ff
	ld [$ca8f], a
	ld a, $ff
	ld [$ca90], a
	ret


Jump_15_4677::
	ld a, [$c8df]
	cp $ff
	jr z, jr_015_4689

	ld a, $00
	ld [$c841], a
	ld a, $f0
	ld [$c86d], a
	ret


jr_015_4689:
	ld a, $59
	call Call_1B2C
	xor a
	ld [$c86d], a
	ld a, $04
	ld [$c8d2], a
	ret


Jump_15_4698::
	ld a, [$c8df]
	cp $ff
	jr z, jr_015_46aa

	ld a, $00
	ld [$c841], a
	ld a, $f1
	ld [$c86d], a
	ret


jr_015_46aa:
	ld a, $59
	call Call_1B2C
	xor a
	ld [$c86d], a
	ld a, $04
	ld [$c8d2], a
	ret


Jump_15_46B9::
	call Call_047E
	ld a, [$c8d2]
	cp $06
	jr z, jr_015_46cc

	cp $14
	jr z, jr_015_46cc

	cp $1c
	jr z, jr_015_46cc

	ret


jr_015_46cc:
	call Call_15_53B2
	call Call_15_53EE
	ld hl, far_Call_17_41C0
	rst $10
	ret


Call_15_46D7::
	ld a, [$c8d2]
	rst $00

JumpTable_15_46DB::
	dw Jump_15_4725
	dw Jump_15_47B7
	dw Jump_15_4944
	dw Jump_15_4A0F
	dw Jump_15_4A14
	dw Jump_15_4A3D
	dw Jump_15_4B0B
	dw Jump_15_4B21
	dw Jump_15_4B57
	dw Jump_15_4B6B
	dw Jump_15_4B93
	dw Jump_15_4BE9
	dw Jump_15_4BFD
	dw Jump_15_4C25
	dw Jump_15_4C94
	dw Jump_15_4D22
	dw Jump_15_4DC8
	dw Jump_15_4E59
	dw Jump_15_4E5E
	dw Jump_15_4E87
	dw Jump_15_4F5B
	dw Jump_15_4F71
	dw Jump_15_4FA7
	dw Jump_15_4FB7
	dw Jump_15_4FF8
	dw Jump_15_5010
	dw Jump_15_5020
	dw Jump_15_504D
	dw Jump_15_50E3
	dw Jump_15_50FE
	dw Jump_15_5134
	dw Jump_15_5168
	dw Jump_15_51AA
	dw Jump_15_51BA
	dw Jump_15_52A1
	dw Jump_15_533C
	dw Jump_15_535C

Jump_15_4725::
	call Call_15_4730
	call Call_15_476F
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_4730::
	ld de, $cac1
	ld b, $00
	ld c, $00

jr_015_4737:
	push de
	ld a, [de]
	or a
	jr z, jr_015_475b

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_015_475b

	ld a, [$c0ec]
	cp b
	jr z, jr_015_475b

	ld a, [$c0ed]
	cp b
	jr z, jr_015_475b

	ld a, [$c0ee]
	cp b
	jr z, jr_015_475b

	inc c

jr_015_475b:
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
	jr nz, jr_015_4737

	ld a, c
	ld [$c8d8], a
	ret


Call_15_476F::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_015_4784:
	push de
	ld a, [de]
	or a
	jr z, jr_015_47a9

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_015_47a9

	ld a, [$c0ec]
	cp c
	jr z, jr_015_47a9

	ld a, [$c0ed]
	cp c
	jr z, jr_015_47a9

	ld a, [$c0ee]
	cp c
	jr z, jr_015_47a9

	ld [hl], c
	inc hl

jr_015_47a9:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_015_4784

	ret


Jump_15_47B7::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_56_4485
	rst $10
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_480B
	call Call_15_47DD
	call Call_15_4AFB
	call Call_15_5DC0
	ld hl, $0225
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_47DD::
	ld de, $6928
	call Call_15_5D8F
	call Call_15_48E5
	ld de, $67b5
	call Call_15_5D8F
	ld de, $680f
	call Call_15_5D8F
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $4a03
	ld b, $04
	ld a, [$c8d8]
	ld c, a
	ld hl, $c8da
	call Call_15_6080
	ret


Call_15_480B::
	ld a, [$c8db]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9100
	call Call_15_4825
	call Call_15_4825
	call Call_15_4825

Call_15_4825::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_015_4846

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_15_5E2E
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


jr_015_4846:
	ld b, $20

jr_015_4848:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_015_4848

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


Call_15_4860::
	ld a, [$c8db]
	add a
	add a
	ld b, a
	ld a, [$c8da]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	push af
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $9000
	call Call_15_5E2E
	pop af
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld hl, $9200
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


Call_15_48E5::
	ld a, [$c8db]
	add a
	add a
	ld b, a
	ld a, [$c8da]
	and $7f
	add b
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	push af
	ld hl, $cb0c
	call Call_223B
	ld c, [hl]
	ld b, $00
	ld hl, $0161
	call Call_15_5D33
	ld a, $de
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
	call Call_15_6135
	pop af
	push af
	ld hl, $cac1
	call Call_223B
	pop af
	ld b, a
	ld a, [hl]
	cp $02
	jr z, jr_015_4930

	call Call_15_4F14
	jr nz, jr_015_4930

	jr jr_015_493a

jr_015_4930:
	ld hl, $0169
	call Call_15_5D33
	ld a, $e3
	ld [hl], a
	ret


jr_015_493a:
	ld hl, $0169
	call Call_15_5D33
	ld a, $e0
	ld [hl], a
	ret


Jump_15_4944::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c825]
	or a
	ret nz

	call Call_15_5391
	ret z

	ld de, $4a03
	ld hl, $c8da
	ld a, [$c8d8]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_15_5EFC
	pop af
	ld hl, $c8da
	cp [hl]
	jr z, jr_015_4976

	call Call_15_4860
	call Call_15_48E5
	call Call_15_5DC0

jr_015_4976:
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_015_4989

	call Call_15_480B
	call Call_15_4860
	call Call_15_48E5
	call Call_15_5DC0

jr_015_4989:
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_49d4

	ld a, [$c0ee]
	cp $ff
	jr z, jr_015_499e

	ld a, $ff
	ld [$c0ee], a
	jr jr_015_49b8

jr_015_499e:
	ld a, [$c0ed]
	cp $ff
	jr z, jr_015_49ac

	ld a, $ff
	ld [$c0ed], a
	jr jr_015_49b8

jr_015_49ac:
	ld a, [$c0ec]
	cp $ff
	jr z, jr_015_49c2

	ld a, $ff
	ld [$c0ec], a

jr_015_49b8:
	call Call_15_4AFB
	ld a, $00
	ld [$c8d2], a
	jr jr_015_4a02

jr_015_49c2:
	ld hl, $022d
	call Call_096D
	ld a, $24
	ld [$c8d2], a
	ld a, $fd
	ld [$c873], a
	jr jr_015_4a02

jr_015_49d4:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_4a02

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8dc], a
	ld a, [$c8db]
	add a
	add a
	ld b, a
	ld a, [$c8da]
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
	ld hl, $c8d2
	inc [hl]

Jump_015_4a02:
jr_015_4a02:
	ret


	db $45, $01, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

Jump_15_4A0F::
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4A14::
	ld a, [$c825]
	or a
	ret nz

	call Call_15_5E7C
	call Call_15_4A27
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_4A27::
	call Call_15_47DD
	ld de, $6849
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $4af5
	ld a, [$c8dc]
	call Call_15_60A2
	ret


Jump_15_4A3D::
	call Call_15_5391
	ret z

	ld de, $4af5
	ld hl, $c8dc
	ld b, $02
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_4a71

	call Call_15_5E7C
	call Call_15_4860
	call Call_15_480B
	call Call_15_47DD
	call Call_15_5DC0
	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]
	jp Jump_015_4af4


jr_015_4a71:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_4af4

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_015_4a93

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_4af4


jr_015_4a93:
	ld a, [$c0ec]
	cp $ff
	jr nz, jr_015_4aa2

	ld a, [$cac0]
	ld [$c0ec], a
	jr jr_015_4ad3

jr_015_4aa2:
	ld a, [$c0ed]
	cp $ff
	jr nz, jr_015_4ab1

	ld a, [$cac0]
	ld [$c0ed], a
	jr jr_015_4ad3

jr_015_4ab1:
	ld a, [$cac0]
	ld [$c0ee], a
	call Call_15_4AFB
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ret


jr_015_4ad3:
	call Call_15_4AFB
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	call Call_15_4730
	or a
	jr nz, jr_015_4af4

	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]

Jump_015_4af4:
jr_015_4af4:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Call_15_4AFB::
	ld de, $c0ec
	ld hl, $9040
	call Call_15_4825
	call Call_15_4825
	call Call_15_4825
	ret


Jump_15_4B0B::
	xor a
	ld [$c906], a
	xor a
	ld [$c8eb], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4B21::
	ld de, $2e1e
	ld hl, $9000
	call Call_1577
	ld de, $2e1f
	ld hl, $8800
	call Call_1577
	ld hl, $0225
	call Call_096D
	call Call_0609
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_480B
	call Call_15_47DD
	call Call_15_4A27
	call Call_15_4AFB
	call Call_15_5DC0
	ld a, $05
	ld [$c8d2], a
	ret


Jump_15_4B57::
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld hl, $0227
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4B6B::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_15_4B80
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_4B80::
	ld de, $6873
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $4be3
	ld a, [$c8dd]
	call Call_15_60A2
	ret


Jump_15_4B93::
	call Call_15_5391
	ret z

	ld de, $4be3
	ld hl, $c8dd
	ld b, $02
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_4bb0

jr_015_4ba9:
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_4be2


jr_015_4bb0:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_4be2

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $81
	jr z, jr_015_4ba9

	call Call_15_4730
	call Call_15_476F
	call Call_15_4860
	call Call_15_480B
	call Call_15_47DD
	ld a, $01
	ld [$c8d2], a
	xor a
	ld [$c8da], a
	ld [$c8db], a
	jp Jump_015_4be2


Jump_015_4be2:
	ret


	db $cf, $01, $0f, $02, $ff, $ff

Jump_15_4BE9::
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld hl, $0228
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4BFD::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_15_4C12
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_4C12::
	ld de, $6873
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $4c8e
	ld a, [$c8de]
	call Call_15_60A2
	ret


Jump_15_4C25::
	call Call_15_5391
	ret z

	ld de, $4c8e
	ld hl, $c8de
	ld b, $02
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_4c5c

jr_015_4c3b:
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld hl, $0229
	call Call_096D
	ld a, $14
	ld [$cac0], a
	ld a, $00
	ld [$d665], a
	ld a, $16
	ld [$c8d2], a
	jp Jump_015_4c8d


jr_015_4c5c:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_4be2

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_015_4c3b

	call Call_15_4CC2
	call Call_15_4CEC
	call Call_15_4860
	call Call_15_480B
	call Call_15_47DD
	xor a
	ld [$c8da], a
	ld [$c8db], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_4c8d


Jump_015_4c8d:
	ret


	db $cf, $01, $0f, $02, $ff, $ff

Jump_15_4C94::
	call Call_15_4CC2
	call Call_15_4CEC
	ld hl, $c8d2
	inc [hl]
	ld a, [$c8d8]
	or a
	ret nz

	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld hl, $0229
	call Call_096D
	ld a, $14
	ld [$cac0], a
	ld a, $00
	ld [$d665], a
	ld a, $16
	ld [$c8d2], a
	ret


Call_15_4CC2::
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_015_4cc9:
	push de
	ld a, [de]
	or a
	jr z, jr_015_4cdb

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_015_4cdb

	inc c

jr_015_4cdb:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_015_4cc9

	ld a, c
	ld [$c8d8], a
	ret


Call_15_4CEC::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_015_4d01:
	push de
	ld a, [de]
	or a
	jr z, jr_015_4d14

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_015_4d14

	ld [hl], c
	inc hl

jr_015_4d14:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_015_4d01

	ret


Jump_15_4D22::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_56_4485
	rst $10
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_4D73
	call Call_15_4D45
	call Call_15_5DC0
	ld hl, $022a
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_4D45::
	ld de, $6928
	call Call_15_5D8F
	call Call_15_48E5
	ld de, $67b5
	call Call_15_5D8F
	ld de, $680f
	call Call_15_5D8F
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $4e4d
	ld b, $04
	ld a, [$c8d8]
	ld c, a
	ld hl, $c8da
	call Call_15_6080
	ret


Call_15_4D73::
	ld a, [$c8db]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9100
	call Call_15_4D8D
	call Call_15_4D8D
	call Call_15_4D8D

Call_15_4D8D::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_015_4dae

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_15_5E2E
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


jr_015_4dae:
	ld b, $20

jr_015_4db0:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_015_4db0

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


Jump_15_4DC8::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c825]
	or a
	ret nz

	call Call_15_5391
	ret z

	ld de, $4e4d
	ld hl, $c8da
	ld a, [$c8d8]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_15_5EFC
	pop af
	ld hl, $c8da
	cp [hl]
	jr z, jr_015_4dfa

	call Call_15_4860
	call Call_15_48E5
	call Call_15_5DC0

jr_015_4dfa:
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_015_4e0d

	call Call_15_4D73
	call Call_15_4860
	call Call_15_48E5
	call Call_15_5DC0

jr_015_4e0d:
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_4e1b

	ld a, $0b
	ld [$c8d2], a
	jr jr_015_4e4c

jr_015_4e1b:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_4e4c

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8dc], a
	ld [$c8dd], a
	ld a, [$c8db]
	add a
	add a
	ld b, a
	ld a, [$c8da]
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
	ld hl, $c8d2
	inc [hl]

Jump_015_4e4c:
jr_015_4e4c:
	ret


	db $45, $01, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

Jump_15_4E59::
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4E5E::
	ld a, [$c825]
	or a
	ret nz

	call Call_15_5E7C
	call Call_15_4E71
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_4E71::
	call Call_15_4D45
	ld de, $6849
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $4f0e
	ld a, [$c8dc]
	call Call_15_60A2
	ret


Jump_15_4E87::
	call Call_15_5391
	ret z

	ld de, $4f0e
	ld hl, $c8dc
	ld b, $02
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_4ebb

	call Call_15_5E7C
	call Call_15_4860
	call Call_15_4D73
	call Call_15_4D45
	call Call_15_5DC0
	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]
	jp Jump_015_4f0d


jr_015_4ebb:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_4f0d

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_015_4edd

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_4f0d


jr_015_4edd:
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld a, [$cac0]
	ld b, a
	call Call_15_4F14
	jr nz, jr_015_4f00

	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_015_4f0d

jr_015_4f00:
	ld hl, $025c
	call Call_096D
	ld a, $23
	ld [$c8d2], a
	jr jr_015_4f0d

Jump_015_4f0d:
jr_015_4f0d:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Call_15_4F14::
	ld hl, $a1c7
	call Call_20EE
	or a
	jr nz, jr_015_4f55

	ld hl, $a1f3
	call Call_20EE
	or a
	jr z, jr_015_4f55

	ld hl, $a1f4
	call Call_20EE
	cp b
	jr z, jr_015_4f57

	ld hl, $a1f3
	call Call_20EE
	cp $01
	jr z, jr_015_4f55

	ld hl, $a1f5
	call Call_20EE
	cp b
	jr z, jr_015_4f57

	ld hl, $a1f3
	call Call_20EE
	cp $02
	jr z, jr_015_4f55

	ld hl, $a1f6
	call Call_20EE
	cp b
	jr z, jr_015_4f57

jr_015_4f55:
	xor a
	ret


jr_015_4f57:
	ld a, $01
	or a
	ret


Jump_15_4F5B::
	xor a
	ld [$c906], a
	xor a
	ld [$c8eb], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_4F71::
	ld de, $2e1e
	ld hl, $9000
	call Call_1577
	ld de, $2e1f
	ld hl, $8800
	call Call_1577
	ld hl, $022a
	call Call_096D
	call Call_0609
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_4D73
	call Call_15_4D45
	call Call_15_4E71
	call Call_15_4AFB
	call Call_15_5DC0
	ld a, $12
	ld [$c8d2], a
	ret


Jump_15_4FA7::
	ld hl, $021f
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ld a, $01
	ld [$c873], a
	ret


Jump_15_4FB7::
	call Call_15_5391
	ret z

	ld a, [$c86e]
	cp $01
	ret nz

	ld hl, $c8d2
	inc [hl]
	ld a, $95
	ld [$c871], a
	xor a
	ld [$c872], a
	ld a, [$cac0]
	ld [$c8ba], a
	ld hl, $cac1
	call Call_223B
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $d6fa
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $01
	ld [$c8c7], a
	ret


Jump_15_4FF8::
	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c8c7], a
	ld a, $00
	ld [$c873], a
	ld hl, $c8d2
	inc [hl]
	xor a
	ld [$c825], a
	ret


Jump_15_5010::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $022b
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_5020::
	ld a, [$c825]
	or a
	ret nz

	call Call_15_5E7C
	call Call_15_5037
	call Call_15_5DC0
	xor a
	ld [$c8dd], a
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_5037::
	call Call_15_4D45
	ld de, $6898
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $50db
	ld a, [$c8dd]
	call Call_15_60A2
	ret


Jump_15_504D::
	ld a, [$c86e]
	cp $fe
	jr nz, jr_015_5067

	ld hl, $022e
	call Call_096D
	ld a, $1e
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_50da


jr_015_5067:
	ld de, $50db
	ld hl, $c8dd
	ld b, $03
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_508c

jr_015_5079:
	ld hl, $022d
	call Call_096D
	ld a, $1e
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_50da


jr_015_508c:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_50da

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $80
	jr z, jr_015_50c6

	cp $82
	jr z, jr_015_5079

	ld a, [$d6fa]
	or a
	jr z, jr_015_50b8

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_50da


jr_015_50b8:
	ld hl, $022f
	call Call_096D
	ld a, $19
	ld [$c8d2], a
	jp Jump_015_50da


jr_015_50c6:
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]

Jump_015_50da:
	ret


	db $2c, $00, $6c, $00, $ac, $00, $ff, $ff

Jump_15_50E3::
	ld a, $15
	ld [$cac0], a
	xor a
	ld [$c906], a
	xor a
	ld [$c8eb], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_50FE::
	ld de, $2e1e
	ld hl, $9000
	call Call_1577
	ld de, $2e1f
	ld hl, $8800
	call Call_1577
	ld hl, $022b
	call Call_096D
	call Call_0609
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_4D73
	call Call_15_4D45
	call Call_15_4AFB
	call Call_15_5037
	call Call_15_5DC0
	ld a, $1a
	ld [$c8d2], a
	ret


Jump_15_5134::
	ld a, [$c86e]
	cp $fe
	ret nz

	ld a, $64
	ld [$c871], a
	xor a
	ld [$c872], a
	ld hl, $c300
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $c300
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $01
	ld [$c8c7], a
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_5168::
	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c8c7], a
	ld hl, $c88a
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld [hl], $00
	ld hl, $c88e
	inc [hl]
	ld a, $00
	ld [$c865], a
	ld a, $00
	ld [$c866], a
	xor a
	ld [$c863], a
	ld [$c864], a
	ld [$c86c], a
	xor a
	ld [$c86e], a
	xor a
	ld [$c873], a
	xor a
	ld [$c86d], a
	ld a, $04
	call Call_1688
	ret


Jump_15_51AA::
	ld hl, $021f
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ld a, $01
	ld [$c873], a
	ret


Jump_15_51BA::
	ld a, [$c86e]
	cp $fe
	jr nz, jr_015_51d4

	ld hl, $022e
	call Call_096D
	ld a, $1e
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_5286


jr_015_51d4:
	ld a, [$c86e]
	cp $01
	ret nz

	ld a, [$c0ec]
	ld de, $c300
	call Call_15_5287
	ld a, [$c0ed]
	ld de, $c395
	call Call_15_5287
	ld a, [$c0ee]
	ld de, $c42a
	call Call_15_5287
	ld hl, $c300
	ld de, $cac1
	ld b, $95

jr_015_51fd:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_015_51fd

	ld a, [$c0ec]
	ld [$c8c4], a
	ld a, [$c0ed]
	ld [$c8c5], a
	ld a, [$c0ee]
	ld [$c8c6], a
	xor a
	ld [$c8c3], a
	ld a, [$c8c4]
	cp $ff
	jr z, jr_015_5243

	ld a, $01
	ld [$c8c3], a
	ld a, [$c8c5]
	cp $ff
	jr z, jr_015_5243

	ld a, $02
	ld [$c8c3], a
	ld a, [$c8c6]
	cp $ff
	jr z, jr_015_5243

	ld a, $03
	ld [$c8c3], a

jr_015_5243:
	ld hl, $ca42
	ld de, $cacd
	ld b, $08

jr_015_524b:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_015_524b

	ld hl, $01bf
	ld a, l
	ld [$c871], a
	ld a, h
	ld [$c872], a
	ld hl, $cac1
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $cd15
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $01
	ld [$c8c7], a
	ld hl, $c8d2
	inc [hl]
	ld hl, $022c
	call Call_096D

Jump_015_5286:
	ret


Call_15_5287::
	and $7f
	cp $7f
	jr nz, jr_015_5290

	xor a
	ld [de], a
	ret


jr_015_5290:
	push de
	ld hl, $cac1
	call Call_223B
	pop de
	ld b, $95

jr_015_529a:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_015_529a

	ret


Jump_15_52A1::
	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c8c7], a
	ld hl, far_Call_01_683E
	rst $10
	ld hl, $cac1
	ld de, $cac1
	ld b, $95
	ld a, [$c863]
	bit 1, a
	jr z, jr_015_52c1

	ld de, $cd15

jr_015_52c1:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	dec b
	jr nz, jr_015_52c1

	ld a, $ff
	ld [$ca8e], a
	ld [$ca8f], a
	ld [$ca90], a
	ld b, $00
	ld a, [$cac1]
	or a
	jr z, jr_015_5307

	ld a, $00
	ld [$ca8e], a
	inc b
	ld a, [$cb56]
	or a
	jr z, jr_015_5307

	ld a, $01
	ld [$ca8f], a
	inc b
	ld a, [$cbeb]
	or a
	jr z, jr_015_5307

	ld a, $02
	ld [$ca90], a
	inc b

jr_015_5307:
	ld a, b
	ld [$ca8d], a
	ld a, [$c8ba]
	cp $14
	jr nz, jr_015_5317

	ld a, $ff
	ld [$c8ba], a

jr_015_5317:
	ld hl, $c88a
	ld a, $02
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld [hl], $00
	ld hl, $c88e
	inc [hl]
	ld a, $01
	ld [$c865], a
	ld a, $00
	ld [$c866], a
	xor a
	ld [$c873], a
	xor a
	ld [$c86e], a
	ret


Jump_15_533C::
	ld a, [$c825]
	or a
	ret nz

	call Call_15_5E7C
	call Call_15_4860
	call Call_15_4D73
	call Call_15_4D45
	call Call_15_5DC0
	ld hl, $022a
	call Call_096D
	ld a, $10
	ld [$c8d2], a
	ret


Jump_15_535C::
	ld a, [$c86e]
	cp $fd
	ret nz

	ld a, $64
	ld [$c871], a
	xor a
	ld [$c872], a
	ld hl, $c300
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $c300
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $1f
	ld [$c8d2], a
	ld a, $01
	ld [$c8c7], a
	ret


Call_15_5391::
	ld a, [$c86e]
	cp $fd
	ret nz

	ld hl, $022e
	call Call_096D
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld a, $24
	ld [$c8d2], a
	ld a, $fd
	ld [$c873], a
	xor a
	ret


Call_15_53B2::
	ld a, [$c90e]
	cp $05
	ret nz

	ld hl, $caca
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
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
	ld a, [$c8a4]
	bit 4, a
	jr z, jr_015_53e1

	ld b, $01

jr_015_53e1:
	ld a, b
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_40A7
	rst $10
	ret


Call_15_53EE::
	ld a, [$c90e]
	cp $09
	ret nz

	ld hl, $cad6
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
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
	jr z, jr_015_5420

	ld b, $01

jr_015_5420:
	ld a, b
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_40A7
	rst $10
	ld hl, $cad7
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
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
	jr z, jr_015_5455

	ld b, $01

jr_015_5455:
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_40A7
	rst $10
	ret


Jump_15_5462::
	call Call_047E
	ld a, [$c8d2]
	cp $06
	jr z, jr_015_5471

	cp $0e
	jr z, jr_015_5471

	ret


jr_015_5471:
	call Call_15_5C60
	call Call_15_5C9C
	ld hl, far_Call_17_41C0
	rst $10
	ret


Call_15_547C::
	ld a, [$c8d2]
	rst $00

JumpTable_15_5480::
	dw Jump_15_54B4
	dw Jump_15_551F
	dw Jump_15_55BF
	dw Jump_15_5659
	dw Jump_15_565E
	dw Jump_15_5687
	dw Jump_15_572F
	dw Jump_15_5745
	dw Jump_15_5775
	dw Jump_15_5785
	dw Jump_15_57C3
	dw Jump_15_582F
	dw Jump_15_583A
	dw Jump_15_5863
	dw Jump_15_58E9
	dw Jump_15_5904
	dw Jump_15_5934
	dw Jump_15_595C
	dw Jump_15_5990
	dw Jump_15_59D2
	dw Jump_15_59E1
	dw Jump_15_5A0F
	dw Jump_15_5A7B
	dw Jump_15_5A8B
	dw Jump_15_5ADF
	dw Jump_15_5C0A

Jump_15_54B4::
	call Call_15_54BF
	call Call_15_54E9
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_54BF::
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_015_54c6:
	push de
	ld a, [de]
	or a
	jr z, jr_015_54d8

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_015_54d8

	inc c

jr_015_54d8:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_015_54c6

	ld a, c
	ld [$c8d8], a
	ret


Call_15_54E9::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_015_54fe:
	push de
	ld a, [de]
	or a
	jr z, jr_015_5511

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_015_5511

	ld [hl], c
	inc hl

jr_015_5511:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_015_54fe

	ret


Jump_15_551F::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_56_4485
	rst $10
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_556A
	call Call_15_5542
	call Call_15_5DC0
	ld hl, $021c
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_5542::
	ld de, $6928
	call Call_15_5D8F
	call Call_15_48E5
	ld de, $67b5
	call Call_15_5D8F
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $564d
	ld b, $04
	ld a, [$c8d8]
	ld c, a
	ld hl, $c8da
	call Call_15_6080
	ret


Call_15_556A::
	ld a, [$c8db]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9100
	call Call_15_5584
	call Call_15_5584
	call Call_15_5584

Call_15_5584::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_015_55a5

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_15_5E2E
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


jr_015_55a5:
	ld b, $20

jr_015_55a7:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_015_55a7

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


Jump_15_55BF::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c825]
	or a
	ret nz

	call Call_15_5C3F
	ret z

	ld de, $564d
	ld hl, $c8da
	ld a, [$c8d8]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	call Call_15_5EFC
	pop af
	ld hl, $c8da
	cp [hl]
	jr z, jr_015_55f1

	call Call_15_4860
	call Call_15_48E5
	call Call_15_5DC0

jr_015_55f1:
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_015_5604

	call Call_15_556A
	call Call_15_4860
	call Call_15_48E5
	call Call_15_5DC0

jr_015_5604:
	ld a, [$c846]
	bit 1, a
	jp z, Jump_015_561e

	ld hl, $0221
	call Call_096D
	ld a, $19
	ld [$c8d2], a
	ld a, $fd
	ld [$c873], a
	jr jr_015_564c

Jump_015_561e:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_564c

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8dc], a
	ld a, [$c8db]
	add a
	add a
	ld b, a
	ld a, [$c8da]
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
	ld hl, $c8d2
	inc [hl]

Jump_015_564c:
jr_015_564c:
	ret


	db $45, $01, $61, $00, $a1, $00, $e1, $00, $21, $01, $ff, $ff

Jump_15_5659::
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_565E::
	ld a, [$c825]
	or a
	ret nz

	call Call_15_5E7C
	call Call_15_5671
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_5671::
	call Call_15_5542
	ld de, $6849
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $5729
	ld a, [$c8dc]
	call Call_15_60A2
	ret


Jump_15_5687::
	call Call_15_5C3F
	ret z

	ld de, $5729
	ld hl, $c8dc
	ld b, $02
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_56bb

	call Call_15_5E7C
	call Call_15_4860
	call Call_15_556A
	call Call_15_5542
	call Call_15_5DC0
	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]
	ld hl, $c8d2
	dec [hl]
	jp Jump_015_5728


jr_015_56bb:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_5728

	ld a, $59
	call Call_1B2C
	ld a, [$c8dc]
	cp $81
	jr z, jr_015_56dd

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_5728


jr_015_56dd:
	ld a, [$cac0]
	ld b, a
	call Call_15_4F14
	jr nz, jr_015_56f4

	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	jr nz, jr_015_5701

jr_015_56f4:
	ld hl, $025d
	call Call_096D
	ld a, $10
	ld [$c8d2], a
	jr jr_015_5728

jr_015_5701:
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $0a
	jr nc, jr_015_571c

	ld hl, $0230
	call Call_096D
	ld a, $10
	ld [$c8d2], a
	jr jr_015_5728

jr_015_571c:
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]

Jump_015_5728:
jr_015_5728:
	ret


	db $2e, $00, $6e, $00, $ff, $ff

Jump_15_572F::
	xor a
	ld [$c906], a
	xor a
	ld [$c8eb], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_5745::
	ld de, $2e1e
	ld hl, $9000
	call Call_1577
	ld de, $2e1f
	ld hl, $8800
	call Call_1577
	ld hl, $021c
	call Call_096D
	call Call_0609
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_556A
	call Call_15_5671
	call Call_15_5DC0
	ld a, $05
	ld [$c8d2], a
	ret


Jump_15_5775::
	ld hl, $021f
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ld a, $01
	ld [$c873], a
	ret


Jump_15_5785::
	call Call_15_5C3F
	ret z

	ld a, [$c86e]
	cp $01
	ret nz

	ld hl, $c8d2
	inc [hl]
	ld a, $95
	ld [$c871], a
	xor a
	ld [$c872], a
	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $d6fa
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $01
	ld [$c8c7], a
	ret


Jump_15_57C3::
	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c8c7], a
	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	ld a, [$d705]
	and $01
	ld b, a
	ld a, [hl]
	and $01
	cp b
	jr nz, jr_015_57ef

	ld hl, $021e
	call Call_096D
	ld a, $10
	ld [$c8d2], a
	jr jr_015_582e

jr_015_57ef:
	ld a, [$cac0]
	ld d, a
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	ld c, $1b
	call Call_1DBE
	push hl
	ld d, $15
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	pop hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	add $7b
	ld l, a
	ld a, h
	adc $61
	ld h, a
	ld a, [hl]
	or a
	jr nz, jr_015_5825

	ld hl, $025e
	call Call_096D
	ld a, $10
	ld [$c8d2], a
	jr jr_015_582e

jr_015_5825:
	ld a, $00
	ld [$c873], a
	ld hl, $c8d2
	inc [hl]

jr_015_582e:
	ret


Jump_15_582F::
	ld hl, $0220
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_583A::
	ld a, [$c825]
	or a
	ret nz

	call Call_15_5E7C
	call Call_15_584D
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_584D::
	call Call_15_5542
	ld de, $68e0
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $58e1
	ld a, [$c8dd]
	call Call_15_60A2
	ret


Jump_15_5863::
	ld a, [$c86e]
	cp $fe
	jr nz, jr_015_587d

	ld hl, $0222
	call Call_096D
	ld a, $11
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_58e0


jr_015_587d:
	ld de, $58e1
	ld hl, $c8dd
	ld b, $03
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_58a2

jr_015_588f:
	ld hl, $0221
	call Call_096D
	ld a, $11
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_58e0


jr_015_58a2:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_58e0

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $80
	jr z, jr_015_58c8

	cp $82
	jr z, jr_015_588f

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_58e0


jr_015_58c8:
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]
	ld hl, $c8d2
	inc [hl]

Jump_015_58e0:
	ret


	db $2c, $00, $6c, $00, $ac, $00, $ff, $ff

Jump_15_58E9::
	ld a, $15
	ld [$cac0], a
	xor a
	ld [$c906], a
	xor a
	ld [$c8eb], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_5904::
	ld de, $2e1e
	ld hl, $9000
	call Call_1577
	ld de, $2e1f
	ld hl, $8800
	call Call_1577
	ld hl, $0220
	call Call_096D
	call Call_0609
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_556A
	call Call_15_584D
	call Call_15_5DC0
	ld a, $0d
	ld [$c8d2], a
	ret


Jump_15_5934::
	ld a, [$c825]
	or a
	ret nz

	ld a, $00
	ld [$c873], a
	ld hl, $021c
	call Call_096D
	call Call_0609
	call Call_15_5E7C
	call Call_15_4860
	call Call_15_556A
	call Call_15_5542
	call Call_15_5DC0
	ld a, $02
	ld [$c8d2], a
	ret


Jump_15_595C::
	ld a, [$c86e]
	cp $fe
	ret nz

	ld a, $64
	ld [$c871], a
	xor a
	ld [$c872], a
	ld hl, $c300
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $c300
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $01
	ld [$c8c7], a
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_5990::
	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c8c7], a
	ld hl, $c88a
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld [hl], $00
	ld hl, $c88e
	inc [hl]
	ld a, $00
	ld [$c865], a
	ld a, $00
	ld [$c866], a
	xor a
	ld [$c863], a
	ld [$c864], a
	ld [$c86c], a
	xor a
	ld [$c86e], a
	xor a
	ld [$c873], a
	xor a
	ld [$c86d], a
	ld a, $04
	call Call_1688
	ret


Jump_15_59D2::
	ld hl, $0223
	call Call_096D
	xor a
	ld [$c8de], a
	ld hl, $c8d2
	inc [hl]
	ret


Jump_15_59E1::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	call Call_15_5E7C
	call Call_15_59F9
	call Call_15_5DC0
	ld hl, $c8d2
	inc [hl]
	ret


Call_15_59F9::
	call Call_15_584D
	ld de, $6716
	call Call_15_5D8F
	call Call_15_5FE3
	ld de, $5a75
	ld a, [$c8de]
	call Call_15_60A2
	ret


Jump_15_5A0F::
	ld a, [$c86e]
	cp $fe
	jr nz, jr_015_5a29

	ld hl, $0222
	call Call_096D
	ld a, $11
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_58e0


jr_015_5a29:
	ld de, $5a75
	ld hl, $c8de
	ld b, $02
	call Call_15_5F85
	ld a, [$c846]
	bit 1, a
	jr z, jr_015_5a52

jr_015_5a3b:
	call Call_15_5E7C
	call Call_15_584D
	call Call_15_5DC0
	ld hl, $0220
	call Call_096D
	ld a, $0c
	ld [$c8d2], a
	jp Jump_015_5a74


jr_015_5a52:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_015_5a74

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_015_5a3b

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld hl, $c8d2
	inc [hl]
	jp Jump_015_5a74


Jump_015_5a74:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_15_5A7B::
	ld hl, $021f
	call Call_096D
	ld hl, $c8d2
	inc [hl]
	ld a, $01
	ld [$c873], a
	ret


Jump_15_5A8B::
	ld a, [$c86e]
	cp $fe
	jr nz, jr_015_5aa5

	ld hl, $0222
	call Call_096D
	ld a, $11
	ld [$c8d2], a
	ld a, $fe
	ld [$c873], a
	jp Jump_015_58e0


jr_015_5aa5:
	ld a, [$c86e]
	cp $01
	ret nz

	ld a, $64
	ld [$c871], a
	xor a
	ld [$c872], a
	ld hl, $c300
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $c300
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $01
	ld [$c8c7], a
	ld hl, $c8d2
	inc [hl]
	ld hl, $0224
	call Call_096D
	ret


Jump_15_5ADF::
	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c8c7], a
	ld hl, $c88a
	ld a, $01
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld [hl], $00
	ld hl, $c88e
	inc [hl]
	ld a, $00
	ld [$c865], a
	ld a, $00
	ld [$c866], a
	xor a
	ld [$c863], a
	ld [$c864], a
	xor a
	ld [$c86e], a
	xor a
	ld [$c873], a
	xor a
	ld [$c86d], a
	ld a, $04
	call Call_1688
	ld a, [$c8db]
	add a
	add a
	ld b, a
	ld a, [$c8da]
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
	ld hl, $cac1
	call Call_223B
	ld de, $d665
	ld b, $95

jr_015_5b41:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_015_5b41

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
	ld [hl], $00
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
	ld hl, far_Call_16_4015
	rst $10
	xor a
	ld [$c86c], a
	di
	ld hl, $ca94
	ld de, $a1ce
	ld b, $20
	ld a, $0a
	ld [$0100], a

jr_015_5b93:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_015_5b93

	ld a, $00
	ld [$0100], a
	call Call_2197
	ei
	ld a, $14
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, $15
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld a, [$cac0]
	ld hl, $caca
	call Call_223B
	ld l, [hl]
	ld h, $05
	ld de, $c1a0
	call Call_097A
	ld a, $04
	ld [$c8ee], a
	xor a
	ld [$c8ea], a
	xor a
	ld [$d8d7], a
	xor a
	ld [$c8eb], a
	ld a, $08
	ld [$c968], a
	ld [$c96a], a
	ld a, $00
	ld [$c969], a
	ld [$c96b], a
	ld a, $00
	ld [$ca8d], a
	ld a, $ff
	ld [$ca8e], a
	ld a, $ff
	ld [$ca8f], a
	ld a, $ff
	ld [$ca90], a
	ret


Jump_15_5C0A::
	ld a, [$c86e]
	cp $fd
	ret nz

	ld a, $64
	ld [$c871], a
	xor a
	ld [$c872], a
	ld hl, $c300
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $c300
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a
	ld a, $12
	ld [$c8d2], a
	ld a, $01
	ld [$c8c7], a
	ret


Call_15_5C3F::
	ld a, [$c86e]
	cp $fd
	ret nz

	ld hl, $0222
	call Call_096D
	ld de, $2e07
	call Call_15_5D8F
	call Call_15_5DC0
	ld a, $19
	ld [$c8d2], a
	ld a, $fd
	ld [$c873], a
	xor a
	ret


Call_15_5C60::
	ld a, [$c90e]
	cp $05
	ret nz

	ld hl, $caca
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
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
	ld a, [$c8a4]
	bit 4, a
	jr z, jr_015_5c8f

	ld b, $01

jr_015_5c8f:
	ld a, b
	ld [hli], a
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_40A7
	rst $10
	ret


Call_15_5C9C::
	ld a, [$c90e]
	cp $09
	ret nz

	ld hl, $cad6
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
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
	jr z, jr_015_5cce

	ld b, $01

jr_015_5cce:
	ld a, b
	ld [hli], a
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_40A7
	rst $10
	ld hl, $cad7
	ld a, [$cac0]
	call Call_223B
	ld a, [hl]
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
	jr z, jr_015_5d03

	ld b, $01

jr_015_5d03:
	ld a, b
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_40A7
	rst $10
	ret


Call_15_5D10::
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


Call_15_5D1F::
	ld a, [$c8d6]
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


Call_15_5D33::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_15_5D3C::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_15_5D1F
	ld a, b
	and $1f
	jr z, jr_015_5d51

	ld b, a

jr_015_5d4b:
	call Call_15_5D10
	dec b
	jr nz, jr_015_5d4b

jr_015_5d51:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $3c, $5d, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $10, $5d, $18, $d3

Call_15_5D8F::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_15_5D33
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a

jr_015_5d9e:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_015_5dbd

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
	jr jr_015_5d9e

jr_015_5dbd:
	ld [hli], a
	jr jr_015_5d9e

Call_15_5DC0::
	ld a, [$c8d6]
	ld l, a
	ld a, [$c8d7]
	ld h, a
	ld de, $c500
	ld c, $12

jr_015_5dcd:
	ld b, $20
	push hl

jr_015_5dd0:
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
	jr nz, jr_015_5dd0

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
	jr nz, jr_015_5dcd

	ret


	db $fa, $27, $c8, $4f, $fa, $28, $c8, $47, $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8
	db $47, $c5, $7d, $ea, $27, $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea
	db $2a, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27, $c8, $7c, $ea, $28, $c8
	db $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9

Call_15_5E2E::
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


Call_15_5E7C::
	ld hl, $c500
	ld bc, $0240

jr_015_5e82:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_015_5e82

	ret


Call_15_5E8B::
	ld hl, $9800
	ld bc, $0400

jr_015_5e91:
	ld a, $e0
	call Call_1AB9
	dec bc
	ld a, b
	or c
	jr nz, jr_015_5e91

	ret


	db $21, $da, $c8, $01, $08, $00, $3e, $00, $cd, $c7, $12, $f0, $bb, $6f, $26, $00
	db $29, $29, $f0, $b7, $0f, $0f, $0f, $85, $6f, $7c, $ce, $98, $67, $7c, $e6, $03
	db $f6, $98, $67, $7d, $ea, $d6, $c8, $7c, $ea, $d7, $c8, $cd, $7c, $5e, $cd, $8b
	db $5e, $11, $0d, $2e, $21, $00, $90, $cd, $77, $15, $cd, $e3, $5f, $21, $d2, $c8
	db $34, $c9, $cd, $7c, $5e, $cd, $c0, $5d, $21, $01, $0b, $d7, $21, $02, $0b, $d7
	db $cd, $18, $25, $cd, $f1, $25, $21, $eb, $c8, $cb, $8e, $af, $ea, $d2, $c8, $c9

Call_15_5EFC::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_015_5f63

	ld a, [$c847]
	bit 5, a
	jr z, jr_015_5f29

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
	jr c, jr_015_5f47

	ld a, c
	dec a
	jr jr_015_5f47

jr_015_5f29:
	ld a, [$c847]
	bit 4, a
	jr z, jr_015_5f63

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
	jr c, jr_015_5f47

	ld a, $00

jr_015_5f47:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_015_5fab

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
	jr z, jr_015_5fab

	dec a
	cp [hl]
	jr nc, jr_015_5fab

	ld [hl], a
	jr jr_015_5fab

Jump_015_5f63:
jr_015_5f63:
	push bc
	push de
	push hl
	call Call_15_6047
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
	jr nz, Call_15_5F85

	ld a, [$c8e1]
	inc a
	ld b, a

Call_15_5F85::
	res 7, [hl]
	ld a, b
	cp $01
	jr z, jr_015_5fb3

	ld a, [$c847]
	bit 6, a
	jr z, jr_015_5f9c

	ld a, [hl]
	dec a
	cp b
	jr c, jr_015_5faa

	dec b
	ld a, b
	jr jr_015_5faa

jr_015_5f9c:
	ld a, [$c847]
	bit 7, a
	jr z, jr_015_5fb3

	ld a, [hl]
	inc a
	cp b
	jr c, jr_015_5faa

	ld a, $00

jr_015_5faa:
	ld [hl], a

jr_015_5fab:
	xor a
	ld [$c8d9], a
	push hl
	push de
	pop de
	pop hl

jr_015_5fb3:
	ld a, [$c846]
	bit 0, a
	jr z, jr_015_5fbc

	set 7, [hl]

jr_015_5fbc:
	ld a, [hl]
	call Call_15_5FE8
	ret


	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

Call_15_5FE3::
	xor a
	ld [$c8d9], a
	ret


Call_15_5FE8::
	ld c, a
	bit 7, a
	jr nz, jr_015_5ffd

	ld a, [$c8d9]
	and $0f
	push af
	ld a, [$c8d9]
	inc a
	ld [$c8d9], a
	pop af
	ld a, c
	ret nz

jr_015_5ffd:
	ld c, a
	ld b, $00

jr_015_6000:
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
	call Call_15_5D3C
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_015_6030

	ld a, $e9
	bit 7, c
	jr nz, jr_015_6030

	ld a, [$c8d9]
	bit 4, a
	ld a, $e0
	jr nz, jr_015_6030

	ld a, $e8

jr_015_6030:
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
	jr jr_015_6000

Call_15_6047::
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
	call Call_15_5D3C
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


Call_15_6080::
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
	jr nc, jr_015_6099

	ld a, $e7

jr_015_6099:
	ld [hld], a
	pop bc
	jr nc, jr_015_60a1

	ld a, [bc]
	add $f1
	ld [hl], a

jr_015_60a1:
	pop af

Call_15_60A2::
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
	call Call_15_5D3C
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_015_60cd

	ld a, [$c8d9]
	bit 4, a
	ld a, $e0
	jr nz, jr_015_60cd

	ld a, $e8

jr_015_60cd:
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


Call_15_60DF::
	ld a, $0a
	ld [$0100], a
	ld a, [$a002]
	or a
	jr z, jr_015_610a

	ld hl, $a002
	ld bc, $1ffe
	call Call_210E
	ld a, $0a
	ld [$0100], a
	ld a, [$a000]
	ld l, a
	ld a, [$a001]
	ld h, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, h
	or l
	jr z, jr_015_6127

jr_015_610a:
	ld hl, $a002
	ld bc, $1ffe
	push hl
	push bc
	call Call_15_612D
	pop bc
	pop hl
	call Call_210E
	ld a, $0a
	ld [$0100], a
	ld a, e
	ld [$a000], a
	ld a, d
	ld [$a001], a

jr_015_6127:
	ld a, $00
	ld [$0100], a
	ret


Call_15_612D::
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, Call_15_612D

	ret


Call_15_6135::
	ld de, $000a
	push bc
	call Call_15_6151
	pop bc
	or a
	jr z, jr_015_614c

	ld de, $000a
	call Call_15_6151
	call Call_15_6166
	call Call_15_616C

jr_015_614c:
	ld a, c
	call Call_15_6166
	ret


Call_15_6151::
	push hl
	ld h, $ff

jr_015_6154:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_015_6154

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


Call_15_6166::
	add $f0
	call Call_1AAD
	ret


Call_15_616C::
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


	db $01, $01, $01, $01, $00, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $00, $01, $00, $01, $01, $01, $01, $00, $00, $00, $01, $01, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01
	db $01, $00, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00
	db $00, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01, $01, $00, $01, $00, $00
	db $01, $00, $00, $01, $00, $00, $01, $00, $01, $01, $00, $00, $00, $01, $01, $00
	db $00, $01, $01, $00, $00, $00, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01
	db $00, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00, $01, $01, $01, $01, $01
	db $00, $01, $01, $01, $01, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $00, $01, $01, $00, $01, $01, $00, $00, $00, $00, $01, $01, $01, $00
	db $00, $00, $00, $00, $01, $01, $00, $01, $01, $01, $01, $01, $00, $00, $00, $00
	db $00, $00, $01, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00, $00, $00, $01
	db $01, $00, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $00, $01, $00, $00
	db $01, $01, $01, $01, $01, $00, $01, $01, $00, $00, $01, $00, $01, $01, $01, $01
	db $01, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $01, $01, $00, $00, $01
	db $01, $00, $00, $00, $01, $01, $00, $01, $01, $01, $00, $00, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $00, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $01
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $01, $01, $01, $01, $00, $00
	db $00, $01, $01, $01, $01, $01, $01, $01, $00, $00, $01, $01, $01, $00, $00, $01
	db $00, $00, $01, $00, $01, $01, $01, $01, $01, $00, $00, $00, $01, $00, $00, $01
	db $00, $01, $01, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $01, $00, $00
	db $01, $01, $00, $00, $00, $00, $00, $01, $00, $00, $01, $01, $01, $01, $00, $00
	db $00, $01, $01, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	db $00, $00, $01, $00, $01, $01, $01, $01, $01, $01, $00, $00, $01, $01, $00, $00
	db $01, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $00, $01, $00, $00
	db $01, $00, $00, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $01, $01, $00, $01, $01, $01, $01, $00, $00, $01, $01, $01, $01, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00
	db $00, $01, $00, $00, $01, $01, $01, $01, $01, $01, $00, $00, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $01, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $01, $01, $01, $01, $00, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $01, $00, $00, $00, $00, $00, $01, $01, $01, $01, $00, $01, $01, $01, $01
	db $00, $00, $00, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $01, $00, $01, $01, $00, $00, $00, $00, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $31, $28, $3a, $e0, $2a, $24
	db $30, $28, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9, $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $26, $32, $31, $37, $2c, $31, $38, $28, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $31, $28, $3a
	db $e0, $2a, $24, $30, $28, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $39, $36, $e0, $30, $32, $27, $28, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $25, $35, $28, $28, $27, $2c, $31, $2a, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $26, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $00, $01, $02, $03, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $24, $25, $26, $27, $28, $e0, $3e, $3f, $40
	db $41, $42, $e0, $e0, $91, $92, $93, $94, $95, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $29, $2a, $2b, $2c, $2d, $e0, $43, $44, $45, $46, $47, $e0, $e0, $49, $4b
	db $4d, $8d, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $2e, $2f, $30, $31, $32
	db $e0, $48, $e0, $4a, $e0, $4c, $e0, $e0, $60, $6a, $60, $70, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $33, $34, $35, $37, $38, $e0, $4e, $4f, $50, $51, $52
	db $e0, $e0, $47, $98, $50, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $39
	db $3a, $3b, $3c, $3d, $e0, $53, $54, $55, $36, $9c, $e0, $e0, $28, $53, $50, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38
	db $39, $3a, $e0, $25, $26, $27, $28, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $3b
	db $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $e0, $29, $2a, $2b
	db $2c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $48, $49, $4a, $4b, $4c, $4d, $4e
	db $4f, $50, $51, $52, $53, $54, $e0, $2d, $24, $69, $6a, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d, $5e, $5f, $60, $61
	db $e0, $2f, $2e, $30, $38, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $62, $64, $65
	db $66, $67, $68, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $32, $3b, $31, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $30, $24, $36, $37, $28, $35, $e4, $00, $01
	db $02, $03, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $da
	db $04, $05, $06, $07, $e0, $db, $08, $09, $0a, $0b, $e0, $dc, $0c, $0d, $0e, $0f
	db $ff, $d8, $fe, $e0, $65, $e4, $e0, $e0, $e0, $e0, $65, $e4, $e0, $e0, $e0, $e0
	db $65, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $3a, $2b, $32, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $10, $11, $12, $13, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $14, $15, $16, $17, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $18, $19, $1a, $1b, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $1c, $1d, $1e, $1f, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $cd, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $f1
	db $04, $05, $06, $07, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $f2
	db $08, $09, $0a, $0b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $f3
	db $0c, $0d, $0e, $0f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $0d, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $2c, $31, $29, $32, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $32, $2e, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $ae, $01, $fa, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $0b, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $29, $2c, $2a, $2b, $37
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $33
	db $35, $2c, $3d, $28, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $28, $3b, $2c, $37, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $0b, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $25, $35, $28, $28, $27, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $26, $2b, $28, $26, $2e, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $3b, $2c, $37, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $40, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $00
	db $01, $02, $03, $20, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $3f, $31, $3f, $8f, $ff, $8c, $fc, $8c, $fc, $8f, $ff, $8c, $fc
	db $8c, $fc, $8f, $8f, $ff, $ff, $fb, $ff, $04, $07, $03, $03, $ff, $ff, $04, $00
	db $04, $ff, $88, $df, $ff, $20, $e0, $c0, $c0, $ff, $ff, $04, $00, $04, $ff, $8e
	db $f1, $ff, $31, $3f, $31, $3f, $f1, $ff, $31, $3f, $31, $3f, $f1, $f1, $05, $ff
	db $99, $88, $fb, $8c, $88, $fb, $8f, $ff, $8c, $fc, $8c, $fc, $8f, $ff, $8c, $fc
	db $8c, $fc, $8f, $ff, $8c, $fc, $8c, $fc, $8f, $8f, $07, $ff, $84, $00, $ff, $00
	db $00, $03, $ff, $8d, $00, $00, $03, $03, $ff, $fe, $03, $02, $02, $03, $fe, $ff
	db $02, $03, $03, $09, $ff, $84, $00, $ff, $00, $00, $03, $ff, $8d, $00, $00, $c0
	db $c0, $ff, $7f, $c0, $40, $40, $c0, $7f, $ff, $40, $03, $c0, $09, $ff, $99, $11
	db $df, $31, $11, $df, $f1, $ff, $31, $3f, $31, $3f, $f1, $ff, $31, $3f, $31, $3f
	db $f1, $ff, $31, $3f, $31, $3f, $f1, $f1, $04, $ff, $10, $00, $8c, $ff, $00, $ff
	db $00, $ff, $00, $ff, $ff, $80, $ff, $80, $80, $04, $9f, $10, $00, $8c, $ff, $03
	db $fe, $03, $fe, $03, $ff, $ff, $00, $ff, $00, $00, $04, $ff, $10, $00, $8c, $ff
	db $c0, $7f, $c0, $7f, $c0, $ff, $ff, $00, $ff, $00, $00, $04, $ff, $10, $00, $8c
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $01, $ff, $01, $01, $04, $f9, $0e, $9f
	db $8e, $bf, $bf, $9f, $9f, $df, $df, $9f, $9f, $bf, $bf, $df, $df, $bf, $bf, $44
	db $ff, $0e, $f9, $8e, $fd, $fd, $f9, $f9, $fb, $fb, $f9, $f9, $fd, $fd, $fb, $fb
	db $fd, $fd, $04, $ff, $9e, $03, $01, $07, $02, $07, $02, $07, $02, $0d, $06, $7d
	db $0e, $f3, $7c, $ff, $80, $f3, $7c, $7d, $0e, $0d, $06, $07, $02, $07, $02, $07
	db $02, $03, $01, $08, $00, $91, $1c, $00, $1f, $0c, $1f, $0b, $0e, $05, $0d, $06
	db $0e, $05, $1f, $0b, $1f, $0c, $1c, $11, $00, $93, $1c, $00, $3f, $1c, $3b, $17
	db $1f, $08, $0f, $04, $07, $02, $0d, $06, $0f, $05, $07, $02, $02, $05, $00, $10
	db $ff, $11, $00, $b0, $ff, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $00, $0f, $ff, $98, $00, $ff, $7f, $80, $7f, $80, $7f, $80, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $08
	db $ff, $ff, $00, $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80
	db $ff, $80, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $ff, $80, $ff, $80
	db $ff, $80, $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $bc, $cf, $bd, $ce
	db $bd, $ce, $ff, $ff, $01, $ff, $ff, $01, $ff, $f1, $f7, $f9, $37, $f9, $f7, $39
	db $f7, $39, $ff, $ff, $80, $ff, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0
	db $bf, $c0, $ff, $ff, $01, $ff, $ff, $01, $ff, $31, $f7, $39, $f7, $39, $f7, $39
	db $f7, $39, $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0
	db $bf, $cf, $ff, $ff, $01, $ff, $ff, $01, $ff, $f1, $f7, $f9, $37, $f9, $f7, $39
	db $f7, $d0, $f9, $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf
	db $c0, $bf, $c3, $f7, $39, $f7, $39, $f7, $39, $f7, $39, $f7, $39, $e7, $19, $ff
	db $01, $ff, $ff, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $11, $ff, $90, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $09, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $bd
	db $ce, $bd, $ce, $bd, $ce, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $ff, $ff, $f7
	db $39, $f7, $39, $f7, $39, $f7, $f9, $f7, $f9, $07, $f9, $ff, $01, $ff, $ff, $bf
	db $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $ff, $ff, $f7
	db $39, $f7, $39, $f7, $39, $f7, $39, $f7, $39, $e7, $19, $ff, $01, $ff, $ff, $bf
	db $cf, $bc, $cf, $bd, $ce, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $ff, $ff, $f7
	db $f9, $07, $f9, $ff, $01, $ff, $f1, $a6, $f7, $f9, $07, $f9, $ff, $01, $ff, $ff
	db $bf, $c3, $be, $c1, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $ff, $ff
	db $f7, $f9, $37, $f9, $f7, $39, $f7, $f9, $f7, $f9, $07, $f9, $ff, $01, $04, $ff
	db $ff, $80, $ff, $bf, $c0, $bf, $cc, $bd, $ce, $bd, $ce, $bd, $ce, $bf, $cf, $ff
	db $ff, $01, $ff, $ff, $01, $ff, $31, $f7, $39, $f7, $39, $f7, $39, $f7, $f9, $ff
	db $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $bc, $cf, $bd, $ce, $bf, $cf, $ff
	db $ff, $01, $ff, $ff, $01, $ff, $f1, $f7, $f9, $07, $f9, $ff, $01, $ff, $f1, $ff
	db $38, $c7, $7d, $92, $ff, $9e, $ff, $9e, $ff, $92, $ff, $c7, $7d, $ff, $38, $ff
	db $ef, $18, $ff, $4c, $ff, $4c, $ff, $4c, $ff, $4c, $ff, $18, $ff, $ff, $ef, $ff
	db $f7, $4d, $ff, $c5, $ff, $c5, $ff, $c9, $ff, $c9, $ff, $4d, $ff, $ff, $fb, $ff
	db $00, $ff, $00, $ff, $0f, $fc, $13, $f0, $2c, $e3, $3b, $e7, $34, $e7, $34, $ff
	db $89, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $03, $ff, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $f0, $0f, $f8, $07, $fc, $c7, $f4, $e7, $34, $e7, $34
	db $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34
	db $e7, $34, $e7, $34, $e3, $3b, $e0, $2f, $f0, $10, $ff, $0f, $ff, $00, $ff, $00
	db $e7, $34, $e7, $34, $e7, $d4, $07, $f4, $0f, $08, $ff, $f0, $ff, $00, $ff, $00
	db $e5, $8b, $a5, $d3, $a5, $d3, $c9, $a5, $d1, $8b, $a1, $d3, $a1, $cd, $e9, $85
	db $38, $b8, $10, $f0, $00, $ff, $01, $be, $02, $bd, $12, $2d, $2a, $95, $06, $39
	db $0c, $2d, $00, $12, $8c, $73, $08, $f7, $00, $ff, $43, $bc, $0b, $f4, $16, $e9
	db $bf, $cf, $b8, $c7, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $a2, $bf, $c0, $ff
	db $ff, $f7, $f9, $37, $f9, $f7, $39, $f7, $39, $f7, $39, $e7, $19, $ff, $01, $ff
	db $ff, $bf, $cf, $b8, $c7, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $04
	db $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $bf, $c0
	db $ff, $00, $ff, $01, $ff, $01, $ff, $01, $ff, $19, $e7, $34, $c3, $7a, $81, $fd
	db $ff, $00, $ff, $e0, $1f, $d8, $07, $f4, $e3, $fa, $f3, $1e, $f9, $0d, $f9, $0f
	db $e7, $ff, $e7, $2c, $f3, $1e, $f1, $17, $f8, $0b, $fe, $06, $ff, $01, $ff, $00
	db $f9, $0f, $f9, $0d, $f3, $1e, $e3, $fa, $07, $f4, $1f, $d8, $ff, $e0, $ff, $00
	db $38, $38, $74, $4c, $ea, $96, $ea, $96, $ea, $96, $ea, $96, $74, $4c, $38, $38
	db $ff, $42, $bd, $e7, $db, $7e, $e7, $3c, $e7, $3c, $db, $7e, $bd, $e7, $ff, $42
	db $ff, $fe, $83, $fe, $9f, $fc, $83, $fa, $f3, $7e, $f3, $7e, $83, $fa, $ff, $fc
	db $ff, $9d, $7c, $83, $ba, $93, $fe, $93, $fe, $93, $fe, $93, $fe, $83, $ba, $ff
	db $7c, $ff, $ff, $99, $66, $e7, $08, $10, $26, $88, $51, $07, $c8, $00, $37, $04
	db $ff, $ff, $fd, $83, $c5, $81, $c5, $99, $cd, $91, $fd, $81, $81, $c1, $ff, $ff
	db $1e, $a1, $3c, $c3, $3e, $41, $bb, $87, $b7, $cf, $2f, $5e, $3c, $5f, $1b, $ff
	db $4f, $b0, $ff, $00, $fb, $fc, $fd, $fe, $7e, $87, $5f, $e3, $fe, $81, $af, $50
	db $07, $87, $00, $0b, $87, $78, $0c, $f3, $08, $f7, $20, $df, $05, $fa, $03, $fc
	db $00, $ed, $03, $c7, $29, $d7, $92, $6d, $27, $d8, $57, $a8, $cf, $30, $af, $51
	db $1c, $5f, $00, $ef, $eb, $97, $ff, $8f, $fe, $1d, $f7, $38, $ff, $66, $7f, $8c
	db $20, $a2, $00, $81, $6b, $97, $b6, $cf, $de, $ed, $fe, $61, $bf, $70, $ff, $76
	db $07, $c7, $00, $84, $91, $6e, $00, $ff, $43, $bc, $cb, $37, $b7, $4f, $4e, $bf
	db $10, $ff, $9a, $00, $b1, $62, $9d, $d5, $2b, $c7, $3b, $df, $e7, $ee, $ff, $ff
	db $7c, $00, $ff, $3e, $be, $ff, $ff, $ed, $f3, $bf, $c0, $ef, $10, $bf, $60, $7f
	db $c0, $30, $b7, $01, $ee, $bf, $c1, $ff, $e1, $7e, $f1, $b7, $78, $dd, $3b, $ea
	db $1d, $1e, $ff, $27, $db, $3f, $c6, $3b, $c5, $3f, $c3, $3f, $c0, $3f, $c0, $3f
	db $41, $ff, $a0, $df, $60, $bf, $c0, $ff, $80, $ff, $00, $ff, $00, $6f, $90, $7f
	db $90, $cf, $3d, $fd, $02, $ff, $04, $fe, $01, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $fd, $63, $5b, $e7, $be, $c7, $f5, $0e, $ff, $0c, $ed, $1f, $fb, $1f, $dd
	db $3e, $b5, $ce, $7e, $87, $fb, $07, $fb, $07, $ff, $c3, $bf, $c3, $7d, $a3, $ff
	db $c0, $ff, $7b, $e7, $ff, $f3, $dd, $e3, $f3, $bd, $7e, $e9, $9f, $f0, $7f, $e0
	db $f7, $c8, $bf, $7f, $6b, $f7, $dd, $e3, $bf, $d1, $d6, $e9, $6f, $d8, $df, $b0
	db $bb, $64, $bf, $7e, $76, $ff, $ff, $e3, $dd, $f3, $ff, $e1, $6e, $d9, $7f, $b0
	db $f7, $6c, $4f, $b0, $fd, $03, $f7, $0f, $ef, $1e, $df, $3c, $fb, $3d, $fe, $fb
	db $77, $fe, $ff, $03, $f6, $f9, $5f, $b8, $ff, $0c, $f7, $8e, $7d, $82, $ef, $10
	db $fe, $a1, $fa, $1d, $ff, $1f, $f7, $0f, $ff, $00, $ff, $03, $b7, $79, $7b, $fc
	db $cf, $fc, $ff, $e0, $ff, $c0, $bf, $c0, $f7, $38, $fb, $1d, $7f, $81, $ed, $1f
	db $be, $7f, $ff, $1c, $db, $3f, $f7, $3c, $ba, $7f, $fd, $7e, $df, $6c, $f7, $18
	db $dd, $ff, $3e, $79, $bf, $ff, $1b, $ff, $3e, $fd, $3b, $a7, $7e, $ff, $6d, $ad
	db $5b, $f3, $1e, $ff, $80, $af, $50, $df, $b0, $bf, $60, $f7, $c8, $ff, $90, $bf
	db $61, $7f, $c3, $ef, $1c, $ff, $0c, $ff, $0c, $f5, $0e, $ff, $06, $ff, $06, $bf
	db $c6, $fb, $c6, $3d, $43, $3f, $c3, $3b, $c7, $3e, $47, $be, $c7, $bf, $87, $3b
	db $47, $bf, $c3, $df, $30, $57, $b8, $9f, $78, $3f, $d8, $9e, $7f, $2f, $df, $5e
	db $bf, $f9, $fe, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $01, $f3, $3d, $f6, $3b, $db, $3c, $ed, $1f, $f7, $0f, $fc, $03, $fd
	db $03, $bf, $c7, $be, $c1, $fd, $43, $b7, $cf, $6f, $9f, $fe, $ff, $e7, $ff, $db
	db $e6, $89, $dd, $e2, $df, $30, $ff, $60, $bb, $cc, $9e, $03, $ff, $ff, $79, $ff
	db $df, $3c, $bb, $7c, $6f, $d8, $f7, $38, $6f, $f8, $3e, $ff, $ef, $ff, $cd, $ff
	db $ff, $1c, $f6, $0f, $af, $58, $de, $31, $b1, $7f, $3f, $ff, $ff, $fe, $db, $fc
	db $bf, $78, $d5, $3e, $3f, $c7, $f7, $0f, $7f, $8f, $ef, $9f, $bf, $cf, $ef, $df
	db $d8, $e7, $5f, $e0, $df, $e2, $ff, $e2, $fc, $e3, $ff, $e1, $dd, $e3, $df, $e1
	db $1e, $e1, $ff, $00, $bd, $c3, $3f, $47, $3e, $cf, $37, $d8, $1f, $e0, $39, $c6
	db $3b, $c7, $3f, $c3, $ef, $ff, $bb, $c7, $6f, $f0, $77, $f8, $db, $3c, $d7, $2e
	db $7d, $83, $de, $e1, $7f, $83, $db, $e7, $b7, $7f, $ff, $0f, $fd, $1f, $df, $3c
	db $fc, $3b, $30, $ff, $fd, $c3, $bf, $c0, $7f, $80, $7f, $80, $bf, $9d, $c0, $ff
	db $c0, $df, $60, $7f, $e0, $7f, $a0, $ff, $00, $ff, $00, $fe, $01, $fb, $07, $f7
	db $0f, $ee, $1f, $fd, $1e, $ef, $18, $ff, $00, $ff, $00, $04, $ff, $ff, $8d, $f3
	db $d1, $2e, $80, $7f, $fb, $04, $ff, $00, $ff, $00, $bf, $c0, $f7, $f8, $fd, $fe
	db $3f, $ff, $e7, $1f, $ef, $10, $ff, $00, $ff, $00, $ff, $00, $f3, $0f, $df, $3f
	db $fd, $fe, $cb, $f4, $fb, $07, $ef, $1f, $dd, $3e, $bb, $7c, $fe, $f9, $fd, $f2
	db $6b, $f5, $fd, $03, $fb, $fc, $47, $be, $08, $f7, $17, $e8, $b7, $78, $ff, $fc
	db $b1, $ce, $7f, $80, $37, $cf, $3d, $cf, $3f, $df, $36, $fb, $25, $bf, $4b, $fd
	db $0e, $b3, $3f, $47, $7b, $87, $ff, $81, $7f, $a0, $cf, $78, $9f, $f0, $ff, $a0
	db $bf, $40, $df, $e0, $ff, $c1, $df, $e0, $ef, $f0, $7f, $f0, $ff, $78, $f7, $38
	db $cf, $30, $ff, $00, $d0, $ef, $fc, $fb, $bf, $7f, $e7, $1f, $fd, $ff, $03, $ff
	db $00, $fb, $07, $f7, $0f, $5f, $e0, $df, $e0, $ff, $c0, $bf, $c0, $ff, $00, $ff
	db $00, $ff, $00, $fe, $01, $ff, $00, $ff, $00, $fe, $01, $ff, $01, $fd, $03, $fe
	db $01, $ff, $00, $ef, $f0, $3e, $c1, $3f, $40, $bf, $c0, $bf, $80, $bf, $c0, $3f
	db $40, $3f, $c1, $3f, $43, $f7, $f8, $ef, $1c, $fc, $03, $fe, $01, $fd, $02, $7b
	db $fc, $ff, $ff, $cf, $ff, $7c, $fb, $dd, $fe, $ec, $9f, $f7, $0e, $fe, $07, $ff
	db $07, $fb, $07, $bf, $c3, $ff, $20, $37, $f8, $9b, $7c, $3f, $df, $07, $ff, $8d
	db $73, $42, $bd, $81, $fe, $ff, $1c, $fd, $1e, $ee, $1f, $77, $8f, $ff, $ff, $fe
	db $ff, $d0, $2f, $42, $bd, $83, $7c, $56, $a9, $fc, $03, $f8, $07, $e9, $b0, $cf
	db $e2, $1d, $00, $ff, $39, $c6, $87, $78, $07, $f8, $2b, $d4, $ab, $54, $12, $ed
	db $85, $7a, $a4, $5b, $8c, $73, $d0, $2f, $40, $bf, $92, $6d, $2a, $d5, $9a, $65
	db $30, $cf, $50, $af, $e2, $1d, $ff, $03, $d2, $2f, $ee, $17, $ce, $37, $ab, $57
	db $0d, $f3, $b5, $4b, $3f, $c3, $ff, $00, $fe, $01, $7f, $80, $7f, $80, $78, $87
	db $ff, $81, $fd, $83, $7e, $81, $3b, $cf, $37, $cb, $3d, $c3, $3f, $c1, $3e, $41
	db $3f, $00, $bf, $80, $bf, $c0, $f4, $fb, $7f, $bf, $ef, $9f, $bb, $d6, $d7, $ec
	db $ed, $fb, $7b, $ff, $ff, $77, $fe, $03, $ff, $9c, $7d, $83, $b6, $69, $6f, $d0
	db $fd, $e3, $eb, $f7, $ff, $f7, $fd, $0e, $9b, $fc, $fe, $f1, $ff, $e1, $fd, $03
	db $df, $e3, $fb, $e7, $ee, $f7, $00, $ff, $00, $ff, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $ff, $0f, $fc, $ff, $fc, $ff, $fc, $ff, $fc
	db $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc
	db $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $00, $ff, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $00, $1f, $1f, $3f, $2f, $70
	db $5f, $e0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0
	db $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $07, $fc, $ff, $fc, $ff, $00
	db $ff, $00, $e7, $18, $db, $3c, $bd, $7e, $66, $ff, $66, $ff, $7e, $ff, $66, $ff
	db $18, $e7, $ef, $10, $97, $78, $7b, $a4, $fc, $a7, $78, $e0, $3f, $ff, $3f, $ff
	db $00, $ff, $00, $d5, $3f, $15, $ff, $fe, $ff, $11, $fe, $93, $7c, $55, $fe, $52
	db $ff, $92, $ff, $c7, $38, $bb, $7c, $c3, $3c, $9d, $7e, $00, $04, $ff, $9c, $00
	db $ff, $00, $81, $7e, $7e, $ff, $42, $ff, $82, $ff, $3d, $fe, $c5, $3e, $cb, $3c
	db $b7, $78, $ff, $00, $ff, $18, $ff, $38, $df, $38, $00, $04, $ff, $9c, $00, $ff
	db $00, $1f, $e0, $ed, $f2, $1a, $e7, $fa, $07, $fa, $07, $f5, $0e, $0b, $fc, $f7
	db $f8, $c3, $3c, $bd, $7e, $cb, $3c, $bd, $7e, $00, $04, $ff, $9c, $00, $ff, $00
	db $f5, $0f, $c0, $3f, $3e, $ff, $c9, $fe, $17, $f8, $d7, $38, $e9, $1e, $f6, $0f
	db $ff, $00, $b3, $4c, $55, $ee, $5a, $e7, $00, $04, $ff, $9c, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f7
	db $08, $ab, $5c, $5d, $fe, $6a, $ff, $00, $04, $ff, $9c, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fb, $04
	db $f5, $0e, $eb, $1c, $d7, $38, $00, $04, $ff, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $83, $7c, $7d
	db $fe, $8b, $7c, $9d, $7e, $00, $f8, $f8, $fc, $f4, $0e, $fa, $07, $fe, $03, $fe
	db $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe
	db $03, $fe, $03, $fe, $03, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f
	db $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $5f, $e0, $2f
	db $70, $1f, $3f, $00, $1f, $79, $fe, $aa, $77, $a2, $7f, $dd, $3e, $ff, $00, $c3
	db $3c, $bd, $7e, $c2, $3f, $f5, $0e, $bb, $44, $41, $fe, $be, $7f, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $62, $ff, $9a, $67, $ff, $c5, $3e, $bb, $7c, $bf, $40
	db $5d, $e2, $52, $ef, $ad, $7e, $b3, $7c, $4f, $f0, $41, $fe, $be, $7f, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $ff, $18, $ff, $18, $ff, $18, $bd, $7e, $f5, $0f
	db $da, $25, $25, $fe, $f2, $ff, $2a, $ff, $49, $fe, $8b, $fc, $37, $f8, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $cb, $3c, $bb, $7c, $4d, $fe, $b3, $7c, $f5, $0f
	db $c0, $3f, $3e, $ff, $c9, $fe, $17, $f8, $d7, $38, $e9, $1e, $f6, $0f, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $5a, $e7, $42, $ff, $55, $fa, $af, $70, $ef, $10
	db $97, $78, $7d, $fe, $89, $7e, $be, $7f, $85, $7e, $43, $fc, $bd, $7e, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $d2, $ff, $b2, $ff, $ff, $aa, $f7, $d5, $6e, $c3
	db $3c, $bd, $7e, $cb, $3c, $bd, $7e, $cb, $3c, $bb, $7c, $4d, $fe, $b3, $7c, $ff
	db $00, $ff, $00, $ff, $ff, $00, $ff, $af, $70, $d7, $38, $eb, $1c, $f5, $0e, $f7
	db $08, $89, $7e, $7e, $ff, $89, $7e, $bb, $7c, $ab, $7c, $9b, $7c, $77, $f8, $ff
	db $00, $ff, $00, $ff, $ff, $00, $ff, $62, $ff, $9a, $ff, $2a, $ff, $dd, $3e, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $ff, $00, $ff, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe
	db $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fa
	db $07, $f4, $0e, $f8, $fc, $00, $f8, $00, $1f, $9f, $1f, $3f, $2f, $70, $5f, $e0
	db $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0
	db $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $00, $04, $ff, $9c, $00, $ff, $00, $03
	db $fc, $fd, $fe, $c3, $fc, $fd, $fe, $06, $ff, $fe, $07, $86, $ff, $7d, $fe, $ea
	db $17, $d5, $3f, $aa, $5f, $55, $ee, $00, $04, $ff, $9c, $00, $ff, $00, $c7, $38
	db $bb, $7c, $4d, $fe, $d7, $ee, $d7, $ee, $d7, $ee, $65, $fe, $bb, $7c, $11, $fe
	db $fe, $ff, $02, $ff, $e5, $1e, $00, $04, $ff, $9c, $00, $ff, $00, $81, $7e, $7e
	db $ff, $82, $7f, $fa, $07, $fa, $07, $fa, $07, $82, $7f, $7e, $ff, $d7, $38, $97
	db $78, $57, $f8, $55, $fa, $00, $04, $ff, $9c, $00, $ff, $00, $fa, $07, $f5, $0e
	db $cb, $3c, $37, $f8, $cb, $fc, $2b, $dc, $eb, $1c, $eb, $1c, $f5, $0f, $da, $25
	db $25, $fe, $f2, $ff, $00, $04, $ff, $9c, $00, $ff, $00, $1f, $e0, $ed, $f2, $1a
	db $e7, $fa, $07, $fa, $07, $f5, $0e, $0b, $fc, $f7, $f8, $e7, $18, $db, $3c, $bb
	db $7c, $db, $3c, $00, $04, $ff, $ff, $00, $ff, $00, $f5, $0f, $c2, $3d, $bd, $7e
	db $c2, $3f, $f5, $0e, $bb, $44, $41, $fe, $be, $7f, $c3, $3c, $bd, $7e, $cb, $3c
	db $bd, $7e, $07, $fc, $ff, $fc, $ff, $00, $ff, $00, $bf, $40, $5d, $e2, $52, $ef
	db $ad, $7e, $b3, $7c, $4f, $f0, $41, $fe, $be, $7f, $ff, $00, $b3, $4c, $55, $ee
	db $5a, $e7, $e0, $3f, $ff, $3f, $ff, $00, $ff, $00, $ff, $00, $a1, $5e, $5e, $ff
	db $41, $fe, $5f, $e0, $47, $f8, $49, $fe, $b6, $6f, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $00, $f8, $f8, $fc, $f4, $0e, $fa, $07, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $7f, $c0, $7f, $c0, $fc, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f
	db $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $5f, $e0, $2f, $70, $1f
	db $3f, $00, $1f, $55, $ee, $ba, $c7, $ba, $c7, $7a, $87, $f7, $08, $ab, $5c, $5d
	db $fe, $6a, $ff, $d2, $ff, $b2, $ff, $aa, $f7, $d5, $6e, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $db, $3c, $35, $fe, $d2, $ff, $15, $fa, $fb, $04, $f5, $0e, $eb
	db $1c, $d7, $38, $af, $70, $d7, $38, $eb, $1c, $f5, $0e, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $52, $ff, $52, $ff, $55, $fe, $9b, $fc, $c7, $38, $bb, $7c, $c3
	db $3c, $ad, $7e, $52, $ff, $6a, $f7, $82, $7f, $dd, $3e, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $10, $00, $90, $ff, $ff, $eb, $9c, $cc, $bf, $cf, $bf, $c8, $b8
	db $bf, $ff, $bf, $e0, $b0, $ef, $10, $00, $03, $c3, $82, $00, $00, $03, $c3, $82
	db $00, $00, $03, $ff, $9b, $00, $00, $ff, $b0, $ef, $a0, $ff, $e0, $ff, $20, $3f
	db $20, $3f, $20, $3f, $20, $3f, $10, $1f, $08, $0f, $04, $07, $02, $03, $01, $01
	db $08, $00, $8d, $ff, $ff, $db, $a5, $bd, $c3, $bd, $db, $bd, $db, $bd, $c3, $a5
	db $05, $ff, $83, $00, $ff, $00, $03, $ff, $08, $00, $03, $ff, $da, $81, $ff, $81
	db $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81
	db $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $3f, $3f, $3d, $27, $3d, $27
	db $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27
	db $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3f, $3f, $38, $38, $28, $38, $28, $38
	db $28, $38, $28, $38, $28, $38, $28, $38, $28, $38, $28, $38, $28, $38, $28, $38
	db $28, $38, $28, $38, $28, $38, $28, $03, $38, $9e, $00, $00, $01, $01, $07, $06
	db $0f, $08, $1a, $17, $17, $1c, $1f, $18, $17, $1b, $1e, $13, $3f, $20, $7f, $40
	db $ff, $86, $f4, $8f, $6b, $5b, $30, $30, $04, $00, $ff, $fc, $fc, $aa, $76, $f5
	db $1b, $ff, $01, $ff, $01, $fd, $e7, $de, $e2, $ef, $59, $ff, $79, $fd, $13, $fa
	db $36, $7c, $a4, $08, $f8, $f0, $f0, $00, $00, $2a, $ff, $49, $fe, $8b, $fc, $37
	db $f8, $f3, $0c, $ad, $5e, $55, $fe, $d5, $fe, $65, $fe, $55, $ee, $d5, $ee, $5a
	db $e7, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $db, $3c, $db, $3c, $db, $3c, $bd
	db $7e, $c3, $3c, $bd, $7e, $cb, $3c, $bd, $7e, $cb, $3c, $bb, $7c, $4d, $fe, $b3
	db $7c, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $cb, $3c, $bb, $7c, $4d, $fe, $b3
	db $7c, $f7, $08, $89, $7e, $7e, $ff, $89, $7e, $bb, $7c, $ab, $7c, $9b, $7c, $77
	db $f8, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $5a, $ff, $e7, $42, $ff, $55, $fa
	db $af, $70, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $fa, $07, $f4, $0e, $f8, $fc, $00, $f8, $00, $1f, $1f, $3f, $2f, $70
	db $5f, $e0, $7f, $c0, $7b, $c4, $74, $cf, $7d, $cf, $76, $cf, $75, $ce, $7d, $ce
	db $74, $cf, $78, $c7, $77, $cf, $76, $cf, $77, $cf, $81, $00, $04, $ff, $9c, $00
	db $ff, $00, $ff, $00, $3c, $c3, $d2, $ef, $2f, $ff, $a4, $7f, $a4, $7f, $2a, $fd
	db $d3, $ef, $1d, $e3, $c1, $ff, $6f, $ff, $c1, $ff, $00, $04, $ff, $9c, $00, $ff
	db $00, $7f, $80, $bf, $c0, $5f, $e0, $2e, $f1, $a9, $f7, $96, $ef, $b8, $c7, $7d
	db $83, $58, $f7, $57, $ff, $e4, $ff, $18, $ef, $00, $04, $ff, $9c, $00, $ff, $00
	db $fe, $01, $f9, $07, $f7, $0f, $7a, $87, $b4, $cf, $54, $ef, $59, $ef, $ba, $cd
	db $11, $ee, $ee, $ff, $21, $fe, $2f, $f0, $00, $04, $ff, $9c, $00, $ff, $00, $fb
	db $04, $75, $8e, $d5, $ee, $1a, $e7, $eb, $f7, $14, $ef, $14, $ef, $eb, $f7, $fe
	db $01, $d9, $27, $a7, $7f, $aa, $77, $00, $04, $ff, $9c, $00, $ff, $00, $ff, $00
	db $dc, $23, $2b, $f7, $dc, $e3, $3f, $c0, $fb, $04, $14, $ef, $eb, $f7, $fd, $02
	db $3a, $c7, $db, $e7, $16, $ef, $00, $04, $ff, $9c, $00, $ff, $00, $fe, $01, $39
	db $c7, $d6, $ef, $29, $f7, $53, $ef, $bc, $4f, $12, $ed, $ed, $f3, $db, $24, $25
	db $fe, $a5, $fe, $15, $ee, $00, $04, $ff, $ff, $00, $ff, $00, $3f, $c0, $dc, $e3
	db $b3, $cf, $3c, $cf, $d1, $ef, $2d, $f3, $2e, $f1, $df, $e0, $ff, $00, $fc, $03
	db $f3, $0f, $fc, $0f, $00, $f8, $f8, $fc, $f4, $0e, $fa, $07, $5e, $f3, $0e, $f3
	db $ee, $f3, $9e, $e3, $7e, $83, $7e, $83, $9e, $e3, $6e, $f3, $9e, $63, $6e, $f3
	db $de, $e3, $be, $c3, $76, $cf, $76, $cf, $77, $cf, $70, $cf, $7f, $c0, $7c, $c3
	db $7b, $c7, $7c, $c3, $7f, $c0, $7b, $c4, $74, $cf, $7b, $c7, $5f, $e0, $2f, $70
	db $1f, $3f, $00, $1f, $69, $f7, $65, $ff, $c5, $ff, $19, $ef, $fe, $01, $39, $c7
	db $d7, $ef, $2a, $f7, $54, $ef, $b4, $4f, $19, $ef, $ea, $fd, $ff, $00, $ff, $00
	db $ff, $ff, $00, $ff, $33, $cf, $5c, $e3, $ff, $2c, $f3, $2b, $f7, $fc, $03, $7b
	db $87, $dc, $e3, $17, $ef, $e8, $f7, $1d, $e3, $1a, $e7, $e5, $fe, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $df, $e0, $5f, $e0, $b0, $cf, $7f, $8f, $7f, $80, $bc
	db $c3, $73, $8f, $dc, $ef, $b1, $cf, $7d, $83, $9e, $e1, $6f, $f0, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $a7, $7f, $59, $e7, $ba, $c7, $7b, $87, $9f, $60, $6f
	db $f0, $de, $e1, $bd, $c3, $7a, $87, $7d, $83, $9e, $e1, $6f, $f0, $ff, $00, $ff
	db $00, $ff, $c3, $7e, $c3, $6b, $f7, $96, $ef, $1a, $ef, $e6, $ff, $be, $41, $59
	db $e7, $b7, $cf, $7a, $87, $f4, $0f, $74, $8f, $b5, $cf, $5a, $ed, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $d5, $ee, $25, $fd, $fe, $a4, $7f, $5b, $e7, $5e, $f1
	db $29, $d7, $d7, $ef, $18, $e7, $ef, $f0, $1b, $e4, $14, $ef, $eb, $f7, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $f1, $0f, $bd, $43, $5e, $e1, $bf, $c0, $ff, $00
	db $3b, $c4, $d5, $ee, $b5, $ce, $55, $ee, $54, $ef, $35, $cf, $da, $e7, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $7e, $83, $7e, $83, $9e, $e3, $6e, $f3, $fe, $03
	db $3e, $c3, $5e, $e3, $ae, $73, $ae, $73, $2e, $f3, $5e, $a3, $fe, $03, $fa, $07
	db $f4, $0e, $f8, $fc, $00, $f8, $00, $01, $01, $03, $02, $07, $05, $0e, $0b, $1c
	db $17, $38, $2f, $70, $3f, $7c, $07, $7c, $07, $0c, $07, $0c, $07, $0c, $07, $0c
	db $07, $0c, $07, $0c, $07, $0c, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00
