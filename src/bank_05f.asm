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
;@ window with the battlers' personality numbers.
FarTable_5F::
	dw EndingInit
	dw EndingUpdate
	dw OpeningInit
	dw OpeningUpdate
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


;@ def CopyTileRect_5F(src: de, dest: hl, width: b, height: c)
;@ path: gfx/tilemap
;@ Copies a `width` x `height` block of tile numbers (stored row after row) into a BG map at
;@ `dest`, each byte written when VRAM is accessible.
;@ test: skip polls the LCD
CopyTileRect_5F::
;>@rows for y in range(height):
;>     rowstart = dest
	push bc
	push hl

.column
;>     for x in range(width):
;>         WriteVRAM(mem[src + x], dest + x)
	ld a, [de]
	call WriteVRAM
	inc hl
	inc de
	dec b
	jr nz, .column

;>     src += width                         # (moved along while copying)
	pop hl
	pop bc
;>     dest = u16(rowstart + 32)            # next BG map row
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@rows
	dec c
	jr nz, CopyTileRect_5F

;> return
	ret


;@ def DrawTilemap_5F(src: de, dest: hl)
;@ path: gfx/tilemap
;@ Draws a tilemap into a BG map (or a buffer). Format: a 2-byte offset added to dest, then
;@ tile numbers; $D8 goes to the start of the next row (32 tiles on), $D9 ends the map.
;@ test: skip pointer-driven loop over map data
DrawTilemap_5F::
;> offset = mem16[src]; src += 2
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
;> dest += offset
	add hl, bc
;> wSceneObjectPtr = dest                  # start of the current row
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a

;> while True:
.loop
;>     t = mem[src]; src += 1
	ld a, [de]
	inc de
;>     if t == 0xD8:
	cp $d8
	jr z, .newRow

;>@row1         dest = wSceneObjectPtr
;>@row2         dest += 0x20
;>@row3         wSceneObjectPtr = dest
;>     elif t == 0xD9:
	cp $d9
;>         return
	ret z

;>     else:
;>         mem[dest] = t; dest += 1
	ld [hli], a
	jr .loop

.newRow
;=@row1
	ld a, [wSceneObjectPtr]
	ld l, a
	ld a, [wSceneObjectPtr + 1]
	ld h, a
;=@row2
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@row3
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a
	jr .loop

;@ def DrawTilemapVRAM_5F(src: de, dest: hl)
;@ path: gfx/tilemap
;@ DrawTilemap_5F for a BG map in VRAM while the screen is on: every tile is written when VRAM
;@ is accessible (WriteVRAMInc).
;@ test: skip polls the LCD
DrawTilemapVRAM_5F::
;> offset = mem16[src]; src += 2
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
;> dest += offset
	add hl, bc
;> wSceneObjectPtr = dest                  # start of the current row
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a

;> while True:
.loop
;>     t = mem[src]; src += 1
	ld a, [de]
	inc de
;>     if t == 0xD8:
	cp $d8
	jr z, .newRow

;>@row1         dest = wSceneObjectPtr
;>@row2         dest += 0x20
;>@row3         wSceneObjectPtr = dest
;>     elif t == 0xD9:
	cp $d9
;>         return
	ret z

;>     else:
;>         dest = WriteVRAMInc(t, dest)
	call WriteVRAMInc
	jr .loop

.newRow
;=@row1
	ld a, [wSceneObjectPtr]
	ld l, a
	ld a, [wSceneObjectPtr + 1]
	ld h, a
;=@row2
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@row3
	ld a, l
	ld [wSceneObjectPtr], a
	ld a, h
	ld [wSceneObjectPtr + 1], a
	jr .loop

;@ path: event/ending
;@ The text box of the closing screen: 20 x 4 tile numbers for CopyTileRect_5F (frame tiles
;@ $EE/$EF/$FA-$FF, blank $E0, letters from tile $B0 on).
;@ asset: tilemap width=20 height=4
EndingSaveBoxTilemap::
	db $e0, $e0, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $e0, $e0, $fe, $b0, $b1, $b2, $e0, $b3, $b4, $e0, $b5, $b6
	db $b7, $b8, $b9, $ba, $bb, $bc, $bd, $ff, $e0, $e0, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $e0, $e0, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd

;@ def PrintCreditsHeading()
;@ path: event/ending
;@ Prints text wTextGroup / wTextIndex of bank $4C (2 lines of 20 letters) into the tiles at
;@ $8000, the top of a credits page. The text box settings are put back afterwards, but
;@ wrongly: the saved line count lands in the high byte of wTextTiles and the line length in
;@ wTextBoxLines.
;@ test: skip calls a routine in another bank
PrintCreditsHeading::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines, saved_length = wTextBoxLines, wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x8000
	ld hl, $8000
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 2
	ld de, $1402
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 20
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_4C()
	ld hl, $4c02
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> mem[0xC828] = saved_lines               # (meant for wTextBoxLines)
	ld a, e
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_length            # (meant for wTextBoxLineLength)
	ld a, d
	ld [wTextBoxLines], a
	ret


;@ def PrintCreditsBody()
;@ path: event/ending
;@ Prints text wTextGroup / wTextIndex of bank $4C (12 lines of 11 letters) into the tiles from
;@ $8260 on, the names of a credits page; the settings are put back with the same mix-up as
;@ in PrintCreditsHeading.
;@ test: skip calls a routine in another bank
PrintCreditsBody::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_lines, saved_length = wTextBoxLines, wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x8260
	ld hl, $8260
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 12
	ld de, $0b0c
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 11
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_4C()
	ld hl, $4c02
	rst $10
;> wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> mem[0xC828] = saved_lines               # (meant for wTextBoxLines)
	ld a, e
	ld [wTextTiles + 1], a
;> wTextBoxLines = saved_length            # (meant for wTextBoxLineLength)
	ld a, d
	ld [wTextBoxLines], a
	ret


;@ def PrintCreditsPage()
;@ path: event/ending
;@ Prints the text of credits page wSceneObjects[1]: its heading (text group 5 of bank $4C)
;@ and its names (text group 6).
;@ test: skip calls a routine in another bank
PrintCreditsPage::
;> wTextIndex = wSceneObjects[1]
	ld a, [wSceneObjects + 1]
	ld [wTextIndex], a
;> wTextGroup = 5
	ld a, $05
	ld [wTextGroup], a
;> PrintCreditsHeading()
	call PrintCreditsHeading
;> wTextIndex = wSceneObjects[1]
	ld a, [wSceneObjects + 1]
	ld [wTextIndex], a
;> wTextGroup = 6
	ld a, $06
	ld [wTextGroup], a
;> PrintCreditsBody()
	call PrintCreditsBody
	ret


;@ def LoadCreditsMonster()
;@ path: event/ending
;@ Loads the monster of credits page wSceneObjects[1] (CreditsMonsters): its picture into the
;@ tiles at $8AA0 and, on a Game Boy Color, its colours into BG palette 4 for the picture at
;@ row 11, column 13.
;@ test: skip calls routines in other banks
LoadCreditsMonster::
;> page = wSceneObjects[1]
	ld a, [wSceneObjects + 1]
;> p = CreditsMonsters + page
	ld hl, CreditsMonsters
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> species = mem[p]
	ld a, [hl]
;> if species == 0xFF:
;>     return
	cp $ff
	ret z

;> wSceneObjects[6] = species; wPaletteSet = species
	ld [wSceneObjects + 6], a
	ld [wPaletteSet], a
;> wMonPicPalette = 4
	ld a, $04
	ld [wMonPicPalette], a
;> wMonPicPos = 0x016D                     # row 11, column 13
	ld hl, $016d
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [wMonPicPos + 1], a
;> wSceneObjects[4] = 0xA0; wSceneObjects[5] = 0x8A   # picture tiles at $8AA0
	ld hl, $8aa0
	ld a, l
	ld [wSceneObjects + 4], a
	ld a, h
	ld [wSceneObjects + 5], a
;> LoadMonsterPicFar()
	ld hl, far_LoadMonsterPicFar
	rst $10
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
	ret


;@ path: event/ending
;@ Monster (species number) shown on each of the 27 credits pages; $FF would show none.
CreditsMonsters::
	db $6d, $13, $59, $49, $42, $0a, $a4, $1b, $81, $84, $c7, $95, $96, $97, $44, $7f
	db $c2, $91, $9a, $2c, $6d, $13, $59, $49, $42, $0a, $08

;@ def DrawCreditsLastPage()
;@ path: event/ending
;@ Draws the screen layout of the last credits page (CreditsLastTilemap, 20 x 11 tiles) at the
;@ top of the BG map.
;@ test: skip polls the LCD
DrawCreditsLastPage::
;> CopyTileRect_5F(CreditsLastTilemap, 0x9800, 20, 11)
	ld de, CreditsLastTilemap
	ld hl, $9800
	ld bc, $140b
	call CopyTileRect_5F
	ret


;@ def OpeningInit()
;@ path: title/opening
;@ Sets up the screen of opening scene wOpeningScene (with the screen off): 0 the three logo
;@ screens, 1-3 and 5 the shooting stars on black, 4 the picture, 6 the title screen.
;@ test: skip runs the scenes through a jump table
OpeningInit::
;> OpeningInitScenes[wOpeningScene]()
	ld a, [wOpeningScene]
	rst $00

;@ path: title/opening
;@ Set-up routine of each opening scene (wOpeningScene 0-6).
OpeningInitScenes::
	dw OpeningInitLogos
	dw OpeningInitStarScene
	dw OpeningInitStarScene
	dw OpeningInitStarScene
	dw OpeningInitPicture
	dw OpeningInitStarScene
	dw OpeningInitTitle

;@ def OpeningInitLogos()
;@ path: title/opening
;@ Scene 0: sets up logo screen wOpeningLogo (0-2).
;@ test: skip runs the logos through a jump table
OpeningInitLogos::
;> OpeningInitLogoTable[wOpeningLogo]()
	ld a, [wOpeningLogo]
	rst $00

;@ path: title/opening
;@ Set-up routine of each logo screen; the byte after the table is a spare `ret`.
OpeningInitLogoTable::
	dw OpeningInitLogo0
	dw OpeningInitLogo1
	dw OpeningInitLogo2
	db $c9

;@ def OpeningInitLogo0()
;@ path: title/opening
;@ First logo screen: Super Game Boy border 2, logo tiles (compressed entry 56:0E) at $9000,
;@ OpeningLogo0Tilemap, palette set 0 and on a Game Boy Color the attribute map 3F:00.
;@ test: skip calls routines in other banks
OpeningInitLogo0::
;> LoadSGBBorder(2)
	ld a, $02
	call LoadSGBBorder
;> SGBPacketDelay()
	call SGBPacketDelay
;> fill(0x9800, 0, 0x400)
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> Decompress(0x56, 0x0E, 0x9000)
	ld de, $560e
	ld hl, $9000
	call Decompress
;> DrawTilemap_5F(OpeningLogo0Tilemap, 0x9800)
	ld de, OpeningLogo0Tilemap
	ld hl, $9800
	call DrawTilemap_5F
;> wPaletteSet = 0
	ld a, $00
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F, 0x00, 0x9800)      # attribute map
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret


;@ def OpeningInitLogo1()
;@ path: title/opening
;@ Second logo screen: like the first with tiles 56:0C and OpeningLogo1Tilemap.
;@ test: skip calls routines in other banks
OpeningInitLogo1::
;> LoadSGBBorder(2)
	ld a, $02
	call LoadSGBBorder
;> SGBPacketDelay()
	call SGBPacketDelay
;> fill(0x9800, 0, 0x400)
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> Decompress(0x56, 0x0C, 0x9000)
	ld de, $560c
	ld hl, $9000
	call Decompress
;> DrawTilemap_5F(OpeningLogo1Tilemap, 0x9800)
	ld de, OpeningLogo1Tilemap
	ld hl, $9800
	call DrawTilemap_5F
;> wPaletteSet = 0
	ld a, $00
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F, 0x00, 0x9800)      # attribute map
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret


;@ def OpeningInitLogo2()
;@ path: title/opening
;@ Third logo screen: like the first with tiles 5B:1F and OpeningLogo2Tilemap.
;@ test: skip calls routines in other banks
OpeningInitLogo2::
;> LoadSGBBorder(2)
	ld a, $02
	call LoadSGBBorder
;> SGBPacketDelay()
	call SGBPacketDelay
;> fill(0x9800, 0, 0x400)
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> Decompress(0x5B, 0x1F, 0x9000)
	ld de, $5b1f
	ld hl, $9000
	call Decompress
;> DrawTilemap_5F(OpeningLogo2Tilemap, 0x9800)
	ld de, OpeningLogo2Tilemap
	ld hl, $9800
	call DrawTilemap_5F
;> wPaletteSet = 0
	ld a, $00
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f00
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F, 0x00, 0x9800)      # attribute map
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret


;@ def OpeningInitStarScene()
;@ path: title/opening
;@ Scenes 1-3 and 5: an all-black background (tile 0 made solid colour 3) with the shooting
;@ star and sparkle sprites (tiles 5B:18 at $8000 and 5B:19 at $8040).
;@ test: skip calls routines in other banks
OpeningInitStarScene::
;> fill(0x9800, 0, 0x400)
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
;> fill(0x9000, 0xFF, 16)                  # tile 0: black
	ld a, $ff
	ld hl, $9000
	ld bc, $0010
	call FillMemory
