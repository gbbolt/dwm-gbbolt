INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $018", ROMX[$4000], BANK[$18]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_18::
	db $18

;@ path: link/result
;@ Entry points of bank $18: the start and the per-frame routine of game mode 6 (the screen after
;@ a VS battle over the link cable, where the prize monster changes hands), then the three text
;@ routines of the texts kept in this bank.
FarTable_18::
	dw VSResultInit
	dw VSResultUpdate
	dw StartText_18
	dw CopyText_18
	dw PrintText_18

;@ def VSResultInit()
;@ path: link/result
;@ Starts game mode 6, the result screen of a VS battle over the link cable: clears the menu
;@ variables, loads the banner letters, window and Terry sprite tiles, restores the party from
;@ the VS team, unpacks the prize monster's walking sprite (or the egg sprite), sets up the text
;@ box, reloads the monsters from the save and the party's pictures, and turns the screen on.
;@ test: skip calls routines in other banks
VSResultInit::
;> fill(wMenuChoice, 0, 8)
	xor a
	ld hl, wMenuChoice
	ld bc, $0008
	call FillMemory
;> fill(wTextTiles, 0, 0x12)
	xor a
	ld hl, wTextTiles
	ld bc, $0012
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
	ld [wTitleBgMap + 1], a
;> wSGBPalSet = 0; mem[wSGBPalSet + 1] = 0
	ld hl, wSGBPalSet
	ld [hl], $00
	inc hl
	ld [hl], $00
;> SGBSetFieldPalettes()
	ld hl, far_SGBSetFieldPalettes
	rst $10
;> LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
;> SetSharedBGColors()
	ld hl, far_SetSharedBGColors
	rst $10
;> ClearAttrMap()
	ld hl, far_ClearAttrMap
	rst $10
;> StartFade(0xFC)                       # fade in
	ld a, $fc
	call StartFade
;> fill(0x9800, 0xE0, 0x400)             # blank BG map
	ld hl, $9800
	ld bc, $0400
	ld a, $e0
	call FillMemory
;> Decompress(0x3F, 0x03, 0x8800)        # the big banner letters (tiles $80 on)
	ld de, $3f03
	ld hl, $8800
	call Decompress
;> Decompress(0x2E, 0x00, 0x8D00)        # window frame and symbols
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> Decompress(0x2F, 0x00, 0x8000)        # Terry's sprite
	ld de, $2f00
	ld hl, $8000
	call Decompress
;> wPartyCount = wVSTeamCount           # the party again as it was before the battle
	ld a, [wVSTeamCount]
	ld [wPartyCount], a
;> wParty[0] = wVSTeamSlots[0]
	ld a, [wVSTeamSlots]
	ld [wParty], a
;> wParty[1] = wVSTeamSlots[1]
	ld a, [wVSTeamSlots + 1]
	ld [wParty + 1], a
;> wParty[2] = wVSTeamSlots[2]
	ld a, [wVSTeamSlots + 2]
	ld [wParty + 2], a
;> slot = VSPrizeRecordSlot()
	call VSPrizeRecordSlot
;>@np if slot != 0xFF and mem[MonsterField(slot, wMonsters)]:
	cp $ff
	jr z, .noPrize

	ld hl, wMonsters
	call MonsterField
;=@np
	ld a, [hl]
	or a
	jr z, .noPrize

;>     gfx = 0x313F                      # the egg sprite
	ld de, $313f
	push de
;>@egg     if mem[MonsterField(VSPrizeRecordSlot(), wMonEgg)] == 0:
	call VSPrizeRecordSlot
	ld hl, wMonEgg
	call MonsterField
	pop de
;=@egg
	ld a, [hl]
	or a
	jr nz, .load

;>         species = mem[MonsterField(VSPrizeRecordSlot(), wMonRecSpecies)]
	call VSPrizeRecordSlot
	ld hl, wMonRecSpecies
	call MonsterField
;>@gfx         gfx = mem16[MonsterSpriteGfx_18 + 2 * species]
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterSpriteGfx_18)
	ld l, a
;=@gfx
	ld a, h
	adc HIGH(MonsterSpriteGfx_18)
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a

.load
;>     Decompress(hi(gfx), lo(gfx), 0x8200)   # sprite tiles $20 on
	ld hl, $8200
	call Decompress

.noPrize
;> SetUpTextBox(0x8B00, 2, 0x12)
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> Call_56_4485()
	ld hl, far_Call_56_4485
	rst $10
;> wTextBoxMap = 0x99C1
	ld hl, $99c1
	ld a, l
	ld [wTextBoxMap], a
	ld a, h
	ld [wTextBoxMap + 1], a
;> CopyFromSRAM_18(wMonsters, sMonsters, 0xBA4)   # the monsters as saved
	ld hl, wMonsters
	ld de, sMonsters
	ld bc, $0ba4
	call CopyFromSRAM_18
;> LoadPartyPictures_18()
	call LoadPartyPictures_18
;> hWX = 7; hWY = 0xFF                  # no window
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
;> hScrollY = 0; hScrollX = 0
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
;> DisableSTATInterrupts()
	call DisableSTATInterrupts
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [wFrameCounter + 1], a
;> wLCDEffect = 0
	xor a
	ld [wLCDEffect], a
;> wLinkMode = 0
	xor a
	ld [wLinkMode], a
;> wLCDC = 0x03
	ld a, $03
	ld [wLCDC], a
;> EnableLCDAndInterrupts(0x01)          # VBlank only
	ld a, $01
	jp EnableLCDAndInterrupts


;@ path: gfx/sprites
;@ Walking sprite graphics of each monster species, 2 bytes per species: the entry number, then the
;@ bank, of the compressed tiles (as Decompress takes them in e and d). The first 16 point into bank
;@ $2F, the others into banks $38, $39 and $3A.
MonsterSpriteGfx_18::
	db $01, $2f, $02, $2f, $03, $2f, $04, $2f, $05, $2f, $06, $2f, $07, $2f, $08, $2f
	db $09, $2f, $0a, $2f, $0b, $2f, $0c, $2f, $0d, $2f, $0e, $2f, $0f, $2f, $10, $2f
	db $00, $38, $01, $38, $02, $38, $03, $38, $04, $38, $05, $38, $06, $38, $07, $38
	db $08, $38, $09, $38, $0a, $38, $0b, $38, $0c, $38, $0d, $38, $0e, $38, $0f, $38
	db $10, $38, $11, $38, $12, $38, $13, $38, $14, $38, $15, $38, $16, $38, $17, $38
	db $18, $38, $19, $38, $1a, $38, $1b, $38, $1c, $38, $1d, $38, $1e, $38, $1f, $38
	db $20, $38, $21, $38, $22, $38, $23, $38, $24, $38, $25, $38, $26, $38, $27, $38
	db $28, $38, $29, $38, $2a, $38, $2b, $38, $2c, $38, $2d, $38, $2e, $38, $2f, $38
	db $30, $38, $31, $38, $32, $38, $33, $38, $34, $38, $35, $38, $36, $38, $37, $38
	db $38, $38, $39, $38, $3a, $38, $3b, $38, $3c, $38, $3d, $38, $3e, $38, $3f, $38
	db $40, $38, $41, $38, $42, $38, $43, $38, $44, $38, $45, $38, $46, $38, $47, $38
	db $00, $39, $01, $39, $02, $39, $03, $39, $04, $39, $05, $39, $06, $39, $07, $39
	db $08, $39, $09, $39, $0a, $39, $0b, $39, $0c, $39, $0d, $39, $0e, $39, $0f, $39
	db $10, $39, $11, $39, $12, $39, $13, $39, $14, $39, $15, $39, $16, $39, $17, $39
	db $18, $39, $19, $39, $1a, $39, $1b, $39, $1c, $39, $1d, $39, $1e, $39, $1f, $39
	db $20, $39, $21, $39, $22, $39, $23, $39, $24, $39, $25, $39, $26, $39, $27, $39
	db $28, $39, $29, $39, $2a, $39, $2b, $39, $2c, $39, $2d, $39, $2e, $39, $2f, $39
	db $30, $39, $31, $39, $32, $39, $33, $39, $34, $39, $35, $39, $36, $39, $37, $39
	db $38, $39, $39, $39, $3a, $39, $3b, $39, $3c, $39, $3d, $39, $3e, $39, $3f, $39
	db $40, $39, $41, $39, $42, $39, $43, $39, $44, $39, $45, $39, $46, $39, $47, $39
	db $00, $3a, $01, $3a, $02, $3a, $03, $3a, $04, $3a, $05, $3a, $06, $3a, $07, $3a
	db $08, $3a, $09, $3a, $0a, $3a, $0b, $3a, $0c, $3a, $0d, $3a, $0e, $3a, $0f, $3a
	db $10, $3a, $11, $3a, $12, $3a, $13, $3a, $14, $3a, $15, $3a, $16, $3a, $17, $3a
	db $18, $3a, $19, $3a, $1a, $3a, $1b, $3a, $1c, $3a, $1d, $3a, $1e, $3a, $1f, $3a
	db $20, $3a, $21, $3a, $22, $3a, $23, $3a, $24, $3a, $25, $3a, $26, $3a, $27, $3a
	db $28, $3a, $29, $3a, $2a, $3a, $2b, $3a, $2c, $3a, $2d, $3a, $2e, $3a, $2f, $3a
	db $30, $3a, $31, $3a, $32, $3a, $33, $3a, $34, $3a, $35, $3a, $36, $3a

;@ def VSPrizeRecordSlot() -> a
;@ path: link/result
;@ Record slot of the monster that changes hands after a VS battle: $15 (the record just after
;@ the 20 monsters, wBreedParent2, which holds the monster received from the partner) when we
;@ won, else wLinkPrizeSlot (after a lost battle $14, wBreedParent1, the copy of the monster we
;@ gave away; $FF when no prize was offered). wBattlerReload is nonzero after a lost battle.
VSPrizeRecordSlot::
;> if not wBattlerReload:              # we won
;>     return 0x15
	ld a, [wBattlerReload]
	or a
	jr nz, .lost

	ld a, $15
	ret


.lost
;> return wLinkPrizeSlot
	ld a, [wLinkPrizeSlot]
	ret


;@ def VSResultUpdate()
;@ path: link/result
;@ Per-frame routine of game mode 6: draws the old master's sprite, then runs step wTitleStep
;@ of the result screen (VSResultSteps).
;@ test: skip jumps through a table
VSResultUpdate::
;> VSResultDrawGiver()
	call VSResultDrawGiver
;> VSResultSteps[wTitleStep]()
	ld a, [wTitleStep]
	rst $00

;@ path: link/result
;@ The steps of the VS result screen (wTitleStep): the "YOU WIN" / "YOU LOSE" banner, the scene
;@ where the prize monster walks over to its new master, storing a won monster (or asking which
;@ monster or egg it replaces when all 20 slots are full), and the way back to the title.
VSResultSteps::
	dw VSResultStart
	dw VSResultSayOutcome
	dw VSResultWaitOutcome
	dw VSResultRevealLetters1
	dw VSResultRevealLetters2
	dw VSResultRevealLetters3
	dw VSResultRevealLetters4
	dw VSResultWipePictures
	dw VSResultGiverWalksIn
	dw VSResultMonsterWalks
	dw VSResultTakerWalksIn
	dw VSResultTakerLeaves
	dw VSResultKeepPrize
	dw VSResultShowReplaceYesNo
	dw VSResultReplaceYesNoInput
	dw VSResultReleasePrize
	dw VSResultReleaseWait
	dw VSResultStartReplaceList
	dw VSResultShowReplaceList
	dw VSResultReplaceListInput
	dw VSResultReplacePicked
	dw VSResultShowInfoOk
	dw VSResultInfoOkInput
	dw VSResultShowStatus
	dw VSResultStatusDone
	dw VSResultReplaceMonster
	dw VSResultEnd
	dw VSResultAskKind
	dw VSResultShowKindMenu
	dw VSResultKindInput
	dw VSResultNoEgg
	dw VSResultBackToList

;@ def VSResultStart()
;@ path: link/result
;@ Step 0: prints the menu words "WHO", "INFO", "OK", "MON" and "EGG" (system text $024A) into the
;@ tiles from $96C0 on (tiles $6C-$7A, used by the windows later), draws the party's monster
;@ pictures and the text box frame and copies the screen to the BG map.
;@ test: skip calls routines in other banks
VSResultStart::
;> wTextGroup = 2; wTextIndex = 0x4A
	ld a, $02
	ld [wTextGroup], a
	ld a, $4a
	ld [wTextIndex], a
;> DrawTextTiles_18(0x96C0, 1, 16)
	ld hl, $96c0
	ld de, $1001
	call DrawTextTiles_18
;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> DrawPartyPictures_18()
	call DrawPartyPictures_18
