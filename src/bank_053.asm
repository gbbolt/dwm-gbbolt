INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $053", ROMX[$4000], BANK[$53]

;@ path: battle/actions
;@ Bank number byte ($53) at the start of the bank; FarCall reads it to know which bank is switched in.
BankNumber_53::
	db $53

;@ path: battle/actions
;@ Far-call entry points of bank $53 (used as `ld hl, far_Name` + `rst $10`): the stages of carrying
;@ out one battler's action in the battle (bank $52's action steps call them), entries 0-17.
FarTable_53::
	dw RunActionStart_53
	dw PickConfusedAction_53
	dw CurseEffect_53
	dw PickChanceEffect_53
	dw RunCoverStages_53
	dw RunSkillHit_53
	dw CheckTakeMagic_53
	dw AbsorbMP_53
	dw AbsorbMP_53
	dw StartReactionFar_53
	dw Call_53_601C
	dw Call_53_60B3
	dw Call_53_65AC
	dw Call_53_670E
	dw Call_53_6A9B
	dw Call_53_6BE2
	dw CheckBossImmunity_53
	dw Call_53_5F15

;@ path: battle/data
;@ Critical-hit chance of each species when it fights on the player's side (or on either side of a
;@ link battle), one byte per species number: 0-2 = that many chances in 256 per attack, 3 = 4 in 256.
;@ Read by CheckCriticalHit_53.
CritChanceOwn_53::
	db $02, $02, $02, $02, $02, $03, $02, $02, $03, $02, $03, $02, $03, $02, $02, $02
	db $02, $02, $01, $01, $01, $01, $01, $01, $01, $02, $01, $02, $02, $02, $00, $01
	db $01, $01, $01, $02, $01, $01, $02, $02, $01, $01, $01, $01, $00, $01, $02, $01
	db $02, $02, $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $00, $01, $01, $01, $02, $02, $03, $02, $02, $02, $02, $02, $03, $02
	db $02, $02, $02, $02, $02, $02, $02, $01, $02, $01, $02, $02, $02, $02, $03, $03
	db $02, $02, $02, $02, $03, $02, $02, $02, $03, $02, $03, $01, $01, $03, $02, $01
	db $02, $02, $02, $02, $01, $01, $02, $03, $02, $01, $01, $02, $02, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $00, $01, $00, $00, $01, $00, $00, $02, $01, $02, $02, $02
	db $01, $01, $02, $02, $02, $02, $01, $01, $01, $01, $01, $02, $01, $00, $02, $02
	db $01, $02, $02, $02, $02, $02, $01, $02, $02, $01, $01, $02, $02, $01, $02, $02
	db $01, $01, $02, $02, $01, $01, $02, $00, $01, $00, $01, $00, $01, $00, $00, $00
	db $01, $00, $01, $01, $00, $00, $00, $00, $02, $02, $01, $01, $02

;@ path: battle/data
;@ Critical-hit chance of each species as a wild or scripted enemy, one byte per species number
;@ (same values as CritChanceOwn_53).
CritChanceWild_53::
	db $00, $00, $01
	db $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	db $00, $00, $01, $01, $01, $00, $01, $00, $01, $00, $00, $00, $01, $01, $01, $01
	db $01, $01, $01, $00, $01, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $01
	db $00, $01, $00, $01, $01, $00, $01, $01, $01, $01, $00, $01, $01, $01, $01, $00
	db $00, $00, $00, $00, $01, $00, $00, $01, $00, $01, $01, $00, $00, $01, $01, $01
	db $01, $01, $01, $01, $01, $00, $00, $01, $01, $00, $00, $01, $01, $00, $01, $00
	db $01, $00, $00, $00, $01, $00, $00, $01, $01, $01, $03, $00, $00, $00, $00, $01
	db $00, $00, $00, $00, $00, $01, $00, $01, $01, $01, $00, $01, $01, $01, $00, $00
	db $01, $01, $00, $01, $00, $01, $01, $00, $00, $00, $01, $01, $01, $01, $01, $01
	db $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01
	db $00, $00, $01, $01, $00, $01, $01, $01, $00, $01, $00, $00, $01, $01, $00, $00
	db $00, $00, $01, $00, $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $01, $00
	db $00, $00, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;@ path: battle/data
