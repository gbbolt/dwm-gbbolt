INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $059", ROMX[$4000], BANK[$59]

BankNumber_59::
	db $59

FarTable_59::
	dw SpriteViewerInit
	dw SpriteViewerUpdate
	dw BattleTutorInit
	dw BattleTutorUpdate
	dw CommandTutorInit
	dw CommandTutorUpdate
	dw StartText_59
	dw CopyText_59
	dw PrintText_59

SpriteViewerInit::
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, hSpriteX
	ld bc, $0012
	call FillMemory
	xor a
	ld hl, wBattleAnimRunning
	ld bc, $0006
	call FillMemory
	xor a
	ld hl, wTilemapBuffer
	ld bc, $0240
	call FillMemory
	call DisableSTATInterrupts
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	xor a
	ld [wSkillAnimSprites], a
	xor a
	ld [wMenuOverlay], a
	ld hl, $9700
	ld de, $0901
	call SetUpTextBox
	call SpriteViewerLoadSpecies
	ld hl, $8800
	ld de, $0601
	call SetUpTextBox
	xor a
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	call StartText_59
	ld hl, $9700
	ld de, $0901
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld de, $2e00
	ld hl, $8d00
	call Decompress
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
	ld hl, wTilemapBuffer
	ld de, SpriteViewerTitleLayout
	call DrawLayout_59
	ld hl, wTilemapBuffer
	ld de, SpriteViewerBoxesLayout
	call DrawLayout_59
	call SpriteViewerDrawNumbers
	call SpriteViewerDrawMenu
	ld a, $fc
	call StartFade
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
	call ApplyScroll
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
	xor a
	ld [wLCDEffect], a
	ld a, $03
	ld [wLCDC], a
	call EnableLYCInterrupt
	ld a, $01
	jp EnableLCDAndInterrupts

SpriteViewerUpdate::
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wJoyHeldLast]
	xor $ff
	ld b, a
	ld a, [wJoyHeld]
	ld [wSGBJoypads], a
	or a
	jr z, jr_059_4104
	and b

jr_059_4104:
	ld [wSGBJoypads + 1], a
	ld a, [wSceneObjects]
	rst $00
	dw SpriteViewerMenu
	dw SpriteViewerLoad
	dw SpriteViewerLoaded
	dw SpriteViewerTurn
	dw SpriteViewerPick
	dw SpriteViewerExit

SpriteViewerMenu::
	call SpriteViewerDrawSprite
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_413c
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, jr_059_4152
	ld a, [wSGBJoypads + 1]
	and $c0
	jr nz, jr_059_4130
	ret


jr_059_4130:
	ld a, [wMenuChoice]
	xor $01
	ld [wMenuChoice], a
	call SpriteViewerDrawMenu
	ret


jr_059_413c:
	ld a, [wMenuChoice]
	set 7, a
	ld [wMenuChoice], a
	call SpriteViewerDrawMenu
	ld a, [wMenuChoice]
	and $01
	add $03
	ld [wSceneObjects], a
	ret


jr_059_4152:
	ld a, $04
	call StartFade
	ld a, $05
	ld [wSceneObjects], a
	ret

SpriteViewerLoad::
	ld hl, wSceneObjects
	inc [hl]
	call SpriteViewerLoadSpecies
	ret

SpriteViewerLoaded::
	ld a, $04
	ld [wSceneObjects], a
	call SpriteViewerDrawNumbers
	ret

SpriteViewerTurn::
	call SpriteViewerDrawSprite
	ld a, [wJoyHeld]
	and $40
	jr nz, jr_059_419c
	ld a, [wJoyHeld]
	and $80
	jr nz, jr_059_41a7
	ld a, [wJoyHeld]
	and $20
	jr nz, jr_059_41b2
	ld a, [wJoyHeld]
	and $10
	jr nz, jr_059_41bd
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_41c8
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, jr_059_41fa
	ret


jr_059_419c:
	ld a, $02
	ld [wBattleAnimIndex], a
	ld a, $00
	ldh [hSpriteAttr], a
	jr jr_059_41db


jr_059_41a7:
	ld a, $00
	ld [wBattleAnimIndex], a
	ld a, $00
	ldh [hSpriteAttr], a
	jr jr_059_41db


jr_059_41b2:
	ld a, $01
	ld [wBattleAnimIndex], a
	ld a, $20
	ldh [hSpriteAttr], a
	jr jr_059_41db


jr_059_41bd:
	ld a, $01
	ld [wBattleAnimIndex], a
	ld a, $00
	ldh [hSpriteAttr], a
	jr jr_059_41db


jr_059_41c8:
	ld a, [wSceneObjects + 9]
	ld b, a
	ld a, [wBattleAnimIndex]
	sub b
	ld [wBattleAnimIndex], a
	ld a, [wSceneObjects + 9]
	xor $03
	ld [wSceneObjects + 9], a

jr_059_41db:
	ld a, [wSceneObjects + 9]
	ld b, a
	ld a, [wBattleAnimIndex]
	add b
	ld [wBattleAnimIndex], a
	xor a
	ld [$dd65], a
	ld hl, wBattleAnimSet
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [wPlayerAnimPtr + 1], a
	ld hl, far_GetAnimationFirstPose
	rst $10
	ret


jr_059_41fa:
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
	call SpriteViewerDrawMenu
	xor a
	ld [wSceneObjects], a
	ret

SpriteViewerPick::
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_424a
	call SpriteViewerDrawSprite
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, jr_059_4250
	ld a, [wJoyHeld]
	and $20
	jr nz, jr_059_422a
	ld a, [wJoyHeld]
	and $10
	jr nz, jr_059_423a
	ret


jr_059_422a:
	ld a, [wConfirmChoice]
	or a
	jr nz, jr_059_4232
	ld a, $d7

jr_059_4232:
	dec a
	ld [wConfirmChoice], a
	call SpriteViewerDrawNumbers
	ret


jr_059_423a:
	ld a, [wConfirmChoice]
	inc a
	cp $d7
	jr c, jr_059_4243
	xor a

jr_059_4243:
	ld [wConfirmChoice], a
	call SpriteViewerDrawNumbers
	ret


jr_059_424a:
	ld a, $01
	ld [wSceneObjects], a
	ret


jr_059_4250:
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
	call SpriteViewerDrawMenu
	xor a
	ld [wSceneObjects], a
	ret
SpriteViewerExit::
	ld a, $00
	ld [wGameMode], a
	xor a
	ld [wGameModeStep], a
	xor a
	ld [wOpeningScene], a
	xor a
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ret

SpriteViewerDrawSprite::
	ld hl, hSpriteX
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, [wSceneObjects + 8]
	add $10
	ld [hli], a
	inc hl
	ld a, $00
	ld [hl], a
	ld hl, wBattleAnimSet
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [wPlayerAnimPtr + 1], a
	ld hl, far_GetAnimationFirstPose
	rst $10
	ldh a, [hSpriteFrame]
	cp $ff
	ret z
	ld hl, far_DrawActorSprite
	rst $10
	ld hl, wBattleAnimRunning
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [wPlayerAnimPtr + 1], a
	ld hl, far_StepAnimation
	rst $10
	ld a, [wBattleAnimRunning]
	or a
	ret nz
	xor a
	ld [$dd65], a
	ret
SpriteViewerLoadSpecies::
	ld a, [wConfirmChoice]
	ld l, a
	ld [wSceneObjects + 8], a
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterSpriteGfx_59)
	ld l, a
	ld a, h
	adc HIGH(MonsterSpriteGfx_59)
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, $80
	ld l, $00
	call DecompressVRAM
	ld a, [wConfirmChoice]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld hl, far_PrintText_41
	rst $10
	ret

SpriteViewerDrawNumbers::
	ld a, [wSceneObjects + 8]
	ld l, a
	ld h, $00
	call SplitDecimal_59
	ld hl, wTilemapBuffer + 33
	ld a, [wSceneObjects + 16]
	add $f0
	ld [hli], a
	ld a, [wSceneObjects + 17]
	add $f0
	ld [hli], a
	ld a, [wSceneObjects + 18]
	add $f0
	ld [hli], a
	ld a, [wConfirmChoice]
	ld l, a
	ld h, $00
	call SplitDecimal_59
	ld hl, wTilemapBuffer + 520
	ld a, [wSceneObjects + 16]
	add $f0
	ld [hli], a
	ld a, [wSceneObjects + 17]
	add $f0
	ld [hli], a
	ld a, [wSceneObjects + 18]
	add $f0
	ld [hl], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret

SpriteViewerDrawMenu::
	ld hl, wTilemapBuffer
	ld de, SpriteViewerMenuLayout
	call DrawLayout_59
	ld a, [wMenuChoice]
	ld hl, SpriteViewerCursorSpots
	and $01
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
	ld a, [wMenuChoice]
	bit 7, a
	jr nz, jr_059_435b
	ld a, $e8
	jr jr_059_435d


jr_059_435b:
	ld a, $e9

jr_059_435d:
	ld [hl], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret

MonsterSpriteGfx_59::
	dw $2f01, $2f02, $2f03, $2f04, $2f05, $2f06, $2f07, $2f08
	dw $2f09, $2f0a, $2f0b, $2f0c, $2f0d, $2f0e, $2f0f, $2f10
	dw $3800, $3801, $3802, $3803, $3804, $3805, $3806, $3807
	dw $3808, $3809, $380a, $380b, $380c, $380d, $380e, $380f
	dw $3810, $3811, $3812, $3813, $3814, $3815, $3816, $3817
	dw $3818, $3819, $381a, $381b, $381c, $381d, $381e, $381f
	dw $3820, $3821, $3822, $3823, $3824, $3825, $3826, $3827
	dw $3828, $3829, $382a, $382b, $382c, $382d, $382e, $382f
	dw $3830, $3831, $3832, $3833, $3834, $3835, $3836, $3837
	dw $3838, $3839, $383a, $383b, $383c, $383d, $383e, $383f
	dw $3840, $3841, $3842, $3843, $3844, $3845, $3846, $3847
	dw $3900, $3901, $3902, $3903, $3904, $3905, $3906, $3907
	dw $3908, $3909, $390a, $390b, $390c, $390d, $390e, $390f
	dw $3910, $3911, $3912, $3913, $3914, $3915, $3916, $3917
	dw $3918, $3919, $391a, $391b, $391c, $391d, $391e, $391f
	dw $3920, $3921, $3922, $3923, $3924, $3925, $3926, $3927
	dw $3928, $3929, $392a, $392b, $392c, $392d, $392e, $392f
	dw $3930, $3931, $3932, $3933, $3934, $3935, $3936, $3937
	dw $3938, $3939, $393a, $393b, $393c, $393d, $393e, $393f
	dw $3940, $3941, $3942, $3943, $3944, $3945, $3946, $3947
	dw $3a00, $3a01, $3a02, $3a03, $3a04, $3a05, $3a06, $3a07
	dw $3a08, $3a09, $3a0a, $3a0b, $3a0c, $3a0d, $3a0e, $3a0f
	dw $3a10, $3a11, $3a12, $3a13, $3a14, $3a15, $3a16, $3a17
	dw $3a18, $3a19, $3a1a, $3a1b, $3a1c, $3a1d, $3a1e, $3a1f
	dw $3a20, $3a21, $3a22, $3a23, $3a24, $3a25, $3a26, $3a27
	dw $3a28, $3a29, $3a2a, $3a2b, $3a2c, $3a2d, $3a2e, $3a2f
	dw $3a30, $3a31, $3a32, $3a33, $3a34, $3a35, $3a36

SpriteViewerTitleLayout::
	dw $0000
	db $fa, $ef, $ef, $ef, $fb, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e0, $ff, $fe, $70, $71, $72, $73, $74, $75, $76, $77, $78, $ff, $d8
	db $fc, $ee, $ee, $ee, $fd, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

SpriteViewerBoxesLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $81, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $fa, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $85, $ff, $fe, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $fc, $ee, $ee, $ee, $fd, $d9

SpriteViewerMenuLayout::
	dw $01a1
	db $ef, $d8
	db $e0, $d8
	db $e0, $d8
	db $e0, $d8
	db $ee, $d9

SpriteViewerCursorSpots::
	dw $01c1
	dw $0201

BattleTutorInit::
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [wTextBoxMap + 1], a
	call DisableSTATInterrupts
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	xor a
	ld [wSkillAnimSprites], a
	xor a
	ld [wMenuOverlay], a
	call LoadTutorEnemyPic
	ld de, $2e00
	ld hl, $8d00
	call Decompress
	ld hl, $9700
	ld de, $0401
	call SetUpTextBox
	ld a, $00
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	call PrintText_59
	ld hl, $96c0
	ld de, $0401
	call SetUpTextBox
	ld a, $00
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $97c0
	ld de, $0401
	call SetUpTextBox
	ld a, $01
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $8800
	ld de, $0401
	call SetUpTextBox
	ld a, $05
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
	call DrawTutorBattleScreen
	ld de, TutorMessageBoxLayout2
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld a, $fc
	call StartFade
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
	ld a, $d8
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
	call ApplyScroll
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
	xor a
	ld [wLCDEffect], a
	ld a, $03
	ld [wLCDC], a
	call EnableLYCInterrupt
	ld a, $01
	jp EnableLCDAndInterrupts
BattleTutorUpdate::
	ld a, [wSceneObjects + 1]
	rst $00
	dw TutorWaitFade
	dw TutorStartIntro
	dw TutorBlink15
	dw TutorShowCommands
	dw TutorBlink40
	dw TutorScrollIn
	dw TutorExplain0
	dw TutorWaitText
	dw TutorExplain1
	dw TutorWaitText
	dw TutorScrollOut
	dw TutorBlink40
	dw TutorScrollIn
	dw TutorExplain2
	dw TutorWaitText
	dw TutorScrollOut
	dw TutorBlink40
	dw TutorPointPlan
	dw TutorBlink40
	dw TutorScrollIn
	dw TutorExplain3
	dw TutorWaitText
	dw TutorScrollOut
	dw TutorBlink40
	dw TutorPointFight
	dw TutorBlink15
	dw TutorPointItem
	dw TutorBlink40
	dw TutorScrollIn
	dw TutorExplain4
	dw TutorWaitText
	dw TutorScrollOut
	dw TutorBlink40
	dw TutorPointRun
	dw TutorBlink40
	dw TutorScrollIn
	dw TutorExplain5
	dw TutorWaitText
	dw TutorExplain6
	dw TutorWaitText
	dw TutorScrollOut
	dw TutorBlink40
	dw TutorStartFadeOut
	dw TutorBackToTitle

TutorScrollIn::
	call TutorScrollInStep
	ret nz
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorScrollOut::
	call TutorScrollOutStep
	ret nz
	ld a, $01
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	call PrintText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorWaitText::
	ld a, [wTextState]
	or a
	ret nz
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorWaitFade::
	ld a, [wFadeState]
	or a
	ret nz
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorBlink15::
	call TutorBlinkCursor
	ld hl, wSceneObjects + 2
	inc [hl]
	ld a, [wSceneObjects + 2]
	cp $0f
	ret nz
	ld hl, wSceneObjects + 1
	inc [hl]
	xor a
	ld [wSceneObjects + 2], a
	ret

TutorBlink40::
	call TutorBlinkCursor
	ld hl, wSceneObjects + 2
	inc [hl]
	ld a, [wSceneObjects + 2]
	cp $28
	ret nz
	ld hl, wSceneObjects + 1
	inc [hl]
	xor a
	ld [wSceneObjects + 2], a
	ret

TutorStartIntro::
	ld a, $02
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorShowCommands::
	ld a, [wTextState]
	or a
	ret nz
	ld a, $01
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	call PrintText_59
	call DrawTutorBattleScreen
	ld de, TutorCommandBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld hl, wTilemapBuffer + 289
	ld [hl], $e8
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	xor a
	ld [wSceneObjects + 3], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain0::
	ld a, $00
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain1::
	ld a, $01
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain2::
	ld a, $02
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain3::
	ld a, $03
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain4::
	ld a, $04
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain5::
	ld a, $05
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorExplain6::
	ld a, $06
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorStartFadeOut::
	ld a, $04
	call StartFade
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

