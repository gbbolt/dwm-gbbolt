INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $050", ROMX[$4000], BANK[$50]

;@ path: battle/flow
;@ Bank number byte that FarCall reads to know which bank is switched in.
BankNumber_50::
	db $50

;@ path: battle/flow
;@ Far-call entry points of bank $50 (the battle mode): 0 battle init, 1 battle frame
;@ with the link and animation work, 2 battle frame logic, 3 redraw the battle windows,
;@ 4 status icon update, 5 copy the screen buffer, 6 HP/MP numbers, 7 the message that
;@ announces an action, 8 to 10 battle messages that end a menu or the battle.
FarTable_50::
	dw Call_50_5DC9
	dw Call_50_5E21
	dw Call_50_5E49
	dw Call_50_6053
	dw UpdateStatusIcon_50
	dw CopyTilemapBufferToScreen_50
	dw PrintPanelHPMP
	dw Call_50_59EB
	dw Call_50_5B58
	dw Call_50_5C78
	dw Call_50_5CB4

Call_50_4017::
	ld a, [wCommandStep]
	rst $00

JumpTable_50_401B::
	dw Jump_50_4031
	dw Jump_50_40ED
	dw Jump_50_4114
	dw Jump_50_41EE
	dw Jump_50_4215
	dw Jump_50_425E
	dw Jump_50_426E
	dw Jump_50_4301
	dw Jump_50_43A7
	dw Jump_50_41E0
	dw Jump_50_59D6

Jump_50_4031::
	ld hl, far_Call_55_479B
	rst $10
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
	ld a, $ff
	ld [wPartyBarTiles], a
	ld bc, $0300
	ld a, [wLinkActive]
	or a
	jr z, jr_050_4062

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4062

	ld bc, $0304

jr_050_4062:
	ld d, $00

jr_050_4064:
	ld a, c
	call Call_50_5B07
	jr c, jr_050_4081

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_050_4081

	inc d
	ld a, [wPartyBarTiles]
	cp $ff
	jr nz, jr_050_4081

	ld a, c
	ld [wPartyBarTiles], a

jr_050_4081:
	inc c
	dec b
	jr nz, jr_050_4064

	ld a, d
	ld [wSkillUser], a
	ld bc, $0404
	ld a, [wLinkActive]
	or a
	jr z, jr_050_409c

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_409c

	ld bc, $0400

jr_050_409c:
	ld d, $00

jr_050_409e:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_40a5

	inc d

jr_050_40a5:
	inc c
	dec b
	jr nz, jr_050_409e

	ld a, d
	ld [wSkillTarget], a
	ld b, $08
	ld hl, wBattlerMenuMemory

jr_050_40b2:
	set 7, [hl]
	inc hl
	dec b
	jr nz, jr_050_40b2

	ld hl, wCommandStep
	inc [hl]
	ld bc, $0300
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_40c8

	ld c, $04

jr_050_40c8:
	ld a, c
	ld [wSkillStatusPtr], a

jr_050_40cc:
	ld a, c
	call CheckBattlerCanAct
	jr c, jr_050_40e8

	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hli]
	and $0c
	jr z, jr_050_40e8

	ld a, [hl]
	and $f0
	jr z, jr_050_40e8

	ld a, c
	ld [wSkillStatusPtr], a
	ret


jr_050_40e8:
	inc c
	dec b
	jr nz, jr_050_40cc

	ret


Jump_50_40ED::
	ld hl, far_Call_55_4774
	rst $10
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $6ed2
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $419b
	ld a, [wMenuChoice]
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_4114::
	ld a, [wJoyPressed]
	and $08
	jr z, jr_050_412d

	ld a, [wPanelMode]
	or a
	jr nz, jr_050_4124

	inc a
	jr jr_050_4126

jr_050_4124:
	ld a, $03

jr_050_4126:
	ld [wPanelMode], a
	call DrawPanelConditions
	ret


jr_050_412d:
	ld de, $419b
	ld hl, wMenuChoice
	call UpdateGridCursor_50
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_050_419a

	ld a, $59
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	xor a
	ld [wCommandSubStep], a
	ld hl, wMenuChoice
	set 7, [hl]
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory
	ld a, [wMenuChoice]
	and $0f
	cp $01
	ret nz

	ld hl, far_Call_55_479B
	rst $10
	xor a
	ld [wConfirmChoice2], a
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4176

	ld a, $04
	ld [wConfirmChoice2], a

jr_050_4176:
	call Call_50_41A5
	jr nc, jr_050_41b9

	ld a, [wPartyBarTiles]
	ld [wConfirmChoice2], a
	ld hl, wCommandSubStep
	inc [hl]
	ld hl, wCommandSubStep
	inc [hl]
	call Call_50_5708
	ld hl, wCommandSubStep
	inc [hl]
	ld a, $81
	ld [wMenuChoice2], a
	ld a, $01
	ld [wTacticMenuRow], a

jr_050_419a:
	ret


BattleMenuCursors::
	db $c1, $01, $01, $02, $c7, $01, $07, $02, $ff, $ff

Call_50_41A5::
	ld a, [wConfirmChoice2]
	ld c, a
	ld b, $03

jr_050_41ab:
	ld a, c
	call Call_50_5B07
	jr nc, jr_050_41b7

	inc c
	dec b
	jr nz, jr_050_41ab

	xor a
	ret


jr_050_41b7:
	scf
	ret


jr_050_41b9:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $0002
	ld a, $09
	ld [wCommandStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_41E0::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $01
	ld [wCommandStep], a
	ret


Jump_50_41EE::
	ld a, [wJoyPressed]
	and $08
	jr z, jr_050_4207

	ld a, [wPanelMode]
	or a
	jr nz, jr_050_41fe

	inc a
	jr jr_050_4200

jr_050_41fe:
	ld a, $03

jr_050_4200:
	ld [wPanelMode], a
	call DrawPanelConditions
	ret


jr_050_4207:
	ld a, [wMenuChoice]
	rst $00

JumpTable_50_420B::
	dw Jump_50_43C8
	dw Jump_50_441B
	dw Jump_50_4FBB
	dw Jump_50_5712
	dw Jump_50_4794

Jump_50_4215::
	ld a, [wPanelMode]
	or a
	jr z, jr_050_4224

	ld a, $03
	ld [wPanelMode], a
	call DrawPanelLetters
	ret


jr_050_4224:
	ld a, [wLinkActive]
	or a
	jr z, jr_050_4259

	ld a, $01
	ld [wLinkNoEnd], a
	ld de, wMonMaster
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_423c

	ld de, $cd21

jr_050_423c:
	ld hl, wTextArg0
	call CopyName
	ld a, $f6
	call Call_50_6AA0
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawMessageWindowAndPanel
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50

jr_050_4259:
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_425E::
	ld a, [wLinkActive]
	or a
	jr z, jr_050_4269

	ld a, $01
	ld [wLinkSendByte], a

jr_050_4269:
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_426E::
	ld a, [wLinkActive]
	or a
	jp z, Jump_050_42fc

	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

	ld de, wBattlerTactic
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4288

	ld de, $dd07

jr_050_4288:
	ld hl, wLinkTurnOut
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, [wRandomHigh]
	ld [hli], a
	ld a, [wRandomLow]
	ld [hli], a
	ld a, [wMenuChoice]
	ld [hli], a
	ld a, [wMenuChoice]
	ld [hli], a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_42af

	ld de, wBattlerAction
	jr jr_050_42b2

jr_050_42af:
	ld de, $dcf4

jr_050_42b2:
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
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld de, wBattlerOrder
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_42d0

	ld de, $dd17

jr_050_42d0:
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, $10
	ld [wLinkSendLength], a
	xor a
	ld [$c872], a
	ld hl, wLinkTurnOut
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [$c875], a
	ld hl, wLinkTurnIn
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [$c870], a
	ld a, $ff
	ld [wLinkSendByte], a

Jump_050_42fc:
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_4301::
	ld a, [wLinkActive]
	or a
	jp z, Jump_050_43a2

	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

	xor a
	ld [wLinkSendByte], a
	ld de, $dd07
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_431f

	ld de, wBattlerTactic

jr_050_431f:
	ld hl, wLinkTurnIn
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc hl
	inc hl
	ld a, [hli]
	ld [wOrderFlag0], a
	ld a, [hli]
	ld [wOrderFlag1], a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_4340

	ld de, $dcf4
	jr jr_050_4343

jr_050_4340:
	ld de, wBattlerAction

jr_050_4343:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld de, $dd17
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4361

	ld de, wBattlerOrder

jr_050_4361:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_438a

	ld a, [wRandomHigh]
	ld [wLinkRandom], a
	ld a, [wRandomLow]
	ld [$c1ee], a
	ld a, [wMenuChoice]
	ld [$c1ef], a
	ld a, [wMenuChoice]
	ld [wOrderFlag0], a
	jr jr_050_43a2

jr_050_438a:
	ld a, [wLinkRandom]
	ld [wRandomHigh], a
	ld a, [$c1ee]
	ld [wRandomLow], a
	ld a, [wMenuChoice]
	ld [$c1f0], a
	ld a, [wMenuChoice]
	ld [wOrderFlag1], a

Jump_050_43a2:
jr_050_43a2:
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_43A7::
	ld hl, far_Call_56_4485
	rst $10
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawMessageWindowAndPanel
	call CopyTilemapBufferToScreen_50
	xor a
	ld [wSkillUser], a
	xor a
	ld [wLinkNoEnd], a
	xor a
	ld [wCommandStep], a
	ld hl, wBattleStep
	inc [hl]
	ret


Jump_50_43C8::
	ld a, [wCommandSubStep]
	rst $00

JumpTable_50_43CC::
	dw Jump_50_43D0
	dw Jump_50_4411

Jump_50_43D0::
	ld hl, wCommandSubStep
	inc [hl]
	ld a, [wPartyBattlers]
	ld b, a
	ld c, $00
	ld hl, wBattlerOrder
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_43ed

	ld a, [wEnemyCount]
	ld b, a
	ld c, $04
	ld hl, $dd17

jr_050_43ed:
	ld a, c
	ld [wBattleTemp], a
	ld a, b
	ld [wBattleTempHigh], a

jr_050_43f5:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_43ff

	ld [hl], $01
	jr jr_050_4401

jr_050_43ff:
	ld [hl], $ff

jr_050_4401:
	inc hl
	inc c
	dec b
	jr nz, jr_050_43f5

	ld a, $ff
	ld [wBattleItemTarget], a
	ld a, $ff
	ld [wBattleItemEffect], a
	ret


Jump_50_4411::
	ld a, $04
	ld [wCommandStep], a
	xor a
	ld [wCommandSubStep], a
	ret


Jump_50_441B::
	ld a, [wCommandSubStep]
	rst $00

JumpTable_50_441F::
	dw Jump_50_442B
	dw Jump_50_443A
	dw Jump_50_446E
	dw Jump_50_44B0
	dw Jump_50_456F
	dw Jump_50_4751

Jump_50_442B::
	ld a, $00
	ld [wCommandStep], a
	ret


UnusedTacticStepFar::
	db $21, $06, $55, $d7, $21, $f5, $d9, $34, $c9

Jump_50_443A::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, $00
	ld [wCommandStep], a
	ld de, $6ed2
	call DrawWindowLayout_50
	ret


UnusedTacticWhoMenu::
	db $11, $1a, $6f, $cd, $f0, $75, $cd, $48, $78, $11, $aa, $44, $fa, $fc, $d9, $cb
	db $ff, $ea, $db, $c8, $cd, $0b, $79, $cd, $8e, $76, $21, $f5, $d9, $34, $c9

Jump_50_446E::
	ld de, $44aa
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4487

	ld a, $01
	ld [wCommandStep], a
	jr jr_050_44a9

jr_050_4487:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_44a9

	ld a, [wMenuChoice2]
	res 7, a
	ld [wTacticMenuRow], a
	ld a, $59
	call QueueSound
	ld hl, wCommandSubStep
	inc [hl]
	ld a, [wSkillStatusPtr]
	ld [wConfirmChoice2], a
	call Call_50_5708

Jump_050_44a9:
jr_050_44a9:
	ret


TacticWhoCursors::
	db $c1, $01, $01, $02, $ff, $ff

Jump_50_44B0::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, wMonName
	ld a, [wConfirmChoice2]
	call Call_50_5B07
	jr c, jr_050_453c

	ld a, [wConfirmChoice2]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, $96c0
	call PrintNameToTiles_50
	ld de, $74a3
	ld a, [wMenuChoice2]
	cp $81
	call z, DrawWindowLayout_50
	ld de, $6f60
	call DrawWindowLayout_50
	ld a, [wBattleType]
	cp $02
	call z, Call_50_4550
	ld a, [wTacticMenuRow]
	or a
	jr z, jr_050_4507

	ld a, [wConfirmChoice2]
	and $03
	or a
	jr z, jr_050_4511

	cp $01
	jr z, jr_050_451b

	ld a, $04
	ld [wTacticSlot], a
	ld a, [$da00]
	jr jr_050_4523

jr_050_4507:
	ld a, $01
	ld [wTacticSlot], a
	ld a, [wTeamTactic]
	jr jr_050_4523

jr_050_4511:
	ld a, $02
	ld [wTacticSlot], a
	ld a, [wMonTactics]
	jr jr_050_4523

jr_050_451b:
	ld a, $03
	ld [wTacticSlot], a
	ld a, [$d9ff]

jr_050_4523:
	set 7, a
	ld [wConfirmChoice], a
	call ResetCursorBlink_50
	ld de, $4715
	ld a, [wConfirmChoice]
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


jr_050_453c:
	ld a, [wConfirmChoice2]
	inc a
	ld [wConfirmChoice2], a
	and $03
	cp $03
	jp c, Jump_50_44B0

	ld hl, wCommandSubStep
	inc [hl]
	inc [hl]
	ret


Call_50_4550::
	ld a, [wLinkActive]
	or a
	ret nz

	ld hl, $0202
	call TilemapBufferAddr_50
	ld de, $4567
	ld b, $08

jr_050_4560:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_050_4560

	ret


TournamentTacticTiles::
	db $8f, $90, $e0, $d6, $e3, $e0, $d6, $98

Jump_50_456F::
	ld de, $4715
	ld hl, wConfirmChoice
	ld b, $04
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 1, a
	jr z, TacticMenuConfirm

jr_050_4581:
	ld hl, far_Call_55_47C3
	rst $10
	ld a, [wMenuChoice2]
	cp $80
	jr z, jr_050_45d6

	ld a, [wConfirmChoice2]
	ld hl, wPartyBarTiles
	cp [hl]
	jr z, jr_050_45d6

	and $03
	or a
	jr z, jr_050_45d6

	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	call Call_50_5B07
	jr c, jr_050_4581

	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_050_4581

	ld a, $00
	ld [hl], a
	ld a, [wConfirmChoice2]
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
	ld hl, wCommandSubStep
	dec [hl]
	xor a
	ld [wConfirmChoice], a
	jp Jump_050_4714


jr_050_45d6:
	call Call_50_4F6E
	ld hl, wCommandSubStep
	dec [hl]
	dec [hl]
	dec [hl]
	jp Jump_050_4714


UnusedTacticBack::
	db $3e, $00, $ea, $f5, $d9, $3e, $01, $ea, $f4, $d9, $cd, $08, $57, $c3, $ed, $40
	db $c3, $14, $47

TacticMenuConfirm::
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4714

	ld a, $59
	call QueueSound
	ld a, [wTacticSlot]
	ld hl, wTacticMenuRow
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice]
	res 7, a
	ld [hl], a
	cp $03
	jp z, TacticDirectOrders

	ld a, [wMenuChoice2]
	cp $80
	jr z, jr_050_466d

Call_50_4620::
	ld a, [wConfirmChoice2]
	ld de, wBattlerOrder
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, $01
	ld [de], a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice]
	ld [hl], a
	res 7, [hl]
	ld a, [hl]
	call Call_50_473D
	ld a, [wConfirmChoice2]
	inc a
	ld [wConfirmChoice2], a
	push af
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_4659

	ld hl, wPartyBattlers
	jr jr_050_465c

jr_050_4659:
	ld hl, wEnemyCount

jr_050_465c:
	pop af
	and $03
	cp [hl]
	jr z, Call_50_46C6

	ld hl, wCommandSubStep
	dec [hl]
	xor a
	ld [wConfirmChoice], a
	jp Jump_050_4714


jr_050_466d:
	ld a, [wSkillUser]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_467c

	ld c, $04

jr_050_467c:
	ld a, c
	call CheckBattlerCanAct
	jr c, jr_050_4699

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr z, jr_050_469c

	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01

jr_050_4699:
	inc c
	jr jr_050_467c

jr_050_469c:
	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $00
	jr nz, jr_050_46c2

	ld a, $01
	ld [hl], a
	ld a, c
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice]
	res 7, a
	ld [hl], a
	ld a, [hl]
	call Call_50_473D

jr_050_46c2:
	inc c
	dec b
	jr nz, jr_050_467c

Call_50_46C6::
	ld hl, wCommandSubStep
	inc [hl]
	ld bc, $0400
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_46d6

	ld c, $04

jr_050_46d6:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_4701

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_050_46fe

	ld de, $0003
	add hl, de
	ld a, [hli]
	and $3f
	jr nz, jr_050_46fe

	bit 2, [hl]
	jr nz, jr_050_46fe

	inc hl
	ld a, [hl]
	and $c0
	jr nz, jr_050_46fe

	bit 4, [hl]
	jr z, jr_050_4701

jr_050_46fe:
	call Call_50_4707

jr_050_4701:
	inc c
	dec b
	jr nz, jr_050_46d6

	jr jr_050_4714

Call_50_4707::
	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ret


Jump_050_4714:
jr_050_4714:
	ret


TacticCursors::
	db $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

TacticDirectOrders::
	call Call_50_5C2F
	jp z, Call_50_4620

	ld a, $04
	ld [wMenuChoice], a
	xor a
	ld [wOrderStep], a
	call Call_50_47BE
	ld a, [wSkillUser]
	cp $01
	ret z

	ld a, $01
	ld [$c1c1], a
	ret


