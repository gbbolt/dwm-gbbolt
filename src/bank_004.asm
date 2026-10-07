INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

BankNumber_04::
	db $04

FarTable_04::
	dw Call_04_400F
	dw Call_04_4016
	dw Call_04_4081
	dw Call_04_40A7
	dw $4167
	dw Call_04_55EC
	dw $56fa

Call_04_400F::
	ld de, $401d
	call Call_0D91
	ret


Call_04_4016::
	ld de, $401d
	call Call_04_40CD
	ret


	db $23, $40, $2a, $40, $3d, $40, $25, $40, $00, $00, $00, $00, $80, $2c, $40, $00
	db $00, $00, $10, $00, $08, $01, $10, $08, $00, $02, $10, $08, $08, $03, $10, $80
	db $45, $40, $4e, $40, $63, $40, $70, $40, $00, $00, $90, $00, $08, $00, $91, $00
	db $80, $00, $00, $a6, $00, $00, $08, $a7, $00, $00, $10, $a8, $00, $00, $30, $a4
	db $00, $08, $30, $a5, $00, $80, $f8, $08, $00, $00, $00, $00, $01, $00, $00, $08
	db $02, $00, $80, $00, $00, $00, $00, $00, $08, $01, $00, $08, $00, $10, $00, $08
	db $08, $11, $00, $80

Call_04_4081::
	ldh a, [$ffc7]
	cp $90
	jr nc, jr_004_409e

	cp $10
	jr nc, jr_004_4095

	call Call_04_4126
	ld de, $4137
	call Call_0D91
	ret


jr_004_4095:
	sub $10
	ldh [$ffc7], a
	ld hl, far_Call_10_4005
	rst $10
	ret


jr_004_409e:
	sub $90
	ldh [$ffc7], a
	ld hl, far_Call_11_4005
	rst $10
	ret


Call_04_40A7::
	ldh a, [$ffc7]
	cp $90
	jr nc, jr_004_40c4

	cp $10
	jr nc, jr_004_40bb

	call Call_04_4126
	ld de, $4137
	call Call_04_40CD
	ret


jr_004_40bb:
	sub $10
	ldh [$ffc7], a
	ld hl, far_Call_10_400F
	rst $10
	ret


jr_004_40c4:
	sub $90
	ldh [$ffc7], a
	ld hl, far_Call_11_400F
	rst $10
	ret


Call_04_40CD::
	push af
	push bc
	push de
	push hl
	ldh a, [$ffcb]
	cp $28
	jr nc, jr_004_4121

	ldh a, [$ffc7]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ldh a, [$ffc8]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ldh a, [$ffcb]
	sla a
	sla a
	ld l, a
	ld h, $c0

jr_004_40f4:
	ld a, [de]
	inc de
	cp $80
	jr z, jr_004_4121

	ld b, a
	ldh a, [$ffc5]
	add b
	add $10
	ld [hli], a
	ld a, [de]
	inc de
	ld b, a
	ldh a, [$ffc3]
	add b
	add $08
	ld [hli], a
	ldh a, [$ffc9]
	ld b, a
	ld a, [de]
	inc de
	add b
	ld [hli], a
	ld a, [de]
	inc de
	ld b, a
	ldh a, [$ffca]
	xor b
	ld [hli], a
	ldh a, [$ffcb]
	inc a
	ldh [$ffcb], a
	cp $28
	jr c, jr_004_40f4

jr_004_4121:
	pop hl
	pop de
	pop bc
	pop af
	ret


Call_04_4126::
	ldh a, [$ffc7]
	ld hl, $4157
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ldh a, [$ffca]
	or [hl]
	ldh [$ffca], a
	ret


	db $37, $72, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77
	db $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77, $38, $77
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

	ld a, [$c8eb]
	res 0, a
	res 2, a
	or a
	ret nz

	ld a, [$c8eb]
	bit 0, a
	jr z, jr_004_417f

	ld a, [$c915]
	cp $0b
	ret nz

	jr jr_004_4189

jr_004_417f:
	bit 2, a
	jr z, jr_004_4189

	ld a, [$c91e]
	cp $02
	ret nz

jr_004_4189:
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c825]
	or a
	ret nz

	ld a, [$d8d7]
	bit 0, a
	jp z, Jump_004_41c7

	bit 1, a
	jp nz, Jump_004_41c7

	ld a, [$d8d7]
	bit 4, a
	call nz, Call_04_43EC
	ld a, [$d8d7]
	bit 6, a
	call nz, Call_04_43EC
	ld a, [$d8d7]
	bit 2, a
	jr nz, jr_004_41c8

	bit 3, a
	jp nz, Jump_004_41e0

	ld a, [$d8d8]
	bit 2, a
	jp nz, Jump_004_43db

	call Call_04_55F5

Jump_004_41c7:
	ret


jr_004_41c8:
	ld a, [$c8a4]
	and $07
	jr nz, jr_004_41dd

	ld a, [$d8db]
	dec a
	ld [$d8db], a
	jr nz, jr_004_41dd

	ld hl, $d8d7
	res 2, [hl]

jr_004_41dd:
	jp Jump_004_41c7


Jump_004_41e0:
	ld a, [$d8dc]
	or a
	jp nz, Jump_004_42cd

	ld hl, $ff90
	set 0, [hl]
	ld a, [$c8a4]
	and $03
	cp $01
	jp z, Jump_004_43d8

	ld a, [$d8dd]
	ld l, a
	ld a, [$d8de]
	ld h, a
	ld a, h
	or l
	jr z, jr_004_425a

	bit 7, h
	jr nz, jr_004_4231

	ld a, [$d8dd]
	sub $01
	ld [$d8dd], a
	ld a, [$d8de]
	sbc $00
	ld [$d8de], a
	ldh a, [$ff92]
	add $01
	ldh [$ff92], a
	ldh a, [$ff93]
	adc $00
	ldh [$ff93], a
	ld a, [$d8d7]
	bit 5, a
	jp nz, Jump_004_42ba

	ld a, $03
	ldh [$ff8e], a
	jp Jump_004_42ba


jr_004_4231:
	ld a, [$d8dd]
	add $01
	ld [$d8dd], a
	ld a, [$d8de]
	adc $00
	ld [$d8de], a
	ldh a, [$ff92]
	sub $01
	ldh [$ff92], a
	ldh a, [$ff93]
	sbc $00
	ldh [$ff93], a
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_42ba

	ld a, $01
	ldh [$ff8e], a
	jr jr_004_42ba

jr_004_425a:
	ld a, [$d8df]
	ld l, a
	ld a, [$d8e0]
	ld h, a
	ld a, h
	or l
	jr z, jr_004_42c0

	bit 7, h
	jr nz, jr_004_4293

	ld a, [$d8df]
	sub $01
	ld [$d8df], a
	ld a, [$d8e0]
	sbc $00
	ld [$d8e0], a
	ldh a, [$ff95]
	add $01
	ldh [$ff95], a
	ldh a, [$ff96]
	adc $00
	ldh [$ff96], a
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_42ba

	ld a, $00
	ldh [$ff8e], a
	jr jr_004_42ba

jr_004_4293:
	ld a, [$d8df]
	add $01
	ld [$d8df], a
	ld a, [$d8e0]
	adc $00
	ld [$d8e0], a
	ldh a, [$ff95]
	sub $01
	ldh [$ff95], a
	ldh a, [$ff96]
	sbc $00
	ldh [$ff96], a
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_42ba

	ld a, $02
	ldh [$ff8e], a

Jump_004_42ba:
jr_004_42ba:
	call Call_04_454B
	jp Jump_004_43d8


jr_004_42c0:
	ld hl, $ff90
	res 0, [hl]
	ld hl, $d8d7
	res 3, [hl]
	jp Jump_004_43d8


Jump_004_42cd:
	dec a
	swap a
	add a
	ld hl, $d7d2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	set 0, [hl]
	res 6, [hl]
	ld a, [$c8a4]
	and $03
	cp $01
	jp z, Jump_004_43d8

	ld a, [$d8dd]
	ld e, a
	ld a, [$d8de]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_435f

	bit 7, d
	jr nz, jr_004_4333

	ld a, [$d8dd]
	sub $01
	ld [$d8dd], a
	ld a, [$d8de]
	sbc $00
	ld [$d8de], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_4320

	ld [hl], $03

jr_004_4320:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jp Jump_004_43d8


jr_004_4333:
	ld a, [$d8dd]
	add $01
	ld [$d8dd], a
	ld a, [$d8de]
	adc $00
	ld [$d8de], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_434d

	ld [hl], $01

jr_004_434d:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr jr_004_43d8

jr_004_435f:
	ld a, [$d8df]
	ld e, a
	ld a, [$d8e0]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_43c7

	bit 7, d
	jr nz, jr_004_439b

	ld a, [$d8df]
	sub $01
	ld [$d8df], a
	ld a, [$d8e0]
	sbc $00
	ld [$d8e0], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_4389

	ld [hl], $00

jr_004_4389:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr jr_004_43d8

jr_004_439b:
	ld a, [$d8df]
	add $01
	ld [$d8df], a
	ld a, [$d8e0]
	adc $00
	ld [$d8e0], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_43b5

	ld [hl], $02

jr_004_43b5:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr jr_004_43d8

jr_004_43c7:
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	res 0, [hl]
	ld hl, $d8d7
	res 3, [hl]

Jump_004_43d8:
jr_004_43d8:
	jp Jump_004_41c7


Jump_004_43db:
	ld a, [$d8db]
	dec a
	ld [$d8db], a
	jr nz, jr_004_43e9

	ld hl, $d8d8
	res 2, [hl]

jr_004_43e9:
	jp Jump_004_41c7


Call_04_43EC::
	ld a, [$d8e9]
	push af
	call Call_04_443D
	pop af
	ld hl, $d8f1
	or [hl]
	push af
	call Call_04_4584
	pop af
	ld hl, $d8f9
	or [hl]
	push af
	call Call_04_4584
	pop af
	ld hl, $d901
	or [hl]
	push af
	call Call_04_4584
	pop af
	ld hl, $d909
	or [hl]
	push af
	call Call_04_4584
	pop af
	ld hl, $d911
	or [hl]
	push af
	call Call_04_4584
	pop af
	ld hl, $d919
	or [hl]
	push af
	call Call_04_4584
	pop af
	ld hl, $d921
	or [hl]
	push af
	call Call_04_4584
	pop af
	or a
	ret nz

	ld hl, $d8d7
	res 4, [hl]
	res 6, [hl]
	ret


Call_04_443D::
	ld a, [$d8e9]
	or a
	ret z

	ld a, [$d8d7]
	set 4, a
	ld [$d8d7], a
	ld hl, $d8e9
	ld a, l
	ldh [$ffd7], a
	ld a, h
	ldh [$ffd8], a
	ld a, [$d8eb]
	ld hl, $ff95
	cp $01
	jp z, Jump_004_4742

	cp $03
	jp z, Jump_004_47be

	cp $04
	jp z, Jump_004_4857

	cp $06
	jp z, Jump_004_48e2

	cp $07
	jp z, Jump_004_4931

	cp $1a
	jp z, Jump_004_55a9

	ld hl, $ff90
	set 0, [hl]
	ld a, [$c8a4]
	and $03
	cp $01
	ret z

	ld a, [$d8ed]
	ld l, a
	ld a, [$d8ee]
	ld h, a
	ld a, h
	or l
	jr z, jr_004_44ea

	bit 7, h
	jr nz, jr_004_44bf

	ld a, [$d8ed]
	sub $01
	ld [$d8ed], a
	ld a, [$d8ee]
	sbc $00
	ld [$d8ee], a
	ldh a, [$ff92]
	add $01
	ldh [$ff92], a
	ldh a, [$ff93]
	adc $00
	ldh [$ff93], a
	ld a, [$d8d7]
	bit 5, a
	jp nz, Call_04_454B

	ld a, $03
	ldh [$ff8e], a
	jp Call_04_454B


jr_004_44bf:
	ld a, [$d8ed]
	add $01
	ld [$d8ed], a
	ld a, [$d8ee]
	adc $00
	ld [$d8ee], a
	ldh a, [$ff92]
	sub $01
	ldh [$ff92], a
	ldh a, [$ff93]
	sbc $00
	ldh [$ff93], a
	ld a, [$d8d7]
	bit 5, a
	jp nz, Call_04_454B

	ld a, $01
	ldh [$ff8e], a
	jp Call_04_454B


jr_004_44ea:
	ld a, [$d8ef]
	ld l, a
	ld a, [$d8f0]
	ld h, a
	ld a, h
	or l
	jp z, Jump_004_457a

	bit 7, h
	jr nz, jr_004_4524

	ld a, [$d8ef]
	sub $01
	ld [$d8ef], a
	ld a, [$d8f0]
	sbc $00
	ld [$d8f0], a
	ldh a, [$ff95]
	add $01
	ldh [$ff95], a
	ldh a, [$ff96]
	adc $00
	ldh [$ff96], a
	ld a, [$d8d7]
	bit 5, a
	jr nz, Call_04_454B

	ld a, $00
	ldh [$ff8e], a
	jr Call_04_454B

jr_004_4524:
	ld a, [$d8ef]
	add $01
	ld [$d8ef], a
	ld a, [$d8f0]
	adc $00
	ld [$d8f0], a
	ldh a, [$ff95]
	sub $01
	ldh [$ff95], a
	ldh a, [$ff96]
	sbc $00
	ldh [$ff96], a
	ld a, [$d8d7]
	bit 5, a
	jr nz, Call_04_454B

	ld a, $02
	ldh [$ff8e], a

