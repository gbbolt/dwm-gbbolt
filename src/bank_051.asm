INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $051", ROMX[$4000], BANK[$51]

BankNumber_51::
	db $51

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
	dw Data_51_7B0F

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
	ld a, [$d999]
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


BattlerFallSequence::
	ld a, [wFallStep]
	rst $00

FallSteps::
	dw FallStep0
	dw FallStep1
	dw FallStep2

FallStep0::
	ld hl, wFallStep
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld a, [wBattleArg0]
	ld [wBattleTemp], a
	and $03
	cp $03
	jr z, jr_051_53d6

	call ReloadBattler
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr nz, jr_051_53cd

	cp $04
	jr c, jr_051_53d1

	cp $07
	jr z, jr_051_53d1

	jr FallStep1

jr_051_53cd:
	cp $03
	jr c, FallStep1

jr_051_53d1:
	ld hl, wFallStep
	inc [hl]
	ret


jr_051_53d6:
	ld hl, wFallStep
	inc [hl]
	ld a, [wBattleArg0]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [wBattleArg0]
	and $04
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	res 2, [hl]
	call SetBattlerDown
	ret


FallStep1::
	ld hl, far_BlankEnemyPicture
	rst $10
	ld a, $1a
	ld [wBattleSubStep], a
	ld a, $02
	ld [wFallStep], a
	ret


FallStep2::
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld [wBattleTemp], a
	call SetBattlerDown
	ld a, [wLinkActive]
	or a
	jr nz, jr_051_543f

	ld a, [wSkillTarget]
	cp $04
	jr c, jr_051_543f

	cp $07
	jr z, jr_051_543f

	ld a, [wSkillTarget]
	cp $03
	jr c, jr_051_543f

	jr z, jr_051_543f

	cp $07
	jr z, jr_051_543f

	ld a, [wSkillTarget]
	ld [wJoinCandidate], a

jr_051_543f:
	ld hl, far_PrintPanelHPMP
	rst $10
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	ld a, [wSkillTarget]
	call GetBattlerName
	call GetMessageSide
	and $04
	srl a
	srl a
	add $e3
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $03
	ld [wBattleSubStep], a
	xor a
	ld [wFallStep], a
	ld a, $02
	ld [wMonStats], a
	ret


GetMessageSide::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

	ld a, [wSkillUser]
	ret


ClearMonStatsCopy::
	push bc
	push hl
	ld hl, wMonStats
	ld bc, $002b
	xor a
	call FillMemory
	pop hl
	pop bc
	ret


ReloadPartyBattlers::
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wNewMonNameText]
	ld b, a
	ld a, [wNewMonSlot]
	ld c, a
	push bc
	ld hl, wTilemapBuffer
	ld bc, $00c0
	ld a, $e0
	call FillMemory
	ld hl, wBattlerStatus
	ld bc, $0040
	xor a
	call FillMemory
	ld a, [wPartyCount]
	ld [wPartyBattlers], a
	ld [wPanelCount], a
	ld b, a
	ld c, $00

jr_051_54ca:
	call LoadBattlerFromRecord
	inc c
	dec b
	jr nz, jr_051_54ca

	ld a, [wParty]
	ld hl, $9700
	call DrawSlotNameTiles
	ld a, [$ca8f]
	ld hl, $9740
	call DrawSlotNameTiles
	ld a, [$ca90]
	ld hl, $9780
	call DrawSlotNameTiles
	pop bc
	ld a, c
	ld [wNewMonSlot], a
	ld a, b
	ld [wNewMonNameText], a
	ret


DrawSlotNameTiles::
	cp $ff
	ret z

	push hl
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	call DrawMonNameTiles
	ret


ResetStatusIcons::
	ld a, $ff
	ld hl, wStatusIconShown
	ld bc, $0008
	call FillMemory
	ret


	db $01, $00, $08, $79, $cd, $a5, $2f, $30, $04, $16, $07, $18, $39, $79, $21, $02
	db $db, $cd, $6c, $2f, $cb, $76, $20, $18, $cb, $6e, $20, $18, $cb, $66, $20, $18
	db $cb, $7e, $20, $18, $cb, $4e, $20, $18, $cb, $46, $20, $18, $16, $00, $18, $16
	db $16, $06, $18, $12, $16, $05, $18, $0e, $16, $04, $18, $0a, $16, $03, $18, $06
	db $16, $02, $18, $02, $16, $01, $79, $21, $0a, $da, $85, $6f, $3e, $00, $8c, $67
	db $72, $0c, $05, $20, $ae, $c9

LoadMonsterPicFar::
	ld a, [$c0dc]
	ld l, a
	ld a, [$c0dd]
	ld h, a
	ld a, [$c0de]
	call LoadMonsterPic
	ret


LevelUpScreen::
	ld a, [wCommandStep]
	rst $00

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

LevelUpStep00::
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	jr c, jr_051_55b7

	ld hl, wBattleStep
	inc [hl]
	xor a
	ld [wCommandStep], a
	ret


jr_051_55b7:
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep01::
	ld a, [wCurPartyMember]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	inc a
	ld hl, wTextArg1
	call ByteToDecimal
	ld a, $47
	call QueueMusic
	ld hl, $0b01
	call PrintSystemText
	ld hl, far_RollLevelUpGains
	rst $10
	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep02::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wOverLevelLimit]
	or a
	jp nz, Jump_051_56ec

	ld a, [wCurPartyMember]
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_5660

	xor a
	ld [wLevelGains], a

jr_051_5660:
	ld a, [wCurPartyMember]
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_567c

	xor a
	ld [$c8cb], a

jr_051_567c:
	ld a, [wCurPartyMember]
	ld hl, wMonAttack
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_5698

	xor a
	ld [$c8cc], a

jr_051_5698:
	ld a, [wCurPartyMember]
	ld hl, wMonDefense
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $e7
	ld l, a
	ld a, h
	sbc $03
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_56b4

	xor a
	ld [$c8cd], a

jr_051_56b4:
	ld a, [wCurPartyMember]
	ld hl, wMonAgility
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $ff
	ld l, a
	ld a, h
	sbc $01
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_56d0

	xor a
	ld [$c8ce], a

jr_051_56d0:
	ld a, [wCurPartyMember]
	ld hl, wMonIntelligence
	call MonsterField
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $ff
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld a, h
	or l
	jr nz, jr_051_56ec

	xor a
	ld [$c8cf], a

Jump_051_56ec:
jr_051_56ec:
	ld a, [wLevelGains]
	ld hl, wTextArg2
	call ByteToDecimal
	ld a, [$c8cb]
	ld hl, $c1a4
	call ByteToDecimal
	ld a, [$c8cc]
	ld hl, $c1a8
	call ByteToDecimal
	ld a, [$c8cd]
	ld hl, $c1ac
	call ByteToDecimal
	ld a, [$c8ce]
	ld hl, wTextArgs
	call ByteToDecimal
	ld a, [$c8cf]
	ld hl, $c1b4
	call ByteToDecimal
	ld hl, $0b1e
	ld a, [wOverLevelLimit]
	or a
	jr z, jr_051_572e

	ld hl, $0b1f

jr_051_572e:
	call PrintSystemText
	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep03::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wSceneObjects
	ld bc, $0028
	ld a, $ff
	call FillMemory
	ld a, [wCurPartyMember]
	ld hl, wMonSkills
	call MonsterField
	ld de, wSceneObjects
	ld b, $08

jr_051_5754:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_5754

	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep04::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, far_FindLearnableSkill
	rst $10
	ldh a, [$ffd8]
	cp $ff
	jr z, jr_051_57b1

	ld l, a
	ld h, $06
	ld de, wTextArg2
	call CopySystemText
	ld c, $ff
	ld hl, $0b02
	ldh a, [$ffd9]
	or a
	jr z, jr_051_5799

	ld hl, $0b0f
	cp $02
	jr z, jr_051_5799

	ldh a, [$ffda]
	ld l, a
	ld h, $06
	ld de, wTextArgs
	call CopySystemText
	ld hl, $0b03
	ldh a, [$ffda]
	ld c, a

jr_051_5799:
	push bc
	call PrintSystemText
	pop bc
	ld hl, wSceneObjects
	ld b, $28

jr_051_57a3:
	ld a, [hl]
	cp c
	jr nz, jr_051_57ac

	ldh a, [$ffd8]
	ld [hl], a
	jr jr_051_57b0

jr_051_57ac:
	inc hl
	dec b
	jr nz, jr_051_57a3

jr_051_57b0:
	ret


jr_051_57b1:
	ld hl, far_PruneLearnableSkills
	rst $10
	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep05::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep06::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep07::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep08::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep09::
	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep10::
	ld a, [wTextState]
	or a
	ret nz

	call CompactSkillList
	cp $09
	jr nc, jr_051_57f9

	ld a, $10
	ld [wCommandStep], a
	ret


