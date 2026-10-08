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
	dw CureAilments_53
	dw RunDispelStages_53
	dw RunWeakenStages_53
	dw RunDeathStages_53
	dw RunReviveAllStages_53
	dw ShowShockedNext_53
	dw CheckBossImmunity_53
	dw RunHitWakeStages_53

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
;@ test: wSkillUser = rand(0, 7); wSkillId = rng.choice([0x42, 0x95, 0x3A])
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

;>@f fill(addr(wBattleSubStep), 0, 7)       # the step variables up to wPanelMode
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
;@ test: skill = rng.choice([0x32, 0x42, 0x66, 0x95, 0x96, 0x03, 0x3A]); wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7); wBattleType = rand(0, 2); wSkillId = rng.choice([0x12, 0x14, 0x69, 0x3A])
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


;@ def Hit_Intercept_53()
;@ path: battle/skills
;@ Stage 7: whether the attack reaches its target or someone or something else gets in the way: a
;@ target high in the sky cannot be reached by skills with bit 5 of wSkillFlags3 ("But it doesn't
;@ reach ..."); a breath on a side under SuckAll is sucked in by its user ("... absorbs the attack",
;@ the user reacts); a protector (Cover, Guardian) steps in ("... protects ..."); a target that
;@ dodges aside lets the attack hit another monster (DodgeAside_53); a wind blows a breath back
;@ ("The wind around ... reflects the attack"); Bounce or MagicBack reflect a spell. A reaction is
;@ not intercepted except by a protector (wReactionKind bit 3).
;@ test: skip calls routines in other banks
Hit_Intercept_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wReactionKind & 0x08: return Cover()
	ld a, [wReactionKind]
	bit 3, a
	jp nz, .cover

;> LoadSkillFlags(); DrawRandom_53()
	ld hl, far_LoadSkillFlags
	rst $10
	call DrawRandom_53
;>@n if wBattlerStatus4[8 * wSkillTarget] & 0x0C and wSkillFlags3 & 0x20:   # high in the sky
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr z, .reach

;=@n
	ld a, [wSkillFlags3]
	bit 5, a
	jr z, .reach

;>     wBattleSubStep = 5; wBattleSubStep2 = 0      # the skill misses
	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;>     GetTargetName_53()
	call GetTargetName_53
;>     wTextIndex = 0xC1; wTextGroup = 0           # "But it doesn't reach ...!"
	ld a, $c1
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     QueueSound(0x6F); return
	ld a, $6f
	call QueueSound
	ret


.reach
;> if not (wSkillFlags1 & 0x10): return Cover()   # not a breath
	ld a, [wSkillFlags1]
	bit 4, a
	jp z, .cover

;> side = wSkillTarget >> 2 & 1
	ld a, [wSkillTarget]
	rrca
	rrca
	and $01
	ld b, a
;>@f if not (wSideFlags[side] & 0x40): return Cover()   # no SuckAll on that side
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	bit 6, [hl]
	jp z, .cover

;> if wReactionKind: return Hit_EasyDodge_53()
	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

;> if wSkillId == 0x8F: return Hit_EasyDodge_53()  # SuckAll itself
	ld a, [wSkillId]
	cp $8f
	jp z, Hit_EasyDodge_53

;>@u sucker = wSuckAllUsers[side] >> 2 & 3 | wSkillTarget & 4
	ld a, b
	ld hl, wSuckAllUsers
	add l
	ld l, a
	ld a, $00
	adc h
;=@u
	ld h, a
	ld a, [hl]
	rrca
	rrca
	and $03
	ld c, a
;=@u
	ld a, [wSkillTarget]
	and $04
	or c
	ld c, a
;> if CheckBattlerCanAct(sucker): return Hit_EasyDodge_53()
	call CheckBattlerCanAct
	jp c, Hit_EasyDodge_53

;>@e entry = addr(wBattlerAction) + 2 * wSkillUser + 1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@e
	adc h
	ld h, a
;>@h wHitCount += sucker - mem[entry]; mem[entry] = sucker
	ld a, [hl]
	ld [hl], c
	ld b, a
	ld a, c
	sub b
	ld b, a
;=@h
	ld a, [wHitCount]
	add b
	ld [wHitCount], a
;> wSkillTarget = sucker
	ld a, c
	ld [wSkillTarget], a
;> StartReactionKeepTarget_53(2, sucker)      # the sucker answers with the breath
	ld b, $02
	call StartReactionKeepTarget_53
;> GetTargetName_53()
	call GetTargetName_53
;> wTextIndex = 0x81; wTextGroup = 0           # "... absorbs the attack!"
	ld a, $81
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C(); return
	ld hl, far_StartText_4C
	rst $10
	ret


.cover
;> def Cover():
;>@cv     if wSkillFlags2 & 0x02 and not wInterceptState:
	ld a, [wSkillFlags2]
	bit 1, a
	jr z, Hit_TryDodgeAside_53

;=@cv
	ld a, [wInterceptState]
	or a
	jr nz, Hit_TryDodgeAside_53

;>         if wBattlerStatus6[8 * wSkillTarget] & 0x10:   # protected
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 4, [hl]
	jr z, Hit_TryDodgeAside_53

;>@pr             protector = wBattlerStatus7[8 * wSkillTarget] >> 4
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	swap a
	and $0f
;=@pr
	ld b, a
;>             if CheckBattlerCanAct(protector): return Hit_NotProtected_53()
	call CheckBattlerCanAct
	jr c, Hit_NotProtected_53
;>             return ShowProtectMessage_53(protector)
;>     return Hit_TryDodgeAside_53()

;@ def ShowProtectMessage_53(protector: b)
;@ path: battle/skills
;@ `protector` takes the attack in place of the target: "... protects ..." ($80) with both names; the
;@ protector becomes the target (the old one is kept in wShieldTarget) and wInterceptState 4.
;@ test: skip calls routines in other banks
ShowProtectMessage_53::
;> GetBattlerName_53(protector, addr(wTextArg0))
	ld a, b
	ld hl, wTextArg0
	push bc
	ld [wNamePos], a
	call GetBattlerName_53
;> wShieldTarget = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg1))
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetBattlerName_53
;> wSkillTarget = protector
	pop bc
	ld a, b
	ld [wSkillTarget], a
;>@e wBattlerAction[2 * wSkillUser + 1] = protector
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@e
	adc h
	ld h, a
	ld [hl], b
;> wTextIndex = 0x80; wTextGroup = 0           # "... protects ...!"
	ld a, $80
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wInterceptState = 4
	ld a, $04
	ld [wInterceptState], a
	ret


;@ def Hit_NotProtected_53()
;@ path: battle/skills
;@ Part of Hit_Intercept_53: points hl at the target's status byte 6 and goes on with the dodge check.
;@ test: skip goes on into another routine
Hit_NotProtected_53::
;> status6 = addr(wBattlerStatus6) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
;> return Hit_TryDodgeAside_53(status6)

;@ def Hit_TryDodgeAside_53(status6: hl)
;@ path: battle/skills
;@ Part of Hit_Intercept_53: a physical attack on a target that dodges (by personality,
;@ wPersonalityNudge bit 5, or Dodge - bit 5 of the byte at `status6`) goes to another monster
;@ (DodgeAside_53, wInterceptState 2); a wind (TailWind, IsWindReflecting_53) turns a breath back on
;@ its user; Bounce or MagicBack reflect a reflectable skill (bit 0 of wSkillFlags2; MagicBack is used
;@ up) - "A wall of light reflects the spell" ($7B/$7C). Otherwise on to Hit_EasyDodge_53.
;@ test: skip calls routines in other banks
Hit_TryDodgeAside_53::
;> if wReactionKind: return Hit_EasyDodge_53()
	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

;> if wSkillFlags1 & 0x80:                 # a physical attack
	ld a, [wSkillFlags1]
	bit 7, a
	jr z, .breath

;>     if CheckBattlerCanAct(wSkillTarget): return Hit_EasyDodge_53()
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jp c, Hit_EasyDodge_53

;>@nu     if wPersonalityNudge[wSkillTarget] & 0x20 or mem[status6] & 0x20:
	push hl
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
;=@nu
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	pop hl
	jr nz, .dodge

;=@nu
	bit 5, [hl]
	jr z, .breath

.dodge
;>         wBattleTemp = 0; wShieldTarget = wSkillTarget
	xor a
	ld [wBattleTemp], a
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
;>         DodgeAside_53()
	call DodgeAside_53
;>         if not mem[addr(wSkillStatusPtr)]: return Hit_EasyDodge_53()   # no dodge
	ld a, [wSkillStatusPtr]
	or a
	jp z, Hit_EasyDodge_53

;>         wInterceptState = 2; return
	ld a, $02
	ld [wInterceptState], a
	ret


.breath
;> if wSkillFlags1 & 0x10:                 # a breath
	ld a, [wSkillFlags1]
	bit 4, a
	jp z, .reflect

;>     if wReactionKind: return Hit_EasyDodge_53()
	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

;>     if IsWindReflecting_53():
	call IsWindReflecting_53
	jr z, .reflect

;>         mem[addr(wBattlerStatus2) + 8 * wSkillTarget] &= ~0x40     # the wind is used up
	res 6, [hl]
;>         GetTargetName_53(); StartReaction_53(1)    # the breath goes back to its user
	call GetTargetName_53
	ld a, $01
	call StartReaction_53
;>         wReflectAnim = 2; wInterceptState = 2
	ld a, $02
	ld [wReflectAnim], a
	ld a, $02
	ld [wInterceptState], a
;>         wTextIndex = 0x7D; wTextGroup = 0        # "The wind around ... reflects the attack!"
	ld a, $7d
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>         StartText_4C(); return
	ld hl, far_StartText_4C
	rst $10
	ret


.reflect
;> if not (wSkillFlags2 & 0x01): return Hit_EasyDodge_53()
	ld a, [wSkillFlags2]
	bit 0, a
	jp z, Hit_EasyDodge_53

;> if wReactionKind: return Hit_EasyDodge_53()
	ld a, [wReactionKind]
	or a
	jp nz, Hit_EasyDodge_53

;> st2 = addr(wBattlerStatus2) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
;> if not (mem[st2] & 0x22): return Hit_EasyDodge_53()   # neither Bounce nor MagicBack
	ld a, [hl]
	and $22
	jp z, Hit_EasyDodge_53

;> wReflectAnim = 0
	ld a, $00
	ld [wReflectAnim], a
;> if not (mem[st2] & 0x02):              # MagicBack: used up
	bit 1, [hl]
	jr nz, .message

;>     mem[st2] &= ~0x20; wReflectAnim = 7
	res 5, [hl]
	ld a, $07
	ld [wReflectAnim], a

.message
;>@sd side = (wSkillUser if wLinkFlags & 0x02 else wSkillTarget) >> 2 & 1
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, .side

;=@sd
	ld a, [wSkillUser]

.side
;=@sd
	rrca
	rrca
	and $01
;> wTextIndex = 0x7B + side; wTextGroup = 0     # "A wall of light reflects the spell" / "The spell is reflected"
	add $7b
	ld a, a
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> StartReaction_53(4)                      # the spell goes back to its user
	ld a, $04
	call StartReaction_53
;> wInterceptState = 2
	ld a, $02
	ld [wInterceptState], a
	ret


;@ def Hit_EasyDodge_53()
;@ path: battle/skills
;@ Stage 8: after a dodge aside the new target may be protected in turn (wInterceptState 3). A
;@ dodgeable skill (bit 7 of wSkillFlags2) on a monster whose personality lets it dodge easily
;@ (wPersonalityNudge bit 7) misses: "... easily dodges the attack" ($6E).
;@ test: skip calls routines in other banks
Hit_EasyDodge_53::
;>@st if wInterceptState == 1:
;>@st1     wBattleSubStep2 += 1; return Hit_CheckMiss_53()
;=@st
	ld a, [wInterceptState]
	or a
	jr z, .easyDodge

	cp $01
	jr z, .done

;>@st2 elif wInterceptState == 2:
;>@st3     return Covered()
;=@st2
	cp $02
	jr nz, .easyDodge

	cp $04
	jr z, .done

;=@st3
	jr .covered
;> return EasyDodgeCheck()

.done
;=@st1
	ld hl, wBattleSubStep2
	inc [hl]
	jr Hit_CheckMiss_53

;> def EasyDodgeCheck():
;>     wBattleSubStep2 += 1
.easyDodge
	ld hl, wBattleSubStep2
	inc [hl]
;>     if CheckBattlerCanAct(wSkillTarget): return Hit_CheckMiss_53()
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, Hit_CheckMiss_53

;>     if not (wSkillFlags2 & 0x80): return Hit_CheckMiss_53()
	ld a, [wSkillFlags2]
	bit 7, a
	jr z, Hit_CheckMiss_53

;>@nu     if not (wPersonalityNudge[wSkillTarget] & 0x80): return Hit_CheckMiss_53()
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nu
	ld h, a
	bit 7, [hl]
	jr z, Hit_CheckMiss_53

;>     GetTargetName_53()
	call GetTargetName_53
;>     wTextIndex = 0x6E; wTextGroup = 0       # "... easily dodges the attack!"
	ld a, $6e
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     EndSkillMissed_53(); QueueSound(0x6F)
	call EndSkillMissed_53
	ld a, $6f
	call QueueSound
;>     return
	ret


.covered
;> def Covered():                          # the monster it dodged to may be protected
;>     if not (wSkillFlags2 & 0x02): return EasyDodgeCheck()
	ld a, [wSkillFlags2]
	bit 1, a
	jr z, .easyDodge

;>     if not (wBattlerStatus6[8 * wSkillTarget] & 0x10): return EasyDodgeCheck()
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 4, [hl]
	jr z, .easyDodge

;>@pr     protector = wBattlerStatus7[8 * wSkillTarget] >> 4
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	swap a
	and $0f
;=@pr
	ld b, a
;>     if CheckBattlerCanAct(protector): return EasyDodgeCheck()
	call CheckBattlerCanAct
	jr c, .easyDodge

;>     ShowProtectMessage_53(protector); wInterceptState += 1
	call ShowProtectMessage_53
	ld hl, wInterceptState
	inc [hl]
	ret


;@ def Hit_CheckMiss_53()
;@ path: battle/skills
;@ Stage 9: a missing target ends the action (except for the revival skills, Farewell, LifeSong,
;@ LifeDance, ALLREVIVE, SuckAll, Guardian, StormWind). An iron lump is invulnerable to skills with
;@ bit 2 of wSkillFlags2 (not to the take-off of HighJump; a call for help is "not heard"); a physical
;@ attack cannot reach a monster high in the sky; a user in an illusion (5 in 8) or blinded (3 in 8)
;@ misses skills with bit 1 of wSkillFlags1; a dodgeable skill (bit 7 of wSkillFlags2) may be dodged
;@ - always one in two while side-stepping, else 43, 8 or 2 in 256 by the target's agility (from
;@ 448, from 32, below). Otherwise straight on to stage 10.
;@ test: skip calls routines in other banks
Hit_CheckMiss_53::
;>@x if wSkillId not in (0x30, 0x31, 0x32, 0x95, 0x96, 0xAD, 0x8F, 0x89, 0x8B):
	ld a, [wSkillId]
	cp $30
	jr z, .check

	cp $31
	jr z, .check

;=@x
	cp $32
	jr z, .check

	cp $95
	jr z, .check

	cp $96
	jr z, .check

;=@x
	cp $ad
	jr z, .check

	cp $8f
	jr z, .check

	cp $89
	jr z, .check

;=@x
	cp $8b
	jr z, .check

;>     if CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, .check

;>         wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;>         return
	ret


.check
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@i if wBattlerStatus[8 * wSkillTarget + 5] & 0xC0 and wSkillFlags2 & 0x04 and not IsHighJumpTakeoff_53():
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, .notIron

;=@i
	ld a, [wSkillFlags2]
	bit 2, a
	jr z, .notIron

	call IsHighJumpTakeoff_53
	jr z, .notIron

;>     if wSkillId in (0x52, 0x53): return CallHelp()     # CallHelp, YellHelp
	ld a, [wSkillId]
	cp $52
	jr z, .callHelp

	cp $53
	jr z, .callHelp

