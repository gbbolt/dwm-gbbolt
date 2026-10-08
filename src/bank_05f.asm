INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $05f", ROMX[$4000], BANK[$5f]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_5F::
	db $5f

;@ path: system/banks
;@ Entry points of bank $5F for far calls: the ending (game mode 4), the opening, the battle
;@ screen effects and skill animations, the debug animation viewer (game mode 5) and the debug
;@ window with the battlers' personality numbers. Entry 3 is the opening's per-frame routine.
FarTable_5F::
	dw EndingInit
	dw EndingUpdate
	dw OpeningInit
	dw $4619
	dw StartSkillHitEffect
	dw UpdateScreenEffect
	dw StartSkillVisual
	dw GetSkillAnim
	dw AnimViewerInit
	dw AnimViewerUpdate
	dw DebugStatsWindow

;@ def EndingInit()
;@ path: event/ending
;@ Start-up routine of game mode 4, the ending: blanks the BG map and sets up step
;@ wGameModeStep (0 the staff credits, 1 the closing screen with the save question).
;@ test: skip calls routines in other banks
EndingInit::
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wSGBPalSet = 0; wSGBAttrSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> fill(0x9800, 0xE0, 0x400)              # blank BG map
	ld hl, $9800
	ld bc, $0400
	ld a, $e0
	call FillMemory
;> EndingInitSteps[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: event/ending
;@ Start-up routine of each step of the ending (game mode 4).
EndingInitSteps::
	dw EndingInitCredits
	dw EndingInitSavePrompt

;@ def EndingInitCredits()
;@ path: event/ending
;@ Step 0: sets up the staff credits. Every tile starts as plain light grey, the text box
;@ letters go to $8B00 (2 lines of 18), the window frame tiles to $8D00; the screen frame
;@ CreditsTilemap is drawn and the first credits page (text and monster picture) shown, then
;@ the screen fades in to song $21.
;@ test: skip calls routines in other banks
EndingInitCredits::
;> FillTileStripes(0x8000, 0xC00)          # all 384 tiles light grey
	ld hl, $8000
	ld bc, $0c00
	call FillTileStripes
;> SetUpTextBox(0x8B00, 2, 18)
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> Decompress(0x2E, 0x00, 0x8D00)          # window frame tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> CopyTileRect_5F(CreditsTilemap, 0x9800, 20, 18)
	ld de, CreditsTilemap
	ld hl, $9800
	ld bc, $1412
	call CopyTileRect_5F
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> PrintCreditsPage()
	call PrintCreditsPage
;> LoadCreditsMonster()
	call LoadCreditsMonster
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> QueueMusic(0x21)
	ld a, $21
	call QueueMusic
;> hScrollX = 0
	xor a
	ldh [hScrollX], a
;> hScrollY = 0
	xor a
	ldh [hScrollY], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLCDC = 0x11                            # BG on, BG tiles at $8000
	ld a, $11
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x01)            # VBlank interrupt only
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def EndingInitSavePrompt()
;@ path: event/ending
;@ Step 1: sets up the closing screen: plain tiles from $8800 on, the text box of
;@ EndingSaveBoxTilemap at the bottom (rows 13-16), the window frame tiles, and song $31.
;@ test: skip calls routines in other banks
EndingInitSavePrompt::
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> FillTileStripes(0x8800, 0x800)
	ld hl, $8800
	ld bc, $0800
	call FillTileStripes
;> CopyTileRect_5F(EndingSaveBoxTilemap, 0x99A0, 20, 4)
	ld de, EndingSaveBoxTilemap
	ld hl, $99a0
	ld bc, $1404
	call CopyTileRect_5F
;> Decompress(0x2E, 0x00, 0x8D00)          # window frame tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> SetUpTextBox(0x8B00, 2, 18)
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> QueueMusic(0x31)
	ld a, $31
	call QueueMusic
;> hScrollX = 0
	xor a
	ldh [hScrollX], a
;> hScrollY = 0
	xor a
	ldh [hScrollY], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLCDC = 0x01                            # BG on, BG tiles at $8800
	ld a, $01
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x01)            # VBlank interrupt only
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def FillTileStripes(dest: hl, count: bc)
;@ path: gfx/tiles
;@ Writes `count` byte pairs $FF, $00 from `dest` on: tile rows of colour 1, so the tiles
;@ there become plain light grey.
;@ test: dest = 0xC100; count = rng.randint(1, 64)
FillTileStripes::
;> while True:
;>     mem[dest] = 0xFF; mem[dest + 1] = 0x00
	ld [hl], $ff
	inc hl
	ld [hl], $00
;>     dest += 2
	inc hl
;>     count = u16(count - 1)
	dec bc
;>     if count == 0:
	ld a, b
	or c
	jr nz, FillTileStripes

;>         return
	ret


