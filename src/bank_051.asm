INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $051", ROMX[$4000], BANK[$51]

BankNumber_51::
	db $51

FarTable_51::
	dw Call_51_423E
	dw Call_51_43F4
	dw Call_51_4A96
	dw Call_51_4BE8
	dw Call_51_4CB3
	dw Call_51_4D16
	dw Call_51_4E5E
	dw Call_51_4FAA
	dw Call_51_50F6
	dw Call_51_524A
	dw Call_51_46AA
	dw Call_51_44A9
	dw Call_51_5578
	dw Call_51_5B31
	dw Call_51_5C33
	dw Call_51_537A
	dw Call_51_6959
	dw Call_51_5569
	dw Data_51_7B0F

Call_51_4027::
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld a, $fc
	call Call_1688
	ld de, $5b00
	ld hl, $9600
	call Call_14CF
	ld de, $5b01
	ld hl, $8800
	call Call_14CF
	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	call Call_51_4107
	call Call_51_40D1
	ld a, [$c86c]
	or a
	jr z, jr_051_4073

	ld a, $ff
	ld [$c8b7], a
	ld [$c8b8], a
	call Call_3331

jr_051_4073:
	ld b, $27
	ld a, [$c968]
	cp $5d
	jp nz, Jump_051_408b

	ld hl, $c8ea
	res 7, [hl]
	ld a, [$d999]
	cp $02
	jr nz, jr_051_408b

	ld b, $2b

Jump_051_408b:
jr_051_408b:
	ld a, b
	call Call_1AE1
	ld a, $07
	ldh [$ffb5], a
	ld a, $ff
	ldh [$ffb6], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffb7], a
	call Call_122F
	call Call_1417
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	xor a
	ld [$c892], a
	xor a
	ld [$dd62], a
	xor a
	ld [$c873], a
	xor a
	ld [$c86e], a
	ld hl, far_Call_17_4192
	rst $10
	ld hl, far_Call_51_6959
	rst $10
	ld a, $03
	ld [$c8a1], a
	call Call_125D
	ld a, $0b
	jp Jump_000_11cb


Call_51_40D1::
	ld a, [$ca8d]
	or a
	ret z

	ld a, [$ca8e]
	ld d, a
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	ld [$da15], a
	ld a, [$ca8d]
	cp $01
	ret z

	ld a, [$ca8f]
	ld d, a
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	ld [$da16], a
	ld a, [$ca8d]
	cp $02
	ret z

	ld a, [$ca90]
	ld d, a
	ld hl, far_Call_01_4C58
	rst $10
	ld a, d
	ld [$da17], a
	ret


Call_51_4107::
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	call Call_51_419F
	ld a, $04
	ld [$db89], a
	ld de, $dc40
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_412b

	xor a
	ld [$db89], a
	ld de, $dc3c

jr_051_412b:
	ld hl, $9000
	ld a, [$db89]
	call Call_2FA5
	jr c, jr_051_413c

	ld a, [de]
	call Call_51_6A67
	jr jr_051_4140

jr_051_413c:
	ld hl, far_Call_58_5749
	rst $10

jr_051_4140:
	ld hl, $db89
	inc [hl]
	inc de
	ld hl, $9240
	ld a, [$db89]
	call Call_2FA5
	jr c, jr_051_4156

	ld a, [de]
	call Call_51_6A67
	jr jr_051_415a

jr_051_4156:
	ld hl, far_Call_58_5749
	rst $10

jr_051_415a:
	ld hl, $db89
	inc [hl]
	inc de
	ld hl, $9480
	ld a, [$db89]
	call Call_2FA5
	jr c, jr_051_4170

	ld a, [de]
	call Call_51_6A67
	jr jr_051_4174

jr_051_4170:
	ld hl, far_Call_58_5749
	rst $10

jr_051_4174:
	xor a
	ld hl, $d9f4
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$d9f8], a
	ld a, h
	ld [$d9f9], a
	call Call_51_742A
	call Call_51_7439
	call Call_51_7524
	call Call_51_7628
	call Call_51_768A
	call Call_51_79CB
	call Call_51_736A
	ret


Call_51_419F::
	ld d, $00
	ld a, [$c86c]
	or a
	jr z, jr_051_41b0

	ld a, [$c863]
	bit 1, a
	jr z, jr_051_41b0

	ld d, $04

jr_051_41b0:
	ld a, d
	ld [$db89], a
	call Call_51_7929
	inc d
	ld a, d
	ld [$db89], a
	call Call_51_7929
	inc d
	ld a, d
	ld [$db89], a
	call Call_51_7929
	ld hl, $9700
	ld b, $60

jr_051_41cc:
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	dec b
	jr nz, jr_051_41cc

	ld a, [$c86c]
	or a
	ld a, [$ca8d]
	ld [$dd72], a
	jr nz, jr_051_41e3

	or a
	ret z

jr_051_41e3:
	ld d, $00
	ld a, [$c86c]
	or a
	jr z, jr_051_41fc

	ld a, [$c863]
	bit 1, a
	jr z, jr_051_41fc

	ld a, [$db75]
	ld [$dd72], a
	ld d, $04
	jr jr_051_41fc

jr_051_41fc:
	push de
	ld hl, $cac2
	ld a, d
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $9700
	call Call_51_73DC
	pop de
	ld a, [$dd72]
	cp $01
	ret z

	inc d
	push de
	ld hl, $cac2
	ld a, d
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $9740
	call Call_51_73DC
	pop de
	ld a, [$dd72]
	cp $02
	ret z

	inc d
	push de
	ld hl, $cac2
	ld a, d
	call Call_2229
	ld e, l
	ld d, h
	ld hl, $9780
	call Call_51_73DC
	pop de
	ret


Call_51_423E::
	call Call_51_4245
	call Call_51_4027
	ret


Call_51_4245::
	call Call_51_43C9
	call Call_51_4452
	ld a, [$db74]
	or a
	jr nz, jr_051_4257

	ld a, $6d
	ld [$dc40], a
	ret


jr_051_4257:
	xor a
	ld [$da88], a
	ld a, $ff
	ld [$da82], a
	xor a
	ld hl, $db00
	ld bc, $0073
	call Call_12C7
	ld hl, $dd1b
	ld bc, $0008
	ld a, $ff
	call Call_12C7
	ld hl, $db8b
	ld bc, $00d9
	xor a
	call Call_12C7
	ld hl, $dc3c
	ld bc, $0008
	ld a, $ff
	call Call_12C7
	ld a, $ff
	ld hl, $dd03
	ld bc, $0008
	call Call_12C7
	ld a, [$db74]
	or a
	jr z, jr_051_42ae

	ld c, a
	ld b, $00
	xor a
	ld hl, $dd03
	push bc
	call Call_12C7
	pop bc
	ld hl, $c876
	xor a
	call Call_12C7

jr_051_42ae:
	ld hl, $d9fc
	ld bc, $0006
	xor a
	call Call_12C7
	ld a, [$d929]
	ld [$d9fd], a
	xor a
	ld hl, $dd0b
	ld bc, $0010
	call Call_12C7
	ld a, $ff
	ld hl, $dc64
	ld bc, $0080
	call Call_12C7
	ld a, $ff
	ld hl, $c1ca
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [$db74]
	ld b, a
	ld c, $00

jr_051_42e1:
	call Call_51_44B2
	inc c
	dec b
	jr nz, jr_051_42e1

	ld a, [$db75]
	ld b, a
	ld c, $04

jr_051_42ee:
	call Call_51_44B2
	inc c
	dec b
	jr nz, jr_051_42ee

	xor a
	ld [$db76], a
	ld [$dd61], a
	xor a
	ld [$d9ed], a
	ld a, $ff
	ld hl, $dce4
	ld bc, $0018
	call Call_12C7
	xor a
	ld hl, $dcfc
	ld bc, $0007
	call Call_12C7
	ld hl, $ffff
	ld a, l
	ld [$db77], a
	ld a, h
	ld [$db78], a
	xor a
	ld hl, $db4c
	ld bc, $0027
	call Call_12C7
	ld hl, $000a
	ld a, l
	ld [$db83], a
	ld a, h
	ld [$db84], a
	ld a, $ff
	ld [$db77], a
	ld [$db78], a
	ld a, [$db74]
	ld d, a
	ld e, $00
	ld a, [$c86c]
	or a
	jr nz, jr_051_4358

	ld hl, $dd1f
	ld b, $00
	ld a, [$db75]
	ld c, a
	or a
	ld a, $00
	call nz, Call_12C7

jr_051_4358:
	call Call_51_499F
	call Call_51_4A28
	ld de, $db8b
	ld bc, $0800

jr_051_4364:
	push bc
	ld a, c
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_051_4393

	ld a, c
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$da31], a
	push de
	ld hl, far_Call_03_443F
	rst $10
	pop de
	ld a, [$da38]
	ld h, a
	ld a, [$da37]
	swap a
	or h
	ld [de], a

jr_051_4393:
	pop bc
	inc de
	inc c
	dec b
	jr nz, jr_051_4364

	ld hl, $c8da
	ld bc, $0008
	xor a
	call Call_12C7
	ld hl, $c1c0
	ld bc, $000f
	ld a, $ff
	call Call_12C7
	ld a, $00
	ld [$c1c2], a
	ld hl, $c1cd
	ld bc, $0008
	ld a, $80
	call Call_12C7
	call Call_51_548C
	call Call_51_5507
	ld hl, $d9ed
	inc [hl]
	ret


Call_51_43C9::
	ld a, [$c86c]
	or a
	jr nz, jr_051_43dc

	ld a, [$da09]
	or a
	jr z, jr_051_43e0

	ld a, [$d8d3]
	cp $5d
	jr nz, jr_051_43e4

jr_051_43dc:
	ld a, $02
	jr jr_051_43e6

jr_051_43e0:
	ld a, $00
	jr jr_051_43e6

jr_051_43e4:
	ld a, $01

jr_051_43e6:
	ld [$db73], a
	ld a, [$c86c]
	or a
	ret z

	ld a, $06
	ld [$c8ee], a
	ret


Call_51_43F4::
	ld a, [$db4c]
	ld l, a
	ld a, [$db4d]
	ld h, a
	ld a, [$db4e]
	ld e, a
	ld a, [$db4f]
	ld d, a

Call_51_4404::
	push hl
	ld a, $1a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	rrc a
	rrc a
	ld c, a
	pop hl
	ld a, [hli]
	sla a
	sla a
	or [hl]
	inc hl
	sla a
	sla a
	or [hl]
	inc hl
	or c
	ld [de], a
	inc de
	ld b, $05

jr_051_4428:
	ld a, [hli]
	sla a
	sla a
	or [hl]
	inc hl
	sla a
	sla a
	or [hl]
	inc hl
	sla a
	sla a
	or [hl]
	inc hl
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_4428

	ld a, [hli]
	sla a
	sla a
	or [hl]
	inc hl
	sla a
	sla a
	or [hl]
	sla a
	sla a
	ld [de], a
	ret


Call_51_4452::
	ld a, [$c86c]
	or a
	jr z, jr_051_4498

	ld bc, $0300

jr_051_445b:
	ld a, c
	ld hl, $cac1
	call Call_224A
	or a
	jr z, jr_051_4469

	inc c
	dec b
	jr nz, jr_051_445b

jr_051_4469:
	ld a, c
	ld [$db74], a
	ld [$c1d9], a
	ld bc, $0304

jr_051_4473:
	ld a, c
	ld hl, $cac1
	call Call_224A
	or a
	jr z, jr_051_4481

	inc c
	dec b
	jr nz, jr_051_4473

jr_051_4481:
	ld a, c
	sub $04
	ld [$db75], a
	dec a
	ld [$da02], a
	ld a, [$c863]
	bit 1, a
	ret z

	ld a, [$db75]
	ld [$c1d9], a
	ret


jr_051_4498:
	ld a, [$ca8d]
	ld [$db74], a
	ld [$c1d9], a
	ld a, [$da02]
	inc a
	ld [$db75], a
	ret


Call_51_44A9::
	ld a, [$db4c]
	ld c, a
	ld a, $01
	ld [$db55], a

