INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $056", ROMX[$4000], BANK[$56]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_56::
	db $56

;@ path: text/control
;@ Entry points of bank $56: the text routines for this bank's texts, the message viewer (game mode
;@ $0B), clearing the text box, the text control codes, the tile viewer (game mode $0C), then the
;@ table of the compressed graphics in this bank (entries 9-30, for Decompress).
FarTable_56::
	dw StartText_56
	dw CopyText_56
	dw PrintText_56
	dw MsgViewerInit
	dw MsgViewerUpdate
	dw ClearTextBoxTiles
	dw RunTextControlCode
	dw TileViewerInit
	dw TileViewerUpdate
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

;@ def TileViewerInit()
;@ path: system/debug
;@ Start of game mode $0C, a debug tile viewer: copies DebugTestScreenMap (all 256 tile numbers in
;@ rows of 16) into the BG map and turns the screen on.
;@ test: skip turns on the LCD
TileViewerInit::
;> src, pos = DebugTestScreenMap, 0x9800
	xor a
	ld hl, $9800
	ld de, DebugTestScreenMap

.copy
;>@cp while pos != 0x9BFF:
;>     mem[pos] = mem[src]; pos += 1; src += 1
	ld a, [de]
	ld [hli], a
	inc de
	ld a, h
	cp $9b
	jr nz, .copy

;=@cp
	ld a, l
	cp $ff
	jr nz, .copy

;> mem[0x9BFF] = mem[src]
	ld a, [de]
	ld [hl], a
;> wLCDC = 0x43
	ld a, $43
	ld [wLCDC], a
;> wLCDC = 0x63
	ld a, $63
	ld [wLCDC], a
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def TileViewerUpdate()
;@ path: system/debug
;@ Per-frame routine of game mode $0C: holding A returns to the game mode saved when the debug
;@ menu was opened.
;@ test: wJoyHeld = rand(0, 255)
TileViewerUpdate::
;> if wJoyHeld & 0x01:                    # A
	ld a, [wJoyHeld]
	and $01
	cp $01
	jr nz, .done

;>     wGameMode = wDebugSavedMode[0]
	ld hl, wDebugSavedMode
	ld a, [hli]
	ld [wGameMode], a
;>     wGameModeStep = wDebugSavedMode[1]
	ld a, [hli]
	ld [wGameModeStep], a
;>     wOpeningScene = wDebugSavedMode[2]
	ld a, [hli]
	ld [wOpeningScene], a
;>     wOpeningLogo = wDebugSavedMode[3]
	ld a, [hl]
	ld [wOpeningLogo], a
;>     wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]

.done
	ret


;@ path: system/debug
;@ BG map of the tile viewer: 32 x 32 tiles, rows of tile numbers $00-$0F, $10-$1F, ... on every
;@ other line, $FF elsewhere.
;@ asset: tilemap width=32 height=32
DebugTestScreenMap::
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

;@ def ClearTextBoxTiles()
;@ path: text/box
;@ Clears the letter tiles of the text box (wTextBoxLines x wTextBoxLineLength tiles from
;@ wTextTiles) by writing TextBoxClearPattern into each, waiting for VRAM access byte by byte.
;@ test: skip polls the LCD
ClearTextBoxTiles::
;> if not (wTextBoxLines | wTextBoxLineLength):
;>     return
	ld hl, wTextBoxLines
	ld a, [hli]
	or [hl]
	ret z

;> pos = wTextTiles
	ld a, [wTextTiles]
	ld l, a
	ld a, [wTextTiles + 1]
	ld h, a
;>@c for _ in range(wTextBoxLineLength):
	ld a, [wTextBoxLineLength]
	ld c, a

.column
;>@t     for _ in range(wTextBoxLines):
	ld a, [wTextBoxLines]
	ld b, a

.tile
;>         for i in range(16):            # one tile
	push bc
	ld b, $10
	ld de, TextBoxClearPattern

.byte
;>             WaitVRAMAccess()           # (inline: until rSTAT shows mode 0 or 1)
	di

.wait
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;>             mem[pos] = mem[TextBoxClearPattern + i]; pos += 1
	ld a, [de]
	ld [hli], a
	ei
	inc de
	dec b
	jr nz, .byte

;=@t
	pop bc
	dec b
	jr nz, .tile

;=@c
	dec c
	jr nz, .column

	ret


;@ path: text/box
;@ One empty letter tile: every row $FF, $00 (color 1, the text box background).
;@ asset: tiles bpp=2 length=$10
TextBoxClearPattern::
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00

;@ def RunTextControlCode(code: d)
;@ path: text/control
;@ Carries out text control code `code` ($E0-$FF) for the text printer (TextPrinterStep): one routine
;@ per code in TextControlCodes. Codes with an argument read it from the next text byte.
;@ test: skip jump table dispatch
RunTextControlCode::
;> wTextControlCode = code
	ld a, d
	ld [wTextControlCode], a
;> TextControlCodes[code - 0xE0]()
	sub $e0
	rst $00

;@ path: text/control
;@ Routine of each text control code $E0-$FF:
;@   $E0-$E6, $FF yes/no question (cursor on yes)   $E7 yes/no question with the cursor on no
;@   $E8 cc rr  put the cursor at column cc, row rr  $E9 ss  play sound effect ss
;@   $EA / $EB  beep per letter (sound $5B / $5A)    $EC pause by message speed (or wait for a button)
;@   $ED  no wait for the rest of the text           $EE scroll the box up one line
;@   $EF  new line (scrolling at the bottom)         $F0 end of text (or of an inserted string)
;@   $F1  line break                                 $F2 clear the box and start at the top
;@   $F3  cursor to the top left                     $F4 normal speed again
;@   $F5  print without letter delay                 $F6 insert the player's name
;@   $F7  wait for a button                          $F8 ss  letter delay ss frames
;@   $F9 nn  insert string nn (at wTextArg0 + nn)    $FA show the prompt arrow
;@   $FB nn  wait nn frames (a button cuts it short) $FC nn  pause nn frames
;@   $FD / $FE  beep per letter on / off
TextControlCodes::
	dw TextCode_YesNo
	dw TextCode_YesNo
	dw TextCode_YesNo
	dw TextCode_YesNo
	dw TextCode_YesNo
	dw TextCode_YesNo
	dw TextCode_YesNo
	dw TextCode_YesNoDefaultNo
	dw TextCode_SetCursor
	dw TextCode_Sound
	dw TextCode_BeepHigh
	dw TextCode_BeepLow
	dw TextCode_SpeedPause
	dw TextCode_NoWait
	dw TextCode_Scroll
	dw TextCode_NewLine
	dw TextCode_End
	dw TextCode_LineBreak
	dw TextCode_ClearBox
	dw TextCode_Home
	dw TextCode_NormalSpeed
	dw TextCode_Instant
	dw TextCode_PlayerName
	dw TextCode_WaitButton
	dw TextCode_SetSpeed
	dw TextCode_InsertArg
	dw TextCode_Arrow
	dw TextCode_Wait
	dw TextCode_Pause
	dw TextCode_BeepOn
	dw TextCode_BeepOff
	dw TextCode_AskYesNo

;@ def TextCode_YesNo()
;@ path: text/control
;@ Codes $E0-$E6: the same as $FF, a yes/no question.
;@ test: skip draws the yes/no window
TextCode_YesNo::
;> return TextCode_AskYesNo()
	jp TextCode_AskYesNo


;@ def TextCode_YesNoDefaultNo()
;@ path: text/control
;@ Code $E7: a yes/no question with the answer set to no; the stored control code becomes $FF.
;@ test: skip draws the yes/no window
TextCode_YesNoDefaultNo::
;> TextCode_AskYesNo()
	call TextCode_AskYesNo
;> wTextChoice = 1                        # no
	ld a, $01
	ld [wTextChoice], a
;> wTextControlCode = 0xFF
	ld a, $ff
	ld [wTextControlCode], a
	ret


;@ def TextCode_SetCursor()
;@ path: text/control
;@ Code $E8 col row: moves the text cursor (and the line start) to letter `col` of line `row` in the
;@ text box tiles.
;@ test: skip reads the text bank
TextCode_SetCursor::
;> col = ReadTextBankByte(NextTextByte())
	call NextTextByte
	ld d, $00
	call ReadTextBankByte
	ld e, a
;> row = ReadTextBankByte(NextTextByte())
	call NextTextByte
	call ReadTextBankByte
;>@pos pos = wTextTiles + (row * wTextBoxLineLength + col) * 16
	ld c, a
	ld a, [wTextBoxLineLength]
	call Multiply
	add hl, de
	add hl, hl
	add hl, hl
;=@pos
	add hl, hl
	add hl, hl
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
;=@pos
	add hl, de
;> wTextCursor = pos
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor + 1], a
;> wTextLineStart = pos
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [wTextLineStart + 1], a
	ret


;@ def TextCode_Sound()
;@ path: text/control
;@ Code $E9 id: plays sound effect `id`.
;@ test: skip reads the text bank
TextCode_Sound::
;> QueueSound(ReadTextBankByte(NextTextByte()))
	call NextTextByte
	call ReadTextBankByte
	call QueueSound
	ret


;@ def TextCode_BeepHigh()
;@ path: text/control
;@ Code $EA: a beep with every letter, sound $5B.
TextCode_BeepHigh::
;> wTextFlags |= 0x01
	ld hl, wTextFlags
	set 0, [hl]
;> wTextBeep = 0x5B
	ld a, $5b
	ld [wTextBeep], a
	ret


;@ def TextCode_BeepLow()
;@ path: text/control
;@ Code $EB: a beep with every letter, sound $5A.
TextCode_BeepLow::
;> wTextFlags |= 0x01
	ld hl, wTextFlags
	set 0, [hl]
;> wTextBeep = 0x5A
	ld a, $5a
	ld [wTextBeep], a
	ret


;@ def TextCode_SpeedPause()
;@ path: text/control
;@ Code $EC: a pause whose length follows the message speed setting (TextPauseLengths, 6 to 48
;@ frames); at the slowest setting 7 it waits for a button with the prompt arrow instead.
;@ test: skip indexes a table the test runner only stubs
TextCode_SpeedPause::
;> wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
;> if wMessageSpeed != 7:
	ld a, [wMessageSpeed]
	cp $07
	jr z, .button

;>@len     wTextPauseTimer = TextPauseLengths[wMessageSpeed]
	ld hl, TextPauseLengths
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@len
	ld a, [hl]
	ld [wTextPauseTimer], a
;>     wTextState |= 0x80                 # timed pause
	ld hl, wTextState
	set 7, [hl]
	ret

;> else:
.button
;>     wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
;>     wTextState |= 0x04 | 0x20          # wait for a button, with the arrow
	ld hl, wTextState
	set 2, [hl]
	set 5, [hl]
	ret


;@ path: text/control
;@ Frames of the $EC pause for message speeds 0-6.
TextPauseLengths::
	db $06, $0c, $14, $1a, $20, $28, $30

;@ def TextCode_NoWait()
;@ path: text/control
;@ Code $ED: marks the text as sped up, so the rest prints without letter delay.
TextCode_NoWait::
;> wTextFlags |= 0x80
	ld hl, wTextFlags
	set 7, [hl]
	ret


;@ def TextCode_Scroll()
;@ path: text/control
;@ Code $EE: second half of scrolling the two-line box (TextCode_NewLine does the first): maps line
;@ 1's tiles to the box's top row again, blanks the middle row, clears line 2's tiles and maps them
;@ to the bottom row, and puts the cursor back to the start of the line.
;@ test: skip polls the LCD
TextCode_Scroll::
;>@t tile = wTextTiles >> 4               # tile number of the box's first letter tile
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
	srl d
	rr e
;=@t
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
;> lines, length = wTextBoxLines, wTextBoxLineLength
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
;> pos = wTextBoxMap
	ld a, [wTextBoxMap]
	ld l, a
	ld a, [wTextBoxMap + 1]
	ld h, a
	push bc

.row1
;> for _ in range(length):                # top row: line 1
;>     WriteVRAM(tile, pos); pos = MapNextTile(pos); tile += 1
	ld a, e
	call WriteVRAM
	call MapNextTile
	inc e
	dec b
	jr nz, .row1

;>@clr ClearMapTiles(TextBoxMapAddress(0x20), length)   # middle row
	ld hl, $0020
	call TextBoxMapAddress
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
;=@clr
	call ClearMapTiles
;>@n size = length * 16                     # bytes of one line of tiles
	ld a, [wTextBoxLineLength]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@n
	add hl, hl
	ld c, l
	ld b, h
;>@p p = wTextTiles + size                  # line 2's tiles
	push de
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
	add hl, de
;=@p
	pop de

.clear
;> for _ in range(size // 2):              # clear them to the background pattern
;>@cl     p = WriteVRAMInc(0xFF, p); p = WriteVRAMInc(0x00, p)
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec bc
	dec bc
;=@cl
	ld a, b
	or c
	jr nz, .clear

;> pos = TextBoxMapAddress(0x40)           # bottom row: line 2
	pop bc
	ld hl, $0040
	call TextBoxMapAddress

.row2
;> for _ in range(length):
;>     WriteVRAM(tile, pos); pos = MapNextTile(pos); tile += 1
	ld a, e
	call WriteVRAM
	call MapNextTile
	inc e
	dec b
	jr nz, .row2

;>@cur wTextCursor = wTextLineStart
	ld a, [wTextLineStart]
	ld l, a
	ld a, [wTextLineStart + 1]
	ld h, a
	ld a, l
	ld [wTextCursor], a
;=@cur
	ld a, h
	ld [wTextCursor + 1], a
;> wTextState &= ~0x02
	ld hl, wTextState
	res 1, [hl]
	ret


;@ def TextCode_NewLine()
;@ path: text/control
;@ Code $EF: new line. On the first line the cursor moves to the start of the second line (and one
;@ text byte is skipped). On the second line the box scrolls: the top row is blanked, line 2's tiles
;@ are shown in the middle row, the bottom row is blanked, line 2's letters are copied into line 1's
;@ tiles, and a 4-frame pause follows (TextCode_Scroll finishes the scroll).
;@ test: skip polls the LCD
TextCode_NewLine::
;>@l2 line2 = wTextTiles + wTextBoxLineLength * 16
	ld a, [wTextBoxLineLength]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@l2
	add hl, hl
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
	add hl, de
;>@cmp if wTextLineStart != line2:
	ld a, [wTextLineStart]
	ld e, a
	ld a, [wTextLineStart + 1]
	ld d, a
	ld a, e
	sub l
;=@cmp
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld a, d
	or e
;=@cmp
	jr z, .scroll

;>     wTextCursor = line2
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor + 1], a
;>     wTextLineStart = line2
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [wTextLineStart + 1], a
;>     NextTextByte()
;>     return
	call NextTextByte
	ret