;@ One byte per enemy monster template (the 16-bit numbers in wEncSpecies): nonzero = this enemy
;@ does not use a group skill (GroupSkills_53) that one of its group already used earlier in the same
;@ turn (CheckEnemyRepeatsSkill_53).
EnemyAvoidsRepeat_53::
	db $00, $00, $00, $00, $00, $00
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	db $00, $01, $01, $01, $01, $01, $01, $00, $01, $00, $00, $01, $01, $01, $01, $01
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;@ def GetBattlerName_53(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Writes the name of the monster at battle position `pos` to `dest`, ended with $F0: an own
;@ monster's nickname, or for an enemy its species name with the letter A/B/C (see GetEnemyName_53).
;@ test: skip calls routines in other banks
GetBattlerName_53::
;> if pos >= 3:
;>     return GetEnemyName_53(pos, dest)
	cp $03
	jr nc, GetEnemyName_53

;@ def GetPartyMonName_53(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Copies the nickname of party monster `pos` to `dest` (CopyName) and returns the address of its
;@ $F0 end mark, so more text can be appended.
GetPartyMonName_53::
;> name = PartyMonsterField(pos, addr(wMonName))
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
;> CopyName(name, dest)
	push hl
	call CopyName
	pop hl

;> while mem[dest] != 0xF0: dest += 1
.findEnd
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr .findEnd
;> return dest

;@ def GetLinkEnemyName_53(pos: b, dest: hl) -> hl
;@ path: battle/names
;@ Part of GetEnemyName_53 for a link battle: the partner's monsters have monster records too, so
;@ their nicknames are copied like the own ones.
;@ test: skip pops a register the caller pushed
GetLinkEnemyName_53::
;> return GetPartyMonName_53(pos, dest)
	ld a, b
	pop bc
	jr GetPartyMonName_53

;@ def GetEnemyName_53(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Name of an enemy battle position (3-7). In a link battle the partner's nickname. Otherwise the
;@ species name plus the letter A/B/C (AppendEnemyLetter); an enemy that turned into one of the own
;@ monsters (Transform, wEnemyMorph) is called "<nickname>Like" instead (GetMorphName_53).
;@ test: skip calls routines in other banks
GetEnemyName_53::
;>@n3 if pos & 3 != 3:                    # not the fourth position of a side
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
;=@n3
	pop bc
	jr z, .species

;>     if wLinkActive:
;>         return GetLinkEnemyName_53(pos, dest)
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, GetLinkEnemyName_53

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
;>     if morph != 0xFF:
;>         return GetMorphName_53(morph, dest)
	cp $ff
	jr nz, .morphed

	ld a, b

.morphed
	pop bc
	jr nz, GetMorphName_53

.species
;> GetSpeciesName_53(pos, dest)
	push af
	call GetSpeciesName_53
	pop af
;> AppendEnemyLetter(pos)
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


;@ def GetSpeciesName_53(pos: a, dest: hl)
;@ path: battle/names
;@ Copies the species name of battle position `pos` (system text $05xx) to `dest` and remembers
;@ the position and the destination for AppendEnemyLetter.
;@ test: skip calls a routine in another bank
GetSpeciesName_53::
;> wNameBattler = pos
	ld [wNameBattler], a
;>@sp species = wBattlerSpecies[pos]
	push hl
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld a, [hl]
;> text = 0x500 + species                 # system text group 5: the monster names
	ld l, a
	ld h, $05
;> wNameDest = dest
	pop de
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [wNameDest + 1], a
;> CopySystemText(text, dest)
	call CopySystemText
	ret


;@ def GetMorphName_53(party: a, dest: hl) -> hl
;@ path: battle/names
;@ Name of an enemy that turned into own party monster `party`: the nickname followed by "Like",
;@ and when several enemies copied the same monster a number 1-3 after it (also left in wBattleArg1;
;@ 0 = no number). Returns the address of the $F0 end mark.
;@ test: skip calls a routine with a test-unfriendly name layout
GetMorphName_53::
;> dest = GetPartyMonName_53(party, dest)
	call GetPartyMonName_53
;> mem[dest] = 0x2F; mem[dest + 1] = 0x46        # "Li"
	ld a, $2f
	ld [hli], a
	ld a, $46
	ld [hli], a
;> mem[dest + 2] = 0x48; mem[dest + 3] = 0x42    # "ke"
	ld a, $48
	ld [hli], a
	ld a, $42
	ld [hli], a
;> dest += 4; mem[dest] = 0xF0
	ld [hl], $f0
;> slot = wNamePos & 3
	push hl
	ld hl, wEnemyMorph
	ld a, [wNamePos]
	and $03
;> if slot not in (1, 2):                  # the first enemy
	cp $01
	jr z, .slot1

	cp $02
	jr z, .slot2

;>@one     if wEnemyMorph[0] == wEnemyMorph[1]: n = 1
	ld a, [hli]
	cp [hl]
	jr z, .one

;>     elif wEnemyMorph[0] == wEnemyMorph[2]: n = 1
	inc hl
	cp [hl]
	jr z, .one

;>@none     else: n = 0
	jr .none

;> elif slot == 1:
.slot1
;>@two     if wEnemyMorph[0] == wEnemyMorph[1]: n = 2
	ld a, [hli]
	cp [hl]
	jr z, .two

;>     elif wEnemyMorph[1] == wEnemyMorph[2]: n = 1
	ld a, [hli]
	cp [hl]
	jr z, .one

;>     else: n = 0
	jr .none

;> else:                                    # the third enemy: count the earlier ones that match
.slot2
;>@same     same = (wEnemyMorph[0] == wEnemyMorph[2]) + (wEnemyMorph[1] == wEnemyMorph[2])
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
;=@same
	jr nz, .notFirst

	inc d

.notFirst
	inc hl
	cp [hl]
	jr nz, .notSecond

	inc d

.notSecond
;>@three     n = (0, 2, 3)[same]
	ld a, d
	or a
	jr z, .none

	cp $01
	jr z, .two

;=@three
	pop hl
	ld a, $03
	jr .store

.one
;=@one
	pop hl
	ld a, $01
	jr .store

.two
;=@two
	pop hl
	ld a, $02

.store
;>@w wBattleArg1 = n
	ld [wBattleArg1], a
;> if n:
;>     mem[dest] = n; mem[dest + 1] = 0xF0
	ld [hli], a
	ld [hl], $f0
;>     dest += 1
;> return dest
	ret


.none
;=@none
	pop hl
	xor a
;=@w
	ld [wBattleArg1], a
	ret


;@ def UnusedGetTargetName2_53()
;@ path: unused
;@ Unreachable variant of GetTargetName_53 that writes the target's name into wTextArg2.
;@ test: skip jumps into the middle of another routine
UnusedGetTargetName2_53::
;> wBattleArg2 = addr(wTextArg2) & 0xFF; wBattleArg3 = addr(wTextArg2) >> 8
	ld hl, wTextArg2
	jr GetTargetName_53 + 3

;@ def GetTargetName_53()
;@ path: battle/names
;@ Writes the name of the skill's target (wSkillTarget) into wTextArg0, the first name a battle
;@ message inserts; wBattleArg2/3 point at it.
;@ test: skip calls routines in other banks
GetTargetName_53::
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerName_53(wSkillTarget, addr(wTextArg0))
	call GetBattlerName_53
	ret


;@ def GetUserName_53()
;@ path: battle/names
;@ Writes the name of the skill's user (wSkillUser) into wTextArg0; wBattleArg2/3 point at it.
;@ test: skip calls routines in other banks
GetUserName_53::
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser
	ld a, [wSkillUser]
	ld [wNamePos], a
;> GetBattlerName_53(wSkillUser, addr(wTextArg0))
	call GetBattlerName_53
	ret


;@ def RunActionStart_53()
;@ path: battle/actions
;@ Battle action step 0, once per frame: runs stage wBattleSubStep2 of starting the next action of
;@ the turn (ActionStartStages_53) - who acts, whether an ailment stops it, whether it still wants
;@ and can afford its skill.
;@ test: skip jump table
RunActionStart_53::
;> ActionStartStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages of RunActionStart_53 (wBattleSubStep2 0-8).
ActionStartStages_53::
	dw ActionStart_Begin_53
	dw ActionStart_Reconsider_53
	dw ActionStart_CheckMP_53
	dw ActionStart_PayMP_53
	dw ActionStart_Next_53
	dw ActionStart_CheckDown_53
	dw ActionStart_AfterDown_53
	dw ActionStart_StartPause_53
	dw ActionStart_Pause_53

;@ def ActionStart_Begin_53()
;@ path: battle/actions
;@ Stage 0: takes the next battle position from wTurnOrder (a reaction keeps its user) and checks
;@ what keeps it from acting: an iron lump, paralysis, sleep (it may wake up), the one-turn
;@ conditions of status byte 3 (frozen, lured, stumbling, licked, shocked, feeling good) - each
;@ shows its message and costs the monster its turn. A cursed monster may suffer the curse
;@ (CurseEffect_53), a confused one acts at random (action step $11). An enemy that would repeat a
;@ group skill of its group may switch to Attack. Otherwise it goes on to stage 1.
;@ test: skip calls routines in other banks
ActionStart_Begin_53::
;> wBattleTemp = 0
	xor a
	ld [wBattleTemp], a
;> if wBattleSubStep == 0x12:             # a second action in the same turn
	ld a, [wBattleSubStep]
	cp $12
	jr nz, .reset

;>     wBattleTemp = 0x12; wBattleSubStep = 0
	ld [wBattleTemp], a
	xor a
	ld [wBattleSubStep], a
;>@o     wBattlerOrder[wSkillUser] = 2
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $02

.reset
;> wHitCount = 0; wBattleStepArg0 = 0
	xor a
	ld [wHitCount], a
	ld [wBattleStepArg0], a
;> wBattleStepArg1 = 0; mem[0xDD6D] = 0
	ld [wBattleStepArg1], a
	ld [wReflectAnim], a
;> mem[0xDD6E] = 0; wBattleAnimRunning = 0
	ld [wInterceptState], a
	ld [wBattleAnimRunning], a
;> if not wLinkActive:
;>     wOrderFlag0 = 0
	ld a, [wLinkActive]
	or a
	jr nz, .link

	ld a, $00
	ld [wOrderFlag0], a

.link
;> wBattleAnimDone = 1; wSkillTarget = 0xFF
	ld a, $01
	ld [wBattleAnimDone], a
	ld a, $ff
	ld [wSkillTarget], a
;> if not wReactionKind:                   # a reaction keeps its user
	ld a, [wReactionKind]
	or a
	jr nz, .user

;>     if wTurnOrderPos == 9:
;>         return EndOfTurn()
	ld a, [wTurnOrderPos]
	cp $09
	jp z, .endOfTurn

;>     pos = wTurnOrder[wTurnOrderPos]
	ld hl, wTurnOrder
	call ReadTableByte_53
;>     if pos == 0x10:                    # Terry uses an item
	cp $10
	jr nz, .monster

;>         wBattleSubStep = 9; return
	ld a, $09
	ld [wBattleSubStep], a
	ret


.monster
;>     wSkillUser = pos
	ld [wSkillUser], a
;>     if CheckBattlerPresent(pos):
;>         wTurnOrderPos += 1; return
	call CheckBattlerPresent
	jp c, .skip

.user
;> if wBattlerOrder[wSkillUser] != 2:
;>     wTurnOrderPos += 1; return
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	call ReadTableByte_53
	cp $02
	jp nz, .skip

;> status = addr(wBattlerStatus) + 8 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
;> if mem[status + 5] & 0xC0: return LoseTurn(0x11)        # "... became a lump of iron!"
	ld a, [hl]
	and $c0
	jr z, .notIron

	ld a, $11
	jp .loseTurn


.notIron
;>@sp wSkillStatusPtr = status
	ld a, l
	sub $05
	ld l, a
	ld [wSkillStatusPtr], a
	ld a, h
	sbc $00
;=@sp
	ld h, a
	ld [wSkillStatusPtr + 1], a
;> if mem[status] & 0x40: return LoseTurn(0x13)            # "... is paralyzed!"
	bit 6, [hl]
	jr z, .notParalyzed

	ld a, $13
	jp .loseTurn


.notParalyzed
;> if mem[status] & 0x80: return LoseTurn(SleepTurn_53(status))   # asleep, or waking up
	bit 7, [hl]
	jr z, .notAsleep

	call SleepTurn_53
	jp .loseTurn


.notAsleep
;> cond = mem[status + 3]
	inc hl
	inc hl
	inc hl
	ld a, [hl]
;> if cond:
	or a
	jr z, .noCondition

;>     if cond & 0x04: return LoseTurn(0x16)                # stumbling: "can't get up yet"
	bit 2, a
	jr z, .notStumbling

	ld a, $16
	jp .loseTurn


.notStumbling
;>     if cond & 0x01: return LoseTurn(0x12)                # "... is frozen solid!"
	bit 0, a
	jr z, .notFrozen

	ld a, $12
	jp .loseTurn


.notFrozen
;>     if cond & 0x02: return LoseTurn(0x14)                # lured: "can't resist dancing"
	bit 1, a
	jr z, .notLured

	ld a, $14
	jr .loseTurn

.notLured
;>     if cond & 0x08: return LoseTurn(0x15)                # licked: "... is shivering!"
	bit 3, a
	jr z, .notLicked

	ld a, $15
	jr .loseTurn

.notLicked
;>     if cond & 0x10: return LoseTurn(0x17)                # shocked: "cowers in fear"
	bit 4, a
	jr z, .notShocked

	ld a, $17
	jr .loseTurn

.notShocked
;>     if cond & 0x20: return LoseTurn(0x18)                # feeling good: "daydreaming"
	bit 5, a
	jr z, .noCondition

	ld a, $18
	jr .loseTurn

.noCondition
;> DrawRandom_53()
	call DrawRandom_53
;> status = wSkillStatusPtr
	ld a, [wSkillStatusPtr]
	ld l, a
	ld a, [wSkillStatusPtr + 1]
	ld h, a
;> if mem[status] & 0x20 and wRandomHigh < 0x40:           # cursed: one turn in four
	bit 5, [hl]
	jr z, .notCursed

	ld a, [wRandomHigh]
	cp $40
	jr nc, .notCursed

;>     CurseEffect_53()
	call CurseEffect_53
;>@hp     if wBattlerHP[wSkillUser] == 0:
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	ret nz

;>         wBattleSubStep2 = 5            # the curse brought it down
	ld a, $05
	ld [wBattleSubStep2], a
;>     return
	ret


.notCursed
;> if mem[status] & 0x10:                 # confused
	bit 4, [hl]
	jr z, .notConfused

;>     GetUserName_53()
	call GetUserName_53
;>     wTextIndex = 0x10; wTextGroup = 0  # "... is confused!"
	ld a, $10
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     wBattleSubStep = 0x11              # a random action (PickConfusedAction_53)
	ld a, $11
	ld [wBattleSubStep], a
;>@nu     wPersonalityNudge[wSkillUser] = 0
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nu
	ld h, a
	ld [hl], $00
;>     return
	ret


.notConfused
;> if not CheckEnemyRepeatsSkill_53():
	call CheckEnemyRepeatsSkill_53
	jr c, .repeats

;>     wBattleSubStep2 += 1; return LoadActionSkill_53()
	ld hl, wBattleSubStep2
	inc [hl]
	jr LoadActionSkill_53

.loseTurn
;> def LoseTurn(msg):                     # the end of the checks above: the monster cannot act
;>     wBattleArg0 = msg; ShowActionMessage()  # show the message
	ld [wBattleArg0], a
	ld hl, far_ShowActionMessage
	rst $10
;>     ClearTurnAilments_53()
	call ClearTurnAilments_53
;>     wBattleSubStep2 = 7                # a pause, then the next monster
	ld a, $07
	ld [wBattleSubStep2], a

.skip
;>     wTurnOrderPos += 1
	ld hl, wTurnOrderPos
	inc [hl]
	ret


.endOfTurn
;> def EndOfTurn():
;>     wBattleSubStep = 0; wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep], a
	ld [wBattleSubStep2], a
;>     wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
	ret


.repeats
;> if IsSmart_53():                       # a clever enemy rethinks in stage 1
	call IsSmart_53
	jr nz, ReplaceWithAttack_53

;>     wBattleSubStep2 += 1; return LoadActionSkill_53()
	ld hl, wBattleSubStep2
	inc [hl]
	jr LoadActionSkill_53

;> return ReplaceWithAttack_53()

;@ def ReplaceWithAttack_53()
;@ path: battle/actions
;@ Turns the action of the skill user into a plain Attack (skill $3A) whose target the battle AI
;@ picks again (RechooseAction_53), and marks that in wOrderFlag0.
;@ test: skip calls routines in other banks
ReplaceWithAttack_53::
;>@a wBattlerAction[2 * wSkillUser] = 0x3A        # Attack
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld [hl], $3a
;>@nu wPersonalityNudge[wSkillUser] = 0
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nu
	ld h, a
	ld [hl], $00
;> RechooseAction_53()
	call RechooseAction_53
;> wOrderFlag0 = 1
	ld a, $01
	ld [wOrderFlag0], a

;@ def LoadActionSkill_53()
;@ path: battle/actions
;@ Makes the skill of the user's action the skill being used (wSkillId) and loads its flags.
;@ test: skip calls a routine in another bank
LoadActionSkill_53::
;>@s wSkillId = wBattlerAction[2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@s
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillId], a
;> LoadSkillFlags()                         # the skill's targets and flags
	ld hl, far_LoadSkillFlags
	rst $10
	ret


;@ def ActionStart_Reconsider_53()
;@ path: battle/actions
;@ Stage 1: a clever monster (intelligence class 2) that is not under a direct order and has no
;@ personality effect pending may choose its whole action again now (action step $18), unless its
;@ skill must not be changed (SquallHit, skills with flag bit 3 of wSkillFlags1, a confused monster,
;@ the second turn of HighJump or LifeSong, the first action of the turn). Then the target is
;@ checked: a missing target is replaced (ActionStart_TargetGone_53); a monster of intelligence
;@ class 1-2 that is neither confused nor under direct orders lets the AI pick the target anew.
;@ test: skip calls routines in other banks
ActionStart_Reconsider_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wBattleStepArg0:                    # the target was already worked out
	ld a, [wBattleStepArg0]
	or a
	jr z, .think

;>     if wBattleStepArg0 != 2:
;>         wBattleSubStep2 += 1
	cp $02
	jp z, KeepActionTarget_53

	ld hl, wBattleSubStep2
	inc [hl]
;>     return KeepActionTarget_53()
	jp KeepActionTarget_53


.think
;> if wBattleTemp or wGameModeStep: return CheckTarget()
	ld a, [wBattleTemp]
	or a
	jp nz, .checkTarget

	ld a, [wGameModeStep]
	or a
	jp nz, .checkTarget

;> if wBattlerIntClass[wSkillUser] != 2: return CheckTarget()
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	call ReadTableByte_53
	cp $02
	jr nz, .checkTarget

;> if IsUnderDirectOrder_53(): return CheckTarget()
	call IsUnderDirectOrder_53
	jr z, .checkTarget

;>@nu if wPersonalityNudge[wSkillUser]: return CheckTarget()
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nu
	ld h, a
	ld a, [hl]
	or a
	jr nz, .checkTarget

;>@sk wSkillId = wBattlerAction[2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@sk
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillId], a
;> if wSkillId == 0x55: return CheckTarget()          # SquallHit
	ld a, [wSkillId]
	cp $55
	jr z, .checkTarget

;> LoadSkillFlags()                         # the skill's targets and flags
	ld hl, far_LoadSkillFlags
	rst $10
;> if wSkillFlags1 & 0x08: return CheckTarget()
	ld a, [wSkillFlags1]
	bit 3, a
	jr nz, .checkTarget

;> status = addr(wBattlerStatus) + 8 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if mem[status] & 0x10: return CheckTarget()        # confused
	bit 4, [hl]
	jr nz, .checkTarget

;> if mem[status + 4] & 0x04: return CheckTarget()    # high in the sky (HighJump)
	ld bc, $0004
	add hl, bc
	bit 2, [hl]
	jr nz, .checkTarget

;> if mem[status + 5] & 0x10: return CheckTarget()    # singing the LifeSong
	inc hl
	bit 4, [hl]
	jr nz, .checkTarget

;> if wTurnOrderPos == 0: return CheckTarget()
	ld a, [wTurnOrderPos]
	or a
	jr z, .checkTarget

;> wBattleSubStep2 = 0; wBattleSubStep = 0x18          # choose the action again
	xor a
	ld [wBattleSubStep2], a
	ld a, $18
	ld [wBattleSubStep], a
;>@o wBattlerOrder[wSkillUser] = 1
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $01
;> return
	ret


.checkTarget
;> def CheckTarget():
;>     wSkillId = wBattlerAction[2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	call ReadTableByte_53
	ld [wSkillId], a
;>     wSkillTarget = wBattlerAction[2 * wSkillUser + 1]
	inc hl
	ld a, [hl]
	ld [wSkillTarget], a
;>     LoadSkillFlags()
	ld hl, far_LoadSkillFlags
	rst $10
;>     if wSkillId == 0x14:               # Sacrifice
	ld a, [wSkillId]
	cp $14
	jr nz, .notSacrifice

;>         if not (wBattlerStatus[8 * wSkillUser + 1] & 0x01): return RechooseAction_53()
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	jr z, RechooseAction_53

;>         return
	ret


.notSacrifice
;>     if wSkillId in (0x32, 0x96): return          # Farewell, LifeDance
	cp $32
	ret z

	cp $96
	ret z

;>     if wSkillId in (0x95, 0xAD): return          # LifeSong, ALLREVIVE
	cp $95
	ret z

	cp $ad
	ret z

;>     if CheckBattlerPresent(wSkillTarget): return ActionStart_TargetGone_53()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, ActionStart_TargetGone_53

;>     if wBattlerIntClass[wSkillUser] == 0: return
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	call ReadTableByte_53
	or a
	ret z

;>     if wBattlerStatus[8 * wSkillUser] & 0x10: return  # confused
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	ret nz

;>@t     if wBattlerTactic[wSkillUser] == 3: return        # direct orders
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld a, [hl]
	cp $03
	ret z

;>     return RechooseAction_53()

;@ def RechooseAction_53()
;@ path: battle/actions
;@ Clears the target of the user's action and switches to action step $19, where the battle AI
;@ picks the target again.
RechooseAction_53::
;>@t wBattlerAction[2 * wSkillUser + 1] = 0xFF
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@t
	adc h
	ld h, a
	ld [hl], $ff
;> wBattleSubStep2 = 0; wBattleSubStep = 0x19
	xor a
	ld [wBattleSubStep2], a
	ld a, $19
	ld [wBattleSubStep], a
	ret


;@ def ActionStart_TargetGone_53()
;@ path: battle/actions
;@ The target of the action is no longer in the fight. CallHelp, YellHelp and QuadHits ($51-$53)
;@ and single-target skills of monsters that think (intelligence class 1-2, not under a direct
;@ order) get a new target from the battle AI (RunTargetPicker); a skill on a whole side is aimed at
;@ the first monster still present on that side.
;@ test: skip calls routines in other banks
ActionStart_TargetGone_53::
;>@q if wSkillId not in (0x51, 0x52, 0x53):
	ld a, [wSkillId]
	cp $51
	jr z, .choose

	cp $52
	jr z, .choose

;=@q
	cp $53
	jr z, .choose

;>     if not (wSkillTargeting & 0x01): return RetargetSide()   # a skill on a whole side
	ld a, [wSkillTargeting]
	and $01
	jr z, KeepActionTarget_53.side

;>     if wBattlerIntClass[wSkillUser] == 0: return
	call IsSmart_53
	or a
	ret z

;>     if IsUnderDirectOrder_53(): return
	call IsUnderDirectOrder_53
	ret z

.choose
;> RunTargetPicker()                         # the battle AI picks a target
	ld hl, far_RunTargetPicker
	rst $10

KeepActionTarget_53:
;> wBattleStepArg0 = 0
	xor a
	ld [wBattleStepArg0], a
;>@k entry = addr(wBattlerAction) + 2 * wSkillUser + 1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@k
	adc h
	ld h, a
	jr .setTarget

.side
;> def RetargetSide():
;>     side = wSkillTarget & 4
	ld a, [wSkillTarget]
	and $04
	ld c, a
;>@f     for pos in range(side, side + 3):
	ld b, $03

.find
;>         if not CheckBattlerPresent(pos): break
	ld a, c
	call CheckBattlerPresent
	jr nc, .found

;=@f
	inc c
	dec b
	jr nz, .find

;>     else: return
	ret


.found
;>@e     entry = addr(wBattlerAction) + 2 * wSkillUser + 1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@e
	adc h
	ld h, a
;>     mem[entry] = pos
	ld [hl], c
;>     wSkillTarget = pos

.setTarget
;> wSkillTarget = mem[entry]
	ld a, [hl]
	ld [wSkillTarget], a
	ret


;@ def ActionStart_CheckMP_53()
;@ path: battle/actions
;@ Stage 2: checks that the user has the MP for its skill (the MP cost is the low byte of word 2 of
;@ the skill's record; the second turn of HighJump and LifeSong is free) and that nothing blocks
;@ the kind of skill: a spell against a MagicWall (the MP are spent anyway) or under StopSpell, a
;@ dance under DanceShut, a breath under MouthShut. A failing skill shows its message and ends the
;@ action (a clever monster rethinks instead, RethinkUnusableSkill_53); otherwise it goes on.
;@ test: skip calls routines in other banks
ActionStart_CheckMP_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> LoadSkillFlags()                         # the skill's targets and flags
	ld hl, far_LoadSkillFlags
	rst $10
;> wBattleArg0 = wSkillId; wBattleArg1 = 0
	ld a, [wSkillId]
	ld [wBattleArg0], a
	xor a
	ld [wBattleArg1], a
;> wBattleArg2 = 4; GetSkillWord()        # word 2 of the skill record: the MP cost
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
;> cost = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a
;> if cost:
	or a
	jp z, .enoughMP

;>     mp = GetBattlerMP(wSkillUser)
	ld b, $00
	ld a, [wSkillUser]
	call GetBattlerMP
;>@lt     if mp < cost:
	call CompareHLBC
	jr z, .enoughMP

	ld a, l
	sub c
	ld a, h
;=@lt
	sbc b
	jr nc, .enoughMP

;>         if not IsSecondTurnOfSkill_53():   # not enough MP
	call IsSecondTurnOfSkill_53
	jr c, .enoughMP

;>             if IsSmart_53(): RethinkUnusableSkill_53()
	call IsSmart_53
	call z, RethinkUnusableSkill_53
;>             if wSkillFlags1 & 0x40: return ShowActionFailed_53(0xF7)    # a spell
	ld a, [wSkillFlags1]
	bit 6, a
	jr z, .notSpell

	ld a, $f7
	jp ShowActionFailed_53


.notSpell
;>             if wSkillFlags1 & 0x20: return ShowActionFailed_53(0xF9)    # a dance
	bit 5, a
	jr z, .notDance

	ld a, $f9
	jp ShowActionFailed_53


.notDance
;>             if wSkillFlags1 & 0x10: return ShowActionFailed_53(0xF8)    # a breath
	bit 4, a
	jr z, .notBreath

	ld a, $f8
	jp ShowActionFailed_53


.notBreath
;>             ShowNotEnoughMP_53(); return
	call ShowNotEnoughMP_53
	ret


.enoughMP
;> if wSkillFlags1 & 0x40:                # a spell
	ld a, [wSkillFlags1]
	bit 6, a
	jr z, .notSpell2

;>@w     if wSideFlags[wSkillUser >> 2] & 0x08:   # the user's side is behind a MagicWall
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
;=@w
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr z, .notWall

;>         if IsSmart_53(): RethinkUnusableSkill_53()
	call IsSmart_53
	call z, RethinkUnusableSkill_53
;>         PayMPClamped_53(); msg = 0x1F            # "But spell was broken!"
	call PayMPClamped_53
	ld a, $1f
	jr .fail

.notWall
;>     else:
;>         if not (wBattlerStatus[8 * wSkillUser + 1] & 0x01): return   # no StopSpell
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	ret z

;>         if IsSmart_53(): RethinkUnusableSkill_53()
	call IsSmart_53
	call z, RethinkUnusableSkill_53
;>         msg = 0x1E                     # "But the spell is blocked"
	ld a, $1e
	jr .fail

.notSpell2
;> elif wSkillFlags1 & 0x20:              # a dance
	bit 5, a
	jr z, .notDance2

;>     if not (wBattlerStatus[8 * wSkillUser + 1] & 0x40): return   # DanceShut
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 6, [hl]
	ret z

;>     if IsSmart_53(): RethinkUnusableSkill_53()
	call IsSmart_53
	call z, RethinkUnusableSkill_53
;>     msg = 0x21                         # "But the dance ..."
	ld a, $21
	jr .fail

.notDance2
;> elif not (wSkillFlags1 & 0x10): return
	bit 4, a
	ret z

;> else:                                  # a breath
;>     if not (wBattlerStatus[8 * wSkillUser + 1] & 0x80): return   # MouthShut
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	ret z

;>     if IsSmart_53(): RethinkUnusableSkill_53()
	call IsSmart_53
	call z, RethinkUnusableSkill_53
;>     msg = 0x20                         # "But its mouth is bound shut"
	ld a, $20

.fail
;> PayMP_53()
	push af
	call PayMP_53
	pop af
;> return ShowActionFailed_53(msg)

;@ def ShowActionFailed_53(msg: a)
;@ path: battle/actions
;@ Shows action message `msg` for the user (ShowActionMessage) and ends its action (EndFailedAction_53).
;@ test: skip calls routines in other banks
ShowActionFailed_53::
;> wBattleArg0 = msg; ShowActionMessage()
	ld [wBattleArg0], a
	ld hl, far_ShowActionMessage
	rst $10

;@ def EndFailedAction_53()
;@ path: battle/actions
;@ Ends an action that did not happen: an ordinary action goes on with the next monster of the turn;
;@ a reaction goes to action step 6 and wReactionKind becomes $20.
EndFailedAction_53::
;> if not wReactionKind:
	ld a, [wReactionKind]
	or a
	jr nz, .reaction

;>     wTurnOrderPos += 1; wBattleSubStep2 = 0
	ld hl, wTurnOrderPos
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
;>     return
	ret


.reaction
;> wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;> wReactionKind = 0x20
	ld a, $20
	ld [wReactionKind], a
	ret


;@ def RethinkUnusableSkill_53()
;@ path: battle/actions
;@ For a clever monster whose skill cannot be used: unless the action is a reaction, a second action,
;@ the monster is confused or under a direct order, it goes back to choosing its action (action
;@ step $16) and the caller is left as well (its return address is dropped).
;@ test: skip drops the caller's return address
RethinkUnusableSkill_53::
;> if wReactionKind: return
	ld a, [wReactionKind]
	or a
	ret nz

;> if wBattlerStatus[8 * wSkillUser] & 0x10: return    # confused
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	ret nz

;> if wBattleTemp: return
	ld a, [wBattleTemp]
	or a
	ret nz

;> if IsUnderDirectOrder_53(): return
	call IsUnderDirectOrder_53
	ret z

;> wBattleSubStep = 0x16; wBattleSubStep2 = 0
	ld a, $16
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;>@o wBattlerOrder[wSkillUser] = 1
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $01
;> return                                 # from the caller too
	pop af
	ret


;@ def IsSecondTurnOfSkill_53() -> carry
;@ path: battle/actions
;@ Carry when the user is in the second turn of a two-turn skill that needs no more MP: HighJump
;@ ($42) while high in the sky, LifeSong ($95) while singing.
;@ test: wSkillUser = rand(0, 7); wSkillId = choice([0x42, 0x95, 0x3A])
IsSecondTurnOfSkill_53::
;> status = addr(wBattlerStatus4) + 8 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
;>@no if not (mem[status] & 0x04) and not (mem[status + 1] & 0x10): return False
	bit 2, [hl]
	jr nz, .sky

	inc hl
	bit 4, [hl]
	jr nz, .song

.no
;=@no
	xor a
	ret


.sky
;> if mem[status] & 0x04: return wSkillId == 0x42
	ld a, [wSkillId]
	cp $42
	jr nz, .no

	jr .yes

.song
;>@yes return wSkillId == 0x95
	ld a, [wSkillId]
	cp $95
	jr nz, .no

.yes
;=@yes
	scf
	ret


;@ def ShowNotEnoughMP_53()
;@ path: battle/actions
;@ The user lacks the MP for its skill: puts the user's and the target's names into wTextArg0/1 and
;@ shows the fitting message ("... tries to fly high! But not enough MP!" and the like, group 1
;@ $0C-$12, or the general "tries to use ..." $1D), then ends the action.
;@ test: skip calls routines in other banks
ShowNotEnoughMP_53::
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser; GetBattlerName_53(wSkillUser, addr(wTextArg0))
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerName_53
;> wBattleArg2 = addr(wTextArg1) & 0xFF; wBattleArg3 = addr(wTextArg1) >> 8
	ld hl, wTextArg1
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg1))
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
;>@m if wSkillId == 0x42: msg = 0x0C              # HighJump
	ld a, [wSkillId]
	cp $42
	jr z, .highJump

;>@n elif wSkillId in (0x52, 0x53): msg = 0x0D    # CallHelp, YellHelp
	cp $52
	jr z, .callHelp

	cp $53
	jr z, .callHelp

;>@o elif wSkillId == 0x56: msg = 0x0E            # PsycheUp
	cp $56
	jr z, .psycheUp

;>@p elif wSkillId == 0x6F: msg = 0x0F            # Curse
	cp $6f
	jr z, .curse

;>@q elif wSkillId == 0x8F: msg = 0x10            # SuckAll
	cp $8f
	jr z, .suckAll

;>@r elif wSkillId == 0x92: msg = 0x11            # MouthShut
	cp $92
	jr z, .mouthShut

;>@s elif wSkillId == 0x95: msg = 0x12            # LifeSong
	cp $95
	jr z, .lifeSong

;> else: return ShowActionFailed_53(0x1D)  # "... tries to use ...! But not enough MP!"
	ld a, $1d
	jp ShowActionFailed_53


.highJump
;=@m
	ld a, $0c
	jr .show

.callHelp
;=@n
	ld a, $0d
	jr .show

.psycheUp
;=@o
	ld a, $0e
	jr .show

.curse
;=@p
	ld a, $0f
	jr .show

.suckAll
;=@q
	ld a, $10
	jr .show

.mouthShut
;=@r
	ld a, $11
	jr .show

.lifeSong
;=@s
	ld a, $12

.show
;> wTextIndex = msg; wTextGroup = 1
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> return EndFailedAction_53()
	jp EndFailedAction_53


;@ def IsSmart_53() -> zero
;@ path: battle/actions
;@ Zero flag when the skill user belongs to the cleverest intelligence class (2); a = its class.
;@ test: wSkillUser = rand(0, 7)
IsSmart_53::
;> return wBattlerIntClass[wSkillUser] == 2
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	call ReadTableByte_53
	cp $02
	ret


;@ def ActionStart_PayMP_53()
;@ path: battle/actions
;@ Stage 3: a clever enemy that would still repeat a group skill of its group (and was not replaced
;@ yet) switches to Attack; otherwise the action goes on to action step 1 (carrying out the skill)
;@ and the MP are paid.
;@ test: skip calls routines in other banks
ActionStart_PayMP_53::
;>@r if IsSmart_53() and CheckEnemyRepeatsSkill_53() and not wOrderFlag0:
	call IsSmart_53
	jr nz, .pay

	call CheckEnemyRepeatsSkill_53
	jr nc, .pay

;=@r
	ld a, [wOrderFlag0]
	or a
	jr nz, .pay

;>     ReplaceWithAttack_53(); return
	call ReplaceWithAttack_53
	ret


.pay
;> wBattleSubStep += 1; wBattleSubStep2 = 0
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
;> return PayMP_53()

;@ def PayMP_53()
;@ path: battle/actions
;@ Takes the MP cost of the skill (the low byte of word 2 of its record) from the user, without a
;@ lower limit; nothing when a Celestial light covers the user (wPersonalityNudge bit 4) or
;@ IsMPFree_53 says so. Farewell ($32) uses up all MP.
;@ test: skip calls a routine in another bank
PayMP_53::
;>@nu if wPersonalityNudge[wSkillUser] & 0x10: return      # Celestial light
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nu
	ld h, a
	bit 4, [hl]
	ret nz

;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> if IsMPFree_53(wSkillId): return
	call IsMPFree_53
	ret c

;> wBattleArg1 = 0; wBattleArg2 = 4
	xor a
	ld [wBattleArg1], a
	ld a, $04
	ld [wBattleArg2], a
;> GetSkillWord()                         # word 2 of the skill record: the MP cost
	ld hl, far_GetSkillWord
	rst $10
;> cost = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a
;>@mp mp = addr(wBattlerMP) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@mp
	adc h
	ld h, a
;> mem16[mp] = (mem16[mp] - cost) & 0xFFFF
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc $00
	ld [hl], a
;> if wSkillId == 0x32:                   # Farewell
	ld a, [wSkillId]
	cp $32
	ret nz

;>     mem16[mp] = 0
	xor a
	ld [hld], a
	ld [hl], a
	ret


;@ def ActionStart_Next_53()
;@ path: battle/actions
;@ Stage 4: on to the next entry of the turn order.
ActionStart_Next_53::
;> wBattleSubStep2 = 0; wTurnOrderPos += 1
	xor a
	ld [wBattleSubStep2], a
	ld hl, wTurnOrderPos
	inc [hl]
	ret


;@ def ActionStart_CheckDown_53()
;@ path: battle/actions
;@ Stage 5, after the curse struck: a monster with HP left goes on with stage 1; one at 0 HP goes
;@ down - a called-in helper (fourth position) disappears, any other is out of action - with its
;@ message, then stage 6.
;@ test: skip calls routines in other banks
ActionStart_CheckDown_53::
;>@hp if mem16[addr(wBattlerHP) + 2 * wSkillUser]:
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	jr z, .down

;>     wBattleSubStep2 = 1; return
	ld a, $01
	ld [wBattleSubStep2], a
	ret


.down
;> GetUserName_53()
	call GetUserName_53
;> pos = wSkillUser
	ld a, [wSkillUser]
	ld b, a
;> if pos & 3 == 3:                       # a monster called in to help
	and $03
	cp $03
	jr nz, .monster

;>@s     wSideFlags[pos >> 2] &= ~0x04      # the called dragon is gone
	ld a, b
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
;=@s
	ld l, a
	ld a, $00
	adc h
	ld h, a
	res 2, [hl]
;>@st     wBattlerState[pos] = 0xFF
	ld a, b
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@st
	ld h, a
	ld [hl], $ff
;>     msg = 0xE6                         # "... disappears!"
	ld a, $e6
	jr .show

.monster
;> else:
;>@d     wBattlerState[pos] = 1             # out of action
	ld a, b
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@d
	ld h, a
	ld [hl], $01
;>@own     msg = 0xE3 if IsUserOnOwnSide_53() else 0xE7     # "collapses" / "is out of HP and faints"
	call IsUserOnOwnSide_53
	jr c, .own

	ld a, $e7
	jr .show

.own
;=@own
	ld a, $e3

.show
;> wTextIndex = msg; wTextGroup = 0
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep2 = 6
	ld a, $06
	ld [wBattleSubStep2], a
	ret


;@ def ActionStart_AfterDown_53()
;@ path: battle/actions
;@ Stage 6: after a monster went down - UserFalls, the status icons and CheckBattleOver (which
;@ checks whether the battle is decided). Unless wSkillMsgMode is $FF the battle steps are
;@ cleared and the battle goes on with battle step $0A.
;@ test: skip calls routines in other banks
ActionStart_AfterDown_53::
;> UserFalls()
	ld hl, far_UserFalls
	rst $10
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> CheckBattleOver()
	ld hl, far_CheckBattleOver
	rst $10
;> if wSkillMsgMode == 0xFF: return
	ld a, [wSkillMsgMode]
	cp $ff
	ret z

;>@f fill(addr(wBattleSubStep), 7, 0)       # the step variables up to wPanelMode
	xor a
	ld hl, wBattleSubStep
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@f
	ld [hli], a
	ld [hli], a
	ld [hli], a
;> wBattleArg2 = 0; wBattleStep = 0x0A
	ld [wBattleArg2], a
	ld a, $0a
	ld [wBattleStep], a
	ret


;@ def SleepTurn_53(status: hl) -> a
;@ path: battle/actions
;@ A sleeping monster's turn (`status` = its status byte 0; bit 7 asleep, bits 2-3 turns left). It
;@ wakes up if wRandomHigh is at most a limit that shrinks with the turns left ($FF with none left
;@ = surely, $E0, $A0, $60); otherwise one turn less. Returns the message: $0F "... is sleeping"
;@ or $DB "... wakes up!".
;@ test: skip calls a routine in another bank
SleepTurn_53::
;> left = mem[status] & 0x0C
	ld a, [hl]
	and $0c
;>@c0 if left == 0: limit = 0xFF
	jr z, .none

;>@c4 elif left == 4: limit = 0xE0
	cp $04
	jr z, .one

;>@c8 elif left == 8: limit = 0xA0
	cp $08
	jr z, .two

;> else: limit = 0x60
	ld b, $60
	jr .roll

.two
;=@c8
	ld b, $a0
	jr .roll

.one
;=@c4
	ld b, $e0
	jr .roll

.none
;=@c0
	ld b, $ff

.roll
;> if wRandomHigh > limit:                # sleeps on
	ld a, [wRandomHigh]
	cp b
	jr z, .wake

	jr c, .wake

;>@dec     mem[status] = mem[status] & 0xF3 | (left - 1) & 0x0C     # one turn less
	ld a, [hl]
	and $f3
	ld b, a
	ld a, [hl]
	and $0c
	dec a
;=@dec
	push bc
	push af
	pop bc
	bit 5, c
	pop bc
	jr nz, .zero

;=@dec
	and $0c
	jr .store

.zero
;=@dec
	xor a

.store
;=@dec
	or b
	ld [hl], a
;>     return 0x0F                        # "... is sleeping."
	ld a, $0f
	ret


.wake
;> mem[status] &= 0x73                    # awake: sleep and its turns cleared
	ld a, [hl]
	and $73
	ld [hl], a
;> wSkillTarget = wSkillUser; UpdateStatusIcon_50()
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> return 0xDB                            # "... wakes up!"
	ld a, $db
	ret


;@ def ClearTurnAilments_53()
;@ path: battle/actions
;@ Clears the one-turn conditions of the skill user (bits 0-5 of status byte 3: frozen, lured,
;@ stumbling, licked, shocked, feeling good). Keeps all registers.
;@ test: wSkillUser = rand(0, 7)
ClearTurnAilments_53::
;>@c mem[addr(wBattlerStatus3) + 8 * wSkillUser] &= 0xC0
	push af
	push bc
	push de
	push hl
	ld a, [wSkillUser]
	ld hl, wBattlerStatus3
;=@c
	call AddEightTimes
	ld a, [hl]
	and $c0
	ld [hl], a
	pop hl
	pop de
;=@c
	pop bc
	pop af
	ret


;@ def PayMPClamped_53()
;@ path: battle/actions
;@ Takes the MP cost of the skill from the user, but not below 0 (a spell broken by a MagicWall).
;@ Keeps all registers.
;@ test: skip calls a routine in another bank
PayMPClamped_53::
;>@a wBattleArg0 = wSkillId; wBattleArg1 = 0
	push af
	push bc
	push de
	push hl
	ld a, [wSkillId]
	ld [wBattleArg0], a
;=@a
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 4; GetSkillWord()        # the MP cost
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
;> cost = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a
	ld b, $00
;>@mp mp = addr(wBattlerMP) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@mp
	adc h
	ld h, a
;>@x mem16[mp] = max(mem16[mp] - cost, 0)
	push hl
	ld a, [hli]
	ld h, [hl]
	sub c
	ld l, a
	ld a, h
;=@x
	sbc b
	ld h, a
	jr nc, .store

	ld hl, $0000

.store
;=@x
	pop bc
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
;=@x
	pop hl
	pop de
	pop bc
	pop af
	ret


;@ def IsMPFree_53(skill: a) -> carry
;@ path: battle/actions
;@ Carry when using `skill` costs no MP now: HighJump ($42) while already high in the sky, LifeSong
;@ ($95) while already singing, or a spell whose MP a MagicWall on the user's side already took.
;@ Farewell, MegaMagic and LifeDance always cost their MP.
;@ test: skill = choice([0x32, 0x42, 0x66, 0x95, 0x96, 0x03, 0x3A]); wSkillUser = rand(0, 7)
IsMPFree_53::
;>@f if skill in (0x32, 0x66, 0x96): return False   # Farewell, MegaMagic, LifeDance
	cp $32
	jr z, .no

;>@h if skill == 0x42: return mem[addr(wBattlerStatus4) + 8 * wSkillUser] & 0x0C != 0
	cp $42
	jr z, .highJump

;=@f
	cp $66
	jr z, .no

;>@l if skill == 0x95: return mem[addr(wBattlerStatus5) + 8 * wSkillUser] & 0x30 != 0
	cp $95
	jr z, .lifeSong

;=@f
	cp $96
	jr z, .no

;> if not (wSkillFlags1 & 0x40): return False      # not a spell
	ld a, [wSkillFlags1]
	bit 6, a
	jr z, .no

;>@w return wSideFlags[wSkillUser >> 2] & 0x08 != 0  # MagicWall
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
;=@w
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr nz, .yes

;=@w
	jr .no

.highJump
;=@h
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, .yes

.no
;=@h
	xor a
	ret


.lifeSong
;=@l
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $30
	jr z, .no

.yes
;=@l
	scf
	ret


;@ def ReadTableByte_53(index: a, table: hl) -> a
;@ path: battle/actions
;@ Byte `index` of `table` (hl points at it afterwards).
;@ test: table = 0xC000; index = rand(0, 255)
ReadTableByte_53::
;>@r return mem[table + index]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@r
	ret


;@ def PickConfusedAction_53()
;@ path: battle/actions
;@ Action step $11: a confused monster does something at random instead of its own action. Half
;@ the time it hits an ally (HitAlly $99), a quarter an enemy (HitEnemy $9A); otherwise an enemy
;@ monster picks one of $9A-$A1 (HitEnemy ... RUN; running away only in a wild battle), an own or
;@ link monster HitRandom/Scared ($9B/$9C, two in three) or Trip ($9E). The battle AI then picks
;@ the target (action step $10).
;@ test: skip calls routines in other banks
PickConfusedAction_53::
;> DrawRandom_53()
	call DrawRandom_53
;>@hitAlly if wRandomHigh & 0x02: action = 0x99          # HitAlly
	ld a, [wRandomHigh]
	bit 1, a
	jr nz, .hitAlly

;>@hitEnemy elif wRandomHigh & 0x01: action = 0x9A        # HitEnemy
	bit 0, a
	jr nz, .hitEnemy

;>@own elif wLinkActive or wSkillUser < 4:
;>@own2     action = 0x9B + (wRandomLow & 1) if wRandomLow >= 0x55 else 0x9E   # HitRandom / Scared, or Trip
;=@own
	ld a, [wLinkActive]
	or a
	jr nz, .ownSide

	ld a, [wSkillUser]
	cp $04
	jr c, .ownSide

;> else:
;>     action = 0x9A + (wRandomLow & 7)
	ld a, [wRandomLow]
	and $07
	add $9a
;>@x     if action == 0xA1 and wBattleType: return PickConfusedAction_53()   # RUN only in wild battles
	cp $a1
	jr nz, .set

;=@x
	ld b, a
	ld a, [wBattleType]
	or a
	ld a, b
	jr z, .set

	jr PickConfusedAction_53

.hitAlly
;=@hitAlly
	ld a, $99
	jr .set

.hitEnemy
;=@hitEnemy
	ld a, $9a
	jr .set

.ownSide
;=@own2
	ld a, [wRandomLow]
	cp $55
	jr c, .trip

	and $01
	add $9b
	jr .set

.trip
;=@own2
	ld a, $9e

.set
;>@a wSkillId = action; wBattlerAction[2 * wSkillUser] = action
	ld [wSkillId], a
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillId]
	ld [hl], a
;> wBattleSubStep = 0x10
	ld a, $10
	ld [wBattleSubStep], a
;> RunTargetPicker()
	ld hl, far_RunTargetPicker
	rst $10
	ret


;@ def CurseEffect_53()
;@ path: battle/actions
;@ A curse strikes the user (one turn in four while cursed): with wRandomLow below $40 it cannot
;@ move, below $80 it loses a sixth of its maximum HP, below $C0 a sixth of its maximum MP, else it
;@ becomes confused (and acts at random, action step $11). Shows "A curse is cast on ..." with the
;@ effect ($19-$1C); nothing when there was nothing to lose.
;@ test: skip calls routines in other banks
CurseEffect_53::
;> keep = wSkillTarget; wSkillTarget = wSkillUser
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> GetTargetName_53(); wSkillTarget = keep
	call GetTargetName_53
	pop af
	ld [wSkillTarget], a
;> if wRandomLow < 0x40: msg = CannotMove()
	ld a, [wRandomLow]
	cp $40
	jr c, .cannotMove

;> elif wRandomLow < 0x80: msg = LoseHP()
	cp $80
	jr c, .loseHP

;> elif wRandomLow < 0xC0: msg = LoseMP()
	cp $c0
	jr c, .loseMP

;> else:
;>     wBattleSubStep = 0x11              # a random action
	ld a, $11
	ld [wBattleSubStep], a
;>     wBattlerStatus[8 * wSkillUser] |= 0x10     # confused
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 4, [hl]
;>     msg = 0x19                         # "... is confused!"
	ld a, $19
	ld [wTextIndex], a
	jr .show

.cannotMove
;> def CannotMove():
;>     wBattleSubStep2 = 4; wBattleSubStep = 0    # the action ends
	ld a, $04
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleSubStep], a
;>     return 0x1A                        # "... can't move!"
	ld a, $1a
	ld [wTextIndex], a
	jr .show

