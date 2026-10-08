INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $055", ROMX[$4000], BANK[$55]

BankNumber_55::
	db $55

FarTable_55::
	dw Call_55_401F
	dw Call_55_4026
	dw Call_55_4035
	dw Call_55_403C
	dw Call_55_4043
	dw Call_55_4774
	dw Call_55_479B
	dw Call_55_47AF
	dw Call_55_47C3
	dw Call_55_47D7
	dw Call_55_47EB
	dw Call_55_47FF
	dw Call_55_4813
	dw Call_55_4936
	dw Data_55_4B4A

Call_55_401F::
	ld hl, $4070
	call Call_55_404A
	ret


Call_55_4026::
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret nz

	ld hl, $4074
	call Call_55_404A
	ret


Call_55_4035::
	ld hl, $4078
	call Call_55_404A
	ret


Call_55_403C::
	ld hl, $407c
	call Call_55_404A
	ret


Call_55_4043::
	ld hl, $4080
	call Call_55_404A
	ret


Call_55_404A::
	ld a, [wLinkFlags]
	and $02
	ld b, a
	ld a, [wSkillUser]
	and $04
	srl a
	xor b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wSkillId]
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl]
	cp $ff
	ret z

	call QueueSound
	ret


	db $84, $40, $62, $41, $40, $42, $1e, $43, $fc, $43, $da, $44, $b8, $45, $b8, $45
	db $96, $46, $96, $46, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $67, $67, $65, $67, $67
	db $67, $67, $67, $67, $67, $ff, $67, $ff, $67, $67, $67, $67, $67, $67, $67, $67
	db $67, $67, $67, $67, $67, $67, $ff, $ff, $ff, $67, $67, $67, $67, $67, $67, $67
	db $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67
	db $67, $67, $67, $67, $67, $67, $67, $ff, $ff, $67, $67, $67, $67, $67, $67, $67
	db $67, $ff, $67, $ff, $ff, $ff, $ff, $ff, $67, $67, $67, $67, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $67, $67, $ff, $67, $ff, $67, $ff, $ff, $67, $67, $67
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $67
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $65, $67, $67, $67, $67, $ff, $ff
	db $ff, $67, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $ff, $65, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $65, $ff, $65, $65, $65
	db $65, $65, $65, $65, $65, $65, $65, $65, $65, $6b, $6b, $65, $6b, $6b, $6b, $6b
	db $6b, $6b, $6b, $ff, $6b, $ff, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $6b, $6b, $6b, $ff, $ff, $ff, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
	db $6b, $6b, $6b, $6b, $6b, $ff, $ff, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b, $ff
	db $6b, $ff, $ff, $ff, $ff, $ff, $65, $65, $65, $65, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $6b, $6b, $ff, $6b, $ff, $6b, $ff, $ff, $6b, $6b, $6b, $ff, $ff
	db $ff, $ff, $ff, $6d, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6b, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $65, $6b, $6b, $6b, $6b, $65, $6d, $65, $6b
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $73, $73, $72, $84, $73, $72, $ff, $72, $72, $ff, $ff
	db $72, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $73, $73, $73, $73, $73
	db $73, $ff, $84, $ff, $ff, $72, $72, $ff, $73, $73, $73, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $72, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $72, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $82, $7e, $ff, $78, $81, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $76, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $71, $71, $ff, $ff, $71, $71, $ff, $ff
	db $71, $71, $ff, $71, $ff, $86, $86, $85, $ff, $70, $70, $70, $70, $70, $ff, $ff
	db $ff, $70, $70, $70, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $71, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $70
	db $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $70, $ff, $ff, $ff, $ff, $ff, $ff, $85, $ff, $ff, $ff, $70, $ff, $70, $70
	db $70, $70, $70, $70, $70, $70, $70, $70, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $82, $7e, $ff, $78, $81, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $76, $85, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $9c, $9c
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $71, $71, $ff, $ff, $71, $71
	db $ff, $71, $ff, $86, $86, $85, $ff, $70, $70, $70, $70, $70, $ff, $ff, $ff, $70
	db $70, $70, $70, $6c, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $ff, $6c, $ff
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $9c, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $6c, $6c, $6c, $ff, $ff, $70, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $70
	db $70, $ff, $ff, $ff, $ff, $6c, $6c, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $70
	db $9c, $ff, $71, $ff, $72, $ff, $85, $6c, $ff, $ff, $70, $6c, $70, $70, $70, $70
	db $70, $70, $70, $70, $70, $70, $70, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $6c, $6c, $ff, $6c, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $6c, $85, $6c, $6c, $6c, $6c, $ff, $ff, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $9c, $9c, $ff, $73
	db $73, $72, $84, $ff, $ff, $ff, $72, $72, $ff, $ff, $72, $72, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $6c, $6c, $ff, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $ff, $6c, $ff, $6c, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $ff, $6c
	db $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c, $6c
	db $6c, $6c, $6c, $6c, $73, $73, $73, $73, $73, $73, $73, $9c, $84, $ff, $ff, $72
	db $ff, $ff, $73, $73, $73, $6c, $6c, $6c, $6c, $ff, $ff, $70, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $73, $ff, $ff, $ff
	db $ff, $ff, $ff, $6c, $6c, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $9c, $ff
	db $71, $73, $ff, $ff, $ff, $6c, $ff, $ff, $ff, $6c, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $6c, $6c, $ff, $6c, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $ff
	db $6c, $6c, $6c, $6c, $73, $ff, $ff, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f
	db $6f, $ff, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $ff, $6f, $ff, $6f, $6f, $6f, $6f
	db $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $ff, $6f, $6f, $6f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f
	db $6f, $6f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $6f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $6f, $6f, $6f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $6f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6f, $6f
	db $6f, $6f, $ff, $ff, $ff, $6f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $6c, $6c, $ff, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $73, $73
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $73, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $6c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff

Call_55_4774::
	ld hl, $97c0
	ld de, $0601
	ld a, $01
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ld hl, $8800
	ld de, $0c01
	ld a, $09
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_479B::
	ld hl, $8850
	ld de, $1801
	ld a, $03
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_47AF::
	ld hl, $8800
	ld de, $0501
	ld a, $04
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_47C3::
	ld hl, $8800
	ld de, $0501
	ld a, $05
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_47D7::
	ld hl, $8850
	ld de, $0601
	ld a, $06
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_47EB::
	ld hl, $8800
	ld de, $0b01
	ld a, $02
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_47FF::
	ld hl, $8860
	ld de, $0201
	ld a, $07
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call Call_55_4823
	ret


Call_55_4813::
	ld hl, $8820
	ld de, $0701
	ld a, $0a
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a

Call_55_4823::
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	call Call_55_4863
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ret


	db $c0, $96, $c0, $97, $00, $88, $50, $88

Call_55_4863::
	ld de, $48a9
	call Call_55_486D
	call RunTextToEnd
	ret


Call_55_486D::
	push de
	ld a, [wTextTiles]
	ld l, a
	ld a, [$c828]
	ld h, a
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [$c82c], a
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [$c830], a
	pop de
	call Call_55_4924
	ld a, e
	ld [wTextPtr], a
	ld a, d
	ld [$c82e], a
	ld a, e
	ld [wTextStart], a
	ld a, d
	ld [$c832], a
	ld a, $01
	ld [wTextState], a
	ld a, $00
	ld [wTextFlags], a
	xor a
	ld [wTextDelay], a
	ret


	db $bf, $48, $c6, $48, $cb, $48, $d1, $48, $e6, $48, $ec, $48, $f4, $48, $fa, $48
	db $fd, $48, $0d, $49, $1a, $49, $33, $38, $8d, $2b, $8d, $50, $f0, $33, $35, $38
	db $31, $f0, $24, $2f, $2e, $27, $36, $f0, $29, $2c, $2a, $2b, $37, $28, $30, $36
	db $35, $38, $31, $32, $24, $33, $2f, $3b, $27, $26, $63, $2e, $f0, $24, $2f, $2e
	db $27, $36, $f0, $2c, $8d, $3a, $55, $29, $30, $8d, $f0, $3a, $2b, $32, $29, $28
	db $f0, $3a, $32, $f0, $33, $29, $26, $38, $8d, $2b, $8d, $2e, $2b, $31, $55, $3a
	db $2c, $8d, $50, $f0, $24, $2f, $2e, $27, $36, $29, $2c, $2a, $2b, $37, $28, $30
	db $f0, $3a, $2b, $32, $2c, $31, $29, $32, $32, $2e, $f0

Call_55_4924::
	ld a, [BankNumber_55]
	ld [wTextBank], a
	ld a, [wTextIndex]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret


Call_55_4936::
	ld hl, $9000
	ld de, $1007
	call SetUpTextBox
	ld hl, far_SetSharedBGColors
	rst $10
	ld hl, far_ClearAttrMap
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld hl, wNumberBackup
	ld bc, $0010
	ld a, $00
	call FillMemory
	xor a
	ld [wLinkChoice], a
	call Call_55_496C
	ld a, $00
	call QueueMusic
	ld a, $03
	ld [wLCDC], a
	ld a, $01
	jp EnableLCDAndInterrupts


Call_55_496C::
	ld a, [wGameModeStep]
	rst $00

JumpTable_55_4970::
	dw Jump_55_497C
	dw Jump_55_499E
	dw Jump_55_49E2
	dw Jump_55_4A4F
	dw Jump_55_4A9E
	dw Jump_55_4ACB

Jump_55_497C::
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	ld hl, $8800
	ld a, $03
	ld [wTextIndex], a
	call Call_55_4B22
	ld hl, $98a3
	ld bc, $1002
	ld a, $80
	jp Call_55_4B33


Jump_55_499E::
	xor a
	ld [wTextGroup], a
	ld a, $05
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	ld hl, $9120
	ld de, $1006
	ld a, $07
	ld [wTextIndex], a
	call Call_55_4B1A
	ld hl, $8800
	ld a, $08
	ld [wTextIndex], a
	call Call_55_4B22
	ld hl, wNumberBackup
	ld a, [wDebugSavedMode]
	ld [hli], a
	ld a, [$c8ae]
	ld [hli], a
	ld a, [$c8af]
	ld [hli], a
	ld a, [$c8b0]
	ld [hli], a
	ld hl, $9884
	ld bc, $1006
	ld a, $12
	jp Call_55_4B33


Jump_55_49E2::
	xor a
	ld [wTextGroup], a
	ld a, $05
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	ld de, $2f11
	ld hl, $8800
	call Decompress
	ld hl, $9800
	ld bc, $0400
	ld a, $00
	call FillMemory
	ld hl, $9887
	ld a, $80
	ld b, $06
	call Call_55_4A47
	ld hl, $98a7
	ld b, $06
	call Call_55_4A47
	ld hl, $98c7
	ld b, $06
	call Call_55_4A47
	ld hl, $98e7
	ld b, $06
	call Call_55_4A47
	ld hl, $9907
	ld b, $06
	call Call_55_4A47
	ld hl, $9927
	ld b, $06
	call Call_55_4A47
	ld hl, $9967
	ld a, $a4
	ld b, $09
	call Call_55_4A47
	xor a
	ld [wLinkChoice], a
	call Call_55_4D44
	ret


Call_55_4A47::
	call WriteVRAMInc
	inc a
	dec b
	jr nz, Call_55_4A47

	ret


Jump_55_4A4F::
	xor a
	ld [wTextGroup], a
	ld a, $05
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	ld hl, $9120
	ld de, $0a0a
	ld a, $04
	ld [wTextIndex], a
	call Call_55_4B1A
	ld hl, wNumberBackup
	ld a, [wOnGateFloor]
	ld [hli], a
	ld a, [wMapId]
	ld [hli], a
	ld a, [wPartyCount]
	ld [hli], a
	ld a, [wParty]
	ld [hli], a
	ld a, [$ca8f]
	ld [hli], a
	ld a, [$ca90]
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, [wDebugSetup]
	ld [hl], a
	ld a, $1c
	ldh [hScrollX], a
	ld hl, $9885
	ld bc, $0a0a
	ld a, $12
	call Call_55_4B33
	jp Jump_055_4ed3


Jump_55_4A9E::
	xor a
	ld [wTextGroup], a
	ld a, $05
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	ld hl, $9120
	ld de, $1006
	ld a, $06
	ld [wTextIndex], a
	call Call_55_4B1A
	xor a
	ld [wNumberBackup], a
	ld [$c0a1], a
	ld hl, $9884
	ld bc, $1006
	ld a, $12
	jp Call_55_4B33


Jump_55_4ACB::
	xor a
	ld [wTextGroup], a
	ld a, $05
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	ld hl, $9120
	ld de, $0a0a
	ld a, $09
	ld [wTextIndex], a
	call Call_55_4B1A
	ld hl, wNumberBackup
	ld a, [wEncCount]
	ld [hli], a
	ld a, [wEncSpecies]
	ld [hli], a
	ld a, [$da04]
	ld [hli], a
	ld a, [$da05]
	ld [hli], a
	ld a, [$da06]
	ld [hli], a
	ld a, [$da07]
	ld [hli], a
	ld a, [$da08]
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $24
	ldh [hScrollX], a
	ld hl, $9885
	ld bc, $0a0a
	ld a, $12
	call Call_55_4B33
	jp Jump_055_5232


Call_55_4B1A::
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a

Call_55_4B22::
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	xor a
	ld [wTextGroup], a
	ld hl, far_PrintText_41
	rst $10
	ret


Call_55_4B33::
	push hl
	ld d, b

jr_055_4b35:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_055_4b35

	ld b, d
	ld e, a
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, e
	dec c
	jr nz, Call_55_4B33

	ret


