INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $056", ROMX[$4000], BANK[$56]

BankNumber_56::
	db $56

FarTable_56::
	dw Call_56_4901
	dw Call_56_4908
	dw Call_56_490F
	dw Call_56_4916
	dw Data_56_4A46
	dw Call_56_4485
	dw Call_56_44C7
	dw Call_56_403F
	dw Call_56_4064
	dw Data_56_6867
	dw Data_56_6882
	dw Data_56_68A3
	dw Data_56_68C6
	dw Data_56_6A71
	dw Data_56_6BC7
	dw Data_56_6CA8
	dw Data_56_6D0F
	dw Data_56_6D7D
	dw Data_56_6DDE
	dw Data_56_6E30
	dw Data_56_6E96
	dw Data_56_6ED6
	dw Data_56_6F25
	dw Data_56_6F8A
	dw Data_56_6FDA
	dw Data_56_700C
	dw Data_56_705E
	dw Data_56_70C1
	dw Data_56_7137
	dw Data_56_71B0
	dw Data_56_7218

Call_56_403F::
	xor a
	ld hl, $9800
	ld de, $4085

jr_056_4046:
	ld a, [de]
	ld [hli], a
	inc de
	ld a, h
	cp $9b
	jr nz, jr_056_4046

	ld a, l
	cp $ff
	jr nz, jr_056_4046

	ld a, [de]
	ld [hl], a
	ld a, $43
	ld [wLCDC], a
	ld a, $63
	ld [wLCDC], a
	ld a, $01
	jp EnableLCDAndInterrupts


Call_56_4064::
	ld a, [wJoyHeld]
	and $01
	cp $01
	jr nz, jr_056_4084

	ld hl, wDebugSavedMode
	ld a, [hli]
	ld [wGameMode], a
	ld a, [hli]
	ld [wGameModeStep], a
	ld a, [hli]
	ld [$c88c], a
	ld a, [hl]
	ld [$c88d], a
	ld hl, wGameModeChange
	inc [hl]

jr_056_4084:
	ret


	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d, $5e, $5f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d, $8e, $8f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $db, $dc, $dd, $de, $df
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9, $ea, $eb, $ec, $ed, $ee, $ef
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $fa, $fb, $fc, $fd, $fe, $ff
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
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

Call_56_4485::
	ld hl, wTextBoxWidth
	ld a, [hli]
	or [hl]
	ret z

	ld a, [wTextTiles]
	ld l, a
	ld a, [$c828]
	ld h, a
	ld a, [wTextBoxHeight]
	ld c, a

jr_056_4497:
	ld a, [wTextBoxWidth]
	ld b, a

jr_056_449b:
	push bc
	ld b, $10
	ld de, $44b7

jr_056_44a1:
	di

jr_056_44a2:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_056_44a2

	ld a, [de]
	ld [hli], a
	ei
	inc de
	dec b
	jr nz, jr_056_44a1

	pop bc
	dec b
	jr nz, jr_056_449b

	dec c
	jr nz, jr_056_4497

	ret


	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00

Call_56_44C7::
	ld a, d
	ld [wTextControlCode], a
	sub $e0
	rst $00

JumpTable_56_44CE::
	dw Jump_56_450E
	dw Jump_56_450E
	dw Jump_56_450E
	dw Jump_56_450E
	dw Jump_56_450E
	dw Jump_56_450E
	dw Jump_56_450E
	dw Jump_56_4511
	dw Jump_56_451F
	dw Jump_56_4554
	dw Jump_56_455E
	dw Jump_56_4569
	dw Jump_56_4574
	dw Jump_56_45A7
	dw Jump_56_45AD
	dw Jump_56_4640
	dw Jump_56_46FE
	dw Jump_56_472B
	dw Jump_56_474F
	dw Jump_56_4758
	dw Call_56_4771
	dw Jump_56_477C
	dw Jump_56_4782
	dw Jump_56_47B4
	dw Jump_56_47BF
	dw Jump_56_47CE
	dw Jump_56_481B
	dw Jump_56_4821
	dw Jump_56_4835
	dw Jump_56_4849
	dw Jump_56_484F
	dw Call_56_4855

Jump_56_450E::
	jp Call_56_4855


Jump_56_4511::
	call Call_56_4855
	ld a, $01
	ld [wTextChoice], a
	ld a, $ff
	ld [wTextControlCode], a
	ret


Jump_56_451F::
	call NextTextByte
	ld d, $00
	call ReadTextBankByte
	ld e, a
	call NextTextByte
	call ReadTextBankByte
	ld c, a
	ld a, [wTextBoxHeight]
	call Multiply
	add hl, de
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, [wTextTiles]
	ld e, a
	ld a, [$c828]
	ld d, a
	add hl, de
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [$c82c], a
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [$c830], a
	ret


Jump_56_4554::
	call NextTextByte
	call ReadTextBankByte
	call QueueSound
	ret


Jump_56_455E::
	ld hl, wTextFlags
	set 0, [hl]
	ld a, $5b
	ld [wTextBeep], a
	ret


Jump_56_4569::
	ld hl, wTextFlags
	set 0, [hl]
	ld a, $5a
	ld [wTextBeep], a
	ret


Jump_56_4574::
	ld hl, wTextFlags
	res 7, [hl]
	ld a, [$c8ee]
	cp $07
	jr z, jr_056_4593

	ld hl, $45a0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wTextPauseTimer], a
	ld hl, wTextState
	set 7, [hl]
	ret


jr_056_4593:
	ld hl, wTextFlags
	res 7, [hl]
	ld hl, wTextState
	set 2, [hl]
	set 5, [hl]
	ret


	db $06, $0c, $14, $1a, $20, $28, $30

Jump_56_45A7::
	ld hl, wTextFlags
	set 7, [hl]
	ret


Jump_56_45AD::
	ld a, [wTextTiles]
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
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	ld a, [wTextBoxMap]
	ld l, a
	ld a, [$c83f]
	ld h, a
	push bc

jr_056_45d6:
	ld a, e
	call WriteVRAM
	call MapNextTile
	inc e
	dec b
	jr nz, jr_056_45d6

	ld hl, $0020
	call TextBoxMapAddress
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	call ClearMapTiles
	ld a, [wTextBoxHeight]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld c, l
	ld b, h
	push de
	ld a, [wTextTiles]
	ld e, a
	ld a, [$c828]
	ld d, a
	add hl, de
	pop de

jr_056_4609:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec bc
	dec bc
	ld a, b
	or c
	jr nz, jr_056_4609

	pop bc
	ld hl, $0040
	call TextBoxMapAddress

jr_056_461f:
	ld a, e
	call WriteVRAM
	call MapNextTile
	inc e
	dec b
	jr nz, jr_056_461f

	ld a, [wTextLineStart]
	ld l, a
	ld a, [$c830]
	ld h, a
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [$c82c], a
	ld hl, wTextState
	res 1, [hl]
	ret


Jump_56_4640::
	ld a, [wTextBoxHeight]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, [wTextTiles]
	ld e, a
	ld a, [$c828]
	ld d, a
	add hl, de
	ld a, [wTextLineStart]
	ld e, a
	ld a, [$c830]
	ld d, a
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld a, d
	or e
	jr z, jr_056_4679

	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [$c82c], a
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [$c830], a
	call NextTextByte
	ret


jr_056_4679:
	ld a, [wTextBoxMap]
	ld l, a
	ld a, [$c83f]
	ld h, a
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	call ClearMapTiles
	ld a, [wTextTiles]
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
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	ld hl, $0020
	call TextBoxMapAddress
	ld a, e
	add b
	ld e, a

jr_056_46b5:
	ld a, e
	call WriteVRAM
	call MapNextTile
	inc e
	dec b
	jr nz, jr_056_46b5

	ld hl, $0040
	call TextBoxMapAddress
	ld a, [wTextBoxWidth]
	ld c, a
	ld a, [wTextBoxHeight]
	ld b, a
	call ClearMapTiles
	ld a, [wTextBoxHeight]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, [wTextTiles]
	ld e, a
	ld a, [$c828]
	ld d, a
	ld c, l
	ld b, h
	add hl, de

jr_056_46e6:
	di
	call WaitVRAMAccess
	ld a, [hli]
	ei
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_056_46e6

	ld hl, wTextState
	set 7, [hl]
	ld a, $04
	ld [wTextPauseTimer], a
	ret


Jump_56_46FE::
	ld a, [wTextState]
	bit 4, a
	jp z, Jump_056_4722

	ld a, [wTextState]
	res 4, a
	ld [wTextState], a
	call EraseTextPromptArrow
	ld a, [wTextStart]
	ld l, a
	ld a, [$c832]
	ld h, a
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [$c82e], a
	ret


Jump_056_4722:
	xor a
	ld [wTextState], a
	xor a
	ld [wTextFlags], a
	ret


Jump_56_472B::
	ld a, [wTextBoxHeight]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, [wTextLineStart]
	ld e, a
	ld a, [$c830]
	ld d, a
	add hl, de
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [$c82c], a
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [$c830], a
	ret


Jump_56_474F::
	call EraseTextPromptArrow
	call Call_56_4771
	call Call_56_4485

Jump_56_4758::
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
	ret


Call_56_4771::
	ld hl, wTextFlags
	res 7, [hl]
	ld hl, wTextState
	res 1, [hl]
	ret


Jump_56_477C::
	ld hl, wTextState
	set 1, [hl]
	ret


Jump_56_4782::
	ld hl, wPlayerName
	ld de, wNameInput
	ld b, $08

jr_056_478a:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_056_478a

	ld a, $f0
	ld [de], a
	ld hl, wTextState
	set 4, [hl]
	ld a, [wTextPtr]
	ld l, a
	ld a, [$c82e]
	ld h, a
	ld a, l
	ld [wTextStart], a
	ld a, h
	ld [$c832], a
	ld hl, wNameInput
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [$c82e], a
	ret


Jump_56_47B4::
	ld hl, wTextState
	set 2, [hl]
	ld hl, wTextFlags
	res 7, [hl]
	ret


Jump_56_47BF::
	ld hl, wTextState
	set 3, [hl]
	call NextTextByte
	call ReadTextBankByte
	ld [wTextSpeed], a
	ret


Jump_56_47CE::
	ld hl, wTextState
	set 4, [hl]
	ld a, [wTextPtr]
	ld l, a
	ld a, [$c82e]
	ld h, a
	ld a, l
	ld [wTextStart], a
	ld a, h
	ld [$c832], a
	ld a, [wTextStart]
	add $01
	ld [wTextStart], a
	ld a, [$c832]
	adc $00
	ld [$c832], a
	ld a, [wGameMode]
	cp $0b
	jr nz, jr_056_4806

	ld hl, $0d8a
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [$c82e], a
	ret


jr_056_4806:
	call ReadTextBankByte
	ld de, wTextArg0
	add e
	ld l, a
	ld a, $00
	adc d
	ld h, a
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [$c82e], a
	ret


Jump_56_481B::
	ld hl, wTextState
	set 5, [hl]
	ret


Jump_56_4821::
	ld hl, wTextState
	set 6, [hl]
	call NextTextByte
	call ReadTextBankByte
	ld [wTextWaitTimer], a
	ld hl, wTextFlags
	res 7, [hl]
	ret


Jump_56_4835::
	ld hl, wTextState
	set 7, [hl]
	call NextTextByte
	call ReadTextBankByte
	ld [wTextPauseTimer], a
	ld hl, wTextFlags
	res 7, [hl]
	ret


