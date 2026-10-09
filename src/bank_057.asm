INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $057", ROMX[$4000], BANK[$57]

BankNumber_57::
	db $57

FarTable_57::
	dw Call_57_6E0E
	dw Call_57_7C44
	dw CheckHPAgainstDamage
	dw CalcHitsToKO
	dw CalcBaseMaxHP
	dw CalcBaseMaxMP
	dw CalcBaseAttack
	dw CalcBaseDefense
	dw CalcBaseAgility

;@ def CheckHPAgainstDamage()
;@ path: unused
;@ Far entry 2 (nothing calls it): counts the monsters present on the side facing wSkillUser, then
;@ works out the normal attack damage of battle position wBattleArg0 on each of that side's four
;@ positions (CalcAttackDamage). wBattleArg2 = 1 as soon as wBattleArg0's own HP is at least that damage
;@ times 10 times the number counted, else 0. wSkillUser and wSkillTarget are kept.
;@ test: skip calls a routine in another bank
CheckHPAgainstDamage::
;> saved_user = wSkillUser
	ld a, [wSkillUser]
	ld b, a
;> saved_target = wSkillTarget
	ld a, [wSkillTarget]
	ld c, a
	push bc
;> side = (wSkillUser & 4) ^ 4                  # the side facing the user
	ld a, [wSkillUser]
	and $04
	xor $04
	ld d, a
;> wBattleArg1 = side
	ld [wBattleArg1], a
;> count = 0
	ld bc, $0400
;>@f for pos in range(side, side + 4):
.count
;>     if not CheckBattlerPresent(pos):
	ld a, d
	call CheckBattlerPresent
	jr c, .next

;>         count += 1
	inc c

.next
;=@f
	inc d
	dec b
	jr nz, .count

;> times = count * 10
	ld a, c
	add a
	ld d, a
	add a
	add a
	add d
;> wBattleArg2 = times
	ld [wBattleArg2], a
;> wSkillUser = wBattleArg0
	ld a, [wBattleArg0]
	ld [wSkillUser], a
;>@l for k in range(4):
	ld b, $04

.loop
	push bc
;>     wSkillTarget = wBattleArg1
	ld a, [wBattleArg1]
	ld [wSkillTarget], a
;>     CalcAttackDamage()
	ld hl, far_CalcAttackDamage
	rst $10
;>     total = (wSkillAmount * wBattleArg2) & 0xFFFF
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, [wBattleArg2]
	call Multiply24
;>     hp = GetBattlerHP(wBattleArg0)
	push hl
	ld a, [wBattleArg0]
	call GetBattlerHP
	pop bc
;>     if hp >= total:
	call CompareHLBC
	pop bc
	jr nc, .enough

;>@e1         wBattleArg2 = 1
;>         break
;>     wBattleArg1 += 1
	ld hl, wBattleArg1
	inc [hl]
;=@l
	dec b
	jr nz, .loop

;> else:
;>     wBattleArg2 = 0
	ld a, $00
	ld [wBattleArg2], a
	jr .done

.enough
;=@e1
	ld a, $01
	ld [wBattleArg2], a

.done
;> wSkillUser = saved_user
	pop bc
	ld a, b
	ld [wSkillUser], a
;> wSkillTarget = saved_target
	ld a, c
	ld [wSkillTarget], a
	ret


;@ def CalcHitsToKO()
;@ path: unused
;@ Far entry 3 (nothing calls it): adds up the normal attack damage each monster of the other side
;@ would do to battle position wBattleArg0 (CalcAttackDamage) and stores wBattleArg0's maximum HP divided
;@ by that sum - how many such rounds it lasts - in wTargetScores (u16 entry wBattleArg0 & 3).
;@ wBattleArg1 counts the attackers present. wSkillUser and wSkillTarget are kept.
;@ test: skip calls a routine in another bank
CalcHitsToKO::
;> saved_user = wSkillUser
	ld a, [wSkillUser]
	ld b, a
;> saved_target = wSkillTarget
	ld a, [wSkillTarget]
	ld c, a
	push bc
;>@s score = addr(wTargetScores) + (wBattleArg0 & 3) * 2
	ld a, [wBattleArg0]
	and $03
	ld hl, wTargetScores
	add a
	add l
	ld l, a
;=@s
	ld a, $00
	adc h
	ld h, a
;> wBattleArg3 = score & 0xFF                    # the pointer is kept in wBattleArg3 / wNamePos
	ld a, l
	ld [wBattleArg3], a
;> wNamePos = score >> 8
	ld a, h
	ld [wNamePos], a
;> mem16[score] = 0
	ld a, $00
	ld [hli], a
	ld a, $00
	ld [hl], a
;> wSkillTarget = wBattleArg0
	ld a, [wBattleArg0]
	ld [wSkillTarget], a
;> wSkillUser = (wBattleArg0 & 4) ^ 4              # each monster of the other side attacks it
	ld a, [wBattleArg0]
	and $04
	xor $04
	ld [wSkillUser], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 4
	ld a, $04
	ld [wBattleArg2], a

;>@w while wBattleArg2:
.loop
;>     if not CheckBattlerPresent(wSkillUser):
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jr c, .next

;>         wBattleArg1 += 1
	ld hl, wBattleArg1
	inc [hl]
;>         CalcAttackDamage()
	ld hl, far_CalcAttackDamage
	rst $10
;>         p = wBattleArg3 | wNamePos << 8
	ld a, [wBattleArg3]
	ld l, a
	ld a, [wNamePos]
	ld h, a
;>@t         total = (mem16[p] + wSkillAmount) & 0xFFFF
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, [hli]
	ld h, [hl]
;=@t
	ld l, a
	add hl, bc
;>@m         mem16[p] = total
	ld a, [wBattleArg3]
	ld c, a
	ld a, [wNamePos]
	ld b, a
	ld a, l
	ld [bc], a
;=@m
	inc bc
	ld a, h
	ld [bc], a

.next
;>     wSkillUser += 1
	ld hl, wSkillUser
	inc [hl]
;>     wBattleArg2 -= 1
	ld a, [wBattleArg2]
	dec a
	ld [wBattleArg2], a
;=@w
	jr nz, .loop

;> hp = GetBattlerMaxHP(wBattleArg0)
	ld a, [wBattleArg0]
	call GetBattlerMaxHP
	push hl
;> p = wBattleArg3 | wNamePos << 8
	ld a, [wBattleArg3]
	ld l, a
	ld a, [wNamePos]
	ld h, a
;>@d mem16[p] = DivideHLBC(hp, mem16[p])[0]
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	call DivideHLBC
	push hl
;=@d
	ld a, [wBattleArg3]
	ld l, a
	ld a, [wNamePos]
	ld h, a
	pop bc
;=@d
	ld a, c
	ld [hli], a
	ld a, b
	ld [hl], a
;> wSkillUser = saved_user
	pop bc
	ld a, b
	ld [wSkillUser], a
;> wSkillTarget = saved_target
	ld a, c
	ld [wSkillTarget], a
	ret


;@ def CalcBaseMaxHP()
;@ path: battle/ai
;@ Far entry 4: the maximum HP of battle position wBattleTemp without the changes of the battle,
;@ into wBattleTemp (low byte) and wBattleTempHigh. A called monster (positions 3 and 7) and,
;@ outside a link battle, an enemy of the encounter group take it from a monster template
;@ ($100 + species, or the species word of wEncSpecies), the others from their monster record.
;@ test: skip calls a routine in another bank
CalcBaseMaxHP::
;> pos = wBattleTemp
	ld a, [wBattleTemp]
	ld b, a
;>@i if (pos & 3) == 3 or (not wLinkActive and pos >= 3):    # from a monster template
	ld a, [wLinkActive]
	or a
	jr nz, .notEnemy

;=@i
	ld a, b
	cp $03
	jr c, .notEnemy

;>@id     id = 0x100 | wBattlerSpecies[pos] if (pos & 3) == 3 else WordTableEntry_57(pos - 4, addr(wEncSpecies))
	and $03
	cp $03
	jr z, .called

;=@id
	ld a, b
	sub $04
	ld hl, wEncSpecies
	call WordTableEntry_57

.template
;>@n     wNewMonId = id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>@l     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>@v     value = wTemplateHP
	ld a, [wTemplateHP]
	ld c, a
	ld a, [wTemplateHP + 1]
	ld b, a
	jr .store

;> else:
.notEnemy
;=@i
	ld a, b
	and $03
	cp $03
	jr z, .called

;>     value = GetPartyMonsterWord(pos, addr(wMonMaxHP))
	ld a, b
	ld hl, wMonMaxHP
	call GetPartyMonsterWord
	jr .store

.called
;=@id
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .template

.store
;> wBattleTemp = value & 0xFF
	ld a, c
	ld [wBattleTemp], a
;> wBattleTempHigh = value >> 8
	ld a, b
	ld [wBattleTempHigh], a
	ret


;@ def CalcBaseMaxMP()
;@ path: battle/ai
;@ Far entry 5: the maximum MP of battle position wBattleTemp without the changes of the battle, into
;@ wBattleTemp / wBattleTempHigh; worked out like CalcBaseMaxHP.
;@ test: skip calls a routine in another bank
CalcBaseMaxMP::
;> pos = wBattleTemp
	ld a, [wBattleTemp]
	ld b, a
;>@i if (pos & 3) == 3 or (not wLinkActive and pos >= 3):    # from a monster template
	ld a, [wLinkActive]
	or a
	jr nz, .notEnemy

;=@i
	ld a, b
	cp $03
	jr c, .notEnemy

;>@id     id = 0x100 | wBattlerSpecies[pos] if (pos & 3) == 3 else WordTableEntry_57(pos - 4, addr(wEncSpecies))
	and $03
	cp $03
	jr z, .called

;=@id
	ld a, b
	sub $04
	ld hl, wEncSpecies
	call WordTableEntry_57

.template
;>@n     wNewMonId = id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>@l     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>@v     value = wTemplateMP
	ld a, [wTemplateMP]
	ld c, a
	ld a, [wTemplateMP + 1]
	ld b, a
	jr .store

;> else:
.notEnemy
;=@i
	ld a, b
	and $03
	cp $03
	jr z, .called

;>     value = GetPartyMonsterWord(pos, addr(wMonMaxMP))
	ld a, b
	ld hl, wMonMaxMP
	call GetPartyMonsterWord
	jr .store

.called
;=@id
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .template

.store
;> wBattleTemp = value & 0xFF
	ld a, c
	ld [wBattleTemp], a
;> wBattleTempHigh = value >> 8
	ld a, b
	ld [wBattleTempHigh], a
	ret


;@ def CalcBaseAttack()
;@ path: battle/ai
;@ Far entry 6: the attack of battle position wBattleTemp without the changes of the battle, into
;@ wBattleTemp / wBattleTempHigh; worked out like CalcBaseMaxHP.
;@ test: skip calls a routine in another bank
CalcBaseAttack::
;> pos = wBattleTemp
	ld a, [wBattleTemp]
	ld b, a
;>@i if (pos & 3) == 3 or (not wLinkActive and pos >= 3):    # from a monster template
	ld a, [wLinkActive]
	or a
	jr nz, .notEnemy

;=@i
	ld a, b
	cp $03
	jr c, .notEnemy

;>@id     id = 0x100 | wBattlerSpecies[pos] if (pos & 3) == 3 else WordTableEntry_57(pos - 4, addr(wEncSpecies))
	and $03
	cp $03
	jr z, .called

;=@id
	ld a, b
	sub $04
	ld hl, wEncSpecies
	call WordTableEntry_57

.template
;>@n     wNewMonId = id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>@l     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>@v     value = wTemplateAttack
	ld a, [wTemplateAttack]
	ld c, a
	ld a, [wTemplateAttack + 1]
	ld b, a
	jr .store

;> else:
.notEnemy
;=@i
	ld a, b
	and $03
	cp $03
	jr z, .called

;>     value = GetPartyMonsterWord(pos, addr(wMonAttack))
	ld a, b
	ld hl, wMonAttack
	call GetPartyMonsterWord
	jr .store

.called
;=@id
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .template

.store
;> wBattleTemp = value & 0xFF
	ld a, c
	ld [wBattleTemp], a
;> wBattleTempHigh = value >> 8
	ld a, b
	ld [wBattleTempHigh], a
	ret


;@ def CalcBaseDefense()
;@ path: battle/ai
;@ Far entry 7: the defense of battle position wBattleTemp without the changes of the battle, into
;@ wBattleTemp / wBattleTempHigh; worked out like CalcBaseMaxHP.
;@ test: skip calls a routine in another bank
CalcBaseDefense::
;> pos = wBattleTemp
	ld a, [wBattleTemp]
	ld b, a
;>@i if (pos & 3) == 3 or (not wLinkActive and pos >= 3):    # from a monster template
	ld a, [wLinkActive]
	or a
	jr nz, .notEnemy

;=@i
	ld a, b
	cp $03
	jr c, .notEnemy

;>@id     id = 0x100 | wBattlerSpecies[pos] if (pos & 3) == 3 else WordTableEntry_57(pos - 4, addr(wEncSpecies))
	and $03
	cp $03
	jr z, .called

;=@id
	ld a, b
	sub $04
	ld hl, wEncSpecies
	call WordTableEntry_57

.template
;>@n     wNewMonId = id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>@l     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>@v     value = wTemplateDefense
	ld a, [wTemplateDefense]
	ld c, a
	ld a, [wTemplateDefense + 1]
	ld b, a
	jr .store

;> else:
.notEnemy
;=@i
	ld a, b
	and $03
	cp $03
	jr z, .called

;>     value = GetPartyMonsterWord(pos, addr(wMonDefense))
	ld a, b
	ld hl, wMonDefense
	call GetPartyMonsterWord
	jr .store

.called
;=@id
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .template

.store
;> wBattleTemp = value & 0xFF
	ld a, c
	ld [wBattleTemp], a
;> wBattleTempHigh = value >> 8
	ld a, b
	ld [wBattleTempHigh], a
	ret


;@ def CalcBaseAgility()
;@ path: battle/ai
;@ Far entry 8: the agility of battle position wBattleTemp without the changes of the battle, into
;@ wBattleTemp / wBattleTempHigh; worked out like CalcBaseMaxHP.
;@ test: skip calls a routine in another bank
CalcBaseAgility::
;> pos = wBattleTemp
	ld a, [wBattleTemp]
	ld b, a
;>@i if (pos & 3) == 3 or (not wLinkActive and pos >= 3):    # from a monster template
	ld a, [wLinkActive]
	or a
	jr nz, .notEnemy

;=@i
	ld a, b
	cp $03
	jr c, .notEnemy

;>@id     id = 0x100 | wBattlerSpecies[pos] if (pos & 3) == 3 else WordTableEntry_57(pos - 4, addr(wEncSpecies))
	and $03
	cp $03
	jr z, .called

;=@id
	ld a, b
	sub $04
	ld hl, wEncSpecies
	call WordTableEntry_57

.template
;>@n     wNewMonId = id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>@l     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>@v     value = wTemplateAgility
	ld a, [wTemplateAgility]
	ld c, a
	ld a, [wTemplateAgility + 1]
	ld b, a
	jr .store

;> else:
.notEnemy
;=@i
	ld a, b
	and $03
	cp $03
	jr z, .called

;>     value = GetPartyMonsterWord(pos, addr(wMonAgility))
	ld a, b
	ld hl, wMonAgility
	call GetPartyMonsterWord
	jr .store

.called
;=@id
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .template

.store
;> wBattleTemp = value & 0xFF
	ld a, c
	ld [wBattleTemp], a
;> wBattleTempHigh = value >> 8
	ld a, b
	ld [wBattleTempHigh], a
	ret


AIRuleLists::
	dw AIRulesAttack
	dw AIRulesStatus
	dw AIRulesHeal

AIRulesAttack::
	dw AIRuleNoLatePrep
	dw AIRuleUsable
	dw AIRuleSeverePoison
	dw AIRulePoison
	dw AIRuleTargetsAsleep
	dw AIRuleTargetsParalyzed
	dw AIRuleTargetsReflect
	dw AIRuleBreathBlocked
	dw AIRuleAllImmune
	dw AIRuleNeedsAlly
	dw AIRuleAllReflect
	dw AIRuleAllIronized
	dw AIRuleNoneCanAct
	dw AIRuleImmuneCanAct
	dw AIRuleImmunePoison
	dw AIRuleSacrificeLowHP
	dw AIRuleSlayerNoTarget
	dw AIRuleAllInSky
	dw AIRuleSquallHitSlowFoes
	dw AIRuleScriptedNoKill
	dw AIPenaltyGroupVsOne
	dw AIPenaltyIfGuarded
	dw AIPenaltyImitated
	dw AIPenaltyAllImitating
	dw AIBonusIfWeakResist
	dw AIBonusSlayer
	dw AIBonusAttackVsDefense
	dw AIBonusStrongHit
	dw AIBonusSpellOrBreath
	dw AIBonusGroupAttack
	dw AIBonusMassacre
	dw AIBonusAttackBoosted
	dw AIBonusBreathHeld
	dw AIBonusResistCanAct
	dw AIBonusResistPoison
	dw AIBonusRamming
	dw AIBonusUserBlinded
	dw AIBonusHurtTwinSlash
	dw AIBonusEnemyDamage
	dw $0000

AIRulesStatus::
	dw AIRuleNoLatePrep
	dw AIRuleUsable
	dw AIRuleNotActive
	dw AIRuleSeverePoison
	dw AIRulePoison
	dw AIRuleTargetsAsleep
	dw AIRuleTargetsParalyzed
	dw AIRuleSurround
	dw AIRuleTargetsConfused
	dw AIRuleDefenseDown
	dw AIRuleAgilityDown
	dw AIRuleTargetsHeld
	dw AIRuleDefenseUp
	dw AIRuleAgilityUp
	dw AIRuleNoBreathers
	dw AIRuleSuckAir
	dw AIRuleTargetsReflect
	dw AIRuleBreathBlocked
	dw AIRuleAllImmune
	dw AIRuleAllBoosted
	dw AIRuleChargeUpDoubled
	dw AIRuleNoSpellsToReflect
	dw AIRuleCurse
	dw AIRuleSpellsStopped
	dw AIRuleMouthsShut
	dw AIRuleDanceShut
	dw AIRuleNoSpellUsers
	dw AIRuleNeedsAlly
	dw AIRuleWindActive
	dw AIRuleTakeMagicActive
	dw AIRuleTripImmune
	dw AIRuleEerieLite
	dw AIRuleMagicWallActive
	dw AIRuleSideStepActive
	dw AIRuleOwnSideBlinded
	dw AIRuleAllReflect
	dw AIRuleAllIronized
	dw AIRuleNoneCanAct
	dw AIRuleImmuneCanAct
	dw AIRuleImmuneUnblinded
	dw AIRuleImmuneStopSpell
	dw AIRuleImmuneHasMP
	dw AIRuleImmuneDefense
	dw AIRuleImmuneAgility
	dw AIRuleImmunePoison
	dw AIRuleImmuneCurse
	dw AIRuleImmuneDanceShut
	dw AIRuleImmuneMouthShut
	dw AIRuleNoEnemyMP
	dw AIRuleCallTaken
	dw AIRuleSuckAirHeld
	dw AIRuleUltraDownUseless
	dw AIRuleAllInSky
	dw AIRuleMPAlmostFull
	dw AIRuleThickFogNoBigSpells
	dw AIRuleNothingToDispel
	dw AIRuleMagicWallUseless
	dw AIRuleBarrier
	dw AIRuleResistEnemies
	dw AIRuleScriptedNoKill
	dw AIRuleBarrierNoBreath
	dw AIPenaltyImitated
	dw AIPenaltyAllImitating
	dw AIPenaltyDeMagicHelpsFoes
	dw AIBonusIfWeakResist
	dw AIBonusBoostUseful
	dw AIBonusLowerDefense
	dw AIBonusVsBlinded
	dw AIBonusVsBigSpells
	dw AIBonusAgilityGap
	dw AIBonusTransform
	dw AIBonusRobMagic
	dw AIBonusDeMagic
	dw AIBonusThickFog
	dw AIBonusMagicWall
	dw AIBonusResistCanAct
	dw AIBonusResistUnblinded
	dw AIBonusResistStopSpell
	dw AIBonusResistHasMP
	dw AIBonusResistDefense
	dw AIBonusResistAgility
	dw AIBonusResistPoison
	dw AIBonusResistCurse
	dw AIBonusResistDanceShut
	dw AIBonusResistMouthShut
	dw $0000

AIRulesHeal::
	dw AIRuleNoLatePrep
	dw AIRuleUsable
	dw AIRuleNumbOff
	dw AIRuleDeChaos
	dw AIRuleCurseOff
	dw AIRuleHealNeeded
	dw AIRuleAlliesParalyzed
	dw AIRuleNoBreathers
	dw AIRuleMouthsShut
	dw AIRuleSurge
	dw AIRuleNeedsAlly
	dw AIRuleAllIronized
	dw AIRuleNoneCanAct
	dw AIRuleSacrificeLowHP
	dw AIRuleNoEnemyMP
	dw AIRuleAntidote
	dw AIRuleNoneFallen
	dw AIRuleTargetsParalyzed
	dw AIBonusRevive
	dw AIBonusLastStand
	dw AIBonusAntidote
	dw AIBonusNumbOff
	dw AIBonusDeChaos
	dw AIBonusCurseOff
	dw AIHealUserBelow3Q
	dw AIHealUserBelowHalf
	dw AIHealUserBelowTenth
	dw AIHealUserAtOne
	dw AIHealAlliesBelow3Q
	dw AIHealAlliesBelowHalf
	dw AIHealAlliesBelowTenth
	dw AIHealAlliesAtOne
	dw AIHealGroup3Q
	dw AIHealGroupHalf
	dw AIHealGroupTenth
	dw AIHealGroupAtOne
	dw AIBonusVsBigSpells
	dw AIBonusProtectAlly
	dw AIBonusGuardWhenLow
	dw AIBonusSurge
	dw $0000

;@ def AIRuleOutIfAllHave(first: c, count: b, status: hl, mask: e)
;@ path: battle/ai/rules
;@ Rules the skill out (wAIPenalty = $FF) when every monster present among the `count` battle positions
;@ from `first` on already has one of the `mask` bits in its status byte (`status` points to the first
;@ position's byte; they are 8 apart): the effect would be wasted on all of them.
;@ test: first = rand(0, 5); count = rand(1, 3); status = 0xDB02 + first * 8
AIRuleOutIfAllHave::
;>@f for pos in range(first, first + count):
;>@c     if not CheckBattlerPresent(pos) and not mem[status] & mask:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, [hl]
	and e
;>         return                              # this one can still be hit by it
	ret z

.next
;=@f
	inc c
;>     status += 8
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	dec b
	jr nz, AIRuleOutIfAllHave
;> wAIPenalty = 0xFF                           # all of them have it already
	ld a, $ff
	ld [wAIPenalty], a
	ret


;@ def AIRuleOutIfAllAtMin(first: c, count: b, values: hl)
;@ path: battle/ai/rules
;@ Rules the skill out when every monster present among the `count` positions from `first` on has its
;@ 16-bit stat (`values` points to the first; 2 bytes apart) at the bottom. The two bytes are put
;@ together the wrong way round, so the test that passes is "the stat is 256" rather than "is 1".
;@ test: first = rand(0, 5); count = rand(1, 3); values = 0xDBE3 + first * 2
AIRuleOutIfAllAtMin::
;>@f for pos in range(first, first + count):
;>@c     if not CheckBattlerPresent(pos) and (mem[values] << 8 | mem[values + 1]) != 1:
	ld a, c
	call CheckBattlerPresent
	jr c, .absent

;=@c
	ld a, [hli]
	ld e, [hl]
	ld d, a
	dec de
	ld a, d
	or e
;>         return                              # this one can still be lowered
	ret nz

.next
;>@v     values += 2
	inc hl
;=@f
	inc c
	dec b
	jr nz, AIRuleOutIfAllAtMin
;> wAIPenalty = 0xFF
	ld a, $ff
	ld [wAIPenalty], a
	ret

.absent
;=@v
	inc hl
	jr .next


;@ def AIRuleOutIfNoneHas(first: c, count: b, status: hl, mask: e)
;@ path: battle/ai/rules
;@ Rules the skill out unless at least one monster present among the `count` positions from `first` on
;@ has one of the `mask` bits in its status byte (`status` points to the first; 8 bytes apart): a cure
;@ with nothing to cure.
;@ test: first = rand(0, 5); count = rand(1, 3); status = 0xDB02 + first * 8
AIRuleOutIfNoneHas::
;>@f for pos in range(first, first + count):
;>@c     if not CheckBattlerPresent(pos) and mem[status] & mask:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, [hl]
	and e
;>         return                              # there is something to do
	ret nz

.next
;=@f
	inc c
;>     status += 8
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	dec b
	jr nz, AIRuleOutIfNoneHas
;> wAIPenalty = 0xFF
	ld a, $ff
	ld [wAIPenalty], a
	ret


;@ def AIBonusIfFamilyPresent(first: c, count: b)
;@ path: battle/ai/rules
;@ Gives the skill a bonus of 20 (wAttackWeight) when the monster at battle position `first` belongs to
;@ family wBattleArg0 (byte 0 of its MonsterStats record). Meant to look at `count` positions, but its
;@ loop only counts b down, so only the first position is ever looked at.
;@ test: skip calls a routine in another bank
AIBonusIfFamilyPresent::
;> if not CheckBattlerPresent(first):
	ld a, c
	call CheckBattlerPresent
	jr c, .skip

;>@s     wMonSpecies = wBattlerSpecies[first]
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@s
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wMonSpecies], a
;>     GetMonsterStats()
	push bc
	ld hl, far_GetMonsterStats
	rst $10
	pop bc
;>     if wMonStats[0] == wBattleArg0:
	ld a, [wMonStats]
	ld hl, wBattleArg0
	cp [hl]
	jr z, .bonus

;>@b         AddCapped_57(addr(wAttackWeight), 20)
;>@r         return
;> return                                      # (the loop here only counts b down)
.skip
	inc c
	dec b
	jr nz, .skip
	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
;=@r
	ret


;@ def AIBonusIfAnyHas(first: c, count: b, status: hl, mask: d, bonus: e)
;@ path: battle/ai/rules
;@ Adds `bonus` to the skill's bonus (wAttackWeight, at most 255) when a monster present among the
;@ `count` positions from `first` on has one of the `mask` bits in its status byte (`status` points to
;@ the first; 8 bytes apart).
;@ test: first = rand(0, 5); count = rand(1, 3); status = 0xDB02 + first * 8
AIBonusIfAnyHas::
;>@f for pos in range(first, first + count):
;>@c     if not CheckBattlerPresent(pos) and mem[status] & mask:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, [hl]
	and d
	jr nz, .bonus

;>@b         AddCapped_57(addr(wAttackWeight), bonus)
;>@r         return
.next
;=@f
	inc c
;>     status += 8
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	dec b
	jr nz, AIBonusIfAnyHas
;> return
	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, e
	call AddCapped_57
;=@r
	ret


;@ def SumBattlerWords(first: c, count: b, values: hl)
;@ path: battle/ai/rules
;@ Adds up a 16-bit stat (`values` points to the first position's; 2 bytes apart) over the monsters
;@ present among the `count` positions from `first` on, into wSkillAmount, and counts them in
;@ wBattleArg0.
;@ test: first = rand(0, 5); count = rand(1, 3); values = 0xDBA3 + first * 2
SumBattlerWords::
;> wSkillAmount = 0
	xor a
	ld [wSkillAmount], a
	xor a
	ld [wSkillAmount + 1], a
;> wBattleArg0 = 0
	xor a
	ld [wBattleArg0], a

;>@f for pos in range(first, first + count):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wBattleArg0 += 1
	ld a, [wBattleArg0]
	inc a
	ld [wBattleArg0], a
;>@s         wSkillAmount = (wSkillAmount + mem16[values]) & 0xFFFF
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@s
	ld a, [wSkillAmount]
	ld e, a
	ld a, [wSkillAmount + 1]
	ld d, a
	ld a, e
	add l
;=@s
	ld e, a
	ld a, d
	adc h
	ld d, a
;=@s
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a
	pop hl

.next
;>     values += 2
	inc hl
	inc hl
;=@f
	inc c
	dec b
	jr nz, .loop

	ret


;@ def GetSkillResistSlot() -> (d, e, c, b)
;@ path: battle/ai/rules
;@ Reads which resistance skill wSkillId is met with (record +5) and turns the number into its place in a
;@ monster's packed resistances (wBattlerResist, four 2-bit values per byte): byte d = number >> 2, pair
;@ e = number & 3. Also returns c = the first position of the side facing the user and b = 3.
;@ test: skip calls a routine in another bank
GetSkillResistSlot::
;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 5                             # record +5: the resistance
	ld a, $05
	ld [wBattleArg2], a
;> GetSkillWord()
	ld hl, far_GetSkillWord
	rst $10
;> pair = wBattleArg0 & 3
	ld a, [wBattleArg0]
	and $03
	ld e, a
;> byte = (wBattleArg0 >> 2) & 0x0F
	ld a, [wBattleArg0]
	rrca
	rrca
	and $0f
	ld d, a
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> return (byte, pair, side, 3)
	ld b, $03
	ret


;@ def AddCapped_57(p: hl, n: b)
;@ path: battle/ai/rules
;@ Adds `n` to the byte at `p`, stopping at 255.
;@ test: p = rand(0xC000, 0xDFFF)
AddCapped_57::
;> total = mem[p] + n
	ld a, [hl]
	add b
;> mem[p] = total & 0xFF
	ld [hl], a
;> if total < 0x100: return
	ret nc
;> mem[p] = 0xFF
	ld a, $ff
	ld [hl], a
	ret

;@ def WordTableEntry_57(index: a, table: hl) -> hl
;@ path: system/memory
;@ Entry `index` of a table of 16-bit words.
;@ test: table = rand(0xC000, 0xDE00)
WordTableEntry_57::
;>@w return mem16[u16(table + (2 * index & 0xFF))]   # (2 * index wraps at 8 bits)
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@w
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret



;@ def IsImitating(pos: c) -> a
;@ path: battle/ai/rules
;@ Nonzero when the monster at battle position `pos` is imitating (Imitate, bit 3 of status byte 6).
;@ test: pos = rand(0, 7)
IsImitating::
;> return mem[AddEightTimes(pos, addr(wBattlerStatus6))] & 0x08
	ld a, c
	ld hl, wBattlerStatus6
	call AddEightTimes
	ld a, [hl]
	and $08
	ret


;@ def GetBaseAgilityBC(pos: a) -> bc
;@ path: battle/ai/rules
;@ The agility of battle position `pos` without the changes of the battle, like CalcBaseAgility. In a
;@ link battle the link flag is tested where the position should be, so the record of party position
;@ wLinkActive & 3 is read instead.
;@ test: skip calls a routine in another bank
GetBaseAgilityBC::
;> key = pos
	push hl
	ld b, a
;>@l if wLinkActive: key = wLinkActive & 3    # a slip: the link flag stands in for the position
	ld a, [wLinkActive]
	or a
	jr nz, .link

;>@t if (key & 3) == 3 or (not wLinkActive and pos >= 3):  # from a monster template
	ld a, b
	cp $03
	jr c, .party

;>@id     id = 0x100 | wBattlerSpecies[pos] if (key & 3) == 3 else WordTableEntry_57(pos - 4, addr(wEncSpecies))
	and $03
	cp $03
	jr z, .called

;=@id
	ld a, b
	sub $04
	ld hl, wEncSpecies
	call WordTableAddr_57
	ld a, [hli]
	ld h, [hl]
;=@id
	ld l, a

.template
;>     wNewMonId = id
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>     agility = wTemplateAgility
	ld a, [wTemplateAgility]
	ld c, a
	ld a, [wTemplateAgility + 1]
	ld b, a
	jr .done

;> else:
.link
;=@l
	and $03
;=@t
	cp $03
	jr z, .called

.party
;>     agility = GetPartyMonsterWord(key, addr(wMonAgility))
	ld hl, wMonAgility
	call GetPartyMonsterWord
	jr .done

.called
;=@id
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
;=@id
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .template

.done
;> return agility
	pop hl
	ret


;@ def IsZeroOrOne(value: hl) -> carry
;@ path: battle/ai/rules
;@ Carry when `value` is 0 or 1.
IsZeroOrOne::
;>@r return value <= 1
	ld a, h
	or a
	jr nz, .no

;=@r
	ld a, l
	or a
	jr z, .yes

	cp $01
	jr nz, .no

.yes
;=@r
	scf
	ret

.no
;=@r
	ld a, $02
	cp $01
	ret


;@ def AIRuleOut()
;@ path: battle/ai/rules
;@ Rules the skill being judged out: wAIPenalty = $FF.
AIRuleOut::
;> wAIPenalty = 0xFF
	ld a, $ff
	ld [wAIPenalty], a
	ret

;@ def WordTableAddr_57(index: a, table: hl) -> hl
;@ path: system/memory
;@ Address of entry `index` of a table of 16-bit words (or `table` + 2 * `index`).
WordTableAddr_57::
;>@r return u16(table + (2 * index & 0xFF))
	add a
	add l
	ld l, a
;=@r
	ld a, $00
	adc h
	ld h, a
	ret



;@ def AIRuleUsable()
;@ path: battle/ai/rules
;@ First rule of every list: rules the skill out when the user cannot use it now - too little MP for its
;@ cost (record +4), a spell (record +7 bit 6) while its spells are stopped (StopSpell), a dance (bit 5)
;@ while its dancing is stopped (DanceShut), a breath (bit 4) while its mouth is shut (MouthShut), or a
;@ spell or ThickFog while the fog lies on its side (wSideFlags bit 3).
;@ test: skip calls a routine in another bank
AIRuleUsable::
;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 4                             # record +4: MP cost
	ld a, $04
	ld [wBattleArg2], a
;> GetSkillWord()
	ld hl, far_GetSkillWord
	rst $10
;>@m if wBattleArg0 and GetBattlerMP(wSkillUser) < wBattleArg0:
	ld a, [wBattleArg0]
	or a
	jr z, .spell

;=@m
	ld c, a
	ld b, $00
	ld a, [wSkillUser]
	call GetBattlerMP
	call CompareHLBC
	jr nc, .spell

;>     AIRuleOut()
	call AIRuleOut

.spell
;>@s if wSkillMsgMode & 0x40 and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus1))] & 0x01:  # StopSpell
	ld a, [wSkillMsgMode]
	bit 6, a
	jr z, .dance