Call_50_473D::
	cp $03
	jr z, jr_050_4750

	push af
	ld hl, wBattlerSexBits67
	ld a, [wConfirmChoice2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a

jr_050_4750:
	ret


Jump_50_4751::
	call Call_50_4764
	call ClearTilemapBuffer_50
	ld hl, wCommandStep
	inc [hl]
	ld a, $ff
	ld [wBattleItemTarget], a
	ld [wBattleItemEffect], a
	ret


Call_50_4764::
	ld a, [wLinkActive]
	or a
	jr z, jr_050_4775

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4775

	ld c, $04
	jr jr_050_4777

jr_050_4775:
	ld c, $00

jr_050_4777:
	ld b, $03

jr_050_4779:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_478f

	ld a, c
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr nz, jr_050_478f

	ld [hl], $01

jr_050_478f:
	inc c
	dec b
	jr nz, jr_050_4779

	ret


Jump_50_4794::
	ld a, [wOrderStep]
	rst $00

JumpTable_50_4798::
	dw Call_50_47BE
	dw Jump_50_4816
	dw Jump_50_485E
	dw Jump_50_49AC
	dw Jump_50_4A2C
	dw Jump_50_4CD6
	dw Jump_50_4D23
	dw Jump_50_4DCD
	dw Jump_50_4E18
	dw Jump_50_4E8A
	dw Jump_50_4E98
	dw Jump_50_4EAB

jr_050_47b0:
	ld hl, wConfirmChoice2
	inc [hl]
	ld a, [wConfirmChoice2]
	and $03
	cp $03
	jp z, Jump_050_4f36

Call_50_47BE::
	ld a, [wConfirmChoice2]
	call CheckBattlerCanAct
	jr c, jr_050_47b0

	ld a, [wConfirmChoice2]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_050_47b0

	inc hl
	bit 4, [hl]
	jr nz, jr_050_47b0

	ld hl, far_Call_55_47AF
	rst $10
	ld hl, far_Call_55_479B
	rst $10
	xor a
	ld hl, wMenuChoice3
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wBattleTemp], a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 2, [hl]
	jr z, jr_050_47ff

	ld a, $01
	ld [wLinkPartnerChoice], a

jr_050_47ff:
	ld a, [hl]
	and $03
	ld [wLinkRefused], a
	ld a, [hl]
	swap a
	and $03
	ld [wMenuChoice3], a
	ld hl, wOrderStep
	inc [hl]
	xor a
	ld [$c1c1], a
	ret


Jump_50_4816::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, [$c1c1]
	or a
	jr nz, jr_050_4836

	ld hl, wMonName
	ld a, [wConfirmChoice2]
	call PartyMonsterField
	ld e, l
	ld d, h
	ld hl, $96c0
	call PrintNameToTiles_50

jr_050_4836:
	ld de, $6f49
	ld a, [wMenuChoice2]
	call DrawWindowLayout_50
	ld de, $74ba
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $496d
	ld a, [wMenuChoice3]
	set 7, a
	ld [wMenuChoice3], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


Jump_50_485E::
	ld de, $496d
	ld hl, wMenuChoice3
	ld b, $03
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_48d5

jr_050_4870:
	ld a, [wMenuChoice2]
	cp $80
	jr nz, jr_050_48b7

	ld a, [wConfirmChoice2]
	and $03
	or a
	jr z, jr_050_48b7

	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	call Call_50_5B07
	jr c, jr_050_4870

	ld a, [wConfirmChoice2]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_050_4870

	inc hl
	bit 4, [hl]
	jr nz, jr_050_4870

	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $00
	ld [hl], a
	xor a
	ld [wOrderStep], a
	call Call_50_4F6E
	call Call_50_47BE
	ret


jr_050_48b7:
	ld hl, far_Call_55_479B
	rst $10
	ld a, $81
	ld [wMenuChoice], a
	ld a, $03
	ld [wCommandSubStep], a
	ld a, [wConfirmChoice]
	res 7, a
	ld [wConfirmChoice], a
	xor a
	ld [wOrderStep], a
	jp Jump_50_44B0


	db $c9

jr_050_48d5:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_496c

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	and $03
	swap a
	ld b, a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $0f
	or b
	ld [hl], a
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_050_4937

	cp $80
	jr z, jr_050_4918

	ld b, $8d
	ld a, [wConfirmChoice2]
	ld c, a

jr_050_490c:
	call Call_50_4F80
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	ret


jr_050_4918:
	ld a, $3a
	ld [wSkillId], a
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	call Call_50_4FA4
	ld a, b
	ld b, $3a
	cp $01
	jr z, jr_050_490c

	call Call_50_4F86
	ld a, $07
	ld [wOrderStep], a
	ret


jr_050_4937:
	call Call_50_4975
	ld a, [wBattlerReload]
	or a
	jr z, jr_050_4945

	ld hl, wOrderStep
	inc [hl]
	ret


jr_050_4945:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $0202
	ld a, $09
	ld [wOrderStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_050_496c:
	ret


CommandCursors::
	db $81, $01, $c1, $01, $01, $02, $ff, $ff

Call_50_4975::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [wBattlerReload], a
	ld bc, $0800

jr_050_498a:
	ld a, [hli]
	or a
	jr z, jr_050_49a7

	ld a, [hl]
	cp $37
	jr z, jr_050_49a2

	cp $38
	jr z, jr_050_49a2

	cp $7e
	jr z, jr_050_49a2

	ld a, [wBattlerReload]
	inc a
	ld [wBattlerReload], a

jr_050_49a2:
	inc hl
	inc c
	dec b
	jr nz, jr_050_498a

jr_050_49a7:
	ld a, c
	ld [wBattleListCount], a
	ret


Jump_50_49AC::
	call Call_50_49D8
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $74f4
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $4cca
	ld b, $04
	ld a, [wBattleListCount]
	ld c, a
	ld hl, wLinkRefused
	call DrawListCursor_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


Call_50_49D8::
	ld a, [wConfirmChoice2]
	swap a
	ld de, $dc65
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wLinkPartnerChoice]
	add a
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call Call_50_49FE
	call Call_50_49FE
	call Call_50_49FE

Call_50_49FE::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_050_4a11

	ld a, $00
	ld [wTextIndex], a
	ld a, $08
	ld [wTextGroup], a
	jr jr_050_4a19

jr_050_4a11:
	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a

jr_050_4a19:
	ld de, $0901
	call PrintTextToTiles_50
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	inc de
	ret


Jump_50_4A2C::
	ld de, $4cca
	ld hl, wLinkRefused
	ld a, [wBattleListCount]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call UpdateListCursor_50
	pop af
	ld hl, wLinkPartnerChoice
	cp [hl]
	jr z, jr_050_4a48

	call Call_50_49D8

jr_050_4a48:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4a65

	ld a, $01
	ld [wOrderStep], a
	jp Jump_50_4816


jr_050_4a57:
	ld hl, $0302
	call Call_50_4CA4
	ret


jr_050_4a5e:
	ld hl, $0402
	call Call_50_4CA4
	ret


jr_050_4a65:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4b97

	ld a, $59
	call QueueSound
	ld hl, wLinkRefused
	res 7, [hl]
	ld a, [wLinkPartnerChoice]
	add a
	add a
	add [hl]
	ld [wItemMsgGroup], a
	add a
	ld hl, $dc65
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wConfirmChoice2]
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call Call_50_4B98
	jr z, jr_050_4a57

	call Call_50_4BA4
	jr c, jr_050_4a5e

	call Call_50_4F86
	ld a, [hl]
	ld [wBattleArg0], a
	ld [wSkillId], a
	ld [wBattleArg3], a
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $f0
	ld b, a
	ld a, [wItemMsgGroup]
	or b
	ld [hl], a
	xor a
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	call Call_50_56EB
	call Call_50_4BD1
	ret c

	ld a, [wBattleArg0]
	bit 0, a
	jp z, Jump_050_4b6b

	bit 4, a
	jr z, jr_050_4af0

	ld a, $07
	ld [wOrderStep], a
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	jr jr_050_4afe

jr_050_4af0:
	bit 6, a
	jr nz, jr_050_4b54

	ld a, $05
	ld [wOrderStep], a
	ld a, [wConfirmChoice2]
	and $04

jr_050_4afe:
	call Call_50_4FA4
	ld a, b
	cp $01
	ret nz

	ld a, [wSkillId]
	cp $30
	jr z, jr_050_4b20

	cp $31
	jr z, jr_050_4b20

	cp $88
	jr z, jr_050_4b20

	call Call_50_4F95
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	ret


jr_050_4b20:
	call Call_50_4B26
	jr z, Call_50_4B4D

	ret


Call_50_4B26::
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4b34

	ld c, $04
	ld a, [wEnemyCount]
	jr jr_050_4b39

jr_050_4b34:
	ld c, $00
	ld a, [wPartyBattlers]

jr_050_4b39:
	ld b, a
	ld d, $00

jr_050_4b3c:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_4b44

	jr z, jr_050_4b45

jr_050_4b44:
	inc d

jr_050_4b45:
	inc c
	dec b
	jr nz, jr_050_4b3c

	ld a, d
	cp $01
	ret


Call_50_4B4D::
	ld hl, $fb00
	call Call_50_4CA4
	ret


jr_050_4b54:
	ld a, [wConfirmChoice2]
	ld c, a
	call Call_50_4F95
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10
	ret


Jump_050_4b6b:
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10
	ld a, [wConfirmChoice2]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	ld b, a
	ld a, [wConfirmChoice2]
	and $04
	bit 4, b
	jr z, jr_050_4b96

	xor $04

jr_050_4b96:
	ld [hl], a

Jump_050_4b97:
	ret


Call_50_4B98::
	ld a, b
	cp $37
	jr z, jr_050_4ba3

	cp $38
	jr z, jr_050_4ba3

	cp $7e

jr_050_4ba3:
	ret


Call_50_4BA4::
	push bc
	ld a, b
	ld [wBattleArg0], a
	xor a
	ld [wBattleArg1], a
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld c, a
	ld b, $00
	ld a, [wConfirmChoice2]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	pop bc
	ret


Call_50_4BD1::
	ld a, [wBattleArg3]
	cp $14
	jr z, jr_050_4c21

	cp $80
	jr z, jr_050_4c21

	cp $24
	jr z, jr_050_4c34

	cp $26
	jr z, jr_050_4c34

	cp $2a
	jr z, jr_050_4c34

	cp $32
	jr z, jr_050_4c2a

	cp $89
	jr z, jr_050_4c2a

	cp $8b
	jr z, jr_050_4c34

	cp $8f
	jr z, jr_050_4c34

	cp $95
	jr z, jr_050_4c2a

	cp $96
	jr z, jr_050_4c2a

	cp $39
	jr z, jr_050_4c3b

	cp $3f
	jr z, jr_050_4c72

	cp $51
	jr z, jr_050_4c40

	cp $52
	jr z, jr_050_4c40

	cp $53
	jr z, jr_050_4c40

	cp $83
	jr z, jr_050_4c64

	cp $88
	ret nc

	cp $84
	jr nc, jr_050_4c6d

	xor a
	ret


jr_050_4c21:
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	jr jr_050_4c96

jr_050_4c2a:
	call Call_50_4B26
	jr nz, jr_050_4c34

	call Call_50_4B4D
	pop hl
	ret


jr_050_4c34:
	ld a, [wConfirmChoice2]
	and $04
	jr jr_050_4c96

jr_050_4c3b:
	ld a, [wConfirmChoice2]
	jr jr_050_4c96

jr_050_4c40:
	ld a, [wSkillUser]
	ld b, a
	ld a, [wSkillId]
	ld c, a
	push bc
	ld a, [wConfirmChoice2]
	ld [wSkillUser], a
	ld a, [wBattleArg3]
	ld [wSkillId], a
	ld hl, far_AITargetRandomEnemy
	rst $10
	pop bc
	ld a, b
	ld [wSkillUser], a
	ld a, c
	ld [wSkillId], a
	jr jr_050_4c9a

jr_050_4c64:
	ld a, [wConfirmChoice2]
	and $04
	xor $04
	jr jr_050_4c96

jr_050_4c6d:
	ld a, [wConfirmChoice2]
	jr jr_050_4c96

jr_050_4c72:
	ld a, [wSkillUser]
	ld b, a
	ld a, [wSkillId]
	ld c, a
	push bc
	ld a, [wConfirmChoice2]
	ld [wSkillUser], a
	ld a, [wBattleArg3]
	ld [wSkillId], a
	ld hl, far_AITargetAnyone
	rst $10
	pop bc
	ld a, b
	ld [wSkillUser], a
	ld a, c
	ld [wSkillId], a
	jr jr_050_4c9a

jr_050_4c96:
	ld c, a
	call Call_50_4F95

jr_050_4c9a:
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	scf
	ret


