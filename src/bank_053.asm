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
	dw Call_53_51E8
	dw Call_53_5CBC
	dw Call_53_5D22
	dw Call_53_5D22
	dw Call_53_5E35
	dw Call_53_601C
	dw Call_53_60B3
	dw Call_53_65AC
	dw Call_53_670E
	dw Call_53_6A9B
	dw Call_53_6BE2
	dw Call_53_51AA
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


RunActionStart_53::
	ld a, [wBattleSubStep2]
	rst $00

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

ActionStart_Begin_53::
	xor a
	ld [wBattleTemp], a
	ld a, [wBattleSubStep]
	cp $12
	jr nz, jr_053_4500

	ld [wBattleTemp], a
	xor a
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02

jr_053_4500:
	xor a
	ld [wHitCount], a
	ld [wBattleStepArg0], a
	ld [wBattleStepArg1], a
	ld [$dd6d], a
	ld [$dd6e], a
	ld [wBattleAnimRunning], a
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_451e

	ld a, $00
	ld [wOrderFlag0], a

jr_053_451e:
	ld a, $01
	ld [wBattleAnimDone], a
	ld a, $ff
	ld [wSkillTarget], a
	ld a, [wReactionKind]
	or a
	jr nz, jr_053_454f

	ld a, [wTurnOrderPos]
	cp $09
	jp z, Jump_053_4640

	ld hl, wTurnOrder
	call ReadTableByte_53
	cp $10
	jr nz, jr_053_4546

	ld a, $09
	ld [wBattleSubStep], a
	ret


jr_053_4546:
	ld [wSkillUser], a
	call CheckBattlerPresent
	jp c, Jump_053_463b

jr_053_454f:
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	call ReadTableByte_53
	cp $02
	jp nz, Jump_053_463b

	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, jr_053_4570

	ld a, $11
	jp Jump_053_462c


jr_053_4570:
	ld a, l
	sub $05
	ld l, a
	ld [wSkillStatusPtr], a
	ld a, h
	sbc $00
	ld h, a
	ld [$db62], a
	bit 6, [hl]
	jr z, jr_053_4587

	ld a, $13
	jp Jump_053_462c


jr_053_4587:
	bit 7, [hl]
	jr z, jr_053_4591

	call SleepTurn_53
	jp Jump_053_462c


jr_053_4591:
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	or a
	jr z, jr_053_45ca

	bit 2, a
	jr z, jr_053_45a1

	ld a, $16
	jp Jump_053_462c


jr_053_45a1:
	bit 0, a
	jr z, jr_053_45aa

	ld a, $12
	jp Jump_053_462c


jr_053_45aa:
	bit 1, a
	jr z, jr_053_45b2

	ld a, $14
	jr jr_053_462c

jr_053_45b2:
	bit 3, a
	jr z, jr_053_45ba

	ld a, $15
	jr jr_053_462c

jr_053_45ba:
	bit 4, a
	jr z, jr_053_45c2

	ld a, $17
	jr jr_053_462c

jr_053_45c2:
	bit 5, a
	jr z, jr_053_45ca

	ld a, $18
	jr jr_053_462c

jr_053_45ca:
	call DrawRandom_53
	ld a, [wSkillStatusPtr]
	ld l, a
	ld a, [$db62]
	ld h, a
	bit 5, [hl]
	jr z, jr_053_45f9

	ld a, [wRandomHigh]
	cp $40
	jr nc, jr_053_45f9

	call CurseEffect_53
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	ret nz

	ld a, $05
	ld [wBattleSubStep2], a
	ret


jr_053_45f9:
	bit 4, [hl]
	jr z, jr_053_4621

	call GetUserName_53
	ld a, $10
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $11
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	ret


jr_053_4621:
	call CheckEnemyRepeatsSkill_53
	jr c, jr_053_464c

	ld hl, wBattleSubStep2
	inc [hl]
	jr LoadActionSkill_53

Jump_053_462c:
jr_053_462c:
	ld [wBattleArg0], a
	ld hl, far_Call_50_59EB
	rst $10
	call ClearTurnAilments_53
	ld a, $07
	ld [wBattleSubStep2], a

Jump_053_463b:
	ld hl, wTurnOrderPos
	inc [hl]
	ret


Jump_053_4640:
	xor a
	ld [wBattleSubStep], a
	ld [wBattleSubStep2], a
	ld hl, wBattleStep
	inc [hl]
	ret


jr_053_464c:
	call IsSmart_53
	jr nz, ReplaceWithAttack_53

	ld hl, wBattleSubStep2
	inc [hl]
	jr LoadActionSkill_53

ReplaceWithAttack_53::
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $3a
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	call RechooseAction_53
	ld a, $01
	ld [wOrderFlag0], a

LoadActionSkill_53::
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillId], a
	ld hl, far_LoadSkillFlags
	rst $10
	ret


ActionStart_Reconsider_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wBattleStepArg0]
	or a
	jr z, jr_053_46a8

	cp $02
	jp z, KeepActionTarget_53

	ld hl, wBattleSubStep2
	inc [hl]
	jp KeepActionTarget_53


jr_053_46a8:
	ld a, [wBattleTemp]
	or a
	jp nz, Jump_053_4733

	ld a, [wGameModeStep]
	or a
	jp nz, Jump_053_4733

	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	call ReadTableByte_53
	cp $02
	jr nz, jr_053_4733

	call IsUnderDirectOrder_53
	jr z, jr_053_4733

	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr nz, jr_053_4733

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillId], a
	ld a, [wSkillId]
	cp $55
	jr z, jr_053_4733

	ld hl, far_LoadSkillFlags
	rst $10
	ld a, [wSkillFlags1]
	bit 3, a
	jr nz, jr_053_4733

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_053_4733

	ld bc, $0004
	add hl, bc
	bit 2, [hl]
	jr nz, jr_053_4733

	inc hl
	bit 4, [hl]
	jr nz, jr_053_4733

	ld a, [wTurnOrderPos]
	or a
	jr z, jr_053_4733

	xor a
	ld [wBattleSubStep2], a
	ld a, $18
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ret


