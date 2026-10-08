INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $051", ROMX[$4000], BANK[$51]

;@ path: system/banks
;@ Bank number byte of bank $51 (battle screen set-up, level-up and recruit screens, battle
;@ panel, cursor and name routines): RST $10 reads it to know which bank to switch back to.
BankNumber_51::
	db $51

;@ path: system/banks
;@ Far-call table of bank $51 (entry n is called with `ld hl, $51nn` + `rst $10`; entry $12 is the
;@ compressed cursor tiles, used as decompress entry $5112).
FarTable_51::
	dw StartBattleScreen
	dw PackResistancesFar
	dw SaveBattleResults
	dw DefeatBattler
	dw AppendEnemyLetter
	dw SetUpCalledMonster1
	dw SetUpCalledMonster2
	dw SetUpCalledMonster3
	dw SetUpCalledMonster4
	dw TransformSkillUser
	dw LoadBattlerSkills
	dw ReloadBattler
	dw LevelUpScreen
	dw ApplyLevelUp
	dw RecruitScreen
	dw BattlerFallSequence
	dw SetBattlePicPalettes
	dw LoadMonsterPicFar
	dw BattleCursorGfx

;@ def SetUpBattleScreen()
;@ path: battle/screen
;@ Builds the battle screen: neutral SGB palettes, the battle tiles (window frame, symbols, font), the
;@ text box, the monster pictures and the party panel; starts the battle music and turns the screen on.
SetUpBattleScreen::
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
;> Decompress(0x5B, 0, 0x9600)     # battle window and symbol tiles
	ld de, $5b00
	ld hl, $9600
	call Decompress
;> Decompress(0x5B, 1, 0x8800)
	ld de, $5b01
	ld hl, $8800
	call Decompress
;> Decompress(0x2E, 0, 0x8D00)
	ld de, $2e00
	ld hl, $8d00
	call Decompress
;> SetUpTextBox(0x8B00, 2, 18)       # two lines of 18 letters
	ld hl, $8b00
	ld de, $1202
	call SetUpTextBox
;> LoadBattleGraphics()
	call LoadBattleGraphics
;> StorePartyPersonalities()
	call StorePartyPersonalities
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .music

;>     wQueuedMusic = 0xFF; wQueuedSound = 0xFF
	ld a, $ff
	ld [wQueuedMusic], a
	ld [wQueuedSound], a
;>     InitSound()
	call InitSound

;> song = 0x27                        # the battle theme
.music:
	ld b, $27
;> if wMapId == 0x5D:                 # the Starry Night arena
	ld a, [wMapId]
	cp $5d
	jp nz, .play

;>     wGameStarted &= ~0x80
	ld hl, wGameStarted
	res 7, [hl]
;>     if mem[0xD999] == 2:
	ld a, [wArenaFight]
	cp $02
	jr nz, .play

;>         song = 0x2B
	ld b, $2b

;> QueueMusic(song)
.play:
	ld a, b
	call QueueMusic
;> hWX = 7; hWY = 0xFF                # window off screen
	ld a, $07
	ldh [hWX], a
	ld a, $ff
	ldh [hWY], a
;> mem[addr(hScrollY)] = 0; mem[addr(hScrollX)] = 0
	ld a, $00
	ldh [hScrollY], a
	ld a, $00
	ldh [hScrollX], a
;> ApplyScroll()
	call ApplyScroll
;> ClearShadowOAM()
	call ClearShadowOAM
;> wFrameCounter = 0
	xor a
	ld [wFrameCounter], a
	ld [$c8a5], a
;> wLCDEffect = 0; mem[0xDD62] = 0
	xor a
	ld [wLCDEffect], a
	xor a
	ld [$dd62], a
;> wLinkSendByte = 0; wLinkReceivedLast = 0
	xor a
	ld [wLinkSendByte], a
	xor a
	ld [wLinkReceivedLast], a
;> ClearAttrMap()
	ld hl, far_ClearAttrMap
	rst $10
;> SetBattlePicPalettes()
	ld hl, far_SetBattlePicPalettes
	rst $10
;> wLCDC = 3
	ld a, $03
	ld [wLCDC], a
;> EnableLYCInterrupt()
	call EnableLYCInterrupt
;> return EnableLCDAndInterrupts(0x0B)
	ld a, $0b
	jp EnableLCDAndInterrupts


;@ def StorePartyPersonalities()
;@ path: battle/setup
;@ Looks up the personality of each party monster (GetMonsterPersonality) into wPartyPersonality.
StorePartyPersonalities::
;> if wPartyCount == 0: return
	ld a, [wPartyCount]
	or a
	ret z

;> wPartyPersonality[0] = GetMonsterPersonality(wParty[0])
	ld a, [wParty]
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	ld [wPartyPersonality], a
;> if wPartyCount == 1: return
	ld a, [wPartyCount]
	cp $01
	ret z

;> wPartyPersonality[1] = GetMonsterPersonality(wParty[1])
	ld a, [$ca8f]
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	ld [$da16], a
;> if wPartyCount == 2: return
	ld a, [wPartyCount]
	cp $02
	ret z

;> wPartyPersonality[2] = GetMonsterPersonality(wParty[2])
	ld a, [$ca90]
	ld d, a
	ld hl, far_GetMonsterPersonality
	rst $10
	ld a, d
	ld [$da17], a
;> return
	ret


;@ def LoadBattleGraphics()
;@ path: battle/screen
;@ Loads the name tiles and the pictures of the three opposing monsters (tiles $9000, $9240, $9480;
;@ for an empty position far_BlankEnemyPicture runs instead), then clears the screen and draws the enemy
;@ pictures and the party panel into the tilemap buffer and the BG map.
LoadBattleGraphics::
;> fill(wMenuChoice, 8, 0)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> LoadBattleNameTiles()
	call LoadBattleNameTiles
;> wSkillTarget = 4; species = addr(wBattlerSpecies) + 4   # the far side: the enemies
	ld a, $04
	ld [wSkillTarget], a
	ld de, $dc40
;> if wLinkFlags & 2:                 # link master: the partner's monsters are positions 0-2
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .pics

;>     wSkillTarget = 0; species = addr(wBattlerSpecies)
	xor a
	ld [wSkillTarget], a
	ld de, wBattlerSpecies

;>@pic for tiles in (0x9000, 0x9240, 0x9480):
.pics:
	ld hl, $9000
;>     if not CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .empty1

;>         LoadMonsterPic(mem[species], tiles)
	ld a, [de]
	call LoadMonsterPic
	jr .next1

;>     else:
;>         BlankEnemyPicture()
.empty1:
	ld hl, far_BlankEnemyPicture
	rst $10

;>     wSkillTarget += 1; species += 1
.next1:
	ld hl, wSkillTarget
	inc [hl]
	inc de
;=@pic
	ld hl, $9240
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .empty2

;=@pic
	ld a, [de]
	call LoadMonsterPic
	jr .next2

;=@pic
.empty2:
	ld hl, far_BlankEnemyPicture
	rst $10

;=@pic
.next2:
	ld hl, wSkillTarget
	inc [hl]
	inc de
;=@pic
	ld hl, $9480
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .empty3

;=@pic
	ld a, [de]
	call LoadMonsterPic
	jr .done

;=@pic
.empty3:
	ld hl, far_BlankEnemyPicture
	rst $10

;> fill(0xD9F4, 8, 0)                 # the screen step variables
.done:
	xor a
	ld hl, $d9f4
	ld bc, $0008
	call FillMemory
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> ClearBGMap()
	call ClearBGMap
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> PlaceEnemyPics()
	call PlaceEnemyPics
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> ClearBGAttributes()
	call ClearBGAttributes
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def LoadBattleNameTiles()
;@ path: battle/screen
;@ Loads the status icons of the three own positions and draws the names of the own monsters into
;@ the name tiles at $9700, $9740 and $9780 (4 tiles each).
LoadBattleNameTiles::
;> pos = 0
	ld d, $00
;> if wLinkActive and wLinkFlags & 2:   # the link master's own side is 4-6
	ld a, [wLinkActive]
	or a
	jr z, .icons

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .icons

;>     pos = 4
	ld d, $04

;>@icon for i in range(3):
.icons:
;>     wSkillTarget = pos + i
	ld a, d
	ld [wSkillTarget], a
;>     UpdateStatusIcon()
	call UpdateStatusIcon
;=@icon
	inc d
	ld a, d
	ld [wSkillTarget], a
	call UpdateStatusIcon
;=@icon
	inc d
	ld a, d
	ld [wSkillTarget], a
	call UpdateStatusIcon
;> p = 0x9700
	ld hl, $9700
;>@clr for i in range(0x60):        # 12 empty tiles
	ld b, $60

;>     mem[p] = 0xFF; mem[p + 1] = 0; p += 2
.clear:
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
;=@clr
	dec b
	jr nz, .clear

;> wBattleTemp = wPartyCount
	ld a, [wLinkActive]
	or a
	ld a, [wPartyCount]
	ld [wBattleTemp], a
;> if not wLinkActive and wPartyCount == 0: return
	jr nz, .names

	or a
	ret z

;> pos = 0
.names:
	ld d, $00
;> if wLinkActive and wLinkFlags & 2:
	ld a, [wLinkActive]
	or a
	jr z, .draw

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .draw

;>     wBattleTemp = wEnemyCount; pos = 4
	ld a, [wEnemyCount]
	ld [wBattleTemp], a
	ld d, $04
	jr .draw

;> name = PartyMonsterField(pos, wMonName)
.draw:
	push de
	ld hl, wMonName
	ld a, d
	call PartyMonsterField
;> DrawMonNameTiles(name, 0x9700)
	ld e, l
	ld d, h
	ld hl, $9700
	call DrawMonNameTiles
	pop de
;> if wBattleTemp == 1: return
	ld a, [wBattleTemp]
	cp $01
	ret z

;> name = PartyMonsterField(pos + 1, wMonName)
	inc d
	push de
	ld hl, wMonName
	ld a, d
	call PartyMonsterField
;> DrawMonNameTiles(name, 0x9740)
	ld e, l
	ld d, h
	ld hl, $9740
	call DrawMonNameTiles
	pop de
;> if wBattleTemp == 2: return
	ld a, [wBattleTemp]
	cp $02
	ret z

;> name = PartyMonsterField(pos + 2, wMonName)
	inc d
	push de
	ld hl, wMonName
	ld a, d
	call PartyMonsterField
;> DrawMonNameTiles(name, 0x9780)
	ld e, l
	ld d, h
	ld hl, $9780
	call DrawMonNameTiles
	pop de
;> return
	ret


;@ def StartBattleScreen()
;@ path: battle/setup
;@ Far entry: sets up all battle positions, then builds the battle screen.
StartBattleScreen::
;> InitBattlers()
	call InitBattlers
;> SetUpBattleScreen()
	call SetUpBattleScreen
;> return
	ret


;@ def InitBattlers()
;@ path: battle/setup
;@ Clears the battle state and fills the battle positions: the own monsters from their records
;@ (positions 0-2), the enemies from their monster templates (4-6) or, in a link battle, from the
;@ records the partner sent. Then fixes up the skill lists, reads each monster's MonsterStats type bits
;@ and clears the menu memory and the status icons.
InitBattlers::
;> SetBattleType()
	call SetBattleType
;> CountBattlers()
	call CountBattlers
;> if wPartyBattlers == 0:
	ld a, [wPartyBattlers]
	or a
	jr nz, .init

;>     wBattlerSpecies[4] = 0x6D
	ld a, $6d
	ld [$dc40], a
;>     return
	ret

;> mem[0xDA88] = 0; mem[0xDA82] = 0xFF
.init:
	xor a
	ld [wDebugStatsShown], a
	ld a, $ff
	ld [$da82], a
;> fill(0xDB00, 0x73, 0)
	xor a
	ld hl, wSideFlags
	ld bc, $0073
	call FillMemory
;> fill(wBattlerState, 8, 0xFF)       # all positions empty
	ld hl, wBattlerState
	ld bc, $0008
	ld a, $ff
	call FillMemory
;> fill(wBattlerTypeBits, 0xD9, 0)
	ld hl, wBattlerTypeBits
	ld bc, $00d9
	xor a
	call FillMemory
;> fill(wBattlerSpecies, 8, 0xFF)
	ld hl, wBattlerSpecies
	ld bc, $0008
	ld a, $ff
	call FillMemory
;> fill(wBattlerTactic, 8, 0xFF)
	ld a, $ff
	ld hl, wBattlerTactic
	ld bc, $0008
	call FillMemory
;> if wPartyBattlers:
	ld a, [wPartyBattlers]
	or a
	jr z, .tactics

;>     fill(wBattlerTactic, wPartyBattlers, 0)
	ld c, a
	ld b, $00
	xor a
	ld hl, wBattlerTactic
	push bc
	call FillMemory
;>     fill(wBattlerSexBits67, wPartyBattlers, 0)
	pop bc
	ld hl, wBattlerSexBits67
	xor a
	call FillMemory

;> fill(wTacticMenuRow, 6, 0)
.tactics:
	ld hl, wTacticMenuRow
	ld bc, $0006
	xor a
	call FillMemory
;> wTeamTactic = wSavedTeamTactic
	ld a, [wSavedTeamTactic]
	ld [wTeamTactic], a
;> fill(wBattlerIntClass, 16, 0)
	xor a
	ld hl, wBattlerIntClass
	ld bc, $0010
	call FillMemory
;> fill(wBattlerSkills, 0x80, 0xFF)
	ld a, $ff
	ld hl, wBattlerSkills
	ld bc, $0080
	call FillMemory
;> mem[0xC1CA] = mem[0xC1CB] = mem[0xC1CC] = 0xFF
	ld a, $ff
	ld hl, $c1ca
	ld [hli], a
	ld [hli], a
	ld [hl], a
;>@own for pos in range(wPartyBattlers):
	ld a, [wPartyBattlers]
	ld b, a
	ld c, $00

;>     LoadBattler(pos)
.own:
	call LoadBattler
	inc c
;=@own
	dec b
	jr nz, .own

;>@enemy for pos in range(4, 4 + wEnemyCount):
	ld a, [wEnemyCount]
	ld b, a
	ld c, $04

;>     LoadBattler(pos)
.enemy:
	call LoadBattler
	inc c
;=@enemy
	dec b
	jr nz, .enemy

;> wRunTurn = 0; wJoinCandidate = 0
	xor a
	ld [wRunTurn], a
	ld [wJoinCandidate], a
;> wBattleSubStep = 0
	xor a
	ld [wBattleSubStep], a
;> fill(0xDCE4, 0x18, 0xFF)
	ld a, $ff
	ld hl, $dce4
	ld bc, $0018
	call FillMemory
;> fill(0xDCFC, 7, 0)
	xor a
	ld hl, wSkillTargeting
	ld bc, $0007
	call FillMemory
;> wBattleItemTarget = 0xFF; wBattleItemEffect = 0xFF
	ld hl, $ffff
	ld a, l
	ld [wBattleItemTarget], a
	ld a, h
	ld [wBattleItemEffect], a
;> fill(wBattleArg0, 0x27, 0)
	xor a
	ld hl, wBattleArg0
	ld bc, $0027
	call FillMemory
;> mem16[0xDB83] = 10
	ld hl, $000a
	ld a, l
	ld [wJoinPoints], a
	ld a, h
	ld [$db84], a
;> wBattleItemTarget = 0xFF; wBattleItemEffect = 0xFF
	ld a, $ff
	ld [wBattleItemTarget], a
	ld [wBattleItemEffect], a
;> if not wLinkActive:
	ld a, [wPartyBattlers]
	ld d, a
	ld e, $00
	ld a, [wLinkActive]
	or a
	jr nz, .skills

;>     n = wEnemyCount
	ld hl, wEnemyDown
	ld b, $00
	ld a, [wEnemyCount]
	ld c, a
;>     if n: fill(wEnemyDown, n, 0)
	or a
	ld a, $00
	call nz, FillMemory

;> SubstituteSkills()
.skills:
	call SubstituteSkills
;> SetSkillKinds()
	call SetSkillKinds
;> p = addr(wBattlerTypeBits)
	ld de, wBattlerTypeBits
;>@pos for pos in range(8):
	ld bc, $0800

;>     q = addr(wBattlerState) + pos
.pos:
	push bc
	ld a, c
	ld hl, wBattlerState
	add l
	ld l, a
;>     if mem[q] != 0xFF:
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, .nextPos

;>         q = addr(wBattlerSpecies) + pos
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;>         wMonSpecies = mem[q]
	ld h, a
	ld a, [hl]
	ld [wMonSpecies], a
;>         GetMonsterStats()
	push de
	ld hl, far_GetMonsterStats
	rst $10
	pop de
;>         mem[p] = (wMonStatsByte4 << 4 | wMonStatsByte5) & 0xFF
	ld a, [wMonStatsByte5]
	ld h, a
	ld a, [wMonStatsByte4]
	swap a
	or h
	ld [de], a

;>     p += 1
.nextPos:
	pop bc
	inc de
	inc c
;=@pos
	dec b
	jr nz, .pos

;> fill(wMenuChoice, 8, 0)
	ld hl, wMenuChoice
	ld bc, $0008
	xor a
	call FillMemory
;> fill(wPartyBarTiles, 15, 0xFF)
	ld hl, wPartyBarTiles
	ld bc, $000f
	ld a, $ff
	call FillMemory
;> wTargetCursorSkill = 0
	ld a, $00
	ld [wTargetCursorSkill], a
;> fill(wBattlerMenuMemory, 8, 0x80)
	ld hl, wBattlerMenuMemory
	ld bc, $0008
	ld a, $80
	call FillMemory
;> ClearMonStatsCopy()
	call ClearMonStatsCopy
;> ResetStatusIcons()
	call ResetStatusIcons
;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> return
	ret


;@ def SetBattleType()
;@ path: battle/setup
;@ Sets wBattleType from how the battle started: 2 for a link battle or a battle on the arena map ($5D),
;@ 0 for a wild encounter, 1 for other scripted battles. Link battles run at message speed 6.
SetBattleType::
;>@t2 t = 2
;> if not wLinkActive:
	ld a, [wLinkActive]
	or a
	jr nz, .two

;>     if wBattleKind == 0:
	ld a, [wBattleKind]
	or a
	jr z, .zero

;>@t0         t = 0
;>     elif wScriptMap != 0x5D:
	ld a, [wScriptMap]
	cp $5d
	jr nz, .one

;>@t1         t = 1
;=@t2
.two:
	ld a, $02
	jr .store

;=@t0
.zero:
	ld a, $00
	jr .store

;=@t1
.one:
	ld a, $01

;> wBattleType = t
.store:
	ld [wBattleType], a
;> if not wLinkActive: return
	ld a, [wLinkActive]
	or a
	ret z

;> wMessageSpeed = 6
	ld a, $06
	ld [wMessageSpeed], a
;> return
	ret


;@ def PackResistancesFar()
;@ path: battle/setup
;@ Far entry for PackResistances: the source address in wBattleArg0/1, the destination in wBattleArg2/3.
PackResistancesFar::
;> src = wBattleArg0 | wBattleArg1 << 8
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
;> dest = wBattleArg2 | wBattleArg3 << 8
	ld a, [wBattleArg2]
	ld e, a
	ld a, [wBattleArg3]
	ld d, a

;@ def PackResistances(src: hl, dest: de)
;@ path: battle/setup
;@ Packs 27 resistance values (0-3 each) into 7 bytes, two bits each from the top down. The first byte
;@ holds resistance 26 in bits 6-7 and resistances 0-2 below it, the next five bytes resistances 3-22,
;@ the last byte resistances 23-25 in bits 7-2.
PackResistances::
;> p = src + 26
	push hl
	ld a, $1a
	add l
	ld l, a
	ld a, $00
	adc h
;> top = (mem[p] & 3) << 6
	ld h, a
	ld a, [hl]
	and $03
	rrc a
	rrc a
	ld c, a
;> v = (mem[src] << 2 | mem[src + 1]) & 0xFF
	pop hl
	ld a, [hli]
	sla a
	sla a
	or [hl]
	inc hl
;> v = (v << 2 | mem[src + 2]) & 0xFF
	sla a
	sla a
	or [hl]
	inc hl
;> mem[dest] = v | top; src += 3; dest += 1
	or c
	ld [de], a
	inc de
;>@b for i in range(5):
	ld b, $05

;>     v = (mem[src] << 2 | mem[src + 1]) & 0xFF
.pack:
	ld a, [hli]
	sla a
	sla a
	or [hl]
	inc hl
;>     v = (v << 2 | mem[src + 2]) & 0xFF
	sla a
	sla a
	or [hl]
	inc hl
;>     mem[dest] = (v << 2 | mem[src + 3]) & 0xFF; src += 4; dest += 1
	sla a
	sla a
	or [hl]
	inc hl
	ld [de], a
	inc de
;=@b
	dec b
	jr nz, .pack

;> v = (mem[src] << 2 | mem[src + 1]) & 0xFF
	ld a, [hli]
	sla a
	sla a
	or [hl]
	inc hl
;> mem[dest] = ((v << 2 | mem[src + 2]) << 2) & 0xFF
	sla a
	sla a
	or [hl]
	sla a
	sla a
	ld [de], a
;> return
	ret


;@ def CountBattlers()
;@ path: battle/setup
;@ Sets wPartyBattlers and wEnemyCount (and wPanelCount, wEncCount). Normally they come from the party
;@ and the encounter group. In a link battle both teams sit in monster slots 0-2 and 4-6, and each count
;@ is the number of filled slots before the first empty one.
CountBattlers::
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .local

;>     c = 0
	ld bc, $0300

;>     while c < 3 and GetPartyMonsterByte(c, wMonsters) != 0:
.count1:
	ld a, c
	ld hl, wMonsters
	call GetPartyMonsterByte
	or a
	jr z, .got1

;>         c += 1
	inc c
	dec b
	jr nz, .count1

;>     wPartyBattlers = c; wPanelCount = c
.got1:
	ld a, c
	ld [wPartyBattlers], a
	ld [wPanelCount], a
;>     c = 4
	ld bc, $0304

;>     while c < 7 and GetPartyMonsterByte(c, wMonsters) != 0:
.count2:
	ld a, c
	ld hl, wMonsters
	call GetPartyMonsterByte
	or a
	jr z, .got2

;>         c += 1
	inc c
	dec b
	jr nz, .count2

;>     wEnemyCount = c - 4; wEncCount = c - 5
.got2:
	ld a, c
	sub $04
	ld [wEnemyCount], a
	dec a
	ld [wEncCount], a
;>     if not wLinkFlags & 2: return
	ld a, [wLinkFlags]
	bit 1, a
	ret z

;>     wPanelCount = wEnemyCount       # the master shows the partner's team in the panel
	ld a, [wEnemyCount]
	ld [wPanelCount], a
;>     return
	ret

;> else:
;>     wPartyBattlers = wPartyCount; wPanelCount = wPartyCount
.local:
	ld a, [wPartyCount]
	ld [wPartyBattlers], a
	ld [wPanelCount], a
;>     wEnemyCount = wEncCount + 1
	ld a, [wEncCount]
	inc a
	ld [wEnemyCount], a
;>     return
	ret


;@ def ReloadBattler()
;@ path: battle/setup
;@ Far entry: refreshes battle position wBattleArg0 from its monster record (when a transformation
;@ ends), keeping its current HP, MP and ailments.
ReloadBattler::
;> pos = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a
;> wBattlerReload = 1; return LoadBattler(pos)        # runs on into LoadBattler
	ld a, $01
	ld [wBattlerReload], a

;@ def LoadBattler(pos: c)
;@ path: battle/setup
;@ Fills battle position `pos`: the own positions (and all positions in a link battle) from the monster
;@ record, the enemy positions from the encounter's monster template.
LoadBattler::
;> if wLinkActive: return LoadBattlerFromRecord(pos)
	ld a, [wLinkActive]
	or a
	jr nz, LoadBattlerFromRecord

;> if pos < 4:
	ld a, c
	cp $04
	jr nc, .enemy

;>     LoadBattlerFromRecord(pos)
	call LoadBattlerFromRecord
;>     ClearMonStatsCopy()
	call ClearMonStatsCopy
;>     return
	ret

;> LoadEnemyBattler(pos)
.enemy:
	call LoadEnemyBattler
;> ClearMonStatsCopy()
	call ClearMonStatsCopy
;> return
	ret


;@ def LoadBattlerFromRecord(pos: c)
;@ path: battle/setup
;@ Copies the monster record of party position `pos` into battle position `pos`: species, sex, tactic
;@ (record byte +$0B: sex in bits 0-3, tactic in bits 4-5, two more bits 6-7), skills, ailments, level,
;@ HP and MP, the four stats, wildness, the personality bytes and the packed resistances. While
;@ wBattlerReload is set the current HP, MP and ailments stay, and so do the personality bytes when
;@ status byte 1 bits 4-5 are set.
LoadBattlerFromRecord::
;> rec = PartyMonsterField(pos, wMonRecSpecies)
	ld a, c
	ld hl, wMonRecSpecies
	call PartyMonsterField
;> q = addr(wBattlerSpecies) + pos
	ld a, c
	ld de, wBattlerSpecies
	add e
	ld e, a
	ld a, $00
	adc d
;> SetBattlerPalSpecies(pos, rec)
	ld d, a
	call SetBattlerPalSpecies
;> mem[q] = mem[rec]; rec += 2              # skip the family byte
	ld a, [hli]
	ld [de], a
	inc hl
;> q = addr(wBattlerSex) + pos
	ld a, c
	ld de, wBattlerSex
	add e
	ld e, a
	ld a, $00
	adc d
;> mem[q] = mem[rec] & 0x0F
	ld d, a
	ld a, [hl]
	and $0f
	ld [de], a
;> hi = mem[rec] >> 4; rec += 1
	ld a, [hli]
	swap a
	and $0f
	push af
;> q = addr(wBattlerTactic) + pos
	ld a, c
	ld de, wBattlerTactic
	add e
	ld e, a
	ld a, $00
	adc d
;> mem[q] = hi & 3
	ld d, a
	pop af
	push af
	and $03
	ld [de], a
;> hi2 = hi
	pop af
	push af
	push af
;> q = addr(wBattlerSexBits67) + pos
	ld a, c
	ld de, wBattlerSexBits67
	add e
	ld e, a
	ld a, $00
	adc d
;> mem[q] = (hi >> 2) & 3
	ld d, a
	pop af
	rrca
	rrca
	and $03
	ld [de], a
;> if not pos & 4:
	ld a, c
	bit 2, a
	jr nz, .far

;>     if not wLinkFlags & 2:         # the tactic menu shows this Game Boy's own monsters
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .drop

;>         q = addr(wMonTactics) + pos
	ld a, c
	inc a
	inc a
	ld de, wTacticMenuRow
	add e
;>         v = hi2 & 3
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	and $03
;>         mem[q] = v
	ld [de], a
	jr .skills

;> elif wLinkFlags & 2:
.far:
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .drop

;>     q = addr(wMonTactics) + (pos & 3)
	ld a, c
	and $03
	inc a
	inc a
	ld de, wTacticMenuRow
	add e
;>     v = hi2 & 3
	ld e, a
	ld a, $00
	adc d
	ld d, a
	pop af
	and $03
;>     mem[q] = v
	ld [de], a
	jr .skills

;> else:
;>     del hi2
.drop:
	pop af

;> rec += 0x1D                              # the skill list
.skills:
	ld a, $1d
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> if wBattleArg0 == 0:
	push hl
	push bc
	ld a, [wBattleArg0]
	or a
	jr nz, .reloadSkills

;>     CopyBattlerSkills(pos, rec)
	call CopyBattlerSkills
	jr .status

;> else:
;>     LoadBattlerSkills()
.reloadSkills:
	call LoadBattlerSkills

;> rec += 0x21                              # the status byte
.status:
	pop bc
	pop hl
	ld a, $21
	add l
	ld l, a
;> if not wBattlerReload: LoadBattlerAilments(pos, rec)
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattlerReload]
	or a
	call z, LoadBattlerAilments
;> rec = StoreBattlerByte(pos, addr(wBattlerLevel), rec + 1)
	inc hl
	ld de, wBattlerLevel
	call StoreBattlerByte
;> rec += 4                                 # skip the experience
	inc hl
	inc hl
	inc hl
	inc hl
;> if wBattlerReload:
	ld a, [wBattlerReload]
	or a
	jr z, .allHPMP

;>     rec = StoreBattlerWord(pos, addr(wBattlerMaxHP), rec + 2)
	inc hl
	inc hl
	ld de, wBattlerMaxHP
	call StoreBattlerWord
;>     rec = StoreBattlerWord(pos, addr(wBattlerMaxMP), rec + 2)
	inc hl
	inc hl
	ld de, wBattlerMaxMP
	call StoreBattlerWord
	jr .stats

;> else:
;>     rec = StoreBattlerWord(pos, addr(wBattlerHP), rec)
.allHPMP:
	ld de, wBattlerHP
	call StoreBattlerWord
;>     rec = StoreBattlerWord(pos, addr(wBattlerMaxHP), rec)
	ld de, wBattlerMaxHP
	call StoreBattlerWord
;>     rec = StoreBattlerWord(pos, addr(wBattlerMP), rec)
	ld de, wBattlerMP
	call StoreBattlerWord
;>     rec = StoreBattlerWord(pos, addr(wBattlerMaxMP), rec)
	ld de, wBattlerMaxMP
	call StoreBattlerWord

