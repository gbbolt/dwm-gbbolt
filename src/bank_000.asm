INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $000", ROM0[$0]

RST_00::
	pop hl
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

RST_08::
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


	db $2a, $66, $6f, $c9

Call_0010::
	ld a, [$4000]
	push af
	ld a, h
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	add hl, hl
	ld h, $00
	ld bc, $4001
	add hl, bc
	call RST_08
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


	db $ff, $1e, $01, $1a, $3c, $12, $c9, $ff, $ff

VBlankInterrupt::
	di
	jp Jump_000_036e


	db $01, $1a, $18, $b8

LCDCInterrupt::
	jp Jump_000_2eea


	db $fa, $90, $cd, $18, $b0

TimerOverflowInterrupt::
	reti


	db $fa, $02, $c0, $b7, $c9, $ff, $ff

SerialTransferCompleteInterrupt::
	jp Jump_000_2edd


	db $d9, $ff, $ff, $ff, $ff, $d9, $f3, $f5, $c5, $d5, $e5, $21, $40, $ff, $cb, $86
	db $cb, $8e, $21, $c2, $dd, $34, $fa, $84, $c9, $b7, $20, $34, $3c, $ea, $84, $c9
	db $cd, $90, $ff, $cd, $f7

Call_0080::
	ld c, $80
	ld b, $0a
	ld hl, $008e

jr_000_0087:
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, jr_000_0087

	ret


	db $3e, $c0, $e0, $46, $3e, $28, $3d, $20, $fd, $c9, $13, $cd, $90, $12, $cd, $00
	db $40, $cd, $ba, $17, $af, $ea, $84, $c9, $e1, $d1, $c1, $f1, $d9, $cd, $c2, $00
	db $af, $e0, $0f, $fa, $99, $c9, $e0, $ff, $fb, $cd, $ed, $04, $e1, $d1, $c1, $f1
	db $cd, $a7, $04, $d9, $21, $91, $c9, $2a, $e0, $42, $2a, $e0, $43, $2a, $e0, $4a
	db $2a, $e0, $4b, $2a, $e0, $47, $2a, $e0, $48, $2a, $e0, $49, $7e, $e0, $45, $fa
	db $c1, $dd, $ea, $c0, $dd, $fa, $90, $c9, $e0, $40, $fa, $c7, $dd, $b7, $c8, $c3
	db $14, $12, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff

Boot::
	nop
	jp Jump_000_0150


HeaderLogo::
	db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
	db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
	db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

HeaderTitle::
	db "DRAGON WMON"

HeaderManufacturerCode::
	db "AWQE"

HeaderCGBFlag::
	db $80

HeaderNewLicenseeCode::
	db $34, $46

HeaderSGBFlag::
	db $03

HeaderCartridgeType::
	db $1b

HeaderROMSize::
	db $06

HeaderRAMSize::
	db $02

HeaderDestinationCode::
	db $01

HeaderOldLicenseeCode::
	db $33

HeaderMaskROMVersion::
	db $00

HeaderComplementCheck::
	db $49

HeaderGlobalChecksum::
	db $52, $71

Jump_000_0150:
	cp $11
	ld a, $00
	jr nz, jr_000_0157

	inc a

jr_000_0157:
	ld [$c81d], a

Jump_000_015a:
	ld sp, $dfff
	call Call_11DE
	call Call_1288
	call Call_0080
	ld hl, $8000
	ld bc, $1c00
	xor a
	call Call_12C7
	ld hl, $c88a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $04
	ld [$c8ee], a
	ld a, $00
	ld [$c88a], a
	ld a, $01
	ld [$6100], a
	ld a, $00
	ld [$4100], a
	ld a, $00
	ld [$6100], a
	ld a, $00
	ld [$4100], a
	ld a, $0a
	ld [$0100], a
	ld a, $01
	ld [$2100], a
	ld a, $00
	ld [$4100], a
	ld a, $01
	ld [$c81c], a
	ld a, $ff
	ld [$c8b7], a
	ld [$c8b8], a
	call Call_3331
	xor a
	ld [$c8c7], a
	ld a, [$c81d]
	or a
	jr z, jr_000_01c6

	xor a
	ldh [rVBK], a
	ldh [rSVBK], a
	ldh [rRP], a

jr_000_01c6:
	call Call_1024
	jr c, jr_000_01d2

	xor a
	ld [$c81c], a
	jp Jump_000_028b


jr_000_01d2:
	ld bc, $000c
	call Call_10CF
	ld a, $14
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $02
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $03
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $04
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $05
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $06
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $07
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $08
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $09
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $0c
	ld de, $0803
	ld bc, $0800
	call Call_113E
	call Call_1013
	ld a, $0d
	ld de, $0804
	call Call_10E5
	call Call_1013
	ld a, $12
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $0a
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $13
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ld a, $01
	ld [$c81c], a
	ld a, $ff
	ld [$c81b], a

Jump_000_028b:
	call Call_12A5
	call Call_1417
	call Call_13EF
	call Call_140B
	call Call_1660
	xor a
	ld [$c86a], a
	ld [$c825], a
	ld [$c829], a
	ld [$c82a], a
	ld [$c8c8], a
	ld [$c8c9], a
	ld [$df0e], a
	call Call_030F
	xor a
	ld [$c88e], a
	ld [$c88f], a
	ld [$c8a3], a
	ld [$c740], a
	ld [$c741], a
	ld [$c8a2], a
	ld [$c8a4], a
	ld [$c8a5], a
	ldh [$ffd3], a
	ld [$c8b9], a
	ld [$da78], a
	ld hl, $c8b1
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

jr_000_02db:
	ld a, [$c86c]
	or a
	call z, Call_12D0
	ld a, [$c88e]
	or a
	jr z, jr_000_02db

	ld a, [$c850]
	or a
	jr z, jr_000_02f2

	bit 7, a
	jr z, jr_000_02db

jr_000_02f2:
	di
	ld a, [$c86c]
	or a
	call nz, Call_3331
	call Call_11DE
	call Call_1013
	ld a, $00
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	jp Jump_000_028b


Call_030F::
	ld a, [$c88a]
	rst $00

JumpTable_0313::
	dw Jump_032D
	dw Jump_0332
	dw Jump_0337
	dw Jump_033C
	dw Jump_0341
	dw Jump_0346
	dw $034b
	dw $0350
	dw $0355
	dw $035a
	dw $035f
	dw $0364
	dw $0369

Jump_032D::
	ld hl, far_Call_15_4009
	rst $10
	ret


Jump_0332::
	ld hl, far_Call_01_401D
	rst $10
	ret


Jump_0337::
	ld hl, far_Call_50_5DC9
	rst $10
	ret


Jump_033C::
	ld hl, far_Call_02_4E9F
	rst $10
	ret


Jump_0341::
	ld hl, far_Call_5F_4017
	rst $10
	ret


Jump_0346::
	ld hl, far_Call_5F_5BB7
	rst $10
	ret


	db $21, $00, $18, $d7, $c9, $21, $0d, $55, $d7, $c9, $21, $00, $59, $d7, $c9, $21
	db $02, $59, $d7, $c9, $21, $04, $59, $d7, $c9, $21, $03, $56, $d7, $c9, $21, $07
	db $56, $d7, $c9

Jump_000_036e:
	push af
	push bc
	push de
	push hl
	ld hl, $c8a2
	bit 0, [hl]
	jp nz, Jump_000_045c

	set 0, [hl]
	call $ff80
	call Call_05AD
	call Call_124C
	call Call_122F
	call Call_056E
	call Call_1240
	ld a, [$c86c]
	or a
	jr z, jr_000_039b

	ld a, [$c8b9]
	or a
	call z, Call_3473

jr_000_039b:
	ei
	ld a, [$c86c]
	or a
	jr nz, jr_000_03b3

	call Call_12EE
	call Call_1364
	ld hl, $c8b9
	inc [hl]
	call Call_3473
	xor a
	ld [$c8b9], a

jr_000_03b3:
	call Call_1BB1
	call Call_046B
	ld a, [$c86c]
	or a
	jr nz, jr_000_03d9

	ld a, [$c825]
	or a
	call nz, Call_0618
	call Call_17EC
	ld a, [$c8a4]
	add $01
	ld [$c8a4], a
	ld a, [$c8a5]
	adc $00
	ld [$c8a5], a

jr_000_03d9:
	ld a, [$c842]
	and $0f
	cp $0f
	jr nz, jr_000_03e9

	ld a, [$c86c]
	or a
	jp z, Jump_000_015a

jr_000_03e9:
	ld a, [$c86c]
	or a
	jr nz, jr_000_044d

	ld a, [$c842]
	and $03
	cp $03
	jr jr_000_044d

	db $fa, $46, $c8, $cb, $57, $28, $20, $21, $ad, $c8, $fa, $8a, $c8, $22, $fa, $8b
	db $c8, $22, $fa, $8c, $c8, $22, $fa, $8d, $c8, $77, $3e, $07, $ea, $8a, $c8, $af
	db $ea, $8b, $c8, $21, $8e, $c8, $34, $fa, $42, $c8, $cb, $5f, $28, $27, $fa, $46
	db $c8, $cb, $57, $28, $20, $21, $ad, $c8, $fa, $8a, $c8, $22, $fa, $8b, $c8, $22
	db $fa, $8c, $c8, $22, $fa, $8d, $c8, $77, $3e, $0c, $ea, $8a, $c8, $af, $ea, $8b
	db $c8, $21, $8e, $c8, $34

jr_000_044d:
	ld hl, $c8a2
	res 0, [hl]

jr_000_0452:
	ldh a, [rLY]
	ld [$c886], a
	pop hl
	pop de
	pop bc
	pop af
	reti


Jump_000_045c:
	call Call_1240
	ld a, [$c8b9]
	or a
	jr nz, jr_000_0468

	call Call_3473

jr_000_0468:
	ei
	jr jr_000_0452

Call_046B::
	xor a
	ldh [$ffcb], a
	call Call_04FB
	ld a, [$c850]
	or a
	jr z, jr_000_047a

	bit 7, a
	ret z

jr_000_047a:
	call Call_1424
	ret


Call_047E::
	ld a, [$c86c]
	or a
	ret z

	ld a, [$c8c8]
	add $01
	ld [$c8c8], a
	ld a, [$c8c9]
	adc $00
	ld [$c8c9], a
	ld a, [$c8c9]
	or a
	jp nz, Jump_000_015a

	ld a, [$c863]
	bit 1, a
	ret nz

	ld a, [$c8a2]
	bit 1, a
	ret nz

	ld a, [$c842]
	ld [$c84e], a
	ld a, [$c843]
	ld [$c84f], a
	call Call_12EE
	ld a, [$c873]
	cp $ff
	jr z, jr_000_04c7

	ld a, $00
	ld [$c866], a
	ld a, [$c873]
	jp Call_126B


jr_000_04c7:
	ld hl, $c871
	ld a, [hli]
	or [hl]
	jr z, jr_000_04f1

	ld a, [$c874]
	ld l, a
	ld a, [$c875]
	ld h, a
	push hl
	ld a, [$c874]
	add $01
	ld [$c874], a
	ld a, [$c875]
	adc $00
	ld [$c875], a
	pop hl
	ld a, $00
	ld [$c866], a
	ld a, [hl]
	jp Call_126B


jr_000_04f1:
	ld a, $00
	ld [$c866], a
	ld a, $f0
	jp Call_126B


Call_04FB::
	ld a, [$c88e]
	or a
	ret nz

	ld a, [$c86c]
	or a
	jr nz, jr_000_050f

	ld a, [$c850]
	or a
	jr z, jr_000_050f

	bit 7, a
	ret z

jr_000_050f:
	ld a, [$c88a]
	rst $00

JumpTable_0513::
	dw Jump_052D
	dw Jump_0532
	dw Jump_0537
	dw Jump_053C
	dw Jump_0541
	dw Jump_0546
	dw Jump_054B
	dw $0550
	dw $0555
	dw $055a
	dw $055f
	dw $0564
	dw $0569

Jump_052D::
	ld hl, $1501
	rst $10
	ret


Jump_0532::
	ld hl, $0101
	rst $10
	ret


Jump_0537::
	ld hl, far_Call_50_5E21
	rst $10
	ret


Jump_053C::
	ld hl, far_Call_02_512C
	rst $10
	ret


Jump_0541::
	ld hl, far_Call_5F_40F7
	rst $10
	ret


Jump_0546::
	ld hl, far_Call_5F_5C8D
	rst $10
	ret


Jump_054B::
	ld hl, far_Call_18_42DE
	rst $10
	ret


	db $21, $0e, $55, $d7, $c9, $21, $01, $59, $d7, $c9, $21, $03, $59, $d7, $c9, $21
	db $05, $59, $d7, $c9, $21, $04, $56, $d7, $c9, $21, $08, $56, $d7, $c9

Call_056E::
	ld a, [$c8b1]
	or a
	jr z, jr_000_058d

	dec a
	ld [$c8b1], a
	ldh a, [rSCY]
	ld b, a
	ld a, [$c8b1]
	add a
	ld c, a
	and $07
	bit 3, c
	jr nz, jr_000_0588

	xor $07

jr_000_0588:
	sub $04
	add b
	ldh [rSCY], a

jr_000_058d:
	ld a, [$c8b2]
	or a
	jr z, jr_000_05ac

	dec a
	ld [$c8b2], a
	ldh a, [rSCX]
	ld b, a
	ld a, [$c8b2]
	add a
	ld c, a
	and $07
	bit 3, c
	jr nz, jr_000_05a7

	xor $07

jr_000_05a7:
	sub $04
	add b
	ldh [rSCX], a

jr_000_05ac:
	ret


Call_05AD::
	ld a, [$c8a3]
	or a
	ret z

	call Call_143C
	ret


Call_05B6::
	push de
	ld hl, far_Call_56_4485
	rst $10
	ld a, [$c827]
	ld l, a
	ld a, [$c828]
	ld h, a
	ld a, l
	ld [$c82b], a
	ld a, h
	ld [$c82c], a
	ld a, l
	ld [$c82f], a
	ld a, h
	ld [$c830], a
	pop de
	call Call_092F
	ld a, e
	ld [$c82d], a
	ld a, d
	ld [$c82e], a
	ld a, e
	ld [$c831], a
	ld a, d
	ld [$c832], a
	ld a, $01
	ld [$c825], a
	ld a, $00
	ld [$c826], a
	xor a
	ld [$c839], a
	ret


Call_05F6::
	call Call_092F
	ld a, [$c837]
	ld l, a
	ld a, [$c838]
	ld h, a

jr_000_0601:
	ld a, [de]
	ld [hli], a
	inc de
	cp $f0
	jr nz, jr_000_0601

	ret


Call_0609::
	ld hl, $c825
	set 1, [hl]

jr_000_060e:
	call Call_0618
	ld a, [$c825]
	or a
	jr nz, jr_000_060e

	ret


Call_0618::
	ld a, [$c826]
	bit 7, a
	jr z, Call_062F

jr_000_061f:
	ld hl, $c825
	set 1, [hl]
	call Call_062F
	ld a, [$c826]
	bit 7, a
	jr nz, jr_000_061f

	ret


Call_062F::
	ld a, [$4000]
	push af
	ld a, [$c824]
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld a, [$c825]
	or a
	jp z, Jump_000_0853

	bit 5, a
	jr z, jr_000_0666

	ld c, $ea
	ld a, [$c8a4]
	bit 4, a
	jr z, jr_000_0657

	ld c, $ee

jr_000_0657:
	ld hl, $0060
	call Call_0CFD
	ld b, $09
	call Call_0CE7
	ld a, c
	call Call_1AAD

jr_000_0666:
	ld a, [$c825]
	bit 2, a
	jp z, Jump_000_076d

	ld a, [$c83a]
	cp $e6
	jp z, Jump_000_067e

	ld a, [$c83a]
	cp $ff
	jp nz, Jump_000_0753

Jump_000_067e:
	ld a, [$c846]
	ld b, a
	ld a, [$c84a]
	or b
	bit 6, a
	jr z, jr_000_0698

	ld a, [$c83c]
	cp $00
	jr z, jr_000_06a8

	ld a, $00
	ld [$c83c], a
	jr jr_000_06a8

jr_000_0698:
	bit 7, a
	jr z, jr_000_06a8

	ld a, [$c83c]
	cp $01
	jr z, jr_000_06a8

	ld a, $01
	ld [$c83c], a

jr_000_06a8:
	ld c, $e8
	ld b, $e0
	ld a, [$c83c]
	or a
	jr z, jr_000_06b6

	ld c, $e0
	ld b, $e8

jr_000_06b6:
	ld a, [$c8a4]
	bit 4, a
	jr z, jr_000_06c1

	ld c, $e0
	ld b, $e0

jr_000_06c1:
	push bc
	ld hl, $0120
	call Call_0D11
	ld b, $0f
	call Call_0CE7
	pop bc
	ld a, c
	call Call_1AAD
	push bc
	ld hl, $0160
	call Call_0D11
	ld b, $0f
	call Call_0CE7
	pop bc
	ld a, b
	call Call_1AAD
	ld a, [$c846]
	ld b, a
	ld a, [$c84a]
	or b
	bit 0, a
	jr z, jr_000_0704

	ld a, [$c83c]
	or a
	jr nz, jr_000_0709

	ld a, [$c83a]
	cp $e6
	jp z, Jump_000_070e

	ld a, $59
	call Call_1B2C
	jr jr_000_070e

jr_000_0704:
	bit 1, a
	jp z, Jump_000_0853

jr_000_0709:
	ld a, $01
	ld [$c83c], a

Jump_000_070e:
jr_000_070e:
	ld hl, $c825
	res 2, [hl]
	res 1, [hl]
	ld hl, $0000
	call Call_0D11
	ld de, $c500
	ld c, $12

jr_000_0720:
	ld b, $20
	push hl

jr_000_0723:
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
	jr nz, jr_000_0723

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
	jr nz, jr_000_0720

	ld de, $560b
	ld hl, $8e50
	call Call_1577
	jp Jump_000_0853


Jump_000_0753:
	ld a, [$c846]
	ld b, a
	ld a, [$c84a]
	or b
	and $f7
	jp z, Jump_000_0853

	ld hl, $c825
	res 2, [hl]
	res 1, [hl]
	call Call_0864
	jp Jump_000_0853


Jump_000_076d:
	bit 6, a
	jr z, jr_000_0794

	ld a, [$c835]
	dec a
	ld [$c835], a
	or a
	jp z, Jump_000_0789

	ld a, [$c846]
	ld b, a
	ld a, [$c84a]
	or b
	and $f7
	jp z, Jump_000_0853

Jump_000_0789:
	ld hl, $c825
	res 6, [hl]
	call Call_0864
	jp Jump_000_0853


jr_000_0794:
	bit 7, a
	jr z, jr_000_07ab

	ld a, [$c836]
	dec a
	ld [$c836], a
	or a
	jp nz, Jump_000_0853

	ld hl, $c825
	res 7, [hl]
	jp Jump_000_0853


jr_000_07ab:
	ld a, [$c82d]
	ld l, a
	ld a, [$c82e]
	ld h, a
	ld a, [hl]
	cp $8d
	jp z, Jump_000_0822

	cp $8e
	jp z, Jump_000_0822

	cp $e0
	jp nc, Jump_000_0838

	ld a, [$c825]
	bit 1, a
	jr nz, jr_000_07f0

	ld a, [$c846]
	ld b, a
	ld a, [$c84a]
	or b
	and $f7
	jr z, jr_000_07db

	ld hl, $c826
	set 7, [hl]

jr_000_07db:
	ld a, $02
	ld b, a
	ld a, [$c825]
	bit 3, a
	jr z, jr_000_07e9

	ld a, [$c833]
	ld b, a

jr_000_07e9:
	ld a, [$c839]
	cp b
	jp c, Jump_000_0853

jr_000_07f0:
	xor a
	ld [$c839], a
	ld hl, $c826
	res 1, [hl]
	call Call_0954
	ld a, [hl]
	cp $e0
	jp nc, Jump_000_0838

	call Call_0880
	ld a, [$c826]
	bit 0, a
	jr z, jr_000_0853

	ld a, b
	cp $90
	jr z, jr_000_0853

	cp $9a
	jr z, jr_000_0853

	ld a, [$c840]
	call Call_1B2C
	ld hl, $c826
	set 1, [hl]
	jr jr_000_0853