;> DrawWindowLayout_18(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_18
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;> MenuResetBlink_18()
	call MenuResetBlink_18
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultSayOutcome()
;@ path: link/result
;@ Step 1: once the fade-in is over, prints "You win!" or "You lose!".
;@ test: skip calls routines in other banks
VSResultSayOutcome::
;> if wFadeState:
;>     return
	ld a, [wFadeState]
	or a
	jr nz, .done

;>@text PrintSystemText(0x0247 if wBattlerReload else 0x0246)   # "You lose!" / "You win!"
	ld hl, $0246
	ld a, [wBattlerReload]
	or a
	jr z, .print

	ld hl, $0247

.print
;=@text
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ def VSResultWaitOutcome()
;@ path: link/result
;@ Step 2: waits for the text, then starts the 12-frame timer of the banner (wMenuChoice).
VSResultWaitOutcome::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	jr nz, .done

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wMenuChoice = 12                     # frames until the first letters
	ld a, $0c
	ld [wMenuChoice], a

.done
	ret


;@ def VSResultRevealLetters1()
;@ path: link/result
;@ Step 3: after 12 frames draws the first and last banner letters ("Y" and "!" / "E").
VSResultRevealLetters1::
;> wMenuChoice -= 1
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
;> if wMenuChoice:
;>     return
	ret nz

;> DrawBannerLetter(0)
	ld a, $00
	call DrawBannerLetter
;> DrawBannerLetter(7)
	ld a, $07
	call DrawBannerLetter
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wMenuChoice = 12
	ld a, $0c
	ld [wMenuChoice], a
	ret


;@ def VSResultRevealLetters2()
;@ path: link/result
;@ Step 4: after 12 frames draws banner letters 1 and 6.
VSResultRevealLetters2::
;> wMenuChoice -= 1
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
;> if wMenuChoice:
;>     return
	ret nz

;> DrawBannerLetter(1)
	ld a, $01
	call DrawBannerLetter
;> DrawBannerLetter(6)
	ld a, $06
	call DrawBannerLetter
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wMenuChoice = 12
	ld a, $0c
	ld [wMenuChoice], a
	ret


;@ def VSResultRevealLetters3()
;@ path: link/result
;@ Step 5: after 12 frames draws banner letters 2 and 5.
VSResultRevealLetters3::
;> wMenuChoice -= 1
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
;> if wMenuChoice:
;>     return
	ret nz

;> DrawBannerLetter(2)
	ld a, $02
	call DrawBannerLetter
;> DrawBannerLetter(5)
	ld a, $05
	call DrawBannerLetter
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wMenuChoice = 12
	ld a, $0c
	ld [wMenuChoice], a
	ret


;@ def VSResultRevealLetters4()
;@ path: link/result
;@ Step 6: after 12 frames draws the middle banner letters 3 and 4, completing "YOU WIN!" or
;@ "YOU LOSE". Without a prize monster the screen ends here (step $1A); else 32 frames later the
;@ pictures are wiped.
;@ test: skip reads monster records
VSResultRevealLetters4::
;> wMenuChoice -= 1
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
;> if wMenuChoice:
;>     return
	ret nz

;> DrawBannerLetter(3)
	ld a, $03
	call DrawBannerLetter
;> DrawBannerLetter(4)
	ld a, $04
	call DrawBannerLetter
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wMenuChoice = 32                     # timer
	ld a, $20
	ld [wMenuChoice], a
;> wMenuChoice2 = 0                     # column the wipe reached
	ld a, $00
	ld [wMenuChoice2], a
;> slot = VSPrizeRecordSlot()
	call VSPrizeRecordSlot
;>@np if slot != 0xFF and mem[MonsterField(slot, wMonsters)]:
	cp $ff
	jr z, .noPrize

	ld hl, wMonsters
	call MonsterField
;=@np
	ld a, [hl]
	or a
	jr z, .noPrize

;>     return
	ret


.noPrize
;> wTitleStep = 0x1A                    # no prize: leave
	ld a, $1a
	ld [wTitleStep], a
	ret


;@ def VSResultWipePictures()
;@ path: link/result
;@ Step 7: every 4 frames blanks one column on each side of the monster pictures (rows 6-11),
;@ moving inwards, until all 20 columns are gone; then places the scene's sprites: the old
;@ master (wMenuChoice = X $B0), the prize monster (wMenuChoice2 = X $C0) and the new master
;@ (wConfirmChoice = X $F8, off screen), with a 30-frame pause (wConfirmChoice2).
;@ test: skip writes VRAM
VSResultWipePictures::
;> wMenuChoice -= 1
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
;> if wMenuChoice:
;>     return
	ret nz

;>@l ClearBgColumn6_18(0x98C0 + wMenuChoice2)            # left side
	ld hl, $98c0
	ld a, [wMenuChoice2]
	add l
	ld l, a
	ld a, $00
	adc h
;=@l
	ld h, a
	call ClearBgColumn6_18
;>@r ClearBgColumn6_18(0x98D3 - wMenuChoice2)            # right side
	ld hl, $98d3
	ld a, [wMenuChoice2]
	ld b, a
	ld a, l
	sub b
	ld l, a
;=@r
	ld a, h
	sbc $00
	ld h, a
	call ClearBgColumn6_18
;> wMenuChoice = 4
	ld a, $04
	ld [wMenuChoice], a
;> wMenuChoice2 += 1
	ld a, [wMenuChoice2]
	inc a
	ld [wMenuChoice2], a
;> if wMenuChoice2 != 10:
;>     return
	cp $0a
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wMenuChoice = 0xB0                   # old master X
	ld a, $b0
	ld [wMenuChoice], a
;> wMenuChoice2 = 0xC0                  # prize monster X
	ld a, $c0
	ld [wMenuChoice2], a
;> wConfirmChoice = 0xF8                # new master X (off screen)
	ld a, $f8
	ld [wConfirmChoice], a
;> wConfirmChoice2 = 30                 # pause
	ld a, $1e
	ld [wConfirmChoice2], a
	ret


;@ def ClearBgColumn6_18(pos: hl)
;@ path: gfx/tilemap
;@ Writes the blank tile $E0 into 6 BG map rows from `pos` down.
;@ test: skip writes VRAM
ClearBgColumn6_18::
;> for i in range(6):
	ld b, $06

.loop
;>     WriteVRAM(0xE0, pos)
	ld a, $e0
	call WriteVRAM
;>@down     pos += 32
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@down
	dec b
	jr nz, .loop

	ret


;@ def VSResultGiverWalksIn()
;@ path: link/result
;@ Step 8: after the pause, the old master and the prize monster walk in from the right, one
;@ pixel a frame, until the old master stands at X $60.
;@ test: skip draws sprites through far calls
VSResultGiverWalksIn::
;> wConfirmChoice2 -= 1
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
;> if wConfirmChoice2:
;>     return VSResultDrawScene()       # still pausing
	jr nz, VSResultDrawScene

;> wConfirmChoice2 = 1                  # from now on move every frame
	ld a, $01
	ld [wConfirmChoice2], a
;> wMenuChoice -= 1
	ld a, [wMenuChoice]
	dec a
	ld [wMenuChoice], a
;> DrawTrainerSpriteFlipped(wMenuChoice)
	call DrawTrainerSpriteFlipped
;> wMenuChoice2 -= 1
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
;> DrawPrizeMonsterSprite(wMenuChoice2)
	call DrawPrizeMonsterSprite
;> if wMenuChoice != 0x60:
;>     return
	ld a, [wMenuChoice]
	cp $60
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wConfirmChoice2 = 30
	ld a, $1e
	ld [wConfirmChoice2], a
	ret


;@ def VSResultDrawScene()
;@ path: link/result
;@ Draws the three sprites of the scene where they stand: the old master (facing left), the
;@ prize monster and the new master (facing right).
;@ test: skip draws sprites through far calls
VSResultDrawScene::
;> DrawTrainerSpriteFlipped(wMenuChoice)
	ld a, [wMenuChoice]
	call DrawTrainerSpriteFlipped
;> DrawPrizeMonsterSprite(wMenuChoice2)
	ld a, [wMenuChoice2]
	call DrawPrizeMonsterSprite
;> DrawTrainerSprite(wConfirmChoice)
	ld a, [wConfirmChoice]
	call DrawTrainerSprite
	ret


;@ def VSResultMonsterWalks()
;@ path: link/result
;@ Step 9: after a 30-frame pause the prize monster walks on alone, until X $50.
;@ test: skip draws sprites through far calls
VSResultMonsterWalks::
;> wConfirmChoice2 -= 1
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
;> if wConfirmChoice2:
;>     return VSResultDrawScene()
	jr nz, VSResultDrawScene

;> wConfirmChoice2 = 1
	ld a, $01
	ld [wConfirmChoice2], a
;> DrawTrainerSpriteFlipped(wMenuChoice)
	ld a, [wMenuChoice]
	call DrawTrainerSpriteFlipped
;> DrawTrainerSprite(wConfirmChoice)
	ld a, [wConfirmChoice]
	call DrawTrainerSprite
;> wMenuChoice2 -= 1
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
;> DrawPrizeMonsterSprite(wMenuChoice2)
	call DrawPrizeMonsterSprite
;> if wMenuChoice2 != 0x50:
;>     return
	ld a, [wMenuChoice2]
	cp $50
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wConfirmChoice2 = 30
	ld a, $1e
	ld [wConfirmChoice2], a
	ret


;@ def VSResultTakerWalksIn()
;@ path: link/result
;@ Step 10: after a 30-frame pause the new master walks in from the left edge to X $40; then a
;@ 60-frame pause.
;@ test: skip draws sprites through far calls
VSResultTakerWalksIn::
;> wConfirmChoice2 -= 1
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
;> if wConfirmChoice2:
;>     return VSResultDrawScene()
	jr nz, VSResultDrawScene

;> wConfirmChoice2 = 1
	ld a, $01
	ld [wConfirmChoice2], a
;> DrawTrainerSpriteFlipped(wMenuChoice)
	ld a, [wMenuChoice]
	call DrawTrainerSpriteFlipped
;> DrawPrizeMonsterSprite(wMenuChoice2)
	ld a, [wMenuChoice2]
	call DrawPrizeMonsterSprite
;> wConfirmChoice += 1
	ld a, [wConfirmChoice]
	inc a
	ld [wConfirmChoice], a
;> DrawTrainerSprite(wConfirmChoice)
	call DrawTrainerSprite
;> if wConfirmChoice != 0x40:
;>     return
	ld a, [wConfirmChoice]
	cp $40
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> wConfirmChoice2 = 60
	ld a, $3c
	ld [wConfirmChoice2], a
	ret


;@ def VSResultTakerLeaves()
;@ path: link/result
;@ Step 11: the new master stands for 30 frames, turns round for 30 more, then walks off to the
;@ left with the prize monster. When the monster is gone: "<partner> surrendered <monster>."
;@ after a won battle, "<monster> was taken by <partner>." after a lost one.
;@ test: skip draws sprites through far calls
VSResultTakerLeaves::
;> wConfirmChoice2 -= 1
	ld a, [wConfirmChoice2]
	dec a
	ld [wConfirmChoice2], a
;> if wConfirmChoice2:
	jr z, .walk

;>     if wConfirmChoice2 >= 30:
;>         return VSResultDrawScene()
	cp $1e
	jr c, .turned

	jp VSResultDrawScene


;>@t1     DrawTrainerSpriteFlipped(wMenuChoice)   # the new master has turned round
;>@t2     DrawPrizeMonsterSprite(wMenuChoice2)
;>@t3     DrawTrainerSpriteFlipped(wConfirmChoice)
;>@t4     return
;> wConfirmChoice2 = 1
.walk
	ld a, $01
	ld [wConfirmChoice2], a
;> DrawTrainerSpriteFlipped(wMenuChoice)
	ld a, [wMenuChoice]
	call DrawTrainerSpriteFlipped
;> wConfirmChoice -= 1
	ld a, [wConfirmChoice]
	dec a
	ld [wConfirmChoice], a
;> DrawTrainerSpriteFlipped(wConfirmChoice)
	call DrawTrainerSpriteFlipped
;> wMenuChoice2 -= 1
	ld a, [wMenuChoice2]
	dec a
	ld [wMenuChoice2], a
;> DrawPrizeMonsterSprite(wMenuChoice2)
	call DrawPrizeMonsterSprite
;> if wMenuChoice2 != 0xFE:
;>     return
	ld a, [wMenuChoice2]
	cp $fe
	ret nz

;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
;> CopyName(wLinkPartnerName, wTextArg0)
	ld de, wLinkPartnerName
	ld hl, wTextArg0
	call CopyName
;>@name CopyName(MonsterField(VSPrizeRecordSlot(), wMonName), wTextArg1)
	call VSPrizeRecordSlot
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	ld hl, wTextArg1
	call CopyName
;>@text PrintSystemText(0x0249 if wBattlerReload else 0x0248)   # "was taken by" / "surrendered"
	ld hl, $0248
	ld a, [wBattlerReload]
	or a
	jr z, .print

	ld hl, $0249

.print
;=@text
	call PrintSystemText
	ret


.turned
;=@t1
	ld a, [wMenuChoice]
	call DrawTrainerSpriteFlipped
;=@t2
	ld a, [wMenuChoice2]
	call DrawPrizeMonsterSprite
;=@t3
	ld a, [wConfirmChoice]
	call DrawTrainerSpriteFlipped
;=@t4
	ret


;@ def VSResultKeepPrize()
;@ path: link/result
;@ Step 12: after the message, a won monster is stored: into the last monster slot (sorted in by
;@ CompactMonsters), with its library entry set, and the monsters and library are saved. When
;@ all 20 slots are taken it asks whether to replace one ("The monster farm is full!"). After a
;@ lost battle nothing is left to do (the game already gave the monster away).
;@ test: skip saves to battery RAM
VSResultKeepPrize::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if not wBattlerReload:              # we won
	ld a, [wBattlerReload]
	or a
	jr nz, .done

;>     rec = wMonsters
	ld de, wMonsters
	ld b, $00

.find
;>@for     for slot in range(20):
;>         if mem[rec] == 0:            # a free slot
	ld a, [de]
	or a
;>             break
	jr z, .free

;>@rec         rec += 0x95
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@for
	inc b
	ld a, b
	cp $14
	jr nz, .find

;>     else:
;>         PrintSystemText(0x024B)      # "The monster farm is full! ... replace one ...?"
	ld hl, $024b
	call PrintSystemText
;>         wTitleStep += 1
;>         return
	ld hl, wTitleStep
	inc [hl]
	ret


.free
;>@copy     copy(wMonsters + 19 * 0x95, wBreedParent2, 0x95)   # the received monster into the last slot
	ld hl, wMonsters + 19 * $95
	ld de, wBreedParent2
	ld b, $95

.copy
;=@copy
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .copy

;>     CopyFromSRAM_18(wPartyCount, sPartyCount, 7)   # party as saved
	di
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call CopyFromSRAM_18
;>     CopyFromSRAM_18(wLibraryFlags, sLibraryFlags, 0x20)
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call CopyFromSRAM_18
	ei
;>     SetFlag(mem[wBreedParent2 + 9], wLibraryFlags)    # its species joins the library
	ld hl, wLibraryFlags
	ld a, [wBreedParent2 + 9]
	call SetFlag
;>     CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>     CopyToSRAM_18(wLibraryFlags, sLibraryFlags, 0x20)
	di
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call CopyToSRAM_18
;>     SaveMonsters()
	call SaveMonsters
	ei

.done
;> wTitleStep = 0x1A                    # leave
	ld a, $1a
	ld [wTitleStep], a
	ret


;@ def CopyFromSRAM_18(dest: hl, src: de, count: bc)
;@ path: save/sram
;@ Copies `count` bytes from battery RAM `src` to `dest`, enabling the battery RAM around it.
;@ test: skip switches the cartridge RAM on and off
CopyFromSRAM_18::
;> mem[0x0100] = 0x0A                   # battery RAM on
	ld a, $0a
	ld [$0100], a

.loop
;>@copy copy(dest, src, count)
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
;=@copy
	jr nz, .loop

;> mem[0x0100] = 0x00                   # battery RAM off
	ld a, $00
	ld [$0100], a
	ret


;@ def CopyToSRAM_18(src: hl, dest: de, count: bc)
;@ path: save/sram
;@ Copies `count` bytes from `src` into battery RAM at `dest`, enabling the battery RAM around it.
;@ test: skip switches the cartridge RAM on and off
CopyToSRAM_18::
;> mem[0x0100] = 0x0A
	ld a, $0a
	ld [$0100], a

.loop
;>@copy copy(dest, src, count)
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
;=@copy
	jr nz, .loop

;> mem[0x0100] = 0x00
	ld a, $00
	ld [$0100], a
	ret


;@ def VSResultShowReplaceYesNo()
;@ path: link/result
;@ Step 13: once the question is shown, draws the yes/no window under the banner.
;@ test: skip draws through helpers
VSResultShowReplaceYesNo::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawReplaceYesNo()
	call VSResultDrawReplaceYesNo
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultDrawReplaceYesNo()
;@ path: link/result
;@ Draws the banner, the text box frame and the yes/no window (VSReplaceYesNoWindow) into
;@ wTilemapBuffer, with the cursor wMenuChoice3.
;@ test: skip draws through helpers
VSResultDrawReplaceYesNo::
;> DrawBannerToBuffer()
	call DrawBannerToBuffer
;> DrawWindowLayout_18(0x2E07)          # the text box frame
	ld de, $2e07
	call DrawWindowLayout_18
;> DrawWindowLayout_18(VSReplaceYesNoWindow)
	ld de, VSReplaceYesNoWindow
	call DrawWindowLayout_18
;> MenuResetBlink_18()
	call MenuResetBlink_18
;> MenuDrawCursorAt_18(wMenuChoice3, VSReplaceYesNoCursor)
	ld de, VSReplaceYesNoCursor
	ld a, [wMenuChoice3]
	call MenuDrawCursorAt_18
	ret


;@ def VSResultReplaceYesNoInput()
;@ path: link/result
;@ Step 14: yes/no cursor of "replace one of your monsters?". Yes goes on to the monster/egg
;@ choice (step $1B); No or B lets the won monster go (step 15).
;@ test: skip draws through helpers
VSResultReplaceYesNoInput::
;> MoveMenuCursor_18(wMenuChoice3, 2, VSReplaceYesNoCursor)
	ld de, VSReplaceYesNoCursor
	ld hl, wMenuChoice3
	ld b, $02
	call MoveMenuCursor_18
;> if wJoyPressed & 0x02:             # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

.release
;>@rel     wTitleStep += 1                  # let it go
	ld hl, wTitleStep
	inc [hl]
	jp .done


;> elif wJoyPressed & 0x01:             # A
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:         # No
;>@rel2         wTitleStep += 1
	ld a, [wMenuChoice3]
	cp $81
	jr z, .release

;>     else:
;>         wLinkPartnerChoice = 0       # replace a monster (1 = an egg)
	xor a
	ld [wLinkPartnerChoice], a
;>         wTitleStep = 0x1B
	ld a, $1b
	ld [wTitleStep], a

.done
	ret


;@ path: link/result
;@ Cursor table of the yes/no window: screen offsets $012F and $016F, $FFFF ends.
VSReplaceYesNoCursor::
	dw $012f, $016f, $ffff

;@ def VSResultReleasePrize()
;@ path: link/result
;@ Step 15: "<monster> is returned to the wild." (the won monster is not kept).
;@ test: skip calls routines in other banks
VSResultReleasePrize::
;> PrintSystemText(0x024C)
	ld hl, $024c
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultReleaseWait()
;@ path: link/result
;@ Step 16: waits for the message, then leaves (step $1A).
VSResultReleaseWait::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wTitleStep = 0x1A
	ld a, $1a
	ld [wTitleStep], a
	ret


;@ def VSResultStartReplaceList()
;@ path: link/result
;@ Step 17: lists the farm monsters (or eggs, wLinkPartnerChoice bit 0) the won monster may
;@ replace and asks "Replace with which monster?" / "... which egg?"; with none to choose
;@ from: "No egg." (step $1E).
;@ test: skip reads battery RAM
VSResultStartReplaceList::
;> if CountReplaceCandidates() == 0:
	call CountReplaceCandidates
	or a
	jr nz, .some

;>     PrintSystemText(0x0252)          # "No egg."
	ld hl, $0252
	call PrintSystemText
;>     wTitleStep = 0x1E
;>     return
	ld a, $1e
	ld [wTitleStep], a
	ret


.some
;> ListReplaceCandidates()
	call ListReplaceCandidates
;>@text PrintSystemText(0x0253 if wLinkPartnerChoice & 1 else 0x024D)   # which egg / which monster
	ld hl, $024d
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .print

	ld hl, $0253

.print
;=@text
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def CountReplaceCandidates() -> a
;@ path: link/result
;@ Counts the monsters the won monster may replace into wTitleListCount: records at the farm
;@ (state not 0 and not 2 = in the party), not in the party a script put aside, and eggs when
;@ wLinkPartnerChoice bit 0 is set, hatched monsters when it is clear.
;@ test: skip reads battery RAM
CountReplaceCandidates::
;> rec = wMonsters; count = 0
	ld de, wMonsters
	ld b, $00
	ld c, $00

.loop
;>@for for slot in range(20):
	push de
;>@ok     if mem[rec] not in (0, 2) and not IsInStashedParty_18(slot):
	ld a, [de]
	or a
	jr z, .next

	cp $02
	jr z, .next

;=@ok
	push bc
	push de
	push hl
	call IsInStashedParty_18
;=@ok
	pop hl
	pop de
	pop bc
	jr nz, .next

;>@egg         egg = mem[rec + 0x63]       # 0 monster, 1 or 2 egg
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>         kind = wLinkPartnerChoice & 1   # 1 = eggs wanted
	ld a, [wLinkPartnerChoice]
	and $01
	ld l, a
;>@k         if (egg | egg >> 1) & 1 == kind:
	ld a, [de]
	ld h, a
	srl a
	or h
;=@k
	and $01
	xor l
	jr nz, .next

;>             count += 1
	inc c

.next
;>@rec     rec += 0x95
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
;=@rec
	adc $00
	ld d, a
;=@for
	inc b
	ld a, b
	cp $14
	jr nz, .loop

;> wTitleListCount = count
;> return count
	ld a, c
	ld [wTitleListCount], a
	ret


;@ def ListReplaceCandidates()
;@ path: link/result
;@ Fills the list in wSceneObjects (20 bytes, $FF = end) with the slots CountReplaceCandidates
;@ counts.
;@ test: skip reads battery RAM
ListReplaceCandidates::
;> fill(wSceneObjects, 0xFF, 20)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> out = wSceneObjects
	ld hl, wSceneObjects
;> rec = wMonsters
	ld de, wMonsters
	ld b, $00
	ld c, $00

.loop
;>@for for slot in range(20):
	push de
;>@ok     if mem[rec] not in (0, 2) and not IsInStashedParty_18(slot):
	ld a, [de]
	or a
	jr z, .next

	cp $02
	jr z, .next

;=@ok
	push bc
	push de
	push hl
	call IsInStashedParty_18
;=@ok
	pop hl
	pop de
	pop bc
	jr nz, .next

;>@egg         egg = mem[rec + 0x63]
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>         kind = wLinkPartnerChoice & 1
	push hl
	ld a, [wLinkPartnerChoice]
	and $01
	ld l, a
;>@k         if (egg | egg >> 1) & 1 == kind:
	ld a, [de]
	ld h, a
	srl a
	or h
;=@k
	and $01
	xor l
	pop hl
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
	ld a, d
;=@rec
	adc $00
	ld d, a
;=@for
	inc c
	inc b
	ld a, b
	cp $14
	jr nz, .loop

	ret


;@ def IsInStashedParty_18(slot: b) -> a
;@ path: link/result
;@ When the saved game has no party, checks whether monster `slot` is in the party a script put
;@ aside (wSavedParty as saved in battery RAM). Returns 1 if so (flag nonzero), else 0.
;@ test: skip reads battery RAM
IsInStashedParty_18::
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


;@ def VSResultShowReplaceList()
;@ path: link/result
;@ Step 18: once the question is shown, draws the list of monsters (or eggs) to replace.
;@ test: skip draws through helpers
VSResultShowReplaceList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawCursorMonName()
	call VSResultDrawCursorMonName
;> VSResultDrawListNames()
	call VSResultDrawListNames
;> VSResultDrawListWindows()
	call VSResultDrawListWindows
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultDrawListWindows()
;@ path: link/result
;@ Draws the list screen into wTilemapBuffer: the monster/egg menu under the banner, then for
;@ monsters the line with the chosen monster's name, sex and level and the 4-row name list,
;@ for eggs the wider 4-row species list; then the list cursor.
;@ test: skip draws through helpers
VSResultDrawListWindows::
;> VSResultDrawKindMenu()
	call VSResultDrawKindMenu
;> if wLinkPartnerChoice & 1:           # eggs
;>     DrawWindowLayout_18(VSEggListWindow)
	ld de, VSEggListWindow
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, .draw

;> else:
;>     DrawWindowLayout_18(VSCursorMonWindow)
	ld de, VSCursorMonWindow
	call DrawWindowLayout_18
;>     VSResultDrawCursorMonLevel()
	call VSResultDrawCursorMonLevel
;>@list     DrawWindowLayout_18(VSReplaceListWindow)
	ld de, VSReplaceListWindow

.draw
;=@list
	call DrawWindowLayout_18
;> MenuResetBlink_18()
	call MenuResetBlink_18
;>@marks marks = VSReplaceEggListCursor if wLinkPartnerChoice & 1 else VSReplaceListCursor
	ld de, VSReplaceListCursor
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .cursor

	ld de, VSReplaceEggListCursor

.cursor
;>@cur MenuDrawListCursor_18(wListCursor, marks, 4, wTitleListCount)
	ld b, $04
	ld a, [wTitleListCount]
	ld c, a
	ld hl, wListCursor
;=@cur
	call MenuDrawListCursor_18
	ret


;@ def VSResultDrawListNames()
;@ path: link/result
;@ Draws the entries of the current list page (wListPage, 4 per page, from the list in
;@ wSceneObjects): monster names into the tiles from $9000 on, or for eggs their species names
;@ and sex marks (VSResultDrawEggNames).
;@ test: skip writes VRAM
VSResultDrawListNames::
;>@entry entry = wSceneObjects + wListPage * 4
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@entry
	ld a, $00
	adc d
	ld d, a
;> if wLinkPartnerChoice & 1:
;>     return VSResultDrawEggNames(entry)
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, VSResultDrawEggNames

;> tiles = 0x9000
	ld hl, $9000
;> for i in range(4):                   # the fourth by running on into VSResultDrawListName
;>     entry, tiles = VSResultDrawListName(entry, tiles)
	call VSResultDrawListName
	call VSResultDrawListName
	call VSResultDrawListName

;@ def VSResultDrawListName(entry: de, tiles: hl) -> (de, hl)
;@ path: link/result
;@ The name of the monster in list entry `entry` into the 4 tiles at `tiles` (blank for an
;@ empty entry); returns the next entry and tiles.
;@ test: skip writes VRAM
VSResultDrawListName::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>@name     DrawNameTiles_18(MonsterField(mem[entry], wMonName), tiles)
	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	pop hl
	push hl
	call DrawNameTiles_18
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


;@ def VSResultDrawEggNames(entry: de)
;@ path: link/result
;@ Egg list page: the species names of the four entries into tiles from $9000 on (9 tiles each),
;@ then their sex marks.
;@ test: skip writes VRAM
VSResultDrawEggNames::
;> tiles = 0x9000
	ld hl, $9000
;> for i in range(4):
;>     entry, tiles = VSResultDrawEggName(entry, tiles)
	call VSResultDrawEggName
	call VSResultDrawEggName
	call VSResultDrawEggName
	call VSResultDrawEggName
;> VSResultDrawEggGenders()
	call VSResultDrawEggGenders
	ret


;@ def VSResultDrawEggName(entry: de, tiles: hl) -> (de, hl)
;@ path: link/result
;@ The species name (text group 5) of the egg in list entry `entry` into the 9 tiles at `tiles`
;@ (blank for an empty entry); returns the next entry and tiles.
;@ test: skip writes VRAM
VSResultDrawEggName::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>     wTextIndex = mem[MonsterField(mem[entry], wMonRecSpecies)]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
;>     wTextGroup = 5                   # species names
	ld a, $05
	ld [wTextGroup], a
;>     DrawTextTiles_18(tiles, 1, 9)
	ld de, $0901
	pop hl
	push hl
	call DrawTextTiles_18
;>@ret     return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
;=@ret
	adc $00
	ld h, a
	pop de
	inc de
	ret


;> else:
;>     for i in range(72):              # blank tiles
.blank
	ld b, $48

.blankLoop
;>         tiles = WriteVRAMInc(0xFF, tiles)
	ld a, $ff
	call WriteVRAMInc
;>         tiles = WriteVRAMInc(0x00, tiles)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blankLoop

;>@ret2     return entry + 1, tiles + 0x90
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
;=@ret2
	adc $00
	ld h, a
	pop de
	inc de
	ret


;@ def VSResultDrawEggGenders()
;@ path: link/result
;@ The sex marks of the four eggs of the current list page into the tiles from $9240 on.
;@ test: skip writes VRAM
VSResultDrawEggGenders::
;>@entry entry = wSceneObjects + wListPage * 4
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;=@entry
	ld a, $00
	adc d
	ld d, a
;> tiles = 0x9240
	ld hl, $9240
;> for i in range(4):                   # the fourth by running on into VSResultDrawEggGender
;>     entry, tiles = VSResultDrawEggGender(entry, tiles)
	call VSResultDrawEggGender
	call VSResultDrawEggGender
	call VSResultDrawEggGender

;@ def VSResultDrawEggGender(entry: de, tiles: hl) -> (de, hl)
;@ path: link/result
;@ The sex mark of the egg in list entry `entry` into the tile at `tiles`: the male or female
;@ sign ($A7 / $A8) when its sex is known (egg state 2), else $98; blank for an empty entry.
;@ Returns the next entry and tile.
;@ test: skip prints text
VSResultDrawEggGender::
;> if mem[entry] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>     egg = MonsterField(mem[entry], wMonEgg)
	ld hl, wMonEgg
	call MonsterField
;>     mark = 0x98                      # sex unknown
;>     if mem[egg] == 2:
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, .print

;>@sex         mark = 0xA7 + (mem[egg - 0x58] & 1)   # wMonGender of the record
	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@sex
	ld a, [hl]
	and $01
	add $a7

.print
;>     wTextArg0[0] = mark; wTextArg0[1] = 0xF0
	ld [wTextArg0], a
	ld a, $f0
	ld [wTextArg0 + 1], a
;>@saved     saved_tiles = wTextTiles
	pop hl
	push hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [wTextTiles + 1]
	ld b, a
;=@saved
	push bc
;>     saved_box = (wTextBoxLines, wTextBoxLineLength)
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;>     wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;>     wTextBoxLines = 1; wTextBoxLineLength = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;>     wTextGroup = 2; wTextIndex = 0      # prints wTextArg0
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
;>     PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>     wTextTiles = saved_tiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [wTextTiles + 1], a
;>     wTextBoxLines = saved_box[0]
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = saved_box[1]
	ld a, d
	ld [wTextBoxLineLength], a
;>@ret     return entry + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
;=@ret
	adc $00
	ld h, a
	pop de
	inc de
	ret


;> else:
;>     for i in range(8):               # blank tile
.blank
	ld b, $08

.blankLoop
;>         tiles = WriteVRAMInc(0xFF, tiles)
	ld a, $ff
	call WriteVRAMInc
;>         tiles = WriteVRAMInc(0x00, tiles)
	xor a
	call WriteVRAMInc
	dec b
	jr nz, .blankLoop

;>@ret2     return entry + 1, tiles + 0x10
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
;=@ret2
	adc $00
	ld h, a
	pop de
	inc de
	ret


;@ def VSResultDrawCursorMonName()
;@ path: link/result
;@ Monster list only: the name of the monster under the cursor into the tiles at $9100 and its
;@ sex sign into the tile at $9140.
;@ test: skip prints text
VSResultDrawCursorMonName::
;> if wLinkPartnerChoice & 1:
;>     return
	ld a, [wLinkPartnerChoice]
	and $01
	ret nz

;>@slot slot = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@slot
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
;=@slot
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
;>@name DrawNameTiles_18(MonsterField(slot, wMonName), 0x9100)
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, $9100
	call DrawNameTiles_18
;>@sex wTextArg0[0] = 0xA7 + (mem[MonsterField(slot, wMonGender)] & 1)
	pop af
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld hl, $9140
	and $01
;=@sex
	add $a7
	ld [wTextArg0], a
;> wTextArg0[1] = 0xF0
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
;> wTextTiles = 0x9140
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
;> wTextGroup = 2; wTextIndex = 0      # prints wTextArg0
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


;@ def VSResultDrawCursorMonLevel()
;@ path: link/result
;@ Monster list only: "Lv" ($DE) and the level of the monster under the cursor at screen offset
;@ $0161 of wTilemapBuffer, and at $0169 the mark $E3 when it is in the party (or the party a
;@ script put aside), else blank.
;@ test: skip reads battery RAM
VSResultDrawCursorMonLevel::
;> if wLinkPartnerChoice & 1:
;>     return
	ld a, [wLinkPartnerChoice]
	and $01
	ret nz

;>@slot slot = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@slot
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
;=@slot
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
;> level = mem[MonsterField(slot, wMonLevel)]
	ld hl, wMonLevel
	call MonsterField
	ld c, [hl]
	ld b, $00
;> p = TilemapBufferAddr_18(0x0161)
	ld hl, $0161
	call TilemapBufferAddr_18
;> mem[p] = 0xDE                        # "Lv"
	ld a, $de
	ld [hli], a
;> mem[p + 1] = mem[p + 2] = 0xE0
	ld a, $e0
	ld [hli], a
	ld a, $e0
	ld [hld], a
;> PrintTwoDigits_18(level, p + 1)
	call PrintTwoDigits_18
;>@st if mem[MonsterField(slot, wMonsters)] == 2 or IsInStashedParty_18(slot):
	pop af
	push af
	ld hl, wMonsters
	call MonsterField
	pop af
	ld b, a
;=@st
	ld a, [hl]
	cp $02
	jr z, .inParty

	call IsInStashedParty_18
	jr nz, .inParty

;>@yes     mem[TilemapBufferAddr_18(0x0169)] = 0xE3   # in the party
;> else:
;>@no     mem[TilemapBufferAddr_18(0x0169)] = 0xE0
	jr .notInParty

.inParty
;=@yes
	ld hl, $0169
	call TilemapBufferAddr_18
	ld a, $e3
	ld [hl], a
	ret


.notInParty
;=@no
	ld hl, $0169
	call TilemapBufferAddr_18
	ld a, $e0
	ld [hl], a
	ret


;@ def VSResultReplaceListInput()
;@ path: link/result
;@ Step 19: moves the cursor through the list (redrawing the name line and the page as they
;@ change). B goes back to the monster/egg choice (step $1D); A picks the entry
;@ (wCurPartyMember) and opens the INFO / OK menu.
;@ test: skip draws through helpers
VSResultReplaceListInput::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;>@marks marks = VSReplaceEggListCursor if wLinkPartnerChoice & 1 else VSReplaceListCursor
	ld de, VSReplaceListCursor
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .move

	ld de, VSReplaceEggListCursor

.move
;>@old old_page = wListPage; old_cursor = wListCursor
	ld hl, wListCursor
	ld a, [wTitleListCount]
	ld c, a
	ld b, $04
	inc hl
;=@old
	ld a, [hld]
	push af
	ld a, [hl]
	push af
;> MovePagedListCursor_18(wListCursor, 4, wTitleListCount, marks)
	call MovePagedListCursor_18
;> if wListCursor != old_cursor:
	pop af
	ld hl, wListCursor
	cp [hl]
	jr z, .samePos

;>     VSResultDrawCursorMonName()
	call VSResultDrawCursorMonName
;>     VSResultDrawCursorMonLevel()
	call VSResultDrawCursorMonLevel
;>     CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18

.samePos
;> if wListPage != old_page:
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .samePage

;>     VSResultDrawListNames()
	call VSResultDrawListNames
;>     VSResultDrawCursorMonName()
	call VSResultDrawCursorMonName
;>     VSResultDrawCursorMonLevel()
	call VSResultDrawCursorMonLevel
;>     CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18

.samePage
;> if wJoyPressed & 0x02:             # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintSystemText(0x0251)          # "Replace with which monster?"
	ld hl, $0251
	call PrintSystemText
;>     ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;>     VSResultDrawKindMenu()
	call VSResultDrawKindMenu
;>     CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;>     wTitleStep = 0x1D                # back to the monster / egg choice
	ld a, $1d
	ld [wTitleStep], a
	jr .done

;> elif wJoyPressed & 0x01:             # A
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wLinkRefused = 0                 # cursor of the INFO / OK menu
	xor a
	ld [wLinkRefused], a
;>@slot     wCurPartyMember = wSceneObjects[wListPage * 4 + (wListCursor & 0x7F)]
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@slot
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
;=@slot
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;>     wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]

