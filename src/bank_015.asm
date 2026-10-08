INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $015", ROMX[$4000], BANK[$15]

;@ path: title/mode
;@ Bank $15 holds game mode 0: the opening, the title menu (continue, new game) and the two
;@ link-cable modes started from it, VS mode and breeding with a friend.
BankNumber_15::
	db $15

;@ path: title/mode
;@ Far-call entry points of bank $15: mode 0 start-up, mode 0 per-frame routine, and the frame
;@ logic of link modes 2 (VS mode) and 3 (breeding) that the serial interrupt runs.
FarTable_15::
	dw TitleModeInit
	dw TitleModeUpdate
	dw VSLinkFrame
	dw BreedLinkFrame

;@ def TitleModeInit()
;@ path: title/mode
;@ Start-up of game mode 0: saves the stack pointer, clears the menu and text box state and runs
;@ the start-up routine of the current step (0 opening, 1 title menu, 2 VS mode, 3 breeding).
;@ test: skip calls routines in other banks
TitleModeInit::
;> wFieldStackPtr = sp
	ld hl, sp+$00
	ld a, l
	ld [wFieldStackPtr], a
	ld a, h
	ld [$da7c], a
;> fill(wMenuChoice, 0, 8)               # menu cursors
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
;> fill(wTextTiles, 0, 0x12)             # text box set-up
	xor a
	ld hl, wTextTiles
	ld bc, $0012
	call FillMemory
;> wTextBoxMap = 0x99C1
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [$c83f], a
;> fill(wTitleStep, 0, 8)
	xor a
	ld hl, wTitleStep
	ld bc, $0008
	call FillMemory
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> TitleModeInitTable[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: title/mode
;@ Start-up routine of each step of game mode 0.
TitleModeInitTable::
	dw TitleInitOpening
	dw TitleInitMenu
	dw TitleInitVSLink
	dw TitleInitBreedLink

;@ def TitleInitOpening()
;@ path: title/mode
;@ Step 0: starts the opening (bank $5F draws it) and turns the screen on with only the VBlank
;@ interrupt.
;@ test: skip calls routines in other banks
TitleInitOpening::
;> wSGBPalSet = 0; wSGBAttrSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> OpeningInit()                       # set up the opening
	ld hl, far_OpeningInit
	rst $10
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> hWX = 7; hWY = 0xFF                   # window off screen
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0; hScrollX = 0
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLinkMode = 0; wLinkPhase = 0
	ld a, $00
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
;> wLinkActive = 0; wLinkCommand = 0
	ld [wLinkActive], a
	ld [wLinkCommand], a
;> wLinkFlags = 0; wSerialLock = 0
	xor a
	ld [wLinkFlags], a
	ld [wSerialLock], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x01)          # VBlank only
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def TitleInitMenu()
;@ path: title/mode
;@ Step 1: the title menu. Loads the SGB border and palettes, checks the save file, clears the
;@ game state, unpacks the font and window tiles, sets up the text box, clears the screen and
;@ starts the title music; turns the screen on with the VBlank and serial interrupts (a friend
;@ may connect a link cable while the menu is open).
;@ test: skip calls routines in other banks
TitleInitMenu::
;> LoadSGBBorder(2)
	ld a, $02
	call LoadSGBBorder
;> SGBPacketDelay()
	call SGBPacketDelay
;> wSGBPalSet = 0; wSGBAttrSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> SetSharedBGColors()
	ld hl, far_SetSharedBGColors
	rst $10
;> ClearAttrMap()
	ld hl, far_ClearAttrMap
	rst $10
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> fill(hPlayerGfx, 0, 0x21)              # HRAM part of the game state
	ld hl, hPlayerGfx
	ld bc, $0021
	xor a
	call FillMemory
;> fill(wGameStarted, 0, 0x1100)          # WRAM part of the game state
	ld hl, wGameStarted
	ld bc, $1100
	xor a
	call FillMemory
;> wMessageSpeed = 4
	ld a, $04
	ld [wMessageSpeed], a
;> CheckSaveChecksum()
	call CheckSaveChecksum
;> Decompress(0x2E1E, 0x9000)            # font
	ld de, $2e1e
	ld hl, $9000
	call Decompress
;> Decompress(0x2E1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call Decompress
;> Decompress(0x2E20, 0x8A00)
	ld de, $2e20
	ld hl, $8a00
	call Decompress
;> Decompress(0x2E00, 0x8D00)            # window frame tiles
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> SetUpTextBox(0x8B00, 0x1202)          # 18 letters, 2 lines
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> fill(wMenuChoice, 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(wTitleStep, 0, 8)
	xor a
	ld hl, wTitleStep
	ld bc, $0008
	call FillMemory
;> wTitleBgMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wTitleBgMap], a
	ld a, h
	ld [$c8d7], a
;> ClearBgMap_15()
	call ClearBgMap_15
;> QueueMusic(0x24)                      # title menu music
	ld a, $24
	call QueueMusic
;> hWX = 7; hWY = 0xFF
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0; hScrollX = 0
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLinkMode = 0; wLinkPhase = 0
	ld a, $00
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
;> wSerialLock = 0; wLinkActive = 0
	xor a
	ld [wSerialLock], a
	ld [wLinkActive], a
;> wLinkCommand = 0
	ld [wLinkCommand], a
;> wLinkFlags = 0; wSerialLock = 0
	xor a
	ld [wLinkFlags], a
	ld [wSerialLock], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x09)          # VBlank and serial
	ld a, $09
	jp EnableLCDAndInterrupts


;@ def TitleInitVSLink()
;@ path: link/vs
;@ Step 2: VS mode over the link cable. Loads the font and window tiles, sets up the text box,
;@ clears the screen and the scratch buffer and starts the menu music; the link stays up (the
;@ serial interrupt runs link mode 2 from here on).
;@ test: skip calls routines in other banks
TitleInitVSLink::
;> wSGBPalSet = 0; wSGBAttrSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> wMessageSpeed = 4
	ld a, $04
	ld [wMessageSpeed], a
;> CheckSaveChecksum()
	call CheckSaveChecksum
;> Decompress(0x2E1E, 0x9000)
	ld de, $2e1e
	ld hl, $9000
	call Decompress
;> Decompress(0x2E1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call Decompress
;> Decompress(0x2E20, 0x8A00)
	ld de, $2e20
	ld hl, $8a00
	call Decompress
;> Decompress(0x2E00, 0x8D00)
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> SetUpTextBox(0x8B00, 0x1202)
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> fill(wMenuChoice, 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(wTitleStep, 0, 8)
	xor a
	ld hl, wTitleStep
	ld bc, $0008
	call FillMemory
;> wTitleBgMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wTitleBgMap], a
	ld a, h
	ld [$c8d7], a
;> ClearBgMap_15()
	call ClearBgMap_15
;> fill(wSceneObjects, 0xFF, 0x17)
	ld hl, wSceneObjects
	ld bc, $0017
	ld a, $ff
	call FillMemory
;> QueueMusic(0x24)
	ld a, $24
	call QueueMusic
;> hWX = 7; hWY = 0xFF
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0; hScrollX = 0
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;> wLinkReceivedLast = 0
	xor a
	ld [wLinkReceivedLast], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x09)
	ld a, $09
	jp EnableLCDAndInterrupts


;@ def TitleInitBreedLink()
;@ path: link/breed
;@ Step 3: breeding over the link cable. The same set-up as VS mode (without clearing the
;@ scratch buffer); the serial interrupt runs link mode 3.
;@ test: skip calls routines in other banks
TitleInitBreedLink::
;> wSGBPalSet = 0; wSGBAttrSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> StartFade(0xFC)
	ld a, $fc
	call StartFade
;> wMessageSpeed = 4
	ld a, $04
	ld [wMessageSpeed], a
;> CheckSaveChecksum()
	call CheckSaveChecksum
;> Decompress(0x2E1E, 0x9000)
	ld de, $2e1e
	ld hl, $9000
	call Decompress
;> Decompress(0x2E1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call Decompress
;> Decompress(0x2E20, 0x8A00)
	ld de, $2e20
	ld hl, $8a00
	call Decompress
;> Decompress(0x2E00, 0x8D00)
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> SetUpTextBox(0x8B00, 0x1202)
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> fill(wMenuChoice, 0, 8)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(wTitleStep, 0, 8)
	xor a
	ld hl, wTitleStep
	ld bc, $0008
	call FillMemory
;> wTitleBgMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wTitleBgMap], a
	ld a, h
	ld [$c8d7], a
;> ClearBgMap_15()
	call ClearBgMap_15
;> QueueMusic(0x24)
	ld a, $24
	call QueueMusic
;> hWX = 7; hWY = 0xFF
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0; hScrollX = 0
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;> wLinkReceivedLast = 0
	xor a
	ld [wLinkReceivedLast], a
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x09)
	ld a, $09
	jp EnableLCDAndInterrupts


;@ def TitleModeUpdate()
;@ path: title/mode
;@ Per-frame routine of game mode 0: runs the current step (0 opening, 1 title menu, 2 VS mode,
;@ 3 breeding).
;@ test: skip calls routines in other banks
TitleModeUpdate::
;> TitleModeUpdateTable[wGameModeStep]()
	ld a, [wGameModeStep]
	rst $00

;@ path: title/mode
;@ Per-frame routine of each step of game mode 0.
TitleModeUpdateTable::
	dw TitleUpdateOpening
	dw TitleUpdateMenu
	dw TitleUpdateVSLink
	dw TitleUpdateBreedLink
	db $c9

;@ def TitleUpdateOpening()
;@ path: title/mode
;@ Step 0: answers a linked Game Boy with $F4 ("in the title screen, not ready") and runs a
;@ frame of the opening in bank $5F.
;@ test: skip calls routines in other banks
TitleUpdateOpening::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> far_call(0x5F, 0x03)                 # one frame of the opening
	ld hl, $5f03
	rst $10
	ret


;@ def TitleUpdateMenu()
;@ path: title/menu
;@ Step 1: runs the title menu. When the player picked VS mode or breeding, the request byte
;@ ($F0 or $F1, in wLinkCommand) is sent once with this Game Boy driving the clock, and the
;@ routine waits for the transfer to finish.
;@ test: skip runs the serial link
TitleUpdateMenu::
;> RunTitleMenu()
	call RunTitleMenu
;> disable_interrupts()
	di
;> if wLinkCommand:
	ld a, [wLinkCommand]
	or a
	jr z, .done

;>     b = wLinkCommand; wLinkCommand = 0
	ld a, [wLinkCommand]
	ld b, a
	xor a
	ld [wLinkCommand], a
;>     if not wGameModeChange:
	ld a, [wGameModeChange]
	or a
	jr nz, .done

;>         SerialSendMaster(b)
	ld a, b
	call SerialSendMaster

.wait
;>         while wSerialLock & 0x03 != 0x03:
;>             wait_serial()
	ld a, [wSerialLock]
	and $03
	cp $03
	jr nz, .wait

.done
;> enable_interrupts()
	ei
	ret


;@ def RunTitleMenu()
;@ path: title/menu
;@ Runs the current step of the title menu (wTitleStep).
;@ test: skip calls routines in other banks
RunTitleMenu::
;> TitleMenuSteps[wTitleStep]()
	ld a, [wTitleStep]
	rst $00

;@ path: title/menu
;@ Steps of the title menu: draw it, move the cursor, run the choice, start the field, show
;@ the link error, wait for its text.
TitleMenuSteps::
	dw TitleMenuOpen
	dw TitleMenuChoose
	dw TitleMenuRunChoice
	dw TitleMenuStartField
	dw TitleMenuLinkMismatch
	dw TitleMenuLinkMismatchWait

;@ def TitleMenuOpen()
;@ path: title/menu
;@ Draws the title menu: only NEW GAME without a saved game, else CONTINUE, NEW GAME, VS MODE
;@ and BREEDING, with the cursor where it was.
;@ test: skip touches battery RAM and VRAM
TitleMenuOpen::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> window = TitleWindowNoSave
	ld de, TitleWindowNoSave
;> if ReadSRAMByte(sSaveValid):
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr z, .drawWindow

;>     window = TitleWindowWithSave
	ld de, TitleWindowWithSave

.drawWindow
;> DrawWindowLayout_15(window)
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> marks = TitleCursorOne
	ld de, TitleCursorOne
;> if ReadSRAMByte(sSaveValid):
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr z, .drawCursor

;>     marks = TitleCursorFour
	ld de, TitleCursorFour

.drawCursor
;> wLinkRefused = 0
	xor a
	ld [wLinkRefused], a
;> wLinkPartnerChoice = wMenuChoice
	ld a, [wMenuChoice]
	ld [wLinkPartnerChoice], a
;> MenuDrawCursorAt_15(wMenuChoice, marks)
	call MenuDrawCursorAt_15
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def TitleMenuChoose()
;@ path: title/menu
;@ Moves the title menu cursor and tells a linked Game Boy where it stands ($F4, or $F2 on VS
;@ MODE and $F3 on BREEDING). A partner asking for a link mode moves the cursor there
;@ (wLinkPartnerChoice, set by the serial handshake). A chooses.
;@ test: skip touches battery RAM and the serial link
TitleMenuChoose::
;> if wFadeState:
;>     return SerialSendSlave(0xF4)
	ld a, [wFadeState]
	or a
	ld a, $f4
	call nz, SerialSendSlave
	ret nz

;> marks = TitleCursorOne; count = 1
	ld de, TitleCursorOne
	ld b, $01
;> if ReadSRAMByte(sSaveValid):
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr z, .move

;>     marks = TitleCursorFour; count = 4
	ld de, TitleCursorFour
	ld b, $04

.move
;> wMenuChoice = wLinkPartnerChoice
	ld hl, wMenuChoice
	ld a, [wLinkPartnerChoice]
	ld [wMenuChoice], a
;> MoveMenuCursor_15(wMenuChoice, count, marks)
	call MoveMenuCursor_15
;> wLinkPartnerChoice = wMenuChoice
	ld a, [wMenuChoice]
	ld [wLinkPartnerChoice], a
;> sends = TitleSendOne
	ld de, TitleSendOne
;> if ReadSRAMByte(sSaveValid):
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr z, .send

;>     sends = TitleSendFour
	ld de, TitleSendFour

.send
;> i = wMenuChoice & 0x7F
	ld a, [wMenuChoice]
	and $7f
;> p = sends + i
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> SerialSendSlave(mem[p])
	ld a, [de]
	call SerialSendSlave
;> if wJoyPressed & A_BUTTON:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     if wMenuChoice & 0x7F not in (2, 3):
	ld a, [wMenuChoice]
	and $7f
	cp $02
	jr z, .next

	cp $03
	jr z, .next

;>         QueueSound(0x59)            # the link modes beep once the partner answers
	ld a, $59
	call QueueSound

.next
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;>     wTitleSubStep = 0
	xor a
	ld [wTitleSubStep], a

.done
	ret


;@ path: title/menu
;@ Cursor position of the title menu without a saved game (tilemap buffer offset; $FFFF ends).
TitleCursorOne::
	dw $0021
	dw $ffff

;@ path: title/menu
;@ Byte sent to a linked Game Boy for the one entry (see TitleSendFour).
TitleSendOne::
	db $f4

;@ path: title/menu
;@ Cursor positions of the four title menu entries (tilemap buffer offsets; $FFFF ends).
TitleCursorFour::
	dw $0021, $0061, $00a1, $00e1
	dw $ffff

;@ path: title/menu
;@ Byte sent to a linked Game Boy each frame for the entry under the cursor: $F4 for CONTINUE
;@ and NEW GAME, $F2 for VS MODE, $F3 for BREEDING.
TitleSendFour::
	db $f4, $f4, $f2, $f3

;@ def TitleMenuRunChoice()
;@ path: title/menu
;@ Runs the chosen title menu entry. Without a saved game the only entry is NEW GAME, so the
;@ cursor number is moved up by one.
;@ test: skip calls routines in other banks
TitleMenuRunChoice::
;> choice = wMenuChoice & 0x7F
	ld a, [wMenuChoice]
	and $7f
	ld b, a
;> if not ReadSRAMByte(sSaveValid):
	ld hl, sSaveValid
	call ReadSRAMByte
	or a
	jr nz, .run

;>     choice += 1
	inc b

.run
;> TitleMenuChoiceTable[choice]()
	ld a, b
	rst $00

;@ path: title/menu
;@ What each title menu entry does: continue, new game, VS mode, breeding.
TitleMenuChoiceTable::
	dw TitleContinue
	dw TitleNewGame
	dw TitleChooseVS
	dw TitleChooseBreed

;@ def TitleMenuStartField()
;@ path: title/menu
;@ Leaves the title: fades out and switches to game mode 1, the field (step 0).
;@ test: skip starts a serial transfer
TitleMenuStartField::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> StartFade(0x04)
	ld a, $04
	call StartFade
;> wGameMode = 1; wGameModeStep = 0
	ld a, $01
	ld [wGameMode], a
	ld a, $00
	ld [wGameModeStep], a
;> mem[0xC88C] = 0; mem[0xC88D] = 0
	ld a, $00
	ld [wOpeningScene], a
	ld a, $00
	ld [wOpeningLogo], a
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
	ret


;@ def TitleMenuLinkMismatch()
;@ path: title/menu
;@ The partner refused the link mode (it chose the other one, or has no saved game): shows the
;@ "not ready for link up" message (another text on a Super Game Boy) in a text box.
;@ test: skip calls routines in other banks
TitleMenuLinkMismatch::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> if wOnSGB == 1:
	ld a, [wOnSGB]
	cp $01
	jr nz, .notSGB

;>     PrintSystemText(0x0270)
	ld hl, $0270
	call PrintSystemText
;>     DrawWindowLayout_15(0x2E07)      # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;> else:
;>     PrintSystemText(0x021B)          # "Not ready for link up. Check and try again."
.notSGB
	ld hl, $021b
	call PrintSystemText
;>     DrawWindowLayout_15(0x2E07)
	ld de, $2e07
	call DrawWindowLayout_15
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def TitleMenuLinkMismatchWait()
;@ path: title/menu
;@ Waits until the link error message is done, then draws the title menu again.
;@ test: skip starts a serial transfer
TitleMenuLinkMismatchWait::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wTitleStep = 0
	xor a
	ld [wTitleStep], a
	ret


;@ def TitleContinue()
;@ path: title/continue
;@ CONTINUE: runs its sub-step (show the saved game, then wait for A or B).
;@ test: skip starts a serial transfer
TitleContinue::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> TitleContinueSteps[wTitleSubStep]()
	ld a, [wTitleSubStep]
	rst $00

;@ path: title/continue
;@ Sub-steps of CONTINUE.
TitleContinueSteps::
	dw ContinueShowSave
	dw ContinueConfirm

;@ def ContinueShowSave()
;@ path: title/continue
;@ CONTINUE, first frame: loads the saved game from battery RAM and the map palettes, then
;@ shows the save's summary (ContinueDrawSave).
;@ test: skip touches battery RAM
ContinueShowSave::
;> disable_interrupts()
	di
;> LoadGame()
	call LoadGame
;> enable_interrupts()
	ei
;> LoadMapPalettes()
	ld hl, far_LoadMapPalettes
	rst $10
;> return ContinueDrawSave()
	jr ContinueDrawSave

;@ path: unused
;@ Code that nothing runs (ContinueShowSave jumps over it): when the save was made on a gate
;@ floor and $D9E7 is set, it would set up a warp back to map 0 at (232, 88), facing up, and
;@ reset the player's animation; otherwise it sets $D9E7 and loads the game again.
UnusedContinueWarp::
	db $fa, $69, $c9, $b7, $28, $74, $fa, $e7, $d9, $b7, $28, $64, $3e, $01, $ea, $ea
	db $c8, $3e, $01, $ea, $6c, $c9, $3e, $00, $ea, $6d, $c9, $ea, $6e, $c9, $21, $e8
	db $00, $7d, $ea, $6f, $c9, $7c, $ea, $70, $c9, $21, $58, $00, $7d, $ea, $71, $c9
	db $7c, $ea, $72, $c9, $3e, $00, $e0, $8d, $3e, $02, $e0, $8f, $3e, $02, $e0, $8e
	db $f0, $8f, $c6, $00, $ea, $b8, $d7, $af, $ea, $ba, $d7, $ea, $bb, $d7, $ea, $b6
	db $d7, $21, $b6, $d7, $7d, $ea, $b4, $d7, $7c, $ea, $b5, $d7, $f0, $8a, $ea, $b7
	db $d7, $21, $00, $02, $d7, $fa, $ba, $d7, $e0, $8b, $21, $09, $01, $d7, $18, $16
	db $3e, $01, $ea, $e7, $d9, $f3, $cd, $28, $21, $fb

;@ def ContinueDrawSave()
;@ path: title/continue
;@ Draws the summary of the saved game: Terry's name, the play time and the names and levels
;@ of the party monsters (empty slots stay blank).
;@ test: skip calls routines in other banks
ContinueDrawSave::
;> if mem[0xD974] != 6:
	ld a, [$d974]
	cp $06
	jr z, .flags

;>     wGameStarted = 0x80
	ld a, $80
	ld [wGameStarted], a

.flags
;> if not wFieldFlags & 0x10:
	ld a, [wFieldFlags]
	bit 4, a
	jr nz, .draw

;>     wFieldFlags = 0
	xor a
	ld [wFieldFlags], a

.draw
;> mem[0xD9E7] = 0
	xor a
	ld [$d9e7], a
;> RefreshPartyGfx()
	ld hl, far_RefreshPartyGfx
	rst $10
;> DrawNameTiles_15(wPlayerName, 0x9000)
	ld de, wPlayerName
	ld hl, $9000
	call DrawNameTiles_15
;> DrawSavePartyNames()
	call DrawSavePartyNames
;> DrawWindowLayout_15(SaveInfoWindow)
	ld de, SaveInfoWindow
	call DrawWindowLayout_15
;> PrintNumber2Zeros(wPlayHours, TilemapBufferAddr_15(0x014D))
	ld a, [wPlayHours]
	ld c, a
	ld b, $00
	ld hl, $014d
	call TilemapBufferAddr_15
	call PrintNumber2Zeros
;> PrintNumber2Zeros(wPlayMinutes, TilemapBufferAddr_15(0x0150))
	ld a, [wPlayMinutes]
	ld c, a
	ld b, $00
	ld hl, $0150
	call TilemapBufferAddr_15
	call PrintNumber2Zeros
;> if wPartyCount:
	ld a, [wPartyCount]
	or a
	jr z, .empty0

;>     level = GetPartyMonsterByte(wMonLevel, 0)
	ld hl, wMonLevel
	ld a, $00
	call GetPartyMonsterByte
	ld c, a
	ld b, $00
;>     PrintNumber2(level, TilemapBufferAddr_15(0x01A4))
	ld hl, $01a4
	call TilemapBufferAddr_15
	call PrintNumber2
;>     if wPartyCount != 1:
	ld a, [wPartyCount]
	cp $01
	jr z, .empty1

;>         level = GetPartyMonsterByte(wMonLevel, 1)
	ld hl, wMonLevel
	ld a, $01
	call GetPartyMonsterByte
	ld c, a
	ld b, $00
;>         PrintNumber2(level, TilemapBufferAddr_15(0x01AA))
	ld hl, $01aa
	call TilemapBufferAddr_15
	call PrintNumber2
;>         if wPartyCount != 2:
	ld a, [wPartyCount]
	cp $02
	jr z, .empty2

;>             level = GetPartyMonsterByte(wMonLevel, 2)
	ld hl, wMonLevel
	ld a, $02
	call GetPartyMonsterByte
	ld c, a
	ld b, $00
