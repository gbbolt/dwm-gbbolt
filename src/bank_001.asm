INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

BankNumber_01::
	db $01

FarTable_01::
	dw Call_01_401D
	dw $4dd3
	dw Call_01_421C
	dw Call_01_484E
	dw Call_01_4845
	dw Call_01_46F6
	dw Call_01_4686
	dw Call_01_4C58
	dw Call_01_5A72
	dw Call_01_4BC1
	dw Call_01_5D6D
	dw Call_01_683E
	dw Call_01_69C8
	dw Call_01_69E1

Call_01_401D::
	ld hl, sp+$00
	ld a, l
	ld [$da7b], a
	ld a, h
	ld [$da7c], a
	xor a
	ld hl, $c827
	ld bc, $0012
	call Call_12C7
	call Call_3331
	xor a
	ld [$c8b5], a
	xor a
	ld [$c88f], a
	call Call_01_43E3
	call Call_1C89
	call Call_01_431A
	ld hl, $8b00
	ld de, $1202
	call Call_098F
	ld a, $fc
	call Call_1688
	call Call_01_4074
	ld a, $07
	ldh [$ffb5], a
	ld a, $ff
	ldh [$ffb6], a
	ld a, $7f
	ldh [rLYC], a
	ld a, $63
	ld [$c8a1], a
	ld a, $01
	ld [$c892], a
	call Call_125D
	ld a, $03
	jp Jump_000_11cb


Call_01_4074::
	call Call_01_421C
	call Call_01_42E4
	call Call_01_4429
	ld hl, far_Call_17_41C0
	rst $10
	ld a, [$c8ab]
	or a
	call nz, Call_01_4C95
	call Call_01_46F6
	call Call_01_484E
	ld hl, far_Call_0B_40CE
	rst $10
	ld hl, far_Call_0B_470F
	rst $10
	call Call_01_4C10
	ld a, [$c8a6]
	push af
	xor a
	ld [$c8a6], a
	ld hl, far_Call_06_4028
	rst $10
	pop af
	ld [$c8a6], a
	ld hl, $d7b6
	ld a, l
	ld [$d7b4], a
	ld a, h
	ld [$d7b5], a
	xor a
	ld [$d7ba], a
	ld [$d7bb], a
	ld [$d7b6], a
	ldh a, [$ff8a]
	ld [$d7b7], a
	ldh a, [$ff8f]
	add $00
	ld [$d7b8], a
	ld hl, far_Call_02_400D
	rst $10
	ld a, [$d7ba]
	ldh [$ff8b], a
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ld a, [$c968]
	ld [$c96a], a
	ld a, [$c969]
	ld [$c96b], a
	ld a, [$c969]
	or a
	jr nz, jr_001_4105

	ld a, [$c968]
	cp $5e
	jr nz, jr_001_4105

	ld hl, far_Call_56_4485
	rst $10
	jr jr_001_410b

jr_001_4105:
	call Call_2518
	call Call_25F1

jr_001_410b:
	ld a, $01
	ld [$c8ea], a
	xor a
	ld [$c8a8], a
	xor a
	ld [$c96c], a
	xor a
	ld [$c740], a
	ld [$c741], a
	ld a, $ff
	ld [$c742], a
	ldh a, [$ffb7]
	ldh [$ffb9], a
	ldh a, [$ffb8]
	ldh [$ffba], a
	ldh a, [$ffbb]
	ldh [$ffbd], a
	ldh a, [$ffbc]
	ldh [$ffbe], a
	ld hl, far_Call_01_5D6D
	rst $10
	ret


Jump_001_4139:
	ld a, [$c88f]
	cp $02
	jp z, Jump_001_41dc

	ld a, [$c850]
	or a
	ret nz

	call Call_01_43E3
	ld b, a
	ld a, [$c81b]
	cp b
	jr z, jr_001_4155

	ld hl, $c88e
	inc [hl]
	ret


jr_001_4155:
	xor a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld hl, $9800
	ld b, $00

jr_001_4161:
	ld a, $e0
	call Call_1AB9
	call Call_1AB9
	call Call_1AB9
	call Call_1AB9
	dec b
	jr nz, jr_001_4161

	call Call_01_4074
	call Call_122F
	ld a, [$c817]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
	ld [$c85b], a
	ld a, h
	ld [$c85c], a
	inc hl
	ld a, l
	ld [$c85d], a
	ld a, h
	ld [$c85e], a
	inc hl
	ld a, l
	ld [$c85f], a
	ld a, h
	ld [$c860], a
	inc hl
	ld a, l
	ld [$c861], a
	ld a, h
	ld [$c862], a
	ld a, $b1
	ld [$c777], a
	ld a, [$c818]
	ld [$c778], a
	ld a, $ff
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld hl, far_Call_08_422C
	rst $10
	xor a
	ld [$c842], a
	ld [$c843], a
	xor a
	ld [$c846], a
	ld [$c847], a
	xor a
	ld [$c848], a
	ld [$c849], a
	call Call_01_4DDA
	ld a, $02
	ld [$c88f], a
	ret


Jump_001_41dc:
	xor a
	ld [$c842], a
	ld [$c843], a
	xor a
	ld [$c846], a
	ld [$c847], a
	xor a
	ld [$c848], a
	ld [$c849], a
	call Call_01_4DDA
	xor a
	ld [$c88f], a
	ld hl, $c89b
	ld a, $d2
	ld [hli], a
	ld a, $d2
	ld [hli], a
	ld a, $e2
	ld [hl], a
	ld hl, $c89e
	ld a, [$c89b]
	ld [hli], a
	ld a, [$c89c]
	ld [hli], a
	ld a, [$c89d]
	ld [hl], a
	call Call_1660
	ld a, $fd
	call Call_1688
	ret


Call_01_421C::
	xor a
	ld [$c8aa], a
	xor a
	ldh [$ffd3], a
	ld a, $80
	ldh [$ffd4], a
	xor a
	ld [$c915], a
	ld [$c916], a
	ld a, [$c8ea]
	or a
	ret nz

	xor a
	ld [$c93e], a
	xor a
	ld [$ca3f], a
	xor a
	ld [$c8ec], a
	xor a
	ld [$c8eb], a
	xor a
	ld [$d8d7], a
	ld [$d8d8], a
	ld a, $04
	ld [$c8ee], a
	ld hl, $0064
	ld a, l
	ld [$ca3b], a
	ld a, h
	ld [$ca3c], a
	ld hl, $0014
	ld a, l
	ld [$ca3d], a
	ld a, h
	ld [$ca3e], a
	ld hl, $d92a
	ld bc, $00c0
	ld a, $00
	call Call_12C7
	ld a, [$c969]
	or a
	jr nz, jr_001_427d

	ld a, [$c968]
	cp $08
	jr z, jr_001_4291

jr_001_427d:
	ld a, $d3
	ld [$ca42], a
	ld a, $d4
	ld [$ca43], a
	ld a, $d5
	ld [$ca44], a
	ld a, $d6
	ld [$ca45], a

jr_001_4291:
	ld a, [$c899]
	ld [$ca4a], a
	ld a, [$c8ab]
	or a
	ret nz

	ld a, $00
	ld [$ca8d], a
	ld a, $ff
	ld [$ca8e], a
	ld a, $ff
	ld [$ca8f], a
	ld a, $ff
	ld [$ca90], a
	ld a, $00
	ld [$ca4b], a
	ld a, $00
	ld [$ca4c], a
	ld a, $00
	ld [$ca4d], a
	ld hl, $ca51
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $ca65
	ld bc, $0028
	ld a, $ff
	call Call_12C7
	ld hl, $cac1
	ld b, $14
	ld de, $0095

jr_001_42dd:
	ld [hl], $00
	add hl, de
	dec b
	jr nz, jr_001_42dd

	ret


Call_01_42E4::
	ld a, [$c88e]
	or a
	jr nz, jr_001_42f6

	ld a, [$c88f]
	or a
	jr z, jr_001_42f6

	ld a, [$d9e9]
	ld [$d988], a

jr_001_42f6:
	xor a
	ld [$d9e9], a
	ld hl, far_Call_0B_4015
	rst $10
	ld a, [$c8b5]
	ld b, a
	push bc
	call Call_01_432D
	pop bc
	cp b
	call nz, Call_1AE1
	ld a, [$c88f]
	or a
	ret nz

	ld de, $2e00
	ld hl, $8d00
	call Call_14CF
	ret


Call_01_431A::
	ld hl, $2add
	ld a, [hl]
	ld [$c817], a
	ld hl, $2ade
	ld a, [hl]
	ld [$c818], a
	ld hl, far_Call_08_41E3
	rst $10
	ret


Call_01_432D::
	ld a, [$c969]
	or a
	jr nz, jr_001_4358

	ld a, [$c968]
	cp $50
	jr c, jr_001_4346

	cp $52
	jr z, jr_001_4346

	cp $5d
	jr c, jr_001_4358

	cp $61
	jr nc, jr_001_4358

jr_001_4346:
	ld hl, $4373
	ld a, [$c968]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld a, b
	cp $09
	ret nz

	ret


jr_001_4358:
	ld a, [$c939]
	ld b, a
	ld a, [$c93a]
	sub $02
	cp b
	ld a, $34
	ret nz

	ld hl, $4373
	ld a, [$c93b]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


	db $09, $09, $09, $09, $09, $09, $1e, $1e, $31, $31, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $1e, $1e, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $9d
	db $34, $0c, $0c, $18, $15, $0c, $2e, $18, $0f, $18, $12, $2e, $1b, $12, $1b, $1b
	db $1b, $1b, $1b, $1b, $12, $1b, $0c, $0f, $12, $12, $15, $15, $18, $1b, $1b, $1b
	db $34, $34, $61, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $61, $02, $02
	db $1b, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34

Call_01_43E3::
	ld a, [$c968]
	ldh [$ffd5], a
	ld a, [$c969]
	ldh [$ffd6], a
	ld a, [$c96c]
	or a
	jr z, jr_001_43fd

	ld a, [$c96d]
	ldh [$ffd5], a
	ld a, [$c96e]
	ldh [$ffd6], a

jr_001_43fd:
	ldh a, [$ffd6]
	or a
	jr z, jr_001_4405

	ld a, $00
	ret


jr_001_4405:
	ldh a, [$ffd5]
	cp $5e
	jr z, jr_001_4425

	cp $5d
	jr nz, jr_001_4412

	ld a, $01
	ret


jr_001_4412:
	ldh a, [$ffd5]
	cp $2f
	jr nz, jr_001_441b

	ld a, $02
	ret


jr_001_441b:
	ldh a, [$ffd5]
	cp $30
	ld a, $03
	ret c

	ld a, $00
	ret


jr_001_4425:
	ld a, [$c81b]
	ret


Call_01_4429::
	ld de, $2f00
	ld hl, $8000
	call Call_1577
	ld de, $2e1d
	ld hl, $8180
	call Call_1577
	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a
	ldh [$ffa3], a
	ldh [$ffa4], a
	ldh [$ff91], a
	ldh [$ff94], a
	ld a, [$c96c]
	or a
	jr z, jr_001_4464

	ld a, [$c96f]
	ldh [$ff92], a
	ld a, [$c970]
	ldh [$ff93], a
	ld a, [$c971]
	ldh [$ff95], a
	ld a, [$c972]
	ldh [$ff96], a
	jr jr_001_4498

jr_001_4464:
	ld a, [$c8ea]
	or a
	jp nz, Jump_001_44ba

	ld hl, $ff8a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ldh [$ff8f], a
	ldh [$ff8e], a
	ldh [$ff90], a
	ld [$d7bd], a
	ld a, [$c968]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, l
	add $06
	ld l, a
	ld a, h
	adc $45
	ld h, a
	ld a, [hli]
	ldh [$ff92], a
	ld a, [hli]
	ldh [$ff93], a
	ld a, [hli]
	ldh [$ff95], a
	ld a, [hl]
	ldh [$ff96], a

jr_001_4498:
	ld b, $31
	ld hl, $c973

jr_001_449d:
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
	dec b
	jr nz, jr_001_449d

	xor a
	ld [$ca37], a

Jump_001_44ba:
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ldh [$ff97], a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ldh [$ff98], a
	ldh a, [$ff92]
	ldh [$ff99], a
	ldh a, [$ff93]
	ldh [$ff9a], a
	ldh a, [$ff95]
	ldh [$ff9b], a
	ldh a, [$ff96]
	ldh [$ff9c], a
	ret


	db $f8, $00, $d8, $00, $e8, $00, $b8, $00, $48, $00, $38, $00, $e8, $00, $c8, $00
	db $e8, $00, $a8, $00, $48, $00, $38, $00, $e8, $00, $38, $00, $e8, $00, $38, $00
	db $48, $00, $38, $00, $e8, $00, $48, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $48, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $38, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $58, $00, $58, $00, $68, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $b8, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $78, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $38, $00, $48, $00, $78, $00, $48, $00, $48, $00, $48, $00, $48, $00
	db $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00
	db $48, $00, $48, $00, $48, $00, $38, $00, $48, $00, $48, $00, $48, $00, $68, $00
	db $48, $00, $68, $00, $48, $00, $68, $00, $68, $00, $68, $00, $48, $00, $68, $00
	db $d8, $00, $d8, $00, $48, $00, $68, $01, $e8, $00, $b8, $00, $f8, $00, $b8, $00
	db $18, $00, $28, $00, $18, $00, $28, $00, $48, $00, $48, $00, $48, $00, $48, $00
	db $68, $00, $48, $00, $48, $00, $38, $00, $48, $00, $38, $00, $48, $00, $38, $00

Call_01_4686::
	ld hl, $cac1
	ld b, $00

jr_001_468b:
	ld a, [hl]
	or a
	jr z, jr_001_4696

	push hl
	push bc
	call Call_01_46A5
	pop bc
	pop hl

jr_001_4696:
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	inc b
	ld a, b
	cp $14
	jr nz, jr_001_468b

	ret


Call_01_46A5::
	push bc
	ld a, b
	ld hl, $caea
	call Call_223B
	pop bc
	ld c, $08

jr_001_46b0:
	ld a, [hli]
	cp $ff
	push hl
	push bc
	call nz, Call_01_46BE
	pop bc
	pop hl
	dec c
	jr nz, jr_001_46b0

	ret


Call_01_46BE::
	ld d, a
	push de
	ld a, b
	ld hl, $caf2
	call Call_223B
	pop de
	push hl
	ld c, $19

jr_001_46cb:
	ld a, [hl]
	cp d
	jr nz, jr_001_46d1

	ld [hl], $ff

jr_001_46d1:
	inc hl
	dec c
	jr nz, jr_001_46cb

	pop hl
	push hl
	ld de, $c0a0
	ld b, $19

jr_001_46dc:
	ld a, [hl]
	ld [de], a
	ld a, $ff
	ld [hli], a
	inc de
	dec b
	jr nz, jr_001_46dc

	pop hl
	ld de, $c0a0
	ld b, $19

jr_001_46eb:
	ld a, [de]
	cp $ff
	jr z, jr_001_46f1

	ld [hli], a

jr_001_46f1:
	inc de
	dec b
	jr nz, jr_001_46eb

	ret


Call_01_46F6::
	ld a, [$ca8e]
	cp $ff
	jr z, jr_001_470c

	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	or a
	jr nz, jr_001_470c

	ld a, $ff
	ld [$ca8e], a

jr_001_470c:
	ld a, [$ca8f]
	cp $ff
	jr z, jr_001_4722

	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	or a
	jr nz, jr_001_4722

	ld a, $ff
	ld [$ca8f], a

jr_001_4722:
	ld a, [$ca90]
	cp $ff
	jr z, jr_001_4738

	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	or a
	jr nz, jr_001_4738

	ld a, $ff
	ld [$ca90], a

jr_001_4738:
	ld hl, $cac1
	ld b, $14

jr_001_473d:
	ld a, [hl]
	or a
	jr z, jr_001_4743

	ld [hl], $01

jr_001_4743:
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_001_473d

	ld a, [$ca8e]
	call Call_01_480D
	ld a, [$ca8f]
	call Call_01_480D
	ld a, [$ca90]
	call Call_01_480D
	ld a, [$ca8e]
	cp $ff
	jr nz, jr_001_4774

	ld hl, $ca8e
	ld a, [$ca8f]
	ld [hli], a
	ld a, [$ca90]
	ld [hli], a
	ld [hl], $ff

jr_001_4774:
	ld a, [$ca8e]
	cp $ff
	jr nz, jr_001_4788

	ld hl, $ca8e
	ld a, [$ca8f]
	ld [hli], a
	ld a, [$ca90]
	ld [hli], a
	ld [hl], $ff

jr_001_4788:
	ld a, [$ca8f]
	cp $ff
	jr nz, jr_001_4798

	ld hl, $ca8f
	ld a, [$ca90]
	ld [hli], a
	ld [hl], $ff

jr_001_4798:
	ld hl, $c0d8
	ld bc, $0014
	ld a, $ff
	call Call_12C7
	ld hl, $c0d8
	ld de, $cac1
	ld b, $14
	ld c, $00

