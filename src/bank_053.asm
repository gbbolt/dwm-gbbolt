INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $053", ROMX[$4000], BANK[$53]

BankNumber_53::
	db $53

FarTable_53::
	dw Call_53_44CA
	dw Call_53_4BEB
	dw Call_53_4C50
	dw Call_53_4D7E
	dw Call_53_4F4C
	dw Call_53_51E8
	dw Call_53_5CBC
	dw Call_53_5D22
	dw Call_53_5D22
	dw Call_53_5E35
	dw Call_53_601C
	dw Call_53_60B3
	dw Call_53_65AC
	dw Call_53_670E
	dw Call_53_6A9B
	dw Call_53_6BE2
	dw Call_53_51AA
	dw Call_53_5F15

	db $02, $02, $02, $02, $02, $03, $02, $02, $03, $02, $03, $02, $03, $02, $02, $02
	db $02, $02, $01, $01, $01, $01, $01, $01, $01, $02, $01, $02, $02, $02, $00, $01
	db $01, $01, $01, $02, $01, $01, $02, $02, $01, $01, $01, $01, $00, $01, $02, $01
	db $02, $02, $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $02, $02, $03, $02, $02, $02, $02, $02, $03, $02
	db $02, $02, $02, $02, $02, $02, $02, $01, $02, $01, $02, $02, $02, $02, $03, $03
	db $02, $02, $02, $02, $03, $02, $02, $02, $03, $02, $03, $01, $01, $03, $02, $01
	db $02, $02, $02, $02, $01, $01, $02, $03, $02, $01, $01, $02, $02, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $00, $01, $00, $00, $01, $00, $00, $02, $01, $02, $02, $02
	db $01, $01, $02, $02, $02, $02, $01, $01, $01, $01, $01, $02, $01, $00, $02, $02
	db $01, $02, $02, $02, $02, $02, $01, $02, $02, $01, $01, $02, $02, $01, $02, $02
	db $01, $01, $02, $02, $01, $01, $02, $00, $01, $00, $01, $00, $01, $00, $00, $00
	db $01, $00, $01, $01, $00, $00, $00, $00, $02, $02, $01, $01, $02, $00, $00, $01
	db $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	db $00, $00, $01, $01, $01, $00, $01, $00, $01, $00, $00, $00, $01, $01, $01, $01
	db $01, $01, $01, $00, $01, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $01
	db $00, $01, $00, $01, $01, $00, $01, $01, $01, $01, $00, $01, $01, $01, $01, $00
	db $00, $00, $00, $00, $01, $00, $00, $01, $00, $01, $01, $00, $00, $01, $01, $01
	db $01, $01, $01, $01, $01, $00, $00, $01, $01, $00, $00, $01, $01, $00, $01, $00
	db $01, $00, $00, $00, $01, $00, $00, $01, $01, $01, $03, $00, $00, $00, $00, $01
	db $00, $00, $00, $00, $00, $01, $00, $01, $01, $01, $00, $01, $01, $01, $00, $00
	db $01, $01, $00, $01, $00, $01, $01, $00, $00, $00, $01, $01, $01, $01, $01, $01
	db $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01
	db $00, $00, $01, $01, $00, $01, $01, $01, $00, $01, $00, $00, $01, $01, $00, $00
	db $00, $00, $01, $00, $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $01, $00
	db $00, $00, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	db $00, $01, $01, $01, $01, $01, $01, $00, $01, $00, $00, $01, $01, $01, $01, $01
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Call_53_43C5::
	cp $03
	jr nc, jr_053_43e3

Call_53_43C9::
	push hl
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0C80
	pop hl

jr_053_43d8:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_053_43d8

jr_053_43df:
	ld a, b
	pop bc
	jr Call_53_43C9

jr_053_43e3:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_053_440c

	push bc
	ld b, a
	ld a, [$c86c]
	or a
	jr nz, jr_053_43df

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
	jr nz, jr_053_4409

	ld a, b

jr_053_4409:
	pop bc
	jr nz, jr_053_4434

jr_053_440c:
	push af
	call Call_53_4416
	pop af
	ld hl, far_Call_51_4CB3
	rst $10
	ret


Call_53_4416::
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


jr_053_4434:
	call Call_53_43C9
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
	jr z, jr_053_4460

	cp $02
	jr z, jr_053_446a

	ld a, [hli]
	cp [hl]
	jr z, jr_053_4486

	inc hl
	cp [hl]
	jr z, jr_053_4486

	jr jr_053_4495

jr_053_4460:
	ld a, [hli]
	cp [hl]
	jr z, jr_053_448b

	ld a, [hli]
	cp [hl]
	jr z, jr_053_4486

	jr jr_053_4495

jr_053_446a:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_053_4474

	inc d

jr_053_4474:
	inc hl
	cp [hl]
	jr nz, jr_053_4479

	inc d

jr_053_4479:
	ld a, d
	or a
	jr z, jr_053_4495

	cp $01
	jr z, jr_053_448b

	pop hl
	ld a, $03
	jr jr_053_448e

jr_053_4486:
	pop hl
	ld a, $01
	jr jr_053_448e

jr_053_448b:
	pop hl
	ld a, $02

jr_053_448e:
	ld [$db4d], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_053_4495:
	pop hl
	xor a
	ld [$db4d], a
	ret


	db $21, $a0, $c1, $18, $03

Call_53_44A0::
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db89]
	ld [$db50], a
	call Call_53_43C5
	ret


Call_53_44B5::
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db88]
	ld [$db50], a
	call Call_53_43C5
	ret


Call_53_44CA::
	ld a, [$d9ee]
	rst $00

JumpTable_53_44CE::
	dw Jump_53_44E0
	dw Jump_53_4692
	dw Jump_53_480E
	dw Jump_53_49E8
	dw Jump_53_4A4C
	dw Jump_53_4A55
	dw Jump_53_4AC1
	dw Jump_53_4F32
	dw Jump_53_4F3F

Jump_53_44E0::
	xor a
	ld [$dd72], a
	ld a, [$d9ed]
	cp $12
	jr nz, jr_053_4500

	ld [$dd72], a
	xor a
	ld [$d9ed], a
	ld a, [$db88]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02

jr_053_4500:
	xor a
	ld [$dd69], a
	ld [$d9ef], a
	ld [$d9f0], a
	ld [$dd6d], a
	ld [$dd6e], a
	ld [$dd62], a
	ld a, [$c86c]
	or a
	jr nz, jr_053_451e

	ld a, $00
	ld [$c1d5], a

jr_053_451e:
	ld a, $01
	ld [$da82], a
	ld a, $ff
	ld [$db89], a
	ld a, [$dd6c]
	or a
	jr nz, jr_053_454f

	ld a, [$db82]
	cp $09
	jp z, Jump_053_4640

	ld hl, $db79
	call Call_53_4BE3
	cp $10
	jr nz, jr_053_4546

	ld a, $09
	ld [$d9ed], a
	ret


jr_053_4546:
	ld [$db88], a
	call Call_2FA5
	jp c, Jump_053_463b

jr_053_454f:
	ld a, [$db88]
	ld hl, $dd13
	call Call_53_4BE3
	cp $02
	jp nz, Jump_053_463b

	ld a, [$db88]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $c0
	jr z, jr_053_4570

	ld a, $11
	jp Jump_053_462c


jr_053_4570:
	ld a, l
	sub $05
	ld l, a
	ld [$db61], a
	ld a, h
	sbc $00
	ld h, a
	ld [$db62], a
	bit 6, [hl]
	jr z, jr_053_4587

	ld a, $13
	jp Jump_053_462c


jr_053_4587:
	bit 7, [hl]
	jr z, jr_053_4591

	call Call_53_4AEB
	jp Jump_053_462c


jr_053_4591:
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	or a
	jr z, jr_053_45ca

	bit 2, a
	jr z, jr_053_45a1

	ld a, $16
	jp Jump_053_462c


jr_053_45a1:
	bit 0, a
	jr z, jr_053_45aa

	ld a, $12
	jp Jump_053_462c


jr_053_45aa:
	bit 1, a
	jr z, jr_053_45b2

	ld a, $14
	jr jr_053_462c

jr_053_45b2:
	bit 3, a
	jr z, jr_053_45ba

	ld a, $15
	jr jr_053_462c

jr_053_45ba:
	bit 4, a
	jr z, jr_053_45c2

	ld a, $17
	jr jr_053_462c

jr_053_45c2:
	bit 5, a
	jr z, jr_053_45ca

	ld a, $18
	jr jr_053_462c

jr_053_45ca:
	call Call_53_4E33
	ld a, [$db61]
	ld l, a
	ld a, [$db62]
	ld h, a
	bit 5, [hl]
	jr z, jr_053_45f9

	ld a, [$c899]
	cp $40
	jr nc, jr_053_45f9

	call Call_53_4C50
	ld a, [$db88]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	ret nz

	ld a, $05
	ld [$d9ee], a
	ret


jr_053_45f9:
	bit 4, [hl]
	jr z, jr_053_4621

	call Call_53_44B5
	ld a, $10
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $11
	ld [$d9ed], a
	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	ret


jr_053_4621:
	call Call_53_4E63
	jr c, jr_053_464c

	ld hl, $d9ee
	inc [hl]
	jr jr_053_467c

Jump_053_462c:
jr_053_462c:
	ld [$db4c], a
	ld hl, far_Call_50_59EB
	rst $10
	call Call_53_4B39
	ld a, $07
	ld [$d9ee], a

Jump_053_463b:
	ld hl, $db82
	inc [hl]
	ret


Jump_053_4640:
	xor a
	ld [$d9ed], a
	ld [$d9ee], a
	ld hl, $d9ec
	inc [hl]
	ret


jr_053_464c:
	call Call_53_49DC
	jr nz, Call_53_4657

	ld hl, $d9ee
	inc [hl]
	jr jr_053_467c

Call_53_4657::
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $3a
	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	call Call_53_4799
	ld a, $01
	ld [$c1d5], a

jr_053_467c:
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$db8a], a
	ld hl, far_Call_54_5298
	rst $10
	ret


Jump_53_4692::
	ld hl, $d9ee
	inc [hl]
	ld a, [$d9ef]
	or a
	jr z, jr_053_46a8

	cp $02
	jp z, Jump_053_47d5

	ld hl, $d9ee
	inc [hl]
	jp Jump_053_47d5


jr_053_46a8:
	ld a, [$dd72]
	or a
	jp nz, Jump_053_4733

	ld a, [$c88b]
	or a
	jp nz, Jump_053_4733

	ld a, [$db88]
	ld hl, $dd0b
	call Call_53_4BE3
	cp $02
	jr nz, jr_053_4733

	call Call_53_4E01
	jr z, jr_053_4733

	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr nz, jr_053_4733

	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$db8a], a
	ld a, [$db8a]
	cp $55
	jr z, jr_053_4733

	ld hl, far_Call_54_5298
	rst $10
	ld a, [$dcfd]
	bit 3, a
	jr nz, jr_053_4733

	ld a, [$db88]
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	jr nz, jr_053_4733

	ld bc, $0004
	add hl, bc
	bit 2, [hl]
	jr nz, jr_053_4733

	inc hl
	bit 4, [hl]
	jr nz, jr_053_4733

	ld a, [$db82]
	or a
	jr z, jr_053_4733

	xor a
	ld [$d9ee], a
	ld a, $18
	ld [$d9ed], a
	ld a, [$db88]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ret


Jump_053_4733:
jr_053_4733:
	ld a, [$db88]
	ld hl, $dcec
	add a
	call Call_53_4BE3
	ld [$db8a], a
	inc hl
	ld a, [hl]
	ld [$db89], a
	ld hl, far_Call_54_5298
	rst $10
	ld a, [$db8a]
	cp $14
	jr nz, jr_053_475e

	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 0, [hl]
	jr z, Call_53_4799

	ret


jr_053_475e:
	cp $32
	ret z

	cp $96
	ret z

	cp $95
	ret z

	cp $ad
	ret z

	ld a, [$db89]
	call Call_2FA5
	jr c, jr_053_47b2

	ld a, [$db88]
	ld hl, $dd0b
	call Call_53_4BE3
	or a
	ret z

	ld a, [$db88]
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	ret nz

	ld a, [$db88]
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	ret z