TutorBackToTitle::
	ld a, [wFadeState]
	or a
	ret nz
	ld a, $00
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ret

CommandTutorInit::
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wListCursor
	ld bc, $0008
	call FillMemory
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [wTextBoxMap + 1], a
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
	call DisableSTATInterrupts
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	xor a
	ld [wSkillAnimSprites], a
	xor a
	ld [wMenuOverlay], a
	call LoadTutorEnemyPic
	call CmdTutorPrintNames
	ld de, $2e00
	ld hl, $8d00
	call Decompress
	call CmdTutorDrawMenu
	call CmdTutorPrintLabels
	ld a, $fc
	call StartFade
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
	ld a, $00
	ldh [hScrollX], a
	ld a, $00
	ldh [hScrollY], a
	call ApplyScroll
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
	xor a
	ld [wLCDEffect], a
	ld a, $03
	ld [wLCDC], a
	call EnableLYCInterrupt
	ld a, $01
	jp EnableLCDAndInterrupts
CommandTutorUpdate::
	ld a, [wFadeState]
	or a
	ret nz
	ld a, [wJoyHeldLast]
	xor $ff
	ld b, a
	ld a, [wJoyHeld]
	ld [wSGBJoypads], a
	or a
	jr z, jr_059_48e5
	and b

jr_059_48e5:
	ld [wSGBJoypads + 1], a
	ld a, [wSceneObjects]
	rst $00
	dw CmdTutorMainMenu
	dw CmdTutorExplainMain
	dw CmdTutorStrategyMenu
	dw CmdTutorExplainStrategy
	dw CmdTutorQuit
	dw CmdTutorTargetMenu
	dw CmdTutorOrderMenu
	dw CmdTutorExplainTarget
	dw CmdTutorExplainOrder

CmdTutorMainMenu::
	ld a, [wLinkRefused]
	or a
	jr z, jr_059_4912
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wLinkRefused]
	cp $08
	ret c
	xor a
	ld [wLinkRefused], a

jr_059_4912:
	call CmdTutorBlinkCursor
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_4933
	ld a, [wSGBJoypads]
	and $c0
	jr nz, jr_059_495a
	ld a, [wSGBJoypads]
	and $30
	jr nz, jr_059_497b
	ld a, [wSGBJoypads + 1]
	and $02
	jp nz, jr_059_499c
	ret


jr_059_4933:
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wMenuChoice]
	set 7, a
	ld [wMenuChoice], a
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $01
	ld [wSceneObjects], a
	ret


jr_059_495a:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wMenuChoice]
	xor $01
	ld [wMenuChoice], a
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_497b:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wMenuChoice]
	xor $02
	ld [wMenuChoice], a
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_499c:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	xor a
	ld [wSceneObjects + 1], a
	ld a, $04
	ld [wSceneObjects], a
	ret

CmdTutorExplainMain::
	ld a, [wSceneObjects + 1]
	rst $00
	dw CmdTutorClearMenu
	dw CmdTutorStartMainText
	dw CmdTutorAfterMainText

CmdTutorClearMenu::
	xor a
	ld [wBattleListCount], a
	ld a, $01
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

CmdTutorStartMainText::
	ld a, [wMenuChoice]
	and $03
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

CmdTutorAfterMainText::
	ld a, [wTextState]
	or a
	ret nz
	ld a, [wMenuChoice]
	res 7, a
	cp $01
	jr z, jr_059_4a1e
	cp $03
	jr z, jr_059_4a59
	ld [wMenuChoice], a
	xor a
	ld [wSceneObjects], a
	ld [wSceneObjects + 1], a
	xor a
	ld [wBattleListCount], a
	xor a
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4a1e:
	ld a, [wPartyCount]
	cp $02
	jr nc, jr_059_4a3f
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	xor a
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4a3f:
	ld a, $05
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	xor a
	ld [wBattleListCount], a
	ld a, $04
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4a59:
	ld [wMenuChoice], a
	xor a
	ld [wListLastRows], a
	ld a, $04
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret

CmdTutorStrategyMenu::
	ld a, [wLinkRefused]
	or a
	jr z, jr_059_4a7e
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wLinkRefused]
	cp $08
	ret c
	xor a
	ld [wLinkRefused], a

jr_059_4a7e:
	call CmdTutorBlinkCursor
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_4aa0
	ld a, [wSGBJoypads]
	and $40
	jr nz, jr_059_4ac7
	ld a, [wSGBJoypads]
	and $80
	jp nz, jr_059_4aee
	ld a, [wSGBJoypads + 1]
	and $02
	jp nz, jr_059_4b15
	ret


jr_059_4aa0:
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wMenuChoice2]
	set 7, a
	ld [wMenuChoice2], a
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $03
	ld [wSceneObjects], a
	ret


jr_059_4ac7:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wMenuChoice2]
	or a
	jr z, jr_059_4adc
	dec a
	jr jr_059_4ade


jr_059_4adc:
	ld a, $03

jr_059_4ade:
	ld [wMenuChoice2], a
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4aee:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wMenuChoice2]
	cp $03
	jr z, jr_059_4b04
	inc a
	jr jr_059_4b05


jr_059_4b04:
	xor a

jr_059_4b05:
	ld [wMenuChoice2], a
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4b15:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wPartyCount]
	cp $02
	jr c, jr_059_4b4a
	ld a, [wListPage]
	res 7, a
	ld [wListPage], a
	xor a
	ld [wBattleListCount], a
	ld a, $04
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $05
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret


jr_059_4b4a:
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
	xor a
	ld [wSceneObjects], a
	ld [wSceneObjects + 1], a
	ld [wMenuChoice2], a
	ld [wBattleListCount], a
	ld [wCommandSubStep], a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret

CmdTutorExplainStrategy::
	ld a, [wSceneObjects + 1]
	rst $00
	dw CmdTutorClearMenu
	dw CmdTutorStartStrategyText
	dw CmdTutorAfterStrategyText

CmdTutorStartStrategyText::
	ld a, [wMenuChoice2]
	and $03
	add $04
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

CmdTutorAfterStrategyText::
	ld a, [wTextState]
	or a
	ret nz
	ld a, [wMenuChoice2]
	and $03
	cp $03
	jr z, jr_059_4bb6
	res 7, a
	ld [wMenuChoice2], a
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4bb6:
	ld a, $06
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ld [wBattleListCount], a
	ld a, $05
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret

CmdTutorQuit::
	ld a, [wSceneObjects + 1]
	rst $00
	dw CmdTutorAskQuit
	dw CmdTutorQuitMenu
	dw CmdTutorQuitAnswer
	dw CmdTutorBackToTitle

CmdTutorAskQuit::
	xor a
	ld [wListCursor], a
	xor a
	ld [wBattleListCount], a
	ld a, $03
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $08
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

CmdTutorQuitMenu::
	ld a, [wLinkRefused]
	or a
	jr z, jr_059_4c15
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wLinkRefused]
	cp $08
	ret c
	xor a
	ld [wLinkRefused], a

jr_059_4c15:
	call CmdTutorBlinkCursor
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_4c2e
	ld a, [wSGBJoypads]
	and $c0
	jr nz, jr_059_4c59
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, jr_059_4c7f
	ret


jr_059_4c2e:
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListCursor]
	set 7, a
	ld [wListCursor], a
	ld a, $01
	ld [wBattleListCount], a
	ld a, $03
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld hl, wSceneObjects + 1
	inc [hl]
	ret


jr_059_4c59:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListCursor]
	xor $01
	ld [wListCursor], a
	ld a, $01
	ld [wBattleListCount], a
	ld a, $03
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4c7f:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	xor a
	ld [wBattleListCount], a
	xor a
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	xor a
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret

CmdTutorQuitAnswer::
	ld a, [wListCursor]
	and $01
	jr nz, jr_059_4c7f
	ld a, $04
	call StartFade
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

CmdTutorBackToTitle::
	ld a, [wFadeState]
	or a
	ret nz
	ld a, $00
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ret