Jump_000_0822:
	ld a, [$c82d]
	add $01
	ld [$c82d], a
	ld a, [$c82e]
	adc $00
	ld [$c82e], a
	ld a, [hl]
	call Call_08C1
	jr jr_000_0853

Jump_000_0838:
	ld a, [$c82d]
	add $01
	ld [$c82d], a
	ld a, [$c82e]
	adc $00
	ld [$c82e], a
	ld a, [hl]
	ld d, a
	ld hl, far_Call_56_44C7
	rst $10
	ld hl, $c826
	res 1, [hl]

Jump_000_0853:
jr_000_0853:
	ld hl, $c839
	inc [hl]
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_0864::
	ld a, [$c825]
	bit 5, a
	ret z

	res 5, a
	ld [$c825], a
	ld hl, $0060
	call Call_0CFD
	ld b, $09
	call Call_0CE7
	ld a, $ee
	call Call_1AAD
	ret


Call_0880::
	ld l, a
	ld a, [$4000]
	push af
	ld a, $4f
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	call Call_08A2
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_08A2::
	call Call_091A
	ld c, $08

jr_000_08a7:
	di

jr_000_08a8:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_08a8

	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	ei
	inc de
	dec c
	jr nz, jr_000_08a7

	ld a, l
	ld [$c82b], a
	ld a, h
	ld [$c82c], a
	ret


Call_08C1::
	ld l, a
	ld a, [$4000]
	push af
	ld a, $4f
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	call Call_08E3
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_08E3::
	call Call_091A
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld b, $10

jr_000_08f0:
	di
	ld a, b
	cp $0d
	jr z, jr_000_0901

jr_000_08f6:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_08f6

	ld a, [de]
	or [hl]
	ld [hli], a
	jr jr_000_090c

jr_000_0901:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_0901

	ld a, [de]
	or [hl]
	and $fd
	ld [hli], a

jr_000_090c:
	ei
	inc de
	dec b
	jr nz, jr_000_08f0

	ld a, l
	ld [$c82b], a
	ld a, h
	ld [$c82c], a
	ret


Call_091A::
	ld de, $4010
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld e, l
	ld d, h
	ld a, [$c82b]
	ld l, a
	ld a, [$c82c]
	ld h, a
	ret


Call_092F::
	ld a, [$4000]
	push af
	ld a, [$4000]
	ld [$c824], a
	ld a, [$c822]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [$c823]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop af
	ld [$2100], a
	ret


Call_0954::
	ld a, [$c82d]
	ld l, a
	ld a, [$c82e]
	ld h, a
	ld a, [$c82d]
	add $01
	ld [$c82d], a
	ld a, [$c82e]
	adc $00
	ld [$c82e], a
	ret


Call_096D::
	ld a, h
	ld [$c822], a
	ld a, l
	ld [$c823], a
	ld hl, far_Call_41_4A93
	rst $10
	ret


Call_097A::
	ld a, e
	ld [$c837], a
	ld a, d
	ld [$c838], a
	ld a, h
	ld [$c822], a
	ld a, l
	ld [$c823], a
	ld hl, far_Call_41_4A9A
	rst $10
	ret


Call_098F::
	ld a, l
	ld [$c827], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c829], a
	ld a, d
	ld [$c82a], a
	ld hl, far_Call_56_4485
	rst $10
	ret


Call_09A4::
	cp $64
	jr nc, jr_000_09ae

	cp $0a
	jr nc, jr_000_09b3

	jr jr_000_09b8

jr_000_09ae:
	ld e, $64
	call Call_09BD

jr_000_09b3:
	ld e, $0a
	call Call_09BD

jr_000_09b8:
	ld [hli], a
	ld a, $f0
	ld [hl], a
	ret


Call_09BD::
	ld d, $ff

jr_000_09bf:
	inc d
	sub e
	jr nc, jr_000_09bf

	add e
	ld [hl], d
	inc hl
	ret


Call_09C7::
	ld a, $0f
	ldh [$ffdb], a
	ld e, $40
	ld d, $42
	call Call_0A2E
	or a
	jp nz, Jump_000_09fb

	ld a, $01
	ldh [$ffdb], a
	ld e, $a0
	ld d, $86
	call Call_0A2E
	or a
	jr nz, jr_000_0a09

	ld a, $00
	ldh [$ffdb], a
	ld e, $10
	ld d, $27
	call Call_0A2E
	or a
	jr nz, jr_000_0a17

	ldh a, [$ffd5]
	ld c, a
	ldh a, [$ffd6]
	ld b, a
	jp Call_0A7C


Jump_000_09fb:
	ld a, $0f
	ldh [$ffdb], a
	ld e, $40
	ld d, $42
	call Call_0A52
	call Call_0AD4

jr_000_0a09:
	ld a, $01
	ldh [$ffdb], a
	ld e, $a0
	ld d, $86
	call Call_0A52
	call Call_0AD4

jr_000_0a17:
	ld a, $00
	ldh [$ffdb], a
	ld e, $10
	ld d, $27
	call Call_0A52
	call Call_0AD4
	ldh a, [$ffd5]
	ld c, a
	ldh a, [$ffd6]
	ld b, a
	jp Jump_000_0a9f


Call_0A2E::
	ldh a, [$ffd5]
	ld [$c0a0], a
	ldh a, [$ffd6]
	ld [$c0a1], a
	ldh a, [$ffd7]
	ld [$c0a2], a
	call Call_0A52
	push af
	ld a, [$c0a0]
	ldh [$ffd5], a
	ld a, [$c0a1]
	ldh [$ffd6], a
	ld a, [$c0a2]
	ldh [$ffd7], a
	pop af
	ret


Call_0A52::
	push hl
	ldh a, [$ffdb]
	ld l, a
	ld h, $ff

jr_000_0a58:
	inc h
	ldh a, [$ffd5]
	sub e
	ldh [$ffd5], a
	ldh a, [$ffd6]
	sbc d
	ldh [$ffd6], a
	ldh a, [$ffd7]
	sbc l
	ldh [$ffd7], a
	jr nc, jr_000_0a58

	ldh a, [$ffd5]
	add e
	ldh [$ffd5], a
	ldh a, [$ffd6]
	adc d
	ldh [$ffd6], a
	ldh a, [$ffd7]
	adc l
	ldh [$ffd7], a
	ld a, h
	pop hl
	ret


Call_0A7C::
	ld de, $03e8
	push bc
	call Call_0ABF
	pop bc
	or a
	jr nz, jr_000_0a9f

	ld de, $0064
	push bc
	call Call_0ABF
	pop bc
	or a
	jr nz, jr_000_0aa8

	ld de, $000a
	push bc
	call Call_0ABF
	pop bc
	or a
	jr nz, jr_000_0ab1

	jr jr_000_0aba

Jump_000_0a9f:
jr_000_0a9f:
	ld de, $03e8
	call Call_0ABF
	call Call_0AD4

jr_000_0aa8:
	ld de, $0064
	call Call_0ABF
	call Call_0AD4

jr_000_0ab1:
	ld de, $000a
	call Call_0ABF
	call Call_0AD4

jr_000_0aba:
	ld a, c
	call Call_0AD4
	ret


Call_0ABF::
	push hl
	ld h, $ff

jr_000_0ac2:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_000_0ac2

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


Call_0AD4::
	ld [hli], a
	ld a, $f0
	ld [hl], a
	ret


Call_0AD9::
	ld e, l
	ld d, h
	ld a, h
	rst $00

JumpTable_0ADD::
	dw Jump_0AF1
	dw Jump_0B13
	dw Jump_0B3E
	dw Jump_0B69
	dw Jump_0B93
	dw Jump_0BBE
	dw Jump_0BFD
	dw Jump_0C13
	dw Jump_0C3F
	dw Jump_0C6A

Jump_0AF1::
	ld a, e
	cp $e2
	jr nc, jr_000_0b03

	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_42_40EB
	rst $10
	ret


jr_000_0b03:
	sub $e2
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_43_4127
	rst $10
	ret


Jump_0B13::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $01
	ld d, a
	ld a, e
	cp $98
	jr nc, jr_000_0b2e

	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_43_4127
	rst $10
	ret


jr_000_0b2e:
	sub $98
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_44_40CD
	rst $10
	ret


Jump_0B3E::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $02
	ld d, a
	ld a, e
	cp $44
	jr nc, jr_000_0b59

	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_44_40CD
	rst $10
	ret


jr_000_0b59:
	sub $44
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_45_4101
	rst $10
	ret


Jump_0B69::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $03
	ld d, a
	ld a, e
	cp $c8
	jr nc, jr_000_0b83

	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_46_4129
	rst $10
	ret


jr_000_0b83:
	sub $c8
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_47_4079
	rst $10
	ret


Jump_0B93::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $04
	ld d, a
	ld a, e
	cp $74
	jr nc, jr_000_0bae

	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_47_4079
	rst $10
	ret


jr_000_0bae:
	sub $74
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_48_40E1
	rst $10
	ret


Jump_0BBE::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $05
	ld d, a
	ld a, e
	cp $12
	jr nc, jr_000_0bd9

	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_48_40E1
	rst $10
	ret


jr_000_0bd9:
	cp $e0
	jr nc, jr_000_0bed

	sub $12
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_49_4145
	rst $10
	ret


jr_000_0bed:
	sub $e0
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4A_424B
	rst $10
	ret


Jump_0BFD::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $06
	ld d, a
	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4A_424B
	rst $10
	ret


Jump_0C13::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $07
	ld d, a
	ld a, e
	cp $c0
	jr nc, jr_000_0c2f

	inc d
	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4A_424B
	rst $10
	ret


jr_000_0c2f:
	sub $c0
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4B_4089
	rst $10
	ret


Jump_0C3F::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $08
	ld d, a
	ld a, e
	cp $68
	jr nc, jr_000_0c5a

	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4B_4089
	rst $10
	ret


jr_000_0c5a:
	sub $68
	ld e, a
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4E_40B9
	rst $10
	ret


Jump_0C6A::
	ld a, e
	sub $00
	ld e, a
	ld a, d
	sbc $09
	ld d, a
	inc d
	ld a, d
	ld [$c822], a
	ld a, e
	ld [$c823], a
	ld hl, far_Call_4E_40B9
	rst $10
	ret


Call_0C80::
	ld b, $04

jr_000_0c82:
	ld a, [de]
	ld [hli], a
	inc de
	cp $8d
	jr z, jr_000_0c82

	cp $8e
	jr z, jr_000_0c82

	dec b
	jr nz, jr_000_0c82

	ld a, [de]
	cp $8d
	jr z, jr_000_0c9c

	cp $8e
	jr z, jr_000_0c9c

	ld [hl], $f0
	ret


jr_000_0c9c:
	ld [hli], a
	ld [hl], $f0
	ret


Call_0CA0::
	ld a, l
	ld [$c83e], a
	ld a, h
	ld [$c83f], a
	ld a, [$c827]
	ld e, a
	ld a, [$c828]
	ld d, a
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld a, [$c829]
	ld c, a
	ld a, [$c82a]
	ld b, a
	ld a, [$c83e]
	ld l, a
	ld a, [$c83f]
	ld h, a

jr_000_0cd0:
	push bc

jr_000_0cd1:
	ld a, e
	call Call_1AAD
	call Call_0CEE
	inc e
	dec b
	jr nz, jr_000_0cd1

	pop bc
	ld hl, $0040
	call Call_0CFD
	dec c
	jr nz, jr_000_0cd0

	ret


Call_0CE7::
	call Call_0CEE
	dec b
	jr nz, Call_0CE7

	ret


Call_0CEE::
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


Call_0CFD::
	ld a, [$c83e]
	add l
	ld l, a
	ld a, [$c83f]
	adc h
	and $03
	ld h, a
	ld a, [$c83f]
	and $fc
	or h
	ld h, a
	ret


Call_0D11::
	push hl
	ldh a, [$ffbb]
	and $f8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [$ffb7]
	and $f8
	rrca
	rrca
	rrca
	add l
	ld c, a
	ld b, h
	pop hl
	ld a, c
	add l
	ld l, a
	ld a, b
	adc h
	and $03
	ld h, a
	and $03
	or $98
	ld h, a
	ret


Call_0D34::
	ld a, $e0
	call Call_1AAD
	call Call_0CEE
	dec b
	jr nz, Call_0D34

	ret


Call_0D40::
	push hl
	ld l, a
	ld de, $4010
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld a, [$4000]
	push af
	ld a, $4f
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld b, $08

jr_000_0d62:
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_000_0d62

	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_0D78::
	ld a, [$4000]
	push af
	ld a, [$c824]
	ld [$2100], a
	ld a, [hl]
	ld b, a
	pop af
	ld [$2100], a
	ld a, b
	ret


	db $30, $28, $36, $25, $38, $29, $f0

Call_0D91::
	ldh a, [$ffcb]
	cp $27
	ret nc

	ld hl, $ffbb
	ld a, [hli]
	sub $11
	cpl
	ld c, a
	ld a, [hl]
	sbc $00
	cpl
	ld b, a
	ldh a, [$ffc5]
	add c
	ldh [$ffcd], a
	ldh a, [$ffc6]
	adc b
	ldh [$ffce], a
	ld hl, $ffb7
	ld a, [hli]
	sub $09
	cpl
	ld c, a
	ld a, [hl]
	sbc $00
	cpl
	ld b, a
	ld hl, $ffcf
	ldh a, [$ffc3]
	add c
	ld c, a
	ld [hli], a
	ldh a, [$ffc4]
	adc b
	ld b, a
	ld [hli], a
	ld a, c
	sub $08
	ld [hli], a
	ld a, b
	sbc $00
	ld [hl], a
	ldh a, [$ffc7]
	add a
	add e
	ld l, a
	ld a, $00
	adc d
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ldh a, [$ffc8]
	add a
	add e
	ld l, a
	ld a, $00
	adc d
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [$ffcb]
	add a
	add a
	ld e, a
	ld d, $c0
	ldh a, [$ffd3]
	or a
	jp nz, Jump_000_0ee3

	ldh a, [$ffc9]
	ld c, a
	ldh a, [$ffca]
	and $20
	jr nz, jr_000_0e6f

jr_000_0dfd:
	ld a, [hli]
	cp $80
	ret z

	ld b, a
	jr nc, jr_000_0e15

	ldh a, [$ffcd]
	add b
	ld b, a
	ldh a, [$ffce]
	adc $00
	jr nz, jr_000_0e24

	ld a, b
	cp $a8
	jr c, jr_000_0e29

	jr jr_000_0e24

jr_000_0e15:
	ldh a, [$ffcd]
	add b
	ld b, a
	ldh a, [$ffce]
	adc $ff
	jr nz, jr_000_0e24

	ld a, b
	cp $a8
	jr c, jr_000_0e29

jr_000_0e24:
	inc hl
	inc hl
	inc hl
	jr jr_000_0dfd

jr_000_0e29:
	ld a, b
	ld [de], a
	inc e
	ld a, [hli]
	ld b, a
	rlca
	jr c, jr_000_0e42

	ldh a, [$ffcf]
	add b
	ld b, a
	ldh a, [$ffd0]
	adc $00
	jr nz, jr_000_0e51

	ld a, b
	cp $b8
	jr c, jr_000_0e58

	jr jr_000_0e51

jr_000_0e42:
	ldh a, [$ffcf]
	add b
	ld b, a
	ldh a, [$ffd0]
	adc $ff
	jr nz, jr_000_0e51

	ld a, b
	cp $b8
	jr c, jr_000_0e58

jr_000_0e51:
	inc hl
	inc hl
	dec e
	xor a
	ld [de], a
	jr jr_000_0dfd

jr_000_0e58:
	ld a, b
	ld [de], a
	inc e
	ld a, [hli]
	add c
	ld [de], a
	inc e
	ldh a, [$ffca]
	xor [hl]
	inc hl
	ld [de], a
	inc e
	ldh a, [$ffcb]
	inc a
	ldh [$ffcb], a
	cp $28
	jr nz, jr_000_0dfd

	ret


jr_000_0e6f:
	ld a, [hli]
	cp $80
	ret z

	ld b, a
	jr nc, jr_000_0e87

	ldh a, [$ffcd]
	add b
	ld b, a
	ldh a, [$ffce]
	adc $00
	jr nz, jr_000_0e96

	ld a, b
	cp $a8
	jr c, jr_000_0e9b

	jr jr_000_0e96

jr_000_0e87:
	ldh a, [$ffcd]
	add b
	ld b, a
	ldh a, [$ffce]
	adc $ff
	jr nz, jr_000_0e96

	ld a, b
	cp $a8
	jr c, jr_000_0e9b

jr_000_0e96:
	inc hl
	inc hl
	inc hl
	jr jr_000_0e6f

jr_000_0e9b:
	ld a, b
	ld [de], a
	inc e
	ld a, [hli]
	ld b, a
	rlca
	jr c, jr_000_0eb6

	ldh a, [$ffd1]
	sub b
	ld b, a
	ldh a, [$ffd2]
	sbc $00
	jr z, jr_000_0ecc

	jr nz, jr_000_0ec5

	ld a, b
	cp $b8
	jr c, jr_000_0ecc

	jr jr_000_0ec5

jr_000_0eb6:
	ldh a, [$ffd1]
	sub b
	ld b, a
	ldh a, [$ffd2]
	sbc $ff
	jr nz, jr_000_0ec5

	ld a, b
	cp $b8
	jr c, jr_000_0ecc

jr_000_0ec5:
	inc hl
	inc hl
	dec e
	xor a
	ld [de], a
	jr jr_000_0e6f

jr_000_0ecc:
	ld a, b
	ld [de], a
	inc e
	ld a, [hli]
	add c
	ld [de], a
	inc e
	ldh a, [$ffca]
	xor [hl]
	inc hl
	ld [de], a
	inc e
	ldh a, [$ffcb]
	inc a
	ldh [$ffcb], a
	cp $28
	jr nz, jr_000_0e6f

	ret


Jump_000_0ee3:
	ldh a, [$ffca]
	and $20
	jr nz, jr_000_0f63

jr_000_0ee9:
	ld a, [hli]
	cp $80
	ret z

	ld c, a
	ld b, $00
	rlca
	jr nc, jr_000_0ef4

	dec b

jr_000_0ef4:
	ldh a, [$ffcd]
	add c
	ld c, a
	ldh a, [$ffce]
	adc b
	jr nz, jr_000_0f1f

	ld a, c
	cp $a8
	jr nc, jr_000_0f1f

	ldh a, [$ffd3]
	or a
	jr z, jr_000_0f24

	cp $01
	jr nz, jr_000_0f12

	ld a, c
	cp $34
	jr c, jr_000_0f1f

	jr jr_000_0f24

jr_000_0f12:
	cp $02
	jr nz, jr_000_0f1d

	ld a, c
	cp $71
	jr c, jr_000_0f24

	jr jr_000_0f1f

jr_000_0f1d:
	jr jr_000_0f24

jr_000_0f1f:
	inc hl
	inc hl
	inc hl
	jr jr_000_0ee9

jr_000_0f24:
	ld a, c
	ld [de], a
	inc e
	ld a, [hli]
	ld c, a
	ld b, $00
	rlca
	jr nc, jr_000_0f2f

	dec b

jr_000_0f2f:
	ldh a, [$ffcf]
	add c
	ld c, a
	ldh a, [$ffd0]
	adc b
	jr nz, jr_000_0f3d

	ld a, c
	cp $b8
	jr c, jr_000_0f44

jr_000_0f3d:
	inc hl
	inc hl
	dec e
	xor a
	ld [de], a
	jr jr_000_0ee9

jr_000_0f44:
	ld a, c
	ld [de], a
	call Call_0FDD
	jr nc, jr_000_0f3d

	inc e
	ldh a, [$ffc9]
	ld b, a
	ld a, [hli]
	add b
	ld [de], a
	inc e
	ldh a, [$ffca]
	xor [hl]
	inc hl
	ld [de], a
	inc e
	ldh a, [$ffcb]
	inc a
	ldh [$ffcb], a
	cp $28
	jr nz, jr_000_0ee9

	ret


jr_000_0f63:
	ld a, [hli]
	cp $80
	ret z

	ld c, a
	ld b, $00
	rlca
	jr nc, jr_000_0f6e

	dec b

jr_000_0f6e:
	ldh a, [$ffcd]
	add c
	ld c, a
	ldh a, [$ffce]
	adc b
	jr nz, jr_000_0f99

	ld a, c
	cp $a8
	jr nc, jr_000_0f99

	ldh a, [$ffd3]
	or a
	jr z, jr_000_0f9e

	cp $01
	jr nz, jr_000_0f8c

	ld a, c
	cp $34
	jr c, jr_000_0f99

	jr jr_000_0f9e