;@ def EndingUpdate()
;@ path: event/ending
;@ Per-frame routine of game mode 4 (the ending); does nothing while a fade runs.
;@ test: skip runs the steps through a jump table
EndingUpdate::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> EndingUpdateSteps[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: event/ending
;@ Per-frame routine of each step of the ending.
EndingUpdateSteps::
	dw EndingCredits
	dw EndingSavePrompt

;@ def EndingCredits()
;@ path: event/ending
;@ Step 0 of the ending: runs state wSceneObjects[0] of the staff credits. The credits keep
;@ their counters in wSceneObjects: [1] page (0-26), [2] frames, [3] seconds shown; [4-5] VRAM
;@ address and [6] species of the page's monster picture.
;@ test: skip runs the states through a jump table
EndingCredits::
;> EndingCreditsStates[wSceneObjects[0]]()
	ld a, [wSceneObjects]
	rst $00

;@ path: event/ending
;@ States of the staff credits: 0 show the page for 5 seconds, 1 draw the next page, 2 fade it
;@ in, 3 go on (or stop after the last page), 4 wait and go back to the field.
EndingCreditsStates::
	dw CreditsWaitPage
	dw CreditsNextPage
	dw CreditsFadeIn
	dw CreditsCheckLast
	dw CreditsLeaveToField

;@ def EndingSavePrompt()
;@ path: event/ending
;@ Step 1 of the ending: runs state wSceneObjects[0] of the closing screen.
;@ test: skip runs the states through a jump table
EndingSavePrompt::
;> EndingSavePromptStates[wSceneObjects[0]]()
	ld a, [wSceneObjects]
	rst $00

;@ path: event/ending
;@ States of the closing screen: 0 print the closing text, 1 start, 2 wait for a button and
;@ ask whether to save, 3 save on yes and print the answer, 4 wait for the text.
EndingSavePromptStates::
	dw SavePromptPrintEnd
	dw SavePromptStart
	dw SavePromptWaitButton
	dw SavePromptAnswer
	dw SavePromptDone

;@ def CreditsWaitPage()
;@ path: event/ending
;@ Credits state 0: counts frames and seconds; after 5 seconds the page fades out and state 1
;@ draws the next one.
;@ test: wSceneObjects[2] = rng.randint(0, 59); wSceneObjects[3] = rng.randint(0, 4)
CreditsWaitPage::
;> wSceneObjects[2] += 1                   # frames
	ld hl, wSceneObjects + 2
	inc [hl]
;> if wSceneObjects[2] < 60:
;>     return
	ld a, [hl]
	cp $3c
	ret c

;> wSceneObjects[2] = 0
	ld a, $00
	ld [hli], a
;> wSceneObjects[3] += 1                   # seconds
	inc [hl]
;> if wSceneObjects[3] < 5:
;>     return
	ld a, [hl]
	cp $05
	ret c

;> wSceneObjects[3] = 0
	ld [hl], $00
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
;> wMapLoadState += 1
	ld hl, wMapLoadState
	inc [hl]
;> StartFade(0x04)                         # fade out
	ld a, $04
	call StartFade
	ret


;@ def CreditsNextPage()
;@ path: event/ending
;@ Credits state 1 (screen faded out): goes to the next page and draws its text and monster;
;@ page 26, the last, also gets its own screen layout.
;@ test: skip calls routines in other banks
CreditsNextPage::
;> wSceneObjects[1] += 1                   # page
	ld hl, wSceneObjects + 1
	inc [hl]
;> if wSceneObjects[1] == 26:
;>     DrawCreditsLastPage()
	ld a, [hl]
	cp $1a
	call z, DrawCreditsLastPage
;> PrintCreditsPage()
	call PrintCreditsPage
;> LoadCreditsMonster()
	call LoadCreditsMonster
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def CreditsFadeIn()
;@ path: event/ending
;@ Credits state 2: fades the new page in (on a Super Game Boy with the colours of the
;@ monster's palette).
;@ test: skip calls a routine in another bank
CreditsFadeIn::
;> SGBLoadPalettes()
	ld hl, far_SGBLoadPalettes
	rst $10
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def CreditsCheckLast()
;@ path: event/ending
;@ Credits state 3: back to state 0 for the next page, or on to state 4 after the last page.
;@ test: wSceneObjects[1] = rng.choice([0, 5, 26])
CreditsCheckLast::
;> wMapLoadState = 0
	xor a
	ld [wMapLoadState], a
;> if wSceneObjects[1] != 26:
;>     wSceneObjects[0] = 0
	ld a, [wSceneObjects + 1]
	cp $1a
	jr z, .last

	xor a
	ld [wSceneObjects], a
;>     return
	ret

.last
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def CreditsLeaveToField()
;@ path: event/ending
;@ Credits state 4: shows the last page for 5 seconds, then fades out and returns to the field
;@ (game mode 1) with a warp to map $2F at X $38, Y $C8.
;@ test: wSceneObjects[2] = rng.randint(0, 59); wSceneObjects[3] = rng.randint(0, 4)
CreditsLeaveToField::
;> wSceneObjects[2] += 1                   # frames
	ld hl, wSceneObjects + 2
	inc [hl]
;> if wSceneObjects[2] < 60:
;>     return
	ld a, [hl]
	cp $3c
	ret c

;> wSceneObjects[2] = 0
	ld a, $00
	ld [hli], a
;> wSceneObjects[3] += 1                   # seconds
	inc [hl]
;> if wSceneObjects[3] < 5:
;>     return
	ld a, [hl]
	cp $05
	ret c

;> wSceneObjects[3] = 0
	ld [hl], $00
;> wWarpMap = 0x2F; wWarpOnGateFloor = 0
	ld hl, $002f
	ld a, l
	ld [wWarpMap], a
	ld a, h
	ld [wWarpOnGateFloor], a
;> wWarpX = 0x0038
	ld hl, $0038
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [wWarpX + 1], a
;> wWarpY = 0x00C8
	ld hl, $00c8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [wWarpY + 1], a
;> wWarpPending = 1
	ld a, $01
	ld [wWarpPending], a
;> hPlayerFlags = 0
	xor a
	ldh [hPlayerFlags], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags &= ~0x01                    # no field event pending
	ld hl, wFieldFlags
	res 0, [hl]
;> wGameMode = 1                           # the field
	ld a, $01
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
;> StartFade(0x04)
	ld a, $04
	call StartFade
	ret


;@ def SavePromptPrintEnd()
;@ path: event/ending
;@ Closing screen state 0: prints text 7/0 of bank $4C (the closing words) into the text box.
;@ test: skip calls a routine in another bank
SavePromptPrintEnd::
;> wTextGroup = 7
	ld a, $07
	ld [wTextGroup], a
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> PrintText_4C()
	ld hl, $4c02
	rst $10
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def SavePromptStart()
;@ path: event/ending
;@ Closing screen state 1: clears wMapLoadState and goes on.
SavePromptStart::
;> wMapLoadState = 0
	xor a
	ld [wMapLoadState], a
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def SavePromptWaitButton()
;@ path: event/ending
;@ Closing screen state 2: waits for A, B, Select or Start, then asks whether to save (system
;@ text $0256 in a message window drawn at the top of the screen).
;@ test: skip prints text
SavePromptWaitButton::
;> if wJoyPressed & 0x0F == 0:
;>     return
	ld a, [wJoyPressed]
	and $0f
	ret z

;> PrintSystemText(0x0256)                 # save the game?
	ld hl, $0256
	call PrintSystemText
;> DrawTilemapVRAM_5F(MessageWindowLayout, 0x9800)
	ld de, MessageWindowLayout
	ld hl, $9800
	call DrawTilemapVRAM_5F
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def SavePromptAnswer()
;@ path: event/ending
;@ Closing screen state 3: once the question is answered, saves the game on "yes" (with
;@ wGameStarted set and the field state cleared, so the save continues after the ending) and
;@ prints system text $0257 (saved) or $0258 (not saved).
;@ test: skip saves the game
SavePromptAnswer::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wTextChoice != 0:                    # "no"
;>     msg = 0x0258
	ld a, [wTextChoice]
	or a
	ld hl, $0258
	jr nz, .print

;> else:
;>     hPlayerFlags = 0
	xor a
	ldh [hPlayerFlags], a
;>     wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;>     wGameStarted = 1
	ld a, $01
	ld [wGameStarted], a
;>     wFieldFlags &= ~0x01
	ld hl, wFieldFlags
	res 0, [hl]
;>     disable_interrupts()
	di
;>     SaveGame()
	call SaveGame
;>     enable_interrupts()
	ei
;>     QueueSound(0x59)                    # saved jingle
	ld a, $59
	call QueueSound
;>     msg = 0x0257
	ld hl, $0257

.print
;> PrintSystemText(msg)
	call PrintSystemText
;> wSceneObjects[0] += 1
	ld hl, wSceneObjects
	inc [hl]
	ret


;@ def SavePromptDone()
;@ path: event/ending
;@ Closing screen state 4: nothing more happens; the game stays on this screen.
SavePromptDone::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> return
	ret


CopyTileRect_5F::
	push bc
	push hl

jr_05f_424c:
	ld a, [de]
	call WriteVRAM
	inc hl
	inc de
	dec b
	jr nz, jr_05f_424c

	pop hl
	pop bc
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	dec c
	jr nz, CopyTileRect_5F

	ret


DrawTilemap_5F::
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	add hl, bc
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [$c0ff], a

jr_05f_4272:
	ld a, [de]
	inc de
	cp $d8
	jr z, jr_05f_427e

	cp $d9
	ret z

	ld [hli], a
	jr jr_05f_4272

jr_05f_427e:
	ld a, [wSceneObjectPtr]
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
	ld [wSceneObjectPtr], a
	ld a, h
	ld [$c0ff], a
	jr jr_05f_4272

DrawTilemapVRAM_5F::
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	add hl, bc
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [$c0ff], a

jr_05f_42a7:
	ld a, [de]
	inc de
	cp $d8
	jr z, jr_05f_42b5

	cp $d9
	ret z

	call WriteVRAMInc
	jr jr_05f_42a7

jr_05f_42b5:
	ld a, [wSceneObjectPtr]
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
	ld [wSceneObjectPtr], a
	ld a, h
	ld [$c0ff], a
	jr jr_05f_42a7

EndingSaveBoxTilemap::
	db $e0, $e0, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $e0, $e0, $fe, $b0, $b1, $b2, $e0, $b3, $b4, $e0, $b5, $b6
	db $b7, $b8, $b9, $ba, $bb, $bc, $bd, $ff, $e0, $e0, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $e0, $e0, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd

PrintCreditsHeading::
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
	ld hl, $8000
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $1402
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld hl, EffectShakeY
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c828], a
	ld a, d
	ld [wTextBoxLines], a
	ret


PrintCreditsBody::
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
	ld hl, $8260
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld de, $0b0c
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld hl, EffectShakeY
	rst $10
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
	ld a, e
	ld [$c828], a
	ld a, d
	ld [wTextBoxLines], a
	ret


PrintCreditsPage::
	ld a, [$c0d9]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	call PrintCreditsHeading
	ld a, [$c0d9]
	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a
	call PrintCreditsBody
	ret


LoadCreditsMonster::
	ld a, [$c0d9]
	ld hl, $43f4
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	ret z

	ld [$c0de], a
	ld [wPaletteSet], a
	ld a, $04
	ld [wMonPicPalette], a
	ld hl, $016d
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [$c821], a
	ld hl, $8aa0
	ld a, l
	ld [$c0dc], a
	ld a, h
	ld [$c0dd], a
	ld hl, far_LoadMonsterPicFar
	rst $10
	ld hl, far_LoadMonPicPalette
	rst $10
	ret


CreditsMonsters::
	db $6d, $13, $59, $49, $42, $0a, $a4, $1b, $81, $84, $c7, $95, $96, $97, $44, $7f
	db $c2, $91, $9a, $2c, $6d, $13, $59, $49, $42, $0a, $08

DrawCreditsLastPage::
	ld de, $681b
	ld hl, $9800
	ld bc, ClearScroll
	call CopyTileRect_5F
	ret


OpeningInit::
	ld a, [wOpeningScene]
	rst $00

OpeningInitScenes::
	dw OpeningInitLogos
	dw OpeningInitStarScene
	dw OpeningInitStarScene
	dw OpeningInitStarScene
	dw OpeningInitPicture
	dw OpeningInitStarScene
	dw OpeningInitTitle

OpeningInitLogos::
	ld a, [wOpeningLogo]
	rst $00

OpeningInitLogoTable::
	dw OpeningInitLogo0
	dw OpeningInitLogo1
	dw OpeningInitLogo2
	db $c9

OpeningInitLogo0::
	ld a, $02
	call LoadSGBBorder
	call SGBPacketDelay
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	ld de, $560e
	ld hl, $9000
	call Decompress
	ld de, $669d
	ld hl, $9800
	call DrawTilemap_5F
	ld a, $00
	ld [wPaletteSet], a
	ld hl, far_LoadPaletteSet
	rst $10
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
	ld a, $00
	ldh [rVBK], a
	ret


OpeningInitLogo1::
	ld a, $02
	call LoadSGBBorder
	call SGBPacketDelay
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	ld de, $560c
	ld hl, $9000
	call Decompress
	ld de, $666e
	ld hl, $9800
	call DrawTilemap_5F
	ld a, $00
	ld [wPaletteSet], a
	ld hl, far_LoadPaletteSet
	rst $10
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
	ld a, $00
	ldh [rVBK], a
	ret


OpeningInitLogo2::
	ld a, $02
	call LoadSGBBorder
	call SGBPacketDelay
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	ld de, $5b1f
	ld hl, $9000
	call Decompress
	ld de, $6457
	ld hl, $9800
	call DrawTilemap_5F
	ld a, $00
	ld [wPaletteSet], a
	ld hl, far_LoadPaletteSet
	rst $10
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
	ld a, $00
	ldh [rVBK], a
	ret


OpeningInitStarScene::
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
	ld a, $ff
	ld hl, $9000
	ld bc, $0010
	call FillMemory
	ld de, $5b18
	ld hl, $8000
	call DecompressVRAM
	ld de, $5b19
	ld hl, $8040
	call DecompressVRAM
	ld a, $00
	ld [wPaletteSet], a
	ld hl, far_LoadPaletteSet
	rst $10
	ld a, $00
	ld [wPaletteSet], a
	ld hl, $170c
	rst $10
	ld a, $01
	ldh [rVBK], a
	xor a
	ld hl, $9800
	ld bc, $0400
	ld a, [wOnCGB]
	or a
	ld a, $00
	call nz, FillMemory
	ld a, $00
	ldh [rVBK], a
	ret


OpeningInitPicture::
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	ld de, $5b20
	ld hl, $9000
	call Decompress
	ld de, $5b21
	ld hl, $8800
	call Decompress
	ld de, $64f1
	ld hl, $9800
	call DrawTilemap_5F
	ld a, $01
	ld [wPaletteSet], a
	ld hl, far_LoadPaletteSet
	rst $10
	ld de, $3f02
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
	ld a, $00
	ldh [rVBK], a
	ret


OpeningInitTitle::
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
	ld de, $5b20
	ld hl, $9000
	call DecompressVRAM
	ld de, $5b21
	ld hl, $8800
	call DecompressVRAM
	ld de, $6583
	ld hl, $9800
	call DrawTilemap_5F
	ld a, $06
	call QueueMusic
	ld a, $01
	ld [wPaletteSet], a
	ld hl, far_LoadPaletteSet
	rst $10
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	jr nz, jr_05f_460c

	jr jr_05f_4614

jr_05f_460c:
	ld a, $05
	ld [hli], a
	ld a, h
	cp $9b
	jr nz, jr_05f_460c

jr_05f_4614:
	ld a, $00
	ldh [rVBK], a
	ret


	ld a, $f4
	call SerialSendSlave
	ld a, [wJoyPressed]
	bit 0, a
	jr nz, OpeningSkip

	bit 1, a
	jr nz, OpeningSkip

	bit 3, a
	jr nz, OpeningSkip

	ld a, [wOpeningScene]
	rst $00

OpeningUpdateScenes::
	dw OpeningLogos
	dw OpeningStarScene1
	dw OpeningStarScene2
	dw OpeningStarScene3
	dw OpeningPicture
	dw OpeningStarScene5
	dw OpeningTitle

OpeningSkip::
	ld a, [wOpeningScene]
	cp $06
	jr nc, jr_05f_4663

	cp $00
	jr z, jr_05f_467c

Jump_05f_464a:
	ld a, $04
	call StartFade
	ld a, $00
	ld [wGameModeStep], a
	ld a, $06
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ret


jr_05f_4663:
	ld a, $04
	call StartFade
	ld a, $01
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ret


jr_05f_467c:
	ld a, [wOpeningLogo]
	cp $00
	jp nz, Jump_05f_4685

	ret


Jump_05f_4685:
	ld a, [wOpeningLogo]
	cp $01
	jp nz, Jump_05f_464a

	ld a, $04
	call StartFade
	ld a, $00
	ld [wGameModeStep], a
	ld a, $00
	ld [wOpeningScene], a
	ld a, $02
	ld [wOpeningLogo], a
	ld hl, wGameModeChange
	inc [hl]
	ret


OpeningLogos::
	ld a, [wOpeningLogo]
	rst $00

OpeningLogoSteps::
	dw OpeningLogo0
	dw OpeningLogo1
	dw OpeningLogo2
	db $c9

OpeningLogo0::
	ld a, [wFadeState]
	or a
	ret nz

	ld hl, wSceneObjects
	inc [hl]
	ld a, [wSceneObjects]
	cp $3c
	ret nz

	ld a, $04
	call StartFade
	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningLogo
	inc [hl]
	ld hl, wGameModeChange
	inc [hl]
	ret


OpeningLogo1::
	ld a, [wFadeState]
	or a
	ret nz

	ld hl, wSceneObjects
	inc [hl]
	ld a, [wSceneObjects]
	cp $b4
	ret nz

	ld a, $04
	call StartFade
	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningLogo
	inc [hl]
	ld hl, wGameModeChange
	inc [hl]
	ret


OpeningLogo2::
	ld a, [wFadeState]
	or a
	ret nz

	ld hl, wSceneObjects
	inc [hl]
	ld a, [wSceneObjects]
	cp $b4
	ret nz

	ld a, $04
	call StartFade
	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningScene
	inc [hl]
	ld hl, wGameModeChange
	inc [hl]
	ld hl, $c0dc
	call SetUpStarScene1
	ret


OpeningStarScene1::
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wSceneObjects]
	or a
	jr nz, jr_05f_472a

	ld a, $5d
	call QueueSound