;>     if wSkillId == 0x14: return                         # Sacrifice
	cp $14
	jr z, .done
;>@ir     return IronLump()
;=@ir

.iron
;> def IronLump():
;>     EndSkillMissed_53()
	call EndSkillMissed_53
;>     return ShowFail(0xBA)                # "... turns to iron and becomes invulnerable"
	ld a, $ba
	jr .show

.callHelp
;> def CallHelp():
;>     if wHitCount >= 2: return IronLump()
	ld a, [wHitCount]
	cp $02
	jr nc, .iron

;>     wHitShown = 0; wHitCount = 0x10      # no further hits
	ld a, $00
	ld [wHitShown], a
	ld a, $10
	ld [wHitCount], a
;>     wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;>     return ShowFail(0xC2)                # "But the call is not heard"
	ld a, $c2

.show
;> def ShowFail(msg):
;>     GetTargetName_53()
	push af
	call GetTargetName_53
	pop af
;>     wTextIndex = msg; wTextGroup = 0
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     QueueSound(0x6F)
	ld a, $6f
	call QueueSound

.done
;>     return
	ret


.notIron
;>@s if wSkillFlags1 & 0x80 and wBattlerStatus[8 * wSkillTarget + 4] & 0x04:   # physical, target high in the sky
	ld a, [wSkillFlags1]
	bit 7, a
	jr z, .roll

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus4
;=@s
	call AddEightTimes
	bit 2, [hl]
	jr z, .roll

;>     GetTargetName_53(); return ShowMissMessage_53(0xC1)    # "But it doesn't reach ...!"
	call GetTargetName_53
	ld a, $c1
	jp ShowMissMessage_53


.roll
;> DrawRandom_53()
	call DrawRandom_53
;> if wSkillFlags1 & 0x02:
	ld a, [wSkillFlags1]
	bit 1, a
	jr z, .dodge

;>@il     if wBattlerStatus[8 * wSkillUser + 1] & 0x02 and wRandomHigh < 0xA0:   # in an illusion (Surround)
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr z, .notIllusion

;=@il
	ld a, [wRandomHigh]
	cp $a0
	jr nc, .notIllusion

;>         ShowMissed_53(); return
	call ShowMissed_53
	ret


.notIllusion
;>@bl     if wBattlerStatus[8 * wSkillUser + 5] & 0x03 and wRandomLow < 0x60:   # blinded (SandStorm)
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $03
	jr z, .dodge

;=@bl
	ld a, [wRandomLow]
	cp $60
	jr nc, .dodge

;>         ShowMissed_53(); return
	call ShowMissed_53
	ret


.dodge
;>@d if wSkillFlags2 & 0x80 and not CheckBattlerCanAct(wSkillTarget) and not IsChargeUpTurn_53():
	ld a, [wSkillFlags2]
	bit 7, a
	jr z, .noDodge

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, .noDodge

;=@d
	call IsChargeUpTurn_53
	jr z, .noDodge

;>@ss     if wBattlerStatus[8 * wSkillTarget + 5] & 0x0C and not (wRandomHigh & 1):   # side-stepping
;>@ss2         return ShowEasyDodge_53()
;=@ss
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr z, .agility

;=@ss
	ld a, [wRandomHigh]
	and $01
	jp z, .dodged

.agility
;>     agi = mem16[addr(wBattlerAgility) + 2 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call ReadWordEntry_53
;>@b     chance = 0x2B if agi >= 0x1C0 else 0x08 if agi >= 0x20 else 0x02
	ld bc, $01c0
	call CompareHLBC
	jr nc, .fast

	ld bc, $0020
	call CompareHLBC
	jr nc, .medium

;=@b
	ld b, $02
	jr .compare

.fast
;=@b
	ld b, $2b
	jr .compare

.medium
;=@b
	ld b, $08

.compare
;>     if wRandomHigh < chance:
	ld a, [wRandomHigh]
	cp b
	jr nc, .noDodge
;>         return ShowEasyDodge_53()

.dodged
;=@ss2
	call ShowEasyDodge_53
	ret


.noDodge
;> return Hit_Critical_53()
	jr Hit_Critical_53

;@ def ShowEasyDodge_53()
;@ path: battle/skills
;@ "... easily dodges the attack!" ($78) and the skill misses.
;@ test: skip calls routines in other banks
ShowEasyDodge_53::
;> GetTargetName_53()
	call GetTargetName_53
;> wTextIndex = 0x78; wTextGroup = 0
	ld a, $78
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> EndSkillMissed_53()
	call EndSkillMissed_53
;> QueueSound(0x6F)
	ld a, $6f
	call QueueSound
	ret


;@ def ShowMissed_53()
;@ path: battle/skills
;@ The skill misses: "Misses! ... is unharmed!" ($B6) for an enemy target, "Missed ...! No damage!"
;@ ($B7) for an own one (seen from this Game Boy in a link battle).
;@ test: skip calls routines in other banks
ShowMissed_53::
;> GetTargetName_53()
	call GetTargetName_53
;>@sd side = wSkillUser if wLinkFlags & 0x02 else wSkillTarget
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, .side

;=@sd
	ld a, [wSkillUser]

.side
;>@m msg = 0xB6 if side >= 4 else 0xB7
	cp $04
	jr c, .own

	ld a, $b6
	jr ShowMissMessage_53

.own
;=@m
	ld a, $b7

;> return ShowMissMessage_53(msg)

;@ def ShowMissMessage_53(msg: a)
;@ path: battle/skills
;@ Shows message `msg` about the target with the miss sound, and the skill ends (EndSkillMissed_53).
;@ test: skip calls routines in other banks
ShowMissMessage_53::
;> wTextIndex = msg; wTextGroup = 0
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> QueueSound(0x6F)
	ld a, $6f
	call QueueSound
;> return EndSkillMissed_53()

;@ def EndSkillMissed_53()
;@ path: battle/skills
;@ The skill misses: on with action step 5.
;@ test: wBattleSubStep = 1; wBattleSubStep2 = 9
EndSkillMissed_53::
;> wBattleSubStep = 5; wBattleSubStep2 = 0
	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def IsHighJumpTakeoff_53() -> zero
;@ path: battle/skills
;@ Zero flag when the skill is HighJump ($42) and the user is still on the ground: its take-off turn.
;@ test: wSkillId = rng.choice([0x42, 0x3A]); wSkillUser = rand(0, 7)
IsHighJumpTakeoff_53::
;> if wSkillId != 0x42: return False
	ld a, [wSkillId]
	cp $42
	ret nz

;>@r return not (wBattlerStatus[8 * wSkillUser + 4] & 0x0C)
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret


;@ def IsChargeUpTurn_53() -> zero
;@ path: battle/skills
;@ Zero flag when the skill is ChargeUP ($41) and the user is not charged yet: its charging turn.
;@ test: wSkillId = rng.choice([0x41, 0x3A]); wSkillUser = rand(0, 7)
IsChargeUpTurn_53::
;> if wSkillId != 0x41: return False
	ld a, [wSkillId]
	cp $41
	ret nz

;>@r return not (wBattlerStatus[8 * wSkillUser + 4] & 0x03)
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $03
	ret


;@ def Hit_Critical_53()
;@ path: battle/skills
;@ Stage 10: skills with bits 4-6 of wSkillFlags2 may hit critically (not while the attack is doubled
;@ by TwinHits): always with the personality effect "full force" (wPersonalityNudge bit 0) or under
;@ ALLCHANGE, else by the species' chance (CheckCriticalHit_53). A critical hit sets bit 7 of status
;@ byte 2, shows "A critical hit!" ($79/$7A by side) and goes straight on to stage 12.
;@ test: skip calls routines in other banks
Hit_Critical_53::
;> LoadSkillFlags()
	ld hl, far_LoadSkillFlags
	rst $10
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if not (wSkillFlags2 & 0x70): return
	ld a, [wSkillFlags2]
	and $70
	ret z

;>@t if wSkillFlags2 & 0x20 and wBattlerStatus[8 * wSkillUser + 1] & 0x04: return   # doubled (TwinHits)
	bit 5, a
	jr z, .crit

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
;=@t
	call AddEightTimes
	bit 2, [hl]
	ret nz

;> if wSkillFlags2 & 0x10:
	ld a, [wSkillFlags2]

.crit
	bit 4, a
	jr z, .noCrit

;>@n     if wPersonalityNudge[wSkillUser] & 0x01 or wBattlerStatus[8 * wSkillUser + 1] & 0x08 or CheckCriticalHit_53():
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@n
	ld h, a
	bit 0, [hl]
	jr nz, .critical

;=@n
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 3, [hl]
	jr nz, .critical

;=@n
	call DrawRandom_53
	call CheckCriticalHit_53
	jr nc, .noCrit

.critical
;>         wBattlerStatus[8 * wSkillUser + 2] |= 0x80      # critical hit
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	set 7, [hl]
;>@sd         side = (wSkillUser >> 2 & 1) ^ (1 if wLinkFlags & 0x02 else 0)
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld d, a
	ld a, [wLinkFlags]
;=@sd
	bit 1, a
	ld a, d
	jr z, .msg

;=@sd
	xor $01

.msg
;>         wTextIndex = 0x79 + side; wTextGroup = 0   # "A critical hit!" / "A pitiful attack!"
	add $79
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>         StartText_4C(); QueueSound(0x6E)
	ld hl, far_StartText_4C
	rst $10
	ld a, $6e
	call QueueSound
;>         wBattleSubStep2 += 1; return Hit_Damage_53()
	ld hl, wBattleSubStep2
	inc [hl]
	jr Hit_Damage_53

	db $c9

.noCrit
;> wBattlerStatus[8 * wSkillUser + 2] &= ~0x80
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	res 7, [hl]
	ret


;@ def Hit_WaitFrame_53()
;@ path: battle/skills
;@ Stage 11: just one frame (the first turn of HighJump comes here).
;@ test: wBattleSubStep2 = 11
Hit_WaitFrame_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def Hit_Damage_53()
;@ path: battle/skills
;@ Stage 12: the damage. After a critical hit it waits for its sound; TwinHits doubles wSkillAmount
;@ for skills with bit 5 of wSkillFlags2; a critical hit instead deals the user's attack (half for
;@ QuadHits) with a spread of +-5 % (SpreadDamage_53) and result $A8 ("... takes ... damage").
;@ Then the boosts (Hit_DamageBoost_53) and the target's guard (Hit_DamageGuard_53).
;@ test: skip calls routines in other banks
Hit_Damage_53::
;> if wBattlerStatus[8 * wSkillUser + 2] & 0x80:      # critical: wait for its sound
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 7, [hl]
	jr z, .noCrit

;>     if wSoundChannels & mem[addr(wSoundChannels) + 26] != 0xFF: return
	ld a, [wSoundChannels]
	ld hl, wSoundChannels+26
	and [hl]
	cp $ff
	ret nz

.noCrit
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@tw if wBattlerStatus[8 * wSkillUser + 1] & 0x04 and wSkillFlags2 & 0x20:   # TwinHits
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	jr z, .notDoubled

;=@tw
	ld a, [wSkillFlags2]
	bit 5, a
	jr z, .notDoubled

;>@d     wSkillAmount = wSkillAmount * 2 & 0xFFFF
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
	sla l
	rl h
;=@d
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
;>     return Hit_DamageGuard_53()
	jp Hit_DamageGuard_53


.notDoubled
;> if wBattlerStatus[8 * wSkillUser + 2] & 0x80:      # a critical hit
	inc hl
	bit 7, [hl]
	jr z, Hit_DamageBoost_53

;>     wBattlerStatus[8 * wSkillUser + 2] &= ~0x80
	res 7, [hl]
;>@r     wSkillResult = 0xA8; wSkillResultValue = 0xB682   # message $82, miss message $B6
	ld hl, $b682
	ld a, $a8
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
;=@r
	ld [wSkillMsgMiss], a
;>     amount = GetBattlerAttack(wSkillUser)
	ld a, [wSkillUser]
	call GetBattlerAttack
;>     if wSkillId == 0x51: amount = HalveHL_53(amount)   # QuadHits
	ld a, [wSkillId]
	cp $51
	call z, HalveHL_53
;>     wSkillAmount = SpreadDamage_53(amount)
	call SpreadDamage_53
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
;>     return Hit_DamageGuard_53()
	jr Hit_DamageGuard_53
;> return Hit_DamageBoost_53(addr(wBattlerStatus2) + 8 * wSkillUser)

;@ def HalveHL_53(n: hl) -> hl
;@ path: battle/skills
;@ n / 2.
;@ test: n = rand(0, 0xFFFF)
HalveHL_53::
;> return n >> 1
	srl h
	rr l
	ret


;@ def Hit_DamageBoost_53(st2: hl)
;@ path: battle/skills
;@ Part of stage 12: a charged-up user (ChargeUP, status byte 4 bit 0) boosts skills with bit 6 of
;@ wSkillFlags2, a held breath (SuckAir, bit 4) boosts the fire and ice breaths $5C-$63 - both to
;@ 2-2.5 times (BoostDamage_53). `st2` points at the user's status byte 2.
;@ test: skip calls routines in other banks
Hit_DamageBoost_53::
;> st4 = st2 + 2
	inc hl
	inc hl
;>@c if mem[st4] & 0x01 and wSkillFlags2 & 0x40:            # charged up
	bit 0, [hl]
	jr z, .notCharged

	ld a, [wSkillFlags2]
	bit 6, a
	jr z, .notCharged

