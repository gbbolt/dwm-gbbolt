INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $057", ROMX[$4000], BANK[$57]

BankNumber_57::
	db $57

FarTable_57::
	dw Call_57_6E0E
	dw Call_57_7C44
	dw Call_57_4013
	dw Call_57_408A
	dw Call_57_4136
	dw Call_57_4192
	dw Call_57_41EE
	dw Call_57_424A
	dw Call_57_42A6

Call_57_4013::
	ld a, [wSkillUser]
	ld b, a
	ld a, [wSkillTarget]
	ld c, a
	push bc
	ld a, [wSkillUser]
	and $04
	xor $04
	ld d, a
	ld [wBattleArg1], a
	ld bc, $0400

jr_057_402a:
	ld a, d
	call CheckBattlerPresent
	jr c, jr_057_4031

	inc c

jr_057_4031:
	inc d
	dec b
	jr nz, jr_057_402a

	ld a, c
	add a
	ld d, a
	add a
	add a
	add d
	ld [wBattleArg2], a
	ld a, [wBattleArg0]
	ld [wSkillUser], a
	ld b, $04

jr_057_4046:
	push bc
	ld a, [wBattleArg1]
	ld [wSkillTarget], a
	ld hl, far_CalcAttackDamage
	rst $10
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [wBattleArg2]
	call Multiply24
	push hl
	ld a, [wBattleArg0]
	call GetBattlerHP
	pop bc
	call CompareHLBC
	pop bc
	jr nc, jr_057_407b

	ld hl, wBattleArg1
	inc [hl]
	dec b
	jr nz, jr_057_4046

	ld a, $00
	ld [wBattleArg2], a
	jr jr_057_4080

jr_057_407b:
	ld a, $01
	ld [wBattleArg2], a

jr_057_4080:
	pop bc
	ld a, b
	ld [wSkillUser], a
	ld a, c
	ld [wSkillTarget], a
	ret


Call_57_408A::
	ld a, [wSkillUser]
	ld b, a
	ld a, [wSkillTarget]
	ld c, a
	push bc
	ld a, [wBattleArg0]
	and $03
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wBattleArg3], a
	ld a, h
	ld [wNamePos], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hl], a
	ld a, [wBattleArg0]
	ld [wSkillTarget], a
	ld a, [wBattleArg0]
	and $04
	xor $04
	ld [wSkillUser], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $04
	ld [wBattleArg2], a

jr_057_40ca:
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr c, jr_057_40fb

	ld hl, wBattleArg1
	inc [hl]
	ld hl, far_CalcAttackDamage
	rst $10
	ld a, [wBattleArg3]
	ld l, a
	ld a, [wNamePos]
	ld h, a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc
	ld a, [wBattleArg3]
	ld c, a
	ld a, [wNamePos]
	ld b, a
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a

jr_057_40fb:
	ld hl, wSkillUser
	inc [hl]
	ld a, [wBattleArg2]
	dec a
	ld [wBattleArg2], a
	jr nz, jr_057_40ca

	ld a, [wBattleArg0]
	call GetBattlerMaxHP
	push hl
	ld a, [wBattleArg3]
	ld l, a
	ld a, [wNamePos]
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	call DivideHLBC
	push hl
	ld a, [wBattleArg3]
	ld l, a
	ld a, [wNamePos]
	ld h, a
	pop bc
	ld a, c
	ld [hli], a
	ld a, b
	ld [hl], a
	pop bc
	ld a, b
	ld [wSkillUser], a
	ld a, c
	ld [wSkillTarget], a
	ret


Call_57_4136::
	ld a, [wBattleTemp]
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_416a

	ld a, b
	cp $03
	jr c, jr_057_416a

	and $03
	cp $03
	jr z, jr_057_417a

	ld a, b
	sub $04
	ld hl, wEncSpecies
	call Call_57_4567

jr_057_4154:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateHP]
	ld c, a
	ld a, [$da1e]
	ld b, a
	jr jr_057_4189

jr_057_416a:
	ld a, b
	and $03
	cp $03
	jr z, jr_057_417a

	ld a, b
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	jr jr_057_4189

jr_057_417a:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_057_4154

jr_057_4189:
	ld a, c
	ld [wBattleTemp], a
	ld a, b
	ld [wBattleTempHigh], a
	ret


Call_57_4192::
	ld a, [wBattleTemp]
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_41c6

	ld a, b
	cp $03
	jr c, jr_057_41c6

	and $03
	cp $03
	jr z, jr_057_41d6

	ld a, b
	sub $04
	ld hl, wEncSpecies
	call Call_57_4567

jr_057_41b0:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateMP]
	ld c, a
	ld a, [$da20]
	ld b, a
	jr jr_057_41e5

jr_057_41c6:
	ld a, b
	and $03
	cp $03
	jr z, jr_057_41d6

	ld a, b
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	jr jr_057_41e5

jr_057_41d6:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_057_41b0

jr_057_41e5:
	ld a, c
	ld [wBattleTemp], a
	ld a, b
	ld [wBattleTempHigh], a
	ret


Call_57_41EE::
	ld a, [wBattleTemp]
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_4222

	ld a, b
	cp $03
	jr c, jr_057_4222

	and $03
	cp $03
	jr z, jr_057_4232

	ld a, b
	sub $04
	ld hl, wEncSpecies
	call Call_57_4567

jr_057_420c:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateAttack]
	ld c, a
	ld a, [$da22]
	ld b, a
	jr jr_057_4241

jr_057_4222:
	ld a, b
	and $03
	cp $03
	jr z, jr_057_4232

	ld a, b
	ld hl, wMonAttack
	call GetPartyMonsterWord
	jr jr_057_4241

jr_057_4232:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_057_420c

jr_057_4241:
	ld a, c
	ld [wBattleTemp], a
	ld a, b
	ld [wBattleTempHigh], a
	ret


Call_57_424A::
	ld a, [wBattleTemp]
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_427e

	ld a, b
	cp $03
	jr c, jr_057_427e

	and $03
	cp $03
	jr z, jr_057_428e

	ld a, b
	sub $04
	ld hl, wEncSpecies
	call Call_57_4567

jr_057_4268:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateDefense]
	ld c, a
	ld a, [$da24]
	ld b, a
	jr jr_057_429d

jr_057_427e:
	ld a, b
	and $03
	cp $03
	jr z, jr_057_428e

	ld a, b
	ld hl, wMonDefense
	call GetPartyMonsterWord
	jr jr_057_429d

jr_057_428e:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_057_4268

jr_057_429d:
	ld a, c
	ld [wBattleTemp], a
	ld a, b
	ld [wBattleTempHigh], a
	ret


Call_57_42A6::
	ld a, [wBattleTemp]
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_42da

	ld a, b
	cp $03
	jr c, jr_057_42da

	and $03
	cp $03
	jr z, jr_057_42ea

	ld a, b
	sub $04
	ld hl, wEncSpecies
	call Call_57_4567

jr_057_42c4:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateAgility]
	ld c, a
	ld a, [$da26]
	ld b, a
	jr jr_057_42f9

jr_057_42da:
	ld a, b
	and $03
	cp $03
	jr z, jr_057_42ea

	ld a, b
	ld hl, wMonAgility
	call GetPartyMonsterWord
	jr jr_057_42f9

jr_057_42ea:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_057_42c4

jr_057_42f9:
	ld a, c
	ld [wBattleTemp], a
	ld a, b
	ld [wBattleTempHigh], a
	ret


	db $08, $43, $58, $43, $04, $44, $84, $67, $f2, $45, $02, $47, $25, $47, $45, $47
	db $85, $47, $f6, $4a, $3d, $4b, $13, $4c, $4d, $5d, $e5, $5e, $1f, $5f, $91, $5f
	db $67, $62, $44, $64, $fb, $64, $48, $68, $0d, $6a, $67, $6a, $62, $6c, $8e, $5d
	db $8c, $4b, $96, $65, $19, $66, $cc, $4b, $41, $4c, $56, $4d, $f9, $4d, $18, $4e
	db $36, $4e, $76, $4e, $54, $54, $ae, $5b, $fd, $5f, $80, $61, $fb, $66, $10, $68
	db $89, $6b, $8c, $6c, $00, $00, $84, $67, $f2, $45, $85, $46, $02, $47, $25, $47
	db $45, $47, $85, $47, $d9, $47, $f5, $47, $21, $48, $43, $48, $65, $48, $90, $48
	db $02, $49, $94, $4a, $cc, $4a, $f6, $4a, $3d, $4b, $13, $4c, $93, $54, $34, $5b
	db $4a, $5b, $cd, $5b, $f5, $5b, $25, $5c, $5d, $5c, $c8, $5c, $4d, $5d, $e0, $5d
	db $fa, $5d, $10, $5e, $3e, $5e, $7e, $5e, $a4, $5e, $bb, $5e, $e5, $5e, $1f, $5f
	db $91, $5f, $67, $62, $a8, $62, $82, $63, $b0, $63, $e3, $63, $14, $64, $44, $64
	db $74, $64, $9d, $64, $cc, $64, $7b, $66, $57, $67, $5e, $69, $75, $69, $0d, $6a
	db $b4, $6a, $f5, $6a, $cb, $6b, $0f, $6c, $c4, $55, $d6, $55, $62, $6c, $c0, $6c
	db $96, $65, $19, $66, $cb, $69, $cc, $4b, $be, $54, $e4, $54, $1b, $55, $f6, $55
	db $60, $56, $39, $57, $fc, $57, $42, $58, $3d, $59, $f7, $59, $fd, $5f, $4a, $60
	db $8e, $60, $c8, $60, $07, $61, $44, $61, $80, $61, $bc, $61, $f1, $61, $2c, $62
	db $00, $00, $84, $67, $f2, $45, $69, $49, $83, $49, $9d, $49, $b7, $49, $5c, $4a
	db $94, $4a, $25, $5c, $16, $5d, $4d, $5d, $1f, $5f, $91, $5f, $fb, $64, $7b, $66
	db $d4, $66, $b1, $67, $85, $47, $b9, $4e, $e4, $4e, $2e, $4f, $61, $4f, $94, $4f
	db $b3, $4f, $d2, $4f, $2c, $50, $bc, $50, $13, $51, $49, $51, $da, $51, $dc, $52
	db $6a, $53, $b6, $53, $dd, $53, $11, $54, $34, $54, $f6, $55, $4c, $5a, $ef, $5a
	db $d5, $67, $00, $00, $79, $cd, $a5, $2f, $38, $03, $7e, $a3, $c8, $0c, $3e, $08
	db $85, $6f, $3e, $00, $8c, $67, $05, $20, $eb, $3e, $ff, $ea, $27, $dd, $c9, $79
	db $cd, $a5, $2f, $38, $12, $2a, $5e, $57, $1b, $7a, $b3, $c0, $23, $0c, $05, $20
	db $ee, $3e, $ff, $ea, $27, $dd, $c9, $23, $18, $f2, $79, $cd, $a5, $2f, $38, $03
	db $7e, $a3, $c0, $0c, $3e, $08, $85, $6f, $3e, $00, $8c, $67, $05, $20, $eb, $3e
	db $ff, $ea, $27, $dd, $c9, $79, $cd, $a5, $2f, $38, $1d, $79, $21, $3c, $dc, $85
	db $6f, $3e, $00, $8c, $67, $7e, $ea, $31, $da, $c5, $21, $01, $03, $d7, $c1, $fa
	db $33, $da, $21, $4c, $db, $be, $28, $05, $0c, $05, $20, $fc, $c9, $21, $26, $dd
	db $06, $14, $cd, $5f, $45, $c9, $79, $cd, $a5, $2f, $38, $04, $7e, $a2, $20, $0d
	db $0c, $3e, $08, $85, $6f, $3e, $00, $8c, $67, $05, $20, $ea, $c9, $21, $26, $dd
	db $43, $cd, $5f, $45, $c9, $af, $ea, $56, $db, $af, $ea, $57, $db, $af, $ea, $4c
	db $db, $79, $cd, $a5, $2f, $38, $22, $fa, $4c, $db, $3c, $ea, $4c, $db, $e5, $2a
	db $66, $6f, $fa, $56, $db, $5f, $fa, $57, $db, $57, $7b, $85, $5f, $7a, $8c, $57
	db $7b, $ea, $56, $db, $7a, $ea, $57, $db, $e1, $23, $23, $0c, $05, $20, $d2, $c9
	db $fa, $8a, $db, $ea, $4c, $db, $3e, $00, $ea, $4d, $db, $3e, $05, $ea, $4e, $db
	db $21, $00, $54, $d7, $fa, $4c, $db, $e6, $03, $5f, $fa, $4c, $db, $0f, $0f, $e6
	db $0f, $57, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $c9, $7e, $80, $77
	db $d0, $3e, $ff, $77, $c9

Call_57_4567::
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


	db $79, $21, $08, $db, $cd, $6c, $2f, $7e, $e6, $08, $c9, $e5, $47, $fa, $6c, $c8
	db $b7, $20, $2d, $78, $fe, $03, $38, $2e, $e6, $03, $fe, $03, $28, $30, $78, $d6
	db $04, $21, $03, $da, $cd, $ea, $45, $2a, $66, $6f, $7d, $ea, $12, $da, $7c, $ea
	db $13, $da, $21, $01, $14, $d7, $fa, $25, $da, $4f, $fa, $26, $da, $47, $18, $1d
	db $e6, $03, $fe, $03, $28, $08, $21, $1d, $cb, $cd, $4f, $22, $18, $0f, $78, $21
	db $3c, $dc, $85, $6f, $3e, $00, $8c, $67, $6e, $26, $01, $18, $cd, $e1, $c9, $7c
	db $b7, $20, $0a, $7d, $b7, $28, $04, $fe, $01, $20, $02, $37, $c9, $3e, $02, $fe
	db $01, $c9, $3e, $ff, $ea, $27, $dd, $c9