;=@s
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	jr z, .dance

;>     AIRuleOut()
	call AIRuleOut

.dance
;>@d if wSkillMsgMode & 0x20 and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus1))] & 0x40:  # DanceShut
	ld a, [wSkillMsgMode]
	bit 5, a
	jr z, .breath

;=@d
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 6, [hl]
	jr z, .breath

;>     AIRuleOut()
	call AIRuleOut

.breath
;>@b if wSkillMsgMode & 0x10 and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus1))] & 0x80:  # MouthShut
	ld a, [wSkillMsgMode]
	bit 4, a
	jr z, .fog

;=@b
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	jr z, .fog

;>     AIRuleOut()
	call AIRuleOut

.fog
;>@f if wSkillId != 0x83 and not wSkillMsgMode & 0x40:   # neither ThickFog nor a spell
	ld a, [wSkillId]
	cp $83
	jr z, .side

;=@f
	ld a, [wSkillMsgMode]
	bit 6, a
;>     return
	ret z

.side
;>@p side = addr(wSideFlags) + (1 if wSkillUser >= 4 else 0)
	ld a, [wSkillUser]
	cp $04
	jr c, .own

;=@p
	ld hl, wSideFlags + 1
	jr .test

.own
;=@p
	ld hl, wSideFlags

.test
;> if not mem[side] & 0x08: return              # no fog on the user's side
	bit 3, [hl]
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNotActive()
;@ path: battle/ai/rules
;@ Rules out a skill whose effect the user has already: ChargeUP ($41) while it charges (status byte 4
;@ bits 0-1), Focus ($54) while it is focused (bits 6-7), SuckAll ($8F) while its mouth is open (status
;@ byte 6 bit 1), MagicBack or Bounce ($27/$28) while it reflects (status byte 2 bits 1 and 5), and
;@ Barrier ($24) when every monster of its side has the veil of light (status byte 2 bit 2).
;@ test: wSkillUser = rand(0, 7)
AIRuleNotActive::
;>@c if wSkillId == 0x41 and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus4))] & 0x03:   # ChargeUP
	ld a, [wSkillId]
	cp $41
	jr nz, .focus

;=@c
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $03
	jr z, .focus

;>     AIRuleOut()
	call AIRuleOut

.focus
;>@f if wSkillId == 0x54 and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus4))] & 0xC0:   # Focus
	ld a, [wSkillId]
	cp $54
	jr nz, .suckAll

;=@f
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, .suckAll

;>     AIRuleOut()
	call AIRuleOut

.suckAll
;>@s if wSkillId == 0x8F and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus6))] & 0x02:   # SuckAll
	ld a, [wSkillId]
	cp $8f
	jr nz, .reflect

;=@s
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 1, [hl]
	jr z, .reflect

;>     AIRuleOut()
	call AIRuleOut

.reflect
;>@r if wSkillId in (0x27, 0x28) and mem[AddEightTimes(wSkillUser, addr(wBattlerStatus2))] & 0x22:  # MagicBack, Bounce
	ld a, [wSkillId]
	cp $27
	jr z, .reflects

	cp $28
	jr nz, .barrier

.reflects
;=@r
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	jr z, .barrier

;>     AIRuleOut()
	call AIRuleOut

.barrier
;> if wSkillId != 0x24: return                  # Barrier
	ld a, [wSkillId]
	cp $24
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus2)), 0x04)
	ld b, $03
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld e, $04
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleSeverePoison()
;@ path: battle/ai/rules
;@ PoisonHit, PoisonGas and PoisonAir ($67, $6C, $6D) are ruled out when every enemy is severely poisoned
;@ already (status byte 0 bit 1).
;@ test: wSkillUser = rand(0, 7)
AIRuleSeverePoison::
;> if not (wSkillId == 0x67 or 0x6C <= wSkillId < 0x6E):
	ld a, [wSkillId]
	cp $6e
	ret nc

	cp $67
	jr z, .check

	cp $6c
;>     return
	ret c

.check
;> side = (wSkillUser & 4) ^ 4                  # the other side
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x02)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld e, $02
	call AIRuleOutIfAllHave
	ret


;@ def AIRulePoison()
;@ path: battle/ai/rules
;@ PoisonHit and PoisonGas ($67, $6C) are ruled out when every enemy is poisoned already (status byte 0
;@ bits 0-1).
;@ test: wSkillUser = rand(0, 7)
AIRulePoison::
;> if wSkillId not in (0x67, 0x6C): return
	ld a, [wSkillId]
	cp $67
	jr z, .check

	cp $6c
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x03)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld e, $03
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleTargetsAsleep()
;@ path: battle/ai/rules
;@ Sleep, SleepAll, Ironize, NapAttack, SleepAir, Ahhh, SandStorm, Radiant, LureDance to WarCry and
;@ Ironize ($DC) are ruled out when every enemy is asleep (status byte 0 bits $8C).
;@ test: wSkillUser = rand(0, 7)
AIRuleTargetsAsleep::
;>@k if not (wSkillId in (0x15, 0x16, 0x2A, 0x68, 0x6A, 0x70, 0x72, 0x73, 0xDC) or 0x78 <= wSkillId < 0x7E):
	ld a, [wSkillId]
	cp $15
	ret c

	cp $17
	jr c, .check

;=@k
	cp $2a
	jr z, .check

	cp $68
	jr z, .check

	cp $6a
	jr z, .check

;=@k
	cp $70
	ret c

	cp $71
	ret z

	cp $74
	jr c, .check

;=@k
	cp $78
	ret c

	cp $7e
	jr c, .check

	cp $dc
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x8C)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld e, $8c
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleTargetsParalyzed()
;@ path: battle/ai/rules
;@ Most status skills aimed at the enemies (Sleep to PanicAll, Sap to Bounce, Ironize, NapAttack to
;@ PalsyAir, PaniDance, Ahhh, SandStorm, Radiant, SideStep to DeMagic, Cover to MouthShut, everything
;@ from Meditate to GigaSlash, and Ironize $DC) are ruled out when every enemy is paralyzed (status byte
;@ 0 bit 6).
;@ test: wSkillUser = rand(0, 7)
AIRuleTargetsParalyzed::
;>@k if not (0x15 <= wSkillId < 0x1A or 0x1C <= wSkillId < 0x2B and wSkillId != 0x29 or 0x68 <= wSkillId < 0x6C or wSkillId in (0x6E, 0x70, 0x72, 0x73, 0xDC) or 0x77 <= wSkillId < 0x81 or 0x88 <= wSkillId < 0xDA):
	ld a, [wSkillId]
	cp $15
	ret c

	cp $1a
	jr c, .check

;=@k
	cp $1c
	ret c

	cp $29
	ret z

	cp $2b
	jr c, .check

;=@k
	cp $68
	ret c

	cp $6c
	jr c, .check

	cp $6e
	jr z, .check

;=@k
	cp $70
	ret c

	cp $71
	ret z

	cp $74
	jr c, .check

;=@k
	cp $77
	ret c

	cp $81
	jr c, .check

	cp $88
	ret c

;=@k
	cp $93
	jr c, .check

	cp $da
	jr c, .check

	cp $dc
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x40)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld e, $40
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleSurround()
;@ path: battle/ai/rules
;@ Surround ($18) is ruled out when every enemy is wrapped in the illusion already (status byte 1 bit 1).
;@ test: wSkillUser = rand(0, 7)
AIRuleSurround::
;> if wSkillId != 0x18: return
	ld a, [wSkillId]
	cp $18
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus1)), 0x02)
	ld b, $03
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld e, $02
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleTargetsConfused()
;@ path: battle/ai/rules
;@ PanicAll, Ironize, PaniDance, Life ($DA) and Ironize ($DC) are ruled out when every enemy is confused
;@ already (status byte 0 bit 4).
;@ test: wSkillUser = rand(0, 7)
AIRuleTargetsConfused::
;>@k if wSkillId not in (0x19, 0x2A, 0x6E, 0xDA, 0xDC): return
	ld a, [wSkillId]
	cp $19
	jr z, .check

	cp $2a
	jr z, .check

;=@k
	cp $6e
	jr z, .check

	cp $da
	jr z, .check

	cp $dc
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x10)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld e, $10
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleDefenseDown()
;@ path: battle/ai/rules
;@ Sap and Defence ($1C, $1D) are ruled out when every enemy's defense is at the bottom (see
;@ AIRuleOutIfAllAtMin).
;@ test: wSkillUser = rand(0, 7)
AIRuleDefenseDown::
;> if wSkillId not in (0x1C, 0x1D): return
	ld a, [wSkillId]
	cp $1c
	jr z, .check

	cp $1d
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@v AIRuleOutIfAllAtMin(side, 3, addr(wBattlerDefense) + side * 2)
	ld b, $03
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
;=@v
	ld a, $00
	adc h
	ld h, a
	call AIRuleOutIfAllAtMin
	ret


;@ def AIRuleAgilityDown()
;@ path: battle/ai/rules
;@ Slow and SlowAll ($20, $21) are ruled out when every enemy's agility is at the bottom (see
;@ AIRuleOutIfAllAtMin).
;@ test: wSkillUser = rand(0, 7)
AIRuleAgilityDown::
;> if wSkillId not in (0x20, 0x21): return
	ld a, [wSkillId]
	cp $20
	jr z, .check

	cp $21
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@v AIRuleOutIfAllAtMin(side, 3, addr(wBattlerAgility) + side * 2)
	ld b, $03
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
;=@v
	ld a, $00
	adc h
	ld h, a
	call AIRuleOutIfAllAtMin
	ret


;@ def AIRuleTargetsHeld()
;@ path: battle/ai/rules
;@ Ironize, Ahhh, LureDance to WarCry and Ironize ($DC) are ruled out when every enemy is held by one of
;@ those effects already (status byte 3 bits 0-5: frozen, lured, stumbling, licked, shocked, feeling good).
;@ test: wSkillUser = rand(0, 7)
AIRuleTargetsHeld::
;>@k if not (wSkillId in (0x2A, 0x70, 0xDC) or 0x78 <= wSkillId < 0x7E):
	ld a, [wSkillId]
	cp $2a
	jr z, .check

	cp $70
	jr z, .check

;=@k
	cp $78
	ret c

	cp $7e
	jr c, .check

	cp $dc
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfAllHave(side, 3, AddEightTimes(side, addr(wBattlerStatus3)), 0x3F)
	ld b, $03
	ld hl, wBattlerStatus3
	call AddEightTimes
	ld e, $3f
	call AIRuleOutIfAllHave
	ret


;@ def AIRuleDefenseUp()
;@ path: battle/ai/rules
;@ Upper and Increase ($1E, $1F) are ruled out unless a monster of the user's side can still have its
;@ defense raised: below its limit (the defense without battle changes, CalcBaseDefense, times 4 for a
;@ party monster - positions 0-2, in a link battle also 4-6 - and times 2 for the others) and below 999.
;@ test: skip calls a routine in another bank
AIRuleDefenseUp::
;> if wSkillId not in (0x1E, 0x1F): return
	ld a, [wSkillId]
	cp $1e
	jr z, .check

	cp $1f
	ret nz

.check
;> wBattleArg0 = wSkillUser & 4                # the user's side
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg0], a
;>@l for k in range(3):
	ld b, $03

.loop
	push bc
;>     if not CheckBattlerPresent(wBattleArg0):
	ld a, [wBattleArg0]
	call CheckBattlerPresent
	jr c, .next

;>         wBattleTemp = wBattleArg0
	ld a, [wBattleArg0]
	push hl
	ld [wBattleTemp], a
;>         CalcBaseDefense()
	ld hl, far_CalcBaseDefense
	rst $10
;>         limit = wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
;>         defense = GetBattlerDefense(wBattleArg0)
	ld a, [wBattleArg0]
	call GetBattlerDefense
;>@x         if (wBattleArg0 & 3) != 3 if wLinkActive else wBattleArg0 < 3:   # a party monster
	ld a, [wLinkActive]
	or a
	jr z, .notLink

;=@x
	ld a, [wBattleArg0]
	and $03
	cp $03
	jr z, .double

	jr .four

.notLink
;=@x
	ld a, [wBattleArg0]
	cp $03
	jr nc, .double

.four
;>             limit = (limit << 1) & 0xFFFF
	sla c
	rl b

.double
;>         limit = (limit << 1) & 0xFFFF
	sla c
	rl b
;>@q         if defense < limit and defense < 999:
	call CompareHLBC
	jr nc, .next

;=@q
	ld bc, $03e7
	call CompareHLBC
	jr nc, .next

;>             return                          # this one can still be raised
	pop bc
	ret

.next
;>     wBattleArg0 += 1
	ld hl, wBattleArg0
	inc [hl]
;=@l
	pop bc
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleAgilityUp()
;@ path: battle/ai/rules
;@ Speed and SpeedUp ($22, $23) are ruled out unless a monster of the user's side can still have its
;@ agility raised: below its limit (the agility without battle changes, GetBaseAgilityBC, times 4 for a
;@ party monster and times 2 for the others) and below 511.
;@ test: skip calls a routine in another bank
AIRuleAgilityUp::
;> if wSkillId not in (0x22, 0x23): return
	ld a, [wSkillId]
	cp $22
	jr z, .check

	cp $23
	ret nz

.check
;> wBattleArg0 = wSkillUser & 4                # the user's side
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg0], a
;>@l for k in range(3):
	ld b, $03

.loop
	push bc
;>     if not CheckBattlerPresent(wBattleArg0):
	ld a, [wBattleArg0]
	call CheckBattlerPresent
	jr c, .next

;>         limit = GetBaseAgilityBC(wBattleArg0)
	ld a, [wBattleArg0]
	call GetBaseAgilityBC
;>         agility = WordTableEntry_57(wBattleArg0, addr(wBattlerAgility))
	ld a, [wBattleArg0]
	ld hl, wBattlerAgility
	call WordTableEntry_57
;>@x         if (wBattleArg0 & 3) != 3 if wLinkActive else wBattleArg0 < 3:   # a party monster
	ld a, [wLinkActive]
	or a
	jr z, .notLink

;=@x
	ld a, [wBattleArg0]
	and $03
	cp $03
	jr z, .double

	jr .four

.notLink
;=@x
	ld a, [wBattleArg0]
	cp $03
	jr nc, .double

.four
;>             limit = (limit << 1) & 0xFFFF
	sla c
	rl b

.double
;>         limit = (limit << 1) & 0xFFFF
	sla c
	rl b
;>@q         if agility < limit and agility < 511:
	call CompareHLBC
	jr nc, .next

;=@q
	ld bc, $01ff
	call CompareHLBC
	jr nc, .next

;>             return
	pop bc
	ret

.next
;>     wBattleArg0 += 1
	ld hl, wBattleArg0
	inc [hl]
;=@l
	pop bc
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNumbOff()
;@ path: battle/ai/rules
;@ NumbOff ($34) is ruled out when no monster of the user's side is paralyzed or asleep (status byte 0
;@ bits 6-7).
;@ test: wSkillUser = rand(0, 7)
AIRuleNumbOff::
;> if wSkillId != 0x34: return
	ld a, [wSkillId]
	cp $34
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIRuleOutIfNoneHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0xC0)
	ld hl, wBattlerStatus
	call AddEightTimes
	ld b, $03
	ld e, $c0
	call AIRuleOutIfNoneHas
	ret


;@ def AIRuleDeChaos()
;@ path: battle/ai/rules
;@ DeChaos ($35) is ruled out when no monster of the user's side is confused (status byte 0 bit 4).
;@ test: wSkillUser = rand(0, 7)
AIRuleDeChaos::
;> if wSkillId != 0x35: return
	ld a, [wSkillId]
	cp $35
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIRuleOutIfNoneHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x10)
	ld hl, wBattlerStatus
	call AddEightTimes
	ld b, $03
	ld e, $10
	call AIRuleOutIfNoneHas
	ret


;@ def AIRuleCurseOff()
;@ path: battle/ai/rules
;@ CurseOff ($36) is ruled out when no monster of the user's side is cursed (status byte 0 bit 5).
;@ test: wSkillUser = rand(0, 7)
AIRuleCurseOff::
;> if wSkillId != 0x36: return
	ld a, [wSkillId]
	cp $36
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIRuleOutIfNoneHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x20)
	ld hl, wBattlerStatus
	call AddEightTimes
	ld b, $03
	ld e, $20
	call AIRuleOutIfNoneHas
	ret


;@ def AIRuleHealNeeded()
;@ path: battle/ai/rules
;@ The healing skills (Heal to HealUsAll, $2B-$2F) and Hustle ($94) are ruled out when every monster of
;@ the user's side has more than 3/4 of its HP; Meditate ($93) when the user has.
;@ test: wSkillUser = rand(0, 7)
AIRuleHealNeeded::
;> if wSkillId < 0x2B: return
	ld a, [wSkillId]
	cp $2b
	ret c

;>@m if wSkillId == 0x93:                       # Meditate heals the user only
	cp $93
	jr z, .self

;>@m1     wSkillAmount = addr(wBattlerHP) + 2 * wSkillUser
;>@m2     wTargetScores = addr(wBattlerMaxHP) + 2 * wSkillUser
;>@m3     if HPAboveThreeQuarters(): AIRuleOut()
;>@m4     return
;> if wSkillId != 0x94 and wSkillId >= 0x30: return
	cp $94
	jr z, .group

	cp $30
	ret nc

.group
;> side = wSkillUser & 4
	ld b, $03
	ld a, [wSkillUser]
	and $04
	ld c, a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * side       # the pointers HPAboveThreeQuarters reads
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * side
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a

;>@l for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HPAboveThreeQuarters():
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	call HPAboveThreeQuarters
;>         return                              # someone to heal
	ret nc

.next
;>@s     wSkillAmount += 2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	inc hl
	inc hl
;=@s
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@t     wTargetScores += 2
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	inc hl
	inc hl
;=@t
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;=@l
	inc c
	dec b
	jr nz, .loop

.out
;> AIRuleOut()                                 # nobody needs it
	call AIRuleOut
	ret

.self
;=@m1
	ld a, [wSkillUser]
	ld c, a
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@m1
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@m1
	ld [wSkillAmount + 1], a
;=@m2
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@m2
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@m2
	ld [wTargetScores + 1], a
;=@m3
	ld a, c
	call HPAboveThreeQuarters
	jr c, .out

;=@m4
	ret

	ret


;@ def AIRuleAlliesParalyzed()
;@ path: battle/ai/rules
;@ Sacrifice, Farewell and LifeDance ($14, $32, $96) are ruled out when the user has allies in the fight
;@ and every one of them is paralyzed (status byte 0 bit 6).
;@ test: wSkillUser = rand(0, 7)
AIRuleAlliesParalyzed::
;>@k if wSkillId not in (0x14, 0x32, 0x96):
	ld a, [wSkillId]
	cp $14
	jr z, .check

	cp $32
	jr z, .check

;=@k
	cp $96
;>     return
	ret nz

.check
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a
;>@o allies = 0
;>@f for pos in range(side, side + 3):
	ld b, $03
;=@o
	ld e, $00

.loop
;>     if pos != user and not CheckBattlerPresent(pos):
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	jr c, .next

;>         allies += 1
	inc e
;>         if not mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x40: return   # one can still act
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if allies == 0: return
	ld a, e
	or a
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNoBreathers()
;@ path: battle/ai/rules
;@ Only for a smart monster (intelligence class 2): Barrier, TailWind, StormWind, SuckAll and MouthShut
;@ ($24, $8A, $8B, $8F, $92), which guard against breaths, are ruled out when no enemy knows a breath
;@ (HasBreathSkill).
;@ test: wSkillUser = rand(0, 7)
AIRuleNoBreathers::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if wSkillId not in (0x24, 0x8A, 0x8B, 0x8F, 0x92):
	ld a, [wSkillId]
	cp $24
	jr z, .check

	cp $8a
	jr z, .check

;=@k
	cp $8b
	jr z, .check

	cp $8f
	jr z, .check

	cp $92
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@f for pos in range(side, side + 3):
	ld b, $03
	ld d, $10

.loop
;>     if not CheckBattlerPresent(pos) and HasBreathSkill(pos): return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	call HasBreathSkill
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleSuckAir()
;@ path: battle/ai/rules
;@ SuckAir ($43) is ruled out unless the user knows a breath to blow afterwards (FireAir to WhiteAir,
;@ $5C-$63).
;@ test: wSkillUser = rand(0, 7)
AIRuleSuckAir::
;> if wSkillId != 0x43: return
	ld a, [wSkillId]
	cp $43
	ret nz

;>@p p = addr(wBattlerSkills) + 1 + wSkillUser * 16    # its skill numbers, every second byte
	ld a, [wSkillUser]
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;>@f for k in range(8):
	ld b, $08

.loop
;>     skill = mem[p]
	ld a, [hli]
;>     if skill == 0xFF: break
	cp $ff
	jr z, .out

;>     if 0x5C <= skill < 0x64: return
	cp $5c
	jr c, .next

	cp $64
	ret c

.next
;>     p += 2
	inc hl
;=@f
	dec b
	jr nz, .loop

.out
;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleTargetsReflect()
;@ path: battle/ai/rules
;@ The spells Firebal to Defeat, Sleep, StopSpell to PanicAll ($03-$19 but $12 and $15), Defence, SlowAll
;@ and Life ($1D, $21, $DA) are ruled out when an enemy present reflects (Bounce or MagicBack, status
;@ byte 2 bits 1 and 5).
;@ test: wSkillUser = rand(0, 7)
AIRuleTargetsReflect::
;>@k if not (0x03 <= wSkillId < 0x1A and wSkillId not in (0x12, 0x15) or wSkillId in (0x1D, 0x21, 0xDA)):
	ld a, [wSkillId]
	cp $03
	ret c

	cp $12
	ret z

;=@k
	cp $15
	ret z

	cp $1d
	jr z, .check

	cp $21
	jr z, .check

;=@k
	cp $da
	jr z, .check

	cp $1a
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@s status = AddEightTimes(side, addr(wBattlerStatus2))
;>@f for pos in range(side, side + 3):
	ld b, $03
;=@s
	ld hl, wBattlerStatus2
	call AddEightTimes

.loop
;>@c     if not CheckBattlerPresent(pos) and mem[status] & 0x22:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, [hl]
	and $22
	jr nz, .out

;>@o         AIRuleOut()
;>@r         return
.next
;=@f
	inc c
;>     status += 8
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	dec b
	jr nz, .loop

	ret

.out
;=@o
	call AIRuleOut
;=@r
	ret


;@ def AIRuleBreathBlocked()
;@ path: battle/ai/rules
;@ The breaths FireAir to WhiteAir and SleepAir to PoisonAir ($5C-$63, $6A-$6D) are ruled out when the
;@ enemies' side has a wind blowing or SuckAll used (wSideFlags bits 5-6), or an enemy present has a
;@ wind of its own (TailWind; status byte 2 bits 3 and 6) or its mouth open for SuckAll (status byte 6
;@ bit 1).
;@ test: wSkillUser = rand(0, 7)
AIRuleBreathBlocked::
;>@k if not (0x5C <= wSkillId < 0x64 or 0x6A <= wSkillId < 0x6E):
	ld a, [wSkillId]
	cp $5c
	ret c

	cp $64
	jr c, .check

;=@k
	cp $6e
	ret nc

	cp $6a
;>     return
	ret c

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@w if wSideFlags[side >> 2] & 0x60 or any(not CheckBattlerPresent(pos) and (mem[AddEightTimes(pos, addr(wBattlerStatus2))] & 0x48 or mem[AddEightTimes(pos, addr(wBattlerStatus6))] & 0x02) for pos in range(side, side + 3)):
	ld a, c
	srl a
	srl a
	ld hl, wSideFlags
	add l
	ld l, a
;=@w
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $60
	jr nz, .out

;>@o     AIRuleOut()
.loop
;=@w
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@w
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
;=@w
	ld a, [hli]
	inc hl
	inc hl
	inc hl
	and $48
	jr nz, .out

;=@w
	bit 1, [hl]
	jr nz, .out

.next
;=@w
	inc c
	dec b
	jr nz, .loop

	ret

.out
;=@o
	call AIRuleOut
	ret


;@ def AIPenaltyIfGuarded()
;@ path: battle/ai/rules
;@ Only for a smart monster: a skill with bit 7 of its record byte 7 gets a penalty of 20 (wAIPenalty)
;@ when an enemy present is dodging (Dodge, status byte 6 bit 5) or stands in a Defence or BladeD stance
;@ (status byte 7 bits 0 and 2). After a missing position the status pointer is one byte off.
;@ test: wSkillUser = rand(0, 7)
AIPenaltyIfGuarded::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> if not wSkillMsgMode & 0x80: return
	ld a, [wSkillMsgMode]
	bit 7, a
	ret z

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@s p = AddEightTimes(side, addr(wBattlerStatus6))
;>@f for pos in range(side, side + 3):
	ld b, $03
;=@s
	ld hl, wBattlerStatus6
	call AddEightTimes

.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@d         if mem[p] & 0x20 or mem[p + 1] & 0x05:
	bit 5, [hl]
	jr nz, .penalty

	inc hl
	ld a, [hl]
	and $05
	jr nz, .penalty

;>@p             AddCapped_57(addr(wAIPenalty), 20)
;>@r             return
;>         p += 1
.next
;=@f
	inc c
;>     p += 7
	ld a, $07
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@f
	dec b
	jr nz, .loop

	ret

.penalty
;=@p
	ld hl, wAIPenalty
	ld b, $14
	call AddCapped_57
;=@r
	ret


;@ def AIBonusIfWeakResist()
;@ path: battle/ai/rules
;@ A skill met with a resistance (record +5 not 0) gets a bonus of 20 when the enemies present resist it
;@ at level 1 or less on average: the sum of their levels (wItemMsgGroup) is at most their number
;@ (wBattlerReload; both bytes serve as scratch here).
;@ test: skip calls a routine in another bank
AIBonusIfWeakResist::
;> byte, pair, side, count = GetSkillResistSlot()
	call GetSkillResistSlot
;> if wBattleArg0 == 0: return                 # no resistance number
	ld a, [wBattleArg0]
	or a
	ret z

;> wItemMsgGroup = 0
;> wBattlerReload = 0
	xor a
	ld hl, wItemMsgGroup
	ld [hli], a
	ld [hl], a

;>@f for pos in range(side, side + count):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wBattlerReload += 1
	ld hl, wBattlerReload
	inc [hl]
;>         wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;>         wBattleArg0 = byte
	ld a, d
	ld [wBattleArg0], a
;>         GetResistByte()
	push de
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
	pop de
;>         wItemMsgGroup = (wItemMsgGroup + (ResistPairBits(pair) & 3)) & 0xFF
	call ResistPairBits
	and $03
	ld hl, wItemMsgGroup
	add [hl]
	ld [hl], a

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleAllImmune()
;@ path: battle/ai/rules
;@ Rules the skill out when every enemy present resists it at level 3 (immune).
;@ test: skip calls a routine in another bank
AIRuleAllImmune::
;> byte, pair, side, count = GetSkillResistSlot()
	call GetSkillResistSlot

;>@f for pos in range(side, side + count):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;>         wBattleArg0 = byte
	ld a, d
	ld [wBattleArg0], a
;>         GetResistByte()
	push de
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
	pop de
;>         if (ResistPairBits(pair) & 3) != 3: return
	call ResistPairBits
	and $03
	cp $03
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> pass                                        # (adds a leftover value to wItemMsgGroup, unused here)
	ld hl, wItemMsgGroup
	add [hl]
	ld [hl], a
;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIBonusSlayer()
;@ path: battle/ai/rules
;@ The cuts that hit one family harder get a bonus of 20 when the first enemy position holds that
;@ family (AIBonusIfFamilyPresent): DrakSlash dragons (1), BeastCut beasts (2), BirdBlow birds (3),
;@ DevilCut devils (6), ZombieCut and MultiCut zombies (7), CleanCut materials (8), SmashLime slimes (0),
;@ ShellDodge bugs (5), Branching plants (4). Massacre, EvilSlash and MetalCut get it when an enemy
;@ present has type bit 0 (wBattlerTypeBits).
;@ test: skip calls a routine in another bank
AIBonusSlayer::
;>@k if not (0x3F <= wSkillId < 0x41 or 0x48 <= wSkillId < 0x50 or 0xD6 <= wSkillId < 0xD9): return
	ld a, [wSkillId]
	cp $3f
	ret c

;>@i index = 0 if wSkillId < 0x41 else wSkillId - 0x48 if wSkillId < 0x50 else wSkillId - 0xD6 + 8
	cp $41
	jp c, .metal

;=@k
	cp $48
	ret c

	cp $50
	jr c, .cuts

;=@k
	cp $d6
	ret c

	cp $d9
	ret nc

;=@i
	ld a, [wSkillId]
	sub $d6
	add $08
	jr .dispatch

.cuts
;=@i
	ld a, [wSkillId]
	sub $48