Call_50_4CA4::
	push hl
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	pop hl
	ld a, $03
	ld [wOrderStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


SkillListCursors::
	db $2a, $02, $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Jump_50_4CD6::
	ld a, [wSkillId]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	ld hl, far_Call_55_47FF
	rst $10
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $70c9
	call DrawWindowLayout_50
	call Call_50_5BD7
	call ResetCursorBlink_50
	ld de, $5339
	ld a, [wLinkFlags]
	rlca
	and $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_4d10

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_4d10

	inc b

jr_050_4d10:
	res 2, b
	set 7, b
	ld a, b
	ld [wBattleTemp], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


Jump_50_4D23::
	ld de, $5339
	ld hl, wBattleTemp
	ld a, [wConfirmChoice2]
	cp $04
	jr c, jr_050_4d35

	ld a, [wEnemyCount]
	jr jr_050_4d38

jr_050_4d35:
	ld a, [wPartyBattlers]

jr_050_4d38:
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	ld c, a
	call Call_50_5B7A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4d51

	ld a, $03
	ld [wOrderStep], a
	jr jr_050_4d9b

jr_050_4d51:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4d9b

	ld a, [wBattleTemp]
	res 7, a
	ld c, a
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_4d68

	set 2, c

jr_050_4d68:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_4d84

	ld a, [wConfirmChoice2]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $30
	jr z, jr_050_4d84

	cp $31
	jr nz, jr_050_4d9c

jr_050_4d84:
	call Call_50_4F95
	ld a, $59
	call QueueSound
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10

Jump_050_4d9b:
jr_050_4d9b:
	ret


Jump_050_4d9c:
jr_050_4d9c:
	ld a, c
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $fa00
	ld a, $0a
	ld [wOrderStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_4DCD::
	ld a, [wSkillId]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	call Call_50_53DC
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $7113
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $5664
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_4e05

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_4e05

	inc b

jr_050_4e05:
	res 2, b
	set 7, b
	ld a, b
	ld [wBattleTemp], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wOrderStep
	inc [hl]
	ret


Jump_50_4E18::
	ld de, $5664
	ld hl, wBattleTemp
	ld a, [wConfirmChoice2]
	cp $04
	jr c, jr_050_4e2a

	ld a, [wPartyBattlers]
	jr jr_050_4e2d

jr_050_4e2a:
	ld a, [wEnemyCount]

jr_050_4e2d:
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld c, a
	call Call_50_5B7A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_4e54

	ld a, [wMenuChoice3]
	cp $80
	ld a, $01
	jr z, jr_050_4e4c

	ld a, $03

jr_050_4e4c:
	ld [wOrderStep], a
	call Call_50_56EB
	jr jr_050_4e89

jr_050_4e54:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_4e89

	ld a, [wBattleTemp]
	res 7, a
	ld c, a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_4e6b

	set 2, c

jr_050_4e6b:
	ld a, c
	call CheckBattlerPresent
	jp c, Jump_050_4d9c

	call Call_50_4F95
	ld a, $59
	call QueueSound
	call Call_50_4F45
	ld a, $0b
	ld [wOrderStep], a
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10

Jump_050_4e89:
jr_050_4e89:
	ret


Jump_50_4E8A::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $01
	ld [wOrderStep], a
	ret


Jump_50_4E98::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, [wMenuChoice3]
	and $01
	add a
	inc a
	ld [wOrderStep], a
	ret


Jump_50_4EAB::
	ld a, [wMenuChoice2]
	cp $80
	jr z, jr_050_4ed7

	ld a, $81
	ld [wMenuChoice], a
	ld a, $04
	ld [wCommandSubStep], a
	call Call_50_4620
	call Call_50_56EB
	ld hl, far_Call_55_479B
	rst $10
	jp Jump_050_4f61


jr_050_4ec9:
	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02

jr_050_4ed7:
	ld a, [wSkillUser]
	cp $01
	jr z, jr_050_4f36

	ld b, a
	ld a, [wConfirmChoice2]
	and $03
	cp b
	jr z, jr_050_4f36

	ld hl, wConfirmChoice2
	inc [hl]
	ld a, [hl]
	and $03
	cp $03
	jr z, jr_050_4f36

	ld a, [hl]
	call CheckBattlerPresent
	jr c, jr_050_4ed7

	ld a, [hl]
	call CheckBattlerCanAct
	jr c, jr_050_4f16

	ld a, [wConfirmChoice2]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_050_4ec9

	inc hl
	bit 4, [hl]
	jr nz, jr_050_4ec9

	xor a
	ld [wOrderStep], a
	jr jr_050_4f61

jr_050_4f16:
	ld a, [hl]
	push bc
	ld b, a
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a
	ld [hli], a
	ld a, b
	ld [hl], a
	pop bc
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	jr jr_050_4ed7

Jump_050_4f36:
jr_050_4f36:
	ld a, $81
	ld [wMenuChoice], a
	ld a, $04
	ld [wCommandSubStep], a
	call Call_50_46C6
	jr jr_050_4f61

Call_50_4F45::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [wConfirmChoice2]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03

Jump_050_4f61:
jr_050_4f61:
	ret


UnusedRedrawBattleWindows::
	db $cd, $4e, $77, $cd, $4c, $79, $cd, $b4, $79, $c9, $c9, $c9

Call_50_4F6E::
	ld a, [wConfirmChoice2]
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
	ret


Call_50_4F80::
	call Call_50_4F86
	inc hl
	ld [hl], c
	ret


Call_50_4F86::
	ld a, [wConfirmChoice2]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


Call_50_4F95::
	ld a, [wConfirmChoice2]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ret


Call_50_4FA4::
	push de
	ld c, a
	ld b, $03
	ld de, $0000

jr_050_4fab:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_4fb3

	inc d
	ld e, c

jr_050_4fb3:
	inc c
	dec b
	jr nz, jr_050_4fab

	ld b, d
	ld c, e
	pop de
	ret


Jump_50_4FBB::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCommandSubStep]
	rst $00

JumpTable_50_4FC4::
	dw Jump_50_4FE2
	dw Jump_50_5040
	dw Jump_50_50C5
	dw Jump_50_51CC
	dw Jump_50_5207
	dw Jump_50_528E
	dw Jump_50_52D7
	dw Jump_50_5372
	dw Jump_50_5602
	dw Jump_50_5697
	dw Jump_50_56AC
	dw Jump_50_56BA
	dw Jump_50_56CB
	dw Jump_50_56D9
	dw Call_50_56EB

Jump_50_4FE2::
	ld a, [wBattleType]
	cp $02
	jr z, jr_050_503a

	ld bc, $1400

jr_050_4fec:
	ld hl, wBagItems
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_050_5020

	or a
	jr z, jr_050_5020

	push bc
	ld a, [hl]
	add $af
	ld a, a
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $0a
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	cp $01
	pop bc
	jr nz, jr_050_5035

	inc c
	dec b
	jr nz, jr_050_4fec

jr_050_5020:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $f300
	call Call_50_51AA
	ld a, $0b
	ld [wCommandSubStep], a
	ret


jr_050_5035:
	ld hl, wCommandSubStep
	inc [hl]
	ret


jr_050_503a:
	ld a, $f4
	call Call_50_5AE5
	ret


Jump_50_5040::
	call Call_50_50AC
	call Call_50_506F
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $6fce
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $51c0
	ld b, $04
	ld a, [wBattleListCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawListCursor_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Call_50_506F::
	ld de, wBagItems
	ld a, [wConfirmChoice]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $88c0
	call Call_50_5089
	call Call_50_5089
	call Call_50_5089

Call_50_5089::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr nz, jr_050_5092

	ld a, $00

jr_050_5092:
	ld [wTextIndex], a
	ld a, $08
	ld [wTextGroup], a
	ld de, $0901
	call PrintTextToTiles_50
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


Call_50_50AC::
	ld hl, wBagItems
	ld b, $14
	ld c, $00

jr_050_50b3:
	ld a, [hli]
	cp $00
	jr z, jr_050_50c0

	cp $ff
	jr z, jr_050_50c0

	inc c
	dec b
	jr nz, jr_050_50b3

jr_050_50c0:
	ld a, c
	ld [wBattleListCount], a
	ret


Jump_50_50C5::
	ld de, $51c0
	ld hl, wMenuChoice2
	ld a, [wBattleListCount]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call UpdateListCursor_50
	pop af
	ld hl, wConfirmChoice
	cp [hl]
	jr z, jr_050_50e1

	call Call_50_506F

jr_050_50e1:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_50f4

	ld hl, far_Call_55_47C3
	rst $10
	ld a, $01
	ld [wCommandStep], a
	jp Jump_050_517a


jr_050_50f4:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_517a

	ld hl, wMenuChoice2
	res 7, [hl]
	ld a, [wConfirmChoice]
	add a
	add a
	add [hl]
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $af
	add [hl]
	ld [wBattleArg0], a
	ld hl, far_GetBattleItemTarget
	rst $10
	ld a, [wBattleArg0]
	or a
	jr z, jr_050_5199

	ld a, [wBattleArg0]
	ld [wBattleItemTarget], a
	ld a, [wBattleArg1]
	ld [wBattleItemEffect], a
	ld a, $59
	call QueueSound
	ld hl, far_Call_55_47D7
	rst $10
	ld a, [wBattleItemTarget]
	cp $11
	jr z, jr_050_514e

	cp $12
	jr z, jr_050_515d

	cp $21
	jr z, jr_050_5169

	cp $22
	jr z, jr_050_5170

	ld hl, wCommandSubStep
	inc [hl]
	jr jr_050_517a

jr_050_514e:
	call Call_50_517B
	jr z, jr_050_5175

	call Call_50_56EB
	ld a, $07
	ld [wCommandSubStep], a
	jr jr_050_517a

jr_050_515d:
	ld a, $04
	ld [wBattleItemTarget], a
	ld a, $09
	ld [wCommandSubStep], a
	jr jr_050_517a

jr_050_5169:
	ld a, $05
	ld [wCommandSubStep], a
	jr jr_050_517a

jr_050_5170:
	ld a, $00
	ld [wBattleItemTarget], a

jr_050_5175:
	ld a, $09
	ld [wCommandSubStep], a

Jump_050_517a:
jr_050_517a:
	ret


Call_50_517B::
	ld hl, wEnemyDown
	ld a, [wEnemyCount]
	ld b, a
	ld c, $00
	ld d, $04

jr_050_5186:
	ld a, [hli]
	or a
	jr nz, jr_050_518c

	inc c
	ld e, d

jr_050_518c:
	inc d
	dec b
	jr nz, jr_050_5186

	ld a, c
	cp $01
	ret nz

	ld a, e
	ld [wBattleItemTarget], a
	ret


jr_050_5199:
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $f200
	ld a, $0a
	ld [wCommandSubStep], a

Call_50_51AA::
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


ItemListCursors::
	db $2a, $02, $41, $01, $81, $01, $c1, $01, $01, $02, $ff, $ff

Jump_50_51CC::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $7045
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $5288
	xor a
	ld [wConfirmChoice2], a
	ld a, [wConfirmChoice2]
	ld b, a
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, jr_050_51fb

	cp $c7
	jr nc, jr_050_51fb

	ld a, $01
	ld [wConfirmChoice2], a
	ld b, $01

jr_050_51fb:
	ld a, b
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Jump_50_5207::
	ld de, $5288
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_5227

	ld hl, wCommandSubStep
	dec [hl]
	ld hl, wCommandSubStep
	dec [hl]
	ld hl, wCommandSubStep
	dec [hl]
	jr jr_050_5287

jr_050_5227:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_5287

	ld a, $59
	call QueueSound
	ld hl, far_Call_55_47EB
	rst $10
	ld a, $80
	ld [wMenuChoice3], a
	ld a, [wConfirmChoice2]
	cp $80
	jr z, jr_050_526d

	ld a, [wBattleItemEffect]
	cp $c2
	jr c, jr_050_524f

	cp $c7
	jr c, jr_050_525f

jr_050_524f:
	ld a, [wBattleItemTarget]
	and $0f
	bit 0, a
	jr z, jr_050_525f

	ld a, $07
	ld [wCommandSubStep], a
	jr jr_050_5287

jr_050_525f:
	ld a, $04
	ld [wBattleItemTarget], a
	ld a, $09
	ld [wCommandSubStep], a
	jr jr_050_5287

	db $18, $1a

jr_050_526d:
	ld a, [wBattleItemTarget]
	and $0f
	bit 0, a
	jr z, jr_050_527d

	ld a, $05
	ld [wCommandSubStep], a
	jr jr_050_5287

jr_050_527d:
	ld a, $09
	ld [wCommandSubStep], a
	ld a, $00
	ld [wBattleItemTarget], a

Jump_050_5287:
jr_050_5287:
	ret


ItemUseCursors::
	db $c1, $01, $01, $02, $ff, $ff

Jump_50_528E::
	ld a, [wBattleItemEffect]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $707f
	call DrawWindowLayout_50
	call Call_50_5BD7
	call ResetCursorBlink_50
	ld de, $5339
	ld a, [wLinkFlags]
	rlca
	and $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_52c4

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_52c4

	inc b

jr_050_52c4:
	res 2, b
	set 7, b
	ld a, b
	ld [wMenuChoice3], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Jump_50_52D7::
	ld de, $5339
	ld hl, wMenuChoice3
	ld a, [wPartyBattlers]
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	ld c, a
	call Call_50_5B7A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_5309

	ld a, [wBattleItemTarget]
	and $f0
	cp $20
	jr z, jr_050_5302

	ld a, $03
	ld [wCommandSubStep], a
	jr jr_050_5338

jr_050_5302:
	ld a, $01
	ld [wCommandSubStep], a
	jr jr_050_5338

jr_050_5309:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_5338

	ld a, [wMenuChoice3]
	res 7, a
	ld c, a
	call CheckBattlerPresent
	jr nc, jr_050_5323

	ld a, [wBattleItemEffect]
	cp $bb
	jr nz, ItemAllyTargetGone

jr_050_5323:
	ld a, c
	ld [wBattleItemTarget], a
	ld a, $59
	call QueueSound
	ld hl, wCommandSubStep
	inc [hl]
	ld hl, wCommandSubStep
	inc [hl]
	ld hl, wCommandSubStep
	inc [hl]

Jump_050_5338:
jr_050_5338:
	ret


AllyTargetCursors::
	db $81, $01, $c1, $01, $01, $02, $ff, $ff

ItemAllyTargetGone::
	ld a, c
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $fa00
	ld a, $0c
	ld [wCommandSubStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_5372::
	ld a, [wBattleItemEffect]
	ld [wTargetSkill], a
	ld a, a
	ld [wTargetCursorSkill], a
	call Call_50_53DC
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld de, $7113
	call DrawWindowLayout_50
	call ResetCursorBlink_50
	ld de, $5664
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_050_53aa

	inc b
	ld a, b
	call CheckBattlerPresent
	jr nc, jr_050_53aa

	inc b

jr_050_53aa:
	res 2, b
	set 7, b
	ld a, b
	ld [wMenuChoice3], a
	call DrawCursorAt_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


Call_50_53BD::
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld [wBattleTempHigh], a
	ret


Call_50_53C9::
	ld a, [wTargetSkill]
	cp $30
	jr z, jr_050_53da

	cp $31
	jr z, jr_050_53da

	cp $bb
	jr z, jr_050_53da

	scf
	ret


jr_050_53da:
	xor a
	ret


Call_50_53DC::
	ld a, [wLinkActive]
	or a
	jp nz, Jump_050_549e

	call Call_50_53BD
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr c, jr_050_53fe

	xor a
	ld [wBattleArg2], a
	ld a, [wEnemyMorph]
	cp $ff
	jr z, jr_050_5403

	call Call_50_5530
	jr jr_050_540e

jr_050_53fe:
	call Call_50_547E
	jr jr_050_540e

jr_050_5403:
	call Call_50_547E
	ld a, $01
	ld [wBattleArg2], a
	call Call_50_5530

jr_050_540e:
	xor a
	ld [wBattleArg2], a
	ld a, [wEncCount]
	cp $00
	jr nz, jr_050_541e

	call Call_50_5485
	jr Call_50_548C

jr_050_541e:
	ld a, [wBattleTempHigh]
	inc a
	ld [wBattleTempHigh], a
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr c, jr_050_5439

	ld a, [$c1cb]
	cp $ff
	jr z, jr_050_543e

	call Call_50_553D
	jr jr_050_5449

jr_050_5439:
	call Call_50_5485
	jr jr_050_5449

jr_050_543e:
	call Call_50_5485
	ld a, $01
	ld [wBattleArg2], a
	call Call_50_553D

jr_050_5449:
	xor a
	ld [wBattleArg2], a
	ld a, [wEncCount]
	cp $01
	jr nz, jr_050_5456

	jr Call_50_548C

jr_050_5456:
	ld a, [wBattleTempHigh]
	inc a
	ld [wBattleTempHigh], a
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr c, jr_050_5470

	ld a, [$c1cc]
	cp $ff
	jr z, jr_050_5472

	call Call_50_554A
	ret


jr_050_5470:
	jr Call_50_548C

jr_050_5472:
	call Call_50_548C
	ld a, $01
	ld [wBattleArg2], a
	call Call_50_554A
	ret


Call_50_547E::
	ld hl, $88c0
	ld b, $a0
	jr Call_50_5491

Call_50_5485::
	ld hl, $8960
	ld b, $a0
	jr Call_50_5491

Call_50_548C::
	ld hl, $8a00
	ld b, $a0

Call_50_5491::
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, Call_50_5491

	ret


Jump_050_549e:
	xor a
	ld [$c1d7], a
	ld a, [wPartyBattlers]
	ld [$c1d8], a
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_54ba

	ld a, $04
	ld [$c1d7], a
	ld a, [wEnemyCount]
	ld [$c1d8], a

jr_050_54ba:
	ld a, [$c1d7]
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr nc, jr_050_54ca

	call Call_50_547E
	jr jr_050_54d9

jr_050_54ca:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $88c0
	call Call_50_5557

jr_050_54d9:
	ld a, [$c1d8]
	cp $01
	jr nz, jr_050_54e5

	call Call_50_5485
	jr Call_50_548C

jr_050_54e5:
	ld hl, $c1d7
	inc [hl]
	ld a, [hl]
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr nc, jr_050_54f7

	call Call_50_5485
	jr jr_050_5506

jr_050_54f7:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $8960
	call Call_50_5557

jr_050_5506:
	ld a, [$c1d8]
	cp $02
	jr nz, jr_050_5510

	jp Call_50_548C


jr_050_5510:
	ld hl, $c1d7
	inc [hl]
	ld a, [hl]
	call CheckBattlerPresent
	call c, Call_50_53C9
	jr nc, jr_050_5520

	jp Call_50_548C


jr_050_5520:
	ld a, [$c1d7]
	call Call_50_55F9
	ld a, [$c1d7]
	ld hl, $8a00
	call Call_50_5557
	ret


Call_50_5530::
	call Call_50_55F9
	ld hl, $88c0
	ld a, $00
	ld [wBattleArg0], a
	jr jr_050_556a

Call_50_553D::
	call Call_50_55F9
	ld hl, $8960
	ld a, $01
	ld [wBattleArg0], a
	jr jr_050_556a

Call_50_554A::
	call Call_50_55F9
	ld hl, $8a00
	ld a, $02
	ld [wBattleArg0], a
	jr jr_050_556a

Call_50_5557::
	push hl
	call PrintNameToTiles_50
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $30
	call Call_50_5491
	ret


jr_050_556a:
	push hl
	push hl
	ld a, [wBattleArg0]
	add $04
	ld [wNamePos], a
	ld hl, wTextArg0
	call GetBattlerName_50
	pop hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, [wBattleArg1]
	or a
	jr nz, jr_050_55a0

	ld de, $0801
	jr jr_050_55a3

jr_050_55a0:
	ld de, $0901

jr_050_55a3:
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	pop hl
	ld a, [wBattleArg2]
	or a
	ret nz

	ld a, [wBattleArg1]
	or a
	jr nz, jr_050_55e3

	ld a, l
	add $80
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $18
	jr jr_050_55f5

jr_050_55e3:
	ld a, l
	add $80
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld b, $10

jr_050_55f5:
	call Call_50_5491
	ret


Call_50_55F9::
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	ret


Jump_50_5602::
	ld de, $5664
	ld hl, wMenuChoice3
	ld a, [wEncCount]
	inc a
	ld b, a
	ld a, [wLinkFlags]
	rlca
	and $04
	xor $04
	ld c, a
	call Call_50_5B7A
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_050_563a

	ld a, [wBattleItemTarget]
	and $f0
	cp $10
	jr z, jr_050_5630

	ld a, $03
	ld [wCommandSubStep], a
	jr jr_050_5663

jr_050_5630:
	call Call_50_56EB
	ld a, $01
	ld [wCommandSubStep], a
	jr jr_050_5663

jr_050_563a:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_050_5663

	ld a, [wMenuChoice3]
	res 7, a
	add $04
	ld c, a
	call CheckBattlerPresent
	jr nc, jr_050_5656

	ld a, [wBattleItemEffect]
	cp $bb
	jr nz, ItemEnemyTargetGone

jr_050_5656:
	ld a, c
	ld [wBattleItemTarget], a
	ld a, $59
	call QueueSound
	ld hl, wCommandSubStep
	inc [hl]

Jump_050_5663:
jr_050_5663:
	ret


EnemyTargetCursors::
	db $81, $01, $c1, $01, $01, $02, $ff, $ff

ItemEnemyTargetGone::
	ld a, c
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	call Call_50_5708
	ld hl, $fa00
	ld a, $0d
	ld [wCommandSubStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_5697::
	ld hl, wBattlerOrder
	ld a, [wPartyBattlers]
	ld b, a
	ld a, $01

jr_050_56a0:
	ld [hli], a
	dec b
	jr nz, jr_050_56a0

	call ClearTilemapBuffer_50
	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_56AC::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $01
	ld [wCommandSubStep], a
	ret


Jump_50_56BA::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	xor a
	ld [wCommandStep], a
	xor a
	ld [wCommandSubStep], a
	ret


Jump_50_56CB::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $05
	ld [wCommandSubStep], a
	ret


Jump_50_56D9::
	ld a, [wTextState]
	or a
	ret nz

	call ClearTilemapBuffer_50
	ld a, $07
	ld [wCommandSubStep], a
	ret


UnusedFarCall55::
	db $21, $06, $55, $d7

Call_50_56EB::
	call Call_50_5708
	ld hl, $88c0

Call_50_56F1::
	ld c, $02

jr_050_56f3:
	ld b, $f0

jr_050_56f5:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_050_56f5

	dec c
	jr nz, jr_050_56f3

	call CopyTilemapBufferToScreen_50
	ret


Call_50_5708::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ret


Jump_50_5712::
	ld a, [wCommandSubStep]
	rst $00

JumpTable_50_5716::
	dw Jump_50_571E
	dw Jump_50_57A8
	dw Jump_50_5831
	dw Jump_50_583B

Jump_50_571E::
	ld a, [wBattleType]
	or a
	jr z, jr_050_5738

	cp $01
	jr z, jr_050_576c

	ld a, [wScriptMap]
	cp $5d
	jr nz, jr_050_576c

	call Call_50_5772
	ld a, $01
	ld [wOrderFlag0], a
	ret


jr_050_5738:
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, $2a
	call Call_50_6AA0
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld a, $ff
	ld [wBattleItemTarget], a
	ld a, $ff
	ld [wBattleItemEffect], a
	ld hl, wCommandSubStep
	inc [hl]
	ld a, $6d
	call QueueSound
	ret


jr_050_576c:
	ld a, $f5
	call Call_50_5AE5
	ret


Call_50_5772::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld hl, $0502
	ld a, $03
	ld [wCommandSubStep], a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $7213
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ret


Jump_50_57A8::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wBattleType]
	or a
	jr nz, jr_050_5808

	ld a, [wRunTurn]
	or a
	jr z, jr_050_5808

	cp $04
	jr nc, jr_050_5808

	cp $03
	jr z, jr_050_57cd

	cp $02
	jr z, jr_050_57c9

	ld b, $40
	jr jr_050_57cf

jr_050_57c9:
	ld b, $80
	jr jr_050_57cf

jr_050_57cd:
	ld b, $c0

jr_050_57cf:
	ld a, [wRandomHigh]
	cp b
	jr c, jr_050_5808

	call Call_50_58A6
	jr c, jr_050_5808

	call Call_50_58D0
	jr c, jr_050_5808

	ld hl, wBattlerOrder
	ld a, [wPartyBattlers]
	ld b, a
	ld a, $03

jr_050_57e8:
	ld [hli], a
	dec b
	jr nz, jr_050_57e8

	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, $b9
	call Call_50_6AA0
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld hl, wCommandSubStep
	inc [hl]
	ret


jr_050_5808:
	xor a
	ld [wBattleArg2], a
	ld hl, wCommandStep
	inc [hl]
	ld a, $0a
	ld [wBattleStep], a
	ld hl, wEnemyDown
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $02
	ld [wBattlerReload], a
	call Call_50_590C
	ld a, [wBattleType]
	or a
	ret z

	ld a, $01
	ld [wBattlerReload], a
	ret


Jump_50_5831::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ret


Jump_50_583B::
	ld de, $58a0
	ld hl, wOrderFlag0
	ld b, $02
	call UpdateMenuCursor_50
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_050_5892

	ld a, [wOrderFlag0]
	bit 0, a
	jr nz, jr_050_5895

	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, $02
	ld [wTextGroup], a
	ld a, $06
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld a, $ff
	ld [wBattleItemTarget], a
	ld a, $ff
	ld [wBattleItemEffect], a
	ld a, $6d
	call QueueSound
	ld a, $01
	ld [wCommandSubStep], a
	ret


jr_050_5892:
	bit 1, a
	ret z

jr_050_5895:
	xor a
	ld [wCommandStep], a
	ld [wMenuChoice], a
	ld [wCommandSubStep], a
	ret


YesNoCursors::
	db $2f, $01, $6f, $01, $ff, $ff

Call_50_58A6::
	ld bc, $0304

jr_050_58a9:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_58c8

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $d0
	jr nz, jr_050_58c8

	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, jr_050_58c8

	inc hl
	ld a, [hl]
	and $c0
	jr z, jr_050_58ce

jr_050_58c8:
	inc c
	dec b
	jr nz, jr_050_58a9

	scf
	ret


jr_050_58ce:
	xor a
	ret


Call_50_58D0::
	ld bc, $0300
	ld de, $0000

jr_050_58d6:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_58e3

	call Call_50_5900
	cp d
	jr c, jr_050_58e3

	ld d, a

jr_050_58e3:
	inc c
	dec b
	jr nz, jr_050_58d6

	ld bc, $0304

jr_050_58ea:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_58f7

	call Call_50_5900
	cp e
	jr c, jr_050_58f7

	ld e, a

jr_050_58f7:
	inc c
	dec b
	jr nz, jr_050_58ea

	ld a, $04
	add e
	cp d
	ret


Call_50_5900::
	ld a, c
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


Call_50_590C::
	ld bc, $0300

Jump_050_590f:
	ld a, c
	ld [wBattleArg0], a
	ld a, b
	ld [wBattleArg1], a
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_5991

	ld de, $0000
	ld a, c
	ld hl, wBattlerPersonality3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $97
	jr c, jr_050_5931

	ld e, $10

jr_050_5931:
	ld a, c
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $0a
	jr c, jr_050_595a

	cp $14
	jr c, jr_050_594e

	cp $1e
	jr c, jr_050_5954

	ld a, e
	add $0c
	ld e, a
	jr jr_050_595a

jr_050_594e:
	ld a, e
	add $04
	ld e, a
	jr jr_050_595a

jr_050_5954:
	ld a, e
	add $08
	ld e, a
	jr jr_050_595a

jr_050_595a:
	ld hl, $59b6
	add hl, de
	ld a, [wBattleArg0]
	ld bc, wBattlerPersonality1
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_50_599F

jr_050_5991:
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
	inc c
	dec b
	jp nz, Jump_050_590f

	ret


Call_50_599F::
	bit 7, [hl]
	jr nz, jr_050_59ab

	ld a, [bc]
	add [hl]
	jr nc, jr_050_59b4

	ld a, $ff
	jr jr_050_59b4

jr_050_59ab:
	ld a, [hl]
	cpl
	inc a
	ld d, a
	ld a, [bc]
	sub d
	jr nc, jr_050_59b4

	xor a

jr_050_59b4:
	ld [bc], a
	ret


RunPersonalityChanges::
	db $fc, $00, $00, $f6, $fd, $00, $00, $fb, $fe, $00, $00, $fd, $ff, $00, $00, $fe
	db $f8, $00, $00, $f1, $fa, $00, $00, $f6, $fc, $00, $00, $fb, $fe, $00, $00, $fd

Jump_50_59D6::
	call Call_50_5708
	ld a, [wTargetScores]
	ld l, a
	ld a, [$db59]
	ld h, a
	call Call_50_56F1
	ld a, [wSkillAmount2]
	ld [wCommandStep], a
	ret


Call_50_59EB::
	ld a, [wSkillUser]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_50
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	cp $4f
	jr z, jr_050_5a19

	cp $a6
	jr z, jr_050_5a16

	cp $ac
	jr z, jr_050_5a19

	call Call_50_5A53
	jr jr_050_5a1c

jr_050_5a16:
	call Call_50_5A5E

jr_050_5a19:
	call Call_50_5A71

jr_050_5a1c:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	call z, Call_50_5A50
	cp $da
	call nc, Call_50_5AD2
	ld l, a
	ld h, $06
	ld de, wTextArg1
	call CopySystemText
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattleArg0]
	ld [wTextIndex], a
	cp $ff
	ret z

	ld hl, far_StartText_4C
	rst $10
	ret


Call_50_5A50::
	ld a, $3a
	ret


Call_50_5A53::
	ld a, [hl]
	ld hl, wTextArg2
	ld [wNamePos], a
	call GetBattlerName_50
	ret


Call_50_5A5E::
	ld a, [hl]
	ld [wSkillTarget], a
	ld hl, far_CountTargetNames
	rst $10
	ld a, [wBattleTemp]
	or a
	jr z, jr_050_5a1c

	ld hl, wTextArg0
	jr jr_050_5a89

Call_50_5A71::
	ld a, [hl]
	ld [wSkillTarget], a
	ld hl, far_CountTargetNames
	rst $10
	ld a, [wBattleTemp]
	or a
	jr z, Call_50_5AC5

	cp $01
	jr nz, jr_050_5a9c

	call Call_50_5AC5
	ld hl, wTextArg2

jr_050_5a89:
	ld a, [hli]
	cp $f0
	jr nz, jr_050_5a89

jr_050_5a8e:
	dec hl
	ld a, [hl]
	cp $f0
	jr z, jr_050_5a8e

	cp $24
	jr c, jr_050_5a99

	inc hl

jr_050_5a99:
	ld [hl], $f0
	ret


jr_050_5a9c:
	ld a, [wLinkActive]
	or a
	jr nz, Call_50_5AC5

	ld a, [wSkillTarget]
	cp $04
	jr nc, jr_050_5aad

	call Call_50_5AC5
	ret


jr_050_5aad:
	ld hl, wTextArg2
	ld a, $3e
	ld [hli], a
	ld a, $62
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld a, $3e
	ld [hli], a
	ld a, $4b
	ld [hli], a
	ld a, $44
	ld [hli], a
	ld [hl], $f0
	ret


Call_50_5AC5::
	ld a, [wSkillTarget]
	ld hl, wTextArg2
	ld [wNamePos], a
	call GetBattlerName_50
	ret


Call_50_5AD2::
	push hl
	sub $da
	ld hl, $5ae1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ret


SpecialActionNames::
	db $19, $a1, $2a, $70

Call_50_5AE5::
	push af
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	pop af
	call Call_50_6AA0
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld a, $00
	ld [wCommandStep], a
	ld a, $00
	ld [wCommandSubStep], a
	ret


Call_50_5B07::
	push bc
	ld [wBattleTemp], a
	ld b, a
	call CheckBattlerCanAct
	jr c, jr_050_5b55

	ld a, b
	ld bc, wBattlerStatus
	add a
	add a
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	bit 4, a
	jr nz, jr_050_5b35

	inc bc
	inc bc
	inc bc
	inc bc
	ld a, [bc]
	and $0c
	jr nz, jr_050_5b35

	inc bc
	ld a, [bc]
	and $f0
	jr nz, jr_050_5b35

	xor a
	jr jr_050_5b56

jr_050_5b35:
	push hl
	ld a, [wBattleTemp]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or $e0
	ld [hl], a
	ld a, [wBattleTemp]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	pop hl

jr_050_5b55:
	scf

jr_050_5b56:
	pop bc
	ret


Call_50_5B58::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	call DrawBattlePanel
	ld a, $e0
	call Call_50_6AA0
	ld de, $2e07
	call DrawWindowLayout_50
	call CopyTilemapBufferToScreen_50
	ld a, $00
	ld [wCommandStep], a
	ld a, $00
	ld [wCommandSubStep], a
	ret


Call_50_5B7A::
	res 7, [hl]
	ld a, [wJoyRepeat]
	and $40
	jp z, Jump_050_5b9a

jr_050_5b84:
	ld a, [hl]
	dec a
	bit 7, a
	call nz, Call_50_5BB7
	call Call_50_5BBC
	jp nc, StoreMenuCursor_50

	call Call_50_5BC5
	ld [hl], a
	jr nz, jr_050_5b84

	jp StoreMenuCursor_50


Jump_050_5b9a:
	ld a, [wJoyRepeat]
	and $80
	jp z, FinishMenuCursor_50

jr_050_5ba2:
	ld a, [hl]
	inc a
	cp b
	call nc, Call_50_5BBA
	call Call_50_5BBC
	jp nc, StoreMenuCursor_50

	call Call_50_5BC5
	ld [hl], a
	jr nz, jr_050_5ba2

	jp StoreMenuCursor_50


Call_50_5BB7::
	ld a, b
	dec a
	ret


Call_50_5BBA::
	xor a
	ret


Call_50_5BBC::
	push bc
	ld b, a
	or c
	call CheckBattlerPresent
	ld a, b
	pop bc
	ret


Call_50_5BC5::
	push bc
	ld b, a
	ld a, [wTargetCursorSkill]
	cp $30
	jr z, jr_050_5bd4

	cp $31
	jr z, jr_050_5bd4

	cp $bb

jr_050_5bd4:
	ld a, b
	pop bc
	ret


Call_50_5BD7::
	ld a, [wLinkFlags]
	rlca
	and $04
	ld c, a
	ld b, $03

jr_050_5be0:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_5bfb

	ld a, [wTargetSkill]
	cp $30
	jr z, jr_050_5bfb

	cp $31
	jr z, jr_050_5bfb

	cp $bb
	jr z, jr_050_5bfb

	ld a, c
	res 2, a
	call Call_50_5C00

jr_050_5bfb:
	inc c
	dec b
	jr nz, jr_050_5be0

	ret


Call_50_5C00::
	push bc
	ld hl, $0060

jr_050_5c04:
	ld a, c
	and $03
	jr z, jr_050_5c14

	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec c
	jr jr_050_5c04

jr_050_5c14:
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $01
	ld h, a
	call TilemapBufferAddr_50

jr_050_5c1f:
	ld a, [hl]
	cp $ff
	jr z, jr_050_5c2d

	cp $80
	jr nc, jr_050_5c2a

	ld [hl], $e0

jr_050_5c2a:
	inc hl
	jr jr_050_5c1f

jr_050_5c2d:
	pop bc
	ret


Call_50_5C2F::
	ld a, [wConfirmChoice]
	cp $83
	ret nz

	ld a, [wBattleType]
	cp $02
	ret nz

	ld a, [wLinkActive]
	or a
	ret


Call_50_5C40::
	ld a, $00
	ld [wRewardTotal], a
	ld a, $00
	ld [$dd24], a
	ld a, $00
	ld [$dd25], a
	ld a, [wEnemyCount]
	ld b, a
	ld hl, wEnemyDown
	ld de, wEnemyReward

jr_050_5c59:
	ld a, [hli]
	cp $01
	jr nz, jr_050_5c71

	push hl
	ld hl, wRewardTotal
	ld a, [de]
	add [hl]
	ld [hli], a
	inc de
	ld a, [de]
	adc [hl]
	ld [hli], a
	inc de
	ld a, [de]
	adc [hl]
	ld [hl], a
	inc de
	pop hl
	jr jr_050_5c74

jr_050_5c71:
	inc de
	inc de
	inc de

jr_050_5c74:
	dec b
	jr nz, jr_050_5c59

	ret


Call_50_5C78::
	ld a, [wLinkActive]
	or a
	jr nz, Call_50_5CB4

	call Call_50_6974
	call Call_50_6A65
	ld bc, $0304
	ld de, $0000

jr_050_5c8a:
	ld a, c
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_050_5c9a

	inc d

jr_050_5c9a:
	inc c
	dec b
	jr nz, jr_050_5c8a

	ld a, d
	or a
	jr nz, jr_050_5ca4

	ld e, $03

jr_050_5ca4:
	ld a, [wBattleArg0]
	cp $02
	jr c, jr_050_5cad

	ld a, $02

jr_050_5cad:
	add e
	add $ec
	call Call_50_6AA0
	ret


Call_50_5CB4::
	ld b, $03
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_5cc1

	ld c, $04
	jr jr_050_5cc3

jr_050_5cc1:
	ld c, $00

jr_050_5cc3:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_5cd4

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, jr_050_5cf5

jr_050_5cd4:
	inc c
	dec b
	jr nz, jr_050_5cc3

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_5ce4

	call Call_50_5D1F
	jr jr_050_5ce7

jr_050_5ce4:
	call Call_50_5D1A

jr_050_5ce7:
	ld a, $4f
	ld [wBattleTemp], a
	ld a, $ff
	ld [wBattleType], a
	ld a, $eb
	jr jr_050_5d0b

jr_050_5cf5:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_5d01

	call Call_50_5D1A
	jr jr_050_5d04

jr_050_5d01:
	call Call_50_5D1F

jr_050_5d04:
	ld a, $69
	ld [wBattleTemp], a
	ld a, $ed

jr_050_5d0b:
	call Call_50_6AA0
	ld a, $02
	call QueueMusic
	ld a, [wBattleTemp]
	call QueueSound
	ret


Call_50_5D1A::
	ld de, wMonMaster
	jr jr_050_5d22

Call_50_5D1F::
	ld de, $cd21

jr_050_5d22:
	ld hl, wTextArg0
	call CopyName
	ret


Call_50_5D29::
	ld a, $02
	ld [wBattlerReload], a
	ld a, [wBattleType]
	or a
	jr nz, jr_050_5d46

	ld a, [wRandomHigh]
	and $1f
	cp $1f
	jr z, jr_050_5d4c

	ld a, [wRandomLow]
	and $1f
	cp $1f
	jr z, jr_050_5d71

jr_050_5d46:
	ld a, $01
	ld [wRunTurn], a
	ret


jr_050_5d4c:
	ld hl, wBattleStep
	inc [hl]
	call Call_50_696D
	ld a, [wBattleArg0]
	cp $02
	jr c, jr_050_5d5c

	ld a, $02

jr_050_5d5c:
	ld c, a
	ld a, [wRandomLow]
	and $01
	ld b, a
	add a
	add b
	add c
	add $03
	call Call_50_6AA0
	ld a, $00
	ld [wBattlerReload], a
	ret


jr_050_5d71:
	ld hl, wBattleStep
	inc [hl]
	ld hl, wBattleStep
	inc [hl]
	call Call_50_696D
	ld a, $04
	ld [wSkillUser], a
	ld a, [wBattleArg0]
	cp $02
	jr c, jr_050_5d8a

	ld a, $02

jr_050_5d8a:
	ld c, a
	ld a, [wRandomHigh]
	and $01
	ld b, a
	add a
	add b
	add c
	add $09
	call Call_50_6AA0
	ld a, $01
	ld [wBattlerReload], a
	ret


Call_50_5D9F::
	ld a, $ff
	ld hl, wTurnOrder
	ld bc, $000a
	call FillMemory
	ld b, $08
	ld c, $00
	ld h, $00

jr_050_5db0:
	ld a, c
	ld e, a
	ld d, a
	ld a, c
	call CheckBattlerCanAct
	ld a, d
	and a
	jr nz, jr_050_5dbc

	inc h

jr_050_5dbc:
	inc c
	dec b
	jr nz, jr_050_5db0

	ld a, h
	or a
	jr nz, jr_050_5dc8

	ld hl, wBattleStep
	inc [hl]

jr_050_5dc8:
	ret


Call_50_5DC9::
	ld hl, sp+$00
	ld a, l
	ld [wBattleStackPtr], a
	ld a, h
	ld [$da7a], a
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [$c83f], a
	xor a
	ld hl, wBattleStep
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
	xor a
	ld [wBattleSubStep], a
	ld [wBattleAnimRunning], a
	call DisableSTATInterrupts
	xor a
	ld [wSkillAnimSprites], a
	xor a
	ld [wMenuOverlay], a
	xor a
	ld [$c87e], a
	ld hl, far_StartBattleScreen
	rst $10
	ret


Call_50_5E21::
	ld a, [wLinkActive]
	or a
	jr z, jr_050_5e3e

	call LinkFrameUpdate
	ld a, [wFadeState]
	or a
	ret nz

	call UpdateSkillAnimation
	ld a, [wBattleAnimRunning]
	or a
	ret z

	di
	ld hl, far_StepAnimation
	rst $10
	ei
	ret


jr_050_5e3e:
	ld a, [wFadeState]
	or a
	ret nz

	call UpdateSkillAnimation
	call UpdatePlayTime

Call_50_5E49::
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wSkillAnimActive]
	cp $01
	jp nz, Jump_050_5ede

	ld a, [wSkillAnim]
	cp $ff
	ret z

	ld a, [wSkillAnim]
	ld [wPaletteSet], a
	ld hl, far_LoadObjPaletteB
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, [wSkillAnim]
	ld hl, $5e84
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $8000
	call DecompressVRAM
	ld a, $02
	ld [wSkillAnimActive], a
	ret


SkillAnimGfx::
	db $00, $5a, $01, $5a, $02, $5a, $03, $5a, $04, $5a, $05, $5a, $06, $5a, $07, $5a
	db $08, $5a, $09, $5a, $0a, $5a, $0b, $5a, $0c, $5a, $0d, $5a, $0e, $5a, $0f, $5a
	db $10, $5a, $11, $5a, $12, $5a, $13, $5a, $14, $5a, $15, $5a, $16, $5a, $17, $5a
	db $18, $5a, $19, $5a, $1a, $5a, $1b, $5a, $1c, $5a, $1d, $5a, $1e, $5a, $1f, $5a
	db $0a, $5b, $0b, $5b, $0c, $5b, $0d, $5b, $0e, $5b, $0f, $5b, $10, $5b, $11, $5b
	db $12, $5b, $13, $5b, $14, $5b, $15, $5b, $16, $5b

Jump_050_5ede:
	ld a, [wBattleAnimRunning]
	or a
	jr z, jr_050_5ef9

	ld a, [wLinkActive]
	or a
	jr nz, jr_050_5eee

	ld hl, far_StepAnimation
	rst $10

jr_050_5eee:
	ld a, [wBattleAnimRunning]
	or a
	ret nz

	ld a, $00
	ld [wSkillAnimActive], a
	ret


jr_050_5ef9:
	ld a, [wBattleStep]
	cp $0d
	jr z, jr_050_5f17

	ld a, [wTextState]
	or a
	jr z, jr_050_5f17

	ld a, [wBattleAnimDone]
	or a
	jr z, jr_050_5f17

	ld hl, far_UpdateScreenEffect
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_050_5f17

	ret


jr_050_5f17:
	ld a, [wBattleAnimDone]
	or a
	jr z, jr_050_5f2f

	ld a, [wScreenEffect]
	cp $09
	jr nz, jr_050_5f2f

	ld hl, far_UpdateScreenEffect
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_050_5f2f

	ret


jr_050_5f2f:
	ld a, [wBattleType]
	cp $ff
	jr z, jr_050_5f5e

	ld a, [wBattleStep]
	rst $00

JumpTable_50_5F3A::
	dw Jump_50_5F6D
	dw Jump_50_5F93
	dw Jump_50_5FAE
	dw Jump_50_5FC1
	dw Jump_50_6051
	dw Jump_50_606F
	dw Jump_50_6079
	dw Jump_50_60B6
	dw Jump_50_60CB
	dw Jump_50_6AAC
	dw Jump_50_60ED
	dw Jump_50_62F0
	dw Jump_50_63C1
	dw Jump_50_63D2
	dw Jump_50_640A
	dw Jump_50_6951
	dw Jump_50_65DC
	dw Jump_50_65E6

jr_050_5f5e:
	ld a, [wSoundChannels]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

	xor a
	ld [wBattleType], a
	ret


Jump_50_5F6D::
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, [wPartyCount]
	or a
	jr nz, jr_050_5f86

	ld hl, $0c00
	call PrintSystemText
	ld hl, wBattleStep
	inc [hl]
	ret


jr_050_5f86:
	call Call_50_6974
	ld a, $05
	ld [wMonStats], a
	ld hl, wBattleStep
	inc [hl]
	ret


Jump_50_5F93::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_050_5fa3

	dec a
	ld [wMonStats], a
	ret


jr_050_5fa3:
	ld a, [wPartyCount]
	or a
	jp z, Jump_50_640A

	call Call_50_69C4
	ret


Jump_50_5FAE::
	call Call_50_5D29
	call Call_50_68FC
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


Jump_50_5FC1::
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wMenuChoice], a
	call Call_50_5D9F
	call Call_50_600D
	ld hl, wPersonalityNudge
	ld bc, $0008
	xor a
	call FillMemory
	ld a, [wPartyBattlers]
	ld b, a
	ld c, $00
	ld hl, wBattlerTactic
	call Call_50_5FF8
	ld a, [wLinkFlags]
	bit 1, a
	ret z

	ld a, [wEnemyCount]
	ld b, a
	ld c, $04
	ld hl, $dd07
	call Call_50_5FF8
	ret