Call_57_45EA::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


	db $fa, $8a, $db, $ea, $4c, $db, $3e, $00, $ea, $4d, $db, $3e, $04, $ea, $4e, $db
	db $21, $00, $54, $d7, $fa, $4c, $db, $b7, $28, $11, $4f, $06, $00, $fa, $88, $db
	db $cd, $ef, $2f, $cd, $45, $2f, $30, $03, $cd, $e4, $45, $fa, $6b, $dd, $cb, $77
	db $28, $10, $fa, $88, $db, $21, $03, $db, $cd, $6c, $2f, $cb, $46, $28, $03, $cd
	db $e4, $45, $fa, $6b, $dd, $cb, $6f, $28, $10, $fa, $88, $db, $21, $03, $db, $cd
	db $6c, $2f, $cb, $76, $28, $03, $cd, $e4, $45, $fa, $6b, $dd, $cb, $67, $28, $10
	db $fa, $88, $db, $21, $03, $db, $cd, $6c, $2f, $cb, $7e, $28, $03, $cd, $e4, $45
	db $fa, $8a, $db, $fe, $83, $28, $06, $fa, $6b, $dd, $cb, $77, $c8, $fa, $88, $db
	db $fe, $04, $38, $05, $21, $01, $db, $18, $03, $21, $00, $db, $cb, $5e, $c8, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $41, $20, $11, $fa, $88, $db, $21, $06, $db
	db $cd, $6c, $2f, $7e, $e6, $03, $28, $03, $cd, $e4, $45, $fa, $8a, $db, $fe, $54
	db $20, $11, $fa, $88, $db, $21, $06, $db, $cd, $6c, $2f, $7e, $e6, $c0, $28, $03
	db $cd, $e4, $45, $fa, $8a, $db, $fe, $8f, $20, $10, $fa, $88, $db, $21, $08, $db
	db $cd, $6c, $2f, $cb, $4e, $28, $03, $cd, $e4, $45, $fa, $8a, $db, $fe, $27, $28
	db $04, $fe, $28, $20, $11, $fa, $88, $db, $21, $04, $db, $cd, $6c, $2f, $7e, $e6
	db $22, $28, $03, $cd, $e4, $45, $fa, $8a, $db, $fe, $24, $c0, $fa, $88, $db, $e6
	db $04, $4f, $06, $03, $21, $04, $db, $cd, $6c, $2f, $1e, $04, $cd, $56, $44, $c9
	db $fa, $8a, $db, $fe, $6e, $d0, $fe, $67, $28, $03, $fe, $6c, $d8, $fa, $88, $db
	db $e6, $04, $ee, $04, $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $1e, $02, $cd
	db $56, $44, $c9, $fa, $8a, $db, $fe, $67, $28, $03, $fe, $6c, $c0, $fa, $88, $db
	db $e6, $04, $ee, $04, $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $1e, $03, $cd
	db $56, $44, $c9, $fa, $8a, $db, $fe, $15, $d8, $fe, $17, $38, $20, $fe, $2a, $28
	db $1c, $fe, $68, $28, $18, $fe, $6a, $28, $14, $fe, $70, $d8, $fe, $71, $c8, $fe
	db $74, $38, $0a, $fe, $78, $d8, $fe, $7e, $38, $03, $fe, $dc, $c0, $fa, $88, $db
	db $e6, $04, $ee, $04, $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $1e, $8c, $cd
	db $56, $44, $c9, $fa, $8a, $db, $fe, $15, $d8, $fe, $1a, $38, $34, $fe, $1c, $d8
	db $fe, $29, $c8, $fe, $2b, $38, $2a, $fe, $68, $d8, $fe, $6c, $38, $23, $fe, $6e
	db $28, $1f, $fe, $70, $d8, $fe, $71, $c8, $fe, $74, $38, $15, $fe, $77, $d8, $fe
	db $81, $38, $0e, $fe, $88, $d8, $fe, $93, $38, $07, $fe, $da, $38, $03, $fe, $dc
	db $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $21, $02, $db, $cd, $6c
	db $2f, $1e, $40, $cd, $56, $44, $c9, $fa, $8a, $db, $fe, $18, $c0, $fa, $88, $db
	db $e6, $04, $ee, $04, $4f, $06, $03, $21, $03, $db, $cd, $6c, $2f, $1e, $02, $cd
	db $56, $44, $c9, $fa, $8a, $db, $fe, $19, $28, $0f, $fe, $2a, $28, $0b, $fe, $6e
	db $28, $07, $fe, $da, $28, $03, $fe, $dc, $c0, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $1e, $10, $cd, $56, $44, $c9, $fa
	db $8a, $db, $fe, $1c, $28, $03, $fe, $1d, $c0, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $21, $f3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $cd, $71, $44
	db $c9, $fa, $8a, $db, $fe, $20, $28, $03, $fe, $21, $c0, $fa, $88, $db, $e6, $04
	db $ee, $04, $4f, $06, $03, $21, $03, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $cd
	db $71, $44, $c9, $fa, $8a, $db, $fe, $2a, $28, $0e, $fe, $70, $28, $0a, $fe, $78
	db $d8, $fe, $7e, $38, $03, $fe, $dc, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f
	db $06, $03, $21, $05, $db, $cd, $6c, $2f, $1e, $3f, $cd, $56, $44, $c9, $fa, $8a
	db $db, $fe, $1e, $28, $03, $fe, $1f, $c0, $fa, $88, $db, $e6, $04, $ea, $4c, $db
	db $06, $03, $c5, $fa, $4c, $db, $cd, $a5, $2f, $38, $49, $fa, $4c, $db, $e5, $ea
	db $72, $dd, $21, $07, $57, $d7, $fa, $72, $dd, $4f, $fa, $73, $dd, $47, $e1, $fa
	db $4c, $db, $cd, $d3, $2f, $fa, $6c, $c8, $b7, $28, $0b, $fa, $4c, $db, $e6, $03
	db $fe, $03, $28, $0d, $18, $07, $fa, $4c, $db, $fe, $03, $30, $04, $cb, $21, $cb
	db $10, $cb, $21, $cb, $10, $cd, $45, $2f, $30, $0a, $01, $e7, $03, $cd, $45, $2f
	db $30, $02, $c1, $c9, $21, $4c, $db, $34, $c1, $05, $20, $a6, $cd, $e4, $45, $c9
	db $fa, $8a, $db, $fe, $22, $28, $03, $fe, $23, $c0, $fa, $88, $db, $e6, $04, $ea
	db $4c, $db, $06, $03, $c5, $fa, $4c, $db, $cd, $a5, $2f, $38, $3e, $fa, $4c, $db
	db $cd, $7d, $45, $fa, $4c, $db, $21, $03, $dc, $cd, $67, $45, $fa, $6c, $c8, $b7
	db $28, $0b, $fa, $4c, $db, $e6, $03, $fe, $03, $28, $0d, $18, $07, $fa, $4c, $db
	db $fe, $03, $30, $04, $cb, $21, $cb, $10, $cb, $21, $cb, $10, $cd, $45, $2f, $30
	db $0a, $01, $ff, $01, $cd, $45, $2f, $30, $02, $c1, $c9, $21, $4c, $db, $34, $c1
	db $05, $20, $b1, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $34, $c0, $fa, $88, $db
	db $e6, $04, $4f, $21, $02, $db, $cd, $6c, $2f, $06, $03, $1e, $c0, $cd, $8c, $44
	db $c9, $fa, $8a, $db, $fe, $35, $c0, $fa, $88, $db, $e6, $04, $4f, $21, $02, $db
	db $cd, $6c, $2f, $06, $03, $1e, $10, $cd, $8c, $44, $c9, $fa, $8a, $db, $fe, $36
	db $c0, $fa, $88, $db, $e6, $04, $4f, $21, $02, $db, $cd, $6c, $2f, $06, $03, $1e
	db $20, $cd, $8c, $44, $c9, $fa, $8a, $db, $fe, $2b, $d8, $fe, $93, $28, $6a, $fe
	db $94, $28, $03, $fe, $30, $d0, $06, $03, $fa, $88, $db, $e6, $04, $4f, $21, $a3
	db $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea, $57, $db
	db $79, $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db, $7c
	db $ea, $59, $db, $79, $cd, $a5, $2f, $38, $04, $cd, $c4, $7a, $d0, $fa, $56, $db
	db $6f, $fa, $57, $db, $67, $23, $23, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa
	db $58, $db, $6f, $fa, $59, $db, $67, $23, $23, $7d, $ea, $58, $db, $7c, $ea, $59
	db $db, $0c, $05, $20, $ce, $cd, $e4, $45, $c9, $fa, $88, $db, $4f, $21, $a3, $db
	db $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $79
	db $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db, $7c, $ea
	db $59, $db, $79, $cd, $c4, $7a, $38, $cd, $c9, $c9, $fa, $8a, $db, $fe, $14, $28
	db $07, $fe, $32, $28, $03, $fe, $96, $c0, $fa, $88, $db, $57, $e6, $04, $4f, $06
	db $03, $1e, $00, $79, $ba, $28, $10, $cd, $a5, $2f, $38, $0b, $1c, $79, $21, $02
	db $db, $cd, $6c, $2f, $cb, $76, $c8, $0c, $05, $20, $e8, $7b, $b7, $c8, $cd, $e4
	db $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $24, $28, $0f, $fe, $8a, $28
	db $0b, $fe, $8b, $28, $07, $fe, $8f, $28, $03, $fe, $92, $c0, $fa, $88, $db, $e6
	db $04, $ee, $04, $4f, $06, $03, $16, $10, $79, $cd, $a5, $2f, $38, $04, $cd, $7d
	db $7b, $c8, $0c, $05, $20, $f2, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $43, $c0
	db $fa, $88, $db, $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $06, $08
	db $2a, $fe, $ff, $28, $0b, $fe, $5c, $38, $03, $fe, $64, $d8, $23, $05, $20, $f0
	db $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $03, $d8, $fe, $12, $c8, $fe, $15, $c8
	db $fe, $1d, $28, $0b, $fe, $21, $28, $07, $fe, $da, $28, $03, $fe, $1a, $d0, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $21, $04, $db, $cd, $6c, $2f, $79
	db $cd, $a5, $2f, $38, $05, $7e, $e6, $22, $20, $0d, $0c, $3e, $08, $85, $6f, $3e
	db $00, $8c, $67, $05, $20, $e9, $c9, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $5c
	db $d8, $fe, $64, $38, $06, $fe, $6e, $d0, $fe, $6a, $d8, $fa, $88, $db, $e6, $04
	db $ee, $04, $4f, $06, $03, $79, $cb, $3f, $cb, $3f, $21, $00, $db, $85, $6f, $3e
	db $00, $8c, $67, $7e, $e6, $60, $20, $1e, $79, $cd, $a5, $2f, $38, $13, $79, $21
	db $04, $db, $cd, $6c, $2f, $2a, $23, $23, $23, $e6, $48, $20, $09, $cb, $4e, $20
	db $05, $0c, $05, $20, $e3, $c9, $cd, $e4, $45, $c9, $cd, $6e, $7c, $c0, $fa, $6b
	db $dd, $cb, $7f, $c8, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $21, $08
	db $db, $cd, $6c, $2f, $79, $cd, $a5, $2f, $38, $0a, $cb, $6e, $20, $13, $23, $7e
	db $e6, $05, $20, $0d, $0c, $3e, $07, $85, $6f, $3e, $00, $8c, $67, $05, $20, $e4
	db $c9, $21, $27, $dd, $06, $14, $cd, $5f, $45, $c9, $cd, $32, $45, $fa, $4c, $db
	db $b7, $c8, $af, $21, $54, $db, $22, $77, $79, $cd, $a5, $2f, $38, $1e, $21, $55
	db $db, $34, $79, $ea, $89, $db, $7a, $ea, $4c, $db, $d5, $c5, $21, $06, $52, $d7
	db $c1, $d1, $cd, $a6, $7a, $e6, $03, $21, $54, $db, $86, $77, $0c, $05, $20, $d8
	db $fa, $55, $db, $21, $54, $db, $be, $d8, $21, $26, $dd, $06, $14, $cd, $5f, $45
	db $c9, $cd, $32, $45, $79, $cd, $a5, $2f, $38, $18, $79, $ea, $89, $db, $7a, $ea
	db $4c, $db, $d5, $c5, $21, $06, $52, $d7, $c1, $d1, $cd, $a6, $7a, $e6, $03, $fe
	db $03, $c0, $0c, $05, $20, $de, $21, $54, $db, $86, $77, $cd, $e4, $45, $c9, $fa
	db $8a, $db, $fe, $3f, $d8, $fe, $41, $da, $29, $4d, $fe, $48, $d8, $fe, $50, $38
	db $0f, $fe, $d6, $d8, $fe, $d9, $d0, $fa, $8a, $db, $d6, $d6, $c6, $08, $18, $05
	db $fa, $8a, $db, $d6, $48, $c7, $29, $4d, $91, $4c, $a4, $4c, $b7, $4c, $f0, $4c
	db $03, $4d, $16, $4d, $03, $4d, $7e, $4c, $ca, $4c, $dd, $4c, $fa, $88, $db, $e6
	db $04, $ee, $04, $4f, $06, $03, $3e, $00, $ea, $4c, $db, $cd, $a7, $44, $c9, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $01, $ea, $4c, $db, $cd, $a7
	db $44, $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $02, $ea, $4c
	db $db, $cd, $a7, $44, $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e
	db $03, $ea, $4c, $db, $cd, $a7, $44, $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f
	db $06, $03, $3e, $05, $ea, $4c, $db, $cd, $a7, $44, $c9, $fa, $88, $db, $e6, $04
	db $ee, $04, $4f, $06, $03, $3e, $04, $ea, $4c, $db, $cd, $a7, $44, $c9, $fa, $88
	db $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $06, $ea, $4c, $db, $cd, $a7, $44
	db $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $07, $ea, $4c, $db
	db $cd, $a7, $44, $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $08
	db $ea, $4c, $db, $cd, $a7, $44, $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06
	db $03, $79, $cd, $a5, $2f, $38, $0e, $79, $21, $8b, $db, $85, $6f, $3e, $00, $8c
	db $67, $cb, $46, $20, $05, $0c, $05, $20, $e8, $c9, $21, $26, $dd, $06, $14, $cd
	db $5f, $45, $c9, $c9, $cd, $7e, $7c, $d0, $cd, $be, $7d, $fa, $88, $db, $cd, $cc
	db $2f, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f, $38, $08, $21, $26
	db $dd, $06, $0a, $cd, $5f, $45, $3e, $ff, $21, $56, $db, $22, $77, $fa, $88, $db
	db $e6, $04, $ee, $04, $4f, $79, $cd, $a5, $2f, $38, $0c, $79, $cd, $d3, $2f, $7d
	db $ea, $56, $db, $7c, $ea, $57, $db, $0c, $79, $cd, $a5, $2f, $38, $1b, $79, $cd
	db $d3, $2f, $c5, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f, $c1, $30
	db $08, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $0c, $79, $cd, $a5, $2f, $38, $1b
	db $79, $cd, $d3, $2f, $c5, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f
	db $c1, $30, $08, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa, $88, $db, $cd, $cc
	db $2f, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f, $d8, $21, $26, $dd
	db $06, $05, $cd, $5f, $45, $c9, $c9, $cd, $b5, $7c, $d0, $cd, $ff, $7c, $38, $08
	db $21, $26, $dd, $06, $05, $cd, $5f, $45, $cd, $37, $7d, $d0, $21, $26, $dd, $06
	db $05, $cd, $5f, $45, $c9, $c9, $cd, $e0, $7c, $d0, $cd, $1d, $7d, $30, $08, $21
	db $26, $dd, $06, $0a, $cd, $5f, $45, $cd, $37, $7d, $d8, $21, $26, $dd, $06, $0a
	db $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $03, $d8, $fe, $12, $28, $11, $fe, $14
	db $38, $0d, $fe, $4f, $28, $09, $fe, $57, $d8, $fe, $58, $c8, $fe, $67, $d0, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $1e, $00, $d5, $79, $cd, $a5, $2f
	db $d1, $38, $01, $1c, $05, $20, $f4, $7b, $fe, $02, $d8, $21, $26, $dd, $06, $14
	db $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $3f, $28, $03, $fe, $40, $c0, $fa, $88
	db $db, $e6, $04, $ee, $04, $5f, $16, $03, $cd, $cc, $2f, $29, $4d, $44, $7b, $cd
	db $a5, $2f, $38, $15, $7b, $21, $f3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $2a
	db $66, $6f, $cd, $45, $2f, $38, $02, $30, $05, $1c, $15, $20, $e1, $c9, $21, $26
	db $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $95, $28, $06, $fe, $30
	db $d8, $fe, $32, $d0, $fa, $88, $db, $e6, $04, $4f, $06, $03, $79, $cd, $a5, $2f
	db $28, $02, $38, $05, $0c, $05, $20, $f4, $c9, $21, $26, $dd, $06, $2d, $cd, $5f
	db $45, $c9, $fa, $8a, $db, $fe, $32, $28, $03, $fe, $96, $c0, $fa, $88, $db, $57
	db $e6, $04, $4f, $28, $05, $fa, $75, $db, $18, $03, $fa, $74, $db, $fe, $01, $c8
	db $47, $79, $ba, $28, $04, $cd, $a5, $2f, $d0, $0c, $05, $20, $f4, $7a, $cd, $e8
	db $2f, $e5, $7a, $21, $b3, $db, $cd, $67, $45, $3e, $05, $cd, $0d, $1e, $c1, $cd
	db $45, $2f, $d8, $21, $26, $dd, $06, $64, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe
	db $33, $28, $03, $fe, $81, $c0, $fa, $88, $db, $e6, $04, $4f, $06, $03, $21, $02
	db $db, $cd, $6c, $2f, $11, $0f, $01, $cd, $d8, $44, $fa, $88, $db, $e6, $04, $4f
	db $06, $03, $21, $02, $db, $cd, $6c, $2f, $11, $0f, $02, $cd, $d8, $44, $c9, $fa
	db $8a, $db, $fe, $34, $28, $03, $fe, $81, $c0, $fa, $88, $db, $e6, $04, $4f, $06
	db $03, $21, $02, $db, $cd, $6c, $2f, $11, $0f, $40, $cd, $d8, $44, $fa, $88, $db
	db $e6, $04, $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $11, $0f, $8c, $cd, $d8
	db $44, $c9, $fa, $8a, $db, $fe, $35, $28, $03, $fe, $81, $c0, $fa, $88, $db, $e6
	db $04, $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $11, $0f, $10, $cd, $d8, $44
	db $c9, $fa, $8a, $db, $fe, $36, $28, $03, $fe, $81, $c0, $fa, $88, $db, $e6, $04
	db $4f, $06, $03, $21, $02, $db, $cd, $6c, $2f, $11, $0f, $20, $cd, $d8, $44, $c9
	db $fa, $8a, $db, $fe, $93, $28, $0a, $fe, $94, $28, $06, $fe, $2b, $d8, $fe, $30
	db $d0, $af, $ea, $61, $db, $fa, $88, $db, $4f, $21, $a3, $db, $87, $85, $6f, $3e
	db $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $79, $21, $b3, $db, $87
	db $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db, $7c, $ea, $59, $db, $79, $cd
	db $c4, $7a, $d8, $3e, $01, $ea, $61, $db, $fa, $8a, $db, $fe, $2d, $c8, $fe, $2f
	db $c8, $21, $26, $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $93, $28
	db $0a, $fe, $94, $28, $06, $fe, $2b, $d8, $fe, $30, $d0, $af, $ea, $63, $db, $fa
	db $88, $db, $4f, $21, $a3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56
	db $db, $7c, $ea, $57, $db, $79, $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67
	db $7d, $ea, $58, $db, $7c, $ea, $59, $db, $79, $cd, $01, $7b, $d8, $3e, $01, $ea
	db $63, $db, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $af, $ea, $65, $db, $fa, $88
	db $db, $4f, $21, $a3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db
	db $7c, $ea, $57, $db, $79, $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d
	db $ea, $58, $db, $7c, $ea, $59, $db, $79, $cd, $35, $7b, $d8, $3e, $01, $ea, $65
	db $db, $21, $26, $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $93, $28
	db $0a, $fe, $94, $28, $06, $fe, $2b, $d8, $fe, $30, $d0, $af, $ea, $67, $db, $fa
	db $88, $db, $4f, $21, $a3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56
	db $db, $7c, $ea, $57, $db, $79, $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67
	db $7d, $ea, $58, $db, $7c, $ea, $59, $db, $79, $cd, $59, $7b, $d8, $3e, $01, $ea
	db $67, $db, $fa, $8a, $db, $fe, $2e, $c8, $21, $26, $dd, $06, $05, $cd, $5f, $45
	db $c9, $fa, $8a, $db, $fe, $93, $28, $0a, $fe, $94, $28, $06, $fe, $2b, $d8, $fe
	db $30, $d0, $af, $ea, $69, $db, $fa, $88, $db, $4f, $cd, $e8, $2f, $fe, $01, $c0
	db $7c, $b7, $c0, $3e, $01, $ea, $69, $db, $fa, $8a, $db, $fe, $2e, $c8, $21, $26
	db $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $94, $28, $06, $fe, $2b
	db $d8, $fe, $30, $d0, $cd, $71, $63, $af, $ea, $62, $db, $fa, $88, $db, $57, $e6
	db $04, $4f, $21, $a3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db
	db $7c, $ea, $57, $db, $79, $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d
	db $ea, $58, $db, $7c, $ea, $59, $db, $79, $ba, $28, $0e, $cd, $a5, $2f, $38, $09
	db $cd, $c4, $7a, $38, $04, $21, $62, $db, $34, $fa, $56, $db, $6f, $fa, $57, $db
	db $67, $23, $23, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa, $58, $db, $6f, $fa
	db $59, $db, $67, $23, $23, $7d, $ea, $58, $db, $7c, $ea, $59, $db, $0c, $05, $20
	db $c6, $fa, $8a, $db, $fe, $2d, $c8, $fe, $2f, $c8, $fa, $62, $db, $b7, $c8, $21
	db $26, $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $94, $28, $06, $fe
	db $2b, $d8, $fe, $30, $d0, $cd, $71, $63, $af, $ea, $64, $db, $fa, $88, $db, $57
	db $e6, $04, $4f, $21, $a3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56
	db $db, $7c, $ea, $57, $db, $79, $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67
	db $7d, $ea, $58, $db, $7c, $ea, $59, $db, $79, $ba, $28, $0e, $cd, $a5, $2f, $38
	db $09, $cd, $01, $7b, $38, $04, $21, $64, $db, $34, $fa, $56, $db, $6f, $fa, $57
	db $db, $67, $23, $23, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa, $58, $db, $6f
	db $fa, $59, $db, $67, $23, $23, $7d, $ea, $58, $db, $7c, $ea, $59, $db, $0c, $05
	db $20, $c6, $fa, $64, $db, $b7, $c8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $cd
	db $71, $63, $af, $ea, $66, $db, $fa, $88, $db, $57, $e6, $04, $4f, $21, $a3, $db
	db $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $79
	db $21, $b3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db, $7c, $ea
	db $59, $db, $79, $ba, $28, $0e, $cd, $a5, $2f, $38, $09, $cd, $35, $7b, $38, $04
	db $21, $66, $db, $34, $fa, $56, $db, $6f, $fa, $57, $db, $67, $23, $23, $7d, $ea
	db $56, $db, $7c, $ea, $57, $db, $fa, $58, $db, $6f, $fa, $59, $db, $67, $23, $23
	db $7d, $ea, $58, $db, $7c, $ea, $59, $db, $0c, $05, $20, $c6, $fa, $66, $db, $b7
	db $c8, $21, $26, $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $94, $28
	db $06, $fe, $2b, $d8, $fe, $30, $d0, $cd, $71, $63, $af, $ea, $68, $db, $fa, $88
	db $db, $57, $e6, $04, $4f, $21, $a3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d
	db $ea, $56, $db, $7c, $ea, $57, $db, $79, $21, $b3, $db, $87, $85, $6f, $3e, $00
	db $8c, $67, $7d, $ea, $58, $db, $7c, $ea, $59, $db, $79, $ba, $28, $0e, $cd, $a5
	db $2f, $38, $09, $cd, $59, $7b, $38, $04, $21, $68, $db, $34, $fa, $56, $db, $6f
	db $fa, $57, $db, $67, $23, $23, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa, $58
	db $db, $6f, $fa, $59, $db, $67, $23, $23, $7d, $ea, $58, $db, $7c, $ea, $59, $db
	db $0c, $05, $20, $c6, $fa, $68, $db, $b7, $c8, $fa, $8a, $db, $fe, $2e, $c8, $21
	db $26, $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $94, $28, $06, $fe
	db $2b, $d8, $fe, $30, $d0, $cd, $71, $63, $af, $ea, $6a, $db, $fa, $88, $db, $57
	db $e6, $04, $4f, $79, $ba, $28, $15, $cd, $a5, $2f, $38, $10, $79, $cd, $e8, $2f
	db $fe, $01, $20, $08, $7c, $b7, $20, $04, $21, $6a, $db, $34, $0c, $05, $20, $e3
	db $fa, $6a, $db, $b7, $c8, $fa, $8a, $db, $fe, $2e, $c8, $21, $26, $dd, $06, $05
	db $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $94, $28, $06, $fe, $2e, $d8, $fe, $30
	db $d0, $fa, $61, $db, $47, $fa, $62, $db, $80, $fe, $02, $d8, $fa, $8a, $db, $fe
	db $2f, $c8, $21, $26, $dd, $06, $05, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $94
	db $28, $06, $fe, $2e, $d8, $fe, $30, $d0, $fa, $63, $db, $47, $fa, $64, $db, $80
	db $fe, $02, $d8, $21, $26, $dd, $06, $0f, $cd, $5f, $45, $fa, $65, $db, $47, $fa
	db $66, $db, $80, $fe, $02, $d8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa
	db $8a, $db, $fe, $2e, $d8, $fe, $30, $d0, $fa, $67, $db, $47, $fa, $68, $db, $80
	db $fe, $02, $d8, $fa, $8a, $db, $fe, $2e, $c8, $21, $26, $dd, $06, $0a, $cd, $5f
	db $45, $c9, $fa, $8a, $db, $fe, $2f, $c0, $fa, $69, $db, $47, $fa, $6a, $db, $80
	db $fe, $02, $d8, $fa, $8a, $db, $fe, $2e, $c8, $21, $26, $dd, $06, $0a, $cd, $5f
	db $45, $c9, $fa, $8a, $db, $fe, $4f, $c8, $fe, $44, $d8, $fe, $52, $38, $15, $fe
	db $d9, $d0, $fe, $d6, $30, $0e, $fe, $6a, $d0, $fe, $67, $30, $07, $fe, $55, $28
	db $03, $fe, $57, $c0, $fa, $88, $db, $21, $06, $db, $cd, $6c, $2f, $3a, $e6, $03
	db $20, $06, $2b, $2b, $7e, $e6, $0c, $c8, $21, $26, $dd, $06, $14, $cd, $5f, $45
	db $c9, $fa, $8a, $db, $fe, $25, $28, $03, $fe, $41, $c0, $fa, $88, $db, $e6, $04
	db $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0b, $79, $21, $03, $db, $cd, $6c, $2f
	db $7e, $e6, $0c, $c8, $0c, $05, $20, $eb, $cd, $e4, $45, $c9, $cd, $6e, $7c, $c0
	db $fa, $8a, $db, $fe, $25, $28, $07, $fe, $7a, $28, $03, $fe, $41, $c0, $fa, $88
	db $db, $5f, $cd, $e0, $62, $cd, $21, $63, $d8, $21, $26, $dd, $06, $14, $cd, $5f
	db $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $7a, $28, $0e, $fe, $82, $28
	db $0a, $fe, $25, $28, $06, $fe, $1c, $d8, $fe, $1e, $d0, $cd, $e0, $62, $fa, $88
	db $db, $e6, $04, $5f, $16, $03, $cd, $21, $63, $30, $05, $1c, $15, $20, $f7, $c9
	db $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db
	db $fe, $18, $28, $11, $fe, $1e, $d8, $fe, $20, $38, $0a, $fe, $72, $d8, $fe, $74
	db $38, $03, $fe, $77, $c0, $af, $ea, $6c, $db, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $af, $ea, $56, $db, $ea, $57, $db, $79, $cd, $a5, $2f, $38, $2d
	db $79, $21, $03, $db, $cd, $6c, $2f, $cb, $4e, $20, $09, $23, $23, $23, $23, $7e
	db $e6, $03, $28, $19, $fa, $56, $db, $5f, $fa, $57, $db, $57, $79, $cd, $cc, $2f
	db $19, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $21, $6c, $db, $34, $0c, $05, $20
	db $c9, $fa, $6c, $db, $b7, $c8, $fa, $56, $db, $6f, $fa, $57, $db, $67, $cd, $0d
	db $1e, $7d, $ea, $58, $db, $7c, $ea, $59, $db, $fa, $88, $db, $e6, $04, $cd, $c5
	db $7d, $fa, $56, $db, $6f, $fa, $57, $db, $67, $cb, $25, $cb, $14, $fa, $58, $db
	db $4f, $fa, $59, $db, $47, $cd, $45, $2f, $d0, $21, $26, $dd, $06, $0a, $cd, $5f
	db $45, $c9, $fa, $8a, $db, $fe, $24, $c0, $fa, $88, $db, $e6, $04, $4f, $06, $03
	db $cd, $4c, $63, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $26, $28, $07, $fe
	db $7f, $28, $03, $fe, $43, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03
	db $cd, $4c, $63, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $17, $28, $0a, $fe
	db $26, $d8, $fe, $7f, $28, $03, $fe, $29, $d0, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $79, $cd, $a5, $2f, $38, $37, $79, $21, $64, $dc, $cb, $37, $85
	db $6f, $3e, $00, $8c, $67, $16, $08, $2a, $b7, $28, $25, $fe, $01, $20, $1d, $7e
	db $fe, $02, $28, $21, $fe, $05, $28, $1d, $fe, $08, $28, $19, $fe, $0b, $28, $15
	db $fe, $0e, $28, $11, $fe, $11, $38, $04, $fe, $14, $38, $09, $23, $15, $20, $d7
	db $0c, $05, $20, $bf, $c9, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $cd, $6e
	db $7c, $c0, $fa, $8a, $db, $fe, $20, $d8, $fe, $24, $d0, $fa, $88, $db, $e6, $04
	db $ee, $04, $4f, $06, $03, $21, $03, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $cd
	db $f7, $44, $fa, $56, $db, $6f, $fa, $57, $db, $67, $fa, $4c, $db, $cd, $0d, $1e
	db $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa, $88, $db, $e6, $04, $5f, $16, $03
	db $21, $03, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $fa, $56, $db, $4f, $fa, $57
	db $db, $47, $7b, $cd, $a5, $2f, $38, $0a, $e5, $2a, $66, $6f, $cd, $45, $2f, $e1
	db $38, $08, $23, $23, $1c, $15, $20, $ea, $18, $08, $21, $26, $dd, $06, $0a, $cd
	db $5f, $45, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $21, $03, $dc, $87
	db $85, $6f, $3e, $00, $8c, $67, $cd, $f7, $44, $fa, $56, $db, $6f, $fa, $57, $db
	db $67, $fa, $4c, $db, $cd, $0d, $1e, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa
	db $88, $db, $e6, $04, $4f, $06, $03, $21, $03, $dc, $87, $85, $6f, $3e, $00, $8c
	db $67, $cd, $f7, $44, $fa, $56, $db, $6f, $fa, $57, $db, $67, $fa, $4c, $db, $cd
	db $0d, $1e, $fa, $58, $db, $4f, $fa, $59, $db, $47, $cd, $45, $2f, $d0, $21, $26
	db $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $29, $c0, $cd, $6e, $7c
	db $c0, $fa, $88, $db, $21, $b3, $db, $87, $5f, $cd, $67, $45, $7d, $ea, $56, $db
	db $7c, $ea, $57, $db, $7b, $cd, $e1, $2f, $7d, $ea, $58, $db, $7c, $ea, $59, $db
	db $7b, $cd, $cc, $2f, $7d, $ea, $5a, $db, $7c, $ea, $5b, $db, $7b, $cd, $d3, $2f
	db $7d, $ea, $5c, $db, $7c, $ea, $5d, $db, $fa, $88, $db, $e6, $04, $ee, $04, $5f
	db $16, $03, $af, $ea, $4c, $db, $7b, $cd, $a5, $2f, $da, $ed, $57, $7b, $21, $b3
	db $db, $cd, $67, $45, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f, $38
	db $04, $21, $4c, $db, $34, $7b, $cd, $e1, $2f, $fa, $58, $db, $4f, $fa, $59, $db
	db $47, $cd, $45, $2f, $18, $04, $21, $4c, $db, $34, $7b, $cd, $cc, $2f, $fa, $5a
	db $db, $4f, $fa, $5b, $db, $47, $cd, $45, $2f, $38, $04, $21, $4c, $db, $34, $7b
	db $cd, $d3, $2f, $fa, $5c, $db, $4f, $fa, $5d, $db, $47, $cd, $45, $2f, $38, $04
	db $21, $4c, $db, $34, $fa, $4c, $db, $fe, $03, $30, $06, $1c, $15, $c2, $88, $57
	db $c9, $21, $26, $dd, $06, $14, $cd, $5f, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a
	db $db, $fe, $76, $28, $06, $fe, $1a, $d8, $fe, $1c, $d0, $fa, $88, $db, $87, $57
	db $21, $c3, $db, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea, $57
	db $db, $7a, $21, $d3, $db, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db, $7c
	db $ea, $59, $db, $cd, $59, $7b, $d0, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9
	db $fa, $8a, $db, $fe, $80, $c0, $cd, $6e, $7c, $c0, $fa, $88, $db, $e6, $04, $ee
	db $04, $4f, $06, $03, $21, $03, $db, $cd, $6c, $2f, $7d, $ea, $56, $db, $7c, $ea
	db $57, $db, $af, $ea, $4c, $db, $79, $cd, $a5, $2f, $da, $0e, $59, $7e, $e6, $3f
	db $28, $1e, $cb, $46, $c4, $2c, $59, $cb, $4e, $c4, $2c, $59, $cb, $56, $c4, $2c
	db $59, $cb, $5e, $c4, $2c, $59, $cb, $66, $c4, $2c, $59, $cb, $6e, $c4, $2c, $59
	db $23, $7e, $e6, $7f, $28, $23, $cb, $46, $c4, $2c, $59, $cb, $4e, $c4, $2c, $59
	db $cb, $56, $c4, $2c, $59, $cb, $5e, $c4, $2c, $59, $cb, $66, $c4, $2c, $59, $cb
	db $6e, $c4, $2c, $59, $cb, $76, $c4, $2c, $59, $23, $7e, $e6, $c0, $28, $0a, $cb
	db $76, $c4, $2c, $59, $cb, $7e, $c4, $2c, $59, $23, $23, $7e, $e6, $cc, $28, $0b
	db $e6, $c0, $c4, $2c, $59, $7e, $e6, $0c, $c4, $2c, $59, $23, $cb, $76, $c4, $2c
	db $59, $fa, $88, $db, $0f, $0f, $e6, $01, $21, $00, $db, $85, $6f, $3e, $00, $8c
	db $67, $7e, $e6, $2c, $28, $0f, $cb, $56, $c4, $2c, $59, $cb, $5e, $c4, $2c, $59
	db $cb, $6e, $c4, $2c, $59, $fa, $4c, $db, $fe, $03, $30, $26, $fa, $56, $db, $6f
	db $fa, $57, $db, $67, $3e, $08, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db
	db $7c, $ea, $57, $db, $0c, $05, $c2, $68, $58, $c9, $fa, $4c, $db, $3c, $ea, $4c
	db $db, $c9, $21, $26, $dd, $06, $14, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $83
	db $c0, $cd, $6e, $7c, $c0, $af, $ea, $4c, $db, $ea, $4d, $db, $fa, $88, $db, $e6
	db $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $35, $79, $21, $65, $dc, $cb, $37
	db $85, $6f, $3e, $00, $8c, $67, $fa, $4d, $db, $3c, $ea, $4d, $db, $16, $08, $2a
	db $fe, $ff, $28, $1b, $fe, $3a, $38, $0c, $fe, $d5, $28, $08, $fe, $da, $28, $04
	db $fe, $dc, $20, $07, $fa, $4c, $db, $3c, $ea, $4c, $db, $23, $15, $20, $e0, $0c
	db $05, $20, $c1, $fa, $4c, $db, $4f, $fa, $4d, $db, $b9, $d8, $fa, $88, $db, $e6
	db $04, $ee, $04, $4f, $06, $03, $16, $00, $79, $cd, $a5, $2f, $38, $39, $79, $21
	db $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $1e, $08, $2a, $fe, $ff, $28
	db $22, $fe, $02, $28, $18, $fe, $05, $28, $14, $fe, $08, $28, $10, $fe, $0b, $28
	db $0c, $fe, $0e, $28, $08, $fe, $11, $38, $0a, $fe, $14, $30, $06, $14, $7a, $fe
	db $02, $30, $09, $23, $1d, $20, $d5, $0c, $05, $20, $bd, $c9, $21, $26, $dd, $06
	db $14, $cd, $5f, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $26, $28, $03
	db $fe, $7f, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $21, $65
	db $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $1e, $08, $2a, $fe, $ff, $28, $21
	db $fe, $4f, $28, $1d, $fe, $59, $28, $19, $fe, $5b, $28, $15, $fe, $64, $28, $11
	db $fe, $65, $28, $0d, $fe, $d9, $28, $09, $23, $1d, $20, $df, $0c, $05, $20, $cd
	db $c9, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $8f, $28
	db $06, $fe, $88, $d8, $fe, $8a, $d0, $fa, $88, $db, $57, $7a, $cd, $e8, $2f, $7d
	db $ea, $56, $db, $7c, $ea, $57, $db, $7a, $21, $b3, $db, $cd, $67, $45, $7d, $ea
	db $58, $db, $7c, $ea, $59, $db, $3e, $0a, $cd, $0d, $1e, $fa, $56, $db, $4f, $fa
	db $57, $db, $47, $09, $fa, $58, $db, $4f, $fa, $59, $db, $47, $cd, $45, $2f, $d8
	db $fa, $88, $db, $57, $e6, $04, $4f, $06, $03, $af, $ea, $4c, $db, $79, $ba, $28
	db $1a, $cd, $a5, $2f, $38, $15, $79, $cd, $e8, $2f, $cd, $cf, $5a, $c5, $fa, $56
	db $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f, $c1, $d0, $0c, $05, $20, $de, $fa
	db $4c, $db, $b7, $c8, $21, $26, $dd, $06, $14, $cd, $5f, $45, $c9, $d5, $c5, $e5
	db $79, $cd, $da, $2f, $3e, $0a, $cd, $0d, $1e, $7d, $b4, $20, $01, $23, $c1, $c5
	db $cd, $45, $2f, $38, $04, $21, $4c, $db, $34, $e1, $c1, $d1, $c9, $fa, $8a, $db
	db $fe, $8d, $c8, $fe, $8f, $c8, $fe, $8c, $d8, $fe, $91, $d0, $fa, $88, $db, $21
	db $a3, $db, $87, $4f, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea
	db $57, $db, $79, $21, $b3, $db, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db
	db $7c, $ea, $59, $db, $79, $cd, $59, $7b, $d8, $21, $26, $dd, $06, $14, $cd, $5f
	db $45, $c9, $fa, $8a, $db, $fe, $41, $c0, $fa, $88, $db, $21, $03, $db, $cd, $6c
	db $2f, $cb, $56, $c8, $cd, $e4, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe
	db $27, $d8, $fe, $29, $d0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79
	db $cd, $a5, $2f, $da, $a3, $5b, $79, $21, $03, $db, $cd, $6c, $2f, $cb, $46, $20
	db $30, $16, $08, $79, $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $2a
	db $fe, $ff, $28, $1d, $fe, $1b, $38, $14, $fe, $1c, $28, $10, $fe, $1d, $28, $0c
	db $fe, $20, $28, $08, $fe, $21, $28, $04, $fe, $da, $20, $01, $c9, $23, $15, $20
	db $de, $0c, $05, $c2, $61, $5b, $cd, $e4, $45, $c9, $c9, $c9, $fa, $8a, $db, $fe
	db $5c, $d8, $fe, $64, $d0, $fa, $88, $db, $21, $06, $db, $cd, $6c, $2f, $7e, $e6
	db $30, $c8, $21, $26, $dd, $06, $1e, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $6f
	db $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38
	db $0a, $79, $21, $02, $db, $cd, $6c, $2f, $cb, $6e, $c8, $0c, $05, $20, $ec, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $17, $28, $07, $fe, $27, $28, $03, $fe, $28
	db $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38
	db $0a, $79, $21, $03, $db, $cd, $6c, $2f, $cb, $46, $c8, $0c, $05, $20, $ec, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $24, $28, $0f, $fe, $8a, $28, $0b, $fe, $8b
	db $28, $07, $fe, $8f, $28, $03, $fe, $92, $c0, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0a, $79, $21, $03, $db, $cd, $6c, $2f
	db $cb, $7e, $c8, $0c, $05, $20, $ec, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $91
	db $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $c5, $79, $cd, $a5, $2f
	db $38, $0b, $79, $21, $03, $db, $cd, $6c, $2f, $cb, $76, $28, $07, $0c, $05, $20
	db $eb, $c1, $18, $3e, $c1, $cd, $6e, $7c, $c0, $79, $cd, $a5, $2f, $38, $2f, $79
	db $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $16, $08, $2a, $fe, $ff
	db $28, $1c, $fe, $6e, $c8, $fe, $71, $c8, $fe, $75, $38, $12, $fe, $79, $d8, $fe
	db $91, $c8, $fe, $94, $c8, $fe, $96, $c8, $23, $15, $20, $e1, $18, $04, $0c, $05
	db $20, $c7, $cd, $e4, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $17, $28
	db $07, $fe, $27, $28, $03, $fe, $28, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f
	db $06, $03, $79, $cd, $a5, $2f, $38, $23, $79, $21, $65, $dc, $cb, $37, $85, $6f
	db $3e, $00, $8c, $67, $16, $08, $2a, $fe, $ff, $28, $10, $fe, $3a, $d8, $fe, $d5
	db $c8, $fe, $da, $c8, $fe, $dc, $c8, $23, $15, $20, $eb, $0c, $05, $20, $d3, $cd
	db $e4, $45, $c9, $c9, $fa, $8a, $db, $fe, $81, $c0, $fa, $88, $db, $e6, $04, $4f
	db $06, $03, $79, $cd, $a5, $2f, $38, $1b, $79, $21, $02, $db, $cd, $6c, $2f, $2a
	db $b7, $c0, $2a, $e6, $c3, $c0, $23, $2a, $e6, $80, $c0, $23, $2a, $e6, $03, $c0
	db $cb, $7e, $c0, $0c, $05, $20, $db, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $14
	db $28, $17, $fe, $30, $d8, $fe, $33, $c8, $fe, $36, $38, $0d, $fe, $88, $d8, $fe
	db $8a, $38, $06, $fe, $95, $d8, $fe, $97, $d0, $fa, $88, $db, $e6, $04, $21, $1b
	db $dd, $85, $6f, $3e, $00, $8c, $67, $06, $03, $16, $00, $2a, $fe, $ff, $28, $01
	db $14, $05, $20, $f7, $7a, $fe, $02, $d0, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe
	db $03, $d8, $fe, $12, $38, $19, $fe, $13, $28, $15, $fe, $14, $28, $11, $fe, $4f
	db $28, $0d, $fe, $58, $c8, $fe, $57, $d8, $fe, $67, $38, $03, $fe, $71, $c0, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $16, $00, $79, $cd, $a5, $2f, $38
	db $01, $14, $0c, $05, $20, $f5, $7a, $fe, $01, $c0, $fa, $8a, $db, $fe, $57, $28
	db $09, $21, $27, $dd, $06, $14, $cd, $5f, $45, $c9, $cd, $e4, $45, $c9, $fa, $8a
	db $db, $fe, $8a, $d8, $fe, $8c, $d0, $fa, $88, $db, $21, $04, $db, $cd, $6c, $2f
	db $7e, $e6, $48, $c8, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $1b, $c0, $fa, $88
	db $db, $21, $04, $db, $cd, $6c, $2f, $cb, $46, $c8, $cd, $e4, $45, $c9, $fa, $8a
	db $db, $fe, $7b, $d8, $fe, $7d, $d0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06
	db $03, $79, $cd, $a5, $2f, $38, $0d, $79, $21, $8b, $db, $85, $6f, $3e, $00, $8c
	db $67, $cb, $66, $c8, $0c, $05, $20, $e9, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe
	db $74, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f
	db $38, $22, $79, $ea, $89, $db, $3e, $02, $ea, $4c, $db, $c5, $21, $06, $52, $d7
	db $c1, $fa, $4c, $db, $e6, $30, $fe, $30, $28, $0a, $79, $21, $05, $db, $cd, $6c
	db $2f, $cb, $7e, $c8, $0c, $05, $20, $d4, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe
	db $26, $c0, $fa, $88, $db, $e6, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0a
	db $79, $21, $05, $db, $cd, $6c, $2f, $cb, $76, $c8, $0c, $05, $20, $ec, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $77, $c0, $fa, $88, $db, $21, $07, $db, $cd, $6c
	db $2f, $7e, $e6, $0c, $c8, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $72, $d8, $fe
	db $74, $d0, $fa, $88, $db, $e6, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0b
	db $79, $21, $07, $db, $cd, $6c, $2f, $7e, $e6, $03, $c8, $0c, $05, $20, $eb, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $1a, $38, $10, $fe, $1c, $d8, $fe, $1e, $c8
	db $fe, $1f, $c8, $fe, $da, $28, $03, $fe, $22, $d0, $fa, $88, $db, $e6, $04, $ee
	db $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0b, $79, $21, $04, $db, $cd, $6c
	db $2f, $7e, $e6, $22, $c8, $0c, $05, $20, $eb, $cd, $e4, $45, $c9, $fa, $8a, $db
	db $fe, $1a, $38, $48, $fe, $1c, $d8, $fe, $1e, $38, $41, $fe, $20, $d8, $fe, $22
	db $38, $3a, $fe, $2a, $28, $36, $fe, $3b, $d8, $fe, $41, $38, $2f, $fe, $44, $28
	db $2b, $fe, $53, $28, $27, $fe, $55, $d8, $fe, $80, $38, $20, $fe, $82, $28, $1c
	db $fe, $88, $d8, $fe, $8a, $38, $15, $fe, $8c, $d8, $fe, $93, $38, $0e, $fe, $d6
	db $d8, $fe, $db, $38, $07, $fe, $dc, $38, $03, $fe, $dd, $c0, $fa, $88, $db, $e6
	db $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0b, $79, $21, $07, $db
	db $cd, $6c, $2f, $7e, $e6, $c0, $c8, $0c, $05, $20, $eb, $cd, $e4, $45, $c9, $fa
	db $8a, $db, $fe, $15, $d8, $fe, $17, $38, $4b, $fe, $19, $28, $47, $fe, $2a, $28
	db $43, $fe, $6a, $d8, $fe, $6c, $38, $3c, $fe, $6e, $28, $38, $fe, $70, $28, $34
	db $fe, $72, $d8, $fe, $74, $38, $2d, $fe, $77, $d8, $fe, $79, $38, $26, $fe, $7a
	db $d8, $fe, $7e, $38, $1f, $fe, $80, $d8, $fe, $83, $38, $18, $fe, $88, $d8, $fe
	db $8a, $38, $11, $fe, $8c, $d8, $fe, $8d, $c8, $fe, $da, $28, $07, $fe, $dc, $28
	db $03, $fe, $91, $d0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd
	db $76, $2f, $d0, $0c, $05, $20, $f7, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $15
	db $d8, $fe, $17, $38, $20, $fe, $19, $28, $1c, $fe, $68, $d8, $fe, $6c, $38, $15
	db $fe, $6e, $28, $11, $fe, $70, $28, $0d, $fe, $78, $d8, $fe, $7a, $c8, $fe, $7e
	db $38, $03, $fe, $da, $c0, $cd, $4d, $7d, $79, $cd, $76, $2f, $38, $03, $cd, $54
	db $7d, $0c, $05, $20, $f3, $fa, $55, $db, $b7, $c8, $21, $54, $db, $be, $d8, $21
	db $26, $dd, $06, $14, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $18, $28, $06, $fe
	db $72, $d8, $fe, $74, $d0, $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $17, $79, $21
	db $03, $db, $cd, $6c, $2f, $cb, $4e, $20, $0c, $23, $23, $23, $23, $7e, $e6, $03
	db $20, $03, $cd, $54, $7d, $0c, $05, $20, $df, $fa, $55, $db, $b7, $c8, $21, $54
	db $db, $be, $d8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe
	db $17, $c0, $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $14, $79, $cd, $94, $7e, $38
	db $0e, $79, $21, $03, $db, $cd, $6c, $2f, $cb, $46, $20, $03, $cd, $54, $7d, $0c
	db $05, $20, $e2, $fa, $55, $db, $b7, $c8, $21, $54, $db, $be, $d8, $21, $26, $dd
	db $06, $1e, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $17, $28, $06, $fe, $75, $d8
	db $fe, $77, $d0, $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $12, $79, $21, $c3, $db
	db $87, $85, $6f, $3e, $00, $8c, $67, $2a, $b6, $28, $03, $cd, $54, $7d, $0c, $05
	db $20, $e4, $fa, $55, $db, $b7, $c8, $21, $54, $db, $be, $d8, $21, $26, $dd, $06
	db $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $7a, $28, $06, $fe, $1c, $d8, $fe
	db $1e, $d0, $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $10, $79, $cd, $d3, $2f, $7d
	db $fe, $02, $30, $04, $7c, $b7, $28, $03, $cd, $54, $7d, $0c, $05, $20, $e6, $fa
	db $55, $db, $b7, $c8, $21, $54, $db, $be, $d8, $21, $26, $dd, $06, $0a, $cd, $5f
	db $45, $c9, $fa, $8a, $db, $fe, $20, $d8, $fe, $22, $d0, $cd, $4d, $7d, $79, $cd
	db $a5, $2f, $38, $13, $79, $21, $03, $dc, $cd, $67, $45, $7d, $fe, $02, $30, $04
	db $7c, $b7, $28, $03, $cd, $54, $7d, $0c, $05, $20, $e3, $fa, $55, $db, $b7, $c8
	db $21, $54, $db, $be, $d8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a
	db $db, $fe, $67, $28, $06, $fe, $6c, $d8, $fe, $6e, $d0, $cd, $4d, $7d, $79, $cd
	db $a5, $2f, $38, $0f, $79, $21, $02, $db, $cd, $6c, $2f, $7e, $e6, $03, $20, $03
	db $cd, $54, $7d, $0c, $05, $20, $e7, $fa, $55, $db, $b7, $c8, $21, $54, $db, $be
	db $d8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $6f, $c0
	db $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $0f, $79, $21, $02, $db, $cd, $6c, $2f
	db $7e, $e6, $20, $20, $03, $cd, $54, $7d, $0c, $05, $20, $e7, $fa, $55, $db, $b7
	db $c8, $21, $54, $db, $be, $d8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa
	db $8a, $db, $fe, $91, $c0, $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $15, $79, $cd
	db $f4, $7e, $38, $0f, $79, $21, $03, $db, $cd, $6c, $2f, $7e, $e6, $40, $20, $03
	db $cd, $54, $7d, $0c, $05, $20, $e1, $fa, $55, $db, $b7, $c8, $21, $54, $db, $be
	db $d8, $21, $26, $dd, $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $92, $c0
	db $cd, $4d, $7d, $79, $cd, $a5, $2f, $38, $15, $79, $cd, $c0, $7e, $38, $0f, $79
	db $21, $03, $db, $cd, $6c, $2f, $7e, $e6, $80, $20, $03, $cd, $54, $7d, $0c, $05
	db $20, $e1, $fa, $55, $db, $b7, $c8, $21, $54, $db, $be, $d8, $21, $26, $dd, $06
	db $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $15, $d8, $fe, $17, $38, $20, $fe
	db $19, $28, $1c, $fe, $68, $d8, $fe, $6c, $38, $15, $fe, $6e, $28, $11, $fe, $70
	db $28, $0d, $fe, $78, $d8, $fe, $7a, $c8, $fe, $7e, $38, $03, $fe, $da, $c0, $cd
	db $73, $7d, $79, $cd, $76, $2f, $38, $06, $cd, $a4, $7d, $fe, $03, $c0, $0c, $05
	db $20, $f0, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $18, $28, $06, $fe, $72, $d8
	db $fe, $74, $d0, $cd, $73, $7d, $79, $cd, $a5, $2f, $38, $1a, $79, $21, $03, $db
	db $cd, $6c, $2f, $cb, $4e, $20, $0f, $23, $23, $23, $23, $7e, $e6, $03, $20, $06
	db $cd, $a4, $7d, $fe, $03, $c0, $0c, $05, $20, $dc, $cd, $e4, $45, $c9, $fa, $88
	db $db, $e6, $04, $ee, $04, $5f, $21, $00, $00, $cd, $a5, $2f, $38, $03, $cd, $d3
	db $2f, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $1c, $16, $02, $7b, $cd, $a5, $2f
	db $38, $18, $cd, $d3, $2f, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cd, $45, $2f
	db $30, $08, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $1c, $15, $20, $de, $c9, $fa
	db $56, $db, $4f, $fa, $57, $db, $47, $cb, $38, $cb, $19, $7b, $cd, $cc, $2f, $cd
	db $45, $2f, $38, $14, $fa, $56, $db, $4f, $fa, $57, $db, $47, $cb, $3c, $cb, $1d
	db $cd, $45, $2f, $30, $03, $af, $b7, $c9, $37, $c9, $79, $cd, $a5, $2f, $38, $17
	db $79, $ea, $89, $db, $3e, $04, $ea, $4c, $db, $c5, $21, $06, $52, $d7, $c1, $fa
	db $4c, $db, $e6, $3c, $fe, $3c, $c0, $0c, $05, $20, $df, $cd, $e4, $45, $c9, $fa
	db $88, $db, $fe, $04, $30, $05, $fa, $74, $db, $18, $03, $fa, $75, $db, $47, $c9
	db $fa, $8a, $db, $fe, $17, $c0, $cd, $73, $7d, $79, $cd, $a5, $2f, $38, $17, $79
	db $cd, $94, $7e, $38, $11, $79, $21, $03, $db, $cd, $6c, $2f, $cb, $46, $20, $06
	db $cd, $a4, $7d, $fe, $03, $c0, $0c, $05, $20, $df, $cd, $e4, $45, $c9, $fa, $8a
	db $db, $fe, $1a, $28, $06, $fe, $75, $d8, $fe, $77, $d0, $cd, $73, $7d, $79, $cd
	db $a5, $2f, $38, $15, $79, $21, $c3, $db, $87, $85, $6f, $3e, $00, $8c, $67, $2a
	db $b6, $28, $06, $cd, $a4, $7d, $fe, $03, $c0, $0c, $05, $20, $e1, $cd, $e4, $45
	db $c9, $fa, $8a, $db, $fe, $1c, $d8, $fe, $1e, $38, $03, $fe, $7a, $c0, $cd, $73
	db $7d, $79, $cd, $a5, $2f, $38, $13, $79, $cd, $d3, $2f, $7d, $fe, $02, $30, $04
	db $7c, $b7, $28, $06, $cd, $a4, $7d, $fe, $03, $c0, $0c, $05, $20, $e3, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $20, $d8, $fe, $22, $d0, $cd, $73, $7d, $79, $cd
	db $a5, $2f, $38, $16, $79, $21, $03, $dc, $cd, $67, $45, $7d, $fe, $02, $30, $04
	db $7c, $b7, $28, $06, $cd, $a4, $7d, $fe, $03, $c0, $0c, $05, $20, $e0, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $67, $28, $06, $fe, $6c, $d8, $fe, $6e, $d0, $cd
	db $73, $7d, $79, $cd, $a5, $2f, $38, $12, $79, $21, $02, $db, $cd, $6c, $2f, $7e
	db $e6, $03, $20, $06, $cd, $a4, $7d, $fe, $03, $c0, $0c, $05, $20, $e4, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $6f, $c0, $cd, $73, $7d, $79, $cd, $a5, $2f, $38
	db $12, $79, $21, $02, $db, $cd, $6c, $2f, $7e, $e6, $20, $20, $06, $cd, $a4, $7d
	db $fe, $03, $c0, $0c, $05, $20, $e4, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $91
	db $c0, $cd, $73, $7d, $79, $cd, $a5, $2f, $38, $18, $79, $cd, $f4, $7e, $38, $12
	db $79, $21, $03, $db, $cd, $6c, $2f, $7e, $e6, $40, $20, $06, $cd, $a4, $7d, $fe
	db $03, $c0, $0c, $05, $20, $de, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $92, $c0
	db $cd, $73, $7d, $79, $cd, $a5, $2f, $38, $18, $79, $cd, $c0, $7e, $38, $12, $79
	db $21, $03, $db, $cd, $6c, $2f, $7e, $e6, $80, $20, $06, $cd, $a4, $7d, $fe, $03
	db $c0, $0c, $05, $20, $de, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $14, $28, $07
	db $fe, $32, $28, $03, $fe, $96, $c0, $af, $ea, $66, $db, $fa, $88, $db, $e6, $04
	db $4f, $06, $03, $c5, $79, $cd, $a5, $2f, $38, $78, $79, $21, $a3, $db, $87, $85
	db $6f, $3e, $00, $8c, $67, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $79, $21, $b3
	db $db, $87, $85, $6f, $3e, $00, $8c, $67, $7d, $ea, $58, $db, $7c, $ea, $59, $db
	db $fa, $56, $db, $6f, $fa, $57, $db, $67, $2a, $66, $6f, $e5, $fa, $58, $db, $6f
	db $fa, $59, $db, $67, $2a, $66, $6f, $fa, $58, $db, $6f, $fa, $59, $db, $67, $7c
	db $b7, $20, $0f, $7b, $0f, $0f, $e6, $3f, $b7, $28, $03, $5f, $18, $0c, $1e, $01
	db $18, $08, $cb, $2c, $cb, $1d, $cb, $2c, $cb, $1d, $c1, $cd, $45, $2f, $38, $12
	db $21, $66, $db, $34, $c1, $0c, $05, $20, $8a, $fa, $66, $db, $b7, $c8, $cd, $e4
	db $45, $c9, $c1, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $03, $d8, $fe, $12
	db $c8, $fe, $15, $c8, $fe, $1a, $38, $4c, $fe, $1d, $28, $48, $fe, $21, $28, $44
	db $fe, $3c, $d8, $fe, $3d, $c8, $fe, $3f, $38, $3a, $fe, $4f, $d8, $28, $35, $fe
	db $52, $d8, $28, $30, $fe, $53, $28, $2c, $fe, $57, $d8, $28, $27, $fe, $59, $d8
	db $fe, $67, $38, $20, $fe, $6a, $d8, $fe, $70, $c8, $fe, $72, $38, $16, $fe, $7c
	db $d8, $fe, $7e, $38, $0f, $fe, $d5, $28, $0b, $fe, $d9, $28, $07, $fe, $da, $28
	db $03, $fe, $dc, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd
	db $a5, $2f, $38, $05, $cd, $72, $45, $20, $05, $0c, $05, $20, $f1, $c9, $21, $27
	db $dd, $06, $1e, $cd, $5f, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db, $fe, $1b
	db $c8, $fe, $1e, $38, $33, $fe, $20, $d8, $fe, $22, $38, $2c, $fe, $3b, $d8, $fe
	db $41, $c8, $fe, $43, $c8, $fe, $54, $c8, $fe, $77, $c8, $fe, $7e, $38, $19, $fe
	db $82, $28, $15, $fe, $91, $d8, $fe, $93, $38, $0e, $fe, $d5, $d8, $fe, $da, $28
	db $07, $fe, $dc, $28, $03, $fe, $da, $d0, $fa, $88, $db, $e6, $04, $ee, $04, $4f
	db $06, $03, $79, $cd, $a5, $2f, $38, $04, $cd, $72, $45, $c8, $0c, $05, $20, $f2
	db $21, $27, $dd, $06, $14, $cd, $5f, $45, $c9, $cd, $6e, $7c, $c0, $fa, $8a, $db
	db $fe, $17, $28, $28, $fe, $1a, $28, $24, $fe, $1b, $28, $20, $fe, $24, $28, $1c
	db $fe, $26, $d8, $fe, $29, $38, $15, $fe, $75, $d8, $fe, $77, $38, $0e, $fe, $8a
	db $d8, $fe, $8c, $38, $07, $fe, $8f, $28, $03, $fe, $92, $c0, $fa, $88, $db, $e6
	db $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $0e, $79, $21, $c3, $db
	db $87, $85, $6f, $3e, $00, $8c, $67, $2a, $b6, $c0, $0c, $05, $20, $e8, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $33, $c0, $fa, $88, $db, $e6, $04, $4f, $06, $03
	db $79, $cd, $a5, $2f, $38, $0b, $79, $21, $02, $db, $cd, $6c, $2f, $7e, $e6, $03
	db $c0, $0c, $05, $20, $eb, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $3c, $28, $03
	db $fe, $3e, $c0, $fa, $88, $db, $cd, $e8, $2f, $44, $4d, $cb, $38, $cb, $19, $09
	db $7d, $ea, $56, $db, $7c, $ea, $57, $db, $fa, $88, $db, $e6, $04, $ee, $04, $4f
	db $06, $03, $79, $cd, $a5, $2f, $38, $1f, $c5, $79, $21, $a3, $db, $87, $85, $6f
	db $3e, $00, $8c, $67, $2a, $46, $4f, $fa, $56, $db, $6f, $fa, $57, $db, $67, $cd
	db $45, $2f, $c1, $28, $02, $38, $05, $0c, $05, $20, $d7, $c9, $21, $26, $dd, $06
	db $14, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $84, $d8, $fe, $88, $d0, $fa, $88
	db $db, $e6, $04, $cb, $3f, $cb, $3f, $21, $00, $db, $85, $6f, $3e, $00, $8c, $67
	db $cb, $56, $c8, $fa, $88, $db, $e6, $04, $c6, $03, $cd, $a5, $2f, $d8, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $2a, $28, $1c, $fe, $55, $d8, $fe, $57, $38, $15
	db $fe, $7f, $28, $11, $fe, $88, $d8, $fe, $8a, $38, $0a, $fe, $8c, $d8, $fe, $91
	db $38, $03, $fe, $dc, $c0, $fa, $ed, $d9, $fe, $15, $d8, $cd, $e4, $45, $c9, $fa
	db $8a, $db, $fe, $95, $28, $06, $fe, $30, $d8, $fe, $32, $d0, $fa, $88, $db, $e6
	db $04, $4f, $06, $03, $79, $cd, $a5, $2f, $28, $01, $d8, $0c, $05, $20, $f5, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $81, $c0, $fa, $88, $db, $e6, $04, $4f, $06
	db $03, $79, $cd, $a5, $2f, $38, $19, $79, $21, $03, $db, $cd, $6c, $2f, $2a, $e6
	db $c3, $20, $12, $23, $23, $23, $2a, $e6, $03, $20, $0a, $7e, $e6, $80, $20, $05
	db $0c, $05, $20, $dd, $c9, $21, $26, $dd, $06, $0f, $cd, $5f, $45, $c9, $fa, $8a
	db $db, $fe, $14, $38, $0a, $fe, $4f, $28, $06, $fe, $58, $d8, $fe, $67, $d0, $fa
	db $88, $db, $cd, $a5, $2f, $d8, $fa, $88, $db, $21, $03, $db, $cd, $6c, $2f, $2a
	db $e6, $02, $20, $09, $23, $23, $23, $7e, $e6, $03, $20, $01, $c9, $21, $26, $dd
	db $06, $0a, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $48, $d8, $fe, $4f, $38, $0a
	db $fe, $d6, $d8, $fe, $d9, $d0, $d6, $cf, $18, $02, $d6, $48, $c7, $73, $68, $97
	db $68, $cf, $68, $e0, $68, $f1, $68, $02, $69, $13, $69, $24, $69, $36, $69, $48
	db $69, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38
	db $0d, $79, $21, $8b, $db, $85, $6f, $3e, $00, $8c, $67, $cb, $46, $c0, $0c, $05
	db $20, $e9, $c3, $5a, $69, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e
	db $01, $ea, $4c, $db, $79, $cd, $a5, $2f, $38, $1c, $79, $21, $3c, $dc, $85, $6f
	db $3e, $00, $8c, $67, $7e, $ea, $31, $da, $c5, $21, $01, $03, $d7, $c1, $fa, $33
	db $da, $21, $4c, $db, $be, $c8, $0c, $05, $20, $da, $c3, $5a, $69, $fa, $88, $db
	db $e6, $04, $ee, $04, $4f, $06, $03, $3e, $02, $ea, $4c, $db, $18, $c6, $fa, $88
	db $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $03, $ea, $4c, $db, $18, $b5, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $06, $ea, $4c, $db, $18, $a4
	db $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $07, $ea, $4c, $db, $18
	db $93, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $08, $ea, $4c, $db
	db $18, $82, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $00, $ea, $4c
	db $db, $c3, $a6, $68, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $3e, $05
	db $ea, $4c, $db, $c3, $a6, $68, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03
	db $3e, $04, $ea, $4c, $db, $c3, $a6, $68, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe
	db $43, $c0, $fa, $88, $db, $21, $06, $db, $cd, $6c, $2f, $7e, $e6, $30, $c8, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $82, $c0, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $79, $cd, $a5, $2f, $38, $38, $79, $ea, $89, $db, $3e, $02, $ea
	db $4c, $db, $c5, $21, $06, $52, $d7, $c1, $fa, $4c, $db, $e6, $30, $fe, $30, $28
	db $20, $79, $21, $03, $dc, $cd, $67, $45, $cd, $d1, $45, $d0, $79, $21, $f3, $db
	db $cd, $67, $45, $cd, $d1, $45, $d0, $79, $21, $03, $db, $cd, $6c, $2f, $cb, $4e
	db $c8, $0c, $05, $20, $be, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $80, $c0, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38, $27, $79
	db $21, $02, $db, $cd, $6c, $2f, $2a, $2a, $e6, $c2, $20, $11, $2a, $e6, $10, $20
	db $0c, $2a, $23, $2a, $e6, $03, $20, $05, $7e, $e6, $80, $28, $09, $21, $27, $dd
	db $06, $14, $cd, $5f, $45, $c9, $0c, $05, $20, $cf, $c9, $fa, $8a, $db, $fe, $3b
	db $d8, $fe, $41, $38, $2d, $fe, $44, $d8, $fe, $4f, $38, $26, $fe, $50, $d8, $fe
	db $54, $38, $1f, $fe, $55, $d8, $fe, $58, $38, $18, $fe, $67, $d8, $fe, $6a, $38
	db $11, $fe, $70, $28, $0d, $fe, $79, $d8, $fe, $7d, $38, $06, $fe, $d6, $d8, $fe
	db $da, $d0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd, $a5, $2f
	db $38, $0b, $79, $21, $06, $db, $cd, $6c, $2f, $7e, $e6, $0c, $c8, $0c, $05, $20
	db $eb, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $55, $c0, $fa, $88, $db, $21, $03
	db $dc, $87, $85, $6f, $3e, $00, $8c, $67, $2a, $66, $6f, $44, $4d, $09, $09, $3e
	db $0a, $cd, $0d, $1e, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $79, $cd
	db $a5, $2f, $38, $16, $c5, $e5, $79, $21, $03, $dc, $87, $85, $6f, $3e, $00, $8c
	db $67, $2a, $46, $4f, $e1, $cd, $45, $2f, $c1, $d8, $0c, $05, $20, $e0, $cd, $e4
	db $45, $c9, $fa, $8a, $db, $fe, $1a, $28, $07, $fe, $1b, $28, $03, $fe, $76, $c0
	db $fa, $88, $db, $87, $21, $c3, $db, $85, $6f, $3e, $00, $8c, $67, $2a, $46, $4f
	db $fa, $88, $db, $87, $21, $d3, $db, $85, $6f, $3e, $00, $8c, $67, $2a, $66, $6f
	db $cb, $3c, $cb, $1d, $54, $5d, $cb, $3c, $cb, $1d, $19, $cd, $45, $2f, $d0, $cd
	db $e4, $45, $c9, $fa, $8a, $db, $fe, $83, $c0, $fa, $88, $db, $e6, $04, $ee, $04
	db $4f, $06, $03, $79, $cd, $a5, $2f, $38, $37, $79, $21, $64, $dc, $cb, $37, $85
	db $6f, $3e, $00, $8c, $67, $16, $08, $2a, $b7, $28, $25, $fe, $01, $20, $1d, $7e
	db $fe, $02, $28, $22, $fe, $05, $28, $1e, $fe, $08, $28, $1a, $fe, $0b, $28, $16
	db $fe, $0e, $28, $12, $fe, $11, $38, $04, $fe, $14, $38, $0a, $23, $15, $20, $d7
	db $0c, $05, $20, $bf, $18, $3d, $fa, $88, $db, $e6, $04, $4f, $06, $03, $1e, $00
	db $79, $cd, $a5, $2f, $38, $22, $79, $21, $64, $dc, $cb, $37, $85, $6f, $3e, $00
	db $8c, $67, $16, $08, $2a, $b7, $28, $10, $fe, $01, $20, $08, $fe, $2b, $38, $04
	db $fe, $33, $38, $09, $23, $15, $20, $ec, $0c, $05, $20, $d4, $c9, $1c, $5f, $fe
	db $02, $38, $f1, $cd, $e4, $45, $c9, $fa, $8a, $db, $fe, $3b, $28, $03, $fe, $3d
	db $c0, $fa, $88, $db, $87, $21, $a3, $db, $85, $6f, $3e, $00, $8c, $67, $2a, $46
	db $4f, $fa, $88, $db, $87, $21, $b3, $db, $85, $6f, $3e, $00, $8c, $67, $2a, $66
	db $6f, $cb, $3c, $cb, $1d, $54, $5d, $cb, $3c, $cb, $1d, $19, $cd, $45, $2f, $d8
	db $21, $26, $dd, $06, $14, $cd, $5f, $45, $c9, $fa, $8a, $db, $fe, $80, $c0, $fa
	db $88, $db, $e6, $04, $ee, $04, $4f, $cb, $3f, $cb, $3f, $21, $00, $db, $85, $6f
	db $3e, $00, $8c, $67, $7e, $e6, $2c, $c0, $06, $03, $79, $21, $03, $db, $cd, $6c
	db $2f, $2a, $e6, $3c, $c0, $2a, $e6, $6f, $c0, $2a, $e6, $40, $c0, $23, $2a, $e6
	db $cc, $c0, $2a, $e6, $40, $c0, $05, $20, $e1, $cd, $e4, $45, $c9, $cd, $6e, $7c
	db $c0, $fa, $8a, $db, $fe, $26, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06
	db $03, $1e, $08, $79, $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $7e
	db $fe, $ff, $28, $24, $2a, $ea, $4c, $db, $3e, $00, $ea, $4d, $db, $3e, $06, $ea
	db $4e, $db, $f5, $c5, $d5, $e5, $21, $00, $54, $d7, $e1, $d1, $c1, $f1, $fa, $4c
	db $db, $fe, $00, $c0, $23, $1d, $20, $d7, $0c, $05, $20, $c5, $cd, $e4, $45, $c9
	db $fa, $6c, $c8, $b7, $c0, $fa, $88, $db, $fe, $04, $d0, $fa, $73, $db, $fe, $01
	db $c0, $fa, $8a, $db, $fe, $12, $d8, $fe, $15, $38, $0b, $fe, $69, $28, $07, $fe
	db $6b, $28, $03, $fe, $71, $c0, $cd, $e4, $45, $c9, $fa, $6c, $c8, $b7, $c0, $fa
	db $88, $db, $fe, $04, $d8, $fe, $07, $c8, $fa, $8a, $db, $fe, $15, $38, $16, $fe
	db $3b, $d8, $fe, $41, $c8, $fe, $43, $c8, $fe, $54, $c8, $fe, $6a, $38, $06, $fe
	db $d6, $d8, $fe, $da, $d0, $21, $26, $dd, $06, $14, $cd, $5f, $45, $c9, $fa, $8a
	db $db, $fe, $24, $c0, $cd, $6e, $7c, $c0, $fa, $88, $db, $e6, $04, $ee, $04, $4f
	db $06, $03, $79, $cd, $a5, $2f, $38, $05, $cd, $e8, $6c, $38, $08, $0c, $05, $20
	db $f1, $cd, $e4, $45, $c9, $c9, $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c
	db $67, $16, $08, $2a, $cd, $00, $6d, $d8, $23, $15, $20, $f7, $b7, $c9, $fe, $5c
	db $38, $03, $fe, $64, $d8, $b7, $c9