jr_001_47ad:
	ld a, [de]
	or a
	jr z, jr_001_47b3

	ld [hl], c
	inc c

jr_001_47b3:
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc hl
	dec b
	jr nz, jr_001_47ad

	ld c, $14

jr_001_47c1:
	ld hl, $cac1
	ld b, $13

jr_001_47c6:
	ld a, [hl]
	or a
	call z, Call_01_4819
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_001_47c6

	dec c
	jr nz, jr_001_47c1

	ld a, [$ca8e]
	call Call_01_4837
	ld [$ca8e], a
	ld a, [$ca8f]
	call Call_01_4837
	ld [$ca8f], a
	ld a, [$ca90]
	call Call_01_4837
	ld [$ca90], a
	ld hl, $ca8e
	ld b, $03
	ld c, $00

jr_001_47fb:
	ld a, [hli]
	cp $ff
	jr z, jr_001_4801

	inc c

jr_001_4801:
	dec b
	jr nz, jr_001_47fb

	ld a, c
	ld [$ca8d], a
	ld hl, far_Call_01_4686
	rst $10
	ret


Call_01_480D::
	cp $ff
	ret z

	ld hl, $cac1
	call Call_223B
	ld [hl], $02
	ret


Call_01_4819::
	push bc
	push hl
	ld e, l
	ld d, h
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [de]
	or a
	jr z, jr_001_4834

	ld b, $95

jr_001_482b:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	dec b
	jr nz, jr_001_482b

jr_001_4834:
	pop hl
	pop bc
	ret


Call_01_4837::
	cp $ff
	ret z

	ld hl, $c0d8
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Call_01_4845::
	ld a, [$ca8d]
	or a
	jr nz, Call_01_4869

	jr jr_001_4854

	db $c9

Call_01_484E::
	ld a, [$ca8d]
	or a
	jr nz, jr_001_4862

jr_001_4854:
	ld hl, $8dc0
	ld b, $10

jr_001_4859:
	ld a, $ff
	call Call_1AB9
	dec b
	jr nz, jr_001_4859

	ret


jr_001_4862:
	call Call_01_4869
	call Call_01_4942
	ret


Call_01_4869::
	ld hl, $c0a0
	ld bc, $0004
	ld a, $ff
	call Call_12C7
	ld a, [$ca8d]
	or a
	jr z, jr_001_48c1

	ld hl, $c0a0
	push hl
	ld a, $00
	ld hl, $cb0b
	call Call_224A
	pop hl
	bit 7, a
	jr nz, jr_001_488f

	ld a, [$ca8e]
	ld [hli], a

jr_001_488f:
	ld a, [$ca8d]
	cp $01
	jr z, jr_001_48c1

	push hl
	ld a, $01
	ld hl, $cb0b
	call Call_224A
	pop hl
	bit 7, a
	jr nz, jr_001_48a8

	ld a, [$ca8f]
	ld [hli], a

jr_001_48a8:
	ld a, [$ca8d]
	cp $02
	jr z, jr_001_48c1

	push hl
	ld a, $02
	ld hl, $cb0b
	call Call_224A
	pop hl
	bit 7, a
	jr nz, jr_001_48c1

	ld a, [$ca90]
	ld [hli], a

jr_001_48c1:
	ld a, [$ca8d]
	or a
	jr z, jr_001_492f

	push hl
	ld a, $00
	ld hl, $cb0b
	call Call_224A
	pop hl
	bit 7, a
	jr z, jr_001_48e5

	ld a, [$ca8e]
	ld [hli], a
	push hl
	ld a, $00
	ld hl, $cb0b
	call Call_2229
	ld [hl], $80
	pop hl

jr_001_48e5:
	ld a, [$ca8d]
	cp $01
	jr z, jr_001_492f

	push hl
	ld a, $01
	ld hl, $cb0b
	call Call_224A
	pop hl
	bit 7, a
	jr z, jr_001_490a

	ld a, [$ca8f]
	ld [hli], a
	push hl
	ld a, $01
	ld hl, $cb0b
	call Call_2229
	ld [hl], $80
	pop hl

jr_001_490a:
	ld a, [$ca8d]
	cp $02
	jr z, jr_001_492f

	push hl
	ld a, $02
	ld hl, $cb0b
	call Call_224A
	pop hl
	bit 7, a
	jr z, jr_001_492f

	ld a, [$ca90]
	ld [hli], a
	push hl
	ld a, $02
	ld hl, $cb0b
	call Call_2229
	ld [hl], $80
	pop hl

jr_001_492f:
	ld a, [$c0a0]
	ld [$ca8e], a
	ld a, [$c0a1]
	ld [$ca8f], a
	ld a, [$c0a2]
	ld [$ca90], a
	ret


Call_01_4942::
	ld hl, $8da0
	ld b, $18

jr_001_4947:
	ld a, $ff
	call Call_1AB9
	xor a
	call Call_1AB9
	dec b
	jr nz, jr_001_4947

	ld a, [$ca8d]
	or a
	ret z

	ld a, $00
	ld [$cac0], a
	call Call_01_4986
	ld [$ca91], a
	ld a, [$ca8d]
	cp $01
	ret z

	ld a, $01
	ld [$cac0], a
	call Call_01_4986
	ld [$ca92], a
	ld a, [$ca8d]
	cp $02
	ret z

	ld a, $02
	ld [$cac0], a
	call Call_01_4986
	ld [$ca93], a
	ret


Call_01_4986::
	ld hl, $cac1
	call Call_2284
	or a
	ret z

	ld hl, $cb0b
	call Call_2284
	bit 7, a
	ld a, $01
	jr nz, jr_001_49a2

	ld hl, $caca
	call Call_2284
	add $10

jr_001_49a2:
	push af
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $df
	ld l, a
	ld a, h
	adc $49
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [$cac0]
	add $82
	ld h, a
	ld l, $00
	call Call_1577
	ld hl, $cacb
	call Call_2284
	add a
	ld hl, $4bad
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [$cac0]
	swap a
	add $a0
	ld l, a
	ld h, $8d
	call Call_1577
	pop af
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
	db $30, $3a, $31, $3a, $32, $3a, $33, $3a, $34, $3a, $35, $3a, $36, $3a, $03, $2e
	db $04, $2e, $05, $2e, $06, $2e, $07, $2e, $08, $2e, $09, $2e, $0a, $2e, $0b, $2e
	db $0c, $2e

Call_01_4BC1::
	ld hl, $cac1
	ld b, $14

jr_001_4bc6:
	push hl
	ld a, [hl]
	or a
	jr z, jr_001_4c03

	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld [hl], $00
	ld a, l
	add $08
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld e, l
	ld d, h
	ld a, e
	add $fe
	ld e, a
	ld a, d
	adc $ff
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ld a, l
	add $03
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld e, l
	ld d, h
	ld a, e
	add $fe
	ld e, a
	ld a, d
	adc $ff
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a

jr_001_4c03:
	pop hl
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_001_4bc6

	ret


Call_01_4C10::
	ld a, [$c8ea]
	cp $80
	ret z

	ld hl, $d8e9
	ld bc, $0040
	xor a
	call Call_12C7
	xor a
	ld [$d9cb], a
	ld [$d9cc], a
	xor a
	ld [$d9df], a
	ld [$d9e0], a
	ld a, [$d8d7]
	or a
	ret nz

	ld a, [$c969]
	or a
	jr nz, jr_001_4c49

	ld a, $00
	ld [$d8d4], a
	ld a, [$c968]
	ld [$d8d3], a
	ld hl, far_Call_04_55EC
	rst $10
	ret


jr_001_4c49:
	ld a, $00
	ld [$d8d4], a
	ld a, $70
	ld [$d8d3], a
	ld hl, far_Call_04_55EC
	rst $10
	ret


Call_01_4C58::
	ld a, d
	ld hl, $cb25
	call Call_223B
	ld e, l
	ld d, h
	call Call_01_4C89
	ld a, $09
	call Call_1DBE
	ld b, l
	ld a, e
	add $01
	ld e, a
	ld a, d
	adc $00
	ld d, a
	call Call_01_4C89
	ld a, c
	add a
	add c
	add b
	ld b, a
	ld a, e
	add $02
	ld e, a
	ld a, d
	adc $00
	ld d, a
	call Call_01_4C89
	ld a, c
	add b
	ld d, a
	ret


Call_01_4C89::
	ld a, [de]
	ld c, $00
	cp $c0
	ret nc

	inc c
	cp $40
	ret nc

	inc c
	ret


Call_01_4C95::
	xor a
	ld [$c8ab], a
	ld a, $6e
	ld [$ca42], a
	ld a, $86
	ld [$ca43], a
	ld a, $9c
	ld [$ca44], a
	ld a, $f0
	ld [$ca45], a
	ld a, $00
	ld [$ca8e], a
	ld a, $01
	ld [$ca8f], a
	ld a, $02
	ld [$ca90], a
	ld b, $14
	ld c, $00

jr_001_4cc0:
	push bc
	ld a, c
	call Call_01_4D02
	pop bc
	inc c
	dec b
	jr nz, jr_001_4cc0

	ld a, $00
	ld [$ca4b], a
	ld a, $54
	ld [$ca4c], a
	ld a, $01
	ld [$ca4d], a
	ld a, $01
	ld [$ca51], a
	ld a, $02
	ld [$ca52], a
	ld a, $03
	ld [$ca53], a
	ld a, $04
	ld [$ca54], a
	ld a, $05
	ld [$ca55], a
	ld a, $06
	ld [$ca56], a
	ld a, $07
	ld [$ca57], a
	ld a, $08
	ld [$ca58], a
	ret


Call_01_4D02::
	push af
	ld [$da14], a
	call Call_12D0
	ld a, [$c899]
	and $3f
	inc a
	ld [$da12], a
	xor a
	ld [$da13], a
	ld hl, far_Call_14_40B4
	rst $10
	pop af
	push af
	call Call_12D0
	and $7f
	ld [$da31], a
	ld hl, $cad6
	ld c, a
	pop af
	call Call_01_4DA8
	push af
	pop af
	push af
	call Call_12D0
	and $7f
	ld [$da31], a
	ld hl, $cad7
	ld c, a
	pop af
	call Call_01_4DA8
	push af
	pop af
	push af
	ld hl, $cacb
	call Call_223B
	ld a, [hl]
	ld c, a
	pop af
	ld hl, $cac2
	call Call_01_4DB8
	push af
	call Call_12D0
	ld a, [$c899]
	and $07
	ld c, a
	pop af
	ld hl, $cad8
	call Call_01_4DB8
	push af
	call Call_12D0
	ld a, [$c899]
	and $07
	ld c, a
	pop af
	ld hl, $cae1
	call Call_01_4DB8
	push af
	ld hl, $cad6
	call Call_223B
	ld a, [hl]
	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld a, [$da33]
	ld c, a
	pop af
	ld hl, $cb44
	call Call_01_4DB8
	push af
	ld hl, $cad7
	call Call_223B
	ld a, [hl]
	ld [$da31], a
	ld hl, far_Call_03_443F
	rst $10
	ld a, [$da33]
	ld c, a
	pop af
	ld hl, $cb4d
	call Call_01_4DB8
	ret


Call_01_4DA8::
	push af
	call Call_223B
	ld [hl], c
	pop af
	ret


	db $f5, $cd, $3b, $22, $71, $23, $70, $f1, $c9

Call_01_4DB8::
	push af
	push bc
	call Call_223B
	ld e, l
	ld d, h
	call Call_12D0
	ld a, [$c899]
	and $0f
	pop bc
	swap c
	or c
	ld l, a
	ld h, $03
	call Call_097A
	pop af
	ret


	ld a, [$c88f]
	or a
	jp nz, Jump_001_4139

Call_01_4DDA::
	jr jr_001_4dfc

	db $fa, $46, $c8, $e6, $04, $28, $19, $fa, $aa, $c8, $b7, $20, $0a, $f0, $24, $ea
	db $aa, $c8, $af, $e0, $24, $18, $09, $fa, $aa, $c8, $e0, $24, $af, $ea, $aa, $c8

jr_001_4dfc:
	ld a, [$c8aa]
	or a
	jr nz, jr_001_4e0b

	call Call_01_60E7
	call Call_01_4EAA
	call Call_01_4EFA

jr_001_4e0b:
	ld hl, $0404
	rst $10
	ld hl, $0606
	rst $10
	call Call_01_565E
	ld hl, $0601
	rst $10
	call Call_01_5F8B
	call Call_01_6611
	ld a, [$c8aa]
	or a
	jr nz, jr_001_4e29

	call Call_01_67F8

jr_001_4e29:
	ret


	db $fa, $86, $c8, $47, $fa, $88, $c8, $80, $ea, $88, $c8, $fa, $89, $c8, $ce, $00
	db $ea, $89, $c8, $fa, $a4, $c8, $e6, $3f, $20, $17, $fa, $88, $c8, $47, $fa, $89
	db $c8, $cb, $10, $17, $cb, $10, $17, $ea, $87, $c8, $af, $ea, $88, $c8, $ea, $89
	db $c8, $21, $a0, $c0, $fa, $87, $c8, $47, $3e, $91, $90, $4f, $06, $00, $cd, $a1
	db $20, $21, $c3, $ff, $3e, $80, $22, $3e, $00, $22, $3e, $78, $22, $3e, $00, $22
	db $3e, $00, $22, $3e, $00, $22, $3e, $00, $22, $3e, $00, $22, $fa, $a0, $c0, $e0
	db $c9, $21, $01, $04, $d7, $3e, $88, $e0, $c3, $fa, $a1, $c0, $e0, $c9, $21, $01
	db $04, $d7, $3e, $90, $e0, $c3, $fa, $a2, $c0, $e0, $c9, $21, $01, $04, $d7, $c9

Call_01_4EAA::
	ld a, [$c8a6]
	add $01
	ld [$c8a6], a
	ld a, [$c8a7]
	adc $00
	ld [$c8a7], a
	ld a, [$c8a8]
	or a
	jr z, jr_001_4ed2

	dec a
	ld [$c8a8], a
	or a
	jr nz, jr_001_4ed2

	ld a, [$c850]
	or a
	jr nz, jr_001_4ed2

	ld a, $d2
	ld [$c89b], a

jr_001_4ed2:
	ld a, [$c8eb]
	bit 5, a
	jr nz, jr_001_4ef9

	bit 6, a
	jr nz, jr_001_4ef9

	ld a, [$c850]
	or a
	jr nz, jr_001_4ef9

	ld a, [$c8a8]
	or a
	jr nz, jr_001_4ef3

	call Call_01_4F70
	call Call_01_5277
	ld hl, $0602
	rst $10

jr_001_4ef3:
	call Call_01_5798
	call Call_01_53CF

jr_001_4ef9:
	ret


Call_01_4EFA::
	ld a, [$d8d7]
	or a
	ret nz

	ld a, [$c8eb]
	bit 1, a
	ret nz

	bit 7, a
	ret nz

	bit 4, a
	ret nz

	bit 3, a
	ret nz

	bit 2, a
	ret nz

	ld hl, $ffb7
	ldh a, [$ff92]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff93]
	sbc [hl]
	bit 7, a
	jr nz, jr_001_4f49

	or a
	jr nz, jr_001_4f50

	ld a, e
	cp $07
	jr c, jr_001_4f49

	cp $99
	jr nc, jr_001_4f50

	ld hl, $ffbb
	ldh a, [$ff95]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff96]
	sbc [hl]
	bit 7, a
	jr nz, jr_001_4f57

	or a
	jr nz, jr_001_4f5e

	ld a, e
	cp $07
	jr c, jr_001_4f57

	cp $79
	jr nc, jr_001_4f5e

	jr jr_001_4f6f

jr_001_4f49:
	ld a, $00
	ld [$c91d], a
	jr jr_001_4f63

jr_001_4f50:
	ld a, $01
	ld [$c91d], a
	jr jr_001_4f63

jr_001_4f57:
	ld a, $02
	ld [$c91d], a
	jr jr_001_4f63

jr_001_4f5e:
	ld a, $03
	ld [$c91d], a

jr_001_4f63:
	ld hl, $c8eb
	set 2, [hl]
	xor a
	ld [$c91e], a
	ld [$c91f], a

jr_001_4f6f:
	ret