Call_50_5FF8::
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6004

	ld a, [hl]
	and $0f
	ld [hli], a
	jr jr_050_6008

jr_050_6004:
	ld a, [hl]
	or $e0
	ld [hli], a

jr_050_6008:
	inc c
	dec b
	jr nz, Call_50_5FF8

	ret


Call_50_600D::
	ld de, wBattlerAction
	ld bc, $0800

jr_050_6013:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6046

	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr z, jr_050_6046

	ld a, c
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 7, [hl]
	jr nz, jr_050_6046

	ld a, c
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr nz, jr_050_6046

	ld a, $ff
	ld [de], a
	inc de
	jr jr_050_604b

jr_050_6046:
	ld a, $ff
	ld [de], a
	inc de
	ld [de], a

jr_050_604b:
	inc de
	inc c
	dec b
	jr nz, jr_050_6013

	ret


Jump_50_6051::
	jr jr_050_6067

Call_50_6053::
	call ClearTilemapBuffer_50
	call DrawEnemyPictures
	ld a, [wDebugStatsShown]
	or a
	jr nz, jr_050_6063

	call DrawMessageWindowAndPanel
	ret


jr_050_6063:
	call DrawBattlePanel
	ret


jr_050_6067:
	call Call_50_4017
	xor a
	ld [wBattleSubStep], a
	ret


