INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $059", ROMX[$4000], BANK[$59]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_59::
	db $59

;@ path: system/debug
;@ Entry points of bank $59 for far calls: start-up and per-frame routines of game modes 8 (the
;@ monster sprite viewer), 9 (the battle screen tutorial) and $0A (the battle command tutorial),
;@ then the three text routines of this bank's texts. Modes 8-$0A are only reached through the
;@ debug menu's mode jump (DebugModeJumpPage); nothing else in the game sets them.
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

;@ def SpriteViewerInit()
;@ path: system/debug/spriteviewer
;@ Start of game mode 8, a debug viewer for the monsters' walking sprites. Clears the state, sets up
;@ the text boxes (monster name in tiles $70-$78, the "Direction" / "No." labels of text 3/0 in
;@ tiles $80-$85), loads the sprite of monster wConfirmChoice, draws the boxes, the numbers and the
;@ two-entry menu into wTilemapBuffer and turns the screen on with a fade in.
;@ test: skip loads graphics and turns the screen on
SpriteViewerInit::
;> fill(wSceneObjects, 0, 0x28)                 # viewer state
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> fill(wMenuChoice, 0, 8)
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
;> fill(hSpriteX, 0, 0x12)                      # the sprite to draw
	xor a
	ld hl, hSpriteX
	ld bc, $0012
	call FillMemory
;> fill(wBattleAnimRunning, 0, 6)               # its animation object
	xor a
	ld hl, wBattleAnimRunning
	ld bc, $0006
	call FillMemory
;> fill(wTilemapBuffer, 0, 0x240)
	xor a
	ld hl, wTilemapBuffer
	ld bc, $0240
	call FillMemory
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wSGBPalSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
;> wSGBAttrSet = 0
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> wSkillAnimSprites = 0
	xor a
	ld [wSkillAnimSprites], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> SetUpTextBox(0x9700, lines=1, line_length=9)   # the monster's name
	ld hl, $9700
	ld de, $0901
	call SetUpTextBox
;> SpriteViewerLoadSpecies()
	call SpriteViewerLoadSpecies
;> SetUpTextBox(0x8800, lines=1, line_length=6)
	ld hl, $8800
	ld de, $0601
	call SetUpTextBox
;> wTextIndex = 0
	xor a
	ld [wTextIndex], a
;> wTextGroup = 3
	ld a, $03
	ld [wTextGroup], a
;> StartText_59()                               # "Direction" / "No."
	call StartText_59
;> wTextTiles = 0x9700                          # names go to the first box again
	ld hl, $9700
	ld de, $0901
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 9
	ld a, d
	ld [wTextBoxLineLength], a
;> Decompress(0x2E, 0x00, 0x8D00)               # box frame and digit tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
;> DrawLayout_59(SpriteViewerTitleLayout, wTilemapBuffer)
	ld hl, wTilemapBuffer
	ld de, SpriteViewerTitleLayout
	call DrawLayout_59
;> DrawLayout_59(SpriteViewerBoxesLayout, wTilemapBuffer)
	ld hl, wTilemapBuffer
	ld de, SpriteViewerBoxesLayout
	call DrawLayout_59
;> SpriteViewerDrawNumbers()
	call SpriteViewerDrawNumbers
;> SpriteViewerDrawMenu()
	call SpriteViewerDrawMenu
;> StartFade(0xFC)                              # fade in
	ld a, $fc
	call StartFade
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> hWY = 0xFF                                   # window off screen
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0
	ld a, $00
	ldh [hScrollY], a
;> hScrollX = 0
	ld a, $00
	ldh [hScrollX], a
;> ApplyScroll()
	call ApplyScroll
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLYCInterrupt()
	call EnableLYCInterrupt
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts

;@ def SpriteViewerUpdate()
;@ path: system/debug/spriteviewer
;@ Per-frame routine of game mode 8 (nothing happens while a fade runs). Keeps the buttons held in
;@ wSGBJoypads[0] and the newly pressed ones in wSGBJoypads[1], then runs state wSceneObjects[0].
;@ test: skip jumps through a table to the state routines
SpriteViewerUpdate::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSGBJoypads[0] = wJoyHeld
	ld a, [wJoyHeldLast]
	xor $ff
	ld b, a
	ld a, [wJoyHeld]
	ld [wSGBJoypads], a
;> wSGBJoypads[1] = wJoyHeld & ~wJoyHeldLast      # newly pressed
	or a
	jr z, .none

	and b

.none
	ld [wSGBJoypads + 1], a
;> SpriteViewerStates[wSceneObjects[0]]()
	ld a, [wSceneObjects]
	rst $00

;@ path: system/debug/spriteviewer
;@ States of the sprite viewer: 0 menu, 1 load the chosen monster, 2 loaded, 3 turn the sprite,
;@ 4 pick a monster number, 5 leave.
SpriteViewerStates::
	dw SpriteViewerMenu
	dw SpriteViewerLoad
	dw SpriteViewerLoaded
	dw SpriteViewerTurn
	dw SpriteViewerPick
	dw SpriteViewerExit

;@ def SpriteViewerMenu()
;@ path: system/debug/spriteviewer
;@ State 0: the menu (wMenuChoice: 0 "Direction", 1 "No."). Up or Down switch the entry, A marks it
;@ (bit 7) and goes to state 3 (turn the sprite) or 4 (pick a monster), B fades out to leave.
;@ test: skip calls far routines
SpriteViewerMenu::
;> SpriteViewerDrawSprite()
	call SpriteViewerDrawSprite
;> if wSGBJoypads[1] & 0x01:                     # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wMenuChoice |= 0x80
;>@a2     SpriteViewerDrawMenu()
;>@a3     wSceneObjects[0] = (wMenuChoice & 1) + 3     # state 3 or 4
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, .b

;>@b1     StartFade(4)
;>@b2     wSceneObjects[0] = 5
;> elif wSGBJoypads[1] & 0xC0:                   # Up or Down
	ld a, [wSGBJoypads + 1]
	and $c0
	jr nz, .upDown

	ret


.upDown
;>     wMenuChoice ^= 0x01
	ld a, [wMenuChoice]
	xor $01
	ld [wMenuChoice], a
;>     SpriteViewerDrawMenu()
	call SpriteViewerDrawMenu
	ret


.a
;=@a1
	ld a, [wMenuChoice]
	set 7, a
	ld [wMenuChoice], a
;=@a2
	call SpriteViewerDrawMenu
;=@a3
	ld a, [wMenuChoice]
	and $01
	add $03
	ld [wSceneObjects], a
	ret


.b
;=@b1
	ld a, $04
	call StartFade
;=@b2
	ld a, $05
	ld [wSceneObjects], a
	ret

;@ def SpriteViewerLoad()
;@ path: system/debug/spriteviewer
;@ State 1: loads the sprite and name of the monster picked (wConfirmChoice), then state 2.
;@ test: skip decompresses into VRAM
SpriteViewerLoad::
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
;> SpriteViewerLoadSpecies()
	call SpriteViewerLoadSpecies
	ret

;@ def SpriteViewerLoaded()
;@ path: system/debug/spriteviewer
;@ State 2: back to picking (state 4) with the numbers redrawn.
;@ test: skip calls a far routine
SpriteViewerLoaded::
;> wSceneObjects[0] = 4
	ld a, $04
	ld [wSceneObjects], a
;> SpriteViewerDrawNumbers()
	call SpriteViewerDrawNumbers
	ret

;@ def SpriteViewerTurn()
;@ path: system/debug/spriteviewer
;@ State 3: the d-pad turns the sprite (wBattleAnimIndex: 0 down, 1 sideways - mirrored for left -,
;@ 2 up); A switches between standing and walking (wSceneObjects[9] = 0 or 3 is added to the
;@ animation number); B goes back to the menu.
;@ test: skip calls far routines
SpriteViewerTurn::
;> SpriteViewerDrawSprite()
	call SpriteViewerDrawSprite
;> if wJoyHeld & 0x40:                           # Up
	ld a, [wJoyHeld]
	and $40
	jr nz, .up

;>@u1     wBattleAnimIndex = 2
;>@u2     hSpriteAttr = 0
;> elif wJoyHeld & 0x80:                         # Down
	ld a, [wJoyHeld]
	and $80
	jr nz, .down

;>@d1     wBattleAnimIndex = 0
;>@d2     hSpriteAttr = 0
;> elif wJoyHeld & 0x20:                         # Left
	ld a, [wJoyHeld]
	and $20
	jr nz, .left

;>@l1     wBattleAnimIndex = 1
;>@l2     hSpriteAttr = 0x20                         # mirrored
;> elif wJoyHeld & 0x10:                         # Right
	ld a, [wJoyHeld]
	and $10
	jr nz, .right

;>@r1     wBattleAnimIndex = 1
;>@r2     hSpriteAttr = 0
;> elif wSGBJoypads[1] & 0x01:                   # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@w1     wBattleAnimIndex -= wSceneObjects[9]
;>@w2     wSceneObjects[9] ^= 3                      # standing <-> walking
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, .b

;>@b1     wMenuChoice &= ~0x80
;>@b2     SpriteViewerDrawMenu()
;>@b3     wSceneObjects[0] = 0
;>@b4     return
;> else:
;>     return
	ret


.up
;=@u1
	ld a, $02
	ld [wBattleAnimIndex], a
;=@u2
	ld a, $00
	ldh [hSpriteAttr], a
	jr .set


.down
;=@d1
	ld a, $00
	ld [wBattleAnimIndex], a
;=@d2
	ld a, $00
	ldh [hSpriteAttr], a
	jr .set


.left
;=@l1
	ld a, $01
	ld [wBattleAnimIndex], a
;=@l2
	ld a, $20
	ldh [hSpriteAttr], a
	jr .set


.right
;=@r1
	ld a, $01
	ld [wBattleAnimIndex], a
;=@r2
	ld a, $00
	ldh [hSpriteAttr], a
	jr .set


.a
;=@w1
	ld a, [wSceneObjects + 9]
	ld b, a
	ld a, [wBattleAnimIndex]
	sub b
	ld [wBattleAnimIndex], a
;=@w2
	ld a, [wSceneObjects + 9]
	xor $03
	ld [wSceneObjects + 9], a

.set
;> wBattleAnimIndex += wSceneObjects[9]
	ld a, [wSceneObjects + 9]
	ld b, a
	ld a, [wBattleAnimIndex]
	add b
	ld [wBattleAnimIndex], a
;> wBattleAnimStep = 0
	xor a
	ld [wBattleAnimStep], a
;> wPlayerAnimPtr = addr(wBattleAnimSet)
	ld hl, wBattleAnimSet
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [wPlayerAnimPtr + 1], a
;> GetAnimationFirstPose()
	ld hl, far_GetAnimationFirstPose
	rst $10
	ret


.b
;=@b1
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
;=@b2
	call SpriteViewerDrawMenu
;=@b3
	xor a
	ld [wSceneObjects], a
;=@b4
	ret

;@ def SpriteViewerPick()
;@ path: system/debug/spriteviewer
;@ State 4: Left / Right (held) step the monster number wConfirmChoice through 0-$D6 with wrap
;@ around, A loads that monster (state 1), B goes back to the menu.
;@ test: skip calls far routines
SpriteViewerPick::
;> if wSGBJoypads[1] & 0x01:                     # A: load it
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wSceneObjects[0] = 1
;>@a2     return
;> SpriteViewerDrawSprite()
	call SpriteViewerDrawSprite
;> if wSGBJoypads[1] & 0x02:                     # B
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, .b

;>@b1     wMenuChoice &= ~0x80
;>@b2     SpriteViewerDrawMenu()
;>@b3     wSceneObjects[0] = 0
;> elif wJoyHeld & 0x20:                         # Left
	ld a, [wJoyHeld]
	and $20
	jr nz, .left

;>@l1     wConfirmChoice = (wConfirmChoice or 0xD7) - 1
;>@l2     SpriteViewerDrawNumbers()
;> elif wJoyHeld & 0x10:                         # Right
	ld a, [wJoyHeld]
	and $10
	jr nz, .right

	ret


.left
;=@l1
	ld a, [wConfirmChoice]
	or a
	jr nz, .dec

	ld a, $d7

.dec
;=@l1
	dec a
	ld [wConfirmChoice], a
;=@l2
	call SpriteViewerDrawNumbers
	ret


.right
;>     wConfirmChoice = (wConfirmChoice + 1) % 0xD7
	ld a, [wConfirmChoice]
	inc a
	cp $d7
	jr c, .store

	xor a

.store
	ld [wConfirmChoice], a
;>     SpriteViewerDrawNumbers()
	call SpriteViewerDrawNumbers
	ret


.a
;=@a1
	ld a, $01
	ld [wSceneObjects], a
;=@a2
	ret


.b
;=@b1
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
;=@b2
	call SpriteViewerDrawMenu
;=@b3
	xor a
	ld [wSceneObjects], a
	ret
;@ def SpriteViewerExit()
;@ path: system/debug/spriteviewer
;@ State 5 (after the fade out): switches to game mode 0, the opening, from its start.
SpriteViewerExit::
;> wGameMode = 0
	ld a, $00
	ld [wGameMode], a
;> wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;> wOpeningScene = 0
	xor a
	ld [wOpeningScene], a
;> wOpeningLogo = 0
	xor a
	ld [wOpeningLogo], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret

