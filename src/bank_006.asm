INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $006", ROMX[$4000], BANK[$6]

BankNumber_06::
	db $06

FarTable_06::
	dw Call_06_4B1F
	dw $4cbc
	dw $400f
	dw Call_06_4028
	dw Call_06_4D5A
	dw Call_06_4F9A
	dw $6034

	ld a, [$c8eb]
	bit 1, a
	ret nz

	bit 3, a
	ret nz

	bit 4, a
	ret nz

	bit 7, a
	ret nz

	bit 2, a
	jr z, Call_06_4028

	ld a, [$c91e]
	cp $01
	ret z

Call_06_4028::
	ld hl, $d7d2

jr_006_402b:
	ld a, [hl]
	cp $ff
	ret z

	inc hl
	ld a, [hl]
	dec hl
	cp $ff
	push hl
	call nz, Call_06_4043
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_006_402b

Call_06_4043::
	ld a, l
	ldh [$ffd5], a
	ld a, h
	ldh [$ffd6], a
	ld a, [hl]
	bit 6, a
	ret nz

	and $0f
	rst $00

JumpTable_06_4050::
	dw Jump_06_4070
	dw Jump_06_4090
	dw Jump_06_40B1
	dw Jump_06_4122
	dw Jump_06_41A5
	dw Jump_06_4266
	dw Jump_06_42D7
	dw Jump_06_4309
	dw Jump_06_433F
	dw Jump_06_43B0
	dw Jump_06_441F
	dw Jump_06_4070
	dw Jump_06_4070
	dw Jump_06_4070
	dw Jump_06_44C5
	dw Jump_06_4691

Jump_06_4070::
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jr nz, jr_006_408d

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_4a83

	ld a, [$c8a6]
	and $07
	jp nz, Jump_006_4aa1

jr_006_408d:
	jp Jump_006_4a48


Jump_06_4090::
	ld a, [$c8a6]
	and $07
	jp nz, Jump_006_4aa1

	ld a, [$c8a6]
	and $0f
	jr nz, jr_006_40ae

	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $03
	ld [hl], a

jr_006_40ae:
	jp Jump_006_4a48


Jump_06_40B1::
	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_40fd

	ld a, [hld]
	and $01
	xor $01
	add a
	inc a
	dec hl
	ld [hld], a
	bit 6, [hl]
	jp nz, Jump_006_40fd

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_40fd

	set 0, [hl]
	call Call_06_4100
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_40fd

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
	ld [hl], $10

Jump_006_40fd:
jr_006_40fd:
	jp Jump_006_4a48


Call_06_4100::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_410C::
	dw Jump_06_4110
	dw Jump_06_4119

Jump_06_4110::
	ld bc, $0001
	ld de, $0020
	jp Jump_006_49ba


Jump_06_4119::
	ld bc, $ffff
	ld de, $ffe0
	jp Jump_006_49ba


Jump_06_4122::
	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_416a

	ld a, [hld]
	and $03
	dec hl
	ld [hld], a
	bit 6, [hl]
	jp nz, Jump_006_416a

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_416a

	set 0, [hl]
	call Call_06_416D
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_416a

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	dec a
	and $03
	ld [hli], a
	ld [hl], $10

Jump_006_416a:
jr_006_416a:
	jp Jump_006_4a48


Call_06_416D::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_4179::
	dw Jump_06_4181
	dw Jump_06_418A
	dw Jump_06_4193
	dw Jump_06_419C

Jump_06_4181::
	ld bc, $0001
	ld de, $0020
	jp Jump_006_4a01


Jump_06_418A::
	ld bc, $ffff
	ld de, $0000
	jp Jump_006_49ba


Jump_06_4193::
	ld bc, $ffff
	ld de, $0000
	jp Jump_006_4a01


Jump_06_419C::
	ld bc, $0001
	ld de, $0020
	jp Jump_006_49ba


Jump_06_41A5::
	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_41f7

	ld a, [hld]
	and $07
	ld de, $425e
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	dec hl
	ld [hld], a
	bit 6, [hl]
	jp nz, Jump_006_41f7

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_41f7

	set 0, [hl]
	call Call_06_41FA
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_41f7

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $07
	ld [hli], a
	ld [hl], $10

Jump_006_41f7:
jr_006_41f7:
	jp Jump_006_4a48


Call_06_41FA::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_4206::
	dw Jump_06_4216
	dw Jump_06_421F
	dw Jump_06_4228
	dw Jump_06_4231
	dw Jump_06_423A
	dw Jump_06_4243
	dw Jump_06_424C
	dw Jump_06_4255

Jump_06_4216::
	ld bc, $ffff
	ld de, $ffd0
	jp Jump_006_49ba


Jump_06_421F::
	ld bc, $ffff
	ld de, $ffd0
	jp Jump_006_4a01


Jump_06_4228::
	ld bc, $ffff
	ld de, $ffa0
	jp Jump_006_49ba


Jump_06_4231::
	ld bc, $0001
	ld de, $0000
	jp Jump_006_4a01


Jump_06_423A::
	ld bc, $0001
	ld de, $ffd0
	jp Jump_006_49ba


Jump_06_4243::
	ld bc, $ffff
	ld de, $ffd0
	jp Jump_006_4a01


Jump_06_424C::
	ld bc, $0001
	ld de, $0000
	jp Jump_006_49ba


Jump_06_4255::
	ld bc, $0001
	ld de, $0000
	jp Jump_006_4a01


	db $01, $02, $01, $00, $03, $02, $03, $00

Jump_06_4266::
	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_42b2

	ld a, [hld]
	and $01
	xor $01
	add a
	inc a
	dec hl
	ld [hld], a
	bit 6, [hl]
	jp nz, Jump_006_42b2

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_42b2

	set 0, [hl]
	call Call_06_42B5
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_42b2

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
	ld [hl], $10

Jump_006_42b2:
jr_006_42b2:
	jp Jump_006_4a48


Call_06_42B5::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_42C1::
	dw Jump_06_42C5
	dw Jump_06_42CE

Jump_06_42C5::
	ld bc, $0001
	ld de, $0030
	jp Jump_006_49ba


Jump_06_42CE::
	ld bc, $ffff
	ld de, $0000
	jp Jump_006_49ba


Jump_06_42D7::
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jr nz, jr_006_42f4

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_4a83

	ld a, [$c8a6]
	and $07
	jp nz, Jump_006_4aa1

jr_006_42f4:
	ld a, [$d8d7]
	or a
	jr nz, jr_006_4306

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	res 6, [hl]

jr_006_4306:
	jp Jump_006_4a83


Jump_06_4309::
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jr nz, jr_006_433c

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_4a83

	ld a, [$c8a6]
	and $07
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, [hl]
	swap a
	and $03
	push af
	ld a, l
	add $06
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	ld [hl], a

jr_006_433c:
	jp Jump_006_4a48


Jump_06_433F::
	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_438b

	ld a, [hld]
	and $01
	xor $01
	add a
	inc a
	dec hl
	ld [hld], a
	bit 6, [hl]
	jp nz, Jump_006_438b

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_438b

	set 0, [hl]
	call Call_06_438E
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_438b

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
	ld [hl], $10

Jump_006_438b:
jr_006_438b:
	jp Jump_006_4a48


Call_06_438E::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_439A::
	dw Jump_06_439E
	dw Jump_06_43A7

Jump_06_439E::
	ld bc, $0001
	ld de, $0010
	jp Jump_006_49ba


Jump_06_43A7::
	ld bc, $ffff
	ld de, $fff0
	jp Jump_006_49ba


Jump_06_43B0::
	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_43fa

	ld a, [hld]
	and $01
	add a
	inc a
	dec hl
	ld [hld], a
	bit 6, [hl]
	jp nz, Jump_006_43fa

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_43fa

	set 0, [hl]
	call Call_06_43FD
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_43fa

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $01
	ld [hli], a
	ld [hl], $10

Jump_006_43fa:
jr_006_43fa:
	jp Jump_006_4a48


Call_06_43FD::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_4409::
	dw Jump_06_440D
	dw Jump_06_4416

Jump_06_440D::
	ld bc, $ffff
	ld de, $ffe0
	jp Jump_006_49ba


Jump_06_4416::
	ld bc, $0001
	ld de, $0020
	jp Jump_006_49ba


Jump_06_441F::
	ld a, [$c8a6]
	and $07
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	or a
	jp nz, Jump_006_446a

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jp nz, Jump_006_446a

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_446a

	set 0, [hl]
	call Call_06_446D
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	ld a, c
	or b
	jr nz, jr_006_446a

	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	inc a
	and $01
	ld [hld], a

Jump_006_446a:
jr_006_446a:
	jp Jump_006_4a48


Call_06_446D::
	ldh a, [$ffd5]
	add $08
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	rst $00

JumpTable_06_4479::
	dw Jump_06_447D
	dw Jump_06_4486

Jump_06_447D::
	ld bc, $0001
	ld de, $0010
	jp Jump_006_448f


Jump_06_4486::
	ld bc, $ffff
	ld de, $fff0
	jp Jump_006_448f


Jump_006_448f:
	ld a, [$c8eb]
	bit 0, a
	ret nz

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld b, a
	ldh a, [$ffd5]
	add $02
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ret


Jump_06_44C5::
	ld a, [$c925]
	ld b, a
	ld a, [$c926]
	cp b
	ret nz

	ld a, [$c8eb]
	bit 2, a
	ret nz

	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	or a
	jp nz, Jump_006_4540

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jp nz, Jump_006_4540

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_4540

	set 0, [hl]
	call Call_06_4543
	cp $00
	jr z, jr_006_4540

	cp $02
	jr z, jr_006_4524

	call Call_06_457D
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $04
	ld a, [$c899]
	and $c0
	jr nz, jr_006_4540

jr_006_4524:
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $04
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [$c899]
	and $03
	ld [hl], a

Jump_006_4540:
jr_006_4540:
	jp Jump_006_4a48


Call_06_4543::
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $03
	rst $00

JumpTable_06_4551::
	dw Jump_06_4559
	dw Jump_06_4562
	dw Jump_06_456B
	dw Jump_06_4574

Jump_06_4559::
	ld bc, $0001
	ld de, $0010
	jp Jump_006_4874


Jump_06_4562::
	ld bc, $ffff
	ld de, $fff0
	jp Jump_006_472e


Jump_06_456B::
	ld bc, $ffff
	ld de, $fff0
	jp Jump_006_4874


Jump_06_4574::
	ld bc, $0001
	ld de, $0010
	jp Jump_006_472e


Call_06_457D::
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $0010
	ldh a, [$ff92]
	ld e, a
	ldh a, [$ff93]
	ld d, a
	call Call_06_467C
	jr nz, jr_006_45ae

	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $0000
	ldh a, [$ff95]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	call Call_06_467C
	jp z, Jump_006_463f

jr_006_45ae:
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $fff0
	ldh a, [$ff92]
	ld e, a
	ldh a, [$ff93]
	ld d, a
	call Call_06_467C
	jr nz, jr_006_45de

	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $0000
	ldh a, [$ff95]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	call Call_06_467C
	jr z, jr_006_463f

jr_006_45de:
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $0000
	ldh a, [$ff92]
	ld e, a
	ldh a, [$ff93]
	ld d, a
	call Call_06_467C
	jr nz, jr_006_460e

	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $0010
	ldh a, [$ff95]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	call Call_06_467C
	jr z, jr_006_463f

jr_006_460e:
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $0000
	ldh a, [$ff92]
	ld e, a
	ldh a, [$ff93]
	ld d, a
	call Call_06_467C
	jr nz, jr_006_463e

	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld bc, $fff0
	ldh a, [$ff95]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	call Call_06_467C
	jr z, jr_006_463f

jr_006_463e:
	ret


Jump_006_463f:
jr_006_463f:
	ldh a, [$ffd5]
	add $04
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld [$d8d4], a
	ld a, $70
	ld [$d8d3], a
	set 6, [hl]
	xor a
	ld [$d8d7], a
	ld hl, far_Call_04_55EC
	rst $10
	ld a, [$d8d7]
	or a
	ret z

	bit 1, a
	ret z

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


Call_06_467C::
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc
	ld a, l
	and $f0
	or $08
	ld l, a
	ld a, e
	and $f0
	or $08
	cp l
	ret nz

	ld a, d
	cp h
	ret nz

	ret


Jump_06_4691::
	ld a, [$c925]
	ld b, a
	ld a, [$c926]
	cp b
	ret nz

	ld a, [$c8eb]
	bit 2, a
	ret nz

	ld a, [$c8a6]
	and $01
	jp nz, Jump_006_4aa1

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	or a
	jp nz, Jump_006_46f1

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jp nz, Jump_006_46f1

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_46f1

	set 0, [hl]
	call Call_06_46F4
	cp $00
	jr z, jr_006_46f1

	cp $02
	jr z, jr_006_46e1

	ld a, [$c899]
	and $c0
	jr nz, jr_006_46f1

jr_006_46e1:
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [$c899]
	and $03
	ld [hl], a

Jump_006_46f1:
jr_006_46f1:
	jp Jump_006_4a48


Call_06_46F4::
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $03
	rst $00

JumpTable_06_4702::
	dw Jump_06_470A
	dw Jump_06_4713
	dw Jump_06_471C
	dw Jump_06_4725

Jump_06_470A::
	ld bc, $0001
	ld de, $0010
	jp Jump_006_4874


Jump_06_4713::
	ld bc, $ffff
	ld de, $fff0
	jp Jump_006_472e


Jump_06_471C::
	ld bc, $ffff
	ld de, $fff0
	jp Jump_006_4874


Jump_06_4725::
	ld bc, $0001
	ld de, $0010
	jp Jump_006_472e


Jump_006_472e:
	ld a, [$c8eb]
	bit 0, a
	ret nz

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $0f
	cp $08
	jr nz, jr_006_47bd

	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, l
	ldh [$ffa5], a
	ld a, h
	ldh [$ffa6], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	push bc
	call Call_1E31
	ldh a, [$ffaa]
	push af
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	pop af
	pop bc
	srl a
	srl a
	cp $0c
	jr z, jr_006_47bd

	cp $0d
	jr z, jr_006_47bd

	cp $0e
	jr z, jr_006_47bd

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $08
	ld a, $02
	ret


jr_006_47bd:
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, e
	add c
	ld e, a
	ld a, d
	adc b
	ld d, a
	ldh a, [$ffd5]
	add $02
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld a, d
	or a
	jr nz, jr_006_47f6

	ld a, e
	cp $70
	jr c, jr_006_4825

jr_006_47f6:
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $08
	ld a, $02
	ret


jr_006_4825:
	push hl
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld b, a
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	and $0f
	ld a, $00
	ret nz

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $10
	ld a, $01
	ret


Jump_006_4874:
	ld a, [$c8eb]
	bit 0, a
	ret nz

	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $0f
	cp $08
	jr nz, jr_006_4903

	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, l
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	ldh [$ffa5], a
	ld a, h
	ldh [$ffa6], a
	push bc
	call Call_1E31
	ldh a, [$ffaa]
	push af
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	pop af
	pop bc
	srl a
	srl a
	cp $0c
	jr z, jr_006_4903

	cp $0d
	jr z, jr_006_4903

	cp $0e
	jr z, jr_006_4903

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $08
	ld a, $02
	ret