.scroll
;>@c0 ClearMapTiles(wTextBoxMap, wTextBoxLineLength)   # top row
	ld a, [wTextBoxMap]
	ld l, a
	ld a, [wTextBoxMap + 1]
	ld h, a
	ld a, [wTextBoxLines]
	ld c, a
;=@c0
	ld a, [wTextBoxLineLength]
	ld b, a
	call ClearMapTiles
;>@t tile = wTextTiles >> 4
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
	srl d
	rr e
;=@t
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
;> pos = TextBoxMapAddress(0x20)           # middle row
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	ld hl, $0020
	call TextBoxMapAddress
;> tile += wTextBoxLineLength              # line 2's tiles
	ld a, e
	add b
	ld e, a

.row
;> for _ in range(wTextBoxLineLength):
;>     WriteVRAM(tile, pos); pos = MapNextTile(pos); tile += 1
	ld a, e
	call WriteVRAM
	call MapNextTile
	inc e
	dec b
	jr nz, .row

;>@c2 ClearMapTiles(TextBoxMapAddress(0x40), wTextBoxLineLength)   # bottom row
	ld hl, $0040
	call TextBoxMapAddress
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
;=@c2
	call ClearMapTiles
;>@sz size = wTextBoxLineLength * 16
	ld a, [wTextBoxLineLength]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@sz
	add hl, hl
;> dest = wTextTiles
	ld a, [wTextTiles]
	ld e, a
	ld a, [wTextTiles + 1]
	ld d, a
;> src = dest + size
	ld c, l
	ld b, h
	add hl, de

.copy
;> for _ in range(size):                   # line 2's letters into line 1
;>@cp     WaitVRAMAccess(); mem[dest] = mem[src]; dest += 1; src += 1
	di
	call WaitVRAMAccess
	ld a, [hli]
	ei
	ld [de], a
	inc de
;=@cp
	dec bc
	ld a, b
	or c
	jr nz, .copy

;> wTextState |= 0x80                     # pause ...
	ld hl, wTextState
	set 7, [hl]
;> wTextPauseTimer = 4                    # ... 4 frames
	ld a, $04
	ld [wTextPauseTimer], a
	ret


;@ def TextCode_End()
;@ path: text/control
;@ Code $F0: end of a string. Inside an inserted string (player name, $F9 argument; wTextState bit 4)
;@ the text goes on where it was (wTextStart holds the return point); otherwise printing stops.
;@ test: skip calls EraseTextPromptArrow
TextCode_End::
;> if wTextState & 0x10:
	ld a, [wTextState]
	bit 4, a
	jp z, TextStop

;>     wTextState &= ~0x10
	ld a, [wTextState]
	res 4, a
	ld [wTextState], a
;>     EraseTextPromptArrow()
	call EraseTextPromptArrow
;>@wp     wTextPtr = wTextStart
	ld a, [wTextStart]
	ld l, a
	ld a, [wTextStart + 1]
	ld h, a
	ld a, l
	ld [wTextPtr], a
;=@wp
	ld a, h
	ld [wTextPtr + 1], a
	ret

;> else:
TextStop:
;>     wTextState = 0
	xor a
	ld [wTextState], a
;>     wTextFlags = 0
	xor a
	ld [wTextFlags], a
	ret


;@ def TextCode_LineBreak()
;@ path: text/control
;@ Code $F1: line break, the cursor moves to the start of the next line's tiles (no scrolling).
TextCode_LineBreak::
;>@nl start = wTextLineStart + wTextBoxLineLength * 16
	ld a, [wTextBoxLineLength]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@nl
	add hl, hl
	ld a, [wTextLineStart]
	ld e, a
	ld a, [wTextLineStart + 1]
	ld d, a
	add hl, de
;> wTextCursor = start
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor + 1], a
;> wTextLineStart = start
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [wTextLineStart + 1], a
	ret


;@ def TextCode_ClearBox()
;@ path: text/control
;@ Code $F2: erases the prompt arrow, ends a speed-up, clears the box's tiles and starts again at the
;@ top left (TextCode_Home follows).
;@ test: skip polls the LCD
TextCode_ClearBox::
;> EraseTextPromptArrow()
	call EraseTextPromptArrow
;> TextCode_NormalSpeed()
	call TextCode_NormalSpeed
;> ClearTextBoxTiles()
;> TextCode_Home()                        # (runs on into it)
	call ClearTextBoxTiles

;@ def TextCode_Home()
;@ path: text/control
;@ Code $F3: the cursor (and line start) go to the first letter tile of the box.
TextCode_Home::
;>@c wTextCursor = wTextTiles
	ld a, [wTextTiles]
	ld l, a
	ld a, [wTextTiles + 1]
	ld h, a
	ld a, l
	ld [wTextCursor], a
;=@c
	ld a, h
	ld [wTextCursor + 1], a
;> wTextLineStart = wTextTiles
	ld a, l
	ld [wTextLineStart], a
	ld a, h
	ld [wTextLineStart + 1], a
	ret


;@ def TextCode_NormalSpeed()
;@ path: text/control
;@ Code $F4: back to normal letter speed (no speed-up, letter delay on).
TextCode_NormalSpeed::
;> wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
;> wTextState &= ~0x02
	ld hl, wTextState
	res 1, [hl]
	ret


;@ def TextCode_Instant()
;@ path: text/control
;@ Code $F5: print without letter delay.
TextCode_Instant::
;> wTextState |= 0x02
	ld hl, wTextState
	set 1, [hl]
	ret


;@ def TextCode_PlayerName()
;@ path: text/control
;@ Code $F6: inserts the player's name: copies 8 bytes from wPlayerName to wNameInput, ends them
;@ with $F0, remembers where the text goes on (wTextStart, wTextState bit 4) and prints from there.
TextCode_PlayerName::
;>@pn for i in range(8): wNameInput[i] = mem[wPlayerName + i]
	ld hl, wPlayerName
	ld de, wNameInput
	ld b, $08

.copy
;=@pn
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy

;> mem[wNameInput + 8] = 0xF0
	ld a, $f0
	ld [de], a
;> wTextState |= 0x10                     # inside an inserted string
	ld hl, wTextState
	set 4, [hl]
;>@s wTextStart = wTextPtr                  # where to go on afterwards
	ld a, [wTextPtr]
	ld l, a
	ld a, [wTextPtr + 1]
	ld h, a
	ld a, l
	ld [wTextStart], a
;=@s
	ld a, h
	ld [wTextStart + 1], a
;> wTextPtr = wNameInput
	ld hl, wNameInput
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [wTextPtr + 1], a
	ret


;@ def TextCode_WaitButton()
;@ path: text/control
;@ Code $F7: waits for a button.
TextCode_WaitButton::
;> wTextState |= 0x04
	ld hl, wTextState
	set 2, [hl]
;> wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
	ret


;@ def TextCode_SetSpeed()
;@ path: text/control
;@ Code $F8 n: from now on `n` frames per letter (wTextSpeed, wTextState bit 3).
;@ test: skip reads the text bank
TextCode_SetSpeed::
;> wTextState |= 0x08
	ld hl, wTextState
	set 3, [hl]
;> wTextSpeed = ReadTextBankByte(NextTextByte())
	call NextTextByte
	call ReadTextBankByte
	ld [wTextSpeed], a
	ret


;@ def TextCode_InsertArg()
;@ path: text/control
;@ Code $F9 n: inserts a string: the text goes on at wTextArg0 + n until its $F0, then after the code
;@ (wTextStart, wTextState bit 4). In the message viewer (game mode $0B) the placeholder
;@ UnusedMesbufText is shown instead.
;@ test: skip reads the text bank
TextCode_InsertArg::
;> wTextState |= 0x10                     # inside an inserted string
	ld hl, wTextState
	set 4, [hl]
;>@s wTextStart = wTextPtr + 1              # go on after the argument byte
	ld a, [wTextPtr]
	ld l, a
	ld a, [wTextPtr + 1]
	ld h, a
	ld a, l
	ld [wTextStart], a
;=@s
	ld a, h
	ld [wTextStart + 1], a
;=@s
	ld a, [wTextStart]
	add $01
	ld [wTextStart], a
	ld a, [wTextStart + 1]
	adc $00
	ld [wTextStart + 1], a
;> if wGameMode == 0x0B:
	ld a, [wGameMode]
	cp $0b
	jr nz, .arg

;>     wTextPtr = UnusedMesbufText
;>     return
	ld hl, UnusedMesbufText
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [wTextPtr + 1], a
	ret

.arg
;>@p wTextPtr = wTextArg0 + ReadTextBankByte(wTextPtr)
	call ReadTextBankByte
	ld de, wTextArg0
	add e
	ld l, a
	ld a, $00
	adc d
;=@p
	ld h, a
	ld a, l
	ld [wTextPtr], a
	ld a, h
	ld [wTextPtr + 1], a
	ret


;@ def TextCode_Arrow()
;@ path: text/control
;@ Code $FA: shows the prompt arrow (wTextState bit 5).
TextCode_Arrow::
;> wTextState |= 0x20
	ld hl, wTextState
	set 5, [hl]
	ret


;@ def TextCode_Wait()
;@ path: text/control
;@ Code $FB n: waits `n` frames; a button cuts the wait short (wTextState bit 6).
;@ test: skip reads the text bank
TextCode_Wait::
;> wTextState |= 0x40
	ld hl, wTextState
	set 6, [hl]
;> wTextWaitTimer = ReadTextBankByte(NextTextByte())
	call NextTextByte
	call ReadTextBankByte
	ld [wTextWaitTimer], a
;> wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
	ret


;@ def TextCode_Pause()
;@ path: text/control
;@ Code $FC n: pauses `n` frames (wTextState bit 7).
;@ test: skip reads the text bank
TextCode_Pause::
;> wTextState |= 0x80
	ld hl, wTextState
	set 7, [hl]
;> wTextPauseTimer = ReadTextBankByte(NextTextByte())
	call NextTextByte
	call ReadTextBankByte
	ld [wTextPauseTimer], a
;> wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
	ret


;@ def TextCode_BeepOn()
;@ path: text/control
;@ Code $FD: a beep with every letter (sound wTextBeep).
TextCode_BeepOn::
;> wTextFlags |= 0x01
	ld hl, wTextFlags
	set 0, [hl]
	ret


;@ def TextCode_BeepOff()
;@ path: text/control
;@ Code $FE: no more beeps.
TextCode_BeepOff::
;> wTextFlags &= ~0x01
	ld hl, wTextFlags
	res 0, [hl]
	ret


;@ def TextCode_AskYesNo()
;@ path: text/control
;@ Code $FF (and $E0-$E6): a yes/no question. Plays sound $5C, saves the visible 32 x 18 background
;@ in wTilemapBuffer (to restore it afterwards), draws the yes/no window and waits for a button with
;@ the answer on yes (wTextChoice 0).
;@ test: skip polls the LCD
TextCode_AskYesNo::
;> wTextFlags &= ~0x80
	ld hl, wTextFlags
	res 7, [hl]
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> pos = ScreenMapAddress(0)              # the screen's top left in the BG map
	ld hl, $0000
	call ScreenMapAddress
;> dest = wTilemapBuffer
	ld de, wTilemapBuffer
	ld c, $12
;> for _ in range(18):
.row
	ld b, $20
	push hl

.tile
;>     for _ in range(32):
;>         WaitVRAMAccess(); mem[dest] = mem[pos]; dest += 1
	di
	call WaitVRAMAccess
	ld a, [hl]
	ei
	ld [de], a
;>@nx         pos = pos & 0xFFE0 | (pos + 1) & 0x1F   # next column, wrapping in the row
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@nx
	ld l, a
	pop af
	or l
	ld l, a
	inc de
;=@nx
	dec b
	jr nz, .tile

;>@nr     pos = (pos & 0xFFE0) + 0x20 & 0x3FF | 0x9800   # next row, wrapping in the map
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@nr
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, .row

;> DrawYesNoWindow()
	call DrawYesNoWindow
;> wTextState |= 0x04                     # wait for a button
	ld hl, wTextState
	set 2, [hl]
;> wTextChoice = 0                        # yes
	xor a
	ld [wTextChoice], a
	ret


;@ def DrawYesNoWindow()
;@ path: text/box
;@ Loads the window tiles (compressed entry $56:$0A, to $8E50) and draws YesNoWindowMap on the
;@ screen 8 rows down and 14 tiles across.
;@ test: skip polls the LCD
DrawYesNoWindow::
;> DecompressVRAM(0x56, 0x0A, 0x8E50)
	ld de, $560a
	ld hl, $8e50
	call DecompressVRAM
;> pos = MapAdvanceTiles(ScreenMapAddress(0x100), 14)
	ld hl, $0100
	call ScreenMapAddress
	ld b, $0e
	call MapAdvanceTiles
;> src = YesNoWindowMap
	ld de, YesNoWindowMap

.line
;> while True:
;>     start = pos
	push hl

.tile
;>     t = mem[src]; src += 1
	ld a, [de]
	inc de
;>     if t == 0xD9:                      # end
;>         return
	cp $d9
	jr z, .done

;>     if t == 0xD8:                      # next row
	cp $d8
	jr nz, .put

;>@nr         pos = start + 0x20 & 0x3FF | 0x9800
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
;=@nr
	ld h, a
	ld a, h
	and $03
	or $98
	ld h, a
	jr .line

;>     else:
.put
;>         WriteVRAM(t, pos); pos = MapNextTile(pos)
	call WriteVRAM
	call MapNextTile
	jr .tile

.done
	pop hl
	ret


;@ path: text/box
;@ Tiles of the yes/no window, row by row: $D8 starts the next row, $D9 ends. A frame ($FA-$FF
;@ corners and sides, $EE/$EF edges) around "YES" ($D4-$D6) and "NO" ($E5-$E6); $E0 is blank.
YesNoWindowMap::
	db $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e5, $e6, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ def StartText_56()
;@ path: text/printer
;@ StartText with this bank's text table (TextTable_56).
;@ test: skip runs the text printer
StartText_56::
;> StartText(TextTable_56)
	ld de, TextTable_56
	call StartText
	ret


;@ def CopyText_56()
;@ path: text/printer
;@ CopyTextString with this bank's text table (TextTable_56).
;@ test: skip runs the text printer
CopyText_56::
;> CopyTextString(TextTable_56)
	ld de, TextTable_56
	call CopyTextString
	ret


;@ def PrintText_56()
;@ path: text/printer
;@ Prints text wTextGroup/wTextIndex of this bank's table at once (StartText_56, RunTextToEnd).
;@ test: skip runs the text printer
PrintText_56::
;> StartText_56()
	call StartText_56