Jump_56_4849::
	ld hl, wTextFlags
	set 0, [hl]
	ret


Jump_56_484F::
	ld hl, wTextFlags
	res 0, [hl]
	ret


Call_56_4855::
	ld hl, wTextFlags
	res 7, [hl]
	ld a, $5c
	call QueueSound
	ld hl, $0000
	call ScreenMapAddress
	ld de, wTilemapBuffer
	ld c, $12

jr_056_486a:
	ld b, $20
	push hl

jr_056_486d:
	di
	call WaitVRAMAccess
	ld a, [hl]
	ei
	ld [de], a
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
	jr nz, jr_056_486d

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
	jr nz, jr_056_486a

	call Call_56_48A1
	ld hl, wTextState
	set 2, [hl]
	xor a
	ld [wTextChoice], a
	ret


Call_56_48A1::
	ld de, $560a
	ld hl, $8e50
	call DecompressVRAM
	ld hl, $0100
	call ScreenMapAddress
	ld b, $0e
	call MapAdvanceTiles
	ld de, $48de

jr_056_48b8:
	push hl

jr_056_48b9:
	ld a, [de]
	inc de
	cp $d9
	jr z, jr_056_48dc

	cp $d8
	jr nz, jr_056_48d4

	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
	jr jr_056_48b8

jr_056_48d4:
	call WriteVRAM
	call MapNextTile
	jr jr_056_48b9

jr_056_48dc:
	pop hl
	ret


	db $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e5, $e6, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $fd, $d9

Call_56_4901::
	ld de, $664b
	call StartText
	ret


Call_56_4908::
	ld de, $664b
	call CopyTextString
	ret


Call_56_490F::
	call Call_56_4901
	call RunTextToEnd
	ret


Call_56_4916::
	ld hl, $9000
	ld de, $1207
	call SetUpTextBox
	ld hl, wNumberBackup
	ld bc, $0010
	ld a, $00
	call FillMemory
	ld hl, $9c00
	ld bc, $0400
	ld a, $1f
	call FillMemory
	ld hl, $9c00
	ld bc, $1204
	ld a, $80
	call Call_56_4A0A
	xor a
	ld [wLinkChoice], a
	xor a
	ldh [rVBK], a
	call Call_56_4996
	ld a, $00
	call QueueMusic
	ld a, $0a
	ld [$df08], a
	xor a
	ld [$df03], a
	ld a, $98
	ld [$df04], a
	ld a, $8e
	ld [$df05], a
	ld a, $64
	ldh [hWY], a
	ld a, $07
	ldh [hWX], a
	ld h, $98
	ld l, $8e
	ld a, [hli]
	ld [$df06], a
	ld a, [hl]
	ld [$df07], a
	ld a, $1f
	ld [$c83b], a
	ld a, $7f
	ld [$c83d], a
	xor a
	ld [$df0b], a
	ld [$df0c], a
	ld a, $43
	ld [wLCDC], a
	ld a, $63
	ld [wLCDC], a
	ld a, $01
	jp EnableLCDAndInterrupts


Call_56_4996::
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	ld hl, $9100
	ld a, $00
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld de, $1002
	call Call_56_49E2
	ld hl, $9300
	ld a, [wGameModeStep]
	inc a
	ld [wTextIndex], a
	ld de, $1004
	call Call_56_49E2
	call Call_56_4A23
	ld hl, $9823
	ld bc, $1002
	ld a, $10
	call Call_56_4A0A
	ld hl, $9883
	ld bc, $1004
	ld a, $30
	call Call_56_4A0A
	call Call_56_4A2F
	ret


Call_56_49E2::
	ld a, e
	ld [wTextBoxWidth], a
	ld a, d
	ld [wTextBoxHeight], a
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	call Call_56_490F
	ret


	db $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $7d, $ea, $27, $c8, $7c, $ea, $28, $c8
	db $cd, $01, $49, $c9

Call_56_4A0A::
	push hl
	ld d, b

jr_056_4a0c:
	call WriteVRAMInc
	inc a
	dec b
	jr nz, jr_056_4a0c

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
	jr nz, Call_56_4A0A

	ret


Call_56_4A23::
	ld hl, $9800
	ld bc, $0400
	ld a, $1f
	call FillMemory
	ret


Call_56_4A2F::
	ld b, $04
	ld hl, $988e
	ld c, $6f

jr_056_4a36:
	ld a, $70
	ld [hli], a
	ld [hld], a
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jr nz, jr_056_4a36

	ret