;@ def SpriteViewerDrawSprite()
;@ path: system/debug/spriteviewer
;@ Draws the monster's walking sprite (sprite set wSceneObjects[8] + $10) at X $50, Y $48 in the
;@ pose its animation object (wBattleAnimSet...) gives, and steps the animation; when the animation
;@ object stops, its step is reset.
;@ test: skip calls far routines
SpriteViewerDrawSprite::
;> hSpriteX = 0x50
	ld hl, hSpriteX
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x48
	ld a, $48
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = wSceneObjects[8] + 0x10
	ld a, [wSceneObjects + 8]
	add $10
	ld [hli], a
;> hSpriteTileBase = 0
	inc hl
	ld a, $00
	ld [hl], a
;> wPlayerAnimPtr = addr(wBattleAnimSet)
	ld hl, wBattleAnimSet
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [wPlayerAnimPtr + 1], a
;> GetAnimationFirstPose()
	ld hl, far_GetAnimationFirstPose
	rst $10
;> if hSpriteFrame == 0xFF:
;>     return
	ldh a, [hSpriteFrame]
	cp $ff
	ret z

;> DrawActorSprite()
	ld hl, far_DrawActorSprite
	rst $10
;> wPlayerAnimPtr = addr(wBattleAnimRunning)
	ld hl, wBattleAnimRunning
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [wPlayerAnimPtr + 1], a
;> StepAnimation()
	ld hl, far_StepAnimation
	rst $10
;> if not wBattleAnimRunning:
;>     wBattleAnimStep = 0
	ld a, [wBattleAnimRunning]
	or a
	ret nz

	xor a
	ld [wBattleAnimStep], a
	ret
;@ def SpriteViewerLoadSpecies()
;@ path: system/debug/spriteviewer
;@ Makes monster wConfirmChoice the one shown (wSceneObjects[8]): unpacks its walking sprite
;@ (MonsterSpriteGfx_59) to $8000 and prints its name (system text group 5) into the name box.
;@ test: skip decompresses into VRAM
SpriteViewerLoadSpecies::
;> wSceneObjects[8] = wConfirmChoice
	ld a, [wConfirmChoice]
	ld l, a
	ld [wSceneObjects + 8], a
;>@g gfx = mem16[MonsterSpriteGfx_59 + 2 * wConfirmChoice]
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterSpriteGfx_59)
	ld l, a
	ld a, h
;=@g
	adc HIGH(MonsterSpriteGfx_59)
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;> DecompressVRAM(gfx >> 8, gfx & 0xFF, 0x8000)
	ld h, $80
	ld l, $00
	call DecompressVRAM
;> wTextIndex = wConfirmChoice
	ld a, [wConfirmChoice]
	ld [wTextIndex], a
;> wTextGroup = 5                                # monster names
	ld a, $05
	ld [wTextGroup], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
	ret

;@ def SpriteViewerDrawNumbers()
;@ path: system/debug/spriteviewer
;@ Writes two 3-digit numbers into wTilemapBuffer (digit tiles $F0-$F9): the monster shown
;@ (wSceneObjects[8]) in the top box and the one picked (wConfirmChoice) in the "No." box, then
;@ copies the buffer to the screen.
;@ test: skip calls a far routine
SpriteViewerDrawNumbers::
;> SplitDecimal_59(wSceneObjects[8])
	ld a, [wSceneObjects + 8]
	ld l, a
	ld h, $00
	call SplitDecimal_59
;>@n for i in range(3): wTilemapBuffer[0x21 + i] = wSceneObjects[16 + i] + 0xF0
	ld hl, wTilemapBuffer + 33
	ld a, [wSceneObjects + 16]
	add $f0
	ld [hli], a
;=@n
	ld a, [wSceneObjects + 17]
	add $f0
	ld [hli], a
	ld a, [wSceneObjects + 18]
	add $f0
	ld [hli], a
;> SplitDecimal_59(wConfirmChoice)
	ld a, [wConfirmChoice]
	ld l, a
	ld h, $00
	call SplitDecimal_59
;>@m for i in range(3): wTilemapBuffer[0x208 + i] = wSceneObjects[16 + i] + 0xF0
	ld hl, wTilemapBuffer + 520
	ld a, [wSceneObjects + 16]
	add $f0
	ld [hli], a
;=@m
	ld a, [wSceneObjects + 17]
	add $f0
	ld [hli], a
	ld a, [wSceneObjects + 18]
	add $f0
	ld [hl], a
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret

;@ def SpriteViewerDrawMenu()
;@ path: system/debug/spriteviewer
;@ Draws the menu column and the cursor at entry wMenuChoice & 1 (SpriteViewerCursorSpots): an
;@ arrow ($E8), or the "chosen" arrow ($E9) while bit 7 is set; then copies the buffer to the screen.
;@ test: skip calls a far routine
SpriteViewerDrawMenu::
;> DrawLayout_59(SpriteViewerMenuLayout, wTilemapBuffer)
	ld hl, wTilemapBuffer
	ld de, SpriteViewerMenuLayout
	call DrawLayout_59
;>@p p = wTilemapBuffer + mem16[SpriteViewerCursorSpots + 2 * (wMenuChoice & 1)]
	ld a, [wMenuChoice]
	ld hl, SpriteViewerCursorSpots
	and $01
	add a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@p
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;>@c mem[p] = 0xE9 if wMenuChoice & 0x80 else 0xE8
	ld a, [wMenuChoice]
	bit 7, a
	jr nz, .chosen

	ld a, $e8
	jr .put


.chosen
	ld a, $e9

.put
;=@c
	ld [hl], a
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret

;@ path: system/debug/spriteviewer
;@ Graphics numbers (u16: bank << 8 | entry for DecompressVRAM) of the walking sprites, one per
;@ species 0-$D6: a copy of MonsterSpriteGfx from sprite set $10 on.
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

;@ path: system/debug/spriteviewer
;@ Box layout (format: DrawLayout_59) at the top of the sprite viewer: a 3-digit box for the
;@ monster number and a box with the monster's name (tiles $70-$78).
SpriteViewerTitleLayout::
	dw $0000
	db $fa, $ef, $ef, $ef, $fb, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $e0, $e0, $ff, $fe, $70, $71, $72, $73, $74, $75, $76, $77, $78, $ff, $d8
	db $fc, $ee, $ee, $ee, $fd, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/spriteviewer
;@ Box layout (format: DrawLayout_59) from row 13: the menu box with the labels of text 3/0 (tiles
;@ $80-$85) and a 3-digit box for the number being picked.
SpriteViewerBoxesLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $80, $81, $e0, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $fa, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $82, $83, $84, $85, $ff, $fe, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $fc, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/spriteviewer
;@ Box layout (format: DrawLayout_59): the cursor column of the menu (row 13-17, column 1), drawn
;@ again before the cursor is put in.
SpriteViewerMenuLayout::
	dw $01a1
	db $ef, $d8
	db $e0, $d8
	db $e0, $d8
	db $e0, $d8
	db $ee, $d9

;@ path: system/debug/spriteviewer
;@ wTilemapBuffer offsets of the menu cursor: entry 0 (row 14) and entry 1 (row 16), column 1.
SpriteViewerCursorSpots::
	dw $01c1
	dw $0201

;@ def BattleTutorInit()
;@ path: system/debug/battletutor
;@ Start of game mode 9, a tutorial of the battle screen: a mock battle screen (enemy picture of
;@ species $AA, the enemy name box, the party panel and the message box) on which an old man's
;@ texts explain the four commands while the cursor moves over them. Sets up the text boxes (the
;@ enemy name, text 1/0, in tiles $70-$73; three label boxes printed from text group 3 of bank $4C,
;@ whose entries in this version all hold the same item message; the message box at $8B00),
;@ draws the screen and starts it scrolled to Y $D8 with a fade in.
;@ test: skip loads graphics and turns the screen on
BattleTutorInit::
;> fill(wTextTiles, 0, 0x12)                    # text box set-up
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
;> fill(wSceneObjects, 0, 0x28)                 # tutorial state
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> wTextBoxMap = 0x99C1
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [wTextBoxMap + 1], a
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wSGBPalSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
;> wSGBAttrSet = 0
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> wSkillAnimSprites = 0
	xor a
	ld [wSkillAnimSprites], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> LoadTutorEnemyPic()
	call LoadTutorEnemyPic
;> Decompress(0x2E, 0x00, 0x8D00)               # box frame and digit tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> SetUpTextBox(0x9700, lines=1, line_length=4)
	ld hl, $9700
	ld de, $0401
	call SetUpTextBox
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> PrintText_59()                               # the enemy's name
	call PrintText_59
;> SetUpTextBox(0x96C0, lines=1, line_length=4)
	ld hl, $96c0
	ld de, $0401
	call SetUpTextBox
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> wTextGroup = 3
	ld a, $03
	ld [wTextGroup], a
;> PrintText_4C()
	ld hl, far_PrintText_4C
	rst $10
;> SetUpTextBox(0x97C0, lines=1, line_length=4)
	ld hl, $97c0
	ld de, $0401
	call SetUpTextBox
;> wTextIndex = 1
	ld a, $01
	ld [wTextIndex], a
;> wTextGroup = 3
	ld a, $03
	ld [wTextGroup], a
;> PrintText_4C()
	ld hl, far_PrintText_4C
	rst $10
;> SetUpTextBox(0x8800, lines=1, line_length=4)
	ld hl, $8800
	ld de, $0401
	call SetUpTextBox
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> wTextGroup = 3
	ld a, $03
	ld [wTextGroup], a
;> PrintText_4C()
	ld hl, far_PrintText_4C
	rst $10
;> SetUpTextBox(0x8B00, lines=2, line_length=18)   # the message box
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> DrawTutorBattleScreen()
	call DrawTutorBattleScreen
;> DrawLayout_59(TutorMessageBoxHighLayout, wTilemapBuffer)
	ld de, TutorMessageBoxHighLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;> StartFade(0xFC)                              # fade in
	ld a, $fc
	call StartFade
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> hWY = 0xFF                                   # window off screen
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0xD8                              # 40 pixels up: the message box is out of view
	ld a, $d8
	ldh [hScrollY], a
;> hScrollX = 0
	ld a, $00
	ldh [hScrollX], a
;> ApplyScroll()
	call ApplyScroll
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLYCInterrupt()
	call EnableLYCInterrupt
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts
;@ def BattleTutorUpdate()
;@ path: system/debug/battletutor
;@ Per-frame routine of game mode 9: runs tutorial step wSceneObjects[1] (BattleTutorSteps).
;@ test: skip jumps through a table to the step routines
BattleTutorUpdate::
;> BattleTutorSteps[wSceneObjects[1]]()
	ld a, [wSceneObjects + 1]
	rst $00

;@ path: system/debug/battletutor
;@ The 44 steps of the battle screen tutorial, one after the other: fade in, the old man's
;@ greeting, the command box, then for each explanation: scroll the message box into view, the
;@ text of group 0 (0 the battle screen, 1 FIGHT, 2 what FIGHT does, 3 PLAN, 4 ITEM, 5 RUN, 6 the
;@ end), wait, scroll it out again, and move the cursor to the next command; at the end a fade
;@ out and back to the opening.
BattleTutorSteps::
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

;@ def TutorScrollIn()
;@ path: system/debug/battletutor
;@ Tutorial step: scrolls the view one pixel a frame until Y is 0 (the message box in view).
;@ test: hScrollY = rand(0, 255)
TutorScrollIn::
;> if not TutorScrollInStep():
;>     return
	call TutorScrollInStep
	ret nz

;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorScrollOut()
;@ path: system/debug/battletutor
;@ Tutorial step: scrolls the view back one pixel a frame until Y is $D8; then empties the
;@ message box (text 1/1).
;@ test: skip runs the text printer
TutorScrollOut::
;> if not TutorScrollOutStep():
;>     return
	call TutorScrollOutStep
	ret nz

;> wTextIndex = 1
	ld a, $01
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> PrintText_59()
	call PrintText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorWaitText()
;@ path: system/debug/battletutor
;@ Tutorial step: waits until the text printer is done.
TutorWaitText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorWaitFade()
;@ path: system/debug/battletutor
;@ Tutorial step: waits until the fade is over.
TutorWaitFade::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorBlink15()
;@ path: system/debug/battletutor
;@ Tutorial step: blinks the cursor for 15 frames.
;@ test: skip calls a far routine
TutorBlink15::
;> TutorBlinkCursor()
	call TutorBlinkCursor
;> wSceneObjects[2] += 1
	ld hl, wSceneObjects + 2
	inc [hl]
;> if wSceneObjects[2] != 15:
;>     return
	ld a, [wSceneObjects + 2]
	cp $0f
	ret nz

;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
;> wSceneObjects[2] = 0
	xor a
	ld [wSceneObjects + 2], a
	ret

;@ def TutorBlink40()
;@ path: system/debug/battletutor
;@ Tutorial step: blinks the cursor for 40 frames.
;@ test: skip calls a far routine
TutorBlink40::
;> TutorBlinkCursor()
	call TutorBlinkCursor
;> wSceneObjects[2] += 1
	ld hl, wSceneObjects + 2
	inc [hl]
;> if wSceneObjects[2] != 40:
;>     return
	ld a, [wSceneObjects + 2]
	cp $28
	ret nz

;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
;> wSceneObjects[2] = 0
	xor a
	ld [wSceneObjects + 2], a
	ret

;@ def TutorStartIntro()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 1/2, the old man's greeting.
;@ test: skip starts the text printer
TutorStartIntro::
;> wTextIndex = 2
	ld a, $02
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorShowCommands()
;@ path: system/debug/battletutor
;@ Tutorial step (once the greeting is printed): empties the message box, redraws the screen with
;@ the command box (FIGHT, PLAN, ITEM, RUN) and puts the cursor on FIGHT. wSkillAmount holds
;@ the cursor's address in wTilemapBuffer for the blinking.
;@ test: skip runs the text printer
TutorShowCommands::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wTextIndex = 1
	ld a, $01
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> PrintText_59()
	call PrintText_59