jr_000_0f8c:
	cp $02
	jr nz, jr_000_0f97

	ld a, c
	cp $71
	jr c, jr_000_0f9e

	jr jr_000_0f99

jr_000_0f97:
	jr jr_000_0f9e

jr_000_0f99:
	inc hl
	inc hl
	inc hl
	jr jr_000_0f63

jr_000_0f9e:
	ld a, c
	ld [de], a
	inc e
	ld a, [hli]
	ld c, a
	ld b, $00
	rlca
	jr nc, jr_000_0fa9

	dec b

jr_000_0fa9:
	ldh a, [$ffd1]
	sub c
	ld c, a
	ldh a, [$ffd2]
	sbc b
	jr nz, jr_000_0fb7

	ld a, c
	cp $b8
	jr c, jr_000_0fbe

jr_000_0fb7:
	inc hl
	inc hl
	dec e
	xor a
	ld [de], a
	jr jr_000_0f63

jr_000_0fbe:
	ld a, c
	ld [de], a
	call Call_0FDD
	jr nc, jr_000_0fb7

	inc e
	ldh a, [$ffc9]
	ld b, a
	ld a, [hli]
	add b
	ld [de], a
	inc e
	ldh a, [$ffca]
	xor [hl]
	inc hl
	ld [de], a
	inc e
	ldh a, [$ffcb]
	inc a
	ldh [$ffcb], a
	cp $28
	jr nz, jr_000_0f63

	ret


Call_0FDD::
	push hl
	push bc
	ldh a, [$ffbb]
	ld b, a
	dec e
	ld a, [de]
	inc e
	add b
	sub $0c
	and $f8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ldh a, [$ffb7]
	ld b, a
	ld a, [de]
	add b
	sub $04
	and $f8
	rrca
	rrca
	rrca
	add l
	ld l, a
	ld a, h
	and $03
	adc $98
	ld h, a
	ldh a, [$ffd4]
	ld b, a
	di

jr_000_1007:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_1007

	ld a, [hl]
	ei
	cp b
	pop bc
	pop hl
	ret


Call_1013::
	ld a, [$c81c]
	or a
	ret z

	ld de, $1b58

jr_000_101b:
	nop
	nop
	nop
	dec de
	ld a, d
	or e
	jr nz, jr_000_101b

	ret


Call_1024::
	ld a, $0b
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ldh a, [rP1]
	and $03
	cp $03
	jr nz, jr_000_1074

	ld a, $20
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ld a, $30
	ldh [rP1], a
	ld a, $10
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ld a, $30
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	and $03
	cp $03
	jr nz, jr_000_1074

	ld a, $0a
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	sub a
	ret


jr_000_1074:
	ld a, $0a
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	scf
	ret


Call_1082::
	ldh a, [rP1]
	ld b, $04
	ld c, a
	jr jr_000_108d

Jump_000_1089:
	ldh a, [rP1]
	cp c
	ret z

jr_000_108d:
	cpl
	and $03
	sla a
	ld d, $00
	ld e, a
	ld hl, $c76c
	add hl, de
	ld a, $20
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0f
	swap a
	ld d, a
	ld a, $30
	ldh [rP1], a
	ld a, $10
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0f
	or d
	ld d, a
	ld a, [hli]
	xor d
	and d
	ld [hld], a
	ld a, d
	ld [hl], a
	ld a, $30
	ldh [rP1], a
	dec b
	jp nz, Jump_000_1089

	ret


Call_10CF::
	ld a, [$c81c]
	or a
	ret z

jr_000_10d4:
	ld de, $06d6

jr_000_10d7:
	nop
	nop
	nop
	dec de
	ld a, d
	or e
	jr nz, jr_000_10d7

	dec bc
	ld a, b
	or c
	jr nz, jr_000_10d4

	ret


Call_10E5::
	ld [$c774], a
	ld a, [$c81c]
	or a
	ret z

	call Call_11E7
	call Call_140B
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	push de
	ld hl, $8800
	ld bc, $1000
	xor a
	call Call_12C7
	pop de
	ld a, $e4
	ldh [rBGP], a
	ld hl, $8800
	call Call_14CF
	ld hl, $9800
	ld de, $000c
	ld a, $80
	ld c, $0d

jr_000_1118:
	ld b, $14

jr_000_111a:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_000_111a

	add hl, de
	dec c
	jr nz, jr_000_1118

	ld a, $81
	ldh [rLCDC], a
	ld [$c8a1], a
	ld bc, $0005
	call Call_10CF
	ld hl, far_Call_08_4015
	rst $10
	ld bc, $0006
	call Call_10CF
	call Call_11E7
	ret


Call_113E::
	ld [$c774], a
	ld a, [$c81c]
	or a
	ret z

	push bc
	call Call_11E7
	call Call_140B
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld a, $e4
	ldh [rBGP], a
	pop bc
	ld a, [$4000]
	push af
	push bc
	ld a, d
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld a, e
	add a
	ld e, a
	ld d, $00
	ld hl, $4001
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop bc
	ld hl, $8800

jr_000_1178:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_000_1178

	ld hl, $9800
	ld de, $000c
	ld a, $80
	ld c, $0d

jr_000_118a:
	ld b, $14

jr_000_118c:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_000_118c

	add hl, de
	dec c
	jr nz, jr_000_118a

	ld a, $81
	ldh [rLCDC], a
	ld [$c8a1], a
	ld bc, $0005
	call Call_10CF
	ld hl, far_Call_08_4015
	rst $10
	ld bc, $0006
	call Call_10CF
	call Call_11E7
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_11BC::
	push hl
	push bc
	xor a
	ld hl, $c777
	ld c, $10

jr_000_11c4:
	ld [hli], a
	dec c
	jr nz, jr_000_11c4

	pop bc
	pop hl
	ret


Jump_000_11cb:
	push af
	ld a, [$c86c]
	or a
	jr z, jr_000_11d5

	call Call_1D45

jr_000_11d5:
	call Call_11FB
	pop af
	call Call_1227
	ei
	ret


Call_11DE::
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	and $e2
	ldh [rIE], a

Call_11E7::
	ld hl, $ff40
	bit 7, [hl]
	ret z

jr_000_11ed:
	ldh a, [rLY]
	cp $91
	jr nz, jr_000_11ed

	res 7, [hl]
	ld hl, $c8a1
	res 7, [hl]
	ret


Call_11FB::
	ld hl, $c8a1
	set 7, [hl]
	ld a, [hl]
	ldh [rLCDC], a
	ld a, [$c81c]
	or a
	ret z

	ld a, $01
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	call Call_1013
	ret


	db $c9, $af, $e0, $0f, $f0, $ff, $e6, $f7, $e0, $ff, $c9

Call_1220::
	ldh a, [rSC]
	bit 7, a
	jr nz, Call_1220

	ret


Call_1227::
	ld b, a
	xor a
	ldh [rIF], a
	ld a, b
	ldh [rIE], a
	ret


Call_122F::
	ldh a, [$ffb7]
	ldh [rSCX], a
	ldh a, [$ffbb]
	ldh [rSCY], a
	ldh a, [$ffb5]
	ldh [rWX], a
	ldh a, [$ffb6]
	ldh [rWY], a
	ret


Call_1240::
	ldh a, [rSTAT]
	bit 1, a
	jr nz, Call_1240

	ld a, [$c8a1]
	ldh [rLCDC], a
	ret


Call_124C::
	ld hl, $1703
	rst $10
	ld hl, $c89b
	ld a, [hli]
	ldh [rBGP], a
	ld a, [hli]
	ldh [rOBP0], a
	ld a, [hl]
	ldh [rOBP1], a
	ret


Call_125D::
	ldh a, [rSTAT]
	or $40
	ldh [rSTAT], a
	ret


Call_1264::
	ldh a, [rSTAT]
	and $07
	ldh [rSTAT], a
	ret


Call_126B::
	di
	call Call_127F
	ld a, $81
	ldh [rSC], a
	ei
	ret


Call_1275::
	di
	call Call_127F
	ld a, $80
	ldh [rSC], a
	ei
	ret


Call_127F::
	ld b, a
	ld a, $00
	ldh [rSC], a
	ld a, b
	ldh [rSB], a
	ret


Call_1288::
	ld a, [$c81d]
	push af
	ld hl, $c000
	ld bc, $1e00
	xor a
	call Call_12C7
	ld hl, $ff8a
	ld bc, $0074
	xor a
	call Call_12C7
	pop af
	ld [$c81d], a
	ret


Call_12A5::
	ld hl, $9800
	ld bc, $0800
	xor a
	call Call_12C7
	ld a, [$c81d]
	or a
	ret z

	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0800
	xor a
	call Call_12C7
	ld a, $00
	ldh [rVBK], a
	ret


Call_12C7::
	ld d, a

jr_000_12c8:
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, jr_000_12c8

	ret


Call_12D0::
	push hl
	push de
	ld a, [$c899]
	ld h, a
	ld a, [$c89a]
	ld l, a
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, de
	ld de, $1357
	add hl, de
	ld a, h
	ld [$c899], a
	ld a, l
	ld [$c89a], a
	pop de
	pop hl
	ret


Call_12EE::
	ld a, [$c81c]
	or a
	jr z, jr_000_1310

	call Call_1082
	ld a, [$c842]
	ld [$c843], a
	ld a, [$c76c]
	ld [$c842], a
	ld a, [$c844]
	ld [$c845], a
	ld a, [$c76e]
	ld [$c844], a
	ret


jr_000_1310:
	xor a
	ld [$c841], a
	call Call_1338
	ld a, [$c842]
	ld [$c843], a
	ld a, b
	ld [$c842], a
	ld a, $30
	ldh [rP1], a
	ret


	db $cd, $38, $13, $fa, $44, $c8, $ea, $45, $c8, $78, $ea, $44, $c8, $3e, $30, $e0
	db $00, $c9

Call_1338::
	ld a, $20
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0f
	swap a
	ld b, a
	ld a, $10
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	cpl
	and $0f
	or b
	ld b, a
	ret


Call_1364::
	ld a, [$c86c]
	or a
	jr nz, jr_000_1377

	ld a, [$c841]
	or a
	jr nz, jr_000_1377

	xor a
	ld [$c844], a
	ld [$c845], a

jr_000_1377:
	xor a
	ld [$c847], a
	ld hl, $c842
	ld a, [hl]
	inc hl
	xor [hl]
	dec hl
	and [hl]
	ld [$c846], a
	ld hl, $c842
	ld a, [hli]
	or a
	jr z, jr_000_1390

	cp [hl]
	jr z, jr_000_139d

jr_000_1390:
	ld a, [$c846]
	ld [$c847], a
	ld a, $14
	ld [$c848], a
	jr jr_000_13ad

jr_000_139d:
	ld hl, $c848
	ld a, [hl]
	or a
	jr nz, jr_000_13ac

	ld [hl], $06
	ld a, [$c842]
	ld [$c847], a

jr_000_13ac:
	dec [hl]

jr_000_13ad:
	xor a
	ld [$c84b], a
	ld hl, $c844
	ld a, [hl]
	inc hl
	xor [hl]
	dec hl
	and [hl]
	ld [$c84a], a
	ld hl, $c844
	ld a, [hli]
	or a
	jr z, jr_000_13c6

	cp [hl]
	jr z, jr_000_13d3

jr_000_13c6:
	ld a, [$c84a]
	ld [$c84b], a
	ld a, $14
	ld [$c84c], a
	jr jr_000_13e3

jr_000_13d3:
	ld hl, $c84c
	ld a, [hl]
	or a
	jr nz, jr_000_13e2

	ld [hl], $06
	ld a, [$c844]
	ld [$c84b], a

jr_000_13e2:
	dec [hl]

jr_000_13e3:
	ret


	db $87, $85, $6f, $3e, $00, $8c, $67, $2a, $66, $6f, $c9

Call_13EF::
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
	ret


Call_140B::
	xor a
	ld hl, $ffb7
	call Call_1412

Call_1412::
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ret


Call_1417::
	xor a
	ldh [$ffcb], a
	ld hl, $c000
	ld bc, $00a0
	call Call_12C7
	ret


Call_1424::
	ldh a, [$ffcb]
	cp $28
	ret z

	ld l, a
	sla l
	sla l
	ld h, $c0
	sub $28
	ld b, a
	xor a

jr_000_1434:
	ld [hli], a
	inc l
	inc l
	inc l
	inc b
	jr nz, jr_000_1434

	ret


Call_143C::
	ld a, [$c740]
	ld e, a
	ld a, [$c741]
	ld d, a
	ld a, d
	or e
	jr nz, jr_000_1449

	ret


jr_000_1449:
	ld a, [$c743]
	ld b, a
	ld hl, $c744
	ld a, [$c742]
	cp $ff
	ret z

	or a
	jr nz, jr_000_148f

	ld a, e
	and $e0
	ld c, a

jr_000_145d:
	ld a, [hli]
	ld [de], a
	inc e
	ld a, e
	and $1f
	or c
	ld e, a
	dec b
	jr nz, jr_000_145d

	ld a, [$c81d]
	or a
	jr z, jr_000_14c7

	ld a, $01
	ldh [rVBK], a
	ld a, [$c740]
	ld e, a
	ld a, [$c741]
	ld d, a
	ld a, [$c743]
	ld b, a

jr_000_147e:
	ld a, [hli]
	ld [de], a
	inc e
	ld a, e
	and $1f
	or c
	ld e, a
	dec b
	jr nz, jr_000_147e

	ld a, $00
	ldh [rVBK], a
	jr jr_000_14c7

jr_000_148f:
	ld a, [hli]
	ld [de], a
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	res 2, a
	ld d, a
	dec b
	jr nz, jr_000_148f

	ld a, [$c81d]
	or a
	jr z, jr_000_14c7

	ld a, $01
	ldh [rVBK], a
	ld a, [$c740]
	ld e, a
	ld a, [$c741]
	ld d, a
	ld a, [$c743]
	ld b, a

jr_000_14b4:
	ld a, [hli]
	ld [de], a
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	res 2, a
	ld d, a
	dec b
	jr nz, jr_000_14b4

	ld a, $00
	ldh [rVBK], a

jr_000_14c7:
	xor a
	ld [$c740], a
	ld [$c741], a
	ret


Call_14CF::
	ld a, [$da78]
	or a
	jr nz, Call_14CF

	inc a
	ld [$da78], a
	call Call_14E1
	xor a
	ld [$da78], a
	ret


Call_14E1::
	ld a, [$4000]
	push af
	call Call_1627

Jump_000_14e8:
jr_000_14e8:
	ld a, [de]
	inc de
	push hl
	ld hl, $ffab
	cp [hl]
	jr z, jr_000_14fc

	pop hl
	ld [hl], a
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, jr_000_14e8

	jp Jump_000_156a


jr_000_14fc:
	pop hl
	ld a, [de]
	ldh [$ffb0], a
	inc de
	ld a, [de]
	ldh [$ffaf], a
	inc de
	ldh a, [$ffaf]
	push af
	and $0f
	add $04
	cp $13
	jr nz, jr_000_1514

	ld a, [de]
	inc de
	add $13

jr_000_1514:
	ldh [$ffaf], a
	pop af
	push de
	swap a
	and $0f
	ld d, a
	ldh a, [$ffb0]
	ld e, a
	push hl
	ldh a, [$ffac]
	ld l, a
	ldh a, [$ffad]
	ld h, a
	add hl, de
	ld e, l
	ld d, h
	pop hl

jr_000_152b:
	ldh a, [$ffb2]
	cp d
	jr z, jr_000_1534

	jr c, jr_000_153b

	jr jr_000_1556

jr_000_1534:
	ldh a, [$ffb1]
	cp e
	jr z, jr_000_153b

	jr nc, jr_000_1556

jr_000_153b:
	ld a, $f0
	add d
	ld d, a
	ldh a, [$ffb4]
	cp d
	jr z, jr_000_1548

	jr nc, jr_000_154f

	jr jr_000_1556

jr_000_1548:
	ldh a, [$ffb3]
	cp e
	jr z, jr_000_1556

	jr c, jr_000_1556

jr_000_154f:
	ld a, $10
	add d
	ld d, a
	xor a
	jr jr_000_1557

jr_000_1556:
	ld a, [de]

jr_000_1557:
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr z, jr_000_1569

	ldh a, [$ffaf]
	dec a
	ldh [$ffaf], a
	jr nz, jr_000_152b

	pop de
	jp Jump_000_14e8


jr_000_1569:
	pop de

Jump_000_156a:
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_1577::
	ld a, [$da78]
	or a
	jr nz, Call_1577

	inc a
	ld [$da78], a
	call Call_1589
	xor a
	ld [$da78], a
	ret


Call_1589::
	ld a, [$4000]
	push af
	call Call_1627

Jump_000_1590:
jr_000_1590:
	ld a, [de]
	inc de
	push hl
	ld hl, $ffab
	cp [hl]
	jr z, jr_000_15a5

	pop hl
	call Call_1AB9
	dec bc
	ld a, b
	or c
	jr nz, jr_000_1590

	jp Jump_000_161a


jr_000_15a5:
	pop hl
	ld a, [de]
	ldh [$ffb0], a
	inc de
	ld a, [de]
	ldh [$ffaf], a
	inc de
	ldh a, [$ffaf]
	push af
	and $0f
	add $04
	cp $13
	jr nz, jr_000_15bd

	ld a, [de]
	inc de
	add $13

jr_000_15bd:
	ldh [$ffaf], a
	pop af
	push de
	swap a
	and $0f
	ld d, a
	ldh a, [$ffb0]
	ld e, a
	push hl
	ldh a, [$ffac]
	ld l, a
	ldh a, [$ffad]
	ld h, a
	add hl, de
	ld e, l
	ld d, h
	pop hl

jr_000_15d4:
	ldh a, [$ffb2]
	cp d
	jr z, jr_000_15dd

	jr c, jr_000_15e4

	jr jr_000_15ff

jr_000_15dd:
	ldh a, [$ffb1]
	cp e
	jr z, jr_000_15e4

	jr nc, jr_000_15ff

jr_000_15e4:
	ld a, $f0
	add d
	ld d, a
	ldh a, [$ffb4]
	cp d
	jr z, jr_000_15f1

	jr nc, jr_000_15f8

	jr jr_000_15ff

jr_000_15f1:
	ldh a, [$ffb3]
	cp e
	jr z, jr_000_15ff

	jr c, jr_000_15ff

jr_000_15f8:
	ld a, $10
	add d
	ld d, a
	xor a
	jr jr_000_1605

jr_000_15ff:
	di
	call Call_1AA6
	ld a, [de]
	ei

jr_000_1605:
	call Call_1AB9
	inc de
	dec bc
	ld a, b
	or c
	jr z, jr_000_1619

	ldh a, [$ffaf]
	dec a
	ldh [$ffaf], a
	jr nz, jr_000_15d4

	pop de
	jp Jump_000_1590


jr_000_1619:
	pop de

Jump_000_161a:
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ret


Call_1627::
	ld a, d
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	push hl
	ld l, e
	ld h, $00
	add hl, hl
	ld de, $4001
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ldh [$ffab], a
	inc de
	ld a, l
	ldh [$ffac], a
	ld a, h
	ldh [$ffad], a
	push hl
	add hl, bc
	ld a, l
	ldh [$ffb1], a
	ld a, h
	ldh [$ffb2], a
	pop hl
	ld a, l
	ldh [$ffb3], a
	ld a, h
	ldh [$ffb4], a
	ret


Call_1660::
	ld hl, $c853
	ld a, [$c89b]
	ld [hli], a
	ld a, [$c89c]
	ld [hli], a
	ld a, [$c89d]
	ld [hl], a
	jr jr_000_1671

jr_000_1671:
	xor a
	ld hl, $c856
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [$c850], a
	ld a, $07
	ld [$c851], a
	ld a, $1f
	ld [$c852], a
	ret


Call_1688::
	ld b, a
	ld a, [$c81d]
	or a
	jp nz, Jump_000_1734

	ld a, [$c81c]
	or a
	jp z, Jump_000_173f

	bit 7, b
	jr nz, jr_000_16c5

	ld a, b
	ld [$c850], a
	ld hl, $c7f7
	ld de, $c7d7
	ld c, $20

jr_000_16a7:
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, jr_000_16a7

	ld a, $00
	ld [$c856], a
	ld a, [$c850]
	srl a
	srl a
	ld [$c857], a
	ld [$c858], a
	call Call_1BD5
	jp Jump_000_17db