jr_006_4903:
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, e
	add c
	ld e, a
	ld a, d
	adc b
	ld d, a
	ldh a, [$ffd5]
	add $03
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld a, d
	or a
	jr nz, jr_006_493c

	ld a, e
	cp $50
	jr c, jr_006_496b

jr_006_493c:
	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $08
	ld a, $02
	ret


jr_006_496b:
	push hl
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld b, a
	pop hl
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	and $0f
	ld a, $00
	ret nz

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	and $f0
	or $08
	ld [hl], a
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $10
	ld a, $01
	ret


Jump_006_49ba:
	ld a, [$c8eb]
	bit 0, a
	ret nz

	ldh a, [$ffd5]
	add $18
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld b, a
	ldh a, [$ffd5]
	add $02
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	and $0f
	jr nz, jr_006_4a00

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $10

jr_006_4a00:
	ret


Jump_006_4a01:
	ld a, [$c8eb]
	bit 0, a
	ret nz

	ldh a, [$ffd5]
	add $1a
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld b, a
	ldh a, [$ffd5]
	add $03
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
	and $0f
	ld h, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, c
	and $0f
	jr nz, jr_006_4a47

	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld [hl], $10

jr_006_4a47:
	ret


Jump_006_4a48:
	ldh a, [$ffd5]
	add $07
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_006_4a5b

	dec [hl]
	dec hl
	dec hl
	res 0, [hl]

jr_006_4a5b:
	ld a, [$d8d7]
	or a
	jr nz, jr_006_4a6d

	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	res 6, [hl]

jr_006_4a6d:
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 6, [hl]
	jr z, jr_006_4a83

	ldh a, [$ff8e]
	add $02
	and $03
	inc hl
	ld [hl], a

Jump_006_4a83:
jr_006_4a83:
	ldh a, [$ffd5]
	add $06
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	ld a, [hl]
	ld de, $4b1b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, l
	add $11
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [de]
	ld [hl], a

Jump_006_4aa1:
	ldh a, [$ffd5]
	add $05
	ld l, a
	ldh a, [$ffd6]
	adc $00
	ld h, a
	bit 7, [hl]
	ret nz

	ld b, $06
	bit 6, [hl]
	jr nz, jr_006_4abc

	ld b, $03
	bit 0, [hl]
	jr nz, jr_006_4abc

	ld b, $00

jr_006_4abc:
	inc hl
	ld a, [hl]
	ld de, $4b17
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add b
	ld b, a
	ld a, l
	add $0a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [$d7b4], a
	ld a, h
	ld [$d7b5], a
	inc hl
	inc hl
	ld a, [hl]
	cp b
	jr nz, jr_006_4ae8

	ld a, [$c8eb]
	bit 0, a
	jr z, jr_006_4af7

	ret


jr_006_4ae8:
	ld [hl], b
	xor a
	inc hl
	ld [hli], a
	ld [hli], a
	ld a, [$d7b4]
	ld l, a
	ld a, [$d7b5]
	ld h, a
	ld [hl], $00

jr_006_4af7:
	ld a, [$d7b4]
	ld l, a
	ld a, [$d7b5]
	ld h, a
	dec hl
	ld a, [hli]
	or a
	jr nz, jr_006_4b09

	ld hl, far_Call_02_400D
	rst $10
	ret


jr_006_4b09:
	inc hl
	ld a, [hl]
	push af
	push hl
	ld [hl], $00
	ld hl, far_Call_02_400D
	rst $10
	pop hl
	pop af
	ld [hl], a
	ret


	db $00, $01, $02, $01, $00, $20, $00, $00

Call_06_4B1F::
	ld hl, $ff90
	res 5, [hl]
	ld hl, $d7d2

jr_006_4b27:
	ld a, [hl]
	cp $ff
	jr z, jr_006_4b40

	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	res 5, [hl]
	ld a, l
	add $1b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_006_4b27

jr_006_4b40:
	ld a, [$d8d7]
	or a
	ret nz

	ld hl, $ffdb
	ldh a, [$ff92]
	ld [hli], a
	ldh a, [$ff93]
	ld [hli], a
	ldh a, [$ff95]
	ld [hli], a
	ldh a, [$ff96]
	ld [hli], a
	call Call_06_4B58
	ret


Call_06_4B58::
	ldh a, [$ffdb]
	and $0f
	cp $08
	jr nz, jr_006_4b6c

	ldh a, [$ffdd]
	and $0f
	cp $08
	jr nz, jr_006_4b89

	call Call_06_4BA6
	ret


jr_006_4b6c:
	ld hl, $ffdb
	ld a, [hl]
	add $08
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hl], a
	call Call_06_4BA6
	ld hl, $ffdb
	ld a, [hl]
	sub $10
	ld [hli], a
	ld a, [hl]
	sbc $00
	ld [hl], a
	call Call_06_4BA6
	ret


jr_006_4b89:
	ld hl, $ffdd
	ld a, [hl]
	add $08
	ld [hli], a
	ld a, [hl]
	adc $00
	ld [hl], a
	call Call_06_4BA6
	ld hl, $ffdd
	ld a, [hl]
	sub $10
	ld [hli], a
	ld a, [hl]
	sbc $00
	ld [hl], a
	call Call_06_4BA6
	ret


Call_06_4BA6::
	ldh a, [$ffdb]
	ld l, a
	ldh a, [$ffdc]
	ld h, a
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ldh [$ffd5], a
	ldh a, [$ffdd]
	ld l, a
	ldh a, [$ffde]
	ld h, a
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ldh [$ffd6], a
	ld d, $00
	ld hl, $d7d2

jr_006_4bd3:
	ld a, [hl]
	cp $ff
	ret z

	bit 6, a
	jr nz, jr_006_4be4

	inc hl
	ld a, [hld]
	cp $4d
	jr z, jr_006_4be4

	call Call_06_4BF0

jr_006_4be4:
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc d
	jr jr_006_4bd3

	db $c9

Call_06_4BF0::
	push hl
	push bc
	push de
	ld a, l
	add $18
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, e
	and $0f
	cp $08
	jr nz, jr_006_4c17

	ld a, l
	and $0f
	cp $08
	jr nz, jr_006_4c37

	call Call_06_4C72
	jr nz, jr_006_4c6e

	jr jr_006_4c55

jr_006_4c17:
	push hl
	push de
	ld a, e
	add $08
	ld e, a
	ld a, d
	adc $00
	ld d, a
	call Call_06_4C72
	pop de
	pop hl
	jr z, jr_006_4c55

	ld a, e
	add $f8
	ld e, a
	ld a, d
	adc $ff
	ld d, a
	call Call_06_4C72
	jr nz, jr_006_4c6e

	jr jr_006_4c55

jr_006_4c37:
	push hl
	push de
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
	call Call_06_4C72
	pop de
	pop hl
	jr z, jr_006_4c55

	ld a, l
	add $f8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	call Call_06_4C72
	jr nz, jr_006_4c6e

jr_006_4c55:
	ld hl, $ff90
	set 5, [hl]
	pop de
	ld a, d
	ld [$d7bd], a
	pop bc
	pop hl
	push hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	set 5, [hl]
	pop hl
	ret


jr_006_4c6e:
	pop de
	pop bc
	pop hl
	ret


Call_06_4C72::
	swap d
	swap e
	ld a, d
	and $f0
	ld d, a
	ld a, e
	and $0f
	or d
	ld b, a
	ldh a, [$ffd5]
	cp b
	ret nz

	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ld c, a
	ldh a, [$ffd6]
	cp c
	ret


	db $fa, $37, $ca, $90, $30, $02, $c6, $31, $6f, $26, $00, $29, $29, $7d, $c6, $73
	db $6f, $7c, $ce, $c9, $67, $2a, $e0, $db, $2a, $e0, $dd, $7e, $cb, $37, $e6, $0f
	db $e0, $dc, $7e, $e6, $0f, $e0, $de, $c9

	ld a, [$c8ec]
	or a
	ret nz

	ld a, [$c8eb]
	bit 1, a
	ret nz

	bit 3, a
	ret nz

	bit 7, a
	ret nz

	bit 4, a
	jr z, jr_006_4cd7

	ld a, [$c8ef]
	cp $0f
	ret z

jr_006_4cd7:
	ld a, [$c8eb]
	bit 2, a
	jr z, jr_006_4cea

	ld a, [$c969]
	or a
	jr nz, jr_006_4cea

	ld a, [$c91e]
	cp $01
	ret z

jr_006_4cea:
	ld de, $d7d2

jr_006_4ced:
	ld a, [de]
	cp $ff
	ret z

	bit 6, a
	jr nz, jr_006_4cff

	inc de
	ld a, [de]
	dec de
	cp $ff
	push de
	call nz, Call_06_4D0A
	pop de

jr_006_4cff:
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
	jr jr_006_4ced

	db $c9

Call_06_4D0A::
	push bc
	push de
	ld a, e
	add $18
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld hl, $ffc3
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	inc de
	add $08
	ld [hli], a
	ld a, [de]
	inc de
	adc $00
	ld [hli], a
	pop de
	ld a, e
	add $11
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	ld [hli], a
	inc de
	inc de
	inc de
	ld a, [de]
	cp $ff
	jr z, jr_006_4d58

	ld [hli], a
	inc de
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, e
	add $f8
	ld e, a
	ld a, d
	adc $ff
	ld d, a
	ld a, [de]
	or a
	jr nz, jr_006_4d54

	ld hl, far_Call_05_4005
	rst $10
	jr jr_006_4d58

jr_006_4d54:
	ld hl, far_Call_04_4081
	rst $10

jr_006_4d58:
	pop bc
	ret


Call_06_4D5A::
	ld hl, $d7be
	ld b, $06
	ld c, $00

jr_006_4d61:
	ld a, [hl]
	cp $ff
	ret z

	push hl
	push bc
	ld b, a
	inc hl
	ld a, [hl]
	or a
	jr nz, jr_006_4d7a

	ld hl, $2adf
	ld a, b
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	jr jr_006_4d86

jr_006_4d7a:
	ld l, b
	ld h, $00
	add hl, hl
	ld a, l
	add $cc
	ld l, a
	ld a, h
	adc $4d
	ld h, a

jr_006_4d86:
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, c
	add $80
	ld h, a
	ld a, [$c969]
	or a
	jr z, jr_006_4d99

	ld a, h
	add $07
	ld h, a
	jr jr_006_4dae

jr_006_4d99:
	ld a, [$c968]
	cp $08
	jr z, jr_006_4dae

	cp $45
	jr nz, jr_006_4daa

	ld a, h
	add $02
	ld h, a
	jr jr_006_4dae

jr_006_4daa:
	ld a, h
	add $05
	ld h, a

jr_006_4dae:
	ld h, a
	ld l, $00
	call Call_1577
	pop bc
	pop hl
	ld a, [hl]
	cp $55
	jr z, jr_006_4dbf

	cp $15
	jr nz, jr_006_4dc5

jr_006_4dbf:
	inc hl
	ld a, [hld]
	or a
	jr nz, jr_006_4dc5

	inc c

jr_006_4dc5:
	inc hl
	inc hl
	inc c
	dec b
	jr nz, jr_006_4d61

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

Call_06_4F9A::
	ld a, [$cac0]
	ld hl, $cb0c
	call Call_223B
	ld e, l
	ld d, h
	ld hl, $50e0
	ld c, $00

Jump_006_4faa:
	push de
	push hl
	push bc
	push de
	call Call_06_50D2
	pop de
	jp z, Jump_006_507c

	ld a, [de]
	inc a
	cp [hl]
	jp c, Jump_006_507c

	ld a, e
	add $07
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	jp c, Jump_006_507c

	ld a, e
	add $03
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	jp c, Jump_006_507c

	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	jp c, Jump_006_507c

	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	jr c, jr_006_507c

	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	jr c, jr_006_507c

	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	ld a, [de]
	sub [hl]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	jr c, jr_006_507c

	ld a, e
	add $d2
	ld e, a
	ld a, d
	adc $ff
	ld d, a
	pop bc
	push bc
	push de
	ld b, $19

jr_006_5031:
	ld a, [de]
	cp c
	jr z, jr_006_5097

	inc de
	dec b
	jr nz, jr_006_5031

	pop de
	ld a, e
	add $f8
	ld e, a
	ld a, d
	adc $ff
	ld d, a
	inc hl
	ld a, [hl]
	cp $ff
	jr z, jr_006_507c

	call Call_06_50C0
	jr nz, jr_006_507c

	ld a, [hl]
	cp $ff
	jp z, Jump_006_50a6

	call Call_06_50C0
	jr nz, jr_006_507c

	ld a, [hl]
	cp $ff
	jp z, Jump_006_50b5

	call Call_06_50C0
	jr nz, jr_006_507c

	ld a, [hl]
	cp $ff
	jp z, Jump_006_50b5

	call Call_06_50C0
	jr nz, jr_006_507c

	ld a, [hl]
	cp $ff
	jp z, Jump_006_50b5

	call Call_06_50C0
	jr nz, jr_006_507c

	jp Jump_006_50b5


Jump_006_507c:
jr_006_507c:
	pop bc
	pop hl
	pop de
	ld a, l
	add $12
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc c
	ld a, c
	cp $da
	jp nz, Jump_006_4faa

	ld a, $ff
	ldh [$ffd8], a
	ld a, $ff
	ldh [$ffd9], a
	ret


jr_006_5097:
	ld a, $ff
	ld [de], a
	pop de
	pop bc
	pop hl
	pop de
	ld a, c
	ldh [$ffd8], a
	ld a, $00
	ldh [$ffd9], a
	ret


Jump_006_50a6:
	dec hl
	ld a, [hl]
	ldh [$ffda], a
	pop bc
	pop hl
	pop de
	ld a, c
	ldh [$ffd8], a
	ld a, $01
	ldh [$ffd9], a
	ret


Jump_006_50b5:
	pop bc
	pop hl
	pop de
	ld a, c
	ldh [$ffd8], a
	ld a, $02
	ldh [$ffd9], a
	ret


Call_06_50C0::
	push de
	call Call_06_50C7
	pop de
	inc hl
	ret


Call_06_50C7::
	ld b, $08

jr_006_50c9:
	ld a, [de]
	cp [hl]
	ret z

	inc de
	dec b
	jr nz, jr_006_50c9

	inc b
	ret


Call_06_50D2::
	ld de, $c0d8
	ld b, $28