Call_04_454B::
	ld a, $00
	ldh [$ff8d], a
	ld a, $00
	ldh [$ff8f], a
	ldh a, [$ff8e]
	or a
	ret z

	ld a, $20
	ldh [$ff8d], a
	ld a, $01
	ldh [$ff8f], a
	ldh a, [$ff8e]
	cp $01
	ret z

	ld a, $00
	ldh [$ff8d], a
	ld a, $02
	ldh [$ff8f], a
	ldh a, [$ff8e]
	cp $02
	ret z

	ld a, $00
	ldh [$ff8d], a
	ld a, $01
	ldh [$ff8f], a
	ret


Jump_004_457a:
	ld hl, $ff90
	res 0, [hl]
	xor a
	ld [$d8e9], a
	ret


Call_04_4584::
	ld a, [hl]
	or a
	ret z

	ld a, [$d8d7]
	set 4, a
	ld [$d8d7], a
	ld a, l
	ldh [$ffd7], a
	ld a, h
	ldh [$ffd8], a
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	dec a
	swap a
	add a
	ld hl, $d7d2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ldh a, [$ffd7]
	add $02
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	push af
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	pop af
	cp $01
	jp z, Jump_004_4742

	cp $02
	jp z, Jump_004_478a

	cp $04
	jp z, Jump_004_4857

	cp $05
	jp z, Jump_004_487f

	cp $08
	jp z, Jump_004_498c

	cp $09
	jp z, Jump_004_49d2

	cp $0a
	jp z, Jump_004_4a2c

	cp $0b
	jp z, Jump_004_4a52

	cp $0c
	jp z, Jump_004_4aa2

	cp $0d
	jp z, Jump_004_4b27

	cp $0e
	jp z, Jump_004_4b6d

	cp $0f
	jp z, Jump_004_4b9b

	cp $10
	jp z, Jump_004_4be7

	cp $11
	jp z, Jump_004_4c33

	cp $12
	jp z, Jump_004_4c65

	cp $13
	jp z, Jump_004_4c9f

	cp $14
	jp z, Jump_004_4d27

	cp $15
	jp z, Jump_004_4da8

	cp $16
	jp z, Jump_004_507b

	cp $17
	jp z, Jump_004_50c6

	cp $18
	jp z, Jump_004_54c8

	cp $19
	jp z, Jump_004_5546

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	set 0, [hl]
	res 6, [hl]
	ld a, [$c8a4]
	and $03
	cp $01
	ret z

	ldh a, [$ffd7]
	add $04
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_46ba

	bit 7, d
	jr nz, jr_004_468c

	ldh a, [$ffd7]
	add $04
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	sub $01
	ld [bc], a
	inc bc
	ld a, [bc]
	sbc $00
	ld [bc], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_467b

	ld [hl], $03

jr_004_467b:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_468c:
	ldh a, [$ffd7]
	add $04
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	add $01
	ld [bc], a
	inc bc
	ld a, [bc]
	adc $00
	ld [bc], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_46a9

	ld [hl], $01

jr_004_46a9:
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_46ba:
	ldh a, [$ffd7]
	add $06
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, d
	or e
	jr z, jr_004_472d

	bit 7, d
	jr nz, jr_004_46ff

	ldh a, [$ffd7]
	add $06
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	sub $01
	ld [bc], a
	inc bc
	ld a, [bc]
	sbc $00
	ld [bc], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_46ee

	ld [hl], $00

jr_004_46ee:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	inc de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_46ff:
	ldh a, [$ffd7]
	add $06
	ld c, a
	ldh a, [$ffd8]
	adc $00
	ld b, a
	ld a, [bc]
	add $01
	ld [bc], a
	inc bc
	ld a, [bc]
	adc $00
	ld [bc], a
	inc hl
	ld a, [$d8d7]
	bit 5, a
	jr nz, jr_004_471c

	ld [hl], $02

jr_004_471c:
	ld a, l
	add $14
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	dec de
	dec hl
	ld [hl], e
	inc hl
	ld [hl], d
	ret


jr_004_472d:
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	res 0, [hl]
	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ret


Jump_004_4742:
	ld bc, $4770

Call_04_4745::
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $80
	jr z, jr_004_4767

	add [hl]
	ld [hli], a
	inc bc
	ld a, [bc]
	adc [hl]
	ld [hl], a
	ret


Jump_004_4767:
jr_004_4767:
	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ret


	db $fd, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $01, $00
	db $01, $00, $02, $00, $03, $00, $03, $00, $80, $80

Jump_004_478a:
	ld bc, $4790
	jp Call_04_4745


	db $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff
	db $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $80, $80

Jump_004_47be:
	ld bc, $47d9
	call Call_04_4745
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c8a6]
	and $03
	ret z

	ldh a, [$ff8e]
	inc a
	and $03
	ldh [$ff8e], a
	jp Call_04_454B


	db $fe, $ff, $fe, $ff, $fe, $ff, $fd, $ff, $fd, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $80, $80

Jump_004_4857:
	ld bc, $485d
	jp Call_04_4745


	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

Jump_004_487f:
	ld bc, $4892
	call Call_04_4745
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	inc [hl]
	inc [hl]
	ret


	db $fb, $ff, $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff
	db $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $03, $00, $03, $00, $04, $00, $04, $00
	db $04, $00, $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $03, $00, $04, $00, $06, $00, $80, $80

Jump_004_48e2:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $40
	jr nz, jr_004_48fc

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ret


jr_004_48fc:
	ld a, [$ca37]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
	add $73
	ld l, a
	ld a, h
	adc $c9
	ld h, a
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
	ld a, [$ca37]
	inc a
	ld [$ca37], a
	cp $31
	ret c

	xor a
	ld [$ca37], a
	ret


Jump_004_4931:
	ld bc, $494c
	call Call_04_4745
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $02
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ff92], a
	ld a, h
	ldh [$ff93], a
	ret


	db $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00, $04, $00, $80, $80

Jump_004_498c:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $ff
	jr nz, jr_004_49ae

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld [hl], $00
	ret


jr_004_49ae:
	push af
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	pop af
	ld b, $0f
	cp $20
	jr c, jr_004_49ca

	ld b, $07
	cp $50
	jr c, jr_004_49ca

	ld b, $03
	cp $90
	jr c, jr_004_49ca

	ld b, $01

jr_004_49ca:
	and b
	or a
	ld [hl], $00
	ret z

	ld [hl], $40
	ret


Jump_004_49d2:
	ld bc, $4a0a
	call Call_04_4745
	ld a, [$c850]
	or a
	ret nz

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $00
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	srl a
	srl a
	and $03
	push af
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	pop af
	ld [hl], a
	jp Call_04_454B


	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

Jump_004_4a2c:
	ld bc, $4a32
	jp Call_04_4745


	db $fb, $ff, $fb, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff
	db $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $80, $80

Jump_004_4a52:
	ld bc, $4a58
	jp Call_04_4745


	db $fc, $ff, $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $01, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $00, $00, $00, $00, $00, $00, $fb, $ff, $fb, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $80, $80

Jump_004_4aa2:
	ld bc, $4ab5
	call Call_04_4745
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	dec [hl]
	dec [hl]
	ret


	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00
	db $80, $80

Jump_004_4b27:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $ff
	jr nz, jr_004_4b49

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld [hl], $40
	ret


jr_004_4b49:
	push af
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	pop af
	ld b, $0f
	cp $20
	jr c, jr_004_4b65

	ld b, $07
	cp $50
	jr c, jr_004_4b65

	ld b, $03
	cp $90
	jr c, jr_004_4b65

	ld b, $01

jr_004_4b65:
	and b
	or a
	ld [hl], $40
	ret z

	ld [hl], $00
	ret


Jump_004_4b6d:
	ld a, [$c8a6]
	and $03
	ret nz

	ld bc, $4b79
	jp Call_04_4745


	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $80, $80

Jump_004_4b9b:
	ld bc, $4ba1
	jp Call_04_4745


	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $80, $80

Jump_004_4be7:
	ld bc, $4bed
	jp Call_04_4745


	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $80, $80

Jump_004_4c33:
	ld bc, $4c39
	jp Call_04_4745


	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $04, $00, $80, $80

Jump_004_4c65:
	ld bc, $4c6b
	jp Call_04_4745


	db $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00, $05, $00
	db $05, $00, $80, $80

Jump_004_4c9f:
	ld bc, $4ca5
	jp Call_04_4745


	db $fe, $ff, $fe, $ff, $fe, $ff, $fd, $ff, $fd, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00
	db $80, $80

Jump_004_4d27:
	call Call_04_4D5C
	ld a, [$c850]
	or a
	ret nz

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $00
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	srl a
	srl a
	and $03
	push af
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	pop af
	ld [hl], a
	jp Call_04_454B


Call_04_4D5C::
	ld a, [$c8a6]
	and $01
	ret nz

	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	inc a
	ld [de], a
	cp $ff
	jr nz, jr_004_4d84

	ldh a, [$ffd7]
	ld l, a
	ldh a, [$ffd8]
	ld h, a
	ld [hl], $00
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld [hl], $00
	ret


jr_004_4d84:
	push af
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	pop af
	ld b, $0f
	cp $20
	jr c, jr_004_4da0

	ld b, $07
	cp $50
	jr c, jr_004_4da0

	ld b, $03
	cp $90
	jr c, jr_004_4da0

	ld b, $01

jr_004_4da0:
	and b
	or a
	ld [hl], $00
	ret z

	ld [hl], $40
	ret


Jump_004_4da8:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_004_4dc2

	ld a, [$d8e3]
	ld c, a
	ld a, $0a
	sub c
	add a
	add a
	add a
	inc a
	ld [de], a

jr_004_4dc2:
	ld a, [$d8e4]
	ld bc, $4df3
	cp $01
	jr z, jr_004_4ddd

	ld bc, $4e95
	cp $02
	jr z, jr_004_4ddd

	ld bc, $4f37
	cp $03
	jr z, jr_004_4ddd

	ld bc, $4fd9

jr_004_4ddd:
	call Call_04_4745
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	dec bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00
	db $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00, $02, $00
	db $03, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00
	db $03, $00, $03, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $03, $00, $02, $00, $02, $00, $03, $00, $02, $00, $03, $00, $04, $00
	db $03, $00, $04, $00, $04, $00, $80, $80

Jump_004_507b:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_004_5095

	ld a, [$d8e3]
	ld c, a
	ld a, $0a
	sub c
	add a
	add a
	add a
	inc a
	ld [de], a

jr_004_5095:
	ld a, [$d8e4]
	ld bc, $4df3
	cp $01
	jr z, jr_004_50b0

	ld bc, $4e95
	cp $02
	jr z, jr_004_50b0

	ld bc, $4f37
	cp $03
	jr z, jr_004_50b0

	ld bc, $4fd9

jr_004_50b0:
	call Call_04_4745
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc bc
	inc bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


Jump_004_50c6:
	ld a, [$d8e3]
	ld bc, $5144
	cp $01
	jr z, jr_004_510b

	ld bc, $5156
	cp $02
	jr z, jr_004_510b

	ld bc, $5178
	cp $03
	jr z, jr_004_510b

	ld bc, $51aa
	cp $04
	jr z, jr_004_510b

	ld bc, $51ec
	cp $05
	jr z, jr_004_510b

	ld bc, $523e
	cp $06
	jr z, jr_004_510b

	ld bc, $52a0
	cp $07
	jr z, jr_004_510b

	ld bc, $5312
	cp $08
	jr z, jr_004_510b

	ld bc, $5394
	cp $09
	jr z, jr_004_510b

	ld bc, $5426

jr_004_510b:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $80
	jp z, Jump_004_4767

	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, [hl]
	sbc d
	ld [hl], a
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	dec bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $80, $80, $03, $00, $03, $00, $03, $00, $02, $00
	db $03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $03, $00, $03, $00, $03, $00
	db $02, $00, $03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $03, $00, $03, $00
	db $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $03, $00
	db $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80
	db $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $80, $03, $00, $03, $00, $03, $00, $02, $00, $03, $00, $02, $00, $02, $00
	db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $02, $00, $01, $00
	db $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00
	db $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $80

Jump_004_54c8:
	ld a, [$d8e3]
	ld bc, $5144
	cp $01
	jr z, jr_004_550d

	ld bc, $5156
	cp $02
	jr z, jr_004_550d

	ld bc, $5178
	cp $03
	jr z, jr_004_550d

	ld bc, $51aa
	cp $04
	jr z, jr_004_550d

	ld bc, $51ec
	cp $05
	jr z, jr_004_550d

	ld bc, $523e
	cp $06
	jr z, jr_004_550d

	ld bc, $52a0
	cp $07
	jr z, jr_004_550d

	ld bc, $5312
	cp $08
	jr z, jr_004_550d

	ld bc, $5394
	cp $09
	jr z, jr_004_550d

	ld bc, $5426

jr_004_550d:
	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $80
	jp z, Jump_004_4767

	ld d, a
	ld a, [hl]
	sub d
	ld [hli], a
	inc bc
	ld a, [bc]
	ld d, a
	ld a, [hl]
	sbc d
	ld [hl], a
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc bc
	inc bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