.dispatch
;> if index != 0:
	rst $00

	dw .metal
	dw .dragon
	dw .beast
	dw .bird
	dw .devil
	dw .zombie
	dw .material
	dw .zombie
	dw .slime
	dw .bug
	dw .plant

.slime
;>@s     side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@n     wBattleArg0 = (1, 2, 3, 6, 7, 8, 7, 0, 5, 4)[index - 1]     # the family
	ld a, $00
	ld [wBattleArg0], a
;>@c     AIBonusIfFamilyPresent(side, 3)
	call AIBonusIfFamilyPresent
	ret

.dragon
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $01
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.beast
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $02
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.bird
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $03
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.bug
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $05
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.plant
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $04
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.devil
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $06
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.zombie
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $07
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

.material
;=@s
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $08
	ld [wBattleArg0], a
;=@c
	call AIBonusIfFamilyPresent
	ret

;> else:                                       # Massacre, EvilSlash, MetalCut
.metal
;>     side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@f     for pos in range(side, side + 3):
.metalLoop
;>@m         if not CheckBattlerPresent(pos) and wBattlerTypeBits[pos] & 0x01:
	ld a, c
	call CheckBattlerPresent
	jr c, .metalNext

;=@m
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	bit 0, [hl]
	jr nz, .metalBonus

;>@b             AddCapped_57(addr(wAttackWeight), 20)
;>@r             return
.metalNext
;=@f
	inc c
	dec b
	jr nz, .metalLoop

	ret

.metalBonus
;=@b
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
;=@r
	ret

	ret


;@ def AIBonusAttackVsDefense()
;@ path: battle/ai/rules
;@ A physical attack (IsPhysicalSkill) gets 10 when the user's attack is at least the enemies' average
;@ defense (AverageEnemyDefense, which does not work out a real average), and 5 more when it is at least
;@ the lowest defense among the enemies present.
;@ test: wSkillUser = rand(0, 7)
AIBonusAttackVsDefense::
;> if not IsPhysicalSkill(): return
	call IsPhysicalSkill
	ret nc

;> AverageEnemyDefense()
	call AverageEnemyDefense
;>@a if GetBattlerAttack(wSkillUser) >= wSkillAmount:
	ld a, [wSkillUser]
	call GetBattlerAttack
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
;=@a
	call CompareHLBC
	jr c, .lowest

;>     AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57

.lowest
;> wSkillAmount = 0xFFFF
	ld a, $ff
	ld hl, wSkillAmount
	ld [hli], a
	ld [hl], a
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@u for pos in range(side, side + 3):          # written out three times
;>@p     if not CheckBattlerPresent(pos) and GetBattlerDefense(pos) < wSkillAmount:
	ld a, c
	call CheckBattlerPresent
	jr c, .second

;=@p
	ld a, c
	call GetBattlerDefense
;>@m         wSkillAmount = GetBattlerDefense(pos)
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.second
;=@u
	inc c
;=@p
	ld a, c
	call CheckBattlerPresent
	jr c, .third

;=@p
	ld a, c
	call GetBattlerDefense
	push bc
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
;=@p
	ld b, a
	call CompareHLBC
	pop bc
	jr nc, .third

;=@m
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.third
;=@u
	inc c
;=@p
	ld a, c
	call CheckBattlerPresent
	jr c, .check

;=@p
	ld a, c
	call GetBattlerDefense
	push bc
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
;=@p
	ld b, a
	call CompareHLBC
	pop bc
	jr nc, .check

;=@m
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.check
;>@b if GetBattlerAttack(wSkillUser) >= wSkillAmount:
	ld a, [wSkillUser]
	call GetBattlerAttack
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
;=@b
	call CompareHLBC
	ret c

;>     AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret

	ret


;@ def AIBonusStrongHit()
;@ path: battle/ai/rules
;@ The strong hits (IsStrongHitSkill) get 5 when the user has no more than 2/3 of its HP, and 5 more
;@ when its maximum MP is below its maximum HP.
;@ test: wSkillUser = rand(0, 7)
AIBonusStrongHit::
;> if not IsStrongHitSkill(): return
	call IsStrongHitSkill
	ret nc

;> if not UserHPAboveTwoThirds(): AddCapped_57(addr(wAttackWeight), 5)
	call UserHPAboveTwoThirds
	jr c, .mp

	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57

.mp
;> if not UserMaxMPBelowMaxHP(): return
	call UserMaxMPBelowMaxHP
	ret nc

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret

	ret


;@ def AIBonusSpellOrBreath()
;@ path: battle/ai/rules
;@ The attack spells, breaths and a few others (IsSpellOrBreath) get 10 when the user has less than half
;@ of its MP, and 10 more when its maximum MP is at least its maximum HP.
;@ test: wSkillUser = rand(0, 7)
AIBonusSpellOrBreath::
;> if not IsSpellOrBreath(): return
	call IsSpellOrBreath
	ret nc

;> if UserMPBelowHalf(): AddCapped_57(addr(wAttackWeight), 10)
	call UserMPBelowHalf
	jr nc, .mp

	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57

.mp
;> if UserMaxMPBelowMaxHP(): return
	call UserMaxMPBelowMaxHP
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusGroupAttack()
;@ path: battle/ai/rules
;@ Skills that hit several enemies (Firebal to Defeat, MultiCut, RainSlash, Vacuum to BigBang) get 20
;@ when two or more enemies are present. The count looks at the first enemy position three times, so
;@ in effect the bonus comes whenever that position is filled.
;@ test: wSkillUser = rand(0, 7)
AIBonusGroupAttack::
;>@k if not (0x03 <= wSkillId < 0x14 or wSkillId in (0x4F, 0x57) or 0x59 <= wSkillId < 0x67):
	ld a, [wSkillId]
	cp $03
	ret c

	cp $12
	jr z, .check

;=@k
	cp $14
	jr c, .check

	cp $4f
	jr z, .check

	cp $57
	ret c

;=@k
	cp $58
	ret z

	cp $67
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@o count = 0
;>@f for k in range(3):
	ld b, $03
;=@o
	ld e, $00

.loop
;>     if not CheckBattlerPresent(side): count += 1
	push de
	ld a, c
	call CheckBattlerPresent
	pop de
	jr c, .next

	inc e

.next
;=@f
	dec b
	jr nz, .loop

;> if count < 2: return
	ld a, e
	cp $02
	ret c

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIBonusMassacre()
;@ path: battle/ai/rules
;@ Massacre and EvilSlash ($3F, $40) get 10 when an enemy present has a defense of at least twice the
;@ attack of the first enemy position (where the user's attack was probably meant).
;@ test: wSkillUser = rand(0, 7)
AIBonusMassacre::
;> if wSkillId not in (0x3F, 0x40): return
	ld a, [wSkillId]
	cp $3f
	jr z, .check

	cp $40
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld e, a
;>@t twice = (GetBattlerAttack(side) * 2) & 0xFFFF
;>@f for pos in range(side, side + 3):
	ld d, $03
;=@t
	call GetBattlerAttack
	add hl, hl
	ld c, l
	ld b, h

.loop
;>@c     if not CheckBattlerPresent(pos) and mem16[addr(wBattlerDefense) + 2 * pos] >= twice:
	ld a, e
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, e
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;=@c
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@c
	call CompareHLBC
	jr c, .next

	jr nc, .bonus

;>@b         AddCapped_57(addr(wAttackWeight), 10)
;>@r         return
.next
;=@f
	inc e
	dec d
	jr nz, .loop

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
;=@r
	ret


;@ def AIBonusRevive()
;@ path: battle/ai/rules
;@ Vivify, Revive and LifeSong ($30, $31, $95) get 45 when a monster of the user's side has fallen (in
;@ its place but out of the fight).
;@ test: wSkillUser = rand(0, 7)
AIBonusRevive::
;>@k if not (wSkillId == 0x95 or 0x30 <= wSkillId < 0x32):
	ld a, [wSkillId]
	cp $95
	jr z, .check

	cp $30
	ret c

	cp $32
;>     return
	ret nc

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03
;>@w if any(CheckBattlerPresent(pos) and wBattlerState[pos] != 0xFF for pos in range(side, side + 3)):
.loop
	ld a, c
	call CheckBattlerPresent
	jr z, .next

	jr c, .bonus

;>@b     AddCapped_57(addr(wAttackWeight), 45)
.next
;=@w
	inc c
	dec b
	jr nz, .loop

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $2d
	call AddCapped_57
	ret


;@ def AIBonusLastStand()
;@ path: battle/ai/rules
;@ Farewell and LifeDance ($32, $96) get 100 when the user's allies are all out of the fight (and it
;@ does not fight alone from the start) and it has no more than a fifth of its HP left.
;@ test: wSkillUser = rand(0, 7)
AIBonusLastStand::
;> if wSkillId not in (0x32, 0x96): return
	ld a, [wSkillId]
	cp $32
	jr z, .check

	cp $96
	ret nz

.check
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a
;> n = wEnemyCount if side else wPartyBattlers
	jr z, .own

	ld a, [wEnemyCount]
	jr .count

.own
	ld a, [wPartyBattlers]

.count
;> if n == 1: return
	cp $01
	ret z

;>@f for pos in range(side, side + n):
	ld b, a

.loop
;>     if pos != user and not CheckBattlerPresent(pos): return     # an ally still fights
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	ret nc

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;>@h if mem16[addr(wBattlerMaxHP) + 2 * user] // 5 < GetBattlerHP(user): return
	ld a, d
	call GetBattlerHP
	push hl
	ld a, d
	ld hl, wBattlerMaxHP
	call WordTableEntry_57
;=@h
	ld a, $05
	call Divide16
	pop bc
	call CompareHLBC
	ret c

;> AddCapped_57(addr(wAttackWeight), 100)
	ld hl, wAttackWeight
	ld b, $64
	call AddCapped_57
	ret


;@ def AIBonusAntidote()
;@ path: battle/ai/rules
;@ Antidote and Surge ($33, $81) get 15 when a monster of the user's side is poisoned (status byte 0 bit
;@ 0) and 15 more when one is severely poisoned (bit 1).
;@ test: wSkillUser = rand(0, 7)
AIBonusAntidote::
;> if wSkillId not in (0x33, 0x81): return
	ld a, [wSkillId]
	cp $33
	jr z, .check

	cp $81
	ret nz

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIBonusIfAnyHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x01, 15)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld de, $010f
	call AIBonusIfAnyHas
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIBonusIfAnyHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x02, 15)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld de, $020f
	call AIBonusIfAnyHas
	ret


;@ def AIBonusNumbOff()
;@ path: battle/ai/rules
;@ NumbOff and Surge ($34, $81) get 15 when a monster of the user's side is paralyzed (status byte 0 bit
;@ 6) and 15 more when one is asleep (bits $8C).
;@ test: wSkillUser = rand(0, 7)
AIBonusNumbOff::
;> if wSkillId not in (0x34, 0x81): return
	ld a, [wSkillId]
	cp $34
	jr z, .check

	cp $81
	ret nz

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIBonusIfAnyHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x40, 15)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld de, $400f
	call AIBonusIfAnyHas
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIBonusIfAnyHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x8C, 15)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld de, $8c0f
	call AIBonusIfAnyHas
	ret


;@ def AIBonusDeChaos()
;@ path: battle/ai/rules
;@ DeChaos and Surge ($35, $81) get 15 when a monster of the user's side is confused (status byte 0 bit
;@ 4).
;@ test: wSkillUser = rand(0, 7)
AIBonusDeChaos::
;> if wSkillId not in (0x35, 0x81): return
	ld a, [wSkillId]
	cp $35
	jr z, .check

	cp $81
	ret nz

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIBonusIfAnyHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x10, 15)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld de, $100f
	call AIBonusIfAnyHas
	ret


;@ def AIBonusCurseOff()
;@ path: battle/ai/rules
;@ CurseOff and Surge ($36, $81) get 15 when a monster of the user's side is cursed (status byte 0 bit
;@ 5).
;@ test: wSkillUser = rand(0, 7)
AIBonusCurseOff::
;> if wSkillId not in (0x36, 0x81): return
	ld a, [wSkillId]
	cp $36
	jr z, .check

	cp $81
	ret nz

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIBonusIfAnyHas(side, 3, AddEightTimes(side, addr(wBattlerStatus)), 0x20, 15)
	ld b, $03
	ld hl, wBattlerStatus
	call AddEightTimes
	ld de, $200f
	call AIBonusIfAnyHas
	ret