jr_006_50d7:
	ld a, [de]
	cp c
	ret z

	inc de
	dec b
	jr nz, jr_006_50d7

	inc b
	ret


	db $01, $00, $00, $07, $00, $00, $00, $00, $00, $00, $00, $14, $00, $ff, $ff, $ff
	db $ff, $ff, $0d, $00, $00, $2e, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00
	db $ff, $ff, $ff, $ff, $1c, $00, $00, $70, $00, $00, $00, $00, $00, $00, $00, $92
	db $00, $01, $ff, $ff, $ff, $ff, $03, $00, $00, $0b, $00, $00, $00, $00, $00, $00
	db $00, $17, $00, $ff, $ff, $ff, $ff, $ff, $0a, $00, $00, $22, $00, $00, $00, $00
	db $00, $00, $00, $34, $00, $03, $ff, $ff, $ff, $ff, $1a, $00, $00, $60, $00, $00
	db $00, $00, $00, $00, $00, $7a, $00, $04, $ff, $ff, $ff, $ff, $04, $00, $00, $0d
	db $00, $00, $00, $00, $00, $00, $00, $1a, $00, $ff, $ff, $ff, $ff, $ff, $0e, $00
	db $00, $32, $00, $00, $00, $00, $00, $00, $00, $44, $00, $06, $ff, $ff, $ff, $ff
	db $1d, $00, $00, $78, $00, $00, $00, $00, $00, $00, $00, $9e, $00, $07, $ff, $ff
	db $ff, $ff, $02, $00, $00, $0a, $00, $00, $00, $00, $00, $00, $00, $15, $00, $ff
	db $ff, $ff, $ff, $ff, $0b, $00, $00, $26, $00, $00, $00, $00, $00, $00, $00, $38
	db $00, $09, $ff, $ff, $ff, $ff, $1b, $00, $00, $68, $00, $00, $00, $00, $00, $00
	db $00, $86, $00, $0a, $ff, $ff, $ff, $ff, $05, $00, $00, $10, $00, $00, $00, $00
	db $00, $00, $00, $1e, $00, $ff, $ff, $ff, $ff, $ff, $0c, $00, $00, $2a, $00, $00
	db $00, $00, $00, $00, $00, $3c, $00, $0c, $ff, $ff, $ff, $ff, $19, $00, $00, $58
	db $00, $00, $00, $00, $00, $00, $00, $6e, $00, $0d, $ff, $ff, $ff, $ff, $06, $00
	db $00, $14, $00, $00, $00, $00, $00, $00, $00, $23, $00, $ff, $ff, $ff, $ff, $ff
	db $0f, $00, $00, $36, $00, $00, $00, $00, $00, $00, $00, $48, $00, $0f, $ff, $ff
	db $ff, $ff, $1e, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $aa, $00, $10
	db $ff, $ff, $ff, $ff, $10, $00, $00, $3a, $00, $00, $00, $00, $00, $00, $00, $4c
	db $00, $ff, $ff, $ff, $ff, $ff, $18, $00, $00, $50, $00, $00, $00, $00, $00, $00
	db $00, $62, $00, $12, $ff, $ff, $ff, $ff, $01, $00, $00, $07, $00, $00, $00, $00
	db $00, $00, $00, $06, $00, $ff, $ff, $ff, $ff, $ff, $04, $00, $00, $18, $00, $00
	db $00, $00, $00, $00, $00, $10, $00, $ff, $ff, $ff, $ff, $ff, $0b, $00, $00, $34
	db $00, $00, $00, $00, $00, $00, $00, $2e, $00, $15, $ff, $ff, $ff, $ff, $09, $00
	db $00, $2c, $00, $00, $00, $00, $00, $00, $00, $26, $00, $ff, $ff, $ff, $ff, $ff
	db $0a, $00, $00, $2f, $00, $00, $00, $00, $00, $00, $00, $29, $00, $ff, $ff, $ff
	db $ff, $ff, $0c, $00, $00, $38, $00, $00, $00, $00, $00, $00, $00, $31, $00, $ff
	db $ff, $ff, $ff, $ff, $07, $00, $00, $20, $00, $00, $00, $00, $00, $00, $00, $1c
	db $00, $ff, $ff, $ff, $ff, $ff, $0d, $00, $00, $3a, $00, $00, $00, $00, $00, $00
	db $00, $34, $00, $1a, $ff, $ff, $ff, $ff, $04, $00, $00, $12, $00, $00, $00, $00
	db $00, $00, $00, $0f, $00, $ff, $ff, $ff, $ff, $ff, $08, $00, $00, $24, $00, $00
	db $00, $00, $00, $00, $00, $20, $00, $1c, $ff, $ff, $ff, $ff, $02, $00, $00, $0e
	db $00, $00, $00, $00, $00, $00, $00, $0c, $00, $ff, $ff, $ff, $ff, $ff, $06, $00
	db $00, $1b, $00, $00, $00, $00, $00, $00, $00, $18, $00, $1e, $ff, $ff, $ff, $ff
	db $03, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $0e, $00, $ff, $ff, $ff
	db $ff, $ff, $07, $00, $00, $20, $00, $00, $00, $00, $00, $00, $00, $1c, $00, $20
	db $ff, $ff, $ff, $ff, $01, $00, $00, $0a, $00, $00, $00, $00, $00, $00, $00, $08
	db $00, $ff, $ff, $ff, $ff, $ff, $05, $00, $00, $18, $00, $00, $00, $00, $00, $00
	db $00, $14, $00, $22, $ff, $ff, $ff, $ff, $12, $00, $00, $4c, $00, $00, $00, $00
	db $00, $00, $00, $46, $00, $ff, $ff, $ff, $ff, $ff, $11, $00, $00, $48, $00, $00
	db $00, $00, $00, $00, $00, $42, $00, $ff, $ff, $ff, $ff, $ff, $13, $00, $00, $50
	db $00, $00, $00, $00, $00, $00, $00, $4a, $00, $ff, $ff, $ff, $ff, $ff, $10, $00
	db $00, $44, $00, $00, $00, $00, $00, $00, $00, $3e, $00, $ff, $ff, $ff, $ff, $ff
	db $14, $00, $00, $54, $00, $00, $00, $00, $00, $00, $00, $4e, $00, $27, $ff, $ff
	db $ff, $ff, $15, $00, $00, $5c, $00, $00, $00, $00, $00, $00, $00, $58, $00, $ff
	db $ff, $ff, $ff, $ff, $0f, $00, $00, $3e, $00, $00, $00, $00, $00, $00, $00, $3a
	db $00, $ff, $ff, $ff, $ff, $ff, $01, $00, $00, $07, $00, $00, $00, $00, $00, $00
	db $00, $06, $00, $ff, $ff, $ff, $ff, $ff, $0a, $00, $00, $34, $00, $00, $00, $00
	db $00, $00, $00, $30, $00, $2b, $ff, $ff, $ff, $ff, $10, $00, $00, $52, $00, $00
	db $00, $00, $00, $00, $00, $50, $00, $2c, $ff, $ff, $ff, $ff, $14, $00, $00, $8c
	db $00, $00, $00, $00, $00, $00, $00, $78, $00, $ff, $ff, $ff, $ff, $ff, $1c, $00
	db $00, $c4, $00, $00, $00, $00, $00, $00, $00, $a0, $00, $2e, $ff, $ff, $ff, $ff
	db $0e, $00, $00, $3f, $00, $00, $00, $00, $00, $00, $00, $36, $00, $ff, $ff, $ff
	db $ff, $ff, $1b, $00, $00, $ae, $00, $00, $00, $00, $00, $00, $00, $98, $00, $30
	db $ff, $ff, $ff, $ff, $20, $00, $00, $bc, $00, $00, $00, $00, $00, $00, $00, $b0
	db $00, $14, $31, $ff, $ff, $ff, $05, $00, $00, $15, $00, $00, $00, $00, $00, $00
	db $00, $14, $00, $ff, $ff, $ff, $ff, $ff, $08, $00, $00, $1e, $00, $00, $00, $00
	db $00, $00, $00, $1a, $00, $ff, $ff, $ff, $ff, $ff, $06, $00, $00, $18, $00, $00
	db $00, $00, $00, $00, $00, $16, $00, $ff, $ff, $ff, $ff, $ff, $07, $00, $00, $1b
	db $00, $00, $00, $00, $00, $00, $00, $18, $00, $ff, $ff, $ff, $ff, $ff, $0a, $00
	db $00, $28, $00, $00, $00, $00, $00, $00, $00, $22, $00, $ff, $ff, $ff, $ff, $ff
	db $0a, $00, $00, $28, $00, $00, $00, $00, $00, $00, $00, $22, $00, $ff, $ff, $ff
	db $ff, $ff, $28, $00, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $ec, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $08, $50, $00, $00, $00, $50, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0c, $46, $00, $00, $00, $00, $00, $00
	db $00, $46, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0e, $62, $00, $00, $00, $54
	db $00, $54, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $12, $7e, $00, $00
	db $00, $6c, $00, $6c, $00, $00, $00, $00, $00, $3c, $41, $ff, $ff, $ff, $0c, $54
	db $00, $00, $00, $48, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $0f, $6a, $00, $00, $00, $5a, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $0e, $62, $00, $00, $00, $00, $00, $54, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $14, $8c, $00, $00, $00, $78, $00, $00, $00, $78, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $11, $77, $00, $00, $00, $00, $00, $66, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0b, $4d, $00, $22, $00, $42, $00, $00
	db $00, $00, $00, $2a, $00, $41, $01, $ff, $ff, $ff, $0b, $4d, $00, $22, $00, $42
	db $00, $00, $00, $00, $00, $2a, $00, $41, $5a, $ff, $ff, $ff, $0b, $4d, $00, $22
	db $00, $42, $00, $00, $00, $00, $00, $2a, $00, $41, $58, $ff, $ff, $ff, $0b, $4d
	db $00, $22, $00, $42, $00, $00, $00, $00, $00, $2a, $00, $41, $0d, $ff, $ff, $ff
	db $0c, $44, $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $0c, $44, $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $0c, $3e, $00, $00, $00, $44, $00, $00, $00, $48, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $0c, $3e, $00, $00, $00, $44, $00, $00, $00, $48
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0c, $40, $00, $00, $00, $3a, $00, $00
	db $00, $3e, $00, $30, $00, $ff, $ff, $ff, $ff, $ff, $0c, $40, $00, $00, $00, $3a
	db $00, $00, $00, $3e, $00, $30, $00, $ff, $ff, $ff, $ff, $ff, $0c, $44, $00, $00
	db $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $1c, $9a
	db $00, $8c, $00, $a8, $00, $00, $00, $a8, $00, $94, $00, $4d, $59, $ff, $ff, $ff
	db $13, $62, $00, $00, $00, $58, $00, $00, $00, $70, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $18, $7c, $00, $00, $00, $70, $00, $00, $00, $88, $00, $00, $00, $50
	db $ff, $ff, $ff, $ff, $11, $54, $00, $2a, $00, $00, $00, $00, $00, $44, $00, $36
	db $00, $ff, $ff, $ff, $ff, $ff, $17, $80, $00, $40, $00, $00, $00, $00, $00, $52
	db $00, $4a, $00, $52, $ff, $ff, $ff, $ff, $12, $7e, $00, $00, $00, $00, $00, $6c
	db $00, $6c, $00, $6c, $00, $41, $43, $93, $ff, $ff, $0c, $48, $00, $00, $00, $44
	db $00, $00, $00, $52, $00, $00, $00, $23, $41, $ff, $ff, $ff, $0c, $48, $00, $00
	db $00, $52, $00, $44, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0f, $5c
	db $00, $00, $00, $5a, $00, $00, $00, $60, $00, $00, $00, $50, $55, $ff, $ff, $ff
	db $0d, $4a, $00, $00, $00, $3c, $00, $00, $00, $54, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $13, $70, $00, $00, $00, $72, $00, $00, $00, $84, $00, $00, $00, $58
	db $ff, $ff, $ff, $ff, $0a, $41, $00, $00, $00, $5a, $00, $00, $00, $34, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $10, $7c, $00, $00, $00, $66, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $03, $15, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0a, $46, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $5c, $ff, $ff, $ff, $ff, $14, $8c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $5d, $ff, $ff, $ff, $ff, $1e, $d2
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5e, $ff, $ff, $ff, $ff
	db $03, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $0a, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60
	db $ff, $ff, $ff, $ff, $14, $8c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $61, $ff, $ff, $ff, $ff, $1e, $d2, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $62, $ff, $ff, $ff, $ff, $22, $b8, $00, $b8, $00, $00, $00, $00
	db $00, $00, $00, $c4, $00, $11, $5a, $ff, $ff, $ff, $24, $c4, $00, $c4, $00, $00
	db $00, $00, $00, $00, $00, $d0, $00, $08, $5f, $63, $ff, $ff, $26, $00, $00, $d2
	db $00, $00, $00, $00, $00, $00, $00, $e0, $00, $02, $05, $08, $0b, $0e, $05, $23
	db $00, $00, $00, $1e, $00, $00, $00, $00, $00, $1e, $00, $ff, $ff, $ff, $ff, $ff
	db $07, $31, $00, $00, $00, $2a, $00, $00, $00, $00, $00, $2a, $00, $ff, $ff, $ff
	db $ff, $ff, $09, $3f, $00, $00, $00, $36, $00, $00, $00, $00, $00, $36, $00, $67
	db $68, $ff, $ff, $ff, $0a, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3c
	db $00, $ff, $ff, $ff, $ff, $ff, $10, $70, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $60, $00, $6a, $6d, $ff, $ff, $ff, $09, $3f, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $36, $00, $ff, $ff, $ff, $ff, $ff, $0e, $62, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $54, $00, $6c, $ff, $ff, $ff, $ff, $0d, $4a, $00, $00
	db $00, $00, $00, $00, $00, $4e, $00, $4e, $00, $ff, $ff, $ff, $ff, $ff, $0f, $00
	db $00, $41, $00, $00, $00, $00, $00, $52, $00, $52, $00, $ff, $ff, $ff, $ff, $ff
	db $0a, $00, $00, $00, $00, $3c, $00, $00, $00, $3c, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $14, $8c, $00, $48, $00, $00, $00, $00, $00, $78, $00, $78, $00, $6f
	db $78, $ff, $ff, $ff, $0a, $46, $00, $00, $00, $00, $00, $00, $00, $46, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $0c, $00, $00, $2a, $00, $00, $00, $00, $00, $48
	db $00, $48, $00, $ff, $ff, $ff, $ff, $ff, $0e, $00, $00, $41, $00, $00, $00, $00
	db $00, $54, $00, $54, $00, $6f, $73, $ff, $ff, $ff, $0a, $36, $00, $1b, $00, $00
	db $00, $00, $00, $3f, $00, $31, $00, $ff, $ff, $ff, $ff, $ff, $0c, $44, $00, $27
	db $00, $00, $00, $00, $00, $55, $00, $3d, $00, $75, $ff, $ff, $ff, $ff, $09, $3f
	db $00, $00, $00, $00, $00, $00, $00, $36, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $0e, $54, $00, $00, $00, $00, $00, $00, $00, $62, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $07, $37, $00, $00, $00, $00, $00, $00, $00, $43, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $0d, $51, $00, $00, $00, $00, $00, $00, $00, $5e, $00, $00
	db $00, $79, $ff, $ff, $ff, $ff, $06, $20, $00, $00, $00, $1f, $00, $00, $00, $30
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0c, $42, $00, $00, $00, $3f, $00, $00
	db $00, $4d, $00, $00, $00, $7b, $ff, $ff, $ff, $ff, $0e, $78, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $04, $00, $00, $1c
	db $00, $00, $00, $00, $00, $00, $00, $18, $00, $ff, $ff, $ff, $ff, $ff, $15, $93
	db $00, $93, $00, $7e, $00, $7e, $00, $7e, $00, $7e, $00, $29, $54, $ff, $ff, $ff
	db $14, $00, $00, $64, $00, $00, $00, $00, $00, $00, $00, $8c, $00, $81, $82, $ff
	db $ff, $ff, $17, $00, $00, $82, $00, $00, $00, $00, $00, $00, $00, $aa, $00, $33
	db $34, $35, $36, $ff, $15, $00, $00, $6e, $00, $00, $00, $00, $00, $00, $00, $96
	db $00, $18, $1d, $21, $ff, $ff, $16, $00, $00, $78, $00, $00, $00, $00, $00, $00
	db $00, $a0, $00, $ff, $ff, $ff, $ff, $ff, $14, $00, $00, $46, $00, $00, $00, $00
	db $00, $00, $00, $5a, $00, $ff, $ff, $ff, $ff, $ff, $19, $00, $00, $64, $00, $00
	db $00, $00, $00, $00, $00, $78, $00, $84, $ff, $ff, $ff, $ff, $1e, $00, $00, $82
	db $00, $00, $00, $00, $00, $00, $00, $96, $00, $85, $ff, $ff, $ff, $ff, $23, $00
	db $00, $a0, $00, $00, $00, $00, $00, $00, $00, $b4, $00, $86, $ff, $ff, $ff, $ff
	db $05, $23, $00, $00, $00, $00, $00, $1e, $00, $1e, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $0c, $54, $00, $00, $00, $00, $00, $48, $00, $48, $00, $00, $00, $88
	db $ff, $ff, $ff, $ff, $0b, $4b, $00, $00, $00, $00, $00, $54, $00, $46, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $13, $8c, $00, $00, $00, $00, $00, $7e, $00, $8c
	db $00, $00, $00, $8a, $ff, $ff, $ff, $ff, $12, $7e, $00, $00, $00, $6c, $00, $6c
	db $00, $6c, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0e, $62, $00, $00
	db $00, $00, $00, $54, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0d, $5b
	db $00, $00, $00, $00, $00, $4e, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $0e, $62, $00, $00, $00, $54, $00, $54, $00, $54, $00, $00, $00, $3b, $8e, $ff
	db $ff, $ff, $10, $64, $00, $00, $00, $00, $00, $00, $00, $78, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $11, $78, $00, $00, $00, $64, $00, $00, $00, $8c, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $1a, $b6, $00, $00, $00, $00, $00, $9c, $00, $00
	db $00, $9c, $00, $89, $8e, $ff, $ff, $ff, $12, $72, $00, $00, $00, $00, $00, $00
	db $00, $82, $00, $60, $00, $2d, $77, $ff, $ff, $ff, $1b, $c6, $00, $5e, $00, $00
	db $00, $00, $00, $91, $00, $a2, $00, $31, $7d, $ff, $ff, $ff, $1e, $d2, $00, $00
	db $00, $00, $00, $00, $00, $b4, $00, $b4, $00, $14, $94, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $1c, $00, $00, $7c, $00, $00
	db $00, $00, $00, $00, $00, $a0, $00, $ff, $ff, $ff, $ff, $ff, $0c, $3e, $00, $00
	db $00, $44, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $0c, $44
	db $00, $00, $00, $48, $00, $00, $00, $3e, $00, $00, $00, $ff, $ff, $ff, $ff, $ff
	db $0c, $44, $00, $00, $00, $3e, $00, $00, $00, $48, $00, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $21, $e7, $00, $a4, $00, $c6, $00, $00, $00, $c6, $00, $c6, $00, $44
	db $45, $46, $47, $ff

	ld a, [$c88f]
	or a
	ret nz

	ld a, [$c8eb]
	bit 5, a
	jp nz, Jump_006_6b87

	bit 7, a
	jp nz, Jump_006_6295

	bit 4, a
	jp nz, Jump_006_62b2

	bit 0, a
	jp nz, Jump_006_67a9

	bit 1, a
	jr z, jr_006_6059

	ld hl, far_Call_07_4009
	rst $10
	ret