;> RunTextToEnd()
	call RunTextToEnd
	ret


;@ def MsgViewerInit()
;@ path: system/debug
;@ Start of game mode $0B, a debug message viewer: lists four text tables per page (page
;@ wGameModeStep, 10 pages) with a hex text number for each; the chosen text is shown in the window
;@ below. Sets up the text box for the window ($9000), the window map, the page and the cursor.
;@ test: skip turns on the LCD
MsgViewerInit::
;> SetUpTextBox(0x9000, lines=7, line_length=18)
	ld hl, $9000
	ld de, $1207
	call SetUpTextBox
;> FillMemory(wNumberBackup, 0x10, 0)
	ld hl, wNumberBackup
	ld bc, $0010
	ld a, $00
	call FillMemory
;> FillMemory(0x9C00, 0x400, 0x1F)        # blank window map
	ld hl, $9c00
	ld bc, $0400
	ld a, $1f
	call FillMemory
;> FillTileBlock_56(0x9C00, width=18, height=4, first=0x80)   # the text box in the window
	ld hl, $9c00
	ld bc, $1204
	ld a, $80
	call FillTileBlock_56
;> wMenuChoice = 0
	xor a
	ld [wMenuChoice], a
;> rVBK = 0
	xor a
	ldh [rVBK], a
;> MsgViewerDrawPage()
	call MsgViewerDrawPage
;> QueueMusic(0)
	ld a, $00
	call QueueMusic
;> wMsgViewBlinkTimer = 10
	ld a, $0a
	ld [wMsgViewBlinkTimer], a
;> wMsgViewCursor = 0
	xor a
	ld [wMsgViewCursor], a
;> wMsgViewMapHi = 0x98
	ld a, $98
	ld [wMsgViewMapHi], a
;> wMsgViewMapLo = 0x8E                   # the first number at $988E
	ld a, $8e
	ld [wMsgViewMapLo], a
;> hWY = 0x64
	ld a, $64
	ldh [hWY], a
;> hWX = 7
	ld a, $07
	ldh [hWX], a
;> wMsgViewDigitHi = mem[0x988E]
	ld h, $98
	ld l, $8e
	ld a, [hli]
	ld [wMsgViewDigitHi], a
;> wMsgViewDigitLo = mem[0x988F]
	ld a, [hl]
	ld [wMsgViewDigitLo], a
;> mem[0xC83B] = 0x1F
	ld a, $1f
	ld [$c83b], a
;> mem[0xC83D] = 0x7F
	ld a, $7f
	ld [$c83d], a
;> wMsgViewRightDelay = 0
	xor a
	ld [wMsgViewRightDelay], a
;> wMsgViewLeftDelay = 0
	ld [wMsgViewLeftDelay], a
;> wLCDC = 0x43
	ld a, $43
	ld [wLCDC], a
;> wLCDC = 0x63                           # window on
	ld a, $63
	ld [wLCDC], a
;> return EnableLCDAndInterrupts(1)
	ld a, $01
	jp EnableLCDAndInterrupts


;@ def MsgViewerDrawPage()
;@ path: system/debug
;@ Draws the viewer's page: the title (bank $56 text 0) into the tiles at $9100 and the names of the
;@ page's four text tables (text wGameModeStep + 1) at $9300, maps them, and draws "00" numbers.
;@ test: skip calls routines in other banks
MsgViewerDrawPage::
;> wSGBPalSet = 0
	ld hl, wSGBPalSet
	ld [hl], $00
;> mem[addr(wSGBPalSet) + 1] = 0
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> wTextGroup = 0
	ld hl, $9100
	ld a, $00
	ld [wTextGroup], a
;> wTextIndex = 0
	ld a, $00
	ld [wTextIndex], a
;> MsgViewerPrint(0x9100, lines=2, line_length=16)
	ld de, $1002
	call MsgViewerPrint
;> wTextIndex = wGameModeStep + 1
	ld hl, $9300
	ld a, [wGameModeStep]
	inc a
	ld [wTextIndex], a
;> MsgViewerPrint(0x9300, lines=4, line_length=16)
	ld de, $1004
	call MsgViewerPrint
;> ClearBGMap_56()
	call ClearBGMap_56
;> FillTileBlock_56(0x9823, width=16, height=2, first=0x10)
	ld hl, $9823
	ld bc, $1002
	ld a, $10
	call FillTileBlock_56
;> FillTileBlock_56(0x9883, width=16, height=4, first=0x30)
	ld hl, $9883
	ld bc, $1004
	ld a, $30
	call FillTileBlock_56
;> DrawMsgViewerNumbers()
	call DrawMsgViewerNumbers
	ret


;@ def MsgViewerPrint(tiles: hl, lines: e, line_length: d)
;@ path: system/debug
;@ Sets up the text box and prints text wTextGroup/wTextIndex of bank $56 at once.
;@ test: skip runs the text printer
MsgViewerPrint::
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = line_length
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> PrintText_56()
	call PrintText_56
	ret



;@ def MsgViewerStartText(tiles: hl, lines: e, line_length: d)
;@ path: system/debug
;@ Sets up the text box and starts text wTextGroup/wTextIndex of bank $56 (printed letter by letter).
;@ test: skip runs the text printer
MsgViewerStartText::
;> wTextBoxLines = lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = line_length
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> StartText_56()
	call StartText_56
	ret

;@ def FillTileBlock_56(pos: hl, width: b, height: c, first: a)
;@ path: system/debug
;@ Fills a `width` x `height` block of the background map at `pos` with consecutive tile numbers
;@ from `first` on (WriteVRAMInc, so the screen may be on).
;@ test: skip polls the LCD
FillTileBlock_56::
;>@loop for _ in range(height):
	push hl
	ld d, b

.col
;>     for _ in range(width): pos = WriteVRAMInc(first, pos); first = (first + 1) & 0xFF
	call WriteVRAMInc
	inc a
	dec b
	jr nz, .col

	ld b, d
;>@p     pos = row_start + 0x20
	ld e, a
	pop hl
	ld a, l
	add $20
	ld l, a
	ld a, h
;=@p
	adc $00
	ld h, a
	ld a, e
;=@loop
	dec c
	jr nz, FillTileBlock_56

	ret


;@ def ClearBGMap_56()
;@ path: system/debug
;@ Fills the background map $9800-$9BFF with tile $1F.
;@ test: skip writes the whole BG map
ClearBGMap_56::
;> FillMemory(0x9800, 0x400, 0x1F)
	ld hl, $9800
	ld bc, $0400
	ld a, $1f
	call FillMemory
	ret


;@ def DrawMsgViewerNumbers()
;@ path: system/debug
;@ Writes "00" (digit tile $70 twice) as the text number of the four rows, at $988E downwards
;@ (the screen is off).
DrawMsgViewerNumbers::
;> pos = 0x988E
	ld b, $04
	ld hl, $988e
	ld c, $6f
;> for _ in range(4):
.row
;>     mem[pos] = mem[pos + 1] = 0x70
	ld a, $70
	ld [hli], a
	ld [hld], a
;>@r     pos += 0x20
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@r
	dec b
	jr nz, .row

	ret


;@ def MsgViewerUpdate()
;@ path: system/debug
;@ Per-frame routine of game mode $0B: input, the blinking number, and the number read back from its
;@ digit tiles.
;@ test: skip polls the LCD
MsgViewerUpdate::
;> MsgViewerInput()
	call MsgViewerInput
;> MsgViewerBlink()
	call MsgViewerBlink
;> MsgViewerReadNumber()
	call MsgViewerReadNumber
	ret


;@ def MsgViewerInput()
;@ path: system/debug
;@ Input of the message viewer: up/down moves the cursor over the four rows (restoring the number
;@ tiles under it first), holding right/left counts the row's text number up/down every 8 frames
;@ (as two hex digit tiles $70-$7F), SELECT turns the page (10 pages), B shows the chosen text in the
;@ window through the routine of its text bank (MsgViewRowBanks), or bank $56 text 11 when the number
;@ is past the table's MsgViewRowCounts; otherwise MsgViewerCheckStart.
;@ test: skip polls the LCD
MsgViewerInput::
;> if wJoyPressed & 0x40:                 # Up
	ld a, [wJoyPressed]
	bit 6, a
	jr z, .notUp

;>@rs     WriteVRAM(wMsgViewDigitLo, WriteVRAMInc(wMsgViewDigitHi, cursor_map))   # restore the number
	ld a, [wMsgViewMapHi]
	ld h, a
	ld a, [wMsgViewMapLo]
	ld l, a
	ld a, [wMsgViewDigitHi]
	call WriteVRAMInc
;=@rs
	ld a, [wMsgViewDigitLo]
	call WriteVRAM
;>@cu     wMsgViewCursor = (wMsgViewCursor - 1) % 4
	ld a, [wMsgViewCursor]
	dec a
	cp $ff
	jr nz, .up

	ld a, $03

.up
;=@cu
	ld [wMsgViewCursor], a
;>     wMsgViewRow = wMsgViewPageRow + wMsgViewCursor
	ld c, a
	ld a, [wMsgViewPageRow]
	add c
	ld [wMsgViewRow], a
;>@mp     map = 0x988E + wMsgViewCursor * 0x20
	ld a, [wMsgViewCursor]
	ld c, $20
	call Multiply
	ld a, l
	add $8e
	ld l, a
;=@mp
	ld a, h
	adc $98
	ld h, a
;>     wMsgViewMapHi = map >> 8
	ld a, h
	ld [wMsgViewMapHi], a
;>     wMsgViewMapLo = map & 0xFF
	ld a, l
	ld [wMsgViewMapLo], a
;>     WaitVRAMAccess(); wMsgViewDigitHi = mem[map]
	call WaitVRAMAccess
	ld a, [hli]
	ld [wMsgViewDigitHi], a
;>     WaitVRAMAccess(); wMsgViewDigitLo = mem[map + 1]
	call WaitVRAMAccess
	ld a, [hl]
	ld [wMsgViewDigitLo], a

.notUp
;> if wJoyPressed & 0x80:                 # Down
	ld a, [wJoyPressed]
	bit 7, a
	jr z, .notDown

;>@rs2     WriteVRAM(wMsgViewDigitLo, WriteVRAMInc(wMsgViewDigitHi, cursor_map))
	ld a, [wMsgViewMapHi]
	ld h, a
	ld a, [wMsgViewMapLo]
	ld l, a
	ld a, [wMsgViewDigitHi]
	call WriteVRAMInc
;=@rs2
	ld a, [wMsgViewDigitLo]
	call WriteVRAM
;>@cd     wMsgViewCursor = (wMsgViewCursor + 1) % 4
	ld a, [wMsgViewCursor]
	inc a
	cp $04
	jr nz, .down

	xor a

.down
;=@cd
	ld [wMsgViewCursor], a
;>     wMsgViewRow = wMsgViewPageRow + wMsgViewCursor
	ld c, a
	ld a, [wMsgViewPageRow]
	add c
	ld [wMsgViewRow], a
;>@mp2     map = 0x988E + wMsgViewCursor * 0x20
	ld a, [wMsgViewCursor]
	ld c, $20
	call Multiply
	ld a, l
	add $8e
	ld l, a
;=@mp2
	ld a, h
	adc $98
	ld h, a
;>     wMsgViewMapHi = map >> 8
	ld a, h
	ld [wMsgViewMapHi], a
;>     wMsgViewMapLo = map & 0xFF
	ld a, l
	ld [wMsgViewMapLo], a
;>     WaitVRAMAccess(); wMsgViewDigitHi = mem[map]
	call WaitVRAMAccess
	ld a, [hli]
	ld [wMsgViewDigitHi], a
;>     WaitVRAMAccess(); wMsgViewDigitLo = mem[map + 1]
	call WaitVRAMAccess
	ld a, [hl]
	ld [wMsgViewDigitLo], a

.notDown
;> if wJoyHeld & 0x10:                    # Right held
	ld a, [wJoyHeld]
	bit 4, a
	jp z, .notRight

;>     wMsgViewRightDelay = (wMsgViewRightDelay + 1) & 7
	ld a, [wMsgViewRightDelay]
	inc a
	and $07
	ld [wMsgViewRightDelay], a
;>     if wMsgViewRightDelay: return      # one step every 8 frames
	jr z, .right

	ret

.right
;>     if wMsgViewDigitLo == 0x7F:        # count the hex digits up
	ld a, [wMsgViewDigitLo]
	inc a
	cp $80
	jr nz, .incLo

;>         wMsgViewDigitLo = 0x70
	ld a, $70
	ld [wMsgViewDigitLo], a
;>@hu         wMsgViewDigitHi = 0x70 if wMsgViewDigitHi == 0x7F else wMsgViewDigitHi + 1
	ld a, [wMsgViewDigitHi]
	inc a
	cp $80
	jr nz, .hiUp

	ld a, $70

.hiUp
;=@hu
	ld [wMsgViewDigitHi], a
	jr .numUp

;>     else:
.incLo
;>         wMsgViewDigitLo += 1
	ld [wMsgViewDigitLo], a

.numUp
;>     wMsgViewNumber += 1
;>     return
	ld a, [wMsgViewNumber]
	inc a
	ld [wMsgViewNumber], a
	ret

.notRight
;> if wJoyHeld & 0x20:                    # Left held
	ld a, [wJoyHeld]
	bit 5, a
	jp z, .notLeft

;>     wMsgViewLeftDelay = (wMsgViewLeftDelay + 1) & 7
	ld a, [wMsgViewLeftDelay]
	inc a
	and $07
	ld [wMsgViewLeftDelay], a
;>     if wMsgViewLeftDelay: return
	jr z, .left

	ret

.left
;>     if wMsgViewDigitLo == 0x70:        # count the hex digits down
	ld a, [wMsgViewDigitLo]
	dec a
	cp $6f
	jr nz, .decLo

;>         wMsgViewDigitLo = 0x7F
	ld a, $7f
	ld [wMsgViewDigitLo], a
;>@hd         wMsgViewDigitHi = 0x7F if wMsgViewDigitHi == 0x70 else wMsgViewDigitHi - 1
	ld a, [wMsgViewDigitHi]
	dec a
	cp $6f
	jr nz, .hiDown

	ld a, $7f

.hiDown
;=@hd
	ld [wMsgViewDigitHi], a
	jr .numDown

;>     else:
.decLo
;>         wMsgViewDigitLo -= 1
	ld [wMsgViewDigitLo], a

.numDown
;>     wMsgViewNumber -= 1
;>     return
	ld a, [wMsgViewNumber]
	dec a
	ld [wMsgViewNumber], a
	ret

.notLeft
;> if wJoyPressed & 0x04:                 # Select: next page
	ld a, [wJoyPressed]
	bit 2, a
	jr z, .notSelect