jr_05f_472a:
	ld a, $01
	ld [wSceneObjects], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_4777

	ld a, $00
	ldh [hSpriteSet], a
	ld a, $00
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0dc
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $40
	jr z, jr_05f_4772

	cp $e0
	jr nz, jr_05f_4777

	ld a, $01
	ld [$c0dc], a
	jr jr_05f_4777

jr_05f_4772:
	ld a, $00
	ld [$c0e2], a

jr_05f_4777:
	ld a, [$c0e2]
	or a
	ret nz

	ld a, $01
	ldh [hSpriteSet], a
	ld a, $04
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0e2
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningScene
	inc [hl]
	ld hl, $c0dc
	call SetUpStarScene2
	ret


OpeningStarScene2::
	ld a, [wSceneObjects]
	or a
	jr nz, jr_05f_47bb

	ld a, $5d
	call QueueSound

jr_05f_47bb:
	ld a, $01
	ld [wSceneObjects], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_4808

	ld a, $00
	ldh [hSpriteSet], a
	ld a, $00
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0dc
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $10
	jr z, jr_05f_4803

	cp $e0
	jr nz, jr_05f_4808

	ld a, $01
	ld [$c0dc], a
	jr jr_05f_4808

jr_05f_4803:
	ld a, $00
	ld [$c0e2], a

jr_05f_4808:
	ld a, [$c0e2]
	or a
	ret nz

	ld a, $01
	ldh [hSpriteSet], a
	ld a, $04
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0e2
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningScene
	inc [hl]
	ld hl, $c0dc
	call SetUpStarScene3
	ret


OpeningStarScene3::
	ld a, [wSceneObjects]
	or a
	jr nz, jr_05f_484c

	ld a, $5d
	call QueueSound

jr_05f_484c:
	ld a, $01
	ld [wSceneObjects], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_4899

	ld a, $00
	ldh [hSpriteSet], a
	ld a, $00
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0dc
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $70
	jr z, jr_05f_4894

	cp $20
	jr nz, jr_05f_4899

	ld a, $01
	ld [$c0dc], a
	jr jr_05f_4899

jr_05f_4894:
	ld a, $00
	ld [$c0e2], a

jr_05f_4899:
	ld a, [$c0e2]
	or a
	ret nz

	ld a, $01
	ldh [hSpriteSet], a
	ld a, $04
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0e2
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	ld a, $04
	call StartFade
	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningScene
	inc [hl]
	ld hl, wGameModeChange
	inc [hl]
	ret


OpeningPicture::
	ld a, [wFadeState]
	or a
	ret nz

	ld hl, wSceneObjects
	inc [hl]
	ld a, [wSceneObjects]
	cp $78
	ret nz

	ld a, $04
	call StartFade
	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningScene
	inc [hl]
	ld hl, wGameModeChange
	inc [hl]
	xor a
	ld [$c0e8], a
	xor a
	ld [$c0e9], a
	xor a
	ld [$c0ea], a
	ld hl, $c0dc
	call SetUpStarScene5
	ret


OpeningStarScene5::
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wSceneObjects]
	or a
	jr nz, jr_05f_4918

	ld a, $5d
	call QueueSound

jr_05f_4918:
	ld a, $01
	ld [wSceneObjects], a
	ld a, [$c0dc]
	or a
	jr nz, jr_05f_495a

	ld a, $00
	ldh [hSpriteSet], a
	ld a, $00
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0dc
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0dd
	dec [hl]
	ld hl, $c0de
	inc [hl]
	ld hl, $c0de
	inc [hl]
	ld a, [$c0dd]
	cp $36
	jr nz, jr_05f_495a

	ld a, $01
	ld [$c0dc], a

jr_05f_495a:
	ld a, [$c0e2]
	or a
	jr nz, jr_05f_4997

	ld a, $00
	ldh [hSpriteSet], a
	ld a, $00
	ldh [hSpriteTileBase], a
	ld a, $00
	ldh [hSpriteAttr], a
	ld hl, $c0e2
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
	ld hl, $0204
	rst $10
	ld hl, $c0e3
	dec [hl]
	ld hl, $c0e3
	dec [hl]
	ld hl, $c0e4
	inc [hl]
	ld hl, $c0e4
	inc [hl]
	ld a, [$c0e3]
	cp $59
	jr nz, jr_05f_4997

	ld a, $01
	ld [$c0e2], a

jr_05f_4997:
	ld a, [$c0e2]
	or a
	ret z

	ld a, [$c0dc]
	or a
	ret z

	ld a, $04
	call StartFade
	xor a
	ld [wSceneObjects], a
	ld hl, wOpeningScene
	inc [hl]
	ld hl, wGameModeChange
	inc [hl]
	ret


OpeningTitle::
	ld a, [$ddb4]
	ld hl, $ddce
	and [hl]
	ld hl, $dde8
	and [hl]
	ld hl, $de02
	and [hl]
	cp $ff
	ret nz

	ld a, $06
	di
	call QueueMusic
	ret


SetUpStarScene1::
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


SetUpStarScene2::
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


SetUpStarScene3::
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


SetUpStarScene5::
	ld a, $00
	ld [hli], a
	ld a, $86
	ld [hli], a
	ld a, $fe
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $a9
	ld [hli], a
	ld a, $04
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $02
	ld [hli], a
	ret


StartSkillHitEffect::
	ld a, [wSkillId]
	cp $12
	jp c, Jump_05f_4ae8

	cp $39
	jr z, jr_05f_4ae8

	cp $37
	ret c

	cp $41
	jr c, jr_05f_4ae8

	cp $42
	ret c

	cp $43
	jr c, jr_05f_4ae8

	cp $44
	ret c

	cp $54
	jr c, jr_05f_4ae8

	cp $55
	ret c

	cp $6a
	jr c, jr_05f_4ae8

	cp $73
	ret c

	cp $75
	jr c, jr_05f_4ae8

	cp $7d
	ret c

	cp $7f
	jr c, jr_05f_4ae8

	cp $81
	ret c

	cp $84
	jr c, jr_05f_4ae8

	cp $88
	jr c, jr_05f_4b0b

	cp $99
	ret c

	cp $9c
	jr c, jr_05f_4ae8

	cp $a5
	ret c

	cp $a6
	jr c, jr_05f_4ae8

	cp $ab
	ret c

	cp $ac
	jr c, jr_05f_4ae8

	cp $af
	ret c

	cp $b0
	jr c, jr_05f_4ae8

	cp $c7
	ret c

	cp $c9
	jr c, jr_05f_4ae8

	cp $ca
	ret c

	cp $cc
	jr c, jr_05f_4ae8

	cp $d4
	ret c

	cp $d5
	jr c, jr_05f_4ae8

	cp $d6
	ret c

	cp $da
	jr c, jr_05f_4ae8

	cp $dd
	ret c

	cp $de
	jr c, jr_05f_4ae8

	cp $df
	ret c

	cp $e0
	jr c, jr_05f_4ae8

	ret


Jump_05f_4ae8:
jr_05f_4ae8:
	xor a
	ld hl, wBattleAnimDone
	ld bc, $0006
	call FillMemory
	ld b, $03
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_05f_4afd

	ld b, $02

jr_05f_4afd:
	ld a, [wSkillTarget]
	cp $04
	ld a, b
	jr c, jr_05f_4b07

	xor $01

jr_05f_4b07:
	ld [wScreenEffect], a
	ret


jr_05f_4b0b:
	xor a
	ld hl, wBattleAnimDone
	ld bc, $0006
	call FillMemory
	ld a, $04
	ld [wScreenEffect], a
	ret


UpdateScreenEffect::
	ld a, [$da34]
	inc a
	cp $05
	ld [$da34], a
	ret c

	xor a
	ld [$da34], a
	ld a, [wBattleAnimDone]
	or a
	ret nz

	ld a, [wItemMsgGroup]
	cp $80
	jr nz, jr_05f_4b40

	ld a, $6c
	call QueueSound
	ld a, $ff
	ld [wItemMsgGroup], a
	ret


jr_05f_4b40:
	ld a, [wScreenEffect]
	rst $00

ScreenEffects::
	dw EffectNone
	dw EffectNone
	dw EffectBlinkTarget
	dw EffectShakeY
	dw EffectFlash
	dw EffectDarken
	dw EffectInvert
	dw EffectDarkenTwice
	dw EffectQuake
	dw EffectWave
	dw EffectLighten
	dw EffectFlashLong
	dw EffectShakeX
	dw EffectBlinkUser

EffectNone::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectBlinkTarget::
	ld a, [wLinkFlags]
	ld b, a
	ld a, [wSkillTarget]
	and $03
	cp $03
	jr z, BlinkTargetEnd

	ld a, [wSkillTarget]
	bit 1, b
	jr nz, jr_05f_4b84

	cp $04
	jr c, BlinkTargetEnd

	jr jr_05f_4b88

jr_05f_4b84:
	cp $04
	jr nc, BlinkTargetEnd

jr_05f_4b88:
	ld a, [wBattleSubStep]
	cp $0a
	jr z, jr_05f_4b97

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, BlinkTargetEnd

jr_05f_4b97:
	ld a, [wScreenEffectStep]
	rst $00

BlinkTargetSteps::
	dw BlinkTargetHide
	dw BlinkTargetShow
	dw BlinkTargetHide
	dw BlinkTargetShow
	dw BlinkTargetEnd

BlinkTargetHide::
	ld a, $06
	ld [wScreenEffectTimer], a
	call GetTargetPicSlot
	ld hl, $50ff
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, $03
	ld hl, $5109
	call GetWordEntry_5F
	ld c, $06
	call CopyTileRectVRAM_5F
	ld hl, wScreenEffectStep
	inc [hl]
	ret


BlinkTargetShow::
	ld a, $06
	ld [wScreenEffectTimer], a
	call GetTargetPicSlot
	ld hl, $50ff
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, [wSkillTarget]
	and $03
	ld hl, $5109
	call GetWordEntry_5F
	ld c, $06
	call CopyTileRectVRAM_5F
	ld hl, wScreenEffectStep
	inc [hl]
	ret


BlinkTargetEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	xor a
	ld [wScreenEffectTimer], a
	ret


EffectShakeY::
	ld a, [wSkillId]
	cp $81
	jr z, ShakeYEnd

	ld a, [wScreenEffectStep]
	rst $00

ShakeYSteps::
	dw ShakeYDown
	dw ShakeYBack
	dw ShakeYDown
	dw ShakeYEnd

ShakeYDown::
	ld a, $02
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


	db $3e, $00, $e0, $bb, $3e, $01, $e0, $b7, $21, $84, $da, $34, $c9

ShakeYBack::
	xor a
	ldh [hScrollY], a
	xor a
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeYEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ldh [hScrollY], a
	xor a
	ldh [hScrollX], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectFlash::
	ld a, [wScreenEffectStep]
	rst $00

FlashSteps::
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw FlashEnd

SetPalettesWhite::
	ld hl, wBGP
	ld [hl], $00
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, wScreenEffectStep
	inc [hl]
	ret


SetPalettesNormal::
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, wScreenEffectStep
	inc [hl]
	ret


FlashEnd::
	call SetPalettesNormal
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectDarken::
	ld a, [wScreenEffectStep]
	rst $00

DarkenSteps::
	dw DarkenFade
	dw DarkenHold
	dw DarkenRestore
	dw DarkenEnd

DarkenFade::
	call DarkenPalettesStep
	ld a, [wScreenEffectFrame]
	cp $04
	ret c

	xor a
	ld [wScreenEffectAux], a
	xor a
	ld [wScreenEffectFrame], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


DarkenHold::
	ld hl, wScreenEffectTimer
	inc [hl]
	ld a, [wScreenEffectTimer]
	cp $0a
	ret nz

	ld hl, wScreenEffectStep
	inc [hl]
	xor a
	ld [wScreenEffectTimer], a
	ret