Call_57_6D09::
	cp $03
	jr nc, jr_057_6d27

Call_57_6D0D::
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call CopyName
	pop hl

jr_057_6d1c:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_057_6d1c

jr_057_6d23:
	ld a, b
	pop bc
	jr Call_57_6D0D

jr_057_6d27:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_057_6d50

	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_6d23

	push hl
	ld a, b
	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	cp $ff
	jr nz, jr_057_6d4d

	ld a, b

jr_057_6d4d:
	pop bc
	jr nz, jr_057_6d78

jr_057_6d50:
	push af
	call Call_57_6D5A
	pop af
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


Call_57_6D5A::
	ld [wNameBattler], a
	push hl
	ld hl, wBattlerSpecies
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
	ld [wNameDest], a
	ld a, d
	ld [$db5f], a
	call CopySystemText
	ret


jr_057_6d78:
	call Call_57_6D0D
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
	ld hl, wEnemyMorph
	ld a, [wNamePos]
	and $03
	cp $01
	jr z, jr_057_6da4

	cp $02
	jr z, jr_057_6dae

	ld a, [hli]
	cp [hl]
	jr z, jr_057_6dca

	inc hl
	cp [hl]
	jr z, jr_057_6dca

	jr jr_057_6dd9

jr_057_6da4:
	ld a, [hli]
	cp [hl]
	jr z, jr_057_6dcf

	ld a, [hli]
	cp [hl]
	jr z, jr_057_6dca

	jr jr_057_6dd9