Call_51_44B2::
	ld a, [$c86c]
	or a
	jr nz, Call_51_44CB

	ld a, c
	cp $04
	jr nc, jr_051_44c4

	call Call_51_44CB
	call Call_51_548C
	ret


jr_051_44c4:
	call Call_51_4627
	call Call_51_548C
	ret


Call_51_44CB::
	ld a, c
	ld hl, $caca
	call Call_2229
	ld a, c
	ld de, $dc3c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call Call_51_4669
	ld a, [hli]
	ld [de], a
	inc hl
	ld a, c
	ld de, $db93
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hl]
	and $0f
	ld [de], a
	ld a, [hli]
	swap a
	and $0f
	push af
	ld a, c
	ld de, $dd03
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	push af
	and $03
	ld [de], a
	pop af
	push af
	push af
	ld a, c
	ld de, $c876
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	rrca
	rrca
	and $03
	ld [de], a
	ld a, c
	bit 2, a
	jr nz, jr_051_4536

	ld a, [$c863]
	bit 1, a
	jr nz, jr_051_4551

	ld a, c
	inc a
	inc a
	ld de, $d9fc
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	and $03
	ld [de], a
	jr jr_051_4552

jr_051_4536:
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_4551

	ld a, c
	and $03
	inc a
	inc a
	ld de, $d9fc
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	and $03
	ld [de], a
	jr jr_051_4552

jr_051_4551:
	pop af

jr_051_4552:
	ld a, $1d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	push bc
	ld a, [$db4c]
	or a
	jr nz, jr_051_4567

	call Call_51_46FF
	jr jr_051_456a

jr_051_4567:
	call Call_51_46AA

jr_051_456a:
	pop bc
	pop hl
	ld a, $21
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$db55]
	or a
	call z, Call_51_4769
	inc hl
	ld de, $db9b
	call Call_51_4692
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [$db55]
	or a
	jr z, jr_051_459e

	inc hl
	inc hl
	ld de, $dbb3
	call Call_51_469C
	inc hl
	inc hl
	ld de, $dbd3
	call Call_51_469C
	jr jr_051_45b6

jr_051_459e:
	ld de, $dba3
	call Call_51_469C
	ld de, $dbb3
	call Call_51_469C
	ld de, $dbc3
	call Call_51_469C
	ld de, $dbd3
	call Call_51_469C

jr_051_45b6:
	ld de, $dbe3
	call Call_51_469C
	ld de, $dbf3
	call Call_51_469C
	ld de, $dc03
	call Call_51_469C
	ld de, $dc13
	call Call_51_469C
	ld de, $dc23
	call Call_51_469C
	inc hl
	inc hl
	ld a, [$db55]
	or a
	jr z, jr_051_45f8

	ld a, [$db4c]
	push hl
	ld hl, $db03
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $30
	pop hl
	jr nz, jr_051_45f8

	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_051_4610

jr_051_45f8:
	ld de, $dc44
	call Call_51_4692
	ld de, $dc54
	call Call_51_4692
	ld de, $dc5c
	call Call_51_4692
	ld de, $dc4c
	call Call_51_4692

jr_051_4610:
	ld a, c
	add a
	add c
	add a
	add c
	ld de, $dd28
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	push bc
	call Call_51_4404
	pop bc
	call Call_51_47A5
	ret


Call_51_4627::
	push bc
	ld a, c
	sub $04
	ld c, a
	push bc
	ld hl, $da03
	ld a, c
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
	ld [$da12], a
	ld a, h
	ld [$da13], a
	ld hl, far_Call_14_4016
	rst $10
	pop bc
	call Call_51_47E0
	ld a, c
	add $04
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_51_4688
	ld a, [hl]
	ld [$da31], a
	push bc
	ld hl, far_Call_03_443F
	rst $10
	pop bc
	call Call_51_494C
	pop bc
	ret


Call_51_4669::
	ld a, [$c81d]
	or a
	ret z

	push de
	push hl
	ld h, [hl]
	ld a, $02
	ldh [rSVBK], a
	ld a, c
	ld de, $db00
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, h
	ld [de], a
	ld a, $00
	ldh [rSVBK], a
	pop hl
	pop de
	ret


Call_51_4688::
	push bc
	ld a, c
	add $04
	ld c, a
	call Call_51_4669
	pop bc
	ret


Call_51_4692::
	ld a, c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ret


Call_51_469C::
	ld a, c
	add a
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
	ret


Call_51_46AA::
	ld a, [$db4c]
	ld c, a
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, $08

jr_051_46bb:
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
	dec b
	jr nz, jr_051_46bb

	ld a, [$c86c]
	or a
	jr nz, jr_051_46cf

	ld a, c
	cp $04
	jr nc, jr_051_46dc

jr_051_46cf:
	ld a, c
	ld hl, $caea
	call Call_2229
	ld a, [$db4c]
	ld c, a
	jr Call_51_46FF

jr_051_46dc:
	ld a, c
	and $03
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
	ld [$da12], a
	ld a, h
	ld [$da13], a
	ld hl, far_Call_14_4016
	rst $10
	ld a, [$db4c]
	ld c, a
	ld hl, $da2d

Call_51_46FF::
	ld a, [$c86c]
	or a
	jr nz, jr_051_470e

	ld a, c
	cp $04
	jr c, jr_051_470e

	ld b, $04
	jr jr_051_4710

jr_051_470e:
	ld b, $08

jr_051_4710:
	ld de, $dc65
	ld a, c
	swap a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a

jr_051_471c:
	ld a, [hli]
	ld [de], a
	inc de
	inc de
	ld a, [hl]
	cp $ff
	jr z, jr_051_4728

	dec b
	jr nz, jr_051_471c

jr_051_4728:
	ld a, c
	ld de, $dc65
	swap a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld b, $08
	ld a, [$db4c]
	push af

jr_051_473a:
	ld a, [de]
	cp $ff
	jr z, jr_051_4761

	push bc
	ld a, [de]
	ld [$db4c], a
	xor a
	ld [$db4d], a
	ld a, $01
	ld [$db4e], a
	ld hl, Jump_51_5400
	rst $10
	ld a, [$db4c]
	swap a
	and $0f
	dec de
	ld [de], a
	inc de
	inc de
	inc de
	pop bc
	dec b
	jr nz, jr_051_473a

jr_051_4761:
	pop af
	ld [$db4c], a
	call Call_51_499F
	ret


Call_51_4769::
	push hl
	ld a, c
	ld de, $dd1b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	bit 7, [hl]
	jr z, jr_051_477d

	ld a, $01
	ld [de], a
	jr jr_051_47a3

jr_051_477d:
	ld a, $00
	ld [de], a
	ld a, [$db73]
	cp $02
	jr z, jr_051_47a3

	ld a, c
	ld de, $db02
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	bit 0, [hl]
	jr z, jr_051_479b

	ld a, $20
	ld [de], a

jr_051_479b:
	bit 2, [hl]
	jr z, jr_051_47a3

	ld a, [de]
	or $01
	ld [de], a

jr_051_47a3:
	pop hl
	ret


Call_51_47A5::
	push bc
	ld a, c
	ld hl, $dd0b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, c
	ld hl, $dc13
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld bc, $0014
	call Call_2F45
	jr c, jr_051_47d3

	ld bc, $00b3
	call Call_2F45
	jr c, jr_051_47d7

	ld a, $02
	jr jr_051_47d9

jr_051_47d3:
	ld a, $00
	jr jr_051_47d9

jr_051_47d7:
	ld a, $01

jr_051_47d9:
	pop hl
	ld [hl], a
	pop bc
	ret


	db $c5, $18, $12

Call_51_47E0::
	push bc
	ld hl, $db85
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da1b]
	ld [hl], a
	ld a, c
	add $04
	ld c, a
	add a
	ld b, a
	ld hl, $db9b
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da1c]
	ld [hl], a
	ld hl, $dba3
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da1d]
	ld [hli], a
	ld a, [$da1e]
	ld [hld], a
	ld a, b
	call Call_51_4A61
	ld hl, $dbb3
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da1d]
	ld [hli], a
	ld a, [$da1e]
	ld [hl], a
	ld hl, $dbc3
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da1f]
	ld [hli], a
	ld a, [$da20]
	ld [hl], a
	ld hl, $dbd3
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da1f]
	ld [hli], a
	ld a, [$da20]
	ld [hl], a
	ld hl, $dbe3
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da21]
	ld [hli], a
	ld a, [$da22]
	ld [hl], a
	ld hl, $dbf3
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da23]
	ld [hli], a
	ld a, [$da24]
	ld [hl], a
	ld hl, $dc03
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da25]
	ld [hli], a
	ld a, [$da26]
	ld [hl], a
	ld hl, $dc13
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da27]
	ld [hli], a
	ld a, [$da28]
	ld [hld], a
	ld a, [hl]
	push af
	ld hl, $dd0b
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	cp $15
	jr c, jr_051_48b0

	cp $b5
	jr c, jr_051_48b4

	ld a, $02
	jr jr_051_48b6

jr_051_48b0:
	ld a, $00
	jr jr_051_48b6

jr_051_48b4:
	ld a, $01

jr_051_48b6:
	ld [hl], a
	ld hl, $dc23
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	inc hl
	ld [hl], $00
	ld hl, $dc33
	push bc
	ld a, c
	sub $04
	ld c, a
	add a
	add c
	pop bc
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da19]
	ld [hli], a
	ld a, [$da1a]
	ld [hli], a
	ld [hl], $00
	ld hl, $dc3c
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da18]
	ld [hl], a
	ld hl, $dc44
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da29]
	ld [hl], a
	ld hl, $dc4c
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da2b]
	ld [hl], a
	ld hl, $dc54
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da2a]
	ld [hl], a
	ld hl, $dc5c
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da2c]
	ld [hl], a
	ld hl, $dc65
	ld a, b
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da2d]
	ld [hli], a
	inc hl
	ld a, [$da2e]
	ld [hli], a
	inc hl
	ld a, [$da2f]
	ld [hli], a
	inc hl
	ld a, [$da30]
	ld [hl], a
	pop bc
	ret


	db $c5, $18, $04

Call_51_494C::
	push bc
	ld a, c
	add $04
	ld c, a
	ld hl, $db93
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$da36]
	or a
	jr z, jr_051_4988

	cp $01
	jr z, jr_051_496c

	cp $02
	jr z, jr_051_4970

	ld b, $e6
	jr jr_051_4972

jr_051_496c:
	ld b, $19
	jr jr_051_4972

jr_051_4970:
	ld b, $80

jr_051_4972:
	push af
	push bc
	push de
	push hl
	call Call_12D0
	pop hl
	pop de
	pop bc
	pop af
	ld a, [$c899]
	cp b
	jr c, jr_051_4986

	xor a
	jr jr_051_4988

jr_051_4986:
	ld a, $01

jr_051_4988:
	ld [hl], a
	ld hl, $da42
	ld de, $dd28
	ld a, c
	add a
	add c
	add a
	add c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call Call_51_4404
	pop bc
	ret


Call_51_499F::
	ld bc, $0800
	ld hl, $db93

jr_051_49a5:
	ld a, c
	call Call_2FA5
	jr c, jr_051_49b4

	ld a, [hl]
	or a
	jr nz, jr_051_49b4

	push hl
	call Call_51_4A00
	pop hl

jr_051_49b4:
	inc c
	inc hl
	dec b
	jr nz, jr_051_49a5

	ld a, [$c86c]
	or a
	ret nz

	ld bc, $0304
	ld hl, $dca5

jr_051_49c4:
	ld a, c
	call Call_2FA5
	jr c, jr_051_49ef

	ld d, $04

jr_051_49cc:
	ld a, [hl]
	cp $ff
	jr z, jr_051_49ef

	cp $97
	jr nz, jr_051_49da

	call Call_51_4A1F
	jr jr_051_49ea

jr_051_49da:
	cp $19
	jr nz, jr_051_49e3

	call Call_51_4A22
	jr jr_051_49ea

jr_051_49e3:
	cp $2a
	jr nz, jr_051_49ea

	call Call_51_4A25