;> DecompressVRAM(0x5B, 0x18, 0x8000)
	ld de, $5b18
	ld hl, $8000
	call DecompressVRAM
;> DecompressVRAM(0x5B, 0x19, 0x8040)
	ld de, $5b19
	ld hl, $8040
	call DecompressVRAM
;> wPaletteSet = 0
	ld a, $00
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> wPaletteSet = 0
	ld a, $00
	ld [wPaletteSet], a
;> LoadObjPaletteA()
	ld hl, $170c
	rst $10
;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
	xor a
	ld hl, $9800
	ld bc, $0400
	ld a, [wOnCGB]
	or a
;>     fill(0x9800, 0, 0x400)              # attribute map: palette 0
	ld a, $00
	call nz, FillMemory
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret


;@ def OpeningInitPicture()
;@ path: title/opening
;@ Scene 4: the picture between the shooting stars (tiles 5B:20 at $9000 and 5B:21 at $8800,
;@ OpeningPictureTilemap, palette set 1, attribute map 3F:02).
;@ test: skip calls routines in other banks
OpeningInitPicture::
;> fill(0x9800, 0, 0x400)
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> Decompress(0x5B, 0x20, 0x9000)
	ld de, $5b20
	ld hl, $9000
	call Decompress
;> Decompress(0x5B, 0x21, 0x8800)
	ld de, $5b21
	ld hl, $8800
	call Decompress
;> DrawTilemap_5F(OpeningPictureTilemap, 0x9800)
	ld de, OpeningPictureTilemap
	ld hl, $9800
	call DrawTilemap_5F
;> wPaletteSet = 1
	ld a, $01
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld de, $3f02
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
;>     Decompress(0x3F, 0x02, 0x9800)      # attribute map
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	call nz, Decompress
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret


;@ def OpeningInitTitle()
;@ path: title/opening
;@ Scene 6: the title screen (the picture's tiles, OpeningTitleTilemap, every tile on CGB
;@ palette 5) with the title song $06.
;@ test: skip calls routines in other banks
OpeningInitTitle::
;> fill(0x9800, 0, 0x400)
	xor a
	ld hl, $9800
	ld bc, $0400
	call FillMemory
;> fill(wSceneObjects, 0, 40)
	xor a
	ld hl, wSceneObjects
	ld bc, $0028
	call FillMemory
;> DecompressVRAM(0x5B, 0x20, 0x9000)
	ld de, $5b20
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x5B, 0x21, 0x8800)
	ld de, $5b21
	ld hl, $8800
	call DecompressVRAM
;> DrawTilemap_5F(OpeningTitleTilemap, 0x9800)
	ld de, OpeningTitleTilemap
	ld hl, $9800
	call DrawTilemap_5F
;> QueueMusic(0x06)
	ld a, $06
	call QueueMusic
;> wPaletteSet = 1
	ld a, $01
	ld [wPaletteSet], a
;> LoadPaletteSet()
	ld hl, far_LoadPaletteSet
	rst $10
;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> if wOnCGB:
	ld hl, $9800
	ld a, [wOnCGB]
	or a
	jr nz, .cgb

	jr .done

.cgb
;>     for p in range(0x9800, 0x9B00):
;>         mem[p] = 5                      # attribute map: palette 5
	ld a, $05
	ld [hli], a
	ld a, h
	cp $9b
	jr nz, .cgb

.done
;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
	ret

;@ def OpeningUpdate()
;@ path: title/opening
;@ Per-frame routine of the opening (far entry 3, called from TitleUpdateOpening): answers a
;@ linked Game Boy with $F4, lets A, B or Start skip ahead (OpeningSkip), else runs scene
;@ wOpeningScene.
;@ test: skip talks to the serial port
OpeningUpdate::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> buttons = wJoyPressed
	ld a, [wJoyPressed]
;> if buttons & 0x0B:                      # A, B or Start
;>     return OpeningSkip()
	bit 0, a
	jr nz, OpeningSkip

	bit 1, a
	jr nz, OpeningSkip

	bit 3, a
	jr nz, OpeningSkip

;> OpeningUpdateScenes[wOpeningScene]()
	ld a, [wOpeningScene]
	rst $00

;@ path: title/opening
;@ Per-frame routine of each opening scene (wOpeningScene 0-6).
OpeningUpdateScenes::
	dw OpeningLogos
	dw OpeningStarScene1
	dw OpeningStarScene2
	dw OpeningStarScene3
	dw OpeningPicture
	dw OpeningStarScene5
	dw OpeningTitle

;@ def OpeningSkip()
;@ path: title/opening
;@ A, B or Start during the opening: on the title screen it opens the title menu (game mode 0
;@ step 1); during the second logo it jumps to the third; from the third logo on it jumps to the
;@ title screen. The first logo cannot be skipped. Every jump fades out and restarts the mode.
;@ test: wOpeningScene = rng.randint(0, 6); wOpeningLogo = rng.randint(0, 2)
OpeningSkip::
;> scene = wOpeningScene
	ld a, [wOpeningScene]
;> if scene >= 6:                          # title screen: on to the title menu
	cp $06
	jr nc, .menu

;>@m1     StartFade(0x04)
;>@m2     wGameModeStep = 1
;>@m3     wOpeningScene = 0
;>@m4     wOpeningLogo = 0
;>@m5     wGameModeChange += 1
;>@m6     return
;> if scene == 0:                          # a logo screen
	cp $00
	jr z, .logos

;>@l1     if wOpeningLogo == 0:
;>@l2         return                       # the first logo plays in full
;>@l3     if wOpeningLogo == 1:            # second logo: skip to the third
;>@l4         StartFade(0x04)
;>@l5         wGameModeStep = 0
;>@l6         wOpeningScene = 0
;>@l7         wOpeningLogo = 2
;>@l8         wGameModeChange += 1
;>@l9         return
.toTitle
;> StartFade(0x04)                         # on to the title screen
	ld a, $04
	call StartFade
;> wGameModeStep = 0
	ld a, $00
	ld [wGameModeStep], a
;> wOpeningScene = 6
	ld a, $06
	ld [wOpeningScene], a
;> wOpeningLogo = 0
	ld a, $00
	ld [wOpeningLogo], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret

.menu
;=@m1
	ld a, $04
	call StartFade
;=@m2
	ld a, $01
	ld [wGameModeStep], a
;=@m3
	ld a, $00
	ld [wOpeningScene], a
;=@m4
	ld a, $00
	ld [wOpeningLogo], a
;=@m5
	ld hl, wGameModeChange
	inc [hl]
;=@m6
	ret

.logos
;=@l1
	ld a, [wOpeningLogo]
	cp $00
	jp nz, .notFirst

;=@l2
	ret

.notFirst
;=@l3
	ld a, [wOpeningLogo]
	cp $01
	jp nz, .toTitle

;=@l4
	ld a, $04
	call StartFade
;=@l5
	ld a, $00
	ld [wGameModeStep], a
;=@l6
	ld a, $00
	ld [wOpeningScene], a
;=@l7
	ld a, $02
	ld [wOpeningLogo], a
;=@l8
	ld hl, wGameModeChange
	inc [hl]
;=@l9
	ret


;@ def OpeningLogos()
;@ path: title/opening
;@ Scene 0: runs logo screen wOpeningLogo.
;@ test: skip runs the logos through a jump table
OpeningLogos::
;> OpeningLogoSteps[wOpeningLogo]()
	ld a, [wOpeningLogo]
	rst $00

;@ path: title/opening
;@ Per-frame routine of each logo screen; the byte after the table is a spare `ret`.
OpeningLogoSteps::
	dw OpeningLogo0
	dw OpeningLogo1
	dw OpeningLogo2
	db $c9

;@ def OpeningLogo0()
;@ path: title/opening
;@ First logo: once faded in, shows it for 60 frames, then fades out and restarts the mode
;@ for the next logo.
;@ test: wSceneObjects[0] = rng.randint(0, 59)
OpeningLogo0::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSceneObjects[0] += 1                   # frames shown
	ld hl, wSceneObjects
	inc [hl]
;> if wSceneObjects[0] != 60:
;>     return
	ld a, [wSceneObjects]
	cp $3c
	ret nz

;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningLogo += 1
	ld hl, wOpeningLogo
	inc [hl]
;> wGameModeChange += 1                    # OpeningInit sets up the next logo
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def OpeningLogo1()
;@ path: title/opening
;@ Second logo: shown for 180 frames, then on to the third.
;@ test: wSceneObjects[0] = rng.randint(0, 179)
OpeningLogo1::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSceneObjects[0] += 1                   # frames shown
	ld hl, wSceneObjects
	inc [hl]
;> if wSceneObjects[0] != 180:
;>     return
	ld a, [wSceneObjects]
	cp $b4
	ret nz

;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningLogo += 1
	ld hl, wOpeningLogo
	inc [hl]
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def OpeningLogo2()
;@ path: title/opening
;@ Third logo: shown for 180 frames, then on to scene 1 with its two sprite objects set up.
;@ test: wSceneObjects[0] = rng.randint(0, 179)
OpeningLogo2::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSceneObjects[0] += 1                   # frames shown
	ld hl, wSceneObjects
	inc [hl]
;> if wSceneObjects[0] != 180:
;>     return
	ld a, [wSceneObjects]
	cp $b4
	ret nz

;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningScene += 1
	ld hl, wOpeningScene
	inc [hl]
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> SetUpStarScene1(addr(wSceneObjects) + 4)
	ld hl, wSceneObjects + 4
	call SetUpStarScene1
	ret


;@ def OpeningStarScene1()
;@ path: title/opening
;@ Scene 1: a shooting star (object at wSceneObjects[4]) flies down to the left, 2 pixels a frame;
;@ when it reaches X $40 the sparkle appears at its place in the sky, and it vanishes at X $E0 (off the left edge).
;@ When both are gone the next scene starts at once (SetUpStarScene2 sets up its objects).
;@ test: skip calls a routine in another bank
OpeningStarScene1::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> if wSceneObjects[0] == 0:               # first frame of the scene
;>     QueueSound(0x5D)                    # the star's sound
	ld a, [wSceneObjects]
	or a
	jr nz, .started

	ld a, $5d
	call QueueSound

.started
;> wSceneObjects[0] = 1
	ld a, $01
	ld [wSceneObjects], a
;> if wSceneObjects[4] == 0:               # the star is still flying
	ld a, [wSceneObjects + 4]
	or a
	jr nz, .sparkle

;>     hSpriteSet = 0                     # star sprites
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0
	ld a, $00
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;>     wSceneStep = 0xDC; wSceneTimer = 0xC0   # object pointer: the star
	ld hl, wSceneObjects + 4
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;>     far_call(0x02, 0x04)               # UpdateSceneObject: draw and animate it
	ld hl, $0204
	rst $10
;>     wSceneObjects[5] -= 2              # X: to the left
	ld hl, wSceneObjects + 5
	dec [hl]
	ld hl, wSceneObjects + 5
	dec [hl]
;>     wSceneObjects[6] += 2              # Y: down
	ld hl, wSceneObjects + 6
	inc [hl]
	ld hl, wSceneObjects + 6
	inc [hl]
;>     if wSceneObjects[5] == 0x40:
	ld a, [wSceneObjects + 5]
	cp $40
	jr z, .showSparkle

;>@sp         wSceneObjects[10] = 0         # the sparkle appears
;>     elif wSceneObjects[5] == 0xE0:
	cp $e0
	jr nz, .sparkle

;>         wSceneObjects[4] = 1           # the star is gone
	ld a, $01
	ld [wSceneObjects + 4], a
	jr .sparkle

.showSparkle
;=@sp
	ld a, $00
	ld [wSceneObjects + 10], a

.sparkle
;> if wSceneObjects[10] != 0:              # sparkle not shown (yet)
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret nz

;> hSpriteSet = 1                          # sparkle sprites
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 4
	ld a, $04
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;> wSceneStep = 0xE2; wSceneTimer = 0xC0   # object pointer: the sparkle
	ld hl, wSceneObjects + 10
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;> far_call(0x02, 0x04)                    # UpdateSceneObject (hides it when its script ends)
	ld hl, $0204
	rst $10
;> if wSceneObjects[10] == 0:              # sparkle still playing
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret z

;> if wSceneObjects[4] == 0:               # star still flying
;>     return
	ld a, [wSceneObjects + 4]
	or a
	ret z

;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningScene += 1
	ld hl, wOpeningScene
	inc [hl]
;> SetUpStarScene2(addr(wSceneObjects) + 4)
	ld hl, wSceneObjects + 4
	call SetUpStarScene2
	ret