DarkenRestore::
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, wScreenEffectStep
	inc [hl]
	ret


DarkenEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectInvert::
	ld a, [wScreenEffectStep]
	rst $00

InvertSteps::
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertPalettes
	dw InvertEnd

InvertPalettes::
	ld hl, wBGP
	ld a, [hl]
	xor $ff
	ld [hli], a
	ld a, [hl]
	xor $ff
	ld [hli], a
	ld a, [hl]
	xor $ff
	ld [hl], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


InvertEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectDarkenTwice::
	ld a, [wScreenEffectStep]
	rst $00

DarkenTwiceSteps::
	dw DarkenTwiceFade
	dw DarkenTwiceHold
	dw DarkenTwiceRestore
	dw DarkenTwiceFade
	dw DarkenTwiceHold
	dw DarkenTwiceRestore
	dw DarkenTwiceEnd

DarkenTwiceFade::
	call DarkenPalettesStep
	ld a, [wScreenEffectFrame]
	cp $04
	ret c

	xor a
	ld [wScreenEffectAux], a
	xor a
	ld [wScreenEffectFrame], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


DarkenTwiceHold::
	ld hl, wScreenEffectTimer
	inc [hl]
	ld a, [wScreenEffectTimer]
	cp $05
	ret nz

	ld hl, wScreenEffectStep
	inc [hl]
	xor a
	ld [wScreenEffectTimer], a
	ret


DarkenTwiceRestore::
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, wScreenEffectStep
	inc [hl]
	ret


DarkenTwiceEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectQuake::
	ld a, [wScreenEffectStep]
	or a
	call z, QuakeShake
	call QuakeFlash
	ld a, [wScreenEffectStep]
	or a
	ret z

	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	xor a
	ld [wScreenEffectTimer], a
	ret


EffectWave::
	ld a, [wScreenEffectFrame]
	or a
	jr nz, jr_05f_4da1

	ld hl, wScreenEffectFrame
	inc [hl]
	xor a
	ld [wMenuStep], a
	xor a
	ld [wMenuSubStep], a
	xor a
	ld [wItemsHandedIn], a
	xor a
	ld [wHatchSlot], a
	ret


jr_05f_4da1:
	call WaveStep
	ld hl, wScreenEffectFrame
	inc [hl]
	ret


EffectLighten::
	ld a, [wScreenEffectStep]
	rst $00

LightenSteps::
	dw LightenFade
	dw LightenHold
	dw LightenRestore
	dw LightenEnd

LightenFade::
	call LightenPalettesStep
	ld a, [wScreenEffectFrame]
	cp $04
	ret c

	xor a
	ld [wScreenEffectAux], a
	xor a
	ld [wScreenEffectFrame], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


LightenHold::
	ld hl, wScreenEffectTimer
	inc [hl]
	ld a, [wScreenEffectTimer]
	cp $0a
	ret nz

	ld hl, wScreenEffectStep
	inc [hl]
	xor a
	ld [wScreenEffectTimer], a
	ret


LightenRestore::
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ld hl, wScreenEffectStep
	inc [hl]
	ret


LightenEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectFlashLong::
	ld a, [wScreenEffectStep]
	rst $00

FlashLongSteps::
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw FlashEnd
	db $c9

CopyTileRectVRAM_5F::
	push de
	ld a, [wScreenEffectTimer]
	ld b, a

jr_05f_4e24:
	di
	call WaitVRAMAccess
	ld a, [hli]
	ld [de], a
	ei
	inc de
	dec b
	jr nz, jr_05f_4e24

	pop de
	dec c
	ret z

	ld a, $20
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	jr CopyTileRectVRAM_5F

GetTargetPicSlot::
	ld a, [wLinkActive]
	or a
	jr z, jr_05f_4e4e

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_05f_4e4e

	ld a, [wPartyBattlers]
	jr jr_05f_4e51

jr_05f_4e4e:
	ld a, [wEnemyCount]

jr_05f_4e51:
	cp $01
	jr z, jr_05f_4e7d

	cp $02
	jr z, jr_05f_4e6c

	ld a, [wSkillTarget]
	and $03
	cp $01
	jr z, jr_05f_4e7d

	jr c, jr_05f_4e68

	ld a, $04
	jr jr_05f_4e7f

jr_05f_4e68:
	ld a, $03
	jr jr_05f_4e7f

jr_05f_4e6c:
	ld a, [wSkillTarget]
	and $03
	cp $01
	jr z, jr_05f_4e79

	ld a, $01
	jr jr_05f_4e7f

jr_05f_4e79:
	ld a, $02
	jr jr_05f_4e7f

jr_05f_4e7d:
	ld a, $00

jr_05f_4e7f:
	ret


GetUserPicSlot::
	ld a, [wLinkActive]
	or a
	jr z, jr_05f_4ea3

	call CheckSwappedPicSkill
	jr nz, jr_05f_4e97

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_05f_4ea3

	ld a, [wPartyBattlers]
	jr jr_05f_4ea6

jr_05f_4e97:
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_05f_4ea3

	ld a, [wPartyBattlers]
	jr jr_05f_4ea6

jr_05f_4ea3:
	ld a, [wEnemyCount]

jr_05f_4ea6:
	cp $01
	jr z, jr_05f_4ed2

	cp $02
	jr z, jr_05f_4ec1

	ld a, [wSkillUser]
	and $03
	cp $01
	jr z, jr_05f_4ed2

	jr c, jr_05f_4ebd

	ld a, $04
	jr jr_05f_4ed4

jr_05f_4ebd:
	ld a, $03
	jr jr_05f_4ed4

jr_05f_4ec1:
	ld a, [wSkillUser]
	and $03
	cp $01
	jr z, jr_05f_4ece

	ld a, $01
	jr jr_05f_4ed4

jr_05f_4ece:
	ld a, $02
	jr jr_05f_4ed4

jr_05f_4ed2:
	ld a, $00

jr_05f_4ed4:
	ret


QuakeShake::
	ld a, [wScreenEffectStep]
	or a
	ret nz

	ld a, [wScreenEffectTimer]
	rst $00

QuakeShakeSteps::
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeCenter
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeCenter
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeCenter
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeCenter
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeCenter
	dw QuakeDown
	dw QuakeCenter
	dw QuakeRight
	dw QuakeEnd

QuakeDown::
	ld a, $04
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
	ld hl, wScreenEffectTimer
	inc [hl]
	ret


QuakeRight::
	ld a, $00
	ldh [hScrollY], a
	ld a, $03
	ldh [hScrollX], a
	ld hl, wScreenEffectTimer
	inc [hl]
	ret


QuakeCenter::
	xor a
	ldh [hScrollY], a
	xor a
	ldh [hScrollX], a
	ld hl, wScreenEffectTimer
	inc [hl]
	ret


QuakeEnd::
	ld a, $01
	ld [wScreenEffectStep], a
	xor a
	ldh [hScrollY], a
	xor a
	ldh [hScrollX], a
	xor a
	ld [wScreenEffectTimer], a
	ret


QuakeFlash::
	ld a, [wScreenEffectTimer]
	rst $00

QuakeFlashSteps::
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal
	dw QuakeFlashWhite
	dw QuakeFlashNormal

QuakeFlashWhite::
	ld hl, wBGP
	ld [hl], $00
	inc hl
	ld [hl], $00
	inc hl
	ld [hl], $00
	ret


QuakeFlashNormal::
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
	inc hl
	ld [hl], $e2
	ret


WaveStep::
	ld a, [wMenuStep]
	rst $00

WaveSteps::
	dw WaveStart
	dw WaveGrow
	dw WaveHold
	dw WaveEnd

WaveStart::
	ld hl, wMenuStep
	inc [hl]
	ld hl, wLineScroll
	ld b, $80

jr_05f_4fb0:
	ldh a, [hScrollX]
	ld [hli], a
	dec b
	jr nz, jr_05f_4fb0

	ld a, $01
	ld [wItemsHandedIn], a
	ld a, $02
	ldh [rLYC], a
	ld a, $02
	ld [wLCDEffect], a
	ret


WaveGrow::
	ld a, [wScreenEffectFrame]
	and $07
	jr nz, WaveSetLines

	ld a, [wItemsHandedIn]
	swap a
	and $0f
	inc a
	ld b, a
	ld a, [wItemsHandedIn]
	add b
	ld [wItemsHandedIn], a
	cp $1c
	jr c, WaveSetLines

	ld hl, wMenuStep
	inc [hl]
	xor a
	ld [wHatchSlot], a

WaveSetLines::
	ld a, [wItemsHandedIn]
	ldh [hNumber], a
	ld a, [wScreenEffectFrame]
	rra
	rra
	and $0f
	ld e, a
	ld d, $00
	ld bc, $c12e
	ld a, $66
	ldh [$ffd6], a

jr_05f_4ffe:
	inc e
	ld a, e
	and $0f
	ld e, a
	ld hl, $5025
	add hl, de
	push bc
	ld c, [hl]
	ldh a, [hNumber]
	call Multiply
	pop bc
	bit 3, e
	jr z, jr_05f_5018

	ldh a, [hScrollX]
	sub h
	jr jr_05f_501b

jr_05f_5018:
	ldh a, [hScrollX]
	add h

jr_05f_501b:
	ld [bc], a
	inc c
	ld [bc], a
	inc c
	ldh a, [$ffd6]
	cp c
	jr nz, jr_05f_4ffe

	ret


WaveOffsets_5F::
	db $00, $30, $5b, $76, $7f, $76, $5b, $30, $00, $30, $5b, $76, $7f, $76, $5b, $30

WaveHold::
	ld a, [wScreenEffectFrame]
	and $0f
	jr nz, jr_05f_504b

	ld a, [wHatchSlot]
	inc a
	ld [wHatchSlot], a
	cp $04
	jr nz, jr_05f_504b

	ld hl, wMenuStep
	inc [hl]

jr_05f_504b:
	call WaveSetLines
	ret


WaveEnd::
	ld a, $00
	ld [wLCDEffect], a
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectFrame], a
	xor a
	ld [wMenuStep], a
	xor a
	ld [wMenuSubStep], a
	xor a
	ld [wItemsHandedIn], a
	xor a
	ld [wHatchSlot], a
	ret


DarkenPalettesStep::
	xor a
	ld [wScreenEffectAux], a
	ld hl, wScreenEffectFrame
	inc [hl]
	ld b, $03
	ld c, $00
	ld hl, wBGP

jr_05f_507d:
	ld a, [hl]
	and $03
	add $01
	cp $04
	jr c, jr_05f_5088

	ld a, $03

jr_05f_5088:
	or c
	ld c, a
	ld a, [hl]
	and $0c
	add $04
	cp $0d
	jr c, jr_05f_5095

	ld a, $0c

jr_05f_5095:
	or c
	ld c, a
	ld a, [hl]
	and $30
	add $10
	cp $31
	jr c, jr_05f_50a2

	ld a, $30

jr_05f_50a2:
	or c
	ld c, a
	ld a, [hl]
	and $c0
	add $40
	cp $c1
	jr c, jr_05f_50af

	ld a, $c0

jr_05f_50af:
	or c
	ld [hli], a
	dec b
	jr nz, jr_05f_507d

	ret


LightenPalettesStep::
	xor a
	ld [wScreenEffectAux], a
	ld hl, wScreenEffectFrame
	inc [hl]
	ld b, $03
	ld c, $00
	ld hl, wBGP

jr_05f_50c4:
	ld a, [hl]
	and $03
	cp $00
	jr z, jr_05f_50cd

	sub $01

jr_05f_50cd:
	or c
	ld c, a
	ld a, [hl]
	and $0c
	cp $00
	jr z, jr_05f_50d8

	sub $04