;>             PrintNumber2(level, TilemapBufferAddr_15(0x01B0))
	ld hl, $01b0
	call TilemapBufferAddr_15
	call PrintNumber2
	jr .show

;> if wPartyCount < 1:                  # (the jumps above land on the first slot left empty)
;>     DrawEmptyLevelSlot(0x0181)
.empty0
	ld hl, $0181
	call DrawEmptyLevelSlot

;> if wPartyCount < 2:
;>     DrawEmptyLevelSlot(0x0187)
.empty1
	ld hl, $0187
	call DrawEmptyLevelSlot

;> if wPartyCount < 3:
;>     DrawEmptyLevelSlot(0x018D)
.empty2
	ld hl, $018d
	call DrawEmptyLevelSlot

.show
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleSubStep += 1
	ld hl, wTitleSubStep
	inc [hl]
	ret


;@ def DrawEmptyLevelSlot(pos: hl)
;@ path: title/continue
;@ Blanks the level of an empty party slot in the save summary: 5 tiles at `pos` (a tilemap
;@ buffer offset) and 2 tiles one row down, one column right.
;@ test: skip writes the tilemap buffer through a helper
DrawEmptyLevelSlot::
;> p = TilemapBufferAddr_15(pos)
	push hl
	call TilemapBufferAddr_15
;> fill(p, 0xE0, 5)
	ld a, $e0
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;> pos += 0x21                          # one row down, one column right
	pop hl
	ld a, l
	add $21
	ld l, a
;> p = TilemapBufferAddr_15(pos)
	ld a, h
	adc $00
	ld h, a
	call TilemapBufferAddr_15
;> fill(p, 0xE0, 2)
	ld a, $e0
	ld [hli], a
	ld [hl], a
	ret


;@ def DrawSavePartyNames()
;@ path: title/continue
;@ Draws the names of the three party monsters of the save into the tiles at $9040, $9080 and
;@ $90C0 (4 tiles each); empty slots get blank tiles.
;@ test: skip writes VRAM
DrawSavePartyNames::
;>@nm for i in range(3):
;>@nm     name = PartyMonsterField(wMonName, i)
	ld hl, wMonName
	ld a, $00
	call PartyMonsterField
	ld e, l
	ld d, h
;>@dr     DrawSavePartyName(i + 1, name, 0x9040 + 0x40 * i)
	ld hl, $9040
	ld a, $01
	call DrawSavePartyName
;=@nm
	ld hl, wMonName
	ld a, $01
	call PartyMonsterField
	ld e, l
	ld d, h
;=@dr
	ld hl, $9080
	ld a, $02
	call DrawSavePartyName
;=@nm
	ld hl, wMonName
	ld a, $02
	call PartyMonsterField
	ld e, l
	ld d, h
;=@dr
	ld hl, $90c0
	ld a, $03
	call DrawSavePartyName
	ret


;@ def DrawSavePartyName(n: a, name: de, tiles: hl)
;@ path: title/continue
;@ Draws party monster number `n` (1-3) into the 4 tiles at `tiles`, or blank tiles when the
;@ party has fewer monsters.
;@ test: skip writes VRAM
DrawSavePartyName::
;> if wPartyCount >= n:
	ld b, a
	ld a, [wPartyCount]
	cp b
;>     return DrawNameTiles_15(name, tiles)
	jp nc, DrawNameTiles_15

;> for i in range(32):                  # 4 tiles of color 1
	ld b, $20

.blank
;>     tiles = WriteVRAMInc(0xFF, tiles)
	ld a, $ff
	call WriteVRAMInc
;>     tiles = WriteVRAMInc(0x00, tiles)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blank

	ret


;@ def ContinueConfirm()
;@ path: title/continue
;@ CONTINUE, waiting on the save summary: A goes on to the field, B goes back to the title
;@ menu cursor.
;@ test: skip names the joypad buttons
ContinueConfirm::
;> if wJoyPressed & A_BUTTON:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .notA

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jr .done

;> elif wJoyPressed & B_BUTTON:
.notA
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .done

;>     wTitleStep -= 2
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]

.done
	ret


;@ def TitleNewGame()
;@ path: title/newgame
;@ NEW GAME: runs its sub-step (one, which sets up the new game).
;@ test: skip starts a serial transfer
TitleNewGame::
;> SerialSendSlave(0xF4)
	ld a, $f4
	call SerialSendSlave
;> TitleNewGameSteps[wTitleSubStep]()
	ld a, [wTitleSubStep]
	rst $00

;@ path: title/newgame
;@ Sub-steps of NEW GAME (all three are the same routine).
TitleNewGameSteps::
	dw NewGameSetup
	dw NewGameSetup
	dw NewGameSetup

;@ def NewGameSetup()
;@ path: title/newgame
;@ Clears the whole game state and puts Terry in map $2F (his room at the start of the story)
;@ with an empty party; the next title step starts the field.
;@ test: skip clears $1100 bytes of WRAM, the stack included
NewGameSetup::
;> fill(hPlayerGfx, 0, 0x21)
	ld hl, hPlayerGfx
	ld bc, $0021
	xor a
	call FillMemory
;> fill(wGameStarted, 0, 0x1100)
	ld hl, wGameStarted
	ld bc, $1100
	xor a
	call FillMemory
;> wMessageSpeed = 4
	ld a, $04
	ld [wMessageSpeed], a
;> wGameStarted = 0
	xor a
	ld [wGameStarted], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wMapId = 0x2F
	ld a, $2f
	ld [wMapId], a
;> wPrevMapId = 0x2F
	ld [wPrevMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;> wPrevOnGateFloor = 0
	ld [wPrevOnGateFloor], a
;> wPartyCount = 0
	ld a, $00
	ld [wPartyCount], a
;> wParty[0] = 0xFF
	ld a, $ff
	ld [wParty], a
;> wParty[1] = 0xFF
	ld a, $ff
	ld [$ca8f], a
;> wParty[2] = 0xFF
	ld a, $ff
	ld [$ca90], a
	ret


;@ def TitleChooseVS()
;@ path: title/menu
;@ VS MODE chosen: unless the partner already refused, asks it for link mode 2 (byte $F0, sent
;@ by TitleUpdateMenu); else beeps and shows the link error.
;@ test: skip queues a sound
TitleChooseVS::
;> if wLinkRefused != 0xFF:
	ld a, [wLinkRefused]
	cp $ff
	jr z, .refused

;>     wJoy2Active = 0
	ld a, $00
	ld [wJoy2Active], a
;>     wLinkCommand = 0xF0
	ld a, $f0
	ld [wLinkCommand], a
	ret


;> else:
;>     QueueSound(0x59)
.refused
	ld a, $59
	call QueueSound
;>     wLinkCommand = 0
	xor a
	ld [wLinkCommand], a
;>     wTitleStep = 4
	ld a, $04
	ld [wTitleStep], a
	ret


;@ def TitleChooseBreed()
;@ path: title/menu
;@ BREEDING chosen: like TitleChooseVS with link mode 3 (byte $F1).
;@ test: skip queues a sound
TitleChooseBreed::
;> if wLinkRefused != 0xFF:
	ld a, [wLinkRefused]
	cp $ff
	jr z, .refused

;>     wJoy2Active = 0
	ld a, $00
	ld [wJoy2Active], a
;>     wLinkCommand = 0xF1
	ld a, $f1
	ld [wLinkCommand], a
	ret


;> else:
;>     QueueSound(0x59)
.refused
	ld a, $59
	call QueueSound
;>     wLinkCommand = 0
	xor a
	ld [wLinkCommand], a
;>     wTitleStep = 4
	ld a, $04
	ld [wTitleStep], a
	ret


;@ def TitleUpdateVSLink()
;@ path: link/vs
;@ Game loop part of VS mode (game mode 0 step 2): the frames themselves run from the serial
;@ interrupt (VSLinkFrame); here the link timeout is counted and, while a status screen is open
;@ (steps 6, 20 and 28), the monster sprites on it are drawn.
;@ test: skip calls routines in other banks
TitleUpdateVSLink::
;> LinkFrameUpdate()
	call LinkFrameUpdate
;>@status if wTitleStep in (6, 0x14, 0x1C):
	ld a, [wTitleStep]
	cp $06
	jr z, .status

;=@status
	cp $14
	jr z, .status

;=@status
	cp $1c
	jr z, .status

	ret


.status
;>     VSDrawStatusMonster()
	call VSDrawStatusMonster
;>     VSDrawStatusParents()
	call VSDrawStatusParents
;>     LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ret


;@ def VSLinkFrame()
;@ path: link/vs
;@ One frame of VS mode, run from the serial interrupt: the current step.
;@ test: skip runs the link protocol
VSLinkFrame::
;> VSLinkSteps[wTitleStep]()
	ld a, [wTitleStep]
	rst $00

;@ path: link/vs
;@ Steps of VS mode: 0-10 choose up to three monsters for the team (INFO shows the status
;@ screen), 11-21 offer a prize monster or none, 22-24 exchange the prize records, 25-29 the
;@ FIGHT / PRIZE / EXIT menu (PRIZE shows the partner's prize), 30-31 refused (back to the
;@ title), 32-34 exchange the teams and start the battle, 35 the prize was in the party,
;@ 36 the partner cancelled.
VSLinkSteps::
	dw VSStart
	dw VSShowTeamList
	dw VSTeamListInput
	dw VSTeamPicked
	dw VSShowTeamChoice
	dw VSTeamChoiceInput
	dw VSTeamShowStatus
	dw VSTeamStatusDone
	dw VSAskAnother
	dw VSShowAnotherYesNo
	dw VSAnotherInput
	dw VSAskPrize
	dw VSShowPrizeYesNo
	dw VSPrizeYesNoInput
	dw VSStartPrizeList
	dw VSShowPrizeList
	dw VSPrizeListInput
	dw VSPrizePicked
	dw VSShowPrizeChoice
	dw VSPrizeChoiceInput
	dw VSPrizeShowStatus
	dw VSPrizeStatusDone
	dw VSPrizeWait
	dw VSSendPrize
	dw VSPrizeSent
	dw VSAskReady
	dw VSShowReadyMenu
	dw VSReadyInput
	dw VSShowPartnerPrize
	dw VSPartnerPrizeDone
	dw VSRefusedSync
	dw VSBackToTitle
	dw VSFightWait
	dw VSSendTeams
	dw VSStartBattle
	dw VSPrizeInParty
	dw VSPartnerCancelled

;@ def VSStart()
;@ path: link/vs
;@ VS mode step 0: lists the monsters that can join the battle team.
;@ test: wTitleStep = rand(0, 3)
VSStart::
;> CountTeamCandidates()
	call CountTeamCandidates
;> ListTeamCandidates()
	call ListTeamCandidates
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def CountTeamCandidates() -> a
;@ path: link/vs
;@ Counts the monsters that can still join the VS team: owned, hatched (not an egg) and not
;@ in wVSTeam yet. The count goes to wTitleListCount and is returned.
CountTeamCandidates::
;> rec = wMonsters
	ld de, wMonsters
;> count = 0
	ld b, $00
	ld c, $00

;>@for for slot in range(20):
.loop
	push de
;>     if mem[rec]:                     # slot in use
	ld a, [de]
	or a
	jr z, .next

;>@egg         if mem[rec + 0x63] == 0 and slot not in wVSTeam:   # hatched, not chosen yet
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next

;=@egg
	ld a, [wVSTeam]
	cp b
	jr z, .next

;=@egg
	ld a, [wVSTeam + 1]
	cp b
	jr z, .next

;=@egg
	ld a, [wVSTeam + 2]
	cp b
	jr z, .next

;>             count += 1
	inc c

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
;=@rec
	ld a, d
	adc $00
	ld d, a
;=@for
	inc b
	ld a, b
	cp $14
	jr nz, .loop

;> wTitleListCount = count
	ld a, c
	ld [wTitleListCount], a
;> return count
	ret


;@ def ListTeamCandidates()
;@ path: link/vs
;@ Fills the list in wSceneObjects (20 bytes, $FF = end) with the slots of the monsters that
;@ can still join the VS team (see CountTeamCandidates).
ListTeamCandidates::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = wSceneObjects
	ld hl, wSceneObjects
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@for for slot in range(20):
.loop
	push de
;>     if mem[rec]:
	ld a, [de]
	or a
	jr z, .next

;>@egg         if mem[rec + 0x63] == 0 and slot not in wVSTeam:
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next

;=@egg
	ld a, [wVSTeam]
	cp c
	jr z, .next

;=@egg
	ld a, [wVSTeam + 1]
	cp c
	jr z, .next

;=@egg
	ld a, [wVSTeam + 2]
	cp c
	jr z, .next

;>             mem[out] = slot; out += 1
	ld [hl], c
	inc hl

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
;=@rec
	ld a, d
	adc $00
	ld d, a
;=@for
	inc c
	dec b
	jr nz, .loop

	ret


;@ def VSShowTeamList()
;@ path: link/vs
;@ VS mode step 1: once the text is done, draws the team selection screen (the monster list,
;@ the cursor monster's name, level and sex, the team so far) and asks "Choose monster(s)
;@ for the battle."
;@ test: skip calls routines in other banks
VSShowTeamList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> VSDrawListNames()
	call VSDrawListNames
;> VSDrawTeamWindows()
	call VSDrawTeamWindows
;> VSDrawTeamNames()
	call VSDrawTeamNames
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x0225)             # "Choose monster(s) for the battle."
	ld hl, $0225
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawTeamWindows()
;@ path: link/vs
;@ Draws the windows of the team selection into the tilemap buffer: the cursor monster's name
;@ and level, the list of four names, the team window and the text box, with the list cursor.
;@ test: skip draws through helpers
VSDrawTeamWindows::
;> DrawWindowLayout_15(TitleNameWindow)
	ld de, TitleNameWindow
	call DrawWindowLayout_15
;> DrawCursorMonLevel()
	call DrawCursorMonLevel
;> DrawWindowLayout_15(TitleListWindow)
	ld de, TitleListWindow
	call DrawWindowLayout_15
;> DrawWindowLayout_15(VSTeamWindow)
	ld de, VSTeamWindow
	call DrawWindowLayout_15
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;>@g1 MenuDrawListCursor_15(wMenuChoice, VSTeamListCursor, 4, wTitleListCount)
	ld de, VSTeamListCursor
	ld b, $04
	ld a, [wTitleListCount]
	ld c, a
	ld hl, wMenuChoice
	call MenuDrawListCursor_15
;=@g1
	ret


;@ def VSDrawListNames()
;@ path: link/vs
;@ Draws the names of the four list entries on the current page (wMenuChoice2) into the tiles
;@ from $9100 on (4 tiles each).
;@ test: skip writes VRAM
VSDrawListNames::
;>@entry entry = wSceneObjects + wMenuChoice2 * 4
	ld a, [wMenuChoice2]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@entry
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9100
	ld hl, $9100
;> for i in range(4):                   # the fourth by running on into VSDrawListName
;>     entry, tiles = VSDrawListName(entry, tiles)
	call VSDrawListName
	call VSDrawListName
	call VSDrawListName

;@ def VSDrawListName(entry: de, tiles: hl) -> (de, hl)
;@ path: link/vs
;@ Draws the name of the monster in list entry `entry` into the 4 tiles at `tiles` (blank
;@ tiles for an empty entry); returns the next entry and the next 4 tiles.
;@ test: skip writes VRAM
VSDrawListName::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>@name     DrawNameTiles_15(MonsterField(wMonName, mem[entry]), tiles)
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	pop hl
	push hl
	call DrawNameTiles_15
;>@ret     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
;=@ret
	adc $00
	ld h, a
	pop de
	inc de
	ret


;> else:
;>     for i in range(32):              # blank tiles
.blank
	ld b, $20

.blankLoop
;>         tiles = WriteVRAMInc(0xFF, tiles)
	ld a, $ff
	call WriteVRAMInc
;>         tiles = WriteVRAMInc(0x00, tiles)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blankLoop

;>@ret2     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
;=@ret2
	adc $00
	ld h, a
	pop de
	inc de
	ret


;@ def DrawCursorMonName()
;@ path: link/menu
;@ Draws the name of the monster under the list cursor into the tiles at $9000 and its sex
;@ sign into the tile at $9200.
;@ test: skip prints text
DrawCursorMonName::
;>@slot slot = wSceneObjects[wMenuChoice2 * 4 + (wMenuChoice & 0x7F)]
	ld a, [wMenuChoice2]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice]
	and $7f
;=@slot
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@slot
	ld h, a
	ld a, [hl]
;> if slot == 0xFF:
;>     return
	cp $ff
	ret z

;>@name DrawNameTiles_15(MonsterField(wMonName, slot), 0x9000)
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	ld hl, $9000
	call DrawNameTiles_15
;> sex = mem[MonsterField(wMonGender, slot)] & 1
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9200
	and $01
;> wTextArg0[0] = 0xA7 + sex            # the sex sign
	add $a7
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0                  # end
	ld a, $f0
	ld [wTextArg0 + 1], a
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
	push bc
;> saved_box = (wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x9200
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> wTextBoxLines = 1; wTextBoxLineLength = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2; wTextIndex = 0      # the text that prints wTextArg0
	ld a, $02
	ld [wTextGroup], a
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
;> wTextBoxLines = saved_box[0]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_box[1]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawCursorMonLevel()
;@ path: link/menu
;@ Writes the level of the monster under the list cursor into the name window ("Lv" and two
;@ digits at buffer offset $0161) and the party mark at $0169 when the monster is in the
;@ party (also a party a script has put aside).
;@ test: skip touches battery RAM
DrawCursorMonLevel::
;>@slot slot = wSceneObjects[wMenuChoice2 * 4 + (wMenuChoice & 0x7F)]
	ld a, [wMenuChoice2]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice]
	and $7f
;=@slot
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@slot
	ld h, a
	ld a, [hl]
;> if slot == 0xFF:
;>     return
	cp $ff
	ret z

;> level = mem[MonsterField(wMonLevel, slot)]
	push af
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = TilemapBufferAddr_15(0x0161)
	ld hl, $0161
	call TilemapBufferAddr_15
;> mem[p] = 0xDE                        # "Lv"
	ld a, $de
	ld [hli], a
;> mem[p + 1] = 0xE0
	ld a, $e0
	ld [hli], a
;> mem[p + 2] = 0xE0
	ld a, $e0
	ld [hld], a
;> PrintTwoDigits_15(level, p + 1)
	call PrintTwoDigits_15
;> owner = mem[MonsterField(wMonsters, slot)]
	pop af
	push af
	ld hl, wMonsters
	call MonsterField
	pop af
	ld b, a
;>@party if owner == 2 or IsInStashedParty(slot):    # in the party
	ld a, [hl]
	cp $02
	jr z, .inParty

;=@party
	call IsInStashedParty
	jr nz, .inParty

	jr .notInParty

;>     mem[TilemapBufferAddr_15(0x0169)] = 0xE3
.inParty
	ld hl, $0169
	call TilemapBufferAddr_15
	ld a, $e3
	ld [hl], a
	ret


;> else:
;>     mem[TilemapBufferAddr_15(0x0169)] = 0xE0
.notInParty
	ld hl, $0169
	call TilemapBufferAddr_15
	ld a, $e0
	ld [hl], a
	ret


;@ def VSTeamListInput()
;@ path: link/vs
;@ VS mode step 2: moves the cursor through the monster list (Left/Right turn the page) and
;@ redraws what changed. A picks the monster under the cursor; B takes the last team member
;@ back out, or with an empty team refuses the battle (byte $FD to the partner).
;@ test: skip runs the link protocol
VSTeamListInput::
;> if wFadeState or wTextState:
;>@wait     return
	ld a, [wFadeState]
	or a
	ret nz

;=@wait
	ld a, [wTextState]
	or a
	ret nz

;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;>@old old_page = wMenuChoice2; old_cursor = wMenuChoice
	ld de, VSTeamListCursor
	ld hl, wMenuChoice
	ld a, [wTitleListCount]
	ld c, a
	ld b, $04
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> MovePagedListCursor_15(wMenuChoice, 4, wTitleListCount, VSTeamListCursor)
	call MovePagedListCursor_15
;> if wMenuChoice != old_cursor:
	pop af
	ld hl, wMenuChoice
	cp [hl]
	jr z, .samePos

;>     DrawCursorMonName()
	call DrawCursorMonName
;>     DrawCursorMonLevel()
	call DrawCursorMonLevel
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15

.samePos
;> if wMenuChoice2 != old_page:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .samePage

;>     VSDrawListNames()
	call VSDrawListNames
;>     DrawCursorMonName()
	call DrawCursorMonName
;>     DrawCursorMonLevel()
	call DrawCursorMonLevel
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15

.samePage
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     for i in (2, 1, 0):               # take the last member out again
;>@if         if wVSTeam[i] != 0xFF:
	ld a, [wVSTeam + 2]
	cp $ff
	jr z, .notThird

;>@clr             wVSTeam[i] = 0xFF
	ld a, $ff
	ld [wVSTeam + 2], a
;>@rm             VSDrawTeamNames()
	jr .removed

.notThird
;=@if
	ld a, [wVSTeam + 1]
	cp $ff
	jr z, .notSecond

;=@clr
	ld a, $ff
	ld [wVSTeam + 1], a
;=@rm
	jr .removed

.notSecond
;=@if
	ld a, [wVSTeam]
	cp $ff
	jr z, .refuse

;=@clr
	ld a, $ff
	ld [wVSTeam], a

.removed
;=@rm
	call VSDrawTeamNames
;>             wTitleStep = 0             # list the candidates again
	ld a, $00
	ld [wTitleStep], a
;>             break
	jr .done

;>     else:                             # the team is empty
;>         PrintSystemText(0x022D)       # "Refused the battle."
.refuse
	ld hl, $022d
	call PrintSystemText
;>         wTitleStep = 0x24
	ld a, $24
	ld [wTitleStep], a
;>         wLinkSendByte = 0xFD
	ld a, $fd
	ld [wLinkSendByte], a
	jr .done

;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>@pick     wCurPartyMember = wSceneObjects[wMenuChoice2 * 4 + (wMenuChoice & 0x7F)]
	ld a, [wMenuChoice2]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice]
	and $7f
;=@pick
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@pick
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ path: link/vs
;@ Cursor positions of the VS team list (tilemap buffer offsets): first the page number, then
;@ the four rows; $FFFF ends.
VSTeamListCursor::
	dw $0145
	dw $0061, $00a1, $00e1, $0121
	dw $ffff

;@ def VSTeamPicked()
;@ path: link/vs
;@ VS mode step 3: goes on to the INFO / OK choice.
;@ test: wTitleStep = rand(0, 30)
VSTeamPicked::
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSShowTeamChoice()
;@ path: link/vs
;@ VS mode step 4: once the text is done, draws the INFO / OK window for the picked monster.
;@ test: skip draws through helpers
VSShowTeamChoice::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> VSDrawTeamChoice()
	call VSDrawTeamChoice
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawTeamChoice()
;@ path: link/vs
;@ Draws the team selection windows with the INFO / OK window and its cursor.
;@ test: skip draws through helpers
VSDrawTeamChoice::
;> VSDrawTeamWindows()
	call VSDrawTeamWindows
;> DrawWindowLayout_15(InfoOkWindow)
	ld de, InfoOkWindow
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wConfirmChoice, VSTeamChoiceCursor)
	ld de, VSTeamChoiceCursor
	ld a, [wConfirmChoice]
	call MenuDrawCursorAt_15
	ret