.loseHP
;> def LoseHP():
;>     wBattleSubStep2 = 5                # then check whether it went down
	ld a, $05
	ld [wBattleSubStep2], a
;>     if IsWordZero_53(addr(wBattlerHP) + 2 * wSkillUser): return None
	ld a, [wSkillUser]
	ld de, wBattlerHP
	call IsWordZero_53
	ret z

;>     if LoseSixthOfMax_53(wSkillUser, addr(wBattlerHP)):
	ld a, [wSkillUser]
	call LoseSixthOfMax_53
	jr nc, .hpShown

;>         mem16[addr(wBattlerHP) + 2 * wSkillUser] = 0
	xor a
	ld [de], a
	dec de
	ld [de], a

.hpShown
;>     return 0x1B                        # "... loses ... HP!"
	ld a, $1b
	ld [wTextIndex], a
	jr .show

.loseMP
;> def LoseMP():
;>     wBattleSubStep2 = 5
	ld a, $05
	ld [wBattleSubStep2], a
;>     LoseSixthOfMaxMP_53()
	call LoseSixthOfMaxMP_53
;>@z     if wSkillAmount == 0: return None
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;=@z
	ld a, l
	or h
	ret z

;>     AmountToTextArg1_53()
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call AmountToTextArg1_53
;>     return 0x1C                        # "... loses ... MP!"
	ld a, $1c
	ld [wTextIndex], a