Data_56_4A46::
	db $cd, $50, $4a, $cd, $7a, $4d, $cd, $ba, $4d, $c9, $fa, $46, $c8, $cb, $77, $28
	db $4f, $fa, $04, $df, $67, $fa, $05, $df, $6f, $fa, $06, $df, $cd, $b9, $1a, $fa
	db $07, $df, $cd, $ad, $1a, $fa, $03, $df, $3d, $fe, $ff, $20, $02, $3e, $03, $ea
	db $03, $df, $4f, $fa, $02, $df, $81, $ea, $00, $df, $fa, $03, $df, $0e, $20, $cd
	db $be, $1d, $7d, $c6, $8e, $6f, $7c, $ce, $98, $67, $7c, $ea, $04, $df, $7d, $ea
	db $05, $df, $cd, $a6, $1a, $2a, $ea, $06, $df, $cd, $a6, $1a, $7e, $ea, $07, $df
	db $fa, $46, $c8, $cb, $7f, $28, $4e, $fa, $04, $df, $67, $fa, $05, $df, $6f, $fa
	db $06, $df, $cd, $b9, $1a, $fa, $07, $df, $cd, $ad, $1a, $fa, $03, $df, $3c, $fe
	db $04, $20, $01, $af, $ea, $03, $df, $4f, $fa, $02, $df, $81, $ea, $00, $df, $fa
	db $03, $df, $0e, $20, $cd, $be, $1d, $7d, $c6, $8e, $6f, $7c, $ce, $98, $67, $7c
	db $ea, $04, $df, $7d, $ea, $05, $df, $cd, $a6, $1a, $2a, $ea, $06, $df, $cd, $a6
	db $1a, $7e, $ea, $07, $df, $fa, $42, $c8, $cb, $67, $ca, $36, $4b, $fa, $0b, $df
	db $3c, $e6, $07, $ea, $0b, $df, $28, $01, $c9, $fa, $07, $df, $3c, $fe, $80, $20
	db $14, $3e, $70, $ea, $07, $df, $fa, $06, $df, $3c, $fe, $80, $20, $02, $3e, $70
	db $ea, $06, $df, $18, $03, $ea, $07, $df, $fa, $01, $df, $3c, $ea, $01, $df, $c9
	db $fa, $42, $c8, $cb, $6f, $ca, $71, $4b, $fa, $0c, $df, $3c, $e6, $07, $ea, $0c
	db $df, $28, $01, $c9, $fa, $07, $df, $3d, $fe, $6f, $20, $14, $3e, $7f, $ea, $07
	db $df, $fa, $06, $df, $3d, $fe, $6f, $20, $02, $3e, $7f, $ea, $06, $df, $18, $03
	db $ea, $07, $df, $fa, $01, $df, $3d, $ea, $01, $df, $c9, $fa, $46, $c8, $cb, $57
	db $28, $26, $fa, $8b, $c8, $3c, $fe, $0a, $20, $02, $3e, $00, $ea, $8b, $c8, $21
	db $8e, $c8, $34, $fa, $8b, $c8, $0e, $04, $cd, $be, $1d, $7d, $ea, $02, $df, $ea
	db $00, $df, $3e, $0c, $cd, $2c, $1b, $c9, $fa, $46, $c8, $cb, $4f, $ca, $63, $4d
	db $fa, $01, $df, $47, $fa, $00, $df, $21, $24, $4e, $85, $6f, $3e, $00, $8c, $67
	db $7e, $90, $30, $14, $3e, $00, $ea, $22, $c8, $3e, $0b, $ea, $23, $c8, $11, $04
	db $12, $21, $00, $88, $cd, $f6, $49, $c9, $fa, $01, $df, $ea, $23, $c8, $fa, $00
	db $df, $21, $d4, $4d, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $22, $c8, $21, $fc
	db $4d, $fa, $00, $df, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $0a, $df, $11, $04
	db $12, $21, $00, $88, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $7d, $ea, $27, $c8
	db $7c, $ea, $28, $c8, $fa, $0a, $df, $c7, $2e, $4c, $33, $4c, $52, $4c, $71, $4c
	db $90, $4c, $95, $4c, $b4, $4c, $d3, $4c, $f2, $4c, $0c, $4d, $2b, $4d, $4a, $4d
	db $4f, $4d, $54, $4d, $59, $4d, $5e, $4d, $21, $00, $41, $d7, $c9, $fa, $22, $c8
	db $fe, $00, $20, $13, $fa, $23, $c8, $fe, $e2, $38, $0c, $d6, $e2, $ea, $23, $c8
	db $3e, $00, $ea, $22, $c8, $18, $05, $21, $00, $42, $d7, $c9, $fa, $22, $c8, $fe
	db $01, $20, $13, $fa, $23, $c8, $fe, $98, $38, $0c, $d6, $98, $ea, $23, $c8, $3e
	db $00, $ea, $22, $c8, $18, $05, $21, $00, $43, $d7, $c9, $fa, $22, $c8, $fe, $01
	db $20, $13, $fa, $23, $c8, $fe, $44, $38, $0c, $d6, $44, $ea, $23, $c8, $3e, $00
	db $ea, $22, $c8, $18, $05, $21, $00, $44, $d7, $c9, $21, $00, $45, $d7, $c9, $fa
	db $22, $c8, $fe, $00, $20, $13, $fa, $23, $c8, $fe, $c8, $38, $0c, $d6, $c8, $ea
	db $23, $c8, $3e, $00, $ea, $22, $c8, $18, $05, $21, $00, $46, $d7, $c9, $fa, $22
	db $c8, $fe, $01, $20, $13, $fa, $23, $c8, $fe, $74, $38, $0c, $d6, $74, $ea, $23
	db $c8, $3e, $00, $ea, $22, $c8, $18, $05, $21, $00, $47, $d7, $c9, $fa, $22, $c8
	db $fe, $01, $20, $13, $fa, $23, $c8, $fe, $12, $38, $0c, $d6, $12, $ea, $23, $c8
	db $3e, $00, $ea, $22, $c8, $18, $05, $21, $00, $48, $d7, $c9, $fa, $23, $c8, $c6
	db $12, $fe, $e0, $38, $0c, $d6, $e0, $ea, $23, $c8, $3e, $00, $ea, $22, $c8, $18
	db $05, $21, $00, $49, $d7, $c9, $fa, $22, $c8, $fe, $02, $20, $13, $fa, $23, $c8
	db $fe, $c0, $38, $0c, $d6, $c0, $ea, $23, $c8, $3e, $00, $ea, $22, $c8, $18, $05
	db $21, $00, $4a, $d7, $c9, $fa, $22, $c8, $fe, $01, $20, $13, $fa, $23, $c8, $fe
	db $68, $38, $0c, $d6, $68, $ea, $23, $c8, $3e, $00, $ea, $22, $c8, $18, $0f, $21
	db $00, $4b, $d7, $c9, $21, $00, $4c, $d7, $c9, $21, $00, $4d, $d7, $c9, $21, $00
	db $4e, $d7, $c9, $21, $06, $59, $d7, $c9, $21, $00, $56, $d7, $c9, $fa, $42, $c8
	db $e6, $08, $fe, $08, $20, $0d, $3e, $07, $ea, $8a, $c8, $af, $ea, $8b, $c8, $21
	db $8e, $c8, $34, $c9, $fa, $08, $df, $fe, $00, $20, $34, $3e, $0a, $ea, $08, $df
	db $fa, $04, $df, $67, $fa, $05, $df, $6f, $fa, $09, $df, $fe, $00, $20, $0e, $3e
	db $1f, $cd, $b9, $1a, $cd, $ad, $1a, $3e, $01, $ea, $09, $df, $c9, $fa, $06, $df
	db $cd, $b9, $1a, $fa, $07, $df, $cd, $ad, $1a, $3e, $00, $ea, $09, $df, $c9, $3d
	db $ea, $08, $df, $c9, $fa, $06, $df, $d6, $70, $07, $07, $07, $07, $ea, $01, $df
	db $fa, $07, $df, $d6, $70, $4f, $fa, $01, $df, $81, $ea, $01, $df, $c9, $00, $01
	db $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $00, $01, $01
	db $00, $01, $01, $01, $02, $01, $01, $00, $01, $02, $03, $04, $05, $06, $07, $00
	db $01, $01, $00, $01, $02, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $02, $03, $05, $06, $07, $09, $09, $0a, $0d, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $0c, $0f, $0e, $0e, $0e, $0e, $09, $5f
	db $6f, $9f, $0a, $ff, $ff, $d6, $2b, $2b, $27, $24, $01, $2f, $0b, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $d8, $ff, $fd, $12, $06, $08, $03, $14, $14, $00, $ff
	db $d6, $ff, $06, $02, $0d, $00, $96, $62, $30, $28, $36, $36, $28, $2a, $28, $f1
	db $62, $62, $62, $62, $62, $27, $28, $25, $38, $2a, $62, $97, $f1, $62, $62, $37
	db $28, $36, $37, $30, $28, $36, $f1, $27, $28, $25, $38, $2a, $31, $24, $30, $28
	db $f1, $62, $62, $62, $36, $3c, $36, $30, $28, $36, $f1, $62, $30, $31, $24, $30
	db $28, $30, $28, $36, $f1, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $24
	db $25, $26, $27, $28, $29, $62, $2e, $28, $2c, $37, $32, $38, $30, $28, $36, $f1
	db $36, $3c, $38, $3d, $32, $2e, $38, $30, $28, $36, $f1, $37, $32, $2e, $38, $2a
	db $2c, $31, $24, $30, $28, $f1, $62, $62, $62, $36, $3c, $38, $31, $24, $30, $28
	db $f0, $62, $62, $2c, $37, $28, $30, $31, $24, $30, $28, $f1, $62, $62, $62, $2c
	db $37, $28, $30, $30, $28, $36, $f1, $36, $28, $2c, $2e, $24, $2e, $38, $30, $28
	db $36, $f1, $62, $25, $37, $2f, $3a, $2c, $31, $30, $28, $36, $f0, $62, $25, $24
	db $37, $37, $2f, $28, $30, $28, $36, $f1, $62, $62, $2c, $37, $28, $30, $30, $28
	db $36, $02, $f1, $37, $32, $2e, $38, $2a, $38, $30, $28, $36, $02, $f1, $2e, $24
	db $2c, $3a, $24, $30, $28, $36, $00, $00, $f0, $2e, $24, $2c, $3a, $24, $30, $28
	db $36, $00, $01, $f1, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $02, $f1, $2e
	db $24, $2c, $3a, $24, $30, $28, $36, $00, $03, $f1, $2e, $24, $2c, $3a, $24, $30
	db $28, $36, $00, $04, $f0, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $05, $f1
	db $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $06, $f1, $2e, $24, $2c, $3a, $24
	db $30, $28, $36, $00, $07, $f1, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $08
	db $f0, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $09, $f1, $62, $62, $62, $62
	db $25, $37, $2f, $30, $28, $36, $f1, $62, $62, $62, $25, $37, $2f, $30, $28, $36
	db $01, $f1, $62, $62, $62, $25, $37, $2f, $30, $28, $36, $02, $f0, $62, $62, $62
	db $25, $37, $2f, $26, $30, $27, $f1, $62, $62, $25, $37, $2f, $30, $28, $36, $04
	db $f1, $36, $37, $24, $29, $29, $30, $28, $36, $00, $f1, $36, $37, $24, $29, $29
	db $30, $28, $36, $01, $f0, $28, $31, $27, $2c, $31, $2a, $30, $28, $36, $f1, $30
	db $32, $31, $2b, $24, $2c, $30, $28, $36, $f1, $30, $32, $31, $2c, $31, $29, $30
	db $28, $36, $f1, $37, $32, $2e, $38, $2a, $2c, $30, $28, $36, $f0, $62, $27, $28
	db $30, $32, $30, $28, $36, $00, $00, $f1, $27, $28, $30, $32, $31, $24, $30, $28
	db $00, $00, $f1, $62, $25, $32, $32, $2e, $30, $28, $36, $00, $00, $f1, $62, $32
	db $25, $2d, $37, $30, $28, $36, $00, $00, $f0, $2c, $31, $39, $24, $2f, $2c, $27
	db $62, $31, $38, $30, $25, $28, $35, $63, $f0, $2c, $4b, $43, $49, $46, $40, $51
	db $50, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $54, $46, $51, $45, $62, $3e, $62
	db $50, $4a, $3e, $49, $49, $62, $43, $46, $4f, $42, $f1, $3f, $3e, $49, $49, $f0
	db $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $f1
	db $54, $46, $51, $45, $62, $3e, $62, $44, $46, $3e, $4b, $51, $f1, $43, $46, $4f
	db $42, $62, $3f, $3e, $49, $49, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62
	db $41, $3e, $4a, $3e, $44, $42, $f1, $54, $46, $51, $45, $62, $4d, $46, $49, $49
	db $3e, $4f, $50, $62, $4c, $43, $f1, $43, $46, $4f, $42, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $3e
	db $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1
	db $3e, $62, $50, $4a, $3e, $49, $49, $62, $3f, $49, $3e, $57, $42, $f0, $2c, $4b
	db $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c
	db $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51
	db $45, $f1, $3e, $62, $45, $52, $44, $42, $62, $3f, $49, $3e, $57, $42, $f0, $2c
	db $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51
	db $4c, $f1, $3e, $49, $49, $62, $51, $45, $42, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f1, $54, $46, $51, $45, $62, $3e, $62, $3f, $46, $44, $62, $3f, $49, $3e
	db $57, $42, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $62, $54, $46, $51, $45, $f1, $3e, $4b, $62, $42, $55, $4d, $49, $4c, $50
	db $46, $4c, $4b, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a
	db $3e, $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46
	db $42, $50, $62, $54, $46, $51, $45, $f1, $42, $55, $4d, $49, $4c, $50, $46, $4c
	db $4b, $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $62, $54, $46, $51, $45, $f1, $3e, $62, $2b, $38, $2a, $28, $62, $42, $55
	db $4d, $49, $4c, $50, $46, $4c, $4b, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50
	db $62, $41, $3e, $4a, $3e, $44, $42, $50, $f1, $51, $4c, $62, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51, $45, $62, $3e, $62, $54
	db $45, $46, $4f, $49, $54, $46, $4b, $41, $f0, $2c, $4b, $43, $49, $46, $40, $51
	db $50, $62, $41, $3e, $4a, $3e, $44, $42, $50, $f1, $51, $4c, $62, $3e, $49, $49
	db $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51, $45, $62, $3e, $62
	db $51, $4c, $4f, $4b, $3e, $41, $4c, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50
	db $62, $41, $3e, $4a, $3e, $44, $42, $50, $f1, $51, $4c, $62, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51, $45, $62, $3e, $62, $45
	db $52, $4f, $4f, $46, $40, $3e, $4b, $42, $f0, $29, $4f, $42, $42, $57, $42, $50
	db $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51
	db $45, $62, $46, $40, $42, $f0, $37, $52, $4f, $4b, $50, $62, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $f1, $46, $4b, $51, $4c, $62, $46, $40, $42
	db $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42
	db $4a, $46, $42, $50, $62, $54, $46, $51, $45, $62, $3e, $f1, $43, $4f, $46, $44
	db $46, $41, $62, $3f, $49, $46, $57, $57, $3e, $4f, $41, $f0, $36, $51, $4f, $46
	db $48, $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62
	db $54, $46, $51, $45, $f1, $49, $46, $44, $45, $51, $4b, $46, $4b, $44, $f0, $36
	db $51, $4f, $46, $48, $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46
	db $42, $50, $62, $54, $46, $51, $45, $f1, $3e, $62, $51, $45, $52, $4b, $41, $42
	db $4f, $3f, $4c, $49, $51, $f0, $36, $51, $4f, $46, $48, $42, $50, $62, $3e, $49
	db $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $51
	db $45, $52, $4b, $41, $42, $4f, $3f, $4c, $49, $51, $50, $f0, $2c, $4b, $50, $51
	db $3e, $4b, $51, $49, $56, $62, $48, $4b, $4c, $40, $48, $50, $f1, $4c, $52, $51
	db $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $2c, $4b, $50, $51, $3e, $4b
	db $51, $49, $56, $62, $48, $4b, $4c, $40, $48, $50, $f1, $4c, $52, $51, $62, $3e
	db $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $2e, $4b, $4c, $40, $48
	db $50, $62, $4c, $52, $51, $62, $51, $45, $42, $f1, $40, $3e, $50, $51, $42, $4f
	db $62, $3e, $4b, $41, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50
	db $f0, $33, $52, $51, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f1, $51
	db $4c, $62, $50, $49, $42, $42, $4d, $f0, $33, $52, $51, $50, $62, $3e, $49, $49
	db $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $51, $4c, $62, $50, $49, $42, $42
	db $4d, $f0, $36, $52, $50, $4d, $42, $4b, $41, $50, $62, $3e, $49, $49, $62, $51
	db $45, $42, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $43, $4f, $4c, $4a, $f1
	db $40, $3e, $50, $51, $46, $4b, $44, $62, $50, $4d, $42, $49, $49, $50, $f0, $28
	db $4b, $44, $52, $49, $43, $50, $62, $3e, $49, $49, $62, $51, $45, $42, $f1, $42
	db $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $62, $3e, $4b, $f1, $46
	db $49, $49, $52, $50, $46, $4c, $4b, $f0, $26, $4c, $4b, $43, $52, $50, $42, $50
	db $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $36, $51, $42
	db $3e, $49, $50, $62, $42, $4b, $42, $4a, $56, $68, $62, $30, $33, $f0, $24, $3f
	db $50, $4c, $4f, $3f, $50, $62, $51, $45, $42, $62, $30, $33, $62, $4c, $43, $f1
	db $3e, $62, $50, $4d, $42, $49, $49, $62, $40, $3e, $50, $51, $62, $3f, $56, $f1
	db $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $2f, $4c, $54, $42, $4f, $50, $62
	db $3e, $4b, $f1, $42, $4b, $42, $4a, $56, $68, $62, $27, $28, $29, $28, $31, $36
	db $28, $f0, $2f, $4c, $54, $42, $4f, $50, $62, $3e, $49, $49, $62, $51, $45, $42
	db $f1, $42, $4b, $42, $4a, $46, $42, $50, $5c, $62, $27, $28, $29, $28, $31, $36
	db $28, $f0, $2c, $4b, $40, $4f, $42, $3e, $50, $42, $50, $62, $27, $28, $29, $28
	db $31, $36, $28, $f1, $43, $4c, $4f, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0
	db $2c, $4b, $40, $4f, $42, $3e, $50, $42, $50, $62, $27, $28, $29, $28, $31, $36
	db $28, $f1, $43, $4c, $4f, $62, $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50
	db $f0, $27, $42, $40, $4f, $42, $3e, $50, $42, $50, $62, $24, $2a, $2c, $2f, $2c
	db $37, $3c, $f1, $4c, $43, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $27
	db $42, $40, $4f, $42, $3e, $50, $42, $50, $62, $24, $2a, $2c, $2f, $2c, $37, $3c
	db $f1, $4c, $43, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0
	db $2c, $4b, $40, $4f, $42, $3e, $50, $42, $50, $62, $24, $2a, $2c, $2f, $2c, $37
	db $3c, $f1, $43, $4c, $4f, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $2c, $4b
	db $40, $4f, $42, $3e, $50, $42, $50, $62, $24, $2a, $2c, $2f, $2c, $37, $3c, $f1
	db $43, $4c, $4f, $62, $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $24
	db $49, $49, $62, $3e, $49, $49, $46, $42, $50, $62, $3f, $42, $40, $4c, $4a, $42
	db $f1, $4a, $4c, $4f, $42, $62, $4f, $42, $50, $46, $50, $51, $3e, $4b, $51, $62
	db $51, $4c, $f1, $3f, $4f, $42, $3e, $51, $45, $62, $3e, $51, $51, $3e, $40, $48
	db $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $4c, $52, $3f, $49
	db $42, $f1, $51, $45, $42, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1
	db $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $2c, $4b, $40, $4f, $42, $3e, $50
	db $42, $50, $f1, $4f, $42, $50, $46, $50, $51, $3e, $4b, $40, $42, $62, $51, $4c
	db $f1, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $62, $50, $4d, $42, $49, $49
	db $50, $f0, $35, $42, $43, $49, $42, $40, $51, $50, $62, $51, $45, $42, $62, $4a
	db $3e, $44, $46, $40, $f1, $40, $3e, $50, $51, $62, $3f, $56, $62, $51, $45, $42
	db $62, $42, $4b, $42, $4a, $56, $f1, $43, $4c, $4f, $62, $4c, $4b, $42, $62, $51
	db $52, $4f, $4b, $f0, $35, $42, $43, $49, $42, $40, $51, $50, $62, $51, $45, $42
	db $62, $42, $4b, $42, $4a, $56, $f1, $50, $4d, $42, $49, $49, $50, $62, $51, $45
	db $3e, $51, $62, $51, $45, $42, $f1, $40, $3e, $50, $51, $42, $4f, $62, $4f, $42
	db $40, $42, $46, $53, $42, $50, $f0, $37, $4f, $3e, $4b, $50, $43, $4c, $4f, $4a
	db $62, $46, $4b, $51, $4c, $f1, $51, $45, $42, $62, $50, $3e, $4a, $42, $62, $50
	db $4d, $42, $40, $46, $42, $50, $f1, $3e, $50, $62, $51, $45, $42, $62, $42, $4b
	db $42, $4a, $56, $f0, $37, $52, $4f, $4b, $50, $62, $3e, $49, $49, $62, $3e, $49
	db $49, $46, $42, $50, $f1, $46, $4b, $51, $4c, $62, $3e, $62, $4d, $4f, $4c, $51
	db $42, $40, $51, $46, $53, $42, $f1, $49, $52, $4a, $4d, $62, $4c, $43, $62, $46
	db $4f, $4c, $4b, $f0, $2b, $42, $3e, $49, $50, $62, $3f, $42, $51, $54, $42, $42
	db $4b, $f1, $03, $00, $62, $51, $4c, $62, $04, $00, $62, $2b, $33, $62, $43, $4c
	db $4f, $62, $3e, $4b, $f1, $3e, $49, $49, $56, $f0, $2b, $42, $3e, $49, $50, $62
	db $3f, $42, $51, $54, $42, $42, $4b, $f1, $07, $05, $62, $3e, $4b, $41, $62, $09
	db $00, $62, $2b, $33, $62, $43, $4c, $4f, $f1, $3e, $49, $49, $62, $3e, $49, $49
	db $46, $42, $50, $f0, $2b, $42, $3e, $49, $50, $62, $2b, $33, $62, $51, $4c, $62
	db $4a, $3e, $55, $f1, $43, $4c, $4f, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0
	db $2b, $42, $3e, $49, $50, $62, $3f, $42, $51, $54, $42, $42, $4b, $f1, $09, $00
	db $62, $51, $4c, $62, $01, $02, $00, $62, $2b, $33, $62, $43, $4c, $4f, $f1, $3e
	db $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $2b, $42, $3e, $49, $50, $62
	db $2b, $33, $62, $51, $4c, $62, $4a, $3e, $55, $f1, $43, $4c, $4f, $62, $3e, $49
	db $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $35, $42, $53, $46, $53, $42, $50
	db $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $35, $42, $53, $46, $53, $42, $50
	db $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $35, $42, $53, $46, $53, $42, $50
	db $62, $3e, $49, $49, $62, $4c, $51, $45, $42, $4f, $f1, $3e, $49, $49, $46, $42
	db $50, $62, $3f, $52, $51, $62, $51, $45, $42, $f1, $40, $3e, $50, $51, $42, $4f
	db $62, $40, $4c, $49, $49, $3e, $4d, $50, $42, $50, $f0, $26, $52, $4f, $42, $50
	db $62, $4d, $4c, $46, $50, $4c, $4b, $f0, $26, $52, $4f, $42, $50, $62, $4d, $3e
	db $4f, $3e, $49, $56, $50, $46, $50, $f1, $4c, $4f, $62, $54, $3e, $48, $42, $50
	db $62, $52, $4d, $f1, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $26, $52, $4f, $42
	db $50, $62, $40, $4c, $4b, $43, $52, $50, $46, $4c, $4b, $f0, $25, $4f, $42, $3e
	db $48, $50, $62, $3e, $62, $40, $52, $4f, $50, $42, $f0, $33, $4f, $4c, $51, $42
	db $40, $51, $50, $62, $43, $4f, $4c, $4a, $f1, $49, $3e, $4b, $41, $62, $45, $3e
	db $57, $3e, $4f, $41, $50, $f1, $54, $45, $46, $49, $42, $62, $51, $4f, $3e, $53
	db $42, $49, $46, $4b, $44, $f0, $35, $42, $53, $42, $3e, $49, $50, $62, $51, $45
	db $42, $62, $42, $4b, $51, $46, $4f, $42, $f1, $4a, $3e, $4d, $62, $4c, $43, $62
	db $51, $45, $42, $f1, $49, $3e, $4b, $41, $50, $40, $3e, $4d, $42, $f0, $24, $62
	db $4f, $3e, $4b, $41, $4c, $4a, $62, $50, $4d, $42, $49, $49, $5e, $f1, $40, $3e
	db $4b, $62, $3f, $42, $62, $44, $4c, $4c, $41, $62, $4c, $4f, $62, $3f, $3e, $41
	db $f0, $f0, $29, $42, $3e, $4f, $49, $42, $50, $50, $62, $3e, $51, $51, $3e, $40
	db $48, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $49, $46, $48, $42, $62, $3e
	db $62, $4f, $3e, $4a, $f1, $54, $46, $51, $45, $62, $46, $51, $50, $62, $51, $4f
	db $52, $42, $f1, $46, $4b, $4b, $42, $4f, $62, $50, $51, $4f, $42, $4b, $44, $51
	db $45, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $49, $46, $48, $42, $62, $51
	db $45, $42, $4f, $42, $f1, $46, $50, $62, $4b, $4c, $62, $51, $4c, $4a, $4c, $4f
	db $4f, $4c, $54, $f0, $24, $62, $50, $52, $46, $40, $46, $41, $42, $62, $3e, $51
	db $51, $3e, $40, $48, $f1, $51, $4c, $62, $48, $4b, $4c, $40, $48, $62, $4c, $52
	db $51, $62, $51, $45, $42, $f1, $42, $4b, $42, $4a, $56, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44
	db $42, $62, $51, $4c, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f1, $4c, $4f, $62
	db $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $24, $51, $51, $3e, $40, $48, $50
	db $62, $49, $46, $48, $42, $62, $3e, $f1, $4f, $52, $51, $45, $49, $42, $50, $50
	db $62, $41, $42, $4a, $4c, $4b, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62
	db $45, $52, $44, $42, $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3e
	db $4b, $62, $42, $4b, $42, $4a, $56, $f1, $4c, $4b, $62, $51, $45, $42, $62, $4b
	db $42, $55, $51, $62, $51, $52, $4f, $4b, $f0, $2d, $52, $4a, $4d, $50, $62, $46
	db $4b, $51, $4c, $62, $51, $45, $42, $62, $3e, $46, $4f, $f1, $3e, $4b, $41, $62
	db $3e, $51, $51, $3e, $40, $48, $50, $62, $4c, $4b, $f1, $51, $45, $42, $62, $4b
	db $42, $55, $51, $62, $51, $52, $4f, $4b, $f0, $36, $52, $40, $48, $50, $62, $46
	db $4b, $62, $3e, $46, $4f, $62, $4d, $4c, $54, $42, $4f, $f1, $51, $4c, $62, $46
	db $4b, $43, $49, $46, $40, $51, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $4c, $4b
	db $62, $51, $45, $42, $62, $4b, $42, $55, $51, $62, $51, $52, $4f, $4b, $f0, $25
	db $52, $4f, $4b, $46, $4b, $44, $62, $3f, $49, $3e, $41, $42, $f1, $50, $54, $4c
	db $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0, $37, $45, $52, $4b, $41, $42
	db $4f, $3f, $4c, $49, $51, $f1, $50, $54, $4c, $4f, $41, $62, $3e, $51, $51, $3e
	db $40, $48, $f0, $3a, $45, $46, $4f, $49, $46, $4b, $44, $62, $53, $3e, $40, $52
	db $52, $4a, $f1, $50, $54, $4c, $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0
	db $29, $4f, $42, $42, $57, $46, $4b, $44, $62, $46, $40, $42, $f1, $50, $54, $4c
	db $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0, $2c, $4b, $43, $49, $46, $40
	db $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42, $62
	db $51, $4c, $62, $4a, $42, $51, $3e, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50
	db $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1
	db $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $41, $4f, $3e, $44, $4c, $4b
	db $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51
	db $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3f, $42, $3e, $50, $51
	db $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51
	db $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3f, $46, $4f, $41, $50
	db $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1
	db $41, $3e, $4a, $3e, $44, $42, $62, $4c, $4b, $62, $41, $42, $53, $46, $49, $50
	db $f0, $2c, $4b, $43, $49, $46, $40, $51, $62, $44, $4f, $42, $3e, $51, $f1, $41
	db $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $57, $4c, $4a, $3f, $46, $42, $50
	db $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1
	db $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $4a, $3e, $51, $42, $4f, $46
	db $3e, $49, $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a
	db $3e, $44, $42, $f1, $51, $4c, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46
	db $42, $50, $f1, $54, $46, $51, $45, $62, $4a, $3e, $4b, $56, $62, $40, $52, $51
	db $50, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $51, $54, $46, $40, $42, $62
	db $46, $4b, $f1, $4c, $4b, $42, $62, $51, $52, $4f, $4b, $f0, $24, $51, $51, $3e
	db $40, $48, $50, $62, $04, $62, $51, $46, $4a, $42, $50, $f1, $46, $4b, $62, $4c
	db $4b, $42, $62, $51, $52, $4f, $4b, $f0, $26, $3e, $49, $49, $50, $62, $43, $4c
	db $4f, $62, $3e, $62, $3f, $3e, $40, $48, $52, $4d, $f0, $26, $3e, $49, $49, $50
	db $62, $3e, $62, $44, $4f, $4c, $52, $4d, $62, $4c, $43, $f1, $4a, $4c, $4b, $50
	db $51, $42, $4f, $50, $62, $43, $4c, $4f, $62, $45, $42, $49, $4d, $f0, $37, $54
	db $4c, $62, $3e, $51, $51, $3e, $40, $48, $50, $f1, $4c, $4b, $62, $51, $45, $42
	db $62, $4b, $42, $55, $51, $f1, $51, $52, $4f, $4b, $f0, $24, $49, $49, $4c, $54
	db $50, $62, $56, $4c, $52, $62, $51, $4c, $f1, $3e, $51, $51, $3e, $40, $48, $62
	db $43, $46, $4f, $50, $51, $f1, $46, $4b, $62, $51, $45, $42, $62, $51, $52, $4f
	db $4b, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $2a, $4f, $42, $3e, $51
	db $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3e, $4b, $62, $42, $4b
	db $42, $4a, $56, $f1, $3e, $51, $62, $51, $45, $42, $62, $49, $3e, $50, $51, $62
	db $51, $52, $4f, $4b, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49
	db $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $46, $4b, $62, $4c, $4b, $42, $f1
	db $3e, $51, $51, $3e, $40, $48, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e
	db $4b, $62, $42, $4b, $42, $4a, $56, $f1, $54, $46, $51, $45, $62, $3e, $62, $53
	db $46, $4c, $49, $42, $4b, $51, $f1, $54, $45, $46, $4f, $49, $54, $46, $4b, $41
	db $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42
	db $4a, $46, $42, $50, $62, $54, $46, $51, $45, $62, $3e, $f1, $44, $46, $3e, $4b
	db $51, $62, $53, $3e, $40, $52, $52, $4a, $f0, $2c, $4b, $43, $49, $46, $40, $51
	db $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $4c, $4b, $f1, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $49, $46, $44
	db $45, $51, $4b, $46, $4b, $44, $f0, $37, $45, $4f, $4c, $54, $50, $62, $3e, $62
	db $45, $52, $44, $42, $62, $4f, $4c, $40, $48, $f1, $4c, $4b, $62, $3e, $49, $49
	db $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $25, $4f, $42, $3e, $51, $45, $42
	db $50, $62, $4c, $52, $51, $62, $43, $46, $4f, $42, $f1, $51, $4c, $62, $46, $4b
	db $43, $49, $46, $40, $51, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $4c, $4b, $62
	db $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $25, $49, $4c, $54
	db $50, $62, $4c, $52, $51, $62, $3e, $62, $3f, $49, $3e, $57, $42, $f1, $51, $4c
	db $62, $46, $4b, $43, $49, $46, $40, $51, $62, $41, $3e, $4a, $3e, $44, $42, $f1
	db $4c, $4b, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $25
	db $52, $4f, $4b, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50
	db $f1, $54, $46, $51, $45, $62, $3e, $62, $41, $42, $53, $3e, $50, $51, $3e, $51
	db $46, $4b, $44, $f1, $43, $49, $3e, $4a, $42, $f0, $24, $51, $51, $3e, $40, $48
	db $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46
	db $51, $45, $62, $3e, $4b, $f1, $52, $4b, $46, $4a, $3e, $44, $46, $4b, $3e, $3f
	db $49, $42, $62, $3f, $49, $3e, $57, $42, $f0, $2c, $4b, $43, $49, $46, $40, $51
	db $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $46, $51, $50
	db $62, $43, $4f, $46, $44, $46, $41, $62, $3f, $4f, $42, $3e, $51, $45, $f0, $29
	db $4f, $42, $42, $57, $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46
	db $42, $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $62, $54, $46, $51, $45, $62, $3e, $f1, $53, $46, $4c, $49, $42, $4b, $51
	db $62, $46, $40, $42, $62, $50, $51, $4c, $4f, $4a, $f0, $24, $51, $51, $3e, $40
	db $48, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54
	db $46, $51, $45, $62, $3e, $4b, $f1, $46, $4b, $40, $3e, $4b, $41, $42, $50, $40
	db $42, $4b, $51, $62, $3e, $46, $4f, $f0, $2b, $42, $49, $49, $62, $4d, $4c, $54
	db $42, $4f, $42, $41, $f1, $49, $46, $44, $45, $51, $4b, $46, $4b, $44, $62, $3f
	db $49, $3e, $50, $51, $f1, $3e, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49
	db $62, $43, $4c, $42, $50, $f0, $26, $4f, $42, $3e, $51, $42, $50, $62, $3e, $62
	db $45, $52, $44, $42, $f1, $42, $55, $4d, $49, $4c, $50, $46, $4c, $4b, $62, $51
	db $4c, $f1, $3e, $51, $51, $3e, $40, $48, $62, $3e, $49, $49, $62, $42, $4b, $42
	db $4a, $46, $42, $50, $f0, $37, $45, $42, $62, $4a, $4c, $50, $51, $62, $4d, $4c
	db $54, $42, $4f, $43, $52, $49, $f1, $50, $4d, $42, $49, $49, $62, $51, $45, $3e
	db $51, $62, $3e, $43, $43, $42, $40, $51, $50, $f1, $3e, $49, $49, $62, $42, $4b
	db $42, $4a, $46, $42, $50, $f0, $33, $4c, $46, $50, $4c, $4b, $50, $62, $51, $45
	db $42, $62, $42, $4b, $42, $4a, $56, $f1, $51, $45, $3e, $51, $62, $3e, $51, $51
	db $3e, $40, $48, $42, $41, $62, $51, $45, $42, $f1, $3e, $49, $49, $56, $f0, $36
	db $42, $4b, $41, $50, $62, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $f1, $51
	db $45, $3e, $51, $62, $3e, $51, $51, $3e, $40, $48, $42, $41, $f1, $51, $45, $42
	db $62, $3e, $49, $49, $56, $62, $51, $4c, $62, $50, $49, $42, $42, $4d, $f0, $33
	db $3e, $4f, $3e, $49, $56, $57, $42, $50, $62, $51, $45, $42, $f1, $42, $4b, $42
	db $4a, $56, $62, $51, $45, $3e, $51, $f1, $3e, $51, $51, $3e, $40, $48, $42, $41
	db $62, $51, $45, $42, $62, $3e, $49, $49, $56, $f0, $36, $42, $4b, $41, $62, $3e
	db $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $51, $4c, $62, $50, $49
	db $42, $42, $4d, $f0, $33, $3e, $4f, $3e, $49, $56, $57, $42, $50, $62, $3e, $49
	db $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $33, $4c, $46, $50, $4c, $4b
	db $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $36, $42
	db $53, $42, $4f, $49, $56, $62, $4d, $4c, $46, $50, $4c, $4b, $50, $f1, $3e, $49
	db $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $26, $4c, $4b, $43, $52, $50
	db $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $26
	db $52, $4f, $50, $42, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f0, $30, $3e, $48, $42, $50, $62, $56, $4c, $52, $62, $43, $42, $42, $49
	db $f1, $45, $3e, $4d, $4d, $56, $f0, $2c, $4b, $50, $51, $3e, $4b, $51, $49, $56
	db $62, $48, $4b, $4c, $40, $48, $50, $f1, $4c, $52, $51, $62, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $f0, $24, $51, $51, $3e, $40, $48, $50, $62
	db $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45
	db $f1, $3e, $62, $50, $3e, $4b, $41, $50, $51, $4c, $4f, $4a, $f0, $25, $49, $46
	db $4b, $41, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f1
	db $54, $46, $51, $45, $62, $46, $51, $50, $62, $3f, $4f, $46, $44, $45, $51, $f1
	db $49, $46, $44, $45, $51, $f0, $30, $3e, $48, $42, $50, $62, $3e, $49, $49, $62
	db $42, $4b, $42, $4a, $46, $42, $50, $f1, $49, $42, $50, $50, $62, $4f, $42, $50
	db $46, $50, $51, $3e, $4b, $51, $f1, $51, $4c, $62, $4a, $3e, $44, $46, $40, $62
	db $50, $4d, $42, $49, $49, $50, $f0, $27, $4f, $4c, $4d, $50, $62, $3e, $4b, $62
	db $42, $4b, $42, $4a, $56, $68, $f1, $30, $33, $62, $54, $46, $51, $45, $62, $46
	db $51, $50, $62, $4c, $41, $41, $f1, $41, $3e, $4b, $40, $46, $4b, $44, $62, $50
	db $51, $42, $4d, $50, $f0, $36, $51, $42, $3e, $49, $50, $62, $3e, $4b, $62, $42
	db $4b, $42, $4a, $56, $68, $f1, $30, $33, $62, $54, $46, $51, $45, $62, $46, $51
	db $50, $f1, $4a, $42, $50, $4a, $42, $4f, $46, $57, $46, $4b, $44, $62, $41, $3e
	db $4b, $40, $42, $f0, $36, $46, $41, $42, $50, $51, $42, $4d, $50, $62, $3e, $4b
	db $f1, $3e, $51, $51, $3e, $40, $48, $f0, $2f, $52, $4f, $42, $50, $62, $3e, $4b
	db $62, $42, $4b, $42, $4a, $56, $62, $51, $4c, $f1, $3e, $62, $51, $4f, $3e, $4d
	db $62, $54, $46, $51, $45, $62, $46, $51, $50, $f1, $41, $3e, $4b, $40, $42, $f0
	db $2f, $46, $40, $48, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f1, $51
	db $4c, $62, $50, $51, $4c, $4d, $62, $46, $51, $62, $43, $4f, $4c, $4a, $f1, $3e
	db $51, $51, $3e, $40, $48, $46, $4b, $44, $f0, $2f, $4c, $54, $42, $4f, $50, $62
	db $27, $28, $29, $28, $31, $36, $28, $f1, $3f, $56, $62, $44, $46, $53, $46, $4b
	db $44, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f1, $3e, $62, $50, $46, $40
	db $48, $49, $56, $62, $49, $46, $40, $48, $f0, $37, $4f, $46, $4d, $50, $62, $3e
	db $4b, $62, $42, $4b, $42, $4a, $56, $62, $3f, $56, $f1, $50, $54, $42, $42, $4d
	db $46, $4b, $44, $62, $46, $51, $50, $62, $49, $42, $44, $50, $f0, $37, $4f, $46
	db $4d, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $29
	db $4f, $42, $42, $57, $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46
	db $42, $50, $62, $54, $46, $51, $45, $62, $3e, $f1, $53, $42, $4f, $56, $62, $49
	db $4c, $52, $41, $62, $4f, $4c, $3e, $4f, $f0, $36, $52, $4a, $4a, $4c, $4b, $50
	db $62, $4a, $4c, $4b, $50, $51, $42, $4f, $50, $f0, $2c, $4a, $46, $51, $3e, $51
	db $42, $50, $62, $51, $45, $42, $f1, $42, $4b, $42, $4a, $56, $68, $62, $3e, $51
	db $51, $3e, $40, $48, $f0, $27, $46, $50, $4d, $42, $49, $50, $62, $4a, $3e, $44
	db $46, $40, $f1, $42, $43, $43, $42, $40, $51, $50, $62, $4c, $4b, $62, $3e, $49
	db $49, $f1, $3e, $49, $49, $46, $42, $50, $f0, $26, $52, $4f, $42, $50, $62, $3e
	db $4b, $56, $62, $3e, $46, $49, $4a, $42, $4b, $51, $50, $f1, $43, $4c, $4f, $62
	db $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $2a, $4f, $42, $3e, $51
	db $49, $56, $62, $54, $42, $3e, $48, $42, $4b, $50, $f1, $51, $45, $42, $62, $42
	db $4b, $42, $4a, $56, $f0, $26, $4f, $42, $3e, $51, $42, $50, $62, $3e, $62, $51
	db $45, $46, $40, $48, $f1, $43, $4c, $44, $62, $51, $4c, $62, $50, $52, $50, $4d
	db $42, $4b, $41, $f1, $4a, $3e, $44, $46, $40, $62, $50, $4d, $42, $49, $49, $50
	db $f0, $36, $52, $4a, $4a, $4c, $4b, $50, $62, $37, $3e, $51, $50, $52, $f1, $4a
	db $4c, $4b, $50, $51, $42, $4f, $50, $62, $51, $4c, $62, $3e, $51, $51, $3e, $40
	db $48, $f1, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $f0, $36, $52, $4a, $4a
	db $4c, $4b, $50, $62, $27, $46, $3e, $44, $4c, $f1, $4a, $4c, $4b, $50, $51, $42
	db $4f, $50, $62, $51, $4c, $62, $3e, $51, $51, $3e, $40, $48, $f1, $51, $45, $42
	db $62, $42, $4b, $42, $4a, $56, $f0, $36, $52, $4a, $4a, $4c, $4b, $50, $62, $36
	db $3e, $4a, $50, $46, $f1, $4a, $4c, $4b, $50, $51, $42, $4f, $50, $62, $51, $4c
	db $62, $3e, $51, $51, $3e, $40, $48, $f1, $51, $45, $42, $62, $42, $4b, $42, $4a
	db $56, $f0, $36, $52, $4a, $4a, $4c, $4b, $50, $62, $25, $3e, $57, $4c, $4c, $f1
	db $4a, $4c, $4b, $50, $51, $42, $4f, $50, $62, $51, $4c, $62, $3e, $51, $51, $3e
	db $40, $48, $f1, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $f0, $37, $45, $4f
	db $4c, $54, $50, $62, $46, $51, $50, $42, $49, $43, $62, $46, $4b, $f1, $43, $4f
	db $4c, $4b, $51, $62, $4c, $43, $62, $51, $45, $42, $f1, $3e, $51, $51, $3e, $40
	db $48, $62, $43, $4c, $4f, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $37, $3e
	db $48, $42, $50, $62, $3e, $49, $49, $62, $51, $45, $42, $f1, $3e, $51, $51, $3e
	db $40, $48, $50, $62, $43, $4f, $4c, $4a, $62, $3e, $49, $49, $f1, $42, $4b, $42
	db $4a, $46, $42, $50, $f0, $35, $42, $43, $49, $42, $40, $51, $50, $62, $3f, $3e
	db $40, $48, $62, $24, $46, $4f, $f1, $3e, $51, $51, $3e, $40, $48, $62, $51, $4c
	db $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $35, $42, $43, $49, $42, $40
	db $51, $50, $62, $3f, $3e, $40, $48, $62, $24, $46, $4f, $f1, $3e, $51, $51, $3e
	db $40, $48, $50, $62, $51, $4c, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46
	db $42, $50, $f0, $27, $4c, $41, $44, $42, $50, $62, $3e, $4b, $62, $3e, $51, $51
	db $3e, $40, $48, $f0, $33, $4f, $42, $4d, $3e, $4f, $42, $50, $62, $51, $4c, $62
	db $41, $42, $43, $42, $4b, $41, $f1, $46, $51, $50, $42, $49, $43, $62, $43, $4c
	db $4f, $62, $3e, $4b, $f1, $42, $4b, $42, $4a, $56, $62, $3e, $51, $51, $3e, $40
	db $48, $f0, $33, $4f, $42, $4d, $3e, $4f, $42, $50, $62, $3e, $62, $50, $51, $4f
	db $4c, $4b, $44, $f1, $41, $42, $43, $42, $4b, $50, $42, $62, $3e, $44, $3e, $46
	db $4b, $50, $51, $f1, $3e, $4b, $56, $62, $3e, $51, $51, $3e, $40, $48, $f0, $36
	db $52, $40, $48, $50, $62, $3e, $49, $49, $62, $51, $45, $42, $62, $3e, $46, $4f
	db $f1, $51, $4c, $62, $46, $4b, $43, $49, $46, $40, $51, $62, $41, $3e, $4a, $3e
	db $44, $42, $f1, $4c, $4b, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f0, $27, $42, $43, $42, $4b, $41, $50, $62, $3e, $44, $3e, $46, $4b, $50
	db $51, $f1, $3e, $62, $40, $4c, $52, $4b, $51, $42, $4f, $3e, $51, $51, $3e, $40
	db $48, $f0, $36, $52, $50, $4d, $42, $4b, $41, $50, $62, $3e, $49, $49, $f1, $42
	db $4b, $42, $4a, $46, $42, $50, $5c, $62, $27, $3e, $4b, $40, $42, $f1, $3e, $51
	db $51, $3e, $40, $48, $50, $f0, $36, $52, $50, $4d, $42, $4b, $41, $50, $62, $3e
	db $4b, $f1, $42, $4b, $42, $4a, $56, $68, $62, $24, $46, $4f, $f1, $3e, $51, $51
	db $3e, $40, $48, $f0, $35, $42, $50, $51, $4c, $4f, $42, $50, $62, $05, $00, $00
	db $62, $2b, $33, $f1, $3f, $56, $62, $4a, $42, $41, $46, $51, $3e, $51, $46, $4c
	db $4b, $f0, $35, $42, $50, $51, $4c, $4f, $42, $50, $62, $3f, $42, $51, $54, $42
	db $42, $4b, $f1, $07, $00, $62, $51, $4c, $62, $08, $00, $62, $2b, $33, $62, $51
	db $4c, $62, $3e, $49, $49, $f1, $3e, $49, $49, $46, $42, $50, $f0, $35, $42, $53
	db $46, $53, $42, $50, $62, $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0
	db $35, $42, $53, $46, $53, $42, $50, $62, $3e, $49, $49, $62, $3e, $49, $49, $46
	db $42, $50, $f0, $f0, $26, $3e, $50, $51, $42, $4f, $62, $51, $4f, $3e, $4b, $50
	db $43, $4c, $4f, $4a, $50, $f1, $46, $4b, $51, $4c, $62, $3e, $62, $41, $4f, $3e
	db $44, $4c, $4b, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42
	db $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $50, $49, $46
	db $4a, $42, $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42
	db $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3f, $52, $44
	db $50, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51
	db $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $4d, $49, $3e, $4b, $51
	db $50, $f0, $30, $4c, $50, $51, $62, $41, $42, $50, $51, $4f, $52, $40, $51, $46
	db $53, $42, $f1, $50, $54, $4c, $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0
	db $30, $3e, $48, $42, $50, $62, $56, $4c, $52, $62, $43, $42, $42, $49, $f1, $50
	db $46, $40, $48, $f0, $f0, $4f, $66, $67, $66, $4c, $4e, $63, $4e, $9b, $4e, $c7
	db $4e, $f3, $4e, $1f, $4f, $4b, $4f, $77, $4f, $a3, $4f, $cb, $4f, $f3, $4f, $1f
	db $50, $2f, $50, $56, $50, $7d, $50, $a2, $50, $d4, $50, $05, $51, $39, $51, $6a
	db $51, $99, $51, $ce, $51, $ff, $51, $2e, $52, $5f, $52, $7c, $52, $97, $52, $c2
	db $52, $e5, $52, $0c, $53, $32, $53, $50, $53, $71, $53, $97, $53, $ae, $53, $c8
	db $53, $f5, $53, $1e, $54, $33, $54, $44, $54, $6f, $54, $88, $54, $a8, $54, $c6
	db $54, $e7, $54, $05, $55, $26, $55, $44, $55, $65, $55, $98, $55, $bf, $55, $e8
	db $55, $1a, $56, $4d, $56, $7a, $56, $aa, $56, $d0, $56, $fa, $56, $16, $57, $40
	db $57, $5f, $57, $6f, $57, $7f, $57, $b1, $57, $be, $57, $e2, $57, $f2, $57, $01
	db $58, $2c, $58, $54, $58, $77, $58, $78, $58, $88, $58, $b8, $58, $da, $58, $02
	db $59, $2f, $59, $4d, $59, $7f, $59, $af, $59, $e5, $59, $00, $5a, $19, $5a, $36
	db $5a, $50, $5a, $77, $5a, $98, $5a, $b8, $5a, $d7, $5a, $f7, $5a, $17, $5b, $3a
	db $5b, $68, $5b, $82, $5b, $9e, $5b, $b1, $5b, $d4, $5b, $f1, $5b, $18, $5c, $4b
	db $5c, $6d, $5c, $97, $5c, $bf, $5c, $ed, $5c, $0f, $5d, $42, $5d, $75, $5d, $a0
	db $5d, $cf, $5d, $05, $5e, $19, $5e, $51, $5e, $7e, $5e, $ac, $5e, $db, $5e, $0c
	db $5f, $35, $5f, $65, $5f, $90, $5f, $aa, $5f, $c0, $5f, $d4, $5f, $f0, $5f, $05
	db $60, $18, $60, $2d, $60, $4e, $60, $73, $60, $9c, $60, $cd, $60, $fb, $60, $2a
	db $61, $3e, $61, $66, $61, $8f, $61, $bf, $61, $e3, $61, $f5, $61, $1f, $62, $30
	db $62, $4b, $62, $6f, $62, $91, $62, $ab, $62, $d7, $62, $02, $63, $2d, $63, $58
	db $63, $83, $63, $b4, $63, $db, $63, $00, $64, $29, $64, $3a, $64, $68, $64, $95
	db $64, $c8, $64, $e8, $64, $0c, $65, $2a, $65, $48, $65, $73, $65, $86, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99
	db $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $9a, $65, $ba, $65, $da
	db $65, $f8, $65, $18, $66, $36, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a
	db $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a
	db $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a
	db $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a
	db $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a
	db $66