;> rec = StoreBattlerWord(pos, addr(wBattlerAttack), rec)
.stats:
	ld de, wBattlerAttack
	call StoreBattlerWord
;> rec = StoreBattlerWord(pos, addr(wBattlerDefense), rec)
	ld de, wBattlerDefense
	call StoreBattlerWord
;> rec = StoreBattlerWord(pos, addr(wBattlerAgility), rec)
	ld de, wBattlerAgility
	call StoreBattlerWord
;> rec = StoreBattlerWord(pos, addr(wBattlerIntelligence), rec)
	ld de, wBattlerIntelligence
	call StoreBattlerWord
;> rec = StoreBattlerWord(pos, addr(wBattlerWildness), rec)
	ld de, wBattlerWildness
	call StoreBattlerWord
;> rec += 2
	inc hl
	inc hl
;>@pers if not wBattlerReload or mem[addr(wBattlerStatus) + 8 * wBattleArg0 + 1] & 0x30:
	ld a, [wBattlerReload]
	or a
	jr z, .personality

;=@pers
	ld a, [wBattleArg0]
	push hl
	ld hl, wBattlerStatus1
	add a
	add a
	add a
;=@pers
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@pers
	and $30
	pop hl
	jr nz, .personality

;=@skip4
	inc hl
	inc hl
	inc hl
	inc hl
;=@skipjr
	jr .resist

;>     rec = StoreBattlerByte(pos, addr(wBattlerPersonality1), rec)
.personality:
	ld de, wBattlerPersonality1
	call StoreBattlerByte
;>     rec = StoreBattlerByte(pos, addr(wBattlerPersonality2), rec)
	ld de, wBattlerPersonality2
	call StoreBattlerByte
;>     rec = StoreBattlerByte(pos, addr(wBattlerPersonality3), rec)
	ld de, wBattlerPersonality3
	call StoreBattlerByte
;>     rec = StoreBattlerByte(pos, addr(wBattlerStat67), rec)
	ld de, wBattlerStat67
	call StoreBattlerByte
;>@skipjr else:
;>@skip4     rec += 4

;> off = 7 * pos
.resist:
	ld a, c
	add a
	add c
	add a
	add c
;> q = addr(wBattlerResist) + off
	ld de, wBattlerResist
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> PackResistances(rec, q)
	push bc
	call PackResistances
	pop bc
;> SetIntClass(pos)
	call SetIntClass
;> return
	ret


;@ def LoadEnemyBattler(pos: c)
;@ path: battle/setup
;@ Fills enemy position `pos` (4-6) from the monster template of encounter species wEncSpecies[pos - 4]:
;@ level, stats, skills and reward (LoadEnemyFromTemplate), the CGB palette species, then the sex
;@ (rolled from the MonsterStats sex chance) and the resistances.
LoadEnemyBattler::
;> i = pos - 4
	push bc
	ld a, c
	sub $04
	ld c, a
	push bc
;> p = addr(wEncSpecies) + 2 * i
	ld hl, wEncSpecies
	ld a, c
	add a
	add l
	ld l, a
	ld a, $00
;> species = mem16[p]
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> wNewMonId = species
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> LoadEnemyFromTemplate(i)
	pop bc
	call LoadEnemyFromTemplate
;> p = addr(wBattlerSpecies) + pos
	ld a, c
	add $04
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
;> SetEnemyPalSpecies(i, p)
	adc h
	ld h, a
	call SetEnemyPalSpecies
;> wMonSpecies = mem[p]
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	push bc
	ld hl, far_GetMonsterStats
	rst $10
	pop bc
;> RollEnemySex(i)
	call RollEnemySex
;> return
	pop bc
	ret


;@ def SetBattlerPalSpecies(pos: c, p: hl)
;@ path: battle/setup
;@ On a Game Boy Color, stores the species at `p` for battle position `pos` at $DB00 + pos in WRAM
;@ bank 2, where the picture palette code looks it up.
;@ test: skip writes WRAM bank 2
SetBattlerPalSpecies::
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;> species = mem[p]; rSVBK = 2
	push de
	push hl
	ld h, [hl]
	ld a, $02
	ldh [rSVBK], a
;> q = 0xDB00 + pos
	ld a, c
	ld de, wSideFlags
	add e
	ld e, a
	ld a, $00
	adc d
;> mem[q] = species                    # in WRAM bank 2
	ld d, a
	ld a, h
	ld [de], a
;> rSVBK = 0
	ld a, $00
	ldh [rSVBK], a
;> return
	pop hl
	pop de
	ret


;@ def SetEnemyPalSpecies(i: c, p: hl)
;@ path: battle/setup
;@ SetBattlerPalSpecies for enemy number `i` (battle position i + 4).
SetEnemyPalSpecies::
;> SetBattlerPalSpecies(i + 4, p)
	push bc
	ld a, c
	add $04
	ld c, a
	call SetBattlerPalSpecies
;> return
	pop bc
	ret


;@ def StoreBattlerByte(pos: c, dest: de, src: hl) -> hl
;@ path: battle/setup
;@ Copies the byte at `src` to the per-position table `dest` (entry `pos`); returns src + 1.
StoreBattlerByte::
;> q = dest + pos
	ld a, c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> mem[q] = mem[src]
	ld a, [hli]
	ld [de], a
;> return src + 1
	ret


;@ def StoreBattlerWord(pos: c, dest: de, src: hl) -> hl
;@ path: battle/setup
;@ Copies the word at `src` to the per-position table of words `dest` (entry `pos`); returns src + 2.
StoreBattlerWord::
;> q = dest + 2 * pos
	ld a, c
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;> mem16[q] = mem16[src]
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;> return src + 2
	ret


;@ def LoadBattlerSkills()
;@ path: battle/setup
;@ Reloads the skill list of battle position wBattleArg0: clears it, then copies the skills again from
;@ the monster record (own monsters, and everyone in a link battle) or from the monster template of the
;@ encounter species (enemies).
LoadBattlerSkills::
;> pos = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a
;> p = addr(wBattlerSkills) + 16 * pos
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
;>@clr for i in range(8):
	ld h, a
	ld b, $08

;>     mem[p] = 0; mem[p + 1] = 0xFF; p += 2
.clear:
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
;=@clr
	dec b
	jr nz, .clear

;> if wLinkActive or pos < 4:
	ld a, [wLinkActive]
	or a
	jr nz, .record

	ld a, c
	cp $04
	jr nc, .template

;>     src = PartyMonsterField(pos, wMonSkills)
.record:
	ld a, c
	ld hl, wMonSkills
	call PartyMonsterField
;>     return CopyBattlerSkills(wBattleArg0, src)
	ld a, [wBattleArg0]
	ld c, a
	jr CopyBattlerSkills

;> p = addr(wEncSpecies) + 2 * (pos & 3)
.template:
	ld a, c
	and $03
	ld hl, wEncSpecies
	add a
	add l
	ld l, a
;>@id wNewMonId = mem16[p]
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> return CopyBattlerSkills(wBattleArg0, addr(wTemplateSkills))     # runs on into it
	ld a, [wBattleArg0]
	ld c, a
	ld hl, wTemplateSkills

;@ def CopyBattlerSkills(pos: c, src: hl)
;@ path: battle/setup
;@ Copies the skill list at `src` ($FF ends it) into the skill numbers of battle position `pos` (up to 8;
;@ 4 for an enemy outside link battles), then looks up each skill's kind (high nibble of word 1 of its
;@ skill table record, GetSkillWord) and finally applies SubstituteSkills.
CopyBattlerSkills::
;> if not wLinkActive and pos >= 4:
	ld a, [wLinkActive]
	or a
	jr nz, .eight

	ld a, c
	cp $04
	jr c, .eight

;>     n = 4
	ld b, $04
	jr .copy

;> else:
;>     n = 8
.eight:
	ld b, $08

;> q = addr(wBattlerSkills) + 1 + 16 * pos
.copy:
	ld de, $dc65
	ld a, c
	swap a
	add e
	ld e, a
;> while True:
	ld a, $00
	adc d
	ld d, a

;>     mem[q] = mem[src]; src += 1; q += 2
.copyLoop:
	ld a, [hli]
	ld [de], a
	inc de
	inc de
;>     if mem[src] == 0xFF: break
	ld a, [hl]
	cp $ff
	jr z, .kinds

;>     n -= 1
;>     if n == 0: break
	dec b
	jr nz, .copyLoop

;> q = addr(wBattlerSkills) + 1 + 16 * pos
.kinds:
	ld a, c
	ld de, $dc65
	swap a
	add e
	ld e, a
	ld a, $00
;> saved = wBattleArg0
	adc d
	ld d, a
	ld b, $08
	ld a, [wBattleArg0]
	push af

;>@k for i in range(8):
;>     if mem[q] == 0xFF: break
.kindLoop:
	ld a, [de]
	cp $ff
	jr z, .done

;>     wBattleArg0 = mem[q]; wBattleArg1 = 0
	push bc
	ld a, [de]
	ld [wBattleArg0], a
	xor a
	ld [wBattleArg1], a
;>     wBattleArg2 = 1; GetSkillWord()      # word 1 of the skill's record
	ld a, $01
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
;>     mem[q - 1] = wBattleArg0 >> 4; q += 2
	ld a, [wBattleArg0]
	swap a
	and $0f
	dec de
	ld [de], a
	inc de
;=@k
	inc de
	inc de
	pop bc
	dec b
	jr nz, .kindLoop

;> wBattleArg0 = saved
.done:
	pop af
	ld [wBattleArg0], a
;> SubstituteSkills()
	call SubstituteSkills
;> return
	ret


;@ def LoadBattlerAilments(pos: c, status: hl)
;@ path: battle/setup
;@ Reads the record's status byte at `status`: bit 7 (dead) puts battle position `pos` down. Outside
;@ tournament and link battles the ailments carry over: bit 0 sets status flag $20, bit 2 flag $01.
LoadBattlerAilments::
;> q = addr(wBattlerState) + pos
	push hl
	ld a, c
	ld de, wBattlerState
	add e
	ld e, a
	ld a, $00
;> if mem[status] & 0x80:
	adc d
	ld d, a
	bit 7, [hl]
	jr z, .alive

;>     mem[q] = 1                    # down
	ld a, $01
	ld [de], a
	jr .done

;> else:
;>     mem[q] = 0
.alive:
	ld a, $00
	ld [de], a
;>     if wBattleType != 2:
	ld a, [wBattleType]
	cp $02
	jr z, .done

;>         s = addr(wBattlerStatus) + 8 * pos
	ld a, c
	ld de, wBattlerStatus
	add a
	add a
	add a
	add e
;>         if mem[status] & 1:
	ld e, a
	ld a, $00
	adc d
	ld d, a
	bit 0, [hl]
	jr z, .bit2

;>             mem[s] = 0x20
	ld a, $20
	ld [de], a

;>         if mem[status] & 4:
.bit2:
	bit 2, [hl]
	jr z, .done

;>             mem[s] |= 0x01
	ld a, [de]
	or $01
	ld [de], a

;> return
.done:
	pop hl
	ret


;@ def SetIntClass(pos: c)
;@ path: battle/setup
;@ Sorts the intelligence of battle position `pos` into wBattlerIntClass: 0 below 20, 1 below 179,
;@ 2 from 179 up.
;@ test: pos = rand(0, 7)
SetIntClass::
;> q = addr(wBattlerIntClass) + pos
	push bc
	ld a, c
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
;> p = addr(wBattlerIntelligence) + 2 * pos
	adc h
	ld h, a
	push hl
	ld a, c
	ld hl, wBattlerIntelligence
	add a
;> intel = mem16[p]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
;> if intel < 20:
	ld h, [hl]
	ld l, a
	ld bc, $0014
	call CompareHLBC
	jr c, .low

;>@lo     mem[q] = 0
;> elif intel < 179:
	ld bc, $00b3
	call CompareHLBC
	jr c, .mid

;>@md     mem[q] = 1
;> else:
;>     mem[q] = 2
	ld a, $02
	jr .store

;=@lo
.low:
	ld a, $00
	jr .store

;=@md
.mid:
	ld a, $01

.store:
	pop hl
	ld [hl], a
;> return
	pop bc
	ret

; unused bytes (push bc / jr into LoadEnemyFromTemplate)
	db $c5, $18, $12

;@ def LoadEnemyFromTemplate(i: c)
;@ path: battle/setup
;@ Copies the monster template just loaded (wTemplate...) into enemy position i + 4: template byte 3,
;@ level, HP (randomized in wild battles), MP, the four stats and the intelligence class, wildness 255,
;@ the reward, the species, the personality bytes and the four skills.
LoadEnemyFromTemplate::
;>@t3 wEnemyTemplate3[i] = wTemplateByte3
	push bc
	ld hl, wEnemyTemplate3
	ld a, c
	add l
	ld l, a
	ld a, $00
;=@t3
	adc h
	ld h, a
	ld a, [wTemplateByte3]
	ld [hl], a
;> pos = i + 4
	ld a, c
	add $04
	ld c, a
	add a
	ld b, a
;>@lv wBattlerLevel[pos] = wTemplateLevel
	ld hl, wBattlerLevel
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;=@lv
	ld h, a
	ld a, [wTemplateLevel]
	ld [hl], a
;> p = addr(wBattlerHP) + 2 * pos
	ld hl, wBattlerHP
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateHP
	ld h, a
	ld a, [wTemplateHP]
	ld [hli], a
	ld a, [$da1e]
	ld [hld], a
;> RandomizeEnemyHP(p)
	ld a, b
	call RandomizeEnemyHP
;> p = addr(wBattlerMaxHP) + 2 * pos
	ld hl, wBattlerMaxHP
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateHP
	ld h, a
	ld a, [wTemplateHP]
	ld [hli], a
	ld a, [$da1e]
	ld [hl], a
;> p = addr(wBattlerMP) + 2 * pos
	ld hl, wBattlerMP
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateMP
	ld h, a
	ld a, [wTemplateMP]
	ld [hli], a
	ld a, [$da20]
	ld [hl], a
;> p = addr(wBattlerMaxMP) + 2 * pos
	ld hl, wBattlerMaxMP
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateMP
	ld h, a
	ld a, [wTemplateMP]
	ld [hli], a
	ld a, [$da20]
	ld [hl], a
;> p = addr(wBattlerAttack) + 2 * pos
	ld hl, wBattlerAttack
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateAttack
	ld h, a
	ld a, [wTemplateAttack]
	ld [hli], a
	ld a, [$da22]
	ld [hl], a
;> p = addr(wBattlerDefense) + 2 * pos
	ld hl, wBattlerDefense
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateDefense
	ld h, a
	ld a, [wTemplateDefense]
	ld [hli], a
	ld a, [$da24]
	ld [hl], a
;> p = addr(wBattlerAgility) + 2 * pos
	ld hl, wBattlerAgility
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateAgility
	ld h, a
	ld a, [wTemplateAgility]
	ld [hli], a
	ld a, [$da26]
	ld [hl], a
;> p = addr(wBattlerIntelligence) + 2 * pos
	ld hl, wBattlerIntelligence
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = wTemplateIntelligence
	ld h, a
	ld a, [wTemplateIntelligence]
	ld [hli], a
	ld a, [$da28]
	ld [hld], a
;> intel = wTemplateIntelligence & 0xFF        # only the low byte is compared
	ld a, [hl]
	push af
;> q = addr(wBattlerIntClass) + pos
	ld hl, wBattlerIntClass
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;> if intel < 0x15:
	ld h, a
	pop af
	cp $15
	jr c, .low

;>@lo     mem[q] = 0
;> elif intel < 0xB5:
	cp $b5
	jr c, .mid

;>@md     mem[q] = 1
;> else:
;>     mem[q] = 2
	ld a, $02
	jr .store

;=@lo
.low:
	ld a, $00
	jr .store

;=@md
.mid:
	ld a, $01

.store:
	ld [hl], a
;> p = addr(wBattlerWildness) + 2 * pos
	ld hl, wBattlerWildness
	ld a, b
	add l
	ld l, a
	ld a, $00
	adc h
;> mem16[p] = 0x00FF
	ld h, a
	ld [hl], $ff
	inc hl
	ld [hl], $00
;>@rw p = addr(wEnemyReward) + 3 * i
	ld hl, wEnemyReward
	push bc
	ld a, c
	sub $04
	ld c, a
	add a
;=@rw
	add c
	pop bc
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = wTemplateReward & 0xFF; mem[p + 1] = wTemplateReward >> 8
	ld h, a
	ld a, [wTemplateReward]
	ld [hli], a
	ld a, [$da1a]
	ld [hli], a
;> mem[p + 2] = 0
	ld [hl], $00
;>@sp wBattlerSpecies[pos] = wNewMonNameText
	ld hl, wBattlerSpecies
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld a, [wNewMonNameText]
	ld [hl], a
;>@p1 wBattlerPersonality1[pos] = wTemplatePersonality1
	ld hl, wBattlerPersonality1
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;=@p1
	ld h, a
	ld a, [wTemplatePersonality1]
	ld [hl], a
;>@s67 wBattlerStat67[pos] = wTemplateStat67
	ld hl, wBattlerStat67
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;=@s67
	ld h, a
	ld a, [wTemplateStat67]
	ld [hl], a
;>@p2 wBattlerPersonality2[pos] = wTemplatePersonality2
	ld hl, wBattlerPersonality2
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;=@p2
	ld h, a
	ld a, [wTemplatePersonality2]
	ld [hl], a
;>@p3 wBattlerPersonality3[pos] = wTemplatePersonality3
	ld hl, wBattlerPersonality3
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
;=@p3
	ld h, a
	ld a, [wTemplatePersonality3]
	ld [hl], a
;> q = addr(wBattlerSkills) + 1 + 16 * pos
	ld hl, $dc65
	ld a, b
	add a
	add a
	add a
	add l
;>@sk for k in range(4):
	ld l, a
	ld a, $00
	adc h
	ld h, a

;>     mem[q + 2 * k] = wTemplateSkills[k]
	ld a, [wTemplateSkills]
	ld [hli], a
	inc hl
;=@sk
	ld a, [$da2e]
	ld [hli], a
	inc hl
;=@sk
	ld a, [$da2f]
	ld [hli], a
	inc hl
;=@sk
	ld a, [$da30]
	ld [hl], a
;> return
	pop bc
	ret

; unused bytes (push bc / jr into RollEnemySex)
	db $c5, $18, $04

;@ def RollEnemySex(i: c)
;@ path: battle/setup
;@ Rolls the sex of enemy position i + 4 from the MonsterStats sex chance just looked up (0 always 0,
;@ 1 one time in ten 1, 2 half and half, otherwise nine times in ten 1), then packs the species'
;@ resistances for it.
;@ test: skip calls Random
RollEnemySex::
;> pos = i + 4
	push bc
	ld a, c
	add $04
	ld c, a
;> q = addr(wBattlerSex) + pos
	ld hl, wBattlerSex
	add l
	ld l, a
	ld a, $00
	adc h
;> sex = 0
	ld h, a
;> if wMonSexChance != 0:
	ld a, [wMonSexChance]
	or a
	jr z, .store

;>@o     if wMonSexChance == 1: limit = 0x19
	cp $01
	jr z, .one

;>@t     elif wMonSexChance == 2: limit = 0x80
	cp $02
	jr z, .two

;>     else: limit = 0xE6
	ld b, $e6
	jr .roll

;=@o
.one:
	ld b, $19
	jr .roll

;=@t
.two:
	ld b, $80

;>@r     Random()
.roll:
	push af
	push bc
	push de
	push hl
	call Random
	pop hl
;=@r
	pop de
	pop bc
	pop af
;>     sex = 1 if wRandomHigh < limit else 0
	ld a, [wRandomHigh]
	cp b
	jr c, .female

	xor a
	jr .store

.female:
	ld a, $01

;> mem[q] = sex
.store:
	ld [hl], a
;>@q q = addr(wBattlerResist) + 7 * pos
	ld hl, wMonResistances
	ld de, wBattlerResist
	ld a, c
	add a
	add c
	add a
;=@q
	add c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> PackResistances(addr(wMonResistances), q)
	call PackResistances
;> return
	pop bc
	ret


;@ def SubstituteSkills()
;@ path: battle/setup
;@ Swaps skills for their battle variants: in the first skill $70 of every monster of sex 0 becomes $DD;
;@ outside link battles enemy skills $97, $19 and $2A become $DB, $DA and $DC.
SubstituteSkills::
;>@pos for pos in range(8):
	ld bc, $0800
	ld hl, wBattlerSex

;>     if not CheckBattlerPresent(pos) and wBattlerSex[pos] == 0:
.sexLoop:
	ld a, c
	call CheckBattlerPresent
	jr c, .nextSex

	ld a, [hl]
	or a
	jr nz, .nextSex

;>         SubstituteSexSkill(pos)
	push hl
	call SubstituteSexSkill
	pop hl

;=@pos
.nextSex:
	inc c
	inc hl
	dec b
	jr nz, .sexLoop

;> if wLinkActive: return
	ld a, [wLinkActive]
	or a
	ret nz

;>@en for pos in range(4, 7):
	ld bc, $0304
;>     p = addr(wBattlerSkills) + 1 + 16 * pos
	ld hl, $dca5

;>     if not CheckBattlerPresent(pos):
.enemyLoop:
	ld a, c
	call CheckBattlerPresent
	jr c, .nextEnemy

;>@k         for k in range(4):
	ld d, $04

;>             if mem[p] == 0xFF: break
.skillLoop:
	ld a, [hl]
	cp $ff
	jr z, .nextEnemy

;>             if mem[p] == 0x97: SetSkillDB(p)
	cp $97
	jr nz, .not97

	call SetSkillDB
	jr .nextSkill

;>             elif mem[p] == 0x19: SetSkillDA(p)
.not97:
	cp $19
	jr nz, .not19

	call SetSkillDA
	jr .nextSkill

;>             elif mem[p] == 0x2A: SetSkillDC(p)
.not19:
	cp $2a
	jr nz, .nextSkill

	call SetSkillDC

;>             p += 2
.nextSkill:
	inc hl
	inc hl
;=@k
	dec d
	jr nz, .skillLoop

;>     p = addr(wBattlerSkills) + 1 + 16 * (pos + 1)
.nextEnemy:
	inc c
	ld a, c
	swap a
	ld hl, $dc65
	add l
	ld l, a
;=@en
	ld a, $00
	adc h
	ld h, a
	dec b
	jr nz, .enemyLoop

;> return
	ret


;@ def SubstituteSexSkill(pos: c)
;@ path: battle/setup
;@ Replaces the first skill $70 in the skill list of battle position `pos` with $DD.
SubstituteSexSkill::
;> p = addr(wBattlerSkills) + 1 + 16 * pos
	ld a, c
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
;>@k for k in range(8):
	adc h
	ld h, a
	ld d, $08

;>     if mem[p] == 0xFF: return
.loop:
	ld a, [hl]
	cp $ff
	ret z

;>     if mem[p] == 0x70:
	cp $70
	jr nz, .next

;>         mem[p] = 0xDD
	ld [hl], $dd
;>         return
	ret

;>     p += 2
.next:
	inc hl
	inc hl
;=@k
	dec d
	jr nz, .loop

;> return
	ret


;@ def SetSkillDB(p: hl)
;@ path: battle/setup
;@ Turns the skill at `p` into skill $DB.
SetSkillDB::
;> mem[p] = 0xDB
	ld [hl], $db
;> return
	ret


;@ def SetSkillDA(p: hl)
;@ path: battle/setup
;@ Turns the skill at `p` into skill $DA.
SetSkillDA::
;> mem[p] = 0xDA
	ld [hl], $da
;> return
	ret


;@ def SetSkillDC(p: hl)
;@ path: battle/setup
;@ Turns the skill at `p` into skill $DC.
SetSkillDC::
;> mem[p] = 0xDC
	ld [hl], $dc
;> return
	ret


;@ def SetSkillKinds()
;@ path: battle/setup
;@ For all 64 skill slots of the 8 battle positions: stores the skill's kind (high nibble of word 1
;@ of its skill table record, read with GetSkillWord) in front of the skill number, 0 for an empty slot.
SetSkillKinds::
;> p = addr(wBattlerSkills) + 1
	ld hl, $dc65
;>@n for n in range(64):
	ld bc, $0808

;>     if mem[p] != 0xFF:
.loop:
	push bc
	ld a, [hl]
	cp $ff
	push hl
	jr z, .empty

;>         wBattleArg0 = mem[p]; wBattleArg1 = 0
	ld a, [hl]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
;>         wBattleArg2 = 1; GetSkillWord()
	ld a, $01
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
;>         kind = wBattleArg0 >> 4
	ld a, [wBattleArg0]
	swap a
	and $0f
	jr .store

;>     else:
;>         kind = 0
.empty:
	ld a, $00

;>     mem[p - 1] = kind; p += 2
.store:
	pop hl
	dec hl
	ld [hli], a
	inc hl
	inc hl
;=@n
	pop bc
	dec c
	jr nz, .loop

;=@n
	ld c, $08
	dec b
	jr nz, .loop

;> return
	ret


;@ def RandomizeEnemyHP(p: hl)
;@ path: battle/setup
;@ In a wild battle, sets the HP word at `p` to a random value from 13/16 of it up to just below the
;@ full amount, using the random generator's current state.
;@ test: p = 0xC100; mem[0xC100] = rand(16, 255); mem[0xC101] = rand(0, 3)
RandomizeEnemyHP::
;> if wBattleType != 0: return
	ld a, [wBattleType]
	or a
	ret nz

;> hp = mem16[p]
	push bc
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> base = ThirteenSixteenths(hp)
	ld b, h
	ld c, l
	call ThirteenSixteenths
;> span = hp - base
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;> r = wRandomHigh | wRandomLow << 8
	push hl
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a

;>@w while r >= span:
.mod:
	call CompareHLBC
	jr c, .done

;>     r -= span
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;=@w
	jr .mod

;>@st mem16[p] = (base + r) & 0xFFFF
.done:
	pop bc
	add hl, bc
	pop bc
	ld a, l
	ld [bc], a
	inc bc
;=@st
	ld a, h
	ld [bc], a
;> return
	pop bc
	ret


;@ def SaveBattleResults()
;@ path: battle/end
;@ Far entry after the battle: keeps the party's tactic setting and writes each own monster's battle
;@ state back into its record: tactic bits, ailments (bit 7 when it is out of the fight), HP and MP (no
;@ higher than the maximum), wildness and the personality bytes (the third counts the battles survived).
SaveBattleResults::
;> wSavedTeamTactic = wTeamTactic
	ld a, [wTeamTactic]
	ld [wSavedTeamTactic], a
;>@l for pos in range(wPartyBattlers):
	ld a, [wPartyBattlers]
	ld b, a
	ld c, $00

;>     SaveTacticBits(pos)
.loop:
	call SaveTacticBits
;>     rec = PartyMonsterField(pos, wMonStatus)
	ld a, c
	ld hl, wMonStatus
	call PartyMonsterField
;>     rec = SaveAilments(pos, rec)
	call SaveAilments
;>     rec = SaveHP(pos, rec)
	call SaveHP
;>     rec = SaveMP(pos, rec)
	call SaveMP
;>     rec = SaveWildness(pos, rec)
	call SaveWildness
;>     SavePersonality(pos, rec)
	call SavePersonality
;=@l
	inc c
	dec b
	jr nz, .loop

;> return
	ret


;@ def SaveTacticBits(pos: c)
;@ path: battle/end
;@ Writes the tactic (bits 4-5) and wBattlerSexBits67 (bits 6-7) of battle position `pos` back into
;@ the record's sex byte, keeping the sex in bits 0-3.
SaveTacticBits::
;> rec = PartyMonsterField(pos, wMonGender)
	ld a, c
	ld hl, wMonGender
	call PartyMonsterField
;> q = addr(wBattlerTactic) + pos
	ld a, c
	ld de, wBattlerTactic
	add e
	ld e, a
	ld a, $00
	adc d
;> bits = mem[q] & 3
	ld d, a
	ld a, [de]
	push hl
	and $03
	ld l, a
;> q = addr(wBattlerSexBits67) + pos
	ld a, c
	ld de, wBattlerSexBits67
	add e
	ld e, a
	ld a, $00
	adc d
;> bits |= (mem[q] << 2) & 0x0C
	ld d, a
	ld a, [de]
	rlca
	rlca
	and $0c
	or l
;> v = (mem[rec] & 0x0F) | bits << 4
	pop hl
	swap a
	ld d, a
	ld a, [hl]
	and $0f
	or d
;> mem[rec] = v
	ld [hl], a
;> return
	ret


;@ def SaveAilments(pos: c, status: hl) -> hl
;@ path: battle/end
;@ Rebuilds the record's status byte at `status` from battle position `pos`: bit 2 from status bits
;@ 0-1, bit 0 from status bit 5, bit 7 when the monster is out of the fight. A monster still standing
;@ (outside a reload) gets its third personality byte raised by one (up to $FF). Returns status + 6
;@ (the HP field).
SaveAilments::
;> mem[status] = 0
	ld a, $00
	ld [hl], a
;> s = 8 * pos
	ld a, c
	ld de, wBattlerStatus
	add a
	add a
	add a
;> s += addr(wBattlerStatus)
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;> if mem[s] & 3:
	ld a, [de]
	and $03
	jr z, .bit5