Jump_004_5546:
	ld bc, $5559
	call Call_04_4745
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	dec [hl]
	dec [hl]
	ret


	db $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $01, $00, $01, $00, $02, $00, $03, $00, $04, $00, $06, $00, $fc, $ff, $fc, $ff
	db $fc, $ff, $fd, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $02, $00, $03, $00
	db $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00, $05, $00, $80, $80

Jump_004_55a9:
	ld bc, $55ca
	call Call_04_4745
	ld a, [$c850]
	or a
	ret nz

	ldh a, [$ffd7]
	add $01
	ld e, a
	ldh a, [$ffd8]
	adc $00
	ld d, a
	ld a, [de]
	srl a
	srl a
	and $03
	ldh [$ff8e], a
	jp Call_04_454B


	db $fc, $ff, $fd, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $03, $00, $03, $00, $04, $00
	db $80, $80

Call_04_55EC::
	xor a
	ld [$d8d5], a
	ld [$d8d6], a
	jr jr_004_5605

Call_04_55F5::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a

Jump_004_5605:
jr_004_5605:
	call Call_04_71EF
	ld a, b
	and c
	cp $ff
	jr nz, jr_004_5613

	xor a
	ld [$d8d7], a
	ret


jr_004_5613:
	ld hl, $d8d7
	set 0, [hl]
	ld a, b
	cp $ff
	jp nz, Jump_004_56ec

	ld a, c
	rst $00

JumpTable_04_5620::
	dw Jump_04_5711
	dw Jump_04_5740
	dw Jump_04_576F
	dw Jump_04_5788
	dw Jump_04_57A1
	dw Jump_04_57EB
	dw Jump_04_5819
	dw Jump_04_5824
	dw Jump_04_5842
	dw Jump_04_5843
	dw Jump_04_5860
	dw Jump_04_5898
	dw Jump_04_58D0
	dw Jump_04_5968
	dw Jump_04_59D2
	dw Jump_04_5A02
	dw Jump_04_5A6F
	dw Jump_04_5AC5
	dw Jump_04_5B1B
	dw Jump_04_5B49
	dw Jump_04_5B79
	dw Jump_04_5B8F
	dw Jump_04_5BD4
	dw Jump_04_5BDB
	dw Jump_04_5C14
	dw Jump_04_5C6D
	dw Jump_04_5C86
	dw Jump_04_5CCF
	dw Jump_04_5D1A
	dw Jump_04_5D4B
	dw Jump_04_5D53
	dw Jump_04_5D5B
	dw Jump_04_5E5E
	dw Jump_04_5E6D
	dw Jump_04_5E87
	dw Jump_04_5E8F
	dw Jump_04_5F13
	dw Jump_04_5F36
	dw Jump_04_5F52
	dw Jump_04_5F5C
	dw Jump_04_5F67
	dw Jump_04_5F9A
	dw Jump_04_5FDB
	dw Jump_04_6002
	dw Jump_04_6064
	dw Jump_04_6093
	dw Jump_04_61E0
	dw Jump_04_623A
	dw Jump_04_6253
	dw Jump_04_62AB
	dw Jump_04_62DD
	dw Jump_04_6332
	dw Jump_04_634F
	dw Jump_04_63BB
	dw Jump_04_63C6
	dw Jump_04_6401
	dw Jump_04_643F
	dw Jump_04_64A7
	dw Jump_04_64C2
	dw Jump_04_65AB
	dw Jump_04_6618
	dw Jump_04_6620
	dw Jump_04_6628
	dw Jump_04_6632
	dw Jump_04_6646
	dw Jump_04_669D
	dw Jump_04_66BD
	dw Jump_04_6723
	dw Jump_04_676F
	dw Jump_04_67B1
	dw Jump_04_67FD
	dw Jump_04_6822
	dw Jump_04_684D
	dw Jump_04_6866
	dw Jump_04_687F
	dw Jump_04_6898
	dw Jump_04_68A1
	dw Jump_04_68BA
	dw Jump_04_68D7
	dw Jump_04_690B
	dw Jump_04_6957
	dw Jump_04_696C
	dw Jump_04_69A9
	dw Jump_04_6A61
	dw Jump_04_6ACE
	dw Jump_04_6AFA
	dw Jump_04_6B3A
	dw Jump_04_6B73
	dw Jump_04_6BA0
	dw Jump_04_6BDF
	dw Jump_04_6D56
	dw Jump_04_6D84
	dw Jump_04_6D93
	dw Jump_04_6F64
	dw Jump_04_6F89
	dw Jump_04_6F9B
	dw Jump_04_6FFB
	dw Jump_04_7038
	dw Jump_04_705B
	dw Jump_04_707F
	dw Jump_04_70D5
	dw Jump_04_71D2

Jump_004_56ec:
	ld hl, $d8d7
	set 1, [hl]
	ld a, c
	ld [$d8d9], a
	ld a, b
	ld [$d8da], a
	ret


	ld a, [$d8d7]
	bit 1, a
	ret z

	ld hl, $d8d7
	res 1, [hl]
	ld a, [$d8d9]
	ld l, a
	ld a, [$d8da]
	ld h, a
	call Call_0AD9
	ret


Jump_04_5711::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_26AE
	jp nz, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_5740::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_26AE
	jp z, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_576F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	call Call_26A6
	jp Call_04_55F5


Jump_04_5788::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	call Call_26A0
	jp Call_04_55F5


Jump_04_57A1::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c8ef], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c8f0], a
	ld a, b
	ld [$c8f1], a
	ld hl, $c8eb
	set 4, [hl]
	xor a
	ld [$c905], a
	ld a, [$c8ef]
	cp $09
	ret z

	cp $0a
	ret z

	ld a, $59
	call Call_1B2C
	ret


Jump_04_57EB::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$da03], a
	ld a, b
	ld [$da04], a
	xor a
	ld [$da02], a
	ld hl, $c8eb
	set 6, [hl]
	xor a
	ld [$c905], a
	ld a, $01
	ld [$da09], a
	ret


Jump_04_5819::
	ld a, [$c8eb]
	bit 0, a
	ret z

	ld hl, $c915
	inc [hl]
	ret


Jump_04_5824::
	ld a, [$c8eb]
	bit 0, a
	ret nz

	ld hl, $ffff
	ld a, l
	ld [$c917], a
	ld a, h
	ld [$c918], a
	ld hl, $c8eb
	set 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	ret


Jump_04_5842::
	ret


Jump_04_5843::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8db], a
	ld hl, $d8d7
	set 2, [hl]
	ret


Jump_04_5860::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8dc], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8dd], a
	ld a, b
	ld [$d8de], a
	ld hl, $d8d7
	set 3, [hl]
	ret


Jump_04_5898::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8dc], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8df], a
	ld a, b
	ld [$d8e0], a
	ld hl, $d8d7
	set 3, [hl]
	ret


Jump_04_58D0::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	or a
	jr nz, jr_004_5942

	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF

Jump_004_58fa:
	ld a, c
	or a
	jr nz, jr_004_590d

	ld a, $00
	ldh [$ff8d], a
	ld a, $00
	ldh [$ff8f], a
	ld a, $00
	ldh [$ff8e], a
	jp Call_04_55F5


jr_004_590d:
	cp $01
	jr nz, jr_004_5920

	ld a, $20
	ldh [$ff8d], a
	ld a, $01
	ldh [$ff8f], a
	ld a, $01
	ldh [$ff8e], a
	jp Call_04_55F5


jr_004_5920:
	cp $02
	jr nz, jr_004_5933

	ld a, $00
	ldh [$ff8d], a
	ld a, $02
	ldh [$ff8f], a
	ld a, $02
	ldh [$ff8e], a
	jp Call_04_55F5


jr_004_5933:
	ld a, $00
	ldh [$ff8d], a
	ld a, $01
	ldh [$ff8f], a
	ld a, $03
	ldh [$ff8e], a
	jp Call_04_55F5


jr_004_5942:
	dec a
	swap a
	add a
	ld hl, $d7d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld [hl], c
	jp Call_04_55F5


Jump_04_5968::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	or a
	jr nz, jr_004_5996

	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	jr jr_004_59b9

jr_004_5996:
	dec a
	swap a
	add a
	ld hl, $d7d2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	add hl, bc

jr_004_59b9:
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld [hl], c
	jp Call_04_55F5


Jump_04_59D2::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [$c925]
	cp c
	jp nz, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_5A02::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c96d], a
	ld a, b
	ld [$c96e], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c96f], a
	ld a, b
	ld [$c970], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c971], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c825], a
	ret


Jump_04_5A6F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8dc], a
	ld hl, $ff92
	or a
	jr z, jr_004_5a99

	dec a
	swap a
	add a
	ld hl, $d7ea
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_004_5a99:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	ld [$d8dd], a
	ld a, b
	ld [$d8de], a
	ld hl, $d8d7
	set 3, [hl]
	ret


Jump_04_5AC5::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8dc], a
	ld hl, $ff95
	or a
	jr z, jr_004_5aef

	dec a
	swap a
	add a
	ld hl, $d7ec
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_004_5aef:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	ld [$d8df], a
	ld a, b
	ld [$d8e0], a
	ld hl, $d8d7
	set 3, [hl]
	ret


Jump_04_5B1B::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld [hl], c
	jp Call_04_55F5


Jump_04_5B49::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	jp Call_04_55F5


Jump_04_5B79::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	jp Jump_004_7212


Jump_04_5B8F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [hl]
	cp c
	jp nz, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_5BD4::
	call Call_2518
	call Call_25F1
	ret


Jump_04_5BDB::
	ld a, [$c968]
	cp $2f
	jr nz, jr_004_5c04

	ld a, [$c925]
	cp $04
	jr z, jr_004_5bed

	cp $05
	jr nz, jr_004_5c04

jr_004_5bed:
	ld hl, $9380
	ld de, $9360
	ld b, $20
	call Call_04_5C05
	ld hl, $9600
	ld de, $9620
	ld b, $20
	call Call_04_5C05
	ret


jr_004_5c04:
	ret


Call_04_5C05::
	di
	call Call_1AA6
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	ei
	inc de
	dec b
	jr nz, Call_04_5C05

	ret


Jump_04_5C14::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$da12], a
	ld a, b
	ld [$da13], a
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_004_5c36:
	ld a, [de]
	or a
	jr z, jr_004_5c48

	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_004_5c36

	ld c, $13

jr_004_5c48:
	ld a, c
	ld [$da14], a
	ld hl, far_Call_14_40B4
	rst $10
	ld a, [$ca8d]
	cp $03
	jr z, jr_004_5c68

	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da14]
	ld [hl], a
	ld hl, $ca8d
	inc [hl]

jr_004_5c68:
	ld hl, far_Call_01_484E
	rst $10
	ret


Jump_04_5C6D::
	ld a, [$d8d7]
	bit 4, a
	jp z, Call_04_55F5

	ld a, [$d8d5]
	sub $01
	ld [$d8d5], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


Jump_04_5C86::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld hl, $d8e9
	ld a, c
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	inc hl
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], c
	inc hl
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	ld hl, $d8d7
	set 4, [hl]
	jp Call_04_55F5


Jump_04_5CCF::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld hl, $d8e9
	ld a, c
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	inc hl
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], c
	inc hl
	inc hl
	inc hl
	push hl
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	pop hl
	ld [hl], c
	inc hl
	ld [hl], b
	ld hl, $d8d7
	set 4, [hl]
	jp Call_04_55F5


Jump_04_5D1A::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld hl, $d8e9
	ld a, c
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], b
	inc hl
	ld [hl], c
	ld hl, $d8d7
	set 4, [hl]
	jp Call_04_55F5


Jump_04_5D4B::
	ld hl, $d8d7
	set 5, [hl]
	jp Call_04_55F5


Jump_04_5D53::
	ld hl, $d8d7
	res 5, [hl]
	jp Call_04_55F5


Jump_04_5D5B::
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
	cp $09
	jr nz, jr_004_5db9

	ld hl, $01e1
	ld a, l
	ld [$da03], a
	ld a, h
	ld [$da04], a
	ld hl, $01e2
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	ld hl, $01e3
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a

jr_004_5db9:
	ld a, [$d9ce]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [$d9cd]
	add b
	add a
	ld hl, $5e22
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
	call Call_04_5E10
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	call Call_04_5E10
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	call Call_04_5E10
	ld [$d7d0], a
	ld a, $01
	ld [$d7d1], a
	ret


Call_04_5E10::
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
	db $0b, $00, $0a, $00, $14, $00, $08, $00, $08, $00, $08, $00

Jump_04_5E5E::
	ld hl, $c8eb
	set 6, [hl]
	xor a
	ld [$c905], a
	ld a, $01
	ld [$da09], a
	ret


Jump_04_5E6D::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	call Call_1B2C
	jp Call_04_55F5


Jump_04_5E87::
	ld hl, $d8d7
	set 6, [hl]
	jp Call_04_55F5


Jump_04_5E8F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [$ca8d]
	cp c
	jp z, Call_04_55F5

	jp c, Call_04_55F5

	ld a, c
	ld hl, $caea
	push bc
	call Call_2229
	pop bc
	ld b, $08

jr_004_5ec8:
	ld a, [hli]
	cp $00
	jr z, jr_004_5efb

	cp $01
	jr z, jr_004_5efb

	cp $02
	jr z, jr_004_5efb

	cp $03
	jr z, jr_004_5efb

	cp $04
	jr z, jr_004_5efb

	cp $05
	jr z, jr_004_5efb

	cp $44
	jr z, jr_004_5efb

	cp $5c
	jr z, jr_004_5efb

	cp $5d
	jr z, jr_004_5efb

	cp $5e
	jr z, jr_004_5efb

	cp $5f
	jr z, jr_004_5efb

	dec b
	jr nz, jr_004_5ec8

	jp Call_04_55F5