;>@b     wSkillAmount = BoostDamage_53(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
	call BoostDamage_53
;=@b
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
	jr Hit_DamageGuard_53

.notCharged
;>@e elif mem[st4] & 0x10 and wSkillFlags1 & 0x10 and 0x5C <= wSkillId < 0x64:   # a held breath
	bit 4, [hl]
	jr z, Hit_DamageGuard_53

	ld a, [wSkillFlags1]
	bit 4, a
	jr z, Hit_DamageGuard_53

;=@e
	ld a, [wSkillId]
	cp $5c
	jr c, Hit_DamageGuard_53

	cp $64
	jr nc, Hit_DamageGuard_53

;>@b2     wSkillAmount = BoostDamage_53(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
	call BoostDamage_53
;=@b2
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
;> return Hit_DamageGuard_53()

;@ def Hit_DamageGuard_53()
;@ path: battle/skills
;@ Part of stage 12: a battle cry of the user (wPersonalityNudge bit 6) adds half. The target's
;@ stance (status byte 7): BladeD halves physical attacks, Defence halves and StrongD cuts to a
;@ tenth skills with bit 0 of wSkillFlags1, and its fear (wPersonalityNudge bit 1) halves again. A
;@ berserk target (status byte 6 bit 2) takes double from physical attacks (not Ramming, Kamikaze).
;@ test: skip goes on into another routine
Hit_DamageGuard_53::
;>@n if wPersonalityNudge[wSkillUser] & 0x40:          # battle cry
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@n
	ld h, a
	bit 6, [hl]
	jr z, .stance

;>@x     wSkillAmount += wSkillAmount >> 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
	ld b, h
	ld c, l
;=@x
	srl h
	rr l
	add hl, bc
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@x
	ld [wSkillAmount+1], a
	jr .stance

.stance
;> stance = wBattlerStatus[8 * wSkillTarget + 7] & 7
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	and $07
;> if stance:
	jr z, .noStance

;>     kind = stance & 3
	and $03
	ld c, a
;>     amount = wSkillAmount
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
;>     if kind == 0:                     # BladeD
	jr nz, .defence

;>         if not (wSkillFlags1 & 0x80): return Hit_Result_53()
	ld a, [wSkillFlags1]
	bit 7, a
	jp z, Hit_Result_53

.halve
;>         amount >>= 1
	srl h
	rr l
	jr .fear

.defence
;>     else:
;>         if not (wSkillFlags1 & 0x01): return Hit_Result_53()
	ld a, [wSkillFlags1]
	bit 0, a
	jr z, Hit_Result_53

;>         if kind & 1: amount >>= 1          # Defence: half
	bit 0, c
	jr nz, .halve

;>         else: amount //= 10                # StrongD: a tenth
	ld a, $0a
	call Divide16

.fear
;>@f     if wPersonalityNudge[wSkillTarget] & 0x02: amount >>= 1    # fear boosts its guard
	ld a, [wSkillTarget]
	ld de, wPersonalityNudge
	add e
	ld e, a
	ld a, $00
	adc d
;=@f
	ld d, a
	ld a, [de]
	bit 1, a
	jr z, .store

	srl h
	rr l

.store
;>     wSkillAmount = amount; return Hit_Result_53()
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
	jr Hit_Result_53

.noStance
;>@bz elif wBattlerStatus[8 * wSkillTarget + 6] & 0x04 and wSkillFlags1 & 0x80 and wSkillId not in (0x3C, 0x3E):
	dec hl
	bit 2, [hl]
	jr z, Hit_Result_53

	ld a, [wSkillFlags1]
	bit 7, a
	jr z, Hit_Result_53

;=@bz
	ld a, [wSkillId]
	cp $3c
	jr z, Hit_Result_53

	cp $3e
	jr z, Hit_Result_53

;>@d2     wSkillAmount = wSkillAmount * 2 & 0xFFFF
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
	sla l
	rl h
;=@d2
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
;> return Hit_Result_53()

;@ def Hit_Result_53()
;@ path: battle/skills
;@ Stage 13: wSkillResult (set by the skill effect routines) bit 6 ends the skill here (message
;@ wSkillResultValue = group, index when bit 7 is set). Bit 5 means the amount is HP damage: bit 4
;@ is set when there is some. With an effect (bit 4, not bit 2) the hit animation starts.
;@ test: skip calls routines in other banks
Hit_Result_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> r = wSkillResult
	ld a, [wSkillResult]
;> if r & 0x40:
	bit 6, a
	jr z, .notEnd

;>     wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;>     if not (wSkillResult & 0x80): return
	ld a, [wSkillResult]
	bit 7, a
	ret z

;>     SetDamageMessageArgs_53()
	call SetDamageMessageArgs_53
;>@t     wTextGroup = wSkillResultValue & 0xFF; wTextIndex = wSkillResultValue >> 8
	ld a, [wSkillResultValue]
	ld l, a
	ld a, [wSkillMsgMiss]
	ld h, a
	ld a, l
	ld [wTextGroup], a
;=@t
	ld a, h
	ld [wTextIndex], a
;>     StartText_4C(); PlaySkillSound1()
	ld hl, far_StartText_4C
	rst $10
	ld hl, far_PlaySkillSound1
	rst $10
;>     wHitShown = 1
	ld a, $01
	ld [wHitShown], a
;>@tm     if wSkillId == 0x1B: StartSkillVisual()       # TakeMagic
	ld a, [wSkillId]
	cp $1b
	ret nz

;=@tm
	ld hl, far_StartSkillVisual
	rst $10
	ret


.notEnd
;> if r & 0x20:                          # HP damage
	ld a, [wSkillResult]
	ld b, a
	bit 5, a
	jr z, .effect

;>@a     r = r | 0x10 if wSkillAmount else r & ~0x10
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
	ld a, h
	or l
;=@a
	jr z, .none

;=@a
	set 4, b
	jr .storeResult

.none
;=@a
	res 4, b

.storeResult
;>     wSkillResult = r
	ld a, b
	ld [wSkillResult], a

.effect
;> if wSkillResult & 0x10 and not (wSkillResult & 0x04):
	ld a, [wSkillResult]
	bit 4, a
	jr z, .done

	bit 2, a
	jr nz, .done

;>     PlaySkillSound1(); StartSkillVisual()
	ld hl, far_PlaySkillSound1
	rst $10
	ld hl, far_StartSkillVisual
	rst $10
;>     if wSkillAnimActive == 1: return Hit_Effect_53()
	ld a, [wSkillAnimActive]
	cp $01
	jr z, Hit_Effect_53

.done
;> return
	ret


;@ def Hit_Effect_53()
;@ path: battle/skills
;@ Stage 14: for a skill with an effect (wSkillResult bit 4, not bit 2) its hit effect and sound.
;@ test: skip calls routines in other banks
Hit_Effect_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wSkillResult & 0x04: return
	ld a, [wSkillResult]
	bit 2, a
	ret nz

;> if not (wSkillResult & 0x10): return
	bit 4, a
	ret z

;> PlaySkillSound2(); StartSkillHitEffect()
	ld hl, far_PlaySkillSound2
	rst $10
	ld hl, far_StartSkillHitEffect
	rst $10
;> wHitShown = 1
	ld a, $01
	ld [wHitShown], a
;> return Hit_Message_53()

;@ def Hit_Message_53()
;@ path: battle/skills
;@ Stage 15: the result message. With an effect: message wSkillResultValue (group 1 with bit 0), a
;@ TakeMagic glow may absorb MP, bit 3 picks the own-side wording; without one the miss message
;@ wSkillMsgMiss (group 1 with bit 1) and the action ends. The names and amount are filled in
;@ (Barrier drops the enemy letter when one enemy is left); message $29 has a fanfare.
;@ test: skip calls routines in other banks
Hit_Message_53::
;>@w if 0x84 <= wSkillId < 0x88 and not wBattleAnimDone: return     # a dragon call waits for its animation
	ld a, [wSkillId]
	cp $84
	jr c, .go

	cp $88
	jr nc, .go

;=@w
	ld a, [wBattleAnimDone]
	or a
	ret z

.go
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wSkillResult & 0x10:
	ld a, [wSkillResult]
	bit 4, a
	jr z, .miss

;>     CheckTakeMagic_53()
	call CheckTakeMagic_53
;>     wTextIndex = wSkillResultValue & 0xFF
	ld a, [wSkillResultValue]
	ld [wTextIndex], a
;>@o     if wSkillResult & 0x08 and IsTargetOnOwnSide2_53(): OwnSideMessage_53()
	ld a, [wSkillResult]
	bit 3, a
	jr z, .group

	call IsTargetOnOwnSide2_53
	jr nc, .group

;=@o
	call OwnSideMessage_53

.group
;>     wTextGroup = 0
	xor a
	ld [wTextGroup], a
;>     if wSkillResult & 0x01: wTextGroup = 1
	ld a, [wSkillResult]
	bit 0, a
	jr z, .adjust

	ld a, $01
	ld [wTextGroup], a
	jr .show
;>     else: AdjustMiss()

.miss
;> else:
;>     PlaySkillSound3()
	ld hl, far_PlaySkillSound3
	rst $10
;>     wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;>     wTextIndex = wSkillMsgMiss; wTextGroup = 0
	ld a, [wSkillMsgMiss]
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     if wSkillResult & 0x02: wTextGroup = 1
	ld a, [wSkillResult]
	bit 1, a
	jr z, .adjust

	ld a, $01
	ld [wTextGroup], a
;>@am     AdjustMiss()
;=@am

.adjust
;> def AdjustMiss():
;>     if wSkillResult & 0x08: OwnSideMissMessage_53()
	ld a, [wSkillResult]
	bit 3, a
	jr z, .show

	call OwnSideMissMessage_53

.show
;> group = wTextGroup; index = wTextIndex; SetDamageMessageArgs_53()
	ld a, [wTextGroup]
	ld l, a
	ld a, [wTextIndex]
	ld h, a
	push hl
	call SetDamageMessageArgs_53
;> wTextGroup = group; wTextIndex = index
	pop hl
	ld a, l
	ld [wTextGroup], a
	ld a, h
	ld [wTextIndex], a
;> if wSkillId == 0x24: DropEnemyLetter_53()      # Barrier
	ld a, [wSkillId]
	cp $24
	call z, DropEnemyLetter_53
;>@s if wTextIndex == 0x29 and wTextGroup == 0: QueueSound(0x6D)
	ld a, [wTextIndex]
	cp $29
	jr nz, .text

	ld a, [wTextGroup]
	or a
	jr nz, .text

;=@s
	ld a, $6d
	call QueueSound

.text
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def DropEnemyLetter_53()
;@ path: battle/names
;@ With wBattleTemp 1, cuts a last character that is not a letter (below $24) off the name in
;@ wTextArg0 (Barrier's message when the letter makes no sense).
;@ test: wBattleTemp = 1
DropEnemyLetter_53::
;> if wBattleTemp != 1: return
	ld a, [wBattleTemp]
	cp $01
	ret nz

;> p = addr(wTextArg0)
	ld hl, wTextArg0

.find
;> while mem[p] != 0xF0: p += 1
	ld a, [hl]
	cp $f0
	jr z, .found

	inc hl
	jr .find

.found
;> p -= 1
	dec hl
;> if mem[p] >= 0x24: return
	ld a, [hl]
	cp $24
	ret nc

;> mem[p] = 0xF0
	ld [hl], $f0
	ret


;@ def OwnSideMessage_53()
;@ path: battle/messages
;@ Changes the result message wTextIndex to its wording for a monster of the player's side: most
;@ have it right after ($82, $CC, $88, $8A, $86, $8E, $95, $B0, $B2 + 1), $E8 becomes $E3, $B5 $D2.
;@ test: wTextIndex = rng.choice([0x82, 0xE8, 0xB5, 0xB2, 0x10])
OwnSideMessage_53::
;> m = wTextIndex
	ld a, [wTextIndex]
;>@one if m in (0x82, 0xCC, 0x88, 0x8A, 0x86, 0x8E, 0x95, 0xB0, 0xB2): wTextIndex = m + 1
	cp $82
	jr z, .next

	cp $cc
	jr z, .next

;>@e8 elif m == 0xE8: wTextIndex = 0xE3
	cp $e8
	jr z, .e3

;=@one
	cp $88
	jr z, .next

	cp $8a
	jr z, .next

	cp $86
	jr z, .next

;=@one
	cp $8e
	jr z, .next

	cp $95
	jr z, .next

	cp $b0
	jr z, .next

;=@one
	cp $b2
	jr z, .next

;>@b5 elif m == 0xB5: wTextIndex = 0xD2
	cp $b5
	jr z, .d2

;> return
	ret


.next
;=@one
	ld hl, wTextIndex
	inc [hl]
	ret


.e3
;=@e8
	ld a, $e3
	ld [wTextIndex], a
	ret


.d2
;=@b5
	ld a, $d2
	ld [wTextIndex], a
	ret


;@ def OwnSideMissMessage_53()
;@ path: battle/messages
;@ Changes a "no effect" / dodge message (wTextIndex) to the right wording for the target: for an own
;@ monster $CA/$C9 become "... dodges quickly" ($C7; "covers its ears" $C4 for WarCry), $B6 becomes
;@ $B7, and $B8 depends on the skill ($C3, $C4, $CA or $C5-$C7); for an enemy $C3 becomes $B8.
;@ test: skip calls a routine with flag results
OwnSideMissMessage_53::
;> m = wTextIndex
	ld a, [wTextIndex]
;>@c if m in (0xCA, 0xC9): return Dodged()
	cp $ca
	jr z, .dodged

;> if m == 0xC3: return AirDodged()
	cp $c3
	jr z, .air

;> if m == 0xB6: return Missed()
	cp $b6
	jr z, .missed

;> if m == 0xB8: return NoEffect()
	cp $b8
	jr z, .noEffect

;=@c
	cp $c9
	jr z, .dodged

;> return
	ret


.dodged
;> def Dodged():
;>     if not IsTargetOnOwnSide2_53(): return
	call IsTargetOnOwnSide2_53
	ret nc

;>@w     wTextIndex = 0xC4 if wSkillId == 0x7D else 0xC7
	ld a, [wSkillId]
	cp $7d
	jr z, .c4

	ld a, $c7
	ld [wTextIndex], a
	ret


.air
;> def AirDodged():
;>     if IsTargetOnOwnSide2_53(): return
	call IsTargetOnOwnSide2_53
	ret c

;>     wTextIndex = 0xB8
	ld a, $b8
	ld [wTextIndex], a
	ret


.missed
;> def Missed():
;>     if not IsTargetOnOwnSide2_53(): return
	call IsTargetOnOwnSide2_53
	ret nc

;>     wTextIndex = 0xB7
	ld a, $b7
	ld [wTextIndex], a
	ret


.noEffect
;> def NoEffect():
;>     if not IsTargetOnOwnSide2_53(): return
	call IsTargetOnOwnSide2_53
	ret nc

;>     s = wSkillId
	ld a, [wSkillId]
;>@r     if s < 0x6B or s in (0x6E, 0x71) or s >= 0x75: return
	cp $6b
	ret c

	cp $6e
	ret z

;=@r
	cp $71
	ret z

	cp $75
	ret nc

;>@d     if s < 0x6E: wTextIndex = 0xC3
	cp $6e
	jr c, .c3

;>     elif s == 0x6F: wTextIndex = 0xC4
	cp $6f
	jr z, .c4

;>@z     elif s == 0x70: wTextIndex = 0xCA
	cp $70
	jr z, .ca

;>@y     elif s < 0x75: wTextIndex = s + 0x53
	cp $75
	jr c, .add

;>     return
	ret


.c3
;=@d
	ld a, $c3
	ld [wTextIndex], a
	ret


.c4
;=@w
	ld a, $c4
	ld [wTextIndex], a
	ret


.add
;=@y
	add $53
	ld [wTextIndex], a
	ret


.ca
;=@z
	ld a, $ca
	ld [wTextIndex], a
	ret


;@ path: unused
;@ Unreachable code kept as bytes: ld a, [wLinkFlags] / bit 1, a / ld a, [wSkillTarget] / ret z /
;@ ld a, [wSkillUser] / ret - the target's position, or the user's when wLinkFlags bit 1 is set.
UnusedLinkSidePos_53::
	db $fa, $63, $c8, $cb, $4f, $fa, $89, $db, $c8, $fa, $88, $db, $c9

;@ def IsTargetOnOwnSide2_53() -> carry
;@ path: battle/state
;@ Carry when the target belongs to the player of this Game Boy: positions 0-3, or 4-7 when wLinkFlags
;@ bit 1 is set (the sides are swapped in a link battle).
;@ test: wSkillTarget = rand(0, 7); wLinkFlags = rand(0, 3)
IsTargetOnOwnSide2_53::
;> if not (wLinkFlags & 0x02): return wSkillTarget < 4
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, .link

	ld a, [wSkillTarget]
	cp $04
	ret


.link
;> return wSkillTarget >= 4
	ld a, [wSkillTarget]
	cp $04
	ccf
	ret


;@ def IsWindReflecting_53()
;@ path: battle/skills
;@ Whether a wind around the target (TailWind, status byte 2 bit 6) turns the breath back on its user;
;@ not SuckAir and SuckAll. The answer is the zero flag: clear = it does (hl at status byte 2).
;@ test: skip the result is a zero flag that means "no"
IsWindReflecting_53::
;> if not (wSkillFlags1 & 0x10): return False      # not a breath
	ld a, [wSkillFlags1]
	bit 4, a
	ret z

;> if wSkillId in (0x43, 0x8F): return False
	ld a, [wSkillId]
	cp $43
	ret z

	cp $8f
	ret z

;> return wBattlerStatus[8 * wSkillTarget + 2] & 0x40 != 0
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 6, [hl]
	ret


;@ def CheckTakeMagic_53()
;@ path: battle/skills
;@ Whether the target glows with TakeMagic (status byte 2 bit 0) against a spell whose MP can be
;@ absorbed (bit 0 of wSkillFlags3): then the MP it gains (the spell's MP cost, at most up to its
;@ maximum) go to wAbsorbMP/wPanelMode and the zero flag is clear.
;@ test: skip calls routines in other banks
CheckTakeMagic_53::
;> if not (wBattlerStatus[8 * wSkillTarget + 2] & 0x01): return False
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	ret z

;> LoadSkillFlags()
	ld hl, far_LoadSkillFlags
	rst $10
;> if not (wSkillFlags3 & 0x01): return False
	ld a, [wSkillFlags3]
	bit 0, a
	ret z

;> wBattleArg0 = wSkillId; wBattleArg1 = 0
	ld a, [wSkillId]
	ld [wBattleArg0], a
	xor a
	ld [wBattleArg1], a
;> wBattleArg2 = 4; GetSkillWord()        # the MP cost
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
;> cost = wBattleArg0; gain = cost
	ld a, [wBattleArg0]
	ld c, a
	ld b, $00
	ld e, c
	ld d, b
;> mp = GetBattlerMP(wSkillTarget); maxmp = GetBattlerMaxMP(wSkillTarget)
	ld a, [wSkillTarget]
	call GetBattlerMP
	add hl, bc
	push hl
	ld a, [wSkillTarget]
	call GetBattlerMaxMP
;> if mp + cost > maxmp:
	pop bc
	call CompareHLBC
	jr nc, .store

;>@g     gain = max(maxmp - mp, 0)
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;=@g
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
;=@g
	jr nc, .positive

	ld de, $0000
	jr .store

.positive
;=@g
	ld b, h
	ld c, l

.store
;> wAbsorbMP = gain & 0xFF; wPanelMode = gain >> 8
	ld a, e
	ld [wAbsorbMP], a
	ld a, d
	ld [wPanelMode], a
;> return True
	ld a, $01
	or a
	ret


;@ def AbsorbMP_53()
;@ path: battle/skills
;@ Far entries 7 and 8: the glowing target sucks in the MP CheckTakeMagic_53 worked out - "...
;@ sucks in ... MP!" ($8D).
;@ test: skip calls routines in other banks
AbsorbMP_53::
;> CheckTakeMagic_53()
	call CheckTakeMagic_53
;> gain = wAbsorbMP | wPanelMode << 8
	ld a, [wAbsorbMP]
	ld c, a
	ld a, [wPanelMode]
	ld b, a
;>@mp mp = addr(wBattlerMP) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@mp
	adc h
	ld h, a
;> mem16[mp] += gain
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
;> Number16ToDecimal(gain, addr(wTextArg1))
	ld hl, wTextArg1
	call Number16ToDecimal
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg0))
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
;> wTextIndex = 0x8D; wTextGroup = 0
	ld a, $8d
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def ReadWordEntry_53(index: a, table: hl) -> hl
;@ path: battle/state
;@ Word `index` of `table` (16-bit entries).
;@ test: table = 0xC000; index = rand(0, 7)
ReadWordEntry_53::
;>@r return mem16[table + 2 * index]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ def SpreadDamage_53(amount: hl) -> hl
;@ path: battle/skills
;@ `amount` give or take up to 5 %: r = a random number 0-1023 reduced to at most amount / 10; an
;@ even r adds r / 2, an odd one takes it away (not below 0).
;@ test: amount = rand(0, 999); wRandomHigh = rand(0, 255); wRandomLow = rand(0, 255)
SpreadDamage_53::
;> tenth = amount // 10
	push hl
	ld a, $0a
	call Divide16
	pop de
;> if tenth == 0: return amount
	ld a, h
	or l
	jr nz, .spread

	ld h, d
	ld l, e
	jr .done

.spread
;>@r r = wRandomHigh | (wRandomLow & 3) << 8
	ld a, [wRandomHigh]
	ld c, a
	ld a, [wRandomLow]
	ld b, a
	ld a, b
	and $03
;=@r
	ld b, a

.mod
;>@m while r > tenth: r -= tenth
	call CompareHLBC
	jr nc, .apply

	ld a, c
	sub l
	ld c, a
	ld a, b
;=@m
	sbc h
	ld b, a
	jr .mod

.apply
;> half = r >> 1
	ld h, d
	ld l, e
	srl b
	rr c
;> if not (r & 1): return amount + half
	jr c, .minus

	add hl, bc
	jr .done

.minus
;>@mi if amount >= half: return amount - half
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;=@mi
	jr nc, .done

;> return amount
	ld h, d
	ld l, e

.done
	ret


;@ def BoostDamage_53(amount: hl) -> hl
;@ path: battle/skills
;@ A boosted amount: twice `amount` plus a random part below half of it (2 to 2.5 times).
;@ test: skip draws a random number first
BoostDamage_53::
;>@d DrawRandom_53()
	push af
	push bc
	push de
	push hl
	call DrawRandom_53
	pop hl
;=@d
	pop de
	pop bc
	pop af
;>@h half = max(amount >> 1, 1)
	ld b, h
	ld c, l
	srl b
	rr c
;=@h
	ld a, b
	or c
	jr nz, .rand

;=@h
	ld c, $01

.rand
;> r = wRandomHigh | wRandomLow << 8
	push hl
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a

.mod
;>@m while r >= half: r -= half
	call CompareHLBC
	jr c, .done

	ld a, l
	sub c
	ld l, a
	ld a, h
;=@m
	sbc b
	ld h, a
	jr .mod

.done
;>@r return amount * 2 + r
	ld b, h
	ld c, l
	pop hl
	sla l
	rl h
	add hl, bc
;=@r
	ret


;@ def SaveReaction_53(kind: a)
;@ path: battle/reactions
;@ Starts a reaction of kind `kind` (wReactionKind): the state of the action it interrupts is kept in
;@ wPartyBarTiles (user, target, hit count, both actions, the target's command state), the target
;@ takes over the user's action and its command state becomes 2 (to act).
;@ test: wSkillUser = rand(0, 7); wSkillTarget = rand(0, 7)
SaveReaction_53::
;> wReactionKind = kind
	ld [wReactionKind], a
;> p = addr(wPartyBarTiles)
	ld hl, wPartyBarTiles
;> wPartyBarTiles[0] = wSkillUser; wPartyBarTiles[1] = wSkillTarget
	ld a, [wSkillUser]
	ld [hli], a
	ld a, [wSkillTarget]
	ld [hli], a
;> wPartyBarTiles[2] = wHitCount
	ld a, [wHitCount]
	ld [hli], a
;>@u ua = addr(wBattlerAction) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld de, wBattlerAction
	add a
	add e
	ld e, a
	ld a, $00
;=@u
	adc d
	ld d, a
;> wPartyBarTiles[3] = mem[ua]; wPartyBarTiles[4] = mem[ua + 1]
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
;>@t ta = addr(wBattlerAction) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld bc, wBattlerAction
	add a
	add c
	ld c, a
	ld a, $00
;=@t
	adc b
	ld b, a
;> wPartyBarTiles[5] = mem[ta]; wPartyBarTiles[6] = mem[ta + 1]
	ld a, [bc]
	ld [hli], a
	inc bc
	ld a, [bc]
	ld [hli], a
;> mem[ta + 1] = mem[ua + 1]; mem[ta] = mem[ua]
	ld a, [de]
	ld [bc], a
	dec bc
	dec de
	ld a, [de]
	ld [bc], a
;>@o wPartyBarTiles[7] = wBattlerOrder[wSkillTarget]
	ld a, [wSkillTarget]
	ld de, wBattlerOrder
	add e
	ld e, a
	ld a, $00
	adc d
;=@o
	ld d, a
	ld a, [de]
	ld [hl], a
;> wBattlerOrder[wSkillTarget] = 2
	ld a, $02
	ld [de], a
	ret


;@ def StartReactionFar_53()
;@ path: battle/reactions
;@ Far entry 9: StartReaction_53 with the kind in wBattleArg0 (bank $52 starts counterattacks).
;@ test: skip calls routines in other banks
StartReactionFar_53::
;> return StartReaction_53(wBattleArg0)
	ld a, [wBattleArg0]

;@ def StartReaction_53(kind: a)
;@ path: battle/reactions
;@ The target answers the action (SaveReaction_53) and becomes the skill user. A single-target skill,
;@ a reflection (kind 4) or a SuckAll catch (kind 1) goes back at the old user; otherwise the battle
;@ AI picks the target. The answer starts at action step 1 (kind 8: step 0 stage 2).
;@ test: skip calls routines in other banks
StartReaction_53::
;> SaveReaction_53(kind)
	call SaveReaction_53
;> wSkillUser = wSkillTarget
	ld a, [wSkillTarget]
	ld [wSkillUser], a
;>@b if wSkillTargeting & 0x01 or wReactionKind in (4, 1):
	ld a, [wSkillTargeting]
	bit 0, a
	jr nz, .back

	ld a, [wReactionKind]
	cp $04
	jr z, .back

;=@b
	cp $01
	jr nz, .pick

.back
;>@a     ta = addr(wBattlerAction) + 2 * wSkillUser + 1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
;>     wSkillTarget = wPartyBarTiles[0]; mem[ta] = wSkillTarget
	ld a, [wPartyBarTiles]
	ld [wSkillTarget], a
	ld [hl], a
	jr .start

.pick
;> else:
;>     RunTargetPicker()
	ld hl, far_RunTargetPicker
	rst $10
;>@c     wSkillTarget = wBattlerAction[2 * wSkillUser + 1]
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@c
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a

.start
;> wHitCount = 0; wBattleSubStep = 0
	xor a
	ld [wHitCount], a
	ld a, $00
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 2
	ld a, $02
	ld [wBattleSubStep2], a
;> if wReactionKind == 8: return
	ld a, [wReactionKind]
	cp $08
	ret z

;> if wReactionKind == 1: ClearSuckAll_53()
	cp $01
	call z, ClearSuckAll_53
;> wBattleSubStep = 1; wBattleSubStep2 = 0
	ld a, $01
	ld hl, wBattleSubStep
	ld [hli], a
	xor a
	ld [hl], a
	ret


;@ def ClearSuckAll_53()
;@ path: battle/reactions
;@ After a SuckAll catch: clears the side's SuckAll user (wSuckAllUsers bits 0-1) and the wind of
;@ the side's first position.
;@ test: wSkillUser = rand(0, 7)
ClearSuckAll_53::
;>@s su = addr(wSuckAllUsers) + (wSkillUser >> 2 & 1)
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld hl, wSuckAllUsers
	add l
;=@s
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> if not (mem[su] & 0x03): return
	ld a, [hl]
	and $03
	ret z

;> mem[su] &= 0xFC
	ld a, [hl]
	and $fc
	ld [hl], a
;> pos = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $01

.loop
;>@w wBattlerStatus[8 * pos + 2] &= ~0x40
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	res 6, [hl]
;=@w
	inc c
	dec b
	jr nz, .loop

	ret


;@ def StartReactionKeepTarget_53(kind: b, target: c)
;@ path: battle/reactions
;@ SaveReaction_53 with kind `kind`, then `target` becomes the target.
;@ test: kind = 2; target = rand(0, 7); wSkillUser = rand(0, 7); wSkillTarget = rand(0, 7)
StartReactionKeepTarget_53::
;> SaveReaction_53(kind)
	push bc
	ld a, b
	call SaveReaction_53
	pop bc
;> wSkillTarget = target
	ld a, c
	ld [wSkillTarget], a
	ret


;@ def CheckCriticalHit_53() -> carry
;@ path: battle/skills
;@ Carry when the user's attack is a critical hit: wRandomHigh below its species' chance
;@ (CritChanceWild_53 for a wild or scripted enemy, else CritChanceOwn_53; values 0-2, else 4).
;@ test: wSkillUser = rand(0, 7); wLinkActive = rand(0, 1); wRandomHigh = rand(0, 7)
CheckCriticalHit_53::
;>@t table = CritChanceWild_53 if not wLinkActive and wSkillUser >= 4 else CritChanceOwn_53
	ld a, [wLinkActive]
	or a
	jr nz, .own

	ld a, [wSkillUser]
	cp $04
	jr c, .own

;=@t
	ld de, CritChanceWild_53
	jr .read

.own
;=@t
	ld de, CritChanceOwn_53

.read
;>@c chance = mem[table + wBattlerSpecies[wSkillUser]]
	ld a, [wSkillUser]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	ld a, [hl]
	add e
	ld e, a
	ld a, $00
	adc d
;=@c
	ld d, a
	ld a, [de]
;>@x if chance not in (0, 1, 2): chance = 4
	or a
	jr z, .compare

	cp $01
	jr z, .compare

	cp $02
	jr z, .compare

;=@x
	ld a, $04

.compare
;> return wRandomHigh < chance
	ld b, a
	ld a, [wRandomHigh]
	cp b
	ret


;@ def RunHitWakeStages_53()
;@ path: battle/skills
;@ Far entry 17, after a hit (action step 5): a TakeMagic glow absorbs MP, and a sleeping or confused
;@ target may come to its senses from the blow.
;@ test: skip jump table
RunHitWakeStages_53::
;> HitWakeStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages of RunHitWakeStages_53.
HitWakeStages_53::
	dw HitWake_Begin_53
	dw HitWake_Sleep_53
	dw HitWake_Confusion_53
	dw HitWake_Done_53

;@ def HitWake_Begin_53()
;@ path: battle/skills
;@ Stage 0: absorbs MP if a TakeMagic gain is pending (AbsorbAfterHit_53). A target that is asleep or
;@ confused and hit by a skill with bit 3 of wSkillFlags3 comes round with a chance of $40/256 (a
;@ wild or scripted enemy) or $AA/256 (stages 1-2); otherwise the stages end.
;@ test: skip calls routines in other banks
HitWake_Begin_53::
;> if wAbsorbMP or wPanelMode: AbsorbAfterHit_53()
	ld hl, wAbsorbMP
	ld a, [hli]
	or [hl]
	call nz, AbsorbAfterHit_53
;>@s if wBattlerStatus[8 * wSkillTarget] & 0x90 and wSkillFlags3 & 0x08:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $90
	jr z, .done

;=@s
	ld a, [wSkillFlags3]
	bit 3, a
	jr z, .done

;>     DrawRandom_53()
	call DrawRandom_53
;>@c     chance = 0x40 if not wLinkActive and wSkillTarget >= 4 else 0xAA
	ld a, [wLinkActive]
	or a
	jr nz, .own

	ld a, [wSkillTarget]
	cp $04
	jr c, .own

;=@c
	ld b, $40
	jr .roll

.own
;=@c
	ld b, $aa

.roll
;>     if wRandomHigh < chance:
	ld a, [wRandomHigh]
	cp b
	jr nc, .done

;>         wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>         if not (wAbsorbMP or wPanelMode): return HitWake_Sleep_53()
	ld hl, wAbsorbMP
	ld a, [hli]
	or [hl]
	jr z, HitWake_Sleep_53

;>         return
	ret


.done
;> wBattleSubStep2 = 3; return HitWake_Done_53()
	ld a, $03
	ld [wBattleSubStep2], a
	jp HitWake_Done_53


;@ def HitWake_Sleep_53()
;@ path: battle/skills
;@ Stage 1: a sleeping target wakes up ("... wakes up!" $DB; its confusion goes too) and loses its turn.
;@ test: skip calls routines in other banks
HitWake_Sleep_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> status = addr(wBattlerStatus) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not (mem[status] & 0x80): return
	bit 7, [hl]
	ret z

;> mem[status] &= 0x63
	ld a, [hl]
	and $63
	ld [hl], a
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg0))
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
;> wTextIndex = 0xDB; wTextGroup = 0
	ld a, $db
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> return TargetLosesTurn_53()