.show
;> if msg is not None:
;>     wTextIndex = msg; wTextGroup = 0
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def IsWordZero_53(word: de) -> zero
;@ path: battle/actions
;@ Zero flag when the 16-bit value at `word` is 0.
;@ test: word = 0xC000
IsWordZero_53::
;>@z return mem16[word] == 0
	push hl
	ld h, d
	ld l, e
	ld a, [hli]
	or [hl]
;=@z
	pop hl
	ret


;@ def LoseSixthOfMax_53(pos: a, table: de) -> carry
;@ path: battle/actions
;@ Takes a sixth of the maximum from the HP (or MP) of battle position `pos`; `table` is wBattlerHP
;@ (or wBattlerMP), the maximum lies $10 bytes further. The amount goes to wSkillAmount and as
;@ digits to wTextArg1; only its low byte is subtracted. Carry when the value went below 0 (the
;@ caller then sets it to 0); de points at the high byte afterwards.
;@ test: skip writes digits with a routine of the home bank
LoseSixthOfMax_53::
;> value = table + 2 * pos
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;>@a amount = mem16[value + 0x10] // 6
	push de
	ld a, $10
	add e
	ld e, a
	ld a, $00
	adc d
;=@a
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
;=@a
	ld a, $06
	call Divide16
;> wSkillAmount = amount
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> AmountToTextArg1_53()
	push hl
	call AmountToTextArg1_53
	pop hl
;>@s mem16[value] -= amount & 0xFF      # carry: it went below 0
	pop de
	ld a, [de]
	sub l
	ld [de], a
	inc de
	ld a, [de]
;=@s
	sbc $00
	ld [de], a
	ret


;@ def LoseSixthOfMaxMP_53()
;@ path: battle/actions
;@ Takes a sixth of the user's maximum MP from its MP, not below 0, and leaves the MP actually
;@ lost in wSkillAmount (0 if it had none); wTargetScores keeps the address of the MP word.
;@ test: skip calls a routine of the home bank that returns two values
LoseSixthOfMaxMP_53::
;> maxmp = GetBattlerMaxMP(wSkillUser)
	ld a, [wSkillUser]
	call GetBattlerMaxMP
;> if maxmp == 0: lost = 0
	or h
	jr z, .done

;> else:
;>     wSkillAmount = maxmp // 6
	ld a, $06
	call Divide16
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@mp     mp = addr(wBattlerMP) + 2 * wSkillUser; wTargetScores = mp
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@mp
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;>@y     if mem16[mp] == 0: lost = 0
	ld a, [hli]
	or [hl]
	jr nz, .take

	ld h, [hl]
;=@y
	ld l, a
	jr .done

.take
;>     else:
;>@h         wSkillAmount2 = mem16[mp]          # what it had
	ld a, [hld]
	ld c, [hl]
	ld b, a
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
;=@h
	ld [wSkillAmount2 + 1], a
;>@t         mem16[mp] -= wSkillAmount
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, [hl]
	sub c
;=@t
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
;>         if not borrowed: return        # lost = the amount, already in wSkillAmount
	ret nc

;>         mem16[mp] = 0
	xor a
	ld [hld], a
	ld [hl], a
;>         lost = wSkillAmount2
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [wSkillAmount2 + 1]
	ld h, a

.done
;> wSkillAmount = lost
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def PickChanceEffect_53()
;@ path: battle/actions
;@ The skill Chance: picks one of its random effects, ECHO ($A9), HealUsAll ($A3) or $A2-$AF
;@ (CALLHOROR, Smashed, FILTHZONE, ALLCHANGE, BIGSLEEP, MP0, CHGDRAGON, CALLEVIL, FREEZY,
;@ ALLREVIVE, RESTOREMP, METEOR), as the user's action. Outside wild battles only effects with bit 1
;@ of word 9 of their skill record are allowed; a wild enemy cannot pick CALLHOROR or Smashed.
;@ The battle AI picks the target, then the action starts over at action step 0.
;@ test: skip calls routines in other banks
PickChanceEffect_53::
;> DrawRandom_53()
	call DrawRandom_53
;> n = wRandomHigh & 0x0F
	ld a, [wRandomHigh]
	and $0f
;>@echo if n == 0: effect = 0xA9                    # ECHO
	or a
	jr z, .echo

;>@heal elif n == 1: effect = 0xA3                  # HealUsAll
	cp $01
	jr z, .healUsAll

;> else: effect = 0xA0 + n
	add $a0
	jr .picked

.echo
;=@echo
	ld a, $a9
	jr .picked

.healUsAll
;=@heal
	ld a, $a3

.picked
;> wSkillId = effect; wBattleArg0 = effect
	ld [wSkillId], a
	ld [wBattleArg0], a
;> wBattleArg1 = 0; wBattleArg2 = 9
	xor a
	ld [wBattleArg1], a
	ld a, $09
	ld [wBattleArg2], a
;> GetSkillWord()                         # word 9 of the skill record
	ld hl, far_GetSkillWord
	rst $10
;> if wBattleType and not (wBattleArg0 & 0x02): return PickChanceEffect_53()
	ld a, [wBattleType]
	or a
	jr z, .allowed

	ld a, [wBattleArg0]
	bit 1, a
	jr z, PickChanceEffect_53

.allowed
;>@w if not wLinkActive and wSkillUser >= 3 and effect in (0xA2, 0xA4): return PickChanceEffect_53()
	ld a, [wLinkActive]
	or a
	jr nz, .setAction

	ld a, [wSkillUser]
	cp $03
	jr c, .setAction

;=@w
	ld a, [wSkillId]
	cp $a2
	jr z, PickChanceEffect_53

	cp $a4
	jr z, PickChanceEffect_53

.setAction
;>@a wBattlerAction[2 * wSkillUser] = effect
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [wSkillId]
	ld [hl], a
;> keep = wHitCount; wHitCount = 0
	ld a, [wHitCount]
	push af
	xor a
	ld [wHitCount], a
;> RunTargetPicker(); wHitCount = keep
	ld hl, far_RunTargetPicker
	rst $10
	pop af
	ld [wHitCount], a
;> wBattleSubStep2 = 0; wBattleSubStep = 0
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleSubStep], a
;> wBattleStepArg0 = 0; wHitCount = 0
	xor a
	ld [wBattleStepArg0], a
	xor a
	ld [wHitCount], a
	ret


;@ def IsUnderDirectOrder_53() -> zero
;@ path: battle/actions
;@ Zero flag when the skill user carries out a direct command: its tactic is 3 (COMMAND) and the
;@ order flag of its side is $81 (wMenuChoice outside link mode, wOrderFlag0/1 in a link battle).
;@ Never during a second action (wBattleTemp set).
;@ test: wSkillUser = rand(0, 7)
IsUnderDirectOrder_53::
;> if wBattleTemp: return False
	ld a, [wBattleTemp]
	or a
	ret nz

;>@t if wBattlerTactic[wSkillUser] != 3: return False
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld a, [hl]
	cp $03
	ret nz

;> if not wLinkActive: flag = wMenuChoice
	ld a, [wLinkActive]
	or a
	jr nz, .link

	ld a, [wMenuChoice]
	jr .check

.link
;> elif wSkillUser < 4: flag = wOrderFlag0
	ld a, [wSkillUser]
	cp $04
	jr nc, .partner

	ld a, [wOrderFlag0]
	jr .check

.partner
;> else: flag = wOrderFlag1
	ld a, [wOrderFlag1]

.check
;> return flag == 0x81
	cp $81
	ret


;@ def DrawRandom_53()
;@ path: battle/actions
;@ Draws a random number (Random: wRandomHigh/Low). In a link battle both Game Boys draw from the
;@ shared state wLinkRandom, so they get the same numbers.
;@ test: skip calls a random-number routine
DrawRandom_53::
;> if not wLinkActive:
	ld a, [wLinkActive]
	or a
	jr nz, .linked

;>     Random(); return
	call Random
	ret


.linked
;>@a wRandomHigh = wLinkRandom & 0xFF; wRandomLow = wLinkRandom >> 8
	push hl
	ld a, [wLinkRandom]
	ld l, a
	ld a, [wLinkRandom + 1]
	ld h, a
;=@a
	ld a, l
	ld [wRandomHigh], a
	ld a, h
	ld [wRandomLow], a
;> Random()
	call Random
;>@b wLinkRandom = wRandomHigh | wRandomLow << 8
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, l
;=@b
	ld [wLinkRandom], a
	ld a, h
	ld [wLinkRandom + 1], a
	pop hl
	ret


;@ def CheckEnemyRepeatsSkill_53() -> carry
;@ path: battle/actions
;@ Carry when the user is an enemy (positions 4-6, not in a link battle) whose template avoids
;@ repeats (EnemyAvoidsRepeat_53) and an enemy found in wTurnOrder before it uses the same group
;@ skill (GroupSkills_53). Only own monsters count toward wTurnOrderPos in the scan, so it can reach
;@ the user's own entry, which always matches.
;@ test: skip reads a table by a 16-bit template number
CheckEnemyRepeatsSkill_53::
;>@no if wLinkActive or wSkillUser < 4 or wSkillUser == 7: return False
	ld a, [wLinkActive]
	or a
	jr nz, .no

	ld a, [wSkillUser]
	cp $04
	jr c, .no

;=@no
	cp $07
	jr z, .no

;>@t template = wEncSpecies[2 * (wSkillUser - 4)] | wEncSpecies[2 * (wSkillUser - 4) + 1] << 8
	sub $04
	ld hl, wEncSpecies
	add a
	add l
	ld l, a
	ld a, $00
;=@t
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@avoid if not mem[EnemyAvoidsRepeat_53 + template]: return False
	ld a, l
	add LOW(EnemyAvoidsRepeat_53)
	ld l, a
	ld a, h
	adc HIGH(EnemyAvoidsRepeat_53)
	ld h, a
;=@avoid
	ld a, [hl]
	or a
	jr z, .no

;> if wTurnOrderPos == 0: return False
	ld a, [wTurnOrderPos]
	or a
	jr z, .no

;> own = wTurnOrderPos; i = 0
	ld b, a
	ld hl, wTurnOrder

.scan
;>@scan while True:
;>     pos = wTurnOrder[i]; i += 1
	ld a, [hli]
;>     if pos == 0xFF: return False
	cp $ff
	jr z, .no

;>     if pos < 4:
	cp $04
	jr nc, .enemy

;>         own -= 1
	dec b
;>         if own == 0: return False
	jr nz, .scan

	jr .no

.enemy
;>@g     elif IsSameGroupSkill_53(pos): return True
	call IsSameGroupSkill_53
	jr nz, .scan

;=@g
	scf
	ret


.no
;=@no
	scf
	ccf
	ret


;@ def IsSameGroupSkill_53(pos: a) -> zero
;@ path: battle/actions
;@ Zero flag when battle position `pos` uses the same skill as the user and that skill is one of
;@ GroupSkills_53. Keeps bc and hl.
;@ test: pos = rand(0, 7); wSkillUser = rand(0, 7)
IsSameGroupSkill_53::
;>@s skill = wBattlerAction[2 * pos]
	push hl
	push bc
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
;=@s
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld c, a
;>@u if wBattlerAction[2 * wSkillUser] != skill: return False
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@u
	adc h
	ld h, a
	ld a, [hl]
	cp c
	jr nz, .done

;>@r return IsGroupSkill_53(skill)
	call IsGroupSkill_53

.done
;=@r
	pop bc
	pop hl
	ret


;@ def IsGroupSkill_53(skill: c) -> zero
;@ path: battle/actions
;@ Zero flag when `skill` is in GroupSkills_53.
;@ test: skill = rand(0, 255)
IsGroupSkill_53::
;> p = GroupSkills_53
	ld hl, GroupSkills_53

.next
;>@l while True:
;>     s = mem[p]; p += 1
	ld a, [hli]
;>@nf     if s == 0xFF: return False
	cp $ff
	jr z, .notFound

;>     if s == skill: return True
	cp c
	ret z

;=@l
	jr .next

.notFound
;=@nf
	or a
	ret


;@ path: battle/data
;@ Skills an enemy group does not use twice in one turn when its template says so
;@ (EnemyAvoidsRepeat_53): attack spells, sleep and support spells, healing, the strong attacks,
;@ breaths and dances and a few others; ends with $FF.
GroupSkills_53::
	db $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12
	db $13, $14, $16, $17, $18, $1d, $1f, $21, $23, $2e, $2f, $30, $31, $32, $3b, $3c
	db $3e, $3f, $40, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $51, $52, $53, $57, $59
	db $5a, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $69, $6a, $6b
	db $6d, $6e, $71, $78, $7c, $7d, $d6, $d7, $d8, $d9, $da, $db, $dc, $ff

;@ def ActionStart_StartPause_53()
;@ path: battle/actions
;@ Stage 7: starts a short pause (message speed + 3 frames) after a monster could not act.
ActionStart_StartPause_53::
;> wBattleArg0 = wMessageSpeed + 3; wBattleSubStep2 += 1
	ld a, [wMessageSpeed]
	add $03
	ld [wBattleArg0], a
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def ActionStart_Pause_53()
;@ path: battle/actions
;@ Stage 8: counts the pause down, then back to stage 0 for the next monster.
ActionStart_Pause_53::
;> wBattleArg0 -= 1
	ld a, [wBattleArg0]
	dec a
	ld [wBattleArg0], a
;> if wBattleArg0 == 0: wBattleSubStep2 = 0
	ret nz

	xor a
	ld [wBattleSubStep2], a
	ret


;@ def RunCoverStages_53()
;@ path: battle/skills
;@ Carries out Cover ($88) and Guardian ($89), one stage (wBattleSubStep2) per call.
;@ test: skip jump table
RunCoverStages_53::
;> CoverStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages of RunCoverStages_53: 0 Cover_Begin_53, 1-3 end the action.
CoverStages_53::
	dw Cover_Begin_53
	dw Cover_Skip2_53
	dw Cover_Skip1_53
	dw Cover_Done_53

;@ def Cover_Begin_53()
;@ path: battle/skills
;@ Cover protects the target, Guardian ($89) the whole side of the target: each protected monster
;@ (not the user, not one protected already) gets status byte 6 bit 4 and the user's position in
;@ the high nibble of status byte 7, so attacks on it are taken by the user. Guardian also marks
;@ the side (wSideFlags bit 4, the user's slot in bits 4-5 of wSuckAllUsers); a side with a
;@ Guardian already, or a missing target, ends the action at once.
;@ test: skip jumps into another stage
Cover_Begin_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@gone if CheckBattlerPresent(wSkillTarget):
;>@g2     wBattleSubStep2 += 1; return Cover_Skip1_53()
;=@gone
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, .present

.skip
;=@g2
	ld hl, wBattleSubStep2
	inc [hl]
	jp Cover_Skip1_53


.present
;>@sd side = addr(wSideFlags) + (1 if wSkillTarget >= 4 else 0)
	ld a, [wSkillTarget]
	cp $04
	jr c, .ownSide

;=@sd
	ld hl, wSideFlags + 1
	jr .side

.ownSide
;=@sd
	ld hl, wSideFlags

.side
;> if mem[side] & 0x10:                   # a Guardian protects that side already
	bit 4, [hl]
	jr nz, .skip
;>     wBattleSubStep2 += 1; return Cover_Skip1_53()

;> if wSkillId == 0x89:                   # Guardian: the whole side
	ld a, [wSkillId]
	cp $89
	jr nz, .single

;>     mem[side] |= 0x10
	set 4, [hl]
;>@s     mem[side + 0x4A] |= (wSkillUser & 3) << 4     # wSuckAllUsers of that side: who guards
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@s
	ld a, [wSkillUser]
	and $03
	swap a
	or [hl]
	ld [hl], a
;>     first = wSkillTarget & 4; count = 3
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $03
	jr .loop

.single
;> else: first = wSkillTarget; count = 1
	ld a, [wSkillTarget]
	ld c, a
	ld b, $01

.loop
;>@l for pos in range(first, first + count):
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>     if pos == wSkillUser: continue
	ld a, c
	ld hl, wSkillUser
	cp [hl]
	jr z, .next

;>     st6 = addr(wBattlerStatus6) + 8 * pos
	ld hl, wBattlerStatus6
	call AddEightTimes
;>     if mem[st6] & 0x10: continue        # protected already
	bit 4, [hl]
	jr nz, .next

;>     mem[st6] |= 0x10
	set 4, [hl]
;>@p     mem[st6 + 1] |= (wSkillUser & 0x0F) << 4     # by whom
	inc hl
	ld a, [wSkillUser]
	and $0f
	swap a
	ld d, a
	ld a, [hl]
;=@p
	or d
	ld [hl], a

.next
;=@l
	inc c
	dec b
	jr nz, .loop

;> return
	ret


;@ def Cover_Skip2_53()
;@ path: battle/skills
;@ Stage 1 of RunCoverStages_53 (and the way out of stage 0): ends the action.
;@ test: wBattleSubStep2 = 1; wBattleSubStep = 4
Cover_Skip2_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> return Cover_Skip1_53()

;@ def Cover_Skip1_53()
;@ path: battle/skills
;@ Stage 2 of RunCoverStages_53: ends the action.
;@ test: wBattleSubStep2 = 2; wBattleSubStep = 4
Cover_Skip1_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> return Cover_Done_53()

;@ def Cover_Done_53()
;@ path: battle/skills
;@ Stage 3 of RunCoverStages_53: the action goes on three action steps later, with the step
;@ variables cleared.
;@ test: wBattleSubStep = 4
Cover_Done_53::
;> wBattleSubStep += 3
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
;> wBattleSubStep2 = 0; wBattleTemp = 0
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleTemp], a
;> wBattleTempHigh = 0
	xor a
	ld [wBattleTempHigh], a
	ret