jr_05f_50d8:
	or c
	ld c, a
	ld a, [hl]
	and $30
	cp $00
	jr z, jr_05f_50e3

	sub $10

jr_05f_50e3:
	or c
	ld c, a
	ld a, [hl]
	and $c0
	cp $00
	jr z, jr_05f_50ee

	sub $40

jr_05f_50ee:
	or c
	ld [hli], a
	dec b
	jr nz, jr_05f_50c4

	ret


GetWordEntry_5F::
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


PicSlotOffsets::
	db $c7, $00, $c4, $00, $ca, $00, $c1, $00, $cd, $00

PicTileLayouts::
	db $11, $51, $35, $51, $59, $51
	db $7d, $51

MonPicTiles0::
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d
	db $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d
	db $1e, $1f, $20, $21, $22, $23

MonPicTiles1::
	db $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d
	db $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d
	db $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47

MonPicTiles2::
	db $48, $49, $4a, $4b, $4c, $4d
	db $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d
	db $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b

MonPicTilesBlank::
	db $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0

EffectShakeX::
	ld a, [wScreenEffectStep]
	rst $00

ShakeXSteps::
	dw ShakeXLeft2
	dw ShakeXCenter
	dw ShakeXRight2
	dw ShakeXCenter
	dw ShakeXLeft4
	dw ShakeXCenter
	dw ShakeXRight4
	dw ShakeXCenter
	dw ShakeXLeft8
	dw ShakeXCenter
	dw ShakeXRight8
	dw ShakeXCenter
	dw ShakeXLeft8Down
	dw ShakeXCenter
	dw ShakeXRight8Down
	dw ShakeXCenter
	dw ShakeXLeft8Down
	dw ShakeXCenter
	dw ShakeXRight8Down
	dw ShakeXCenter
	dw ShakeXLeft8Down
	dw ShakeXCenter
	dw ShakeXRight8Down
	dw ShakeXCenter
	dw ShakeXLeft8Down
	dw ShakeXCenter
	dw ShakeXRight8Down
	dw ShakeXEnd

ShakeXCenter::
	xor a
	ldh [hScrollX], a
	ldh [hScrollY], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXLeft2::
	ld a, $fe
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXRight2::
	ld a, $02
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXLeft4::
	ld a, $fc
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXRight4::
	ld a, $04
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXLeft8::
	ld a, $f8
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXRight8::
	ld a, $08
	ldh [hScrollX], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXLeft8Down::
	ld a, $f8
	ldh [hScrollX], a
	ld a, $02
	ldh [hScrollY], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXRight8Down::
	ld a, $08
	ldh [hScrollX], a
	ld a, $02
	ldh [hScrollY], a
	ld hl, wScreenEffectStep
	inc [hl]
	ret


ShakeXEnd::
	xor a
	ldh [hScrollX], a
	ldh [hScrollY], a
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	ret


EffectBlinkUser::
	ld a, [wLinkFlags]
	ld b, a
	ld a, [wSkillUser]
	cp $07
	jr nc, BlinkUserEnd

	cp $03
	jr z, BlinkUserEnd

	bit 1, b
	jr nz, jr_05f_525f

	cp $04
	jr c, BlinkUserEnd

	jr jr_05f_5263

jr_05f_525f:
	cp $04
	jr nc, BlinkUserEnd

jr_05f_5263:
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr c, BlinkUserEnd

	ld a, [wScreenEffectStep]
	rst $00

BlinkUserSteps::
	dw BlinkUserHide
	dw BlinkUserShow
	dw BlinkUserHide
	dw BlinkUserShow
	dw BlinkUserEnd

BlinkUserHide::
	ld a, $06
	ld [wScreenEffectTimer], a
	call GetUserPicSlot
	ld hl, $50ff
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, $03
	ld hl, $5109
	call GetWordEntry_5F
	ld c, $06
	call CopyTileRectVRAM_5F
	ld hl, wScreenEffectStep
	inc [hl]
	ret


BlinkUserShow::
	ld a, $06
	ld [wScreenEffectTimer], a
	call GetUserPicSlot
	ld hl, $50ff
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
	ld a, [wSkillUser]
	and $03
	ld hl, $5109
	call GetWordEntry_5F
	ld c, $06
	call CopyTileRectVRAM_5F
	ld hl, wScreenEffectStep
	inc [hl]
	ret


BlinkUserEnd::
	ld a, $01
	ld [wBattleAnimDone], a
	xor a
	ld [wScreenEffectStep], a
	xor a
	ld [wScreenEffectTimer], a
	ret


CheckSwappedPicSkill::
	ld a, [wSkillId]
	cp $3b
	jr z, jr_05f_52e4

	cp $3c
	jr z, jr_05f_52e4

	cp $3e
	ret nz

jr_05f_52e4:
	ld a, [wBattleStep]
	cp $07
	ret nz

	ld a, [wBattleSubStep]
	cp $04
	ret


StartSkillVisual::
	ld a, [wSkillId]
	cp $15
	jp c, Jump_05f_53a4

	cp $24
	jp c, Jump_05f_5382

	cp $25
	jp c, Jump_05f_53a4

	cp $2a
	jp z, Jump_05f_53a4

	cp $37
	jr c, jr_05f_5382

	cp $3b
	jp z, Jump_05f_53be

	cp $3c
	jp z, Jump_05f_53be

	cp $3e
	jp z, Jump_05f_53be

	cp $67
	jp c, Jump_05f_53a4

	cp $6a
	jp c, Jump_05f_53be

	cp $71
	jr z, jr_05f_53a4

	cp $73
	jr c, jr_05f_5382

	cp $75
	jr c, jr_05f_53a4

	cp $77
	jr c, jr_05f_5382

	cp $78
	jr c, jr_05f_53a4

	cp $7b
	jr c, jr_05f_5382

	cp $80
	jr z, jr_05f_5382

	cp $84
	jr c, jr_05f_53a4

	cp $88
	jr c, jr_05f_5382

	cp $91
	jr c, jr_05f_53a4

	cp $95
	jr z, jr_05f_53a4

	cp $97
	jr c, jr_05f_5382

	cp $a3
	jr z, jr_05f_5382

	cp $a4
	jr c, jr_05f_53a4

	cp $a7
	jr c, jr_05f_53a4

	cp $a9
	jr z, jr_05f_53a4

	cp $ab
	jr c, jr_05f_5382

	cp $ae
	jr z, jr_05f_5382

	cp $b0
	jr c, jr_05f_53a4

	cp $c7
	jr c, jr_05f_5382

	cp $c9
	jr z, jr_05f_5382

	cp $d5
	jr c, jr_05f_53cd

	cp $d5
	jr z, jr_05f_5382

	jr jr_05f_53a4

Jump_05f_5382:
jr_05f_5382:
	ld a, [wSkillId]
	cp $80
	jp z, Jump_05f_53e9

	ld a, [wBattleStep]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [wBattleSubStep]
	cp $0a
	jr z, jr_05f_53e3

	cp $01
	jr nz, jr_05f_53e9

	ld a, [wBattleSubStep2]
	cp $0e
	jr nc, jr_05f_53e9

	ret


Jump_05f_53a4:
jr_05f_53a4:
	ld a, [wBattleStep]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [wBattleSubStep]
	cp $0a
	jr z, jr_05f_53e3

	cp $01
	jr nz, jr_05f_53e9

	ld a, [wBattleSubStep2]
	cp $05
	jr z, jr_05f_53e9

	ret


Jump_05f_53be:
	ld a, [wBattleStep]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [wBattleSubStep]
	cp $04
	jr z, jr_05f_53e9

	ret


jr_05f_53cd:
	ld a, [wBattleStep]
	cp $07
	jr nz, jr_05f_53e9

	ld a, [wBattleSubStep]
	cp $0a
	jr nz, jr_05f_53e9

	ld a, [wBattleStepArg0]
	cp $04
	jr nz, jr_05f_53e9

	ret


jr_05f_53e3:
	ld a, [wBattleStepArg0]
	cp $01
	ret z

Jump_05f_53e9:
jr_05f_53e9:
	ld a, [wSkillUser]
	cp $10
	jr z, jr_05f_5409

	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_05f_5400

	ld a, [wSkillUser]
	cp $04
	jr c, jr_05f_540d

	jr jr_05f_5412

jr_05f_5400:
	ld a, [wSkillUser]
	cp $04
	jr c, jr_05f_5412

	jr jr_05f_540d

jr_05f_5409:
	call IsTargetOwnSide
	ret c

jr_05f_540d:
	ld hl, $58dd
	jr jr_05f_5433

jr_05f_5412:
	ld hl, $59c3
	ld a, [wLinkActive]
	or a
	jr z, jr_05f_5433

	ld a, [wBattleStep]
	cp $07
	jr nz, jr_05f_5433

	ld a, [wBattleSubStep]
	cp $01
	jr nz, jr_05f_5433

	ld a, [wBattleSubStep2]
	cp $05
	jr nz, jr_05f_5433

	ld hl, $5aa9

jr_05f_5433:
	ld a, [wSkillId]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	call RunSkillVisual
	ret


RunSkillVisual::
	ld c, a
	ld b, $00
	ld hl, $58bd
	add hl, bc
	add hl, bc
	call JumpToPointer
	ret


	db $e9

SetSkillAnimPlace::
	db $fa, $8a, $db, $fe, $1a, $38, $6e, $fe, $1c, $38, $08, $fe, $29, $28, $04
	db $fe, $76, $20, $62, $cd, $8f, $5b, $38, $5d, $21, $74, $db, $fa, $63, $c8, $e6
	db $02, $cb, $3f, $ee, $01, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $53, $db, $7e
	db $fe, $01, $28, $32, $fe, $02, $28, $18, $fa, $88, $db, $e6, $03, $fe, $01, $28
	db $25, $38, $09, $fe, $03, $d2, $23, $55, $3e, $06, $18, $26, $3e, $04, $18, $22
	db $fa, $88, $db, $e6, $03, $fe, $03, $d2, $23, $55, $fe, $01, $28, $04, $3e, $02
	db $18, $10, $3e, $03, $18, $0c, $fa, $88, $db, $e6, $03, $fe, $03, $d2, $23, $55
	db $3e, $01, $ea, $54, $db, $c9, $cd, $8f, $5b, $30, $61, $21, $74, $db, $fa, $63
	db $c8, $e6, $02, $cb, $3f, $ee, $01, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $53
	db $db, $7e, $fe, $01, $28, $30, $fe, $02, $28, $17, $fa, $89, $db, $e6, $03, $fe
	db $01, $28, $23, $38, $08, $fe, $03, $30, $2d, $3e, $06, $18, $25, $3e, $04, $18
	db $21, $fa, $89, $db, $e6, $03, $fe, $01, $28, $08, $fe, $03, $30, $18, $3e, $02
	db $18, $10, $3e, $03, $18, $0c, $fa, $89, $db, $e6, $03, $fe, $03, $d2, $23, $55
	db $3e, $01, $ea, $54, $db, $c9, $3e, $08, $ea, $54, $db, $c9, $fa, $89, $db, $e6
	db $03, $fe, $03, $30, $f1, $cd, $a3, $5b, $30, $91, $21, $74, $db, $fa, $63, $c8
	db $e6, $02, $cb, $3f, $85, $6f, $3e, $00, $8c, $67, $7e, $ea, $53, $db, $7e, $fe
	db $01, $28, $33, $fe, $02, $28, $19, $fa, $88, $db, $e6, $03, $fe, $01, $28, $26
	db $38, $0a, $e6, $03, $fe, $03, $30, $be, $3e, $06, $18, $b6, $3e, $04, $18, $b2
	db $fa, $88, $db, $e6, $03, $fe, $01, $28, $09, $fe, $03, $d2, $23, $55, $3e, $02
	db $18, $a0, $3e, $03, $18, $9c, $fa, $88, $db, $e6, $03, $fe, $03, $d2, $23, $55
	db $3e, $01, $18, $8e