;@ def VSTeamChoiceInput()
;@ path: link/vs
;@ VS mode step 5: INFO / OK for the picked monster. B goes back to the list, INFO opens the
;@ monster's status screen, OK puts it into the next free team place; with three members (or
;@ nobody left to choose) the prize question follows, else "Choose another monster?".
;@ test: skip runs the link protocol
VSTeamChoiceInput::
;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;> MoveMenuCursor_15(wConfirmChoice, 2, VSTeamChoiceCursor)
	ld de, VSTeamChoiceCursor
	ld hl, wConfirmChoice
	ld b, $02
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;>     DrawCursorMonName()
	call DrawCursorMonName
;>     VSDrawListNames()
	call VSDrawListNames
;>     VSDrawTeamWindows()
	call VSDrawTeamWindows
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>@g2     wTitleStep -= 3                   # back to the list
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
;=@g2
	jp .done


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:        # INFO
	ld a, [wConfirmChoice]
	cp $81
	jr z, .ok

;>         wFieldMenuState[0] = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp .done


;>     else:                             # OK: into the first free place
;>         for i in range(3):
;>@if             if i == 2 or wVSTeam[i] == 0xFF:
.ok
	ld a, [wVSTeam]
	cp $ff
	jr nz, .notFirst

;>@set                 wVSTeam[i] = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wVSTeam], a
;>@brk                 break
	jr .added

.notFirst
;=@if
	ld a, [wVSTeam + 1]
	cp $ff
	jr nz, .third

;=@set
	ld a, [wCurPartyMember]
	ld [wVSTeam + 1], a
;=@brk
	jr .added

.third
;=@set
	ld a, [wCurPartyMember]
	ld [wVSTeam + 2], a
;>@dr         VSDrawTeamNames()
	call VSDrawTeamNames
;>@g3         if i == 2:
;>@six             wTitleStep += 6           # the team is full: the prize question
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;=@six
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;=@g3
	ret


.added
;=@dr
	call VSDrawTeamNames
;>         else:
;>             wTitleStep += 3           # "Choose another monster?"
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;>             if CountTeamCandidates() == 0:
	call CountTeamCandidates
	or a
	jr nz, .done

;>@g4                 wTitleStep += 3       # nobody left: the prize question
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]

.done
;=@g4
	ret


;@ path: link/vs
;@ Cursor positions of the INFO / OK window (tilemap buffer offsets, $FFFF ends).
VSTeamChoiceCursor::
	dw $002e, $006e
	dw $ffff

;@ def VSDrawTeamNames()
;@ path: link/vs
;@ Draws the names of the (up to three) team members into the tiles from $9040 on.
;@ test: skip writes VRAM
VSDrawTeamNames::
;> entry, tiles = wVSTeam, 0x9040
	ld de, wVSTeam
	ld hl, $9040
;> for i in range(3):
;>     entry, tiles = VSDrawListName(entry, tiles)
	call VSDrawListName
	call VSDrawListName
	call VSDrawListName
	ret


;@ def VSTeamShowStatus()
;@ path: link/vs
;@ VS mode step 6: runs the monster status screen for the picked monster until it closes.
;@ test: skip calls routines in other banks
VSTeamShowStatus::
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep:                     # the status screen was closed
	ld a, [wMenuSubStep]
	or a
	ret z

;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSTeamStatusDone()
;@ path: link/vs
;@ VS mode step 7: after the status screen, loads the font again, prints the team question
;@ and redraws the team selection with the INFO / OK window (back to step 5).
;@ test: skip calls routines in other banks
VSTeamStatusDone::
;> DecompressVRAM(0x2E, 0x1E, 0x9000)   # font
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
;> PrintSystemText(0x0225)             # "Choose monster(s) for the battle."
	ld hl, $0225
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> VSDrawListNames()
	call VSDrawListNames
;> VSDrawTeamWindows()
	call VSDrawTeamWindows
;> VSDrawTeamChoice()
	call VSDrawTeamChoice
;> VSDrawTeamNames()
	call VSDrawTeamNames
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 5
	ld a, $05
	ld [wTitleStep], a
	ret


;@ def VSAskAnother()
;@ path: link/vs
;@ VS mode step 8: asks "Choose another monster?".
;@ test: skip prints text
VSAskAnother::
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x0227)
	ld hl, $0227
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSShowAnotherYesNo()
;@ path: link/vs
;@ VS mode step 9: once the question is printed, beeps and draws the YES / NO window.
;@ test: skip draws through helpers
VSShowAnotherYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> VSDrawAnotherYesNo()
	call VSDrawAnotherYesNo
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawAnotherYesNo()
;@ path: link/vs
;@ Draws the YES / NO window of "Choose another monster?" with its cursor.
;@ test: skip draws through helpers
VSDrawAnotherYesNo::
;> DrawWindowLayout_15(YesNoWindow_15)
	ld de, YesNoWindow_15
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wConfirmChoice2, VSAnotherCursor)
	ld de, VSAnotherCursor
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt_15
	ret


;@ def VSAnotherInput()
;@ path: link/vs
;@ VS mode step 10: YES goes back to the monster list for the next team member; NO or B goes
;@ on to the prize question.
;@ test: skip runs the link protocol
VSAnotherInput::
;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;> MoveMenuCursor_15(wConfirmChoice2, 2, VSAnotherCursor)
	ld de, VSAnotherCursor
	ld hl, wConfirmChoice2
	ld b, $02
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@no     wTitleStep += 1                   # the prize question
.no
	ld hl, wTitleStep
	inc [hl]
	jp Jump_015_4be2


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_015_4be2

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice2 == 0x81:       # NO
;>         wTitleStep += 1
	ld a, [wConfirmChoice2]
	cp $81
;=@no
	jr z, .no

;>     else:
;>         CountTeamCandidates()
	call CountTeamCandidates
;>         ListTeamCandidates()
	call ListTeamCandidates
;>         DrawCursorMonName()
	call DrawCursorMonName
;>         VSDrawListNames()
	call VSDrawListNames
;>         VSDrawTeamWindows()
	call VSDrawTeamWindows
;>         wTitleStep = 1
	ld a, $01
	ld [wTitleStep], a
;>         wMenuChoice = 0; wMenuChoice2 = 0
	xor a
	ld [wMenuChoice], a
	ld [wMenuChoice2], a
	jp Jump_015_4be2


Jump_015_4be2:
	ret


;@ path: link/vs
;@ Cursor positions of the YES / NO window of "Choose another monster?" ($FFFF ends).
VSAnotherCursor::
	dw $01cf, $020f
	dw $ffff

;@ def VSAskPrize()
;@ path: link/vs
;@ VS mode step 11: asks "Submit a prize?" (the winner of the battle takes the prize monster).
;@ test: skip prints text
VSAskPrize::
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x0228)
	ld hl, $0228
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSShowPrizeYesNo()
;@ path: link/vs
;@ VS mode step 12: once the question is printed, beeps and draws the YES / NO window.
;@ test: skip draws through helpers
VSShowPrizeYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> VSDrawPrizeYesNo()
	call VSDrawPrizeYesNo
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawPrizeYesNo()
;@ path: link/vs
;@ Draws the YES / NO window of "Submit a prize?" with its cursor.
;@ test: skip draws through helpers
VSDrawPrizeYesNo::
;> DrawWindowLayout_15(YesNoWindow_15)
	ld de, YesNoWindow_15
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wMenuChoice3, VSPrizeYesNoCursor)
	ld de, VSPrizeYesNoCursor
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt_15
	ret


;@ def VSPrizeYesNoInput()
;@ path: link/vs
;@ VS mode step 13: YES lists the monsters that can be offered as the prize; NO or B offers
;@ none (an empty record, slot $14 = wBreedParent1) and goes on to the exchange.
;@ test: skip runs the link protocol
VSPrizeYesNoInput::
;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;> MoveMenuCursor_15(wMenuChoice3, 2, VSPrizeYesNoCursor)
	ld de, VSPrizeYesNoCursor
	ld hl, wMenuChoice3
	ld b, $02
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@none     DrawWindowLayout_15(0x2E07)
.none
	ld de, $2e07
	call DrawWindowLayout_15
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>     PrintSystemText(0x0229)           # no prize
	ld hl, $0229
	call PrintSystemText
;>     wCurPartyMember = 0x14            # the prize is the empty record in slot 20
	ld a, $14
	ld [wCurPartyMember], a
;>     wBreedParent1[0] = 0
	ld a, $00
	ld [wBreedParent1], a
;>     wTitleStep = 0x16
	ld a, $16
	ld [wTitleStep], a
	jp Jump_015_4c8d


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_015_4be2

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:          # NO: as B
	ld a, [wMenuChoice3]
	cp $81
;>         pass                          # jumps to the B code above: no prize
	jr z, .none

;>     else:
;>         CountPrizeCandidates()
	call CountPrizeCandidates
;>         ListPrizeCandidates()
	call ListPrizeCandidates
;>         DrawCursorMonName()
	call DrawCursorMonName
;>         VSDrawListNames()
	call VSDrawListNames
;>         VSDrawTeamWindows()
	call VSDrawTeamWindows
;>         wMenuChoice = 0; wMenuChoice2 = 0
	xor a
	ld [wMenuChoice], a
	ld [wMenuChoice2], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp Jump_015_4c8d


Jump_015_4c8d:
	ret


;@ path: link/vs
;@ Cursor positions of the YES / NO window of "Submit a prize?" ($FFFF ends).
VSPrizeYesNoCursor::
	dw $01cf, $020f
	dw $ffff

;@ def VSStartPrizeList()
;@ path: link/vs
;@ VS mode step 14: lists the monsters that can be offered as the prize. With none, no prize
;@ is offered (an empty record) and the exchange follows.
;@ test: skip prints text
VSStartPrizeList::
;> CountPrizeCandidates()
	call CountPrizeCandidates
;> ListPrizeCandidates()
	call ListPrizeCandidates
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> if wTitleListCount:
;>     return
	ld a, [wTitleListCount]
	or a
	ret nz

;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x0229)             # "No monsters left at the farm. Thus, no prize."
	ld hl, $0229
	call PrintSystemText
;> wCurPartyMember = 0x14               # the empty record in slot 20
	ld a, $14
	ld [wCurPartyMember], a
;> wBreedParent1[0] = 0
	ld a, $00
	ld [wBreedParent1], a
;> wTitleStep = 0x16
	ld a, $16
	ld [wTitleStep], a
	ret


;@ def CountPrizeCandidates() -> a
;@ path: link/vs
;@ Counts the hatched monsters (owned, not eggs) into wTitleListCount and returns the count.
CountPrizeCandidates::
;> rec = wMonsters; count = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@for for slot in range(20):
.loop
	push de
;>     if mem[rec]:
	ld a, [de]
	or a
	jr z, .next

;>@egg         if mem[rec + 0x63] == 0:      # not an egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next

;>             count += 1
	inc c

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
;=@rec
	ld a, d
	adc $00
	ld d, a
;=@for
	dec b
	jr nz, .loop

;> wTitleListCount = count
	ld a, c
	ld [wTitleListCount], a
;> return count
	ret


;@ def ListPrizeCandidates()
;@ path: link/vs
;@ Fills the list in wSceneObjects (20 bytes, $FF = end) with the slots of all hatched
;@ monsters.
ListPrizeCandidates::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = wSceneObjects
	ld hl, wSceneObjects
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@for for slot in range(20):
.loop
	push de
;>     if mem[rec]:
	ld a, [de]
	or a
	jr z, .next

;>@egg         if mem[rec + 0x63] == 0:
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next

;>             mem[out] = slot; out += 1
	ld [hl], c
	inc hl

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
;=@rec
	ld a, d
	adc $00
	ld d, a
;=@for
	inc c
	dec b
	jr nz, .loop

	ret


;@ def VSShowPrizeList()
;@ path: link/vs
;@ VS mode step 15: once the text is done, draws the prize selection screen and asks "Choose
;@ a monster for the prize?".
;@ test: skip calls routines in other banks
VSShowPrizeList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> VSDrawPrizeListNames()
	call VSDrawPrizeListNames
;> VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x022A)             # "Choose a monster for the prize?"
	ld hl, $022a
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawPrizeWindows()
;@ path: link/vs
;@ Draws the windows of the prize selection (as VSDrawTeamWindows, with the prize list cursor).
;@ test: skip draws through helpers
VSDrawPrizeWindows::
;> DrawWindowLayout_15(TitleNameWindow)
	ld de, TitleNameWindow
	call DrawWindowLayout_15
;> DrawCursorMonLevel()
	call DrawCursorMonLevel
;> DrawWindowLayout_15(TitleListWindow)
	ld de, TitleListWindow
	call DrawWindowLayout_15
;> DrawWindowLayout_15(VSTeamWindow)
	ld de, VSTeamWindow
	call DrawWindowLayout_15
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;>@g5 MenuDrawListCursor_15(wMenuChoice, VSPrizeListCursor, 4, wTitleListCount)
	ld de, VSPrizeListCursor
	ld b, $04
	ld a, [wTitleListCount]
	ld c, a
	ld hl, wMenuChoice
	call MenuDrawListCursor_15
;=@g5
	ret


;@ def VSDrawPrizeListNames()
;@ path: link/vs
;@ Draws the names of the four prize list entries on the current page into the tiles from
;@ $9100 on (as VSDrawListNames).
;@ test: skip writes VRAM
VSDrawPrizeListNames::
;>@entry entry = wSceneObjects + wMenuChoice2 * 4
	ld a, [wMenuChoice2]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@entry
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9100
	ld hl, $9100
;> for i in range(4):                   # the fourth by running on into VSDrawPrizeListName
;>     entry, tiles = VSDrawPrizeListName(entry, tiles)
	call VSDrawPrizeListName
	call VSDrawPrizeListName
	call VSDrawPrizeListName

;@ def VSDrawPrizeListName(entry: de, tiles: hl) -> (de, hl)
;@ path: link/vs
;@ A copy of VSDrawListName: the name of the monster in list entry `entry` into the 4 tiles at
;@ `tiles` (blank for an empty entry); returns the next entry and tiles.
;@ test: skip writes VRAM
VSDrawPrizeListName::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>@name     DrawNameTiles_15(MonsterField(wMonName, mem[entry]), tiles)
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	pop hl
	push hl
	call DrawNameTiles_15
;>@ret     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
;=@ret
	adc $00
	ld h, a
	pop de
	inc de
	ret


;> else:
;>     for i in range(32):              # blank tiles
.blank
	ld b, $20

.blankLoop
;>         tiles = WriteVRAMInc(0xFF, tiles)
	ld a, $ff
	call WriteVRAMInc
;>         tiles = WriteVRAMInc(0x00, tiles)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blankLoop

;>@ret2     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
;=@ret2
	adc $00
	ld h, a
	pop de
	inc de
	ret


;@ def VSPrizeListInput()
;@ path: link/vs
;@ VS mode step 16: moves the cursor through the prize list. A picks the monster; B goes back
;@ to "Submit a prize?".
;@ test: skip runs the link protocol
VSPrizeListInput::
;> if wFadeState or wTextState:
;>@wait     return
	ld a, [wFadeState]
	or a
	ret nz

;=@wait
	ld a, [wTextState]
	or a
	ret nz

;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;>@old old_page = wMenuChoice2; old_cursor = wMenuChoice
	ld de, VSPrizeListCursor
	ld hl, wMenuChoice
	ld a, [wTitleListCount]
	ld c, a
	ld b, $04
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> MovePagedListCursor_15(wMenuChoice, 4, wTitleListCount, VSPrizeListCursor)
	call MovePagedListCursor_15
;> if wMenuChoice != old_cursor:
	pop af
	ld hl, wMenuChoice
	cp [hl]
	jr z, .samePos

;>     DrawCursorMonName()
	call DrawCursorMonName
;>     DrawCursorMonLevel()
	call DrawCursorMonLevel
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15

.samePos
;> if wMenuChoice2 != old_page:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .samePage

;>     VSDrawPrizeListNames()
	call VSDrawPrizeListNames
;>     DrawCursorMonName()
	call DrawCursorMonName
;>     DrawCursorMonLevel()
	call DrawCursorMonLevel
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15

.samePage
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     wTitleStep = 0x0B                 # back to "Submit a prize?"
	ld a, $0b
	ld [wTitleStep], a
	jr .done

;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wConfirmChoice = 0; wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice], a
	ld [wConfirmChoice2], a
;>@pick     wCurPartyMember = wSceneObjects[wMenuChoice2 * 4 + (wMenuChoice & 0x7F)]
	ld a, [wMenuChoice2]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice]
	and $7f
;=@pick
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@pick
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ path: link/vs
;@ Cursor positions of the prize list: the page number, then the four rows ($FFFF ends).
VSPrizeListCursor::
	dw $0145
	dw $0061, $00a1, $00e1, $0121
	dw $ffff

;@ def VSPrizePicked()
;@ path: link/vs
;@ VS mode step 17: goes on to the INFO / OK choice for the prize.
;@ test: wTitleStep = rand(0, 30)
VSPrizePicked::
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSShowPrizeChoice()
;@ path: link/vs
;@ VS mode step 18: once the text is done, draws the INFO / OK window for the picked prize.
;@ test: skip draws through helpers
VSShowPrizeChoice::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> VSDrawPrizeChoice()
	call VSDrawPrizeChoice
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawPrizeChoice()
;@ path: link/vs
;@ Draws the prize selection windows with the INFO / OK window and its cursor.
;@ test: skip draws through helpers
VSDrawPrizeChoice::
;> VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;> DrawWindowLayout_15(InfoOkWindow)
	ld de, InfoOkWindow
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wConfirmChoice, VSPrizeChoiceCursor)
	ld de, VSPrizeChoiceCursor
	ld a, [wConfirmChoice]
	call MenuDrawCursorAt_15
	ret


;@ def VSPrizeChoiceInput()
;@ path: link/vs
;@ VS mode step 19: INFO / OK for the prize. B goes back to the list, INFO opens the status
;@ screen, OK offers the monster, unless it is in the party (then a message and back).
;@ test: skip runs the link protocol
VSPrizeChoiceInput::
;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;> MoveMenuCursor_15(wConfirmChoice, 2, VSPrizeChoiceCursor)
	ld de, VSPrizeChoiceCursor
	ld hl, wConfirmChoice
	ld b, $02
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;>     DrawCursorMonName()
	call DrawCursorMonName
;>     VSDrawPrizeListNames()
	call VSDrawPrizeListNames
;>     VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>@g6     wTitleStep -= 3                   # back to the list
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
;=@g6
	jp .done


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:        # INFO
	ld a, [wConfirmChoice]
	cp $81
	jr z, .ok

;>         wFieldMenuState[0] = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp .done


;>     else:
;>         wTitleStep += 3               # OK: on to the exchange
.ok
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;>         slot = wCurPartyMember
	ld a, [wCurPartyMember]
	ld b, a
;>@party         if IsInStashedParty(slot) or mem[MonsterField(wMonsters, slot)] == 2:
	call IsInStashedParty
	jr nz, .inParty

;=@party
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, .done

;>             PrintSystemText(0x025C)   # "You cannot choose the monster in your current party as a prize."
.inParty
	ld hl, $025c
	call PrintSystemText
;>             wTitleStep = 0x23
	ld a, $23
	ld [wTitleStep], a
	jr .done

.done
	ret


;@ path: link/vs
;@ Cursor positions of the INFO / OK window of the prize ($FFFF ends).
VSPrizeChoiceCursor::
	dw $002e, $006e
	dw $ffff

;@ def IsInStashedParty(slot: b) -> a
;@ path: link/vs
;@ When the saved game has no party, checks whether monster `slot` is in the party a script put
;@ aside (wSavedParty as saved in battery RAM). Returns 1 if so, else 0.
;@ test: skip reads battery RAM
IsInStashedParty::
;> if ReadSRAMByte(sPartyCount):
;>     return 0
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr nz, .no

;> count = ReadSRAMByte(sStashedParty)
	ld hl, sStashedParty
	call ReadSRAMByte
;> if count == 0:
;>     return 0
	or a
	jr z, .no

;>@for for i in range(count):
;>@if     if ReadSRAMByte(sStashedParty + 1 + i) == slot:
	ld hl, sStashedParty + 1
	call ReadSRAMByte
	cp b
;>@yes         return 1
	jr z, .yes

;=@for
	ld hl, sStashedParty
	call ReadSRAMByte
	cp $01
	jr z, .no

;=@if
	ld hl, sStashedParty + 2
	call ReadSRAMByte
	cp b
	jr z, .yes

;=@for
	ld hl, sStashedParty
	call ReadSRAMByte
	cp $02
	jr z, .no

;=@if
	ld hl, sStashedParty + 3
	call ReadSRAMByte
	cp b
	jr z, .yes

;> return 0
.no
	xor a
	ret


.yes
;=@yes
	ld a, $01
	or a
	ret


;@ def VSPrizeShowStatus()
;@ path: link/vs
;@ VS mode step 20: runs the monster status screen for the picked prize until it closes.
;@ test: skip calls routines in other banks
VSPrizeShowStatus::
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep:
	ld a, [wMenuSubStep]
	or a
	ret z

;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSPrizeStatusDone()
;@ path: link/vs
;@ VS mode step 21: after the status screen, loads the font again and redraws the prize
;@ selection with the INFO / OK window (back to step 18).
;@ test: skip calls routines in other banks
VSPrizeStatusDone::
;> DecompressVRAM(0x2E, 0x1E, 0x9000)   # font
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
;> PrintSystemText(0x022A)             # "Choose a monster for the prize?"
	ld hl, $022a
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> VSDrawPrizeListNames()
	call VSDrawPrizeListNames
;> VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;> VSDrawPrizeChoice()
	call VSDrawPrizeChoice
;> VSDrawTeamNames()
	call VSDrawTeamNames
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 0x12
	ld a, $12
	ld [wTitleStep], a
	ret


;@ def VSPrizeWait()
;@ path: link/vs
;@ VS mode step 22: "One moment please." and tells the partner this side is ready (byte 1).
;@ test: skip prints text
VSPrizeWait::
;> PrintSystemText(0x021F)
	ld hl, $021f
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wLinkSendByte = 1
	ld a, $01
	ld [wLinkSendByte], a
	ret


;@ def VSSendPrize()
;@ path: link/vs
;@ VS mode step 23: when the partner is ready too, exchanges the prize records ($95 bytes):
;@ ours goes out, the partner's lands in wBreedParent2.
;@ test: skip runs the link protocol
VSSendPrize::
;> if not VSCheckPartnerCancel():
;>     return
	call VSCheckPartnerCancel
	ret z

;> if wLinkReceivedLast != 1:
;>     return
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wLinkSendLength = 0x95
	ld a, $95
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;> wLinkPrizeSlot = wCurPartyMember
	ld a, [wCurPartyMember]
	ld [wLinkPrizeSlot], a
;> wLinkSendPtr = MonsterField(wMonsters, wCurPartyMember)
	ld hl, wMonsters
	call MonsterField
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wBreedParent2
	ld hl, wBreedParent2
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF                 # send the buffer
	ld a, $ff
	ld [wLinkSendByte], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
	ret


;@ def VSPrizeSent()
;@ path: link/vs
;@ VS mode step 24: waits for the end byte $F0 of the record exchange.
;@ test: wLinkReceivedLast = rand(0xEF, 0xF1)
;@ test: wTitleStep = rand(0, 30)
VSPrizeSent::
;> if wLinkReceivedLast != 0xF0:
;>     return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> wLinkSendByte = 0
	ld a, $00
	ld [wLinkSendByte], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wTextState = 0
	xor a
	ld [wTextState], a
	ret