Call_53_4799::
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	xor a
	ld [$d9ee], a
	ld a, $19
	ld [$d9ed], a
	ret


jr_053_47b2:
	ld a, [$db8a]
	cp $51
	jr z, jr_053_47d1

	cp $52
	jr z, jr_053_47d1

	cp $53
	jr z, jr_053_47d1

	ld a, [$dcfc]
	and $01
	jr z, jr_053_47e8

	call Call_53_49DC
	or a
	ret z

	call Call_53_4E01
	ret z

jr_053_47d1:
	ld hl, far_Call_58_5498
	rst $10

Jump_053_47d5:
	xor a
	ld [$d9ef], a
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	jr jr_053_4809

jr_053_47e8:
	ld a, [$db89]
	and $04
	ld c, a
	ld b, $03

jr_053_47f0:
	ld a, c
	call Call_2FA5
	jr nc, jr_053_47fb

	inc c
	dec b
	jr nz, jr_053_47f0

	ret


jr_053_47fb:
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c

jr_053_4809:
	ld a, [hl]
	ld [$db89], a
	ret


Jump_53_480E::
	ld hl, $d9ee
	inc [hl]
	ld hl, far_Call_54_5298
	rst $10
	ld a, [$db8a]
	ld [$db4c], a
	xor a
	ld [$db4d], a
	ld a, $04
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	ld a, [$db4c]
	ld c, a
	or a
	jp z, Jump_053_4871

	ld b, $00
	ld a, [$db88]
	call Call_2FEF
	call Call_2F45
	jr z, jr_053_4871

	ld a, l
	sub c
	ld a, h
	sbc b
	jr nc, jr_053_4871

	call Call_53_493D
	jr c, jr_053_4871

	call Call_53_49DC
	call z, Call_53_490A
	ld a, [$dcfd]
	bit 6, a
	jr z, jr_053_485b

	ld a, $f7
	jp Jump_053_48e5


jr_053_485b:
	bit 5, a
	jr z, jr_053_4864

	ld a, $f9
	jp Jump_053_48e5


jr_053_4864:
	bit 4, a
	jr z, jr_053_486d

	ld a, $f8
	jp Jump_053_48e5


jr_053_486d:
	call Call_53_4963
	ret


Jump_053_4871:
jr_053_4871:
	ld a, [$dcfd]
	bit 6, a
	jr z, jr_053_48af

	ld a, [$db88]
	rrca
	rrca
	and $01
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr z, jr_053_4899

	call Call_53_49DC
	call z, Call_53_490A
	call Call_53_4B4F
	ld a, $1f
	jr jr_053_48e0

jr_053_4899:
	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 0, [hl]
	ret z

	call Call_53_49DC
	call z, Call_53_490A
	ld a, $1e
	jr jr_053_48e0

jr_053_48af:
	bit 5, a
	jr z, jr_053_48c9

	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 6, [hl]
	ret z

	call Call_53_49DC
	call z, Call_53_490A
	ld a, $21
	jr jr_053_48e0

jr_053_48c9:
	bit 4, a
	ret z

	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 7, [hl]
	ret z

	call Call_53_49DC
	call z, Call_53_490A
	ld a, $20

jr_053_48e0:
	push af
	call Call_53_4A04
	pop af

Jump_053_48e5:
	ld [$db4c], a
	ld hl, far_Call_50_59EB
	rst $10

Jump_053_48ec:
	ld a, [$dd6c]
	or a
	jr nz, jr_053_48fb

	ld hl, $db82
	inc [hl]
	xor a
	ld [$d9ee], a
	ret


jr_053_48fb:
	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ld a, $20
	ld [$dd6c], a
	ret


Call_53_490A::
	ld a, [$dd6c]
	or a
	ret nz

	ld a, [$db88]
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	ret nz

	ld a, [$dd72]
	or a
	ret nz

	call Call_53_4E01
	ret z

	ld a, $16
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ld a, [$db88]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	pop af
	ret


Call_53_493D::
	ld a, [$db88]
	ld hl, $db06
	call Call_2F6C
	bit 2, [hl]
	jr nz, jr_053_4951

	inc hl
	bit 4, [hl]
	jr nz, jr_053_495a

jr_053_494f:
	xor a
	ret


jr_053_4951:
	ld a, [$db8a]
	cp $42
	jr nz, jr_053_494f

	jr jr_053_4961

jr_053_495a:
	ld a, [$db8a]
	cp $95
	jr nz, jr_053_494f

jr_053_4961:
	scf
	ret


Call_53_4963::
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db88]
	ld [$db50], a
	call Call_53_43C5
	ld hl, $c190
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db89]
	ld [$db50], a
	call Call_53_43C5
	ld a, [$db8a]
	cp $42
	jr z, jr_053_49b3

	cp $52
	jr z, jr_053_49b7

	cp $53
	jr z, jr_053_49b7

	cp $56
	jr z, jr_053_49bb

	cp $6f
	jr z, jr_053_49bf

	cp $8f
	jr z, jr_053_49c3

	cp $92
	jr z, jr_053_49c7

	cp $95
	jr z, jr_053_49cb

	ld a, $1d
	jp Jump_053_48e5


jr_053_49b3:
	ld a, $0c
	jr jr_053_49cd

jr_053_49b7:
	ld a, $0d
	jr jr_053_49cd

jr_053_49bb:
	ld a, $0e
	jr jr_053_49cd

jr_053_49bf:
	ld a, $0f
	jr jr_053_49cd

jr_053_49c3:
	ld a, $10
	jr jr_053_49cd

jr_053_49c7:
	ld a, $11
	jr jr_053_49cd

jr_053_49cb:
	ld a, $12

jr_053_49cd:
	ld [$c823], a
	ld a, $01
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	jp Jump_053_48ec


Call_53_49DC::
	ld a, [$db88]
	ld hl, $dd0b
	call Call_53_4BE3
	cp $02
	ret


Jump_53_49E8::
	call Call_53_49DC
	jr nz, jr_053_49fc

	call Call_53_4E63
	jr nc, jr_053_49fc

	ld a, [$c1d5]
	or a
	jr nz, jr_053_49fc

	call Call_53_4657
	ret


jr_053_49fc:
	ld hl, $d9ed
	inc [hl]
	xor a
	ld [$d9ee], a

Call_53_4A04::
	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 4, [hl]
	ret nz

	ld a, [$db8a]
	ld [$db4c], a
	call Call_53_4B92
	ret c

	xor a
	ld [$db4d], a
	ld a, $04
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	ld a, [$db4c]
	ld c, a
	ld a, [$db88]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc $00
	ld [hl], a
	ld a, [$db8a]
	cp $32
	ret nz

	xor a
	ld [hld], a
	ld [hl], a
	ret


Jump_53_4A4C::
	xor a
	ld [$d9ee], a
	ld hl, $db82
	inc [hl]
	ret


Jump_53_4A55::
	ld a, [$db88]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	jr z, jr_053_4a6c

	ld a, $01
	ld [$d9ee], a
	ret


jr_053_4a6c:
	call Call_53_44B5
	ld a, [$db88]
	ld b, a
	and $03
	cp $03
	jr nz, jr_053_4a99

	ld a, b
	rrca
	rrca
	and $01
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	res 2, [hl]
	ld a, b
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, $e6
	jr jr_053_4ab0

jr_053_4a99:
	ld a, b
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	call Call_53_6C59
	jr c, jr_053_4aae

	ld a, $e7
	jr jr_053_4ab0

jr_053_4aae:
	ld a, $e3

jr_053_4ab0:
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $06
	ld [$d9ee], a
	ret


Jump_53_4AC1::
	ld hl, far_Call_52_7A18
	rst $10
	xor a
	ld [$d9ee], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld hl, far_Call_52_76C8
	rst $10
	ld a, [$dd6b]
	cp $ff
	ret z

	xor a
	ld hl, $d9ed
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [$db4e], a
	ld a, $0a
	ld [$d9ec], a
	ret


Call_53_4AEB::
	ld a, [hl]
	and $0c
	jr z, jr_053_4b04

	cp $04
	jr z, jr_053_4b00

	cp $08
	jr z, jr_053_4afc

	ld b, $60
	jr jr_053_4b06

jr_053_4afc:
	ld b, $a0
	jr jr_053_4b06

jr_053_4b00:
	ld b, $e0
	jr jr_053_4b06

jr_053_4b04:
	ld b, $ff

jr_053_4b06:
	ld a, [$c899]
	cp b
	jr z, jr_053_4b28

	jr c, jr_053_4b28

	ld a, [hl]
	and $f3
	ld b, a
	ld a, [hl]
	and $0c
	dec a
	push bc
	push af
	pop bc
	bit 5, c
	pop bc
	jr nz, jr_053_4b22

	and $0c
	jr jr_053_4b23

jr_053_4b22:
	xor a

jr_053_4b23:
	or b
	ld [hl], a
	ld a, $0f
	ret


jr_053_4b28:
	ld a, [hl]
	and $73
	ld [hl], a
	ld a, [$db88]
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld a, $db
	ret


Call_53_4B39::
	push af
	push bc
	push de
	push hl
	ld a, [$db88]
	ld hl, $db05
	call Call_2F6C
	ld a, [hl]
	and $c0
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Call_53_4B4F::
	push af
	push bc
	push de
	push hl
	ld a, [$db8a]
	ld [$db4c], a
	ld a, $00
	ld [$db4d], a
	ld a, $04
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	ld a, [$db4c]
	ld c, a
	ld b, $00
	ld a, [$db88]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [hli]
	ld h, [hl]
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, jr_053_4b87

	ld hl, $0000

jr_053_4b87:
	pop bc
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	pop hl
	pop de
	pop bc
	pop af
	ret


Call_53_4B92::
	cp $32
	jr z, jr_053_4bd1

	cp $42
	jr z, jr_053_4bc3

	cp $66
	jr z, jr_053_4bd1

	cp $95
	jr z, jr_053_4bd3

	cp $96
	jr z, jr_053_4bd1

	ld a, [$dcfd]
	bit 6, a
	jr z, jr_053_4bd1

	ld a, [$db88]
	rrca
	rrca
	and $01
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr nz, jr_053_4be1

	jr jr_053_4bd1

jr_053_4bc3:
	ld a, [$db88]
	ld hl, $db06
	call Call_2F6C
	ld a, [hl]
	and $0c
	jr nz, jr_053_4be1

jr_053_4bd1:
	xor a
	ret


jr_053_4bd3:
	ld a, [$db88]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $30
	jr z, jr_053_4bd1

jr_053_4be1:
	scf
	ret


Call_53_4BE3::
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Call_53_4BEB::
	call Call_53_4E33
	ld a, [$c899]
	bit 1, a
	jr nz, jr_053_4c1b

	bit 0, a
	jr nz, jr_053_4c1f

	ld a, [$c86c]
	or a
	jr nz, jr_053_4c23

	ld a, [$db88]
	cp $04
	jr c, jr_053_4c23

	ld a, [$c89a]
	and $07
	add $9a
	cp $a1
	jr nz, jr_053_4c32

	ld b, a
	ld a, [$db73]
	or a
	ld a, b
	jr z, jr_053_4c32

	jr Call_53_4BEB

jr_053_4c1b:
	ld a, $99
	jr jr_053_4c32

jr_053_4c1f:
	ld a, $9a
	jr jr_053_4c32

jr_053_4c23:
	ld a, [$c89a]
	cp $55
	jr c, jr_053_4c30

	and $01
	add $9b
	jr jr_053_4c32

jr_053_4c30:
	ld a, $9e

jr_053_4c32:
	ld [$db8a], a
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db8a]
	ld [hl], a
	ld a, $10
	ld [$d9ed], a
	ld hl, far_Call_58_5498
	rst $10
	ret


Call_53_4C50::
	ld a, [$db89]
	push af
	ld a, [$db88]
	ld [$db89], a
	call Call_53_44A0
	pop af
	ld [$db89], a
	ld a, [$c89a]
	cp $40
	jr c, jr_053_4c87

	cp $80
	jr c, jr_053_4c97

	cp $c0
	jr c, jr_053_4cb9

	ld a, $11
	ld [$d9ed], a
	ld a, [$db88]
	ld hl, $db02
	call Call_2F6C
	set 4, [hl]
	ld a, $19
	ld [$c823], a
	jr jr_053_4cdc