jr_006_6059:
	bit 3, a
	jr z, jr_006_6062

	ld hl, far_Call_19_4003
	rst $10
	ret


jr_006_6062:
	bit 6, a
	jr z, jr_006_606b

	ld hl, far_Call_13_7366
	rst $10
	ret


jr_006_606b:
	bit 2, a
	jp nz, Jump_006_62f6

	ld a, [$d9e8]
	or a
	jp nz, Jump_006_6284

	ld a, [$d8d7]
	or a
	jp nz, Jump_006_6284

	ld a, [$c8a8]
	or a
	jp nz, Jump_006_6284

	ldh a, [$ff90]
	bit 0, a
	jp nz, Jump_006_6284

	ld a, [$c8aa]
	or a
	jp nz, Jump_006_611d

	ld a, [$c850]
	or a
	jp nz, Jump_006_60b8

	ld a, [$c846]
	and $08
	jr z, jr_006_60b8

	ld a, [$ca8d]
	or a
	jr z, jr_006_60ac

	ld a, [$ca3f]
	xor $01

jr_006_60ac:
	ld [$ca3f], a
	call Call_2518
	call Call_25F1
	jp Jump_006_6284


Jump_006_60b8:
jr_006_60b8:
	ld a, [$c850]
	or a
	jp nz, Jump_006_611d

	ld a, [$c846]
	and $04
	jr z, jr_006_611d

	ld a, [$c969]
	or a
	jr nz, jr_006_60e7

	ld a, [$c968]
	cp $61
	jr z, jr_006_60e7

	cp $62
	jr z, jr_006_60e7

	cp $63
	jr z, jr_006_60e7

	cp $64
	jr z, jr_006_60e7

	cp $50
	jr c, jr_006_611d

	cp $5d
	jr nc, jr_006_611d

jr_006_60e7:
	ld hl, $c8eb
	set 3, [hl]
	xor a
	ld [$c905], a
	ld [$c906], a
	xor a
	ld [$c907], a
	ld [$c908], a
	ldh a, [$ffb7]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	ld a, l
	ldh [$ffbf], a
	ld a, h
	ldh [$ffc0], a
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	ldh [$ffc1], a
	ld a, h
	ldh [$ffc2], a
	call Call_06_62B7
	ld a, $59
	call Call_1B2C
	jp Jump_006_6284


Jump_006_611d:
jr_006_611d:
	ld a, [$d8d7]
	or a
	jp nz, Jump_006_6247

	ld a, [$c850]
	or a
	jp nz, Jump_006_6247

	ld a, [$c846]
	and $01
	jp z, Jump_006_6247

	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	ldh [$ffdb], a
	ld a, h
	ldh [$ffdc], a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	ldh [$ffdd], a
	ld a, h
	ldh [$ffde], a
	ld hl, $0b04
	rst $10
	ldh a, [$ffd5]
	cp $ff
	jr nz, jr_006_618e

	ld hl, $6285
	ldh a, [$ff8e]
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	add hl, bc
	ld a, l
	ldh [$ffdb], a
	ld a, h
	ldh [$ffdc], a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	add hl, de
	ld a, l
	ldh [$ffdd], a
	ld a, h
	ldh [$ffde], a
	ld hl, $0b04
	rst $10
	ldh a, [$ffd5]
	cp $ff
	jp z, Jump_006_61e9

jr_006_618e:
	ld [$d8d4], a
	ld a, [$c968]
	ld [$d8d3], a
	ld a, [$c969]
	or a
	jr z, jr_006_61a2

	ld a, $70
	ld [$d8d3], a

jr_006_61a2:
	ldh a, [$ffd6]
	cp $ff
	jr z, jr_006_61b7

	ld c, $20
	call Call_1DBE
	ld a, l
	add $d7
	ld l, a
	ld a, h
	adc $d7
	ld h, a
	set 6, [hl]

jr_006_61b7:
	ld hl, $d8d8
	res 0, [hl]
	res 1, [hl]
	xor a
	ld [$d8d7], a
	ld hl, far_Call_04_55EC
	rst $10
	ld a, [$d8d7]
	or a
	jp z, Jump_006_61e9

	bit 1, a
	jp z, Jump_006_61e9

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

Jump_006_61e9:
	ld a, [$c969]
	or a
	jp z, Jump_006_6247

	ld hl, $6285
	ldh a, [$ff8e]
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	add hl, bc
	ld a, l
	ldh [$ffdb], a
	ld a, h
	ldh [$ffdc], a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	add hl, de
	ld a, l
	ldh [$ffdd], a
	ld a, h
	ldh [$ffde], a
	ldh a, [$ffdb]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffdc]
	swap a
	and $f0
	or b
	ldh [$ffdb], a
	ldh a, [$ffdd]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffde]
	swap a
	and $f0
	or b
	ldh [$ffdd], a
	ld a, $01
	ld [$d78f], a
	ld hl, far_Call_01_5A72
	rst $10

Jump_006_6247:
	ld a, [$d8d7]
	or a
	jp nz, Jump_006_6284

	ld a, [$c8eb]
	or a
	jp nz, Jump_006_6284

	ld a, [$c850]
	or a
	jp nz, Jump_006_6284

	ld a, [$c846]
	and $01
	jr z, jr_006_6284

	ld a, [$ca8d]
	or a
	jr z, jr_006_6284

	ld hl, $c8eb
	set 1, [hl]
	xor a
	ld [$c90d], a
	ld [$c90e], a
	xor a
	ld [$c90f], a
	ld [$c910], a
	ld a, $59
	call Call_1B2C
	jp Jump_006_6284


Jump_006_6284:
jr_006_6284:
	ret


	db $00, $00, $10, $00, $f0, $ff, $00, $00, $00, $00, $f0, $ff, $10, $00, $00, $00

Jump_006_6295:
	call Call_06_62A0
	ld hl, far_Call_09_6120
	rst $10
	call Call_06_62A0
	ret


Call_06_62A0::
	ld hl, $c905
	ld de, $c876
	ld b, $08

jr_006_62a8:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	dec b
	jr nz, jr_006_62a8

	ret


Jump_006_62b2:
	ld hl, $0900
	rst $10
	ret


Call_06_62B7::
	ld a, $80
	ldh [$ffb6], a
	ld hl, $9c00
	ld de, $c1c0
	ld c, $02

jr_006_62c3:
	ld b, $14
	push hl

jr_006_62c6:
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
	jr nz, jr_006_62c6

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
	dec c
	jr nz, jr_006_62c3

	ret


Jump_006_62f6:
	ld a, [$c91d]
	rst $00

JumpTable_06_62FA::
	dw Jump_06_6302
	dw Jump_06_6446
	dw Jump_06_651B
	dw Jump_06_65EA

Jump_06_6302::
	ld a, [$c91e]
	rst $00

JumpTable_06_6306::
	dw Jump_06_6310
	dw Jump_06_66B8
	dw Jump_06_66C7
	dw Jump_06_6328
	dw Jump_06_63D7

Jump_06_6310::
	ld a, [$c925]
	dec a
	ld [$c925], a
	call Call_06_66E5
	ld hl, $0b03
	rst $10
	ld a, $13
	ld [$c91f], a
	ld hl, $c91e
	inc [hl]
	ret


Jump_06_6328::
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
	dec a
	and $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$c740], a
	ld a, h
	ld [$c741], a
	ld a, [$c91f]
	ld de, $c500
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, $01
	ld [$c742], a
	ld a, $10
	ld [$c743], a
	ld hl, $c744
	ld b, $10

jr_006_6369:
	ld a, [de]
	ld [hli], a
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_006_6369

	ld a, [$c91f]
	srl a
	push af
	ld de, $c200
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	ld b, $10
	ld hl, $c754
	jr c, jr_006_63a0

jr_006_638d:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_006_638d

	jr jr_006_63af

jr_006_63a0:
	ld a, [de]
	and $0f
	ld [hli], a
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_006_63a0

jr_006_63af:
	ld a, $01
	ld [$c8a3], a
	ldh a, [$ffb7]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	ld a, l
	add $f8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [$ffb7], a
	ld a, h
	ldh [$ffb8], a
	ld a, [$c91f]
	dec a
	ld [$c91f], a
	cp $ff
	ret nz

	ld hl, $c91e
	inc [hl]
	ret


Jump_06_63D7::
	ld hl, $c300
	ld de, $c500
	ld bc, $0200

jr_006_63e0:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_006_63e0

	ld hl, $c8eb
	res 2, [hl]
	call Call_06_66F0
	ld b, $31

jr_006_63f2:
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
	jr c, jr_006_6427

	xor a
	ld [$ca37], a

jr_006_6427:
	dec b
	jr nz, jr_006_63f2

	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ld hl, far_Call_01_5D6D
	rst $10
	xor a
	ld [$d9e8], a
	ret


Jump_06_6446::
	ld a, [$c91e]
	rst $00

JumpTable_06_644A::
	dw Jump_06_6454
	dw Jump_06_66B8
	dw Jump_06_66C7
	dw Jump_06_646B
	dw Jump_06_63D7

Jump_06_6454::
	ld a, [$c925]
	inc a
	ld [$c925], a
	call Call_06_66E5
	ld hl, $0b03
	rst $10
	xor a
	ld [$c91f], a
	ld hl, $c91e
	inc [hl]
	ret


Jump_06_646B::
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
	add $14
	and $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$c740], a
	ld a, h
	ld [$c741], a
	ld a, [$c91f]
	ld de, $c500
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, $01
	ld [$c742], a
	ld a, $10
	ld [$c743], a
	ld hl, $c744
	ld b, $10

jr_006_64ad:
	ld a, [de]
	ld [hli], a
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_006_64ad

	ld a, [$c91f]
	srl a
	push af
	ld de, $c200
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	ld b, $10
	ld hl, $c754
	jr c, jr_006_64e4

jr_006_64d1:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_006_64d1

	jr jr_006_64f3

jr_006_64e4:
	ld a, [de]
	and $0f
	ld [hli], a
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_006_64e4

jr_006_64f3:
	ld a, $01
	ld [$c8a3], a
	ldh a, [$ffb7]
	ld l, a
	ldh a, [$ffb8]
	ld h, a
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ffb7], a
	ld a, h
	ldh [$ffb8], a
	ld a, [$c91f]
	inc a
	ld [$c91f], a
	cp $14
	ret nz

	ld hl, $c91e
	inc [hl]
	ret


Jump_06_651B::
	ld a, [$c91e]
	rst $00

JumpTable_06_651F::
	dw Jump_06_6529
	dw Jump_06_66B8
	dw Jump_06_66C7
	dw Jump_06_6542
	dw Jump_06_63D7

Jump_06_6529::
	ld a, [$c925]
	sub $04
	ld [$c925], a
	call Call_06_66E5
	ld hl, $0b03
	rst $10
	ld a, $0f
	ld [$c91f], a
	ld hl, $c91e
	inc [hl]
	ret