Jump_50_606F::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, far_ChooseTargetsAndOrder
	rst $10
	ret


Jump_50_6079::
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wBattleSubStep], a
	ld [wBattleSubStep2], a
	ld [$dd75], a
	ld [wReactionKind], a
	ld [wSkillAnimPhase], a
	ld a, [wLinkActive]
	or a
	jr z, Jump_50_60B6

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

Jump_50_60B6::
	ld hl, far_RunActionStep
	rst $10
	call DrawBattlePanel
	call RefreshPanelDigits
	ld a, [wBattleStep]
	cp $08
	ret nz

	ld a, $05
	ld [wMonStats], a

Jump_50_60CB::
	ld a, [wMonStats]
	or a
	jr z, jr_050_60d6

	dec a
	ld [wMonStats], a
	ret


jr_050_60d6:
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wBattleArg0], a
	ld [wBattleArg1], a
	ld [wBattleArg2], a
	ld [wBattleSubStep], a
	call Call_50_6053
	jp Jump_50_6AAC


Jump_50_60ED::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wBGP
	ld a, $d2
	ld [hli], a
	ld a, $d2
	ld [hli], a
	ld [hl], $e2
	ld a, [wBattleArg2]
	cp $02
	jr nz, jr_050_6112

	ld hl, far_Call_52_76C8
	rst $10
	xor a
	ld [wBattleArg2], a
	ld a, $05
	ld [wMonStats], a
	ret


jr_050_6112:
	ld a, [wMonStats]
	or a
	jr z, jr_050_611d

	dec a
	ld [wMonStats], a
	ret


jr_050_611d:
	call ClearTilemapBuffer_50
	call DrawMessageWindowAndPanel
	call CopyTilemapBufferToScreen_50
	ld a, [wLinkActive]
	or a
	jr z, jr_050_6139

	ld a, $01
	ld [wLinkNoEnd], a
	ld a, $10
	ld [wBattleStep], a
	jp Jump_050_6196


jr_050_6139:
	call Call_50_5C40
	ld hl, far_SaveBattleResults
	rst $10
	ld a, [wBattlerReload]
	or a
	jr z, jr_050_6150

	xor a
	ld [wJoinCandidate], a
	ld hl, wBattleStep
	inc [hl]
	jr jr_050_6196

jr_050_6150:
	ld hl, wRewardTotal
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	jr z, jr_050_6192

	call Call_50_61E2
	ld hl, far_PruneLearnableSkills
	rst $10
	call Call_50_6197
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	ld a, e
	ldh [$ffd7], a
	ld hl, wTextArg0
	call Number24ToDecimal
	call Call_50_61CD
	ld a, b
	ld hl, $0b0e
	cp $01
	jr nz, jr_050_618f

	ld a, c
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg1
	call CopyName
	ld hl, $0b23

jr_050_618f:
	call PrintSystemText

jr_050_6192:
	ld hl, wBattleStep
	inc [hl]

Jump_050_6196:
jr_050_6196:
	ret


Call_50_6197::
	call Call_50_61CD
	ld a, [wRewardTotal]
	ld l, a
	ld a, [$dd24]
	ld h, a
	ld a, [$dd25]
	ld e, a
	ld a, b
	push af
	call Divide24
	pop af
	cp $02
	ret z

	cp $03
	jr z, jr_050_61c0

	ld a, l
	sub $01
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, e
	sbc $00
	ld e, a
	ret


jr_050_61c0:
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, e
	adc $00
	ld e, a
	ret


Call_50_61CD::
	ld b, $00
	ld a, [wParty]
	call Call_50_62DD
	ld a, [$ca8f]
	call Call_50_62DD
	ld a, [$ca90]
	call Call_50_62DD
	ret


Call_50_61E2::
	call Call_50_6197
	ld a, l
	ldh [$ffd8], a
	ld a, h
	ldh [$ffd9], a
	ld a, e
	ldh [$ffda], a
	ld a, [wRewardTotal]
	ld l, a
	ld a, [$dd24]
	ld h, a
	ld a, [$dd25]
	ld e, a
	ld a, $10
	call Divide24
	ld a, l
	ldh [hDivisorHigh], a
	ld a, h
	ldh [$ffdc], a
	ld a, e
	ldh [hFindY], a
	ld hl, wMonsters
	ld b, $14
	xor a
	ld [wCurPartyMember], a

Jump_050_6211:
	push hl
	ld a, [hl]
	or a
	jp z, Jump_050_62c4

	cp $02
	jr z, jr_050_6272

	ld a, l
	add $63
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	or a
	jp nz, Jump_050_62c4

	ld a, l
	add $e8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	cp $63
	jp z, Jump_050_62c4

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jp nc, Jump_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [hDivisorHigh]
	add [hl]
	ld [hli], a
	ld e, a
	ldh a, [$ffdc]
	adc [hl]
	ld [hli], a
	ld d, a
	ldh a, [hFindY]
	adc [hl]
	ld [hl], a
	ld c, a
	ld a, e
	sub $7f
	ld a, d
	sbc $96
	ld a, c
	sbc $98
	jr c, jr_050_62c4

	ld de, $967f
	ld c, $98
	ld [hl], c
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e
	jr jr_050_62c4

jr_050_6272:
	ld a, l
	add $4a
	ld l, a
	ld a, h
	adc $00
	ld h, a
	bit 7, [hl]
	jr nz, jr_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $63
	jr z, jr_050_62c4

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jr nc, jr_050_62c4

	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [$ffd8]
	add [hl]
	ld [hli], a
	ld e, a
	ldh a, [$ffd9]
	adc [hl]
	ld [hli], a
	ld d, a
	ldh a, [$ffda]
	adc [hl]
	ld [hl], a
	ld c, a
	ld a, e
	sub $7f
	ld a, d
	sbc $96
	ld a, c
	sbc $98
	jr c, jr_050_62c4

	ld de, $967f
	ld c, $98
	ld [hl], c
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e

Jump_050_62c4:
jr_050_62c4:
	pop hl
	push bc
	push hl
	call Call_50_689E
	ld hl, wCurPartyMember
	inc [hl]
	pop hl
	pop bc
	ld a, l
	add $95
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec b
	jp nz, Jump_050_6211

	ret


Call_50_62DD::
	cp $ff
	ret z

	ld hl, wMonStatus
	push af
	push bc
	call MonsterField
	pop bc
	pop af
	bit 7, [hl]
	ret nz

	ld c, a
	inc b
	ret


Jump_50_62F0::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wParty]
	call Call_50_6383
	jr nc, jr_050_630d

	ld a, [$ca8f]
	call Call_50_6383
	jr nc, jr_050_630d

	ld a, [$ca90]
	call Call_50_6383
	jr c, jr_050_6316

jr_050_630d:
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wCommandStep], a
	ret


jr_050_6316:
	ld b, $00

jr_050_6318:
	push bc
	ld a, b
	call Call_50_6383
	pop bc
	jr nc, jr_050_6337

	inc b
	ld a, b
	cp $14
	jr nz, jr_050_6318

	ld hl, wBattleStep
	inc [hl]
	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wCommandStep], a
	ld hl, far_CheckEnemyJoins
	rst $10
	ret


jr_050_6337:
	ld hl, far_RollLevelUpGains
	rst $10
	ld hl, far_ApplyLevelUp
	rst $10
	ret


UnusedPartyCode::
	db $fe, $ff, $c8, $ea, $c0, $ca, $78, $21, $15, $da, $85, $6f, $3e, $00, $8c, $67
	db $e5, $fa, $c0, $ca, $57, $21, $07, $01, $d7, $7a, $e1, $be, $c8, $77, $6f, $26
	db $0a, $11, $90, $c1, $cd, $7a, $09, $fa, $c0, $ca, $21, $c2, $ca, $cd, $3b, $22
	db $5d, $54, $21, $80, $c1, $cd, $80, $0c, $21, $21, $0b, $cd, $6d, $09, $fa, $25
	db $c8, $b7, $c9

Call_50_6383::
	cp $ff
	jr z, jr_050_63a2

	ld [wCurPartyMember], a
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	jr z, jr_050_63a2

	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	jr nz, jr_050_63a4

jr_050_63a2:
	scf
	ret


jr_050_63a4:
	ld hl, far_GetExpForNextLevel
	rst $10
	ld a, [wCurPartyMember]
	ld hl, wMonExp
	call MonsterField
	ldh a, [hNumber]
	ld b, a
	ld a, [hli]
	sub b
	ldh a, [$ffd6]
	ld b, a
	ld a, [hli]
	sbc b
	ldh a, [$ffd7]
	ld b, a
	ld a, [hli]
	sbc b
	ret


Jump_50_63C1::
	ld a, [wBattlerReload]
	or a
	jr nz, jr_050_63cc

	ld hl, far_LevelUpScreen
	rst $10
	ret


jr_050_63cc:
	ld a, $0e
	ld [wBattleStep], a
	ret


Jump_50_63D2::
	ld a, [wCommandStep]
	cp $24
	jr z, jr_050_63de

	ld a, [wTextState]
	or a
	ret nz

jr_050_63de:
	ld a, [wJoinCandidate]
	cp $ff
	jr nz, jr_050_63ea

	ld hl, wBattleStep
	inc [hl]
	ret


jr_050_63ea:
	ld a, [wJoinCandidate]
	sub $04
	add a
	ld hl, wEncSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wNewMonId], a
	ld a, [hl]
	ld [$da13], a
	ld hl, far_RemapMonId
	rst $10
	ld hl, far_RecruitScreen
	rst $10
	ret


Jump_50_640A::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, far_PruneLearnableSkills
	rst $10
	ld hl, wGameStarted
	set 7, [hl]
	ld a, $04
	call StartFade
	ld a, $01
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ld a, [wMapId]
	cp $5d
	jp nz, Jump_050_64e0

	ld hl, wGameStarted
	res 7, [hl]
	ld a, [$d999]
	cp $02
	jr z, jr_050_64a0

	cp $01
	jr z, jr_050_6486

	call Call_50_66D3
	xor a
	ld [wScriptRunning], a
	ld a, [wBattlerReload]
	cp $01
	ret nz

	ld a, $ff
	ld [wArenaRound], a
	ld hl, $0006
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ret


jr_050_6486:
	call Call_50_66D3
	xor a
	ld [wScriptRunning], a
	ld a, [wBattlerReload]
	cp $01
	jr z, jr_050_64af

	ld a, [wArenaRound]
	cp $02
	ret nz

	ld a, $02
	ld [$d999], a
	ret


jr_050_64a0:
	xor a
	ld [wScriptRunning], a
	ld a, $03
	ld [$d999], a
	ld a, [wBattlerReload]
	cp $01
	ret nz

jr_050_64af:
	ld a, $08
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld hl, wGameStarted
	res 7, [hl]
	ret


Jump_050_64e0:
	ld a, [wMapId]
	cp $52
	jr nz, jr_050_64f5

	call Call_50_67AE
	xor a
	ld [wScriptRunning], a
	ld hl, wGameStarted
	res 7, [hl]
	jr jr_050_6546

jr_050_64f5:
	ld a, [wBattleKind]
	cp $02
	jr nz, jr_050_6546

	ld a, [wBattlerReload]
	cp $01
	ret nz

	ld b, $00
	ld c, $00
	ld a, [wParty]
	call Call_50_6535
	ld a, [$ca8f]
	call Call_50_6535
	ld a, [$ca90]
	call Call_50_6535
	ld a, b
	cp c
	ret nz

	ld a, [wParty]
	ld hl, wMonHP
	call MonsterField
	ld [hl], $01
	inc hl
	ld [hl], $00
	ld a, [wParty]
	ld hl, wMonStatus
	call MonsterField
	ld [hl], $00
	ret


Call_50_6535::
	cp $ff
	ret z

	inc b
	ld hl, wMonStatus
	call MonsterField
	ld a, [hl]
	and $80
	ld [hl], a
	ret z

	inc c
	ret


jr_050_6546:
	ld a, [wBattlerReload]
	cp $01
	jr z, jr_050_6559

	ld a, [wBattleKind]
	cp $03
	ret nz

	ld a, $0e
	ld [wHiddenSprites], a
	ret


jr_050_6559:
	ld a, $08
	ld [$d92b], a
	ld hl, $0000
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
	ld hl, $0058
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ld a, $01
	ld [wWarpPending], a
	ld hl, wGameStarted
	res 7, [hl]
	ld a, [wGold]
	ld l, a
	ld a, [$ca4c]
	ld h, a
	ld a, [$ca4d]
	ld e, a
	ld a, $02
	call Divide24
	ld a, l
	ld [wGold], a
	ld a, h
	ld [$ca4c], a
	ld a, e
	ld [$ca4d], a
	ld hl, wBagItems
	ld b, $14

jr_050_65ab:
	ld a, [hl]
	or a
	jr z, jr_050_65c7

	cp $ff
	jr z, jr_050_65c7

	ld [wItemId], a
	push hl
	push bc
	ld hl, far_GetItemData
	rst $10
	pop bc
	pop hl
	ld a, [$da6d]
	bit 2, a
	jr nz, jr_050_65c7

	ld [hl], $ff

jr_050_65c7:
	inc hl
	dec b
	jr nz, jr_050_65ab

	ld hl, far_CompactBag
	rst $10
	xor a
	ldh [hPlayerFlags], a
	xor a
	ld [wScriptRunning], a
	ld hl, wFieldFlags
	res 0, [hl]
	ret


Jump_50_65DC::
	ld a, $01
	ld [wLinkSendByte], a
	ld hl, wBattleStep
	inc [hl]
	ret


Jump_50_65E6::
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

	ld hl, wMonMaster
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_65f9

	ld hl, $cd21

jr_050_65f9:
	ld de, wLinkPartnerName
	ld b, $08
	call Call_50_66CC
	ld a, [wLinkPrizeSlot]
	cp $ff
	jr z, jr_050_6663

	ld a, [wBattlerReload]
	or a
	jr z, jr_050_6663

	di
	ld hl, wMonsters
	ld de, sMonsters
	ld bc, $0ba4
	call Call_50_66B9
	ei
	ld a, [wLinkPrizeSlot]
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	ld b, $95
	call Call_50_66CC
	ld a, [wLinkPrizeSlot]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	di
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call Call_50_66B9
	ei
	ld hl, far_CompactMonsters
	rst $10
	di
	call SaveMonsters
	ei
	ld a, $00
	call Call_50_669F
	ld a, $01
	call Call_50_669F
	ld a, $02
	call Call_50_669F
	ld a, $14
	ld [wLinkPrizeSlot], a

jr_050_6663:
	ld a, $04
	call StartFade
	ld a, $06
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	xor a
	ld [wLinkMode], a
	ld [wLinkPhase], a
	xor a
	ld [wLinkFlags], a
	ld [wSerialLock], a
	xor a
	ld [wLinkActive], a
	xor a
	ld [wLinkReceivedLast], a
	xor a
	ld [wLinkSendByte], a
	xor a
	ld [wLinkCommand], a
	ret


Call_50_669F::
	ld c, a
	ld hl, wVSTeamSlots
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	cp [hl]
	ret z

	ld a, [wLinkPrizeSlot]
	cp [hl]
	jr z, jr_050_66b6

	ret nc

	dec [hl]
	ret


jr_050_66b6:
	ld [hl], $14
	ret


Call_50_66B9::
	ld a, $0a
	ld [$0100], a

jr_050_66be:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, jr_050_66be

	ld a, $00
	ld [$0100], a
	ret


Call_50_66CC::
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, Call_50_66CC

	ret