jr_053_4c87:
	ld a, $04
	ld [$d9ee], a
	xor a
	ld [$d9ed], a
	ld a, $1a
	ld [$c823], a
	jr jr_053_4cdc

jr_053_4c97:
	ld a, $05
	ld [$d9ee], a
	ld a, [$db88]
	ld de, $dba3
	call Call_53_4CE5
	ret z

	ld a, [$db88]
	call Call_53_4CEC
	jr nc, jr_053_4cb2

	xor a
	ld [de], a
	dec de
	ld [de], a

jr_053_4cb2:
	ld a, $1b
	ld [$c823], a
	jr jr_053_4cdc

jr_053_4cb9:
	ld a, $05
	ld [$d9ee], a
	call Call_53_4D1D
	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, l
	or h
	ret z

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Call_53_4FFD
	ld a, $1c
	ld [$c823], a

jr_053_4cdc:
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Call_53_4CE5::
	push hl
	ld h, d
	ld l, e
	ld a, [hli]
	or [hl]
	pop hl
	ret


Call_53_4CEC::
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	push de
	ld a, $10
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
	ld a, $06
	call Call_1E0D
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	push hl
	call Call_53_4FFD
	pop hl
	pop de
	ld a, [de]
	sub l
	ld [de], a
	inc de
	ld a, [de]
	sbc $00
	ld [de], a
	ret


Call_53_4D1D::
	ld a, [$db88]
	call Call_2FE1
	or h
	jr z, jr_053_4d75

	ld a, $06
	call Call_1E0D
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	ld a, [$db88]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$db58], a
	ld a, h
	ld [$db59], a
	ld a, [hli]
	or [hl]
	jr nz, jr_053_4d50

	ld h, [hl]
	ld l, a
	jr jr_053_4d75

jr_053_4d50:
	ld a, [hld]
	ld c, [hl]
	ld b, a
	ld a, c
	ld [$db5a], a
	ld a, b
	ld [$db5b], a
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret nc

	xor a
	ld [hld], a
	ld [hl], a
	ld a, [$db5a]
	ld l, a
	ld a, [$db5b]
	ld h, a

jr_053_4d75:
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	ret


Call_53_4D7E::
	call Call_53_4E33
	ld a, [$c899]
	and $0f
	or a
	jr z, jr_053_4d91

	cp $01
	jr z, jr_053_4d95

	add $a0
	jr jr_053_4d97

jr_053_4d91:
	ld a, $a9
	jr jr_053_4d97

jr_053_4d95:
	ld a, $a3

jr_053_4d97:
	ld [$db8a], a
	ld [$db4c], a
	xor a
	ld [$db4d], a
	ld a, $09
	ld [$db4e], a
	ld hl, far_Call_54_5249
	rst $10
	ld a, [$db73]
	or a
	jr z, jr_053_4db7

	ld a, [$db4c]
	bit 1, a
	jr z, Call_53_4D7E

jr_053_4db7:
	ld a, [$c86c]
	or a
	jr nz, jr_053_4dcf

	ld a, [$db88]
	cp $03
	jr c, jr_053_4dcf

	ld a, [$db8a]
	cp $a2
	jr z, Call_53_4D7E

	cp $a4
	jr z, Call_53_4D7E

jr_053_4dcf:
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db8a]
	ld [hl], a
	ld a, [$dd69]
	push af
	xor a
	ld [$dd69], a
	ld hl, far_Call_58_5498
	rst $10
	pop af
	ld [$dd69], a
	xor a
	ld [$d9ee], a
	xor a
	ld [$d9ed], a
	xor a
	ld [$d9ef], a
	xor a
	ld [$dd69], a
	ret


Call_53_4E01::
	ld a, [$dd72]
	or a
	ret nz

	ld a, [$db88]
	ld hl, $dd03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	ret nz

	ld a, [$c86c]
	or a
	jr nz, jr_053_4e21

	ld a, [$c8da]
	jr jr_053_4e30

jr_053_4e21:
	ld a, [$db88]
	cp $04
	jr nc, jr_053_4e2d

	ld a, [$c1d5]
	jr jr_053_4e30

jr_053_4e2d:
	ld a, [$c1d6]

jr_053_4e30:
	cp $81
	ret


Call_53_4E33::
	ld a, [$c86c]
	or a
	jr nz, jr_053_4e3d

	call Call_12D0
	ret


jr_053_4e3d:
	push hl
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
	pop hl
	ret


Call_53_4E63::
	ld a, [$c86c]
	or a
	jr nz, jr_053_4eae

	ld a, [$db88]
	cp $04
	jr c, jr_053_4eae

	cp $07
	jr z, jr_053_4eae

	sub $04
	ld hl, $da03
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
	add $df
	ld l, a
	ld a, h
	adc $41
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_053_4eae

	ld a, [$db82]
	or a
	jr z, jr_053_4eae

	ld b, a
	ld hl, $db79

jr_053_4e99:
	ld a, [hli]
	cp $ff
	jr z, jr_053_4eae

	cp $04
	jr nc, jr_053_4ea7

	dec b
	jr nz, jr_053_4e99

	jr jr_053_4eae

jr_053_4ea7:
	call Call_53_4EB1
	jr nz, jr_053_4e99

	scf
	ret


jr_053_4eae:
	scf
	ccf
	ret


Call_53_4EB1::
	push hl
	push bc
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld c, a
	ld a, [$db88]
	ld hl, $dcec
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp c
	jr nz, jr_053_4ed3

	call Call_53_4ED6

jr_053_4ed3:
	pop bc
	pop hl
	ret


Call_53_4ED6::
	ld hl, $4ee4

jr_053_4ed9:
	ld a, [hli]
	cp $ff
	jr z, jr_053_4ee2

	cp c
	ret z

	jr jr_053_4ed9

jr_053_4ee2:
	or a
	ret


	db $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12
	db $13, $14, $16, $17, $18, $1d, $1f, $21, $23, $2e, $2f, $30, $31, $32, $3b, $3c
	db $3e, $3f, $40, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $51, $52, $53, $57, $59
	db $5a, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $69, $6a, $6b
	db $6d, $6e, $71, $78, $7c, $7d, $d6, $d7, $d8, $d9, $da, $db, $dc, $ff

Jump_53_4F32::
	ld a, [$c8ee]
	add $03
	ld [$db4c], a
	ld hl, $d9ee
	inc [hl]
	ret


Jump_53_4F3F::
	ld a, [$db4c]
	dec a
	ld [$db4c], a
	ret nz

	xor a
	ld [$d9ee], a
	ret


Call_53_4F4C::
	ld a, [$d9ee]
	rst $00

JumpTable_53_4F50::
	dw Jump_53_4F58
	dw Jump_53_4FD2
	dw Jump_53_4FD6
	dw Jump_53_4FDA

Jump_53_4F58::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2FA5
	jr nc, jr_053_4f6b

jr_053_4f64:
	ld hl, $d9ee
	inc [hl]
	jp Jump_53_4FD6


jr_053_4f6b:
	ld a, [$db89]
	cp $04
	jr c, jr_053_4f77

	ld hl, $db01
	jr jr_053_4f7a

jr_053_4f77:
	ld hl, $db00

jr_053_4f7a:
	bit 4, [hl]
	jr nz, jr_053_4f64

	ld a, [$db8a]
	cp $89
	jr nz, jr_053_4fa2

	set 4, [hl]
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db88]
	and $03
	swap a
	or [hl]
	ld [hl], a
	ld a, [$db89]
	and $04
	ld c, a
	ld b, $03
	jr jr_053_4fa8

jr_053_4fa2:
	ld a, [$db89]
	ld c, a
	ld b, $01

jr_053_4fa8:
	ld a, c
	call Call_2FA5
	jr c, jr_053_4fcd

	ld a, c
	ld hl, $db88
	cp [hl]
	jr z, jr_053_4fcd

	ld hl, $db08
	call Call_2F6C
	bit 4, [hl]
	jr nz, jr_053_4fcd

	set 4, [hl]
	inc hl
	ld a, [$db88]
	and $0f
	swap a
	ld d, a
	ld a, [hl]
	or d
	ld [hl], a

jr_053_4fcd:
	inc c
	dec b
	jr nz, jr_053_4fa8

	ret


Jump_53_4FD2::
	ld hl, $d9ee
	inc [hl]

Jump_53_4FD6::
	ld hl, $d9ee
	inc [hl]

Jump_53_4FDA::
	ld hl, $d9ed
	inc [hl]
	ld hl, $d9ed
	inc [hl]
	ld hl, $d9ed
	inc [hl]
	xor a
	ld [$d9ee], a
	xor a
	ld [$dd72], a
	xor a
	ld [$dd73], a
	ret


Call_53_4FF3::
	call Call_53_44A0
	call Call_53_4FFD
	call Call_53_500C
	ret


Call_53_4FFD::
	ld hl, $c190
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Call_0A7C
	ret


Call_53_500C::
	ld hl, $c1a0
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db88]
	ld [$db50], a
	call Call_53_43C5
	ret


Jump_053_5021:
	ld a, [$db89]
	and $04
	ld b, a
	ld a, c
	and $04
	cp b
	jr nz, jr_053_5030

	xor $04
	ld c, a

jr_053_5030:
	ld a, c
	and $04
	xor $04
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	inc e
	ld a, e
	call Call_53_5192
	jp nc, Jump_053_5140

	inc e
	jp Jump_053_5140


Jump_053_5048:
jr_053_5048:
	ld a, c
	and $04
	xor $04
	ld d, a
	ld a, [$c89a]
	and $02
	ld c, a
	or d
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	ld a, e
	xor $02
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	inc d
	ld e, d
	jp Jump_053_5140


Jump_053_506b:
jr_053_506b:
	ld a, [$c89a]
	and $01
	inc a
	ld d, a
	ld a, c
	and $04
	xor $04
	ld c, a
	add d
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	ld a, d
	xor $03
	ld d, a
	ld a, c
	sub d
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	ld e, c
	jp Jump_053_5140


Call_53_5091::
	xor a
	ld [$db61], a
	ld a, [$db89]
	call Call_2F76
	ret c

	ld a, [$db89]
	ld c, a
	call Call_53_4E33
	ld a, [$c899]
	cp $33
	jr c, jr_053_5112

	cp $66
	jp c, Jump_053_5021

	cp $99
	jr c, jr_053_5048

	cp $cc
	jr c, jr_053_506b

	ld a, c
	and $04
	ld b, a
	ld a, [$c89a]
	and $01
	ld d, a
	ld a, c
	and $03
	cp $00
	jr z, jr_053_50e8

	cp $01
	jr z, jr_053_50ec

	inc d
	sub d

jr_053_50ce:
	or b
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld a, d
	xor $03
	cp $03
	jr nz, jr_053_50de

	ld a, $01

jr_053_50de:
	or b
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld e, c
	jr jr_053_5130

jr_053_50e8:
	inc d
	ld a, d
	jr jr_053_50ce

jr_053_50ec:
	ld a, d
	or a
	jr z, jr_053_5102

	ld a, c
	inc a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld a, c
	dec a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	jr jr_053_5130

jr_053_5102:
	ld a, c
	dec a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld a, c
	inc a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

jr_053_5112:
	ld a, [$db89]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	jp nz, Jump_053_5021

	ld a, $7f
	ld [$c823], a
	ld a, [$db89]
	ld [$db4c], a
	jr jr_053_516e

jr_053_5130:
	ld a, [$c899]
	cp $55
	jp c, Jump_053_5021

	cp $aa
	jp c, Jump_053_5048

	jp Jump_053_506b


Jump_053_5140:
jr_053_5140:
	ld a, e
	call Call_2FA5
	jr c, jr_053_5112

	ld a, [$db89]
	ld [$db4c], a
	cp e
	jp z, Call_53_5091

	ld a, e
	ld [$db89], a
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	ld a, $7e
	ld [$c823], a
	jr jr_053_516e

	db $3e, $7f, $ea, $23, $c8

jr_053_516e:
	ld hl, $c1a0
	ld a, [$c823]
	push af
	ld a, [$db4c]
	call Call_53_43C5
	pop af
	ld [$c823], a
	ld a, [$dd72]
	or a
	ret nz

	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $01
	ld [$db61], a
	ret