Data_55_4B4A::
	db $fa, $46, $c8, $cb, $57, $28, $21, $af, $ea, $0b, $df, $ea, $0c, $df, $ea, $02
	db $df, $ea, $03, $df, $ea, $00, $df, $ea, $01, $df, $3e, $0b, $ea, $8a, $c8, $af
	db $ea, $8b, $c8, $21, $8e, $c8, $34, $d9, $fa, $8b, $c8, $c7, $82, $4b, $f4, $4b
	db $02, $4d, $a4, $4d, $a0, $4f, $16, $51, $fa, $47, $c8, $e6, $90, $28, $0c, $fa
	db $a0, $c0, $3c, $fe, $06, $20, $15, $3e, $00, $18, $11, $fa, $47, $c8, $e6, $60
	db $28, $12, $fa, $a0, $c0, $3d, $fe, $ff, $20, $02, $3e, $05, $ea, $a0, $c0, $3e
	db $59, $cd, $2c, $1b, $fa, $a0, $c0, $cb, $37, $c6, $a0, $21, $22, $99, $06, $10
	db $cd, $b9, $1a, $3c, $05, $20, $f9, $fa, $46, $c8, $e6, $01, $c8, $3e, $59, $cd
	db $2c, $1b, $fa, $a0, $c0, $fe, $05, $28, $09, $3c, $ea, $8b, $c8, $21, $8e, $c8
	db $34, $c9, $21, $8a, $c8, $fa, $ad, $c8, $22, $fa, $ae, $c8, $22, $fa, $af, $c8
	db $22, $fa, $b0, $c8, $77, $21, $8e, $c8, $34, $c9, $fa, $46, $c8, $e6, $08, $28
	db $57, $3e, $59, $cd, $2c, $1b, $cd, $d0, $12, $fa, $99, $c8, $3c, $ea, $03, $da
	db $cd, $d0, $12, $fa, $99, $c8, $3c, $ea, $05, $da, $cd, $d0, $12, $fa, $99, $c8
	db $3c, $ea, $07, $da, $cd, $d0, $12, $fa, $99, $c8, $47, $3e, $03, $cd, $fb, $1d
	db $ea, $02, $da, $3e, $04, $cd, $88, $16, $21, $a0, $c0, $2a, $ea, $8a, $c8, $2a
	db $ea, $8b, $c8, $2a, $ea, $8c, $c8, $2a, $ea, $8d, $c8, $21, $8e, $c8, $34, $af
	db $ea, $eb, $c8, $af, $ea, $ea, $c8, $c9, $fa, $47, $c8, $cb, $77, $28, $06, $fa
	db $da, $c8, $3d, $18, $0b, $fa, $47, $c8, $cb, $7f, $28, $0e, $fa, $da, $c8, $3c
	db $e6, $03, $ea, $da, $c8, $3e, $59, $cd, $2c, $1b, $fa, $da, $c8, $4f, $06, $00
	db $21, $a0, $c0, $09, $fa, $47, $c8, $e6, $10, $28, $03, $34, $18, $13, $fa, $47
	db $c8, $e6, $20, $28, $03, $35, $18, $09, $fa, $46, $c8, $e6, $01, $28, $07, $af
	db $77, $3e, $59, $cd, $2c, $1b, $fa, $46, $c8, $e6, $02, $28, $0e, $3e, $59, $cd
	db $2c, $1b, $af, $ea, $8b, $c8, $21, $8e, $c8, $34, $c9, $11, $a0, $c0, $21, $cd
	db $98, $06, $01, $0e, $04, $d5, $e5, $c5, $fa, $da, $c8, $81, $fe, $04, $20, $10
	db $fa, $a4, $c8, $cb, $5f, $20, $09, $af, $cd, $b9, $1a, $cd, $b9, $1a, $18, $04
	db $1a, $cd, $15, $53, $c1, $e1, $d1, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $13
	db $0d, $20, $d2, $fa, $a0, $c0, $87, $87, $87, $c6, $80, $21, $c4, $98, $06, $08
	db $cd, $b9, $1a, $3c, $05, $20, $f9, $c9, $21, $88, $99, $fa, $da, $c8, $06, $01
	db $0e, $00, $cd, $26, $53, $fa, $46, $c8, $e6, $02, $28, $0e, $3e, $59, $cd, $2c
	db $1b, $af, $ea, $8b, $c8, $21, $8e, $c8, $34, $c9, $fa, $47, $c8, $cb, $77, $28
	db $06, $fa, $da, $c8, $3d, $18, $0b, $fa, $47, $c8, $cb, $7f, $28, $6b, $fa, $da
	db $c8, $3c, $ea, $da, $c8, $3e, $59, $cd, $2c, $1b

Call_55_4D44::
	ld a, [wLinkChoice]
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
	ld hl, $8800
	call DecompressVRAM
	ld a, [wLinkChoice]
	ld [wPaletteSet], a
	ld a, $04
	ld [$c81f], a
	ld hl, $0087
	ld a, l
	ld [$c820], a
	ld a, h
	ld [$c821], a
	ld hl, far_LoadMonPicPalette
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, [wLinkChoice]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld hl, $0901
	ld a, l
	ld [wTextBoxWidth], a
	ld a, h
	ld [wTextBoxHeight], a
	ld hl, $8a40
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld hl, far_Call_56_4485
	rst $10
	ld hl, far_PrintText_41
	rst $10
	ret


	db $fa, $46, $c8, $e6, $08, $28, $5f, $3e, $04, $cd, $88, $16, $3e, $01, $ea, $8a
	db $c8, $3e, $00, $ea, $8b, $c8, $3e, $59, $cd, $2c, $1b, $21, $a0, $c0, $2a, $ea
	db $69, $c9, $2a, $ea, $68, $c9, $2a, $ea, $8d, $ca, $2a, $ea, $8e, $ca, $2a, $ea
	db $8f, $ca, $2a, $ea, $90, $ca, $2a, $e0, $d5, $7e, $ea, $ab, $c8, $fa, $69, $c9
	db $ea, $ea, $c8, $fa, $69, $c9, $ea, $6c, $c9, $fa, $68, $c9, $ea, $6d, $c9, $fa
	db $69, $c9, $ea, $6e, $c9, $af, $ea, $35, $c9, $21, $8e, $c8, $34, $af, $ea, $eb
	db $c8, $af, $ea, $d7, $d8, $c9, $fa, $47, $c8, $cb, $77, $28, $06, $fa, $da, $c8
	db $3d, $18, $0b, $fa, $47, $c8, $cb, $7f, $28, $0e, $fa, $da, $c8, $3c, $e6, $07
	db $ea, $da, $c8, $3e, $59, $cd, $2c, $1b, $fa, $da, $c8, $4f, $06, $00, $21, $a0
	db $c0, $09, $fa, $47, $c8, $e6, $10, $28, $03, $34, $18, $13, $fa, $47, $c8, $e6
	db $20, $28, $03, $35, $18, $09, $fa, $46, $c8, $e6, $01, $28, $34, $af, $77, $3e
	db $59, $cd, $2c, $1b, $fa, $da, $c8, $06, $02, $fe, $00, $cc, $d3, $4e, $06, $60
	db $fe, $01, $cc, $d3, $4e, $06, $04, $fe, $02, $cc, $d3, $4e, $06, $0a, $fe, $03
	db $cc, $d3, $4e, $06, $0a, $fe, $04, $cc, $d3, $4e, $06, $0a, $fe, $05, $cc, $d3
	db $4e, $fa, $46, $c8, $e6, $02, $28, $07, $af, $ea, $8b, $c8, $c3, $ba, $4d, $11
	db $a0, $c0, $21, $cc, $98, $06, $01, $0e, $08, $d5, $e5, $c5, $fa, $da, $c8, $81
	db $fe, $08, $20, $13, $fa, $a4, $c8, $cb, $5f, $20, $0c, $af, $cd, $b9, $1a, $cd
	db $b9, $1a, $cd, $b9, $1a, $18, $08, $1a, $06, $01, $0e, $00, $cd, $66, $53, $c1
	db $e1, $d1, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $13, $0d, $20, $cb, $c9

Jump_055_4ed3:
	push af
	ld a, [wLinkChoice]
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp b
	jr nz, jr_055_4ee6

	ld [hl], $00

jr_055_4ee6:
	ld a, [hl]
	cp $ff
	jr nz, jr_055_4eed

	dec b
	ld [hl], b

jr_055_4eed:
	ld a, [wNumberBackup]
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	ld hl, $0701
	ld a, l
	ld [wTextBoxWidth], a
	ld a, h
	ld [wTextBoxHeight], a
	ld hl, $8800
	call Call_55_4F8F
	ld a, [wNumberBackup]
	cp $00
	jr z, jr_055_4f14

	ld a, $03
	jr jr_055_4f19

jr_055_4f14:
	ld a, [$c0a1]
	add $04

jr_055_4f19:
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	ld hl, $0701
	ld a, l
	ld [wTextBoxWidth], a
	ld a, h
	ld [wTextBoxHeight], a
	ld hl, $8870
	call Call_55_4F8F
	ld a, $04
	ld [wTextGroup], a
	ld a, [wLineUpOrder]
	ld [wTextIndex], a
	ld hl, $88e0
	call Call_55_4F8F
	ld a, [$c0a4]
	ld [wTextIndex], a
	ld hl, $8950
	call Call_55_4F8F
	ld a, [$c0a5]
	ld [wTextIndex], a
	ld hl, $89c0
	call Call_55_4F8F
	ld hl, $98d0
	ld a, $80
	ld b, $07
	call Call_55_4F87
	ld hl, $98f0
	ld b, $07
	call Call_55_4F87
	ld hl, $9930
	ld b, $07
	call Call_55_4F87
	ld hl, $9950
	ld b, $07
	call Call_55_4F87
	ld hl, $9970
	ld b, $07
	call Call_55_4F87
	pop af
	ret


Call_55_4F87::
	call WriteVRAMInc
	inc a
	dec b
	jr nz, Call_55_4F87

	ret


Call_55_4F8F::
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld hl, far_Call_56_4485
	rst $10
	ld hl, far_PrintText_41
	rst $10
	ret


	db $fa, $46, $c8, $e6, $08, $28, $2b, $fa, $da, $c8, $b7, $20, $11, $fa, $a0, $c0
	db $21, $b4, $50, $85, $6f, $3e, $00, $8c, $67, $7e, $cd, $e1, $1a, $c9, $cd, $31
	db $33, $fa, $a1, $c0, $21, $d4, $50, $85, $6f, $3e, $00, $8c, $67, $7e, $cd, $2c
	db $1b, $c9, $fa, $47, $c8, $cb, $77, $28, $06, $fa, $da, $c8, $3d, $18, $0b, $fa
	db $47, $c8, $cb, $7f, $28, $0e, $fa, $da, $c8, $3c, $e6, $01, $ea, $da, $c8, $3e
	db $59, $cd, $2c, $1b, $fa, $da, $c8, $4f, $06, $00, $21, $a0, $c0, $09, $fa, $47
	db $c8, $e6, $10, $28, $03, $34, $18, $13, $fa, $47, $c8, $e6, $20, $28, $03, $35
	db $18, $09, $fa, $46, $c8, $e6, $01, $28, $18, $af, $77, $3e, $59, $cd, $2c, $1b
	db $fa, $da, $c8, $06, $20, $fe, $00, $cc, $98, $50, $06, $40, $fe, $01, $cc, $98
	db $50, $fa, $46, $c8, $e6, $02, $28, $0e, $3e, $59, $cd, $2c, $1b, $af, $ea, $8b
	db $c8, $21, $8e, $c8, $34, $c9, $11, $a0, $c0, $21, $ca, $98, $06, $01, $0e, $02
	db $d5, $e5, $c5, $fa, $da, $c8, $81, $fe, $02, $20, $10, $fa, $a4, $c8, $cb, $5f
	db $20, $09, $af, $cd, $b9, $1a, $cd, $b9, $1a, $18, $04, $1a, $cd, $15, $53, $c1
	db $c5, $79, $01, $d4, $50, $fe, $02, $20, $03, $01, $b4, $50, $1a, $81, $4f, $3e
	db $00, $88, $47, $0a, $23, $cd, $15, $53, $c1, $e1, $d1, $7d, $c6, $20, $6f, $7c
	db $ce, $00, $67, $13, $0d, $20, $b9, $c9, $f5, $fa, $da, $c8, $21, $a0, $c0, $85
	db $6f, $3e, $00, $8c, $67, $7e, $b8, $20, $02, $36, $00, $7e, $fe, $ff, $20, $02
	db $05, $70, $f1, $c9, $02, $06, $09, $0c, $0f, $12, $15, $18, $1b, $1e, $21, $24
	db $27, $2b, $2e, $31, $34, $37, $3a, $3c, $3f, $41, $44, $47, $49, $4b, $4d, $4f
	db $9f, $00, $00, $00, $00, $51, $52, $53, $54, $55, $56, $57, $59, $5a, $5b, $5c
	db $5d, $5f, $60, $61, $64, $65, $66, $67, $68, $69, $6b, $6c, $6d, $6e, $6f, $70
	db $71, $72, $73, $74, $76, $78, $7a, $7b, $7c, $7e, $7f, $80, $81, $82, $83, $84
	db $85, $86, $88, $89, $8a, $8c, $8d, $8e, $8f, $90, $92, $93, $94, $95, $96, $97
	db $99, $9b, $9c, $9d, $00, $00, $fa, $46, $c8, $e6, $08, $28, $45, $3e, $04, $cd
	db $88, $16, $3e, $02, $ea, $8a, $c8, $3e, $00, $ea, $8b, $c8, $cd, $79, $53, $fa
	db $8d, $ca, $b7, $20, $04, $21, $8d, $ca, $34, $3e, $59, $cd, $2c, $1b, $21, $a0
	db $c0, $2a, $ea, $02, $da, $2a, $ea, $03, $da, $2a, $ea, $04, $da, $2a, $ea, $05
	db $da, $2a, $ea, $06, $da, $2a, $ea, $07, $da, $2a, $ea, $08, $da, $21, $8e, $c8
	db $34, $c9, $fa, $47, $c8, $cb, $77, $28, $06, $fa, $da, $c8, $3d, $18, $0b, $fa
	db $47, $c8, $cb, $7f, $28, $0e, $fa, $da, $c8, $3c, $e6, $07, $ea, $da, $c8, $3e
	db $59, $cd, $2c, $1b, $fa, $da, $c8, $4f, $06, $00, $21, $a0, $c0, $09, $fa, $47
	db $c8, $e6, $10, $28, $03, $34, $18, $13, $fa, $47, $c8, $e6, $20, $28, $03, $35
	db $18, $09, $fa, $46, $c8, $e6, $01, $28, $3b, $af, $77, $3e, $59, $cd, $2c, $1b
	db $fa, $da, $c8, $06, $03, $fe, $00, $cc, $32, $52, $06, $00, $fe, $01, $cc, $32
	db $52, $06, $02, $fe, $02, $cc, $32, $52, $06, $00, $fe, $03, $cc, $32, $52, $06
	db $02, $fe, $04, $cc, $32, $52, $06, $00, $fe, $05, $cc, $32, $52, $06, $02, $fe
	db $06, $cc, $32, $52, $fa, $46, $c8, $e6, $02, $28, $07, $af, $ea, $8b, $c8, $c3
	db $39, $51, $11, $a0, $c0, $21, $cb, $98, $06, $01, $0e, $08, $d5, $e5, $c5, $fa
	db $da, $c8, $81, $fe, $08, $20, $13, $fa, $a4, $c8, $cb, $5f, $20, $0c, $af, $cd
	db $b9, $1a, $cd, $b9, $1a, $cd, $b9, $1a, $18, $08, $1a, $06, $01, $0e, $00, $cd
	db $66, $53, $c1, $e1, $d1, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $13, $0d, $20
	db $cb, $c9

Jump_055_5232:
	push af
	ld a, [wLinkChoice]
	ld hl, wNumberBackup
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp b
	jr nz, jr_055_5245

	ld [hl], $00

jr_055_5245:
	ld a, [hl]
	cp $ff
	jr nz, jr_055_524c

	dec b
	ld [hl], b