SkillVisualAtTarget::
	db $cd, $4e, $54, $3e, $01, $ea, $68, $dd, $18, $20

SkillVisualCenter::
	db $3e, $01
	db $ea, $54, $db, $3e, $01, $ea, $68, $dd, $18, $14

SkillVisualAtTarget2::
	db $cd, $4e, $54, $3e, $02, $ea
	db $68, $dd, $18, $0a

SkillVisualFlyIn::
	db $3e, $00, $ea, $54, $db, $3e, $00, $ea, $68, $dd

StartSkillAnimation::
	db $cd, $30
	db $56, $fe, $ff, $c8, $cd, $96, $56, $cd, $03, $31, $3e, $01, $ea, $80, $da, $c9
SkillVisualFlash::
	db $cd, $60, $4a, $3e, $04, $ea, $83, $da, $c9

SkillVisualDarken::
	db $cd, $60, $4a, $3e, $05, $ea, $83
	db $da, $c9

SkillVisualInvert::
	db $cd, $60, $4a, $3e, $06, $ea, $83, $da, $c9

SkillVisualDarkenTwice::
	db $cd, $60, $4a, $3e, $07
	db $ea, $83, $da, $c9

SkillVisualQuake::
	db $cd, $60, $4a, $3e, $08, $ea, $83, $da, $c9

SkillVisualWave::
	db $cd, $60, $4a
	db $3e, $09, $ea, $83, $da, $c9

SkillVisualLighten::
	db $cd, $60, $4a, $3e, $0a, $ea, $83, $da, $c9

SkillVisualFlashLong::
	db $cd
	db $60, $4a, $3e, $0b, $ea, $83, $da, $c9

SkillVisualShakeX::
	db $cd, $60, $4a, $3e, $0c, $ea, $83, $da
	db $c9

SkillVisualShakeY::
	db $cd, $60, $4a, $3e, $03, $ea, $83, $da, $c9

SkillVisualBlinkUser::
	db $cd, $60, $4a, $3e, $0d, $ea
	db $83, $da, $c9

GetSkillAnim::
	ld a, [wSkillUser]
	cp $10
	jr z, jr_05f_5649

	call IsUserOwnSide
	jr c, jr_05f_563e

	jr jr_05f_565f

jr_05f_563e:
	call IsTargetOwnSide
	jr nc, jr_05f_564e

	ld a, $ff
	ld [wSkillAnim], a
	ret


jr_05f_5649:
	call IsTargetOwnSide
	jr c, jr_05f_5690

jr_05f_564e:
	ld a, [wSkillId]
	ld de, $56ed
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [wSkillAnim], a
	ret


jr_05f_565f:
	ld a, [wSkillId]
	cp $1a
	jr z, jr_05f_567f

	cp $1b
	jr z, jr_05f_567f

	cp $80
	jr z, jr_05f_567f

	cp $29
	jr z, jr_05f_567f

	cp $d5
	jr z, jr_05f_567f

	cp $aa
	jr z, jr_05f_567f

	call IsTargetOwnSide
	jr c, jr_05f_5690

jr_05f_567f:
	ld a, [wSkillId]
	ld de, $57d5
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [wSkillAnim], a
	ret


jr_05f_5690:
	ld a, $ff
	ld [wSkillAnim], a
	ret


StartSkillAnimSprite::
	db $cd, $b9, $56, $fa, $a4, $da, $ea, $64, $dd, $3e, $60, $ea, $63, $dd, $3e, $00
	db $ea, $62, $dd, $21, $62, $dd, $7d, $ea, $b4, $d7, $7c, $ea, $b5, $d7, $21, $00
	db $02, $d7, $c9

GetSkillAnimSet::
	db $fa, $88, $db, $fe, $10, $28, $07, $cd, $8f, $5b, $38, $02, $18
	db $15, $cd, $a3, $5b, $d8, $fa, $8a, $db, $21, $ed, $56, $85, $6f, $3e, $00, $8c
	db $67, $7e, $ea, $a4, $da, $c9, $fa, $8a, $db, $21, $d5, $57, $85, $6f, $3e, $00
	db $8c, $67, $7e, $ea, $a4, $da, $c9

SkillAnimsOwnUser::
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $ff, $ff, $ff, $15, $15, $12, $17
	db $16, $12, $ff, $12, $12, $ff, $ff, $12, $12, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $1d, $ff, $ff, $ff, $1d, $1d, $ff, $ff, $ff, $1e, $1f, $20, $21, $25
	db $1d, $1d, $23, $24, $24, $25, $27, $ff, $ff, $ff, $ff, $ff, $1d, $ff, $1d, $09
	db $0b, $0f, $1b, $03, $04, $05, $1c, $0c, $0d, $0e, $1a, $28, $29, $2a, $15, $15
	db $15, $15, $15, $15, $15, $16, $16, $16, $ff, $17, $ff, $ff, $12, $12, $ff, $16
	db $15, $15, $ff, $ff, $ff, $ff, $ff, $2b, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $12, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $14, $ff, $ff, $ff, $15, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $14, $14, $14, $14, $14, $14, $14, $14, $14
	db $14, $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $2c, $2c, $2c, $15, $2c, $0f, $09
	db $12, $04, $0e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $02, $ff, $22, $22, $1d
	db $26, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SkillAnimsEnemyUser::
	db $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $13, $13, $ff, $ff, $13, $13, $ff
	db $ff, $13, $13, $ff, $13, $ff, $19, $19, $18, $ff, $14, $14, $14, $14, $14, $ff
	db $ff, $14, $14, $14, $14, $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $13, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $2b
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $14, $14, $ff, $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $14, $ff, $ff, $ff, $15, $12, $ff, $18, $ff, $ff, $ff, $14, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $18, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff

SkillVisualRoutines::
	db $91, $55, $9b, $55, $a7, $55, $b1, $55, $cd
	db $55, $d6, $55, $df, $55, $e8, $55, $f1, $55, $fa, $55, $03, $56, $0c, $56, $15
	db $56, $cc, $55, $1e, $56, $27, $56

SkillVisualsOwn::
	db $00, $00, $00, $03, $03, $01, $02, $02, $01
	db $02, $03, $01, $03, $02, $01, $02, $02, $01, $0d, $0d, $0d, $00, $00, $00, $00
	db $00, $00, $0d, $00, $00, $0d, $0d, $00, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $06, $0d, $0e, $0e, $0d, $0e, $00, $00, $0d, $0d, $0d, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $0d, $0d, $0d, $0d, $0d, $00, $0d, $02, $00
	db $01, $02, $02, $03, $03, $01, $01, $03, $02, $01, $01, $02, $01, $01, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $0d, $00, $04, $04, $00, $00, $0d, $00
	db $00, $00, $0d, $0d, $0d, $0d, $0d, $01, $04, $05, $05, $04, $04, $04, $04, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $0d, $05, $0d, $00, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $00, $00, $00, $02, $02
	db $00, $03, $01, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $0d, $00, $00, $00
	db $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d

SkillVisualsEnemy::
	db $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $00, $00, $0d, $0d, $00, $00, $0d, $0d, $00
	db $00, $0d, $00, $02, $00, $00, $00, $0d, $00, $00, $00, $00, $00, $0d, $0d, $00
	db $00, $00, $00, $00, $0d, $0d, $06, $0d, $0f, $0f, $0d, $0f, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $04, $04, $0d, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $01, $04, $05
	db $05, $04, $04, $04, $04, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $00, $00, $0d, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $00, $0d, $05, $0d, $00, $00, $0d, $00, $0d, $0d, $0d, $00, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $00, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d

SkillVisualsLink::
	db $0d, $0d, $0d, $0b, $0b, $0b, $04, $04, $08, $0d, $0c, $0c, $0b
	db $04, $0b, $04, $04, $08, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $06, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0a, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0c, $0a, $0d, $0b
	db $0b, $0b, $0a, $0b, $04, $0b, $0a, $06, $08, $08, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $04, $04, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $01, $04, $05, $05, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $05, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d

IsUserOwnSide::
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_05f_5b9c

	ld a, [wSkillUser]
	cp $04
	ret


jr_05f_5b9c:
	ld a, [wSkillUser]
	cp $04
	ccf
	ret


IsTargetOwnSide::
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_05f_5bb0

	ld a, [wSkillTarget]
	cp $04
	ret


jr_05f_5bb0:
	ld a, [wSkillTarget]
	cp $04
	ccf
	ret


AnimViewerInit::
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
	call DisableSTATInterrupts
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
	ld hl, far_SGBSetFieldPalettes
	rst $10
	ld a, $e0
	ld hl, wTilemapBuffer
	ld bc, $0240
	call FillMemory
	xor a
	ld hl, wBattleAnimDone
	ld bc, $0006
	call FillMemory
	ld de, $ff00
	ld hl, $9000
	ld bc, $0120
	call FillVRAMWords_5F
	ld de, $6093
	ld hl, wTilemapBuffer
	call DrawTilemap_5F
	ld de, $60fe
	ld hl, wTilemapBuffer
	call DrawTilemap_5F
	ld de, $6169
	ld hl, wTilemapBuffer
	call DrawTilemap_5F
	ld de, $2e00
	ld hl, $8d00
	call Decompress
	ld hl, $6195
	ld de, $8b90
	call DrawDebugString
	ld hl, $61ad
	ld de, $8ab0
	call DrawDebugString
	call AnimViewerDrawAnimNumber
	call AnimViewerDrawBGSwitch
	call AnimViewerDrawBGNumber
	call AnimViewerDrawEffectNumber
	ld a, $fc
	call StartFade
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld a, $01
	ld [wSkillAnimPhase], a
	ld a, $01
	ld [wItemMsgGroup], a
	ld a, $01
	ld [wBattleAnimDone], a
	ld a, $03
	ld [wMenuChoice], a
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
	xor a
	ld [wLCDEffect], a
	ld a, $03
	ld [wLCDC], a
	call EnableLYCInterrupt
	ld a, $03
	jp EnableLCDAndInterrupts


AnimViewerUpdate::
	ld a, [wScreenEffect]
	cp $09
	jr nz, jr_05f_5c9b

	ld a, [wBattleAnimDone]
	or a
	jp z, AnimViewerRunEffect

jr_05f_5c9b:
	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wBattleAnimRunning]
	or a
	jp nz, AnimViewerStepAnim

	ld a, [wMenuChoice]
	rst $00

AnimViewerRows::
	dw AnimViewerRowAnim
	dw AnimViewerRowBGSwitch
	dw AnimViewerRowBGNumber
	dw AnimViewerRowEffect

AnimViewerRowAnim::
	ld a, [wJoyPressed]
	bit 0, a
	jp nz, AnimViewerPlayAnim

	bit 1, a
	jp nz, AnimViewerExit

	bit 6, a
	jp nz, AnimViewerCursorUp

	bit 7, a
	jp nz, AnimViewerCursorDown

	bit 5, a
	jr nz, AnimViewerPrevAnim

	bit 4, a
	jr nz, AnimViewerNextAnim

	ret


AnimViewerRowBGSwitch::
	ld a, [wJoyPressed]
	bit 1, a
	jp nz, AnimViewerExit

	bit 6, a
	jp nz, AnimViewerCursorUp

	bit 7, a
	jr nz, jr_05f_5d61

	bit 5, a
	jp nz, AnimViewerToggleBG

	bit 4, a
	jp nz, AnimViewerToggleBG

	ret


AnimViewerRowBGNumber::
	ld a, [wJoyPressed]
	bit 1, a
	jp nz, AnimViewerExit

	bit 6, a
	jr nz, jr_05f_5d75

	bit 7, a
	jr nz, jr_05f_5d61

	bit 5, a
	jp nz, AnimViewerPrevBG

	bit 4, a
	jp nz, AnimViewerNextBG

	ret