;@ def TargetLosesTurn_53()
;@ path: battle/skills
;@ The target loses its turn (command state 3).
;@ test: wSkillTarget = rand(0, 7)
TargetLosesTurn_53::
;>@o wBattlerOrder[wSkillTarget] = 3
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $03
	ret


;@ def HitWake_Confusion_53()
;@ path: battle/skills
;@ Stage 2: a confused target "returns to normal" ($DC) and loses its turn.
;@ test: skip calls routines in other banks
HitWake_Confusion_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> status = addr(wBattlerStatus) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not (mem[status] & 0x10): return HitWake_Done_53()
	bit 4, [hl]
	jr z, HitWake_Done_53

;> mem[status] &= 0x63
	ld a, [hl]
	and $63
	ld [hl], a
;> wBattleArg2 = addr(wTextArg0) & 0xFF; wBattleArg3 = addr(wTextArg0) >> 8
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg0))
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
;> wTextIndex = 0xDC; wTextGroup = 0
	ld a, $dc
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> TargetLosesTurn_53()
	call TargetLosesTurn_53
	ret


;@ def HitWake_Done_53()
;@ path: battle/skills
;@ Stage 3: on to action step 6.
;@ test: wBattleSubStep2 = 3
HitWake_Done_53::
;> wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def AbsorbAfterHit_53()
;@ path: battle/skills
;@ The target, still present and glowing with TakeMagic, absorbs the MP of the spell (AbsorbMP_53) -
;@ not during a reaction or after the hit was intercepted.
;@ test: skip calls routines in other banks
AbsorbAfterHit_53::
;> if wReactionKind: return
	ld a, [wReactionKind]
	or a
	ret nz