;@ def AIHealUserBelow3Q()
;@ path: battle/ai/rules
;@ The healing skills (Heal to HealUsAll ($2B-$2F)), Meditate and Hustle: when the user has no more than 3/4 of
;@ its HP the flag at wSkillStatusPtr is set to 1, and all but HealAll and HealUsAll get 5.
;@ test: wSkillUser = rand(0, 7)
AIHealUserBelow3Q::
;>@k if not (wSkillId in (0x93, 0x94) or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $93
	jr z, .check

	cp $94
	jr z, .check

;=@k
	cp $2b
	ret c

	cp $30
;>     return
	ret nc

.check
;> mem[addr(wSkillStatusPtr)] = 0                # flag: the user has at most 3/4 of its HP
	xor a
	ld [wSkillStatusPtr], a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * wSkillUser       # the pointers the HP tests read
	ld a, [wSkillUser]
	ld c, a
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * wSkillUser
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;> if HPAboveThreeQuarters(): return
	ld a, c
	call HPAboveThreeQuarters
	ret c

;> mem[addr(wSkillStatusPtr)] = 1
	ld a, $01
	ld [wSkillStatusPtr], a
;> if wSkillId in (0x2D, 0x2F): return        # HealAll, HealUsAll
	ld a, [wSkillId]
	cp $2d
	ret z

	cp $2f
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealUserBelowHalf()
;@ path: battle/ai/rules
;@ The healing skills, Meditate and Hustle get 10 when the user has no more than half of its HP
;@ (flag wStatPtr = 1) and 5 more when it has no more than a quarter (flag wAIUserHPQuarter).
;@ test: wSkillUser = rand(0, 7)
AIHealUserBelowHalf::
;>@k if not (wSkillId in (0x93, 0x94) or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $93
	jr z, .check

	cp $94
	jr z, .check

;=@k
	cp $2b
	ret c

	cp $30
;>     return
	ret nc

.check
;> mem[addr(wStatPtr)] = 0                       # flag: the user has at most half of its HP
	xor a
	ld [wStatPtr], a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * wSkillUser       # the pointers the HP tests read
	ld a, [wSkillUser]
	ld c, a
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * wSkillUser
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;> if HPAboveHalf(): return
	ld a, c
	call HPAboveHalf
	ret c

;> mem[addr(wStatPtr)] = 1
	ld a, $01
	ld [wStatPtr], a
;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
;> wAIUserHPQuarter = 0
	xor a
	ld [wAIUserHPQuarter], a
;>@a2 wSkillAmount = addr(wBattlerHP) + 2 * wSkillUser       # the pointers the HP tests read
	ld a, [wSkillUser]
	ld c, a
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a2
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a2
	ld [wSkillAmount + 1], a
;>@b2 wTargetScores = addr(wBattlerMaxHP) + 2 * wSkillUser
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b2
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b2
	ld [wTargetScores + 1], a
;> if HPAboveQuarter(): return
	ld a, c
	call HPAboveQuarter
	ret c

;> wAIUserHPQuarter = 1
	ld a, $01
	ld [wAIUserHPQuarter], a
;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealUserBelowTenth()
;@ path: battle/ai/rules
;@ The healing skills, Meditate and Hustle: when the user has no more than a tenth of its HP the
;@ flag wAIUserHPTenth is set, and all but HealUs get 5.
;@ test: wSkillUser = rand(0, 7)
AIHealUserBelowTenth::
;>@k if not (wSkillId in (0x93, 0x94) or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $93
	jr z, .check

	cp $94
	jr z, .check

;=@k
	cp $2b
	ret c

	cp $30
;>     return
	ret nc

.check
;> wAIUserHPTenth = 0
	xor a
	ld [wAIUserHPTenth], a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * wSkillUser       # the pointers the HP tests read
	ld a, [wSkillUser]
	ld c, a
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * wSkillUser
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;> if HPAboveTenth(): return
	ld a, c
	call HPAboveTenth
	ret c

;> wAIUserHPTenth = 1
	ld a, $01
	ld [wAIUserHPTenth], a
;> if wSkillId == 0x2E: return                # HealUs
	ld a, [wSkillId]
	cp $2e
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealUserAtOne()
;@ path: battle/ai/rules
;@ The healing skills, Meditate and Hustle: when the user is down to 1 HP the flag wAIUserHPOne is
;@ set, and all but HealUs get 5.
;@ test: wSkillUser = rand(0, 7)
AIHealUserAtOne::
;>@k if not (wSkillId in (0x93, 0x94) or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $93
	jr z, .check

	cp $94
	jr z, .check

;=@k
	cp $2b
	ret c

	cp $30
;>     return
	ret nc

.check
;> wAIUserHPOne = 0
	xor a
	ld [wAIUserHPOne], a
;>@h if GetBattlerHP(wSkillUser) != 1: return
	ld a, [wSkillUser]
	ld c, a
	call GetBattlerHP
	cp $01
	ret nz

;=@h
	ld a, h
	or a
	ret nz

;> wAIUserHPOne = 1
	ld a, $01
	ld [wAIUserHPOne], a
;> if wSkillId == 0x2E: return                # HealUs
	ld a, [wSkillId]
	cp $2e
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealAlliesBelow3Q()
;@ path: battle/ai/rules
;@ The healing skills and Hustle: counts the user's allies with no more than 3/4 of their HP (at
;@ wSkillStatusPtr + 1); when there are any, all but HealAll and HealUsAll get 5.
;@ test: wSkillUser = rand(0, 7)
AIHealAlliesBelow3Q::
;>@k if not (wSkillId == 0x94 or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $94
	jr z, .check

	cp $2b
	ret c

;=@k
	cp $30
;>     return
	ret nc

.check
;> count = GetUserSideCount()
	call GetUserSideCount
;> mem[addr(wSkillStatusPtr) + 1] = 0
	xor a
	ld [wSkillStatusPtr + 1], a
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * side       # the pointers the HP tests read
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * side
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;>@f for pos in range(side, side + count):
.loop
;>@c     if pos != user and not CheckBattlerPresent(pos) and not HPAboveThreeQuarters():
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	jr c, .next

;=@c
	call HPAboveThreeQuarters
	jr c, .next

;>         mem[addr(wSkillStatusPtr) + 1] += 1
	ld hl, wSkillStatusPtr + 1
	inc [hl]

.next
;>@s     wSkillAmount += 2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	inc hl
	inc hl
;=@s
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@t     wTargetScores += 2
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	inc hl
	inc hl
;=@t
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;=@f
	inc c
	dec b
	jr nz, .loop

;> if wSkillId in (0x2D, 0x2F): return        # HealAll, HealUsAll
	ld a, [wSkillId]
	cp $2d
	ret z

	cp $2f
	ret z

;> if not mem[addr(wSkillStatusPtr) + 1]: return
	ld a, [wSkillStatusPtr + 1]
	or a
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealAlliesBelowHalf()
;@ path: battle/ai/rules
;@ The healing skills and Hustle get 10 when one of the user's allies has no more than half of its HP
;@ (counted at wStatPtr + 1), and 5 more when one has no more than a quarter (wAIAlliesHPQuarter).
;@ test: wSkillUser = rand(0, 7)
AIHealAlliesBelowHalf::
;>@k if not (wSkillId == 0x94 or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $94
	jr z, .check

	cp $2b
	ret c

;=@k
	cp $30
;>     return
	ret nc

.check
;> count = GetUserSideCount()
	call GetUserSideCount
;> mem[addr(wStatPtr) + 1] = 0
	xor a
	ld [wStatPtr + 1], a
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * side       # the pointers the HP tests read
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * side
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;>@f for pos in range(side, side + count):
.loop
;>@c     if pos != user and not CheckBattlerPresent(pos) and not HPAboveHalf():
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	jr c, .next

;=@c
	call HPAboveHalf
	jr c, .next

;>         mem[addr(wStatPtr) + 1] += 1
	ld hl, wStatPtr + 1
	inc [hl]

.next
;>@s     wSkillAmount += 2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	inc hl
	inc hl
;=@s
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@t     wTargetScores += 2
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	inc hl
	inc hl
;=@t
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not mem[addr(wStatPtr) + 1]: return
	ld a, [wStatPtr + 1]
	or a
	ret z

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
;> count = GetUserSideCount()
	call GetUserSideCount
;> wAIAlliesHPQuarter = 0
	xor a
	ld [wAIAlliesHPQuarter], a
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a
;>@a2 wSkillAmount = addr(wBattlerHP) + 2 * side       # the pointers the HP tests read
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a2
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a2
	ld [wSkillAmount + 1], a
;>@b2 wTargetScores = addr(wBattlerMaxHP) + 2 * side
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b2
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b2
	ld [wTargetScores + 1], a
;>@f2 for pos in range(side, side + count):
.loop2
;>@c2     if pos != user and not CheckBattlerPresent(pos) and not HPAboveQuarter():
	ld a, c
	cp d
	jr z, .next2

	call CheckBattlerPresent
	jr c, .next2

;=@c2
	call HPAboveQuarter
	jr c, .next2

;>         wAIAlliesHPQuarter += 1
	ld hl, wAIAlliesHPQuarter
	inc [hl]

.next2
;>@s2     wSkillAmount += 2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	inc hl
	inc hl
;=@s2
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@t2     wTargetScores += 2
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	inc hl
	inc hl
;=@t2
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;=@f2
	inc c
	dec b
	jr nz, .loop2

;> if not wAIAlliesHPQuarter: return
	ld a, [wAIAlliesHPQuarter]
	or a
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealAlliesBelowTenth()
;@ path: battle/ai/rules
;@ The healing skills and Hustle: counts the user's allies with no more than a tenth of their HP
;@ (wAIAlliesHPTenth); when there are any, all but HealUs get 5.
;@ test: wSkillUser = rand(0, 7)
AIHealAlliesBelowTenth::
;>@k if not (wSkillId == 0x94 or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $94
	jr z, .check

	cp $2b
	ret c

;=@k
	cp $30
;>     return
	ret nc

.check
;> count = GetUserSideCount()
	call GetUserSideCount
;> wAIAlliesHPTenth = 0
	xor a
	ld [wAIAlliesHPTenth], a
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a
;>@a wSkillAmount = addr(wBattlerHP) + 2 * side       # the pointers the HP tests read
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * side
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;>@f for pos in range(side, side + count):
.loop
;>@c     if pos != user and not CheckBattlerPresent(pos) and not HPAboveTenth():
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	jr c, .next

;=@c
	call HPAboveTenth
	jr c, .next

;>         wAIAlliesHPTenth += 1
	ld hl, wAIAlliesHPTenth
	inc [hl]

.next
;>@s     wSkillAmount += 2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	inc hl
	inc hl
;=@s
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@t     wTargetScores += 2
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	inc hl
	inc hl
;=@t
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wAIAlliesHPTenth: return
	ld a, [wAIAlliesHPTenth]
	or a
	ret z

;> if wSkillId == 0x2E: return                # HealUs
	ld a, [wSkillId]
	cp $2e
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealAlliesAtOne()
;@ path: battle/ai/rules
;@ The healing skills and Hustle: counts the user's allies down to 1 HP (wAIAlliesHPOne); when there
;@ are any, all but HealUs get 5.
;@ test: wSkillUser = rand(0, 7)
AIHealAlliesAtOne::
;>@k if not (wSkillId == 0x94 or 0x2B <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $94
	jr z, .check

	cp $2b
	ret c

;=@k
	cp $30
;>     return
	ret nc

.check
;> count = GetUserSideCount()
	call GetUserSideCount
;> wAIAlliesHPOne = 0
	xor a
	ld [wAIAlliesHPOne], a
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> side = user & 4
	and $04
	ld c, a

;>@f for pos in range(side, side + count):
.loop
;>@c     if pos != user and not CheckBattlerPresent(pos) and GetBattlerHP(pos) == 1:
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call GetBattlerHP
	cp $01
	jr nz, .next

	ld a, h
	or a
;=@c
	jr nz, .next

;>         wAIAlliesHPOne += 1
	ld hl, wAIAlliesHPOne
	inc [hl]

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wAIAlliesHPOne: return
	ld a, [wAIAlliesHPOne]
	or a
	ret z

;> if wSkillId == 0x2E: return                # HealUs
	ld a, [wSkillId]
	cp $2e
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealGroup3Q()
;@ path: battle/ai/rules
;@ HealUs, HealUsAll and Hustle: HealUs and Hustle get 5 when the user and its allies with no more
;@ than 3/4 of their HP are two or more (wSkillStatusPtr flags).
;@ test: wSkillUser = rand(0, 7)
AIHealGroup3Q::
;>@k if not (wSkillId == 0x94 or 0x2E <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $94
	jr z, .check

	cp $2e
	ret c

;=@k
	cp $30
;>     return
	ret nc

.check
;> if mem[addr(wSkillStatusPtr)] + mem[addr(wSkillStatusPtr) + 1] < 2: return
	ld a, [wSkillStatusPtr]
	ld b, a
	ld a, [wSkillStatusPtr + 1]
	add b
	cp $02
	ret c

;> if wSkillId == 0x2F: return                # HealUsAll
	ld a, [wSkillId]
	cp $2f
	ret z

;> AddCapped_57(addr(wAttackWeight), 5)
	ld hl, wAttackWeight
	ld b, $05
	call AddCapped_57
	ret


;@ def AIHealGroupHalf()
;@ path: battle/ai/rules
;@ HealUs, HealUsAll and Hustle get 15 when two or more of the user's side have no more than half of
;@ their HP (wStatPtr flags), and 10 more when two or more have no more than a quarter.
;@ test: wSkillUser = rand(0, 7)
AIHealGroupHalf::
;>@k if not (wSkillId == 0x94 or 0x2E <= wSkillId < 0x30):
	ld a, [wSkillId]
	cp $94
	jr z, .check

	cp $2e
	ret c

;=@k
	cp $30
;>     return
	ret nc

.check
;> if mem[addr(wStatPtr)] + mem[addr(wStatPtr) + 1] < 2: return
	ld a, [wStatPtr]
	ld b, a
	ld a, [wStatPtr + 1]
	add b
	cp $02
	ret c

;> AddCapped_57(addr(wAttackWeight), 15)
	ld hl, wAttackWeight
	ld b, $0f
	call AddCapped_57
;> if wAIUserHPQuarter + wAIAlliesHPQuarter < 2: return
	ld a, [wAIUserHPQuarter]
	ld b, a
	ld a, [wAIAlliesHPQuarter]
	add b
	cp $02
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIHealGroupTenth()
;@ path: battle/ai/rules
;@ HealUs and HealUsAll: when two or more of the user's side have no more than a tenth of their HP,
;@ HealUsAll gets 10.
;@ test: wSkillUser = rand(0, 7)
AIHealGroupTenth::
;> if not 0x2E <= wSkillId < 0x30: return
	ld a, [wSkillId]
	cp $2e
	ret c

	cp $30
	ret nc

;> if wAIUserHPTenth + wAIAlliesHPTenth < 2: return
	ld a, [wAIUserHPTenth]
	ld b, a
	ld a, [wAIAlliesHPTenth]
	add b
	cp $02
	ret c

;> if wSkillId == 0x2E: return                # HealUs
	ld a, [wSkillId]
	cp $2e
	ret z

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIHealGroupAtOne()
;@ path: battle/ai/rules
;@ HealUsAll ($2F) gets 10 when two or more of the user's side are down to 1 HP.
;@ test: wSkillUser = rand(0, 7)
AIHealGroupAtOne::
;> if wSkillId != 0x2F: return
	ld a, [wSkillId]
	cp $2f
	ret nz

;> if wAIUserHPOne + wAIAlliesHPOne < 2: return
	ld a, [wAIUserHPOne]
	ld b, a
	ld a, [wAIAlliesHPOne]
	add b
	cp $02
	ret c

;> if wSkillId == 0x2E: return                # HealUs
	ld a, [wSkillId]
	cp $2e
	ret z

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusAttackBoosted()
;@ path: battle/ai/rules
;@ The physical attacks FireSlash to QuadHits (but MultiCut), SquallHit, RainSlash, PoisonHit to
;@ Paralyze and SmashLime to Branching get 20 while the user charges (ChargeUP, status byte 4 bits 0-1)
;@ or has its attack doubled (status byte 1 bits 2-3: TwinHits, ALLCHANGE).
;@ test: wSkillUser = rand(0, 7)
AIBonusAttackBoosted::
;>@k if not (0x44 <= wSkillId < 0x52 and wSkillId != 0x4F or 0xD6 <= wSkillId < 0xD9 or 0x67 <= wSkillId < 0x6A or wSkillId in (0x55, 0x57)):
	ld a, [wSkillId]
	cp $4f
	ret z

	cp $44
	ret c

;=@k
	cp $52
	jr c, .check

	cp $d9
	ret nc

	cp $d6
	jr nc, .check

;=@k
	cp $6a
	ret nc

	cp $67
	jr nc, .check

	cp $55
	jr z, .check

;=@k
	cp $57
;>     return
	ret nz

.check
;> status4 = AddEightTimes(wSkillUser, addr(wBattlerStatus4))
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
;>@x if not (mem[status4] & 0x03 or mem[status4 - 3] & 0x0C): return
	ld a, [hld]
	and $03
	jr nz, .bonus

	dec hl
	dec hl
	ld a, [hl]
;=@x
	and $0c
	ret z

.bonus
;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleAllBoosted()
;@ path: battle/ai/rules
;@ TwinHits and ChargeUP ($25, $41) are ruled out when every monster of the user's side has its attack
;@ doubled already (status byte 1 bits 2-3).
;@ test: wSkillUser = rand(0, 7)
AIRuleAllBoosted::
;> if wSkillId not in (0x25, 0x41): return
	ld a, [wSkillId]
	cp $25
	jr z, .check

	cp $41
	ret nz

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x0C: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIBonusBoostUseful()
;@ path: battle/ai/rules
;@ Only for a smart monster: TwinHits, SickLick and ChargeUP ($25, $7A, $41) get 20 unless the attack
;@ tested is far from the enemies' lowest defense (AttackFarFromDefense). MinEnemyDefense leaves the
;@ position at the end of the enemy side, so that position's attack is tested, not the user's.
;@ test: wSkillUser = rand(0, 7)
AIBonusBoostUseful::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if wSkillId not in (0x25, 0x7A, 0x41):
	ld a, [wSkillId]
	cp $25
	jr z, .check

	cp $7a
	jr z, .check

;=@k
	cp $41
;>     return
	ret nz

.check
;> pos = wSkillUser
	ld a, [wSkillUser]
	ld e, a
;> pos = MinEnemyDefense()
	call MinEnemyDefense
;> if AttackFarFromDefense(pos): return
	call AttackFarFromDefense
	ret c

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIBonusLowerDefense()
;@ path: battle/ai/rules
;@ Only for a smart monster: SickLick, UltraDown, TwinHits, Sap and Defence ($7A, $82, $25, $1C, $1D)
;@ get 10 when the attack of a position of the user's side is near the enemies' lowest defense
;@ (between half and twice of it, AttackFarFromDefense).
;@ test: wSkillUser = rand(0, 7)
AIBonusLowerDefense::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if wSkillId not in (0x7A, 0x82, 0x25, 0x1C, 0x1D):
	ld a, [wSkillId]
	cp $7a
	jr z, .check

	cp $82
	jr z, .check

;=@k
	cp $25
	jr z, .check

	cp $1c
	ret c

	cp $1e
;>     return
	ret nc

.check
;> MinEnemyDefense()
	call MinEnemyDefense
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld e, a
;>@w if any(not AttackFarFromDefense(pos) for pos in range(side, side + 3)):
	ld d, $03

.loop
;=@w
	call AttackFarFromDefense
	jr nc, .bonus

	inc e
	dec d
	jr nz, .loop

	ret

;>@b     AddCapped_57(addr(wAttackWeight), 10)
.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusVsBlinded()
;@ path: battle/ai/rules
;@ Only for a smart monster: Surround, Upper, Increase, SandStorm, Radiant and SideStep get 10 when
;@ enemies wrapped in an illusion (status byte 1 bit 1) or blinded (status byte 5 bits 0-1) are present
;@ and twice the "average" defense of the user's side is below their "average" attack. Both averages
;@ are broken: the attack total is divided by its own high byte, and AverageDefense gives 0 or a
;@ division by 0.
;@ test: skip divides by zero
AIBonusVsBlinded::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if wSkillId not in (0x18, 0x1E, 0x1F, 0x72, 0x73, 0x77):
	ld a, [wSkillId]
	cp $18
	jr z, .check

	cp $1e
	ret c

;=@k
	cp $20
	jr c, .check

	cp $72
	ret c

;=@k
	cp $74
	jr c, .check

	cp $77
;>     return
	ret nz

.check
;> wAIBlindCount = 0
	xor a
	ld [wAIBlindCount], a
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> wSkillAmount = 0
	xor a
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and (mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x02 or mem[AddEightTimes(pos, addr(wBattlerStatus5))] & 0x03):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr nz, .add

;=@c
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	and $03
;=@c
	jr z, .next

.add
;>@a         wSkillAmount = (wSkillAmount + GetBattlerAttack(pos)) & 0xFFFF
	ld a, [wSkillAmount]
	ld e, a
	ld a, [wSkillAmount + 1]
	ld d, a
	ld a, c
	call GetBattlerAttack
;=@a
	add hl, de
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>         wAIBlindCount += 1
	ld hl, wAIBlindCount
	inc [hl]

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wAIBlindCount: return
	ld a, [wAIBlindCount]
	or a
	ret z

;>@d wTargetScores = Divide16(wSkillAmount, wSkillAmount >> 8)[0]    # meant: divided by the count
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Divide16
;=@d
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;> AverageDefense(wSkillUser & 4)
	ld a, [wSkillUser]
	and $04
	call AverageDefense
;>@q if (wSkillAmount << 1) & 0xFFFF >= wTargetScores: return
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	sla l
	rl h
;=@q
	ld a, [wTargetScores]
	ld c, a
	ld a, [wTargetScores + 1]
	ld b, a
	call CompareHLBC
	ret nc

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIRuleBarrier()
;@ path: battle/ai/rules
;@ Barrier ($24) is ruled out when every monster of the user's side resists at level 3 already
;@ (AIRuleOutIfResistByte4).
;@ test: skip calls a routine in another bank
AIRuleBarrier::
;> if wSkillId != 0x24: return
	ld a, [wSkillId]
	cp $24
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> AIRuleOutIfResistByte4(side, 3)
	ld b, $03
	call AIRuleOutIfResistByte4
	ret


;@ def AIRuleResistEnemies()
;@ path: battle/ai/rules
;@ Only for a smart monster: MagicWall, Imitate and SuckAir ($26, $7F, $43) are ruled out when every
;@ enemy resists at level 3 (AIRuleOutIfResistByte4).
;@ test: skip calls a routine in another bank
AIRuleResistEnemies::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if wSkillId not in (0x26, 0x7F, 0x43): return
	ld a, [wSkillId]
	cp $26
	jr z, .check

	cp $7f
	jr z, .check

;=@k
	cp $43
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> AIRuleOutIfResistByte4(side, 3)
	ld b, $03
	call AIRuleOutIfResistByte4
	ret


;@ def AIBonusVsBigSpells()
;@ path: battle/ai/rules
;@ Only for a smart monster: StopSpell, MagicWall, MagicBack, Bounce and Imitate get 10 when an enemy
;@ present knows one of the strongest attack spells (Blazemost, Firebolt, Explodet, Infermost,
;@ Blizzard, Thordain, Beat, Defeat). Each enemy's list is read as kind / number pairs up to a kind 0.
;@ test: wSkillUser = rand(0, 7)
AIBonusVsBigSpells::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if not (wSkillId in (0x17, 0x7F) or 0x26 <= wSkillId < 0x29):
	ld a, [wSkillId]
	cp $17
	jr z, .check

	cp $26
	ret c

;=@k
	cp $7f
	jr z, .check

	cp $29
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@p     p = addr(wBattlerSkills) + pos * 16          # kind / number pairs
	ld a, c
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;>@g     for k in range(8):
	ld d, $08

.skills
;>         kind = mem[p]
	ld a, [hli]
;>         if kind == 0: break
	or a
	jr z, .next

;>@a         if kind == 1 and mem[p + 1] in (0x02, 0x05, 0x08, 0x0B, 0x0E, 0x11, 0x12, 0x13):
	cp $01
	jr nz, .skip

	ld a, [hl]
	cp $02
	jr z, .bonus

;=@a
	cp $05
	jr z, .bonus

	cp $08
	jr z, .bonus

	cp $0b
	jr z, .bonus

;=@a
	cp $0e
	jr z, .bonus

	cp $11
	jr c, .skip

	cp $14
	jr c, .bonus

;>@b             AddCapped_57(addr(wAttackWeight), 10)
;>@r             return
.skip
;>         p += 2
	inc hl
;=@g
	dec d
	jr nz, .skills

.next
;=@f
	inc c
	dec b
	jr nz, .loop

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
;=@r
	ret


;@ def AIBonusAgilityGap()
;@ path: battle/ai/rules
;@ Only for a smart monster: Slow, SlowAll, Speed and SpeedUp ($20-$23) get 10 when a monster of the
;@ user's side is slower than the enemies' average agility, and 10 more when the user's side's
;@ average agility is below wTargetScores - which is not set here, so that test uses whatever an
;@ earlier rule left in it.
;@ test: wSkillUser = rand(0, 7)
AIBonusAgilityGap::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> if not 0x20 <= wSkillId < 0x24: return
	ld a, [wSkillId]
	cp $20
	ret c

	cp $24
	ret nc

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@s SumBattlerWords(side, 3, addr(wBattlerAgility) + side * 2)
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	call SumBattlerWords
;>@v wSkillAmount = Divide16(wSkillAmount, wBattleArg0)[0]         # the enemies' average agility
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [wBattleArg0]
	call Divide16
;=@v
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> own = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
;>@p agility = addr(wBattlerAgility) + own * 2
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;> average = wSkillAmount
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a

;>@f for pos in range(own, own + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and mem16[agility] < average:
	ld a, e
	call CheckBattlerPresent
	jr c, .next

;=@c
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	pop hl
;=@c
	jr c, .bonus

;>@b         AddCapped_57(addr(wAttackWeight), 10)
;>         break
.next
;>     agility += 2
	inc hl
	inc hl
;=@f
	inc e
	dec d
	jr nz, .loop

	jr .second

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57

.second
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@s2 SumBattlerWords(side, 3, addr(wBattlerAgility) + side * 2)
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s2
	ld h, a
	call SumBattlerWords
;>@v2 wSkillAmount = Divide16(wSkillAmount, wBattleArg0)[0]
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [wBattleArg0]
	call Divide16
;=@v2
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> own = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03
;>@s3 SumBattlerWords(own, 3, addr(wBattlerAgility) + own * 2)
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@s3
	ld h, a
	call SumBattlerWords
;>@q if Divide16(wSkillAmount, wBattleArg0)[0] >= wTargetScores: return
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [wBattleArg0]
	call Divide16
;=@q
	ld a, [wTargetScores]
	ld c, a
	ld a, [wTargetScores + 1]
	ld b, a
	call CompareHLBC
	ret nc

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusTransform()
;@ path: battle/ai/rules
;@ Only for a smart monster: Transform ($29) gets 20 once the enemies present have matched or beaten
;@ the compared monster in three stats, counted over all of them (maximum HP, attack, defense; the
;@ maximum MP is compared but the count for it is jumped over). The compared stats are those of
;@ position 2 * wSkillUser rather than the user's own. The loop goes on in AIBonusTransformTail.
;@ test: skip runs on in AIBonusTransformTail
AIBonusTransform::
;> if wSkillId != 0x29: return
	ld a, [wSkillId]
	cp $29
	ret nz

;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> me = 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	add a
	ld e, a
;> wSkillAmount = WordTableEntry_57(me, addr(wBattlerMaxHP))
	call WordTableEntry_57
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> wTargetScores = GetBattlerMaxMP(me)
	ld a, e
	call GetBattlerMaxMP
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;> wSkillAmount2 = GetBattlerAttack(me)
	ld a, e
	call GetBattlerAttack
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;> wSkillTempPtr = GetBattlerDefense(me)
	ld a, e
	call GetBattlerDefense
	ld a, l
	ld [wSkillTempPtr], a
	ld a, h
	ld [wSkillTempPtr + 1], a
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld e, a
	ld d, $03
;> wBattleArg0 = 0
	xor a
	ld [wBattleArg0], a

;> for pos in range(side, side + 3):
jr_057_5788:
;>     if CheckBattlerPresent(pos): continue
	ld a, e
	call CheckBattlerPresent
	jp c, jr_057_57ed

;>@h     if WordTableEntry_57(pos, addr(wBattlerMaxHP)) >= wSkillAmount: wBattleArg0 += 1
	ld a, e
	ld hl, wBattlerMaxHP
	call WordTableEntry_57
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
;=@h
	ld b, a
	call CompareHLBC
	jr c, .mp

	ld hl, wBattleArg0
	inc [hl]

.mp
;>@x     GetBattlerMaxMP(pos) >= wTargetScores        # its count is jumped over (AIBonusTransformTail)
	ld a, e
	call GetBattlerMaxMP
	ld a, [wTargetScores]
	ld c, a
	ld a, [wTargetScores + 1]
	ld b, a
;=@x
	call CompareHLBC
	jr jr_057_57bc


;@ def AIBonusTransformTail(pos: e, left: d)
;@ path: battle/ai/rules
;@ The rest of AIBonusTransform's loop. Its first two instructions (the MP count) are never reached: the
;@ loop jumps in after them. Counts an attack and a defense at least the compared monster's, gives 20
;@ once the count reaches 3, and goes back to the start of the loop for the next enemy.
;@ test: skip part of the loop of AIBonusTransform
AIBonusTransformTail::
;> wBattleArg0 += 1                             # (never reached)
	ld hl, wBattleArg0
	inc [hl]

jr_057_57bc:
;>@a if GetBattlerAttack(pos) >= wSkillAmount2: wBattleArg0 += 1
	ld a, e
	call GetBattlerAttack
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
;=@a
	call CompareHLBC
	jr c, .defense

	ld hl, wBattleArg0
	inc [hl]

.defense
;>@d if GetBattlerDefense(pos) >= wSkillTempPtr: wBattleArg0 += 1
	ld a, e
	call GetBattlerDefense
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [wSkillTempPtr + 1]
	ld b, a
;=@d
	call CompareHLBC
	jr c, .count

	ld hl, wBattleArg0
	inc [hl]

.count
;> if wBattleArg0 >= 3:
	ld a, [wBattleArg0]
	cp $03
	jr nc, jr_057_57ed.bonus

;>@b     AddCapped_57(addr(wAttackWeight), 20)
;>@r     return
jr_057_57ed:
;> pos += 1
	inc e
;> left -= 1
	dec d
;> if left: return                              # back to the loop of AIBonusTransform
	jp nz, jr_057_5788

;> return
	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
;=@r
	ret


;@ def AIBonusRobMagic()
;@ path: battle/ai/rules
;@ Only for a smart monster: RobMagic, TakeMagic and RobDance ($1A, $1B, $76) get 10 while the user
;@ has more than a tenth of its MP (HPAboveTenth, pointed at the MP words).
;@ test: wSkillUser = rand(0, 7)
AIBonusRobMagic::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if not (wSkillId == 0x76 or 0x1A <= wSkillId < 0x1C):
	ld a, [wSkillId]
	cp $76
	jr z, .check

	cp $1a
	ret c

	cp $1c
;>     return
	ret nc

.check
;>@a wSkillAmount = addr(wBattlerMP) + 2 * wSkillUser
	ld a, [wSkillUser]
	add a
	ld d, a
	ld hl, wBattlerMP
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxMP) + 2 * wSkillUser
	ld a, d
	ld hl, wBattlerMaxMP
	add l
	ld l, a
	ld a, $00
	adc h
;=@b
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;> if not HPAboveTenth(): return
	call HPAboveTenth
	ret nc

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusDeMagic()
;@ path: battle/ai/rules
;@ Only for a smart monster: DeMagic ($80) gets 20 once three effects DeMagic would end have been
;@ counted over the enemies present: the bits of status byte 1 (0-5) and 2 (0-6), bits 6-7 of byte 3,
;@ an iron lump or side-stepping (byte 5), a raised stat (byte 6 bit 6), and per enemy bits 2, 3 and 5
;@ of the user's own side's wSideFlags.
;@ test: wSkillUser = rand(0, 7)
AIBonusDeMagic::
;> if wSkillId != 0x80: return
	ld a, [wSkillId]
	cp $80
	ret nz

;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> wSkillAmount = AddEightTimes(side, addr(wBattlerStatus1))    # walks the enemies' status bytes
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> wBattleArg0 = 0
	xor a
	ld [wBattleArg0], a

;>@f for pos in range(side, side + 3):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jp c, .next

;>@1         wBattleArg0 = (wBattleArg0 + bin(mem[wSkillAmount] & 0x3F).count('1')) & 0xFF
	ld a, [hl]
	and $3f
	jr z, .byte2

	bit 0, [hl]
	call nz, CountUp_57
;=@1
	bit 1, [hl]
	call nz, CountUp_57
	bit 2, [hl]
	call nz, CountUp_57
;=@1
	bit 3, [hl]
	call nz, CountUp_57
	bit 4, [hl]
	call nz, CountUp_57
;=@1
	bit 5, [hl]
	call nz, CountUp_57

.byte2
;>@2         wBattleArg0 = (wBattleArg0 + bin(mem[wSkillAmount + 1] & 0x7F).count('1')) & 0xFF
	inc hl
	ld a, [hl]
	and $7f
	jr z, .byte3

	bit 0, [hl]
	call nz, CountUp_57
;=@2
	bit 1, [hl]
	call nz, CountUp_57
	bit 2, [hl]
	call nz, CountUp_57
;=@2
	bit 3, [hl]
	call nz, CountUp_57
	bit 4, [hl]
	call nz, CountUp_57
;=@2
	bit 5, [hl]
	call nz, CountUp_57
	bit 6, [hl]
	call nz, CountUp_57

.byte3
;>@3         wBattleArg0 = (wBattleArg0 + bin(mem[wSkillAmount + 2] & 0xC0).count('1')) & 0xFF
	inc hl
	ld a, [hl]
	and $c0
	jr z, .byte5

	bit 6, [hl]
	call nz, CountUp_57
;=@3
	bit 7, [hl]
	call nz, CountUp_57

.byte5
;>@5         wBattleArg0 = (wBattleArg0 + (1 if mem[wSkillAmount + 4] & 0xC0 else 0) + (1 if mem[wSkillAmount + 4] & 0x0C else 0)) & 0xFF
	inc hl
	inc hl
	ld a, [hl]
	and $cc
	jr z, .byte6

;=@5
	and $c0
	call nz, CountUp_57
	ld a, [hl]
	and $0c
	call nz, CountUp_57

.byte6
;>         if mem[wSkillAmount + 5] & 0x40: CountUp_57()
	inc hl
	bit 6, [hl]
	call nz, CountUp_57
;>@s         sideflags = wSideFlags[(wSkillUser >> 2) & 1]
	ld a, [wSkillUser]
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
;>@w         wBattleArg0 = (wBattleArg0 + bin(sideflags & 0x2C).count('1')) & 0xFF
	ld a, [hl]
	and $2c
	jr z, .total

	bit 2, [hl]
	call nz, CountUp_57
;=@w
	bit 3, [hl]
	call nz, CountUp_57
	bit 5, [hl]
	call nz, CountUp_57

.total
;>         if wBattleArg0 >= 3:
	ld a, [wBattleArg0]
	cp $03
	jr nc, jr_057_5934

;>             AddCapped_57(addr(wAttackWeight), 20)   # at jr_057_5934, behind CountUp_57
;>             return
.next
;>@n     wSkillAmount += 8
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, $08
	add l
;=@n
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
;=@n
	ld a, h
	ld [wSkillAmount + 1], a
;=@f
	inc c
	dec b
	jp nz, .loop

	ret


;@ def CountUp_57()
;@ path: battle/ai/rules
;@ wBattleArg0 += 1 (a counter of AIBonusDeMagic). The bonus of AIBonusDeMagic follows it.
;@ test: wBattleArg0 = rand(0, 255)
CountUp_57::
;> wBattleArg0 = (wBattleArg0 + 1) & 0xFF
	ld a, [wBattleArg0]
	inc a
	ld [wBattleArg0], a
;> return
	ret

jr_057_5934:
;> AddCapped_57(addr(wAttackWeight), 20)        # (AIBonusDeMagic jumps here)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIBonusThickFog()
;@ path: battle/ai/rules
;@ Only for a smart monster: ThickFog ($83), which stops spells on both sides, gets 20 unless the
;@ user's side knows more spells (numbers below $3A, BeDragon, Life, Ironize $DC) than it has monsters,
;@ and when the enemies know two or more of the strongest attack spells.
;@ test: wSkillUser = rand(0, 7)
AIBonusThickFog::
;> if wSkillId != 0x83: return
	ld a, [wSkillId]
	cp $83
	ret nz

;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> wBattleArg0 = 0                             # spells of the user's side
;> wBattleArg1 = 0                             # its monsters
	xor a
	ld [wBattleArg0], a
	ld [wBattleArg1], a
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@p     p = addr(wBattlerSkills) + 1 + pos * 16
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;>     wBattleArg1 += 1
	ld a, [wBattleArg1]
	inc a
	ld [wBattleArg1], a
;>@g     for k in range(8):
	ld d, $08

.skills
;>         skill = mem[p]
	ld a, [hli]
;>         if skill == 0xFF: break
	cp $ff
	jr z, .next

;>@s         if skill < 0x3A or skill in (0xD5, 0xDA, 0xDC): wBattleArg0 += 1
	cp $3a
	jr c, .spell

	cp $d5
	jr z, .spell

	cp $da
	jr z, .spell

;=@s
	cp $dc
	jr nz, .skip

.spell
;=@s
	ld a, [wBattleArg0]
	inc a
	ld [wBattleArg0], a

.skip
;>         p += 2
	inc hl
;=@g
	dec d
	jr nz, .skills

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if wBattleArg1 < wBattleArg0: return
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	cp c
	ret c

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> count = 0
	ld d, $00

;>@f2 for pos in range(side, side + 3):
.loop2
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next2

;>@q     p = addr(wBattlerSkills) + 1 + pos * 16
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@q
	ld a, $00
	adc h
	ld h, a
;>@g2     for k in range(8):
	ld e, $08

.skills2
;>         skill = mem[p]
	ld a, [hli]
;>@t         if skill != 0xFF and (skill in (0x02, 0x05, 0x08, 0x0B, 0x0E) or 0x11 <= skill < 0x14):   # (an end mark does not stop this scan)
	cp $ff
	jr z, .skip2

;=@t
	cp $02
	jr z, .strong

	cp $05
	jr z, .strong

	cp $08
	jr z, .strong

;=@t
	cp $0b
	jr z, .strong

	cp $0e
	jr z, .strong

	cp $11
	jr c, .skip2

;=@t
	cp $14
	jr nc, .skip2

.strong
;>             count += 1
	inc d
;>             if count >= 2:
	ld a, d
	cp $02
	jr nc, .bonus

;>@b                 AddCapped_57(addr(wAttackWeight), 20)
;>@r                 return
.skip2
;>         p += 2
	inc hl
;=@g2
	dec e
	jr nz, .skills2

.next2
;=@f2
	inc c
	dec b
	jr nz, .loop2

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
;=@r
	ret


;@ def AIBonusMagicWall()
;@ path: battle/ai/rules
;@ Only for a smart monster: MagicWall and Imitate ($26, $7F) get 10 when an enemy position's skill list
;@ holds MultiCut, Vacuum, RockThrow, Hellblast, BigBang or GigaSlash - or simply ends before its
;@ eighth skill, which makes the bonus nearly certain. The positions are not checked for a monster.
;@ test: wSkillUser = rand(0, 7)
AIBonusMagicWall::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> if wSkillId not in (0x26, 0x7F): return
	ld a, [wSkillId]
	cp $26
	jr z, .check

	cp $7f
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@p     p = addr(wBattlerSkills) + 1 + pos * 16
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
;>@g     for k in range(8):
	ld e, $08

.skills
;>@s         if mem[p] in (0xFF, 0x4F, 0x59, 0x5B, 0x64, 0x65, 0xD9):
	ld a, [hli]
	cp $ff
	jr z, .bonus

	cp $4f
	jr z, .bonus

;=@s
	cp $59
	jr z, .bonus

	cp $5b
	jr z, .bonus

	cp $64
	jr z, .bonus

;=@s
	cp $65
	jr z, .bonus

	cp $d9
	jr z, .bonus

;>@b             AddCapped_57(addr(wAttackWeight), 10)
;>@r             return
;>         p += 2
	inc hl
;=@g
	dec e
	jr nz, .skills

;=@f
	inc c
	dec b
	jr nz, .loop

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
;=@r
	ret


;@ def AIBonusProtectAlly()
;@ path: battle/ai/rules
;@ SuckAll, Cover and Guardian ($8F, $88, $89) get 20 when the user has at least 9/10 of its HP, every
;@ ally present has less HP than the user, and at least one of them is down to a tenth of its HP
;@ (counted by CountIfHPTenth).
;@ test: wSkillUser = rand(0, 7)
AIBonusProtectAlly::
;>@k if not (wSkillId == 0x8F or 0x88 <= wSkillId < 0x8A):
	ld a, [wSkillId]
	cp $8f
	jr z, .check

	cp $88
	ret c

	cp $8a
;>     return
	ret nc

.check
;> user = wSkillUser
	ld a, [wSkillUser]
	ld d, a
;> wSkillAmount = GetBattlerHP(user)
	ld a, d
	call GetBattlerHP
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@m wTargetScores = WordTableEntry_57(user, addr(wBattlerMaxHP))
	ld a, d
	ld hl, wBattlerMaxHP
	call WordTableEntry_57
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@m
	ld [wTargetScores + 1], a
;>@q if (Divide16(wTargetScores, 10)[0] + wSkillAmount) & 0xFFFF < wTargetScores: return   # below 9/10
	ld a, $0a
	call Divide16
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
;=@q
	add hl, bc
	ld a, [wTargetScores]
	ld c, a
	ld a, [wTargetScores + 1]
	ld b, a
	call CompareHLBC
;=@q
	ret c

;> side = user & 4
	ld a, [wSkillUser]
	ld d, a
	and $04
	ld c, a
	ld b, $03
;> wBattleArg0 = 0
	xor a
	ld [wBattleArg0], a

;>@f for pos in range(side, side + 3):
.loop
;>     if pos == user or CheckBattlerPresent(pos): continue
	ld a, c
	cp d
	jr z, .next

	call CheckBattlerPresent
	jr c, .next

;>     hp = GetBattlerHP(pos)
	ld a, c
	call GetBattlerHP
;>     CountIfHPTenth(pos, hp)
	call CountIfHPTenth
;>@h     if hp >= wSkillAmount: return
	push bc
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	call CompareHLBC
;=@h
	pop bc
	ret nc

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattleArg0: return
	ld a, [wBattleArg0]
	or a
	ret z

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def CountIfHPTenth(pos: c, hp: hl)
;@ path: battle/ai/rules
;@ wBattleArg0 += 1 when `hp` is at most a tenth of the maximum HP of battle position `pos` (at least
;@ 1). Keeps the registers.
;@ test: pos = rand(0, 7)
CountIfHPTenth::
;>@l limit = GetBattlerMaxHP(pos) // 10
	push de
	push bc
	push hl
	ld a, c
	call GetBattlerMaxHP
;=@l
	ld a, $0a
	call Divide16
;> if limit == 0: limit = 1
	ld a, l
	or h
	jr nz, .compare

	inc hl

.compare
;> if limit >= hp: wBattleArg0 = (wBattleArg0 + 1) & 0xFF
	pop bc
	push bc
	call CompareHLBC
	jr c, .done

	ld hl, wBattleArg0
	inc [hl]

.done
;> return
	pop hl
	pop bc
	pop de
	ret


;@ def AIBonusGuardWhenLow()
;@ path: battle/ai/rules
;@ Dodge, StrongD and BladeD ($8C, $8E, $90) get 20 when the user has no more than a tenth of its HP.
;@ test: wSkillUser = rand(0, 7)
AIBonusGuardWhenLow::
;>@k if wSkillId not in (0x8C, 0x8E, 0x90):
	ld a, [wSkillId]
	cp $8d
	ret z

	cp $8f
	ret z

;=@k
	cp $8c
	ret c

	cp $91
;>     return
	ret nc

;>@a wSkillAmount = addr(wBattlerHP) + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	add a
	ld c, a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b wTargetScores = addr(wBattlerMaxHP) + 2 * wSkillUser
	ld a, c
	ld hl, wBattlerMaxHP
	add l
	ld l, a
	ld a, $00
	adc h
;=@b
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;> if HPAboveTenth(): return
	ld a, c
	call HPAboveTenth
	ret c

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleChargeUpDoubled()
;@ path: battle/ai/rules
;@ ChargeUP ($41) is ruled out while the user's attack is doubled (status byte 1 bit 2).
;@ test: wSkillUser = rand(0, 7)
AIRuleChargeUpDoubled::
;> if wSkillId != 0x41: return
	ld a, [wSkillId]
	cp $41
	ret nz

;> if not mem[AddEightTimes(wSkillUser, addr(wBattlerStatus1))] & 0x04: return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNoSpellsToReflect()
;@ path: battle/ai/rules
;@ Only for a smart monster: MagicBack and Bounce ($27, $28) are ruled out unless an enemy present whose
;@ spells are not stopped knows a spell they can turn back (numbers below $1B, Sap, Defence, Slow,
;@ SlowAll or Life).
;@ test: wSkillUser = rand(0, 7)
AIRuleNoSpellsToReflect::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> if not 0x27 <= wSkillId < 0x29: return
	ld a, [wSkillId]
	cp $27
	ret c

	cp $29
	ret nc

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if CheckBattlerPresent(pos) or mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x01: continue
	ld a, c
	call CheckBattlerPresent
	jp c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	jr nz, .next

;>@p     p = addr(wBattlerSkills) + 1 + pos * 16
	ld d, $08
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;>@g     for k in range(8):
.skills
;>         skill = mem[p]
	ld a, [hli]
;>         if skill == 0xFF: break
	cp $ff
	jr z, .next

;>@s         if skill < 0x1B or skill in (0x1C, 0x1D, 0x20, 0x21, 0xDA): return
	cp $1b
	jr c, .keep

	cp $1c
	jr z, .keep

	cp $1d
	jr z, .keep

;=@s
	cp $20
	jr z, .keep

	cp $21
	jr z, .keep

	cp $da
	jr nz, .skip

.keep
;=@s
	ret

.skip
;>         p += 2
	inc hl
;=@g
	dec d
	jr nz, .skills

.next
;=@f
	inc c
	dec b
	jp nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret

	ret

	ret


;@ def AIBonusBreathHeld()
;@ path: battle/ai/rules
;@ The breaths FireAir to WhiteAir ($5C-$63) get 30 while the user holds its breath (SuckAir, status
;@ byte 4 bits 4-5).
;@ test: wSkillUser = rand(0, 7)
AIBonusBreathHeld::
;> if not 0x5C <= wSkillId < 0x64: return
	ld a, [wSkillId]
	cp $5c
	ret c

	cp $64
	ret nc

;> if not mem[AddEightTimes(wSkillUser, addr(wBattlerStatus4))] & 0x30: return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $30
	ret z

;> AddCapped_57(addr(wAttackWeight), 30)
	ld hl, wAttackWeight
	ld b, $1e
	call AddCapped_57
	ret


;@ def AIRuleCurse()
;@ path: battle/ai/rules
;@ Curse ($6F) is ruled out when every enemy present is cursed already (status byte 0 bit 5).
;@ test: wSkillUser = rand(0, 7)
AIRuleCurse::
;> if wSkillId != 0x6F: return
	ld a, [wSkillId]
	cp $6f
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x20: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 5, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleSpellsStopped()
;@ path: battle/ai/rules
;@ StopSpell, MagicBack and Bounce ($17, $27, $28) are ruled out when every enemy present has its spells
;@ stopped already (status byte 1 bit 0).
;@ test: wSkillUser = rand(0, 7)
AIRuleSpellsStopped::
;>@k if wSkillId not in (0x17, 0x27, 0x28): return
	ld a, [wSkillId]
	cp $17
	jr z, .check

	cp $27
	jr z, .check

;=@k
	cp $28
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x01: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleMouthsShut()
;@ path: battle/ai/rules
;@ Barrier, TailWind, StormWind, SuckAll and MouthShut are ruled out when every enemy present has its
;@ mouth bound (status byte 1 bit 7), so no breath can come.
;@ test: wSkillUser = rand(0, 7)
AIRuleMouthsShut::
;>@k if wSkillId not in (0x24, 0x8A, 0x8B, 0x8F, 0x92):
	ld a, [wSkillId]
	cp $24
	jr z, .check

	cp $8a
	jr z, .check

;=@k
	cp $8b
	jr z, .check

	cp $8f
	jr z, .check

	cp $92
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x80: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleDanceShut()
;@ path: battle/ai/rules
;@ DanceShut ($91) is ruled out when every enemy present has its dancing stopped already (status byte 1
;@ bit 6), and for a smart monster also when no enemy knows a dance (PaniDance, KODance, OddDance to
;@ LureDance, DanceShut, Hustle, LifeDance). Each enemy's list is only read up to its first skill
;@ numbered below $75 other than those, and a full list of eight ends the search.
;@ test: wSkillUser = rand(0, 7)
AIRuleDanceShut::
;> if wSkillId != 0x91: return
	ld a, [wSkillId]
	cp $91
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@a if not all(CheckBattlerPresent(pos) or mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x40 for pos in range(side, side + 3)):
	push bc

.loop
;=@a
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@a
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 6, [hl]
	jr z, .found

.next
;=@a
	inc c
	dec b
	jr nz, .loop

;=@a
	pop bc
	jr .out

.found
;>     if not IsUserSmart(): return
	pop bc
	call IsUserSmart
	ret nz

;>@f     for pos in range(side, side + 3):
.loop2
;>         if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next2

;>@p         p = addr(wBattlerSkills) + 1 + pos * 16
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
	ld d, $08

;>@g         for k in range(8):
.skills
;>             skill = mem[p]
	ld a, [hli]
;>             if skill == 0xFF: break
	cp $ff
	jr z, .next2

;>             if skill in (0x6E, 0x71): return
	cp $6e
	ret z

	cp $71
	ret z

;>             if skill < 0x75: break
	cp $75
	jr c, .next2

;>@d             if skill < 0x79 or skill in (0x91, 0x94, 0x96): return
	cp $79
	ret c

	cp $91
	ret z

	cp $94
	ret z

;=@d
	cp $96
	ret z

;>             p += 2
	inc hl
;=@g
	dec d
	jr nz, .skills

;>         else:
;>             break
	jr .out

.next2
;=@f
	inc c
	dec b
	jr nz, .loop2

.out
;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNoSpellUsers()
;@ path: battle/ai/rules
;@ Only for a smart monster: StopSpell, MagicBack and Bounce ($17, $27, $28) are ruled out when no enemy
;@ present knows a spell (a number below $3A, BeDragon, Life or Ironize $DC).
;@ test: wSkillUser = rand(0, 7)
AIRuleNoSpellUsers::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if wSkillId not in (0x17, 0x27, 0x28):
	ld a, [wSkillId]
	cp $17
	jr z, .check

	cp $27
	jr z, .check

;=@k
	cp $28
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@p     p = addr(wBattlerSkills) + 1 + pos * 16
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
	ld d, $08

;>@g     for k in range(8):
.skills
;>         skill = mem[p]
	ld a, [hli]
;>         if skill == 0xFF: break
	cp $ff
	jr z, .next

;>@s         if skill < 0x3A or skill in (0xD5, 0xDA, 0xDC): return
	cp $3a
	ret c

	cp $d5
	ret z

	cp $da
	ret z

;=@s
	cp $dc
	ret z

;>         p += 2
	inc hl
;=@g
	dec d
	jr nz, .skills

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret

	ret


;@ def AIRuleSurge()
;@ path: battle/ai/rules
;@ Surge ($81) is ruled out when no monster of the user's side suffers from anything it cures: any bit
;@ of status byte 0, bits $C3 of byte 1 (spells stopped, illusion, dancing stopped, mouth bound), bit 7
;@ of byte 3 (EerieLite), bits 0-1 of byte 5 (blinded) or bit 7 of byte 6 (a stat went down).
;@ test: wSkillUser = rand(0, 7)
AIRuleSurge::
;> if wSkillId != 0x81: return
	ld a, [wSkillId]
	cp $81
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>     s = AddEightTimes(pos, addr(wBattlerStatus))
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;>@x     if mem[s] or mem[s + 1] & 0xC3 or mem[s + 3] & 0x80 or mem[s + 5] & 0x03 or mem[s + 6] & 0x80: return
	ld a, [hli]
	or a
	ret nz

	ld a, [hli]
	and $c3
	ret nz

;=@x
	inc hl
	ld a, [hli]
	and $80
	ret nz

	inc hl
;=@x
	ld a, [hli]
	and $03
	ret nz

	bit 7, [hl]
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNeedsAlly()
;@ path: battle/ai/rules
;@ Sacrifice, Vivify, Revive, Farewell, NumbOff, DeChaos, Cover, Guardian, LifeSong and LifeDance are
;@ ruled out when fewer than two positions of the user's side hold a monster (wBattlerState not $FF).
;@ test: wSkillUser = rand(0, 7)
AIRuleNeedsAlly::
;>@k if not (wSkillId in (0x14, 0x30, 0x31, 0x32, 0x34, 0x35, 0x88, 0x89, 0x95, 0x96)):
	ld a, [wSkillId]
	cp $14
	jr z, .check

	cp $30
	ret c

	cp $33
;=@k
	ret z

	cp $36
	jr c, .check

	cp $88
	ret c

	cp $8a
;=@k
	jr c, .check

	cp $95
	ret c

	cp $97
;>     return
	ret nc

.check
;>@p p = addr(wBattlerState) + (wSkillUser & 4)
	ld a, [wSkillUser]
	and $04
	ld hl, wBattlerState
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;> filled = 0
	ld b, $03
	ld d, $00

;>@f for k in range(3):
.loop
;>     if mem[p] != 0xFF: filled += 1
;>     p += 1
	ld a, [hli]
	cp $ff
	jr z, .next

	inc d

.next
;=@f
	dec b
	jr nz, .loop

;> if filled >= 2: return
	ld a, d
	cp $02
	ret nc

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIPenaltyGroupVsOne()
;@ path: battle/ai/rules
;@ Skills that hit the whole enemy side (Firebal to Thordain, Defeat, Sacrifice, MultiCut, RainSlash,
;@ Vacuum to MegaMagic, KODance) get a penalty of 20 when only one enemy is present; RainSlash is ruled
;@ out then.
;@ test: wSkillUser = rand(0, 7)
AIPenaltyGroupVsOne::
;>@k if not (0x03 <= wSkillId < 0x12 or wSkillId in (0x13, 0x14, 0x4F, 0x71) or 0x57 <= wSkillId < 0x67 and wSkillId != 0x58):
	ld a, [wSkillId]
	cp $03
	ret c

	cp $12
	jr c, .check

	cp $13
;=@k
	jr z, .check

	cp $14
	jr z, .check

	cp $4f
	jr z, .check

	cp $58
;=@k
	ret z

	cp $57
	ret c

	cp $67
	jr c, .check

	cp $71
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> count = 0
	ld d, $00

;>@f for pos in range(side, side + 3):
.loop
;>     if not CheckBattlerPresent(pos): count += 1
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	inc d

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if count != 1: return
	ld a, d
	cp $01
	ret nz

;> if wSkillId == 0x57:                         # RainSlash
	ld a, [wSkillId]
	cp $57
	jr z, .out

;>@o     AIRuleOut()
;> else:
;>     AddCapped_57(addr(wAIPenalty), 20)
	ld hl, wAIPenalty
	ld b, $14
	call AddCapped_57
	ret

.out
;=@o
	call AIRuleOut
	ret


;@ def AIRuleWindActive()
;@ path: battle/ai/rules
;@ TailWind and StormWind ($8A, $8B) are ruled out while the user has a wind already (status byte 2
;@ bits 3 and 6).
;@ test: wSkillUser = rand(0, 7)
AIRuleWindActive::
;> if not 0x8A <= wSkillId < 0x8C: return
	ld a, [wSkillId]
	cp $8a
	ret c

	cp $8c
	ret nc

;> if not mem[AddEightTimes(wSkillUser, addr(wBattlerStatus2))] & 0x48: return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $48
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleTakeMagicActive()
;@ path: battle/ai/rules
;@ TakeMagic ($1B) is ruled out while the user glows already (status byte 2 bit 0).
;@ test: wSkillUser = rand(0, 7)
AIRuleTakeMagicActive::
;> if wSkillId != 0x1B: return
	ld a, [wSkillId]
	cp $1b
	ret nz

;> if not mem[AddEightTimes(wSkillUser, addr(wBattlerStatus2))] & 0x01: return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleTripImmune()
;@ path: battle/ai/rules
;@ LegSweep and BigTrip ($7B, $7C) are ruled out when every enemy present has type bit 4
;@ (wBattlerTypeBits), which cannot be tripped.
;@ test: wSkillUser = rand(0, 7)
AIRuleTripImmune::
;> if not 0x7B <= wSkillId < 0x7D: return
	ld a, [wSkillId]
	cp $7b
	ret c

	cp $7d
	ret nc

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not wBattlerTypeBits[pos] & 0x10: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	bit 4, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleEerieLite()
;@ path: battle/ai/rules
;@ EerieLite ($74) is ruled out when every enemy present resists it fully (bits 4-5 of resistance byte
;@ 2 at level 3) or is open to spells already (status byte 3 bit 7).
;@ test: skip calls a routine in another bank
AIRuleEerieLite::
;> if wSkillId != 0x74: return
	ld a, [wSkillId]
	cp $74
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>     wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;>     wBattleArg0 = 2
	ld a, $02
	ld [wBattleArg0], a
;>     GetResistByte()
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>@c     if (wBattleArg0 & 0x30) != 0x30 and not mem[AddEightTimes(pos, addr(wBattlerStatus3))] & 0x80: return
	ld a, [wBattleArg0]
	and $30
	cp $30
	jr z, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus3
	call AddEightTimes
	bit 7, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleMagicWallActive()
;@ path: battle/ai/rules
;@ MagicWall ($26) is ruled out when every monster of the user's side is behind a magic wall already
;@ (status byte 3 bit 6).
;@ test: wSkillUser = rand(0, 7)
AIRuleMagicWallActive::
;> if wSkillId != 0x26: return
	ld a, [wSkillId]
	cp $26
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus3))] & 0x40: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus3
	call AddEightTimes
	bit 6, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleSideStepActive()
;@ path: battle/ai/rules
;@ SideStep ($77) is ruled out while the user is side-stepping already (status byte 5 bits 2-3).
;@ test: wSkillUser = rand(0, 7)
AIRuleSideStepActive::
;> if wSkillId != 0x77: return
	ld a, [wSkillId]
	cp $77
	ret nz

;> if not mem[AddEightTimes(wSkillUser, addr(wBattlerStatus5))] & 0x0C: return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleOwnSideBlinded()
;@ path: battle/ai/rules
;@ SandStorm and Radiant ($72, $73) are ruled out when every monster present is blinded (status byte 5
;@ bits 0-1) - of the user's own side, not of the enemies these skills blind.
;@ test: wSkillUser = rand(0, 7)
AIRuleOwnSideBlinded::
;> if not 0x72 <= wSkillId < 0x74: return
	ld a, [wSkillId]
	cp $72
	ret c

	cp $74
	ret nc

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus5))] & 0x03: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $03
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleAllReflect()
;@ path: battle/ai/rules
;@ The spells Blaze to PanicAll, Sap, Defence, Slow, SlowAll and Life are ruled out when every enemy
;@ present reflects them (Bounce or MagicBack, status byte 2 bits 1 and 5).
;@ test: wSkillUser = rand(0, 7)
AIRuleAllReflect::
;>@k if not (wSkillId < 0x1A or wSkillId in (0x1C, 0x1D, 0x20, 0x21, 0xDA)):
	ld a, [wSkillId]
	cp $1a
	jr c, .check

	cp $1c
	ret c

	cp $1e
;=@k
	ret z

	cp $1f
	ret z

	cp $da
	jr z, .check

	cp $22
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus2))] & 0x22: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleAllIronized()
;@ path: battle/ai/rules
;@ Most skills aimed at the enemies (the spells, Ironize, the strong hits, the cuts and breaths, the
;@ status skills from SquallHit to Imitate, UltraDown, Cover, Guardian, Dodge to DanceShut, SmashLime
;@ to the RUN at $DB, and Ahhh $DD) are ruled out when every enemy present is an iron lump (Ironize,
;@ status byte 5 bits 6-7).
;@ test: wSkillUser = rand(0, 7)
AIRuleAllIronized::
;>@k if not (wSkillId < 0x1A or wSkillId in (0x1C, 0x1D, 0x20, 0x21, 0x2A, 0x44, 0x53, 0x82, 0x88, 0x89, 0xDD) or 0x3B <= wSkillId < 0x41 or 0x55 <= wSkillId < 0x80 or 0x8C <= wSkillId < 0x93 or 0xD6 <= wSkillId < 0xDC):
	ld a, [wSkillId]
	cp $1a
	jr c, .check

	cp $1c
	ret c

	cp $1e
