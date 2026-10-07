INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $050", ROMX[$4000], BANK[$50]

BankNumber_50::
	db $50

FarTable_50::
	dw Call_50_5DC9
	dw Call_50_5E21
	dw Call_50_5E49
	dw Call_50_6053
	dw Call_50_7C4D
	dw Call_50_768E
	dw Call_50_79EB
	dw Call_50_59EB
	dw Call_50_5B58
	dw Call_50_5C78
	dw Call_50_5CB4

Call_50_4017::
	ld a, [$d9f4]
	rst $00

JumpTable_50_401B::
	dw Jump_50_4031
	dw Jump_50_40ED
	dw Jump_50_4114
	dw Jump_50_41EE
	dw Jump_50_4215
	dw Jump_50_425E
	dw Jump_50_426E
	dw Jump_50_4301
	dw Jump_50_43A7
	dw Jump_50_41E0
	dw Jump_50_59D6

Jump_50_4031::
	ld hl, far_Call_55_479B
	rst $10
	xor a
	ld hl, $d9f4
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$d9f8], a
	ld a, h
	ld [$d9f9], a
	ld a, $ff
	ld [$c1c0], a
	ld bc, $0300
	ld a, [$c86c]
	or a
	jr z, jr_050_4062

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4062

	ld bc, $0304

jr_050_4062:
	ld d, $00

jr_050_4064:
	ld a, c
	call Call_50_5B07
	jr c, jr_050_4081

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	jr nz, jr_050_4081

	inc d
	ld a, [$c1c0]
	cp $ff
	jr nz, jr_050_4081

	ld a, c
	ld [$c1c0], a

jr_050_4081:
	inc c
	dec b
	jr nz, jr_050_4064

	ld a, d
	ld [$db88], a
	ld bc, $0404
	ld a, [$c86c]
	or a
	jr z, jr_050_409c

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_409c

	ld bc, $0400

jr_050_409c:
	ld d, $00

jr_050_409e:
	ld a, c
	call Call_2FA5
	jr c, jr_050_40a5

	inc d

jr_050_40a5:
	inc c
	dec b
	jr nz, jr_050_409e

	ld a, d
	ld [$db89], a
	ld b, $08
	ld hl, $c1cd

jr_050_40b2:
	set 7, [hl]
	inc hl
	dec b
	jr nz, jr_050_40b2

	ld hl, $d9f4
	inc [hl]
	ld bc, $0300
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_40c8

	ld c, $04

jr_050_40c8:
	ld a, c
	ld [$db61], a

jr_050_40cc:
	ld a, c
	call Call_2F76
	jr c, jr_050_40e8

	ld a, c
	ld hl, $db06
	call Call_2F6C
	ld a, [hli]
	and $0c
	jr z, jr_050_40e8

	ld a, [hl]
	and $f0
	jr z, jr_050_40e8

	ld a, c
	ld [$db61], a
	ret


jr_050_40e8:
	inc c
	dec b
	jr nz, jr_050_40cc

	ret


Jump_50_40ED::
	ld hl, far_Call_55_4774
	rst $10
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $6ed2
	call Call_50_75F0
	call Call_50_7848
	ld de, $419b
	ld a, [$c8da]
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_4114::
	ld a, [$c846]
	and $08
	jr z, jr_050_412d

	ld a, [$d9f3]
	or a
	jr nz, jr_050_4124

	inc a
	jr jr_050_4126

jr_050_4124:
	ld a, $03

jr_050_4126:
	ld [$d9f3], a
	call Call_50_7A87
	ret


jr_050_412d:
	ld de, $419b
	ld hl, $c8da
	call Call_50_782E
	ld a, [$c846]
	bit 0, a
	jr z, jr_050_419a

	ld a, $59
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	xor a
	ld [$d9f5], a
	ld hl, $c8da
	set 7, [hl]
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7
	ld a, [$c8da]
	and $0f
	cp $01
	ret nz

	ld hl, far_Call_55_479B
	rst $10
	xor a
	ld [$c8dd], a
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4176

	ld a, $04
	ld [$c8dd], a

jr_050_4176:
	call Call_50_41A5
	jr nc, jr_050_41b9

	ld a, [$c1c0]
	ld [$c8dd], a
	ld hl, $d9f5
	inc [hl]
	ld hl, $d9f5
	inc [hl]
	call Call_50_5708
	ld hl, $d9f5
	inc [hl]
	ld a, $81
	ld [$c8db], a
	ld a, $01
	ld [$d9fc], a

jr_050_419a:
	ret


	db $c1, $01, $01, $02, $c7, $01, $07, $02, $ff, $ff

Call_50_41A5::
	ld a, [$c8dd]
	ld c, a
	ld b, $03

jr_050_41ab:
	ld a, c
	call Call_50_5B07
	jr nc, jr_050_41b7

	inc c
	dec b
	jr nz, jr_050_41ab

	xor a
	ret


jr_050_41b7:
	scf
	ret


jr_050_41b9:
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $0002
	ld a, $09
	ld [$d9f4], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


Jump_50_41E0::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	ld a, $01
	ld [$d9f4], a
	ret


Jump_50_41EE::
	ld a, [$c846]
	and $08
	jr z, jr_050_4207

	ld a, [$d9f3]
	or a
	jr nz, jr_050_41fe

	inc a
	jr jr_050_4200

jr_050_41fe:
	ld a, $03

jr_050_4200:
	ld [$d9f3], a
	call Call_50_7A87
	ret


jr_050_4207:
	ld a, [$c8da]
	rst $00

JumpTable_50_420B::
	dw Jump_50_43C8
	dw Jump_50_441B
	dw Jump_50_4FBB
	dw Jump_50_5712
	dw Jump_50_4794

Jump_50_4215::
	ld a, [$d9f3]
	or a
	jr z, jr_050_4224

	ld a, $03
	ld [$d9f3], a
	call Call_50_7B8F
	ret


jr_050_4224:
	ld a, [$c86c]
	or a
	jr z, jr_050_4259

	ld a, $01
	ld [$c8c7], a
	ld de, $cacd
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_423c

	ld de, $cd21

jr_050_423c:
	ld hl, $c180
	call Call_0C80
	ld a, $f6
	call Call_50_6AA0
	call Call_50_774E
	call Call_50_794C
	call Call_50_79AE
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E

jr_050_4259:
	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_425E::
	ld a, [$c86c]
	or a
	jr z, jr_050_4269

	ld a, $01
	ld [$c873], a

jr_050_4269:
	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_426E::
	ld a, [$c86c]
	or a
	jp z, Jump_050_42fc

	ld a, [$c86e]
	cp $01
	ret nz

	ld de, $dd03
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4288

	ld de, $dd07

jr_050_4288:
	ld hl, $c1da
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, [$c899]
	ld [hli], a
	ld a, [$c89a]
	ld [hli], a
	ld a, [$c8da]
	ld [hli], a
	ld a, [$c8da]
	ld [hli], a
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_42af

	ld de, $dcec
	jr jr_050_42b2

jr_050_42af:
	ld de, $dcf4

jr_050_42b2:
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld de, $dd13
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_42d0

	ld de, $dd17

jr_050_42d0:
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, $10
	ld [$c871], a
	xor a
	ld [$c872], a
	ld hl, $c1da
	ld a, l
	ld [$c874], a
	ld a, h
	ld [$c875], a
	ld hl, $c1ea
	ld a, l
	ld [$c86f], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [$c873], a

Jump_050_42fc:
	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_4301::
	ld a, [$c86c]
	or a
	jp z, Jump_050_43a2

	ld a, [$c86e]
	cp $f0
	ret nz

	xor a
	ld [$c873], a
	ld de, $dd07
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_431f

	ld de, $dd03

jr_050_431f:
	ld hl, $c1ea
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc hl
	inc hl
	ld a, [hli]
	ld [$c1d5], a
	ld a, [hli]
	ld [$c1d6], a
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_4340

	ld de, $dcf4
	jr jr_050_4343

jr_050_4340:
	ld de, $dcec

jr_050_4343:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld de, $dd17
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4361

	ld de, $dd13

jr_050_4361:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_438a

	ld a, [$c899]
	ld [$c1ed], a
	ld a, [$c89a]
	ld [$c1ee], a
	ld a, [$c8da]
	ld [$c1ef], a
	ld a, [$c8da]
	ld [$c1d5], a
	jr jr_050_43a2

jr_050_438a:
	ld a, [$c1ed]
	ld [$c899], a
	ld a, [$c1ee]
	ld [$c89a], a
	ld a, [$c8da]
	ld [$c1f0], a
	ld a, [$c8da]
	ld [$c1d6], a

Jump_050_43a2:
jr_050_43a2:
	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_43A7::
	ld hl, far_Call_56_4485
	rst $10
	call Call_50_774E
	call Call_50_794C
	call Call_50_79AE
	call Call_50_768E
	xor a
	ld [$db88], a
	xor a
	ld [$c8c7], a
	xor a
	ld [$d9f4], a
	ld hl, $d9ec
	inc [hl]
	ret


Jump_50_43C8::
	ld a, [$d9f5]
	rst $00

JumpTable_50_43CC::
	dw Jump_50_43D0
	dw Jump_50_4411

Jump_50_43D0::
	ld hl, $d9f5
	inc [hl]
	ld a, [$db74]
	ld b, a
	ld c, $00
	ld hl, $dd13
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_43ed

	ld a, [$db75]
	ld b, a
	ld c, $04
	ld hl, $dd17

jr_050_43ed:
	ld a, c
	ld [$dd72], a
	ld a, b
	ld [$dd73], a

jr_050_43f5:
	ld a, c
	call Call_2FA5
	jr c, jr_050_43ff

	ld [hl], $01
	jr jr_050_4401

jr_050_43ff:
	ld [hl], $ff

jr_050_4401:
	inc hl
	inc c
	dec b
	jr nz, jr_050_43f5

	ld a, $ff
	ld [$db77], a
	ld a, $ff
	ld [$db78], a
	ret


Jump_50_4411::
	ld a, $04
	ld [$d9f4], a
	xor a
	ld [$d9f5], a
	ret


Jump_50_441B::
	ld a, [$d9f5]
	rst $00

JumpTable_50_441F::
	dw Jump_50_442B
	dw Jump_50_443A
	dw Jump_50_446E
	dw Jump_50_44B0
	dw Jump_50_456F
	dw Jump_50_4751

Jump_50_442B::
	ld a, $00
	ld [$d9f4], a
	ret


	db $21, $06, $55, $d7, $21, $f5, $d9, $34, $c9

Jump_50_443A::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld a, $00
	ld [$d9f4], a
	ld de, $6ed2
	call Call_50_75F0
	ret


	db $11, $1a, $6f, $cd, $f0, $75, $cd, $48, $78, $11, $aa, $44, $fa, $fc, $d9, $cb
	db $ff, $ea, $db, $c8, $cd, $0b, $79, $cd, $8e, $76, $21, $f5, $d9, $34, $c9

Jump_50_446E::
	ld de, $44aa
	ld hl, $c8db
	ld b, $02
	call Call_50_77F7
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_4487

	ld a, $01
	ld [$d9f4], a
	jr jr_050_44a9

jr_050_4487:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_44a9

	ld a, [$c8db]
	res 7, a
	ld [$d9fc], a
	ld a, $59
	call Call_1B2C
	ld hl, $d9f5
	inc [hl]
	ld a, [$db61]
	ld [$c8dd], a
	call Call_50_5708

Jump_050_44a9:
jr_050_44a9:
	ret


	db $c1, $01, $01, $02, $ff, $ff

Jump_50_44B0::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $cac2
	ld a, [$c8dd]
	call Call_50_5B07
	jr c, jr_050_453c

	ld a, [$c8dd]
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $96c0
	call Call_50_7700
	ld de, $74a3
	ld a, [$c8db]
	cp $81
	call z, Call_50_75F0
	ld de, $6f60
	call Call_50_75F0
	ld a, [$db73]
	cp $02
	call z, Call_50_4550
	ld a, [$d9fc]
	or a
	jr z, jr_050_4507

	ld a, [$c8dd]
	and $03
	or a
	jr z, jr_050_4511

	cp $01
	jr z, jr_050_451b

	ld a, $04
	ld [$da01], a
	ld a, [$da00]
	jr jr_050_4523

jr_050_4507:
	ld a, $01
	ld [$da01], a
	ld a, [$d9fd]
	jr jr_050_4523

jr_050_4511:
	ld a, $02
	ld [$da01], a
	ld a, [$d9fe]
	jr jr_050_4523

jr_050_451b:
	ld a, $03
	ld [$da01], a
	ld a, [$d9ff]

jr_050_4523:
	set 7, a
	ld [$c8dc], a
	call Call_50_7848
	ld de, $4715
	ld a, [$c8dc]
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f5
	inc [hl]
	ret


jr_050_453c:
	ld a, [$c8dd]
	inc a
	ld [$c8dd], a
	and $03
	cp $03
	jp c, Jump_50_44B0

	ld hl, $d9f5
	inc [hl]
	inc [hl]
	ret


Call_50_4550::
	ld a, [$c86c]
	or a
	ret nz

	ld hl, $0202
	call Call_50_758E
	ld de, $4567
	ld b, $08

jr_050_4560:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_050_4560

	ret


	db $8f, $90, $e0, $d6, $e3, $e0, $d6, $98

Jump_50_456F::
	ld de, $4715
	ld hl, $c8dc
	ld b, $04
	call Call_50_77F7
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_45f5

jr_050_4581:
	ld hl, far_Call_55_47C3
	rst $10
	ld a, [$c8db]
	cp $80
	jr z, jr_050_45d6

	ld a, [$c8dd]
	ld hl, $c1c0
	cp [hl]
	jr z, jr_050_45d6

	and $03
	or a
	jr z, jr_050_45d6

	ld a, [$c8dd]
	dec a
	ld [$c8dd], a
	call Call_50_5B07
	jr c, jr_050_4581

	ld a, [$c8dd]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_050_4581

	ld a, $00
	ld [hl], a
	ld a, [$c8dd]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld hl, $d9f5
	dec [hl]
	xor a
	ld [$c8dc], a
	jp Jump_050_4714


jr_050_45d6:
	call Call_50_4F6E
	ld hl, $d9f5
	dec [hl]
	dec [hl]
	dec [hl]
	jp Jump_050_4714


	db $3e, $00, $ea, $f5, $d9, $3e, $01, $ea, $f4, $d9, $cd, $08, $57, $c3, $ed, $40
	db $c3, $14, $47

jr_050_45f5:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_4714

	ld a, $59
	call Call_1B2C
	ld a, [$da01]
	ld hl, $d9fc
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c8dc]
	res 7, a
	ld [hl], a
	cp $03
	jp z, Jump_050_471f

	ld a, [$c8db]
	cp $80
	jr z, jr_050_466d

Call_50_4620::
	ld a, [$c8dd]
	ld de, $dd13
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, $01
	ld [de], a
	ld a, [$c8dd]
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c8dc]
	ld [hl], a
	res 7, [hl]
	ld a, [hl]
	call Call_50_473D
	ld a, [$c8dd]
	inc a
	ld [$c8dd], a
	push af
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_4659

	ld hl, $db74
	jr jr_050_465c

jr_050_4659:
	ld hl, $db75

jr_050_465c:
	pop af
	and $03
	cp [hl]
	jr z, Call_50_46C6

	ld hl, $d9f5
	dec [hl]
	xor a
	ld [$c8dc], a
	jp Jump_050_4714


jr_050_466d:
	ld a, [$db88]
	ld b, a
	ld c, $00
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_467c

	ld c, $04

jr_050_467c:
	ld a, c
	call Call_2F76
	jr c, jr_050_4699

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	jr z, jr_050_469c

	ld a, c
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01

jr_050_4699:
	inc c
	jr jr_050_467c

jr_050_469c:
	ld a, c
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $00
	jr nz, jr_050_46c2

	ld a, $01
	ld [hl], a
	ld a, c
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c8dc]
	res 7, a
	ld [hl], a
	ld a, [hl]
	call Call_50_473D

jr_050_46c2:
	inc c
	dec b
	jr nz, jr_050_467c

Call_50_46C6::
	ld hl, $d9f5
	inc [hl]
	ld bc, $0400
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_46d6

	ld c, $04

jr_050_46d6:
	ld a, c
	call Call_2FA5
	jr c, jr_050_4701

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	jr nz, jr_050_46fe

	ld de, $0003
	add hl, de
	ld a, [hli]
	and $3f
	jr nz, jr_050_46fe

	bit 2, [hl]
	jr nz, jr_050_46fe

	inc hl
	ld a, [hl]
	and $c0
	jr nz, jr_050_46fe

	bit 4, [hl]
	jr z, jr_050_4701