;@ def VSAskReady()
;@ path: link/vs
;@ VS mode step 25: once the text is done, asks "Are you ready to fight?".
;@ test: skip prints text
VSAskReady::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> PrintSystemText(0x022B)
	ld hl, $022b
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSShowReadyMenu()
;@ path: link/vs
;@ VS mode step 26: once the question is printed, draws the FIGHT / PRIZE / EXIT window.
;@ test: skip draws through helpers
VSShowReadyMenu::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> VSDrawReadyMenu()
	call VSDrawReadyMenu
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSDrawReadyMenu()
;@ path: link/vs
;@ Draws the prize selection windows with the FIGHT / PRIZE / EXIT window and its cursor.
;@ test: skip draws through helpers
VSDrawReadyMenu::
;> VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;> DrawWindowLayout_15(VSReadyWindow)
	ld de, VSReadyWindow
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wConfirmChoice2, VSReadyCursor)
	ld de, VSReadyCursor
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt_15
	ret


;@ def VSReadyInput()
;@ path: link/vs
;@ VS mode step 27: FIGHT goes on to the battle, PRIZE shows the monster the partner offers,
;@ EXIT or B refuses the battle (byte $FE). A refusal from the partner ends it too.
;@ test: skip runs the link protocol
VSReadyInput::
;> if wLinkReceivedLast == 0xFE:        # the partner refused
	ld a, [wLinkReceivedLast]
	cp $fe
	jr nz, .input

;>     PrintSystemText(0x022E)           # "Battle refused."
	ld hl, $022e
	call PrintSystemText
;>     wTitleStep = 0x1E
	ld a, $1e
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp .done


.input
;> MoveMenuCursor_15(wConfirmChoice2, 3, VSReadyCursor)
	ld de, VSReadyCursor
	ld hl, wConfirmChoice2
	ld b, $03
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintSystemText(0x022D)           # "Refused the battle."
.refuse
	ld hl, $022d
	call PrintSystemText
;>     wTitleStep = 0x1E
	ld a, $1e
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp .done


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice2 == 0x80:       # FIGHT
	ld a, [wConfirmChoice2]
	cp $80
;>@five         wTitleStep += 5
	jr z, .fight

;>     elif wConfirmChoice2 == 0x82:     # EXIT: refuse as for B (the code above)
	cp $82
;>         pass                          # jumps to the B code above: "Refused the battle."
	jr z, .refuse

;>     elif wBreedParent2[0]:            # PRIZE: the partner offers one
	ld a, [wBreedParent2]
	or a
	jr z, .noPrize

;>         wFieldMenuState[0] = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp .done


;>     else:
;>         PrintSystemText(0x022F)       # "No prize."
.noPrize
	ld hl, $022f
	call PrintSystemText
;>         wTitleStep = 0x19
	ld a, $19
	ld [wTitleStep], a
	jp .done


.fight
;=@five
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;=@five
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ path: link/vs
;@ Cursor positions of the FIGHT / PRIZE / EXIT window ($FFFF ends).
VSReadyCursor::
	dw $002c, $006c, $00ac
	dw $ffff

;@ def VSShowPartnerPrize()
;@ path: link/vs
;@ VS mode step 28: shows the status screen of the partner's prize (slot $15 = wBreedParent2)
;@ until it closes.
;@ test: skip calls routines in other banks
VSShowPartnerPrize::
;> wCurPartyMember = 0x15
	ld a, $15
	ld [wCurPartyMember], a
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep:
	ld a, [wMenuSubStep]
	or a
	ret z

;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSPartnerPrizeDone()
;@ path: link/vs
;@ VS mode step 29: after the status screen, loads the font again, asks "Are you ready to
;@ fight?" and redraws the screen with the FIGHT / PRIZE / EXIT window.
;@ test: skip calls routines in other banks
VSPartnerPrizeDone::
;> DecompressVRAM(0x2E, 0x1E, 0x9000)   # font
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
;> PrintSystemText(0x022B)
	ld hl, $022b
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> VSDrawPrizeListNames()
	call VSDrawPrizeListNames
;> VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;> VSDrawTeamNames()
	call VSDrawTeamNames
;> VSDrawReadyMenu()
	call VSDrawReadyMenu
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 0x1A
	ld a, $1a
	ld [wTitleStep], a
	ret


;@ def VSRefusedSync()
;@ path: link/vs
;@ VS mode step 30: after a refusal, waits for the partner's $FE, then runs one last block
;@ exchange ($64 bytes of wSavedTilemap both ways) so both Game Boys leave together.
;@ test: skip runs the link protocol
VSRefusedSync::
;> if wLinkReceivedLast != 0xFE:
;>     return
	ld a, [wLinkReceivedLast]
	cp $fe
	ret nz

;> wLinkSendLength = 0x64
	ld a, $64
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;> wLinkSendPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSBackToTitle()
;@ path: link/vs
;@ VS mode step 31: when the last exchange has ended ($F0), closes the link and goes back to
;@ the title menu (game mode 0 step 1).
;@ test: skip starts a fade
VSBackToTitle::
;> if wLinkReceivedLast != 0xF0:
;>     return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> wGameMode = 0; wGameModeStep = 1
	ld hl, wGameMode
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
;> mem[0xC88C] = 0; mem[0xC88D] = 0
	ld a, $00
	ld [hli], a
	ld [hl], $00
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wLinkMode = 0; wLinkPhase = 0
	ld a, $00
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
;> wLinkFlags = 0
	xor a
	ld [wLinkFlags], a
;> wSerialLock = 0
	ld [wSerialLock], a
;> wLinkActive = 0
	ld [wLinkActive], a
;> wLinkReceivedLast = 0
	xor a
	ld [wLinkReceivedLast], a
;> wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;> wLinkCommand = 0
	xor a
	ld [wLinkCommand], a
;> StartFade(0x04)
	ld a, $04
	call StartFade
	ret


;@ def VSFightWait()
;@ path: link/vs
;@ VS mode step 32: "One moment please." and tells the partner this side is ready (byte 1).
;@ test: skip prints text
VSFightWait::
;> PrintSystemText(0x021F)
	ld hl, $021f
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wLinkSendByte = 1
	ld a, $01
	ld [wLinkSendByte], a
	ret


;@ def VSSendTeams()
;@ path: link/vs
;@ VS mode step 33: when the partner is ready, moves the team into monster slots 0-2 (through
;@ the buffer wSavedTilemap), notes where the members came from (wVSTeamSlots, wVSTeamCount)
;@ and sends the three records ($1BF bytes); the partner's team arrives in slots 4-6. Prints
;@ "Fight!!".
;@ test: skip runs the link protocol
VSSendTeams::
;> if wLinkReceivedLast == 0xFE:        # the partner refused
	ld a, [wLinkReceivedLast]
	cp $fe
	jr nz, .notRefused

;>     PrintSystemText(0x022E)           # "Battle refused."
	ld hl, $022e
	call PrintSystemText
;>     wTitleStep = 0x1E
	ld a, $1e
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp .done


.notRefused
;> if wLinkReceivedLast != 1:
;>     return
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

;> CopyTeamRecord(wVSTeam[0], wSavedTilemap)
	ld a, [wVSTeam]
	ld de, wSavedTilemap
	call CopyTeamRecord
;> CopyTeamRecord(wVSTeam[1], wSavedTilemap + 0x95)
	ld a, [wVSTeam + 1]
	ld de, $c395
	call CopyTeamRecord
;> CopyTeamRecord(wVSTeam[2], wSavedTilemap + 0x12A)
	ld a, [wVSTeam + 2]
	ld de, $c42a
	call CopyTeamRecord
;>@copy copy(wMonsters, wSavedTilemap, 3 * 0x95)
	ld hl, wSavedTilemap
	ld de, wMonsters
	ld b, $95

.copy
;=@copy
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
;=@copy
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy

;> wVSTeamSlots[0:3] = wVSTeam[0:3]
	ld a, [wVSTeam]
	ld [wVSTeamSlots], a
	ld a, [wVSTeam + 1]
	ld [wVSTeamSlots + 1], a
	ld a, [wVSTeam + 2]
	ld [wVSTeamSlots + 2], a
;> wVSTeamCount = 0
	xor a
	ld [wVSTeamCount], a
;>@cnt for i in range(3):              # count the members up to the first empty place
;>@cnt2     if wVSTeamSlots[i] == 0xFF: break
	ld a, [wVSTeamSlots]
	cp $ff
	jr z, .counted

;>@inc     wVSTeamCount = i + 1
	ld a, $01
	ld [wVSTeamCount], a
;=@cnt2
	ld a, [wVSTeamSlots + 1]
	cp $ff
	jr z, .counted

;=@inc
	ld a, $02
	ld [wVSTeamCount], a
;=@cnt2
	ld a, [wVSTeamSlots + 2]
	cp $ff
	jr z, .counted

;=@inc
	ld a, $03
	ld [wVSTeamCount], a

.counted
;>@master copy(wMonMaster, wPlayerName, 8)    # the first member's master is this player
	ld hl, wPlayerName
	ld de, wMonMaster
	ld b, $08

.master
;=@master
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .master

;> wLinkSendLength = 0x1BF             # the three records
	ld hl, $01bf
	ld a, l
	ld [wLinkSendLength], a
	ld a, h
	ld [wLinkSendLength + 1], a
;> wLinkSendPtr = wMonsters
	ld hl, wMonsters
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wMonsters + 4 * 0x95  # slot 4
	ld hl, $cd15
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> PrintSystemText(0x022C)             # "Fight!!"
	ld hl, $022c
	call PrintSystemText

.done
	ret


;@ def CopyTeamRecord(slot: a, dest: de)
;@ path: link/vs
;@ Copies the $95-byte record of monster `slot` to `dest`; an empty team place ($FF) gives a
;@ record whose first byte is 0 (no monster).
;@ test: skip copies through MonsterField
CopyTeamRecord::
;> if slot & 0x7F == 0x7F:
	and $7f
	cp $7f
	jr nz, .copy

;>     mem[dest] = 0
	xor a
	ld [de], a
	ret


;> else:
;>@copy     copy(dest, MonsterField(wMonsters, slot), 0x95)
.copy
	push de
	ld hl, wMonsters
	call MonsterField
	pop de
	ld b, $95

.loop
;=@copy
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .loop

	ret


;@ def VSStartBattle()
;@ path: link/vs
;@ VS mode step 34: when the teams are exchanged ($F0), the Game Boy that drives the clock
;@ swaps slots 0-2 with 4-6, so that on both Game Boys slots 0-2 hold the same team; makes
;@ those slots the party and starts the battle (game mode 2, link mode 1).
;@ test: skip calls routines in other banks
VSStartBattle::
;> if wLinkReceivedLast != 0xF0:
;>     return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> RollEncounterGroup()
	ld hl, far_RollEncounterGroup
	rst $10
;> src = dst = wMonsters
	ld hl, wMonsters
	ld de, wMonsters
	ld b, $95
;> if wLinkFlags & 0x02:                # this side drives the clock
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .swap

;>     dst = wMonsters + 4 * 0x95        # slot 4
	ld de, $cd15

.swap
;>@swap for i in range(3 * 0x95):            # (src == dst changes nothing)
;>     mem[src + i], mem[dst + i] = mem[dst + i], mem[src + i]
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
;=@swap
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
;=@swap
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
;=@swap
	dec b
	jr nz, .swap

;> wParty[0:3] = [0xFF, 0xFF, 0xFF]
	ld a, $ff
	ld [wParty], a
	ld [wParty + 1], a
	ld [wParty + 2], a
;> count = 0
	ld b, $00
;>@p0 for i in range(3):               # slots 0-2 up to the first empty one
;>@p1     if mem[wMonsters + i * 0x95] == 0: break
	ld a, [wMonsters]
	or a
	jr z, .partyDone

;>@p2     wParty[i] = i; count += 1
	ld a, $00
	ld [wParty], a
	inc b
;=@p1
	ld a, [$cb56]
	or a
	jr z, .partyDone

;=@p2
	ld a, $01
	ld [wParty + 1], a
	inc b
;=@p1
	ld a, [$cbeb]
	or a
	jr z, .partyDone

;=@p2
	ld a, $02
	ld [wParty + 2], a
	inc b

.partyDone
;> wPartyCount = count
	ld a, b
	ld [wPartyCount], a
;> if wLinkPrizeSlot == 0x14:           # no prize offered
	ld a, [wLinkPrizeSlot]
	cp $14
	jr nz, .start

;>     wLinkPrizeSlot = 0xFF
	ld a, $ff
	ld [wLinkPrizeSlot], a

.start
;> wGameMode = 2; wGameModeStep = 0     # the battle
	ld hl, wGameMode
	ld a, $02
	ld [hli], a
	ld a, $00
	ld [hli], a
;> mem[0xC88C] = 0; mem[0xC88D] = 0
	ld a, $00
	ld [hli], a
	ld [hl], $00
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wLinkMode = 1; wLinkPhase = 0
	ld a, $01
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
;> wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;> wLinkReceivedLast = 0
	xor a
	ld [wLinkReceivedLast], a
	ret


;@ def VSPrizeInParty()
;@ path: link/vs
;@ VS mode step 35: after "You cannot choose the monster in your current party as a prize."
;@ redraws the prize list (back to step 16).
;@ test: skip draws through helpers
VSPrizeInParty::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> VSDrawPrizeListNames()
	call VSDrawPrizeListNames
;> VSDrawPrizeWindows()
	call VSDrawPrizeWindows
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x022A)             # "Choose a monster for the prize?"
	ld hl, $022a
	call PrintSystemText
;> wTitleStep = 0x10
	ld a, $10
	ld [wTitleStep], a
	ret


;@ def VSPartnerCancelled()
;@ path: link/vs
;@ VS mode step 36: one side cancelled (byte $FD); once the partner's $FD arrives, runs the last
;@ block exchange and goes to step 31 (back to the title).
;@ test: skip runs the link protocol
VSPartnerCancelled::
;> if wLinkReceivedLast != 0xFD:
;>     return
	ld a, [wLinkReceivedLast]
	cp $fd
	ret nz

;> wLinkSendLength = 0x64
	ld a, $64
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;> wLinkSendPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wTitleStep = 0x1F
	ld a, $1f
	ld [wTitleStep], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
	ret


;@ def VSCheckPartnerCancel()
;@ path: link/vs
;@ Checks whether the partner cancelled VS mode (byte $FD). If so prints "Battle refused.",
;@ answers $FD and goes to step 36, returning false (zero flag set); else returns true.
;@ test: skip prints text
VSCheckPartnerCancel::
;> if wLinkReceivedLast != 0xFD:
;>     return True
	ld a, [wLinkReceivedLast]
	cp $fd
	ret nz

;> PrintSystemText(0x022E)             # "Battle refused."
	ld hl, $022e
	call PrintSystemText
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 0x24
	ld a, $24
	ld [wTitleStep], a
;> wLinkSendByte = 0xFD
	ld a, $fd
	ld [wLinkSendByte], a
;> return False
	xor a
	ret


;@ def VSDrawStatusMonster()
;@ path: link/menu
;@ On page 5 of the monster status screen (wFieldMenuStep 5), draws the monster's sprite at
;@ (144, 64), stepping between its two frames every 16 frames.
;@ test: skip calls routines in other banks
VSDrawStatusMonster::
;> if wFieldMenuStep != 5:
;>     return
	ld a, [wFieldMenuStep]
	cp $05
	ret nz

;> species = mem[MonsterField(wMonRecSpecies, wCurPartyMember)]
	ld hl, wMonRecSpecies
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
	push af
;> hSpriteX = 0x0090
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0040
	ld a, $40
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@frame hSpriteFrame = (wFrameCounter >> 4) & 1
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame

	ld b, $01

.frame
;=@frame
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x50; hSpriteAttr = 0
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def VSDrawStatusParents()
;@ path: link/menu
;@ On page 9 of the monster status screen (the pedigree), draws the sprites of both parents
;@ at (144, 48) and (144, 120).
;@ test: skip calls routines in other banks
VSDrawStatusParents::
;> if wFieldMenuStep != 9:
;>     return
	ld a, [wFieldMenuStep]
	cp $09
	ret nz

;> species = mem[MonsterField(wMonParent1, wCurPartyMember)]
	ld hl, wMonParent1
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
;> if species == 0xFF:                  # no parents
;>     return
	cp $ff
	ret z

;> hSpriteX = 0x0090
	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0030
	ld a, $30
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@frame1 hSpriteFrame = (wFrameCounter >> 4) & 1
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame1

	ld b, $01

.frame1
;=@frame1
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x60; hSpriteAttr = 0
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
;> species = mem[MonsterField(wMonParent2, wCurPartyMember)]
	ld hl, wMonParent2
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
	push af
;> hSpriteX = 0x0090
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0078
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@frame2 hSpriteFrame = (wFrameCounter >> 4) & 1
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame2

	ld b, $01

.frame2
;=@frame2
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x70; hSpriteAttr = 0
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def TitleUpdateBreedLink()
;@ path: link/breed
;@ Game loop part of breeding over the link (game mode 0 step 3): the frames themselves run from
;@ the serial interrupt (BreedLinkFrame); here the link timeout is counted and, while a status
;@ screen is open (steps 6 and 14), the monster sprites on it are drawn.
;@ test: skip calls routines in other banks
TitleUpdateBreedLink::
;> LinkFrameUpdate()
	call LinkFrameUpdate
;>@status if wTitleStep in (6, 0x0E):
	ld a, [wTitleStep]
	cp $06
	jr z, .status

;=@status
	cp $0e
	jr z, .status

	ret


.status
;>     BreedDrawStatusMonster()
	call BreedDrawStatusMonster
;>     BreedDrawStatusParents()
	call BreedDrawStatusParents
;>     LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ret


;@ def BreedLinkFrame()
;@ path: link/breed
;@ One frame of breeding over the link, run from the serial interrupt: the current step.
;@ test: skip runs the link protocol
BreedLinkFrame::
;> BreedLinkSteps[wTitleStep]()
	ld a, [wTitleStep]
	rst $00

;@ path: link/breed
;@ Steps of breeding over the link: 0-7 choose a monster from the farm (INFO shows its status),
;@ 8-10 exchange the two records and check the pair, 11-15 the BREED / CHECK / EXIT menu,
;@ 16 back to the list, 17-18 refused (back to the title), 19-24 "Save the result of
;@ breeding?", the last exchange and the offspring, 25 the partner cancelled.
BreedLinkSteps::
	dw BreedStart
	dw BreedShowList
	dw BreedListInput
	dw BreedPicked
	dw BreedShowChoice
	dw BreedChoiceInput
	dw BreedShowStatus
	dw BreedStatusDone
	dw BreedWait
	dw BreedSendMonster
	dw BreedCheckPair
	dw BreedAskBreed
	dw BreedShowMenu
	dw BreedMenuInput
	dw BreedShowPartner
	dw BreedPartnerDone
	dw BreedBackToList
	dw BreedRefusedSync
	dw BreedBackToTitle
	dw BreedAskSave
	dw BreedShowSaveYesNo
	dw BreedSaveInput
	dw BreedFinalWait
	dw BreedFinalSync
	dw BreedMakeOffspring
	dw BreedPartnerCancelled

;@ def BreedStart()
;@ path: link/breed
;@ Breeding step 0: lists the hatched monsters.
;@ test: wTitleStep = rand(0, 3)
BreedStart::
;> CountBreedCandidates()
	call CountBreedCandidates
;> ListBreedCandidates()
	call ListBreedCandidates
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def CountBreedCandidates() -> a
;@ path: link/breed
;@ Counts the hatched monsters (owned, not eggs) into wTitleListCount and returns the count.
CountBreedCandidates::
;> rec = wMonsters; count = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@for for slot in range(20):
.loop
	push de
;>     if mem[rec]:
	ld a, [de]
	or a
	jr z, .next

;>@egg         if mem[rec + 0x63] == 0:      # not an egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next

;>             count += 1
	inc c

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
;=@rec
	ld a, d
	adc $00
	ld d, a
;=@for
	dec b
	jr nz, .loop

;> wTitleListCount = count
	ld a, c
	ld [wTitleListCount], a
;> return count
	ret


;@ def ListBreedCandidates()
;@ path: link/breed
;@ Fills the list in wSceneObjects (20 bytes, $FF = end) with the slots of all hatched
;@ monsters.
ListBreedCandidates::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = wSceneObjects
	ld hl, wSceneObjects
;> rec = wMonsters
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@for for slot in range(20):
.loop
	push de
;>     if mem[rec]:
	ld a, [de]
	or a
	jr z, .next

;>@egg         if mem[rec + 0x63] == 0:
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@egg
	ld a, [de]
	or a
	jr nz, .next

;>             mem[out] = slot; out += 1
	ld [hl], c
	inc hl

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
;=@rec
	ld a, d
	adc $00
	ld d, a
;=@for
	inc c
	dec b
	jr nz, .loop

	ret


;@ def BreedShowList()
;@ path: link/breed
;@ Breeding step 1: once the text is done, draws the monster list and asks "Choose a monster
;@ for breeding."
;@ test: skip calls routines in other banks
BreedShowList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> BreedDrawListNames()
	call BreedDrawListNames
;> BreedDrawWindows()
	call BreedDrawWindows
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> PrintSystemText(0x021C)             # "Choose a monster for breeding."
	ld hl, $021c
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedDrawWindows()
;@ path: link/breed
;@ Draws the windows of the breeding list: the cursor monster's name and level, the list of
;@ four names and the text box, with the list cursor.
;@ test: skip draws through helpers
BreedDrawWindows::
;> DrawWindowLayout_15(TitleNameWindow)
	ld de, TitleNameWindow
	call DrawWindowLayout_15
;> DrawCursorMonLevel()
	call DrawCursorMonLevel
;> DrawWindowLayout_15(TitleListWindow)
	ld de, TitleListWindow
	call DrawWindowLayout_15
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;>@g7 MenuDrawListCursor_15(wMenuChoice, BreedListCursor, 4, wTitleListCount)
	ld de, BreedListCursor
	ld b, $04
	ld a, [wTitleListCount]
	ld c, a
	ld hl, wMenuChoice
	call MenuDrawListCursor_15
;=@g7
	ret


;@ def BreedDrawListNames()
;@ path: link/breed
;@ Draws the names of the four list entries on the current page into the tiles from $9100 on
;@ (as VSDrawListNames).
;@ test: skip writes VRAM
BreedDrawListNames::
;>@entry entry = wSceneObjects + wMenuChoice2 * 4
	ld a, [wMenuChoice2]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@entry
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9100
	ld hl, $9100
;> for i in range(4):                   # the fourth by running on into BreedDrawListName
;>     entry, tiles = BreedDrawListName(entry, tiles)
	call BreedDrawListName
	call BreedDrawListName
	call BreedDrawListName

;@ def BreedDrawListName(entry: de, tiles: hl) -> (de, hl)
;@ path: link/breed
;@ A copy of VSDrawListName: the name of the monster in list entry `entry` into the 4 tiles at
;@ `tiles` (blank for an empty entry); returns the next entry and tiles.
;@ test: skip writes VRAM
BreedDrawListName::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>@name     DrawNameTiles_15(MonsterField(wMonName, mem[entry]), tiles)
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	pop hl
	push hl
	call DrawNameTiles_15
;>@ret     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
;=@ret
	adc $00
	ld h, a
	pop de
	inc de
	ret


;> else:
;>     for i in range(32):              # blank tiles
.blank
	ld b, $20

.blankLoop
;>         tiles = WriteVRAMInc(0xFF, tiles)
	ld a, $ff
	call WriteVRAMInc