jr_004_5efb:
	ld a, c
	ld [$d8e1], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	call Call_04_71EF
	jp Jump_004_7212


Jump_04_5F13::
	ld a, [$d8d3]
	cp $06
	jr nc, jr_004_5f1f

	ld hl, far_Call_0C_402F
	rst $10
	ret


jr_004_5f1f:
	cp $20
	jr nc, jr_004_5f28

	ld hl, far_Call_0D_402F
	rst $10
	ret


jr_004_5f28:
	cp $40
	jr nc, jr_004_5f31

	ld hl, far_Call_0E_402F
	rst $10
	ret


jr_004_5f31:
	ld hl, far_Call_0F_402F
	rst $10
	ret


Jump_04_5F36::
	ld a, [$d8e1]
	ld hl, $cac1
	call Call_2229
	ld [hl], $00
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	call Call_2518
	call Call_25F1
	jp Call_04_55F5


Jump_04_5F52::
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	ret


Jump_04_5F5C::
	ld hl, far_Call_01_4BC1
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	jp Call_04_55F5


Jump_04_5F67::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, $cac1
	ld b, $14
	ld c, $00

jr_004_5f7e:
	ld a, [hl]
	or a
	jr z, jr_004_5f8e

	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_004_5f7e

jr_004_5f8e:
	ld a, c
	cp $14
	jp c, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_5F9A::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$da12], a
	ld a, b
	ld [$da13], a
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_004_5fbc:
	ld a, [de]
	or a
	jr z, jr_004_5fce

	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_004_5fbc

	jr jr_004_5fda

jr_004_5fce:
	ld a, c
	ld [$da14], a
	ld hl, far_Call_14_40B4
	rst $10
	ld hl, far_Call_01_484E
	rst $10

jr_004_5fda:
	ret


Jump_04_5FDB::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld hl, $ca51
	ld b, $14

jr_004_5ff3:
	ld a, [hl]
	or a
	jr z, jr_004_6000

	cp $ff
	jr z, jr_004_6000

	inc hl
	dec b
	jr nz, jr_004_5ff3

	ret


jr_004_6000:
	ld [hl], c
	ret


Jump_04_6002::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, $cac1
	ld b, $14
	ld c, $00

jr_004_6019:
	push hl
	ld a, [hl]
	or a
	jr z, jr_004_604c

	cp $01
	jr z, jr_004_604c

	ld a, l
	add $4b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $0a
	jr c, jr_004_604c

	ld a, l
	add $b6
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld de, $605c
	ld b, $08

jr_004_603c:
	ld a, [de]
	cp [hl]
	jr nz, jr_004_604c

	inc de
	inc hl
	dec b
	jr nz, jr_004_603c

	pop hl
	call Call_04_71EF
	jp Jump_004_7212


jr_004_604c:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_004_6019

	jp Call_04_55F5


	db $67, $85, $42, $8d, $26, $f0, $f0, $f0

Jump_04_6064::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, $ca51
	ld b, $14
	ld c, $00

jr_004_607b:
	ld a, [hli]
	or a
	jr z, jr_004_6087

	cp $ff
	jr z, jr_004_6087

	inc c
	dec b
	jr nz, jr_004_607b

jr_004_6087:
	ld a, c
	cp $14
	jp c, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_6093::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	push af
	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld a, [$da33]
	add a
	ld hl, $60f4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	push hl
	ld d, a
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	add a
	pop hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $d8d7
	set 1, [hl]
	ld a, c
	ld [$d8d9], a
	ld a, b
	ld [$d8da], a
	ret


	db $08, $61, $3e, $61, $74, $61, $3e, $61, $08, $61, $74, $61, $74, $61, $08, $61
	db $3e, $61, $aa, $61, $75, $00, $79, $00, $7d, $00, $81, $00, $85, $00, $89, $00
	db $8d, $00, $91, $00, $95, $00, $99, $00, $9d, $00, $a1, $00, $a5, $00, $a9, $00
	db $ad, $00, $b1, $00, $b5, $00, $b9, $00, $bd, $00, $c1, $00, $c5, $00, $c9, $00
	db $cd, $00, $d1, $00, $d5, $00, $d9, $00, $de, $00, $76, $00, $7a, $00, $7e, $00
	db $82, $00, $86, $00, $8a, $00, $8e, $00, $92, $00, $96, $00, $9a, $00, $9e, $00
	db $a2, $00, $a6, $00, $aa, $00, $ae, $00, $b2, $00, $b6, $00, $ba, $00, $be, $00
	db $c2, $00, $c6, $00, $ca, $00, $ce, $00, $d2, $00, $d6, $00, $da, $00, $df, $00
	db $77, $00, $7b, $00, $7f, $00, $83, $00, $87, $00, $8b, $00, $8f, $00, $93, $00
	db $97, $00, $9b, $00, $9f, $00, $a3, $00, $a7, $00, $ab, $00, $af, $00, $b3, $00
	db $b7, $00, $bb, $00, $bf, $00, $c3, $00, $c7, $00, $cb, $00, $cf, $00, $d3, $00
	db $d7, $00, $db, $00, $e0, $00, $78, $00, $7c, $00, $80, $00, $84, $00, $88, $00
	db $8c, $00, $90, $00, $94, $00, $98, $00, $9c, $00, $a0, $00, $a4, $00, $a8, $00
	db $ac, $00, $b0, $00, $b4, $00, $b8, $00, $bc, $00, $c0, $00, $c4, $00, $c8, $00
	db $cc, $00, $d0, $00, $d4, $00, $d8, $00, $dc, $00, $e1, $00

Jump_04_61E0::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	add a
	add a
	add c
	ld c, a
	ld a, [$d9df]
	dec a
	add c
	ld hl, $620d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$d9e0], a
	jp Call_04_55F5


	db $01, $01, $00, $02, $02, $02, $01, $02, $01, $02, $01, $01, $02, $00, $01, $01
	db $01, $00, $02, $01, $00, $02, $00, $00, $00, $01, $02, $00, $00, $01, $00, $01
	db $01, $01, $01, $02, $01, $02, $01, $00, $01, $01, $00, $01, $00

Jump_04_623A::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	inc [hl]
	jp Call_04_55F5


Jump_04_6253::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [$ca8d]
	cp c
	jp z, Call_04_55F5

	jp c, Call_04_55F5

	ld a, c
	ld hl, $cb19
	push bc
	call Call_2229
	pop bc
	ld a, [hli]
	sub $64
	ld a, [hl]
	sbc $00
	jp c, Call_04_55F5

	ld a, c
	ld [$d8e1], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	call Call_04_71EF
	jp Jump_004_7212


Jump_04_62AB::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld b, $00
	ld c, $00

jr_004_62bf:
	push bc
	ld hl, $ca94
	ld a, b
	call Call_267E
	pop bc
	jr z, jr_004_62cb

	inc c

jr_004_62cb:
	inc b
	ld a, b
	cp $f0
	jr nz, jr_004_62bf

	ld a, c
	cp $64
	jp c, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_62DD::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [$ca8d]
	cp c
	jp z, Call_04_55F5

	jp c, Call_04_55F5

	ld a, c
	ld hl, $caca
	push bc
	call Call_2229
	pop bc
	ld a, [hl]
	cp $af
	jp nz, Call_04_55F5

	ld a, c
	ld [$d8e1], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	call Call_04_71EF
	jp Jump_004_7212


Jump_04_6332::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	ld e, $00
	call Call_241A
	jp Call_04_55F5


Jump_04_634F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [$ca8d]
	cp c
	jp z, Call_04_55F5

	jp c, Call_04_55F5

	ld a, c
	ld hl, $caea
	push bc
	call Call_2229
	pop bc
	ld b, $08

jr_004_6388:
	ld a, [hli]
	cp $0f
	jr z, jr_004_63a3

	cp $10
	jr z, jr_004_63a3

	cp $45
	jr z, jr_004_63a3

	cp $11
	jr z, jr_004_63a3

	cp $5a
	jr z, jr_004_63a3

	dec b
	jr nz, jr_004_6388

	jp Call_04_55F5


jr_004_63a3:
	ld a, c
	ld [$d8e1], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	call Call_04_71EF
	jp Jump_004_7212


Jump_04_63BB::
	ld hl, far_Call_01_4BC1
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	jp Call_04_55F5


Jump_04_63C6::
	ld a, [$cab4]
	add a
	ld hl, $63ef
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$da03], a
	ld a, [hl]
	ld [$da04], a
	ld a, $00
	ld [$da02], a
	ld hl, $c8eb
	set 6, [hl]
	xor a
	ld [$c905], a
	ld a, $01
	ld [$da09], a
	ret


	db $3d, $01, $3e, $01, $3f, $01, $40, $01, $41, $01, $42, $01, $43, $01, $44, $01
	db $44, $01

Jump_04_6401::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld hl, $d9cf
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld hl, $ca51
	ld b, $14

jr_004_6424:
	ld a, [hl]
	or a
	jr z, jr_004_6432

	cp $ff
	jr z, jr_004_6432

	inc hl
	dec b
	jr nz, jr_004_6424

	jr jr_004_6433

jr_004_6432:
	ld [hl], c

jr_004_6433:
	ld l, c
	ld h, $08
	ld de, $c180
	call Call_097A
	jp Call_04_55F5


Jump_04_643F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [$ca8d]
	cp c
	jp z, Call_04_55F5

	jp c, Call_04_55F5

	ld a, c
	ld hl, $caea
	push bc
	call Call_2229
	pop bc
	ld b, $08

jr_004_6478:
	ld a, [hli]
	cp $84
	jr z, jr_004_648f

	cp $85
	jr z, jr_004_648f

	cp $86
	jr z, jr_004_648f

	cp $87
	jr z, jr_004_648f

	dec b
	jr nz, jr_004_6478

	jp Call_04_55F5


jr_004_648f:
	ld a, c
	ld [$d8e1], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	call Call_04_71EF
	jp Jump_004_7212


Jump_04_64A7::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld l, c
	ld h, b
	call Call_0AD9
	jp Call_04_55F5


Jump_04_64C2::
	ld a, [$ca40]
	ld [$cac0], a
	ld hl, far_Call_16_474A
	rst $10
	ld hl, $c8eb
	res 4, [hl]
	res 0, [hl]
	xor a
	ld [$c905], a
	ld a, [$cac0]
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
	call Call_04_6583
	ld a, [$cac0]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld de, $c190
	call Call_04_6598
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


Call_04_6583::
	or a
	ret z

	push af

jr_004_6586:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_004_6586

	dec de
	ld a, $a2
	ld [de], a
	inc de
	pop af
	ld l, e
	ld h, d
	call Call_09A4
	ret


Call_04_6598::
	push af

jr_004_6599:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_004_6599

	dec de
	pop af
	and $01
	add $a7
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
	ret


Jump_04_65AB::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c96d], a
	ld a, b
	ld [$c96e], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c96f], a
	ld a, b
	ld [$c970], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c971], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld hl, $c8eb
	set 5, [hl]
	xor a
	ld [$c905], a
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c825], a
	ret


Jump_04_6618::
	ld hl, $d8d8
	set 0, [hl]
	jp Call_04_55F5


Jump_04_6620::
	ld hl, $d8d8
	set 1, [hl]
	jp Call_04_55F5


Jump_04_6628::
	ld a, $04
	call Call_1688
	ld hl, $c88e
	inc [hl]
	ret


Jump_04_6632::
	ld a, $00
	ld hl, $caca
	call Call_2229
	ld l, [hl]
	ld h, $05
	ld de, $c180
	call Call_097A
	jp Call_04_55F5


Jump_04_6646::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld d, c
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld hl, $cac1
	ld b, $14
	ld c, $00

jr_004_6671:
	push hl
	ld a, [hl]
	or a
	jr z, jr_004_668d

	cp $01
	jr z, jr_004_668d

	ld a, l
	add $09
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp d
	jr nz, jr_004_668d

	pop hl
	call Call_04_71EF
	jp Jump_004_7212


jr_004_668d:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	dec b
	jr nz, jr_004_6671

	jp Call_04_55F5


Jump_04_669D::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$c8b5]
	ld [$c8b6], a
	ld a, c
	call Call_1AE1
	jp Call_04_55F5


Jump_04_66BD::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c8f7], a
	ld a, b
	ld [$c8f8], a
	ld a, [$c968]
	ld c, a
	ld a, [$c969]
	ld b, a
	ld a, c
	ld [$c8fb], a
	ld a, b
	ld [$c8fc], a
	ldh a, [$ff92]
	ld c, a
	ldh a, [$ff93]
	ld b, a
	ld a, c
	ld [$c8fd], a
	ld a, b
	ld [$c8fe], a
	ldh a, [$ff95]
	ld c, a
	ldh a, [$ff96]
	ld b, a
	ld a, c
	ld [$c8ff], a
	ld a, b
	ld [$c900], a
	ldh a, [$ff8e]
	ld [$c901], a
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$c902], a
	jp Call_04_55F5