Jump_053_4733:
jr_053_4733:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	call ReadTableByte_53
	ld [wSkillId], a
	inc hl
	ld a, [hl]
	ld [wSkillTarget], a
	ld hl, far_LoadSkillFlags
	rst $10
	ld a, [wSkillId]
	cp $14
	jr nz, jr_053_475e

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	jr z, RechooseAction_53

	ret


jr_053_475e:
	cp $32
	ret z

	cp $96
	ret z

	cp $95
	ret z

	cp $ad
	ret z

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, ActionStart_TargetGone_53

	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	call ReadTableByte_53
	or a
	ret z

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	ret z

RechooseAction_53::
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	xor a
	ld [wBattleSubStep2], a
	ld a, $19
	ld [wBattleSubStep], a
	ret


ActionStart_TargetGone_53::
	ld a, [wSkillId]
	cp $51
	jr z, jr_053_47d1

	cp $52
	jr z, jr_053_47d1

	cp $53
	jr z, jr_053_47d1

	ld a, [wSkillTargeting]
	and $01
	jr z, jr_053_47e8

	call IsSmart_53
	or a
	ret z

	call IsUnderDirectOrder_53
	ret z

jr_053_47d1:
	ld hl, far_RunTargetPicker
	rst $10

KeepActionTarget_53:
	xor a
	ld [wBattleStepArg0], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	jr jr_053_4809

jr_053_47e8:
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $03

jr_053_47f0:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_053_47fb

	inc c
	dec b
	jr nz, jr_053_47f0

	ret


jr_053_47fb:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c

jr_053_4809:
	ld a, [hl]
	ld [wSkillTarget], a
	ret


ActionStart_CheckMP_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, far_LoadSkillFlags
	rst $10
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
	or a
	jp z, Jump_053_4871

	ld b, $00
	ld a, [wSkillUser]
	call GetBattlerMP
	call CompareHLBC
	jr z, jr_053_4871

	ld a, l
	sub c
	ld a, h
	sbc b
	jr nc, jr_053_4871

	call IsSecondTurnOfSkill_53
	jr c, jr_053_4871

	call IsSmart_53
	call z, RethinkUnusableSkill_53
	ld a, [wSkillFlags1]
	bit 6, a
	jr z, jr_053_485b

	ld a, $f7
	jp ShowActionFailed_53


jr_053_485b:
	bit 5, a
	jr z, jr_053_4864

	ld a, $f9
	jp ShowActionFailed_53


jr_053_4864:
	bit 4, a
	jr z, jr_053_486d

	ld a, $f8
	jp ShowActionFailed_53


jr_053_486d:
	call ShowNotEnoughMP_53
	ret


Jump_053_4871:
jr_053_4871:
	ld a, [wSkillFlags1]
	bit 6, a
	jr z, jr_053_48af

	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr z, jr_053_4899

	call IsSmart_53
	call z, RethinkUnusableSkill_53
	call PayMPClamped_53
	ld a, $1f
	jr jr_053_48e0

jr_053_4899:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	ret z

	call IsSmart_53
	call z, RethinkUnusableSkill_53
	ld a, $1e
	jr jr_053_48e0

jr_053_48af:
	bit 5, a
	jr z, jr_053_48c9

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 6, [hl]
	ret z

	call IsSmart_53
	call z, RethinkUnusableSkill_53
	ld a, $21
	jr jr_053_48e0

jr_053_48c9:
	bit 4, a
	ret z

	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	ret z

	call IsSmart_53
	call z, RethinkUnusableSkill_53
	ld a, $20

jr_053_48e0:
	push af
	call PayMP_53
	pop af

ShowActionFailed_53::
	ld [wBattleArg0], a
	ld hl, far_Call_50_59EB
	rst $10

EndFailedAction_53::
	ld a, [wReactionKind]
	or a
	jr nz, jr_053_48fb

	ld hl, wTurnOrderPos
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	ret


jr_053_48fb:
	ld a, $06
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ld a, $20
	ld [wReactionKind], a
	ret


RethinkUnusableSkill_53::
	ld a, [wReactionKind]
	or a
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	ret nz

	ld a, [wBattleTemp]
	or a
	ret nz

	call IsUnderDirectOrder_53
	ret z

	ld a, $16
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	pop af
	ret


IsSecondTurnOfSkill_53::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_053_4951

	inc hl
	bit 4, [hl]
	jr nz, jr_053_495a

jr_053_494f:
	xor a
	ret


jr_053_4951:
	ld a, [wSkillId]
	cp $42
	jr nz, jr_053_494f

	jr jr_053_4961

jr_053_495a:
	ld a, [wSkillId]
	cp $95
	jr nz, jr_053_494f

jr_053_4961:
	scf
	ret


ShowNotEnoughMP_53::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerName_53
	ld hl, wTextArg1
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, [wSkillId]
	cp $42
	jr z, jr_053_49b3

	cp $52
	jr z, jr_053_49b7

	cp $53
	jr z, jr_053_49b7

	cp $56
	jr z, jr_053_49bb

	cp $6f
	jr z, jr_053_49bf

	cp $8f
	jr z, jr_053_49c3

	cp $92
	jr z, jr_053_49c7

	cp $95
	jr z, jr_053_49cb

	ld a, $1d
	jp ShowActionFailed_53