;> if wInterceptState: return
	ld a, [wInterceptState]
	or a
	ret nz

;> if CheckBattlerPresent(wSkillTarget): return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> if not (wBattlerStatus[8 * wSkillTarget + 2] & 0x01): return
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	ret z

;> AbsorbMP_53()
	ld hl, far_AbsorbMP_53
	rst $10
	ret


;@ def CureAilments_53()
;@ path: battle/skills
;@ Far entry 10: cures the target - all of status byte 0 (sleep, paralysis, confusion, curse, poison),
;@ byte 1 except bits 2-5, byte 3 bit 7, byte 5 bits 0-1 (blind); a sleeping or confused target loses
;@ its turn. A lowered stat (byte 6 bit 7) comes back: agility and defense return to their normal
;@ values (Call_57_42A6, Call_57_424A) where they are below.
;@ test: skip calls routines in other banks
CureAilments_53::
;> status = addr(wBattlerStatus) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if mem[status] & 0x90: TargetLosesTurn2_53()
	ld a, [hl]
	and $90
	call nz, TargetLosesTurn2_53
;> mem[status] = 0; mem[status + 1] &= 0x3C
	xor a
	ld [hli], a
	ld a, [hl]
	and $3c
	ld [hli], a
;> mem[status + 3] &= ~0x80
	inc hl
	res 7, [hl]
;> mem[status + 5] &= 0xFC
	inc hl
	inc hl
	ld a, [hl]
	and $fc
	ld [hl], a
;> if not (mem[status + 6] & 0x80): return
	inc hl
	bit 7, [hl]
	ret z

;> mem[status + 6] &= ~0x80
	res 7, [hl]
;> wBattleTemp = wSkillTarget; Call_57_42A6()         # normal agility -> wBattleTemp
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_42A6
	rst $10
;>@a agi = addr(wBattlerAgility) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
;>@b if mem16[agi] < (wBattleTemp | wBattleTempHigh << 8):
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wBattleTemp]
	ld c, a
;=@b
	ld a, [wBattleTempHigh]
	ld b, a
	call CompareHLBC
	pop hl
	jr nc, .defense

;>     mem16[agi] = wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld [hli], a
	ld a, [wBattleTempHigh]
	ld [hl], a

.defense
;> wBattleTemp = wSkillTarget; Call_57_424A()         # normal defense
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_424A
	rst $10
;>@d df = addr(wBattlerDefense) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;=@d
	adc h
	ld h, a
;>@e if mem16[df] < (wBattleTemp | wBattleTempHigh << 8):
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wBattleTemp]
	ld c, a
;=@e
	ld a, [wBattleTempHigh]
	ld b, a
	call CompareHLBC
	pop hl
	ret nc

;>     mem16[df] = wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld [hli], a
	ld a, [wBattleTempHigh]
	ld [hl], a
	ret


;@ def TargetLosesTurn2_53()
;@ path: battle/skills
;@ TargetLosesTurn_53 that keeps hl.
;@ test: wSkillTarget = rand(0, 7)
TargetLosesTurn2_53::
;>@o wBattlerOrder[wSkillTarget] = 3
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
;=@o
	adc h
	ld h, a
	ld [hl], $03
	pop hl
	ret


;@ def RunDispelStages_53()
;@ path: battle/skills
;@ Far entry 11: cancels the effects on every monster of the target's side, one stage
;@ (wBattleSubStep2) per call - DeMagic, and ThickFog / FILTHZONE (which also fog both sides).
;@ test: skip jump table
RunDispelStages_53::
;> DispelStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages of RunDispelStages_53 (0-4 for each of the three positions, then 6-8 once per side).
DispelStages_53::
	dw Dispel_Begin_53
	dw Dispel_Effects_53
	dw Dispel_Wind_53
	dw Dispel_Transform_53
	dw Dispel_Picture_53
	dw Dispel_NextTarget_53
	dw Dispel_Helper_53
	dw Dispel_Side_53
	dw Dispel_Done_53

;@ def Dispel_Begin_53()
;@ path: battle/skills
;@ Stage 0: a missing target is skipped (on to the next position).
;@ test: skip goes on into other stages
Dispel_Begin_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if not CheckBattlerPresent(wSkillTarget): return Dispel_Effects_53()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, Dispel_Effects_53

;> wBattleSubStep2 = 5; return Dispel_NextTarget_53()
	ld a, $05
	ld [wBattleSubStep2], a
	jp Dispel_NextTarget_53


;@ def Dispel_Effects_53()
;@ path: battle/skills
;@ Stage 1: clears the target's skill effects - status byte 1 but bits 4-5, byte 2 but bits 3, 6, 7,
;@ byte 3 bits 6-7, byte 5 bits 2-3 and 6-7 (an iron lump also loses its turn), byte 6 bits 0 and
;@ 2-5 kept, byte 7 bit 2 - and shows "The spell on ... is broken" ($AC).
;@ test: skip calls routines in other banks
Dispel_Effects_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> status = addr(wBattlerStatus) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> mem[status + 1] &= 0x30
	inc hl
	ld a, [hl]
	and $30
	ld [hli], a
;> mem[status + 2] &= 0xC8
	ld a, [hl]
	and $c8
	ld [hli], a
;> mem[status + 3] &= 0x3F
	ld a, [hl]
	and $3f
	ld [hli], a
;> s5 = mem[status + 5]
	inc hl
	ld a, [hl]
	ld b, a
;> if s5 & 0xC0:                                 # an iron lump loses its turn
	and $c0
	ld a, b
	jr z, .notIron

;>@o     wBattlerOrder[wSkillTarget] = 3
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
;=@o
	adc h
	ld h, a
	ld [hl], $03
	pop hl

.notIron
;> mem[status + 5] = s5 & 0x33; mem[status + 6] &= 0x3D
	and $33
	ld [hli], a
	ld a, [hl]
	and $3d
	ld [hli], a
;> mem[status + 7] &= ~0x04
	res 2, [hl]
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg0))
	ld a, [wSkillTarget]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_53
;> wTextIndex = 0xAC; wTextGroup = 0
	ld a, $ac
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def Dispel_Wind_53()
;@ path: battle/skills
;@ Stage 2: what is left of status byte 2 (the winds) goes: "The wind is stopped" ($D9).
;@ test: skip calls routines in other banks
Dispel_Wind_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> s2 = addr(wBattlerStatus2) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
;> if not mem[s2]: return
	ld a, [hl]
	or a
	ret z

;> mem[s2] = 0; wTextIndex = 0xD9
	ld [hl], $00
	ld a, $d9
	ld [wTextIndex], a
;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def Dispel_Transform_53()
;@ path: battle/skills
;@ Stage 3: a target with status byte 1 still set gets its own stats back (ReloadBattlerStats_53):
;@ "... returns to its true form" ($AD), then stage 4; otherwise only defense and agility are
;@ restored and stage 4 is skipped.
;@ test: skip calls routines in other banks
Dispel_Transform_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> s1 = addr(wBattlerStatus1) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
;> if not mem[s1]:
	ld a, [hl]
	or a
	jr nz, .transformed

;>     RestoreDefAgility_53(); wBattleSubStep2 += 1
	call RestoreDefAgility_53
	ld hl, wBattleSubStep2
	inc [hl]
;>     return
	ret


.transformed
;> mem[s1] = 0; ReloadBattlerStats_53()
	ld [hl], $00
	call ReloadBattlerStats_53
;> wTextIndex = 0xAD; wTextGroup = 0
	ld a, $ad
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def Dispel_Picture_53()
;@ path: battle/skills
;@ Stage 4: the target's own picture comes back, its menu memory is reset, it loses its turn and it is
;@ no longer a copy of a party monster (wEnemyMorph).
;@ test: skip calls routines in other banks
Dispel_Picture_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@s ReloadBattlerPicture_53(wSkillTarget, wBattlerSpecies[wSkillTarget])
	ld a, [wSkillTarget]
	ld b, a
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
;=@s
	adc h
	ld h, a
	ld c, [hl]
	call ReloadBattlerPicture_53
;>@m wBattlerMenuMemory[wSkillTarget] &= 0x80
	ld a, [wSkillTarget]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	and $80
	ld [hl], a
;>@o wBattlerOrder[wSkillTarget] = 3
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $03
;>@e wEnemyMorph[wSkillTarget & 3] = 0xFF
	ld a, [wSkillTarget]
	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
	ld a, $00
;=@e
	adc h
	ld h, a
	ld [hl], $ff
	ret


;@ def Dispel_NextTarget_53()
;@ path: battle/skills
;@ Stage 5: the next of the side's three positions (stage 0 again); after the third, the helper
;@ position 3 of the side (stage 6).
;@ test: wSkillTarget = rand(0, 7); wBattleSubStep2 = 5
Dispel_NextTarget_53::
;> if wSkillTarget & 3 != 2:
	ld a, [wSkillTarget]
	and $03
	cp $02
	jr z, .helper

;>     wSkillTarget += 1; wBattleSubStep2 = 0
	ld hl, wSkillTarget
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
;>     return
	ret


.helper
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> wSkillTarget = wSkillTarget & 4 | 3
	ld a, [wSkillTarget]
	and $04
	or $03
	ld [wSkillTarget], a
	ret


;@ def Dispel_Helper_53()
;@ path: battle/skills
;@ Stage 6: a called-in helper of the side leaves: "... disappears!" ($D8).
;@ test: skip calls routines in other banks
Dispel_Helper_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget): return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> RemoveBattler_53()
	call RemoveBattler_53
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg0))
	ld a, [wSkillTarget]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_53
;> wTextIndex = 0xD8; wTextGroup = 0
	ld a, $d8
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def Dispel_Side_53()
;@ path: battle/skills
;@ Stage 7: the fog of both sides (wSideFlags bit 3) and the target side's flags but bit 4 are
;@ cleared. ThickFog ($83) and FILTHZONE ($A5) then fog both sides; if the target side was not the
;@ user's, the user's side is dispelled too (stage 0 again).
;@ test: skip goes on into other stages
Dispel_Side_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> wSideFlags[0] &= ~0x08; wSideFlags[1] &= ~0x08
	ld hl, wSideFlags
	res 3, [hl]
	inc hl
	res 3, [hl]
;>@s side = 1 if wSkillTarget >= 4 else 0
	ld a, [wSkillTarget]
	cp $04
	jr c, .own

	ld hl, wSideFlags + 1
	jr .side

.own
;=@s
	ld hl, wSideFlags

.side
;> wSideFlags[side] &= 0x10
	ld a, [hl]
	and $10
	ld [hl], a
;> if wSkillId not in (0x83, 0xA5): return
	ld a, [wSkillId]
	cp $83
	jr z, .fog

	cp $a5
	ret nz

.fog
;> wSideFlags[0] |= 0x08; wSideFlags[1] |= 0x08
	ld hl, wSideFlags
	set 3, [hl]
	inc hl
	set 3, [hl]
;> u = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld b, a
;> if wSkillTarget & 4 == u: return
	ld a, [wSkillTarget]
	and $04
	cp b
	ret z

;> wSkillTarget = wSkillUser & 4; wBattleSubStep2 = 0
	ld a, b
	ld [wSkillTarget], a
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def Dispel_Done_53()
;@ path: battle/skills
;@ Stage 8: the action goes on three action steps later.
;@ test: wBattleSubStep = 4
Dispel_Done_53::
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


;@ def ReloadBattlerStats_53()
;@ path: battle/state
;@ Gives the target its own skills (LoadBattlerSkills) and stats back - from its monster record, or
;@ for a wild or scripted enemy from its template - and cuts HP and MP down to the maximum.
;@ test: skip calls routines in other banks
ReloadBattlerStats_53::
;> wBattleArg0 = wSkillTarget; LoadBattlerSkills()
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld hl, far_LoadBattlerSkills
	rst $10
;> if not wLinkActive and wSkillTarget >= 4:
	ld a, [wLinkActive]
	or a
	jr nz, .record

	ld a, [wSkillTarget]
	cp $04
	jr c, .record

;>     LoadStatsFromTemplate_53()
	call LoadStatsFromTemplate_53
	jr .clamp

.record
;> else: LoadStatsFromRecord_53()
	call LoadStatsFromRecord_53

.clamp
;> hp = ReadBattlerWord_53(wSkillTarget, addr(wBattlerHP))
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call ReadBattlerWord_53
	push hl
;> if ReadBattlerWord_53(wSkillTarget, addr(wBattlerMaxHP)) < hp:
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	call ReadBattlerWord_53
	pop bc
	call CompareHLBC
	jr nc, .mp

;>     RefillFromMax_53(wSkillTarget, addr(wBattlerHP))
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call RefillFromMax_53

.mp
;> mp = ReadBattlerWord_53(wSkillTarget, addr(wBattlerMP))
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call ReadBattlerWord_53
	push hl
;> if ReadBattlerWord_53(wSkillTarget, addr(wBattlerMaxMP)) < mp:
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxMP
	call ReadBattlerWord_53
	pop bc
	call CompareHLBC
	jr nc, .done

;>     RefillFromMax_53(wSkillTarget, addr(wBattlerMP))
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call RefillFromMax_53

.done
	ret


;@ def ReadBattlerWord_53(pos: a, table: hl) -> hl
;@ path: battle/state
;@ Entry `pos` of a table of 16-bit battler values.
;@ test: table = 0xDBA3; pos = rand(0, 7)
ReadBattlerWord_53::
;>@r return mem16[table + 2 * pos]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ def RefillFromMax_53(pos: a, table: hl)
;@ path: battle/state
;@ Sets entry `pos` of wBattlerHP or wBattlerMP (`table`) to its maximum ($10 bytes further).
;@ test: table = 0xDBA3; pos = rand(0, 7)
RefillFromMax_53::
;>@a entry = table + 2 * pos
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@a
	ld b, h
	ld c, l
;>@c mem16[entry] = mem16[entry + 0x10]
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@c
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a
	ret


;@ def LoadStatsFromRecord_53()
;@ path: battle/state
;@ Copies the target's maximum HP and MP, attack, defense, agility, intelligence, level and its
;@ personality bytes from its monster record into the battle tables (a helper in the fourth
;@ position uses its template). The byte values are stored with StoreBattlerByte_53, which steps 2
;@ bytes per position - for positions above 0 they land in the wrong entry.
;@ test: skip calls routines of the home bank
LoadStatsFromRecord_53::
;> if wSkillTarget & 3 == 3: return LoadStatsFromTemplate_53(wSkillTarget)
	ld a, [wSkillTarget]
	and $03
	cp $03
	jp z, LoadStatsFromTemplate_53

;> for field, table in ((addr(wMonMaxHP), addr(wBattlerMaxHP)), (addr(wMonMaxMP), addr(wBattlerMaxMP)), (addr(wMonAttack), addr(wBattlerAttack)), (addr(wMonDefense), addr(wBattlerDefense)), (addr(wMonAgility), addr(wBattlerAgility)), (addr(wMonIntelligence), addr(wBattlerIntelligence))):
;>@w     StoreBattlerWord_53(wSkillTarget, table, GetPartyMonsterWord(wSkillTarget, field))
;=@w
	ld a, [wSkillTarget]
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	call StoreBattlerWord_53
;=@w
	ld a, [wSkillTarget]
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxMP
	call StoreBattlerWord_53
;=@w
	ld a, [wSkillTarget]
	ld hl, wMonAttack
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerAttack
	call StoreBattlerWord_53