CmdTutorTargetMenu::
	ld a, [wLinkRefused]
	or a
	jr z, jr_059_4ce6
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wLinkRefused]
	cp $08
	ret c
	xor a
	ld [wLinkRefused], a

jr_059_4ce6:
	call CmdTutorBlinkCursor
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_4cff
	ld a, [wSGBJoypads]
	and $c0
	jr nz, jr_059_4d26
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, jr_059_4d47
	ret


jr_059_4cff:
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListPage]
	set 7, a
	ld [wListPage], a
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $07
	ld [wSceneObjects], a
	ret


jr_059_4d26:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListPage]
	xor $01
	ld [wListPage], a
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4d47:
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	xor a
	ld [wBattleListCount], a
	xor a
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	xor a
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret

CmdTutorOrderMenu::
	ld a, [wLinkRefused]
	or a
	jr z, jr_059_4d87
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wLinkRefused]
	cp $08
	ret c
	xor a
	ld [wLinkRefused], a

jr_059_4d87:
	call CmdTutorBlinkCursor
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, jr_059_4da7
	ld a, [wSGBJoypads]
	and $40
	jr nz, jr_059_4dce
	ld a, [wSGBJoypads]
	and $80
	jr nz, jr_059_4df5
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, jr_059_4e1a
	ret


jr_059_4da7:
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListCursor2]
	set 7, a
	ld [wListCursor2], a
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $08
	ld [wSceneObjects], a
	ret


jr_059_4dce:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListCursor2]
	or a
	jr z, jr_059_4de3
	dec a
	jr jr_059_4de5


jr_059_4de3:
	ld a, $02

jr_059_4de5:
	ld [wListCursor2], a
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4df5:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	ld a, [wListCursor2]
	inc a
	cp $03
	jr c, jr_059_4e0a
	xor a

jr_059_4e0a:
	ld [wListCursor2], a
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret


jr_059_4e1a:
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
	ld hl, wLinkRefused
	inc [hl]
	xor a
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret
CmdTutorExplainTarget::
	ld a, [wSceneObjects + 1]
	rst $00
	dw CmdTutorClearMenu
	dw CmdTutorStartTargetText
	dw CmdTutorAfterTargetText

CmdTutorStartTargetText::
	ld a, [wListPage]
	and $03
	add $09
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

CmdTutorAfterTargetText::
	ld a, [wTextState]
	or a
	ret nz
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret

CmdTutorExplainOrder::
	ld a, [wSceneObjects + 1]
	rst $00
	dw CmdTutorClearMenu
	dw CmdTutorStartOrderText
	dw CmdTutorAfterOrderText

CmdTutorStartOrderText::
	ld a, [wListCursor2]
	and $03
	add $0b
	ld [wTextIndex], a
	ld a, $02
	ld [wTextGroup], a
	call StartText_59
	ld hl, wSceneObjects + 1
	inc [hl]
	ret
CmdTutorAfterOrderText::
	ld a, [wTextState]
	or a
	ret nz
	ld a, [wListCursor2]
	res 7, a
	ld [wListCursor2], a
	ld a, $06
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ld [wBattleListCount], a
	ld a, $05
	ld [wCommandSubStep], a
	xor a
	ld [wCommandStep], a
	call CmdTutorDrawMenu
	ret

CmdTutorDrawMenu::
	ld a, [wCommandStep]
	or a
	ret nz
	ld a, [wCommandSubStep]
	rst $00
	dw CmdTutorDrawMain
	dw CmdTutorDrawMessageBox
	dw CmdTutorDrawStrategy
	dw CmdTutorDrawYesNo
	dw CmdTutorDrawTarget
	dw CmdTutorDrawOrder

CmdTutorDrawMain::
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawMainFull
	dw CmdTutorDrawMainBox
	dw CmdTutorDrawMainBox

CmdTutorDrawMainFull::
	call ClearTilemapBuffer_59
	call CmdTutorDrawScreen

CmdTutorDrawMainBox::
	ld de, TutorMainMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld a, [wMenuChoice]
	and $0f
	ld hl, TutorMainCursorSpots
	call ReadTableWord_59
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
	ld a, [wMenuChoice]
	bit 7, a
	jr z, jr_059_4f1b
	ld [hl], $e9
	jp jr_059_504d


jr_059_4f1b:
	ld [hl], $e8
	jp jr_059_504d
CmdTutorDrawMessageBox::
	call ClearTilemapBuffer_59
	call CmdTutorDrawScreen
	ld de, TutorMessageBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	jp jr_059_504d

CmdTutorDrawStrategy::
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawStrategyFull
	dw CmdTutorDrawStrategyBox
	dw CmdTutorDrawStrategyBox

CmdTutorDrawStrategyFull::
	call ClearTilemapBuffer_59
	call CmdTutorDrawScreen

CmdTutorDrawStrategyBox::
	ld de, TutorStrategyMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld a, [wMenuChoice2]
	and $0f
	ld hl, TutorListCursorSpots
	call ReadTableWord_59
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
	ld a, [wMenuChoice2]
	bit 7, a
	jr z, jr_059_4f72
	ld [hl], $e9
	jp jr_059_504d


jr_059_4f72:
	ld [hl], $e8
	jp jr_059_504d

CmdTutorDrawYesNo::
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawYesNoFull
	dw CmdTutorDrawYesNoBox

CmdTutorDrawYesNoFull::
	call ClearTilemapBuffer_59
	call CmdTutorDrawScreen
	ld de, TutorMessageBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59

CmdTutorDrawYesNoBox::
	ld de, TutorYesNoLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld a, [wListCursor]
	and $0f
	ld hl, TutorYesNoCursorSpots
	call ReadTableWord_59
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
	ld a, [wListCursor]
	bit 7, a
	jr z, jr_059_4fbd
	ld [hl], $e9
	jr jr_059_4fbf


jr_059_4fbd:
	ld [hl], $e8

jr_059_4fbf:
	ld a, [wBattleListCount]
	or a
	jp nz, jr_059_5056
	jp jr_059_504d

CmdTutorDrawTarget::
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawTargetFull
	dw CmdTutorDrawTargetBox

CmdTutorDrawTargetFull::
	call ClearTilemapBuffer_59
	call CmdTutorDrawScreen

CmdTutorDrawTargetBox::
	ld de, TutorTargetMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld a, [wListPage]
	and $0f
	add $02
	ld hl, TutorListCursorSpots
	call ReadTableWord_59
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
	ld a, [wListPage]
	bit 7, a
	jr z, jr_059_5008
	ld [hl], $e9
	jr jr_059_504d


jr_059_5008:
	ld [hl], $e8
	jr jr_059_504d

CmdTutorDrawOrder::
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawOrderFull
	dw CmdTutorDrawOrderBox

CmdTutorDrawOrderFull::
	call ClearTilemapBuffer_59
	call CmdTutorDrawScreen

CmdTutorDrawOrderBox::
	ld de, TutorOrderMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld a, [wListCursor2]
	and $0f
	add $01
	ld hl, TutorListCursorSpots
	call ReadTableWord_59
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
	ld a, [wListCursor2]
	bit 7, a
	jr z, jr_059_504b
	ld [hl], $e9
	jr jr_059_504d


jr_059_504b:
	ld [hl], $e8

jr_059_504d:
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox

jr_059_5056:
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld a, $01
	ld [wCommandStep], a
	ret
CmdTutorDrawScreen::
	ld a, [wPartyCount]
	or a
	jr z, jr_059_507d
	ld hl, TutorPartyLayouts
	ld a, [wPartyCount]
	call ReadTableWord_59
	ld d, h
	ld e, l
	ld hl, wTilemapBuffer
	call DrawLayout_59
	call CmdTutorDrawHPMP
	call CmdTutorClearSlot0

jr_059_507d:
	ld de, TutorPartyPicLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ret

CmdTutorPrintLabels::
	ld hl, $96c0
	ld de, $0401
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $00
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $97c0
	ld de, $0401
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $01
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $8850
	ld de, $1401
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $03
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $8990
	ld de, $0501
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $04
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ld hl, $8800
	ld de, $0501
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld a, $05
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
	ld hl, far_PrintText_4C
	rst $10
	ret