Jump_06_6542::
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
	ld a, l
	add $e0
	ld l, a
	ld a, h
	adc $03
	ld h, a
	res 2, h
	ld a, l
	ld [$c740], a
	ld a, h
	ld [$c741], a
	ld a, [$c91f]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld e, l
	ld d, h
	ld a, $00
	ld [$c742], a
	ld a, $14
	ld [$c743], a
	ld hl, $c744
	ld b, $14

jr_006_6595:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_006_6595

	ld a, [$c91f]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c2
	ld h, a
	ld e, l
	ld d, h
	ld hl, $c758
	ld b, $0a

jr_006_65b4:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	ld a, [de]
	and $0f
	ld [hli], a
	inc de
	dec b
	jr nz, jr_006_65b4

	ld a, $01
	ld [$c8a3], a
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	add $f8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, [$c91f]
	dec a
	ld [$c91f], a
	cp $ff
	ret nz

	ld hl, $c91e
	inc [hl]
	ret


Jump_06_65EA::
	ld a, [$c91e]
	rst $00

JumpTable_06_65EE::
	dw Jump_06_65F8
	dw Jump_06_66B8
	dw Jump_06_66C7
	dw Jump_06_6610
	dw Jump_06_63D7

Jump_06_65F8::
	ld a, [$c925]
	add $04
	ld [$c925], a
	call Call_06_66E5
	ld hl, $0b03
	rst $10
	xor a
	ld [$c91f], a
	ld hl, $c91e
	inc [hl]
	ret


Jump_06_6610::
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
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $02
	ld h, a
	res 2, h
	ld a, l
	ld [$c740], a
	ld a, h
	ld [$c741], a
	ld a, [$c91f]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld e, l
	ld d, h
	ld a, $00
	ld [$c742], a
	ld a, $14
	ld [$c743], a
	ld hl, $c744
	ld b, $14

jr_006_6663:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_006_6663

	ld a, [$c91f]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c2
	ld h, a
	ld e, l
	ld d, h
	ld hl, $c758
	ld b, $0a

jr_006_6682:
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	ld a, [de]
	and $0f
	ld [hli], a
	inc de
	dec b
	jr nz, jr_006_6682

	ld a, $01
	ld [$c8a3], a
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, [$c91f]
	inc a
	ld [$c91f], a
	cp $10
	ret nz

	ld hl, $c91e
	inc [hl]
	ret


Jump_06_66B8::
	ld a, [$c969]
	or a
	jr nz, jr_006_66c2

	ld hl, far_Call_0B_470F
	rst $10

jr_006_66c2:
	ld hl, $c91e
	inc [hl]
	ret


Jump_06_66C7::
	ld hl, $c91e
	inc [hl]
	ld a, [$c969]
	or a
	ret nz

	ld a, [$d8d7]
	or a
	ret nz

	ld a, $00
	ld [$d8d4], a
	ld a, [$c968]
	ld [$d8d3], a
	ld hl, far_Call_04_55EC
	rst $10
	ret


Call_06_66E5::
	ld a, $80
	ldh [$ffb6], a
	ld hl, $9c00
	call Call_06_671F
	ret


Call_06_66F0::
	ld a, $ff
	ldh [$ffb6], a
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
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $02
	ld h, a
	res 2, h
	call Call_06_671F
	ret


Call_06_671F::
	push hl
	call Call_06_6771
	pop hl
	ld a, [$c81d]
	or a
	ret z

	di
	call Call_1AA6
	ld a, $01
	ldh [rVBK], a
	ei
	ld c, $02

jr_006_6734:
	ld b, $14
	push hl

jr_006_6737:
	ld a, $07
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
	jr nz, jr_006_6737

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
	dec c
	jr nz, jr_006_6734

	di
	call Call_1AA6
	ld a, $00
	ldh [rVBK], a
	ei
	ret


Call_06_6771::
	ld de, $c1c0
	ld c, $02

jr_006_6776:
	ld b, $14
	push hl

jr_006_6779:
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
	jr nz, jr_006_6779

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
	dec c
	jr nz, jr_006_6776

	ret


Jump_006_67a9:
	ld hl, $ffb7
	call Call_06_67E3
	ld hl, $ffbb
	call Call_06_67E3
	ld a, [$c915]
	rst $00

JumpTable_06_67B9::
	dw Jump_06_6843
	dw Jump_06_68D4
	dw Jump_06_692F
	dw Jump_06_682A
	dw Jump_06_682A
	dw Jump_06_682A
	dw Jump_06_6964
	dw Jump_06_682A
	dw Jump_06_682A
	dw Jump_06_6979
	dw Jump_06_67FF
	dw Jump_06_69D0
	dw Jump_06_6B1E
	dw Jump_06_682A
	dw Jump_06_682A
	dw Jump_06_6B49
	dw Jump_06_682A
	dw Jump_06_682A
	dw Jump_06_682A
	dw Jump_06_6B6C
	dw Jump_06_6B7D

Call_06_67E3::
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


Call_06_67F0::
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


Jump_06_67FF::
	ld a, $fd
	ld [$c83b], a
	ld hl, far_Call_56_4485
	rst $10
	ld a, [$c917]
	ld l, a
	ld a, [$c918]
	ld h, a
	ld a, h
	and l
	cp $ff
	jr z, jr_006_6819

	call Call_096D

jr_006_6819:
	ld hl, $c915
	inc [hl]
	ld hl, $0020
	call Call_06_682F
	call Call_06_67F0
	call Call_0CA0
	ret


Jump_06_682A::
	ld hl, $c915
	inc [hl]
	ret


Call_06_682F::
	ld a, [$c919]
	add l
	ld l, a
	ld a, [$c91a]
	adc h
	and $03
	ld h, a
	ld a, [$c91a]
	and $fc
	or h
	ld h, a
	ret


Jump_06_6843::
	ld hl, $c915
	inc [hl]
	ld a, $01
	ldh [$ffd3], a
	ld a, $00
	ld [$c83c], a
	ld a, $20
	ld [$c83d], a
	ld de, $0000
	ld a, [$d8d7]
	or a
	jr z, jr_006_686e

	ld hl, $d8d8
	ld a, [hl]
	res 0, [hl]
	res 1, [hl]
	bit 0, a
	jr nz, jr_006_6882

	bit 1, a
	jr nz, jr_006_6893

jr_006_686e:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ff95]
	sub c
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ldh a, [$ff96]
	sbc b
	jr nz, jr_006_6882

	ld a, c
	cp $50
	jr nc, jr_006_6893

jr_006_6882:
	ld a, $02
	ldh [$ffd3], a
	ld a, $00
	ld [$c83c], a
	ld a, $80
	ld [$c83d], a
	ld de, $01a0

jr_006_6893:
	ld a, [$c969]
	or a
	jr nz, jr_006_68a7

	ld a, [$c968]
	cp $08
	jr z, jr_006_68a4

	cp $5d
	jr nz, jr_006_68a7

jr_006_68a4:
	xor a
	ldh [$ffd3], a

jr_006_68a7:
	ld hl, $ffb7
	call Call_06_6957
	ld hl, $ffbb
	call Call_06_6957
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
	add hl, de
	ld a, h
	and $03
	or $98
	ld h, a
	ld a, l
	ld [$c919], a
	ld a, h
	ld [$c91a], a

Jump_06_68D4::
	ld hl, $c915
	inc [hl]
	ld a, [$c919]
	ld l, a
	ld a, [$c91a]
	ld h, a
	ld bc, $0000
	ld de, $c100
	call Call_06_690A
	ld bc, $0020
	ld de, $c114
	call Call_06_690A
	ld bc, $0040
	ld de, $c128
	call Call_06_690A
	ld bc, $0060
	ld de, $c13c
	call Call_06_690A
	ld bc, $0080
	ld de, $c150

Call_06_690A::
	ld a, [$c919]
	ld l, a
	ld a, [$c91a]
	ld h, a
	add hl, bc
	ld a, h
	and $03
	ld h, a
	ld a, [$c91a]
	and $fc
	or h
	ld h, a
	ld b, $14

jr_006_6920:
	di
	call Call_1AA6
	ld a, [hl]
	ei
	ld [de], a
	inc de
	call Call_06_67F0
	dec b
	jr nz, jr_006_6920

	ret


Jump_06_692F::
	ld hl, $c915
	inc [hl]
	ld hl, $0040
	call Call_06_682F

Call_06_6939::
	ld a, $fe
	call Call_1AAD
	call Call_06_67F0
	ld b, $12
	ld a, $e0
	call Call_06_694D
	ld a, $ff
	jp Call_1AAD


Call_06_694D::
	call Call_1AAD
	call Call_06_67F0
	dec b
	jr nz, Call_06_694D

	ret


Call_06_6957::
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


Jump_06_6964::
	ld hl, $c915
	inc [hl]
	ld hl, $0020
	call Call_06_682F
	call Call_06_6939
	ld hl, $0060
	call Call_06_682F
	jr Call_06_6939

Jump_06_6979::
	ld hl, $c915
	inc [hl]
	ld a, [$c919]
	ld l, a
	ld a, [$c91a]
	ld h, a
	ld a, $fa
	call Call_1AAD
	call Call_06_67F0
	ld b, $12
	ld a, $ef
	call Call_06_694D
	ld a, $fb
	call Call_1AAD
	ld hl, $0080
	call Call_06_682F
	ld a, $fc
	call Call_1AAD
	call Call_06_67F0
	ld b, $12
	ld a, $ee
	call Call_06_694D
	ld a, $fd
	call Call_1AAD
	call Call_1ED5
	ld hl, $0000
	ldh a, [$ffd3]
	cp $02
	jr nz, jr_006_69c2

	ld hl, $000d

jr_006_69c2:
	ld a, $00
	ld bc, $1304
	ld d, $01
	call Call_1F27
	call Call_1F59
	ret


Jump_06_69D0::
	ld a, [$c8aa]
	or a
	ret nz

	ld a, [$c850]
	or a
	ret nz

	ld a, [$c825]
	or a
	ret nz

	ld a, [$c917]
	ld l, a
	ld a, [$c918]
	ld h, a
	ld a, h
	and l
	cp $ff
	jr nz, jr_006_6a02

	ld a, [$d8d7]
	bit 1, a
	jr z, jr_006_6a02

	ld a, [$c8eb]
	bit 7, a
	ret nz

	bit 4, a
	ret nz

	ld hl, $0406
	rst $10
	ret


jr_006_6a02:
	ld a, [$c918]
	cp $02
	jr nz, jr_006_6a25

	ld a, [$c917]
	cp $11
	jr nz, jr_006_6a1a

	call Call_06_6AC2
	ld a, [$c917]
	cp $17
	jr nz, jr_006_6a1a

jr_006_6a1a:
	ld a, [$c917]
	cp $17
	jr nz, jr_006_6a25

	call Call_06_6AD7
	ret


jr_006_6a25:
	ld a, [$c917]
	cp $1a
	jp nz, Jump_006_6ab9

	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
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

jr_006_6a8b:
	ld a, [hl]
	or a
	jr z, jr_006_6aa7

	cp $ff
	jr z, jr_006_6aa7

	ld [$da5e], a
	push hl
	push bc
	ld hl, far_Call_03_6980
	rst $10
	pop bc
	pop hl
	ld a, [$da6d]
	bit 2, a
	jr nz, jr_006_6aa7

	ld [hl], $ff

jr_006_6aa7:
	inc hl
	dec b
	jr nz, jr_006_6a8b

	ld hl, far_Call_03_7160
	rst $10
	ld a, $04
	call Call_1688
	ld hl, $c88f
	inc [hl]
	ret


Jump_006_6ab9:
	ld hl, $c915
	inc [hl]
	ld hl, far_Call_08_41E3
	rst $10
	ret


Call_06_6AC2::
	ld de, $d793

jr_006_6ac5:
	ld a, [de]
	cp $ff
	ret z

	ld a, [de]
	res 5, a
	ld [de], a
	ld a, e
	add $04
	ld e, a
	ld a, d
	adc $00
	ld d, a
	jr jr_006_6ac5

Call_06_6AD7::
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	ld a, [$cab4]
	add a
	ld hl, $6b0c
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
	ld a, $00
	ld [$da09], a
	ret


	db $3d, $01, $3e, $01, $3f, $01, $40, $01, $41, $01, $42, $01, $43, $01, $44, $01
	db $44, $01

Jump_06_6B1E::
	ld hl, $c915
	inc [hl]
	ld a, [$c919]
	ld l, a
	ld a, [$c91a]
	ld h, a
	ld de, $c100
	ld b, $14
	call Call_06_6B3D
	ld hl, $0080
	call Call_06_682F
	ld de, $c150
	ld b, $14

Call_06_6B3D::
	ld a, [de]
	call Call_1AAD
	inc de
	call Call_06_67F0
	dec b
	jr nz, Call_06_6B3D

	ret


Jump_06_6B49::
	ld a, $00
	ldh [$ffd3], a
	ld hl, $c915
	inc [hl]
	ld hl, $0020
	call Call_06_682F
	ld de, $c114
	ld b, $14
	call Call_06_6B3D
	ld hl, $0060
	call Call_06_682F
	ld de, $c13c
	ld b, $14
	jr Call_06_6B3D

Jump_06_6B6C::
	ld hl, $c915
	inc [hl]
	ld hl, $0040
	call Call_06_682F
	ld de, $c128
	ld b, $14
	jr Call_06_6B3D

Jump_06_6B7D::
	ld hl, $c8eb
	res 0, [hl]
	xor a
	ld [$c915], a
	ret


Jump_006_6b87:
	ld a, [$c905]
	or a
	jr nz, jr_006_6ba7

	ld a, [$c969]
	or a
	jr nz, jr_006_6ba2

	ld a, [$c968]
	cp $50
	jr c, jr_006_6ba7

	cp $52
	jr z, jr_006_6ba7

	cp $60
	jr z, jr_006_6ba7

jr_006_6ba2:
	ld a, $10
	ld [$c905], a

jr_006_6ba7:
	ld a, [$c905]
	rst $00

JumpTable_06_6BAB::
	dw Jump_06_6BDC
	dw Jump_06_6C56
	dw Jump_06_6C7B
	dw Jump_06_6D1F
	dw Jump_06_6D53
	dw Jump_06_6E12
	dw Jump_06_6E2B
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6BDB
	dw Jump_06_6E9F
	dw Jump_06_6F14
	dw Jump_06_6F3F
	dw Jump_06_6FC7
	dw Jump_06_6D1F
	dw Jump_06_6D53
	dw Jump_06_6E12
	dw Jump_06_6E2B

Jump_06_6BDB::
	ret


Jump_06_6BDC::
	ld a, $02
	call Call_1AE1
	call Call_3331
	ld a, $52
	call Call_1B2C
	ld hl, $ffb7
	call Call_06_6E4F
	ld hl, $ffbb
	call Call_06_6E4F
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
	ld [$c90b], a
	ld a, h
	ld [$c90c], a
	ld hl, $0014
	ld b, $10