;>     mem[status] |= 4
	set 2, [hl]

;> if mem[s] & 0x20:
.bit5:
	ld a, [de]
	bit 5, a
	jr z, .present

;>     mem[status] |= 1
	set 0, [hl]

;> if CheckBattlerPresent(pos):          # carry: out of the fight
.present:
	ld a, c
	call CheckBattlerPresent
	jr nc, .standing

;>     mem[status] |= 0x80
	set 7, [hl]
	jr .done

;> elif not wBattlerReload:
.standing:
	ld a, [wBattlerReload]
	or a
	jr nz, .done

;>     q = addr(wBattlerPersonality3) + pos
	ld a, c
	ld de, wBattlerPersonality3
	add e
	ld e, a
	ld a, $00
	adc d
;>     if mem[q] != 0xFF:
	ld d, a
	ld a, [de]
	cp $ff
	jr z, .done

;>         mem[q] += 1
	inc a
	ld [de], a

;>@r return status + 6
.done:
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
;=@r
	ret


;@ def SaveHP(pos: c, hp: hl) -> hl
;@ path: battle/end
;@ Writes the HP of battle position `pos` into the record's HP field at `hp` (no higher than the
;@ maximum that follows it); returns the address of the MP field.
SaveHP::
;> q = addr(wBattlerHP) + 2 * pos
	push bc
	ld a, c
	ld de, wBattlerHP
	add a
	add e
	ld e, a
;>@w v = mem16[q]; mem16[hp] = v
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld c, a
;=@w
	inc de
	ld a, [de]
	ld [hli], a
	ld b, a
;> ClampToMax(hp + 2, v)
	call ClampToMax
;> return hp + 4
	inc hl
	inc hl
	pop bc
	ret


;@ def SaveMP(pos: c, mp: hl) -> hl
;@ path: battle/end
;@ Writes the MP of battle position `pos` into the record's MP field at `mp` (no higher than the
;@ maximum that follows it); returns the address of the wildness field.
SaveMP::
;> q = addr(wBattlerMP) + 2 * pos
	push bc
	ld a, c
	ld de, wBattlerMP
	add a
	add e
	ld e, a
;>@w v = mem16[q]; mem16[mp] = v
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	ld c, a
;=@w
	inc de
	ld a, [de]
	ld [hli], a
	ld b, a
;> ClampToMax(mp + 2, v)
	call ClampToMax
;>@r return mp + 12
	ld a, $0a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	pop bc
	ret


;@ def ClampToMax(max: hl, value: bc)
;@ path: battle/end
;@ If the maximum word at `max` is below `value`, writes the maximum into the word just before it.
ClampToMax::
;> m = mem16[max]
	push hl
	ld d, h
	ld e, l
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> if m < value:
	call CompareHLBC
	jr nc, .done

;>     mem16[max - 2] = m
	dec de
	ld a, h
	ld [de], a
	dec de
	ld a, l
	ld [de], a

;> return
.done:
	pop hl
	ret


;@ def SaveWildness(pos: c, wild: hl) -> hl
;@ path: battle/end
;@ Writes the wildness of battle position `pos` into the record field at `wild`; returns the address of
;@ the personality bytes.
SaveWildness::
;> q = addr(wBattlerWildness) + 2 * pos
	ld a, c
	ld de, wBattlerWildness
	add a
	add e
	ld e, a
	ld a, $00
;>@w mem16[wild] = mem16[q]
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
;=@w
	ld [hli], a
;> return wild + 4
	inc hl
	inc hl
	ret


;@ def SavePersonality(pos: c, p: hl)
;@ path: battle/end
;@ For a monster still in the fight (and not marked by status byte 1 bit 4), writes its personality
;@ bytes and record byte +$67 back to the record at `p`.
SavePersonality::
;> q = addr(wBattlerState) + pos
	ld a, c
	ld de, wBattlerState
	add e
	ld e, a
	ld a, $00
	adc d
;> if mem[q] == 0:
	ld d, a
	ld a, [de]
	or a
	jr nz, .done

;>     off = 8 * pos
	push hl
	ld a, c
	ld hl, wBattlerStatus1
	add a
	add a
	add a
;>     s = addr(wBattlerStatus1) + off
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>     if not mem[s] & 0x10:
	bit 4, [hl]
	pop hl
	jr nz, .done

;>         q = addr(wBattlerPersonality1) + pos
	ld a, c
	ld de, wBattlerPersonality1
	add e
	ld e, a
	ld a, $00
	adc d
;>         mem[p] = mem[q]; p += 1
	ld d, a
	ld a, [de]
	ld [hli], a
;>         q = addr(wBattlerPersonality2) + pos
	ld a, c
	ld de, wBattlerPersonality2
	add e
	ld e, a
	ld a, $00
	adc d
;>         mem[p] = mem[q]; p += 1
	ld d, a
	ld a, [de]
	ld [hli], a
;>         q = addr(wBattlerPersonality3) + pos
	ld a, c
	ld de, wBattlerPersonality3
	add e
	ld e, a
	ld a, $00
	adc d
;>         mem[p] = mem[q]; p += 1
	ld d, a
	ld a, [de]
	ld [hli], a
;>         q = addr(wBattlerStat67) + pos
	ld a, c
	ld de, wBattlerStat67
	add e
	ld e, a
	ld a, $00
	adc d
;>         mem[p] = mem[q]
	ld d, a
	ld a, [de]
	ld [hl], a

;> return
.done:
	ret


;@ def DefeatBattler()
;@ path: battle/state
;@ Far entry: battle position wBattleArg0 goes down. A monster first gets its record stats back
;@ (ReloadBattler, ending a transformation); a called monster (slot 3 of a side) leaves the fight
;@ instead and its side's dragon flag is cleared. Then SetBattlerDown.
DefeatBattler::
;> wBattleStepArg1 = 1
	ld a, $01
	ld [wBattleStepArg1], a
;> wBattleTemp = wBattleArg0
	ld a, [wBattleArg0]
	ld [wBattleTemp], a
;> if wBattleArg0 & 3 != 3:
	and $03
	cp $03
	jr z, .called

;>     ReloadBattler()
	call ReloadBattler
;>     SetBattlerDown()
	call SetBattlerDown
;>     return
	ret

;> q = addr(wBattlerState) + wBattleArg0
.called:
	ld a, [wBattleArg0]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[q] = 0xFF                      # the called monster is gone
	ld h, a
	ld [hl], $ff
;> side = wBattleArg0 >> 2 & 1
	ld a, [wBattleArg0]
	and $04
	rrca
	rrca
	and $01
;>@sf wSideFlags[side] &= ~4
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@sf
	res 2, [hl]
;> SetBattlerDown()
	call SetBattlerDown
;> return
	ret


;@ def SetBattlerDown()
;@ path: battle/state
;@ Puts battle position wBattleTemp down: HP 0, MP no higher than its maximum, all status flags cleared
;@ (a changed palette is put back), state 1 unless it already was out. Outside link battles a fallen
;@ enemy (not a called one) also loses its transformation mark in wEnemyMorph.
SetBattlerDown::
;> p = addr(wBattlerHP) + 2 * wBattleTemp
	ld a, [wBattleTemp]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 0
	adc h
	ld h, a
	xor a
	ld [hli], a
	ld [hl], a
;> p += 0x20                          # its MP
	ld a, $1f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mp = mem16[p]
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> pmax = p + 0x10                    # its maximum MP
	ld a, $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> if mem16[pmax] < mp:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	pop bc
	jr nc, .status

;>     mem16[p] = mem16[pmax]
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a

;> s = 8 * wBattleTemp
.status:
	ld a, [wBattleTemp]
	ld hl, wBattlerStatus
	add a
	add a
	add a
;> s += addr(wBattlerStatus)
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[s] = 0
	xor a
	ld [hli], a
;> RestorePalettesIfChanged(s + 1)
	call RestorePalettesIfChanged
;>@f fill(s + 1, 7, 0)
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@f
	ld [hl], a
;> q = addr(wBattlerState) + wBattleTemp
	ld a, [wBattleTemp]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;> if mem[q] != 0: return
	ld h, a
	ld a, [hl]
	or a
	ret nz

;> mem[q] = 1
	ld [hl], $01
;> if wLinkActive: return
	ld a, [wLinkActive]
	or a
	ret nz

;> if wBattleArg0 < 4: return
	ld a, [wBattleArg0]
	cp $04
	ret c

;> if wBattleArg0 & 3 == 3: return
	and $03
	cp $03
	ret z

;>@em wEnemyMorph[wBattleArg0 & 3] = 0xFF
	ld hl, wEnemyMorph
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@em
	ld [hl], $ff
;> return
	ret


;@ def RestorePalettesIfChanged(s1: hl)
;@ path: battle/state
;@ If status byte 1 at `s1` has bit 4 or 5 set (a changed look), reloads the picture palettes of the
;@ battle and sends them to the CGB. Returns with a = 0 in that case.
RestorePalettesIfChanged::
;> if not mem[s1] & 0x10 and not mem[s1] & 0x20: return
	bit 4, [hl]
	jr nz, .restore

	bit 5, [hl]
	ret z

;> SetBattlePicPalettes()
.restore:
	push hl
	ld hl, far_SetBattlePicPalettes
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> return
	pop hl
	xor a
	ret


;@ def AppendEnemyLetter()
;@ path: battle/names
;@ Far entry: when several enemies share the species of position wNameBattler, adds a letter to its
;@ name at wNameDest (before the $F0 end): the first of them gets code $0B, the next $0C and so on.
;@ An enemy whose species appears only once gets no letter.
AppendEnemyLetter::
;> n = wEncCount + 1; pos = 4; before = 0
	ld a, [wEncCount]
	ld b, a
	inc b
	ld c, $04
	ld d, $00
;> p = addr(wBattlerSpecies) + wNameBattler
	ld a, [wNameBattler]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;> species = mem[p]
	ld h, a
	ld e, [hl]

;> while True:
;>     q = addr(wBattlerSpecies) + pos
.count:
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;>     if mem[q] == species:
	ld h, a
	ld a, [hl]
	cp e
	jr nz, .next

;>         if pos == wNameBattler: break
	ld a, [wNameBattler]
	cp c
	jp z, .found

;>         before += 1
	inc d

;>     pos += 1; n -= 1
.next:
	inc c
	dec b
;>     if n == 0: return
	jr nz, .count

	ret

;> if before == 0:                   # the first of its kind: only lettered when another one follows
.found:
	ld a, d
	or a
	jr nz, .append

;>     pos += 1
	inc c

;>     while True:
;>         q = addr(wBattlerSpecies) + pos
.search:
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;>         if mem[q] == species: break
	ld h, a
	ld a, [hl]
	cp e
	jr z, .append

;>         pos += 1; n -= 1
	inc c
	dec b
;>         if n == 0: return
	jr nz, .search

	ret

;> p = wNameDest
.append:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
;> letter = before + 0x0B
	ld a, d
	add $0b
	push af

;> while mem[p] != 0xF0: p += 1
.find:
	ld a, [hl]
	cp $f0
	jr z, .end

	inc hl
	jr .find

;> mem[p] = letter; mem[p + 1] = 0xF0
.end:
	pop af
	ld [hli], a
	ld a, $f0
	ld [hl], a
;> return
	ret


;@ def SetUpCalledMonster1()
;@ path: battle/skills
;@ Fills slot 3 of the user's side (wSkillUser) with the first monster a calling skill brings in: level 30, HP 200, MP 100, attack 180, defense 150, agility 80, intelligence 150, three fixed skills and fixed resistances.
SetUpCalledMonster1::
;> pos = wSkillUser & 4 | 3              # slot 3 of the user's side
	ld b, $00
	ld a, [wSkillUser]
	and $04
	or $03
	ld [wBattleArg0], a
;> p = addr(wBattlerTypeBits) + pos
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerSex
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerLevel
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 30
	ld a, $1e
	ld [hl], a
;> p = addr(wBattlerHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerMaxHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 100
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerMaxMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 100
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerAttack) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 180
	adc h
	ld h, a
	ld a, $b4
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerDefense) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 150
	adc h
	ld h, a
	ld a, $96
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerAgility) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 80
	adc h
	ld h, a
	ld a, $50
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntelligence) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntelligence
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 150
	adc h
	ld h, a
	ld a, $96
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntClass) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 1
	ld h, a
	ld [hl], $01
;> p = addr(wBattlerWildness) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerWildness
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 255
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerPersonality1) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 250
	ld h, a
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerStat67
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality2
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality3
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p = addr(wBattlerSkills) + 16 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;>@sk1 for i, v in enumerate((0x03, 0x2C, 0x01, 0x5A, 0x03, 0x88)): mem[p + i] = v
	adc h
	ld h, a
	ld a, $03
	ld [hli], a
;=@sk1
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $5a
	ld [hli], a
;=@sk1
	ld a, $03
	ld [hli], a
	ld a, $88
	ld [hli], a
;> off = 7 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerResist
	ld c, a
	add a
	add c
	add a
;> p = addr(wBattlerResist) + off
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@rs2 for i, v in enumerate((0x16, 0xB5, 0x55, 0x54, 0x15, 0x55, 0x54)): mem[p + i] = v
	ld a, $16
	ld [hli], a
;=@rs2
	ld a, $b5
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $54
	ld [hli], a
;=@rs2
	ld a, $15
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $54
	ld [hli], a
;> return
	ret


;@ def SetUpCalledMonster2()
;@ path: battle/skills
;@ Fills slot 3 of the user's side with the second called monster: level 40, HP 300, MP 200, attack 210, defense 160, agility 120, intelligence 100, three fixed skills and fixed resistances.
SetUpCalledMonster2::
;> pos = wSkillUser & 4 | 3              # slot 3 of the user's side
	ld b, $00
	ld a, [wSkillUser]
	and $04
	or $03
	ld [wBattleArg0], a
;> p = addr(wBattlerTypeBits) + pos
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerSex
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerLevel
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 40
	ld a, $28
	ld [hl], a
;> p = addr(wBattlerHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 300
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerMaxHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 300
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerMaxMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerAttack) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 210
	adc h
	ld h, a
	ld a, $d2
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerDefense) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 160
	adc h
	ld h, a
	ld a, $a0
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerAgility) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 120
	adc h
	ld h, a
	ld a, $78
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntelligence) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntelligence
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 100
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntClass) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 1
	ld h, a
	ld [hl], $01
;> p = addr(wBattlerWildness) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerWildness
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 255
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerPersonality1) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 250
	ld h, a
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerStat67
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality2
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality3
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p = addr(wBattlerSkills) + 16 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;>@sk1 for i, v in enumerate((0x02, 0x25, 0x01, 0x5E, 0x02, 0x7A)): mem[p + i] = v
	adc h
	ld h, a
	ld a, $02
	ld [hli], a
;=@sk1
	ld a, $25
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $5e
	ld [hli], a
;=@sk1
	ld a, $02
	ld [hli], a
	ld a, $7a
	ld [hli], a
;> off = 7 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerResist
	ld c, a
	add a
	add c
	add a
;> p = addr(wBattlerResist) + off
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@rs2 for i, v in enumerate((0x3A, 0x05, 0x64, 0x54, 0x31, 0x55, 0x84)): mem[p + i] = v
	ld a, $3a
	ld [hli], a
;=@rs2
	ld a, $05
	ld [hli], a
	ld a, $64
	ld [hli], a
	ld a, $54
	ld [hli], a
;=@rs2
	ld a, $31
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $84
	ld [hli], a
;> return
	ret


;@ def SetUpCalledMonster3()
;@ path: battle/skills
;@ Fills slot 3 of the user's side with the third called monster: level 50, HP 450, MP 200, attack 250, defense 190, agility 150, intelligence 200, three fixed skills and fixed resistances.
SetUpCalledMonster3::
;> pos = wSkillUser & 4 | 3              # slot 3 of the user's side
	ld b, $00
	ld a, [wSkillUser]
	and $04
	or $03
	ld [wBattleArg0], a
;> p = addr(wBattlerTypeBits) + pos
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerSex
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerLevel
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 50
	ld a, $32
	ld [hl], a
;> p = addr(wBattlerHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 450
	adc h
	ld h, a
	ld a, $c2
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerMaxHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 450
	adc h
	ld h, a
	ld a, $c2
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerMaxMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerAttack) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 250
	adc h
	ld h, a
	ld a, $fa
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerDefense) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 190
	adc h
	ld h, a
	ld a, $be
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerAgility) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 150
	adc h
	ld h, a
	ld a, $96
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntelligence) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntelligence
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntClass) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 2
	ld h, a
	ld [hl], $02
;> p = addr(wBattlerWildness) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerWildness
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 255
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerPersonality1) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 250
	ld h, a
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerStat67
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality2
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality3
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p = addr(wBattlerSkills) + 16 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;>@sk1 for i, v in enumerate((0x01, 0x40, 0x01, 0x55, 0x01, 0x57)): mem[p + i] = v
	adc h
	ld h, a
	ld a, $01
	ld [hli], a
;=@sk1
	ld a, $40
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $55
	ld [hli], a
;=@sk1
	ld a, $01
	ld [hli], a
	ld a, $57
	ld [hli], a
;> off = 7 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerResist
	ld c, a
	add a
	add c
	add a
;> p = addr(wBattlerResist) + off
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@rs2 for i, v in enumerate((0x19, 0xC6, 0xB5, 0x44, 0x19, 0x55, 0x54)): mem[p + i] = v
	ld a, $19
	ld [hli], a
;=@rs2
	ld a, $c6
	ld [hli], a
	ld a, $b5
	ld [hli], a
	ld a, $44
	ld [hli], a
;=@rs2
	ld a, $19
	ld [hli], a
	ld a, $55
	ld [hli], a
	ld a, $54
	ld [hli], a
;> return
	ret


;@ def SetUpCalledMonster4()
;@ path: battle/skills
;@ Fills slot 3 of the user's side with the fourth called monster: level 60, HP 700 (the maximum is set to only 444), MP 400, attack 350, defense 300, agility 100, intelligence 250, three fixed skills and fixed resistances.
SetUpCalledMonster4::
;> pos = wSkillUser & 4 | 3              # slot 3 of the user's side
	ld b, $00
	ld a, [wSkillUser]
	and $04
	or $03
	ld [wBattleArg0], a
;> p = addr(wBattlerTypeBits) + pos
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerSex
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 0
	ld [hl], b
;> p += 8                                 # wBattlerLevel
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 60
	ld a, $3c
	ld [hl], a
;> p = addr(wBattlerHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 700
	adc h
	ld h, a
	ld a, $bc
	ld [hli], a
	ld a, $02
	ld [hl], a
;> p = addr(wBattlerMaxHP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 444
	adc h
	ld h, a
	ld a, $bc
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 400
	adc h
	ld h, a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerMaxMP) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerMaxMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 400
	adc h
	ld h, a
	ld a, $90
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerAttack) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 350
	adc h
	ld h, a
	ld a, $5e
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerDefense) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 300
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerAgility) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 100
	adc h
	ld h, a
	ld a, $64
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntelligence) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntelligence
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 250
	adc h
	ld h, a
	ld a, $fa
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerIntClass) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 2
	ld h, a
	ld [hl], $02
;> p = addr(wBattlerWildness) + 2 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerWildness
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 255
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], b
;> p = addr(wBattlerPersonality1) + pos
	ld a, [wBattleArg0]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 250
	ld h, a
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerStat67
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality2
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p += 8                                 # wBattlerPersonality3
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[p] = 250
	ld a, $fa
	ld [hl], a
;> p = addr(wBattlerSkills) + 16 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;>@sk1 for i, v in enumerate((0x01, 0x62, 0x01, 0x64, 0x02, 0x80)): mem[p + i] = v
	adc h
	ld h, a
	ld a, $01
	ld [hli], a
;=@sk1
	ld a, $62
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $64
	ld [hli], a
;=@sk1
	ld a, $02
	ld [hli], a
	ld a, $80
	ld [hli], a
;> off = 7 * pos
	ld a, [wBattleArg0]
	ld hl, wBattlerResist
	ld c, a
	add a
	add c
	add a
;> p = addr(wBattlerResist) + off
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@rs2 for i, v in enumerate((0x1A, 0x6F, 0xFA, 0xA9, 0x1E, 0xAA, 0xA8)): mem[p + i] = v
	ld a, $1a
	ld [hli], a
;=@rs2
	ld a, $6f
	ld [hli], a
	ld a, $fa
	ld [hli], a
	ld a, $a9
	ld [hli], a
;=@rs2
	ld a, $1e
	ld [hli], a
	ld a, $aa
	ld [hli], a
	ld a, $a8
	ld [hli], a
;> return
	ret


;@ def TransformSkillUser()
;@ path: battle/skills
;@ Turns the skill user (wSkillUser) into a stronger form: level 50, maximum HP 999, maximum MP 300, attack 300, defense, agility and intelligence 200, the palette of species $DC, three fixed skills (the other five slots empty) and fixed resistances; its remembered menu cursor is cleared.
TransformSkillUser::
;> p = addr(wBattlerLevel) + wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[p] = 50
	ld h, a
	ld a, $32
	ld [hl], a
;> p = addr(wBattlerMaxHP) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 999
	adc h
	ld h, a
	ld a, $e7
	ld [hli], a
	ld a, $03
	ld [hl], a
;> p = addr(wBattlerMaxMP) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerMaxMP
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 300
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerAttack) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 300
	adc h
	ld h, a
	ld a, $2c
	ld [hli], a
	ld a, $01
	ld [hl], a
;> p = addr(wBattlerDefense) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld a, $00
	ld [hl], a
;> p = addr(wBattlerAgility) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld a, $00
	ld [hl], a
;> p = addr(wBattlerIntelligence) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerIntelligence
	add a
	add l
	ld l, a
	ld a, $00
;> mem16[p] = 200
	adc h
	ld h, a
	ld a, $c8
	ld [hli], a
	ld a, $00
	ld [hl], a
;> SetTransformPalette()
	call SetTransformPalette
;> p = addr(wBattlerSkills) + 16 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;>@sk1 for i, v in enumerate((0x01, 0x5E, 0x01, 0x62, 0x02, 0x80, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF)): mem[p + i] = v
	adc h
	ld h, a
	ld a, $01
	ld [hli], a
;=@sk1
	ld a, $5e
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $62
	ld [hli], a
;=@sk1
	ld a, $02
	ld [hli], a
	ld a, $80
	ld [hli], a
	ld a, $00
	ld [hli], a
;=@sk1
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
;=@sk1
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
;=@sk1
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $ff
	ld [hl], a
;> off = 7 * wSkillUser
	ld a, [wSkillUser]
	ld h, a
	add a
	add h
	add a
	add h
;> p = addr(wBattlerResist) + off
	ld hl, wBattlerResist
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@rs2 for i, v in enumerate((0x2A, 0xAA, 0xA9, 0x69, 0x4F, 0xAA, 0x5A)): mem[p + i] = v
	ld a, $2a
	ld [hli], a
;=@rs2
	ld a, $aa
	ld [hli], a
	ld a, $a9
	ld [hli], a
	ld a, $69
	ld [hli], a
;=@rs2
	ld a, $4f
	ld [hli], a
	ld a, $aa
	ld [hli], a
	ld a, $5a
	ld [hl], a
;> ForgetMenuCursor(wSkillUser)
	ld a, [wSkillUser]
	call ForgetMenuCursor
;> return
	ret


;@ def SetTransformPalette()
;@ path: battle/skills
;@ On a Game Boy Color, gives the skill user the picture palette of species $DC (the species byte at
;@ $DB00 + position in WRAM bank 2).
;@ test: skip writes WRAM bank 2
SetTransformPalette::
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;> rSVBK = 2
	ld a, $02
	ldh [rSVBK], a
;> q = 0xDB00 + wSkillUser
	ld a, [wSkillUser]
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
;> mem[q] = 0xDC                      # in WRAM bank 2
	ld h, a
	ld [hl], $dc
;> rSVBK = 0
	ld a, $00
	ldh [rSVBK], a
;> return
	ret


;@ def ForgetMenuCursor(pos: a)
;@ path: battle/skills
;@ Forgets the remembered menu cursor of battle position `pos` (keeps only bit 7 of
;@ wBattlerMenuMemory).
;@ test: pos = rand(0, 7)
ForgetMenuCursor::
;> q = addr(wBattlerMenuMemory) + pos
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> mem[q] &= 0x80
	ld a, [hl]
	and $80
	ld [hl], a
;> return
	ret


;@ def ThirteenSixteenths(x: hl) -> hl
;@ path: battle/setup
;@ Returns about 13/16 of `x`: x/2 + x/4 + x/16 (each part rounded down).
;@ test: x = rand(0, 0xFFFF)
ThirteenSixteenths::
;> half = x >> 1
	push bc
	srl h
	rr l
;> quarter = half >> 1
	ld b, h
	ld c, l
	srl b
	rr c
;> r = half + quarter
	add hl, bc
;> sixteenth = quarter >> 2
	srl b
	rr c
	srl b
	rr c
;> return (r + sixteenth) & 0xFFFF
	add hl, bc
	pop bc
	ret


;@ def BattlerFallSequence()
;@ path: battle/state
;@ Far entry, run once per frame while the skill target wSkillTarget goes down: step wFallStep of
;@ FallSteps.
;@ test: skip jump table indexed by a step variable
BattlerFallSequence::
;> FallSteps[wFallStep]()
	ld a, [wFallStep]
	rst $00

;@ path: battle/state
;@ The steps of BattlerFallSequence.
FallSteps::
	dw FallStep0
	dw FallStep1
	dw FallStep2

;@ def FallStep0()
;@ path: battle/state
;@ The target is out: it gives no more orders this turn and its state becomes 1 (down); a monster
;@ gets its record stats back. A fallen monster shown at the top of the screen goes on to step 1 (its
;@ picture is blanked), the others straight to step 2. A called monster (slot 3) leaves the fight.
FallStep0::
;> wFallStep += 1
	ld hl, wFallStep
	inc [hl]
;>@o wBattlerOrder[wSkillTarget] = 0xFF
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $ff
;>@s wBattlerState[wSkillTarget] = 1
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld [hl], $01
;> wBattleArg0 = wSkillTarget; wBattleTemp = wSkillTarget
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld a, [wBattleArg0]
	ld [wBattleTemp], a
;> if wSkillTarget & 3 != 3:
	and $03
	cp $03
	jr z, .called

;>     ReloadBattler()
	call ReloadBattler
;>     if wLinkFlags & 2:
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr nz, .master

;>@m         if wSkillTarget < 3: return FallStep1()     # the partner's monsters are 0-2 there
;>     elif 4 <= wSkillTarget < 7:
	cp $04
	jr c, .skip

	cp $07
	jr z, .skip

;>         return FallStep1()
	jr FallStep1

;=@m
.master:
	cp $03
	jr c, FallStep1

;>     wFallStep += 1
.skip:
	ld hl, wFallStep
	inc [hl]
;>     return
	ret

;> wFallStep += 1
.called:
	ld hl, wFallStep
	inc [hl]
;>@cs wBattlerState[wBattleArg0] = 0xFF        # the called monster leaves
	ld a, [wBattleArg0]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@cs
	ld h, a
	ld [hl], $ff
;> side = wBattleArg0 >> 2 & 1
	ld a, [wBattleArg0]
	and $04
	rrca
	rrca
	and $01
;>@sf wSideFlags[side] &= ~4
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@sf
	res 2, [hl]
;> SetBattlerDown()
	call SetBattlerDown
;> return
	ret


;@ def FallStep1()
;@ path: battle/state
;@ Blanks the fallen monster's picture, starts battle sub-step $1A and moves on to step 2.
FallStep1::
;> BlankEnemyPicture()
	ld hl, far_BlankEnemyPicture
	rst $10
;> wBattleSubStep = 0x1A
	ld a, $1a
	ld [wBattleSubStep], a
;> wFallStep = 2
	ld a, $02
	ld [wFallStep], a
;> return
	ret


;@ def FallStep2()
;@ path: battle/state
;@ Puts the target down for good, remembers a fallen enemy as the one that may ask to join, redraws
;@ the panel and prints "<name> is defeated" (battle message $E3 for the own side, $E4 for the enemy
;@ side), then hands back to battle sub-step 3.
FallStep2::
;> wBattleArg0 = wSkillTarget; wBattleTemp = wSkillTarget
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld [wBattleTemp], a
;> SetBattlerDown()
	call SetBattlerDown
;>@j if not wLinkActive and 4 <= wSkillTarget < 7:
	ld a, [wLinkActive]
	or a
	jr nz, .print

	ld a, [wSkillTarget]
	cp $04
	jr c, .print

;=@j
	cp $07
	jr z, .print

	ld a, [wSkillTarget]
	cp $03
	jr c, .print

;=@j
	jr z, .print

	cp $07
	jr z, .print

;>     wJoinCandidate = wSkillTarget
	ld a, [wSkillTarget]
	ld [wJoinCandidate], a

;> PrintPanelHPMP()
.print:
	ld hl, far_PrintPanelHPMP
	rst $10
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerName(wSkillTarget, addr(wTextArg0))
	ld a, [wSkillTarget]
	call GetBattlerName
;> side = GetMessageSide() >> 2 & 1
	call GetMessageSide
	and $04
	srl a
	srl a