Jump_04_6723::
	ld a, [$c8fb]
	ld c, a
	ld a, [$c8fc]
	ld b, a
	ld a, c
	ld [$c96d], a
	ld a, b
	ld [$c96e], a
	ld a, [$c8fd]
	ld c, a
	ld a, [$c8fe]
	ld b, a
	ld a, c
	ld [$c96f], a
	ld a, b
	ld [$c970], a
	ld a, [$c8ff]
	ld c, a
	ld a, [$c900]
	ld b, a
	ld a, c
	ld [$c971], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c825], a
	ret


Jump_04_676F::
	ld a, [$c901]
	ldh [$ff8e], a
	call Call_04_454B
	ld a, [$c902]
	dec a
	swap a
	add a
	ld hl, $d7d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ldh a, [$ff8e]
	add $02
	and $03
	ld [hl], a
	ld a, [$c8f0]
	ld c, a
	ld a, [$c8f1]
	ld b, a
	ld a, c
	add $09
	ld c, a
	ld a, b
	adc $00
	ld b, a
	ld hl, $d8d7
	set 1, [hl]
	ld a, c
	ld [$d8d9], a
	ld a, b
	ld [$d8da], a
	ld hl, $c8eb
	set 0, [hl]
	ret


Jump_04_67B1::
	ld hl, $cab9
	ld a, [hli]
	ld [$ca8d], a
	ld a, [hli]
	ld [$ca8e], a
	ld a, [hli]
	ld [$ca8f], a
	ld a, [hli]
	ld [$ca90], a
	ld a, [hli]
	ld [$ca91], a
	ld a, [hli]
	ld [$ca92], a
	ld a, [hli]
	ld [$ca93], a
	ld a, [$ca8e]
	call Call_04_67F1
	ld a, [$ca8f]
	call Call_04_67F1
	ld a, [$ca90]
	call Call_04_67F1
	ld hl, far_Call_01_46F6
	rst $10
	ld hl, far_Call_01_4BC1
	rst $10
	ld hl, far_Call_01_484E
	rst $10
	jp Call_04_55F5


Call_04_67F1::
	cp $ff
	ret z

	ld hl, $cac1
	call Call_223B
	ld [hl], $02
	ret


Jump_04_67FD::
	ld a, [$ddb4]
	ld hl, $ddce
	and [hl]
	ld hl, $dde8
	and [hl]
	ld hl, $de02
	and [hl]
	cp $ff
	jp z, Call_04_55F5

	ld a, [$d8d5]
	sub $01
	ld [$d8d5], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


Jump_04_6822::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld c, $02

Jump_004_6838:
	or a
	jp z, Jump_004_58fa

	dec a
	swap a
	add a
	ld hl, $d7d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	jp Call_04_55F5


Jump_04_684D::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld c, $00
	jp Jump_004_6838


Jump_04_6866::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld c, $01
	jp Jump_004_6838


Jump_04_687F::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld c, $03
	jp Jump_004_6838


Jump_04_6898::
	ld a, [$c8b6]
	call Call_1AE1
	jp Call_04_55F5


Jump_04_68A1::
	ld a, [$c846]
	and $f0
	jp nz, Call_04_55F5

	ld a, [$d8d5]
	sub $01
	ld [$d8d5], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


Jump_04_68BA::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$d8db], a
	ld hl, $d8d8
	set 2, [hl]
	ret


Jump_04_68D7::
	ld a, [$c968]
	ld c, a
	ld a, [$c969]
	ld b, a
	ld a, c
	ld [$c8fb], a
	ld a, b
	ld [$c8fc], a
	ldh a, [$ff92]
	ld c, a
	ldh a, [$ff93]
	ld b, a
	ld a, c
	ld [$c8fd], a
	ld a, b
	ld [$c8fe], a
	ldh a, [$ff95]
	ld c, a
	ldh a, [$ff96]
	ld b, a
	ld a, c
	ld [$c8ff], a
	ld a, b
	ld [$c900], a
	ldh a, [$ff8e]
	ld [$c901], a
	jp Call_04_55F5


Jump_04_690B::
	ld a, [$c8fb]
	ld c, a
	ld a, [$c8fc]
	ld b, a
	ld a, c
	ld [$c96d], a
	ld a, b
	ld [$c96e], a
	ld a, [$c8fd]
	ld c, a
	ld a, [$c8fe]
	ld b, a
	ld a, c
	ld [$c96f], a
	ld a, b
	ld [$c970], a
	ld a, [$c8ff]
	ld c, a
	ld a, [$c900]
	ld b, a
	ld a, c
	ld [$c971], a
	ld a, b
	ld [$c972], a
	ld a, $01
	ld [$c96c], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c825], a
	ret


Jump_04_6957::
	ld a, [$c901]
	ldh [$ff8e], a
	call Call_04_454B
	ld hl, $d7f8
	ldh a, [$ff8e]
	add $02
	and $03
	ld [hl], a
	jp Call_04_55F5


Jump_04_696C::
	ld b, $00
	ld c, $00

jr_004_6970:
	push bc
	ld hl, $ca94
	ld a, b
	call Call_267E
	pop bc
	jr z, jr_004_697c

	inc c

jr_004_697c:
	inc b
	ld a, b
	cp $f0
	jr nz, jr_004_6970

	push bc
	ld a, c
	ld hl, $c180
	call Call_09A4
	pop bc
	ld hl, $699d
	ld a, c
	ld e, $ff

jr_004_6991:
	cp [hl]
	inc hl
	inc e
	jr nc, jr_004_6991

	ld a, e
	ld [$d8e1], a
	jp Call_04_55F5


	db $07, $10, $1a, $26, $32, $47, $64, $83, $a1, $c8, $d7, $ff

Jump_04_69A9::
	ld bc, $0000
	ld a, [$ca8e]
	call Call_04_6A4E
	ld a, [$ca8f]
	call Call_04_6A4E
	ld a, [$ca90]
	call Call_04_6A4E
	ld l, c
	ld h, b
	inc hl
	ld a, $14
	call Call_1E0D
	ld a, l
	cp $07
	jr c, jr_004_69cd

	ld a, $07

jr_004_69cd:
	ld hl, $6a3c
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	call Call_12D0
	pop hl
	push hl
	ld a, [$c899]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$da03], a
	ld a, h
	ld [$da04], a
	pop hl
	push hl
	call Call_12D0
	pop hl
	push hl
	ld a, [$c899]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	pop hl
	push hl
	call Call_12D0
	pop hl
	push hl
	ld a, [$c899]
	and $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	pop hl
	ld a, $02
	ld [$da02], a
	ld hl, $c8eb
	set 6, [hl]
	xor a
	ld [$c905], a
	ld a, $02
	ld [$da09], a
	ret


	db $60, $01, $70, $01, $80, $01, $90, $01, $a0, $01, $b0, $01, $c0, $01, $d0, $01
	db $d0, $01

Call_04_6A4E::
	cp $ff
	ret z

	push bc
	ld hl, $cb0c
	call Call_223B
	pop bc
	ld a, [hl]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ret


Jump_04_6A61::
	ldh a, [$ff95]
	and $f0
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, [$d7ec]
	and $f0
	ld e, a
	ld a, [$d7ed]
	ld d, a
	push hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, h
	or l
	pop hl
	jr z, jr_004_6a8d

	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, $00
	jr c, jr_004_6abc

	ld a, $02
	jr jr_004_6abc

jr_004_6a8d:
	ldh a, [$ff92]
	and $f0
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, [$d7ea]
	and $f0
	ld e, a
	ld a, [$d7eb]
	ld d, a
	push hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, h
	or l
	pop hl
	jr z, jr_004_6ab9

	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, $03
	jr c, jr_004_6abc

	ld a, $01
	jr jr_004_6abc

jr_004_6ab9:
	jp Call_04_55F5


jr_004_6abc:
	ldh [$ff8e], a
	call Call_04_454B
	ld hl, $d7d8
	ldh a, [$ff8e]
	add $02
	and $03
	ld [hl], a
	jp Call_04_55F5


Jump_04_6ACE::
	ld a, [$c899]
	ld b, a
	ld a, $25
	call Call_1DFB
	inc a
	ld c, a
	ld hl, $ca51
	ld b, $14

jr_004_6ade:
	ld a, [hl]
	or a
	jr z, jr_004_6aed

	cp $ff
	jr z, jr_004_6aed

	inc hl
	dec b
	jr nz, jr_004_6ade

	jp Call_04_55F5


jr_004_6aed:
	ld [hl], c
	ld l, c
	ld h, $08
	ld de, $c180
	call Call_097A
	jp Call_04_55F5


Jump_04_6AFA::
	ld hl, $ca51
	ld b, $14
	ld c, $00

jr_004_6b01:
	ld a, [hl]
	or a
	jr z, jr_004_6b0e

	cp $ff
	jr z, jr_004_6b0e

	inc hl
	inc c
	dec b
	jr nz, jr_004_6b01

jr_004_6b0e:
	ld a, c
	ld [$d8e1], a
	or a
	jp z, Call_04_55F5

	ld a, [$c899]
	ld b, a
	ld a, c
	call Call_1DFB
	ld hl, $ca51
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld [hl], $ff
	ld l, c
	ld h, $08
	ld de, $c180
	call Call_097A
	ld hl, far_Call_03_7160
	rst $10
	jp Call_04_55F5


Jump_04_6B3A::
	ld a, [$ca4b]
	ld l, a
	ld a, [$ca4c]
	ld h, a
	ld a, [$ca4d]
	ld e, a
	ld a, $0a
	call Call_1E1E
	ld a, h
	or l
	or e
	ld [$d8e1], a
	or a
	jp z, Call_04_55F5

	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld hl, $c180
	call Call_09C7
	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ldh a, [$ffd7]
	ld e, a
	call Call_2424
	jp Call_04_55F5


Jump_04_6B73::
	ld a, [$c899]
	ld b, a
	ld a, $05
	call Call_1DFB
	add $13
	ld c, a
	ld hl, $ca51
	ld b, $14

jr_004_6b84:
	ld a, [hl]
	or a
	jr z, jr_004_6b93

	cp $ff
	jr z, jr_004_6b93

	inc hl
	dec b
	jr nz, jr_004_6b84

	jp Call_04_55F5


jr_004_6b93:
	ld [hl], c
	ld l, c
	ld h, $08
	ld de, $c180
	call Call_097A
	jp Call_04_55F5


Jump_04_6BA0::
	ld a, [$c93a]
	dec a
	dec a
	ld b, a
	ld a, [$c939]
	cp b
	jr z, jr_004_6bb9

	add $13
	ld [$c939], a
	cp b
	jr c, jr_004_6bb9

	ld a, b
	dec a
	ld [$c939], a

jr_004_6bb9:
	ld a, $01
	ld [$c96c], a
	ld a, $00
	ld [$c96d], a
	ld a, $80
	ld [$c96e], a
	ld hl, $c8eb
	set 5, [hl]
	xor a
	ld [$c905], a
	xor a
	ld [$d8d7], a
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c825], a
	ret


Jump_04_6BDF::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld hl, $ca8e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$d8e1], a
	cp $ff
	jp z, Call_04_55F5

	ld [$cac0], a
	ld hl, $cb13
	call Call_223B
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $cb17
	call Call_04_6D40
	jr c, jr_004_6c47

	ld hl, $cb19
	call Call_04_6D40
	jr c, jr_004_6c47

	ld hl, $cb1b
	call Call_04_6D40
	jr c, jr_004_6c47

	ld hl, $cb1d
	call Call_04_6D35
	jr c, jr_004_6c47

	ld hl, $cb1f
	call Call_04_6D29
	jr c, jr_004_6c47

	ld hl, $0014
	ld a, [$cac0]
	call Call_23E9
	ld a, $00
	jp Jump_004_6d0a


jr_004_6c47:
	ld a, [$cac0]
	ld hl, $cb17
	call Call_223B
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $cb19
	call Call_04_6D40
	jr c, jr_004_6c81

	ld hl, $cb1b
	call Call_04_6D40
	jr c, jr_004_6c81

	ld hl, $cb1d
	call Call_04_6D35
	jr c, jr_004_6c81

	ld hl, $cb1f
	call Call_04_6D29
	jr c, jr_004_6c81

	ld hl, $0014
	ld a, [$cac0]
	call Call_2403
	ld a, $01
	jp Jump_004_6d0a


jr_004_6c81:
	ld a, [$cac0]
	ld hl, $cb19
	call Call_223B
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $cb1b
	call Call_04_6D40
	jr c, jr_004_6cb2

	ld hl, $cb1d
	call Call_04_6D35
	jr c, jr_004_6cb2

	ld hl, $cb1f
	call Call_04_6D29
	jr c, jr_004_6cb2

	ld hl, $0014
	ld a, [$cac0]
	call Call_2307
	ld a, $02
	jr jr_004_6d0a

jr_004_6cb2:
	ld a, [$cac0]
	ld hl, $cb1b
	call Call_223B
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $cb1d
	call Call_04_6D35
	jr c, jr_004_6cdb

	ld hl, $cb1f
	call Call_04_6D29
	jr c, jr_004_6cdb

	ld hl, $0014
	ld a, [$cac0]
	call Call_2321
	ld a, $03
	jr jr_004_6d0a

jr_004_6cdb:
	ld a, [$cac0]
	ld hl, $cb1d
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, hl
	ld e, l
	ld d, h
	ld hl, $cb1f
	call Call_04_6D29
	jr c, jr_004_6cff

	ld hl, $0014
	ld a, [$cac0]
	call Call_233B
	ld a, $04
	jr jr_004_6d0a