jr_051_57f9:
	ld hl, wCommandStep
	inc [hl]
	ld hl, $0b04
	call PrintSystemText
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	call CopyTilemapBufferToBG
	ret


CompactSkillList::
	ld hl, wNumberBackup
	ld bc, $0028
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wNumberBackup
	ld b, $28
	ld c, $00

jr_051_5822:
	ld a, [hli]
	cp $ff
	jr z, jr_051_582a

	ld [de], a
	inc de
	inc c

jr_051_582a:
	dec b
	jr nz, jr_051_5822

	ld a, c
	push af
	ld hl, wSceneObjects
	ld de, wNumberBackup
	ld b, $28

jr_051_5837:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_051_5837

	pop af
	ret


LevelUpStep11::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	call CompactSkillList
	ld [wBattleListCount], a
	ld hl, wCommandStep
	inc [hl]
	call DrawSkillNameColumn
	call DrawForgetSkillInfo
	call ClearBattleTilemap
	call DrawForgetMenu
	call CopyTilemapBufferToBG
	ret


DrawForgetMenu::
	call DrawBattlePartyPanel
	ld hl, far_Call_55_4774
	rst $10
	ld de, $6e78
	call DrawBattleWindow
	ld de, $6fe2
	call DrawBattleWindow
	ld de, $7077
	call DrawBattleWindow
	call DrawForgetMPCost
	ld hl, wMonMaxMP
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0125
	call BattleBufferAddress
	call PrintNumber3
	call ResetBattleCursorBlink
	ld de, $59d7
	ld a, [wBattleListCount]
	ld c, a
	ld hl, wMenuChoice2
	call DrawPagedCursor
	ret


DrawForgetMPCost::
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	ld d, $00
	ld hl, far_GetSkillMPCost
	rst $10
	ld c, e
	ld b, d
	ld a, e
	add $19
	ld e, a
	ld a, d
	adc $fc
	ld d, a
	ld a, d
	or e
	jr z, jr_051_58dd

	ld hl, $0121
	call BattleBufferAddress
	call PrintNumber3
	ret


jr_051_58dd:
	ld hl, wMonMaxMP
	ld a, [wCurPartyMember]
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0121
	call BattleBufferAddress
	call PrintNumber3
	ret


DrawSkillNameColumn::
	ld de, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9360
	call DrawSkillNameTiles
	call DrawSkillNameTiles
	call DrawSkillNameTiles

DrawSkillNameTiles::
	push de
	push hl
	ld a, [de]
	ld [wTextIndex], a
	ld a, $06
	ld [wTextGroup], a
	ld de, $0901
	call PrintTextToTiles
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


DrawForgetSkillInfo::
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	ld hl, $9000
	ld de, $1203
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
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
	ld hl, LevelUpStep01
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
	ret


LevelUpStep12::
	ld de, $59d7
	ld hl, wMenuChoice2
	ld a, [wBattleListCount]
	ld c, a
	ld b, $04
	ld a, [hli]
	push af
	ld a, [hld]
	push af
	call UpdatePagedCursor
	pop af
	ld hl, wConfirmChoice
	cp [hl]
	jr z, jr_051_59ad

	call DrawSkillNameColumn
	call DrawForgetSkillInfo
	call DrawForgetMPCost
	call CopyTilemapBufferToBG

jr_051_59ad:
	pop af
	ld hl, wMenuChoice2
	cp [hl]
	jr z, jr_051_59bd

	call DrawForgetSkillInfo
	call DrawForgetMPCost
	call CopyTilemapBufferToBG

jr_051_59bd:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_59d6

	ld a, $59
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	ld hl, wMenuChoice2
	set 7, [hl]
	xor a
	ld [wConfirmChoice2], a

jr_051_59d6:
	ret


	db $52, $01, $69, $00, $a9, $00, $e9, $00, $29, $01, $ff, $ff

LevelUpStep13::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $06
	ld de, wTextArg0
	call CopySystemText
	ld hl, $0b05
	call PrintSystemText
	ld de, $2e07
	call DrawBattleWindow
	call CopyTilemapBufferToBG
	ret


LevelUpStep14::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ld a, $5c
	call QueueSound
	call ClearBattleTilemap
	call DrawForgetMenu
	ld de, $2e07
	call DrawBattleWindow
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $6eef
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $5ab6
	ld a, [wConfirmChoice2]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


LevelUpStep15::
	ld de, $5ab6
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_5a72

jr_051_5a65:
	ld hl, $0b07
	call PrintSystemText
	ld a, $0b
	ld [wCommandStep], a
	jr jr_051_5ab5

jr_051_5a72:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_5ab5

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice2]
	cp $81
	jr z, jr_051_5a65

	ld hl, wCommandStep
	inc [hl]
	ld hl, wConfirmChoice2
	set 7, [hl]
	ld hl, wSceneObjects
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [hl], $ff
	ld l, a
	ld h, $06
	ld de, wTextArg0
	call CopySystemText
	ld hl, $0b06
	call PrintSystemText

jr_051_5ab5:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

LevelUpStep16::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	push hl
	ld a, [wCurPartyMember]
	ld hl, wMonMaxLevel
	call MonsterField
	ld a, [hl]
	dec a
	pop hl
	cp [hl]
	jr nz, jr_051_5ae0

	ld hl, $0b20
	call PrintSystemText

jr_051_5ae0:
	ld hl, wCommandStep
	inc [hl]
	ret


LevelUpStep17::
	ld a, [wTextState]
	or a
	ret nz

	call CompactSkillList
	cp $09
	jr c, jr_051_5b04

	ld hl, $0b07
	call PrintSystemText
	ld a, $0b
	ld [wCommandStep], a
	xor a
	ld [wMenuChoice2], a
	ld [wConfirmChoice], a
	ret


jr_051_5b04:
	call StoreLearnedSkills
	call ApplyLevelUp
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	call CopyTilemapBufferToBG
	xor a
	ld [wCommandStep], a
	ld hl, wBattleStep
	dec [hl]
	ret


StoreLearnedSkills::
	ld a, [wCurPartyMember]
	ld hl, wMonSkills
	call MonsterField
	ld de, wSceneObjects
	ld b, $08

jr_051_5b2a:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_051_5b2a

	ret


ApplyLevelUp::
	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	cp $63
	ret nc

	ld a, [wCurPartyMember]
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	inc a
	ld [hl], a
	ld a, [wOverLevelLimit]
	or a
	jr nz, jr_051_5b99

	ld a, [wLevelGains]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxHP
	ld a, [$c8cb]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterMaxMP
	ld a, [$c8cc]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterAttack
	ld a, [$c8cd]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterDefense
	ld a, [$c8ce]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterAgility
	ld a, [$c8cf]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call RaiseMonsterIntelligence
	ret


jr_051_5b99:
	ld a, [wLevelGains]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterMaxHP
	ld a, [$c8cb]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterMaxMP
	ld a, [$c8cc]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterAttack
	ld a, [$c8cd]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterDefense
	ld a, [$c8ce]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterAgility
	ld a, [$c8cf]
	ld l, a
	ld h, $00
	ld a, [wCurPartyMember]
	call LowerMonsterIntelligence
	ld a, [wCurPartyMember]
	ld hl, wMonMaxHP
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
	ld a, [wCurPartyMember]
	ld hl, wMonHP
	call MonsterField
	pop bc
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc [hl]
	jr nc, jr_051_5c02

	ld [hl], b
	dec hl
	ld [hl], c

jr_051_5c02:
	ld a, [wCurPartyMember]
	ld hl, wMonMaxMP
	call MonsterField
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
	ld a, [wCurPartyMember]
	ld hl, wMonMP
	call MonsterField
	pop bc
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc [hl]
	jr nc, jr_051_5c23

	ld [hl], b
	dec hl
	ld [hl], c

jr_051_5c23:
	call ReloadPartyBattlers
	call RefreshStatusIcons
	call DrawBattlePartyPanel
	call ClearBGAttributes
	call CopyTilemapBufferToBG
	ret


RecruitScreen::
	ld a, [wCommandStep]
	rst $00

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

RecruitStep00::
	ld hl, far_LoadFieldObjPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
	ld a, $14
	ld [wNewMonSlot], a
	ld hl, far_CreateMonsterUnlisted
	rst $10
	ld hl, far_LoadMonTemplate2
	rst $10
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
	ld hl, wMenuChoice
	ld bc, $0008
	ld a, $00
	call FillMemory
	xor a
	ld hl, wCommandStep
	ld bc, $0008
	call FillMemory
	ld hl, $9800
	ld a, l
	ld [wBattleBGMap], a
	ld a, h
	ld [$d9f9], a
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	call CopyTilemapBufferToBG
	ld de, wPartyBarTiles
	ld a, [wParty]
	call CopyMonName8
	ld a, [$ca8f]
	call CopyMonName8
	ld a, [$ca90]
	call CopyMonName8
	ld hl, wCommandStep
	inc [hl]
	ret