;>         tiles = WriteVRAMInc(0x00, tiles)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blankLoop

;>@ret2     return entry + 1, tiles + 0x40
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
;=@ret2
	adc $00
	ld h, a
	pop de
	inc de
	ret


;@ def BreedListInput()
;@ path: link/breed
;@ Breeding step 2: moves the cursor through the monster list. A picks the monster; B refuses
;@ to breed (byte $FD to the partner).
;@ test: skip runs the link protocol
BreedListInput::
;> if wFadeState or wTextState:
;>@wait     return
	ld a, [wFadeState]
	or a
	ret nz

;=@wait
	ld a, [wTextState]
	or a
	ret nz

;> if not BreedCheckPartnerCancel():
;>     return
	call BreedCheckPartnerCancel
	ret z

;>@old old_page = wMenuChoice2; old_cursor = wMenuChoice
	ld de, BreedListCursor
	ld hl, wMenuChoice
	ld a, [wTitleListCount]
	ld c, a
	ld b, $04
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> MovePagedListCursor_15(wMenuChoice, 4, wTitleListCount, BreedListCursor)
	call MovePagedListCursor_15
;> if wMenuChoice != old_cursor:
	pop af
	ld hl, wMenuChoice
	cp [hl]
	jr z, .samePos

;>     DrawCursorMonName()
	call DrawCursorMonName
;>     DrawCursorMonLevel()
	call DrawCursorMonLevel
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15

.samePos
;> if wMenuChoice2 != old_page:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .samePage

;>     BreedDrawListNames()
	call BreedDrawListNames
;>     DrawCursorMonName()
	call DrawCursorMonName
;>     DrawCursorMonLevel()
	call DrawCursorMonLevel
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15

.samePage
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jp z, .notB

;>     PrintSystemText(0x0221)           # "Refused to breed."
	ld hl, $0221
	call PrintSystemText
;>     wTitleStep = 0x19
	ld a, $19
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFD
	ld a, $fd
	ld [wLinkSendByte], a
	jr .done

;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wConfirmChoice = 0
	xor a
	ld [wConfirmChoice], a
;>@pick     wCurPartyMember = wSceneObjects[wMenuChoice2 * 4 + (wMenuChoice & 0x7F)]
	ld a, [wMenuChoice2]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice]
	and $7f
;=@pick
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@pick
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ path: link/breed
;@ Cursor positions of the breeding list: the page number, then the four rows ($FFFF ends).
BreedListCursor::
	dw $0145
	dw $0061, $00a1, $00e1, $0121
	dw $ffff

;@ def BreedPicked()
;@ path: link/breed
;@ Breeding step 3: goes on to the INFO / OK choice.
;@ test: wTitleStep = rand(0, 30)
BreedPicked::
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedShowChoice()
;@ path: link/breed
;@ Breeding step 4: once the text is done, draws the INFO / OK window for the picked monster.
;@ test: skip draws through helpers
BreedShowChoice::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> BreedDrawChoice()
	call BreedDrawChoice
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedDrawChoice()
;@ path: link/breed
;@ Draws the breeding list windows with the INFO / OK window and its cursor.
;@ test: skip draws through helpers
BreedDrawChoice::
;> BreedDrawWindows()
	call BreedDrawWindows
;> DrawWindowLayout_15(InfoOkWindow)
	ld de, InfoOkWindow
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wConfirmChoice, BreedChoiceCursor)
	ld de, BreedChoiceCursor
	ld a, [wConfirmChoice]
	call MenuDrawCursorAt_15
	ret


;@ def BreedChoiceInput()
;@ path: link/breed
;@ Breeding step 5: INFO / OK. B goes back to the list, INFO opens the status screen. OK takes
;@ the monster unless it is in the party (it must come from the farm) or below level 10; then
;@ the exchange follows.
;@ test: skip runs the link protocol
BreedChoiceInput::
;> if not BreedCheckPartnerCancel():
;>     return
	call BreedCheckPartnerCancel
	ret z

;> MoveMenuCursor_15(wConfirmChoice, 2, BreedChoiceCursor)
	ld de, BreedChoiceCursor
	ld hl, wConfirmChoice
	ld b, $02
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;>     DrawCursorMonName()
	call DrawCursorMonName
;>     BreedDrawListNames()
	call BreedDrawListNames
;>     BreedDrawWindows()
	call BreedDrawWindows
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>@g8     wTitleStep -= 3                   # back to the list
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
;=@g8
	jp .done


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice != 0x81:        # INFO
	ld a, [wConfirmChoice]
	cp $81
	jr z, .ok

;>         wFieldMenuState[0] = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp .done


;>@party     elif IsInStashedParty(wCurPartyMember) or mem[MonsterField(wMonsters, wCurPartyMember)] == 2:
.ok
	ld a, [wCurPartyMember]
	ld b, a
	call IsInStashedParty
	jr nz, .inParty

;=@party
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	cp $02
	jr nz, .checkLevel

;>         PrintSystemText(0x025D)       # "Please choose a monster from the farm."
.inParty
	ld hl, $025d
	call PrintSystemText
;>         wTitleStep = 0x10
	ld a, $10
	ld [wTitleStep], a
	jr .done

;>     elif mem[MonsterField(wMonLevel, wCurPartyMember)] < 10:
.checkLevel
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $0a
	jr nc, .accept

;>         PrintSystemText(0x0230)       # "Your monster is not old enough for breeding..."
	ld hl, $0230
	call PrintSystemText
;>         wTitleStep = 0x10
	ld a, $10
	ld [wTitleStep], a
	jr .done

;>     else:
;>@g9         wTitleStep += 3               # on to the exchange
.accept
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]

.done
;=@g9
	ret


;@ path: link/breed
;@ Cursor positions of the INFO / OK window of the breeding list ($FFFF ends).
BreedChoiceCursor::
	dw $002e, $006e
	dw $ffff

;@ def BreedShowStatus()
;@ path: link/breed
;@ Breeding step 6: runs the monster status screen for the picked monster until it closes.
;@ test: skip calls routines in other banks
BreedShowStatus::
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep:
	ld a, [wMenuSubStep]
	or a
	ret z

;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedStatusDone()
;@ path: link/breed
;@ Breeding step 7: after the status screen, loads the font again and redraws the list with
;@ the INFO / OK window (back to step 5).
;@ test: skip calls routines in other banks
BreedStatusDone::
;> DecompressVRAM(0x2E, 0x1E, 0x9000)   # font
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
;> PrintSystemText(0x021C)             # "Choose a monster for breeding."
	ld hl, $021c
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> BreedDrawListNames()
	call BreedDrawListNames
;> BreedDrawChoice()
	call BreedDrawChoice
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 5
	ld a, $05
	ld [wTitleStep], a
	ret


;@ def BreedWait()
;@ path: link/breed
;@ Breeding step 8: "One moment please." and tells the partner this side is ready (byte 1).
;@ test: skip prints text
BreedWait::
;> PrintSystemText(0x021F)
	ld hl, $021f
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wLinkSendByte = 1
	ld a, $01
	ld [wLinkSendByte], a
	ret


;@ def BreedSendMonster()
;@ path: link/breed
;@ Breeding step 9: when the partner is ready, exchanges the chosen monsters' records ($95
;@ bytes); the partner's arrives in wBreedParent2.
;@ test: skip runs the link protocol
BreedSendMonster::
;> if not BreedCheckPartnerCancel():
;>     return
	call BreedCheckPartnerCancel
	ret z

;> if wLinkReceivedLast != 1:
;>     return
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wLinkSendLength = 0x95
	ld a, $95
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;>@send wLinkSendPtr = MonsterField(wMonsters, wCurPartyMember)
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
;=@send
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wBreedParent2
	ld hl, wBreedParent2
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
	ret


;@ def BreedCheckPair()
;@ path: link/breed
;@ Breeding step 10: when the records are exchanged ($F0), checks the pair: the two monsters
;@ must be of different sex, and BreedCompatibility must allow the two personalities. Else a
;@ message and back to the list.
;@ test: skip calls routines in other banks
BreedCheckPair::
;> if wLinkReceivedLast != 0xF0:
;>     return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;>@sex if mem[MonsterField(wMonGender, wCurPartyMember)] & 1 == wBreedParent2[0x0B] & 1:
	ld a, [wCurPartyMember]
	ld hl, wMonGender
	call MonsterField
	ld a, [wBreedParent2 + $0b]
	and $01
	ld b, a
;=@sex
	ld a, [hl]
	and $01
	cp b
	jr nz, .otherSex

;>     PrintSystemText(0x021E)           # "Same gender. Cannot breed."
	ld hl, $021e
	call PrintSystemText
;>     wTitleStep = 0x10
	ld a, $10
	ld [wTitleStep], a
	jr .done

;> else:
;>@pers     i = GetMonsterPersonality(wCurPartyMember) * 27
.otherSex
	ld a, [wCurPartyMember]
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	ld c, $1b
;=@pers
	call Multiply
;>@pers2     i += GetMonsterPersonality(0x15)  # the partner's monster
	push hl
	ld d, $15
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	pop hl
;=@pers2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@compat     if BreedCompatibility[i] == 0:
	ld a, l
	add LOW(BreedCompatibility)
	ld l, a
	ld a, h
	adc HIGH(BreedCompatibility)
	ld h, a
;=@compat
	ld a, [hl]
	or a
	jr nz, .compatible

;>         PrintSystemText(0x025E)       # "Too bad... Breeding failed."
	ld hl, $025e
	call PrintSystemText
;>         wTitleStep = 0x10
	ld a, $10
	ld [wTitleStep], a
	jr .done

;>     else:
;>         wLinkSendByte = 0
.compatible
	ld a, $00
	ld [wLinkSendByte], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ def BreedAskBreed()
;@ path: link/breed
;@ Breeding step 11: asks "Want to breed?".
;@ test: skip prints text
BreedAskBreed::
;> PrintSystemText(0x0220)
	ld hl, $0220
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedShowMenu()
;@ path: link/breed
;@ Breeding step 12: once the question is printed, draws the BREED / CHECK / EXIT window.
;@ test: skip draws through helpers
BreedShowMenu::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> BreedDrawMenu()
	call BreedDrawMenu
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedDrawMenu()
;@ path: link/breed
;@ Draws the breeding list windows with the BREED / CHECK / EXIT window and its cursor.
;@ test: skip draws through helpers
BreedDrawMenu::
;> BreedDrawWindows()
	call BreedDrawWindows
;> DrawWindowLayout_15(BreedMenuWindow)
	ld de, BreedMenuWindow
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wConfirmChoice2, BreedMenuCursor)
	ld de, BreedMenuCursor
	ld a, [wConfirmChoice2]
	call MenuDrawCursorAt_15
	ret


;@ def BreedMenuInput()
;@ path: link/breed
;@ Breeding step 13: BREED goes on to "Save the result of breeding?", CHECK shows the
;@ partner's monster, EXIT or B refuses (byte $FE). A refusal from the partner ends it too.
;@ test: skip runs the link protocol
BreedMenuInput::
;> if wLinkReceivedLast == 0xFE:        # the partner refused
	ld a, [wLinkReceivedLast]
	cp $fe
	jr nz, .input

;>     PrintSystemText(0x0222)           # "Breeding refused."
	ld hl, $0222
	call PrintSystemText
;>     wTitleStep = 0x11
	ld a, $11
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp Jump_015_58e0


.input
;> MoveMenuCursor_15(wConfirmChoice2, 3, BreedMenuCursor)
	ld de, BreedMenuCursor
	ld hl, wConfirmChoice2
	ld b, $03
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintSystemText(0x0221)           # "Refused to breed."
.refuse
	ld hl, $0221
	call PrintSystemText
;>     wTitleStep = 0x11
	ld a, $11
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp Jump_015_58e0


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_015_58e0

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice2 == 0x80:       # BREED
	ld a, [wConfirmChoice2]
	cp $80
;>@six         wTitleStep += 6
	jr z, .breed

;>     elif wConfirmChoice2 == 0x82:     # EXIT: refuse as for B (the code above)
	cp $82
;>         pass                          # jumps to the B code above: "Refused to breed."
	jr z, .refuse

;>     else:                             # CHECK
;>         wFieldMenuState[0] = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>@g10         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp Jump_015_58e0


.breed
;=@six
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;=@six
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]

Jump_015_58e0:
;=@g10
	ret


;@ path: link/breed
;@ Cursor positions of the BREED / CHECK / EXIT window ($FFFF ends).
BreedMenuCursor::
	dw $002c, $006c, $00ac
	dw $ffff

;@ def BreedShowPartner()
;@ path: link/breed
;@ Breeding step 14: CHECK shows the status screen of the partner's monster (slot $15 =
;@ wBreedParent2) until it closes.
;@ test: skip calls routines in other banks
BreedShowPartner::
;> wCurPartyMember = 0x15
	ld a, $15
	ld [wCurPartyMember], a
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep:
	ld a, [wMenuSubStep]
	or a
	ret z

;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedPartnerDone()
;@ path: link/breed
;@ Breeding step 15: after the status screen, loads the font again, asks "Want to breed?" and
;@ redraws the BREED / CHECK / EXIT menu (back to step 13).
;@ test: skip calls routines in other banks
BreedPartnerDone::
;> DecompressVRAM(0x2E, 0x1E, 0x9000)   # font
	ld de, $2e1e
	ld hl, $9000
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x1F, 0x8800)
	ld de, $2e1f
	ld hl, $8800
	call DecompressVRAM
;> PrintSystemText(0x0220)             # "Want to breed?"
	ld hl, $0220
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> BreedDrawListNames()
	call BreedDrawListNames
;> BreedDrawMenu()
	call BreedDrawMenu
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 0x0D
	ld a, $0d
	ld [wTitleStep], a
	ret


;@ def BreedBackToList()
;@ path: link/breed
;@ Breeding step 16: after a message (wrong monster, same sex, failed pair) clears the byte
;@ sent to the partner and shows the list again (step 2).
;@ test: skip calls routines in other banks
BreedBackToList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wLinkSendByte = 0
	ld a, $00
	ld [wLinkSendByte], a
;> PrintSystemText(0x021C)             # "Choose a monster for breeding."
	ld hl, $021c
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> DrawCursorMonName()
	call DrawCursorMonName
;> BreedDrawListNames()
	call BreedDrawListNames
;> BreedDrawWindows()
	call BreedDrawWindows
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 2
	ld a, $02
	ld [wTitleStep], a
	ret


;@ def BreedRefusedSync()
;@ path: link/breed
;@ Breeding step 17: after a refusal, waits for the partner's $FE, then runs one last block
;@ exchange ($64 bytes of wSavedTilemap both ways) so both Game Boys leave together.
;@ test: skip runs the link protocol
BreedRefusedSync::
;> if wLinkReceivedLast != 0xFE:
;>     return
	ld a, [wLinkReceivedLast]
	cp $fe
	ret nz

;> wLinkSendLength = 0x64
	ld a, $64
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;> wLinkSendPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedBackToTitle()
;@ path: link/breed
;@ Breeding step 18: when the last exchange has ended ($F0), closes the link and goes back to
;@ the title menu (game mode 0 step 1).
;@ test: skip starts a fade
BreedBackToTitle::
;> if wLinkReceivedLast != 0xF0:
;>     return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> wGameMode = 0; wGameModeStep = 1
	ld hl, wGameMode
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
;> mem[0xC88C] = 0; mem[0xC88D] = 0
	ld a, $00
	ld [hli], a
	ld [hl], $00
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wLinkMode = 0; wLinkPhase = 0
	ld a, $00
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
;> wLinkFlags = 0
	xor a
	ld [wLinkFlags], a
;> wSerialLock = 0
	ld [wSerialLock], a
;> wLinkActive = 0
	ld [wLinkActive], a
;> wLinkReceivedLast = 0
	xor a
	ld [wLinkReceivedLast], a
;> wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;> wLinkCommand = 0
	xor a
	ld [wLinkCommand], a
;> StartFade(0x04)
	ld a, $04
	call StartFade
	ret


;@ def BreedAskSave()
;@ path: link/breed
;@ Breeding step 19: asks "Save the result of breeding?".
;@ test: skip prints text
BreedAskSave::
;> PrintSystemText(0x0223)
	ld hl, $0223
	call PrintSystemText
;> wMenuChoice3 = 0
	xor a
	ld [wMenuChoice3], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedShowSaveYesNo()
;@ path: link/breed
;@ Breeding step 20: once the question is printed, beeps and draws its YES / NO window.
;@ test: skip draws through helpers
BreedShowSaveYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> ClearTilemapBuffer_15()
	call ClearTilemapBuffer_15
;> BreedDrawSaveYesNo()
	call BreedDrawSaveYesNo
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def BreedDrawSaveYesNo()
;@ path: link/breed
;@ Draws the breeding menu with the YES / NO window of "Save the result of breeding?".
;@ test: skip draws through helpers
BreedDrawSaveYesNo::
;> BreedDrawMenu()
	call BreedDrawMenu
;> DrawWindowLayout_15(BreedSaveYesNoWindow)
	ld de, BreedSaveYesNoWindow
	call DrawWindowLayout_15
;> MenuResetBlink_15()
	call MenuResetBlink_15
;> MenuDrawCursorAt_15(wMenuChoice3, BreedSaveCursor)
	ld de, BreedSaveCursor
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt_15
	ret


;@ def BreedSaveInput()
;@ path: link/breed
;@ Breeding step 21: YES goes on to the breeding; NO or B goes back to "Want to breed?". A
;@ refusal from the partner ends it.
;@ test: skip runs the link protocol
BreedSaveInput::
;> if wLinkReceivedLast == 0xFE:        # the partner refused
	ld a, [wLinkReceivedLast]
	cp $fe
	jr nz, .input

;>     PrintSystemText(0x0222)           # "Breeding refused."
	ld hl, $0222
	call PrintSystemText
;>     wTitleStep = 0x11
	ld a, $11
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp Jump_015_58e0


.input
;> MoveMenuCursor_15(wMenuChoice3, 2, BreedSaveCursor)
	ld de, BreedSaveCursor
	ld hl, wMenuChoice3
	ld b, $02
	call MoveMenuCursor_15
;> if wJoyPressed & B_BUTTON:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     ClearTilemapBuffer_15()
.back
	call ClearTilemapBuffer_15
;>     BreedDrawMenu()
	call BreedDrawMenu
;>     CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;>     PrintSystemText(0x0220)           # "Want to breed?"
	ld hl, $0220
	call PrintSystemText
;>     wTitleStep = 0x0C
	ld a, $0c
	ld [wTitleStep], a
	jp .done


;> elif wJoyPressed & A_BUTTON:
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:          # NO: back as for B (the code above)
	ld a, [wMenuChoice3]
	cp $81
;>         pass                          # jumps to the B code above: back to "Want to breed?"
	jr z, .back

;>     else:
;>         wFieldMenuState[0] = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp .done


.done
	ret


;@ path: link/breed
;@ Cursor positions of the YES / NO window of "Save the result of breeding?" ($FFFF ends).
BreedSaveCursor::
	dw $012f, $016f
	dw $ffff

;@ def BreedFinalWait()
;@ path: link/breed
;@ Breeding step 22: "One moment please." and tells the partner this side is ready (byte 1).
;@ test: skip prints text
BreedFinalWait::
;> PrintSystemText(0x021F)
	ld hl, $021f
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wLinkSendByte = 1
	ld a, $01
	ld [wLinkSendByte], a
	ret


;@ def BreedFinalSync()
;@ path: link/breed
;@ Breeding step 23: when the partner is ready too, runs the last block exchange and prints
;@ "The ceremony!". A refusal from the partner ends it.
;@ test: skip runs the link protocol
BreedFinalSync::
;> if wLinkReceivedLast == 0xFE:        # the partner refused
	ld a, [wLinkReceivedLast]
	cp $fe
	jr nz, .notRefused

;>     PrintSystemText(0x0222)           # "Breeding refused."
	ld hl, $0222
	call PrintSystemText
;>     wTitleStep = 0x11
	ld a, $11
	ld [wTitleStep], a
;>     wLinkSendByte = 0xFE
	ld a, $fe
	ld [wLinkSendByte], a
	jp Jump_015_58e0


.notRefused
;> if wLinkReceivedLast != 1:
;>     return
	ld a, [wLinkReceivedLast]
	cp $01
	ret nz

;> wLinkSendLength = 0x64
	ld a, $64
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;> wLinkSendPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> PrintSystemText(0x0224)             # "The ceremony!"
	ld hl, $0224
	call PrintSystemText
	ret


;@ def BreedMakeOffspring()
;@ path: link/breed
;@ Breeding step 24: when the last exchange has ended ($F0), closes the link and makes the
;@ offspring: this side's parent is copied to wBreedParent1 (the partner's is in wBreedParent2)
;@ and leaves the farm, the egg is made (MakeOffspring in bank $16), the monster library flags
;@ and the monsters are saved, and the game goes to the field (map 8, the breeding ceremony)
;@ with the parents' names and the offspring's species name ready for its messages.
;@ test: skip touches battery RAM
BreedMakeOffspring::
;> if wLinkReceivedLast != 0xF0:
;>     return
	ld a, [wLinkReceivedLast]
	cp $f0
	ret nz

;> wLinkNoEnd = 0
	xor a
	ld [wLinkNoEnd], a
;> wGameMode = 1; wGameModeStep = 1     # the field
	ld hl, wGameMode
	ld a, $01
	ld [hli], a
	ld a, $01
	ld [hli], a
;> mem[0xC88C] = 0; mem[0xC88D] = 0
	ld a, $00
	ld [hli], a
	ld [hl], $00
;> wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]
;> wLinkMode = 0; wLinkPhase = 0
	ld a, $00
	ld [wLinkMode], a
	ld a, $00
	ld [wLinkPhase], a
;> wLinkFlags = 0
	xor a
	ld [wLinkFlags], a
;> wSerialLock = 0
	ld [wSerialLock], a
;> wLinkReceivedLast = 0
	xor a
	ld [wLinkReceivedLast], a
;> wLinkSendByte = 0
	xor a
	ld [wLinkSendByte], a
;> wLinkCommand = 0
	xor a
	ld [wLinkCommand], a
;> StartFade(0x04)
	ld a, $04
	call StartFade
;>@pick wCurPartyMember = wSceneObjects[wMenuChoice2 * 4 + (wMenuChoice & 0x7F)]
	ld a, [wMenuChoice2]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice]
	and $7f
;=@pick
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
;=@pick
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>@copy copy(wBreedParent1, MonsterField(wMonsters, wCurPartyMember), 0x95)
	ld hl, wMonsters
	call MonsterField
	ld de, wBreedParent1
	ld b, $95

.copy
;=@copy
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy

;> wEncGfx[0] = mem[MonsterField(wMonRecSpecies, wCurPartyMember)] + 0x10
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx], a
;> wEncGfx[1] = 1
	ld a, $01
	ld [wEncGfx + 1], a
;> mem[MonsterField(wMonsters, wCurPartyMember)] = 0      # the parent leaves the farm
	ld a, [wCurPartyMember]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;> wEncGfx[2] = mem[MonsterField(wMonRecSpecies, 0x15)] + 0x10   # the partner's monster
	ld a, $15
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	add $10
	ld [wEncGfx + 2], a
;> wEncGfx[3] = 1
	ld a, $01
	ld [wEncGfx + 3], a
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> Call_16_4015()                       # make the offspring egg
	ld hl, far_MakeOffspring
	rst $10
;> wLinkActive = 0
	xor a
	ld [wLinkActive], a