jr_050_46fe:
	call Call_50_4707

jr_050_4701:
	inc c
	dec b
	jr nz, jr_050_46d6

	jr jr_050_4714

Call_50_4707::
	ld a, c
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ret


Jump_050_4714:
jr_050_4714:
	ret


	db $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Jump_050_471f:
	call Call_50_5C2F
	jp z, Call_50_4620

	ld a, $04
	ld [$c8da], a
	xor a
	ld [$d9f7], a
	call Call_50_47BE
	ld a, [$db88]
	cp $01
	ret z

	ld a, $01
	ld [$c1c1], a
	ret


Call_50_473D::
	cp $03
	jr z, jr_050_4750

	push af
	ld hl, $c876
	ld a, [$c8dd]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a

jr_050_4750:
	ret


Jump_50_4751::
	call Call_50_4764
	call Call_50_774E
	ld hl, $d9f4
	inc [hl]
	ld a, $ff
	ld [$db77], a
	ld [$db78], a
	ret


Call_50_4764::
	ld a, [$c86c]
	or a
	jr z, jr_050_4775

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4775

	ld c, $04
	jr jr_050_4777

jr_050_4775:
	ld c, $00

jr_050_4777:
	ld b, $03

jr_050_4779:
	ld a, c
	call Call_2FA5
	jr c, jr_050_478f

	ld a, c
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr nz, jr_050_478f

	ld [hl], $01

jr_050_478f:
	inc c
	dec b
	jr nz, jr_050_4779

	ret


Jump_50_4794::
	ld a, [$d9f7]
	rst $00

JumpTable_50_4798::
	dw Call_50_47BE
	dw Jump_50_4816
	dw Jump_50_485E
	dw Jump_50_49AC
	dw Jump_50_4A2C
	dw Jump_50_4CD6
	dw Jump_50_4D23
	dw Jump_50_4DCD
	dw Jump_50_4E18
	dw Jump_50_4E8A
	dw Jump_50_4E98
	dw Jump_50_4EAB

jr_050_47b0:
	ld hl, $c8dd
	inc [hl]
	ld a, [$c8dd]
	and $03
	cp $03
	jp z, Jump_050_4f36

Call_50_47BE::
	ld a, [$c8dd]
	call Call_2F76
	jr c, jr_050_47b0

	ld a, [$c8dd]
	ld hl, $db06
	call Call_2F6C
	bit 2, [hl]
	jr nz, jr_050_47b0

	inc hl
	bit 4, [hl]
	jr nz, jr_050_47b0

	ld hl, far_Call_55_47AF
	rst $10
	ld hl, far_Call_55_479B
	rst $10
	xor a
	ld hl, $c8de
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [$dd72], a
	ld a, [$c8dd]
	ld hl, $c1cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 2, [hl]
	jr z, jr_050_47ff

	ld a, $01
	ld [$c8e0], a

jr_050_47ff:
	ld a, [hl]
	and $03
	ld [$c8df], a
	ld a, [hl]
	swap a
	and $03
	ld [$c8de], a
	ld hl, $d9f7
	inc [hl]
	xor a
	ld [$c1c1], a
	ret


Jump_50_4816::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld a, [$c1c1]
	or a
	jr nz, jr_050_4836

	ld hl, $cac2
	ld a, [$c8dd]
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $96c0
	call Call_50_7700

jr_050_4836:
	ld de, $6f49
	ld a, [$c8db]
	call Call_50_75F0
	ld de, $74ba
	call Call_50_75F0
	call Call_50_7848
	ld de, $496d
	ld a, [$c8de]
	set 7, a
	ld [$c8de], a
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f7
	inc [hl]
	ret


Jump_50_485E::
	ld de, $496d
	ld hl, $c8de
	ld b, $03
	call Call_50_77F7
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_48d5

jr_050_4870:
	ld a, [$c8db]
	cp $80
	jr nz, jr_050_48b7

	ld a, [$c8dd]
	and $03
	or a
	jr z, jr_050_48b7

	ld a, [$c8dd]
	dec a
	ld [$c8dd], a
	call Call_50_5B07
	jr c, jr_050_4870

	ld a, [$c8dd]
	ld hl, $db06
	call Call_2F6C
	bit 2, [hl]
	jr nz, jr_050_4870

	inc hl
	bit 4, [hl]
	jr nz, jr_050_4870

	ld a, [$c8dd]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $00
	ld [hl], a
	xor a
	ld [$d9f7], a
	call Call_50_4F6E
	call Call_50_47BE
	ret


jr_050_48b7:
	ld hl, far_Call_55_479B
	rst $10
	ld a, $81
	ld [$c8da], a
	ld a, $03
	ld [$d9f5], a
	ld a, [$c8dc]
	res 7, a
	ld [$c8dc], a
	xor a
	ld [$d9f7], a
	jp Jump_50_44B0


	db $c9

jr_050_48d5:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_496c

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	and $03
	swap a
	ld b, a
	ld a, [$c8dd]
	ld hl, $c1cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $0f
	or b
	ld [hl], a
	ld a, [$c8de]
	cp $81
	jr z, jr_050_4937

	cp $80
	jr z, jr_050_4918

	ld b, $8d
	ld a, [$c8dd]
	ld c, a

jr_050_490c:
	call Call_50_4F80
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	ret


jr_050_4918:
	ld a, $3a
	ld [$db8a], a
	ld a, [$c8dd]
	and $04
	xor $04
	call Call_50_4FA4
	ld a, b
	ld b, $3a
	cp $01
	jr z, jr_050_490c

	call Call_50_4F86
	ld a, $07
	ld [$d9f7], a
	ret


jr_050_4937:
	call Call_50_4975
	ld a, [$db55]
	or a
	jr z, jr_050_4945

	ld hl, $d9f7
	inc [hl]
	ret


jr_050_4945:
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $0202
	ld a, $09
	ld [$d9f7], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


Jump_050_496c:
	ret


	db $81, $01, $c1, $01, $01, $02, $ff, $ff

Call_50_4975::
	ld a, [$c8dd]
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [$db55], a
	ld bc, $0800

jr_050_498a:
	ld a, [hli]
	or a
	jr z, jr_050_49a7

	ld a, [hl]
	cp $37
	jr z, jr_050_49a2

	cp $38
	jr z, jr_050_49a2

	cp $7e
	jr z, jr_050_49a2

	ld a, [$db55]
	inc a
	ld [$db55], a

jr_050_49a2:
	inc hl
	inc c
	dec b
	jr nz, jr_050_498a

jr_050_49a7:
	ld a, c
	ld [$d9f6], a
	ret


Jump_50_49AC::
	call Call_50_49D8
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $74f4
	call Call_50_75F0
	call Call_50_7848
	ld de, $4cca
	ld b, $04
	ld a, [$d9f6]
	ld c, a
	ld hl, $c8df
	call Call_50_78E9
	call Call_50_768E
	ld hl, $d9f7
	inc [hl]
	ret


Call_50_49D8::
	ld a, [$c8dd]
	swap a
	ld de, $dc65
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [$c8e0]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call Call_50_49FE
	call Call_50_49FE
	call Call_50_49FE

Call_50_49FE::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_050_4a11

	ld a, $00
	ld [$c823], a
	ld a, $08
	ld [$c822], a
	jr jr_050_4a19

jr_050_4a11:
	ld [$c823], a
	ld a, $06
	ld [$c822], a

jr_050_4a19:
	ld de, $0901
	call Call_50_76C7
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	inc de
	ret


Jump_50_4A2C::
	ld de, $4cca
	ld hl, $c8df
	ld a, [$d9f6]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call Call_50_776E
	pop af
	ld hl, $c8e0
	cp [hl]
	jr z, jr_050_4a48

	call Call_50_49D8

jr_050_4a48:
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_4a65

	ld a, $01
	ld [$d9f7], a
	jp Jump_50_4816


jr_050_4a57:
	ld hl, $0302
	call Call_50_4CA4
	ret


jr_050_4a5e:
	ld hl, $0402
	call Call_50_4CA4
	ret


jr_050_4a65:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_4b97

	ld a, $59
	call Call_1B2C
	ld hl, $c8df
	res 7, [hl]
	ld a, [$c8e0]
	add a
	add a
	add [hl]
	ld [$db54], a
	add a
	ld hl, $dc65
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c8dd]
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call Call_50_4B98
	jr z, jr_050_4a57

	call Call_50_4BA4
	jr c, jr_050_4a5e

	call Call_50_4F86
	ld a, [hl]
	ld [$db4c], a
	ld [$db8a], a
	ld [$db4f], a
	ld a, [$c8dd]
	ld hl, $c1cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	ld b, a
	ld a, [$db54]
	or b
	ld [hl], a
	xor a
	ld [$db4d], a
	ld a, $02
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	call Call_50_56EB
	call Call_50_4BD1
	ret c

	ld a, [$db4c]
	bit 0, a
	jp z, Jump_050_4b6b

	bit 4, a
	jr z, jr_050_4af0

	ld a, $07
	ld [$d9f7], a
	ld a, [$c8dd]
	and $04
	xor $04
	jr jr_050_4afe

jr_050_4af0:
	bit 6, a
	jr nz, jr_050_4b54

	ld a, $05
	ld [$d9f7], a
	ld a, [$c8dd]
	and $04

jr_050_4afe:
	call Call_50_4FA4
	ld a, b
	cp $01
	ret nz

	ld a, [$db8a]
	cp $30
	jr z, jr_050_4b20

	cp $31
	jr z, jr_050_4b20

	cp $88
	jr z, jr_050_4b20

	call Call_50_4F95
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	ret


jr_050_4b20:
	call Call_50_4B26
	jr z, Call_50_4B4D

	ret


Call_50_4B26::
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4b34

	ld c, $04
	ld a, [$db75]
	jr jr_050_4b39

jr_050_4b34:
	ld c, $00
	ld a, [$db74]

jr_050_4b39:
	ld b, a
	ld d, $00

jr_050_4b3c:
	ld a, c
	call Call_2FA5
	jr nc, jr_050_4b44

	jr z, jr_050_4b45

jr_050_4b44:
	inc d

jr_050_4b45:
	inc c
	dec b
	jr nz, jr_050_4b3c

	ld a, d
	cp $01
	ret


Call_50_4B4D::
	ld hl, $fb00
	call Call_50_4CA4
	ret


jr_050_4b54:
	ld a, [$c8dd]
	ld c, a
	call Call_50_4F95
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10
	ret


Jump_050_4b6b:
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10
	ld a, [$c8dd]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db4c]
	ld b, a
	ld a, [$c8dd]
	and $04
	bit 4, b
	jr z, jr_050_4b96

	xor $04

jr_050_4b96:
	ld [hl], a

Jump_050_4b97:
	ret


Call_50_4B98::
	ld a, b
	cp $37
	jr z, jr_050_4ba3

	cp $38
	jr z, jr_050_4ba3

	cp $7e

jr_050_4ba3:
	ret


Call_50_4BA4::
	push bc
	ld a, b
	ld [$db4c], a
	xor a
	ld [$db4d], a
	ld a, $04
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	ld a, [$db4c]
	ld c, a
	ld b, $00
	ld a, [$c8dd]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call Call_2F45
	pop bc
	ret


Call_50_4BD1::
	ld a, [$db4f]
	cp $14
	jr z, jr_050_4c21

	cp $80
	jr z, jr_050_4c21

	cp $24
	jr z, jr_050_4c34

	cp $26
	jr z, jr_050_4c34

	cp $2a
	jr z, jr_050_4c34

	cp $32
	jr z, jr_050_4c2a

	cp $89
	jr z, jr_050_4c2a

	cp $8b
	jr z, jr_050_4c34

	cp $8f
	jr z, jr_050_4c34

	cp $95
	jr z, jr_050_4c2a

	cp $96
	jr z, jr_050_4c2a

	cp $39
	jr z, jr_050_4c3b

	cp $3f
	jr z, jr_050_4c72

	cp $51
	jr z, jr_050_4c40

	cp $52
	jr z, jr_050_4c40

	cp $53
	jr z, jr_050_4c40

	cp $83
	jr z, jr_050_4c64

	cp $88
	ret nc

	cp $84
	jr nc, jr_050_4c6d

	xor a
	ret


jr_050_4c21:
	ld a, [$c8dd]
	and $04
	xor $04
	jr jr_050_4c96

jr_050_4c2a:
	call Call_50_4B26
	jr nz, jr_050_4c34

	call Call_50_4B4D
	pop hl
	ret


jr_050_4c34:
	ld a, [$c8dd]
	and $04
	jr jr_050_4c96

jr_050_4c3b:
	ld a, [$c8dd]
	jr jr_050_4c96

jr_050_4c40:
	ld a, [$db88]
	ld b, a
	ld a, [$db8a]
	ld c, a
	push bc
	ld a, [$c8dd]
	ld [$db88], a
	ld a, [$db4f]
	ld [$db8a], a
	ld hl, far_Call_58_642C
	rst $10
	pop bc
	ld a, b
	ld [$db88], a
	ld a, c
	ld [$db8a], a
	jr jr_050_4c9a

jr_050_4c64:
	ld a, [$c8dd]
	and $04
	xor $04
	jr jr_050_4c96

jr_050_4c6d:
	ld a, [$c8dd]
	jr jr_050_4c96

jr_050_4c72:
	ld a, [$db88]
	ld b, a
	ld a, [$db8a]
	ld c, a
	push bc
	ld a, [$c8dd]
	ld [$db88], a
	ld a, [$db4f]
	ld [$db8a], a
	ld hl, far_Call_58_6379
	rst $10
	pop bc
	ld a, b
	ld [$db88], a
	ld a, c
	ld [$db8a], a
	jr jr_050_4c9a

jr_050_4c96:
	ld c, a
	call Call_50_4F95

jr_050_4c9a:
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	scf
	ret


Call_50_4CA4::
	push hl
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	pop hl
	ld a, $03
	ld [$d9f7], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


	db $2a, $02, $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Jump_50_4CD6::
	ld a, [$db8a]
	ld [$dd76], a
	ld a, a
	ld [$c1c2], a
	ld hl, far_Call_55_47FF
	rst $10
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $70c9
	call Call_50_75F0
	call Call_50_5BD7
	call Call_50_7848
	ld de, $5339
	ld a, [$c863]
	rlca
	and $04
	ld b, a
	call Call_2FA5
	jr nc, jr_050_4d10

	inc b
	ld a, b
	call Call_2FA5
	jr nc, jr_050_4d10

	inc b

jr_050_4d10:
	res 2, b
	set 7, b
	ld a, b
	ld [$dd72], a
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f7
	inc [hl]
	ret


Jump_50_4D23::
	ld de, $5339
	ld hl, $dd72
	ld a, [$c8dd]
	cp $04
	jr c, jr_050_4d35

	ld a, [$db75]
	jr jr_050_4d38

jr_050_4d35:
	ld a, [$db74]

jr_050_4d38:
	ld b, a
	ld a, [$c863]
	rlca
	and $04
	ld c, a
	call Call_50_5B7A
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_4d51

	ld a, $03
	ld [$d9f7], a
	jr jr_050_4d9b

jr_050_4d51:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_4d9b

	ld a, [$dd72]
	res 7, a
	ld c, a
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_4d68

	set 2, c

jr_050_4d68:
	ld a, c
	call Call_2FA5
	jr nc, jr_050_4d84

	ld a, [$c8dd]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $30
	jr z, jr_050_4d84

	cp $31
	jr nz, jr_050_4d9c

jr_050_4d84:
	call Call_50_4F95
	ld a, $59
	call Call_1B2C
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10

Jump_050_4d9b:
jr_050_4d9b:
	ret


Jump_050_4d9c:
jr_050_4d9c:
	ld a, c
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D2E
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $fa00
	ld a, $0a
	ld [$d9f7], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


Jump_50_4DCD::
	ld a, [$db8a]
	ld [$dd76], a
	ld a, a
	ld [$c1c2], a
	call Call_50_53DC
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $7113
	call Call_50_75F0
	call Call_50_7848
	ld de, $5664
	ld a, [$c863]
	rlca
	and $04
	xor $04
	ld b, a
	call Call_2FA5
	jr nc, jr_050_4e05

	inc b
	ld a, b
	call Call_2FA5
	jr nc, jr_050_4e05

	inc b

jr_050_4e05:
	res 2, b
	set 7, b
	ld a, b
	ld [$dd72], a
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f7
	inc [hl]
	ret


Jump_50_4E18::
	ld de, $5664
	ld hl, $dd72
	ld a, [$c8dd]
	cp $04
	jr c, jr_050_4e2a

	ld a, [$db74]
	jr jr_050_4e2d