jr_053_49b3:
	ld a, $0c
	jr jr_053_49cd

jr_053_49b7:
	ld a, $0d
	jr jr_053_49cd

jr_053_49bb:
	ld a, $0e
	jr jr_053_49cd

jr_053_49bf:
	ld a, $0f
	jr jr_053_49cd

jr_053_49c3:
	ld a, $10
	jr jr_053_49cd

jr_053_49c7:
	ld a, $11
	jr jr_053_49cd

jr_053_49cb:
	ld a, $12

jr_053_49cd:
	ld [wTextIndex], a
	ld a, $01
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	jp EndFailedAction_53


IsSmart_53::
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	call ReadTableByte_53
	cp $02
	ret


ActionStart_PayMP_53::
	call IsSmart_53
	jr nz, jr_053_49fc

	call CheckEnemyRepeatsSkill_53
	jr nc, jr_053_49fc

	ld a, [wOrderFlag0]
	or a
	jr nz, jr_053_49fc

	call ReplaceWithAttack_53
	ret


jr_053_49fc:
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a

PayMP_53::
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 4, [hl]
	ret nz

	ld a, [wSkillId]
	ld [wBattleArg0], a
	call IsMPFree_53
	ret c

	xor a
	ld [wBattleArg1], a
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc $00
	ld [hl], a
	ld a, [wSkillId]
	cp $32
	ret nz

	xor a
	ld [hld], a
	ld [hl], a
	ret


ActionStart_Next_53::
	xor a
	ld [wBattleSubStep2], a
	ld hl, wTurnOrderPos
	inc [hl]
	ret


ActionStart_CheckDown_53::
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	jr z, jr_053_4a6c

	ld a, $01
	ld [wBattleSubStep2], a
	ret


jr_053_4a6c:
	call GetUserName_53
	ld a, [wSkillUser]
	ld b, a
	and $03
	cp $03
	jr nz, jr_053_4a99

	ld a, b
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
	ld a, b
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, $e6
	jr jr_053_4ab0

jr_053_4a99:
	ld a, b
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	call Call_53_6C59
	jr c, jr_053_4aae

	ld a, $e7
	jr jr_053_4ab0

jr_053_4aae:
	ld a, $e3

jr_053_4ab0:
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $06
	ld [wBattleSubStep2], a
	ret


ActionStart_AfterDown_53::
	ld hl, far_Call_52_7A18
	rst $10
	xor a
	ld [wBattleSubStep2], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld hl, far_Call_52_76C8
	rst $10
	ld a, [wSkillMsgMode]
	cp $ff
	ret z

	xor a
	ld hl, wBattleSubStep
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [wBattleArg2], a
	ld a, $0a
	ld [wBattleStep], a
	ret


SleepTurn_53::
	ld a, [hl]
	and $0c
	jr z, jr_053_4b04

	cp $04
	jr z, jr_053_4b00

	cp $08
	jr z, jr_053_4afc

	ld b, $60
	jr jr_053_4b06

jr_053_4afc:
	ld b, $a0
	jr jr_053_4b06

jr_053_4b00:
	ld b, $e0
	jr jr_053_4b06

jr_053_4b04:
	ld b, $ff

jr_053_4b06:
	ld a, [wRandomHigh]
	cp b
	jr z, jr_053_4b28

	jr c, jr_053_4b28

	ld a, [hl]
	and $f3
	ld b, a
	ld a, [hl]
	and $0c
	dec a
	push bc
	push af
	pop bc
	bit 5, c
	pop bc
	jr nz, jr_053_4b22

	and $0c
	jr jr_053_4b23

jr_053_4b22:
	xor a

jr_053_4b23:
	or b
	ld [hl], a
	ld a, $0f
	ret


jr_053_4b28:
	ld a, [hl]
	and $73
	ld [hl], a
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, $db
	ret


ClearTurnAilments_53::
	push af
	push bc
	push de
	push hl
	ld a, [wSkillUser]
	ld hl, wBattlerStatus3
	call AddEightTimes
	ld a, [hl]
	and $c0
	ld [hl], a
	pop hl
	pop de
	pop bc
	pop af
	ret


PayMPClamped_53::
	push af
	push bc
	push de
	push hl
	ld a, [wSkillId]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $04
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld c, a
	ld b, $00
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [hli]
	ld h, [hl]
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, jr_053_4b87

	ld hl, $0000

jr_053_4b87:
	pop bc
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	pop hl
	pop de
	pop bc
	pop af
	ret


IsMPFree_53::
	cp $32
	jr z, jr_053_4bd1

	cp $42
	jr z, jr_053_4bc3

	cp $66
	jr z, jr_053_4bd1

	cp $95
	jr z, jr_053_4bd3

	cp $96
	jr z, jr_053_4bd1

	ld a, [wSkillFlags1]
	bit 6, a
	jr z, jr_053_4bd1

	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr nz, jr_053_4be1

	jr jr_053_4bd1

jr_053_4bc3:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, jr_053_4be1

jr_053_4bd1:
	xor a
	ret


jr_053_4bd3:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $30
	jr z, jr_053_4bd1

jr_053_4be1:
	scf
	ret


ReadTableByte_53::
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret


PickConfusedAction_53::
	call DrawRandom_53
	ld a, [wRandomHigh]
	bit 1, a
	jr nz, jr_053_4c1b

	bit 0, a
	jr nz, jr_053_4c1f

	ld a, [wLinkActive]
	or a
	jr nz, jr_053_4c23

	ld a, [wSkillUser]
	cp $04
	jr c, jr_053_4c23

	ld a, [wRandomLow]
	and $07
	add $9a
	cp $a1
	jr nz, jr_053_4c32

	ld b, a
	ld a, [wBattleType]
	or a
	ld a, b
	jr z, jr_053_4c32

	jr PickConfusedAction_53