jr_051_49ea:
	inc hl
	inc hl
	dec d
	jr nz, jr_051_49cc

jr_051_49ef:
	inc c
	ld a, c
	swap a
	ld hl, $dc65
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	dec b
	jr nz, jr_051_49c4

	ret


Call_51_4A00::
	ld a, c
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld d, $08

jr_051_4a0e:
	ld a, [hl]
	cp $ff
	ret z

	cp $70
	jr nz, jr_051_4a19

	ld [hl], $dd
	ret


jr_051_4a19:
	inc hl
	inc hl
	dec d
	jr nz, jr_051_4a0e

	ret


Call_51_4A1F::
	ld [hl], $db
	ret


Call_51_4A22::
	ld [hl], $da
	ret


Call_51_4A25::
	ld [hl], $dc
	ret


Call_51_4A28::
	ld hl, $dc65
	ld bc, $0808

jr_051_4a2e:
	push bc
	ld a, [hl]
	cp $ff
	push hl
	jr z, jr_051_4a50

	ld a, [hl]
	ld [$db4c], a
	ld a, $00
	ld [$db4d], a
	ld a, $01
	ld [$db4e], a
	ld hl, Jump_51_5400
	rst $10
	ld a, [$db4c]
	swap a
	and $0f
	jr jr_051_4a52

jr_051_4a50:
	ld a, $00

jr_051_4a52:
	pop hl
	dec hl
	ld [hli], a
	inc hl
	inc hl
	pop bc
	dec c
	jr nz, jr_051_4a2e

	ld c, $08
	dec b
	jr nz, jr_051_4a2e

	ret


Call_51_4A61::
	ld a, [$db73]
	or a
	ret nz

	push bc
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, h
	ld c, l
	call Call_51_5363
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	push hl
	ld a, [$c899]
	ld l, a
	ld a, [$c89a]
	ld h, a

jr_051_4a7f:
	call Call_2F45
	jr c, jr_051_4a8c

	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr jr_051_4a7f

jr_051_4a8c:
	pop bc
	add hl, bc
	pop bc
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	pop bc
	ret


Call_51_4A96::
	ld a, [$d9fd]
	ld [$d929], a
	ld a, [$db74]
	ld b, a
	ld c, $00

jr_051_4aa2:
	call Call_51_4AC0
	ld a, c
	ld hl, $cb0b
	call Call_2229
	call Call_51_4AF0
	call Call_51_4B36
	call Call_51_4B50
	call Call_51_4B83
	call Call_51_4B96
	inc c
	dec b
	jr nz, jr_051_4aa2

	ret


Call_51_4AC0::
	ld a, c
	ld hl, $cacc
	call Call_2229
	ld a, c
	ld de, $dd03
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	push hl
	and $03
	ld l, a
	ld a, c
	ld de, $c876
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	rlca
	rlca
	and $0c
	or l
	pop hl
	swap a
	ld d, a
	ld a, [hl]
	and $0f
	or d
	ld [hl], a
	ret


Call_51_4AF0::
	ld a, $00
	ld [hl], a
	ld a, c
	ld de, $db02
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	and $03
	jr z, jr_051_4b07

	set 2, [hl]

jr_051_4b07:
	ld a, [de]
	bit 5, a
	jr z, jr_051_4b0e

	set 0, [hl]

jr_051_4b0e:
	ld a, c
	call Call_2FA5
	jr nc, jr_051_4b18

	set 7, [hl]
	jr jr_051_4b2f

jr_051_4b18:
	ld a, [$db55]
	or a
	jr nz, jr_051_4b2f

	ld a, c
	ld de, $dc5c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	cp $ff
	jr z, jr_051_4b2f

	inc a
	ld [de], a

jr_051_4b2f:
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ret


Call_51_4B36::
	push bc
	ld a, c
	ld de, $dba3
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld c, a
	inc de
	ld a, [de]
	ld [hli], a
	ld b, a
	call Call_51_4B70
	inc hl
	inc hl
	pop bc
	ret


Call_51_4B50::
	push bc
	ld a, c
	ld de, $dbc3
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld c, a
	inc de
	ld a, [de]
	ld [hli], a
	ld b, a
	call Call_51_4B70
	ld a, $0a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop bc
	ret


Call_51_4B70::
	push hl
	ld d, h
	ld e, l
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call Call_2F45
	jr nc, jr_051_4b81

	dec de
	ld a, h
	ld [de], a
	dec de
	ld a, l
	ld [de], a

jr_051_4b81:
	pop hl
	ret


Call_51_4B83::
	ld a, c
	ld de, $dc23
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
	inc hl
	inc hl
	ret


Call_51_4B96::
	ld a, c
	ld de, $dd1b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_051_4be7

	push hl
	ld a, c
	ld hl, $db03
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 4, [hl]
	pop hl
	jr nz, jr_051_4be7

	ld a, c
	ld de, $dc44
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld a, c
	ld de, $dc54
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld a, c
	ld de, $dc5c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld a, c
	ld de, $dc4c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a

jr_051_4be7:
	ret


Call_51_4BE8::
	ld a, $01
	ld [$d9f0], a
	ld a, [$db4c]
	ld [$dd72], a
	and $03
	cp $03
	jr z, jr_051_4c00

	call Call_51_44A9
	call Call_51_4C26
	ret


jr_051_4c00:
	ld a, [$db4c]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [$db4c]
	and $04
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
	call Call_51_4C26
	ret


Call_51_4C26::
	ld a, [$dd72]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hli], a
	ld [hl], a
	ld a, $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, $0f
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
	jr nc, jr_051_4c58

	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a

jr_051_4c58:
	ld a, [$dd72]
	ld hl, $db02
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hli], a
	call Call_51_4CA0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [$dd72]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	ret nz

	ld [hl], $01
	ld a, [$c86c]
	or a
	ret nz

	ld a, [$db4c]
	cp $04
	ret c

	and $03
	cp $03
	ret z

	ld hl, $c1ca
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ret


Call_51_4CA0::
	bit 4, [hl]
	jr nz, jr_051_4ca7

	bit 5, [hl]
	ret z

jr_051_4ca7:
	push hl
	ld hl, far_Call_51_6959
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	pop hl
	xor a
	ret


Call_51_4CB3::
	ld a, [$da02]
	ld b, a
	inc b
	ld c, $04
	ld d, $00
	ld a, [$db60]
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]

jr_051_4cc9:
	ld a, c
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp e
	jr nz, jr_051_4cdf

	ld a, [$db60]
	cp c
	jp z, Jump_051_4ce4

	inc d

jr_051_4cdf:
	inc c
	dec b
	jr nz, jr_051_4cc9

	ret


Jump_051_4ce4:
	ld a, d
	or a
	jr nz, jr_051_4cfc

	inc c

jr_051_4ce9:
	ld a, c
	ld hl, $dc3c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp e
	jr z, jr_051_4cfc

	inc c
	dec b
	jr nz, jr_051_4ce9

	ret


jr_051_4cfc:
	ld a, [$db5e]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, d
	add $0b
	push af

jr_051_4d08:
	ld a, [hl]
	cp $f0
	jr z, jr_051_4d10

	inc hl
	jr jr_051_4d08

jr_051_4d10:
	pop af
	ld [hli], a
	ld a, $f0
	ld [hl], a
	ret


Call_51_4D16::
	ld b, $00
	ld a, [$db88]
	and $04
	or $03
	ld [$db4c], a
	ld hl, $db8b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $1e
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbb3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbd3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbe3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $b4
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbf3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $96
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $50
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc13
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $96
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dd0b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [$db4c]
	ld hl, $dc23
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc44
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $03
	ld [hli], a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $5a
	ld [hli], a
	ld a, $03
	ld [hli], a
	ld a, $88
	ld [hli], a
	ld a, [$db4c]
	ld hl, $dd28
	ld c, a
	add a
	add c
	add a
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $16
	ld [hli], a
	ld a, $b5
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $54
	ld [hli], a
	ld a, $15
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $54
	ld [hli], a
	ret


Call_51_4E5E::
	ld b, $00
	ld a, [$db88]
	and $04
	or $03
	ld [$db4c], a
	ld hl, $db8b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $28
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbb3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbd3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbe3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $d2
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbf3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $a0
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $78
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc13
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dd0b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [$db4c]
	ld hl, $dc23
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc44
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $02
	ld [hli], a
	ld a, $25
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $5e
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $7a
	ld [hli], a
	ld a, [$db4c]
	ld hl, $dd28
	ld c, a
	add a
	add c
	add a
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a
	ld [hli], a
	ld a, $05
	ld [hli], a
	ld a, $64
	ld [hli], a
	ld a, $54
	ld [hli], a
	ld a, $31
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $84
	ld [hli], a
	ret


Call_51_4FAA::
	ld b, $00
	ld a, [$db88]
	and $04
	or $03
	ld [$db4c], a
	ld hl, $db8b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $32
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c2
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbb3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c2
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbd3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbe3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dbf3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $be
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $96
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc13
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dd0b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02
	ld a, [$db4c]
	ld hl, $dc23
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc44
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $01
	ld [hli], a
	ld a, $40
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $57
	ld [hli], a
	ld a, [$db4c]
	ld hl, $dd28
	ld c, a
	add a
	add c
	add a
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $19
	ld [hli], a
	ld a, $c6
	ld [hli], a
	ld a, $b5
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld a, $19
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $54
	ld [hli], a
	ret


Call_51_50F6::
	ld b, $00
	ld a, [$db88]
	and $04
	or $03
	ld [$db4c], a
	ld hl, $db8b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3c
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dba3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $bc
	ld [hli], a
	ld a, $02
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbb3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $bc
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbc3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbd3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbe3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $5e
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dbf3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dc03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc13
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dd0b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02
	ld a, [$db4c]
	ld hl, $dc23
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
	ld a, [$db4c]
	ld hl, $dc44
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fa
	ld [hl], a
	ld a, [$db4c]
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $01
	ld [hli], a
	ld a, $62
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $64
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, [$db4c]
	ld hl, $dd28
	ld c, a
	add a
	add c
	add a
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $1a
	ld [hli], a
	ld a, $6f
	ld [hli], a
	ld a, $fa
	ld [hli], a
	ld a, $a9
	ld [hli], a
	ld a, $1e
	ld [hli], a
	ld a, $aa
	ld [hli], a
	ld a, $a8
	ld [hli], a
	ret


Call_51_524A::
	ld a, [$db88]
	ld hl, $db9b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $32
	ld [hl], a
	ld a, [$db88]
	ld hl, $dbb3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $e7
	ld [hli], a
	ld a, $03
	ld [hl], a
	ld a, [$db88]
	ld hl, $dbd3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db88]
	ld hl, $dbe3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
	ld a, [$db88]
	ld hl, $dbf3
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld a, [$db88]
	ld hl, $dc03
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld a, [$db88]
	ld hl, $dc13
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld a, $00
	ld [hl], a
	call Call_51_5339
	ld a, [$db88]
	ld hl, $dc64
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $01
	ld [hli], a
	ld a, $5e
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $62
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld a, [$db88]
	ld h, a
	add a
	add h
	add a
	add h
	ld hl, $dd28
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $2a
	ld [hli], a
	ld a, $aa
	ld [hli], a
	ld a, $a9
	ld [hli], a
	ld a, $69
	ld [hli], a
	ld a, $4f
	ld [hli], a
	ld a, $aa
	ld [hli], a
	ld a, $5a
	ld [hl], a
	ld a, [$db88]
	call Call_51_5355
	ret


Call_51_5339::
	ld a, [$c81d]
	or a
	ret z

	ld a, $02
	ldh [rSVBK], a
	ld a, [$db88]
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $dc
	ld a, $00
	ldh [rSVBK], a
	ret


Call_51_5355::
	ld hl, $c1cd
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $80
	ld [hl], a
	ret


Call_51_5363::
	push bc
	srl h
	rr l
	ld b, h
	ld c, l
	srl b
	rr c
	add hl, bc
	srl b
	rr c
	srl b
	rr c
	add hl, bc
	pop bc
	ret