jr_057_6dae:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_057_6db8

	inc d

jr_057_6db8:
	inc hl
	cp [hl]
	jr nz, jr_057_6dbd

	inc d

jr_057_6dbd:
	ld a, d
	or a
	jr z, jr_057_6dd9

	cp $01
	jr z, jr_057_6dcf

	pop hl
	ld a, $03
	jr jr_057_6dd2

jr_057_6dca:
	pop hl
	ld a, $01
	jr jr_057_6dd2

jr_057_6dcf:
	pop hl
	ld a, $02

jr_057_6dd2:
	ld [wBattleArg1], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_057_6dd9:
	pop hl
	xor a
	ld [wBattleArg1], a
	ret


	db $21, $a0, $c1, $18, $03, $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db
	db $fa, $89, $db, $ea, $50, $db, $cd, $09, $6d, $c9, $21, $80, $c1, $7d, $ea, $4e
	db $db, $7c, $ea, $4f, $db, $fa, $88, $db, $ea, $50, $db, $cd, $09, $6d, $c9

Call_57_6E0E::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_57_6E12::
	dw Jump_57_6E2A
	dw Jump_57_7129
	dw Jump_57_73B9
	dw Jump_57_7529
	dw Jump_57_7439
	dw Jump_57_75A2
	dw Jump_57_7859
	dw Jump_57_7865