;=@k
	jr c, .check

	cp $20
	ret c

	cp $22
	jr c, .check

	cp $2a
;=@k
	jr z, .check

	cp $3b
	ret c

	cp $41
	jr c, .check

	cp $44
;=@k
	jr z, .check

	cp $53
	jr z, .check

	cp $55
	ret c

	cp $80
;=@k
	jr c, .check

	cp $82
	jr z, .check

	cp $88
	ret c

	cp $8a
;=@k
	jr c, .check

	cp $8c
	ret c

	cp $93
	jr c, .check

	cp $d6
;=@k
	ret c

	cp $db
	jr c, .check

	cp $dc
	jr c, .check

	cp $dd
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus5))] & 0xC0: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNoneCanAct()
;@ path: battle/ai/rules
;@ Status skills that only matter for an enemy who acts (Sleep, SleepAll, PanicAll, Ironize, SleepAir,
;@ PalsyAir, PaniDance, Ahhh, SandStorm, Radiant, SideStep, LureDance, SickLick to WarCry, DeMagic to
;@ UltraDown, Cover, Guardian, Dodge, StrongD to BladeD, Life, Ironize $DC) are ruled out when no enemy
;@ can act (CheckBattlerCanAct).
;@ test: wSkillUser = rand(0, 7)
AIRuleNoneCanAct::
;>@k if not (wSkillId in (0x15, 0x16, 0x19, 0x2A, 0x6A, 0x6B, 0x6E, 0x70, 0x72, 0x73, 0x77, 0x78, 0x88, 0x89, 0x8C, 0xDA, 0xDC) or 0x7A <= wSkillId < 0x7E or 0x80 <= wSkillId < 0x83 or 0x8E <= wSkillId < 0x91):
	ld a, [wSkillId]
	cp $15
	ret c

	cp $17
	jr c, .check

	cp $19
;=@k
	jr z, .check

	cp $2a
	jr z, .check

	cp $6a
	ret c

	cp $6c
;=@k
	jr c, .check

	cp $6e
	jr z, .check

	cp $70
	jr z, .check

	cp $72
;=@k
	ret c

	cp $74
	jr c, .check

	cp $77
	ret c

	cp $79
;=@k
	jr c, .check

	cp $7a
	ret c

	cp $7e
	jr c, .check

	cp $80
;=@k
	ret c

	cp $83
	jr c, .check

	cp $88
	ret c

	cp $8a
;=@k
	jr c, .check

	cp $8c
	ret c

	cp $8d
	ret z

	cp $da
;=@k
	jr z, .check

	cp $dc
	jr z, .check

	cp $91
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if not CheckBattlerCanAct(pos): return
	ld a, c
	call CheckBattlerCanAct
	ret nc

;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIBonusResistCanAct()
;@ path: battle/ai/rules
;@ Sleep, SleepAll, PanicAll, NapAttack to PalsyAir, PaniDance, Ahhh, LureDance, LushLicks, LegSweep, BigTrip, WarCry and Life get 20 when the enemies that can act resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistCanAct::
;>@k if not (wSkillId in (0x15, 0x16, 0x19, 0x6E, 0x70, 0x78, 0x79, 0xDA) or 0x68 <= wSkillId < 0x6C or 0x7B <= wSkillId < 0x7E):
	ld a, [wSkillId]
	cp $15
	ret c

	cp $17
	jr c, .check

	cp $19
;=@k
	jr z, .check

	cp $68
	ret c

	cp $6c
	jr c, .check

	cp $6e
;=@k
	jr z, .check

	cp $70
	jr z, .check

	cp $78
	ret c

	cp $7a
;=@k
	ret z

	cp $7e
	jr c, .check

	cp $da
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerCanAct(pos):
	ld a, c
	call CheckBattlerCanAct
	jr c, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIBonusResistUnblinded()
;@ path: battle/ai/rules
;@ Surround, SandStorm and Radiant get 10 when the enemies neither wrapped in an illusion nor blinded resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistUnblinded::
;>@k if not (wSkillId in (0x18, 0x72, 0x73)):
	ld a, [wSkillId]
	cp $18
	jr z, .check

	cp $72
	ret c

	cp $74
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x02 and not mem[AddEightTimes(pos, addr(wBattlerStatus5))] & 0x03:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr nz, .next

	inc hl
;=@c
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	and $03
	jr nz, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistStopSpell()
;@ path: battle/ai/rules
;@ StopSpell gets 30 when the enemies that know a spell and still may cast it resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistStopSpell::
;>@k if not (wSkillId == 0x17):
	ld a, [wSkillId]
	cp $17
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HasNoSpells(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x01:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call HasNoSpells
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@c
	bit 0, [hl]
	jr nz, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 30)
	ld hl, wAttackWeight
	ld b, $1e
	call AddCapped_57
	ret


;@ def AIBonusResistHasMP()
;@ path: battle/ai/rules
;@ StopSpell, OddDance and RobDance get 10 when the enemies with MP left resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistHasMP::
;>@k if not (wSkillId in (0x17, 0x75, 0x76)):
	ld a, [wSkillId]
	cp $17
	jr z, .check

	cp $75
	ret c

	cp $77
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and mem16[addr(wBattlerMP) + 2 * pos] != 0:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@c
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	jr z, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistDefense()
;@ path: battle/ai/rules
;@ SickLick, Sap and Defence get 10 when the enemies whose defense is at least 2 resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistDefense::
;>@k if not (wSkillId in (0x7A, 0x1C, 0x1D)):
	ld a, [wSkillId]
	cp $7a
	jr z, .check

	cp $1c
	ret c

	cp $1e
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and GetBattlerDefense(pos) >= 2:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call GetBattlerDefense
	ld a, l
	cp $02
	jr nc, .add

	ld a, h
;=@c
	or a
	jr z, .next

.add
;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistAgility()
;@ path: battle/ai/rules
;@ Slow and SlowAll get 10 when the enemies whose agility is at least 2 resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistAgility::
;>@k if not (0x20 <= wSkillId < 0x22):
	ld a, [wSkillId]
	cp $20
	ret c

	cp $22
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and WordTableEntry_57(pos, addr(wBattlerAgility)) >= 2:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerAgility
	call WordTableEntry_57
	ld a, l
	cp $02
	jr nc, .add

;=@c
	ld a, h
	or a
	jr z, .next

.add
;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistPoison()
;@ path: battle/ai/rules
;@ PoisonHit, PoisonGas and PoisonAir get 10 when the enemies not poisoned yet resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistPoison::
;>@k if not (wSkillId in (0x67, 0x6C, 0x6D)):
	ld a, [wSkillId]
	cp $67
	jr z, .check

	cp $6c
	ret c

	cp $6e
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x03:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistCurse()
;@ path: battle/ai/rules
;@ Curse gets 10 when the enemies not cursed yet resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistCurse::
;>@k if not (wSkillId == 0x6F):
	ld a, [wSkillId]
	cp $6f
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x20:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $20
	jr nz, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistDanceShut()