AnimViewerRowEffect::
	ld a, [wBattleAnimDone]
	or a
	jr z, jr_05f_5d30

	ld a, [wJoyPressed]
	bit 0, a
	jp nz, AnimViewerPlayEffect

	bit 1, a
	jp nz, AnimViewerExit

	bit 6, a
	jr nz, jr_05f_5d75

	bit 7, a
	jr nz, jr_05f_5d61

	bit 5, a
	jp nz, AnimViewerPrevEffect

	bit 4, a
	jp nz, AnimViewerNextEffect

	ret


jr_05f_5d30:
	call AnimViewerHideCursor
	jp AnimViewerRunEffect


AnimViewerNextAnim::
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
	ld a, [wMenuChoice2]
	cp $2d
	jr c, jr_05f_5d48

	xor a
	ld [wMenuChoice2], a

jr_05f_5d48:
	call AnimViewerDrawAnimNumber
	ret


AnimViewerPrevAnim::
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	ld a, [wMenuChoice2]
	cp $2d
	jr c, jr_05f_5d48

	ld a, $2c
	ld [wMenuChoice2], a
	jr jr_05f_5d48

AnimViewerCursorDown::
jr_05f_5d61:
	ld a, [wMenuChoice]
	inc a
	ld [wMenuChoice], a
	ld a, [wMenuChoice]
	cp $04
	jr c, AnimViewerDrawCursor

	xor a
	ld [wMenuChoice], a
	jr AnimViewerDrawCursor

AnimViewerCursorUp::
jr_05f_5d75:
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
	ld a, [wMenuChoice]
	cp $04
	jr c, AnimViewerDrawCursor

	ld a, $03
	ld [wMenuChoice], a

AnimViewerDrawCursor::
	rst $00

AnimViewerCursorDraws::
	dw AnimViewerCursorRow0
	dw AnimViewerCursorRow1
	dw AnimViewerCursorRow2
	dw AnimViewerCursorRow3

AnimViewerToggleBG::
	ld a, [wConfirmChoice]
	xor $01
	ld [wConfirmChoice], a
	call AnimViewerDrawBGSwitch
	ld a, [wConfirmChoice]
	rst $00

AnimViewerBGLoaders::
	dw AnimViewerClearBG
	dw AnimViewerLoadBG

AnimViewerNextBG::
	ld a, [wConfirmChoice2]
	inc a
	ld [wConfirmChoice2], a
	ld a, [wConfirmChoice2]
	cp $d8
	jr c, jr_05f_5db6

	xor a
	ld [wConfirmChoice2], a

jr_05f_5db6:
	call AnimViewerDrawBGNumber
	ld a, [wConfirmChoice]
	or a
	ret z

	call AnimViewerLoadBG
	ret


AnimViewerPrevBG::
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
	ld a, [wConfirmChoice2]
	cp $d8
	jr c, jr_05f_5db6

	ld a, $d7
	ld [wConfirmChoice2], a
	jr jr_05f_5db6

AnimViewerPlayAnim::
	ld a, [wMenuChoice2]
	ld hl, $61ee
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, $8000
	call DecompressVRAM
	ld a, [wMenuChoice2]
	ld [wPaletteSet], a
	ld hl, far_LoadObjPaletteB
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, [wMenuChoice2]
	ld [wSkillAnimSet], a
	ld a, [wMenuChoice2]
	ld [wSkillAnim], a
	ld a, [wSkillAnimSet]
	ld [wBattleAnimIndex], a
	ld a, $60
	ld [wBattleAnimSet], a
	ld a, $00
	ld [wBattleAnimRunning], a
	ld hl, wBattleAnimRunning
	ld a, l
	ld [wPlayerAnimPtr], a
	ld a, h
	ld [$d7b5], a
	ld hl, far_StepAnimation
	rst $10
	call AnimViewerStartSprite

AnimViewerHideCursor::
	ld hl, $c6cd
	call PutBlank
	call PutBlank
	call PutBlank
	ld hl, $c56d
	call PutBlank
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


AnimViewerExit::
	ld a, $04
	call StartFade
	ld a, $07
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


AnimViewerNextEffect::
	ld a, [wListLastRows]
	inc a
	ld [wListLastRows], a
	ld a, [wListLastRows]
	cp $0d
	jr c, jr_05f_5e6e

	xor a
	ld [wListLastRows], a

jr_05f_5e6e:
	call AnimViewerDrawEffectNumber
	ret


AnimViewerPrevEffect::
	ld a, [wListLastRows]
	dec a
	ld [wListLastRows], a
	ld a, [wListLastRows]
	cp $0d
	jr c, jr_05f_5e6e

	ld a, $0c
	ld [wListLastRows], a
	jr jr_05f_5e6e

AnimViewerPlayEffect::
	ld a, $04
	ld [wSkillTarget], a
	ld a, $01
	ld [wEnemyCount], a
	xor a
	ld hl, wBattleAnimDone
	ld bc, $0006
	call FillMemory
	ld a, [wListLastRows]
	ld [wScreenEffect], a
	jr AnimViewerHideCursor

AnimViewerStepAnim::
	ld a, [wBattleAnimRunning]
	or a
	jr z, jr_05f_5eb5

	call AnimViewerDrawSprite
	ld hl, far_StepAnimation
	rst $10
	ld a, [wBattleAnimRunning]
	or a
	ret nz

jr_05f_5eb5:
	ld a, [wMenuChoice]
	rst $00

AnimViewerCursorRedraws::
	dw AnimViewerCursorRow0
	dw AnimViewerCursorRow1
	dw AnimViewerCursorRow2
	dw AnimViewerCursorRow3

AnimViewerRunEffect::
	ld hl, far_UpdateScreenEffect
	rst $10
	ld a, [wBattleAnimDone]
	or a
	ret z

	jr AnimViewerCursorRow3

FillVRAMWords_5F::
	di
	call WaitVRAMAccess
	ld a, d
	ld [hli], a
	ei
	di
	call WaitVRAMAccess
	ld a, e
	ld [hli], a
	ei
	dec bc
	ld a, b
	or c
	jr nz, FillVRAMWords_5F

	ret


AnimViewerCursorRow0::
	ld hl, $c6cd
	call PutArrow
	call PutBlankTwice
	ld hl, $c56d
	call PutBlank
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


AnimViewerCursorRow1::
	ld hl, $c6cd
	call PutBlank
	call PutArrow
	call PutBlank
	ld hl, $c56d
	call PutBlank
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


AnimViewerCursorRow2::
	ld hl, $c6cd
	call PutBlankTwice
	call PutArrow
	ld hl, $c56d
	call PutBlank
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


AnimViewerCursorRow3::
	ld hl, $c6cd
	call PutBlank
	call PutBlankTwice
	ld hl, $c56d
	call PutArrow
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


PutBlankTwice::
	call PutBlank

PutBlank::
	di
	call WaitVRAMAccess
	ld a, $e0
	ld [hl], a
	ei
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ret


PutArrow::
	di
	call WaitVRAMAccess
	ld a, $e8
	ld [hl], a
	ei
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ret


DrawDebugString::
	ld a, [hli]
	cp $ff
	ret z

	push hl
	push de
	ld hl, wTextArg0
	push de
	call CopyGlyph
	pop de
	ld hl, wTextArg0
	call CopyTileVRAM_5F
	pop de
	pop hl
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	jr DrawDebugString

CopyTileVRAM_5F::
	ld b, $10

jr_05f_5f7a:
	di
	call WaitVRAMAccess
	ld a, [hli]
	ld [de], a
	ei
	inc de
	dec b
	jr nz, jr_05f_5f7a

	ret


AnimViewerDrawAnimNumber::
	ld hl, wMenuChoice3
	ld a, [wMenuChoice2]
	and $f0
	call HighNibble_5F
	ld [hli], a
	ld a, [wMenuChoice2]
	and $0f
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld de, $8b40
	ld hl, wMenuChoice3
	call DrawDebugString
	ret


AnimViewerDrawBGSwitch::
	ld hl, $61b5
	ld a, [wConfirmChoice]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, $8b60
	call DrawDebugString
	ret


AnimViewerDrawBGNumber::
	ld hl, wMenuChoice3
	ld a, [wConfirmChoice2]
	and $f0
	call HighNibble_5F
	ld [hli], a
	ld a, [wConfirmChoice2]
	and $0f
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld de, $8b20
	ld hl, wMenuChoice3
	call DrawDebugString
	ret


AnimViewerDrawEffectNumber::
	ld hl, wMenuChoice3
	ld a, [wListLastRows]
	and $f0
	call HighNibble_5F
	ld [hli], a
	ld a, [wListLastRows]
	and $0f
	ld [hli], a
	ld a, $ff
	ld [hl], a
	ld de, $8a90
	ld hl, wMenuChoice3
	call DrawDebugString
	ret


AnimViewerDrawSprite::
	ld a, [wMenuChoice2]
	cp $0e
	jr c, jr_05f_600a

	cp $21
	jr c, jr_05f_600f

	ld hl, far_DrawSkillAnimSprite_5E
	rst $10
	ret


jr_05f_600a:
	ld hl, far_DrawSkillAnimSprite_5C
	rst $10
	ret


jr_05f_600f:
	ld hl, far_DrawSkillAnimSprite_5D
	rst $10
	ret


AnimViewerStartSprite::
	ld hl, wBGP
	inc hl
	ld a, $d0
	ld [hli], a
	ld a, $e0
	ld [hl], a
	ld hl, $61c1
	ld a, [wMenuChoice2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wOBP0], a
	ld a, [wMenuChoice2]
	cp $03
	jr z, jr_05f_6049

	cp $04
	jr z, jr_05f_6049

	cp $0a
	jr z, jr_05f_6049

	ld a, $01
	ld [wSkillAnimPhase], a
	ld a, $01
	ld [wItemMsgGroup], a
	jr jr_05f_6053

jr_05f_6049:
	ld a, $00
	ld [wSkillAnimPhase], a
	ld a, $00
	ld [wItemMsgGroup], a

jr_05f_6053:
	ld a, [wMenuChoice2]
	cp $0e
	jr c, jr_05f_6063

	cp $21
	jr c, jr_05f_6068

	ld hl, far_StartSkillAnimSprite_5E
	rst $10
	ret


jr_05f_6063:
	ld hl, far_StartSkillAnimSprite_5C
	rst $10
	ret


jr_05f_6068:
	ld hl, far_StartSkillAnimSprite_5D
	rst $10
	ret


AnimViewerClearBG::
	ld de, $ff00
	ld hl, $9000
	ld bc, $0120
	call FillVRAMWords_5F
	ret


AnimViewerLoadBG::
	ld a, [wConfirmChoice2]
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
	ld hl, $9000
	call DecompressVRAM
	ret


AnimViewerMenuTilemap::
	db $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $c4, $c5, $c6, $e0, $c7
	db $c8, $e0, $e0, $e0, $e0, $b4, $b5, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $c9, $ca, $cb, $cc, $cd, $ce, $cf, $e0, $e0, $e0, $b6, $b7, $b8, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $b2
	db $b3, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

AnimViewerTitleTilemap::
	db $00, $00, $fa, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $e0, $e0, $b9, $ba, $bb, $bc, $bd, $be, $e0, $bf, $c0, $c1
	db $c2, $c3, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $ab, $ac, $ad, $ae, $af, $e0, $b0, $b1, $e0, $e8, $a9, $aa, $e0, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