Data_56_6867::
	db $20, $00, $01, $ff, $00, $ff, $c6, $01, $02, $01, $fe, $01, $02, $03, $01, $01
	db $00, $ee, $ff, $ee, $ff, $fe, $ff, $d6, $01, $02, $00

Data_56_6882::
	db $20, $00, $01, $ff, $82, $ff, $c2, $ff, $a2, $ff, $92, $ff, $8a, $ff, $86, $ff
	db $82, $ff, $00, $ff, $38, $ff, $44, $ff, $82, $01, $14, $01, $44, $ff, $38, $ff
	db $00

Data_56_68A3::
	db $20, $00, $01, $ff, $00, $ff, $02, $ff, $04, $ff, $08, $ff, $10, $ff, $20, $ff
	db $40, $ff, $80, $ff, $00, $ff, $10, $ff, $92, $ff, $54, $ff, $38, $ff, $54, $ff
	db $92, $ff, $10

Data_56_68C6::
	db $00, $05, $05, $05, $ff, $fc, $01, $01, $0f, $0f, $3f, $3f, $7c, $7c, $f0, $f0
	db $e0, $e0, $e0, $e0, $ff, $05, $1e, $01, $80, $80, $05, $ff, $f4, $ff, $ff, $f8
	db $f8, $f8, $f8, $05, $ff, $f6, $f8, $f8, $1c, $05, $40, $0b, $0f, $0f, $0f, $0f
	db $0e, $05, $54, $07, $05, $1e, $00, $05, $ff, $f8, $c0, $c0, $f8, $f8, $fe, $fe
	db $1f, $1f, $03, $03, $03, $03, $01, $01, $01, $01, $05, $ff, $f4, $81, $81, $83
	db $83, $c3, $c3, $c3, $c3, $07, $07, $1f, $1f, $7e, $7e, $f0, $f0, $c0, $c0, $80
	db $80, $05, $24, $00, $05, $1e, $00, $03, $03, $05, $64, $0a, $f0, $f0, $78, $78
	db $1c, $1c, $05, $54, $00, $06, $06, $01, $01, $07, $07, $05, $52, $00, $0f, $0f
	db $07, $07, $05, $a4, $00, $05, $60, $06, $c0, $c0, $fc, $fc, $7f, $7f, $fc, $fc
	db $fc, $fc, $05, $66, $08, $ff, $ff, $e0, $e0, $f0, $f0, $7c, $7c, $3f, $3f, $0f
	db $0f, $05, $7e, $00, $05, $62, $04, $80, $80, $05, $60, $02, $05, $32, $06, $05
	db $30, $02, $05, $40, $0a, $00, $00, $05, $54, $08, $0e, $0e, $05, $ff, $f8, $05
	db $60, $02, $01, $01, $05, $78, $00, $0f, $0f, $fe, $fe, $f8, $f8, $c0, $c0, $00
	db $00, $c3, $c3, $83, $83, $81, $81, $05, $ff, $f6, $05, $9a, $00, $05, $b2, $00
	db $7e, $7e, $1f, $1f, $07, $07, $05, $ff, $f6, $03, $03, $05, $60, $02, $05, $54
	db $00, $1c, $1c, $78, $78, $05, $96, $00, $05, $ff, $fa, $05, $50, $00, $00, $00
	db $05, $7c, $16, $05, $0a, $14, $7e, $7e, $05, $c8, $00, $1f, $1f, $05, $58, $10
	db $05, $ff, $f2, $20, $05, $d4, $15, $05, $ff, $f2, $12, $12, $1a, $1a, $16, $16
	db $12, $12, $12, $12, $05, $82, $14, $05, $7c, $00, $05, $7c, $06, $05, $24, $06
	db $05, $ff, $f2, $f0, $f0, $80, $80, $e0, $e0, $80, $80, $f0, $f0, $05, $ff, $f2
	db $1c, $1c, $12, $12, $05, $24, $20, $05, $ec, $14, $01, $01, $02, $02, $03, $03
	db $02, $02, $02, $02, $05, $02, $14, $40, $40, $c0, $c0, $40, $40, $40, $40, $05
	db $ff, $f2, $30, $30, $48, $48, $40, $40, $48, $48, $30, $30, $05, $ff, $f2, $0e
	db $0e, $04, $05, $66, $23, $05, $0a, $04, $05, $f6, $1a, $05, $f8, $18, $05, $d0
	db $16, $c0, $c0, $05, $9a, $14, $3c, $3c, $20, $20, $38, $38, $20, $20, $3c, $3c
	db $05, $a0, $ff, $4d, $05, $0d, $3f, $4d, $05, $6d, $3f, $4d, $05, $cd, $3f, $4d
	db $05, $2d, $4f, $4d, $05, $8d, $4f, $4d, $05, $ed, $4e