jr_053_4c1b:
	ld a, $99
	jr jr_053_4c32

jr_053_4c1f:
	ld a, $9a
	jr jr_053_4c32

jr_053_4c23:
	ld a, [wRandomLow]
	cp $55
	jr c, jr_053_4c30

	and $01
	add $9b
	jr jr_053_4c32

jr_053_4c30:
	ld a, $9e

jr_053_4c32:
	ld [wSkillId], a
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillId]
	ld [hl], a
	ld a, $10
	ld [wBattleSubStep], a
	ld hl, far_RunTargetPicker
	rst $10
	ret


CurseEffect_53::
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	call GetTargetName_53
	pop af
	ld [wSkillTarget], a
	ld a, [wRandomLow]
	cp $40
	jr c, jr_053_4c87

	cp $80
	jr c, jr_053_4c97

	cp $c0
	jr c, jr_053_4cb9

	ld a, $11
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 4, [hl]
	ld a, $19
	ld [wTextIndex], a
	jr jr_053_4cdc

jr_053_4c87:
	ld a, $04
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleSubStep], a
	ld a, $1a
	ld [wTextIndex], a
	jr jr_053_4cdc

jr_053_4c97:
	ld a, $05
	ld [wBattleSubStep2], a
	ld a, [wSkillUser]
	ld de, wBattlerHP
	call IsWordZero_53
	ret z

	ld a, [wSkillUser]
	call LoseSixthOfMax_53
	jr nc, jr_053_4cb2

	xor a
	ld [de], a
	dec de
	ld [de], a

jr_053_4cb2:
	ld a, $1b
	ld [wTextIndex], a
	jr jr_053_4cdc

jr_053_4cb9:
	ld a, $05
	ld [wBattleSubStep2], a
	call LoseSixthOfMaxMP_53
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, l
	or h
	ret z

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call AmountToTextArg1_53
	ld a, $1c
	ld [wTextIndex], a

jr_053_4cdc:
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


IsWordZero_53::
	push hl
	ld h, d
	ld l, e
	ld a, [hli]
	or [hl]
	pop hl
	ret


LoseSixthOfMax_53::
	add a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	push de
	ld a, $10
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
	ld a, $06
	call Divide16
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	push hl
	call AmountToTextArg1_53
	pop hl
	pop de
	ld a, [de]
	sub l
	ld [de], a
	inc de
	ld a, [de]
	sbc $00
	ld [de], a
	ret


LoseSixthOfMaxMP_53::
	ld a, [wSkillUser]
	call GetBattlerMaxMP
	or h
	jr z, jr_053_4d75

	ld a, $06
	call Divide16
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [$db59], a
	ld a, [hli]
	or [hl]
	jr nz, jr_053_4d50

	ld h, [hl]
	ld l, a
	jr jr_053_4d75

jr_053_4d50:
	ld a, [hld]
	ld c, [hl]
	ld b, a
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [$db5b], a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
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
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [$db5b]
	ld h, a

jr_053_4d75:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


PickChanceEffect_53::
	call DrawRandom_53
	ld a, [wRandomHigh]
	and $0f
	or a
	jr z, jr_053_4d91

	cp $01
	jr z, jr_053_4d95

	add $a0
	jr jr_053_4d97

jr_053_4d91:
	ld a, $a9
	jr jr_053_4d97

jr_053_4d95:
	ld a, $a3

jr_053_4d97:
	ld [wSkillId], a
	ld [wBattleArg0], a
	xor a
	ld [wBattleArg1], a
	ld a, $09
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleType]
	or a
	jr z, jr_053_4db7

	ld a, [wBattleArg0]
	bit 1, a
	jr z, PickChanceEffect_53

jr_053_4db7:
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_4dcf

	ld a, [wSkillUser]
	cp $03
	jr c, jr_053_4dcf

	ld a, [wSkillId]
	cp $a2
	jr z, PickChanceEffect_53

	cp $a4
	jr z, PickChanceEffect_53

jr_053_4dcf:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillId]
	ld [hl], a
	ld a, [wHitCount]
	push af
	xor a
	ld [wHitCount], a
	ld hl, far_RunTargetPicker
	rst $10
	pop af
	ld [wHitCount], a
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleSubStep], a
	xor a
	ld [wBattleStepArg0], a
	xor a
	ld [wHitCount], a
	ret


IsUnderDirectOrder_53::
	ld a, [wBattleTemp]
	or a
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	ret nz

	ld a, [wLinkActive]
	or a
	jr nz, jr_053_4e21

	ld a, [wMenuChoice]
	jr jr_053_4e30

jr_053_4e21:
	ld a, [wSkillUser]
	cp $04
	jr nc, jr_053_4e2d

	ld a, [wOrderFlag0]
	jr jr_053_4e30

jr_053_4e2d:
	ld a, [wOrderFlag1]

jr_053_4e30:
	cp $81
	ret


DrawRandom_53::
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_4e3d

	call Random
	ret


jr_053_4e3d:
	push hl
	ld a, [wLinkRandom]
	ld l, a
	ld a, [$c1ee]
	ld h, a
	ld a, l
	ld [wRandomHigh], a
	ld a, h
	ld [wRandomLow], a
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, l
	ld [wLinkRandom], a
	ld a, h
	ld [$c1ee], a
	pop hl
	ret


CheckEnemyRepeatsSkill_53::
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_4eae

	ld a, [wSkillUser]
	cp $04
	jr c, jr_053_4eae

	cp $07
	jr z, jr_053_4eae

	sub $04
	ld hl, wEncSpecies
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
	add $df
	ld l, a
	ld a, h
	adc $41
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_053_4eae

	ld a, [wTurnOrderPos]
	or a
	jr z, jr_053_4eae

	ld b, a
	ld hl, wTurnOrder