jr_004_6cff:
	ld hl, $0014
	ld a, [$cac0]
	call Call_2355
	ld a, $05

Jump_004_6d0a:
jr_004_6d0a:
	add $35
	ld l, a
	ld h, $02
	ld de, $c190
	call Call_097A
	ld a, [$cac0]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	jp Call_04_55F5


Call_04_6D29::
	call Call_04_6D4A
	add hl, hl
	add hl, hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ret


Call_04_6D35::
	call Call_04_6D4A
	add hl, hl
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ret


Call_04_6D40::
	call Call_04_6D4A
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ret


Call_04_6D4A::
	push de
	ld a, [$cac0]
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	ret


Jump_04_6D56::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, c
	ld [$da03], a
	ld a, b
	ld [$da04], a
	xor a
	ld [$da02], a
	ld hl, $c8eb
	set 6, [hl]
	xor a
	ld [$c905], a
	ld a, $03
	ld [$da09], a
	ret


Jump_04_6D84::
	ld hl, $c8eb
	set 6, [hl]
	xor a
	ld [$c905], a
	ld a, $03
	ld [$da09], a
	ret


Jump_04_6D93::
	ld a, [$d9cf]
	bit 7, a
	jr nz, jr_004_6d9e

	ld hl, $d9cf
	inc [hl]

jr_004_6d9e:
	call Call_04_6EB3
	ld a, [$da03]
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
	call Call_04_6EB3
	ld a, [$da03]
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
	call Call_04_6EB3
	ld hl, $d7ca
	call Call_04_6E41
	ld hl, $6f44
	ld a, [$d9cf]
	cp $09
	jr c, jr_004_6e1a

	ld hl, $6f54

jr_004_6e1a:
	push hl
	call Call_12D0
	ld a, [$c899]
	and $0f
	pop hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$d9d0], a
	xor a
	ld [$d9cd], a
	ld a, [$d9d0]
	ld l, a
	ld h, $08
	ld de, $c180
	call Call_097A
	jp Call_04_55F5


Call_04_6E41::
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
	ld a, [$da03]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [$da12], a
	ld a, h
	ld [$da13], a
	call Call_04_6EA9
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, [$da02]
	or a
	ret z

	push hl
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$da12], a
	ld a, h
	ld [$da13], a
	call Call_04_6EA9
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, [$da02]
	cp $01
	ret z

	push hl
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$da12], a
	ld a, h
	ld [$da13], a
	call Call_04_6EA9
	pop hl
	ld [hli], a
	ld a, $01
	ld [hli], a
	ret


Call_04_6EA9::
	ld hl, far_Call_14_4016
	rst $10
	ld a, [$da18]
	add $10
	ret


Call_04_6EB3::
	ld b, $00
	ld a, [$ca8e]
	call Call_04_6F05
	ld a, [$ca8f]
	call Call_04_6F05
	ld a, [$ca90]
	call Call_04_6F05
	ld a, b
	ld hl, $0209
	cp $04
	jr c, jr_004_6f13

	ld hl, $0d12
	cp $0a
	jr c, jr_004_6f13

	ld hl, $2112
	cp $10
	jr c, jr_004_6f13

	ld hl, $3912
	cp $16
	jr c, jr_004_6f13

	ld hl, $5112
	cp $1c
	jr c, jr_004_6f13

	ld hl, $6912
	cp $22
	jr c, jr_004_6f13

	ld hl, $8112
	cp $28
	jr c, jr_004_6f13

	ld hl, $9d12
	cp $2e
	jr c, jr_004_6f13

	ld hl, $b512
	jr jr_004_6f13

Call_04_6F05::
	cp $ff
	ret z

	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp b
	ret c

	ld b, a
	ret


jr_004_6f13:
	ld a, $02
	ld [$da02], a
	call Call_04_6F35
	ld [$da03], a
	call Call_04_6F35
	ld [$da05], a
	call Call_04_6F35
	ld [$da07], a
	xor a
	ld [$da04], a
	ld [$da06], a
	ld [$da08], a
	ret


Call_04_6F35::
	push hl
	call Call_12D0
	ld a, [$c899]
	ld b, a
	ld a, l
	call Call_1DFB
	pop hl
	add h
	ret


	db $03, $04, $06, $0c, $15, $17, $18, $19, $1a, $1b, $1c, $25, $1a, $1b, $1c, $25
	db $0d, $0e, $0f, $10, $11, $12, $1e, $1f, $20, $21, $22, $23, $20, $21, $22, $23

Jump_04_6F64::
	ld a, [$d9d0]
	ld l, a
	ld h, $08
	ld de, $c180
	call Call_097A
	ld hl, $ca51
	ld b, $14

jr_004_6f75:
	ld a, [hl]
	or a
	jr z, jr_004_6f82

	cp $ff
	jr z, jr_004_6f82

	inc hl
	dec b
	jr nz, jr_004_6f75

	ret


jr_004_6f82:
	ld a, [$d9d0]
	ld [hl], a
	jp Call_04_55F5


Jump_04_6F89::
	ld a, $07
	ld [$d951], a
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	jp Call_04_55F5


Jump_04_6F9B::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	call Call_04_71EF
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, c
	ld a, [$ca8d]
	cp c
	jp z, Call_04_55F5

	jp c, Call_04_55F5

	ld a, c
	ld hl, $cb0d
	push bc
	call Call_2229
	ld a, [hl]
	push hl
	ld hl, $c190
	call Call_09A4
	pop hl
	pop bc
	push hl
	ld a, c
	ld [$d8e1], a
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	pop hl
	ld a, [hld]
	dec a
	cp [hl]
	jp nc, Call_04_55F5

	call Call_04_71EF
	jp Jump_004_7212


Jump_04_6FFB::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [$ca40]
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
	jr nc, jr_004_7030

	call Call_04_71EF
	jp Jump_004_7212


jr_004_7030:
	ld e, $00
	call Call_2424
	jp Call_04_55F5


Jump_04_7038::
	ld a, [$d8d3]
	cp $06
	jr nc, jr_004_7044

	ld hl, far_Call_0C_4110
	rst $10
	ret


jr_004_7044:
	cp $20
	jr nc, jr_004_704d

	ld hl, far_Call_0D_4110
	rst $10
	ret


jr_004_704d:
	cp $40
	jr nc, jr_004_7056

	ld hl, far_Call_0E_4110
	rst $10
	ret


jr_004_7056:
	ld hl, far_Call_0F_4110
	rst $10
	ret


Jump_04_705B::
	ld hl, $8da0
	ld b, $10
	ld a, $ff

jr_004_7062:
	call Call_1AB9
	dec b
	jr nz, jr_004_7062

	ld hl, $9800
	ld b, $00
	ld a, $da

jr_004_706f:
	call Call_1AB9
	call Call_1AB9
	call Call_1AB9
	call Call_1AB9
	dec b
	jr nz, jr_004_706f

	ret


Jump_04_707F::
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
	ld de, $c300
	ld c, $10

jr_004_70a1:
	ld b, $14
	push hl

jr_004_70a4:
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
	jr nz, jr_004_70a4

	pop hl
	ld a, e
	add $0c
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
	jr nz, jr_004_70a1

	ld hl, far_Call_01_484E
	rst $10
	ret


Jump_04_70D5::
	ld a, [$d8d5]
	add $01
	ld [$d8d5], a
	ld a, [$d8d6]
	adc $00
	ld [$d8d6], a
	ld a, [$ca8d]
	or a
	jp z, Jump_004_71c9

	ld a, $00
	ld hl, $cb0b
	call Call_224A
	or a
	jp nz, Jump_004_71cf

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
	jp nz, Jump_004_71cf

	ld a, $00
	ld hl, $cb17
	call Call_224F
	push bc
	ld a, $00
	ld hl, $cb15
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
	jp nz, Jump_004_71cf

	ld a, [$ca8d]
	cp $01
	jp z, Jump_004_71c9

	ld a, $01
	ld hl, $cb0b
	call Call_224A
	or a
	jp nz, Jump_004_71cf

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
	jr nz, jr_004_71cf

	ld a, $01
	ld hl, $cb17
	call Call_224F
	push bc
	ld a, $01
	ld hl, $cb15
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
	jr nz, jr_004_71cf

	ld a, [$ca8d]
	cp $02
	jr z, jr_004_71c9

	ld a, $02
	ld hl, $cb0b
	call Call_224A
	or a
	jp nz, Jump_004_71cf

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
	jr nz, jr_004_71cf

	ld a, $02
	ld hl, $cb17
	call Call_224F
	push bc
	ld a, $02
	ld hl, $cb15
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
	jr nz, jr_004_71cf

Jump_004_71c9:
jr_004_71c9:
	call Call_04_71EF
	jp Jump_004_7212


Jump_004_71cf:
jr_004_71cf:
	jp Call_04_55F5


Jump_04_71D2::
	ld a, [$dd80]
	ld hl, $dd9a
	and [hl]
	cp $ff
	jp z, Call_04_55F5

	ld a, [$d8d5]
	sub $01
	ld [$d8d5], a
	ld a, [$d8d6]
	sbc $00
	ld [$d8d6], a
	ret


Call_04_71EF::
	ld a, [$d8d3]
	cp $06
	jr nc, jr_004_71fb

	ld hl, far_Call_0C_4007
	rst $10
	ret


jr_004_71fb:
	cp $20
	jr nc, jr_004_7204

	ld hl, far_Call_0D_4007
	rst $10
	ret


jr_004_7204:
	cp $40
	jr nc, jr_004_720d

	ld hl, far_Call_0E_4007
	rst $10
	ret


jr_004_720d:
	ld hl, far_Call_0F_4007
	rst $10
	ret