Call_51_537A::
	ld a, [$d9f1]
	rst $00

JumpTable_51_537E::
	dw Jump_51_5384
	dw Jump_51_5400
	dw Jump_51_540F

Jump_51_5384::
	ld hl, $d9f1
	inc [hl]
	ld a, [$db89]
	ld hl, $dd13
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [$db89]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [$db89]
	ld [$db4c], a
	ld a, [$db4c]
	ld [$dd72], a
	and $03
	cp $03
	jr z, jr_051_53d6

	call Call_51_44A9
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	jr nz, jr_051_53cd

	cp $04
	jr c, jr_051_53d1

	cp $07
	jr z, jr_051_53d1

	jr Jump_51_5400

jr_051_53cd:
	cp $03
	jr c, Jump_51_5400

jr_051_53d1:
	ld hl, $d9f1
	inc [hl]
	ret


jr_051_53d6:
	ld hl, $d9f1
	inc [hl]
	ld a, [$db4c]
	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [$db4c]
	and $04
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
	call Call_51_4C26
	ret


Jump_51_5400::
	ld hl, far_Call_58_5749
	rst $10
	ld a, $1a
	ld [$d9ed], a
	ld a, $02
	ld [$d9f1], a
	ret


Jump_51_540F::
	ld a, [$db89]
	ld [$db4c], a
	ld [$dd72], a
	call Call_51_4C26
	ld a, [$c86c]
	or a
	jr nz, jr_051_543f

	ld a, [$db89]
	cp $04
	jr c, jr_051_543f

	cp $07
	jr z, jr_051_543f

	ld a, [$db89]
	cp $03
	jr c, jr_051_543f

	jr z, jr_051_543f

	cp $07
	jr z, jr_051_543f

	ld a, [$db89]
	ld [$dd61], a

jr_051_543f:
	ld hl, far_Call_50_79EB
	rst $10
	ld hl, $c180
	ld a, l
	ld [$db4e], a
	ld a, h
	ld [$db4f], a
	ld a, [$db89]
	ld [$db50], a
	ld a, [$db89]
	call Call_51_7A0A
	call Call_51_547F
	and $04
	srl a
	srl a
	add $e3
	ld [$c823], a
	xor a
	ld [$c822], a
	ld hl, far_Call_4C_42D1
	rst $10
	ld a, $03
	ld [$d9ed], a
	xor a
	ld [$d9f1], a
	ld a, $02
	ld [$da33], a
	ret


Call_51_547F::
	ld a, [$c863]
	bit 1, a
	ld a, [$db89]
	ret z

	ld a, [$db88]
	ret


Call_51_548C::
	push bc
	push hl
	ld hl, $da33
	ld bc, $002b
	xor a
	call Call_12C7
	pop hl
	pop bc
	ret


Call_51_549B::
	ld a, [$c86c]
	or a
	ret nz

	ld a, [$da18]
	ld b, a
	ld a, [$da14]
	ld c, a
	push bc
	ld hl, $c500
	ld bc, $00c0
	ld a, $e0
	call Call_12C7
	ld hl, $db02
	ld bc, $0040
	xor a
	call Call_12C7
	ld a, [$ca8d]
	ld [$db74], a
	ld [$c1d9], a
	ld b, a
	ld c, $00

jr_051_54ca:
	call Call_51_44CB
	inc c
	dec b
	jr nz, jr_051_54ca

	ld a, [$ca8e]
	ld hl, $9700
	call Call_51_54F6
	ld a, [$ca8f]
	ld hl, $9740
	call Call_51_54F6
	ld a, [$ca90]
	ld hl, $9780
	call Call_51_54F6
	pop bc
	ld a, c
	ld [$da14], a
	ld a, b
	ld [$da18], a
	ret


Call_51_54F6::
	cp $ff
	ret z

	push hl
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	call Call_51_73DC
	ret


Call_51_5507::
	ld a, $ff
	ld hl, $da0a
	ld bc, $0008
	call Call_12C7
	ret


	db $01, $00, $08, $79, $cd, $a5, $2f, $30, $04, $16, $07, $18, $39, $79, $21, $02
	db $db, $cd, $6c, $2f, $cb, $76, $20, $18, $cb, $6e, $20, $18, $cb, $66, $20, $18
	db $cb, $7e, $20, $18, $cb, $4e, $20, $18, $cb, $46, $20, $18, $16, $00, $18, $16
	db $16, $06, $18, $12, $16, $05, $18, $0e, $16, $04, $18, $0a, $16, $03, $18, $06
	db $16, $02, $18, $02, $16, $01, $79, $21, $0a, $da, $85, $6f, $3e, $00, $8c, $67
	db $72, $0c, $05, $20, $ae, $c9

Call_51_5569::
	ld a, [$c0dc]
	ld l, a
	ld a, [$c0dd]
	ld h, a
	ld a, [$c0de]
	call Call_51_6A67
	ret


Call_51_5578::
	ld a, [$d9f4]
	rst $00

JumpTable_51_557C::
	dw Jump_51_55A0
	dw Jump_51_5602
	dw Jump_51_5638
	dw Jump_51_5736
	dw Jump_51_575F
	dw Jump_51_57BA
	dw Jump_51_57C4
	dw Jump_51_57CE
	dw Jump_51_57D8
	dw Jump_51_57E2
	dw Jump_51_57E7
	dw Jump_51_583F
	dw Jump_51_5987
	dw Jump_51_59E3
	dw Jump_51_5A1A
	dw Jump_51_5A53
	dw Jump_51_5ABC
	dw Jump_51_5AE5

Jump_51_55A0::
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $63
	jr c, jr_051_55b7

	ld hl, $d9ec
	inc [hl]
	xor a
	ld [$d9f4], a
	ret


jr_051_55b7:
	ld a, $0a
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $8820
	ld de, $0a01
	call Call_51_73A3
	ld a, $1b
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $89c0
	ld de, $0f01
	call Call_51_73A3
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	xor a
	ld hl, $d9f4
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$d9f8], a
	ld a, h
	ld [$d9f9], a
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_5602::
	ld a, [$cac0]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	inc a
	ld hl, $c190
	call Call_09A4
	ld a, $47
	call Call_1AE1
	ld hl, $0b01
	call Call_096D
	ld hl, far_Call_13_40AE
	rst $10
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_5638::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c8d0]
	or a
	jp nz, Jump_051_56ec

	ld a, [$cac0]
	ld hl, $cb13
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_5660

	xor a
	ld [$c8ca], a

jr_051_5660:
	ld a, [$cac0]
	ld hl, $cb17
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_567c

	xor a
	ld [$c8cb], a

jr_051_567c:
	ld a, [$cac0]
	ld hl, $cb19
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_5698

	xor a
	ld [$c8cc], a

jr_051_5698:
	ld a, [$cac0]
	ld hl, $cb1b
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_56b4

	xor a
	ld [$c8cd], a

jr_051_56b4:
	ld a, [$cac0]
	ld hl, $cb1d
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $ff
	ld l, a
	ld a, h
	sbc $01
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_56d0

	xor a
	ld [$c8ce], a

jr_051_56d0:
	ld a, [$cac0]
	ld hl, $cb1f
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $ff
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_56ec

	xor a
	ld [$c8cf], a

Jump_051_56ec:
jr_051_56ec:
	ld a, [$c8ca]
	ld hl, $c1a0
	call Call_09A4
	ld a, [$c8cb]
	ld hl, $c1a4
	call Call_09A4
	ld a, [$c8cc]
	ld hl, $c1a8
	call Call_09A4
	ld a, [$c8cd]
	ld hl, $c1ac
	call Call_09A4
	ld a, [$c8ce]
	ld hl, $c1b0
	call Call_09A4
	ld a, [$c8cf]
	ld hl, $c1b4
	call Call_09A4
	ld hl, $0b1e
	ld a, [$c8d0]
	or a
	jr z, jr_051_572e

	ld hl, $0b1f

jr_051_572e:
	call Call_096D
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_5736::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c0d8
	ld bc, $0028
	ld a, $ff
	call Call_12C7
	ld a, [$cac0]
	ld hl, $caea
	call Call_223B
	ld de, $c0d8
	ld b, $08

jr_051_5754:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_5754

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_575F::
	ld a, [$c825]
	or a
	ret nz

	ld hl, far_Call_06_4F9A
	rst $10
	ldh a, [$ffd8]
	cp $ff
	jr z, jr_051_57b1

	ld l, a
	ld h, $06
	ld de, $c1a0
	call Call_097A
	ld c, $ff
	ld hl, $0b02
	ldh a, [$ffd9]
	or a
	jr z, jr_051_5799

	ld hl, $0b0f
	cp $02
	jr z, jr_051_5799

	ldh a, [$ffda]
	ld l, a
	ld h, $06
	ld de, $c1b0
	call Call_097A
	ld hl, $0b03
	ldh a, [$ffda]
	ld c, a

jr_051_5799:
	push bc
	call Call_096D
	pop bc
	ld hl, $c0d8
	ld b, $28

jr_051_57a3:
	ld a, [hl]
	cp c
	jr nz, jr_051_57ac

	ldh a, [$ffd8]
	ld [hl], a
	jr jr_051_57b0

jr_051_57ac:
	inc hl
	dec b
	jr nz, jr_051_57a3

jr_051_57b0:
	ret


jr_051_57b1:
	ld hl, far_Call_01_4686
	rst $10
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_57BA::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_57C4::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_57CE::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_57D8::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_57E2::
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_57E7::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_580D
	cp $09
	jr nc, jr_051_57f9

	ld a, $10
	ld [$d9f4], a
	ret


jr_051_57f9:
	ld hl, $d9f4
	inc [hl]
	ld hl, $0b04
	call Call_096D
	call Call_51_742A
	call Call_51_768A
	call Call_51_736A
	ret


Call_51_580D::
	ld hl, $c0a0
	ld bc, $0028
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $c0a0
	ld b, $28
	ld c, $00

jr_051_5822:
	ld a, [hli]
	cp $ff
	jr z, jr_051_582a

	ld [de], a
	inc de
	inc c

jr_051_582a:
	dec b
	jr nz, jr_051_5822

	ld a, c
	push af
	ld hl, $c0d8
	ld de, $c0a0
	ld b, $28

jr_051_5837:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_051_5837

	pop af
	ret


Jump_51_583F::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $89c0
	ld de, $5112
	call Call_1577
	call Call_51_580D
	ld [$d9f6], a
	ld hl, $d9f4
	inc [hl]
	call Call_51_58F3
	call Call_51_592A
	call Call_51_742A
	call Call_51_5867
	call Call_51_736A
	ret


Call_51_5867::
	call Call_51_768A
	ld hl, far_Call_55_4774
	rst $10
	ld de, $6e78
	call Call_51_72CC
	ld de, $6fe2
	call Call_51_72CC
	ld de, $7077
	call Call_51_72CC
	call Call_51_58A9
	ld hl, $cb17
	ld a, [$cac0]
	call Call_223B
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0125
	call Call_51_726A
	call Call_2071
	call Call_51_7524
	ld de, $59d7
	ld a, [$d9f6]
	ld c, a
	ld hl, $c8db
	call Call_51_75C5
	ret


Call_51_58A9::
	ld hl, $c0d8
	ld a, [$c8dc]
	add a
	add a
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	ld d, $00
	ld hl, far_Call_07_56E8
	rst $10
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
	jr z, jr_051_58dd

	ld hl, $0121
	call Call_51_726A
	call Call_2071
	ret


jr_051_58dd:
	ld hl, $cb17
	ld a, [$cac0]
	call Call_223B
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0121
	call Call_51_726A
	call Call_2071
	ret


Call_51_58F3::
	ld de, $c0d8
	ld a, [$c8dc]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9360
	call Call_51_590D
	call Call_51_590D
	call Call_51_590D

Call_51_590D::
	push de
	push hl
	ld a, [de]
	ld [$c823], a
	ld a, $06
	ld [$c822], a
	ld de, $0901
	call Call_51_73A3
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