CopyMonName8::
	cp $ff
	ret z

	push de
	ld hl, wMonName
	call MonsterField
	pop de
	ld b, $08

jr_051_5d20:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_5d20

	ret


RecruitStep01::
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ld a, $14
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg0
	call AppendSexSymbol
	ld hl, $0b10
	call PrintSystemText
	ld hl, wCommandStep
	inc [hl]
	ret


RecruitStep02::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $6eef
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $5de4
	ld a, [wMenuChoice]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


RecruitStep03::
	ld de, $5de4
	ld hl, wMenuChoice
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_5dbc

jr_051_5da3:
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ld hl, $0b12
	call PrintSystemText
	ld a, $1d
	ld [wCommandStep], a
	jr jr_051_5de3

jr_051_5dbc:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_5de3

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice]
	cp $81
	jr z, jr_051_5da3

	ld hl, wCommandStep
	inc [hl]
	ld hl, wMenuChoice
	set 7, [hl]
	ld hl, wMenuChoice2
	ld bc, $0007
	ld a, $00
	call FillMemory

jr_051_5de3:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

RecruitStep04::
	call CountFreeMonSlots
	or a
	jr z, jr_051_5df7

	ld a, $15
	ld [wCommandStep], a
	jr jr_051_5e33

jr_051_5df7:
	ld hl, wCommandStep
	inc [hl]
	ld hl, $0b11
	call PrintSystemText
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $6eef
	call DrawBattleWindow
	ld de, $5de4
	ld a, [wMenuChoice]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG

jr_051_5e33:
	ret


CountFreeMonSlots::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_051_5e3b:
	ld a, [de]
	or a
	jr nz, jr_051_5e40

	inc c

jr_051_5e40:
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_051_5e3b

	ld a, c
	ret


RecruitStep05::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $6eef
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $5ed1
	ld a, [wMenuChoice2]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


RecruitStep06::
	ld de, $5ed1
	ld hl, wMenuChoice2
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_5ea5

jr_051_5e8c:
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ld hl, $0b12
	call PrintSystemText
	ld a, $1d
	ld [wCommandStep], a
	jr jr_051_5ed0

jr_051_5ea5:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_5ed0

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice2]
	cp $81
	jr z, jr_051_5e8c

	ld hl, wListCursor
	ld bc, $0008
	ld a, $00
	call FillMemory
	ld hl, wMenuChoice2
	set 7, [hl]
	inc hl
	ld [hl], $00
	ld a, $1f
	ld [wCommandStep], a

jr_051_5ed0:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

RecruitStep07::
	call CountMonstersOrEggs
	or a
	jr nz, jr_051_5ee9

	ld hl, $0b1c
	call PrintSystemText
	ld a, $22
	ld [wCommandStep], a
	ret


jr_051_5ee9:
	call ListMonstersOrEggs
	ld hl, PrintMessageGroup1
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_5ef9

	ld hl, $0b22

jr_051_5ef9:
	call PrintSystemText
	call DrawMonsterEggChoice
	call CopyTilemapBufferToBG
	ld hl, wCommandStep
	inc [hl]
	ret


DrawMonsterEggChoice::
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	ld de, $70ab
	call DrawBattleWindow
	ld de, $6823
	ld a, [wListCursor2]
	call DrawBattleCursorAt
	ret


CountMonstersOrEggs::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_051_5f35:
	push de
	ld a, [de]
	or a
	jr z, jr_051_5f53

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	ld a, [wListCursor2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	jr nz, jr_051_5f53

	inc c

jr_051_5f53:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_051_5f35

	ld a, c
	ld [wListLength], a
	ret


ListMonstersOrEggs::
	ld hl, wSceneObjects
	ld bc, $0014
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_051_5f79:
	push de
	ld a, [de]
	or a
	jr z, jr_051_5f9a

	ld a, e
	add $63
	ld e, a
	ld a, d
	adc $00
	ld d, a
	push hl
	ld a, [wListCursor2]
	and $01
	ld l, a
	ld a, [de]
	ld h, a
	srl a
	or h
	and $01
	xor l
	pop hl
	jr nz, jr_051_5f9a

	ld [hl], c
	inc hl

jr_051_5f9a:
	pop de
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	inc c
	dec b
	jr nz, jr_051_5f79

	ret


RecruitStep08::
	ld a, [wTextState]
	or a
	ret nz

	call DrawReleaseListPage
	call DrawReleaseList
	call CopyTilemapBufferToBG
	ld hl, wCommandStep
	inc [hl]
	ret


DrawReleaseList::
	ld hl, far_Call_55_4813
	rst $10
	ld de, $6f14
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_5fcc

	ld de, $70d0

jr_051_5fcc:
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $61a5
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_5fdf

	ld de, $61b1

jr_051_5fdf:
	ld b, $04
	ld a, [wListLength]
	ld c, a
	ld hl, wListCursor
	call DrawPagedCursor
	ret


DrawReleaseListPage::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_6014

	ld hl, $9240
	call DrawListSpeciesTiles
	call DrawListSpeciesTiles
	call DrawListSpeciesTiles
	call DrawListSpeciesTiles
	call DrawListSexIcons
	ret


jr_051_6014:
	ld hl, $88c0
	call DrawListNameTiles
	call DrawListNameTiles
	call DrawListNameTiles

DrawListNameTiles::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_051_6041

	ld a, [de]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call DrawMonNameTiles
	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


jr_051_6041:
	ld b, $20

jr_051_6043:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_051_6043

	pop hl
	ld a, l
	add $40
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


DrawListSpeciesTiles::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_051_6085

	ld hl, wMonRecSpecies
	call MonsterField
	ld a, [hl]
	ld [wTextIndex], a
	ld a, $05
	ld [wTextGroup], a
	ld de, $0901
	pop hl
	push hl
	call PrintTextToTiles
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


jr_051_6085:
	ld b, $48

jr_051_6087:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_051_6087

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


DrawListSexIcons::
	ld a, [wListPage]
	add a
	add a
	ld de, wSceneObjects
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld hl, $9480
	call DrawListSexIcon
	call DrawListSexIcon
	call DrawListSexIcon

DrawListSexIcon::
	push de
	push hl
	ld a, [de]
	cp $ff
	jr z, jr_051_6135

	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	cp $02
	ld a, $98
	jr nz, jr_051_60da

	ld a, l
	add $a8
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, [hl]
	and $01
	add $a7

jr_051_60da:
	ld [wTextArg0], a
	ld a, $f0
	ld [$c181], a
	pop hl
	push hl
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
	ld de, $0101
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
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


jr_051_6135:
	ld b, $08

jr_051_6137:
	ld a, $ff
	call WriteVRAMInc
	xor a
	call WriteVRAMInc
	dec b
	jr nz, jr_051_6137

	pop hl
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	pop de
	inc de
	ret


RecruitStep09::
	ld de, $61a5
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_615c

	ld de, $61b1

jr_051_615c:
	ld hl, wListCursor
	ld a, [wListLength]
	ld c, a
	ld b, $04
	inc hl
	ld a, [hld]
	push af
	call UpdatePagedCursor
	pop af
	ld hl, wListPage
	cp [hl]
	jr z, jr_051_6175

	call DrawReleaseListPage

jr_051_6175:
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_618c

	call RedrawMonsterEggChoice
	ld a, $20
	ld [wCommandStep], a
	ld hl, $0b1a
	call PrintSystemText
	jr jr_051_61a4

jr_051_618c:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_61a4

	ld a, $59
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	ld hl, wConfirmChoice
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_61a4:
	ret


	db $85, $01, $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff, $8b, $01, $a1, $00
	db $e1, $00, $21, $01, $61, $01, $ff, $ff

RecruitStep10::
	ld hl, wCommandStep
	inc [hl]
	ret


RecruitStep11::
	ld a, [wTextState]
	or a
	ret nz

	call DrawReleaseConfirm
	ld hl, wCommandStep
	inc [hl]
	ret


DrawReleaseConfirm::
	ld de, $6f6e
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_61dc

	ld de, $7150

jr_051_61dc:
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $629e
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_61ef

	ld de, $62a4

jr_051_61ef:
	ld a, [wConfirmChoice2]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


RecruitStep12::
	ld de, $629e
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_6206

	ld de, $62a4

jr_051_6206:
	ld hl, wConfirmChoice2
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_622b

	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	jr jr_051_629d

jr_051_622b:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_629d

	ld a, $59
	call QueueSound
	ld a, [wConfirmChoice2]
	cp $81
	jr z, jr_051_624c

	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
	ld a, $19
	ld [wCommandStep], a
	jr jr_051_629d

jr_051_624c:
	ld a, [wPartyCount]
	cp $01
	jr z, jr_051_6260

	ld a, [$ca8f]
	ld hl, wMonStatus
	call MonsterField
	bit 7, [hl]
	jr z, jr_051_6291

jr_051_6260:
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wParty]
	cp [hl]
	jr nz, jr_051_6291

	ld hl, $0b24
	call PrintSystemText
	ld de, $2e07
	call DrawBattleWindow
	call CopyTilemapBufferToBG
	ld a, $1f
	ld [wCommandStep], a
	jr jr_051_629d