jr_000_16c5:
	ld a, b
	ld [$c850], a
	ld a, $20
	ld [$c856], a
	ld a, [$c850]
	cpl
	srl a
	srl a
	ld [$c857], a
	ld [$c858], a
	ld hl, $c7f7
	ld de, $c7d7
	ld c, $20

jr_000_16e4:
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, jr_000_16e4

	ld de, $7fff
	ld a, [$c851]
	bit 7, a
	jr z, jr_000_16f7

	ld de, $0000

jr_000_16f7:
	ld hl, $c7d7
	ld c, $10

jr_000_16fc:
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	dec c
	jr nz, jr_000_16fc

	call Call_11BC
	ld hl, $c7d7
	ld de, $c777
	ld a, $01
	ld [de], a
	inc de
	call Call_18C0
	call Call_1013
	ld a, [$c852]
	bit 4, a
	jp z, Jump_000_17db

	call Call_11BC
	ld hl, $c7e7
	ld de, $c777
	ld a, $09
	ld [de], a
	inc de
	call Call_18C0
	call Call_1013
	jp Jump_000_17db


Jump_000_1734:
	ld a, b
	ld [$c850], a
	ld hl, far_Call_17_4410
	rst $10
	jp Jump_000_17db


Jump_000_173f:
	ld a, [$c851]
	bit 7, a
	jr nz, jr_000_1792

	bit 7, b
	jr nz, jr_000_1772

	ld a, b
	ld [$c850], a
	ld hl, $c853
	ld a, [$c89b]
	ld [hli], a
	ld a, [$c89c]
	ld [hli], a
	ld a, [$c89d]
	ld [hl], a
	ld a, $00
	ld [$c856], a
	ld a, [$c850]
	add $02
	ld [$c857], a
	ld [$c858], a
	call Call_1BD5
	jr jr_000_17db

jr_000_1772:
	ld a, b
	ld [$c850], a
	ld a, $04
	ld [$c856], a
	ld a, [$c850]
	cpl
	add $02
	ld [$c857], a
	ld [$c858], a
	ld a, $00
	ld hl, $c89b
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jp Jump_000_17db


jr_000_1792:
	bit 7, b
	jr nz, jr_000_17be

	ld a, b
	ld [$c850], a
	ld hl, $c853
	ld a, [$c89b]
	ld [hli], a
	ld a, [$c89c]
	ld [hli], a
	ld a, [$c89d]
	ld [hl], a
	ld a, $00
	ld [$c856], a
	ld a, [$c850]
	add $02
	ld [$c857], a
	ld [$c858], a
	call Call_1BD5
	jr jr_000_17db

jr_000_17be:
	ld a, b
	ld [$c850], a
	ld a, $04
	ld [$c856], a
	ld a, [$c850]
	cpl
	add $02
	ld [$c857], a
	ld [$c858], a
	ld a, $ff
	ld hl, $c89b
	ld [hli], a
	ld [hli], a
	ld [hl], a

Jump_000_17db:
jr_000_17db:
	ret


	db $29, $29, $29, $01, $00, $88, $09, $0e, $08, $2a, $12, $13, $0d, $20, $fa, $c9

Call_17EC::
	ld a, [$c850]
	or a
	ret z

	bit 7, a
	call z, Call_1C18
	ld a, [$c81d]
	or a
	jp nz, Jump_000_1964

	ld a, [$c81c]
	or a
	jp z, Jump_000_1969

	ld a, [$c850]
	bit 7, a
	jr nz, jr_000_1836

	ld a, [$c858]
	or a
	jr z, jr_000_1816

	dec a
	ld [$c858], a
	ret


jr_000_1816:
	ld a, [$c856]
	add $05
	cp $1f
	jr c, jr_000_1821

	ld a, $1f

jr_000_1821:
	ld [$c856], a
	call Call_185F
	ld a, [$c857]
	ld [$c858], a
	ld a, [$c856]
	cp $1f
	jp z, Jump_000_1aa1

	ret


jr_000_1836:
	ld a, [$c858]
	or a
	jr z, jr_000_1841

	dec a
	ld [$c858], a
	ret


jr_000_1841:
	ld a, [$c856]
	sub $05
	bit 7, a
	jr z, jr_000_184b

	xor a

jr_000_184b:
	ld [$c856], a
	call Call_185F
	ld a, [$c857]
	ld [$c858], a
	ld a, [$c856]
	or a
	jp z, Jump_000_1aa1

	ret


Call_185F::
	ld a, [$c852]
	bit 0, a
	ld a, $00
	ld [$c85a], a
	call nz, Call_18DC
	ld a, [$c852]
	bit 1, a
	ld a, $08
	ld [$c85a], a
	call nz, Call_18DC
	ld a, [$c852]
	bit 4, a
	jr z, jr_000_189a

	ld a, [$c852]
	bit 2, a
	ld a, $10
	ld [$c85a], a
	call nz, Call_18DC
	ld a, [$c852]
	bit 3, a
	ld a, $18
	ld [$c85a], a
	call nz, Call_18DC

jr_000_189a:
	call Call_11BC
	ld hl, $c7d7
	ld de, $c777
	ld a, $01
	ld [de], a
	inc de
	call Call_18C0
	ld a, [$c852]
	bit 4, a
	ret z

	call Call_1013
	call Call_11BC
	ld hl, $c7e7
	ld de, $c777
	ld a, $09
	ld [de], a
	inc de

Call_18C0::
	ld c, $08

jr_000_18c2:
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, jr_000_18c2

	inc hl
	inc hl
	ld c, $06

jr_000_18cc:
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, jr_000_18cc

	ld a, $ff
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	ret


Call_18DC::
	call Call_18ED
	call Call_18E5
	call Call_18E5

Call_18E5::
	ld a, [$c85a]
	add $02
	ld [$c85a], a

Call_18ED::
	ld hl, $c7f7
	ld a, [$c85a]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	ld hl, $0000
	ld a, [$c856]
	ld b, a
	ld a, e
	call Call_1948
	ld l, a
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a, d
	call Call_1948
	ld d, a
	ld e, $00
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	add hl, de
	pop de
	ld a, d
	srl a
	srl a
	call Call_1948
	sla a
	sla a
	add h
	ld h, a
	push hl
	pop de
	ld hl, $c7d7
	ld b, $00
	ld a, [$c85a]
	ld c, a
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	ret


Call_1948::
	push af
	ld a, [$c851]
	ld c, a
	pop af
	bit 7, c
	jr nz, jr_000_195d

	and $1f
	add b
	cp $1f
	jr c, jr_000_1963

	ld a, $1f
	jr jr_000_1963

jr_000_195d:
	and $1f
	sub b
	jr nc, jr_000_1963

	xor a

jr_000_1963:
	ret


Jump_000_1964:
	ld hl, $1705
	rst $10
	ret


Jump_000_1969:
	ld a, [$c851]
	bit 7, a
	jp nz, Jump_000_1a08

	ld a, [$c850]
	bit 7, a
	jr nz, jr_000_1999

	ld a, [$c858]
	or a
	jr z, jr_000_1983

	dec a
	ld [$c858], a
	ret


jr_000_1983:
	call Call_19BA
	ld a, [$c857]
	ld [$c858], a
	ld a, [$c856]
	inc a
	ld [$c856], a
	cp $04
	jp z, Jump_000_1aa1

	ret


jr_000_1999:
	ld a, [$c858]
	or a
	jr z, jr_000_19a4

	dec a
	ld [$c858], a
	ret


jr_000_19a4:
	call Call_19BA
	ld a, [$c857]
	ld [$c858], a
	ld a, [$c856]
	dec a
	ld [$c856], a
	cp $ff
	jp z, Jump_000_1aa1

	ret


Call_19BA::
	ld a, [$c851]
	bit 0, a
	ld a, [$c853]
	ld hl, $c89b
	call nz, Call_19E0
	ld a, [$c851]
	bit 1, a
	ld a, [$c854]
	inc hl
	call nz, Call_19E0
	ld a, [$c851]
	bit 2, a
	ld a, [$c855]
	inc hl
	jr nz, Call_19E0

	ret


Call_19E0::
	ld d, a
	ld a, [$c856]
	ld b, a
	ld c, $00
	ld a, d
	call Call_19FB
	call Call_19F6
	call Call_19F6
	call Call_19F6
	ld [hl], c
	ret


Call_19F6::
	rrc d
	rrc d
	ld a, d

Call_19FB::
	and $03
	sub b
	jr nc, jr_000_1a01

	xor a

jr_000_1a01:
	or c
	ld c, a
	rrc c
	rrc c
	ret


Jump_000_1a08:
	ld a, [$c850]
	bit 7, a
	jr nz, jr_000_1a30

	ld a, [$c858]
	or a
	jr z, jr_000_1a1a

	dec a
	ld [$c858], a
	ret


jr_000_1a1a:
	call Call_1A50
	ld a, [$c857]
	ld [$c858], a
	ld a, [$c856]
	inc a
	ld [$c856], a
	cp $04
	jp z, Jump_000_1aa1

	ret


jr_000_1a30:
	ld a, [$c858]
	or a
	jr z, jr_000_1a3b

	dec a
	ld [$c858], a
	ret


jr_000_1a3b:
	call Call_1A50
	ld a, [$c857]
	ld [$c858], a
	ld a, [$c856]
	dec a
	ld [$c856], a
	cp $ff
	jr z, jr_000_1aa1

	ret


Call_1A50::
	ld a, [$c851]
	bit 0, a
	ld a, [$c853]
	ld hl, $c89b
	call nz, Call_1A76
	ld a, [$c851]
	bit 1, a
	ld a, [$c854]
	inc hl
	call nz, Call_1A76
	ld a, [$c851]
	bit 2, a
	ld a, [$c855]
	inc hl
	jr nz, Call_1A76

	ret


Call_1A76::
	ld d, a
	ld a, [$c856]
	ld b, a
	ld c, $00
	ld a, d
	call Call_1A91
	call Call_1A8C
	call Call_1A8C
	call Call_1A8C
	ld [hl], c
	ret


Call_1A8C::
	rrc d
	rrc d
	ld a, d

Call_1A91::
	and $03
	add b
	cp $03
	jr c, jr_000_1a9a

	ld a, $03

jr_000_1a9a:
	or c
	ld c, a
	rrc c
	rrc c
	ret


Jump_000_1aa1:
jr_000_1aa1:
	xor a
	ld [$c850], a
	ret


Call_1AA6::
	ldh a, [rSTAT]
	bit 1, a
	ret z

	jr Call_1AA6

Call_1AAD::
	push af
	di

jr_000_1aaf:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_1aaf

	pop af
	ld [hl], a
	ei
	ret


Call_1AB9::
	push af
	di

jr_000_1abb:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_1abb

	pop af
	ld [hli], a
	ei
	ret


Call_1AC5::
	push af
	ld a, [$c81d]
	or a
	jr nz, jr_000_1ace

	pop af
	ret


jr_000_1ace:
	di

jr_000_1acf:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_000_1acf

	ld a, $01
	ldh [rVBK], a
	pop af
	ld [hl], a
	ld a, $00
	ldh [rVBK], a
	ei
	ret


Call_1AE1::
	ld [$c8b7], a
	ret


Call_1AE5::
	ld [$c8b5], a
	di
	call Call_3331
	ld a, [$c8b5]
	or a
	jr z, jr_000_1b2a

	ld [$de24], a
	cp $27
	jr z, jr_000_1b22

	cp $3a
	jr z, jr_000_1b27

	cp $3f
	jr z, jr_000_1b27

	cp $47
	jr z, jr_000_1b27

	cp $49
	jr z, jr_000_1b27

	cp $4b
	jr z, jr_000_1b27

	cp $4d
	jr z, jr_000_1b27

	cp $4f
	jr z, jr_000_1b27

	cp $5d
	jr z, jr_000_1b27

	cp $9d
	jr z, jr_000_1b27

	call Call_33CC
	ei
	ret


jr_000_1b22:
	call Call_33C9
	ei
	ret


jr_000_1b27:
	call Call_33CF

jr_000_1b2a:
	ei
	ret


Call_1B2C::
	ld [$c8b8], a
	ret


Call_1B30::
	push af
	push bc
	push de
	push hl
	ld [$de24], a
	cp $3f
	jr z, jr_000_1b9d

	cp $41
	jr z, jr_000_1ba7

	cp $44
	jr z, jr_000_1ba7

	cp $47
	jr z, jr_000_1b9d

	cp $49
	jr z, jr_000_1b9d

	cp $4b
	jr z, jr_000_1b9d

	cp $4d
	jr z, jr_000_1b9d

	cp $4f
	jr z, jr_000_1b9d

	cp $57
	jr z, jr_000_1b9d

	cp $5d
	jr z, jr_000_1b9d

	cp $63
	jr z, jr_000_1b9d

	cp $61
	jr z, jr_000_1ba7

	cp $69
	jr z, jr_000_1b9d

	cp $74
	jr z, jr_000_1b9d

	cp $76
	jr z, jr_000_1b9d

	cp $78
	jr z, jr_000_1b9d

	cp $7c
	jr z, jr_000_1b9d

	cp $86
	jr z, jr_000_1b9d

	cp $8a
	jr z, jr_000_1b9d

	cp $90
	jr z, jr_000_1b9d

	cp $97
	jr z, jr_000_1b9d

	cp $99
	jr z, jr_000_1b9d

	cp $9d
	jr z, jr_000_1b9d

	di
	call Call_33D2
	ei
	pop hl
	pop de
	pop bc
	pop af
	ret


jr_000_1b9d:
	di
	call Call_33CF
	ei
	pop hl
	pop de
	pop bc
	pop af
	ret


jr_000_1ba7:
	di
	call Call_33CC
	ei
	pop hl
	pop de
	pop bc
	pop af
	ret


Call_1BB1::
	ld a, [$c8b7]
	cp $ff
	jr z, jr_000_1bc4

	cp $9d
	jr z, jr_000_1bc4

	call Call_1AE5
	ld a, $ff
	ld [$c8b7], a

jr_000_1bc4:
	ld a, [$c8b8]
	cp $ff
	jr z, jr_000_1bd3

	call Call_1B30
	ld a, $ff
	ld [$c8b8], a

jr_000_1bd3:
	ret


	db $c9

Call_1BD5::
	ld b, a
	ld a, [$c88f]
	or a
	jr nz, jr_000_1c13

	ld a, b
	bit 7, a
	jr nz, jr_000_1c13

	or a
	jr z, jr_000_1c13

	ld [$c894], a
	ld a, [$c81c]
	or a
	jr nz, jr_000_1bf5

	ld a, [$c894]
	sra a
	ld [$c894], a

jr_000_1bf5:
	ldh a, [rNR50]
	bit 7, a
	jr nz, jr_000_1c13

	bit 3, a
	jr nz, jr_000_1c13

	or a
	jr z, jr_000_1c13

	ld a, [$c894]
	ld [$c895], a
	ld a, $08
	ld [$c896], a
	ldh a, [rNR50]
	ld [$c897], a
	ret


jr_000_1c13:
	xor a
	ld [$c894], a
	ret


Call_1C18::
	ld a, [$c88f]
	or a
	jr nz, jr_000_1c84

	ld a, [$c894]
	bit 7, a
	jr nz, jr_000_1c84

	or a
	ret z

	ld a, [$c895]
	or a
	jr z, jr_000_1c32

	dec a
	ld [$c895], a
	ret


jr_000_1c32:
	ldh a, [rNR50]
	and $88
	cp $88
	jr z, jr_000_1c84

	ld a, [$c897]
	or a
	jr z, jr_000_1c84

	ld b, a
	and $0f
	ld d, a
	ld a, b
	swap a
	and $0f
	ld c, a
	bit 3, c
	jr nz, jr_000_1c53

	ld a, c
	or a
	jr z, jr_000_1c53

	dec c

jr_000_1c53:
	bit 3, d
	jr nz, jr_000_1c5c

	ld a, d
	or a
	jr z, jr_000_1c5c

	dec d

jr_000_1c5c:
	ld a, c
	swap a
	or d
	ldh [rNR50], a
	ld [$c897], a
	or a
	jr z, jr_000_1c79

	ld a, [$c896]
	or a
	jr z, jr_000_1c84

	dec a
	ld [$c896], a
	ld a, [$c894]
	ld [$c895], a
	ret


jr_000_1c79:
	ld a, [$c86c]
	or a
	jr nz, jr_000_1c84

	di
	call Call_3331
	ei

jr_000_1c84:
	xor a
	ld [$c894], a
	ret


Call_1C89::
	ld hl, $c81b
	cp [hl]
	ret z

	ld [hl], a
	cp $00
	jr nz, jr_000_1cb9

	ld a, $10
	ld de, $0805
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $11
	ld de, $0806
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $0f
	ld de, $0807
	call Call_10E5
	jr jr_000_1d37

jr_000_1cb9:
	cp $01
	jr nz, jr_000_1ce3

	ld a, $10
	ld de, $0808
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $11
	ld de, $2c00
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $0f
	ld de, $0809
	call Call_10E5
	jr jr_000_1d37

jr_000_1ce3:
	cp $02
	jr nz, jr_000_1d0d

	ld a, $10
	ld de, $2c01
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $11
	ld de, $3211
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $0f
	ld de, $3212
	call Call_10E5
	jr jr_000_1d37

jr_000_1d0d:
	cp $03
	jr nz, jr_000_1d37

	ld a, $10
	ld de, $2e24
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $11
	ld de, $2e25
	ld bc, $1000
	call Call_113E
	call Call_1013
	ld a, $0f
	ld de, $3213
	call Call_10E5
	jr jr_000_1d37

jr_000_1d37:
	ret


	db $78, $ea, $26, $de, $79, $ea, $27, $de, $af, $ea, $28, $de, $c9

Call_1D45::
	ld a, [$c86c]
	or a
	jr z, jr_000_1d94

	ld a, $08
	call Call_1227
	ld a, [$c864]
	set 7, a
	res 6, a
	ld [$c864], a
	ld a, [$c863]
	bit 1, a
	jr nz, jr_000_1d69

	ld hl, $6000

jr_000_1d64:
	dec hl
	ld a, h
	or l
	jr nz, jr_000_1d64

jr_000_1d69:
	ei
	call Call_1DA2
	call Call_1220
	ldh a, [rSB]
	cp $f5
	call nz, Call_1DA2
	di
	ld a, [$c864]
	res 7, a
	ld [$c864], a
	ld a, [$c864]
	res 0, a
	res 1, a
	ld [$c864], a
	ld a, [$c863]
	bit 1, a
	ld a, $f8
	call nz, Call_1275

jr_000_1d94:
	xor a
	ld [$c866], a
	ld hl, $c842
	ld b, $0e

jr_000_1d9d:
	ld [hli], a
	dec b
	jr nz, jr_000_1d9d

	ret


Call_1DA2::
	ld a, [$c863]
	bit 1, a
	ld a, $f5
	call nz, Call_1275
	ld a, [$c863]
	bit 1, a
	ld a, $f5
	call z, Call_126B

jr_000_1db6:
	ld a, [$c864]
	bit 6, a
	jr z, jr_000_1db6

	ret


Call_1DBE::
	ld b, $00
	ld h, b
	ld l, b
	call Call_1DC5

Call_1DC5::
	rrca
	jr nc, jr_000_1dc9

	add hl, bc

jr_000_1dc9:
	sla c
	rl b
	rrca
	jr nc, jr_000_1dd1

	add hl, bc

jr_000_1dd1:
	sla c
	rl b
	rrca
	jr nc, jr_000_1dd9

	add hl, bc

jr_000_1dd9:
	sla c
	rl b
	rrca
	jr nc, jr_000_1de1

	add hl, bc

jr_000_1de1:
	sla c
	rl b
	ret


Call_1DE6::
	push af
	push bc
	ld c, b
	call Call_1DBE
	pop bc
	pop af
	push hl
	call Call_1DBE
	pop bc
	ld a, c
	add h
	ld h, a
	ld a, b
	adc $00
	ld e, a
	ret


Call_1DFB::
	ld d, $08
	ld e, a
	xor a

jr_000_1dff:
	sla b
	rla
	jr c, jr_000_1e07

	cp e
	jr c, jr_000_1e09

jr_000_1e07:
	sub e
	inc b

jr_000_1e09:
	dec d
	jr nz, jr_000_1dff

	ret


Call_1E0D::
	ld d, $10
	ld e, a
	xor a