;=@w
	ld a, [wSkillTarget]
	ld hl, wMonDefense
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call StoreBattlerWord_53
;=@w
	ld a, [wSkillTarget]
	ld hl, wMonAgility
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call StoreBattlerWord_53
;=@w
	ld a, [wSkillTarget]
	ld hl, wMonIntelligence
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerIntelligence
	call StoreBattlerWord_53
;> for field, table in ((addr(wMonLevel), addr(wBattlerLevel)), (addr(wMonStat64), addr(wBattlerPersonality1)), (addr(wMonStat65), addr(wBattlerPersonality2)), (addr(wMonStat67), addr(wBattlerStat67)), (addr(wMonStat66), addr(wBattlerPersonality3))):
;>@b     StoreBattlerByte_53(wSkillTarget, table, GetPartyMonsterByte(wSkillTarget, field))
;=@b
	ld a, [wSkillTarget]
	ld hl, wMonLevel
	call GetPartyMonsterByte
	ld b, a
;=@b
	ld a, [wSkillTarget]
	ld hl, wBattlerLevel
	call StoreBattlerByte_53
;=@b
	ld a, [wSkillTarget]
	ld hl, wMonStat64
	call GetPartyMonsterByte
	ld b, a
;=@b
	ld a, [wSkillTarget]
	ld hl, wBattlerPersonality1
	call StoreBattlerByte_53
;=@b
	ld a, [wSkillTarget]
	ld hl, wMonStat65
	call GetPartyMonsterByte
	ld b, a
;=@b
	ld a, [wSkillTarget]
	ld hl, wBattlerPersonality2
	call StoreBattlerByte_53
;=@b
	ld a, [wSkillTarget]
	ld hl, wMonStat67
	call GetPartyMonsterByte
	ld b, a
;=@b
	ld a, [wSkillTarget]
	ld hl, wBattlerStat67
	call StoreBattlerByte_53
;=@b
	ld a, [wSkillTarget]
	ld hl, wMonStat66
	call GetPartyMonsterByte
	ld b, a
;=@b
	ld a, [wSkillTarget]
	ld hl, wBattlerPersonality3
	call StoreBattlerByte_53
	ret


;@ def LoadStatsFromTemplate_53(pos: a)
;@ path: battle/state
;@ Copies level, maximum HP and MP, attack, defense, agility, intelligence and the personality bytes
;@ of enemy position `pos` (4-7) from its monster template (LoadMonTemplate2) into the battle tables.
;@ test: skip calls a routine in another bank
LoadStatsFromTemplate_53::
;>@t wNewMonId = ReadWordEntry_53(pos - 4, addr(wEncSpecies))
	sub $04
	ld hl, wEncSpecies
	call ReadWordEntry_53
	ld a, l
	ld [wNewMonId], a
	ld a, h
;=@t
	ld [wNewMonId + 1], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> src = addr(wTemplateLevel)
	ld hl, wTemplateLevel
;>@l wBattlerLevel[wSkillTarget] = mem[src]; src += 1
	ld a, [wSkillTarget]
	ld de, wBattlerLevel
	add e
	ld e, a
	ld a, $00
	adc d
;=@l
	ld d, a
	ld a, [hli]
	ld [de], a
;> pos = wSkillTarget
	ld a, [wSkillTarget]
	ld b, a
;> for table in (addr(wBattlerMaxHP), addr(wBattlerMaxMP), addr(wBattlerAttack), addr(wBattlerDefense), addr(wBattlerAgility), addr(wBattlerIntelligence)):
;>@w     mem16[table + 2 * pos] = mem16[src]; src += 2
;=@w
	ld de, wBattlerMaxHP
	add a
	ld c, a
	add e
	ld e, a
	ld a, $00
;=@w
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
;=@w
	ld [de], a
;=@w
	ld a, c
	ld de, wBattlerMaxMP
	add e
	ld e, a
	ld a, $00
	adc d
;=@w
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;=@w
	ld a, c
	ld de, wBattlerAttack
	add e
	ld e, a
	ld a, $00
	adc d
;=@w
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;=@w
	ld a, c
	ld de, wBattlerDefense
	add e
	ld e, a
	ld a, $00
	adc d
;=@w
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;=@w
	ld a, c
	ld de, wBattlerAgility
	add e
	ld e, a
	ld a, $00
	adc d
;=@w
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;=@w
	ld a, c
	ld de, wBattlerIntelligence
	add e
	ld e, a
	ld a, $00
	adc d
;=@w
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
;> for table in (addr(wBattlerPersonality1), addr(wBattlerPersonality2), addr(wBattlerStat67), addr(wBattlerPersonality3)):
;>@p     mem[table + pos] = mem[src]; src += 1
;=@p
	ld a, b
	ld de, wBattlerPersonality1
	add e
	ld e, a
	ld a, $00
	adc d
;=@p
	ld d, a
	ld a, [hli]
	ld [de], a
;=@p
	ld a, b
	ld de, wBattlerPersonality2
	add e
	ld e, a
	ld a, $00
	adc d
;=@p
	ld d, a
	ld a, [hli]
	ld [de], a
;=@p
	ld a, b
	ld de, wBattlerStat67
	add e
	ld e, a
	ld a, $00
	adc d
;=@p
	ld d, a
	ld a, [hli]
	ld [de], a
;=@p
	ld a, b
	ld de, wBattlerPersonality3
	add e
	ld e, a
	ld a, $00
	adc d
;=@p
	ld d, a
	ld a, [hli]
	ld [de], a
	ret


;@ def RestoreDefAgility_53()
;@ path: battle/state
;@ Gives the target its normal defense and agility back, from its monster record or (a wild or
;@ scripted enemy) from its template; not for a helper in the fourth position.
;@ test: skip calls routines of the home bank
RestoreDefAgility_53::
;>@t if not wLinkActive and wSkillTarget >= 3: return RestoreDefAgilityTemplate_53()
	ld a, [wLinkActive]
	or a
	jr nz, .record

	ld a, [wSkillTarget]
	cp $03
	jr c, .record

;=@t
	call RestoreDefAgilityTemplate_53
	ret


.record
;> if wSkillTarget & 3 == 3: return
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret z

;> StoreBattlerWord_53(wSkillTarget, addr(wBattlerDefense), GetPartyMonsterWord(wSkillTarget, addr(wMonDefense)))
	ld a, [wSkillTarget]
	ld hl, wMonDefense
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call StoreBattlerWord_53
;>@a StoreBattlerWord_53(wSkillTarget, addr(wBattlerAgility), GetPartyMonsterWord(wSkillTarget, addr(wMonAgility)))
	ld a, [wSkillTarget]
	ld hl, wMonAgility
	call GetPartyMonsterWord
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call StoreBattlerWord_53
;=@a
	ret


;@ def RestoreDefAgilityTemplate_53()
;@ path: battle/state
;@ An enemy's normal defense and agility from its template; its stat-change marks (status byte 6
;@ bits 6-7) are cleared.
;@ test: skip calls a routine in another bank
RestoreDefAgilityTemplate_53::
;> if wSkillTarget & 3 == 3: return
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret z

;>@t wNewMonId = ReadWordEntry_53(wSkillTarget & 3, addr(wEncSpecies))
	ld hl, wEncSpecies
	call ReadWordEntry_53
	ld a, l
	ld [wNewMonId], a
	ld a, h
;=@t
	ld [wNewMonId + 1], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>@ag mem16[addr(wBattlerAgility) + 2 * wSkillTarget] = mem16[addr(wTemplateAgility)]
	ld hl, wTemplateAgility
	ld a, [wSkillTarget]
	add a
	ld de, wBattlerAgility
	add e
	ld e, a
;=@ag
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
;=@ag
	ld a, [hl]
	ld [de], a
;>@df mem16[addr(wBattlerDefense) + 2 * wSkillTarget] = mem16[addr(wTemplateDefense)]
	ld hl, wTemplateDefense
	ld a, [wSkillTarget]
	add a
	ld de, wBattlerDefense
	add e
	ld e, a
;=@df
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
;=@df
	ld a, [hl]
	ld [de], a
;>@s wBattlerStatus[8 * wSkillTarget + 6] &= 0x3F
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	ld a, [hl]
	and $3f
;=@s
	ld [hl], a
	ret


;@ def RemoveBattler_53()
;@ path: battle/state
;@ The target leaves the battle: position empty, no command, status bytes cleared.
;@ test: wSkillTarget = rand(0, 7)
RemoveBattler_53::
;>@s wBattlerState[wSkillTarget] = 0xFF
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld [hl], $ff
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
;>@c fill(addr(wBattlerStatus) + 8 * wSkillTarget, 0, 8)
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	xor a
	ld [hli], a
	ld [hli], a
;=@c
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;=@c
	ret


;@ def StoreBattlerWord_53(pos: a, table: hl, value: bc)
;@ path: battle/state
;@ Stores `value` as entry `pos` of a table of 16-bit battler values.
;@ test: table = 0xDBB3; pos = rand(0, 7)
StoreBattlerWord_53::
;>@r mem16[table + 2 * pos] = value
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


;@ def StoreBattlerByte_53(pos: a, table: hl, value: b)
;@ path: battle/state
;@ Stores `value` at table + 2 * `pos` (2 bytes per position, although the tables it is used on have
;@ one byte per position).
;@ test: table = 0xDB9B; pos = rand(0, 3)
StoreBattlerByte_53::
;>@r mem[table + 2 * pos] = value
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ld [hl], b
	ret


;@ def ReloadBattlerPicture_53(pos: b, species: c)
;@ path: battle/screen
;@ Draws the picture of `species` again for enemy position `pos` (4-6; seen from this Game Boy, so
;@ positions 0-2 for the link partner when wLinkFlags bit 1 is set): decompressed to $9000 +
;@ $240 per slot from the species' picture entry in the table at $2B9F, then the palettes.
;@ test: skip decompresses into VRAM
ReloadBattlerPicture_53::
;> StoreSpeciesCGB_53(pos, species)
	call StoreSpeciesCGB_53
;> if wLinkFlags & 0x02:
	ld a, [wLinkFlags]
	bit 1, a
	ld a, b
	jr z, .normal

;>     if pos >= 3: return
	cp $03
	jr nc, .done

;>     slot = pos
	jr .load

.normal
;> else:
;>@e     if pos < 4 or pos == 7: return
	cp $04
	jr c, .done

	cp $07
	jr z, .done

;>     slot = pos - 4
	sub $04

.load
;> dest = 0x9000 + slot * 0x240
	push bc
	ld bc, $0240
	call Multiply24
	ld bc, $9000
	add hl, bc
	pop bc
;>@s DecompressVRAM(mem16[0x2B9F + 2 * species], dest)
	push hl
	ld l, c
	ld h, $00
	add hl, hl
	ld a, l
	add $9f
;=@s
	ld l, a
	ld a, h
	adc $2b
	ld h, a
	ld e, [hl]
	inc hl
;=@s
	ld d, [hl]
	pop hl
	call DecompressVRAM
;> SetBattlePicPalettes(); UploadCGBPalettes()
	ld hl, far_SetBattlePicPalettes
	rst $10
	ld hl, far_UploadCGBPalettes
	rst $10

.done
	ret


;@ def StoreSpeciesCGB_53(pos: b, species: c)
;@ path: battle/screen
;@ On a Game Boy Color: notes `species` for position `pos` in WRAM bank 2 (at the address of
;@ wSideFlags + pos there), for the colour palettes.
;@ test: skip switches WRAM banks
StoreSpeciesCGB_53::
;> if not wOnCGB: return
	ld a, [wOnCGB]
	or a
	ret z

;>@s rSVBK = 2; mem[addr(wSideFlags) + pos] = species
	ld a, $02
	ldh [rSVBK], a
	ld a, b
	ld hl, wSideFlags
	add l
	ld l, a
;=@s
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
;> rSVBK = 0
	ld a, $00
	ldh [rSVBK], a
	ret


;@ def RunWeakenStages_53()
;@ path: battle/skills
;@ Far entry 12: weakens the target in stages (wBattleSubStep2) - defense and agility each drop by
;@ half their normal value, and it is caught in an illusion.
;@ test: skip jump table
RunWeakenStages_53::
;> WeakenStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages of RunWeakenStages_53.
WeakenStages_53::
	dw Weaken_Defense_53
	dw Weaken_Agility_53
	dw Weaken_Illusion_53
	dw Weaken_Mark_53
	dw Weaken_Done_53

;@ def Weaken_Defense_53()
;@ path: battle/skills
;@ Stage 0: the target's defense drops by half its normal value (Call_57_424A; at least 1, and never
;@ below 1): "... loses ... defense" ($86/$87), its stat-down mark (status byte 6 bit 7) is set.
;@ test: skip calls routines in other banks
Weaken_Defense_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> wBattleTemp = wSkillTarget; Call_57_424A()          # normal defense -> wBattleTemp
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_424A
	rst $10
;> drop = (wBattleTemp | wBattleTempHigh << 8) >> 1
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	srl b
	rr c
;> drop = AtLeastOne_53(drop)
	call AtLeastOne_53
;>@d df = addr(wBattlerDefense) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;=@d
	adc h
	ld h, a
;> drop = LimitDrop_53(df, drop); wSkillAmount = drop
	call LimitDrop_53
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount+1], a
;> SubtractClamped_53(df, drop)
	call SubtractClamped_53
;>@z if wSkillAmount == 0: return
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
;=@z
	ld a, h
	or l
	jr z, .none

;> SetDamageMessageArgs_53(); wTextIndex = 0x86
	call SetDamageMessageArgs_53
	ld a, $86
	ld [wTextIndex], a
;> ShowStatMessage_53(); QueueSound(0x72)
	call ShowStatMessage_53
	ld a, $72
	call QueueSound
;> wBattlerStatus[8 * wSkillTarget + 6] |= 0x80
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	ret


.none
	ret


;@ def Weaken_Agility_53()
;@ path: battle/skills
;@ Stage 1: the same for agility (Call_57_42A6): "... speed goes down by ..." ($95/$96).
;@ test: skip calls routines in other banks
Weaken_Agility_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> wBattleTemp = wSkillTarget; Call_57_42A6()          # normal agility -> wBattleTemp
	ld a, [wSkillTarget]
	ld [wBattleTemp], a
	ld hl, far_Call_57_42A6
	rst $10
;> drop = (wBattleTemp | wBattleTempHigh << 8) >> 1
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	srl b
	rr c
;> drop = AtLeastOne_53(drop)
	call AtLeastOne_53
;>@d ag = addr(wBattlerAgility) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;=@d
	adc h
	ld h, a
;> drop = LimitDrop_53(ag, drop); wSkillAmount = drop
	call LimitDrop_53
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount+1], a
;> SubtractClamped_53(ag, drop)
	call SubtractClamped_53
;>@z if wSkillAmount == 0: return
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount+1]
	ld h, a
;=@z
	ld a, h
	or l
	jr z, .none

;> SetDamageMessageArgs_53(); wTextIndex = 0x95
	call SetDamageMessageArgs_53
	ld a, $95
	ld [wTextIndex], a
;> ShowStatMessage_53(); QueueSound(0x72)
	call ShowStatMessage_53
	ld a, $72
	call QueueSound
;> wBattlerStatus[8 * wSkillTarget + 6] |= 0x80
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	ret


.none
	ret


;@ def Weaken_Illusion_53()
;@ path: battle/skills
;@ Stage 2: "An illusion engulfs ..." ($98): status byte 1 bit 1, unless already in one.
;@ test: skip calls routines in other banks
Weaken_Illusion_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> s1 = addr(wBattlerStatus1) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
;> if mem[s1] & 0x02: return
	bit 1, [hl]
	jr nz, .already

;> mem[s1] |= 0x02; GetTargetName_53()
	set 1, [hl]
	call GetTargetName_53
;> wTextIndex = 0x98; wTextGroup = 0
	ld a, $98
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C(); QueueSound(0x84)
	ld hl, far_StartText_4C
	rst $10
	ld a, $84
	call QueueSound
	ret


.already
	ret


;@ def Weaken_Mark_53()
;@ path: battle/skills
;@ Stage 3: a target still present gets its stat-down mark.
;@ test: skip calls a routine with flag results
Weaken_Mark_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget): return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> wBattlerStatus[8 * wSkillTarget + 6] |= 0x80
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	ret