Call_53_5192::
	call Call_2FA5
	jr c, jr_053_51a8

	ld a, e
	push hl
	ld hl, $db06
	call Call_2F6C
	ld a, [hl]
	and $0c
	pop hl
	jr nz, jr_053_51a8

	scf
	ccf
	ret


jr_053_51a8:
	scf
	ret


Call_53_51AA::
	ld a, [$c86c]
	or a
	jr nz, jr_053_51dd

	ld a, [$db89]
	cp $04
	jr c, jr_053_51dd

	ld a, [$db73]
	cp $01
	jr nz, jr_053_51dd

	ld a, [$db8a]
	cp $12
	jr z, jr_053_51e3

	cp $13
	jr z, jr_053_51e3

	cp $14
	jr z, jr_053_51e3

	cp $3e
	jr z, jr_053_51e3

	cp $69
	jr z, jr_053_51e3

	cp $6b
	jr z, jr_053_51e3

	cp $71
	jr z, jr_053_51e3

jr_053_51dd:
	ld a, $01
	ld [$db4c], a
	ret


jr_053_51e3:
	xor a
	ld [$db4c], a
	ret


Call_53_51E8::
	ld a, [$d9ee]
	rst $00

JumpTable_53_51EC::
	dw Jump_53_520C
	dw Jump_53_5242
	dw Jump_53_527A
	dw Jump_53_52E9
	dw Jump_53_535E
	dw Jump_53_537A
	dw Jump_53_53A9
	dw Jump_53_5411
	dw Jump_53_5622
	dw Jump_53_56A8
	dw Jump_53_586A
	dw Jump_53_58F6
	dw Jump_53_58FB
	dw Jump_53_5A6F
	dw Jump_53_5AED
	dw Jump_53_5B07

Jump_53_520C::
	ld hl, $d9ee
	inc [hl]
	ld hl, $dd69
	inc [hl]

jr_053_5214:
	xor a
	ld [$dd6e], a
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$db89], a
	cp $ff
	jr nz, jr_053_5233

	ld hl, far_Call_58_5498
	rst $10
	jr jr_053_5214

jr_053_5233:
	ld a, [$dd69]
	cp $01
	jr z, Jump_53_5242

	ld a, $07
	ld [$d9ee], a
	jp Jump_53_5411


Jump_53_5242::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $54
	jr z, Jump_53_527A

	push af
	call Call_53_44B5
	pop af
	bit 6, a
	jr nz, jr_053_526c

	bit 2, a
	jr nz, jr_053_5268

	ld a, $6b
	jr jr_053_526e

jr_053_5268:
	ld a, $69
	jr jr_053_526e

jr_053_526c:
	ld a, $6d

jr_053_526e:
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_53_527A::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd6c]
	or a
	jr z, jr_053_5289

	cp $08
	jr z, jr_053_5289

	ret


jr_053_5289:
	ld hl, far_Call_58_57C5
	rst $10
	ld hl, far_Call_50_59EB
	rst $10
	ld hl, far_Call_55_401F
	rst $10
	ld a, $18
	ld [$da33], a
	ld a, [$db8a]
	cp $14
	jr z, jr_053_52c8

	cp $24
	jr z, jr_053_52c8

	cp $26
	jr z, jr_053_52c8

	cp $2a
	jr z, jr_053_52c8

	cp $89
	jr z, jr_053_52c8

	cp $80
	jr z, jr_053_52c8

	cp $8a
	jr z, jr_053_52c8

	cp $8b
	jr z, jr_053_52c8

	cp $8f
	jr z, jr_053_52c8

	cp $83
	jr z, jr_053_52c8

	cp $a5
	ret nz

jr_053_52c8:
	ld a, [$db89]
	call Call_2FA5
	ret nc

	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	cp $03
	ret z

	inc [hl]
	ld a, [hl]
	ld [$db89], a
	jr jr_053_52c8

Jump_53_52E9::
	ld a, [$da33]
	or a
	jr z, jr_053_52f4

	dec a
	ld [$da33], a
	ret


jr_053_52f4:
	ld hl, far_Call_54_5298
	rst $10
	ld a, [$db8a]
	cp $42
	jr nz, jr_053_5313

	ld a, [$db88]
	ld hl, $db06
	call Call_2F6C
	ld a, [hl]
	and $0c
	jr nz, jr_053_5313

	ld a, $0b
	ld [$d9ee], a
	ret


jr_053_5313:
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$db89], a
	ld [$dd73], a
	ld hl, $d9ee
	inc [hl]
	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	jr z, Jump_53_535E

	push af
	call Call_53_44B5
	pop af
	bit 1, a
	jr z, jr_053_5349

	ld a, $68
	jr jr_053_5352

jr_053_5349:
	ld a, [$dcfe]
	bit 4, a
	jr z, Jump_53_535E

	ld a, $67

jr_053_5352:
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_53_535E::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2FA5
	jr c, Jump_53_537A

	ld hl, far_Call_5F_52F0
	rst $10
	ld a, [$da80]
	cp $01
	ret z

	ld hl, $d9ee
	inc [hl]
	jr Jump_53_53A9

Jump_53_537A::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd68]
	cp $02
	jr nz, Jump_53_53A9

	ld a, [$db89]
	ld c, a

jr_053_5389:
	and $03
	cp $02
	jr z, jr_053_53a3

	inc c
	ld a, c
	call Call_2FA5
	ld a, c
	jr c, jr_053_5389

	ld [$db89], a
	ld hl, $d9ee
	dec [hl]
	ld hl, $d9ee
	dec [hl]
	ret


jr_053_53a3:
	ld a, [$dd73]
	ld [$db89], a

Jump_53_53A9::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dcfd]
	bit 7, a
	jr z, Jump_53_5411

	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$db89], a
	ld a, [$db89]
	call Call_2F76
	jr c, Jump_53_5411

	ld a, [$db89]
	ld [$c1c8], a
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	jr z, Jump_53_5411

	ld a, [hl]
	ld [$dd72], a
	call Call_53_5091
	ld a, [$c1c8]
	ld hl, $c180
	ld [$db50], a
	call Call_53_43C5
	ld a, [$db89]
	ld hl, $c190
	ld [$db50], a
	call Call_53_43C5
	ld a, $6c
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld hl, $d9ee
	inc [hl]
	ret


Jump_53_5411::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd6c]
	bit 3, a
	jp nz, Jump_053_54d6

	ld hl, far_Call_54_5298
	rst $10
	call Call_53_4E33
	ld a, [$db89]
	ld hl, $db06
	call Call_2F6C
	ld a, [hl]
	and $0c
	jr z, jr_053_5458

	ld a, [$dcff]
	bit 5, a
	jr z, jr_053_5458

	ld a, $05
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	call Call_53_44A0
	ld a, $c1
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $6f
	call Call_1B2C
	ret


jr_053_5458:
	ld a, [$dcfd]
	bit 4, a
	jp z, Jump_053_54d6

	ld a, [$db89]
	rrca
	rrca
	and $01
	ld b, a
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jp z, Jump_053_54d6

	ld a, [$dd6c]
	or a
	jp nz, Jump_53_5622

	ld a, [$db8a]
	cp $8f
	jp z, Jump_53_5622

	ld a, b
	ld hl, $db4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	rrca
	rrca
	and $03
	ld c, a
	ld a, [$db89]
	and $04
	or c
	ld c, a
	call Call_2F76
	jp c, Jump_53_5622

	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [hl], c
	ld b, a
	ld a, c
	sub b
	ld b, a
	ld a, [$dd69]
	add b
	ld [$dd69], a
	ld a, c
	ld [$db89], a
	ld b, $02
	call Call_53_5ECE
	call Call_53_44A0
	ld a, $81
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_053_54d6:
	ld a, [$dcfe]
	bit 1, a
	jr z, jr_053_554d

	ld a, [$dd6e]
	or a
	jr nz, jr_053_554d

	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C
	bit 4, [hl]
	jr z, jr_053_554d

	ld a, [$db89]
	ld hl, $db09
	call Call_2F6C
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call Call_2F76
	jr c, jr_053_5544

Call_53_5504::
	ld a, b
	ld hl, $c180
	push bc
	ld [$db50], a
	call Call_53_43C5
	ld a, [$db89]
	ld [$c1c8], a
	ld hl, $c190
	ld [$db50], a
	call Call_53_43C5
	pop bc
	ld a, b
	ld [$db89], a
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $80
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $04
	ld [$dd6e], a
	ret


jr_053_5544:
	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C

jr_053_554d:
	ld a, [$dd6c]
	or a
	jp nz, Jump_53_5622

	ld a, [$dcfd]
	bit 7, a
	jr z, jr_053_5594

	ld a, [$db89]
	call Call_2F76
	jp c, Jump_53_5622

	push hl
	ld a, [$db89]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	pop hl
	jr nz, jr_053_557a

	bit 5, [hl]
	jr z, jr_053_5594

jr_053_557a:
	xor a
	ld [$dd72], a
	ld a, [$db89]
	ld [$c1c8], a
	call Call_53_5091
	ld a, [$db61]
	or a
	jp z, Jump_53_5622

	ld a, $02
	ld [$dd6e], a
	ret


jr_053_5594:
	ld a, [$dcfd]
	bit 4, a
	jp z, Jump_053_55ca

	ld a, [$dd6c]
	or a
	jp nz, Jump_53_5622

	call Call_53_5CA1
	jr z, jr_053_55ca

	res 6, [hl]
	call Call_53_44A0
	ld a, $01
	call Call_53_5E38
	ld a, $02
	ld [$dd6d], a
	ld a, $02
	ld [$dd6e], a
	ld a, $7d
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_053_55ca:
jr_053_55ca:
	ld a, [$dcfe]
	bit 0, a
	jp z, Jump_53_5622

	ld a, [$dd6c]
	or a
	jp nz, Jump_53_5622

	ld a, [$db89]
	ld hl, $db04
	call Call_2F6C
	ld a, [hl]
	and $22
	jp z, Jump_53_5622

	ld a, $00
	ld [$dd6d], a
	bit 1, [hl]
	jr nz, jr_053_55f8

	res 5, [hl]
	ld a, $07
	ld [$dd6d], a

jr_053_55f8:
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	jr z, jr_053_5605

	ld a, [$db88]

jr_053_5605:
	rrca
	rrca
	and $01
	add $7b
	ld a, a
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $04
	call Call_53_5E38
	ld a, $02
	ld [$dd6e], a
	ret


Jump_53_5622::
	ld a, [$dd6e]
	or a
	jr z, jr_053_563c

	cp $01
	jr z, jr_053_5636

	cp $02
	jr nz, jr_053_563c

	cp $04
	jr z, jr_053_5636

	jr jr_053_5678

jr_053_5636:
	ld hl, $d9ee
	inc [hl]
	jr Jump_53_56A8

jr_053_563c:
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2F76
	jr c, Jump_53_56A8

	ld a, [$dcfe]
	bit 7, a
	jr z, Jump_53_56A8

	ld a, [$db89]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 7, [hl]
	jr z, Jump_53_56A8

	call Call_53_44A0
	ld a, $6e
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	call Call_53_583A
	ld a, $6f
	call Call_1B2C
	ret


jr_053_5678:
	ld a, [$dcfe]
	bit 1, a
	jr z, jr_053_563c

	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C
	bit 4, [hl]
	jr z, jr_053_563c

	ld a, [$db89]
	ld hl, $db09
	call Call_2F6C
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call Call_2F76
	jr c, jr_053_563c

	call Call_53_5504
	ld hl, $dd6e
	inc [hl]
	ret


Jump_53_56A8::
	ld a, [$db8a]
	cp $30
	jr z, jr_053_56e1

	cp $31
	jr z, jr_053_56e1

	cp $32
	jr z, jr_053_56e1

	cp $95
	jr z, jr_053_56e1

	cp $96
	jr z, jr_053_56e1

	cp $ad
	jr z, jr_053_56e1

	cp $8f
	jr z, jr_053_56e1

	cp $89
	jr z, jr_053_56e1

	cp $8b
	jr z, jr_053_56e1

	ld a, [$db89]
	call Call_2FA5
	jr nc, jr_053_56e1

	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ret