Call_50_66D3::
	ld a, [wArenaRound]
	cp $03
	ret z

	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
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
	ld [wEncSpecies], a
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
	ld [wEncCount], a
	ld a, [wArenaClass]
	ld b, a
	add a
	add b
	ld b, a
	ld a, [wArenaRound]
	add b
	add a
	ld hl, $6778
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wEncGfx], a
	ld a, [hl]
	ld [$d7cb], a
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	call Call_50_6766
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	call Call_50_6766
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	call Call_50_6766
	ld [$d7d0], a
	ld a, $01
	ld [$d7d1], a
	ret


Call_50_6766::
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wNewMonNameText]
	add $10
	ret


ArenaTeamGfx::
	db $0b, $00, $0a, $00, $11, $00, $0b, $00, $0a, $00, $da, $01, $0b, $00, $0a, $00
	db $0b, $00, $0b, $00, $0a, $00, $02, $00, $0b, $00, $0a, $00, $0b, $00, $0b, $00
	db $0a, $00, $0f, $00, $0b, $00, $0a, $00, $0c, $00, $0b, $00, $0a, $00, $13, $00
	db $0b, $00, $0a, $00, $14, $00

Call_50_67AE::
	ld hl, wEncGfx
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
	ld a, [wArenaRound]
	or a
	jr nz, jr_050_682d

	ld a, $01
	ld [wArenaRound], a
	ld a, $02
	ld [wEncCount], a
	ld a, [wArenaTeam1]
	ld l, a
	ld a, [$d9d2]
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	call Call_50_6766
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wEncCount]
	or a
	ret z

	ld a, [$d9d3]
	ld l, a
	ld a, [$d9d4]
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	call Call_50_6766
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [wEncCount]
	cp $01
	ret z

	ld a, [$d9d5]
	ld l, a
	ld a, [$d9d6]
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	call Call_50_6766
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ret


jr_050_682d:
	cp $01
	jr nz, jr_050_6898

	ld a, $02
	ld [wArenaRound], a
	ld a, $02
	ld [wEncCount], a
	ld a, [wArenaTeam2]
	ld l, a
	ld a, [$d9da]
	ld h, a
	ld a, l
	ld [wEncSpecies], a
	ld a, h
	ld [$da04], a
	call Call_50_6766
	ld [wEncGfx], a
	ld a, $01
	ld [$d7cb], a
	ld a, [wEncCount]
	or a
	ret z

	ld a, [$d9db]
	ld l, a
	ld a, [$d9dc]
	ld h, a
	ld a, l
	ld [$da05], a
	ld a, h
	ld [$da06], a
	call Call_50_6766
	ld [$d7cc], a
	ld a, $01
	ld [$d7cd], a
	ld a, [wEncCount]
	cp $01
	ret z

	ld a, [$d9dd]
	ld l, a
	ld a, [$d9de]
	ld h, a
	ld a, l
	ld [$da07], a
	ld a, h
	ld [$da08], a
	call Call_50_6766
	ld [$d7ce], a
	ld a, $01
	ld [$d7cf], a
	ret


jr_050_6898:
	ld a, $03
	ld [wArenaRound], a
	ret


Call_50_689E::
	ld a, [hl]
	or a
	ret z

	ld a, l
	add $4b
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	cp $63
	jr z, jr_050_68fb

	push af
	ld a, l
	add $01
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop af
	cp [hl]
	jr nc, jr_050_68fb

	push hl
	ld a, l
	add $b4
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	pop hl
	cp $01
	jr z, jr_050_68fb

	ld a, [hl]
	push af
	ld a, l
	add $ff
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	pop af
	ld b, [hl]
	ld [hl], a
	push bc
	push hl
	ld a, [wCurPartyMember]
	call Call_50_6383
	pop hl
	pop bc
	ld [hl], b
	jr c, jr_050_68fb

	ld a, l
	add $02
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ldh a, [hNumber]
	sub $01
	ld [hli], a
	ldh a, [$ffd6]
	sbc $00
	ld [hli], a
	ldh a, [$ffd7]
	sbc $00
	ld [hl], a

jr_050_68fb:
	ret


Call_50_68FC::
	ld a, [wBattlerReload]
	cp $02
	jr z, jr_050_6913

	cp $01
	jr z, jr_050_690d

	ld d, $00
	ld e, $03
	jr jr_050_6922

jr_050_690d:
	ld d, $03
	ld e, $01
	jr jr_050_6922

jr_050_6913:
	ld a, [wLinkActive]
	or a
	jr nz, jr_050_691f

	ld d, $00
	ld e, $01
	jr jr_050_6922

jr_050_691f:
	ld de, $0000

jr_050_6922:
	ld hl, wBattlerOrder
	ld b, $04
	ld c, $00

jr_050_6929:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6932

	ld [hl], d
	jr jr_050_6934

jr_050_6932:
	ld [hl], $ff

jr_050_6934:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6929

	ld hl, $dd17
	ld b, $04
	ld c, $04

jr_050_6940:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6949

	ld [hl], e
	jr jr_050_694b

jr_050_6949:
	ld [hl], $ff

jr_050_694b:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6940

	ret


Jump_50_6951::
	ret


jr_050_6952:
	ld de, wMonMaster
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_050_695f

	ld de, $cd21

jr_050_695f:
	ld hl, wTextArg0
	call CopyName
	ld a, $01
	ld [wTextIndex], a
	jp Jump_050_6a4f


Call_50_696D::
	call Call_50_6974
	call Call_50_6A65
	ret


Call_50_6974::
	ld a, [wLinkActive]
	or a
	jr nz, jr_050_6952

	ld a, [wEncCount]
	or a
	jr z, jr_050_69bb

	cp $01
	jr z, jr_050_6999

	ld a, [$dc40]
	ld b, a
	ld a, [$dc41]
	cp b
	jr z, jr_050_69ab

	ld b, a
	ld a, [$dc42]
	cp b
	jr z, jr_050_69b9

	ld a, $05
	jr jr_050_69bb

jr_050_6999:
	ld a, [$dc40]
	ld b, a
	ld a, [$dc41]
	cp b
	jr z, jr_050_69a7

	ld a, $02
	jr jr_050_69bb

jr_050_69a7:
	ld a, $01
	jr jr_050_69bb

jr_050_69ab:
	ld a, [$dc41]
	ld b, a
	ld a, [$dc42]
	cp b
	jr z, jr_050_69a7

	ld a, $03
	jr jr_050_69bb

jr_050_69b9:
	ld a, $04

jr_050_69bb:
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ret


Call_50_69C4::
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattleArg1]
	or a
	jr z, jr_050_69d3

	call Call_50_6A26
	ret


jr_050_69d3:
	ld a, [wBattleArg0]
	cp $05
	jr z, jr_050_6a1c

	cp $04
	jr z, jr_050_6a12

	cp $03
	jr z, jr_050_6a08

	cp $02
	jr z, jr_050_69fe

	cp $01
	jr z, jr_050_69f4

	call Call_50_6A65
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_69f4:
	call Call_50_6A65
	ld a, $01
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_69fe:
	call Call_50_6A71
	ld a, $02
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_6a08:
	call Call_50_6A65
	ld a, $01
	ld [wTextIndex], a
	jr jr_050_6a57

jr_050_6a12:
	call Call_50_6A65
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a57

jr_050_6a1c:
	call Call_50_6A71
	ld a, $02
	ld [wTextIndex], a
	jr jr_050_6a57

Call_50_6A26::
	ld a, [wBattleArg0]
	cp $05
	jr z, jr_050_6a45

	cp $04
	jr z, jr_050_6a3b

	call Call_50_6A94
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_6a3b:
	call Call_50_6A88
	ld a, $01
	ld [wTextIndex], a
	jr jr_050_6a4f

jr_050_6a45:
	call Call_50_6A94
	ld a, $00
	ld [wTextIndex], a
	jr jr_050_6a4f

Jump_050_6a4f:
jr_050_6a4f:
	call Call_50_6AA3
	ld hl, wBattleStep
	inc [hl]
	ret


jr_050_6a57:
	call Call_50_6AA3
	ld a, $01
	ld [wBattleArg1], a
	ld a, $05
	ld [wMonStats], a
	ret


Call_50_6A65::
	ld a, $04
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


Call_50_6A71::
	ld a, $04
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ld a, $05
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


Call_50_6A88::
	ld a, $05
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


Call_50_6A94::
	ld a, $06
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetSpeciesName_50
	ret


Call_50_6AA0::
	ld [wTextIndex], a

Call_50_6AA3::
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_50_6AAC::
	ld a, [wBattleSubStep]
	rst $00

JumpTable_50_6AB0::
	dw Jump_50_6ABC
	dw Jump_50_6B11
	dw Jump_50_6B25
	dw Jump_50_6C02
	dw Jump_50_6C9B
	dw Jump_50_6D0C

Jump_50_6ABC::
	ld hl, wSideFlags
	res 4, [hl]
	res 6, [hl]
	inc hl
	res 4, [hl]
	res 6, [hl]
	inc hl
	ld b, $08

jr_050_6acb:
	inc hl
	inc hl
	res 7, [hl]
	inc hl
	inc hl
	ld a, [hl]
	rrca
	and $55
	ld [hli], a
	ld a, [hl]
	and $30
	call nz, Call_50_6B06
	inc hl
	ld a, [hl]
	and $c0
	ld [hli], a
	xor a
	ld [hli], a
	dec b
	jr nz, jr_050_6acb

	ld b, $08
	xor a

jr_050_6ae9:
	ld [hli], a
	dec b
	jr nz, jr_050_6ae9

	ld a, [hl]
	and $03
	ld [hli], a
	ld a, [hl]
	and $03
	ld [hli], a
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wSkillUser], a
	ld [$d9f2], a
	ld [wPanelMode], a
	jr Jump_50_6B11

	db $c9

Call_50_6B06::
	ld a, [hl]
	and $cf
	ld e, a
	ld a, [hl]
	rrca
	and $10
	or e
	ld [hl], a
	ret


Jump_50_6B11::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr nc, Jump_50_6B25

	ld a, $05
	ld [wBattleSubStep], a
	jp Jump_50_6D0C


Jump_50_6B25::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $3f
	ld d, a
	ld a, [hl]
	and $c0
	jp z, Jump_050_6b5e

	ld b, $00
	push hl
	push de
	sub $40
	jr nz, jr_050_6b4f

	call GetSkillUserName
	ld a, $dd
	call Call_50_6AA0
	xor a
	ld b, $01

jr_050_6b4f:
	pop de
	pop hl
	or d
	ld [hl], a
	ld a, $05
	ld [wBattleSubStep], a
	ld a, b
	or a
	jp z, Jump_50_6D0C

	ret


Jump_050_6b5e:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, jr_050_6b74

	ld a, $05
	ld [wBattleSubStep], a
	jp Jump_50_6D0C


jr_050_6b74:
	bit 0, a
	jr z, jr_050_6b81

	ld a, $e1
	ld [wBattleArg0], a
	ld d, $10
	jr jr_050_6b88

jr_050_6b81:
	ld a, $e2
	ld [wBattleArg0], a
	ld d, $06

jr_050_6b88:
	ld a, [wSkillUser]
	call GetBattlerMaxHP
	ld a, d
	call Divide16
	ld a, h
	or l
	jr nz, jr_050_6b99

	ld hl, $0001

jr_050_6b99:
	call Call_50_6BC4
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, [wSkillUser]
	call GetSkillUserName
	ld hl, wTextArg1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Number16ToDecimal
	ld a, [wBattleArg0]
	call Call_50_6AA0
	ld a, $05
	ld [wMonStats], a
	ret


Call_50_6BC4::
	ld a, [wBattleArg0]
	cp $e1
	jr z, jr_050_6be7

	ld bc, $001e
	call CompareHLBC
	jr c, jr_050_6c01

	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $0b
	call Divide16
	add $1e
	ld l, a
	ld h, $00
	jr jr_050_6c01

jr_050_6be7:
	ld bc, $000a
	call CompareHLBC
	jr c, jr_050_6c01

	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $06
	call Divide16
	add $0a
	ld l, a
	ld h, $00

jr_050_6c01:
	ret


Jump_50_6C02::
	ld a, [wMonStats]
	or a
	jr z, jr_050_6c14

	dec a
	ld [wMonStats], a
	or a
	ret nz

	ld a, $fd
	call Call_50_6AA0
	ret


jr_050_6c14:
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerHP
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
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call CompareHLBC
	jr z, jr_050_6c40

	jr c, jr_050_6c40

	ld a, l
	sub c
	ld c, a
	ld a, h
	sbc b
	ld b, a
	jr jr_050_6c43

jr_050_6c40:
	ld bc, $0000

jr_050_6c43:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, b
	or c
	jr z, jr_050_6c59

	call DrawBattlePanel
	call RefreshPanelDigits
	ld a, $05
	ld [wBattleSubStep], a
	jp Jump_50_6D0C


jr_050_6c59:
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, far_BlankEnemyPicture
	rst $10
	ld a, [wSkillUser]
	ld [wBattleArg0], a
	ld hl, far_DefeatBattler
	rst $10
	call UpdateStatusIcon_50
	ld a, $04
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	call GetSkillUserName
	ld a, $ea
	call Call_50_6AA0
	call DrawBattlePanel
	call RefreshPanelDigits
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wSkillUser]
	cp $04
	ret c

	cp $07
	ret z

	ld a, [wSkillUser]
	ld [wJoinCandidate], a
	ret


Jump_50_6C9B::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03
	ld a, [wLinkActive]
	or a
	jr nz, jr_050_6cd3

	ld a, [wSkillUser]
	cp $04
	jr c, jr_050_6cd3

jr_050_6cb4:
	ld a, c
	call CheckBattlerPresent
	jr nc, Jump_50_6D0C

	inc c
	dec b
	jr nz, jr_050_6cb4

jr_050_6cbe:
	ld a, $00
	ld [wBattlerReload], a

jr_050_6cc3:
	ld a, $0a
	ld [wBattleStep], a
	ld a, $02
	call QueueMusic
	ld a, $02
	ld [wBattleArg2], a
	ret


jr_050_6cd3:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6ce4

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, Jump_50_6D0C

jr_050_6ce4:
	inc c
	dec b
	jr nz, jr_050_6cd3

	ld a, $01
	ld [wBattlerReload], a
	ld a, [wLinkActive]
	or a
	jr z, jr_050_6cc3

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_6d03

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_050_6cc3

	jr jr_050_6cbe

jr_050_6d03:
	ld a, [wSkillUser]
	cp $04
	jr c, jr_050_6cc3

	jr jr_050_6cbe

Jump_50_6D0C::
	ld hl, wSkillUser
	inc [hl]
	ld a, [hl]
	cp $08
	jr z, jr_050_6d22

	call CheckBattlerPresent
	jr c, Jump_50_6D0C

	ld a, $01
	ld [wBattleSubStep], a
	jp Jump_50_6B11


jr_050_6d22:
	ld bc, $0300
	ld de, $0001
	ld hl, wBattlerOrder
	ld a, [wLinkActive]
	or a
	jr z, jr_050_6d33

	ld e, $00

jr_050_6d33:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d3c

	ld [hl], d
	jr jr_050_6d3e

jr_050_6d3c:
	ld [hl], $ff

jr_050_6d3e:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6d33

	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d4b

	ld [hl], $01

jr_050_6d4b:
	inc hl
	inc c
	ld bc, $0304

jr_050_6d50:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d59

	ld [hl], e
	jr jr_050_6d5b

jr_050_6d59:
	ld [hl], $ff

jr_050_6d5b:
	inc hl
	inc c
	dec b
	jr nz, jr_050_6d50

	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_6d68

	ld [hl], $01

jr_050_6d68:
	inc hl
	inc c
	ld a, $03
	ld [wBattleStep], a
	ld hl, wRunTurn
	ld a, [hl]
	cp $ff
	ret z

	inc [hl]
	ret


;@ def UpdatePlayTime()
;@ path: system/clock
;@ Counts the play time on by one frame: 60 frames make a second, 60 seconds a minute,
;@ 60 minutes an hour. The clock stops at 99:59:59.
;@ test: wPlayFrames = rand(0, 59); wPlaySeconds = rand(0, 59); wPlayMinutes = rand(0, 59); wPlayHours = rand(0, 99)
UpdatePlayTime::
;> wPlayFrames += 1
	ld a, [wPlayFrames]
	inc a
	ld [wPlayFrames], a
;> if wPlayFrames != 60:
;>     return
	cp $3c
	ret nz

;> wPlayFrames = 0
	xor a
	ld [wPlayFrames], a
;> wPlaySeconds += 1
	ld a, [wPlaySeconds]
	inc a
	ld [wPlaySeconds], a
;> if wPlaySeconds != 60:
;>     return
	cp $3c
	ret nz

;> wPlaySeconds = 0
	xor a
	ld [wPlaySeconds], a
;> wPlayMinutes += 1
	ld a, [wPlayMinutes]
	inc a
	ld [wPlayMinutes], a
;> if wPlayMinutes != 60:
;>     return
	cp $3c
	ret nz

;> wPlayMinutes = 0
	xor a
	ld [wPlayMinutes], a
;> wPlayHours += 1
	ld a, [wPlayHours]
	inc a
	ld [wPlayHours], a
;> if wPlayHours != 100:
;>     return
	cp $64
	ret nz

;> wPlayHours = 99                       # the clock stops at 99:59:59
	ld a, $63
	ld [wPlayHours], a
;> wPlayMinutes = 59
	ld a, $3b
	ld [wPlayMinutes], a
;> wPlaySeconds = 59
	ld [wPlaySeconds], a
;> wPlayFrames = 0
	xor a
	ld [wPlayFrames], a
	ret


;@ path: battle/panel
;@ Window layout (DrawWindowLayout_50 format: a u16 buffer offset, then tile rows ended by
;@ $D8, $D9 at the end) of the party panel at the top of the battle screen with three
;@ monsters: name tiles $70-$73 / $74-$77 / $78-$7B, slot marks $DA-$DC, an "HP" row
;@ ($E1) and an "MP" row ($E2) under each name; $EC/$EB/$ED a divider line.
StatusWindow3::
	dw $0000                     ; row 0, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: battle/panel
;@ Party panel layout for two monsters (see StatusWindow3).
StatusWindow2::
	dw $0000                     ; row 0, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/panel
;@ Party panel layout for one monster (see StatusWindow3).
StatusWindow1::
	dw $0000                     ; row 0, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/menu
;@ Layout of the battle menu at the bottom left: four commands in two columns (their
;@ words are text tiles $7C-$8B printed into VRAM), cursor places in BattleMenuCursors.
BattleMenuWindow::
	dw $01a0                     ; row 13, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/tactics
;@ Layout of a small two-row window at the bottom left; only UnusedTacticWhoMenu draws it.
TacticWhoWindow::
	dw $01a0                     ; row 13, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $84, $9c, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Name plate (tiles $6C-$6F) of the monster that gets direct orders, row 8.