jr_057_6e22:
	ld a, $06
	ld [wBattleSubStep2], a
	jp Jump_57_7859


Jump_57_6E2A::
	ld a, [wBattleSubStep]
	cp $16
	jr c, jr_057_6e50

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01

jr_057_6e50:
	ld hl, $dce4
	ld bc, $0008
	xor a
	call FillMemory
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_057_6e22

	ld hl, wSkillTargeting
	ld bc, $0007
	xor a
	call FillMemory
	xor a
	ld [wNamePos], a
	ld [$db51], a
	ld [$db52], a
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	jr c, jr_057_6eb9

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_057_6eb9

	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr z, jr_057_6ec1

	ld a, [wSkillUser]
	cp $03
	jr c, jr_057_6f1f

	jr z, jr_057_6eb9

	cp $07
	jr z, jr_057_6eb9

	ld a, [wLinkActive]
	or a
	jr z, jr_057_6eb9

	jr jr_057_6f1f

jr_057_6eb9:
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7129


	db $c9

jr_057_6ec1:
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_6ecc

	ld a, [wMenuChoice]
	jr jr_057_6edb

jr_057_6ecc:
	ld a, [wSkillUser]
	cp $04
	jr nc, jr_057_6ed8

	ld a, [wOrderFlag0]
	jr jr_057_6edb