jr_006_6c25:
	push bc
	push hl
	ld b, $0c

jr_006_6c29:
	push bc
	push hl
	call Call_06_6E7F
	pop hl
	inc hl
	pop bc
	dec b
	jr nz, jr_006_6c29

	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop bc
	dec b
	jr nz, jr_006_6c25

	ld hl, $c905
	inc [hl]
	ld hl, $c100
	ld b, $80

jr_006_6c4a:
	ldh a, [$ffb7]
	ld [hli], a
	dec b
	jr nz, jr_006_6c4a

	ld a, $1e
	ld [$c906], a
	ret


Jump_06_6C56::
	ld a, [$c906]
	and $01
	ld [$c8ec], a
	ld a, [$c906]
	dec a
	ld [$c906], a
	ret nz

	ld hl, $c905
	inc [hl]
	ld a, $01
	ld [$c907], a
	di
	ld a, $02
	ldh [rLYC], a
	ld a, $02
	ld [$c892], a
	ei
	ret


Jump_06_6C7B::
	ld a, $01
	ld [$c8ec], a
	ld a, [$c8a6]
	and $07
	jr nz, Call_06_6CA3

	ld a, [$c907]
	swap a
	and $0f
	inc a
	ld b, a
	ld a, [$c907]
	add b
	ld [$c907], a
	cp $38
	jr c, Call_06_6CA3

	ld hl, $c905
	inc [hl]
	xor a
	ld [$c908], a

Call_06_6CA3::
	ld a, [$c907]
	ldh [$ffd5], a
	ld a, [$c8a6]
	rra
	rra
	and $0f
	ld e, a
	ld d, $00
	ld a, [$c8a6]
	and $03
	cp $00
	jr nz, jr_006_6cc5

	ld bc, $c100
	ld a, $20
	ldh [$ffd6], a
	jp Jump_006_6ce8


jr_006_6cc5:
	cp $01
	jr nz, jr_006_6cd3

	ld bc, $c120
	ld a, $40
	ldh [$ffd6], a
	jp Jump_006_6ce8


jr_006_6cd3:
	cp $02
	jr nz, jr_006_6ce1

	ld bc, $c140
	ld a, $60
	ldh [$ffd6], a
	jp Jump_006_6ce8


jr_006_6ce1:
	ld bc, $c160
	ld a, $80
	ldh [$ffd6], a

Jump_006_6ce8:
jr_006_6ce8:
	inc e
	ld a, e
	and $0f
	ld e, a
	ld hl, $6d0f
	add hl, de
	push bc
	ld c, [hl]
	ldh a, [$ffd5]
	call Call_1DBE
	pop bc
	bit 3, e
	jr z, jr_006_6d02

	ldh a, [$ffb7]
	sub h
	jr jr_006_6d05

jr_006_6d02:
	ldh a, [$ffb7]
	add h

jr_006_6d05:
	ld [bc], a
	inc c
	ld [bc], a
	inc c
	ldh a, [$ffd6]
	cp c
	jr nz, jr_006_6ce8

	ret


	db $00, $60, $b6, $ec, $ff, $ec, $b6, $60, $00, $60, $b6, $ec, $ff, $ec, $b6, $60

Jump_06_6D1F::
	ld a, [$c8a6]
	and $0f
	jr nz, jr_006_6d3a

	ld a, [$c908]
	inc a
	ld [$c908], a
	cp $04
	jr nz, jr_006_6d3a

	ld hl, $c905
	inc [hl]
	ld a, $00
	ld [$c892], a

jr_006_6d3a:
	ld a, [$c908]
	ld hl, $6d4e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c89b], a
	call Call_06_6CA3
	ret


	db $d2, $81, $40, $00, $00

Jump_06_6D53::
	ld hl, $c905
	inc [hl]
	ld hl, $c88f
	inc [hl]
	ld a, $28
	ld [$c906], a
	ld a, $00
	ld [$c89b], a
	ld a, $00
	ld [$c89c], a
	ld a, $00
	ld [$c89d], a
	ld a, $01
	ld [$c8ec], a
	ld a, [$c96e]
	or a
	ret nz

	ld a, [$c96d]
	or a
	ret nz

	ld a, [$d92b]
	cp $01
	ret z

	cp $02
	ret z

	cp $03
	ret z

	cp $04
	ret z

	cp $05
	ret z

	ld a, $00
	ld [$c8ec], a
	ld hl, $c8eb
	res 5, [hl]
	xor a
	ld [$c905], a
	di
	ld a, $7f
	ldh [rLYC], a
	ld a, $01
	ld [$c892], a
	ei
	ret


	db $3e, $00, $ea, $9b, $c8, $f3, $3e, $02, $e0, $45, $3e, $02, $ea, $92, $c8, $fb
	db $21, $05, $c9, $34, $c9, $fa, $a6, $c8, $e6, $0f, $20, $0f, $fa, $08, $c9, $3d
	db $ea, $08, $c9, $fe, $00, $20, $04, $21, $05, $c9, $34, $fa, $08, $c9, $21, $4e
	db $6d, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $9b, $c8, $cd, $a3, $6c, $c9, $fa
	db $a6, $c8, $e6, $07, $20, $1f, $fa, $07, $c9, $cb, $37, $e6, $0f, $3c, $47, $fa
	db $07, $c9, $90, $ea, $07, $c9, $30, $0d, $21, $05, $c9, $34, $af, $ea, $07, $c9
	db $3e, $3c, $ea, $06, $c9, $c3, $a3, $6c

Jump_06_6E12::
	di
	ld a, $7f
	ldh [rLYC], a
	ld a, $01
	ld [$c892], a
	ei
	ld a, [$c969]
	or a
	jr z, jr_006_6e26

	xor a
	ldh [$ff90], a

jr_006_6e26:
	ld hl, $c905
	inc [hl]
	ret


Jump_06_6E2B::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c906]
	and $01
	ld [$c8ec], a
	ld a, [$c906]
	dec a
	ld [$c906], a
	ret nz

	ld a, $00
	ld [$c8ec], a
	xor a
	ld [$c905], a
	ld hl, $c8eb
	res 5, [hl]
	ret


Call_06_6E4F::
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


Call_06_6E5C::
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


Call_06_6E6B::
	ld a, [$c90b]
	add l
	ld l, a
	ld a, [$c90c]
	adc h
	and $03
	ld h, a
	ld a, [$c90c]
	and $fc
	or h
	ld h, a
	ret


Call_06_6E7F::
	call Call_06_6E88
	ld a, $e0
	call Call_1AAD
	ret


Call_06_6E88::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call Call_06_6E6B
	ld a, b
	and $1f
	jr z, jr_006_6e9d

	ld b, a

jr_006_6e97:
	call Call_06_6E5C
	dec b
	jr nz, jr_006_6e97

jr_006_6e9d:
	pop bc
	ret


Jump_06_6E9F::
	ld a, $55
	call Call_1B2C
	ld hl, $ffb7
	call Call_06_6E4F
	ld hl, $ffbb
	call Call_06_6E4F
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
	ld [$c90b], a
	ld a, h
	ld [$c90c], a
	ld hl, $0240
	ld b, $0e

jr_006_6ee0:
	push bc
	push hl
	ld b, $14

jr_006_6ee4:
	push bc
	push hl
	call Call_06_6E7F
	pop hl
	inc hl
	pop bc
	dec b
	jr nz, jr_006_6ee4

	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop bc
	dec b
	jr nz, jr_006_6ee0

	ld hl, $c905
	inc [hl]
	ld hl, $c100
	ld b, $80

jr_006_6f05:
	ldh a, [$ffbb]
	ld [hli], a
	dec b
	jr nz, jr_006_6f05

	ld a, $1e
	ld [$c906], a
	call Call_06_7031
	ret


Jump_06_6F14::
	ld a, [$c906]
	and $01
	ld [$c8ec], a
	ld a, [$c906]
	dec a
	ld [$c906], a
	ret nz

	ld hl, $c905
	inc [hl]
	ld hl, $0000
	ld a, l
	ld [$c907], a
	ld a, h
	ld [$c908], a
	di
	ld a, $02
	ldh [rLYC], a
	ld a, $03
	ld [$c892], a
	ei
	ret


Jump_06_6F3F::
	ldh a, [$ffbb]
	add $20
	ld [$c180], a
	ld [$c181], a
	ld [$c182], a
	ld [$c183], a
	ld a, $01
	ld [$c8ec], a
	ld hl, $0000
	ld de, $c140
	ld bc, $c140

jr_006_6f5d:
	ld a, h
	add e
	cp $7c
	jr c, jr_006_6f73

	ldh a, [$ffbb]
	add $98
	sub e
	ld [de], a
	inc de
	dec bc
	ldh a, [$ffbb]
	sub $08
	sub c
	ld [bc], a
	jr jr_006_6f87

jr_006_6f73:
	ld a, [$c907]
	add l
	ld l, a
	ld a, [$c908]
	adc h
	ld h, a
	ldh a, [$ffbb]
	add h
	ld [de], a
	inc de
	dec bc
	ldh a, [$ffbb]
	sub h
	ld [bc], a

jr_006_6f87:
	ld a, c
	or a
	jr nz, jr_006_6f5d

	ld a, [$c907]
	ld l, a
	ld a, [$c908]
	ld h, a
	ld a, h
	cp $20
	jr nc, jr_006_6fbe

	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	add $02
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [$c907]
	ld c, a
	ld a, [$c908]
	ld b, a
	add hl, bc
	ld a, l
	ld [$c907], a
	ld a, h
	ld [$c908], a
	ret


jr_006_6fbe:
	ld hl, $c905
	inc [hl]
	xor a
	ld [$c908], a
	ret


Jump_06_6FC7::
	ld hl, $0000
	ld a, [$c908]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_06_6E88
	ld b, $10

jr_006_6fd8:
	ld a, $e0
	call Call_1AAD
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_006_6fd8

	ld hl, $0013
	ld a, [$c908]
	ld b, a
	ld a, l
	sub b
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	call Call_06_6E88
	ld b, $10

jr_006_6ffb:
	ld a, $e0
	call Call_1AAD
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_006_6ffb

	ld hl, $c908
	inc [hl]
	ld a, [$c908]
	cp $0a
	ret nz

	ld hl, $c905
	inc [hl]
	xor a
	ld [$c908], a
	ldh a, [$ffbb]
	ldh [rSCY], a
	ld a, $ff
	ldh [$ffb6], a
	di
	ld a, $7f
	ldh [rLYC], a
	ld a, $01
	ld [$c892], a
	ei
	ret


Call_06_7031::
	ld a, $80
	ldh [$ffb6], a
	ld hl, $9c00
	push hl
	call Call_06_708A
	pop hl
	ld a, [$c81d]
	or a
	ret z

	di
	call Call_1AA6
	ld a, $01
	ldh [rVBK], a
	ei
	ld c, $02

jr_006_704d:
	ld b, $14
	push hl

jr_006_7050:
	ld a, $07
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
	jr nz, jr_006_7050

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
	dec c
	jr nz, jr_006_704d

	di
	call Call_1AA6
	ld a, $00
	ldh [rVBK], a
	ei
	ret


Call_06_708A::
	ld de, $c1c0
	ld c, $02

jr_006_708f:
	ld b, $14
	push hl