;> disable_interrupts()
	di
;> mem[0x0100] = 0x0A                   # battery RAM on
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld b, $20
	ld a, $0a
	ld [$0100], a

.saveFlags
;> copy(sLibraryFlags, wLibraryFlags, 0x20)
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .saveFlags

;> mem[0x0100] = 0x00                   # battery RAM off
	ld a, $00
	ld [$0100], a
;> SaveMonsters()
	call SaveMonsters
;> enable_interrupts()
	ei
;>@n0 CopyName(MonsterField(wMonName, 0x14), wTextArg0)     # this side's parent
	ld a, $14
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@n0
	ld hl, wTextArg0
	call CopyName
;>@n1 CopyName(MonsterField(wMonName, 0x15), wTextArg1)     # the partner's
	ld a, $15
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@n1
	ld hl, wTextArg1
	call CopyName
;>@sp CopySystemText(0x0500 + mem[MonsterField(wMonRecSpecies, wCurPartyMember)], wTextArg2)
	ld a, [wCurPartyMember]
	ld hl, wMonRecSpecies
	call MonsterField
	ld l, [hl]
	ld h, $05
	ld de, wTextArg2
;=@sp
	call CopySystemText
;> wMessageSpeed = 4
	ld a, $04
	ld [wMessageSpeed], a
;> wGameStarted = 0
	xor a
	ld [wGameStarted], a
;> wScriptRunning = 0
	xor a
	ld [wScriptRunning], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> wMapId = 8
	ld a, $08
	ld [wMapId], a
;> wPrevMapId = 8
	ld [wPrevMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;> wPrevOnGateFloor = 0
	ld [wPrevOnGateFloor], a
;> wPartyCount = 0
	ld a, $00
	ld [wPartyCount], a
;> wParty[0] = 0xFF
	ld a, $ff
	ld [wParty], a
;> wParty[1] = 0xFF
	ld a, $ff
	ld [wParty + 1], a
;> wParty[2] = 0xFF
	ld a, $ff
	ld [wParty + 2], a
	ret


;@ def BreedPartnerCancelled()
;@ path: link/breed
;@ Breeding step 25: one side cancelled (byte $FD); once the partner's $FD arrives, runs the
;@ last block exchange and goes to step 18 (back to the title).
;@ test: skip runs the link protocol
BreedPartnerCancelled::
;> if wLinkReceivedLast != 0xFD:
;>     return
	ld a, [wLinkReceivedLast]
	cp $fd
	ret nz

;> wLinkSendLength = 0x64
	ld a, $64
	ld [wLinkSendLength], a
	xor a
	ld [wLinkSendLength + 1], a
;> wLinkSendPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkSendPtr], a
	ld a, h
	ld [wLinkSendPtr + 1], a
;> wLinkRecvPtr = wSavedTilemap
	ld hl, wSavedTilemap
	ld a, l
	ld [wLinkRecvPtr], a
	ld a, h
	ld [wLinkRecvPtr + 1], a
;> wLinkSendByte = 0xFF
	ld a, $ff
	ld [wLinkSendByte], a
;> wTitleStep = 0x12
	ld a, $12
	ld [wTitleStep], a
;> wLinkNoEnd = 1
	ld a, $01
	ld [wLinkNoEnd], a
	ret


;@ def BreedCheckPartnerCancel()
;@ path: link/breed
;@ Checks whether the partner cancelled breeding (byte $FD). If so prints "Breeding refused.",
;@ answers $FD and goes to step 25, returning false (zero flag set); else returns true.
;@ test: skip prints text
BreedCheckPartnerCancel::
;> if wLinkReceivedLast != 0xFD:
;>     return True
	ld a, [wLinkReceivedLast]
	cp $fd
	ret nz

;> PrintSystemText(0x0222)             # "Breeding refused."
	ld hl, $0222
	call PrintSystemText
;> DrawWindowLayout_15(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_15
;> CopyTilemapBufferToVram_15()
	call CopyTilemapBufferToVram_15
;> wTitleStep = 0x19
	ld a, $19
	ld [wTitleStep], a
;> wLinkSendByte = 0xFD
	ld a, $fd
	ld [wLinkSendByte], a
;> return False
	xor a
	ret


;@ def BreedDrawStatusMonster()
;@ path: link/menu
;@ A copy of VSDrawStatusMonster: on page 5 of the monster status screen draws the monster's
;@ sprite at (144, 64), stepping between its two frames every 16 frames.
;@ test: skip calls routines in other banks
BreedDrawStatusMonster::
;> if wFieldMenuStep != 5:
;>     return
	ld a, [wFieldMenuStep]
	cp $05
	ret nz

;> species = mem[MonsterField(wMonRecSpecies, wCurPartyMember)]
	ld hl, wMonRecSpecies
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
	push af
;> hSpriteX = 0x0090
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0040
	ld a, $40
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@frame hSpriteFrame = (wFrameCounter >> 4) & 1
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame

	ld b, $01

.frame
;=@frame
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x50; hSpriteAttr = 0
	ld a, $50
	ld [hli], a
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def BreedDrawStatusParents()
;@ path: link/menu
;@ A copy of VSDrawStatusParents: on page 9 of the monster status screen draws the sprites of
;@ both parents at (144, 48) and (144, 120).
;@ test: skip calls routines in other banks
BreedDrawStatusParents::
;> if wFieldMenuStep != 9:
;>     return
	ld a, [wFieldMenuStep]
	cp $09
	ret nz

;> species = mem[MonsterField(wMonParent1, wCurPartyMember)]
	ld hl, wMonParent1
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
;> if species == 0xFF:
;>     return
	cp $ff
	ret z

;> hSpriteX = 0x0090
	push af
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0030
	ld a, $30
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@frame1 hSpriteFrame = (wFrameCounter >> 4) & 1
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame1

	ld b, $01

.frame1
;=@frame1
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x60; hSpriteAttr = 0
	ld a, $60
	ld [hli], a
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
;> species = mem[MonsterField(wMonParent2, wCurPartyMember)]
	ld hl, wMonParent2
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hl]
	push af
;> hSpriteX = 0x0090
	ld hl, hSpriteX
	ld a, $90
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x0078
	ld a, $78
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = species + 0x10
	pop af
	add $10
	ld [hli], a
;>@frame2 hSpriteFrame = (wFrameCounter >> 4) & 1
	ld b, $00
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame2

	ld b, $01

.frame2
;=@frame2
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0x70; hSpriteAttr = 0
	ld a, $70
	ld [hli], a
	ld a, $00
	ld [hl], a
;> DrawActorSpriteOnScreen()
	ld hl, far_DrawActorSpriteOnScreen
	rst $10
	ret


;@ def NextBgColumn_15(addr: hl) -> hl
;@ path: gfx/tilemap
;@ Moves a BG map address one column right, wrapping around within its 32-tile row.
;@ test: hl = rand(0x9800, 0x9BFF)
NextBgColumn_15::
;>@col return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@col
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@col
	ret


;@ def TitleBgAddr(offset: hl) -> hl
;@ path: gfx/tilemap
;@ BG map address of a screen offset: wTitleBgMap + `offset`, wrapped around within the 1 KiB
;@ BG map.
;@ test: hl = rand(0, 0x3FF)
;@ test: wTitleBgMap = rand(0x9800, 0x9BFF)
TitleBgAddr::
;> addr = wTitleBgMap + offset
	ld a, [wTitleBgMap]
	add l
	ld l, a
	ld a, [wTitleBgMap + 1]
	adc h
;>@g11 return (addr & 0x03FF) | (wTitleBgMap & 0xFC00)
	and $03
	ld h, a
	ld a, [wTitleBgMap + 1]
	and $fc
	or h
	ld h, a
;=@g11
	ret


;@ def TilemapBufferAddr_15(offset: hl) -> hl
;@ path: gfx/tilemap
;@ Address of a screen offset in wTilemapBuffer.
;@ test: hl = rand(0, 0x23F)
TilemapBufferAddr_15::
;>@g12 return wTilemapBuffer + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@g12
	ret


;@ def TitleBgAddrWrapped(offset: hl) -> hl
;@ path: gfx/tilemap
;@ BG map address of a screen offset (row * 32 + column), wrapping the column around within
;@ the BG map row as the screen is scrolled.
;@ test: hl = rand(0, 0x23F)
;@ test: wTitleBgMap = rand(0x9800, 0x9BFF)
TitleBgAddrWrapped::
;> addr = TitleBgAddr(offset & 0xFFE0)  # start of the row
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call TitleBgAddr
;> for i in range(offset & 0x1F):
	ld a, b
	and $1f
	jr z, .done

	ld b, a

.loop
;>     addr = NextBgColumn_15(addr)
	call NextBgColumn_15
	dec b
	jr nz, .loop

.done
;> return addr
	pop bc
	ret


;@ path: unused
;@ Code that nothing calls (a copy of the window drawer that writes straight into the BG map,
;@ as DrawWindowLayout_15 does into the tilemap buffer).
DrawLayoutToVram_15::
	db $1a, $6f, $13, $1a, $67, $13, $cd, $3c, $5d, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $10, $5d, $18, $d3

;@ def DrawWindowLayout_15(layout: de)
;@ path: gfx/tilemap
;@ Draws a window layout into wTilemapBuffer. Layout format: a u16 screen offset (row * 32 +
;@ column) where it starts, then tile numbers; $D8 starts the next row below the start, $D9
;@ ends.
;@ test: skip reads a layout from ROM
DrawWindowLayout_15::
;>@start row = p = TilemapBufferAddr_15(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@start
	call TilemapBufferAddr_15
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a

.loop
;> while (t := mem[layout]) != 0xD9:
;>     layout += 1
	ld a, [de]
	inc de
	cp $d9
	ret z

;>     if t == 0xD8:                    # next row
	cp $d8
	jr nz, .tile

;>@row         row += 32; p = row
	ldh a, [hNumber]
	ld l, a
	ldh a, [hNumber + 1]
	ld h, a
	ld a, l
	add $20
;=@row
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hNumber], a
;=@row
	ld a, h
	ldh [hNumber + 1], a
	jr .loop

;>     else:
;>         mem[p] = t; p += 1
.tile
	ld [hli], a
	jr .loop

;@ def CopyTilemapBufferToVram_15()
;@ path: gfx/tilemap
;@ Copies the 18 rows of 32 tiles of wTilemapBuffer to the BG map at wTitleBgMap (columns and
;@ rows wrap around within the BG map).
;@ test: skip writes VRAM
CopyTilemapBufferToVram_15::
;> addr = wTitleBgMap
	ld a, [wTitleBgMap]
	ld l, a
	ld a, [wTitleBgMap + 1]
	ld h, a
;> src = wTilemapBuffer
	ld de, wTilemapBuffer
;> for row in range(18):
	ld c, $12

.row
;>     p = addr
;>     for col in range(32):
	ld b, $20
	push hl

.col
;>@src         WriteVRAM(mem[src], p); src += 1
	ld a, [de]
	call WriteVRAM
;>@next         p = NextBgColumn_15(p)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@next
	ld l, a
	pop af
	or l
	ld l, a
;=@src
	inc de
	dec b
	jr nz, .col

;>@down     addr = ((addr + 32) & 0x03FF) | 0x9800
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@down
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .row

	ret


;@ path: unused
;@ Code that nothing calls (a text box printer that prints the current text into the tiles at
;@ hl, lines and line length in de).
DrawTextTiles_15::
	db $fa, $27, $c8, $4f, $fa, $28, $c8, $47, $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8
	db $47, $c5, $7d, $ea, $27, $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea
	db $2a, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27, $c8, $7c, $ea, $28, $c8
	db $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9

;@ def DrawNameTiles_15(name: de, tiles: hl)
;@ path: text/tiles
;@ Prints a 4-letter name into the 4 tiles at `tiles` (through wTextArg0 and text 0 of group 2,
;@ which prints it), keeping the text box settings.
;@ test: skip prints text
DrawNameTiles_15::
;> CopyName(name, wTextArg0)
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
;> saved_box = (wTextBoxLines, wTextBoxLineLength)
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
;> wTextBoxLines = 1; wTextBoxLineLength = 4
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextGroup = 2; wTextIndex = 0
	ld a, $02
	ld [wTextGroup], a
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
;> wTextBoxLines = saved_box[0]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_box[1]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def ClearTilemapBuffer_15()
;@ path: gfx/tilemap
;@ Fills the $240 bytes of wTilemapBuffer with the blank tile $E0.
ClearTilemapBuffer_15::
;>@fill fill(wTilemapBuffer, 0xE0, 0x240)
	ld hl, wTilemapBuffer
	ld bc, $0240

.loop
;=@fill
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop

;=@fill
	ret


;@ def ClearBgMap_15()
;@ path: gfx/tilemap
;@ Fills the BG map at $9800 (32 x 32 tiles) with the blank tile $E0.
;@ test: skip writes VRAM
ClearBgMap_15::
;> p = 0x9800
	ld hl, $9800
	ld bc, $0400

.loop
;> for i in range(0x400):
;>@g14     p = WriteVRAMInc(0xE0, p)
	ld a, $e0
	call WriteVRAMInc
	dec bc
	ld a, b
	or c
	jr nz, .loop

;=@g14
	ret


;@ path: unused
;@ Code that nothing calls: opens a menu screen (clears the menu variables, sets the BG map
;@ position from the scroll registers, clears the tilemap buffer and BG map, loads the window
;@ tiles from $2E0D and advances wTitleStep).
UnusedMenuOpen_15::
	db $21, $da, $c8, $01, $08, $00, $3e, $00, $cd, $c7, $12, $f0, $bb, $6f, $26, $00
	db $29, $29, $f0, $b7, $0f, $0f, $0f, $85, $6f, $7c, $ce, $98, $67, $7c, $e6, $03
	db $f6, $98, $67, $7d, $ea, $d6, $c8, $7c, $ea, $d7, $c8, $cd, $7c, $5e, $cd, $8b
	db $5e, $11, $0d, $2e, $21, $00, $90, $cd, $77, $15, $cd, $e3, $5f, $21, $d2, $c8
	db $34, $c9

;@ path: unused
;@ Code that nothing calls: closes such a menu screen again (clears the tilemap buffer and copies
;@ it to the BG map, reloads the field graphics and goes back to wTitleStep 0).
UnusedMenuClose_15::
	db $cd, $7c, $5e, $cd, $c0, $5d, $21, $01, $0b, $d7, $21, $02, $0b, $d7
	db $cd, $18, $25, $cd, $f1, $25, $21, $eb, $c8, $cb, $8e, $af, $ea, $d2, $c8, $c9

;@ def MovePagedListCursor_15(cur: hl, rows: b, count: c, marks: de)
;@ path: menu/cursor
;@ Cursor of a paged list of `count` entries, `rows` per page: cur[0] is the row (bit 7 set once
;@ chosen), cur[1] the page. Left and Right turn the page (wrapping around; on the shorter last
;@ page the row is pulled up), Up and Down move the row within the page (MoveMenuCursor_15),
;@ A chooses. `marks` is the list's cursor table: the page number position, then the rows.
;@ test: skip draws through helpers
MovePagedListCursor_15::
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> marks += 2                           # skip the page number position
	inc de
	inc de
;>@turn if not wTextState and wJoyRepeat & 0x30:     # Left or Right: turn the page
	ld a, [wTextState]
	or a
	jp nz, .noTurn

;>     if wJoyRepeat & 0x20:            # Left
	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .notLeft

;>         page = (cur[1] - 1) & 0xFF
	inc hl
	ld a, [hl]
	dec a
	push af
;>@pg1         pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@pg1
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>         if page >= pages:
;>             page = pages - 1         # wrap to the last page
	pop af
	cp c
	jr c, .setPage

	ld a, c
	dec a
	jr .setPage

.notLeft
;=@turn
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .noTurn

;>     else:                            # Right
;>         page = (cur[1] + 1) & 0xFF
	inc hl
	ld a, [hl]
	inc a
	push af
;>@pg2         pages = (count - 1) // rows + 1
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;=@pg2
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>         if page >= pages:
;>             page = 0                 # wrap to the first page
	pop af
	cp c
	jr c, .setPage

	ld a, $00

.setPage
;>     cur[1] = page
	ld [hld], a
;>     if page == pages - 1:            # the last page may be shorter
	dec c
	cp c
	jr nz, jr_015_5fab

;>@left         left = count % rows
	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
;=@left
	call Divide8
	pop bc
	pop de
;>         if left and cur[0] > left - 1:
	or a
	jr z, jr_015_5fab

	dec a
	cp [hl]
	jr nc, jr_015_5fab

;>             cur[0] = left - 1
	ld [hl], a
;>     wTitleBlink = 0; cur[0] |= 0x80 if wJoyPressed & 0x01 else 0   # the shared end of MoveMenuCursor_15
;>     return MenuDrawCursorMarks_15(cur[0], marks)
	jr jr_015_5fab

.noTurn
;>@lpn DrawListPageNumber_15(cur, rows, count, marks)
	push bc
	push de
	push hl
	call DrawListPageNumber_15
	pop hl
	pop de
;=@lpn
	pop bc
;>@lp last_page = (count - 1) // rows; left = (count - 1) % rows
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
;> wListLastRows = left                 # rows on the last page - 1
	ld [wListLastRows], a
;=@lp
	ld a, b
	pop bc
	pop de
	ld c, a
;> if cur[1] == last_page:
	inc hl
	ld a, [hld]
	cp c
	jr nz, MoveMenuCursor_15

;>     rows = wListLastRows + 1         # the rows on the last page
	ld a, [wListLastRows]
	inc a
;> return MoveMenuCursor_15(cur, rows, marks)   # runs on into it
	ld b, a

;@ def MoveMenuCursor_15(cur: hl, rows: b, marks: de)
;@ path: menu/cursor
;@ Moves a menu cursor (cur[0], bit 7 = chosen) with Up and Down through `rows` entries,
;@ wrapping around, sets bit 7 when A is pressed and draws the cursor marks.
;@ test: skip draws through helpers
MoveMenuCursor_15::
;> cur[0] &= 0x7F
	res 7, [hl]
;> if rows != 1:
	ld a, b
	cp $01
	jr z, jr_015_5fb3

;>     if wJoyRepeat & 0x40:            # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>         c = cur[0] - 1
;>         if c >= rows: c = rows - 1   # (also when it went below 0)
	ld a, [hl]
	dec a
	cp b
	jr c, .set

	dec b
	ld a, b
;>@set         cur[0] = c; wTitleBlink = 0
	jr .set

.notUp
;>     elif wJoyRepeat & 0x80:          # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_015_5fb3

;>         c = cur[0] + 1
;>         if c >= rows: c = 0
	ld a, [hl]
	inc a
	cp b
	jr c, .set

	ld a, $00

.set
;>@set2         cur[0] = c; wTitleBlink = 0
	ld [hl], a

jr_015_5fab:
;=@set2
	xor a
	ld [wTitleBlink], a
	push hl
	push de
	pop de
	pop hl

jr_015_5fb3:
;> if wJoyPressed & 0x01:             # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw

;>     cur[0] |= 0x80
	set 7, [hl]

.draw
;> MenuDrawCursorMarks_15(cur[0], marks)
	ld a, [hl]
	call MenuDrawCursorMarks_15
	ret


;@ path: unused
;@ Code that nothing reaches: a left/right variant of the cursor movement in MoveMenuCursor_15
;@ (Left moves to the previous entry, Right to the next, wrapping to 0), jumping back into it.
MoveMenuCursorSideways_15::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

;@ def MenuResetBlink_15()
;@ path: menu/cursor
;@ Restarts the cursor blink, so the cursor is drawn at once.
MenuResetBlink_15::
;> wTitleBlink = 0
	xor a
	ld [wTitleBlink], a
	ret


;@ def MenuDrawCursorMarks_15(cursor: a, marks: de) -> a
;@ path: menu/cursor
;@ Draws the mark of every entry of a cursor table (u16 screen offsets, $FFFF ends) into the
;@ BG map and wTilemapBuffer: the arrow $E8 at entry `cursor` (blinking: blank while
;@ wTitleBlink bit 4 is set), $E9 when chosen (bit 7), blank $E0 at the others. A cursor not
;@ chosen is only redrawn every 16 frames.
;@ test: skip writes VRAM
MenuDrawCursorMarks_15::
;> if not cursor & 0x80:
	ld c, a
	bit 7, a
	jr nz, .draw

;>     phase = wTitleBlink & 0x0F; wTitleBlink += 1
	ld a, [wTitleBlink]
	and $0f
	push af
	ld a, [wTitleBlink]
	inc a
	ld [wTitleBlink], a
;>     if phase:
;>         return cursor
	pop af
	ld a, c
	ret nz

.draw
;> i = 0
	ld c, a
	ld b, $00

.loop
;>@while while (pos := mem16[marks]) != 0xFFFF:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@while
	and l
	cp $ff
	ret z

;>@bg     bg = TitleBgAddrWrapped(pos); marks += 2
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@bg
	call TitleBgAddrWrapped
	pop bc
	pop de
;>     tile = 0xE0
;>     if i == cursor & 0x7F:
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .write

;>@sel         tile = 0xE9 if cursor & 0x80 else (0xE0 if wTitleBlink & 0x10 else 0xE8)
	ld a, $e9
	bit 7, c
	jr nz, .write

;=@sel
	ld a, [wTitleBlink]
	bit 4, a
	ld a, $e0
	jr nz, .write

;=@sel
	ld a, $e8

.write
;>     WriteVRAM(tile, bg)
	call WriteVRAM
;>@buf     mem[TilemapBufferAddr_15(pos)] = tile
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
;>     i += 1
	inc b
	jr .loop

;@ def DrawListPageNumber_15(cur: hl, rows: b, count: c, marks: de)
;@ path: menu/cursor
;@ When a list has more entries than one page holds, writes the page number (tile $F1 + page,
;@ cur[1]) just left of the page arrow, whose position is the word before `marks`, into the
;@ BG map and wTilemapBuffer.
;@ test: skip writes VRAM
DrawListPageNumber_15::
;> if rows >= count:
;>     return
	ld a, b
	cp c
	ret nc

;> page = cur[1]
	inc hl
	ld c, [hl]
;>@pos pos = mem16[marks - 2]
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
;>@digit WriteVRAM(0xF1 + (page & 0x7F), TitleBgAddrWrapped(pos))
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@digit
	call TitleBgAddrWrapped
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
;=@digit
	call WriteVRAM
;>@buf mem[TilemapBufferAddr_15(pos)] = 0xF1 + (page & 0x7F)
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