jr_053_56e1:
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $c0
	jr z, jr_053_5747

	ld a, [$dcfe]
	bit 2, a
	jr z, jr_053_5747

	call Call_53_5844
	jr z, jr_053_5747

	ld a, [$db8a]
	cp $52
	jr z, jr_053_5715

	cp $53
	jr z, jr_053_5715

	cp $14
	jr z, jr_053_5746

jr_053_570e:
	call Call_53_583A
	ld a, $ba
	jr jr_053_5731

jr_053_5715:
	ld a, [$dd69]
	cp $02
	jr nc, jr_053_570e

	ld a, $00
	ld [$c1c9], a
	ld a, $10
	ld [$dd69], a
	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ld a, $c2

jr_053_5731:
	push af
	call Call_53_44A0
	pop af
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $6f
	call Call_1B2C

jr_053_5746:
	ret


jr_053_5747:
	ld a, [$dcfd]
	bit 7, a
	jr z, jr_053_5763

	ld a, [$db89]
	ld hl, $db06
	call Call_2F6C
	bit 2, [hl]
	jr z, jr_053_5763

	call Call_53_44A0
	ld a, $c1
	jp Jump_053_582a


jr_053_5763:
	call Call_53_4E33
	ld a, [$dcfd]
	bit 1, a
	jr z, jr_053_579e

	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 1, [hl]
	jr z, jr_053_5785

	ld a, [$c899]
	cp $a0
	jr nc, jr_053_5785

	call Call_53_5810
	ret


jr_053_5785:
	ld a, [$db88]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $03
	jr z, jr_053_579e

	ld a, [$c89a]
	cp $60
	jr nc, jr_053_579e

	call Call_53_5810
	ret


jr_053_579e:
	ld a, [$dcfe]
	bit 7, a
	jr z, jr_053_57f5

	ld a, [$db89]
	call Call_2F76
	jr c, jr_053_57f5

	call Call_53_5857
	jr z, jr_053_57f5

	ld a, [$db89]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $0c
	jr z, jr_053_57c8

	ld a, [$c899]
	and $01
	jp z, Jump_053_57f1

jr_053_57c8:
	ld a, [$db89]
	ld hl, $dc03
	call Call_53_5D68
	ld bc, $01c0
	call Call_2F45
	jr nc, jr_053_57e5

	ld bc, $0020
	call Call_2F45
	jr nc, jr_053_57e9

	ld b, $02
	jr jr_053_57eb

jr_053_57e5:
	ld b, $2b
	jr jr_053_57eb

jr_053_57e9:
	ld b, $08

jr_053_57eb:
	ld a, [$c899]
	cp b
	jr nc, jr_053_57f5

Jump_053_57f1:
	call Call_53_57F7
	ret


jr_053_57f5:
	jr Jump_53_586A

Call_53_57F7::
	call Call_53_44A0
	ld a, $78
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	call Call_53_583A
	ld a, $6f
	call Call_1B2C
	ret


Call_53_5810::
	call Call_53_44A0
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	jr z, jr_053_5820

	ld a, [$db88]

jr_053_5820:
	cp $04
	jr c, jr_053_5828

	ld a, $b6
	jr jr_053_582a

jr_053_5828:
	ld a, $b7

Jump_053_582a:
jr_053_582a:
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $6f
	call Call_1B2C

Call_53_583A::
	ld a, $05
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ret


Call_53_5844::
	ld a, [$db8a]
	cp $42
	ret nz

	ld a, [$db88]
	ld hl, $db06
	call Call_2F6C
	ld a, [hl]
	and $0c
	ret


Call_53_5857::
	ld a, [$db8a]
	cp $41
	ret nz

	ld a, [$db88]
	ld hl, $db06
	call Call_2F6C
	ld a, [hl]
	and $03
	ret


Jump_53_586A::
	ld hl, far_Call_54_5298
	rst $10
	ld hl, $d9ee
	inc [hl]
	ld a, [$dcfe]
	and $70
	ret z

	bit 5, a
	jr z, jr_053_588b

	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 2, [hl]
	ret nz

	ld a, [$dcfe]

jr_053_588b:
	bit 4, a
	jr z, jr_053_58ea

	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	jr nz, jr_053_58b4

	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 3, [hl]
	jr nz, jr_053_58b4

	call Call_53_4E33
	call Call_53_5ED9
	jr nc, jr_053_58ea

jr_053_58b4:
	ld a, [$db88]
	ld hl, $db04
	call Call_2F6C
	set 7, [hl]
	ld a, [$db88]
	rrca
	rrca
	and $01
	ld d, a
	ld a, [$c863]
	bit 1, a
	ld a, d
	jr z, jr_053_58d1

	xor $01

jr_053_58d1:
	add $79
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $6e
	call Call_1B2C
	ld hl, $d9ee
	inc [hl]
	jr Jump_53_58FB

	db $c9

jr_053_58ea:
	ld a, [$db88]
	ld hl, $db04
	call Call_2F6C
	res 7, [hl]
	ret


Jump_53_58F6::
	ld hl, $d9ee
	inc [hl]
	ret


Jump_53_58FB::
	ld a, [$db88]
	ld hl, $db04
	call Call_2F6C
	bit 7, [hl]
	jr z, jr_053_5912

	ld a, [$dd80]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

jr_053_5912:
	ld hl, $d9ee
	inc [hl]
	ld a, [$db88]
	ld hl, $db03
	call Call_2F6C
	bit 2, [hl]
	jr z, jr_053_5941

	ld a, [$dcfe]
	bit 5, a
	jr z, jr_053_5941

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	sla l
	rl h
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	jp Jump_053_59c3


jr_053_5941:
	inc hl
	bit 7, [hl]
	jr z, jr_053_5978

	res 7, [hl]
	ld hl, $b682
	ld a, $a8
	ld [$dd6f], a
	ld a, l
	ld [$dd70], a
	ld a, h
	ld [$dd71], a
	ld a, [$db88]
	call Call_2FCC
	ld a, [$db8a]
	cp $51
	call z, Call_53_5973
	call Call_53_5D73
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	jr jr_053_59c3

Call_53_5973::
	srl h
	rr l
	ret


jr_053_5978:
	inc hl
	inc hl
	bit 0, [hl]
	jr z, jr_053_599a

	ld a, [$dcfe]
	bit 6, a
	jr z, jr_053_599a

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Call_53_5DB1
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	jr jr_053_59c3

jr_053_599a:
	bit 4, [hl]
	jr z, jr_053_59c3

	ld a, [$dcfd]
	bit 4, a
	jr z, jr_053_59c3

	ld a, [$db8a]
	cp $5c
	jr c, jr_053_59c3

	cp $64
	jr nc, jr_053_59c3

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Call_53_5DB1
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a

Jump_053_59c3:
jr_053_59c3:
	ld a, [$db88]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr z, jr_053_59ec

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld b, h
	ld c, l
	srl h
	rr l
	add hl, bc
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	jr jr_053_59ec

jr_053_59ec:
	ld a, [$db89]
	ld hl, $db09
	call Call_2F6C
	ld a, [hl]
	and $07
	jr z, jr_053_5a44

	and $03
	ld c, a
	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	jr nz, jr_053_5a15

	ld a, [$dcfd]
	bit 7, a
	jp z, Jump_53_5A6F

jr_053_5a0f:
	srl h
	rr l
	jr jr_053_5a25

jr_053_5a15:
	ld a, [$dcfd]
	bit 0, a
	jr z, Jump_53_5A6F

	bit 0, c
	jr nz, jr_053_5a0f

	ld a, $0a
	call Call_1E0D

jr_053_5a25:
	ld a, [$db89]
	ld de, $db42
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	bit 1, a
	jr z, jr_053_5a3a

	srl h
	rr l

jr_053_5a3a:
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	jr Jump_53_5A6F

jr_053_5a44:
	dec hl
	bit 2, [hl]
	jr z, Jump_53_5A6F

	ld a, [$dcfd]
	bit 7, a
	jr z, Jump_53_5A6F

	ld a, [$db8a]
	cp $3c
	jr z, Jump_53_5A6F

	cp $3e
	jr z, Jump_53_5A6F

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	sla l
	rl h
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a

Jump_53_5A6F::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd6f]
	bit 6, a
	jr z, jr_053_5ab4

	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ld a, [$dd6f]
	bit 7, a
	ret z

	call Call_53_4FF3
	ld a, [$dd70]
	ld l, a
	ld a, [$dd71]
	ld h, a
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld hl, far_Call_55_4026
	rst $10
	ld a, $01
	ld [$c1c9], a
	ld a, [$db8a]
	cp $1b
	ret nz

	ld hl, far_Call_5F_52F0
	rst $10
	ret


jr_053_5ab4:
	ld a, [$dd6f]
	ld b, a
	bit 5, a
	jr z, jr_053_5ad2

	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, h
	or l
	jr z, jr_053_5acc

	set 4, b
	jr jr_053_5ace

jr_053_5acc:
	res 4, b

jr_053_5ace:
	ld a, b
	ld [$dd6f], a

jr_053_5ad2:
	ld a, [$dd6f]
	bit 4, a
	jr z, jr_053_5aec

	bit 2, a
	jr nz, jr_053_5aec

	ld hl, far_Call_55_4026
	rst $10
	ld hl, far_Call_5F_52F0
	rst $10
	ld a, [$da80]
	cp $01
	jr z, Jump_53_5AED

jr_053_5aec:
	ret


Jump_53_5AED::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd6f]
	bit 2, a
	ret nz

	bit 4, a
	ret z

	ld hl, far_Call_55_4035
	rst $10
	ld hl, far_Call_5F_4A60
	rst $10
	ld a, $01
	ld [$c1c9], a

Jump_53_5B07::
	ld a, [$db8a]
	cp $84
	jr c, jr_053_5b17

	cp $88
	jr nc, jr_053_5b17

	ld a, [$da82]
	or a
	ret z

jr_053_5b17:
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd6f]
	bit 4, a
	jr z, jr_053_5b4c

	call Call_53_5CBC
	ld a, [$dd70]
	ld [$c823], a
	ld a, [$dd6f]
	bit 3, a
	jr z, jr_053_5b3a

	call Call_53_5C8D
	jr nc, jr_053_5b3a

	call Call_53_5BC6

jr_053_5b3a:
	xor a
	ld [$c822], a
	ld a, [$dd6f]
	bit 0, a
	jr z, jr_053_5b6f

	ld a, $01
	ld [$c822], a
	jr jr_053_5b79

jr_053_5b4c:
	ld hl, far_Call_55_403C
	rst $10
	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ld a, [$dd71]
	ld [$c823], a
	xor a
	ld [$c822], a
	ld a, [$dd6f]
	bit 1, a
	jr z, jr_053_5b6f

	ld a, $01
	ld [$c822], a

jr_053_5b6f:
	ld a, [$dd6f]
	bit 3, a
	jr z, jr_053_5b79

	call Call_53_5C07

jr_053_5b79:
	ld a, [$c822]
	ld l, a
	ld a, [$c823]
	ld h, a
	push hl
	call Call_53_4FF3
	pop hl
	ld a, l
	ld [$c822], a
	ld a, h
	ld [$c823], a
	ld a, [$db8a]
	cp $24
	call z, Call_53_5BAD
	ld a, [$c823]
	cp $29
	jr nz, jr_053_5ba8

	ld a, [$c822]
	or a
	jr nz, jr_053_5ba8

	ld a, $6d
	call Call_1B2C

jr_053_5ba8:
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Call_53_5BAD::
	ld a, [$dd72]
	cp $01
	ret nz

	ld hl, $c180

jr_053_5bb6:
	ld a, [hl]
	cp $f0
	jr z, jr_053_5bbe

	inc hl
	jr jr_053_5bb6

jr_053_5bbe:
	dec hl
	ld a, [hl]
	cp $24
	ret nc

	ld [hl], $f0
	ret


Call_53_5BC6::
	ld a, [$c823]
	cp $82
	jr z, jr_053_5bf6

	cp $cc
	jr z, jr_053_5bf6

	cp $e8
	jr z, jr_053_5bfb

	cp $88
	jr z, jr_053_5bf6

	cp $8a
	jr z, jr_053_5bf6

	cp $86
	jr z, jr_053_5bf6

	cp $8e
	jr z, jr_053_5bf6

	cp $95
	jr z, jr_053_5bf6

	cp $b0
	jr z, jr_053_5bf6

	cp $b2
	jr z, jr_053_5bf6

	cp $b5
	jr z, jr_053_5c01

	ret