.done
	ret


;@ path: link/result
;@ Cursor table of the monster list: the page number position ($0145), then the four rows; $FFFF
;@ ends.
VSReplaceListCursor::
	dw $0145, $0061, $00a1, $00e1, $0121, $ffff

;@ path: link/result
;@ Cursor table of the egg list: the page number position ($010B), then the four rows; $FFFF
;@ ends.
VSReplaceEggListCursor::
	dw $010b, $0021, $0061, $00a1, $00e1, $ffff

;@ def VSResultReplacePicked()
;@ path: link/result
;@ Step 20: goes on to the INFO / OK menu.
VSResultReplacePicked::
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultShowInfoOk()
;@ path: link/result
;@ Step 21: once the text is done, draws the INFO / OK menu next to the list.
;@ test: skip draws through helpers
VSResultShowInfoOk::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawInfoOk()
	call VSResultDrawInfoOk
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultDrawInfoOk()
;@ path: link/result
;@ Draws the list screen and on it the INFO / OK window (a narrower one for the egg list), with
;@ the cursor wLinkRefused.
;@ test: skip draws through helpers
VSResultDrawInfoOk::
;> VSResultDrawListWindows()
	call VSResultDrawListWindows
;>@win DrawWindowLayout_18(VSEggInfoOkWindow if wLinkPartnerChoice & 1 else VSInfoOkWindow)
	ld de, VSInfoOkWindow
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .window

	ld de, VSEggInfoOkWindow

.window
;=@win
	call DrawWindowLayout_18
;> MenuResetBlink_18()
	call MenuResetBlink_18
;>@marks marks = VSEggInfoOkCursor if wLinkPartnerChoice & 1 else VSInfoOkCursor
	ld de, VSInfoOkCursor
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .cursor

	ld de, VSEggInfoOkCursor

.cursor
;> MenuDrawCursorAt_18(wLinkRefused, marks)
	ld a, [wLinkRefused]
	call MenuDrawCursorAt_18
	ret


;@ def VSResultInfoOkInput()
;@ path: link/result
;@ Step 22: INFO / OK menu of the picked monster. B goes back to the list (step 19), INFO shows
;@ its status screen (step 23), OK replaces it (step 25).
;@ test: skip draws through helpers
VSResultInfoOkInput::
;>@marks marks = VSEggInfoOkCursor if wLinkPartnerChoice & 1 else VSInfoOkCursor
	ld de, VSInfoOkCursor
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .move

	ld de, VSEggInfoOkCursor

.move
;> MoveMenuCursor_18(wLinkRefused, 2, marks)
	ld hl, wLinkRefused
	ld b, $02
	call MoveMenuCursor_18
;> if wJoyPressed & 0x02:             # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;>     VSResultDrawCursorMonName()
	call VSResultDrawCursorMonName
;>     VSResultDrawListNames()
	call VSResultDrawListNames
;>     VSResultDrawListWindows()
	call VSResultDrawListWindows
;>     CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;>     wTitleStep -= 3                  # back to the list
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
	ld hl, wTitleStep
	dec [hl]
;>     return
	jp .done


;> elif wJoyPressed & 0x01:             # A
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wLinkRefused != 0x81:         # INFO
	ld a, [wLinkRefused]
	cp $81
	jr z, .ok

;>         wFieldMenuState = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	jp .done


;>     else:                            # OK
;>         wTitleStep += 3
.ok
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
	ld hl, wTitleStep
	inc [hl]
;>         ReadSRAMByte(sPartyCount)    # (the result is not used)
	ld hl, sPartyCount
	call ReadSRAMByte
	or a
	jr z, .done

.done
	ret


;@ path: link/result
;@ Cursor table of the INFO / OK window of the monster list: screen offsets $002E and $006E,
;@ $FFFF ends.
VSInfoOkCursor::
	dw $002e, $006e, $ffff

;@ path: link/result
;@ Cursor table of the INFO / OK window of the egg list: screen offsets $002D and $006D, $FFFF
;@ ends.
VSEggInfoOkCursor::
	dw $002d, $006d, $ffff

;@ path: unused
;@ Code that nothing calls: reads a monster slot from battery RAM at hl; unless it is $FF, the
;@ monster wCurPartyMember or a dead one (status bit 7 of its saved record), it adds 1 to b.
UnusedCountSlot_18::
	db $c5, $cd, $ee, $20
	db $c1, $fe, $ff, $c8, $4f, $fa, $c0, $ca, $b9, $c8, $c5, $79, $21, $45, $a2, $cd
	db $3b, $22, $cd, $ee, $20, $c1, $cb, $7f, $c0, $04, $c9

;@ def VSResultShowStatus()
;@ path: link/result
;@ Step 23: runs the monster status screen for the picked monster (wCurPartyMember) until it
;@ closes.
;@ test: skip calls routines in other banks
VSResultShowStatus::
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> wFieldFlags = 0
	xor a
	ld [wFieldFlags], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep:                     # closed
;>     wTitleStep += 1
	ld a, [wMenuSubStep]
	or a
	ret z

	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultStatusDone()