jr_057_6ed8:
	ld a, [wOrderFlag1]

jr_057_6edb:
	ld [wBattleTemp], a
	ld a, [hl]
	call Call_57_78D4
	call Call_57_7905
	call Call_57_791A
	call Call_57_7A03
	call Call_57_7A16
	call Call_57_7A5D
	jp nc, Jump_057_6f8c

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	set 6, [hl]
	ld a, [wBattleTemp]
	cp $81
	jp nz, Jump_57_7129

	ld hl, wBattleSubStep2
	inc [hl]

jr_057_6f1f:
	ld a, [wBattleSubStep]
	cp $01
	jr nz, jr_057_6f64

	ld a, [wSkillUser]
	call CheckBattlerPresent
	jp c, Jump_57_7129

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $dc
	jp nz, Jump_57_7129

	inc hl
	inc hl
	inc hl
	ld a, [hl]
	and $1f
	jp nz, Jump_57_7129

	inc hl
	bit 2, [hl]
	jp nz, Jump_57_7129

	inc hl
	ld a, [hl]
	and $d0
	jp nz, Jump_57_7129

	call Call_57_7E82
	ld a, $b4
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10

jr_057_6f64:
	ld a, $06
	ld [wBattleSubStep2], a
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	ld [hli], a
	ld a, [hl]
	and $cf
	ld [hl], a
	call Call_57_7F5F
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


Jump_057_6f8c:
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
	cp $03
	jr nz, jr_057_6fbc

	ld a, [wBattleTemp]
	cp $81
	jr z, jr_057_6fd2

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $3a
	ld a, $06
	ld [wBattleSubStep2], a
	jp Jump_57_7859


jr_057_6fbc:
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleTemp]
	cp $81
	jr z, jr_057_6fd0

	ld [hl], $14
	jr jr_057_6fd2

jr_057_6fd0:
	ld [hl], $2d

jr_057_6fd2:
	ld a, [wBattleStep]
	cp $05
	jr z, jr_057_6fe0

	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7129


jr_057_6fe0:
	ld a, [wLinkActive]
	or a
	jp nz, Jump_57_7129

	ld a, [wBattleTemp]
	cp $81
	jp nz, Jump_57_7129

	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	jr z, jr_057_7017

	cp $02
	jr z, jr_057_7012

	cp $01
	jr z, jr_057_700d

	ld hl, $70a9
	jr jr_057_701a

jr_057_700d:
	ld hl, $70c9
	jr jr_057_701a

jr_057_7012:
	ld hl, $70e9
	jr jr_057_701a

jr_057_7017:
	ld hl, $7109

jr_057_701a:
	ld de, $0000
	ld a, [wSkillUser]
	ld bc, wBattlerPersonality3
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $97
	jr c, jr_057_7030

	ld d, $10

jr_057_7030:
	ld a, [wSkillUser]
	ld bc, wBattlerLevel
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $0a
	jr c, jr_057_7050

	cp $14
	jr c, jr_057_704b

	cp $1e
	jr c, jr_057_704a

	inc e

jr_057_704a:
	inc e

jr_057_704b:
	inc e
	ld a, e
	add a
	add a
	ld e, a

jr_057_7050:
	ld a, d
	add e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillUser]
	ld bc, wBattlerPersonality1
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7129


Call_57_7092::
	bit 7, [hl]
	jr nz, jr_057_709e

	ld a, [bc]
	add [hl]
	jr nc, jr_057_70a7

	ld a, $ff
	jr jr_057_70a7

jr_057_709e:
	ld a, [hl]
	cpl
	inc a
	ld d, a
	ld a, [bc]
	sub d
	jr nc, jr_057_70a7

	xor a

jr_057_70a7:
	ld [bc], a
	ret


	db $07, $ff, $00, $03, $05, $ff, $00, $02, $03, $ff, $00, $01, $02, $ff, $00, $01
	db $0a, $ff, $00, $04, $07, $ff, $00, $03, $05, $ff, $00, $02, $05, $00, $00, $01
	db $00, $07, $fe, $03, $00, $05, $fe, $02, $00, $04, $ff, $01, $00, $03, $ff, $01
	db $00, $0a, $fd, $04, $00, $07, $fe, $03, $00, $05, $ff, $02, $00, $05, $00, $01
	db $fe, $00, $07, $03, $fe, $00, $05, $02, $ff, $00, $04, $01, $ff, $00, $03, $01
	db $fe, $00, $0a, $04, $fe, $00, $07, $03, $ff, $00, $05, $02, $00, $00, $05, $01
	db $00, $00, $00, $ff, $00, $00, $00, $fe, $00, $00, $00, $fe, $00, $00, $00, $ff
	db $00, $00, $00, $ff, $00, $00, $00, $fe, $00, $00, $00, $fe, $00, $00, $00, $ff

Jump_57_7129::
	ld a, [wLinkActive]
	or a
	jr z, jr_057_7140

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_057_713b

	ld a, [wOrderFlag0]
	jr jr_057_7143

jr_057_713b:
	ld a, [wOrderFlag1]
	jr jr_057_7143

jr_057_7140:
	ld a, [wMenuChoice]

jr_057_7143:
	cp $81
	jr nz, jr_057_7160

	ld a, [wSkillUser]
	cp $03
	jr z, jr_057_7160

	cp $07
	jr z, jr_057_7160

	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	jr z, jr_057_718c

jr_057_7160:
	call Call_57_71B9
	ld a, [wRunTurn]
	or a
	call z, Call_57_719B
	call Call_57_7322
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_057_7184

	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_73B9


jr_057_7184:
	ld a, $05
	ld [wBattleSubStep2], a
	jp Jump_57_75A2


jr_057_718c:
	ld a, $06
	ld [wBattleSubStep2], a
	jp Jump_57_7859


	db $cd, $2c, $7f, $fa, $99, $c8, $c9

Call_57_719B::
	ld a, [wSkillUser]
	cp $04
	jr nc, jr_057_71a8

	ld a, [wMenuChoice]
	cp $81
	ret z

jr_057_71a8:
	ld a, [wSkillFlags2]
	cp $1e
	jr nc, jr_057_71b3

	ld a, $00
	jr jr_057_71b5

jr_057_71b3:
	sub $1e

jr_057_71b5:
	ld [wSkillFlags2], a
	ret


Call_57_71B9::
	ld c, $00
	ld d, c
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_71c9

	ld a, [wSkillUser]
	cp $03
	jr nc, jr_057_71cf

jr_057_71c9:
	ld d, $01
	ld a, [wNamePos]
	ld c, a

jr_057_71cf:
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld hl, wSkillTargeting
	call Call_57_72CE
	ld a, d
	or a
	jr nz, jr_057_71e8

	jr jr_057_7206

jr_057_71e8:
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_71f3

	ld a, [wMenuChoice]
	jr jr_057_7202

jr_057_71f3:
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_057_71ff

	ld a, [wOrderFlag0]
	jr jr_057_7202

jr_057_71ff:
	ld a, [wOrderFlag1]

jr_057_7202:
	cp $81
	jr z, jr_057_7228

jr_057_7206:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	and $0c
	jr nz, jr_057_7221

	inc hl
	inc hl
	ld a, [hl]
	and $33
	jr z, jr_057_7228

jr_057_7221:
	ld a, $1e
	ld hl, wSkillTargeting
	add [hl]
	ld [hl], a

jr_057_7228:
	ld a, [$db51]
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerStat67
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld hl, wSkillFlags1
	call Call_57_72CE
	ld a, [$db52]
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld hl, wSkillFlags2
	call Call_57_72CE
	ld a, [wSkillUser]
	ld d, a
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	ret nz

	ld a, [wSkillUser]
	cp $04
	jr c, jr_057_7273

	ld a, [wEnemyCount]
	jr jr_057_7276