jr_051_6291:
	ld hl, wCommandStep
	inc [hl]
	ld hl, wConfirmChoice2
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_629d:
	ret


	db $2e, $01, $6e, $01, $ff, $ff, $2d, $01, $6d, $01, $ff, $ff

RecruitStep13::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push af
	ld hl, wMonEgg
	call MonsterField
	ld a, [hl]
	or a
	jr z, jr_051_62e0

	pop af
	push af
	ld hl, $0b1d
	call PrintSystemText
	ld de, $70d0
	call DrawBattleWindow
	jr jr_051_62f6

jr_051_62e0:
	pop af
	push af
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld hl, $0b14
	call PrintSystemText

jr_051_62f6:
	pop af
	ld hl, wMonsters
	call MonsterField
	ld [hl], $00
	ld hl, far_CompactMonsters
	rst $10
	call RefreshStatusIcons
	call DrawBattlePartyPanel
	ld de, $2e07
	call DrawBattleWindow
	call CopyTilemapBufferToBG
	ld a, $15
	ld [wCommandStep], a
	ret


RecruitStep14::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ld a, [wNewMonSlot]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld hl, $0b15
	call PrintSystemText
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	call CopyTilemapBufferToBG
	ret


RecruitStep15::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $5c
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $6eef
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $63bc
	ld a, [wMenuChoice3]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


RecruitStep16::
	ld de, $63bc
	ld hl, wMenuChoice3
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_6398

jr_051_6392:
	ld hl, wCommandStep
	inc [hl]
	jr jr_051_63bb

jr_051_6398:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_63bb

	ld a, $59
	call QueueSound
	ld a, [wMenuChoice3]
	cp $81
	jr z, jr_051_6392

	ld hl, wCommandStep
	inc [hl]
	ld hl, wCommandStep
	inc [hl]
	ld hl, wMenuChoice3
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_63bb:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

RecruitStep17::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	ld a, [wNewMonSlot]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld hl, $0b16
	call PrintSystemText
	ld a, $1e
	ld [wCommandStep], a
	ret


FindFreeMonSlot::
	ld de, wMonsters
	ld b, $14
	ld c, $00

jr_051_63ef:
	ld a, [de]
	or a
	jr z, jr_051_63ff

	inc c
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec b
	jr nz, jr_051_63ef

jr_051_63ff:
	ld a, c
	ret


RecruitStep18::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wPartyCount]
	cp $03
	jr z, jr_051_642b

	ld a, [wPartyCount]
	ld hl, wParty
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wNewMonSlot]
	ld [hl], a
	ld hl, wPartyCount
	inc [hl]
	ld hl, far_CompactMonsters
	rst $10
	ld a, $1e
	ld [wCommandStep], a
	ret


jr_051_642b:
	ld hl, wCommandStep
	inc [hl]
	ld hl, $0b18
	call PrintSystemText
	call DrawPartyFullMenu
	call CopyTilemapBufferToBG
	ret


DrawPartyFullMenu::
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	ld hl, $89c0
	ld de, $5112
	call DecompressVRAM
	ld de, $6eef
	call DrawBattleWindow
	ld de, $63bc
	ld a, [wMenuChoice3]
	call DrawBattleCursorAt
	ret


RecruitStep19::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wCommandStep
	inc [hl]
	call ListPartyAndNewcomer
	call DrawPartySwapNames
	call DrawPartySwapList
	call CopyTilemapBufferToBG
	ret


DrawPartySwapList::
	ld hl, far_Call_55_4813
	rst $10
	ld de, $6f14
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $6527
	ld a, [wLinkRefused]
	call DrawBattleCursorAt
	ret


DrawPartySwapNames::
	ld de, wSceneObjects
	ld hl, $88c0
	call DrawListNameTiles
	call DrawListNameTiles
	call DrawListNameTiles
	call DrawListNameTiles
	ret


ListPartyAndNewcomer::
	ld hl, wSceneObjects
	ld bc, $0004
	ld a, $ff
	call FillMemory
	ld hl, wSceneObjects
	ld a, [wParty]
	cp $ff
	call nz, AppendToList
	ld a, [$ca8f]
	cp $ff
	call nz, AppendToList
	ld a, [$ca90]
	cp $ff
	call nz, AppendToList
	ld a, [wNewMonSlot]
	call AppendToList
	ret


AppendToList::
	ld [hli], a
	ret


RecruitStep20::
	ld de, $6527
	ld hl, wLinkRefused
	ld a, [wPartyCount]
	inc a
	ld b, a
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_650a

	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	jr jr_051_6526

jr_051_650a:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_6526

	ld a, $59
	call QueueSound
	ld hl, wCommandStep
	inc [hl]
	ld hl, wCommandStep
	inc [hl]
	ld hl, wLinkRefused
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_6526:
	ret


	db $a1, $00, $e1, $00, $21, $01, $61, $01, $ff, $ff

RecruitStep21::
	ld a, [wTextState]
	or a
	ret nz

	call FindFreeMonSlot
	ld [wNewMonSlot], a
	call StoreRecruitedMonster
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg0
	call CopySystemText
	ld a, [wNewMonSlot]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld de, wTextArg0
	call AppendSexSymbol
	ld hl, $0b17
	call PrintSystemText
	ld a, $23
	ld [wCommandStep], a
	ret


RecruitStep22::
	ld a, [wTextState]
	or a
	ret nz

	call DrawSwapConfirm
	ld hl, wCommandStep
	inc [hl]
	ret


DrawSwapConfirm::
	ld de, $6f6e
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $65d8
	ld a, [wLinkPartnerChoice]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


RecruitStep23::
	ld de, $65d8
	ld hl, wLinkPartnerChoice
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_65aa

	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	ld hl, wCommandStep
	dec [hl]
	jr jr_051_65d7

jr_051_65aa:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_65d7

	ld a, $59
	call QueueSound
	ld a, [wLinkPartnerChoice]
	cp $81
	jr z, jr_051_65cb

	xor a
	ld [wFieldMenuState], a
	ld [wFieldMenuStep], a
	ld a, $1b
	ld [wCommandStep], a
	jr jr_051_65d7

jr_051_65cb:
	ld hl, wCommandStep
	inc [hl]
	ld hl, wLinkPartnerChoice
	set 7, [hl]
	inc hl
	ld [hl], $00

jr_051_65d7:
	ret


	db $2e, $01, $6e, $01, $ff, $ff

RecruitStep24::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wLinkRefused]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wMonName
	call MonsterField
	ld e, l
	ld d, h
	ld hl, wTextArg0
	call CopyName
	ld a, [wNewMonNameText]
	ld l, a
	ld h, $05
	ld de, wTextArg1
	call CopySystemText
	ld hl, $0b19
	call PrintSystemText
	ld de, $2e07
	call DrawBattleWindow
	call CopyTilemapBufferToBG
	ld a, [wLinkRefused]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld hl, wParty
	ld a, [wSceneObjects]
	call AppendIfFilled
	ld a, [$c0d9]
	call AppendIfFilled
	ld a, [$c0da]
	call AppendIfFilled
	ld a, [$c0db]
	call AppendIfFilled
	ld hl, far_CompactMonsters
	rst $10
	ld a, $1d
	ld [wCommandStep], a
	ret


AppendIfFilled::
	cp $ff
	ret z

	ld [hli], a
	ret


RecruitStep25::
	ld a, [wListPage]
	add a
	add a
	ld b, a
	ld a, [wListCursor]
	and $7f
	add b
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	xor a
	ld [wMenuSubStep], a
	ld hl, far_ShowMonsterStatus
	rst $10
	ld a, [wMenuSubStep]
	or a
	ret z

	ld hl, wCommandStep
	inc [hl]
	ret


RecruitStep26::
	ld de, $5b00
	ld hl, $9600
	call DecompressVRAM
	ld de, $5b01
	ld hl, $8800
	call DecompressVRAM
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
	call CountMonstersOrEggs
	call ListMonstersOrEggs
	call DrawReleaseListPage
	ld hl, PrintMessageGroup1
	ld a, [wListCursor2]
	and $01
	jr z, jr_051_66d7

	ld hl, $0b22