jr_050_4e2a:
	ld a, [$db75]

jr_050_4e2d:
	ld b, a
	ld a, [$c863]
	rlca
	and $04
	xor $04
	ld c, a
	call Call_50_5B7A
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_4e54

	ld a, [$c8de]
	cp $80
	ld a, $01
	jr z, jr_050_4e4c

	ld a, $03

jr_050_4e4c:
	ld [$d9f7], a
	call Call_50_56EB
	jr jr_050_4e89

jr_050_4e54:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_4e89

	ld a, [$dd72]
	res 7, a
	ld c, a
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_4e6b

	set 2, c

jr_050_4e6b:
	ld a, c
	call Call_2FA5
	jp c, Jump_050_4d9c

	call Call_50_4F95
	ld a, $59
	call Call_1B2C
	call Call_50_4F45
	ld a, $0b
	ld [$d9f7], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10

Jump_050_4e89:
jr_050_4e89:
	ret


Jump_50_4E8A::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	ld a, $01
	ld [$d9f7], a
	ret


Jump_50_4E98::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	ld a, [$c8de]
	and $01
	add a
	inc a
	ld [$d9f7], a
	ret


Jump_50_4EAB::
	ld a, [$c8db]
	cp $80
	jr z, jr_050_4ed7

	ld a, $81
	ld [$c8da], a
	ld a, $04
	ld [$d9f5], a
	call Call_50_4620
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10
	jp Jump_050_4f61


jr_050_4ec9:
	ld a, [$c8dd]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02

jr_050_4ed7:
	ld a, [$db88]
	cp $01
	jr z, jr_050_4f36

	ld b, a
	ld a, [$c8dd]
	and $03
	cp b
	jr z, jr_050_4f36

	ld hl, $c8dd
	inc [hl]
	ld a, [hl]
	and $03
	cp $03
	jr z, jr_050_4f36

	ld a, [hl]
	call Call_2FA5
	jr c, jr_050_4ed7

	ld a, [hl]
	call Call_2F76
	jr c, jr_050_4f16

	ld a, [$c8dd]
	ld hl, $db06
	call Call_2F6C
	bit 2, [hl]
	jr nz, jr_050_4ec9

	inc hl
	bit 4, [hl]
	jr nz, jr_050_4ec9

	xor a
	ld [$d9f7], a
	jr jr_050_4f61

jr_050_4f16:
	ld a, [hl]
	push bc
	ld b, a
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a
	ld [hli], a
	ld a, b
	ld [hl], a
	pop bc
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	jr jr_050_4ed7

Jump_050_4f36:
jr_050_4f36:
	ld a, $81
	ld [$c8da], a
	ld a, $04
	ld [$d9f5], a
	call Call_50_46C6
	jr jr_050_4f61

Call_50_4F45::
	ld a, [$c8dd]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [$c8dd]
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03

Jump_050_4f61:
jr_050_4f61:
	ret


	db $cd, $4e, $77, $cd, $4c, $79, $cd, $b4, $79, $c9, $c9, $c9

Call_50_4F6E::
	ld a, [$c8dd]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ret


Call_50_4F80::
	call Call_50_4F86
	inc hl
	ld [hl], c
	ret


Call_50_4F86::
	ld a, [$c8dd]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


Call_50_4F95::
	ld a, [$c8dd]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ret


Call_50_4FA4::
	push de
	ld c, a
	ld b, $03
	ld de, $0000

jr_050_4fab:
	ld a, c
	call Call_2FA5
	jr c, jr_050_4fb3

	inc d
	ld e, c

jr_050_4fb3:
	inc c
	dec b
	jr nz, jr_050_4fab

	ld b, d
	ld c, e
	pop de
	ret


Jump_50_4FBB::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$d9f5]
	rst $00

JumpTable_50_4FC4::
	dw Jump_50_4FE2
	dw Jump_50_5040
	dw Jump_50_50C5
	dw Jump_50_51CC
	dw Jump_50_5207
	dw Jump_50_528E
	dw Jump_50_52D7
	dw Jump_50_5372
	dw Jump_50_5602
	dw Jump_50_5697
	dw Jump_50_56AC
	dw Jump_50_56BA
	dw Jump_50_56CB
	dw Jump_50_56D9
	dw Call_50_56EB

Jump_50_4FE2::
	ld a, [$db73]
	cp $02
	jr z, jr_050_503a

	ld bc, $1400

jr_050_4fec:
	ld hl, $ca51
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_050_5020

	or a
	jr z, jr_050_5020

	push bc
	ld a, [hl]
	add $af
	ld a, a
	ld [$db4c], a
	ld a, $00
	ld [$db4d], a
	ld a, $0a
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	ld a, [$db4c]
	cp $01
	pop bc
	jr nz, jr_050_5035

	inc c
	dec b
	jr nz, jr_050_4fec

jr_050_5020:
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $f300
	call Call_50_51AA
	ld a, $0b
	ld [$d9f5], a
	ret


jr_050_5035:
	ld hl, $d9f5
	inc [hl]
	ret


jr_050_503a:
	ld a, $f4
	call Call_50_5AE5
	ret


Jump_50_5040::
	call Call_50_50AC
	call Call_50_506F
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $6fce
	call Call_50_75F0
	call Call_50_7848
	ld de, $51c0
	ld b, $04
	ld a, [$d9f6]
	ld c, a
	ld hl, $c8db
	call Call_50_78E9
	call Call_50_768E
	ld hl, $d9f5
	inc [hl]
	ret


Call_50_506F::
	ld de, $ca51
	ld a, [$c8dc]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call Call_50_5089
	call Call_50_5089
	call Call_50_5089

Call_50_5089::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_050_5092

	ld a, $00

jr_050_5092:
	ld [$c823], a
	ld a, $08
	ld [$c822], a
	ld de, $0901
	call Call_50_76C7
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


Call_50_50AC::
	ld hl, $ca51
	ld b, $14
	ld c, $00

jr_050_50b3:
	ld a, [hli]
	cp $00
	jr z, jr_050_50c0

	cp $ff
	jr z, jr_050_50c0

	inc c
	dec b
	jr nz, jr_050_50b3

jr_050_50c0:
	ld a, c
	ld [$d9f6], a
	ret


Jump_50_50C5::
	ld de, $51c0
	ld hl, $c8db
	ld a, [$d9f6]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call Call_50_776E
	pop af
	ld hl, $c8dc
	cp [hl]
	jr z, jr_050_50e1

	call Call_50_506F

jr_050_50e1:
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_50f4

	ld hl, far_Call_55_47C3
	rst $10
	ld a, $01
	ld [$d9f4], a
	jp Jump_050_517a


jr_050_50f4:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_517a

	ld hl, $c8db
	res 7, [hl]
	ld a, [$c8dc]
	add a
	add a
	add [hl]
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $af
	add [hl]
	ld [$db4c], a
	ld hl, far_Call_54_535F
	rst $10
	ld a, [$db4c]
	or a
	jr z, jr_050_5199

	ld a, [$db4c]
	ld [$db77], a
	ld a, [$db4d]
	ld [$db78], a
	ld a, $59
	call Call_1B2C
	ld hl, far_Call_55_47D7
	rst $10
	ld a, [$db77]
	cp $11
	jr z, jr_050_514e

	cp $12
	jr z, jr_050_515d

	cp $21
	jr z, jr_050_5169

	cp $22
	jr z, jr_050_5170

	ld hl, $d9f5
	inc [hl]
	jr jr_050_517a

jr_050_514e:
	call Call_50_517B
	jr z, jr_050_5175

	call Call_50_56EB
	ld a, $07
	ld [$d9f5], a
	jr jr_050_517a

jr_050_515d:
	ld a, $04
	ld [$db77], a
	ld a, $09
	ld [$d9f5], a
	jr jr_050_517a

jr_050_5169:
	ld a, $05
	ld [$d9f5], a
	jr jr_050_517a

jr_050_5170:
	ld a, $00
	ld [$db77], a

jr_050_5175:
	ld a, $09
	ld [$d9f5], a

Jump_050_517a:
jr_050_517a:
	ret


Call_50_517B::
	ld hl, $dd1f
	ld a, [$db75]
	ld b, a
	ld c, $00
	ld d, $04

jr_050_5186:
	ld a, [hli]
	or a
	jr nz, jr_050_518c

	inc c
	ld e, d

jr_050_518c:
	inc d
	dec b
	jr nz, jr_050_5186

	ld a, c
	cp $01
	ret nz

	ld a, e
	ld [$db77], a
	ret


jr_050_5199:
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $f200
	ld a, $0a
	ld [$d9f5], a

Call_50_51AA::
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


	db $2a, $02, $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Jump_50_51CC::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $7045
	call Call_50_75F0
	call Call_50_7848
	ld de, $5288
	xor a
	ld [$c8dd], a
	ld a, [$c8dd]
	ld b, a
	ld a, [$db78]
	cp $c2
	jr c, jr_050_51fb

	cp $c7
	jr nc, jr_050_51fb

	ld a, $01
	ld [$c8dd], a
	ld b, $01

jr_050_51fb:
	ld a, b
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f5
	inc [hl]
	ret


Jump_50_5207::
	ld de, $5288
	ld hl, $c8dd
	ld b, $02
	call Call_50_77F7
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_5227

	ld hl, $d9f5
	dec [hl]
	ld hl, $d9f5
	dec [hl]
	ld hl, $d9f5
	dec [hl]
	jr jr_050_5287

jr_050_5227:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_5287

	ld a, $59
	call Call_1B2C
	ld hl, far_Call_55_47EB
	rst $10
	ld a, $80
	ld [$c8de], a
	ld a, [$c8dd]
	cp $80
	jr z, jr_050_526d

	ld a, [$db78]
	cp $c2
	jr c, jr_050_524f

	cp $c7
	jr c, jr_050_525f

jr_050_524f:
	ld a, [$db77]
	and $0f
	bit 0, a
	jr z, jr_050_525f

	ld a, $07
	ld [$d9f5], a
	jr jr_050_5287

jr_050_525f:
	ld a, $04
	ld [$db77], a
	ld a, $09
	ld [$d9f5], a
	jr jr_050_5287

	db $18, $1a

jr_050_526d:
	ld a, [$db77]
	and $0f
	bit 0, a
	jr z, jr_050_527d

	ld a, $05
	ld [$d9f5], a
	jr jr_050_5287

jr_050_527d:
	ld a, $09
	ld [$d9f5], a
	ld a, $00
	ld [$db77], a

Jump_050_5287:
jr_050_5287:
	ret


	db $c1, $01, $01, $02, $ff, $ff

Jump_50_528E::
	ld a, [$db78]
	ld [$dd76], a
	ld a, a
	ld [$c1c2], a
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $707f
	call Call_50_75F0
	call Call_50_5BD7
	call Call_50_7848
	ld de, $5339
	ld a, [$c863]
	rlca
	and $04
	ld b, a
	call Call_2FA5
	jr nc, jr_050_52c4

	inc b
	ld a, b
	call Call_2FA5
	jr nc, jr_050_52c4

	inc b

jr_050_52c4:
	res 2, b
	set 7, b
	ld a, b
	ld [$c8de], a
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f5
	inc [hl]
	ret


Jump_50_52D7::
	ld de, $5339
	ld hl, $c8de
	ld a, [$db74]
	ld b, a
	ld a, [$c863]
	rlca
	and $04
	ld c, a
	call Call_50_5B7A
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_5309

	ld a, [$db77]
	and $f0
	cp $20
	jr z, jr_050_5302

	ld a, $03
	ld [$d9f5], a
	jr jr_050_5338

jr_050_5302:
	ld a, $01
	ld [$d9f5], a
	jr jr_050_5338

jr_050_5309:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_5338

	ld a, [$c8de]
	res 7, a
	ld c, a
	call Call_2FA5
	jr nc, jr_050_5323

	ld a, [$db78]
	cp $bb
	jr nz, jr_050_5341

jr_050_5323:
	ld a, c
	ld [$db77], a
	ld a, $59
	call Call_1B2C
	ld hl, $d9f5
	inc [hl]
	ld hl, $d9f5
	inc [hl]
	ld hl, $d9f5
	inc [hl]

Jump_050_5338:
jr_050_5338:
	ret


	db $81, $01, $c1, $01, $01, $02, $ff, $ff

jr_050_5341:
	ld a, c
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D2E
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $fa00
	ld a, $0c
	ld [$d9f5], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


Jump_50_5372::
	ld a, [$db78]
	ld [$dd76], a
	ld a, a
	ld [$c1c2], a
	call Call_50_53DC
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld de, $7113
	call Call_50_75F0
	call Call_50_7848
	ld de, $5664
	ld a, [$c863]
	rlca
	and $04
	xor $04
	ld b, a
	call Call_2FA5
	jr nc, jr_050_53aa

	inc b
	ld a, b
	call Call_2FA5
	jr nc, jr_050_53aa

	inc b

jr_050_53aa:
	res 2, b
	set 7, b
	ld a, b
	ld [$c8de], a
	call Call_50_790B
	call Call_50_768E
	ld hl, $d9f5
	inc [hl]
	ret


Call_50_53BD::
	ld a, [$c863]
	rlca
	and $04
	xor $04
	ld [$dd73], a
	ret


Call_50_53C9::
	ld a, [$dd76]
	cp $30
	jr z, jr_050_53da

	cp $31
	jr z, jr_050_53da

	cp $bb
	jr z, jr_050_53da

	scf
	ret


jr_050_53da:
	xor a
	ret


Call_50_53DC::
	ld a, [$c86c]
	or a
	jp nz, Jump_050_549e

	call Call_50_53BD
	call Call_2FA5
	call c, Call_50_53C9
	jr c, jr_050_53fe

	xor a
	ld [$db4e], a
	ld a, [$c1ca]
	cp $ff
	jr z, jr_050_5403

	call Call_50_5530
	jr jr_050_540e

jr_050_53fe:
	call Call_50_547E
	jr jr_050_540e

jr_050_5403:
	call Call_50_547E
	ld a, $01
	ld [$db4e], a
	call Call_50_5530

jr_050_540e:
	xor a
	ld [$db4e], a
	ld a, [$da02]
	cp $00
	jr nz, jr_050_541e

	call Call_50_5485
	jr Call_50_548C

jr_050_541e:
	ld a, [$dd73]
	inc a
	ld [$dd73], a
	call Call_2FA5
	call c, Call_50_53C9
	jr c, jr_050_5439

	ld a, [$c1cb]
	cp $ff
	jr z, jr_050_543e

	call Call_50_553D
	jr jr_050_5449

jr_050_5439:
	call Call_50_5485
	jr jr_050_5449

jr_050_543e:
	call Call_50_5485
	ld a, $01
	ld [$db4e], a
	call Call_50_553D

jr_050_5449:
	xor a
	ld [$db4e], a
	ld a, [$da02]
	cp $01
	jr nz, jr_050_5456

	jr Call_50_548C

jr_050_5456:
	ld a, [$dd73]
	inc a
	ld [$dd73], a
	call Call_2FA5
	call c, Call_50_53C9
	jr c, jr_050_5470

	ld a, [$c1cc]
	cp $ff
	jr z, jr_050_5472

	call Call_50_554A
	ret


jr_050_5470:
	jr Call_50_548C

jr_050_5472:
	call Call_50_548C
	ld a, $01
	ld [$db4e], a
	call Call_50_554A
	ret


Call_50_547E::
	ld hl, $88c0
	ld b, $a0
	jr Call_50_5491

Call_50_5485::
	ld hl, $8960
	ld b, $a0
	jr Call_50_5491

Call_50_548C::
	ld hl, $8a00
	ld b, $a0

Call_50_5491::
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, Call_50_5491

	ret


Jump_050_549e:
	xor a
	ld [$c1d7], a
	ld a, [$db74]
	ld [$c1d8], a
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_54ba

	ld a, $04
	ld [$c1d7], a
	ld a, [$db75]
	ld [$c1d8], a

jr_050_54ba:
	ld a, [$c1d7]
	call Call_2FA5
	call c, Call_50_53C9
	jr nc, jr_050_54ca

	call Call_50_547E
	jr jr_050_54d9

jr_050_54ca:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $88c0
	call Call_50_5557

jr_050_54d9:
	ld a, [$c1d8]
	cp $01
	jr nz, jr_050_54e5

	call Call_50_5485
	jr Call_50_548C

jr_050_54e5:
	ld hl, $c1d7
	inc [hl]
	ld a, [hl]
	call Call_2FA5
	call c, Call_50_53C9
	jr nc, jr_050_54f7

	call Call_50_5485
	jr jr_050_5506