jr_053_4e99:
	ld a, [hli]
	cp $ff
	jr z, jr_053_4eae

	cp $04
	jr nc, jr_053_4ea7

	dec b
	jr nz, jr_053_4e99

	jr jr_053_4eae

jr_053_4ea7:
	call IsSameGroupSkill_53
	jr nz, jr_053_4e99

	scf
	ret


jr_053_4eae:
	scf
	ccf
	ret


IsSameGroupSkill_53::
	push hl
	push bc
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp c
	jr nz, jr_053_4ed3

	call IsGroupSkill_53

jr_053_4ed3:
	pop bc
	pop hl
	ret


IsGroupSkill_53::
	ld hl, $4ee4

jr_053_4ed9:
	ld a, [hli]
	cp $ff
	jr z, jr_053_4ee2

	cp c
	ret z

	jr jr_053_4ed9

jr_053_4ee2:
	or a
	ret


GroupSkills_53::
	db $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12
	db $13, $14, $16, $17, $18, $1d, $1f, $21, $23, $2e, $2f, $30, $31, $32, $3b, $3c
	db $3e, $3f, $40, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $51, $52, $53, $57, $59
	db $5a, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $69, $6a, $6b
	db $6d, $6e, $71, $78, $7c, $7d, $d6, $d7, $d8, $d9, $da, $db, $dc, $ff

ActionStart_StartPause_53::
	ld a, [wMessageSpeed]
	add $03
	ld [wBattleArg0], a
	ld hl, wBattleSubStep2
	inc [hl]
	ret


ActionStart_Pause_53::
	ld a, [wBattleArg0]
	dec a
	ld [wBattleArg0], a
	ret nz

	xor a
	ld [wBattleSubStep2], a
	ret


RunCoverStages_53::
	ld a, [wBattleSubStep2]
	rst $00

CoverStages_53::
	dw Cover_Begin_53
	dw Cover_Skip2_53
	dw Cover_Skip1_53
	dw Cover_Done_53

Cover_Begin_53::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, jr_053_4f6b

jr_053_4f64:
	ld hl, wBattleSubStep2
	inc [hl]
	jp Cover_Skip1_53


jr_053_4f6b:
	ld a, [wSkillTarget]
	cp $04
	jr c, jr_053_4f77

	ld hl, $db01
	jr jr_053_4f7a

jr_053_4f77:
	ld hl, wSideFlags

jr_053_4f7a:
	bit 4, [hl]
	jr nz, jr_053_4f64

	ld a, [wSkillId]
	cp $89
	jr nz, jr_053_4fa2

	set 4, [hl]
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillUser]
	and $03
	swap a
	or [hl]
	ld [hl], a
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $03
	jr jr_053_4fa8

jr_053_4fa2:
	ld a, [wSkillTarget]
	ld c, a
	ld b, $01

jr_053_4fa8:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_053_4fcd

	ld a, c
	ld hl, wSkillUser
	cp [hl]
	jr z, jr_053_4fcd

	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_053_4fcd

	set 4, [hl]
	inc hl
	ld a, [wSkillUser]
	and $0f
	swap a
	ld d, a
	ld a, [hl]
	or d
	ld [hl], a

jr_053_4fcd:
	inc c
	dec b
	jr nz, jr_053_4fa8

	ret


Cover_Skip2_53::
	ld hl, wBattleSubStep2
	inc [hl]

Cover_Skip1_53::
	ld hl, wBattleSubStep2
	inc [hl]

Cover_Done_53::
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


SetDamageMessageArgs_53::
	call GetTargetName_53
	call AmountToTextArg1_53
	call UserNameToTextArg2_53
	ret


AmountToTextArg1_53::
	ld hl, wTextArg1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Number16ToDecimal
	ret


UserNameToTextArg2_53::
	ld hl, wTextArg2
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerName_53
	ret


Jump_053_5021:
	ld a, [wSkillTarget]
	and $04
	ld b, a
	ld a, c
	and $04
	cp b
	jr nz, jr_053_5030

	xor $04
	ld c, a

jr_053_5030:
	ld a, c
	and $04
	xor $04
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	inc e
	ld a, e
	call Call_53_5192
	jp nc, Jump_053_5140

	inc e
	jp Jump_053_5140


Jump_053_5048:
jr_053_5048:
	ld a, c
	and $04
	xor $04
	ld d, a
	ld a, [wRandomLow]
	and $02
	ld c, a
	or d
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	ld a, e
	xor $02
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	inc d
	ld e, d
	jp Jump_053_5140


Jump_053_506b:
jr_053_506b:
	ld a, [wRandomLow]
	and $01
	inc a
	ld d, a
	ld a, c
	and $04
	xor $04
	ld c, a
	add d
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	ld a, d
	xor $03
	ld d, a
	ld a, c
	sub d
	ld e, a
	call Call_53_5192
	jp nc, Jump_053_5140

	ld e, c
	jp Jump_053_5140


Call_53_5091::
	xor a
	ld [wSkillStatusPtr], a
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	ret c

	ld a, [wSkillTarget]
	ld c, a
	call DrawRandom_53
	ld a, [wRandomHigh]
	cp $33
	jr c, jr_053_5112

	cp $66
	jp c, Jump_053_5021

	cp $99
	jr c, jr_053_5048

	cp $cc
	jr c, jr_053_506b

	ld a, c
	and $04
	ld b, a
	ld a, [wRandomLow]
	and $01
	ld d, a
	ld a, c
	and $03
	cp $00
	jr z, jr_053_50e8

	cp $01
	jr z, jr_053_50ec

	inc d
	sub d