;> wTextIndex = 0xE3 + side; wTextGroup = 0
	add $e3
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep = 3; wFallStep = 0
	ld a, $03
	ld [wBattleSubStep], a
	xor a
	ld [wFallStep], a
;> wMonStats[0] = 2
	ld a, $02
	ld [wMonStats], a
;> return
	ret


;@ def GetMessageSide() -> a
;@ path: battle/state
;@ The position a fall message is worded for: the target, or on the link master the skill user.
GetMessageSide::
;> if not wLinkFlags & 2: return wSkillTarget
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

;> return wSkillUser
	ld a, [wSkillUser]
	ret


;@ def ClearMonStatsCopy()
;@ path: battle/setup
;@ Clears wMonStats (the copy of a MonsterStats record).
ClearMonStatsCopy::
;> fill(wMonStats, 0x2B, 0)
	push bc
	push hl
	ld hl, wMonStats
	ld bc, $002b
	xor a
	call FillMemory
;> return
	pop hl
	pop bc
	ret


;@ def ReloadPartyBattlers()
;@ path: battle/end
;@ After a level-up or a change of the party on the after-battle screens (not in link battles): clears
;@ the top of the tilemap buffer and all status flags, reloads the party monsters into battle positions
;@ 0-2 and redraws their name tiles. wNewMonSlot and wNewMonNameText are kept.
ReloadPartyBattlers::
;> if wLinkActive: return
	ld a, [wLinkActive]
	or a
	ret nz

;> saved = (wNewMonNameText, wNewMonSlot)
	ld a, [wNewMonNameText]
	ld b, a
	ld a, [wNewMonSlot]
	ld c, a
	push bc
;> fill(wTilemapBuffer, 0xC0, 0xE0)
	ld hl, wTilemapBuffer
	ld bc, $00c0
	ld a, $e0
	call FillMemory
;> fill(wBattlerStatus, 0x40, 0)
	ld hl, wBattlerStatus
	ld bc, $0040
	xor a
	call FillMemory
;> wPartyBattlers = wPartyCount; wPanelCount = wPartyCount
	ld a, [wPartyCount]
	ld [wPartyBattlers], a
	ld [wPanelCount], a
;>@l for pos in range(wPartyCount):
	ld b, a
	ld c, $00

;>     LoadBattlerFromRecord(pos)
.load:
	call LoadBattlerFromRecord
;=@l
	inc c
	dec b
	jr nz, .load

;> DrawSlotNameTiles(wParty[0], 0x9700)
	ld a, [wParty]
	ld hl, $9700
	call DrawSlotNameTiles
;> DrawSlotNameTiles(wParty[1], 0x9740)
	ld a, [$ca8f]
	ld hl, $9740
	call DrawSlotNameTiles
;> DrawSlotNameTiles(wParty[2], 0x9780)
	ld a, [$ca90]
	ld hl, $9780
	call DrawSlotNameTiles
;> wNewMonSlot = saved[1]
	pop bc
	ld a, c
	ld [wNewMonSlot], a
;> wNewMonNameText = saved[0]
	ld a, b
	ld [wNewMonNameText], a
;> return
	ret


;@ def DrawSlotNameTiles(slot: a, tiles: hl)
;@ path: battle/screen
;@ Draws the name of the monster in record slot `slot` into the name tiles at `tiles` ($FF: nothing).
DrawSlotNameTiles::
;> if slot == 0xFF: return
	cp $ff
	ret z

;> name = MonsterField(slot, wMonName)
	push hl
	ld hl, wMonName
	call MonsterField
;> DrawMonNameTiles(name, tiles)
	ld e, l
	ld d, h
	pop hl
	call DrawMonNameTiles
;> return
	ret


;@ def ResetStatusIcons()
;@ path: battle/screen
;@ Marks the status icons of all eight positions as not loaded ($FF), so they are drawn again.
ResetStatusIcons::
;> fill(wStatusIconShown, 8, 0xFF)
	ld a, $ff
	ld hl, wStatusIconShown
	ld bc, $0008
	call FillMemory
;> return
	ret

; unused code: works out the status icon of all eight positions into wStatusIconShown
	db $01, $00, $08, $79, $cd, $a5, $2f, $30, $04, $16, $07, $18, $39, $79, $21, $02
	db $db, $cd, $6c, $2f, $cb, $76, $20, $18, $cb, $6e, $20, $18, $cb, $66, $20, $18
	db $cb, $7e, $20, $18, $cb, $4e, $20, $18, $cb, $46, $20, $18, $16, $00, $18, $16
	db $16, $06, $18, $12, $16, $05, $18, $0e, $16, $04, $18, $0a, $16, $03, $18, $06
	db $16, $02, $18, $02, $16, $01, $79, $21, $0a, $da, $85, $6f, $3e, $00, $8c, $67
	db $72, $0c, $05, $20, $ae, $c9

;@ def LoadMonsterPicFar()
;@ path: battle/screen
;@ Far entry for LoadMonsterPic: the species in $C0DE, the destination tiles in $C0DC/$C0DD.
LoadMonsterPicFar::
;> LoadMonsterPic(mem[0xC0DE], mem16[0xC0DC])
	ld a, [$c0dc]
	ld l, a
	ld a, [$c0dd]
	ld h, a
	ld a, [$c0de]
	call LoadMonsterPic
;> return
	ret


;@ def LevelUpScreen()
;@ path: battle/levelup
;@ Far entry, run once per frame after a battle while party member wCurPartyMember gains a level:
;@ step wCommandStep of LevelUpSteps. It announces the level and the stat gains, teaches new skills
;@ (letting the player forget one when more than 8 are known) and finally applies the gains.
LevelUpScreen::
;> LevelUpSteps[wCommandStep]()
	ld a, [wCommandStep]
	rst $00

;@ path: battle/levelup
;@ The steps of LevelUpScreen.
LevelUpSteps::
	dw LevelUpStep00
	dw LevelUpStep01
	dw LevelUpStep02
	dw LevelUpStep03
	dw LevelUpStep04
	dw LevelUpStep05
	dw LevelUpStep06
	dw LevelUpStep07
	dw LevelUpStep08
	dw LevelUpStep09
	dw LevelUpStep10
	dw LevelUpStep11
	dw LevelUpStep12
	dw LevelUpStep13
	dw LevelUpStep14
	dw LevelUpStep15
	dw LevelUpStep16
	dw LevelUpStep17

;@ def LevelUpStep00()
;@ path: battle/levelup
;@ A monster already at level 99 gets nothing (the after-battle sequence moves on). Otherwise draws
;@ the two window titles (system texts $0B0A and $0B1B) into their tiles and resets the menu state.
LevelUpStep00::
;> if mem[MonsterField(wCurPartyMember, wMonLevel)] >= 99:
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	jr c, .start

;>     wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
;>     wCommandStep = 0
	xor a
	ld [wCommandStep], a
;>     return
	ret

;> wTextIndex = 0x0A; wTextGroup = 0x0B
.start:
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x8820, 1, 10)
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
;> wTextIndex = 0x1B; wTextGroup = 0x0B
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x89C0, 1, 15)
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
;> fill(wMenuChoice, 8, 0)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(wCommandStep, 8, 0)
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep01()
;@ path: battle/levelup
;@ Plays the level-up fanfare, prints "<name> grew to level N" (system text $0B01) and rolls the stat
;@ gains (RollLevelUpGains).
LevelUpStep01::
;>@n CopyName(MonsterField(wCurPartyMember, wMonName), addr(wTextArg0))
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
;=@n
	call CopyName
;>@d ByteToDecimal(mem[MonsterField(wCurPartyMember, wMonLevel)] + 1, addr(wTextArg1))
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	inc a
	ld hl, wTextArg1
;=@d
	call ByteToDecimal
;> QueueMusic(0x47)
	ld a, $47
	call QueueMusic
;> PrintSystemText(0x0B01)
	ld hl, $0b01
	call PrintSystemText
;> RollLevelUpGains()
	ld hl, far_RollLevelUpGains
	rst $10
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep02()
;@ path: battle/levelup
;@ Once the text is done: a stat already at its limit (HP, MP, attack and defense 999, agility 511,
;@ intelligence 255) gains nothing, unless the monster is past its level limit. Then prints the six
;@ gains (system text $0B1E, or $0B1F past the level limit, where the stats drop instead).
LevelUpStep02::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> if not wOverLevelLimit:
	ld a, [wOverLevelLimit]
	or a
	jp nz, .print

;>@s0     if mem16[MonsterField(wCurPartyMember, wMonMaxHP)] == 999: wLevelGains[0] = 0
	ld a, [wCurPartyMember]
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s0
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
;=@s0
	ld a, h
	or l
	jr nz, .mp

	xor a
	ld [wLevelGains], a

;>@s1     if mem16[MonsterField(wCurPartyMember, wMonMaxMP)] == 999: wLevelGains[1] = 0
.mp:
	ld a, [wCurPartyMember]
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s1
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
;=@s1
	ld a, h
	or l
	jr nz, .attack

	xor a
	ld [$c8cb], a

;>@s2     if mem16[MonsterField(wCurPartyMember, wMonAttack)] == 999: wLevelGains[2] = 0
.attack:
	ld a, [wCurPartyMember]
	ld hl, wMonAttack
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s2
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
;=@s2
	ld a, h
	or l
	jr nz, .defense

	xor a
	ld [$c8cc], a

;>@s3     if mem16[MonsterField(wCurPartyMember, wMonDefense)] == 999: wLevelGains[3] = 0
.defense:
	ld a, [wCurPartyMember]
	ld hl, wMonDefense
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s3
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
;=@s3
	ld a, h
	or l
	jr nz, .agility

	xor a
	ld [$c8cd], a

;>@s4     if mem16[MonsterField(wCurPartyMember, wMonAgility)] == 511: wLevelGains[4] = 0
.agility:
	ld a, [wCurPartyMember]
	ld hl, wMonAgility
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s4
	ld a, l
	sub $ff
	ld l, a
	ld a, h
	sbc $01
	ld h, a
;=@s4
	ld a, h
	or l
	jr nz, .intelligence

	xor a
	ld [$c8ce], a

;>@s5     if mem16[MonsterField(wCurPartyMember, wMonIntelligence)] == 255: wLevelGains[5] = 0
.intelligence:
	ld a, [wCurPartyMember]
	ld hl, wMonIntelligence
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s5
	ld a, l
	sub $ff
	ld l, a
	ld a, h
	sbc $00
	ld h, a
;=@s5
	ld a, h
	or l
	jr nz, .print

	xor a
	ld [$c8cf], a

;> ByteToDecimal(wLevelGains[0], addr(wTextArg2))
.print:
	ld a, [wLevelGains]
	ld hl, wTextArg2
	call ByteToDecimal
;> ByteToDecimal(wLevelGains[1], addr(wTextArg2) + 4)
	ld a, [$c8cb]
	ld hl, $c1a4
	call ByteToDecimal
;> ByteToDecimal(wLevelGains[2], addr(wTextArg2) + 8)
	ld a, [$c8cc]
	ld hl, $c1a8
	call ByteToDecimal
;> ByteToDecimal(wLevelGains[3], addr(wTextArg2) + 12)
	ld a, [$c8cd]
	ld hl, $c1ac
	call ByteToDecimal
;> ByteToDecimal(wLevelGains[4], addr(wTextArgs))
	ld a, [$c8ce]
	ld hl, wTextArgs
	call ByteToDecimal
;> ByteToDecimal(wLevelGains[5], addr(wTextArgs) + 4)
	ld a, [$c8cf]
	ld hl, $c1b4
	call ByteToDecimal
;>@txt PrintSystemText(0x0B1F if wOverLevelLimit else 0x0B1E)
	ld hl, $0b1e
	ld a, [wOverLevelLimit]
	or a
	jr z, .text

	ld hl, $0b1f

;=@txt
.text:
	call PrintSystemText
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep03()
;@ path: battle/levelup
;@ Once the text is done: copies the monster's 8 skills into a 40-entry scratch list in wSceneObjects
;@ (the rest $FF), where the newly learned skills are collected.
LevelUpStep03::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> fill(wSceneObjects, 0x28, 0xFF)
	ld hl, wSceneObjects
	ld bc, $0028
	ld a, $ff
	call FillMemory
;> src = MonsterField(wCurPartyMember, wMonSkills)
	ld a, [wCurPartyMember]
	ld hl, wMonSkills
	call MonsterField
;>@c for i in range(8):
	ld de, wSceneObjects
	ld b, $08

;>     wSceneObjects[i] = mem[src + i]
.copy:
	ld a, [hli]
	ld [de], a
	inc de
;=@c
	dec b
	jr nz, .copy

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep04()
;@ path: battle/levelup
;@ Once the text is done: looks for a skill the monster learns now (FindLearnableSkill) and prints it:
;@ system text $0B02 for a skill from its own list, $0B0F for one grown from several skills, $0B03 for
;@ one grown from a single skill (that skill is replaced in the scratch list). The step repeats until
;@ no skill is left, then the learnable lists are tidied up.
LevelUpStep04::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> FindLearnableSkill()
	ld hl, far_FindLearnableSkill
	rst $10
;> if mem[0xFFD8] != 0xFF:
	ldh a, [$ffd8]
	cp $ff
	jr z, .none

;>     CopySystemText(0x0600 + mem[0xFFD8], addr(wTextArg2))    # the skill's name
	ld l, a
	ld h, $06
	ld de, wTextArg2
	call CopySystemText
;>     old = 0xFF; text = 0x0B02
	ld c, $ff
	ld hl, $0b02
;>     if mem[0xFFD9] != 0:
	ldh a, [$ffd9]
	or a
	jr z, .print

;>         text = 0x0B0F
	ld hl, $0b0f
;>         if mem[0xFFD9] != 2:
	cp $02
	jr z, .print

;>             CopySystemText(0x0600 + mem[0xFFDA], addr(wTextArgs))    # the skill it grew from
	ldh a, [$ffda]
	ld l, a
	ld h, $06
	ld de, wTextArgs
	call CopySystemText
;>             text = 0x0B03; old = mem[0xFFDA]
	ld hl, $0b03
	ldh a, [$ffda]
	ld c, a

;>     PrintSystemText(text)
.print:
	push bc
	call PrintSystemText
	pop bc
;>@f     for i in range(0x28):
	ld hl, wSceneObjects
	ld b, $28

;>         if mem[addr(wSceneObjects) + i] == old:
.find:
	ld a, [hl]
	cp c
	jr nz, .next

;>             mem[addr(wSceneObjects) + i] = mem[0xFFD8]
	ldh a, [$ffd8]
	ld [hl], a
;>             break
	jr .done

;=@f
.next:
	inc hl
	dec b
	jr nz, .find

;>     return
.done:
	ret

;> PruneLearnableSkills()
.none:
	ld hl, far_PruneLearnableSkills
	rst $10
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep05()
;@ path: battle/levelup
;@ Waits for the text to finish.
LevelUpStep05::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep06()
;@ path: battle/levelup
;@ Waits for the text to finish.
LevelUpStep06::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep07()
;@ path: battle/levelup
;@ Waits for the text to finish.
LevelUpStep07::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep08()
;@ path: battle/levelup
;@ Waits for the text to finish.
LevelUpStep08::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep09()
;@ path: battle/levelup
;@ Goes straight on.
LevelUpStep09::
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep10()
;@ path: battle/levelup
;@ Once the text is done: with 8 skills or fewer the list is kept and the sequence jumps to step 16.
;@ With more, prints "forget a skill" (system text $0B04) and goes on to the forget menu.
LevelUpStep10::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> if CompactSkillList() < 9:
	call CompactSkillList
	cp $09
	jr nc, .tooMany

;>     wCommandStep = 16
	ld a, $10
	ld [wCommandStep], a
;>     return
	ret

;> wCommandStep += 1
.tooMany:
	ld hl, wCommandStep
	inc [hl]
;> PrintSystemText(0x0B04)
	ld hl, $0b04
	call PrintSystemText
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def CompactSkillList() -> a
;@ path: battle/levelup
;@ Closes the gaps ($FF) in the 40-entry skill scratch list in wSceneObjects (through wNumberBackup)
;@ and returns the number of skills in it.
CompactSkillList::
;> fill(wNumberBackup, 0x28, 0xFF)
	ld hl, wNumberBackup
	ld bc, $0028
	ld a, $ff
	call FillMemory
;> n = 0
	ld hl, wSceneObjects
	ld de, wNumberBackup
	ld b, $28
	ld c, $00

;>@a for i in range(0x28):
;>     if mem[addr(wSceneObjects) + i] != 0xFF:
.gather:
	ld a, [hli]
	cp $ff
	jr z, .skip

;>         mem[addr(wNumberBackup) + n] = mem[addr(wSceneObjects) + i]; n += 1
	ld [de], a
	inc de
	inc c

;=@a
.skip:
	dec b
	jr nz, .gather

;>@b for i in range(0x28):
	ld a, c
	push af
	ld hl, wSceneObjects
	ld de, wNumberBackup
	ld b, $28

;>     mem[addr(wSceneObjects) + i] = mem[addr(wNumberBackup) + i]
.back:
	ld a, [de]
	ld [hli], a
	inc de
;=@b
	dec b
	jr nz, .back

;> return n
	pop af
	ret


;@ def LevelUpStep11()
;@ path: battle/levelup
;@ Once the text is done: opens the forget-a-skill menu (cursor tiles from BattleCursorGfx, the skill
;@ list in pages of 4, the description and the MP cost of the skill under the cursor).
LevelUpStep11::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> DecompressVRAM(0x51, 0x12, 0x89C0)          # the cursor tiles (BattleCursorGfx)
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> wBattleListCount = CompactSkillList()
	call CompactSkillList
	ld [wBattleListCount], a
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> DrawSkillNameColumn()
	call DrawSkillNameColumn
;> DrawForgetSkillInfo()
	call DrawForgetSkillInfo
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawForgetMenu()
	call DrawForgetMenu
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def DrawForgetMenu()
;@ path: battle/levelup
;@ Draws the forget-a-skill screen into the tilemap buffer: the party panel, the title tiles, the skill
;@ list, description and MP windows, the skill's MP cost, the monster's maximum MP and the cursor.
DrawForgetMenu::
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> LoadWindowLetters_1_9()                             # the windows' title texts
	ld hl, far_LoadWindowLetters_1_9
	rst $10
;> DrawBattleWindow(ForgetSkillListWindow)
	ld de, ForgetSkillListWindow
	call DrawBattleWindow
;> DrawBattleWindow(ForgetSkillInfoWindow)
	ld de, ForgetSkillInfoWindow
	call DrawBattleWindow
;> DrawBattleWindow(ForgetMPWindow)
	ld de, ForgetMPWindow
	call DrawBattleWindow
;> DrawForgetMPCost()
	call DrawForgetMPCost
;> maxmp = mem16[MonsterField(wCurPartyMember, wMonMaxMP)]
	ld hl, wMonMaxMP
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> PrintNumber3(BattleBufferAddress(0x125), maxmp)     # row 9, column 5
	ld hl, $0125
	call BattleBufferAddress
	call PrintNumber3
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawPagedCursor(addr(wMenuChoice2), ForgetCursorSpots, wBattleListCount)
	ld de, ForgetCursorSpots
	ld a, [wBattleListCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawPagedCursor
;> return
	ret


;@ def DrawForgetMPCost()
;@ path: battle/levelup
;@ Prints the MP cost of the skill under the cursor (page wConfirmChoice, row wMenuChoice2) at row 9,
;@ column 1 of the buffer; a skill costing "all MP" (999) shows the monster's maximum MP instead.
DrawForgetMPCost::
;> page4 = 4 * wConfirmChoice
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
;> i = page4 + (wMenuChoice2 & 0x7F)
	ld a, [wMenuChoice2]
	and $7f
	add b
;> skill = mem[addr(wSceneObjects) + i]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
;> cost = GetSkillMPCost(skill)
	ld d, $00
	ld hl, far_GetSkillMPCost
	rst $10
;> diff = (cost - 999) & 0xFFFF
	ld c, e
	ld b, d
	ld a, e
	add $19
	ld e, a
	ld a, d
;> if diff != 0:
	adc $fc
	ld d, a
	ld a, d
	or e
	jr z, .all

;>     PrintNumber3(BattleBufferAddress(0x121), cost)
	ld hl, $0121
	call BattleBufferAddress
	call PrintNumber3
;>     return
	ret

;> maxmp = mem16[MonsterField(wCurPartyMember, wMonMaxMP)]
.all:
	ld hl, wMonMaxMP
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> PrintNumber3(BattleBufferAddress(0x121), maxmp)
	ld hl, $0121
	call BattleBufferAddress
	call PrintNumber3
;> return
	ret


;@ def DrawSkillNameColumn()
;@ path: battle/levelup
;@ Draws the names of the 4 skills on page wConfirmChoice of the skill scratch list into the name
;@ tiles from $9360 (9 tiles each).
DrawSkillNameColumn::
;> p = addr(wSceneObjects) + 4 * wConfirmChoice
	ld de, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	add e
	ld e, a
;> tiles = 0x9360
	ld a, $00
	adc d
	ld d, a
	ld hl, $9360

;>@r for i in range(2):
;>     p, tiles = DrawSkillNameTiles(p, tiles)
	call DrawSkillNameTiles
;=@r
	call DrawSkillNameTiles
;> p, tiles = DrawSkillNameTiles(p, tiles)
;> return DrawSkillNameTiles(p, tiles)          # the fourth: runs on into it
	call DrawSkillNameTiles

;@ def DrawSkillNameTiles(p: de, tiles: hl) -> (de, hl)
;@ path: battle/levelup
;@ Prints the name of skill mem[p] (text group 6) into 9 tiles at `tiles`; returns p + 1 and the
;@ tiles of the next line.
DrawSkillNameTiles::
;> wTextIndex = mem[p]; wTextGroup = 6
	push de
	push hl
	ld a, [de]
	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a
;> PrintTextToTiles(tiles, 1, 9)
	ld de, $0901
	call PrintTextToTiles
;>@rt return (p + 1, tiles + 0x90)
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@rt
	ld h, a
	pop de
	inc de
	ret


;@ def DrawForgetSkillInfo()
;@ path: battle/levelup
;@ Prints the description (text group 1) of the skill under the cursor into the tiles at $9000
;@ (3 lines of 18), keeping the text box settings.
DrawForgetSkillInfo::
;> page4 = 4 * wConfirmChoice
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
;> i = page4 + (wMenuChoice2 & 0x7F)
	ld a, [wMenuChoice2]
	and $7f
	add b
;> skill = mem[addr(wSceneObjects) + i]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;> wTextIndex = skill
	ld [wTextIndex], a
;> wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;> savedTiles = wTextTiles
	ld hl, $9000
	ld de, $1203
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
;> savedLines = wTextBoxLines; savedLength = wTextBoxLineLength
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = 0x9000
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = 3; wTextBoxLineLength = 18
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;> PrintText_56()                       # prints the text into those tiles
	ld hl, far_PrintText_56
	rst $10
;> wTextTiles = savedTiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = savedLines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = savedLength
	ld a, d
	ld [wTextBoxLineLength], a
;> return
	ret


;@ def LevelUpStep12()
;@ path: battle/levelup
;@ The forget-a-skill menu: moves the cursor through the pages of 4 skills (redrawing the names,
;@ description and MP cost when the page or row changes). A chooses the skill to forget.
LevelUpStep12::
;> spots = ForgetCursorSpots; n = wBattleListCount
	ld de, ForgetCursorSpots
	ld hl, wMenuChoice2
	ld a, [wBattleListCount]
	ld c, a
	ld b, $04
;> oldRow = wMenuChoice2; oldPage = wConfirmChoice
	ld a, [hli]
	push af
	ld a, [hld]
	push af
;> UpdatePagedCursor(addr(wMenuChoice2), spots, n, 4)
	call UpdatePagedCursor
;> if wConfirmChoice != oldPage:
	pop af
	ld hl, wConfirmChoice
	cp [hl]
	jr z, .samePage

;>     DrawSkillNameColumn()
	call DrawSkillNameColumn
;>     DrawForgetSkillInfo()
	call DrawForgetSkillInfo
;>     DrawForgetMPCost()
	call DrawForgetMPCost
;>     CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG

;> if wMenuChoice2 != oldRow:
.samePage:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, .buttons

;>     DrawForgetSkillInfo()
	call DrawForgetSkillInfo
;>     DrawForgetMPCost()
	call DrawForgetMPCost
;>     CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG

;> if wJoyPressed & 1:                 # A
.buttons:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;>     wMenuChoice2 |= 0x80
	ld hl, wMenuChoice2
	set 7, [hl]
;>     wConfirmChoice2 = 0
	xor a
	ld [wConfirmChoice2], a

;> return
.done:
	ret


;@ path: battle/levelup
;@ Cursor spots of the forget-a-skill list (BG buffer offsets, $FFFF ends the list): the page number
;@ first, then the 4 rows.
ForgetCursorSpots::
	dw $0152, $0069, $00a9, $00e9, $0129, $ffff

;@ def LevelUpStep13()
;@ path: battle/levelup
;@ Once the text is done: asks whether to forget the chosen skill (system text $0B05).
LevelUpStep13::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> page4 = 4 * wConfirmChoice
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
;> i = page4 + (wMenuChoice2 & 0x7F)
	ld a, [wMenuChoice2]
	and $7f
	add b
;> skill = mem[addr(wSceneObjects) + i]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
;> CopySystemText(0x0600 + skill, addr(wTextArg0))
	ld h, $06
	ld de, wTextArg0
	call CopySystemText
;> PrintSystemText(0x0B05)
	ld hl, $0b05
	call PrintSystemText
;> DrawBattleWindow(0x2E07)             # the message box frame
	ld de, $2e07
	call DrawBattleWindow
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def LevelUpStep14()
;@ path: battle/levelup
;@ Once the text is done: draws the yes/no window of the forget question.
LevelUpStep14::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawForgetMenu()
	call DrawForgetMenu
;> DrawBattleWindow(0x2E07)
	ld de, $2e07
	call DrawBattleWindow
;> DecompressVRAM(0x51, 0x12, 0x89C0)
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> DrawBattleWindow(ResultYesNoWindow)
	ld de, ResultYesNoWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(ForgetYesNoSpots, wConfirmChoice2)
	ld de, ForgetYesNoSpots
	ld a, [wConfirmChoice2]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def LevelUpStep15()
;@ path: battle/levelup
;@ The yes/no choice: B or "no" keeps the skills (system text $0B07, back to step 11); "yes" removes
;@ the skill from the scratch list and prints "<skill> was forgotten" (system text $0B06).
LevelUpStep15::
;> UpdateBattleMenuCursor(addr(wConfirmChoice2), ForgetYesNoSpots, 2)
	ld de, ForgetYesNoSpots
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     PrintSystemText(0x0B07)
.no:
	ld hl, $0b07
	call PrintSystemText
;>     wCommandStep = 11
	ld a, $0b
	ld [wCommandStep], a
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice2 == 0x81:     # "no"
	ld a, [wConfirmChoice2]
	cp $81
;>         PrintSystemText(0x0B07); wCommandStep = 11      # the B case above
	jr z, .no

;>     else:
;>         wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;>         wConfirmChoice2 |= 0x80
	ld hl, wConfirmChoice2
	set 7, [hl]
;>         page4 = 4 * wConfirmChoice
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
;>         i = page4 + (wMenuChoice2 & 0x7F)
	ld a, [wMenuChoice2]
	and $7f
	add b
;>         skill = mem[addr(wSceneObjects) + i]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>         mem[addr(wSceneObjects) + i] = 0xFF
	ld [hl], $ff
;>         CopySystemText(0x0600 + skill, addr(wTextArg0))
	ld l, a
	ld h, $06
	ld de, wTextArg0
	call CopySystemText
;>         PrintSystemText(0x0B06)
	ld hl, $0b06
	call PrintSystemText

;> return
.done:
	ret


;@ path: battle/levelup
;@ Cursor spots of the yes/no window of the forget question (BG buffer offsets, $FFFF ends the list).
ForgetYesNoSpots::
	dw $012f, $016f, $ffff

;@ def LevelUpStep16()
;@ path: battle/levelup
;@ Once the text is done: one level below its level limit, the monster gets a note (system text $0B20).
LevelUpStep16::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> lvl = MonsterField(wCurPartyMember, wMonLevel)
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	push hl
;> maxlvl = mem[MonsterField(wCurPartyMember, wMonMaxLevel)]
	ld a, [wCurPartyMember]
	ld hl, wMonMaxLevel
	call MonsterField
	ld a, [hl]
;> if maxlvl - 1 == mem[lvl]:
	dec a
	pop hl
	cp [hl]
	jr nz, .next

;>     PrintSystemText(0x0B20)
	ld hl, $0b20
	call PrintSystemText

;> wCommandStep += 1
.next:
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def LevelUpStep17()
;@ path: battle/levelup
;@ Once the text is done: still more than 8 skills means forgetting another one (system text $0B07,
;@ back to step 11). Otherwise the skills are stored, the level and stats applied, the screen redrawn,
;@ and the after-battle sequence repeats its level-up check.
LevelUpStep17::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> if CompactSkillList() >= 9:
	call CompactSkillList
	cp $09
	jr c, .apply

;>     PrintSystemText(0x0B07)
	ld hl, $0b07
	call PrintSystemText
;>     wCommandStep = 11
	ld a, $0b
	ld [wCommandStep], a
;>     wMenuChoice2 = 0; wConfirmChoice = 0
	xor a
	ld [wMenuChoice2], a
	ld [wConfirmChoice], a
;>     return
	ret

;> StoreLearnedSkills()
.apply:
	call StoreLearnedSkills
;> ApplyLevelUp()
	call ApplyLevelUp
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> wBattleStep -= 1
	ld hl, wBattleStep
	dec [hl]
;> return
	ret


;@ def StoreLearnedSkills()
;@ path: battle/levelup
;@ Copies the first 8 entries of the skill scratch list back into the monster's skill list.
StoreLearnedSkills::
;> dest = MonsterField(wCurPartyMember, wMonSkills)
	ld a, [wCurPartyMember]
	ld hl, wMonSkills
	call MonsterField
;>@c for i in range(8):
	ld de, wSceneObjects
	ld b, $08

;>     mem[dest + i] = wSceneObjects[i]
.copy:
	ld a, [de]
	ld [hli], a
	inc de
;=@c
	dec b
	jr nz, .copy

;> return
	ret


;@ def ApplyLevelUp()
;@ path: battle/levelup
;@ Far entry: raises party member wCurPartyMember one level (up to 99) and adds the stat gains of
;@ wLevelGains. Past its level limit the gains are taken away instead; HP and MP are then cut to the new
;@ maximum and the party battlers and the screen are refreshed.
ApplyLevelUp::
;> if mem[MonsterField(wCurPartyMember, wMonLevel)] >= 99: return
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	ret nc

;> mem[MonsterField(wCurPartyMember, wMonLevel)] += 1
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	inc a
	ld [hl], a
;> if not wOverLevelLimit:
	ld a, [wOverLevelLimit]
	or a
	jr nz, .lower

;>     RaiseMonsterMaxHP(wCurPartyMember, wLevelGains[0])
	ld a, [wLevelGains]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxHP
;>     RaiseMonsterMaxMP(wCurPartyMember, wLevelGains[1])
	ld a, [$c8cb]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxMP
;>     RaiseMonsterAttack(wCurPartyMember, wLevelGains[2])
	ld a, [$c8cc]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterAttack
;>     RaiseMonsterDefense(wCurPartyMember, wLevelGains[3])
	ld a, [$c8cd]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterDefense
;>     RaiseMonsterAgility(wCurPartyMember, wLevelGains[4])
	ld a, [$c8ce]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterAgility
;>     RaiseMonsterIntelligence(wCurPartyMember, wLevelGains[5])
	ld a, [$c8cf]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterIntelligence
;>     return
	ret

;> LowerMonsterMaxHP(wCurPartyMember, wLevelGains[0])
.lower:
	ld a, [wLevelGains]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterMaxHP
;> LowerMonsterMaxMP(wCurPartyMember, wLevelGains[1])
	ld a, [$c8cb]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterMaxMP
;> LowerMonsterAttack(wCurPartyMember, wLevelGains[2])
	ld a, [$c8cc]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterAttack
;> LowerMonsterDefense(wCurPartyMember, wLevelGains[3])
	ld a, [$c8cd]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterDefense
;> LowerMonsterAgility(wCurPartyMember, wLevelGains[4])
	ld a, [$c8ce]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterAgility
;> LowerMonsterIntelligence(wCurPartyMember, wLevelGains[5])
	ld a, [$c8cf]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterIntelligence
;> maxhp = mem16[MonsterField(wCurPartyMember, wMonMaxHP)]
	ld a, [wCurPartyMember]
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> p = MonsterField(wCurPartyMember, wMonHP)
	push bc
	ld a, [wCurPartyMember]
	ld hl, wMonHP
	call MonsterField
	pop bc
;> if maxhp < mem16[p]:
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc [hl]
	jr nc, .mp

;>     mem16[p] = maxhp
	ld [hl], b
	dec hl
	ld [hl], c

;> maxmp = mem16[MonsterField(wCurPartyMember, wMonMaxMP)]
.mp:
	ld a, [wCurPartyMember]
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> p = MonsterField(wCurPartyMember, wMonMP)
	push bc
	ld a, [wCurPartyMember]
	ld hl, wMonMP
	call MonsterField
	pop bc
;> if maxmp < mem16[p]:
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc [hl]
	jr nc, .refresh

;>     mem16[p] = maxmp
	ld [hl], b
	dec hl
	ld [hl], c

;> ReloadPartyBattlers()
.refresh:
	call ReloadPartyBattlers
;> RefreshStatusIcons()
	call RefreshStatusIcons
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> ClearBGAttributes()
	call ClearBGAttributes
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitScreen()
;@ path: battle/recruit
;@ Far entry, run once per frame after a battle when a defeated monster wants to join: step
;@ wCommandStep of RecruitSteps. The monster (made in the spare record slot 20) is offered; when all
;@ 20 slots are taken, the player may release a monster or egg first. A newcomer goes to the party
;@ when there is room (or swaps with a party member), else to the farm; it can be renamed.
;@ test: skip jump table indexed by a step variable
RecruitScreen::
;> RecruitSteps[wCommandStep]()
	ld a, [wCommandStep]
	rst $00

;@ path: battle/recruit
;@ The steps of RecruitScreen.
RecruitSteps::
	dw RecruitStep00
	dw RecruitStep01
	dw RecruitStep02
	dw RecruitStep03
	dw RecruitStep04
	dw RecruitStep05
	dw RecruitStep06
	dw RecruitStep07
	dw RecruitStep08
	dw RecruitStep09
	dw RecruitStep10
	dw RecruitStep11
	dw RecruitStep12
	dw RecruitStep13
	dw RecruitStep14
	dw RecruitStep15
	dw RecruitStep16
	dw RecruitStep17
	dw RecruitStep18
	dw RecruitStep19
	dw RecruitStep20
	dw RecruitStep21
	dw RecruitStep22
	dw RecruitStep23
	dw RecruitStep24
	dw RecruitStep25
	dw RecruitStep26
	dw RecruitStep27
	dw RecruitStep28
	dw RecruitStep29
	dw RecruitStep29
	dw RecruitStep31
	dw RecruitStep32
	dw RecruitStep33
	dw RecruitStep34
	dw RecruitStep35
	dw RecruitStep36

;@ def RecruitStep00()
;@ path: battle/recruit
;@ Sets up the joining screen: palettes, the window titles, the new monster created in record slot 20
;@ from wNewMonId (CreateMonsterUnlisted) with its picture in the middle of the screen, and a copy of
;@ the party's names in wPartyBarTiles.
RecruitStep00::
;> LoadFieldObjPalettes()
	ld hl, far_LoadFieldObjPalettes
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> wTextIndex = 0x0A; wTextGroup = 0x0B
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x8820, 1, 10)
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
;> wTextIndex = 0x1B; wTextGroup = 0x0B
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x89C0, 1, 15)
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
;> wNewMonSlot = 20
	ld a, $14
	ld [wNewMonSlot], a