;@ def SetDamageMessageArgs_53()
;@ path: battle/names
;@ Fills the texts a skill message inserts: the target's name (wTextArg0), the amount wSkillAmount
;@ as digits (wTextArg1) and the user's name (wTextArg2).
;@ test: skip calls routines in other banks
SetDamageMessageArgs_53::
;> GetTargetName_53()
	call GetTargetName_53
;> AmountToTextArg1_53()
	call AmountToTextArg1_53
;> UserNameToTextArg2_53()
	call UserNameToTextArg2_53
	ret


;@ def AmountToTextArg1_53()
;@ path: battle/names
;@ Writes wSkillAmount as decimal digits into wTextArg1.
;@ test: wSkillAmount = rand(0, 9999)
AmountToTextArg1_53::
;>@n Number16ToDecimal(wSkillAmount, addr(wTextArg1))
	ld hl, wTextArg1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
;=@n
	call Number16ToDecimal
	ret


;@ def UserNameToTextArg2_53()
;@ path: battle/names
;@ Writes the user's name into wTextArg2; wBattleArg2/3 point at it.
;@ test: skip calls routines in other banks
UserNameToTextArg2_53::
;> wBattleArg2 = addr(wTextArg2) & 0xFF; wBattleArg3 = addr(wTextArg2) >> 8
	ld hl, wTextArg2
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser; GetBattlerName_53(wSkillUser, addr(wTextArg2))
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerName_53
	ret


;@ def DodgeToTargetSide_53(c: c)
;@ path: battle/dodge
;@ Part of DodgeAside_53: the attack goes to the first free position of the target's own side
;@ (DodgeTo_53; the third position is taken without a check).
;@ test: skip jumps on into other routines
DodgeToTargetSide_53::
;>@f if c & 4 == wSkillTarget & 4: c = (c & 4) ^ 4
	ld a, [wSkillTarget]
	and $04
	ld b, a
	ld a, c
	and $04
	cp b
;=@f
	jr nz, .first

	xor $04
	ld c, a

.first
;> e = (c & 4) ^ 4                        # the first position of the target's side
	ld a, c
	and $04
	xor $04
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jp nc, DodgeTo_53

;> e += 1
	inc e
	ld a, e
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jp nc, DodgeTo_53

;> e += 1; return DodgeTo_53(e)
	inc e
	jp DodgeTo_53


;@ def DodgeToOtherSide_53(c: c)
;@ path: battle/dodge
;@ Part of DodgeAside_53: the attack goes to the side opposite position `c` - position 0 or 2 of it
;@ at random, then the other one, then position 1.
;@ test: skip jumps on into other routines
DodgeToOtherSide_53::
;> d = (c & 4) ^ 4                        # the first position of the other side
	ld a, c
	and $04
	xor $04
	ld d, a
;> c = wRandomLow & 2; e = c | d
	ld a, [wRandomLow]
	and $02
	ld c, a
	or d
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jp nc, DodgeTo_53

;> e ^= 2
	ld a, e
	xor $02
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jp nc, DodgeTo_53

;> e = d + 1; return DodgeTo_53(e)
	inc d
	ld e, d
	jp DodgeTo_53


;@ def DodgeToOtherSide2_53(c: c)
;@ path: battle/dodge
;@ Part of DodgeAside_53: the attack goes to position 1 or 2 (at random) of the side opposite `c`,
;@ then to a position counted back from that side's start, then to its first position.
;@ test: skip jumps on into other routines
DodgeToOtherSide2_53::
;> d = (wRandomLow & 1) + 1
	ld a, [wRandomLow]
	and $01
	inc a
	ld d, a
;> c = (c & 4) ^ 4; e = c + d
	ld a, c
	and $04
	xor $04
	ld c, a
	add d
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jp nc, DodgeTo_53

;> d ^= 3; e = (c - d) & 0xFF
	ld a, d
	xor $03
	ld d, a
	ld a, c
	sub d
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jp nc, DodgeTo_53

;> e = c; return DodgeTo_53(e)
	ld e, c
	jp DodgeTo_53


;@ def DodgeAside_53()
;@ path: battle/dodge
;@ The target tries to get out of the way of the attack so that it hits another monster: one time
;@ in five it fails, otherwise the new position is picked at random from the target's side, the
;@ other side, or a neighbour of the target. Sets up "... dodges the attack!" ($7E, with the new
;@ target) or "... cannot dodge in time" ($7F); the low byte of wSkillStatusPtr becomes 1 once a
;@ message was started. A target that cannot act does not dodge.
;@ test: skip calls routines in other banks
DodgeAside_53::
;> mem[addr(wSkillStatusPtr)] = 0
	xor a
	ld [wSkillStatusPtr], a
;> if CheckBattlerCanAct(wSkillTarget): return
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	ret c

;> c = wSkillTarget; DrawRandom_53()
	ld a, [wSkillTarget]
	ld c, a
	call DrawRandom_53
;> r = wRandomHigh
	ld a, [wRandomHigh]
;> if r < 0x33: return DodgeFails_53()
	cp $33
	jr c, DodgeFails_53

;> if r < 0x66: return DodgeToTargetSide_53(c)
	cp $66
	jp c, DodgeToTargetSide_53

;> if r < 0x99: return DodgeToOtherSide_53(c)
	cp $99
	jr c, DodgeToOtherSide_53

;> if r < 0xCC: return DodgeToOtherSide2_53(c)
	cp $cc
	jr c, DodgeToOtherSide2_53

;> side = c & 4; d = wRandomLow & 1
	ld a, c
	and $04
	ld b, a
	ld a, [wRandomLow]
	and $01
	ld d, a
;> slot = c & 3
	ld a, c
	and $03
;>@s0 if slot == 0:
;>@s0b     d += 1; first = d
;=@s0
	cp $00
	jr z, .slot0

;> elif slot == 1: return Neighbours()
	cp $01
	jr z, .slot1

;> else: d += 1; first = slot - d
	inc d
	sub d

.tryTwo
;> e = first | side
	or b
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jr nc, DodgeTo_53

;> second = d ^ 3 if d ^ 3 != 3 else 1
	ld a, d
	xor $03
	cp $03
	jr nz, .second

	ld a, $01

.second
;> e = second | side
	or b
	ld e, a
;> if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jr nc, DodgeTo_53

;> e = c; return DodgeRandomly_53()
	ld e, c
	jr DodgeRandomly_53

.slot0
;=@s0b
	inc d
	ld a, d
	jr .tryTwo

.slot1
;> def Neighbours():                       # the middle position: one neighbour, then the other
;>     if d:
	ld a, d
	or a
	jr z, .leftFirst

;>         e = c + 1
	ld a, c
	inc a
	ld e, a
;>         if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jr nc, DodgeTo_53

;>         e = c - 1
	ld a, c
	dec a
	ld e, a
;>         if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jr nc, DodgeTo_53

;>         return DodgeRandomly_53()
	jr DodgeRandomly_53

.leftFirst
;>     else:
;>         e = c - 1
	ld a, c
	dec a
	ld e, a
;>         if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jr nc, DodgeTo_53

;>         e = c + 1
	ld a, c
	inc a
	ld e, a
;>         if not IsDodgeSpotFree_53(e): return DodgeTo_53(e)
	call IsDodgeSpotFree_53
	jr nc, DodgeTo_53

;>         return DodgeFails_53()

;@ def DodgeFails_53()
;@ path: battle/dodge
;@ The dodge does not work out: a target whose personality lets it dodge (wPersonalityNudge bit 5)
;@ tries its own side after all (DodgeToTargetSide_53); otherwise "... cannot dodge in time" ($7F).
;@ test: skip jumps on into other routines
DodgeFails_53::
;>@n if wPersonalityNudge[wSkillTarget] & 0x20: return DodgeToTargetSide_53(c)
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@n
	ld h, a
	bit 5, [hl]
	jp nz, DodgeToTargetSide_53

;> wTextIndex = 0x7F; wBattleArg0 = wSkillTarget
	ld a, $7f
	ld [wTextIndex], a
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
;> return ShowDodgeMessage_53()
	jr ShowDodgeMessage_53

;@ def DodgeRandomly_53()
;@ path: battle/dodge
;@ Part of DodgeAside_53 when the neighbours are taken: one of the three ways at random.
;@ test: skip jumps on into other routines
DodgeRandomly_53::
;> if wRandomHigh < 0x55: return DodgeToTargetSide_53(c)
	ld a, [wRandomHigh]
	cp $55
	jp c, DodgeToTargetSide_53

;> if wRandomHigh < 0xAA: return DodgeToOtherSide_53(c)
	cp $aa
	jp c, DodgeToOtherSide_53

;> return DodgeToOtherSide2_53(c)
	jp DodgeToOtherSide2_53


;@ def DodgeTo_53(e: e)
;@ path: battle/dodge
;@ Ends DodgeAside_53 with position `e`: an empty one means the dodge fails, the target itself means
;@ trying again; otherwise `e` becomes the target of the action and "... dodges the attack!"
;@ ($7E) is set up. (After it come five unreachable bytes: ld a, $7F / ld [$C823], a.)
;@ test: skip jumps on into other routines
DodgeTo_53::
;> if CheckBattlerPresent(e): return DodgeFails_53()
	ld a, e
	call CheckBattlerPresent
	jr c, DodgeFails_53

;> wBattleArg0 = wSkillTarget
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
;> if e == wSkillTarget: return DodgeAside_53()
	cp e
	jp z, DodgeAside_53

;> wSkillTarget = e
	ld a, e
	ld [wSkillTarget], a
;>@a wBattlerAction[2 * wSkillUser + 1] = e
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld [hl], e
;> wTextIndex = 0x7E                      # "... dodges the attack!"
	ld a, $7e
	ld [wTextIndex], a
;> return ShowDodgeMessage_53()
	jr ShowDodgeMessage_53

	db $3e, $7f, $ea, $23, $c8

;@ def ShowDodgeMessage_53()
;@ path: battle/dodge
;@ Writes the name of position wBattleArg0 (the monster that dodged or failed to) into wTextArg2 and
;@ starts message wTextIndex, unless only the outcome was wanted (wBattleTemp set).
;@ test: skip calls routines in other banks
ShowDodgeMessage_53::
;>@n GetBattlerName_53(wBattleArg0, addr(wTextArg2))
	ld hl, wTextArg2
	ld a, [wTextIndex]
	push af
	ld a, [wBattleArg0]
	call GetBattlerName_53
;=@n
	pop af
	ld [wTextIndex], a
;> if wBattleTemp: return
	ld a, [wBattleTemp]
	or a
	ret nz

;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;> mem[addr(wSkillStatusPtr)] = 1
	ld a, $01
	ld [wSkillStatusPtr], a
	ret


;@ def IsDodgeSpotFree_53(pos: a, e: e) -> carry
;@ path: battle/dodge
;@ Carry when an attack cannot be moved to position `pos` (= `e`): it is empty, or the monster is
;@ high in the sky (HighJump).
;@ test: pos = rand(0, 7); e = pos
IsDodgeSpotFree_53::
;>@p if CheckBattlerPresent(pos): return True
	call CheckBattlerPresent
	jr c, .no

;>@s return mem[addr(wBattlerStatus4) + 8 * e] & 0x0C != 0
	ld a, e
	push hl
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
;=@s
	and $0c
	pop hl
	jr nz, .no

	scf
	ccf
	ret


.no
;=@p
	scf
	ret


;@ def CheckBossImmunity_53()
;@ path: battle/skills
;@ wBattleArg0 = 0 when the target is an enemy of a scripted battle (a boss) and the skill is one it
;@ is immune to - Beat, Defeat, Sacrifice, Kamikaze, Paralyze, PalsyAir, K.O.Dance - else 1.
;@ test: wSkillTarget = rand(0, 7); wBattleType = rand(0, 2); wSkillId = choice([0x12, 0x14, 0x69, 0x3A])
CheckBossImmunity_53::
;>@n if not wLinkActive and wSkillTarget >= 4 and wBattleType == 1:
	ld a, [wLinkActive]
	or a
	jr nz, .notImmune

	ld a, [wSkillTarget]
	cp $04
	jr c, .notImmune

;=@n
	ld a, [wBattleType]
	cp $01
	jr nz, .notImmune

;>@i     if wSkillId in (0x12, 0x13, 0x14, 0x3E, 0x69, 0x6B, 0x71):
;>@b         wBattleArg0 = 0; return
;=@i
	ld a, [wSkillId]
	cp $12
	jr z, .immune

	cp $13
	jr z, .immune

;=@i
	cp $14
	jr z, .immune

	cp $3e
	jr z, .immune

	cp $69
	jr z, .immune

;=@i
	cp $6b
	jr z, .immune

	cp $71
	jr z, .immune

.notImmune
;> wBattleArg0 = 1
	ld a, $01
	ld [wBattleArg0], a
	ret


.immune
;=@b
	xor a
	ld [wBattleArg0], a
	ret


;@ def RunSkillHit_53()
;@ path: battle/skills
;@ Battle action step 1, once per frame: carries out the skill of the acting monster on its target,
;@ one stage (wBattleSubStep2, SkillHitStages_53) after the other - messages, animation, being
;@ intercepted, dodged or missed, a critical hit, the damage and the result message. Stage 16 (after
;@ the last) tells bank $52 that the hit is over.
;@ test: skip jump table
RunSkillHit_53::
;> SkillHitStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages 0-15 of RunSkillHit_53.
SkillHitStages_53::
	dw Hit_Begin_53
	dw Hit_NudgeMessage_53
	dw Hit_Announce_53
	dw Hit_AfterAnnounce_53
	dw Hit_Animate_53
	dw Hit_NextAnimTarget_53
	dw Hit_Shield_53
	dw Hit_Intercept_53
	dw Hit_EasyDodge_53
	dw Hit_CheckMiss_53
	dw Hit_Critical_53
	dw Hit_WaitFrame_53
	dw Hit_Damage_53
	dw Hit_Result_53
	dw Hit_Effect_53
	dw Hit_Message_53

;@ def Hit_Begin_53()
;@ path: battle/skills
;@ Stage 0: counts the hit (wHitCount) and takes the target of the action (the battle AI picks one
;@ if it is still open). Only the first hit has the announcing stages; a further hit of the same
;@ skill goes straight to stage 7.
;@ test: skip calls routines in other banks
Hit_Begin_53::
;> wBattleSubStep2 += 1; wHitCount += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wHitCount
	inc [hl]

.getTarget
;>@t while True:
;>     wInterceptState = 0
	xor a
	ld [wInterceptState], a
;>@a     wSkillTarget = wBattlerAction[2 * wSkillUser + 1]
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a
;>     if wSkillTarget != 0xFF: break
	cp $ff
	jr nz, .haveTarget

;>     RunTargetPicker()
	ld hl, far_RunTargetPicker
	rst $10
;=@t
	jr .getTarget

.haveTarget
;> if wHitCount == 1: return Hit_NudgeMessage_53()
	ld a, [wHitCount]
	cp $01
	jr z, Hit_NudgeMessage_53

;> wBattleSubStep2 = 7; return Hit_Intercept_53()
	ld a, $07
	ld [wBattleSubStep2], a
	jp Hit_Intercept_53


;@ def Hit_NudgeMessage_53()
;@ path: battle/skills
;@ Stage 1: a personality effect of the user shows itself: "... shouts a battle cry!" ($6D, bit 6 of
;@ wPersonalityNudge), "... focuses its energy" ($69, bit 2) or "A Celestial light covers ..."
;@ ($6B, bit 4); without one it goes on with stage 2 at once.
;@ test: skip calls routines in other banks
Hit_NudgeMessage_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@n nudge = wPersonalityNudge[wSkillUser] & 0x54
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@n
	ld h, a
	ld a, [hl]
	and $54
;> if not nudge: return Hit_Announce_53()
	jr z, Hit_Announce_53

;> GetUserName_53()
	push af
	call GetUserName_53
	pop af
;>@c if nudge & 0x40: msg = 0x6D            # battle cry
	bit 6, a
	jr nz, .battleCry

;>@f elif nudge & 0x04: msg = 0x69          # focuses its energy
	bit 2, a
	jr nz, .focus

;> else: msg = 0x6B                        # Celestial light
	ld a, $6b
	jr .show

.focus
;=@f
	ld a, $69
	jr .show

.battleCry
;=@c
	ld a, $6d

.show
;> wTextIndex = msg; wTextGroup = 0
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def Hit_Announce_53()
;@ path: battle/skills
;@ Stage 2: shows what the user does (GetSkillMessage, ShowActionMessage, PlaySkillSound0) and
;@ starts a 24-frame wait (wMonStats serves as the counter). Skills on a whole side (Sacrifice,
;@ Barrier, MagicWall, Ironize, Guardian, DeMagic, TailWind, StormWind, SuckAll, ThickFog,
;@ FILTHZONE) move their target to the first monster present on that side. A reaction other than
;@ kind 8 is not announced.
;@ test: skip calls routines in other banks
Hit_Announce_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wReactionKind not in (0, 8): return
	ld a, [wReactionKind]
	or a
	jr z, .announce

	cp $08
	jr z, .announce

	ret


.announce
;> GetSkillMessage(); ShowActionMessage()
	ld hl, far_GetSkillMessage
	rst $10
	ld hl, far_ShowActionMessage
	rst $10
;> PlaySkillSound0()
	ld hl, far_PlaySkillSound0
	rst $10
;> wMonStats = 0x18                       # wait 24 frames
	ld a, $18
	ld [wMonStats], a