CmdTutorPrintNames::
	ld a, [wPartyCount]
	or a
	ret z
	xor a
	ld [wSceneObjects + 19], a
	ld hl, $9700
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a

jr_059_515b:
	ld a, [wSceneObjects + 19]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call CmdTutorPrintName
	ld hl, wSceneObjects + 19
	inc [hl]
	ld a, [wTextTiles]
	ld l, a
	ld a, [wTextTiles + 1]
	ld h, a
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld a, [wSceneObjects + 19]
	ld d, a
	ld a, [wPartyCount]
	cp d
	jr nz, jr_059_515b
	ld hl, $8b00
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld de, $1202
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret

CmdTutorDrawHPMP::
	xor a
	ld [wSceneObjects + 19], a

jr_059_51ac:
	ld a, [wSceneObjects + 19]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call CmdTutorDrawSlotHPMP
	ld hl, wSceneObjects + 19
	inc [hl]
	ld a, [wSceneObjects + 19]
	ld d, a
	ld a, [wPartyCount]
	cp d
	jr nz, jr_059_51ac
	ret

CmdTutorDrawSlotHPMP::
	ld c, $95
	ld b, $00
	call Multiply_59
	push bc
	ld hl, wMonHP
	call ReadWordAt_59
	call SplitDecimal_59
	ld a, [wSceneObjects + 19]
	ld hl, TutorHPDigitSpots
	call ReadTableWord_59
	call CmdTutorPutNumber
	pop bc
	ld hl, wMonMP
	call ReadWordAt_59
	call SplitDecimal_59
	ld a, [wSceneObjects + 19]
	ld hl, TutorMPDigitSpots
	call ReadTableWord_59
	call CmdTutorPutNumber
	ret

CmdTutorPutNumber::
	ld a, [wSceneObjects + 16]
	ld e, a
	or a
	jr z, jr_059_5209
	add $f0
	ld [hl], a

jr_059_5209:
	inc hl
	ld a, [wSceneObjects + 17]
	or e
	jr z, jr_059_5216
	ld a, [wSceneObjects + 17]
	add $f0
	ld [hl], a

jr_059_5216:
	inc hl
	ld a, [wSceneObjects + 18]
	add $f0
	ld [hl], a
	ret

CmdTutorPrintName::
	ld c, $95
	ld b, $00
	call Multiply_59
	ld hl, wMonName
	add hl, bc
	ld d, h
	ld e, l
	ld hl, wTextArg0
	call CopyName
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_PrintText_41
	rst $10
	ret
CmdTutorClearSlot0::
	xor a
	ld [wSceneObjects + 19], a
	call CmdTutorClearSlotText
	ret

CmdTutorClearSlotText::
	ld hl, wTextArg0
	ld a, $f0
	ld [hl], a
	ld a, [wSceneObjects + 19]
	ld hl, TutorSlotTextTiles
	call ReadTableWord_59
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
	ld de, $0301
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
	ret

CmdTutorBlinkCursor::
	ld a, [wListLastRows]
	or a
	ret nz
	ld hl, wLinkPartnerChoice
	inc [hl]
	ld a, [wLinkPartnerChoice]
	cp $0a
	jr z, jr_059_528e
	cp $14
	jr z, jr_059_529d
	ret


jr_059_528e:
	ld a, [wConfirmChoice2]
	ld l, a
	ld a, [wMenuChoice3]
	ld h, a
	ld [hl], $e0
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


jr_059_529d:
	ld a, [wConfirmChoice2]
	ld l, a
	ld a, [wMenuChoice3]
	ld h, a
	ld [hl], $e8
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	xor a
	ld [wLinkPartnerChoice], a
	ret
TutorHPDigitSpots::
	dw $c562
	dw $c568
	dw $c56e

TutorMPDigitSpots::
	dw $c582
	dw $c588
	dw $c58e

TutorNameTileSpots::
	dw $9700
	dw $9740
	dw $9780

TutorPartyLayouts::
	dw TutorParty1Layout
	dw TutorParty1Layout
	dw TutorParty2Layout
	dw TutorParty3Layout

TutorSlotTextTiles::
	dw $8da0
	dw $8db0
	dw $8dc0
TutorMainCursorSpots::
	dw $01c1
	dw $0201
	dw $01c7
	dw $0207

TutorListCursorSpots::
	dw $0141
	dw $0181
	dw $01c1
	dw $0201
TutorYesNoCursorSpots::
	dw $012f
	dw $016f

StartText_59::
	ld de, TextGroups_59
	call StartText
	ret

CopyText_59::
	ld de, TextGroups_59
	call CopyTextString
	ret

PrintText_59::
	call StartText_59
	call RunTextToEnd
	ret

TextGroups_59::
	dw TextGroup_59_0
	dw TextGroup_59_1
	dw TextGroup_59_2
	dw TextGroup_59_3

TextGroup_59_0::
	dw Texts_59 + $000
	dw Texts_59 + $021
	dw Texts_59 + $136
	dw Texts_59 + $1ea
	dw Texts_59 + $31f
	dw Texts_59 + $3c0
	dw Texts_59 + $40f

TextGroup_59_1::
	dw Texts_59 + $450
	dw Texts_59 + $455
	dw Texts_59 + $457

TextGroup_59_2::
	dw Texts_59 + $473
	dw Texts_59 + $4c8
	dw Texts_59 + $582
	dw Texts_59 + $613
	dw Texts_59 + $666
	dw Texts_59 + $69b
	dw Texts_59 + $6cd
	dw Texts_59 + $702
	dw Texts_59 + $73c
	dw Texts_59 + $745
	dw Texts_59 + $783
	dw Texts_59 + $7c3
	dw Texts_59 + $7e2
	dw Texts_59 + $829

TextGroup_59_3::
	dw Texts_59 + $865