;> DrawTutorBattleScreen()
	call DrawTutorBattleScreen
;> DrawLayout_59(TutorCommandBoxLayout, wTilemapBuffer)
	ld de, TutorCommandBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;> wTilemapBuffer[0x121] = 0xE8                 # cursor on FIGHT
	ld hl, wTilemapBuffer + 289
	ld [hl], $e8
;> wSkillAmount = addr(wTilemapBuffer) + 0x121
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> wSceneObjects[3] = 0                         # blink timer
	xor a
	ld [wSceneObjects + 3], a
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain0()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/0 ("This is the Battle Screen").
;@ test: skip starts the text printer
TutorExplain0::
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain1()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/1 (select FIGHT to start the fight).
;@ test: skip starts the text printer
TutorExplain1::
;> wTextIndex = 1
	ld a, $01
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain2()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/2 (what happens when FIGHT is selected).
;@ test: skip starts the text printer
TutorExplain2::
;> wTextIndex = 2
	ld a, $02
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain3()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/3 (PLAN).
;@ test: skip starts the text printer
TutorExplain3::
;> wTextIndex = 3
	ld a, $03
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain4()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/4 (ITEM).
;@ test: skip starts the text printer
TutorExplain4::
;> wTextIndex = 4
	ld a, $04
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain5()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/5 (RUN).
;@ test: skip starts the text printer
TutorExplain5::
;> wTextIndex = 5
	ld a, $05
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorExplain6()
;@ path: system/debug/battletutor
;@ Tutorial step: starts text 0/6 ("That's all about battle").
;@ test: skip starts the text printer
TutorExplain6::
;> wTextIndex = 6
	ld a, $06
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorStartFadeOut()
;@ path: system/debug/battletutor
;@ Tutorial step: starts the fade out.
TutorStartFadeOut::
;> StartFade(4)
	ld a, $04
	call StartFade
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def TutorBackToTitle()
;@ path: system/debug/battletutor
;@ Last tutorial step (after the fade out): switches to game mode 0, the opening, from its start.
TutorBackToTitle::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wGameMode = 0
	ld a, $00
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> wOpeningScene = 0
	ld a, $00
	ld [wOpeningScene], a
;> wOpeningLogo = 0
	ld a, $00
	ld [wOpeningLogo], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret

;@ def CommandTutorInit()
;@ path: system/debug/commandtutor
;@ Start of game mode $0A, a tutorial of the battle commands: on a mock battle screen with the
;@ player's own party the menus can be tried out (FIGHT / PLAN / ITEM / RUN, the strategies, ALL or
;@ EACH, the orders), and choosing an entry shows a text about it. Clears the state, prints the
;@ party's names, loads the tiles, draws the first menu and the labels and turns the screen on.
;@ test: skip loads graphics and turns the screen on
CommandTutorInit::
;> fill(wTextTiles, 0, 0x12)
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
;> fill(wSceneObjects, 0, 0x28)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> fill(wCommandStep, 0, 8)
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
;> fill(wMenuChoice, 0, 8)
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
;> fill(wListCursor, 0, 8)
	xor a
	ld hl, wListCursor
	ld bc, $0008
	call FillMemory
;> wTextBoxMap = 0x99C1
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [wTextBoxMap + 1], a
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [wBattleBGMap + 1], a
;> wLayoutRow = 0x9800
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [wLayoutRow + 1], a
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wSGBPalSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
;> wSGBAttrSet = 0
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> wSkillAnimSprites = 0
	xor a
	ld [wSkillAnimSprites], a
;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
;> LoadTutorEnemyPic()
	call LoadTutorEnemyPic
;> CmdTutorPrintNames()
	call CmdTutorPrintNames
;> Decompress(0x2E, 0x00, 0x8D00)               # box frame and digit tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;> CmdTutorPrintLabels()
	call CmdTutorPrintLabels
;> StartFade(0xFC)                              # fade in
	ld a, $fc
	call StartFade
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> hWY = 0xFF                                   # window off screen
	ld a, $ff
	ldh [hWY], a
;> hScrollX = 0
	ld a, $00
	ldh [hScrollX], a
;> hScrollY = 0
	ld a, $00
	ldh [hScrollY], a
;> ApplyScroll()
	call ApplyScroll
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLYCInterrupt()
	call EnableLYCInterrupt
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts
;@ def CommandTutorUpdate()
;@ path: system/debug/commandtutor
;@ Per-frame routine of game mode $0A (nothing happens while a fade runs). Keeps the buttons held
;@ in wSGBJoypads[0] and the newly pressed ones in wSGBJoypads[1], then runs state
;@ wSceneObjects[0] (CommandTutorStates).
;@ test: skip jumps through a table to the state routines
CommandTutorUpdate::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSGBJoypads[0] = wJoyHeld
	ld a, [wJoyHeldLast]
	xor $ff
	ld b, a
	ld a, [wJoyHeld]
	ld [wSGBJoypads], a
;> wSGBJoypads[1] = wJoyHeld & ~wJoyHeldLast      # newly pressed
	or a
	jr z, .none

	and b

.none
	ld [wSGBJoypads + 1], a
;> CommandTutorStates[wSceneObjects[0]]()
	ld a, [wSceneObjects]
	rst $00

;@ path: system/debug/commandtutor
;@ States of the command tutorial: 0 the command menu, 1 explain a command, 2 the strategy menu,
;@ 3 explain a strategy, 4 "Enough?" (leave), 5 ALL or EACH, 6 the order menu, 7 explain ALL /
;@ EACH, 8 explain an order.
CommandTutorStates::
	dw CmdTutorMainMenu
	dw CmdTutorExplainMain
	dw CmdTutorStrategyMenu
	dw CmdTutorExplainStrategy
	dw CmdTutorQuit
	dw CmdTutorTargetMenu
	dw CmdTutorOrderMenu
	dw CmdTutorExplainTarget
	dw CmdTutorExplainOrder

;@ def CmdTutorMainMenu()
;@ path: system/debug/commandtutor
;@ State 0, the command menu (wMenuChoice 0 FIGHT, 1 PLAN, 2 ITEM, 3 RUN in two columns). After a
;@ press, input is ignored for 8 frames (wLinkRefused counts them). Up / Down switch the row, Left /
;@ Right the column, A marks the command and goes to state 1 (its text), B goes to state 4
;@ ("Enough?"). Every move restarts the cursor blink (wLinkPartnerChoice, wListLastRows) and asks
;@ for the menu box to be redrawn (wBattleListCount 2, wCommandStep 0).
;@ test: skip calls far routines
CmdTutorMainMenu::
;> if wLinkRefused:                             # input pause after a press
	ld a, [wLinkRefused]
	or a
	jr z, .input

;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     if wLinkRefused < 8:
;>         return
	ld a, [wLinkRefused]
	cp $08
	ret c

;>     wLinkRefused = 0
	xor a
	ld [wLinkRefused], a

.input
;> CmdTutorBlinkCursor()
	call CmdTutorBlinkCursor
;> if wSGBJoypads[1] & 0x01:                     # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wLinkPartnerChoice = 0; wListLastRows = 1  # cursor stays on
;>@a2     wLinkRefused += 1
;>@a3     wMenuChoice |= 0x80
;>@a4     wBattleListCount = 2; wCommandStep = 0
;>@a5     CmdTutorDrawMenu()
;>@a6     wSceneObjects[0] = 1
;> elif wSGBJoypads[0] & 0xC0:                   # Up or Down
	ld a, [wSGBJoypads]
	and $c0
	jr nz, .upDown

;>@v1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@v2     wLinkRefused += 1
;>@v3     wMenuChoice ^= 0x01
;>@v4     wBattleListCount = 2; wCommandStep = 0
;>@v5     CmdTutorDrawMenu()
;> elif wSGBJoypads[0] & 0x30:                   # Left or Right
	ld a, [wSGBJoypads]
	and $30
	jr nz, .leftRight

;>@h1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@h2     wLinkRefused += 1
;>@h3     wMenuChoice ^= 0x02
;>@h4     wBattleListCount = 2; wCommandStep = 0
;>@h5     CmdTutorDrawMenu()
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jp nz, .b

	ret


.a
;=@a1
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
;=@a2
	ld hl, wLinkRefused
	inc [hl]
;=@a3
	ld a, [wMenuChoice]
	set 7, a
	ld [wMenuChoice], a
;=@a4
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@a5
	call CmdTutorDrawMenu
;=@a6
	ld a, $01
	ld [wSceneObjects], a
	ret


.upDown
;=@v1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@v2
	ld hl, wLinkRefused
	inc [hl]
;=@v3
	ld a, [wMenuChoice]
	xor $01
	ld [wMenuChoice], a
;=@v4
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@v5
	call CmdTutorDrawMenu
	ret


.leftRight
;=@h1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@h2
	ld hl, wLinkRefused
	inc [hl]
;=@h3
	ld a, [wMenuChoice]
	xor $02
	ld [wMenuChoice], a
;=@h4
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@h5
	call CmdTutorDrawMenu
	ret


.b
;>     wLinkPartnerChoice = 0; wListLastRows = 0
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     wBattleListCount = 2; wCommandStep = 0
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;>     wSceneObjects[1] = 0
	xor a
	ld [wSceneObjects + 1], a
;>     wSceneObjects[0] = 4
	ld a, $04
	ld [wSceneObjects], a
	ret

;@ def CmdTutorExplainMain()
;@ path: system/debug/commandtutor
;@ State 1: explains the chosen command in steps wSceneObjects[1] (CmdTutorExplainMainSteps).
;@ test: skip jumps through a table to the step routines
CmdTutorExplainMain::
;> CmdTutorExplainMainSteps[wSceneObjects[1]]()
	ld a, [wSceneObjects + 1]
	rst $00

;@ path: system/debug/commandtutor
;@ Steps of state 1: show only the message box, start the text, continue when it is done.
CmdTutorExplainMainSteps::
	dw CmdTutorClearMenu
	dw CmdTutorStartMainText
	dw CmdTutorAfterMainText

;@ def CmdTutorClearMenu()
;@ path: system/debug/commandtutor
;@ First step of every explanation: redraws the screen with only the message box (menu 1) and
;@ goes on.
;@ test: skip calls far routines
CmdTutorClearMenu::
;> wBattleListCount = 0                         # redraw everything
	xor a
	ld [wBattleListCount], a
;> wCommandSubStep = 1                          # the message box
	ld a, $01
	ld [wCommandSubStep], a
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def CmdTutorStartMainText()
;@ path: system/debug/commandtutor
;@ Starts text 2/(wMenuChoice & 3), the explanation of the chosen command.
;@ test: skip starts the text printer
CmdTutorStartMainText::
;> wTextIndex = wMenuChoice & 3
	ld a, [wMenuChoice]
	and $03
	ld [wTextIndex], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def CmdTutorAfterMainText()
;@ path: system/debug/commandtutor
;@ Once the text is done: PLAN goes on to the strategy menu (state 2) or, with two or more
;@ monsters, to ALL / EACH first (state 5); RUN goes to "Enough?" (state 4); FIGHT and ITEM go
;@ back to the command menu.
;@ test: skip calls far routines
CmdTutorAfterMainText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> choice = wMenuChoice & ~0x80
	ld a, [wMenuChoice]
	res 7, a
;> if choice == 1:                               # PLAN
	cp $01
	jr z, .plan

;>@p1     if wPartyCount < 2:
;>@p2         wSceneObjects[0] = 2; wSceneObjects[1] = 0
;>@p3         wBattleListCount = 0; wCommandSubStep = 2   # strategy menu
;>@p4     else:
;>@p5         wSceneObjects[0] = 5; wSceneObjects[1] = 0
;>@p6         wBattleListCount = 0; wCommandSubStep = 4   # ALL / EACH
;>@p7     wCommandStep = 0
;>@p8     CmdTutorDrawMenu()
;> elif choice == 3:                             # RUN
	cp $03
	jr z, .run

;>@r1     wMenuChoice = choice
;>@r2     wListLastRows = 0
;>@r3     wSceneObjects[0] = 4; wSceneObjects[1] = 0
;> else:
;>     wMenuChoice = choice
	ld [wMenuChoice], a
;>     wSceneObjects[0] = 0; wSceneObjects[1] = 0
	xor a
	ld [wSceneObjects], a
	ld [wSceneObjects + 1], a
;>     wBattleListCount = 0; wCommandSubStep = 0
	xor a
	ld [wBattleListCount], a
	xor a
	ld [wCommandSubStep], a
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
	ret


.plan
;=@p1
	ld a, [wPartyCount]
	cp $02
	jr nc, .two

;=@p2
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
;=@p3
	xor a
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
;=@p7
	xor a
	ld [wCommandStep], a
;=@p8
	call CmdTutorDrawMenu
	ret


.two
;=@p5
	ld a, $05
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
;=@p6
	xor a
	ld [wBattleListCount], a
	ld a, $04
	ld [wCommandSubStep], a
;=@p7
	xor a
	ld [wCommandStep], a
;=@p8
	call CmdTutorDrawMenu
	ret


.run
;=@r1
	ld [wMenuChoice], a
;=@r2
	xor a
	ld [wListLastRows], a
;=@r3
	ld a, $04
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret

;@ def CmdTutorStrategyMenu()
;@ path: system/debug/commandtutor
;@ State 2, the strategy menu (wMenuChoice2 0 CHARGE!, 1 MIXED, 2 CAUTIOUS, 3 COMMAND): Up / Down
;@ move with wrap around, A marks the entry and goes to state 3 (its text), B goes to ALL / EACH
;@ (state 5) with two or more monsters, else back to the command menu. Input pauses 8 frames
;@ after each press, as in CmdTutorMainMenu.
;@ test: skip calls far routines
CmdTutorStrategyMenu::
;> if wLinkRefused:                             # input pause after a press
	ld a, [wLinkRefused]
	or a
	jr z, .input

;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     if wLinkRefused < 8:
;>         return
	ld a, [wLinkRefused]
	cp $08
	ret c

;>     wLinkRefused = 0
	xor a
	ld [wLinkRefused], a

.input
;> CmdTutorBlinkCursor()
	call CmdTutorBlinkCursor
;> if wSGBJoypads[1] & 0x01:                     # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wLinkPartnerChoice = 0; wListLastRows = 1
;>@a2     wLinkRefused += 1
;>@a3     wMenuChoice2 |= 0x80
;>@a4     wBattleListCount = 2; wCommandStep = 0
;>@a5     CmdTutorDrawMenu()
;>@a6     wSceneObjects[0] = 3
;> elif wSGBJoypads[0] & 0x40:                   # Up
	ld a, [wSGBJoypads]
	and $40
	jr nz, .up

;>@u1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@u2     wLinkRefused += 1
;>@u3     wMenuChoice2 = (wMenuChoice2 - 1) & 3
;>@u4     wBattleListCount = 2; wCommandStep = 0
;>@u5     CmdTutorDrawMenu()
;> elif wSGBJoypads[0] & 0x80:                   # Down
	ld a, [wSGBJoypads]
	and $80
	jp nz, .down

;>@d1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@d2     wLinkRefused += 1
;>@d3     wMenuChoice2 = (wMenuChoice2 + 1) & 3
;>@d4     wBattleListCount = 2; wCommandStep = 0
;>@d5     CmdTutorDrawMenu()
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jp nz, .b

	ret


.a
;=@a1
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
;=@a2
	ld hl, wLinkRefused
	inc [hl]
;=@a3
	ld a, [wMenuChoice2]
	set 7, a
	ld [wMenuChoice2], a
;=@a4
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@a5
	call CmdTutorDrawMenu
;=@a6
	ld a, $03
	ld [wSceneObjects], a
	ret


.up
;=@u1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@u2
	ld hl, wLinkRefused
	inc [hl]
;=@u3
	ld a, [wMenuChoice2]
	or a
	jr z, .wrapUp

	dec a
	jr .storeUp


.wrapUp
;=@u3
	ld a, $03

.storeUp
;=@u3
	ld [wMenuChoice2], a
;=@u4
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@u5
	call CmdTutorDrawMenu
	ret


.down
;=@d1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@d2
	ld hl, wLinkRefused
	inc [hl]
;=@d3
	ld a, [wMenuChoice2]
	cp $03
	jr z, .wrapDown

	inc a
	jr .storeDown


.wrapDown
;=@d3
	xor a

.storeDown
;=@d3
	ld [wMenuChoice2], a
;=@d4
	ld a, $02
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@d5
	call CmdTutorDrawMenu
	ret


.b
;>     wLinkPartnerChoice = 0; wListLastRows = 0
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     if wPartyCount >= 2:                      # back to ALL / EACH
	ld a, [wPartyCount]
	cp $02
	jr c, .toMain

;>         wListPage &= ~0x80
	ld a, [wListPage]
	res 7, a
	ld [wListPage], a
;>         wBattleListCount = 0; wCommandSubStep = 4
	xor a
	ld [wBattleListCount], a
	ld a, $04
	ld [wCommandSubStep], a
;>         wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>         CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;>         wSceneObjects[0] = 5; wSceneObjects[1] = 0
	ld a, $05
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret


.toMain
;>     else:                                    # back to the command menu
;>         wMenuChoice &= ~0x80
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
;>         wSceneObjects[0] = 0; wSceneObjects[1] = 0; wMenuChoice2 = 0
	xor a
	ld [wSceneObjects], a
	ld [wSceneObjects + 1], a
	ld [wMenuChoice2], a
;>         wBattleListCount = 0; wCommandSubStep = 0; wCommandStep = 0
	ld [wBattleListCount], a
	ld [wCommandSubStep], a
	ld [wCommandStep], a
;>         CmdTutorDrawMenu()
	call CmdTutorDrawMenu
	ret

;@ def CmdTutorExplainStrategy()
;@ path: system/debug/commandtutor
;@ State 3: explains the chosen strategy in steps wSceneObjects[1] (CmdTutorExplainStrategySteps).
;@ test: skip jumps through a table to the step routines
CmdTutorExplainStrategy::
;> CmdTutorExplainStrategySteps[wSceneObjects[1]]()
	ld a, [wSceneObjects + 1]
	rst $00

;@ path: system/debug/commandtutor
;@ Steps of state 3: show only the message box, start the text, continue when it is done.
CmdTutorExplainStrategySteps::
	dw CmdTutorClearMenu
	dw CmdTutorStartStrategyText
	dw CmdTutorAfterStrategyText

;@ def CmdTutorStartStrategyText()
;@ path: system/debug/commandtutor
;@ Starts text 2/(4 + (wMenuChoice2 & 3)), the explanation of the chosen strategy.
;@ test: skip starts the text printer
CmdTutorStartStrategyText::
;> wTextIndex = (wMenuChoice2 & 3) + 4
	ld a, [wMenuChoice2]
	and $03
	add $04
	ld [wTextIndex], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def CmdTutorAfterStrategyText()
;@ path: system/debug/commandtutor
;@ Once the text is done: COMMAND goes on to the order menu (state 6), the other strategies back to
;@ the strategy menu (state 2).
;@ test: skip calls far routines
CmdTutorAfterStrategyText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> choice = wMenuChoice2 & 3
	ld a, [wMenuChoice2]
	and $03
;> if choice != 3:
	cp $03
	jr z, .command

;>     wMenuChoice2 = choice
	res 7, a
	ld [wMenuChoice2], a
;>     wSceneObjects[0] = 2; wSceneObjects[1] = 0
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
;>     wBattleListCount = 0; wCommandSubStep = 2
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
	ret


.command
;> else:
;>     wSceneObjects[0] = 6; wSceneObjects[1] = 0
	ld a, $06
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
;>     wBattleListCount = 0; wCommandSubStep = 5   # the order menu
	ld [wBattleListCount], a
	ld a, $05
	ld [wCommandSubStep], a
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
	ret

;@ def CmdTutorQuit()
;@ path: system/debug/commandtutor
;@ State 4, "Enough?": runs step wSceneObjects[1] (CmdTutorQuitSteps).
;@ test: skip jumps through a table to the step routines
CmdTutorQuit::
;> CmdTutorQuitSteps[wSceneObjects[1]]()
	ld a, [wSceneObjects + 1]
	rst $00

;@ path: system/debug/commandtutor
;@ Steps of state 4: ask, the yes / no menu, act on the answer, leave after the fade out.
CmdTutorQuitSteps::
	dw CmdTutorAskQuit
	dw CmdTutorQuitMenu
	dw CmdTutorQuitAnswer
	dw CmdTutorBackToTitle

;@ def CmdTutorAskQuit()
;@ path: system/debug/commandtutor
;@ Puts the cursor on "yes", draws the yes / no box (menu 3) with the screen and starts text 2/8
;@ ("Enough?").
;@ test: skip calls far routines
CmdTutorAskQuit::
;> wListCursor = 0
	xor a
	ld [wListCursor], a
;> wBattleListCount = 0; wCommandSubStep = 3
	xor a
	ld [wBattleListCount], a
	ld a, $03
	ld [wCommandSubStep], a
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;> wTextIndex = 8
	ld a, $08
	ld [wTextIndex], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def CmdTutorQuitMenu()
;@ path: system/debug/commandtutor
;@ The yes / no menu (wListCursor 0 yes, 1 no): Up / Down switch, A marks the answer and goes on,
;@ B returns to the command menu. Input pauses 8 frames after each press.
;@ test: skip calls far routines
CmdTutorQuitMenu::
;> if wLinkRefused:                             # input pause after a press
	ld a, [wLinkRefused]
	or a
	jr z, .input

;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     if wLinkRefused < 8:
;>         return
	ld a, [wLinkRefused]
	cp $08
	ret c

;>     wLinkRefused = 0
	xor a
	ld [wLinkRefused], a

.input
;> CmdTutorBlinkCursor()
	call CmdTutorBlinkCursor
;> if wSGBJoypads[1] & 0x01:                     # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wLinkPartnerChoice = 0; wListLastRows = 1
;>@a2     wLinkRefused += 1
;>@a3     wListCursor |= 0x80
;>@a4     wBattleListCount = 1; wCommandSubStep = 3
;>@a5     wCommandStep = 0
;>@a6     CmdTutorDrawMenu()
;>@a7     wSceneObjects[1] += 1
;> elif wSGBJoypads[0] & 0xC0:                   # Up or Down
	ld a, [wSGBJoypads]
	and $c0
	jr nz, .upDown

;>@v1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@v2     wLinkRefused += 1
;>@v3     wListCursor ^= 0x01
;>@v4     wBattleListCount = 1; wCommandSubStep = 3
;>@v5     wCommandStep = 0
;>@v6     CmdTutorDrawMenu()
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, CmdTutorQuitCancel

	ret


.a
;=@a1
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
;=@a2
	ld hl, wLinkRefused
	inc [hl]
;=@a3
	ld a, [wListCursor]
	set 7, a
	ld [wListCursor], a
;=@a4
	ld a, $01
	ld [wBattleListCount], a
	ld a, $03
	ld [wCommandSubStep], a
;=@a5
	xor a
	ld [wCommandStep], a
;=@a6
	call CmdTutorDrawMenu
;=@a7
	ld hl, wSceneObjects + 1
	inc [hl]
	ret


.upDown
;=@v1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@v2
	ld hl, wLinkRefused
	inc [hl]
;=@v3
	ld a, [wListCursor]
	xor $01
	ld [wListCursor], a
;=@v4
	ld a, $01
	ld [wBattleListCount], a
	ld a, $03
	ld [wCommandSubStep], a
;=@v5
	xor a
	ld [wCommandStep], a
;=@v6
	call CmdTutorDrawMenu
	ret


CmdTutorQuitCancel:
;>     wLinkPartnerChoice = 0; wListLastRows = 0   # back to the command menu
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     wBattleListCount = 0; wCommandSubStep = 0
	xor a
	ld [wBattleListCount], a
	xor a
	ld [wCommandSubStep], a
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;>     wSceneObjects[0] = 0; wSceneObjects[1] = 0
	xor a
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret

;@ def CmdTutorQuitAnswer()
;@ path: system/debug/commandtutor
;@ "No" returns to the command menu (the B path of CmdTutorQuitMenu); "yes" starts the fade out
;@ and goes on to leave.
;@ test: skip calls far routines
CmdTutorQuitAnswer::
;> if wListCursor & 0x01:                       # no
;>     return CmdTutorQuitCancel()
	ld a, [wListCursor]
	and $01
	jr nz, CmdTutorQuitCancel

;> StartFade(4)
	ld a, $04
	call StartFade
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def CmdTutorBackToTitle()
;@ path: system/debug/commandtutor
;@ After the fade out: switches to game mode 0, the opening, from its start.
CmdTutorBackToTitle::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wGameMode = 0
	ld a, $00
	ld [wGameMode], a
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> wOpeningScene = 0
	ld a, $00
	ld [wOpeningScene], a
;> wOpeningLogo = 0
	ld a, $00
	ld [wOpeningLogo], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret

;@ def CmdTutorTargetMenu()
;@ path: system/debug/commandtutor
;@ State 5, ALL or EACH (wListPage 0 ALL, 1 EACH: whether a strategy goes to the whole party or to
;@ each monster): Up / Down switch, A marks the entry and goes to state 7 (its text), B returns to
;@ the command menu. Input pauses 8 frames after each press.
;@ test: skip calls far routines
CmdTutorTargetMenu::
;> if wLinkRefused:                             # input pause after a press
	ld a, [wLinkRefused]
	or a
	jr z, .input

;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     if wLinkRefused < 8:
;>         return
	ld a, [wLinkRefused]
	cp $08
	ret c

;>     wLinkRefused = 0
	xor a
	ld [wLinkRefused], a

.input
;> CmdTutorBlinkCursor()
	call CmdTutorBlinkCursor
;> if wSGBJoypads[1] & 0x01:                     # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wLinkPartnerChoice = 0; wListLastRows = 1
;>@a2     wLinkRefused += 1
;>@a3     wListPage |= 0x80
;>@a4     wBattleListCount = 1; wCommandStep = 0
;>@a5     CmdTutorDrawMenu()
;>@a6     wSceneObjects[0] = 7
;> elif wSGBJoypads[0] & 0xC0:                   # Up or Down
	ld a, [wSGBJoypads]
	and $c0
	jr nz, .upDown

;>@v1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@v2     wLinkRefused += 1
;>@v3     wListPage ^= 0x01
;>@v4     wBattleListCount = 1; wCommandStep = 0
;>@v5     CmdTutorDrawMenu()
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, .b

	ret


.a
;=@a1
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
;=@a2
	ld hl, wLinkRefused
	inc [hl]