Call_01_4F70::
	ld a, [$c8eb]
	bit 2, a
	jp nz, Jump_001_5253

	bit 0, a
	jp nz, Jump_001_51fd

	bit 1, a
	jp nz, Jump_001_5253

	bit 7, a
	jp nz, Jump_001_5253

	bit 4, a
	jp nz, Jump_001_5253

	bit 3, a
	jp nz, Jump_001_5253

	ld hl, $ff90
	res 4, [hl]
	ldh a, [$ff90]
	bit 6, a
	jp nz, Jump_001_5253

	ldh a, [$ff90]
	bit 7, a
	jp nz, Jump_001_51fd

	bit 0, a
	jp nz, Jump_001_51b2

	ld a, [$d8d7]
	or a
	jp nz, Jump_001_51b2

	ld hl, $ffb7
	ldh a, [$ff92]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff93]
	sbc [hl]
	or a
	jp nz, Jump_001_51b2

	ld a, e
	cp $07
	jp c, Jump_001_51b2

	cp $99
	jp nc, Jump_001_51b2

	ld hl, $ffbb
	ldh a, [$ff95]
	sub [hl]
	ld e, a
	inc hl
	ldh a, [$ff96]
	sbc [hl]
	or a
	jp nz, Jump_001_51b2

	ld a, e
	cp $07
	jp c, Jump_001_51b2

	cp $79
	jp nc, Jump_001_51b2

	ld hl, $00c0
	ld a, [$c842]
	bit 4, a
	jr z, jr_001_5056

	ld a, $00
	ldh [$ff8d], a
	ld a, $01
	ldh [$ff8f], a
	call Call_01_5254
	ldh a, [$ff8e]
	push af
	ld a, $03
	ldh [$ff8e], a
	pop af
	cp $03
	jr z, jr_001_5012

	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a
	ld a, $05
	ld [$c8a8], a
	jp Jump_001_51b2


jr_001_5012:
	ld a, l
	ldh [$ffa1], a
	ld a, h
	ldh [$ffa2], a
	ldh a, [$ff95]
	and $0f
	cp $08
	jr nz, jr_001_5046

	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ffa5], a
	ld a, h
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jp nz, Jump_001_51b2

jr_001_5046:
	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a
	call Call_01_5487
	ld hl, $ff90
	set 4, [hl]
	jp Jump_001_51b2


jr_001_5056:
	ld a, [$c842]
	bit 5, a
	jr z, jr_001_50cf

	ld a, l
	cpl
	add $01
	ld l, a
	ld a, h
	cpl
	adc $00
	ld h, a
	ld a, $20
	ldh [$ff8d], a
	ld a, $01
	ldh [$ff8f], a
	call Call_01_5254
	ldh a, [$ff8e]
	push af
	ld a, $01
	ldh [$ff8e], a
	pop af
	cp $01
	jr z, jr_001_508b

	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a
	ld a, $05
	ld [$c8a8], a
	jp Jump_001_51b2


jr_001_508b:
	ld a, l
	ldh [$ffa1], a
	ld a, h
	ldh [$ffa2], a
	ldh a, [$ff95]
	and $0f
	cp $08
	jr nz, jr_001_50bf

	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ffa5], a
	ld a, h
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jp nz, Jump_001_51b2

jr_001_50bf:
	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a
	call Call_01_546D
	ld hl, $ff90
	set 4, [hl]
	jp Jump_001_51b2


jr_001_50cf:
	ld hl, $00c0
	ld a, [$c842]
	bit 7, a
	jp z, Jump_001_5145

	ld a, $00
	ldh [$ff8d], a
	ld a, $00
	ldh [$ff8f], a
	call Call_01_5254
	ldh a, [$ff8e]
	push af
	ld a, $00
	ldh [$ff8e], a
	pop af
	cp $00
	jr z, jr_001_50fe

	xor a
	ldh [$ffa3], a
	ldh [$ffa4], a
	ld a, $05
	ld [$c8a8], a
	jp Jump_001_51b2


jr_001_50fe:
	ld a, l
	ldh [$ffa3], a
	ld a, h
	ldh [$ffa4], a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $08
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	and $f0
	ld l, a
	ld a, l
	add $18
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jp nz, Jump_001_51b2

	xor a
	ldh [$ffa3], a
	ldh [$ffa4], a
	call Call_01_54C6
	ld hl, $ff90
	set 4, [hl]
	jr jr_001_51b2

Jump_001_5145:
	ld a, [$c842]
	bit 6, a
	jp z, Jump_001_51ea

	ld a, l
	cpl
	add $01
	ld l, a
	ld a, h
	cpl
	adc $00
	ld h, a
	ld a, $00
	ldh [$ff8d], a
	ld a, $02
	ldh [$ff8f], a
	ldh a, [$ff8e]
	push af
	ld a, $02
	ldh [$ff8e], a
	pop af
	cp $02
	jr z, jr_001_5178

	xor a
	ldh [$ffa3], a
	ldh [$ffa4], a
	ld a, $05
	ld [$c8a8], a
	jp Jump_001_51b2


jr_001_5178:
	ld a, l
	ldh [$ffa3], a
	ld a, h
	ldh [$ffa4], a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jr nz, jr_001_51b2

	xor a
	ldh [$ffa3], a
	ldh [$ffa4], a
	call Call_01_54AC
	ld hl, $ff90
	set 4, [hl]
	jr jr_001_51b2

Jump_001_51b2:
jr_001_51b2:
	ldh a, [$ff90]
	bit 1, a
	jr nz, jr_001_51ea

	ldh a, [$ff8f]
	add $03
	ld b, a
	ld a, [$d7b8]
	cp b
	jr z, jr_001_51d1

	ld a, b
	ld [$d7b8], a
	xor a
	ld [$d7ba], a
	ld [$d7bb], a
	ld [$d7b6], a

jr_001_51d1:
	ld hl, $d7b6
	ld a, l
	ld [$d7b4], a
	ld a, h
	ld [$d7b5], a
	ldh a, [$ff8a]
	ld [$d7b7], a
	ld hl, far_Call_02_400D
	rst $10
	ld a, [$d7ba]
	ldh [$ff8b], a

Jump_001_51ea:
jr_001_51ea:
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31

Jump_001_51fd:
	ldh a, [$ff90]
	bit 0, a
	jp nz, Jump_001_5253

	ld a, [$d8d7]
	or a
	jp nz, Jump_001_5212

	ld a, [$c842]
	and $f0
	jr nz, jr_001_5253

Jump_001_5212:
	ld c, $00
	ld a, [$d8d7]
	or a
	jr z, jr_001_521c

	ld c, $06

jr_001_521c:
	ldh a, [$ff8f]
	add c
	ld b, a
	ld a, [$d7b8]
	cp b
	jr z, jr_001_5234

	ld a, b
	ld [$d7b8], a
	xor a
	ld [$d7ba], a
	ld [$d7bb], a
	ld [$d7b6], a

jr_001_5234:
	ld hl, $d7b6
	ld a, l
	ld [$d7b4], a
	ld a, h
	ld [$d7b5], a
	ldh a, [$ff8a]
	ld [$d7b7], a
	ld hl, far_Call_02_400D
	rst $10
	ld a, [$d7b6]
	or a
	jr z, jr_001_5253

	ld a, [$d7ba]
	ldh [$ff8b], a

Jump_001_5253:
jr_001_5253:
	ret


Call_01_5254::
	ld a, [$c969]
	or a
	ret nz

	ld a, [$c968]
	cp $18
	ret nz

	ldh a, [$ff95]
	ld e, a
	ldh a, [$ff96]
	ld d, a
	ld a, e
	sub $90
	ld e, a
	ld a, d
	sbc $00
	ld d, a
	ret nc

	ld a, $00
	ldh [$ff8d], a
	ld a, $02
	ldh [$ff8f], a
	ret


Call_01_5277::
	ld a, [$c8eb]
	bit 2, a
	jr z, Call_01_5287

	call Call_01_5629
	call Call_01_5629
	call Call_01_5287

Call_01_5287::
	ld hl, $ffa1
	ld a, [hli]
	or [hl]
	jr z, jr_001_52ac

	ld b, $00
	ldh a, [$ffa2]
	bit 7, a
	jr z, jr_001_5297

	dec b

jr_001_5297:
	ld hl, $ff91
	ldh a, [$ffa1]
	add [hl]
	ld [hli], a
	ldh a, [$ffa2]
	adc [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
	ld hl, $ff90
	set 0, [hl]
	jr jr_001_52cf

jr_001_52ac:
	ld hl, $ffa3
	ld a, [hli]
	or [hl]
	jr z, jr_001_52cf

	ld b, $00
	ldh a, [$ffa4]
	bit 7, a
	jr z, jr_001_52bc

	dec b

jr_001_52bc:
	ld hl, $ff94
	ldh a, [$ffa3]
	add [hl]
	ld [hli], a
	ldh a, [$ffa4]
	adc [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
	ld hl, $ff90
	set 0, [hl]

jr_001_52cf:
	ldh a, [$ff93]
	or a
	jr nz, jr_001_52e8

	ldh a, [$ff92]
	cp $08
	jr nc, jr_001_52e8

	ld a, $00
	ldh [$ff91], a
	ld a, $08
	ldh [$ff92], a
	ld a, $00
	ldh [$ff93], a
	jr jr_001_530a

jr_001_52e8:
	ldh a, [$ff9d]
	ld l, a
	ldh a, [$ff9e]
	ld h, a
	ld a, l
	sub $08
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff93]
	cp h
	jr c, jr_001_530a

	ldh a, [$ff92]
	cp l
	jr c, jr_001_530a

	ld a, $00
	ldh [$ff91], a
	ld a, l
	ldh [$ff92], a
	ld a, h
	ldh [$ff93], a

jr_001_530a:
	ldh a, [$ff96]
	or a
	jr nz, jr_001_5323

	ldh a, [$ff95]
	cp $08
	jr nc, jr_001_5323

	ld a, $00
	ldh [$ff94], a
	ld a, $08
	ldh [$ff95], a
	ld a, $00
	ldh [$ff96], a
	jr jr_001_5345

jr_001_5323:
	ldh a, [$ff9f]
	ld l, a
	ldh a, [$ffa0]
	ld h, a
	ld a, l
	sub $08
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff96]
	cp h
	jr c, jr_001_5345

	ldh a, [$ff95]
	cp l
	jr c, jr_001_5345

	ld a, $00
	ldh [$ff94], a
	ld a, l
	ldh [$ff95], a
	ld a, h
	ldh [$ff96], a

jr_001_5345:
	ldh a, [$ff90]
	bit 0, a
	jp z, Jump_001_53ce

	ldh a, [$ff92]
	and $0f
	cp $08
	jr nz, jr_001_5359

	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a

jr_001_5359:
	ldh a, [$ff95]
	and $0f
	cp $08
	jr nz, jr_001_5366

	xor a
	ldh [$ffa3], a
	ldh [$ffa4], a

jr_001_5366:
	ld hl, $ffa1
	ld a, [hli]
	or [hl]
	jr nz, jr_001_53ce

	ld hl, $ffa3
	ld a, [hli]
	or [hl]
	jr nz, jr_001_53ce

	ld hl, $ff90
	res 0, [hl]
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ld b, a
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	swap h
	swap l
	ld a, h
	and $f0
	ld h, a
	ld a, l
	and $0f
	or h
	ld c, a
	ldh a, [$ff97]
	cp b
	jr nz, jr_001_53a9

	ldh a, [$ff98]
	cp c
	jr z, jr_001_53ce

jr_001_53a9:
	ld a, b
	ldh [$ff97], a
	ld a, c
	ldh [$ff98], a
	call Call_01_5A66
	call Call_01_5A29
	call Call_01_5A4D
	ld hl, $0b06
	rst $10
	call Call_01_55D7
	call Call_01_5510
	call Call_01_5C65
	call Call_01_5E19
	call Call_01_5EA9
	call Call_01_5D6D

Jump_001_53ce:
jr_001_53ce:
	ret


Call_01_53CF::
	ld hl, $ff99
	ldh a, [$ff92]
	cp [hl]
	jr nz, jr_001_53e9

	inc hl
	ldh a, [$ff93]
	cp [hl]
	jr nz, jr_001_53e9

	inc hl
	ldh a, [$ff95]
	cp [hl]
	jr nz, jr_001_53e9

	inc hl
	ldh a, [$ff96]
	cp [hl]
	jr z, jr_001_53ec

jr_001_53e9:
	call Call_01_5629

jr_001_53ec:
	ldh a, [$ff92]
	ldh [$ff99], a
	ldh a, [$ff93]
	ldh [$ff9a], a
	ldh a, [$ff95]
	ldh [$ff9b], a
	ldh a, [$ff96]
	ldh [$ff9c], a
	call Call_01_5440
	ld a, [$d7b8]
	cp $03
	jr z, jr_001_540f

	cp $04
	jr z, jr_001_540f

	cp $05
	jr z, jr_001_540f

	ret


jr_001_540f:
	ld hl, $ff90
	bit 5, [hl]
	jr nz, jr_001_5425

	bit 4, [hl]
	ret z

	ld hl, $ffa1
	ld a, [hli]
	or [hl]
	ret nz

	ld hl, $ffa3
	ld a, [hli]
	or [hl]
	ret nz

jr_001_5425:
	ld a, [$c850]
	or a
	ret nz

	ld a, [$d7b6]
	or a
	ret nz

	ld a, [$d8d7]
	or a
	ret nz

	ld a, $54
	call Call_1B2C
	ld a, $80
	ldh [$ff91], a
	ldh [$ff94], a
	ret


Call_01_5440::
	ld hl, $d7d2

jr_001_5443:
	ld a, [hl]
	cp $ff
	ret z

	push hl
	ld a, l
	add $18
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld e, l
	ld d, h
	inc hl
	inc hl
	inc hl
	inc hl
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
	ld [hl], a
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_001_5443

	db $c9

Call_01_546D::
	ldh a, [$ff93]
	or a
	ret nz

	ldh a, [$ff92]
	cp $08
	ret nz

	ld a, $00
	ldh [$ff91], a
	ld a, $08
	ldh [$ff92], a
	ld a, $00
	ldh [$ff93], a
	ld hl, far_Call_0B_4488
	rst $10
	ret


Call_01_5487::
	ldh a, [$ff9d]
	ld l, a
	ldh a, [$ff9e]
	ld h, a
	ld a, l
	sub $08
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff93]
	cp h
	ret c

	ldh a, [$ff92]
	cp l
	ret nz

	ld a, $00
	ldh [$ff91], a
	ld a, l
	ldh [$ff92], a
	ld a, h
	ldh [$ff93], a
	ld hl, far_Call_0B_4488
	rst $10
	ret


Call_01_54AC::
	ldh a, [$ff96]
	or a
	ret nz

	ldh a, [$ff95]
	cp $08
	ret nz

	ld a, $00
	ldh [$ff94], a
	ld a, $08
	ldh [$ff95], a
	ld a, $00
	ldh [$ff96], a
	ld hl, far_Call_0B_4488
	rst $10
	ret


Call_01_54C6::
	ldh a, [$ff9f]
	ld l, a
	ldh a, [$ffa0]
	ld h, a
	ld a, l
	sub $08
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ldh a, [$ff96]
	cp h
	ret c

	ldh a, [$ff95]
	cp l
	ret nz

	ld a, $00
	ldh [$ff94], a
	ld a, l
	ldh [$ff95], a
	ld a, h
	ldh [$ff96], a
	ld hl, far_Call_0B_4488
	rst $10
	ret


Call_01_54EB::
	ld a, [$c968]
	cp $53
	ret z

	cp $61
	ret z

	cp $62
	ret z

	cp $63
	ret z

	cp $64
	ret z

	cp $54
	ret z

	cp $55
	ret z

	cp $56
	ret z

	cp $57
	ret z

	cp $58
	ret z

	cp $59
	ret z

	ret


Call_01_5510::
	ld a, [$c969]
	or a
	jr nz, jr_001_551a

	call Call_01_54EB
	ret nz

jr_001_551a:
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c8eb]
	bit 6, a
	ret nz

	bit 2, a
	ret nz

	bit 0, a
	ret nz

	ld a, [$ca3b]
	ld l, a
	ld a, [$ca3c]
	ld h, a
	dec hl
	ld a, l
	ld [$ca3b], a
	ld a, h
	ld [$ca3c], a
	ld a, h
	or l
	jr nz, jr_001_555d

	ld hl, $0064
	ld a, l
	ld [$ca3b], a
	ld a, h
	ld [$ca3c], a
	ld a, [$ca8e]
	call Call_01_558C
	ld a, [$ca8f]
	call Call_01_558C
	ld a, [$ca90]
	call Call_01_558C

jr_001_555d:
	ld a, [$ca3d]
	ld l, a
	ld a, [$ca3e]
	ld h, a
	dec hl
	ld a, l
	ld [$ca3d], a
	ld a, h
	ld [$ca3e], a
	ld a, h
	or l
	jr nz, jr_001_558b

	ld hl, $0014
	ld a, l
	ld [$ca3d], a
	ld a, h
	ld [$ca3e], a
	ld b, $14
	ld c, $00

jr_001_5581:
	push bc
	ld a, c
	call Call_01_55B1
	pop bc
	inc c
	dec b
	jr nz, jr_001_5581

jr_001_558b:
	ret


Call_01_558C::
	cp $ff
	ret z

	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $02
	ret nz

	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	bit 7, [hl]
	ret nz

	ld a, l
	add $16
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	or a
	ret z

	dec [hl]
	ret