;@ path: battle/ai/rules
;@ DanceShut gets 10 when the enemies that know a dance and still may dance resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistDanceShut::
;>@k if not (wSkillId == 0x91):
	ld a, [wSkillId]
	cp $91
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HasNoDances(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x40:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call HasNoDances
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@c
	ld a, [hl]
	and $40
	jr nz, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIBonusResistMouthShut()
;@ path: battle/ai/rules
;@ MouthShut gets 10 when the enemies that know a breath (or SuckAir, SuckAll) and have their mouth free resist it at level 1 or less on
;@ average (their levels add up to no more than their number). The first enemy position is counted
;@ once more by ResistSumStart.
;@ test: skip calls a routine in another bank
AIBonusResistMouthShut::
;>@k if not (wSkillId == 0x92):
	ld a, [wSkillId]
	cp $92
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumStart()
	call ResistSumStart

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HasNoBreathMoves(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x80:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call HasNoBreathMoves
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@c
	ld a, [hl]
	and $80
	jr nz, .next

;>         ResistSumAdd(pos, byte, pair)
	call ResistSumAdd

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if not wBattlerReload or wBattlerReload < wItemMsgGroup: return
	ld a, [wBattlerReload]
	or a
	ret z

	ld hl, wItemMsgGroup
	cp [hl]
	ret c

;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIRuleImmuneCanAct()
;@ path: battle/ai/rules
;@ Sleep, SleepAll, PanicAll, NapAttack to PalsyAir, PaniDance, Ahhh, LureDance, LushLicks, LegSweep, BigTrip, WarCry and Life are ruled out when every enemy that can act resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneCanAct::
;>@k if not (wSkillId in (0x15, 0x16, 0x19, 0x6E, 0x70, 0x78, 0x79, 0xDA) or 0x68 <= wSkillId < 0x6C or 0x7B <= wSkillId < 0x7E):
	ld a, [wSkillId]
	cp $15
	ret c

	cp $17
	jr c, .check

	cp $19
;=@k
	jr z, .check

	cp $68
	ret c

	cp $6c
	jr c, .check

	cp $6e
;=@k
	jr z, .check

	cp $70
	jr z, .check

	cp $78
	ret c

	cp $7a
;=@k
	ret z

	cp $7e
	jr c, .check

	cp $da
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerCanAct(pos) and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerCanAct
	jr c, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneUnblinded()
;@ path: battle/ai/rules
;@ Surround, SandStorm and Radiant are ruled out when every enemy neither wrapped in an illusion nor blinded resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneUnblinded::
;>@k if not (wSkillId in (0x18, 0x72, 0x73)):
	ld a, [wSkillId]
	cp $18
	jr z, .check

	cp $72
	ret c

	cp $74
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x02 and not mem[AddEightTimes(pos, addr(wBattlerStatus5))] & 0x03 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr nz, .next

	inc hl
;=@c
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	and $03
	jr nz, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def MinEnemyDefense() -> e
;@ path: battle/ai/rules
;@ Puts the lowest defense among the enemies present into wSkillAmount (0 when the first enemy position
;@ is empty). Returns the position after the enemy side's third (3 or 7).
;@ test: wSkillUser = rand(0, 7)
MinEnemyDefense::
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld e, a
;>@w wSkillAmount = 0 if CheckBattlerPresent(side) else GetBattlerDefense(side)
	ld hl, $0000
	call CheckBattlerPresent
	jr c, .store

	call GetBattlerDefense

.store
;=@w
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@f for pos in range(side + 1, side + 3):
	inc e
	ld d, $02

.loop
;>@c     if not CheckBattlerPresent(pos) and GetBattlerDefense(pos) < wSkillAmount:
	ld a, e
	call CheckBattlerPresent
	jr c, .next

	call GetBattlerDefense
	ld a, [wSkillAmount]
	ld c, a
;=@c
	ld a, [wSkillAmount + 1]
	ld b, a
	call CompareHLBC
	jr nc, .next

;>         wSkillAmount = GetBattlerDefense(pos)
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.next
;=@f
	inc e
	dec d
	jr nz, .loop

;> return side + 3
	ret


;@ def AttackFarFromDefense(pos: e) -> carry
;@ path: battle/ai/rules
;@ Carry when the attack of battle position `pos` is below half of wSkillAmount (the enemies' lowest
;@ defense) or at least twice it; no carry when it is in between.
;@ test: pos = rand(0, 7)
AttackFarFromDefense::
;> half = wSkillAmount >> 1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	srl b
	rr c
;> attack = GetBattlerAttack(pos)
	ld a, e
	call GetBattlerAttack
;>@r return attack < half or attack >> 1 >= wSkillAmount
	call CompareHLBC
	jr c, .far

;=@r
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	srl h
	rr l
;=@r
	call CompareHLBC
	jr nc, .far

	xor a
	or a
	ret

.far
;=@r
	scf
	ret


;@ def AIRuleOutIfResistByte4(first: c, count: b)
;@ path: battle/ai/rules
;@ Rules the skill out when every monster present among the `count` positions from `first` on has both
;@ resistances in bits 2-5 of its resistance byte 4 (numbers 17 and 18) at level 3.
;@ test: skip calls a routine in another bank
AIRuleOutIfResistByte4::
;>@f for pos in range(first, first + count):
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;>         wBattleArg0 = 4
	ld a, $04
	ld [wBattleArg0], a
;>         GetResistByte()
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>         if (wBattleArg0 & 0x3C) != 0x3C: return
	ld a, [wBattleArg0]
	and $3c
	cp $3c
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, AIRuleOutIfResistByte4

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def GetUserSideCount() -> b
;@ path: battle/ai/rules
;@ Number of monsters on the skill user's side (wPartyBattlers or wEnemyCount).
;@ test: wSkillUser = rand(0, 7)
GetUserSideCount::
;>@r return wPartyBattlers if wSkillUser < 4 else wEnemyCount
	ld a, [wSkillUser]
	cp $04
	jr nc, .enemy

	ld a, [wPartyBattlers]
	jr .done

.enemy
;=@r
	ld a, [wEnemyCount]

.done
;=@r
	ld b, a
	ret


;@ def AIRuleImmuneStopSpell()
;@ path: battle/ai/rules
;@ StopSpell is ruled out when every enemy that knows a spell and still may cast it resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneStopSpell::
;>@k if not (wSkillId == 0x17):
	ld a, [wSkillId]
	cp $17
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HasNoSpells(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x01 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call HasNoSpells
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@c
	bit 0, [hl]
	jr nz, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneHasMP()
;@ path: battle/ai/rules
;@ RobMagic, OddDance and RobDance are ruled out when every enemy with MP left resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneHasMP::
;>@k if not (wSkillId in (0x1A, 0x75, 0x76)):
	ld a, [wSkillId]
	cp $1a
	jr z, .check

	cp $75
	ret c

	cp $77
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and mem16[addr(wBattlerMP) + 2 * pos] != 0 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@c
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	jr z, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneDefense()
;@ path: battle/ai/rules
;@ Sap, Defence and SickLick are ruled out when every enemy whose defense is at least 2 resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneDefense::
;>@k if not (wSkillId in (0x1C, 0x1D, 0x7A)):
	ld a, [wSkillId]
	cp $1c
	ret c

	cp $1e
	jr c, .check

	cp $7a
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and GetBattlerDefense(pos) >= 2 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call GetBattlerDefense
	ld a, l
	cp $02
	jr nc, .add

	ld a, h
;=@c
	or a
	jr z, .next

.add
;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneAgility()
;@ path: battle/ai/rules
;@ Slow and SlowAll are ruled out when every enemy whose agility is at least 2 resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneAgility::
;>@k if not (0x20 <= wSkillId < 0x22):
	ld a, [wSkillId]
	cp $20
	ret c

	cp $22
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and WordTableEntry_57(pos, addr(wBattlerAgility)) >= 2 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerAgility
	call WordTableEntry_57
	ld a, l
	cp $02
	jr nc, .add

;=@c
	ld a, h
	or a
	jr z, .next

.add
;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmunePoison()
;@ path: battle/ai/rules
;@ PoisonHit, PoisonGas and PoisonAir are ruled out when every enemy not poisoned yet resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmunePoison::
;>@k if not (wSkillId in (0x67, 0x6C, 0x6D)):
	ld a, [wSkillId]
	cp $67
	jr z, .check

	cp $6c
	ret c

	cp $6e
;>     return
	ret nc

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x03 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneCurse()
;@ path: battle/ai/rules
;@ Curse is ruled out when every enemy not cursed yet resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneCurse::
;>@k if not (wSkillId == 0x6F):
	ld a, [wSkillId]
	cp $6f
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x20 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $20
	jr nz, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneDanceShut()
;@ path: battle/ai/rules
;@ DanceShut is ruled out when every enemy that knows a dance and still may dance resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneDanceShut::
;>@k if not (wSkillId == 0x91):
	ld a, [wSkillId]
	cp $91
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HasNoDances(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x40 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call HasNoDances
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@c
	ld a, [hl]
	and $40
	jr nz, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleImmuneMouthShut()
;@ path: battle/ai/rules
;@ MouthShut is ruled out when every enemy that knows a breath (or SuckAir, SuckAll) and has its mouth free resists it at level 3.
;@ test: skip calls a routine in another bank
AIRuleImmuneMouthShut::
;>@k if not (wSkillId == 0x92):
	ld a, [wSkillId]
	cp $92
;>     return
	ret nz

.check
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit

;>@f for pos in range(side, side + count):
.loop
;>@c     if not CheckBattlerPresent(pos) and not HasNoBreathMoves(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0x80 and ResistLevelOf(pos, byte, pair) != 3:
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	call HasNoBreathMoves
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@c
	ld a, [hl]
	and $80
	jr nz, .next

;=@c
	call ResistLevelOf
	cp $03
;>         return
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleSacrificeLowHP()
;@ path: battle/ai/rules
;@ Meant to rule out Sacrifice, Farewell and LifeDance ($14, $32, $96) when every monster of the
;@ user's side is down to a quarter of its HP. The limit is worked out from the address of the maximum
;@ HP (shifted right twice, keeping the sign) instead of from the HP, which no HP reaches, so the skills
;@ are ruled out whenever all three positions of the user's side hold a monster in the fight.
;@ test: wSkillUser = rand(0, 7)
AIRuleSacrificeLowHP::
;>@k if not (wSkillId in (0x14, 0x32, 0x96)):
	ld a, [wSkillId]
	cp $14
	jr z, .check

	cp $32
	jr z, .check

	cp $96
;>     return
	ret nz

.check
;> wAIAlliesHPQuarter = 0
	xor a
	ld [wAIAlliesHPQuarter], a
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@x     if CheckBattlerPresent(pos): return
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .leave

;>@a     wSkillAmount = addr(wBattlerHP) + 2 * pos
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
;=@a
	ld [wSkillAmount + 1], a
;>@b     wTargetScores = addr(wBattlerMaxHP) + 2 * pos
	ld a, c
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
;=@b
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
;=@b
	ld [wTargetScores + 1], a
;>@h     hp = mem16[wSkillAmount]
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@h
	ld l, a
	push hl
;>@m     maxhp = mem16[wTargetScores]              # read, but not used
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@m
	ld l, a
;>@l     limit = (wTargetScores >> 2 | (0xC000 if wTargetScores & 0x8000 else 0)) if wTargetScores >= 0x100 else wTargetScores
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, h
	or a
;=@l
	jr nz, .big

;=@l
	ld a, e
	rrca
	rrca
	and $3f
	or a
	jr z, .one

;=@l
	ld e, a
	jr .compare

.one
;=@l
	ld e, $01
	jr .compare

.big
;=@l
	sra h
	rr l
	sra h
	rr l

.compare
;>     if limit < hp: return
	pop bc
	call CompareHLBC
	jr c, .leave

;>     wAIAlliesHPQuarter += 1
	ld hl, wAIAlliesHPQuarter
	inc [hl]
;=@f
	pop bc
	inc c
	dec b
	jr nz, .loop

;> if not wAIAlliesHPQuarter: return
	ld a, [wAIAlliesHPQuarter]
	or a
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret

.leave
;=@x
	pop bc
	ret


;@ def AIPenaltyImitated()
;@ path: battle/ai/rules
;@ Only for a smart monster: skills an imitator would copy (the spells Firebal to PanicAll but Beat and
;@ Sleep, Defence, SlowAll, Ramming, Kamikaze, MultiCut, CallHelp, YellHelp, RainSlash, Vacuum to
;@ MegaMagic, SleepAir to Curse, KODance, BigTrip, WarCry, BeDragon, GigaSlash, Life, Ironize $DC) get a
;@ penalty of 30 when an enemy present is imitating (Imitate, status byte 6 bit 3).
;@ test: wSkillUser = rand(0, 7)
AIPenaltyImitated::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if not (0x03 <= wSkillId < 0x1A and wSkillId not in (0x12, 0x15) or wSkillId in (0x1D, 0x21, 0x3C, 0x3E, 0x4F, 0x52, 0x53, 0x57, 0x71, 0x7C, 0x7D, 0xD5, 0xD9, 0xDA, 0xDC) or 0x59 <= wSkillId < 0x67 or 0x6A <= wSkillId < 0x70):
	ld a, [wSkillId]
	cp $03
	ret c

	cp $12
	ret z

	cp $15
;=@k
	ret z

	cp $1a
	jr c, .check

	cp $1d
	jr z, .check

	cp $21
;=@k
	jr z, .check

	cp $3c
	ret c

	cp $3d
	ret z

	cp $3f
;=@k
	jr c, .check

	cp $4f
	ret c

	jr z, .check

	cp $52
	ret c

;=@k
	jr z, .check

	cp $53
	jr z, .check

	cp $57
	ret c

	jr z, .check

;=@k
	cp $59
	ret c

	cp $67
	jr c, .check

	cp $6a
	ret c

;=@k
	cp $70
	ret z

	cp $72
	jr c, .check

	cp $7c
	ret c

;=@k
	cp $7e
	jr c, .check

	cp $d5
	jr z, .check

	cp $d9
	jr z, .check

;=@k
	cp $da
	jr z, .check

	cp $dc
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@w if any(not CheckBattlerPresent(pos) and IsImitating(pos) for pos in range(side, side + 3)):
.loop
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	call IsImitating
	jr nz, .penalty

;>@p     AddCapped_57(addr(wAIPenalty), 30)
.next
;=@w
	inc c
	dec b
	jr nz, .loop

	ret

.penalty
;=@p
	ld hl, wAIPenalty
	ld b, $1e
	call AddCapped_57
	ret


;@ def AIPenaltyAllImitating()
;@ path: battle/ai/rules
;@ Only for a smart monster: many skills (Blaze to Sap, Upper, Increase, Slow, SlowAll, TwinSlash to
;@ Imitate but ChargeUP, SuckAir, Focus and SideStep, UltraDown, DanceShut, MouthShut, BeDragon to
;@ GigaSlash, Life, Ironize $DC) get a penalty of 20 unless an enemy present is not imitating - so also
;@ when no enemy is present.
;@ test: wSkillUser = rand(0, 7)
AIPenaltyAllImitating::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if not (wSkillId < 0x1E and wSkillId != 0x1B or wSkillId in (0x20, 0x21, 0x82, 0x91, 0x92, 0xDA, 0xDC) or 0x3B <= wSkillId < 0x7E and wSkillId not in (0x41, 0x43, 0x54, 0x77) or 0xD5 <= wSkillId < 0xDA):
	ld a, [wSkillId]
	cp $1b
	ret z

	cp $1e
	jr c, .check

	cp $20
;=@k
	ret c

	cp $22
	jr c, .check

	cp $3b
	ret c

	cp $41
;=@k
	ret z

	cp $43
	ret z

	cp $54
	ret z

	cp $77
;=@k
	ret z

	cp $7e
	jr c, .check

	cp $82
	jr z, .check

	cp $91
;=@k
	ret c

	cp $93
	jr c, .check

	cp $d5
	ret c

	cp $da
;=@k
	jr z, .check

	cp $dc
	jr z, .check

	cp $da
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if not CheckBattlerPresent(pos) and not IsImitating(pos): return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	call IsImitating
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AddCapped_57(addr(wAIPenalty), 20)
	ld hl, wAIPenalty
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleNoEnemyMP()
;@ path: battle/ai/rules
;@ Only for a smart monster: StopSpell, RobMagic, TakeMagic, Barrier, MagicWall, MagicBack, Bounce,
;@ OddDance, RobDance, TailWind, StormWind, SuckAll and MouthShut are ruled out when no enemy present
;@ has MP left.
;@ test: wSkillUser = rand(0, 7)
AIRuleNoEnemyMP::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;>@k if not (wSkillId in (0x17, 0x1A, 0x1B, 0x24, 0x26, 0x27, 0x28, 0x75, 0x76, 0x8A, 0x8B, 0x8F, 0x92)):
	ld a, [wSkillId]
	cp $17
	jr z, .check

	cp $1a
	jr z, .check

	cp $1b
;=@k
	jr z, .check

	cp $24
	jr z, .check

	cp $26
	ret c

	cp $29
;=@k
	jr c, .check

	cp $75
	ret c

	cp $77
	jr c, .check

	cp $8a
;=@k
	ret c

	cp $8c
	jr c, .check

	cp $8f
	jr z, .check

	cp $92
;>     return
	ret nz

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and mem16[addr(wBattlerMP) + 2 * pos] != 0: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
;=@c
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleAntidote()
;@ path: battle/ai/rules
;@ Antidote ($33) is ruled out when no monster of the user's side is poisoned (status byte 0 bits 0-1).
;@ test: wSkillUser = rand(0, 7)
AIRuleAntidote::
;> if wSkillId != 0x33: return
	ld a, [wSkillId]
	cp $33
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and mem[AddEightTimes(pos, addr(wBattlerStatus))] & 0x03: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	ret nz

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIBonusRamming()
;@ path: battle/ai/rules
;@ Ramming and Kamikaze ($3C, $3E) get 20 when an enemy present has more HP than 1.5 times the user's.
;@ test: wSkillUser = rand(0, 7)
AIBonusRamming::
;> if wSkillId not in (0x3C, 0x3E): return
	ld a, [wSkillId]
	cp $3c
	jr z, .check

	cp $3e
	ret nz

.check
;>@h wSkillAmount = (GetBattlerHP(wSkillUser) + (GetBattlerHP(wSkillUser) >> 1)) & 0xFFFF
	ld a, [wSkillUser]
	call GetBattlerHP
	ld b, h
	ld c, l
	srl b
	rr c
;=@h
	add hl, bc
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@w if any(not CheckBattlerPresent(pos) and mem16[addr(wBattlerHP) + 2 * pos] > wSkillAmount for pos in range(side, side + 3)):
.loop
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@w
	push bc
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
;=@w
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@w
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call CompareHLBC
	pop bc
;=@w
	jr z, .next

	jr c, .bonus

;>@b     AddCapped_57(addr(wAttackWeight), 20)
.next
;=@w
	inc c
	dec b
	jr nz, .loop

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleCallTaken()
;@ path: battle/ai/rules
;@ TatsuCall, DiagoCall, SamsiCall and BazooCall ($84-$87) are ruled out once a monster has been called
;@ on the user's side (wSideFlags bit 2) and still stands in that side's fourth position (3 or 7).
;@ test: wSkillUser = rand(0, 7)
AIRuleCallTaken::
;> if not 0x84 <= wSkillId < 0x88: return
	ld a, [wSkillId]
	cp $84
	ret c

	cp $88
	ret nc

;>@s if not wSideFlags[(wSkillUser & 4) >> 2] & 0x04: return
	ld a, [wSkillUser]
	and $04
	srl a
	srl a
	ld hl, wSideFlags
	add l
;=@s
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 2, [hl]
	ret z

;> if CheckBattlerPresent((wSkillUser & 4) + 3): return
	ld a, [wSkillUser]
	and $04
	add $03
	call CheckBattlerPresent
	ret c

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNoLatePrep()
;@ path: battle/ai/rules
;@ First rule of every list: Ironize, SquallHit, PsycheUp, Imitate, Cover, Guardian, Dodge to BladeD
;@ and Ironize $DC, which have to come at the start of a turn, are ruled out when the skill is chosen
;@ during the actions of the turn (battle sub-step $15 or later) instead of with the commands.
;@ test: wBattleSubStep = rand(0, 0x20)
AIRuleNoLatePrep::
;>@k if not (wSkillId in (0x2A, 0x55, 0x56, 0x7F, 0x88, 0x89, 0xDC) or 0x8C <= wSkillId < 0x91):
	ld a, [wSkillId]
	cp $2a
	jr z, .check

	cp $55
	ret c

	cp $57
;=@k
	jr c, .check

	cp $7f
	jr z, .check

	cp $88
	ret c

	cp $8a
;=@k
	jr c, .check

	cp $8c
	ret c

	cp $91
	jr c, .check

	cp $dc
;>     return
	ret nz

.check
;> if wBattleSubStep < 0x15: return
	ld a, [wBattleSubStep]
	cp $15
	ret c

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleNoneFallen()
;@ path: battle/ai/rules
;@ Vivify, Revive and LifeSong ($30, $31, $95) are ruled out when no monster of the user's side has
;@ fallen (in its place but out of the fight).
;@ test: wSkillUser = rand(0, 7)
AIRuleNoneFallen::
;>@k if not (wSkillId == 0x95 or 0x30 <= wSkillId < 0x32):
	ld a, [wSkillId]
	cp $95
	jr z, .check

	cp $30
	ret c

	cp $32
;>     return
	ret nc

.check
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos) and wBattlerState[pos] != 0xFF: return
	ld a, c
	call CheckBattlerPresent
	jr z, .next

	ret c

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIBonusSurge()
;@ path: battle/ai/rules
;@ Surge ($81) gets 15 when a monster of the user's side has its spells stopped, an illusion, its
;@ dancing stopped or its mouth bound (status byte 1 bits $C3), is blinded (status byte 5 bits 0-1) or
;@ had a stat lowered (status byte 6 bit 7).
;@ test: wSkillUser = rand(0, 7)
AIBonusSurge::
;> if wSkillId != 0x81: return
	ld a, [wSkillId]
	cp $81
	ret nz

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03
;>@w if any(not CheckBattlerPresent(pos) and (mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 0xC3 or mem[AddEightTimes(pos, addr(wBattlerStatus5))] & 0x03 or mem[AddEightTimes(pos, addr(wBattlerStatus6))] & 0x80) for pos in range(side, side + 3)):
.loop
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@w
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, [hli]
	and $c3
	jr nz, .bonus

;=@w
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	and $03
	jr nz, .bonus

;=@w
	ld a, [hl]
	and $80
	jr nz, .bonus

;>@b     AddCapped_57(addr(wAttackWeight), 15)
.next
;=@w
	inc c
	dec b
	jr nz, .loop

	ret

.bonus
;=@b
	ld hl, wAttackWeight
	ld b, $0f
	call AddCapped_57
	ret


;@ def AIBonusUserBlinded()
;@ path: battle/ai/rules
;@ The attack spells, MultiCut and WindBeast to PoisonHit ($00-$13, $4F, $58-$66), which do not depend on
;@ seeing the target, get 10 while the user is wrapped in an illusion (status byte 1 bit 1) or blinded
;@ (status byte 5 bits 0-1).
;@ test: wSkillUser = rand(0, 7)
AIBonusUserBlinded::
;>@k if not (wSkillId < 0x14 or wSkillId == 0x4F or 0x58 <= wSkillId < 0x67):
	ld a, [wSkillId]
	cp $14
	jr c, .check

	cp $4f
	jr z, .check

	cp $58
;=@k
	ret c

	cp $67
;>     return
	ret nc

.check
;> if CheckBattlerPresent(wSkillUser): return
	ld a, [wSkillUser]
	call CheckBattlerPresent
	ret c

;>@b if not (mem[AddEightTimes(wSkillUser, addr(wBattlerStatus1))] & 0x02 or mem[AddEightTimes(wSkillUser, addr(wBattlerStatus5))] & 0x03): return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, [hli]
	and $02
	jr nz, .bonus

;=@b
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	and $03
	jr nz, .bonus

;=@b
	ret

.bonus
;> AddCapped_57(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped_57
	ret


;@ def AIRuleSlayerNoTarget()
;@ path: battle/ai/rules
;@ The cuts that hit one family harder are ruled out when no enemy present is of that family: MetalCut
;@ needs one with type bit 0 (wBattlerTypeBits), DrakSlash a dragon (family 1), BeastCut a beast (2),
;@ BirdBlow a bird (3), DevilCut a devil (6), ZombieCut a zombie (7), CleanCut a material (8), SmashLime a
;@ slime (0), ShellDodge a bug (5) and Branching a plant (4). The family is byte 0 of the monster's
;@ MonsterStats record (GetMonsterStats).
;@ test: skip calls a routine in another bank
AIRuleSlayerNoTarget::
;>@k if not (0x48 <= wSkillId < 0x4F or 0xD6 <= wSkillId < 0xD9): return
	ld a, [wSkillId]
	cp $48
	ret c

;>@i index = wSkillId - 0x48 if wSkillId < 0x4F else wSkillId - 0xD6 + 7
	cp $4f
	jr c, .cuts

;=@k
	cp $d6
	ret c

	cp $d9
	ret nc

;=@i
	sub $cf
	jr .dispatch

.cuts
;=@i
	sub $48

.dispatch
;> if index == 0:                              # MetalCut
	rst $00

	dw .metal
	dw .dragon
	dw .beast
	dw .bird
	dw .devil
	dw .zombie
	dw .material
	dw .slime
	dw .bug
	dw .plant

.metal
;>     side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f     for pos in range(side, side + 3):
.metalLoop
;>@c         if not CheckBattlerPresent(pos) and wBattlerTypeBits[pos] & 1: return
	ld a, c
	call CheckBattlerPresent
	jr c, .metalNext

;=@c
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	bit 0, [hl]
	ret nz

.metalNext
;=@f
	inc c
	dec b
	jr nz, .metalLoop

;>@o     AIRuleOut()
	jp .out


.dragon
;> else:
;>@s2     side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;>@n     wBattleArg0 = (1, 2, 3, 6, 7, 8, 0, 5, 4)[index - 1]     # the family
	ld a, $01
	ld [wBattleArg0], a

;>@g     for pos in range(side, side + 3):
.familyLoop
;>         if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .familyNext

;>@m         wMonSpecies = wBattlerSpecies[pos]
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld a, [hl]
	ld [wMonSpecies], a
;>         GetMonsterStats()
	push bc
	ld hl, far_GetMonsterStats
	rst $10
	pop bc
;>         if wMonStats[0] == wBattleArg0: return
	ld a, [wMonStats]
	ld hl, wBattleArg0
	cp [hl]
	ret z

.familyNext
;=@g
	inc c
	dec b
	jr nz, .familyLoop

;>@p     AIRuleOut()
	jp .out


.beast
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $02
	ld [wBattleArg0], a
	jr .familyLoop

.bird
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $03
	ld [wBattleArg0], a
	jr .familyLoop

.devil
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $06
	ld [wBattleArg0], a
	jr .familyLoop

.zombie
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $07
	ld [wBattleArg0], a
	jr .familyLoop

.material
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $08
	ld [wBattleArg0], a
	jr .familyLoop

.slime
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $00
	ld [wBattleArg0], a
	jp .familyLoop

.bug
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $05
	ld [wBattleArg0], a
	jp .familyLoop

.plant
;=@s2
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;=@n
	ld a, $04
	ld [wBattleArg0], a
	jp .familyLoop


.out
;=@o
	call AIRuleOut
;=@p
	ret


;@ def AIRuleSuckAirHeld()
;@ path: battle/ai/rules
;@ SuckAir ($43) is ruled out while the user holds its breath already (status byte 4 bits 4-5).
;@ test: wSkillUser = rand(0, 7)
AIRuleSuckAirHeld::
;> if wSkillId != 0x43: return
	ld a, [wSkillId]
	cp $43
	ret nz

;> if not mem[AddEightTimes(wSkillUser, addr(wBattlerStatus4))] & 0x30: return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $30
	ret z

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleUltraDownUseless()
;@ path: battle/ai/rules
;@ UltraDown ($82) is ruled out when every enemy present either resists it fully (bits 4-5 of
;@ resistance byte 2 at level 3) or has agility and defense down to 1 or less and is wrapped in an
;@ illusion already (status byte 1 bit 1).
;@ test: skip calls a routine in another bank
AIRuleUltraDownUseless::
;> if wSkillId != 0x82: return
	ld a, [wSkillId]
	cp $82
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>     wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;>     wBattleArg0 = 2
	ld a, $02
	ld [wBattleArg0], a
;>     GetResistByte()
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>     if (wBattleArg0 & 0x30) == 0x30: continue
	ld a, [wBattleArg0]
	and $30
	cp $30
	jr z, .next

;>     if not IsZeroOrOne(WordTableEntry_57(pos, addr(wBattlerAgility))): return
	ld a, c
	ld hl, wBattlerAgility
	call WordTableEntry_57
	call IsZeroOrOne
	ret nc

;>     if not IsZeroOrOne(WordTableEntry_57(pos, addr(wBattlerDefense))): return
	ld a, c
	ld hl, wBattlerDefense
	call WordTableEntry_57
	call IsZeroOrOne
	ret nc

;>     if not mem[AddEightTimes(pos, addr(wBattlerStatus1))] & 2: return
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIPenaltyDeMagicHelpsFoes()
;@ path: battle/ai/rules
;@ DeMagic ($80) gets a penalty of 20 when an enemy present suffers from something it would lift: an
;@ illusion, dancing stopped or mouth bound (status byte 1 bits 1, 6, 7), status byte 2 bit 4, blinded
;@ (status byte 5 bits 0-1) or a stat that went down (status byte 6 bit 7).
;@ test: wSkillUser = rand(0, 7)
AIPenaltyDeMagicHelpsFoes::
;> if wSkillId != 0x80: return
	ld a, [wSkillId]
	cp $80
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@s     s = AddEightTimes(pos, addr(wBattlerStatus))
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
;>@t     if mem[s + 1] & 0xC2 or mem[s + 2] & 0x10 or mem[s + 5] & 0x03 or mem[s + 6] & 0x80:
	ld a, [hli]
	and $c2
	jr nz, .penalty

;=@t
	ld a, [hli]
	and $10
	jr nz, .penalty

	ld a, [hli]
	inc hl
;=@t
	ld a, [hli]
	and $03
	jr nz, .penalty

	ld a, [hl]
	and $80
	jr z, .next

.penalty
;>         AddCapped_57(addr(wAIPenalty), 20)
;>         return
	ld hl, wAIPenalty
	ld b, $14
	call AddCapped_57
	ret


.next
;=@f
	inc c
	dec b
	jr nz, .loop

	ret


;@ def AIRuleAllInSky()
;@ path: battle/ai/rules
;@ The skills that have to reach the target (TwinSlash to EvilSlash, FireSlash to CleanCut, BiAttack to
;@ YellHelp, SquallHit to RainSlash, PoisonHit to Paralyze, Ahhh, LushLicks to BigTrip, SmashLime to
;@ GigaSlash) are ruled out when every enemy present is high in the sky (status byte 4 bits 2-3).
;@ test: wSkillUser = rand(0, 7)
AIRuleAllInSky::
;>@k if not (0x3B <= wSkillId < 0x41 or 0x44 <= wSkillId < 0x4F or 0x50 <= wSkillId < 0x54 or 0x55 <= wSkillId < 0x58 or 0x67 <= wSkillId < 0x6A or wSkillId == 0x70 or 0x79 <= wSkillId < 0x7D or 0xD6 <= wSkillId < 0xDA):
	ld a, [wSkillId]
	cp $3b
	ret c

	cp $41
	jr c, .check

	cp $44
;=@k
	ret c

	cp $4f
	jr c, .check

	cp $50
	ret c

	cp $54
;=@k
	jr c, .check

	cp $55
	ret c

	cp $58
	jr c, .check

	cp $67
;=@k
	ret c

	cp $6a
	jr c, .check

	cp $70
	jr z, .check

	cp $79
;=@k
	ret c

	cp $7d
	jr c, .check

	cp $d6
	ret c

	cp $da
;>     return
	ret nc

.check
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>@c     if not CheckBattlerPresent(pos) and not mem[AddEightTimes(pos, addr(wBattlerStatus4))] & 0x0C: return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;=@c
	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret z

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleSquallHitSlowFoes()
;@ path: battle/ai/rules
;@ SquallHit ($55) is ruled out when no enemy present has more agility than 3/10 of the user's.
;@ test: wSkillUser = rand(0, 7)
AIRuleSquallHitSlowFoes::
;> if wSkillId != 0x55: return
	ld a, [wSkillId]
	cp $55
	ret nz

;>@a limit = (mem16[addr(wBattlerAgility) + 2 * wSkillUser] * 3 & 0xFFFF) // 10
	ld a, [wSkillUser]
	ld hl, wBattlerAgility
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
	ld b, h
;=@a
	ld c, l
	add hl, bc
	add hl, bc
	ld a, $0a
	call Divide16
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@g     if limit < mem16[addr(wBattlerAgility) + 2 * pos]: return
	push bc
	push hl
	ld a, c
	ld hl, wBattlerAgility
	add a
	add l
;=@g
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
;=@g
	ld c, a
	pop hl
	call CompareHLBC
	pop bc
	ret c

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleMPAlmostFull()
;@ path: battle/ai/rules
;@ RobMagic, TakeMagic and RobDance ($1A, $1B, $76) are ruled out while the user has more than 3/4 of
;@ its maximum MP.
;@ test: wSkillUser = rand(0, 7)
AIRuleMPAlmostFull::
;>@k if not (wSkillId in (0x1A, 0x1B, 0x76)):
	ld a, [wSkillId]
	cp $1a
	jr z, .check

	cp $1b
	jr z, .check

	cp $76
;>     return
	ret nz

.check
;>@m mp = mem16[addr(wBattlerMP) + 2 * wSkillUser]
	ld a, [wSkillUser]
	add a
	ld hl, wBattlerMP
	add l
	ld l, a
	ld a, $00
;=@m
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>@x top = mem16[addr(wBattlerMaxMP) + 2 * wSkillUser]
	ld a, [wSkillUser]
	add a
	ld hl, wBattlerMaxMP
	add l
	ld l, a
	ld a, $00
;=@x
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@y limit = (top >> 1) + (top >> 2)
	srl h
	rr l
	ld d, h
	ld e, l
	srl h
	rr l
;=@y
	add hl, de
;> if limit >= mp: return
	call CompareHLBC
	ret nc

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleThickFogNoBigSpells()
;@ path: battle/ai/rules
;@ ThickFog ($83) is ruled out when no enemy present knows one of the strongest attack spells (Blazemost,
;@ Firebolt, Explodet, Infermost, Blizzard, Thordain, Beat, Defeat; skill kind 1). A second loop over the
;@ user's side would also rule it out when two healing spells (Heal to Farewell, $2B-$32) are known
;@ there, but it compares the kind byte (1 at that point) instead of the skill number, so it never
;@ counts one and the routine just returns.
;@ test: wSkillUser = rand(0, 7)
AIRuleThickFogNoBigSpells::
;> if wSkillId != 0x83: return
	ld a, [wSkillId]
	cp $83
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;> found = False
;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@p     p = addr(wBattlerSkills) + pos * 16
	ld a, c
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
;>@g     for k in range(8):
	ld d, $08

.skills
;>         kind = mem[p]; p += 1
	ld a, [hli]
;>         if kind == 0: break
	or a
	jr z, .next

;>@b         if kind == 1 and (mem[p] in (0x02, 0x05, 0x08, 0x0B, 0x0E) or 0x11 <= mem[p] < 0x14):
	cp $01
	jr nz, .skip

	ld a, [hl]
	cp $02
	jr z, .found

;=@b
	cp $05
	jr z, .found

	cp $08
	jr z, .found

	cp $0b
	jr z, .found

;=@b
	cp $0e
	jr z, .found

	cp $11
	jr c, .skip

	cp $14
	jr c, .found

;>             found = True; break
.skip
;>         p += 1
;=@g
	inc hl
	dec d
	jr nz, .skills

;>     if found: break
.next
;=@f
	inc c
	dec b
	jr nz, .loop

;>@o if not found: return AIRuleOut()
	jr .out


.found
;>@w side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03
;> heals = 0
	ld e, $00

;>@F for pos in range(side, side + 3):
.ownLoop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .ownNext

;>@P     p = addr(wBattlerSkills) + pos * 16
	ld a, c
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
;=@P
	adc h
	ld h, a
;>@G     for k in range(8):
	ld d, $08

.ownSkills
;>         kind = mem[p]; p += 1
	ld a, [hli]
;>         if kind == 0: break
	or a
	jr z, .ownNext

;>@h         if kind == 1 and 0x2B <= kind < 0x33:     # the kind, not the skill: never true
	cp $01
	jr nz, .ownSkip

	cp $2b
	jr c, .ownSkip

	cp $33
	jr c, .heal

;>@H             heals = kind
;>@I             if heals >= 2: return AIRuleOut()
.ownSkip
;>         p += 1
;=@G
	inc hl
	dec d
	jr nz, .ownSkills

.ownNext
;=@F
	inc c
	dec b
	jr nz, .ownLoop

	ret


.heal
;=@H
	inc e
	ld e, a
;=@I
	cp $02
	jr c, .ownSkip

.out
;=@o
	call AIRuleOut
	ret


;@ def AIBonusHurtTwinSlash()
;@ path: battle/ai/rules
;@ TwinSlash and Beserker ($3B, $3D) get 20 while the user has no more than 3/4 of its maximum HP.
;@ test: wSkillUser = rand(0, 7)
AIBonusHurtTwinSlash::
;> if wSkillId not in (0x3B, 0x3D): return
	ld a, [wSkillId]
	cp $3b
	jr z, .check

	cp $3d
	ret nz

.check
;>@h hp = mem16[addr(wBattlerHP) + 2 * wSkillUser]
	ld a, [wSkillUser]
	add a
	ld hl, wBattlerHP
	add l
	ld l, a
	ld a, $00
;=@h
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>@x top = mem16[addr(wBattlerMaxHP) + 2 * wSkillUser]
	ld a, [wSkillUser]
	add a
	ld hl, wBattlerMaxHP
	add l
	ld l, a
	ld a, $00
;=@x
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@y limit = (top >> 1) + (top >> 2)
	srl h
	rr l
	ld d, h
	ld e, l
	srl h
	rr l
;=@y
	add hl, de
;> if limit < hp: return
	call CompareHLBC
	ret c

;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleNothingToDispel()
;@ path: battle/ai/rules
;@ DeMagic ($80) is ruled out when the enemy side has nothing to lift: no called dragon, fog, magic wall
;@ or wind (wSideFlags bits 2, 3, 5) and none of status byte 1 bits 2-5, status byte 2 bits 0-3 and 5-6,
;@ status byte 3 bit 6, status byte 5 bits 2-3 and 6-7 or status byte 6 bit 6. The loop never moves on
;@ from the first enemy position, so only that one is looked at (three times).
;@ test: wSkillUser = rand(0, 7)
AIRuleNothingToDispel::
;> if wSkillId != 0x80: return
	ld a, [wSkillId]
	cp $80
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;>@w if wSideFlags[side >> 2] & 0x2C: return
	srl a
	srl a
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
;=@w
	adc h
	ld h, a
	ld a, [hl]
	and $2c
	ret nz

;>@f for k in range(3):                          # the position is never advanced
	ld b, $03

.loop
;>     s = AddEightTimes(side, addr(wBattlerStatus1))
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;>@t     if mem[s] & 0x3C or mem[s + 1] & 0x6F or mem[s + 2] & 0x40 or mem[s + 4] & 0xCC or mem[s + 5] & 0x40: return
	ld a, [hli]
	and $3c
	ret nz

	ld a, [hli]
	and $6f
	ret nz

;=@t
	ld a, [hli]
	and $40
	ret nz

	inc hl
	ld a, [hli]
	and $cc
;=@t
	ret nz

	ld a, [hli]
	and $40
	ret nz

;=@f
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleMagicWallUseless()
;@ path: battle/ai/rules
;@ Only for a smart monster: MagicWall ($26) is ruled out when no enemy knows a skill whose record byte
;@ +6 is not 0 (read with GetSkillWord). Empty positions are looked at too.
;@ test: skip calls a routine in another bank
AIRuleMagicWallUseless::
;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> if wSkillId != 0x26: return
	ld a, [wSkillId]
	cp $26
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     left = 8
	ld e, $08
;>@p     p = addr(wBattlerSkills) + 1 + pos * 16
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a

.skills
;>@g     while left:
;>         if mem[p] == 0xFF: break
	ld a, [hl]
	cp $ff
	jr z, .next

;>         wBattleArg0 = mem[p]; p += 1
	ld a, [hli]
	ld [wBattleArg0], a
;>         wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;>         wBattleArg2 = 6
	ld a, $06
	ld [wBattleArg2], a
;>@c         GetSkillWord()
	push af
	push bc
	push de
	push hl
	ld hl, far_GetSkillWord
	rst $10
;=@c
	pop hl
	pop de
	pop bc
	pop af
;>         if wBattleArg0 != 0: return
	ld a, [wBattleArg0]
	cp $00
	ret nz

;>         p += 1
	inc hl
;>         left -= 1
;=@g
	dec e
	jr nz, .skills

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIRuleScriptedNoKill()
;@ path: battle/ai/rules
;@ In a scripted battle (wBattleType 1, not a link battle) the monsters of the player's side (positions
;@ 0-3) leave out Beat, Defeat, Sacrifice, Paralyze, PalsyAir and KODance ($12-$14, $69, $6B, $71).
;@ test: wSkillUser = rand(0, 7)
AIRuleScriptedNoKill::
;> if wLinkActive: return
	ld a, [wLinkActive]
	or a
	ret nz

;> if wSkillUser >= 4: return
	ld a, [wSkillUser]
	cp $04
	ret nc

;> if wBattleType != 1: return
	ld a, [wBattleType]
	cp $01
	ret nz

;>@k if not (0x12 <= wSkillId < 0x15 or wSkillId in (0x69, 0x6B, 0x71)):
	ld a, [wSkillId]
	cp $12
	ret c

	cp $15
	jr c, .check

	cp $69
;=@k
	jr z, .check

	cp $6b
	jr z, .check

	cp $71
;>     return
	ret nz

.check
;> AIRuleOut()
	call AIRuleOut
	ret


;@ def AIBonusEnemyDamage()
;@ path: battle/ai/rules
;@ Outside a link battle, the enemies at positions 4-6 (not a called helper at 7) get 20 for the skills
;@ that do damage: Blaze to Sacrifice ($00-$14), TwinSlash to Paralyze ($3B-$69) but ChargeUP, SuckAir and
;@ Focus, and SmashLime to GigaSlash ($D6-$D9).
;@ test: wSkillUser = rand(0, 7)
AIBonusEnemyDamage::
;> if wLinkActive: return
	ld a, [wLinkActive]
	or a
	ret nz

;> if wSkillUser < 4 or wSkillUser == 7: return
	ld a, [wSkillUser]
	cp $04
	ret c

	cp $07
	ret z

;>@k if not (wSkillId < 0x15 or 0x3B <= wSkillId < 0x6A and wSkillId not in (0x41, 0x43, 0x54) or 0xD6 <= wSkillId < 0xDA):
	ld a, [wSkillId]
	cp $15
	jr c, .check

	cp $3b
	ret c

	cp $41
;=@k
	ret z

	cp $43
	ret z

	cp $54
	ret z

	cp $6a
;=@k
	jr c, .check

	cp $d6
	ret c

	cp $da
;>     return
	ret nc

.check
;> AddCapped_57(addr(wAttackWeight), 20)
	ld hl, wAttackWeight
	ld b, $14
	call AddCapped_57
	ret


;@ def AIRuleBarrierNoBreath()
;@ path: battle/ai/rules
;@ Only for a smart monster: Barrier ($24) is ruled out when no enemy present knows a fire or ice breath
;@ (FireAir to WhiteAir, KnowsElementBreath).
;@ test: wSkillUser = rand(0, 7)
AIRuleBarrierNoBreath::
;> if wSkillId != 0x24: return
	ld a, [wSkillId]
	cp $24
	ret nz

;> if not IsUserSmart(): return
	call IsUserSmart
	ret nz

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

;>@f for pos in range(side, side + 3):
.loop
;>     if CheckBattlerPresent(pos): continue
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@k     if KnowsElementBreath(pos): return
	call KnowsElementBreath
	jr c, .done

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIRuleOut()
	call AIRuleOut
	ret


.done
;=@k
	ret


;@ def KnowsElementBreath(pos: a) -> carry
;@ path: battle/ai/rules
;@ Carry when the monster at battle position `pos` knows a fire or ice breath (IsElementBreath). All
;@ eight skill entries are looked at.
;@ test: pos = rand(0, 7)
KnowsElementBreath::
;>@p p = addr(wBattlerSkills) + 1 + pos * 16
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
;>@g for k in range(8):
	ld d, $08

.loop
;>     if IsElementBreath(mem[p]): return True
	ld a, [hli]
	call IsElementBreath
	ret c

;>     p += 2
	inc hl
;=@g
	dec d
	jr nz, .loop

;> return False
	or a
	ret


;@ def IsElementBreath(skill: a) -> carry
;@ path: battle/ai/rules
;@ Carry when `skill` is a fire or ice breath: FireAir to WhiteAir ($5C-$63).
;@ test: skill = rand(0, 255)
IsElementBreath::
;> return 0x5C <= skill < 0x64
	cp $5c
	jr c, .no

	cp $64
	ret c

.no
	or a
	ret

;@ def GetBattlerNameTo_57(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Bank $57's copy of GetBattlerNameTo: writes the name of the monster at battle position `pos` to
;@ `dest`. An own monster's (and in a link battle the partner's) own name from its record; a wild
;@ enemy's species name with its letter (CopyBattlerSpeciesName_57, AppendEnemyLetter), or, when it has
;@ transformed, the name of the monster it became plus "Like" (CopyMorphedEnemyName_57). Position 3 or 7
;@ always gets the species name.
;@ test: skip calls routines in other banks
GetBattlerNameTo_57::
;> if pos >= 3:
	cp $03
;>     return CopyEnemyName_57(pos, dest)
;> return CopyPartyMonName_57(pos, dest)       # runs on into it
	jr nc, CopyEnemyName_57

;@ def CopyPartyMonName_57(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Copies the name of party monster `pos` (the record's own name) to `dest` and returns the address of
;@ its $F0 end mark. CopyEnemyName_57, the name of a far-side monster, follows inside this block: the
;@ link partner's own name (its monsters have party records too, positions 4-6), a transformed enemy's
;@ "Like" name, or the species name with the enemy's letter; slot 3 (the called helper) always gets the
;@ species name.
;@ test: skip follows name and record pointers that random states leave invalid
CopyPartyMonName_57::
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

.findEnd
;> while mem[dest] != 0xF0:
;>@c     dest += 1
	ld a, [hl]
	cp $f0
;>@r return dest
	ret z

;=@c
	inc hl
	jr .findEnd

.linkPartner
;> # CopyEnemyName_57 in a link battle:
;> return CopyPartyMonName_57(pos, dest)
	ld a, b
	pop bc
	jr CopyPartyMonName_57

CopyEnemyName_57:
;> # CopyEnemyName_57(pos, dest) -> dest:
;>@x if (pos & 3) != 3:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
;=@x
	jr z, .species

;>@l     if wLinkActive:
;>@l2         return CopyPartyMonName_57(pos, dest)
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, CopyPartyMonName_57.linkPartner

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
;>@t         return CopyMorphedEnemyName_57(morph, dest)
	cp $ff
	jr nz, .morphed

	ld a, b

.morphed
;=@t
	pop bc
	jr nz, CopyMorphedEnemyName_57

.species
;> CopyBattlerSpeciesName_57(pos, dest)
	push af
	call CopyBattlerSpeciesName_57
	pop af
;> AppendEnemyLetter()
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


;@ def CopyBattlerSpeciesName_57(pos: a, dest: hl)
;@ path: battle/names
;@ Copies the species name of battle position `pos` (system text group 5) to `dest`, and notes both for
;@ AppendEnemyLetter (wNameBattler, wNameDest). CopyMorphedEnemyName_57 follows inside this block: the
;@ name of an enemy that transformed into an own monster, that monster's name followed by "Like"; when
;@ another enemy turned into the same monster, a number 1-3 follows, counted by the enemy's place
;@ (wNamePos), and is also left in wBattleArg1 (0 = none).
;@ test: skip follows name and record pointers that random states leave invalid
CopyBattlerSpeciesName_57::
;> wNameBattler = pos
	ld [wNameBattler], a
;>@s species = wBattlerSpecies[pos]
	push hl
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hl]
;>@w wNameDest = dest
	ld l, a
	ld h, $05
	pop de
	ld a, e
	ld [wNameDest], a
	ld a, d
;=@w
	ld [wNameDest + 1], a
;> CopySystemText(0x0500 | species, dest)
	call CopySystemText
	ret


CopyMorphedEnemyName_57:
;> # CopyMorphedEnemyName_57(party_pos, dest):
;> end = CopyPartyMonName_57(party_pos, dest)
	call CopyPartyMonName_57
;>@k mem[end:end + 5] = [0x2F, 0x46, 0x48, 0x42, 0xF0]   # "Like"
	ld a, $2f
	ld [hli], a
	ld a, $46
	ld [hli], a
	ld a, $48
	ld [hli], a
;=@k
	ld a, $42
	ld [hli], a
	ld [hl], $f0
;> end += 4
	push hl
	ld hl, wEnemyMorph
;>@s2 slot = wNamePos & 3
	ld a, [wNamePos]
	and $03
;> if slot == 0:
	cp $01
	jr z, .slot1

	cp $02
	jr z, .slot2

;>@0     if wEnemyMorph[1] == wEnemyMorph[0] or wEnemyMorph[2] == wEnemyMorph[0]:
;>@a         n = 1
	ld a, [hli]
	cp [hl]
	jr z, .number1

	inc hl
	cp [hl]
	jr z, .number1

;>@z0     else:
;>@z         n = 0
	jr .none

.slot1
;>@1 elif slot == 1:
;>@1b     if wEnemyMorph[1] == wEnemyMorph[0]:
;>@b         n = 2
	ld a, [hli]
	cp [hl]
	jr z, .number2

;>@1a     elif wEnemyMorph[2] == wEnemyMorph[1]:
;>@a1         n = 1
	ld a, [hli]
	cp [hl]
	jr z, .number1

;>@z1     else:
;>@z2         n = 0
	jr .none

.slot2
;>@2 else:
;>@2s     same = (wEnemyMorph[0] == wEnemyMorph[2]) + (wEnemyMorph[1] == wEnemyMorph[2])
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
;=@2s
	jr nz, .notFirst

	inc d

.notFirst
;=@2s
	inc hl
	cp [hl]
	jr nz, .count

	inc d

.count
;>@2c     n = (0, 2, 3)[same]
	ld a, d
	or a
	jr z, .none

	cp $01
	jr z, .number2

;=@2c
	pop hl
	ld a, $03
	jr .store

.number1
;=@a
	pop hl
	ld a, $01
	jr .store

.number2
;=@b
	pop hl
	ld a, $02

.store
;> wBattleArg1 = n
	ld [wBattleArg1], a
;> if n:
;>     mem[end:end + 2] = [n, 0xF0]
	ld [hli], a
	ld [hl], $f0
	ret


.none
;=@z
	pop hl
	xor a
	ld [wBattleArg1], a
	ret



;@ def TargetNameToArg2_57()
;@ path: battle/names
;@ Unused: writes the skill target's name to wTextArg2 (TargetNameTo_57).
;@ test: skip calls routines in other banks
TargetNameToArg2_57::
;> TargetNameTo_57(addr(wTextArg2))
	ld hl, wTextArg2
	jr TargetNameTo_57


;@ def TargetNameToArg0_57()
;@ path: battle/names
;@ Unused: writes the skill target's name to wTextArg0 for the next message. TargetNameTo_57 inside it
;@ does the same for the buffer in hl (GetBattlerNameTo_57; wBattleArg2/3 hold the buffer's address).
;@ test: skip calls routines in other banks
TargetNameToArg0_57::
;> dest = addr(wTextArg0)
	ld hl, wTextArg0

TargetNameTo_57:
;> # TargetNameTo_57(dest):
;> wBattleArg2 = lo(dest)
;> wBattleArg3 = hi(dest)
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo_57(wSkillTarget, dest)
	call GetBattlerNameTo_57
	ret


;@ def UserNameToArg0_57()
;@ path: battle/names
;@ Unused: writes the skill user's name to wTextArg0 for the next message (GetBattlerNameTo_57).
;@ test: skip calls routines in other banks
UserNameToArg0_57::
;> wBattleArg2 = lo(wTextArg0)
;> wBattleArg3 = hi(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser
	ld a, [wSkillUser]
	ld [wNamePos], a
;> GetBattlerNameTo_57(wSkillUser, wTextArg0)
	call GetBattlerNameTo_57
	ret

Call_57_6E0E::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_57_6E12::
	dw Jump_57_6E2A
	dw Jump_57_7129
	dw Jump_57_73B9
	dw Jump_57_7529
	dw Jump_57_7439
	dw Jump_57_75A2
	dw Jump_57_7859
	dw Jump_57_7865

jr_057_6e22:
	ld a, $06
	ld [wBattleSubStep2], a
	jp Jump_57_7859


Jump_57_6E2A::
	ld a, [wBattleSubStep]
	cp $16
	jr c, jr_057_6e50

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01

jr_057_6e50:
	ld hl, wAISkillScores
	ld bc, $0008
	xor a
	call FillMemory
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, jr_057_6e22

	ld hl, wSkillTargeting
	ld bc, $0007
	xor a
	call FillMemory
	xor a
	ld [wNamePos], a
	ld [$db51], a
	ld [$db52], a
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	jr c, jr_057_6eb9

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_057_6eb9

	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 6, [hl]
	jr z, jr_057_6ec1

	ld a, [wSkillUser]
	cp $03
	jr c, jr_057_6f1f

	jr z, jr_057_6eb9

	cp $07
	jr z, jr_057_6eb9

	ld a, [wLinkActive]
	or a
	jr z, jr_057_6eb9

	jr jr_057_6f1f

jr_057_6eb9:
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7129


	db $c9

jr_057_6ec1:
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_6ecc

	ld a, [wMenuChoice]
	jr jr_057_6edb

jr_057_6ecc:
	ld a, [wSkillUser]
	cp $04
	jr nc, jr_057_6ed8

	ld a, [wOrderFlag0]
	jr jr_057_6edb

jr_057_6ed8:
	ld a, [wOrderFlag1]

jr_057_6edb:
	ld [wBattleTemp], a
	ld a, [hl]
	call Call_57_78D4
	call Call_57_7905
	call Call_57_791A
	call Call_57_7A03
	call Call_57_7A16
	call Call_57_7A5D
	jp nc, Jump_057_6f8c

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	set 6, [hl]
	ld a, [wBattleTemp]
	cp $81
	jp nz, Jump_57_7129

	ld hl, wBattleSubStep2
	inc [hl]

jr_057_6f1f:
	ld a, [wBattleSubStep]
	cp $01
	jr nz, jr_057_6f64

	ld a, [wSkillUser]
	call CheckBattlerPresent
	jp c, Jump_57_7129

	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $dc
	jp nz, Jump_57_7129

	inc hl
	inc hl
	inc hl
	ld a, [hl]
	and $1f
	jp nz, Jump_57_7129

	inc hl
	bit 2, [hl]
	jp nz, Jump_57_7129

	inc hl
	ld a, [hl]
	and $d0
	jp nz, Jump_57_7129

	call Call_57_7E82
	ld a, $b4
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10

jr_057_6f64:
	ld a, $06
	ld [wBattleSubStep2], a
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	ld [hli], a
	ld a, [hl]
	and $cf
	ld [hl], a
	call Call_57_7F5F
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], b
	ret


Jump_057_6f8c:
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
	cp $03
	jr nz, jr_057_6fbc

	ld a, [wBattleTemp]
	cp $81
	jr z, jr_057_6fd2

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $3a
	ld a, $06
	ld [wBattleSubStep2], a
	jp Jump_57_7859


jr_057_6fbc:
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleTemp]
	cp $81
	jr z, jr_057_6fd0

	ld [hl], $14
	jr jr_057_6fd2

jr_057_6fd0:
	ld [hl], $2d

jr_057_6fd2:
	ld a, [wBattleStep]
	cp $05
	jr z, jr_057_6fe0

	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7129


jr_057_6fe0:
	ld a, [wLinkActive]
	or a
	jp nz, Jump_57_7129

	ld a, [wBattleTemp]
	cp $81
	jp nz, Jump_57_7129

	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	jr z, jr_057_7017

	cp $02
	jr z, jr_057_7012

	cp $01
	jr z, jr_057_700d

	ld hl, PersonalityShiftTable
	jr jr_057_701a

jr_057_700d:
	ld hl, PersonalityShiftTable + $20
	jr jr_057_701a

jr_057_7012:
	ld hl, PersonalityShiftTable + $40
	jr jr_057_701a

jr_057_7017:
	ld hl, PersonalityShiftTable + $60

jr_057_701a:
	ld de, $0000
	ld a, [wSkillUser]
	ld bc, wBattlerPersonality3
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $97
	jr c, jr_057_7030

	ld d, $10

jr_057_7030:
	ld a, [wSkillUser]
	ld bc, wBattlerLevel
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	cp $0a
	jr c, jr_057_7050

	cp $14
	jr c, jr_057_704b

	cp $1e
	jr c, jr_057_704a

	inc e

jr_057_704a:
	inc e

jr_057_704b:
	inc e
	ld a, e
	add a
	add a
	ld e, a

jr_057_7050:
	ld a, d
	add e
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillUser]
	ld bc, wBattlerPersonality1
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	inc hl
	ld a, $08
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	call Call_57_7092
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7129


Call_57_7092::
	bit 7, [hl]
	jr nz, jr_057_709e

	ld a, [bc]
	add [hl]
	jr nc, jr_057_70a7

	ld a, $ff
	jr jr_057_70a7

jr_057_709e:
	ld a, [hl]
	cpl
	inc a
	ld d, a
	ld a, [bc]
	sub d
	jr nc, jr_057_70a7

	xor a

jr_057_70a7:
	ld [bc], a
	ret


PersonalityShiftTable::
	db $07, $ff, $00, $03
	db $05, $ff, $00, $02
	db $03, $ff, $00, $01
	db $02, $ff, $00, $01
	db $0a, $ff, $00, $04
	db $07, $ff, $00, $03
	db $05, $ff, $00, $02
	db $05, $00, $00, $01
	db $00, $07, $fe, $03
	db $00, $05, $fe, $02
	db $00, $04, $ff, $01
	db $00, $03, $ff, $01
	db $00, $0a, $fd, $04
	db $00, $07, $fe, $03
	db $00, $05, $ff, $02
	db $00, $05, $00, $01
	db $fe, $00, $07, $03
	db $fe, $00, $05, $02
	db $ff, $00, $04, $01
	db $ff, $00, $03, $01
	db $fe, $00, $0a, $04
	db $fe, $00, $07, $03
	db $ff, $00, $05, $02
	db $00, $00, $05, $01
	db $00, $00, $00, $ff
	db $00, $00, $00, $fe
	db $00, $00, $00, $fe
	db $00, $00, $00, $ff
	db $00, $00, $00, $ff
	db $00, $00, $00, $fe
	db $00, $00, $00, $fe
	db $00, $00, $00, $ff

Jump_57_7129::
	ld a, [wLinkActive]
	or a
	jr z, jr_057_7140

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_057_713b

	ld a, [wOrderFlag0]
	jr jr_057_7143

jr_057_713b:
	ld a, [wOrderFlag1]
	jr jr_057_7143

jr_057_7140:
	ld a, [wMenuChoice]

jr_057_7143:
	cp $81
	jr nz, jr_057_7160

	ld a, [wSkillUser]
	cp $03
	jr z, jr_057_7160

	cp $07
	jr z, jr_057_7160

	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $03
	jr z, jr_057_718c

jr_057_7160:
	call Call_57_71B9
	ld a, [wRunTurn]
	or a
	call z, Call_57_719B
	call Call_57_7322
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_057_7184

	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_73B9


jr_057_7184:
	ld a, $05
	ld [wBattleSubStep2], a
	jp Jump_57_75A2


jr_057_718c:
	ld a, $06
	ld [wBattleSubStep2], a
	jp Jump_57_7859



Call_57_7194::
	call Call_57_7F2C
	ld a, [wRandomHigh]
	ret

Call_57_719B::
	ld a, [wSkillUser]
	cp $04
	jr nc, jr_057_71a8

	ld a, [wMenuChoice]
	cp $81
	ret z

jr_057_71a8:
	ld a, [wSkillFlags2]
	cp $1e
	jr nc, jr_057_71b3

	ld a, $00
	jr jr_057_71b5

jr_057_71b3:
	sub $1e

jr_057_71b5:
	ld [wSkillFlags2], a
	ret


Call_57_71B9::
	ld c, $00
	ld d, c
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_71c9

	ld a, [wSkillUser]
	cp $03
	jr nc, jr_057_71cf

jr_057_71c9:
	ld d, $01
	ld a, [wNamePos]
	ld c, a

jr_057_71cf:
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld hl, wSkillTargeting
	call Call_57_72CE
	ld a, d
	or a
	jr nz, jr_057_71e8

	jr jr_057_7206

jr_057_71e8:
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_71f3

	ld a, [wMenuChoice]
	jr jr_057_7202

jr_057_71f3:
	ld a, [wLinkFlags]
	bit 1, a
	jr nz, jr_057_71ff

	ld a, [wOrderFlag0]
	jr jr_057_7202

jr_057_71ff:
	ld a, [wOrderFlag1]

jr_057_7202:
	cp $81
	jr z, jr_057_7228

jr_057_7206:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	add a
	add a
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	and $0c
	jr nz, jr_057_7221

	inc hl
	inc hl
	ld a, [hl]
	and $33
	jr z, jr_057_7228

jr_057_7221:
	ld a, $1e
	ld hl, wSkillTargeting
	add [hl]
	ld [hl], a

jr_057_7228:
	ld a, [$db51]
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerStat67
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld hl, wSkillFlags1
	call Call_57_72CE
	ld a, [$db52]
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	ld hl, wSkillFlags2
	call Call_57_72CE
	ld a, [wSkillUser]
	ld d, a
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	ret nz

	ld a, [wSkillUser]
	cp $04
	jr c, jr_057_7273

	ld a, [wEnemyCount]
	jr jr_057_7276

jr_057_7273:
	ld a, [wPartyBattlers]

jr_057_7276:
	ld b, a
	ld a, [wSkillUser]
	and $04
	ld c, a

jr_057_727d:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_057_7298

	push bc
	call GetBattlerMaxHP
	push hl
	ld a, c
	call GetBattlerHP
	add hl, hl
	ld b, h
	ld c, l
	add hl, bc
	add hl, bc
	pop bc
	call CompareHLBC
	pop bc
	jr c, jr_057_729d

jr_057_7298:
	inc c
	dec b
	jr nz, jr_057_727d

	ret


jr_057_729d:
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, $08

jr_057_72ad:
	ld a, [hli]
	cp $ff
	ret z

	cp $2b
	jr c, jr_057_72c1

	cp $30
	jr c, jr_057_72c6

	cp $93
	jr z, jr_057_72c6

	cp $94
	jr z, jr_057_72c6

jr_057_72c1:
	inc hl
	dec b
	jr nz, jr_057_72ad

	ret


jr_057_72c6:
	ld a, $1e
	ld hl, wSkillFlags2
	add [hl]
	ld [hl], a
	ret


Call_57_72CE::
	push hl
	push de
	ld a, b
	ld [wBattleTemp], a
	call Call_57_78CE
	ld a, c
	add b
	ld b, a
	call Call_57_7F2C
	push bc
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_7316

	ld a, [wSkillUser]
	cp $03
	jr c, jr_057_7316

	ld a, [wBattleTemp]
	cp $32
	jr c, jr_057_730a

	cp $64
	jr c, jr_057_730e

	cp $96
	jr c, jr_057_7312

	cp $c8
	jr c, jr_057_7316

	ld a, $0a
	jr jr_057_7318

jr_057_730a:
	ld a, $1e
	jr jr_057_7318

jr_057_730e:
	ld a, $19
	jr jr_057_7318

jr_057_7312:
	ld a, $14
	jr jr_057_7318

jr_057_7316:
	ld a, $0a

jr_057_7318:
	call Divide16
	pop bc
	pop de
	add b
	ld b, a
	pop hl
	ld [hl], b
	ret


Call_57_7322::
	ld a, $01
	ld [wSkillFlags3], a
	ld a, $02
	ld [wAIKindOrder2], a
	ld a, $03
	ld [wAIKindOrder3], a
	ld a, [wSkillTargeting]
	ld l, a
	ld a, [wSkillFlags1]
	ld c, a
	xor a
	ld h, a
	ld b, a
	call CompareHLBC
	jr nc, jr_057_734d

	ld l, c
	ld h, b
	ld a, $02
	ld [wSkillFlags3], a
	ld a, $01
	ld [wAIKindOrder2], a

jr_057_734d:
	ld a, [wSkillFlags2]
	ld c, a
	ld b, $00
	call CompareHLBC
	jr nc, jr_057_7366

	ld a, [wSkillFlags3]
	ld b, a
	ld a, [wAIKindOrder3]
	ld [wSkillFlags3], a
	ld a, b
	ld [wAIKindOrder3], a

jr_057_7366:
	call Call_57_73A5
	call z, Call_57_73B1
	ld a, [wAIKindOrder3]
	dec a
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	ld b, $00
	ld a, [wAIKindOrder2]
	dec a
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	call CompareHLBC
	jr nc, jr_057_739f

	ld a, [wAIKindOrder2]
	ld b, a
	ld a, [wAIKindOrder3]
	ld [wAIKindOrder2], a
	ld a, b
	ld [wAIKindOrder3], a

jr_057_739f:
	ld a, $03
	ld [wAIKindTry], a
	ret


Call_57_73A5::
	ld a, [wAIKindOrder2]
	cp $01
	ret z

	ld a, [wAIKindOrder3]
	cp $01
	ret


Call_57_73B1::
	ld hl, wSkillTargeting
	ld a, $1e
	add [hl]
	ld [hl], a
	ret


Jump_57_73B9::
	ld a, [wAIKindTry]
	cp $06
	jr z, jr_057_73ed

	cp $04
	jr z, jr_057_73f1

	cp $03
	jr z, jr_057_73d9

	ld b, a
	dec a
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr z, jr_057_73ed

	ld a, b

jr_057_73d9:
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wAIKind], a
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7529


jr_057_73ed:
	ld c, $3a
	jr jr_057_7418

jr_057_73f1:
	ld a, [wSkillFlags3]
	cp $01
	jr z, jr_057_73ed

	cp $03
	ld a, [wAIKindTry]
	jr nz, jr_057_73d9

	ld a, [wBattleSubStep]
	cp $15
	ld a, [wAIKindTry]
	jr nc, jr_057_73ed

	call Call_57_77A4
	ld a, [wAIKindTry]
	jr nz, jr_057_73d9

	call Call_57_77B4
	jr nc, jr_057_73ed

	ld c, $8d

jr_057_7418:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	jp Jump_57_7859


Jump_57_7439::
	ld a, [wAISkillPtr]
	ld l, a
	ld a, [$c1ff]
	ld h, a

Jump_057_7441:
	ld a, [hl]
	or a
	jp z, Jump_057_74ca

	ld a, [wAIKind]
	cp [hl]
	jr nz, jr_057_7487

	xor a
	ld [wAttackWeight], a
	ld [wAIPenalty], a
	inc hl
	ld a, [hl]
	ld [wSkillId], a
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $07
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld [wSkillMsgMode], a
	ld a, [wAIKind]
	dec a
	ld hl, AIRuleLists
	call WordTableEntry_57
	ld a, l
	ld [wAIRulePtr], a
	ld a, h
	ld [$c1fb], a
	ld a, $07
	ld [wBattleSubStep2], a
	ret


jr_057_7487:
	ld a, [wAISkillSlot]
	ld hl, wAISkillScores
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hl], a
	ld [wAttackWeight], a
	ld [wAIPenalty], a

Jump_057_749b:
	ld a, [wAISkillPtr]
	ld l, a
	ld a, [$c1ff]
	ld h, a
	inc hl
	inc hl
	ld a, l
	ld [wAISkillPtr], a
	ld a, h
	ld [$c1ff], a
	ld a, [wAISkillSlot]
	ld c, a
	ld a, [wAISlotsLeft]
	ld b, a
	inc c
	dec b
	ld a, c
	ld [wAISkillSlot], a
	ld a, b
	ld [wAISlotsLeft], a
	jp nz, Jump_057_7441

jr_057_74c2:
	ld a, $05
	ld [wBattleSubStep2], a
	jp Jump_57_75A2


Jump_057_74ca:
	ld a, [wAISkillSlot]
	ld hl, wAISkillScores
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a

jr_057_74d7:
	ld [hli], a
	dec b
	jr nz, jr_057_74d7

	jr jr_057_74c2


Call_57_74DD::
	push hl
	push de
	push bc
	ld a, [hl]
	ld [wSkillId], a
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $07
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	ld [wSkillMsgMode], a
	ld a, [wAIKind]
	dec a
	ld hl, AIRuleLists
	call WordTableEntry_57
	call Call_57_750C
	pop bc
	pop de
	pop hl
	ret


Call_57_750C::
	ld a, [hli]
	ld d, a
	ld a, [hld]
	or d
	jr z, jr_057_7524
	push hl
	call Call_57_7525
	pop hl
	ld a, [wAIPenalty]
	cp $ff
	jr z, jr_057_7524
	inc hl
	inc hl
	push hl
	pop hl
	jr Call_57_750C


jr_057_7524:
	ret


Call_57_7525::
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

Jump_57_7529::
	ld bc, $0800
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_057_753a:
	ld a, [hl]
	cp $ff
	jr z, jr_057_7574

	push hl
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $03
	ld [wBattleArg2], a
	push bc
	ld hl, far_GetSkillWord
	rst $10
	pop bc
	ld a, c
	ld hl, wAISkillScores
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	add [hl]
	ld [hl], a
	jr nc, jr_057_7566

	ld [hl], $ff

jr_057_7566:
	push hl
	ld a, $10
	call Call_57_7A93
	pop hl
	add [hl]
	ld [hl], a
	jr nc, jr_057_7573

	ld [hl], $ff

jr_057_7573:
	pop hl

jr_057_7574:
	inc hl
	inc hl
	inc c
	dec b
	jr nz, jr_057_753a

	ld hl, wBattleSubStep2
	inc [hl]
	ld bc, $0800
	ld a, c
	ld [wAISkillSlot], a
	ld a, b
	ld [wAISlotsLeft], a
	ld a, [wSkillUser]
	ld hl, wBattlerSkills
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, l
	ld [wAISkillPtr], a
	ld a, h
	ld [$c1ff], a
	jp Jump_57_7439


Jump_57_75A2::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jp nz, Jump_057_76bd

	inc hl
	inc hl
	inc hl
	inc hl
	bit 2, [hl]
	jp nz, Jump_057_76b5

	inc hl
	bit 4, [hl]
	jp nz, Jump_057_76c5

	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jp z, Jump_057_76df

	ld hl, wAISkillScores
	ld bc, $0701
	ld d, [hl]
	inc hl
	ld e, $00

jr_057_75da:
	ld a, d
	or a
	jr nz, jr_057_75ec

	ld a, [hli]
	ld d, a
	inc e
	inc c
	dec b
	jr nz, jr_057_75da

	ld a, d
	or a
	jp z, Jump_057_76a9

	jr jr_057_75fa

jr_057_75ec:
	ld a, [hl]
	cp d
	jp z, Jump_057_769b

	jr c, jr_057_75f5

Jump_057_75f3:
	ld d, [hl]
	ld e, c

Jump_057_75f5:
jr_057_75f5:
	inc hl
	inc c
	dec b
	jr nz, jr_057_75ec

jr_057_75fa:
	ld a, [wAIKindTry]
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr z, jr_057_7650

	cp $02
	jr z, jr_057_762e

	ld a, d
	cp $14
	jr nc, jr_057_7632

	ld a, [wBattleSubStep]
	cp $15
	jp nc, Jump_057_76a9

	call Call_57_77A4
	jp nz, Jump_057_76a9

	call Call_57_77B4
	jp nc, Jump_057_7686

	call Call_57_76CD
	ld [hl], $8d
	ret


jr_057_762e:
	ld a, d
	or a
	jr z, jr_057_76a9

jr_057_7632:
	call Call_57_76CD
	push hl
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ld [hl], a
	ret


jr_057_7650:
	push de
	ld hl, far_AIAttackWeight
	rst $10
	ld a, [wAttackWeight]
	pop de
	cp d
	jr nc, jr_057_7686

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	push hl
	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	cp $ff
	jr nz, jr_057_7695

Jump_057_7686:
jr_057_7686:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a

jr_057_7695:
	ld [hl], a
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_057_769b:
	call Call_57_7F2C
	ld a, [wRandomHigh]
	bit 0, a
	jp z, Jump_057_75f5

	jp Jump_057_75f3


Jump_057_76a9:
jr_057_76a9:
	ld hl, wAIKindTry
	inc [hl]
	ld a, $02
	ld [wBattleSubStep2], a
	jp Jump_57_73B9


Jump_057_76b5:
	call Call_57_76CD
	ld [hl], $42
	jp Jump_57_7859


Jump_057_76bd:
	call Call_57_76CD
	ld [hl], $3a
	jp Jump_57_7859


Jump_057_76c5:
	call Call_57_76CD
	ld [hl], $95
	jp Jump_57_7859


Call_57_76CD::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


Jump_057_76df:
	ld b, $0a
	ld hl, wSkillStatusPtr
	xor a

jr_057_76e5:
	ld [hli], a
	dec b
	jr nz, jr_057_76e5

jr_057_76e9:
	ld a, [wAIKindTry]
	ld hl, wSkillTargeting
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld d, [hl]
	ld e, $00
	ld hl, wBattlerSkills
	ld a, [wSkillUser]
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld bc, $0800

jr_057_7709:
	ld a, [hli]
	cp d
	jr nz, jr_057_7724

	push hl
	call Call_57_7F2C
	ld hl, wSkillStatusPtr
	ld a, c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wRandomHigh]
	and $07
	inc a
	ld [hl], a
	pop hl
	inc e

jr_057_7724:
	inc hl
	inc c
	dec b
	jr nz, jr_057_7709

	call Call_57_7F2C
	ld a, d
	cp $02
	jr z, jr_057_7741

	ld hl, wAIUserHPOne
	cp $01
	jr z, jr_057_7739

	inc hl

jr_057_7739:
	ld a, [wRandomLow]
	and $07
	inc a
	ld [hl], a
	inc e

jr_057_7741:
	ld a, e
	or a
	jr nz, jr_057_7761

	ld a, d
	cp $02
	jr nz, jr_057_7750

	ld hl, wAIKindTry
	inc [hl]
	jr jr_057_76e9

jr_057_7750:
	cp $03
	jr z, jr_057_7758

jr_057_7754:
	ld b, $3a
	jr jr_057_77a0

jr_057_7758:
	call Call_57_77A4
	jr nz, jr_057_7754

	ld b, $8d
	jr jr_057_77a0

jr_057_7761:
	ld bc, $0a00
	ld hl, wSkillStatusPtr

jr_057_7767:
	ld a, [hli]
	or a
	jr nz, jr_057_7773

	inc c
	dec b
	jr nz, jr_057_7767

	ld b, $3a
	jr jr_057_77a0

jr_057_7773:
	ld d, a
	ld e, c
	inc c

jr_057_7776:
	ld a, [hli]
	cp d
	jr c, jr_057_777c

	ld d, a
	ld e, c

jr_057_777c:
	inc c
	dec b
	jr nz, jr_057_7776

	ld a, e
	cp $09
	jr nc, jr_057_7758

	cp $08
	jr z, jr_057_7754

	ld a, [wSkillUser]
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]