jr_053_50ce:
	or b
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld a, d
	xor $03
	cp $03
	jr nz, jr_053_50de

	ld a, $01

jr_053_50de:
	or b
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld e, c
	jr jr_053_5130

jr_053_50e8:
	inc d
	ld a, d
	jr jr_053_50ce

jr_053_50ec:
	ld a, d
	or a
	jr z, jr_053_5102

	ld a, c
	inc a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld a, c
	dec a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	jr jr_053_5130

jr_053_5102:
	ld a, c
	dec a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

	ld a, c
	inc a
	ld e, a
	call Call_53_5192
	jr nc, jr_053_5140

jr_053_5112:
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	jp nz, Jump_053_5021

	ld a, $7f
	ld [wTextIndex], a
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	jr jr_053_516e

jr_053_5130:
	ld a, [wRandomHigh]
	cp $55
	jp c, Jump_053_5021

	cp $aa
	jp c, Jump_053_5048

	jp Jump_053_506b


Jump_053_5140:
jr_053_5140:
	ld a, e
	call CheckBattlerPresent
	jr c, jr_053_5112

	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	cp e
	jp z, Call_53_5091

	ld a, e
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	ld a, $7e
	ld [wTextIndex], a
	jr jr_053_516e

	db $3e, $7f, $ea, $23, $c8

jr_053_516e:
	ld hl, wTextArg2
	ld a, [wTextIndex]
	push af
	ld a, [wBattleArg0]
	call GetBattlerName_53
	pop af
	ld [wTextIndex], a
	ld a, [wBattleTemp]
	or a
	ret nz

	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $01
	ld [wSkillStatusPtr], a
	ret


Call_53_5192::
	call CheckBattlerPresent
	jr c, jr_053_51a8

	ld a, e
	push hl
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	pop hl
	jr nz, jr_053_51a8

	scf
	ccf
	ret


jr_053_51a8:
	scf
	ret


Call_53_51AA::
	ld a, [wLinkActive]
	or a
	jr nz, jr_053_51dd

	ld a, [wSkillTarget]
	cp $04
	jr c, jr_053_51dd

	ld a, [wBattleType]
	cp $01
	jr nz, jr_053_51dd

	ld a, [wSkillId]
	cp $12
	jr z, jr_053_51e3

	cp $13
	jr z, jr_053_51e3

	cp $14
	jr z, jr_053_51e3

	cp $3e
	jr z, jr_053_51e3

	cp $69
	jr z, jr_053_51e3

	cp $6b
	jr z, jr_053_51e3

	cp $71
	jr z, jr_053_51e3

jr_053_51dd:
	ld a, $01
	ld [wBattleArg0], a
	ret


jr_053_51e3:
	xor a
	ld [wBattleArg0], a
	ret


Call_53_51E8::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_53_51EC::
	dw Jump_53_520C
	dw Jump_53_5242
	dw Jump_53_527A
	dw Jump_53_52E9
	dw Jump_53_535E
	dw Jump_53_537A
	dw Jump_53_53A9
	dw Jump_53_5411
	dw Jump_53_5622
	dw Jump_53_56A8
	dw Jump_53_586A
	dw Jump_53_58F6
	dw Jump_53_58FB
	dw Jump_53_5A6F
	dw Jump_53_5AED
	dw Jump_53_5B07

Jump_53_520C::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wHitCount
	inc [hl]

jr_053_5214:
	xor a
	ld [$dd6e], a
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
	cp $ff
	jr nz, jr_053_5233

	ld hl, far_RunTargetPicker
	rst $10
	jr jr_053_5214

jr_053_5233:
	ld a, [wHitCount]
	cp $01
	jr z, Jump_53_5242

	ld a, $07
	ld [wBattleSubStep2], a
	jp Jump_53_5411


Jump_53_5242::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $54
	jr z, Jump_53_527A

	push af
	call GetUserName_53
	pop af
	bit 6, a
	jr nz, jr_053_526c

	bit 2, a
	jr nz, jr_053_5268

	ld a, $6b
	jr jr_053_526e

jr_053_5268:
	ld a, $69
	jr jr_053_526e

jr_053_526c:
	ld a, $6d

jr_053_526e:
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_53_527A::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wReactionKind]
	or a
	jr z, jr_053_5289

	cp $08
	jr z, jr_053_5289

	ret


jr_053_5289:
	ld hl, far_GetSkillMessage
	rst $10
	ld hl, far_Call_50_59EB
	rst $10
	ld hl, far_Call_55_401F
	rst $10
	ld a, $18
	ld [wMonStats], a
	ld a, [wSkillId]
	cp $14
	jr z, jr_053_52c8

	cp $24
	jr z, jr_053_52c8

	cp $26
	jr z, jr_053_52c8

	cp $2a
	jr z, jr_053_52c8

	cp $89
	jr z, jr_053_52c8

	cp $80
	jr z, jr_053_52c8

	cp $8a
	jr z, jr_053_52c8

	cp $8b
	jr z, jr_053_52c8

	cp $8f
	jr z, jr_053_52c8

	cp $83
	jr z, jr_053_52c8

	cp $a5
	ret nz

jr_053_52c8:
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret nc

	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	cp $03
	ret z

	inc [hl]
	ld a, [hl]
	ld [wSkillTarget], a
	jr jr_053_52c8

Jump_53_52E9::
	ld a, [wMonStats]
	or a
	jr z, jr_053_52f4

	dec a
	ld [wMonStats], a
	ret