jr_055_524c:
	ld a, [$c0a1]
	ld [wEncSpecies], a
	ld a, [$c0a2]
	ld [$da04], a
	ld a, [wLineUpOrder]
	ld [$da05], a
	ld a, [$c0a4]
	ld [$da06], a
	ld a, [$c0a5]
	ld [$da07], a
	ld a, [$c0a6]
	ld [$da08], a
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate
	rst $10
	ld hl, $0901
	ld a, l
	ld [wTextBoxWidth], a
	ld a, h
	ld [wTextBoxHeight], a
	ld a, $05
	ld [wTextGroup], a
	ld a, [wNewMonNameText]
	ld [wTextIndex], a
	ld hl, $8800
	call Call_55_5304
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate
	rst $10
	ld a, [wNewMonNameText]
	ld [wTextIndex], a
	ld hl, $8890
	call Call_55_5304
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate
	rst $10
	ld a, [wNewMonNameText]
	ld [wTextIndex], a
	ld hl, $8920
	call Call_55_5304
	ld hl, $98ef
	ld a, $80
	ld b, $09
	call Call_55_52FC
	ld hl, $992f
	ld b, $09
	call Call_55_52FC
	ld hl, $996f
	ld b, $09
	call Call_55_52FC
	pop af
	ret


Call_55_52FC::
	call WriteVRAMInc
	inc a
	dec b
	jr nz, Call_55_52FC

	ret