Call_51_592A::
	ld hl, $c0d8
	ld a, [$c8dc]
	add a
	add a
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
	ld [$c823], a
	ld a, $01
	ld [$c822], a
	ld hl, $9000
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
	ld hl, Jump_51_5602
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


Jump_51_5987::
	ld de, $59d7
	ld hl, $c8db
	ld a, [$d9f6]
	ld c, a
	ld b, $04
	ld a, [hli]
	push af
	ld a, [hld]
	push af
	call Call_51_744A
	pop af
	ld hl, $c8dc
	cp [hl]
	jr z, jr_051_59ad

	call Call_51_58F3
	call Call_51_592A
	call Call_51_58A9
	call Call_51_736A

jr_051_59ad:
	pop af
	ld hl, $c8db
	cp [hl]
	jr z, jr_051_59bd

	call Call_51_592A
	call Call_51_58A9
	call Call_51_736A

jr_051_59bd:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_59d6

	ld a, $59
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	ld hl, $c8db
	set 7, [hl]
	xor a
	ld [$c8dd], a

jr_051_59d6:
	ret


	db $52, $01, $69, $00, $a9, $00, $e9, $00, $29, $01, $ff, $ff

Jump_51_59E3::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ld hl, $c0d8
	ld a, [$c8dc]
	add a
	add a
	ld b, a
	ld a, [$c8db]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $06
	ld de, $c180
	call Call_097A
	ld hl, $0b05
	call Call_096D
	ld de, $2e07
	call Call_51_72CC
	call Call_51_736A
	ret


Jump_51_5A1A::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ld a, $5c
	call Call_1B2C
	call Call_51_742A
	call Call_51_5867
	ld de, $2e07
	call Call_51_72CC
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $6eef
	call Call_51_72CC
	call Call_51_7524
	ld de, $5ab6
	ld a, [$c8dd]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_5A53::
	ld de, $5ab6
	ld hl, $c8dd
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_5a72

jr_051_5a65:
	ld hl, $0b07
	call Call_096D
	ld a, $0b
	ld [$d9f4], a
	jr jr_051_5ab5

jr_051_5a72:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_5ab5

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $81
	jr z, jr_051_5a65

	ld hl, $d9f4
	inc [hl]
	ld hl, $c8dd
	set 7, [hl]
	ld hl, $c0d8
	ld a, [$c8dc]
	add a
	add a
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
	ld [hl], $ff
	ld l, a
	ld h, $06
	ld de, $c180
	call Call_097A
	ld hl, $0b06
	call Call_096D

jr_051_5ab5:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_51_5ABC::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	push hl
	ld a, [$cac0]
	ld hl, $cb0d
	call Call_223B
	ld a, [hl]
	dec a
	pop hl
	cp [hl]
	jr nz, jr_051_5ae0

	ld hl, $0b20
	call Call_096D

jr_051_5ae0:
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_5AE5::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_580D
	cp $09
	jr c, jr_051_5b04

	ld hl, $0b07
	call Call_096D
	ld a, $0b
	ld [$d9f4], a
	xor a
	ld [$c8db], a
	ld [$c8dc], a
	ret


jr_051_5b04:
	call Call_51_5B1C
	call Call_51_5B31
	call Call_51_742A
	call Call_51_768A
	call Call_51_736A
	xor a
	ld [$d9f4], a
	ld hl, $d9ec
	dec [hl]
	ret


Call_51_5B1C::
	ld a, [$cac0]
	ld hl, $caea
	call Call_223B
	ld de, $c0d8
	ld b, $08

jr_051_5b2a:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_051_5b2a

	ret


Call_51_5B31::
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	cp $63
	ret nc

	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld a, [hl]
	inc a
	ld [hl], a
	ld a, [$c8d0]
	or a
	jr nz, jr_051_5b99

	ld a, [$c8ca]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_23E9
	ld a, [$c8cb]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2403
	ld a, [$c8cc]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2307
	ld a, [$c8cd]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2321
	ld a, [$c8ce]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_233B
	ld a, [$c8cf]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2355
	ret


jr_051_5b99:
	ld a, [$c8ca]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_23F6
	ld a, [$c8cb]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2410
	ld a, [$c8cc]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2314
	ld a, [$c8cd]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_232E
	ld a, [$c8ce]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2348
	ld a, [$c8cf]
	ld l, a
	ld h, $00
	ld a, [$cac0]
	call Call_2362
	ld a, [$cac0]
	ld hl, $cb13
	call Call_223B
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
	ld a, [$cac0]
	ld hl, $cb11
	call Call_223B
	pop bc
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc [hl]
	jr nc, jr_051_5c02

	ld [hl], b
	dec hl
	ld [hl], c

jr_051_5c02:
	ld a, [$cac0]
	ld hl, $cb17
	call Call_223B
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
	ld a, [$cac0]
	ld hl, $cb15
	call Call_223B
	pop bc
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc [hl]
	jr nc, jr_051_5c23

	ld [hl], b
	dec hl
	ld [hl], c

jr_051_5c23:
	call Call_51_549B
	call Call_51_6A7E
	call Call_51_768A
	call Call_51_79CB
	call Call_51_736A
	ret


Call_51_5C33::
	ld a, [$d9f4]
	rst $00

JumpTable_51_5C37::
	dw Jump_51_5C81
	dw Jump_51_5D27
	dw Jump_51_5D4D
	dw Jump_51_5D91
	dw Jump_51_5DEA
	dw Jump_51_5E4D
	dw Jump_51_5E7A
	dw Jump_51_5ED7
	dw Jump_51_5FA8
	dw Jump_51_614F
	dw Jump_51_61BD
	dw Jump_51_61C2
	dw Jump_51_61F9
	dw Jump_51_62AA
	dw Jump_51_6318
	dw Jump_51_6353
	dw Jump_51_6380
	dw Jump_51_63C2
	dw Jump_51_6401
	dw Jump_51_646C
	dw Jump_51_64DB
	dw Jump_51_6531
	dw Jump_51_6567
	dw Jump_51_658A
	dw Jump_51_65DE
	dw Jump_51_6655
	dw Jump_51_6680
	dw Jump_51_66F3
	dw Jump_51_6717
	dw Jump_51_6789
	dw Jump_51_6789
	dw Jump_51_67A6
	dw Jump_51_67B6
	dw Jump_51_67F0
	dw Jump_51_6829
	dw Jump_51_683D
	dw Jump_51_687E

Jump_51_5C81::
	ld hl, far_Call_17_41C0
	rst $10
	ld hl, far_Call_17_46DD
	rst $10
	ld a, $0a
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $8820
	ld de, $0a01
	call Call_51_73A3
	ld a, $1b
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $89c0
	ld de, $0f01
	call Call_51_73A3
	ld a, $14
	ld [$da14], a
	ld hl, far_Call_14_401D
	rst $10
	ld hl, far_Call_14_4016
	rst $10
	ld hl, $9000
	ld a, [$da18]
	call Call_51_6A67
	ld hl, $c8da
	ld bc, $0008
	ld a, $00
	call Call_12C7
	xor a
	ld hl, $d9f4
	ld bc, $0008
	call Call_12C7
	ld hl, $9800
	ld a, l
	ld [$d9f8], a
	ld a, h
	ld [$d9f9], a
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	call Call_51_736A
	ld de, $c1c0
	ld a, [$ca8e]
	call Call_51_5D13
	ld a, [$ca8f]
	call Call_51_5D13
	ld a, [$ca90]
	call Call_51_5D13
	ld hl, $d9f4
	inc [hl]
	ret


Call_51_5D13::
	cp $ff
	ret z

	push de
	ld hl, $cac2
	call Call_223B
	pop de
	ld b, $08

jr_051_5d20:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_5d20

	ret


Jump_51_5D27::
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c180
	call Call_097A
	ld a, $14
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld de, $c180
	call Call_51_6915
	ld hl, $0b10
	call Call_096D
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_5D4D::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $6eef
	call Call_51_72CC
	call Call_51_7524
	ld de, $5de4
	ld a, [$c8da]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_5D91::
	ld de, $5de4
	ld hl, $c8da
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_5dbc

jr_051_5da3:
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c180
	call Call_097A
	ld hl, $0b12
	call Call_096D
	ld a, $1d
	ld [$d9f4], a
	jr jr_051_5de3

jr_051_5dbc:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_5de3

	ld a, $59
	call Call_1B2C
	ld a, [$c8da]
	cp $81
	jr z, jr_051_5da3

	ld hl, $d9f4
	inc [hl]
	ld hl, $c8da
	set 7, [hl]
	ld hl, $c8db
	ld bc, $0007
	ld a, $00
	call Call_12C7

jr_051_5de3:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_51_5DEA::
	call Call_51_5E34
	or a
	jr z, jr_051_5df7

	ld a, $15
	ld [$d9f4], a
	jr jr_051_5e33

jr_051_5df7:
	ld hl, $d9f4
	inc [hl]
	ld hl, $0b11
	call Call_096D
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $6eef
	call Call_51_72CC
	ld de, $5de4
	ld a, [$c8da]
	call Call_51_75E7
	call Call_51_736A

jr_051_5e33:
	ret


Call_51_5E34::
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_051_5e3b:
	ld a, [de]
	or a
	jr nz, jr_051_5e40

	inc c

jr_051_5e40:
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_051_5e3b

	ld a, c
	ret


Jump_51_5E4D::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $6eef
	call Call_51_72CC
	call Call_51_7524
	ld de, $5ed1
	ld a, [$c8db]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_5E7A::
	ld de, $5ed1
	ld hl, $c8db
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_5ea5

jr_051_5e8c:
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c180
	call Call_097A
	ld hl, $0b12
	call Call_096D
	ld a, $1d
	ld [$d9f4], a
	jr jr_051_5ed0

jr_051_5ea5:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_5ed0

	ld a, $59
	call Call_1B2C
	ld a, [$c8db]
	cp $81
	jr z, jr_051_5e8c

	ld hl, $c8e2
	ld bc, $0008
	ld a, $00
	call Call_12C7
	ld hl, $c8db
	set 7, [hl]
	inc hl
	ld [hl], $00
	ld a, $1f
	ld [$d9f4], a

jr_051_5ed0:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_51_5ED7::
	call Call_51_5F2E
	or a
	jr nz, jr_051_5ee9

	ld hl, $0b1c
	call Call_096D
	ld a, $22
	ld [$d9f4], a
	ret


jr_051_5ee9:
	call Call_51_5F64
	ld hl, Jump_0B13
	ld a, [$c8e4]
	and $01
	jr z, jr_051_5ef9

	ld hl, $0b22

jr_051_5ef9:
	call Call_096D
	call Call_51_5F07
	call Call_51_736A
	ld hl, $d9f4
	inc [hl]
	ret


Call_51_5F07::
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	ld de, $70ab
	call Call_51_72CC
	ld de, $6823
	ld a, [$c8e4]
	call Call_51_75E7
	ret


Call_51_5F2E::
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_051_5f35:
	push de
	ld a, [de]
	or a
	jr z, jr_051_5f53

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [$c8e4]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	jr nz, jr_051_5f53

	inc c

jr_051_5f53:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_051_5f35

	ld a, c
	ld [$c8e9], a
	ret


Call_51_5F64::
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_051_5f79:
	push de
	ld a, [de]
	or a
	jr z, jr_051_5f9a

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push hl
	ld a, [$c8e4]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, jr_051_5f9a

	ld [hl], c
	inc hl

jr_051_5f9a:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_051_5f79

	ret


Jump_51_5FA8::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_5FEC
	call Call_51_5FBB
	call Call_51_736A
	ld hl, $d9f4
	inc [hl]
	ret


Call_51_5FBB::
	ld hl, far_Call_55_4813
	rst $10
	ld de, $6f14
	ld a, [$c8e4]
	and $01
	jr z, jr_051_5fcc

	ld de, $70d0

jr_051_5fcc:
	call Call_51_72CC
	call Call_51_7524
	ld de, $61a5
	ld a, [$c8e4]
	and $01
	jr z, jr_051_5fdf

	ld de, $61b1