;@ def OpeningStarScene2()
;@ path: title/opening
;@ Scene 2: a shooting star (object at wSceneObjects[4]) flies down to the left, 2 pixels a frame;
;@ the sparkle appears when the star reaches X $10, the star vanishes at X $E0.
;@ When both are gone the next scene starts at once (SetUpStarScene3 sets up its objects).
;@ test: skip calls a routine in another bank
OpeningStarScene2::
;> if wSceneObjects[0] == 0:               # first frame of the scene
;>     QueueSound(0x5D)                    # the star's sound
	ld a, [wSceneObjects]
	or a
	jr nz, .started

	ld a, $5d
	call QueueSound

.started
;> wSceneObjects[0] = 1
	ld a, $01
	ld [wSceneObjects], a
;> if wSceneObjects[4] == 0:               # the star is still flying
	ld a, [wSceneObjects + 4]
	or a
	jr nz, .sparkle

;>     hSpriteSet = 0                     # star sprites
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0
	ld a, $00
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;>     wSceneStep = 0xDC; wSceneTimer = 0xC0   # object pointer: the star
	ld hl, wSceneObjects + 4
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;>     far_call(0x02, 0x04)               # UpdateSceneObject: draw and animate it
	ld hl, $0204
	rst $10
;>     wSceneObjects[5] -= 2              # X: to the left
	ld hl, wSceneObjects + 5
	dec [hl]
	ld hl, wSceneObjects + 5
	dec [hl]
;>     wSceneObjects[6] += 2              # Y: down
	ld hl, wSceneObjects + 6
	inc [hl]
	ld hl, wSceneObjects + 6
	inc [hl]
;>     if wSceneObjects[5] == 0x10:
	ld a, [wSceneObjects + 5]
	cp $10
	jr z, .showSparkle

;>@sp         wSceneObjects[10] = 0         # the sparkle appears
;>     elif wSceneObjects[5] == 0xE0:
	cp $e0
	jr nz, .sparkle

;>         wSceneObjects[4] = 1           # the star is gone
	ld a, $01
	ld [wSceneObjects + 4], a
	jr .sparkle

.showSparkle
;=@sp
	ld a, $00
	ld [wSceneObjects + 10], a

.sparkle
;> if wSceneObjects[10] != 0:              # sparkle not shown (yet)
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret nz

;> hSpriteSet = 1                          # sparkle sprites
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 4
	ld a, $04
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;> wSceneStep = 0xE2; wSceneTimer = 0xC0   # object pointer: the sparkle
	ld hl, wSceneObjects + 10
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;> far_call(0x02, 0x04)                    # UpdateSceneObject (hides it when its script ends)
	ld hl, $0204
	rst $10
;> if wSceneObjects[10] == 0:              # sparkle still playing
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret z

;> if wSceneObjects[4] == 0:               # star still flying
;>     return
	ld a, [wSceneObjects + 4]
	or a
	ret z

;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningScene += 1
	ld hl, wOpeningScene
	inc [hl]
;> SetUpStarScene3(addr(wSceneObjects) + 4)
	ld hl, wSceneObjects + 4
	call SetUpStarScene3
	ret


;@ def OpeningStarScene3()
;@ path: title/opening
;@ Scene 3: a shooting star (object at wSceneObjects[4]) flies down to the left, 2 pixels a frame;
;@ the sparkle appears when the star reaches X $70, the star vanishes at X $20.
;@ When both are gone the screen fades out and the picture scene follows.
;@ test: skip calls a routine in another bank
OpeningStarScene3::
;> if wSceneObjects[0] == 0:               # first frame of the scene
;>     QueueSound(0x5D)                    # the star's sound
	ld a, [wSceneObjects]
	or a
	jr nz, .started

	ld a, $5d
	call QueueSound

.started
;> wSceneObjects[0] = 1
	ld a, $01
	ld [wSceneObjects], a
;> if wSceneObjects[4] == 0:               # the star is still flying
	ld a, [wSceneObjects + 4]
	or a
	jr nz, .sparkle

;>     hSpriteSet = 0                     # star sprites
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0
	ld a, $00
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;>     wSceneStep = 0xDC; wSceneTimer = 0xC0   # object pointer: the star
	ld hl, wSceneObjects + 4
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;>     far_call(0x02, 0x04)               # UpdateSceneObject: draw and animate it
	ld hl, $0204
	rst $10
;>     wSceneObjects[5] -= 2              # X: to the left
	ld hl, wSceneObjects + 5
	dec [hl]
	ld hl, wSceneObjects + 5
	dec [hl]
;>     wSceneObjects[6] += 2              # Y: down
	ld hl, wSceneObjects + 6
	inc [hl]
	ld hl, wSceneObjects + 6
	inc [hl]
;>     if wSceneObjects[5] == 0x70:
	ld a, [wSceneObjects + 5]
	cp $70
	jr z, .showSparkle

;>@sp         wSceneObjects[10] = 0         # the sparkle appears
;>     elif wSceneObjects[5] == 0x20:
	cp $20
	jr nz, .sparkle

;>         wSceneObjects[4] = 1           # the star is gone
	ld a, $01
	ld [wSceneObjects + 4], a
	jr .sparkle

.showSparkle
;=@sp
	ld a, $00
	ld [wSceneObjects + 10], a

.sparkle
;> if wSceneObjects[10] != 0:              # sparkle not shown (yet)
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret nz

;> hSpriteSet = 1                          # sparkle sprites
	ld a, $01
	ldh [hSpriteSet], a
;> hSpriteTileBase = 4
	ld a, $04
	ldh [hSpriteTileBase], a
;> hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;> wSceneStep = 0xE2; wSceneTimer = 0xC0   # object pointer: the sparkle
	ld hl, wSceneObjects + 10
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;> far_call(0x02, 0x04)                    # UpdateSceneObject (hides it when its script ends)
	ld hl, $0204
	rst $10
;> if wSceneObjects[10] == 0:              # sparkle still playing
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret z

;> if wSceneObjects[4] == 0:               # star still flying
;>     return
	ld a, [wSceneObjects + 4]
	or a
	ret z

;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningScene += 1
	ld hl, wOpeningScene
	inc [hl]
;> wGameModeChange += 1                    # OpeningInit sets up the picture
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def OpeningPicture()
;@ path: title/opening
;@ Scene 4: shows the picture for 120 frames, then fades out to scene 5 with its two stars set
;@ up.
;@ test: wSceneObjects[0] = rng.randint(0, 119)
OpeningPicture::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> wSceneObjects[0] += 1                   # frames shown
	ld hl, wSceneObjects
	inc [hl]
;> if wSceneObjects[0] != 120:
;>     return
	ld a, [wSceneObjects]
	cp $78
	ret nz

;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningScene += 1
	ld hl, wOpeningScene
	inc [hl]
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wSceneObjects[16] = 0
	xor a
	ld [wSceneObjects + 16], a
;> wSceneObjects[17] = 0
	xor a
	ld [wSceneObjects + 17], a
;> wSceneObjects[18] = 0
	xor a
	ld [wSceneObjects + 18], a
;> SetUpStarScene5(addr(wSceneObjects) + 4)
	ld hl, wSceneObjects + 4
	call SetUpStarScene5
	ret


;@ def OpeningStarScene5()
;@ path: title/opening
;@ Scene 5: two shooting stars (objects at wSceneObjects[4] and [10]) fly down to the left
;@ together, 2 pixels a frame; the first vanishes at X $36, the second at X $59. Then the
;@ screen fades out to the title screen.
;@ test: skip calls a routine in another bank
OpeningStarScene5::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	ret nz

;> if wSceneObjects[0] == 0:               # first frame of the scene
;>     QueueSound(0x5D)
	ld a, [wSceneObjects]
	or a
	jr nz, .started

	ld a, $5d
	call QueueSound

.started
;> wSceneObjects[0] = 1
	ld a, $01
	ld [wSceneObjects], a
;> if wSceneObjects[4] == 0:               # first star still flying
	ld a, [wSceneObjects + 4]
	or a
	jr nz, .second

;>     hSpriteSet = 0
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0
	ld a, $00
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;>     wSceneStep = 0xDC; wSceneTimer = 0xC0   # object pointer: first star
	ld hl, wSceneObjects + 4
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;>     far_call(0x02, 0x04)                # UpdateSceneObject
	ld hl, $0204
	rst $10
;>     wSceneObjects[5] -= 2               # X: to the left
	ld hl, wSceneObjects + 5
	dec [hl]
	ld hl, wSceneObjects + 5
	dec [hl]
;>     wSceneObjects[6] += 2               # Y: down
	ld hl, wSceneObjects + 6
	inc [hl]
	ld hl, wSceneObjects + 6
	inc [hl]
;>     if wSceneObjects[5] == 0x36:
	ld a, [wSceneObjects + 5]
	cp $36
	jr nz, .second

;>         wSceneObjects[4] = 1            # gone
	ld a, $01
	ld [wSceneObjects + 4], a

.second
;> if wSceneObjects[10] == 0:              # second star still flying
	ld a, [wSceneObjects + 10]
	or a
	jr nz, .check

;>     hSpriteSet = 0
	ld a, $00
	ldh [hSpriteSet], a
;>     hSpriteTileBase = 0
	ld a, $00
	ldh [hSpriteTileBase], a
;>     hSpriteAttr = 0
	ld a, $00
	ldh [hSpriteAttr], a
;>     wSceneStep = 0xE2; wSceneTimer = 0xC0   # object pointer: second star
	ld hl, wSceneObjects + 10
	ld a, l
	ld [wSceneStep], a
	ld a, h
	ld [wSceneTimer], a
;>     far_call(0x02, 0x04)                # UpdateSceneObject
	ld hl, $0204
	rst $10
;>     wSceneObjects[11] -= 2
	ld hl, wSceneObjects + 11
	dec [hl]
	ld hl, wSceneObjects + 11
	dec [hl]
;>     wSceneObjects[12] += 2
	ld hl, wSceneObjects + 12
	inc [hl]
	ld hl, wSceneObjects + 12
	inc [hl]
;>     if wSceneObjects[11] == 0x59:
	ld a, [wSceneObjects + 11]
	cp $59
	jr nz, .check

;>         wSceneObjects[10] = 1           # gone
	ld a, $01
	ld [wSceneObjects + 10], a

.check
;> if wSceneObjects[10] == 0:
;>     return
	ld a, [wSceneObjects + 10]
	or a
	ret z

;> if wSceneObjects[4] == 0:
;>     return
	ld a, [wSceneObjects + 4]
	or a
	ret z

;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wSceneObjects[0] = 0
	xor a
	ld [wSceneObjects], a
;> wOpeningScene += 1
	ld hl, wOpeningScene
	inc [hl]
;> wGameModeChange += 1                    # OpeningInit sets up the title screen
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def OpeningTitle()
;@ path: title/opening
;@ Scene 6, the title screen: when all four music channels have finished ($FF in the state
;@ byte of each), starts the title song again. Interrupts stay off until QueueMusic turns them
;@ back on.
;@ test: skip starts the music
OpeningTitle::
;> done = mem[0xDDB4] & mem[0xDDCE]
	ld a, [$ddb4]
	ld hl, $ddce
	and [hl]
;> done &= mem[0xDDE8] & mem[0xDE02]
	ld hl, $dde8
	and [hl]
	ld hl, $de02
	and [hl]
;> if done != 0xFF:
;>     return
	cp $ff
	ret nz

;> disable_interrupts(); QueueMusic(0x06)
	ld a, $06
	di
	call QueueMusic
	ret


;@ def SetUpStarScene1(objs: hl)
;@ path: title/opening
;@ Sets up the two cutscene objects of scene 1 at `objs` (6 bytes each: hidden, X, Y, pose,
;@ script step, frames left): the shooting star at X $80, Y 0 and the sparkle at X $50, Y $30,
;@ still hidden.
;@ test: objs = 0xC100
SetUpStarScene1::
;> for i, v in enumerate([0, 0x80, 0x00, 0, 0, 2, 1, 0x50, 0x30, 0, 0, 2]):
;>@w     mem[objs + i] = v
	ld a, $00
	ld [hli], a
;=@w
	ld a, $80
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;=@w
	ld a, $01
	ld [hli], a
;=@w
	ld a, $50
	ld [hli], a
;=@w
	ld a, $30
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def SetUpStarScene2(objs: hl)
;@ path: title/opening
;@ Objects of scene 2: the star at X $40, Y 0, the hidden sparkle at X $20, Y $20.
;@ test: objs = 0xC100
SetUpStarScene2::
;> for i, v in enumerate([0, 0x40, 0x00, 0, 0, 2, 1, 0x20, 0x20, 0, 0, 2]):
;>@w     mem[objs + i] = v
	ld a, $00
	ld [hli], a
;=@w
	ld a, $40
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;=@w
	ld a, $01
	ld [hli], a
;=@w
	ld a, $20
	ld [hli], a
;=@w
	ld a, $20
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def SetUpStarScene3(objs: hl)
;@ path: title/opening
;@ Objects of scene 3: the star at X $A0, Y $30, the hidden sparkle at X $80, Y $50.
;@ test: objs = 0xC100
SetUpStarScene3::
;> for i, v in enumerate([0, 0xA0, 0x30, 0, 0, 2, 1, 0x80, 0x50, 0, 0, 2]):
;>@w     mem[objs + i] = v
	ld a, $00
	ld [hli], a