;>@s if wSkillId not in (0x14, 0x24, 0x26, 0x2A, 0x89, 0x80, 0x8A, 0x8B, 0x8F, 0x83, 0xA5): return
	ld a, [wSkillId]
	cp $14
	jr z, .findTarget

	cp $24
	jr z, .findTarget

;=@s
	cp $26
	jr z, .findTarget

	cp $2a
	jr z, .findTarget

;=@s
	cp $89
	jr z, .findTarget

	cp $80
	jr z, .findTarget

;=@s
	cp $8a
	jr z, .findTarget

	cp $8b
	jr z, .findTarget

;=@s
	cp $8f
	jr z, .findTarget

	cp $83
	jr z, .findTarget

;=@s
	cp $a5
	ret nz

.findTarget
;>@l while CheckBattlerPresent(wSkillTarget):   # not present: try the next position of the side
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret nc

;>@e     entry = addr(wBattlerAction) + 2 * wSkillUser + 1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@e
	adc h
	ld h, a
;>     if mem[entry] & 3 == 3: return
	ld a, [hl]
	and $03
	cp $03
	ret z

;>     mem[entry] += 1; wSkillTarget = mem[entry]
	inc [hl]
	ld a, [hl]
	ld [wSkillTarget], a
;=@l
	jr .findTarget

;@ def Hit_AfterAnnounce_53()
;@ path: battle/skills
;@ Stage 3: waits out the 24 frames, then: the first turn of HighJump goes to stage 11 (the user just
;@ jumps). Otherwise the target is fixed (and kept in wBattleTempHigh) and a personality effect may
;@ show: "... fear boosts its guard" ($68, bit 1 of wPersonalityNudge) or, for skills with bit 4 of
;@ wSkillFlags2, "... attacks with full force" ($67, bit 0); else on to stage 4 at once.
;@ test: skip calls routines in other banks
Hit_AfterAnnounce_53::
;> if wMonStats:
	ld a, [wMonStats]
	or a
	jr z, .waited

;>     wMonStats -= 1; return
	dec a
	ld [wMonStats], a
	ret


.waited
;> LoadSkillFlags()
	ld hl, far_LoadSkillFlags
	rst $10
;>@hj if wSkillId == 0x42 and not (wBattlerStatus4[8 * wSkillUser] & 0x0C):    # HighJump, first turn
	ld a, [wSkillId]
	cp $42
	jr nz, .target

;=@hj
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, .target

;>     wBattleSubStep2 = 0x0B; return
	ld a, $0b
	ld [wBattleSubStep2], a
	ret


.target
;>@t wSkillTarget = wBattlerAction[2 * wSkillUser + 1]; wBattleTempHigh = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@t
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a
	ld [wBattleTempHigh], a
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@n nudge = wPersonalityNudge[wSkillUser] & 0x03
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@n
	ld h, a
	ld a, [hl]
	and $03
;> if not nudge: return Hit_Animate_53()
	jr z, Hit_Animate_53

;> GetUserName_53()
	push af
	call GetUserName_53
	pop af
;>@fear if nudge & 0x02: msg = 0x68          # fear boosts its guard
	bit 1, a
	jr z, .notFear

;=@fear
	ld a, $68
	jr .show

.notFear
;>@full elif wSkillFlags2 & 0x10: msg = 0x67     # attacks with full force
	ld a, [wSkillFlags2]
	bit 4, a
;> else: return Hit_Animate_53()
	jr z, Hit_Animate_53

;=@full
	ld a, $67

.show
;> wTextIndex = msg; wTextGroup = 0
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def Hit_Animate_53()
;@ path: battle/skills
;@ Stage 4: plays the skill animation on the target (StartSkillVisual) until it is done, then goes on
;@ with stage 6; a missing target goes to stage 5.
;@ test: skip calls routines in other banks
Hit_Animate_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget): return Hit_NextAnimTarget_53()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, Hit_NextAnimTarget_53

;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;> if wSkillAnimActive == 1: return
	ld a, [wSkillAnimActive]
	cp $01
	ret z

;> wBattleSubStep2 += 1; return Hit_Shield_53()
	ld hl, wBattleSubStep2
	inc [hl]
	jr Hit_Shield_53

;@ def Hit_NextAnimTarget_53()
;@ path: battle/skills
;@ Stage 5: for an animation shown on each target in turn (wSkillAnimPhase 2), the next monster
;@ present on the side gets it (back to stage 4); after the last one the target is the first one
;@ again (wBattleTempHigh).
;@ test: skip calls routines in other banks
Hit_NextAnimTarget_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wSkillAnimPhase != 2: return Hit_Shield_53()
	ld a, [wSkillAnimPhase]
	cp $02
	jr nz, Hit_Shield_53

;> c = wSkillTarget
	ld a, [wSkillTarget]
	ld c, a

.next
;>@l while c & 3 != 2:
	and $03
	cp $02
	jr z, .restore

;>     c += 1
	inc c
	ld a, c
;>     if not CheckBattlerPresent(c):
	call CheckBattlerPresent
	ld a, c
;=@l
	jr c, .next

;>         wSkillTarget = c; wBattleSubStep2 -= 2; return
	ld [wSkillTarget], a
	ld hl, wBattleSubStep2
	dec [hl]
	ld hl, wBattleSubStep2
	dec [hl]
	ret


.restore
;> wSkillTarget = wBattleTempHigh
	ld a, [wBattleTempHigh]
	ld [wSkillTarget], a

;@ def Hit_Shield_53()
;@ path: battle/skills
;@ Stage 6: a physical attack (bit 7 of wSkillFlags1) on a monster whose personality lets it dodge
;@ (wPersonalityNudge bit 5): it grabs another monster (picked like a dodge, DodgeAside_53, without
;@ its message) and uses it as a shield - "... grabs ... and uses it as a shield" ($6C), and stage 7
;@ is skipped. Otherwise on to stage 7 at once.
;@ test: skip calls routines in other banks
Hit_Shield_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if not (wSkillFlags1 & 0x80): return Hit_Intercept_53()
	ld a, [wSkillFlags1]
	bit 7, a
	jr z, Hit_Intercept_53

;>@t wSkillTarget = wBattlerAction[2 * wSkillUser + 1]
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@t
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a
;> if CheckBattlerCanAct(wSkillTarget): return Hit_Intercept_53()
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, Hit_Intercept_53

;>@n wShieldTarget = wSkillTarget; nudge = wPersonalityNudge[wSkillTarget]
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
	ld hl, wPersonalityNudge
	add l
	ld l, a
;=@n
	ld a, $00
	adc h
	ld h, a
;> if not (nudge & 0x20): return Hit_Intercept_53()
	bit 5, [hl]
	jr z, Hit_Intercept_53

;> wBattleTemp = nudge; DodgeAside_53()   # only picks the shield (no message)
	ld a, [hl]
	ld [wBattleTemp], a
	call DodgeAside_53
;> GetBattlerName_53(wShieldTarget, addr(wTextArg0))
	ld a, [wShieldTarget]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_53
;> GetBattlerName_53(wSkillTarget, addr(wTextArg1))
	ld a, [wSkillTarget]
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetBattlerName_53
;> wTextIndex = 0x6C; wTextGroup = 0
	ld a, $6c
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Hit_Intercept_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wReactionKind]
	bit 3, a
	jp nz, Jump_053_54d6

	ld hl, far_LoadSkillFlags
	rst $10
	call DrawRandom_53
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr z, jr_053_5458

	ld a, [wSkillFlags3]
	bit 5, a
	jr z, jr_053_5458

	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	call GetTargetName_53
	ld a, $c1
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $6f
	call QueueSound
	ret


jr_053_5458:
	ld a, [wSkillFlags1]
	bit 4, a
	jp z, Jump_053_54d6

	ld a, [wSkillTarget]
	rrca
	rrca
	and $01
	ld b, a
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jp z, Jump_053_54d6

	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

	ld a, [wSkillId]
	cp $8f
	jp z, Hit_EasyDodge_53

	ld a, b
	ld hl, wSuckAllUsers
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	rrca
	rrca
	and $03
	ld c, a
	ld a, [wSkillTarget]
	and $04
	or c
	ld c, a
	call CheckBattlerCanAct
	jp c, Hit_EasyDodge_53

	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [hl], c
	ld b, a
	ld a, c
	sub b
	ld b, a
	ld a, [wHitCount]
	add b
	ld [wHitCount], a
	ld a, c
	ld [wSkillTarget], a
	ld b, $02
	call StartReactionKeepTarget_53
	call GetTargetName_53
	ld a, $81
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_053_54d6:
	ld a, [wSkillFlags2]
	bit 1, a
	jr z, Hit_TryDodgeAside_53

	ld a, [wInterceptState]
	or a
	jr nz, Hit_TryDodgeAside_53

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 4, [hl]
	jr z, Hit_TryDodgeAside_53

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call CheckBattlerCanAct
	jr c, Hit_NotProtected_53

ShowProtectMessage_53::
	ld a, b
	ld hl, wTextArg0
	push bc
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetBattlerName_53
	pop bc
	ld a, b
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $80
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $04
	ld [wInterceptState], a
	ret


Hit_NotProtected_53::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes

Hit_TryDodgeAside_53::
	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

	ld a, [wSkillFlags1]
	bit 7, a
	jr z, jr_053_5594

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jp c, Hit_EasyDodge_53

	push hl
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	pop hl
	jr nz, jr_053_557a

	bit 5, [hl]
	jr z, jr_053_5594

jr_053_557a:
	xor a
	ld [wBattleTemp], a
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
	call DodgeAside_53
	ld a, [wSkillStatusPtr]
	or a
	jp z, Hit_EasyDodge_53

	ld a, $02
	ld [wInterceptState], a
	ret


jr_053_5594:
	ld a, [wSkillFlags1]
	bit 4, a
	jp z, Jump_053_55ca

	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

	call IsWindReflecting_53
	jr z, jr_053_55ca

	res 6, [hl]
	call GetTargetName_53
	ld a, $01
	call StartReaction_53
	ld a, $02
	ld [wReflectAnim], a
	ld a, $02
	ld [wInterceptState], a
	ld a, $7d
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_053_55ca:
jr_053_55ca:
	ld a, [wSkillFlags2]
	bit 0, a
	jp z, Hit_EasyDodge_53

	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	jp z, Hit_EasyDodge_53

	ld a, $00
	ld [wReflectAnim], a
	bit 1, [hl]
	jr nz, jr_053_55f8

	res 5, [hl]
	ld a, $07
	ld [wReflectAnim], a

jr_053_55f8:
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, jr_053_5605

	ld a, [wSkillUser]

jr_053_5605:
	rrca
	rrca
	and $01
	add $7b
	ld a, a
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $04
	call StartReaction_53
	ld a, $02
	ld [wInterceptState], a
	ret


Hit_EasyDodge_53::
	ld a, [wInterceptState]
	or a
	jr z, jr_053_563c

	cp $01
	jr z, jr_053_5636

	cp $02
	jr nz, jr_053_563c

	cp $04
	jr z, jr_053_5636

	jr jr_053_5678

jr_053_5636:
	ld hl, wBattleSubStep2
	inc [hl]
	jr Hit_CheckMiss_53

jr_053_563c:
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, Hit_CheckMiss_53

	ld a, [wSkillFlags2]
	bit 7, a
	jr z, Hit_CheckMiss_53

	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 7, [hl]
	jr z, Hit_CheckMiss_53

	call GetTargetName_53
	ld a, $6e
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call EndSkillMissed_53
	ld a, $6f
	call QueueSound
	ret


jr_053_5678:
	ld a, [wSkillFlags2]
	bit 1, a
	jr z, jr_053_563c

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 4, [hl]
	jr z, jr_053_563c

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call CheckBattlerCanAct
	jr c, jr_053_563c

	call ShowProtectMessage_53
	ld hl, wInterceptState
	inc [hl]
	ret


Hit_CheckMiss_53::
	ld a, [wSkillId]
	cp $30
	jr z, jr_053_56e1

	cp $31
	jr z, jr_053_56e1

	cp $32
	jr z, jr_053_56e1

	cp $95
	jr z, jr_053_56e1

	cp $96
	jr z, jr_053_56e1

	cp $ad
	jr z, jr_053_56e1

	cp $8f
	jr z, jr_053_56e1

	cp $89
	jr z, jr_053_56e1

	cp $8b
	jr z, jr_053_56e1

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, jr_053_56e1

	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


jr_053_56e1:
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, jr_053_5747

	ld a, [wSkillFlags2]
	bit 2, a
	jr z, jr_053_5747

	call IsHighJumpInSky_53
	jr z, jr_053_5747

	ld a, [wSkillId]
	cp $52
	jr z, jr_053_5715

	cp $53
	jr z, jr_053_5715

	cp $14
	jr z, jr_053_5746

jr_053_570e:
	call EndSkillMissed_53
	ld a, $ba
	jr jr_053_5731

jr_053_5715:
	ld a, [wHitCount]
	cp $02
	jr nc, jr_053_570e

	ld a, $00
	ld [wHitShown], a
	ld a, $10
	ld [wHitCount], a
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ld a, $c2

jr_053_5731:
	push af
	call GetTargetName_53
	pop af
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $6f
	call QueueSound

jr_053_5746:
	ret


jr_053_5747:
	ld a, [wSkillFlags1]
	bit 7, a
	jr z, jr_053_5763

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr z, jr_053_5763

	call GetTargetName_53
	ld a, $c1
	jp ShowMissMessage_53


jr_053_5763:
	call DrawRandom_53
	ld a, [wSkillFlags1]
	bit 1, a
	jr z, jr_053_579e

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr z, jr_053_5785

	ld a, [wRandomHigh]
	cp $a0
	jr nc, jr_053_5785

	call ShowMissed_53
	ret


jr_053_5785:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $03
	jr z, jr_053_579e

	ld a, [wRandomLow]
	cp $60
	jr nc, jr_053_579e

	call ShowMissed_53
	ret


jr_053_579e:
	ld a, [wSkillFlags2]
	bit 7, a
	jr z, jr_053_57f5

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, jr_053_57f5

	call IsChargedUp_53
	jr z, jr_053_57f5

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr z, jr_053_57c8

	ld a, [wRandomHigh]
	and $01
	jp z, Jump_053_57f1

jr_053_57c8:
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call ReadWordEntry_53
	ld bc, $01c0
	call CompareHLBC
	jr nc, jr_053_57e5

	ld bc, $0020
	call CompareHLBC
	jr nc, jr_053_57e9

	ld b, $02
	jr jr_053_57eb

jr_053_57e5:
	ld b, $2b
	jr jr_053_57eb

jr_053_57e9:
	ld b, $08

jr_053_57eb:
	ld a, [wRandomHigh]
	cp b
	jr nc, jr_053_57f5

Jump_053_57f1:
	call ShowEasyDodge_53
	ret


jr_053_57f5:
	jr Hit_Critical_53

ShowEasyDodge_53::
	call GetTargetName_53
	ld a, $78
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call EndSkillMissed_53
	ld a, $6f
	call QueueSound
	ret


ShowMissed_53::
	call GetTargetName_53
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, jr_053_5820

	ld a, [wSkillUser]

jr_053_5820:
	cp $04
	jr c, jr_053_5828

	ld a, $b6
	jr jr_053_582a

jr_053_5828:
	ld a, $b7

ShowMissMessage_53::
jr_053_582a:
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $6f
	call QueueSound

EndSkillMissed_53::
	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


IsHighJumpInSky_53::
	ld a, [wSkillId]
	cp $42
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret


IsChargedUp_53::
	ld a, [wSkillId]
	cp $41
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $03
	ret


Hit_Critical_53::
	ld hl, far_LoadSkillFlags
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillFlags2]
	and $70
	ret z

	bit 5, a
	jr z, jr_053_588b

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	ret nz

	ld a, [wSkillFlags2]

jr_053_588b:
	bit 4, a
	jr z, jr_053_58ea

	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	jr nz, jr_053_58b4

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 3, [hl]
	jr nz, jr_053_58b4

	call DrawRandom_53
	call CheckCriticalHit_53
	jr nc, jr_053_58ea

jr_053_58b4:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	set 7, [hl]
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld d, a
	ld a, [wLinkFlags]
	bit 1, a
	ld a, d
	jr z, jr_053_58d1

	xor $01

jr_053_58d1:
	add $79
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $6e
	call QueueSound
	ld hl, wBattleSubStep2
	inc [hl]
	jr Hit_Damage_53

	db $c9

jr_053_58ea:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	res 7, [hl]
	ret


Hit_WaitFrame_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Hit_Damage_53::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 7, [hl]
	jr z, jr_053_5912

	ld a, [wSoundChannels]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

jr_053_5912:
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	jr z, jr_053_5941

	ld a, [wSkillFlags2]
	bit 5, a
	jr z, jr_053_5941

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	sla l
	rl h
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jp Hit_DamageGuard_53


jr_053_5941:
	inc hl
	bit 7, [hl]
	jr z, Hit_DamageBoost_53

	res 7, [hl]
	ld hl, $b682
	ld a, $a8
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	ld a, [wSkillUser]
	call GetBattlerAttack
	ld a, [wSkillId]
	cp $51
	call z, HalveHL_53
	call SpreadDamage_53
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr jr_053_59c3

HalveHL_53::
	srl h
	rr l
	ret


Hit_DamageBoost_53::
	inc hl
	inc hl
	bit 0, [hl]
	jr z, jr_053_599a

	ld a, [wSkillFlags2]
	bit 6, a
	jr z, jr_053_599a

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call BoostDamage_53
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr jr_053_59c3

jr_053_599a:
	bit 4, [hl]
	jr z, jr_053_59c3

	ld a, [wSkillFlags1]
	bit 4, a
	jr z, jr_053_59c3

	ld a, [wSkillId]
	cp $5c
	jr c, jr_053_59c3

	cp $64
	jr nc, jr_053_59c3

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call BoostDamage_53
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a

Hit_DamageGuard_53::
jr_053_59c3:
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr z, jr_053_59ec

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld b, h
	ld c, l
	srl h
	rr l
	add hl, bc
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr jr_053_59ec

jr_053_59ec:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	and $07
	jr z, jr_053_5a44

	and $03
	ld c, a
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	jr nz, jr_053_5a15

	ld a, [wSkillFlags1]
	bit 7, a
	jp z, Hit_Result_53