Data_56_6A71::
	db $40, $02, $04, $04, $ff, $fc, $01, $01, $0f, $0f, $3f, $3f, $7c, $7c, $f0, $f0
	db $e0, $e0, $e0, $e0, $ff, $04, $1e, $01, $80, $80, $04, $ff, $f4, $ff, $ff, $f8
	db $f8, $f8, $f8, $04, $ff, $f6, $f8, $f8, $1c, $04, $40, $0b, $0f, $0f, $0f, $0f
	db $0e, $04, $54, $07, $04, $1e, $00, $04, $ff, $f8, $c0, $c0, $f8, $f8, $fe, $fe
	db $1f, $1f, $03, $03, $03, $03, $01, $01, $01, $01, $04, $ff, $f4, $81, $81, $83
	db $83, $c3, $c3, $c3, $c3, $07, $07, $1f, $1f, $7e, $7e, $f0, $f0, $c0, $c0, $80
	db $80, $04, $24, $00, $04, $1e, $00, $03, $03, $04, $64, $0a, $f0, $f0, $78, $78
	db $1c, $1c, $04, $54, $00, $06, $06, $01, $01, $07, $07, $04, $52, $00, $0f, $0f
	db $07, $07, $04, $a4, $00, $04, $60, $06, $c0, $c0, $fc, $fc, $7f, $7f, $fc, $fc
	db $fc, $fc, $04, $66, $08, $ff, $ff, $e0, $e0, $f0, $f0, $7c, $7c, $3f, $3f, $0f
	db $0f, $04, $7e, $00, $04, $62, $04, $80, $80, $04, $60, $02, $04, $32, $06, $04
	db $30, $02, $04, $40, $0a, $00, $00, $04, $54, $08, $0e, $0e, $04, $ff, $f8, $04
	db $60, $02, $01, $01, $04, $78, $00, $0f, $0f, $fe, $fe, $f8, $f8, $c0, $c0, $00
	db $00, $c3, $c3, $83, $83, $81, $81, $04, $ff, $f6, $04, $9a, $00, $04, $b2, $00
	db $7e, $7e, $1f, $1f, $07, $07, $04, $ff, $f6, $03, $03, $04, $60, $02, $04, $54
	db $00, $1c, $1c, $78, $78, $04, $96, $00, $04, $ff, $fa, $04, $50, $00, $00, $00
	db $04, $7c, $16, $04, $0a, $14, $7e, $7e, $04, $c8, $00, $1f, $1f, $04, $58, $10
	db $04, $ff, $f2, $20, $04, $d4, $15, $04, $ff, $f2, $12, $12, $1a, $1a, $16, $16
	db $12, $12, $12, $12, $04, $82, $14, $04, $7c, $00, $04, $7c, $06, $04, $24, $06
	db $04, $ff, $f2, $f0, $f0, $80, $80, $e0, $e0, $80, $80, $f0, $f0, $04, $ff, $f2
	db $1c, $1c, $12, $12, $04, $24, $20, $04, $ec, $14, $01, $01, $02, $02, $03, $03
	db $02, $02, $02, $02, $00, $00