;=@a3
	ld a, [wListPage]
	set 7, a
	ld [wListPage], a
;=@a4
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@a5
	call CmdTutorDrawMenu
;=@a6
	ld a, $07
	ld [wSceneObjects], a
	ret


.upDown
;=@v1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@v2
	ld hl, wLinkRefused
	inc [hl]
;=@v3
	ld a, [wListPage]
	xor $01
	ld [wListPage], a
;=@v4
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@v5
	call CmdTutorDrawMenu
	ret


.b
;>     wMenuChoice &= ~0x80
	ld a, [wMenuChoice]
	res 7, a
	ld [wMenuChoice], a
;>     wLinkPartnerChoice = 0; wListLastRows = 0
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     wBattleListCount = 0; wCommandSubStep = 0
	xor a
	ld [wBattleListCount], a
	xor a
	ld [wCommandSubStep], a
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;>     wSceneObjects[0] = 0; wSceneObjects[1] = 0
	xor a
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret

;@ def CmdTutorOrderMenu()
;@ path: system/debug/commandtutor
;@ State 6, the order menu of the COMMAND strategy (wListCursor2 0 ATK, 1 the skills, 2 the
;@ defense): Up / Down move with wrap around, A marks the entry and goes to state 8 (its text), B
;@ returns to the strategy menu. Input pauses 8 frames after each press.
;@ test: skip calls far routines
CmdTutorOrderMenu::
;> if wLinkRefused:                             # input pause after a press
	ld a, [wLinkRefused]
	or a
	jr z, .input

;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     if wLinkRefused < 8:
;>         return
	ld a, [wLinkRefused]
	cp $08
	ret c

;>     wLinkRefused = 0
	xor a
	ld [wLinkRefused], a

.input
;> CmdTutorBlinkCursor()
	call CmdTutorBlinkCursor
;> if wSGBJoypads[1] & 0x01:                     # A
	ld a, [wSGBJoypads + 1]
	and $01
	jr nz, .a

;>@a1     wLinkPartnerChoice = 0; wListLastRows = 1
;>@a2     wLinkRefused += 1
;>@a3     wListCursor2 |= 0x80
;>@a4     wBattleListCount = 1; wCommandStep = 0
;>@a5     CmdTutorDrawMenu()
;>@a6     wSceneObjects[0] = 8
;> elif wSGBJoypads[0] & 0x40:                   # Up
	ld a, [wSGBJoypads]
	and $40
	jr nz, .up

;>@u1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@u2     wLinkRefused += 1
;>@u3     wListCursor2 = (wListCursor2 or 3) - 1
;>@u4     wBattleListCount = 1; wCommandStep = 0
;>@u5     CmdTutorDrawMenu()
;> elif wSGBJoypads[0] & 0x80:                   # Down
	ld a, [wSGBJoypads]
	and $80
	jr nz, .down

;>@d1     wLinkPartnerChoice = 0; wListLastRows = 0
;>@d2     wLinkRefused += 1
;>@d3     wListCursor2 = (wListCursor2 + 1) % 3
;>@d4     wBattleListCount = 1; wCommandStep = 0
;>@d5     CmdTutorDrawMenu()
;> elif wSGBJoypads[1] & 0x02:                   # B
	ld a, [wSGBJoypads + 1]
	and $02
	jr nz, .b

	ret


.a
;=@a1
	xor a
	ld [wLinkPartnerChoice], a
	ld a, $01
	ld [wListLastRows], a
;=@a2
	ld hl, wLinkRefused
	inc [hl]
;=@a3
	ld a, [wListCursor2]
	set 7, a
	ld [wListCursor2], a
;=@a4
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@a5
	call CmdTutorDrawMenu
;=@a6
	ld a, $08
	ld [wSceneObjects], a
	ret


.up
;=@u1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@u2
	ld hl, wLinkRefused
	inc [hl]
;=@u3
	ld a, [wListCursor2]
	or a
	jr z, .wrapUp

	dec a
	jr .storeUp


.wrapUp
;=@u3
	ld a, $02

.storeUp
;=@u3
	ld [wListCursor2], a
;=@u4
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@u5
	call CmdTutorDrawMenu
	ret


.down
;=@d1
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;=@d2
	ld hl, wLinkRefused
	inc [hl]
;=@d3
	ld a, [wListCursor2]
	inc a
	cp $03
	jr c, .storeDown

	xor a

.storeDown
;=@d3
	ld [wListCursor2], a
;=@d4
	ld a, $01
	ld [wBattleListCount], a
	xor a
	ld [wCommandStep], a
;=@d5
	call CmdTutorDrawMenu
	ret


.b
;>     wLinkPartnerChoice = 0; wListLastRows = 0   # back to the strategy menu
	xor a
	ld [wLinkPartnerChoice], a
	xor a
	ld [wListLastRows], a
;>     wLinkRefused += 1
	ld hl, wLinkRefused
	inc [hl]
;>     wBattleListCount = 0; wCommandSubStep = 2
	xor a
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     CmdTutorDrawMenu()
	call CmdTutorDrawMenu
;>     wSceneObjects[0] = 2; wSceneObjects[1] = 0
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
	ret
;@ def CmdTutorExplainTarget()
;@ path: system/debug/commandtutor
;@ State 7: explains ALL or EACH in steps wSceneObjects[1] (CmdTutorExplainTargetSteps).
;@ test: skip jumps through a table to the step routines
CmdTutorExplainTarget::
;> CmdTutorExplainTargetSteps[wSceneObjects[1]]()
	ld a, [wSceneObjects + 1]
	rst $00

;@ path: system/debug/commandtutor
;@ Steps of state 7: show only the message box, start the text, continue when it is done.
CmdTutorExplainTargetSteps::
	dw CmdTutorClearMenu
	dw CmdTutorStartTargetText
	dw CmdTutorAfterTargetText

;@ def CmdTutorStartTargetText()
;@ path: system/debug/commandtutor
;@ Starts text 2/(9 + (wListPage & 3)), the explanation of ALL or EACH.
;@ test: skip starts the text printer
CmdTutorStartTargetText::
;> wTextIndex = (wListPage & 3) + 9
	ld a, [wListPage]
	and $03
	add $09
	ld [wTextIndex], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret

;@ def CmdTutorAfterTargetText()
;@ path: system/debug/commandtutor
;@ Once the text is done, goes on to the strategy menu (state 2).
;@ test: skip calls far routines
CmdTutorAfterTargetText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wSceneObjects[0] = 2; wSceneObjects[1] = 0
	ld a, $02
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
;> wBattleListCount = 0; wCommandSubStep = 2
	ld [wBattleListCount], a
	ld a, $02
	ld [wCommandSubStep], a
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> CmdTutorDrawMenu()
	call CmdTutorDrawMenu
	ret

;@ def CmdTutorExplainOrder()
;@ path: system/debug/commandtutor
;@ State 8: explains the chosen order in steps wSceneObjects[1] (CmdTutorExplainOrderSteps).
;@ test: skip jumps through a table to the step routines
CmdTutorExplainOrder::
;> CmdTutorExplainOrderSteps[wSceneObjects[1]]()
	ld a, [wSceneObjects + 1]
	rst $00

;@ path: system/debug/commandtutor
;@ Steps of state 8: show only the message box, start the text, continue when it is done.
CmdTutorExplainOrderSteps::
	dw CmdTutorClearMenu
	dw CmdTutorStartOrderText
	dw CmdTutorAfterOrderText

;@ def CmdTutorStartOrderText()
;@ path: system/debug/commandtutor
;@ Starts text 2/($0B + (wListCursor2 & 3)), the explanation of the chosen order.
;@ test: skip starts the text printer
CmdTutorStartOrderText::
;> wTextIndex = (wListCursor2 & 3) + 0x0B
	ld a, [wListCursor2]
	and $03
	add $0b
	ld [wTextIndex], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> StartText_59()
	call StartText_59
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
	ret
;@ def CmdTutorAfterOrderText()
;@ path: system/debug/commandtutor
;@ Once the text is done, goes back to the order menu (state 6).
;@ test: skip calls far routines
CmdTutorAfterOrderText::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wListCursor2 &= ~0x80
	ld a, [wListCursor2]
	res 7, a
	ld [wListCursor2], a
;> wSceneObjects[0] = 6; wSceneObjects[1] = 0
	ld a, $06
	ld [wSceneObjects], a
	xor a
	ld [wSceneObjects + 1], a
;> wBattleListCount = 0; wCommandSubStep = 5
	ld [wBattleListCount], a
	ld a, $05
	ld [wCommandSubStep], a
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> CmdTutorDrawMenu()
	call CmdTutorDrawMenu
	ret

;@ def CmdTutorDrawMenu()
;@ path: system/debug/commandtutor
;@ Draws menu wCommandSubStep of the command tutorial when asked to (wCommandStep 0): 0 the
;@ command menu, 1 just the message box, 2 the strategies, 3 yes / no, 4 ALL / EACH, 5 the orders.
;@ wBattleListCount 0 redraws the whole screen first, otherwise only the menu box is drawn again.
;@ test: skip jumps through a table to the menu routines
CmdTutorDrawMenu::
;> if wCommandStep:                            # already drawn
;>     return
	ld a, [wCommandStep]
	or a
	ret nz

;> CmdTutorMenus[wCommandSubStep]()
	ld a, [wCommandSubStep]
	rst $00

;@ path: system/debug/commandtutor
;@ Drawing routines of the command tutorial's menus (wCommandSubStep).
CmdTutorMenus::
	dw CmdTutorDrawMain
	dw CmdTutorDrawMessageBox
	dw CmdTutorDrawStrategy
	dw CmdTutorDrawYesNo
	dw CmdTutorDrawTarget
	dw CmdTutorDrawOrder

;@ def CmdTutorDrawMain()
;@ path: system/debug/commandtutor
;@ Menu 0, the command box: the whole screen first when wBattleListCount is 0.
;@ test: skip jumps through a table
CmdTutorDrawMain::
;> [CmdTutorDrawMainFull, CmdTutorDrawMainBox, CmdTutorDrawMainBox][wBattleListCount]()
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawMainFull
	dw CmdTutorDrawMainBox
	dw CmdTutorDrawMainBox

;@ def CmdTutorDrawMainFull()
;@ path: system/debug/commandtutor
;@ Redraws the whole screen, then the command box (falls into CmdTutorDrawMainBox).
;@ test: skip writes VRAM
CmdTutorDrawMainFull::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> CmdTutorDrawScreen()
	call CmdTutorDrawScreen

;@ def CmdTutorDrawMainBox()
;@ path: system/debug/commandtutor
;@ Draws the command box (FIGHT / PLAN / ITEM / RUN) with the cursor on wMenuChoice, then
;@ finishes like every menu (CmdTutorDrawFinish).
;@ test: skip writes VRAM
CmdTutorDrawMainBox::
;> DrawLayout_59(TutorMainMenuLayout, wTilemapBuffer)
	ld de, TutorMainMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;>@p p = wTilemapBuffer + ReadTableWord_59(wMenuChoice & 0x0F, TutorMainCursorSpots)
	ld a, [wMenuChoice]
	and $0f
	ld hl, TutorMainCursorSpots
	call ReadTableWord_59
;=@p
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
;> wConfirmChoice2 = lo(p); wMenuChoice3 = hi(p)   # the cursor's place, for the blinking
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
;> if wMenuChoice & 0x80:
	ld a, [wMenuChoice]
	bit 7, a
	jr z, .arrow

;>     mem[p] = 0xE9                            # chosen
;>     return CmdTutorDrawFinish()
	ld [hl], $e9
	jp CmdTutorDrawFinish


.arrow
;> mem[p] = 0xE8
	ld [hl], $e8
;> return CmdTutorDrawFinish()
	jp CmdTutorDrawFinish
;@ def CmdTutorDrawMessageBox()
;@ path: system/debug/commandtutor
;@ Menu 1: the whole screen with just the message box (while a text is shown).
;@ test: skip writes VRAM
CmdTutorDrawMessageBox::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> CmdTutorDrawScreen()
	call CmdTutorDrawScreen
;> DrawLayout_59(TutorMessageBoxLayout, wTilemapBuffer)
	ld de, TutorMessageBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;> return CmdTutorDrawFinish()
	jp CmdTutorDrawFinish

;@ def CmdTutorDrawStrategy()
;@ path: system/debug/commandtutor
;@ Menu 2, the strategies: the whole screen first when wBattleListCount is 0.
;@ test: skip jumps through a table
CmdTutorDrawStrategy::
;> [CmdTutorDrawStrategyFull, CmdTutorDrawStrategyBox, CmdTutorDrawStrategyBox][wBattleListCount]()
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawStrategyFull
	dw CmdTutorDrawStrategyBox
	dw CmdTutorDrawStrategyBox

;@ def CmdTutorDrawStrategyFull()
;@ path: system/debug/commandtutor
;@ Redraws the whole screen, then the strategy box.
;@ test: skip writes VRAM
CmdTutorDrawStrategyFull::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> CmdTutorDrawScreen()
	call CmdTutorDrawScreen

;@ def CmdTutorDrawStrategyBox()
;@ path: system/debug/commandtutor
;@ Draws the strategy box (CHARGE!, MIXED, CAUTIOUS, COMMAND) with the cursor on wMenuChoice2.
;@ test: skip writes VRAM
CmdTutorDrawStrategyBox::
;> DrawLayout_59(TutorStrategyMenuLayout, wTilemapBuffer)
	ld de, TutorStrategyMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;>@p p = wTilemapBuffer + ReadTableWord_59(wMenuChoice2 & 0x0F, TutorListCursorSpots)
	ld a, [wMenuChoice2]
	and $0f
	ld hl, TutorListCursorSpots
	call ReadTableWord_59