Call_55_5304::
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld hl, far_Call_56_4485
	rst $10
	ld hl, far_PrintText_41
	rst $10
	ret


	db $4f, $cb, $37, $e6, $0f, $3c, $cd, $b9, $1a, $79, $e6, $0f, $3c, $cd, $b9, $1a
	db $c9, $fe, $64, $30, $0e, $cd, $5f, $53, $23, $fe, $0a, $30, $0f, $cd, $5f, $53
	db $23, $18, $12, $1e, $64, $cd, $4f, $53, $cd, $57, $53, $23, $1e, $0a, $cd, $4f
	db $53, $cd, $57, $53, $23, $57, $cd, $57, $53, $c9, $16, $ff, $14, $93, $30, $fc
	db $83, $c9, $f5, $7a, $80, $cd, $ad, $1a, $f1, $c9, $f5, $79, $cd, $ad, $1a, $f1
	db $c9, $23, $f5, $cb, $37, $e6, $0f, $57, $cd, $57, $53, $23, $f1, $e6, $0f, $57
	db $cd, $57, $53, $c9, $3e, $6e, $ea, $42, $ca, $3e, $86, $ea, $43, $ca, $3e, $9c
	db $ea, $44, $ca, $3e, $f0, $ea, $45, $ca, $3e, $03, $ea, $8d, $ca, $3e, $00, $ea
	db $8e, $ca, $3e, $01, $ea, $8f, $ca, $3e, $02, $ea, $90, $ca, $06, $14, $0e, $00
	db $c5, $79, $cd, $f6, $53, $c1, $0c, $05, $20, $f6, $3e, $00, $ea, $4b, $ca, $3e
	db $54, $ea, $4c, $ca, $3e, $01, $ea, $4d, $ca, $3e, $01, $ea, $51, $ca, $3e, $02
	db $ea, $52, $ca, $3e, $03, $ea, $53, $ca, $3e, $04, $ea, $54, $ca, $3e, $05, $ea
	db $55, $ca, $3e, $06, $ea, $56, $ca, $3e, $07, $ea, $57, $ca, $3e, $08, $ea, $58
	db $ca, $3e, $02, $ea, $c1, $ca, $3e, $02, $ea, $56, $cb, $3e, $02, $ea, $eb, $cb
	db $c9, $f5, $ea, $14, $da, $cd, $d0, $12, $fa, $99, $c8, $e6, $3f, $3c, $ea, $12
	db $da, $af, $ea, $13, $da, $21, $02, $14, $d7, $f1, $f5, $cd, $d0, $12, $e6, $7f
	db $ea, $31, $da, $21, $d6, $ca, $4f, $f1, $cd, $9c, $54, $f5, $f1, $f5, $cd, $d0
	db $12, $e6, $7f, $ea, $31, $da, $21, $d7, $ca, $4f, $f1, $cd, $9c, $54, $f5, $f1
	db $f5, $21, $cb, $ca, $cd, $3b, $22, $7e, $4f, $f1, $21, $c2, $ca, $cd, $ac, $54
	db $f5, $cd, $d0, $12, $fa, $99, $c8, $e6, $07, $4f, $f1, $21, $d8, $ca, $cd, $ac
	db $54, $f5, $cd, $d0, $12, $fa, $99, $c8, $e6, $07, $4f, $f1, $21, $e1, $ca, $cd
	db $ac, $54, $f5, $21, $d6, $ca, $cd, $3b, $22, $7e, $ea, $31, $da, $21, $01, $03
	db $d7, $fa, $33, $da, $4f, $f1, $21, $44, $cb, $cd, $ac, $54, $f5, $21, $d7, $ca
	db $cd, $3b, $22, $7e, $ea, $31, $da, $21, $01, $03, $d7, $fa, $33, $da, $4f, $f1
	db $21, $4d, $cb, $cd, $ac, $54, $c9, $f5, $cd, $3b, $22, $71, $f1, $c9, $f5, $cd
	db $3b, $22, $71, $23, $70, $f1, $c9, $f5, $c5, $cd, $3b, $22, $5d, $54, $cd, $d0
	db $12, $fa, $99, $c8, $e6, $0f, $c1, $cb, $31, $b1, $6f, $26, $03, $cd, $7a, $09
	db $f1, $c9, $df, $06, $f8, $04, $f8, $a1, $5a, $01, $4e, $81, $5e, $96, $08, $b8
	db $28, $11, $24, $46, $db, $01, $37, $8b, $b0, $40, $2d, $cd, $84, $64, $ff, $00
	db $ff, $00, $ff, $00, $05, $ff, $8b, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $05, $ff, $8b, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $05, $ff, $8b, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $05, $ff
	db $84, $00, $ff, $00, $ff, $11, $00, $ff, $07, $70, $07, $70, $ff, $ff, $00, $ff
	db $00, $00, $ff, $ff, $00, $ff, $00, $00, $e1, $0e, $e1, $0e, $f0, $f6, $08, $fb
	db $04, $fc, $c5, $f6, $25, $f6, $65, $36, $18, $23, $30, $8e, $70, $08, $e1, $10
	db $03, $a4, $06, $e8, $04, $ba, $06, $69, $56, $a9, $1b, $64, $76, $81, $e0, $0e
	db $40, $b8, $40, $a3, $c3, $28, $c6, $31, $c6, $21, $84, $00, $00, $3c, $0c, $51
	db $18, $e1, $30, $4f, $74, $09, $4d, $30, $00, $b7, $29, $16, $22, $49, $da, $04
	db $3c, $80, $b0, $4f, $20, $c2, $80, $6b, $b9, $44, $89, $54, $d8, $27, $00, $f9
	db $51, $a8, $93, $68, $02, $95, $07, $f8, $b1, $0e, $7d, $02, $60, $9f, $e0, $13
	db $c0, $22, $80, $58, $10, $a6, $e0, $f1, $1c, $80, $5f, $00, $7f, $40, $be, $40
	db $90, $00, $75, $01, $46, $45, $aa, $c6, $39, $03, $b8, $07, $18, $30, $07, $20
	db $47, $c3, $3c, $8c, $73, $41, $3a, $06, $d9, $01, $d9, $83, $72, $20, $d0, $05
	db $f3, $03, $f7, $a4, $55, $00, $41, $80, $51, $ff, $1c, $ff, $24, $ff, $44, $ff
	db $24, $ff, $24, $ff, $24, $ff, $42, $ff, $7e, $ff, $7c, $bb, $82, $ff, $92, $ff
	db $92, $ff, $92, $ff, $92, $bb, $82, $ff, $7c, $ff, $fe, $ff, $82, $ff, $9c, $fb
	db $82, $ff, $72, $ff, $72, $fb, $82, $ff, $fc, $ff, $7c, $bb, $82, $ff, $92, $fb
	db $e2, $ff, $4c, $bf, $de, $ff, $82, $ff, $fe, $30, $00, $00, $81, $00, $0f, $7f
	db $81, $00, $0f, $ff, $10, $cf, $10, $ff, $10, $fc, $10, $3f, $04, $00, $84, $03
	db $07, $0e, $0d, $08, $09, $03, $00, $83, $03, $07, $0d, $04, $0a, $86, $1f, $19
	db $ff, $ff, $00, $ff, $0c, $00, $84, $ff, $ff, $00, $ff, $0a, $09, $82, $04, $03
	db $04, $00, $89, $7f, $7f, $7e, $7d, $7d, $7e, $7e, $7d, $7f, $03, $7e, $b8, $7d
	db $7e, $7e, $7f, $a8, $57, $a8, $57, $57, $e8, $eb, $e8, $77, $ab, $ab, $17, $fa
	db $47, $87, $7b, $47, $fa, $09, $95, $6d, $d5, $49, $56, $ee, $d5, $ad, $5e, $be
	db $5d, $ad, $d6, $5f, $5f, $5e, $55, $4a, $4a, $56, $6d, $d7, $62, $49, $b6, $cd
	db $3e, $06, $fa, $ff, $0f, $f7, $8b, $03, $ab, $c9, $57, $bf, $4f, $f7, $87, $db
	db $67, $87, $fb, $fd, $f2, $c9, $fc, $d2, $d2, $ea, $cd, $fb, $e5, $df, $e2, $ef
	db $e1, $d0, $ef, $ff, $ec, $55, $96, $96, $50, $d5, $eb, $fd, $ea, $57, $5a, $b4
	db $6c, $ea, $75, $fe, $f1, $4f, $b2, $85, $b5, $7a, $fd, $f0, $ef, $72, $af, $b2
	db $ae, $93, $6c, $7b, $b5, $7b, $eb, $fd, $d3, $6a, $ab, $fd, $62, $df, $62, $ee
	db $ea, $66, $dd, $05, $fe, $87, $7e, $be, $7e, $fe, $7e, $be, $7e, $04, $fe, $89
	db $00, $01, $02, $05, $0b, $17, $2f, $5f, $7f, $07, $07, $91, $00, $1f, $2f, $5f
	db $7c, $7f, $7c, $7e, $7e, $7d, $7d, $7e, $7e, $7d, $7f, $7f, $00, $03, $ff, $8d
	db $86, $f8, $8b, $ab, $a8, $6b, $68, $d7, $0f, $f6, $5f, $5e, $00, $03, $ff, $8d
	db $97, $97, $f0, $4f, $44, $f9, $26, $ac, $0f, $f6, $2d, $f5, $00, $03, $ff, $8d
	db $d7, $6b, $97, $cb, $ab, $27, $2f, $df, $ff, $cf, $56, $69, $07, $03, $ff, $8d
	db $f7, $e8, $ee, $d8, $ef, $d8, $ea, $d9, $ff, $0f, $f7, $8b, $e0, $03, $ff, $8d
	db $77, $aa, $95, $55, $59, $a5, $b2, $6d, $fa, $f5, $ea, $d5, $00, $03, $ff, $8d
	db $fe, $f1, $4f, $72, $45, $75, $fa, $fd, $84, $7f, $80, $79, $00, $03, $ff, $8d
	db $7b, $a5, $5f, $e2, $ef, $e1, $50, $af, $75, $a5, $95, $55, $00, $03, $ff, $93
	db $fe, $f1, $4f, $72, $85, $75, $fa, $7d, $fd, $f6, $c9, $7c, $00, $f8, $f4, $fa
	db $7e, $be, $7e, $03, $fe, $a2, $7e, $be, $7e, $be, $7e, $be, $7d, $7f, $7f, $7d
	db $7f, $7f, $7c, $7f, $7d, $7d, $7e, $7c, $5f, $2f, $1f, $00, $f7, $5e, $5d, $f6
	db $df, $2e, $95, $c9, $29, $25, $ad, $de, $03, $ff, $8d, $00, $2d, $ed, $35, $ce
	db $ff, $cf, $54, $6b, $68, $0b, $57, $bf, $03, $ff, $ad, $00, $00, $01, $07, $0f
	db $1a, $17, $1f, $17, $1e, $3f, $7f, $ff, $f4, $6b, $30, $00, $00, $fc, $aa, $f5
	db $ff, $ff, $fd, $de, $ef, $ff, $fd, $fa, $7c, $08, $f0, $00, $6a, $0a, $56, $bd
	db $e7, $1b, $f7, $2e, $5f, $5d, $a6, $da, $03, $ff, $81, $00, $03, $ab, $89, $57
	db $bf, $5f, $bf, $bf, $df, $37, $ab, $b7, $03, $ff, $86, $00, $d5, $ee, $ee, $de
	db $ef, $04, $d7, $83, $d6, $d1, $ee, $03, $ff, $8d, $00, $76, $8d, $b4, $85, $f0
	db $ef, $f2, $ef, $f2, $ee, $53, $ec, $03, $ff, $8d, $00, $d4, $54, $95, $66, $fd
	db $62, $df, $62, $ee, $ea, $66, $dd, $03, $ff, $89, $00, $8a, $92, $62, $cd, $ff
	db $7f, $bf, $7f, $07, $ff, $83, $00, $be, $7e, $0a, $fe, $95, $fa, $f4, $f8, $00
	db $00, $1f, $2f, $5f, $7c, $7f, $7c, $7e, $7e, $7d, $7d, $7e, $7c, $7f, $7c, $7f
	db $00, $03, $ff, $8d, $86, $f8, $8b, $ab, $a8, $6b, $68, $d7, $07, $fb, $44, $6f
	db $00, $03, $ff, $8d, $96, $95, $f1, $4e, $46, $f9, $25, $ae, $df, $2e, $97, $ca
	db $00, $04, $ff, $8c, $77, $4b, $b7, $cf, $3f, $07, $fb, $1f, $ef, $0f, $b7, $00
	db $04, $ff, $ff, $e0, $ef, $e0, $ef, $e9, $ef, $e0, $f1, $ee, $f1, $df, $00, $7b
	db $6f, $51, $38, $7f, $7f, $de, $ff, $ff, $f7, $c0, $68, $23, $7f, $7f, $00, $f7
	db $1d, $8b, $ce, $e5, $bd, $ff, $ff, $eb, $ff, $2a, $ff, $e5, $83, $ff, $00, $7b
	db $77, $69, $78, $7e, $7f, $7f, $5f, $3e, $f7, $e0, $83, $7d, $7f, $7f, $f0, $3d
	db $0e, $c3, $71, $1f, $87, $e1, $3f, $ff, $3f, $de, $fb, $7f, $f3, $dd, $07, $f8
	db $f6, $f8, $fc, $8e, $fe, $c2, $fc, $40, $7f, $7b, $7f, $5e, $2f, $5f, $e0, $1b
	db $07, $65, $f3, $f3, $63, $03, $33, $7b, $ff, $b7, $cb, $7d, $07, $ff, $00, $7b
	db $74, $69, $b2, $c1, $00, $ff, $60, $5d, $7b, $73, $71, $69, $77, $7b, $76, $ff
	db $7b, $3b, $96, $9b, $c7, $ff, $7f, $fe, $ff, $ff, $b7, $c9, $bb, $87, $fc, $00
	db $3c, $7f, $ff, $ff, $bd, $43, $3e, $4f, $7f, $03, $ff, $97, $80, $40, $7f, $00
	db $bf, $ff, $b7, $8f, $85, $72, $9f, $0a, $f2, $fb, $fe, $fd, $7a, $71, $ff, $00
	db $ff, $fc, $90, $03, $7f, $8e, $3f, $5f, $9d, $b8, $b8, $7f, $40, $7f, $7f, $00
	db $ff, $01, $00, $fc, $03, $fe, $b5, $f7, $8b, $1d, $1d, $cb, $06, $fb, $ff, $00
	db $77, $58, $64, $28, $51, $51, $7f, $3f, $3f, $7f, $ff, $af, $57, $21, $7f, $00
	db $ef, $1b, $45, $93, $0a, $01, $c1, $ed, $ed, $f1, $fa, $6d, $92, $e1, $ff, $00
	db $7f, $7b, $6c, $53, $6f, $2f, $43, $bb, $fb, $fd, $7b, $3f, $03, $7f, $8d, $00
	db $ff, $df, $37, $cb, $f7, $f5, $c2, $dd, $df, $bf, $de, $fd, $03, $ff, $81, $00
	db $03, $ff, $8d, $fd, $6a, $55, $57, $57, $56, $51, $ae, $f1, $ee, $f0, $6b, $00
	db $03, $ff, $8d, $7b, $a5, $5e, $e9, $de, $ea, $68, $f7, $f2, $ed, $f2, $69, $00
	db $04, $ff, $8c, $f0, $ef, $d8, $6a, $aa, $aa, $55, $af, $57, $94, $6b, $00, $03
	db $ff, $98, $fb, $e4, $5f, $a8, $9d, $a6, $a8, $6f, $ff, $7f, $bf, $7f, $00, $f8
	db $f4, $fa, $fe, $fe, $7e, $7e, $be, $7e, $7e, $be, $04, $fe, $05, $7f, $97, $7e
	db $7e, $7d, $7e, $7d, $7e, $7d, $5f, $2f, $1f, $00, $55, $4d, $5e, $5c, $74, $8b
	db $ea, $85, $f6, $89, $a8, $97, $03, $ff, $8d, $00, $29, $25, $ae, $df, $47, $fb
	db $08, $f7, $4c, $f5, $56, $f8, $03, $ff, $8d, $00, $4b, $ab, $0b, $77, $d7, $6b
	db $97, $cb, $ab, $27, $2f, $df, $03, $ff, $8d, $00, $e2, $f5, $ea, $d5, $fb, $e5
	db $de, $e9, $de, $ea, $e8, $f7, $03, $ff, $8d, $00, $d4, $da, $60, $b7, $f1, $ee
	db $f0, $eb, $54, $9a, $a0, $77, $03, $ff, $8d, $00, $95, $aa, $a2, $4d, $f1, $ee
	db $f1, $5f, $a2, $b5, $aa, $55, $03, $ff, $8d, $00, $6c, $93, $90, $6f, $f0, $ef
	db $f2, $6f, $f2, $ee, $53, $ac, $03, $ff, $8d, $00, $ff, $ff, $7f, $bf, $fd, $62
	db $df, $62, $ee, $ea, $66, $dd, $03, $ff, $81, $00, $05, $fe, $83, $7e, $be, $7e
	db $04, $fe, $83, $fa, $f4, $f8, $09, $00, $09, $ff, $0f, $80, $81, $ff, $0f, $00
	db $10, $f8, $10, $0f, $20, $ff, $04, $00, $84, $03, $04, $09, $0b, $08, $0f, $03
	db $00, $83, $03, $04, $0b, $04, $0e, $86, $1f, $17, $ff, $00, $ff, $ff, $0c, $00
	db $84, $ff, $00, $ff, $ff, $09, $0f, $83, $0e, $07, $03, $04, $00, $83, $c0, $c0
	db $c1, $04, $c3, $82, $c2, $c0, $03, $c1, $89, $c3, $c1, $c1, $c0, $5f, $ff, $7f
	db $b8, $b8, $03, $1f, $ac, $88, $dc, $dc, $f8, $fd, $f8, $f8, $fc, $f8, $fd, $ff
	db $7b, $f3, $fb, $ff, $eb, $11, $3b, $73, $e1, $c1, $e3, $73, $39, $e0, $e0, $e1
	db $eb, $ff, $ff, $fb, $f3, $3c, $9d, $bf, $f9, $f3, $c1, $f9, $fd, $00, $f0, $f8
	db $fc, $03, $dc, $8b, $b8, $40, $f0, $f8, $f8, $fc, $f8, $f8, $fc, $02, $0f, $04
	db $3f, $85, $37, $3e, $04, $1e, $3f, $03, $1f, $b2, $3f, $1f, $00, $13, $bb, $f9
	db $f9, $bf, $3e, $1c, $02, $17, $bf, $bf, $ff, $bf, $3d, $9b, $01, $0f, $bf, $ff
	db $fe, $ce, $87, $03, $0f, $1f, $8f, $df, $cf, $df, $ff, $9f, $84, $ce, $8c, $1c
	db $1e, $3e, $b7, $f7, $02, $9f, $3f, $9f, $1f, $1f, $9f, $3e, $05, $03, $87, $83
	db $c3, $83, $03, $83, $c3, $83, $04, $03, $8a, $01, $03, $07, $0e, $1c, $38, $70
	db $e0, $fc, $fc, $06, $0c, $84, $1f, $3f, $70, $e0, $03, $c3, $82, $c1, $c1, $03
	db $c3, $81, $c1, $03, $c3, $dc, $ff, $ff, $00, $00, $f9, $ff, $ff, $dc, $df, $9f
	db $9f, $38, $f0, $f9, $b8, $b9, $ff, $ff, $00, $00, $fc, $fc, $ff, $f3, $fb, $ff
	db $fb, $73, $f0, $f9, $f3, $fb, $ff, $ff, $00, $00, $3c, $94, $f8, $fc, $fc, $f8
	db $f0, $e0, $00, $30, $b9, $9f, $fc, $fc, $00, $00, $08, $1f, $1f, $3f, $1f, $3f
	db $3d, $3f, $00, $f0, $f8, $fc, $3f, $3f, $00, $00, $88, $dd, $fb, $bb, $bf, $db
	db $cf, $9e, $05, $0f, $17, $3b, $ff, $ff, $00, $00, $01, $0f, $bf, $bf, $be, $8e
	db $07, $03, $03, $ff, $88, $87, $ff, $ff, $00, $00, $84, $de, $bf, $03, $1f, $9d
	db $bf, $df, $8e, $de, $fe, $be, $ff, $ff, $00, $00, $01, $0f, $bf, $bf, $fe, $8e
	db $07, $83, $03, $09, $3f, $bf, $f8, $fc, $0e, $07, $83, $c3, $83, $03, $03, $85
	db $83, $c3, $c3, $43, $83, $05, $c3, $82, $c0, $c0, $06, $c3, $d4, $e0, $70, $3f
	db $1f, $f8, $b9, $bb, $f9, $20, $f1, $fb, $ff, $ff, $fb, $73, $e1, $00, $00, $ff
	db $ff, $f3, $f3, $fb, $f1, $00, $30, $bb, $9f, $9f, $fc, $e8, $c0, $00, $00, $ff
	db $ff, $00, $01, $06, $08, $17, $1c, $18, $1b, $13, $20, $40, $86, $8f, $5b, $30
	db $00, $00, $fc, $76, $1b, $01, $01, $e7, $e2, $59, $79, $13, $36, $a4, $f8, $f0
	db $00, $9f, $ff, $eb, $c3, $18, $fc, $f8, $f1, $e1, $e3, $7b, $3f, $00, $00, $ff
	db $ff, $03, $dc, $92, $b8, $40, $e0, $c0, $c0, $e0, $e8, $7c, $78, $00, $00, $ff
	db $ff, $3b, $31, $31, $21, $10, $04, $38, $a5, $39, $3f, $1f, $00, $00, $ff, $ff
	db $8f, $ff, $ff, $fe, $0f, $1f, $0f, $1f, $0f, $1f, $bf, $1f, $00, $00, $ff, $ff
	db $3f, $bf, $ff, $bf, $02, $9f, $3f, $9f, $1f, $1f, $9f, $3e, $00, $00, $04, $ff
	db $86, $bf, $3e, $00, $80, $c0, $80, $06, $00, $84, $ff, $ff, $c3, $83, $0a, $03
	db $88, $07, $0e, $fc, $f8, $1f, $3f, $70, $e0, $03, $c3, $82, $c1, $c1, $06, $c3
	db $a3, $c0, $ff, $ff, $00, $00, $f9, $ff, $ff, $dc, $df, $9f, $9f, $38, $f8, $fc
	db $fb, $f3, $ff, $ff, $00, $00, $fd, $ff, $ff, $f1, $f9, $ff, $fb, $71, $20, $f1
	db $f8, $fd, $ff, $ff, $03, $00, $8f, $88, $bc, $f8, $f0, $c0, $f8, $fc, $e0, $f0
	db $f0, $f8, $ff, $ff, $00, $00, $08, $3f, $bc, $0e, $1f, $0e, $3f, $ff, $87, $9c
	db $be, $e7, $df, $ff, $bf, $9e, $c8, $bf, $bf, $df, $ff, $de, $ff, $ff, $f8, $ee
	db $76, $33, $fb, $db, $1f, $1f, $37, $e3, $f7, $fe, $1e, $7e, $fe, $ff, $87, $8c
	db $9e, $97, $91, $9e, $9f, $b7, $e9, $cf, $1f, $ff, $fe, $80, $80, $ff, $ce, $f3
	db $3d, $8f, $e2, $7a, $df, $04, $ff, $8b, $fc, $fe, $8e, $be, $ff, $cf, $ff, $cf
	db $87, $f3, $fb, $04, $ff, $c1, $c4, $c7, $e5, $f8, $bf, $ff, $fc, $fc, $9e, $0e
	db $0e, $9e, $fe, $ff, $ce, $85, $ce, $ff, $fe, $fc, $fc, $ff, $87, $8f, $9f, $ff
	db $fe, $ff, $ff, $bf, $bf, $9e, $9e, $9f, $9f, $8e, $87, $ff, $8a, $d6, $ef, $7e
	db $3d, $3c, $c7, $bb, $4d, $85, $cf, $ff, $7e, $7f, $fc, $ff, $ff, $c3, $91, $81
	db $c3, $ff, $ff, $f0, $ff, $aa, $9a, $05, $ff, $9b, $e0, $50, $fc, $fa, $fe, $8f
	db $65, $f7, $ff, $4d, $ab, $9b, $f7, $8f, $ff, $ff, $c7, $bf, $ff, $f0, $9f, $95
	db $ff, $ff, $eb, $d7, $d7, $03, $ff, $be, $80, $ff, $fe, $ff, $ff, $03, $fd, $4d
	db $1d, $fe, $f7, $e3, $e3, $f7, $ff, $fc, $00, $ff, $8f, $bf, $bb, $f7, $ee, $ee
	db $c0, $ff, $f6, $df, $8f, $df, $ff, $ff, $bf, $ff, $f0, $fc, $be, $6e, $f7, $ff
	db $3f, $df, $ff, $9f, $0f, $9e, $ff, $ff, $3f, $ff, $80, $87, $9f, $bc, $b0, $f0
	db $fc, $c6, $86, $82, $c4, $ff, $03, $80, $8d, $ff, $00, $e0, $f8, $3c, $0c, $0e
	db $3f, $63, $61, $41, $23, $fe, $03, $00, $a2, $ff, $ff, $00, $00, $c2, $d7, $fa
	db $f8, $f8, $f9, $ff, $df, $0e, $1f, $0f, $9f, $ff, $ff, $00, $00, $84, $de, $bf
	db $1e, $3f, $1d, $9f, $0f, $0d, $1f, $0f, $96, $ff, $ff, $03, $00, $a7, $0f, $1f
	db $3f, $bd, $fd, $fd, $bb, $d0, $f8, $fb, $9f, $ff, $ff, $00, $00, $04, $1f, $bf
	db $df, $ff, $df, $df, $9f, $00, $80, $c0, $80, $f8, $fc, $0e, $07, $03, $03, $83
	db $83, $c3, $83, $83, $c3, $04, $03, $05, $c0, $84, $c1, $c1, $c3, $c1, $03, $c3
	db $92, $e0, $70, $3f, $1f, $fb, $f3, $e3, $e3, $8b, $ff, $ff, $fb, $f9, $ff, $df
	db $fb, $00, $00, $03, $ff, $ef, $fb, $71, $e0, $f8, $fc, $ff, $fb, $f3, $fb, $fb
	db $ff, $00, $00, $ff, $ff, $fc, $dc, $fc, $f8, $3c, $94, $f8, $fc, $fc, $f8, $f0
	db $e0, $00, $00, $ff, $ff, $1f, $0e, $1f, $3b, $04, $1e, $3f, $1e, $3f, $1d, $1f
	db $0f, $00, $00, $ff, $ff, $3f, $3d, $9f, $cf, $0e, $1f, $0f, $1f, $bf, $fd, $df
	db $8f, $00, $00, $ff, $ff, $fe, $f7, $ff, $be, $0e, $1f, $0e, $bf, $df, $ce, $df
	db $bb, $00, $00, $ff, $ff, $9f, $fc, $ff, $9f, $0f, $1f, $0f, $9f, $0f, $1f, $bf
	db $df, $00, $00, $ff, $ff, $00, $00, $80, $c0, $02, $9f, $3f, $9f, $1f, $1f, $9f
	db $3e, $00, $00, $ff, $ff, $05, $03, $83, $83, $c3, $83, $04, $03, $84, $07, $0e
	db $fc, $f8, $12, $00, $00, $c0, $00, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55
	db $2a, $55, $2a, $55, $2a, $55, $00, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55
	db $aa, $55, $aa, $55, $aa, $55, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd
	db $ca, $cd, $ca, $cd, $ca, $cd, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f
	db $af, $5f, $af, $5f, $af, $5f, $10, $fc, $10, $3f, $81, $00, $0f, $7f, $81, $00
	db $0f, $ff, $10, $cf, $10, $ff, $84, $0f, $1f, $3b, $37, $08, $3f, $84, $37, $3b
	db $1f, $0f, $10, $ff, $04, $00, $88, $01, $0f, $1e, $1b, $1b, $1e, $0f, $01, $08
	db $00, $08, $ff, $04, $00, $90, $3f, $7f, $ef, $df, $fe, $fd, $fb, $f6, $f6, $f7
	db $f6, $f1, $f0, $f7, $f6, $f7, $04, $ff, $8c, $7f, $bf, $df, $6f, $6f, $ef, $6f
	db $8f, $3f, $df, $6f, $df, $15, $ff, $88, $f8, $f7, $f8, $fb, $fa, $f9, $f7, $fb
	db $03, $f5, $04, $ff, $8c, $78, $97, $e8, $99, $b6, $b9, $b2, $7d, $fd, $f2, $ff
	db $f4, $04, $ff, $8c, $3f, $df, $bf, $df, $2f, $af, $af, $df, $ff, $9b, $65, $95
	db $0d, $ff, $87, $3f, $5f, $af, $fc, $fe, $f7, $fb, $0c, $ff, $96, $f6, $f6, $f7
	db $f0, $ff, $f5, $ff, $fb, $fd, $f7, $fb, $f5, $df, $ef, $7f, $3f, $6f, $6f, $df
	db $3f, $ff, $d7, $0f, $ff, $81, $7f, $0a, $ff, $8c, $f5, $f5, $f4, $fb, $ff, $fb
	db $fc, $f7, $fc, $f4, $f4, $fb, $04, $ff, $8c, $f4, $b9, $52, $bd, $7f, $fc, $93
	db $ec, $93, $9f, $0c, $db, $04, $ff, $82, $00, $00, $04, $ff, $8c, $e7, $db, $bd
	db $66, $66, $7e, $66, $18, $ff, $ff, $00, $00, $0e, $ff, $82, $00, $00, $04, $ff
	db $8c, $f7, $ab, $5d, $6a, $d2, $b2, $aa, $d5, $ff, $ff, $00, $00, $04, $ff, $8c
	db $fb, $f5, $eb, $d7, $af, $d7, $eb, $f5, $ff, $ff, $00, $00, $04, $ff, $8c, $83
	db $7d, $8b, $9d, $62, $9a, $2a, $dd, $ff, $ff, $00, $00, $0e, $ff, $87, $3f, $7f
	db $ef, $df, $f8, $f7, $f8, $03, $ff, $86, $f8, $f7, $df, $ef, $7f, $3f, $04, $ff
	db $88, $1f, $ef, $2c, $a3, $ac, $a2, $2e, $ee, $08, $ff, $88, $a1, $5e, $b1, $7f
	db $bf, $bf, $b0, $bf, $09, $ff, $87, $dd, $a2, $af, $a2, $54, $b8, $73, $08, $ff
	db $88, $5e, $a9, $57, $2a, $a4, $94, $b9, $7a, $08, $ff, $88, $fd, $7a, $d5, $15
	db $e6, $19, $1c, $eb, $08, $ff, $88, $fc, $bb, $5c, $5b, $5c, $5b, $b4, $7b, $08
	db $ff, $88, $3f, $db, $bc, $d7, $bc, $b4, $d4, $3b, $08, $ff, $88, $7e, $fd, $9e
	db $ea, $9f, $94, $0a, $da, $04, $ff, $9a, $fc, $fe, $f7, $fb, $ff, $7f, $ff, $ff
	db $7f, $df, $af, $df, $fb, $f7, $fe, $fc, $ff, $ff, $03, $7d, $66, $7d, $66, $66
	db $7d, $03, $04, $ff, $0a, $00, $88, $ff, $eb, $cc, $cf, $c8, $bf, $bf, $b0, $08
	db $00, $8b, $c3, $c3, $00, $c3, $00, $ff, $ff, $00, $b0, $a0, $e0, $04, $20, $85
	db $10, $08, $04, $02, $01, $04, $00, $82, $ff, $db, $04, $bd, $86, $a5, $ff, $ff
	db $00, $00, $ff, $04, $00, $10, $ff, $81, $3f, $0e, $3d, $82, $3f, $38, $0e, $28
	db $a1, $38, $00, $01, $07, $0f, $1a, $17, $1f, $17, $1e, $3f, $7f, $ff, $f4, $6b
	db $30, $00, $00, $fc, $aa, $f5, $ff, $ff, $fd, $de, $ef, $ff, $fd, $fa, $7c, $08
	db $f0, $00, $0e, $ff, $82, $00, $00, $03, $ff, $87, $c3, $bd, $c2, $f5, $bb, $41
	db $be, $04, $ff, $8c, $00, $00, $ff, $ff, $ef, $97, $7d, $a1, $4e, $41, $91, $ae
	db $04, $ff, $85, $00, $00, $1d, $23, $41, $04, $7f, $81, $3e, $04, $7f, $87, $41
	db $22, $1c, $00, $fb, $0c, $0c, $09, $ff, $87, $99, $99, $ff, $00, $be, $61, $60
	db $09, $ff, $89, $24, $24, $ff, $00, $fc, $84, $84, $fc, $fc, $03, $f8, $81, $78
	db $03, $f8, $90, $c8, $c8, $f8, $00, $55, $d4, $65, $9a, $ff, $3a, $d5, $26, $ad
	db $ab, $5a, $bd, $04, $ff, $8c, $af, $2f, $5f, $ff, $7f, $bb, $d5, $a5, $25, $24
	db $a5, $5a, $09, $ff, $8b, $3f, $5f, $af, $af, $2f, $5f, $ff, $fb, $f7, $fe, $fc
	db $11, $00, $a6, $a2, $17, $ff, $fe, $ff, $7f, $bf, $bf, $fd, $ff, $97, $ff, $fd
	db $df, $7f, $81, $03, $03, $a6, $8f, $fc, $7f, $b7, $c0, $85, $29, $83, $0d, $ef
	db $ff, $f8, $fb, $f6, $ef, $bd, $fb, $cf, $7f, $08, $ff, $ae, $fe, $bf, $3e, $3f
	db $bf, $36, $3f, $3f, $37, $77, $ef, $db, $fd, $ba, $63, $f5, $fc, $ff, $ef, $ff
	db $bb, $ff, $bf, $7f, $36, $ff, $ff, $eb, $bf, $df, $7f, $ed, $ff, $7d, $ef, $fb
	db $fb, $b7, $fe, $dd, $bf, $f7, $9f, $bf, $7f, $bf, $03, $ff, $9d, $fe, $eb, $f5
	db $db, $df, $f7, $ff, $fe, $d7, $bf, $7f, $ef, $5f, $ef, $ff, $fd, $fb, $f7, $6f
	db $9f, $f7, $fe, $ff, $ff, $fb, $f7, $df, $b7, $ef, $03, $ff, $b0, $fe, $fd, $bf
	db $bb, $fc, $77, $7f, $ee, $ff, $e3, $8e, $7f, $df, $f7, $6f, $bf, $df, $ef, $77
	db $bf, $db, $fd, $ef, $f7, $ef, $ff, $ff, $79, $f7, $ef, $bb, $2f, $ef, $fb, $ff
	db $9d, $ff, $f6, $f8, $fe, $fd, $ff, $ff, $fe, $ff, $ff, $fe, $ff, $03, $3f, $9e
	db $bf, $bf, $3f, $3d, $37, $fe, $df, $fd, $fb, $a7, $ed, $77, $5d, $79, $ff, $ef
	db $ff, $2f, $6f, $df, $bf, $af, $fe, $ee, $f7, $ff, $fd, $fe, $ff, $7f, $04, $ff
	db $83, $7f, $ff, $be, $06, $ff, $8d, $f7, $5b, $ff, $fd, $ff, $ff, $fe, $fe, $fc
	db $e7, $ff, $f7, $fb, $04, $ff, $91, $37, $ef, $ef, $ff, $f9, $f6, $ff, $fb, $ac
	db $ff, $7f, $fe, $df, $ff, $ff, $df, $b3, $0a, $00, $a2, $80, $c0, $e0, $f0, $f8
	db $fc, $00, $80, $c0, $e0, $f0, $f8, $fc, $fe, $7f, $3f, $1f, $0f, $07, $03, $01
	db $00, $ff, $f8, $e0, $c0, $80, $03, $03, $01, $80, $00, $00, $38, $03, $fc, $85
	db $e0, $01, $00, $00, $1c, $03, $3f, $ac, $07, $ff, $1f, $07, $03, $11, $d0, $e0
	db $a4, $80, $c0, $f0, $fc, $f0, $e0, $e0, $f0, $01, $03, $0e, $00, $00, $0c, $1c
	db $3c, $80, $c0, $70, $00, $00, $30, $38, $3c, $25, $1b, $0f, $3f, $0f, $07, $07
	db $0f, $ff, $c7, $83, $09, $fe, $87, $82, $c4, $f9, $e3, $ff, $c5, $c5, $08, $fd
	db $88, $ff, $c2, $c2, $fe, $c0, $ff, $c7, $83, $04, $fe, $8c, $9c, $fd, $f9, $f3
	db $ff, $82, $82, $fe, $80, $ff, $c7, $83, $03, $fe, $83, $fc, $fd, $ff, $03, $fe
	db $87, $82, $c4, $f9, $e3, $ff, $95, $95, $05, $fd, $81, $ff, $03, $fe, $89, $94
	db $f5, $fd, $f1, $ff, $82, $82, $fe, $f0, $03, $ff, $04, $fe, $87, $82, $c4, $f9
	db $e3, $ff, $c7, $83, $03, $fe, $82, $fc, $ff, $04, $fe, $97, $82, $c4, $f9, $e3
	db $ff, $82, $82, $fe, $9e, $fe, $fc, $fd, $fd, $f9, $fb, $fb, $cb, $cb, $fb, $c3
	db $ff, $c7, $83, $03, $fe, $83, $fc, $fd, $ff, $03, $fe, $87, $82, $c4, $f9, $e3
	db $ff, $c7, $83, $09, $fe, $84, $82, $c4, $f9, $e3, $08, $00, $0a, $ff, $88, $83
	db $7d, $8b, $9d, $62, $9a, $2a, $dd, $04, $ff, $82, $00, $00, $0a, $ff, $90, $fb
	db $f7, $fe, $fc, $00, $00, $ff, $ff, $c7, $bb, $c7, $7d, $8b, $d7, $a9, $56, $04
	db $ff, $0a, $00, $0a, $ff, $16, $00, $07, $ff, $81, $fb, $08, $00, $07, $ff, $86
	db $fe, $fb, $8f, $88, $8c, $8f, $03, $8c, $86, $ff, $80, $9f, $bf, $df, $bf, $04
	db $ff, $83, $03, $03, $ff, $03, $02, $82, $ff, $00, $06, $ff, $84, $88, $8c, $ff
	db $80, $07, $9f, $89, $bf, $df, $bf, $ff, $ff, $02, $02, $ff, $00, $0c, $ff, $bf
	db $fc, $8c, $8f, $8c, $8c, $8f, $8c, $8c, $3f, $28, $fb, $3a, $0a, $fb, $0a, $0a
	db $fc, $14, $df, $5c, $50, $df, $50, $50, $3f, $31, $f1, $31, $31, $f1, $31, $31
	db $8f, $8c, $8c, $8f, $8c, $8c, $8f, $ff, $fb, $04, $03, $ff, $00, $00, $ff, $ff
	db $df, $20, $c0, $ff, $00, $00, $ff, $ff, $f1, $31, $31, $f1, $31, $31, $f1, $03
	db $ff, $8c, $fb, $88, $8f, $8c, $8c, $8f, $8c, $8c, $8f, $8c, $8c, $8f, $05, $ff
	db $8a, $00, $ff, $00, $03, $ff, $03, $02, $fe, $02, $03, $06, $ff, $8a, $00, $ff
	db $00, $c0, $ff, $c0, $40, $7f, $40, $c0, $05, $ff, $8e, $df, $11, $f1, $31, $31
	db $f1, $31, $31, $f1, $31, $31, $f1, $ff, $ff, $08, $00, $04, $ff, $84, $80, $80
	db $9f, $9f, $08, $00, $88, $ff, $ff, $fe, $ff, $00, $00, $ff, $ff, $08, $00, $88
	db $ff, $ff, $7f, $ff, $00, $00, $ff, $ff, $08, $00, $04, $ff, $84, $01, $01, $f9
	db $f9, $07, $9f, $87, $bf, $9f, $df, $9f, $bf, $df, $bf, $22, $ff, $07, $f9, $8a
	db $fd, $f9, $fb, $f9, $fd, $fb, $fd, $ff, $ff, $03, $03, $07, $87, $0d, $7d, $f3
	db $ff, $f3, $7d, $0d, $03, $07, $81, $03, $04, $00, $89, $1c, $1f, $1f, $0e, $0d
	db $0e, $1f, $1f, $1c, $08, $00, $8c, $1c, $3f, $3b, $1f, $0f, $07, $0d, $0f, $07
	db $02, $00, $00, $08, $ff, $09, $00, $07, $7f, $81, $00, $07, $ff, $81, $00, $07
	db $7f, $81, $00, $07, $ff, $81, $00, $07, $7f, $81, $00, $07, $ff, $81, $00, $07
	db $ff, $81, $00, $08, $ff, $81, $80, $03, $bf, $8d, $bc, $bd, $bd, $ff, $01, $ff
	db $ff, $f7, $37, $f7, $f7, $ff, $80, $06, $bf, $84, $ff, $01, $ff, $ff, $04, $f7
	db $82, $ff, $80, $03, $bf, $8d, $b8, $bf, $bf, $ff, $01, $ff, $ff, $f7, $37, $f7
	db $f7, $ff, $80, $03, $bf, $83, $b8, $bf, $bf, $05, $f7, $83, $e7, $ff, $ff, $08
	db $7f, $08, $ff, $08, $7f, $08, $ff, $08, $7f, $18, $ff, $03, $bd, $85, $bf, $bf
	db $b8, $bf, $ff, $05, $f7, $83, $07, $ff, $ff, $07, $bf, $81, $ff, $05, $f7, $95
	db $e7, $ff, $ff, $bf, $bc, $bd, $bf, $bf, $b8, $bf, $ff, $f7, $07, $ff, $ff, $f7
	db $07, $ff, $ff, $bf, $be, $03, $bf, $85, $b8, $bf, $ff, $f7, $37, $03, $f7, $81
	db $07, $03, $ff, $83, $80, $bf, $bf, $03, $bd, $85, $bf, $ff, $01, $ff, $ff, $04
	db $f7, $82, $ff, $80, $03, $bf, $8d, $bc, $bd, $bf, $ff, $01, $ff, $ff, $f7, $07
	db $ff, $ff, $ba, $7d, $04, $ff, $83, $7d, $3a, $ef, $06, $ff, $81, $ef, $0b, $ff
	db $85, $fc, $f0, $e3, $e4, $e5, $03, $ff, $84, $00, $00, $ff, $00, $04, $ff, $84
	db $0f, $07, $c5, $25, $0b, $e5, $86, $e3, $e0, $f0, $ff, $f8, $ff, $03, $e5, $9f
	db $05, $0b, $f7, $0f, $ff, $e5, $a5, $a5, $c9, $d1, $a1, $a1, $e9, $38, $10, $00
	db $01, $02, $12, $2a, $06, $0c, $00, $8c, $08, $00, $43, $0b, $16, $bf, $b8, $05
	db $bf, $83, $ff, $f7, $37, $03, $f7, $85, $e7, $ff, $ff, $bf, $b8, $03, $bf, $85
	db $b8, $bf, $ff, $ff, $80, $03, $bf, $83, $b8, $bf, $bf, $05, $ff, $9d, $f6, $fb
	db $fd, $ff, $ff, $df, $f7, $fb, $1f, $ed, $ff, $ff, $2c, $df, $f7, $eb, $f6, $f9
	db $fe, $ff, $fd, $fe, $fb, $f5, $db, $e7, $3f, $ff, $c7, $04, $a3, $81, $c7, $0c
	db $ff, $87, $fb, $ff, $ff, $fb, $ff, $ff, $bb, $04, $ff, $e6, $bb, $ff, $ff, $99
	db $e7, $10, $88, $07, $00, $ff, $ff, $fd, $c5, $c5, $cd, $fd, $81, $ff, $1e, $3c
	db $3e, $bb, $b7, $2f, $3c, $1b, $4f, $ff, $fb, $fd, $7e, $5f, $fe, $af, $07, $00
	db $87, $0c, $08, $20, $05, $03, $00, $03, $29, $92, $27, $57, $cf, $af, $1c, $00
	db $eb, $ff, $fe, $f7, $ff, $7f, $20, $00, $6b, $b6, $de, $fe, $bf, $ff, $07, $00
	db $91, $00, $43, $cb, $b7, $4e, $10, $00, $62, $d5, $c7, $df, $ee, $ff, $00, $3e
	db $ff, $ed, $bf, $ef, $bf, $7f, $30, $00, $bf, $ff, $7e, $b7, $dd, $ea, $1e, $27
	db $3f, $3b, $04, $3f, $83, $ff, $df, $bf, $03, $ff, $86, $6f, $7f, $cf, $fd, $ff
	db $fe, $04, $ff, $f8, $fd, $5b, $be, $f5, $ff, $ed, $fb, $dd, $b5, $7e, $fb, $fb
	db $ff, $bf, $7d, $ff, $7b, $ff, $dd, $f3, $7e, $9f, $7f, $f7, $bf, $6b, $dd, $bf
	db $d6, $6f, $df, $bb, $bf, $76, $ff, $dd, $ff, $6e, $7f, $f7, $4f, $fd, $f7, $ef
	db $df, $fb, $fe, $77, $ff, $f6, $5f, $ff, $f7, $7d, $ef, $fe, $fa, $ff, $f7, $ff
	db $ff, $b7, $7b, $cf, $ff, $ff, $bf, $f7, $fb, $7f, $ed, $be, $ff, $db, $f7, $ba
	db $fd, $df, $f7, $dd, $79, $ff, $ff, $fd, $a7, $ff, $ad, $f3, $ff, $af, $df, $bf
	db $f7, $ff, $bf, $7f, $ef, $ff, $ff, $f5, $ff, $ff, $bf, $fb, $3d, $3f, $3b, $3e
	db $be, $bf, $3b, $bf, $df, $57, $9f, $3f, $9e, $2f, $5e, $f9, $08, $ff, $e1, $f3
	db $f6, $db, $ed, $f7, $fc, $fd, $bf, $be, $fd, $b7, $6f, $fe, $e7, $db, $dd, $df
	db $ff, $bb, $9e, $ff, $79, $df, $bb, $6f, $f7, $6f, $3e, $ef, $cd, $ff, $f6, $af
	db $de, $b1, $3f, $ff, $db, $bf, $d5, $3f, $f7, $7f, $ef, $bf, $ef, $d8, $5f, $df
	db $ff, $fc, $ff, $dd, $df, $1e, $ff, $bd, $3f, $3e, $37, $1f, $39, $3b, $3f, $ef
	db $bb, $6f, $77, $db, $d7, $7d, $de, $7f, $db, $b7, $ff, $fd, $df, $fc, $30, $fd
	db $bf, $7f, $7f, $bf, $ff, $df, $7f, $7f, $ff, $ff, $fe, $fb, $f7, $ee, $fd, $ef
	db $04, $ff, $8c, $8d, $d1, $80, $fb, $ff, $ff, $bf, $f7, $fd, $3f, $e7, $ef, $03
	db $ff, $b8, $f3, $df, $fd, $cb, $fb, $ef, $dd, $bb, $fe, $fd, $6b, $fd, $fb, $47
	db $08, $17, $b7, $ff, $b1, $7f, $37, $3d, $3f, $36, $25, $4b, $0e, $3f, $7b, $ff
	db $7f, $cf, $9f, $ff, $bf, $df, $ff, $df, $ef, $7f, $ff, $f7, $cf, $ff, $d0, $fc
	db $bf, $e7, $fd, $ff, $fb, $f7, $5f, $df, $ff, $bf, $03, $ff, $8b, $fe, $ff, $ff
	db $fe, $ff, $fd, $fe, $ff, $ef, $3e, $3f, $03, $bf, $03, $3f, $e8, $f7, $ef, $fc
	db $fe, $fd, $7b, $ff, $cf, $7c, $dd, $ec, $f7, $fe, $ff, $fb, $bf, $ff, $37, $9b
	db $3f, $07, $8d, $42, $81, $ff, $fd, $ee, $77, $ff, $fe, $d0, $42, $83, $56, $fc
	db $f8, $b0, $e2, $00, $39, $87, $07, $2b, $ab, $12, $85, $a4, $8c, $d0, $40, $92
	db $2a, $9a, $30, $50, $e2, $ff, $d2, $ee, $ce, $ab, $0d, $b5, $3f, $ff, $fe, $7f
	db $7f, $78, $ff, $fd, $7e, $3b, $37, $3d, $3f, $3e, $3f, $bf, $bf, $f4, $7f, $ef
	db $bb, $d7, $ed, $7b, $ff, $fe, $ff, $7d, $b6, $6f, $fd, $eb, $ff, $fd, $9b, $fe
	db $ff, $fd, $df, $fb, $ee, $61, $ff, $0f, $80, $81, $ff, $0f, $00, $10, $f8, $11
	db $0f, $83, $1f, $3c, $38, $08, $30, $86, $38, $3c, $1f, $0f, $ff, $ff, $0c, $00
	db $82, $ff, $ff, $04, $00, $88, $03, $0f, $1f, $1c, $1c, $1f, $0f, $03, $08, $00
	db $82, $ff, $ff, $04, $00, $82, $ff, $ff, $04, $00, $87, $7f, $ff, $f0, $e0, $c1
	db $c3, $c7, $04, $cf, $81, $ce, $04, $cf, $87, $ff, $ff, $00, $00, $80, $c0, $e0
	db $04, $f0, $87, $70, $c0, $e0, $f0, $e0, $ff, $ff, $06, $00, $81, $05, $07, $00
	db $82, $ff, $ff, $03, $00, $88, $07, $0f, $07, $47, $07, $07, $0f, $04, $03, $0e
	db $88, $ff, $ff, $00, $00, $87, $ef, $f7, $e7, $03, $cf, $82, $83, $02, $03, $0f
	db $88, $ff, $ff, $00, $00, $c0, $e0, $c0, $e0, $03, $f0, $87, $e0, $00, $64, $fe
	db $6e, $ff, $ff, $0b, $00, $87, $c0, $e0, $70, $fe, $ff, $0f, $07, $0c, $03, $04
	db $cf, $92, $c0, $cf, $ca, $cc, $c6, $ca, $ce, $ce, $e0, $f0, $ff, $7f, $f0, $f0
	db $e0, $c0, $00, $fb, $03, $aa, $88, $bb, $aa, $aa, $00, $00, $ff, $ff, $05, $04
	db $00, $b4, $f0, $a0, $a0, $a5, $20, $a0, $a0, $00, $00, $ff, $ff, $4e, $0e, $0f
	db $07, $00, $04, $07, $0f, $4f, $0f, $0f, $07, $00, $00, $ff, $ff, $0f, $4f, $ef
	db $c3, $80, $83, $ef, $ff, $ec, $e0, $f3, $e7, $00, $00, $ff, $ff, $00, $00, $ff
	db $ff, $00, $00, $18, $3c, $7e, $04, $ff, $81, $e7, $04, $00, $82, $ff, $ff, $06
	db $00, $81, $54, $07, $00, $87, $ff, $ff, $00, $00, $08, $5c, $fe, $03, $ff, $82
	db $f7, $6e, $04, $00, $8c, $ff, $ff, $00, $00, $04, $0e, $1c, $38, $70, $38, $1c
	db $0e, $04, $00, $88, $ff, $ff, $00, $00, $7c, $fe, $7c, $7e, $03, $ff, $81, $3e
	db $04, $00, $82, $ff, $ff, $0c, $00, $87, $3f, $7f, $f0, $e0, $c7, $cf, $c7, $03
	db $c0, $94, $c7, $cf, $e0, $f0, $7f, $3f, $ff, $ff, $00, $00, $e0, $f0, $f3, $7f
	db $7f, $7d, $f1, $f1, $00, $00, $04, $ff, $8c, $00, $00, $7e, $ef, $ce, $80, $c0
	db $c0, $cf, $cf, $00, $00, $04, $ff, $03, $00, $81, $22, $03, $7f, $85, $ef, $cf
	db $8f, $00, $00, $04, $ff, $8c, $00, $00, $f1, $57, $ef, $f7, $ff, $ef, $cf, $8d
	db $00, $00, $04, $ff, $8c, $00, $00, $02, $87, $ee, $ee, $ff, $e6, $e3, $f7, $00
	db $00, $04, $ff, $8c, $00, $00, $03, $47, $e3, $e7, $e3, $e7, $cf, $87, $00, $00
	db $04, $ff, $8c, $00, $00, $c0, $e4, $c7, $ef, $cf, $cf, $ef, $c7, $00, $00, $04
	db $ff, $ac, $00, $00, $81, $83, $e3, $f7, $e7, $ef, $fd, $ed, $00, $00, $ff, $ff
	db $fc, $fe, $0f, $07, $03, $83, $03, $03, $83, $a3, $f3, $e3, $07, $0f, $fe, $fc
	db $00, $00, $fc, $fe, $ff, $fe, $ff, $ff, $fe, $fc, $00, $00, $ff, $ff, $0a, $00
	db $88, $ff, $9c, $bf, $bf, $b8, $ff, $e0, $ef, $08, $00, $8b, $c3, $00, $c3, $c3
	db $00, $ff, $00, $ff, $ef, $ff, $ff, $04, $3f, $85, $1f, $0f, $07, $03, $01, $04
	db $00, $86, $ff, $a5, $c3, $db, $db, $c3, $06, $ff, $04, $00, $81, $ff, $0e, $81
	db $82, $ff, $3f, $0e, $27, $81, $3f, $10, $38, $9f, $00, $01, $06, $08, $17, $1c
	db $18, $1b, $13, $20, $40, $86, $8f, $5b, $30, $00, $00, $fc, $76, $1b, $01, $01
	db $e7, $e2, $59, $79, $13, $36, $a4, $f8, $f0, $07, $00, $81, $54, $05, $00, $82
	db $ff, $ff, $05, $00, $8b, $3c, $7e, $3f, $0e, $44, $fe, $7f, $00, $00, $ff, $ff
	db $04, $00, $91, $10, $78, $fe, $7e, $ff, $fe, $fe, $df, $00, $00, $ff, $ff, $00
	db $00, $1d, $3f, $7f, $03, $49, $83, $4f, $23, $79, $03, $49, $88, $7f, $3f, $1f
	db $0e, $fb, $ff, $ff, $09, $03, $99, $82, $98, $98, $03, $99, $03, $ff, $84, $7f
	db $be, $ff, $ff, $04, $24, $82, $20, $21, $03, $24, $04, $ff, $86, $fc, $fe, $fe
	db $86, $ce, $ce, $06, $cc, $04, $fc, $a0, $ee, $ef, $ff, $e7, $00, $c5, $ef, $ff
	db $7f, $7f, $ef, $c6, $00, $00, $ff, $ff, $70, $f0, $a0, $00, $80, $c4, $ee, $fe
	db $fe, $ff, $7f, $e7, $00, $00, $ff, $ff, $05, $03, $8b, $c3, $e3, $73, $73, $f3
	db $a3, $03, $07, $0f, $ff, $fe, $10, $00, $a7, $ff, $5d, $ef, $ff, $ff, $00, $80
	db $c0, $40, $fe, $fe, $ef, $03, $03, $3f, $ff, $7e, $fc, $fc, $59, $f0, $ff, $ff
	db $cf, $3f, $7a, $d6, $7c, $f3, $1f, $ff, $ff, $07, $0f, $1e, $7e, $fc, $f0, $80
	db $08, $00, $99, $01, $c0, $41, $c1, $c3, $4f, $cc, $cf, $cf, $ef, $ff, $f7, $b7
	db $6d, $fe, $fe, $ff, $f7, $f7, $e7, $c7, $00, $71, $b0, $f9, $03, $f7, $92, $c0
	db $30, $98, $9f, $8f, $83, $f3, $fc, $1c, $78, $f1, $e2, $c0, $e8, $70, $70, $e0
	db $c0, $03, $00, $c9, $0f, $1d, $1b, $36, $24, $08, $00, $01, $fe, $ef, $ef, $df
	db $bd, $7c, $cc, $8f, $06, $0e, $9c, $f8, $f8, $f1, $f1, $ff, $04, $0c, $38, $78
	db $f0, $e0, $c0, $80, $c1, $c3, $c3, $c7, $87, $8d, $8a, $15, $ff, $ff, $f1, $e0
	db $e0, $ac, $d8, $f0, $e0, $f0, $f8, $78, $3d, $1f, $1f, $0f, $1f, $3f, $7f, $fe
	db $f8, $f4, $ec, $f8, $f0, $fc, $fc, $7e, $1e, $0f, $07, $01, $03, $04, $01, $8c
	db $00, $01, $00, $c0, $c0, $40, $c0, $c0, $40, $42, $cf, $1f, $03, $3f, $95, $7c
	db $7b, $de, $ae, $ff, $ff, $90, $30, $f0, $d8, $b0, $60, $df, $ff, $1f, $0f, $07
	db $03, $01, $00, $80, $04, $00, $83, $80, $80, $41, $06, $00, $a2, $08, $fc, $01
	db $02, $00, $00, $01, $01, $03, $1f, $0f, $0f, $06, $00, $00, $01, $01, $c9, $9f
	db $1f, $3f, $7f, $f9, $f0, $e4, $df, $01, $81, $81, $e0, $e0, $70, $38, $cc, $09
	db $00, $a3, $80, $40, $20, $10, $08, $04, $02, $80, $40, $20, $10, $08, $04, $02
	db $01, $80, $40, $20, $10, $08, $04, $02, $01, $ff, $f8, $e0, $c0, $80, $03, $03
	db $01, $80, $00, $00, $38, $03, $fc, $85, $e0, $01, $00, $00, $1c, $03, $3f, $ac
	db $07, $ff, $1f, $07, $03, $11, $d0, $e0, $a4, $80, $c0, $f0, $fc, $f0, $e0, $e0
	db $f0, $01, $03, $0e, $00, $00, $0c, $1c, $3c, $80, $c0, $70, $00, $00, $30, $38
	db $3c, $25, $1b, $0f, $3f, $0f, $07, $07, $0f, $38, $7c, $fe, $09, $93, $89, $ff
	db $7f, $3e, $1c, $3c, $7e, $7e, $46, $66, $06, $26, $81, $66, $03, $7f, $84, $3f
	db $38, $7c, $fe, $03, $93, $86, $f3, $77, $26, $4e, $5c, $9e, $03, $ff, $8a, $7f
	db $38, $7c, $fe, $93, $93, $f3, $47, $46, $f2, $03, $93, $87, $ff, $7f, $3e, $1c
	db $fc, $fe, $fe, $06, $96, $90, $83, $83, $f7, $7f, $1e, $1e, $0e, $fe, $ff, $ff
	db $9f, $9f, $98, $84, $82, $f3, $03, $93, $8c, $ff, $7f, $3e, $1c, $38, $7c, $fe
	db $93, $93, $9f, $87, $82, $04, $93, $90, $ff, $7f, $3e, $1c, $fe, $ff, $ff, $f3
	db $73, $23, $27, $26, $46, $4e, $4c, $4c, $03, $7c, $84, $3c, $38, $7c, $fe, $03
	db $93, $83, $47, $46, $92, $03, $93, $87, $ff, $7f, $3e, $1c, $38, $7c, $fe, $03
	db $93, $83, $83, $43, $f3, $03, $93, $84, $ff, $7f, $3e, $1c, $12, $00, $84, $7c
	db $fe, $7c, $7e, $03, $ff, $87, $3e, $00, $00, $ff, $ff, $00, $00, $0a, $03, $84
	db $07, $0f, $ff, $fe, $04, $00, $8c, $38, $7c, $38, $fe, $7c, $38, $7e, $ef, $00
	db $00, $ff, $ff, $11, $00, $03, $ff, $1c, $00, $82, $ff, $8c, $0d, $00, $88, $03
	db $fe, $03, $8c, $ff, $fb, $fc, $ff, $03, $fc, $8d, $ff, $80, $9f, $bf, $df, $bf
	db $ff, $ff, $00, $ff, $ff, $02, $fe, $03, $03, $82, $ff, $00, $06, $ff, $84, $fb
	db $fc, $ff, $80, $07, $9f, $83, $bf, $df, $bf, $03, $ff, $83, $03, $ff, $00, $0c
	db $ff, $ae, $8c, $fc, $ff, $fc, $fc, $ff, $fc, $fc, $28, $3f, $fb, $3e, $0e, $ff
	db $0e, $0e, $14, $fc, $df, $7c, $70, $ff, $70, $70, $31, $3f, $ff, $3f, $3f, $ff
	db $3f, $3f, $ff, $fc, $fc, $ff, $fc, $fc, $8f, $ff, $ff, $07, $03, $ff, $00, $00
	db $03, $ff, $85, $e0, $c0, $ff, $00, $00, $03, $ff, $95, $3f, $3f, $ff, $3f, $3f
	db $f1, $ff, $ff, $88, $8c, $fb, $ff, $fc, $fc, $ff, $fc, $fc, $ff, $fc, $fc, $8f
	db $03, $ff, $8c, $00, $00, $ff, $ff, $00, $03, $fe, $02, $03, $ff, $03, $03, $04
	db $ff, $8c, $00, $00, $ff, $ff, $00, $c0, $7f, $40, $c0, $ff, $c0, $c0, $04, $ff
	db $8f, $11, $31, $df, $ff, $3f, $3f, $ff, $3f, $3f, $ff, $3f, $3f, $f1, $ff, $ff
	db $0b, $00, $85, $ff, $ff, $80, $9f, $9f, $08, $00, $88, $03, $02, $03, $ff, $ff
	db $00, $ff, $ff, $08, $00, $88, $c0, $40, $c0, $ff, $ff, $00, $ff, $ff, $0b, $00
	db $85, $ff, $ff, $01, $f9, $f9, $07, $9f, $87, $bf, $9f, $df, $9f, $bf, $df, $bf
	db $22, $ff, $07, $f9, $8a, $fd, $f9, $fb, $f9, $fd, $fb, $fd, $ff, $ff, $01, $03
	db $02, $87, $06, $0e, $7c, $80, $7c, $0e, $06, $03, $02, $81, $01, $05, $00, $87
	db $0c, $0b, $05, $06, $05, $0b, $0c, $0a, $00, $88, $1c, $17, $08, $04, $02, $06
	db $05, $02, $03, $00, $08, $ff, $08, $00, $81, $ff, $07, $80, $81, $ff, $07, $00
	db $11, $ff, $03, $80, $05, $ff, $03, $00, $05, $ff, $07, $80, $81, $ff, $03, $00
	db $04, $80, $83, $ff, $ff, $c0, $03, $cf, $8c, $ce, $ce, $ff, $ff, $01, $f1, $f9
	db $f9, $39, $39, $ff, $ff, $06, $c0, $84, $ff, $ff, $01, $31, $04, $39, $98, $ff
	db $ff, $c0, $cf, $cf, $c7, $c0, $cf, $ff, $ff, $01, $f1, $f9, $f9, $39, $f9, $ff
	db $ff, $c0, $cf, $cf, $c7, $c0, $c3, $05, $39, $83, $19, $01, $ff, $08, $80, $08
	db $00, $14, $ff, $04, $80, $04, $ff, $04, $00, $04, $80, $04, $00, $08, $80, $03
	db $ce, $85, $cf, $cf, $c7, $c0, $ff, $03, $39, $03, $f9, $82, $01, $ff, $07, $c0
	db $81, $ff, $05, $39, $9e, $19, $01, $ff, $cf, $cf, $ce, $cf, $cf, $c7, $c0, $ff
	db $f9, $f9, $01, $f1, $f9, $f9, $01, $ff, $c3, $c1, $c0, $cf, $cf, $c7, $c0, $ff
	db $f9, $f9, $39, $03, $f9, $81, $01, $03, $ff, $82, $c0, $cc, $03, $ce, $85, $cf
	db $ff, $ff, $01, $31, $03, $39, $84, $f9, $ff, $ff, $c0, $03, $cf, $94, $ce, $cf
	db $ff, $ff, $01, $f1, $f9, $f9, $01, $f1, $7d, $c7, $92, $9e, $9e, $92, $c7, $7d
	db $ff, $18, $04, $4c, $99, $18, $ff, $f7, $4d, $c5, $c5, $c9, $c9, $4d, $fb, $00
	db $00, $0f, $13, $2c, $3b, $37, $36, $00, $00, $ff, $ff, $00, $ff, $ff, $03, $00
	db $85, $f0, $f8, $fc, $f6, $f6, $0b, $36, $a8, $3b, $2f, $10, $0f, $07, $00, $36
	db $36, $d6, $f6, $0c, $f8, $f0, $00, $8b, $d3, $d3, $a5, $8b, $d3, $cd, $85, $b8
	db $f0, $ff, $be, $bd, $2d, $95, $39, $2d, $12, $73, $f7, $ff, $bc, $f4, $e9, $cf
	db $c7, $05, $c0, $83, $ff, $f9, $f9, $03, $39, $8a, $19, $01, $ff, $cf, $c7, $c0
	db $cf, $cf, $c7, $c0, $03, $ff, $87, $c0, $cf, $cf, $c7, $c0, $c0, $00, $03, $01
	db $9e, $19, $2d, $46, $83, $00, $e0, $38, $0c, $e6, $f2, $1b, $09, $e7, $f7, $32
	db $19, $1c, $0f, $07, $01, $09, $0b, $13, $e6, $0e, $3c, $f8, $c0, $38, $7c, $04
	db $ce, $94, $7c, $38, $00, $42, $24, $18, $18, $24, $42, $00, $fe, $82, $9c, $82
	db $72, $72, $82, $fc, $7c, $82, $04, $92, $f6, $82, $7c, $ff, $66, $08, $26, $51
	db $c8, $37, $ff, $ff, $83, $81, $99, $91, $81, $c1, $ff, $a1, $c3, $41, $87, $cf
	db $5e, $5f, $ff, $b0, $00, $fc, $fe, $87, $e3, $81, $50, $87, $0b, $78, $f3, $f7
	db $df, $fa, $fc, $ed, $c7, $d7, $6d, $d8, $a8, $30, $51, $5f, $ef, $97, $8f, $1d
	db $38, $66, $8c, $a2, $81, $97, $cf, $ed, $61, $70, $76, $c7, $84, $6e, $ff, $bc
	db $37, $4f, $bf, $9a, $b1, $9d, $2b, $3b, $e7, $ff, $7c, $ff, $be, $ff, $f3, $c0
	db $10, $60, $c0, $b7, $ef, $c1, $e1, $f1, $78, $3b, $1d, $ff, $db, $c6, $c5, $c3
	db $c0, $c0, $41, $a0, $60, $c0, $80, $00, $00, $90, $90, $3d, $02, $04, $01, $04
	db $00, $f8, $63, $e7, $c7, $0e, $0c, $1f, $1f, $3e, $ce, $87, $07, $07, $c3, $c3
	db $a3, $c0, $e7, $f3, $e3, $bd, $e9, $f0, $e0, $c8, $7f, $f7, $e3, $d1, $e9, $d8
	db $b0, $64, $7e, $ff, $e3, $f3, $e1, $d9, $b0, $6c, $b0, $03, $0f, $1e, $3c, $3d
	db $fb, $fe, $03, $f9, $b8, $0c, $8e, $82, $10, $a1, $1d, $1f, $0f, $00, $03, $79
	db $fc, $fc, $e0, $c0, $c0, $38, $1d, $81, $1f, $7f, $1c, $3f, $3c, $7f, $7e, $6c
	db $18, $3e, $bf, $1b, $3e, $3b, $7e, $6d, $5b, $1e, $80, $50, $b0, $60, $c8, $90
	db $61, $c3, $1c, $0c, $0c, $0e, $06, $06, $c6, $c6, $43, $c3, $c7, $47, $c7, $87
	db $47, $c3, $30, $b8, $78, $d8, $7f, $df, $bf, $fe, $07, $00, $94, $01, $3d, $3b
	db $3c, $1f, $0f, $03, $03, $c7, $c1, $43, $cf, $9f, $ff, $ff, $e6, $e2, $30, $60
	db $cc, $03, $ff, $85, $3c, $7c, $d8, $38, $f8, $03, $ff, $d3, $1c, $0f, $58, $31
	db $7f, $ff, $fe, $fc, $78, $3e, $c7, $0f, $8f, $9f, $cf, $df, $e7, $e0, $e2, $e2
	db $e3, $e1, $e3, $e1, $e1, $00, $c3, $47, $cf, $d8, $e0, $c6, $c7, $c3, $ff, $c7
	db $f0, $f8, $3c, $2e, $83, $e1, $83, $e7, $7f, $0f, $1f, $3c, $3b, $ff, $c3, $c0
	db $80, $80, $c0, $c0, $60, $e0, $a0, $00, $00, $01, $07, $0f, $1f, $1e, $18, $00
	db $00, $ff, $ff, $f3, $2e, $7f, $04, $00, $00, $c0, $f8, $fe, $ff, $1f, $10, $03
	db $00, $b8, $0f, $3f, $fe, $f4, $07, $1f, $3e, $7c, $f9, $f2, $f5, $03, $fc, $be
	db $f7, $e8, $78, $fc, $ce, $80, $cf, $cf, $df, $fb, $bf, $fd, $b3, $47, $87, $81
	db $a0, $78, $f0, $a0, $40, $e0, $c1, $e0, $f0, $f0, $78, $38, $30, $00, $ef, $fb
	db $7f, $1f, $03, $00, $07, $0f, $e0, $e0, $c0, $c0, $03, $00, $9d, $01, $00, $00
	db $01, $01, $03, $01, $00, $f0, $c1, $40, $c0, $80, $c0, $40, $c1, $43, $f8, $1c
	db $03, $01, $02, $fc, $ff, $ff, $fb, $fe, $9f, $0e, $03, $07, $d9, $c3, $20, $f8
	db $7c, $df, $ff, $73, $bd, $fe, $1c, $1e, $1f, $8f, $ff, $ff, $2f, $bd, $7c, $a9
	db $03, $07, $cf, $1d, $ff, $c6, $78, $f8, $d4, $54, $ed, $7a, $5b, $73, $2f, $bf
	db $6d, $d5, $65, $cf, $af, $1d, $03, $2f, $17, $37, $57, $f3, $4b, $c3, $00, $01
	db $80, $80, $87, $81, $83, $81, $cf, $cb, $c3, $c1, $41, $00, $80, $c0, $fb, $bf
	db $9f, $d6, $ec, $fb, $ff, $77, $ff, $ff, $83, $69, $d0, $e3, $f7, $f7, $0e, $fc
	db $f1, $e1, $03, $e3, $e7, $f7, $02, $00, $00, $00, $00, $00, $00, $00, $c0, $00
	db $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $2a, $55, $00
	db $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $aa, $55, $ca
	db $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $ca, $cd, $af
	db $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $af, $5f, $10
	db $fc, $10, $3f, $81, $00, $0f, $7f, $81, $00, $0f, $ff, $10, $cf, $10, $ff, $84
	db $00, $1f, $2f, $5f, $0c, $7f, $81, $07, $03, $ff, $8d, $e7, $db, $bd, $66, $66
	db $7e, $66, $18, $ef, $97, $7b, $a7, $e0, $03, $ff, $8d, $d5, $15, $fe, $11, $93
	db $55, $52, $92, $c7, $bb, $c3, $9d, $00, $03, $ff, $88, $81, $7e, $42, $82, $3d
	db $c5, $cb, $b7, $03, $ff, $82, $df, $00, $03, $ff, $8d, $1f, $ed, $1a, $fa, $fa
	db $f5, $0b, $f7, $c3, $bd, $cb, $bd, $00, $03, $ff, $8d, $f5, $c0, $3e, $c9, $17
	db $d7, $e9, $f6, $ff, $b3, $55, $5a, $00, $0b, $ff, $85, $f7, $ab, $5d, $6a, $00
	db $0b, $ff, $85, $fb, $f5, $eb, $d7, $00, $0b, $ff, $88, $83, $7d, $8b, $9d, $00
	db $f8, $f4, $fa, $0c, $fe, $0c, $7f, $90, $5f, $2f, $1f, $00, $79, $aa, $a2, $dd
	db $ff, $c3, $bd, $c2, $f5, $bb, $41, $be, $03, $ff, $8d, $00, $62, $9a, $c5, $bb
	db $bf, $5d, $52, $ad, $b3, $4f, $41, $be, $03, $ff, $81, $00, $03, $ff, $89, $bd
	db $f5, $da, $25, $f2, $2a, $49, $8b, $37, $03, $ff, $8d, $00, $cb, $bb, $4d, $b3
	db $f5, $c0, $3e, $c9, $17, $d7, $e9, $f6, $03, $ff, $8d, $00, $5a, $42, $55, $af
	db $ef, $97, $7d, $89, $be, $85, $43, $bd, $03, $ff, $8d, $00, $d2, $b2, $aa, $d5
	db $c3, $bd, $cb, $bd, $cb, $bb, $4d, $b3, $03, $ff, $8d, $00, $af, $d7, $eb, $f5
	db $f7, $89, $7e, $89, $bb, $ab, $9b, $77, $03, $ff, $85, $00, $62, $9a, $2a, $dd
	db $0b, $ff, $81, $00, $0c, $fe, $88, $fa, $f4, $f8, $00, $00, $1f, $2f, $5f, $0c
	db $7f, $81, $00, $03, $ff, $8d, $03, $fd, $c3, $fd, $06, $fe, $86, $7d, $ea, $d5
	db $aa, $55, $00, $03, $ff, $83, $c7, $bb, $4d, $03, $d7, $87, $65, $bb, $11, $fe
	db $02, $e5, $00, $03, $ff, $83, $81, $7e, $82, $03, $fa, $87, $82, $7e, $d7, $97
	db $57, $55, $00, $03, $ff, $8d, $fa, $f5, $cb, $37, $cb, $2b, $eb, $eb, $f5, $da
	db $25, $f2, $00, $03, $ff, $8d, $1f, $ed, $1a, $fa, $fa, $f5, $0b, $f7, $e7, $db
	db $bb, $db, $00, $03, $ff, $8d, $f5, $c2, $bd, $c2, $f5, $bb, $41, $be, $c3, $bd
	db $cb, $bd, $07, $03, $ff, $8d, $bf, $5d, $52, $ad, $b3, $4f, $41, $be, $ff, $b3
	db $55, $5a, $e0, $04, $ff, $87, $a1, $5e, $41, $5f, $47, $49, $b6, $04, $ff, $84
	db $00, $f8, $f4, $fa, $0c, $fe, $0c, $7f, $90, $5f, $2f, $1f, $00, $55, $ba, $ba
	db $7a, $f7, $ab, $5d, $6a, $d2, $b2, $aa, $d5, $03, $ff, $8d, $00, $db, $35, $d2
	db $15, $fb, $f5, $eb, $d7, $af, $d7, $eb, $f5, $03, $ff, $8d, $00, $52, $52, $55
	db $9b, $c7, $bb, $c3, $ad, $52, $6a, $82, $dd, $03, $ff, $09, $00, $88, $ff, $eb
	db $cc, $cf, $c8, $bf, $bf, $b0, $08, $00, $8b, $c3, $c3, $00, $c3, $00, $ff, $ff
	db $00, $b0, $a0, $e0, $04, $20, $85, $10, $08, $04, $02, $01, $04, $00, $82, $ff
	db $db, $04, $bd, $86, $a5, $ff, $ff, $00, $00, $ff, $04, $00, $10, $ff, $81, $3f
	db $0e, $3d, $82, $3f, $38, $0e, $28, $ad, $38, $00, $01, $07, $0f, $1a, $17, $1f
	db $17, $1e, $3f, $7f, $ff, $f4, $6b, $30, $00, $00, $fc, $aa, $f5, $ff, $ff, $fd
	db $de, $ef, $ff, $fd, $fa, $7c, $08, $f0, $00, $2a, $49, $8b, $37, $f3, $ad, $55
	db $d5, $65, $55, $d5, $5a, $03, $ff, $81, $00, $03, $db, $89, $bd, $c3, $bd, $cb
	db $bd, $cb, $bb, $4d, $b3, $03, $ff, $8d, $00, $cb, $bb, $4d, $b3, $f7, $89, $7e
	db $89, $bb, $ab, $9b, $77, $03, $ff, $85, $00, $5a, $42, $55, $af, $0b, $ff, $81
	db $00, $0f, $ff, $81, $00, $0c, $fe, $95, $fa, $f4, $f8, $00, $00, $1f, $2f, $5f
	db $7f, $7b, $74, $7d, $76, $75, $7d, $74, $78, $77, $76, $77, $00, $04, $ff, $8c
	db $3c, $d2, $2f, $a4, $a4, $2a, $d3, $1d, $c1, $6f, $c1, $00, $03, $ff, $8d, $7f
	db $bf, $5f, $2e, $a9, $96, $b8, $7d, $58, $57, $e4, $18, $00, $03, $ff, $8d, $fe
	db $f9, $f7, $7a, $b4, $54, $59, $ba, $11, $ee, $21, $2f, $00, $03, $ff, $8d, $fb
	db $75, $d5, $1a, $eb, $14, $14, $eb, $fe, $d9, $a7, $aa, $00, $04, $ff, $8c, $dc
	db $2b, $dc, $3f, $fb, $14, $eb, $fd, $3a, $db, $16, $00, $03, $ff, $8d, $fe, $39
	db $d6, $29, $53, $bc, $12, $ed, $db, $25, $a5, $15, $00, $03, $ff, $b8, $3f, $dc
	db $b3, $3c, $d1, $2d, $2e, $df, $ff, $fc, $f3, $fc, $00, $f8, $f4, $fa, $5e, $0e
	db $ee, $9e, $7e, $7e, $9e, $6e, $9e, $6e, $de, $be, $76, $76, $77, $70, $7f, $7c
	db $7b, $7c, $7f, $7b, $74, $7b, $5f, $2f, $1f, $00, $69, $65, $c5, $19, $fe, $39
	db $d7, $2a, $54, $b4, $19, $ea, $03, $ff, $8d, $00, $33, $5c, $2c, $2b, $fc, $7b
	db $dc, $17, $e8, $1d, $1a, $e5, $03, $ff, $8d, $00, $df, $5f, $b0, $7f, $7f, $bc
	db $73, $dc, $b1, $7d, $9e, $6f, $03, $ff, $8d, $00, $a7, $59, $ba, $7b, $9f, $6f
	db $de, $bd, $7a, $7d, $9e, $6f, $03, $ff, $8d, $7e, $6b, $96, $1a, $e6, $be, $59
	db $b7, $7a, $f4, $74, $b5, $5a, $03, $ff, $8d, $00, $d5, $25, $a4, $5b, $5e, $29
	db $d7, $18, $ef, $1b, $14, $eb, $03, $ff, $8d, $00, $f1, $bd, $5e, $bf, $ff, $3b
	db $d5, $b5, $55, $54, $35, $da, $03, $ff, $99, $00, $7e, $7e, $9e, $6e, $fe, $3e
	db $5e, $ae, $ae, $2e, $5e, $fe, $fa, $f4, $f8, $00, $00, $01, $02, $05, $0b, $17
	db $2f, $3f, $08, $07, $20, $00, $61, $ff, $0f, $80, $81, $ff, $0f, $00, $10, $f8
	db $10, $0f, $84, $1f, $3f, $70, $e0, $0c, $c0, $87, $fc, $fc, $00, $00, $18, $3c
	db $7e, $04, $ff, $9a, $e7, $10, $78, $fc, $78, $3f, $3f, $00, $00, $3f, $ff, $ff
	db $fe, $7c, $fe, $ff, $ff, $38, $7c, $3c, $7e, $ff, $ff, $00, $00, $7e, $03, $ff
	db $aa, $fe, $3e, $3c, $78, $00, $18, $38, $38, $ff, $ff, $00, $00, $e0, $f2, $e7
	db $07, $07, $0e, $fc, $f8, $3c, $7e, $3c, $7e, $ff, $ff, $00, $00, $0f, $3f, $ff
	db $fe, $f8, $38, $1e, $0f, $00, $4c, $ee, $e7, $ff, $ff, $0a, $00, $83, $08, $5c
	db $fe, $03, $ff, $0a, $00, $86, $04, $0e, $1c, $38, $ff, $ff, $0a, $00, $88, $7c
	db $fe, $7c, $7e, $f8, $fc, $0e, $07, $0c, $03, $0c, $c0, $92, $e0, $70, $3f, $1f
	db $fe, $77, $7f, $3e, $00, $3c, $7e, $3f, $0e, $44, $fe, $7f, $00, $00, $03, $ff
	db $8f, $67, $3e, $7c, $40, $e2, $ef, $7e, $7c, $f0, $fe, $7f, $00, $00, $ff, $ff
	db $03, $18, $ab, $7e, $0f, $25, $fe, $ff, $ff, $fe, $fc, $f8, $00, $00, $ff, $ff
	db $3c, $7c, $fe, $7c, $0f, $3f, $ff, $fe, $f8, $38, $1e, $0f, $00, $00, $ff, $ff
	db $e7, $ff, $fa, $70, $10, $78, $fe, $7e, $7f, $7e, $fc, $7e, $00, $00, $04, $ff
	db $96, $f7, $6e, $3c, $7e, $3c, $7e, $3c, $7c, $fe, $7c, $00, $00, $ff, $ff, $70
	db $38, $1c, $0e, $08, $7e, $ff, $7e, $03, $7c, $83, $f8, $00, $00, $05, $ff, $81
	db $3e, $0a, $00, $82, $ff, $ff, $0c, $03, $88, $07, $0e, $fc, $f8, $1f, $3f, $70
	db $e0, $0c, $c0, $97, $ff, $ff, $00, $00, $fc, $fe, $fc, $fe, $ff, $07, $ff, $fe
	db $17, $3f, $5f, $ee, $ff, $ff, $00, $00, $38, $7c, $fe, $03, $ee, $8d, $fe, $7c
	db $fe, $ff, $ff, $1e, $ff, $ff, $00, $00, $7e, $ff, $7f, $03, $07, $95, $7f, $ff
	db $38, $78, $f8, $fa, $ff, $ff, $00, $00, $07, $0e, $3c, $f8, $fc, $dc, $1c, $1c
	db $0f, $25, $fe, $03, $ff, $b0, $00, $00, $e0, $f2, $e7, $07, $07, $0e, $fc, $f8
	db $18, $3c, $7c, $3c, $ff, $ff, $00, $00, $0f, $3d, $7e, $3f, $0e, $44, $fe, $7f
	db $3c, $7e, $3c, $7e, $fc, $fc, $00, $00, $40, $e2, $ef, $7e, $7c, $f0, $fe, $7f
	db $00, $4c, $ee, $e7, $3f, $3f, $03, $00, $87, $5e, $ff, $fe, $e0, $f8, $fe, $6f
	db $04, $00, $84, $f8, $fc, $0e, $07, $0c, $03, $0c, $c0, $8b, $e0, $70, $3f, $1f
	db $ee, $c7, $c7, $87, $08, $5c, $fe, $03, $ff, $94, $f7, $6e, $00, $00, $ff, $ff
	db $3c, $fe, $ff, $fa, $04, $0e, $1c, $38, $70, $38, $1c, $0e, $00, $00, $04, $ff
	db $8e, $fe, $fc, $38, $7c, $3c, $7e, $ff, $f7, $7f, $3e, $00, $00, $ff, $ff, $08
	db $00, $88, $ff, $9c, $bf, $bf, $b8, $ff, $e0, $ef, $08, $00, $8b, $c3, $00, $c3
	db $c3, $00, $ff, $00, $ff, $ef, $ff, $ff, $04, $3f, $85, $1f, $0f, $07, $03, $01
	db $04, $00, $86, $ff, $a5, $c3, $db, $db, $c3, $06, $ff, $04, $00, $81, $ff, $0e
	db $81, $82, $ff, $3f, $0e, $27, $81, $3f, $10, $38, $a6, $00, $01, $06, $08, $17
	db $1c, $18, $1b, $13, $20, $40, $86, $8f, $5b, $30, $00, $00, $fc, $76, $1b, $01
	db $01, $e7, $e2, $59, $79, $13, $36, $a4, $f8, $f0, $00, $ff, $fe, $fc, $f8, $0c
	db $5e, $03, $fe, $87, $ee, $ee, $e7, $00, $00, $ff, $ff, $03, $3c, $95, $7e, $3c
	db $7e, $3c, $7e, $3c, $7c, $fe, $7c, $00, $00, $ff, $ff, $3c, $7c, $fe, $7c, $08
	db $7e, $ff, $7e, $03, $7c, $89, $f8, $00, $00, $ff, $ff, $e7, $ff, $fa, $70, $0a
	db $00, $82, $ff, $ff, $0e, $00, $82, $ff, $ff, $0c, $03, $8a, $07, $0e, $fc, $f8
	db $1f, $3f, $70, $e0, $c0, $c4, $03, $cf, $84, $ce, $ce, $cf, $c7, $03, $cf, $82
	db $ff, $ff, $03, $00, $88, $c3, $ef, $ff, $7f, $7f, $fd, $ef, $e3, $05, $ff, $b0
	db $00, $00, $80, $c0, $e0, $f1, $f7, $ef, $c7, $83, $f7, $ff, $ff, $ef, $ff, $ff
	db $00, $00, $01, $07, $0f, $87, $cf, $ef, $ef, $cd, $ee, $ff, $fe, $f0, $ff, $ff
	db $00, $00, $04, $8e, $ee, $e7, $f7, $ef, $ef, $f7, $01, $27, $7f, $77, $ff, $ff
	db $03, $00, $af, $23, $f7, $e3, $c0, $04, $ef, $f7, $02, $c7, $e7, $ef, $ff, $ff
	db $00, $00, $01, $c7, $ef, $f7, $ef, $4f, $ed, $f3, $24, $fe, $fe, $ee, $ff, $ff
	db $00, $00, $c0, $e3, $cf, $cf, $ef, $f3, $f1, $e0, $00, $03, $0f, $0f, $f8, $fc
	db $0e, $07, $03, $f3, $89, $e3, $83, $83, $e3, $f3, $63, $f3, $e3, $c3, $04, $cf
	db $ff, $c0, $c3, $c7, $c3, $c0, $c4, $cf, $c7, $e0, $70, $3f, $1f, $f7, $ff, $ff
	db $ef, $01, $c7, $ef, $f7, $ef, $4f, $ef, $fd, $00, $00, $ff, $ff, $cf, $e3, $f3
	db $f7, $03, $87, $e3, $ef, $f7, $e3, $e7, $fe, $00, $00, $ff, $ff, $e0, $e0, $cf
	db $8f, $80, $c3, $8f, $ef, $cf, $83, $e1, $f0, $00, $00, $ff, $ff, $7f, $e7, $c7
	db $87, $60, $f0, $e1, $c3, $87, $83, $e1, $f0, $00, $00, $c3, $c3, $f7, $ef, $ef
	db $ff, $41, $e7, $cf, $87, $0f, $8f, $cf, $ed, $00, $00, $ff, $ff, $ee, $fe, $7f
	db $e7, $f1, $d7, $ef, $e7, $f0, $e4, $ef, $f7, $00, $00, $ff, $ff, $0f, $43, $e1
	db $c0, $00, $c4, $ee, $ce, $ee, $ef, $cf, $e7, $00, $00, $ff, $ff, $83, $83, $e3
	db $96, $f3, $03, $c3, $e3, $73, $73, $f3, $a3, $03, $07, $0e, $fc, $f8, $01, $03
	db $07, $0e, $1c, $38, $70, $7c, $7c, $07, $0c, $22, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