jr_051_5fdf:
	ld b, $04
	ld a, [$c8e9]
	ld c, a
	ld hl, $c8e2
	call Call_51_75C5
	ret


Call_51_5FEC::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [$c8e4]
	and $01
	jr z, jr_051_6014

	ld hl, $9240
	call Call_51_605B
	call Call_51_605B
	call Call_51_605B
	call Call_51_605B
	call Call_51_609F
	ret


jr_051_6014:
	ld hl, $88c0
	call Call_51_6020
	call Call_51_6020
	call Call_51_6020

Call_51_6020::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_051_6041

	ld a, [de]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_51_73DC
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


jr_051_6041:
	ld b, $20

jr_051_6043:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_051_6043

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


Call_51_605B::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_051_6085

	ld hl, $caca
	call Call_223B
	ld a, [hl]
	ld [$c823], a
	ld a, $05
	ld [$c822], a
	ld de, $0901
	pop hl
	push hl
	call Call_51_73A3
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


jr_051_6085:
	ld b, $48

jr_051_6087:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_051_6087

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


Call_51_609F::
	ld a, [$c8e3]
	add a
	add a
	ld de, $c0d8
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9480
	call Call_51_60B9
	call Call_51_60B9
	call Call_51_60B9

Call_51_60B9::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_051_6135

	ld hl, $cb24
	call Call_223B
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, jr_051_60da

	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	and $01
	add $a7

jr_051_60da:
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


jr_051_6135:
	ld b, $08

jr_051_6137:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_051_6137

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


Jump_51_614F::
	ld de, $61a5
	ld a, [$c8e4]
	and $01
	jr z, jr_051_615c

	ld de, $61b1

jr_051_615c:
	ld hl, $c8e2
	ld a, [$c8e9]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call Call_51_744A
	pop af
	ld hl, $c8e3
	cp [hl]
	jr z, jr_051_6175

	call Call_51_5FEC

jr_051_6175:
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_618c

	call Call_51_67C3
	ld a, $20
	ld [$d9f4], a
	ld hl, $0b1a
	call Call_096D
	jr jr_051_61a4

jr_051_618c:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_61a4

	ld a, $59
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	ld hl, $c8dc
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_61a4:
	ret


	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff, $8b, $01, $a1, $00
	db $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_51_61BD::
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_61C2::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_61CF
	ld hl, $d9f4
	inc [hl]
	ret


Call_51_61CF::
	ld de, $6f6e
	ld a, [$c8e4]
	and $01
	jr z, jr_051_61dc

	ld de, $7150

jr_051_61dc:
	call Call_51_72CC
	call Call_51_7524
	ld de, $629e
	ld a, [$c8e4]
	and $01
	jr z, jr_051_61ef

	ld de, $62a4

jr_051_61ef:
	ld a, [$c8dd]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_61F9::
	ld de, $629e
	ld a, [$c8e4]
	and $01
	jr z, jr_051_6206

	ld de, $62a4

jr_051_6206:
	ld hl, $c8dd
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_622b

	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	jr jr_051_629d

jr_051_622b:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_629d

	ld a, $59
	call Call_1B2C
	ld a, [$c8dd]
	cp $81
	jr z, jr_051_624c

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $19
	ld [$d9f4], a
	jr jr_051_629d

jr_051_624c:
	ld a, [$ca8d]
	cp $01
	jr z, jr_051_6260

	ld a, [$ca8f]
	ld hl, $cb0b
	call Call_223B
	bit 7, [hl]
	jr z, jr_051_6291

jr_051_6260:
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
	ld a, [$ca8e]
	cp [hl]
	jr nz, jr_051_6291

	ld hl, $0b24
	call Call_096D
	ld de, $2e07
	call Call_51_72CC
	call Call_51_736A
	ld a, $1f
	ld [$d9f4], a
	jr jr_051_629d

jr_051_6291:
	ld hl, $d9f4
	inc [hl]
	ld hl, $c8dd
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_629d:
	ret


	db $2e, $01, $6e, $01, $ff, $ff, $2d, $01, $6d, $01, $ff, $ff

Jump_51_62AA::
	ld a, [$c825]
	or a
	ret nz

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
	ld hl, $cb24
	call Call_223B
	ld a, [hl]
	or a
	jr z, jr_051_62e0

	pop af
	push af
	ld hl, $0b1d
	call Call_096D
	ld de, $70d0
	call Call_51_72CC
	jr jr_051_62f6

jr_051_62e0:
	pop af
	push af
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld hl, $0b14
	call Call_096D

jr_051_62f6:
	pop af
	ld hl, $cac1
	call Call_223B
	ld [hl], $00
	ld hl, far_Call_01_46F6
	rst $10
	call Call_51_6A7E
	call Call_51_768A
	ld de, $2e07
	call Call_51_72CC
	call Call_51_736A
	ld a, $15
	ld [$d9f4], a
	ret


Jump_51_6318::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ld a, [$da14]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld hl, $0b15
	call Call_096D
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	call Call_51_736A
	ret


Jump_51_6353::
	ld a, [$c825]
	or a
	ret nz

	ld a, $5c
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $6eef
	call Call_51_72CC
	call Call_51_7524
	ld de, $63bc
	ld a, [$c8de]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_6380::
	ld de, $63bc
	ld hl, $c8de
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_6398

jr_051_6392:
	ld hl, $d9f4
	inc [hl]
	jr jr_051_63bb

jr_051_6398:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_63bb

	ld a, $59
	call Call_1B2C
	ld a, [$c8de]
	cp $81
	jr z, jr_051_6392

	ld hl, $d9f4
	inc [hl]
	ld hl, $d9f4
	inc [hl]
	ld hl, $c8de
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_63bb:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_51_63C2::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	ld a, [$da14]
	ld hl, $cac2
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $c180
	call Call_0C80
	ld hl, $0b16
	call Call_096D
	ld a, $1e
	ld [$d9f4], a
	ret


Call_51_63E8::
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_051_63ef:
	ld a, [de]
	or a
	jr z, jr_051_63ff

	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_051_63ef

jr_051_63ff:
	ld a, c
	ret


Jump_51_6401::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$ca8d]
	cp $03
	jr z, jr_051_642b

	ld a, [$ca8d]
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
	ld hl, far_Call_01_46F6
	rst $10
	ld a, $1e
	ld [$d9f4], a
	ret


jr_051_642b:
	ld hl, $d9f4
	inc [hl]
	ld hl, $0b18
	call Call_096D
	call Call_51_643C
	call Call_51_736A
	ret


Call_51_643C::
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	ld hl, $89c0
	ld de, $5112
	call Call_1577
	ld de, $6eef
	call Call_51_72CC
	ld de, $63bc
	ld a, [$c8de]
	call Call_51_75E7
	ret


Jump_51_646C::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $d9f4
	inc [hl]
	call Call_51_64AC
	call Call_51_6499
	call Call_51_6482
	call Call_51_736A
	ret


Call_51_6482::
	ld hl, far_Call_55_4813
	rst $10
	ld de, $6f14
	call Call_51_72CC
	call Call_51_7524
	ld de, $6527
	ld a, [$c8df]
	call Call_51_75E7
	ret


Call_51_6499::
	ld de, $c0d8
	ld hl, $88c0
	call Call_51_6020
	call Call_51_6020
	call Call_51_6020
	call Call_51_6020
	ret


Call_51_64AC::
	ld hl, $c0d8
	ld bc, $0004
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld a, [$ca8e]
	cp $ff
	call nz, Call_51_64D9
	ld a, [$ca8f]
	cp $ff
	call nz, Call_51_64D9
	ld a, [$ca90]
	cp $ff
	call nz, Call_51_64D9
	ld a, [$da14]
	call Call_51_64D9
	ret


Call_51_64D9::
	ld [hli], a
	ret


Jump_51_64DB::
	ld de, $6527
	ld hl, $c8df
	ld a, [$ca8d]
	inc a
	ld b, a
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_650a

	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	jr jr_051_6526

jr_051_650a:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_6526

	ld a, $59
	call Call_1B2C
	ld hl, $d9f4
	inc [hl]
	ld hl, $d9f4
	inc [hl]
	ld hl, $c8df
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_6526:
	ret


	db $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

Jump_51_6531::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_63E8
	ld [$da14], a
	call Call_51_6928
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c180
	call Call_097A
	ld a, [$da14]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld de, $c180
	call Call_51_6915
	ld hl, $0b17
	call Call_096D
	ld a, $23
	ld [$d9f4], a
	ret


Jump_51_6567::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_6574
	ld hl, $d9f4
	inc [hl]
	ret


Call_51_6574::
	ld de, $6f6e
	call Call_51_72CC
	call Call_51_7524
	ld de, $65d8
	ld a, [$c8e0]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_658A::
	ld de, $65d8
	ld hl, $c8e0
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_65aa

	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	ld hl, $d9f4
	dec [hl]
	jr jr_051_65d7

jr_051_65aa:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_65d7

	ld a, $59
	call Call_1B2C
	ld a, [$c8e0]
	cp $81
	jr z, jr_051_65cb

	xor a
	ld [$c90d], a
	ld [$c90e], a
	ld a, $1b
	ld [$d9f4], a
	jr jr_051_65d7

jr_051_65cb:
	ld hl, $d9f4
	inc [hl]
	ld hl, $c8e0
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_65d7:
	ret


	db $2e, $01, $6e, $01, $ff, $ff

Jump_51_65DE::
	ld a, [$c825]
	or a
	ret nz

	ld a, [$c8df]
	and $7f
	ld hl, $c0d8
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
	ld a, [$da18]
	ld l, a
	ld h, $05
	ld de, $c190
	call Call_097A
	ld hl, $0b19
	call Call_096D
	ld de, $2e07
	call Call_51_72CC
	call Call_51_736A
	ld a, [$c8df]
	and $7f
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld hl, $ca8e
	ld a, [$c0d8]
	call Call_51_6650
	ld a, [$c0d9]
	call Call_51_6650
	ld a, [$c0da]
	call Call_51_6650
	ld a, [$c0db]
	call Call_51_6650
	ld hl, far_Call_01_46F6
	rst $10
	ld a, $1d
	ld [$d9f4], a
	ret


Call_51_6650::
	cp $ff
	ret z

	ld [hli], a
	ret


Jump_51_6655::
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
	ld [$c906], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_6680::
	ld de, $5b00
	ld hl, $9600
	call Call_1577
	ld de, $5b01
	ld hl, $8800
	call Call_1577
	ld a, $0a
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $8820
	ld de, $0a01
	call Call_51_73A3
	ld a, $1b
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $89c0
	ld de, $0f01
	call Call_51_73A3
	ld hl, $9000
	ld a, [$da18]
	call Call_51_6A67
	call Call_51_5F2E
	call Call_51_5F64
	call Call_51_5FEC
	ld hl, Jump_0B13
	ld a, [$c8e4]
	and $01
	jr z, jr_051_66d7

	ld hl, $0b22

jr_051_66d7:
	call Call_096D
	call Call_0609
	call Call_51_6A0D
	call Call_51_5F07
	call Call_51_5FBB
	call Call_51_61CF
	ld hl, far_Call_17_46DD
	rst $10
	ld a, $0b
	ld [$d9f4], a
	ret


Jump_51_66F3::
	ld a, [$c8df]
	and $7f
	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$cac0], a
	xor a
	ld [$c906], a
	ld hl, far_Call_07_6456
	rst $10
	ld a, [$c906]
	or a
	ret z

	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_6717::
	ld de, $5b00
	ld hl, $9600
	call Call_1577
	ld de, $5b01
	ld hl, $8800
	call Call_1577
	ld a, $0a
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $8820
	ld de, $0a01
	call Call_51_73A3
	ld a, $1b
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $89c0
	ld de, $0f01
	call Call_51_73A3
	ld hl, $9000
	ld a, [$da18]
	call Call_51_6A67
	call Call_51_5F2E
	call Call_51_5F64
	call Call_51_5FEC
	ld hl, $0b18
	call Call_096D
	call Call_0609
	call Call_51_549B
	call Call_51_6A7E
	call Call_51_643C
	call Call_51_64AC
	call Call_51_6499
	call Call_51_6482
	call Call_51_6574
	ld hl, far_Call_17_46DD
	rst $10
	ld a, $17
	ld [$d9f4], a
	ret