jr_000_1e11:
	add hl, hl
	rla
	jr c, jr_000_1e18

	cp e
	jr c, jr_000_1e1a

jr_000_1e18:
	sub e
	inc l

jr_000_1e1a:
	dec d
	jr nz, jr_000_1e11

	ret


Call_1E1E::
	ld d, $18
	ld b, a
	xor a

jr_000_1e22:
	add hl, hl
	rl e
	rla
	jr c, jr_000_1e2b

	cp b
	jr c, jr_000_1e2d

jr_000_1e2b:
	sub b
	inc l

jr_000_1e2d:
	dec d
	jr nz, jr_000_1e22

	ret


Call_1E31::
	ld a, $ff
	ldh [$ffa9], a
	ldh a, [$ffa6]
	bit 7, a
	ret nz

	ldh a, [$ffa8]
	bit 7, a
	ret nz

	ld hl, $ff9d
	ldh a, [$ffa5]
	sub [hl]
	inc hl
	ldh a, [$ffa6]
	sbc [hl]
	ret nc

	ld hl, $ff9f
	ldh a, [$ffa7]
	sub [hl]
	inc hl
	ldh a, [$ffa8]
	sbc [hl]
	ret nc

	ld a, $0f
	ldh [$ffa9], a
	ld a, [$c8eb]
	bit 2, a
	ret nz

	ld hl, $ffb7
	ldh a, [$ffa5]
	sub [hl]
	ldh [$ffa5], a
	ld b, a
	inc hl
	ldh a, [$ffa6]
	sbc [hl]
	ldh [$ffa6], a
	or a
	ret nz

	ld a, b
	cp $a0
	ret nc

	ld hl, $ffbb
	ldh a, [$ffa7]
	sub [hl]
	ldh [$ffa7], a
	ld b, a
	inc hl
	ldh a, [$ffa8]
	sbc [hl]
	ldh [$ffa8], a
	or a
	ret nz

	ld a, b
	cp $80
	ret nc

	ldh a, [$ffa7]
	and $f8
	ld l, a
	ldh a, [$ffa8]
	sla l
	rla
	sla l
	rla
	ld h, a
	ld de, $c300
	add hl, de
	ldh a, [$ffa6]
	ld d, a
	ldh a, [$ffa5]
	srl d
	rra
	srl d
	rra
	srl d
	rra
	and $1f
	ld e, a
	ld d, $00
	add hl, de
	ld c, [hl]
	ld a, [hl]
	ldh [$ffaa], a
	ld de, $26e3
	ld a, [$c969]
	or a
	jr z, jr_000_1ebf

	ld de, $2a63

jr_000_1ebf:
	ld a, [$c968]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld a, c
	ld b, $ff
	cp [hl]
	jr c, jr_000_1ed1

	ld b, $0f

jr_000_1ed1:
	ld a, b
	ldh [$ffa9], a
	ret


Call_1ED5::
	ld hl, $c777
	ld bc, $0020
	xor a
	call Call_12C7
	ld a, $20
	ld [$c777], a
	ld a, $00
	ld [$c778], a
	ld hl, $c779
	ld a, l
	ld [$c775], a
	ld a, h
	ld [$c776], a
	ret


	db $57, $87, $87, $b2, $87, $87, $b2, $f5, $fa, $75, $c7, $5f, $fa, $76, $c7, $57
	db $3e, $02, $12, $13, $f1, $12, $13, $7c, $12, $13, $7d, $12, $13, $7c, $80, $12
	db $13, $7d, $81, $12, $13, $7b, $ea, $75, $c7, $7a, $ea, $76, $c7, $21, $78, $c7
	db $34, $c9

Call_1F27::
	ld e, a
	add a
	add a
	or e
	add a
	add a
	or e
	push af
	push de
	ld a, [$c775]
	ld e, a
	ld a, [$c776]
	ld d, a
	pop af
	ld [de], a
	inc de
	pop af
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	inc de
	ld a, h
	add b
	ld [de], a
	inc de
	ld a, l
	add c
	ld [de], a
	inc de
	ld a, e
	ld [$c775], a
	ld a, d
	ld [$c776], a
	ld hl, $c778
	inc [hl]
	ret


Call_1F59::
	ld a, [$c778]
	or a
	ret z

	ld a, [$c775]
	ld l, a
	ld a, [$c776]
	ld h, a
	ld a, l
	sub $77
	ld l, a
	ld a, h
	sbc $c7
	ld h, a
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
	add $21
	ld [$c777], a
	ld a, $ff
	ld [$c774], a
	ld hl, far_Call_08_4015
	rst $10
	ret


Call_1F90::
	ld a, $0f
	ldh [$ffdb], a
	ld e, $40
	ld d, $42
	call Call_2012
	or a
	jp nz, Jump_000_1fd6

	call Call_20D9
	call Call_20DF

Call_1FA5::
	ld a, $01
	ldh [$ffdb], a
	ld e, $a0
	ld d, $86
	call Call_2012
	or a
	jr nz, jr_000_1fe7

	call Call_20D9
	call Call_20DF

Call_1FB9::
	ld a, $00
	ldh [$ffdb], a
	ld e, $10
	ld d, $27
	call Call_2012
	or a
	jr nz, Call_1FF8

	call Call_20D9
	call Call_20DF
	ldh a, [$ffd5]
	ld c, a
	ldh a, [$ffd6]
	ld b, a
	jp Jump_000_2060


Jump_000_1fd6:
	ld a, $0f
	ldh [$ffdb], a
	ld e, $40
	ld d, $42
	call Call_2036
	call Call_20D3
	call Call_20DF

jr_000_1fe7:
	ld a, $01
	ldh [$ffdb], a
	ld e, $a0
	ld d, $86
	call Call_2036
	call Call_20D3
	call Call_20DF

Call_1FF8::
	ld a, $00
	ldh [$ffdb], a
	ld e, $10
	ld d, $27
	call Call_2036
	call Call_20D3
	call Call_20DF
	ldh a, [$ffd5]
	ld c, a
	ldh a, [$ffd6]
	ld b, a
	jp Jump_000_2095


Call_2012::
	ldh a, [$ffd5]
	ld [$c0a0], a
	ldh a, [$ffd6]
	ld [$c0a1], a
	ldh a, [$ffd7]
	ld [$c0a2], a
	call Call_2036
	push af
	ld a, [$c0a0]
	ldh [$ffd5], a
	ld a, [$c0a1]
	ldh [$ffd6], a
	ld a, [$c0a2]
	ldh [$ffd7], a
	pop af
	ret


Call_2036::
	push hl
	ldh a, [$ffdb]
	ld l, a
	ld h, $ff

jr_000_203c:
	inc h
	ldh a, [$ffd5]
	sub e
	ldh [$ffd5], a
	ldh a, [$ffd6]
	sbc d
	ldh [$ffd6], a
	ldh a, [$ffd7]
	sbc l
	ldh [$ffd7], a
	jr nc, jr_000_203c

	ldh a, [$ffd5]
	add e
	ldh [$ffd5], a
	ldh a, [$ffd6]
	adc d
	ldh [$ffd6], a
	ldh a, [$ffd7]
	adc l
	ldh [$ffd7], a
	ld a, h
	pop hl
	ret


Jump_000_2060:
	ld de, $03e8
	push bc
	call Call_20BE
	pop bc
	or a
	jr nz, jr_000_2095

	call Call_20D9
	call Call_20DF

Call_2071::
	ld de, $0064
	push bc
	call Call_20BE
	pop bc
	or a
	jr nz, jr_000_20a1

	call Call_20D9
	call Call_20DF

Call_2082::
	ld de, $000a
	push bc
	call Call_20BE
	pop bc
	or a
	jr nz, Call_20AD

	call Call_20D9
	call Call_20DF
	jr jr_000_20b9

Jump_000_2095:
jr_000_2095:
	ld de, $03e8
	call Call_20BE
	call Call_20D3
	call Call_20DF

jr_000_20a1:
	ld de, $0064
	call Call_20BE
	call Call_20D3
	call Call_20DF

Call_20AD::
	ld de, $000a
	call Call_20BE
	call Call_20D3
	call Call_20DF

jr_000_20b9:
	ld a, c
	call Call_20D3
	ret


Call_20BE::
	push hl
	ld h, $ff

jr_000_20c1:
	inc h
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jr nc, jr_000_20c1

	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	ld a, h
	pop hl
	ret


Call_20D3::
	add $f0
	call Call_1AAD
	ret


Call_20D9::
	ld a, $e0
	call Call_1AAD
	ret


Call_20DF::
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


Call_20EE::
	di
	ld a, $0a
	ld [$0100], a
	ld a, [hl]
	push af
	ld a, $00
	ld [$0100], a
	pop af
	ei
	ret


Call_20FE::
	di
	push af
	ld a, $0a
	ld [$0100], a
	pop af
	ld [hl], a
	ld a, $00
	ld [$0100], a
	ei
	ret


Call_210E::
	ld a, $0a
	ld [$0100], a
	ld de, $4638

jr_000_2116:
	ld a, [hli]
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, jr_000_2116

	ld a, $00
	ld [$0100], a
	ret


Call_2128::
	ld hl, $ff8a
	ld de, $a003
	ld bc, $0021
	call Call_2184
	ld hl, $c8ea
	ld de, $a024
	ld bc, $1100
	call Call_2184
	ld hl, $c300
	ld de, $bcc8
	ld bc, $0200
	call Call_2184
	ld hl, $c200
	ld de, $bec8
	ld bc, $0100
	call Call_2184

Jump_000_2158:
	ld hl, $a002
	ld a, $01
	push af
	ld a, $0a
	ld [$0100], a
	pop af
	ld [hl], a
	ld a, $00
	ld [$0100], a
	ld hl, $a002
	ld bc, $1ffe
	call Call_210E
	ld a, $0a
	ld [$0100], a
	ld hl, $a000
	ld [hl], e
	inc hl
	ld [hl], d
	ld a, $00
	ld [$0100], a
	ret


Call_2184::
	ld a, $0a
	ld [$0100], a

jr_000_2189:
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_000_2189

	ld a, $00
	ld [$0100], a
	ret


Call_2197::
	ld hl, $cac1
	ld de, $a1fb
	ld bc, $0ba4
	call Call_2184
	ld hl, $ca8d
	ld de, $a1c7
	ld bc, $0007
	call Call_2184
	jp Jump_000_2158


Call_21B2::
	ld hl, $a002
	ld a, $0a
	ld [$0100], a
	ld a, [hl]
	push af
	ld a, $00
	ld [$0100], a
	pop af
	or a
	ret z

	ld hl, $ff8a
	ld de, $a003
	ld bc, $0021
	call Call_21F5
	ld hl, $c8ea
	ld de, $a024
	ld bc, $1100
	call Call_21F5
	ld hl, $c300
	ld de, $bcc8
	ld bc, $0200
	call Call_21F5
	ld hl, $c200
	ld de, $bec8
	ld bc, $0100
	call Call_21F5
	ret


Call_21F5::
	ld a, $0a
	ld [$0100], a

jr_000_21fa:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_000_21fa

	ld a, $00
	ld [$0100], a
	ret


Call_2208::
	push bc
	ld b, a
	ld a, [$c86c]
	or a
	jr z, jr_000_221a

	ld a, [$c88a]
	cp $02
	jr nz, jr_000_221a

	ld a, b
	pop bc
	ret


jr_000_221a:
	ld a, b
	pop bc
	ld hl, $ca8e
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Call_2229::
	push af
	push bc
	push de
	push hl
	call Call_2208
	ld c, $95
	call Call_1DBE
	pop bc
	add hl, bc
	pop de
	pop bc
	pop af
	ret


Call_223B::
	push bc
	push de
	push hl
	ld c, $95
	and $7f
	call Call_1DBE
	pop bc
	add hl, bc
	pop de
	pop bc
	ret


Call_224A::
	call Call_2229
	ld a, [hl]
	ret


Call_224F::
	call Call_2229
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $c5, $cd, $29, $22, $c1, $71, $c9

Call_225D::
	push bc
	call Call_2229
	pop bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


Call_2266::
	push af
	push bc
	push de
	push hl
	ld hl, $ca8e
	ld a, [$cac0]
	and $7f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld c, $95
	call Call_1DBE
	pop bc
	add hl, bc
	pop de
	pop bc
	pop af
	ret


Call_2284::
	call Call_2266
	ld a, [hl]
	ret


Call_2289::
	call Call_2266
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $c5, $cd, $66, $22, $c1, $71, $c9, $c5, $cd, $66, $22, $c1, $79, $22, $70, $c9

Call_22A0::
	push hl
	call Call_2208
	pop hl
	push hl
	push af
	ld hl, $cb13
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	push hl
	ld hl, $cb11
	call Call_223B
	pop bc
	pop de
	call Call_2482
	ret


Call_22BE::
	push hl
	call Call_2208
	pop hl
	push hl
	ld hl, $cb11
	call Call_223B
	pop de
	ld bc, $0000
	call Call_2496
	ret


Call_22D2::
	push hl
	call Call_2208
	pop hl
	push hl
	push af
	ld hl, $cb17
	call Call_223B
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	push hl
	ld hl, $cb15
	call Call_223B
	pop bc
	pop de
	call Call_2482
	ret


	db $e5, $cd, $08, $22, $e1, $e5, $21, $15, $cb, $cd, $3b, $22, $d1, $01, $00, $00
	db $cd, $96, $24, $c9

Call_2304::
	call Call_2442

Call_2307::
	ld de, $cb19
	ld bc, $03e7
	call Call_2448
	ret


	db $cd, $62, $24

Call_2314::
	ld de, $cb19
	ld bc, $0001
	call Call_2468
	ret


Call_231E::
	call Call_2442

Call_2321::
	ld de, $cb1b
	ld bc, $03e7
	call Call_2448
	ret


	db $cd, $62, $24

Call_232E::
	ld de, $cb1b
	ld bc, $0001
	call Call_2468
	ret


Call_2338::
	call Call_2442

Call_233B::
	ld de, $cb1d
	ld bc, $01ff
	call Call_2448
	ret


	db $cd, $62, $24

Call_2348::
	ld de, $cb1d
	ld bc, $0001
	call Call_2468
	ret


Call_2352::
	call Call_2442

Call_2355::
	ld de, $cb1f
	ld bc, $00ff
	call Call_2448
	ret


	db $cd, $62, $24

Call_2362::
	ld de, $cb1f
	ld bc, $0001
	call Call_2468
	ret


	db $cd, $42, $24, $11, $21, $cb, $01, $ff, $00, $cd, $48, $24, $c9

Call_2379::
	call Call_2462
	ld de, $cb21
	ld bc, $0000
	call Call_2468
	ret


Call_2386::
	call Call_2442
	ld de, $cb25
	ld c, $ff
	call Call_2455
	ret


Call_2392::
	call Call_2462
	ld de, $cb25
	ld c, $00
	call Call_2475
	ret


Call_239E::
	call Call_2442
	ld de, $cb28
	ld c, $ff
	call Call_2455
	ret


Call_23AA::
	call Call_2462
	ld de, $cb28
	ld c, $00
	call Call_2475
	ret


	db $cd, $42, $24, $11, $27, $cb, $0e, $ff, $cd, $55, $24, $c9, $cd, $62, $24, $11
	db $27, $cb, $0e, $00, $cd, $75, $24, $c9

Call_23CE::
	call Call_2442
	ld de, $cb26
	ld c, $ff
	call Call_2455
	ret


Call_23DA::
	call Call_2462
	ld de, $cb26
	ld c, $00
	call Call_2475
	ret


Call_23E6::
	call Call_2442

Call_23E9::
	ld de, $cb13
	ld bc, $03e7
	call Call_2448
	ret


	db $cd, $62, $24

Call_23F6::
	ld de, $cb13
	ld bc, $0001
	call Call_2468
	ret


Call_2400::
	call Call_2442

Call_2403::
	ld de, $cb17
	ld bc, $03e7
	call Call_2448
	ret


	db $cd, $62, $24

Call_2410::
	ld de, $cb17
	ld bc, $0001
	call Call_2468
	ret


Call_241A::
	ld c, e
	ld d, h
	ld e, l
	ld hl, $ca4b
	call Call_24C3
	ret


Call_2424::
	ld c, e
	ld d, h
	ld e, l
	ld hl, $ca4b
	call Call_2500
	ret


Call_242E::
	ld c, e
	ld d, h
	ld e, l
	ld hl, $ca4e
	call Call_24E4
	ret


Call_2438::
	ld c, e
	ld d, h
	ld e, l
	ld hl, $ca4e
	call Call_2500
	ret


Call_2442::
	push hl
	call Call_2208
	pop hl
	ret


Call_2448::
	push bc
	push hl
	ld l, e
	ld h, d
	call Call_223B
	pop de
	pop bc
	call Call_2482
	ret


Call_2455::
	push bc
	push hl
	ld l, e
	ld h, d
	call Call_223B
	pop de
	pop bc
	call Call_24AF
	ret


Call_2462::
	push hl
	call Call_2208
	pop hl
	ret


Call_2468::
	push bc
	push hl
	ld l, e
	ld h, d
	call Call_223B
	pop de
	pop bc
	call Call_2496
	ret


Call_2475::
	push bc
	push hl
	ld l, e
	ld h, d
	call Call_223B
	pop de
	pop bc
	call Call_24B9
	ret


Call_2482::
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	jr c, jr_000_248f

	ld a, l
	sub c
	ld a, h
	sbc b
	jr nc, jr_000_2491

jr_000_248f:
	ld c, l
	ld b, h

jr_000_2491:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


Call_2496::
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	jr c, jr_000_24aa

	ld a, l
	sub c
	ld a, h
	sbc b
	jr c, jr_000_24aa

	ld c, l
	ld b, h

jr_000_24aa:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


Call_24AF::
	ld a, [hl]
	add e
	jr c, jr_000_24b6

	cp c
	jr c, jr_000_24b7

jr_000_24b6:
	ld a, c

jr_000_24b7:
	ld [hl], a
	ret


Call_24B9::
	ld a, [hl]
	sub e
	jr c, jr_000_24c0

	cp c
	jr nc, jr_000_24c1

jr_000_24c0:
	ld a, c

jr_000_24c1:
	ld [hl], a
	ret


Call_24C3::
	push hl
	ld a, [hli]
	add e
	ld e, a
	ld a, [hli]
	adc d
	ld d, a
	ld a, [hl]
	adc c
	ld c, a
	ld a, e
	sub $9f
	ld a, d
	sbc $86
	ld a, c
	sbc $01
	jr c, jr_000_24dd

	ld de, $869f
	ld c, $01

jr_000_24dd:
	pop hl
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], c
	ret


Call_24E4::
	push hl
	ld a, [hli]
	add e
	ld e, a
	ld a, [hli]
	adc d
	ld d, a
	ld a, [hl]
	adc c
	ld c, a
	ld a, e
	sub $3f
	ld a, d
	sbc $42
	ld a, c
	sbc $0f
	jr c, jr_000_24dd

	ld de, $423f
	ld c, $0f
	jr jr_000_24dd

Call_2500::
	push hl
	ld a, [hli]
	sub e
	ld e, a
	ld a, [hli]
	sbc d
	ld d, a
	ld a, [hl]
	sbc c
	ld c, a
	jr nc, jr_000_2511

	ld de, $0000
	ld c, $00

jr_000_2511:
	pop hl
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hl], c
	ret


Call_2518::
	ld a, [$ca8d]
	or a
	jr nz, jr_000_252a

	ld hl, $c1c0
	ld bc, $0040
	ld a, $dc
	call Call_12C7
	ret


jr_000_252a:
	ld hl, $c1c0
	ld bc, $0040
	ld a, $e0
	call Call_12C7
	ld a, [$ca8d]
	or a
	ret z

	ld hl, $c1c0
	ld a, $00
	call Call_255F
	ld a, [$ca8d]
	cp $01
	ret z

	ld hl, $c1c7
	ld a, $01
	call Call_255F
	ld a, [$ca8d]
	cp $02
	ret z

	ld hl, $c1ce
	ld a, $02
	call Call_255F
	ret


Call_255F::
	ldh [$ffd5], a
	ld a, [$ca3f]
	or a
	jr nz, jr_000_25a0

	push hl
	ldh a, [$ffd5]
	add $da
	ld [hli], a
	ld a, $e1
	ld [hli], a
	ld a, $e3
	ld [hli], a
	push hl
	ld hl, $cb11
	ldh a, [$ffd5]
	call Call_224F
	pop hl
	call Call_2071
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, $e0
	ld [hli], a
	ld a, $e2
	ld [hli], a
	ld a, $e3
	ld [hli], a
	push hl
	ld hl, $cb15
	ldh a, [$ffd5]
	call Call_224F
	pop hl
	call Call_2071
	ret