Call_01_55B1::
	cp $ff
	ret z

	ld hl, $cac1
	call Call_223B
	ld a, [hl]
	cp $01
	ret nz

	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	bit 7, [hl]
	ret nz

	ld a, l
	add $16
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	inc [hl]
	ret


Call_01_55D7::
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
	ld hl, $0b05
	rst $10
	ldh a, [$ffd5]
	cp $ff
	ret z

	ld [$d8d4], a
	ld a, [$c968]
	ld [$d8d3], a
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


Call_01_5629::
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


Call_01_565E::
	ld a, [$d8d7]
	or a
	jr nz, jr_001_5690

	ld a, [$c969]
	or a
	jr nz, jr_001_568c

	ld a, [$c968]
	cp $06
	jr z, jr_001_5690

	cp $5d
	jr z, jr_001_5690

	ld a, [$d92b]
	cp $07
	jr nz, jr_001_568c

	ld a, [$da09]
	cp $03
	jr nz, jr_001_568c

	ld a, [$c8ed]
	cp $0e
	jr nz, jr_001_568c

	jr jr_001_5690

jr_001_568c:
	xor a
	ld [$c8ed], a

jr_001_5690:
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
	jr z, jr_001_56ab

	ld a, [$c8ef]
	cp $0f
	ret z

jr_001_56ab:
	ldh a, [$ff90]
	bit 6, a
	ret nz

	ld hl, $ffc3
	ldh a, [$ff92]
	ld [hli], a
	ldh a, [$ff93]
	ld [hli], a
	ldh a, [$ff95]
	add $08
	ld [hli], a
	ldh a, [$ff96]
	adc $00
	ld [hli], a
	ldh a, [$ff8a]
	ld [hli], a
	ldh a, [$ff8b]
	ld [hli], a
	ldh a, [$ff8c]
	ld [hli], a
	ldh a, [$ff8d]
	ld [hl], a
	ldh a, [$ffc8]
	cp $ff
	ret z

	ld a, [$c8ed]
	bit 0, a
	jr nz, jr_001_56df

	ld hl, far_Call_04_4081
	rst $10

jr_001_56df:
	ld a, [$ca8d]
	cp $00
	ret z

	ld a, [$ca91]
	ldh [$ffc7], a
	ld a, $20
	ldh [$ffc9], a
	ld b, $10
	ld a, [$c8ed]
	bit 1, a
	call z, Call_01_572B
	ld a, [$ca8d]
	cp $01
	ret z

	ld a, [$ca92]
	ldh [$ffc7], a
	ld a, $30
	ldh [$ffc9], a
	ld b, $20
	ld a, [$c8ed]
	bit 2, a
	call z, Call_01_572B
	ld a, [$ca8d]
	cp $02
	ret z

	ld a, [$ca93]
	ldh [$ffc7], a
	ld a, $40
	ldh [$ffc9], a
	ld b, $30
	ld a, [$c8ed]
	bit 3, a
	call z, Call_01_572B
	ret


Call_01_572B::
	ld a, [$ca37]
	sub b
	jr nc, jr_001_5733

	add $31

jr_001_5733:
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
	ld e, l
	ld d, h
	ld hl, $ffc3
	ld a, [de]
	ld [hli], a
	inc de
	inc de
	ld a, [de]
	swap a
	and $0f
	ld [hli], a
	dec de
	ld a, [de]
	inc de
	add $08
	ld [hli], a
	ld a, [de]
	inc de
	adc $00
	and $0f
	ld [hli], a
	inc hl
	ld a, [de]
	and $0f
	ld [hli], a
	inc hl
	ld a, [de]
	and $f0
	ld [hli], a
	inc de
	call Call_01_576F
	ld hl, far_Call_04_4081
	rst $10
	ret


Call_01_576F::
	ld a, [$d7b8]
	cp $00
	jr z, jr_001_578b

	cp $01
	jr z, jr_001_578b

	cp $02
	jr z, jr_001_578b

	cp $03
	jr z, jr_001_578b

	cp $04
	jr z, jr_001_578b

	cp $05
	jr z, jr_001_578b

	ret


jr_001_578b:
	ldh a, [$ffc8]
	and $fe
	ld b, a
	ldh a, [$ff8b]
	and $01
	add b
	ldh [$ffc8], a
	ret


Call_01_5798::
	ld hl, far_Call_06_4B1F
	rst $10
	call Call_01_59C4
	ld hl, $ff90
	bit 5, [hl]
	jr nz, jr_001_57ab

	xor a
	ld [$d7bc], a
	ret


jr_001_57ab:
	ld a, [$d7bc]
	inc a
	ld [$d7bc], a
	cp $02
	jp nz, Jump_001_5921

	xor a
	ld [$d7bc], a
	xor a
	ldh [$ffa1], a
	ldh [$ffa2], a
	xor a
	ldh [$ffa3], a
	ldh [$ffa4], a
	ld hl, $ff90
	res 0, [hl]
	ldh a, [$ff92]
	and $f0
	add $08
	ldh [$ff92], a
	ldh a, [$ff95]
	and $f0
	add $08
	ldh [$ff95], a
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jr z, jr_001_57fc

	ld hl, far_Call_06_4B1F
	rst $10
	ldh a, [$ff90]
	bit 5, a
	ret z

jr_001_57fc:
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jr z, jr_001_5852

	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ff95], a
	ld a, h
	ldh [$ff96], a
	ld hl, far_Call_06_4B1F
	rst $10
	ldh a, [$ff90]
	bit 5, a
	ret z

	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ff95], a
	ld a, h
	ldh [$ff96], a

jr_001_5852:
	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ffa7], a
	ld a, h
	ldh [$ffa8], a
	ldh a, [$ff92]
	ldh [$ffa5], a
	ldh a, [$ff93]
	ldh [$ffa6], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jr z, jr_001_58a8

	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ff95], a
	ld a, h
	ldh [$ff96], a
	ld hl, far_Call_06_4B1F
	rst $10
	ldh a, [$ff90]
	bit 5, a
	ret z

	ldh a, [$ff95]
	ld l, a
	ldh a, [$ff96]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ff95], a
	ld a, h
	ldh [$ff96], a

jr_001_58a8:
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ffa5], a
	ld a, h
	ldh [$ffa6], a
	ldh a, [$ff95]
	ldh [$ffa7], a
	ldh a, [$ff96]
	ldh [$ffa8], a
	call Call_1E31
	ldh a, [$ffa9]
	cp $ff
	jr z, jr_001_58fe

	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, l
	ldh [$ff92], a
	ld a, h
	ldh [$ff93], a
	ld hl, far_Call_06_4B1F
	rst $10
	ldh a, [$ff90]
	bit 5, a
	ret z

	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ff92], a
	ld a, h
	ldh [$ff93], a

jr_001_58fe:
	ldh a, [$ff92]
	ld l, a
	ldh a, [$ff93]
	ld h, a
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [$ff92], a
	ld a, h
	ldh [$ff93], a
	ld hl, far_Call_06_4B1F
	rst $10
	ldh a, [$ff90]
	bit 5, a
	jr nz, jr_001_58fe

	ret


	db $af, $ea, $bc, $d7

Jump_001_5921:
	ldh a, [$ff99]
	ldh [$ff92], a
	ldh a, [$ff9a]
	ldh [$ff93], a
	ldh a, [$ff9b]
	ldh [$ff95], a
	ldh a, [$ff9c]
	ldh [$ff96], a
	call Call_01_5935
	ret


Call_01_5935::
	ld hl, $d7d2

jr_001_5938:
	ld a, [hl]
	cp $ff
	ret z

	call Call_01_594A
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_001_5938

	db $c9

Call_01_594A::
	push hl
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	bit 5, [hl]
	jr z, jr_001_599c

	ld a, l
	add $13
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld e, l
	ld d, h
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	and $0f
	cp $08
	jr nz, jr_001_599c

	inc hl
	ld a, [hld]
	and $0f
	cp $08
	jr nz, jr_001_599c

	dec hl
	ld a, [hli]
	ld [de], a
	ld c, a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld b, a
	inc de
	ld a, [hl]
	ld [de], a
	ld a, c
	and $0f
	cp $08
	jr nz, jr_001_599c

	ld a, b
	and $0f
	cp $08
	jr nz, jr_001_599c

	pop hl
	push hl
	ld a, l
	add $07
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld [hl], $20

jr_001_599c:
	pop hl
	ret


	db $f0, $8a, $ea, $b7, $d7, $7d, $ea, $b8, $d7, $7c, $ea, $b9, $d7, $21, $b6, $d7
	db $7d, $ea, $b4, $d7, $7c, $ea, $b5, $d7, $af, $ea, $b6, $d7, $21, $00, $02, $d7
	db $fa, $ba, $d7, $e0, $8b, $c9

Call_01_59C4::
	ld a, [$c969]
	or a
	ret z

	ld hl, $d793

jr_001_59cc:
	ld a, [hl]
	cp $ff
	ret z

	push hl
	and $f8
	jr z, jr_001_59f3

	bit 7, a
	jr nz, jr_001_59f3

	inc hl
	inc hl
	ld de, $ff92
	call Call_01_59FE
	jr nc, jr_001_59f3

	inc hl
	ld de, $ff95
	call Call_01_59FE
	jr nc, jr_001_59f3

	pop hl
	ld hl, $ff90
	set 5, [hl]
	ret


jr_001_59f3:
	pop hl
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_001_59cc

Call_01_59FE::
	ld a, [hl]
	swap a
	ld b, a
	and $f0
	or $08
	ld c, a
	ld a, b
	and $0f
	ld b, a
	ld a, [de]
	inc de
	sub c
	ld c, a
	ld a, [de]
	sbc b
	ld b, a
	bit 7, b
	jr z, jr_001_5a20

	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
	adc $00
	ld b, a

jr_001_5a20:
	ld a, c
	sub $10
	ld c, a
	ld a, b
	sbc $00
	ld b, a
	ret


Call_01_5A29::
	ld a, [$c969]
	or a
	ret z

	ld a, [$d793]
	cp $ff
	ret z

	ld hl, $d793

jr_001_5a37:
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	bit 7, a
	ret z

	cp $ff
	jr nz, jr_001_5a37

	ld a, $04
	ld [$c92d], a
	ret


Call_01_5A4D::
	ld a, [$c969]
	or a
	ret z

	ld a, [$c92e]
	inc a
	ld [$c92e], a
	cp $c8
	ret c

	xor a
	ld [$c92e], a
	ld a, $07
	ld [$c92d], a
	ret


Call_01_5A66::
	ldh a, [$ff97]
	ldh [$ffdb], a
	ldh a, [$ff98]
	ldh [$ffdd], a
	xor a
	ld [$d78f], a

Call_01_5A72::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c969]
	or a
	ret z

	ld hl, $d793

jr_001_5a7f:
	ld a, [hl]
	cp $ff
	ret z

	push hl
	bit 7, a
	jr nz, jr_001_5aa0

	ld a, [$d78f]
	or a
	jr z, jr_001_5a93

	ld a, [hl]
	and $78
	jr z, jr_001_5aa0

jr_001_5a93:
	inc hl
	inc hl
	ldh a, [$ffdb]
	cp [hl]
	jr nz, jr_001_5aa0

	inc hl
	ldh a, [$ffdd]
	cp [hl]
	jr z, jr_001_5aab

jr_001_5aa0:
	pop hl
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_001_5a7f

jr_001_5aab:
	xor a
	ld [$c92e], a
	pop hl
	inc hl
	ld a, [hl]
	ld [$d78f], a
	dec hl
	cp $ff
	jp z, Jump_001_5b57

	cp $00
	jp nz, Jump_001_5b43

	push hl
	ld hl, far_Call_01_69E1
	rst $10
	ld a, [$c93c]
	cp $01
	jr nz, jr_001_5ae0

	ld a, [$c899]
	ld b, a
	ld a, $0d
	call Call_1DFB
	add $07
	ld [$d791], a
	xor a
	ld [$d792], a
	jr jr_001_5b22

jr_001_5ae0:
	cp $02
	jr nz, jr_001_5af8

	ld a, [$c899]
	ld b, a
	ld a, $1e
	call Call_1DFB
	add $28
	ld [$d791], a
	xor a
	ld [$d792], a
	jr jr_001_5b22

jr_001_5af8:
	ld a, [$ca38]
	add $0a
	ld c, a
	ld a, [$c939]
	inc a
	call Call_1DBE
	push hl
	ld a, [$c899]
	ld b, a
	ld a, $32
	call Call_1DFB
	add $32
	pop bc
	call Call_1DE6
	ld a, $64
	call Call_1E1E
	ld a, l
	ld [$d791], a
	ld a, h
	ld [$d792], a

jr_001_5b22:
	ld hl, $d791
	ld a, [$ca4b]
	add [hl]
	ld e, a
	inc hl
	ld a, [$ca4c]
	adc [hl]
	ld d, a
	inc hl
	ld a, [$ca4d]
	adc $00
	ld c, a
	pop hl
	ld a, e
	sub $a0
	ld a, d
	sbc $86
	ld a, c
	sbc $01
	jr jr_001_5b57

Jump_001_5b43:
	ld de, $ca51
	ld b, $14

jr_001_5b48:
	ld a, [de]
	or a
	jr z, jr_001_5b57

	cp $ff
	jr z, jr_001_5b57

	inc de
	dec b
	jr nz, jr_001_5b48

	jp Jump_001_5bfd


Jump_001_5b57:
jr_001_5b57:
	set 7, [hl]
	ld a, [hl]
	and $78
	jr z, jr_001_5b68

	set 5, [hl]
	inc hl
	ld [hl], $20
	ld a, $53
	call Call_1B2C

jr_001_5b68:
	ld a, [$d78f]
	cp $ff
	jr nz, jr_001_5b87

	ld hl, $c8eb
	set 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	ld hl, $0217
	ld a, l
	ld [$c917], a
	ld a, h
	ld [$c918], a
	ret


jr_001_5b87:
	or a
	jr nz, jr_001_5bc3

	ld hl, $c8eb
	set 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	ld a, [$d791]
	ldh [$ffd5], a
	ld a, [$d792]
	ldh [$ffd6], a
	ld a, $00
	ldh [$ffd7], a
	ld hl, $c180
	call Call_09C7
	ld hl, $0215
	ld a, l
	ld [$c917], a
	ld a, h
	ld [$c918], a
	ld a, [$d791]
	ld l, a
	ld a, [$d792]
	ld h, a
	ld e, $00
	call Call_241A
	ret


jr_001_5bc3:
	ld hl, $c8eb
	set 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	ld a, [$d78f]
	ld l, a
	ld h, $08
	ld de, $c180
	call Call_097A
	ld hl, $0208
	ld a, l
	ld [$c917], a
	ld a, h
	ld [$c918], a
	ld hl, $ca51
	ld b, $14

jr_001_5beb:
	ld a, [hl]
	or a
	jr z, jr_001_5bf3

	cp $ff
	jr nz, jr_001_5bf8

jr_001_5bf3:
	ld a, [$d78f]
	ld [hl], a
	ret


jr_001_5bf8:
	inc hl
	dec b
	jr nz, jr_001_5beb

	ret


Jump_001_5bfd:
	ld a, [hl]
	and $78
	jr z, jr_001_5c09

	set 5, [hl]
	ld a, $53
	call Call_1B2C

jr_001_5c09:
	ld hl, $c8eb
	set 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	ld a, [$d78f]
	ld l, a
	ld h, $08
	ld de, $c180
	call Call_097A
	ld hl, $0211
	ld a, l
	ld [$c917], a
	ld a, h
	ld [$c918], a
	ret


	db $7e, $e6, $78, $28, $07, $cb, $ee, $3e, $53, $cd, $2c, $1b, $21, $eb, $c8, $cb
	db $c6, $af, $ea, $15, $c9, $ea, $16, $c9, $fa, $91, $d7, $e0, $d5, $fa, $92, $d7
	db $e0, $d6, $3e, $00, $e0, $d7, $21, $80, $c1, $cd, $c7, $09, $21, $16, $02, $7d
	db $ea, $17, $c9, $7c, $ea, $18, $c9, $c9

Call_01_5C65::
	ld a, [$c969]
	or a
	jr nz, jr_001_5c6f

	call Call_01_54EB
	ret nz

jr_001_5c6f:
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c8eb]
	bit 5, a
	ret nz

	bit 6, a
	ret nz

	bit 2, a
	ret nz

	bit 0, a
	ret nz

	ld a, [$ca3b]
	ld l, a
	ld a, [$ca3c]
	ld h, a
	ld a, $0a
	call Call_1E0D
	cp $01
	jr nz, jr_001_5cac

	ld hl, $0001
	ld a, $00
	call Call_01_5CD3
	ld a, $01
	call Call_01_5CD3
	ld a, $02
	call Call_01_5CD3
	call Call_2518
	call Call_25F1

jr_001_5cac:
	ld a, [$ca3b]
	ld l, a
	ld a, [$ca3c]
	ld h, a
	ld a, $05
	call Call_1E0D
	cp $04
	jr nz, jr_001_5cd2

	ld a, $00
	call Call_01_5D33
	ld a, $01
	call Call_01_5D33
	ld a, $02
	call Call_01_5D33
	call Call_2518
	call Call_25F1