Jump_51_6789::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_549B
	call Call_51_6A7E
	call Call_51_742A
	call Call_51_768A
	call Call_51_736A
	xor a
	ld [$d9f4], a
	ld hl, $d9ec
	inc [hl]
	ret


Jump_51_67A6::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $0b1a
	call Call_096D
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_67B6::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_67C3
	ld hl, $d9f4
	inc [hl]
	ret


Call_51_67C3::
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	ld de, $70ab
	call Call_51_72CC
	call Call_51_7524
	ld de, $6823
	ld a, [$c8e4]
	call Call_51_75E7
	call Call_51_736A
	ret


Jump_51_67F0::
	ld de, $6823
	ld hl, $c8e4
	ld b, $02
	call Call_51_74D3
	ld a, [$c846]
	bit 1, a
	jr z, jr_051_6809

	ld a, $04
	ld [$d9f4], a
	jr jr_051_6822

jr_051_6809:
	ld a, [$c846]
	bit 0, a
	jp z, Jump_051_6822

	ld a, $59
	call Call_1B2C
	xor a
	ld [$c8e2], a
	ld [$c8e3], a
	ld a, $07
	ld [$d9f4], a

Jump_051_6822:
jr_051_6822:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

Jump_51_6829::
	ld a, [$c825]
	or a
	ret nz

	call Call_51_67C3
	ld a, $20
	ld [$d9f4], a
	ld hl, $0b1a
	call Call_096D
	ret


Jump_51_683D::
	ld a, [$c825]
	or a
	ret nz

	ld hl, $c8eb
	set 4, [hl]
	ld a, $ff
	ld [$c8ef], a
	xor a
	ld [$c905], a
	ld a, [$da18]
	ld [$c8f5], a
	add $10
	ld [$c8f4], a
	ld a, [$da14]
	ld hl, $cacc
	call Call_223B
	ld a, [hl]
	ld [$c8f6], a
	ld a, [$da14]
	ld hl, $cac2
	call Call_223B
	ld a, l
	ld [$c8f2], a
	ld a, h
	ld [$c8f3], a
	ld hl, $d9f4
	inc [hl]
	ret


Jump_51_687E::
	call Call_51_6903
	ld hl, far_Call_09_6120
	rst $10
	call Call_51_6903
	ld a, [$c8eb]
	bit 4, a
	ret nz

	call Call_51_742A
	call Call_51_736A
	ld hl, far_Call_56_4485
	rst $10
	ld hl, $d9f4
	inc [hl]
	ld de, $5b00
	ld hl, $9600
	call Call_1577
	ld de, $5b01
	ld hl, $8800
	call Call_1577
	ld a, $0a
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $8820
	ld de, $0a01
	call Call_51_73A3
	ld a, $1b
	ld [$c823], a
	ld a, $0b
	ld [$c822], a
	ld hl, $89c0
	ld de, $0f01
	call Call_51_73A3
	ld hl, $9000
	ld a, [$da18]
	call Call_51_6A67
	call Call_51_549B
	call Call_51_6A7E
	call Call_51_742A
	call Call_51_768A
	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ld a, [$da18]
	ld hl, $00c7
	call Call_51_6943
	call Call_51_736A
	ld a, $0e
	ld [$d9f4], a
	ret


Call_51_6903::
	ld hl, $c8da
	ld de, $c876
	ld b, $08

jr_051_690b:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_690b

	ret


Call_51_6915::
	push af

jr_051_6916:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_051_6916

	dec de
	pop af
	and $01
	add $a7
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
	ret


Call_51_6928::
	ld hl, $cac1
	call Call_223B
	ld b, $95
	ld de, $d665

jr_051_6933:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_051_6933

	ld a, [$da18]
	ld hl, $ca94
	call Call_2670
	ret


Call_51_6943::
	ld [$c81e], a
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld a, [$dd61]
	ld [$c81f], a
	ld hl, far_Call_17_41D0
	rst $10
	ret


Call_51_6959::
	ld a, [$c86c]
	or a
	jr z, jr_051_696d

	ld a, [$c863]
	bit 1, a
	jr z, jr_051_696d

	ld a, [$db74]
	ld c, $00
	jr jr_051_6972

jr_051_696d:
	ld a, [$db75]
	ld c, $04

jr_051_6972:
	cp $03
	jr z, jr_051_6992

	cp $02
	jr z, jr_051_6982

	ld a, c
	ld hl, $00c7
	call Call_51_69AA
	ret


jr_051_6982:
	ld a, c
	ld hl, $00c4
	call Call_51_69AA
	inc c
	ld a, c
	ld hl, $00ca
	call Call_51_69AA
	ret


jr_051_6992:
	ld a, c
	ld hl, $00c1
	call Call_51_69AA
	inc c
	ld a, c
	ld hl, $00c7
	call Call_51_69AA
	inc c
	ld a, c
	ld hl, $00cd
	call Call_51_69AA
	ret


Call_51_69AA::
	push bc
	push af
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	pop af
	push af
	ld de, $dc3c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [$c81e], a
	call Call_51_69D4
	pop af
	and $03
	add $04
	ld [$c81f], a
	ld hl, far_Call_17_41D0
	rst $10
	pop bc
	ret


Call_51_69D4::
	ld a, [$c81d]
	or a
	ret z

	ld a, [$c86c]
	or a
	jr z, jr_051_69ed

	ld a, [$c863]
	bit 1, a
	jr z, jr_051_69ed

	ld a, c
	cp $03
	jr nc, jr_051_6a0c

	jr jr_051_69f6

jr_051_69ed:
	ld a, c
	cp $04
	jr c, jr_051_6a0c

	cp $07
	jr z, jr_051_6a0c

jr_051_69f6:
	ld a, $02
	ldh [rSVBK], a
	ld a, c
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c81e], a
	ld a, $00
	ldh [rSVBK], a

jr_051_6a0c:
	ret


Call_51_6A0D::
	ld a, $00
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld a, $01
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld a, $02
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld hl, $9700
	ld b, $60

jr_051_6a2d:
	ld a, $ff
	call Call_1AB9
	ld a, $00
	call Call_1AB9
	dec b
	jr nz, jr_051_6a2d

	ld a, [$db74]
	or a
	ret z

	ld de, $c1c0
	ld hl, $9700
	call Call_51_73DC
	ld a, [$db74]
	cp $01
	ret z

	ld de, $c1c8
	ld hl, $9740
	call Call_51_73DC
	ld a, [$db74]
	cp $02
	ret z

	ld de, $c1d0
	ld hl, $9780
	call Call_51_73DC
	ret


Call_51_6A67::
	push de
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
	call Call_1577
	pop de
	ret


Call_51_6A7E::
	ld a, $00
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld a, $01
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
	ld a, $02
	ld [$db89], a
	ld hl, far_Call_50_7C4D
	rst $10
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

Call_51_7247::
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


Call_51_7256::
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


Call_51_726A::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


Call_51_7273::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_51_7256
	ld a, b
	and $1f
	jr z, jr_051_7288

	ld b, a

jr_051_7282:
	call Call_51_7247
	dec b
	jr nz, jr_051_7282

jr_051_7288:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $73, $72, $7d, $ea, $ea, $d9, $7c, $ea, $eb
	db $d9, $1a, $13, $fe, $d9, $c8, $fe, $d8, $20, $20, $fa, $ea, $d9, $6f, $fa, $eb
	db $d9, $67, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67
	db $7d, $ea, $ea, $d9, $7c, $ea, $eb, $d9, $18, $d7, $cd, $ad, $1a, $cd, $47, $72
	db $18, $cf

Call_51_72CC::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Call_51_726A
	ld a, l
	ld [$d9ea], a
	ld a, h
	ld [$d9eb], a

jr_051_72dd:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_051_7300

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
	jr jr_051_72dd

jr_051_7300:
	ld [hli], a
	jr jr_051_72dd

	db $fa, $74, $db, $4f, $fa, $63, $c8, $cb, $4f, $28, $04, $fa, $75, $db, $4f, $c5
	db $06, $25, $0e, $62, $cd, $32, $73, $c1, $0d, $c8, $c5, $06, $2b, $0e, $68, $cd
	db $32, $73, $c1, $0d, $c8, $c5, $06, $31, $0e, $6e, $cd, $32, $73, $c1, $c9, $68
	db $26, $98, $78, $11, $00, $c5, $83, $5f, $3e, $00, $8a, $57, $1a, $cd, $ad, $1a
	db $06, $03, $69, $26, $98, $79, $11, $00, $c5, $83, $5f, $3e, $00, $8a, $57, $cd
	db $8e, $73, $06, $03, $79, $c6, $20, $6f, $26, $98, $11, $00, $c5, $83, $5f, $3e
	db $00, $8a, $57, $cd, $8e, $73, $c9

Call_51_736A::
	ld a, [$d9f8]
	ld l, a
	ld a, [$d9f9]
	ld h, a
	ld de, $c500
	ld c, $12

jr_051_7377:
	ld b, $20
	push hl
	call Call_51_738E
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
	jr nz, jr_051_7377

	ret


Call_51_738E::
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
	jr nz, Call_51_738E

	ret


Call_51_73A3::
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


Call_51_73DC::
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


Call_51_742A::
	ld hl, $c500
	ld bc, $0240

jr_051_7430:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_051_7430

	ret


Call_51_7439::
	ld hl, $9800
	ld bc, $0400

jr_051_743f:
	ld a, $e0
	call Call_1AB9
	dec bc
	ld a, b
	or c
	jr nz, jr_051_743f

	ret


Call_51_744A::
	ld a, c
	ld [$c8e1], a
	inc de
	inc de
	ld a, [$c825]
	or a
	jp nz, Jump_051_74b1

	ld a, [$c847]
	bit 5, a
	jr z, jr_051_7477

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
	jr c, jr_051_7495

	ld a, c
	dec a
	jr jr_051_7495

jr_051_7477:
	ld a, [$c847]
	bit 4, a
	jr z, jr_051_74b1

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
	jr c, jr_051_7495

	ld a, $00

jr_051_7495:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_051_74f4

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
	jr z, jr_051_74f4

	dec a
	cp [hl]
	jr nc, jr_051_74f4

	ld [hl], a
	jr jr_051_74f4

Jump_051_74b1:
jr_051_74b1:
	push bc
	push de
	push hl
	call Call_51_758C
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
	jr nz, Call_51_74D3

	ld a, [$c8e1]
	inc a
	ld b, a

Call_51_74D3::
	res 7, [hl]
	ld a, [$c847]
	bit 6, a
	jr z, jr_051_74e5

	ld a, [hl]
	dec a
	cp b
	jr c, jr_051_74f3

	dec b
	ld a, b
	jr jr_051_74f3

jr_051_74e5:
	ld a, [$c847]
	bit 7, a
	jr z, jr_051_74fc

	ld a, [hl]
	inc a
	cp b
	jr c, jr_051_74f3

	ld a, $00

jr_051_74f3:
	ld [hl], a

jr_051_74f4:
	xor a
	ld [$d9fb], a
	push hl
	push de
	pop de
	pop hl

jr_051_74fc:
	ld a, [$c846]
	bit 0, a
	jr z, jr_051_7505

	set 7, [hl]

jr_051_7505:
	ld a, [hl]
	call Call_51_7529
	ret


	db $cb, $be, $fa, $47, $c8, $e6, $c0, $28, $05, $7e, $ee, $01, $18, $db, $fa, $47
	db $c8, $e6, $30, $28, $dd, $7e, $ee, $02, $18, $cf

Call_51_7524::
	xor a
	ld [$d9fb], a
	ret


Call_51_7529::
	ld c, a
	bit 7, a
	jr nz, jr_051_753e

	ld a, [$d9fb]
	and $0f
	push af
	ld a, [$d9fb]
	inc a
	ld [$d9fb], a
	pop af
	ld a, c
	ret nz

jr_051_753e:
	ld c, a
	ld b, $00

