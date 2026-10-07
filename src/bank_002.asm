INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

BankNumber_02::
	db $02

FarTable_02::
	dw Call_02_400D
	dw Call_02_4E9F
	dw Call_02_512C
	dw Call_02_5FD6
	dw $6a78
	dw Call_02_6B0A

Call_02_400D::
	ld a, [$d7b4]
	ld l, a
	ld a, [$d7b5]
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_002_401e

	call Call_02_4028
	jr jr_002_4027

jr_002_401e:
	inc [hl]
	inc hl
	inc hl
	inc hl
	ld [hl], $00
	call Call_02_404E

jr_002_4027:
	ret


Call_02_4028::
	ld a, [$d7b4]
	add $05
	ld l, a
	ld a, [$d7b5]
	adc $00
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	or a
	jr z, jr_002_4041

	dec a
	ld [hld], a
	ld a, [hl]
	cp $ff
	ret


Jump_002_4041:
jr_002_4041:
	ld a, [$d7b4]
	add $03
	ld l, a
	ld a, [$d7b5]
	adc $00
	ld h, a
	inc [hl]

Call_02_404E::
	call Call_02_40B3
	ld a, b
	and c
	cp $ff
	jr nz, jr_002_4062

	ld a, [$d7b4]
	ld l, a
	ld a, [$d7b5]
	ld h, a
	ld [hl], $00
	ret


jr_002_4062:
	ld a, c
	cp $ff
	jr nz, jr_002_4067

jr_002_4067:
	ld a, c
	cp $f8
	jr c, jr_002_4086

	cp $fe
	jr nz, jr_002_407c

	ld a, b
	rst $00

JumpTable_02_4072::
	dw Jump_02_4096
	dw Jump_02_409C
	dw Jump_02_409C
	dw Jump_02_409C
	dw Jump_02_409F

jr_002_407c:
	cp $fd
	jr nz, jr_002_4086

	ld a, b
	call Call_1B2C
	jr jr_002_4041

Jump_002_4086:
jr_002_4086:
	ld a, [$d7b4]
	add $04
	ld l, a
	ld a, [$d7b5]
	adc $00
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b

Jump_002_4095:
	ret


Jump_02_4096::
	ld bc, $ffff
	jp Jump_002_4086


Jump_02_409C::
	jp Jump_002_4041


Jump_02_409F::
	ld a, [$d7b4]
	add $03
	ld l, a
	ld a, [$d7b5]
	adc $00
	ld h, a
	ld a, $01
	ld [hli], a
	inc hl
	inc [hl]
	jp Jump_002_4095