;=@p
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
;> wConfirmChoice2 = lo(p); wMenuChoice3 = hi(p)
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
;> if wMenuChoice2 & 0x80:
	ld a, [wMenuChoice2]
	bit 7, a
	jr z, .arrow

;>     mem[p] = 0xE9
;>     return CmdTutorDrawFinish()
	ld [hl], $e9
	jp CmdTutorDrawFinish


.arrow
;> mem[p] = 0xE8
	ld [hl], $e8
;> return CmdTutorDrawFinish()
	jp CmdTutorDrawFinish

;@ def CmdTutorDrawYesNo()
;@ path: system/debug/commandtutor
;@ Menu 3, yes / no: the whole screen and the message box first when wBattleListCount is 0.
;@ test: skip jumps through a table
CmdTutorDrawYesNo::
;> [CmdTutorDrawYesNoFull, CmdTutorDrawYesNoBox][wBattleListCount]()
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawYesNoFull
	dw CmdTutorDrawYesNoBox

;@ def CmdTutorDrawYesNoFull()
;@ path: system/debug/commandtutor
;@ Redraws the whole screen with the message box, then the yes / no box.
;@ test: skip writes VRAM
CmdTutorDrawYesNoFull::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> CmdTutorDrawScreen()
	call CmdTutorDrawScreen
;> DrawLayout_59(TutorMessageBoxLayout, wTilemapBuffer)
	ld de, TutorMessageBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59

;@ def CmdTutorDrawYesNoBox()
;@ path: system/debug/commandtutor
;@ Draws the yes / no box with the cursor on wListCursor; after a full redraw the text box is set
;@ up again, otherwise (the "Enough?" text is still printing) only the buffer is copied.
;@ test: skip writes VRAM
CmdTutorDrawYesNoBox::
;> DrawLayout_59(TutorYesNoLayout, wTilemapBuffer)
	ld de, TutorYesNoLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;>@p p = wTilemapBuffer + ReadTableWord_59(wListCursor & 0x0F, TutorYesNoCursorSpots)
	ld a, [wListCursor]
	and $0f
	ld hl, TutorYesNoCursorSpots
	call ReadTableWord_59
;=@p
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
;> wConfirmChoice2 = lo(p); wMenuChoice3 = hi(p)
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
;> mem[p] = 0xE9 if wListCursor & 0x80 else 0xE8
	ld a, [wListCursor]
	bit 7, a
	jr z, .arrow

	ld [hl], $e9
	jr .placed


.arrow
	ld [hl], $e8

.placed
;> if wBattleListCount:
;>     return CmdTutorDrawCopy()
	ld a, [wBattleListCount]
	or a
	jp nz, CmdTutorDrawCopy

;> return CmdTutorDrawFinish()
	jp CmdTutorDrawFinish

;@ def CmdTutorDrawTarget()
;@ path: system/debug/commandtutor
;@ Menu 4, ALL / EACH: the whole screen first when wBattleListCount is 0.
;@ test: skip jumps through a table
CmdTutorDrawTarget::
;> [CmdTutorDrawTargetFull, CmdTutorDrawTargetBox][wBattleListCount]()
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawTargetFull
	dw CmdTutorDrawTargetBox

;@ def CmdTutorDrawTargetFull()
;@ path: system/debug/commandtutor
;@ Redraws the whole screen, then the ALL / EACH box.
;@ test: skip writes VRAM
CmdTutorDrawTargetFull::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> CmdTutorDrawScreen()
	call CmdTutorDrawScreen

;@ def CmdTutorDrawTargetBox()
;@ path: system/debug/commandtutor
;@ Draws the ALL / EACH box with the cursor on wListPage (rows 3 and 4 of TutorListCursorSpots).
;@ test: skip writes VRAM
CmdTutorDrawTargetBox::
;> DrawLayout_59(TutorTargetMenuLayout, wTilemapBuffer)
	ld de, TutorTargetMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;>@p p = wTilemapBuffer + ReadTableWord_59((wListPage & 0x0F) + 2, TutorListCursorSpots)
	ld a, [wListPage]
	and $0f
	add $02
	ld hl, TutorListCursorSpots
	call ReadTableWord_59
;=@p
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
;> wConfirmChoice2 = lo(p); wMenuChoice3 = hi(p)
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
;> if wListPage & 0x80:
	ld a, [wListPage]
	bit 7, a
	jr z, .arrow

;>     mem[p] = 0xE9
;>     return CmdTutorDrawFinish()
	ld [hl], $e9
	jr CmdTutorDrawFinish


.arrow
;> mem[p] = 0xE8
	ld [hl], $e8
;> return CmdTutorDrawFinish()
	jr CmdTutorDrawFinish

;@ def CmdTutorDrawOrder()
;@ path: system/debug/commandtutor
;@ Menu 5, the orders: the whole screen first when wBattleListCount is 0.
;@ test: skip jumps through a table
CmdTutorDrawOrder::
;> [CmdTutorDrawOrderFull, CmdTutorDrawOrderBox][wBattleListCount]()
	ld a, [wBattleListCount]
	rst $00
	dw CmdTutorDrawOrderFull
	dw CmdTutorDrawOrderBox

;@ def CmdTutorDrawOrderFull()
;@ path: system/debug/commandtutor
;@ Redraws the whole screen, then the order box.
;@ test: skip writes VRAM
CmdTutorDrawOrderFull::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> CmdTutorDrawScreen()
	call CmdTutorDrawScreen

;@ def CmdTutorDrawOrderBox()
;@ path: system/debug/commandtutor
;@ Draws the order box (ATK, skills, defense) with the cursor on wListCursor2 (rows 2-4 of
;@ TutorListCursorSpots). Then, as every menu does (CmdTutorDrawFinish), sets the message box up
;@ as the text box again, copies wTilemapBuffer to the screen (CmdTutorDrawCopy) and marks the
;@ menu as drawn (wCommandStep 1).
;@ test: skip writes VRAM
CmdTutorDrawOrderBox::
;> DrawLayout_59(TutorOrderMenuLayout, wTilemapBuffer)
	ld de, TutorOrderMenuLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;>@p p = wTilemapBuffer + ReadTableWord_59((wListCursor2 & 0x0F) + 1, TutorListCursorSpots)
	ld a, [wListCursor2]
	and $0f
	add $01
	ld hl, TutorListCursorSpots
	call ReadTableWord_59
;=@p
	ld a, l
	add LOW(wTilemapBuffer)
	ld l, a
	ld a, h
	adc HIGH(wTilemapBuffer)
	ld h, a
;> wConfirmChoice2 = lo(p); wMenuChoice3 = hi(p)
	ld a, l
	ld [wConfirmChoice2], a
	ld a, h
	ld [wMenuChoice3], a
;> mem[p] = 0xE9 if wListCursor2 & 0x80 else 0xE8
	ld a, [wListCursor2]
	bit 7, a
	jr z, .arrow

	ld [hl], $e9
	jr CmdTutorDrawFinish


.arrow
	ld [hl], $e8

CmdTutorDrawFinish:
;> SetUpTextBox(0x8B00, lines=2, line_length=18)   # the message box
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox

CmdTutorDrawCopy:
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> wCommandStep = 1                             # drawn
	ld a, $01
	ld [wCommandStep], a
	ret
;@ def CmdTutorDrawScreen()
;@ path: system/debug/commandtutor
;@ Draws the base of the command tutorial's screen into wTilemapBuffer: the party panel for the
;@ number of monsters (TutorPartyLayouts) with their HP and MP, blank status icons, and the enemy
;@ picture.
;@ test: skip writes VRAM
CmdTutorDrawScreen::
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
	jr z, .noParty

;>@l     DrawLayout_59(mem16[TutorPartyLayouts + 2 * wPartyCount], wTilemapBuffer)
	ld hl, TutorPartyLayouts
	ld a, [wPartyCount]
	call ReadTableWord_59
	ld d, h
	ld e, l
	ld hl, wTilemapBuffer
;=@l
	call DrawLayout_59
;>     CmdTutorDrawHPMP()
	call CmdTutorDrawHPMP
;>     CmdTutorClearIcons()
	call CmdTutorClearIcons

.noParty
;> DrawLayout_59(TutorEnemyPicLowLayout, wTilemapBuffer)
	ld de, TutorEnemyPicLowLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ret

;@ def CmdTutorPrintLabels()
;@ path: system/debug/commandtutor
;@ Prints five label texts of text group 3 of bank $4C (entries 0, 1, 3, 4, 5) into their tiles
;@ ($96C0, $97C0, $8850, $8990, $8800). In this version every entry of that group holds the same
;@ item message, so these labels do not come out as intended.
;@ test: skip runs the text printer
CmdTutorPrintLabels::
;>@t1 for tiles, size, i in ((0x96C0, 0x0401, 0), (0x97C0, 0x0401, 1), (0x8850, 0x1401, 3), (0x8990, 0x0501, 4), (0x8800, 0x0501, 5)):
;>@t2     wTextTiles = tiles
	ld hl, $96c0
	ld de, $0401
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;>@t3     wTextBoxLines = size & 0xFF; wTextBoxLineLength = size >> 8
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;>@t4     wTextIndex = i; wTextGroup = 3
	ld a, $00
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
;>@t5     PrintText_4C()
	ld hl, far_PrintText_4C
	rst $10
;=@t2
	ld hl, $97c0
	ld de, $0401
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@t3
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;=@t4
	ld a, $01
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
;=@t5
	ld hl, far_PrintText_4C
	rst $10
;=@t2
	ld hl, $8850
	ld de, $1401
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@t3
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;=@t4
	ld a, $03
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
;=@t5
	ld hl, far_PrintText_4C
	rst $10
;=@t2
	ld hl, $8990
	ld de, $0501
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@t3
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;=@t4
	ld a, $04
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
;=@t5
	ld hl, far_PrintText_4C
	rst $10
;=@t2
	ld hl, $8800
	ld de, $0501
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;=@t3
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;=@t4
	ld a, $05
	ld [wTextIndex], a
	ld a, $03
	ld [wTextGroup], a
;=@t5
	ld hl, far_PrintText_4C
	rst $10
	ret

;@ def CmdTutorPrintNames()
;@ path: system/debug/commandtutor
;@ Prints the names of the party's monsters into 4-letter boxes at $9700, $9740 and $9780 (one
;@ per party position, wSceneObjects[19] counts them), then sets the message box up as the text
;@ box again.
;@ test: skip runs the text printer
CmdTutorPrintNames::
;> if wPartyCount == 0:
;>     return
	ld a, [wPartyCount]
	or a
	ret z

;> wSceneObjects[19] = 0
	xor a
	ld [wSceneObjects + 19], a
;> wTextTiles = 0x9700
	ld hl, $9700
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1; wTextBoxLineLength = 4
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a

.loop
;> while True:
;>@m     CmdTutorPrintName(wParty[wSceneObjects[19]])
	ld a, [wSceneObjects + 19]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	call CmdTutorPrintName
;>     wSceneObjects[19] += 1
	ld hl, wSceneObjects + 19
	inc [hl]
;>@w     wTextTiles += 0x40                       # the next box
	ld a, [wTextTiles]
	ld l, a
	ld a, [wTextTiles + 1]
	ld h, a
	ld a, l
	add $40
;=@w
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [wTextTiles], a
;=@w
	ld a, h
	ld [wTextTiles + 1], a
;>     if wSceneObjects[19] == wPartyCount:
;>         break
	ld a, [wSceneObjects + 19]
	ld d, a
	ld a, [wPartyCount]
	cp d
	jr nz, .loop

;> wTextTiles = 0x8B00
	ld hl, $8b00
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 2; wTextBoxLineLength = 18
	ld de, $1202
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ret

;@ def CmdTutorDrawHPMP()
;@ path: system/debug/commandtutor
;@ Writes the HP and MP of each party monster into the party panel (CmdTutorDrawSlotHPMP).
;@ test: skip reads monster records through computed addresses
CmdTutorDrawHPMP::
;> wSceneObjects[19] = 0
	xor a
	ld [wSceneObjects + 19], a

.loop
;> while True:
;>@m     CmdTutorDrawSlotHPMP(wParty[wSceneObjects[19]])
	ld a, [wSceneObjects + 19]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	call CmdTutorDrawSlotHPMP
;>     wSceneObjects[19] += 1
	ld hl, wSceneObjects + 19
	inc [hl]
;>     if wSceneObjects[19] == wPartyCount:
;>         break
	ld a, [wSceneObjects + 19]
	ld d, a
	ld a, [wPartyCount]
	cp d
	jr nz, .loop

	ret

;@ def CmdTutorDrawSlotHPMP(mon: a)
;@ path: system/debug/commandtutor
;@ Writes the HP and MP of monster slot `mon` (party records of $95 bytes) as numbers into the
;@ panel spots of party position wSceneObjects[19] (TutorHPDigitSpots, TutorMPDigitSpots).
;@ test: skip reads monster records through computed addresses
CmdTutorDrawSlotHPMP::
;> offset = Multiply_59(mon, 0x95)              # the monster's record
	ld c, $95
	ld b, $00
	call Multiply_59
	push bc
;> SplitDecimal_59(ReadWordAt_59(wMonHP, offset))
	ld hl, wMonHP
	call ReadWordAt_59
	call SplitDecimal_59