;> CreateMonsterUnlisted()
	ld hl, far_CreateMonsterUnlisted
	rst $10
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> LoadMonsterPic(wNewMonNameText, 0x9000)
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
;> fill(wMenuChoice, 8, 0)
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
;> fill(wCommandStep, 8, 0)
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
;> wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
;> PlacePicTiles(0, 0x00C7)                   # 6 x 6 tiles from row 6, column 7
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> p = CopyMonName8(wParty[0], addr(wPartyBarTiles))
	ld de, wPartyBarTiles
	ld a, [wParty]
	call CopyMonName8
;> p = CopyMonName8(wParty[1], p)
	ld a, [$ca8f]
	call CopyMonName8
;> CopyMonName8(wParty[2], p)
	ld a, [$ca90]
	call CopyMonName8
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def CopyMonName8(slot: a, dest: de) -> de
;@ path: battle/recruit
;@ Copies the 8 name bytes of the monster in record slot `slot` to `dest` ($FF: nothing); returns
;@ the address after them.
CopyMonName8::
;> if slot == 0xFF: return dest
	cp $ff
	ret z

;> p = MonsterField(slot, wMonName)
	push de
	ld hl, wMonName
	call MonsterField
	pop de
;>@c for i in range(8):
	ld b, $08

;>     mem[dest + i] = mem[p + i]
.copy:
	ld a, [hli]
	ld [de], a
	inc de
;=@c
	dec b
	jr nz, .copy

;> return dest + 8
	ret


;@ def RecruitStep01()
;@ path: battle/recruit
;@ Prints "<species> wants to join" (system text $0B10) with the newcomer's sex symbol.
RecruitStep01::
;> CopySystemText(0x0500 + wNewMonNameText, addr(wTextArg0))     # the species name
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
;> AppendSexSymbol(mem[MonsterField(20, wMonGender)], addr(wTextArg0))
	ld a, $14
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg0
	call AppendSexSymbol
;> PrintSystemText(0x0B10)
	ld hl, $0b10
	call PrintSystemText
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RecruitStep02()
;@ path: battle/recruit
;@ Once the text is done: redraws the screen with the yes/no window (cursor wMenuChoice).
RecruitStep02::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> DecompressVRAM(0x51, 0x12, 0x89C0)          # the cursor tiles
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> DrawBattleWindow(ResultYesNoWindow)
	ld de, ResultYesNoWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(JoinYesNoSpots, wMenuChoice)
	ld de, JoinYesNoSpots
	ld a, [wMenuChoice]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep03()
;@ path: battle/recruit
;@ Accept the monster? B or "no": "<species> goes away" (system text $0B12) and the end (step 29).
;@ "Yes": on to step 4.
RecruitStep03::
;> UpdateBattleMenuCursor(addr(wMenuChoice), JoinYesNoSpots, 2)
	ld de, JoinYesNoSpots
	ld hl, wMenuChoice
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     CopySystemText(0x0500 + wNewMonNameText, addr(wTextArg0))
.no:
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
;>     PrintSystemText(0x0B12)
	ld hl, $0b12
	call PrintSystemText
;>     wCommandStep = 29
	ld a, $1d
	ld [wCommandStep], a
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice == 0x81:         # "no"
	ld a, [wMenuChoice]
	cp $81
;>         PrintSystemText(0x0B12); wCommandStep = 29      # the B case above
	jr z, .no

;>     else:
;>         wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;>         wMenuChoice |= 0x80
	ld hl, wMenuChoice
	set 7, [hl]
;>         fill(wMenuChoice2, 7, 0)
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the yes/no window asking whether the monster may join (BG buffer offsets, $FFFF ends).
JoinYesNoSpots::
	dw $012f, $016f, $ffff

;@ def RecruitStep04()
;@ path: battle/recruit
;@ With a free record slot the newcomer is stored (step 21). With all 20 taken, asks whether to release
;@ a monster to make room (system text $0B11).
RecruitStep04::
;> if CountFreeMonSlots() != 0:
	call CountFreeMonSlots
	or a
	jr z, .full

;>     wCommandStep = 21
	ld a, $15
	ld [wCommandStep], a
	jr .done

;> else:
;>     wCommandStep += 1
.full:
	ld hl, wCommandStep
	inc [hl]
;>     PrintSystemText(0x0B11)
	ld hl, $0b11
	call PrintSystemText
;>     ClearBattleTilemap()
	call ClearBattleTilemap
;>     DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;>     PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;>     SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;>     DecompressVRAM(0x51, 0x12, 0x89C0)
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;>     DrawBattleWindow(ResultYesNoWindow)
	ld de, ResultYesNoWindow
	call DrawBattleWindow
;>     DrawBattleCursorAt(JoinYesNoSpots, wMenuChoice)
	ld de, JoinYesNoSpots
	ld a, [wMenuChoice]
	call DrawBattleCursorAt
;>     CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG

;> return
.done:
	ret


;@ def CountFreeMonSlots() -> a
;@ path: battle/recruit
;@ Counts the empty records (kind byte 0) among the 20 monster slots.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2)
CountFreeMonSlots::
;> n = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@s for slot in range(20):
;>     if mem[addr(wMonsters) + slot * 0x95] == 0: n += 1
.loop:
	ld a, [de]
	or a
	jr nz, .next

	inc c

;=@s
.next:
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@s
	dec b
	jr nz, .loop

;> return n
	ld a, c
	ret


;@ def RecruitStep05()
;@ path: battle/recruit
;@ Once the text is done: shows the yes/no window of the release question (cursor wMenuChoice2).
RecruitStep05::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> DecompressVRAM(0x51, 0x12, 0x89C0)
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> DrawBattleWindow(ResultYesNoWindow)
	ld de, ResultYesNoWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(RecruitYesNoSpots, wMenuChoice2)
	ld de, RecruitYesNoSpots
	ld a, [wMenuChoice2]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep06()
;@ path: battle/recruit
;@ Release a monster for the newcomer? B or "no": the newcomer goes away (system text $0B12, step 29).
;@ "Yes": on to the monsters-or-eggs choice (step 31).
RecruitStep06::
;> UpdateBattleMenuCursor(addr(wMenuChoice2), RecruitYesNoSpots, 2)
	ld de, RecruitYesNoSpots
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     CopySystemText(0x0500 + wNewMonNameText, addr(wTextArg0))
.no:
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
;>     PrintSystemText(0x0B12)
	ld hl, $0b12
	call PrintSystemText
;>     wCommandStep = 29
	ld a, $1d
	ld [wCommandStep], a
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice2 == 0x81:        # "no"
	ld a, [wMenuChoice2]
	cp $81
;>         PrintSystemText(0x0B12); wCommandStep = 29      # the B case above
	jr z, .no

;>     else:
;>         fill(wListCursor, 8, 0)
	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
;>         wMenuChoice2 |= 0x80; wConfirmChoice = 0
	ld hl, wMenuChoice2
	set 7, [hl]
	inc hl
	ld [hl], $00
;>         wCommandStep = 31
	ld a, $1f
	ld [wCommandStep], a

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the yes/no window of the release question (BG buffer offsets, $FFFF ends).
RecruitYesNoSpots::
	dw $012f, $016f, $ffff

;@ def RecruitStep07()
;@ path: battle/recruit
;@ Lists the monsters (wListCursor2 bit 0 clear) or the eggs (set) the player owns. With none of that
;@ kind: system text $0B1C and step 34. Otherwise "release which monster / egg?" (system text $0B13 or
;@ $0B22).
RecruitStep07::
;> if CountMonstersOrEggs() == 0:
	call CountMonstersOrEggs
	or a
	jr nz, .list

;>     PrintSystemText(0x0B1C)
	ld hl, $0b1c
	call PrintSystemText
;>     wCommandStep = 34
	ld a, $22
	ld [wCommandStep], a
;>     return
	ret

;> ListMonstersOrEggs()
.list:
	call ListMonstersOrEggs
;>@p PrintSystemText(0x0B22 if wListCursor2 & 1 else 0x0B13)
	ld hl, $0b13
	ld a, [wListCursor2]
	and $01
	jr z, .print

	ld hl, $0b22

;=@p
.print:
	call PrintSystemText
;> DrawMonsterEggChoice()
	call DrawMonsterEggChoice
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def DrawMonsterEggChoice()
;@ path: battle/recruit
;@ Draws the screen with the newcomer's picture and the monsters / eggs window (cursor wListCursor2).
DrawMonsterEggChoice::
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> DrawBattleWindow(MonsterEggWindow)
	ld de, MonsterEggWindow
	call DrawBattleWindow
;> DrawBattleCursorAt(MonsterEggSpots, wListCursor2)
	ld de, MonsterEggSpots
	ld a, [wListCursor2]
	call DrawBattleCursorAt
;> return
	ret


;@ def CountMonstersOrEggs() -> a
;@ path: battle/recruit
;@ Counts the owned records that are monsters (wListCursor2 bit 0 clear) or eggs (set; record byte
;@ wMonEgg 1 or 2) into wListLength.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
CountMonstersOrEggs::
;> n = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@s for slot in range(20):
;>     rec = addr(wMonsters) + slot * 0x95
.loop:
	push de
;>     if mem[rec] != 0:
	ld a, [de]
	or a
	jr z, .next

;>         egg = mem[rec + 0x63]
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@e         if (egg >> 1 | egg) & 1 == wListCursor2 & 1: n += 1
	ld a, [wListCursor2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
;=@e
	or h
	and $01
	xor l
	jr nz, .next

	inc c

;=@s
.next:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@s
	ld d, a
	dec b
	jr nz, .loop

;> wListLength = n
	ld a, c
	ld [wListLength], a
;> return n
	ret


;@ def ListMonstersOrEggs()
;@ path: battle/recruit
;@ Writes the record slots of the owned monsters (or eggs, by wListCursor2 bit 0) into the list in
;@ wSceneObjects (20 entries, $FF after the last).
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2); mem[0xCB24 + i * 0x95] = rand(0, 2)
ListMonstersOrEggs::
;> fill(wSceneObjects, 20, 0xFF)
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
;> p = addr(wSceneObjects)
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@s for slot in range(20):
;>     rec = addr(wMonsters) + slot * 0x95
.loop:
	push de
;>     if mem[rec] != 0:
	ld a, [de]
	or a
	jr z, .next

;>         egg = mem[rec + 0x63]
	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