jr_051_7541:
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
	call Call_51_7273
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_051_7573

	ld a, $e9
	bit 7, c
	jr nz, jr_051_7573

	ld a, [$d9fb]
	bit 4, a
	ld a, $e0
	jr nz, jr_051_7573

	ld a, $e8

jr_051_7573:
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
	jr jr_051_7541

Call_51_758C::
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
	call Call_51_7273
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


Call_51_75C5::
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
	jr nc, jr_051_75de

	ld a, $e7

jr_051_75de:
	ld [hld], a
	pop bc
	jr nc, jr_051_75e6

	ld a, [bc]
	add $f1
	ld [hl], a

jr_051_75e6:
	pop af

Call_51_75E7::
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
	call Call_51_7273
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_051_7614

	ld a, [$d9fb]
	bit 4, a
	ld a, $e0
	jr nz, jr_051_7614

	ld a, $e8

jr_051_7614:
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


Call_51_7628::
	ld a, [$c86c]
	or a
	jr z, jr_051_763a

	ld a, [$c863]
	bit 1, a
	jr z, jr_051_763a

	ld a, [$db74]
	jr jr_051_763d

jr_051_763a:
	ld a, [$db75]

jr_051_763d:
	cp $03
	jr z, jr_051_765d

	cp $02
	jr z, jr_051_764e

	ld a, $00
	ld hl, $00c7
	call Call_51_7672
	ret


jr_051_764e:
	ld a, $00
	ld hl, $00c4
	call Call_51_7672
	ld hl, $00ca
	call Call_51_7672
	ret


jr_051_765d:
	ld a, $00
	ld hl, $00c1
	call Call_51_7672
	ld hl, $00c7
	call Call_51_7672
	ld hl, $00cd
	call Call_51_7672
	ret


Call_51_7672::
	ld c, $06

jr_051_7674:
	push hl
	push af
	call Call_51_726A
	pop af
	ld b, $06

jr_051_767c:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_051_767c

	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, jr_051_7674

	ret


Call_51_768A::
	ld de, $2e07
	call Call_51_72CC
	ld a, [$d9f3]
	or a
	jp nz, Jump_051_7763

Call_51_7697::
	ld a, [$c86c]
	or a
	jr nz, jr_051_76a2

	ld a, [$ca8d]
	or a
	ret z

jr_051_76a2:
	call Call_51_76A7
	jr jr_051_76c7

Call_51_76A7::
	ld hl, $775b
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_76b6

	ld a, [$db75]
	jr jr_051_76b9

jr_051_76b6:
	ld a, [$db74]

jr_051_76b9:
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	call Call_51_72CC
	ret


jr_051_76c7:
	ld hl, $dba3
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_76d4

	ld hl, $dbab

jr_051_76d4:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0062
	call Call_51_726A
	call Call_2071
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0082
	call Call_51_726A
	call Call_2071
	ld a, [$c1d9]
	cp $01
	ret z

	ld hl, $dba5
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_7705

	ld hl, $dbad

jr_051_7705:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0068
	call Call_51_726A
	call Call_2071
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0088
	call Call_51_726A
	call Call_2071
	ld a, [$c1d9]
	cp $02
	ret z

	ld hl, $dba7
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_7736

	ld hl, $dbaf

jr_051_7736:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $006e
	call Call_51_726A
	call Call_2071
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $008e
	call Call_51_726A
	call Call_2071
	ret


	db $c7, $76, $f2, $76, $23, $77, $76, $6b, $76, $6b, $1a, $6b, $9a, $6a

Jump_051_7763:
	cp $03
	jp z, Jump_051_786b

	call Call_51_76A7
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
	jr z, jr_051_7785

	ld c, $04

jr_051_7785:
	ld hl, $78ca
	call Call_51_78E2
	push hl
	ld a, c
	call Call_2FA5
	jr nc, jr_051_7796

	ld a, $d9
	jr jr_051_7798

jr_051_7796:
	ld a, $e0

jr_051_7798:
	pop hl
	ld [hl], a
	ld hl, $78d0
	call Call_51_78E2
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
	jr nz, jr_051_7785

	ld a, [$d9f3]
	cp $02
	jr z, jr_051_77e6

	call Call_51_736A
	ld hl, $8da0
	ld a, $02
	call Call_51_7906
	ld hl, $8db0
	ld a, $04
	call Call_51_7906
	ld hl, $8dc0
	ld a, $06
	call Call_51_7906
	ld hl, $8dd0
	ld a, $03
	call Call_51_7906
	ld hl, $d9f3
	inc [hl]

jr_051_77e6:
	ld a, [$c1d9]
	ld b, a
	ld c, $00
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_77f5

	ld c, $04

jr_051_77f5:
	ld hl, $78d0
	call Call_51_78E2
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
	jr c, jr_051_7863

	ld hl, $78d6
	call Call_51_78E2
	push hl
	ld a, c
	ld hl, $db02
	call Call_2F6C
	pop de
	ld a, [hl]
	or a
	jr z, jr_051_7863

	bit 6, [hl]
	jr z, jr_051_7832

	ld a, $00
	call Call_51_78F8

jr_051_7832:
	inc de
	bit 5, [hl]
	jr z, jr_051_783c

	ld a, $01
	call Call_51_78F8

jr_051_783c:
	inc de
	bit 4, [hl]
	jr z, jr_051_7846

	ld a, $02
	call Call_51_78F8

jr_051_7846:
	inc de
	bit 7, [hl]
	jr z, jr_051_7850

	ld a, $03
	call Call_51_78F8

jr_051_7850:
	inc de
	bit 1, [hl]
	jr z, jr_051_785a

	ld a, $04
	call Call_51_78F8

jr_051_785a:
	bit 0, [hl]
	jr z, jr_051_7863

	ld a, $05
	call Call_51_78F8

jr_051_7863:
	inc c
	dec b
	jr nz, jr_051_77f5

	call Call_51_736A
	ret


Jump_051_786b:
	ld a, [$c1d9]
	ld b, a
	ld c, $00
	ld a, [$c863]
	bit 1, a
	jr z, jr_051_787a

	ld c, $04

jr_051_787a:
	ld hl, $78ca
	call Call_51_78E2
	ld a, c
	and $03
	add $da
	ld [hl], a
	ld hl, $78d0
	call Call_51_78E2
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
	call Call_51_7929
	pop hl
	pop de
	pop bc
	pop af
	inc c
	dec b
	jr nz, jr_051_787a

	xor a
	ld [$d9f3], a
	call Call_51_7697
	call Call_51_736A
	ret


	db $25, $00, $2b, $00, $31, $00, $61, $00, $67, $00, $6d, $00, $81, $00, $87, $00
	db $8d, $00, $dc, $d7, $db, $dd, $da, $d8

Call_51_78E2::
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


Call_51_78F8::
	push hl
	ld hl, $78dc
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [de], a
	pop hl
	ret


Call_51_7906::
	push hl
	ld hl, $7919
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

Call_51_7929::
	ld a, [$c86c]
	or a
	jr z, jr_051_794f

	ld a, [$c863]
	bit 1, a
	jr z, jr_051_794f

	ld a, [$db89]
	ld c, a
	cp $04
	jr c, jr_051_7943

	cp $07
	ret z

	jr jr_051_7960

jr_051_7943:
	ld a, [$db88]
	ld c, a
	cp $04
	ret c

	cp $07
	ret z

	jr jr_051_7960

jr_051_794f:
	ld a, [$db89]
	ld c, a
	cp $03
	jr c, jr_051_7962

	ld a, [$db88]
	ld c, a
	cp $03
	jr c, jr_051_7962

	ret


jr_051_7960:
	xor $04

jr_051_7962:
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
	jr c, jr_051_7998

	ld a, c
	ld hl, $db02
	call Call_2F6C
	bit 6, [hl]
	jr nz, jr_051_799c

	bit 5, [hl]
	jr nz, jr_051_79a0

	bit 4, [hl]
	jr nz, jr_051_79a4

	bit 7, [hl]
	jr nz, jr_051_79a8

	bit 1, [hl]
	jr nz, jr_051_79ac

	bit 0, [hl]
	jr nz, jr_051_79b0

	ld a, $00
	jr jr_051_79b2

jr_051_7998:
	ld a, $07
	jr jr_051_79b2

jr_051_799c:
	ld a, $06
	jr jr_051_79b2

jr_051_79a0:
	ld a, $05
	jr jr_051_79b2

jr_051_79a4:
	ld a, $04
	jr jr_051_79b2

jr_051_79a8:
	ld a, $03
	jr jr_051_79b2

jr_051_79ac:
	ld a, $02
	jr jr_051_79b2

jr_051_79b0:
	ld a, $01

jr_051_79b2:
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
	call nz, Call_51_79C9
	pop hl
	call nz, Call_51_7906
	pop de
	ret


Call_51_79C9::
	ld [hl], a
	ret


Call_51_79CB::
	ld a, [$c81d]
	or a
	ret z

	ld a, $01
	ldh [rVBK], a
	ld a, [$d9f8]
	ld l, a
	ld a, [$d9f9]
	ld h, a
	ld c, $12

jr_051_79de:
	ld b, $20
	push hl

jr_051_79e1:
	ld a, $00
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
	dec b
	jr nz, jr_051_79e1

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
	jr nz, jr_051_79de

	ld a, $00
	ldh [rVBK], a
	ret


Call_51_7A0A::
	cp $03
	jr nc, jr_051_7a28

Call_51_7A0E::
	push hl
	ld hl, $cac2
	call Call_2229
	ld e, l
	ld d, h
	pop hl
	push hl
	call Call_0C80
	pop hl

jr_051_7a1d:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_051_7a1d

jr_051_7a24:
	ld a, b
	pop bc
	jr Call_51_7A0E

jr_051_7a28:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_051_7a51

	push bc
	ld b, a
	ld a, [$c86c]
	or a
	jr nz, jr_051_7a24

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
	jr nz, jr_051_7a4e

	ld a, b

jr_051_7a4e:
	pop bc
	jr nz, jr_051_7a79

jr_051_7a51:
	push af
	call Call_51_7A5B
	pop af
	ld hl, far_Call_51_4CB3
	rst $10
	ret


Call_51_7A5B::
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


jr_051_7a79:
	call Call_51_7A0E
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
	jr z, jr_051_7aa5

	cp $02
	jr z, jr_051_7aaf

	ld a, [hli]
	cp [hl]
	jr z, jr_051_7acb

	inc hl
	cp [hl]
	jr z, jr_051_7acb

	jr jr_051_7ada

jr_051_7aa5:
	ld a, [hli]
	cp [hl]
	jr z, jr_051_7ad0

	ld a, [hli]
	cp [hl]
	jr z, jr_051_7acb

	jr jr_051_7ada

jr_051_7aaf:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_051_7ab9

	inc d

jr_051_7ab9:
	inc hl
	cp [hl]
	jr nz, jr_051_7abe

	inc d

jr_051_7abe:
	ld a, d
	or a
	jr z, jr_051_7ada

	cp $01
	jr z, jr_051_7ad0

	pop hl
	ld a, $03
	jr jr_051_7ad3

jr_051_7acb:
	pop hl
	ld a, $01
	jr jr_051_7ad3

jr_051_7ad0:
	pop hl
	ld a, $02

jr_051_7ad3:
	ld [$db4d], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_051_7ada:
	pop hl
	xor a
	ld [$db4d], a
	ret


	db $21, $a0, $c1, $18, $03, $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db
	db $fa, $89, $db, $ea, $50, $db, $cd, $0a, $7a, $c9, $21, $80, $c1, $7d, $ea, $4e
	db $db, $7c, $ea, $4f, $db, $fa, $88, $db, $ea, $50, $db, $cd, $0a, $7a, $c9

Data_51_7B0F::
	db $30, $00, $01, $ff, $82, $01, $00, $07, $7c, $ff, $01, $ff, $f0, $c2, $ff, $a2
	db $ff, $92, $ff, $8a, $ff, $86, $ff, $82, $ff, $00, $ff, $38, $ff, $44, $01, $00
	db $03, $44, $ff, $38, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00