jr_050_54f7:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $8960
	call Call_50_5557

jr_050_5506:
	ld a, [$c1d8]
	cp $02
	jr nz, jr_050_5510

	jp Call_50_548C


jr_050_5510:
	ld hl, $c1d7
	inc [hl]
	ld a, [hl]
	call Call_2FA5
	call c, Call_50_53C9
	jr nc, jr_050_5520

	jp Call_50_548C


jr_050_5520:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $8a00
	call Call_50_5557
	ret


Call_50_5530::
	call Call_50_55F9
	ld hl, $88c0
	ld a, $00
	ld [$db4c], a
	jr jr_050_556a

Call_50_553D::
	call Call_50_55F9
	ld hl, $8960
	ld a, $01
	ld [$db4c], a
	jr jr_050_556a

Call_50_554A::
	call Call_50_55F9
	ld hl, $8a00
	ld a, $02
	ld [$db4c], a
	jr jr_050_556a

Call_50_5557::
	push hl
	call Call_50_7700
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $30
	call Call_50_5491
	ret


jr_050_556a:
	push hl
	push hl
	ld a, [$db4c]
	add $04
	ld [$db50], a
	ld hl, $c180
	call Call_50_7D2E
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
	ld a, [$db4d]
	or a
	jr nz, jr_050_55a0

	ld de, $0801
	jr jr_050_55a3

jr_050_55a0:
	ld de, $0901

jr_050_55a3:
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
	ld a, [$db4e]
	or a
	ret nz

	ld a, [$db4d]
	or a
	jr nz, jr_050_55e3

	ld a, l
	add $80
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $18
	jr jr_050_55f5

jr_050_55e3:
	ld a, l
	add $80
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $10

jr_050_55f5:
	call Call_50_5491
	ret


Call_50_55F9::
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ret


Jump_50_5602::
	ld de, $5664
	ld hl, $c8de
	ld a, [$da02]
	inc a
	ld b, a
	ld a, [$c863]
	rlca
	and $04
	xor $04
	ld c, a
	call Call_50_5B7A
	ld a, [$c846]
	bit 1, a
	jr z, jr_050_563a

	ld a, [$db77]
	and $f0
	cp $10
	jr z, jr_050_5630

	ld a, $03
	ld [$d9f5], a
	jr jr_050_5663

jr_050_5630:
	call Call_50_56EB
	ld a, $01
	ld [$d9f5], a
	jr jr_050_5663

jr_050_563a:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_050_5663

	ld a, [$c8de]
	res 7, a
	add $04
	ld c, a
	call Call_2FA5
	jr nc, jr_050_5656

	ld a, [$db78]
	cp $bb
	jr nz, jr_050_566c

jr_050_5656:
	ld a, c
	ld [$db77], a
	ld a, $59
	call Call_1B2C
	ld hl, $d9f5
	inc [hl]

Jump_050_5663:
jr_050_5663:
	ret


	db $81, $01, $c1, $01, $01, $02, $ff, $ff

jr_050_566c:
	ld a, c
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D2E
	call Call_50_5708
	ld hl, $fa00
	ld a, $0d
	ld [$d9f5], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ret


Jump_50_5697::
	ld hl, $dd13
	ld a, [$db74]
	ld b, a
	ld a, $01

jr_050_56a0:
	ld [hli], a
	dec b
	jr nz, jr_050_56a0

	call Call_50_774E
	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_56AC::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	ld a, $01
	ld [$d9f5], a
	ret


Jump_50_56BA::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	xor a
	ld [$d9f4], a
	xor a
	ld [$d9f5], a
	ret


Jump_50_56CB::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	ld a, $05
	ld [$d9f5], a
	ret


Jump_50_56D9::
	ld a, [$c825]
	or a
	ret nz

	call Call_50_774E
	ld a, $07
	ld [$d9f5], a
	ret


	db $21, $06, $55, $d7

Call_50_56EB::
	call Call_50_5708
	ld hl, $88c0

Call_50_56F1::
	ld c, $02

jr_050_56f3:
	ld b, $f0

jr_050_56f5:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_050_56f5

	dec c
	jr nz, jr_050_56f3

	call Call_50_768E
	ret


Call_50_5708::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ret


Jump_50_5712::
	ld a, [$d9f5]
	rst $00

JumpTable_50_5716::
	dw Jump_50_571E
	dw Jump_50_57A8
	dw Jump_50_5831
	dw Jump_50_583B

Jump_50_571E::
	ld a, [$db73]
	or a
	jr z, jr_050_5738

	cp $01
	jr z, jr_050_576c

	ld a, [$d8d3]
	cp $5d
	jr nz, jr_050_576c

	call Call_50_5772
	ld a, $01
	ld [$c1d5], a
	ret


jr_050_5738:
	ld de, $ca42
	ld hl, $c180
	call Call_0C80
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld a, $2a
	call Call_50_6AA0
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ld a, $ff
	ld [$db77], a
	ld a, $ff
	ld [$db78], a
	ld hl, $d9f5
	inc [hl]
	ld a, $6d
	call Call_1B2C
	ret


jr_050_576c:
	ld a, $f5
	call Call_50_5AE5
	ret


Call_50_5772::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld hl, $0502
	ld a, $03
	ld [$d9f5], a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $7213
	call Call_50_75F0
	call Call_50_768E
	ret


Jump_50_57A8::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$db73]
	or a
	jr nz, jr_050_5808

	ld a, [$db76]
	or a
	jr z, jr_050_5808

	cp $04
	jr nc, jr_050_5808

	cp $03
	jr z, jr_050_57cd

	cp $02
	jr z, jr_050_57c9

	ld b, $40
	jr jr_050_57cf

jr_050_57c9:
	ld b, $80
	jr jr_050_57cf

jr_050_57cd:
	ld b, $c0

jr_050_57cf:
	ld a, [$c899]
	cp b
	jr c, jr_050_5808

	call Call_50_58A6
	jr c, jr_050_5808

	call Call_50_58D0
	jr c, jr_050_5808

	ld hl, $dd13
	ld a, [$db74]
	ld b, a
	ld a, $03

jr_050_57e8:
	ld [hli], a
	dec b
	jr nz, jr_050_57e8

	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld a, $b9
	call Call_50_6AA0
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ld hl, $d9f5
	inc [hl]
	ret


jr_050_5808:
	xor a
	ld [$db4e], a
	ld hl, $d9f4
	inc [hl]
	ld a, $0a
	ld [$d9ec], a
	ld hl, $dd1f
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $02
	ld [$db55], a
	call Call_50_590C
	ld a, [$db73]
	or a
	ret z

	ld a, $01
	ld [$db55], a
	ret


Jump_50_5831::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ret


Jump_50_583B::
	ld de, $58a0
	ld hl, $c1d5
	ld b, $02
	call Call_50_77F7
	ld a, [$c846]
	bit 0, a
	jr z, jr_050_5892

	ld a, [$c1d5]
	bit 0, a
	jr nz, jr_050_5895

	ld de, $ca42
	ld hl, $c180
	call Call_0C80
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld a, $02
	ld [$c822], a
	ld a, $06
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ld a, $ff
	ld [$db77], a
	ld a, $ff
	ld [$db78], a
	ld a, $6d
	call Call_1B2C
	ld a, $01
	ld [$d9f5], a
	ret


jr_050_5892:
	bit 1, a
	ret z

jr_050_5895:
	xor a
	ld [$d9f4], a
	ld [$c8da], a
	ld [$d9f5], a
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Call_50_58A6::
	ld bc, $0304

jr_050_58a9:
	ld a, c
	call Call_2FA5
	jr c, jr_050_58c8

	ld a, c
	ld hl, $db02
	call Call_2F6C
	ld a, [hli]
	and $d0
	jr nz, jr_050_58c8

	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, jr_050_58c8

	inc hl
	ld a, [hl]
	and $c0
	jr z, jr_050_58ce

jr_050_58c8:
	inc c
	dec b
	jr nz, jr_050_58a9

	scf
	ret


jr_050_58ce:
	xor a
	ret


Call_50_58D0::
	ld bc, $0300
	ld de, $0000

jr_050_58d6:
	ld a, c
	call Call_2FA5
	jr c, jr_050_58e3

	call Call_50_5900
	cp d
	jr c, jr_050_58e3

	ld d, a

jr_050_58e3:
	inc c
	dec b
	jr nz, jr_050_58d6

	ld bc, $0304

jr_050_58ea:
	ld a, c
	call Call_2FA5
	jr c, jr_050_58f7

	call Call_50_5900
	cp e
	jr c, jr_050_58f7

	ld e, a

jr_050_58f7:
	inc c
	dec b
	jr nz, jr_050_58ea

	ld a, $04
	add e
	cp d
	ret


Call_50_5900::
	ld a, c
	ld hl, $db9b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Call_50_590C::
	ld bc, $0300

Jump_050_590f:
	ld a, c
	ld [$db4c], a
	ld a, b
	ld [$db4d], a
	ld a, c
	call Call_2FA5
	jr c, jr_050_5991

	ld de, $0000
	ld a, c
	ld hl, $dc5c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $97
	jr c, jr_050_5931

	ld e, $10

jr_050_5931:
	ld a, c
	ld hl, $db9b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $0a
	jr c, jr_050_595a

	cp $14
	jr c, jr_050_594e

	cp $1e
	jr c, jr_050_5954

	ld a, e
	add $0c
	ld e, a
	jr jr_050_595a

jr_050_594e:
	ld a, e
	add $04
	ld e, a
	jr jr_050_595a

jr_050_5954:
	ld a, e
	add $08
	ld e, a
	jr jr_050_595a

jr_050_595a:
	ld hl, $59b6
	add hl, de
	ld a, [$db4c]
	ld bc, $dc44
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F

jr_050_5991:
	ld a, [$db4c]
	ld c, a
	ld a, [$db4d]
	ld b, a
	inc c
	dec b
	jp nz, Jump_050_590f

	ret


Call_50_599F::
	bit 7, [hl]
	jr nz, jr_050_59ab

	ld a, [bc]
	add [hl]
	jr nc, jr_050_59b4

	ld a, $ff
	jr jr_050_59b4

jr_050_59ab:
	ld a, [hl]
	cpl
	inc a
	ld d, a
	ld a, [bc]
	sub d
	jr nc, jr_050_59b4

	xor a

jr_050_59b4:
	ld [bc], a
	ret


	db $fc, $00, $00, $f6, $fd, $00, $00, $fb, $fe, $00, $00, $fd, $ff, $00, $00, $fe
	db $f8, $00, $00, $f1, $fa, $00, $00, $f6, $fc, $00, $00, $fb, $fe, $00, $00, $fd

Jump_50_59D6::
	call Call_50_5708
	ld a, [$db58]
	ld l, a
	ld a, [$db59]
	ld h, a
	call Call_50_56F1
	ld a, [$db5a]
	ld [$d9f4], a
	ret


Call_50_59EB::
	ld a, [$db88]
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D2E
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	cp $4f
	jr z, jr_050_5a19

	cp $a6
	jr z, jr_050_5a16

	cp $ac
	jr z, jr_050_5a19

	call Call_50_5A53
	jr jr_050_5a1c

jr_050_5a16:
	call Call_50_5A5E

jr_050_5a19:
	call Call_50_5A71

jr_050_5a1c:
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	call z, Call_50_5A50
	cp $da
	call nc, Call_50_5AD2
	ld l, a
	ld h, $06
	ld de, $c190
	call Call_097A
	ld a, $00
	ld [$c822], a
	ld a, [$db4c]
	ld [$c823], a
	cp $ff
	ret z

	ld hl, far_Call_4C_42D1
	rst $10
	ret


Call_50_5A50::
	ld a, $3a
	ret


Call_50_5A53::
	ld a, [hl]
	ld hl, $c1a0
	ld [$db50], a
	call Call_50_7D2E
	ret


Call_50_5A5E::
	ld a, [hl]
	ld [$db89], a
	ld hl, far_Call_58_5955
	rst $10
	ld a, [$dd72]
	or a
	jr z, jr_050_5a1c

	ld hl, $c180
	jr jr_050_5a89

Call_50_5A71::
	ld a, [hl]
	ld [$db89], a
	ld hl, far_Call_58_5955
	rst $10
	ld a, [$dd72]
	or a
	jr z, Call_50_5AC5

	cp $01
	jr nz, jr_050_5a9c

	call Call_50_5AC5
	ld hl, $c1a0

jr_050_5a89:
	ld a, [hli]
	cp $f0
	jr nz, jr_050_5a89

jr_050_5a8e:
	dec hl
	ld a, [hl]
	cp $f0
	jr z, jr_050_5a8e

	cp $24
	jr c, jr_050_5a99

	inc hl

jr_050_5a99:
	ld [hl], $f0
	ret


jr_050_5a9c:
	ld a, [$c86c]
	or a
	jr nz, Call_50_5AC5

	ld a, [$db89]
	cp $04
	jr nc, jr_050_5aad

	call Call_50_5AC5
	ret


jr_050_5aad:
	ld hl, $c1a0
	ld a, $3e
	ld [hli], a
	ld a, $62
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld a, $3e
	ld [hli], a
	ld a, $4b
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld [hl], $f0
	ret


Call_50_5AC5::
	ld a, [$db89]
	ld hl, $c1a0
	ld [$db50], a
	call Call_50_7D2E
	ret


Call_50_5AD2::
	push hl
	sub $da
	ld hl, $5ae1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


	db $19, $a1, $2a, $70

Call_50_5AE5::
	push af
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	pop af
	call Call_50_6AA0
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ld a, $00
	ld [$d9f4], a
	ld a, $00
	ld [$d9f5], a
	ret


Call_50_5B07::
	push bc
	ld [$dd72], a
	ld b, a
	call Call_2F76
	jr c, jr_050_5b55

	ld a, b
	ld bc, $db02
	add a
	add a
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	bit 4, a
	jr nz, jr_050_5b35

	inc bc
	inc bc
	inc bc
	inc bc
	ld a, [bc]
	and $0c
	jr nz, jr_050_5b35

	inc bc
	ld a, [bc]
	and $f0
	jr nz, jr_050_5b35

	xor a
	jr jr_050_5b56

jr_050_5b35:
	push hl
	ld a, [$dd72]
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or $e0
	ld [hl], a
	ld a, [$dd72]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	pop hl

jr_050_5b55:
	scf

jr_050_5b56:
	pop bc
	ret


Call_50_5B58::
	call Call_50_774E
	call Call_50_794C
	call Call_50_79B4
	ld a, $e0
	call Call_50_6AA0
	ld de, $2e07
	call Call_50_75F0
	call Call_50_768E
	ld a, $00
	ld [$d9f4], a
	ld a, $00
	ld [$d9f5], a
	ret


Call_50_5B7A::
	res 7, [hl]
	ld a, [$c847]
	and $40
	jp z, Jump_050_5b9a

jr_050_5b84:
	ld a, [hl]
	dec a
	bit 7, a
	call nz, Call_50_5BB7
	call Call_50_5BBC
	jp nc, Jump_050_7817

	call Call_50_5BC5
	ld [hl], a
	jr nz, jr_050_5b84

	jp Jump_050_7817


Jump_050_5b9a:
	ld a, [$c847]
	and $80
	jp z, Jump_050_7820

jr_050_5ba2:
	ld a, [hl]
	inc a
	cp b
	call nc, Call_50_5BBA
	call Call_50_5BBC
	jp nc, Jump_050_7817

	call Call_50_5BC5
	ld [hl], a
	jr nz, jr_050_5ba2

	jp Jump_050_7817


Call_50_5BB7::
	ld a, b
	dec a
	ret


Call_50_5BBA::
	xor a
	ret


Call_50_5BBC::
	push bc
	ld b, a
	or c
	call Call_2FA5
	ld a, b
	pop bc
	ret


Call_50_5BC5::
	push bc
	ld b, a
	ld a, [$c1c2]
	cp $30
	jr z, jr_050_5bd4

	cp $31
	jr z, jr_050_5bd4

	cp $bb

jr_050_5bd4:
	ld a, b
	pop bc
	ret


Call_50_5BD7::
	ld a, [$c863]
	rlca
	and $04
	ld c, a
	ld b, $03

jr_050_5be0:
	ld a, c
	call Call_2FA5
	jr nc, jr_050_5bfb

	ld a, [$dd76]
	cp $30
	jr z, jr_050_5bfb

	cp $31
	jr z, jr_050_5bfb

	cp $bb
	jr z, jr_050_5bfb

	ld a, c
	res 2, a
	call Call_50_5C00

jr_050_5bfb:
	inc c
	dec b
	jr nz, jr_050_5be0

	ret