jr_051_66d7:
	call PrintSystemText
	call RunTextToEnd
	call RefreshIconsAndNames
	call DrawMonsterEggChoice
	call DrawReleaseList
	call DrawReleaseConfirm
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, $0b
	ld [wCommandStep], a
	ret


RecruitStep27::
	ld a, [wLinkRefused]
	and $7f
	ld hl, wSceneObjects
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wCurPartyMember], a
	xor a
	ld [wMenuSubStep], a
	ld hl, far_ShowMonsterStatus
	rst $10
	ld a, [wMenuSubStep]
	or a
	ret z

	ld hl, wCommandStep
	inc [hl]
	ret


RecruitStep28::
	ld de, $5b00
	ld hl, $9600
	call DecompressVRAM
	ld de, $5b01
	ld hl, $8800
	call DecompressVRAM
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
	call CountMonstersOrEggs
	call ListMonstersOrEggs
	call DrawReleaseListPage
	ld hl, $0b18
	call PrintSystemText
	call RunTextToEnd
	call ReloadPartyBattlers
	call RefreshStatusIcons
	call DrawPartyFullMenu
	call ListPartyAndNewcomer
	call DrawPartySwapNames
	call DrawPartySwapList
	call DrawSwapConfirm
	ld hl, far_UploadCGBPalettes
	rst $10
	ld a, $17
	ld [wCommandStep], a
	ret


RecruitStep29::
	ld a, [wTextState]
	or a
	ret nz

	call ReloadPartyBattlers
	call RefreshStatusIcons
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	call CopyTilemapBufferToBG
	xor a
	ld [wCommandStep], a
	ld hl, wBattleStep
	inc [hl]
	ret


RecruitStep31::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, $0b1a
	call PrintSystemText
	ld hl, wCommandStep
	inc [hl]
	ret


RecruitStep32::
	ld a, [wTextState]
	or a
	ret nz

	call RedrawMonsterEggChoice
	ld hl, wCommandStep
	inc [hl]
	ret


RedrawMonsterEggChoice::
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	ld de, $70ab
	call DrawBattleWindow
	call ResetBattleCursorBlink
	ld de, $6823
	ld a, [wListCursor2]
	call DrawBattleCursorAt
	call CopyTilemapBufferToBG
	ret


RecruitStep33::
	ld de, $6823
	ld hl, wListCursor2
	ld b, $02
	call UpdateBattleMenuCursor
	ld a, [wJoyPressed]
	bit 1, a
	jr z, jr_051_6809

	ld a, $04
	ld [wCommandStep], a
	jr jr_051_6822

jr_051_6809:
	ld a, [wJoyPressed]
	bit 0, a
	jp z, Jump_051_6822

	ld a, $59
	call QueueSound
	xor a
	ld [wListCursor], a
	ld [wListPage], a
	ld a, $07
	ld [wCommandStep], a

Jump_051_6822:
jr_051_6822:
	ret


	db $2f, $01, $6f, $01, $ff, $ff

RecruitStep34::
	ld a, [wTextState]
	or a
	ret nz

	call RedrawMonsterEggChoice
	ld a, $20
	ld [wCommandStep], a
	ld hl, $0b1a
	call PrintSystemText
	ret


RecruitStep35::
	ld a, [wTextState]
	or a
	ret nz

	ld hl, wFieldFlags
	set 4, [hl]
	ld a, $ff
	ld [wScriptMenu], a
	xor a
	ld [wMenuStep], a
	ld a, [wNewMonNameText]
	ld [wChosenMonSpecies], a
	add $10
	ld [wChosenMonPic], a
	ld a, [wNewMonSlot]
	ld hl, wMonGender
	call MonsterField
	ld a, [hl]
	ld [wChosenMonGender], a
	ld a, [wNewMonSlot]
	ld hl, wMonName
	call MonsterField
	ld a, l
	ld [wChosenMonName], a
	ld a, h
	ld [$c8f3], a
	ld hl, wCommandStep
	inc [hl]
	ret


RecruitStep36::
	call SwapMenuVars
	ld hl, far_NameEntryMenu
	rst $10
	call SwapMenuVars
	ld a, [wFieldFlags]
	bit 4, a
	ret nz

	call ClearBattleTilemap
	call CopyTilemapBufferToBG
	ld hl, far_Call_56_4485
	rst $10
	ld hl, wCommandStep
	inc [hl]
	ld de, $5b00
	ld hl, $9600
	call DecompressVRAM
	ld de, $5b01
	ld hl, $8800
	call DecompressVRAM
	ld a, $0a
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $8820
	ld de, $0a01
	call PrintTextToTiles
	ld a, $1b
	ld [wTextIndex], a
	ld a, $0b
	ld [wTextGroup], a
	ld hl, $89c0
	ld de, $0f01
	call PrintTextToTiles
	ld hl, $9000
	ld a, [wNewMonNameText]
	call LoadMonsterPic
	call ReloadPartyBattlers
	call RefreshStatusIcons
	call ClearBattleTilemap
	call DrawBattlePartyPanel
	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ld a, [wNewMonNameText]
	ld hl, $00c7
	call SetNewMonPicPalette
	call CopyTilemapBufferToBG
	ld a, $0e
	ld [wCommandStep], a
	ret


SwapMenuVars::
	ld hl, wMenuChoice
	ld de, wBattlerSexBits67
	ld b, $08

jr_051_690b:
	ld c, [hl]
	ld a, [de]
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	dec b
	jr nz, jr_051_690b

	ret


AppendSexSymbol::
	push af

jr_051_6916:
	ld a, [de]
	inc de
	cp $f0
	jr nz, jr_051_6916

	dec de
	pop af
	and $01
	add $a7
	ld [de], a
	inc de
	ld a, $f0
	ld [de], a
	ret


StoreRecruitedMonster::
	ld hl, wMonsters
	call MonsterField
	ld b, $95
	ld de, wBreedParent1

jr_051_6933:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_051_6933

	ld a, [wNewMonNameText]
	ld hl, wLibraryFlags
	call SetFlag
	ret


SetNewMonPicPalette::
	ld [wPaletteSet], a
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [$c821], a
	ld a, [wJoinCandidate]
	ld [wMonPicPalette], a
	ld hl, far_LoadMonPicPalette
	rst $10
	ret


SetBattlePicPalettes::
	ld a, [wLinkActive]
	or a
	jr z, jr_051_696d

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_696d

	ld a, [wPartyBattlers]
	ld c, $00
	jr jr_051_6972

jr_051_696d:
	ld a, [wEnemyCount]
	ld c, $04

jr_051_6972:
	cp $03
	jr z, jr_051_6992

	cp $02
	jr z, jr_051_6982

	ld a, c
	ld hl, $00c7
	call SetPicPalette
	ret


jr_051_6982:
	ld a, c
	ld hl, $00c4
	call SetPicPalette
	inc c
	ld a, c
	ld hl, $00ca
	call SetPicPalette
	ret


jr_051_6992:
	ld a, c
	ld hl, $00c1
	call SetPicPalette
	inc c
	ld a, c
	ld hl, $00c7
	call SetPicPalette
	inc c
	ld a, c
	ld hl, $00cd
	call SetPicPalette
	ret


SetPicPalette::
	push bc
	push af
	ld a, l
	ld [wMonPicPos], a
	ld a, h
	ld [$c821], a
	pop af
	push af
	ld de, wBattlerSpecies
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [wPaletteSet], a
	call GetCGBPicSpecies
	pop af
	and $03
	add $04
	ld [wMonPicPalette], a
	ld hl, far_LoadMonPicPalette
	rst $10
	pop bc
	ret


GetCGBPicSpecies::
	ld a, [wOnCGB]
	or a
	ret z

	ld a, [wLinkActive]
	or a
	jr z, jr_051_69ed

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_69ed

	ld a, c
	cp $03
	jr nc, jr_051_6a0c

	jr jr_051_69f6

jr_051_69ed:
	ld a, c
	cp $04
	jr c, jr_051_6a0c

	cp $07
	jr z, jr_051_6a0c

jr_051_69f6:
	ld a, $02
	ldh [rSVBK], a
	ld a, c
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wPaletteSet], a
	ld a, $00
	ldh [rSVBK], a

jr_051_6a0c:
	ret


RefreshIconsAndNames::
	ld a, $00
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, $01
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, $02
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld hl, $9700
	ld b, $60