Data_56_6BC7::
	db $00, $03, $01, $ff, $01, $ff, $fe, $18, $01, $12, $07, $1f, $ff, $00, $ff, $3c
	db $01, $12, $07, $3c, $ff, $00, $ff, $71, $ff, $d9, $ff, $c1, $01, $36, $01, $d9
	db $ff, $71, $ff, $00, $ff, $f3, $ff, $83, $ff, $83, $01, $42, $05, $00, $ff, $23
	db $ff, $26, $ff, $a7, $ff, $a3, $ff, $61, $ff, $64, $ff, $27, $ff, $00, $ff, $cf
	db $ff, $4c, $ff, $0c, $ff, $8f, $ff, $cc, $ff, $cc, $ff, $8f, $ff, $00, $ff, $9e
	db $ff, $1b, $ff, $1b, $ff, $9b, $01, $74, $01, $9e, $01, $00, $0f, $00, $79, $ff
	db $65, $ff, $64, $ff, $78, $ff, $64, $01, $96, $01, $00, $ff, $08, $ff, $98, $ff
	db $90, $ff, $f0, $ff, $60, $01, $aa, $01, $00, $ff, $03, $01, $b2, $09, $00, $ff
	db $27, $ff, $23, $ff, $a3, $ff, $a3, $ff, $63, $ff, $63, $01, $5e, $01, $99, $ff
	db $19, $ff, $1d, $ff, $1d, $01, $74, $01, $99, $ff, $00, $ff, $3f, $ff, $0c, $01
	db $e4, $07, $00, $ff, $3e, $ff, $30, $ff, $30, $01, $f2, $05, $00, $01, $9a, $01
	db $74, $ff, $74, $ff, $6c, $ff, $6c, $ff, $64, $ff, $00, $ff, $f0, $ff, $d9, $01
	db $14, $15, $f0, $ff, $00, $ff, $e0, $ff, $b0, $01, $24, $15, $e0, $01, $a0, $ff
	db $4d, $01, $8f, $1f, $4d, $01, $ef, $1f, $4d, $01, $4f, $2f, $4d, $01, $af, $2f
	db $3d