jr_053_5bf6:
	ld hl, $c823
	inc [hl]
	ret


jr_053_5bfb:
	ld a, $e3
	ld [$c823], a
	ret


jr_053_5c01:
	ld a, $d2
	ld [$c823], a
	ret


Call_53_5C07::
	ld a, [$c823]
	cp $ca
	jr z, jr_053_5c1f

	cp $c3
	jr z, jr_053_5c30

	cp $b6
	jr z, jr_053_5c3a

	cp $b8
	jr z, jr_053_5c44

	cp $c9
	jr z, jr_053_5c1f

	ret


jr_053_5c1f:
	call Call_53_5C8D
	ret nc

	ld a, [$db8a]
	cp $7d
	jr z, jr_053_5c6e

	ld a, $c7
	ld [$c823], a
	ret


jr_053_5c30:
	call Call_53_5C8D
	ret c

	ld a, $b8
	ld [$c823], a
	ret


jr_053_5c3a:
	call Call_53_5C8D
	ret nc

	ld a, $b7
	ld [$c823], a
	ret


jr_053_5c44:
	call Call_53_5C8D
	ret nc

	ld a, [$db8a]
	cp $6b
	ret c

	cp $6e
	ret z

	cp $71
	ret z

	cp $75
	ret nc

	cp $6e
	jr c, jr_053_5c68

	cp $6f
	jr z, jr_053_5c6e

	cp $70
	jr z, jr_053_5c7a

	cp $75
	jr c, jr_053_5c74

	ret


jr_053_5c68:
	ld a, $c3
	ld [$c823], a
	ret


jr_053_5c6e:
	ld a, $c4
	ld [$c823], a
	ret


jr_053_5c74:
	add $53
	ld [$c823], a
	ret


jr_053_5c7a:
	ld a, $ca
	ld [$c823], a
	ret


	db $fa, $63, $c8, $cb, $4f, $fa, $89, $db, $c8, $fa, $88, $db, $c9

Call_53_5C8D::
	ld a, [$c863]
	bit 1, a
	jr nz, jr_053_5c9a

	ld a, [$db89]
	cp $04
	ret


jr_053_5c9a:
	ld a, [$db89]
	cp $04
	ccf
	ret


Call_53_5CA1::
	ld a, [$dcfd]
	bit 4, a
	ret z

	ld a, [$db8a]
	cp $43
	ret z

	cp $8f
	ret z

	ld a, [$db89]
	ld hl, $db04
	call Call_2F6C
	bit 6, [hl]
	ret


Call_53_5CBC::
	ld a, [$db89]
	ld hl, $db04
	call Call_2F6C
	bit 0, [hl]
	ret z

	ld hl, far_Call_54_5298
	rst $10
	ld a, [$dcff]
	bit 0, a
	ret z

	ld a, [$db8a]
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
	ld e, c
	ld d, b
	ld a, [$db89]
	call Call_2FEF
	add hl, bc
	push hl
	ld a, [$db89]
	call Call_2FE1
	pop bc
	call Call_2F45
	jr nc, jr_053_5d16

	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	jr nc, jr_053_5d14

	ld de, $0000
	jr jr_053_5d16

jr_053_5d14:
	ld b, h
	ld c, l

jr_053_5d16:
	ld a, e
	ld [$d9f2], a
	ld a, d
	ld [$d9f3], a
	ld a, $01
	or a
	ret


Call_53_5D22::
	call Call_53_5CBC
	ld a, [$d9f2]
	ld c, a
	ld a, [$d9f3]
	ld b, a
	ld a, [$db89]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld hl, $c190
	call Call_0A7C
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db89]
	ld [$db50], a
	call Call_53_43C5
	ld a, $8d
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Call_53_5D68::
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


Call_53_5D73::
	push hl
	ld a, $0a
	call Call_1E0D
	pop de
	ld a, h
	or l
	jr nz, jr_053_5d82

	ld h, d
	ld l, e
	jr jr_053_5db0

jr_053_5d82:
	ld a, [$c899]
	ld c, a
	ld a, [$c89a]
	ld b, a
	ld a, b
	and $03
	ld b, a

jr_053_5d8e:
	call Call_2F45
	jr nc, jr_053_5d9b

	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	jr jr_053_5d8e

jr_053_5d9b:
	ld h, d
	ld l, e
	srl b
	rr c
	jr c, jr_053_5da6

	add hl, bc
	jr jr_053_5db0

jr_053_5da6:
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, jr_053_5db0

	ld h, d
	ld l, e

jr_053_5db0:
	ret


Call_53_5DB1::
	push af
	push bc
	push de
	push hl
	call Call_53_4E33
	pop hl
	pop de
	pop bc
	pop af
	ld b, h
	ld c, l
	srl b
	rr c
	ld a, b
	or c
	jr nz, jr_053_5dc8

	ld c, $01

jr_053_5dc8:
	push hl
	ld a, [$c899]
	ld l, a
	ld a, [$c89a]
	ld h, a

jr_053_5dd1:
	call Call_2F45
	jr c, jr_053_5dde

	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr jr_053_5dd1

jr_053_5dde:
	ld b, h
	ld c, l
	pop hl
	sla l
	rl h
	add hl, bc
	ret


Call_53_5DE7::
	ld [$dd6c], a
	ld hl, $c1c0
	ld a, [$db88]
	ld [hli], a
	ld a, [$db89]
	ld [hli], a
	ld a, [$dd69]
	ld [hli], a
	ld a, [$db88]
	ld de, $dcec
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, [$db89]
	ld bc, $dcec
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	ld [hli], a
	inc bc
	ld a, [bc]
	ld [hli], a
	ld a, [de]
	ld [bc], a
	dec bc
	dec de
	ld a, [de]
	ld [bc], a
	ld a, [$db89]
	ld de, $dd13
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ld a, $02
	ld [de], a
	ret


Call_53_5E35::
	ld a, [$db4c]

Call_53_5E38::
	call Call_53_5DE7
	ld a, [$db89]
	ld [$db88], a
	ld a, [$dcfc]
	bit 0, a
	jr nz, jr_053_5e53

	ld a, [$dd6c]
	cp $04
	jr z, jr_053_5e53

	cp $01
	jr nz, jr_053_5e69

jr_053_5e53:
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$c1c0]
	ld [$db89], a
	ld [hl], a
	jr jr_053_5e7e

jr_053_5e69:
	ld hl, far_Call_58_5498
	rst $10
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$db89], a

jr_053_5e7e:
	xor a
	ld [$dd69], a
	ld a, $00
	ld [$d9ed], a
	ld a, $02
	ld [$d9ee], a
	ld a, [$dd6c]
	cp $08
	ret z

	cp $01
	call z, Call_53_5EA0
	ld a, $01
	ld hl, $d9ed
	ld [hli], a
	xor a
	ld [hl], a
	ret


Call_53_5EA0::
	ld a, [$db88]
	rrca
	rrca
	and $01
	ld hl, $db4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	ret z

	ld a, [hl]
	and $fc
	ld [hl], a
	ld a, [$db88]
	and $04
	ld c, a
	ld b, $01

jr_053_5ec0:
	ld a, c
	ld hl, $db04
	call Call_2F6C
	res 6, [hl]
	inc c
	dec b
	jr nz, jr_053_5ec0

	ret


Call_53_5ECE::
	push bc
	ld a, b
	call Call_53_5DE7
	pop bc
	ld a, c
	ld [$db89], a
	ret


Call_53_5ED9::
	ld a, [$c86c]
	or a
	jr nz, jr_053_5eeb

	ld a, [$db88]
	cp $04
	jr c, jr_053_5eeb

	ld de, $4102
	jr jr_053_5eee

jr_053_5eeb:
	ld de, $4025

jr_053_5eee:
	ld a, [$db88]
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	or a
	jr z, jr_053_5f0f

	cp $01
	jr z, jr_053_5f0f

	cp $02
	jr z, jr_053_5f0f

	ld a, $04

jr_053_5f0f:
	ld b, a
	ld a, [$c899]
	cp b
	ret


Call_53_5F15::
	ld a, [$d9ee]
	rst $00

JumpTable_53_5F19::
	dw Jump_53_5F21
	dw Jump_53_5F6E
	dw Jump_53_5FB6
	dw Jump_53_5FF0

Jump_53_5F21::
	ld hl, $d9f2
	ld a, [hli]
	or [hl]
	call nz, Call_53_5FFA
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	ld a, [hl]
	and $90
	jr z, jr_053_5f66

	ld a, [$dcff]
	bit 3, a
	jr z, jr_053_5f66

	call Call_53_4E33
	ld a, [$c86c]
	or a
	jr nz, jr_053_5f52

	ld a, [$db89]
	cp $04
	jr c, jr_053_5f52

	ld b, $40
	jr jr_053_5f54

jr_053_5f52:
	ld b, $aa

jr_053_5f54:
	ld a, [$c899]
	cp b
	jr nc, jr_053_5f66

	ld hl, $d9ee
	inc [hl]
	ld hl, $d9f2
	ld a, [hli]
	or [hl]
	jr z, Jump_53_5F6E

	ret


jr_053_5f66:
	ld a, $03
	ld [$d9ee], a
	jp Jump_53_5FF0


Jump_53_5F6E::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	bit 7, [hl]
	ret z

	ld a, [hl]
	and $63
	ld [hl], a
	ld hl, $d9ee
	inc [hl]
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db89]
	ld [$db50], a
	call Call_53_43C5
	ld a, $db
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10

Call_53_5FA7::
	ld a, [$db89]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	ret


Jump_53_5FB6::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	bit 4, [hl]
	jr z, Jump_53_5FF0

	ld a, [hl]
	and $63
	ld [hl], a
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db89]
	ld [$db50], a
	call Call_53_43C5
	ld a, $dc
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	call Call_53_5FA7
	ret


Jump_53_5FF0::
	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ret


Call_53_5FFA::
	ld a, [$dd6c]
	or a
	ret nz

	ld a, [$dd6e]
	or a
	ret nz

	ld a, [$db89]
	call Call_2FA5
	ret c

	ld a, [$db89]
	ld hl, $db04
	call Call_2F6C
	bit 0, [hl]
	ret z

	ld hl, far_Call_53_5D22
	rst $10
	ret


Call_53_601C::
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	ld a, [hl]
	and $90
	call nz, Call_53_60A2
	xor a
	ld [hli], a
	ld a, [hl]
	and $3c
	ld [hli], a
	inc hl
	res 7, [hl]
	inc hl
	inc hl
	ld a, [hl]
	and $fc
	ld [hl], a
	inc hl
	bit 7, [hl]
	ret z

	res 7, [hl]
	ld a, [$db89]
	ld [$dd72], a
	ld hl, far_Call_57_42A6
	rst $10
	ld a, [$db89]
	ld hl, $dc03
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
	ld a, [$dd72]
	ld c, a
	ld a, [$dd73]
	ld b, a
	call Call_2F45
	pop hl
	jr nc, jr_053_6071

	ld a, [$dd72]
	ld [hli], a
	ld a, [$dd73]
	ld [hl], a

jr_053_6071:
	ld a, [$db89]
	ld [$dd72], a
	ld hl, far_Call_57_424A
	rst $10
	ld a, [$db89]
	ld hl, $dbf3
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
	ld a, [$dd72]
	ld c, a
	ld a, [$dd73]
	ld b, a
	call Call_2F45
	pop hl
	ret nc

	ld a, [$dd72]
	ld [hli], a
	ld a, [$dd73]
	ld [hl], a
	ret


Call_53_60A2::
	push hl
	ld a, [$db89]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	pop hl
	ret


Call_53_60B3::
	ld a, [$d9ee]
	rst $00

JumpTable_53_60B7::
	dw Jump_53_60C9
	dw Jump_53_60DD
	dw Jump_53_6132
	dw Jump_53_6152
	dw Jump_53_617E
	dw Jump_53_61C2
	dw Jump_53_61E3
	dw Jump_53_620B
	dw Jump_53_6252