;>     wGameModeStep = (wGameModeStep + 1) % 10
	ld a, [wGameModeStep]
	inc a
	cp $0a
	jr nz, .page

	ld a, $00

.page
	ld [wGameModeStep], a
;>     wGameModeChange += 1               # set the viewer up again
	ld hl, wGameModeChange
	inc [hl]
;>     wMsgViewPageRow = wGameModeStep * 4
	ld a, [wGameModeStep]
	ld c, $04
	call Multiply
	ld a, l
	ld [wMsgViewPageRow], a
;>     wMsgViewRow = wMsgViewPageRow
	ld [wMsgViewRow], a
;>     QueueSound(0x0C)
;>     return
	ld a, $0c
	call QueueSound
	ret

.notSelect
;> if not wJoyPressed & 0x02:             # no B
;>     return MsgViewerCheckStart()
	ld a, [wJoyPressed]
	bit 1, a
	jp z, MsgViewerCheckStart

;>@cnt if MsgViewRowCounts[wMsgViewRow] < wMsgViewNumber:   # no such text
	ld a, [wMsgViewNumber]
	ld b, a
	ld a, [wMsgViewRow]
	ld hl, MsgViewRowCounts
	add l
	ld l, a
;=@cnt
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	sub b
	jr nc, .show

;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     wTextIndex = 11                    # a "no such message" text of bank $56
	ld a, $0b
	ld [wTextIndex], a
;>     return MsgViewerStartText(0x8800, lines=4, line_length=18)
	ld de, $1204
	ld hl, $8800
	call MsgViewerStartText
	ret

.show
;> wTextIndex = wMsgViewNumber
	ld a, [wMsgViewNumber]
	ld [wTextIndex], a
;>@g wTextGroup = MsgViewRowGroups[wMsgViewRow]
	ld a, [wMsgViewRow]
	ld hl, MsgViewRowGroups
	add l
	ld l, a
	ld a, $00
	adc h
;=@g
	ld h, a
	ld a, [hl]
	ld [wTextGroup], a
;>@b wMsgViewBank = MsgViewRowBanks[wMsgViewRow]
	ld hl, MsgViewRowBanks
	ld a, [wMsgViewRow]
	add l
	ld l, a
	ld a, $00
	adc h
;=@b
	ld h, a
	ld a, [hl]
	ld [wMsgViewBank], a
;> wTextBoxLines = 4
	ld de, $1204
	ld hl, $8800
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 18
	ld a, d
	ld [wTextBoxLineLength], a
;> wTextTiles = 0x8800
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;> MsgViewTexts[wMsgViewBank]()          # start the text with that bank's routine
	ld a, [wMsgViewBank]
	rst $00

	dw MsgViewText41
	dw MsgViewText42
	dw MsgViewText43
	dw MsgViewText44
	dw MsgViewText45
	dw MsgViewText46
	dw MsgViewText47
	dw MsgViewText48
	dw MsgViewText49
	dw MsgViewText4A
	dw MsgViewText4B
	dw MsgViewText4C
	dw MsgViewText4D
	dw MsgViewText4E
	dw MsgViewText59
	dw MsgViewText56

;@ def MsgViewText41()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $41.
;@ test: skip calls a routine in another bank
MsgViewText41::
;> StartText_41()
	ld hl, far_StartText_41
	rst $10
	ret


;@ def MsgViewText42()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $42; group 0 numbers from
;@ $E2 on are group 0 of the next bank ($43), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText42::
;>@c if wTextGroup == 0 and wTextIndex >= 0xE2:
	ld a, [wTextGroup]
	cp $00
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $e2
	jr c, .start

;>     wTextIndex -= 0xE2
	sub $e2
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText43()
	jr MsgViewText43

.start
;> StartText_42()
	ld hl, far_StartText_42
	rst $10
	ret


;@ def MsgViewText43()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $43; group 1 numbers from
;@ $98 on are group 0 of the next bank ($44), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText43::
;>@c if wTextGroup == 1 and wTextIndex >= 0x98:
	ld a, [wTextGroup]
	cp $01
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $98
	jr c, .start

;>     wTextIndex -= 0x98
	sub $98
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText44()
	jr MsgViewText44

.start
;> StartText_43()
	ld hl, far_StartText_43
	rst $10
	ret


;@ def MsgViewText44()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $44; group 1 numbers from
;@ $44 on are group 0 of the next bank ($45), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText44::
;>@c if wTextGroup == 1 and wTextIndex >= 0x44:
	ld a, [wTextGroup]
	cp $01
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $44
	jr c, .start

;>     wTextIndex -= 0x44
	sub $44
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText45()
	jr MsgViewText45

.start
;> StartText_44()
	ld hl, far_StartText_44
	rst $10
	ret


;@ def MsgViewText45()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $45.
;@ test: skip calls a routine in another bank
MsgViewText45::
;> StartText_45()
	ld hl, far_StartText_45
	rst $10
	ret


;@ def MsgViewText46()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $46; group 0 numbers from
;@ $C8 on are group 0 of the next bank ($47), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText46::
;>@c if wTextGroup == 0 and wTextIndex >= 0xC8:
	ld a, [wTextGroup]
	cp $00
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $c8
	jr c, .start

;>     wTextIndex -= 0xC8
	sub $c8
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText47()
	jr MsgViewText47

.start
;> StartText_46()
	ld hl, far_StartText_46
	rst $10
	ret


;@ def MsgViewText47()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $47; group 1 numbers from
;@ $74 on are group 0 of the next bank ($48), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText47::
;>@c if wTextGroup == 1 and wTextIndex >= 0x74:
	ld a, [wTextGroup]
	cp $01
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $74
	jr c, .start

;>     wTextIndex -= 0x74
	sub $74
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText48()
	jr MsgViewText48

.start
;> StartText_47()
	ld hl, far_StartText_47
	rst $10
	ret


;@ def MsgViewText48()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $48; group 1 numbers from
;@ $12 on are group 0 of the next bank ($49), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText48::
;>@c if wTextGroup == 1 and wTextIndex >= 0x12:
	ld a, [wTextGroup]
	cp $01
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $12
	jr c, .start

;>     wTextIndex -= 0x12
	sub $12
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText49()
	jr MsgViewText49

.start
;> StartText_48()
	ld hl, far_StartText_48
	rst $10
	ret


;@ def MsgViewText49()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $49; numbers from $CE on (index
;@ + $12 >= $E0) are group 0 of bank $4A.
;@ test: skip calls a routine in another bank
MsgViewText49::
;> if wTextIndex + 0x12 >= 0xE0:
	ld a, [wTextIndex]
	add $12
	cp $e0
	jr c, .start

;>     wTextIndex = wTextIndex + 0x12 - 0xE0
	sub $e0
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText4A()
	jr MsgViewText4A

.start
;> StartText_49()
	ld hl, far_StartText_49
	rst $10
	ret


;@ def MsgViewText4A()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $4A; group 2 numbers from
;@ $C0 on are group 0 of the next bank ($4B), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText4A::
;>@c if wTextGroup == 2 and wTextIndex >= 0xC0:
	ld a, [wTextGroup]
	cp $02
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $c0
	jr c, .start

;>     wTextIndex -= 0xC0
	sub $c0
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText4B()
	jr MsgViewText4B

.start
;> StartText_4A()
	ld hl, far_StartText_4A
	rst $10
	ret


;@ def MsgViewText4B()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $4B; group 1 numbers from
;@ $68 on are group 0 of the next bank ($4E), so the number is counted on there.
;@ test: skip calls a routine in another bank
MsgViewText4B::
;>@c if wTextGroup == 1 and wTextIndex >= 0x68:
	ld a, [wTextGroup]
	cp $01
	jr nz, .start

;=@c
	ld a, [wTextIndex]
	cp $68
	jr c, .start

;>     wTextIndex -= 0x68
	sub $68
	ld [wTextIndex], a
;>     wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>     return MsgViewText4E()
	jr MsgViewText4E

.start
;> StartText_4B()
	ld hl, far_StartText_4B
	rst $10
	ret


;@ def MsgViewText4C()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $4C.
;@ test: skip calls a routine in another bank
MsgViewText4C::
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def MsgViewText4D()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $4D (its far entry 0).
;@ test: skip calls a routine in another bank
MsgViewText4D::
;> StartText_4D()
	ld hl, far_StartText_4D
	rst $10
	ret


;@ def MsgViewText4E()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $4E.
;@ test: skip calls a routine in another bank
MsgViewText4E::
;> StartText_4E()
	ld hl, far_StartText_4E
	rst $10
	ret


;@ def MsgViewText59()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $59 (far entry 6 of bank $59).
;@ test: skip calls a routine in another bank
MsgViewText59::
;> far_call(0x59, 0x06)()
	ld hl, $5906
	rst $10
	ret


;@ def MsgViewText56()
;@ path: system/debug
;@ Message viewer: starts text wTextGroup/wTextIndex from text bank $56 (StartText_56).
;@ test: skip calls a routine in another bank
MsgViewText56::
;> StartText_56()
	ld hl, far_StartText_56
	rst $10
	ret


;@ def MsgViewerCheckStart()
;@ path: system/debug
;@ Holding START leaves the message viewer for the debug menu (game mode $07).
;@ test: wJoyHeld = rand(0, 255)
MsgViewerCheckStart::
;> if wJoyHeld & 0x08:                    # Start
	ld a, [wJoyHeld]
	and $08
	cp $08
	jr nz, .done

;>     wGameMode = 7
	ld a, $07
	ld [wGameMode], a
;>     wGameModeStep = 0
	xor a
	ld [wGameModeStep], a
;>     wGameModeChange += 1
	ld hl, wGameModeChange
	inc [hl]

.done
	ret


;@ def MsgViewerBlink()
;@ path: system/debug
;@ Every 11 frames toggles the chosen row's number between blank tiles ($1F) and its digit tiles.
;@ test: skip polls the LCD
MsgViewerBlink::
;> if wMsgViewBlinkTimer:
	ld a, [wMsgViewBlinkTimer]
	cp $00
	jr nz, .count

;>@c1     wMsgViewBlinkTimer -= 1
;>@c2     return
;> wMsgViewBlinkTimer = 10
	ld a, $0a
	ld [wMsgViewBlinkTimer], a
;> pos = wMsgViewMapHi << 8 | wMsgViewMapLo
	ld a, [wMsgViewMapHi]
	ld h, a
	ld a, [wMsgViewMapLo]
	ld l, a
;> if not wMsgViewBlinkPhase:
	ld a, [wMsgViewBlinkPhase]
	cp $00
	jr nz, .show

;>     WriteVRAM(0x1F, WriteVRAMInc(0x1F, pos))
	ld a, $1f
	call WriteVRAMInc
	call WriteVRAM
;>     wMsgViewBlinkPhase = 1
	ld a, $01
	ld [wMsgViewBlinkPhase], a
	ret

;> else:
.show
;>     WriteVRAM(wMsgViewDigitLo, WriteVRAMInc(wMsgViewDigitHi, pos))
	ld a, [wMsgViewDigitHi]
	call WriteVRAMInc
	ld a, [wMsgViewDigitLo]
	call WriteVRAM
;>     wMsgViewBlinkPhase = 0
	ld a, $00
	ld [wMsgViewBlinkPhase], a
	ret

.count
;=@c1
	dec a
	ld [wMsgViewBlinkTimer], a
;=@c2
	ret


;@ def MsgViewerReadNumber()
;@ path: system/debug
;@ Reads the chosen text number back from its two digit tiles ($70 + hex digit).
;@ test: wMsgViewDigitHi = rand(0x70, 0x7F); wMsgViewDigitLo = rand(0x70, 0x7F)
MsgViewerReadNumber::
;>@n wMsgViewNumber = ((wMsgViewDigitHi - 0x70) << 4 | (wMsgViewDigitHi - 0x70) >> 4) & 0xFF
	ld a, [wMsgViewDigitHi]
	sub $70
	rlca
	rlca
	rlca
	rlca
;=@n
	ld [wMsgViewNumber], a
;>@m wMsgViewNumber = (wMsgViewNumber + wMsgViewDigitLo - 0x70) & 0xFF
	ld a, [wMsgViewDigitLo]
	sub $70
	ld c, a
	ld a, [wMsgViewNumber]
	add c
;=@m
	ld [wMsgViewNumber], a
	ret

;@ path: system/debug
;@ Message viewer, one byte per row (10 pages of 4): the text group the row starts at.
MsgViewRowGroups::
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $00
	db $01, $01, $00, $01, $01, $01, $02, $01, $01, $00, $01, $02, $03, $04, $05, $06
	db $07, $00, $01, $01, $00, $01, $02, $03

;@ path: system/debug
;@ Message viewer: for each row the text bank routine (0 = $41, 1 = $42, ... see MsgViewerInput's
;@ table) that shows it.
MsgViewRowBanks::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
	db $02, $03, $05, $06, $07, $09, $09, $0a, $0d, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0c, $0c, $0f, $0e, $0e, $0e, $0e

;@ path: system/debug
;@ Message viewer: for each row the highest text number it has.
MsgViewRowCounts::
	db $09, $5f, $6f, $9f, $0a, $ff, $ff, $d6, $2b, $2b, $27, $24, $01, $2f, $0b, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d8, $ff, $fd, $12, $06, $08, $03, $14, $14
	db $00, $ff, $d6, $ff, $06, $02, $0d, $00