Call_50_5C00::
	push bc
	ld hl, $0060

jr_050_5c04:
	ld a, c
	and $03
	jr z, jr_050_5c14

	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec c
	jr jr_050_5c04

jr_050_5c14:
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $01
	ld h, a
	call Call_50_758E

jr_050_5c1f:
	ld a, [hl]
	cp $ff
	jr z, jr_050_5c2d

	cp $80
	jr nc, jr_050_5c2a

	ld [hl], $e0

jr_050_5c2a:
	inc hl
	jr jr_050_5c1f

jr_050_5c2d:
	pop bc
	ret


Call_50_5C2F::
	ld a, [$c8dc]
	cp $83
	ret nz

	ld a, [$db73]
	cp $02
	ret nz

	ld a, [$c86c]
	or a
	ret


Call_50_5C40::
	ld a, $00
	ld [$dd23], a
	ld a, $00
	ld [$dd24], a
	ld a, $00
	ld [$dd25], a
	ld a, [$db75]
	ld b, a
	ld hl, $dd1f
	ld de, $dc33

jr_050_5c59:
	ld a, [hli]
	cp $01
	jr nz, jr_050_5c71

	push hl
	ld hl, $dd23
	ld a, [de]
	add [hl]
	ld [hli], a
	inc de
	ld a, [de]
	adc [hl]
	ld [hli], a
	inc de
	ld a, [de]
	adc [hl]
	ld [hl], a
	inc de
	pop hl
	jr jr_050_5c74

jr_050_5c71:
	inc de
	inc de
	inc de

jr_050_5c74:
	dec b
	jr nz, jr_050_5c59

	ret


Call_50_5C78::
	ld a, [$c86c]
	or a
	jr nz, Call_50_5CB4

	call Call_50_6974
	call Call_50_6A65
	ld bc, $0304
	ld de, $0000

jr_050_5c8a:
	ld a, c
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_050_5c9a

	inc d

jr_050_5c9a:
	inc c
	dec b
	jr nz, jr_050_5c8a

	ld a, d
	or a
	jr nz, jr_050_5ca4

	ld e, $03

jr_050_5ca4:
	ld a, [$db4c]
	cp $02
	jr c, jr_050_5cad

	ld a, $02

jr_050_5cad:
	add e
	add $ec
	call Call_50_6AA0
	ret


Call_50_5CB4::
	ld b, $03
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_5cc1

	ld c, $04
	jr jr_050_5cc3

jr_050_5cc1:
	ld c, $00

jr_050_5cc3:
	ld a, c
	call Call_2FA5
	jr c, jr_050_5cd4

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 6, [hl]
	jr z, jr_050_5cf5

jr_050_5cd4:
	inc c
	dec b
	jr nz, jr_050_5cc3

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_5ce4

	call Call_50_5D1F
	jr jr_050_5ce7

jr_050_5ce4:
	call Call_50_5D1A

jr_050_5ce7:
	ld a, $4f
	ld [$dd72], a
	ld a, $ff
	ld [$db73], a
	ld a, $eb
	jr jr_050_5d0b

jr_050_5cf5:
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_5d01

	call Call_50_5D1A
	jr jr_050_5d04

jr_050_5d01:
	call Call_50_5D1F

jr_050_5d04:
	ld a, $69
	ld [$dd72], a
	ld a, $ed

jr_050_5d0b:
	call Call_50_6AA0
	ld a, $02
	call Call_1AE1
	ld a, [$dd72]
	call Call_1B2C
	ret


Call_50_5D1A::
	ld de, $cacd
	jr jr_050_5d22

Call_50_5D1F::
	ld de, $cd21

jr_050_5d22:
	ld hl, $c180
	call Call_0C80
	ret


Call_50_5D29::
	ld a, $02
	ld [$db55], a
	ld a, [$db73]
	or a
	jr nz, jr_050_5d46

	ld a, [$c899]
	and $1f
	cp $1f
	jr z, jr_050_5d4c

	ld a, [$c89a]
	and $1f
	cp $1f
	jr z, jr_050_5d71

jr_050_5d46:
	ld a, $01
	ld [$db76], a
	ret


jr_050_5d4c:
	ld hl, $d9ec
	inc [hl]
	call Call_50_696D
	ld a, [$db4c]
	cp $02
	jr c, jr_050_5d5c

	ld a, $02

jr_050_5d5c:
	ld c, a
	ld a, [$c89a]
	and $01
	ld b, a
	add a
	add b
	add c
	add $03
	call Call_50_6AA0
	ld a, $00
	ld [$db55], a
	ret


jr_050_5d71:
	ld hl, $d9ec
	inc [hl]
	ld hl, $d9ec
	inc [hl]
	call Call_50_696D
	ld a, $04
	ld [$db88], a
	ld a, [$db4c]
	cp $02
	jr c, jr_050_5d8a

	ld a, $02

jr_050_5d8a:
	ld c, a
	ld a, [$c899]
	and $01
	ld b, a
	add a
	add b
	add c
	add $09
	call Call_50_6AA0
	ld a, $01
	ld [$db55], a
	ret


Call_50_5D9F::
	ld a, $ff
	ld hl, $db79
	ld bc, $000a
	call Call_12C7
	ld b, $08
	ld c, $00
	ld h, $00

jr_050_5db0:
	ld a, c
	ld e, a
	ld d, a
	ld a, c
	call Call_2F76
	ld a, d
	and a
	jr nz, jr_050_5dbc

	inc h

jr_050_5dbc:
	inc c
	dec b
	jr nz, jr_050_5db0

	ld a, h
	or a
	jr nz, jr_050_5dc8

	ld hl, $d9ec
	inc [hl]

jr_050_5dc8:
	ret


Call_50_5DC9::
	ld hl, sp+$00
	ld a, l
	ld [$da79], a
	ld a, h
	ld [$da7a], a
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
	ld hl, $d9ec
	ld bc, $0008
	call Call_12C7
	xor a
	ld hl, $d9f4
	ld bc, $0008
	call Call_12C7
	xor a
	ld [$d9ed], a
	ld [$dd62], a
	call Call_1264
	xor a
	ld [$dd60], a
	xor a
	ld [$c8ec], a
	xor a
	ld [$c87e], a
	ld hl, far_Call_51_423E
	rst $10
	ret


Call_50_5E21::
	ld a, [$c86c]
	or a
	jr z, jr_050_5e3e

	call Call_047E
	ld a, [$c850]
	or a
	ret nz

	call Call_3001
	ld a, [$dd62]
	or a
	ret z

	di
	ld hl, far_Call_02_400D
	rst $10
	ei
	ret


jr_050_5e3e:
	ld a, [$c850]
	or a
	ret nz

	call Call_3001
	call Call_50_6D78

Call_50_5E49::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$da80]
	cp $01
	jp nz, Jump_050_5ede

	ld a, [$da81]
	cp $ff
	ret z

	ld a, [$da81]
	ld [$c81e], a
	ld hl, far_Call_17_4751
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ld a, [$da81]
	ld hl, $5e84
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $8000
	call Call_1577
	ld a, $02
	ld [$da80], a
	ret


	db $00, $5a, $01, $5a, $02, $5a, $03, $5a, $04, $5a, $05, $5a, $06, $5a, $07, $5a
	db $08, $5a, $09, $5a, $0a, $5a, $0b, $5a, $0c, $5a, $0d, $5a, $0e, $5a, $0f, $5a
	db $10, $5a, $11, $5a, $12, $5a, $13, $5a, $14, $5a, $15, $5a, $16, $5a, $17, $5a
	db $18, $5a, $19, $5a, $1a, $5a, $1b, $5a, $1c, $5a, $1d, $5a, $1e, $5a, $1f, $5a
	db $0a, $5b, $0b, $5b, $0c, $5b, $0d, $5b, $0e, $5b, $0f, $5b, $10, $5b, $11, $5b
	db $12, $5b, $13, $5b, $14, $5b, $15, $5b, $16, $5b

Jump_050_5ede:
	ld a, [$dd62]
	or a
	jr z, jr_050_5ef9

	ld a, [$c86c]
	or a
	jr nz, jr_050_5eee

	ld hl, far_Call_02_400D
	rst $10

jr_050_5eee:
	ld a, [$dd62]
	or a
	ret nz

	ld a, $00
	ld [$da80], a
	ret


jr_050_5ef9:
	ld a, [$d9ec]
	cp $0d
	jr z, jr_050_5f17

	ld a, [$c825]
	or a
	jr z, jr_050_5f17

	ld a, [$da82]
	or a
	jr z, jr_050_5f17

	ld hl, far_Call_5F_4B1B
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_050_5f17

	ret


jr_050_5f17:
	ld a, [$da82]
	or a
	jr z, jr_050_5f2f

	ld a, [$da83]
	cp $09
	jr nz, jr_050_5f2f

	ld hl, far_Call_5F_4B1B
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_050_5f2f

	ret


jr_050_5f2f:
	ld a, [$db73]
	cp $ff
	jr z, jr_050_5f5e

	ld a, [$d9ec]
	rst $00

JumpTable_50_5F3A::
	dw Jump_50_5F6D
	dw Jump_50_5F93
	dw Jump_50_5FAE
	dw Jump_50_5FC1
	dw Jump_50_6051
	dw Jump_50_606F
	dw Jump_50_6079
	dw Jump_50_60B6
	dw Jump_50_60CB
	dw Jump_50_6AAC
	dw Jump_50_60ED
	dw Jump_50_62F0
	dw Jump_50_63C1
	dw Jump_50_63D2
	dw Jump_50_640A
	dw Jump_50_6951
	dw Jump_50_65DC
	dw Jump_50_65E6

jr_050_5f5e:
	ld a, [$dd80]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

	xor a
	ld [$db73], a
	ret


Jump_50_5F6D::
	ld hl, far_Call_17_41C0
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ld a, [$ca8d]
	or a
	jr nz, jr_050_5f86

	ld hl, $0c00
	call Call_096D
	ld hl, $d9ec
	inc [hl]
	ret


jr_050_5f86:
	call Call_50_6974
	ld a, $05
	ld [$da33], a
	ld hl, $d9ec
	inc [hl]
	ret


Jump_50_5F93::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$da33]
	or a
	jr z, jr_050_5fa3

	dec a
	ld [$da33], a
	ret


jr_050_5fa3:
	ld a, [$ca8d]
	or a
	jp z, Jump_50_640A

	call Call_50_69C4
	ret


Jump_50_5FAE::
	call Call_50_5D29
	call Call_50_68FC
	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ret


Jump_50_5FC1::
	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$c8da], a
	call Call_50_5D9F
	call Call_50_600D
	ld hl, $db42
	ld bc, $0008
	xor a
	call Call_12C7
	ld a, [$db74]
	ld b, a
	ld c, $00
	ld hl, $dd03
	call Call_50_5FF8
	ld a, [$c863]
	bit 1, a
	ret z

	ld a, [$db75]
	ld b, a
	ld c, $04
	ld hl, $dd07
	call Call_50_5FF8
	ret


Call_50_5FF8::
	ld a, c
	call Call_2FA5
	jr c, jr_050_6004

	ld a, [hl]
	and $0f
	ld [hli], a
	jr jr_050_6008

jr_050_6004:
	ld a, [hl]
	or $e0
	ld [hli], a

jr_050_6008:
	inc c
	dec b
	jr nz, Call_50_5FF8

	ret


Call_50_600D::
	ld de, $dcec
	ld bc, $0800

jr_050_6013:
	ld a, c
	call Call_2FA5
	jr c, jr_050_6046

	ld a, c
	ld hl, $db06
	call Call_2F6C
	bit 2, [hl]
	jr z, jr_050_6046

	ld a, c
	ld hl, $c1cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 7, [hl]
	jr nz, jr_050_6046

	ld a, c
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr nz, jr_050_6046

	ld a, $ff
	ld [de], a
	inc de
	jr jr_050_604b

jr_050_6046:
	ld a, $ff
	ld [de], a
	inc de
	ld [de], a

jr_050_604b:
	inc de
	inc c
	dec b
	jr nz, jr_050_6013

	ret


Jump_50_6051::
	jr jr_050_6067

Call_50_6053::
	call Call_50_774E
	call Call_50_794C
	ld a, [$da88]
	or a
	jr nz, jr_050_6063

	call Call_50_79AE
	ret


jr_050_6063:
	call Call_50_79B4
	ret


jr_050_6067:
	call Call_50_4017
	xor a
	ld [$d9ed], a
	ret


Jump_50_606F::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_58_53CF
	rst $10
	ret


Jump_50_6079::
	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$d9ed], a
	ld [$d9ee], a
	ld [$dd75], a
	ld [$dd6c], a
	ld [$dd68], a
	ld a, [$c86c]
	or a
	jr z, Jump_50_60B6

	ld a, [$c1ed]
	ld l, a
	ld a, [$c1ee]
	ld h, a
	ld a, l
	ld [$c899], a
	ld a, h
	ld [$c89a], a
	call Call_12D0
	ld a, [$c899]
	ld l, a
	ld a, [$c89a]
	ld h, a
	ld a, l
	ld [$c1ed], a
	ld a, h
	ld [$c1ee], a

Jump_50_60B6::
	ld hl, far_Call_52_6C4D
	rst $10
	call Call_50_79B4
	call Call_50_7627
	ld a, [$d9ec]
	cp $08
	ret nz

	ld a, $05
	ld [$da33], a

Jump_50_60CB::
	ld a, [$da33]
	or a
	jr z, jr_050_60d6

	dec a
	ld [$da33], a
	ret


jr_050_60d6:
	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$db4c], a
	ld [$db4d], a
	ld [$db4e], a
	ld [$d9ed], a
	call Call_50_6053
	jp Jump_50_6AAC


Jump_50_60ED::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c89b
	ld a, $d2
	ld [hli], a
	ld a, $d2
	ld [hli], a
	ld [hl], $e2
	ld a, [$db4e]
	cp $02
	jr nz, jr_050_6112

	ld hl, far_Call_52_76C8
	rst $10
	xor a
	ld [$db4e], a
	ld a, $05
	ld [$da33], a
	ret


jr_050_6112:
	ld a, [$da33]
	or a
	jr z, jr_050_611d

	dec a
	ld [$da33], a
	ret


jr_050_611d:
	call Call_50_774E
	call Call_50_79AE
	call Call_50_768E
	ld a, [$c86c]
	or a
	jr z, jr_050_6139

	ld a, $01
	ld [$c8c7], a
	ld a, $10
	ld [$d9ec], a
	jp Jump_050_6196


jr_050_6139:
	call Call_50_5C40
	ld hl, far_Call_51_4A96
	rst $10
	ld a, [$db55]
	or a
	jr z, jr_050_6150

	xor a
	ld [$dd61], a
	ld hl, $d9ec
	inc [hl]
	jr jr_050_6196

jr_050_6150:
	ld hl, $dd23
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_050_6192

	call Call_50_61E2
	ld hl, far_Call_01_4686
	rst $10
	call Call_50_6197
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld hl, $c180
	call Call_09C7
	call Call_50_61CD
	ld a, b
	ld hl, $0b0e
	cp $01
	jr nz, jr_050_618f

	ld a, c
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c190
	call Call_0C80
	ld hl, $0b23

jr_050_618f:
	call Call_096D

jr_050_6192:
	ld hl, $d9ec
	inc [hl]

Jump_050_6196:
jr_050_6196:
	ret


Call_50_6197::
	call Call_50_61CD
	ld a, [$dd23]
	ld l, a
	ld a, [$dd24]
	ld h, a
	ld a, [$dd25]
	ld e, a
	ld a, b
	push af
	call Call_1E1E
	pop af
	cp $02
	ret z

	cp $03
	jr z, jr_050_61c0

	ld a, l
	sub $01
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, e
	sbc $00
	ld e, a
	ret


jr_050_61c0:
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, e
	adc $00
	ld e, a
	ret


Call_50_61CD::
	ld b, $00
	ld a, [$ca8e]
	call Call_50_62DD
	ld a, [$ca8f]
	call Call_50_62DD
	ld a, [$ca90]
	call Call_50_62DD
	ret


Call_50_61E2::
	call Call_50_6197
	ld a, l
	ldh [$ffd8], a
	ld a, h
	ldh [$ffd9], a
	ld a, e
	ldh [$ffda], a
	ld a, [$dd23]
	ld l, a
	ld a, [$dd24]
	ld h, a
	ld a, [$dd25]
	ld e, a
	ld a, $10
	call Call_1E1E
	ld a, l
	ldh [$ffdb], a
	ld a, h
	ldh [$ffdc], a
	ld a, e
	ldh [$ffdd], a
	ld hl, $cac1
	ld b, $14
	xor a
	ld [$cac0], a