CommandNameWindow::
	dw $0100                     ; row 8, column 0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/tactics
;@ Layout of the tactic window: four rows of words (text tiles $86-$96), cursor places
;@ in TacticCursors.
TacticWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $96, $88, $91, $8d, $87, $8a, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8b, $86, $94, $8a, $95, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $91, $8e, $89, $86, $90, $8e, $8c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $90, $8b, $8b, $91, $8f, $95, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: battle/item
;@ Layout of the item list in battle: four rows of item names printed into tiles $8C-$AF.
BattleItemWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/item
;@ Layout of a two-choice window under a title (tiles $85-$87), cursor places in
;@ ItemUseCursors.
ItemUseWindow::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $7e, $84, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $87, $89, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/item
;@ Layout of the window that picks an own monster for an item: a title and the three
;@ name tiles $70-$7B, cursor places in AllyTargetCursors.
ItemAllyTargetWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the window that picks an own monster as a skill's target (as
;@ ItemAllyTargetWindow with another title).
SkillAllyTargetWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $86, $88, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the window that picks an enemy: three rows of enemy names printed into tiles
;@ $8C-$A9, cursor places in EnemyTargetCursors.
EnemyTargetWindow::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $95, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout (DrawWindowLayout_50 format) that nothing draws: a small 4x3 window at
;@ row 8, column 0.
UnusedWindow7177::
	dw $0100                     ; row 8, column 0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $e0, $d5, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: four text rows of tiles $36-$59 at row 2, column 8.
UnusedWindow719C::
	dw $0048                     ; row 2, column 8
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $51, $52, $53, $54, $55, $56, $57, $58, $59, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/run
;@ Layout of the small yes/no window (tiles $D4-$D6 and $9D-$9E) at row 8, column 14, used
;@ when giving up a tournament battle; cursor places in YesNoCursors.
YesNoWindow::
	dw $010e                     ; row 8, column 14
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9e, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a title and four rows at row 2, column 0.
UnusedWindow7238::
	dw $0040                     ; row 2, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $90, $91, $92, $93, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $94, $95, $96, $97, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $98, $99, $9a, $9b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: two rows at row 8, column 13.
UnusedWindow7292::
	dw $010d                     ; row 8, column 13
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a title and the three name tiles, at row 9.
UnusedWindow72BC::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a full-width window of three text rows (tiles
;@ $00-$35) at row 11.
UnusedWindow7306::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: a small window at row 6.
UnusedWindow739B::
	dw $00c0                     ; row 6, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $9c, $d6, $d5, $e0, $e2, $e3, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: two rows at row 8, column 14.
UnusedWindow73CF::
	dw $010e                     ; row 8, column 14
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a0, $a1, $a2, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a3, $a4, $a5, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: four text rows of tiles $24-$4B at row 4.
UnusedWindow73F4::
	dw $0080                     ; row 4, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $48, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $49, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $4a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $4b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused
;@ Window layout that nothing draws: two rows at row 8, column 12.
UnusedWindow7474::
	dw $010c                     ; row 8, column 12
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a6, $a7, $a8, $a9, $aa, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/tactics
;@ Name plate (tiles $6C-$6F) of the monster whose tactic is being set, row 6.
TacticNameWindow::
	dw $00c0                     ; row 6, column 0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the order window for one monster: three rows (attack, skill, defend; text
;@ tiles $80-$8A), cursor places in CommandCursors.
CommandWindow::
	dw $0160                     ; row 11, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $89, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $82, $86, $81, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $83, $8a, $85, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/orders
;@ Layout of the skill list in battle: four rows of skill names printed into tiles $8C-$AF,
;@ cursor places in SkillListCursors.
BattleSkillWindow::
	dw $0120                     ; row 9, column 0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ def NextBufferColumn_50(addr: hl) -> hl
;@ path: battle/screen
;@ Steps a tile address one column to the right, wrapping from column 31 back to column 0
;@ of the same 32-tile row.
NextBufferColumn_50::
;>@r return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@r
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@r
	ret


;@ def BattleOffsetToMap(offset: hl) -> hl
;@ path: battle/screen
;@ Turns an offset (row * 32 + column) into a BG map address counted from wBattleBGMap,
;@ wrapping around inside the 1 KiB map.
BattleOffsetToMap::
;> addr = wBattleBGMap + offset
	ld a, [wBattleBGMap]
	add l
	ld l, a
	ld a, [wBattleBGMap + 1]
	adc h
;>@r return (wBattleBGMap & 0xFC00) | (addr & 0x03FF)
	and $03
	ld h, a
	ld a, [wBattleBGMap + 1]
	and $fc
	or h
	ld h, a
;=@r
	ret


;@ def TilemapBufferAddr_50(offset: hl) -> hl
;@ path: battle/screen
;@ Address of an offset (row * 32 + column) in wTilemapBuffer.
TilemapBufferAddr_50::
;>@r return wTilemapBuffer + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@r
	ret


;@ def PosToScreenMap_50(pos: hl) -> hl
;@ path: battle/screen
;@ BG map address of a screen position (row * 32 + column): the start of its row through
;@ BattleOffsetToMap, then stepped right column by column so the column wraps within the
;@ row.
PosToScreenMap_50::
;> addr = BattleOffsetToMap(pos & 0xFFE0)
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call BattleOffsetToMap
;> for i in range(pos & 0x1F):
	ld a, b
	and $1f
	jr z, .done

	ld b, a
.column
;>     addr = NextBufferColumn_50(addr)
	call NextBufferColumn_50
	dec b
	jr nz, .column

.done
;> return addr
	pop bc
	ret