;@ def Weaken_Done_53()
;@ path: battle/skills
;@ Stage 4: the action goes on three action steps later.
;@ test: wBattleSubStep = 4
Weaken_Done_53::
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


;@ def SubtractClamped_53(value: hl, n: bc)
;@ path: battle/skills
;@ The word at `value` minus `n`, not below 0.
;@ test: value = 0xC000; n = rand(0, 0xFFFF)
SubtractClamped_53::
;>@s mem16[value] = max(mem16[value] - n, 0)
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
;=@s
	ret nc

	xor a
	ld [hld], a
	ld [hl], a
	ret


;@ def AtLeastOne_53(n: bc) -> bc
;@ path: battle/skills
;@ `n`, but at least 1.
;@ test: n = rand(0, 3)
AtLeastOne_53::
;> return max(n, 1)
	ld a, b
	or c
	ret nz

	ld bc, $0001
	ret


;@ def LimitDrop_53(value: hl, n: bc) -> bc
;@ path: battle/skills
;@ `n`, but at most the word at `value` minus 1, so that a lowered stat stays at least 1.
;@ test: value = 0xC000; n = rand(0, 0x200)
LimitDrop_53::
;>@l if mem16[value] - n <= 0: n = mem16[value] - 1
	ld a, [hli]
	sub c
	ld e, a
	ld a, [hld]
	sbc b
	ld d, a
;=@l
	jr c, .limit

	or e
	jr z, .limit

	ret nc

.limit
;=@l
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	dec bc
;> return n
	ret


;@ def ShowStatMessage_53()
;@ path: battle/skills
;@ Starts message wTextIndex (group 0), the next one (own-side wording) for a target in positions 0-3.
;@ test: skip calls a routine in another bank
ShowStatMessage_53::
;> if wSkillTarget < 4: wTextIndex += 1
	ld a, [wSkillTarget]
	cp $04
	jr nc, .show

	ld hl, wTextIndex
	inc [hl]

.show
;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def RunDeathStages_53()
;@ path: battle/skills
;@ Far entry 13: Sacrifice, in stages (wBattleSubStep2) - each monster of the target side may be
;@ felled (stages 0-3 per position), then the user falls (stages 4-6).
;@ test: skip jump table
RunDeathStages_53::
;> DeathStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages of RunDeathStages_53.
DeathStages_53::
	dw Death_Begin_53
	dw Death_Roll_53
	dw Death_Apply_53
	dw Death_NextTarget_53
	dw UserDeath_Roll_53
	dw UserDeath_Apply_53
	dw UserDeath_Done_53

;@ def Death_Begin_53()
;@ path: battle/skills
;@ Stage 0: a missing target is skipped (stage 3), and so is an iron lump (status byte 5 bits 6-7)
;@ after message $BA ("... turns to iron and becomes invulnerable"). A target that a guardian covers
;@ (status byte 6 bit 4, the guardian in byte 7 bits 4-7) has the guardian take its place, if the
;@ guardian can act: "... protects ..." ($80), wInterceptState 4.
;@ test: skip calls routines in other banks
Death_Begin_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@g if CheckBattlerPresent(wSkillTarget): wBattleSubStep2 = 3; return   # carry: nobody there
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .skip

;> if wBattlerStatus5[8 * wSkillTarget] & 0xC0:     # an iron lump
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, .notIron

;>     GetTargetName_53(); wTextIndex = 0xBA
	call GetTargetName_53
	ld a, $ba
	ld [wTextIndex], a
;>     wTextGroup = 0; StartText_4C()
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;>     wBattleSubStep2 = 3; return

.skip
;=@g
	ld a, $03
	ld [wBattleSubStep2], a
	jr .done

.notIron
;> if wInterceptState: return
	ld a, [wInterceptState]
	or a
	jr nz, .done

;> if not wBattlerStatus6[8 * wSkillTarget] & 0x10: return
	inc hl
	bit 4, [hl]
	jr z, .done

;> guard = wBattlerStatus7[8 * wSkillTarget] >> 4
	inc hl
	ld a, [hl]
	swap a
	and $0f
	ld b, a
;> if CheckBattlerCanAct(guard): return
	call CheckBattlerCanAct
	jr c, .done

;> wNamePos = guard; GetBattlerName_53(guard, addr(wTextArg0))
	ld a, b
	ld hl, wTextArg0
	push bc
	ld [wNamePos], a
	call GetBattlerName_53
;> wShieldTarget = wSkillTarget
	ld a, [wSkillTarget]
	ld [wShieldTarget], a
;> wNamePos = wSkillTarget; GetBattlerName_53(wSkillTarget, addr(wTextArg1))
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetBattlerName_53
;> wSkillTarget = guard
	pop bc
	ld a, b
	ld [wSkillTarget], a
;>@a wBattlerAction[2 * wSkillUser + 1] = guard
	ld a, [wSkillUser]
	ld hl, wBattlerAction+1
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld [hl], b
;> wTextIndex = 0x80; wTextGroup = 0
	ld a, $80
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C(); wInterceptState = 4
	ld hl, far_StartText_4C
	rst $10
	ld a, $04
	ld [wInterceptState], a

.done
	ret


;@ def Death_Roll_53()
;@ path: battle/skills
;@ Stage 1: does Sacrifice fell the target? Not a boss immune to it (CheckBossImmunity_53), not a
;@ death resistance of 3 (resistance byte 3 bits 0-1), and a resistance of 2 fails a quarter of the
;@ time. If it works, half the time the target loses all its HP - "... falls to pieces" ($E9, own
;@ side "... collapses" $E3, sound $9C) - otherwise all but a hundredth (at least 1) of them:
;@ "... takes ... damage pts" ($82/$83, sound $6C). The amount goes to wSkillAmount.
;@ test: skip calls routines in other banks
Death_Roll_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBossImmunity_53() == 0: return Death_NoEffect_53()
	call CheckBossImmunity_53
	or a
	jp z, Death_NoEffect_53

;> DrawRandom_53()
	call DrawRandom_53
;>@r resist = wBattlerResist[7 * wSkillTarget + 3] & 3
	ld a, [wSkillTarget]
	ld hl, wBattlerResist+3
	ld b, a
	add a
	add b
	add a
;=@r
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ld a, [hl]
	and $03
;>@w if resist == 3 or (resist >= 2 and wRandomHigh >= 0xC0): return Death_NoEffect_53()
	cp $03
	jp z, Death_NoEffect_53

;=@w
	cp $02
	jr c, .works

;=@w
	ld a, [wRandomHigh]
	cp $c0
	jr nc, Death_NoEffect_53

.works
;> GetTargetName_53(); hp = GetBattlerHP(wSkillTarget)
	call GetTargetName_53
	ld a, [wSkillTarget]
	call GetBattlerHP
;> wSkillAmount = hp
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
;> if wRandomLow >= 0x7F:
	ld a, [wRandomLow]
	cp $7f
	jr c, .kill

;>     cut = max(hp // 100, 1)
	ld a, $64
	call Divide16
	ld a, h
	or l
	jr nz, .cut

	ld hl, $0001

.cut
;>@c     left = hp - cut
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount+1]
	ld b, a
	ld a, c
	sub l
;=@c
	ld c, a
	ld a, b
	sbc h
	ld b, a
;>     if left > 0:
	jr c, .kill

	or c
	jr z, .kill

;>         wBattleTempHigh = 0x6C; wSkillAmount = left
	ld a, $6c
	ld [wBattleTempHigh], a
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount+1], a
;>         AmountToTextArg1_53(); wTextIndex = 0x82
	call AmountToTextArg1_53
	ld a, $82
	ld [wTextIndex], a
;>         if IsTargetOnOwnSide_53(): wTextIndex += 1
	call IsTargetOnOwnSide_53
	jr nc, Death_ShowMessage_53

	ld hl, wTextIndex
	inc [hl]
;>         return Death_ShowMessage_53()
	jr Death_ShowMessage_53

.kill
;> wTextIndex = 0xE9; wBattleTempHigh = 0x9C
	ld a, $e9
	ld [wTextIndex], a
	ld a, $9c
	ld [wBattleTempHigh], a
;> if IsTargetOnOwnSide_53(): wTextIndex = 0xE3
	call IsTargetOnOwnSide_53
	jr nc, Death_ShowMessage_53

	ld a, $e3
	ld [wTextIndex], a
;> return Death_ShowMessage_53()                    # runs on into it

;@ def Death_ShowMessage_53()
;@ path: battle/skills
;@ Starts message wTextIndex (group 0) and plays sound wBattleTempHigh ($FF: none).
;@ test: skip calls a routine in another bank
Death_ShowMessage_53::
;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;> if wBattleTempHigh != 0xFF: QueueSound(wBattleTempHigh)
	ld a, [wBattleTempHigh]
	cp $ff
	ret z

	call QueueSound
	ret


;@ def Death_NoEffect_53()
;@ path: battle/skills
;@ Sacrifice misses the target: stage 2 is skipped, "Has no effect on ..." ($B8). The sound is
;@ whatever wBattleTempHigh still holds.
;@ test: skip calls routines in other banks
Death_NoEffect_53::
;> wBattleSubStep2 += 1; GetTargetName_53()
	ld hl, wBattleSubStep2
	inc [hl]
	call GetTargetName_53
;> wTextIndex = 0xB8; return Death_ShowMessage_53()
	ld a, $b8
	ld [wTextIndex], a
	jr Death_ShowMessage_53

;@ def Death_Apply_53()
;@ path: battle/skills
;@ Stage 2: the target loses wSkillAmount HP. At 0 it goes down (DefeatBattler); a felled enemy's
;@ picture is blanked, the action jumps to step 3 and (not in a link battle) it may ask to join.
;@ test: skip calls routines in other banks
Death_Apply_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;>@h hp = addr(wBattlerHP) + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@h
	adc h
	ld h, a
;>@s mem16[hp] -= wSkillAmount
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount+1]
	ld b, a
	ld a, [hl]
	sub c
;=@s
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hld], a
;> if mem16[hp]: return
	or [hl]
	ret nz

;> wBattleArg0 = wSkillTarget; wBattleStepArg1 = 0
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	xor a
	ld [wBattleStepArg1], a
;> DefeatBattler()
	ld hl, far_DefeatBattler
	rst $10
;>@o if IsTargetOnOwnSide_53(): UpdateStatusIcon_50(); return
	call IsTargetOnOwnSide_53
	jr c, .own

;> BlankEnemyPicture(); wBattleSubStep = 3
	ld hl, far_BlankEnemyPicture
	rst $10
	ld a, $03
	ld [wBattleSubStep], a
;> if not wLinkActive: wJoinCandidate = wSkillTarget
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wSkillTarget]
	ld [wJoinCandidate], a
	ret


.own
;=@o
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ret


;@ def Death_NextTarget_53()
;@ path: battle/skills
;@ Stage 3: a guardian that took the hit gives the place back to the original target. After a
;@ reaction the interrupted action is restored first; then on to the side's next position.
;@ test: skip calls routines in other banks
Death_NextTarget_53::
;> if wShieldTarget != 0xFF:
	ld a, [wShieldTarget]
	cp $ff
	jr z, .next

;>     UpdateStatusIcon_50(); wSkillTarget = wShieldTarget
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, [wShieldTarget]
	ld [wSkillTarget], a
;>@a     wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction+1
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [wSkillTarget]
	ld [hl], a
;>     wShieldTarget = 0xFF; wInterceptState = 0
	ld a, $ff
	ld [wShieldTarget], a
	xor a
	ld [wInterceptState], a

.next
;> if wReactionKind: return Death_AfterReaction_53()
	ld a, [wReactionKind]
	or a
	jr nz, Death_AfterReaction_53

;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> return NextTargetOfSide_53()                     # runs on into it

;@ def NextTargetOfSide_53()
;@ path: battle/skills
;@ The next of the target side's three positions (stage 0 again, and a reflection is checked); after
;@ the third nothing changes.
;@ test: skip calls a routine that starts messages
NextTargetOfSide_53::
;> if wSkillTarget & 3 == 2: return
	ld a, [wSkillTarget]
	and $03
	cp $02
	ret z

;> wSkillTarget += 1; CheckDeathReflected_53()
	ld hl, wSkillTarget
	inc [hl]
	call CheckDeathReflected_53
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def Death_AfterReaction_53()
;@ path: battle/skills
;@ Stage 3 after a reaction: puts the interrupted action back, then the next position.
;@ test: skip calls routines in other banks
Death_AfterReaction_53::
;> RestoreInterruptedAction(); NextTargetOfSide_53()
	ld hl, far_RestoreInterruptedAction
	rst $10
	call NextTargetOfSide_53
	ret


;@ path: unused
;@ Code no routine reaches (kept as bytes): wBattleSubStep += 1; wBattleSubStep2 = 0.
UnusedNextSubStep_53::
	db $21, $ed, $d9, $34, $af, $ea, $ee, $d9, $c9

;@ def CheckDeathReflected_53()
;@ path: battle/skills
;@ A reflectable skill (wSkillFlags2 bit 0) meets a target that reflects (status byte 2 bit 1 Bounce,
;@ or bit 5 MagicBack, which is used up): "A wall of light reflects the spell" ($7B, $7C for the
;@ other side) and the target answers with the skill (StartReaction_53 kind 4). Not during a
;@ reflection (wReactionKind bit 2).
;@ test: skip calls routines in other banks
CheckDeathReflected_53::
;> if not wSkillFlags2 & 0x01: return
	ld a, [wSkillFlags2]
	bit 0, a
	ret z

;> if wReactionKind & 0x04: return
	ld a, [wReactionKind]
	bit 2, a
	ret nz

;> s2 = addr(wBattlerStatus2) + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
;> if not mem[s2] & 0x22: return
	ld a, [hl]
	and $22
	ret z

;> wReflectAnim = 0
	ld a, $00
	ld [wReflectAnim], a
;> if not mem[s2] & 0x02:
	bit 1, [hl]
	jr nz, .bounce

;>     mem[s2] &= ~0x20; wReflectAnim = 7
	res 5, [hl]
	ld a, $07
	ld [wReflectAnim], a

.bounce
;>@s side = (wSkillUser if wLinkFlags & 0x02 else wSkillTarget) >> 2 & 1
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, .side

;=@s
	ld a, [wSkillUser]

.side
;=@s
	rrca
	rrca
	and $01
;> wTextIndex = 0x7B + side
	add $7b
	ld a, a
	ld [wTextIndex], a
;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;> StartReaction_53(4); wInterceptState = 2
	ld a, $04
	call StartReaction_53
	ld a, $02
	ld [wInterceptState], a
;> wBattleSubStep = 3; wBattleSubStep2 = 3
	ld a, $03
	ld [wBattleSubStep], a
	ld a, $03
	ld [wBattleSubStep2], a
	ret


;@ def UserDeath_Begin_53()
;@ path: battle/skills
;@ Stage 4 of RunReviveAllStages_53: the user becomes the target, then UserDeath_Roll_53.
;@ test: skip goes on into other stages
UserDeath_Begin_53::
;> wSkillTarget = wSkillUser
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> return UserDeath_Roll_53()                       # runs on into it

;@ def UserDeath_Roll_53()
;@ path: battle/skills
;@ The user pays for Sacrifice, Farewell or LifeDance (stage 4 of the death stages, 5 of the revive
;@ stages): half the time it loses all its HP (UserDeath_Faint_53), otherwise all but a hundredth of
;@ them (at least 1): "... receives a fatal blow" ($85). The amount goes to wSkillAmount; no sound.
;@ test: skip calls routines in other banks
UserDeath_Roll_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillUser): return        # carry: nobody there
	ld a, [wSkillUser]
	call CheckBattlerPresent
	ret c

;> DrawRandom_53(); GetUserName_53()
	call DrawRandom_53
	call GetUserName_53
;> hp = GetBattlerHP(wSkillUser)
	ld a, [wSkillUser]
	call GetBattlerHP