jr_001_5cd2:
	ret


Call_01_5CD3::
	ld b, a
	ld a, [$ca8d]
	cp b
	ret z

	ret c

	ld a, b
	push bc
	ld hl, $cb0b
	call Call_2229
	bit 0, [hl]
	pop bc
	ret nz

	push bc
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	pop bc
	ret nz

	ld a, b
	ld hl, $0001
	call Call_22D2
	ret


	db $47, $f0, $90, $cb, $4f, $c0, $fa, $8d, $ca, $b8, $c8, $d8, $78, $c5, $21, $0b
	db $cb, $cd, $29, $22, $cb, $46, $c1, $c8, $c5, $21, $0b, $cb, $cd, $29, $22, $cb
	db $7e, $c1, $c0, $78, $21, $01, $00, $cd, $f0, $22, $3e, $6c, $cd, $2c, $1b, $3e
	db $08, $ea, $a8, $c8, $3e, $2d, $ea, $9b, $c8, $c9

Call_01_5D33::
	ld b, a
	ldh a, [$ff90]
	bit 1, a
	ret nz

	ld a, [$ca8d]
	cp b
	ret z

	ret c

	ld a, b
	push bc
	ld hl, $cb0b
	call Call_2229
	bit 2, [hl]
	pop bc
	ret z

	push bc
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	pop bc
	ret nz

	ld a, b
	ld hl, $0001
	call Call_22BE
	ld a, $6c
	call Call_1B2C
	ld a, $08
	ld [$c8a8], a
	ld a, $2d
	ld [$c89b], a
	ret


Call_01_5D6D::
	ldh a, [$ff90]
	bit 7, a
	ret nz

	bit 1, a
	jr z, Call_01_5D9C

	ld hl, $ff90
	res 1, [hl]
	call Call_01_5D9C
	ldh a, [$ff90]
	bit 1, a
	ret nz

	ld a, [$c8eb]
	bit 2, a
	ret nz

	ld a, $01
	ld [$d8d4], a
	ld a, $54
	ld [$d8d3], a
	xor a
	ld [$d8d7], a
	ld hl, far_Call_04_55EC
	rst $10
	ret


Call_01_5D9C::
	ld a, [$c969]
	or a
	ret nz

	ld a, [$c850]
	cpl
	inc a
	bit 7, a
	ret nz

	ld a, [$c88f]
	or a
	ret nz

	ld a, [$c8eb]
	bit 6, a
	ret nz

	bit 2, a
	ret nz

	bit 0, a
	ret nz

	call Call_01_54EB
	ret nz

	ldh a, [$ffaa]
	srl a
	srl a
	cp $0f
	jr z, jr_001_5dd5

	cp $10
	jr z, jr_001_5de6

	cp $11
	jr z, jr_001_5df7

	cp $12
	jr z, jr_001_5e08

	ret


jr_001_5dd5:
	ld hl, $0100
	ld a, l
	ldh [$ffa1], a
	ld a, h
	ldh [$ffa2], a
	ld hl, $ff90
	set 1, [hl]
	set 0, [hl]
	ret


jr_001_5de6:
	ld hl, $ff00
	ld a, l
	ldh [$ffa1], a
	ld a, h
	ldh [$ffa2], a
	ld hl, $ff90
	set 1, [hl]
	set 0, [hl]
	ret


jr_001_5df7:
	ld hl, $0100
	ld a, l
	ldh [$ffa3], a
	ld a, h
	ldh [$ffa4], a
	ld hl, $ff90
	set 1, [hl]
	set 0, [hl]
	ret


jr_001_5e08:
	ld hl, $ff00
	ld a, l
	ldh [$ffa3], a
	ld a, h
	ldh [$ffa4], a
	ld hl, $ff90
	set 1, [hl]
	set 0, [hl]
	ret


Call_01_5E19::
	ld a, [$c969]
	or a
	jr nz, jr_001_5e23

	call Call_01_54EB
	ret nz

jr_001_5e23:
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c8eb]
	bit 6, a
	ret nz

	bit 2, a
	ret nz

	bit 0, a
	ret nz

	ld a, [$c93e]
	bit 0, a
	ret nz

	ldh a, [$ffaa]
	srl a
	srl a
	cp $0e
	jr nz, jr_001_5e7c

	ld a, [$c968]
	ld hl, $5e7d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_001_5e7c

	ld c, a
	ld l, a
	ld h, $00
	ld a, $00
	call Call_01_5E8D
	ld a, $01
	call Call_01_5E8D
	ld a, $02
	call Call_01_5E8D
	ld a, $6c
	call Call_1B2C
	ld a, $08
	ld [$c8a8], a
	ld a, $2d
	ld [$c89b], a
	call Call_2518
	call Call_25F1

jr_001_5e7c:
	ret


	db $00, $00, $00, $05, $00, $00, $0a, $00, $00, $00, $00, $00, $02, $00, $02, $00

Call_01_5E8D::
	ld b, a
	ld a, [$ca8d]
	cp b
	ret z

	ret c

	ld a, b
	push bc
	push hl
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	pop hl
	pop bc
	ret nz

	push hl
	ld a, b
	call Call_22BE
	pop hl
	ret


Call_01_5EA9::
	ld c, $00
	ld a, $00
	call Call_01_5F25
	ld a, $01
	call Call_01_5F25
	ld a, $02
	call Call_01_5F25
	ld a, c
	or a
	ret z

	push bc
	ld c, $00
	ld a, $00
	call Call_01_5F76
	ld a, $01
	call Call_01_5F76
	ld a, $02
	call Call_01_5F76
	ld a, [$ca8d]
	cp c
	pop bc
	jr nz, jr_001_5f01

	call Call_01_484E
	call Call_2518
	call Call_25F1
	ld hl, $ff90
	res 1, [hl]
	ld a, $4f
	call Call_1AE1
	ld hl, $021a
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


jr_001_5f01:
	ld a, $17
	add c
	ld l, a
	ld h, $02
	ld a, l
	ld [$c917], a
	ld a, h
	ld [$c918], a
	ld hl, $c8eb
	set 0, [hl]
	xor a
	ld [$c915], a
	ld [$c916], a
	call Call_01_484E
	call Call_2518
	call Call_25F1
	ret


Call_01_5F25::
	ld b, a
	ld a, [$ca8d]
	cp b
	jr z, jr_001_5f74

	jr c, jr_001_5f74

	ld a, b
	push bc
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	pop bc
	jr nz, jr_001_5f74

	ld a, b
	push bc
	ld hl, $cb11
	call Call_224F
	ld a, b
	or c
	pop bc
	jr nz, jr_001_5f74

	ld a, b
	push bc
	ld hl, $cb0b
	call Call_2229
	set 7, [hl]
	pop bc
	ld a, c
	push bc
	swap a
	ld hl, $c180
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld hl, $cac2
	ld a, b
	call Call_2229
	ld e, l
	ld d, h
	pop hl
	call Call_0C80
	pop bc
	inc c
	ld a, $01
	or a
	ret


jr_001_5f74:
	xor a
	ret


Call_01_5F76::
	ld b, a
	ld a, [$ca8d]
	cp b
	ret z

	ret c

	ld a, b
	push bc
	ld hl, $cb0b
	call Call_2229
	bit 7, [hl]
	pop bc
	ret z

	inc c
	ret


Call_01_5F8B::
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
	jr z, jr_001_5fa6

	ld a, [$c8ef]
	cp $0f
	ret z

jr_001_5fa6:
	ld a, [$c969]
	or a
	ret z

	ld de, $d793

jr_001_5fae:
	ld a, [de]
	cp $ff
	ret z

	push de
	call Call_01_5FC1
	pop de
	ld a, e
	add $04
	ld e, a
	ld a, d
	adc $00
	ld d, a
	jr jr_001_5fae

Call_01_5FC1::
	bit 7, a
	jr z, jr_001_5fde

	and $78
	ret z

	inc de
	ld a, [de]
	or a
	ret z

	ld a, [$c8eb]
	bit 0, a
	jr nz, jr_001_5fdd

	bit 6, a
	jr nz, jr_001_5fdd

	ld a, [de]
	dec a
	ld [de], a
	and $01
	ret z

jr_001_5fdd:
	dec de

jr_001_5fde:
	ld a, [de]
	and $7f
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, c
	cp $08
	jr nc, jr_001_5ff6

	ld a, b
	ld hl, $60b7
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]

jr_001_5ff6:
	push af
	ld hl, $6037
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ldh [$ffc9], a
	pop af
	ld hl, $6077
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ldh [$ffca], a
	ld hl, $ffc3
	ld a, [de]
	swap a
	ld c, a
	and $f0
	ld [hli], a
	ld a, c
	and $0f
	ld [hli], a
	inc de
	ld a, [de]
	swap a
	ld c, a
	and $f0
	ld [hli], a
	ld a, c
	and $0f
	ld [hli], a
	ld a, $01
	ldh [$ffc7], a
	ld a, $00
	ldh [$ffc8], a
	ld hl, far_Call_04_400F
	rst $10
	ret


	db $50, $54, $58, $5c, $60, $64, $68, $6c, $18, $18, $18, $18, $18, $18, $18, $18
	db $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18
	db $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c
	db $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c
	db $01, $02, $06, $07, $00, $07, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $00, $01, $00, $01, $01, $01, $00, $00, $02, $00, $01, $00, $03, $03, $03
	db $03, $03, $03, $04, $04, $04, $04, $04, $05, $05, $05, $05, $05, $06, $07, $00
	db $00, $00, $00, $00, $00, $05, $00, $05, $01, $00, $00, $00, $00, $05, $00, $05

Call_01_60E7::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c88f]
	or a
	ret nz

	ld a, [$c969]
	or a
	ret nz

	ld a, [$c8eb]
	bit 5, a
	ret nz

	bit 6, a
	ret nz

	bit 2, a
	ret nz

	bit 1, a
	ret nz

	bit 3, a
	ret nz

	bit 7, a
	ret nz

	bit 4, a
	jr z, jr_001_6115

	ld a, [$c8ef]
	cp $0f
	ret z

jr_001_6115:
	ld a, [$c968]
	rst $00

JumpTable_01_6119::
	dw Jump_01_61F9
	dw Jump_01_6200
	dw Jump_01_6204
	dw Jump_01_621F
	dw Jump_01_621F
	dw Jump_01_621F
	dw Jump_01_621F
	dw Jump_01_621F
	dw Jump_01_6220
	dw Jump_01_62B2
	dw Jump_01_62B3
	dw Jump_01_62B7
	dw Jump_01_62B7
	dw Jump_01_62B7
	dw Jump_01_62B7
	dw Jump_01_62B7
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B8
	dw Jump_01_62B9
	dw Jump_01_62B9
	dw Jump_01_62CD
	dw Jump_01_62CE
	dw Jump_01_62E2
	dw Jump_01_62E3
	dw Jump_01_62E4
	dw Jump_01_62E5
	dw Jump_01_62E5
	dw Jump_01_62F9
	dw Jump_01_62FA
	dw Jump_01_630E
	dw Jump_01_630F
	dw Jump_01_6310
	dw Jump_01_6335
	dw Jump_01_6336
	dw Jump_01_633D
	dw Jump_01_6362
	dw Jump_01_6376
	dw Jump_01_6362
	dw Jump_01_6377
	dw Jump_01_637E
	dw Jump_01_639D
	dw Jump_01_63B1
	dw Jump_01_63B8
	dw Jump_01_63B9
	dw Jump_01_63BA
	dw Jump_01_63BB
	dw Jump_01_63BC
	dw Jump_01_63BD
	dw Jump_01_63BE
	dw Jump_01_63D2
	dw Jump_01_63D3
	dw Jump_01_63D4
	dw Jump_01_63D5
	dw Jump_01_63D6
	dw Jump_01_63DD
	dw Jump_01_63BE
	dw Jump_01_63E4
	dw Jump_01_63F8
	dw Jump_01_63F9
	dw Jump_01_63FA
	dw Jump_01_63FB
	dw Jump_01_63FC
	dw Jump_01_6422
	dw Jump_01_6423
	dw Jump_01_642A
	dw Jump_01_6449
	dw Jump_01_645D
	dw Jump_01_648D
	dw Jump_01_648E
	dw Jump_01_64B4
	dw Jump_01_64B5
	dw Jump_01_64DA
	dw Jump_01_64DB
	dw Jump_01_64EF
	dw Jump_01_64EF
	dw Jump_01_64F0
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6543
	dw Jump_01_659E
	dw Jump_01_659E
	dw Jump_01_63FA
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_6542
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA
	dw Jump_01_63FA

Jump_01_61F9::
	ld hl, $94d0
	call Call_01_65E0
	ret


Jump_01_6200::
	call Call_01_659F
	ret


Jump_01_6204::
	ret


	db $21, $10, $92, $cd, $36, $66, $21, $f0, $93, $cd, $36, $66, $c9, $21, $10, $92
	db $cd, $8f, $66, $21, $f0, $93, $cd, $8f, $66, $c9

Jump_01_621F::
	ret


Jump_01_6220::
	ld a, [$d9cb]
	cp $02
	jp z, Jump_001_62b1

	or a
	jr nz, jr_001_6260

	ld a, [$c8a6]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	and $07
	ld hl, $6258
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c89b], a
	ret


	db $d2, $d2, $d2, $d1, $c1, $c1, $c1, $d1

jr_001_6260:
	ld a, [$c8a6]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	ld c, l
	ld b, h
	add hl, hl
	add hl, bc
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	and $1f
	ld hl, $6291
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$c89b], a
	ret


	db $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e6, $e6, $e6, $d2, $d2, $d2, $d1, $d1, $d1
	db $c1, $c1, $c1, $c1, $c1, $c1, $c1, $d1, $d1, $d1, $d2, $d2, $d2, $e6, $e6, $e6

Jump_001_62b1:
	ret


Jump_01_62B2::
	ret


Jump_01_62B3::
	call Call_01_659F
	ret


Jump_01_62B7::
	ret


Jump_01_62B8::
	ret


Jump_01_62B9::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9320
	ld de, $93d0
	ld b, $20
	call Call_01_6602
	ret


Jump_01_62CD::
	ret


Jump_01_62CE::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9240
	ld de, $92c0
	ld b, $20
	call Call_01_6602
	ret


Jump_01_62E2::
	ret


Jump_01_62E3::
	ret


Jump_01_62E4::
	ret


Jump_01_62E5::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9320
	ld de, $9380
	ld b, $20
	call Call_01_6602
	ret


Jump_01_62F9::
	ret


Jump_01_62FA::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9130
	ld de, $9190
	ld b, $40
	call Call_01_6602
	ret


Jump_01_630E::
	ret


Jump_01_630F::
	ret


Jump_01_6310::
	ld hl, $9240
	call Call_01_65E0
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9060
	ld de, $9200
	ld b, $20
	call Call_01_6602
	ld hl, $9160
	ld de, $9220
	ld b, $20
	call Call_01_6602
	ret


Jump_01_6335::
	ret


Jump_01_6336::
	ld hl, $9250
	call Call_01_65E0
	ret


Jump_01_633D::
	ld hl, $90a0
	call Call_01_65E0
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9060
	ld de, $90c0
	ld b, $20
	call Call_01_6602
	ld hl, $9160
	ld de, $90e0
	ld b, $20
	call Call_01_6602
	ret


Jump_01_6362::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9060
	ld de, $91a0
	ld b, $40
	call Call_01_6602
	ret


Jump_01_6376::
	ret


Jump_01_6377::
	ld hl, $9180
	call Call_01_65E0
	ret


Jump_01_637E::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9060
	ld de, $9200
	ld b, $20
	call Call_01_6602
	ld hl, $9160
	ld de, $9220
	ld b, $20
	call Call_01_6602
	ret


Jump_01_639D::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $94e0
	ld de, $94f0
	ld b, $10
	call Call_01_6602
	ret


Jump_01_63B1::
	ld hl, $91e0
	call Call_01_65E0
	ret


Jump_01_63B8::
	ret


Jump_01_63B9::
	ret


Jump_01_63BA::
	ret


Jump_01_63BB::
	ret


Jump_01_63BC::
	ret


Jump_01_63BD::
	ret


Jump_01_63BE::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9230
	ld de, $9240
	ld b, $10
	call Call_01_6602
	ret


Jump_01_63D2::
	ret


Jump_01_63D3::
	ret


Jump_01_63D4::
	ret


Jump_01_63D5::
	ret


Jump_01_63D6::
	ld hl, $9560
	call Call_01_65E0
	ret


Jump_01_63DD::
	ld hl, $90a0
	call Call_01_65E0
	ret


Jump_01_63E4::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9380
	ld de, $93c0
	ld b, $40
	call Call_01_6602
	ret


Jump_01_63F8::
	ret


Jump_01_63F9::
	ret


Jump_01_63FA::
	ret


Jump_01_63FB::
	ret