Texts_59::
	db $9f, $a3, $37, $45, $46, $50, $62, $46, $50, $62, $51, $45, $42, $ef, $ee, $65
	db $25, $3e, $51, $51, $49, $42, $62, $36, $40, $4f, $42, $42, $4b, $65, $5f, $f7
	db $f0, $9f, $a3, $36, $42, $49, $42, $40, $51, $62, $65, $29, $2c, $2a, $2b, $37
	db $65, $ef, $ee, $51, $4c, $62, $50, $51, $3e, $4f, $51, $62, $51, $45, $42, $62
	db $43, $46, $44, $45, $51, $fa, $fb, $f0, $ef, $ee, $3e, $52, $51, $4c, $4a, $3e
	db $51, $46, $40, $3e, $49, $49, $56, $5f, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $9f
	db $a3, $36, $42, $49, $42, $40, $51, $62, $65, $33, $2f, $24, $31, $65, $62, $51
	db $4c, $ef, $ee, $50, $42, $51, $62, $51, $45, $42, $62, $4d, $49, $3e, $4b, $50
	db $62, $4c, $43, $fa, $fb, $f0, $ef, $ee, $51, $45, $42, $62, $3f, $3e, $51, $51
	db $49, $42, $62, $43, $4c, $4f, $ef, $ee, $42, $3e, $40, $45, $62, $4c, $43, $62
	db $56, $4c, $52, $4f, $fa, $fb, $f0, $ef, $ee, $4a, $4c, $4b, $50, $51, $42, $4f
	db $50, $5f, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $9f, $a3, $36, $42, $49, $42, $40
	db $51, $62, $65, $2c, $37, $28, $30, $65, $ef, $ee, $51, $4c, $62, $45, $42, $49
	db $4d, $62, $51, $45, $42, $62, $fa, $fb, $f0, $ef, $ee, $4a, $4c, $4b, $50, $51
	db $42, $4f, $50, $62, $54, $46, $51, $45, $62, $51, $45, $42, $ef, $ee, $46, $51
	db $42, $4a, $50, $62, $56, $4c, $52, $62, $45, $3e, $53, $42, $5f, $fa, $fb, $f0
	db $ef, $ee, $9f, $a3, $24, $4b, $41, $62, $50, $42, $49, $42, $40, $51, $62, $65
	db $35, $38, $31, $65, $ef, $ee, $51, $4c, $62, $43, $49, $42, $42, $62, $43, $4f
	db $4c, $4a, $fa, $fb, $f0, $ef, $ee, $51, $45, $42, $62, $3f, $3e, $51, $51, $49
	db $42, $5f, $ef, $ee, $f7, $f0, $9f, $a3, $3a, $45, $42, $4b, $62, $65, $29, $2c
	db $2a, $2b, $37, $65, $62, $46, $50, $ef, $ee, $50, $42, $49, $42, $40, $51, $42
	db $41, $5e, $62, $51, $45, $42, $fa, $fb, $f0, $ef, $ee, $4a, $4c, $4b, $50, $51
	db $42, $4f, $50, $62, $54, $46, $49, $49, $5e, $ef, $ee, $fa, $fb, $f0, $ef, $ee
	db $9f, $a3, $40, $45, $4c, $4c, $50, $42, $62, $51, $45, $42, $46, $4f, $ef, $ee
	db $4c, $54, $4b, $62, $4a, $4c, $53, $42, $50, $5f, $fa, $fb, $f0, $ef, $ee, $9f
	db $a3, $2c, $43, $62, $56, $4c, $52, $62, $54, $3e, $4b, $51, $62, $51, $4c, $ef
	db $ee, $45, $3e, $53, $42, $6e, $4a, $62, $4d, $42, $4f, $43, $4c, $4f, $4a, $fa
	db $fb, $f0, $ef, $ee, $40, $42, $4f, $51, $3e, $46, $4b, $62, $4a, $4c, $53, $42
	db $50, $ef, $ee, $40, $4c, $4b, $50, $46, $41, $42, $4f, $5e, $fa, $fb, $f0, $ef
	db $ee, $9f, $a3, $51, $45, $42, $46, $4f, $ef, $ee, $65, $4d, $42, $4f, $50, $4c
	db $4b, $3e, $49, $46, $51, $56, $65, $63, $f7, $f0, $9f, $a3, $3a, $45, $42, $4b
	db $62, $65, $33, $2f, $24, $31, $65, $62, $46, $50, $ef, $ee, $50, $42, $49, $42
	db $40, $51, $42, $41, $5e, $62, $56, $4c, $52, $62, $50, $42, $51, $fa, $fb, $f0
	db $ef, $ee, $51, $45, $42, $62, $51, $4c, $4b, $42, $ef, $ee, $fa, $fb, $f0, $ef
	db $ee, $9f, $a3, $43, $4c, $4f, $62, $51, $45, $42, $62, $3f, $3e, $51, $51, $49
	db $42, $5f, $5f, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $9f, $a3, $65, $26, $2b, $24
	db $35, $2a, $28, $63, $65, $62, $4a, $3e, $48, $42, $50, $ef, $ee, $51, $45, $42
	db $4a, $62, $3e, $44, $4f, $42, $50, $50, $46, $53, $42, $5e, $fa, $fb, $f0, $ef
	db $ee, $9f, $a3, $65, $30, $2c, $3b, $28, $27, $65, $62, $4a, $3e, $48, $42, $50
	db $ef, $ee, $51, $45, $42, $4a, $62, $50, $52, $4d, $4d, $4c, $4f, $51, $fa, $fb
	db $f0, $ef, $ee, $51, $45, $42, $46, $4f, $62, $43, $4f, $46, $42, $4b, $41, $50
	db $5f, $5f, $5f, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $9f, $a3, $65, $26, $24, $38
	db $37, $2c, $32, $38, $36, $65, $62, $4a, $3e, $48, $42, $50, $ef, $ee, $51, $45
	db $42, $4a, $62, $43, $46, $44, $45, $51, $fa, $fb, $f0, $ef, $ee, $40, $3e, $52
	db $51, $46, $4c, $52, $50, $49, $56, $5f, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $9f
	db $a3, $25, $56, $62, $50, $42, $49, $42, $40, $51, $46, $4b, $44, $ef, $ee, $65
	db $26, $32, $30, $30, $24, $31, $27, $65, $5e, $fa, $fb, $f0, $ef, $ee, $9f, $a3
	db $56, $4c, $52, $62, $40, $3e, $4b, $62, $44, $46, $53, $42, $ef, $ee, $51, $45
	db $42, $4a, $62, $40, $4c, $4a, $4a, $3e, $4b, $41, $50, $fa, $fb, $f0, $ef, $ee
	db $41, $46, $4f, $42, $40, $51, $49, $56, $5f, $ef, $ee, $ef, $ee, $f7, $f0, $9f
	db $a3, $25, $56, $62, $50, $42, $49, $42, $40, $51, $46, $4b, $44, $ef, $ee, $65
	db $2c, $37, $28, $30, $65, $62, $56, $4c, $52, $62, $40, $3e, $4b, $fa, $fb, $f0
	db $ef, $ee, $45, $42, $49, $4d, $62, $56, $4c, $52, $4f, $ef, $ee, $4a, $4c, $4b
	db $50, $51, $42, $4f, $50, $62, $43, $46, $44, $45, $51, $5f, $5f, $5f, $fa, $fb
	db $f0, $ef, $ee, $9f, $a3, $5f, $5f, $5f, $3f, $56, $62, $52, $50, $46, $4b, $44
	db $ef, $ee, $46, $51, $42, $4a, $50, $5e, $fa, $fb, $f0, $ef, $ee, $9f, $a3, $4c
	db $4f, $62, $56, $4c, $52, $62, $40, $3e, $4b, $62, $51, $3e, $4a, $42, $ef, $ee
	db $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $68, $fa, $fb, $f0, $ef, $ee, $4a
	db $4c, $4b, $50, $51, $42, $4f, $50, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $9f, $a3
	db $54, $46, $51, $45, $62, $4a, $42, $3e, $51, $63, $ef, $ee, $ef, $ee, $f7, $f0
	db $9f, $a3, $36, $42, $49, $42, $40, $51, $62, $65, $35, $38, $31, $65, $ef, $ee
	db $54, $45, $42, $4b, $62, $56, $4c, $52, $62, $54, $3e, $4b, $51, $62, $51, $4c
	db $fa, $fb, $f0, $ef, $ee, $43, $49, $42, $42, $62, $43, $4f, $4c, $4a, $ef, $ee
	db $fa, $fb, $f0, $ef, $ee, $9f, $a3, $51, $45, $42, $62, $42, $4b, $42, $4a, $56
	db $ef, $ee, $4a, $4c, $4b, $50, $51, $42, $4f, $50, $5f, $ef, $ee, $f7, $f0, $9f
	db $a3, $37, $45, $3e, $51, $68, $62, $3e, $49, $49, $62, $3e, $3f, $4c, $52, $51
	db $ef, $ee, $65, $3f, $3e, $51, $51, $49, $42, $65, $5f, $fa, $fb, $f0, $ef, $ee
	db $9f, $a3, $2f, $42, $3e, $4f, $4b, $62, $51, $45, $42, $62, $4f, $42, $50, $51
	db $ef, $ee, $4c, $4b, $62, $56, $4c, $52, $4f, $62, $4c, $54, $4b, $5f, $f7, $f0
	db $36, $49, $46, $4c, $f0, $ed, $f0, $ed, $2a, $4f, $3e, $4b, $41, $4d, $3e, $62
	db $36, $3e, $48, $3e, $4a, $4c, $51, $4c, $f1, $46, $50, $62, $45, $42, $4f, $42
	db $63, $ec, $f0, $36, $42, $49, $42, $40, $51, $62, $65, $29, $2c, $2a, $2b, $37
	db $65, $62, $b6, $ef, $ee, $51, $45, $42, $62, $4a, $4c, $4b, $50, $51, $42, $4f
	db $50, $62, $3e, $40, $51, $fa, $fb, $f0, $ef, $ee, $3f, $3e, $50, $42, $41, $62
	db $4c, $4b, $62, $51, $45, $42, $ef, $ee, $4d, $4f, $42, $53, $46, $4c, $52, $50
	db $62, $4d, $49, $3e, $4b, $fa, $fb, $f0, $ef, $ee, $56, $4c, $52, $62, $40, $45
	db $4c, $50, $42, $5f, $ef, $ee, $f7, $f0, $36, $42, $49, $42, $40, $51, $62, $65
	db $33, $2f, $24, $31, $65, $62, $3e, $4b, $41, $ef, $ee, $51, $45, $42, $62, $4a
	db $3e, $50, $51, $42, $4f, $62, $40, $3e, $4b, $62, $50, $42, $51, $fa, $fb, $f0
	db $ef, $ee, $51, $45, $42, $62, $51, $4c, $4b, $42, $62, $4c, $43, $62, $51, $45
	db $42, $ef, $ee, $3f, $3e, $51, $51, $49, $42, $62, $50, $51, $4f, $3e, $51, $42
	db $44, $56, $5f, $fa, $fb, $f0, $ef, $ee, $37, $45, $42, $62, $4a, $4c, $4b, $50
	db $51, $42, $4f, $62, $54, $46, $49, $49, $ef, $ee, $40, $3e, $4f, $4f, $56, $62
	db $4c, $52, $51, $62, $51, $45, $42, $fa, $fb, $f0, $ef, $ee, $50, $51, $4f, $3e
	db $51, $42, $44, $56, $62, $52, $4b, $49, $42, $50, $50, $ef, $ee, $51, $45, $42
	db $62, $4a, $4c, $4b, $50, $51, $42, $4f, $62, $46, $50, $62, $4b, $4c, $51, $fa
	db $fb, $f0, $ef, $ee, $49, $46, $50, $51, $42, $4b, $46, $4b, $44, $62, $51, $4c
	db $62, $56, $4c, $52, $4f, $ef, $ee, $40, $4c, $4a, $4a, $3e, $4b, $41, $50, $5f
	db $f7, $f0, $36, $42, $49, $42, $40, $51, $46, $4b, $44, $62, $65, $2c, $37, $28
	db $30, $65, $ef, $ee, $3e, $49, $49, $4c, $54, $50, $62, $51, $45, $42, $62, $4a
	db $3e, $50, $51, $42, $4f, $fa, $fb, $f0, $ef, $ee, $51, $4c, $62, $3e, $51, $51
	db $3e, $40, $48, $62, $42, $4b, $42, $4a, $56, $ef, $ee, $4a, $4c, $4b, $50, $51
	db $42, $4f, $50, $62, $41, $46, $4f, $42, $40, $51, $49, $56, $5f, $fa, $fb, $f0
	db $ef, $ee, $24, $49, $50, $4c, $5e, $62, $46, $51, $62, $3e, $49, $49, $4c, $54
	db $50, $ef, $ee, $51, $45, $42, $62, $45, $42, $3e, $49, $46, $4b, $44, $62, $4c
	db $43, $fa, $fb, $f0, $ef, $ee, $42, $46, $51, $45, $42, $4f, $62, $42, $4b, $42
	db $4a, $46, $42, $50, $62, $4c, $4f, $ef, $ee, $43, $4f, $46, $42, $4b, $41, $50
	db $5f, $f7, $f0, $36, $42, $49, $42, $40, $51, $62, $65, $35, $38, $31, $65, $ef
	db $ee, $54, $45, $42, $4b, $62, $56, $4c, $52, $62, $4f, $42, $3e, $49, $49, $56
	db $fa, $fb, $f0, $ef, $ee, $54, $3e, $4b, $51, $62, $51, $4c, $62, $43, $49, $42
	db $42, $5f, $ef, $ee, $fa, $fb, $f0, $ef, $ee, $25, $52, $51, $62, $46, $51, $62
	db $41, $4c, $42, $50, $4b, $67, $ef, $ee, $3e, $49, $54, $3e, $56, $50, $62, $54
	db $4c, $4f, $48, $5f, $f7, $f0, $36, $42, $49, $42, $40, $51, $62, $65, $26, $2b
	db $24, $35, $2a, $28, $63, $65, $ef, $ee, $43, $4c, $4f, $62, $3e, $4b, $62, $3e
	db $44, $44, $4f, $42, $50, $50, $46, $53, $42, $fa, $fb, $f0, $ef, $ee, $50, $51
	db $4f, $3e, $51, $42, $44, $56, $5f, $ef, $ee, $f7, $f0, $36, $42, $49, $42, $40
	db $51, $62, $65, $30, $2c, $3b, $28, $27, $65, $ef, $ee, $43, $4c, $4f, $62, $3e
	db $62, $50, $52, $4d, $4d, $4c, $4f, $51, $46, $53, $42, $fa, $fb, $f0, $ef, $ee
	db $50, $51, $4f, $3e, $51, $42, $44, $56, $5f, $ef, $ee, $f7, $f0, $36, $42, $49
	db $42, $40, $51, $62, $65, $26, $24, $38, $37, $2c, $32, $38, $36, $65, $ef, $ee
	db $43, $4c, $4f, $62, $3e, $62, $50, $51, $4f, $3e, $51, $42, $44, $56, $62, $51
	db $4c, $fa, $fb, $f0, $ef, $ee, $50, $3e, $53, $42, $62, $2b, $33, $5f, $ef, $ee
	db $f7, $f0, $36, $42, $49, $42, $40, $51, $46, $4b, $44, $62, $ef, $ee, $65, $26
	db $32, $30, $30, $24, $31, $27, $65, $62, $3e, $49, $49, $4c, $54, $50, $fa, $fb
	db $f0, $ef, $ee, $56, $4c, $52, $62, $51, $4c, $62, $46, $50, $50, $52, $42, $ef
	db $ee, $40, $4c, $4a, $4a, $3e, $4b, $41, $50, $5f, $f7, $f0, $ed, $28, $4b, $4c
	db $52, $44, $45, $64, $f0, $36, $42, $49, $42, $40, $51, $62, $65, $24, $2f, $2f
	db $65, $62, $51, $4c, $ef, $ee, $44, $46, $53, $42, $62, $3e, $62, $50, $51, $4f
	db $3e, $51, $42, $44, $56, $62, $51, $4c, $fa, $fb, $f0, $ef, $ee, $3e, $49, $49
	db $62, $56, $4c, $52, $4f, $62, $4a, $4c, $4b, $50, $51, $42, $4f, $50, $5f, $ef
	db $ee, $f7, $f0, $36, $42, $49, $42, $40, $51, $62, $65, $28, $24, $26, $2b, $65
	db $ef, $ee, $51, $4c, $62, $44, $46, $53, $42, $62, $3e, $62, $50, $51, $4f, $3e
	db $51, $42, $44, $56, $fa, $fb, $f0, $ef, $ee, $51, $4c, $62, $46, $4b, $41, $46
	db $53, $46, $41, $52, $3e, $49, $ef, $ee, $4a, $4c, $4b, $50, $51, $42, $4f, $50
	db $5f, $f7, $f0, $65, $24, $37, $2e, $65, $62, $4a, $42, $3e, $4b, $50, $62, $3e
	db $ef, $ee, $4b, $4c, $4f, $4a, $3e, $49, $62, $3e, $51, $51, $3e, $40, $48, $5f
	db $f7, $f0, $3c, $4c, $52, $62, $40, $3e, $4b, $62, $50, $42, $49, $42, $40, $51
	db $ef, $ee, $51, $45, $42, $62, $50, $48, $46, $49, $49, $50, $62, $43, $4c, $4f
	db $62, $51, $45, $42, $fa, $fb, $f0, $ef, $ee, $4a, $4c, $4b, $50, $51, $42, $4f
	db $50, $62, $3f, $56, $ef, $ee, $50, $42, $49, $42, $40, $51, $46, $4b, $44, $62
	db $65, $36, $2e, $2c, $2f, $65, $5f, $f7, $f0, $3c, $4c, $52, $62, $40, $3e, $4b
	db $62, $40, $4c, $4a, $4a, $3e, $4b, $41, $ef, $ee, $51, $45, $42, $62, $4b, $42
	db $55, $51, $62, $41, $42, $43, $42, $4b, $50, $42, $fa, $fb, $f0, $ef, $ee, $3f
	db $56, $62, $50, $42, $49, $42, $40, $51, $46, $4b, $44, $ef, $ee, $65, $27, $28
	db $29, $65, $5f, $f7, $f0, $ed, $27, $46, $4f, $42, $40, $51, $46, $4c, $4b, $62
	db $31, $4c, $5f, $f0