jr_053_52f4:
	ld hl, far_LoadSkillFlags
	rst $10
	ld a, [wSkillId]
	cp $42
	jr nz, jr_053_5313

	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, jr_053_5313

	ld a, $0b
	ld [wBattleSubStep2], a
	ret


jr_053_5313:
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
	ld [wBattleTempHigh], a
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	jr z, Jump_53_535E

	push af
	call GetUserName_53
	pop af
	bit 1, a
	jr z, jr_053_5349

	ld a, $68
	jr jr_053_5352

jr_053_5349:
	ld a, [wSkillFlags2]
	bit 4, a
	jr z, Jump_53_535E

	ld a, $67

jr_053_5352:
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_53_535E::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, Jump_53_537A

	ld hl, far_StartSkillVisual
	rst $10
	ld a, [wSkillAnimActive]
	cp $01
	ret z

	ld hl, wBattleSubStep2
	inc [hl]
	jr Jump_53_53A9

Jump_53_537A::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillAnimPhase]
	cp $02
	jr nz, Jump_53_53A9

	ld a, [wSkillTarget]
	ld c, a

jr_053_5389:
	and $03
	cp $02
	jr z, jr_053_53a3

	inc c
	ld a, c
	call CheckBattlerPresent
	ld a, c
	jr c, jr_053_5389

	ld [wSkillTarget], a
	ld hl, wBattleSubStep2
	dec [hl]
	ld hl, wBattleSubStep2
	dec [hl]
	ret


jr_053_53a3:
	ld a, [wBattleTempHigh]
	ld [wSkillTarget], a

Jump_53_53A9::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillFlags1]
	bit 7, a
	jr z, Jump_53_5411

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
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, Jump_53_5411

	ld a, [wSkillTarget]
	ld [$c1c8], a
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	jr z, Jump_53_5411

	ld a, [hl]
	ld [wBattleTemp], a
	call Call_53_5091
	ld a, [$c1c8]
	ld hl, wTextArg0
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, [wSkillTarget]
	ld hl, wTextArg1
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, $6c
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_53_5411::
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
	jp nz, Jump_53_5622

	ld a, [wSkillId]
	cp $8f
	jp z, Jump_53_5622

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
	jp c, Jump_53_5622

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
	call Call_53_5ECE
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
	jr z, jr_053_554d

	ld a, [$dd6e]
	or a
	jr nz, jr_053_554d

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 4, [hl]
	jr z, jr_053_554d

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	swap a
	and $0f
	ld b, a
	call CheckBattlerCanAct
	jr c, jr_053_5544

Call_53_5504::
	ld a, b
	ld hl, wTextArg0
	push bc
	ld [wNamePos], a
	call GetBattlerName_53
	ld a, [wSkillTarget]
	ld [$c1c8], a
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
	ld [$dd6e], a
	ret


jr_053_5544:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes

jr_053_554d:
	ld a, [wReactionKind]
	or a
	jp nz, Jump_53_5622

	ld a, [wSkillFlags1]
	bit 7, a
	jr z, jr_053_5594

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jp c, Jump_53_5622

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
	ld [$c1c8], a
	call Call_53_5091
	ld a, [wSkillStatusPtr]
	or a
	jp z, Jump_53_5622

	ld a, $02
	ld [$dd6e], a
	ret


jr_053_5594:
	ld a, [wSkillFlags1]
	bit 4, a
	jp z, Jump_053_55ca

	ld a, [wReactionKind]
	or a
	jp nz, Jump_53_5622

	call Call_53_5CA1
	jr z, jr_053_55ca

	res 6, [hl]
	call GetTargetName_53
	ld a, $01
	call Call_53_5E38
	ld a, $02
	ld [$dd6d], a
	ld a, $02
	ld [$dd6e], a
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
	jp z, Jump_53_5622

	ld a, [wReactionKind]
	or a
	jp nz, Jump_53_5622

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	jp z, Jump_53_5622

	ld a, $00
	ld [$dd6d], a
	bit 1, [hl]
	jr nz, jr_053_55f8

	res 5, [hl]
	ld a, $07
	ld [$dd6d], a

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
	call Call_53_5E38
	ld a, $02
	ld [$dd6e], a
	ret


Jump_53_5622::
	ld a, [$dd6e]
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
	jr Jump_53_56A8

jr_053_563c:
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, Jump_53_56A8

	ld a, [wSkillFlags2]
	bit 7, a
	jr z, Jump_53_56A8

	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 7, [hl]
	jr z, Jump_53_56A8

	call GetTargetName_53
	ld a, $6e
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call Call_53_583A
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

	call Call_53_5504
	ld hl, $dd6e
	inc [hl]
	ret


Jump_53_56A8::
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

	call Call_53_5844
	jr z, jr_053_5747

	ld a, [wSkillId]
	cp $52
	jr z, jr_053_5715

	cp $53
	jr z, jr_053_5715

	cp $14
	jr z, jr_053_5746

jr_053_570e:
	call Call_53_583A
	ld a, $ba
	jr jr_053_5731

jr_053_5715:
	ld a, [wHitCount]
	cp $02
	jr nc, jr_053_570e

	ld a, $00
	ld [$c1c9], a
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
	jp Jump_053_582a


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

	call Call_53_5810
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

	call Call_53_5810
	ret


jr_053_579e:
	ld a, [wSkillFlags2]
	bit 7, a
	jr z, jr_053_57f5

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, jr_053_57f5

	call Call_53_5857
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
	call Call_53_5D68
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
	call Call_53_57F7
	ret


jr_053_57f5:
	jr Jump_53_586A

Call_53_57F7::
	call GetTargetName_53
	ld a, $78
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call Call_53_583A
	ld a, $6f
	call QueueSound
	ret


Call_53_5810::
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

Jump_053_582a:
jr_053_582a:
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $6f
	call QueueSound