jr_057_7273:
	ld a, [wPartyBattlers]

jr_057_7276:
	ld b, a
	ld a, [wSkillUser]
	and $04
	ld c, a

jr_057_727d:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_057_7298

	push bc
	call GetBattlerMaxHP
	push hl
	ld a, c
	call GetBattlerHP
	add hl, hl
	ld b, h
	ld c, l
	add hl, bc
	add hl, bc
	pop bc
	call CompareHLBC
	pop bc
	jr c, jr_057_729d

jr_057_7298:
	inc c
	dec b
	jr nz, jr_057_727d

	ret


jr_057_729d:
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, $08

jr_057_72ad:
	ld a, [hli]
	cp $ff
	ret z

	cp $2b
	jr c, jr_057_72c1

	cp $30
	jr c, jr_057_72c6

	cp $93
	jr z, jr_057_72c6

	cp $94
	jr z, jr_057_72c6

jr_057_72c1:
	inc hl
	dec b
	jr nz, jr_057_72ad

	ret


jr_057_72c6:
	ld a, $1e
	ld hl, wSkillFlags2
	add [hl]
	ld [hl], a
	ret


Call_57_72CE::
	push hl
	push de
	ld a, b
	ld [wBattleTemp], a
	call Call_57_78CE
	ld a, c
	add b
	ld b, a
	call Call_57_7F2C
	push bc
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_7316

	ld a, [wSkillUser]
	cp $03
	jr c, jr_057_7316

	ld a, [wBattleTemp]
	cp $32
	jr c, jr_057_730a

	cp $64
	jr c, jr_057_730e

	cp $96
	jr c, jr_057_7312

	cp $c8
	jr c, jr_057_7316

	ld a, $0a
	jr jr_057_7318

jr_057_730a:
	ld a, $1e
	jr jr_057_7318

jr_057_730e:
	ld a, $19
	jr jr_057_7318

jr_057_7312:
	ld a, $14
	jr jr_057_7318

jr_057_7316:
	ld a, $0a

jr_057_7318:
	call Divide16
	pop bc
	pop de
	add b
	ld b, a
	pop hl
	ld [hl], b
	ret


Call_57_7322::
	ld a, $01
	ld [wSkillFlags3], a
	ld a, $02
	ld [$dd00], a
	ld a, $03
	ld [$dd01], a
	ld a, [wSkillTargeting]
	ld l, a
	ld a, [wSkillFlags1]
	ld c, a
	xor a
	ld h, a
	ld b, a
	call CompareHLBC
	jr nc, jr_057_734d

	ld l, c
	ld h, b
	ld a, $02
	ld [wSkillFlags3], a
	ld a, $01
	ld [$dd00], a

jr_057_734d:
	ld a, [wSkillFlags2]
	ld c, a
	ld b, $00
	call CompareHLBC
	jr nc, jr_057_7366

	ld a, [wSkillFlags3]
	ld b, a
	ld a, [$dd01]
	ld [wSkillFlags3], a
	ld a, b
	ld [$dd01], a

jr_057_7366:
	call Call_57_73A5
	call z, Call_57_73B1
	ld a, [$dd01]
	dec a
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $00
	ld a, [$dd00]
	dec a
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	call CompareHLBC
	jr nc, jr_057_739f

	ld a, [$dd00]
	ld b, a
	ld a, [$dd01]
	ld [$dd00], a
	ld a, b
	ld [$dd01], a

jr_057_739f:
	ld a, $03
	ld [$dd02], a
	ret


Call_57_73A5::
	ld a, [$dd00]
	cp $01
	ret z

	ld a, [$dd01]
	cp $01
	ret


Call_57_73B1::
	ld hl, wSkillTargeting
	ld a, $1e
	add [hl]
	ld [hl], a
	ret


Jump_57_73B9::
	ld a, [$dd02]
	cp $06
	jr z, jr_057_73ed

	cp $04
	jr z, jr_057_73f1

	cp $03
	jr z, jr_057_73d9

	ld b, a
	dec a
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr z, jr_057_73ed

	ld a, b

jr_057_73d9:
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [$dd6a], a
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7529


jr_057_73ed:
	ld c, $3a
	jr jr_057_7418

jr_057_73f1:
	ld a, [wSkillFlags3]
	cp $01
	jr z, jr_057_73ed

	cp $03
	ld a, [$dd02]
	jr nz, jr_057_73d9

	ld a, [wBattleSubStep]
	cp $15
	ld a, [$dd02]
	jr nc, jr_057_73ed

	call Call_57_77A4
	ld a, [$dd02]
	jr nz, jr_057_73d9

	call Call_57_77B4
	jr nc, jr_057_73ed

	ld c, $8d

jr_057_7418:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7859


Jump_57_7439::
	ld a, [$c1fe]
	ld l, a
	ld a, [$c1ff]
	ld h, a

Jump_057_7441:
	ld a, [hl]
	or a
	jp z, Jump_057_74ca

	ld a, [$dd6a]
	cp [hl]
	jr nz, jr_057_7487

	xor a
	ld [wAttackWeight], a
	ld [$dd27], a
	inc hl
	ld a, [hl]
	ld [wSkillId], a
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $07
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld [wSkillMsgMode], a
	ld a, [$dd6a]
	dec a
	ld hl, $4302
	call Call_57_4567
	ld a, l
	ld [$c1fa], a
	ld a, h
	ld [$c1fb], a
	ld a, $07
	ld [wBattleSubStep2], a
	ret


jr_057_7487:
	ld a, [$c1fc]
	ld hl, $dce4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hl], a
	ld [wAttackWeight], a
	ld [$dd27], a

Jump_057_749b:
	ld a, [$c1fe]
	ld l, a
	ld a, [$c1ff]
	ld h, a
	inc hl
	inc hl
	ld a, l
	ld [$c1fe], a
	ld a, h
	ld [$c1ff], a
	ld a, [$c1fc]
	ld c, a
	ld a, [$c1fd]
	ld b, a
	inc c
	dec b
	ld a, c
	ld [$c1fc], a
	ld a, b
	ld [$c1fd], a
	jp nz, Jump_057_7441

jr_057_74c2:
	ld a, $05
	ld [wBattleSubStep2], a
	jp Jump_57_75A2


Jump_057_74ca:
	ld a, [$c1fc]
	ld hl, $dce4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a

jr_057_74d7:
	ld [hli], a
	dec b
	jr nz, jr_057_74d7

	jr jr_057_74c2

	db $e5, $d5, $c5, $7e, $ea, $8a, $db, $ea, $4c, $db, $3e, $00, $ea, $4d, $db, $3e
	db $07, $ea, $4e, $db, $21, $00, $54, $d7, $fa, $4c, $db, $ea, $6b, $dd, $fa, $6a
	db $dd, $3d, $21, $02, $43, $cd, $67, $45, $cd, $0c, $75, $c1, $d1, $e1, $c9, $2a
	db $57, $3a, $b2, $28, $12, $e5, $cd, $25, $75, $e1, $fa, $27, $dd, $fe, $ff, $28
	db $06, $23, $23, $e5, $e1, $18, $e8, $c9, $2a, $66, $6f, $e9

Jump_57_7529::
	ld bc, $0800
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_057_753a:
	ld a, [hl]
	cp $ff
	jr z, jr_057_7574

	push hl
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $03
	ld [wBattleArg2], a
	push bc
	ld hl, far_GetSkillWord
	rst $10
	pop bc
	ld a, c
	ld hl, $dce4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	add [hl]
	ld [hl], a
	jr nc, jr_057_7566

	ld [hl], $ff

jr_057_7566:
	push hl
	ld a, $10
	call Call_57_7A93
	pop hl
	add [hl]
	ld [hl], a
	jr nc, jr_057_7573

	ld [hl], $ff

jr_057_7573:
	pop hl

jr_057_7574:
	inc hl
	inc hl
	inc c
	dec b
	jr nz, jr_057_753a

	ld hl, wBattleSubStep2
	inc [hl]
	ld bc, $0800
	ld a, c
	ld [$c1fc], a
	ld a, b
	ld [$c1fd], a
	ld a, [wSkillUser]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [$c1fe], a
	ld a, h
	ld [$c1ff], a
	jp Jump_57_7439


Jump_57_75A2::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jp nz, Jump_057_76bd

	inc hl
	inc hl
	inc hl
	inc hl
	bit 2, [hl]
	jp nz, Jump_057_76b5

	inc hl
	bit 4, [hl]
	jp nz, Jump_057_76c5

	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jp z, Jump_057_76df

	ld hl, $dce4
	ld bc, $0701
	ld d, [hl]
	inc hl
	ld e, $00

jr_057_75da:
	ld a, d
	or a
	jr nz, jr_057_75ec

	ld a, [hli]
	ld d, a
	inc e
	inc c
	dec b
	jr nz, jr_057_75da

	ld a, d
	or a
	jp z, Jump_057_76a9

	jr jr_057_75fa

jr_057_75ec:
	ld a, [hl]
	cp d
	jp z, Jump_057_769b

	jr c, jr_057_75f5

Jump_057_75f3:
	ld d, [hl]
	ld e, c

Jump_057_75f5:
jr_057_75f5:
	inc hl
	inc c
	dec b
	jr nz, jr_057_75ec

jr_057_75fa:
	ld a, [$dd02]
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr z, jr_057_7650

	cp $02
	jr z, jr_057_762e

	ld a, d
	cp $14
	jr nc, jr_057_7632

	ld a, [wBattleSubStep]
	cp $15
	jp nc, Jump_057_76a9

	call Call_57_77A4
	jp nz, Jump_057_76a9

	call Call_57_77B4
	jp nc, Jump_057_7686

	call Call_57_76CD
	ld [hl], $8d
	ret


jr_057_762e:
	ld a, d
	or a
	jr z, jr_057_76a9

jr_057_7632:
	call Call_57_76CD
	push hl
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ld [hl], a
	ret


jr_057_7650:
	push de
	ld hl, far_AIAttackWeight
	rst $10
	ld a, [wAttackWeight]
	pop de
	cp d
	jr nc, jr_057_7686

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	cp $ff
	jr nz, jr_057_7695

Jump_057_7686:
jr_057_7686:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a

jr_057_7695:
	ld [hl], a
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_057_769b:
	call Call_57_7F2C
	ld a, [wRandomHigh]
	bit 0, a
	jp z, Jump_057_75f5

	jp Jump_057_75f3


Jump_057_76a9:
jr_057_76a9:
	ld hl, $dd02
	inc [hl]
	ld a, $02
	ld [wBattleSubStep2], a
	jp Jump_57_73B9


Jump_057_76b5:
	call Call_57_76CD
	ld [hl], $42
	jp Jump_57_7859


Jump_057_76bd:
	call Call_57_76CD
	ld [hl], $3a
	jp Jump_57_7859


Jump_057_76c5:
	call Call_57_76CD
	ld [hl], $95
	jp Jump_57_7859


Call_57_76CD::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


Jump_057_76df:
	ld b, $0a
	ld hl, wSkillStatusPtr
	xor a

jr_057_76e5:
	ld [hli], a
	dec b
	jr nz, jr_057_76e5

jr_057_76e9:
	ld a, [$dd02]
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld d, [hl]
	ld e, $00
	ld hl, wBattlerSkills
	ld a, [wSkillUser]
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld bc, $0800

jr_057_7709:
	ld a, [hli]
	cp d
	jr nz, jr_057_7724

	push hl
	call Call_57_7F2C
	ld hl, wSkillStatusPtr
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wRandomHigh]
	and $07
	inc a
	ld [hl], a
	pop hl
	inc e

jr_057_7724:
	inc hl
	inc c
	dec b
	jr nz, jr_057_7709

	call Call_57_7F2C
	ld a, d
	cp $02
	jr z, jr_057_7741

	ld hl, $db69
	cp $01
	jr z, jr_057_7739

	inc hl

jr_057_7739:
	ld a, [wRandomLow]
	and $07
	inc a
	ld [hl], a
	inc e

jr_057_7741:
	ld a, e
	or a
	jr nz, jr_057_7761

	ld a, d
	cp $02
	jr nz, jr_057_7750

	ld hl, $dd02
	inc [hl]
	jr jr_057_76e9

jr_057_7750:
	cp $03
	jr z, jr_057_7758

jr_057_7754:
	ld b, $3a
	jr jr_057_77a0

jr_057_7758:
	call Call_57_77A4
	jr nz, jr_057_7754

	ld b, $8d
	jr jr_057_77a0

jr_057_7761:
	ld bc, $0a00
	ld hl, wSkillStatusPtr

jr_057_7767:
	ld a, [hli]
	or a
	jr nz, jr_057_7773

	inc c
	dec b
	jr nz, jr_057_7767

	ld b, $3a
	jr jr_057_77a0

jr_057_7773:
	ld d, a
	ld e, c
	inc c

jr_057_7776:
	ld a, [hli]
	cp d
	jr c, jr_057_777c

	ld d, a
	ld e, c

jr_057_777c:
	inc c
	dec b
	jr nz, jr_057_7776

	ld a, e
	cp $09
	jr nc, jr_057_7758

	cp $08
	jr z, jr_057_7754

	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]

jr_057_77a0:
	call Call_57_76CD
	ld [hl], b

Call_57_77A4::
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	ret


Call_57_77B4::
	ld a, [wSkillUser]
	ld c, a
	and $03
	cp $03
	jr z, jr_057_77f2

	ld a, [wLinkActive]
	or a
	jr nz, jr_057_77c8

	bit 2, c
	jr nz, jr_057_77f2

jr_057_77c8:
	ld a, c
	xor $04
	and $04
	ld c, a
	call Call_57_77F5
	jr nc, jr_057_77f0

	inc c
	call Call_57_77F5
	jr nc, jr_057_77f0

	inc c
	call Call_57_77F5
	jr nc, jr_057_77f0

	call Call_57_7828
	jr nc, jr_057_77f2

	dec c
	call Call_57_7828
	jr nc, jr_057_77f2

	dec c
	call Call_57_7828
	jr nc, jr_057_77f2

jr_057_77f0:
	scf
	ret


jr_057_77f2:
	scf
	ccf
	ret


Call_57_77F5::
	ld a, c
	call CheckBattlerPresent
	ret c

	push bc
	ld a, c
	ld hl, wBattlerAttack
	call Call_57_4567
	push hl
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call Call_57_4567
	srl h
	rr l
	push hl
	ld a, [wSkillUser]
	ld hl, wBattlerDefense
	call Call_57_4567
	srl h
	rr l
	pop bc
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	call CompareHLBC
	pop bc
	ret


Call_57_7828::
	ld a, c
	call CheckBattlerPresent
	ret c

	push bc
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call Call_57_4567
	push hl
	ld a, c
	ld hl, wBattlerMaxHP
	call Call_57_4567
	srl h
	rr l
	push hl
	ld a, c
	ld hl, wBattlerDefense
	call Call_57_4567
	srl h
	rr l
	pop bc
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	call CompareHLBC
	pop bc
	ret


Jump_57_7859::
	ld a, [wSkillUser]
	xor a
	ld [wBattleSubStep2], a
	ld hl, wBattleSubStep
	inc [hl]
	ret


Jump_57_7865::
	ld a, [$c1fa]
	ld l, a
	ld a, [$c1fb]
	ld h, a

jr_057_786d:
	ld a, [hli]
	ld d, a
	ld a, [hld]
	or d
	jr z, jr_057_78a2

	push hl
	call Call_57_78CA
	pop hl
	ld a, [$dd27]
	cp $ff
	jr z, jr_057_788b

	inc hl
	inc hl
	ld a, l
	ld [$c1fa], a
	ld a, h
	ld [$c1fb], a
	jr jr_057_786d

jr_057_788b:
	xor a
	ld [wAttackWeight], a
	ld [$dd27], a
	ld a, [$c1fc]
	ld hl, $dce4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	jr jr_057_78c1

jr_057_78a2:
	ld a, [$c1fc]
	ld hl, $dce4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [$dd27]
	cp $ff
	jr z, jr_057_788b

	ld e, a
	ld a, [wAttackWeight]
	sub e
	jr c, jr_057_788b

	ld [wAttackWeight], a
	add [hl]
	ld [hl], a

jr_057_78c1:
	ld a, $04
	ld [wBattleSubStep2], a
	jp Jump_057_749b


	db $c9

Call_57_78CA::
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


Call_57_78CE::
	ld a, $0a
	call Divide8
	ret