jr_051_6a2d:
	ld a, $ff
	call WriteVRAMInc
	ld a, $00
	call WriteVRAMInc
	dec b
	jr nz, jr_051_6a2d

	ld a, [wPartyBattlers]
	or a
	ret z

	ld de, wPartyBarTiles
	ld hl, $9700
	call DrawMonNameTiles
	ld a, [wPartyBattlers]
	cp $01
	ret z

	ld de, $c1c8
	ld hl, $9740
	call DrawMonNameTiles
	ld a, [wPartyBattlers]
	cp $02
	ret z

	ld de, $c1d0
	ld hl, $9780
	call DrawMonNameTiles
	ret


LoadMonsterPic::
	push de
	push hl
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
	pop hl
	call DecompressVRAM
	pop de
	ret


RefreshStatusIcons::
	ld a, $00
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, $01
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, $02
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ret


	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $70, $71, $72, $73, $da, $e0, $74, $75
	db $76, $77, $db, $e0, $78, $79, $7a, $7b, $dc, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e2, $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0
	db $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $00, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $70, $71, $72, $73, $da, $e0, $74, $75, $76, $77, $db, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe
	db $e1, $e0, $e0, $e0, $e0, $e0, $e1, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e2
	db $e0, $e0, $e0, $e0, $e0, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $00, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $70, $71, $72, $73, $da, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e1, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e2, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $85, $86, $87, $88, $89, $e0, $86, $89, $8a, $8b
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $7c, $81, $80, $7f, $e0, $e0, $7d, $7e, $7f, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $a0, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $9a, $82, $9b, $82, $e0, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $92, $93, $94, $84, $9c
	db $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $6c, $6d, $6e, $6f, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $fd, $d9, $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8
	db $fe, $e0, $96, $88, $91, $8d, $87, $8a, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $8b, $86, $94, $8a, $95, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $96, $91, $8e, $89, $86, $90, $8e, $8c, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $96, $90, $8b, $8b, $91, $8f
	db $95, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9
	db $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $95, $96, $97, $98, $99
	db $9a, $9b, $9c, $9d, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a7
	db $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $85, $86, $87, $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed
	db $d8, $fe, $e0, $7e, $84, $e0, $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $88, $87, $89, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $85, $86, $87
	db $e0, $ff, $d8, $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72
	db $73, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76
	db $77, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a
	db $7b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $20, $01, $fa, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $86, $88, $87, $e0, $ff, $d8, $ec, $eb, $eb
	db $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72, $73, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76, $77, $ff, $d8, $fe, $e0, $e0
	db $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a, $7b, $ff, $d8, $fc, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94
	db $95, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $ff, $d8, $fe
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a0
	db $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $d8, $fc, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $00, $01, $fa, $ef, $ef, $ef, $ef
	db $fb, $d8, $fe, $e0, $d4, $e0, $d5, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8
	db $fe, $e0, $d5, $d5, $d6, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $48, $00
	db $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $36
	db $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $3f, $40, $41, $42, $43, $44, $45
	db $46, $47, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff
	db $d8, $fe, $e0, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $51, $52, $53
	db $54, $55, $56, $57, $58, $59, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $d4, $d5, $d6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9d, $9e
	db $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $40, $00, $fa, $ef, $ef, $ef
	db $ef, $ef, $fb, $d8, $fe, $e0, $82, $83, $84, $e0, $ff, $d8, $ec, $eb, $eb, $eb
	db $eb, $eb, $ed, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $90, $91, $92, $93, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $94, $95, $96, $97, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $ff, $d8, $fe, $e0, $98, $99, $9a, $9b, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $fd, $d9, $0d, $01, $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0
	db $85, $86, $87, $88, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $89, $8a, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $20, $01
	db $fa, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $82, $83, $84, $e0, $ff, $d8
	db $ec, $eb, $eb, $eb, $eb, $eb, $ed, $d8, $fe, $e0, $70, $71, $72, $73, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $74, $75, $76, $77, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $78, $79, $7a, $7b, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
	db $10, $11, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $12, $13, $14, $15, $16, $17
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
	db $30, $31, $32, $33, $34, $35, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9, $c0, $00, $fa
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $9c, $d6, $d5, $e0, $e2, $e3
	db $e0, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $e0
	db $e0, $e5, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd
	db $d9, $0e, $01, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $a0, $a1, $a2, $ff
	db $d8, $fe, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $a3, $a4, $a5, $ff, $d8, $fc
	db $ee, $ee, $ee, $ee, $fd, $d9, $80, $00, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $24, $25, $26, $27, $28, $29, $2a, $2b
	db $2c, $48, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $ff, $d8, $fe, $e0, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $49, $ff, $d8
	db $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0
	db $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $4a, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $3f, $40, $41, $42
	db $43, $44, $45, $46, $47, $4b, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $0c, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $fb
	db $d8, $fe, $e0, $a6, $a7, $a8, $a9, $aa, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $89, $8a, $e0, $e0, $e0, $ff, $d8, $fc, $ee, $ee, $ee
	db $ee, $ee, $ee, $fd, $d9, $c0, $00, $fa, $ef, $ef, $ef, $ef, $fb, $d8, $fe, $6c
	db $6d, $6e, $6f, $ff, $d8, $fc, $ee, $ee, $ee, $ee, $fd, $d9, $60, $01, $fa, $ef
	db $ef, $ef, $ef, $ef, $fb, $d8, $fe, $e0, $80, $89, $82, $e0, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $84, $82, $86, $81, $ff, $d8, $fe, $e0
	db $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $83, $8a, $85, $e0, $ff, $d8, $fc, $ee
	db $ee, $ee, $ee, $ee, $fd, $d9, $20, $01, $fa, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $fb, $d8, $fe, $e0, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94
	db $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe
	db $e0, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $ff, $d8, $fe, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $d8, $fe, $e0, $9e, $9f, $a0, $a1, $a2
	db $a3, $a4, $a5, $a6, $ff, $d8, $fe, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	db $e0, $ff, $d8, $fe, $e0, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $ff, $d8
	db $fc, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $ee, $fd, $d9

NextColumnWrapped::
	push af
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	pop af
	ret


BGMapAddress::
	ld a, [wBattleBGMap]
	add l
	ld l, a
	ld a, [$d9f9]
	adc h
	and $03
	ld h, a
	ld a, [$d9f9]
	and $fc
	or h
	ld h, a
	ret


BattleBufferAddress::
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ret


OffsetToBGAddress::
	push bc
	ld b, l
	ld a, l
	and $e0
	ld l, a
	call BGMapAddress
	ld a, b
	and $1f
	jr z, jr_051_7288

	ld b, a

jr_051_7282:
	call NextColumnWrapped
	dec b
	jr nz, jr_051_7282

jr_051_7288:
	pop bc
	ret


	db $1a, $6f, $13, $1a, $67, $13, $cd, $73, $72, $7d, $ea, $ea, $d9, $7c, $ea, $eb
	db $d9, $1a, $13, $fe, $d9, $c8, $fe, $d8, $20, $20, $fa, $ea, $d9, $6f, $fa, $eb
	db $d9, $67, $7d, $c6, $20, $6f, $7c, $ce, $00, $67, $7c, $e6, $03, $f6, $98, $67
	db $7d, $ea, $ea, $d9, $7c, $ea, $eb, $d9, $18, $d7, $cd, $ad, $1a, $cd, $47, $72
	db $18, $cf

DrawBattleWindow::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call BattleBufferAddress
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a

jr_051_72dd:
	ld a, [de]
	inc de
	cp $d9
	ret z

	cp $d8
	jr nz, jr_051_7300

	ld a, [wLayoutRow]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
	add $20
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a
	jr jr_051_72dd

jr_051_7300:
	ld [hli], a
	jr jr_051_72dd

	db $fa, $74, $db, $4f, $fa, $63, $c8, $cb, $4f, $28, $04, $fa, $75, $db, $4f, $c5
	db $06, $25, $0e, $62, $cd, $32, $73, $c1, $0d, $c8, $c5, $06, $2b, $0e, $68, $cd
	db $32, $73, $c1, $0d, $c8, $c5, $06, $31, $0e, $6e, $cd, $32, $73, $c1, $c9, $68
	db $26, $98, $78, $11, $00, $c5, $83, $5f, $3e, $00, $8a, $57, $1a, $cd, $ad, $1a
	db $06, $03, $69, $26, $98, $79, $11, $00, $c5, $83, $5f, $3e, $00, $8a, $57, $cd
	db $8e, $73, $06, $03, $79, $c6, $20, $6f, $26, $98, $11, $00, $c5, $83, $5f, $3e
	db $00, $8a, $57, $cd, $8e, $73, $c9

CopyTilemapBufferToBG::
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [$d9f9]
	ld h, a
	ld de, wTilemapBuffer
	ld c, $12

jr_051_7377:
	ld b, $20
	push hl
	call CopyTilemapRow
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, jr_051_7377

	ret