;@ def MenuDrawListCursor_15(cur: hl, marks: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws a paged list's cursor into wTilemapBuffer: at the table's first position the page
;@ arrow $E7 with the page number left of it when there are several pages (else the frame tile
;@ $EE), then the row cursor (MenuDrawCursorAt_15, run on into).
;@ test: skip draws through helpers
MenuDrawListCursor_15::
;> cursor = cur[0]; page = cur[1]
	ld a, [hli]
	push af
	push hl
;>@p p = TilemapBufferAddr_15(mem16[marks]); marks += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	ld h, a
;=@p
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;>@mark mem[p] = 0xE7 if rows < count else 0xEE
	ld a, b
	cp c
	ld a, $ee
	jr nc, .mark

	ld a, $e7

.mark
;=@mark
	ld [hld], a
;> if rows < count:
;>     mem[p - 1] = page + 0xF1
	pop bc
	jr nc, .one

	ld a, [bc]
	add $f1
	ld [hl], a

.one
;> MenuDrawCursorAt_15(cursor, marks)   # runs on into it
	pop af

;@ def MenuDrawCursorAt_15(cursor: a, marks: de)
;@ path: menu/cursor
;@ Writes the cursor mark of entry `cursor` of a cursor table into wTilemapBuffer: $E9 when
;@ chosen (bit 7), else the blinking arrow ($E8, blank $E0 while wTitleBlink bit 4 is set).
;@ test: skip reads a table from ROM
MenuDrawCursorAt_15::
;>@pos pos = mem16[marks + 2 * cursor]
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
;>@bg TitleBgAddrWrapped(pos)              # (the result is not used)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@bg
	call TitleBgAddrWrapped
	pop bc
	pop de
;>@sel tile = 0xE9 if cursor & 0x80 else (0xE0 if wTitleBlink & 0x10 else 0xE8)
	ld a, $e9
	bit 7, c
	jr nz, .write

;=@sel
	ld a, [wTitleBlink]
	bit 4, a
	ld a, $e0
	jr nz, .write

;=@sel
	ld a, $e8

.write
;>@buf mem[TilemapBufferAddr_15(pos)] = tile
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


;@ def CheckSaveChecksum()
;@ path: save/check
;@ Checks the battery RAM: when it holds no save, or its checksum (SRAMChecksum over
;@ $A002-$BFFF) does not match sChecksum, the whole save area is cleared and the checksum of
;@ the empty data is stored.
;@ test: skip touches battery RAM
CheckSaveChecksum::
;> mem[0x0100] = 0x0A; ok = False       # battery RAM on
	ld a, $0a
	ld [$0100], a
;> if sSaveValid:
	ld a, [sSaveValid]
	or a
	jr z, .clear

;>     sum = SRAMChecksum(sSaveValid, 0x1FFE)
	ld hl, sSaveValid
	ld bc, $1ffe
	call SRAMChecksum
;>     mem[0x0100] = 0x0A
	ld a, $0a
	ld [$0100], a
;>@same     ok = sChecksum == sum
	ld a, [sChecksum]
	ld l, a
	ld a, [sChecksum + 1]
	ld h, a
	ld a, l
	sub e
;=@same
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, h
	or l
;> if not ok:
	jr z, .done

.clear
;>     ZeroBytes_15(sSaveValid, 0x1FFE)  # no valid save: clear it
	ld hl, sSaveValid
	ld bc, $1ffe
	push hl
	push bc
	call ZeroBytes_15
;>     sum = SRAMChecksum(sSaveValid, 0x1FFE)
	pop bc
	pop hl
	call SRAMChecksum
;>     mem[0x0100] = 0x0A
	ld a, $0a
	ld [$0100], a
;>     sChecksum = sum
	ld a, e
	ld [sChecksum], a
	ld a, d
	ld [sChecksum + 1], a

.done
;> mem[0x0100] = 0x00                   # battery RAM off
	ld a, $00
	ld [$0100], a
	ret


;@ def ZeroBytes_15(dest: hl, count: bc)
;@ path: system/memory
;@ Clears `count` bytes from `dest` on.
;@ test: skip a count of 0 clears all 64 KiB
ZeroBytes_15::
;>@fill fill(dest, 0, count)
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
;=@fill
	jr nz, ZeroBytes_15

	ret


;@ def PrintTwoDigits_15(n: bc, dest: hl)
;@ path: text/numbers
;@ Writes `n` (0-99) as one or two digit tiles ($F0 + digit) at `dest` (through WriteVRAM, so
;@ VRAM or RAM); no leading zero.
;@ test: skip writes through WriteVRAM
PrintTwoDigits_15::
;> if n // 10:
	ld de, $000a
	push bc
	call DivideBCByDE_15
	pop bc
	or a
	jr z, .ones

;>     tens, n = DivideBCByDE_15(n, 10)
	ld de, $000a
	call DivideBCByDE_15
;>     WriteDigitTile_15(tens, dest)
	call WriteDigitTile_15
;>     dest = NextBgColumn2_15(dest)
	call NextBgColumn2_15

.ones
;> WriteDigitTile_15(n, dest)
	ld a, c
	call WriteDigitTile_15
	ret


;@ def DivideBCByDE_15(n: bc, d: de) -> (a, bc)
;@ path: system/math
;@ Divides `n` by `d` by repeated subtraction: returns the quotient (8-bit) and the remainder.
;@ test: bc = rand(0, 0x3FF)
;@ test: de = rand(1, 0x30)
DivideBCByDE_15::
;> q = -1
	push hl
	ld h, $ff

.loop
;> while True:
;>     q += 1
	inc h
;>@sub     n -= d
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
;=@sub
	ld b, a
;>     if n < 0:
;>         break
	jr nc, .loop

;> n += d                               # undo the last step
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
;> return q & 0xFF, n
	ld a, h
	pop hl
	ret


;@ def WriteDigitTile_15(digit: a, dest: hl)
;@ path: text/numbers
;@ Writes the digit tile $F0 + `digit` at `dest` through WriteVRAM.
;@ test: skip writes through WriteVRAM
WriteDigitTile_15::
;> WriteVRAM(0xF0 + digit, dest)
	add $f0
	call WriteVRAM
	ret


;@ def NextBgColumn2_15(addr: hl) -> hl
;@ path: gfx/tilemap
;@ A copy of NextBgColumn_15: one column right, wrapping around within the 32-tile row.
;@ test: hl = rand(0x9800, 0x9BFF)
NextBgColumn2_15::
;>@col return (addr & 0xFFE0) | ((addr + 1) & 0x1F)
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
;=@col
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
;=@col
	ret


;@ path: unused
;@ A 27 x 27 table of 0/1 flags (729 bytes) that no code reads.
BreedCompatibility::
	db $01, $01, $01, $01, $00, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $00, $01, $00, $01, $01, $01, $01, $00, $00, $00, $01, $01, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01
	db $01, $00, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00
	db $00, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01, $01, $00, $01, $00, $00
	db $01, $00, $00, $01, $00, $00, $01, $00, $01, $01, $00, $00, $00, $01, $01, $00
	db $00, $01, $01, $00, $00, $00, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01
	db $00, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00, $01, $01, $01, $01, $01
	db $00, $01, $01, $01, $01, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $00, $01, $01, $00, $01, $01, $00, $00, $00, $00, $01, $01, $01, $00
	db $00, $00, $00, $00, $01, $01, $00, $01, $01, $01, $01, $01, $00, $00, $00, $00
	db $00, $00, $01, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00, $00, $00, $01
	db $01, $00, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $00, $01, $00, $00
	db $01, $01, $01, $01, $01, $00, $01, $01, $00, $00, $01, $00, $01, $01, $01, $01
	db $01, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $01, $01, $00, $00, $01
	db $01, $00, $00, $00, $01, $01, $00, $01, $01, $01, $00, $00, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $00, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $01
	db $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $01, $01, $01, $01, $00, $00
	db $00, $01, $01, $01, $01, $01, $01, $01, $00, $00, $01, $01, $01, $00, $00, $01
	db $00, $00, $01, $00, $01, $01, $01, $01, $01, $00, $00, $00, $01, $00, $00, $01
	db $00, $01, $01, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $01, $00, $00
	db $01, $01, $00, $00, $00, $00, $00, $01, $00, $00, $01, $01, $01, $01, $00, $00
	db $00, $01, $01, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	db $00, $00, $01, $00, $01, $01, $01, $01, $01, $01, $00, $00, $01, $01, $00, $00
	db $01, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $00, $01, $00, $00
	db $01, $00, $00, $01, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $01, $01, $00, $01, $01, $01, $01, $00, $00, $01, $01, $01, $01, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $00
	db $00, $01, $00, $00, $01, $01, $01, $01, $01, $01, $00, $00, $01, $00, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $01, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $00, $01, $01, $00, $01, $01, $01, $01, $00, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $01, $00, $00, $00, $00, $00, $01, $01, $01, $01, $00, $01, $01, $01, $01
	db $00, $00, $00, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $01, $00, $01, $01, $00, $00, $00

;@ path: title/menu
;@ Window layout of the title menu without a save: NEW GAME in a framed box (layout format:
;@ tilemap-buffer offset, tile rows separated by $D8, $D9 at the end).
TitleWindowNoSave::
	db $00, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $31, $28, $3a, $e0, $2a, $24
	db $30, $28, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: title/menu
;@ Window layout of the title menu with a save: CONTINUE, NEW GAME, VS MODE and BREEDING.
;@ Three more layouts follow that nothing draws: a small box with tiles $00-$03 and two pages
;@ of a name-entry keyboard (letters, small letters and signs).
TitleWindowWithSave::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $26, $32, $31, $37, $2c, $31, $38, $28, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $31, $28, $3a
	db $e0, $2a, $24, $30, $28, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $39, $36, $e0, $30, $32, $27, $28, $e0, $e0
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $25, $35, $28, $28, $27, $2c, $31, $2a, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $26, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $00, $01, $02, $03, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $24, $25, $26, $27, $28, $e0, $3e, $3f, $40
	db $41, $42, $e0, $e0, $91, $92, $93, $94, $95, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $29, $2a, $2b, $2c, $2d, $e0, $43, $44, $45, $46, $47, $e0, $e0, $49, $4b
	db $4d, $8d, $8e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $2e, $2f, $30, $31, $32
	db $e0, $48, $e0, $4a, $e0, $4c, $e0, $e0, $60, $6a, $60, $70, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $33, $34, $35, $37, $38, $e0, $4e, $4f, $50, $51, $52
	db $e0, $e0, $47, $98, $50, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $39
	db $3a, $3b, $3c, $3d, $e0, $53, $54, $55, $36, $9c, $e0, $e0, $28, $53, $50, $e0
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38
	db $39, $3a, $e0, $25, $26, $27, $28, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $3b
	db $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $e0, $29, $2a, $2b
	db $2c, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $48, $49, $4a, $4b, $4c, $4d, $4e
	db $4f, $50, $51, $52, $53, $54, $e0, $2d, $24, $69, $6a, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d, $5e, $5f, $60, $61
	db $e0, $2f, $2e, $30, $38, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $62, $64, $65
	db $66, $67, $68, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $32, $3b, $31, $e0, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/breed
;@ The yes/no box of the breeding save question (YES / NO, the cursor at BreedSaveCursor).
BreedSaveYesNoWindow::
	db $0e, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: title/menu
;@ The save information window on CONTINUE: MASTER and the name, the party's three monster
;@ names with their levels.
SaveInfoWindow::
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $30, $24, $36, $37, $28, $35, $e4, $00, $01
	db $02, $03, $e0, $e0, $e0, $e4, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $da
	db $04, $05, $06, $07, $e0, $db, $08, $09, $0a, $0b, $e0, $dc, $0c, $0d, $0e, $0f
	db $ff, $d8, $fe, $e0, $65, $e4, $e0, $e0, $e0, $e0, $65, $e4, $e0, $e0, $e0, $e0
	db $65, $e4, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/menu
;@ The monster list window of the link modes: WHO, then four rows of names (tiles $10-$1F).
TitleListWindow::
	db $00, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $3a, $2b, $32, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $10, $11, $12, $13, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $14, $15, $16, $17, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $18, $19, $1a, $1b, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $1c, $1d, $1e, $1f, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: link/vs
;@ The VS team window: three numbered rows with the chosen monsters' names.
VSTeamWindow::
	db $cd, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $f1
	db $04, $05, $06, $07, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $f2
	db $08, $09, $0a, $0b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $f3
	db $0c, $0d, $0e, $0f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/menu
;@ The INFO / OK choice box of the link lists.
InfoOkWindow::
	db $0d, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $2c, $31, $29, $32, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $32, $2e, $e0, $e0, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/menu
;@ A YES / NO box of the link modes.
YesNoWindow_15::
	db $ae, $01, $fa, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $31, $32, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/vs
;@ The VS menu before the fight: FIGHT, PRIZE, EXIT.
VSReadyWindow::
	db $0b, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $29, $2c, $2a, $2b, $37
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $33
	db $35, $2c, $3d, $28, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $28, $3b, $2c, $37, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: link/breed
;@ The link breeding menu: BREED, CHECK, EXIT.
BreedMenuWindow::
	db $0b, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $25, $35, $28, $28, $27, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $26, $2b, $28, $26, $2e, $e0, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $28, $3b, $2c, $37, $e0
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/menu
;@ The name window of the link lists (the master's name, tiles $00-$03 and $20). The rest of the
;@ bank after it is data nothing refers to (it looks like left-over graphics).
TitleNameWindow::
	db $40, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $00
	db $01, $02, $03, $20, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9, $3f, $31, $3f, $8f, $ff, $8c, $fc, $8c, $fc, $8f, $ff, $8c, $fc
	db $8c, $fc, $8f, $8f, $ff, $ff, $fb, $ff, $04, $07, $03, $03, $ff, $ff, $04, $00
	db $04, $ff, $88, $df, $ff, $20, $e0, $c0, $c0, $ff, $ff, $04, $00, $04, $ff, $8e
	db $f1, $ff, $31, $3f, $31, $3f, $f1, $ff, $31, $3f, $31, $3f, $f1, $f1, $05, $ff
	db $99, $88, $fb, $8c, $88, $fb, $8f, $ff, $8c, $fc, $8c, $fc, $8f, $ff, $8c, $fc
	db $8c, $fc, $8f, $ff, $8c, $fc, $8c, $fc, $8f, $8f, $07, $ff, $84, $00, $ff, $00
	db $00, $03, $ff, $8d, $00, $00, $03, $03, $ff, $fe, $03, $02, $02, $03, $fe, $ff
	db $02, $03, $03, $09, $ff, $84, $00, $ff, $00, $00, $03, $ff, $8d, $00, $00, $c0
	db $c0, $ff, $7f, $c0, $40, $40, $c0, $7f, $ff, $40, $03, $c0, $09, $ff, $99, $11
	db $df, $31, $11, $df, $f1, $ff, $31, $3f, $31, $3f, $f1, $ff, $31, $3f, $31, $3f
	db $f1, $ff, $31, $3f, $31, $3f, $f1, $f1, $04, $ff, $10, $00, $8c, $ff, $00, $ff
	db $00, $ff, $00, $ff, $ff, $80, $ff, $80, $80, $04, $9f, $10, $00, $8c, $ff, $03
	db $fe, $03, $fe, $03, $ff, $ff, $00, $ff, $00, $00, $04, $ff, $10, $00, $8c, $ff
	db $c0, $7f, $c0, $7f, $c0, $ff, $ff, $00, $ff, $00, $00, $04, $ff, $10, $00, $8c
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $01, $ff, $01, $01, $04, $f9, $0e, $9f
	db $8e, $bf, $bf, $9f, $9f, $df, $df, $9f, $9f, $bf, $bf, $df, $df, $bf, $bf, $44
	db $ff, $0e, $f9, $8e, $fd, $fd, $f9, $f9, $fb, $fb, $f9, $f9, $fd, $fd, $fb, $fb
	db $fd, $fd, $04, $ff, $9e, $03, $01, $07, $02, $07, $02, $07, $02, $0d, $06, $7d
	db $0e, $f3, $7c, $ff, $80, $f3, $7c, $7d, $0e, $0d, $06, $07, $02, $07, $02, $07
	db $02, $03, $01, $08, $00, $91, $1c, $00, $1f, $0c, $1f, $0b, $0e, $05, $0d, $06
	db $0e, $05, $1f, $0b, $1f, $0c, $1c, $11, $00, $93, $1c, $00, $3f, $1c, $3b, $17
	db $1f, $08, $0f, $04, $07, $02, $0d, $06, $0f, $05, $07, $02, $02, $05, $00, $10
	db $ff, $11, $00, $b0, $ff, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $00, $0f, $ff, $98, $00, $ff, $7f, $80, $7f, $80, $7f, $80, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $08
	db $ff, $ff, $00, $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80
	db $ff, $80, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $ff, $80, $ff, $80
	db $ff, $80, $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $bc, $cf, $bd, $ce
	db $bd, $ce, $ff, $ff, $01, $ff, $ff, $01, $ff, $f1, $f7, $f9, $37, $f9, $f7, $39
	db $f7, $39, $ff, $ff, $80, $ff, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0
	db $bf, $c0, $ff, $ff, $01, $ff, $ff, $01, $ff, $31, $f7, $39, $f7, $39, $f7, $39
	db $f7, $39, $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0
	db $bf, $cf, $ff, $ff, $01, $ff, $ff, $01, $ff, $f1, $f7, $f9, $37, $f9, $f7, $39
	db $f7, $d0, $f9, $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf
	db $c0, $bf, $c3, $f7, $39, $f7, $39, $f7, $39, $f7, $39, $f7, $39, $e7, $19, $ff
	db $01, $ff, $ff, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $11, $ff, $90, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $09, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $bd
	db $ce, $bd, $ce, $bd, $ce, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $ff, $ff, $f7
	db $39, $f7, $39, $f7, $39, $f7, $f9, $f7, $f9, $07, $f9, $ff, $01, $ff, $ff, $bf
	db $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $ff, $ff, $f7
	db $39, $f7, $39, $f7, $39, $f7, $39, $f7, $39, $e7, $19, $ff, $01, $ff, $ff, $bf
	db $cf, $bc, $cf, $bd, $ce, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $ff, $ff, $f7
	db $f9, $07, $f9, $ff, $01, $ff, $f1, $a6, $f7, $f9, $07, $f9, $ff, $01, $ff, $ff
	db $bf, $c3, $be, $c1, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $ff, $ff
	db $f7, $f9, $37, $f9, $f7, $39, $f7, $f9, $f7, $f9, $07, $f9, $ff, $01, $04, $ff
	db $ff, $80, $ff, $bf, $c0, $bf, $cc, $bd, $ce, $bd, $ce, $bd, $ce, $bf, $cf, $ff
	db $ff, $01, $ff, $ff, $01, $ff, $31, $f7, $39, $f7, $39, $f7, $39, $f7, $f9, $ff
	db $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $bc, $cf, $bd, $ce, $bf, $cf, $ff
	db $ff, $01, $ff, $ff, $01, $ff, $f1, $f7, $f9, $07, $f9, $ff, $01, $ff, $f1, $ff
	db $38, $c7, $7d, $92, $ff, $9e, $ff, $9e, $ff, $92, $ff, $c7, $7d, $ff, $38, $ff
	db $ef, $18, $ff, $4c, $ff, $4c, $ff, $4c, $ff, $4c, $ff, $18, $ff, $ff, $ef, $ff
	db $f7, $4d, $ff, $c5, $ff, $c5, $ff, $c9, $ff, $c9, $ff, $4d, $ff, $ff, $fb, $ff
	db $00, $ff, $00, $ff, $0f, $fc, $13, $f0, $2c, $e3, $3b, $e7, $34, $e7, $34, $ff
	db $89, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $03, $ff, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $f0, $0f, $f8, $07, $fc, $c7, $f4, $e7, $34, $e7, $34
	db $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34, $e7, $34
	db $e7, $34, $e7, $34, $e3, $3b, $e0, $2f, $f0, $10, $ff, $0f, $ff, $00, $ff, $00
	db $e7, $34, $e7, $34, $e7, $d4, $07, $f4, $0f, $08, $ff, $f0, $ff, $00, $ff, $00
	db $e5, $8b, $a5, $d3, $a5, $d3, $c9, $a5, $d1, $8b, $a1, $d3, $a1, $cd, $e9, $85
	db $38, $b8, $10, $f0, $00, $ff, $01, $be, $02, $bd, $12, $2d, $2a, $95, $06, $39
	db $0c, $2d, $00, $12, $8c, $73, $08, $f7, $00, $ff, $43, $bc, $0b, $f4, $16, $e9
	db $bf, $cf, $b8, $c7, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $a2, $bf, $c0, $ff
	db $ff, $f7, $f9, $37, $f9, $f7, $39, $f7, $39, $f7, $39, $e7, $19, $ff, $01, $ff
	db $ff, $bf, $cf, $b8, $c7, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $04
	db $ff, $ff, $80, $ff, $bf, $c0, $bf, $cf, $bf, $cf, $b8, $c7, $bf, $c0, $bf, $c0
	db $ff, $00, $ff, $01, $ff, $01, $ff, $01, $ff, $19, $e7, $34, $c3, $7a, $81, $fd
	db $ff, $00, $ff, $e0, $1f, $d8, $07, $f4, $e3, $fa, $f3, $1e, $f9, $0d, $f9, $0f
	db $e7, $ff, $e7, $2c, $f3, $1e, $f1, $17, $f8, $0b, $fe, $06, $ff, $01, $ff, $00
	db $f9, $0f, $f9, $0d, $f3, $1e, $e3, $fa, $07, $f4, $1f, $d8, $ff, $e0, $ff, $00
	db $38, $38, $74, $4c, $ea, $96, $ea, $96, $ea, $96, $ea, $96, $74, $4c, $38, $38
	db $ff, $42, $bd, $e7, $db, $7e, $e7, $3c, $e7, $3c, $db, $7e, $bd, $e7, $ff, $42
	db $ff, $fe, $83, $fe, $9f, $fc, $83, $fa, $f3, $7e, $f3, $7e, $83, $fa, $ff, $fc
	db $ff, $9d, $7c, $83, $ba, $93, $fe, $93, $fe, $93, $fe, $93, $fe, $83, $ba, $ff
	db $7c, $ff, $ff, $99, $66, $e7, $08, $10, $26, $88, $51, $07, $c8, $00, $37, $04
	db $ff, $ff, $fd, $83, $c5, $81, $c5, $99, $cd, $91, $fd, $81, $81, $c1, $ff, $ff
	db $1e, $a1, $3c, $c3, $3e, $41, $bb, $87, $b7, $cf, $2f, $5e, $3c, $5f, $1b, $ff
	db $4f, $b0, $ff, $00, $fb, $fc, $fd, $fe, $7e, $87, $5f, $e3, $fe, $81, $af, $50
	db $07, $87, $00, $0b, $87, $78, $0c, $f3, $08, $f7, $20, $df, $05, $fa, $03, $fc
	db $00, $ed, $03, $c7, $29, $d7, $92, $6d, $27, $d8, $57, $a8, $cf, $30, $af, $51
	db $1c, $5f, $00, $ef, $eb, $97, $ff, $8f, $fe, $1d, $f7, $38, $ff, $66, $7f, $8c
	db $20, $a2, $00, $81, $6b, $97, $b6, $cf, $de, $ed, $fe, $61, $bf, $70, $ff, $76
	db $07, $c7, $00, $84, $91, $6e, $00, $ff, $43, $bc, $cb, $37, $b7, $4f, $4e, $bf
	db $10, $ff, $9a, $00, $b1, $62, $9d, $d5, $2b, $c7, $3b, $df, $e7, $ee, $ff, $ff
	db $7c, $00, $ff, $3e, $be, $ff, $ff, $ed, $f3, $bf, $c0, $ef, $10, $bf, $60, $7f
	db $c0, $30, $b7, $01, $ee, $bf, $c1, $ff, $e1, $7e, $f1, $b7, $78, $dd, $3b, $ea
	db $1d, $1e, $ff, $27, $db, $3f, $c6, $3b, $c5, $3f, $c3, $3f, $c0, $3f, $c0, $3f
	db $41, $ff, $a0, $df, $60, $bf, $c0, $ff, $80, $ff, $00, $ff, $00, $6f, $90, $7f
	db $90, $cf, $3d, $fd, $02, $ff, $04, $fe, $01, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $fd, $63, $5b, $e7, $be, $c7, $f5, $0e, $ff, $0c, $ed, $1f, $fb, $1f, $dd
	db $3e, $b5, $ce, $7e, $87, $fb, $07, $fb, $07, $ff, $c3, $bf, $c3, $7d, $a3, $ff
	db $c0, $ff, $7b, $e7, $ff, $f3, $dd, $e3, $f3, $bd, $7e, $e9, $9f, $f0, $7f, $e0
	db $f7, $c8, $bf, $7f, $6b, $f7, $dd, $e3, $bf, $d1, $d6, $e9, $6f, $d8, $df, $b0
	db $bb, $64, $bf, $7e, $76, $ff, $ff, $e3, $dd, $f3, $ff, $e1, $6e, $d9, $7f, $b0
	db $f7, $6c, $4f, $b0, $fd, $03, $f7, $0f, $ef, $1e, $df, $3c, $fb, $3d, $fe, $fb
	db $77, $fe, $ff, $03, $f6, $f9, $5f, $b8, $ff, $0c, $f7, $8e, $7d, $82, $ef, $10
	db $fe, $a1, $fa, $1d, $ff, $1f, $f7, $0f, $ff, $00, $ff, $03, $b7, $79, $7b, $fc
	db $cf, $fc, $ff, $e0, $ff, $c0, $bf, $c0, $f7, $38, $fb, $1d, $7f, $81, $ed, $1f
	db $be, $7f, $ff, $1c, $db, $3f, $f7, $3c, $ba, $7f, $fd, $7e, $df, $6c, $f7, $18
	db $dd, $ff, $3e, $79, $bf, $ff, $1b, $ff, $3e, $fd, $3b, $a7, $7e, $ff, $6d, $ad
	db $5b, $f3, $1e, $ff, $80, $af, $50, $df, $b0, $bf, $60, $f7, $c8, $ff, $90, $bf
	db $61, $7f, $c3, $ef, $1c, $ff, $0c, $ff, $0c, $f5, $0e, $ff, $06, $ff, $06, $bf
	db $c6, $fb, $c6, $3d, $43, $3f, $c3, $3b, $c7, $3e, $47, $be, $c7, $bf, $87, $3b
	db $47, $bf, $c3, $df, $30, $57, $b8, $9f, $78, $3f, $d8, $9e, $7f, $2f, $df, $5e
	db $bf, $f9, $fe, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $01, $f3, $3d, $f6, $3b, $db, $3c, $ed, $1f, $f7, $0f, $fc, $03, $fd
	db $03, $bf, $c7, $be, $c1, $fd, $43, $b7, $cf, $6f, $9f, $fe, $ff, $e7, $ff, $db
	db $e6, $89, $dd, $e2, $df, $30, $ff, $60, $bb, $cc, $9e, $03, $ff, $ff, $79, $ff
	db $df, $3c, $bb, $7c, $6f, $d8, $f7, $38, $6f, $f8, $3e, $ff, $ef, $ff, $cd, $ff
	db $ff, $1c, $f6, $0f, $af, $58, $de, $31, $b1, $7f, $3f, $ff, $ff, $fe, $db, $fc
	db $bf, $78, $d5, $3e, $3f, $c7, $f7, $0f, $7f, $8f, $ef, $9f, $bf, $cf, $ef, $df
	db $d8, $e7, $5f, $e0, $df, $e2, $ff, $e2, $fc, $e3, $ff, $e1, $dd, $e3, $df, $e1
	db $1e, $e1, $ff, $00, $bd, $c3, $3f, $47, $3e, $cf, $37, $d8, $1f, $e0, $39, $c6
	db $3b, $c7, $3f, $c3, $ef, $ff, $bb, $c7, $6f, $f0, $77, $f8, $db, $3c, $d7, $2e
	db $7d, $83, $de, $e1, $7f, $83, $db, $e7, $b7, $7f, $ff, $0f, $fd, $1f, $df, $3c
	db $fc, $3b, $30, $ff, $fd, $c3, $bf, $c0, $7f, $80, $7f, $80, $bf, $9d, $c0, $ff
	db $c0, $df, $60, $7f, $e0, $7f, $a0, $ff, $00, $ff, $00, $fe, $01, $fb, $07, $f7
	db $0f, $ee, $1f, $fd, $1e, $ef, $18, $ff, $00, $ff, $00, $04, $ff, $ff, $8d, $f3
	db $d1, $2e, $80, $7f, $fb, $04, $ff, $00, $ff, $00, $bf, $c0, $f7, $f8, $fd, $fe
	db $3f, $ff, $e7, $1f, $ef, $10, $ff, $00, $ff, $00, $ff, $00, $f3, $0f, $df, $3f
	db $fd, $fe, $cb, $f4, $fb, $07, $ef, $1f, $dd, $3e, $bb, $7c, $fe, $f9, $fd, $f2
	db $6b, $f5, $fd, $03, $fb, $fc, $47, $be, $08, $f7, $17, $e8, $b7, $78, $ff, $fc
	db $b1, $ce, $7f, $80, $37, $cf, $3d, $cf, $3f, $df, $36, $fb, $25, $bf, $4b, $fd
	db $0e, $b3, $3f, $47, $7b, $87, $ff, $81, $7f, $a0, $cf, $78, $9f, $f0, $ff, $a0
	db $bf, $40, $df, $e0, $ff, $c1, $df, $e0, $ef, $f0, $7f, $f0, $ff, $78, $f7, $38
	db $cf, $30, $ff, $00, $d0, $ef, $fc, $fb, $bf, $7f, $e7, $1f, $fd, $ff, $03, $ff
	db $00, $fb, $07, $f7, $0f, $5f, $e0, $df, $e0, $ff, $c0, $bf, $c0, $ff, $00, $ff
	db $00, $ff, $00, $fe, $01, $ff, $00, $ff, $00, $fe, $01, $ff, $01, $fd, $03, $fe
	db $01, $ff, $00, $ef, $f0, $3e, $c1, $3f, $40, $bf, $c0, $bf, $80, $bf, $c0, $3f
	db $40, $3f, $c1, $3f, $43, $f7, $f8, $ef, $1c, $fc, $03, $fe, $01, $fd, $02, $7b
	db $fc, $ff, $ff, $cf, $ff, $7c, $fb, $dd, $fe, $ec, $9f, $f7, $0e, $fe, $07, $ff
	db $07, $fb, $07, $bf, $c3, $ff, $20, $37, $f8, $9b, $7c, $3f, $df, $07, $ff, $8d
	db $73, $42, $bd, $81, $fe, $ff, $1c, $fd, $1e, $ee, $1f, $77, $8f, $ff, $ff, $fe
	db $ff, $d0, $2f, $42, $bd, $83, $7c, $56, $a9, $fc, $03, $f8, $07, $e9, $b0, $cf
	db $e2, $1d, $00, $ff, $39, $c6, $87, $78, $07, $f8, $2b, $d4, $ab, $54, $12, $ed
	db $85, $7a, $a4, $5b, $8c, $73, $d0, $2f, $40, $bf, $92, $6d, $2a, $d5, $9a, $65
	db $30, $cf, $50, $af, $e2, $1d, $ff, $03, $d2, $2f, $ee, $17, $ce, $37, $ab, $57
	db $0d, $f3, $b5, $4b, $3f, $c3, $ff, $00, $fe, $01, $7f, $80, $7f, $80, $78, $87
	db $ff, $81, $fd, $83, $7e, $81, $3b, $cf, $37, $cb, $3d, $c3, $3f, $c1, $3e, $41
	db $3f, $00, $bf, $80, $bf, $c0, $f4, $fb, $7f, $bf, $ef, $9f, $bb, $d6, $d7, $ec
	db $ed, $fb, $7b, $ff, $ff, $77, $fe, $03, $ff, $9c, $7d, $83, $b6, $69, $6f, $d0
	db $fd, $e3, $eb, $f7, $ff, $f7, $fd, $0e, $9b, $fc, $fe, $f1, $ff, $e1, $fd, $03
	db $df, $e3, $fb, $e7, $ee, $f7, $00, $ff, $00, $ff, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $ff, $0f, $fc, $ff, $fc, $ff, $fc, $ff, $fc
	db $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc
	db $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $00, $ff, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8
	db $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $cf, $f8, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f
	db $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $ff, $0f, $00, $1f, $1f, $3f, $2f, $70
	db $5f, $e0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0
	db $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $07, $fc, $ff, $fc, $ff, $00
	db $ff, $00, $e7, $18, $db, $3c, $bd, $7e, $66, $ff, $66, $ff, $7e, $ff, $66, $ff
	db $18, $e7, $ef, $10, $97, $78, $7b, $a4, $fc, $a7, $78, $e0, $3f, $ff, $3f, $ff
	db $00, $ff, $00, $d5, $3f, $15, $ff, $fe, $ff, $11, $fe, $93, $7c, $55, $fe, $52
	db $ff, $92, $ff, $c7, $38, $bb, $7c, $c3, $3c, $9d, $7e, $00, $04, $ff, $9c, $00
	db $ff, $00, $81, $7e, $7e, $ff, $42, $ff, $82, $ff, $3d, $fe, $c5, $3e, $cb, $3c
	db $b7, $78, $ff, $00, $ff, $18, $ff, $38, $df, $38, $00, $04, $ff, $9c, $00, $ff
	db $00, $1f, $e0, $ed, $f2, $1a, $e7, $fa, $07, $fa, $07, $f5, $0e, $0b, $fc, $f7
	db $f8, $c3, $3c, $bd, $7e, $cb, $3c, $bd, $7e, $00, $04, $ff, $9c, $00, $ff, $00
	db $f5, $0f, $c0, $3f, $3e, $ff, $c9, $fe, $17, $f8, $d7, $38, $e9, $1e, $f6, $0f
	db $ff, $00, $b3, $4c, $55, $ee, $5a, $e7, $00, $04, $ff, $9c, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f7
	db $08, $ab, $5c, $5d, $fe, $6a, $ff, $00, $04, $ff, $9c, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fb, $04
	db $f5, $0e, $eb, $1c, $d7, $38, $00, $04, $ff, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $83, $7c, $7d
	db $fe, $8b, $7c, $9d, $7e, $00, $f8, $f8, $fc, $f4, $0e, $fa, $07, $fe, $03, $fe
	db $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe
	db $03, $fe, $03, $fe, $03, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f
	db $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $5f, $e0, $2f
	db $70, $1f, $3f, $00, $1f, $79, $fe, $aa, $77, $a2, $7f, $dd, $3e, $ff, $00, $c3
	db $3c, $bd, $7e, $c2, $3f, $f5, $0e, $bb, $44, $41, $fe, $be, $7f, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $62, $ff, $9a, $67, $ff, $c5, $3e, $bb, $7c, $bf, $40
	db $5d, $e2, $52, $ef, $ad, $7e, $b3, $7c, $4f, $f0, $41, $fe, $be, $7f, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $ff, $18, $ff, $18, $ff, $18, $bd, $7e, $f5, $0f
	db $da, $25, $25, $fe, $f2, $ff, $2a, $ff, $49, $fe, $8b, $fc, $37, $f8, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $cb, $3c, $bb, $7c, $4d, $fe, $b3, $7c, $f5, $0f
	db $c0, $3f, $3e, $ff, $c9, $fe, $17, $f8, $d7, $38, $e9, $1e, $f6, $0f, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $5a, $e7, $42, $ff, $55, $fa, $af, $70, $ef, $10
	db $97, $78, $7d, $fe, $89, $7e, $be, $7f, $85, $7e, $43, $fc, $bd, $7e, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $d2, $ff, $b2, $ff, $ff, $aa, $f7, $d5, $6e, $c3
	db $3c, $bd, $7e, $cb, $3c, $bd, $7e, $cb, $3c, $bb, $7c, $4d, $fe, $b3, $7c, $ff
	db $00, $ff, $00, $ff, $ff, $00, $ff, $af, $70, $d7, $38, $eb, $1c, $f5, $0e, $f7
	db $08, $89, $7e, $7e, $ff, $89, $7e, $bb, $7c, $ab, $7c, $9b, $7c, $77, $f8, $ff
	db $00, $ff, $00, $ff, $ff, $00, $ff, $62, $ff, $9a, $ff, $2a, $ff, $dd, $3e, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $ff, $00, $ff, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe
	db $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fa
	db $07, $f4, $0e, $f8, $fc, $00, $f8, $00, $1f, $9f, $1f, $3f, $2f, $70, $5f, $e0
	db $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0
	db $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $00, $04, $ff, $9c, $00, $ff, $00, $03
	db $fc, $fd, $fe, $c3, $fc, $fd, $fe, $06, $ff, $fe, $07, $86, $ff, $7d, $fe, $ea
	db $17, $d5, $3f, $aa, $5f, $55, $ee, $00, $04, $ff, $9c, $00, $ff, $00, $c7, $38
	db $bb, $7c, $4d, $fe, $d7, $ee, $d7, $ee, $d7, $ee, $65, $fe, $bb, $7c, $11, $fe
	db $fe, $ff, $02, $ff, $e5, $1e, $00, $04, $ff, $9c, $00, $ff, $00, $81, $7e, $7e
	db $ff, $82, $7f, $fa, $07, $fa, $07, $fa, $07, $82, $7f, $7e, $ff, $d7, $38, $97
	db $78, $57, $f8, $55, $fa, $00, $04, $ff, $9c, $00, $ff, $00, $fa, $07, $f5, $0e
	db $cb, $3c, $37, $f8, $cb, $fc, $2b, $dc, $eb, $1c, $eb, $1c, $f5, $0f, $da, $25
	db $25, $fe, $f2, $ff, $00, $04, $ff, $9c, $00, $ff, $00, $1f, $e0, $ed, $f2, $1a
	db $e7, $fa, $07, $fa, $07, $f5, $0e, $0b, $fc, $f7, $f8, $e7, $18, $db, $3c, $bb
	db $7c, $db, $3c, $00, $04, $ff, $ff, $00, $ff, $00, $f5, $0f, $c2, $3d, $bd, $7e
	db $c2, $3f, $f5, $0e, $bb, $44, $41, $fe, $be, $7f, $c3, $3c, $bd, $7e, $cb, $3c
	db $bd, $7e, $07, $fc, $ff, $fc, $ff, $00, $ff, $00, $bf, $40, $5d, $e2, $52, $ef
	db $ad, $7e, $b3, $7c, $4f, $f0, $41, $fe, $be, $7f, $ff, $00, $b3, $4c, $55, $ee
	db $5a, $e7, $e0, $3f, $ff, $3f, $ff, $00, $ff, $00, $ff, $00, $a1, $5e, $5e, $ff
	db $41, $fe, $5f, $e0, $47, $f8, $49, $fe, $b6, $6f, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $00, $f8, $f8, $fc, $f4, $0e, $fa, $07, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $7f, $c0, $7f, $c0, $fc, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f
	db $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $7f, $c0, $5f, $e0, $2f, $70, $1f
	db $3f, $00, $1f, $55, $ee, $ba, $c7, $ba, $c7, $7a, $87, $f7, $08, $ab, $5c, $5d
	db $fe, $6a, $ff, $d2, $ff, $b2, $ff, $aa, $f7, $d5, $6e, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $db, $3c, $35, $fe, $d2, $ff, $15, $fa, $fb, $04, $f5, $0e, $eb
	db $1c, $d7, $38, $af, $70, $d7, $38, $eb, $1c, $f5, $0e, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $52, $ff, $52, $ff, $55, $fe, $9b, $fc, $c7, $38, $bb, $7c, $c3
	db $3c, $ad, $7e, $52, $ff, $6a, $f7, $82, $7f, $dd, $3e, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $10, $00, $90, $ff, $ff, $eb, $9c, $cc, $bf, $cf, $bf, $c8, $b8
	db $bf, $ff, $bf, $e0, $b0, $ef, $10, $00, $03, $c3, $82, $00, $00, $03, $c3, $82
	db $00, $00, $03, $ff, $9b, $00, $00, $ff, $b0, $ef, $a0, $ff, $e0, $ff, $20, $3f
	db $20, $3f, $20, $3f, $20, $3f, $10, $1f, $08, $0f, $04, $07, $02, $03, $01, $01
	db $08, $00, $8d, $ff, $ff, $db, $a5, $bd, $c3, $bd, $db, $bd, $db, $bd, $c3, $a5
	db $05, $ff, $83, $00, $ff, $00, $03, $ff, $08, $00, $03, $ff, $da, $81, $ff, $81
	db $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81
	db $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $3f, $3f, $3d, $27, $3d, $27
	db $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3d, $27
	db $3d, $27, $3d, $27, $3d, $27, $3d, $27, $3f, $3f, $38, $38, $28, $38, $28, $38
	db $28, $38, $28, $38, $28, $38, $28, $38, $28, $38, $28, $38, $28, $38, $28, $38
	db $28, $38, $28, $38, $28, $38, $28, $03, $38, $9e, $00, $00, $01, $01, $07, $06
	db $0f, $08, $1a, $17, $17, $1c, $1f, $18, $17, $1b, $1e, $13, $3f, $20, $7f, $40
	db $ff, $86, $f4, $8f, $6b, $5b, $30, $30, $04, $00, $ff, $fc, $fc, $aa, $76, $f5
	db $1b, $ff, $01, $ff, $01, $fd, $e7, $de, $e2, $ef, $59, $ff, $79, $fd, $13, $fa
	db $36, $7c, $a4, $08, $f8, $f0, $f0, $00, $00, $2a, $ff, $49, $fe, $8b, $fc, $37
	db $f8, $f3, $0c, $ad, $5e, $55, $fe, $d5, $fe, $65, $fe, $55, $ee, $d5, $ee, $5a
	db $e7, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $db, $3c, $db, $3c, $db, $3c, $bd
	db $7e, $c3, $3c, $bd, $7e, $cb, $3c, $bd, $7e, $cb, $3c, $bb, $7c, $4d, $fe, $b3
	db $7c, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $cb, $3c, $bb, $7c, $4d, $fe, $b3
	db $7c, $f7, $08, $89, $7e, $7e, $ff, $89, $7e, $bb, $7c, $ab, $7c, $9b, $7c, $77
	db $f8, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $5a, $ff, $e7, $42, $ff, $55, $fa
	db $af, $70, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $03
	db $fe, $03, $fa, $07, $f4, $0e, $f8, $fc, $00, $f8, $00, $1f, $1f, $3f, $2f, $70
	db $5f, $e0, $7f, $c0, $7b, $c4, $74, $cf, $7d, $cf, $76, $cf, $75, $ce, $7d, $ce
	db $74, $cf, $78, $c7, $77, $cf, $76, $cf, $77, $cf, $81, $00, $04, $ff, $9c, $00
	db $ff, $00, $ff, $00, $3c, $c3, $d2, $ef, $2f, $ff, $a4, $7f, $a4, $7f, $2a, $fd
	db $d3, $ef, $1d, $e3, $c1, $ff, $6f, $ff, $c1, $ff, $00, $04, $ff, $9c, $00, $ff
	db $00, $7f, $80, $bf, $c0, $5f, $e0, $2e, $f1, $a9, $f7, $96, $ef, $b8, $c7, $7d
	db $83, $58, $f7, $57, $ff, $e4, $ff, $18, $ef, $00, $04, $ff, $9c, $00, $ff, $00
	db $fe, $01, $f9, $07, $f7, $0f, $7a, $87, $b4, $cf, $54, $ef, $59, $ef, $ba, $cd
	db $11, $ee, $ee, $ff, $21, $fe, $2f, $f0, $00, $04, $ff, $9c, $00, $ff, $00, $fb
	db $04, $75, $8e, $d5, $ee, $1a, $e7, $eb, $f7, $14, $ef, $14, $ef, $eb, $f7, $fe
	db $01, $d9, $27, $a7, $7f, $aa, $77, $00, $04, $ff, $9c, $00, $ff, $00, $ff, $00
	db $dc, $23, $2b, $f7, $dc, $e3, $3f, $c0, $fb, $04, $14, $ef, $eb, $f7, $fd, $02
	db $3a, $c7, $db, $e7, $16, $ef, $00, $04, $ff, $9c, $00, $ff, $00, $fe, $01, $39
	db $c7, $d6, $ef, $29, $f7, $53, $ef, $bc, $4f, $12, $ed, $ed, $f3, $db, $24, $25
	db $fe, $a5, $fe, $15, $ee, $00, $04, $ff, $ff, $00, $ff, $00, $3f, $c0, $dc, $e3
	db $b3, $cf, $3c, $cf, $d1, $ef, $2d, $f3, $2e, $f1, $df, $e0, $ff, $00, $fc, $03
	db $f3, $0f, $fc, $0f, $00, $f8, $f8, $fc, $f4, $0e, $fa, $07, $5e, $f3, $0e, $f3
	db $ee, $f3, $9e, $e3, $7e, $83, $7e, $83, $9e, $e3, $6e, $f3, $9e, $63, $6e, $f3
	db $de, $e3, $be, $c3, $76, $cf, $76, $cf, $77, $cf, $70, $cf, $7f, $c0, $7c, $c3
	db $7b, $c7, $7c, $c3, $7f, $c0, $7b, $c4, $74, $cf, $7b, $c7, $5f, $e0, $2f, $70
	db $1f, $3f, $00, $1f, $69, $f7, $65, $ff, $c5, $ff, $19, $ef, $fe, $01, $39, $c7
	db $d7, $ef, $2a, $f7, $54, $ef, $b4, $4f, $19, $ef, $ea, $fd, $ff, $00, $ff, $00
	db $ff, $ff, $00, $ff, $33, $cf, $5c, $e3, $ff, $2c, $f3, $2b, $f7, $fc, $03, $7b
	db $87, $dc, $e3, $17, $ef, $e8, $f7, $1d, $e3, $1a, $e7, $e5, $fe, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $df, $e0, $5f, $e0, $b0, $cf, $7f, $8f, $7f, $80, $bc
	db $c3, $73, $8f, $dc, $ef, $b1, $cf, $7d, $83, $9e, $e1, $6f, $f0, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $a7, $7f, $59, $e7, $ba, $c7, $7b, $87, $9f, $60, $6f
	db $f0, $de, $e1, $bd, $c3, $7a, $87, $7d, $83, $9e, $e1, $6f, $f0, $ff, $00, $ff
	db $00, $ff, $c3, $7e, $c3, $6b, $f7, $96, $ef, $1a, $ef, $e6, $ff, $be, $41, $59
	db $e7, $b7, $cf, $7a, $87, $f4, $0f, $74, $8f, $b5, $cf, $5a, $ed, $ff, $00, $ff
	db $00, $ff, $ff, $00, $ff, $d5, $ee, $25, $fd, $fe, $a4, $7f, $5b, $e7, $5e, $f1
	db $29, $d7, $d7, $ef, $18, $e7, $ef, $f0, $1b, $e4, $14, $ef, $eb, $f7, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $f1, $0f, $bd, $43, $5e, $e1, $bf, $c0, $ff, $00
	db $3b, $c4, $d5, $ee, $b5, $ce, $55, $ee, $54, $ef, $35, $cf, $da, $e7, $ff, $00
	db $ff, $00, $ff, $ff, $00, $ff, $7e, $83, $7e, $83, $9e, $e3, $6e, $f3, $fe, $03
	db $3e, $c3, $5e, $e3, $ae, $73, $ae, $73, $2e, $f3, $5e, $a3, $fe, $03, $fa, $07
	db $f4, $0e, $f8, $fc, $00, $f8, $00, $01, $01, $03, $02, $07, $05, $0e, $0b, $1c
	db $17, $38, $2f, $70, $3f, $7c, $07, $7c, $07, $0c, $07, $0c, $07, $0c, $07, $0c
	db $07, $0c, $07, $0c, $07, $0c, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00