;@ def DrawWindowLayoutVRAM_50(layout: de)
;@ path: unused
;@ Unused: draws a window layout (see DrawWindowLayout_50) straight to the BG map instead
;@ of into wTilemapBuffer. Nothing calls it.
;@ test: skip writes VRAM while waiting for the LCD
DrawWindowLayoutVRAM_50::
;>@row addr = PosToScreenMap_50(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@row
	call PosToScreenMap_50
;> wLayoutRow = addr
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
.loop
;> while True:
;>     t = mem[layout]; layout += 1
	ld a, [de]
	inc de
;>     if t == 0xD9:                      # end of the layout
;>         return
	cp $d9
	ret z

;>     if t == 0xD8:                      # next row, wrapping inside the BG map
	cp $d8
	jr nz, .tile

;>@nl         wLayoutRow = 0x9800 | ((wLayoutRow + 32) & 0x03FF)
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
	add $20
;=@nl
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, h
	and $03
;=@nl
	or $98
	ld h, a
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
;>         addr = wLayoutRow
	jr .loop

.tile
;>     else:
;>         WriteVRAM(addr, t)
	call WriteVRAM
;>         addr = NextBufferColumn_50(addr)
	call NextBufferColumn_50
	jr .loop

;@ def DrawWindowLayout_50(layout: de)
;@ path: battle/screen
;@ Draws a window layout into wTilemapBuffer. A layout is a u16 offset (row * 32 + column
;@ in the 32-wide buffer) followed by tile numbers; $D8 starts the next row below the
;@ first tile of the current one, $D9 ends the layout. Window tiles: $FA/$EF/$FB top
;@ frame, $FE/$FF left and right sides, $FC/$EE/$FD bottom frame, $EC/$EB/$ED a divider,
;@ $E0 blank.
;@ test: skip reads a layout from ROM
DrawWindowLayout_50::
;>@row p = TilemapBufferAddr_50(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@row
	call TilemapBufferAddr_50
;> wLayoutRow = p
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a

.loop
;> while (t := mem[layout]) != 0xD9:
;>     layout += 1
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     if t == 0xD8:                      # next row
	cp $d8
	jr nz, .tile

;>@nl         wLayoutRow += 32
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
	add $20
;=@nl
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [wLayoutRow], a
;=@nl
	ld a, h
	ld [wLayoutRow + 1], a
;>         p = wLayoutRow
	jr .loop

.tile
;>     else:
;>         mem[p] = t; p += 1
	ld [hli], a
	jr .loop

;@ def RefreshPanelDigits()
;@ path: battle/panel
;@ Copies the changing parts of the party panel from wTilemapBuffer to the screen for each
;@ monster of the side shown (own side, or the link master's partner side): the mark after
;@ the name and the two 3-digit HP / MP numbers.
;@ test: skip writes VRAM while waiting for the LCD
RefreshPanelDigits::
;> count = wPartyBattlers
	ld a, [wPartyBattlers]
	ld c, a
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .count

;>     count = wEnemyCount               # the link master shows the other side's team
	ld a, [wEnemyCount]
	ld c, a

.count
;> CopyPanelSlotToScreen(0x25, 0x62)    # first monster
	push bc
	ld b, $25
	ld c, $62
	call CopyPanelSlotToScreen
	pop bc
;> if count == 1:
;>     return
	dec c
	ret z

;> CopyPanelSlotToScreen(0x2B, 0x68)    # second monster
	push bc
	ld b, $2b
	ld c, $68
	call CopyPanelSlotToScreen
	pop bc
;> if count == 2:
;>     return
	dec c
	ret z

;> CopyPanelSlotToScreen(0x31, 0x6E)    # third monster
	push bc
	ld b, $31
	ld c, $6e
	call CopyPanelSlotToScreen
	pop bc
	ret


;@ def CopyPanelSlotToScreen(mark: b, digits: c)
;@ path: battle/panel
;@ Copies one tile at offset `mark` and two rows of three tiles at offsets `digits` and
;@ `digits` + 32 from wTilemapBuffer to the BG map at $9800.
;@ test: skip writes VRAM while waiting for the LCD
CopyPanelSlotToScreen::
;>@m WriteVRAM(0x9800 + mark, wTilemapBuffer[mark])
	ld l, b
	ld h, $98
	ld a, b
	ld de, wTilemapBuffer
	add e
	ld e, a
;=@m
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	call WriteVRAM
;>@r CopyTileRowToScreen_50(0x9800 + digits, wTilemapBuffer + digits, 3)
	ld b, $03
	ld l, c
	ld h, $98
	ld a, c
	ld de, wTilemapBuffer
	add e
;=@r
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call CopyTileRowToScreen_50
;>@r2 CopyTileRowToScreen_50(0x9820 + digits, wTilemapBuffer + 0x20 + digits, 3)
	ld b, $03
	ld a, c
	add $20
	ld l, a
	ld h, $98
	ld de, wTilemapBuffer
;=@r2
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call CopyTileRowToScreen_50
;=@r2
	ret


;@ def CopyTilemapBufferToScreen_50()
;@ path: battle/screen
;@ Copies the whole wTilemapBuffer (18 rows of 32 tiles) to the BG map at wBattleBGMap,
;@ wrapping inside the 1 KiB map.
;@ test: skip writes VRAM while waiting for the LCD
CopyTilemapBufferToScreen_50::
;> dest = wBattleBGMap
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [wBattleBGMap + 1]
	ld h, a
;> src = wTilemapBuffer
	ld de, wTilemapBuffer
;> for row in range(18):
	ld c, $12

.row
;>     src = CopyTileRowToScreen_50(dest, src, 32)
	ld b, $20
	push hl
	call CopyTileRowToScreen_50
	pop hl
;>@d     dest = 0x9800 | ((dest + 32) & 0x03FF)
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
;=@d
	ld h, a
	pop bc
	dec c
	jr nz, .row

	ret


;@ def CopyTileRowToScreen_50(dest: hl, src: de, count: b) -> de
;@ path: battle/screen
;@ Writes `count` tiles from `src` to the BG map at `dest`, the column wrapping within the
;@ 32-tile row. Returns the source address after the last tile.
;@ test: skip writes VRAM while waiting for the LCD
CopyTileRowToScreen_50::
.loop
;> for i in range(count):
;>     WriteVRAM(dest, mem[src])
	ld a, [de]
	call WriteVRAM
;>@n     dest = (dest & 0xFFE0) | ((dest + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@n
	ld l, a
	pop af
	or l
	ld l, a
;>     src += 1
	inc de
	dec b
	jr nz, .loop

;> return src
	ret


;@ def PrintTextToTiles_50(tiles: hl, lines: e, length: d)
;@ path: battle/screen
;@ Prints the text wTextGroup / wTextIndex at once into the letter tiles at `tiles` (a text
;@ box of `lines` lines of `length` letters), then restores the text box settings.
;@ test: skip prints through another bank
PrintTextToTiles_50::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines = wTextBoxLines
;> saved_length = wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = length
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def PrintNameToTiles_50(tiles: hl, name: de)
;@ path: battle/screen
;@ Prints a name (copied into wTextArg0, shown by text $0200) at once into the four letter
;@ tiles at `tiles`, then restores the text box settings.
;@ test: skip prints through another bank
PrintNameToTiles_50::
;> CopyName(wTextArg0, name)
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines = wTextBoxLines
;> saved_length = wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0                        # text $0200 shows wTextArg0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def ClearTilemapBuffer_50()
;@ path: battle/screen
;@ Fills wTilemapBuffer (576 tiles) with the blank tile $E0.
ClearTilemapBuffer_50::
;>@f fill(wTilemapBuffer, 0x240, 0xE0)
	ld hl, wTilemapBuffer
	ld bc, $0240
.loop
	ld a, $e0
	ld [hli], a
	dec bc
;=@f
	ld a, b
	or c
	jr nz, .loop

	ret


;@ def ClearScreenMap_50()
;@ path: unused
;@ Unused: fills the whole BG map at $9800 with the blank tile $E0.
;@ test: skip writes VRAM while waiting for the LCD
ClearScreenMap_50::
;>@l for i in range(0x400):
	ld hl, $9800
	ld bc, $0400
.loop
;>     WriteVRAMInc(0x9800 + i, 0xE0)
	ld a, $e0
	call WriteVRAMInc
;=@l
	dec bc
	ld a, b
	or c
	jr nz, .loop

	ret

;@ def UpdateListCursor_50(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Moves the cursor of a paged list (skills, items): `cursor` points at the row (bit 7 =
;@ chosen) and the page number, `table` at the list's cursor table (the page marker
;@ position, then one position per row), `rows` is the page size and `count` the number of
;@ entries. Left / Right turn the pages (wrapping, and pulling the row up on a short last
;@ page); otherwise the page number is drawn and Up / Down move within the page
;@ (UpdateMenuCursor_50). Pages don't turn while a text prints.
;@ test: skip draws to the screen
UpdateListCursor_50::
;> turned = False
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> rows_table = table + 2
	inc de
	inc de
;> if not wTextState:
	ld a, [wTextState]
	or a
	jp nz, .draw

;>     if wJoyRepeat & 0x20:              # Left: previous page, wrapping to the last
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .right

;>         page = mem[cursor + 1] - 1
	inc hl
	ld a, [hl]
	dec a
	push af
;>@pl         pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@pl
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
;>         turned = True
;>         if page < 0:
	cp c
	jr c, .setPage

;>             page = pages - 1
	ld a, c
	dec a
	jr .setPage

.right
;>     elif wJoyRepeat & 0x10:            # Right: next page, wrapping to the first
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .draw

;>         page = mem[cursor + 1] + 1
	inc hl
	ld a, [hl]
	inc a
	push af
;>@pr         pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@pr
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
;>         turned = True
;>         if page >= pages:
	cp c
	jr c, .setPage

;>             page = 0
	ld a, $00

.setPage
;> if turned:
;>     mem[cursor + 1] = page
	ld [hld], a
;>     if page == pages - 1:              # the last page may be short
	dec c
	cp c
	jr nz, RestartMenuCursor_50

;>@rest         rest = count % rows
	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
;=@rest
	call Divide8
	pop bc
	pop de
;>         if rest != 0 and mem[cursor] > rest - 1:
	or a
	jr z, RestartMenuCursor_50

	dec a
	cp [hl]
	jr nc, RestartMenuCursor_50

;>             mem[cursor] = rest - 1
	ld [hl], a
;>     return RestartMenuCursor_50(cursor, rows_table)
	jr RestartMenuCursor_50

.draw
;>@pn DrawPageNumber_50(cursor, rows_table, rows, count)
	push bc
	push de
	push hl
	call DrawPageNumber_50
	pop hl
	pop de
;=@pn
	pop bc
;>@dm q, r = divmod(count - 1, rows)
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;> wListLastRows = r
	ld [wListLastRows], a
;> last_page = q
	ld a, b
	pop bc
	pop de
	ld c, a
;> if mem[cursor + 1] == last_page:
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateMenuCursor_50

;>     rows = wListLastRows + 1          # rows on the last page
	ld a, [wListLastRows]
	inc a
	ld b, a
;> UpdateMenuCursor_50(cursor, rows, rows_table)

;@ def UpdateMenuCursor_50(cursor: hl, rows: b, table: de)
;@ path: menu/cursor
;@ Moves a menu cursor with Up / Down (wrapping over `rows` rows), restarts the blink when
;@ it moved, marks it chosen (bit 7) when A is pressed, and draws it at the positions of
;@ `table` (DrawMenuCursor_50).
;@ test: skip draws to the screen
UpdateMenuCursor_50::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:                  # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .down

;>     row = mem[cursor] - 1
	ld a, [hl]
	dec a
;>     if row < 0:
	cp b
	jr c, StoreMenuCursor_50

;>         row = rows - 1
	dec b
	ld a, b
;>     return StoreMenuCursor_50(cursor, row, table)
	jr StoreMenuCursor_50

.down
;> if wJoyRepeat & 0x80:                  # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, FinishMenuCursor_50

;>     row = mem[cursor] + 1
	ld a, [hl]
	inc a
;>     if row >= rows:
	cp b
	jr c, StoreMenuCursor_50

;>         row = 0
	ld a, $00
;>     return StoreMenuCursor_50(cursor, row, table)
;> FinishMenuCursor_50(cursor, table)

;@ def StoreMenuCursor_50(cursor: hl, row: a, table: de)
;@ path: menu/cursor
;@ Tail of the cursor routines when the cursor moved: stores the new row, then
;@ RestartMenuCursor_50.
;@ test: skip draws to the screen
StoreMenuCursor_50::
;> mem[cursor] = row
	ld [hl], a
;> RestartMenuCursor_50(cursor, table)

;@ def RestartMenuCursor_50(cursor: hl, table: de)
;@ path: menu/cursor
;@ Restarts the cursor blink (so the moved cursor shows at once), then FinishMenuCursor_50.
;@ test: skip draws to the screen
RestartMenuCursor_50::
;> wCursorBlinkTimer = 0
	xor a
	ld [wCursorBlinkTimer], a
	push hl
	push de
	pop de
	pop hl
;> FinishMenuCursor_50(cursor, table)

;@ def FinishMenuCursor_50(cursor: hl, table: de)
;@ path: menu/cursor
;@ Tail of the cursor routines: A marks the cursor chosen (bit 7), then it is drawn at its
;@ position of `table` (DrawMenuCursor_50).
;@ test: skip draws to the screen
FinishMenuCursor_50::
;> if wJoyPressed & 0x01:                 # A chooses
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw

;>     mem[cursor] |= 0x80
	set 7, [hl]

.draw
;> DrawMenuCursor_50(mem[cursor], table)
	ld a, [hl]
	call DrawMenuCursor_50
	ret


;@ def UpdateGridCursor_50(cursor: hl, table: de)
;@ path: menu/cursor
;@ Moves the cursor of a 2 x 2 menu (the battle menu): Up / Down switch the row (bit 0),
;@ Left / Right the column (bit 1). Then as UpdateMenuCursor_50: blink restart, A chooses,
;@ the cursor is drawn.
;@ test: skip draws to the screen
UpdateGridCursor_50::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0xC0:                  # Up or Down: the other row
	ld a, [wJoyRepeat]
	and $c0
	jr z, .leftRight

;>     return StoreMenuCursor_50(cursor, mem[cursor] ^ 0x01, table)
	ld a, [hl]
	xor $01
	jr StoreMenuCursor_50

.leftRight
;> if not wJoyRepeat & 0x30:              # Left or Right: the other column
;>     return FinishMenuCursor_50(cursor, table)
	ld a, [wJoyRepeat]
	and $30
	jr z, FinishMenuCursor_50

;> return StoreMenuCursor_50(cursor, mem[cursor] ^ 0x02, table)
	ld a, [hl]
	xor $02
	jr StoreMenuCursor_50

;@ def ResetCursorBlink_50()
;@ path: menu/cursor
;@ Restarts the cursor blink, so the next DrawMenuCursor_50 draws at once.
ResetCursorBlink_50::
;> wCursorBlinkTimer = 0
	xor a
	ld [wCursorBlinkTimer], a
	ret


;@ def DrawMenuCursor_50(sel: a, table: de)
;@ path: menu/cursor
;@ Redraws the cursor column of a menu: every row of the cursor table (screen positions up
;@ to $FFFF) gets a blank $E0, except row sel & $7F, which gets the arrow $E8 (blinking:
;@ blank while wCursorBlinkTimer bit 4 is set) or the filled arrow $E9 once chosen (bit 7).
;@ Drawn to the screen and into wTilemapBuffer. While nothing is chosen it only redraws
;@ every 16th frame.
;@ test: skip writes VRAM while waiting for the LCD
DrawMenuCursor_50::
;> if not sel & 0x80:
	ld c, a
	bit 7, a
	jr nz, .draw

;>     t = wCursorBlinkTimer & 0x0F
	ld a, [wCursorBlinkTimer]
	and $0f
	push af
;>     wCursorBlinkTimer += 1
	ld a, [wCursorBlinkTimer]
	inc a
	ld [wCursorBlinkTimer], a
;>     if t != 0:
;>         return
	pop af
	ld a, c
	ret nz

.draw
;> row = 0
	ld c, a
	ld b, $00
.loop
;> while True:
;>     pos = mem16[table]; table += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if pos == 0xFFFF:
;>         return
	and l
	cp $ff
	ret z

;>@a     addr = PosToScreenMap_50(pos); wLayoutRow = pos
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
	push de
	push bc
;=@a
	call PosToScreenMap_50
	pop bc
	pop de
;>     if sel & 0x7F != row:
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .tile

;>         tile = 0xE0
;>     elif sel & 0x80:
	ld a, $e9
	bit 7, c
	jr nz, .tile

;>         tile = 0xE9
;>     elif wCursorBlinkTimer & 0x10:
	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, .tile

;>         tile = 0xE0
;>     else:
;>         tile = 0xE8
	ld a, $e8

.tile
;>     WriteVRAM(addr, tile)
	call WriteVRAM
;>@buf     mem[TilemapBufferAddr_50(pos)] = tile
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
;=@buf
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@buf
	ld [hl], a
;>     row += 1
	inc b
	jr .loop

;@ def DrawPageNumber_50(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ When the list has more entries than a page has rows, draws the page number
;@ (cursor[1] + 1, as tile $F1 + page) one tile left of the page marker position (the
;@ first entry of the cursor table; `table` points just past it), on the screen and in
;@ wTilemapBuffer.
;@ test: skip writes VRAM while waiting for the LCD
DrawPageNumber_50::
;> if rows >= count:
;>     return
	ld a, b
	cp c
	ret nc

;> page = mem[cursor + 1]
	inc hl
	ld c, [hl]
;>@pos pos = mem16[table - 2]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
;=@pos
	ld h, a
	inc de
;> if pos == 0xFFFF:
;>     return
	and l
	cp $ff
	ret z

;> pos -= 1
	dec hl
;>@w WriteVRAM(PosToScreenMap_50(pos), (page & 0x7F) + 0xF1)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@w
	call PosToScreenMap_50
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
;=@w
	call WriteVRAM
;>@buf mem[TilemapBufferAddr_50(pos)] = (page & 0x7F) + 0xF1
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
;=@buf
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@buf
	ld [hl], a
	ret


;@ def DrawListCursor_50(cursor: hl, table: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws a paged list's markers into wTilemapBuffer. `cursor` points at the cursor row
;@ (bit 7 = chosen), followed by the page number; `table` is the list's cursor table: the
;@ position of the page marker, then the position of each row. When the list has more
;@ entries than a page has rows the marker shows an arrow ($E7) with the page number
;@ ($F1 = "1") left of it, else a plain frame tile ($EE). Then the row cursor is drawn.
;@ test: skip draws a list from tables
DrawListCursor_50::
;> sel = mem[cursor]
	ld a, [hli]
	push af
	push hl
;>@p p = TilemapBufferAddr_50(mem16[table])
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
;=@p
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
;=@p
	ld h, a
;> tile = 0xE7 if rows < count else 0xEE    # more than one page: an arrow
	ld a, b
	cp c
	ld a, $ee
	jr nc, .onePage

	ld a, $e7

.onePage
;> mem[p] = tile
	ld [hld], a
	pop bc
;> if rows < count:
	jr nc, .marked

;>     mem[p - 1] = mem[cursor + 1] + 0xF1     # page number
	ld a, [bc]
	add $f1
	ld [hl], a
.marked
;> DrawCursorAt_50(sel, table + 2)
	pop af

;@ def DrawCursorAt_50(sel: a, table: de)
;@ path: menu/cursor
;@ Draws the cursor of entry sel & $7F of a menu cursor table (a list of screen positions)
;@ into wTilemapBuffer: a filled arrow $E9 once chosen (bit 7), else the arrow $E8 or, in
;@ the blinking-off phase, a blank $E0.
;@ test: skip draws from a table
DrawCursorAt_50::
;>@pos pos = mem16[table + 2 * (sel & 0x7F)]
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;=@pos
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;>@ps wLayoutRow = pos; PosToScreenMap_50(pos)      # result not used
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
	push de
	push bc
;=@ps
	call PosToScreenMap_50
	pop bc
	pop de
;> if sel & 0x80:
	ld a, $e9
	bit 7, c
	jr nz, .draw

;>     tile = 0xE9
;> elif wCursorBlinkTimer & 0x10:
	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, .draw

;>     tile = 0xE0
;> else:
;>     tile = 0xE8
	ld a, $e8

.draw
;>@d mem[TilemapBufferAddr_50(pos)] = tile
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [wLayoutRow + 1]
	ld h, a
	ld a, l
;=@d
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@d
	ld [hl], a
	ret


DrawEnemyPictures::
	ld a, [wLinkActive]
	or a
	jr z, jr_050_795e

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_795e

	ld a, [wPartyBattlers]
	jr jr_050_7961

jr_050_795e:
	ld a, [wEnemyCount]

jr_050_7961:
	cp $03
	jr z, jr_050_7981

	cp $02
	jr z, jr_050_7972

	ld a, $00
	ld hl, $00c7
	call DrawPictureBlock
	ret


jr_050_7972:
	ld a, $00
	ld hl, $00c4
	call DrawPictureBlock
	ld hl, $00ca
	call DrawPictureBlock
	ret


jr_050_7981:
	ld a, $00
	ld hl, $00c1
	call DrawPictureBlock
	ld hl, $00c7
	call DrawPictureBlock
	ld hl, $00cd
	call DrawPictureBlock
	ret


DrawPictureBlock::
	ld c, $06

jr_050_7998:
	push hl
	push af
	call TilemapBufferAddr_50
	pop af
	ld b, $06

jr_050_79a0:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_050_79a0

	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, jr_050_7998

	ret


DrawMessageWindowAndPanel::
	ld de, $2e07
	call DrawWindowLayout_50

DrawBattlePanel::
	ld a, [wPanelMode]
	or a
	jp nz, DrawPanelConditions

DrawPanelNumbers::
	ld a, [wLinkActive]
	or a
	jr nz, jr_050_79c6

	ld a, [wPartyCount]
	or a
	ret z

jr_050_79c6:
	call DrawPanelFrame
	jr PrintPanelHPMP

DrawPanelFrame::
	ld hl, $7a7f
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_79da

	ld a, [wEnemyCount]
	jr jr_050_79dd

jr_050_79da:
	ld a, [wPartyBattlers]

jr_050_79dd:
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	call DrawWindowLayout_50
	ret


PrintPanelHPMP::
	ld hl, wBattlerHP
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_79f8

	ld hl, $dbab

jr_050_79f8:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0062
	call TilemapBufferAddr_50
	call PrintNumber3
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0082
	call TilemapBufferAddr_50
	call PrintNumber3
	ld a, [wPanelCount]
	cp $01
	ret z

	ld hl, $dba5
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_7a29

	ld hl, $dbad

jr_050_7a29:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0068
	call TilemapBufferAddr_50
	call PrintNumber3
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0088
	call TilemapBufferAddr_50
	call PrintNumber3
	ld a, [wPanelCount]
	cp $02
	ret z

	ld hl, $dba7
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_7a5a

	ld hl, $dbaf

jr_050_7a5a:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $006e
	call TilemapBufferAddr_50
	call PrintNumber3
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $008e
	call TilemapBufferAddr_50
	call PrintNumber3
	ret


UnusedHPPrintParts::
	db $eb, $79, $16, $7a, $47, $7a

StatusWindowLayouts::
	db $9a, $6e, $9a, $6e, $3e, $6e, $be, $6d

DrawPanelConditions::
	cp $03
	jp z, DrawPanelLetters

	call DrawPanelFrame
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_7aa9

	ld c, $04

jr_050_7aa9:
	ld hl, $7bee
	call PanelSlotAddr
	push hl
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_050_7aba

	ld a, $d9
	jr jr_050_7abc

jr_050_7aba:
	ld a, $e0

jr_050_7abc:
	pop hl
	ld [hl], a
	ld hl, $7bf4
	call PanelSlotAddr
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
	jr nz, jr_050_7aa9

	ld a, [wPanelMode]
	cp $02
	jr z, jr_050_7b0a

	call CopyTilemapBufferToScreen_50
	ld hl, $8da0
	ld a, $02
	call LoadStatusIcon
	ld hl, $8db0
	ld a, $04
	call LoadStatusIcon
	ld hl, $8dc0
	ld a, $06
	call LoadStatusIcon
	ld hl, $8dd0
	ld a, $03
	call LoadStatusIcon
	ld hl, wPanelMode
	inc [hl]

jr_050_7b0a:
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_7b19

	ld c, $04

jr_050_7b19:
	ld hl, $7bf4
	call PanelSlotAddr
	inc hl
	inc hl
	push bc
	ld a, c
	ld bc, wBattlerLevel
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	ld c, a
	ld b, $00
	call PrintNumber2
	pop bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_050_7b87

	ld hl, $7bfa
	call PanelSlotAddr
	push hl
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	pop de
	ld a, [hl]
	or a
	jr z, jr_050_7b87

	bit 6, [hl]
	jr z, jr_050_7b56

	ld a, $00
	call PutAilmentTile

jr_050_7b56:
	inc de
	bit 5, [hl]
	jr z, jr_050_7b60

	ld a, $01
	call PutAilmentTile

jr_050_7b60:
	inc de
	bit 4, [hl]
	jr z, jr_050_7b6a

	ld a, $02
	call PutAilmentTile

jr_050_7b6a:
	inc de
	bit 7, [hl]
	jr z, jr_050_7b74

	ld a, $03
	call PutAilmentTile

jr_050_7b74:
	inc de
	bit 1, [hl]
	jr z, jr_050_7b7e

	ld a, $04
	call PutAilmentTile

jr_050_7b7e:
	bit 0, [hl]
	jr z, jr_050_7b87

	ld a, $05
	call PutAilmentTile

jr_050_7b87:
	inc c
	dec b
	jr nz, jr_050_7b19

	call CopyTilemapBufferToScreen_50
	ret


DrawPanelLetters::
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_7b9e

	ld c, $04

jr_050_7b9e:
	ld hl, $7bee
	call PanelSlotAddr
	ld a, c
	and $03
	add $da
	ld [hl], a
	ld hl, $7bf4
	call PanelSlotAddr
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
	ld [wSkillUser], a
	ld [wSkillTarget], a
	push af
	push bc
	push de
	push hl
	ld hl, wStatusIconShown
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	call UpdateStatusIcon_50
	pop hl
	pop de
	pop bc
	pop af
	inc c
	dec b
	jr nz, jr_050_7b9e

	xor a
	ld [wPanelMode], a
	call DrawPanelNumbers
	call CopyTilemapBufferToScreen_50
	ret


StatusNamePositions::
	db $25, $00, $2b, $00, $31, $00

StatusHPPositions::
	db $61, $00, $67, $00, $6d, $00

StatusIconPositions::
	db $81, $00, $87, $00
	db $8d, $00

StatusIconTiles::
	db $dc, $d7, $db, $dd, $da, $d8

PanelSlotAddr::
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


PutAilmentTile::
	push hl
	ld hl, $7c00
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [de], a
	pop hl
	ret


LoadStatusIcon::
	push hl
	ld hl, $7c3d
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
	call DecompressVRAM
	ret


StatusFaceGfx::
	db $02, $5b, $03, $5b, $04, $5b, $05, $5b, $06, $5b, $07, $5b, $08, $5b, $09, $5b

UpdateStatusIcon_50::
	ld a, [wLinkActive]
	or a
	jr z, jr_050_7c73

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_050_7c73

	ld a, [wSkillTarget]
	ld c, a
	cp $04
	jr c, jr_050_7c67

	cp $07
	ret z

	jr jr_050_7c84

jr_050_7c67:
	ld a, [wSkillUser]
	ld c, a
	cp $04
	ret c

	cp $07
	ret z

	jr jr_050_7c84

jr_050_7c73:
	ld a, [wSkillTarget]
	ld c, a
	cp $03
	jr c, jr_050_7c86

	ld a, [wSkillUser]
	ld c, a
	cp $03
	jr c, jr_050_7c86

	ret


jr_050_7c84:
	xor $04

jr_050_7c86:
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
	call CheckBattlerPresent
	jr c, jr_050_7cbc

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr nz, jr_050_7cc0

	bit 5, [hl]
	jr nz, jr_050_7cc4

	bit 4, [hl]
	jr nz, jr_050_7cc8

	bit 7, [hl]
	jr nz, jr_050_7ccc

	bit 1, [hl]
	jr nz, jr_050_7cd0

	bit 0, [hl]
	jr nz, jr_050_7cd4

	ld a, $00
	jr jr_050_7cd6

jr_050_7cbc:
	ld a, $07
	jr jr_050_7cd6

jr_050_7cc0:
	ld a, $06
	jr jr_050_7cd6

jr_050_7cc4:
	ld a, $05
	jr jr_050_7cd6

jr_050_7cc8:
	ld a, $04
	jr jr_050_7cd6

jr_050_7ccc:
	ld a, $03
	jr jr_050_7cd6

jr_050_7cd0:
	ld a, $02
	jr jr_050_7cd6

jr_050_7cd4:
	ld a, $01

jr_050_7cd6:
	push af
	ld a, c
	ld hl, wStatusIconShown
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld d, [hl]
	pop af
	cp d
	call nz, StoreStatusIcon_50
	pop hl
	call nz, LoadStatusIcon
	pop de
	ret


StoreStatusIcon_50::
	ld [hl], a
	ret


UnusedClearAttrMap::
	db $fa, $1d, $c8, $b7, $c8, $3e, $01, $e0, $4f, $fa, $f8, $d9, $6f, $fa, $f9, $d9
	db $67, $0e, $12, $06, $20, $e5, $3e, $00, $cd, $ad, $1a, $7d, $e6, $e0, $f5, $7d
	db $3c, $e6, $1f, $6f, $f1, $b5, $6f, $05, $20, $ec, $e1, $c5, $01, $20, $00, $09
	db $7c, $e6, $03, $f6, $98, $67, $c1, $0d, $20, $d9, $3e, $00, $e0, $4f, $c9

GetBattlerName_50::
	cp $03
	jr nc, GetEnemyName_50

GetPartyMonName_50::
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call CopyName
	pop hl

jr_050_7d41:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_050_7d41

GetLinkEnemyName_50::
	ld a, b
	pop bc
	jr GetPartyMonName_50

GetEnemyName_50::
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_050_7d75

	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, GetLinkEnemyName_50

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
	jr nz, jr_050_7d72

	ld a, b

jr_050_7d72:
	pop bc
	jr nz, GetLikeName_50

jr_050_7d75:
	push af
	call GetSpeciesName_50
	pop af
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


GetSpeciesName_50::
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


GetLikeName_50::
	call GetPartyMonName_50
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
	jr z, jr_050_7dc9

	cp $02
	jr z, jr_050_7dd3

	ld a, [hli]
	cp [hl]
	jr z, jr_050_7def

	inc hl
	cp [hl]
	jr z, jr_050_7def

	jr jr_050_7dfe

jr_050_7dc9:
	ld a, [hli]
	cp [hl]
	jr z, jr_050_7df4

	ld a, [hli]
	cp [hl]
	jr z, jr_050_7def

	jr jr_050_7dfe

jr_050_7dd3:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_050_7ddd

	inc d

jr_050_7ddd:
	inc hl
	cp [hl]
	jr nz, jr_050_7de2

	inc d

jr_050_7de2:
	ld a, d
	or a
	jr z, jr_050_7dfe

	cp $01
	jr z, jr_050_7df4

	pop hl
	ld a, $03
	jr jr_050_7df7

jr_050_7def:
	pop hl
	ld a, $01
	jr jr_050_7df7

jr_050_7df4:
	pop hl
	ld a, $02

jr_050_7df7:
	ld [wBattleArg1], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_050_7dfe:
	pop hl
	xor a
	ld [wBattleArg1], a
	ret


UnusedTargetName::
	db $21, $a0, $c1, $18, $03, $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db
	db $fa, $89, $db, $ea, $50, $db, $cd, $2e, $7d, $c9

GetSkillUserName::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerName_50
	ret


Bank50Padding::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