Data_56_6CA8::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $01, $02, $05, $00, $ff
	db $f8, $ff, $80, $ff, $80, $01, $12, $05, $00, $ff, $70, $ff, $88, $ff, $80, $ff
	db $bc, $ff, $88, $ff, $98, $ff, $68, $ff, $00, $ff, $44, $ff, $46, $ff, $45, $ff
	db $45, $ff, $44, $01, $3a, $01, $01, $31, $06, $c4, $01, $3c, $05, $01, $3b, $02
	db $01, $4b, $06, $64, $ff, $54, $ff, $54, $ff, $4c, $01, $3c, $03, $38, $ff, $44
	db $ff, $40, $ff, $5e, $ff, $44, $ff, $4c, $ff, $34, $ff, $00, $ff, $18, $ff, $18
	db $ff, $01, $ff, $f0, $01, $83, $01

Data_56_6D0F::
	db $90, $00, $01, $ff, $00, $ff, $88, $01, $02, $03, $50, $ff, $50, $ff, $20, $01
	db $00, $07, $01, $03, $00, $8f, $ff, $00, $ff, $08, $01, $22, $07, $01, $1f, $00
	db $02, $ff, $05, $01, $34, $01, $0f, $ff, $08, $ff, $88, $ff, $00, $ff, $07, $01
	db $22, $01, $0b, $ff, $88, $ff, $89, $ff, $86, $01, $40, $01, $84, $ff, $04, $ff
	db $c7, $ff, $84, $ff, $84, $ff, $87, $ff, $00, $ff, $c7, $ff, $04, $01, $56, $01
	db $05, $ff, $04, $ff, $c4, $ff, $00, $ff, $80, $ff, $40, $ff, $40, $ff, $80, $01
	db $70, $03, $00, $ff, $18, $ff, $18, $ff, $01, $ff, $f0, $01, $83, $01