jr_057_77a0:
	call Call_57_76CD
	ld [hl], b

Call_57_77A4::
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	ret


Call_57_77B4::
	ld a, [wSkillUser]
	ld c, a
	and $03
	cp $03
	jr z, jr_057_77f2

	ld a, [wLinkActive]
	or a
	jr nz, jr_057_77c8

	bit 2, c
	jr nz, jr_057_77f2

jr_057_77c8:
	ld a, c
	xor $04
	and $04
	ld c, a
	call Call_57_77F5
	jr nc, jr_057_77f0

	inc c
	call Call_57_77F5
	jr nc, jr_057_77f0

	inc c
	call Call_57_77F5
	jr nc, jr_057_77f0

	call Call_57_7828
	jr nc, jr_057_77f2

	dec c
	call Call_57_7828
	jr nc, jr_057_77f2

	dec c
	call Call_57_7828
	jr nc, jr_057_77f2

jr_057_77f0:
	scf
	ret


jr_057_77f2:
	scf
	ccf
	ret


Call_57_77F5::
	ld a, c
	call CheckBattlerPresent
	ret c

	push bc
	ld a, c
	ld hl, wBattlerAttack
	call WordTableEntry_57
	push hl
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call WordTableEntry_57
	srl h
	rr l
	push hl
	ld a, [wSkillUser]
	ld hl, wBattlerDefense
	call WordTableEntry_57
	srl h
	rr l
	pop bc
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	call CompareHLBC
	pop bc
	ret