CopyTilemapRow::
	ld a, [de]
	call WriteVRAM
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	inc de
	dec b
	jr nz, CopyTilemapRow

	ret


PrintTextToTiles::
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
	ld a, e
	ld [wTextBoxLines], a
	ld a, d
	ld [wTextBoxLineLength], a
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
	ret


DrawMonNameTiles::
	push hl
	ld hl, wTextArg0
	call CopyName
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
	ld de, $0401
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
	ret


ClearBattleTilemap::
	ld hl, wTilemapBuffer
	ld bc, $0240

jr_051_7430:
	ld a, $e0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_051_7430

	ret


ClearBGMap::
	ld hl, $9800
	ld bc, $0400

jr_051_743f:
	ld a, $e0
	call WriteVRAMInc
	dec bc
	ld a, b
	or c
	jr nz, jr_051_743f

	ret


UpdatePagedCursor::
	ld a, c
	ld [wListLastRows], a
	inc de
	inc de
	ld a, [wTextState]
	or a
	jp nz, Jump_051_74b1

	ld a, [wJoyRepeat]
	bit 5, a
	jr z, jr_051_7477

	inc hl
	ld a, [hl]
	dec a
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
	cp c
	jr c, jr_051_7495

	ld a, c
	dec a
	jr jr_051_7495

jr_051_7477:
	ld a, [wJoyRepeat]
	bit 4, a
	jr z, jr_051_74b1

	inc hl
	ld a, [hl]
	inc a
	push af
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld a, b
	inc a
	pop bc
	pop de
	ld c, a
	pop af
	cp c
	jr c, jr_051_7495

	ld a, $00

jr_051_7495:
	ld [hld], a
	dec c
	cp c
	jr nz, jr_051_74f4

	ld a, [wListLastRows]
	ld c, a
	push de
	push bc
	ld a, b
	ld b, c
	call Divide8
	pop bc
	pop de
	or a
	jr z, jr_051_74f4

	dec a
	cp [hl]
	jr nc, jr_051_74f4

	ld [hl], a
	jr jr_051_74f4

Jump_051_74b1:
jr_051_74b1:
	push bc
	push de
	push hl
	call DrawBattlePageNumber
	pop hl
	pop de
	pop bc
	push de
	push bc
	ld a, b
	ld b, c
	dec b
	call Divide8
	ld [wListLastRows], a
	ld a, b
	pop bc
	pop de
	ld c, a
	inc hl
	ld a, [hld]
	cp c
	jr nz, UpdateBattleMenuCursor

	ld a, [wListLastRows]
	inc a
	ld b, a

UpdateBattleMenuCursor::
	res 7, [hl]
	ld a, [wJoyRepeat]
	bit 6, a
	jr z, jr_051_74e5

	ld a, [hl]
	dec a
	cp b
	jr c, jr_051_74f3

	dec b
	ld a, b
	jr jr_051_74f3

jr_051_74e5:
	ld a, [wJoyRepeat]
	bit 7, a
	jr z, jr_051_74fc

	ld a, [hl]
	inc a
	cp b
	jr c, jr_051_74f3

	ld a, $00

jr_051_74f3:
	ld [hl], a

jr_051_74f4:
	xor a
	ld [wCursorBlinkTimer], a
	push hl
	push de
	pop de
	pop hl

jr_051_74fc:
	ld a, [wJoyPressed]
	bit 0, a
	jr z, jr_051_7505

	set 7, [hl]

jr_051_7505:
	ld a, [hl]
	call DrawBattleMenuCursor
	ret


	db $cb, $be, $fa, $47, $c8, $e6, $c0, $28, $05, $7e, $ee, $01, $18, $db, $fa, $47
	db $c8, $e6, $30, $28, $dd, $7e, $ee, $02, $18, $cf

ResetBattleCursorBlink::
	xor a
	ld [wCursorBlinkTimer], a
	ret


DrawBattleMenuCursor::
	ld c, a
	bit 7, a
	jr nz, jr_051_753e

	ld a, [wCursorBlinkTimer]
	and $0f
	push af
	ld a, [wCursorBlinkTimer]
	inc a
	ld [wCursorBlinkTimer], a
	pop af
	ld a, c
	ret nz

jr_051_753e:
	ld c, a
	ld b, $00

jr_051_7541:
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a
	push de
	push bc
	call OffsetToBGAddress
	pop bc
	pop de
	ld a, c
	and $7f
	cp b
	ld a, $e0
	jr nz, jr_051_7573

	ld a, $e9
	bit 7, c
	jr nz, jr_051_7573

	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, jr_051_7573

	ld a, $e8

jr_051_7573:
	call WriteVRAM
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	inc b
	jr jr_051_7541

DrawBattlePageNumber::
	ld a, b
	cp c
	ret nc

	inc hl
	ld c, [hl]
	dec de
	dec de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	and l
	cp $ff
	ret z

	dec hl
	ld a, l
	ldh [hNumber], a
	ld a, h
	ldh [$ffd6], a
	push de
	push bc
	call OffsetToBGAddress
	pop bc
	pop de
	ld a, c
	and $7f
	add $f1
	call WriteVRAM
	push af
	ldh a, [hNumber]
	ld l, a
	ldh a, [$ffd6]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


DrawPagedCursor::
	ld a, [hli]
	push af
	push hl
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	ld a, b
	cp c
	ld a, $ee
	jr nc, jr_051_75de

	ld a, $e7

jr_051_75de:
	ld [hld], a
	pop bc
	jr nc, jr_051_75e6

	ld a, [bc]
	add $f1
	ld [hl], a

jr_051_75e6:
	pop af

DrawBattleCursorAt::
	ld c, a
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld a, l
	ld [wLayoutRow], a
	ld a, h
	ld [$d9eb], a
	push de
	push bc
	call OffsetToBGAddress
	pop bc
	pop de
	ld a, $e9
	bit 7, c
	jr nz, jr_051_7614

	ld a, [wCursorBlinkTimer]
	bit 4, a
	ld a, $e0
	jr nz, jr_051_7614

	ld a, $e8

jr_051_7614:
	push af
	ld a, [wLayoutRow]
	ld l, a
	ld a, [$d9eb]
	ld h, a
	ld a, l
	add $00
	ld l, a
	ld a, h
	adc $c5
	ld h, a
	pop af
	ld [hl], a
	ret


PlaceEnemyPics::
	ld a, [wLinkActive]
	or a
	jr z, jr_051_763a

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_763a

	ld a, [wPartyBattlers]
	jr jr_051_763d

jr_051_763a:
	ld a, [wEnemyCount]

jr_051_763d:
	cp $03
	jr z, jr_051_765d

	cp $02
	jr z, jr_051_764e

	ld a, $00
	ld hl, $00c7
	call PlacePicTiles
	ret


jr_051_764e:
	ld a, $00
	ld hl, $00c4
	call PlacePicTiles
	ld hl, $00ca
	call PlacePicTiles
	ret


jr_051_765d:
	ld a, $00
	ld hl, $00c1
	call PlacePicTiles
	ld hl, $00c7
	call PlacePicTiles
	ld hl, $00cd
	call PlacePicTiles
	ret


PlacePicTiles::
	ld c, $06

jr_051_7674:
	push hl
	push af
	call BattleBufferAddress
	pop af
	ld b, $06

jr_051_767c:
	ld [hli], a
	inc a
	dec b
	jr nz, jr_051_767c

	pop hl
	ld de, $0020
	add hl, de
	dec c
	jr nz, jr_051_7674

	ret


DrawBattlePartyPanel::
	ld de, $2e07
	call DrawBattleWindow
	ld a, [wPanelMode]
	or a
	jp nz, Jump_051_7763

DrawPartyHPMP::
	ld a, [wLinkActive]
	or a
	jr nz, jr_051_76a2

	ld a, [wPartyCount]
	or a
	ret z

jr_051_76a2:
	call DrawPartyPanelFrame
	jr jr_051_76c7

DrawPartyPanelFrame::
	ld hl, $775b
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_76b6

	ld a, [wEnemyCount]
	jr jr_051_76b9

jr_051_76b6:
	ld a, [wPartyBattlers]

jr_051_76b9:
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	call DrawBattleWindow
	ret


jr_051_76c7:
	ld hl, wBattlerHP
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_76d4

	ld hl, $dbab

jr_051_76d4:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0062
	call BattleBufferAddress
	call PrintNumber3
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0082
	call BattleBufferAddress
	call PrintNumber3
	ld a, [wPanelCount]
	cp $01
	ret z

	ld hl, $dba5
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_7705

	ld hl, $dbad

jr_051_7705:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0068
	call BattleBufferAddress
	call PrintNumber3
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $0088
	call BattleBufferAddress
	call PrintNumber3
	ld a, [wPanelCount]
	cp $02
	ret z

	ld hl, $dba7
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_7736

	ld hl, $dbaf