;=@w
	ld a, $a0
	ld [hli], a
;=@w
	ld a, $30
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;=@w
	ld a, $01
	ld [hli], a
;=@w
	ld a, $80
	ld [hli], a
;=@w
	ld a, $50
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def SetUpStarScene5(objs: hl)
;@ path: title/opening
;@ Objects of scene 5: two stars, both shown, at X $86, Y $FE (just above the screen) and
;@ X $A9, Y 4.
;@ test: objs = 0xC100
SetUpStarScene5::
;> for i, v in enumerate([0, 0x86, 0xFE, 0, 0, 2, 0, 0xA9, 0x04, 0, 0, 2]):
;>@w     mem[objs + i] = v
	ld a, $00
	ld [hli], a
;=@w
	ld a, $86
	ld [hli], a
;=@w
	ld a, $fe
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $a9
	ld [hli], a
;=@w
	ld a, $04
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $00
	ld [hli], a
;=@w
	ld a, $02
	ld [hli], a
;> return
	ret


;@ def StartSkillHitEffect()
;@ path: battle/screeneffect
;@ Starts the screen effect of a skill hitting its target, for the skills that have one
;@ (wSkillId in the ranges below): the target's picture blinks when it is an enemy (effect 2),
;@ the screen shakes when it is one of the player's own monsters, which are not shown (effect
;@ 3); skills $84-$87 flash the screen instead (effect 4). Linked, the Game Boy driving the
;@ clock sees the sides the other way round. Other skills leave the effect state alone.
;@ test: wSkillTarget = rng.randint(0, 7)
StartSkillHitEffect::
;> s = wSkillId
	ld a, [wSkillId]
;> if s < 0x12 or s == 0x39:
;>     pass
	cp $12
	jp c, .hit

	cp $39
	jr z, .hit

;> elif s < 0x37:
;>     return
	cp $37
	ret c

;> elif s < 0x41:
;>     pass
	cp $41
	jr c, .hit

;> elif s < 0x42:
;>     return
	cp $42
	ret c

;> elif s < 0x43:
;>     pass
	cp $43
	jr c, .hit

;> elif s < 0x44:
;>     return
	cp $44
	ret c

;> elif s < 0x54:
;>     pass
	cp $54
	jr c, .hit

;> elif s < 0x55:
;>     return
	cp $55
	ret c

;> elif s < 0x6A:
;>     pass
	cp $6a
	jr c, .hit

;> elif s < 0x73:
;>     return
	cp $73
	ret c

;> elif s < 0x75:
;>     pass
	cp $75
	jr c, .hit

;> elif s < 0x7D:
;>     return
	cp $7d
	ret c

;> elif s < 0x7F:
;>     pass
	cp $7f
	jr c, .hit

;> elif s < 0x81:
;>     return
	cp $81
	ret c

;> elif s < 0x84:
;>     pass
	cp $84
	jr c, .hit

;> elif s < 0x88:
	cp $88
	jr c, .flash

;>@f1     fill(addr(wBattleAnimDone), 0, 6)
;>@f2     wScreenEffect = 4               # flash
;>@f3     return
;> elif s < 0x99:
;>     return
	cp $99
	ret c

;> elif s < 0x9C:
;>     pass
	cp $9c
	jr c, .hit

;> elif s < 0xA5:
;>     return
	cp $a5
	ret c

;> elif s < 0xA6:
;>     pass
	cp $a6
	jr c, .hit

;> elif s < 0xAB:
;>     return
	cp $ab
	ret c

;> elif s < 0xAC:
;>     pass
	cp $ac
	jr c, .hit

;> elif s < 0xAF:
;>     return
	cp $af
	ret c

;> elif s < 0xB0:
;>     pass
	cp $b0
	jr c, .hit

;> elif s < 0xC7:
;>     return
	cp $c7
	ret c

;> elif s < 0xC9:
;>     pass
	cp $c9
	jr c, .hit

;> elif s < 0xCA:
;>     return
	cp $ca
	ret c

;> elif s < 0xCC:
;>     pass
	cp $cc
	jr c, .hit

;> elif s < 0xD4:
;>     return
	cp $d4
	ret c

;> elif s < 0xD5:
;>     pass
	cp $d5
	jr c, .hit

;> elif s < 0xD6:
;>     return
	cp $d6
	ret c

;> elif s < 0xDA:
;>     pass
	cp $da
	jr c, .hit

;> elif s < 0xDD:
;>     return
	cp $dd
	ret c

;> elif s < 0xDE:
;>     pass
	cp $de
	jr c, .hit

;> elif s < 0xDF:
;>     return
	cp $df
	ret c

;> elif s < 0xE0:
;>     pass
	cp $e0
	jr c, .hit

;> else:
;>     return
	ret

.hit
;> fill(addr(wBattleAnimDone), 0, 6)       # wBattleAnimDone and the screen effect state
	xor a
	ld hl, wBattleAnimDone
	ld bc, $0006
	call FillMemory
;> effect = 3                              # shake the screen
	ld b, $03
;> if wLinkFlags & 0x02:                   # this Game Boy drives the clock
;>     effect = 2
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .side

	ld b, $02

.side
;> if wSkillTarget >= 4:                   # the other side
;>     effect ^= 1                         # 3 <-> 2
	ld a, [wSkillTarget]
	cp $04
	ld a, b
	jr c, .set

	xor $01

.set
;> wScreenEffect = effect
	ld [wScreenEffect], a
	ret

.flash
;=@f1
	xor a
	ld hl, wBattleAnimDone
	ld bc, $0006
	call FillMemory
;=@f2
	ld a, $04
	ld [wScreenEffect], a
;=@f3
	ret


;@ def UpdateScreenEffect()
;@ path: battle/screeneffect
;@ Runs one step of battle screen effect wScreenEffect every 5th frame, until the effect sets
;@ wBattleAnimDone. A pending $80 in wItemMsgGroup (the skill animation's screen place) plays
;@ sound $6C instead.
;@ test: skip runs the effects through a jump table
UpdateScreenEffect::
;> t = mem[0xDA34] + 1
	ld a, [$da34]
	inc a
;> mem[0xDA34] = t
	cp $05
	ld [$da34], a
;> if t < 5:
;>     return
	ret c

;> mem[0xDA34] = 0
	xor a
	ld [$da34], a
;> if wBattleAnimDone:
;>     return
	ld a, [wBattleAnimDone]
	or a
	ret nz

;> if wItemMsgGroup == 0x80:
;>     QueueSound(0x6C)
	ld a, [wItemMsgGroup]
	cp $80
	jr nz, .run

	ld a, $6c
	call QueueSound
;>     wItemMsgGroup = 0xFF
;>     return
	ld a, $ff
	ld [wItemMsgGroup], a
	ret

.run
;> ScreenEffects[wScreenEffect]()
	ld a, [wScreenEffect]
	rst $00

;@ path: battle/screeneffect
;@ Routine of each battle screen effect (wScreenEffect 0-13): 0-1 none, 2 blink the target's
;@ picture, 3 shake up and down, 4 flash, 5 darken, 6 invert, 7 darken twice, 8 quake, 9 wave,
;@ 10 lighten, 11 long flash, 12 shake sideways, 13 blink the user's picture.
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

;@ def EffectNone()
;@ path: battle/screeneffect
;@ Screen effects 0 and 1: nothing to show, done at once.
EffectNone::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectBlinkTarget()
;@ path: battle/screeneffect
;@ Screen effect 2: the target's picture disappears and comes back twice (one step each 5
;@ frames). Ends at once when the target has no picture (one of the player's own monsters,
;@ position 3 or 7) or has left the battle.
;@ test: skip runs the steps through a jump table
EffectBlinkTarget::
;> flags = wLinkFlags
	ld a, [wLinkFlags]
	ld b, a
;> if wSkillTarget & 0x03 == 3:
;>     return BlinkTargetEnd()
	ld a, [wSkillTarget]
	and $03
	cp $03
	jr z, BlinkTargetEnd

;> pos = wSkillTarget
	ld a, [wSkillTarget]
;> if flags & 0x02:                        # this Game Boy drives the clock: sides swapped
	bit 1, b
	jr nz, .master

;>@m1     if pos >= 4:
;>@m2         return BlinkTargetEnd()
;> elif pos < 4:                           # own side: no picture
;>     return BlinkTargetEnd()
	cp $04
	jr c, BlinkTargetEnd

	jr .check

.master
;=@m1
	cp $04
;=@m2
	jr nc, BlinkTargetEnd

.check
;> if wBattleSubStep != 0x0A and CheckBattlerPresent(wSkillTarget):
;>     return BlinkTargetEnd()             # the target is gone
	ld a, [wBattleSubStep]
	cp $0a
	jr z, .run

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, BlinkTargetEnd

.run
;> BlinkTargetSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the blinking target picture: hide, show, hide, show, done.
BlinkTargetSteps::
	dw BlinkTargetHide
	dw BlinkTargetShow
	dw BlinkTargetHide
	dw BlinkTargetShow
	dw BlinkTargetEnd

;@ def BlinkTargetHide()
;@ path: battle/screeneffect
;@ Overwrites the target's 6 x 6 tile picture with blank tiles.
;@ test: skip writes VRAM
BlinkTargetHide::
;> wScreenEffectTimer = 6                  # picture width
	ld a, $06
	ld [wScreenEffectTimer], a
;> slot = GetTargetPicSlot()
	call GetTargetPicSlot
;> dest = 0x9800 + GetWordEntry_5F(slot, PicSlotOffsets)
	ld hl, PicSlotOffsets
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
;> tiles = GetWordEntry_5F(3, PicTileLayouts)   # blank
	ld a, $03
	ld hl, PicTileLayouts
	call GetWordEntry_5F
;> CopyTileRectVRAM_5F(tiles, dest, 6)
	ld c, $06
	call CopyTileRectVRAM_5F
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def BlinkTargetShow()
;@ path: battle/screeneffect
;@ Draws the target's picture again: the tile numbers of enemy picture wSkillTarget & 3.
;@ test: skip writes VRAM
BlinkTargetShow::
;> wScreenEffectTimer = 6                  # picture width
	ld a, $06
	ld [wScreenEffectTimer], a
;> slot = GetTargetPicSlot()
	call GetTargetPicSlot
;> dest = 0x9800 + GetWordEntry_5F(slot, PicSlotOffsets)
	ld hl, PicSlotOffsets
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
;> tiles = GetWordEntry_5F(wSkillTarget & 0x03, PicTileLayouts)
	ld a, [wSkillTarget]
	and $03
	ld hl, PicTileLayouts
	call GetWordEntry_5F
;> CopyTileRectVRAM_5F(tiles, dest, 6)
	ld c, $06
	call CopyTileRectVRAM_5F
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def BlinkTargetEnd()
;@ path: battle/screeneffect
;@ Ends the blinking picture effect.
BlinkTargetEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
;> wScreenEffectTimer = 0
	xor a
	ld [wScreenEffectTimer], a
	ret


;@ def EffectShakeY()
;@ path: battle/screeneffect
;@ Screen effect 3: the screen jumps 2 pixels up and back twice (skipped for skill $81).
;@ test: skip runs the steps through a jump table
EffectShakeY::
;> if wSkillId == 0x81:
;>     return ShakeYEnd()
	ld a, [wSkillId]
	cp $81
	jr z, ShakeYEnd

;> ShakeYSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the up-and-down shake.
ShakeYSteps::
	dw ShakeYDown
	dw ShakeYBack
	dw ShakeYDown
	dw ShakeYEnd

;@ def ShakeYDown()
;@ path: battle/screeneffect
;@ Scrolls the background 2 pixels (Y). The 13 bytes after it are an unused step that sets
;@ scroll Y 0 and scroll X 1.
ShakeYDown::
;> mem[addr(hScrollY)] = 2
	ld a, $02
	ldh [hScrollY], a
;> mem[addr(hScrollX)] = 0
	ld a, $00
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


	db $3e, $00, $e0, $bb, $3e, $01, $e0, $b7, $21, $84, $da, $34, $c9

;@ def ShakeYBack()
;@ path: battle/screeneffect
;@ Puts the background scroll back to 0.
ShakeYBack::
;> mem[addr(hScrollY)] = 0
	xor a
	ldh [hScrollY], a
;> mem[addr(hScrollX)] = 0
	xor a
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeYEnd()
;@ path: battle/screeneffect
;@ Ends the shake with the scroll back at 0.
ShakeYEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> mem[addr(hScrollY)] = 0
	xor a
	ldh [hScrollY], a
;> mem[addr(hScrollX)] = 0
	xor a
	ldh [hScrollX], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectFlash()
;@ path: battle/screeneffect
;@ Screen effect 4: the screen flashes white three times.
;@ test: skip runs the steps through a jump table
EffectFlash::
;> FlashSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the flash: white, normal, three times, then done.
FlashSteps::
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw SetPalettesWhite
	dw SetPalettesNormal
	dw FlashEnd

;@ def SetPalettesWhite()
;@ path: battle/screeneffect
;@ Makes all Game Boy palettes white (wBGP, wOBP0, wOBP1 = 0) and goes to the next step.
SetPalettesWhite::
;> wBGP = 0; wOBP0 = 0
	ld hl, wBGP
	ld [hl], $00
	inc hl
	ld [hl], $00