Jump_01_63FC::
	ld a, [$c8a6]
	and $3f
	cp $03
	ld hl, $90e0
	ld de, $90f0
	ld b, $10
	call z, Call_01_6602
	ld a, [$c8a6]
	and $3f
	cp $23
	ret nz

	ld hl, $91e0
	ld de, $91f0
	ld b, $10
	call Call_01_6602
	ret


Jump_01_6422::
	ret


Jump_01_6423::
	ld hl, $9460
	call Call_01_65E0
	ret


Jump_01_642A::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $94c0
	ld de, $95a0
	ld b, $10
	call Call_01_6602
	ld hl, $94e0
	ld de, $95b0
	ld b, $10
	call Call_01_6602
	ret


Jump_01_6449::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $9190
	ld de, $91a0
	ld b, $10
	call Call_01_6602
	ret


Jump_01_645D::
	ld hl, $9310
	call Call_01_65E0
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $92a0
	ld de, $92c0
	ld b, $20
	call Call_01_6602
	ld hl, $93a0
	ld de, $93c0
	ld b, $20
	call Call_01_6602
	ld hl, $9400
	ld de, $9420
	ld b, $20
	call Call_01_6602
	ret


Jump_01_648D::
	ret


Jump_01_648E::
	ld a, [$c8a6]
	and $1f
	cp $03
	ld hl, $90c0
	ld de, $90d0
	ld b, $10
	call z, Call_01_6602
	ld a, [$c8a6]
	and $1f
	cp $13
	ret nz

	ld hl, $90e0
	ld de, $90f0
	ld b, $10
	call Call_01_6602
	ret


Jump_01_64B4::
	ret


Jump_01_64B5::
	ld hl, $9340
	call Call_01_65E0
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $90a0
	ld de, $90c0
	ld b, $20
	call Call_01_6602
	ld hl, $9200
	ld de, $9220
	ld b, $20
	call Call_01_6602
	ret


Jump_01_64DA::
	ret


Jump_01_64DB::
	ld a, [$c8a6]
	and $1f
	cp $03
	ret nz

	ld hl, $95c0
	ld de, $95e0
	ld b, $20
	call Call_01_6602
	ret


Jump_01_64EF::
	ret


Jump_01_64F0::
	ld a, [$c8a6]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $20
	call Call_1E0D
	or a
	jr nz, jr_001_651e

	ld hl, $91b0
	ld de, $90d0
	ld b, $10
	call Call_01_6602
	ld hl, $91c0
	ld de, $91d0
	ld b, $10
	call Call_01_6602

jr_001_651e:
	ld a, [$c8a6]
	ld l, a
	ld a, [$c8a7]
	ld h, a
	ld a, l
	add $0a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $19
	call Call_1E0D
	or a
	jr nz, jr_001_6541

	ld hl, $9200
	ld de, $9220
	ld b, $20
	call Call_01_6602

jr_001_6541:
	ret


Jump_01_6542::
	ret


Jump_01_6543::
	ld a, [$c8a6]
	and $07
	ret nz

	ld a, [$c8a6]
	ld b, a
	ld a, $38
	call Call_1DFB
	or a
	jr nz, jr_001_6560

	ld hl, $93c0
	ld de, $9440
	ld b, $20
	call Call_01_6602

jr_001_6560:
	ld a, [$c8a6]
	add $08
	ld b, a
	ld a, $20
	call Call_1DFB
	or a
	jr nz, jr_001_6584

	ld hl, $93e0
	ld de, $9460
	ld b, $20
	call Call_01_6602
	ld hl, $9520
	ld de, $94a0
	ld b, $20
	call Call_01_6602

jr_001_6584:
	ld a, [$c8a6]
	add $10
	ld b, a
	ld a, $18
	call Call_1DFB
	or a
	jr nz, jr_001_659d

	ld hl, $9500
	ld de, $9480
	ld b, $20
	call Call_01_6602

jr_001_659d:
	ret


Jump_01_659E::
	ret


Call_01_659F::
	ld a, [$c8a6]
	and $1f
	cp $05
	jr z, jr_001_65a9

	ret


jr_001_65a9:
	ld a, [$c8a7]
	bit 1, a
	jr z, jr_001_65c8

	ld hl, $9400
	call Call_01_65D4
	call Call_01_65BC
	call Call_01_65D4

Call_01_65BC::
	call Call_01_668F
	call Call_01_668F
	call Call_01_668F
	jp Call_01_668F


jr_001_65c8:
	ld hl, $9400
	call Call_01_65BC
	call Call_01_65D4
	call Call_01_65BC

Call_01_65D4::
	call Call_01_6636
	call Call_01_6636
	call Call_01_6636
	jp Call_01_6636


Call_01_65E0::
	ld a, [$c8a6]
	and $7f
	cp $07
	jr z, jr_001_65f6

	cp $27
	jr z, jr_001_65f6

	cp $47
	jr z, jr_001_65f6

	cp $67
	jr z, jr_001_65fc

	ret


jr_001_65f6:
	call Call_01_6636
	jp Call_01_6636


jr_001_65fc:
	call Call_01_668F
	jp Call_01_668F


Call_01_6602::
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
	jr nz, Call_01_6602

	ret


Call_01_6611::
	ld a, [$c850]
	or a
	ret nz

	ld a, [$c88f]
	or a
	ret nz

	ld a, [$c969]
	or a
	ret nz

	ld a, [$d8d7]
	or a
	ret nz

	ld a, [$c968]
	cp $08
	ret nz

	ld a, [$d951]
	cp $07
	ret nz

	ld hl, far_Call_02_5FD6
	rst $10
	ret


Call_01_6636::
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rrc [hl]
	inc l
	rrc [hl]
	ei
	inc hl
	ret


Call_01_668F::
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	di
	call Call_1AA6
	rlc [hl]
	inc l
	rlc [hl]
	ei
	inc hl
	ret


	db $5d, $54, $1b, $1b, $f3, $cd, $a6, $1a, $4e, $2b, $46, $23, $fb, $c5, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd
	db $a6, $1a, $1a, $32, $1b, $fb, $f3, $cd, $a6, $1a, $1a, $32, $1b, $fb, $c1, $f3
	db $cd, $a6, $1a, $71, $2b, $70, $fb, $c9, $5d, $54, $13, $13, $f3, $cd, $a6, $1a
	db $4e, $23, $46, $2b, $fb, $c5, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $f3, $cd, $a6, $1a, $1a, $22, $13, $fb, $f3, $cd
	db $a6, $1a, $1a, $22, $13, $fb, $c1, $f3, $cd, $a6, $1a, $71, $23, $70, $fb, $c9

Call_01_67F8::
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


Call_01_683E::
	call Call_01_69E1
	ld a, [$ca38]
	ld bc, $001a
	call Call_1DE6
	ld a, l
	add $b0
	ld l, a
	ld a, h
	adc $6a
	ld h, a
	ld b, $00
	ld de, $c0d8
	call Call_01_69AD
	call Call_01_69AD
	call Call_01_69AD
	ld hl, $c0d8
	call Call_01_6989
	ld [$da02], a
	ld a, [$ca38]
	ld bc, $001a
	call Call_1DE6
	ld a, l
	add $b3
	ld l, a
	ld a, h
	adc $6a
	ld h, a
	ld de, $c0d8
	call Call_01_69AD
	call Call_01_69AD
	call Call_01_69AD
	call Call_01_69AD
	call Call_01_69AD
	ld a, $ff
	ld [$da03], a
	ld [$da05], a
	ld [$da07], a
	ld hl, $c0d8
	call Call_01_6989
	ld [$da03], a
	call Call_01_696C
	cp $01
	jr z, jr_001_68d8

	ld a, [$da02]
	or a
	jr z, jr_001_68d8

jr_001_68ad:
	ld hl, $c0d8
	call Call_01_6989
	ld [$da05], a
	call Call_01_6941
	jr c, jr_001_68ad

	cp $01
	jr z, jr_001_68ad

	ld a, [$da02]
	cp $01
	jr z, jr_001_68d8

jr_001_68c6:
	ld hl, $c0d8
	call Call_01_6989
	ld [$da07], a
	call Call_01_6941
	jr c, jr_001_68c6

	cp $01
	jr z, jr_001_68c6

jr_001_68d8:
	ld a, [$ca38]
	ld bc, $001a
	call Call_1DE6
	ld a, l
	add $b8
	ld l, a
	ld a, h
	adc $6a
	ld h, a
	ld a, [$da03]
	cp $ff
	jr z, jr_001_6940

	add a
	push hl
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
	pop hl
	ld a, [$da05]
	cp $ff
	jr z, jr_001_6940

	add a
	push hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$da05], a
	ld a, [hl]
	ld [$da06], a
	ld a, $01
	ld [$da02], a
	pop hl
	ld a, [$da07]
	cp $ff
	jr z, jr_001_6940

	add a
	push hl
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [$da07], a
	ld a, [hl]
	ld [$da08], a
	ld a, $02
	ld [$da02], a
	pop hl

jr_001_6940:
	ret


Call_01_6941::
	ld b, $00
	push af
	ld c, a
	ld a, [$da03]
	cp $ff
	jr z, jr_001_6966

	cp c
	jr nz, jr_001_6950

	inc b

jr_001_6950:
	ld a, [$da05]
	cp $ff
	jr z, jr_001_6966

	cp c
	jr nz, jr_001_695b

	inc b

jr_001_695b:
	ld a, [$da07]
	cp $ff
	jr z, jr_001_6966

	cp c
	jr nz, jr_001_6966

	inc b

jr_001_6966:
	pop af
	call Call_01_696C
	cp b
	ret


Call_01_696C::
	push af
	push bc
	ld a, [$ca38]
	ld bc, $001a
	call Call_1DE6
	ld a, l
	add $c2
	ld l, a
	ld a, h
	adc $6a
	ld h, a
	pop bc
	pop af
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Call_01_6989::
	push hl
	call Call_12D0
	ld a, [$c899]
	ld l, a
	ld a, [$c89a]
	ld h, a
	ld a, $64
	call Call_1E0D
	pop hl
	ld c, a
	ld b, $ff

jr_001_699e:
	ld a, [hl]
	inc b
	inc hl
	or a
	jr z, jr_001_699e

	cp $64
	jr z, jr_001_69ab

	cp c
	jr c, jr_001_699e

jr_001_69ab:
	ld a, b
	ret


Call_01_69AD::
	ld a, [hl]
	push hl
	ld hl, $69c0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	add b
	ld b, a
	ld [de], a
	inc de
	inc hl
	ret


	db $00, $0a, $14, $1e, $28, $32, $46, $64

Call_01_69C8::
	call Call_01_69E1
	ld a, [$ca38]
	ld bc, $001a
	call Call_1DE6
	ld a, l
	add $c7
	ld l, a
	ld a, h
	adc $6a
	ld h, a
	ld a, [hl]
	ld [$c93d], a
	ret


Call_01_69E1::
	ld a, [$c935]
	ld hl, $6a22
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld a, [$c935]
	add a
	ld hl, $6a42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, $ff