jr_000_25a0:
	push hl
	ldh a, [$ffd5]
	add $da
	ld [hli], a
	ld a, $de
	ld [hli], a
	ld a, $df
	ld [hli], a
	ld a, $e4
	ld [hli], a
	push hl
	ld hl, $cb0c
	ldh a, [$ffd5]
	call Call_224A
	pop hl
	ld c, a
	ld b, $00
	call Call_2082
	pop hl
	ld a, l
	add $21
	ld l, a
	ld a, h
	adc $00
	ld h, a
	push hl
	ld hl, $cb0b
	ldh a, [$ffd5]
	call Call_224A
	ld b, a
	pop hl
	bit 0, b
	ld a, $e0
	jr z, jr_000_25db

	ld a, $d7

jr_000_25db:
	ld [hli], a
	inc hl
	bit 2, b
	ld a, $e0
	jr z, jr_000_25e5

	ld a, $d8

jr_000_25e5:
	ld [hli], a
	inc hl
	bit 7, b
	ld a, $e0
	jr z, jr_000_25ef

	ld a, $d9

jr_000_25ef:
	ld [hl], a
	ret


Call_25F1::
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
	ld de, $c1c0
	ld c, $02

jr_000_261d:
	ld b, $14
	push hl

jr_000_2620:
	ld a, [de]
	call Call_1AAD
	ld a, $07
	call Call_1AC5
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
	jr nz, jr_000_2620

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
	jr nz, jr_000_261d

	ret


Call_2652::
	ld a, [$c969]
	or a
	jr nz, jr_000_266c

	ld a, [$c968]
	cp $5d
	jr z, jr_000_266a

	cp $5e
	jr z, jr_000_266a

	ld a, [$c968]
	cp $30
	jr nc, jr_000_266c

jr_000_266a:
	xor a
	ret


jr_000_266c:
	ld a, $01
	or a
	ret


Call_2670::
	call Call_2683
	or [hl]
	ld [hl], a
	ret


	db $cd, $83, $26, $ee, $ff, $a6, $77, $c9

Call_267E::
	call Call_2683
	and [hl]
	ret


Call_2683::
	push af
	srl a
	srl a
	srl a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	push hl
	ld hl, $26d5
	and $07
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


Call_26A0::
	call Call_26B3
	or [hl]
	ld [hl], a
	ret


Call_26A6::
	call Call_26B3
	xor $ff
	and [hl]
	ld [hl], a
	ret


Call_26AE::
	call Call_26B3
	and [hl]
	ret


Call_26B3::
	push bc
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld hl, $d99b
	add hl, bc
	pop bc
	push hl
	ld hl, $26d5
	ld a, c
	and $07
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


	db $80, $40, $20, $10, $08, $04, $02, $01, $00, $2a, $40, $01, $00, $01, $57, $00
	db $08, $2a, $40, $01, $00, $02, $50, $00, $14, $2a, $e0, $01, $00, $01, $49, $00
	db $21, $2a, $40, $01, $00, $01, $30, $00, $01, $29, $e0, $01, $00, $01, $3a, $00
	db $09, $29, $e0, $01, $80, $00, $50, $00, $0e, $29, $e0, $01, $80, $00, $5a, $00
	db $12, $29, $e0, $01, $00, $01, $52, $00, $1c, $29, $a0, $00, $80, $00, $a2, $00
	db $1f, $29, $40, $01, $00, $01, $18, $00, $23, $29, $40, $01, $80, $00, $18, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $26, $29, $a0, $00, $80, $00, $30, $00
	db $00, $30, $a0, $00, $80, $00, $40, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $02, $30, $a0, $00, $80, $00, $50, $00, $04, $30, $a0, $00, $80, $00, $38, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $07, $30, $a0, $00, $00, $01, $40, $00
	db $0a, $30, $a0, $00, $80, $00, $40, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $0c, $30, $a0, $00, $80, $00, $40, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $0f, $30, $a0, $00, $00, $01, $4e, $00
	db $13, $30, $a0, $00, $80, $00, $40, $00, $15, $30, $a0, $00, $80, $00, $40, $00
	db $17, $30, $a0, $00, $80, $00, $50, $00, $19, $30, $a0, $00, $80, $00, $50, $00
	db $1b, $30, $a0, $00, $80, $00, $30, $00, $1d, $30, $a0, $00, $80, $00, $24, $00
	db $00, $2d, $a0, $00, $80, $00, $30, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $00, $2a, $40, $01, $00, $01, $57, $00, $00, $2a, $40, $01, $00, $01, $57, $00
	db $02, $2d, $a0, $00, $80, $00, $20, $00, $04, $2d, $a0, $00, $80, $00, $18, $00
	db $06, $2d, $a0, $00, $80, $00, $20, $00, $08, $2d, $a0, $00, $80, $00, $30, $00
	db $0a, $2d, $a0, $00, $80, $00, $10, $00, $0c, $2d, $a0, $00, $80, $00, $30, $00
	db $0e, $2d, $a0, $00, $80, $00, $20, $00, $10, $2d, $a0, $00, $80, $00, $20, $00
	db $12, $2d, $a0, $00, $80, $00, $20, $00, $14, $2d, $a0, $00, $80, $00, $20, $00
	db $16, $2d, $a0, $00, $80, $00, $30, $00, $18, $2d, $a0, $00, $80, $00, $28, $00
	db $1a, $2d, $40, $01, $00, $01, $70, $00, $0c, $26, $a0, $00, $80, $00, $40, $00
	db $0f, $26, $a0, $00, $80, $00, $50, $00, $15, $24, $a0, $00, $80, $00, $20, $00
	db $12, $26, $a0, $00, $80, $00, $40, $00, $15, $26, $a0, $00, $80, $00, $50, $00
	db $18, $26, $a0, $00, $80, $00, $20, $00, $1b, $26, $a0, $00, $80, $00, $50, $00
	db $1a, $25, $a0, $00, $80, $00, $40, $00, $00, $25, $a0, $00, $80, $00, $50, $00
	db $03, $23, $a0, $00, $80, $00, $20, $00, $03, $25, $a0, $00, $80, $00, $40, $00
	db $06, $24, $a0, $00, $80, $00, $50, $00, $06, $23, $a0, $00, $80, $00, $66, $00
	db $06, $25, $a0, $00, $80, $00, $10, $00, $08, $25, $a0, $00, $80, $00, $50, $00
	db $00, $24, $a0, $00, $80, $00, $50, $00, $15, $25, $a0, $00, $80, $00, $40, $00
	db $17, $25, $a0, $00, $80, $00, $40, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $0f, $24, $a0, $00, $80, $00, $40, $00, $18, $24, $a0, $00, $80, $00, $20, $00
	db $09, $24, $a0, $00, $80, $00, $50, $00, $00, $23, $a0, $00, $80, $00, $50, $00
	db $1b, $24, $a0, $00, $80, $00, $65, $00, $0c, $24, $a0, $00, $80, $00, $40, $00
	db $0b, $25, $a0, $00, $80, $00, $50, $00, $0a, $23, $a0, $00, $80, $00, $40, $00
	db $0d, $23, $a0, $00, $80, $00, $14, $00, $10, $23, $a0, $00, $80, $00, $68, $00
	db $0e, $25, $a0, $00, $80, $00, $40, $00, $11, $25, $a0, $00, $00, $01, $55, $00
	db $03, $24, $a0, $00, $80, $00, $60, $00, $00, $26, $a0, $00, $80, $00, $20, $00
	db $02, $26, $a0, $00, $80, $00, $20, $00, $04, $26, $a0, $00, $80, $00, $2b, $00
	db $18, $23, $a0, $00, $80, $00, $30, $00, $00, $37, $e0, $01, $80, $01, $30, $00
	db $0a, $37, $e0, $01, $80, $01, $30, $00, $14, $37, $e0, $01, $80, $01, $30, $00
	db $1e, $37, $e0, $01, $80, $01, $30, $00, $28, $37, $e0, $01, $80, $01, $30, $00
	db $32, $37, $e0, $01, $80, $01, $30, $00, $06, $26, $a0, $00, $80, $00, $37, $00
	db $08, $26, $a0, $00, $80, $00, $37, $00, $0a, $26, $a0, $00, $80, $00, $37, $00
	db $13, $23, $a0, $00, $80, $00, $60, $00, $16, $23, $a0, $00, $80, $00, $00, $00
	db $00, $26, $a0, $00, $80, $00, $20, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $18, $23, $a0, $00, $80, $00, $30, $00, $18, $23, $a0, $00, $80, $00, $30, $00
	db $18, $23, $a0, $00, $80, $00, $30, $00, $18, $23, $a0, $00, $80, $00, $30, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $12, $24, $a0, $00, $80, $00, $50, $00
	db $12, $24, $a0, $00, $80, $00, $50, $00, $00, $28, $80, $02, $00, $02, $30, $00
	db $01, $28, $80, $02, $00, $02, $30, $00, $02, $28, $80, $02, $00, $02, $30, $00
	db $03, $28, $80, $02, $00, $02, $30, $00, $04, $28, $80, $02, $00, $02, $30, $00
	db $05, $28, $80, $02, $00, $02, $30, $00, $06, $28, $80, $02, $00, $02, $30, $00
	db $07, $28, $80, $02, $00, $02, $30, $00, $08, $28, $80, $02, $00, $02, $30, $00
	db $09, $28, $80, $02, $00, $02, $30, $00, $0a, $28, $80, $02, $00, $02, $30, $00
	db $0b, $28, $80, $02, $00, $02, $30, $00, $0c, $28, $80, $02, $00, $02, $30, $00
	db $0d, $28, $80, $02, $00, $02, $30, $00, $0e, $28, $80, $02, $00, $02, $30, $00
	db $0f, $28, $80, $02, $00, $02, $30, $00, $00, $00, $00, $31, $01, $31, $02, $31
	db $03, $31, $04, $31, $05, $31, $06, $31, $07, $31, $08, $31, $09, $31, $0a, $31
	db $0b, $31, $0c, $31, $0d, $31, $0e, $31, $0f, $31, $10, $31, $11, $31, $12, $31
	db $13, $31, $14, $31, $15, $31, $16, $31, $17, $31, $18, $31, $19, $31, $1a, $31
	db $1b, $31, $1c, $31, $1d, $31, $1e, $31, $1f, $31, $20, $31, $21, $31, $22, $31
	db $23, $31, $24, $31, $25, $31, $26, $31, $27, $31, $28, $31, $29, $31, $2a, $31
	db $2b, $31, $2c, $31, $2d, $31, $2e, $31, $2f, $31, $30, $31, $31, $31, $32, $31
	db $33, $31, $34, $31, $35, $31, $36, $31, $37, $31, $38, $31, $39, $31, $09, $2f
	db $04, $38, $34, $38, $37, $38, $08, $39, $1e, $39, $2d, $39, $03, $3a, $26, $3a
	db $2a, $3a, $3e, $38, $31, $38, $04, $39, $39, $38, $0b, $3a, $14, $3a, $06, $39
	db $29, $38, $00, $38, $42, $31, $00, $31, $00, $31, $3a, $31, $3b, $31, $3c, $31
	db $3d, $31, $3e, $31, $3f, $31, $40, $31, $41, $31, $3a, $31, $3a, $31, $3a, $31
	db $3a, $31, $3a, $31, $3a, $31, $00, $2f, $19, $2e, $11, $2f, $12, $2f, $13, $2f
	db $14, $2f, $15, $2f, $16, $2f, $17, $2f, $18, $2f, $19, $2f, $1a, $2f, $1b, $2f
	db $1c, $2f, $1d, $2f, $1e, $2f, $1f, $2f, $20, $2f, $21, $2f, $22, $2f, $23, $2f
	db $24, $2f, $25, $2f, $26, $2f, $27, $2f, $28, $2f, $29, $2f, $2a, $2f, $2b, $2f
	db $2c, $2f, $2d, $2f, $2e, $2f, $2f, $2f, $30, $2f, $31, $2f, $32, $2f, $33, $2f
	db $34, $2f, $35, $2f, $36, $2f, $37, $2f, $00, $36, $01, $36, $02, $36, $03, $36
	db $04, $36, $05, $36, $06, $36, $07, $36, $08, $36, $09, $36, $0a, $36, $0b, $36
	db $0c, $36, $0d, $36, $0e, $36, $0f, $36, $10, $36, $11, $36, $12, $36, $13, $36
	db $14, $36, $15, $36, $16, $36, $17, $36, $18, $36, $19, $36, $1a, $36, $1b, $36
	db $1c, $36, $1d, $36, $1e, $36, $1f, $36, $20, $36, $21, $36, $22, $36, $23, $36
	db $24, $36, $25, $36, $26, $36, $27, $36, $00, $35, $01, $35, $02, $35, $03, $35
	db $04, $35, $05, $35, $06, $35, $07, $35, $08, $35, $09, $35, $0a, $35, $0b, $35
	db $0c, $35, $0d, $35, $0e, $35, $0f, $35, $10, $35, $11, $35, $12, $35, $13, $35
	db $14, $35, $15, $35, $16, $35, $17, $35, $18, $35, $19, $35, $1a, $35, $1b, $35
	db $1c, $35, $1d, $35, $1e, $35, $1f, $35, $20, $35, $21, $35, $22, $35, $23, $35
	db $24, $35, $25, $35, $26, $35, $27, $35, $00, $34, $01, $34, $02, $34, $03, $34
	db $04, $34, $05, $34, $06, $34, $07, $34, $08, $34, $09, $34, $0a, $34, $0b, $34
	db $0c, $34, $0d, $34, $0e, $34, $0f, $34, $10, $34, $11, $34, $12, $34, $13, $34
	db $14, $34, $15, $34, $16, $34, $17, $34, $18, $34, $19, $34, $1a, $34, $1b, $34
	db $1c, $34, $1d, $34, $1e, $34, $1f, $34, $20, $34, $21, $34, $22, $34, $23, $34
	db $24, $34, $25, $34, $26, $34, $27, $34, $00, $33, $01, $33, $02, $33, $03, $33
	db $04, $33, $05, $33, $06, $33, $07, $33, $08, $33, $09, $33, $0a, $33, $0b, $33
	db $0c, $33, $0d, $33, $0e, $33, $0f, $33, $10, $33, $11, $33, $12, $33, $13, $33
	db $14, $33, $15, $33, $16, $33, $17, $33, $18, $33, $19, $33, $1a, $33, $1b, $33
	db $1c, $33, $1d, $33, $1e, $33, $1f, $33, $20, $33, $21, $33, $22, $33, $23, $33
	db $24, $33, $25, $33, $26, $33, $27, $33, $00, $32, $01, $32, $02, $32, $03, $32
	db $04, $32, $05, $32, $06, $32, $07, $32, $08, $32, $09, $32, $0a, $32, $0b, $32
	db $0c, $32, $0d, $32, $0e, $32, $0f, $32, $10, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32, $0f, $32
	db $0f, $32, $00, $00, $00, $00, $a0, $00, $00, $00, $40, $01, $00, $00, $e0, $01
	db $00, $00, $00, $00, $80, $00, $a0, $00, $80, $00, $40, $01, $80, $00, $e0, $01
	db $80, $00, $00, $00, $00, $01, $a0, $00, $00, $01, $40, $01, $00, $01, $e0, $01
	db $00, $01, $00, $00, $80, $01, $a0, $00, $80, $01, $40, $01, $80, $01, $e0, $01
	db $80, $01, $00, $00, $0a, $00, $14, $00, $1e, $00, $00, $08, $0a, $08, $14, $08
	db $1e, $08, $00, $10, $0a, $10, $14, $10, $1e, $10, $00, $18, $0a, $18, $14, $18
	db $1e, $18, $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5
	db $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
	db $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba
	db $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $c2
	db $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2
	db $d3, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Jump_000_2edd:
	push af
	push bc
	push de
	push hl
	ld hl, far_Call_03_4013
	rst $10
	pop hl
	pop de
	pop bc
	pop af
	reti


Jump_000_2eea:
	push af
	push bc
	push de
	push hl
	ld a, [$c892]
	rst $00

JumpTable_2EF2::
	dw Jump_2F40
	dw Jump_2EFA
	dw Jump_2F08
	dw Jump_2F24

Jump_2EFA::
	ldh a, [rSTAT]
	and $03
	jr nz, Jump_2EFA

	ldh a, [rLCDC]
	res 1, a
	ldh [rLCDC], a
	jr Jump_2F40

Jump_2F08::
	ldh a, [rLY]
	ld l, a
	ld h, $c1
	ld a, [hl]
	ldh [rSCX], a
	ldh a, [rLYC]
	add $02
	ldh [rLYC], a
	cp $80
	jr c, Jump_2F40

	ldh a, [$ffb7]
	ldh [rSCX], a
	ld a, $01
	ldh [rLYC], a
	jr Jump_2F40

Jump_2F24::
	ldh a, [rLY]
	ld l, a
	ld h, $c1
	ld a, [hl]
	ldh [rSCY], a
	ldh a, [rLYC]
	add $02
	ldh [rLYC], a
	cp $81
	jr c, Jump_2F40

	ldh a, [$ffbb]
	ldh [rSCY], a
	ld a, $00
	ldh [rLYC], a
	jr Jump_2F40

Jump_2F40::
	pop hl
	pop de
	pop bc
	pop af
	reti


Call_2F45::
	ld a, h
	cp b
	ret nz

	ld a, l
	cp c
	ret


Call_2F4B::
	ld de, $0000
	ld a, b
	or a
	jr z, jr_000_2f5d

jr_000_2f52:
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr c, jr_000_2f66

	inc de
	jr jr_000_2f52

jr_000_2f5d:
	ld a, c
	call Call_1E0D
	ld c, a
	ld b, $00
	jr jr_000_2f6b

jr_000_2f66:
	add hl, bc
	ld b, h
	ld c, l
	ld h, d
	ld l, e

jr_000_2f6b:
	ret


Call_2F6C::
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


Call_2F76::
	push hl
	push bc
	ld c, a
	call Call_2FA5
	jr c, jr_000_2fa1

	ld a, c
	ld hl, $db02
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	and $d0
	jr nz, jr_000_2fa0

	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, jr_000_2fa0

	inc hl
	ld a, [hl]
	and $c0
	jr nz, jr_000_2fa0

	xor a
	jr jr_000_2fa1

jr_000_2fa0:
	scf

jr_000_2fa1:
	ld a, c
	pop bc
	pop hl
	ret


Call_2FA5::
	push hl
	push bc
	ld c, a
	cp $08
	jr nc, jr_000_2fc0

	ld hl, $dd1b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and a
	jr z, jr_000_2fc4

	cp $ff
	jr z, jr_000_2fc0

	scf
	jr jr_000_2fc8

jr_000_2fc0:
	xor a
	scf
	jr jr_000_2fc8

jr_000_2fc4:
	ld a, $0a
	cp $01

jr_000_2fc8:
	ld a, c
	pop bc
	pop hl
	ret


Call_2FCC::
	ld hl, $dbe3
	call Call_2FF6
	ret


Call_2FD3::
	ld hl, $dbf3
	call Call_2FF6
	ret


Call_2FDA::
	ld hl, $dbb3
	call Call_2FF6
	ret


Call_2FE1::
	ld hl, $dbd3
	call Call_2FF6
	ret


Call_2FE8::
	ld hl, $dba3
	call Call_2FF6
	ret


Call_2FEF::
	ld hl, $dbc3
	call Call_2FF6
	ret


Call_2FF6::
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


Call_3001::
	ld a, [$da80]
	or a
	ret z

	ld a, [$c863]
	and $02
	sla a
	ld b, a
	ld a, [$db88]
	xor b
	cp $04
	jr nc, jr_000_3029

	ld a, [$db89]
	xor b
	cp $04
	jr nc, jr_000_3029

	ld a, $00
	ld [$dd60], a
	ld a, $00
	ld [$dd62], a
	ret


jr_000_3029:
	ld hl, far_Call_5F_5630
	rst $10
	ld a, [$da81]
	cp $ff
	ret z

	cp $0e
	jr c, jr_000_3048

	cp $15
	jr z, jr_000_3052

	cp $21
	jr c, jr_000_304d

	cp $2c
	jr z, jr_000_3059

	ld hl, far_Call_5E_4005
	rst $10
	ret