;@ path: text/dialogue
;@ Texts of bank $56 (game's character set, control codes at TextControlCodes): the message
;@ viewer's title and page names ("MESSAGE DEBUG", the text table names) and further texts,
;@ reached through TextTable_56.
Bank56Texts::
	db $96, $62, $30, $28, $36, $36, $28, $2a, $28, $f1, $62, $62, $62, $62, $62, $27
	db $28, $25, $38, $2a, $62, $97, $f1, $62, $62, $37, $28, $36, $37, $30, $28, $36
	db $f1, $27, $28, $25, $38, $2a, $31, $24, $30, $28, $f1, $62, $62, $62, $36, $3c
	db $36, $30, $28, $36, $f1, $62, $30, $31, $24, $30, $28, $30, $28, $36, $f1, $00
	db $01, $02, $03, $04, $05, $06, $07, $08, $09, $24, $25, $26, $27, $28, $29, $62
	db $2e, $28, $2c, $37, $32, $38, $30, $28, $36, $f1, $36, $3c, $38, $3d, $32, $2e
	db $38, $30, $28, $36, $f1, $37, $32, $2e, $38, $2a, $2c, $31, $24, $30, $28, $f1
	db $62, $62, $62, $36, $3c, $38, $31, $24, $30, $28, $f0, $62, $62, $2c, $37, $28
	db $30, $31, $24, $30, $28, $f1, $62, $62, $62, $2c, $37, $28, $30, $30, $28, $36
	db $f1, $36, $28, $2c, $2e, $24, $2e, $38, $30, $28, $36, $f1, $62, $25, $37, $2f
	db $3a, $2c, $31, $30, $28, $36, $f0, $62, $25, $24, $37, $37, $2f, $28, $30, $28
	db $36, $f1, $62, $62, $2c, $37, $28, $30, $30, $28, $36, $02, $f1, $37, $32, $2e
	db $38, $2a, $38, $30, $28, $36, $02, $f1, $2e, $24, $2c, $3a, $24, $30, $28, $36
	db $00, $00, $f0, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $01, $f1, $2e, $24
	db $2c, $3a, $24, $30, $28, $36, $00, $02, $f1, $2e, $24, $2c, $3a, $24, $30, $28
	db $36, $00, $03, $f1, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $04, $f0, $2e
	db $24, $2c, $3a, $24, $30, $28, $36, $00, $05, $f1, $2e, $24, $2c, $3a, $24, $30
	db $28, $36, $00, $06, $f1, $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $07, $f1
	db $2e, $24, $2c, $3a, $24, $30, $28, $36, $00, $08, $f0, $2e, $24, $2c, $3a, $24
	db $30, $28, $36, $00, $09, $f1, $62, $62, $62, $62, $25, $37, $2f, $30, $28, $36
	db $f1, $62, $62, $62, $25, $37, $2f, $30, $28, $36, $01, $f1, $62, $62, $62, $25
	db $37, $2f, $30, $28, $36, $02, $f0, $62, $62, $62, $25, $37, $2f, $26, $30, $27
	db $f1, $62, $62, $25, $37, $2f, $30, $28, $36, $04, $f1, $36, $37, $24, $29, $29
	db $30, $28, $36, $00, $f1, $36, $37, $24, $29, $29, $30, $28, $36, $01, $f0, $28
	db $31, $27, $2c, $31, $2a, $30, $28, $36, $f1, $30, $32, $31, $2b, $24, $2c, $30
	db $28, $36, $f1, $30, $32, $31, $2c, $31, $29, $30, $28, $36, $f1, $37, $32, $2e
	db $38, $2a, $2c, $30, $28, $36, $f0, $62, $27, $28, $30, $32, $30, $28, $36, $00
	db $00, $f1, $27, $28, $30, $32, $31, $24, $30, $28, $00, $00, $f1, $62, $25, $32
	db $32, $2e, $30, $28, $36, $00, $00, $f1, $62, $32, $25, $2d, $37, $30, $28, $36
	db $00, $00, $f0, $2c, $31, $39, $24, $2f, $2c, $27, $62, $31, $38, $30, $25, $28
	db $35, $63, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $f1, $54, $46, $51, $45, $62, $3e, $62, $50, $4a, $3e, $49, $49, $62
	db $43, $46, $4f, $42, $f1, $3f, $3e, $49, $49, $f0, $2c, $4b, $43, $49, $46, $40
	db $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $54, $46, $51, $45, $62, $3e
	db $62, $44, $46, $3e, $4b, $51, $f1, $43, $46, $4f, $42, $62, $3f, $3e, $49, $49
	db $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42
	db $f1, $54, $46, $51, $45, $62, $4d, $46, $49, $49, $3e, $4f, $50, $62, $4c, $43
	db $f1, $43, $46, $4f, $42, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41
	db $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42, $4b, $42
	db $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $3e, $62, $50, $4a, $3e, $49
	db $49, $62, $3f, $49, $3e, $57, $42, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50
	db $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42
	db $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $3e, $62, $45, $52
	db $44, $42, $62, $3f, $49, $3e, $57, $42, $f0, $2c, $4b, $43, $49, $46, $40, $51
	db $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62
	db $51, $45, $42, $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51, $45
	db $62, $3e, $62, $3f, $46, $44, $62, $3f, $49, $3e, $57, $42, $f0, $2c, $4b, $43
	db $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1
	db $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45
	db $f1, $3e, $4b, $62, $42, $55, $4d, $49, $4c, $50, $46, $4c, $4b, $f0, $2c, $4b
	db $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c
	db $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51
	db $45, $f1, $42, $55, $4d, $49, $4c, $50, $46, $4c, $4b, $50, $f0, $2c, $4b, $43
	db $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1
	db $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45
	db $f1, $3e, $62, $2b, $38, $2a, $28, $62, $42, $55, $4d, $49, $4c, $50, $46, $4c
	db $4b, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44
	db $42, $50, $f1, $51, $4c, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f1, $54, $46, $51, $45, $62, $3e, $62, $54, $45, $46, $4f, $49, $54, $46
	db $4b, $41, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $50, $f1, $51, $4c, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46
	db $42, $50, $f1, $54, $46, $51, $45, $62, $3e, $62, $51, $4c, $4f, $4b, $3e, $41
	db $4c, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44
	db $42, $50, $f1, $51, $4c, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f1, $54, $46, $51, $45, $62, $3e, $62, $45, $52, $4f, $4f, $46, $40, $3e
	db $4b, $42, $f0, $29, $4f, $42, $42, $57, $42, $50, $62, $3e, $49, $49, $f1, $42
	db $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $62, $46, $40, $42, $f0
	db $37, $52, $4f, $4b, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f1, $46, $4b, $51, $4c, $62, $46, $40, $42, $f0, $24, $51, $51, $3e, $40
	db $48, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54
	db $46, $51, $45, $62, $3e, $f1, $43, $4f, $46, $44, $46, $41, $62, $3f, $49, $46
	db $57, $57, $3e, $4f, $41, $f0, $36, $51, $4f, $46, $48, $42, $50, $62, $3e, $49
	db $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $49
	db $46, $44, $45, $51, $4b, $46, $4b, $44, $f0, $36, $51, $4f, $46, $48, $42, $50
	db $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51
	db $45, $f1, $3e, $62, $51, $45, $52, $4b, $41, $42, $4f, $3f, $4c, $49, $51, $f0
	db $36, $51, $4f, $46, $48, $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a
	db $46, $42, $50, $62, $54, $46, $51, $45, $f1, $51, $45, $52, $4b, $41, $42, $4f
	db $3f, $4c, $49, $51, $50, $f0, $2c, $4b, $50, $51, $3e, $4b, $51, $49, $56, $62
	db $48, $4b, $4c, $40, $48, $50, $f1, $4c, $52, $51, $62, $3e, $4b, $62, $42, $4b
	db $42, $4a, $56, $f0, $2c, $4b, $50, $51, $3e, $4b, $51, $49, $56, $62, $48, $4b
	db $4c, $40, $48, $50, $f1, $4c, $52, $51, $62, $3e, $49, $49, $62, $42, $4b, $42
	db $4a, $46, $42, $50, $f0, $2e, $4b, $4c, $40, $48, $50, $62, $4c, $52, $51, $62
	db $51, $45, $42, $f1, $40, $3e, $50, $51, $42, $4f, $62, $3e, $4b, $41, $f1, $3e
	db $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $33, $52, $51, $50, $62
	db $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f1, $51, $4c, $62, $50, $49, $42, $42
	db $4d, $f0, $33, $52, $51, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46
	db $42, $50, $f1, $51, $4c, $62, $50, $49, $42, $42, $4d, $f0, $36, $52, $50, $4d
	db $42, $4b, $41, $50, $62, $3e, $49, $49, $62, $51, $45, $42, $f1, $42, $4b, $42
	db $4a, $46, $42, $50, $62, $43, $4f, $4c, $4a, $f1, $40, $3e, $50, $51, $46, $4b
	db $44, $62, $50, $4d, $42, $49, $49, $50, $f0, $28, $4b, $44, $52, $49, $43, $50
	db $62, $3e, $49, $49, $62, $51, $45, $42, $f1, $42, $4b, $42, $4a, $46, $42, $50
	db $62, $54, $46, $51, $45, $62, $3e, $4b, $f1, $46, $49, $49, $52, $50, $46, $4c
	db $4b, $f0, $26, $4c, $4b, $43, $52, $50, $42, $50, $62, $3e, $49, $49, $f1, $42
	db $4b, $42, $4a, $46, $42, $50, $f0, $36, $51, $42, $3e, $49, $50, $62, $42, $4b
	db $42, $4a, $56, $68, $62, $30, $33, $f0, $24, $3f, $50, $4c, $4f, $3f, $50, $62
	db $51, $45, $42, $62, $30, $33, $62, $4c, $43, $f1, $3e, $62, $50, $4d, $42, $49
	db $49, $62, $40, $3e, $50, $51, $62, $3f, $56, $f1, $3e, $4b, $62, $42, $4b, $42
	db $4a, $56, $f0, $2f, $4c, $54, $42, $4f, $50, $62, $3e, $4b, $f1, $42, $4b, $42
	db $4a, $56, $68, $62, $27, $28, $29, $28, $31, $36, $28, $f0, $2f, $4c, $54, $42
	db $4f, $50, $62, $3e, $49, $49, $62, $51, $45, $42, $f1, $42, $4b, $42, $4a, $46
	db $42, $50, $5c, $62, $27, $28, $29, $28, $31, $36, $28, $f0, $2c, $4b, $40, $4f
	db $42, $3e, $50, $42, $50, $62, $27, $28, $29, $28, $31, $36, $28, $f1, $43, $4c
	db $4f, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $2c, $4b, $40, $4f, $42, $3e
	db $50, $42, $50, $62, $27, $28, $29, $28, $31, $36, $28, $f1, $43, $4c, $4f, $62
	db $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $27, $42, $40, $4f, $42
	db $3e, $50, $42, $50, $62, $24, $2a, $2c, $2f, $2c, $37, $3c, $f1, $4c, $43, $62
	db $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f0, $27, $42, $40, $4f, $42, $3e, $50
	db $42, $50, $62, $24, $2a, $2c, $2f, $2c, $37, $3c, $f1, $4c, $43, $62, $3e, $49
	db $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $2c, $4b, $40, $4f, $42, $3e
	db $50, $42, $50, $62, $24, $2a, $2c, $2f, $2c, $37, $3c, $f1, $43, $4c, $4f, $62
	db $3e, $4b, $62, $3e, $49, $49, $56, $f0, $2c, $4b, $40, $4f, $42, $3e, $50, $42
	db $50, $62, $24, $2a, $2c, $2f, $2c, $37, $3c, $f1, $43, $4c, $4f, $62, $3e, $49
	db $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $24, $49, $49, $62, $3e, $49, $49
	db $46, $42, $50, $62, $3f, $42, $40, $4c, $4a, $42, $f1, $4a, $4c, $4f, $42, $62
	db $4f, $42, $50, $46, $50, $51, $3e, $4b, $51, $62, $51, $4c, $f1, $3f, $4f, $42
	db $3e, $51, $45, $62, $3e, $51, $51, $3e, $40, $48, $50, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $41, $4c, $52, $3f, $49, $42, $f1, $51, $45, $42, $62
	db $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1, $3e, $4b, $62, $42, $4b, $42
	db $4a, $56, $f0, $2c, $4b, $40, $4f, $42, $3e, $50, $42, $50, $f1, $4f, $42, $50
	db $46, $50, $51, $3e, $4b, $40, $42, $62, $51, $4c, $f1, $51, $45, $42, $62, $42
	db $4b, $42, $4a, $56, $62, $50, $4d, $42, $49, $49, $50, $f0, $35, $42, $43, $49
	db $42, $40, $51, $50, $62, $51, $45, $42, $62, $4a, $3e, $44, $46, $40, $f1, $40
	db $3e, $50, $51, $62, $3f, $56, $62, $51, $45, $42, $62, $42, $4b, $42, $4a, $56
	db $f1, $43, $4c, $4f, $62, $4c, $4b, $42, $62, $51, $52, $4f, $4b, $f0, $35, $42
	db $43, $49, $42, $40, $51, $50, $62, $51, $45, $42, $62, $42, $4b, $42, $4a, $56
	db $f1, $50, $4d, $42, $49, $49, $50, $62, $51, $45, $3e, $51, $62, $51, $45, $42
	db $f1, $40, $3e, $50, $51, $42, $4f, $62, $4f, $42, $40, $42, $46, $53, $42, $50
	db $f0, $37, $4f, $3e, $4b, $50, $43, $4c, $4f, $4a, $62, $46, $4b, $51, $4c, $f1
	db $51, $45, $42, $62, $50, $3e, $4a, $42, $62, $50, $4d, $42, $40, $46, $42, $50
	db $f1, $3e, $50, $62, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $f0, $37, $52
	db $4f, $4b, $50, $62, $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f1, $46
	db $4b, $51, $4c, $62, $3e, $62, $4d, $4f, $4c, $51, $42, $40, $51, $46, $53, $42
	db $f1, $49, $52, $4a, $4d, $62, $4c, $43, $62, $46, $4f, $4c, $4b, $f0, $2b, $42
	db $3e, $49, $50, $62, $3f, $42, $51, $54, $42, $42, $4b, $f1, $03, $00, $62, $51
	db $4c, $62, $04, $00, $62, $2b, $33, $62, $43, $4c, $4f, $62, $3e, $4b, $f1, $3e
	db $49, $49, $56, $f0, $2b, $42, $3e, $49, $50, $62, $3f, $42, $51, $54, $42, $42
	db $4b, $f1, $07, $05, $62, $3e, $4b, $41, $62, $09, $00, $62, $2b, $33, $62, $43
	db $4c, $4f, $f1, $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $2b, $42
	db $3e, $49, $50, $62, $2b, $33, $62, $51, $4c, $62, $4a, $3e, $55, $f1, $43, $4c
	db $4f, $62, $3e, $4b, $62, $3e, $49, $49, $56, $f0, $2b, $42, $3e, $49, $50, $62
	db $3f, $42, $51, $54, $42, $42, $4b, $f1, $09, $00, $62, $51, $4c, $62, $01, $02
	db $00, $62, $2b, $33, $62, $43, $4c, $4f, $f1, $3e, $49, $49, $62, $3e, $49, $49
	db $46, $42, $50, $f0, $2b, $42, $3e, $49, $50, $62, $2b, $33, $62, $51, $4c, $62
	db $4a, $3e, $55, $f1, $43, $4c, $4f, $62, $3e, $49, $49, $62, $3e, $49, $49, $46
	db $42, $50, $f0, $35, $42, $53, $46, $53, $42, $50, $62, $3e, $4b, $62, $3e, $49
	db $49, $56, $f0, $35, $42, $53, $46, $53, $42, $50, $62, $3e, $4b, $62, $3e, $49
	db $49, $56, $f0, $35, $42, $53, $46, $53, $42, $50, $62, $3e, $49, $49, $62, $4c
	db $51, $45, $42, $4f, $f1, $3e, $49, $49, $46, $42, $50, $62, $3f, $52, $51, $62
	db $51, $45, $42, $f1, $40, $3e, $50, $51, $42, $4f, $62, $40, $4c, $49, $49, $3e
	db $4d, $50, $42, $50, $f0, $26, $52, $4f, $42, $50, $62, $4d, $4c, $46, $50, $4c
	db $4b, $f0, $26, $52, $4f, $42, $50, $62, $4d, $3e, $4f, $3e, $49, $56, $50, $46
	db $50, $f1, $4c, $4f, $62, $54, $3e, $48, $42, $50, $62, $52, $4d, $f1, $3e, $4b
	db $62, $3e, $49, $49, $56, $f0, $26, $52, $4f, $42, $50, $62, $40, $4c, $4b, $43
	db $52, $50, $46, $4c, $4b, $f0, $25, $4f, $42, $3e, $48, $50, $62, $3e, $62, $40
	db $52, $4f, $50, $42, $f0, $33, $4f, $4c, $51, $42, $40, $51, $50, $62, $43, $4f
	db $4c, $4a, $f1, $49, $3e, $4b, $41, $62, $45, $3e, $57, $3e, $4f, $41, $50, $f1
	db $54, $45, $46, $49, $42, $62, $51, $4f, $3e, $53, $42, $49, $46, $4b, $44, $f0
	db $35, $42, $53, $42, $3e, $49, $50, $62, $51, $45, $42, $62, $42, $4b, $51, $46
	db $4f, $42, $f1, $4a, $3e, $4d, $62, $4c, $43, $62, $51, $45, $42, $f1, $49, $3e
	db $4b, $41, $50, $40, $3e, $4d, $42, $f0, $24, $62, $4f, $3e, $4b, $41, $4c, $4a
	db $62, $50, $4d, $42, $49, $49, $5e, $f1, $40, $3e, $4b, $62, $3f, $42, $62, $44
	db $4c, $4c, $41, $62, $4c, $4f, $62, $3f, $3e, $41, $f0, $f0, $29, $42, $3e, $4f
	db $49, $42, $50, $50, $62, $3e, $51, $51, $3e, $40, $48, $f0, $24, $51, $51, $3e
	db $40, $48, $50, $62, $49, $46, $48, $42, $62, $3e, $62, $4f, $3e, $4a, $f1, $54
	db $46, $51, $45, $62, $46, $51, $50, $62, $51, $4f, $52, $42, $f1, $46, $4b, $4b
	db $42, $4f, $62, $50, $51, $4f, $42, $4b, $44, $51, $45, $f0, $24, $51, $51, $3e
	db $40, $48, $50, $62, $49, $46, $48, $42, $62, $51, $45, $42, $4f, $42, $f1, $46
	db $50, $62, $4b, $4c, $62, $51, $4c, $4a, $4c, $4f, $4f, $4c, $54, $f0, $24, $62
	db $50, $52, $46, $40, $46, $41, $42, $62, $3e, $51, $51, $3e, $40, $48, $f1, $51
	db $4c, $62, $48, $4b, $4c, $40, $48, $62, $4c, $52, $51, $62, $51, $45, $42, $f1
	db $42, $4b, $42, $4a, $56, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44
	db $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3e
	db $4b, $62, $3e, $49, $49, $56, $f1, $4c, $4f, $62, $3e, $4b, $62, $42, $4b, $42
	db $4a, $56, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $49, $46, $48, $42, $62
	db $3e, $f1, $4f, $52, $51, $45, $49, $42, $50, $50, $62, $41, $42, $4a, $4c, $4b
	db $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $45, $52, $44, $42, $f1, $41
	db $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $3e, $4b, $62, $42, $4b, $42, $4a
	db $56, $f1, $4c, $4b, $62, $51, $45, $42, $62, $4b, $42, $55, $51, $62, $51, $52
	db $4f, $4b, $f0, $2d, $52, $4a, $4d, $50, $62, $46, $4b, $51, $4c, $62, $51, $45
	db $42, $62, $3e, $46, $4f, $f1, $3e, $4b, $41, $62, $3e, $51, $51, $3e, $40, $48
	db $50, $62, $4c, $4b, $f1, $51, $45, $42, $62, $4b, $42, $55, $51, $62, $51, $52
	db $4f, $4b, $f0, $36, $52, $40, $48, $50, $62, $46, $4b, $62, $3e, $46, $4f, $62
	db $4d, $4c, $54, $42, $4f, $f1, $51, $4c, $62, $46, $4b, $43, $49, $46, $40, $51
	db $62, $41, $3e, $4a, $3e, $44, $42, $f1, $4c, $4b, $62, $51, $45, $42, $62, $4b
	db $42, $55, $51, $62, $51, $52, $4f, $4b, $f0, $25, $52, $4f, $4b, $46, $4b, $44
	db $62, $3f, $49, $3e, $41, $42, $f1, $50, $54, $4c, $4f, $41, $62, $3e, $51, $51
	db $3e, $40, $48, $f0, $37, $45, $52, $4b, $41, $42, $4f, $3f, $4c, $49, $51, $f1
	db $50, $54, $4c, $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0, $3a, $45, $46
	db $4f, $49, $46, $4b, $44, $62, $53, $3e, $40, $52, $52, $4a, $f1, $50, $54, $4c
	db $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0, $29, $4f, $42, $42, $57, $46
	db $4b, $44, $62, $46, $40, $42, $f1, $50, $54, $4c, $4f, $41, $62, $3e, $51, $51
	db $3e, $40, $48, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42
	db $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $62, $4a, $42, $51
	db $3e, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $2c, $4b, $43, $49, $46
	db $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42
	db $62, $51, $4c, $62, $41, $4f, $3e, $44, $4c, $4b, $50, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44
	db $42, $62, $51, $4c, $62, $3f, $42, $3e, $50, $51, $50, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44
	db $42, $62, $51, $4c, $62, $3f, $46, $4f, $41, $50, $f0, $2c, $4b, $43, $49, $46
	db $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42
	db $62, $4c, $4b, $62, $41, $42, $53, $46, $49, $50, $f0, $2c, $4b, $43, $49, $46
	db $40, $51, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42, $62
	db $51, $4c, $62, $57, $4c, $4a, $3f, $46, $42, $50, $f0, $2c, $4b, $43, $49, $46
	db $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44, $42
	db $62, $51, $4c, $f1, $4a, $3e, $51, $42, $4f, $46, $3e, $49, $50, $f0, $2c, $4b
	db $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $51, $4c
	db $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51
	db $45, $62, $4a, $3e, $4b, $56, $62, $40, $52, $51, $50, $f0, $24, $51, $51, $3e
	db $40, $48, $50, $62, $51, $54, $46, $40, $42, $62, $46, $4b, $f1, $4c, $4b, $42
	db $62, $51, $52, $4f, $4b, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $04, $62
	db $51, $46, $4a, $42, $50, $f1, $46, $4b, $62, $4c, $4b, $42, $62, $51, $52, $4f
	db $4b, $f0, $26, $3e, $49, $49, $50, $62, $43, $4c, $4f, $62, $3e, $62, $3f, $3e
	db $40, $48, $52, $4d, $f0, $26, $3e, $49, $49, $50, $62, $3e, $62, $44, $4f, $4c
	db $52, $4d, $62, $4c, $43, $f1, $4a, $4c, $4b, $50, $51, $42, $4f, $50, $62, $43
	db $4c, $4f, $62, $45, $42, $49, $4d, $f0, $37, $54, $4c, $62, $3e, $51, $51, $3e
	db $40, $48, $50, $f1, $4c, $4b, $62, $51, $45, $42, $62, $4b, $42, $55, $51, $f1
	db $51, $52, $4f, $4b, $f0, $24, $49, $49, $4c, $54, $50, $62, $56, $4c, $52, $62
	db $51, $4c, $f1, $3e, $51, $51, $3e, $40, $48, $62, $43, $46, $4f, $50, $51, $f1
	db $46, $4b, $62, $51, $45, $42, $62, $51, $52, $4f, $4b, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $2a, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44
	db $42, $62, $51, $4c, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f1, $3e, $51
	db $62, $51, $45, $42, $62, $49, $3e, $50, $51, $62, $51, $52, $4f, $4b, $f0, $24
	db $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46
	db $42, $50, $62, $46, $4b, $62, $4c, $4b, $42, $f1, $3e, $51, $51, $3e, $40, $48
	db $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a
	db $56, $f1, $54, $46, $51, $45, $62, $3e, $62, $53, $46, $4c, $49, $42, $4b, $51
	db $f1, $54, $45, $46, $4f, $49, $54, $46, $4b, $41, $f0, $24, $51, $51, $3e, $40
	db $48, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54
	db $46, $51, $45, $62, $3e, $f1, $44, $46, $3e, $4b, $51, $62, $53, $3e, $40, $52
	db $52, $4a, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $62, $4c, $4b, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $62, $54, $46, $51, $45, $f1, $49, $46, $44, $45, $51, $4b, $46, $4b, $44
	db $f0, $37, $45, $4f, $4c, $54, $50, $62, $3e, $62, $45, $52, $44, $42, $62, $4f
	db $4c, $40, $48, $f1, $4c, $4b, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46
	db $42, $50, $f0, $25, $4f, $42, $3e, $51, $45, $42, $50, $62, $4c, $52, $51, $62
	db $43, $46, $4f, $42, $f1, $51, $4c, $62, $46, $4b, $43, $49, $46, $40, $51, $62
	db $41, $3e, $4a, $3e, $44, $42, $f1, $4c, $4b, $62, $3e, $49, $49, $62, $42, $4b
	db $42, $4a, $46, $42, $50, $f0, $25, $49, $4c, $54, $50, $62, $4c, $52, $51, $62
	db $3e, $62, $3f, $49, $3e, $57, $42, $f1, $51, $4c, $62, $46, $4b, $43, $49, $46
	db $40, $51, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $4c, $4b, $62, $3e, $49, $49
	db $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $25, $52, $4f, $4b, $50, $62, $3e
	db $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51, $45, $62
	db $3e, $62, $41, $42, $53, $3e, $50, $51, $3e, $51, $46, $4b, $44, $f1, $43, $49
	db $3e, $4a, $42, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49, $f1
	db $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $62, $3e, $4b, $f1
	db $52, $4b, $46, $4a, $3e, $44, $46, $4b, $3e, $3f, $49, $42, $62, $3f, $49, $3e
	db $57, $42, $f0, $2c, $4b, $43, $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e
	db $44, $42, $62, $51, $4c, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $62, $54, $46, $51, $45, $f1, $46, $51, $50, $62, $43, $4f, $46, $44, $46
	db $41, $62, $3f, $4f, $42, $3e, $51, $45, $f0, $29, $4f, $42, $42, $57, $42, $50
	db $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $2c, $4b, $43
	db $49, $46, $40, $51, $50, $62, $41, $3e, $4a, $3e, $44, $42, $62, $51, $4c, $f1
	db $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45
	db $62, $3e, $f1, $53, $46, $4c, $49, $42, $4b, $51, $62, $46, $40, $42, $62, $50
	db $51, $4c, $4f, $4a, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49
	db $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $62, $3e, $4b
	db $f1, $46, $4b, $40, $3e, $4b, $41, $42, $50, $40, $42, $4b, $51, $62, $3e, $46
	db $4f, $f0, $2b, $42, $49, $49, $62, $4d, $4c, $54, $42, $4f, $42, $41, $f1, $49
	db $46, $44, $45, $51, $4b, $46, $4b, $44, $62, $3f, $49, $3e, $50, $51, $f1, $3e
	db $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49, $62, $43, $4c, $42, $50, $f0
	db $26, $4f, $42, $3e, $51, $42, $50, $62, $3e, $62, $45, $52, $44, $42, $f1, $42
	db $55, $4d, $49, $4c, $50, $46, $4c, $4b, $62, $51, $4c, $f1, $3e, $51, $51, $3e
	db $40, $48, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $37
	db $45, $42, $62, $4a, $4c, $50, $51, $62, $4d, $4c, $54, $42, $4f, $43, $52, $49
	db $f1, $50, $4d, $42, $49, $49, $62, $51, $45, $3e, $51, $62, $3e, $43, $43, $42
	db $40, $51, $50, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0
	db $33, $4c, $46, $50, $4c, $4b, $50, $62, $51, $45, $42, $62, $42, $4b, $42, $4a
	db $56, $f1, $51, $45, $3e, $51, $62, $3e, $51, $51, $3e, $40, $48, $42, $41, $62
	db $51, $45, $42, $f1, $3e, $49, $49, $56, $f0, $36, $42, $4b, $41, $50, $62, $51
	db $45, $42, $62, $42, $4b, $42, $4a, $56, $f1, $51, $45, $3e, $51, $62, $3e, $51
	db $51, $3e, $40, $48, $42, $41, $f1, $51, $45, $42, $62, $3e, $49, $49, $56, $62
	db $51, $4c, $62, $50, $49, $42, $42, $4d, $f0, $33, $3e, $4f, $3e, $49, $56, $57
	db $42, $50, $62, $51, $45, $42, $f1, $42, $4b, $42, $4a, $56, $62, $51, $45, $3e
	db $51, $f1, $3e, $51, $51, $3e, $40, $48, $42, $41, $62, $51, $45, $42, $62, $3e
	db $49, $49, $56, $f0, $36, $42, $4b, $41, $62, $3e, $49, $49, $62, $42, $4b, $42
	db $4a, $46, $42, $50, $f1, $51, $4c, $62, $50, $49, $42, $42, $4d, $f0, $33, $3e
	db $4f, $3e, $49, $56, $57, $42, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a
	db $46, $42, $50, $f0, $33, $4c, $46, $50, $4c, $4b, $50, $62, $3e, $49, $49, $f1
	db $42, $4b, $42, $4a, $46, $42, $50, $f0, $36, $42, $53, $42, $4f, $49, $56, $62
	db $4d, $4c, $46, $50, $4c, $4b, $50, $f1, $3e, $49, $49, $62, $42, $4b, $42, $4a
	db $46, $42, $50, $f0, $26, $4c, $4b, $43, $52, $50, $42, $50, $62, $3e, $49, $49
	db $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $26, $52, $4f, $50, $42, $50, $62
	db $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $30, $3e, $48, $42
	db $50, $62, $56, $4c, $52, $62, $43, $42, $42, $49, $f1, $45, $3e, $4d, $4d, $56
	db $f0, $2c, $4b, $50, $51, $3e, $4b, $51, $49, $56, $62, $48, $4b, $4c, $40, $48
	db $50, $f1, $4c, $52, $51, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f0, $24, $51, $51, $3e, $40, $48, $50, $62, $3e, $49, $49, $f1, $42, $4b
	db $42, $4a, $46, $42, $50, $62, $54, $46, $51, $45, $f1, $3e, $62, $50, $3e, $4b
	db $41, $50, $51, $4c, $4f, $4a, $f0, $25, $49, $46, $4b, $41, $50, $62, $3e, $49
	db $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f1, $54, $46, $51, $45, $62, $46
	db $51, $50, $62, $3f, $4f, $46, $44, $45, $51, $f1, $49, $46, $44, $45, $51, $f0
	db $30, $3e, $48, $42, $50, $62, $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42
	db $50, $f1, $49, $42, $50, $50, $62, $4f, $42, $50, $46, $50, $51, $3e, $4b, $51
	db $f1, $51, $4c, $62, $4a, $3e, $44, $46, $40, $62, $50, $4d, $42, $49, $49, $50
	db $f0, $27, $4f, $4c, $4d, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $68
	db $f1, $30, $33, $62, $54, $46, $51, $45, $62, $46, $51, $50, $62, $4c, $41, $41
	db $f1, $41, $3e, $4b, $40, $46, $4b, $44, $62, $50, $51, $42, $4d, $50, $f0, $36
	db $51, $42, $3e, $49, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56, $68, $f1
	db $30, $33, $62, $54, $46, $51, $45, $62, $46, $51, $50, $f1, $4a, $42, $50, $4a
	db $42, $4f, $46, $57, $46, $4b, $44, $62, $41, $3e, $4b, $40, $42, $f0, $36, $46
	db $41, $42, $50, $51, $42, $4d, $50, $62, $3e, $4b, $f1, $3e, $51, $51, $3e, $40
	db $48, $f0, $2f, $52, $4f, $42, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a, $56
	db $62, $51, $4c, $f1, $3e, $62, $51, $4f, $3e, $4d, $62, $54, $46, $51, $45, $62
	db $46, $51, $50, $f1, $41, $3e, $4b, $40, $42, $f0, $2f, $46, $40, $48, $50, $62
	db $3e, $4b, $62, $42, $4b, $42, $4a, $56, $f1, $51, $4c, $62, $50, $51, $4c, $4d
	db $62, $46, $51, $62, $43, $4f, $4c, $4a, $f1, $3e, $51, $51, $3e, $40, $48, $46
	db $4b, $44, $f0, $2f, $4c, $54, $42, $4f, $50, $62, $27, $28, $29, $28, $31, $36
	db $28, $f1, $3f, $56, $62, $44, $46, $53, $46, $4b, $44, $62, $3e, $4b, $62, $42
	db $4b, $42, $4a, $56, $f1, $3e, $62, $50, $46, $40, $48, $49, $56, $62, $49, $46
	db $40, $48, $f0, $37, $4f, $46, $4d, $50, $62, $3e, $4b, $62, $42, $4b, $42, $4a
	db $56, $62, $3f, $56, $f1, $50, $54, $42, $42, $4d, $46, $4b, $44, $62, $46, $51
	db $50, $62, $49, $42, $44, $50, $f0, $37, $4f, $46, $4d, $50, $62, $3e, $49, $49
	db $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $29, $4f, $42, $42, $57, $42, $50
	db $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $62, $54, $46, $51
	db $45, $62, $3e, $f1, $53, $42, $4f, $56, $62, $49, $4c, $52, $41, $62, $4f, $4c
	db $3e, $4f, $f0, $36, $52, $4a, $4a, $4c, $4b, $50, $62, $4a, $4c, $4b, $50, $51
	db $42, $4f, $50, $f0, $2c, $4a, $46, $51, $3e, $51, $42, $50, $62, $51, $45, $42
	db $f1, $42, $4b, $42, $4a, $56, $68, $62, $3e, $51, $51, $3e, $40, $48, $f0, $27
	db $46, $50, $4d, $42, $49, $50, $62, $4a, $3e, $44, $46, $40, $f1, $42, $43, $43
	db $42, $40, $51, $50, $62, $4c, $4b, $62, $3e, $49, $49, $f1, $3e, $49, $49, $46
	db $42, $50, $f0, $26, $52, $4f, $42, $50, $62, $3e, $4b, $56, $62, $3e, $46, $49
	db $4a, $42, $4b, $51, $50, $f1, $43, $4c, $4f, $62, $3e, $49, $49, $62, $3e, $49
	db $49, $46, $42, $50, $f0, $2a, $4f, $42, $3e, $51, $49, $56, $62, $54, $42, $3e
	db $48, $42, $4b, $50, $f1, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $f0, $26
	db $4f, $42, $3e, $51, $42, $50, $62, $3e, $62, $51, $45, $46, $40, $48, $f1, $43
	db $4c, $44, $62, $51, $4c, $62, $50, $52, $50, $4d, $42, $4b, $41, $f1, $4a, $3e
	db $44, $46, $40, $62, $50, $4d, $42, $49, $49, $50, $f0, $36, $52, $4a, $4a, $4c
	db $4b, $50, $62, $37, $3e, $51, $50, $52, $f1, $4a, $4c, $4b, $50, $51, $42, $4f
	db $50, $62, $51, $4c, $62, $3e, $51, $51, $3e, $40, $48, $f1, $51, $45, $42, $62
	db $42, $4b, $42, $4a, $56, $f0, $36, $52, $4a, $4a, $4c, $4b, $50, $62, $27, $46
	db $3e, $44, $4c, $f1, $4a, $4c, $4b, $50, $51, $42, $4f, $50, $62, $51, $4c, $62
	db $3e, $51, $51, $3e, $40, $48, $f1, $51, $45, $42, $62, $42, $4b, $42, $4a, $56
	db $f0, $36, $52, $4a, $4a, $4c, $4b, $50, $62, $36, $3e, $4a, $50, $46, $f1, $4a
	db $4c, $4b, $50, $51, $42, $4f, $50, $62, $51, $4c, $62, $3e, $51, $51, $3e, $40
	db $48, $f1, $51, $45, $42, $62, $42, $4b, $42, $4a, $56, $f0, $36, $52, $4a, $4a
	db $4c, $4b, $50, $62, $25, $3e, $57, $4c, $4c, $f1, $4a, $4c, $4b, $50, $51, $42
	db $4f, $50, $62, $51, $4c, $62, $3e, $51, $51, $3e, $40, $48, $f1, $51, $45, $42
	db $62, $42, $4b, $42, $4a, $56, $f0, $37, $45, $4f, $4c, $54, $50, $62, $46, $51
	db $50, $42, $49, $43, $62, $46, $4b, $f1, $43, $4f, $4c, $4b, $51, $62, $4c, $43
	db $62, $51, $45, $42, $f1, $3e, $51, $51, $3e, $40, $48, $62, $43, $4c, $4f, $62
	db $3e, $4b, $62, $3e, $49, $49, $56, $f0, $37, $3e, $48, $42, $50, $62, $3e, $49
	db $49, $62, $51, $45, $42, $f1, $3e, $51, $51, $3e, $40, $48, $50, $62, $43, $4f
	db $4c, $4a, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $35
	db $42, $43, $49, $42, $40, $51, $50, $62, $3f, $3e, $40, $48, $62, $24, $46, $4f
	db $f1, $3e, $51, $51, $3e, $40, $48, $62, $51, $4c, $62, $3e, $4b, $62, $42, $4b
	db $42, $4a, $56, $f0, $35, $42, $43, $49, $42, $40, $51, $50, $62, $3f, $3e, $40
	db $48, $62, $24, $46, $4f, $f1, $3e, $51, $51, $3e, $40, $48, $50, $62, $51, $4c
	db $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50, $f0, $27, $4c, $41
	db $44, $42, $50, $62, $3e, $4b, $62, $3e, $51, $51, $3e, $40, $48, $f0, $33, $4f
	db $42, $4d, $3e, $4f, $42, $50, $62, $51, $4c, $62, $41, $42, $43, $42, $4b, $41
	db $f1, $46, $51, $50, $42, $49, $43, $62, $43, $4c, $4f, $62, $3e, $4b, $f1, $42
	db $4b, $42, $4a, $56, $62, $3e, $51, $51, $3e, $40, $48, $f0, $33, $4f, $42, $4d
	db $3e, $4f, $42, $50, $62, $3e, $62, $50, $51, $4f, $4c, $4b, $44, $f1, $41, $42
	db $43, $42, $4b, $50, $42, $62, $3e, $44, $3e, $46, $4b, $50, $51, $f1, $3e, $4b
	db $56, $62, $3e, $51, $51, $3e, $40, $48, $f0, $36, $52, $40, $48, $50, $62, $3e
	db $49, $49, $62, $51, $45, $42, $62, $3e, $46, $4f, $f1, $51, $4c, $62, $46, $4b
	db $43, $49, $46, $40, $51, $62, $41, $3e, $4a, $3e, $44, $42, $f1, $4c, $4b, $62
	db $3e, $49, $49, $62, $42, $4b, $42, $4a, $46, $42, $50, $f0, $27, $42, $43, $42
	db $4b, $41, $50, $62, $3e, $44, $3e, $46, $4b, $50, $51, $f1, $3e, $62, $40, $4c
	db $52, $4b, $51, $42, $4f, $3e, $51, $51, $3e, $40, $48, $f0, $36, $52, $50, $4d
	db $42, $4b, $41, $50, $62, $3e, $49, $49, $f1, $42, $4b, $42, $4a, $46, $42, $50
	db $5c, $62, $27, $3e, $4b, $40, $42, $f1, $3e, $51, $51, $3e, $40, $48, $50, $f0
	db $36, $52, $50, $4d, $42, $4b, $41, $50, $62, $3e, $4b, $f1, $42, $4b, $42, $4a
	db $56, $68, $62, $24, $46, $4f, $f1, $3e, $51, $51, $3e, $40, $48, $f0, $35, $42
	db $50, $51, $4c, $4f, $42, $50, $62, $05, $00, $00, $62, $2b, $33, $f1, $3f, $56
	db $62, $4a, $42, $41, $46, $51, $3e, $51, $46, $4c, $4b, $f0, $35, $42, $50, $51
	db $4c, $4f, $42, $50, $62, $3f, $42, $51, $54, $42, $42, $4b, $f1, $07, $00, $62
	db $51, $4c, $62, $08, $00, $62, $2b, $33, $62, $51, $4c, $62, $3e, $49, $49, $f1
	db $3e, $49, $49, $46, $42, $50, $f0, $35, $42, $53, $46, $53, $42, $50, $62, $3e
	db $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $35, $42, $53, $46, $53, $42
	db $50, $62, $3e, $49, $49, $62, $3e, $49, $49, $46, $42, $50, $f0, $f0, $26, $3e
	db $50, $51, $42, $4f, $62, $51, $4f, $3e, $4b, $50, $43, $4c, $4f, $4a, $50, $f1
	db $46, $4b, $51, $4c, $62, $3e, $62, $41, $4f, $3e, $44, $4c, $4b, $f0, $2c, $4b
	db $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a
	db $3e, $44, $42, $62, $51, $4c, $62, $50, $49, $46, $4a, $42, $50, $f0, $2c, $4b
	db $43, $49, $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a
	db $3e, $44, $42, $62, $51, $4c, $62, $3f, $52, $44, $50, $f0, $2c, $4b, $43, $49
	db $46, $40, $51, $50, $62, $44, $4f, $42, $3e, $51, $f1, $41, $3e, $4a, $3e, $44
	db $42, $62, $51, $4c, $62, $4d, $49, $3e, $4b, $51, $50, $f0, $30, $4c, $50, $51
	db $62, $41, $42, $50, $51, $4f, $52, $40, $51, $46, $53, $42, $f1, $50, $54, $4c
	db $4f, $41, $62, $3e, $51, $51, $3e, $40, $48, $f0, $30, $3e, $48, $42, $50, $62
	db $56, $4c, $52, $62, $43, $42, $42, $49, $f1, $50, $46, $40, $48, $f0, $f0

;@ path: text/dialogue
;@ Text table of bank $56 for StartText_56 / CopyText_56: one pointer per text group, then each
;@ group's pointers to its texts (the two-level format StartText reads).
TextTable_56::
	db $4f, $66, $67, $66, $4c, $4e, $63, $4e, $9b, $4e, $c7, $4e, $f3, $4e, $1f, $4f
	db $4b, $4f, $77, $4f, $a3, $4f, $cb, $4f, $f3, $4f, $1f, $50, $2f, $50, $56, $50
	db $7d, $50, $a2, $50, $d4, $50, $05, $51, $39, $51, $6a, $51, $99, $51, $ce, $51
	db $ff, $51, $2e, $52, $5f, $52, $7c, $52, $97, $52, $c2, $52, $e5, $52, $0c, $53
	db $32, $53, $50, $53, $71, $53, $97, $53, $ae, $53, $c8, $53, $f5, $53, $1e, $54
	db $33, $54, $44, $54, $6f, $54, $88, $54, $a8, $54, $c6, $54, $e7, $54, $05, $55
	db $26, $55, $44, $55, $65, $55, $98, $55, $bf, $55, $e8, $55, $1a, $56, $4d, $56
	db $7a, $56, $aa, $56, $d0, $56, $fa, $56, $16, $57, $40, $57, $5f, $57, $6f, $57
	db $7f, $57, $b1, $57, $be, $57, $e2, $57, $f2, $57, $01, $58, $2c, $58, $54, $58
	db $77, $58, $78, $58, $88, $58, $b8, $58, $da, $58, $02, $59, $2f, $59, $4d, $59
	db $7f, $59, $af, $59, $e5, $59, $00, $5a, $19, $5a, $36, $5a, $50, $5a, $77, $5a
	db $98, $5a, $b8, $5a, $d7, $5a, $f7, $5a, $17, $5b, $3a, $5b, $68, $5b, $82, $5b
	db $9e, $5b, $b1, $5b, $d4, $5b, $f1, $5b, $18, $5c, $4b, $5c, $6d, $5c, $97, $5c
	db $bf, $5c, $ed, $5c, $0f, $5d, $42, $5d, $75, $5d, $a0, $5d, $cf, $5d, $05, $5e
	db $19, $5e, $51, $5e, $7e, $5e, $ac, $5e, $db, $5e, $0c, $5f, $35, $5f, $65, $5f
	db $90, $5f, $aa, $5f, $c0, $5f, $d4, $5f, $f0, $5f, $05, $60, $18, $60, $2d, $60
	db $4e, $60, $73, $60, $9c, $60, $cd, $60, $fb, $60, $2a, $61, $3e, $61, $66, $61
	db $8f, $61, $bf, $61, $e3, $61, $f5, $61, $1f, $62, $30, $62, $4b, $62, $6f, $62
	db $91, $62, $ab, $62, $d7, $62, $02, $63, $2d, $63, $58, $63, $83, $63, $b4, $63
	db $db, $63, $00, $64, $29, $64, $3a, $64, $68, $64, $95, $64, $c8, $64, $e8, $64
	db $0c, $65, $2a, $65, $48, $65, $73, $65, $86, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65, $99, $65
	db $99, $65, $99, $65, $99, $65, $9a, $65, $ba, $65, $da, $65, $f8, $65, $18, $66
	db $36, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66
	db $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66
	db $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66
	db $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66
	db $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66, $4a, $66

;@ path: gfx/compressed
;@ Compressed data, entry $09 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6867::
	db $20, $00, $01, $ff, $00, $ff, $c6, $01, $02, $01, $fe, $01, $02, $03, $01, $01
	db $00, $ee, $ff, $ee, $ff, $fe, $ff, $d6, $01, $02, $00

;@ path: gfx/compressed
;@ Compressed data, entry $0A of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6882::
	db $20, $00, $01, $ff, $82, $ff, $c2, $ff, $a2, $ff, $92, $ff, $8a, $ff, $86, $ff
	db $82, $ff, $00, $ff, $38, $ff, $44, $ff, $82, $01, $14, $01, $44, $ff, $38, $ff
	db $00

;@ path: gfx/compressed
;@ Compressed data, entry $0B of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_68A3::
	db $20, $00, $01, $ff, $00, $ff, $02, $ff, $04, $ff, $08, $ff, $10, $ff, $20, $ff
	db $40, $ff, $80, $ff, $00, $ff, $10, $ff, $92, $ff, $54, $ff, $38, $ff, $54, $ff
	db $92, $ff, $10

;@ path: gfx/compressed
;@ Compressed data, entry $0C of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
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

;@ path: gfx/compressed
;@ Compressed data, entry $0D of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
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

;@ path: gfx/compressed
;@ Compressed data, entry $0E of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
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

;@ path: gfx/compressed
;@ Compressed data, entry $0F of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6CA8::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $01, $02, $05, $00, $ff
	db $f8, $ff, $80, $ff, $80, $01, $12, $05, $00, $ff, $70, $ff, $88, $ff, $80, $ff
	db $bc, $ff, $88, $ff, $98, $ff, $68, $ff, $00, $ff, $44, $ff, $46, $ff, $45, $ff
	db $45, $ff, $44, $01, $3a, $01, $01, $31, $06, $c4, $01, $3c, $05, $01, $3b, $02
	db $01, $4b, $06, $64, $ff, $54, $ff, $54, $ff, $4c, $01, $3c, $03, $38, $ff, $44
	db $ff, $40, $ff, $5e, $ff, $44, $ff, $4c, $ff, $34, $ff, $00, $ff, $18, $ff, $18
	db $ff, $01, $ff, $f0, $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $10 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6D0F::
	db $90, $00, $01, $ff, $00, $ff, $88, $01, $02, $03, $50, $ff, $50, $ff, $20, $01
	db $00, $07, $01, $03, $00, $8f, $ff, $00, $ff, $08, $01, $22, $07, $01, $1f, $00
	db $02, $ff, $05, $01, $34, $01, $0f, $ff, $08, $ff, $88, $ff, $00, $ff, $07, $01
	db $22, $01, $0b, $ff, $88, $ff, $89, $ff, $86, $01, $40, $01, $84, $ff, $04, $ff
	db $c7, $ff, $84, $ff, $84, $ff, $87, $ff, $00, $ff, $c7, $ff, $04, $01, $56, $01
	db $05, $ff, $04, $ff, $c4, $ff, $00, $ff, $80, $ff, $40, $ff, $40, $ff, $80, $01
	db $70, $03, $00, $ff, $18, $ff, $18, $ff, $01, $ff, $f0, $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $11 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6D7D::
	db $90, $00, $01, $ff, $00, $ff, $f8, $ff, $20, $01, $04, $07, $00, $ff, $20, $ff
	db $50, $01, $14, $01, $f8, $ff, $88, $ff, $88, $ff, $00, $ff, $80, $01, $22, $07
	db $f8, $ff, $00, $ff, $87, $01, $1c, $01, $87, $ff, $80, $01, $36, $01, $00, $ff
	db $08, $ff, $8d, $ff, $0a, $ff, $0a, $01, $1c, $01, $08, $ff, $00, $ff, $82, $ff
	db $85, $01, $54, $01, $8f, $01, $1c, $03, $08, $ff, $0c, $01, $46, $01, $89, $01
	db $1c, $0f, $00, $80, $ff, $00, $ff, $18, $ff, $18, $ff, $01, $ff, $f0, $01, $83
	db $01

;@ path: gfx/compressed
;@ Compressed data, entry $12 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6DDE::
	db $90, $00, $01, $ff, $00, $ff, $88, $ff, $d8, $ff, $a8, $ff, $a8, $ff, $88, $01
	db $0a, $01, $00, $ff, $f8, $ff, $80, $ff, $80, $01, $12, $05, $01, $01, $0e, $70
	db $01, $0a, $03, $01, $0b, $00, $70, $ff, $00, $ff, $f0, $01, $0a, $01, $f0, $ff
	db $a0, $ff, $90, $01, $0e, $01, $20, $01, $52, $09, $01, $11, $0e, $01, $33, $00
	db $80, $ff, $70, $ff, $08, $01, $3c, $03, $18, $ff, $18, $ff, $01, $ff, $f0, $01
	db $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $13 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6E30::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $01, $02, $05, $00, $ff
	db $f8, $ff, $80, $ff, $80, $01, $12, $05, $00, $01, $04, $01, $88, $ff, $a8, $ff
	db $a8, $ff, $d8, $ff, $88, $ff, $00, $ff, $84, $01, $32, $07, $87, $ff, $00, $ff
	db $0f, $ff, $08, $01, $44, $05, $cf, $01, $40, $01, $01, $05, $00, $8f, $01, $04
	db $01, $0f, $ff, $00, $ff, $8f, $01, $44, $01, $8f, $ff, $0a, $ff, $09, $01, $2e
	db $01, $00, $01, $14, $01, $01, $ff, $f0, $01, $73, $00, $00, $ff, $18, $ff, $18
	db $01, $70, $01, $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $14 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6E96::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $ff, $f0, $ff, $80, $01
	db $0a, $01, $00, $ff, $f8, $01, $0a, $01, $01, $13, $04, $00, $ff, $20, $ff, $50
	db $01, $24, $01, $f8, $01, $04, $01, $00, $ff, $70, $ff, $88, $01, $0a, $03, $88
	db $ff, $70, $01, $10, $0f, $00, $01, $51, $0f, $1d, $18, $ff, $18, $01, $7e, $06

;@ path: gfx/compressed
;@ Compressed data, entry $15 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6ED6::
	db $90, $00, $01, $ff, $00, $ff, $f0, $ff, $88, $ff, $88, $01, $02, $05, $01, $01
	db $06, $a0, $ff, $90, $ff, $88, $ff, $00, $ff, $20, $ff, $50, $01, $24, $01, $f8
	db $01, $04, $01, $00, $01, $04, $01, $01, $05, $00, $01, $25, $00, $20, $ff, $00
	db $ff, $f8, $ff, $80, $ff, $80, $01, $42, $05, $01, $11, $0e, $01, $37, $02, $20
	db $01, $68, $03, $01, $ff, $f0, $01, $71, $0a, $18, $ff, $18, $01, $7e, $06

;@ path: gfx/compressed
;@ Compressed data, entry $16 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6F25::
	db $90, $00, $01, $ff, $00, $ff, $70, $ff, $88, $ff, $80, $ff, $70, $ff, $08, $ff
	db $88, $ff, $70, $ff, $00, $ff, $f8, $ff, $20, $01, $14, $07, $00, $ff, $f0, $ff
	db $88, $ff, $88, $ff, $f0, $ff, $a0, $ff, $90, $ff, $88, $01, $10, $01, $80, $ff
	db $80, $01, $32, $05, $00, $ff, $88, $ff, $c8, $ff, $a8, $ff, $a8, $ff, $98, $01
	db $24, $01, $01, $01, $04, $bc, $ff, $88, $ff, $98, $ff, $68, $01, $10, $0f, $00
	db $01, $25, $00, $88, $ff, $f8, $01, $72, $03, $00, $ff, $18, $ff, $18, $ff, $01
	db $ff, $f0, $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $17 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6F8A::
	db $90, $00, $01, $ff, $00, $ff, $20, $ff, $50, $01, $04, $01, $f8, $ff, $88, $ff
	db $88, $ff, $00, $ff, $88, $ff, $c8, $ff, $a8, $ff, $a8, $ff, $98, $01, $0c, $03
	db $70, $ff, $88, $ff, $80, $ff, $bc, $ff, $88, $ff, $98, $ff, $68, $ff, $00, $ff
	db $f8, $ff, $80, $ff, $80, $01, $32, $05, $00, $ff, $f0, $01, $0c, $01, $f0, $ff
	db $a0, $ff, $90, $01, $0e, $01, $01, $51, $0f, $1d, $18, $ff, $18, $01, $7e, $06

;@ path: gfx/compressed
;@ Compressed data, entry $18 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_6FDA::
	db $90, $00, $01, $ff, $00, $ff, $08, $01, $02, $03, $88, $ff, $88, $ff, $70, $ff
	db $00, $ff, $70, $01, $0a, $01, $01, $15, $02, $01, $0f, $00, $01, $0b, $00, $50
	db $ff, $20, $01, $28, $03, $01, $ff, $f0, $01, $31, $0f, $3b, $18, $ff, $18, $01
	db $7e, $06

;@ path: gfx/compressed
;@ Compressed data, entry $19 of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_700C::
	db $90, $00, $01, $ff, $00, $ff, $88, $01, $02, $01, $a8, $ff, $a8, $ff, $d8, $ff
	db $88, $ff, $00, $ff, $20, $01, $12, $09, $00, $ff, $70, $ff, $88, $ff, $80, $ff
	db $70, $ff, $08, $ff, $88, $ff, $70, $ff, $00, $ff, $e0, $ff, $90, $01, $02, $03
	db $90, $ff, $e0, $01, $20, $03, $01, $45, $04, $01, $2f, $00, $88, $ff, $d8, $01
	db $08, $01, $01, $03, $02, $01, $ff, $f0, $01, $61, $0f, $0b, $18, $ff, $18, $01
	db $7e, $06

;@ path: gfx/compressed
;@ Compressed data, entry $1A of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_705E::
	db $90, $00, $01, $ff, $00, $ff, $88, $01, $02, $01, $f8, $01, $02, $03, $00, $ff
	db $20, $ff, $50, $01, $14, $01, $01, $09, $02, $00, $ff, $f0, $01, $02, $01, $f0
	db $ff, $80, $01, $2a, $01, $01, $21, $0e, $88, $ff, $8c, $ff, $8a, $ff, $8a, $ff
	db $89, $01, $0c, $03, $8f, $01, $02, $01, $01, $53, $04, $00, $ff, $87, $ff, $08
	db $ff, $08, $ff, $87, $ff, $00, $01, $66, $03, $0e, $ff, $91, $ff, $10, $ff, $0e
	db $ff, $81, $ff, $91, $ff, $0e, $ff, $00, $ff, $18, $ff, $18, $ff, $01, $ff, $f0
	db $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $1B of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_70C1::
	db $90, $00, $01, $ff, $00, $ff, $fb, $ff, $22, $ff, $22, $ff, $23, $01, $04, $03
	db $00, $ff, $e4, $ff, $06, $ff, $05, $ff, $e5, $ff, $04, $ff, $04, $ff, $e4, $ff
	db $00, $ff, $4f, $ff, $c8, $ff, $48, $ff, $4f, $ff, $48, $01, $2a, $01, $00, $ff
	db $1f, $ff, $84, $ff, $84, $01, $1a, $01, $01, $1b, $00, $00, $ff, $08, $ff, $14
	db $01, $44, $01, $3e, $01, $04, $01, $00, $ff, $7c, $ff, $10, $01, $54, $07, $00
	db $ff, $47, $01, $2a, $03, $01, $2b, $00, $47, $ff, $00, $ff, $11, $ff, $99, $ff
	db $95, $ff, $95, $ff, $93, $ff, $91, $ff, $11, $ff, $00, $ff, $18, $ff, $18, $ff
	db $01, $ff, $f0, $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $1C of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_7137::
	db $90, $00, $01, $ff, $00, $ff, $80, $01, $02, $03, $81, $ff, $81, $ff, $f9, $ff
	db $00, $ff, $41, $ff, $a1, $01, $14, $01, $f1, $ff, $11, $ff, $11, $ff, $00, $ff
	db $e1, $ff, $11, $ff, $10, $ff, $e0, $ff, $10, $01, $26, $01, $00, $ff, $13, $ff
	db $12, $ff, $a2, $ff, $43, $ff, $42, $01, $3a, $01, $00, $ff, $c1, $ff, $21, $ff
	db $21, $ff, $c1, $ff, $81, $ff, $41, $ff, $21, $ff, $00, $ff, $08, $ff, $0c, $ff
	db $0a, $ff, $0a, $ff, $09, $ff, $08, $ff, $08, $ff, $00, $ff, $8f, $ff, $82, $01
	db $64, $07, $00, $ff, $91, $01, $1c, $01, $1f, $01, $1c, $01, $01, $1f, $00, $18
	db $ff, $18, $ff, $01, $ff, $f0, $01, $83, $01

;@ path: gfx/compressed
;@ Compressed data, entry $1D of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
Data_56_71B0::
	db $90, $00, $01, $ff, $00, $ff, $09, $01, $02, $03, $89, $ff, $89, $ff, $70, $ff
	db $00, $ff, $13, $ff, $12, $01, $14, $05, $e3, $ff, $00, $ff, $83, $ff, $44, $ff
	db $24, $ff, $25, $ff, $24, $ff, $44, $ff, $83, $ff, $00, $ff, $88, $ff, $4d, $ff
	db $0a, $ff, $ea, $ff, $48, $ff, $c8, $ff, $48, $ff, $00, $ff, $9f, $ff, $90, $ff
	db $90, $01, $42, $05, $00, $ff, $22, $ff, $32, $ff, $2a, $ff, $2a, $ff, $26, $ff
	db $22, $ff, $22, $ff, $00, $ff, $7c, $ff, $10, $01, $64, $07, $01, $ff, $f0, $01
	db $71, $0a, $18, $ff, $18, $01, $7e, $06

;@ path: gfx/compressed
;@ Compressed data, entry $1E of bank $56 for Decompress / DecompressVRAM (format at
;@ DecompressCore).
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