Call_02_40B3::
	ld a, [$d7b4]
	ld c, a
	ld a, [$d7b5]
	ld b, a
	inc bc
	ld a, [bc]
	add a
	ld hl, $40e3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc bc
	ld a, [bc]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc bc
	ld a, [bc]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret


	db $a5, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $3d, $42, $a5, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $65, $42
	db $f1, $41, $f1, $41, $a9, $42, $cd, $42, $f1, $42, $15, $43, $33, $43, $57, $43
	db $7b, $43, $a7, $43, $cb, $43, $ed, $43, $11, $44, $35, $44, $59, $44, $7d, $44
	db $a1, $44, $c5, $44, $e9, $44, $0d, $45, $45, $45, $69, $45, $a7, $45, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41
	db $f1, $41, $f1, $41, $f1, $41, $f1, $41, $f1, $41, $cf, $45, $a5, $41, $a5, $41
	db $ef, $45, $ef, $45, $0f, $46, $ef, $45, $33, $46, $67, $46, $f1, $41, $ef, $45
	db $a5, $41, $a5, $41, $a5, $41, $a5, $41, $a5, $41, $a5, $41, $a5, $41, $ef, $45
	db $a1, $46, $bf, $41, $c5, $41, $cb, $41, $d1, $41, $d7, $41, $dd, $41, $e3, $41
	db $e7, $41, $eb, $41, $ef, $41, $ef, $41, $ef, $41, $ef, $41, $00, $20, $01, $20
	db $ff, $ff, $02, $20, $03, $20, $ff, $ff, $04, $20, $05, $20, $ff, $ff, $01, $0b
	db $00, $0b, $ff, $ff, $03, $0b, $02, $0b, $ff, $ff, $05, $0b, $04, $0b, $ff, $ff
	db $00, $ff, $ff, $ff, $02, $ff, $ff, $ff, $04, $ff, $ff, $ff, $ff, $ff, $0b, $42
	db $11, $42, $17, $42, $1d, $42, $23, $42, $29, $42, $2f, $42, $33, $42, $37, $42
	db $3b, $42, $3b, $42, $3b, $42, $3b, $42, $01, $20, $00, $20, $ff, $ff, $03, $20
	db $02, $20, $ff, $ff, $05, $20, $04, $20, $ff, $ff, $01, $0b, $00, $0b, $ff, $ff
	db $03, $0b, $02, $0b, $ff, $ff, $05, $0b, $04, $0b, $ff, $ff, $00, $ff, $ff, $ff
	db $02, $ff, $ff, $ff, $04, $ff, $ff, $ff, $ff, $ff, $57, $42, $57, $42, $57, $42
	db $57, $42, $57, $42, $57, $42, $5f, $42, $5f, $42, $5f, $42, $63, $42, $63, $42
	db $63, $42, $63, $42, $00, $0a, $01, $0a, $02, $0a, $ff, $ff, $00, $0a, $ff, $ff
	db $ff, $ff, $7f, $42, $7f, $42, $7f, $42, $85, $42, $8f, $42, $99, $42, $a1, $42
	db $a1, $42, $a1, $42, $a7, $42, $a7, $42, $a7, $42, $a7, $42, $00, $0e, $01, $0e
	db $ff, $ff, $00, $0e, $01, $0b, $02, $80, $01, $0a, $ff, $ff, $00, $0e, $01, $0b
	db $03, $80, $01, $0a, $ff, $ff, $01, $04, $00, $0e, $04, $80, $ff, $ff, $00, $0e
	db $01, $0e, $ff, $ff, $ff, $ff, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42
	db $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42, $c3, $42
	db $00, $08, $01, $0e, $00, $08, $02, $0e, $ff, $ff, $e7, $42, $e7, $42, $e7, $42
	db $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42, $e7, $42
	db $e7, $42, $e7, $42, $00, $08, $01, $0e, $02, $0d, $01, $0e, $ff, $ff, $0b, $43
	db $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43, $0b, $43
	db $0b, $43, $0b, $43, $0b, $43, $0b, $43, $00, $0e, $01, $0e, $00, $0e, $02, $0e
	db $ff, $ff, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43
	db $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $2f, $43, $00, $ff, $ff, $ff
	db $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43
	db $4d, $43, $4d, $43, $4d, $43, $4d, $43, $4d, $43, $00, $09, $01, $03, $02, $62
	db $01, $02, $ff, $ff, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43
	db $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $71, $43, $00, $0e
	db $01, $0e, $00, $0e, $02, $0e, $ff, $ff, $95, $43, $95, $43, $95, $43, $95, $43
	db $95, $43, $95, $43, $95, $43, $95, $43, $95, $43, $95, $43, $95, $43, $95, $43
	db $95, $43, $00, $0e, $01, $0b, $02, $11, $03, $0b, $04, $0e, $03, $0b, $02, $11
	db $01, $0b, $ff, $ff, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43
	db $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $c1, $43, $00, $0e
	db $01, $08, $02, $0c, $01, $08, $ff, $ff, $e5, $43, $e5, $43, $e5, $43, $e5, $43
	db $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43, $e5, $43
	db $e5, $43, $00, $0a, $01, $0b, $02, $0c, $ff, $ff, $07, $44, $07, $44, $07, $44
	db $07, $44, $07, $44, $07, $44, $07, $44, $07, $44, $07, $44, $07, $44, $07, $44
	db $07, $44, $07, $44, $00, $06, $01, $06, $02, $06, $03, $06, $ff, $ff, $2b, $44
	db $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44, $2b, $44
	db $2b, $44, $2b, $44, $2b, $44, $2b, $44, $00, $2c, $01, $0b, $02, $0d, $01, $0b
	db $ff, $ff, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44
	db $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $4f, $44, $00, $0b, $01, $0b
	db $02, $0b, $01, $0b, $ff, $ff, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44
	db $73, $44, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44, $73, $44
	db $00, $0e, $01, $0e, $02, $0e, $01, $0e, $ff, $ff, $97, $44, $97, $44, $97, $44
	db $97, $44, $97, $44, $97, $44, $97, $44, $97, $44, $97, $44, $97, $44, $97, $44
	db $97, $44, $97, $44, $00, $0e, $01, $0e, $02, $0e, $01, $0e, $ff, $ff, $bb, $44
	db $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44, $bb, $44
	db $bb, $44, $bb, $44, $bb, $44, $bb, $44, $00, $0e, $01, $0e, $02, $0e, $01, $0e
	db $ff, $ff, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44
	db $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $df, $44, $00, $0e, $01, $0e
	db $00, $0e, $02, $0e, $ff, $ff, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45
	db $03, $45, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45, $03, $45
	db $00, $0e, $01, $0e, $00, $0e, $02, $0e, $ff, $ff, $27, $45, $27, $45, $27, $45
	db $27, $45, $27, $45, $27, $45, $27, $45, $27, $45, $27, $45, $27, $45, $27, $45
	db $27, $45, $27, $45, $00, $20, $01, $07, $02, $10, $00, $10, $03, $07, $04, $10
	db $00, $0e, $05, $0e, $00, $0e, $05, $0e, $00, $0e, $06, $0e, $00, $0e, $06, $0e
	db $ff, $ff, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45
	db $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $5f, $45, $00, $0b, $01, $0b
	db $02, $0b, $01, $0b, $ff, $ff, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45
	db $83, $45, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45, $83, $45
	db $00, $0e, $03, $0a, $04, $0e, $05, $0a, $00, $0e, $03, $0a, $04, $0e, $05, $0a
	db $00, $10, $01, $0e, $02, $0e, $01, $0e, $02, $0e, $00, $20, $06, $0e, $07, $20
	db $06, $0e, $ff, $ff, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45
	db $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $c1, $45, $00, $0c
	db $01, $0c, $02, $0c, $03, $0c, $04, $0c, $05, $0c, $ff, $ff, $e9, $45, $e9, $45
	db $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45, $e9, $45
	db $e9, $45, $e9, $45, $e9, $45, $00, $1c, $ff, $1c, $ff, $ff, $09, $46, $09, $46
	db $09, $46, $09, $46, $09, $46, $09, $46, $09, $46, $09, $46, $09, $46, $0d, $46
	db $0d, $46, $0d, $46, $0d, $46, $00, $ff, $ff, $ff, $ff, $ff, $29, $46, $29, $46
	db $29, $46, $29, $46, $29, $46, $29, $46, $29, $46, $29, $46, $29, $46, $31, $46
	db $31, $46, $31, $46, $31, $46, $00, $08, $01, $08, $02, $0a, $ff, $ff, $ff, $ff
	db $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46, $4d, $46
	db $4d, $46, $65, $46, $65, $46, $65, $46, $65, $46, $00, $0a, $01, $0a, $02, $0a
	db $03, $0a, $04, $0a, $05, $0a, $06, $0a, $07, $0a, $08, $0a, $09, $0a, $fe, $00
	db $ff, $ff, $ff, $ff, $81, $46, $81, $46, $81, $46, $81, $46, $81, $46, $81, $46
	db $85, $46, $85, $46, $85, $46, $9f, $46, $9f, $46, $9f, $46, $9f, $46, $00, $ff
	db $ff, $ff, $00, $0e, $01, $0e, $02, $0e, $01, $0e, $02, $0e, $01, $0e, $02, $0e
	db $00, $36, $03, $0e, $04, $0e, $05, $0e, $06, $ff, $ff, $ff, $ff, $ff, $fb, $46
	db $11, $47, $47, $47, $7b, $47, $89, $47, $97, $47, $c7, $47, $df, $47, $05, $48
	db $47, $48, $67, $48, $7d, $48, $b9, $48, $e5, $48, $05, $49, $45, $49, $67, $49
	db $97, $49, $d9, $49, $f5, $49, $0b, $4a, $27, $4a, $41, $4a, $59, $4a, $6b, $4a
	db $81, $4a, $9f, $4a, $dd, $4a, $f3, $4a, $35, $4b, $47, $4b, $7f, $4b, $bb, $4b
	db $f7, $4b, $2f, $4c, $41, $4c, $55, $4c, $85, $4c, $b7, $4c, $f7, $4c, $37, $4d
	db $5d, $4d, $9d, $4d, $df, $4d, $ff, $4d, $00, $05, $fd, $74, $01, $05, $02, $05
	db $03, $05, $04, $02, $05, $02, $06, $02, $07, $02, $1f, $02, $ff, $ff, $00, $04
	db $fd, $76, $01, $04, $02, $04, $03, $04, $04, $02, $05, $02, $06, $02, $07, $02
	db $1f, $08, $08, $03, $09, $03, $0a, $03, $0b, $03, $0c, $03, $09, $03, $0a, $03
	db $0b, $03, $0c, $03, $09, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02
	db $1f, $02, $ff, $ff, $08, $02, $fd, $76, $09, $05, $0a, $05, $0b, $05, $0c, $02
	db $0d, $02, $0e, $02, $0f, $02, $1f, $08, $00, $01, $01, $01, $02, $01, $03, $01
	db $04, $03, $05, $03, $06, $03, $07, $03, $04, $03, $05, $03, $06, $03, $07, $03
	db $02, $02, $00, $02, $1f, $02, $ff, $ff, $00, $03, $fd, $78, $01, $03, $02, $03
	db $fe, $04, $1f, $02, $ff, $ff, $00, $02, $fd, $78, $01, $02, $02, $02, $fe, $04
	db $1f, $02, $ff, $ff, $00, $04, $fd, $7a, $01, $03, $02, $02, $03, $04, $04, $05
	db $05, $03, $06, $04, $07, $03, $08, $04, $04, $04, $05, $03, $06, $04, $07, $03
	db $08, $04, $04, $03, $05, $04, $06, $03, $07, $04, $08, $03, $09, $02, $0a, $03
	db $1f, $02, $ff, $ff, $00, $04, $fd, $7b, $01, $02, $02, $04, $03, $04, $04, $02
	db $00, $02, $01, $02, $02, $02, $01, $02, $1f, $02, $ff, $ff, $00, $02, $01, $02
	db $02, $02, $1f, $10, $03, $04, $fd, $7b, $04, $02, $05, $04, $06, $02, $07, $04
	db $08, $02, $03, $03, $04, $02, $05, $03, $06, $02, $07, $04, $08, $02, $1f, $02
	db $ff, $ff, $00, $02, $fd, $7c, $01, $02, $02, $02, $03, $02, $1f, $10, $04, $05
	db $fd, $7b, $05, $05, $06, $05, $07, $02, $08, $02, $0e, $02, $09, $02, $0f, $02
	db $0a, $02, $10, $02, $0b, $02, $11, $02, $0c, $02, $12, $02, $0d, $02, $13, $02
	db $08, $02, $0e, $02, $09, $02, $0f, $02, $0a, $02, $10, $02, $0b, $02, $06, $02
	db $1f, $02, $ff, $ff, $00, $02, $fd, $7e, $01, $02, $02, $02, $03, $02, $04, $02
	db $05, $02, $06, $02, $07, $02, $08, $02, $09, $02, $0a, $02, $0b, $02, $0c, $02
	db $1f, $02, $ff, $ff, $04, $05, $fd, $7e, $05, $04, $06, $05, $07, $06, $08, $05
	db $09, $04, $0a, $05, $04, $05, $1f, $02, $ff, $ff, $00, $03, $fd, $7f, $01, $03
	db $02, $03, $03, $03, $04, $03, $05, $03, $06, $03, $07, $03, $08, $03, $09, $03
	db $0a, $03, $0b, $03, $0c, $03, $0d, $03, $0e, $03, $0f, $03, $10, $03, $11, $03
	db $12, $03, $13, $03, $14, $03, $15, $03, $16, $03, $17, $03, $18, $03, $19, $03
	db $1a, $03, $1f, $02, $ff, $ff, $00, $03, $fd, $80, $01, $03, $02, $03, $03, $03
	db $04, $03, $05, $03, $06, $03, $07, $03, $08, $03, $09, $03, $0a, $03, $0b, $03
	db $0c, $03, $0d, $03, $0e, $03, $0f, $03, $10, $03, $11, $03, $12, $03, $1f, $02
	db $ff, $ff, $00, $05, $fd, $80, $01, $04, $02, $04, $03, $03, $04, $02, $03, $02
	db $04, $03, $03, $03, $04, $0f, $1f, $03, $04, $03, $1f, $03, $04, $02, $1f, $02
	db $ff, $ff, $06, $03, $fd, $81, $07, $03, $08, $02, $09, $02, $0a, $01, $0b, $01
	db $0c, $01, $1f, $08, $01, $02, $02, $02, $03, $02, $04, $02, $01, $02, $02, $02
	db $03, $02, $04, $02, $01, $02, $02, $02, $03, $02, $04, $02, $01, $02, $02, $02
	db $03, $02, $04, $02, $01, $02, $02, $02, $03, $02, $04, $02, $05, $01, $1f, $02
	db $ff, $ff, $00, $04, $fd, $82, $01, $03, $1f, $08, $02, $05, $03, $04, $04, $03
	db $05, $03, $06, $02, $07, $02, $04, $02, $05, $02, $06, $02, $07, $02, $02, $02
	db $1f, $02, $ff, $ff, $00, $04, $fd, $82, $01, $03, $02, $02, $1f, $08, $03, $05
	db $04, $04, $05, $03, $06, $03, $07, $02, $08, $02, $09, $02, $05, $02, $06, $02
	db $07, $02, $08, $02, $09, $02, $06, $02, $07, $02, $08, $02, $09, $02, $04, $01
	db $1f, $02, $ff, $ff, $00, $03, $fd, $83, $01, $03, $02, $02, $03, $03, $02, $01
	db $0f, $01, $04, $03, $05, $03, $06, $03, $07, $02, $08, $02, $09, $02, $0a, $01
	db $0b, $01, $0c, $01, $0d, $01, $06, $03, $07, $02, $0a, $01, $0b, $01, $0c, $01
	db $0d, $01, $08, $03, $09, $02, $0a, $01, $0b, $01, $0c, $01, $0d, $01, $0e, $01
	db $04, $02, $1f, $02, $ff, $ff, $00, $04, $fd, $72, $01, $04, $02, $04, $03, $04
	db $04, $04, $05, $04, $06, $04, $07, $04, $08, $04, $09, $04, $0a, $04, $1f, $02
	db $ff, $ff, $00, $04, $fd, $71, $01, $03, $02, $04, $03, $03, $04, $02, $05, $01
	db $06, $01, $07, $01, $1f, $01, $ff, $ff, $00, $0a, $fd, $70, $01, $08, $02, $07
	db $03, $06, $04, $05, $05, $05, $06, $05, $07, $05, $08, $04, $09, $04, $0a, $04
	db $1f, $02, $ff, $ff, $00, $08, $fd, $73, $01, $06, $02, $08, $03, $06, $04, $08
	db $05, $08, $06, $08, $07, $08, $08, $04, $09, $04, $1f, $02, $ff, $ff, $00, $06
	db $fd, $73, $01, $06, $02, $06, $03, $06, $04, $08, $05, $08, $06, $04, $07, $04
	db $08, $04, $1f, $02, $ff, $ff, $00, $06, $fd, $84, $01, $06, $02, $06, $03, $06
	db $04, $06, $05, $06, $1f, $02, $ff, $ff, $00, $0a, $fd, $85, $01, $06, $02, $05
	db $03, $04, $04, $04, $05, $03, $06, $03, $07, $03, $1f, $02, $ff, $ff, $00, $04
	db $fd, $86, $1f, $04, $00, $04, $1f, $04, $00, $04, $1f, $04, $00, $04, $1f, $04
	db $00, $04, $1f, $04, $00, $04, $1f, $04, $1f, $02, $ff, $ff, $00, $03, $fd, $88
	db $01, $03, $02, $03, $1f, $08, $03, $02, $04, $02, $05, $02, $06, $02, $07, $02
	db $08, $02, $09, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02
	db $10, $02, $11, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02
	db $10, $02, $11, $02, $12, $02, $1f, $02, $ff, $ff, $00, $04, $fd, $89, $01, $04
	db $02, $04, $03, $04, $04, $05, $05, $04, $06, $04, $07, $04, $1f, $02, $ff, $ff
	db $00, $02, $fd, $8a, $01, $02, $02, $02, $03, $02, $04, $02, $05, $02, $06, $02
	db $07, $02, $08, $02, $09, $02, $0a, $02, $0b, $03, $0c, $05, $0d, $04, $0e, $03
	db $0f, $03, $0e, $04, $0d, $04, $0e, $03, $0b, $03, $13, $04, $0b, $04, $0c, $05
	db $0d, $04, $0e, $03, $0f, $04, $0e, $03, $10, $04, $11, $04, $12, $04, $1f, $02
	db $ff, $ff, $00, $03, $fd, $8c, $01, $04, $02, $04, $03, $03, $04, $05, $05, $03
	db $1f, $02, $ff, $ff, $00, $03, $fd, $8d, $01, $04, $02, $04, $03, $03, $00, $03
	db $01, $04, $02, $04, $03, $03, $04, $05, $05, $03, $06, $03, $1f, $08, $07, $03
	db $08, $02, $09, $04, $0a, $04, $0b, $04, $0c, $04, $0d, $04, $0e, $03, $0f, $03
	db $10, $03, $11, $03, $12, $03, $13, $03, $1f, $02, $ff, $ff, $00, $03, $fd, $8e
	db $01, $04, $02, $04, $03, $03, $04, $05, $05, $02, $06, $02, $07, $02, $08, $02
	db $09, $02, $0a, $03, $0b, $04, $0c, $03, $0d, $03, $0e, $02, $0f, $02, $10, $02
	db $0c, $02, $0d, $02, $0e, $02, $0f, $02, $10, $02, $0d, $02, $0e, $02, $0f, $02
	db $10, $02, $0a, $01, $1f, $02, $ff, $ff, $00, $03, $fd, $8f, $01, $04, $02, $04
	db $03, $03, $04, $05, $05, $03, $06, $03, $1f, $08, $07, $02, $08, $02, $09, $02
	db $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02, $10, $02, $11, $02
	db $12, $02, $13, $02, $14, $02, $15, $02, $16, $02, $17, $02, $18, $02, $19, $02
	db $1f, $02, $ff, $ff, $00, $03, $fd, $90, $01, $04, $02, $04, $03, $03, $04, $05
	db $05, $03, $06, $03, $1f, $08, $07, $05, $08, $04, $09, $03, $0a, $03, $0b, $03
	db $0a, $04, $0b, $08, $1f, $03, $0b, $02, $1f, $02, $0b, $01, $1f, $01, $0b, $01
	db $1f, $01, $0b, $01, $1f, $01, $0b, $01, $1f, $02, $ff, $ff, $00, $06, $fd, $92
	db $01, $05, $02, $05, $03, $03, $04, $04, $05, $03, $1f, $02, $ff, $ff, $00, $03
	db $fd, $93, $01, $04, $02, $04, $03, $03, $04, $05, $05, $03, $06, $02, $1f, $02
	db $ff, $ff, $00, $06, $fd, $93, $01, $05, $02, $05, $03, $05, $04, $03, $05, $03
	db $06, $08, $07, $03, $06, $03, $07, $03, $06, $03, $07, $02, $06, $02, $07, $02
	db $06, $02, $07, $01, $06, $01, $07, $01, $06, $01, $07, $01, $06, $01, $1f, $02
	db $ff, $ff, $00, $05, $fd, $8c, $01, $04, $02, $04, $03, $04, $04, $03, $05, $03
	db $06, $03, $05, $02, $07, $02, $08, $02, $07, $02, $1f, $02, $08, $02, $1f, $02
	db $07, $01, $1f, $01, $08, $01, $1f, $01, $07, $01, $1f, $01, $08, $01, $1f, $01
	db $1f, $02, $ff, $ff, $00, $04, $fd, $94, $01, $05, $02, $05, $03, $04, $04, $04
	db $05, $06, $06, $04, $07, $04, $08, $03, $07, $02, $08, $02, $06, $02, $08, $03
	db $09, $03, $08, $02, $09, $02, $08, $02, $09, $02, $0a, $02, $0b, $02, $0a, $01
	db $0b, $01, $0a, $01, $1f, $01, $0b, $01, $1f, $01, $0a, $01, $1f, $01, $0b, $01
	db $1f, $02, $ff, $ff, $00, $01, $fd, $95, $01, $01, $02, $01, $03, $02, $04, $03
	db $05, $03, $06, $03, $07, $03, $08, $03, $09, $03, $0a, $03, $0b, $02, $0c, $02
	db $0d, $02, $0b, $02, $0c, $02, $0d, $02, $0b, $02, $0c, $02, $0d, $02, $0b, $02
	db $0c, $02, $0d, $02, $0b, $02, $0c, $02, $0d, $02, $0b, $02, $0c, $02, $0d, $02
	db $1f, $02, $ff, $ff, $00, $03, $fd, $96, $1f, $01, $01, $03, $1f, $01, $02, $03
	db $1f, $01, $03, $03, $1f, $01, $04, $03, $05, $03, $04, $03, $05, $03, $04, $03
	db $05, $03, $04, $03, $05, $03, $1f, $02, $ff, $ff, $00, $04, $fd, $97, $01, $04
	db $00, $03, $01, $03, $02, $04, $01, $04, $02, $03, $01, $03, $03, $04, $02, $04
	db $03, $03, $02, $03, $04, $04, $03, $04, $04, $03, $03, $03, $05, $04, $04, $03
	db $06, $03, $05, $04, $07, $04, $10, $04, $0b, $04, $11, $04, $0c, $04, $12, $04
	db $0d, $04, $13, $04, $07, $03, $1f, $02, $ff, $ff, $00, $04, $fd, $99, $01, $05
	db $02, $04, $03, $03, $04, $03, $05, $03, $06, $03, $07, $03, $08, $03, $1f, $08
	db $09, $02, $0a, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02, $0f, $02, $10, $02
	db $11, $02, $12, $02, $13, $02, $14, $02, $0b, $02, $0c, $02, $0d, $02, $0e, $02
	db $0f, $02, $15, $02, $16, $02, $17, $02, $1f, $02, $ff, $ff, $00, $04, $fd, $9b
	db $01, $04, $02, $04, $03, $02, $04, $02, $05, $02, $06, $02, $07, $02, $08, $02
	db $05, $02, $06, $02, $07, $02, $08, $02, $1f, $02, $ff, $ff, $00, $04, $01, $03
	db $02, $06, $03, $06, $04, $06, $05, $06, $06, $06, $07, $06, $08, $06, $09, $06
	db $1f, $02, $ff, $ff, $23, $4e, $29, $4e, $5b, $4e, $61, $4e, $67, $4e, $99, $4e
	db $00, $02, $02, $01, $fe, $00, $00, $04, $06, $01, $00, $04, $06, $01, $01, $04
	db $06, $01, $01, $04, $06, $01, $02, $04, $06, $01, $02, $05, $06, $01, $03, $05
	db $06, $01, $03, $05, $06, $01, $04, $05, $06, $01, $04, $06, $06, $01, $05, $06
	db $06, $01, $05, $06, $06, $01, $ff, $ff, $00, $02, $06, $01, $fe, $00, $01, $02
	db $06, $01, $fe, $00, $02, $02, $06, $01, $02, $02, $06, $01, $02, $02, $06, $01
	db $03, $02, $06, $01, $03, $02, $06, $01, $03, $02, $06, $01, $04, $02, $06, $01
	db $04, $02, $06, $01, $04, $02, $06, $01, $05, $02, $06, $01, $05, $02, $06, $01
	db $05, $02, $06, $01, $ff, $ff, $01, $02, $02, $01, $fe, $00