Jump_050_6211:
	push hl
	ld a, [hl]
	or a
	jp z, Jump_050_62c4

	cp $02
	jr z, jr_050_6272

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	or a
	jp nz, Jump_050_62c4

	ld a, l
	add $e8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	cp $63
	jp z, Jump_050_62c4

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jp nc, Jump_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [$ffdb]
	add [hl]
	ld [hli], a
	ld e, a
	ldh a, [$ffdc]
	adc [hl]
	ld [hli], a
	ld d, a
	ldh a, [$ffdd]
	adc [hl]
	ld [hl], a
	ld c, a
	ld a, e
	sub $7f
	ld a, d
	sbc $96
	ld a, c
	sbc $98
	jr c, jr_050_62c4

	ld de, $967f
	ld c, $98
	ld [hl], c
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e
	jr jr_050_62c4

jr_050_6272:
	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	bit 7, [hl]
	jr nz, jr_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $63
	jr z, jr_050_62c4

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jr nc, jr_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [$ffd8]
	add [hl]
	ld [hli], a
	ld e, a
	ldh a, [$ffd9]
	adc [hl]
	ld [hli], a
	ld d, a
	ldh a, [$ffda]
	adc [hl]
	ld [hl], a
	ld c, a
	ld a, e
	sub $7f
	ld a, d
	sbc $96
	ld a, c
	sbc $98
	jr c, jr_050_62c4

	ld de, $967f
	ld c, $98
	ld [hl], c
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e

Jump_050_62c4:
jr_050_62c4:
	pop hl
	push bc
	push hl
	call Call_50_689E
	ld hl, $cac0
	inc [hl]
	pop hl
	pop bc
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jp nz, Jump_050_6211

	ret


Call_50_62DD::
	cp $ff
	ret z

	ld hl, $cb0b
	push af
	push bc
	call Call_223B
	pop bc
	pop af
	bit 7, [hl]
	ret nz

	ld c, a
	inc b
	ret


Jump_50_62F0::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$ca8e]
	call Call_50_6383
	jr nc, jr_050_630d

	ld a, [$ca8f]
	call Call_50_6383
	jr nc, jr_050_630d

	ld a, [$ca90]
	call Call_50_6383
	jr c, jr_050_6316

jr_050_630d:
	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$d9f4], a
	ret


jr_050_6316:
	ld b, $00

jr_050_6318:
	push bc
	ld a, b
	call Call_50_6383
	pop bc
	jr nc, jr_050_6337

	inc b
	ld a, b
	cp $14
	jr nz, jr_050_6318

	ld hl, $d9ec
	inc [hl]
	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$d9f4], a
	ld hl, far_Call_54_55BB
	rst $10
	ret


jr_050_6337:
	ld hl, far_Call_13_40AE
	rst $10
	ld hl, far_Call_51_5B31
	rst $10
	ret


	db $fe, $ff, $c8, $ea, $c0, $ca, $78, $21, $15, $da, $85, $6f, $3e, $00, $8c, $67
	db $e5, $fa, $c0, $ca, $57, $21, $07, $01, $d7, $7a, $e1, $be, $c8, $77, $6f, $26
	db $0a, $11, $90, $c1, $cd, $7a, $09, $fa, $c0, $ca, $21, $c2, $ca, $cd, $3b, $22
	db $5d, $54, $21, $80, $c1, $cd, $80, $0c, $21, $21, $0b, $cd, $6d, $09, $fa, $25
	db $c8, $b7, $c9

Call_50_6383::
	cp $ff
	jr z, jr_050_63a2

	ld [$cac0], a
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $63
	jr z, jr_050_63a2

	ld a, [$cac0]
	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	or a
	jr nz, jr_050_63a4

jr_050_63a2:
	scf
	ret


jr_050_63a4:
	ld hl, far_Call_13_4009
	rst $10
	ld a, [$cac0]
	ld hl, $cb0e
	call Call_223B
	ldh a, [$ffd5]
	ld b, a
	ld a, [hli]
	sub b
	ldh a, [$ffd6]
	ld b, a
	ld a, [hli]
	sbc b
	ldh a, [$ffd7]
	ld b, a
	ld a, [hli]
	sbc b
	ret


Jump_50_63C1::
	ld a, [$db55]
	or a
	jr nz, jr_050_63cc

	ld hl, far_Call_51_5578
	rst $10
	ret


jr_050_63cc:
	ld a, $0e
	ld [$d9ec], a
	ret


Jump_50_63D2::
	ld a, [$d9f4]
	cp $24
	jr z, jr_050_63de

	ld a, [$c825]
	or a
	ret nz

jr_050_63de:
	ld a, [$dd61]
	cp $ff
	jr nz, jr_050_63ea

	ld hl, $d9ec
	inc [hl]
	ret


jr_050_63ea:
	ld a, [$dd61]
	sub $04
	add a
	ld hl, $da03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$da12], a
	ld a, [hl]
	ld [$da13], a
	ld hl, far_Call_14_4869
	rst $10
	ld hl, far_Call_51_5C33
	rst $10
	ret


Jump_50_640A::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_01_4686
	rst $10
	ld hl, $c8ea
	set 7, [hl]
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
	ld a, [$c968]
	cp $5d
	jp nz, Jump_050_64e0

	ld hl, $c8ea
	res 7, [hl]
	ld a, [$d999]
	cp $02
	jr z, jr_050_64a0

	cp $01
	jr z, jr_050_6486

	call Call_50_66D3
	xor a
	ld [$d8d7], a
	ld a, [$db55]
	cp $01
	ret nz

	ld a, $ff
	ld [$d9cd], a
	ld hl, $0006
	ld a, l
	ld [$c96d], a
	ld a, h
	ld [$c96e], a
	ld hl, $00e8
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
	ret


jr_050_6486:
	call Call_50_66D3
	xor a
	ld [$d8d7], a
	ld a, [$db55]
	cp $01
	jr z, jr_050_64af

	ld a, [$d9cd]
	cp $02
	ret nz

	ld a, $02
	ld [$d999], a
	ret


jr_050_64a0:
	xor a
	ld [$d8d7], a
	ld a, $03
	ld [$d999], a
	ld a, [$db55]
	cp $01
	ret nz

jr_050_64af:
	ld a, $08
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
	ld hl, $c8ea
	res 7, [hl]
	ret


Jump_050_64e0:
	ld a, [$c968]
	cp $52
	jr nz, jr_050_64f5

	call Call_50_67AE
	xor a
	ld [$d8d7], a
	ld hl, $c8ea
	res 7, [hl]
	jr jr_050_6546

jr_050_64f5:
	ld a, [$da09]
	cp $02
	jr nz, jr_050_6546

	ld a, [$db55]
	cp $01
	ret nz

	ld b, $00
	ld c, $00
	ld a, [$ca8e]
	call Call_50_6535
	ld a, [$ca8f]
	call Call_50_6535
	ld a, [$ca90]
	call Call_50_6535
	ld a, b
	cp c
	ret nz

	ld a, [$ca8e]
	ld hl, $cb11
	call Call_223B
	ld [hl], $01
	inc hl
	ld [hl], $00
	ld a, [$ca8e]
	ld hl, $cb0b
	call Call_223B
	ld [hl], $00
	ret


Call_50_6535::
	cp $ff
	ret z

	inc b
	ld hl, $cb0b
	call Call_223B
	ld a, [hl]
	and $80
	ld [hl], a
	ret z

	inc c
	ret


jr_050_6546:
	ld a, [$db55]
	cp $01
	jr z, jr_050_6559

	ld a, [$da09]
	cp $03
	ret nz

	ld a, $0e
	ld [$c8ed], a
	ret


jr_050_6559:
	ld a, $08
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
	ld hl, $c8ea
	res 7, [hl]
	ld a, [$ca4b]
	ld l, a
	ld a, [$ca4c]
	ld h, a
	ld a, [$ca4d]
	ld e, a
	ld a, $02
	call Call_1E1E
	ld a, l
	ld [$ca4b], a
	ld a, h
	ld [$ca4c], a
	ld a, e
	ld [$ca4d], a
	ld hl, $ca51
	ld b, $14

jr_050_65ab:
	ld a, [hl]
	or a
	jr z, jr_050_65c7

	cp $ff
	jr z, jr_050_65c7

	ld [$da5e], a
	push hl
	push bc
	ld hl, far_Call_03_6980
	rst $10
	pop bc
	pop hl
	ld a, [$da6d]
	bit 2, a
	jr nz, jr_050_65c7

	ld [hl], $ff

jr_050_65c7:
	inc hl
	dec b
	jr nz, jr_050_65ab

	ld hl, far_Call_03_7160
	rst $10
	xor a
	ldh [$ff90], a
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	ret


Jump_50_65DC::
	ld a, $01
	ld [$c873], a
	ld hl, $d9ec
	inc [hl]
	ret


Jump_50_65E6::
	ld a, [$c86e]
	cp $01
	ret nz

	ld hl, $cacd
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_65f9

	ld hl, $cd21

jr_050_65f9:
	ld de, $c8bb
	ld b, $08
	call Call_50_66CC
	ld a, [$c8ba]
	cp $ff
	jr z, jr_050_6663

	ld a, [$db55]
	or a
	jr z, jr_050_6663

	di
	ld hl, $cac1
	ld de, $a1fb
	ld bc, $0ba4
	call Call_50_66B9
	ei
	ld a, [$c8ba]
	ld hl, $cac1
	call Call_223B
	ld de, $d665
	ld b, $95
	call Call_50_66CC
	ld a, [$c8ba]
	ld hl, $cac1
	call Call_223B
	ld [hl], $00
	di
	ld hl, $ca8d
	ld de, $a1c7
	ld bc, $0007
	call Call_50_66B9
	ei
	ld hl, far_Call_01_46F6
	rst $10
	di
	call Call_2197
	ei
	ld a, $00
	call Call_50_669F
	ld a, $01
	call Call_50_669F
	ld a, $02
	call Call_50_669F
	ld a, $14
	ld [$c8ba], a

jr_050_6663:
	ld a, $04
	call Call_1688
	ld a, $06
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c88e
	inc [hl]
	xor a
	ld [$c865], a
	ld [$c866], a
	xor a
	ld [$c863], a
	ld [$c864], a
	xor a
	ld [$c86c], a
	xor a
	ld [$c86e], a
	xor a
	ld [$c873], a
	xor a
	ld [$c86d], a
	ret


Call_50_669F::
	ld c, a
	ld hl, $c8c4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	cp [hl]
	ret z

	ld a, [$c8ba]
	cp [hl]
	jr z, jr_050_66b6

	ret nc

	dec [hl]
	ret


jr_050_66b6:
	ld [hl], $14
	ret


Call_50_66B9::
	ld a, $0a
	ld [$0100], a

jr_050_66be:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_050_66be

	ld a, $00
	ld [$0100], a
	ret


Call_50_66CC::
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, Call_50_66CC

	ret


Call_50_66D3::
	ld a, [$d9cd]
	cp $03
	ret z

	ld a, [$d9ce]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [$d9cd]
	add b
	ld b, a
	add a
	add b
	ld hl, $00e0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$da03], a
	ld a, h
	ld [$da04], a
	inc hl
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	inc hl
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	ld a, $02
	ld [$da02], a
	ld a, [$d9ce]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [$d9cd]
	add b
	add a
	ld hl, $6778
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$d7ca], a
	ld a, [hl]
	ld [$d7cb], a
	ld a, [$da03]
	ld l, a
	ld a, [$da04]
	ld h, a
	call Call_50_6766
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	call Call_50_6766
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	call Call_50_6766
	ld [$d7d0], a
	ld a, $01
	ld [$d7d1], a
	ret


Call_50_6766::
	ld a, l
	ld [$da12], a
	ld a, h
	ld [$da13], a
	ld hl, far_Call_14_4016
	rst $10
	ld a, [$da18]
	add $10
	ret


	db $0b, $00, $0a, $00, $11, $00, $0b, $00, $0a, $00, $da, $01, $0b, $00, $0a, $00
	db $0b, $00, $0b, $00, $0a, $00, $02, $00, $0b, $00, $0a, $00, $0b, $00, $0b, $00
	db $0a, $00, $0f, $00, $0b, $00, $0a, $00, $0c, $00, $0b, $00, $0a, $00, $13, $00
	db $0b, $00, $0a, $00, $14, $00

Call_50_67AE::
	ld hl, $d7ca
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
	ld a, [$d9cd]
	or a
	jr nz, jr_050_682d

	ld a, $01
	ld [$d9cd], a
	ld a, $02
	ld [$da02], a
	ld a, [$d9d1]
	ld l, a
	ld a, [$d9d2]
	ld h, a
	ld a, l
	ld [$da03], a
	ld a, h
	ld [$da04], a
	call Call_50_6766
	ld [$d7ca], a
	ld a, $01
	ld [$d7cb], a
	ld a, [$da02]
	or a
	ret z

	ld a, [$d9d3]
	ld l, a
	ld a, [$d9d4]
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	call Call_50_6766
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da02]
	cp $01
	ret z

	ld a, [$d9d5]
	ld l, a
	ld a, [$d9d6]
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	call Call_50_6766
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ret


jr_050_682d:
	cp $01
	jr nz, jr_050_6898

	ld a, $02
	ld [$d9cd], a
	ld a, $02
	ld [$da02], a
	ld a, [$d9d9]
	ld l, a
	ld a, [$d9da]
	ld h, a
	ld a, l
	ld [$da03], a
	ld a, h
	ld [$da04], a
	call Call_50_6766
	ld [$d7ca], a
	ld a, $01
	ld [$d7cb], a
	ld a, [$da02]
	or a
	ret z

	ld a, [$d9db]
	ld l, a
	ld a, [$d9dc]
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	call Call_50_6766
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da02]
	cp $01
	ret z

	ld a, [$d9dd]
	ld l, a
	ld a, [$d9de]
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	call Call_50_6766
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ret


jr_050_6898:
	ld a, $03
	ld [$d9cd], a
	ret


Call_50_689E::
	ld a, [hl]
	or a
	ret z

	ld a, l
	add $4b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $63
	jr z, jr_050_68fb

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jr nc, jr_050_68fb

	push hl
	ld a, l
	add $b4
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	pop hl
	cp $01
	jr z, jr_050_68fb

	ld a, [hl]
	push af
	ld a, l
	add $ff
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	pop af
	ld b, [hl]
	ld [hl], a
	push bc
	push hl
	ld a, [$cac0]
	call Call_50_6383
	pop hl
	pop bc
	ld [hl], b
	jr c, jr_050_68fb

	ld a, l
	add $02
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [$ffd5]
	sub $01
	ld [hli], a
	ldh a, [$ffd6]
	sbc $00
	ld [hli], a
	ldh a, [$ffd7]
	sbc $00
	ld [hl], a

jr_050_68fb:
	ret


Call_50_68FC::
	ld a, [$db55]
	cp $02
	jr z, jr_050_6913

	cp $01
	jr z, jr_050_690d

	ld d, $00
	ld e, $03
	jr jr_050_6922

jr_050_690d:
	ld d, $03
	ld e, $01
	jr jr_050_6922

jr_050_6913:
	ld a, [$c86c]
	or a
	jr nz, jr_050_691f

	ld d, $00
	ld e, $01
	jr jr_050_6922

jr_050_691f:
	ld de, $0000

jr_050_6922:
	ld hl, $dd13
	ld b, $04
	ld c, $00

jr_050_6929:
	ld a, c
	call Call_2FA5
	jr c, jr_050_6932

	ld [hl], d
	jr jr_050_6934

jr_050_6932:
	ld [hl], $ff

jr_050_6934:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6929

	ld hl, $dd17
	ld b, $04
	ld c, $04

jr_050_6940:
	ld a, c
	call Call_2FA5
	jr c, jr_050_6949

	ld [hl], e
	jr jr_050_694b

jr_050_6949:
	ld [hl], $ff

jr_050_694b:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6940

	ret


Jump_50_6951::
	ret


jr_050_6952:
	ld de, $cacd
	ld a, [$c863]
	bit 1, a
	jr nz, jr_050_695f

	ld de, $cd21

jr_050_695f:
	ld hl, $c180
	call Call_0C80
	ld a, $01
	ld [$c823], a
	jp Jump_050_6a4f


Call_50_696D::
	call Call_50_6974
	call Call_50_6A65
	ret


Call_50_6974::
	ld a, [$c86c]
	or a
	jr nz, jr_050_6952

	ld a, [$da02]
	or a
	jr z, jr_050_69bb

	cp $01
	jr z, jr_050_6999

	ld a, [$dc40]
	ld b, a
	ld a, [$dc41]
	cp b
	jr z, jr_050_69ab

	ld b, a
	ld a, [$dc42]
	cp b
	jr z, jr_050_69b9

	ld a, $05
	jr jr_050_69bb