Call_57_7828::
	ld a, c
	call CheckBattlerPresent
	ret c

	push bc
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call WordTableEntry_57
	push hl
	ld a, c
	ld hl, wBattlerMaxHP
	call WordTableEntry_57
	srl h
	rr l
	push hl
	ld a, c
	ld hl, wBattlerDefense
	call WordTableEntry_57
	srl h
	rr l
	pop bc
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	call CompareHLBC
	pop bc
	ret


Jump_57_7859::
	ld a, [wSkillUser]
	xor a
	ld [wBattleSubStep2], a
	ld hl, wBattleSubStep
	inc [hl]
	ret


Jump_57_7865::
	ld a, [wAIRulePtr]
	ld l, a
	ld a, [$c1fb]
	ld h, a

jr_057_786d:
	ld a, [hli]
	ld d, a
	ld a, [hld]
	or d
	jr z, jr_057_78a2

	push hl
	call Call_57_78CA
	pop hl
	ld a, [wAIPenalty]
	cp $ff
	jr z, jr_057_788b

	inc hl
	inc hl
	ld a, l
	ld [wAIRulePtr], a
	ld a, h
	ld [$c1fb], a
	jr jr_057_786d

jr_057_788b:
	xor a
	ld [wAttackWeight], a
	ld [wAIPenalty], a
	ld a, [wAISkillSlot]
	ld hl, wAISkillScores
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	jr jr_057_78c1

jr_057_78a2:
	ld a, [wAISkillSlot]
	ld hl, wAISkillScores
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wAIPenalty]
	cp $ff
	jr z, jr_057_788b

	ld e, a
	ld a, [wAttackWeight]
	sub e
	jr c, jr_057_788b

	ld [wAttackWeight], a
	add [hl]
	ld [hl], a

jr_057_78c1:
	ld a, $04
	ld [wBattleSubStep2], a
	jp Jump_057_749b


	db $c9

Call_57_78CA::
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl


Call_57_78CE::
	ld a, $0a
	call Divide8
	ret


Call_57_78D4::
	cp $03
	jr z, jr_057_78e5

	cp $02
	jr z, jr_057_78f0

	cp $01
	jr z, jr_057_78eb

	ld hl, wBattlerPersonality1
	jr jr_057_78f3

jr_057_78e5:
	ld a, $00
	ld [wBattleArg0], a
	ret


jr_057_78eb:
	ld hl, wBattlerStat67
	jr jr_057_78f3

jr_057_78f0:
	ld hl, wBattlerPersonality2

jr_057_78f3:
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call Call_57_78CE
	ld a, b
	ld [wBattleArg0], a
	ret


Call_57_7905::
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, [hl]
	call Call_57_78CE
	ld a, b
	ld [wBattleArg1], a
	ret


Call_57_791A::
	ld b, $00
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $c0
	jr nc, jr_057_7937

	cp $40
	jr nc, jr_057_7935

	ld b, $12
	jr jr_057_7937

jr_057_7935:
	ld b, $09

jr_057_7937:
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality2
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $c0
	jr nc, jr_057_7954

	cp $40
	jr nc, jr_057_7950

	ld a, $06
	jr jr_057_7952

jr_057_7950:
	ld a, $03

jr_057_7952:
	add b
	ld b, a

jr_057_7954:
	ld a, [wSkillUser]
	ld hl, wBattlerStat67
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $c0
	jr nc, jr_057_7970

	cp $40
	jr nc, jr_057_796f

	inc b
	inc b
	ld a, $02
	jr jr_057_7970

jr_057_796f:
	inc b

jr_057_7970:
	ld a, [wSkillUser]
	ld hl, wBattlerTactic
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]

jr_057_797d:
	ld a, c
	or a
	jr z, jr_057_7988

	ld a, $1b
	add b
	ld b, a
	dec c
	jr jr_057_797d

jr_057_7988:
	add b
	ld hl, TacticWeights
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleItemUsedUp], a
	ret


TacticWeights::
	db $19, $19, $19, $14, $14, $19, $19, $19, $19
	db $14, $0f, $0a, $14, $14, $14, $14, $0f, $14
	db $05, $0f, $0a, $14, $0a, $0a, $14, $05, $05
	db $14, $0a, $05, $14, $05, $0a, $0f, $0a, $05
	db $19, $14, $19, $19, $0f, $14, $14, $14, $0a
	db $19, $0f, $0a, $14, $0a, $14, $19, $0f, $05
	db $14, $05, $05, $14, $05, $0a, $05, $0f, $05
	db $19, $14, $19, $19, $14, $14, $14, $0a, $0a
	db $19, $14, $0a, $0f, $0a, $0a, $0f, $19, $05
	db $14, $05, $05, $05, $05, $0a, $05, $05, $05
	db $19, $0f, $0a, $19, $14, $0a, $05, $05, $05
	db $19, $14, $0f, $14, $14, $19, $14, $19, $05

Call_57_7A03::
	ld a, [wSkillUser]
	ld hl, wBattlerWildness
	call WordTableAddr_57
	ld b, [hl]
	srl b
	srl b
	ld a, b
	ld [wBattleArg2], a
	ret


Call_57_7A16::
	ld a, [wSkillUser]
	ld hl, wBattlerWildness
	call WordTableAddr_57
	ld a, [hl]
	cp $20
	jr c, jr_057_7a38

	cp $40
	jr c, jr_057_7a3c

	cp $60
	jr c, jr_057_7a40

	cp $90
	jr c, jr_057_7a44

	cp $c0
	jr c, jr_057_7a48

	ld b, $0f
	jr jr_057_7a4a

jr_057_7a38:
	ld b, $05
	jr jr_057_7a4a

jr_057_7a3c:
	ld b, $07
	jr jr_057_7a4a

jr_057_7a40:
	ld b, $09
	jr jr_057_7a4a

jr_057_7a44:
	ld b, $0b
	jr jr_057_7a4a

jr_057_7a48:
	ld b, $0d

jr_057_7a4a:
	call Call_57_7F2C
	ld a, [wRandomHigh]
	and $3f

jr_057_7a52:
	cp b
	jr c, jr_057_7a59

	sub b
	jr nz, jr_057_7a52

	ld a, b

jr_057_7a59:
	ld [wBattleArg3], a
	ret


Call_57_7A5D::
	ld a, [wSkillUser]
	add a
	ld hl, wBattlerWildness
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_057_7a8e

	cp $15
	jr c, jr_057_7a8e

	cp $f0
	jr nc, jr_057_7a91

	ld a, [wBattleArg2]
	ld b, a
	ld a, [wBattleArg3]
	add b
	ld b, a
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	add c
	ld c, a
	ld a, [wBattleItemUsedUp]
	add c
	sub b
	ret


jr_057_7a8e:
	scf
	ccf
	ret


jr_057_7a91:
	scf
	ret


Call_57_7A93::
	push bc
	push af
	call Call_57_7F2C
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	pop af
	call Divide16
	pop bc
	ret



;@ def ResistPairBits(pair: e) -> a
;@ path: battle/ai/rules
;@ Turns the resistance byte in wBattleArg0 so that 2-bit value number `pair` (0 = bits 6-7, 1 = bits
;@ 4-5, 2 = bits 2-3, 3 = bits 0-1) sits in bits 0-1.
;@ test: pair = rand(0, 3)
ResistPairBits::
;> value = wBattleArg0
	ld a, [wBattleArg0]
	ld h, a
;>@0 if pair == 0: return (value << 2 | value >> 6) & 0xFF
	ld a, e
	or a
	jr z, .pair0

;>@1 if pair == 1: return (value << 4 | value >> 4) & 0xFF
	cp $01
	jr z, .pair1

;>@2 if pair == 2: return (value >> 2 | value << 6) & 0xFF
	cp $02
	jr z, .pair2

;> return value
	ld a, h
	ret

.pair0
;=@0
	ld a, h
	rlca
	rlca
	ret

.pair1
;=@1
	ld a, h
	swap a
	ret

.pair2
;=@2
	ld a, h
	rrca
	rrca
	ret


;@ def HPAboveThreeQuarters() -> carry
;@ path: battle/ai/rules
;@ Carry when the HP word wSkillAmount points to is above 3/4 of the maximum HP word wTargetScores points
;@ to (3 * (max // 4), at least 1).
;@ test: wSkillAmount = 0xDBA3 + 2 * rand(0, 7); wTargetScores = 0xDBB3 + 2 * rand(0, 7)
HPAboveThreeQuarters::
;>@h hp = mem16[wSkillAmount]
	push bc
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;=@h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
;>@m maxhp = mem16[wTargetScores]
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@m
	ld l, a
;>@q q = maxhp >> 2
	ld a, h
	or a
	jr nz, .big

;=@q
	ld a, l
	rrca
	rrca
	and $3f
;>@l limit = 3 * q if q else 1
	or a
	jr z, .one

;=@q
	ld l, a
;=@l
	jr .times3

.one
;=@l
	ld l, $01
	jr .compare

.big
;=@q
	sra h
	rr l
	sra h
	rr l

.times3
;=@l
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc

.compare
;> return limit < hp
	pop bc
	call CompareHLBC
	pop bc
	ret


;@ def HPAboveHalf() -> carry
;@ path: battle/ai/rules
;@ Carry when the HP word wSkillAmount points to is above half the maximum HP word wTargetScores points
;@ to (max // 2, at least 1).
;@ test: wSkillAmount = 0xDBA3 + 2 * rand(0, 7); wTargetScores = 0xDBB3 + 2 * rand(0, 7)
HPAboveHalf::
;>@h hp = mem16[wSkillAmount]
	push bc
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;=@h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
;>@m maxhp = mem16[wTargetScores]
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@m
	ld l, a
;>@l limit = maxhp >> 1 or 1
	ld a, h
	or a
	jr nz, .big

;=@l
	ld a, l
	rrca
	and $7f
	or a
	jr z, .one

;=@l
	ld l, a
	jr .compare

.one
;=@l
	ld l, $01
	jr .compare

.big
;=@l
	sra h
	rr l

.compare
;> return limit < hp
	pop bc
	call CompareHLBC
	pop bc
	ret


;@ def HPAboveQuarter() -> carry
;@ path: battle/ai/rules
;@ Carry when the HP word wSkillAmount points to is above a quarter of the maximum HP word wTargetScores
;@ points to.
;@ test: wSkillAmount = 0xDBA3 + 2 * rand(0, 7); wTargetScores = 0xDBB3 + 2 * rand(0, 7)
HPAboveQuarter::
;>@h hp = mem16[wSkillAmount]
	push bc
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;=@h
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
;>@m maxhp = mem16[wTargetScores]
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@m
	ld l, a
;> limit = maxhp // 4
	ld bc, $0004
	call DivideHLBC
;> return limit < hp
	pop bc
	call CompareHLBC
	pop bc
	ret


;@ def HPAboveTenth() -> carry
;@ path: battle/ai/rules
;@ Carry when the HP word wSkillAmount points to is above a tenth of the maximum HP word wTargetScores
;@ points to.
;@ test: wSkillAmount = 0xDBA3 + 2 * rand(0, 7); wTargetScores = 0xDBB3 + 2 * rand(0, 7)
HPAboveTenth::
;>@h hp = mem16[wSkillAmount]
	push bc
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;=@h
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
;>@m maxhp = mem16[wTargetScores]
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@m
	ld l, a
;> limit = maxhp // 10
	ld bc, $000a
	call DivideHLBC
;> return limit < hp
	pop bc
	call CompareHLBC
	pop bc
	ret


;@ def HasBreathSkill(pos: c) -> zero
;@ path: battle/ai/rules
;@ Zero when the monster at battle position `pos` knows a breath: FireAir to WhiteAir ($5C-$63) or
;@ SleepAir to PoisonAir ($6A-$6D).
;@ test: pos = rand(0, 7)
HasBreathSkill::
;>@p p = addr(wBattlerSkills) + 1 + pos * 16          # its skill numbers, every second byte
	ld a, c
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
;=@p
	ld a, $00
	adc h
	ld h, a
;>@f for k in range(8):
	ld d, $08

.loop
;>     skill = mem[p]
	ld a, [hli]
;>     if skill == 0xFF: break
	cp $ff
	jr z, .none

;>@b     if 0x5C <= skill < 0x64 or 0x6A <= skill < 0x6E:
	cp $5c
	jr c, .next

	cp $64
	jr c, .yes

	cp $6a
	jr c, .next

;=@b
	cp $6e
	jr c, .yes

;>@y         return True
.next
;>     p += 2
	inc hl
;=@f
	dec d
	jr nz, .loop

.none
;> return False
	ld a, $01
	or a
	ret

.yes
;=@y
	xor a
	ret


Call_57_7BAA::
	cp $03
	jr nc, jr_057_7bbc
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	call CopyName
	ret


jr_057_7bbc:
	push af
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
	ld [wNameDest + 1], a
	call CopySystemText
	pop af
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


Call_57_7BE0::
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

	ld a, [hl]
	and $0c
	jr z, jr_057_7c0f
	cp $04
	jr z, jr_057_7c0b
	cp $08
	jr z, jr_057_7c07
	ld b, $60
	jr jr_057_7c11


jr_057_7c07:
	ld b, $a0
	jr jr_057_7c11


jr_057_7c0b:
	ld b, $e0
	jr jr_057_7c11


jr_057_7c0f:
	ld b, $ff

jr_057_7c11:
	ld a, [wRandomHigh]
	cp b
	jr z, jr_057_7c33
	jr c, jr_057_7c33
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
	jr nz, jr_057_7c2d
	and $0c
	jr jr_057_7c2e


jr_057_7c2d:
	xor a

jr_057_7c2e:
	or b
	ld [hl], a
	ld a, $0f
	ret


jr_057_7c33:
	ld a, [hl]
	and $73
	ld [hl], a
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld a, $db
	ret

Call_57_7C44::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 0, [hl]
	jr nz, jr_057_7c52

	ret


jr_057_7c52:
	ld a, [wSkillId]
	cp $52
	jr z, jr_057_7c62

	cp $53
	jr z, jr_057_7c62

	cp $ab
	jr z, jr_057_7c66

	ret


jr_057_7c62:
	ld a, $03
	jr jr_057_7c68

jr_057_7c66:
	ld a, $08

jr_057_7c68:
	ld [wReflectAnim], a
	res 0, [hl]
	ret



;@ def IsUserSmart() -> zero
;@ path: battle/ai/rules
;@ Zero when the skill user is of intelligence class 2 (the smart monsters): some rules only apply then.
;@ test: wSkillUser = rand(0, 7)
IsUserSmart::
;>@r return wBattlerIntClass[wSkillUser] == 2
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@r
	ld h, a
	ld a, [hl]
	cp $02
	ret


;@ def IsPhysicalSkill() -> carry
;@ path: battle/ai/rules
;@ Carry for the physical attacks: TwinSlash, Beserker, HighJump, the cuts FireSlash to CleanCut, BiAttack,
;@ QuadHits, SquallHit to RainSlash, PoisonHit to Paralyze and SmashLime to Branching.
;@ test: wSkillId = rand(0, 0xDD)
IsPhysicalSkill::
;>@r return wSkillId in (0x3B, 0x3D, 0x42) or 0x44 <= wSkillId < 0x52 and wSkillId != 0x4F or 0x55 <= wSkillId < 0x58 or 0x67 <= wSkillId < 0x6A or 0xD6 <= wSkillId < 0xD9
	ld a, [wSkillId]
	cp $3b
	jr z, .yes

	cp $3d
	jr z, .yes

;=@r
	cp $42
	jr z, .yes

	cp $44
	jr c, .no

	cp $4f
	jr z, .no

;=@r
	cp $52
	jr c, .yes

	cp $55
	jr c, .no

	cp $58
	jr c, .yes

;=@r
	cp $67
	jr c, .no

	cp $6a
	jr c, .yes

	cp $d6
	jr c, .no

;=@r
	cp $d9
	jr c, .yes

.no
;=@r
	xor a
	ret

.yes
;=@r
	scf
	ret


;@ def IsStrongHitSkill() -> carry
;@ path: battle/ai/rules
;@ Carry for the strong hits: TwinSlash, Beserker, Massacre, EvilSlash, HighJump, BiAttack, QuadHits,
;@ SquallHit, PsycheUp and RainSlash.
;@ test: wSkillId = rand(0, 0xDD)
IsStrongHitSkill::
;>@r return wSkillId in (0x3B, 0x3D, 0x3F, 0x40, 0x42, 0x50, 0x51) or 0x55 <= wSkillId < 0x58
	ld a, [wSkillId]
	cp $3b
	jr z, .yes

	cp $3d
	jr z, .yes

;=@r
	cp $3f
	jr z, .yes

	cp $40
	jr z, .yes

	cp $42
	jr z, .yes

;=@r
	cp $50
	jr z, .yes

	cp $51
	jr z, .yes

	cp $55
	jr c, .no

;=@r
	cp $58
	jr c, .yes

.no
;=@r
	xor a
	ret

.yes
;=@r
	scf
	ret


;@ def IsSpellOrBreath() -> carry
;@ path: battle/ai/rules
;@ Carry for the attack spells Blaze to Defeat ($00-$13), MultiCut, CallHelp, YellHelp and WindBeast to
;@ BigBang ($58-$65).
;@ test: wSkillId = rand(0, 0xDD)
IsSpellOrBreath::
;>@r return wSkillId < 0x14 or wSkillId in (0x4F, 0x52, 0x53) or 0x58 <= wSkillId < 0x66
	ld a, [wSkillId]
	cp $14
	jr c, .yes

	cp $4f
	jr z, .yes

;=@r
	cp $52
	jr z, .yes

	cp $53
	jr z, .yes

	cp $58
	jr c, .no

;=@r
	cp $66
	jr c, .yes

.no
;=@r
	xor a
	ret

.yes
;=@r
	scf
	ret


;@ def UserHPAboveTwoThirds() -> carry
;@ path: battle/ai/rules
;@ Carry when the skill user has more than 2/3 of its maximum HP (2 * max < 3 * HP).
;@ test: wSkillUser = rand(0, 7)
UserHPAboveTwoThirds::
;>@t triple = (3 * mem16[addr(wBattlerHP) + 2 * wSkillUser]) & 0xFFFF
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call WordTableEntry_57
	ld b, h
	ld c, l
	add hl, bc
;=@t
	add hl, bc
	push hl
;> double = (2 * mem16[addr(wBattlerMaxHP) + 2 * wSkillUser]) & 0xFFFF
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	call WordTableEntry_57
	add hl, hl
;> return double < triple
	pop bc
	call CompareHLBC
	ret

	ret


;@ def UserMPBelowHalf() -> carry
;@ path: battle/ai/rules
;@ Carry when the skill user has less than half of its maximum MP.
;@ test: wSkillUser = rand(0, 7)
UserMPBelowHalf::
;>@h half = mem16[addr(wBattlerMaxMP) + 2 * wSkillUser] >> 1
	ld a, [wSkillUser]
	ld hl, wBattlerMaxMP
	call WordTableAddr_57
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@h
	srl b
	rr c
;> return GetBattlerMP(wSkillUser) < half
	ld a, [wSkillUser]
	call GetBattlerMP
	call CompareHLBC
	ret


;@ def UserMaxMPBelowMaxHP() -> carry
;@ path: battle/ai/rules
;@ Carry when the skill user's maximum MP is below its maximum HP.
;@ test: wSkillUser = rand(0, 7)
UserMaxMPBelowMaxHP::
;> maxhp = mem16[addr(wBattlerMaxHP) + 2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	call WordTableAddr_57
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> return GetBattlerMaxMP(wSkillUser) < maxhp
	ld a, [wSkillUser]
	call GetBattlerMaxMP
	call CompareHLBC
	ret


;@ def ResistSumStart() -> (d, e, c, b)
;@ path: battle/ai/rules
;@ Starts adding up how well the enemies resist skill wSkillId: ResistSumInit, wItemMsgGroup = 0, and
;@ (running on into ResistSumAdd) the level of the first enemy position is added right away.
;@ test: skip calls a routine in another bank
ResistSumStart::
;> byte, pair, side, count = ResistSumInit()
	call ResistSumInit
;> wItemMsgGroup = 0
	xor a
	ld [wItemMsgGroup], a
;> ResistSumAdd(side, byte, pair)              # (runs on into it)
;> return (byte, pair, side, count)

;@ def ResistSumAdd(pos: c, byte: d, pair: e)
;@ path: battle/ai/rules
;@ Counts battle position `pos` (wBattlerReload += 1) and adds its resistance level to skill wSkillId
;@ (resistance byte `byte`, 2-bit value `pair`) to wItemMsgGroup.
;@ test: skip calls a routine in another bank
ResistSumAdd::
;> wBattlerReload += 1
	ld hl, wBattlerReload
	inc [hl]
;> wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;> wBattleArg0 = byte
	ld a, d
	ld [wBattleArg0], a
;> GetResistByte()
	push de
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
	pop de
;> wItemMsgGroup = (wItemMsgGroup + (ResistPairBits(pair) & 3)) & 0xFF
	call ResistPairBits
	and $03
	ld hl, wItemMsgGroup
	add [hl]
	ld [hl], a
	ret


;@ def ResistSumInit() -> (d, e, c, b)
;@ path: battle/ai/rules
;@ GetSkillResistSlot (where skill wSkillId's resistance sits; the side facing the user; 3) with the
;@ counter wBattlerReload cleared.
;@ test: skip calls a routine in another bank
ResistSumInit::
;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 5                             # record +5: the resistance
	ld a, $05
	ld [wBattleArg2], a
;> GetSkillWord()
	ld hl, far_GetSkillWord
	rst $10
;> pair = wBattleArg0 & 3
	ld a, [wBattleArg0]
	and $03
	ld e, a
;> byte = (wBattleArg0 >> 2) & 0x0F
	ld a, [wBattleArg0]
	rrca
	rrca
	and $0f
	ld d, a
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> count = 3
	ld b, $03
;> wBattlerReload = 0
	xor a
	ld [wBattlerReload], a
;> return (byte, pair, side, count)
	ret


;@ def ResistLevelOf(pos: c, byte: d, pair: e) -> a
;@ path: battle/ai/rules
;@ Counts battle position `pos` (wBattlerReload += 1) and returns its resistance level (0-3) to skill
;@ wSkillId (resistance byte `byte`, 2-bit value `pair`).
;@ test: skip calls a routine in another bank
ResistLevelOf::
;> wBattlerReload += 1
	ld hl, wBattlerReload
	inc [hl]
;> wSkillTarget = pos
	ld a, c
	ld [wSkillTarget], a
;> wBattleArg0 = byte
	ld a, d
	ld [wBattleArg0], a
;> GetResistByte()
	push de
	push bc
	ld hl, far_GetResistByte
	rst $10
	pop bc
	pop de
;> return ResistPairBits(pair) & 3
	call ResistPairBits
	and $03
	ret


;@ def AverageEnemyDefense()
;@ path: battle/ai/rules
;@ AverageDefense for the side facing the skill user (runs on into it).
;@ test: skip divides by zero
AverageEnemyDefense::
;> return AverageDefense((wSkillUser & 4) ^ 4)
	ld a, [wSkillUser]
	and $04
	xor $04

;@ def AverageDefense(first: a)
;@ path: battle/ai/rules
;@ Meant to put the average defense of the monsters present among the three positions from `first`
;@ into wSkillAmount. It adds the running total into each monster's own defense instead of the other
;@ way round, so the total stays 0 and the defenses are written back unchanged: with one or two
;@ monsters the result is 0, with three (or none) 0 is divided by the total's high byte, 0, as well.
;@ test: skip divides by zero
AverageDefense::
;> count = 0
	ld c, a
	ld b, $03
	ld de, $0000
;> wSkillAmount = 0
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a

;>@f for pos in range(first, first + 3):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@d         mem16[addr(wBattlerDefense) + 2 * pos] = (mem16[addr(wBattlerDefense) + 2 * pos] + wSkillAmount) & 0xFFFF
	ld a, c
	ld hl, wBattlerDefense
	call WordTableAddr_57
	ld a, [wSkillAmount]
	add [hl]
	ld [hli], a
;=@d
	ld a, [wSkillAmount + 1]
	adc [hl]
	ld [hl], a
;>         count += 1
	inc d

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if count == 1: return
	ld a, d
	cp $01
	ret z

;>@h if count == 2:
	cp $02
	jr z, .half

;>@h2     wSkillAmount = wSkillAmount >> 1 | wSkillAmount & 0x8000
;> else:
;>@x     wSkillAmount = Divide16(wSkillAmount, wSkillAmount >> 8)[0]    # meant: divided by the count
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Divide16
;=@x
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret

.half
;=@h2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	sra h
	rr l
;=@h2
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AverageEnemyDefense2()
;@ path: unused
;@ The same as AverageEnemyDefense with wTargetScores as the total and result; nothing calls it.
;@ test: skip divides by zero
AverageEnemyDefense2::
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
;> count = 0
	ld b, $03
	ld de, $0000
;> wTargetScores = 0
	ld a, e
	ld [wTargetScores], a
	ld a, d
	ld [wTargetScores + 1], a

;>@f for pos in range(side, side + 3):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>@d         mem16[addr(wBattlerDefense) + 2 * pos] = (mem16[addr(wBattlerDefense) + 2 * pos] + wTargetScores) & 0xFFFF
	ld a, c
	ld hl, wBattlerDefense
	call WordTableAddr_57
	ld a, [wTargetScores]
	add [hl]
	ld [hli], a
;=@d
	ld a, [wTargetScores + 1]
	adc [hl]
	ld [hl], a
;>         count += 1
	inc d

.next
;=@f
	inc c
	dec b
	jr nz, .loop

;> if count == 1: return
	ld a, d
	cp $01
	ret z

;>@h if count == 2:
	cp $02
	jr z, .half

;>@h2     wTargetScores = wTargetScores >> 1 | wTargetScores & 0x8000
;> else:
;>@x     wTargetScores = Divide16(wTargetScores, wTargetScores >> 8)[0]
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	call Divide16
;=@x
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
	ret

.half
;=@h2
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	sra h
	rr l
;=@h2
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
	ret

Call_57_7E82::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	call GetBattlerNameTo_57
	ret



;@ def HasNoSpells(pos: a) -> carry
;@ path: battle/ai/rules
;@ Carry when the monster at battle position `pos` knows no spell (a skill number below $3A, BeDragon,
;@ Life or Ironize $DC).
;@ test: pos = rand(0, 7)
HasNoSpells::
;>@p p = AddSixteenTimes_57(pos, addr(wBattlerSkills) + 1)   # its skill numbers, every second byte
	push bc
	push hl
	ld hl, wBattlerSkills + 1
	call AddSixteenTimes_57
;>@f for k in range(8):
	ld b, $08

.loop
;>     skill = mem[p]
	ld a, [hli]
;>     if skill == 0xFF: break
	cp $ff
	jr z, .none

;>@s     if skill < 0x3A or skill in (0xD5, 0xDA, 0xDC):
	cp $3a
	jr c, .has

	cp $d5
	jr z, .has

	cp $da
	jr z, .has

;=@s
	cp $dc
	jr z, .has

;>@r         return False
;>     p += 2
	inc hl
;=@f
	dec b
	jr nz, .loop

.none
;> return True
	pop hl
	pop bc
	scf
	ret

.has
;=@r
	pop hl
	pop bc
	xor a
	or a
	ret


;@ def HasNoBreathMoves(pos: a) -> carry
;@ path: battle/ai/rules
;@ Carry when the monster at battle position `pos` knows no breath and neither SuckAir nor SuckAll.
;@ test: pos = rand(0, 7)
HasNoBreathMoves::
;>@p p = AddSixteenTimes_57(pos, addr(wBattlerSkills) + 1)
	push bc
	push hl
	ld hl, wBattlerSkills + 1
	call AddSixteenTimes_57
;>@f for k in range(8):
	ld b, $08

.loop
;>     skill = mem[p]
	ld a, [hli]
;>     if skill == 0xFF: break
	cp $ff
	jr z, .none

;>@s     if skill in (0x43, 0x8F) or 0x5C <= skill < 0x64 or 0x6A <= skill < 0x6E:
	cp $43
	jr z, .has

	cp $5c
	jr c, .skip

	cp $64
	jr c, .has

;=@s
	cp $6a
	jr c, .skip

	cp $6e
	jr c, .has

	cp $8f
	jr z, .has

;>@r         return False
.skip
;>     p += 2
	inc hl
;=@f
	dec b
	jr nz, .loop

.none
;> return True
	pop hl
	pop bc
	scf
	ret

.has
;=@r
	pop hl
	pop bc
	xor a
	or a
	ret


;@ def HasNoDances(pos: a) -> carry
;@ path: battle/ai/rules
;@ Carry when the monster at battle position `pos` knows no dance (PaniDance, KODance, OddDance to
;@ LureDance, DanceShut, Hustle, LifeDance).
;@ test: pos = rand(0, 7)
HasNoDances::
;>@p p = AddSixteenTimes_57(pos, addr(wBattlerSkills) + 1)
	push bc
	push hl
	ld hl, wBattlerSkills + 1
	call AddSixteenTimes_57
;>@f for k in range(8):
	ld b, $08

.loop
;>     skill = mem[p]
	ld a, [hli]
;>     if skill == 0xFF: break
	cp $ff
	jr z, .none

;>@s     if skill in (0x6E, 0x71, 0x91, 0x94, 0x96) or 0x75 <= skill < 0x79:
	cp $6e
	jr z, .has

	cp $71
	jr z, .has

	cp $75
	jr c, .skip

;=@s
	cp $79
	jr c, .has

	cp $91
	jr z, .has

	cp $94
	jr z, .has

;=@s
	cp $96
	jr z, .has

;>@r         return False
.skip
;>     p += 2
	inc hl
;=@f
	dec b
	jr nz, .loop

.none
;> return True
	pop hl
	pop bc
	scf
	ret

.has
;=@r
	pop hl
	pop bc
	xor a
	or a
	ret

Call_57_7F2C::
	push bc
	ld a, [wLinkActive]
	or a
	jr nz, jr_057_7f38

	call Random
	jr jr_057_7f5d

jr_057_7f38:
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

jr_057_7f5d:
	pop bc
	ret


Call_57_7F5F::
	ld hl, wBattleArg0
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality1
	call Call_57_7FC2
	ld [wBattleArg1], a
	cp $3f
	jr c, jr_057_7f7c

	ld a, $01
	ld [wBattleArg0], a

jr_057_7f7c:
	ld a, [wSkillUser]
	ld hl, wBattlerStat67
	call Call_57_7FC2
	ld [wBattleArg2], a
	cp $3f
	jr c, jr_057_7f91

	ld hl, wBattleArg0
	set 1, [hl]

jr_057_7f91:
	ld a, [wSkillUser]
	ld hl, wBattlerPersonality2
	call Call_57_7FC2
	ld [wBattleArg3], a
	cp $3f
	jr c, jr_057_7fa6

	ld hl, wBattleArg0
	set 2, [hl]

jr_057_7fa6:
	ld b, $98
	ld a, [wBattleArg0]
	or a
	ret z

	ld b, $3a
	bit 0, a
	jr z, jr_057_7fbf

	ld a, [wBattleArg1]
	ld hl, wBattleArg2
	cp [hl]
	jr c, jr_057_7fbf

	inc hl
	cp [hl]
	ret nc

jr_057_7fbf:
	ld b, $8d
	ret


Call_57_7FC2::
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ret



AddSixteenTimes_57::
	add a
	add a
	add a
	call WordTableAddr_57
	ret

Bank57Padding::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