Call_02_4E9F::
	call Call_1264
	ld hl, $c817
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_Call_08_41E3
	rst $10
	ld a, $02
	call Call_1AE1
	ld a, [$c88b]
	rst $00

JumpTable_02_4EB7::
	dw Jump_02_4EBF
	dw Jump_02_4F85
	dw Jump_02_5012
	dw Jump_02_509F

Jump_02_4EBF::
	ld a, $fc
	call Call_1688
	ld de, $5b17
	ld hl, $9000
	call Call_14CF
	ld de, $5b18
	ld hl, $8600
	call Call_14CF
	ld de, $5b19
	ld hl, $8640
	call Call_14CF
	ld de, $5b1a
	ld hl, $8670
	call Call_14CF
	ld de, $2f00
	ld hl, $8800
	call Call_14CF
	ld de, $310d
	ld hl, $8a00
	call Call_14CF
	ld de, $310e
	ld hl, $8b00
	call Call_14CF
	ld de, $3110
	ld hl, $8c00
	call Call_14CF
	ld de, $6df0
	ld hl, $9800
	call Call_02_5C6D
	ld de, $7092
	ld hl, $9c00
	call Call_02_5C6D
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld a, $02
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld hl, far_Call_17_41C0
	rst $10
	ld a, $01
	ldh [rVBK], a
	ld de, $3f04
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld de, $3f04
	ld hl, $9c00
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	ld a, $00
	ldh [$ffb7], a
	ld a, $70
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffb5], a
	ld a, $00
	ldh [$ffb6], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	xor a
	ld [$c892], a
	ld a, $03
	ld [$c8a1], a
	call Call_122F
	call Call_1417
	call $ff80
	ld a, $01
	jp Jump_000_11cb


Jump_02_4F85::
	ld a, $fc
	call Call_1688
	ld de, $5b1b
	ld hl, $9000
	call Call_14CF
	ld de, $5b1c
	ld hl, $8800
	call Call_14CF
	ld de, $ff00
	ld hl, $8ff0
	ld bc, $0008
	call Call_02_6A5B
	ld de, $720e
	ld hl, $9800
	call Call_02_5C6D
	ld a, $ff
	ld hl, $9c00
	ld bc, $0040
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld a, $03
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f06
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	ld a, $00
	ldh [$ffb7], a
	ld a, $70
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffb5], a
	ld a, $00
	ldh [$ffb6], a
	ld a, $03
	ld [$c8a1], a
	call Call_122F
	call Call_1417
	call $ff80
	xor a
	ld [$c892], a
	ld a, $01
	jp Jump_000_11cb


Jump_02_5012::
	ld a, $fc
	call Call_1688
	ld de, $5b1b
	ld hl, $9000
	call Call_14CF
	ld de, $5b1c
	ld hl, $8800
	call Call_14CF
	ld de, $ff00
	ld hl, $8ff0
	ld bc, $0008
	call Call_02_6A5B
	ld de, $720e
	ld hl, $9800
	call Call_02_5C6D
	ld a, $ff
	ld hl, $9c00
	ld bc, $0040
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld a, $03
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f06
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	ld a, $00
	ldh [$ffb7], a
	ld a, $70
	ldh [$ffbb], a
	ld a, $07
	ldh [$ffb5], a
	ld a, $80
	ldh [$ffb6], a
	ld a, $03
	ld [$c8a1], a
	call Call_122F
	call Call_1417
	call $ff80
	xor a
	ld [$c892], a
	ld a, $01
	jp Jump_000_11cb


Jump_02_509F::
	ld a, $fc
	call Call_1688
	ld de, $5b1d
	ld hl, $9000
	call Call_14CF
	ld de, $5b1e
	ld hl, $8800
	call Call_14CF
	ld de, $ff00
	ld hl, $8ff0
	ld bc, $0008
	call Call_02_6A5B
	ld de, $74b0
	ld hl, $9800
	call Call_02_5C6D
	ld a, $ff
	ld hl, $9c00
	ld bc, $0040
	call Call_12C7
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	ld a, $04
	ld [$c81e], a
	ld hl, far_Call_17_4712
	rst $10
	ld de, $3f07
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [$c81d]
	or a
	call nz, Call_14CF
	ld a, $00
	ldh [rVBK], a
	xor a
	ld [$c8a4], a
	ld [$c8a5], a
	ld a, $00
	ldh [$ffb7], a
	ld a, $70
	ldh [$ffbb], a
	ld a, $07
	ldh [$ffb5], a
	ld a, $80
	ldh [$ffb6], a
	ld a, $03
	ld [$c8a1], a
	call Call_122F
	call Call_1417
	call $ff80
	xor a
	ld [$c892], a
	ld a, $01
	jp Jump_000_11cb


Call_02_512C::
	ld a, [$c88b]
	rst $00

JumpTable_02_5130::
	dw Jump_02_5138
	dw Jump_02_5D06
	dw Jump_02_5E98
	dw Jump_02_5F70

Jump_02_5138::
	call Call_02_5CA2
	call Call_02_517E
	ld a, [$c0fc]
	rst $00

JumpTable_02_5142::
	dw Jump_02_5C48
	dw Jump_02_5224
	dw Jump_02_5C58
	dw Jump_02_528A
	dw Jump_02_5C48
	dw Jump_02_5331
	dw Jump_02_5C38
	dw Jump_02_53D8
	dw Jump_02_5C38
	dw Jump_02_547F
	dw Jump_02_5C28
	dw Jump_02_5526
	dw Jump_02_55D8
	dw Jump_02_568B
	dw Jump_02_5732
	dw Jump_02_581F
	dw Jump_02_590F
	dw Jump_02_5BF8
	dw Jump_02_59B6
	dw Jump_02_5C08
	dw Jump_02_5A5D
	dw Jump_02_5C18
	dw Jump_02_5AE6
	dw Jump_02_5B35
	dw Jump_02_5C28
	dw Jump_02_5B80
	dw Jump_02_5B8E
	dw Jump_02_5BB6
	dw Jump_02_5C58
	dw Jump_02_5BD5

Call_02_517E::
	ld a, [$c0fc]
	cp $00
	jr z, jr_002_5188

	cp $01
	ret nz

jr_002_5188:
	ld hl, $ffc3
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $f0
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $0e
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $b0
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_05_4005
	rst $10
	ld hl, $ffc3
	ld a, $58
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $f0
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $0d
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $a0
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_05_4005
	rst $10
	ld hl, $ffc3
	ld a, $68
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $f0
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_04_4081
	rst $10
	ld hl, $ffc3
	ld a, $28
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $10
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $c0
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_05_4005
	rst $10
	ld hl, $ffc3
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $10
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $c0
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld hl, far_Call_05_4005
	rst $10
	ret


Jump_02_5224::
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $03
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $ffbb
	dec [hl]
	ldh a, [$ffbb]
	or a
	ret nz

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $50
	ld [$c0e0], a
	ld a, $30
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_528A::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $40
	jr nz, jr_002_52d7

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_52d7:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_5331::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $10
	jr nz, jr_002_537e

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_537e:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_53D8::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $28
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $70
	jr nz, jr_002_5425

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_5425:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $70
	ld [$c0e0], a
	ld a, $10
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_547F::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $60
	jr nz, jr_002_54cc

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_54cc:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_5526::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $10
	jr nz, jr_002_5573

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_5573:
	ld a, [$c0d9]
	or a
	jr nz, jr_002_557e

	ld a, $01
	ld [$c0d8], a

jr_002_557e:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_55D8::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $28
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $70
	jr nz, jr_002_5625

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_5625:
	ld a, [$c0d9]
	cp $38
	jr nz, jr_002_5631

	ld a, $01
	ld [$c0d8], a

jr_002_5631:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_568B::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $10
	jr nz, jr_002_56d8

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_56d8:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $30
	ld [$c0e0], a
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_5732::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $20
	jr nz, jr_002_577f

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_577f:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0e6], a
	ld a, $40
	ld [$c0e7], a
	ld a, $00
	ld [$c0e8], a
	ld a, $00
	ld [$c0e9], a
	ld a, $00
	ld [$c0ea], a
	ld a, $02
	ld [$c0eb], a
	ld a, $00
	ld [$c0ec], a
	ld a, $01
	ld [$c0ed], a
	ld a, $20
	ld [$c0ee], a
	ld a, $20
	ld [$c0ef], a
	ld a, $00
	ld [$c0f0], a
	ld a, $00
	ld [$c0f1], a
	ld a, $04
	ld [$c0f2], a
	ld a, $00
	ld [$c0f3], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_581F::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, [$c0e7]
	cp $e0
	jr nz, jr_002_583f

	ld a, $01
	ld [$c0e6], a
	ld a, $02
	ldh [$ffca], a

jr_002_583f:
	ld hl, $c0e6
	call Call_02_6A80
	ld hl, $c0e7
	dec [hl]
	ld hl, $c0e8
	inc [hl]
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ed
	call Call_02_6A80
	ld a, [$c0e7]
	cp $10
	jr nz, jr_002_586b

	ld a, $00
	ld [$c0ed], a

jr_002_586b:
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $28
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $70
	jr nz, jr_002_58b0

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_58b0:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld a, [$c0e6]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $80
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $50
	ld [$c0e0], a
	ld a, $30
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_590F::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $40
	jr nz, jr_002_595c

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_595c:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $40
	ld [$c0d9], a
	ld a, $00
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $20
	ld [$c0e0], a
	ld a, $20
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_59B6::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $e0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $10
	jr nz, jr_002_5a03

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_5a03:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $a0
	ld [$c0d9], a
	ld a, $30
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $01
	ld [$c0df], a
	ld a, $80
	ld [$c0e0], a
	ld a, $50
	ld [$c0e1], a
	ld a, $00
	ld [$c0e2], a
	ld a, $00
	ld [$c0e3], a
	ld a, $04
	ld [$c0e4], a
	ld a, $00
	ld [$c0e5], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_5A5D::
	ld a, $00
	ldh [$ffb7], a
	ld a, $00
	ldh [$ffbb], a
	ld a, $00
	ldh [$ffc7], a
	ld a, $60
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld hl, $c0d9
	dec [hl]
	ld hl, $c0da
	inc [hl]
	ld a, [$c0d9]
	cp $28
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $64
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0df
	call Call_02_6A80
	ld a, [$c0d9]
	cp $70
	jr nz, jr_002_5aaa

	ld a, $00
	ld [$c0df], a
	ld a, $5d
	call Call_1B2C

jr_002_5aaa:
	ld a, [$c0d8]
	or a
	ret z

	ld a, [$c0df]
	or a
	ret z

	ld a, $02
	call Call_1AE1
	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $50
	ld [$c0d9], a
	ld a, $90
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $00
	ld [$c0fd], a
	ret


Jump_02_5AE6::
	ld a, $02
	ldh [$ffc7], a
	ld a, $67
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0fd]
	cp $78
	jr c, jr_002_5b30

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $50
	ld [$c0d9], a
	ld a, $90
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $00
	ld [$c0fd], a
	ret


jr_002_5b30:
	ld hl, $c0fd
	inc [hl]
	ret


Jump_02_5B35::
	ld a, $03
	ldh [$ffc7], a
	ld a, $67
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0fd]
	cp $78
	jr c, jr_002_5b7b

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0d8], a
	ld a, $50
	ld [$c0d9], a
	ld a, $88
	ld [$c0da], a
	ld a, $00
	ld [$c0db], a
	ld a, $00
	ld [$c0dc], a
	ld a, $02
	ld [$c0dd], a
	ld a, $00
	ld [$c0de], a
	ld a, $00
	ld [$c0fd], a
	ret