Call_53_583A::
	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


Call_53_5844::
	ld a, [wSkillId]
	cp $42
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret


Call_53_5857::
	ld a, [wSkillId]
	cp $41
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $03
	ret


Jump_53_586A::
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
	call Call_53_5ED9
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
	jr Jump_53_58FB

	db $c9

jr_053_58ea:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	res 7, [hl]
	ret


Jump_53_58F6::
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_53_58FB::
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
	jp Jump_053_59c3


jr_053_5941:
	inc hl
	bit 7, [hl]
	jr z, jr_053_5978

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
	call z, Call_53_5973
	call Call_53_5D73
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr jr_053_59c3

Call_53_5973::
	srl h
	rr l
	ret


jr_053_5978:
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
	call Call_53_5DB1
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
	call Call_53_5DB1
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a

Jump_053_59c3:
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
	jp z, Jump_53_5A6F

jr_053_5a0f:
	srl h
	rr l
	jr jr_053_5a25

jr_053_5a15:
	ld a, [wSkillFlags1]
	bit 0, a
	jr z, Jump_53_5A6F

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
	jr Jump_53_5A6F

jr_053_5a44:
	dec hl
	bit 2, [hl]
	jr z, Jump_53_5A6F

	ld a, [wSkillFlags1]
	bit 7, a
	jr z, Jump_53_5A6F

	ld a, [wSkillId]
	cp $3c
	jr z, Jump_53_5A6F

	cp $3e
	jr z, Jump_53_5A6F

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

Jump_53_5A6F::
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
	ld hl, far_Call_55_4026
	rst $10
	ld a, $01
	ld [$c1c9], a
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

	ld hl, far_Call_55_4026
	rst $10
	ld hl, far_StartSkillVisual
	rst $10
	ld a, [wSkillAnimActive]
	cp $01
	jr z, Jump_53_5AED

jr_053_5aec:
	ret


Jump_53_5AED::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillResult]
	bit 2, a
	ret nz

	bit 4, a
	ret z

	ld hl, far_Call_55_4035
	rst $10
	ld hl, far_StartSkillHitEffect
	rst $10
	ld a, $01
	ld [$c1c9], a

Jump_53_5B07::
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

	call Call_53_5CBC
	ld a, [wSkillResultValue]
	ld [wTextIndex], a
	ld a, [wSkillResult]
	bit 3, a
	jr z, jr_053_5b3a

	call Call_53_5C8D
	jr nc, jr_053_5b3a

	call Call_53_5BC6

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
	ld hl, far_Call_55_403C
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

	call Call_53_5C07

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
	call z, Call_53_5BAD
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


Call_53_5BAD::
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


Call_53_5BC6::
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


Call_53_5C07::
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
	call Call_53_5C8D
	ret nc

	ld a, [wSkillId]
	cp $7d
	jr z, jr_053_5c6e

	ld a, $c7
	ld [wTextIndex], a
	ret


jr_053_5c30:
	call Call_53_5C8D
	ret c

	ld a, $b8
	ld [wTextIndex], a
	ret


jr_053_5c3a:
	call Call_53_5C8D
	ret nc

	ld a, $b7
	ld [wTextIndex], a
	ret


jr_053_5c44:
	call Call_53_5C8D
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

Call_53_5C8D::
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


Call_53_5CA1::
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


Call_53_5CBC::
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
	ld [$d9f2], a
	ld a, d
	ld [wPanelMode], a
	ld a, $01
	or a
	ret


Call_53_5D22::
	call Call_53_5CBC
	ld a, [$d9f2]
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


Call_53_5D68::
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


Call_53_5D73::
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


Call_53_5DB1::
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


Call_53_5DE7::
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


Call_53_5E35::
	ld a, [wBattleArg0]

Call_53_5E38::
	call Call_53_5DE7
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
	call z, Call_53_5EA0
	ld a, $01
	ld hl, wBattleSubStep
	ld [hli], a
	xor a
	ld [hl], a
	ret


Call_53_5EA0::
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


Call_53_5ECE::
	push bc
	ld a, b
	call Call_53_5DE7
	pop bc
	ld a, c
	ld [wSkillTarget], a
	ret


Call_53_5ED9::
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
	ld hl, $d9f2
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
	ld hl, $d9f2
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

	ld a, [$dd6e]
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

	ld hl, far_Call_53_5D22
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
	call Call_53_5D68
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
	call Call_53_5D68
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
	ld a, [$dd6e]
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
	ld [$c1c8], a
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
	ld [$dd6e], a

jr_053_67a8:
	ret


Jump_53_67A9::
	ld hl, wBattleSubStep2
	inc [hl]
	call Call_53_51AA
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
	call Call_53_6C48
	jr nc, jr_053_6846

	ld hl, wTextIndex
	inc [hl]
	jr jr_053_6846

jr_053_6832:
	ld a, $e9
	ld [wTextIndex], a
	ld a, $9c
	ld [wBattleTempHigh], a
	call Call_53_6C48
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
	call Call_53_6C48
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
	ld a, [$c1c8]
	cp $ff
	jr z, jr_053_68df

	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, [$c1c8]
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
	ld [$c1c8], a
	xor a
	ld [$dd6e], a

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
	ld hl, far_Call_52_7EF1
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
	ld [$dd6d], a
	bit 1, [hl]
	jr nz, jr_053_6937

	res 5, [hl]
	ld a, $07
	ld [$dd6d], a

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
	call Call_53_5E38
	ld a, $02
	ld [$dd6e], a
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
	call Call_53_6C59
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
	call Call_53_6C59
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

	call Call_53_6C59
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


Call_53_6C48::
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


Call_53_6C59::
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