Call_57_78D4::
	cp $03
	jr z, jr_057_78e5

	cp $02
	jr z, jr_057_78f0

	cp $01
	jr z, jr_057_78eb

	ld hl, wBattlerPersonality1
	jr jr_057_78f3

jr_057_78e5:
	ld a, $00
	ld [wBattleArg0], a
	ret


jr_057_78eb:
	ld hl, wBattlerStat67
	jr jr_057_78f3

jr_057_78f0:
	ld hl, wBattlerPersonality2

jr_057_78f3:
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call Call_57_78CE
	ld a, b
	ld [wBattleArg0], a
	ret


Call_57_7905::
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call Call_57_78CE
	ld a, b
	ld [wBattleArg1], a
	ret


Call_57_791A::
	ld b, $00
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $c0
	jr nc, jr_057_7937

	cp $40
	jr nc, jr_057_7935

	ld b, $12
	jr jr_057_7937

jr_057_7935:
	ld b, $09

jr_057_7937:
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $c0
	jr nc, jr_057_7954

	cp $40
	jr nc, jr_057_7950

	ld a, $06
	jr jr_057_7952

jr_057_7950:
	ld a, $03

jr_057_7952:
	add b
	ld b, a

jr_057_7954:
	ld a, [wSkillUser]
	ld hl, wBattlerStat67
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $c0
	jr nc, jr_057_7970

	cp $40
	jr nc, jr_057_796f

	inc b
	inc b
	ld a, $02
	jr jr_057_7970

jr_057_796f:
	inc b

jr_057_7970:
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]

jr_057_797d:
	ld a, c
	or a
	jr z, jr_057_7988

	ld a, $1b
	add b
	ld b, a
	dec c
	jr jr_057_797d

jr_057_7988:
	add b
	ld hl, $7997
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleItemUsedUp], a
	ret


	db $19, $19, $19, $14, $14, $19, $19, $19, $19, $14, $0f, $0a, $14, $14, $14, $14
	db $0f, $14, $05, $0f, $0a, $14, $0a, $0a, $14, $05, $05, $14, $0a, $05, $14, $05
	db $0a, $0f, $0a, $05, $19, $14, $19, $19, $0f, $14, $14, $14, $0a, $19, $0f, $0a
	db $14, $0a, $14, $19, $0f, $05, $14, $05, $05, $14, $05, $0a, $05, $0f, $05, $19
	db $14, $19, $19, $14, $14, $14, $0a, $0a, $19, $14, $0a, $0f, $0a, $0a, $0f, $19
	db $05, $14, $05, $05, $05, $05, $0a, $05, $05, $05, $19, $0f, $0a, $19, $14, $0a
	db $05, $05, $05, $19, $14, $0f, $14, $14, $19, $14, $19, $05

Call_57_7A03::
	ld a, [wSkillUser]
	ld hl, wBattlerWildness
	call Call_57_45EA
	ld b, [hl]
	srl b
	srl b
	ld a, b
	ld [wBattleArg2], a
	ret


Call_57_7A16::
	ld a, [wSkillUser]
	ld hl, wBattlerWildness
	call Call_57_45EA
	ld a, [hl]
	cp $20
	jr c, jr_057_7a38

	cp $40
	jr c, jr_057_7a3c

	cp $60
	jr c, jr_057_7a40

	cp $90
	jr c, jr_057_7a44

	cp $c0
	jr c, jr_057_7a48

	ld b, $0f
	jr jr_057_7a4a

jr_057_7a38:
	ld b, $05
	jr jr_057_7a4a

jr_057_7a3c:
	ld b, $07
	jr jr_057_7a4a

jr_057_7a40:
	ld b, $09
	jr jr_057_7a4a

jr_057_7a44:
	ld b, $0b
	jr jr_057_7a4a

jr_057_7a48:
	ld b, $0d

jr_057_7a4a:
	call Call_57_7F2C
	ld a, [wRandomHigh]
	and $3f

jr_057_7a52:
	cp b
	jr c, jr_057_7a59

	sub b
	jr nz, jr_057_7a52

	ld a, b

jr_057_7a59:
	ld [wBattleArg3], a
	ret


Call_57_7A5D::
	ld a, [wSkillUser]
	add a
	ld hl, wBattlerWildness
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_057_7a8e

	cp $15
	jr c, jr_057_7a8e

	cp $f0
	jr nc, jr_057_7a91

	ld a, [wBattleArg2]
	ld b, a
	ld a, [wBattleArg3]
	add b
	ld b, a
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	add c
	ld c, a
	ld a, [wBattleItemUsedUp]
	add c
	sub b
	ret


jr_057_7a8e:
	scf
	ccf
	ret


jr_057_7a91:
	scf
	ret


Call_57_7A93::
	push bc
	push af
	call Call_57_7F2C
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	pop af
	call Divide16
	pop bc
	ret


	db $fa, $4c, $db, $67, $7b, $b7, $28, $0a, $fe, $01, $28, $0a, $fe, $02, $28, $0a
	db $7c, $c9, $7c, $07, $07, $c9, $7c, $cb, $37, $c9, $7c, $0f, $0f, $c9, $c5, $fa
	db $56, $db, $6f, $fa, $57, $db, $67, $2a, $66, $6f, $e5, $fa, $58, $db, $6f, $fa
	db $59, $db, $67, $2a, $66, $6f, $7c, $b7, $20, $0f, $7d, $0f, $0f, $e6, $3f, $b7
	db $28, $03, $6f, $18, $0c, $2e, $01, $18, $0c, $cb, $2c, $cb, $1d, $cb, $2c, $cb
	db $1d, $44, $4d, $29, $09, $c1, $cd, $45, $2f, $c1, $c9, $c5, $fa, $56, $db, $6f
	db $fa, $57, $db, $67, $2a, $66, $6f, $e5, $fa, $58, $db, $6f, $fa, $59, $db, $67
	db $2a, $66, $6f, $7c, $b7, $20, $0e, $7d, $0f, $e6, $7f, $b7, $28, $03, $6f, $18
	db $08, $2e, $01, $18, $04, $cb, $2c, $cb, $1d, $c1, $cd, $45, $2f, $c1, $c9, $c5
	db $fa, $56, $db, $6f, $fa, $57, $db, $67, $2a, $46, $4f, $c5, $fa, $58, $db, $6f
	db $fa, $59, $db, $67, $2a, $66, $6f, $01, $04, $00, $cd, $4b, $2f, $c1, $cd, $45
	db $2f, $c1, $c9, $c5, $fa, $56, $db, $6f, $fa, $57, $db, $67, $2a, $46, $4f, $c5
	db $fa, $58, $db, $6f, $fa, $59, $db, $67, $2a, $66, $6f, $01, $0a, $00, $cd, $4b
	db $2f, $c1, $cd, $45, $2f, $c1, $c9, $79, $21, $65, $dc, $cb, $37, $85, $6f, $3e
	db $00, $8c, $67, $16, $08, $2a, $fe, $ff, $28, $14, $fe, $5c, $38, $0c, $fe, $64
	db $38, $10, $fe, $6a, $38, $04, $fe, $6e, $38, $08, $23, $15, $20, $e7, $3e, $01
	db $b7, $c9, $af, $c9, $fe, $03, $30, $0e, $e5, $21, $c2, $ca, $cd, $29, $22, $5d
	db $54, $e1, $cd, $80, $0c, $c9, $f5, $ea, $60, $db, $e5, $21, $3c, $dc, $85, $6f
	db $3e, $00, $8c, $67, $7e, $6f, $26, $05, $d1, $7b, $ea, $5e, $db, $7a, $ea, $5f
	db $db, $cd, $7a, $09, $f1, $21, $04, $51, $d7, $c9, $f5, $c5, $d5, $e5, $fa, $88
	db $db, $21, $05, $db, $cd, $6c, $2f, $7e, $e6, $c0, $77, $e1, $d1, $c1, $f1, $c9
	db $7e, $e6, $0c, $28, $14, $fe, $04, $28, $0c, $fe, $08, $28, $04, $06, $60, $18
	db $0a, $06, $a0, $18, $06, $06, $e0, $18, $02, $06, $ff, $fa, $99, $c8, $b8, $28
	db $1c, $38, $1a, $7e, $e6, $f3, $47, $7e, $e6, $0c, $3d, $c5, $f5, $c1, $cb, $69
	db $c1, $20, $04, $e6, $0c, $18, $01, $af, $b0, $77, $3e, $0f, $c9, $7e, $e6, $73
	db $77, $fa, $88, $db, $ea, $89, $db, $21, $04, $50, $d7, $3e, $db, $c9

Call_57_7C44::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 0, [hl]
	jr nz, jr_057_7c52

	ret


jr_057_7c52:
	ld a, [wSkillId]
	cp $52
	jr z, jr_057_7c62

	cp $53
	jr z, jr_057_7c62

	cp $ab
	jr z, jr_057_7c66

	ret


jr_057_7c62:
	ld a, $03
	jr jr_057_7c68

jr_057_7c66:
	ld a, $08

jr_057_7c68:
	ld [wReflectAnim], a
	res 0, [hl]
	ret


	db $fa, $88, $db, $21, $0b, $dd, $85, $6f, $3e, $00, $8c, $67, $7e, $fe, $02, $c9
	db $fa, $8a, $db, $fe, $3b, $28, $2e, $fe, $3d, $28, $2a, $fe, $42, $28, $26, $fe
	db $44, $38, $20, $fe, $4f, $28, $1c, $fe, $52, $38, $1a, $fe, $55, $38, $14, $fe
	db $58, $38, $12, $fe, $67, $38, $0c, $fe, $6a, $38, $0a, $fe, $d6, $38, $04, $fe
	db $d9, $38, $02, $af, $c9, $37, $c9, $fa, $8a, $db, $fe, $3b, $28, $22, $fe, $3d
	db $28, $1e, $fe, $3f, $28, $1a, $fe, $40, $28, $16, $fe, $42, $28, $12, $fe, $50
	db $28, $0e, $fe, $51, $28, $0a, $fe, $55, $38, $04, $fe, $58, $38, $02, $af, $c9
	db $37, $c9, $fa, $8a, $db, $fe, $14, $38, $16, $fe, $4f, $28, $12, $fe, $52, $28
	db $0e, $fe, $53, $28, $0a, $fe, $58, $38, $04, $fe, $66, $38, $02, $af, $c9, $37
	db $c9, $fa, $88, $db, $21, $a3, $db, $cd, $67, $45, $44, $4d, $09, $09, $e5, $fa
	db $88, $db, $21, $b3, $db, $cd, $67, $45, $29, $c1, $cd, $45, $2f, $c9, $c9, $fa
	db $88, $db, $21, $d3, $db, $cd, $ea, $45, $2a, $46, $4f, $cb, $38, $cb, $19, $fa
	db $88, $db, $cd, $ef, $2f, $cd, $45, $2f, $c9, $fa, $88, $db, $21, $b3, $db, $cd
	db $ea, $45, $2a, $46, $4f, $fa, $88, $db, $cd, $e1, $2f, $cd, $45, $2f, $c9, $cd
	db $73, $7d, $af, $ea, $54, $db, $21, $55, $db, $34, $79, $ea, $89, $db, $7a, $ea
	db $4c, $db, $d5, $c5, $21, $06, $52, $d7, $c1, $d1, $cd, $a6, $7a, $e6, $03, $21
	db $54, $db, $86, $77, $c9, $fa, $8a, $db, $ea, $4c, $db, $3e, $00, $ea, $4d, $db
	db $3e, $05, $ea, $4e, $db, $21, $00, $54, $d7, $fa, $4c, $db, $e6, $03, $5f, $fa
	db $4c, $db, $0f, $0f, $e6, $0f, $57, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06
	db $03, $af, $ea, $55, $db, $c9, $21, $55, $db, $34, $79, $ea, $89, $db, $7a, $ea
	db $4c, $db, $d5, $c5, $21, $06, $52, $d7, $c1, $d1, $cd, $a6, $7a, $e6, $03, $c9
	db $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $11, $00, $00, $7b, $ea, $56
	db $db, $7a, $ea, $57, $db, $79, $cd, $a5, $2f, $38, $12, $79, $21, $f3, $db, $cd
	db $ea, $45, $fa, $56, $db, $86, $22, $fa, $57, $db, $8e, $77, $14, $0c, $05, $20
	db $e4, $7a, $fe, $01, $c8, $fe, $02, $28, $14, $fa, $56, $db, $6f, $fa, $57, $db
	db $67, $cd, $0d, $1e, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $c9, $fa, $56, $db
	db $6f, $fa, $57, $db, $67, $cb, $2c, $cb, $1d, $7d, $ea, $56, $db, $7c, $ea, $57
	db $db, $c9, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $11, $00, $00, $7b
	db $ea, $58, $db, $7a, $ea, $59, $db, $79, $cd, $a5, $2f, $38, $12, $79, $21, $f3
	db $db, $cd, $ea, $45, $fa, $58, $db, $86, $22, $fa, $59, $db, $8e, $77, $14, $0c
	db $05, $20, $e4, $7a, $fe, $01, $c8, $fe, $02, $28, $14, $fa, $58, $db, $6f, $fa
	db $59, $db, $67, $cd, $0d, $1e, $7d, $ea, $58, $db, $7c, $ea, $59, $db, $c9, $fa
	db $58, $db, $6f, $fa, $59, $db, $67, $cb, $2c, $cb, $1d, $7d, $ea, $58, $db, $7c
	db $ea, $59, $db, $c9

Call_57_7E82::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	call Call_57_6D09
	ret


	db $c5, $e5, $21, $65, $dc, $cd, $ca, $7f, $06, $08, $2a, $fe, $ff, $28, $14, $fe
	db $3a, $38, $14, $fe, $d5, $28, $10, $fe, $da, $28, $0c, $fe, $dc, $28, $08, $23
	db $05, $20, $e7, $e1, $c1, $37, $c9, $e1, $c1, $af, $b7, $c9, $c5, $e5, $21, $65
	db $dc, $cd, $ca, $7f, $06, $08, $2a, $fe, $ff, $28, $1c, $fe, $43, $28, $1c, $fe
	db $5c, $38, $10, $fe, $64, $38, $14, $fe, $6a, $38, $08, $fe, $6e, $38, $0c, $fe
	db $8f, $28, $08, $23, $05, $20, $df, $e1, $c1, $37, $c9, $e1, $c1, $af, $b7, $c9
	db $c5, $e5, $21, $65, $dc, $cd, $ca, $7f, $06, $08, $2a, $fe, $ff, $28, $20, $fe
	db $6e, $28, $20, $fe, $71, $28, $1c, $fe, $75, $38, $10, $fe, $79, $38, $14, $fe
	db $91, $28, $10, $fe, $94, $28, $0c, $fe, $96, $28, $08, $23, $05, $20, $db, $e1
	db $c1, $37, $c9, $e1, $c1, $af, $b7, $c9

Call_57_7F2C::
	push bc
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_7f38

	call Random
	jr jr_057_7f5d

jr_057_7f38:
	push hl
	ld a, [wLinkRandom]
	ld l, a
	ld a, [$c1ee]
	ld h, a
	ld a, l
	ld [wRandomHigh], a
	ld a, h
	ld [wRandomLow], a
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, l
	ld [wLinkRandom], a
	ld a, h
	ld [$c1ee], a
	pop hl

jr_057_7f5d:
	pop bc
	ret


Call_57_7F5F::
	ld hl, wBattleArg0
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality1
	call Call_57_7FC2
	ld [wBattleArg1], a
	cp $3f
	jr c, jr_057_7f7c

	ld a, $01
	ld [wBattleArg0], a

jr_057_7f7c:
	ld a, [wSkillUser]
	ld hl, wBattlerStat67
	call Call_57_7FC2
	ld [wBattleArg2], a
	cp $3f
	jr c, jr_057_7f91

	ld hl, wBattleArg0
	set 1, [hl]

jr_057_7f91:
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality2
	call Call_57_7FC2
	ld [wBattleArg3], a
	cp $3f
	jr c, jr_057_7fa6

	ld hl, wBattleArg0
	set 2, [hl]

jr_057_7fa6:
	ld b, $98
	ld a, [wBattleArg0]
	or a
	ret z

	ld b, $3a
	bit 0, a
	jr z, jr_057_7fbf

	ld a, [wBattleArg1]
	ld hl, wBattleArg2
	cp [hl]
	jr c, jr_057_7fbf

	inc hl
	cp [hl]
	ret nc

jr_057_7fbf:
	ld b, $8d
	ret


Call_57_7FC2::
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


	db $87, $87, $87, $cd, $ea, $45, $c9, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00