jr_002_5b7b:
	ld hl, $c0fd
	inc [hl]
	ret


Jump_02_5B80::
	ld a, $8b
	ld [$c8a1], a
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5B8E::
	ld a, $04
	ldh [$ffc7], a
	ld a, $67
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0fd]
	cp $24
	jr c, jr_002_5bb1

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0fd], a
	ret


jr_002_5bb1:
	ld hl, $c0fd
	inc [hl]
	ret


Jump_02_5BB6::
	ld a, [$c0fd]
	or a
	jr z, jr_002_5bcb

	ld a, [$c850]
	or a
	ret nz

	ld hl, $c0fc
	inc [hl]
	ld a, $00
	ld [$c0fd], a
	ret


jr_002_5bcb:
	ld hl, $c0fd
	inc [hl]
	ld a, $04
	call Call_1688
	ret


Jump_02_5BD5::
	ld a, $01
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c8ea
	set 7, [hl]
	ld hl, $c88e
	inc [hl]
	ld a, $83
	ld [$c8a1], a
	ret


Jump_02_5BF8::
	ld a, [$c0fd]
	cp $18
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5C08::
	ld a, [$c0fd]
	cp $28
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5C18::
	ld a, [$c0fd]
	cp $40
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5C28::
	ld a, [$c0fd]
	cp $3c
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5C38::
	ld a, [$c0fd]
	cp $78
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5C48::
	ld a, [$c0fd]
	cp $b4
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5C58::
	ld a, [$c0fd]
	cp $f0
	jr c, jr_002_5c68

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


jr_002_5c68:
	ld hl, $c0fd
	inc [hl]
	ret


Call_02_5C6D::
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

jr_002_5c7c:
	ld a, [de]
	inc de
	cp $d8
	jr z, jr_002_5c88

	cp $d9
	ret z

	ld [hli], a
	jr jr_002_5c7c

jr_002_5c88:
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
	jr jr_002_5c7c

Call_02_5CA2::
	ld hl, $c0fb
	inc [hl]
	ld a, [$c0fb]
	cp $18
	ret nz

	xor a
	ld [$c0fb], a
	ld hl, $c0fa
	inc [hl]
	ld a, [$c0fa]
	cp $05
	jr nz, jr_002_5cbf

	xor a
	ld [$c0fa], a

jr_002_5cbf:
	ld hl, $5cfc
	ld a, [$c0fa]
	call Call_02_6AFF
	ld e, l
	ld d, h
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld b, $10

jr_002_5cd4:
	di
	call Call_1AA6
	ld a, [de]
	ei
	ld [$c0f9], a
	di
	call Call_1AA6
	ld a, [hl]
	ei
	push af
	di
	call Call_1AA6
	pop af
	ld [de], a
	ei
	ld a, [$c0f9]
	push af
	di
	call Call_1AA6
	pop af
	ld [hl], a
	ei
	inc de
	inc hl
	dec b
	jr nz, jr_002_5cd4

	ret


	db $80, $91, $a0, $91, $c0, $91, $e0, $91, $00, $92

Jump_02_5D06::
	call Call_02_5DF7
	ld a, [$c0fc]
	rst $00

JumpTable_02_5D0D::
	dw Jump_02_5D17
	dw Jump_02_5D36
	dw Jump_02_5D4B
	dw Jump_02_5D69
	dw Jump_02_5D7E

Jump_02_5D17::
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $05
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $ffbb
	dec [hl]
	ldh a, [$ffbb]
	or a
	ret nz

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5D36::
	ld a, [$c0fd]
	cp $b4
	jr nc, jr_002_5d42

	ld hl, $c0fd
	inc [hl]
	ret


jr_002_5d42:
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5D4B::
	ld a, [$c0fd]
	or a
	jr z, jr_002_5d5f

	ld a, [$c850]
	or a
	ret nz

	ld hl, $c0fc
	inc [hl]
	xor a
	ld [$c0fd], a
	ret


jr_002_5d5f:
	ld hl, $c0fd
	inc [hl]
	ld a, $04
	call Call_1688
	ret


Jump_02_5D69::
	ld a, [$c0fd]
	cp $78
	jr nc, jr_002_5d75

	ld hl, $c0fd
	inc [hl]
	ret


jr_002_5d75:
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5D7E::
	ld a, $01
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $0004
	ld a, l
	ld [$c96d], a
	ld a, h
	ld [$c96e], a
	ld hl, $00f8
	ld a, l
	ld [$c96f], a
	ld a, h
	ld [$c970], a
	ld hl, $0038
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
	ld hl, $cab9
	ld a, [$ca8d]
	ld [hli], a
	ld a, [$ca8e]
	ld [hli], a
	ld a, [$ca8f]
	ld [hli], a
	ld a, [$ca90]
	ld [hli], a
	ld a, [$ca91]
	ld [hli], a
	ld a, [$ca92]
	ld [hli], a
	ld a, [$ca93]
	ld [hli], a
	xor a
	ld [$ca8d], a
	ld a, $ff
	ld [$ca8e], a
	ld [$ca8f], a
	ld [$ca90], a
	ld hl, $c88e
	inc [hl]
	ret


Call_02_5DF7::
	ld hl, $c0f9
	inc [hl]
	ld a, [$c0f9]
	cp $19
	jr z, jr_002_5e45

	cp $32
	ret nz

	xor a
	ld [$c0f9], a
	xor a
	ld [$c0fa], a

jr_002_5e0d:
	ld a, [$c0fa]
	ld hl, $5e8c
	call Call_02_6AFF
	ld e, l
	ld d, h
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld b, $10

jr_002_5e22:
	di
	call Call_1AA6
	ld a, [de]
	ld [$c0fb], a
	call Call_1AA6
	ld a, [hl]
	ld [de], a
	ld a, [$c0fb]
	ld [hl], a
	ei
	inc de
	inc hl
	dec b
	jr nz, jr_002_5e22

	ld hl, $c0fa
	inc [hl]
	ld a, [$c0fa]
	cp $02
	jr nz, jr_002_5e0d

	ret


jr_002_5e45:
	xor a
	ld [$c0fa], a

jr_002_5e49:
	ld a, [$c0fa]
	ld hl, $5e90
	call Call_02_6AFF
	ld e, l
	ld d, h
	ld a, $20
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld b, $20

jr_002_5e5e:
	di
	call Call_1AA6
	ld a, [de]
	ld [$c0fb], a
	ei
	di
	call Call_1AA6
	ld a, [hl]
	ld [de], a
	ei
	di
	call Call_1AA6
	ld a, [$c0fb]
	ld [hl], a
	ei
	inc de
	inc hl
	dec b
	jr nz, jr_002_5e5e

	ld hl, $c0fa
	inc [hl]
	ld hl, $c0fa
	inc [hl]
	ld a, [$c0fa]
	cp $04
	jr nz, jr_002_5e49

	ret


	db $00, $89, $00, $8a, $20, $89, $30, $89, $20, $8a, $30, $8a

Jump_02_5E98::
	call Call_02_5DF7
	ld a, [$c0fc]
	rst $00

JumpTable_02_5E9F::
	dw Jump_02_5EA9
	dw Jump_02_5EC9
	dw Jump_02_5EE7
	dw Jump_02_5F24
	dw Jump_02_5F3D

Jump_02_5EA9::
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $04
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $ffbb
	dec [hl]
	ldh a, [$ffbb]
	cp $08
	ret nz

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5EC9::
	ld a, [$c0fd]
	cp $78
	jr nc, jr_002_5ed5

	ld hl, $c0fd
	inc [hl]
	ret


jr_002_5ed5:
	xor a
	ld [$c0d8], a
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld a, $68
	call Call_1B2C
	ret


Jump_02_5EE7::
	ld a, [$c0fd]
	cp $f0
	jr nc, jr_002_5f19

	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	and $03
	cp $03
	ret nz

	ld hl, $c0d8
	inc [hl]
	ld a, [$c0d8]
	cp $02
	jr nz, jr_002_5f09

	xor a
	ld [$c0d8], a

jr_002_5f09:
	ld a, [$c0d8]
	ld hl, $5f22
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ldh [$ffbb], a
	ret


jr_002_5f19:
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


	db $08, $00

Jump_02_5F24::
	ld a, [$c0fd]
	cp $3c
	jr nc, jr_002_5f30

	ld hl, $c0fd
	inc [hl]
	ret


jr_002_5f30:
	xor a
	ld [$c0d8], a
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_5F3D::
	ld a, [$c0fd]
	or a
	jr z, jr_002_5f66

	ld a, [$c850]
	or a
	ret nz

	ld a, $01
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c8ea
	set 7, [hl]
	ld hl, $c88e
	inc [hl]
	ret


jr_002_5f66:
	ld hl, $c0fd
	inc [hl]
	ld a, $04
	call Call_1688
	ret


Jump_02_5F70::
	ld a, [$c0fc]
	rst $00

JumpTable_02_5F74::
	dw Jump_02_5EA9
	dw Jump_02_5EC9
	dw Jump_02_5EE7
	dw Jump_02_5F24
	dw Jump_02_5F7E

Jump_02_5F7E::
	ld a, [$c0fd]
	or a
	jr z, jr_002_5f66

	ld a, [$c850]
	or a
	ret nz

	ld a, $01
	ld [$c88a], a
	ld a, $00
	ld [$c88b], a
	ld a, $00
	ld [$c88c], a
	ld a, $00
	ld [$c88d], a
	ld hl, $c8ea
	set 7, [hl]
	ld hl, $c88e
	inc [hl]
	ret


Call_02_5FA7::
	ld de, $5b18
	ld hl, $8700
	call Call_1577
	ld de, $5b19
	ld hl, $8740
	call Call_1577
	xor a
	ld hl, $c0d8
	ld bc, $0028
	call Call_12C7
	call Call_02_6A37
	call Call_02_6A3D
	call Call_02_6A43
	call Call_02_6A49
	call Call_02_6A4F
	call Call_02_6A55
	ret


Call_02_5FD6::
	ld a, [$c0fc]
	rst $00

JumpTable_02_5FDA::
	dw Jump_02_5FF8
	dw Jump_02_602E
	dw Jump_02_604D
	dw Jump_02_60A9
	dw Jump_02_6105
	dw Jump_02_616A
	dw Jump_02_623B
	dw Jump_02_648C
	dw Jump_02_649F
	dw Jump_02_64CC
	dw Jump_02_650D
	dw Jump_02_66AB
	dw Jump_02_67EC
	dw Jump_02_681F
	dw Jump_02_6886

Jump_02_5FF8::
	ld a, [$c0fd]
	ld b, a
	ld a, [$c0d8]
	or b
	call z, Call_02_5FA7
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $f0
	ret c

	xor a
	ld [$c0fd], a
	ld a, [$c0d8]
	cp $01
	jr nz, jr_002_601d

	ld hl, $c0d8
	inc [hl]
	ret


jr_002_601d:
	xor a
	ld [$c0fd], a
	xor a
	ld [$c0d8], a
	xor a
	ld [$d9cb], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_602E::
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $78
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_68A1
	ld hl, $c0de
	call Call_02_68EB
	ret


Jump_02_604D::
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $60
	call z, Call_02_6A19
	ld a, [$c0d9]
	or a
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $78
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_6937
	ret


Jump_02_60A9::
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $10
	call z, Call_02_6A19
	ld a, [$c0d9]
	or a
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $78
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_6981
	ret


Jump_02_6105::
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $70
	call z, Call_02_6A19
	ld a, [$c0d9]
	or a
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $3c
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_6937
	ld hl, $c0e4
	call Call_02_6981
	call Call_02_6A43
	ret


Jump_02_616A::
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $10
	call z, Call_02_6A19
	ld a, [$c0d9]
	or a
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld a, [$c0fd]
	cp $10
	jr c, jr_002_61fc

	jr nz, jr_002_61b9

	call Call_02_6A1F

jr_002_61b9:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0e4
	call Call_02_6A80
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
	ld a, [$c0e5]
	cp $70
	call z, Call_02_6A25
	ld a, [$c0e5]
	or a
	call z, Call_02_6A43
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ea
	call Call_02_6A80

jr_002_61fc:
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $c8
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_6937
	ld hl, $c0e4
	call Call_02_68A1
	ld hl, $c0ea
	call Call_02_68EB
	ld hl, $c0f0
	call Call_02_6981
	call Call_02_6A43
	call Call_02_6A4F
	call Call_02_6A13
	ld hl, $d9cb
	inc [hl]
	xor a
	ld [$c8a6], a
	ld [$c8a7], a
	ret