jr_053_5a0f:
	srl h
	rr l
	jr jr_053_5a25

jr_053_5a15:
	ld a, [wSkillFlags1]
	bit 0, a
	jr z, Hit_Result_53

	bit 0, c
	jr nz, jr_053_5a0f

	ld a, $0a
	call Divide16

jr_053_5a25:
	ld a, [wSkillTarget]
	ld de, wPersonalityNudge
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	bit 1, a
	jr z, jr_053_5a3a

	srl h
	rr l

jr_053_5a3a:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr Hit_Result_53

jr_053_5a44:
	dec hl
	bit 2, [hl]
	jr z, Hit_Result_53

	ld a, [wSkillFlags1]
	bit 7, a
	jr z, Hit_Result_53

	ld a, [wSkillId]
	cp $3c
	jr z, Hit_Result_53

	cp $3e
	jr z, Hit_Result_53

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	sla l
	rl h
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a

Hit_Result_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillResult]
	bit 6, a
	jr z, jr_053_5ab4

	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ld a, [wSkillResult]
	bit 7, a
	ret z

	call SetDamageMessageArgs_53
	ld a, [wSkillResultValue]
	ld l, a
	ld a, [wSkillMsgMiss]
	ld h, a
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld hl, far_PlaySkillSound1
	rst $10
	ld a, $01
	ld [wHitShown], a
	ld a, [wSkillId]
	cp $1b
	ret nz

	ld hl, far_StartSkillVisual
	rst $10
	ret


jr_053_5ab4:
	ld a, [wSkillResult]
	ld b, a
	bit 5, a
	jr z, jr_053_5ad2

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, h
	or l
	jr z, jr_053_5acc

	set 4, b
	jr jr_053_5ace

jr_053_5acc:
	res 4, b

jr_053_5ace:
	ld a, b
	ld [wSkillResult], a

jr_053_5ad2:
	ld a, [wSkillResult]
	bit 4, a
	jr z, jr_053_5aec

	bit 2, a
	jr nz, jr_053_5aec

	ld hl, far_PlaySkillSound1
	rst $10
	ld hl, far_StartSkillVisual
	rst $10
	ld a, [wSkillAnimActive]
	cp $01
	jr z, Hit_Effect_53

jr_053_5aec:
	ret


Hit_Effect_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillResult]
	bit 2, a
	ret nz

	bit 4, a
	ret z

	ld hl, far_PlaySkillSound2
	rst $10
	ld hl, far_StartSkillHitEffect
	rst $10
	ld a, $01
	ld [wHitShown], a

Hit_Message_53::
	ld a, [wSkillId]
	cp $84
	jr c, jr_053_5b17

	cp $88
	jr nc, jr_053_5b17

	ld a, [wBattleAnimDone]
	or a
	ret z

jr_053_5b17:
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillResult]
	bit 4, a
	jr z, jr_053_5b4c

	call CheckTakeMagic_53
	ld a, [wSkillResultValue]
	ld [wTextIndex], a
	ld a, [wSkillResult]
	bit 3, a
	jr z, jr_053_5b3a

	call IsTargetOnOwnSide2_53
	jr nc, jr_053_5b3a

	call OwnSideMessage_53

jr_053_5b3a:
	xor a
	ld [wTextGroup], a
	ld a, [wSkillResult]
	bit 0, a
	jr z, jr_053_5b6f

	ld a, $01
	ld [wTextGroup], a
	jr jr_053_5b79

jr_053_5b4c:
	ld hl, far_PlaySkillSound3
	rst $10
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ld a, [wSkillMsgMiss]
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld a, [wSkillResult]
	bit 1, a
	jr z, jr_053_5b6f

	ld a, $01
	ld [wTextGroup], a

jr_053_5b6f:
	ld a, [wSkillResult]
	bit 3, a
	jr z, jr_053_5b79

	call OwnSideMissMessage_53

jr_053_5b79:
	ld a, [wTextGroup]
	ld l, a
	ld a, [wTextIndex]
	ld h, a
	push hl
	call SetDamageMessageArgs_53
	pop hl
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
	ld a, [wSkillId]
	cp $24
	call z, DropEnemyLetter_53
	ld a, [wTextIndex]
	cp $29
	jr nz, jr_053_5ba8

	ld a, [wTextGroup]
	or a
	jr nz, jr_053_5ba8

	ld a, $6d
	call QueueSound

jr_053_5ba8:
	ld hl, far_StartText_4C
	rst $10
	ret


DropEnemyLetter_53::
	ld a, [wBattleTemp]
	cp $01
	ret nz

	ld hl, wTextArg0

jr_053_5bb6:
	ld a, [hl]
	cp $f0
	jr z, jr_053_5bbe

	inc hl
	jr jr_053_5bb6

jr_053_5bbe:
	dec hl
	ld a, [hl]
	cp $24
	ret nc

	ld [hl], $f0
	ret


OwnSideMessage_53::
	ld a, [wTextIndex]
	cp $82
	jr z, jr_053_5bf6

	cp $cc
	jr z, jr_053_5bf6

	cp $e8
	jr z, jr_053_5bfb

	cp $88
	jr z, jr_053_5bf6

	cp $8a
	jr z, jr_053_5bf6

	cp $86
	jr z, jr_053_5bf6

	cp $8e
	jr z, jr_053_5bf6

	cp $95
	jr z, jr_053_5bf6

	cp $b0
	jr z, jr_053_5bf6

	cp $b2
	jr z, jr_053_5bf6

	cp $b5
	jr z, jr_053_5c01

	ret


jr_053_5bf6:
	ld hl, wTextIndex
	inc [hl]
	ret


jr_053_5bfb:
	ld a, $e3
	ld [wTextIndex], a
	ret


jr_053_5c01:
	ld a, $d2
	ld [wTextIndex], a
	ret


OwnSideMissMessage_53::
	ld a, [wTextIndex]
	cp $ca
	jr z, jr_053_5c1f

	cp $c3
	jr z, jr_053_5c30

	cp $b6
	jr z, jr_053_5c3a

	cp $b8
	jr z, jr_053_5c44

	cp $c9
	jr z, jr_053_5c1f

	ret


jr_053_5c1f:
	call IsTargetOnOwnSide2_53
	ret nc

	ld a, [wSkillId]
	cp $7d
	jr z, jr_053_5c6e

	ld a, $c7
	ld [wTextIndex], a
	ret


jr_053_5c30:
	call IsTargetOnOwnSide2_53
	ret c

	ld a, $b8
	ld [wTextIndex], a
	ret


jr_053_5c3a:
	call IsTargetOnOwnSide2_53
	ret nc

	ld a, $b7
	ld [wTextIndex], a
	ret


jr_053_5c44:
	call IsTargetOnOwnSide2_53
	ret nc

	ld a, [wSkillId]
	cp $6b
	ret c

	cp $6e
	ret z

	cp $71
	ret z

	cp $75
	ret nc

	cp $6e
	jr c, jr_053_5c68

	cp $6f
	jr z, jr_053_5c6e

	cp $70
	jr z, jr_053_5c7a

	cp $75
	jr c, jr_053_5c74

	ret


jr_053_5c68:
	ld a, $c3
	ld [wTextIndex], a
	ret


jr_053_5c6e:
	ld a, $c4
	ld [wTextIndex], a
	ret


jr_053_5c74:
	add $53
	ld [wTextIndex], a
	ret


jr_053_5c7a:
	ld a, $ca
	ld [wTextIndex], a
	ret


UnusedLinkSidePos_53::
	db $fa, $63, $c8, $cb, $4f, $fa, $89, $db, $c8, $fa, $88, $db, $c9

IsTargetOnOwnSide2_53::
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_053_5c9a

	ld a, [wSkillTarget]
	cp $04
	ret


jr_053_5c9a:
	ld a, [wSkillTarget]
	cp $04
	ccf
	ret


IsWindReflecting_53::
	ld a, [wSkillFlags1]
	bit 4, a
	ret z

	ld a, [wSkillId]
	cp $43
	ret z

	cp $8f
	ret z

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 6, [hl]
	ret


CheckTakeMagic_53::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	ret z

	ld hl, far_LoadSkillFlags
	rst $10
	ld a, [wSkillFlags3]
	bit 0, a
	ret z

	ld a, [wSkillId]
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
	ld e, c
	ld d, b
	ld a, [wSkillTarget]
	call GetBattlerMP
	add hl, bc
	push hl
	ld a, [wSkillTarget]
	call GetBattlerMaxMP
	pop bc
	call CompareHLBC
	jr nc, jr_053_5d16

	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	jr nc, jr_053_5d14

	ld de, $0000
	jr jr_053_5d16

jr_053_5d14:
	ld b, h
	ld c, l

jr_053_5d16:
	ld a, e
	ld [wAbsorbMP], a
	ld a, d
	ld [wPanelMode], a
	ld a, $01
	or a
	ret


AbsorbMP_53::
	call CheckTakeMagic_53
	ld a, [wAbsorbMP]
	ld c, a
	ld a, [wPanelMode]
	ld b, a
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld hl, wTextArg1
	call Number16ToDecimal
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, $8d
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


ReadWordEntry_53::
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


SpreadDamage_53::
	push hl
	ld a, $0a
	call Divide16
	pop de
	ld a, h
	or l
	jr nz, jr_053_5d82

	ld h, d
	ld l, e
	jr jr_053_5db0

jr_053_5d82:
	ld a, [wRandomHigh]
	ld c, a
	ld a, [wRandomLow]
	ld b, a
	ld a, b
	and $03
	ld b, a

jr_053_5d8e:
	call CompareHLBC
	jr nc, jr_053_5d9b

	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	jr jr_053_5d8e

jr_053_5d9b:
	ld h, d
	ld l, e
	srl b
	rr c
	jr c, jr_053_5da6

	add hl, bc
	jr jr_053_5db0

jr_053_5da6:
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, jr_053_5db0

	ld h, d
	ld l, e

jr_053_5db0:
	ret


BoostDamage_53::
	push af
	push bc
	push de
	push hl
	call DrawRandom_53
	pop hl
	pop de
	pop bc
	pop af
	ld b, h
	ld c, l
	srl b
	rr c
	ld a, b
	or c
	jr nz, jr_053_5dc8

	ld c, $01

jr_053_5dc8:
	push hl
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a

jr_053_5dd1:
	call CompareHLBC
	jr c, jr_053_5dde

	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr jr_053_5dd1

jr_053_5dde:
	ld b, h
	ld c, l
	pop hl
	sla l
	rl h
	add hl, bc
	ret


SaveReaction_53::
	ld [wReactionKind], a
	ld hl, wPartyBarTiles
	ld a, [wSkillUser]
	ld [hli], a
	ld a, [wSkillTarget]
	ld [hli], a
	ld a, [wHitCount]
	ld [hli], a
	ld a, [wSkillUser]
	ld de, wBattlerAction
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld a, [wSkillTarget]
	ld bc, wBattlerAction
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	ld [hli], a
	inc bc
	ld a, [bc]
	ld [hli], a
	ld a, [de]
	ld [bc], a
	dec bc
	dec de
	ld a, [de]
	ld [bc], a
	ld a, [wSkillTarget]
	ld de, wBattlerOrder
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld [hl], a
	ld a, $02
	ld [de], a
	ret


StartReactionFar_53::
	ld a, [wBattleArg0]

StartReaction_53::
	call SaveReaction_53
	ld a, [wSkillTarget]
	ld [wSkillUser], a
	ld a, [wSkillTargeting]
	bit 0, a
	jr nz, jr_053_5e53

	ld a, [wReactionKind]
	cp $04
	jr z, jr_053_5e53

	cp $01
	jr nz, jr_053_5e69

jr_053_5e53:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wPartyBarTiles]
	ld [wSkillTarget], a
	ld [hl], a
	jr jr_053_5e7e

jr_053_5e69:
	ld hl, far_RunTargetPicker
	rst $10
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a

jr_053_5e7e:
	xor a
	ld [wHitCount], a
	ld a, $00
	ld [wBattleSubStep], a
	ld a, $02
	ld [wBattleSubStep2], a
	ld a, [wReactionKind]
	cp $08
	ret z

	cp $01
	call z, ClearSuckAll_53
	ld a, $01
	ld hl, wBattleSubStep
	ld [hli], a
	xor a
	ld [hl], a
	ret


ClearSuckAll_53::
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld hl, wSuckAllUsers
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	ret z

	ld a, [hl]
	and $fc
	ld [hl], a
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $01

jr_053_5ec0:
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	res 6, [hl]
	inc c
	dec b
	jr nz, jr_053_5ec0

	ret


StartReactionKeepTarget_53::
	push bc
	ld a, b
	call SaveReaction_53
	pop bc
	ld a, c
	ld [wSkillTarget], a
	ret


CheckCriticalHit_53::
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_5eeb

	ld a, [wSkillUser]
	cp $04
	jr c, jr_053_5eeb

	ld de, $4102
	jr jr_053_5eee

jr_053_5eeb:
	ld de, $4025

jr_053_5eee:
	ld a, [wSkillUser]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	or a
	jr z, jr_053_5f0f

	cp $01
	jr z, jr_053_5f0f

	cp $02
	jr z, jr_053_5f0f

	ld a, $04

jr_053_5f0f:
	ld b, a
	ld a, [wRandomHigh]
	cp b
	ret


Call_53_5F15::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_53_5F19::
	dw Jump_53_5F21
	dw Jump_53_5F6E
	dw Jump_53_5FB6
	dw Jump_53_5FF0

Jump_53_5F21::
	ld hl, wAbsorbMP
	ld a, [hli]
	or [hl]
	call nz, Call_53_5FFA
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $90
	jr z, jr_053_5f66

	ld a, [wSkillFlags3]
	bit 3, a
	jr z, jr_053_5f66

	call DrawRandom_53
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_5f52

	ld a, [wSkillTarget]
	cp $04
	jr c, jr_053_5f52

	ld b, $40
	jr jr_053_5f54

jr_053_5f52:
	ld b, $aa

jr_053_5f54:
	ld a, [wRandomHigh]
	cp b
	jr nc, jr_053_5f66

	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wAbsorbMP
	ld a, [hli]
	or [hl]
	jr z, Jump_53_5F6E

	ret


jr_053_5f66:
	ld a, $03
	ld [wBattleSubStep2], a
	jp Jump_53_5FF0


Jump_53_5F6E::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 7, [hl]
	ret z

	ld a, [hl]
	and $63
	ld [hl], a
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, $db
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10

Call_53_5FA7::
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	ret


Jump_53_5FB6::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr z, Jump_53_5FF0

	ld a, [hl]
	and $63
	ld [hl], a
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, $dc
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call Call_53_5FA7
	ret


Jump_53_5FF0::
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


Call_53_5FFA::
	ld a, [wReactionKind]
	or a
	ret nz

	ld a, [wInterceptState]
	or a
	ret nz

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	ret z

	ld hl, far_AbsorbMP_53
	rst $10
	ret


Call_53_601C::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $90
	call nz, Call_53_60A2
	xor a
	ld [hli], a
	ld a, [hl]
	and $3c
	ld [hli], a
	inc hl
	res 7, [hl]
	inc hl
	inc hl
	ld a, [hl]
	and $fc
	ld [hl], a
	inc hl
	bit 7, [hl]
	ret z

	res 7, [hl]
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_42A6
	rst $10
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
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
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	call CompareHLBC
	pop hl
	jr nc, jr_053_6071

	ld a, [wBattleTemp]
	ld [hli], a
	ld a, [wBattleTempHigh]
	ld [hl], a

jr_053_6071:
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_424A
	rst $10
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
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
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	call CompareHLBC
	pop hl
	ret nc

	ld a, [wBattleTemp]
	ld [hli], a
	ld a, [wBattleTempHigh]
	ld [hl], a
	ret


Call_53_60A2::
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	pop hl
	ret


Call_53_60B3::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_53_60B7::
	dw Jump_53_60C9
	dw Jump_53_60DD
	dw Jump_53_6132
	dw Jump_53_6152
	dw Jump_53_617E
	dw Jump_53_61C2
	dw Jump_53_61E3
	dw Jump_53_620B
	dw Jump_53_6252

Jump_53_60C9::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, Jump_53_60DD

	ld a, $05
	ld [wBattleSubStep2], a
	jp Jump_53_61C2


Jump_53_60DD::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	inc hl
	ld a, [hl]
	and $30
	ld [hli], a
	ld a, [hl]
	and $c8
	ld [hli], a
	ld a, [hl]
	and $3f
	ld [hli], a
	inc hl
	ld a, [hl]
	ld b, a
	and $c0
	ld a, b
	jr z, jr_053_610f

	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	pop hl

jr_053_610f:
	and $33
	ld [hli], a
	ld a, [hl]
	and $3d
	ld [hli], a
	res 2, [hl]
	ld a, [wSkillTarget]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, $ac
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_53_6132::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	or a
	ret z

	ld [hl], $00
	ld a, $d9
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_53_6152::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, [hl]
	or a
	jr nz, jr_053_616b

	call Call_53_647C
	ld hl, wBattleSubStep2
	inc [hl]
	ret


jr_053_616b:
	ld [hl], $00
	call Call_53_626B
	ld a, $ad
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_53_617E::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld b, a
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	call Call_53_654F
	ld a, [wSkillTarget]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $80
	ld [hl], a
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	ld a, [wSkillTarget]
	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ret


Jump_53_61C2::
	ld a, [wSkillTarget]
	and $03
	cp $02
	jr z, jr_053_61d4

	ld hl, wSkillTarget
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	ret


jr_053_61d4:
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	and $04
	or $03
	ld [wSkillTarget], a
	ret


Jump_53_61E3::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

	call Call_53_650C
	ld a, [wSkillTarget]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, $d8
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_53_620B::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wSideFlags
	res 3, [hl]
	inc hl
	res 3, [hl]
	ld a, [wSkillTarget]
	cp $04
	jr c, jr_053_6223

	ld hl, $db01
	jr jr_053_6226

jr_053_6223:
	ld hl, wSideFlags

jr_053_6226:
	ld a, [hl]
	and $10
	ld [hl], a
	ld a, [wSkillId]
	cp $83
	jr z, jr_053_6234

	cp $a5
	ret nz