Jump_53_60C9::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2FA5
	jr nc, Jump_53_60DD

	ld a, $05
	ld [$d9ee], a
	jp Jump_53_61C2


Jump_53_60DD::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	inc hl
	ld a, [hl]
	and $30
	ld [hli], a
	ld a, [hl]
	and $c8
	ld [hli], a
	ld a, [hl]
	and $3f
	ld [hli], a
	inc hl
	ld a, [hl]
	ld b, a
	and $c0
	ld a, b
	jr z, jr_053_610f

	push hl
	ld a, [$db89]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	pop hl

jr_053_610f:
	and $33
	ld [hli], a
	ld a, [hl]
	and $3d
	ld [hli], a
	res 2, [hl]
	ld a, [$db89]
	ld hl, $c180
	ld [$db50], a
	call Call_53_43C5
	ld a, $ac
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_53_6132::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db04
	call Call_2F6C
	ld a, [hl]
	or a
	ret z

	ld [hl], $00
	ld a, $d9
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_53_6152::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db03
	call Call_2F6C
	ld a, [hl]
	or a
	jr nz, jr_053_616b

	call Call_53_647C
	ld hl, $d9ee
	inc [hl]
	ret


jr_053_616b:
	ld [hl], $00
	call Call_53_626B
	ld a, $ad
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_53_617E::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld b, a
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	call Call_53_654F
	ld a, [$db89]
	ld hl, $c1cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $80
	ld [hl], a
	ld a, [$db89]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	ld a, [$db89]
	and $03
	ld hl, $c1ca
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ret


Jump_53_61C2::
	ld a, [$db89]
	and $03
	cp $02
	jr z, jr_053_61d4

	ld hl, $db89
	inc [hl]
	xor a
	ld [$d9ee], a
	ret


jr_053_61d4:
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	and $04
	or $03
	ld [$db89], a
	ret


Jump_53_61E3::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2FA5
	ret c

	call Call_53_650C
	ld a, [$db89]
	ld hl, $c180
	ld [$db50], a
	call Call_53_43C5
	ld a, $d8
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Jump_53_620B::
	ld hl, $d9ee
	inc [hl]
	ld hl, $db00
	res 3, [hl]
	inc hl
	res 3, [hl]
	ld a, [$db89]
	cp $04
	jr c, jr_053_6223

	ld hl, $db01
	jr jr_053_6226

jr_053_6223:
	ld hl, $db00

jr_053_6226:
	ld a, [hl]
	and $10
	ld [hl], a
	ld a, [$db8a]
	cp $83
	jr z, jr_053_6234

	cp $a5
	ret nz

jr_053_6234:
	ld hl, $db00
	set 3, [hl]
	inc hl
	set 3, [hl]
	ld a, [$db88]
	and $04
	ld b, a
	ld a, [$db89]
	and $04
	cp b
	ret z

	ld a, b
	ld [$db89], a
	xor a
	ld [$d9ee], a
	ret


Jump_53_6252::
	ld hl, $d9ed
	inc [hl]
	ld hl, $d9ed
	inc [hl]
	ld hl, $d9ed
	inc [hl]
	xor a
	ld [$d9ee], a
	xor a
	ld [$dd72], a
	xor a
	ld [$dd73], a
	ret


Call_53_626B::
	ld a, [$db89]
	ld [$db4c], a
	ld hl, far_Call_51_46AA
	rst $10
	ld a, [$c86c]
	or a
	jr nz, jr_053_6287

	ld a, [$db89]
	cp $04
	jr c, jr_053_6287

	call Call_53_63C7
	jr jr_053_628a

jr_053_6287:
	call Call_53_62F1

jr_053_628a:
	ld a, [$db89]
	ld hl, $dba3
	call Call_53_62CF
	push hl
	ld a, [$db89]
	ld hl, $dbb3
	call Call_53_62CF
	pop bc
	call Call_2F45
	jr nc, jr_053_62ac

	ld a, [$db89]
	ld hl, $dba3
	call Call_53_62DA

jr_053_62ac:
	ld a, [$db89]
	ld hl, $dbc3
	call Call_53_62CF
	push hl
	ld a, [$db89]
	ld hl, $dbd3
	call Call_53_62CF
	pop bc
	call Call_2F45
	jr nc, jr_053_62ce

	ld a, [$db89]
	ld hl, $dbc3
	call Call_53_62DA

jr_053_62ce:
	ret


Call_53_62CF::
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


Call_53_62DA::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, h
	ld c, l
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a
	ret


Call_53_62F1::
	ld a, [$db89]
	and $03
	cp $03
	jp z, Call_53_63C7

	ld a, [$db89]
	ld hl, $cb13
	call Call_224F
	ld a, [$db89]
	ld hl, $dbb3
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb17
	call Call_224F
	ld a, [$db89]
	ld hl, $dbd3
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb19
	call Call_224F
	ld a, [$db89]
	ld hl, $dbe3
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb1b
	call Call_224F
	ld a, [$db89]
	ld hl, $dbf3
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb1d
	call Call_224F
	ld a, [$db89]
	ld hl, $dc03
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb1f
	call Call_224F
	ld a, [$db89]
	ld hl, $dc13
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb0c
	call Call_224A
	ld b, a
	ld a, [$db89]
	ld hl, $db9b
	call Call_53_6546
	ld a, [$db89]
	ld hl, $cb25
	call Call_224A
	ld b, a
	ld a, [$db89]
	ld hl, $dc44
	call Call_53_6546
	ld a, [$db89]
	ld hl, $cb26
	call Call_224A
	ld b, a
	ld a, [$db89]
	ld hl, $dc54
	call Call_53_6546
	ld a, [$db89]
	ld hl, $cb28
	call Call_224A
	ld b, a
	ld a, [$db89]
	ld hl, $dc4c
	call Call_53_6546
	ld a, [$db89]
	ld hl, $cb27
	call Call_224A
	ld b, a
	ld a, [$db89]
	ld hl, $dc5c
	call Call_53_6546
	ret


Call_53_63C7::
	sub $04
	ld hl, $da03
	call Call_53_5D68
	ld a, l
	ld [$da12], a
	ld a, h
	ld [$da13], a
	ld hl, far_Call_14_4016
	rst $10
	ld hl, $da1c
	ld a, [$db89]
	ld de, $db9b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, [$db89]
	ld b, a
	ld de, $dbb3
	add a
	ld c, a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, $dbd3
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, $dbe3
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, $dbf3
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, $dc03
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, $dc13
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, $dc44
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, $dc54
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, $dc4c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, $dc5c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ret


Call_53_647C::
	ld a, [$c86c]
	or a
	jr nz, jr_053_648d

	ld a, [$db89]
	cp $03
	jr c, jr_053_648d

	call Call_53_64BA
	ret


jr_053_648d:
	ld a, [$db89]
	and $03
	cp $03
	ret z

	ld a, [$db89]
	ld hl, $cb1b
	call Call_224F
	ld a, [$db89]
	ld hl, $dbf3
	call Call_53_653B
	ld a, [$db89]
	ld hl, $cb1d
	call Call_224F
	ld a, [$db89]
	ld hl, $dc03
	call Call_53_653B
	ret


Call_53_64BA::
	ld a, [$db89]
	and $03
	cp $03
	ret z

	ld hl, $da03
	call Call_53_5D68
	ld a, l
	ld [$da12], a
	ld a, h
	ld [$da13], a
	ld hl, far_Call_14_4016
	rst $10
	ld hl, $da25
	ld a, [$db89]
	add a
	ld de, $dc03
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ld hl, $da23
	ld a, [$db89]
	add a
	ld de, $dbf3
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C
	ld a, [hl]
	and $3f
	ld [hl], a
	ret


Call_53_650C::
	ld a, [$db89]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [$db89]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret


Call_53_653B::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


Call_53_6546::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


Call_53_654F::
	call Call_53_6593
	ld a, [$c863]
	bit 1, a
	ld a, b
	jr z, jr_053_6560

	cp $03
	jr nc, jr_053_6592

	jr jr_053_656a

jr_053_6560:
	cp $04
	jr c, jr_053_6592

	cp $07
	jr z, jr_053_6592

	sub $04

jr_053_656a:
	push bc
	ld bc, $0240
	call Call_1DE6
	ld bc, $9000
	add hl, bc
	pop bc
	push hl
	ld l, c
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
	call Call_1577
	ld hl, far_Call_51_6959
	rst $10
	ld hl, far_Call_17_46DD
	rst $10

jr_053_6592:
	ret


Call_53_6593::
	ld a, [$c81d]
	or a
	ret z

	ld a, $02
	ldh [rSVBK], a
	ld a, b
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ld a, $00
	ldh [rSVBK], a
	ret


Call_53_65AC::
	ld a, [$d9ee]
	rst $00

JumpTable_53_65B0::
	dw Jump_53_65BA
	dw Jump_53_661B
	dw Jump_53_667C
	dw Jump_53_66A6
	dw Jump_53_66BD

Jump_53_65BA::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld [$dd72], a
	ld hl, far_Call_57_424A
	rst $10
	ld a, [$dd72]
	ld c, a
	ld a, [$dd73]
	ld b, a
	srl b
	rr c
	call Call_53_66E1
	ld a, [$db89]
	ld hl, $dbf3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_53_66E8
	ld a, c
	ld [$db56], a
	ld a, b
	ld [$db57], a
	call Call_53_66D6
	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, h
	or l
	jr z, jr_053_661a

	call Call_53_4FF3
	ld a, $86
	ld [$c823], a
	call Call_53_66FA
	ld a, $72
	call Call_1B2C
	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C
	set 7, [hl]
	ret


jr_053_661a:
	ret


Jump_53_661B::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld [$dd72], a
	ld hl, far_Call_57_42A6
	rst $10
	ld a, [$dd72]
	ld c, a
	ld a, [$dd73]
	ld b, a
	srl b
	rr c
	call Call_53_66E1
	ld a, [$db89]
	ld hl, $dc03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_53_66E8
	ld a, c
	ld [$db56], a
	ld a, b
	ld [$db57], a
	call Call_53_66D6
	ld a, [$db56]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, h
	or l
	jr z, jr_053_667b

	call Call_53_4FF3
	ld a, $95
	ld [$c823], a
	call Call_53_66FA
	ld a, $72
	call Call_1B2C
	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C
	set 7, [hl]
	ret


jr_053_667b:
	ret


Jump_53_667C::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $db03
	call Call_2F6C
	bit 1, [hl]
	jr nz, jr_053_66a5

	set 1, [hl]
	call Call_53_44A0
	ld a, $98
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $84
	call Call_1B2C
	ret


jr_053_66a5:
	ret


Jump_53_66A6::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2FA5
	ret c

	ld a, [$db89]
	ld hl, $db08
	call Call_2F6C
	set 7, [hl]
	ret


Jump_53_66BD::
	ld hl, $d9ed
	inc [hl]
	ld hl, $d9ed
	inc [hl]
	ld hl, $d9ed
	inc [hl]
	xor a
	ld [$d9ee], a
	xor a
	ld [$dd72], a
	xor a
	ld [$dd73], a
	ret


Call_53_66D6::
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret nc

	xor a
	ld [hld], a
	ld [hl], a
	ret


Call_53_66E1::
	ld a, b
	or c
	ret nz

	ld bc, $0001
	ret


Call_53_66E8::
	ld a, [hli]
	sub c
	ld e, a
	ld a, [hld]
	sbc b
	ld d, a
	jr c, jr_053_66f4

	or e
	jr z, jr_053_66f4

	ret nc

jr_053_66f4:
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	dec bc
	ret


Call_53_66FA::
	ld a, [$db89]
	cp $04
	jr nc, jr_053_6705

	ld hl, $c823
	inc [hl]

jr_053_6705:
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ret


Call_53_670E::
	ld a, [$d9ee]
	rst $00

JumpTable_53_6712::
	dw Jump_53_6720
	dw Jump_53_67A9
	dw Jump_53_6866
	dw Jump_53_68B4
	dw Jump_53_6971
	dw Jump_53_6A04
	dw Jump_53_6A89

Jump_53_6720::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	call Call_2FA5
	jr c, jr_053_674b

	ld a, [$db89]
	ld hl, $db07
	call Call_2F6C
	ld a, [hl]
	and $c0
	jr z, jr_053_6752

	call Call_53_44A0
	ld a, $ba
	ld [$c823], a
	ld a, $00
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10