Jump_02_623B::
	ld a, [$c0fd]
	cp $40
	ld hl, $c0d8
	call z, Call_02_6937
	ld a, [$c0fd]
	cp $60
	ld hl, $c0e4
	call z, Call_02_6981
	ld a, [$c0fd]
	cp $70
	ld hl, $c0f0
	call z, Call_02_68A1
	ld a, [$c0fd]
	cp $70
	ld hl, $c0f6
	call z, Call_02_6911
	ld a, [$c0fd]
	cp $40
	call z, Call_02_6A37
	ld a, [$c0fd]
	cp $60
	call z, Call_02_6A43
	ld a, [$c0fd]
	cp $70
	call z, Call_02_6A4F
	ld a, [$c0fd]
	cp $10
	call z, Call_02_6A1F
	ld a, [$c0fd]
	cp $20
	call z, Call_02_6A2B
	ld a, [$c0fd]
	cp $40
	call z, Call_02_6A13
	ld a, [$c0fd]
	cp $60
	call z, Call_02_6A1F
	ld a, [$c0fd]
	cp $70
	call z, Call_02_6A2B
	ld a, [$c0fd]
	cp $80
	jp nc, Jump_002_63eb

	cp $70
	jp nc, Jump_002_63a0

	cp $60
	jp nc, Jump_002_6354

	cp $40
	jp nc, Jump_002_6309

	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $10
	call z, Call_02_6A19
	ld a, [$c0d9]
	or a
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld a, [$c0fd]
	cp $10
	jp c, Jump_002_6479

Jump_002_6309:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0e4
	call Call_02_6A80
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
	ld a, [$c0e5]
	cp $60
	call z, Call_02_6A25
	ld a, [$c0e5]
	or a
	call z, Call_02_6A43
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ea
	call Call_02_6A80
	ld a, [$c0fd]
	cp $20
	jp c, Jump_002_6479

Jump_002_6354:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0f0
	call Call_02_6A80
	ld a, [$c0f1]
	sub $02
	ld [$c0f1], a
	ld a, [$c0f2]
	add $02
	ld [$c0f2], a
	ld a, [$c0f1]
	cp $70
	call z, Call_02_6A31
	ld a, [$c0f1]
	cp $30
	call z, Call_02_6A4F
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0f6
	call Call_02_6A80
	ld a, [$c0fd]
	cp $30
	jp c, Jump_002_6479

Jump_002_63a0:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	sub $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $10
	call z, Call_02_6A19
	ld a, [$c0d9]
	or a
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld a, [$c0fd]
	cp $50
	jp c, Jump_002_6479

Jump_002_63eb:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0e4
	call Call_02_6A80
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
	ld a, [$c0e5]
	cp $70
	call z, Call_02_6A25
	ld a, [$c0e5]
	cp $30
	call z, Call_02_6A43
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ea
	call Call_02_6A80
	ld a, [$c0fd]
	cp $60
	jr c, jr_002_6479

	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0f0
	call Call_02_6A80
	ld a, [$c0f1]
	sub $02
	ld [$c0f1], a
	ld a, [$c0f2]
	add $02
	ld [$c0f2], a
	ld a, [$c0e5]
	cp $20
	call z, Call_02_6A31
	ld a, [$c0f1]
	or a
	call z, Call_02_6A4F
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0f6
	call Call_02_6A80

Jump_002_6479:
jr_002_6479:
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $b4
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_648C::
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $aa
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_649F::
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
	ret nz

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_64CC::
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
	cp $0f
	ret nz

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_695C
	ld hl, $c0e4
	call Call_02_6937
	call Call_02_6A43
	call Call_02_6A13
	ret


Jump_02_650D::
	ld a, [$c0fd]
	cp $30
	ld hl, $c0d8
	call z, Call_02_68C6
	ld a, [$c0fd]
	cp $40
	ld hl, $c0e4
	call z, Call_02_68A1
	ld a, [$c0fd]
	cp $30
	call z, Call_02_6A37
	ld a, [$c0fd]
	cp $40
	call z, Call_02_6A43
	ld a, [$c0fd]
	cp $30
	ld hl, $c0de
	call z, Call_02_6924
	ld a, [$c0fd]
	cp $40
	ld hl, $c0ea
	call z, Call_02_6911
	ld a, [$c0fd]
	cp $10
	call z, Call_02_6A1F
	ld a, [$c0fd]
	cp $30
	call z, Call_02_6A13
	ld a, [$c0fd]
	cp $40
	call z, Call_02_6A1F
	ld a, [$c0fd]
	cp $40
	jp nc, Jump_002_6604

	cp $30
	jr nc, jr_002_65b9

	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $22
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	add $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $90
	call z, Call_02_6A19
	ld a, [$c0d9]
	cp $b0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $22
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld a, [$c0fd]
	cp $10
	jp c, Jump_002_6692

jr_002_65b9:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0e4
	call Call_02_6A80
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
	ld a, [$c0e5]
	cp $10
	call z, Call_02_6A25
	ld a, [$c0e5]
	or a
	call z, Call_02_6A43
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ea
	call Call_02_6A80
	ld a, [$c0fd]
	cp $30
	jp c, Jump_002_6692

Jump_002_6604:
	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $22
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0d9]
	add $02
	ld [$c0d9], a
	ld a, [$c0da]
	add $02
	ld [$c0da], a
	ld a, [$c0d9]
	cp $80
	call z, Call_02_6A19
	ld a, [$c0d9]
	cp $b0
	call z, Call_02_6A37
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $22
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld a, [$c0fd]
	cp $40
	jr c, jr_002_6692

	ld a, $00
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0e4
	call Call_02_6A80
	ld a, [$c0e5]
	sub $02
	ld [$c0e5], a
	ld a, [$c0e6]
	add $02
	ld [$c0e6], a
	ld a, [$c0e5]
	cp $20
	call z, Call_02_6A25
	ld a, [$c0e5]
	or a
	call z, Call_02_6A43
	ld a, $01
	ldh [$ffc7], a
	ld a, $74
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ea
	call Call_02_6A80

Jump_002_6692:
jr_002_6692:
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $b4
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $c0d8
	call Call_02_69A6
	ret


Jump_02_66AB::
	ld a, [$c0de]
	or a
	jr nz, jr_002_66df

	ld a, $05
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0de
	call Call_02_6A80
	ld a, [$c0e0]
	sub $02
	ld [$c0e0], a
	ld a, [$c0fd]
	cp $14
	jr nz, jr_002_66d5

	call Call_02_6A31

jr_002_66d5:
	ld a, [$c0e0]
	cp $f0
	jr c, jr_002_66df

	call Call_02_6A3D

jr_002_66df:
	ld a, [$c0f6]
	or a
	jr nz, jr_002_6713

	ld a, $05
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0f6
	call Call_02_6A80
	ld a, [$c0f8]
	sub $02
	ld [$c0f8], a
	ld a, [$c0fd]
	cp $28
	jr nz, jr_002_6709

	call Call_02_6A25

jr_002_6709:
	ld a, [$c0f8]
	cp $f0
	jr c, jr_002_6713

	call Call_02_6A55

jr_002_6713:
	ld a, [$c0ea]
	or a
	jr nz, jr_002_6747

	ld a, $05
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0ea
	call Call_02_6A80
	ld a, [$c0ec]
	sub $02
	ld [$c0ec], a
	ld a, [$c0fd]
	cp $3c
	jr nz, jr_002_673d

	call Call_02_6A1F

jr_002_673d:
	ld a, [$c0ec]
	cp $f0
	jr c, jr_002_6747

	call Call_02_6A49

jr_002_6747:
	ld a, [$c0e4]
	or a
	jr nz, jr_002_677b

	ld a, $05
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0e4
	call Call_02_6A80
	ld a, [$c0e6]
	sub $02
	ld [$c0e6], a
	ld a, [$c0fd]
	cp $50
	jr nz, jr_002_6771

	call Call_02_6A2B

jr_002_6771:
	ld a, [$c0e6]
	cp $f0
	jr c, jr_002_677b

	call Call_02_6A43

jr_002_677b:
	ld a, [$c0f0]
	or a
	jr nz, jr_002_67af

	ld a, $05
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0f0
	call Call_02_6A80
	ld a, [$c0f2]
	sub $02
	ld [$c0f2], a
	ld a, [$c0fd]
	cp $64
	jr nz, jr_002_67a5

	call Call_02_6A13

jr_002_67a5:
	ld a, [$c0f2]
	cp $f0
	jr c, jr_002_67af

	call Call_02_6A4F

jr_002_67af:
	ld a, [$c0d8]
	or a
	jr nz, jr_002_67d9

	ld a, $05
	ldh [$ffc7], a
	ld a, $70
	ldh [$ffc9], a
	ld a, $02
	ldh [$ffca], a
	ld hl, $c0d8
	call Call_02_6A80
	ld a, [$c0da]
	sub $02
	ld [$c0da], a
	ld a, [$c0da]
	cp $f0
	jr c, jr_002_67d9

	call Call_02_6A37

jr_002_67d9:
	ld hl, $c0fd
	inc [hl]
	ld a, [$c0fd]
	cp $b4
	ret c

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_67EC::
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
	cp $10
	ret nz

	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ld hl, $d9cb
	inc [hl]
	ret


Jump_02_681F::
	ld hl, $c0fd
	inc [hl]
	ld a, $00
	ld [$c89b], a
	ld a, $ff
	ld [$c89c], a
	ld a, [$c0fd]
	cp $06
	ret c

	ld a, $c1
	ld [$c89b], a
	ld a, $d2
	ld [$c89c], a
	ld a, [$c0fd]
	cp $0c
	ret c

	ld a, $00
	ld [$c89b], a
	ld a, $ff
	ld [$c89c], a
	ld a, [$c0fd]
	cp $12
	ret c

	ld a, $c1
	ld [$c89b], a
	ld a, $d2
	ld [$c89c], a
	ld a, [$c0fd]
	cp $18
	ret c

	ld a, $00
	ld [$c89b], a
	ld a, $ff
	ld [$c89c], a
	ld a, [$c0fd]
	cp $1e
	ret c

	ld a, $c1
	ld [$c89b], a
	ld a, $d2
	ld [$c89c], a
	xor a
	ld [$c0fd], a
	ld hl, $c0fc
	inc [hl]
	ret


Jump_02_6886::
	xor a
	ld [$c0fc], a
	xor a
	ld [$c0d8], a
	ld a, $03
	call Call_1688
	ld hl, $c88f
	inc [hl]
	xor a
	ld [$d9cb], a
	ld a, $08
	ld [$d951], a
	ret


Call_02_68A1::
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


Call_02_68C6::
	ld a, $00
	ld [hli], a
	ld a, $20
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


Call_02_68EB::
	ld a, $01
	ld [hli], a
	ld a, $70
	ld [hli], a
	ld a, $10
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


	db $3e, $01, $22, $3e, $30, $22, $3e, $10, $22, $3e, $00, $22, $3e, $00, $22, $3e
	db $02, $22, $c9

Call_02_6911::
	ld a, $01
	ld [hli], a
	ld a, $30
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


Call_02_6924::
	ld a, $01
	ld [hli], a
	ld a, $70
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


Call_02_6937::
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


Call_02_695C::
	ld a, $00
	ld [hli], a
	ld a, $60
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
	ld a, $80
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


Call_02_6981::
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


Call_02_69A6::
	ld a, $01
	ld [hli], a
	ld a, $08
	ld [hli], a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $18
	ld [hli], a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $28
	ld [hli], a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $78
	ld [hli], a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $88
	ld [hli], a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


Call_02_6A13::
	ld a, $00
	ld [$c0d8], a
	ret


Call_02_6A19::
	ld a, $00
	ld [$c0de], a
	ret


Call_02_6A1F::
	ld a, $00
	ld [$c0e4], a
	ret


Call_02_6A25::
	ld a, $00
	ld [$c0ea], a
	ret


Call_02_6A2B::
	ld a, $00
	ld [$c0f0], a
	ret


Call_02_6A31::
	ld a, $00
	ld [$c0f6], a
	ret


Call_02_6A37::
	ld a, $01
	ld [$c0d8], a
	ret


Call_02_6A3D::
	ld a, $01
	ld [$c0de], a
	ret


Call_02_6A43::
	ld a, $01
	ld [$c0e4], a
	ret


Call_02_6A49::
	ld a, $01
	ld [$c0ea], a
	ret


Call_02_6A4F::
	ld a, $01
	ld [$c0f0], a
	ret


Call_02_6A55::
	ld a, $01
	ld [$c0f6], a
	ret


Call_02_6A5B::
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, Call_02_6A5B

	ret


Call_02_6A65::
	ld de, $6a6c
	call Call_0D91
	ret


	db $4c, $6b, $a9, $6c, $e2, $6d, $e2, $6d, $e2, $6d, $4c, $6b

	ld a, [$c0fc]
	ld l, a
	ld a, [$c0fd]
	ld h, a

Call_02_6A80::
	ld a, l
	ld [$c0fe], a
	ld a, h
	ld [$c0ff], a
	ld a, [hli]
	or a
	ret nz

	xor a
	ldh [$ffc4], a
	ldh [$ffc6], a
	ldh [$ffd3], a
	ld a, [hli]
	ldh [$ffc3], a
	ld a, [hli]
	ldh [$ffc5], a
	ld a, [hli]
	ldh [$ffc8], a
	call Call_02_6A65
	ld a, [$c0fe]
	ld l, a
	ld a, [$c0ff]
	ld h, a
	ld a, $05
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, l
	ld d, h
	ld a, [de]
	dec a
	ld [de], a
	or a
	ret nz

	dec de
	ld a, [de]
	inc a
	ld [de], a
	ld hl, $4e17
	ldh a, [$ffc7]
	call Call_02_6AFF
	ld a, [de]
	dec de
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_002_6ada

	cp $fe
	jr z, jr_002_6ae6

	ld a, [hli]
	ld [de], a
	inc de
	inc de
	ld a, [hl]
	ld [de], a
	ret