;>@e         if (egg >> 1 | egg) & 1 == wListCursor2 & 1:
	push hl
	ld a, [wListCursor2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
;=@e
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, .next

;>             mem[p] = slot; p += 1
	ld [hl], c
	inc hl

;=@s
.next:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@s
	ld d, a
	inc c
	dec b
	jr nz, .loop

;> return
	ret


;@ def RecruitStep08()
;@ path: battle/recruit
;@ Once the text is done: draws the first page of the release list.
RecruitStep08::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> DrawReleaseListPage()
	call DrawReleaseListPage
;> DrawReleaseList()
	call DrawReleaseList
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def DrawReleaseList()
;@ path: battle/recruit
;@ Draws the release list window (monsters or eggs) with its title tiles and the paged cursor
;@ (wListCursor, wListPage; 4 rows per page).
DrawReleaseList::
;> LoadWindowLetters_10()                             # the title text tiles
	ld hl, far_LoadWindowLetters_10
	rst $10
;>@w DrawBattleWindow(ResultEggListWindow if wListCursor2 & 1 else ResultMonsterListWindow)
	ld de, ResultMonsterListWindow
	ld a, [wListCursor2]
	and $01
	jr z, .draw

	ld de, ResultEggListWindow

;=@w
.draw:
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> spots = EggListSpots if wListCursor2 & 1 else MonsterListSpots
	ld de, MonsterListSpots
	ld a, [wListCursor2]
	and $01
	jr z, .cursor

	ld de, EggListSpots

;> DrawPagedCursor(addr(wListCursor), spots, wListLength, 4)
.cursor:
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawPagedCursor
;> return
	ret


;@ def DrawReleaseListPage()
;@ path: battle/recruit
;@ Draws the 4 entries of page wListPage: monster names into tiles from $88C0, or for eggs the species
;@ names into tiles from $9240 and the sex icons into tiles from $9480.
DrawReleaseListPage::
;> p = addr(wSceneObjects) + 4 * wListPage
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;> if wListCursor2 & 1:                 # eggs
	ld a, $00
	adc d
	ld d, a
	ld a, [wListCursor2]
	and $01
	jr z, .monsters

;>     tiles = 0x9240
	ld hl, $9240
;>@sp     for i in range(4): p, tiles = DrawListSpeciesTiles(p, tiles)
	call DrawListSpeciesTiles
;=@sp
	call DrawListSpeciesTiles
	call DrawListSpeciesTiles
	call DrawListSpeciesTiles
;>     DrawListSexIcons()
	call DrawListSexIcons
;>     return
	ret

;> tiles = 0x88C0
.monsters:
	ld hl, $88c0
;>@nm for i in range(3): p, tiles = DrawListNameTiles(p, tiles)
	call DrawListNameTiles
;=@nm
	call DrawListNameTiles
	call DrawListNameTiles
;> return DrawListNameTiles(p, tiles)        # the fourth: runs on into it

;@ def DrawListNameTiles(p: de, tiles: hl) -> (de, hl)
;@ path: battle/recruit
;@ Draws the name of the monster in record slot mem[p] into 4 tiles at `tiles` (blank tiles for $FF);
;@ returns p + 1 and tiles + $40.
DrawListNameTiles::
;> if mem[p] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>     name = MonsterField(mem[p], wMonName)
	ld a, [de]
	ld hl, wMonName
	call MonsterField
;>     DrawMonNameTiles(name, tiles)
	ld e, l
	ld d, h
	pop hl
	push hl
	call DrawMonNameTiles
;>@r     return (p + 1, tiles + 0x40)
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret

;>@b for i in range(0x20):              # 4 empty tiles
.blank:
	ld b, $20

;>     WriteVRAMInc(0xFF); WriteVRAMInc(0)
.clear:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@b
	dec b
	jr nz, .clear

;>@r2 return (p + 1, tiles + 0x40)
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
;=@r2
	ld h, a
	pop de
	inc de
	ret


;@ def DrawListSpeciesTiles(p: de, tiles: hl) -> (de, hl)
;@ path: battle/recruit
;@ Prints the species name (text group 5) of the record in slot mem[p] into 9 tiles at `tiles`
;@ (blank for $FF); returns p + 1 and tiles + $90.
DrawListSpeciesTiles::
;> if mem[p] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>     wTextIndex = mem[MonsterField(mem[p], wMonRecSpecies)]
	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
;>     wTextGroup = 5
	ld a, $05
	ld [wTextGroup], a
;>     PrintTextToTiles(tiles, 1, 9)
	ld de, $0901
	pop hl
	push hl
	call PrintTextToTiles
;>@r     return (p + 1, tiles + 0x90)
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret

;>@b for i in range(0x48):              # 9 empty tiles
.blank:
	ld b, $48

;>     WriteVRAMInc(0xFF); WriteVRAMInc(0)
.clear:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@b
	dec b
	jr nz, .clear

;>@r2 return (p + 1, tiles + 0x90)
	pop hl
	ld a, l
	add $90
	ld l, a
	ld a, h
	adc $00
;=@r2
	ld h, a
	pop de
	inc de
	ret


;@ def DrawListSexIcons()
;@ path: battle/recruit
;@ Draws the sex icons of the 4 eggs on page wListPage into the tiles from $9480.
DrawListSexIcons::
;> p = addr(wSceneObjects) + 4 * wListPage
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
;> tiles = 0x9480
	ld a, $00
	adc d
	ld d, a
	ld hl, $9480
;>@ic for i in range(3): p, tiles = DrawListSexIcon(p, tiles)
	call DrawListSexIcon
;=@ic
	call DrawListSexIcon
	call DrawListSexIcon
;> return DrawListSexIcon(p, tiles)         # the fourth: runs on into it

;@ def DrawListSexIcon(p: de, tiles: hl) -> (de, hl)
;@ path: battle/recruit
;@ Draws one tile for the egg in record slot mem[p]: its sex symbol ($A7 + sex) once the sex is
;@ known (wMonEgg 2), else "?" ($98); a blank tile for $FF. Returns p + 1 and tiles + $10.
DrawListSexIcon::
;> if mem[p] != 0xFF:
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, .blank

;>     egg = MonsterField(mem[p], wMonEgg)
	ld hl, wMonEgg
	call MonsterField
;>     icon = 0x98
;>     if mem[egg] == 2:
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, .store

;>@ix         icon = 0xA7 + (mem[egg - 0x58] & 1)      # wMonGender of the record
	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@ix
	ld a, [hl]
	and $01
	add $a7

;>     wTextArg0[0] = icon; wTextArg0[1] = 0xF0
.store:
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
;>     savedTiles = wTextTiles
	pop hl
	push hl
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
;>     savedLines = wTextBoxLines; savedLength = wTextBoxLineLength
	push bc
	ld a, [wTextBoxLines]
	ld c, a
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;>     wTextTiles = tiles
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;>     wTextBoxLines = 1; wTextBoxLineLength = 1
	ld de, $0101
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
;>     wTextGroup = 2; wTextIndex = 0          # the text that shows wTextArg0
	ld a, $02
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
;>     PrintText_41()
	ld hl, far_PrintText_41
	rst $10
;>     wTextTiles = savedTiles
	pop de
	pop hl
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;>     wTextBoxLines = savedLines
	ld a, e
	ld [wTextBoxLines], a
;>     wTextBoxLineLength = savedLength
	ld a, d
	ld [wTextBoxLineLength], a
;>@r     return (p + 1, tiles + 0x10)
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r
	ld h, a
	pop de
	inc de
	ret

;>@b for i in range(8):                 # an empty tile
.blank:
	ld b, $08

;>     WriteVRAMInc(0xFF); WriteVRAMInc(0)
.clear:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
;=@b
	dec b
	jr nz, .clear

;>@r2 return (p + 1, tiles + 0x10)
	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
;=@r2
	ld h, a
	pop de
	inc de
	ret


;@ def RecruitStep09()
;@ path: battle/recruit
;@ The release list: moves the paged cursor (redrawing the page when it changes). B goes back to the
;@ monsters-or-eggs choice (system text $0B1A, step 32); A picks the entry (step 10).
RecruitStep09::
;> spots = EggListSpots if wListCursor2 & 1 else MonsterListSpots
	ld de, MonsterListSpots
	ld a, [wListCursor2]
	and $01
	jr z, .move

	ld de, EggListSpots

;> oldPage = wListPage
.move:
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
;> UpdatePagedCursor(addr(wListCursor), spots, wListLength, 4)
	push af
	call UpdatePagedCursor
;> if wListPage != oldPage: DrawReleaseListPage()
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, .buttons

	call DrawReleaseListPage

;> if wJoyPressed & 2:                 # B
.buttons:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     RedrawMonsterEggChoice()
	call RedrawMonsterEggChoice
;>     wCommandStep = 32
	ld a, $20
	ld [wCommandStep], a
;>     PrintSystemText(0x0B1A)
	ld hl, $0b1a
	call PrintSystemText
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;>     wConfirmChoice |= 0x80; wConfirmChoice2 = 0
	ld hl, wConfirmChoice
	set 7, [hl]
	inc hl
	ld [hl], $00

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the release list of monsters (BG buffer offsets, $FFFF ends): the page number, then
;@ the 4 rows.
MonsterListSpots::
	dw $0185, $00a1, $00e1, $0121, $0161, $ffff

;@ path: battle/recruit
;@ Cursor spots of the release list of eggs (BG buffer offsets, $FFFF ends): the page number, then
;@ the 4 rows.
EggListSpots::
	dw $018b, $00a1, $00e1, $0121, $0161, $ffff

;@ def RecruitStep10()
;@ path: battle/recruit
;@ Goes straight on.
RecruitStep10::
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RecruitStep11()
;@ path: battle/recruit
;@ Once the text is done: shows the two-choice window for the picked entry (look at it / release it).
RecruitStep11::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> DrawReleaseConfirm()
	call DrawReleaseConfirm
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def DrawReleaseConfirm()
;@ path: battle/recruit
;@ Draws the two-choice window for a monster or an egg and its cursor (wConfirmChoice2).
DrawReleaseConfirm::
;>@w DrawBattleWindow(EggConfirmWindow if wListCursor2 & 1 else ReleaseConfirmWindow)
	ld de, ReleaseConfirmWindow
	ld a, [wListCursor2]
	and $01
	jr z, .draw

	ld de, EggConfirmWindow

;=@w
.draw:
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> spots = EggReleaseYesNoSpots if wListCursor2 & 1 else ReleaseYesNoSpots
	ld de, ReleaseYesNoSpots
	ld a, [wListCursor2]
	and $01
	jr z, .cursor

	ld de, EggReleaseYesNoSpots

;> DrawBattleCursorAt(spots, wConfirmChoice2)
.cursor:
	ld a, [wConfirmChoice2]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep12()
;@ path: battle/recruit
;@ The two choices for the picked entry. B: back to the list (step 7). The first choice shows its status
;@ screen (step 25). The second releases it (step 13), except the party leader while no other party
;@ monster is standing (system text $0B24, back to step 31).
RecruitStep12::
;> spots = EggReleaseYesNoSpots if wListCursor2 & 1 else ReleaseYesNoSpots
	ld de, ReleaseYesNoSpots
	ld a, [wListCursor2]
	and $01
	jr z, .move

	ld de, EggReleaseYesNoSpots

;> UpdateBattleMenuCursor(addr(wConfirmChoice2), spots, 2)
.move:
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@b     wCommandStep -= 5
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
;=@b
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wConfirmChoice2 != 0x81:     # look at it
	ld a, [wConfirmChoice2]
	cp $81
	jr z, .release

;>         wFieldMenuState = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wCommandStep = 25
	ld a, $19
	ld [wCommandStep], a
	jr .done

;>     else:                           # release it
;>@lead         if wPartyCount == 1 or mem[MonsterField(wParty[1], wMonStatus)] & 0x80:
.release:
	ld a, [wPartyCount]
	cp $01
	jr z, .leader

;=@lead
	ld a, [$ca8f]
	ld hl, wMonStatus
	call MonsterField
	bit 7, [hl]
	jr z, .ok

;>             page4 = 4 * wListPage
.leader:
	ld a, [wListPage]
	add a
	add a
	ld b, a
;>             i = page4 + (wListCursor & 0x7F)
	ld a, [wListCursor]
	and $7f
	add b
;>             q = addr(wSceneObjects) + i
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>             if mem[q] == wParty[0]:     # the leader would stand alone
	ld a, [wParty]
	cp [hl]
	jr nz, .ok

;>                 PrintSystemText(0x0B24)
	ld hl, $0b24
	call PrintSystemText
;>                 DrawBattleWindow(0x2E07)
	ld de, $2e07
	call DrawBattleWindow
;>                 CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;>                 wCommandStep = 31; return
	ld a, $1f
	ld [wCommandStep], a
	jr .done

;>         wCommandStep += 1
.ok:
	ld hl, wCommandStep
	inc [hl]
;>         wConfirmChoice2 |= 0x80; wMenuChoice3 = 0
	ld hl, wConfirmChoice2
	set 7, [hl]
	inc hl
	ld [hl], $00

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the two-choice window for a monster (BG buffer offsets, $FFFF ends).
ReleaseYesNoSpots::
	dw $012e, $016e, $ffff

;@ path: battle/recruit
;@ Cursor spots of the two-choice window for an egg (BG buffer offsets, $FFFF ends).
EggReleaseYesNoSpots::
	dw $012d, $016d, $ffff

;@ def RecruitStep13()
;@ path: battle/recruit
;@ Once the text is done: releases the picked monster or egg (system text $0B14 with its name, or $0B1D
;@ for an egg): its record is emptied and the monster list tidied up. Then on to storing the newcomer
;@ (step 21).
RecruitStep13::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> page4 = 4 * wListPage
	ld a, [wListPage]
	add a
	add a
	ld b, a
;> i = page4 + (wListCursor & 0x7F)
	ld a, [wListCursor]
	and $7f
	add b
;> q = addr(wSceneObjects) + i
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> slot = mem[q]
	ld a, [hl]
	push af
;> if mem[MonsterField(slot, wMonEgg)]:
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	jr z, .monster

;>     PrintSystemText(0x0B1D)
	pop af
	push af
	ld hl, $0b1d
	call PrintSystemText
;>     DrawBattleWindow(ResultEggListWindow)
	ld de, ResultEggListWindow
	call DrawBattleWindow
	jr .release

;> else:
;>@n     CopyName(MonsterField(slot, wMonName), addr(wTextArg0))
.monster:
	pop af
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
;=@n
	ld hl, wTextArg0
	call CopyName
;>     PrintSystemText(0x0B14)
	ld hl, $0b14
	call PrintSystemText

;> mem[MonsterField(slot, wMonsters)] = 0      # the record is free now
.release:
	pop af
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> RefreshStatusIcons()
	call RefreshStatusIcons
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> DrawBattleWindow(0x2E07)
	ld de, $2e07
	call DrawBattleWindow
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> wCommandStep = 21
	ld a, $15
	ld [wCommandStep], a
;> return
	ret


;@ def RecruitStep14()
;@ path: battle/recruit
;@ Once the text is done: asks whether the newcomer joins the party (system text $0B15) over its picture.
RecruitStep14::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> name = MonsterField(wNewMonSlot, wMonName)
	ld a, [wNewMonSlot]
	ld hl, wMonName
	call MonsterField
;> CopyName(name, addr(wTextArg0))
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;> PrintSystemText(0x0B15)
	ld hl, $0b15
	call PrintSystemText
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep15()
;@ path: battle/recruit
;@ Once the text is done: shows the yes/no window (cursor wMenuChoice3).
RecruitStep15::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> QueueSound(0x5C)
	ld a, $5c
	call QueueSound
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> DecompressVRAM(0x51, 0x12, 0x89C0)
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> DrawBattleWindow(ResultYesNoWindow)
	ld de, ResultYesNoWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(PartyFullYesNoSpots, wMenuChoice3)
	ld de, PartyFullYesNoSpots
	ld a, [wMenuChoice3]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep16()
;@ path: battle/recruit
;@ Join the party? B or "no": to the farm (step 17). "Yes": into the party (step 18).
RecruitStep16::
;> UpdateBattleMenuCursor(addr(wMenuChoice3), PartyFullYesNoSpots, 2)
	ld de, PartyFullYesNoSpots
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     wCommandStep += 1
.farm:
	ld hl, wCommandStep
	inc [hl]
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wMenuChoice3 == 0x81:        # "no"
	ld a, [wMenuChoice3]
	cp $81
;>         wCommandStep += 1           # the B case above
	jr z, .farm

;>     else:
;>         wCommandStep += 2
	ld hl, wCommandStep
	inc [hl]
	ld hl, wCommandStep
	inc [hl]
;>         wMenuChoice3 |= 0x80; wLinkRefused = 0
	ld hl, wMenuChoice3
	set 7, [hl]
	inc hl
	ld [hl], $00

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the yes/no window asking whether the newcomer joins the party (BG buffer offsets).
PartyFullYesNoSpots::
	dw $012f, $016f, $ffff

;@ def RecruitStep17()
;@ path: battle/recruit
;@ Once the text is done: the newcomer goes to the farm (system text $0B16); then step 30.
RecruitStep17::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> name = MonsterField(wNewMonSlot, wMonName)
	ld a, [wNewMonSlot]
	ld hl, wMonName
	call MonsterField
;> CopyName(name, addr(wTextArg0))
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;> PrintSystemText(0x0B16)
	ld hl, $0b16
	call PrintSystemText
;> wCommandStep = 30
	ld a, $1e
	ld [wCommandStep], a
;> return
	ret


;@ def FindFreeMonSlot() -> a
;@ path: battle/recruit
;@ Returns the first empty record slot (kind byte 0) of the 20, or 20 when all are taken.
;@ test: for i in range(20): mem[0xCAC1 + i * 0x95] = rand(0, 2)
FindFreeMonSlot::
;> slot = 0
	ld de, wMonsters
	ld b, $14
	ld c, $00

;>@s while slot < 20 and mem[addr(wMonsters) + slot * 0x95] != 0:
.loop:
	ld a, [de]
	or a
	jr z, .found

;>     slot += 1
	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
;=@s
	ld d, a
	dec b
	jr nz, .loop

;> return slot
.found:
	ld a, c
	ret


;@ def RecruitStep18()
;@ path: battle/recruit
;@ Once the text is done: with room in the party the newcomer joins it (step 30); with a full party,
;@ asks which monster it should replace (system text $0B18, step 19).
RecruitStep18::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> if wPartyCount != 3:
	ld a, [wPartyCount]
	cp $03
	jr z, .full

;>     q = addr(wParty) + wPartyCount
	ld a, [wPartyCount]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
;>     mem[q] = wNewMonSlot
	ld h, a
	ld a, [wNewMonSlot]
	ld [hl], a
;>     wPartyCount += 1
	ld hl, wPartyCount
	inc [hl]
;>     CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;>     wCommandStep = 30
	ld a, $1e
	ld [wCommandStep], a
;>     return
	ret

;> wCommandStep += 1
.full:
	ld hl, wCommandStep
	inc [hl]
;> PrintSystemText(0x0B18)
	ld hl, $0b18
	call PrintSystemText
;> DrawPartyFullMenu()
	call DrawPartyFullMenu
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def DrawPartyFullMenu()
;@ path: battle/recruit
;@ Draws the newcomer's picture with the yes/no window (cursor wMenuChoice3).
DrawPartyFullMenu::
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> DecompressVRAM(0x51, 0x12, 0x89C0)
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
;> DrawBattleWindow(ResultYesNoWindow)
	ld de, ResultYesNoWindow
	call DrawBattleWindow
;> DrawBattleCursorAt(PartyFullYesNoSpots, wMenuChoice3)
	ld de, PartyFullYesNoSpots
	ld a, [wMenuChoice3]
	call DrawBattleCursorAt
;> return
	ret


;@ def RecruitStep19()
;@ path: battle/recruit
;@ Once the text is done: lists the party and the newcomer to pick the one that goes to the farm.
RecruitStep19::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> ListPartyAndNewcomer()
	call ListPartyAndNewcomer
;> DrawPartySwapNames()
	call DrawPartySwapNames
;> DrawPartySwapList()
	call DrawPartySwapList
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def DrawPartySwapList()
;@ path: battle/recruit
;@ Draws the list window of the party and the newcomer with its cursor (wLinkRefused, used here as a
;@ menu cursor).
DrawPartySwapList::
;> LoadWindowLetters_10()                             # the title text tiles
	ld hl, far_LoadWindowLetters_10
	rst $10
;> DrawBattleWindow(ResultMonsterListWindow)
	ld de, ResultMonsterListWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(PartySwapSpots, wLinkRefused)
	ld de, PartySwapSpots
	ld a, [wLinkRefused]
	call DrawBattleCursorAt
;> return
	ret


;@ def DrawPartySwapNames()
;@ path: battle/recruit
;@ Draws the 4 names of the swap list (wSceneObjects) into the tiles from $88C0.
DrawPartySwapNames::
;> p, tiles = addr(wSceneObjects), 0x88C0
	ld de, wSceneObjects
	ld hl, $88c0
;>@n for i in range(4):
;>     p, tiles = DrawListNameTiles(p, tiles)
	call DrawListNameTiles
;=@n
	call DrawListNameTiles
	call DrawListNameTiles
	call DrawListNameTiles
;> return
	ret


;@ def ListPartyAndNewcomer()
;@ path: battle/recruit
;@ Writes the record slots of the party monsters and then the newcomer (wNewMonSlot) into the 4-entry
;@ list in wSceneObjects.
ListPartyAndNewcomer::
;> fill(wSceneObjects, 4, 0xFF)
	ld hl, wSceneObjects
	ld bc, $0004
	ld a, $ff
	call FillMemory
;> p = addr(wSceneObjects)
	ld hl, wSceneObjects
;> if wParty[0] != 0xFF: p = AppendToList(wParty[0], p)
	ld a, [wParty]
	cp $ff
	call nz, AppendToList
;> if wParty[1] != 0xFF: p = AppendToList(wParty[1], p)
	ld a, [$ca8f]
	cp $ff
	call nz, AppendToList
;> if wParty[2] != 0xFF: p = AppendToList(wParty[2], p)
	ld a, [$ca90]
	cp $ff
	call nz, AppendToList
;> AppendToList(wNewMonSlot, p)
	ld a, [wNewMonSlot]
	call AppendToList
;> return
	ret


;@ def AppendToList(v: a, p: hl) -> hl
;@ path: battle/recruit
;@ Stores `v` at `p` and returns p + 1.
AppendToList::
;> mem[p] = v
	ld [hli], a
;> return p + 1
	ret


;@ def RecruitStep20()
;@ path: battle/recruit
;@ The swap list: B goes back to the join-the-party question (step 14); A picks the monster (step 22).
RecruitStep20::
;> UpdateBattleMenuCursor(addr(wLinkRefused), PartySwapSpots, wPartyCount + 1)
	ld de, PartySwapSpots
	ld hl, wLinkRefused
	ld a, [wPartyCount]
	inc a
	ld b, a
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@b     wCommandStep -= 6
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
;=@b
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
;=@b
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wCommandStep += 2
	ld hl, wCommandStep
	inc [hl]
	ld hl, wCommandStep
	inc [hl]
;>     wLinkRefused |= 0x80; wLinkPartnerChoice = 0
	ld hl, wLinkRefused
	set 7, [hl]
	inc hl
	ld [hl], $00

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the swap list, one per row (BG buffer offsets, $FFFF ends).
PartySwapSpots::
	dw $00a1, $00e1, $0121, $0161, $ffff

;@ def RecruitStep21()
;@ path: battle/recruit
;@ Once the text is done: stores the newcomer in the first free record slot and prints
;@ "<species> joined" (system text $0B17); then on to naming it (step 35).
RecruitStep21::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wNewMonSlot = FindFreeMonSlot()
	call FindFreeMonSlot
	ld [wNewMonSlot], a
;> StoreRecruitedMonster(wNewMonSlot)
	call StoreRecruitedMonster
;> CopySystemText(0x0500 + wNewMonNameText, addr(wTextArg0))
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
;> AppendSexSymbol(mem[MonsterField(wNewMonSlot, wMonGender)], addr(wTextArg0))
	ld a, [wNewMonSlot]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg0
	call AppendSexSymbol
;> PrintSystemText(0x0B17)
	ld hl, $0b17
	call PrintSystemText
;> wCommandStep = 35
	ld a, $23
	ld [wCommandStep], a
;> return
	ret


;@ def RecruitStep22()
;@ path: battle/recruit
;@ Once the text is done: shows the two-choice window for the picked monster (look at it / send it to
;@ the farm).
RecruitStep22::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> DrawSwapConfirm()
	call DrawSwapConfirm
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def DrawSwapConfirm()
;@ path: battle/recruit
;@ Draws the two-choice window for the picked monster with its cursor (wLinkPartnerChoice).
DrawSwapConfirm::
;> DrawBattleWindow(ReleaseConfirmWindow)
	ld de, ReleaseConfirmWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(SwapYesNoSpots, wLinkPartnerChoice)
	ld de, SwapYesNoSpots
	ld a, [wLinkPartnerChoice]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep23()
;@ path: battle/recruit
;@ The two choices: B back to the swap list (step 20); the first shows the monster's status (step 27);
;@ the second sends it to the farm (step 24).
RecruitStep23::
;> UpdateBattleMenuCursor(addr(wLinkPartnerChoice), SwapYesNoSpots, 2)
	ld de, SwapYesNoSpots
	ld hl, wLinkPartnerChoice
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>@b     wCommandStep -= 3
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
;=@b
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     if wLinkPartnerChoice != 0x81:  # look at it
	ld a, [wLinkPartnerChoice]
	cp $81
	jr z, .send

;>         wFieldMenuState = 0; wFieldMenuStep = 0
	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
;>         wCommandStep = 27
	ld a, $1b
	ld [wCommandStep], a
	jr .done

;>     else:
;>         wCommandStep += 1
.send:
	ld hl, wCommandStep
	inc [hl]
;>         wLinkPartnerChoice |= 0x80; wListLastRows = 0
	ld hl, wLinkPartnerChoice
	set 7, [hl]
	inc hl
	ld [hl], $00

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the two-choice window for the picked monster (BG buffer offsets, $FFFF ends).
SwapYesNoSpots::
	dw $012e, $016e, $ffff

;@ def RecruitStep24()
;@ path: battle/recruit
;@ Once the text is done: the picked monster goes to the farm and the newcomer takes its place
;@ (system text $0B19); the party is rebuilt from the remaining list entries. Then the end (step 29).
RecruitStep24::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> q = addr(wSceneObjects) + (wLinkRefused & 0x7F)
	ld a, [wLinkRefused]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
;> name = MonsterField(mem[q], wMonName)
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wMonName
	call MonsterField
;> CopyName(name, addr(wTextArg0))
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
;> CopySystemText(0x0500 + wNewMonNameText, addr(wTextArg1))
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
;> PrintSystemText(0x0B19)
	ld hl, $0b19
	call PrintSystemText
;> DrawBattleWindow(0x2E07)
	ld de, $2e07
	call DrawBattleWindow
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> q = addr(wSceneObjects) + (wLinkRefused & 0x7F)
	ld a, [wLinkRefused]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
;> mem[q] = 0xFF
	adc h
	ld h, a
	ld [hl], $ff
;> p = AppendIfFilled(mem[addr(wSceneObjects)], addr(wParty))
	ld hl, wParty
	ld a, [wSceneObjects]
	call AppendIfFilled
;> p = AppendIfFilled(mem[addr(wSceneObjects) + 1], p)
	ld a, [$c0d9]
	call AppendIfFilled
;> p = AppendIfFilled(mem[addr(wSceneObjects) + 2], p)
	ld a, [$c0da]
	call AppendIfFilled
;> AppendIfFilled(mem[addr(wSceneObjects) + 3], p)
	ld a, [$c0db]
	call AppendIfFilled
;> CompactMonsters()
	ld hl, far_CompactMonsters
	rst $10
;> wCommandStep = 29
	ld a, $1d
	ld [wCommandStep], a
;> return
	ret


;@ def AppendIfFilled(v: a, p: hl) -> hl
;@ path: battle/recruit
;@ Stores `v` at `p` and returns p + 1, unless `v` is $FF (then returns p).
AppendIfFilled::
;> if v == 0xFF: return p
	cp $ff
	ret z

;> mem[p] = v
	ld [hli], a
;> return p + 1
	ret


;@ def RecruitStep25()
;@ path: battle/recruit
;@ Shows the status screen of the monster picked in the release list (ShowMonsterStatus, run each
;@ frame); when it closes, on to step 26.
RecruitStep25::
;> page4 = 4 * wListPage
	ld a, [wListPage]
	add a
	add a
	ld b, a
;> i = page4 + (wListCursor & 0x7F)
	ld a, [wListCursor]
	and $7f
	add b
;> q = addr(wSceneObjects) + i
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wCurPartyMember = mem[q]
	ld a, [hl]
	ld [wCurPartyMember], a
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep == 0: return
	ld a, [wMenuSubStep]
	or a
	ret z

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RecruitStep26()
;@ path: battle/recruit
;@ Back from the status screen opened from the release list: reloads the battle tiles, the window
;@ titles and the newcomer's picture, redraws the list and the two-choice window and returns to step 11.
RecruitStep26::
;>@g DecompressVRAM(0x5B, 0, 0x9600); DecompressVRAM(0x5B, 1, 0x8800)
	ld de, $5b00
	ld hl, $9600
	call DecompressVRAM
;=@g
	ld de, $5b01
	ld hl, $8800
	call DecompressVRAM
;> wTextIndex = 0x0A; wTextGroup = 0x0B
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x8820, 1, 10)
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
;> wTextIndex = 0x1B; wTextGroup = 0x0B
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x89C0, 1, 15)
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
;> LoadMonsterPic(wNewMonNameText, 0x9000)
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
;> CountMonstersOrEggs()
	call CountMonstersOrEggs
;> ListMonstersOrEggs()
	call ListMonstersOrEggs
;> DrawReleaseListPage()
	call DrawReleaseListPage
;>@p PrintSystemText(0x0B22 if wListCursor2 & 1 else 0x0B13)
	ld hl, $0b13
	ld a, [wListCursor2]
	and $01
	jr z, .print

	ld hl, $0b22

;=@p
.print:
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> RefreshIconsAndNames()
	call RefreshIconsAndNames
;> DrawMonsterEggChoice()
	call DrawMonsterEggChoice
;> DrawReleaseList()
	call DrawReleaseList
;> DrawReleaseConfirm()
	call DrawReleaseConfirm
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> wCommandStep = 11
	ld a, $0b
	ld [wCommandStep], a
;> return
	ret


;@ def RecruitStep27()
;@ path: battle/recruit
;@ Shows the status screen of the monster picked in the swap list; when it closes, on to step 28.
RecruitStep27::
;> q = addr(wSceneObjects) + (wLinkRefused & 0x7F)
	ld a, [wLinkRefused]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
;> wCurPartyMember = mem[q]
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
;> wMenuSubStep = 0
	xor a
	ld [wMenuSubStep], a
;> ShowMonsterStatus()
	ld hl, far_ShowMonsterStatus
	rst $10
;> if wMenuSubStep == 0: return
	ld a, [wMenuSubStep]
	or a
	ret z

;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RecruitStep28()
;@ path: battle/recruit
;@ Back from the status screen opened from the swap list: reloads the graphics, prints the swap question
;@ (system text $0B18) at once, redraws the swap list and its two-choice window and returns to step 23.
RecruitStep28::
;>@g DecompressVRAM(0x5B, 0, 0x9600); DecompressVRAM(0x5B, 1, 0x8800)
	ld de, $5b00
	ld hl, $9600
	call DecompressVRAM
;=@g
	ld de, $5b01
	ld hl, $8800
	call DecompressVRAM
;> wTextIndex = 0x0A; wTextGroup = 0x0B
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x8820, 1, 10)
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
;> wTextIndex = 0x1B; wTextGroup = 0x0B
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x89C0, 1, 15)
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
;> LoadMonsterPic(wNewMonNameText, 0x9000)
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
;> CountMonstersOrEggs()
	call CountMonstersOrEggs
;> ListMonstersOrEggs()
	call ListMonstersOrEggs
;> DrawReleaseListPage()
	call DrawReleaseListPage
;> PrintSystemText(0x0B18)
	ld hl, $0b18
	call PrintSystemText
;> RunTextToEnd()
	call RunTextToEnd
;> ReloadPartyBattlers()
	call ReloadPartyBattlers
;> RefreshStatusIcons()
	call RefreshStatusIcons
;> DrawPartyFullMenu()
	call DrawPartyFullMenu
;> ListPartyAndNewcomer()
	call ListPartyAndNewcomer
;> DrawPartySwapNames()
	call DrawPartySwapNames
;> DrawPartySwapList()
	call DrawPartySwapList
;> DrawSwapConfirm()
	call DrawSwapConfirm
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10
;> wCommandStep = 23
	ld a, $17
	ld [wCommandStep], a
;> return
	ret


;@ def RecruitStep29()
;@ path: battle/recruit
;@ The end (also step 30): once the text is done, reloads the party into the battle positions, redraws
;@ the screen and hands back to the after-battle sequence.
RecruitStep29::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> ReloadPartyBattlers()
	call ReloadPartyBattlers
;> RefreshStatusIcons()
	call RefreshStatusIcons
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> wCommandStep = 0
	xor a
	ld [wCommandStep], a
;> wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
;> return
	ret


;@ def RecruitStep31()
;@ path: battle/recruit
;@ Once the text is done: asks "monsters or eggs?" (system text $0B1A).
RecruitStep31::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> PrintSystemText(0x0B1A)
	ld hl, $0b1a
	call PrintSystemText
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RecruitStep32()
;@ path: battle/recruit
;@ Once the text is done: shows the monsters / eggs window.
RecruitStep32::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> RedrawMonsterEggChoice()
	call RedrawMonsterEggChoice
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RedrawMonsterEggChoice()
;@ path: battle/recruit
;@ Draws the newcomer's picture with the monsters / eggs window and its cursor (wListCursor2) and
;@ copies the buffer to the screen.
RedrawMonsterEggChoice::
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> DrawBattleWindow(MonsterEggWindow)
	ld de, MonsterEggWindow
	call DrawBattleWindow
;> ResetBattleCursorBlink()
	call ResetBattleCursorBlink
;> DrawBattleCursorAt(MonsterEggSpots, wListCursor2)
	ld de, MonsterEggSpots
	ld a, [wListCursor2]
	call DrawBattleCursorAt
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ def RecruitStep33()
;@ path: battle/recruit
;@ Monsters or eggs: B goes back to the release question (step 4); A opens the list of that kind
;@ (step 7).
RecruitStep33::
;> UpdateBattleMenuCursor(addr(wListCursor2), MonsterEggSpots, 2)
	ld de, MonsterEggSpots
	ld hl, wListCursor2
	ld b, $02
	call UpdateBattleMenuCursor
;> if wJoyPressed & 2:                 # B
	ld a, [wJoyPressed]
	bit 1, a
	jr z, .notB

;>     wCommandStep = 4
	ld a, $04
	ld [wCommandStep], a
	jr .done

;> elif wJoyPressed & 1:               # A
.notB:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, .done

;>     QueueSound(0x59)
	ld a, $59
	call QueueSound
;>     wListCursor = 0; wListPage = 0
	xor a
	ld [wListCursor], a
	ld [wListPage], a
;>     wCommandStep = 7
	ld a, $07
	ld [wCommandStep], a

;> return
.done:
	ret


;@ path: battle/recruit
;@ Cursor spots of the monsters / eggs window (BG buffer offsets, $FFFF ends).
MonsterEggSpots::
	dw $012f, $016f, $ffff

;@ def RecruitStep34()
;@ path: battle/recruit
;@ Once the text is done (no monster or egg of the chosen kind): back to the monsters / eggs choice
;@ (step 32) with system text $0B1A.
RecruitStep34::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> RedrawMonsterEggChoice()
	call RedrawMonsterEggChoice
;> wCommandStep = 32
	ld a, $20
	ld [wCommandStep], a
;> PrintSystemText(0x0B1A)
	ld hl, $0b1a
	call PrintSystemText
;> return
	ret


;@ def RecruitStep35()
;@ path: battle/recruit
;@ Once the text is done: prepares the name entry for the newcomer (the field's script menu $FF with
;@ its species, picture, sex and name address).
RecruitStep35::
;> if wTextState: return
	ld a, [wTextState]
	or a
	ret nz

;> wFieldFlags |= 0x10
	ld hl, wFieldFlags
	set 4, [hl]
;> wScriptMenu = 0xFF; wMenuStep = 0
	ld a, $ff
	ld [wScriptMenu], a
	xor a
	ld [wMenuStep], a
;> wChosenMonSpecies = wNewMonNameText
	ld a, [wNewMonNameText]
	ld [wChosenMonSpecies], a
;> wChosenMonPic = wNewMonNameText + 0x10
	add $10
	ld [wChosenMonPic], a
;> wChosenMonGender = mem[MonsterField(wNewMonSlot, wMonGender)]
	ld a, [wNewMonSlot]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
;>@n wChosenMonName = MonsterField(wNewMonSlot, wMonName)
	ld a, [wNewMonSlot]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
;=@n
	ld a, h
	ld [$c8f3], a
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;> return
	ret


;@ def RecruitStep36()
;@ path: battle/recruit
;@ Runs the name entry (with the menu variables swapped out) until it closes, then reloads the battle
;@ graphics and the party and goes on to the join-the-party question (step 14).
RecruitStep36::
;> SwapMenuVars()
	call SwapMenuVars
;> NameEntryMenu()
	ld hl, far_NameEntryMenu
	rst $10
;> SwapMenuVars()
	call SwapMenuVars
;> if wFieldFlags & 0x10: return       # still naming
	ld a, [wFieldFlags]
	bit 4, a
	ret nz

;> ClearBattleTilemap()
	call ClearBattleTilemap
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> ClearTextBoxTiles()                     # clears the text box
	ld hl, far_ClearTextBoxTiles
	rst $10
;> wCommandStep += 1
	ld hl, wCommandStep
	inc [hl]
;>@g DecompressVRAM(0x5B, 0, 0x9600); DecompressVRAM(0x5B, 1, 0x8800)
	ld de, $5b00
	ld hl, $9600
	call DecompressVRAM
;=@g
	ld de, $5b01
	ld hl, $8800
	call DecompressVRAM
;> wTextIndex = 0x0A; wTextGroup = 0x0B
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x8820, 1, 10)
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
;> wTextIndex = 0x1B; wTextGroup = 0x0B
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
;> PrintTextToTiles(0x89C0, 1, 15)
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
;> LoadMonsterPic(wNewMonNameText, 0x9000)
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
;> ReloadPartyBattlers()
	call ReloadPartyBattlers
;> RefreshStatusIcons()
	call RefreshStatusIcons
;> ClearBattleTilemap()
	call ClearBattleTilemap
;> DrawBattlePartyPanel()
	call DrawBattlePartyPanel
;> PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;> SetNewMonPicPalette(wNewMonNameText, 0x00C7)
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> wCommandStep = 14
	ld a, $0e
	ld [wCommandStep], a
;> return
	ret


;@ def SwapMenuVars()
;@ path: battle/recruit
;@ Swaps the 8 menu variables from wMenuChoice with the 8 bytes at wBattlerSexBits67, so the name entry
;@ can use them.
SwapMenuVars::
;> p = addr(wMenuChoice); q = addr(wBattlerSexBits67)
	ld hl, wMenuChoice
	ld de, wBattlerSexBits67
;>@i for i in range(8):
	ld b, $08

;>     mem[p + i], mem[q + i] = mem[q + i], mem[p + i]
.swap:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
;=@i
	dec b
	jr nz, .swap

;> return
	ret


;@ def AppendSexSymbol(sex: a, text: de)
;@ path: battle/recruit
;@ Adds the sex symbol ($A7 + bit 0 of `sex`) at the end ($F0) of the text at `text`.
AppendSexSymbol::
;> p = text
	push af

;> while mem[p] != 0xF0: p += 1
.find:
	ld a, [de]
	inc de
	cp $f0
	jr nz, .find

;>@s mem[p] = 0xA7 + (sex & 1); mem[p + 1] = 0xF0
	dec de
	pop af
	and $01
	add $a7
	ld [de], a
	inc de
;=@s
	ld a, $f0
	ld [de], a
;> return
	ret


;@ def StoreRecruitedMonster(slot: a)
;@ path: battle/recruit
;@ Copies the newcomer's record (record slot 20, at wBreedParent1) into record slot `slot` and marks its
;@ species as seen in the monster library.
StoreRecruitedMonster::
;> dest = MonsterField(slot, wMonsters)
	ld hl, wMonsters
	call MonsterField
;>@c for i in range(0x95):
	ld b, $95
	ld de, wBreedParent1

;>     mem[dest + i] = wBreedParent1[i]
.copy:
	ld a, [de]
	ld [hli], a
	inc de
;=@c
	dec b
	jr nz, .copy

;> SetFlag(wNewMonNameText, addr(wLibraryFlags))
	ld a, [wNewMonNameText]
	ld hl, wLibraryFlags
	call SetFlag
;> return
	ret


;@ def SetNewMonPicPalette(species: a, pos: hl)
;@ path: battle/recruit
;@ Loads the picture palette of `species` for the picture at buffer offset `pos`, in the palette slot
;@ of the enemy that asked to join (wJoinCandidate).
SetNewMonPicPalette::
;> wPaletteSet = species
	ld [wPaletteSet], a
;> wMonPicPos = pos
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [$c821], a
;> wMonPicPalette = wJoinCandidate
	ld a, [wJoinCandidate]
	ld [wMonPicPalette], a
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> return
	ret