jr_000_3048:
	ld hl, far_Call_5C_4005
	rst $10
	ret


jr_000_304d:
	ld hl, far_Call_5D_4005
	rst $10
	ret


jr_000_3052:
	ld a, [$db8a]
	cp $c5
	jr nz, jr_000_304d

jr_000_3059:
	ld a, [$db75]
	cp $01
	jr z, jr_000_30b4

	cp $02
	jr z, jr_000_30ce

	ld a, [$dd1f]
	or a
	jr nz, jr_000_307f

	ld a, $20
	ldh [$ffc3], a
	ld a, [$da81]
	cp $15
	jr nz, jr_000_307b

	ld hl, far_Call_5D_4005
	rst $10
	jr jr_000_307f

jr_000_307b:
	ld hl, far_Call_5E_4005
	rst $10

jr_000_307f:
	ld a, [$dd20]
	or a
	jr nz, jr_000_309a

	ld a, $50
	ldh [$ffc3], a
	ld a, [$da81]
	cp $15
	jr nz, jr_000_3096

	ld hl, far_Call_5D_4005
	rst $10
	jr jr_000_309a

jr_000_3096:
	ld hl, far_Call_5E_4005
	rst $10

jr_000_309a:
	ld a, [$dd21]
	or a
	ret nz

	ld a, $80
	ldh [$ffc3], a
	ld a, [$da81]
	cp $15
	jr nz, jr_000_30af

	ld hl, far_Call_5D_4005
	rst $10
	ret


jr_000_30af:
	ld hl, far_Call_5E_4005
	rst $10
	ret


jr_000_30b4:
	ld a, [$dd1f]
	or a
	ret nz

	ld a, $50
	ldh [$ffc3], a
	ld a, [$da81]
	cp $15
	jr nz, jr_000_30c9

	ld hl, far_Call_5D_4005
	rst $10
	ret


jr_000_30c9:
	ld hl, far_Call_5E_4005
	rst $10
	ret


jr_000_30ce:
	ld a, [$dd1f]
	or a
	jr nz, jr_000_30e9

	ld a, $38
	ldh [$ffc3], a
	ld a, [$da81]
	cp $15
	jr nz, jr_000_30e5

	ld hl, far_Call_5D_4005
	rst $10
	jr jr_000_30e9

jr_000_30e5:
	ld hl, far_Call_5E_4005
	rst $10

jr_000_30e9:
	ld a, [$dd20]
	or a
	ret nz

	ld a, $68
	ldh [$ffc3], a
	ld a, [$da81]
	cp $15
	jr nz, jr_000_30fe

	ld hl, far_Call_5D_4005
	rst $10
	ret


jr_000_30fe:
	ld hl, far_Call_5E_4005
	rst $10
	ret


	db $21, $07, $5f, $d7, $fa, $81, $da, $fe, $ff, $c8, $21, $9b, $c8, $23, $3e, $d0
	db $22, $3e, $e0, $77, $21, $41, $31, $fa, $81, $da, $85, $6f, $3e, $00, $8c, $67
	db $7e, $ea, $9c, $c8, $fa, $81, $da, $fe, $0e, $38, $09, $fe, $21, $38, $0a, $21
	db $01, $5e, $d7, $c9, $21, $01, $5c, $d7, $c9, $21, $01, $5d, $d7, $c9, $e0, $e0
	db $e0, $e0, $e0, $e0, $d0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $d0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d0, $00, $01, $12, $35, $8a
	db $cd, $ee, $ff, $ff, $fe, $ed, $ca, $85, $32, $11, $00, $01, $23, $45, $67, $89
	db $ab, $cd, $ef, $fe, $dc, $ba, $98, $76, $54, $32, $10, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ee, $dd, $cc, $bb
	db $aa, $99, $88, $77, $66, $55, $44, $33, $22, $11, $00, $ff, $ff, $de, $bd, $24
	db $12, $00, $00, $00, $00, $21, $42, $db, $ed, $ff, $ff, $ff, $ff, $ee, $ca, $53
	db $11, $00, $00, $00, $00, $11, $35, $ac, $ee, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $00, $00, $66, $aa, $bb
	db $dd, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ee, $ed, $dd
	db $cc, $cb, $ba, $a9, $98, $87, $65, $54, $43, $31, $10, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $aa, $bb, $cc, $dd, $ee, $ff, $ff, $00, $00, $00, $00, $aa
	db $aa, $bb, $cc, $dd, $dd, $ff, $ff, $ff, $ff, $00, $ff, $00, $00, $00, $00, $aa
	db $aa, $bb, $cc, $dd, $dd, $ff, $ff, $ff, $ff, $aa, $ff, $01, $12, $22, $33, $35
	db $55, $77, $99, $55, $99, $aa, $bb, $cc, $dd, $ee, $ff, $fc, $dc, $ba, $90, $70
	db $50, $30, $15, $15, $15, $15, $22, $55, $77, $aa, $cc, $ee, $ee, $cd, $ac, $35
	db $23, $11, $11, $11, $11, $32, $53, $ca, $dc, $ee, $ee, $dd, $dd, $dd, $dd, $dd
	db $dd, $dd, $dd, $22, $22, $22, $22, $22, $22, $22, $22, $70, $32, $f1, $d0, $b0
	db $90, $70, $50, $30, $15, $15, $15, $15, $15, $15, $15, $15, $15, $f3, $d0, $b0
	db $90, $70, $50, $30, $10, $51, $40, $30, $20, $15, $15, $15, $15, $89, $98, $a8
	db $b8, $c8, $d8, $e8, $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5, $b9, $c8, $d8
	db $e8, $f1, $d0, $b0, $90, $70, $50, $30, $15, $15, $15, $15, $15, $99, $a8, $b8
	db $c8, $d8, $e8, $f4, $f4, $f0, $e0, $d0, $b0, $90, $70, $50, $35, $db, $f3, $d0
	db $b0, $90, $81, $70, $60, $50, $40, $30, $20, $15, $15, $15, $15, $f1, $e0, $d0
	db $c0, $b0, $a0, $90, $80, $70, $60, $50, $40, $30, $20, $10, $05, $f1, $70, $50
	db $30, $20, $15, $15, $15, $15, $05, $05, $05, $05, $05, $05, $05, $f1, $b0, $70
	db $50, $30, $20, $20, $15, $15, $15, $15, $15, $15, $15, $15, $05, $f1, $b0, $70
	db $50, $30, $10, $51, $40, $30, $20, $15, $15, $15, $15, $15, $05, $f3, $d0, $b0
	db $90, $70, $50, $30, $10, $51, $40, $30, $20, $15, $15, $15, $05, $09, $18, $28
	db $38, $48, $58, $68, $78, $88, $98, $a8, $b8, $c8, $d8, $e8, $f5, $c9

Call_3331::
	ld bc, $0000
	call Call_336D
	ld a, $80
	ldh [rNR52], a
	xor a
	ldh [rNR51], a
	ld [$de1d], a
	ld a, $77
	ldh [rNR50], a
	ld hl, $dd80
	ld b, $06
	ld a, $ff

jr_000_334c:
	ld [hl], a
	ld de, $0019
	add hl, de
	ld [hl], a
	ld de, $0001
	add hl, de
	dec b
	jr nz, jr_000_334c

	xor a
	ld [$de29], a
	ret


	db $af, $ea, $29, $de, $c9, $3e, $04, $ea, $29, $de, $af, $ea, $1d, $de, $c9

Call_336D::
	ld a, b
	ld [$de26], a
	ld a, c
	ld [$de27], a
	xor a
	ld [$de28], a
	ret


Call_337A::
	ld a, [$de23]
	inc a
	ld b, a
	ld a, $01

jr_000_3381:
	dec b
	jr z, jr_000_3387

	add a
	jr jr_000_3381

jr_000_3387:
	ld b, a
	ld a, [$de28]
	or b
	ld [$de28], a
	ret


Call_3390::
	ld a, [$de28]
	ld hl, $de26
	and [hl]
	cp [hl]
	jr nz, jr_000_33c4

	ld hl, $dd84
	ld a, [$de27]
	and $0f
	ld b, a
	ld a, [$de26]

jr_000_33a6:
	srl a
	ld [$de28], a
	jr nc, jr_000_33b2

	ld a, [hl]
	and $f0
	or b
	ld [hl], a

jr_000_33b2:
	ld a, l
	add $1a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [$de28]
	and a
	jr nz, jr_000_33a6

	xor a
	ld [$de26], a

jr_000_33c4:
	xor a
	ld [$de28], a
	ret


Call_33C9::
	call Call_33D2

Call_33CC::
	call Call_33D2

Call_33CF::
	call Call_33D2

Call_33D2::
	push bc
	push de
	push hl
	ld a, [$de24]
	ld hl, $3466

jr_000_33db:
	cp [hl]
	jr c, jr_000_33e4

	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_000_33db

jr_000_33e4:
	ld a, [$4000]
	push af
	dec hl
	ld a, [hld]
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld a, [hld]
	ld d, a
	ld a, [hld]
	ld e, a
	ld a, [$de24]
	sub [hl]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, de
	push hl
	pop de
	ld a, [de]
	inc de
	ld c, a
	ld b, $00
	ld hl, $dd80
	add hl, bc
	ld a, [hl]
	cp $ff
	jr z, jr_000_3430

	inc hl
	ld a, [hld]
	ld b, $ee
	and $03
	jr z, jr_000_3429

	ld b, $dd
	cp $01
	jr z, jr_000_3429

	ld b, $bb
	cp $02
	jr z, jr_000_3429

	ld b, $77

jr_000_3429:
	ld a, [$de1d]
	and b
	ld [$de1d], a

jr_000_3430:
	xor a
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [$4000]
	ld [hl], a
	push hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, $ff
	ld [hl], a
	pop hl
	ld de, $0015
	add hl, de
	xor a
	ld [hl], a
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ld a, [$de24]
	inc a
	ld [$de24], a
	pop hl
	pop de
	pop bc
	ret


	db $00, $01, $40, $1c, $21, $01, $40, $1d, $37, $01, $40, $1e, $ff

Call_3473::
	ld a, [$4000]
	push af
	ld a, [$de29]
	ld [$de23], a
	xor a
	ld [$de1c], a
	ld hl, $de22
	inc [hl]
	ld hl, $dd80

Jump_000_3488:
	push hl
	ld de, $ffe4
	ld b, $03

jr_000_348e:
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, jr_000_348e

	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	ldh a, [$ffe5]
	and $03
	ld [$de1e], a
	ld b, a
	add a
	add a
	add b
	ld [$de21], a
	inc b
	ld a, $88

jr_000_34bf:
	rlca
	dec b
	jr nz, jr_000_34bf

	ld [$de1f], a
	ld [$de20], a
	ldh a, [$ffe4]
	ld b, a
	ldh a, [$fffd]
	and b
	cp $ff
	jp z, Jump_000_3559

	ldh a, [$ffe8]
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	ldh a, [$fffd]
	or b
	and a
	jp z, Jump_000_357f

	call Call_3905
	call Call_3974
	ldh a, [$fff1]
	ld b, a
	ldh a, [$fff2]
	inc a
	cp b
	jr c, jr_000_34f8

	ld a, b

jr_000_34f8:
	ldh [$fff2], a
	ld hl, $ffea
	ldh a, [$ffe9]
	and $0f
	add [hl]
	cp $10
	jr c, jr_000_350b

	sub $10
	ld [hl], a
	jr jr_000_3527

jr_000_350b:
	ld [hl], a
	call Call_38C6
	ldh a, [$fffb]
	and a
	jr z, jr_000_3517

	dec a
	ldh [$fffb], a

jr_000_3517:
	ld hl, $ffec
	dec [hl]
	jr nz, jr_000_3527

	call Call_337A

Jump_000_3520:
	ldh a, [$fffa]
	ldh [$fffb], a
	call Call_35EA

jr_000_3527:
	ld a, [$de1f]
	ld b, a
	ld a, [$de1c]
	or b
	ld [$de1c], a
	pop hl
	push hl
	ld de, $ffe4
	ld b, $03

jr_000_3539:
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a
	inc e
	dec b
	jr nz, jr_000_3539

	ld a, [de]
	ld [hli], a
	inc e
	ld a, [de]
	ld [hli], a

Jump_000_3559:
	pop hl
	ld de, $001a
	add hl, de
	ld a, [$de23]
	inc a
	ld [$de23], a
	cp $06
	jp c, Jump_000_3488

	ld a, [$de1d]
	ldh [rNR51], a
	pop af
	ld [$2100], a
	swap a
	rra
	and $03
	ld [$4100], a
	call Call_3390
	ret


Jump_000_357f:
	ldh a, [$ffe6]
	ld l, a
	ldh a, [$ffe7]
	ld h, a
	xor a
	ldh [$ffea], a
	ld a, [hli]
	and $0f
	ld d, a
	ld a, [$de1e]
	cp $02
	jr z, jr_000_35bf

	ld a, [hli]
	rrca
	rrca
	and $c0
	or d

jr_000_3599:
	ldh [$ffe9], a
	ld a, [hli]
	swap a
	ldh [$ffeb], a
	ld a, [$de1e]
	cp $02
	jr z, jr_000_35c5

	ld a, [hli]
	ldh [$ffed], a

jr_000_35aa:
	xor a
	ldh [$ffee], a
	ldh [$ffef], a
	ldh [$fff0], a
	ldh [$fff3], a
	ldh [$fffd], a
	dec a
	ldh [$fff9], a
	ld a, $02
	ldh [$ffe4], a
	jp Jump_000_3520


jr_000_35bf:
	ld a, [hli]
	ldh [$fff1], a
	ld a, d
	jr jr_000_3599

jr_000_35c5:
	xor a
	ldh [rNR30], a
	ld d, a
	ldh a, [$ffed]
	ld e, a
	cp $ff
	jr nz, jr_000_35d4

	ld e, [hl]
	ld a, e
	ldh [$ffed], a

jr_000_35d4:
	ld [$de2b], a
	swap e
	ld hl, $316e
	add hl, de
	ld de, $ff30
	ld b, $10

jr_000_35e2:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_35e2

	jr jr_000_35aa

Call_35EA::
	ldh a, [$ffe4]
	ld l, a
	ldh a, [$fffd]
	ld h, a
	add hl, hl
	ldh a, [$ffe6]
	ld e, a
	ldh a, [$ffe7]
	ld d, a
	add hl, de

Jump_000_35f8:
jr_000_35f8:
	ldh a, [$ffe4]
	add $01
	ldh [$ffe4], a
	ldh a, [$fffd]
	adc $00
	ldh [$fffd], a
	ld a, [hli]
	cp $d0
	jr nc, jr_000_3630

	cp $b0
	jr nc, jr_000_366e

	cp $a0
	jp nc, Jump_000_36cb

	jp Jump_000_37ee


jr_000_3615:
	cp $fd
	jr nz, jr_000_3624

	ldh a, [$ffe4]
	ldh [$fff8], a
	ldh a, [$fffd]
	ldh [$fffe], a

jr_000_3621:
	inc hl
	jr jr_000_35f8

jr_000_3624:
	cp $ff
	jr nz, jr_000_3621

	ldh [$ffe4], a
	ldh [$fffd], a
	call Call_3A38
	ret


jr_000_3630:
	cp $f0
	jr nc, jr_000_3615

	cp $e0
	jr nc, jr_000_363c

	and $0f
	jr jr_000_3640

jr_000_363c:
	and $0f
	cpl
	inc a

jr_000_3640:
	ld b, a
	ld a, [$de1e]
	cp $02
	jr z, jr_000_3650

	ld a, b
	ldh [$fff3], a
	ld a, [hl]
	ldh [$fff4], a
	ldh [$fff5], a

jr_000_3650:
	inc hl
	jr jr_000_35f8

jr_000_3653:
	and $0f
	ld b, a
	ld a, [$de1e]
	cp $02
	jr z, jr_000_366b

	ldh a, [$ffeb]
	and $0f
	jr nz, jr_000_366b

	ld a, [hl]
	ldh [$fff1], a
	ld a, b
	swap a
	ldh [$fff0], a

jr_000_366b:
	inc hl
	jr jr_000_35f8

jr_000_366e:
	cp $c0
	jr nc, jr_000_3653

	and $0f
	jr z, jr_000_3699

	ld e, a
	ld a, [hl]
	and a
	jr nz, jr_000_368b

	ldh a, [$ffee]
	dec a
	ldh [$ffee], a
	jr z, jr_000_36b0

	bit 7, a
	jr z, jr_000_3699

	ld a, e
	ldh [$ffee], a
	jr jr_000_3699

jr_000_368b:
	ldh a, [$ffef]
	dec a
	ldh [$ffef], a
	jr z, jr_000_36c2

	bit 7, a
	jr z, jr_000_3699

	ld a, e
	ldh [$ffef], a

jr_000_3699:
	ld a, [hl]
	cp $fc
	jr z, jr_000_36a9

	ldh a, [$fff8]
	ldh [$ffe4], a
	ldh a, [$fffe]
	ldh [$fffd], a
	jp Call_35EA


jr_000_36a9:
	inc hl
	ld a, [hli]
	ldh [$ffe4], a
	ld a, [hl]
	ldh [$fffd], a

jr_000_36b0:
	jp Call_35EA


	db $f0, $e4, $c6, $01, $e0, $e4, $f0, $fd, $ce, $00, $e0, $fd, $c3, $ea, $35

jr_000_36c2:
	ldh a, [$ffe4]
	add $01
	ldh [$ffe4], a
	jp Call_35EA


Jump_000_36cb:
	cp $a0
	jr nz, jr_000_36e5

	ld a, [hli]
	swap a
	ldh [$ffeb], a
	ld a, [$de1f]
	ld b, a
	ld a, [$de1c]
	and b
	jp nz, Jump_000_35f8

	call Call_393C
	jp Jump_000_35f8


jr_000_36e5:
	cp $a1
	jr nz, jr_000_3725

	ld a, [$de1e]
	cp $02
	jr z, jr_000_36f6

	ld a, [hli]
	ldh [$ffed], a
	jp Jump_000_35f8


jr_000_36f6:
	xor a
	ldh [rNR30], a
	ld d, a
	ld a, [hli]
	ld e, a
	ldh [$ffed], a
	ld a, [$de1f]
	ld b, a
	ld a, [$de1c]
	and b
	jr z, jr_000_370b

	jp Jump_000_35f8


jr_000_370b:
	push hl
	ld a, e
	ld [$de2b], a
	swap e
	ld hl, $316e
	add hl, de
	ld de, $ff30
	ld b, $10

jr_000_371b:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_371b

	pop hl
	jp Jump_000_35f8


jr_000_3725:
	cp $a2
	jr nz, jr_000_3746

	ld a, [$de1e]
	cp $02
	jr z, jr_000_3740

	ld a, [hli]
	rrca
	rrca
	and $c0
	ld d, a
	ldh a, [$ffe9]
	and $3f
	or d
	ldh [$ffe9], a
	jp Jump_000_35f8


jr_000_3740:
	ld a, [hli]
	ldh [$fff1], a
	jp Jump_000_35f8


jr_000_3746:
	cp $a3
	jr nz, jr_000_376d

	ld a, [hli]
	bit 7, a
	jr nz, jr_000_3767

	ld b, a
	and $0f
	add a
	ldh [$fffa], a
	ldh [$fffb], a
	ld a, b
	and $70
	ld e, a
	ldh a, [$ffe5]
	and $0f
	or e
	or $80

jr_000_3762:
	ldh [$ffe5], a
	jp Jump_000_35f8


jr_000_3767:
	ldh a, [$ffe5]
	and $0f
	jr jr_000_3762

jr_000_376d:
	cp $a5
	jr nz, jr_000_377f

	ld a, [hli]
	cp $01
	jr nz, jr_000_377a

	ldh a, [$fff9]
	swap a

jr_000_377a:
	ldh [$fff9], a
	jp Jump_000_35f8


jr_000_377f:
	cp $a6
	jr nz, jr_000_3789

	ld a, [hli]
	ldh [rNR50], a
	jp Jump_000_35f8


jr_000_3789:
	cp $a7
	jr nz, jr_000_3793

	ld a, [hl]
	ldh [$ffec], a
	jp Jump_000_38a5


jr_000_3793:
	cp $a8
	jr nz, jr_000_379d

	ld a, [hli]
	ldh [$fffc], a
	jp Jump_000_35f8