jr_050_6999:
	ld a, [$dc40]
	ld b, a
	ld a, [$dc41]
	cp b
	jr z, jr_050_69a7

	ld a, $02
	jr jr_050_69bb

jr_050_69a7:
	ld a, $01
	jr jr_050_69bb

jr_050_69ab:
	ld a, [$dc41]
	ld b, a
	ld a, [$dc42]
	cp b
	jr z, jr_050_69a7

	ld a, $03
	jr jr_050_69bb

jr_050_69b9:
	ld a, $04

jr_050_69bb:
	ld [$db4c], a
	ld a, $00
	ld [$db4d], a
	ret


Call_50_69C4::
	ld a, $00
	ld [$c822], a
	ld a, [$db4d]
	or a
	jr z, jr_050_69d3

	call Call_50_6A26
	ret


jr_050_69d3:
	ld a, [$db4c]
	cp $05
	jr z, jr_050_6a1c

	cp $04
	jr z, jr_050_6a12

	cp $03
	jr z, jr_050_6a08

	cp $02
	jr z, jr_050_69fe

	cp $01
	jr z, jr_050_69f4

	call Call_50_6A65
	ld a, $00
	ld [$c823], a
	jr jr_050_6a4f

jr_050_69f4:
	call Call_50_6A65
	ld a, $01
	ld [$c823], a
	jr jr_050_6a4f

jr_050_69fe:
	call Call_50_6A71
	ld a, $02
	ld [$c823], a
	jr jr_050_6a4f

jr_050_6a08:
	call Call_50_6A65
	ld a, $01
	ld [$c823], a
	jr jr_050_6a57

jr_050_6a12:
	call Call_50_6A65
	ld a, $00
	ld [$c823], a
	jr jr_050_6a57

jr_050_6a1c:
	call Call_50_6A71
	ld a, $02
	ld [$c823], a
	jr jr_050_6a57

Call_50_6A26::
	ld a, [$db4c]
	cp $05
	jr z, jr_050_6a45

	cp $04
	jr z, jr_050_6a3b

	call Call_50_6A94
	ld a, $00
	ld [$c823], a
	jr jr_050_6a4f

jr_050_6a3b:
	call Call_50_6A88
	ld a, $01
	ld [$c823], a
	jr jr_050_6a4f

jr_050_6a45:
	call Call_50_6A94
	ld a, $00
	ld [$c823], a
	jr jr_050_6a4f

Jump_050_6a4f:
jr_050_6a4f:
	call Call_50_6AA3
	ld hl, $d9ec
	inc [hl]
	ret


jr_050_6a57:
	call Call_50_6AA3
	ld a, $01
	ld [$db4d], a
	ld a, $05
	ld [$da33], a
	ret


Call_50_6A65::
	ld a, $04
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D7F
	ret


Call_50_6A71::
	ld a, $04
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D7F
	ld a, $05
	ld hl, $c190
	ld [$db50], a
	call Call_50_7D7F
	ret


Call_50_6A88::
	ld a, $05
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D7F
	ret


Call_50_6A94::
	ld a, $06
	ld hl, $c180
	ld [$db50], a
	call Call_50_7D7F
	ret


Call_50_6AA0::
	ld [$c823], a

Call_50_6AA3::
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_50_6AAC::
	ld a, [$d9ed]
	rst $00

JumpTable_50_6AB0::
	dw Jump_50_6ABC
	dw Jump_50_6B11
	dw Jump_50_6B25
	dw Jump_50_6C02
	dw Jump_50_6C9B
	dw Jump_50_6D0C

Jump_50_6ABC::
	ld hl, $db00
	res 4, [hl]
	res 6, [hl]
	inc hl
	res 4, [hl]
	res 6, [hl]
	inc hl
	ld b, $08

jr_050_6acb:
	inc hl
	inc hl
	res 7, [hl]
	inc hl
	inc hl
	ld a, [hl]
	rrca
	and $55
	ld [hli], a
	ld a, [hl]
	and $30
	call nz, Call_50_6B06
	inc hl
	ld a, [hl]
	and $c0
	ld [hli], a
	xor a
	ld [hli], a
	dec b
	jr nz, jr_050_6acb

	ld b, $08
	xor a

jr_050_6ae9:
	ld [hli], a
	dec b
	jr nz, jr_050_6ae9

	ld a, [hl]
	and $03
	ld [hli], a
	ld a, [hl]
	and $03
	ld [hli], a
	ld hl, $d9ed
	inc [hl]
	xor a
	ld [$db88], a
	ld [$d9f2], a
	ld [$d9f3], a
	jr Jump_50_6B11

	db $c9

Call_50_6B06::
	ld a, [hl]
	and $cf
	ld e, a
	ld a, [hl]
	rrca
	and $10
	or e
	ld [hl], a
	ret


Jump_50_6B11::
	ld hl, $d9ed
	inc [hl]
	ld a, [$db88]
	call Call_2FA5
	jr nc, Jump_50_6B25

	ld a, $05
	ld [$d9ed], a
	jp Jump_50_6D0C


Jump_50_6B25::
	ld hl, $d9ed
	inc [hl]
	ld a, [$db88]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $3f
	ld d, a
	ld a, [hl]
	and $c0
	jp z, Jump_050_6b5e

	ld b, $00
	push hl
	push de
	sub $40
	jr nz, jr_050_6b4f

	call Call_50_7E1E
	ld a, $dd
	call Call_50_6AA0
	xor a
	ld b, $01

jr_050_6b4f:
	pop de
	pop hl
	or d
	ld [hl], a
	ld a, $05
	ld [$d9ed], a
	ld a, b
	or a
	jp z, Jump_50_6D0C

	ret


Jump_050_6b5e:
	ld a, [$db88]
	ld hl, $db02
	call Call_2F6C
	ld a, [hl]
	and $03
	jr nz, jr_050_6b74

	ld a, $05
	ld [$d9ed], a
	jp Jump_50_6D0C


jr_050_6b74:
	bit 0, a
	jr z, jr_050_6b81

	ld a, $e1
	ld [$db4c], a
	ld d, $10
	jr jr_050_6b88

jr_050_6b81:
	ld a, $e2
	ld [$db4c], a
	ld d, $06

jr_050_6b88:
	ld a, [$db88]
	call Call_2FDA
	ld a, d
	call Call_1E0D
	ld a, h
	or l
	jr nz, jr_050_6b99

	ld hl, $0001

jr_050_6b99:
	call Call_50_6BC4
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	ld a, [$db88]
	call Call_50_7E1E
	ld hl, $c190
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Call_0A7C
	ld a, [$db4c]
	call Call_50_6AA0
	ld a, $05
	ld [$da33], a
	ret


Call_50_6BC4::
	ld a, [$db4c]
	cp $e1
	jr z, jr_050_6be7

	ld bc, $001e
	call Call_2F45
	jr c, jr_050_6c01

	ld a, [$c899]
	ld l, a
	ld a, [$c89a]
	ld h, a
	ld a, $0b
	call Call_1E0D
	add $1e
	ld l, a
	ld h, $00
	jr jr_050_6c01

jr_050_6be7:
	ld bc, $000a
	call Call_2F45
	jr c, jr_050_6c01

	ld a, [$c899]
	ld l, a
	ld a, [$c89a]
	ld h, a
	ld a, $06
	call Call_1E0D
	add $0a
	ld l, a
	ld h, $00

jr_050_6c01:
	ret


Jump_50_6C02::
	ld a, [$da33]
	or a
	jr z, jr_050_6c14

	dec a
	ld [$da33], a
	or a
	ret nz

	ld a, $fd
	call Call_50_6AA0
	ret


jr_050_6c14:
	ld hl, $d9ed
	inc [hl]
	ld a, [$db88]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Call_2F45
	jr z, jr_050_6c40

	jr c, jr_050_6c40

	ld a, l
	sub c
	ld c, a
	ld a, h
	sbc b
	ld b, a
	jr jr_050_6c43

jr_050_6c40:
	ld bc, $0000

jr_050_6c43:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, b
	or c
	jr z, jr_050_6c59

	call Call_50_79B4
	call Call_50_7627
	ld a, $05
	ld [$d9ed], a
	jp Jump_50_6D0C


jr_050_6c59:
	ld a, [$db88]
	ld [$db89], a
	ld hl, far_Call_58_5749
	rst $10
	ld a, [$db88]
	ld [$db4c], a
	ld hl, far_Call_51_4BE8
	rst $10
	call Call_50_7C4D
	ld a, $04
	ld [$d9ed], a
	ld a, [$db88]
	call Call_50_7E1E
	ld a, $ea
	call Call_50_6AA0
	call Call_50_79B4
	call Call_50_7627
	ld a, [$c86c]
	or a
	ret nz

	ld a, [$db88]
	cp $04
	ret c

	cp $07
	ret z

	ld a, [$db88]
	ld [$dd61], a
	ret


Jump_50_6C9B::
	ld hl, $d9ed
	inc [hl]
	ld a, [$db88]
	and $04
	ld c, a
	ld b, $03
	ld a, [$c86c]
	or a
	jr nz, jr_050_6cd3

	ld a, [$db88]
	cp $04
	jr c, jr_050_6cd3

jr_050_6cb4:
	ld a, c
	call Call_2FA5
	jr nc, Jump_50_6D0C

	inc c
	dec b
	jr nz, jr_050_6cb4

jr_050_6cbe:
	ld a, $00
	ld [$db55], a

jr_050_6cc3:
	ld a, $0a
	ld [$d9ec], a
	ld a, $02
	call Call_1AE1
	ld a, $02
	ld [$db4e], a
	ret


jr_050_6cd3:
	ld a, c
	call Call_2FA5
	jr c, jr_050_6ce4

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 6, [hl]
	jr z, Jump_50_6D0C

jr_050_6ce4:
	inc c
	dec b
	jr nz, jr_050_6cd3

	ld a, $01
	ld [$db55], a
	ld a, [$c86c]
	or a
	jr z, jr_050_6cc3

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_6d03

	ld a, [$db88]
	cp $04
	jr nc, jr_050_6cc3

	jr jr_050_6cbe

jr_050_6d03:
	ld a, [$db88]
	cp $04
	jr c, jr_050_6cc3

	jr jr_050_6cbe

Jump_50_6D0C::
	ld hl, $db88
	inc [hl]
	ld a, [hl]
	cp $08
	jr z, jr_050_6d22

	call Call_2FA5
	jr c, Jump_50_6D0C

	ld a, $01
	ld [$d9ed], a
	jp Jump_50_6B11


jr_050_6d22:
	ld bc, $0300
	ld de, $0001
	ld hl, $dd13
	ld a, [$c86c]
	or a
	jr z, jr_050_6d33

	ld e, $00

jr_050_6d33:
	ld a, c
	call Call_2FA5
	jr c, jr_050_6d3c

	ld [hl], d
	jr jr_050_6d3e

jr_050_6d3c:
	ld [hl], $ff

jr_050_6d3e:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6d33

	ld a, c
	call Call_2FA5
	jr c, jr_050_6d4b

	ld [hl], $01

jr_050_6d4b:
	inc hl
	inc c
	ld bc, $0304

jr_050_6d50:
	ld a, c
	call Call_2FA5
	jr c, jr_050_6d59

	ld [hl], e
	jr jr_050_6d5b

jr_050_6d59:
	ld [hl], $ff

jr_050_6d5b:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6d50

	ld a, c
	call Call_2FA5
	jr c, jr_050_6d68

	ld [hl], $01

jr_050_6d68:
	inc hl
	inc c
	ld a, $03
	ld [$d9ec], a
	ld hl, $db76
	ld a, [hl]
	cp $ff
	ret z

	inc [hl]
	ret


Call_50_6D78::
	ld a, [$cab5]
	inc a
	ld [$cab5], a
	cp $3c
	ret nz

	xor a
	ld [$cab5], a
	ld a, [$cab6]
	inc a
	ld [$cab6], a
	cp $3c
	ret nz

	xor a
	ld [$cab6], a
	ld a, [$cab7]
	inc a
	ld [$cab7], a
	cp $3c
	ret nz

	xor a
	ld [$cab7], a
	ld a, [$cab8]
	inc a
	ld [$cab8], a
	cp $64
	ret nz

	ld a, $63
	ld [$cab8], a
	ld a, $3b
	ld [$cab7], a
	ld [$cab6], a
	xor a
	ld [$cab5], a
	ret


	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $70, $71, $72, $73, $da, $e0, $74, $75
	db $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0
	db $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e2
	db $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e1, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $84, $9c
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $6c, $6d, $6e, $6f, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $fd, $d9, $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $96, $88, $91, $8d, $87, $8a, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8b, $86, $94, $8a, $95, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $91, $8e, $89, $86, $90, $8e, $8c, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $96, $90, $8b, $8b, $91, $8f
	db $95, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $95, $96, $97, $98, $99
	db $9a, $9b, $9c, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a7
	db $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $85, $86, $87, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e0, $7e, $84, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $88, $87, $89, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $85, $86, $87
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72
	db $73, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76
	db $77, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a
	db $7b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $20, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $86, $88, $87, $e0, $ff, $d8, $ec, $eb, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72, $73, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76, $77, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a, $7b, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94
	db $95, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a0
	db $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $d4, $e0, $d5, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $48, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $36
	db $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $3f, $40, $41, $42, $43, $44, $45
	db $46, $47, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $51, $52, $53
	db $54, $55, $56, $57, $58, $59, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9e
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $40, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $82, $83, $84, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $90, $91, $92, $93, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $94, $95, $96, $97, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $98, $99, $9a, $9b, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $0d, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $89, $8a, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $20, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
	db $10, $11, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $12, $13, $14, $15, $16, $17
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
	db $30, $31, $32, $33, $34, $35, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $c0, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9c, $d6, $d5, $e0, $e2, $e3
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a0, $a1, $a2, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a3, $a4, $a5, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $24, $25, $26, $27, $28, $29, $2a, $2b
	db $2c, $48, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $49, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $4a, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $3f, $40, $41, $42
	db $43, $44, $45, $46, $47, $4b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $0c, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $a6, $a7, $a8, $a9, $aa, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $89, $8a, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $c0, $00, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $6c
	db $6d, $6e, $6f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $89, $82, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $82, $86, $81, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $83, $8a, $85, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2
	db $a3, $a4, $a5, $a6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Call_50_756B::
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


Call_50_757A::
	ld a, [$d9f8]
	add l
	ld l, a
	ld a, [$d9f9]
	adc h
	and $03
	ld h, a
	ld a, [$d9f9]
	and $fc
	or h
	ld h, a
	ret


Call_50_758E::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_50_7597::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_50_757A
	ld a, b
	and $1f
	jr z, jr_050_75ac

	ld b, a

jr_050_75a6:
	call Call_50_756B
	dec b
	jr nz, jr_050_75a6

jr_050_75ac:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $97, $75, $7d, $ea, $ea, $d9, $7c, $ea, $eb
	db $d9, $1a, $13, $fe, $d9, $c8, $fe, $d8, $20, $20, $fa, $ea, $d9, $6f, $fa, $eb
	db $d9, $67, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67
	db $7d, $ea, $ea, $d9, $7c, $ea, $eb, $d9, $18, $d7, $cd, $ad, $1a, $cd, $6b, $75
	db $18, $cf

Call_50_75F0::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_50_758E
	ld a, l
	ld [$d9ea], a
	ld a, h
	ld [$d9eb], a

jr_050_7601:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_050_7624

	ld a, [$d9ea]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [$d9ea], a
	ld a, h
	ld [$d9eb], a
	jr jr_050_7601

jr_050_7624:
	ld [hli], a
	jr jr_050_7601

Call_50_7627::
	ld a, [$db74]
	ld c, a
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7636

	ld a, [$db75]
	ld c, a

jr_050_7636:
	push bc
	ld b, $25
	ld c, $62
	call Call_50_7656
	pop bc
	dec c
	ret z

	push bc
	ld b, $2b
	ld c, $68
	call Call_50_7656
	pop bc
	dec c
	ret z

	push bc
	ld b, $31
	ld c, $6e
	call Call_50_7656
	pop bc
	ret


Call_50_7656::
	ld l, b
	ld h, $98
	ld a, b
	ld de, $c500
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	call Call_1AAD
	ld b, $03
	ld l, c
	ld h, $98
	ld a, c
	ld de, $c500
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call Call_50_76B2
	ld b, $03
	ld a, c
	add $20
	ld l, a
	ld h, $98
	ld de, $c500
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call Call_50_76B2
	ret