;@ def SetBattlePicPalettes()
;@ path: battle/screen/pictures
;@ Loads the colour palettes of the monster pictures at the top of the battle screen: the enemies
;@ (positions 4-6), or in a link battle seen from the other side, the party (positions 0-2). One
;@ picture sits in the middle, two or three are spread out.
SetBattlePicPalettes::
;> if wLinkActive and wLinkFlags & 2:
	ld a, [wLinkActive]
	or a
	jr z, .enemies

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .enemies

;>     n = wPartyBattlers; first = 0
	ld a, [wPartyBattlers]
	ld c, $00
	jr .count

;> else:
;>     n = wEnemyCount; first = 4
.enemies:
	ld a, [wEnemyCount]
	ld c, $04

;> if n != 3 and n != 2:
.count:
	cp $03
	jr z, .three

	cp $02
	jr z, .two

;>     SetPicPalette(first, 0x00C7)
	ld a, c
	ld hl, $00c7
	call SetPicPalette
;>     return
	ret

;> if n == 2:
;>     SetPicPalette(first, 0x00C4)
.two:
	ld a, c
	ld hl, $00c4
	call SetPicPalette
;>     SetPicPalette(first + 1, 0x00CA)
	inc c
	ld a, c
	ld hl, $00ca
	call SetPicPalette
;>     return
	ret

;> SetPicPalette(first, 0x00C1)
.three:
	ld a, c
	ld hl, $00c1
	call SetPicPalette
;> SetPicPalette(first + 1, 0x00C7)
	inc c
	ld a, c
	ld hl, $00c7
	call SetPicPalette
;> SetPicPalette(first + 2, 0x00CD)
	inc c
	ld a, c
	ld hl, $00cd
	call SetPicPalette
;> return
	ret


;@ def SetPicPalette(pos: a, offset: hl)
;@ path: battle/screen/pictures
;@ Loads the palette of the monster at battle position `pos` (also passed in c) for its picture at
;@ buffer offset `offset`; the palette slot is 4 + (pos & 3).
SetPicPalette::
;> wMonPicPos = offset
	push bc
	push af
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [$c821], a
;>@s wPaletteSet = wBattlerSpecies[pos]
	pop af
	push af
	ld de, wBattlerSpecies
	add e
	ld e, a
	ld a, $00
;=@s
	adc d
	ld d, a
	ld a, [de]
	ld [wPaletteSet], a
;> GetCGBPicSpecies(pos)
	call GetCGBPicSpecies
;> wMonPicPalette = (pos & 3) + 4
	pop af
	and $03
	add $04
	ld [wMonPicPalette], a
;> LoadMonPicPalette()
	ld hl, far_LoadMonPicPalette
	rst $10
;> return
	pop bc
	ret


;@ def GetCGBPicSpecies(pos: c)
;@ path: battle/screen/pictures
;@ On a Game Boy Color, takes the palette species of position `pos` from the copy kept in WRAM bank 2
;@ (at the address of wSideFlags + pos) instead. This is done for the enemy positions 4-6, or in a
;@ link battle seen from the other side for the positions 0-2.
GetCGBPicSpecies::
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;> if wLinkActive and wLinkFlags & 2:
	ld a, [wLinkActive]
	or a
	jr z, .normal

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .normal

;>     if pos >= 3: return
	ld a, c
	cp $03
	jr nc, .done

	jr .read

;> elif pos < 4 or pos == 7: return
.normal:
	ld a, c
	cp $04
	jr c, .done

	cp $07
	jr z, .done

;> rSVBK = 2
.read:
	ld a, $02
	ldh [rSVBK], a
;>@r wPaletteSet = mem[addr(wSideFlags) + pos]          # in WRAM bank 2
	ld a, c
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
;=@r
	adc h
	ld h, a
	ld a, [hl]
	ld [wPaletteSet], a
;> rSVBK = 0
	ld a, $00
	ldh [rSVBK], a

;> return
.done:
	ret


;@ def RefreshIconsAndNames()
;@ path: battle/screen/panel
;@ Updates the status icons of the three party positions, clears the name tiles at $9700 (96 tiles
;@ worth of rows) and draws the names of the party monsters in battle into them.
RefreshIconsAndNames::
;> wSkillTarget = 0
	ld a, $00
	ld [wSkillTarget], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> wSkillTarget = 1
	ld a, $01
	ld [wSkillTarget], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> wSkillTarget = 2
	ld a, $02
	ld [wSkillTarget], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;>@c for i in range(0x60):
	ld hl, $9700
	ld b, $60

;>     WriteVRAMInc(0x9700 + 2*i, 0xFF); WriteVRAMInc(0x9701 + 2*i, 0x00)
.clear:
	ld a, $ff
	call WriteVRAMInc
	ld a, $00
	call WriteVRAMInc
;=@c
	dec b
	jr nz, .clear

;> if wPartyBattlers == 0: return
	ld a, [wPartyBattlers]
	or a
	ret z

;> DrawMonNameTiles(addr(wPartyBarTiles), 0x9700)
	ld de, wPartyBarTiles
	ld hl, $9700
	call DrawMonNameTiles
;> if wPartyBattlers == 1: return
	ld a, [wPartyBattlers]
	cp $01
	ret z

;> DrawMonNameTiles(addr(wShieldTarget), 0x9740)
	ld de, wShieldTarget
	ld hl, $9740
	call DrawMonNameTiles
;> if wPartyBattlers == 2: return
	ld a, [wPartyBattlers]
	cp $02
	ret z

;> DrawMonNameTiles(0xC1D0, 0x9780)
	ld de, $c1d0
	ld hl, $9780
	call DrawMonNameTiles
;> return
	ret


;@ def LoadMonsterPic(species: a, dest: hl)
;@ path: battle/screen/pictures
;@ Decompresses the picture of monster `species` to VRAM at `dest`; the compressed entry (bank and
;@ number) comes from the picture table at $2B9F in bank 0.
LoadMonsterPic::
;>@e entry = mem16[0x2B9F + 2*species]
	push de
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
;=@e
	add $9f
	ld l, a
	ld a, h
	adc $2b
	ld h, a
;=@e
	ld e, [hl]
	inc hl
	ld d, [hl]
;> DecompressVRAM(entry >> 8, entry & 0xFF, dest)
	pop hl
	call DecompressVRAM
;> return
	pop de
	ret


;@ def RefreshStatusIcons()
;@ path: battle/screen/panel
;@ Updates the status icons of the three party positions.
RefreshStatusIcons::
;> wSkillTarget = 0
	ld a, $00
	ld [wSkillTarget], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> wSkillTarget = 1
	ld a, $01
	ld [wSkillTarget], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> wSkillTarget = 2
	ld a, $02
	ld [wSkillTarget], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> return
	ret


;@ path: battle/screen/panel
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the party panel for three
;@ monsters: rows 0-5, 20 tiles wide, with the name tiles $70-$7B and position marks $DA-$DC, the
;@ "HP" ($E1) and "MP" ($E2) labels.
PanelWindow3::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $70, $71, $72, $73, $da, $e0, $74, $75
	db $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0
	db $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: battle/screen/panel
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the party panel for two
;@ monsters: rows 0-5, 14 tiles wide.
PanelWindow2::
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e2
	db $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/panel
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the party panel for one
;@ monster: rows 0-5, 8 tiles wide.
PanelWindow1::
	db $00, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e1, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 13, 13 x 5
;@ tiles.
UnusedWindow51_6BAE::
	db $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 13, 8 x 5 tiles.
UnusedWindow51_6BF6::
	db $a0, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $84, $9c
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 8, 6 x 3 tiles
;@ (one 4-tile name).
UnusedWindow51_6C25::
	db $00, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $6c, $6d, $6e, $6f, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 9, 11 x 9 tiles
;@ (three text lines).
UnusedWindow51_6C3C::
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $96, $88, $91, $8d, $87, $8a, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8b, $86, $94, $8a, $95, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $91, $8e, $89, $86, $90, $8e, $8c, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $96, $90, $8b, $8b, $91, $8f
	db $95, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 9, 12 x 9 tiles
;@ (four text lines).
UnusedWindow51_6CAA::
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $95, $96, $97, $98, $99
	db $9a, $9b, $9c, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a7
	db $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 11, 7 x 7 tiles
;@ (a title and two choices).
UnusedWindow51_6D21::
	db $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $85, $86, $87, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e0, $7e, $84, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $88, $87, $89, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 9, 7 x 9 tiles
;@ (a title and the three party names).
UnusedWindow51_6D5B::
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $85, $86, $87
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72
	db $73, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76
	db $77, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a
	db $7b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 9, 7 x 9 tiles
;@ (a title and the three party names).
UnusedWindow51_6DA5::
	db $20, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $86, $88, $87, $e0, $ff, $d8, $ec, $eb, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72, $73, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76, $77, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a, $7b, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 11, 13 x 7 tiles
;@ (three text lines).
UnusedWindow51_6DEF::
	db $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94
	db $95, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a0
	db $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 8, 6 x 5 tiles
;@ (two choices).
UnusedWindow51_6E53::
	db $00, $01, $fa, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $d4, $e0, $d5, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/levelup
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the skill list on the
;@ level-up screen when a skill must be forgotten: row 2, column 8, 12 x 9 tiles, four skill names
;@ (tiles $36-$59).
ForgetSkillListWindow::
	db $48, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $36
	db $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $3f, $40, $41, $42, $43, $44, $45
	db $46, $47, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $51, $52, $53
	db $54, $55, $56, $57, $58, $59, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of a yes / no choice: row 8,
;@ column 14, 6 x 5 tiles.
ResultYesNoWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9e
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/recruit
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the list of monsters to
;@ release when a monster wants to join: row 2, 7 x 11 tiles, a title and four names (tiles
;@ $8C-$9B).
ResultMonsterListWindow::
	db $40, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $82, $83, $84, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $90, $91, $92, $93, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $94, $95, $96, $97, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $98, $99, $9a, $9b, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9

;@ path: battle/recruit
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the release question's two
;@ choices: row 8, column 13, 7 x 5 tiles.
ReleaseConfirmWindow::
	db $0d, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $89, $8a, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 9, 7 x 9 tiles
;@ (a title and the three party names).
UnusedWindow51_6F98::
	db $20, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/levelup
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the three text lines under
;@ the skill list on the level-up screen: row 11, 20 x 7 tiles (tiles $00-$35).
ForgetSkillInfoWindow::
	db $60, $01, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
	db $10, $11, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $12, $13, $14, $15, $16, $17
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
	db $30, $31, $32, $33, $34, $35, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/levelup
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the MP cost of the skill
;@ under the cursor on the level-up screen: row 6, 9 x 5 tiles.
ForgetMPWindow::
	db $c0, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9c, $d6, $d5, $e0, $e2, $e3
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9

;@ path: battle/recruit
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the monsters / eggs choice:
;@ row 8, column 14, 6 x 5 tiles.
MonsterEggWindow::
	db $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a0, $a1, $a2, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a3, $a4, $a5, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/recruit
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the list of eggs to give
;@ up: row 4, 13 x 9 tiles, four lines (tiles $24-$4B).
ResultEggListWindow::
	db $80, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $24, $25, $26, $27, $28, $29, $2a, $2b
	db $2c, $48, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $49, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $4a, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $3f, $40, $41, $42
	db $43, $44, $45, $46, $47, $4b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/recruit
;@ Window layout (buffer offset word, tiles, $D8 next row, $D9 end) of the egg question's two
;@ choices: row 8, column 12, 8 x 5 tiles.
EggConfirmWindow::
	db $0c, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $a6, $a7, $a8, $a9, $aa, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $89, $8a, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 6, 6 x 3 tiles
;@ (one 4-tile name).
UnusedWindow51_717F::
	db $c0, $00, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $6c
	db $6d, $6e, $6f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 11, 7 x 7 tiles
;@ (three short lines).
UnusedWindow51_7196::
	db $60, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $89, $82, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $82, $86, $81, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $83, $8a, $85, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9

;@ path: battle/screen/windows
;@ Unused window layout (buffer offset word, tiles, $D8 next row, $D9 end) at row 9, 12 x 9 tiles
;@ (four text lines).
UnusedWindow51_71D0::
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2
	db $a3, $a4, $a5, $a6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

;@ def NextColumnWrapped(pos: hl) -> hl
;@ path: battle/screen/tilemap
;@ Steps `pos` one tile to the right inside its 32-tile row, wrapping from the last column to the
;@ first.
NextColumnWrapped::
;>@r return (pos & 0xFFE0) | ((pos + 1) & 0x1F)
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


;@ def BGMapAddress(offset: hl) -> hl
;@ path: battle/screen/tilemap
;@ Turns a buffer offset into an address on the battle BG map at wBattleBGMap, wrapping inside the
;@ 1 KiB map.
BGMapAddress::
;>@r s = wBattleBGMap + offset
	ld a, [wBattleBGMap]
	add l
	ld l, a
	ld a, [$d9f9]
	adc h
;>@m return (wBattleBGMap & 0xFC00) | (s & 0x03FF)
	and $03
	ld h, a
	ld a, [$d9f9]
	and $fc
	or h
	ld h, a
;=@m
	ret


;@ def BattleBufferAddress(offset: hl) -> hl
;@ path: battle/screen/tilemap
;@ Turns a buffer offset into an address in wTilemapBuffer.
BattleBufferAddress::
;>@b return addr(wTilemapBuffer) + offset
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@b
	ret


;@ def OffsetToBGAddress(offset: hl) -> hl
;@ path: battle/screen/tilemap
;@ Turns a buffer offset (row * 32 + column) into an address on the battle BG map, wrapping the row
;@ and the column.
OffsetToBGAddress::
;> pos = BGMapAddress(offset & 0xFFE0)
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call BGMapAddress
;>@c for i in range(offset & 0x1F):
	ld a, b
	and $1f
	jr z, .done

	ld b, a

;>     pos = NextColumnWrapped(pos)
.column:
	call NextColumnWrapped
;=@c
	dec b
	jr nz, .column

;> return pos
.done:
	pop bc
	ret

; Unused: a version of DrawBattleWindow that writes the window layout straight to the BG map
; (OffsetToBGAddress, then WriteVRAM and NextColumnWrapped per tile, $D8 next row, $D9 end).
	db $1a, $6f, $13, $1a, $67, $13, $cd, $73, $72, $7d, $ea, $ea, $d9, $7c, $ea, $eb
	db $d9, $1a, $13, $fe, $d9, $c8, $fe, $d8, $20, $20, $fa, $ea, $d9, $6f, $fa, $eb
	db $d9, $67, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67
	db $7d, $ea, $ea, $d9, $7c, $ea, $eb, $d9, $18, $d7, $cd, $ad, $1a, $cd, $47, $72
	db $18, $cf

;@ def DrawBattleWindow(layout: de)
;@ path: battle/screen/windows
;@ Draws a window layout into wTilemapBuffer: a word with the buffer offset, then the tiles, $D8 for
;@ the next row and $D9 for the end.
DrawBattleWindow::
;>@p p = BattleBufferAddress(mem16[layout]); layout += 2
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;=@p
	call BattleBufferAddress
;> wLayoutRow = p
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a

;> while True:
;>     t = mem[layout]; layout += 1
.loop:
	ld a, [de]
	inc de
;>     if t == 0xD9: return
	cp $d9
	ret z

;>     if t == 0xD8:
	cp $d8
	jr nz, .tile

;>@n         p = wLayoutRow + 0x20; wLayoutRow = p
	ld a, [wLayoutRow]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
	add $20
;=@n
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@n
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a
;>         continue
	jr .loop

;>     else:
;>         mem[p] = t; p += 1
.tile:
	ld [hli], a
	jr .loop

; Unused: redraws three tiles of each party position (columns $25/$2B/$31 and $62/$68/$6E, two rows)
; from wTilemapBuffer straight to the BG map.
	db $fa, $74, $db, $4f, $fa, $63, $c8, $cb, $4f, $28, $04, $fa, $75, $db, $4f, $c5
	db $06, $25, $0e, $62, $cd, $32, $73, $c1, $0d, $c8, $c5, $06, $2b, $0e, $68, $cd
	db $32, $73, $c1, $0d, $c8, $c5, $06, $31, $0e, $6e, $cd, $32, $73, $c1, $c9, $68
	db $26, $98, $78, $11, $00, $c5, $83, $5f, $3e, $00, $8a, $57, $1a, $cd, $ad, $1a
	db $06, $03, $69, $26, $98, $79, $11, $00, $c5, $83, $5f, $3e, $00, $8a, $57, $cd
	db $8e, $73, $06, $03, $79, $c6, $20, $6f, $26, $98, $11, $00, $c5, $83, $5f, $3e
	db $00, $8a, $57, $cd, $8e, $73, $c9

;@ def CopyTilemapBufferToBG()
;@ path: battle/screen/tilemap
;@ Copies the 18 rows of wTilemapBuffer to the battle BG map at wBattleBGMap, wrapping inside the
;@ map at $9800.
CopyTilemapBufferToBG::
;> p = wBattleBGMap; src = addr(wTilemapBuffer)
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [$d9f9]
	ld h, a
	ld de, wTilemapBuffer
;>@r for row in range(18):
	ld c, $12

;>     src = CopyTilemapRow(src, p, 32)
.row:
	ld b, $20
	push hl
	call CopyTilemapRow
	pop hl
;>@w     p = ((p + 0x20) & 0x03FF) | 0x9800
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
;=@w
	ld h, a
	pop bc
;=@r
	dec c
	jr nz, .row

;> return
	ret


;@ def CopyTilemapRow(src: de, pos: hl, count: b) -> de
;@ path: battle/screen/tilemap
;@ Copies `count` tiles from `src` to VRAM at `pos`, wrapping inside the 32-tile row.
CopyTilemapRow::
;>@l for i in range(count):
;>     WriteVRAM(mem[src], pos)
	ld a, [de]
	call WriteVRAM
;>@x     pos = (pos & 0xFFE0) | ((pos + 1) & 0x1F)
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
;=@x
	ld l, a
	pop af
	or l
	ld l, a
;>     src += 1
	inc de
;=@l
	dec b
	jr nz, CopyTilemapRow

;> return src
	ret


;@ def PrintTextToTiles(dest: hl, lines: e, length: d)
;@ path: battle/screen/text
;@ Prints text wTextGroup / wTextIndex as tiles at `dest` (`lines` lines of `length` tiles), keeping the
;@ current text-tile settings.
PrintTextToTiles::
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
;> saved_lines = wTextBoxLines
	ld a, [wTextBoxLines]
	ld c, a
;> saved_length = wTextBoxLineLength
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = dest
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
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
	ld [$c828], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
;> return
	ret


;@ def DrawMonNameTiles(name: de, dest: hl)
;@ path: battle/screen/text
;@ Prints the 4-letter name at `name` as tiles at `dest` (one line of 4 tiles), keeping the current
;@ text-tile settings.
DrawMonNameTiles::
;> CopyName(name, addr(wTextArg0))
	push hl
	ld hl, wTextArg0
	call CopyName
	pop hl
;> saved_tiles = wTextTiles
	ld a, [wTextTiles]
	ld c, a
	ld a, [$c828]
	ld b, a
	push bc
;> saved_lines = wTextBoxLines
	ld a, [wTextBoxLines]
	ld c, a
;> saved_length = wTextBoxLineLength
	ld a, [wTextBoxLineLength]
	ld b, a
	push bc
;> wTextTiles = dest
	ld a, l
	ld [wTextTiles], a
	ld a, h
	ld [$c828], a
;> wTextBoxLines = 1
	ld de, $0401
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = 4
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
	ld [$c828], a
;> wTextBoxLines = saved_lines
	ld a, e
	ld [wTextBoxLines], a
;> wTextBoxLineLength = saved_length
	ld a, d
	ld [wTextBoxLineLength], a
;> return
	ret


;@ def ClearBattleTilemap()
;@ path: battle/screen/tilemap
;@ Fills wTilemapBuffer ($240 tiles) with the blank tile $E0.
ClearBattleTilemap::
;>@c for i in range(0x240):
	ld hl, wTilemapBuffer
	ld bc, $0240

;>     wTilemapBuffer[i] = 0xE0
.loop:
	ld a, $e0
	ld [hli], a
;=@c
	dec bc
	ld a, b
	or c
	jr nz, .loop

;> return
	ret


;@ def ClearBGMap()
;@ path: battle/screen/tilemap
;@ Fills the BG map at $9800 ($400 tiles) with the blank tile $E0.
ClearBGMap::
;>@c for i in range(0x400):
	ld hl, $9800
	ld bc, $0400

;>     WriteVRAMInc(0xE0, 0x9800 + i)
.loop:
	ld a, $e0
	call WriteVRAMInc
;=@c
	dec bc
	ld a, b
	or c
	jr nz, .loop

;> return
	ret


;@ def UpdatePagedCursor(cursor: hl, spots: de, count: c, rows: b)
;@ path: battle/screen/cursor
;@ Moves the cursor of a paged list of `count` entries with `rows` rows per page: mem[cursor] is the
;@ row, mem[cursor + 1] the page. Left / right turn the page (wrapping, keeping the row inside the
;@ last page); otherwise the page number is drawn and up / down / A are handled like a plain menu
;@ with as many rows as the page holds. The first spot of `spots` is the page-number spot.
;@ test: skip draws to VRAM
UpdatePagedCursor::
;> wListLastRows = count
	ld a, c
	ld [wListLastRows], a
;> spots += 2; page = -1
	inc de
	inc de
;> if wTextState == 0 and wJoyRepeat & 0x20:                # left: previous page
	ld a, [wTextState]
	or a
	jp nz, .draw

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, .right

;>     page = mem[cursor + 1] - 1
	inc hl
	ld a, [hl]
	dec a
;>@a     pages = (count - 1) // rows + 1
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
;=@a
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>     if page >= pages: page = pages - 1                    # wraps to the last page
	pop af
	cp c
	jr c, .store

	ld a, c
	dec a
	jr .store

;> elif wTextState == 0 and wJoyRepeat & 0x10:              # right: next page
.right:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, .draw

;>     page = mem[cursor + 1] + 1
	inc hl
	ld a, [hl]
	inc a
;>@b     pages = (count - 1) // rows + 1
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
;=@b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
;>     if page >= pages: page = 0                            # wraps to the first page
	pop af
	cp c
	jr c, .store

	ld a, $00

;> if page >= 0:
;>     mem[cursor + 1] = page
.store:
	ld [hld], a
;>     if page == pages - 1:
	dec c
	cp c
	jr nz, FinishCursorMove

;>@l         left = wListLastRows % rows                     # entries on the last page
	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
;=@l
	call Divide8
	pop bc
	pop de
;>         if left and left - 1 < mem[cursor]:
	or a
	jr z, FinishCursorMove

	dec a
	cp [hl]
	jr nc, FinishCursorMove

;>             mem[cursor] = left - 1
	ld [hl], a
;>     return FinishCursorMove(cursor, spots)
	jr FinishCursorMove

;> DrawBattlePageNumber(cursor, spots, count, rows)
.draw:
	push bc
	push de
	push hl
	call DrawBattlePageNumber
	pop hl
	pop de
;>@d last = (count - 1) // rows; wListLastRows = (count - 1) % rows
	pop bc
	push de
	push bc
	ld a, b
	ld b, c
	dec b
;=@d
	call Divide8
	ld [wListLastRows], a
	ld a, b
	pop bc
	pop de
	ld c, a
;> if mem[cursor + 1] == last:
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateBattleMenuCursor

;>     rows = wListLastRows + 1
	ld a, [wListLastRows]
	inc a
	ld b, a

;> return UpdateBattleMenuCursor(cursor, spots, rows)

;@ def UpdateBattleMenuCursor(cursor: hl, spots: de, n: b)
;@ path: battle/screen/cursor
;@ Moves the cursor mem[cursor] of a menu with `n` rows on up / down (wrapping), sets bit 7 when A is
;@ pressed and draws the cursor at the menu's spots.
;@ test: skip draws to VRAM
UpdateBattleMenuCursor::
;> mem[cursor] &= 0x7F
	res 7, [hl]
;> if wJoyRepeat & 0x40:                                    # up
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, .down

;>     row = mem[cursor] - 1
	ld a, [hl]
	dec a
;>     if row >= n: row = n - 1
	cp b
	jr c, .store

	dec b
	ld a, b
	jr .store

;> elif wJoyRepeat & 0x80:                                  # down
.down:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, ConfirmCursorChoice

;>     row = mem[cursor] + 1
	ld a, [hl]
	inc a
;>     if row >= n: row = 0
	cp b
	jr c, .store

	ld a, $00

;> else:
;>     return ConfirmCursorChoice(cursor, spots)
;> mem[cursor] = row
.store:
	ld [hl], a

;> return FinishCursorMove(cursor, spots)

;@ def FinishCursorMove(cursor: hl, spots: de)
;@ path: battle/screen/cursor
;@ After the cursor moved: restarts the blink so the cursor shows at once, then goes on to
;@ ConfirmCursorChoice.
;@ test: skip draws to VRAM
FinishCursorMove::
;> wCursorBlinkTimer = 0
	xor a
	ld [wCursorBlinkTimer], a
	push hl
	push de
	pop de
	pop hl

;> return ConfirmCursorChoice(cursor, spots)

;@ def ConfirmCursorChoice(cursor: hl, spots: de)
;@ path: battle/screen/cursor
;@ Sets bit 7 of mem[cursor] when A is pressed, then draws the cursor at the menu's spots.
;@ test: skip draws to VRAM
ConfirmCursorChoice::
;> if wJoyPressed & 1:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, .draw

;>     mem[cursor] |= 0x80
	set 7, [hl]

;> DrawBattleMenuCursor(mem[cursor], spots)
.draw:
	ld a, [hl]
	call DrawBattleMenuCursor
;> return
	ret

; Unused: cursor movement for a 2 x 2 grid (up / down flip bit 0, left / right flip bit 1).
	db $cb, $be, $fa, $47, $c8, $e6, $c0, $28, $05, $7e, $ee, $01, $18, $db, $fa, $47
	db $c8, $e6, $30, $28, $dd, $7e, $ee, $02, $18, $cf

;@ def ResetBattleCursorBlink()
;@ path: battle/screen/cursor
;@ Restarts the cursor blink so the cursor shows at once.
ResetBattleCursorBlink::
;> wCursorBlinkTimer = 0
	xor a
	ld [wCursorBlinkTimer], a
;> return
	ret


;@ def DrawBattleMenuCursor(cursor: a, spots: de)
;@ path: battle/screen/cursor
;@ Draws the cursor at every spot of `spots` (blank tile $E0 at the others) on the BG map and in
;@ wTilemapBuffer: $E9 when chosen (bit 7), otherwise $E8 blinking every 16 frames. While nothing
;@ was chosen the spots are only redrawn every 16th call.
;@ test: skip draws to VRAM
DrawBattleMenuCursor::
;> if not cursor & 0x80:
	ld c, a
	bit 7, a
	jr nz, .draw

;>     t = wCursorBlinkTimer & 0x0F
	ld a, [wCursorBlinkTimer]
	and $0f
;>     wCursorBlinkTimer += 1
	push af
	ld a, [wCursorBlinkTimer]
	inc a
	ld [wCursorBlinkTimer], a
;>     if t: return
	pop af
	ld a, c
	ret nz

;> i = 0
.draw:
	ld c, a
	ld b, $00

;> while True:
;>     pos = mem16[spots]; spots += 2
.loop:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
;>     if pos & 0xFF == 0xFF and pos >> 8 == 0xFF: return
	and l
	cp $ff
	ret z

;>     wLayoutRow = pos
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a
;>     bg = OffsetToBGAddress(pos)
	push de
	push bc
	call OffsetToBGAddress
	pop bc
	pop de
;>     if cursor & 0x7F != i: tile = 0xE0
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, .put

;>     elif cursor & 0x80: tile = 0xE9
	ld a, $e9
	bit 7, c
	jr nz, .put

;>     elif wCursorBlinkTimer & 0x10: tile = 0xE0
	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, .put

;>     else: tile = 0xE8
	ld a, $e8

;>     WriteVRAM(tile, bg)
.put:
	call WriteVRAM
;>@b     wTilemapBuffer[wLayoutRow] = tile
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
;>     i += 1
	inc b
	jr .loop

;@ def DrawBattlePageNumber(cursor: hl, spots: de, count: c, rows: b)
;@ path: battle/screen/cursor
;@ When the list has more than one page, draws the page number (tile $F1 + page) left of the
;@ page-number spot (the word before `spots`), on the BG map and in wTilemapBuffer.
;@ test: skip draws to VRAM
DrawBattlePageNumber::
;> if rows >= count: return
	ld a, b
	cp c
	ret nc

;> page = mem[cursor + 1]
	inc hl
	ld c, [hl]
;>@s pos = mem16[spots - 2]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
;=@s
	ld h, a
	inc de
;> if pos == 0xFFFF: return
	and l
	cp $ff
	ret z

;> hNumber = pos - 1
	dec hl
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
;> bg = OffsetToBGAddress(pos - 1)
	push de
	push bc
	call OffsetToBGAddress
	pop bc
	pop de
;> tile = (page & 0x7F) + 0xF1
	ld a, c
	and $7f
	add $f1
;> WriteVRAM(tile, bg)
	call WriteVRAM