jr_053_674b:
	ld a, $03
	ld [$d9ee], a
	jr jr_053_67a8

jr_053_6752:
	ld a, [$dd6e]
	or a
	jr nz, jr_053_67a8

	inc hl
	bit 4, [hl]
	jr z, jr_053_67a8

	inc hl
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call Call_2F76
	jr c, jr_053_67a8

	ld a, b
	ld hl, $c180
	push bc
	ld [$db50], a
	call Call_53_43C5
	ld a, [$db89]
	ld [$c1c8], a
	ld hl, $c190
	ld [$db50], a
	call Call_53_43C5
	pop bc
	ld a, b
	ld [$db89], a
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $80
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $04
	ld [$dd6e], a

jr_053_67a8:
	ret


Jump_53_67A9::
	ld hl, $d9ee
	inc [hl]
	call Call_53_51AA
	or a
	jp z, Jump_053_6858

	call Call_53_4E33
	ld a, [$db89]
	ld hl, $dd2b
	ld b, a
	add a
	add b
	add a
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	cp $03
	jp z, Jump_053_6858

	cp $02
	jr c, jr_053_67db

	ld a, [$c899]
	cp $c0
	jr nc, jr_053_6858

jr_053_67db:
	call Call_53_44A0
	ld a, [$db89]
	call Call_2FE8
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	ld a, [$c89a]
	cp $7f
	jr c, jr_053_6832

	ld a, $64
	call Call_1E0D
	ld a, h
	or l
	jr nz, jr_053_67ff

	ld hl, $0001

jr_053_67ff:
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	jr c, jr_053_6832

	or c
	jr z, jr_053_6832

	ld a, $6c
	ld [$dd73], a
	ld a, c
	ld [$db56], a
	ld a, b
	ld [$db57], a
	call Call_53_4FFD
	ld a, $82
	ld [$c823], a
	call Call_53_6C48
	jr nc, jr_053_6846

	ld hl, $c823
	inc [hl]
	jr jr_053_6846

jr_053_6832:
	ld a, $e9
	ld [$c823], a
	ld a, $9c
	ld [$dd73], a
	call Call_53_6C48
	jr nc, jr_053_6846

	ld a, $e3
	ld [$c823], a

jr_053_6846:
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, [$dd73]
	cp $ff
	ret z

	call Call_1B2C
	ret


Jump_053_6858:
jr_053_6858:
	ld hl, $d9ee
	inc [hl]
	call Call_53_44A0
	ld a, $b8
	ld [$c823], a
	jr jr_053_6846

Jump_53_6866::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db89]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hld], a
	or [hl]
	ret nz

	ld a, [$db89]
	ld [$db4c], a
	xor a
	ld [$d9f0], a
	ld hl, far_Call_51_4BE8
	rst $10
	call Call_53_6C48
	jr c, jr_053_68af

	ld hl, far_Call_58_5749
	rst $10
	ld a, $03
	ld [$d9ed], a
	ld a, [$c86c]
	or a
	ret nz

	ld a, [$db89]
	ld [$dd61], a
	ret


jr_053_68af:
	ld hl, far_Call_50_7C4D
	rst $10
	ret


Jump_53_68B4::
	ld a, [$c1c8]
	cp $ff
	jr z, jr_053_68df

	ld hl, far_Call_50_7C4D
	rst $10
	ld a, [$c1c8]
	ld [$db89], a
	ld a, [$db88]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db89]
	ld [hl], a
	ld a, $ff
	ld [$c1c8], a
	xor a
	ld [$dd6e], a

jr_053_68df:
	ld a, [$dd6c]
	or a
	jr nz, jr_053_68fd

	ld hl, $d9ee
	inc [hl]

Call_53_68E9::
	ld a, [$db89]
	and $03
	cp $02
	ret z

	ld hl, $db89
	inc [hl]
	call Call_53_690E
	xor a
	ld [$d9ee], a
	ret


jr_053_68fd:
	ld hl, far_Call_52_7EF1
	rst $10
	call Call_53_68E9
	ret


	db $21, $ed, $d9, $34, $af, $ea, $ee, $d9, $c9

Call_53_690E::
	ld a, [$dcfe]
	bit 0, a
	ret z

	ld a, [$dd6c]
	bit 2, a
	ret nz

	ld a, [$db89]
	ld hl, $db04
	call Call_2F6C
	ld a, [hl]
	and $22
	ret z

	ld a, $00
	ld [$dd6d], a
	bit 1, [hl]
	jr nz, jr_053_6937

	res 5, [hl]
	ld a, $07
	ld [$dd6d], a

jr_053_6937:
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	jr z, jr_053_6944

	ld a, [$db88]

jr_053_6944:
	rrca
	rrca
	and $01
	add $7b
	ld a, a
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $04
	call Call_53_5E38
	ld a, $02
	ld [$dd6e], a
	ld a, $03
	ld [$d9ed], a
	ld a, $03
	ld [$d9ee], a
	ret


Jump_53_696B::
	ld a, [$db88]
	ld [$db89], a

Jump_53_6971::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db88]
	call Call_2FA5
	ret c

	call Call_53_4E33
	call Call_53_44B5
	ld a, [$db88]
	call Call_2FE8
	ld a, l
	ld [$db56], a
	ld a, h
	ld [$db57], a
	ld a, [$c899]
	cp $7f
	jr c, jr_053_69d7

	ld a, $64
	call Call_1E0D
	ld a, h
	or l
	jr nz, jr_053_69a3

	ld hl, $0001

jr_053_69a3:
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	or c
	jr z, jr_053_69d7

	ld a, c
	ld [$db56], a
	ld a, b
	ld [$db57], a
	call Call_53_4FFD
	ld a, $85
	ld [$c823], a
	ld a, $ff
	ld [$dd73], a
	jr jr_053_69f2

jr_053_69cb:
	ld a, $e5
	ld [$c823], a
	ld a, $ff
	ld [$dd73], a
	jr jr_053_69f2

jr_053_69d7:
	ld a, [$db8a]
	cp $96
	jr z, jr_053_69cb

	ld a, $ff
	ld [$dd73], a
	ld a, $e7
	ld [$c823], a
	call Call_53_6C59
	jr nc, jr_053_69f2

	ld a, $ea
	ld [$c823], a

jr_053_69f2:
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, [$dd73]
	cp $ff
	ret z

	call Call_1B2C
	ret


Jump_53_6A04::
	ld hl, $d9ee
	inc [hl]
	ld a, [$db88]
	call Call_2FA5
	jr c, jr_053_6a39

	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db56]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hld], a
	or [hl]
	ret nz

	ld a, [$db88]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $01
	ld [hl], a

jr_053_6a39:
	ld a, [$db88]
	ld [$db4c], a
	xor a
	ld [$d9f0], a
	ld hl, far_Call_51_4BE8
	rst $10
	ld a, [$db89]
	push af
	ld a, [$db88]
	ld [$db89], a
	call Call_53_6C59
	jr c, jr_053_6a70

	ld a, [$d9ed]
	push af
	ld hl, far_Call_58_5749
	rst $10
	pop af
	ld [$d9ed], a
	ld a, [$c86c]
	or a
	jr nz, jr_053_6a74

	ld a, [$db89]
	ld [$dd61], a
	jr jr_053_6a74

jr_053_6a70:
	ld hl, far_Call_50_7C4D
	rst $10

jr_053_6a74:
	pop af
	ld [$db89], a
	ret


Jump_53_6A79::
	ld a, [$db88]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hli], a
	ld [hl], a

Jump_53_6A89::
	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	xor a
	ld [$dd72], a
	xor a
	ld [$dd73], a
	ret


Call_53_6A9B::
	ld a, [$d9ee]
	rst $00

JumpTable_53_6A9F::
	dw Jump_53_6AAD
	dw Jump_53_6ADD
	dw Jump_53_6B53
	dw Jump_53_6B7E
	dw Jump_53_696B
	dw Jump_53_6A04
	dw Jump_53_6A79

Jump_53_6AAD::
	ld hl, $d9ee
	inc [hl]
	xor a
	ld [$dd73], a
	ld a, [$db89]
	ld hl, $db88
	cp [hl]
	jr z, jr_053_6ad4

	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_053_6ad4

	cp $01
	ret z

	ld hl, $d9ee
	inc [hl]
	ret


jr_053_6ad4:
	ld hl, $d9ee
	inc [hl]
	ld hl, $d9ee
	inc [hl]
	ret


Jump_53_6ADD::
	ld hl, $d9ee
	inc [hl]
	ld hl, $d9ee
	inc [hl]
	ld a, $9e
	ld [$dd73], a
	call Call_53_6BC1
	ld a, [$db89]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	ld a, [$db89]
	ld hl, $db02
	call Call_2F6C
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	ld b, a
	jr nz, jr_053_6b1e

	cp $03
	jr c, jr_053_6b31

	jr jr_053_6b22

jr_053_6b1e:
	cp $03
	jr nc, jr_053_6b31

jr_053_6b22:
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	call Call_53_654F
	jr jr_053_6b42

jr_053_6b31:
	swap a
	ld hl, $8da0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld de, $5b02
	call Call_1577

jr_053_6b42:
	ld a, $9e
	ld [$dd73], a
	ld a, $ff
	ld [$db5c], a
	call Call_53_44A0
	ret


	db $25, $2b, $31

Jump_53_6B53::
	ld hl, $d9ee
	inc [hl]
	call Call_53_6BC1
	ld hl, far_Call_5F_52F0
	rst $10
	ld a, $84
	ld [$dd73], a
	call Call_53_44A0
	ld a, [$c86c]
	or a
	jr z, jr_053_6b72

	call Call_53_6C59
	ret nc

	jr jr_053_6b78

jr_053_6b72:
	ld a, [$db88]
	cp $04
	ret nc

jr_053_6b78:
	ld a, $70
	ld [$db5c], a
	ret


Jump_53_6B7E::
	ld hl, $d9ee
	inc [hl]
	ld a, [$dd73]
	or a
	jr z, jr_053_6bb0

	ld a, [$dd73]
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, [$db5c]
	cp $ff
	jr z, jr_053_6bb0

	ld a, [$c86c]
	or a
	jr nz, jr_053_6baa

	ld a, [$db88]
	cp $04
	jr nc, jr_053_6bb0

jr_053_6baa:
	ld a, [$db5c]
	call Call_1B2C

jr_053_6bb0:
	ld a, [$db89]
	and $03
	cp $02
	ret z

	ld hl, $db89
	inc [hl]
	xor a
	ld [$d9ee], a
	ret


Call_53_6BC1::
	ld a, [$db89]
	ld hl, $dbb3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [$db89]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	ret


Call_53_6BE2::
	ld a, [$db89]
	cp $03
	jr z, jr_053_6c3e

	cp $06
	jr z, jr_053_6c0a

	cp $03
	jr c, jr_053_6c1b

	inc a
	ld [$db89], a
	call Call_2FA5
	jr c, Call_53_6BE2

	ld a, $01
	ld [$d9ed], a
	ld a, $0b
	ld [$d9ee], a
	ld a, $00
	ld [$d9f0], a
	ret


jr_053_6c0a:
	ld a, [$db8a]
	cp $a4
	jr z, jr_053_6c3e

	ld a, $00
	ld [$db89], a
	call Call_2FA5
	jr c, Call_53_6BE2

jr_053_6c1b:
	call Call_2FA5
	jr c, jr_053_6c38

	ld a, [$db89]
	call Call_53_44A0
	ld a, $aa
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld hl, $db89
	inc [hl]
	ret


jr_053_6c38:
	ld hl, $db89
	inc [hl]
	jr Call_53_6BE2

jr_053_6c3e:
	ld a, $06
	ld [$d9ed], a
	xor a
	ld [$d9ee], a
	ret


Call_53_6C48::
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	jr nz, jr_053_6c55

	cp $04
	ret


jr_053_6c55:
	cp $04
	ccf
	ret


Call_53_6C59::
	ld a, [$c863]
	bit 1, a
	ld a, [$db88]
	jr nz, jr_053_6c66

	cp $04
	ret


jr_053_6c66:
	cp $04
	ccf
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
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00