AnimViewerPicTilemap::
	db $c7, $00, $00, $01, $02, $03, $04, $05, $d8, $06
	db $07, $08, $09, $0a, $0b, $d8, $0c, $0d, $0e, $0f, $10, $11, $d8, $12, $13, $14
	db $15, $16, $17, $d8, $18, $19, $1a, $1b, $1c, $1d, $d8, $1e, $1f, $20, $21, $22
	db $23, $d9

AnimViewerLabels::
	db $0b, $0a, $1d, $1d, $15, $0e, $0e, $0f, $0e, $0c, $1d, $18, $0b, $13
	db $17, $18, $16, $18, $17, $1c, $1d, $0e, $1b, $ff

AnimViewerLabels2::
	db $0e, $0f, $0e, $0c, $1d, $17
	db $18, $ff

AnimViewerOnOff::
	db $b9, $61, $bd, $61

AnimViewerOffText::
	db $18, $0f, $0f, $ff

AnimViewerOnText::
	db $18, $17, $90, $ff

AnimViewerOBP0::
	db $e0, $e0
	db $e0, $e0, $e0, $e0, $d0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $d0, $d0, $e0, $e0, $e0, $e0, $e0, $d0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $d0

AnimViewerSpriteGfx::
	db $00, $5a, $01, $5a, $02
	db $5a, $03, $5a, $04, $5a, $05, $5a, $06, $5a, $07, $5a, $08, $5a, $09, $5a, $0a
	db $5a, $0b, $5a, $0c, $5a, $0d, $5a, $0e, $5a, $0f, $5a, $10, $5a, $11, $5a, $12
	db $5a, $13, $5a, $14, $5a, $15, $5a, $16, $5a, $17, $5a, $18, $5a, $19, $5a, $1a
	db $5a, $1b, $5a, $1c, $5a, $1d, $5a, $1e, $5a, $1f, $5a, $0a, $5b, $0b, $5b, $0c
	db $5b, $0d, $5b, $0e, $5b, $0f, $5b, $10, $5b, $11, $5b, $12, $5b, $13, $5b, $14
	db $5b, $15, $5b, $16, $5b

HighNibble_5F::
	srl a
	srl a
	srl a
	srl a
	ret


DebugStatsWindow::
	ld a, [wMenuChoice]
	bit 7, a
	ret nz

	ld a, [wDebugStatsShown]
	or a
	jr nz, jr_05f_62d7

	ld a, [wJoyPressed]
	bit 2, a
	ret z

	ld a, $01
	ld [wDebugStatsShown], a
	ld hl, $6452
	ld de, $8860
	call DrawDebugString
	ld de, $63b0
	ld hl, wTilemapBuffer
	call DrawTilemap_5F
	ld a, [wLinkFlags]
	and $02
	rlca
	ld [wBattleArg0], a
	inc a
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wBattleArg1], a
	ld a, h
	ld [wBattleArg2], a
	call DrawDebugStatsLine
	ld a, [wBattleArg1]
	ld l, a
	ld a, [wBattleArg2]
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_05f_62d2

	inc hl
	ld a, l
	ld [wBattleArg1], a
	ld a, h
	ld [wBattleArg2], a
	ld hl, wBattleArg0
	inc [hl]
	call DrawDebugStatsLine
	ld a, [wBattleArg1]
	ld l, a
	ld a, [wBattleArg2]
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_05f_62d2

	inc hl
	ld a, l
	ld [wBattleArg1], a
	ld a, h
	ld [wBattleArg2], a
	ld hl, wBattleArg0
	inc [hl]
	call DrawDebugStatsLine

jr_05f_62d2:
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ret


jr_05f_62d7:
	ld a, [wJoyPressed]
	bit 2, a
	ret z

	xor a
	ld [wDebugStatsShown], a
	ld [wCommandStep], a
	ret


DrawDebugStatsLine::
	call ClearDebugDigits
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call SplitDecimal_5F
	ld hl, $643a
	call DrawDebugNumber
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call SplitDecimal_5F
	ld hl, $6440
	call DrawDebugNumber
	ld a, [wBattleArg0]
	ld hl, wBattlerStat67
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call SplitDecimal_5F
	ld hl, $6446
	call DrawDebugNumber
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call SplitDecimal_5F
	ld hl, $644c
	call DrawDebugNumber
	ret


ClearDebugDigits::
	xor a
	ld hl, wBattleArg3
	ld bc, $0003
	call FillMemory
	ret


SplitDecimal_5F::
	ld b, [hl]
	ld a, $64
	call Divide8
	ld hl, wBattleArg3
	ld [hl], b
	ld b, a
	ld a, $0a
	call Divide8
	ld hl, wNamePos
	ld [hl], b
	ld [$db51], a
	ret


DrawDebugNumber::
	ld a, [wBattleArg0]
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
	ld de, wTilemapBuffer
	add hl, de
	ld c, $00
	ld a, [wBattleArg3]
	or c
	jr z, jr_05f_638a

	inc c
	ld a, [wBattleArg3]
	ld de, $6430
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a

jr_05f_638a:
	inc hl
	ld a, [wNamePos]
	or c
	jr z, jr_05f_63a0

	inc c
	ld a, [wNamePos]
	ld de, $6430
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a

jr_05f_63a0:
	inc hl
	ld a, [$db51]
	ld de, $6430
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ret


DebugStatsTilemap::
	db $80, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $86, $e0, $e0
	db $e0, $e0, $e0, $86, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $87, $e0, $e0, $e0, $e0, $e0, $87, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $88, $e0, $e0, $e0, $e0, $e0, $88, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $89, $e0, $e0, $e0
	db $e0, $e0, $89, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
DebugDigitTiles::
	db $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9

DebugStatsPos1::
	db $a2, $01, $a8, $01, $ae, $01
DebugStatsPos2::
	db $c2, $01, $c8, $01, $ce, $01

DebugStatsPos3::
	db $e2, $01, $e8, $01, $ee, $01

DebugStatsPos4::
	db $02, $02, $08, $02
	db $0e, $02

DebugStatsLabels::
	db $4a, $28, $2f, $48, $ff

OpeningLogo2Tilemap::
	db $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $02, $03, $04, $05, $d8, $00, $00, $00, $00, $00, $00, $00, $06
	db $07, $08, $09, $0a, $0b, $0c, $d8, $00, $00, $00, $00, $00, $00, $0d, $0e, $0f
	db $10, $11, $12, $13, $14, $d8, $00, $00, $00, $00, $00, $00, $15, $16, $17, $18
	db $19, $1a, $1b, $1c, $d8, $00, $00, $00, $00, $00, $1d, $1e, $1f, $20, $21, $22
	db $23, $24, $25, $26, $d8, $00, $00, $00, $00, $00, $27, $28, $29, $2a, $2b, $2c
	db $2d, $2e, $2f, $30, $d8, $00, $00, $00, $00, $00, $00, $31, $32, $33, $34, $35
	db $36, $00, $38, $d8, $00, $00, $00, $00, $00, $00, $39, $3a, $3b, $3c, $3d, $3e
	db $3f, $40, $d8, $00, $00, $00, $00, $00, $00, $41, $42, $43, $44, $45, $46, $47
	db $48, $d8, $00, $00, $00, $00, $00, $00, $49, $4a, $4b, $4c, $4d, $4e, $4f, $37
	db $d9

OpeningPictureTilemap::
	db $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $d8, $00, $6a, $6b, $6c, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $6d, $6e, $6f, $00, $d8, $00, $70, $71, $72, $73, $74
	db $75, $76, $77, $00, $00, $00, $78, $79, $7a, $7b, $7c, $7d, $7e, $00, $d8, $00
	db $00, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d
	db $8e, $8f, $00, $d8, $00, $00, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99
	db $9a, $9b, $9c, $9d, $9e, $9f, $a0, $00, $d8, $00, $00, $a1, $a2, $a3, $a4, $61
	db $62, $63, $64, $65, $66, $67, $68, $69, $ae, $af, $be, $00, $00, $d8, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $d9

OpeningTitleTilemap::
	db $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $d8, $00, $6a, $6b, $6c, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $6d, $6e, $6f, $00, $d8, $00, $70
	db $71, $72, $73, $74, $75, $76, $77, $00, $00, $00, $78, $79, $7a, $7b, $7c, $7d
	db $7e, $00, $d8, $00, $00, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89
	db $8a, $8b, $8c, $8d, $8e, $8f, $00, $d8, $00, $00, $90, $91, $92, $93, $94, $95
	db $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $a0, $00, $d8, $00, $00, $a1
	db $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $be, $00
	db $00, $d8, $00, $00, $00, $00, $00, $00, $bf, $cd, $ce, $cf, $d0, $d1, $d2, $d3
	db $d4, $00, $00, $00, $c0, $00, $d8, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $d8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $d8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $d8, $00, $00, $00, $ba, $bb, $bc, $bd, $b0, $b1, $b2, $b3, $b4
	db $b5, $b6, $b7, $b8, $b9, $00, $00, $00, $d8, $00, $00, $00, $00, $c1, $c2, $c3
	db $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $00, $00, $00, $00, $d9

OpeningLogo1Tilemap::
	db $03, $01
	db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $d8, $0f
	db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $d8, $1d, $1e
	db $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $d9

OpeningLogo0Tilemap::
	db $00, $01, $00
	db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10
	db $11, $12, $d9

CreditsTilemap::
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $00, $01, $02, $03
	db $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $e0
	db $e0, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22
	db $23, $24, $25, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $26, $27, $28, $29, $2a, $2b, $2c
	db $2d, $2e, $2f, $30, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $31, $32, $33
	db $34, $35, $36, $37, $38, $39, $3a, $3b, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50
	db $51, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $52, $53, $54, $55, $56, $57, $58
	db $59, $5a, $5b, $5c, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $5d, $5e
	db $5f, $60, $61, $62, $63, $64, $65, $66, $67, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f, $70, $71, $72, $aa, $ab, $ac, $ad
	db $ae, $af, $e0, $e0, $e0, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $e0, $e0
	db $b0, $b1, $b2, $b3, $b4, $b5, $e0, $e0, $e0, $7e, $7f, $80, $81, $82, $83, $84
	db $85, $86, $87, $88, $b6, $b7, $b8, $b9, $ba, $bb, $e0, $e0, $e0, $e0, $89, $8a
	db $8b, $8c, $8d, $8e, $8f, $90, $91, $92, $bc, $bd, $be, $bf, $c0, $c1, $e0, $e0
	db $e0, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $c2, $c3, $c4, $c5
	db $c6, $c7, $e0, $e0, $e0, $e0, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $e0
	db $c8, $c9, $ca, $cb, $cc, $cd, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0

CreditsLastTilemap::
	db $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b
	db $0c, $0d, $0e, $0f, $10, $11, $12, $e0, $e0, $14, $e0, $15, $16, $17, $18, $19
	db $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $24, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31
	db $32, $33, $34, $35, $36, $37, $38, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $3c, $3d, $3e, $3f
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d
	db $5e, $5f, $60, $61, $62, $63, $64

UnusedSpace_5F::
	db $e0, $e0, $68, $69, $6a, $6b, $6c, $6d, $6e
	db $6f, $70, $71, $72, $aa, $ab, $ac, $ad, $ae, $af, $e0, $e0, $e0, $e0, $e0, $73
	db $74, $75, $76, $77, $78, $79, $7a, $7b, $b0, $b1, $b2, $b3, $b4, $b5, $e0, $e0
	db $e0, $7e, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $b6, $b7, $b8, $b9
	db $ba, $bb, $e0, $e0, $e0, $e0, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
	db $bc, $bd, $be, $bf, $c0, $c1, $e0, $e0, $e0, $94, $95, $96, $97, $98, $99, $9a
	db $9b, $9c, $9d, $9e, $c2, $c3, $c4, $c5, $c6, $c7, $e0, $e0, $e0, $e0, $e0, $9f
	db $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $c8, $c9, $ca, $cb, $cc, $cd, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