;>@b wTilemapBuffer[hNumber] = tile
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
;> return
	ret


;@ def DrawPagedCursor(cursor: hl, spots: de, count: c, rows: b)
;@ path: battle/screen/cursor
;@ Draws the cursor of a paged list into wTilemapBuffer: at the page-number spot (first word of
;@ `spots`) tile $E7 with the page number ($F1 + page) to its left when there is more than one page,
;@ else tile $EE; then the row cursor via DrawBattleCursorAt.
DrawPagedCursor::
;> row = mem[cursor]
	ld a, [hli]
	push af
	push hl
;>@p p = BattleBufferAddress(mem16[spots]); spots += 2
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
;> mem[p] = 0xE7 if rows < count else 0xEE
	ld a, b
	cp c
	ld a, $ee
	jr nc, .mark

	ld a, $e7

.mark:
	ld [hld], a
;> if rows < count:
	pop bc
	jr nc, .row

;>     mem[p - 1] = mem[cursor + 1] + 0xF1
	ld a, [bc]
	add $f1
	ld [hl], a

;> return DrawBattleCursorAt(spots, row)
.row:
	pop af

;@ def DrawBattleCursorAt(spots: de, index: a)
;@ path: battle/screen/cursor
;@ Puts the cursor tile at spot `index` & $7F of `spots` in wTilemapBuffer: $E9 when chosen (bit 7),
;@ otherwise $E8 or blank $E0 by the blink timer.
DrawBattleCursorAt::
;>@p pos = mem16[spots + 2*(index & 0x7F)]
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
;=@p
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;> wLayoutRow = pos
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a
;> OffsetToBGAddress(pos)                                  # result not used
	push de
	push bc
	call OffsetToBGAddress
	pop bc
	pop de
;> if index & 0x80: tile = 0xE9
	ld a, $e9
	bit 7, c
	jr nz, .put

;> elif wCursorBlinkTimer & 0x10: tile = 0xE0
	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, .put

;> else: tile = 0xE8
	ld a, $e8

;>@b wTilemapBuffer[wLayoutRow] = tile
.put:
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
;=@b
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
;=@b
	ld [hl], a
;> return
	ret


;@ def PlaceEnemyPics()
;@ path: battle/screen/pictures
;@ Puts the tiles of the enemy pictures (or in a link battle seen from the other side, the party's)
;@ into wTilemapBuffer: one in the middle, two or three spread out. All use tiles from $00 on.
PlaceEnemyPics::
;> if wLinkActive and wLinkFlags & 2:
	ld a, [wLinkActive]
	or a
	jr z, .enemies

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .enemies

;>     n = wPartyBattlers
	ld a, [wPartyBattlers]
	jr .count

;> else:
;>     n = wEnemyCount
.enemies:
	ld a, [wEnemyCount]

;> if n != 3 and n != 2:
.count:
	cp $03
	jr z, .three

	cp $02
	jr z, .two

;>     PlacePicTiles(0, 0x00C7)
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
;>     return
	ret

;> if n == 2:
;>     t = PlacePicTiles(0, 0x00C4)
.two:
	ld a, $00
	ld hl, $00c4
	call PlacePicTiles
;>     PlacePicTiles(t, 0x00CA)
	ld hl, $00ca
	call PlacePicTiles
;>     return
	ret

;> t = PlacePicTiles(0, 0x00C1)
.three:
	ld a, $00
	ld hl, $00c1
	call PlacePicTiles
;> t = PlacePicTiles(t, 0x00C7)
	ld hl, $00c7
	call PlacePicTiles
;> PlacePicTiles(t, 0x00CD)
	ld hl, $00cd
	call PlacePicTiles
;> return
	ret


;@ def PlacePicTiles(tile: a, offset: hl) -> a
;@ path: battle/screen/pictures
;@ Puts a 6 x 6 block of consecutive tiles starting at `tile` into wTilemapBuffer at `offset`;
;@ returns the tile after the last one.
PlacePicTiles::
;>@r for row in range(6):
	ld c, $06

;>@p     p = BattleBufferAddress(offset + 0x20*row)
.row:
	push hl
	push af
	call BattleBufferAddress
	pop af
;>@c     for col in range(6):
	ld b, $06

;>         mem[p + col] = tile; tile += 1
.column:
	ld [hli], a
	inc a
;=@c
	dec b
	jr nz, .column

;=@p
	pop hl
	ld de, $0020
	add hl, de
;=@r
	dec c
	jr nz, .row

;> return tile
	ret


;@ def DrawBattlePartyPanel()
;@ path: battle/screen/panel
;@ Draws the message window and the party panel at the bottom of the battle screen into
;@ wTilemapBuffer: with HP / MP numbers (wPanelMode 0) or with levels and ailment icons.
DrawBattlePartyPanel::
;> DrawBattleWindow(MessageWindowLayout)
	ld de, $2e07
	call DrawBattleWindow
;> if wPanelMode: return DrawPanelLevels(wPanelMode)
	ld a, [wPanelMode]
	or a
	jp nz, DrawPanelLevels

;> return DrawPartyHPMP()

;@ def DrawPartyHPMP()
;@ path: battle/screen/panel
;@ Draws the party panel frame with the HP and MP of the monsters in battle (unless the party is
;@ empty outside a link battle).
DrawPartyHPMP::
;> if not wLinkActive and wPartyCount == 0: return
	ld a, [wLinkActive]
	or a
	jr nz, .draw

	ld a, [wPartyCount]
	or a
	ret z

;> DrawPartyPanelFrame()
.draw:
	call DrawPartyPanelFrame
;> return DrawPanelHPMPNumbers()
	jr DrawPanelHPMPNumbers

;@ def DrawPartyPanelFrame()
;@ path: battle/screen/panel
;@ Draws the panel window for 1-3 monsters (PanelWindowTable by wPartyBattlers, or by wEnemyCount in a
;@ link battle seen from the other side) into wTilemapBuffer.
DrawPartyPanelFrame::
;> if wLinkFlags & 2: n = wEnemyCount
	ld hl, PanelWindowTable
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .party

	ld a, [wEnemyCount]
	jr .draw

;> else: n = wPartyBattlers
.party:
	ld a, [wPartyBattlers]

;>@w DrawBattleWindow(mem16[PanelWindowTable + 2*n])
.draw:
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@w
	ld e, [hl]
	inc hl
	ld d, [hl]
	call DrawBattleWindow
;> return
	ret


;@ def DrawPanelHPMPNumbers()
;@ path: battle/screen/panel
;@ Prints the HP and MP of the panel's monsters (positions 0-2, or 4-6 in a link battle seen from the
;@ other side) as 3 digits into wTilemapBuffer, as many as wPanelCount.
DrawPanelHPMPNumbers::
;> side = 4 if wLinkFlags & 2 else 0
	ld hl, wBattlerHP
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .first

	ld hl, $dbab

;>@h PrintNumber3(BattleBufferAddress(0x62), mem16[addr(wBattlerHP) + 2*side])
.first:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0062
	call BattleBufferAddress
;=@h
	call PrintNumber3
;>@m PrintNumber3(BattleBufferAddress(0x82), mem16[addr(wBattlerMP) + 2*side])
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@m
	ld hl, $0082
	call BattleBufferAddress
	call PrintNumber3
;> if wPanelCount == 1: return
	ld a, [wPanelCount]
	cp $01
	ret z

;> side = 4 if wLinkFlags & 2 else 0
	ld hl, $dba5
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .second

	ld hl, $dbad

;>@h2 PrintNumber3(BattleBufferAddress(0x68), mem16[addr(wBattlerHP) + 2*side + 2])
.second:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0068
	call BattleBufferAddress
;=@h2
	call PrintNumber3
;>@m2 PrintNumber3(BattleBufferAddress(0x88), mem16[addr(wBattlerMP) + 2*side + 2])
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@m2
	ld hl, $0088
	call BattleBufferAddress
	call PrintNumber3
;> if wPanelCount == 2: return
	ld a, [wPanelCount]
	cp $02
	ret z

;> side = 4 if wLinkFlags & 2 else 0
	ld hl, $dba7
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .third

	ld hl, $dbaf

;>@h3 PrintNumber3(BattleBufferAddress(0x6E), mem16[addr(wBattlerHP) + 2*side + 4])
.third:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $006e
	call BattleBufferAddress
;=@h3
	call PrintNumber3
;>@m3 PrintNumber3(BattleBufferAddress(0x8E), mem16[addr(wBattlerMP) + 2*side + 4])
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@m3
	ld hl, $008e
	call BattleBufferAddress
	call PrintNumber3
;> return
	ret


;@ path: battle/screen/panel
;@ Unused: the entry points of DrawPanelHPMPNumbers for the first, second and third monster.
UnusedPanelJumps::
	dw DrawPanelHPMPNumbers, $76f2, $7723

;@ path: battle/screen/panel
;@ The panel window by number of monsters (0 and 1 share the one-monster panel).
PanelWindowTable::
	dw PanelWindow1, PanelWindow1, PanelWindow2, PanelWindow3

;@ def DrawPanelLevels(mode: a)
;@ path: battle/screen/panel
;@ The panel with levels instead of HP / MP. Mode 1 draws the frame, an "absent" mark for monsters
;@ out of the fight and the "Lv" tiles, copies them to the screen, loads the ailment icon tiles and
;@ moves on to mode 2; modes 1 and 2 then print the levels and the ailment icons. Mode 3 turns the
;@ panel back: the position marks and HP / MP labels, fresh status icons, then the HP / MP numbers
;@ (mode 0).
DrawPanelLevels::
;> if mode != 3:
	cp $03
	jp z, .restore

;>     DrawPartyPanelFrame()
	call DrawPartyPanelFrame
;>     wBattleBGMap = 0x9800
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
;>@d     side = 4 if wLinkFlags & 2 else 0
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .marks

;=@d
	ld c, $04

;>@k     for pos in range(side, side + wPanelCount):
;>         p = PanelSlotAddress(PanelMarkSpots, pos)
.marks:
	ld hl, PanelMarkSpots
	call PanelSlotAddress
;>@x         mem[p] = 0xD9 if CheckBattlerPresent(pos) else 0xE0       # carry: out of the fight
	push hl
	ld a, c
	call CheckBattlerPresent
	jr nc, .present

;=@x
	ld a, $d9
	jr .mark

.present:
	ld a, $e0

.mark:
	pop hl
	ld [hl], a
;>         q = PanelSlotAddress(PanelLevelSpots, pos)
	ld hl, PanelLevelSpots
	call PanelSlotAddress
;>         mem[q] = 0xDE; mem[q + 1] = 0xE4
	ld [hl], $de
	inc hl
	ld a, $e4
	ld [hld], a
;>         q += 0x20
	ld a, $20
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>         mem[q] = 0xE0; mem[q + 1] = 0xE0
	ld a, $e0
	ld [hli], a
	ld [hli], a
;>         mem[q + 2] = 0xE0; mem[q + 3] = 0xE0
	ld [hli], a
	ld [hl], a
;=@k
	inc c
	dec b
	jr nz, .marks

;>     if wPanelMode != 2:
	ld a, [wPanelMode]
	cp $02
	jr z, .levels

;>         CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;>         LoadStatusIconTiles(2, 0x8DA0)
	ld hl, $8da0
	ld a, $02
	call LoadStatusIconTiles
;>         LoadStatusIconTiles(4, 0x8DB0)
	ld hl, $8db0
	ld a, $04
	call LoadStatusIconTiles
;>         LoadStatusIconTiles(6, 0x8DC0)
	ld hl, $8dc0
	ld a, $06
	call LoadStatusIconTiles
;>         LoadStatusIconTiles(3, 0x8DD0)
	ld hl, $8dd0
	ld a, $03
	call LoadStatusIconTiles
;>         wPanelMode += 1
	ld hl, wPanelMode
	inc [hl]

;>@e     side = 4 if wLinkFlags & 2 else 0
.levels:
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .level

;=@e
	ld c, $04

;>@l     for pos in range(side, side + wPanelCount):
;>         q = PanelSlotAddress(PanelLevelSpots, pos) + 2
.level:
	ld hl, PanelLevelSpots
	call PanelSlotAddress
	inc hl
	inc hl
;>@n         PrintNumber2(q, wBattlerLevel[pos])
	push bc
	ld a, c
	ld bc, wBattlerLevel
	add c
	ld c, a
	ld a, $00
;=@n
	adc b
	ld b, a
	ld a, [bc]
	ld c, a
	ld b, $00
	call PrintNumber2
;>         if not CheckBattlerPresent(pos):
	pop bc
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>             d = PanelSlotAddress(PanelAilmentSpots, pos)
	ld hl, PanelAilmentSpots
	call PanelSlotAddress
;>             s = wBattlerStatus[8*pos]
	push hl
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	pop de
;>             if s:
	ld a, [hl]
	or a
	jr z, .next

;>                 if s & 0x40: PutAilmentIcon(0, d)
	bit 6, [hl]
	jr z, .bit5

	ld a, $00
	call PutAilmentIcon

;>                 if s & 0x20: PutAilmentIcon(1, d + 1)
.bit5:
	inc de
	bit 5, [hl]
	jr z, .bit4

	ld a, $01
	call PutAilmentIcon

;>                 if s & 0x10: PutAilmentIcon(2, d + 2)
.bit4:
	inc de
	bit 4, [hl]
	jr z, .bit7

	ld a, $02
	call PutAilmentIcon

;>                 if s & 0x80: PutAilmentIcon(3, d + 3)
.bit7:
	inc de
	bit 7, [hl]
	jr z, .bit1

	ld a, $03
	call PutAilmentIcon

;>                 if s & 0x02: PutAilmentIcon(4, d + 4)
.bit1:
	inc de
	bit 1, [hl]
	jr z, .bit0

	ld a, $04
	call PutAilmentIcon

;>                 if s & 0x01: PutAilmentIcon(5, d + 4)
.bit0:
	bit 0, [hl]
	jr z, .next

	ld a, $05
	call PutAilmentIcon

.next:
;=@l
	inc c
	dec b
	jr nz, .level

;>     CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;>     return
	ret

;>@f side = 4 if wLinkFlags & 2 else 0          # mode 3: turn the panel back
.restore:
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, .slot

;=@f
	ld c, $04

;>@s for pos in range(side, side + wPanelCount):
;>     mem[PanelSlotAddress(PanelMarkSpots, pos)] = 0xDA + (pos & 3)
.slot:
	ld hl, PanelMarkSpots
	call PanelSlotAddress
	ld a, c
	and $03
	add $da
	ld [hl], a
;>     q = PanelSlotAddress(PanelLevelSpots, pos); mem[q] = 0xE1
	ld hl, PanelLevelSpots
	call PanelSlotAddress
	ld [hl], $e1
;>     q += 0x20
	ld a, $20
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>     mem[q] = 0xE2; mem[q + 1] = 0xE0
	ld a, $e2
	ld [hli], a
	ld a, $e0
	ld [hli], a
;>     mem[q + 2] = 0xE0; mem[q + 3] = 0xE0
	ld [hli], a
	ld [hl], a
;>     wSkillUser = pos; wSkillTarget = pos
	ld a, c
	ld [wSkillUser], a
	ld [wSkillTarget], a
;>@i     wStatusIconShown[pos] = 0xFF
	push af
	push bc
	push de
	push hl
	ld hl, wStatusIconShown
	add l
;=@i
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
;>     UpdateStatusIcon()
	call UpdateStatusIcon
	pop hl
	pop de
	pop bc
	pop af
;=@s
	inc c
	dec b
	jr nz, .slot

;> wPanelMode = 0
	xor a
	ld [wPanelMode], a
;> DrawPartyHPMP()
	call DrawPartyHPMP
;> CopyTilemapBufferToBG()
	call CopyTilemapBufferToBG
;> return
	ret


;@ path: battle/screen/panel
;@ Buffer offsets of the position mark of each panel slot.
PanelMarkSpots::
	dw $0025, $002b, $0031

;@ path: battle/screen/panel
;@ Buffer offsets of the level ("Lv") of each panel slot.
PanelLevelSpots::
	dw $0061, $0067, $006d

;@ path: battle/screen/panel
;@ Buffer offsets of the ailment icons of each panel slot.
PanelAilmentSpots::
	dw $0081, $0087, $008d

;@ path: battle/screen/panel
;@ The tiles of the six ailment icons drawn by PutAilmentIcon.
AilmentIconTiles::
	db $dc, $d7, $db, $dd, $da, $d8

;@ def PanelSlotAddress(spots: hl, pos: c) -> hl
;@ path: battle/screen/panel
;@ The wTilemapBuffer address of the panel slot of battle position `pos` (pos & 3) in the table of
;@ buffer offsets `spots`.
PanelSlotAddress::
;>@a return BattleBufferAddress(mem16[spots + 2*(pos & 3)])
	ld a, c
	and $03
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
;=@a
	ret


;@ def PutAilmentIcon(icon: a, dest: de)
;@ path: battle/screen/panel
;@ Puts the tile of ailment icon `icon` (AilmentIconTiles) at `dest`.
PutAilmentIcon::
;>@p mem[dest] = mem[AilmentIconTiles + icon]
	push hl
	ld hl, AilmentIconTiles
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	ld a, [hl]
	ld [de], a
;> return
	pop hl
	ret


;@ def LoadStatusIconTiles(icon: a, dest: hl)
;@ path: battle/screen/panel
;@ Decompresses the tiles of status icon `icon` (StatusIconGfx) to VRAM at `dest`.
LoadStatusIconTiles::
;>@e entry = mem16[StatusIconGfx + 2*icon]
	push hl
	ld hl, StatusIconGfx
	add a
	add l
	ld l, a
	ld a, $00
;=@e
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
;> DecompressVRAM(entry >> 8, entry & 0xFF, dest)
	pop hl
	call DecompressVRAM
;> return
	ret


;@ path: battle/screen/panel
;@ The compressed tiles of the 8 status icons: entries 2-9 of bank $5B (0 none, 1-6 the ailments, 7
;@ out of the fight).
StatusIconGfx::
	db $02, $5b, $03, $5b, $04, $5b, $05, $5b, $06, $5b, $07, $5b, $08, $5b, $09, $5b

;@ def UpdateStatusIcon()
;@ path: battle/screen/panel
;@ Updates the status icon tiles ($8DA0 + 16 * slot) of the panel slot of wSkillTarget, or else of
;@ wSkillUser, when that position sits on the panel's side: the icon shows the first of the ailments
;@ (bits 6, 5, 4, 7, 1, 0 of its status byte), or 7 when it is out of the fight. Tiles are only loaded
;@ when the icon changed (wStatusIconShown).
UpdateStatusIcon::
;> if wLinkActive and wLinkFlags & 2:                # the panel shows positions 4-6
	ld a, [wLinkActive]
	or a
	jr z, .normal

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .normal

;>     pos = wSkillTarget
	ld a, [wSkillTarget]
	ld c, a
;>     if pos >= 4:
	cp $04
	jr c, .user

;>         if pos == 7: return
	cp $07
	ret z

;>         slot = pos ^ 4
	jr .flip

;>     else:
;>         pos = wSkillUser
.user:
	ld a, [wSkillUser]
	ld c, a
;>         if pos < 4 or pos == 7: return
	cp $04
	ret c

	cp $07
	ret z

;>         slot = pos ^ 4
	jr .flip

;> else:
;>     pos = wSkillTarget; slot = pos
.normal:
	ld a, [wSkillTarget]
	ld c, a
;>     if pos >= 3:
	cp $03
	jr c, .slot

;>         pos = wSkillUser; slot = pos
	ld a, [wSkillUser]
	ld c, a
;>         if pos >= 3: return
	cp $03
	jr c, .slot

	ret

.flip:
	xor $04

;>@d dest = 0x8DA0 + 16*slot
.slot:
	push de
	swap a
	ld hl, $8da0
	add l
	ld l, a
	ld a, $00
;=@d
	adc h
	ld h, a
	push hl
;> if CheckBattlerPresent(pos): icon = 7                 # carry: out of the fight
	ld a, c
	call CheckBattlerPresent
	jr c, .absent

;> else:
;>     s = wBattlerStatus[8*pos]
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;>     if s & 0x40: icon = 6
	bit 6, [hl]
	jr nz, .icon6

;>     elif s & 0x20: icon = 5
	bit 5, [hl]
	jr nz, .icon5

;>     elif s & 0x10: icon = 4
	bit 4, [hl]
	jr nz, .icon4

;>     elif s & 0x80: icon = 3
	bit 7, [hl]
	jr nz, .icon3

;>     elif s & 0x02: icon = 2
	bit 1, [hl]
	jr nz, .icon2

;>     elif s & 0x01: icon = 1
	bit 0, [hl]
	jr nz, .icon1

;>@z     else: icon = 0
	ld a, $00
	jr .got

.absent:
	ld a, $07
	jr .got

.icon6:
;=@z
	ld a, $06
	jr .got

.icon5:
	ld a, $05
	jr .got

.icon4:
	ld a, $04
	jr .got

.icon3:
;=@z
	ld a, $03
	jr .got

.icon2:
	ld a, $02
	jr .got

.icon1:
	ld a, $01

;>@g if icon != wStatusIconShown[pos]:
.got:
	push af
	ld a, c
	ld hl, wStatusIconShown
	add l
	ld l, a
	ld a, $00
;=@g
	adc h
	ld h, a
	ld d, [hl]
	pop af
	cp d
;>     StoreStatusIcon(icon, addr(wStatusIconShown) + pos)
	call nz, StoreStatusIcon
;>     LoadStatusIconTiles(icon, dest)
	pop hl
	call nz, LoadStatusIconTiles
;> return
	pop de
	ret


;@ def StoreStatusIcon(icon: a, p: hl)
;@ path: battle/screen/panel
;@ mem[p] = icon (keeps the flags).
StoreStatusIcon::
;> mem[p] = icon
	ld [hl], a
;> return
	ret


;@ def ClearBGAttributes()
;@ path: battle/screen/tilemap
;@ On a Game Boy Color, clears the tile attributes (VRAM bank 1) of the 18 rows of the battle BG map
;@ at wBattleBGMap.
;@ test: skip draws to VRAM
ClearBGAttributes::
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;> rVBK = 1
	ld a, $01
	ldh [rVBK], a
;> p = wBattleBGMap
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [$d9f9]
	ld h, a
;>@r for row in range(18):
	ld c, $12

;>@c     for col in range(32):
.row:
	ld b, $20
	push hl

;>@x         WriteVRAM(0,(p & 0xFFE0) | ((p + col) & 0x1F))
.column:
	ld a, $00
	call WriteVRAM
	ld a, l
	and $e0
	push af
	ld a, l
;=@x
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
;=@c
	dec b
	jr nz, .column

;>@w     p = ((p + 0x20) & 0x03FF) | 0x9800
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
;=@w
	or $98
	ld h, a
	pop bc
;=@r
	dec c
	jr nz, .row

;> rVBK = 0
	ld a, $00
	ldh [rVBK], a
;> return
	ret


;@ def GetBattlerName(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Copies the name of the monster at battle position `pos` to `dest`: the party monsters' own names
;@ for positions 0-2, GetEnemyName for the others.
GetBattlerName::
;> if pos >= 3: return GetEnemyName(pos, dest)
	cp $03
	jr nc, GetEnemyName

;> return GetPartyMonName(pos, dest)

;@ def GetPartyMonName(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Copies the name of the party monster at position `pos` to `dest`; returns the address of its $F0
;@ end.
GetPartyMonName::
;>@n CopyName(PartyMonsterField(pos, wMonName), dest)
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
;=@n
	push hl
	call CopyName
	pop hl

;> while mem[dest] != 0xF0: dest += 1
.end:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr .end

;> return dest

;@ def GetLinkEnemyName(pos: b, dest: hl)
;@ path: battle/names
;@ GetEnemyName in a link battle: the other player's monsters are named like party monsters (takes
;@ back the bc that GetEnemyName saved).
;@ test: skip pops the bc that GetEnemyName pushed
GetLinkEnemyName::
;> return GetPartyMonName(pos, dest)
	ld a, b
	pop bc
	jr GetPartyMonName

;@ def GetEnemyName(pos: a, dest: hl)
;@ path: battle/names
;@ The name of an enemy (or a called monster, positions 3 and 7): the species name with a letter when
;@ several enemies share it; an enemy changed by the transform skill is named after the monster it
;@ copied (GetMorphEnemyName); in a link battle the monster's own name.
GetEnemyName::
;>@n if pos & 3 != 3:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
;=@n
	jr z, .species

;>     if wLinkActive: return GetLinkEnemyName(pos, dest)
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, GetLinkEnemyName

;>@m     morph = wEnemyMorph[pos & 3]
	push hl
	ld a, b
	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
;=@m
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
;>     if morph != 0xFF: return GetMorphEnemyName(morph, dest)
	cp $ff
	jr nz, .morph

	ld a, b

.morph:
	pop bc
	jr nz, GetMorphEnemyName

;> GetSpeciesName(pos, dest)
.species:
	push af
	call GetSpeciesName
	pop af
;> AppendEnemyLetter()
	ld hl, far_AppendEnemyLetter
	rst $10
;> return
	ret


;@ def GetSpeciesName(pos: a, dest: hl)
;@ path: battle/names
;@ Copies the species name of the monster at battle position `pos` (system text $0500 + species) to
;@ `dest`, and notes position and buffer for AppendEnemyLetter (wNameBattler, wNameDest).
GetSpeciesName::
;> wNameBattler = pos
	ld [wNameBattler], a
;>@s id = 0x0500 + wBattlerSpecies[pos]
	push hl
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hl]
	ld l, a
	ld h, $05
;> wNameDest = dest
	pop de
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [$db5f], a
;> CopySystemText(id, dest)
	call CopySystemText
;> return
	ret


;@ def GetMorphEnemyName(morph: a, dest: hl)
;@ path: battle/names
;@ The name of an enemy changed by the transform skill: the name of party monster `morph` followed by
;@ the suffix tiles $2F $46 $48 $42 and, when other enemies copied the same monster, a letter code
;@ 1-3 (also kept in wBattleArg1, else 0).
GetMorphEnemyName::
;> p = GetPartyMonName(morph, dest)
	call GetPartyMonName
;> mem[p] = 0x2F; mem[p + 1] = 0x46
	ld a, $2f
	ld [hli], a
	ld a, $46
	ld [hli], a
;> mem[p + 2] = 0x48; mem[p + 3] = 0x42
	ld a, $48
	ld [hli], a
	ld a, $42
	ld [hli], a
;> p += 4; mem[p] = 0xF0
	ld [hl], $f0
;> m = wEnemyMorph; e = wNamePos & 3
	push hl
	ld hl, wEnemyMorph
	ld a, [wNamePos]
	and $03
;> if e == 0:
	cp $01
	jr z, .second

	cp $02
	jr z, .third

;>     if m[0] == m[1] or m[0] == m[2]: letter = 1
	ld a, [hli]
	cp [hl]
	jr z, .letter1

	inc hl
	cp [hl]
	jr z, .letter1

;>     else: letter = 0
	jr .none

;> elif e == 1:
;>     if m[1] == m[0]: letter = 2
.second:
	ld a, [hli]
	cp [hl]
	jr z, .letter2

;>     elif m[1] == m[2]: letter = 1
	ld a, [hli]
	cp [hl]
	jr z, .letter1

;>     else: letter = 0
	jr .none

;> else:
;>     n = 0
.third:
	ld d, $00
;>@q     if m[2] == m[0]: n += 1
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, .notFirst

;=@q
	inc d

;>     if m[2] == m[1]: n += 1
.notFirst:
	inc hl
	cp [hl]
	jr nz, .counted

	inc d

;>@k     letter = n + 1 if n else 0
.counted:
	ld a, d
	or a
	jr z, .none

	cp $01
	jr z, .letter2

;=@k
	pop hl
	ld a, $03
	jr .store

.letter1:
	pop hl
	ld a, $01
	jr .store

.letter2:
;=@k
	pop hl
	ld a, $02

;> if letter:
;>     wBattleArg1 = letter
.store:
	ld [wBattleArg1], a
;>     mem[p] = letter; mem[p + 1] = 0xF0
	ld [hli], a
	ld [hl], $f0
;>     return
	ret

;> wBattleArg1 = 0
.none:
	pop hl
	xor a
	ld [wBattleArg1], a
;> return
	ret

; Unused: two small routines that put the name of the position in $DB89 into $C1A0 and of the
; position in $DB88 into $C180 via GetBattlerName (buffer noted in wBattleArg2/3, position in
; wNamePos).
	db $21, $a0, $c1, $18, $03, $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db
	db $fa, $89, $db, $ea, $50, $db, $cd, $0a, $7a, $c9, $21, $80, $c1, $7d, $ea, $4e
	db $db, $7c, $ea, $4f, $db, $fa, $88, $db, $ea, $50, $db, $cd, $0a, $7a, $c9

;@ path: battle/screen/cursor
;@ The battle menu cursor tiles, compressed (decompress entry $5112; 48 bytes = 3 tiles once
;@ unpacked), followed by the zero padding up to the end of the bank.
BattleCursorGfx::
	db $30, $00, $01, $ff, $82, $01, $00, $07, $7c, $ff, $01, $ff, $f0, $c2, $ff, $a2
	db $ff, $92, $ff, $8a, $ff, $86, $ff, $82, $ff, $00, $ff, $38, $ff, $44, $01, $00
	db $03, $44, $ff, $38, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00