;> CmdTutorPutNumber(ReadTableWord_59(wSceneObjects[19], TutorHPDigitSpots))
	ld a, [wSceneObjects + 19]
	ld hl, TutorHPDigitSpots
	call ReadTableWord_59
	call CmdTutorPutNumber
;> SplitDecimal_59(ReadWordAt_59(wMonMP, offset))
	pop bc
	ld hl, wMonMP
	call ReadWordAt_59
	call SplitDecimal_59
;> CmdTutorPutNumber(ReadTableWord_59(wSceneObjects[19], TutorMPDigitSpots))
	ld a, [wSceneObjects + 19]
	ld hl, TutorMPDigitSpots
	call ReadTableWord_59
	call CmdTutorPutNumber
	ret

;@ def CmdTutorPutNumber(dest: hl)
;@ path: system/debug/commandtutor
;@ Writes the 3 digits in wSceneObjects[16-18] as tiles $F0-$F9 at `dest`, leaving leading zeros
;@ out (their places keep what was there).
;@ test: dest = rand(0xC500, 0xC700)
CmdTutorPutNumber::
;> if wSceneObjects[16]:
;>     mem[dest] = wSceneObjects[16] + 0xF0
	ld a, [wSceneObjects + 16]
	ld e, a
	or a
	jr z, .tens

	add $f0
	ld [hl], a

.tens
;> if wSceneObjects[17] or wSceneObjects[16]:
	inc hl
	ld a, [wSceneObjects + 17]
	or e
	jr z, .ones

;>     mem[dest + 1] = wSceneObjects[17] + 0xF0
	ld a, [wSceneObjects + 17]
	add $f0
	ld [hl], a

.ones
;> mem[dest + 2] = wSceneObjects[18] + 0xF0
	inc hl
	ld a, [wSceneObjects + 18]
	add $f0
	ld [hl], a
	ret

;@ def CmdTutorPrintName(mon: a)
;@ path: system/debug/commandtutor
;@ Prints the name of monster slot `mon` into the current text box (system text 2/0, which is
;@ just its first word, wTextArg0).
;@ test: skip runs the text printer
CmdTutorPrintName::
;> offset = Multiply_59(mon, 0x95)
	ld c, $95
	ld b, $00
	call Multiply_59
;> CopyName(wMonName + offset, wTextArg0)
	ld hl, wMonName
	add hl, bc
	ld d, h
	ld e, l
	ld hl, wTextArg0
	call CopyName
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
	ret
;@ def CmdTutorClearIcons()
;@ path: system/debug/commandtutor
;@ Clears the status icon tiles of the party panel (CmdTutorClearIconTiles for position 0).
;@ test: skip runs the text printer
CmdTutorClearIcons::
;> wSceneObjects[19] = 0
	xor a
	ld [wSceneObjects + 19], a
;> CmdTutorClearIconTiles()
	call CmdTutorClearIconTiles
	ret

;@ def CmdTutorClearIconTiles()
;@ path: system/debug/commandtutor
;@ Prints an empty name (system text 2/0 with wTextArg0 empty) into a 3-tile box from the status
;@ icon tile of party position wSceneObjects[19] (TutorIconTiles): from position 0 that blanks
;@ the three icons.
;@ test: skip runs the text printer
CmdTutorClearIconTiles::
;> wTextArg0[0] = 0xF0                          # an empty word
	ld hl, wTextArg0
	ld a, $f0
	ld [hl], a
;>@x wTextTiles = mem16[TutorIconTiles + 2 * wSceneObjects[19]]
	ld a, [wSceneObjects + 19]
	ld hl, TutorIconTiles
	call ReadTableWord_59
	ld a, l
	ld [wTextTiles], a
	ld a, h
;=@x
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1; wTextBoxLineLength = 3
	ld de, $0301
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2
	ld a, $02
	ld [wTextGroup], a
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_41()
	ld hl, far_PrintText_41
	rst $10
	ret

;@ def CmdTutorBlinkCursor()
;@ path: system/debug/commandtutor
;@ Blinks the menu cursor (its address in wConfirmChoice2 / wMenuChoice3), timed by
;@ wLinkPartnerChoice: gone after 10 frames, back after 20. While wListLastRows is set (an entry
;@ was chosen) the cursor stays.
;@ test: skip calls a far routine
CmdTutorBlinkCursor::
;> if wListLastRows:
;>     return
	ld a, [wListLastRows]
	or a
	ret nz

;> wLinkPartnerChoice += 1
	ld hl, wLinkPartnerChoice
	inc [hl]
;> if wLinkPartnerChoice == 10:
	ld a, [wLinkPartnerChoice]
	cp $0a
	jr z, .hide

;>@h1     mem[wConfirmChoice2 | wMenuChoice3 << 8] = 0xE0
;>@h2     CopyTilemapBufferToScreen_50()
;> elif wLinkPartnerChoice == 20:
	cp $14
	jr z, .show

	ret


.hide
;=@h1
	ld a, [wConfirmChoice2]
	ld l, a
	ld a, [wMenuChoice3]
	ld h, a
	ld [hl], $e0
;=@h2
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


.show
;>     mem[wConfirmChoice2 | wMenuChoice3 << 8] = 0xE8
	ld a, [wConfirmChoice2]
	ld l, a
	ld a, [wMenuChoice3]
	ld h, a
	ld [hl], $e8
;>     CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;>     wLinkPartnerChoice = 0
	xor a
	ld [wLinkPartnerChoice], a
	ret
;@ path: system/debug/commandtutor
;@ wTilemapBuffer addresses of the HP number of party positions 0-2 in the panel.
TutorHPDigitSpots::
	dw $c562
	dw $c568
	dw $c56e

;@ path: system/debug/commandtutor
;@ wTilemapBuffer addresses of the MP number of party positions 0-2.
TutorMPDigitSpots::
	dw $c582
	dw $c588
	dw $c58e

;@ path: unused/data
;@ The name boxes' tile addresses ($9700, $9740, $9780) of the three party positions; nothing
;@ reads this table (CmdTutorPrintNames steps through them itself).
TutorNameTileSpots::
	dw $9700
	dw $9740
	dw $9780

;@ path: system/debug/commandtutor
;@ Party panel layout by the number of monsters (entry 0 is never used).
TutorPartyLayouts::
	dw TutorParty1Layout
	dw TutorParty1Layout
	dw TutorParty2Layout
	dw TutorParty3Layout

;@ path: system/debug/commandtutor
;@ Tile addresses of the status icons of party positions 0-2 (tiles $DA-$DC).
TutorIconTiles::
	dw $8da0
	dw $8db0
	dw $8dc0
;@ path: system/debug/commandtutor
;@ wTilemapBuffer offsets of the command menu cursor: FIGHT (row 14), PLAN (row 16) in column 1,
;@ ITEM and RUN in column 7.
TutorMainCursorSpots::
	dw $01c1
	dw $0201
	dw $01c7
	dw $0207

;@ path: system/debug/commandtutor
;@ wTilemapBuffer offsets of the cursor in the list menus: rows 10, 12, 14 and 16 of column 1
;@ (the strategy box uses all four, the order box rows 2-4, ALL / EACH rows 3-4).
TutorListCursorSpots::
	dw $0141
	dw $0181
	dw $01c1
	dw $0201
;@ path: system/debug/commandtutor
;@ wTilemapBuffer offsets of the yes / no cursor (rows 9 and 11, column 15).
TutorYesNoCursorSpots::
	dw $012f
	dw $016f

;@ def StartText_59()
;@ path: text/dialogue
;@ Starts printing text wTextGroup / wTextIndex of bank $59 (TextGroups_59).
;@ test: skip runs the text code with this bank switched in
StartText_59::
;> StartText(TextGroups_59)
	ld de, TextGroups_59
	call StartText
	ret

;@ def CopyText_59()
;@ path: text/dialogue
;@ Copies text wTextGroup / wTextIndex of bank $59 to wTextCopyDest.
;@ test: skip runs the text code with this bank switched in
CopyText_59::
;> CopyTextString(TextGroups_59)
	ld de, TextGroups_59
	call CopyTextString
	ret

;@ def PrintText_59()
;@ path: text/dialogue
;@ Prints text wTextGroup / wTextIndex of bank $59 at once and waits until it is done.
;@ test: skip runs the text printer
PrintText_59::
;> StartText_59()
	call StartText_59
;> RunTextToEnd()
	call RunTextToEnd
	ret

;@ path: text/dialogue
;@ The text groups of bank $59 (the table StartText_59 hands to StartText): 0 the battle screen
;@ tutorial, 1 its enemy name and greeting, 2 the command tutorial, 3 the sprite viewer's labels.
TextGroups_59::
	dw TextGroup_59_0
	dw TextGroup_59_1
	dw TextGroup_59_2
	dw TextGroup_59_3

;@ path: text/dialogue
;@ Text group 0 of bank $59, the battle screen tutorial (TutorExplain0-6): 0 "This is the Battle
;@ Screen", 1 select FIGHT to start the fight, 2 what FIGHT does, 3 PLAN, 4 ITEM, 5 RUN, 6 "That's
;@ all about battle". The text format is described at TextGroup_1A_0.
TextGroup_59_0::
	dw Texts_59 + $000
	dw Texts_59 + $021
	dw Texts_59 + $136
	dw Texts_59 + $1ea
	dw Texts_59 + $31f
	dw Texts_59 + $3c0
	dw Texts_59 + $40f

;@ path: text/dialogue
;@ Text group 1 of bank $59: 0 the tutorial enemy's name "Slio", 1 an empty text (clears the
;@ message box), 2 the greeting "Grandpa Sakamoto is here!".
TextGroup_59_1::
	dw Texts_59 + $450
	dw Texts_59 + $455
	dw Texts_59 + $457

;@ path: text/dialogue
;@ Text group 2 of bank $59, the command tutorial: 0-3 FIGHT, PLAN, ITEM, RUN; 4-7 the strategies
;@ CHARGE!, MIXED, CAUTIOUS and COMMAND; 8 "Enough?"; 9-10 ALL and EACH; 11-13 ATK, the skills and
;@ the defense.
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

;@ path: text/dialogue
;@ Text group 3 of bank $59: a single text, the sprite viewer's labels "Direction" / "No.".
TextGroup_59_3::
	dw Texts_59 + $865

;@ path: text/dialogue
;@ The texts of bank $59, one after the other, each ended by $F0 (format: see TextGroup_1A_0).
;@ The tutorial texts start with $9F $A3 ("*:"), the speaker mark.
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

;@ def SplitDecimal_59(n: hl)
;@ path: system/debug
;@ Splits `n` (0-999) into its decimal digits: hundreds in wSceneObjects[16], tens in
;@ wSceneObjects[17], ones in wSceneObjects[18].
;@ test: n = rand(0, 999)
SplitDecimal_59::
;>@z for i in (16, 17, 18): wSceneObjects[i] = 0
	xor a
	ld [wSceneObjects + 16], a
	ld [wSceneObjects + 17], a
	ld [wSceneObjects + 18], a

.hundreds
;> while True:                                  # counts one hundred too many
;>     wSceneObjects[16] += 1
	ld a, [wSceneObjects + 16]
	inc a
	ld [wSceneObjects + 16], a
;>     n = (n - 100) & 0xFFFF
	ld bc, -100
	add hl, bc
;>     if n & 0x8000:
;>         break
	ld a, h
	rlc a
	jr nc, .hundreds

;> n = (n + 100) & 0xFFFF
	ld bc, $0064
	add hl, bc
;> wSceneObjects[16] -= 1
	ld a, [wSceneObjects + 16]
	dec a
	ld [wSceneObjects + 16], a

.tens
;> while True:
;>     wSceneObjects[17] += 1
	ld a, [wSceneObjects + 17]
	inc a
	ld [wSceneObjects + 17], a
;>     n = (n - 10) & 0xFFFF
	ld bc, -10
	add hl, bc
;>     if n & 0x8000:
;>         break
	ld a, h
	rlc a
	jr nc, .tens

;> n = (n + 10) & 0xFFFF
	ld bc, $000a
	add hl, bc
;> wSceneObjects[17] -= 1
	ld a, [wSceneObjects + 17]
	dec a
	ld [wSceneObjects + 17], a
;> wSceneObjects[18] = n & 0xFF
	ld a, l
	ld [wSceneObjects + 18], a
	ret

;@ def ReadWordAt_59(table: hl, offset: bc) -> hl
;@ path: system/memory
;@ Returns the 16-bit word at `table` + `offset`.
ReadWordAt_59::
;> return mem16[(table + offset) & 0xFFFF]
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

;@ def ReadTableWord_59(index: a, table: hl) -> hl
;@ path: system/memory
;@ Returns entry `index` (0-127) of the table of 16-bit words at `table`.
;@ test: index = rand(0, 127)
ReadTableWord_59::
;>@p p = table + 2 * index
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
;> return mem16[p]
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

;@ def TutorPointFight()
;@ path: system/debug/battletutor
;@ Tutorial step: moves the cursor to FIGHT (wTilemapBuffer offset $121), clears the other three
;@ spots and restarts the blinking.
;@ test: skip calls a far routine
TutorPointFight::
;> wTilemapBuffer[0x121] = 0xE8
	ld hl, wTilemapBuffer + 289
	ld [hl], $e8
;> wSkillAmount = addr(wTilemapBuffer) + 0x121
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> wTilemapBuffer[0x161] = 0xE0
	ld hl, wTilemapBuffer + 353
	ld [hl], $e0
;> wTilemapBuffer[0x127] = 0xE0
	ld hl, wTilemapBuffer + 295
	ld [hl], $e0