SplitDecimal_59::
	xor a
	ld [wSceneObjects + 16], a
	ld [wSceneObjects + 17], a
	ld [wSceneObjects + 18], a

jr_059_5bb1:
	ld a, [wSceneObjects + 16]
	inc a
	ld [wSceneObjects + 16], a
	ld bc, hPlayerPrevY + 1
	add hl, bc
	ld a, h
	rlc a
	jr nc, jr_059_5bb1
	ld bc, $0064
	add hl, bc
	ld a, [wSceneObjects + 16]
	dec a
	ld [wSceneObjects + 16], a

jr_059_5bcc:
	ld a, [wSceneObjects + 17]
	inc a
	ld [wSceneObjects + 17], a
	ld bc, hChanFreq
	add hl, bc
	ld a, h
	rlc a
	jr nc, jr_059_5bcc
	ld bc, $000a
	add hl, bc
	ld a, [wSceneObjects + 17]
	dec a
	ld [wSceneObjects + 17], a
	ld a, l
	ld [wSceneObjects + 18], a
	ret

ReadWordAt_59::
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

ReadTableWord_59::
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

TutorPointFight::
	ld hl, wTilemapBuffer + 289
	ld [hl], $e8
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ld hl, wTilemapBuffer + 353
	ld [hl], $e0
	ld hl, wTilemapBuffer + 295
	ld [hl], $e0
	ld hl, wTilemapBuffer + 359
	ld [hl], $e0
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld hl, wSceneObjects + 1
	inc [hl]
	xor a
	ld [wSceneObjects + 3], a
	ret