jr_002_6ada:
	ld a, [$c0fe]
	ld l, a
	ld a, [$c0ff]
	ld h, a
	ld a, $01
	ld [hl], a
	ret


jr_002_6ae6:
	ld hl, $4e17
	ldh a, [$ffc7]
	call Call_02_6AFF
	xor a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ret


Call_02_6AFF::
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


Call_02_6B0A::
	ld a, [$d7b4]
	ld c, a
	ld a, [$d7b5]
	ld b, a
	ld hl, $40e3
	ld a, [bc]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc bc
	ld a, [bc]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc bc
	ld a, [bc]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ldh [$ffc8], a
	ret


	db $f8, $f8, $00, $00, $f7, $00, $01, $00, $80, $f0, $f8, $02, $00, $f8, $f8, $03
	db $00, $80, $80, $39, $6b, $42, $6b, $4b, $6b, $e8, $18, $02, $00, $f8, $18, $02
	db $00, $f0, $10, $00, $00, $08, $10, $02, $00, $f4, $18, $02, $00, $f6, $1d, $02
	db $00, $ff, $15, $02, $00, $f0, $08, $02, $00, $10, $00, $02, $00, $00, $08, $01
	db $00, $00, $02, $01, $00, $08, $08, $02, $00, $0c, $04, $02, $00, $18, $08, $01
	db $00, $00, $f8, $02, $00, $10, $f0, $01, $00, $20, $f0, $02, $00, $16, $f3, $02
	db $00, $2b, $f2, $02, $00, $0c, $f4, $00, $00, $07, $f0, $02, $00, $1d, $f8, $01
	db $00, $f8, $00, $01, $00, $80, $f8, $18, $02, $00, $08, $18, $02, $00, $18, $10
	db $02, $00, $04, $18, $02, $00, $06, $1d, $02, $00, $0f, $15, $02, $00, $00, $08
	db $02, $00, $20, $00, $02, $00, $10, $08, $01, $00, $10, $02, $01, $00, $18, $08
	db $02, $00, $1c, $04, $02, $00, $28, $08, $01, $00, $10, $f8, $02, $00, $20, $f0
	db $01, $00, $30, $f0, $02, $00, $26, $f3, $02, $00, $3b, $f2, $02, $00, $17, $f0
	db $02, $00, $2d, $f8, $01, $00, $08, $00, $01, $00, $1c, $f4, $01, $00, $00, $10
	db $01, $00, $80, $08, $18, $02, $00, $28, $10, $02, $00, $14, $18, $02, $00, $16
	db $1d, $02, $00, $10, $08, $02, $00, $30, $00, $02, $00, $20, $08, $01, $00, $20
	db $02, $01, $00, $28, $08, $02, $00, $38, $08, $01, $00, $20, $f8, $02, $00, $30
	db $f0, $01, $00, $40, $f0, $02, $00, $36, $f3, $02, $00, $4b, $f2, $02, $00, $27
	db $f0, $02, $00, $3d, $f8, $01, $00, $2c, $f4, $01, $00, $80, $38, $10, $02, $00
	db $24, $18, $02, $00, $20, $08, $02, $00, $40, $00, $02, $00, $30, $08, $01, $00
	db $48, $08, $01, $00, $30, $f8, $02, $00, $50, $f0, $02, $00, $5b, $f2, $02, $00
	db $37, $f0, $02, $00, $4d, $f8, $01, $00, $80, $50, $00, $02, $00, $58, $08, $01
	db $00, $40, $f8, $02, $00, $60, $f0, $02, $00, $6b, $f2, $02, $00, $47, $f0, $02
	db $00, $5d, $f8, $01, $00, $80, $73, $f2, $02, $00, $65, $f8, $01, $00, $80, $80
	db $52, $6b, $af, $6b, $0c, $6c, $55, $6c, $82, $6c, $9f, $6c, $a8, $6c, $f0, $f0
	db $03, $00, $f0, $f8, $04, $00, $f8, $e8, $05, $00, $f8, $f0, $06, $00, $f8, $f8
	db $07, $00, $f0, $08, $03, $20, $f0, $00, $04, $20, $f8, $10, $05, $20, $f8, $08
	db $06, $20, $f8, $00, $07, $20, $80, $f0, $e8, $08, $00, $f0, $f0, $09, $00, $f0
	db $f8, $0a, $00, $f8, $e0, $0b, $00, $f8, $e8, $0c, $00, $f8, $f0, $07, $00, $f8
	db $f8, $07, $00, $f0, $10, $08, $20, $f0, $08, $09, $20, $f0, $00, $0a, $20, $f8
	db $18, $0b, $20, $f8, $10, $0c, $20, $f8, $08, $07, $20, $f8, $00, $07, $20, $80
	db $e0, $f0, $00, $00, $f0, $10, $00, $00, $f0, $e0, $00, $00, $e4, $d8, $00, $00
	db $ea, $07, $00, $00, $e8, $18, $00, $00, $e0, $f8, $01, $00, $e0, $08, $01, $00
	db $f8, $e8, $01, $00, $f8, $10, $01, $00, $80, $e0, $08, $01, $00, $f8, $10, $01
	db $00, $d8, $cd, $00, $00, $d6, $07, $00, $00, $ce, $f5, $01, $00, $f0, $25, $00
	db $00, $f7, $d5, $01, $00, $de, $f8, $00, $00, $ee, $e7, $02, $00, $e3, $df, $02
	db $00, $d7, $ee, $02, $00, $e4, $15, $02, $00, $e3, $24, $02, $00, $80, $d3, $c4
	db $00, $00, $c4, $ec, $01, $00, $f2, $cc, $01, $00, $d4, $ef, $00, $00, $e9, $de
	db $02, $00, $de, $d6, $02, $00, $cd, $e5, $02, $00, $cd, $0d, $01, $00, $ea, $15
	db $01, $00, $c3, $0c, $00, $00, $e2, $2a, $00, $00, $d6, $1a, $02, $00, $d0, $29
	db $02, $00, $80, $e9, $b6, $00, $00, $da, $de, $01, $00, $08, $be, $01, $00, $ea
	db $e1, $00, $00, $ff, $d0, $02, $00, $f4, $c8, $02, $00, $e3, $d7, $02, $00, $e6
	db $1a, $01, $00, $03, $22, $01, $00, $dc, $19, $00, $00, $fb, $37, $00, $00, $ef
	db $27, $02, $00, $e9, $36, $02, $00, $80, $80, $b7, $6c, $e0, $6c, $19, $6d, $42
	db $6d, $77, $6d, $ac, $6d, $e1, $6d, $00, $00, $0e, $1e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $1e, $0e, $0e, $0e, $0e, $1a, $0e, $d8, $0e, $0e
	db $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $18, $0e, $d8, $0e, $0e, $18, $0e, $0e, $18, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e
	db $1e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $d8, $0e, $1a, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $d8, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20
	db $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1c, $0e, $0e
	db $0e, $0e, $0e, $0e, $18, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e, $0e, $d8
	db $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1a, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $d8, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $1c, $0e, $d8, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $20, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e
	db $0e, $0e, $1e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $1a, $0e, $d8, $0e, $1a, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $0e
	db $0e, $18, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $d8, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $d8, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $d8, $0e, $1e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $20, $0e, $18, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e
	db $d8, $0e, $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $18, $0e, $0e
	db $0e, $0c, $0d, $0e, $0e, $0e, $0e, $0c, $0d, $0e, $0e, $1c, $0e, $0e, $1e, $d8
	db $0e, $0e, $0e, $0e, $0e, $04, $10, $11, $06, $07, $0a, $0b, $10, $11, $05, $0e
	db $0e, $0e, $0e, $0e, $d8, $1c, $0e, $0c, $0d, $0c, $03, $14, $15, $08, $09, $14
	db $15, $14, $15, $02, $0d, $0c, $0d, $0e, $0e, $d8, $0e, $04, $10, $11, $10, $13
	db $16, $17, $16, $17, $16, $17, $16, $17, $12, $11, $10, $11, $05, $0e, $d8, $0c
	db $03, $14, $15, $14, $15, $14, $15, $14, $15, $14, $15, $14, $15, $14, $15, $14
	db $15, $02, $01, $d8, $12, $13, $16, $17, $16, $17, $16, $17, $16, $17, $16, $17
	db $16, $17, $16, $17, $16, $17, $12, $11, $d9, $00, $00, $0e, $1e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $1e, $0e, $0e, $0e, $0e, $1a, $0e, $d8
	db $0e, $0e, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $d8, $0e, $0e, $18, $0e, $0e, $18
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $18
	db $0e, $0e, $1e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $1a
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $d8, $0e, $1a
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $20, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1c
	db $0e, $0e, $0e, $0e, $0e, $0e, $18, $0e, $0e, $1a, $0e, $0e, $0e, $0e, $18, $0e
	db $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $1c, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $d8, $0e, $0e, $1a, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $18, $0e, $0e, $0e, $0e, $0e
	db $d8, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $20, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $1c, $0e, $d8, $0e, $0e, $0e, $0e, $18, $0e, $0e, $22, $23, $24
	db $2b, $2c, $2d, $0e, $0e, $0e, $20, $0e, $0e, $0e, $d8, $0e, $0e, $0e, $0e, $0e
	db $0e, $25, $26, $27, $2a, $2a, $2e, $2f, $30, $0e, $0e, $0e, $0e, $0e, $0e, $d8
	db $0e, $0e, $0e, $0e, $1e, $28, $29, $2a, $2a, $2a, $2a, $2a, $2a, $31, $32, $0e
	db $0e, $0e, $1a, $0e, $d9, $00, $00, $05, $05, $05, $05, $05, $05, $05, $05, $05
	db $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $d8, $05, $05, $05, $05
	db $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05
	db $d8, $14, $15, $15, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $14
	db $15, $15, $16, $17, $4f, $d8, $10, $11, $12, $13, $14, $15, $16, $17, $10, $11
	db $12, $13, $14, $15, $16, $17, $25, $26, $27, $5f, $d8, $20, $21, $22, $23, $24
	db $25, $26, $27, $20, $21, $22, $23, $24, $25, $26, $27, $73, $74, $75, $76, $d8
	db $02, $03, $08, $09, $0a, $0b, $05, $04, $05, $05, $05, $05, $05, $8d, $8e, $8f
	db $83, $84, $85, $36, $d8, $05, $05, $18, $19, $1a, $1b, $05, $05, $05, $92, $93
	db $05, $05, $9d, $9e, $9f, $2e, $2f, $05, $05, $d8, $05, $37, $05, $29, $2a, $2b
	db $05, $2d, $05, $a2, $a3, $05, $05, $ad, $ae, $af, $3e, $39, $05, $05, $d8, $05
	db $05, $05, $05, $3a, $3b, $05, $3d, $05, $05, $05, $05, $05, $05, $8b, $8c, $3f
	db $05, $05, $05, $d8, $39, $05, $05, $05, $0c, $0d, $05, $90, $05, $05, $05, $05
	db $05, $05, $0b, $9c, $05, $05, $05, $37, $d8, $05, $05, $38, $05, $1c, $1d, $05
	db $a0, $05, $05, $05, $90, $05, $58, $1b, $ac, $05, $05, $05, $05, $d8, $47, $48
	db $49, $48, $42, $43, $05, $05, $05, $05, $05, $a0, $05, $68, $89, $8a, $05, $05
	db $05, $05, $d8, $06, $07, $05, $05, $05, $86, $87, $88, $05, $05, $05, $05, $05
	db $33, $34, $35, $05, $36, $05, $05, $d8, $05, $05, $05, $05, $05, $05, $05, $4f
	db $05, $05, $05, $05, $05, $05, $44, $45, $46, $05, $05, $38, $d8, $11, $12, $13
	db $14, $15, $16, $17, $5f, $05, $05, $90, $05, $05, $05, $54, $05, $56, $05, $05
	db $05, $d8, $21, $22, $23, $24, $25, $26, $27, $05, $05, $05, $a0, $05, $05, $05
	db $64, $2c, $66, $05, $05, $05, $d8, $03, $08, $09, $0a, $0b, $05, $3d, $05, $05
	db $05, $05, $05, $05, $05, $05, $4a, $3e, $39, $05, $05, $d8, $05, $18, $19, $1a
	db $1b, $05, $05, $05, $05, $05, $05, $05, $05, $58, $05, $5a, $5b, $05, $05, $05
	db $d8, $37, $05, $29, $2a, $2b, $52, $05, $05, $05, $90, $05, $05, $05, $68, $05
	db $6a, $6b, $05, $05, $05, $d8, $05, $05, $05, $3a, $3b, $9d, $05, $05, $05, $a0
	db $05, $05, $05, $05, $79, $7a, $7b, $05, $37, $05, $d8, $05, $05, $05, $0c, $0d
	db $ad, $05, $05, $05, $05, $05, $05, $05, $05, $33, $34, $35, $05, $05, $05, $d8
	db $05, $05, $38, $1c, $1d, $05, $05, $05, $05, $05, $05, $05, $05, $90, $05, $44
	db $45, $46, $05, $05, $d8, $05, $05, $05, $30, $31, $05, $05, $05, $05, $05, $05
	db $05, $05, $a0, $05, $54, $05, $56, $05, $05, $d8, $38, $05, $05, $40, $41, $05
	db $90, $05, $05, $05, $05, $05, $05, $05, $05, $64, $65, $66, $05, $39, $d8, $05
	db $05, $05, $50, $51, $52, $a0, $05, $05, $05, $05, $05, $05, $05, $05, $52, $4d
	db $4e, $05, $05, $d8, $05, $39, $05, $60, $61, $62, $05, $05, $05, $05, $05, $05
	db $05, $05, $05, $62, $5d, $5e, $05, $05, $d8, $05, $05, $05, $70, $71, $72, $0f
	db $52, $05, $05, $05, $05, $05, $0f, $05, $72, $6d, $6e, $6f, $05, $d8, $05, $05
	db $00, $80, $81, $82, $1f, $62, $05, $05, $05, $05, $05, $1f, $05, $82, $7d, $7e
	db $7f, $05, $d8, $0e, $1e, $0e, $28, $01, $32, $55, $0e, $0e, $1e, $0e, $1e, $0e
	db $32, $1e, $55, $0e, $55, $0e, $1e, $d8, $01, $01, $96, $97, $98, $99, $a6, $a7
	db $a8, $a9, $aa, $01, $01, $01, $01, $01, $01, $96, $97, $98, $d8, $98, $99, $a6
	db $9a, $9b, $ab, $01, $01, $01, $01, $01, $96, $97, $98, $99, $a6, $a7, $01, $9a
	db $9b, $d8, $9b, $ab, $01, $a8, $a9, $aa, $96, $97, $98, $99, $a6, $a7, $9a, $9b
	db $ab, $01, $01, $a8, $a9, $aa, $d9, $00, $00, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $09, $0a, $0b, $07, $08, $02, $02, $07, $08, $d8, $02, $07
	db $08, $02, $09, $0a, $0b, $07, $08, $02, $02, $02, $02, $02, $02, $02, $02, $09
	db $0a, $0b, $d8, $0a, $0b, $07, $08, $02, $02, $09, $0a, $0b, $09, $0a, $0b, $07
	db $08, $07, $08, $09, $0c, $0d, $5a, $d8, $13, $14, $15, $16, $0c, $0d, $10, $11
	db $12, $10, $11, $12, $0c, $0d, $4c, $4d, $7c, $7d, $7e, $7f, $d8, $23, $24, $25
	db $26, $0e, $0f, $20, $21, $22, $20, $21, $22, $43, $44, $45, $46, $8c, $8d, $8e
	db $8f, $d8, $33, $34, $35, $36, $30, $31, $32, $01, $01, $01, $01, $01, $53, $54
	db $55, $56, $82, $83, $84, $d8, $b0, $b0, $17, $18, $40, $41, $42, $01, $01, $05
	db $06, $01, $01, $64, $65, $66, $92, $93, $d8, $b0, $b0, $27, $28, $50, $51, $52
	db $01, $01, $01, $01, $01, $01, $74, $75, $76, $a7, $d8, $b0, $b0, $b0, $b0, $60
	db $61, $62, $01, $01, $01, $01, $01, $01, $5b, $70, $71, $a8, $1a, $1b, $19, $d8
	db $19, $1a, $1b, $1c, $1d, $1e, $1f, $04, $01, $01, $01, $01, $01, $01, $80, $81
	db $a9, $2a, $2b, $29, $d8, $29, $2a, $2b, $2c, $2d, $2e, $2f, $01, $01, $01, $01
	db $04, $01, $9d, $9e, $9f, $d8, $37, $38, $37, $38, $39, $3a, $01, $01, $01, $01
	db $01, $5b, $5c, $5d, $5e, $5f, $19, $1a, $1b, $1c, $d8, $02, $02, $02, $02, $02
	db $3b, $3c, $3d, $01, $01, $6a, $6b, $6c, $6d, $6e, $6f, $29, $2a, $2b, $2c, $d8
	db $0b, $07, $08, $02, $02, $09, $08, $3f, $01, $01, $01, $01, $01, $01, $85, $86
	db $63, $d8, $14, $15, $16, $0c, $0d, $10, $3e, $4f, $01, $01, $04, $01, $01, $04
	db $95, $96, $73, $d8, $24, $25, $26, $0e, $0f, $20, $4e, $01, $01, $01, $01, $01
	db $01, $01, $a5, $a6, $72, $d8, $34, $35, $36, $30, $31, $32, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $90, $91, $d8, $b0, $17, $18, $40, $41, $42, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $a0, $a1, $d8, $b0, $27, $28, $50, $51, $52
	db $01, $01, $01, $04, $01, $01, $01, $01, $9d, $9e, $9f, $d8, $b0, $b0, $b0, $60
	db $61, $62, $01, $01, $01, $01, $01, $01, $5b, $5c, $5d, $5e, $5f, $1a, $1b, $1c
	db $d8, $19, $1b, $1c, $1d, $1e, $1f, $01, $01, $01, $01, $01, $6a, $6b, $6c, $6d
	db $6e, $6f, $2a, $2b, $2c, $d8, $29, $2b, $2c, $2d, $2e, $2f, $01, $01, $01, $01
	db $01, $01, $01, $04, $01, $85, $86, $63, $d8, $b0, $b0, $b0, $48, $49, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $95, $96, $73, $d8, $b0, $b0, $b0, $58
	db $59, $01, $04, $01, $01, $01, $01, $01, $01, $01, $01, $a5, $a6, $72, $d8, $b0
	db $b0, $b0, $68, $69, $47, $01, $01, $01, $01, $01, $01, $01, $5b, $5c, $5d, $5e
	db $5f, $1a, $1b, $d8, $b0, $b0, $b0, $78, $79, $57, $01, $01, $01, $47, $01, $01
	db $47, $01, $01, $6d, $6e, $6f, $2a, $2b, $d8, $b0, $b0, $b0, $88, $89, $67, $47
	db $7b, $47, $57, $01, $01, $57, $01, $01, $7b, $9a, $9b, $d8, $b0, $b0, $87, $98
	db $99, $77, $57, $8b, $57, $67, $47, $01, $67, $47, $01, $8b, $aa, $ab, $ac, $d8
	db $a2, $a3, $a4, $4a, $4b, $5d, $4b, $4a, $4b, $5d, $4a, $9c, $4b, $4a, $9c, $5d
	db $4a, $4b, $94, $a2, $d8, $03, $7a, $ae, $af, $03, $03, $03, $03, $03, $03, $7a
	db $8a, $ae, $7a, $03, $03, $03, $03, $03, $03, $d8, $03, $03, $03, $03, $03, $7a
	db $8a, $ad, $ae, $af, $03, $03, $03, $03, $7a, $8a, $ad, $ae, $af, $03, $d8, $7a
	db $8a, $ad, $ae, $af, $03, $03, $03, $03, $7a, $8a, $ad, $ae, $af, $03, $03, $03
	db $03, $03, $7a, $d9, $02, $c0, $81, $82, $83, $84, $85, $a6, $80, $fe, $52, $c9
	db $8a, $8b, $ac, $fe, $62, $cd, $8e, $8f, $b0, $fe, $82, $c7, $88, $91, $b2, $ff
	db $20, $02, $e0, $ff, $55, $77, $6c, $77, $8b, $77, $a6, $77, $27, $23, $c6, $85
	db $84, $83, $82, $a1, $fe, $25, $cc, $8b, $8a, $89, $88, $a7, $fe, $77, $ed, $fe
	db $72, $e0, $ff, $20, $02, $c0, $81, $82, $83, $84, $85, $92, $b3, $fe, $32, $c6
	db $87, $88, $89, $aa, $fe, $62, $cb, $8c, $8d, $8e, $af, $fe, $92, $f0, $fe, $b2
	db $f1, $ff, $22, $22, $c0, $81, $82, $83, $84, $80, $85, $80, $80, $86, $87, $88
	db $89, $ea, $fe, $52, $cb, $8c, $ad, $fe, $82, $ce, $8f, $b0, $ff, $22, $22, $c0
	db $e1, $ff, $b3, $77, $c2, $77, $e1, $77, $f9, $77, $20, $02, $c0, $81, $82, $83
	db $84, $a5, $fe, $22, $c6, $87, $88, $a9, $ff, $20, $02, $c0, $81, $82, $83, $84
	db $85, $86, $87, $88, $89, $8a, $eb, $fe, $32, $ce, $8f, $90, $b1, $fe, $52, $cc
	db $ad, $fe, $72, $f2, $fe, $92, $f3, $ff, $20, $02, $c0, $a1, $fe, $22, $c4, $85
	db $86, $87, $a8, $fe, $42, $e9, $fe, $62, $e2, $fe, $a2, $ea, $fe, $82, $e3, $ff
	db $20, $02, $c0, $81, $a2, $ff, $0b, $78, $11, $78, $1b, $78, $3c, $78, $55, $78
	db $62, $78, $20, $02, $c0, $a1, $c0, $ff, $20, $02, $e0, $fe, $12, $e1, $fe, $f2
	db $e1, $ff, $20, $02, $80, $80, $86, $86, $80, $81, $81, $86, $80, $81, $81, $86
	db $86, $82, $ff, $02, $86, $81, $80, $82, $83, $80, $86, $86, $81, $80, $86, $80
	db $84, $a5, $ff, $20, $02, $c0, $81, $82, $83, $84, $e5, $fe, $21, $e6, $c6, $a7
	db $e7, $fe, $42, $e8, $fe, $62, $c9, $ea, $fe, $82, $eb, $ff, $20, $02, $c0, $c1
	db $c2, $c1, $c2, $c2, $c1, $c1, $c1, $e1, $ff, $20, $02, $e0, $ff, $2f, $f2, $c0
	db $81, $82, $83, $84, $a5, $ff, $79, $78, $79, $78, $99, $78, $d2, $78, $33, $79
	db $81, $78, $81, $78, $81, $78, $8c, $78, $22, $00, $3c, $03, $02, $13, $08, $00
	db $06, $03, $ff, $22, $00, $0f, $01, $2d, $03, $02, $13, $08, $00, $06, $03, $ff
	db $a1, $78, $b6, $78, $c1, $78, $c1, $78, $16, $00, $08, $03, $01, $23, $01, $63
	db $01, $a3, $01, $e3, $21, $03, $04, $00, $17, $03, $02, $13, $ff, $16, $00, $3b
	db $03, $02, $00, $0b, $03, $02, $13, $ff, $16, $00, $04, $03, $03, $83, $20, $03
	db $01, $40, $1c, $00, $04, $03, $02, $13, $ff, $da, $78, $f1, $78, $06, $79, $06
	db $79, $0a, $00, $03, $03, $05, $00, $0d, $03, $07, $00, $02, $03, $1c, $00, $12
	db $03, $04, $00, $04, $03, $02, $13, $ff, $1f, $03, $07, $00, $02, $03, $1c, $00
	db $12, $03, $04, $00, $04, $03, $02, $13, $5a, $00, $04, $20, $ff, $0a, $00, $03
	db $03, $05, $00, $0d, $03, $07, $00, $02, $03, $17, $00, $05, $03, $01, $02, $07
	db $03, $01, $02, $01, $03, $01, $02, $04, $03, $01, $83, $01, $82, $09, $03, $02
	db $13, $46, $00, $01, $22, $01, $00, $01, $22, $ff, $3f, $79, $3f, $79, $3f, $79
	db $4e, $79, $4e, $79, $4e, $79, $22, $00, $1e, $03, $0d, $00, $11, $03, $02, $13
	db $2e, $00, $01, $03, $ff, $0b, $03, $48, $00, $0b, $03, $02, $13, $10, $03, $ff
	db $26, $c0, $16, $17, $af, $2e, $20, $1e, $50, $22, $1d, $20, $fc, $24, $15, $20
	db $f4, $11, $20, $c0, $21, $c9, $69, $cd, $b6, $04, $2a, $fe, $80, $c8, $cb, $7f
	db $28, $22, $cb, $bf, $cb, $77, $20, $04, $47, $af, $18, $0b, $cb, $b7, $47, $cb
	db $a0, $cb, $a8, $e6, $30, $cb, $c7, $e0, $d8, $f0, $d8, $cd, $a3, $79, $d8, $05
	db $20, $f7, $18, $d6, $cd, $a3, $79, $d8, $18, $d0, $12, $1c, $7b, $fe, $70, $3f
	db $d0, $1e, $20, $14, $7a, $fe, $d4, $3f, $c9, $cd, $43, $00, $bf, $79, $d7, $79
	db $f2, $79, $07, $7a, $ae, $08, $d7, $c0, $3e, $30, $cd, $d6, $05, $d0, $01, $ed
	db $79, $cd, $be, $02, $cd, $83, $06, $ff, $01, $00, $fc, $c3, $64, $05, $cd, $1f
	db $7a, $01, $1a, $00, $cd, $8e, $05, $cd, $a2, $05, $c0, $3e, $60, $cd, $ce, $06
	db $ff, $c3, $c3, $05, $08, $61, $08, $62, $fe, $cd, $1f, $7a, $3e, $00, $cd, $a4
	db $06, $3e, $1b, $cc, $15, $05, $d7, $c0, $36, $60, $ff, $c3, $b4, $05, $cd, $1f
	db $7a, $01, $1a, $00, $cd, $8e, $05, $2e, $0f, $7e, $fe, $90, $d8, $36, $90, $cd
	db $c3, $05, $af, $c3, $d8, $07, $cd, $38, $08, $01, $ed, $79, $ca, $98, $02, $3e
	db $04, $01, $05, $63, $cd, $ee, $07, $c1, $c9, $cd, $43, $00, $3f, $7a, $77, $7a
	db $8e, $7a, $94, $7a, $ae, $08, $fa, $01, $cc, $fe, $02, $38, $03, $fe, $07, $d8
	db $3e, $38, $cd, $d6, $05, $d0, $01, $89, $7a, $cd, $be, $02, $cd, $83, $06, $3e
	db $3d, $cd, $15, $05, $ff, $01, $60, $ff, $cd, $52, $05, $01, $c0, $fc, $cd, $64
	db $05, $cd, $48, $06, $cd, $32, $06, $c8, $01, $00, $08, $c3, $ea, $05, $cd, $9d
	db $7a, $01, $16, $00, $cd, $8e, $05, $cd, $a2, $05, $c0, $3e, $20, $c3, $e6, $79
	db $08, $60, $08, $61, $fe, $cd, $9d, $7a, $c3, $ff, $79, $cd, $9d, $7a, $01, $16
	db $00, $c3, $8e, $05, $01, $89, $7a, $cd, $98, $02, $cd, $38, $08, $c8, $3e, $04
	db $01, $05, $62, $cd, $ee, $07, $c1, $c9, $1e, $00, $1a, $fe, $30, $ca, $bb, $7c
	db $fe, $35, $ca, $a3, $7e, $01, $00, $9a, $cd, $c8, $7b, $01, $07, $9a, $cd, $c8
	db $7b, $16, $cc, $01, $40, $7c, $cd, $be, $02, $2e, $07, $36, $a1, $cd, $84, $07
	db $01, $28, $01, $cd, $52, $05, $01, $48, $d4, $cd, $e2, $05, $14, $cd, $e2, $05
	db $2e, $00, $36, $69, $01, $37, $7c, $cd, $7e, $06, $cd, $84, $07, $15, $cd, $be
	db $7b, $01, $2f, $03, $c3, $96, $11, $1e, $00, $1a, $fe, $69, $ca, $11, $7c, $fe
	db $6a, $ca, $8d, $7c, $fe, $30, $ca, $de, $7c, $fe, $35, $ca, $a7, $7e, $cd, $ab
	db $7b, $cd, $98, $08, $cd, $de, $7b, $1e, $01, $1a, $c7, $2c, $7b, $32, $7b, $51
	db $7b, $90, $7b, $f7, $fe, $50, $d0, $ff, $c9, $cd, $32, $06, $01, $d0, $c8, $20
	db $03, $01, $d8, $d0, $f7, $b8, $d8, $b9, $d0, $cd, $38, $06, $cd, $32, $06, $c8
	db $fa, $86, $ca, $fe, $08, $d8, $ff, $c9, $f7, $fe, $f0, $d8, $ff, $01, $00, $b8
	db $cd, $fe, $05, $0e, $08, $14, $3e, $10, $df, $c5, $14, $cd, $e2, $05, $2e, $00
	db $36, $6a, $cd, $84, $07, $3e, $66, $e7, $3e, $91, $cd, $8f, $06, $7a, $d6, $ce
	db $21, $8a, $7b, $ef, $7e, $cd, $ce, $06, $c1, $7a, $fe, $d3, $38, $d8, $16, $cc
	db $c9, $30, $20, $10, $00, $10, $20, $f7, $fe, $c8, $d8, $fe, $d0, $d0, $cd, $26
	db $04, $af, $77, $ea, $96, $ca, $cd, $e4, $23, $01, $7e, $01, $cd, $96, $11, $c3
	db $30, $07, $fa, $82, $c9, $cb, $5f, $3e, $48, $28, $01, $3c, $1e, $0f, $12, $01
	db $40, $7c, $cd, $98, $02, $62, $3e, $34, $2e, $14, $96, $ea, $c3, $dd, $c9, $21
	db $45, $7c, $16, $0c, $1e, $06, $2a, $cd, $07, $0b, $0c, $1d, $20, $f8, $3e, $1a
	db $df, $15, $20, $f0, $c9, $21, $06, $c0, $cb, $46, $c8, $e5, $2c, $cb, $be, $cd
	db $6f, $03, $e1, $cb, $7e, $c8, $2c, $fa, $0f, $c0, $fe, $5c, $d0, $fa, $01, $c0
	db $fe, $03, $30, $08, $cb, $fe, $3e, $01, $ea, $c5, $ca, $c9, $fa, $07, $cc, $cb
	db $bf, $77, $3e, $01, $ea, $d2, $ca, $c9, $fa, $00, $cc, $a7, $ca, $33, $07, $cd
	db $6f, $03, $cd, $98, $08, $cd, $de, $7b, $26, $cc, $cd, $f7, $05, $cd, $e2, $05
	db $fa, $07, $cc, $cb, $bf, $cd, $8f, $06, $01, $37, $7c, $c3, $98, $02, $04, $62
	db $04, $65, $04, $64, $04, $63, $fe, $08, $60, $08, $61, $fe, $b7, $98, $99, $95
	db $96, $93, $9a, $9b, $9c, $92, $92, $97, $9d, $9e, $92, $92, $92, $94, $a6, $92
	db $92, $92, $b0, $af, $a9, $92, $92, $ae, $ad, $ac, $a5, $a8, $a7, $ab, $aa, $b9
	db $b7, $9f, $a0, $95, $96, $93, $a1, $a2, $a3, $92, $92, $97, $b8, $a4, $92, $92
	db $92, $94, $a6, $92, $92, $92, $b6, $ba, $a9, $92, $92, $b5, $b4, $b3, $a5, $a8
	db $a7, $b2, $b1, $b9, $1e, $01, $1a, $fe, $01, $28, $1d, $7a, $fe, $d1, $fa, $01
	db $d1, $c2, $d8, $07, $f7, $fe, $98, $dc, $e4, $23, $fa, $14, $cc, $fe, $a0, $d0
	db $26, $cc, $cd, $89, $03, $d0, $ff, $c9, $d7, $c0, $2e, $00, $36, $67, $af, $c3
	db $d8, $07, $3e, $6f, $e7, $cd, $86, $06, $cd, $88, $07, $62, $2e, $05, $36, $04
	db $3e, $0b, $ea, $c1, $c9, $cd, $98, $3f, $cd, $a3, $3f, $3e, $04, $ea, $c1, $c9
	db $3e, $20, $c3, $ce, $06, $cd, $12, $09, $cd, $98, $08, $cd, $2e, $7e, $1e, $01
	db $1a, $c7, $0f, $7d, $14, $7d, $32, $7d, $5b, $7d, $14, $7d, $32, $7d, $5b, $7d
	db $14, $7d, $32, $7d, $5b, $7d, $5b, $7d, $71, $13, $71, $13, $71, $13, $8c, $7d
	db $c1, $7d, $ce, $7d, $1c, $7e, $d7, $c0, $c3, $5f, $7e, $cd, $c9, $02, $01, $89
	db $7e, $cd, $b1, $06, $c0, $ff, $01, $2d, $7d, $cd, $be, $02, $3e, $4a, $cd, $15
	db $05, $c3, $b4, $05, $30, $6b, $04, $71, $ff, $cd, $c9, $02, $01, $2d, $7d, $cd
	db $98, $02, $01, $18, $00, $1e, $01, $1a, $fe, $08, $20, $02, $0e, $0e, $cd, $8e
	db $05, $01, $17, $00, $cd, $a9, $07, $c8, $ff, $cd, $c3, $05, $01, $89, $7e, $c3
	db $be, $02, $cd, $c9, $02, $01, $89, $7e, $cd, $b1, $06, $c0, $1e, $01, $1a, $fe
	db $09, $c2, $5f, $7e, $cd, $e8, $07, $3e, $0e, $cd, $d8, $07, $01, $83, $7d, $cd
	db $be, $02, $3e, $e0, $cd, $ce, $06, $c3, $c3, $05, $08, $6c, $04, $6d, $08, $6e
	db $04, $6d, $fe, $cd, $90, $7e, $01, $83, $7d, $cd, $98, $02, $3e, $00, $cd, $a4
	db $06, $3e, $39, $cc, $15, $05, $3e, $02, $cd, $a4, $06, $3e, $39, $cc, $15, $05
	db $62, $2e, $04, $cb, $7e, $2e, $08, $cb, $96, $20, $02, $cb, $d6, $d7, $c0, $36
	db $20, $3e, $6d, $e7, $ff, $c3, $e2, $07, $cd, $c9, $02, $d7, $c0, $cd, $5f, $7e
	db $3e, $01, $c3, $d8, $07, $21, $c0, $ca, $cb, $c6, $cd, $10, $7e, $2e, $08, $7e
	db $fe, $6b, $c8, $01, $14, $e6, $cd, $32, $06, $f7, $20, $06, $fe, $24, $30, $08
	db $18, $04, $fe, $7c, $38, $02, $06, $00, $cd, $12, $06, $16, $c0, $cd, $e2, $05
	db $01, $00, $03, $cd, $73, $05, $cd, $b7, $05, $16, $cc, $3e, $73, $e7, $ff, $21
	db $18, $c0, $36, $00, $c3, $d3, $07, $01, $2d, $7d, $cd, $98, $02, $01, $0e, $00
	db $c3, $8e, $05, $cd, $10, $7e, $01, $17, $00, $cd, $a9, $07, $c8, $3e, $08, $cd
	db $d8, $07, $c3, $52, $7d, $fa, $c0, $ca, $a7, $c8, $1e, $02, $1a, $a7, $ca, $f7
	db $7e, $1e, $0f, $1a, $c6, $14, $16, $c0, $12, $cd, $b7, $05, $cd, $d3, $06, $cd
	db $ff, $2f, $16, $cc, $20, $0a, $fa, $14, $c0, $fe, $0c, $38, $03, $fe, $94, $d8
	db $21, $c0, $ca, $cb, $86, $c9, $ff, $01, $89, $7e, $cd, $7e, $06, $01, $80, $fd
	db $cd, $6c, $05, $01, $40, $ff, $cd, $5a, $05, $01, $30, $70, $1e, $01, $1a, $fe
	db $07, $20, $03, $01, $4c, $54, $f7, $b8, $d0, $b9, $da, $38, $06, $c3, $48, $06
	db $04, $67, $0a, $70, $04, $67, $ff, $cd, $41, $08, $c8, $3e, $19, $d2, $ce, $06
	db $3e, $0b, $01, $50, $72, $cd, $ee, $07, $c1, $c9, $3e, $74, $e7, $c9, $15, $cd
	db $f6, $05, $2e, $07, $7e, $cb, $87, $14, $62, $77, $cd, $e2, $05, $21, $01, $cc
	db $7e, $fe, $08, $c0, $2e, $0f, $7e, $fe, $4c, $d0, $fa, $06, $c0, $cb, $7f, $c0
	db $cb, $47, $c8, $cd, $82, $03, $d0, $21, $09, $cc, $2a, $a7, $c0, $36, $20, $16
	db $cc, $3e, $10, $cd, $d8, $07, $af, $cd, $dd, $07, $cd, $f7, $7e, $1e, $07, $1a
	db $16, $c0, $12, $cd, $3b, $06, $21, $06, $c0, $cb, $fe, $16, $cd, $c9, $01, $18
	db $12, $cd, $12, $06, $26, $c0, $c3, $e3, $05, $01, $cc, $98, $21, $43, $7f, $cd
	db $ea, $0a, $0e, $cf, $cd, $f8, $0a, $0e, $f1, $cd, $ea, $0a, $3e, $54, $0e, $0d
	db $cd, $07, $0b, $3e, $78, $01, $f3, $98, $cd, $07, $0b, $cd, $3d, $09, $c0, $cd
	db $77, $13, $c3, $f7, $15, $01, $ec, $98, $21, $4d, $7f, $cd, $ea, $0a, $01, $ef
	db $98, $cd, $ea, $0a, $3e, $7f, $0e, $12, $18, $de, $70, $71, $72, $73, $74, $75
	db $76, $77, $51, $52, $79, $73, $7a, $7b, $7c, $7d, $7e, $50, $61, $98, $89, $18
	db $19, $23, $13, $00, $18, $16, $16, $23, $37, $8b, $12, $1d, $26, $14, $23, $18
	db $17, $15, $14, $25, $2b, $35, $90, $1c, $20, $12, $15, $12, $1c, $18, $14, $15
	db $25, $2b, $23, $12, $1a, $14, $25, $30, $93, $12, $23, $1d, $00, $15, $14, $11
	db $12, $18, $14, $1d, $00, $19, $23, $1d, $19, $1c, $19, $12, $2d, $91, $12, $15
	db $14, $00, $18, $15, $12, $1d, $14, $1a, $12, $15, $22, $25, $00, $16, $1e, $2f
	db $91, $27, $12, $15, $23, $14, $15, $00, $1b, $15, $16, $25, $2a, $00, $19, $23
	db $1c, $2a, $2f, $86, $2e, $00, $05, $0d, $0d, $05, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $02