;> wTilemapBuffer[0x167] = 0xE0
	ld hl, wTilemapBuffer + 359
	ld [hl], $e0
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
;> wSceneObjects[3] = 0
	xor a
	ld [wSceneObjects + 3], a
	ret

;@ def TutorPointPlan()
;@ path: system/debug/battletutor
;@ Tutorial step: moves the cursor to PLAN (offset $161).
;@ test: skip calls a far routine
TutorPointPlan::
;> wTilemapBuffer[0x121] = 0xE0
	ld hl, wTilemapBuffer + 289
	ld [hl], $e0
;> wTilemapBuffer[0x161] = 0xE8
	ld hl, wTilemapBuffer + 353
	ld [hl], $e8
;> wSkillAmount = addr(wTilemapBuffer) + 0x161
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> wTilemapBuffer[0x127] = 0xE0
	ld hl, wTilemapBuffer + 295
	ld [hl], $e0
;> wTilemapBuffer[0x167] = 0xE0
	ld hl, wTilemapBuffer + 359
	ld [hl], $e0
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
;> wSceneObjects[3] = 0
	xor a
	ld [wSceneObjects + 3], a
	ret

;@ def TutorPointItem()
;@ path: system/debug/battletutor
;@ Tutorial step: moves the cursor to ITEM (offset $127).
;@ test: skip calls a far routine
TutorPointItem::
;> wTilemapBuffer[0x121] = 0xE0
	ld hl, wTilemapBuffer + 289
	ld [hl], $e0
;> wTilemapBuffer[0x161] = 0xE0
	ld hl, wTilemapBuffer + 353
	ld [hl], $e0
;> wTilemapBuffer[0x127] = 0xE8
	ld hl, wTilemapBuffer + 295
	ld [hl], $e8
;> wSkillAmount = addr(wTilemapBuffer) + 0x127
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> wTilemapBuffer[0x167] = 0xE0
	ld hl, wTilemapBuffer + 359
	ld [hl], $e0
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
;> wSceneObjects[3] = 0
	xor a
	ld [wSceneObjects + 3], a
	ret

;@ def TutorPointRun()
;@ path: system/debug/battletutor
;@ Tutorial step: moves the cursor to RUN (offset $167).
;@ test: skip calls a far routine
TutorPointRun::
;> wTilemapBuffer[0x121] = 0xE0
	ld hl, wTilemapBuffer + 289
	ld [hl], $e0
;> wTilemapBuffer[0x161] = 0xE0
	ld hl, wTilemapBuffer + 353
	ld [hl], $e0
;> wTilemapBuffer[0x127] = 0xE0
	ld hl, wTilemapBuffer + 295
	ld [hl], $e0
;> wTilemapBuffer[0x167] = 0xE8
	ld hl, wTilemapBuffer + 359
	ld [hl], $e8
;> wSkillAmount = addr(wTilemapBuffer) + 0x167
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> wSceneObjects[1] += 1
	ld hl, wSceneObjects + 1
	inc [hl]
;> wSceneObjects[3] = 0
	xor a
	ld [wSceneObjects + 3], a
	ret
;@ def TutorBlinkCursor()
;@ path: system/debug/battletutor
;@ Blinks the tutorial's cursor (at the buffer address in wSkillAmount): it disappears after 10
;@ frames and comes back after 20, counted in wSceneObjects[3].
;@ test: skip calls a far routine
TutorBlinkCursor::
;> wSceneObjects[3] += 1
	ld hl, wSceneObjects + 3
	inc [hl]
;> if wSceneObjects[3] == 10:
	ld a, [wSceneObjects + 3]
	cp $0a
	jr z, .hide

;>@h1     mem[wSkillAmount] = 0xE0
;>@h2     CopyTilemapBufferToScreen_50()
;> elif wSceneObjects[3] == 20:
	cp $14
	jr z, .show

	ret


.hide
;=@h1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld [hl], $e0
;=@h2
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


.show
;>     mem[wSkillAmount] = 0xE8
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld [hl], $e8
;>     CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;>     wSceneObjects[3] = 0
	xor a
	ld [wSceneObjects + 3], a
	ret

;@ def DrawLayout_59(src: de, dest: hl)
;@ path: gfx/tilemap
;@ Draws a box layout into a BG map or into wTilemapBuffer (every tile goes through WriteVRAM, so
;@ it works with the screen on). Layout format: a u16 offset added to `dest`, then tile numbers
;@ row by row; $D8 goes on at the start of the next row (32 tiles further), $D9 ends it.
;@ test: skip writes through WriteVRAM, which waits for the LCD
DrawLayout_59::
;> offset = mem16[src]; src += 2
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
;> dest += offset
	add hl, bc

.row
;> while True:                                  # one row per pass
;>     row = dest
	push hl

.next
;>     while True:
;>         tile = mem[src]; src += 1
	ld a, [de]
	inc de
;>         if tile == 0xD8:                     # next row
;>             break
	cp $d8
	jr z, .newRow

;>         if tile == 0xD9:                     # end
;>@e             return
	cp $d9
	jr z, .end

;>         WriteVRAM(tile, dest)
	call WriteVRAM
;>         dest += 1
	inc hl
	jr .next


.newRow
;>@n     dest = row + 0x20
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@n
	ld h, a
	jr .row


.end
;=@e
	pop hl
	ret

;@ def TutorScrollInStep() -> zero
;@ path: system/debug/battletutor
;@ Scrolls the view one pixel (hScrollY + 1); returns zero set once Y has reached 0.
;@ test: skip writes the scroll registers
TutorScrollInStep::
;> mem[addr(hScrollY)] = (lo(hScrollY) + 1) & 0xFF      # the low byte
	ld hl, hScrollY
	inc [hl]
;> ApplyScroll()
	call ApplyScroll
;> return lo(hScrollY) == 0
	ldh a, [hScrollY]
	cp $00
	ret

;@ def TutorScrollOutStep() -> zero
;@ path: system/debug/battletutor
;@ Scrolls the view back one pixel (hScrollY - 1); returns zero set once Y has reached $D8.
;@ test: skip writes the scroll registers
TutorScrollOutStep::
;> mem[addr(hScrollY)] = (lo(hScrollY) - 1) & 0xFF      # the low byte
	ld hl, hScrollY
	dec [hl]
;> ApplyScroll()
	call ApplyScroll
;> return lo(hScrollY) == 0xD8
	ldh a, [hScrollY]
	cp $d8
	ret

;@ def LoadTutorEnemyPic()
;@ path: system/debug/battletutor
;@ Unpacks the battle picture of species $AA (WhiteKing) to $9000, the tutorial's enemy.
;@ test: skip decompresses into VRAM
LoadTutorEnemyPic::
;>@g gfx = mem16[MonsterPicRefs + 2 * 0xAA]
	ld a, $aa
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterPicRefs)
;=@g
	ld l, a
	ld a, h
	adc HIGH(MonsterPicRefs)
	ld h, a
	ld e, [hl]
	inc hl
;=@g
	ld d, [hl]
;> DecompressVRAM(gfx >> 8, gfx & 0xFF, 0x9000)
	ld hl, $9000
	call DecompressVRAM
	ret

;@ def DrawTutorBattleScreen()
;@ path: system/debug/battletutor
;@ Draws the tutorials' mock battle screen: the enemy name box straight into BG map row 27
;@ ($9B60, in view while the screen is scrolled to Y $D8), and into a blank wTilemapBuffer the
;@ bottom of that box, the enemy picture and the message box.
;@ test: skip writes VRAM
DrawTutorBattleScreen::
;> ClearTilemapBuffer_59()
	call ClearTilemapBuffer_59
;> DrawLayout_59(TutorEnemyNameLayout, 0x9B60)
	ld de, TutorEnemyNameLayout
	ld hl, $9b60
	call DrawLayout_59
;> DrawLayout_59(TutorEnemyNameBottomLayout, wTilemapBuffer)
	ld de, TutorEnemyNameBottomLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;> DrawLayout_59(TutorEnemyPicLayout, wTilemapBuffer)
	ld de, TutorEnemyPicLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
;> DrawLayout_59(TutorMessageBoxLayout, wTilemapBuffer)
	ld de, TutorMessageBoxLayout
	ld hl, wTilemapBuffer
	call DrawLayout_59
	ret

;@ def ClearTilemapBuffer_59()
;@ path: gfx/tilemap
;@ Fills wTilemapBuffer with the blank tile $E0.
ClearTilemapBuffer_59::
;> fill(wTilemapBuffer, 0xE0, 0x240)
	ld a, $e0
	ld hl, wTilemapBuffer
	ld bc, $0240
	call FillMemory
	ret

;@ def Multiply_59(count: a, size: bc) -> bc
;@ path: system/math
;@ Returns `count` * `size` (16 bits) by repeated adding.
;@ test: count = rand(0, 20)
Multiply_59::
;> if count == 0:
	or a
	jr z, .zero

;>@z     return 0
;> total = 0
	ld hl, $0000

.loop
;> while count:
;>     total = (total + size) & 0xFFFF; count -= 1
	add hl, bc
	dec a
	jr nz, .loop

;> return total
	ld b, h
	ld c, l
	ret


.zero
;=@z
	ld bc, $0000
	ret

;@ path: system/debug/battletutor
;@ Box layout (format: DrawLayout_59): the 6 x 6 tiles of the enemy picture ($00-$23, unpacked
;@ to $9000 by LoadTutorEnemyPic) at row 1, column 7 - the battle screen tutorial.
TutorEnemyPicLayout::
	dw $0027
	db $00, $01, $02, $03, $04, $05, $d8
	db $06, $07, $08, $09, $0a, $0b, $d8
	db $0c, $0d, $0e, $0f, $10, $11, $d8
	db $12, $13, $14, $15, $16, $17, $d8
	db $18, $19, $1a, $1b, $1c, $1d, $d8
	db $1e, $1f, $20, $21, $22, $23, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the enemy picture's 6 x 6 tiles at row 6, column 7, lower
;@ than in the battle screen tutorial, above the command tutorial's party panel.
TutorEnemyPicLowLayout::
	dw $00c7
	db $00, $01, $02, $03, $04, $05, $d8
	db $06, $07, $08, $09, $0a, $0b, $d8
	db $0c, $0d, $0e, $0f, $10, $11, $d8
	db $12, $13, $14, $15, $16, $17, $d8
	db $18, $19, $1a, $1b, $1c, $1d, $d8
	db $1e, $1f, $20, $21, $22, $23, $d9

;@ path: system/debug/battletutor
;@ Box layout (format: DrawLayout_59): the 20 x 5 message box at the bottom (rows 13-17), its two
;@ text lines being the letter tiles $B0-$C1 and $C2-$D3 of the text box at $8B00.
TutorMessageBoxLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/battletutor
;@ The same message box one row higher up the map, at rows 8-12 (BattleTutorInit draws it there
;@ once, under the screen's first scroll position).
TutorMessageBoxHighLayout::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/battletutor
;@ Box layout (format: DrawLayout_59): the 13 x 5 command box at row 8 with the labels FIGHT, PLAN,
;@ ITEM and RUN made of tiles from $6C on.
TutorCommandBoxLayout::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $6c, $6c, $83, $7c, $e0, $e0, $6d, $7c, $6e, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7e, $7d, $7f, $82, $e0, $e0, $81, $80, $6f, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/battletutor
;@ Box layout (format: DrawLayout_59): the enemy name box (name tiles $70-$73) with the HP / MP
;@ divider, drawn straight into BG map row 27 (DrawTutorBattleScreen).
TutorEnemyNameLayout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $e0, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $f1, $f9, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $f2, $e0, $e0, $ff, $d9

;@ path: system/debug/battletutor
;@ Box layout (format: DrawLayout_59): the bottom edge of the enemy name box, at row 0 of the
;@ buffer (the map wraps from row 31 to row 0).
TutorEnemyNameBottomLayout::
	dw $0000
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the yes / no box at row 8, column 14.
TutorYesNoLayout::
	dw $010e
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $d4, $e0, $d5, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the order box (ATK, the skills, the defense) at rows 11-17.
TutorOrderMenuLayout::
	dw $0160
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $87, $7c, $80, $9c, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $9b, $7d, $9d, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $8a, $7c, $9c, $8b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the party panel for three monsters (20 x 6 at the top): the
;@ name tiles, status icons $DA-$DC, the HP ($E1) and MP ($E2) rows.
TutorParty3Layout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the party panel for two monsters (14 x 6).
TutorParty2Layout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the party panel for one monster (8 x 6).
TutorParty1Layout::
	dw $0000
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8
	db $fe, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the command box (FIGHT / PLAN / ITEM / RUN) at rows 13-17.
TutorMainMenuLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the ALL / EACH box at rows 13-17.
TutorTargetMenuLayout::
	dw $01a0
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $92, $93, $94, $84, $9c, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: unused/data
;@ Box layout (format: DrawLayout_59) nothing draws: a 6 x 3 box at row 8 with tiles $6C-$6F.
UnusedLayout_59_6106::
	dw $0100
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $6c, $6d, $6e, $6f, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: system/debug/commandtutor
;@ Box layout (format: DrawLayout_59): the strategy box (CHARGE!, MIXED, CAUTIOUS, COMMAND) at
;@ rows 9-17.
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

;@ path: unused/data
;@ Thirteen more box layouts (format: DrawLayout_59) that nothing draws, from $618B to $6727:
;@ further variants of the battle windows (lists, small boxes, a 20 x 7 box with tiles $00-$35).
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

;@ path: data
;@ Unused space at the end of bank $59 (zero bytes).
Bank59Padding::
	ds 6360, $00