TutorPointPlan::
	ld hl, wTilemapBuffer + 289
	ld [hl], $e0
	ld hl, wTilemapBuffer + 353
	ld [hl], $e8
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ld hl, wTilemapBuffer + 295
	ld [hl], $e0
	ld hl, wTilemapBuffer + 359
	ld [hl], $e0
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld hl, wSceneObjects + 1
	inc [hl]
	xor a
	ld [wSceneObjects + 3], a
	ret

TutorPointItem::
	ld hl, wTilemapBuffer + 289
	ld [hl], $e0
	ld hl, wTilemapBuffer + 353
	ld [hl], $e0
	ld hl, wTilemapBuffer + 295
	ld [hl], $e8
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ld hl, wTilemapBuffer + 359
	ld [hl], $e0
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld hl, wSceneObjects + 1
	inc [hl]
	xor a
	ld [wSceneObjects + 3], a
	ret

TutorPointRun::
	ld hl, wTilemapBuffer + 289
	ld [hl], $e0
	ld hl, wTilemapBuffer + 353
	ld [hl], $e0
	ld hl, wTilemapBuffer + 295
	ld [hl], $e0
	ld hl, wTilemapBuffer + 359
	ld [hl], $e8
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld hl, wSceneObjects + 1
	inc [hl]
	xor a
	ld [wSceneObjects + 3], a
	ret
TutorBlinkCursor::
	ld hl, wSceneObjects + 3
	inc [hl]
	ld a, [wSceneObjects + 3]
	cp $0a
	jr z, jr_059_5cb0
	cp $14
	jr z, jr_059_5cbf
	ret


jr_059_5cb0:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld [hl], $e0
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


jr_059_5cbf:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld [hl], $e8
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	xor a
	ld [wSceneObjects + 3], a
	ret

DrawLayout_59::
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	add hl, bc

jr_059_5cd9:
	push hl

jr_059_5cda:
	ld a, [de]
	inc de
	cp $d8
	jr z, jr_059_5cea
	cp $d9
	jr z, jr_059_5cf5
	call WriteVRAM
	inc hl
	jr jr_059_5cda


jr_059_5cea:
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_059_5cd9


jr_059_5cf5:
	pop hl
	ret

TutorScrollInStep::
	ld hl, hScrollY
	inc [hl]
	call ApplyScroll
	ldh a, [hScrollY]
	cp $00
	ret

TutorScrollOutStep::
	ld hl, hScrollY
	dec [hl]
	call ApplyScroll
	ldh a, [hScrollY]
	cp $d8
	ret

LoadTutorEnemyPic::
	ld a, $aa
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterPicRefs)
	ld l, a
	ld a, h
	adc HIGH(MonsterPicRefs)
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $9000
	call DecompressVRAM
	ret

DrawTutorBattleScreen::
	call ClearTilemapBuffer_59
	ld de, TutorEnemyNameLayout
	ld hl, $9b60
	call DrawLayout_59
	ld de, TutorEnemyNameBottomLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld de, TutorEnemyPicLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ld de, TutorMessageBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ret

ClearTilemapBuffer_59::
	ld a, $e0
	ld hl, wTilemapBuffer
	ld bc, $0240
	call FillMemory
	ret

Multiply_59::
	or a
	jr z, jr_059_5d68
	ld hl, $0000

jr_059_5d61:
	add hl, bc
	dec a
	jr nz, jr_059_5d61
	ld b, h
	ld c, l
	ret


jr_059_5d68:
	ld bc, $0000
	ret

TutorEnemyPicLayout::
	dw $0027
	db $00, $01, $02, $03, $04, $05, $d8
	db $06, $07, $08, $09, $0a, $0b, $d8
	db $0c, $0d, $0e, $0f, $10, $11, $d8
	db $12, $13, $14, $15, $16, $17, $d8
	db $18, $19, $1a, $1b, $1c, $1d, $d8
	db $1e, $1f, $20, $21, $22, $23, $d9

TutorPartyPicLayout::
	dw $00c7
	db $00, $01, $02, $03, $04, $05, $d8
	db $06, $07, $08, $09, $0a, $0b, $d8
	db $0c, $0d, $0e, $0f, $10, $11, $d8
	db $12, $13, $14, $15, $16, $17, $d8
	db $18, $19, $1a, $1b, $1c, $1d, $d8
	db $1e, $1f, $20, $21, $22, $23, $d9

TutorMessageBoxLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorMessageBoxLayout2::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorCommandBoxLayout::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $6c, $6c, $83, $7c, $e0, $e0, $6d, $7c, $6e, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7e, $7d, $7f, $82, $e0, $e0, $81, $80, $6f, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorEnemyNameLayout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $e0, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $f1, $f9, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $f2, $e0, $e0, $ff, $d9

TutorEnemyNameBottomLayout::
	dw $0000
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorYesNoLayout::
	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $e0, $d5, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

TutorOrderMenuLayout::
	dw $0160
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $87, $7c, $80, $9c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9b, $7d, $9d, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8a, $7c, $9c, $8b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorParty3Layout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorParty2Layout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorParty1Layout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorMainMenuLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

TutorTargetMenuLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $84, $9c, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedLayout_59_6106::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

TutorStrategyMenuLayout::
	dw $0120
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $96, $88, $91, $8d, $87, $8a, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8b, $86, $94, $8a, $95, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $91, $8e, $89, $86, $90, $8e, $8c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $90, $8b, $8b, $91, $8f, $95, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

UnusedLayouts_59::
	dw $0120
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0160
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $7e, $84, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $88, $87, $89, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0120
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0120
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $86, $88, $87, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0160
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $95, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $e0, $d5, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0048
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $51, $52, $53, $54, $55, $56, $57, $58, $59, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9d, $9e, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0040
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

	dw $010d
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0120
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0160
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $00c0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $9c, $d6, $d5, $e0, $e2, $e3, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e5, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a0, $a1, $a2, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a3, $a4, $a5, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0080
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $48, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $49, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $4a, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $4b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $010c
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $a6, $a7, $a8, $a9, $aa, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $89, $8a, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $00c0
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0160
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $89, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $84, $82, $86, $81, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $83, $8a, $85, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

	dw $0120
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

Bank59Padding::
	ds 6360, $00