jr_000_379d:
	cp $ae
	jr nz, jr_000_37af

	ld a, [hli]
	and $10
	ld b, a
	ldh a, [$ffe9]
	and $ef
	or b
	ldh [$ffe9], a
	jp Jump_000_35f8


jr_000_37af:
	cp $af
	jr nz, jr_000_37c1

	ld a, [hli]
	and $0f
	ld b, a
	ldh a, [$ffe9]
	and $f0
	or b
	ldh [$ffe9], a
	jp Jump_000_35f8


jr_000_37c1:
	inc hl
	jp Jump_000_35f8


	db $00, $01, $11, $12, $14, $23, $07, $15, $17, $32, $33, $60, $61, $45, $53, $62

jr_000_37d5:
	xor a
	ldh [$fff6], a
	ld a, $80
	ldh [$fff7], a
	ld a, [$de1e]
	cp $02
	jr z, jr_000_37e7

	call Call_3A30
	ret


jr_000_37e7:
	call Call_3A48
	xor a
	ldh [rNR30], a
	ret


Jump_000_37ee:
	ld b, a
	ld a, [hl]
	ldh [$ffec], a
	ld a, [$de1e]
	cp $03
	jr nz, jr_000_3815

	ld a, b
	cp $1f
	jr z, jr_000_37d5

	cp $10
	jr nc, jr_000_3810

	ld hl, $37c5
	add l
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld l, [hl]
	ld h, $00
	jr jr_000_3848

jr_000_3810:
	ld l, a
	ld h, $00
	jr jr_000_3848

jr_000_3815:
	ld a, b
	and $0f
	cp $0c
	jr nc, jr_000_37d5

	add a
	ld e, a
	ldh a, [$ffe9]
	and $10
	jr z, jr_000_3828

	ld a, e
	add $18
	ld e, a

jr_000_3828:
	ld d, $00
	ld hl, $3a53
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, b
	swap a
	and $0f
	jr z, jr_000_3840

	ld b, a

jr_000_3839:
	srl h
	rr l
	dec b
	jr nz, jr_000_3839

jr_000_3840:
	ld a, $00
	sub l
	ld l, a
	ld a, $08
	sbc h
	ld h, a

jr_000_3848:
	xor a
	ldh [$fff2], a
	call Call_3A48
	ld a, [$de1e]
	cp $02
	jr nz, jr_000_385c

	call Call_3C03
	ld a, $80
	ldh [rNR30], a

jr_000_385c:
	push hl
	call Call_392E
	pop hl
	ld a, [$de1e]
	and a
	ldh a, [$ffed]
	ld c, $10
	call z, Call_3954
	ld a, l
	ld c, $13
	call Call_3954
	ld a, l
	cp $02
	jr c, jr_000_387f

	cp $fe
	jr c, jr_000_3881

	ld a, $fd
	jr jr_000_3881

jr_000_387f:
	ld a, $02

jr_000_3881:
	ldh [$fff6], a
	ld a, [$de1e]
	cp $02
	jr z, jr_000_38b8

	cp $02
	jr nc, jr_000_3899

	ldh a, [$ffe9]
	and $c0
	or $3f
	ld c, $11
	call Call_3954

jr_000_3899:
	ld a, h
	and $07
	or $80

jr_000_389e:
	ldh [$fff7], a
	ld c, $14
	call Call_3954

Jump_000_38a5:
	ld a, [$de20]
	ld b, a
	cpl
	ld c, a
	ldh a, [$fff9]
	and b
	ld b, a
	ld a, [$de1d]
	and c
	or b
	ld [$de1d], a
	ret


jr_000_38b8:
	xor a
	ldh [rNR31], a
	ldh a, [rNR52]
	and $04
	jr z, jr_000_3899

	ld a, h
	and $07
	jr jr_000_389e

Call_38C6::
	ld a, [$de1e]
	cp $02
	ret z

	ldh a, [$fff3]
	and a
	ret z

	ld hl, $fff5
	dec [hl]
	ret nz

	ldh a, [$ffeb]
	swap a
	cp $10
	ret nc

	and $0f
	ld b, a
	ldh a, [$fff4]
	ldh [$fff5], a
	ld hl, $fff3
	ld a, [hl]
	bit 7, a
	jr nz, jr_000_38f9

	dec [hl]
	ld a, b
	cp $0f
	ret z

	ldh a, [$ffeb]
	add $10
	ldh [$ffeb], a
	jp Call_393C


jr_000_38f9:
	inc [hl]
	ld a, b
	and a
	ret z

	ldh a, [$ffeb]
	sub $10
	ldh [$ffeb], a
	jr Call_393C

Call_3905::
	call Call_3A48
	ld a, [$de1e]
	cp $03
	ret z

	ldh a, [$fffb]
	and a
	ret nz

	ldh a, [$ffe5]
	bit 7, a
	ret z

	and $70
	ld b, a
	ld a, [$de22]
	and $0f
	or b
	ld e, a
	ld d, $00
	ld hl, $3b83
	add hl, de
	ldh a, [$fff6]
	add [hl]
	ld c, $13
	jr Call_3954

Call_392E::
	ld a, [$de1e]
	cp $02
	jr z, jr_000_395d

	ldh a, [$fff0]
	and a
	jr nz, jr_000_398e

	ldh a, [$ffeb]

Call_393C::
	ld b, a
	and $07
	jr nz, jr_000_3945

	ld a, b
	or $08
	ld b, a

jr_000_3945:
	ld a, [$de21]
	add $12
	ld c, a
	ldh a, [c]
	cp b
	ret z

	ld a, b
	ldh [c], a
	ldh a, [$fff7]
	ld c, $14

Call_3954::
	ld b, a
	ld a, [$de21]
	add c
	ld c, a
	ld a, b
	ldh [c], a
	ret


jr_000_395d:
	ldh a, [$ffeb]
	ld c, $12
	jr Call_3954

jr_000_3963:
	ld a, e
	srl a
	add $02
	swap a
	ld hl, $ffeb
	cp [hl]
	ret c

	and $60
	ldh [rNR32], a
	ret


Call_3974::
	call Call_3A48
	ldh a, [$fff6]
	and a
	jr nz, jr_000_3983

	ldh a, [$fff7]
	and $7f
	jp z, Call_3A30

jr_000_3983:
	ld a, [$de1e]
	cp $02
	jr z, jr_000_398e

	ldh a, [$fff0]
	and a
	ret z

jr_000_398e:
	ldh a, [$fff1]
	and a
	ret z

	ld e, $00
	ld c, a
	ldh a, [$fff2]
	ld b, $04

jr_000_3999:
	add a
	cp c
	jr c, jr_000_399e

	sub c

jr_000_399e:
	ccf
	rl e
	dec b
	jr nz, jr_000_3999

	ld a, [$de1e]
	cp $02
	jr z, jr_000_3963

	ldh a, [$fff0]
	or e
	ld e, a
	ld d, $00
	push de
	ldh a, [$fffc]
	ld de, $326e
	sla a
	add e
	ld e, a
	xor a
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	pop de
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	add hl, de
	ldh a, [$ffeb]
	swap a
	ld e, a
	ld a, [hl]
	ld h, a
	and $f0
	or e
	ld e, a
	bit 2, h
	jr nz, jr_000_39fc

	inc b
	ld a, c
	swap a
	and $0f
	jr z, jr_000_39fc

	ld b, a
	bit 3, e
	jr nz, jr_000_39f5

	sla b
	bit 2, e
	jr nz, jr_000_39f5

	sla b
	bit 1, e
	jr z, jr_000_39fa

jr_000_39f5:
	ld a, b
	cp $08
	jr c, jr_000_39fc

jr_000_39fa:
	ld b, $00

jr_000_39fc:
	bit 1, h
	jr z, jr_000_3a05

	ld a, b
	jr z, jr_000_3a05

	srl b

jr_000_3a05:
	ld a, h
	and $08
	or b
	ld b, a
	bit 0, h
	jr z, jr_000_3a17

	ld hl, $3a83
	add hl, de
	ld a, [hl]
	or b
	jp Call_393C


jr_000_3a17:
	ld c, $12
	ld a, [$de21]
	add c
	ld c, a
	ldh a, [c]
	and $08
	ld l, a
	ld a, h
	and $08
	cp l
	ret z

	ld hl, $3a83
	add hl, de
	ld a, [hl]
	or b
	jp Call_393C


Call_3A30::
	call Call_3A48
	ld a, $00
	jp Call_393C


Call_3A38::
	call Call_3A48
	ld a, [$de1f]
	cpl
	ld b, a
	ld a, [$de1d]
	and b
	ld [$de1d], a
	ret


Call_3A48::
	ld a, [$de1f]
	ld b, a
	ld a, [$de1c]
	and b
	ret z

	pop af
	ret


	db $d4, $07, $64, $07, $f9, $06, $95, $06, $37, $06, $dd, $05, $89, $05, $3a, $05
	db $f0, $04, $a8, $04, $65, $04, $26, $04, $9c, $07, $2e, $07, $c7, $06, $66, $06
	db $0a, $06, $b3, $05, $61, $05, $15, $05, $cc, $04, $86, $04, $45, $04, $08, $04
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $10, $10, $10, $10, $10, $10, $10, $10
	db $00, $00, $00, $00, $10, $10, $10, $10, $10, $10, $10, $10, $20, $20, $20, $20
	db $00, $00, $00, $10, $10, $10, $10, $10, $20, $20, $20, $20, $20, $30, $30, $30
	db $00, $00, $10, $10, $10, $10, $20, $20, $20, $20, $30, $30, $30, $30, $40, $40
	db $00, $00, $10, $10, $10, $20, $20, $20, $30, $30, $30, $40, $40, $40, $50, $50
	db $00, $00, $10, $10, $20, $20, $20, $30, $30, $40, $40, $40, $50, $50, $60, $60
	db $00, $00, $10, $10, $20, $20, $30, $30, $40, $40, $50, $50, $60, $60, $70, $70
	db $00, $10, $10, $20, $20, $30, $30, $40, $40, $50, $50, $60, $60, $70, $70, $80
	db $00, $10, $10, $20, $20, $30, $40, $40, $50, $50, $60, $70, $70, $80, $80, $90
	db $00, $10, $10, $20, $30, $30, $40, $50, $50, $60, $70, $70, $80, $90, $90, $a0
	db $00, $10, $10, $20, $30, $40, $40, $50, $60, $70, $70, $80, $90, $a0, $a0, $b0
	db $00, $10, $20, $20, $30, $40, $50, $60, $60, $70, $80, $90, $a0, $a0, $b0, $c0
	db $00, $10, $20, $30, $30, $40, $50, $60, $70, $80, $90, $a0, $a0, $b0, $c0, $d0
	db $00, $10, $20, $30, $40, $50, $60, $70, $70, $80, $90, $a0, $b0, $c0, $d0, $e0
	db $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $a0, $b0, $c0, $d0, $e0, $f0
	db $00, $00, $01, $01, $00, $00, $ff, $ff, $00, $00, $01, $01, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $ff, $ff, $ff, $ff
	db $00, $01, $02, $01, $00, $ff, $fe, $ff, $00, $01, $02, $01, $00, $ff, $fe, $ff
	db $00, $00, $01, $01, $02, $02, $01, $01, $00, $00, $ff, $ff, $fe, $fe, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

Call_3C03::
	ld a, [$de2b]
	ld b, a
	ldh a, [$ffed]
	cp b
	ret z

	ld [$de2b], a
	ld e, a
	swap e
	xor a
	ldh [rNR30], a
	ld d, a
	ld hl, $316e
	add hl, de
	ld de, $ff30
	ld b, $10

jr_000_3c1e:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_3c1e

	ret


	db $fa, $ff, $cd, $3d, $fe, $f7, $30, $08, $7e, $f6, $7f, $2f, $77, $cb, $7e, $c9
	db $af, $77, $c9, $cd, $4b, $00, $43, $3c, $4a, $3c, $83, $3c, $c6, $3c, $cd, $ab
	db $3d, $c0, $c3, $e8, $3c, $16, $c1, $cd, $c1, $07, $21, $b0, $53, $cd, $57, $09
	db $fa, $c1, $c9, $fe, $03, $cc, $63, $3c, $cd, $f0, $3b, $c3, $e8, $3c, $21, $a1
	db $cd, $7e, $36, $01, $b7, $c8, $21, $b0, $53, $3e, $05, $c3, $5a, $09, $3e, $08
	db $ea, $c0, $c9, $3e, $04, $ea, $93, $c9, $ea, $a1, $cd, $c3, $ed, $3c, $cd, $7b
	db $3b, $ca, $e8, $3c, $fa, $c1, $c9, $fe, $02, $20, $11, $fa, $98, $cd, $fe, $04
	db $30, $dc, $fe, $03, $20, $06, $fa, $a1, $cd, $b7, $20, $d2, $cd, $ab, $3d, $21
	db $bc, $3c, $e5, $cd, $13, $3c, $7e, $e6, $80, $07, $47, $e1, $fa, $c1, $c9, $87
	db $80, $ef, $7e, $16, $cc, $e7, $c9, $50, $51, $50, $51, $50, $51, $50, $51, $50
	db $51, $fa, $c1, $c9, $c7, $d4, $3c, $d4, $3c, $d4, $3c, $da, $3c, $d4, $3c, $3e
	db $05, $ea, $c0, $c9, $c9, $cd, $ff, $12, $cd, $3c, $20, $af, $ea, $c0, $c9, $c9
	db $ea, $80, $cd, $21, $90, $cd, $34, $c9, $af, $ea, $90, $cd, $c9, $cd, $84, $12
	db $c3, $d0, $74, $cd, $84, $12, $c3, $3d, $5a, $65, $9c, $6b, $9c, $fa, $8b, $c9
	db $cb, $47, $c2, $ab, $1a, $fa, $c1, $c9, $3d, $c7, $37, $3d, $17, $3d, $4b, $3d
	db $17, $3d, $cd, $4b, $00, $43, $3c, $22, $3d, $28, $3d, $37, $3d, $21, $b1, $55
	db $c3, $52, $3c, $cd, $7b, $3b, $ca, $e8, $3c, $cd, $ab, $3d, $21, $bc, $3c, $c3
	db $a7, $3c, $16, $cc, $cd, $30, $07, $3e, $20, $cd, $10, $05, $21, $8b, $c9, $cb
	db $c6, $3e, $07, $c3, $9d, $1c, $cd, $84, $12, $c3, $57, $6a, $fa, $8b, $c9, $cb
	db $47, $c2, $ab, $1a, $cd, $96, $12, $cd, $4a, $35, $cd, $8a, $12, $cd, $98, $23
	db $cd, $c8, $6d, $cd, $f7, $71, $cd, $7b, $74, $cd, $84, $12, $cd, $7d, $3d, $cd
	db $0e, $42, $cd, $cd, $0b, $c3, $ba, $17, $16, $c0, $fa, $c1, $c9, $c7, $0c, $4c
	db $0c, $4c, $1a, $59, $c0, $6a, $2d, $7c, $fa, $c1, $c9, $c7, $9b, $3d, $9b, $3d
	db $29, $3e, $67, $3e, $7b, $3e, $cd, $84, $12, $cd, $4b, $00, $e5, $3d, $ec, $3d
	db $f2, $3d, $0b, $3e, $1c, $3e, $cd, $dc, $23, $16, $c0, $cd, $57, $05, $af, $ea
	db $99, $cd, $cd, $9e, $1a, $c5, $fa, $9a, $cd, $32, $fa, $99, $cd, $77, $cd, $b0
	db $17, $af, $ea, $9a, $cd, $c1, $cd, $97, $1a, $11, $08, $c0, $1a, $fe, $02, $c0
	db $21, $07, $c0, $cb, $ae, $fa, $14, $c0, $fe, $70, $38, $02, $cb, $ee, $af, $c9
	db $cd, $ab, $3d, $c0, $c3, $e8, $3c, $cd, $ab, $3d, $c3, $0e, $42, $cd, $7b, $3b
	db $ca, $e8, $3c, $cd, $ab, $3d, $21, $01, $3e, $c3, $a7, $3c, $50, $51, $50, $51
	db $50, $51, $50, $51, $6f, $67, $3e, $10, $ea, $9a, $cd, $cd, $b4, $3d, $fa, $0f
	db $c0, $fe, $34, $d0, $c3, $e8, $3c, $06, $8d, $cd, $43, $20, $01, $37, $05, $cd
	db $96, $11, $18, $34, $cd, $84, $12, $cd, $4b, $00, $e5, $3d, $f2, $3d, $53, $3e
	db $3e, $12, $ea, $9a, $cd, $cd, $b4, $3d, $fa, $01, $c0, $fe, $01, $c0, $16, $c0
	db $cd, $57, $05, $3e, $01, $ea, $9a, $cd, $cd, $b4, $3d, $c3, $e8, $3c, $06, $c9
	db $cd, $43, $20, $3e, $5b, $cd, $10, $05, $af, $ea, $c0, $c9, $21, $8b, $c9, $cb
	db $8e, $c9, $cd, $84, $12, $cd, $4b, $00, $e5, $3d, $f2, $3d, $73, $3e, $21, $0c
	db $1f, $cd, $42, $20, $18, $dd, $06, $03, $cd, $41, $2e, $20, $11, $cd, $84, $12
	db $cd, $0c, $7b, $cd, $4b, $00, $e5, $3d, $f2, $3d, $35, $3e, $58, $3e, $cd, $4b
	db $00, $e5, $3d, $b4, $3e, $cb, $3e, $e4, $3e, $66, $3f, $cb, $3e, $e4, $3e, $22
	db $3f, $2c, $3f, $33, $3f, $50, $3f, $22, $3f, $22, $3f, $66, $3f, $5a, $3f, $cd
	db $7b, $3b, $fa, $98, $cd, $fe, $03, $c0, $3c, $ea, $98, $cd, $af, $ea, $81, $cd
	db $01, $0b, $02, $c3, $77, $3f, $cd, $66, $3f, $c0, $af, $ea, $b7, $cc, $21, $d9
	db $3e, $c3, $1e, $09, $66, $9c, $37, $38, $39, $00, $00, $00, $23, $24, $ff, $cd
	db $85, $3f, $fa, $b7, $cc, $a7, $28, $11, $fa, $90, $cd, $fe, $03, $01, $0f, $04
	db $ca, $77, $3f, $01, $10, $07, $c3, $77, $3f, $21, $f5, $c9, $7e, $fe, $05, $38
	db $12, $21, $80, $cb, $36, $f4, $2c, $36, $01, $3e, $08, $ea, $90, $cd, $3e, $20
	db $c3, $a1, $0b, $01, $0e, $0c, $c3, $77, $3f, $66, $9c, $6b, $9c, $cd, $66, $3f
	db $c0, $01, $0c, $0d, $c3, $77, $3f, $cd, $9b, $0b, $c0, $c3, $e8, $3c, $21, $80
	db $cb, $7e, $d6, $01, $22, $7e, $de, $00, $77, $38, $08, $3e, $01, $01, $cb, $9f
	db $c3, $13, $0c, $3e, $20, $cd, $a1, $0b, $c3, $e8, $3c, $cd, $9b, $0b, $c0, $01
	db $0d, $0b, $c3, $77, $3f, $cd, $7b, $3b, $c0, $06, $ec, $cd, $43, $20, $c3, $5d
	db $3e, $cd, $3d, $09, $f5, $21, $01, $3e, $cd, $a7, $3c, $f1, $c0, $cd, $e8, $3c
	db $af, $c9, $78, $ea, $90, $cd, $79, $21, $ce, $55, $cd, $5a, $09, $c3, $98, $0b
	db $21, $1e, $3f, $cd, $41, $05, $3e, $0f, $c2, $15, $05, $cd, $90, $12, $cd, $f1
	db $68, $c1, $c9, $3e, $0a, $ea, $c0, $c9, $21, $8b, $c9, $cb, $ce, $c9, $3e, $06
	db $ea, $82, $cd, $d5, $21, $ce, $55, $cd, $57, $09, $d1, $c3, $f0, $3b, $cd, $e4
	db $16, $21, $e9, $76, $cd, $b6, $04, $7e, $e6, $0f, $ea, $8d, $ca, $2a, $cb, $37
	db $e6, $0f, $ea, $86, $ca, $06, $01, $fa, $94, $ca, $cb, $47, $28, $02, $06, $10
	db $5e, $23, $16, $d7, $2a, $fe, $ff, $c8, $fe, $fe, $28, $f4, $12, $78, $cd, $40
	db $16, $18, $f1, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