jr_006_7092:
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
	jr nz, jr_006_7092

	pop hl
	ld a, e
	add $0c
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push bc
	ld bc, $0020
	ld a, h
	add hl, bc
	and $fc
	ld b, a
	ld a, h
	and $03
	or b
	ld h, a
	pop bc
	dec c
	jr nz, jr_006_708f

	ret


	db $08, $0f, $fe, $56, $02, $1f, $10, $3f, $24, $7f, $48, $7f, $ff, $5a, $7f, $32
	db $7f, $14, $3f, $0d, $1f, $ff, $03, $07, $80, $ff, $00, $ff, $02, $ff, $ff, $13
	db $ff, $1f, $fc, $1f, $f0, $1f, $f1, $ff, $0f, $f9, $0f, $fa, $0f, $f9, $27, $fc
	db $ff, $a7, $fc, $93, $fe, $93, $fe, $1f, $fc, $df, $f7, $fb, $01, $ff, $49, $8f
	db $00, $ff, $ff, $bf, $fa, $af, $fc, $8e, $f8, $08, $9a, $00, $28, $ff, $fc, $ac
	db $fe, $62, $fe, $0a, $fe, $46, $bf, $fc, $a4, $f8, $18, $e6, $e6, $fc, $39, $0e
	db $ff, $0f, $0b, $0c, $05, $0e, $02, $07, $03, $ff, $03, $03, $02, $02, $03, $05
	db $07, $05, $ff, $07, $07, $07, $1c, $34, $3f, $7f, $42, $ff, $7f, $42, $ff, $a3
	db $ff, $9c, $fe, $70, $ff, $f8, $20, $e0, $60, $b0, $f0, $10, $e0, $ff, $f0, $e0
	db $a0, $fc, $fe, $1a, $e6, $02, $ff, $fe, $fe, $fe, $0e, $0a, $fa, $f6, $f4, $9f
	db $8e, $f8, $bc, $c0, $e0, $38, $0f, $02, $17, $18, $ff, $3c, $25, $7f, $4e, $fb
	db $8f, $fe, $bb, $df, $ce, $b1, $db, $60, $f1, $02, $19, $0e, $1a, $ff, $1f, $3f
	db $21, $3f, $21, $7f, $d1, $ff, $ff, $ce, $7f, $b8, $7c, $54, $ae, $da, $27, $ff
	db $af, $dd, $75, $ff, $03, $06, $01, $03, $fb, $00, $01, $02, $11, $07, $05, $fd
	db $fb, $7a, $df, $c7, $7c, $de, $e0, $f0, $02, $11, $38, $7c, $ff, $74, $4c, $f4
	db $cc, $c8, $7c, $90, $f8, $fb, $20, $f0, $f6, $05, $60, $f0, $90, $f8, $88, $ff
	db $fc, $a4, $de, $b2, $cf, $59, $e7, $2c, $9f, $73, $1b, $3c, $06, $0f, $46, $10
	db $45, $06, $30, $ff, $78, $48, $78, $48, $7c, $44, $7c, $24, $ff, $7c, $24, $3e
	db $12, $be, $8a, $de, $4a, $ff, $ef, $a5, $77, $d5, $bf, $6a, $ff, $16, $7f, $3f
	db $0b, $1f, $05, $0f, $02, $07, $02, $1f, $fa, $b1, $10, $80, $c3, $10, $c0, $40
	db $c0, $40, $e0, $fb, $e0, $f0, $6e, $08, $f1, $1f, $f2, $0d, $fa, $fb, $0f, $f8
	db $80, $05, $9f, $fe, $21, $ff, $e2, $fd, $ff, $8e, $06, $0f, $fc, $8e, $f9, $09
	db $b9, $ff, $c9, $d9, $69, $fd, $ad, $ff, $63, $fe, $ff, $0b, $fd, $c7, $fe, $46
	db $f8, $2c, $f0, $fd, $f8, $c3, $00, $07, $07, $0c, $0b, $1d, $7f, $ff, $79, $af
	db $d8, $7f, $88, $f7, $0c, $bc, $ff, $47, $cf, $33, $7e, $9d, $bf, $de, $77, $ff
	db $df, $7a, $57, $6e, $5b, $3d, $6b, $10, $7f, $f0, $20, $f8, $98, $64, $dc, $ae
	db $34, $20, $ff, $22, $dc, $22, $b8, $44, $c6, $fa, $7e, $ff, $b2, $f6, $ca, $ea
	db $36, $dc, $ec, $f0, $ff, $58, $e0, $70, $80, $c0, $22, $7f, $22, $fb, $3f, $1f
	db $53, $00, $17, $3f, $2a, $75, $56, $ff, $69, $3d, $62, $1f, $38, $0f, $1f, $1a
	db $ff, $37, $34, $2e, $3f, $7f, $43, $7c, $40, $ff, $7f, $7f, $7f, $f8, $88, $b8
	db $cc, $f4, $ff, $fe, $8b, $df, $4b, $cd, $cb, $6d, $a9, $ff, $6e, $e9, $2e, $c9
	db $6e, $88, $cf, $0b, $ff, $0c, $0b, $0d, $8b, $cc, $47, $cf, $40, $ff, $c0, $c0
	db $c0, $1a, $3d, $04, $06, $00, $fb, $00, $fe, $ed, $10, $8f, $71, $ef, $95, $ff
	db $e7, $e5, $9e, $df, $c7, $11, $8b, $20, $40, $80, $c0, $f4, $b1, $11, $0e, $21
	db $04, $5b, $00, $78, $7f, $af, $d9, $fc, $1a, $2f, $2c, $23, $00, $fc, $00, $fe
	db $00, $fe, $f8, $36, $21, $3c, $2f, $6e, $24, $cf, $45, $ce, $c5, $66, $ff, $a2
	db $67, $e2, $23, $c1, $63, $81, $c1, $f8, $48, $11, $c6, $12, $8b, $26, $80, $c0
	db $e0, $f0, $98, $ff, $fc, $c4, $7e, $72, $be, $3a, $ce, $76, $7f, $9e, $ec, $b6
	db $b8, $cc, $70, $f8, $b1, $13, $ff, $1f, $3f, $2f, $70, $5f, $60, $7f, $c0, $ff
	db $bf, $c0, $ff, $80, $ff, $80, $df, $b8, $ff, $ff, $a1, $ef, $b0, $ff, $98, $77
	db $c8, $ff, $5f, $60, $2f, $70, $1f, $38, $0b, $1d, $ff, $e0, $e0, $d0, $30, $f8
	db $08, $fc, $24, $bf, $fc, $54, $fc, $44, $fc, $84, $5a, $30, $14, $ff, $fe, $d6
	db $ff, $31, $ff, $05, $ff, $23, $3f, $fe, $52, $fc, $0c, $f3, $f3, $6e, $06, $75
	db $32, $7d, $0f, $7b, $32, $27, $ff, $a7, $ff, $93, $85, $30, $ef, $1e, $ff, $f0
	db $f8, $8e, $06, $ff, $fc, $fe, $be, $e2, $00, $f0, $f0, $f8, $f8, $fc, $a1, $31
	db $f8, $f9, $fc, $56, $13, $5a, $10, $3c, $3c, $3e, $06, $0f, $fd, $79, $6b, $20
	db $02, $07, $02, $03, $1e, $1f, $ff, $1d, $33, $37, $2f, $34, $2c, $34, $6c, $ff
	db $74, $4c, $74, $4c, $64, $dc, $e4, $9c, $cf, $e4, $9c, $88, $fc, $26, $35, $db
	db $3f, $01, $03, $fd, $02, $ef, $30, $82, $c3, $42, $e3, $21, $f3, $fe, $7a, $30
	db $fa, $ef, $fb, $2a, $7e, $4c, $7e, $f7, $48, $f8, $88, $05, $00, $90, $f8, $60
	db $f0, $df, $0e, $1f, $d1, $ff, $20, $71, $00, $8a, $ff, $ff, $bf, $ff, $e9, $ff
	db $bb, $cf, $7f, $8b, $ff, $fe, $07, $b4, $cf, $4b, $ff, $3d, $7b, $f1, $06, $91
	db $20, $be, $16, $c3, $10, $bc, $be, $42, $7f, $ff, $b9, $c7, $c1, $3f, $01, $ff
	db $71, $ff, $fb, $8d, $df, $ac, $15, $0c, $0e, $0e, $0e, $06, $7f, $0f, $3b, $3f
	db $3d, $3f, $07, $0f, $f0, $31, $f4, $be, $3d, $ea, $3d, $ff, $fb, $30, $8f, $fb
	db $7a, $fe, $fb, $0c, $0e, $6a, $17, $89, $fb, $8a, $fb, $4a, $ff, $7b, $ca, $fb
	db $4a, $fb, $29, $fb, $2f, $9e, $fb, $30, $cf, $fb, $3a, $7e, $86, $05, $0e, $0b
	db $b9, $f7, $cf, $79, $8f, $20, $0b, $42, $3c, $8b, $46, $ff, $05, $83, $05, $83
	db $4d, $83, $39, $c7, $0f, $83, $7e, $7e, $3c, $dc, $3d, $18, $88, $03, $07, $1f
	db $3f, $3d, $23, $3f, $3f, $14, $8c, $18, $38, $38, $68, $e8, $d8, $d0, $b8, $e0
	db $f0, $00, $80, $ff, $a6, $01, $00, $60, $80, $82, $7c, $05, $02, $20, $1f, $52
	db $21, $21, $40, $21, $40, $84, $7b, $41, $32, $20, $13, $82, $7c, $d0, $20, $08
	db $f0, $32, $cc, $98, $63, $8d, $02, $40, $3c, $20, $c0, $06, $84, $88, $70, $14
	db $88, $04, $8c, $88, $70, $72, $8c, $7d, $82, $be, $41, $46, $39, $0b, $04, $ff
	db $04, $44, $0f, $44, $f0, $44, $0f, $7f, $44, $f0, $0c, $ff, $d0, $02, $fd, $00
	db $ee, $36, $03, $07, $07, $05, $05, $0f, $ff, $0e, $0b, $0a, $1e, $1c, $16, $14
	db $3c, $ff, $38, $2c, $28, $78, $70, $58, $50, $f0, $fe, $ee, $33, $01, $03, $0f
	db $1e, $7e, $f1, $f7, $7f, $8f, $fe, $ff, $10, $1f, $1f, $1f, $ee, $37, $ff, $00
	db $00, $42, $e3, $21, $f1, $50, $b8, $ff, $f8, $f8, $fe, $06, $f7, $f9, $fd, $fe
	db $ff, $0e, $ff, $03, $ff, $e3, $ff, $11, $3f, $ff, $09, $1f, $04, $0f, $0e, $1f
	db $17, $3d, $ff, $05, $1f, $fd, $72, $77, $b8, $ff, $b8, $ff, $fe, $a9, $bd, $c3
	db $7f, $7f, $8d, $9f, $ff, $c6, $4d, $ff, $7f, $7f, $a0, $e0, $bf, $ff, $b0, $df
	db $ff, $df, $5f, $e0, $7f, $ff, $ff, $3b, $fd, $6d, $f3, $9e, $ff, $88, $fc, $ff
	db $b4, $fc, $c4, $fe, $7a, $fe, $2e, $f3, $ff, $95, $fb, $ff, $ff, $a9, $57, $53
	db $fe, $ff, $56, $fd, $fd, $fb, $fb, $07, $fe, $ff, $df, $6c, $b7, $83, $c2, $02
	db $f9, $32, $0f, $1f, $ff, $1f, $30, $37, $6f, $6f, $df, $d8, $bf, $ff, $b0, $7f
	db $60, $ff, $c7, $ff, $84, $fc, $ff, $1c, $fe, $3a, $ef, $28, $fe, $80, $c0, $ff
	db $80, $80, $00, $80, $00, $00, $fc, $fe, $ff, $fe, $02, $fe, $fe, $e0, $f0, $20
	db $e0, $cf, $40, $e0, $80, $c0, $b2, $01, $ee, $33, $b1, $ff, $cf, $ef, $ff, $00
	db $01, $22, $09, $dc, $0b, $b6, $ff, $cf, $6d, $b6, $db, $ff, $dc, $0f, $ee, $35
	db $fd, $12, $ff, $77, $88, $ff, $e0, $16, $19, $0d, $0b, $ef, $07, $07, $85, $87
	db $5c, $0f, $fc, $ff, $f3, $ff, $fc, $ef, $f0, $dd, $e3, $bb, $c7, $bb, $e7, $c7
	db $7b, $87, $3a, $13, $36, $11, $dd, $e3, $ef, $df, $f0, $f3, $fc, $fc, $ff, $2e
	db $13, $df, $e0, $ff, $bf, $c0, $be, $c1, $7d, $83, $7b, $87, $ff, $77, $8f, $7f
	db $8f, $bf, $cf, $be, $c7, $fb, $df, $e0, $48, $1d, $b0, $cf, $6f, $9f, $7f, $7e
	db $7b, $10, $6f, $9f, $b0, $cf, $bf, $c0, $66, $15, $34, $8d, $1d, $fc, $0c, $80
	db $b6, $00, $fe, $ff, $b0, $10, $8d, $15, $f3, $f4, $f8, $b4, $17, $9a, $13, $80
	db $00, $a0, $c0, $cf, $e8, $f0, $f8, $fc, $b6, $00, $8d, $10, $80, $c0, $bf, $c0
	db $e0, $e0, $f0, $f8, $f0, $d5, $10, $f8, $ef, $f8, $fc, $fe, $fc, $12, $00, $00
	db $05, $03, $ff, $17, $0f, $1f, $3f, $3f, $7e, $7b, $fc, $df, $fb, $f1, $2f, $1f
	db $7f, $8d, $12, $bf, $ff, $6d, $ff, $00, $22, $01, $03, $f8, $30, $0f, $1f, $95
	db $00, $ff, $3f, $1e, $1e, $3c, $7e, $3c, $f7, $e3, $ff, $ef, $c7, $dd, $8e, $9d
	db $19, $1b, $03, $3f, $47, $03, $ec, $46, $c8, $85, $07, $24, $8d, $11, $fe, $00
	db $22, $3c, $79, $79, $7b, $ff, $7b, $73, $ef, $f7, $ff, $f7, $f7, $8d, $12, $93
	db $81, $1d, $e7, $b8, $bb, $76, $2f, $27, $ee, $19, $7a, $fc, $f1, $fd, $f8, $fe
	db $13, $fb, $f7, $df, $8f, $3f, $3f, $fa, $00, $20, $e7, $0e, $2a, $3f, $7d, $3f
	db $f3, $e1, $ff, $c1, $e0, $d0, $8c, $3c, $98, $f9, $30, $ff, $f3, $61, $e9, $c1
	db $dc, $c8, $df, $8f, $d7, $bf, $3f, $7f, $00, $22, $df, $a0, $22, $da, $b8, $01
	db $be, $48, $23, $8d, $14, $80, $01, $ff, $00, $01, $0f, $1f, $75, $fb, $ff, $83
	db $df, $7a, $77, $0c, $1e, $00, $fa, $3f, $00, $df, $ff, $bc, $ed, $de, $bf, $6e
	db $3f, $ea, $ef, $ff, $f0, $1f, $3f, $05, $0f, $05, $07, $3f, $ff, $7f, $7f, $40
	db $7f, $7f, $30, $7f, $1b, $ff, $3f, $0e, $1d, $06, $0d, $03, $03, $7b, $ff, $9c
	db $e7, $3f, $e3, $3f, $a5, $7f, $79, $ff, $ff, $d3, $fe, $6f, $bd, $ee, $bb, $fc
	db $ff, $f7, $f8, $0f, $f0, $ff, $07, $ff, $0e, $ff, $f9, $98, $f7, $f8, $f7, $ff
	db $ff, $fe, $df, $ff, $7d, $83, $83, $7f, $52, $01, $03, $ff, $fe, $58, $07, $83
	db $ff, $c7, $ff, $7e, $ff, $7c, $ff, $fe, $f8, $fc, $05, $07, $03, $07, $06, $fd
	db $05, $70, $0f, $0c, $1f, $35, $7a, $5b, $64, $7f, $7f, $7f, $d0, $70, $e0, $f0
	db $b0, $8f, $0f, $ff, $f0, $b0, $f8, $dc, $7e, $ee, $3e, $fe, $ff, $fe, $ff, $84
	db $dd, $e2, $bf, $78, $05, $07, $fe, $fb, $fe, $1a, $01, $1c, $0f, $6e, $0f, $84
	db $07, $fc, $31, $f8, $8e, $0f, $a4, $07, $fc, $31, $2a, $77, $1d, $37, $14, $e7
	db $1c, $08, $08, $fc, $3f, $1c, $13, $5d, $77, $3e, $ff, $7f, $0f, $1f, $1e, $39
	db $3b, $27, $1f, $ff, $3f, $07, $0e, $0e, $09, $07, $0f, $00, $ed, $01, $41, $11
	db $00, $01, $1c, $18, $80, $80, $80, $ff, $00, $80, $c0, $c0, $a0, $60, $f0, $f0
	db $ff, $fa, $df, $df, $b5, $bd, $77, $f7, $6d, $ff, $bd, $ef, $17, $3f, $02, $07
	db $00, $00, $9c, $30, $78, $58, $7c, $76, $df, $bd, $d3, $d6, $be, $38, $dc, $7c
	db $9c, $f4, $9c, $78, $dc, $b6, $ff, $dd, $f3, $76, $fe, $78, $78, $30, $78, $04
	db $81, $fe, $49, $ff, $b2, $f7, $0f, $ff, $00, $fe, $3f, $fd, $42, $fd, $92, $fd
	db $ba, $7d, $92, $bb, $44, $47, $b8, $bf, $40, $cf, $b0, $5d, $77, $3e, $7f, $35
	db $2b, $1f, $3f, $1a, $15, $0f, $1f, $0d, $0a, $07, $0f, $06, $05, $03, $07, $0c
	db $1f, $35, $7a, $5b, $64, $7f, $7f, $0b, $44, $80, $91, $c0, $40, $c0, $c0, $e0
	db $a0, $60, $e0, $f0, $b0, $f8, $dc, $7e, $ee, $3e, $fe, $fe, $0c, $42, $01, $92
	db $00, $01, $03, $02, $01, $03, $06, $05, $03, $07, $0c, $1f, $35, $7a, $5b, $64
	db $7f, $7f, $04, $9c, $5d, $77, $3e, $7f, $d6, $ae, $7c, $fe, $ac, $5c, $f8, $fc
	db $58, $b8, $f0, $f8, $b0, $70, $e0, $f0, $b0, $f8, $dc, $7e, $ee, $3e, $fe, $fe
	db $04, $a3, $02, $67, $37, $3f, $1f, $3f, $3f, $7f, $73, $ff, $ed, $f2, $3e, $29
	db $3f, $29, $3f, $21, $6f, $5f, $ff, $91, $f5, $9a, $ff, $8e, $bf, $c8, $5f, $65
	db $37, $3b, $30, $78, $7d, $45, $ff, $a2, $83, $ff, $7d, $83, $fe, $01, $f7, $19
	db $f7, $19, $ff, $01, $ff, $01, $ff, $82, $ff, $7c, $7f, $80, $bf, $40, $df, $a0
	db $30, $70, $e0, $f0, $e0, $e0, $ec, $fe, $f8, $fc, $43, $f8, $b3, $f9, $b9, $7f
	db $ff, $3f, $be, $7f, $fe, $7e, $7a, $e7, $ff, $db, $ef, $33, $fe, $23, $db, $27
	db $da, $bd, $ff, $9c, $fd, $5e, $7f, $de, $ff, $de, $7b, $de, $f3, $be, $e3, $be
	db $e3, $be, $7e, $d5, $7d, $63, $3e, $7f, $1b, $3f, $0e, $1d, $06, $0d, $03, $03
	db $ff, $a0, $03, $43, $11, $40, $10, $28, $11, $22, $20, $90, $04, $0b, $40, $b3
	db $6f, $de, $0b, $16, $86, $12, $0a, $05, $00, $02, $00, $08, $00, $12, $44, $84
	db $00, $00, $43, $01, $96, $40, $24, $0a, $04, $01, $dc, $b8, $b4, $f0, $e0, $00
	db $80, $20, $c2, $26, $05, $0a, $55, $ab, $4a, $12, $01, $03, $be, $c0, $20, $10
	db $88, $00, $06, $1c, $20, $04, $f2, $38, $e0, $8c, $20, $90, $08, $22, $00, $02
	db $05, $52, $59, $88, $04, $40, $a9, $44, $43, $04, $24, $3a, $32, $bc, $78, $fc
	db $fc, $c2, $04, $90, $50, $a8, $00, $02, $01, $0a, $04, $0a, $14, $4a, $3d, $ae
	db $17, $25, $d8, $62, $39, $7f, $1f, $bf, $1f, $fe, $ff, $41, $ce, $85, $87, $89
	db $f3, $c0, $e1, $7f, $a0, $08, $38, $c8, $2b, $0c, $10, $20, $41, $c0, $60, $f8
	db $04, $3f, $4c, $90, $21, $04, $08, $78, $8c, $04, $82, $83, $01, $20, $27, $38
	db $21, $22, $40, $80, $00, $43, $42, $95, $21, $18, $24, $22, $3e, $23, $44, $48
	db $08, $17, $08, $10, $9f, $01, $01, $02, $04, $88, $50, $30, $e0, $07, $be, $40
	db $21, $13, $03, $00, $f8, $0c, $06, $1e, $78, $10, $08, $c7, $01, $02, $00, $00
	db $20, $20, $70, $80, $38, $44, $83, $81, $60, $70, $70, $78, $78, $fc, $fc, $fe
	db $3c, $f8, $60, $20, $10, $ef, $01, $00, $01, $03, $04, $08, $3c, $fe, $1f, $8f
	db $c0, $e1, $f9, $7f, $3f, $3f, $1f, $9f, $fe, $fe, $e7, $c3, $c3, $41, $c1, $82
	db $e1, $e0, $ff, $09, $87, $0f, $18, $37, $6f, $5e, $5d, $5b, $09, $87, $ff, $00
	db $ff, $ff, $00, $ff, $00, $50, $5a, $7f, $09, $87, $07, $0f, $18, $30, $61, $63
	db $66, $09, $42, $ff, $02, $42, $ff, $81, $00, $50, $66, $ff, $ff, $00, $0f, $0f
	db $0f, $1f, $1f, $1f, $3f, $db, $00, $ff, $f9, $13, $00, $e0, $01, $00, $c0, $c0
	db $fb, $c0, $00, $08, $01, $01, $07, $3f, $3f, $3f, $fb, $7f, $7f, $f9, $14, $ff
	db $fe, $fc, $f0, $c0, $f3, $80, $80, $08, $02, $08, $03, $03, $03, $07, $07, $3d
	db $1f, $13, $08, $fc, $f8, $f8, $fc, $07, $03, $08, $00, $ed, $03, $2d, $01, $07
	db $00, $f8, $14, $00, $00, $fc, $e6, $3c, $01, $f8, $07, $f1, $13, $f8, $16, $f0
	db $f0, $f0, $a8, $01, $01, $25, $05, $f1, $12, $3f, $13, $07, $f8, $71, $01, $c0
	db $e6, $21, $01, $03, $0f, $83, $00, $13, $06, $ff, $ff, $f8, $58, $93, $00, $21
	db $00, $21, $06, $01, $01, $2c, $00, $03, $f8, $16, $fb, $fe, $fe, $3b, $00, $fc
	db $fc, $00, $00, $1f, $ff, $1e, $1e, $3c, $3d, $3f, $3f, $00, $1f, $7f, $3e, $7c
	db $f8, $f1, $e1, $c3, $00, $31, $00, $ff, $f3, $e1, $e1, $c1, $00, $83, $c3, $c3
	db $ff, $e7, $e7, $e7, $ef, $00, $e1, $e1, $e1, $ef, $e3, $f3, $f3, $77, $00, $00
	db $e1, $c1, $c3, $7b, $c7, $87, $c7, $01, $de, $de, $9e, $9e, $f0, $10, $fe, $f4
	db $10, $3d, $3d, $00, $c1, $c3, $c3, $c7, $f7, $c7, $cf, $ce, $59, $02, $78, $79
	db $79, $00, $fb, $78, $78, $70, $02, $7f, $7b, $7b, $f9, $f1, $7b, $f0, $f0, $e8
	db $01, $e3, $e1, $f1, $f0, $10, $11, $7f, $e7, $ff, $ff, $fc, $00, $ef, $cf, $05
	db $10, $ff, $3c, $3c, $00, $77, $77, $7f, $3f, $3f, $7f, $3e, $3e, $00, $8f, $9f
	db $1f, $3f, $21, $10, $fb, $00, $1e, $c8, $00, $1e, $1e, $1e, $00, $3d, $ff, $79
	db $79, $79, $f1, $f1, $f1, $00, $de, $ef, $dc, $fc, $f8, $f9, $65, $10, $f1, $f3
	db $f3, $15, $f3, $ec, $00, $00, $04, $01, $80, $20, $00, $21, $2e, $7a, $cd, $80
	db $22, $cd, $96, $1e, $11, $20, $00, $cd, $65, $1e, $21, $ab, $7b, $cd, $f3, $1d
	db $11, $00, $94, $21, $00, $d8, $01, $58, $00, $cd, $9c, $7b, $01, $18, $00, $cd
	db $8d, $7b, $01, $18, $00, $cd, $9c, $7b, $01, $08, $01, $af, $cd, $a7, $04, $12
	db $13, $2a, $12, $13, $0b, $78, $b1, $20, $f2, $c9, $2a, $cd, $a7, $04, $12, $13
	db $af, $12, $13, $0b, $78, $b1, $20, $f2, $c9, $a4, $98, $83, $40, $41, $42, $7f
	db $c3, $98, $84, $43, $44, $45, $46, $7f, $e1, $98, $93, $47, $48, $49, $4a, $4b
	db $4c, $4d, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $2f, $7f, $01
	db $99, $92, $4e, $4f, $50, $51, $52, $53, $54, $67, $68, $69, $6a, $6b, $6c, $6d
	db $6e, $6f, $70, $71, $7f, $23, $99, $84, $55, $56, $57, $58, $7f, $42, $99, $83
	db $59, $5a, $5b, $ff, $fa, $81, $c9, $c7, $03, $16, $49, $7c, $fc, $15, $67, $7c
	db $7c, $7c, $8a, $7c, $98, $7c, $a3, $7c, $ae, $7c, $b9, $7c, $fc, $15, $c4, $7c
	db $fc, $15, $d8, $7c, $e9, $7c, $d1, $21, $91, $c9, $fa, $82, $c9, $e6, $03, $c0
	db $34, $7e, $d5, $c9, $cd, $70, $16, $cd, $59, $16, $c3, $84, $21, $3e, $4e, $cd
	db $10, $05, $cd, $26, $7c, $21, $ff, $7c, $c3, $54, $7c, $cd, $18, $7c, $fe, $00
	db $c0, $21, $ff, $7c, $c3, $76, $7c, $3e, $63, $cd, $10, $05, $cd, $26, $7c, $21
	db $06, $7d, $3e, $f0, $ea, $91, $c9, $01, $00, $1a, $cd, $96, $11, $cd, $1e, $09
	db $3e, $c0, $c3, $f4, $15, $cd, $18, $7c, $fe, $40, $c0, $01, $00, $18, $cd, $96
	db $11, $21, $06, $7d, $cd, $1a, $09, $c3, $f7, $15, $21, $18, $7d, $3e, $30, $ea
	db $91, $c9, $cd, $1e, $09, $c3, $f7, $15, $cd, $18, $7c, $fe, $f0, $c0, $21, $18
	db $7d, $cd, $1a, $09, $18, $e7, $cd, $18, $7c, $fe, $b0, $c0, $21, $47, $7d, $18
	db $f0, $cd, $18, $7c, $fe, $c0, $c0, $21, $65, $7d, $18, $e5, $cd, $18, $7c, $fe
	db $f0, $c0, $21, $8e, $7d, $18, $da, $cd, $18, $7c, $fe, $78, $c0, $3e, $40, $c3
	db $f4, $15, $cd, $18, $7c, $fe, $b0, $c0, $21, $c4, $7d, $cd, $1a, $09, $3e, $00
	db $21, $0e, $7d, $c3, $56, $7c, $21, $91, $c9, $fa, $82, $c9, $e6, $03, $c0, $35
	db $7e, $fe, $f0, $c0, $c3, $f7, $15, $fa, $87, $c9, $e6, $90, $c8, $3e, $01, $ea
	db $a7, $c9, $21, $0e, $7d, $cd, $1a, $09, $3e, $04, $c3, $e6, $15, $e8, $9b, $ac
	db $a2, $b5, $a8, $ff, $e7, $9b, $b5, $a8, $a2, $ae, $ae, $ff, $e6, $9b, $a8, $b0
	db $a4, $90, $a4, $b3, $ad, $ff, $02, $9a, $a0, $a5, $a6, $af, $a5, $a2, $aa, $aa
	db $a4, $a5, $fe, $86, $9a, $a8, $ba, $b0, $a2, $af, $a9, $b0, $a2, $a5, $a2, $fe
	db $e6, $9a, $a3, $ba, $b0, $a2, $a3, $a2, $b3, $a6, $fe, $46, $9b, $b2, $ba, $aa
	db $a9, $a7, $a5, $a2, $ff, $02, $9a, $af, $a5, $a2, $a0, $b0, $a9, $ac, $90, $ad
	db $a4, $b5, $a9, $af, $b3, $a4, $a5, $fe, $86, $9a, $b2, $ba, $b2, $a9, $aa, $a7
	db $a5, $a2, $ff, $02, $9a, $b5, $a6, $a7, $b3, $ad, $90, $ac, $a5, $a4, $a2, $a8
	db $a6, $a5, $fe, $86, $9a, $b0, $ba, $ae, $a7, $b3, $a2, $a7, $ac, $b0, $a9, $fe
	db $e6, $9a, $aa, $ba, $b5, $b0, $a9, $b3, $ad, $a6, $a7, $ff, $02, $9a, $b5, $a0
	db $a4, $ac, $a9, $a2, $a1, $90, $a8, $b0, $a2, $b3, $b2, $b5, $fe, $86, $9a, $b0
	db $ba, $ae, $a7, $b3, $a2, $ab, $a9, $b2, $a9, $fe, $e6, $9a, $a8, $a4, $ad, $90
	db $b0, $a9, $b2, $a2, $b7, $a2, $fe, $46, $9b, $a2, $ba, $a8, $a6, $a3, $a2, $aa
	db $a2, $ff, $04, $9a, $a0, $a5, $a4, $b5, $a4, $b3, $a8, $a4, $ad, $90, $ab, $a3
	db $fe, $47, $9a, $b2, $a6, $b3, $a2, $aa, $a9, $ff, $cd, $98, $13, $3e, $01, $ea
	db $c1, $c9, $3e, $00, $ea, $c2, $c9, $cd, $59, $16, $cd, $21, $21, $21, $f6, $49
	db $11, $c0, $99, $cd, $40, $13, $01, $00, $98, $11, $0b, $9a, $26, $08, $cd, $f8
	db $7e, $01, $4a, $98, $11, $16, $9a, $26, $0a, $cd, $f8, $7e, $21, $2e, $49, $11
	db $60, $99, $cd, $40, $13, $01, $08, $98, $11, $73, $99, $cd, $d2, $7e, $01, $48
	db $98, $11, $93, $99, $cd, $d2, $7e, $01, $49, $98, $11, $60, $99, $cd, $d2, $7e
	db $01, $89, $98, $11, $80, $99, $cd, $d2, $7e, $01, $ca, $98, $21, $0e, $7f, $cd
	db $ea, $0a, $0e, $d2, $cd, $ea, $0a, $0e, $cf, $cd, $f8, $0a, $0e, $ec, $cd, $f8
	db $0a, $01, $f1, $98, $cd, $ea, $0a, $01, $50, $04, $cd, $93, $11, $c3, $f7, $15
	db $cd, $98, $13, $3e, $01, $ea, $c1, $c9, $3e, $00, $ea, $c2, $c9, $cd, $59, $16
	db $cd, $80, $13, $21, $2e, $49, $11, $21, $98, $cd, $40, $13, $01, $01, $98, $11
	db $21, $98, $26, $06, $cd, $d8, $7e, $01, $07, $98, $11, $34, $98, $cd, $d2, $7e
	db $01, $47, $98, $11, $54, $98, $cd, $d2, $7e, $01, $28, $98, $11, $07, $19, $cd
	db $0c, $0b, $cd, $3c, $0b, $01, $41, $99, $11, $01, $98, $cd, $d6, $7e, $01, $61
	db $99, $11, $61, $98, $cd, $d6, $7e, $06, $80, $cd, $43, $20, $16, $c0, $3e, $01
	db $e7, $14, $3e, $09, $e7, $21, $e0, $cd, $36, $e7, $2c, $36, $7e, $c3, $f7, $15
	db $26, $01, $18, $02, $26, $07, $2e, $06, $c5, $d5, $e5, $cd, $a7, $04, $1a, $02
	db $1c, $0c, $25, $20, $f6, $7d, $e1, $6f, $d1, $c1, $3e, $20, $cd, $40, $16, $3e
	db $20, $df, $2d, $20, $e3, $c9, $cd, $fe, $7e, $cd, $d8, $7e, $c5, $e5, $3e, $df
	db $cd, $59, $0b, $25, $20, $fa, $e1, $c1, $3e, $20, $df, $c9, $60, $61, $62, $63
	db $6d, $6e, $6b, $6c, $66, $69, $64, $65, $6a, $6b, $51, $6f, $ff, $ff, $ff, $ff
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
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $06