jr_051_7736:
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $006e
	call BattleBufferAddress
	call PrintNumber3
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, $008e
	call BattleBufferAddress
	call PrintNumber3
	ret


	db $c7, $76, $f2, $76, $23, $77, $76, $6b, $76, $6b, $1a, $6b, $9a, $6a

Jump_051_7763:
	cp $03
	jp z, Jump_051_786b

	call DrawPartyPanelFrame
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
	jr z, jr_051_7785

	ld c, $04

jr_051_7785:
	ld hl, $78ca
	call PanelSlotAddress
	push hl
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_051_7796

	ld a, $d9
	jr jr_051_7798

jr_051_7796:
	ld a, $e0

jr_051_7798:
	pop hl
	ld [hl], a
	ld hl, $78d0
	call PanelSlotAddress
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
	jr nz, jr_051_7785

	ld a, [wPanelMode]
	cp $02
	jr z, jr_051_77e6

	call CopyTilemapBufferToBG
	ld hl, $8da0
	ld a, $02
	call LoadStatusIconTiles
	ld hl, $8db0
	ld a, $04
	call LoadStatusIconTiles
	ld hl, $8dc0
	ld a, $06
	call LoadStatusIconTiles
	ld hl, $8dd0
	ld a, $03
	call LoadStatusIconTiles
	ld hl, wPanelMode
	inc [hl]

jr_051_77e6:
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_77f5

	ld c, $04

jr_051_77f5:
	ld hl, $78d0
	call PanelSlotAddress
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
	jr c, jr_051_7863

	ld hl, $78d6
	call PanelSlotAddress
	push hl
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	pop de
	ld a, [hl]
	or a
	jr z, jr_051_7863

	bit 6, [hl]
	jr z, jr_051_7832

	ld a, $00
	call PutAilmentIcon

jr_051_7832:
	inc de
	bit 5, [hl]
	jr z, jr_051_783c

	ld a, $01
	call PutAilmentIcon

jr_051_783c:
	inc de
	bit 4, [hl]
	jr z, jr_051_7846

	ld a, $02
	call PutAilmentIcon

jr_051_7846:
	inc de
	bit 7, [hl]
	jr z, jr_051_7850

	ld a, $03
	call PutAilmentIcon

jr_051_7850:
	inc de
	bit 1, [hl]
	jr z, jr_051_785a

	ld a, $04
	call PutAilmentIcon

jr_051_785a:
	bit 0, [hl]
	jr z, jr_051_7863

	ld a, $05
	call PutAilmentIcon

jr_051_7863:
	inc c
	dec b
	jr nz, jr_051_77f5

	call CopyTilemapBufferToBG
	ret


Jump_051_786b:
	ld a, [wPanelCount]
	ld b, a
	ld c, $00
	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_787a

	ld c, $04

jr_051_787a:
	ld hl, $78ca
	call PanelSlotAddress
	ld a, c
	and $03
	add $da
	ld [hl], a
	ld hl, $78d0
	call PanelSlotAddress
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
	call UpdateStatusIcon
	pop hl
	pop de
	pop bc
	pop af
	inc c
	dec b
	jr nz, jr_051_787a

	xor a
	ld [wPanelMode], a
	call DrawPartyHPMP
	call CopyTilemapBufferToBG
	ret


	db $25, $00, $2b, $00, $31, $00, $61, $00, $67, $00, $6d, $00, $81, $00, $87, $00
	db $8d, $00, $dc, $d7, $db, $dd, $da, $d8

PanelSlotAddress::
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


PutAilmentIcon::
	push hl
	ld hl, $78dc
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [de], a
	pop hl
	ret


LoadStatusIconTiles::
	push hl
	ld hl, $7919
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


	db $02, $5b, $03, $5b, $04, $5b, $05, $5b, $06, $5b, $07, $5b, $08, $5b, $09, $5b

UpdateStatusIcon::
	ld a, [wLinkActive]
	or a
	jr z, jr_051_794f

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_051_794f

	ld a, [wSkillTarget]
	ld c, a
	cp $04
	jr c, jr_051_7943

	cp $07
	ret z

	jr jr_051_7960

jr_051_7943:
	ld a, [wSkillUser]
	ld c, a
	cp $04
	ret c

	cp $07
	ret z

	jr jr_051_7960

jr_051_794f:
	ld a, [wSkillTarget]
	ld c, a
	cp $03
	jr c, jr_051_7962

	ld a, [wSkillUser]
	ld c, a
	cp $03
	jr c, jr_051_7962

	ret


jr_051_7960:
	xor $04

jr_051_7962:
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
	jr c, jr_051_7998

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr nz, jr_051_799c

	bit 5, [hl]
	jr nz, jr_051_79a0

	bit 4, [hl]
	jr nz, jr_051_79a4

	bit 7, [hl]
	jr nz, jr_051_79a8

	bit 1, [hl]
	jr nz, jr_051_79ac

	bit 0, [hl]
	jr nz, jr_051_79b0

	ld a, $00
	jr jr_051_79b2

jr_051_7998:
	ld a, $07
	jr jr_051_79b2

jr_051_799c:
	ld a, $06
	jr jr_051_79b2

jr_051_79a0:
	ld a, $05
	jr jr_051_79b2

jr_051_79a4:
	ld a, $04
	jr jr_051_79b2

jr_051_79a8:
	ld a, $03
	jr jr_051_79b2

jr_051_79ac:
	ld a, $02
	jr jr_051_79b2

jr_051_79b0:
	ld a, $01

jr_051_79b2:
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
	call nz, StoreStatusIcon
	pop hl
	call nz, LoadStatusIconTiles
	pop de
	ret


StoreStatusIcon::
	ld [hl], a
	ret


ClearBGAttributes::
	ld a, [wOnCGB]
	or a
	ret z

	ld a, $01
	ldh [rVBK], a
	ld a, [wBattleBGMap]
	ld l, a
	ld a, [$d9f9]
	ld h, a
	ld c, $12

jr_051_79de:
	ld b, $20
	push hl

jr_051_79e1:
	ld a, $00
	call WriteVRAM
	ld a, l
	and $e0
	push af
	ld a, l
	inc a
	and $1f
	ld l, a
	pop af
	or l
	ld l, a
	dec b
	jr nz, jr_051_79e1

	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	ld a, h
	and $03
	or $98
	ld h, a
	pop bc
	dec c
	jr nz, jr_051_79de

	ld a, $00
	ldh [rVBK], a
	ret


GetBattlerName::
	cp $03
	jr nc, jr_051_7a28

GetPartyMonName::
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call CopyName
	pop hl

jr_051_7a1d:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_051_7a1d

jr_051_7a24:
	ld a, b
	pop bc
	jr GetPartyMonName

jr_051_7a28:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_051_7a51

	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_051_7a24

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
	jr nz, jr_051_7a4e

	ld a, b

jr_051_7a4e:
	pop bc
	jr nz, jr_051_7a79

jr_051_7a51:
	push af
	call GetSpeciesName
	pop af
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


GetSpeciesName::
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


jr_051_7a79:
	call GetPartyMonName
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
	jr z, jr_051_7aa5

	cp $02
	jr z, jr_051_7aaf

	ld a, [hli]
	cp [hl]
	jr z, jr_051_7acb

	inc hl
	cp [hl]
	jr z, jr_051_7acb

	jr jr_051_7ada

jr_051_7aa5:
	ld a, [hli]
	cp [hl]
	jr z, jr_051_7ad0

	ld a, [hli]
	cp [hl]
	jr z, jr_051_7acb

	jr jr_051_7ada

jr_051_7aaf:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_051_7ab9

	inc d

jr_051_7ab9:
	inc hl
	cp [hl]
	jr nz, jr_051_7abe

	inc d

jr_051_7abe:
	ld a, d
	or a
	jr z, jr_051_7ada

	cp $01
	jr z, jr_051_7ad0

	pop hl
	ld a, $03
	jr jr_051_7ad3

jr_051_7acb:
	pop hl
	ld a, $01
	jr jr_051_7ad3

jr_051_7ad0:
	pop hl
	ld a, $02

jr_051_7ad3:
	ld [wBattleArg1], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_051_7ada:
	pop hl
	xor a
	ld [wBattleArg1], a
	ret


	db $21, $a0, $c1, $18, $03, $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db
	db $fa, $89, $db, $ea, $50, $db, $cd, $0a, $7a, $c9, $21, $80, $c1, $7d, $ea, $4e
	db $db, $7c, $ea, $4f, $db, $fa, $88, $db, $ea, $50, $db, $cd, $0a, $7a, $c9

Data_51_7B0F::
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