jr_053_6234:
	ld hl, wSideFlags
	set 3, [hl]
	inc hl
	set 3, [hl]
	ld a, [wSkillUser]
	and $04
	ld b, a
	ld a, [wSkillTarget]
	and $04
	cp b
	ret z

	ld a, b
	ld [wSkillTarget], a
	xor a
	ld [wBattleSubStep2], a
	ret


Jump_53_6252::
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleTemp], a
	xor a
	ld [wBattleTempHigh], a
	ret


Call_53_626B::
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld hl, far_LoadBattlerSkills
	rst $10
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_6287

	ld a, [wSkillTarget]
	cp $04
	jr c, jr_053_6287

	call Call_53_63C7
	jr jr_053_628a

jr_053_6287:
	call Call_53_62F1

jr_053_628a:
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call Call_53_62CF
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	call Call_53_62CF
	pop bc
	call CompareHLBC
	jr nc, jr_053_62ac

	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call Call_53_62DA

jr_053_62ac:
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call Call_53_62CF
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxMP
	call Call_53_62CF
	pop bc
	call CompareHLBC
	jr nc, jr_053_62ce

	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call Call_53_62DA

jr_053_62ce:
	ret


Call_53_62CF::
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


Call_53_62DA::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, h
	ld c, l
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a
	ret


Call_53_62F1::
	ld a, [wSkillTarget]
	and $03
	cp $03
	jp z, Call_53_63C7

	ld a, [wSkillTarget]
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxMP
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonAttack
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerAttack
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonDefense
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonAgility
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonIntelligence
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerIntelligence
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonLevel
	call GetPartyMonsterByte
	ld b, a
	ld a, [wSkillTarget]
	ld hl, wBattlerLevel
	call Call_53_6546
	ld a, [wSkillTarget]
	ld hl, wMonStat64
	call GetPartyMonsterByte
	ld b, a
	ld a, [wSkillTarget]
	ld hl, wBattlerPersonality1
	call Call_53_6546
	ld a, [wSkillTarget]
	ld hl, wMonStat65
	call GetPartyMonsterByte
	ld b, a
	ld a, [wSkillTarget]
	ld hl, wBattlerPersonality2
	call Call_53_6546
	ld a, [wSkillTarget]
	ld hl, wMonStat67
	call GetPartyMonsterByte
	ld b, a
	ld a, [wSkillTarget]
	ld hl, wBattlerStat67
	call Call_53_6546
	ld a, [wSkillTarget]
	ld hl, wMonStat66
	call GetPartyMonsterByte
	ld b, a
	ld a, [wSkillTarget]
	ld hl, wBattlerPersonality3
	call Call_53_6546
	ret


Call_53_63C7::
	sub $04
	ld hl, wEncSpecies
	call ReadWordEntry_53
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld hl, wTemplateLevel
	ld a, [wSkillTarget]
	ld de, wBattlerLevel
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, [wSkillTarget]
	ld b, a
	ld de, wBattlerMaxHP
	add a
	ld c, a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, wBattlerMaxMP
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, wBattlerAttack
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, wBattlerDefense
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, wBattlerAgility
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ld de, wBattlerIntelligence
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, wBattlerPersonality1
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, wBattlerPersonality2
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, wBattlerStat67
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ld a, b
	ld de, wBattlerPersonality3
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	ret


Call_53_647C::
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_648d

	ld a, [wSkillTarget]
	cp $03
	jr c, jr_053_648d

	call Call_53_64BA
	ret


jr_053_648d:
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret z

	ld a, [wSkillTarget]
	ld hl, wMonDefense
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call Call_53_653B
	ld a, [wSkillTarget]
	ld hl, wMonAgility
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call Call_53_653B
	ret


Call_53_64BA::
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret z

	ld hl, wEncSpecies
	call ReadWordEntry_53
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld hl, wTemplateAgility
	ld a, [wSkillTarget]
	add a
	ld de, wBattlerAgility
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ld hl, wTemplateDefense
	ld a, [wSkillTarget]
	add a
	ld de, wBattlerDefense
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	ld a, [hl]
	and $3f
	ld [hl], a
	ret


Call_53_650C::
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret


Call_53_653B::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


Call_53_6546::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


Call_53_654F::
	call Call_53_6593
	ld a, [wLinkFlags]
	bit 1, a
	ld a, b
	jr z, jr_053_6560

	cp $03
	jr nc, jr_053_6592

	jr jr_053_656a

jr_053_6560:
	cp $04
	jr c, jr_053_6592

	cp $07
	jr z, jr_053_6592

	sub $04

jr_053_656a:
	push bc
	ld bc, $0240
	call Multiply24
	ld bc, $9000
	add hl, bc
	pop bc
	push hl
	ld l, c
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
	ld hl, far_SetBattlePicPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10

jr_053_6592:
	ret


Call_53_6593::
	ld a, [wOnCGB]
	or a
	ret z

	ld a, $02
	ldh [rSVBK], a
	ld a, b
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ld a, $00
	ldh [rSVBK], a
	ret


Call_53_65AC::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_53_65B0::
	dw Jump_53_65BA
	dw Jump_53_661B
	dw Jump_53_667C
	dw Jump_53_66A6
	dw Jump_53_66BD

Jump_53_65BA::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_424A
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	srl b
	rr c
	call Call_53_66E1
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_53_66E8
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	call Call_53_66D6
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, h
	or l
	jr z, jr_053_661a

	call SetDamageMessageArgs_53
	ld a, $86
	ld [wTextIndex], a
	call Call_53_66FA
	ld a, $72
	call QueueSound
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	ret


jr_053_661a:
	ret


Jump_53_661B::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_42A6
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	srl b
	rr c
	call Call_53_66E1
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call Call_53_66E8
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	call Call_53_66D6
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, h
	or l
	jr z, jr_053_667b

	call SetDamageMessageArgs_53
	ld a, $95
	ld [wTextIndex], a
	call Call_53_66FA
	ld a, $72
	call QueueSound
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	ret


jr_053_667b:
	ret


Jump_53_667C::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr nz, jr_053_66a5

	set 1, [hl]
	call GetTargetName_53
	ld a, $98
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $84
	call QueueSound
	ret


jr_053_66a5:
	ret


Jump_53_66A6::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	ret


Jump_53_66BD::
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleTemp], a
	xor a
	ld [wBattleTempHigh], a
	ret


Call_53_66D6::
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret nc

	xor a
	ld [hld], a
	ld [hl], a
	ret


Call_53_66E1::
	ld a, b
	or c
	ret nz

	ld bc, $0001
	ret


Call_53_66E8::
	ld a, [hli]
	sub c
	ld e, a
	ld a, [hld]
	sbc b
	ld d, a
	jr c, jr_053_66f4

	or e
	jr z, jr_053_66f4

	ret nc

jr_053_66f4:
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	dec bc
	ret


Call_53_66FA::
	ld a, [wSkillTarget]
	cp $04
	jr nc, jr_053_6705

	ld hl, wTextIndex
	inc [hl]

jr_053_6705:
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Call_53_670E::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_53_6712::
	dw Jump_53_6720
	dw Jump_53_67A9
	dw Jump_53_6866
	dw Jump_53_68B4
	dw Jump_53_6971
	dw Jump_53_6A04
	dw Jump_53_6A89

Jump_53_6720::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_053_674b

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, jr_053_6752

	call GetTargetName_53
	ld a, $ba
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10

jr_053_674b:
	ld a, $03
	ld [wBattleSubStep2], a
	jr jr_053_67a8

jr_053_6752:
	ld a, [wInterceptState]
	or a
	jr nz, jr_053_67a8

	inc hl
	bit 4, [hl]
	jr z, jr_053_67a8

	inc hl
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call CheckBattlerCanAct
	jr c, jr_053_67a8

	ld a, b
	ld hl, wTextArg0
	push bc
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetBattlerName_53
	pop bc
	ld a, b
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ld a, $80
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $04
	ld [wInterceptState], a

jr_053_67a8:
	ret


Jump_53_67A9::
	ld hl, wBattleSubStep2
	inc [hl]
	call CheckBossImmunity_53
	or a
	jp z, Jump_053_6858

	call DrawRandom_53
	ld a, [wSkillTarget]
	ld hl, $dd2b
	ld b, a
	add a
	add b
	add a
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	cp $03
	jp z, Jump_053_6858

	cp $02
	jr c, jr_053_67db

	ld a, [wRandomHigh]
	cp $c0
	jr nc, jr_053_6858

jr_053_67db:
	call GetTargetName_53
	ld a, [wSkillTarget]
	call GetBattlerHP
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, [wRandomLow]
	cp $7f
	jr c, jr_053_6832

	ld a, $64
	call Divide16
	ld a, h
	or l
	jr nz, jr_053_67ff

	ld hl, $0001

jr_053_67ff:
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	jr c, jr_053_6832

	or c
	jr z, jr_053_6832

	ld a, $6c
	ld [wBattleTempHigh], a
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	call AmountToTextArg1_53
	ld a, $82
	ld [wTextIndex], a
	call IsTargetOnOwnSide_53
	jr nc, jr_053_6846

	ld hl, wTextIndex
	inc [hl]
	jr jr_053_6846

jr_053_6832:
	ld a, $e9
	ld [wTextIndex], a
	ld a, $9c
	ld [wBattleTempHigh], a
	call IsTargetOnOwnSide_53
	jr nc, jr_053_6846

	ld a, $e3
	ld [wTextIndex], a

jr_053_6846:
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, [wBattleTempHigh]
	cp $ff
	ret z

	call QueueSound
	ret


Jump_053_6858:
jr_053_6858:
	ld hl, wBattleSubStep2
	inc [hl]
	call GetTargetName_53
	ld a, $b8
	ld [wTextIndex], a
	jr jr_053_6846

Jump_53_6866::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hld], a
	or [hl]
	ret nz

	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	xor a
	ld [wBattleStepArg1], a
	ld hl, far_DefeatBattler
	rst $10
	call IsTargetOnOwnSide_53
	jr c, jr_053_68af

	ld hl, far_BlankEnemyPicture
	rst $10
	ld a, $03
	ld [wBattleSubStep], a
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wSkillTarget]
	ld [wJoinCandidate], a
	ret


jr_053_68af:
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ret


Jump_53_68B4::
	ld a, [wShieldTarget]
	cp $ff
	jr z, jr_053_68df

	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, [wShieldTarget]
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillTarget]
	ld [hl], a
	ld a, $ff
	ld [wShieldTarget], a
	xor a
	ld [wInterceptState], a

jr_053_68df:
	ld a, [wReactionKind]
	or a
	jr nz, jr_053_68fd

	ld hl, wBattleSubStep2
	inc [hl]

Call_53_68E9::
	ld a, [wSkillTarget]
	and $03
	cp $02
	ret z

	ld hl, wSkillTarget
	inc [hl]
	call Call_53_690E
	xor a
	ld [wBattleSubStep2], a
	ret


jr_053_68fd:
	ld hl, far_RestoreInterruptedAction
	rst $10
	call Call_53_68E9
	ret


UnusedNextSubStep_53::
	db $21, $ed, $d9, $34, $af, $ea, $ee, $d9, $c9

Call_53_690E::
	ld a, [wSkillFlags2]
	bit 0, a
	ret z

	ld a, [wReactionKind]
	bit 2, a
	ret nz

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	ret z

	ld a, $00
	ld [wReflectAnim], a
	bit 1, [hl]
	jr nz, jr_053_6937

	res 5, [hl]
	ld a, $07
	ld [wReflectAnim], a

jr_053_6937:
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, jr_053_6944

	ld a, [wSkillUser]

jr_053_6944:
	rrca
	rrca
	and $01
	add $7b
	ld a, a
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $04
	call StartReaction_53
	ld a, $02
	ld [wInterceptState], a
	ld a, $03
	ld [wBattleSubStep], a
	ld a, $03
	ld [wBattleSubStep2], a
	ret


Jump_53_696B::
	ld a, [wSkillUser]
	ld [wSkillTarget], a

Jump_53_6971::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	call CheckBattlerPresent
	ret c

	call DrawRandom_53
	call GetUserName_53
	ld a, [wSkillUser]
	call GetBattlerHP
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, [wRandomHigh]
	cp $7f
	jr c, jr_053_69d7

	ld a, $64
	call Divide16
	ld a, h
	or l
	jr nz, jr_053_69a3

	ld hl, $0001

jr_053_69a3:
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	or c
	jr z, jr_053_69d7

	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	call AmountToTextArg1_53
	ld a, $85
	ld [wTextIndex], a
	ld a, $ff
	ld [wBattleTempHigh], a
	jr jr_053_69f2

jr_053_69cb:
	ld a, $e5
	ld [wTextIndex], a
	ld a, $ff
	ld [wBattleTempHigh], a
	jr jr_053_69f2

jr_053_69d7:
	ld a, [wSkillId]
	cp $96
	jr z, jr_053_69cb

	ld a, $ff
	ld [wBattleTempHigh], a
	ld a, $e7
	ld [wTextIndex], a
	call IsUserOnOwnSide_53
	jr nc, jr_053_69f2

	ld a, $ea
	ld [wTextIndex], a

jr_053_69f2:
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, [wBattleTempHigh]
	cp $ff
	ret z

	call QueueSound
	ret


Jump_53_6A04::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr c, jr_053_6a39

	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hld], a
	or [hl]
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $01
	ld [hl], a

jr_053_6a39:
	ld a, [wSkillUser]
	ld [wBattleArg0], a
	xor a
	ld [wBattleStepArg1], a
	ld hl, far_DefeatBattler
	rst $10
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	call IsUserOnOwnSide_53
	jr c, jr_053_6a70

	ld a, [wBattleSubStep]
	push af
	ld hl, far_BlankEnemyPicture
	rst $10
	pop af
	ld [wBattleSubStep], a
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_6a74

	ld a, [wSkillTarget]
	ld [wJoinCandidate], a
	jr jr_053_6a74

jr_053_6a70:
	ld hl, far_UpdateStatusIcon_50
	rst $10

jr_053_6a74:
	pop af
	ld [wSkillTarget], a
	ret


Jump_53_6A79::
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hli], a
	ld [hl], a

Jump_53_6A89::
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleTemp], a
	xor a
	ld [wBattleTempHigh], a
	ret


Call_53_6A9B::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_53_6A9F::
	dw Jump_53_6AAD
	dw Jump_53_6ADD
	dw Jump_53_6B53
	dw Jump_53_6B7E
	dw Jump_53_696B
	dw Jump_53_6A04
	dw Jump_53_6A79

Jump_53_6AAD::
	ld hl, wBattleSubStep2
	inc [hl]
	xor a
	ld [wBattleTempHigh], a
	ld a, [wSkillTarget]
	ld hl, wSkillUser
	cp [hl]
	jr z, jr_053_6ad4

	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_053_6ad4

	cp $01
	ret z

	ld hl, wBattleSubStep2
	inc [hl]
	ret


jr_053_6ad4:
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_53_6ADD::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, $9e
	ld [wBattleTempHigh], a
	call Call_53_6BC1
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ld b, a
	jr nz, jr_053_6b1e

	cp $03
	jr c, jr_053_6b31

	jr jr_053_6b22

jr_053_6b1e:
	cp $03
	jr nc, jr_053_6b31

jr_053_6b22:
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	call Call_53_654F
	jr jr_053_6b42

jr_053_6b31:
	swap a
	ld hl, $8da0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld de, $5b02
	call DecompressVRAM

jr_053_6b42:
	ld a, $9e
	ld [wBattleTempHigh], a
	ld a, $ff
	ld [wSkillTempPtr], a
	call GetTargetName_53
	ret


	db $25, $2b, $31

Jump_53_6B53::
	ld hl, wBattleSubStep2
	inc [hl]
	call Call_53_6BC1
	ld hl, far_StartSkillVisual
	rst $10
	ld a, $84
	ld [wBattleTempHigh], a
	call GetTargetName_53
	ld a, [wLinkActive]
	or a
	jr z, jr_053_6b72

	call IsUserOnOwnSide_53
	ret nc

	jr jr_053_6b78

jr_053_6b72:
	ld a, [wSkillUser]
	cp $04
	ret nc

jr_053_6b78:
	ld a, $70
	ld [wSkillTempPtr], a
	ret


Jump_53_6B7E::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wBattleTempHigh]
	or a
	jr z, jr_053_6bb0

	ld a, [wBattleTempHigh]
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, [wSkillTempPtr]
	cp $ff
	jr z, jr_053_6bb0

	ld a, [wLinkActive]
	or a
	jr nz, jr_053_6baa

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_053_6bb0

jr_053_6baa:
	ld a, [wSkillTempPtr]
	call QueueSound

jr_053_6bb0:
	ld a, [wSkillTarget]
	and $03
	cp $02
	ret z

	ld hl, wSkillTarget
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	ret


Call_53_6BC1::
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	ret


Call_53_6BE2::
	ld a, [wSkillTarget]
	cp $03
	jr z, jr_053_6c3e

	cp $06
	jr z, jr_053_6c0a

	cp $03
	jr c, jr_053_6c1b

	inc a
	ld [wSkillTarget], a
	call CheckBattlerPresent
	jr c, Call_53_6BE2

	ld a, $01
	ld [wBattleSubStep], a
	ld a, $0b
	ld [wBattleSubStep2], a
	ld a, $00
	ld [wBattleStepArg1], a
	ret


jr_053_6c0a:
	ld a, [wSkillId]
	cp $a4
	jr z, jr_053_6c3e

	ld a, $00
	ld [wSkillTarget], a
	call CheckBattlerPresent
	jr c, Call_53_6BE2

jr_053_6c1b:
	call CheckBattlerPresent
	jr c, jr_053_6c38

	ld a, [wSkillTarget]
	call GetTargetName_53
	ld a, $aa
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld hl, wSkillTarget
	inc [hl]
	ret


jr_053_6c38:
	ld hl, wSkillTarget
	inc [hl]
	jr Call_53_6BE2

jr_053_6c3e:
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


IsTargetOnOwnSide_53::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr nz, jr_053_6c55

	cp $04
	ret


jr_053_6c55:
	cp $04
	ccf
	ret


IsUserOnOwnSide_53::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillUser]
	jr nz, jr_053_6c66

	cp $04
	ret


jr_053_6c66:
	cp $04
	ccf
	ret


Padding_53_6C6A::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00