jr_001_6a01:
	ld a, [$c939]
	inc a
	cp [hl]
	inc c
	inc hl
	jr nc, jr_001_6a01

	pop af
	add c
	ld [$ca38], a
	ld bc, $001a
	call Call_1DE6
	ld a, l
	add $ae
	ld l, a
	ld a, h
	adc $6a
	ld h, a
	ld a, [hl]
	ld [$c8a9], a
	ret


	db $00, $01, $03, $05, $07, $09, $0c, $0f, $12, $16, $1a, $1e, $22, $27, $2c, $31
	db $36, $3b, $40, $45, $4a, $4f, $55, $59, $5d, $61, $65, $69, $6d, $71, $75, $79
	db $82, $6a, $83, $6a, $83, $6a, $83, $6a, $83, $6a, $83, $6a, $86, $6a, $86, $6a
	db $86, $6a, $8a, $6a, $8a, $6a, $8a, $6a, $8e, $6a, $83, $6a, $8e, $6a, $93, $6a
	db $93, $6a, $86, $6a, $98, $6a, $98, $6a, $98, $6a, $9d, $6a, $a3, $6a, $a3, $6a
	db $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a3, $6a, $a7, $6a
	db $ff, $03, $06, $ff, $04, $06, $09, $ff, $04, $06, $09, $ff, $04, $06, $09, $0d
	db $ff, $05, $09, $0d, $11, $ff, $06, $0b, $10, $15, $ff, $06, $0b, $10, $15, $1a
	db $ff, $06, $0b, $15, $ff, $06, $0b, $15, $29, $3d, $51, $ff, $03, $01, $07, $00
	db $00, $03, $05, $02, $00, $00, $02, $00, $04, $00, $03, $00, $00, $00, $00, $00
	db $01, $01, $01, $00, $00, $08, $03, $02, $05, $05, $00, $03, $03, $02, $02, $00
	db $05, $00, $06, $00, $03, $00, $0e, $00, $00, $00, $03, $03, $03, $01, $00, $08
	db $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $05, $00, $06, $00, $07, $00
	db $0f, $00, $00, $00, $03, $03, $03, $02, $00, $08, $03, $03, $03, $05, $02, $03
	db $03, $02, $02, $00, $08, $00, $0a, $00, $03, $00, $0d, $00, $00, $00, $03, $03
	db $03, $01, $00, $08, $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $08, $00
	db $09, $00, $0a, $00, $0e, $00, $00, $00, $03, $03, $03, $02, $00, $08, $03, $03
	db $03, $06, $00, $03, $03, $02, $02, $00, $09, $00, $0f, $00, $11, $00, $13, $00
	db $00, $00, $03, $03, $03, $02, $00, $08, $03, $03, $02, $03, $05, $04, $03, $02
	db $01, $00, $0e, $00, $14, $00, $13, $00, $19, $00, $00, $00, $03, $03, $03, $02
	db $00, $08, $03, $03, $03, $06, $00, $03, $03, $02, $02, $00, $0d, $00, $15, $00
	db $11, $00, $19, $00, $00, $00, $03, $03, $03, $02, $00, $08, $03, $03, $02, $03
	db $05, $04, $03, $02, $01, $00, $12, $00, $16, $00, $19, $00, $10, $00, $00, $00
	db $03, $03, $03, $02, $00, $08, $04, $03, $03, $05, $02, $03, $03, $02, $02, $00
	db $14, $00, $15, $00, $19, $00, $1a, $00, $00, $00, $03, $03, $03, $02, $00, $03
	db $04, $03, $03, $05, $02, $04, $03, $02, $01, $00, $15, $00, $11, $00, $13, $00
	db $1b, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $03, $04, $03, $04
	db $03, $02, $01, $00, $16, $00, $13, $00, $10, $00, $1c, $00, $00, $00, $03, $03
	db $03, $02, $00, $03, $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $15, $00
	db $19, $00, $1d, $00, $1a, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03
	db $02, $05, $03, $04, $03, $02, $01, $00, $11, $00, $1a, $00, $17, $00, $21, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $03, $04, $03, $04, $03, $02
	db $01, $00, $10, $00, $1a, $00, $21, $00, $22, $00, $00, $00, $03, $03, $03, $02
	db $00, $0f, $03, $03, $03, $05, $02, $03, $03, $03, $01, $00, $16, $00, $1b, $00
	db $1c, $00, $23, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $02, $05
	db $03, $04, $03, $02, $01, $00, $1b, $00, $23, $00, $18, $00, $24, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $03, $04, $03, $04, $03, $02, $01, $00
	db $1b, $00, $23, $00, $24, $00, $22, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $04, $03, $00, $06, $03, $03, $03, $03, $01, $00, $17, $00, $21, $00, $23, $00
	db $26, $00, $00, $00, $03, $03, $03, $03, $00, $03, $04, $03, $00, $06, $03, $04
	db $03, $02, $01, $00, $21, $00, $28, $00, $23, $00, $26, $00, $00, $00, $03, $03
	db $03, $03, $00, $03, $04, $03, $00, $06, $03, $04, $03, $02, $01, $00, $24, $00
	db $22, $00, $23, $00, $27, $00, $00, $00, $03, $03, $03, $03, $00, $03, $04, $03
	db $00, $06, $03, $03, $02, $02, $02, $01, $22, $00, $18, $00, $23, $00, $27, $00
	db $1e, $00, $03, $03, $03, $03, $03, $03, $03, $03, $01, $05, $04, $03, $03, $02
	db $02, $00, $27, $00, $28, $00, $25, $00, $2f, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $01, $05, $04, $03, $03, $03, $01, $00, $27, $00, $25, $00
	db $2f, $00, $2b, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $05
	db $04, $04, $03, $02, $01, $00, $28, $00, $25, $00, $2b, $00, $2e, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $01, $05, $04, $04, $03, $02, $01, $00
	db $28, $00, $2b, $00, $2f, $00, $2e, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $03, $03, $01, $05, $04, $03, $03, $02, $02, $00, $24, $00, $26, $00, $29, $00
	db $2a, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $01, $05, $04, $03
	db $03, $03, $01, $00, $26, $00, $29, $00, $2a, $00, $2c, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $03, $03, $01, $05, $04, $04, $03, $02, $01, $00, $2a, $00
	db $29, $00, $2c, $00, $2d, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03
	db $01, $05, $04, $04, $03, $02, $01, $00, $2a, $00, $2c, $00, $2d, $00, $2e, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $00, $05, $05, $03, $03, $02
	db $02, $00, $2f, $00, $31, $00, $32, $00, $30, $00, $00, $00, $03, $03, $03, $02
	db $00, $03, $04, $03, $00, $05, $05, $03, $03, $03, $01, $00, $2f, $00, $32, $00
	db $30, $00, $39, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $05
	db $05, $04, $03, $02, $01, $00, $2e, $00, $32, $00, $30, $00, $3a, $00, $00, $00
	db $03, $03, $03, $02, $00, $03, $04, $03, $00, $05, $05, $04, $03, $02, $01, $00
	db $2e, $00, $30, $00, $39, $00, $3a, $00, $00, $00, $03, $03, $03, $02, $00, $03
	db $03, $03, $01, $04, $05, $03, $03, $02, $02, $00, $3b, $00, $3c, $00, $3e, $00
	db $3d, $00, $00, $00, $03, $03, $03, $01, $00, $0f, $03, $03, $01, $04, $05, $03
	db $03, $03, $01, $00, $3b, $00, $3c, $00, $3e, $00, $3d, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00, $3c, $00
	db $3e, $00, $3f, $00, $3d, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03
	db $01, $04, $05, $04, $03, $02, $01, $00, $3c, $00, $3f, $00, $41, $00, $40, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $01, $04, $05, $04, $03, $02
	db $01, $00, $41, $00, $3f, $00, $3d, $00, $40, $00, $00, $00, $03, $03, $03, $02
	db $00, $0f, $03, $03, $01, $04, $05, $03, $03, $02, $02, $00, $3a, $00, $43, $00
	db $44, $00, $42, $00, $00, $00, $03, $03, $03, $01, $00, $0f, $03, $03, $01, $04
	db $05, $03, $03, $03, $01, $00, $3a, $00, $43, $00, $44, $00, $42, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00
	db $43, $00, $44, $00, $42, $00, $46, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $03, $03, $01, $04, $05, $04, $03, $02, $01, $00, $43, $00, $42, $00, $45, $00
	db $46, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $01, $04, $05, $04
	db $03, $02, $01, $00, $42, $00, $45, $00, $47, $00, $46, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $04, $03, $00, $03, $06, $03, $03, $02, $02, $00, $49, $00
	db $48, $00, $47, $00, $4a, $00, $00, $00, $03, $03, $03, $01, $00, $03, $04, $03
	db $00, $03, $06, $03, $03, $03, $01, $00, $49, $00, $48, $00, $47, $00, $4a, $00
	db $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $03, $06, $04, $03, $02
	db $01, $00, $48, $00, $47, $00, $4a, $00, $51, $00, $00, $00, $03, $03, $03, $02
	db $00, $03, $04, $03, $00, $03, $06, $04, $03, $02, $01, $00, $48, $00, $4a, $00
	db $53, $00, $51, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $03
	db $06, $04, $03, $02, $01, $00, $4a, $00, $53, $00, $51, $00, $52, $00, $00, $00
	db $03, $03, $03, $02, $00, $03, $03, $03, $01, $04, $05, $03, $03, $02, $02, $00
	db $55, $00, $56, $00, $57, $00, $52, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $03, $03, $01, $04, $05, $03, $03, $03, $01, $00, $55, $00, $56, $00, $57, $00
	db $58, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04
	db $03, $02, $01, $00, $55, $00, $56, $00, $57, $00, $58, $00, $00, $00, $03, $03
	db $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00, $56, $00
	db $57, $00, $58, $00, $54, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03
	db $01, $04, $05, $04, $03, $02, $01, $00, $56, $00, $58, $00, $59, $00, $54, $00
	db $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $03, $03, $02
	db $02, $00, $59, $00, $5b, $00, $5c, $00, $5a, $00, $00, $00, $03, $03, $03, $02
	db $00, $0f, $03, $03, $01, $04, $05, $03, $03, $03, $01, $00, $59, $00, $5b, $00
	db $5c, $00, $5a, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04
	db $05, $04, $03, $02, $01, $00, $5b, $00, $5c, $00, $5a, $00, $5e, $00, $00, $00
	db $03, $03, $03, $02, $00, $0f, $03, $03, $01, $04, $05, $04, $03, $02, $01, $00
	db $5b, $00, $5a, $00, $5d, $00, $5e, $00, $00, $00, $03, $03, $03, $02, $00, $0f
	db $04, $03, $01, $04, $05, $04, $03, $02, $01, $00, $5a, $00, $5d, $00, $5f, $00
	db $5e, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $04, $03, $00, $03, $06, $03
	db $03, $02, $02, $00, $60, $00, $62, $00, $6b, $00, $69, $00, $00, $00, $03, $03
	db $03, $01, $00, $03, $04, $03, $00, $03, $06, $03, $03, $03, $01, $00, $60, $00
	db $62, $00, $6b, $00, $69, $00, $00, $00, $03, $03, $03, $02, $00, $03, $04, $03
	db $00, $03, $06, $04, $03, $02, $01, $00, $62, $00, $6b, $00, $69, $00, $61, $00
	db $00, $00, $03, $03, $03, $02, $00, $03, $04, $03, $00, $03, $06, $04, $03, $02
	db $01, $00, $62, $00, $69, $00, $6a, $00, $61, $00, $00, $00, $03, $03, $03, $02
	db $00, $03, $04, $03, $00, $03, $06, $04, $03, $02, $01, $00, $69, $00, $6a, $00
	db $6b, $00, $61, $00, $00, $00, $03, $03, $03, $02, $00, $03, $03, $03, $01, $04
	db $05, $03, $02, $02, $02, $01, $6c, $00, $6d, $00, $70, $00, $71, $00, $6b, $00
	db $03, $03, $03, $03, $02, $0f, $03, $03, $01, $04, $05, $03, $02, $02, $02, $01
	db $6c, $00, $6f, $00, $70, $00, $71, $00, $6b, $00, $03, $03, $03, $03, $02, $0f
	db $03, $03, $01, $04, $05, $03, $02, $02, $02, $01, $6c, $00, $6f, $00, $70, $00
	db $6b, $00, $72, $00, $03, $03, $03, $02, $02, $0f, $03, $03, $01, $04, $05, $03
	db $02, $02, $02, $01, $6c, $00, $6f, $00, $71, $00, $6b, $00, $72, $00, $03, $03
	db $03, $02, $02, $0f, $04, $03, $01, $04, $05, $02, $02, $02, $02, $02, $6c, $00
	db $6f, $00, $6b, $00, $72, $00, $73, $00, $03, $03, $03, $03, $02, $0f, $03, $03
	db $01, $04, $05, $03, $02, $02, $02, $01, $74, $00, $77, $00, $78, $00, $79, $00
	db $75, $00, $03, $03, $03, $03, $02, $0f, $03, $03, $01, $04, $05, $03, $02, $02
	db $02, $01, $77, $00, $78, $00, $79, $00, $7a, $00, $75, $00, $03, $03, $03, $03
	db $02, $0f, $03, $03, $01, $04, $05, $03, $02, $02, $02, $01, $77, $00, $79, $00
	db $7a, $00, $75, $00, $76, $00, $03, $03, $03, $02, $02, $0f, $03, $03, $01, $04
	db $05, $03, $02, $02, $02, $01, $77, $00, $79, $00, $81, $00, $75, $00, $76, $00
	db $03, $03, $03, $02, $02, $0f, $04, $03, $01, $04, $05, $02, $02, $02, $02, $02
	db $77, $00, $78, $00, $81, $00, $75, $00, $76, $00, $03, $03, $03, $03, $02, $0f
	db $04, $03, $00, $03, $06, $03, $02, $02, $02, $01, $82, $00, $84, $00, $88, $00
	db $89, $00, $83, $00, $03, $03, $03, $03, $02, $03, $04, $03, $00, $03, $06, $03
	db $02, $02, $02, $01, $82, $00, $84, $00, $86, $00, $89, $00, $83, $00, $03, $03
	db $03, $03, $02, $03, $04, $03, $00, $03, $06, $03, $02, $02, $02, $01, $82, $00
	db $84, $00, $86, $00, $89, $00, $85, $00, $03, $03, $03, $03, $02, $03, $04, $03
	db $00, $03, $06, $03, $02, $02, $02, $01, $82, $00, $83, $00, $86, $00, $89, $00
	db $85, $00, $03, $03, $03, $03, $02, $03, $04, $03, $00, $03, $06, $02, $02, $02
	db $02, $02, $82, $00, $83, $00, $85, $00, $86, $00, $87, $00, $03, $03, $03, $03
	db $02, $03, $03, $03, $00, $03, $06, $03, $02, $02, $02, $01, $8a, $00, $8b, $00
	db $8c, $00, $8d, $00, $8e, $00, $03, $03, $03, $03, $02, $0f, $03, $03, $00, $03
	db $06, $03, $02, $02, $02, $01, $8a, $00, $8b, $00, $8d, $00, $8e, $00, $8f, $00
	db $03, $03, $03, $03, $02, $0f, $03, $03, $00, $03, $06, $03, $02, $02, $02, $01
	db $8e, $00, $8d, $00, $90, $00, $91, $00, $8f, $00, $03, $03, $03, $03, $02, $0f
	db $03, $03, $00, $03, $06, $03, $02, $02, $02, $01, $8e, $00, $90, $00, $92, $00
	db $9d, $00, $8f, $00, $03, $03, $03, $03, $02, $0f, $03, $03, $00, $03, $06, $03
	db $02, $02, $02, $01, $90, $00, $92, $00, $9d, $00, $9e, $00, $8f, $00, $03, $03
	db $03, $03, $02, $0f, $04, $03, $00, $03, $06, $02, $02, $02, $02, $02, $8f, $00
	db $92, $00, $9d, $00, $9e, $00, $9f, $00, $03, $03, $03, $03, $03, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $06, $00, $0a, $00, $13, $00, $24, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $26, $00, $2c, $00, $31, $00, $46, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $03, $03, $02, $02, $00, $56, $00, $5e, $00
	db $71, $00, $74, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00
	db $07, $03, $03, $02, $02, $00, $7a, $00, $81, $00, $89, $00, $92, $00, $00, $00
	db $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $05, $00, $12, $00, $1b, $00, $23, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $02, $03, $00, $00, $07, $03, $03, $02, $02, $00, $2b, $00, $3e, $00, $45, $00
	db $55, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $70, $00, $79, $00, $88, $00, $91, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $91, $00
	db $a3, $00, $a9, $00, $bd, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $04, $00, $0e, $00, $15, $00, $22, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $32, $00, $3d, $00, $44, $00, $54, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $03, $03, $02, $02, $00, $5d, $00, $6f, $00
	db $78, $00, $87, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00
	db $07, $03, $03, $02, $02, $00, $90, $00, $a2, $00, $c5, $00, $c6, $00, $00, $00
	db $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $02, $00, $19, $00, $1e, $00, $28, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $02, $03, $00, $00, $07, $03, $03, $02, $02, $00, $2e, $00, $3b, $00, $41, $00
	db $49, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $51, $00, $5a, $00, $62, $00, $6c, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $6c, $00
	db $75, $00, $8d, $00, $b5, $00, $00, $00, $03, $03, $03, $02, $00, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $07, $00, $16, $00, $1c, $00, $25, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $3f, $00, $47, $00, $57, $00, $5f, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $03, $03, $02, $02, $00, $69, $00, $72, $00
	db $82, $00, $8a, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00
	db $07, $03, $03, $02, $02, $00, $9d, $00, $a4, $00, $aa, $00, $be, $00, $00, $00
	db $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $08, $00, $10, $00, $17, $00, $2d, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $02, $03, $00, $00, $07, $03, $03, $02, $02, $00, $39, $00, $40, $00, $58, $00
	db $60, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $03, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $6a, $00, $73, $00, $83, $00, $8b, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $02, $02, $02, $02, $02, $9e, $00
	db $a5, $00, $ab, $00, $ba, $00, $bf, $00, $03, $03, $03, $03, $03, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $09, $00, $18, $00, $1d, $00, $27, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $3a, $00, $48, $00, $59, $00, $61, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $03, $03, $00, $00, $07, $02, $02, $02, $02, $02, $6b, $00, $84, $00
	db $8c, $00, $9f, $00, $a6, $00, $03, $03, $03, $03, $03, $0f, $04, $03, $00, $00
	db $07, $02, $02, $02, $02, $02, $ac, $00, $b7, $00, $bb, $00, $c0, $00, $c1, $00
	db $03, $03, $03, $03, $03, $0f, $02, $03, $00, $00, $07, $02, $02, $02, $02, $02
	db $0f, $00, $14, $00, $21, $00, $2a, $00, $30, $00, $03, $03, $03, $03, $03, $0f
	db $02, $03, $00, $00, $07, $02, $02, $02, $02, $02, $3c, $00, $43, $00, $4a, $00
	db $53, $00, $5c, $00, $03, $03, $03, $03, $03, $0f, $03, $03, $00, $00, $07, $02
	db $02, $02, $02, $02, $6e, $00, $77, $00, $86, $00, $8f, $00, $a1, $00, $03, $03
	db $03, $03, $03, $0f, $04, $03, $00, $00, $07, $02, $02, $02, $02, $02, $a8, $00
	db $ae, $00, $b6, $00, $b9, $00, $c3, $00, $03, $03, $03, $03, $03, $0f, $02, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $0d, $00, $11, $00, $1a, $00, $29, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $02, $03, $00, $00, $07, $02, $02, $02
	db $02, $02, $2f, $00, $42, $00, $52, $00, $5b, $00, $6d, $00, $03, $03, $03, $03
	db $03, $0f, $03, $03, $00, $00, $07, $02, $02, $02, $02, $02, $76, $00, $85, $00
	db $8e, $00, $a0, $00, $a7, $00, $03, $03, $03, $03, $03, $0f, $04, $03, $00, $00
	db $07, $02, $02, $02, $02, $02, $ad, $00, $b8, $00, $bc, $00, $c2, $00, $c4, $00
	db $03, $03, $03, $03, $03, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00
	db $ba, $00, $b9, $00, $bb, $00, $bc, $00, $00, $00, $03, $03, $03, $03, $00, $0f
	db $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $bb, $00, $bc, $00, $bd, $00
	db $be, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03
	db $03, $02, $02, $00, $bd, $00, $be, $00, $bf, $00, $c0, $00, $00, $00, $03, $03
	db $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $bf, $00
	db $c0, $00, $c1, $00, $c2, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03
	db $00, $00, $07, $03, $03, $02, $02, $00, $c1, $00, $c2, $00, $c3, $00, $c4, $00
	db $00, $00, $03, $03, $03, $03, $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02
	db $02, $00, $c3, $00, $c4, $00, $c5, $00, $c6, $00, $00, $00, $03, $03, $03, $03
	db $00, $0f, $04, $03, $00, $00, $07, $03, $03, $02, $02, $00, $c5, $00, $c6, $00
	db $1e, $00, $b5, $00, $00, $00, $03, $03, $03, $03, $00, $0f, $5a, $e7, $c9, $d7
	db $c0, $3e, $07, $ea, $80, $c9, $3e, $06, $ea, $81, $c9, $c9, $f7, $fe, $e8, $62
	db $2e, $12, $38, $10, $3a, $fe, $02, $38, $05, $c0, $7e, $fe, $80, $d0, $01, $0c
	db $00, $c3, $98, $05, $fe, $3c, $d8, $fe, $48, $01, $20, $01, $d2, $5a, $05, $3a
	db $fe, $01, $d8, $20, $04, $7e, $fe, $80, $d8, $01, $f8, $ff, $c3, $98, $05, $fa
	db $96, $ca, $cb, $6f, $3e, $03, $20, $57, $fa, $c1, $ca, $a7, $c0, $cd, $82, $03
	db $38, $23, $fa, $08, $cc, $e0, $d8, $3e, $61, $e7, $cd, $82, $03, $f0, $d8, $e7
	db $d0, $21, $0f, $cc, $fa, $0f, $c0, $fe, $6a, $d0, $d6, $0c, $be, $26, $c0, $30
	db $02, $34, $c9, $35, $c9, $21, $c0, $ca, $cb, $c6, $21, $07, $c0, $cb, $86, $01
	db $5b, $78, $cd, $be, $02, $2e, $10, $36, $02, $3e, $80, $cd, $ce, $06, $cd, $0b
	db $05, $cd, $60, $78, $1e, $01, $1a, $fe, $02, $3e, $06, $28, $02, $3e, $07, $cd
	db $d8, $07, $21, $8b, $c9, $cb, $ce, $c1, $c9, $08, $58, $08, $59, $fe, $26, $c0
	db $01, $00, $00, $cd, $ff, $05, $c5, $26, $d0, $cd, $b8, $07, $36, $64, $c1, $cd
	db $e3, $05, $16, $d0, $cd, $86, $06, $3e, $1f, $e7, $01, $00, $01, $cd, $52, $05
	db $01, $00, $fe, $cd, $64, $05, $16, $cc, $c9, $1e, $01, $1a, $fe, $01, $28, $13
	db $30, $34, $d7, $c0, $36, $18, $ff, $01, $80, $00, $cd, $64, $05, $01, $80, $ff
	db $c3, $52, $05, $1e, $0f, $1a, $fe, $98, $30, $13, $01, $f8, $ff, $cd, $8e, $05
	db $d7, $c0, $36, $28, $01, $00, $01, $cd, $6c, $05, $c3, $7c, $05, $cd, $c3, $05
	db $ff, $3e, $80, $c3, $ce, $06, $d7, $c0, $3e, $03, $ea, $c0, $c9, $c3, $33, $07
	db $01, $0c, $00, $c3, $8e, $05, $c3, $84, $07, $cd, $43, $00, $e4, $78, $06, $79
	db $1b, $79, $fa, $86, $ca, $fe, $08, $d8, $ff, $01, $fd, $78, $cd, $7e, $06, $01
	db $10, $f0, $cd, $e2, $05, $01, $80, $02, $c3, $52, $05, $08, $5d, $04, $5e, $08
	db $5f, $04, $5e, $fe, $01, $fd, $78, $cd, $98, $02, $cd, $5c, $07, $d0, $ff, $3e
	db $80, $cd, $ce, $06, $2e, $10, $36, $02, $c9, $d7, $c0, $3e, $01, $cd, $d8, $07
	db $cd, $3b, $06, $01, $00, $10, $cd, $12, $06, $cd, $e2, $05, $2e, $10, $36, $01
	db $fa, $01, $cc, $fe, $03, $30, $0f, $01, $80, $02, $cd, $32, $06, $ca, $5a, $05
	db $01, $00, $ff, $c3, $5a, $05, $01, $80, $00, $c3, $4a, $05, $c9, $1e, $01, $1a
	db $fe, $08, $f5, $dc, $6f, $03, $f1, $c7, $6e, $79, $92, $79, $fc, $79, $1c, $7a
	db $34, $7a, $44, $7a, $49, $7a, $4e, $7a, $69, $7a, $c5, $7a, $1e, $02, $1a, $a7
	db $20, $0f, $cd, $0c, $7b, $fa, $86, $ca, $fe, $03, $c0, $cd, $0b, $05, $c3, $37
	db $61, $ff, $3e, $5c, $e7, $3e, $40, $cd, $ce, $06, $01, $43, $98, $c3, $22, $37
	db $cd, $0c, $7b, $d7, $c0, $36, $20, $ff, $3e, $3e, $cd, $15, $05, $cd, $4b, $16
	db $21, $14, $c0, $86, $21, $0f, $c0, $86, $cb, $47, $20, $15, $1e, $02, $1a, $fe
	db $0a, $30, $0e, $3e, $09, $01, $54, $74, $cd, $d1, $79, $21, $a8, $7b, $c3, $1e
	db $09, $3e, $0b, $01, $64, $74, $cd, $d1, $79, $21, $8f, $7b, $c3, $1e, $09, $1e
	db $1c, $12, $c5, $cd, $cc, $07, $c1, $c0, $36, $65, $54, $3e, $5b, $e7, $cd, $8a
	db $06, $cd, $e8, $07, $01, $00, $fe, $cd, $52, $05, $cd, $cf, $01, $44, $4d, $21
	db $c0, $c0, $cd, $ea, $0a, $16, $cc, $c3, $d3, $07, $d7, $c0, $36, $08, $21, $71
	db $7b, $cd, $1e, $09, $1e, $02, $1a, $fe, $10, $3e, $04, $d2, $d8, $07, $21, $8e
	db $8f, $cd, $1d, $7b, $ff, $62, $2e, $1c, $34, $c9, $d7, $c0, $3e, $40, $2e, $02
	db $96, $96, $96, $96, $cd, $ce, $06, $21, $8f, $8e, $cd, $1d, $7b, $3e, $01, $c3
	db $d8, $07, $01, $bb, $7b, $d7, $c0, $36, $20, $ff, $60, $69, $cd, $1e, $09, $c3
	db $0b, $05, $01, $c0, $7b, $18, $ee, $01, $c5, $7b, $18, $e9, $d7, $c0, $ff, $01
	db $00, $80, $cd, $e2, $05, $0e, $00, $3e, $60, $cd, $71, $63, $01, $00, $04, $cd
	db $64, $05, $3e, $48, $c3, $15, $05, $cd, $89, $64, $c8, $16, $c0, $cd, $7f, $30
	db $16, $cc, $28, $1a, $fa, $0f, $c0, $c6, $08, $fe, $6a, $30, $40, $16, $c0, $cd
	db $ff, $2f, $16, $cc, $20, $37, $fa, $0f, $c0, $c6, $08, $ea, $0f, $c0, $01, $f4
	db $fc, $21, $c0, $c0, $cd, $61, $64, $01, $fc, $e4, $21, $d4, $7b, $cd, $57, $64
	db $01, $fc, $04, $21, $e0, $7b, $cd, $57, $64, $cd, $83, $65, $d8, $3e, $1a, $cd
	db $15, $05, $3e, $20, $cd, $e6, $08, $ff, $3e, $40, $c3, $ce, $06, $3e, $01, $ea
	db $c1, $ca, $c9, $fa, $01, $c0, $fe, $03, $30, $0a, $21, $c0, $ca, $cb, $c6, $21
	db $07, $c0, $cb, $c6, $d7, $c0, $fa, $c1, $ca, $a7, $c0, $cd, $26, $04, $3e, $ac
	db $77, $ea, $96, $ca, $21, $c0, $ca, $cb, $86, $cd, $30, $07, $c3, $8c, $5e, $1e
	db $01, $1a, $a7, $c2, $ae, $08, $01, $fc, $ff, $cd, $98, $05, $cd, $38, $08, $c8
	db $ff, $cd, $c6, $05, $01, $00, $01, $c3, $64, $05, $21, $65, $7b, $fa, $82, $c9
	db $cb, $5f, $ca, $1e, $09, $21, $6b, $7b, $c3, $1e, $09, $e5, $cd, $2a, $37, $1e
	db $02, $1a, $fe, $0b, $38, $1e, $af, $cd, $59, $7b, $cd, $22, $37, $1e, $01, $1a
	db $fe, $03, $28, $10, $62, $2e, $02, $3e, $10, $96, $87, $3d, $1e, $1c, $12, $3e
	db $8e, $cd, $59, $7b, $e1, $1e, $1c, $1a, $5f, $7c, $cd, $59, $7b, $1d, $c8, $7d
	db $cd, $59, $7b, $1d, $c8, $18, $f2, $cd, $07, $0b, $0d, $cd, $07, $0b, $0c, $3e
	db $20, $df, $c9, $24, $99, $40, $41, $42, $ff, $24, $99, $67, $41, $68, $ff, $24
	db $99, $40, $41, $42, $43, $fe, $43, $99, $00, $44, $45, $46, $47, $fe, $63, $99
	db $00, $48, $49, $4a, $4b, $fe, $84, $99, $4c, $4d, $4e, $4f, $ff, $25, $99, $54
	db $55, $56, $fe, $46, $99, $57, $58, $fe, $64, $99, $59, $49, $5a, $5b, $fe, $84
	db $99, $5c, $5d, $5e, $5f, $ff, $24, $99, $60, $61, $fe, $43, $99, $62, $63, $fe
	db $63, $99, $64, $65, $fe, $84, $99, $66, $ff, $44, $99, $6b, $6c, $ff, $44, $99
	db $69, $6a, $ff, $44, $99, $6d, $6e, $fe, $64, $99, $6f, $70, $fe, $84, $99, $71
	db $72, $ff, $00, $00, $00, $00, $73, $74, $75, $76, $73, $74, $75, $76, $7a, $7e
	db $7b, $00, $74, $74, $74, $74, $74, $74, $74, $74, $cd, $64, $05, $01, $00, $02
	db $cd, $52, $05, $fa, $0f, $c0, $4f, $06, $60, $cd, $8a, $06, $2e, $00, $36, $66
	db $3e, $5a, $e7, $14, $c9, $f7, $fe, $98, $d8, $c3, $33, $07, $1e, $01, $1a, $a7
	db $20, $0f, $cd, $8d, $06, $ff, $01, $53, $7d, $cd, $be, $02, $3e, $48, $c3, $15
	db $05, $01, $53, $7d, $cd, $b1, $06, $c0, $c3, $33, $07, $cd, $4b, $00, $44, $7c
	db $3e, $59, $5a, $7c, $71, $7c, $84, $7c, $9d, $7c, $c5, $7c, $d1, $7c, $30, $7d
	db $40, $7d, $cd, $82, $4e, $cd, $47, $05, $cd, $f5, $23, $cd, $86, $06, $3e, $61
	db $cd, $10, $05, $3e, $60, $c3, $e5, $3c, $cd, $9b, $0b, $c2, $8d, $4e, $01, $a0
	db $ff, $cd, $6c, $05, $3e, $52, $e7, $3e, $21, $cd, $15, $05, $c3, $e8, $3c, $fa
	db $0f, $c0, $fe, $38, $c2, $d6, $08, $ea, $1a, $c0, $3e, $c0, $ea, $80, $ca, $c3
	db $e8, $3c, $cd, $9c, $4e, $fe, $05, $c0, $01, $4e, $7d, $cd, $be, $02, $14, $01
	db $1c, $9c, $cd, $e2, $05, $cd, $f5, $23, $c3, $e8, $3c, $cd, $9c, $4e, $cd, $b4
	db $06, $01, $4e, $7d, $c2, $98, $02, $16, $cc, $01, $40, $ff, $cd, $ec, $7b, $01
	db $00, $00, $cd, $ec, $7b, $01, $c0, $00, $cd, $ec, $7b, $3e, $44, $cd, $15, $05
	db $c3, $e8, $3c, $fa, $00, $cc, $b7, $c2, $9c, $4e, $3e, $20, $c3, $e5, $3c, $cd
	db $9c, $4e, $fa, $82, $c9, $e6, $07, $c0, $cd, $9b, $0b, $28, $1a, $cd, $cc, $07
	db $54, $36, $67, $cd, $4b, $16, $34, $e6, $3f, $c6, $14, $4f, $cd, $4b, $16, $e6
	db $0f, $c6, $94, $47, $c3, $e2, $05, $3e, $52, $e7, $01, $38, $00, $cd, $6c, $05
	db $16, $c1, $01, $20, $f8, $cd, $ba, $08, $af, $cd, $07, $0b, $01, $f8, $00, $cd
	db $ba, $08, $3e, $8b, $cd, $07, $0b, $3c, $04, $cd, $07, $0b, $01, $00, $00, $cd
	db $ba, $08, $11, $07, $01, $cd, $0c, $0b, $cd, $3c, $0b, $c3, $e8, $3c, $fa, $0f
	db $c0, $fe, $57, $c2, $dc, $2e, $ea, $1a, $c0, $3e, $c0, $c3, $e5, $3c, $cd, $9b
	db $0b, $c2, $9c, $4e, $3e, $5d, $ea, $0f, $c0, $c3, $80, $4d, $34, $53, $01, $54
	db $ff, $08, $56, $08, $57, $08, $58, $ff, $01, $82, $99, $cd, $7b, $74, $21, $76
	db $1f, $cd, $42, $20, $af, $ea, $95, $c9, $11, $00, $4f, $cd, $65, $1e, $cd, $8d
	db $1e, $cd, $a9, $7d, $c3, $f7, $15, $cd, $3d, $09, $c0, $3e, $50, $cd, $10, $05
	db $cd, $43, $1e, $3e, $5c, $c3, $f4, $15, $fa, $ff, $cd, $3c, $28, $0c, $fa, $aa
	db $cd, $c7, $ba, $7d, $c6, $7d, $de, $7d, $e6, $7d, $fa, $a5, $cd, $fe, $06, $28
	db $11, $3d, $cb, $97, $ea, $aa, $cd, $21, $a5, $cd, $7e, $34, $21, $f8, $5b, $c3
	db $5a, $09, $af, $cd, $f4, $15, $18, $ef, $cd, $d5, $7d, $cd, $07, $74, $01, $a3
	db $98, $c3, $ea, $0a, $cd, $74, $1e, $11, $6f, $57, $01, $12, $99, $cd, $d5, $7d
	db $c3, $07, $0b, $cd, $20, $74, $21, $81, $c9, $36, $04, $c9, $11, $4d, $54, $01
	db $0d, $99, $18, $e9, $11, $46, $55, $01, $ef, $98, $cd, $cf, $7d, $3c, $0c, $c3
	db $07, $0b, $cd, $20, $74, $18, $c4, $af, $cd, $2b, $05, $af, $c3, $f4, $15, $cd
	db $4b, $00, $0a, $7e, $97, $7e, $ca, $7e, $cd, $d1, $1f, $06, $ab, $cd, $43, $20
	db $cd, $74, $1e, $01, $48, $11, $cd, $93, $11, $cd, $4f, $7e, $fa, $a5, $cd, $fe
	db $04, $28, $13, $fe, $07, $cc, $8d, $7e, $14, $cd, $9e, $06, $1e, $00, $16, $68
	db $cd, $99, $1e, $c3, $e8, $3c, $14, $01, $7c, $bc, $cd, $e2, $05, $cd, $86, $06
	db $3e, $12, $e7, $01, $2f, $1c, $cd, $96, $11, $1e, $50, $18, $e1, $16, $c0, $21
	db $6d, $7e, $fa, $a5, $cd, $87, $87, $ef, $cd, $5e, $7e, $14, $4e, $23, $46, $23
	db $e5, $cd, $e2, $05, $2e, $08, $34, $e1, $c3, $86, $06, $28, $bc, $74, $e4, $28
	db $bc, $74, $e6, $24, $bc, $74, $ea, $28, $c0, $74, $e2, $18, $bc, $4d, $e6, $24
	db $bc, $74, $e4, $20, $bc, $74, $e6, $1f, $bc, $6c, $e6, $3e, $31, $cd, $8f, $06
	db $06, $eb, $c3, $43, $20, $cd, $8d, $1e, $21, $14, $c0, $35, $24, $34, $24, $35
	db $21, $92, $c9, $34, $c0, $21, $e0, $cd, $af, $cf, $cd, $1e, $09, $01, $e0, $cd
	db $7d, $02, $0c, $7c, $02, $fa, $a5, $cd, $fe, $04, $cc, $c4, $7e, $3e, $f0, $c3
	db $e5, $3c, $11, $70, $4f, $c3, $65, $1e, $cd, $9b, $0b, $c0, $cd, $80, $1e, $cd
	db $3c, $0b, $21, $a5, $cd, $7e, $34, $fe, $07, $c2, $ed, $3c, $af, $cd, $2b, $05
	db $3e, $0e, $c3, $e6, $15, $69, $98, $1b, $17, $25, $18, $14, $15, $fe, $ac, $98
	db $1b, $17, $23, $23, $13, $fe, $78, $98, $1d, $19, $29, $29, $13, $fe, $bb, $98
	db $1d, $14, $26, $19, $11, $ff, $69, $98, $10, $11, $17, $1c, $22, $13, $fe, $ad
	db $98, $1d, $17, $1c, $22, $fe, $98, $98, $1e, $17, $15, $15, $1b, $12, $11, $11
	db $ff, $89, $98, $20, $12, $1a, $18, $16, $23, $fe, $98, $98, $1e, $19, $1e, $19
	db $ff, $69, $98, $25, $20, $19, $15, $11, $14, $13, $fe, $a9, $98, $18, $20, $14
	db $00, $11, $16, $16, $23, $fe, $78, $98, $1c, $12, $11, $12, $1a, $19, $18, $13
	db $fe, $ba, $98, $1c, $16, $13, $16, $18, $14, $ff, $89, $99, $1b, $16, $16, $22
	db $27, $16, $15, $1a, $fe, $98, $99, $25, $27, $14, $14, $18, $19, $14, $fe, $00
	db $9c, $11, $19, $18, $18, $11, $14, $fe, $41, $9c, $1b, $14, $14, $10, $14, $15
	db $ff, $69, $98, $1f, $16, $1f, $16, $fe, $ad, $98, $1d, $16, $1d, $16, $fe, $98
	db $98, $25, $23, $14, $14, $29, $14, $15, $ff, $69, $98, $1c, $16, $23, $1c, $16
	db $15, $1d, $fe, $ab, $98, $1c, $16, $23, $1d, $16, $15, $fe, $98, $98, $14, $11
	db $1a, $13, $15, $12, $ff, $69, $98, $1a, $16, $23, $18, $12, $23, $12, $fe, $ae
	db $98, $1a, $12, $28, $fe, $78, $98, $1b, $12, $1b, $25, $fe, $bb, $98, $1b, $17
	db $23, $23, $13, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $01