;> wSkillAmount = hp
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount+1], a
;> if wRandomHigh < 0x7F: return UserDeath_Faint_53()
	ld a, [wRandomHigh]
	cp $7f
	jr c, UserDeath_Faint_53

;> cut = max(hp // 100, 1)
	ld a, $64
	call Divide16
	ld a, h
	or l
	jr nz, .cut

	ld hl, $0001

.cut
;>@c left = hp - cut
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount+1]
	ld b, a
	ld a, c
	sub l
;=@c
	ld c, a
	ld a, b
	sbc h
	ld b, a
;> if left == 0: return UserDeath_Faint_53()
	or c
	jr z, UserDeath_Faint_53

;> wSkillAmount = left; AmountToTextArg1_53()
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount+1], a
	call AmountToTextArg1_53
;> wTextIndex = 0x85; wBattleTempHigh = 0xFF
	ld a, $85
	ld [wTextIndex], a
	ld a, $ff
	ld [wBattleTempHigh], a
;> return UserDeath_ShowMessage_53()
	jr UserDeath_ShowMessage_53

;@ def UserDeath_LifeDance_53()
;@ path: battle/skills
;@ The LifeDance user's message: "... is weak after the dance" ($E5), no sound.
;@ test: skip calls a routine in another bank
UserDeath_LifeDance_53::
;> wTextIndex = 0xE5; wBattleTempHigh = 0xFF
	ld a, $e5
	ld [wTextIndex], a
	ld a, $ff
	ld [wBattleTempHigh], a
;> return UserDeath_ShowMessage_53()
	jr UserDeath_ShowMessage_53

;@ def UserDeath_Faint_53()
;@ path: battle/skills
;@ The user loses all its HP (wSkillAmount): "... is out of HP and faints" ($E7, $EA on this Game
;@ Boy's side; LifeDance: UserDeath_LifeDance_53), no sound.
;@ test: skip calls a routine in another bank
UserDeath_Faint_53::
;> if wSkillId == 0x96: return UserDeath_LifeDance_53()
	ld a, [wSkillId]
	cp $96
	jr z, UserDeath_LifeDance_53

;> wBattleTempHigh = 0xFF; wTextIndex = 0xE7
	ld a, $ff
	ld [wBattleTempHigh], a
	ld a, $e7
	ld [wTextIndex], a
;> if IsUserOnOwnSide_53(): wTextIndex = 0xEA
	call IsUserOnOwnSide_53
	jr nc, UserDeath_ShowMessage_53

	ld a, $ea
	ld [wTextIndex], a
;> return UserDeath_ShowMessage_53()                # runs on into it

;@ def UserDeath_ShowMessage_53()
;@ path: battle/skills
;@ Starts message wTextIndex (group 0) and plays sound wBattleTempHigh ($FF: none).
;@ test: skip calls a routine in another bank
UserDeath_ShowMessage_53::
;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;> if wBattleTempHigh != 0xFF: QueueSound(wBattleTempHigh)
	ld a, [wBattleTempHigh]
	cp $ff
	ret z

	call QueueSound
	ret


;@ def UserDeath_Apply_53()
;@ path: battle/skills
;@ Stage 5: the user loses wSkillAmount HP. At 0 (or when it is no longer in the fight) it goes down
;@ (wBattlerState 1, DefeatBattler); a user on the enemy side has its picture blanked and (not in a
;@ link battle) may ask to join.
;@ test: skip calls routines in other banks
UserDeath_Apply_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if not CheckBattlerPresent(wSkillUser):           # no carry: it is there
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr c, .gone

;>@h     hp = addr(wBattlerHP) + 2 * wSkillUser
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@h
	ld h, a
;>@s     mem16[hp] -= wSkillAmount
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount+1]
	ld b, a
	ld a, [hl]
	sub c
;=@s
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hld], a
;>     if mem16[hp]: return
	or [hl]
	ret nz

;>@d     wBattlerState[wSkillUser] = 1
	ld a, [wSkillUser]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@d
	ld h, a
	ld a, $01
	ld [hl], a

.gone
;> wBattleArg0 = wSkillUser; wBattleStepArg1 = 0
	ld a, [wSkillUser]
	ld [wBattleArg0], a
	xor a
	ld [wBattleStepArg1], a
;> DefeatBattler()
	ld hl, far_DefeatBattler
	rst $10
;> saved = wSkillTarget; wSkillTarget = wSkillUser
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;>@o if IsUserOnOwnSide_53(): UpdateStatusIcon_50()
	call IsUserOnOwnSide_53
	jr c, .own
;> else:

;>     step = wBattleSubStep; BlankEnemyPicture()
	ld a, [wBattleSubStep]
	push af
	ld hl, far_BlankEnemyPicture
	rst $10
;>     wBattleSubStep = step
	pop af
	ld [wBattleSubStep], a
;>     if not wLinkActive: wJoinCandidate = wSkillTarget
	ld a, [wLinkActive]
	or a
	jr nz, .restore

	ld a, [wSkillTarget]
	ld [wJoinCandidate], a
	jr .restore

.own
;=@o
	ld hl, far_UpdateStatusIcon_50
	rst $10

.restore
;> wSkillTarget = saved
	pop af
	ld [wSkillTarget], a
	ret


;@ def UserDeath_DrainMP_53()
;@ path: battle/skills
;@ Stage 6 of RunReviveAllStages_53: the user's MP drops to 0, then UserDeath_Done_53.
;@ test: wSkillUser = rand(0, 7)
UserDeath_DrainMP_53::
;>@m mem16[addr(wBattlerMP) + 2 * wSkillUser] = 0
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	xor a
	ld [hli], a
	ld [hl], a
;> return UserDeath_Done_53()                       # runs on into it

;@ def UserDeath_Done_53()
;@ path: battle/skills
;@ The end of the death or revive stages: the action goes on with step 6.
;@ test: wBattleSubStep = 0
UserDeath_Done_53::
;> wBattleSubStep = 6; wBattleSubStep2 = 0
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
;> wBattleTemp = 0; wBattleTempHigh = 0
	xor a
	ld [wBattleTemp], a
	xor a
	ld [wBattleTempHigh], a
	ret


;@ def RunReviveAllStages_53()
;@ path: battle/skills
;@ Far entry 14: Farewell and LifeDance, in stages (wBattleSubStep2) - every other monster of the
;@ user's side is revived or healed in full (stages 0-3 per position), then the user falls and
;@ loses all its MP (stages 4-6).
;@ test: skip jump table
RunReviveAllStages_53::
;> ReviveAllStages_53[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/skills
;@ Stages of RunReviveAllStages_53.
ReviveAllStages_53::
	dw Revive_Begin_53
	dw Revive_Revive_53
	dw Revive_Heal_53
	dw Revive_Message_53
	dw UserDeath_Begin_53
	dw UserDeath_Apply_53
	dw UserDeath_DrainMP_53

;@ def Revive_Begin_53()
;@ path: battle/skills
;@ Stage 0: no message yet (wBattleTempHigh 0). The user itself and empty positions go straight to
;@ stage 3, a monster that is down to stage 1 (revive), any other to stage 2 (heal).
;@ test: wSkillTarget = rand(0, 7); wSkillUser = rand(0, 7); wBattleSubStep2 = 0
Revive_Begin_53::
;> wBattleSubStep2 += 1; wBattleTempHigh = 0
	ld hl, wBattleSubStep2
	inc [hl]
	xor a
	ld [wBattleTempHigh], a
;>@u if wSkillTarget == wSkillUser: wBattleSubStep2 += 2; return
	ld a, [wSkillTarget]
	ld hl, wSkillUser
	cp [hl]
	jr z, .skip

;>@x state = wBattlerState[wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@x
	ld a, [hl]
;> if state == 0xFF: wBattleSubStep2 += 2; return
	cp $ff
	jr z, .skip

;> if state == 1: return
	cp $01
	ret z

;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


.skip
;=@u
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def Revive_Revive_53()
;@ path: battle/skills
;@ Stage 1: the target comes back with full HP and its status bytes cleared; its picture (enemy side,
;@ ReloadBattlerPicture_53) or its tile at $8DA0 (this Game Boy's side, graphic $5B:02) is drawn
;@ again. Message "... is revived" ($9E), no sound; stage 2 is skipped.
;@ test: skip decompresses into VRAM
Revive_Revive_53::
;> wBattleSubStep2 += 2
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
;> wBattleTempHigh = 0x9E; RefillHP_53()
	ld a, $9e
	ld [wBattleTempHigh], a
	call RefillHP_53
;>@s wBattlerState[wSkillTarget] = 0
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld [hl], $00
;>@c fill(addr(wBattlerStatus) + 8 * wSkillTarget, 0, 8)
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	xor a
	ld [hli], a
	ld [hli], a
;=@c
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;>@e enemy = wSkillTarget < 3 if wLinkFlags & 0x02 else wSkillTarget >= 3
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ld b, a
	jr nz, .link

;=@e
	cp $03
	jr c, .own

	jr .enemy

.link
;=@e
	cp $03
	jr nc, .own

.enemy
;>@p if enemy: ReloadBattlerPicture_53(wSkillTarget, wBattlerSpecies[wSkillTarget])
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@p
	ld c, [hl]
	call ReloadBattlerPicture_53
	jr .done

.own
;>@t else: DecompressVRAM(0x5B, 0x02, 0x8DA0 + 16 * wSkillTarget)
	swap a
	ld hl, $8da0
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld de, $5b02
	call DecompressVRAM

.done
;> wBattleTempHigh = 0x9E; wSkillTempPtr = 0xFF
	ld a, $9e
	ld [wBattleTempHigh], a
	ld a, $ff
	ld [wSkillTempPtr], a
;> GetTargetName_53()
	call GetTargetName_53
	ret


	db $25, $2b, $31

;@ def Revive_Heal_53()
;@ path: battle/skills
;@ Stage 2: a monster still up gets its HP back in full and the skill is shown: "...'s wound heals"
;@ ($84). The sound $70 is set only for a user on this Game Boy's side (otherwise wSkillTempPtr
;@ keeps the previous position's value).
;@ test: skip calls routines in other banks
Revive_Heal_53::
;> wBattleSubStep2 += 1; RefillHP_53()
	ld hl, wBattleSubStep2
	inc [hl]
	call RefillHP_53
;> StartSkillVisual(); wBattleTempHigh = 0x84
	ld hl, far_StartSkillVisual
	rst $10
	ld a, $84
	ld [wBattleTempHigh], a
;> GetTargetName_53()
	call GetTargetName_53
;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .single

;>     if not IsUserOnOwnSide_53(): return
	call IsUserOnOwnSide_53
	ret nc

	jr .sound
;> else:

.single
;>     if wSkillUser >= 4: return
	ld a, [wSkillUser]
	cp $04
	ret nc

.sound
;> wSkillTempPtr = 0x70
	ld a, $70
	ld [wSkillTempPtr], a
	ret


;@ def Revive_Message_53()
;@ path: battle/skills
;@ Stage 3: shows message wBattleTempHigh (0: none) and plays sound wSkillTempPtr ($FF: none; in a
;@ single-player battle only for a user on the player's side), then on to the side's next position
;@ (stage 0); after the third, stage 4.
;@ test: skip calls routines in other banks
Revive_Message_53::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wBattleTempHigh:
	ld a, [wBattleTempHigh]
	or a
	jr z, .next

;>     wTextIndex = wBattleTempHigh; wTextGroup = 0
	ld a, [wBattleTempHigh]
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>@q     if wSkillTempPtr != 0xFF and (wLinkActive or wSkillUser < 4): QueueSound(wSkillTempPtr)
	ld a, [wSkillTempPtr]
	cp $ff
	jr z, .next

;=@q
	ld a, [wLinkActive]
	or a
	jr nz, .sound

;=@q
	ld a, [wSkillUser]
	cp $04
	jr nc, .next

.sound
;=@q
	ld a, [wSkillTempPtr]
	call QueueSound

.next
;> if wSkillTarget & 3 == 2: return
	ld a, [wSkillTarget]
	and $03
	cp $02
	ret z

;> wSkillTarget += 1; wBattleSubStep2 = 0
	ld hl, wSkillTarget
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def RefillHP_53()
;@ path: battle/state
;@ Sets the target's HP to its maximum.
;@ test: wSkillTarget = rand(0, 7)
RefillHP_53::
;>@m hp = mem16[addr(wBattlerMaxHP) + 2 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@h mem16[addr(wBattlerHP) + 2 * wSkillTarget] = hp
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@h
	adc h
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	ret


;@ def ShowShockedNext_53()
;@ path: battle/skills
;@ Far entry 15, for CALLHOROR and Smashed: the next enemy (positions 5 and 6) that is present is
;@ hit (action step 1, stage 11). After the last enemy CALLHOROR turns on its own side: each present
;@ monster of positions 0-2, one per call, "freezes in shock" ($AA). Then the action goes on with
;@ step 6.
;@ test: skip calls routines in other banks
ShowShockedNext_53::
;>@d if wSkillTarget == 3: wBattleSubStep = 6; wBattleSubStep2 = 0; return
	ld a, [wSkillTarget]
	cp $03
	jr z, .done

;>@o if wSkillTarget != 6 and wSkillTarget >= 3:
	cp $06
	jr z, .ownSide

;=@o
	cp $03
	jr c, .shock

;>     wSkillTarget += 1
	inc a
	ld [wSkillTarget], a
;>     if CheckBattlerPresent(wSkillTarget): return ShowShockedNext_53()
	call CheckBattlerPresent
	jr c, ShowShockedNext_53

;>     wBattleSubStep = 1; wBattleSubStep2 = 0x0B
	ld a, $01
	ld [wBattleSubStep], a
	ld a, $0b
	ld [wBattleSubStep2], a
;>     wBattleStepArg1 = 0; return
	ld a, $00
	ld [wBattleStepArg1], a
	ret
;> if wSkillTarget == 6:


.ownSide
;>     if wSkillId == 0xA4: wBattleSubStep = 6; wBattleSubStep2 = 0; return
	ld a, [wSkillId]
	cp $a4
	jr z, .done

;>     wSkillTarget = 0
	ld a, $00
	ld [wSkillTarget], a
;>     if CheckBattlerPresent(0): return ShowShockedNext_53()
	call CheckBattlerPresent
	jr c, ShowShockedNext_53

.shock
;>@m if CheckBattlerPresent(wSkillTarget): wSkillTarget += 1; return ShowShockedNext_53()
	call CheckBattlerPresent
	jr c, .missing

;> GetTargetName_53(); wTextIndex = 0xAA
	ld a, [wSkillTarget]
	call GetTargetName_53
	ld a, $aa
	ld [wTextIndex], a
;> wTextGroup = 0; StartText_4C()
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;> wSkillTarget += 1
	ld hl, wSkillTarget
	inc [hl]
	ret


.missing
;=@m
	ld hl, wSkillTarget
	inc [hl]
	jr ShowShockedNext_53

.done
;=@d
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def IsTargetOnOwnSide_53() -> carry
;@ path: battle/state
;@ Carry when the target (wSkillTarget) is on this Game Boy's side: positions 0-3, or 4-7 when the
;@ sides are swapped (wLinkFlags bit 1, the link partner's view).
;@ test: wSkillTarget = rand(0, 7); wLinkFlags = rand(0, 3)
IsTargetOnOwnSide_53::
;> swapped = wLinkFlags & 0x02
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr nz, .swapped

;> if not swapped: return wSkillTarget < 4
	cp $04
	ret


.swapped
;> return wSkillTarget >= 4
	cp $04
	ccf
	ret


;@ def IsUserOnOwnSide_53() -> carry
;@ path: battle/state
;@ The same for the user (wSkillUser).
;@ test: wSkillUser = rand(0, 7); wLinkFlags = rand(0, 3)
IsUserOnOwnSide_53::
;> swapped = wLinkFlags & 0x02
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillUser]
	jr nz, .swapped

;> if not swapped: return wSkillUser < 4
	cp $04
	ret


.swapped
;> return wSkillUser >= 4
	cp $04
	ccf
	ret


;@ path: unused
;@ Unused space at the end of the bank (zeros).
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