Data_56_6D7D::
	db $90, $00, $01, $ff, $00, $ff, $f8, $ff, $20, $01, $04, $07, $00, $ff, $20, $ff
	db $50, $01, $14, $01, $f8, $ff, $88, $ff, $88, $ff, $00, $ff, $80, $01, $22, $07
	db $f8, $ff, $00, $ff, $87, $01, $1c, $01, $87, $ff, $80, $01, $36, $01, $00, $ff
	db $08, $ff, $8d, $ff, $0a, $ff, $0a, $01, $1c, $01, $08, $ff, $00, $ff, $82, $ff
	db $85, $01, $54, $01, $8f, $01, $1c, $03, $08, $ff, $0c, $01, $46, $01, $89, $01
	db $1c, $0f, $00, $80, $ff, $00, $ff, $18, $ff, $18, $ff, $01, $ff, $f0, $01, $83
	db $01

Data_56_6DDE::
	db $90, $00, $01, $ff, $00, $ff, $88, $ff, $d8, $ff, $a8, $ff, $a8, $ff, $88, $01
	db $0a, $01, $00, $ff, $f8, $ff, $80, $ff, $80, $01, $12, $05, $01, $01, $0e, $70
	db $01, $0a, $03, $01, $0b, $00, $70, $ff, $00, $ff, $f0, $01, $0a, $01, $f0, $ff
	db $a0, $ff, $90, $01, $0e, $01, $20, $01, $52, $09, $01, $11, $0e, $01, $33, $00
	db $80, $ff, $70, $ff, $08, $01, $3c, $03, $18, $ff, $18, $ff, $01, $ff, $f0, $01
	db $83, $01

Data_56_6E30::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $01, $02, $05, $00, $ff
	db $f8, $ff, $80, $ff, $80, $01, $12, $05, $00, $01, $04, $01, $88, $ff, $a8, $ff
	db $a8, $ff, $d8, $ff, $88, $ff, $00, $ff, $84, $01, $32, $07, $87, $ff, $00, $ff
	db $0f, $ff, $08, $01, $44, $05, $cf, $01, $40, $01, $01, $05, $00, $8f, $01, $04
	db $01, $0f, $ff, $00, $ff, $8f, $01, $44, $01, $8f, $ff, $0a, $ff, $09, $01, $2e
	db $01, $00, $01, $14, $01, $01, $ff, $f0, $01, $73, $00, $00, $ff, $18, $ff, $18
	db $01, $70, $01, $01, $83, $01

Data_56_6E96::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $ff, $f0, $ff, $80, $01
	db $0a, $01, $00, $ff, $f8, $01, $0a, $01, $01, $13, $04, $00, $ff, $20, $ff, $50
	db $01, $24, $01, $f8, $01, $04, $01, $00, $ff, $70, $ff, $88, $01, $0a, $03, $88
	db $ff, $70, $01, $10, $0f, $00, $01, $51, $0f, $1d, $18, $ff, $18, $01, $7e, $06

Data_56_6ED6::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $01, $02, $05, $01, $01
	db $06, $a0, $ff, $90, $ff, $88, $ff, $00, $ff, $20, $ff, $50, $01, $24, $01, $f8
	db $01, $04, $01, $00, $01, $04, $01, $01, $05, $00, $01, $25, $00, $20, $ff, $00
	db $ff, $f8, $ff, $80, $ff, $80, $01, $42, $05, $01, $11, $0e, $01, $37, $02, $20
	db $01, $68, $03, $01, $ff, $f0, $01, $71, $0a, $18, $ff, $18, $01, $7e, $06

Data_56_6F25::
	db $90, $00, $01, $ff, $00, $ff, $70, $ff, $88, $ff, $80, $ff, $70, $ff, $08, $ff
	db $88, $ff, $70, $ff, $00, $ff, $f8, $ff, $20, $01, $14, $07, $00, $ff, $f0, $ff
	db $88, $ff, $88, $ff, $f0, $ff, $a0, $ff, $90, $ff, $88, $01, $10, $01, $80, $ff
	db $80, $01, $32, $05, $00, $ff, $88, $ff, $c8, $ff, $a8, $ff, $a8, $ff, $98, $01
	db $24, $01, $01, $01, $04, $bc, $ff, $88, $ff, $98, $ff, $68, $01, $10, $0f, $00
	db $01, $25, $00, $88, $ff, $f8, $01, $72, $03, $00, $ff, $18, $ff, $18, $ff, $01
	db $ff, $f0, $01, $83, $01

Data_56_6F8A::
	db $90, $00, $01, $ff, $00, $ff, $20, $ff, $50, $01, $04, $01, $f8, $ff, $88, $ff
	db $88, $ff, $00, $ff, $88, $ff, $c8, $ff, $a8, $ff, $a8, $ff, $98, $01, $0c, $03
	db $70, $ff, $88, $ff, $80, $ff, $bc, $ff, $88, $ff, $98, $ff, $68, $ff, $00, $ff
	db $f8, $ff, $80, $ff, $80, $01, $32, $05, $00, $ff, $f0, $01, $0c, $01, $f0, $ff
	db $a0, $ff, $90, $01, $0e, $01, $01, $51, $0f, $1d, $18, $ff, $18, $01, $7e, $06

Data_56_6FDA::
	db $90, $00, $01, $ff, $00, $ff, $08, $01, $02, $03, $88, $ff, $88, $ff, $70, $ff
	db $00, $ff, $70, $01, $0a, $01, $01, $15, $02, $01, $0f, $00, $01, $0b, $00, $50
	db $ff, $20, $01, $28, $03, $01, $ff, $f0, $01, $31, $0f, $3b, $18, $ff, $18, $01
	db $7e, $06

Data_56_700C::
	db $90, $00, $01, $ff, $00, $ff, $88, $01, $02, $01, $a8, $ff, $a8, $ff, $d8, $ff
	db $88, $ff, $00, $ff, $20, $01, $12, $09, $00, $ff, $70, $ff, $88, $ff, $80, $ff
	db $70, $ff, $08, $ff, $88, $ff, $70, $ff, $00, $ff, $e0, $ff, $90, $01, $02, $03
	db $90, $ff, $e0, $01, $20, $03, $01, $45, $04, $01, $2f, $00, $88, $ff, $d8, $01
	db $08, $01, $01, $03, $02, $01, $ff, $f0, $01, $61, $0f, $0b, $18, $ff, $18, $01
	db $7e, $06

Data_56_705E::
	db $90, $00, $01, $ff, $00, $ff, $88, $01, $02, $01, $f8, $01, $02, $03, $00, $ff
	db $20, $ff, $50, $01, $14, $01, $01, $09, $02, $00, $ff, $f0, $01, $02, $01, $f0
	db $ff, $80, $01, $2a, $01, $01, $21, $0e, $88, $ff, $8c, $ff, $8a, $ff, $8a, $ff
	db $89, $01, $0c, $03, $8f, $01, $02, $01, $01, $53, $04, $00, $ff, $87, $ff, $08
	db $ff, $08, $ff, $87, $ff, $00, $01, $66, $03, $0e, $ff, $91, $ff, $10, $ff, $0e
	db $ff, $81, $ff, $91, $ff, $0e, $ff, $00, $ff, $18, $ff, $18, $ff, $01, $ff, $f0
	db $01, $83, $01

Data_56_70C1::
	db $90, $00, $01, $ff, $00, $ff, $fb, $ff, $22, $ff, $22, $ff, $23, $01, $04, $03
	db $00, $ff, $e4, $ff, $06, $ff, $05, $ff, $e5, $ff, $04, $ff, $04, $ff, $e4, $ff
	db $00, $ff, $4f, $ff, $c8, $ff, $48, $ff, $4f, $ff, $48, $01, $2a, $01, $00, $ff
	db $1f, $ff, $84, $ff, $84, $01, $1a, $01, $01, $1b, $00, $00, $ff, $08, $ff, $14
	db $01, $44, $01, $3e, $01, $04, $01, $00, $ff, $7c, $ff, $10, $01, $54, $07, $00
	db $ff, $47, $01, $2a, $03, $01, $2b, $00, $47, $ff, $00, $ff, $11, $ff, $99, $ff
	db $95, $ff, $95, $ff, $93, $ff, $91, $ff, $11, $ff, $00, $ff, $18, $ff, $18, $ff
	db $01, $ff, $f0, $01, $83, $01

Data_56_7137::
	db $90, $00, $01, $ff, $00, $ff, $80, $01, $02, $03, $81, $ff, $81, $ff, $f9, $ff
	db $00, $ff, $41, $ff, $a1, $01, $14, $01, $f1, $ff, $11, $ff, $11, $ff, $00, $ff
	db $e1, $ff, $11, $ff, $10, $ff, $e0, $ff, $10, $01, $26, $01, $00, $ff, $13, $ff
	db $12, $ff, $a2, $ff, $43, $ff, $42, $01, $3a, $01, $00, $ff, $c1, $ff, $21, $ff
	db $21, $ff, $c1, $ff, $81, $ff, $41, $ff, $21, $ff, $00, $ff, $08, $ff, $0c, $ff
	db $0a, $ff, $0a, $ff, $09, $ff, $08, $ff, $08, $ff, $00, $ff, $8f, $ff, $82, $01
	db $64, $07, $00, $ff, $91, $01, $1c, $01, $1f, $01, $1c, $01, $01, $1f, $00, $18
	db $ff, $18, $ff, $01, $ff, $f0, $01, $83, $01

Data_56_71B0::
	db $90, $00, $01, $ff, $00, $ff, $09, $01, $02, $03, $89, $ff, $89, $ff, $70, $ff
	db $00, $ff, $13, $ff, $12, $01, $14, $05, $e3, $ff, $00, $ff, $83, $ff, $44, $ff
	db $24, $ff, $25, $ff, $24, $ff, $44, $ff, $83, $ff, $00, $ff, $88, $ff, $4d, $ff
	db $0a, $ff, $ea, $ff, $48, $ff, $c8, $ff, $48, $ff, $00, $ff, $9f, $ff, $90, $ff
	db $90, $01, $42, $05, $00, $ff, $22, $ff, $32, $ff, $2a, $ff, $2a, $ff, $26, $ff
	db $22, $ff, $22, $ff, $00, $ff, $7c, $ff, $10, $01, $64, $07, $01, $ff, $f0, $01
	db $71, $0a, $18, $ff, $18, $01, $7e, $06

Data_56_7218::
	db $90, $00, $01, $ff, $00, $ff, $f1, $ff, $89, $ff, $89, $ff, $f1, $ff, $a1, $ff
	db $91, $ff, $89, $ff, $00, $ff, $f3, $ff, $02, $ff, $02, $01, $12, $03, $f2, $ff
	db $00, $ff, $e4, $ff, $04, $ff, $04, $ff, $c4, $01, $24, $01, $07, $ff, $00, $ff
	db $0f, $ff, $08, $ff, $08, $01, $32, $03, $cf, $ff, $00, $ff, $8e, $ff, $11, $ff
	db $10, $ff, $90, $ff, $11, $ff, $11, $ff, $8e, $ff, $00, $ff, $3e, $01, $34, $01
	db $01, $55, $04, $00, $ff, $47, $ff, $48, $01, $64, $05, $47, $ff, $00, $ff, $11
	db $ff, $99, $ff, $95, $ff, $95, $ff, $93, $ff, $91, $ff, $11, $ff, $00, $ff, $18
	db $ff, $18, $ff, $01, $ff, $f0, $01, $83, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