;> wOBP1 = 0
	inc hl
	ld [hl], $00
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def SetPalettesNormal()
;@ path: battle/screeneffect
;@ Puts the battle's Game Boy palettes back (BG and sprite palette 0 $D2, sprite palette 1 $E2)
;@ and goes to the next step.
SetPalettesNormal::
;> wBGP = 0xD2; wOBP0 = 0xD2
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
;> wOBP1 = 0xE2
	inc hl
	ld [hl], $e2
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def FlashEnd()
;@ path: battle/screeneffect
;@ Ends a flash effect with the normal palettes.
FlashEnd::
;> SetPalettesNormal()
	call SetPalettesNormal
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectDarken()
;@ path: battle/screeneffect
;@ Screen effect 5: the palettes darken in 4 steps, stay dark for 10 steps, then come back.
;@ test: skip runs the steps through a jump table
EffectDarken::
;> DarkenSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the darkening: fade, hold, restore, done.
DarkenSteps::
	dw DarkenFade
	dw DarkenHold
	dw DarkenRestore
	dw DarkenEnd

;@ def DarkenFade()
;@ path: battle/screeneffect
;@ Darkens the palettes one shade; after 4 shades goes on to the next step.
;@ test: wScreenEffectFrame = rng.randint(0, 3)
DarkenFade::
;> DarkenPalettesStep()
	call DarkenPalettesStep
;> if wScreenEffectFrame < 4:
;>     return
	ld a, [wScreenEffectFrame]
	cp $04
	ret c

;> wScreenEffectAux = 0
	xor a
	ld [wScreenEffectAux], a
;> wScreenEffectFrame = 0
	xor a
	ld [wScreenEffectFrame], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def DarkenHold()
;@ path: battle/screeneffect
;@ Keeps the screen as it is for 10 steps.
;@ test: wScreenEffectTimer = rng.randint(0, 9)
DarkenHold::
;> wScreenEffectTimer += 1
	ld hl, wScreenEffectTimer
	inc [hl]
;> if wScreenEffectTimer != 10:
;>     return
	ld a, [wScreenEffectTimer]
	cp $0a
	ret nz

;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
;> wScreenEffectTimer = 0
	xor a
	ld [wScreenEffectTimer], a
	ret


;@ def DarkenRestore()
;@ path: battle/screeneffect
;@ Puts the normal palettes back (as SetPalettesNormal).
DarkenRestore::
;> wBGP = 0xD2; wOBP0 = 0xD2
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
;> wOBP1 = 0xE2
	inc hl
	ld [hl], $e2
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def DarkenEnd()
;@ path: battle/screeneffect
;@ Ends the darkening effect.
DarkenEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectInvert()
;@ path: battle/screeneffect
;@ Screen effect 6: the palettes are inverted 12 times (6 flickers to the negative and back).
;@ test: skip runs the steps through a jump table
EffectInvert::
;> InvertSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the inverting effect: 12 inversions, then done.
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

;@ def InvertPalettes()
;@ path: battle/screeneffect
;@ Inverts the three Game Boy palettes (every colour becomes 3 - colour).
InvertPalettes::
;> wBGP ^= 0xFF
	ld hl, wBGP
	ld a, [hl]
	xor $ff
	ld [hli], a
;> wOBP0 ^= 0xFF
	ld a, [hl]
	xor $ff
	ld [hli], a
;> wOBP1 ^= 0xFF
	ld a, [hl]
	xor $ff
	ld [hl], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def InvertEnd()
;@ path: battle/screeneffect
;@ Ends the inverting effect (after an even number of inversions the palettes are normal).
InvertEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectDarkenTwice()
;@ path: battle/screeneffect
;@ Screen effect 7: twice darkens the palettes in 4 shades, holds 5 steps and restores them.
;@ test: skip runs the steps through a jump table
EffectDarkenTwice::
;> DarkenTwiceSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the double darkening: fade, hold, restore, twice, then done.
DarkenTwiceSteps::
	dw DarkenTwiceFade
	dw DarkenTwiceHold
	dw DarkenTwiceRestore
	dw DarkenTwiceFade
	dw DarkenTwiceHold
	dw DarkenTwiceRestore
	dw DarkenTwiceEnd

;@ def DarkenTwiceFade()
;@ path: battle/screeneffect
;@ Darkens the palettes one shade; after 4 shades goes on to the next step.
;@ test: wScreenEffectFrame = rng.randint(0, 3)
DarkenTwiceFade::
;> DarkenPalettesStep()
	call DarkenPalettesStep
;> if wScreenEffectFrame < 4:
;>     return
	ld a, [wScreenEffectFrame]
	cp $04
	ret c

;> wScreenEffectAux = 0
	xor a
	ld [wScreenEffectAux], a
;> wScreenEffectFrame = 0
	xor a
	ld [wScreenEffectFrame], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def DarkenTwiceHold()
;@ path: battle/screeneffect
;@ Keeps the screen dark for 5 steps.
;@ test: wScreenEffectTimer = rng.randint(0, 4)
DarkenTwiceHold::
;> wScreenEffectTimer += 1
	ld hl, wScreenEffectTimer
	inc [hl]
;> if wScreenEffectTimer != 5:
;>     return
	ld a, [wScreenEffectTimer]
	cp $05
	ret nz

;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
;> wScreenEffectTimer = 0
	xor a
	ld [wScreenEffectTimer], a
	ret


;@ def DarkenTwiceRestore()
;@ path: battle/screeneffect
;@ Puts the normal palettes back.
DarkenTwiceRestore::
;> wBGP = 0xD2; wOBP0 = 0xD2
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
;> wOBP1 = 0xE2
	inc hl
	ld [hl], $e2
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def DarkenTwiceEnd()
;@ path: battle/screeneffect
;@ Ends the double darkening.
DarkenTwiceEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectQuake()
;@ path: battle/screeneffect
;@ Screen effect 8, the quake: the screen shakes in a 27-step pattern (QuakeShake) while the
;@ palettes flash white in the second half (QuakeFlash); both run on wScreenEffectTimer.
;@ test: skip runs the steps through jump tables
EffectQuake::
;> if wScreenEffectStep == 0:
;>     QuakeShake()
	ld a, [wScreenEffectStep]
	or a
	call z, QuakeShake
;> QuakeFlash()
	call QuakeFlash
;> if wScreenEffectStep == 0:              # QuakeEnd sets it
;>     return
	ld a, [wScreenEffectStep]
	or a
	ret z

;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
;> wScreenEffectTimer = 0
	xor a
	ld [wScreenEffectTimer], a
	ret


;@ def EffectWave()
;@ path: battle/screeneffect
;@ Screen effect 9: the screen waves sideways (per-line X scroll, WaveStep). The first step
;@ clears the wave's counters, which borrow wMenuStep (wave step), wMenuSubStep, wItemsHandedIn
;@ (amplitude) and wHatchSlot (hold count).
;@ test: skip calls the raster effect code
EffectWave::
;> if wScreenEffectFrame == 0:
	ld a, [wScreenEffectFrame]
	or a
	jr nz, .run

;>     wScreenEffectFrame += 1
	ld hl, wScreenEffectFrame
	inc [hl]
;>     wMenuStep = 0
	xor a
	ld [wMenuStep], a
;>     wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;>     wItemsHandedIn = 0
	xor a
	ld [wItemsHandedIn], a
;>     wHatchSlot = 0
	xor a
	ld [wHatchSlot], a
;>     return
	ret

.run
;> WaveStep()
	call WaveStep
;> wScreenEffectFrame += 1                 # wave phase
	ld hl, wScreenEffectFrame
	inc [hl]
	ret


;@ def EffectLighten()
;@ path: battle/screeneffect
;@ Screen effect 10: the palettes lighten in 4 shades, stay for 10 steps, then come back.
;@ test: skip runs the steps through a jump table
EffectLighten::
;> LightenSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the lightening: fade, hold, restore, done.
LightenSteps::
	dw LightenFade
	dw LightenHold
	dw LightenRestore
	dw LightenEnd

;@ def LightenFade()
;@ path: battle/screeneffect
;@ Lightens the palettes one shade; after 4 shades goes on to the next step.
;@ test: wScreenEffectFrame = rng.randint(0, 3)
LightenFade::
;> LightenPalettesStep()
	call LightenPalettesStep
;> if wScreenEffectFrame < 4:
;>     return
	ld a, [wScreenEffectFrame]
	cp $04
	ret c

;> wScreenEffectAux = 0
	xor a
	ld [wScreenEffectAux], a
;> wScreenEffectFrame = 0
	xor a
	ld [wScreenEffectFrame], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def LightenHold()
;@ path: battle/screeneffect
;@ Keeps the screen light for 10 steps.
;@ test: wScreenEffectTimer = rng.randint(0, 9)
LightenHold::
;> wScreenEffectTimer += 1
	ld hl, wScreenEffectTimer
	inc [hl]
;> if wScreenEffectTimer != 10:
;>     return
	ld a, [wScreenEffectTimer]
	cp $0a
	ret nz

;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
;> wScreenEffectTimer = 0
	xor a
	ld [wScreenEffectTimer], a
	ret


;@ def LightenRestore()
;@ path: battle/screeneffect
;@ Puts the normal palettes back.
LightenRestore::
;> wBGP = 0xD2; wOBP0 = 0xD2
	ld hl, wBGP
	ld [hl], $d2
	inc hl
	ld [hl], $d2
;> wOBP1 = 0xE2
	inc hl
	ld [hl], $e2
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def LightenEnd()
;@ path: battle/screeneffect
;@ Ends the lightening effect.
LightenEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectFlashLong()
;@ path: battle/screeneffect
;@ Screen effect 11: the screen flashes white eight times.
;@ test: skip runs the steps through a jump table
EffectFlashLong::
;> FlashLongSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the long flash: white, normal, eight times, then done; a spare `ret` follows.
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