;@ path: link/result
;@ Step 24: after the status screen, reloads the tiles it replaced (banner letters, window
;@ symbols, Terry's sprite, the menu words), repeats the question, redraws the list and goes
;@ back to the INFO / OK menu (step 20).
;@ test: skip calls routines in other banks
VSResultStatusDone::
;> DecompressVRAM(0x3F, 0x03, 0x8800)
	ld de, $3f03
	ld hl, $8800
	call DecompressVRAM
;> DecompressVRAM(0x2E, 0x00, 0x8D00)
	ld de, $2e00
	ld hl, $8d00
	call DecompressVRAM
;> DecompressVRAM(0x2F, 0x00, 0x8000)
	ld de, $2f00
	ld hl, $8000
	call DecompressVRAM
;> wTextGroup = 2; wTextIndex = 0x4A
	ld a, $02
	ld [wTextGroup], a
	ld a, $4a
	ld [wTextIndex], a
;> DrawTextTiles_18(0x96C0, 1, 16)      # the menu words
	ld hl, $96c0
	ld de, $1001
	call DrawTextTiles_18
;>@text PrintSystemText(0x0253 if wLinkPartnerChoice & 1 else 0x024D)   # which egg / which monster
	ld hl, $024d
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .print

	ld hl, $0253

.print
;=@text
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawCursorMonName()
	call VSResultDrawCursorMonName
;> VSResultDrawListNames()
	call VSResultDrawListNames
;> wTitleStep = 0x14
	ld a, $14
	ld [wTitleStep], a
	ret


;@ def VSResultReplaceMonster()
;@ path: link/result
;@ Step 25: the picked monster (or egg) is let go and the won monster takes its place: the
;@ library gets its species, the records are tidied and saved. For a monster: "<monster> is
;@ returned to the wild."
;@ test: skip saves to battery RAM
VSResultReplaceMonster::
;>@p p = wSceneObjects + wListPage * 4 + (wListCursor & 0x7F)
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
;=@p
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;> if not wLinkPartnerChoice & 1:      # a monster: its name for the message
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, .save

;>@name     CopyName(MonsterField(mem[p], wMonName), wTextArg1)
	push hl
	ld a, [hl]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@name
	ld hl, wTextArg1
	call CopyName
	pop hl

.save
;> CopyFromSRAM_18(wPartyCount, sPartyCount, 7)
	push hl
	di
	ld hl, wPartyCount
	ld de, sPartyCount
	ld bc, $0007
	call CopyFromSRAM_18
;> CopyFromSRAM_18(wLibraryFlags, sLibraryFlags, 0x20)
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call CopyFromSRAM_18
	ei
;> SetFlag(mem[wBreedParent2 + 9], wLibraryFlags)    # the won monster's species
	ld hl, wLibraryFlags
	ld a, [wBreedParent2 + 9]
	call SetFlag
;> mem[MonsterField(mem[p], wMonsters)] = 0          # let the picked one go
	pop hl
	ld a, [hl]
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>@copy copy(wMonsters + 19 * 0x95, wBreedParent2, 0x95)   # the won monster into the last slot
	ld hl, wMonsters + 19 * $95
	ld de, wBreedParent2
	ld b, $95

.copy
;=@copy
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .copy

;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> CopyToSRAM_18(wLibraryFlags, sLibraryFlags, 0x20)
	di
	ld hl, wLibraryFlags
	ld de, sLibraryFlags
	ld bc, $0020
	call CopyToSRAM_18
;> SaveMonsters()
	call SaveMonsters
	ei
;> if not wLinkPartnerChoice & 1:
;>     PrintSystemText(0x0254)          # "<monster> is returned to the wild."
	ld a, [wLinkPartnerChoice]
	and $01
	jr nz, .next

	ld hl, $0254
	call PrintSystemText

.next
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultEnd()
;@ path: link/result
;@ Step 26: once the text is done, ends the link and goes back to the title menu (game mode 0,
;@ step 1) with a fade-out.
;@ test: skip touches the link state
VSResultEnd::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wGameMode = 0; wGameModeStep = 1
	ld hl, wGameMode
	ld a, $00
	ld [hli], a
	ld a, $01
	ld [hli], a
;> mem[wGameMode + 2] = 0; mem[wGameMode + 3] = 0
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
;> wSerialLock = 0; wLinkActive = 0
	ld [wSerialLock], a
	ld [wLinkActive], a
;> wLinkReceivedLast = 0; wLinkSendByte = 0
	xor a
	ld [wLinkReceivedLast], a
	xor a
	ld [wLinkSendByte], a
;> wLinkCommand = 0
	xor a
	ld [wLinkCommand], a
;> StartFade(0x04)                      # fade out
	ld a, $04
	call StartFade
	ret


;@ def VSResultAskKind()
;@ path: link/result
;@ Step 27: "Replace with which monster?" before the monster / egg choice.
;@ test: skip calls routines in other banks
VSResultAskKind::
;> PrintSystemText(0x0251)
	ld hl, $0251
	call PrintSystemText
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultShowKindMenu()
;@ path: link/result
;@ Step 28: once the text is done, draws the MON / EGG menu.
;@ test: skip draws through helpers
VSResultShowKindMenu::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawKindMenu()
	call VSResultDrawKindMenu
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;> wTitleStep += 1
	ld hl, wTitleStep
	inc [hl]
	ret


;@ def VSResultDrawKindMenu()
;@ path: link/result
;@ Draws the yes/no screen and on it the MON / EGG window (VSKindWindow), with the cursor
;@ wLinkPartnerChoice (0 monsters, 1 eggs).
;@ test: skip draws through helpers
VSResultDrawKindMenu::
;> VSResultDrawReplaceYesNo()
	call VSResultDrawReplaceYesNo
;> DrawWindowLayout_18(VSKindWindow)
	ld de, VSKindWindow
	call DrawWindowLayout_18
;> MenuResetBlink_18()
	call MenuResetBlink_18
;> MenuDrawCursorAt_18(wLinkPartnerChoice, VSKindMenuCursor)
	ld de, VSKindMenuCursor
	ld a, [wLinkPartnerChoice]
	call MenuDrawCursorAt_18
	ret


;@ def VSResultKindInput()
;@ path: link/result
;@ Step 29: MON / EGG choice (wLinkPartnerChoice). A opens the list of that kind (step 17); B
;@ goes back to the yes/no question (step 14).
;@ test: skip draws through helpers
VSResultKindInput::
;> MoveMenuCursor_18(wLinkPartnerChoice, 2, VSKindMenuCursor)
	ld de, VSKindMenuCursor
	ld hl, wLinkPartnerChoice
	ld b, $02
	call MoveMenuCursor_18
;> if wJoyPressed & 0x02:             # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintSystemText(0x024F)          # "Do you want to replace one of your monsters ...?"
	ld hl, $024f
	call PrintSystemText
;>     ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;>     VSResultDrawReplaceYesNo()
	call VSResultDrawReplaceYesNo
;>     CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;>     wTitleStep = 0x0E
	ld a, $0e
	ld [wTitleStep], a
	jr .done

;> elif wJoyPressed & 0x01:             # A
.notB
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wTitleStep = 0x11
	ld a, $11
	ld [wTitleStep], a
;>     wListCursor = 0; wListPage = 0
	xor a
	ld [wListCursor], a
	ld [wListPage], a

.done
	ret


;@ path: link/result
;@ Cursor table of the MON / EGG window: screen offsets $002F and $006F, $FFFF ends.
VSKindMenuCursor::
	dw $002f, $006f, $ffff

;@ def VSResultNoEgg()
;@ path: link/result
;@ Step 30: after "No egg.", asks again and redraws the MON / EGG menu (step 29).
;@ test: skip draws through helpers
VSResultNoEgg::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> PrintSystemText(0x0251)
	ld hl, $0251
	call PrintSystemText
;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawKindMenu()
	call VSResultDrawKindMenu
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;> wTitleStep = 0x1D
	ld a, $1d
	ld [wTitleStep], a
	ret


;@ def VSResultBackToList()
;@ path: link/result
;@ Step 31 (no step leads here): redraws the list and asks again, then runs the list (step 19).
;@ test: skip draws through helpers
VSResultBackToList::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> ClearTilemapBuffer_18()
	call ClearTilemapBuffer_18
;> VSResultDrawCursorMonName()
	call VSResultDrawCursorMonName
;> VSResultDrawListNames()
	call VSResultDrawListNames
;> VSResultDrawListWindows()
	call VSResultDrawListWindows
;> CopyTilemapBufferToVram_18()
	call CopyTilemapBufferToVram_18
;>@text PrintSystemText(0x0253 if wLinkPartnerChoice & 1 else 0x024D)
	ld hl, $024d
	ld a, [wLinkPartnerChoice]
	and $01
	jr z, .print

	ld hl, $0253

.print
;=@text
	call PrintSystemText
;> wTitleStep = 0x13
	ld a, $13
	ld [wTitleStep], a
	ret


;@ def VSResultDrawGiver()
;@ path: link/result
;@ Every frame: when there is a prize monster, keeps drawing the old master (facing left at X
;@ wMenuChoice) from step 12 on, except while the status screen is open (steps 23 and 24).
;@ test: skip draws sprites through far calls
VSResultDrawGiver::
;> slot = VSPrizeRecordSlot()
	call VSPrizeRecordSlot
;> if slot == 0xFF:
;>     return
	cp $ff
	ret z

;> if not mem[MonsterField(slot, wMonsters)]:
;>     return
	ld hl, wMonsters
	call MonsterField
	ld a, [hl]
	or a
	ret z

;> if wTitleStep < 0x0C:
;>     return
	ld a, [wTitleStep]
	cp $0c
	ret c

;> if wTitleStep in (0x17, 0x18):
;>@ret     return
	cp $17
	ret z

;=@ret
	cp $18
	ret z

;> DrawTrainerSpriteFlipped(wMenuChoice)
	ld a, [wMenuChoice]
	call DrawTrainerSpriteFlipped
	ret


;@ def DrawTrainerSpriteFlipped(x: a)
;@ path: link/result
;@ DrawTrainerSpriteAttr with the sprite mirrored (attribute $20: facing left).
;@ test: skip draws sprites through far calls
DrawTrainerSpriteFlipped::
;> return DrawTrainerSpriteAttr(x, 0x20)
	ld c, $20
	jr DrawTrainerSpriteAttr

;@ def DrawTrainerSprite(x: a)
;@ path: link/result
;@ DrawTrainerSpriteAttr unmirrored (facing right); runs on into it.
;@ test: skip draws sprites through far calls
DrawTrainerSprite::
;> return DrawTrainerSpriteAttr(x, 0x00)
	ld c, $00

;@ def DrawTrainerSpriteAttr(x: a, attr: c)
;@ path: link/result
;@ Draws a walking trainer (actor sprite set 0, Terry's) at X `x`, Y $58 with sprite attribute
;@ `attr`; the walking frame (2 or 3) changes every 16 frames. X from $E0 on is off screen and
;@ draws nothing.
;@ test: skip draws sprites through far calls
DrawTrainerSpriteAttr::
;> if x >= 0xE0:
;>     return
	cp $e0
	ret nc

;> hSpriteX = x
	ld hl, hSpriteX
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x58
	ld a, $58
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteSet = 0
	ld a, $00
	ld [hli], a
;>@frame hSpriteFrame = 3 if wFrameCounter & 0x10 else 2
	ld b, $02
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame

	ld b, $03

.frame
;=@frame
	ld a, b
	ld [hli], a
;> hSpriteTileBase = 0
	ld a, $00
	ld [hli], a
;> hSpriteAttr = attr
	ld a, c
	ld [hl], a
;> DrawActorSprite()
	ld hl, far_DrawActorSprite
	rst $10
	ret


;@ def DrawPrizeMonsterSprite(x: a)
;@ path: link/result
;@ Draws the prize monster at X `x`, Y $58, facing left: its walking sprite (actor set species +
;@ $10, tiles from $20 on, frame 2 or 3 changing every 16 frames), or for an egg the egg sprite
;@ (character set $55). X from $E0 on draws nothing. (The two bytes after the jump are an
;@ unused unmirrored entry, `ld c, $00`.)
;@ test: skip draws sprites through far calls
DrawPrizeMonsterSprite::
;> attr = 0x20
	ld c, $20
	jr .draw

	db $0e, $00

.draw
;> if x >= 0xE0:
;>     return
	cp $e0
	ret nc

;> hSpriteX = x
	ld hl, hSpriteX
	ld [hli], a
	ld a, $00
	ld [hli], a
;> hSpriteY = 0x58
	ld a, $58
	ld [hli], a
	ld a, $00
	ld [hli], a
;>@egg if mem[MonsterField(VSPrizeRecordSlot(), wMonEgg)] == 0:
	push bc
	push de
	push hl
	call VSPrizeRecordSlot
	ld hl, wMonEgg
	call MonsterField
;=@egg
	ld a, [hl]
	pop hl
	pop de
	pop bc
	or a
	jr nz, .egg

;>@sp     hSpriteSet = mem[MonsterField(VSPrizeRecordSlot(), wMonRecSpecies)] + 0x10
	push bc
	push de
	push hl
	call VSPrizeRecordSlot
	ld hl, wMonRecSpecies
	call MonsterField
;=@sp
	ld a, [hl]
	pop hl
	pop de
	pop bc
	add $10
	ld [hli], a
;>@frame     hSpriteFrame = 3 if wFrameCounter & 0x10 else 2
	ld b, $02
	ld a, [wFrameCounter]
	bit 4, a
	jr z, .frame

	ld b, $03

.frame
;=@frame
	ld a, b
	ld [hli], a
;>     hSpriteTileBase = 0x20
	ld a, $20
	ld [hli], a
;>     hSpriteAttr = attr
	ld a, c
	ld [hl], a
;>     DrawActorSprite()
	ld hl, far_DrawActorSprite
	rst $10
	ret


;> else:
;>     hSpriteSet = 0x55                # the egg
.egg
	ld a, $55
	ld [hli], a
;>     hSpriteFrame = 0
	ld a, $00
	ld [hli], a
;>     hSpriteTileBase = 0x20
	ld a, $20
	ld [hli], a
;>     hSpriteAttr = attr
	ld a, c
	ld [hl], a
;>     DrawCharacterSprite()
	ld hl, far_DrawCharacterSprite
	rst $10
	ret


;@ def DrawBannerLetter(i: a)
;@ path: link/result
;@ Draws letter `i` (0-7) of the "YOU WIN!" / "YOU LOSE" banner (WinBannerLetters or
;@ LoseBannerLetters by wBattlerReload) as 2 x 2 tiles at row 2, column 2 + 2i, both into
;@ wTilemapBuffer and the BG map. Tiles: $80 + the table value, the next three for the
;@ other quarters. A gap ($FF) draws nothing.
;@ test: skip writes VRAM
DrawBannerLetter::
;>@t table = LoseBannerLetters if wBattlerReload else WinBannerLetters
	push af
	ld de, WinBannerLetters
	ld a, [wBattlerReload]
	or a
	jr z, .table

	ld de, LoseBannerLetters

.table
;> t = mem[table + i]
	pop af
	push af
	add e
	ld e, a
	ld a, $00
	adc d
;>@pos pos = 0x42 + 2 * i
	ld d, a
	pop af
	add a
	ld hl, $0042
	add l
	ld l, a
;=@pos
	ld a, $00
	adc h
	ld h, a
;> if t == 0xFF:
;>     return
	ld a, [de]
	cp $ff
	ret z

;> PutBufferAndBgTile(pos, t + 0x80)
	add $80
	call PutBufferAndBgTile
;> PutBufferAndBgTile(pos + 1, t + 0x81)
	inc hl
	inc a
	call PutBufferAndBgTile
;>@down pos += 0x20                       # the row below
	push af
	ld a, l
	add $1f
	ld l, a
	ld a, h
	adc $00
;=@down
	ld h, a
	pop af
;> PutBufferAndBgTile(pos, t + 0x82)
	inc a
	call PutBufferAndBgTile
;> PutBufferAndBgTile(pos + 1, t + 0x83)
	inc hl
	inc a
	call PutBufferAndBgTile
	ret


;@ def PutBufferAndBgTile(pos: hl, tile: a)
;@ path: gfx/tilemap
;@ Writes `tile` at screen offset `pos` both into wTilemapBuffer and the BG map at $9800.
;@ test: skip writes VRAM
PutBufferAndBgTile::
;>@buf mem[wTilemapBuffer + pos] = tile
	push hl
	push af
	ld a, l
	add $00
	ld l, a
	ld a, h
;=@buf
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	pop hl
;>@bg WriteVRAM(tile, 0x9800 + pos)
	push hl
	push af
	ld a, l
	add $00
	ld l, a
	ld a, h
;=@bg
	adc $98
	ld h, a
	pop af
	call WriteVRAM
	pop hl
	ret


;@ def DrawBannerToBuffer()
;@ path: link/result
;@ Draws the whole banner into wTilemapBuffer (letter 3 is the gap in both words).
;@ test: skip reads tables from ROM
DrawBannerToBuffer::
;>@b for i in (0, 1, 2, 4, 5, 6, 7):      # the last by running on into DrawBannerLetterToBuffer
;>     DrawBannerLetterToBuffer(i)
	ld a, $00
	call DrawBannerLetterToBuffer
	ld a, $01
	call DrawBannerLetterToBuffer
;=@b
	ld a, $02
	call DrawBannerLetterToBuffer
	ld a, $04
	call DrawBannerLetterToBuffer
;=@b
	ld a, $05
	call DrawBannerLetterToBuffer
	ld a, $06
	call DrawBannerLetterToBuffer
;=@b
	ld a, $07

;@ def DrawBannerLetterToBuffer(i: a)
;@ path: link/result
;@ DrawBannerLetter into wTilemapBuffer only (row 2, column 2 + 2i).
;@ test: skip reads tables from ROM
DrawBannerLetterToBuffer::
;>@t table = LoseBannerLetters if wBattlerReload else WinBannerLetters
	push af
	ld de, WinBannerLetters
	ld a, [wBattlerReload]
	or a
	jr z, .table

	ld de, LoseBannerLetters

.table
;> t = mem[table + i]
	pop af
	push af
	add e
	ld e, a
	ld a, $00
	adc d
;>@p p = wTilemapBuffer + 0x42 + 2 * i
	ld d, a
	pop af
	add a
	ld hl, wTilemapBuffer + $42
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;> if t == 0xFF:
;>     return
	ld a, [de]
	cp $ff
	ret z

;> mem[p] = t + 0x80; mem[p + 1] = t + 0x81
	add $80
	ld [hli], a
	inc a
	ld [hl], a
;>@down mem[p + 0x20] = t + 0x82; mem[p + 0x21] = t + 0x83
	push af
	ld a, l
	add $1f
	ld l, a
	ld a, h
	adc $00
;=@down
	ld h, a
	pop af
	inc a
	ld [hli], a
;=@down
	inc a
	ld [hl], a
	ret


;@ path: link/result
;@ Banner letters of "YOU WIN!": per letter the first of its 4 tiles (relative to $80), $FF a
;@ gap.
WinBannerLetters::
	db $00, $04, $08, $ff, $0c, $10, $14, $18

;@ path: link/result
;@ Banner letters of "YOU LOSE" (the O shares the tiles of the first one).
LoseBannerLetters::
	db $00, $04, $08, $ff, $1c, $04, $20, $24

;@ def NextBgColumn_18(addr: hl) -> hl
;@ path: gfx/tilemap
;@ Moves a BG map address one column right, wrapping around within its 32-tile row.
;@ test: hl = rand(0x9800, 0x9BFF)
NextBgColumn_18::
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


;@ def TitleBgAddr_18(offset: hl) -> hl
;@ path: gfx/tilemap
;@ BG map address of a screen offset: wTitleBgMap + `offset`, wrapped around within the 1 KiB
;@ BG map.
;@ test: hl = rand(0, 0x3FF)
;@ test: wTitleBgMap = rand(0x9800, 0x9BFF)
TitleBgAddr_18::
;> addr = wTitleBgMap + offset
	ld a, [wTitleBgMap]
	add l
	ld l, a
	ld a, [wTitleBgMap + 1]
	adc h
;>@g return (addr & 0x03FF) | (wTitleBgMap & 0xFC00)
	and $03
	ld h, a
	ld a, [wTitleBgMap + 1]
	and $fc
	or h
	ld h, a
;=@g
	ret


;@ def TilemapBufferAddr_18(offset: hl) -> hl
;@ path: gfx/tilemap
;@ Address of a screen offset in wTilemapBuffer.
;@ test: hl = rand(0, 0x23F)
TilemapBufferAddr_18::
;>@g return wTilemapBuffer + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@g
	ret


;@ def TitleBgAddrWrapped_18(offset: hl) -> hl
;@ path: gfx/tilemap
;@ BG map address of a screen offset (row * 32 + column), wrapping the column around within
;@ the BG map row as the screen is scrolled.
;@ test: hl = rand(0, 0x23F)
;@ test: wTitleBgMap = rand(0x9800, 0x9BFF)
TitleBgAddrWrapped_18::
;> addr = TitleBgAddr_18(offset & 0xFFE0)   # start of the row
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call TitleBgAddr_18
;> for i in range(offset & 0x1F):
	ld a, b
	and $1f
	jr z, .done

	ld b, a

.loop
;>     addr = NextBgColumn_18(addr)
	call NextBgColumn_18
	dec b
	jr nz, .loop

.done
;> return addr
	pop bc
	ret


;@ path: unused
;@ Code that nothing calls (a copy of the window drawer that writes straight into the BG map,
;@ as DrawWindowLayout_18 does into the tilemap buffer).
DrawLayoutToVram_18::
	db $1a, $6f, $13, $1a, $67, $13, $cd, $82, $4f, $7d, $e0, $d5, $7c, $e0, $d6, $1a
	db $13, $fe, $d9, $c8, $fe, $d8, $20, $1c, $f0, $d5, $6f, $f0, $d6, $67, $7d, $c6
	db $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67, $7d, $e0, $d5, $7c
	db $e0, $d6, $18, $db, $cd, $ad, $1a, $cd, $56, $4f, $18, $d3

;@ def DrawWindowLayout_18(layout: de)
;@ path: gfx/tilemap
;@ Draws a window layout into wTilemapBuffer. Layout format: a u16 screen offset (row * 32 +
;@ column) where it starts, then tile numbers; $D8 starts the next row below the start, $D9
;@ ends.
;@ test: skip reads a layout from ROM
DrawWindowLayout_18::
;>@start row = p = TilemapBufferAddr_18(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@start
	call TilemapBufferAddr_18
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

;@ def CopyTilemapBufferToVram_18()
;@ path: gfx/tilemap
;@ Copies the 18 rows of 32 tiles of wTilemapBuffer to the BG map at wTitleBgMap (columns and
;@ rows wrap around within the BG map).
;@ test: skip writes VRAM
CopyTilemapBufferToVram_18::
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
;>@next         p = NextBgColumn_18(p)
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


;@ def DrawTextTiles_18(tiles: hl, lines: e, line_length: d)
;@ path: text/tiles
;@ Prints text wTextGroup / wTextIndex of bank $41 at once into the tiles at `tiles` (`lines`
;@ lines of `line_length` tiles), keeping the text box settings.
;@ test: skip prints text
DrawTextTiles_18::
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
;> wTextBoxLines = lines; wTextBoxLineLength = line_length
	ld a, e
	ld [wTextBoxLines], a
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
;> wTextBoxLines = saved_box[0]
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_box[1]
	ld a, d
	ld [wTextBoxLineLength], a
	ret


;@ def DrawNameTiles_18(name: de, tiles: hl)
;@ path: text/tiles
;@ Prints a 4-letter name into the 4 tiles at `tiles` (through wTextArg0 and text 0 of group 2,
;@ which prints it), keeping the text box settings.
;@ test: skip prints text
DrawNameTiles_18::
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


;@ path: unused
;@ Code that nothing calls: prints the single character in a into the tile at hl (as
;@ DrawNameTiles_18, with a one-tile text box).
DrawCharTile_18::
	db $ea, $80, $c1, $3e, $f0, $ea, $81, $c1, $fa, $27, $c8, $4f, $fa, $28, $c8, $47
	db $c5, $fa, $29, $c8, $4f, $fa, $2a, $c8, $47, $c5, $7d, $ea, $27, $c8, $7c, $ea
	db $28, $c8, $11, $01, $01, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $3e, $02, $ea
	db $22, $c8, $3e, $00, $ea, $23, $c8, $21, $02, $41, $d7, $d1, $e1, $7d, $ea, $27
	db $c8, $7c, $ea, $28, $c8, $7b, $ea, $29, $c8, $7a, $ea, $2a, $c8, $c9

;@ path: unused
;@ Code that nothing calls: copies $200 bytes from $C300 to wTilemapBuffer, then two rows of 20
;@ bytes from $C1C0 on over its start (rows 32 bytes apart in the buffer, 20 at the source).
UnusedCopyScreen_18::
	db $21, $00
	db $c5, $11, $00, $c3, $01, $00, $02, $1a, $13, $22, $0b, $78, $b1, $20, $f8, $11
	db $c0, $c1, $0e, $02, $06, $14, $1a, $13, $22, $05, $20, $fa, $7b, $c6, $0c, $5f
	db $7a, $ce, $00, $57, $7d, $c6, $0c, $6f, $7c, $ce, $00, $67, $0d, $20, $e5, $c9

;@ def ClearTilemapBuffer_18()
;@ path: gfx/tilemap
;@ Fills the $240 bytes of wTilemapBuffer with the blank tile $E0.
ClearTilemapBuffer_18::
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


;@ path: unused
;@ Code that nothing calls: fills the BG map at $9800 (32 x 32 tiles) with the blank tile $E0.
ClearBgMap_18::
	db $21, $00, $98, $01, $00, $04, $3e, $e0, $cd, $b9, $1a, $0b, $78, $b1, $20, $f6
	db $c9

;@ def MovePagedListCursor_18(cur: hl, rows: b, count: c, marks: de)
;@ path: menu/cursor
;@ Cursor of a paged list of `count` entries, `rows` per page: cur[0] is the row (bit 7 set once
;@ chosen), cur[1] the page. Left and Right turn the page (wrapping around; on the shorter last
;@ page the row is pulled up), Up and Down move the row within the page (MoveMenuCursor_18),
;@ A chooses. `marks` is the list's cursor table: the page number position, then the rows.
;@ test: skip draws through helpers
MovePagedListCursor_18::
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
	jr nz, jr_018_520c

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
	jr z, jr_018_520c

	dec a
	cp [hl]
	jr nc, jr_018_520c

;>             cur[0] = left - 1
	ld [hl], a
;>     wTitleBlink = 0; cur[0] |= 0x80 if wJoyPressed & 0x01 else 0   # the shared end of MoveMenuCursor_18
;>     return MenuDrawCursorMarks_18(cur[0], marks)
	jr jr_018_520c

.noTurn
;>@lpn DrawListPageNumber_18(cur, rows, count, marks)
	push bc
	push de
	push hl
	call DrawListPageNumber_18
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
	jr nz, MoveMenuCursor_18

;>     rows = wListLastRows + 1         # the rows on the last page
	ld a, [wListLastRows]
	inc a
;> return MoveMenuCursor_18(cur, rows, marks)   # runs on into it
	ld b, a

;@ def MoveMenuCursor_18(cur: hl, rows: b, marks: de)
;@ path: menu/cursor
;@ Moves a menu cursor (cur[0], bit 7 = chosen) with Up and Down through `rows` entries,
;@ wrapping around, sets bit 7 when A is pressed and draws the cursor marks.
;@ test: skip draws through helpers
MoveMenuCursor_18::
;> cur[0] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:                # Up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .notUp

;>     c = cur[0] - 1
;>     if c >= rows: c = rows - 1       # (also when it went below 0)
	ld a, [hl]
	dec a
	cp b
	jr c, .set

	dec b
	ld a, b
;>@set     cur[0] = c; wTitleBlink = 0
	jr .set

.notUp
;> elif wJoyRepeat & 0x80:              # Down
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_018_5214

;>     c = cur[0] + 1
;>     if c >= rows: c = 0
	ld a, [hl]
	inc a
	cp b
	jr c, .set

	ld a, $00

.set
;>@set2     cur[0] = c; wTitleBlink = 0
	ld [hl], a

jr_018_520c:
;=@set2
	xor a
	ld [wTitleBlink], a
	push hl
	push de
	pop de
	pop hl

jr_018_5214:
;> if wJoyPressed & 0x01:             # A
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw

;>     cur[0] |= 0x80
	set 7, [hl]

.draw
;> MenuDrawCursorMarks_18(cur[0], marks)
	ld a, [hl]
	call MenuDrawCursorMarks_18
	ret


;@ path: unused
;@ Code that nothing reaches: a left/right variant of the cursor movement in MoveMenuCursor_18
;@ (Left moves to the previous entry, Right to the next, wrapping to 0), jumping back into it.
MoveMenuCursorSideways_18::
	db $cb, $be, $fa, $47, $c8, $cb, $6f, $28, $09, $7e, $3d, $b8, $38, $db, $05, $78
	db $18, $d7, $fa, $47, $c8, $cb, $67, $28, $d9, $7e, $3c, $b8, $38, $cb, $3e, $00
	db $18, $c7

;@ def MenuResetBlink_18()
;@ path: menu/cursor
;@ Restarts the cursor blink, so the cursor is drawn at once.
MenuResetBlink_18::
;> wTitleBlink = 0
	xor a
	ld [wTitleBlink], a
	ret


;@ def MenuDrawCursorMarks_18(cursor: a, marks: de) -> a
;@ path: menu/cursor
;@ Draws the mark of every entry of a cursor table (u16 screen offsets, $FFFF ends) into the
;@ BG map and wTilemapBuffer: the arrow $E8 at entry `cursor` (blinking: blank while
;@ wTitleBlink bit 4 is set), $E9 when chosen (bit 7), blank $E0 at the others. A cursor not
;@ chosen is only redrawn every 16 frames.
;@ test: skip writes VRAM
MenuDrawCursorMarks_18::
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

;>@bg     bg = TitleBgAddrWrapped_18(pos); marks += 2
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@bg
	call TitleBgAddrWrapped_18
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
;>@buf     mem[TilemapBufferAddr_18(pos)] = tile
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

;@ def DrawListPageNumber_18(cur: hl, rows: b, count: c, marks: de)
;@ path: menu/cursor
;@ When a list has more entries than one page holds, writes the page number (tile $F1 + page,
;@ cur[1]) just left of the page arrow, whose position is the word before `marks`, into the
;@ BG map and wTilemapBuffer.
;@ test: skip writes VRAM
DrawListPageNumber_18::
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
;>@digit WriteVRAM(0xF1 + (page & 0x7F), TitleBgAddrWrapped_18(pos))
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@digit
	call TitleBgAddrWrapped_18
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
;=@digit
	call WriteVRAM
;>@buf mem[TilemapBufferAddr_18(pos)] = 0xF1 + (page & 0x7F)
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


;@ def MenuDrawListCursor_18(cur: hl, marks: de, rows: b, count: c)
;@ path: menu/cursor
;@ Draws a paged list's cursor into wTilemapBuffer: at the table's first position the page
;@ arrow $E7 with the page number left of it when there are several pages (else the frame tile
;@ $EE), then the row cursor (MenuDrawCursorAt_18, run on into).
;@ test: skip draws through helpers
MenuDrawListCursor_18::
;> cursor = cur[0]; page = cur[1]
	ld a, [hli]
	push af
	push hl
;>@p p = TilemapBufferAddr_18(mem16[marks]); marks += 2
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
;> MenuDrawCursorAt_18(cursor, marks)   # runs on into it
	pop af

;@ def MenuDrawCursorAt_18(cursor: a, marks: de)
;@ path: menu/cursor
;@ Writes the cursor mark of entry `cursor` of a cursor table into wTilemapBuffer: $E9 when
;@ chosen (bit 7), else the blinking arrow ($E8, blank $E0 while wTitleBlink bit 4 is set).
;@ test: skip reads a table from ROM
MenuDrawCursorAt_18::
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
;>@bg TitleBgAddrWrapped_18(pos)          # (the result is not used)
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [hNumber + 1], a
	push de
	push bc
;=@bg
	call TitleBgAddrWrapped_18
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
;>@buf mem[TilemapBufferAddr_18(pos)] = tile
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


;@ def LoadPartyPictures_18()
;@ path: link/result
;@ Unpacks the big pictures of the party monsters into the tiles at $9000, $9240 and $9480
;@ (36 tiles each).
;@ test: skip decompresses into VRAM
LoadPartyPictures_18::
;> if wPartyCount == 0:
;>     return
	ld a, [wPartyCount]
	or a
	ret z

;>@p0 LoadMonsterPicture_18(GetPartyMonsterByte(0, wMonRecSpecies), 0x9000)
	ld a, $00
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $9000
	call LoadMonsterPicture_18
;> if wPartyCount == 1:
;>     return
	ld a, [wPartyCount]
	cp $01
	ret z

;>@p1 LoadMonsterPicture_18(GetPartyMonsterByte(1, wMonRecSpecies), 0x9240)
	ld a, $01
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $9240
	call LoadMonsterPicture_18
;> if wPartyCount == 2:
;>     return
	ld a, [wPartyCount]
	cp $02
	ret z

;> LoadMonsterPicture_18(GetPartyMonsterByte(2, wMonRecSpecies), 0x9480)   # runs on into it
	ld a, $02
	ld hl, wMonRecSpecies
	call GetPartyMonsterByte
	ld hl, $9480

;@ def LoadMonsterPicture_18(species: a, dest: hl)
;@ path: link/result
;@ Unpacks the big picture of `species` (graphics number from the table at $2B9F in the home
;@ bank) to VRAM `dest`; nothing for $FF.
;@ test: skip decompresses into VRAM
LoadMonsterPicture_18::
;> if species == 0xFF:
;>     return
	cp $ff
	ret z

;>@g gfx = mem16[0x2B9F + 2 * species]
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
;=@g
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
;=@g
	ld d, [hl]
	pop hl
;> Decompress(hi(gfx), lo(gfx), dest)
	call Decompress
	ret


;@ def DrawPartyPictures_18()
;@ path: link/result
;@ Places the party's monster pictures (6 x 6 tiles each, from tile 0 on) in row 6 of
;@ wTilemapBuffer, centred for 1, 2 or 3 monsters, and gives each its CGB palette (BG palettes
;@ 4-6).
;@ test: skip calls routines in other banks
DrawPartyPictures_18::
;>@c if wPartyCount not in (2, 3):       # one monster
	ld a, [wPartyCount]
	cp $03
	jr z, .three

;=@c
	cp $02
	jr z, .two

;>     DrawPictureTiles_18(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call DrawPictureTiles_18
;>     SetPartyPicturePalette_18(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call SetPartyPicturePalette_18
	ret


;> elif wPartyCount == 2:
;>     tile = DrawPictureTiles_18(0, 0x00C4)
.two
	ld a, $00
	ld hl, $00c4
	call DrawPictureTiles_18
;>     DrawPictureTiles_18(tile, 0x00CA)
	ld hl, $00ca
	call DrawPictureTiles_18
;>     SetPartyPicturePalette_18(0, 0x00C4)
	ld a, $00
	ld hl, $00c4
	call SetPartyPicturePalette_18
;>     SetPartyPicturePalette_18(1, 0x00CA)
	ld a, $01
	ld hl, $00ca
	call SetPartyPicturePalette_18
	ret


;> else:
;>     tile = DrawPictureTiles_18(0, 0x00C1)
.three
	ld a, $00
	ld hl, $00c1
	call DrawPictureTiles_18
;>     tile = DrawPictureTiles_18(tile, 0x00C7)
	ld hl, $00c7
	call DrawPictureTiles_18
;>     DrawPictureTiles_18(tile, 0x00CD)
	ld hl, $00cd
	call DrawPictureTiles_18
;>     SetPartyPicturePalette_18(0, 0x00C1)
	ld a, $00
	ld hl, $00c1
	call SetPartyPicturePalette_18
;>     SetPartyPicturePalette_18(1, 0x00C7)
	ld a, $01
	ld hl, $00c7
	call SetPartyPicturePalette_18
;>     SetPartyPicturePalette_18(2, 0x00CD)
	ld a, $02
	ld hl, $00cd
	call SetPartyPicturePalette_18
	ret


;@ def DrawPictureTiles_18(tile: a, pos: hl) -> a
;@ path: gfx/tilemap
;@ Writes a 6 x 6 block of consecutive tile numbers from `tile` on into wTilemapBuffer at screen
;@ offset `pos`; returns the next tile number.
;@ test: skip writes wTilemapBuffer, where the test stack lives
DrawPictureTiles_18::
;> for row in range(6):
	ld c, $06

.row
;>     p = TilemapBufferAddr_18(pos)
	push hl
	push af
	call TilemapBufferAddr_18
	pop af
;>     for col in range(6):
	ld b, $06

.col
;>         mem[p] = tile; p += 1
	ld [hli], a
;>         tile = (tile + 1) & 0xFF
	inc a
	dec b
	jr nz, .col

;>     pos += 32
	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, .row

;> return tile
	ret


;@ def SetPartyPicturePalette_18(n: a, pos: hl)
;@ path: link/result
;@ Gives the picture of party monster `n` at screen offset `pos` its species' palette: BG
;@ palette 4 + n, and its attributes.
;@ test: skip calls routines in other banks
SetPartyPicturePalette_18::
;> wMonPicPos = pos
	push af
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [wMonPicPos + 1], a
;> wPaletteSet = mem[PartyMonsterField(n, wMonRecSpecies)]
	pop af
	push af
	ld hl, wMonRecSpecies
	call PartyMonsterField
	ld a, [hl]
	ld [wPaletteSet], a
;> wMonPicPalette = n + 4
	pop af
	add $04
	ld [wMonPicPalette], a
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
	ret


;@ def PrintTwoDigits_18(n: bc, dest: hl)
;@ path: text/numbers
;@ Writes `n` (0-99) as one or two digit tiles ($F0 + digit) at `dest` (through WriteVRAM, so
;@ VRAM or RAM); no leading zero.
;@ test: skip writes through WriteVRAM
PrintTwoDigits_18::
;> if n // 10:
	ld de, $000a
	push bc
	call DivideBCByDE_18
	pop bc
	or a
	jr z, .ones

;>     tens, n = DivideBCByDE_18(n, 10)
	ld de, $000a
	call DivideBCByDE_18
;>     WriteDigitTile_18(tens, dest)
	call WriteDigitTile_18
;>     dest = NextBgColumn2_18(dest)
	call NextBgColumn2_18

.ones
;> WriteDigitTile_18(n, dest)
	ld a, c
	call WriteDigitTile_18
	ret


;@ def DivideBCByDE_18(n: bc, d: de) -> (a, bc)
;@ path: system/math
;@ Divides `n` by `d` by repeated subtraction: returns the quotient (8-bit) and the remainder.
;@ test: bc = rand(0, 0x3FF)
;@ test: de = rand(1, 0x30)
DivideBCByDE_18::
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


;@ def WriteDigitTile_18(digit: a, dest: hl)
;@ path: text/numbers
;@ Writes the digit tile $F0 + `digit` at `dest` through WriteVRAM.
;@ test: skip writes through WriteVRAM
WriteDigitTile_18::
;> WriteVRAM(0xF0 + digit, dest)
	add $f0
	call WriteVRAM
	ret


;@ def NextBgColumn2_18(addr: hl) -> hl
;@ path: gfx/tilemap
;@ A copy of NextBgColumn_18: one column right, wrapping around within the 32-tile row.
;@ test: hl = rand(0x9800, 0x9BFF)
NextBgColumn2_18::
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


;@ path: link/result
;@ Window layout (format: see DrawWindowLayout_18) of the yes/no window of the VS result
;@ screen, at screen offset $010E: tiles $D4-$D6 and $A8-$A9 are the two choices.
VSReplaceYesNoWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $d4, $d5, $d6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a8, $a9, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: link/result
;@ Window layout of the monster list: "WHO" (tiles $6C-$6E) as the title, then four name rows
;@ (tiles $00-$0F, filled by VSResultDrawListNames).
VSReplaceListWindow::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $6c, $6d, $6e, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e0, $00, $01, $02, $03, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $04, $05, $06, $07, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $08, $09, $0a, $0b, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $0c, $0d, $0e, $0f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/result
;@ Window layout of the INFO / OK menu next to the monster list (tiles $6F-$72 "INFO", $73-$74
;@ "OK").
VSInfoOkWindow::
	db $0d
	db $00, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $6f, $70, $71, $72, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $73, $74, $e0, $e0, $ff
	db $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/result
;@ Window layout of the INFO / OK menu next to the egg list (one column further left and one
;@ wider).
VSEggInfoOkWindow::
	db $0c, $00, $fa, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $6f, $70, $71, $72, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $73, $74, $e0, $e0, $e0, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/result
;@ Window layout of the MON / EGG choice (tiles $75-$77 "MON", $78-$7A "EGG").
VSKindWindow::
	db $0e, $00, $fa, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $75, $76, $77, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $78, $79, $7a, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/result
;@ Window layout of the egg list: four rows of a 9-tile species name (tiles $00-$23) and a sex
;@ mark (tiles $24-$27).
VSEggListWindow::
	db $00, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $00
	db $01, $02, $03, $04, $05, $06, $07, $08, $24, $ff, $d8, $fe, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $09, $0a, $0b, $0c, $0d
	db $0e, $0f, $10, $11, $25, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $12, $13, $14, $15, $16, $17, $18, $19, $1a
	db $26, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $27, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: link/result
;@ Window layout of the line about the monster under the list cursor, at screen offset $0140:
;@ its name (tiles $10-$13) and sex sign (tile $14); the level is written in by
;@ VSResultDrawCursorMonLevel.
VSCursorMonWindow::
	db $40, $01, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $e0, $e0, $10
	db $11, $12, $13, $14, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $fd, $d9

;@ path: text/dialogue
;@ Text group table of bank $18 (handed to StartText): one group.
TextGroups_18::
	dw TextGroup_18_0

;@ path: text/dialogue
;@ Text group 0 of bank $18: one pointer per text (wTextIndex), 48 texts. They are texts $9E-$CD
;@ of bank $49's group 0 (StartText_49 renumbers them): the late story (DeathMore, the King's
;@ praise for each defeated evil lord, the villagers after the victory). The text format is
;@ described at TextGroup_1A_0.
TextGroup_18_0::
	db $94, $56, $89, $58, $51, $5a, $a8, $5a, $a2, $5b, $31
	db $5c, $dd, $5c, $15, $5d, $c2, $5d, $8a, $5e, $7a, $5f, $a6, $5f, $b8, $60, $4b
	db $61, $90, $61, $3e, $62, $47, $63, $a7, $63, $bf, $64, $e9, $64, $61, $65, $c9
	db $65, $ca, $66, $ea, $66, $09, $67, $2a, $67, $48, $67, $69, $67, $89, $67, $b1
	db $67, $d0, $67, $36, $69, $67, $69, $e2, $69, $19, $6a, $8e, $6a, $02, $6b, $38
	db $6b, $55, $6b, $b0, $6b, $a0, $6c, $32, $6d, $75, $6d, $b6, $6d, $3d, $6e, $f3
	db $6e, $31, $6f, $4e, $6f

;@ def StartText_18()
;@ path: text/dialogue
;@ Starts printing text wTextGroup / wTextIndex of bank $18 (StartText with this bank's table).
;@ test: skip runs the text code with this bank switched in
StartText_18::
;> StartText(TextGroups_18)
	ld de, TextGroups_18
	call StartText
	ret


;@ def CopyText_18()
;@ path: text/dialogue
;@ Copies text wTextGroup / wTextIndex of bank $18 to wTextCopyDest.
;@ test: skip runs the text code with this bank switched in
CopyText_18::
;> CopyTextString(TextGroups_18)
	ld de, TextGroups_18
	call CopyTextString
	ret


;@ def PrintText_18()
;@ path: text/dialogue
;@ Prints text wTextGroup / wTextIndex of bank $18 at once and waits for its end.
;@ test: skip runs the text code with this bank switched in
PrintText_18::
;> StartText_18()
	call StartText_18
;> RunTextToEnd()
	call RunTextToEnd
	ret


;@ path: text/dialogue
;@ The 48 texts of bank $18, one after the other, each ended by $F0 (format: see
;@ TextGroup_1A_0): the late story, from DeathMore's taunts to the King's praise and the
;@ villagers after the Starry Night victory.
Texts_18::
	db $ea, $9f, $a3, $2b, $3e, $62, $45, $3e, $62, $45, $3e, $63, $ef, $ee, $fa, $f7
	db $ef, $ee, $9f, $a3, $2d, $52, $50, $51, $62, $3f, $42, $40, $3e, $52, $50, $42
	db $62, $2c, $ef, $ee, $49, $42, $51, $62, $56, $4c, $52, $62, $4d, $49, $3e, $56
	db $5f, $5f, $5f, $fa, $f7, $ef, $ee, $3c, $4c, $52, $62, $45, $3e, $53, $42, $62
	db $50, $52, $40, $45, $ef, $ee, $40, $4c, $4b, $40, $42, $46, $51, $5f, $5f, $5f
	db $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $54, $3e, $50, $62, $44, $4c, $46, $4b
	db $44, $62, $51, $4c, $ef, $ee, $50, $4a, $3e, $50, $45, $62, $56, $4c, $52, $62
	db $3e, $49, $49, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $37, $45, $42, $4b, $62, $56
	db $4c, $52, $62, $50, $45, $4c, $54, $42, $41, $ef, $ee, $52, $4d, $5f, $5f, $fa
	db $f7, $ef, $ee, $9f, $a3, $36, $52, $40, $45, $62, $3e, $62, $50, $46, $4a, $4d
	db $49, $42, $ef, $ee, $4a, $4c, $4f, $51, $3e, $49, $63, $fa, $f7, $ef, $ee, $9f
	db $a3, $2c, $62, $41, $4c, $4b, $67, $62, $4b, $42, $42, $41, $62, $51, $4c, $ef
	db $ee, $46, $4b, $51, $4f, $4c, $41, $52, $40, $42, $62, $4a, $56, $50, $42, $49
	db $43, $5f, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $3e, $4a, $62, $44, $4c
	db $46, $4b, $44, $62, $51, $4c, $ef, $ee, $3f, $42, $62, $51, $45, $42, $62, $2e
	db $46, $4b, $44, $62, $4c, $43, $62, $51, $45, $42, $fa, $f7, $ef, $ee, $42, $4b
	db $51, $46, $4f, $42, $62, $54, $4c, $4f, $49, $41, $5f, $5f, $5f, $ef, $ee, $fa
	db $f7, $ef, $ee, $9f, $a3, $37, $45, $42, $62, $44, $4f, $42, $3e, $51, $62, $ef
	db $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $63, $fa, $f7, $ef, $ee, $27
	db $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $26, $4c, $4a, $42, $62, $4c, $4b
	db $63, $ef, $ee, $54, $4c, $4f, $51, $45, $49, $42, $50, $50, $62, $4a, $4c, $4f
	db $51, $3e, $49, $50, $63, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c
	db $4f, $42, $a3, $2c, $62, $54, $46, $49, $49, $62, $ef, $ee, $51, $42, $3e, $40
	db $45, $62, $56, $4c, $52, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $27, $42, $3e, $51
	db $45, $30, $4c, $4f, $42, $a3, $5f, $5f, $5f, $45, $4c, $54, $ef, $ee, $45, $42
	db $49, $4d, $49, $42, $50, $50, $62, $3e, $4b, $41, $fa, $f7, $ef, $ee, $46, $4a
	db $4d, $42, $4f, $43, $42, $40, $51, $62, $56, $4c, $52, $ef, $ee, $3e, $4f, $42
	db $63, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $2c
	db $6a, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $5e, $fa, $f7, $ef
	db $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $37, $45, $42, $62, $2e
	db $46, $4b, $44, $ef, $ee, $4c, $43, $62, $3e, $49, $49, $62, $43, $49, $42, $50
	db $45, $63, $63, $f7, $f0, $ea, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3
	db $2b, $3e, $62, $45, $3e, $62, $45, $3e, $ef, $ee, $3c, $4c, $52, $62, $40, $3e
	db $4a, $42, $62, $3f, $3e, $40, $48, $5f, $fa, $f7, $ef, $ee, $27, $42, $3e, $51
	db $45, $30, $4c, $4f, $42, $a3, $2b, $4c, $54, $62, $40, $3e, $4b, $ef, $ee, $56
	db $4c, $52, $62, $3f, $42, $62, $50, $4c, $fa, $f7, $ef, $ee, $43, $4c, $4c, $49
	db $46, $50, $45, $5f, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45
	db $30, $4c, $4f, $42, $a3, $4b, $4c, $51, $62, $ef, $ee, $51, $4c, $62, $4f, $42
	db $3e, $49, $46, $57, $42, $62, $56, $4c, $52, $4f, $fa, $f7, $ef, $ee, $45, $42
	db $49, $4d, $49, $42, $50, $50, $4b, $42, $50, $50, $5e, $ef, $ee, $fa, $f7, $ef
	db $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $3e, $43, $51, $42, $4f
	db $ef, $ee, $50, $52, $40, $45, $62, $3e, $62, $4a, $46, $50, $42, $4f, $3e, $3f
	db $49, $42, $fa, $f7, $ef, $ee, $41, $42, $43, $42, $3e, $51, $63, $ef, $ee, $fa
	db $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $3c, $4c, $52
	db $4f, $ef, $ee, $42, $55, $4d, $42, $4f, $46, $42, $4b, $40, $42, $62, $b6, $fa
	db $f7, $ef, $ee, $51, $4f, $3e, $46, $4b, $46, $4b, $44, $62, $46, $50, $62, $ef
	db $ee, $52, $50, $42, $49, $42, $50, $50, $63, $fa, $f7, $ef, $ee, $27, $42, $3e
	db $51, $45, $30, $4c, $4f, $42, $a3, $3c, $4c, $52, $69, $42, $ef, $ee, $54, $4c
	db $4f, $51, $45, $49, $42, $50, $50, $5f, $fa, $f7, $ef, $ee, $27, $42, $3e, $51
	db $45, $30, $4c, $4f, $42, $a3, $29, $46, $4b, $42, $5f, $ef, $ee, $2c, $62, $54
	db $46, $49, $49, $62, $51, $42, $3e, $40, $45, $62, $56, $4c, $52, $fa, $f7, $ef
	db $ee, $4c, $53, $42, $4f, $62, $3e, $4b, $41, $62, $4c, $53, $42, $4f, $5e, $ef
	db $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $52
	db $4b, $51, $46, $49, $ef, $ee, $56, $4c, $52, $62, $43, $46, $4b, $3e, $49, $49
	db $56, $62, $fa, $f7, $ef, $ee, $52, $4b, $41, $42, $4f, $50, $51, $3e, $4b, $41
	db $5f, $ef, $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42
	db $a3, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $62, $46, $50, $62
	db $51, $45, $42, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $62, $4c, $43, $62, $ef
	db $ee, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $a3, $3e
	db $49, $49, $62, $ef, $ee, $43, $49, $42, $50, $45, $63, $f7, $f0, $ea, $27, $42
	db $3e, $51, $45, $30, $4c, $4f, $42, $a3, $24, $4f, $44, $45, $5f, $5f, $ef, $ee
	db $2c, $5f, $5f, $49, $4c, $50, $51, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $27, $42
	db $3e, $51, $45, $30, $4c, $4f, $42, $a3, $2c, $62, $44, $52, $42, $50, $50, $ef
	db $ee, $2c, $62, $40, $3e, $4b, $4b, $4c, $51, $62, $54, $46, $4b, $62, $46, $4b
	db $fa, $f7, $ef, $ee, $51, $45, $46, $50, $62, $43, $4c, $4f, $4a, $5f, $5f, $5f
	db $ef, $ee, $f7, $f0, $eb, $3a, $3e, $51, $3e, $3f, $4c, $52, $a3, $ef, $ee, $27
	db $42, $3e, $51, $45, $30, $4c, $4f, $42, $62, $46, $50, $62, $51, $45, $42, $fa
	db $f7, $ef, $ee, $4a, $4c, $50, $51, $62, $4d, $4c, $54, $42, $4f, $43, $52, $49
	db $ef, $ee, $4c, $43, $62, $51, $45, $42, $62, $42, $53, $46, $49, $fa, $f7, $ef
	db $ee, $49, $4c, $4f, $41, $50, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $3a, $3e, $51
	db $3e, $3f, $4c, $52, $a3, $24, $40, $51, $52, $3e, $49, $49, $56, $ef, $ee, $45
	db $42, $62, $50, $45, $4c, $52, $49, $41, $62, $3f, $42, $fa, $f7, $ef, $ee, $50
	db $51, $4f, $4c, $4b, $44, $42, $4f, $62, $51, $45, $3e, $4b, $ef, $ee, $51, $45
	db $3e, $51, $5f, $fa, $f7, $ef, $ee, $3a, $3e, $51, $3e, $3f, $4c, $52, $a3, $2c
	db $62, $54, $4c, $4b, $41, $42, $4f, $ef, $ee, $46, $43, $62, $46, $51, $68, $62
	db $3f, $42, $40, $3e, $52, $50, $42, $62, $fa, $f7, $ef, $ee, $45, $42, $62, $51
	db $4c, $4c, $48, $62, $3e, $4b, $62, $4c, $49, $41, $62, $ef, $ee, $44, $52, $56
	db $68, $62, $43, $4c, $4f, $4a, $64, $62, $32, $45, $62, $fa, $f7, $ef, $ee, $54
	db $42, $49, $49, $63, $ef, $ee, $fa, $f7, $ef, $ee, $3a, $3e, $51, $3e, $3f, $4c
	db $52, $a3, $31, $4c, $54, $5e, $ef, $ee, $f6, $62, $2f, $42, $51, $68, $62, $44
	db $4c, $fa, $f7, $ef, $ee, $3f, $3e, $40, $48, $63, $ef, $ee, $f7, $f0, $eb, $3a
	db $3e, $51, $3e, $3f, $4c, $52, $a3, $2a, $4c, $4c, $41, $ef, $ee, $4a, $4c, $4f
	db $4b, $46, $4b, $44, $62, $f6, $63, $fa, $f7, $ef, $ee, $2c, $51, $68, $62, $51
	db $46, $4a, $42, $62, $51, $4c, $62, $50, $42, $51, $ef, $ee, $3e, $62, $43, $4c
	db $4c, $51, $62, $4c, $4b, $62, $3e, $4b, $4c, $51, $45, $42, $4f, $fa, $f7, $ef
	db $ee, $47, $4c, $52, $4f, $4b, $42, $56, $63, $ef, $ee, $fa, $f7, $ef, $ee, $3a
	db $3e, $51, $3e, $3f, $4c, $52, $a3, $2c, $66, $49, $62, $3f, $42, $ef, $ee, $54
	db $3e, $46, $51, $46, $4b, $44, $62, $43, $4c, $4f, $62, $56, $3e, $fa, $f7, $ef
	db $ee, $3e, $51, $62, $51, $45, $42, $62, $50, $51, $3e, $3f, $49, $42, $5f, $ef
	db $ee, $26, $4c, $4a, $42, $62, $50, $4c, $4c, $4b, $63, $f7, $f0, $ea, $9f, $a3
	db $32, $45, $5e, $62, $f6, $63, $ef, $ee, $3a, $42, $49, $40, $4c, $4a, $42, $62
	db $3f, $3e, $40, $48, $63, $63, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $3f, $42
	db $49, $46, $42, $53, $42, $41, $62, $ef, $ee, $56, $4c, $52, $6d, $62, $4f, $42
	db $51, $52, $4f, $4b, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $28, $53, $42, $4f, $56
	db $3f, $4c, $41, $56, $62, $4a, $46, $50, $50, $42, $41, $ef, $ee, $56, $4c, $52
	db $62, $54, $45, $46, $49, $42, $62, $56, $4c, $52, $62, $54, $42, $4f, $42, $fa
	db $f7, $ef, $ee, $3e, $54, $3e, $56, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3
	db $37, $45, $42, $62, $2e, $46, $4b, $44, $62, $4a, $46, $50, $50, $42, $41, $ef
	db $ee, $56, $4c, $52, $62, $53, $42, $4f, $56, $62, $4a, $52, $40, $45, $5f, $fa
	db $f7, $ef, $ee, $9f, $a3, $2a, $4c, $62, $50, $42, $42, $62, $51, $45, $42, $62
	db $2e, $46, $4b, $44, $63, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $32, $45, $5e, $62
	db $2a, $4f, $42, $3e, $51, $37, $4f, $42, $42, $62, $46, $50, $ef, $ee, $50, $45
	db $3e, $48, $46, $4b, $44, $63, $62, $2c, $51, $68, $62, $fa, $f7, $ef, $ee, $54
	db $42, $49, $40, $4c, $4a, $46, $4b, $44, $62, $56, $4c, $52, $63, $ef, $ee, $f7
	db $f0, $ea, $9f, $a3, $32, $45, $5e, $62, $30, $4c, $4b, $50, $51, $42, $4f, $ef
	db $ee, $30, $3e, $50, $51, $42, $4f, $62, $f6, $63, $fa, $f7, $ef, $ee, $3a, $45
	db $42, $4f, $42, $62, $45, $3e, $53, $42, $ef, $ee, $56, $4c, $52, $62, $3f, $42
	db $42, $4b, $64, $fa, $f7, $ef, $ee, $9f, $a3, $37, $45, $42, $62, $2e, $46, $4b
	db $44, $62, $3e, $4b, $41, $ef, $ee, $42, $53, $42, $4f, $56, $3f, $4c, $41, $56
	db $62, $54, $42, $4f, $42, $62, $fa, $f7, $ef, $ee, $49, $4c, $4c, $48, $46, $4b
	db $44, $62, $43, $4c, $4f, $62, $56, $4c, $52, $63, $ef, $ee, $fa, $f7, $ef, $ee
	db $9f, $a3, $2b, $46, $50, $62, $4a, $3e, $47, $42, $50, $51, $56, $62, $46, $50
	db $ef, $ee, $54, $3e, $46, $51, $46, $4b, $44, $62, $43, $4c, $4f, $62, $56, $4c
	db $52, $5f, $fa, $f7, $ef, $ee, $2a, $4c, $62, $4d, $4f, $42, $50, $42, $4b, $51
	db $62, $ef, $ee, $56, $4c, $52, $4f, $50, $42, $49, $43, $63, $f7, $f0, $ea, $2e
	db $46, $4b, $44, $a3, $f6, $63, $ef, $ee, $2c, $51, $68, $62, $56, $4c, $52, $62
	db $f6, $63, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3a, $45, $42, $4f, $42
	db $62, $46, $4b, $62, $51, $45, $42, $ef, $ee, $54, $4c, $4f, $49, $41, $62, $45
	db $3e, $53, $42, $62, $56, $4c, $52, $fa, $f7, $ef, $ee, $3f, $42, $42, $4b, $64
	db $62, $36, $52, $41, $41, $42, $4b, $49, $56, $ef, $ee, $41, $46, $50, $3e, $4d
	db $4d, $42, $3e, $4f, $46, $4b, $44, $62, $49, $46, $48, $42, $fa, $f7, $ef, $ee
	db $51, $45, $3e, $51, $63, $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3
	db $3a, $42, $6c, $42, $62, $3f, $42, $42, $4b, $62, $ef, $ee, $54, $3e, $46, $51
	db $46, $4b, $44, $62, $43, $4c, $4f, $62, $56, $4c, $52, $5f, $fa, $f7, $ef, $ee
	db $2e, $46, $4b, $44, $a3, $32, $45, $63, $62, $37, $45, $42, $50, $42, $ef, $ee
	db $43, $4c, $49, $48, $50, $62, $54, $42, $4f, $42, $62, $54, $3e, $46, $51, $46
	db $4b, $44, $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $56, $4c, $52, $62, $51, $4c
	db $4c, $63, $ef, $ee, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $2c, $62, $45, $3e
	db $53, $42, $62, $ef, $ee, $4d, $4f, $42, $4d, $3e, $4f, $42, $41, $62, $3e, $62
	db $4d, $4f, $46, $57, $42, $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $56, $4c, $52
	db $4f, $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $ef, $ee, $fa, $f7, $ef, $ee
	db $2e, $46, $4b, $44, $a3, $2a, $4c, $62, $51, $4c, $62, $51, $45, $42, $ef, $ee
	db $26, $45, $3e, $4a, $3f, $42, $4f, $62, $4c, $43, $fa, $f7, $ef, $ee, $37, $4f
	db $3e, $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51, $42, $50, $5f, $ef
	db $ee, $37, $45, $42, $4f, $42, $62, $54, $46, $49, $49, $62, $3f, $42, $62, $4b
	db $42, $54, $fa, $f7, $ef, $ee, $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c
	db $62, $2a, $3e, $51, $42, $50, $ef, $ee, $54, $3e, $46, $51, $46, $4b, $44, $62
	db $43, $4c, $4f, $62, $56, $4c, $52, $5f, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44
	db $a3, $3a, $42, $49, $49, $5e, $62, $2c, $62, $3e, $4a, $62, $ef, $ee, $3f, $52
	db $50, $56, $5f, $62, $3c, $4c, $52, $69, $42, $fa, $f7, $ef, $ee, $41, $46, $50
	db $4a, $46, $50, $50, $42, $41, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b
	db $44, $a3, $25, $52, $50, $56, $63, $62, $25, $52, $50, $56, $63, $ef, $ee, $25
	db $52, $50, $56, $63, $f7, $f0, $eb, $9f, $a3, $36, $46, $4f, $62, $f6, $5e, $ef
	db $ee, $37, $45, $3e, $4b, $48, $62, $56, $4c, $52, $62, $43, $4c, $4f, $62, $51
	db $45, $42, $fa, $f7, $ef, $ee, $53, $46, $40, $51, $4c, $4f, $56, $5f, $ef, $ee
	db $f7, $f0, $eb, $9f, $a3, $f6, $5e, $62, $51, $45, $3e, $4b, $48, $50, $ef, $ee
	db $51, $4c, $62, $56, $4c, $52, $5e, $62, $46, $51, $62, $54, $3e, $50, $62, $51
	db $45, $42, $fa, $f7, $ef, $ee, $3f, $42, $50, $51, $62, $36, $51, $3e, $4f, $4f
	db $56, $62, $31, $46, $44, $45, $51, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3
	db $2f, $46, $50, $51, $42, $4b, $5e, $62, $2c, $62, $45, $42, $3e, $4f, $41, $ef
	db $ee, $3e, $4b, $62, $46, $4b, $51, $42, $4f, $42, $50, $51, $46, $4b, $44, $62
	db $fa, $f7, $ef, $ee, $50, $3e, $56, $46, $4b, $44, $5f, $62, $2c, $51, $62, $44
	db $4c, $42, $50, $60, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $30, $4c, $4b, $48
	db $42, $56, $50, $62, $54, $46, $49, $49, $62, $3f, $42, $ef, $ee, $4f, $42, $3f
	db $4c, $4f, $4b, $62, $3e, $50, $62, $fa, $f7, $ef, $ee, $42, $49, $42, $4d, $45
	db $3e, $4b, $51, $50, $5e, $62, $51, $45, $42, $4b, $ef, $ee, $41, $4f, $42, $3e
	db $4a, $62, $3e, $3f, $4c, $52, $51, $62, $49, $46, $4c, $4b, $50, $fa, $f7, $ef
	db $ee, $50, $4c, $4a, $42, $62, $41, $3e, $56, $5f, $ef, $ee, $fa, $f7, $ef, $ee
	db $9f, $a3, $2c, $62, $54, $4c, $4b, $41, $42, $4f, $62, $54, $45, $3e, $51, $62
	db $ef, $ee, $46, $51, $62, $40, $4c, $52, $49, $41, $62, $4a, $42, $3e, $4b, $64
	db $fa, $f7, $ef, $ee, $24, $62, $4a, $4c, $4b, $48, $42, $56, $62, $3f, $42, $40
	db $4c, $4a, $42, $50, $ef, $ee, $3e, $4b, $62, $42, $49, $42, $4d, $45, $3e, $4b
	db $51, $64, $f7, $f0, $ea, $9f, $a3, $2b, $46, $50, $62, $4a, $3e, $47, $42, $50
	db $51, $56, $ef, $ee, $44, $3e, $53, $42, $62, $56, $4c, $52, $62, $3e, $62, $4f
	db $42, $54, $3e, $4f, $41, $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $51, $45, $42
	db $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f
	db $a3, $37, $45, $42, $4f, $42, $62, $3e, $4f, $42, $62, $4b, $42, $54, $ef, $ee
	db $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51, $42, $50
	db $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $56, $4c, $52, $62, $46, $4b, $62, $51
	db $45, $42, $ef, $ee, $26, $45, $3e, $4a, $3f, $42, $4f, $62, $4c, $43, $fa, $f7
	db $ef, $ee, $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51
	db $42, $50, $63, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $30, $3e, $50, $51, $42, $4f
	db $62, $30, $4c, $4b, $50, $51, $42, $4f, $ef, $ee, $f6, $5e, $62, $4d, $49, $42
	db $3e, $50, $42, $fa, $f7, $ef, $ee, $50, $51, $3e, $56, $62, $45, $42, $4f, $42
	db $62, $46, $4b, $62, $51, $45, $46, $50, $ef, $ee, $48, $46, $4b, $44, $41, $4c
	db $4a, $62, $43, $4c, $4f, $42, $53, $42, $4f, $63, $f7, $f0, $eb, $9f, $a3, $37
	db $45, $42, $62, $2e, $46, $4b, $44, $62, $44, $3e, $53, $42, $62, $ef, $ee, $56
	db $4c, $52, $62, $3e, $62, $50, $4d, $42, $40, $46, $3e, $49, $fa, $f7, $ef, $ee
	db $4d, $42, $4f, $4a, $46, $50, $50, $46, $4c, $4b, $5f, $ef, $ee, $fa, $f7, $ef
	db $ee, $9f, $a3, $29, $4f, $4c, $4a, $62, $4b, $4c, $54, $62, $4c, $4b, $5e, $ef
	db $ee, $51, $45, $46, $50, $62, $50, $42, $40, $4f, $42, $51, $62, $4d, $3e, $51
	db $45, $fa, $f7, $ef, $ee, $46, $50, $62, $3e, $49, $49, $62, $56, $4c, $52, $4f
	db $50, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $5f, $5f, $3a, $4c, $52, $49
	db $41, $62, $56, $4c, $52, $62, $49, $46, $48, $42, $ef, $ee, $51, $4c, $62, $45
	db $42, $3e, $4f, $62, $51, $45, $42, $62, $49, $42, $44, $42, $4b, $41, $fa, $f7
	db $ef, $ee, $4c, $43, $62, $51, $45, $42, $62, $36, $51, $3e, $4f, $4f, $56, $62
	db $ef, $ee, $31, $46, $44, $45, $51, $64, $ff, $f0, $eb, $9f, $a3, $37, $45, $42
	db $62, $36, $51, $3e, $4f, $4f, $56, $62, $31, $46, $44, $45, $51, $ef, $ee, $40
	db $4c, $4a, $42, $50, $62, $3e, $43, $51, $42, $4f, $62, $42, $53, $42, $4f, $56
	db $62, $fa, $f7, $ef, $ee, $04, $07, $51, $45, $62, $43, $52, $49, $49, $62, $4a
	db $4c, $4c, $4b, $5f, $62, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $2b, $52, $4b
	db $41, $4f, $42, $41, $50, $62, $4c, $43, $62, $ef, $ee, $51, $45, $4c, $52, $50
	db $3e, $4b, $41, $50, $62, $4c, $43, $62, $50, $51, $3e, $4f, $50, $fa, $f7, $ef
	db $ee, $9f, $a3, $43, $3e, $49, $49, $62, $51, $4c, $62, $43, $46, $49, $49, $62
	db $51, $45, $42, $ef, $ee, $50, $48, $56, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $29
	db $4f, $3e, $44, $4a, $42, $4b, $51, $50, $62, $4c, $43, $62, $ef, $ee, $49, $46
	db $44, $45, $51, $62, $40, $4c, $53, $42, $4f, $62, $51, $45, $42, $fa, $f7, $ef
	db $ee, $54, $4c, $4f, $49, $41, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $37
	db $45, $3e, $51, $68, $62, $51, $45, $42, $62, $ef, $ee, $36, $51, $3e, $4f, $4f
	db $56, $62, $31, $46, $44, $45, $51, $5f, $62, $fa, $f7, $ef, $ee, $9f, $a3, $37
	db $45, $42, $62, $4b, $46, $44, $45, $51, $62, $54, $45, $42, $4b, $ef, $ee, $40
	db $4c, $52, $4b, $51, $49, $42, $50, $50, $62, $49, $46, $53, $42, $50, $62, $fa
	db $f7, $ef, $ee, $50, $45, $4c, $54, $42, $4f, $62, $41, $4c, $54, $4b, $5f, $ef
	db $ee, $f7, $f0, $eb, $9f, $a3, $37, $45, $42, $62, $50, $51, $4c, $4f, $56, $62
	db $4c, $43, $ef, $ee, $30, $4c, $4b, $50, $51, $42, $4f, $62, $30, $3e, $50, $51
	db $42, $4f, $fa, $f7, $ef, $ee, $f6, $62, $54, $46, $49, $49, $62, $3f, $42, $ef
	db $ee, $45, $3e, $4b, $41, $42, $41, $62, $41, $4c, $54, $4b, $62, $43, $4f, $4c
	db $4a, $fa, $f7, $ef, $ee, $44, $42, $4b, $42, $4f, $3e, $51, $46, $4c, $4b, $62
	db $51, $4c, $ef, $ee, $44, $42, $4b, $42, $4f, $3e, $51, $46, $4c, $4b, $5f, $5f
	db $5f, $f7, $f0, $eb, $9f, $a3, $2f, $4c, $4b, $44, $62, $49, $4c, $4b, $44, $62
	db $3e, $44, $4c, $5f, $5f, $ef, $ee, $24, $4b, $62, $3e, $4b, $40, $42, $50, $51
	db $4c, $4f, $62, $4c, $43, $fa, $f7, $ef, $ee, $3a, $3e, $51, $3e, $3f, $4c, $52
	db $62, $49, $4c, $40, $48, $42, $41, $ef, $ee, $4a, $4c, $4b, $50, $51, $42, $4f
	db $50, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $3f, $42, $45, $46, $4b, $41
	db $62, $51, $45, $42, $ef, $ee, $37, $4f, $3e, $53, $42, $49, $42, $4f, $50, $5c
	db $62, $2a, $3e, $51, $42, $50, $fa, $f7, $ef, $ee, $3f, $42, $40, $3e, $52, $50
	db $42, $62, $51, $45, $42, $56, $62, $54, $42, $4f, $42, $ef, $ee, $3e, $62, $3f
	db $3e, $4b, $42, $62, $51, $4c, $62, $45, $52, $4a, $3e, $4b, $50, $5f, $fa, $f7
	db $ef, $ee, $9f, $a3, $32, $52, $4f, $50, $62, $3e, $4b, $40, $42, $50, $51, $4c
	db $4f, $50, $62, $ef, $ee, $41, $42, $4a, $3e, $4b, $41, $42, $41, $62, $54, $42
	db $a4, $fa, $f7, $ef, $ee, $9f, $a3, $a4, $45, $4c, $49, $41, $62, $3e, $62, $ef
	db $ee, $51, $4c, $52, $4f, $4b, $3e, $4a, $42, $4b, $51, $62, $42, $53, $42, $4f
	db $56, $fa, $f7, $ef, $ee, $36, $51, $3e, $4f, $4f, $56, $62, $31, $46, $44, $45
	db $51, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $24, $43, $51, $42, $4f, $62
	db $4a, $3e, $4b, $56, $62, $ef, $ee, $40, $42, $4b, $51, $52, $4f, $46, $42, $50
	db $5e, $62, $fa, $f7, $ef, $ee, $f6, $62, $54, $3e, $50, $62, $ef, $ee, $53, $46
	db $40, $51, $4c, $4f, $46, $4c, $52, $50, $63, $f7, $f0, $ea, $2e, $46, $4b, $44
	db $a3, $32, $45, $5e, $62, $f6, $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e
	db $51, $62, $fa, $f7, $ef, $ee, $27, $4f, $3e, $40, $4c, $2f, $4c, $4f, $41, $63
	db $ef, $ee, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $3c, $4c, $52, $62, $40
	db $4c, $52, $49, $41, $62, $ef, $ee, $3f, $42, $3e, $51, $62, $3e, $4b, $62, $42
	db $53, $46, $49, $62, $49, $4c, $4f, $41, $5f, $fa, $f7, $ef, $ee, $2e, $46, $4b
	db $44, $a3, $2c, $62, $40, $3e, $4b, $4b, $4c, $51, $62, $43, $46, $4b, $41, $ef
	db $ee, $3e, $62, $43, $46, $51, $51, $46, $4b, $44, $62, $4d, $4f, $3e, $46, $50
	db $42, $5f, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3c, $4c, $52, $62, $50
	db $45, $4c, $52, $49, $41, $62, $3f, $42, $ef, $ee, $51, $45, $42, $62, $2e, $46
	db $4b, $44, $62, $46, $4b, $50, $51, $42, $3e, $41, $63, $f7, $f0, $ea, $2e, $46
	db $4b, $44, $a3, $2d, $52, $50, $51, $62, $48, $46, $41, $41, $46, $4b, $44, $63
	db $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $2b, $3e, $62, $45, $3e
	db $62, $45, $3e, $62, $45, $3e, $63, $ef, $ee, $3a, $4c, $4f, $48, $62, $45, $3e
	db $4f, $41, $63, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3c, $4c, $52, $69
	db $42, $ef, $ee, $41, $46, $50, $4a, $46, $50, $50, $42, $41, $5f, $fa, $f7, $ef
	db $ee, $25, $52, $50, $56, $63, $62, $25, $52, $50, $56, $63, $ef, $ee, $25, $52
	db $50, $56, $63, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $ef
	db $ee, $3c, $4c, $52, $62, $45, $3e, $53, $42, $62, $44, $4c, $4c, $41, $fa, $f7
	db $ef, $ee, $46, $4b, $51, $42, $4b, $51, $46, $4c, $4b, $50, $63, $ef, $ee, $fa
	db $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $3a, $4c, $4f, $48, $46, $4b, $44, $62
	db $45, $3e, $4f, $41, $62, $ef, $ee, $51, $4c, $62, $43, $46, $4b, $41, $62, $4a
	db $4c, $4b, $50, $51, $42, $4f, $50, $62, $fa, $f7, $ef, $ee, $42, $53, $42, $4b
	db $62, $3e, $43, $51, $42, $4f, $62, $56, $4c, $52, $4f, $62, $ef, $ee, $53, $46
	db $40, $51, $4c, $4f, $56, $63, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $f6
	db $62, $46, $50, $62, $ef, $ee, $51, $4f, $52, $49, $56, $62, $51, $45, $42, $62
	db $46, $4a, $3e, $44, $42, $62, $4c, $43, $fa, $f7, $ef, $ee, $3e, $62, $4a, $3e
	db $50, $51, $42, $4f, $63, $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3
	db $28, $53, $42, $4f, $56, $3f, $4c, $41, $56, $62, $ef, $ee, $4c, $52, $44, $45
	db $51, $62, $51, $4c, $62, $4d, $4f, $3e, $56, $fa, $f7, $ef, $ee, $51, $45, $3e
	db $51, $62, $51, $45, $42, $56, $62, $4a, $3e, $56, $ef, $ee, $45, $3e, $53, $42
	db $62, $4c, $4b, $42, $62, $fa, $f7, $ef, $ee, $51, $45, $4c, $52, $50, $3e, $4b
	db $41, $51, $45, $62, $4c, $43, $62, $56, $4c, $52, $4f, $ef, $ee, $53, $46, $4f
	db $51, $52, $42, $5f, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6
	db $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $2b, $3e, $4f, $44
	db $4c, $4b, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6
	db $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $36, $46, $41, $4c
	db $45, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63
	db $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $25, $3e, $4f, $3e, $4a
	db $4c, $50, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6
	db $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $3d, $4c, $4a, $3e
	db $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63, $ef
	db $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $33, $46, $57, $57, $3e, $4f
	db $4c, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63
	db $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $62, $28, $50, $51, $42, $4f
	db $48, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b, $44, $a3, $32, $45, $62, $f6, $63
	db $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e, $51, $fa, $f7, $ef, $ee, $30, $46
	db $4f, $52, $41, $4f, $3e, $3e, $50, $63, $ef, $ee, $fa, $f7, $f0, $ea, $2e, $46
	db $4b, $44, $a3, $32, $45, $62, $f6, $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42
	db $3e, $51, $62, $30, $52, $41, $4c, $52, $63, $fa, $f7, $f0, $ea, $2e, $46, $4b
	db $44, $a3, $32, $45, $62, $f6, $63, $ef, $ee, $3c, $4c, $52, $62, $3f, $42, $3e
	db $51, $62, $fa, $f7, $ef, $ee, $27, $42, $3e, $51, $45, $30, $4c, $4f, $42, $63
	db $ef, $ee, $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $37, $45, $3e, $51, $62
	db $4a, $4c, $4b, $50, $51, $42, $4f, $ef, $ee, $46, $50, $62, $51, $45, $42, $62
	db $50, $51, $4f, $4c, $4b, $44, $42, $50, $51, $fa, $f7, $ef, $ee, $4c, $4b, $42
	db $62, $3f, $42, $45, $46, $4b, $41, $62, $51, $45, $42, $ef, $ee, $37, $4f, $3e
	db $53, $42, $49, $42, $4f, $50, $5c, $62, $2a, $3e, $51, $42, $63, $fa, $f7, $ef
	db $ee, $2e, $46, $4b, $44, $a3, $37, $45, $3e, $51, $68, $62, $4a, $56, $ef, $ee
	db $f6, $63, $62, $37, $45, $42, $62, $4a, $4c, $50, $51, $fa, $f7, $ef, $ee, $4d
	db $4c, $54, $42, $4f, $43, $52, $49, $62, $4a, $3e, $50, $51, $42, $4f, $ef, $ee
	db $46, $4b, $62, $51, $45, $42, $62, $52, $4b, $46, $53, $42, $4f, $50, $42, $63
	db $fa, $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $37, $45, $42, $62, $4b, $42, $55
	db $51, $62, $ef, $ee, $36, $51, $3e, $4f, $4f, $56, $62, $31, $46, $44, $45, $51
	db $62, $54, $4c, $4b, $67, $fa, $f7, $ef, $ee, $40, $4c, $4a, $42, $62, $43, $4c
	db $4f, $62, $3e, $62, $49, $4c, $4b, $44, $ef, $ee, $51, $46, $4a, $42, $5f, $fa
	db $f7, $ef, $ee, $2e, $46, $4b, $44, $a3, $25, $52, $51, $62, $2c, $6a, $62, $ef
	db $ee, $40, $4c, $52, $4b, $51, $46, $4b, $44, $62, $4c, $4b, $62, $56, $4c, $52
	db $fa, $f7, $ef, $ee, $43, $4c, $4f, $62, $4b, $42, $55, $51, $62, $51, $46, $4a
	db $42, $62, $3e, $50, $ef, $ee, $54, $42, $49, $49, $63, $fa, $f7, $ef, $ee, $2e
	db $46, $4b, $44, $a3, $24, $4b, $41, $62, $43, $4c, $4f, $62, $51, $45, $42, $ef
	db $ee, $37, $46, $4b, $56, $30, $42, $41, $3e, $49, $50, $62, $51, $4c, $4c, $63
	db $62, $fa, $f7, $ef, $ee, $2b, $3e, $62, $45, $3e, $62, $45, $3e, $63, $ef, $ee
	db $f7, $f0, $ea, $9f, $a3, $3c, $42, $50, $5e, $62, $56, $4c, $52, $69, $42, $ef
	db $ee, $3e, $51, $62, $51, $45, $42, $62, $40, $3e, $50, $51, $49, $42, $62, $4c
	db $43, $fa, $f7, $ef, $ee, $2a, $4f, $42, $3e, $51, $37, $4f, $42, $42, $63, $ef
	db $ee, $f7, $f0, $eb, $9f, $a3, $3a, $45, $56, $62, $41, $46, $41, $ef, $ee, $3a
	db $3e, $51, $3e, $3f, $4c, $52, $68, $fa, $f7, $ef, $ee, $3e, $4b, $40, $42, $50
	db $51, $4c, $4f, $62, $54, $3e, $4b, $51, $ef, $ee, $51, $45, $42, $62, $51, $4c
	db $52, $4f, $4b, $3e, $4a, $42, $4b, $51, $fa, $f7, $ef, $ee, $51, $4c, $62, $3f
	db $42, $62, $45, $42, $49, $41, $5f, $5f, $5f, $ef, $ee, $fa, $f7, $ef, $ee, $9f
	db $a3, $27, $46, $41, $62, $56, $4c, $52, $62, $43, $46, $4b, $41, $62, $4c, $52
	db $51, $ef, $ee, $3e, $43, $51, $42, $4f, $62, $56, $4c, $52, $4f, $62, $fa, $f7
	db $ef, $ee, $53, $46, $40, $51, $4c, $4f, $56, $64, $ef, $ee, $f7, $f0, $eb, $9f
	db $a3, $37, $45, $42, $62, $53, $46, $49, $49, $3e, $44, $42, $62, $4c, $43, $ef
	db $ee, $2a, $4f, $42, $3e, $51, $37, $4f, $42, $42, $62, $46, $50, $fa, $f7, $ef
	db $ee, $43, $46, $49, $49, $42, $41, $62, $54, $46, $51, $45, $62, $47, $4c, $56
	db $63, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $37, $45, $42, $62, $44, $46, $4f, $49
	db $ef, $ee, $41, $4c, $54, $4b, $50, $51, $3e, $46, $4f, $50, $62, $45, $3e, $50
	db $fa, $f7, $ef, $ee, $3f, $42, $42, $4b, $62, $49, $4c, $4c, $48, $46, $4b, $44
	db $62, $43, $4c, $4f, $ef, $ee, $56, $4c, $52, $5f, $fa, $f7, $ef, $ee, $9f, $a3
	db $2c, $62, $45, $3e, $53, $42, $4b, $67, $62, $50, $42, $42, $4b, $ef, $ee, $56
	db $4c, $52, $62, $43, $4c, $4f, $62, $3e, $62, $54, $45, $46, $49, $42, $5f, $fa
	db $f7, $ef, $ee, $3a, $45, $42, $4f, $42, $62, $45, $3e, $53, $42, $62, $56, $4c
	db $52, $ef, $ee, $3f, $42, $42, $4b, $64, $f7, $f0, $ea, $9f, $a3, $28, $53, $42
	db $4b, $62, $46, $43, $62, $51, $45, $42, $4f, $42, $62, $46, $50, $ef, $ee, $4b
	db $4c, $62, $4a, $4c, $4f, $42, $62, $4f, $42, $54, $3e, $4f, $41, $50, $fa, $f7
	db $ef, $ee, $44, $46, $53, $42, $4b, $62, $3f, $56, $62, $30, $42, $41, $3e, $49
	db $ef, $ee, $30, $3e, $4b, $5f, $5f, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $54, $46
	db $49, $49, $62, $56, $4c, $52, $ef, $ee, $40, $4c, $4b, $51, $46, $4b, $52, $42
	db $62, $51, $4c, $fa, $f7, $ef, $ee, $40, $4c, $49, $49, $42, $40, $51, $62, $51
	db $45, $42, $ef, $ee, $4a, $42, $41, $3e, $49, $50, $63, $64, $ff, $f0, $ea, $9f
	db $a3, $2a, $4f, $42, $3e, $51, $5e, $62, $46, $51, $68, $62, $50, $4c, $ef, $ee
	db $44, $4f, $42, $3e, $51, $5f, $62, $25, $52, $51, $62, $2c, $fa, $f7, $ef, $ee
	db $54, $4c, $52, $49, $41, $62, $4b, $4c, $51, $62, $41, $4c, $62, $46, $51, $5f
	db $ef, $ee, $f7, $f0, $ea, $9f, $a3, $3c, $42, $50, $5f, $62, $2c, $51, $68, $62
	db $51, $45, $42, $ef, $ee, $4f, $46, $44, $45, $51, $62, $54, $3e, $56, $5f, $f7
	db $f0, $eb, $9f, $a3, $2c, $62, $43, $42, $42, $49, $62, $51, $45, $42, $62, $3e
	db $46, $4f, $ef, $ee, $46, $50, $62, $50, $4d, $3e, $4f, $48, $49, $46, $4b, $44
	db $5f, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $54, $4c, $4b, $41, $42, $4f, $62
	db $46, $43, $62, $51, $45, $42, $ef, $ee, $50, $51, $3e, $4f, $50, $62, $3e, $4f
	db $42, $62, $50, $51, $46, $49, $49, $fa, $f7, $ef, $ee, $46, $4b, $62, $51, $45
	db $42, $62, $3e, $46, $4f, $5f, $5f, $5f, $ef, $ee, $f7, $f0, $ea, $9f, $a3, $37
	db $45, $42, $62, $53, $46, $40, $51, $4c, $4f, $46, $4c, $52, $50, $ef, $ee, $4a
	db $3e, $50, $51, $42, $4f, $fa, $f7, $ef, $ee, $42, $53, $42, $4b, $51, $52, $3e
	db $49, $49, $56, $62, $3f, $42, $40, $4c, $4a, $42, $50, $ef, $ee, $51, $45, $42
	db $62, $30, $3e, $50, $51, $42, $4f, $62, $30, $4c, $4b, $50, $51, $42, $4f, $fa
	db $f7, $ef, $ee, $37, $3e, $4a, $42, $4f, $5f, $5f, $5f, $ef, $ee, $fa, $f7, $ef
	db $ee, $9f, $a3, $2c, $62, $54, $4c, $4b, $41, $42, $4f, $62, $46, $43, $62, $2c
	db $ef, $ee, $40, $3e, $4b, $62, $3f, $42, $40, $4c, $4a, $42, $62, $4c, $4b, $42
	db $fa, $f7, $ef, $ee, $51, $4c, $4c, $64, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3
	db $2c, $62, $4f, $42, $3e, $41, $62, $3e, $3f, $4c, $52, $51, $62, $46, $51, $62
	db $ef, $ee, $46, $4b, $62, $51, $45, $42, $62, $3f, $4c, $4c, $48, $62, $2c, $62
	db $fa, $f7, $ef, $ee, $3f, $4c, $4f, $4f, $4c, $54, $42, $41, $62, $43, $4f, $4c
	db $4a, $62, $51, $45, $42, $62, $ef, $ee, $49, $46, $3f, $4f, $3e, $4f, $56, $62
	db $3f, $52, $51, $62, $2c, $62, $fa, $f7, $ef, $ee, $41, $46, $41, $4b, $67, $62
	db $52, $4b, $41, $42, $4f, $50, $51, $3e, $4b, $41, $62, $ef, $ee, $46, $51, $62
	db $51, $45, $3e, $51, $62, $54, $42, $49, $49, $5f, $f7, $f0, $eb, $9f, $a3, $24
	db $62, $54, $42, $49, $49, $62, $54, $4c, $4b, $62, $ef, $ee, $53, $46, $40, $51
	db $4c, $4f, $56, $63, $62, $2c, $6a, $62, $50, $4c, $fa, $f7, $ef, $ee, $45, $3e
	db $4d, $4d, $56, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $45, $42
	db $3e, $4f, $41, $62, $54, $46, $50, $45, $42, $50, $ef, $ee, $40, $4c, $4a, $42
	db $62, $51, $4f, $52, $42, $62, $3e, $43, $51, $42, $4f, $fa, $f7, $ef, $ee, $51
	db $45, $42, $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $5f, $5f, $ef, $ee, $fa
	db $f7, $ef, $ee, $9f, $a3, $3f, $52, $51, $62, $2c, $62, $3e, $4a, $62, $45, $3e
	db $4d, $4d, $56, $62, $ef, $ee, $51, $45, $3e, $51, $62, $56, $4c, $52, $62, $54
	db $4c, $4b, $5e, $62, $fa, $f7, $ef, $ee, $f6, $5f, $ef, $ee, $f7, $f0, $ea, $9f
	db $a3, $28, $4b, $51, $42, $4f, $62, $45, $42, $4f, $42, $62, $51, $4c, $ef, $ee
	db $51, $45, $42, $62, $39, $3e, $52, $49, $51, $5f, $fa, $f7, $ef, $ee, $26, $4c
	db $4b, $44, $4f, $3e, $51, $52, $49, $3e, $51, $46, $4c, $4b, $50, $ef, $ee, $4c
	db $4b, $62, $56, $4c, $52, $4f, $62, $53, $46, $40, $51, $4c, $4f, $56, $5f, $f7
	db $f0, $eb, $9f, $a3, $2a, $4c, $62, $4f, $46, $44, $45, $51, $62, $51, $4c, $62
	db $51, $45, $42, $ef, $ee, $25, $3e, $57, $3e, $3e, $4f, $63, $62, $fa, $f7, $ef
	db $ee, $2b, $42, $56, $62, $56, $4c, $52, $62, $54, $42, $4f, $42, $62, $50, $4c
	db $62, $ef, $ee, $40, $4c, $4c, $49, $62, $3f, $4f, $4c, $51, $45, $42, $4f, $63
	db $f7, $f0, $ea, $9f, $a3, $26, $4c, $4b, $44, $4f, $3e, $51, $52, $49, $3e, $51
	db $46, $4c, $4b, $50, $63, $ef, $ee, $27, $4c, $54, $4b, $62, $51, $45, $42, $62
	db $50, $51, $3e, $46, $4f, $50, $62, $51, $4c, $fa, $f7, $ef, $ee, $51, $45, $42
	db $62, $36, $45, $4f, $46, $4b, $42, $62, $4c, $43, $ef, $ee, $36, $51, $3e, $4f
	db $4f, $56, $62, $31, $46, $44, $45, $51, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $37
	db $45, $42, $4f, $42, $62, $46, $50, $62, $3e, $62, $4b, $42, $54, $ef, $ee, $4f
	db $4c, $4c, $4a, $62, $51, $4c, $62, $51, $45, $42, $62, $4f, $46, $44, $45, $51
	db $fa, $f7, $ef, $ee, $41, $52, $42, $62, $51, $4c, $62, $51, $45, $42, $62, $4e
	db $52, $3e, $48, $42, $5f, $ef, $ee, $f7, $f0, $eb, $9f, $a3, $3c, $4c, $52, $62
	db $43, $4c, $4c, $49, $63, $62, $3a, $45, $42, $4f, $42, $ef, $ee, $45, $3e, $53
	db $42, $62, $56, $4c, $52, $62, $3f, $42, $42, $4b, $62, $43, $4c, $4f, $fa, $f7
	db $ef, $ee, $50, $52, $40, $45, $62, $3e, $62, $49, $4c, $4b, $44, $62, $51, $46
	db $4a, $42, $63, $ef, $ee, $fa, $f7, $ef, $ee, $9f, $a3, $27, $3e, $4f, $4b, $62
	db $53, $46, $40, $51, $4c, $4f, $56, $63, $ef, $ee, $3a, $45, $3e, $51, $62, $3e
	db $4f, $42, $62, $56, $4c, $52, $62, $50, $4c, $fa, $f7, $ef, $ee, $4d, $52, $43
	db $43, $42, $41, $62, $52, $4d, $62, $3e, $3f, $4c, $52, $51, $63, $ef, $ee, $fa
	db $f7, $ef, $ee, $9f, $a3, $3c, $4c, $52, $62, $40, $45, $42, $3e, $51, $42, $41
	db $63, $ef, $ee, $2c, $51, $62, $54, $3e, $50, $62, $52, $4b, $43, $3e, $46, $4f
	db $63, $63, $fa, $f7, $ef, $ee, $9f, $a3, $2c, $62, $54, $3e, $50, $5f, $5f, $5f
	db $ef, $ee, $5f, $5f, $5f, $54, $4c, $4f, $4f, $46, $42, $41, $5f, $f7, $f0, $eb
	db $9f, $a3, $2c, $62, $54, $3e, $50, $5f, $5f, $5f, $ef, $ee, $5f, $5f, $5f, $54
	db $4c, $4f, $4f, $46, $42, $41, $5f, $fa, $f7, $ef, $ee, $9f, $a3, $5f, $5f, $5f
	db $2b, $42, $56, $62, $56, $4c, $52, $63, $ef, $ee, $3c, $4c, $52, $62, $48, $4b
	db $4c, $54, $62, $4a, $56, $62, $4b, $3e, $4a, $42, $64, $f7, $f0, $eb, $9f, $a3
	db $2b, $52, $43, $43, $5e, $62, $ef, $ee, $2c, $62, $41, $4c, $4b, $67, $62, $4b
	db $42, $42, $41, $62, $56, $4c, $52, $63, $f7, $f0, $eb, $9f, $a3, $37, $45, $42
	db $4b, $62, $50, $3e, $56, $62, $46, $51, $63, $ef, $ee, $ff, $f0

;@ path: unused
;@ $F8E bytes after the last text that nothing points to, then zero padding to the end of the
;@ bank. They look like music sequence data (note bytes $80-$9F, event bytes $B1-$BF, $C1,
;@ $D0-$D6), probably left over from an earlier build.
UnusedSongData_18::
	db $31, $82, $33
	db $35, $82, $30, $82, $32, $82, $34, $b1, $01, $00, $13, $6f, $bd, $00, $bc, $4a
	db $be, $0a, $bf, $78, $d1, $44, $1f, $82, $46, $82, $45, $82, $46, $82, $45, $82
	db $46, $82, $45, $82, $46, $82, $45, $82, $46, $82, $45, $82, $46, $82, $45, $82
	db $46, $82, $45, $82, $46, $82, $45, $82, $44, $82, $43, $82, $42, $82, $43, $82
	db $44, $82, $45, $82, $46, $82, $47, $82, $b1, $bd, $00, $bc, $4a, $be, $65, $bf
	db $78, $d1, $3e, $1f, $82, $40, $82, $41, $82, $42, $82, $41, $82, $42, $82, $41
	db $82, $42, $82, $41, $82, $42, $82, $41, $82, $42, $82, $41, $82, $42, $82, $41
	db $82, $42, $82, $41, $82, $40, $82, $3f, $82, $3e, $82, $3f, $82, $40, $82, $41
	db $82, $42, $82, $43, $82, $b1, $02, $00, $70, $6f, $ad, $6f, $bd, $00, $bc, $4a
	db $be, $34, $bf, $78, $d1, $31, $1f, $86, $37, $82, $b1, $01, $00, $f0, $6f, $bd
	db $00, $bc, $4a, $be, $45, $bf, $78, $d5, $4e, $1f, $86, $d1, $4e, $09, $82, $d1
	db $4e, $0c, $82, $d1, $4e, $04, $82, $b1, $01, $00, $03, $70, $bd, $00, $bc, $4a
	db $be, $10, $bf, $55, $c2, $0e, $c1, $40, $d6, $30, $1b, $81, $c1, $42, $81, $45
	db $81, $4a, $81, $64, $81, $78, $81, $7f, $81, $c1, $40, $d6, $30, $13, $81, $c1
	db $42, $81, $45, $81, $4a, $81, $64, $81, $78, $81, $7f, $81, $b1, $01, $00, $20
	db $70, $bd, $00, $bc, $4a, $be, $64, $bf, $5e, $d1, $4e, $16, $86, $5f, $82, $b1
	db $01, $00, $55, $70, $bd, $00, $bc, $4a, $be, $10, $c5, $50, $bf, $4b, $d3, $54
	db $13, $84, $58, $84, $57, $84, $56, $84, $5f, $84, $5e, $84, $5d, $84, $59, $84
	db $b1, $01, $00, $68, $70, $bd, $00, $bc, $4a, $be, $3b, $bf, $4b, $d1, $30, $18
	db $82, $3a, $82, $39, $82, $35, $82, $b1, $01, $00, $89, $70, $bd, $00, $bc, $4a
	db $be, $65, $bf, $5e, $d2, $3c, $18, $83, $3d, $83, $3e, $83, $3f, $83, $d2, $3d
	db $16, $83, $3e, $83, $3f, $83, $40, $83, $d2, $3e, $13, $83, $3f, $83, $40, $83
	db $41, $83, $d2, $3f, $11, $83, $40, $83, $41, $83, $42, $83, $d2, $40, $0e, $83
	db $41, $83, $42, $83, $43, $83, $d2, $41, $0c, $83, $42, $83, $43, $83, $44, $83
	db $d2, $42, $09, $83, $43, $83, $44, $83, $45, $83, $d2, $43, $07, $83, $44, $83
	db $45, $83, $46, $83, $b1, $01, $00, $a0, $70, $bd, $00, $bc, $4a, $be, $65, $bf
	db $71, $d5, $37, $0b, $86, $d5, $37, $0c, $86, $d5, $37, $0d, $86, $d5, $37, $0e
	db $86, $d5, $37, $0f, $86, $d5, $37, $10, $86, $d5, $37, $11, $86, $d5, $37, $12
	db $86, $d5, $37, $13, $86, $d5, $37, $14, $86, $d5, $37, $15, $86, $d5, $37, $16
	db $86, $d5, $37, $14, $86, $d5, $37, $12, $86, $d5, $37, $10, $86, $d5, $37, $0e
	db $86, $d5, $37, $0c, $86, $d5, $37, $0b, $86, $b1, $01, $00, $fd, $70, $bd, $00
	db $bc, $4a, $be, $6c, $bf, $67, $d3, $35, $18, $86, $04, $84, $b1, $01, $00, $52
	db $71, $bd, $00, $bc, $4a, $be, $10, $bf, $71, $d0, $34, $1d, $83, $d0, $35, $1b
	db $83, $b1, $01, $00, $65, $71, $bd, $00, $bc, $4a, $be, $40, $bf, $78, $c1, $40
	db $db, $34, $18, $81, $c1, $44, $81, $c5, $2b, $c1, $44, $81, $c5, $27, $c1, $3c
	db $81, $c5, $20, $c1, $2c, $81, $27, $81, $c5, $18, $c1, $1b, $81, $c5, $0b, $c1
	db $16, $81, $c5, $07, $c1, $15, $81, $c5, $06, $c1, $14, $81, $13, $81, $c5, $04
	db $81, $07, $c1, $40, $db, $13, $81, $c1, $44, $81, $c5, $15, $c1, $44, $81, $c5
	db $21, $c1, $3c, $81, $c5, $29, $c1, $2c, $81, $c5, $31, $c1, $27, $81, $c5, $33
	db $c1, $1b, $81, $c5, $36, $c1, $16, $81, $c5, $35, $c1, $15, $81, $14, $81, $c5
	db $2b, $c1, $13, $81, $c5, $25, $81, $c1, $40, $db, $0c, $81, $c5, $19, $c1, $44
	db $81, $c5, $16, $c1, $44, $81, $3c, $81, $2c, $81, $c5, $1a, $c1, $27, $81, $c5
	db $22, $c1, $1b, $81, $c5, $2e, $c1, $16, $81, $15, $81, $c5, $4d, $c1, $14, $81
	db $c5, $51, $c1, $13, $82, $40, $db, $07, $81, $c5, $4d, $c1, $44, $81, $c5, $44
	db $c1, $44, $81, $3c, $81, $c5, $37, $c1, $2c, $81, $c5, $1c, $c1, $27, $81, $1b
	db $81, $c5, $12, $c1, $16, $81, $c5, $0c, $c1, $15, $81, $14, $81, $c5, $0f, $c1
	db $13, $82, $c5, $25, $81, $34, $81, $43, $81, $49, $81, $4b, $81, $49, $81, $44
	db $81, $3d, $81, $35, $81, $2c, $81, $25, $81, $20, $81, $1f, $83, $22, $81, $2e
	db $81, $3c, $81, $4b, $81, $53, $81, $58, $81, $5a, $82, $59, $81, $53, $81, $4c
	db $81, $44, $81, $3d, $82, $35, $81, $2f, $81, $2a, $81, $26, $81, $24, $81, $21
	db $81, $20, $81, $1f, $b1, $01, $00, $7a, $71, $bd, $00, $bc, $4a, $be, $6a, $bf
	db $78, $d3, $32, $1f, $86, $09, $84, $b1, $01, $00, $8d, $72, $bd, $00, $bc, $4a
	db $be, $0d, $c3, $7f, $c4, $00, $c5, $32, $c6, $00, $bf, $67, $d4, $4c, $1b, $8c
	db $e7, $98, $c5, $00, $be, $64, $bf, $78, $c2, $0a, $e7, $62, $1f, $81, $c1, $42
	db $81, $41, $81, $3e, $81, $3c, $81, $3a, $81, $35, $81, $33, $82, $30, $82, $2e
	db $82, $2f, $82, $32, $82, $36, $82, $38, $82, $3d, $82, $40, $81, $d4, $13, $85
	db $b1, $bd, $00, $be, $5d, $c3, $7f, $c4, $00, $c5, $32, $c6, $00, $bf, $67, $d4
	db $4a, $1b, $8c, $e7, $98, $c5, $00, $be, $68, $bf, $55, $db, $3b, $10, $8c, $be
	db $65, $d3, $3b, $12, $84, $d7, $3b, $14, $88, $d7, $3b, $16, $88, $df, $3b, $18
	db $90, $eb, $3b, $1b, $9c, $d7, $3b, $16, $88, $be, $66, $e7, $3b, $12, $98, $b1
	db $02, $00, $a0, $72, $e5, $72, $bd, $00, $bc, $4a, $be, $0a, $bf, $5e, $c5, $64
	db $d3, $48, $18, $81, $4a, $81, $4c, $81, $4e, $81, $50, $81, $52, $81, $4a, $81
	db $4c, $81, $4e, $81, $50, $81, $52, $81, $54, $81, $4c, $81, $4e, $81, $50, $81
	db $52, $81, $54, $81, $56, $81, $4e, $81, $50, $81, $52, $81, $54, $81, $56, $81
	db $58, $84, $b1, $01, $00, $2a, $73, $bd, $00, $bc, $4a, $be, $37, $bf, $67, $ed
	db $30, $18, $9e, $40, $b1, $01, $00, $6b, $73, $bd, $00, $bc, $4a, $be, $0a, $c5
	db $14, $bf, $71, $d1, $39, $1d, $82, $36, $82, $38, $82, $35, $82, $37, $82, $34
	db $82, $36, $82, $33, $82, $35, $82, $32, $82, $34, $82, $31, $82, $33, $82, $30
	db $82, $32, $82, $2f, $82, $31, $82, $2e, $82, $30, $82, $2d, $82, $2f, $82, $2c
	db $82, $2e, $82, $2b, $82, $b1, $bd, $00, $bc, $4a, $be, $6d, $bf, $78, $d2, $47
	db $1f, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83
	db $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83
	db $46, $83, $45, $83, $b1, $02, $00, $7d, $73, $ba, $73, $bd, $00, $bc, $4a, $be
	db $3c, $c5, $14, $bf, $71, $d1, $3a, $1d, $82, $37, $82, $39, $82, $36, $82, $38
	db $82, $35, $82, $3a, $16, $82, $37, $82, $39, $82, $36, $82, $38, $82, $35, $82
	db $b1, $01, $00, $ef, $73, $bd, $00, $bc, $4a, $be, $0a, $c5, $14, $bf, $71, $d1
	db $3a, $1d, $82, $37, $82, $39, $82, $36, $82, $38, $82, $35, $82, $3a, $16, $82
	db $37, $82, $39, $82, $36, $82, $38, $82, $35, $82, $b1, $bd, $00, $bc, $4a, $be
	db $6d, $bf, $78, $d2, $47, $1f, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45
	db $83, $47, $83, $46, $83, $45, $83, $b1, $02, $00, $19, $74, $3f, $74, $bd, $00
	db $bc, $4a, $be, $63, $c5, $14, $bf, $78, $d1, $41, $1f, $82, $3e, $82, $40, $82
	db $3d, $82, $3f, $82, $3c, $82, $3e, $82, $3b, $82, $3d, $82, $3a, $82, $3c, $82
	db $39, $82, $3b, $82, $38, $82, $3a, $82, $37, $82, $39, $82, $36, $82, $38, $82
	db $35, $82, $37, $82, $34, $82, $36, $82, $33, $82, $35, $82, $32, $82, $34, $82
	db $31, $82, $33, $82, $30, $82, $32, $82, $2f, $82, $31, $82, $2e, $82, $30, $82
	db $2d, $82, $2f, $82, $2c, $82, $2e, $82, $2b, $82, $b1, $bd, $00, $bc, $4a, $be
	db $6d, $bf, $78, $d2, $47, $1f, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45
	db $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46
	db $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47
	db $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $b1, $02, $00, $62, $74
	db $bf, $74, $bd, $00, $bc, $4a, $be, $65, $bf, $71, $c5, $00, $d5, $39, $1f, $8c
	db $d1, $12, $82, $b1, $01, $00, $06, $75, $bd, $00, $bc, $4a, $be, $0a, $c5, $14
	db $bf, $4b, $d1, $3a, $13, $82, $37, $82, $3b, $82, $38, $82, $3c, $82, $39, $82
	db $3d, $82, $3a, $82, $3e, $82, $3b, $82, $3f, $82, $3c, $82, $40, $82, $3d, $82
	db $41, $82, $3e, $82, $42, $82, $3f, $82, $43, $82, $40, $82, $44, $82, $41, $82
	db $45, $82, $42, $82, $b1, $bd, $00, $bc, $4a, $be, $6d, $bf, $78, $d2, $47, $1f
	db $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45
	db $83, $47, $83, $46, $83, $45, $83, $47, $83, $46, $83, $45, $83, $47, $83, $46
	db $83, $45, $83, $b1, $02, $00, $1c, $75, $59, $75, $bd, $00, $bc, $4a, $be, $3c
	db $c5, $14, $bf, $5e, $d1, $4a, $18, $84, $49, $84, $48, $84, $d1, $4a, $11, $84
	db $49, $84, $48, $84, $b1, $01, $00, $8e, $75, $bd, $00, $bc, $4a, $be, $32, $bf
	db $71, $d3, $35, $1d, $85, $d3, $85, $d3, $39, $85, $b1, $01, $00, $ad, $75, $bd
	db $00, $bc, $4a, $be, $63, $bf, $71, $d1, $24, $1d, $82, $26, $82, $28, $82, $29
	db $82, $2b, $82, $2d, $82, $2f, $82, $30, $82, $32, $82, $34, $82, $35, $82, $37
	db $82, $39, $82, $3b, $82, $3c, $82, $3b, $82, $3a, $82, $39, $82, $3a, $82, $3b
	db $82, $3a, $82, $39, $82, $38, $82, $37, $82, $38, $82, $39, $82, $38, $82, $37
	db $82, $36, $82, $35, $82, $36, $82, $37, $82, $36, $82, $35, $82, $34, $82, $33
	db $82, $34, $82, $35, $82, $b1, $01, $00, $c3, $75, $bd, $00, $bc, $4a, $be, $3f
	db $bf, $71, $d5, $37, $1d, $86, $be, $36, $d3, $35, $1d, $86, $b1, $01, $00, $1e
	db $76, $bd, $00, $bc, $4a, $be, $63, $c5, $64, $bf, $71, $d1, $48, $1d, $82, $42
	db $82, $3d, $82, $47, $82, $41, $82, $3c, $82, $46, $82, $40, $82, $3b, $82, $45
	db $82, $3f, $82, $3a, $82, $44, $82, $3e, $82, $39, $82, $43, $82, $3d, $82, $38
	db $82, $42, $82, $3c, $82, $37, $82, $41, $82, $3b, $82, $36, $82, $40, $82, $3a
	db $82, $35, $82, $3f, $82, $39, $82, $34, $82, $3e, $82, $38, $82, $33, $82, $3d
	db $82, $37, $82, $32, $82, $3c, $82, $31, $82, $36, $82, $b1, $01, $00, $35, $76
	db $bd, $00, $bc, $4a, $be, $63, $bf, $71, $d2, $30, $1d, $83, $31, $83, $32, $83
	db $33, $83, $34, $83, $35, $83, $36, $83, $37, $83, $38, $83, $39, $83, $d2, $30
	db $11, $83, $31, $83, $32, $83, $33, $83, $34, $83, $35, $83, $36, $83, $37, $83
	db $38, $83, $39, $83, $b1, $01, $00, $94, $76, $bd, $00, $bc, $4a, $be, $33, $bf
	db $78, $d3, $30, $1f, $88, $b1, $01, $00, $cd, $76, $bd, $00, $bc, $4a, $be, $55
	db $bf, $78, $d0, $5b, $1f, $83, $63, $83, $5a, $83, $56, $83, $65, $83, $55, $83
	db $4f, $aa, $b1, $bd, $00, $be, $10, $bf, $2f, $92, $d2, $5b, $0c, $83, $63, $83
	db $5a, $83, $56, $83, $65, $83, $55, $83, $4f, $a4, $b1, $bd, $00, $be, $25, $bf
	db $55, $86, $d2, $5b, $16, $83, $63, $83, $5a, $83, $56, $83, $65, $83, $55, $83
	db $4f, $a8, $b1, $03, $00, $de, $76, $f7, $76, $0f, $77, $bd, $00, $bc, $4a, $be
	db $10, $bf, $5e, $d0, $30, $18, $83, $3e, $83, $46, $82, $b1, $01, $00, $2f, $77
	db $bd, $00, $bc, $4a, $be, $63, $c5, $50, $bf, $71, $c1, $40, $df, $4b, $18, $8a
	db $c1, $37, $82, $31, $82, $28, $82, $24, $82, $22, $82, $21, $82, $d6, $4b, $0c
	db $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6
	db $48, $18, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81
	db $40, $d6, $48, $0c, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81
	db $21, $81, $40, $d6, $41, $18, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81
	db $22, $81, $21, $81, $40, $d6, $41, $0c, $81, $c1, $37, $81, $31, $81, $28, $81
	db $24, $81, $22, $81, $21, $81, $40, $d6, $3e, $18, $81, $c1, $37, $81, $31, $81
	db $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6, $3e, $0c, $81, $c1, $37, $81
	db $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6, $3d, $18, $81, $c1
	db $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6, $3d, $0c
	db $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81, $40, $d6
	db $3c, $18, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81, $21, $81
	db $40, $d6, $3c, $0c, $81, $c1, $37, $81, $31, $81, $28, $81, $24, $81, $22, $81
	db $21, $81, $40, $b4, $b1, $bd, $01, $bc, $4a, $be, $0a, $c5, $50, $bf, $71, $c1
	db $40, $86, $b3, $50, $77, $b1, $02, $00, $44, $77, $29, $78, $bd, $00, $bc, $4a
	db $be, $6a, $bf, $71, $d0, $40, $1d, $81, $40, $19, $81, $40, $17, $81, $3e, $1d
	db $81, $3e, $19, $81, $3e, $17, $81, $3c, $1d, $81, $3c, $19, $81, $3c, $17, $81
	db $3b, $1d, $81, $3b, $19, $81, $3b, $17, $81, $39, $1d, $81, $39, $18, $81, $39
	db $17, $81, $37, $1d, $81, $37, $19, $81, $37, $17, $81, $35, $1d, $81, $35, $19
	db $81, $35, $17, $81, $34, $1d, $81, $34, $19, $81, $34, $17, $81, $32, $1d, $81
	db $32, $19, $81, $32, $17, $81, $30, $1d, $81, $30, $19, $81, $30, $17, $81, $32
	db $1d, $81, $32, $19, $81, $32, $17, $81, $34, $1d, $81, $34, $19, $81, $34, $17
	db $81, $35, $1d, $81, $35, $19, $81, $35, $17, $81, $37, $1d, $81, $37, $19, $81
	db $37, $17, $81, $39, $1d, $81, $39, $19, $81, $39, $17, $81, $3b, $1d, $81, $3b
	db $19, $81, $3b, $17, $81, $3c, $1d, $81, $3c, $19, $81, $3c, $17, $81, $3e, $1d
	db $81, $3e, $19, $81, $3e, $17, $81, $40, $1d, $81, $40, $19, $81, $40, $17, $81
	db $b1, $01, $00, $40, $78, $bd, $00, $bc, $4a, $be, $63, $c5, $64, $bf, $71, $d1
	db $60, $1d, $82, $54, $82, $48, $82, $3c, $82, $5f, $82, $53, $82, $47, $82, $3b
	db $82, $5e, $82, $52, $82, $46, $82, $3a, $82, $5d, $82, $51, $82, $45, $82, $39
	db $82, $5c, $82, $50, $82, $44, $82, $38, $82, $5b, $18, $82, $4f, $82, $43, $82
	db $37, $82, $5b, $11, $82, $4f, $82, $43, $82, $37, $82, $5b, $0c, $82, $4f, $82
	db $43, $82, $37, $82, $b1, $01, $00, $f9, $78, $bd, $00, $bc, $4a, $be, $33, $bf
	db $78, $d6, $2b, $13, $88, $d6, $2d, $16, $88, $d6, $2f, $18, $88, $d6, $30, $1b
	db $88, $d6, $32, $1f, $88, $b1, $01, $00, $4d, $79, $bd, $00, $bc, $4a, $be, $36
	db $bf, $78, $d6, $30, $1f, $88, $d6, $2f, $1b, $88, $d6, $2e, $18, $88, $d6, $2d
	db $16, $88, $d6, $2b, $13, $88, $b1, $01, $00, $6e, $79, $bd, $00, $bc, $4a, $be
	db $6a, $bf, $78, $d5, $3a, $1f, $8c, $d1, $12, $82, $d1, $0c, $82, $b1, $01, $00
	db $8f, $79, $bd, $00, $bc, $4a, $be, $3a, $bf, $4b, $e3, $60, $13, $94, $b1, $01
	db $00, $a6, $79, $bd, $00, $bc, $4a, $be, $65, $bf, $5e, $d0, $4a, $18, $82, $d0
	db $47, $0c, $82, $b1, $01, $00, $b7, $79, $bd, $00, $bc, $4a, $be, $6a, $bf, $78
	db $d6, $38, $1f, $88, $d4, $38, $0e, $86, $d3, $37, $07, $85, $b1, $01, $00, $cc
	db $79, $bd, $00, $bc, $4a, $be, $65, $c5, $00, $bf, $5e, $d0, $4f, $1d, $81, $4e
	db $81, $4d, $81, $4c, $81, $4b, $81, $4a, $81, $49, $81, $48, $81, $47, $81, $46
	db $81, $45, $81, $44, $81, $43, $81, $42, $07, $81, $41, $81, $40, $81, $3f, $05
	db $81, $3e, $81, $3d, $03, $81, $3c, $81, $3b, $01, $81, $3a, $81, $39, $81, $38
	db $00, $81, $37, $81, $b1, $01, $00, $e5, $79, $bd, $00, $bc, $4a, $be, $10, $bf
	db $4b, $c2, $0e, $c1, $40, $d6, $48, $13, $81, $c1, $42, $81, $45, $81, $4a, $81
	db $64, $81, $78, $81, $7f, $81, $b1, $01, $00, $2d, $7a, $bd, $00, $bc, $4a, $be
	db $6a, $c5, $00, $bf, $5e, $d0, $43, $18, $81, $0c, $81, $46, $18, $81, $0c, $81
	db $45, $18, $81, $0c, $81, $b1, $01, $00, $4f, $7a, $bd, $00, $bc, $4a, $be, $10
	db $bf, $71, $d0, $48, $18, $84, $55, $84, $3e, $84, $63, $84, $4c, $84, $59, $84
	db $42, $84, $5b, $84, $68, $84, $51, $84, $52, $84, $47, $84, $60, $84, $b1, $01
	db $00, $6e, $7a, $bd, $00, $bc, $4a, $be, $5d, $bf, $67, $d0, $54, $18, $81, $0c
	db $82, $18, $81, $0c, $82, $b1, $01, $00, $97, $7a, $bd, $00, $bc, $4a, $be, $65
	db $bf, $78, $d7, $38, $1f, $8a, $d7, $38, $04, $8a, $b1, $01, $00, $ae, $7a, $bd
	db $00, $bc, $4a, $be, $65, $bf, $71, $d7, $35, $1f, $88, $d7, $35, $18, $88, $b1
	db $01, $00, $c3, $7a, $bd, $00, $bc, $4a, $be, $3a, $bf, $4b, $e3, $54, $13, $94
	db $b1, $01, $00, $d8, $7a, $bd, $00, $bc, $4a, $be, $6a, $bf, $78, $be, $0b, $e1
	db $60, $1f, $92, $b1, $01, $00, $e9, $7a, $bd, $00, $bc, $4a, $be, $6a, $c5, $32
	db $bf, $71, $db, $49, $1d, $8c, $b1, $01, $00, $fc, $7a, $bd, $00, $bc, $4a, $be
	db $10, $bf, $5e, $c1, $40, $c2, $0a, $e7, $57, $15, $87, $c1, $3f, $88, $3e, $89
	db $e7, $57, $0e, $c1, $3d, $8a, $3c, $88, $3b, $82, $3a, $83, $39, $81, $e9, $57
	db $09, $c1, $38, $8b, $37, $87, $36, $86, $35, $86, $e1, $57, $07, $c1, $34, $88
	db $33, $83, $32, $84, $31, $83, $da, $57, $04, $c1, $30, $84, $2f, $87, $b1, $01
	db $00, $0f, $7b, $bd, $03, $bc, $4a, $be, $3c, $c5, $14, $bf, $71, $d1, $4a, $18
	db $84, $4b, $84, $4c, $84, $d1, $4d, $11, $84, $4e, $84, $4f, $84, $b1, $01, $00
	db $57, $7b, $bd, $00, $bc, $4a, $be, $1f, $bf, $5e, $c1, $5f, $d5, $64, $19, $81
	db $c1, $40, $81, $01, $84, $d5, $64, $0e, $81, $c1, $40, $81, $01, $84, $b1, $01
	db $00, $76, $7b, $bd, $00, $bc, $4a, $be, $65, $bf, $5e, $d0, $56, $18, $83, $51
	db $81, $b1, $01, $00, $97, $7b, $bd, $00, $bc, $4a, $be, $65, $bf, $67, $d0, $4a
	db $1b, $83, $b1, $01, $00, $aa, $7b, $bd, $00, $bc, $4a, $be, $6a, $bf, $5e, $d0
	db $43, $18, $83, $0c, $83, $b1, $01, $00, $bb, $7b, $bd, $00, $bc, $4a, $be, $63
	db $bf, $78, $d0, $58, $1f, $86, $d0, $54, $1f, $86, $d0, $58, $1f, $86, $5b, $82
	db $b1, $01, $00, $ce, $7b, $bd, $00, $bc, $4a, $be, $35, $bf, $78, $d7, $48, $18
	db $88, $d7, $88, $d7, $88, $d7, $88, $b1, $01, $00, $e9, $7b, $bd, $00, $bc, $4a
	db $be, $3c, $bf, $4b, $d7, $40, $13, $88, $b1, $01, $00, $00, $7c, $bd, $00, $bc
	db $4a, $be, $10, $bf, $4b, $d1, $54, $13, $83, $43, $83, $40, $83, $30, $83, $32
	db $83, $45, $83, $b1, $01, $00, $11, $7c, $bd, $00, $bc, $4a, $be, $3b, $bf, $78
	db $d5, $41, $18, $83, $65, $86, $b1, $01, $00, $2c, $7c, $bd, $00, $bc, $4a, $be
	db $10, $bf, $38, $c1, $40, $c2, $0a, $ce, $57, $0e, $87, $c1, $3f, $88, $3e, $8a
	db $3d, $89, $3c, $88, $3b, $82, $3a, $83, $39, $83, $38, $8b, $37, $87, $36, $86
	db $35, $86, $34, $88, $33, $83, $32, $82, $31, $83, $30, $84, $2f, $87, $2e, $87
	db $2d, $85, $2c, $86, $2b, $88, $2a, $86, $29, $86, $28, $84, $27, $85, $26, $85
	db $25, $85, $24, $81, $23, $82, $22, $82, $21, $86, $20, $84, $1f, $81, $1e, $81
	db $1d, $82, $1c, $83, $1b, $82, $1a, $84, $cf, $b1, $01, $00, $3f, $7c, $bd, $00
	db $bc, $4a, $be, $10, $bf, $5e, $c1, $40, $c2, $0a, $ce, $57, $15, $87, $c1, $3f
	db $88, $3e, $8a, $3d, $89, $3c, $88, $3b, $82, $3a, $83, $39, $83, $38, $8b, $37
	db $87, $36, $86, $35, $86, $34, $88, $33, $83, $32, $82, $31, $83, $30, $84, $2f
	db $87, $2e, $87, $2d, $85, $2c, $86, $2b, $88, $2a, $86, $29, $86, $28, $84, $27
	db $85, $26, $85, $25, $85, $24, $81, $23, $82, $22, $82, $21, $86, $20, $84, $1f
	db $81, $1e, $81, $1d, $82, $1c, $83, $1b, $82, $1a, $84, $cf, $b1, $01, $00, $a2
	db $7c, $bd, $00, $bc, $4a, $be, $6a, $bf, $4b, $d1, $3c, $13, $83, $b1, $01, $00
	db $05, $7d, $bd, $00, $bc, $4a, $be, $0a, $bf, $00, $d0, $3c, $00, $81, $b1, $bd
	db $00, $be, $14, $bf, $00, $d0, $3c, $00, $81, $b1, $bd, $00, $be, $1e, $bf, $00
	db $d0, $3c, $00, $81, $b1, $bd, $00, $be, $65, $bf, $00, $d0, $3c, $00, $81, $b1
	db $04, $00, $16, $7d, $23, $7d, $2e, $7d, $39, $7d, $bd, $00, $bc, $4a, $be, $65
	db $bf, $00, $d0, $3c, $00, $81, $b1, $01, $00, $4e, $7d, $bd, $00, $bc, $4a, $be
	db $3a, $bf, $4b, $e3, $54, $13, $94, $b1, $01, $00, $5f, $7d, $bd, $00, $bc, $4a
	db $be, $10, $bf, $5e, $d1, $54, $11, $82, $d1, $56, $11, $82, $d1, $58, $11, $82
	db $b1, $01, $00, $70, $7d, $bd, $00, $bc, $4a, $be, $10, $bf, $5e, $d1, $58, $11
	db $82, $d1, $56, $11, $82, $d1, $54, $11, $82, $b1, $01, $00, $89, $7d, $bd, $00
	db $bc, $4a, $be, $6a, $bf, $5e, $d1, $3c, $18, $84, $3d, $84, $3e, $82, $b1, $01
	db $00, $a2, $7d, $bd, $00, $bc, $4a, $be, $10, $bf, $4b, $c2, $14, $c1, $41, $e1
	db $35, $13, $85, $c1, $42, $81, $45, $81, $4a, $82, $53, $81, $56, $81, $5e, $81
	db $66, $81, $69, $81, $6d, $81, $73, $81, $7a, $81, $7e, $81, $b1, $01, $00, $b7
	db $7d, $bd, $00, $bc, $4a, $be, $10, $bf, $4b, $c2, $14, $c1, $3f, $e1, $48, $13
	db $85, $c1, $3e, $81, $3b, $81, $36, $82, $2d, $81, $2a, $81, $22, $81, $1a, $81
	db $17, $81, $13, $81, $0d, $81, $06, $81, $02, $81, $b1, $01, $00, $e5, $7d, $bd
	db $00, $bc, $4a, $be, $10, $bf, $71, $d1, $48, $1d, $83, $4c, $83, $4f, $83, $54
	db $83, $48, $18, $83, $4c, $83, $4f, $83, $54, $83, $48, $0e, $83, $4c, $83, $4f
	db $83, $54, $83, $b1, $01, $00, $13, $7e, $bd, $02, $bc, $4a, $be, $0d, $c3, $7f
	db $c4, $00, $c5, $32, $c6, $00, $bf, $78, $d4, $35, $1f, $8c, $e7, $98, $b1, $bd
	db $02, $be, $5d, $c3, $7f, $c4, $00, $c5, $32, $c6, $00, $bf, $78, $d4, $33, $1f
	db $8c, $e7, $98, $b1, $02, $00, $3c, $7e, $53, $7e, $bd, $00, $be, $4a, $bf, $5e
	db $d0, $5f, $18, $81, $0c, $82, $d0, $60, $18, $81, $0c, $82, $d0, $5f, $18, $81
	db $0c, $82, $d0, $60, $18, $81, $0c, $82, $d0, $5f, $18, $81, $0c, $82, $d0, $60
	db $18, $81, $0c, $82, $d7, $5f, $18, $81, $0c, $82, $d7, $60, $18, $81, $0c, $82
	db $d7, $5f, $11, $81, $07, $82, $d7, $60, $11, $81, $07, $82, $d0, $5f, $11, $81
	db $07, $82, $d0, $60, $11, $81, $07, $82, $d7, $5f, $11, $81, $07, $82, $d7, $60
	db $11, $81, $07, $82, $b1, $01, $00, $6e, $7e, $bd, $00, $bc, $4a, $be, $11, $bf
	db $5e, $e7, $54, $18, $98, $b1, $01, $00, $cd, $7e, $bd, $00, $bc, $4a, $be, $11
	db $bf, $5e, $e7, $60, $18, $98, $b1, $01, $00, $de, $7e, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