Jump_004_7212:
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, b
	push af
	srl b
	rr c
	pop af
	and $80
	or b
	ld b, a
	ld a, [$d8d5]
	ld l, a
	ld a, [$d8d6]
	ld h, a
	add hl, bc
	ld a, l
	ld [$d8d5], a
	ld a, h
	ld [$d8d6], a
	jp Jump_004_5605


	db $61, $72, $72, $72, $83, $72, $94, $72, $a5, $72, $b6, $72, $c7, $72, $c7, $72
	db $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72, $c7, $72
	db $c7, $72, $b4, $73, $99, $74, $82, $75, $6b, $76, $f0, $f8, $00, $00, $f0, $00
	db $00, $20, $f8, $f8, $01, $00, $f8, $00, $02, $00, $80, $f0, $f8, $03, $00, $f8
	db $f8, $04, $00, $f8, $00, $05, $00, $f0, $00, $03, $20, $80, $f0, $f8, $06, $00
	db $f0, $00, $07, $00, $f8, $f8, $08, $00, $f8, $00, $09, $00, $80, $f0, $00, $0a
	db $00, $f8, $f8, $0b, $00, $f8, $00, $0c, $00, $f0, $f8, $13, $00, $80, $f0, $f8
	db $0d, $00, $f0, $00, $0d, $20, $f8, $f8, $0e, $00, $f8, $00, $0f, $00, $80, $f0
	db $f8, $10, $00, $f0, $00, $10, $20, $f8, $f8, $11, $00, $f8, $00, $12, $00, $80
	db $c8, $e0, $00, $10, $c8, $e8, $01, $10, $c8, $f0, $02, $10, $c8, $f8, $03, $10
	db $c8, $00, $04, $10, $c8, $08, $05, $10, $c8, $10, $06, $10, $c8, $18, $07, $10
	db $d0, $e0, $10, $10, $d0, $e8, $11, $10, $d0, $f0, $12, $10, $d0, $f8, $13, $10
	db $d0, $00, $14, $10, $d0, $08, $15, $10, $d0, $10, $16, $10, $d0, $18, $17, $10
	db $d8, $e0, $20, $00, $d8, $e8, $21, $00, $d8, $f0, $22, $00, $d8, $f8, $23, $00
	db $d8, $00, $24, $00, $d8, $08, $25, $00, $d8, $10, $26, $00, $e0, $e0, $30, $10
	db $e0, $e8, $31, $10, $e0, $f0, $32, $10, $e0, $f8, $33, $10, $e0, $00, $34, $10
	db $e0, $08, $35, $10, $e0, $10, $36, $10, $e8, $e0, $40, $10, $e8, $e8, $41, $10
	db $e8, $f0, $42, $10, $e8, $f8, $43, $10, $e8, $00, $44, $10, $e8, $08, $45, $10
	db $e8, $10, $46, $10, $f0, $e0, $50, $10, $f0, $e8, $51, $10, $f0, $f0, $52, $10
	db $f0, $f8, $53, $10, $f0, $00, $54, $10, $f0, $08, $55, $10, $f0, $10, $56, $10
	db $f8, $e0, $60, $00, $f8, $e8, $61, $00, $f8, $f0, $62, $00, $f8, $f8, $63, $00
	db $f8, $00, $64, $00, $f8, $08, $65, $00, $f8, $10, $66, $00, $00, $e0, $70, $10
	db $00, $e8, $71, $00, $00, $f0, $72, $00, $00, $f8, $73, $00, $00, $00, $74, $00
	db $00, $08, $75, $00, $00, $10, $76, $00, $00, $18, $77, $00, $80, $c8, $e0, $00
	db $10, $c8, $18, $07, $10, $d0, $e0, $10, $10, $d0, $18, $17, $10, $d8, $e0, $20
	db $00, $e0, $e0, $30, $10, $e8, $e0, $40, $10, $f0, $e0, $50, $10, $f8, $e0, $60
	db $00, $c8, $e8, $07, $10, $c8, $f0, $08, $10, $c8, $f8, $09, $10, $c8, $00, $0a
	db $10, $c8, $08, $0b, $10, $c8, $10, $0c, $10, $d0, $e8, $17, $10, $d0, $f0, $18
	db $10, $d0, $f8, $19, $10, $d0, $00, $1a, $10, $d0, $08, $1b, $10, $d0, $10, $1c
	db $10, $d8, $e8, $27, $00, $d8, $f0, $28, $00, $d8, $f8, $29, $00, $d8, $00, $2a
	db $00, $d8, $08, $2b, $00, $d8, $10, $2c, $00, $e0, $e8, $37, $10, $e0, $f0, $38
	db $10, $e0, $f8, $39, $10, $e0, $00, $3a, $10, $e0, $08, $3b, $10, $e0, $10, $3c
	db $10, $e8, $e8, $47, $10, $e8, $f0, $48, $10, $e8, $f8, $49, $10, $e8, $00, $4a
	db $10, $e8, $08, $4b, $10, $e8, $10, $4c, $10, $f0, $e8, $57, $10, $f0, $f0, $58
	db $10, $f0, $f8, $59, $10, $f0, $00, $5a, $10, $f0, $08, $5b, $10, $f0, $10, $5c
	db $10, $f8, $e8, $67, $00, $f8, $f0, $68, $00, $f8, $f8, $69, $00, $f8, $00, $6a
	db $00, $f8, $08, $6b, $00, $f8, $10, $6c, $00, $00, $e8, $77, $00, $00, $f0, $78
	db $00, $00, $f8, $79, $00, $00, $00, $7a, $00, $00, $08, $7b, $00, $00, $10, $7c
	db $00, $80, $c8, $e0, $00, $10, $c8, $18, $07, $10, $d0, $e0, $10, $10, $d0, $18
	db $17, $10, $d8, $e0, $20, $00, $e0, $e0, $30, $10, $e8, $e0, $40, $10, $f0, $e0
	db $50, $10, $f8, $e0, $60, $00, $d0, $e8, $91, $10, $d0, $f0, $92, $10, $d0, $f8
	db $93, $10, $d0, $00, $94, $10, $d0, $08, $95, $10, $d0, $10, $96, $10, $d8, $e8
	db $a1, $00, $d8, $f0, $a2, $00, $d8, $f8, $a3, $00, $d8, $00, $a4, $00, $d8, $08
	db $a5, $00, $d8, $10, $a6, $00, $e0, $e8, $b1, $10, $e0, $f0, $b2, $10, $e0, $f8
	db $b3, $10, $e0, $00, $b4, $10, $e0, $08, $b5, $10, $e0, $10, $b6, $10, $e8, $e8
	db $c1, $10, $e8, $f0, $c2, $10, $e8, $f8, $c3, $10, $e8, $00, $c4, $10, $e8, $08
	db $c5, $10, $e8, $10, $c6, $10, $f0, $e8, $d1, $10, $f0, $f0, $d2, $10, $f0, $f8
	db $d3, $10, $f0, $00, $d4, $10, $f0, $08, $d5, $10, $f0, $10, $d6, $10, $f8, $e8
	db $e1, $00, $f8, $f0, $e2, $00, $f8, $f8, $e3, $00, $f8, $00, $e4, $00, $f8, $08
	db $e5, $00, $f8, $10, $e6, $00, $c8, $e8, $81, $10, $c8, $f0, $82, $10, $c8, $f8
	db $83, $10, $c8, $00, $84, $10, $c8, $08, $85, $10, $c8, $10, $86, $10, $00, $e0
	db $f0, $10, $00, $e8, $f1, $10, $00, $f0, $f2, $10, $00, $f8, $f3, $10, $00, $00
	db $f4, $10, $00, $08, $f5, $10, $00, $10, $f6, $10, $80, $c8, $e0, $00, $10, $c8
	db $18, $07, $10, $d0, $e0, $10, $10, $d0, $18, $17, $10, $d8, $e0, $20, $00, $e0
	db $e0, $30, $10, $e8, $e0, $40, $10, $f0, $e0, $50, $10, $f8, $e0, $60, $00, $c8
	db $e8, $87, $10, $c8, $f0, $88, $10, $c8, $f8, $89, $10, $c8, $00, $8a, $10, $c8
	db $08, $8b, $10, $c8, $10, $8c, $10, $d0, $e8, $97, $10, $d0, $f0, $98, $10, $d0
	db $f8, $99, $10, $d0, $00, $9a, $10, $d0, $08, $9b, $10, $d0, $10, $9c, $10, $d8
	db $e8, $a7, $00, $d8, $f0, $a8, $00, $d8, $f8, $a9, $00, $d8, $00, $aa, $00, $d8
	db $08, $ab, $00, $d8, $10, $ac, $00, $e0, $e8, $b7, $10, $e0, $f0, $b8, $10, $e0
	db $f8, $b9, $10, $e0, $00, $ba, $10, $e0, $08, $bb, $10, $e0, $10, $bc, $10, $e8
	db $e8, $c7, $10, $e8, $f0, $c8, $10, $e8, $f8, $c9, $10, $e8, $00, $ca, $10, $e8
	db $08, $cb, $10, $e8, $10, $cc, $10, $f0, $e8, $d7, $10, $f0, $f0, $d8, $10, $f0
	db $f8, $d9, $10, $f0, $00, $da, $10, $f0, $08, $db, $10, $f0, $10, $dc, $10, $f8
	db $e8, $e7, $00, $f8, $f0, $e8, $00, $f8, $f8, $e9, $00, $f8, $00, $ea, $00, $f8
	db $08, $eb, $00, $f8, $10, $ec, $00, $00, $e8, $f7, $10, $00, $f0, $f8, $10, $00
	db $f8, $f9, $10, $00, $00, $fa, $10, $00, $08, $fb, $10, $00, $10, $fc, $10, $00
	db $18, $fd, $10, $80, $c8, $e0, $00, $10, $c8, $18, $07, $10, $d0, $e0, $10, $10
	db $d0, $18, $17, $10, $d8, $e0, $20, $10, $e0, $e0, $30, $10, $e8, $e0, $40, $10
	db $f0, $e0, $50, $10, $f8, $e0, $60, $10, $c8, $e8, $87, $10, $c8, $f0, $88, $10
	db $c8, $f8, $89, $10, $c8, $00, $8a, $10, $c8, $08, $8b, $10, $c8, $10, $8c, $10
	db $d0, $e8, $97, $10, $d0, $f0, $98, $10, $d0, $f8, $99, $10, $d0, $00, $9a, $10
	db $d0, $08, $9b, $10, $d0, $10, $9c, $10, $d8, $e8, $a7, $10, $d8, $f0, $a8, $10
	db $d8, $f8, $a9, $10, $d8, $00, $aa, $10, $d8, $08, $ab, $10, $d8, $10, $ac, $10
	db $e0, $e8, $b7, $10, $e0, $f0, $b8, $10, $e0, $f8, $b9, $10, $e0, $00, $ba, $10
	db $e0, $08, $bb, $10, $e0, $10, $bc, $10, $e8, $e8, $c7, $10, $e8, $f0, $c8, $10
	db $e8, $f8, $c9, $10, $e8, $00, $ca, $10, $e8, $08, $cb, $10, $e8, $10, $cc, $10
	db $f0, $e8, $d7, $10, $f0, $f0, $d8, $10, $f0, $f8, $d9, $10, $f0, $00, $da, $10
	db $f0, $08, $db, $10, $f0, $10, $dc, $10, $f8, $e8, $e7, $10, $f8, $f0, $e8, $10
	db $f8, $f8, $e9, $10, $f8, $00, $ea, $10, $f8, $08, $eb, $10, $f8, $10, $ec, $10
	db $80, $44, $77, $55, $77, $66, $77, $77, $77, $88, $77, $99, $77, $f0, $f8, $00
	db $00, $f0, $00, $01, $00, $f8, $f8, $02, $00, $f8, $00, $03, $00, $80, $f0, $f8
	db $00, $00, $f0, $00, $01, $00, $f8, $f8, $02, $00, $f8, $00, $03, $00, $80, $f0
	db $f8, $04, $00, $f0, $00, $05, $00, $f8, $f8, $06, $00, $f8, $00, $07, $00, $80
	db $f0, $f8, $04, $00, $f0, $00, $05, $00, $f8, $f8, $06, $00, $f8, $00, $07, $00
	db $80, $f0, $f8, $08, $00, $f0, $00, $09, $00, $f8, $f8, $0a, $00, $f8, $00, $0b
	db $00, $80, $f0, $f8, $08, $00, $f0, $00, $09, $00, $f8, $f8, $0a, $00, $f8, $00
	db $0b, $00, $80, $5b, $7f, $8e, $24, $00, $d0, $c9, $03, $13, $1f, $34, $25, $22
	db $25, $3f, $ff, $5b, $7f, $8e, $54, $20, $d0, $c9, $00, $12, $10, $30, $20, $20
	db $25, $3f, $8f, $23, $07, $06, $04, $00, $d0, $c9, $35, $1b, $41, $1e, $ae, $14
	db $1b, $00, $fc, $a7, $1b, $37, $71, $f1, $b3, $df, $06, $0a, $e6, $f4, $b6, $9f
	db $fd, $4f, $7e, $00, $75, $f5, $eb, $fb, $f5, $f5, $8b, $77, $40, $3f, $2f, $20
	db $2f, $3f, $20, $7f, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $46, $51, $82
	db $00, $01, $46, $55, $99, $01, $5f, $f6, $de, $56, $7f, $d6, $5f, $f7, $ff, $f5
	db $f7, $fd, $f7, $fd, $ff, $f7, $e3, $b9, $eb, $a9, $fb, $e9, $a1, $eb, $7f, $83
	db $7f, $80, $80, $45, $9f, $83, $ff, $00, $00, $45, $ff, $83, $fe, $01, $01, $45
	db $f9, $45, $9f, $42, $80, $81, $7f, $45, $ff, $02, $81, $ff, $45, $f9, $42, $01
	db $81, $fe, $48, $9f, $48, $ff, $48, $f9, $83, $1f, $3f, $7f, $45, $ff, $83, $f8
	db $fc, $fe, $45, $ff, $48, $40, $48, $0a, $84, $43, $4c, $70, $c0, $04, $44, $0a
	db $84, $0b, $0c, $30, $c0, $04, $88, $03, $0c, $30, $c0, $03, $0c, $30, $c0, $04
	db $81, $3f, $47, $40, $81, $ff, $07, $81, $fc, $47, $02, $98, $00, $08, $08, $0c
	db $04, $06, $02, $03, $06, $0e, $02, $03, $03, $07, $02, $03, $0f, $02, $06, $04
	db $0c, $08, $18, $08, $18, $81, $3f, $47, $40, $81, $ff, $09, $83, $06, $08, $10
	db $43, $20, $84, $00, $08, $e4, $82, $44, $81, $48, $20, $48, $81, $05, $b5, $38
	db $24, $12, $00, $00, $03, $0f, $3c, $48, $90, $91, $00, $7f, $c4, $18, $20, $7c
	db $c4, $89, $00, $c0, $30, $0c, $3e, $c7, $81, $00, $11, $0a, $0c, $14, $24, $24
	db $22, $2f, $fe, $e4, $83, $04, $1c, $29, $e8, $70, $09, $10, $e3, $12, $0c, $c4
	db $a6, $82, $00, $80, $03, $42, $40, $be, $60, $13, $16, $1c, $14, $0f, $02, $3e
	db $57, $19, $2e, $28, $63, $ac, $90, $26, $cc, $83, $81, $81, $01, $3d, $43, $1f
	db $20, $38, $38, $3c, $1f, $1e, $1c, $b8, $f0, $54, $36, $4c, $46, $3a, $27, $1c
	db $00, $12, $22, $41, $81, $80, $00, $01, $02, $20, $18, $20, $20, $98, $90, $8f
	db $44, $40, $00, $03, $47, $7c, $41, $e0, $82, $c0, $e0, $06, $99, $03, $04, $04
	db $08, $09, $09, $05, $72, $8e, $80, $22, $ff, $c1, $c1, $80, $80, $c1, $c1, $30
	db $18, $98, $98, $b0, $a7, $78, $04, $85, $0f, $38, $48, $90, $93, $03, $85, $fe
	db $01, $3e, $e4, $88, $04, $8f, $c0, $30, $08, $06, $08, $10, $e1, $12, $0e, $c4
	db $a6, $82, $33, $4d, $c1, $05, $ba, $13, $16, $1c, $14, $0f, $02, $1e, $2b, $83
	db $83, $87, $0c, $3c, $58, $38, $70, $00, $80, $00, $01, $07, $1f, $0f, $0c, $7e
	db $81, $80, $60, $80, $e1, $43, $3e, $3f, $f0, $80, $00, $00, $80, $e0, $3f, $f8
	db $7c, $0c, $04, $00, $01, $3f, $fe, $18, $18, $30, $60, $e0, $c0, $c0, $e0, $01
	db $02, $43, $04, $8b, $3c, $26, $12, $f0, $1c, $2f, $47, $20, $20, $40, $41, $03
	db $92, $07, $19, $2b, $6a, $aa, $11, $0a, $0c, $34, $e4, $24, $22, $6f, $ad, $b7
	db $bf, $7e, $38, $03, $8e, $f3, $f6, $fc, $14, $0f, $02, $02, $03, $04, $06, $04
	db $02, $02, $01, $06, $b0, $18, $14, $12, $12, $00, $7f, $c4, $18, $38, $48, $88
	db $09, $11, $0a, $0c, $17, $2a, $28, $28, $2f, $fe, $e4, $83, $74, $a8, $89, $88
	db $70, $11, $0a, $0c, $17, $28, $2a, $28, $2f, $fe, $e4, $83, $74, $88, $a9, $88
	db $70, $17, $0a, $08, $18, $43, $28, $b7, $2f, $76, $ac, $8b, $8c, $88, $89, $88
	db $70, $13, $16, $1c, $14, $0f, $00, $79, $ae, $19, $2e, $2a, $4b, $cd, $61, $fa
	db $06, $a4, $64, $94, $8f, $7a, $47, $3c, $00, $05, $7d, $db, $4b, $94, $f4, $89
	db $72, $3f, $40, $5f, $5f, $50, $40, $5f, $3f, $ff, $00, $ff, $ff, $00, $00, $43
	db $ff, $46, $80, $42, $ff, $46, $0b, $99, $ff, $a8, $89, $a1, $a9, $a0, $a9, $a8
	db $88, $02, $0a, $08, $02, $0a, $02, $02, $0a, $5f, $4f, $1f, $5f, $4f, $5f, $5f
	db $1f, $ff, $85, $3f, $7f, $ff, $7f, $7f, $45, $ff, $ab, $fe, $ff, $fa, $fc, $e8
	db $f0, $c2, $e1, $e1, $c0, $80, $c0, $c0, $80, $8a, $84, $16, $8f, $a6, $17, $00
	db $21, $ff, $ff, $cf, $9f, $87, $0f, $0f, $07, $0f, $07, $43, $87, $11, $62, $88
	db $11, $e8, $f0, $fa, $fc, $fe, $43, $ff, $91, $f3, $ff, $fa, $f9, $58, $3c, $86
	db $0c, $c0, $e0, $80, $c0, $00, $80, $80, $00, $03, $07, $be, $40, $20, $00, $40
	db $00, $40, $80, $40, $00, $f8, $08, $06, $02, $01, $01, $00, $04, $88, $40, $84
	db $35, $72, $20, $7c, $00, $62, $00, $42, $54, $82, $60, $9c, $40, $82, $10, $60
	db $04, $18, $02, $04, $11, $62, $42, $81, $00, $c1, $00, $21, $00, $00, $02, $01
	db $08, $07, $05, $19, $23, $01, $03, $03, $07, $03, $41, $03, $be, $07, $42, $3c
	db $28, $f0, $f4, $f8, $e8, $f4, $c2, $e4, $85, $c2, $c8, $e7, $e3, $ff, $90, $60
	db $61, $00, $04, $03, $08, $04, $12, $0c, $c9, $3e, $34, $fb, $f8, $f0, $40, $21
	db $20, $c1, $82, $01, $41, $82, $04, $42, $4a, $84, $94, $08, $48, $30, $07, $07
	db $0f, $07, $07, $0f, $1f, $0f, $18, $0f, $10, $09, $02, $41, $10, $82, $20, $10
	db $48, $ff, $9b, $bf, $cf, $8f, $07, $03, $07, $07, $03, $f1, $e0, $e4, $e3, $ca
	db $e4, $e4, $c8, $88, $d0, $80, $d0, $88, $d0, $c4, $e8, $20, $c0, $80, $0d, $ff
	db $60, $01, $fd, $00, $ee, $30, $03, $07, $0f, $0c, $1b, $16, $ff, $36, $2d, $5d
	db $63, $7f, $c0, $ff, $81, $ff, $ff, $80, $fd, $83, $ef, $9f, $f1, $fb, $fd, $01
	db $08, $00, $00, $01, $1f, $1f, $1f, $11, $ff, $cd, $eb, $ad, $7f, $d3, $3b, $e8
	db $98, $ff, $e8, $18, $e8, $18, $c8, $38, $d0, $b8, $ff, $20, $f1, $c1, $e1, $f9
	db $7f, $e7, $bf, $fd, $a1, $fc, $30, $f9, $27, $fa, $17, $a4, $7e, $ff, $f8, $fc
	db $3f, $6f, $3c, $37, $34, $2f, $ff, $18, $3f, $10, $1f, $10, $1f, $15, $1f, $ff
	db $0d, $0f, $7d, $ff, $a7, $fb, $82, $ff, $fb, $fe, $fe, $ee, $31, $18, $3c, $38
	db $3c, $20, $ff, $f0, $fe, $ff, $36, $ff, $10, $f0, $10, $ff, $f0, $5e, $ff, $75
	db $ff, $61, $ff, $c3, $9f, $bf, $8c, $fe, $70, $f8, $ee, $31, $f0, $33, $1f, $f7
	db $10, $37, $2e, $fa, $3f, $00, $01, $00, $00, $ff, $3e, $3e, $fe, $e2, $ba, $76
	db $da, $3e, $fb, $ee, $1e, $18, $01, $c8, $38, $d1, $b9, $21, $cf, $f3, $c3, $e3
	db $fa, $27, $0f, $39, $06, $75, $ff, $ff, $ad, $ff, $85, $ff, $63, $ff, $1c, $3d
	db $fe, $ee, $31, $30, $30, $30, $70, $60, $60, $4c, $df, $ee, $fc, $fe, $30, $f8
	db $5c, $01, $50, $f0, $ff, $70, $f0, $60, $e0, $fe, $ff, $c5, $bf, $ff, $81, $ff
	db $ff, $ff, $00, $00, $10, $78, $ff, $68, $98, $f8, $0c, $f7, $0f, $f0, $0f, $ff
	db $60, $9f, $62, $9d, $26, $d9, $56, $7b, $ff, $36, $7b, $0a, $1d, $1d, $13, $1b
	db $14, $bf, $0d, $1e, $0b, $0f, $0f, $1f, $3f, $00, $13, $ff, $17, $1a, $1b, $1e
	db $17, $1f, $14, $1c, $b3, $18, $1c, $6c, $03, $1e, $17, $e0, $f0, $5d, $00, $90
	db $3f, $dc, $bc, $a4, $fc, $f8, $fc, $1e, $1d, $ee, $31, $00, $02, $bd, $00, $ee
	db $38, $04, $03, $03, $04, $ee, $33, $80, $f7, $60, $40, $a0, $06, $01, $42, $bc
	db $02, $05, $ef, $03, $04, $04, $03, $ee, $37, $7d, $82, $46, $ff, $b9, $2b, $c4
	db $05, $02, $00, $01, $20, $ff, $18, $11, $28, $56, $29, $5c, $24, $8c, $ff, $74
	db $00, $88, $20, $84, $00, $a2, $40, $ff, $99, $28, $c4, $80, $3c, $30, $52, $30
	db $ff, $12, $28, $07, $04, $38, $ab, $44, $40, $ff, $83, $04, $00, $02, $01, $4e
	db $20, $04, $ff, $40, $04, $40, $8e, $4a, $0e, $ca, $a4, $9f, $40, $44, $3b, $0a
	db $24, $ee, $39, $69, $0f, $00, $ff, $00, $50, $20, $20, $10, $20, $10, $28, $ff
	db $10, $21, $1e, $10, $61, $40, $80, $08, $df, $00, $01, $88, $02, $08, $90, $05
	db $01, $08, $5f, $09, $04, $83, $00, $44, $9f, $00, $28, $a3, $01, $ff, $6c, $28
	db $6c, $39, $00, $88, $04, $48, $fe, $af, $04, $50, $0c, $94, $08, $20, $18, $00
	db $bf, $00, $81, $00, $00, $ff, $80, $ee, $30, $03, $fd, $00, $fd, $31, $88, $64
	db $40, $94, $80, $34, $ff, $10, $64, $48, $24, $84, $08, $58, $04, $ff, $08, $04
	db $86, $70, $00, $70, $04, $22, $ff, $00, $1c, $00, $00, $42, $81, $00, $fe, $ff
	db $00, $ff, $04, $03, $0b, $04, $07, $08, $ff, $17, $08, $0c, $13, $2f, $10, $1f
	db $20, $ff, $1f, $20, $90, $60, $e0, $10, $90, $60, $ff, $e8, $10, $f4, $08, $78
	db $84, $7a, $84, $6f, $7c, $82, $5f, $20, $30, $0b, $bc, $42, $40, $0b, $ff, $5f
	db $20, $3f, $40, $3f, $40, $bf, $40, $fe, $56, $05, $d0, $20, $e0, $10, $e0, $10
	db $e8, $56, $85, $0f, $08, $03, $99, $0c, $ab, $a9, $0c, $d0, $b9, $02, $fe, $0e
	db $1b, $90, $24, $02, $34, $61, $1a, $62, $ff, $19, $18, $25, $41, $24, $a4, $42
	db $24, $ff, $c2, $90, $27, $09, $06, $04, $18, $10, $fb, $f8, $f0, $a3, $10, $74
	db $f8, $f8, $7c, $78, $ff, $3c, $84, $59, $01, $23, $03, $1f, $17, $ff, $c7, $4f
	db $2f, $06, $2f, $26, $16, $20, $ff, $16, $31, $c0, $c2, $81, $88, $86, $80, $ff
	db $38, $20, $40, $10, $60, $68, $90, $74, $ff, $88, $80, $79, $71, $8e, $fe, $01
	db $7c, $ff, $83, $9c, $63, $24, $1b, $10, $0f, $5a, $fd, $a4, $de, $01, $00, $20
	db $08, $10, $10, $18, $3f, $5a, $99, $18, $da, $18, $db, $80, $00, $ff, $3f, $7f
	db $5f, $e0, $bf, $c0, $e6, $99, $7f, $bb, $ff, $ee, $ff, $44, $ee, $00, $fc, $31
	db $ff, $01, $00, $01, $01, $03, $03, $06, $07, $ff, $05, $06, $07, $00, $00, $ff
	db $ff, $ff, $ef, $00, $ff, $00, $66, $f5, $32, $c4, $ff, $9c, $ff, $e3, $9e, $f9
	db $b6, $cd, $9e, $e7, $5e, $ff, $e7, $ee, $f1, $b6, $f9, $1c, $3f, $07, $ff, $0f
	db $38, $7c, $54, $ee, $ba, $c6, $ba, $ff, $c6, $92, $ee, $c6, $fe, $7c, $fe, $38
	db $f9, $7c, $fc, $32, $3e, $08, $42, $3c, $bd, $42, $5b, $ff, $bd, $77, $ad, $6d
	db $b7, $37, $cf, $df, $07, $7e, $7e, $3c, $3e, $0d, $00, $9a, $05, $83, $2c, $2d
	db $2e, $11, $8b, $32, $33, $00, $32, $33, $00, $00, $20, $21, $21, $22, $05, $88
	db $2c, $2d, $2e, $00, $00, $28, $29, $2a, $05, $8e, $2c, $2d, $2e, $30, $31, $00
	db $30, $31, $00, $00, $25, $26, $00, $27, $08, $8a, $20, $21, $25, $26, $27, $00
	db $00, $20, $21, $22, $03, $be, $32, $33, $00, $32, $33, $00, $00, $25, $00, $28
	db $29, $2a, $6d, $6e, $6f, $70, $6d, $6e, $6f, $25, $26, $25, $28, $29, $2a, $6e
	db $25, $26, $27, $6d, $6e, $6f, $30, $31, $6e, $30, $31, $6f, $70, $23, $00, $25
	db $26, $27, $71, $72, $73, $74, $71, $72, $73, $25, $26, $23, $23, $26, $27, $72
	db $23, $26, $27, $71, $41, $72, $8d, $73, $32, $33, $72, $32, $33, $73, $74, $25
	db $00, $25, $00, $27, $07, $8a, $23, $28, $29, $2a, $00, $27, $00, $25, $00, $24
	db $03, $8c, $30, $31, $00, $30, $31, $00, $00, $23, $00, $23, $00, $24, $07, $8a
	db $23, $25, $26, $00, $00, $24, $00, $23, $00, $27, $03, $85, $32, $33, $00, $32
	db $33, $04, $81, $23, $0a, $81, $23, $05, $81, $23, $05, $85, $34, $2f, $00, $34
	db $2f, $02, $ff, $00, $9a, $23, $83, $64, $65, $66, $03, $8a, $64, $65, $66, $00
	db $64, $65, $66, $00, $00, $62, $06, $8a, $64, $65, $66, $00, $5e, $5f, $00, $00
	db $64, $65, $43, $3d, $83, $66, $64, $65, $43, $3d, $81, $65, $43, $3d, $b0, $65
	db $66, $67, $00, $64, $65, $66, $64, $65, $3d, $3d, $68, $00, $60, $61, $00, $58
	db $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58
	db $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $58, $59, $7f
	db $e0, $9b, $60, $3d, $ff, $3e, $c7, $ea, $90, $c9, $cd, $92, $13, $3e, $03, $ea
	db $a6, $c9, $af, $ea, $8b, $c9, $ea, $8c, $c9, $ea, $88, $c9, $ea, $a1, $c9, $ea
	db $c7, $dd, $ea, $c8, $dd, $ea, $9a, $c9, $ea, $a4, $c9, $ea, $a7, $c9, $c3, $e6
	db $15, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $04