;@ def WaveStep()
;@ path: battle/screeneffect
;@ One frame of the wave effect: wave step wMenuStep (0 start, 1 grow, 2 hold, 3 end).
;@ test: skip runs the steps through a jump table
WaveStep::
;> WaveSteps[wMenuStep]()
	ld a, [wMenuStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the wave effect.
WaveSteps::
	dw WaveStart
	dw WaveGrow
	dw WaveHold
	dw WaveEnd

;@ def WaveStart()
;@ path: battle/screeneffect
;@ Starts the wave: every line of wLineScroll gets the current X scroll, the amplitude starts
;@ at 1 and the LCD interrupt's per-line X scroll (wLCDEffect 2) is switched on from line 2.
;@ test: skip switches on the raster effect
WaveStart::
;> wMenuStep += 1
	ld hl, wMenuStep
	inc [hl]
;> for i in range(128):
;>     wLineScroll[i] = lo(hScrollX)
	ld hl, wLineScroll
	ld b, $80

.fill
	ldh a, [hScrollX]
	ld [hli], a
	dec b
	jr nz, .fill

;> wItemsHandedIn = 1                      # amplitude
	ld a, $01
	ld [wItemsHandedIn], a
;> rLYC = 2
	ld a, $02
	ldh [rLYC], a
;> wLCDEffect = 2                          # per-line X scroll
	ld a, $02
	ld [wLCDEffect], a
	ret


;@ def WaveGrow()
;@ path: battle/screeneffect
;@ Every 8 frames makes the wave wider (amplitude + amplitude / 16 + 1) until it reaches $1C;
;@ then the hold step follows. Runs on into WaveSetLines.
;@ test: skip runs on into the raster effect code
WaveGrow::
;> if (wScreenEffectFrame & 0x07) == 0:
	ld a, [wScreenEffectFrame]
	and $07
	jr nz, WaveSetLines

;>     step = (wItemsHandedIn >> 4) + 1
	ld a, [wItemsHandedIn]
	swap a
	and $0f
	inc a
	ld b, a
;>     wItemsHandedIn = u8(wItemsHandedIn + step)
	ld a, [wItemsHandedIn]
	add b
	ld [wItemsHandedIn], a
;>     if wItemsHandedIn >= 0x1C:
	cp $1c
	jr c, WaveSetLines

;>         wMenuStep += 1                  # on to holding
	ld hl, wMenuStep
	inc [hl]
;>         wHatchSlot = 0
	xor a
	ld [wHatchSlot], a
;> WaveSetLines()                          # (runs on into it)

;@ def WaveSetLines()
;@ path: battle/screeneffect
;@ Writes the wave into wLineScroll lines 46-101 (the monsters' part of the screen): every pair
;@ of lines gets hScrollX +/- WaveOffsets_5F[e] * amplitude / 256 (minus in the second half of
;@ the wave), with e stepping along the 16-entry wave from wScreenEffectFrame >> 2, so the wave
;@ moves.
;@ test: skip pointer loop over the line buffer
WaveSetLines::
;> hNumber[0] = wItemsHandedIn             # amplitude
	ld a, [wItemsHandedIn]
	ldh [hNumber], a
;> e = (wScreenEffectFrame >> 2) & 0x0F
	ld a, [wScreenEffectFrame]
	rra
	rra
	and $0f
	ld e, a
	ld d, $00
;> line = 0xC12E                           # wLineScroll + 46
	ld bc, wLineScroll + 46
;> hNumber[1] = 0x66                       # low byte of the end (line 102)
	ld a, $66
	ldh [hNumber + 1], a

;>@w while True:
.loop
;>     e = (e + 1) & 0x0F
	inc e
	ld a, e
	and $0f
	ld e, a
;>     h = (mem[WaveOffsets_5F + e] * hNumber[0]) >> 8
	ld hl, WaveOffsets_5F
	add hl, de
	push bc
	ld c, [hl]
	ldh a, [hNumber]
	call Multiply
;>     if e & 0x08:
	pop bc
	bit 3, e
	jr z, .plus

;>         x = u8(hScrollX - h)
	ldh a, [hScrollX]
	sub h
;>     else:
	jr .store

;>         x = u8(hScrollX + h)
.plus
	ldh a, [hScrollX]
	add h

;>     mem[line] = x; mem[line + 1] = x
.store
	ld [bc], a
	inc c
	ld [bc], a
;>     line += 2
	inc c
;>     if (line & 0xFF) == hNumber[1]:
;>         return
	ldh a, [hNumber + 1]
	cp c
;=@w
	jr nz, .loop

	ret


;@ path: battle/screeneffect
;@ The wave of WaveSetLines: 16 offsets (scaled by the amplitude / 256), half a sine twice.
WaveOffsets_5F::
	db $00, $30, $5b, $76, $7f, $76, $5b, $30, $00, $30, $5b, $76, $7f, $76, $5b, $30

;@ def WaveHold()
;@ path: battle/screeneffect
;@ Keeps waving at full width; every 16 frames counts wHatchSlot up, after 4 the wave ends.
;@ test: skip runs into the raster effect code
WaveHold::
;> if (wScreenEffectFrame & 0x0F) == 0:
	ld a, [wScreenEffectFrame]
	and $0f
	jr nz, .lines

;>     wHatchSlot += 1
	ld a, [wHatchSlot]
	inc a
	ld [wHatchSlot], a
;>     if wHatchSlot == 4:
;>         wMenuStep += 1
	cp $04
	jr nz, .lines

	ld hl, wMenuStep
	inc [hl]

.lines
;> WaveSetLines()
	call WaveSetLines
	ret


;@ def WaveEnd()
;@ path: battle/screeneffect
;@ Switches the raster effect off and ends the wave effect, clearing its counters.
WaveEnd::
;> wLCDEffect = 0
	ld a, $00
	ld [wLCDEffect], a
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectFrame = 0
	xor a
	ld [wScreenEffectFrame], a
;> wMenuStep = 0
	xor a
	ld [wMenuStep], a
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wItemsHandedIn = 0
	xor a
	ld [wItemsHandedIn], a
;> wHatchSlot = 0
	xor a
	ld [wHatchSlot], a
	ret


;@ def DarkenPalettesStep()
;@ path: battle/screeneffect
;@ Darkens the three Game Boy palettes one shade (every colour + 1, at most 3) and counts
;@ wScreenEffectFrame up. Quirks: the result of each palette is ORed into the next ones, and a
;@ colour 3 in the top slot wraps round to 0.
;@ test: wBGP = rng.randint(0, 255); wOBP0 = rng.randint(0, 255); wOBP1 = rng.randint(0, 255)
DarkenPalettesStep::
;> wScreenEffectAux = 0
	xor a
	ld [wScreenEffectAux], a
;> wScreenEffectFrame += 1
	ld hl, wScreenEffectFrame
	inc [hl]
;> c = 0; p = addr(wBGP)
	ld b, $03
	ld c, $00
	ld hl, wBGP

;>@pal for i in range(3):
.palette
;>     x = min((mem[p] & 0x03) + 0x01, 0x03)
	ld a, [hl]
	and $03
	add $01
	cp $04
	jr c, .c0

	ld a, $03

.c0
;>     c |= x
	or c
	ld c, a
;>     x = min((mem[p] & 0x0C) + 0x04, 0x0C)
	ld a, [hl]
	and $0c
	add $04
	cp $0d
	jr c, .c1

	ld a, $0c

.c1
;>     c |= x
	or c
	ld c, a
;>     x = min((mem[p] & 0x30) + 0x10, 0x30)
	ld a, [hl]
	and $30
	add $10
	cp $31
	jr c, .c2

	ld a, $30

.c2
;>     c |= x
	or c
	ld c, a
;>     x = u8((mem[p] & 0xC0) + 0x40)        # (3 wraps round to 0)
	ld a, [hl]
	and $c0
	add $40
	cp $c1
	jr c, .c3

	ld a, $c0

.c3
;>     mem[p] = c | x; p += 1
	or c
	ld [hli], a
;=@pal
	dec b
	jr nz, .palette

	ret


;@ def LightenPalettesStep()
;@ path: battle/screeneffect
;@ Lightens the three Game Boy palettes one shade (every colour - 1, at least 0) and counts
;@ wScreenEffectFrame up; the result of each palette is ORed into the next ones.
;@ test: wBGP = rng.randint(0, 255); wOBP0 = rng.randint(0, 255); wOBP1 = rng.randint(0, 255)
LightenPalettesStep::
;> wScreenEffectAux = 0
	xor a
	ld [wScreenEffectAux], a
;> wScreenEffectFrame += 1
	ld hl, wScreenEffectFrame
	inc [hl]
;> c = 0; p = addr(wBGP)
	ld b, $03
	ld c, $00
	ld hl, wBGP

;>@pal for i in range(3):
.palette
;>     x = max((mem[p] & 0x03) - 0x01, 0)
	ld a, [hl]
	and $03
	cp $00
	jr z, .c0

	sub $01

.c0
;>     c |= x
	or c
	ld c, a
;>     x = max((mem[p] & 0x0C) - 0x04, 0)
	ld a, [hl]
	and $0c
	cp $00
	jr z, .c1

	sub $04

.c1
;>     c |= x
	or c
	ld c, a
;>     x = max((mem[p] & 0x30) - 0x10, 0)
	ld a, [hl]
	and $30
	cp $00
	jr z, .c2

	sub $10

.c2
;>     c |= x
	or c
	ld c, a
;>     x = max((mem[p] & 0xC0) - 0x40, 0)
	ld a, [hl]
	and $c0
	cp $00
	jr z, .c3

	sub $40

.c3
;>     mem[p] = c | x; p += 1
	or c
	ld [hli], a
;=@pal
	dec b
	jr nz, .palette

	ret


;@ def GetWordEntry_5F(index: a, table: hl) -> hl
;@ path: data
;@ Returns entry `index` of a table of 16-bit words.
;@ test: index = rng.randint(0, 127); table = 0xC100
GetWordEntry_5F::
;> p = table + (2 * index & 0xFF)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> return mem16[p]
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ path: battle/screeneffect
;@ BG map offsets (row * 32 + column) of the five places an enemy picture can stand: row 6 at
;@ column 7 (one enemy, or the middle one), 4 / 10 (two enemies), 1 / 13 (left and right of
;@ three).
PicSlotOffsets::
	dw $00c7, $00c4, $00ca, $00c1, $00cd

;@ path: battle/screeneffect
;@ Tile layouts of the enemy pictures for CopyTileRectVRAM_5F: the 6 x 6 tile numbers of
;@ picture 0, 1, 2 and a blank one.
PicTileLayouts::
	dw MonPicTiles0, MonPicTiles1, MonPicTiles2
	dw MonPicTilesBlank

;@ path: battle/screeneffect
;@ Tiles of the first enemy picture ($00-$23), row after row.
;@ asset: tilemap width=6 height=6
MonPicTiles0::
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d
	db $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d
	db $1e, $1f, $20, $21, $22, $23

;@ path: battle/screeneffect
;@ Tiles of the second enemy picture ($24-$47).
;@ asset: tilemap width=6 height=6
MonPicTiles1::
	db $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d
	db $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d
	db $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47

;@ path: battle/screeneffect
;@ Tiles of the third enemy picture ($48-$6B).
;@ asset: tilemap width=6 height=6
MonPicTiles2::
	db $48, $49, $4a, $4b, $4c, $4d
	db $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d
	db $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b

;@ path: battle/screeneffect
;@ A blank 6 x 6 picture (tile $E0) that hides a monster.
MonPicTilesBlank::
	db $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0

;@ def EffectShakeX()
;@ path: battle/screeneffect
;@ Screen effect 12: the screen shakes sideways, wider and wider (2, 4, 8 pixels), the last
;@ swings also 2 pixels down.
;@ test: skip runs the steps through a jump table
EffectShakeX::
;> ShakeXSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the sideways shake (every swing followed by a step back to the middle).
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

;@ def ShakeXCenter()
;@ path: battle/screeneffect
;@ Puts the background scroll back to 0.
ShakeXCenter::
;> mem[addr(hScrollX)] = 0; mem[addr(hScrollY)] = 0
	xor a
	ldh [hScrollX], a
	ldh [hScrollY], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXLeft2()
;@ path: battle/screeneffect
;@ Scroll X -2.
ShakeXLeft2::
;> mem[addr(hScrollX)] = 0xFE
	ld a, $fe
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXRight2()
;@ path: battle/screeneffect
;@ Scroll X +2.
ShakeXRight2::
;> mem[addr(hScrollX)] = 0x02
	ld a, $02
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXLeft4()
;@ path: battle/screeneffect
;@ Scroll X -4.
ShakeXLeft4::
;> mem[addr(hScrollX)] = 0xFC
	ld a, $fc
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXRight4()
;@ path: battle/screeneffect
;@ Scroll X +4.
ShakeXRight4::
;> mem[addr(hScrollX)] = 0x04
	ld a, $04
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXLeft8()
;@ path: battle/screeneffect
;@ Scroll X -8.
ShakeXLeft8::
;> mem[addr(hScrollX)] = 0xF8
	ld a, $f8
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXRight8()
;@ path: battle/screeneffect
;@ Scroll X +8.
ShakeXRight8::
;> mem[addr(hScrollX)] = 0x08
	ld a, $08
	ldh [hScrollX], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXLeft8Down()
;@ path: battle/screeneffect
;@ Scroll X -8, Y +2.
ShakeXLeft8Down::
;> mem[addr(hScrollX)] = 0xF8
	ld a, $f8
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0x02
	ld a, $02
	ldh [hScrollY], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXRight8Down()
;@ path: battle/screeneffect
;@ Scroll X +8, Y +2.
ShakeXRight8Down::
;> mem[addr(hScrollX)] = 0x08
	ld a, $08
	ldh [hScrollX], a
;> mem[addr(hScrollY)] = 0x02
	ld a, $02
	ldh [hScrollY], a
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def ShakeXEnd()
;@ path: battle/screeneffect
;@ Ends the sideways shake with the scroll back at 0.
ShakeXEnd::
;> mem[addr(hScrollX)] = 0; mem[addr(hScrollY)] = 0
	xor a
	ldh [hScrollX], a
	ldh [hScrollY], a
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
	ret


;@ def EffectBlinkUser()
;@ path: battle/screeneffect
;@ Screen effect 13: the picture of the skill's user disappears and comes back twice. Ends at
;@ once when the user has no picture (position 3 or from 7 on, or one of the player's own
;@ monsters) or has left the battle.
;@ test: skip runs the steps through a jump table
EffectBlinkUser::
;> flags = wLinkFlags
	ld a, [wLinkFlags]
	ld b, a
;> pos = wSkillUser
	ld a, [wSkillUser]
;> if pos >= 7 or pos == 3:
;>     return BlinkUserEnd()
	cp $07
	jr nc, BlinkUserEnd

	cp $03
	jr z, BlinkUserEnd

;> if flags & 0x02:                        # this Game Boy drives the clock: sides swapped
	bit 1, b
	jr nz, .master

;>@m1     if pos >= 4:
;>@m2         return BlinkUserEnd()
;> elif pos < 4:                           # own side: no picture
;>     return BlinkUserEnd()
	cp $04
	jr c, BlinkUserEnd

	jr .check

.master
;=@m1
	cp $04
;=@m2
	jr nc, BlinkUserEnd

.check
;> if CheckBattlerPresent(wSkillUser):     # (carry: not in the battle)
;>     return BlinkUserEnd()
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr c, BlinkUserEnd

;> BlinkUserSteps[wScreenEffectStep]()
	ld a, [wScreenEffectStep]
	rst $00

;@ path: battle/screeneffect
;@ Steps of the blinking user picture: hide, show, hide, show, done.
BlinkUserSteps::
	dw BlinkUserHide
	dw BlinkUserShow
	dw BlinkUserHide
	dw BlinkUserShow
	dw BlinkUserEnd

;@ def BlinkUserHide()
;@ path: battle/screeneffect
;@ Overwrites the user's 6 x 6 tile picture with blank tiles.
;@ test: skip writes VRAM
BlinkUserHide::
;> wScreenEffectTimer = 6                  # picture width
	ld a, $06
	ld [wScreenEffectTimer], a
;> slot = GetUserPicSlot()
	call GetUserPicSlot
;> dest = 0x9800 + GetWordEntry_5F(slot, PicSlotOffsets)
	ld hl, PicSlotOffsets
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
;> tiles = GetWordEntry_5F(3, PicTileLayouts)   # blank
	ld a, $03
	ld hl, PicTileLayouts
	call GetWordEntry_5F
;> CopyTileRectVRAM_5F(tiles, dest, 6)
	ld c, $06
	call CopyTileRectVRAM_5F
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def BlinkUserShow()
;@ path: battle/screeneffect
;@ Draws the user's picture again: the tile numbers of enemy picture wSkillUser & 3.
;@ test: skip writes VRAM
BlinkUserShow::
;> wScreenEffectTimer = 6                  # picture width
	ld a, $06
	ld [wScreenEffectTimer], a
;> slot = GetUserPicSlot()
	call GetUserPicSlot
;> dest = 0x9800 + GetWordEntry_5F(slot, PicSlotOffsets)
	ld hl, PicSlotOffsets
	call GetWordEntry_5F
	ld de, $9800
	add hl, de
	ld e, l
	ld d, h
;> tiles = GetWordEntry_5F(wSkillUser & 0x03, PicTileLayouts)
	ld a, [wSkillUser]
	and $03
	ld hl, PicTileLayouts
	call GetWordEntry_5F
;> CopyTileRectVRAM_5F(tiles, dest, 6)
	ld c, $06
	call CopyTileRectVRAM_5F
;> wScreenEffectStep += 1
	ld hl, wScreenEffectStep
	inc [hl]
	ret


;@ def BlinkUserEnd()
;@ path: battle/screeneffect
;@ Ends the blinking user picture effect.
BlinkUserEnd::
;> wBattleAnimDone = 1
	ld a, $01
	ld [wBattleAnimDone], a
;> wScreenEffectStep = 0
	xor a
	ld [wScreenEffectStep], a
;> wScreenEffectTimer = 0
	xor a
	ld [wScreenEffectTimer], a
	ret


;@ def CheckSwappedPicSkill() -> zero
;@ path: battle/screeneffect
;@ Zero when skill $3B, $3C or $3E is being carried out at battle step 7, sub-step 4: then
;@ GetUserPicSlot counts the other side's monsters in a link battle.
;@ test: wSkillId = rng.choice([0x3B, 0x3C, 0x3D, 0x3E, 0x10]); wBattleStep = rng.choice([7, 3]); wBattleSubStep = rng.choice([4, 1])
CheckSwappedPicSkill::
;> s = wSkillId
	ld a, [wSkillId]
;> if s not in (0x3B, 0x3C, 0x3E):
;>     return False
	cp $3b
	jr z, .step

	cp $3c
	jr z, .step

	cp $3e
	ret nz

.step
;> if wBattleStep != 7:
;>     return False
	ld a, [wBattleStep]
	cp $07
	ret nz

;> return wBattleSubStep == 4
	ld a, [wBattleSubStep]
	cp $04
	ret


;@ def StartSkillVisual()
;@ path: battle/animation
;@ Starts what the screen shows for skill wSkillId: a skill animation (sprites) or a screen
;@ effect, picked from SkillVisualsOwn (user on this Game Boy's side, or user $10, no battle
;@ position), SkillVisualsEnemy, or SkillVisualsLink (the other player's monster in a link
;@ battle, at stage 5 of a skill). During a monster's action (battle step 7) the skills are in
;@ four groups that each show their visual only at certain stages of the action (A: stage 5 of
;@ sub-step 1, B: stage $0E on, C: only in sub-step 4, D: not in sub-step $0A with counter 4;
;@ A and B also not in sub-step $0A with counter 1). Skill $80 always shows it. Nothing is
;@ shown for a skill aimed at the own side by user $10.
;@ test: skip calls routines in other banks
StartSkillVisual::
;> s = wSkillId
	ld a, [wSkillId]
;> if s < 0x15: group = 'A'
	cp $15
	jp c, .groupA

;> elif s < 0x24: group = 'B'
	cp $24
	jp c, .groupB

;> elif s < 0x25: group = 'A'
	cp $25
	jp c, .groupA

;> elif s == 0x2A: group = 'A'
	cp $2a
	jp z, .groupA

;> elif s < 0x37: group = 'B'
	cp $37
	jr c, .groupB

;> elif s == 0x3B: group = 'C'
	cp $3b
	jp z, .groupC

;> elif s == 0x3C: group = 'C'
	cp $3c
	jp z, .groupC

;> elif s == 0x3E: group = 'C'
	cp $3e
	jp z, .groupC

;> elif s < 0x67: group = 'A'
	cp $67
	jp c, .groupA

;> elif s < 0x6A: group = 'C'
	cp $6a
	jp c, .groupC

;> elif s == 0x71: group = 'A'
	cp $71
	jr z, .groupA

;> elif s < 0x73: group = 'B'
	cp $73
	jr c, .groupB

;> elif s < 0x75: group = 'A'
	cp $75
	jr c, .groupA

;> elif s < 0x77: group = 'B'
	cp $77
	jr c, .groupB

;> elif s < 0x78: group = 'A'
	cp $78
	jr c, .groupA

;> elif s < 0x7B: group = 'B'
	cp $7b
	jr c, .groupB

;> elif s == 0x80: group = 'B'
	cp $80
	jr z, .groupB

;> elif s < 0x84: group = 'A'
	cp $84
	jr c, .groupA

;> elif s < 0x88: group = 'B'
	cp $88
	jr c, .groupB

;> elif s < 0x91: group = 'A'
	cp $91
	jr c, .groupA

;> elif s == 0x95: group = 'A'
	cp $95
	jr z, .groupA

;> elif s < 0x97: group = 'B'
	cp $97
	jr c, .groupB

;> elif s == 0xA3: group = 'B'
	cp $a3
	jr z, .groupB

;> elif s < 0xA4: group = 'A'
	cp $a4
	jr c, .groupA

;> elif s < 0xA7: group = 'A'
	cp $a7
	jr c, .groupA

;> elif s == 0xA9: group = 'A'
	cp $a9
	jr z, .groupA

;> elif s < 0xAB: group = 'B'
	cp $ab
	jr c, .groupB

;> elif s == 0xAE: group = 'B'
	cp $ae
	jr z, .groupB

;> elif s < 0xB0: group = 'A'
	cp $b0
	jr c, .groupA

;> elif s < 0xC7: group = 'B'
	cp $c7
	jr c, .groupB

;> elif s == 0xC9: group = 'B'
	cp $c9
	jr z, .groupB

;> elif s < 0xD5: group = 'D'
	cp $d5
	jr c, .groupD

;> elif s == 0xD5: group = 'B'
	cp $d5
	jr z, .groupB

;> else: group = 'A'
	jr .groupA

.groupB
;> if group == 'B':
;>@b1     if s != 0x80 and wBattleStep == 7:      # during a monster's action
	ld a, [wSkillId]
	cp $80
	jp z, .show

;=@b1
	ld a, [wBattleStep]
	cp $07
	jr nz, .show

;>         if wBattleSubStep == 0x0A:
;>@e1             if wBattleStepArg0 == 1: return
	ld a, [wBattleSubStep]
	cp $0a
	jr z, .subStepA

;>@b2         elif wBattleSubStep == 1 and wBattleSubStep2 < 0x0E:
	cp $01
	jr nz, .show

;=@b2
	ld a, [wBattleSubStep2]
	cp $0e
	jr nc, .show

;>             return
	ret


.groupA
;> elif group == 'A':
;>     if wBattleStep == 7:
	ld a, [wBattleStep]
	cp $07
	jr nz, .show

;>         if wBattleSubStep == 0x0A:
;>@e2             if wBattleStepArg0 == 1: return
	ld a, [wBattleSubStep]
	cp $0a
	jr z, .subStepA

;>@a1         elif wBattleSubStep == 1 and wBattleSubStep2 != 5:
	cp $01
	jr nz, .show

;=@a1
	ld a, [wBattleSubStep2]
	cp $05
	jr z, .show

;>             return
	ret


.groupC
;> elif group == 'C':
;>@c1     if wBattleStep == 7 and wBattleSubStep != 4:
	ld a, [wBattleStep]
	cp $07
	jr nz, .show

;=@c1
	ld a, [wBattleSubStep]
	cp $04
	jr z, .show

;>         return
	ret


.groupD
;> elif group == 'D':
;>@d1     if wBattleStep == 7 and wBattleSubStep == 0x0A and wBattleStepArg0 == 4:
	ld a, [wBattleStep]
	cp $07
	jr nz, .show

;=@d1
	ld a, [wBattleSubStep]
	cp $0a
	jr nz, .show

;=@d1
	ld a, [wBattleStepArg0]
	cp $04
	jr nz, .show

;>         return
	ret


.subStepA
;=@e1
;=@e2
	ld a, [wBattleStepArg0]
	cp $01
	ret z

.show
;> if wSkillUser == 0x10:                    # the skill comes from no battle position
;>@n1     if IsTargetOwnSide():
;>@n2         return
;>@n3     own = True
	ld a, [wSkillUser]
	cp $10
	jr z, .noUser

;> elif wLinkFlags & 0x02:                   # clock-driving Game Boy: its own monsters are 4-7
;>@m1     own = wSkillUser >= 4
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .linkMaster

;> else:
;>     own = wSkillUser < 4
	ld a, [wSkillUser]
	cp $04
	jr c, .ownTable

	jr .enemyTable

.linkMaster
;=@m1
	ld a, [wSkillUser]
	cp $04
	jr c, .enemyTable

	jr .ownTable

.noUser
;=@n1
	call IsTargetOwnSide
;=@n2
;=@n3
	ret c

.ownTable
;> if own:
;>     table = SkillVisualsOwn
	ld hl, SkillVisualsOwn
	jr .lookUp

.enemyTable
;> else:
;>     table = SkillVisualsEnemy
	ld hl, SkillVisualsEnemy
;>@k     if wLinkActive and wBattleStep == 7 and wBattleSubStep == 1 and wBattleSubStep2 == 5:
	ld a, [wLinkActive]
	or a
	jr z, .lookUp

;=@k
	ld a, [wBattleStep]
	cp $07
	jr nz, .lookUp

;=@k
	ld a, [wBattleSubStep]
	cp $01
	jr nz, .lookUp

;=@k
	ld a, [wBattleSubStep2]
	cp $05
	jr nz, .lookUp

;>         table = SkillVisualsLink          # the other player's monster in a link battle
	ld hl, SkillVisualsLink

.lookUp
;> p = table + wSkillId
	ld a, [wSkillId]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> RunSkillVisual(mem[p])
	ld a, [hl]
	call RunSkillVisual
;> return
	ret


;@ def RunSkillVisual(visual: a)
;@ path: battle/animation
;@ Runs entry `visual` of SkillVisualRoutines: starts a skill animation or a screen effect.
;@ The byte after it (a `jp hl`) is never reached.
;@ test: skip jumps through a table to routines that call other banks
RunSkillVisual::
;> SkillVisualRoutines[visual]()
	ld c, a
	ld b, $00
	ld hl, SkillVisualRoutines
	add hl, bc
	add hl, bc
	call JumpToPointer
;> return
	ret


	db $e9

;@ def SetSkillAnimPlace()
;@ path: battle/animation
;@ Works out where on the screen the skill animation is drawn (wItemMsgGroup: 1 the single
;@ monster or the middle one of three, 2/3 the left/right one of two, 4/6 the left/right one
;@ of three, 8 nowhere) from a slot (battle position & 3) and the number of monsters on that
;@ side (also kept in wBattleItemUsedUp). Normally it is the target's slot on this Game Boy's
;@ enemy side. Skills $1A, $1B, $29 and $76 of an enemy-side monster are drawn at the user. An
;@ enemy-side monster's skill aimed at the own side uses the user's slot but the own side's
;@ number of monsters.
;@ test: skip calls IsUserOwnSide / IsTargetOwnSide
SetSkillAnimPlace::
;> s = wSkillId
	ld a, [wSkillId]
;>@u if s in (0x1A, 0x1B, 0x29, 0x76) and not IsUserOwnSide():   # drawn at the enemy-side user
	cp $1a
	jr c, .notAtUser

	cp $1c
	jr c, .atUser

;=@u
	cp $29
	jr z, .atUser

	cp $76
	jr nz, .notAtUser

.atUser
;=@u
	call IsUserOwnSide
	jr c, .notAtUser

;>     i = (wLinkFlags & 0x02) >> 1 ^ 1      # 1: wEnemyCount (0: wPartyBattlers on the clock-driving Game Boy)
	ld hl, wPartyBattlers
	ld a, [wLinkFlags]
	and $02
	srl a
	xor $01
;>     count = mem[wPartyBattlers + i]       # monsters on this Game Boy's enemy side
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>     wBattleItemUsedUp = count
	ld [wBattleItemUsedUp], a
;>     if count == 1:
;>@uo         place = 8 if wSkillUser & 3 >= 3 else 1
	ld a, [hl]
	cp $01
	jr z, .userOne

;>     elif count == 2:
;>@ut         place = [2, 3, 8, 8][wSkillUser & 3]
	cp $02
	jr z, .userTwo

;>     else:
;>@uh         place = [4, 1, 6, 8][wSkillUser & 3]
	ld a, [wSkillUser]
	and $03
	cp $01
	jr z, .userOne

;=@uh
	jr c, .userLeft

	cp $03
	jp nc, .nowhere

	ld a, $06
	jr .storeUser

.userLeft
;=@uh
	ld a, $04
	jr .storeUser

.userTwo
;=@ut
	ld a, [wSkillUser]
	and $03
	cp $03
	jp nc, .nowhere

;=@ut
	cp $01
	jr z, .userRight

	ld a, $02
	jr .storeUser

.userRight
;=@ut
	ld a, $03
	jr .storeUser

.userOne
;=@uo
;=@uh
	ld a, [wSkillUser]
	and $03
	cp $03
	jp nc, .nowhere

	ld a, $01

.storeUser
;>     wItemMsgGroup = place
;>     return
	ld [wItemMsgGroup], a
	ret


.notAtUser
;>@t if IsUserOwnSide() or (wSkillTarget & 3 < 3 and not IsTargetOwnSide()):   # at the target
	call IsUserOwnSide
	jr nc, .enemyUser

.atTarget
;>     i = (wLinkFlags & 0x02) >> 1 ^ 1
	ld hl, wPartyBattlers
	ld a, [wLinkFlags]
	and $02
	srl a
	xor $01
;>     count = mem[wPartyBattlers + i]       # monsters on this Game Boy's enemy side
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>     wBattleItemUsedUp = count
	ld [wBattleItemUsedUp], a
;>     if count == 1:
;>@to         place = 8 if wSkillTarget & 3 >= 3 else 1
	ld a, [hl]
	cp $01
	jr z, .targetOne

;>     elif count == 2:
;>@tt         place = [2, 3, 8, 8][wSkillTarget & 3]
	cp $02
	jr z, .targetTwo

;>     else:
;>@th         place = [4, 1, 6, 8][wSkillTarget & 3]
	ld a, [wSkillTarget]
	and $03
	cp $01
	jr z, .targetOne

;=@th
	jr c, .targetLeft

	cp $03
	jr nc, .nowhere

	ld a, $06
	jr .store

.targetLeft
;=@th
	ld a, $04
	jr .store

.targetTwo
;=@tt
	ld a, [wSkillTarget]
	and $03
	cp $01
	jr z, .targetRight

;=@tt
	cp $03
	jr nc, .nowhere

	ld a, $02
	jr .store

.targetRight
;=@tt
	ld a, $03
	jr .store

.targetOne
;=@to
;=@th
	ld a, [wSkillTarget]
	and $03
	cp $03
	jp nc, .nowhere

	ld a, $01

.store
;>     wItemMsgGroup = place
;>     return
	ld [wItemMsgGroup], a
	ret


.nowhere
;> elif wSkillTarget & 3 >= 3:               # (also where every place 8 above ends up)
;>     wItemMsgGroup = 8                      # nowhere
	ld a, $08
	ld [wItemMsgGroup], a
;>     return
	ret


.enemyUser
;=@t
	ld a, [wSkillTarget]
	and $03
	cp $03
	jr nc, .nowhere

;=@t
	call IsTargetOwnSide
	jr nc, .atTarget

;> else:                                     # an enemy-side monster's skill aimed at the own side
;>     i = (wLinkFlags & 0x02) >> 1          # 0: wPartyBattlers (1: wEnemyCount on the clock-driving Game Boy)
	ld hl, wPartyBattlers
	ld a, [wLinkFlags]
	and $02
	srl a
;>     count = mem[wPartyBattlers + i]       # monsters on the own side
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>     wBattleItemUsedUp = count
	ld [wBattleItemUsedUp], a
;>     if count == 1:
;>@eo         place = 8 if wSkillUser & 3 >= 3 else 1
	ld a, [hl]
	cp $01
	jr z, .ownOne

;>     elif count == 2:
;>@et         place = [2, 3, 8, 8][wSkillUser & 3]
	cp $02
	jr z, .ownTwo

;>     else:
;>@eh         place = [4, 1, 6, 8][wSkillUser & 3]
	ld a, [wSkillUser]
	and $03
	cp $01
	jr z, .ownOne

;=@eh
	jr c, .ownLeft

	and $03
	cp $03
	jr nc, .nowhere

;=@eh
	ld a, $06
	jr .store

.ownLeft
;=@eh
	ld a, $04
	jr .store

.ownTwo
;=@et
	ld a, [wSkillUser]
	and $03
	cp $01
	jr z, .ownRight

;=@et
	cp $03
	jp nc, .nowhere

	ld a, $02
	jr .store

.ownRight
;=@et
	ld a, $03
	jr .store

.ownOne
;=@eo
;=@eh
	ld a, [wSkillUser]
	and $03
	cp $03
	jp nc, .nowhere

	ld a, $01
;>     wItemMsgGroup = place                 # (through the target case's store)
;>     return
	jr .store

;@ def SkillVisualAtTarget()
;@ path: battle/animation
;@ Skill visual 0: the skill animation starts at the place of its target (SetSkillAnimPlace).
;@ test: skip calls routines in other banks
SkillVisualAtTarget::
;> SetSkillAnimPlace()
	call SetSkillAnimPlace
;> wSkillAnimPhase = 1
	ld a, $01
	ld [wSkillAnimPhase], a
;> StartSkillAnimation()
	jr StartSkillAnimation

;@ def SkillVisualCenter()
;@ path: battle/animation
;@ Skill visual 1: the skill animation starts in the middle of the enemy side (place 1).
;@ test: skip calls routines in other banks
SkillVisualCenter::
;> wItemMsgGroup = 1                         # place: the middle
	ld a, $01
	ld [wItemMsgGroup], a
;> wSkillAnimPhase = 1
	ld a, $01
	ld [wSkillAnimPhase], a
;> StartSkillAnimation()
	jr StartSkillAnimation

;@ def SkillVisualAtTarget2()
;@ path: battle/animation
;@ Skill visual 2: the skill animation starts at the place of its target, in phase 2.
;@ test: skip calls routines in other banks
SkillVisualAtTarget2::
;> SetSkillAnimPlace()
	call SetSkillAnimPlace
;> wSkillAnimPhase = 2
	ld a, $02
	ld [wSkillAnimPhase], a
;> StartSkillAnimation()
	jr StartSkillAnimation

;@ def SkillVisualFlyIn()
;@ path: battle/animation
;@ Skill visual 3: the skill animation flies in from the left (phase 0, no place); goes on
;@ into StartSkillAnimation.
;@ test: skip calls routines in other banks
SkillVisualFlyIn::
;> wItemMsgGroup = 0
	ld a, $00
	ld [wItemMsgGroup], a
;> wSkillAnimPhase = 0
	ld a, $00
	ld [wSkillAnimPhase], a
;> StartSkillAnimation()

;@ def StartSkillAnimation()
;@ path: battle/animation
;@ Looks up the skill animation (GetSkillAnim) and, if there is one, starts its animation
;@ object and its sprites and sets wSkillAnimActive. Its final `ret` is also skill visual 13
;@ (nothing shown).
;@ test: skip calls routines in other banks
StartSkillAnimation::
;> GetSkillAnim()
	call GetSkillAnim
;> if wSkillAnim == 0xFF:
;>     return
	cp $ff
	ret z

;> StartSkillAnimObject()
	call StartSkillAnimObject
;> StartSkillAnimSprites()
	call StartSkillAnimSprites
;> wSkillAnimActive = 1
	ld a, $01
	ld [wSkillAnimActive], a
;> return
	ret
;@ def SkillVisualFlash()
;@ path: battle/effects
;@ Skill visual 4: screen effect 4, the screen flashes.
;@ test: skip calls a routine with its own tables
SkillVisualFlash::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 4
	ld a, $04
	ld [wScreenEffect], a
	ret

;@ def SkillVisualDarken()
;@ path: battle/effects
;@ Skill visual 5: screen effect 5, the screen darkens and comes back.
;@ test: skip calls a routine with its own tables
SkillVisualDarken::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 5
	ld a, $05
	ld [wScreenEffect], a
	ret

;@ def SkillVisualInvert()
;@ path: battle/effects
;@ Skill visual 6: screen effect 6, the palettes are inverted for a while.
;@ test: skip calls a routine with its own tables
SkillVisualInvert::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 6
	ld a, $06
	ld [wScreenEffect], a
	ret

;@ def SkillVisualDarkenTwice()
;@ path: battle/effects
;@ Skill visual 7: screen effect 7, the screen darkens twice.
;@ test: skip calls a routine with its own tables
SkillVisualDarkenTwice::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 7
	ld a, $07
	ld [wScreenEffect], a
	ret

;@ def SkillVisualQuake()
;@ path: battle/effects
;@ Skill visual 8: screen effect 8, the screen quakes.
;@ test: skip calls a routine with its own tables
SkillVisualQuake::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 8
	ld a, $08
	ld [wScreenEffect], a
	ret

;@ def SkillVisualWave()
;@ path: battle/effects
;@ Skill visual 9: screen effect 9, the picture waves.
;@ test: skip calls a routine with its own tables
SkillVisualWave::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 9
	ld a, $09
	ld [wScreenEffect], a
	ret

;@ def SkillVisualLighten()
;@ path: battle/effects
;@ Skill visual 10: screen effect 10, the screen lightens and comes back.
;@ test: skip calls a routine with its own tables
SkillVisualLighten::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 10
	ld a, $0a
	ld [wScreenEffect], a
	ret

;@ def SkillVisualFlashLong()
;@ path: battle/effects
;@ Skill visual 11: screen effect 11, a long flash.
;@ test: skip calls a routine with its own tables
SkillVisualFlashLong::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 11
	ld a, $0b
	ld [wScreenEffect], a
	ret

;@ def SkillVisualShakeX()
;@ path: battle/effects
;@ Skill visual 12: screen effect 12, the screen shakes sideways.
;@ test: skip calls a routine with its own tables
SkillVisualShakeX::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 12
	ld a, $0c
	ld [wScreenEffect], a
	ret

;@ def SkillVisualShakeY()
;@ path: battle/effects
;@ Skill visual 14: screen effect 3, the screen shakes up and down.
;@ test: skip calls a routine with its own tables
SkillVisualShakeY::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 3
	ld a, $03
	ld [wScreenEffect], a
	ret

;@ def SkillVisualBlinkUser()
;@ path: battle/effects
;@ Skill visual 15: screen effect 13, the user's picture blinks.
;@ test: skip calls a routine with its own tables
SkillVisualBlinkUser::
;> StartSkillHitEffect()
	call StartSkillHitEffect
;> wScreenEffect = 13
	ld a, $0d
	ld [wScreenEffect], a
	ret

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


StartSkillAnimObject::
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
	jr c, AnimViewerAnimChanged

	xor a
	ld [wMenuChoice2], a

AnimViewerAnimChanged:
	call AnimViewerDrawAnimNumber
	ret


AnimViewerPrevAnim::
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
	ld a, [wMenuChoice2]
	cp $2d
	jr c, AnimViewerAnimChanged

	ld a, $2c
	ld [wMenuChoice2], a
	jr AnimViewerAnimChanged

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
	jr c, AnimViewerBGChanged

	xor a
	ld [wConfirmChoice2], a

AnimViewerBGChanged:
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
	jr c, AnimViewerBGChanged

	ld a, $d7
	ld [wConfirmChoice2], a
	jr AnimViewerBGChanged

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
	jr c, AnimViewerEffectChanged

	xor a
	ld [wListLastRows], a

AnimViewerEffectChanged:
	call AnimViewerDrawEffectNumber
	ret


AnimViewerPrevEffect::
	ld a, [wListLastRows]
	dec a
	ld [wListLastRows], a
	ld a, [wListLastRows]
	cp $0d
	jr c, AnimViewerEffectChanged

	ld a, $0c
	ld [wListLastRows], a
	jr AnimViewerEffectChanged

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
	call DrawDebugStatsColumn
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
	call DrawDebugStatsColumn
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
	call DrawDebugStatsColumn

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


DrawDebugStatsColumn::
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

CreditsLastUnusedRows::
	db $e0, $e0, $68, $69, $6a, $6b, $6c, $6d, $6e
	db $6f, $70, $71, $72, $aa, $ab, $ac, $ad, $ae, $af, $e0, $e0, $e0, $e0, $e0, $73
	db $74, $75, $76, $77, $78, $79, $7a, $7b, $b0, $b1, $b2, $b3, $b4, $b5, $e0, $e0
	db $e0, $7e, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $b6, $b7, $b8, $b9
	db $ba, $bb, $e0, $e0, $e0, $e0, $e0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
	db $bc, $bd, $be, $bf, $c0, $c1, $e0, $e0, $e0, $94, $95, $96, $97, $98, $99, $9a
	db $9b, $9c, $9d, $9e, $c2, $c3, $c4, $c5, $c6, $c7, $e0, $e0, $e0, $e0, $e0, $9f
	db $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $c8, $c9, $ca, $cb, $cc, $cd, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0

UnusedSpace_5F::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