Call_50_768E::
	ld a, [$d9f8]
	ld l, a
	ld a, [$d9f9]
	ld h, a
	ld de, $c500
	ld c, $12

jr_050_769b:
	ld b, $20
	push hl
	call Call_50_76B2
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
	jr nz, jr_050_769b

	ret


Call_50_76B2::
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
	jr nz, Call_50_76B2

	ret


Call_50_76C7::
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


Call_50_7700::
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


Call_50_774E::
	ld hl, $c500
	ld bc, $0240

jr_050_7754:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_050_7754

	ret


	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

Call_50_776E::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_050_77d5

	ld a, [$c847]
	bit 5, a
	jr z, jr_050_779b

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
	jr c, jr_050_77b9

	ld a, c
	dec a
	jr jr_050_77b9

jr_050_779b:
	ld a, [$c847]
	bit 4, a
	jr z, jr_050_77d5

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
	jr c, jr_050_77b9

	ld a, $00

jr_050_77b9:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_050_7818

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
	jr z, jr_050_7818

	dec a
	cp [hl]
	jr nc, jr_050_7818

	ld [hl], a
	jr jr_050_7818

Jump_050_77d5:
jr_050_77d5:
	push bc
	push de
	push hl
	call Call_50_78B0
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
	jr nz, Call_50_77F7

	ld a, [$c8e1]
	inc a
	ld b, a

Call_50_77F7::
	res 7, [hl]
	ld a, [$c847]
	bit 6, a
	jr z, jr_050_7809

	ld a, [hl]
	dec a
	cp b
	jr c, jr_050_7817

	dec b
	ld a, b
	jr jr_050_7817

jr_050_7809:
	ld a, [$c847]
	bit 7, a
	jr z, jr_050_7820

	ld a, [hl]
	inc a
	cp b
	jr c, jr_050_7817

	ld a, $00

Jump_050_7817:
jr_050_7817:
	ld [hl], a

jr_050_7818:
	xor a
	ld [$d9fb], a
	push hl
	push de
	pop de
	pop hl

Jump_050_7820:
jr_050_7820:
	ld a, [$c846]
	bit 0, a
	jr z, jr_050_7829

	set 7, [hl]

jr_050_7829:
	ld a, [hl]
	call Call_50_784D
	ret


Call_50_782E::
	res 7, [hl]
	ld a, [$c847]
	and $c0
	jr z, jr_050_783c

	ld a, [hl]
	xor $01
	jr jr_050_7817

jr_050_783c:
	ld a, [$c847]
	and $30
	jr z, jr_050_7820

	ld a, [hl]
	xor $02
	jr jr_050_7817

Call_50_7848::
	xor a
	ld [$d9fb], a
	ret


Call_50_784D::
	ld c, a
	bit 7, a
	jr nz, jr_050_7862

	ld a, [$d9fb]
	and $0f
	push af
	ld a, [$d9fb]
	inc a
	ld [$d9fb], a
	pop af
	ld a, c
	ret nz

jr_050_7862:
	ld c, a
	ld b, $00

jr_050_7865:
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
	ld [$d9ea], a
	ld a, h
	ld [$d9eb], a
	push de
	push bc
	call Call_50_7597
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_050_7897

	ld a, $e9
	bit 7, c
	jr nz, jr_050_7897

	ld a, [$d9fb]
	bit 4, a
	ld a, $e0
	jr nz, jr_050_7897

	ld a, $e8

jr_050_7897:
	call Call_1AAD
	push af
	ld a, [$d9ea]
	ld l, a
	ld a, [$d9eb]
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
	jr jr_050_7865

Call_50_78B0::
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
	call Call_50_7597
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


Call_50_78E9::
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
	jr nc, jr_050_7902

	ld a, $e7

jr_050_7902:
	ld [hld], a
	pop bc
	jr nc, jr_050_790a

	ld a, [bc]
	add $f1
	ld [hl], a

jr_050_790a:
	pop af

Call_50_790B::
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
	ld [$d9ea], a
	ld a, h
	ld [$d9eb], a
	push de
	push bc
	call Call_50_7597
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_050_7938

	ld a, [$d9fb]
	bit 4, a
	ld a, $e0
	jr nz, jr_050_7938

	ld a, $e8

jr_050_7938:
	push af
	ld a, [$d9ea]
	ld l, a
	ld a, [$d9eb]
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


Call_50_794C::
	ld a, [$c86c]
	or a
	jr z, jr_050_795e

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_795e

	ld a, [$db74]
	jr jr_050_7961

jr_050_795e:
	ld a, [$db75]

jr_050_7961:
	cp $03
	jr z, jr_050_7981

	cp $02
	jr z, jr_050_7972

	ld a, $00
	ld hl, $00c7
	call Call_50_7996
	ret


jr_050_7972:
	ld a, $00
	ld hl, $00c4
	call Call_50_7996
	ld hl, $00ca
	call Call_50_7996
	ret


jr_050_7981:
	ld a, $00
	ld hl, $00c1
	call Call_50_7996
	ld hl, $00c7
	call Call_50_7996
	ld hl, $00cd
	call Call_50_7996
	ret


Call_50_7996::
	ld c, $06

jr_050_7998:
	push hl
	push af
	call Call_50_758E
	pop af
	ld b, $06

jr_050_79a0:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_050_79a0

	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, jr_050_7998

	ret


Call_50_79AE::
	ld de, $2e07
	call Call_50_75F0

Call_50_79B4::
	ld a, [$d9f3]
	or a
	jp nz, Call_50_7A87

Call_50_79BB::
	ld a, [$c86c]
	or a
	jr nz, jr_050_79c6

	ld a, [$ca8d]
	or a
	ret z

jr_050_79c6:
	call Call_50_79CB
	jr Call_50_79EB

Call_50_79CB::
	ld hl, $7a7f
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_79da

	ld a, [$db75]
	jr jr_050_79dd

jr_050_79da:
	ld a, [$db74]

jr_050_79dd:
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	call Call_50_75F0
	ret


Call_50_79EB::
	ld hl, $dba3
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_79f8

	ld hl, $dbab

jr_050_79f8:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0062
	call Call_50_758E
	call Call_2071
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0082
	call Call_50_758E
	call Call_2071
	ld a, [$c1d9]
	cp $01
	ret z

	ld hl, $dba5
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7a29

	ld hl, $dbad

jr_050_7a29:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0068
	call Call_50_758E
	call Call_2071
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0088
	call Call_50_758E
	call Call_2071
	ld a, [$c1d9]
	cp $02
	ret z

	ld hl, $dba7
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7a5a

	ld hl, $dbaf

jr_050_7a5a:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $006e
	call Call_50_758E
	call Call_2071
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $008e
	call Call_50_758E
	call Call_2071
	ret


	db $eb, $79, $16, $7a, $47, $7a, $9a, $6e, $9a, $6e, $3e, $6e, $be, $6d

Call_50_7A87::
	cp $03
	jp z, Call_50_7B8F

	call Call_50_79CB
	ld hl, $9800
	ld a, l
	ld [$d9f8], a
	ld a, h
	ld [$d9f9], a
	ld a, [$c1d9]
	ld b, a
	ld c, $00
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7aa9

	ld c, $04

jr_050_7aa9:
	ld hl, $7bee
	call Call_50_7C06
	push hl
	ld a, c
	call Call_2FA5
	jr nc, jr_050_7aba

	ld a, $d9
	jr jr_050_7abc

jr_050_7aba:
	ld a, $e0

jr_050_7abc:
	pop hl
	ld [hl], a
	ld hl, $7bf4
	call Call_50_7C06
	ld [hl], $de
	inc hl
	ld a, $e4
	ld [hld], a
	ld a, $20
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	inc c
	dec b
	jr nz, jr_050_7aa9

	ld a, [$d9f3]
	cp $02
	jr z, jr_050_7b0a

	call Call_50_768E
	ld hl, $8da0
	ld a, $02
	call Call_50_7C2A
	ld hl, $8db0
	ld a, $04
	call Call_50_7C2A
	ld hl, $8dc0
	ld a, $06
	call Call_50_7C2A
	ld hl, $8dd0
	ld a, $03
	call Call_50_7C2A
	ld hl, $d9f3
	inc [hl]

jr_050_7b0a:
	ld a, [$c1d9]
	ld b, a
	ld c, $00
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7b19

	ld c, $04

jr_050_7b19:
	ld hl, $7bf4
	call Call_50_7C06
	inc hl
	inc hl
	push bc
	ld a, c
	ld bc, $db9b
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	ld c, a
	ld b, $00
	call Call_2082
	pop bc
	ld a, c
	call Call_2FA5
	jr c, jr_050_7b87

	ld hl, $7bfa
	call Call_50_7C06
	push hl
	ld a, c
	ld hl, $db02
	call Call_2F6C
	pop de
	ld a, [hl]
	or a
	jr z, jr_050_7b87

	bit 6, [hl]
	jr z, jr_050_7b56

	ld a, $00
	call Call_50_7C1C

jr_050_7b56:
	inc de
	bit 5, [hl]
	jr z, jr_050_7b60

	ld a, $01
	call Call_50_7C1C

jr_050_7b60:
	inc de
	bit 4, [hl]
	jr z, jr_050_7b6a

	ld a, $02
	call Call_50_7C1C

jr_050_7b6a:
	inc de
	bit 7, [hl]
	jr z, jr_050_7b74

	ld a, $03
	call Call_50_7C1C

jr_050_7b74:
	inc de
	bit 1, [hl]
	jr z, jr_050_7b7e

	ld a, $04
	call Call_50_7C1C

jr_050_7b7e:
	bit 0, [hl]
	jr z, jr_050_7b87

	ld a, $05
	call Call_50_7C1C

jr_050_7b87:
	inc c
	dec b
	jr nz, jr_050_7b19

	call Call_50_768E
	ret


Call_50_7B8F::
	ld a, [$c1d9]
	ld b, a
	ld c, $00
	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7b9e

	ld c, $04

jr_050_7b9e:
	ld hl, $7bee
	call Call_50_7C06
	ld a, c
	and $03
	add $da
	ld [hl], a
	ld hl, $7bf4
	call Call_50_7C06
	ld [hl], $e1
	ld a, $20
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $e2
	ld [hli], a
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, c
	ld [$db88], a
	ld [$db89], a
	push af
	push bc
	push de
	push hl
	ld hl, $da0a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	call Call_50_7C4D
	pop hl
	pop de
	pop bc
	pop af
	inc c
	dec b
	jr nz, jr_050_7b9e

	xor a
	ld [$d9f3], a
	call Call_50_79BB
	call Call_50_768E
	ret


	db $25, $00, $2b, $00, $31, $00, $61, $00, $67, $00, $6d, $00, $81, $00, $87, $00
	db $8d, $00, $dc, $d7, $db, $dd, $da, $d8

Call_50_7C06::
	ld a, c
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
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_50_7C1C::
	push hl
	ld hl, $7c00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [de], a
	pop hl
	ret


Call_50_7C2A::
	push hl
	ld hl, $7c3d
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call Call_1577
	ret


	db $02, $5b, $03, $5b, $04, $5b, $05, $5b, $06, $5b, $07, $5b, $08, $5b, $09, $5b

Call_50_7C4D::
	ld a, [$c86c]
	or a
	jr z, jr_050_7c73

	ld a, [$c863]
	bit 1, a
	jr z, jr_050_7c73

	ld a, [$db89]
	ld c, a
	cp $04
	jr c, jr_050_7c67

	cp $07
	ret z

	jr jr_050_7c84

jr_050_7c67:
	ld a, [$db88]
	ld c, a
	cp $04
	ret c

	cp $07
	ret z

	jr jr_050_7c84

jr_050_7c73:
	ld a, [$db89]
	ld c, a
	cp $03
	jr c, jr_050_7c86

	ld a, [$db88]
	ld c, a
	cp $03
	jr c, jr_050_7c86

	ret


jr_050_7c84:
	xor $04

jr_050_7c86:
	push de
	swap a
	ld hl, $8da0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, c
	call Call_2FA5
	jr c, jr_050_7cbc

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 6, [hl]
	jr nz, jr_050_7cc0

	bit 5, [hl]
	jr nz, jr_050_7cc4

	bit 4, [hl]
	jr nz, jr_050_7cc8

	bit 7, [hl]
	jr nz, jr_050_7ccc

	bit 1, [hl]
	jr nz, jr_050_7cd0

	bit 0, [hl]
	jr nz, jr_050_7cd4

	ld a, $00
	jr jr_050_7cd6

jr_050_7cbc:
	ld a, $07
	jr jr_050_7cd6

jr_050_7cc0:
	ld a, $06
	jr jr_050_7cd6

jr_050_7cc4:
	ld a, $05
	jr jr_050_7cd6

jr_050_7cc8:
	ld a, $04
	jr jr_050_7cd6

jr_050_7ccc:
	ld a, $03
	jr jr_050_7cd6

jr_050_7cd0:
	ld a, $02
	jr jr_050_7cd6

jr_050_7cd4:
	ld a, $01

jr_050_7cd6:
	push af
	ld a, c
	ld hl, $da0a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld d, [hl]
	pop af
	cp d
	call nz, Call_50_7CED
	pop hl
	call nz, Call_50_7C2A
	pop de
	ret


Call_50_7CED::
	ld [hl], a
	ret


	db $fa, $1d, $c8, $b7, $c8, $3e, $01, $e0, $4f, $fa, $f8, $d9, $6f, $fa, $f9, $d9
	db $67, $0e, $12, $06, $20, $e5, $3e, $00, $cd, $ad, $1a, $7d, $e6, $e0, $f5, $7d
	db $3c, $e6, $1f, $6f, $f1, $b5, $6f, $05, $20, $ec, $e1, $c5, $01, $20, $00, $09
	db $7c, $e6, $03, $f6, $98, $67, $c1, $0d, $20, $d9, $3e, $00, $e0, $4f, $c9

Call_50_7D2E::
	cp $03
	jr nc, jr_050_7d4c

Call_50_7D32::
	push hl
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0C80
	pop hl

jr_050_7d41:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_050_7d41

jr_050_7d48:
	ld a, b
	pop bc
	jr Call_50_7D32

jr_050_7d4c:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_050_7d75

	push bc
	ld b, a
	ld a, [$c86c]
	or a
	jr nz, jr_050_7d48

	push hl
	ld a, b
	and $03
	ld hl, $c1ca
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	cp $ff
	jr nz, jr_050_7d72

	ld a, b

jr_050_7d72:
	pop bc
	jr nz, jr_050_7d9d

jr_050_7d75:
	push af
	call Call_50_7D7F
	pop af
	ld hl, far_Call_51_4CB3
	rst $10
	ret


Call_50_7D7F::
	ld [$db60], a
	push hl
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld l, a
	ld h, $05
	pop de
	ld a, e
	ld [$db5e], a
	ld a, d
	ld [$db5f], a
	call Call_097A
	ret


jr_050_7d9d:
	call Call_50_7D32
	ld a, $2f
	ld [hli], a
	ld a, $46
	ld [hli], a
	ld a, $48
	ld [hli], a
	ld a, $42
	ld [hli], a
	ld [hl], $f0
	push hl
	ld hl, $c1ca
	ld a, [$db50]
	and $03
	cp $01
	jr z, jr_050_7dc9

	cp $02
	jr z, jr_050_7dd3

	ld a, [hli]
	cp [hl]
	jr z, jr_050_7def

	inc hl
	cp [hl]
	jr z, jr_050_7def

	jr jr_050_7dfe

jr_050_7dc9:
	ld a, [hli]
	cp [hl]
	jr z, jr_050_7df4

	ld a, [hli]
	cp [hl]
	jr z, jr_050_7def

	jr jr_050_7dfe

jr_050_7dd3:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_050_7ddd

	inc d

jr_050_7ddd:
	inc hl
	cp [hl]
	jr nz, jr_050_7de2

	inc d

jr_050_7de2:
	ld a, d
	or a
	jr z, jr_050_7dfe

	cp $01
	jr z, jr_050_7df4

	pop hl
	ld a, $03
	jr jr_050_7df7

jr_050_7def:
	pop hl
	ld a, $01
	jr jr_050_7df7

jr_050_7df4:
	pop hl
	ld a, $02

jr_050_7df7:
	ld [$db4d], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_050_7dfe:
	pop hl
	xor a
	ld [$db4d], a
	ret


	db $21, $a0, $c1, $18, $03, $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db
	db $fa, $89, $db, $ea, $50, $db, $cd, $2e, $7d, $c9

Call_50_7E1E::
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db88]
	ld [$db50], a
	call Call_50_7D2E
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
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
