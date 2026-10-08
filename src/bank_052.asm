INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $052", ROMX[$4000], BANK[$52]

BankNumber_52::
	db $52

FarTable_52::
	dw RunActionStep
	dw Call_52_76C8
	dw Call_52_7A18
	dw SkillDamageByKind
	dw GetBaseAgilityTemp
	dw CalcAttackDamage
	dw GetResistByte
	dw Call_52_7EF1
	dw SkillBlaze
	dw SkillBlaze
	dw SkillBlaze
	dw SkillFirebal
	dw SkillFirebal
	dw SkillFirebal
	dw SkillBang
	dw SkillBang
	dw SkillBang
	dw SkillInfernos
	dw SkillInfernos
	dw SkillInfernos
	dw SkillIceBolt
	dw SkillIceBolt
	dw SkillIceBolt
	dw SkillBolt
	dw SkillBolt
	dw SkillBolt
	dw SkillBeat
	dw SkillBeat
	dw SkillSacrifice
	dw SkillSleep
	dw SkillSleep
	dw SkillStopSpell
	dw SkillSurround
	dw SkillPanicAll
	dw SkillRobMagic
	dw SkillTakeMagic
	dw SkillSap
	dw SkillSap
	dw SkillUpper
	dw SkillUpper
	dw SkillSlow
	dw SkillSlow
	dw SkillSpeed
	dw SkillSpeed
	dw SkillBarrier
	dw SkillTwinHits
	dw SkillMagicWall
	dw SkillMagicBack
	dw SkillMagicBack
	dw SkillTransform
	dw SkillIronize
	dw SkillHeal
	dw SkillHeal
	dw SkillHeal
	dw SkillHeal
	dw SkillHeal
	dw SkillVivify
	dw SkillVivify
	dw SkillFarewell
	dw SkillAntidote
	dw SkillNumbOff
	dw SkillDeChaos
	dw SkillCurseOff
	dw SkillAttack
	dw SkillAttack
	dw SkillChance
	dw SkillAttack
	dw SkillTwinSlash
	dw SkillRamming
	dw SkillBeserker
	dw SkillKamikaze
	dw SkillMassacre
	dw SkillMassacre
	dw SkillChargeUp
	dw SkillHighJump
	dw SkillSuckAir
	dw SkillFireSlash
	dw SkillBoltSlash
	dw SkillVacuSlash
	dw SkillIceSlash
	dw SkillMetalCut
	dw SkillDrakSlash
	dw SkillBeastCut
	dw SkillBirdBlow
	dw SkillDevilCut
	dw SkillZombieCut
	dw SkillCleanCut
	dw SkillMultiCut
	dw SkillBiAttack
	dw SkillBiAttack
	dw SkillCallHelp
	dw SkillCallHelp
	dw SkillFocus
	dw SkillSquallHit
	dw SkillTwinSlash
	dw SkillRainSlash
	dw SkillWindBeast
	dw SkillWindBeast
	dw SkillBolt
	dw SkillRockThrow
	dw SkillFireAir
	dw SkillFireAir
	dw SkillFireAir
	dw SkillFireAir
	dw SkillFrigidAir
	dw SkillFrigidAir
	dw SkillFrigidAir
	dw SkillFrigidAir
	dw SkillBolt
	dw SkillBigBang
	dw SkillMegaMagic
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillSleep
	dw SkillPalsyAir
	dw SkillPoisonGas
	dw SkillPoisonGas
	dw SkillPanicAll
	dw SkillCurse
	dw SkillAhhh
	dw SkillBeat
	dw SkillSandStorm
	dw SkillSandStorm
	dw SkillEerieLite
	dw SkillOddDance
	dw SkillRobMagic
	dw SkillSideStep
	dw SkillLureDance
	dw SkillLushLicks
	dw SkillLushLicks
	dw SkillLegSweep
	dw SkillLegSweep
	dw SkillWarCry
	dw SkillAttack
	dw SkillImitate
	dw SkillDeMagic
	dw SkillSurge
	dw SkillUltraDown
	dw SkillDeMagic
	dw SkillTatsuCall
	dw SkillTatsuCall
	dw SkillTatsuCall
	dw SkillTatsuCall
	dw SkillCover
	dw SkillCover
	dw SkillTailWind
	dw SkillTailWind
	dw SkillDodge
	dw SkillDefence
	dw SkillDefence
	dw SkillSuckAll
	dw SkillDefence
	dw SkillDanceShut
	dw SkillMouthShut
	dw SkillMeditate
	dw SkillHeal
	dw SkillLifeSong
	dw SkillLifeDance
	dw SkillAttack
	dw SkillDaze
	dw SkillHitAlly
	dw SkillHitEnemy
	dw SkillHitSelf
	dw SkillNoEffect
	dw SkillNoEffect
	dw SkillTrip
	dw SkillCantMove
	dw SkillCantMove
	dw SkillRunAway
	dw SkillCallHorror
	dw SkillHealUsAllSpecial
	dw SkillCallHorror
	dw SkillDeMagic
	dw SkillAllChange
	dw SkillBigSleep
	dw SkillMP0
	dw SkillNoEffect
	dw SkillChgDragon
	dw SkillCallEvil
	dw SkillFreezy
	dw SkillVivify
	dw SkillRestoreMP
	dw SkillMeteor
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillAttack
	dw SkillChgDragon
	dw SkillSmashlime
	dw SkillSheldodge
	dw SkillBranching
	dw SkillGigaSlash
	dw SkillPanicAll
	dw SkillRunAway
	dw SkillIronizeSelf
	dw SkillHalfAttack

SkillBlaze::
	call BlazeDamage
	call SkillDealsDamage
	ret


SkillFirebal::
	call FirebalDamage
	call SkillDealsDamage
	ret


SkillBang::
	call BangDamage
	call SkillDealsDamage
	ret


SkillInfernos::
	call InfernosDamage
	call SkillDealsDamage
	ret


SkillIceBolt::
	call IceBoltDamage
	call SkillDealsDamage
	ret


SkillBolt::
	call BoltDamage
	call SkillDealsDamage
	ret


SkillBeat::
	xor a
	ld [wBattleStepArg1], a
	call RollInstantDeath
	jr nc, jr_052_4225

	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld hl, $b8e8
	call SkillWorksSide
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, $00
	ld [hli], a
	ld [hl], $00
	pop hl
	ret


jr_052_4225:
	ld a, $b8
	call SkillFails
	ret


SkillSacrifice::
	ld a, $03
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


SkillSleep::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $8c
	jr nz, jr_052_4276

	call RollSleep
	jr nc, jr_052_4270

	ld hl, $bccc
	call SkillWorksSideNoDamage

PutTargetToSleep::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	or $8c
	ld [hl], a
	ret


jr_052_4270:
	ld a, $bc
	call SkillFails
	ret


jr_052_4276:
	ld a, $bd
	call SkillFailsNoAnim
	ret


SkillStopSpell::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	jr nz, jr_052_42a0

	call RollStopSpell
	jr nc, jr_052_42a4

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 0, [hl]
	ld hl, $b888
	call SkillWorksSideNoDamage
	ret


jr_052_42a0:
	call SkillEndsQuietly
	ret


jr_052_42a4:
	ld a, $b8
	call SkillFails
	ret


SkillSurround::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr nz, jr_052_42ce

	call RollSurround
	jr nc, jr_052_42d2

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 1, [hl]
	ld hl, $b898
	call SkillWorks
	ret


jr_052_42ce:
	call SkillEndsQuietly
	ret


jr_052_42d2:
	ld a, $b8
	call SkillFails
	ret


SkillPanicAll::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr z, jr_052_42eb

	ld a, $be
	call SkillFailsNoAnim
	ret


jr_052_42eb:
	call RollConfusion
	jr nc, jr_052_4302

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 4, [hl]
	ld hl, $b88e
	call SkillWorksSide
	ret


jr_052_4302:
	ld a, $b8
	call SkillFails
	ret


SkillRobMagic::
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	or [hl]
	jr z, jr_052_432a

	call RollRobMagic
	jr nc, jr_052_4324

	call RobMagic
	ld hl, $b88a
	call SkillWorksSide
	ret


jr_052_4324:
	ld a, $b8
	call SkillFails
	ret


jr_052_432a:
	ld a, $bb
	call SkillFails
	ret


SkillTakeMagic::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	jr nz, jr_052_4346

	set 0, [hl]
	ld hl, $8c00
	call SkillWorksAtOnce
	ret


jr_052_4346:
	call SkillEndsQuietly
	ret


SkillSap::
	call RollDefenseDown
	jr nc, jr_052_4367

	call LowerDefense
	jr nc, jr_052_4361

	ld a, [wSkillTarget]
	call MarkStatDown
	ld hl, $b886
	call SkillWorksSide
	ret


jr_052_4361:
	ld a, $bb
	call SkillFailsNoAnim
	ret


jr_052_4367:
	ld a, $b8
	call SkillFails
	ret


SkillUpper::
	call RaiseDefense
	jr nc, jr_052_437f

	ld hl, $9292
	call SkillWorks
	ld a, [wSkillTarget]
	call MarkStatUp
	ret


jr_052_437f:
	ld a, $bb
	call SkillFailsNoAnim
	ret


SkillSlow::
	call RollSlow
	jr nc, jr_052_43a2

	call LowerAgility
	jr nc, jr_052_439c

	ld a, [wSkillTarget]
	call MarkStatDown
	ld hl, $b895
	call SkillWorksSide
	ret


jr_052_439c:
	ld a, $bb
	call SkillFailsNoAnim
	ret


jr_052_43a2:
	ld a, $b8
	call SkillFails
	ret


SkillSpeed::
	call RaiseAgility
	jr nc, jr_052_43ba

	ld hl, $9797
	call SkillWorks
	ld a, [wSkillTarget]
	call MarkStatUp
	ret


jr_052_43ba:
	ld a, $bb
	call SkillFailsNoAnim
	ret


SkillBarrier::
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $04
	ld d, $00

jr_052_43ca:
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_43f3

	bit 2, [hl]
	jr nz, jr_052_43de

	inc d
	set 2, [hl]

jr_052_43de:
	inc c
	dec b
	jr nz, jr_052_43ca

	ld a, d
	or a
	jr z, jr_052_43f7

	ld hl, far_Call_58_59DC
	rst $10
	ld a, [wBattleTemp]
	add $09
	call SkillWorksGroup1
	ret


jr_052_43f3:
	res 2, [hl]
	jr jr_052_43de

jr_052_43f7:
	call SkillEndsQuietly
	ret


SkillTwinHits::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_052_4411

	set 2, [hl]
	ld hl, $9090
	call SkillWorksNoDamage
	ret


jr_052_4411:
	call SkillEndsQuietly
	ret


SkillMagicWall::
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

jr_052_441d:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_442c

	ld a, c
	ld hl, wBattlerStatus3
	call AddEightTimes
	set 6, [hl]

jr_052_442c:
	inc c
	dec b
	jr nz, jr_052_441d

	call SkillEndsQuietly
	ret


SkillMagicBack::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [wSkillId]
	cp $28
	jr z, jr_052_4455

	bit 5, [hl]
	jr nz, jr_052_4466

	ld a, [hl]
	and $dd
	or $20
	ld [hl], a
	ld hl, $9999
	call SkillWorksNoDamage
	ret


jr_052_4455:
	bit 1, [hl]
	jr nz, jr_052_4466

	ld a, [hl]
	and $dd
	or $02
	ld [hl], a
	ld hl, $9a9a
	call SkillWorks
	ret


jr_052_4466:
	ld a, $bb
	call SkillFailsNoAnim
	ret


SkillTransform::
	ld a, [wSkillUser]
	call MarkStatsChanged
	ld hl, $a0a0
	call SkillWorksNoDamage
	ret


SkillIronizeSelf::
	ld a, [wSkillUser]
	ld [wSkillTarget], a

SkillIronize::
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_449c

	ld a, [wSkillTarget]
	bit 2, a
	jr z, jr_052_449c

	ld hl, wBattlerStatus5
	call AddEightTimes
	push hl
	pop hl
	ld b, $01
	ld a, [wSkillTarget]
	ld c, a
	jr jr_052_44aa

jr_052_449c:
	ld b, $04
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld hl, wBattlerStatus5
	call AddEightTimes

jr_052_44aa:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_44b4

	ld a, [hl]
	or $c0
	ld [hl], a

jr_052_44b4:
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	inc c
	dec b
	jr nz, jr_052_44aa

	call ShowIronizeMessage
	ret


SkillHeal::
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, jr_052_44d2

jr_052_44cc:
	ld a, $bb
	call SkillFails
	ret


jr_052_44d2:
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr z, jr_052_44cc

	call HealTarget
	ld hl, $bb84
	call SkillDealsDamageNoSide
	ret


SkillVivify::
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, jr_052_456d

	jr z, jr_052_457a

	ld a, [wSkillId]
	cp $30
	jr nz, jr_052_453a

	call BattleRandom
	ld a, [wRandomHigh]
	cp $80
	jr nc, jr_052_4567

	jr jr_052_453a

jr_052_4515:
	ld a, [wSkillUser]
	and $04
	ld c, a
	or $03
	ld b, a

jr_052_451e:
	ld a, c
	call CheckBattlerPresent
	jr z, jr_052_4526

	jr c, jr_052_452d

jr_052_4526:
	inc a
	ld c, a
	cp b
	jr c, jr_052_451e

	jr jr_052_4574

jr_052_452d:
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld [hl], c

jr_052_453a:
	ld a, [wSkillTarget]
	ld b, a
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wSkillId]
	cp $30
	jr nz, jr_052_4552

	srl d
	rr e

jr_052_4552:
	ld a, b
	ld hl, wBattlerHP
	call IndexWords
	ld a, e
	ld [hli], a
	ld [hl], d
	ld a, b
	call ResetBattler
	ld hl, $9e9e
	call SkillWorksNoDamage
	ret


jr_052_4567:
	ld a, $c0
	call SkillFails
	ret


jr_052_456d:
	ld a, [wSkillId]
	cp $30
	jr nz, jr_052_4515

jr_052_4574:
	ld a, $bb
	call SkillFails
	ret


jr_052_457a:
	call SkillEndsQuietly
	ret


SkillFarewell::
	ld a, $04
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ld [wBattleTemp], a
	xor a
	ld [wBattleStepArg0], a
	ret


SkillAntidote::
	call ClearDamageGetStatus
	and $03
	jr z, jr_052_45a1

	ld a, [hl]
	and $fc
	ld [hl], a
	ld hl, $9c9c
	call SkillWorksNoDamage
	ret


jr_052_45a1:
	ld a, $bb
	call SkillFails
	ret


SkillNumbOff::
	call ClearDamageGetStatus
	and $cc
	jr z, jr_052_45d2

	push hl
	bit 6, [hl]
	jr z, jr_052_45b8

	ld hl, $9d9d
	jr jr_052_45bb

jr_052_45b8:
	ld hl, $dbdb

jr_052_45bb:
	call SkillWorksNoDamage
	pop hl
	ld a, [hl]
	and $33
	ld [hl], a
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	ret


jr_052_45d2:
	ld a, $bb
	call SkillFails
	ret


SkillDeChaos::
	call ClearDamageGetStatus
	and $10
	jr z, jr_052_45f8

	ld a, [hl]
	and $ef
	ld [hl], a
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	ld hl, $dcdc
	call SkillWorksNoDamage
	ret


jr_052_45f8:
	ld a, $bb
	call SkillFails
	ret


SkillCurseOff::
	call ClearDamageGetStatus
	and $20
	jr z, jr_052_4610

	ld a, [hl]
	and $df
	ld [hl], a
	ld hl, $9f9f
	call SkillWorksNoDamage
	ret


jr_052_4610:
	ld a, $bb
	call SkillFails
	ret


SkillChance::
	ld hl, far_Call_53_4D7E
	rst $10
	ld a, $00
	ld [wSkillMsgMode], a
	ld a, $01
	ld [wBattleSubStep], a
	ret


SkillAttack::
	call SkillAttackDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillTwinSlash::
	call SkillAttackDamage
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent150
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillRamming::
	call CalcHPFractionDamage
	call SkillDealsDamage
	ret


SkillBeserker::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 2, [hl]
	call SkillAttackDamage
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
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillKamikaze::
	call CalcLeaveOneHPDamage
	call SkillDealsDamage
	ret


SkillMassacre::
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_46b4

	ld a, [wSkillId]
	cp $3f
	jr z, jr_052_46a2

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, jr_052_46a2

	ld b, $a0
	ld a, [wRandomHigh]
	cp b
	jr c, jr_052_46b8

jr_052_46a2:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	set 7, [hl]
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


jr_052_46b4:
	call SkillEndsQuietly
	ret


jr_052_46b8:
	ld a, $78
	call SkillFails
	ret


SkillChargeUp::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	or $03
	ld [hl], a
	call SkillEndsQuietly
	ret


SkillHighJump::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, jr_052_46ee

	ld a, [hl]
	or $0c
	ld [hl], a
	call SkillEndsQuietly
	xor a
	ld [wBattleSubStep2], a
	ld a, $06
	ld [wBattleSubStep], a
	ret


jr_052_46ee:
	ld a, [hl]
	and $f3
	ld [hl], a
	call SkillAttackDamage
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent150
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillSuckAir::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	or $30
	ld [hl], a
	call SkillEndsQuietly
	ret


SkillFireSlash::
	call CalcAttackDamageRes0
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillBoltSlash::
	call CalcAttackDamageRes4
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillVacuSlash::
	call CalcAttackDamageRes3
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillIceSlash::
	call CalcAttackDamageRes5
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillMetalCut::
	call CalcAttackDamageVsType0
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillDrakSlash::
	call CalcDragonSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillBeastCut::
	call CalcBeastSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillBirdBlow::
	call CalcBirdSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillDevilCut::
	call CalcDevilSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillZombieCut::
	call CalcZombieSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillCleanCut::
	call CalcMaterialSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillMultiCut::
	call CalcSkillDamageVsZombie
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillBiAttack::
	ld a, [wSkillId]
	cp $51
	jr z, jr_052_47ac

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	call c, RetargetSkill
	ld d, $00
	jr jr_052_47bb

jr_052_47ac:
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
	ld d, $01

jr_052_47bb:
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call IndexWords
	ld a, l
	ld [wStatPtr], a
	ld a, h
	ld [$db64], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, d
	or a
	jr nz, jr_052_47d9

	call Percent75
	jr jr_052_47e2

jr_052_47d9:
	call ShiftHL1
	ld b, h
	ld c, l
	call ShiftBC2
	add hl, bc

jr_052_47e2:
	ld a, [wStatPtr]
	ld c, a
	ld a, [$db64]
	ld b, a
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	call SkillAttackDamage
	pop hl
	ld a, [wStatPtr]
	ld c, a
	ld a, [$db64]
	ld b, a
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


RetargetSkill::
	ld hl, far_Call_58_41E9
	rst $10
	ret


SkillCallHelp::
	ld a, [wHitCount]
	cp $01
	jr nz, jr_052_486b

	call BattleRandom
	ld a, [wRandomHigh]
	and $01
	jr z, jr_052_4859

	ld a, $03
	ld [wBattleStepArg0], a
	ld a, $0f
	ld [wHitCount], a
	xor a
	ld [wBattleSubStep2], a
	ld [wTextGroup], a
	ld a, $a1
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 0, [hl]
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wSkillUser]
	cp $04
	ret c

	ld hl, wHitCount
	inc [hl]
	ld a, [wSkillId]
	cp $52
	ret z

	inc [hl]
	ret


jr_052_4859:
	ld a, $ff
	ld [wHitCount], a
	xor a
	ld [wSkillAmount], a
	ld [$db57], a
	ld a, $c2
	call SkillFails
	ret


jr_052_486b:
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
	call CheckBattlerPresent
	jp c, EndCalledHelp

	call CalcLevelDamageRes24
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillFocus::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	set 7, [hl]
	call SkillEndsQuietly
	ret


SkillSquallHit::
	call SkillAttackDamage
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent80
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillRainSlash::
	ld a, [wHitCount]
	cp $05
	jr nc, jr_052_4914

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_48f5

	call SkillAttackDamage
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, [wHitCount]
	cp $01
	jr z, jr_052_48de

	cp $02
	jr z, jr_052_48e3

	call Percent40
	jr jr_052_48e6

jr_052_48de:
	call Percent80
	jr jr_052_48e6

jr_052_48e3:
	call Percent60

jr_052_48e6:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


jr_052_48f5:
	ld a, [wSkillTarget]
	and $04
	or $02
	ld b, a
	ld a, [wSkillTarget]
	cp b
	jr z, jr_052_4914

	inc a
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [wSkillTarget]
	ld [hl], a

jr_052_4914:
	call SkillEndsQuietly
	ret


SkillWindBeast::
	ld a, [wSkillId]
	cp $59
	jr z, jr_052_4924

	call CalcLevelDamage
	jr jr_052_4927

jr_052_4924:
	call CalcLevelDamage2

jr_052_4927:
	call SkillDealsDamage
	ret


SkillRockThrow::
	call CalcSkillDamageRes24
	call SkillDealsDamage
	ret


SkillFireAir::
	call CalcSkillDamageRes16
	call HalveDamageBehindVeil
	call SkillDealsDamage
	ret


SkillFrigidAir::
	call CalcSkillDamageRes17
	call HalveDamageBehindVeil
	call SkillDealsDamage
	ret


SkillBigBang::
	call CalcSkillDamageRes0
	call SkillDealsDamage
	ret


SkillMegaMagic::
	call CalcMPLevelDamage
	call SkillDealsDamage
	ret


SkillPalsyAir::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr nz, jr_052_4977

	push hl
	call TryEffectRes19
	pop hl
	jr c, jr_052_496e

	ld a, $c3
	call SkillFailsSide
	ret


jr_052_496e:
	set 6, [hl]
	ld hl, $cfcf
	call SkillWorksNoDamage
	ret


jr_052_4977:
	call SkillEndsQuietly
	ret


SkillPoisonGas::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [wSkillId]
	cp $6d
	jr z, jr_052_4997

	ld a, $ce
	ld [wBattleArg0], a
	ld a, [hl]
	and $03
	jr nz, jr_052_49ce

	jr jr_052_49a0

jr_052_4997:
	ld a, $d0
	ld [wBattleArg0], a
	bit 1, [hl]
	jr nz, jr_052_49ce

jr_052_49a0:
	call TryEffectRes18
	jr c, jr_052_49ab

	ld a, $c3
	call SkillFailsSide
	ret


jr_052_49ab:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [wSkillId]
	cp $6d
	jr z, jr_052_49c1

	set 0, [hl]
	res 1, [hl]
	jr jr_052_49c5

jr_052_49c1:
	set 1, [hl]
	res 0, [hl]

jr_052_49c5:
	ld a, [wBattleArg0]
	ld h, a
	ld l, a
	call SkillWorksNoDamage
	ret


jr_052_49ce:
	call SkillEndsQuietly
	ret


SkillCurse::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 5, [hl]
	jr nz, jr_052_49fc

	call TryEffectRes20
	jr c, jr_052_49ea

	ld a, $b8
	call SkillFailsSide
	ret


jr_052_49ea:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 5, [hl]
	ld hl, $d1d1
	call SkillWorksNoDamage
	ret


jr_052_49fc:
	call SkillEndsQuietly
	ret


SkillAhhh::
	call TargetStatus3
	bit 5, [hl]
	jr nz, jr_052_4a18

	call TryEffectRes21
	jr nc, jr_052_4a1c

	call TargetStatus3
	set 5, [hl]
	ld hl, $a7a7
	call SkillWorks
	ret


jr_052_4a18:
	call SkillEndsQuietly
	ret


jr_052_4a1c:
	ld a, $b8
	call SkillFailsSide
	ret


SkillSandStorm::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, jr_052_4a53

	call RollSurround
	jr nc, jr_052_4a4d

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	set 1, [hl]
	set 0, [hl]
	ld a, [wSkillId]
	add $30
	ld h, a
	ld l, a
	call SkillWorks
	ret


jr_052_4a4d:
	ld a, $b8
	call SkillFailsSide
	ret


jr_052_4a53:
	call SkillEndsQuietly
	ret


SkillEerieLite::
	call TargetStatus3
	bit 7, [hl]
	jr nz, jr_052_4a6f

	call RollInstantDeath
	jr nc, jr_052_4a75

	call TargetStatus3
	set 7, [hl]
	ld hl, $a4a4
	call SkillWorks
	ret


jr_052_4a6f:
	ld a, $bb
	call SkillFailsNoAnim
	ret


jr_052_4a75:
	ld a, $b8
	call SkillFailsSide
	ret


SkillOddDance::
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	or [hl]
	jr z, jr_052_4a9d

	call RollRobMagic
	jr nc, jr_052_4a97

	call DrainTargetMP
	ld hl, $a5a5
	call SkillWorks
	ret


jr_052_4a97:
	ld a, $b8
	call SkillFails
	ret


jr_052_4a9d:
	ld a, $bb
	call SkillFails
	ret


SkillSideStep::
	call BattleRandom
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, jr_052_4ac1

	ld a, [wRandomHigh]
	and $04
	add $04
	ld b, a
	ld a, [hl]
	and $f3
	or b
	ld [hl], a

jr_052_4ac1:
	call SkillEndsQuietly
	ret


SkillLureDance::
	call TargetStatus3
	bit 1, [hl]
	jr nz, jr_052_4ae3

	call TryEffectRes21
	jr nc, jr_052_4add

	call TargetStatus3
	set 1, [hl]
	ld hl, $a6a6
	call SkillWorks
	ret


jr_052_4add:
	ld a, $c8
	call SkillFails
	ret


jr_052_4ae3:
	call SkillEndsQuietly
	ret


SkillLushLicks::
	call TargetStatus3
	bit 3, [hl]
	jr nz, jr_052_4b30

	ld a, [wSkillId]
	cp $7a
	jr z, jr_052_4afa

	call TryEffectRes21
	jr jr_052_4afd

jr_052_4afa:
	call RollDefenseDown

jr_052_4afd:
	jr nc, jr_052_4b2a

	call TargetStatus3
	set 3, [hl]
	ld a, [wSkillId]
	cp $79
	jr z, jr_052_4b1f

	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, $01
	ld [hli], a
	ld [hl], $00
	ld a, [wSkillTarget]
	call MarkStatDown

jr_052_4b1f:
	ld a, [wSkillId]
	add $2f
	ld h, a
	ld l, a
	call SkillWorksNoDamage
	ret


jr_052_4b2a:
	ld a, $ca
	call SkillFailsSide
	ret


jr_052_4b30:
	call SkillEndsQuietly
	ret


SkillLegSweep::
	call TargetStatus3
	bit 2, [hl]
	jr nz, jr_052_4b4c

	call TryEffectRes21NotType4
	jr nc, jr_052_4b50

	call TargetStatus3
	set 2, [hl]
	ld hl, $abab
	call SkillWorksNoDamage
	ret


jr_052_4b4c:
	call SkillEndsQuietly
	ret


jr_052_4b50:
	ld a, [wSkillTarget]
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 4, [hl]
	ld a, $c9
	jr z, jr_052_4b64

	ld a, $c1

jr_052_4b64:
	call SkillFails
	ret


SkillWarCry::
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_4b88

	call TargetStatus3
	bit 4, [hl]
	jr nz, jr_052_4b88

	call TryEffectRes21
	jr nc, jr_052_4b8c

	call TargetStatus3
	set 4, [hl]
	ld hl, $aaaa
	call SkillWorksNoDamage
	ret


jr_052_4b88:
	call SkillEndsQuietly
	ret


jr_052_4b8c:
	ld a, $ca
	call SkillFailsSide
	ret


SkillImitate::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 3, [hl]
	call SkillEndsQuietly
	ret


SkillDeMagic::
	ld a, $03
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


SkillSurge::
	ld hl, far_Call_53_601C
	rst $10
	ld hl, $aeae
	call SkillWorks
	ret


SkillUltraDown::
	call RollInstantDeath
	jr nc, jr_052_4bca

	call CanLowerTargetStats
	jr nc, jr_052_4bca

	xor a
	ld [wBattleSubStep2], a
	ld a, $03
	ld [wBattleSubStep], a
	ret


jr_052_4bca:
	ld a, $b8
	call SkillFails
	ret


SkillTatsuCall::
	call BattleRandom
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
	bit 2, [hl]
	jr nz, jr_052_4c25

	ld a, $c0
	ld b, a
	ld a, [wRandomHigh]
	cp b
	jr nc, jr_052_4c2b

	set 2, [hl]
	ld a, [wSkillId]
	call RunSkill84To86
	ld a, [wBattleArg0]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	ld a, [wBattleArg0]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillId]
	add $54
	ld [hl], a
	ld a, [wBattleArg0]
	ld [wSkillTarget], a
	ld hl, $afaf
	call SkillWorks
	ret


jr_052_4c25:
	ld a, $bb
	call SkillFailsNoAnim
	ret


jr_052_4c2b:
	ld a, $cb
	call SkillFails
	ret


SkillCover::
	ld a, $03
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


SkillTailWind::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	set 6, [hl]
	ld a, [wSkillId]
	cp $8a
	jr z, jr_052_4c6e

	ld a, [wSkillTarget]
	and $03
	cp $02
	jr z, jr_052_4c5c

	ld hl, wSkillTarget
	inc [hl]
	jr SkillTailWind

jr_052_4c5c:
	ld a, [wSkillTarget]
	rra
	rra
	and $01
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	set 5, [hl]

jr_052_4c6e:
	call SkillEndsQuietly
	ret


SkillDodge::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 5, [hl]
	call SkillEndsQuietly
	ret


SkillDefence::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [wSkillId]
	cp $90
	jr z, jr_052_4c9b

	sub $8c
	ld b, a
	ld a, [hl]
	and $f0
	or b
	ld [hl], a
	jr jr_052_4ca1

jr_052_4c9b:
	ld a, [hl]
	and $f0
	or $04
	ld [hl], a

jr_052_4ca1:
	call SkillEndsQuietly
	ret


SkillSuckAll::
	ld a, [wSkillUser]
	cp $04
	jr c, jr_052_4cb1

	ld hl, $db01
	jr jr_052_4cb4

jr_052_4cb1:
	ld hl, wSideFlags

jr_052_4cb4:
	bit 6, [hl]
	jr nz, jr_052_4cd8

	set 6, [hl]
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillUser]
	and $03
	rla
	rla
	ld b, a
	ld a, [hl]
	or b
	ld [hl], a
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 1, [hl]

jr_052_4cd8:
	call SkillEndsQuietly
	ret


SkillDanceShut::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 6, [hl]
	jr nz, jr_052_4d06

	call TryEffectRes22
	jr nc, jr_052_4d00

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 6, [hl]
	ld hl, $b0b0
	call SkillWorksSideNoDamage
	ret


jr_052_4d00:
	ld a, $b8
	call SkillFails
	ret


jr_052_4d06:
	call SkillEndsQuietly
	ret


SkillMouthShut::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	jr nz, jr_052_4d2e

	call TryEffectRes23
	jr nc, jr_052_4d32

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 7, [hl]
	ld hl, $b2b2
	call SkillWorksSideNoDamage
	ret


jr_052_4d2e:
	call SkillEndsQuietly
	ret


jr_052_4d32:
	ld a, $c9
	call SkillFailsSide
	ret


SkillMeditate::
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [$db5b], a
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	ld a, l
	ld [wSkillTempPtr], a
	ld a, h
	ld [$db5d], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr z, jr_052_4d8c

	ld bc, $01f4
	add hl, bc
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [$db5b]
	ld b, a
	call CompareHLBC
	jr c, jr_052_4d78

	ld h, b
	ld l, c

jr_052_4d78:
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [$db5d]
	ld b, a
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	ld hl, $8484
	call SkillWorks
	ret


jr_052_4d8c:
	ld a, $bb
	call SkillFails
	ret


SkillLifeSong::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $10
	jr nz, jr_052_4daa

	ld a, [hl]
	and $cf
	or $20
	ld [hl], a
	call SkillEndsQuietly
	ret


jr_052_4daa:
	ld a, [hl]
	and $cf
	ld [hl], a
	call BattleRandom
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_052_4de3

	ld a, [wSkillUser]
	and $04
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, $03

jr_052_4dc8:
	ld a, [hli]
	cp $01
	jr z, jr_052_4dd2

	dec b
	jr nz, jr_052_4dc8

	jr jr_052_4de3

jr_052_4dd2:
	ld a, $04
	ld [wBattleSubStep], a
	ld [wBattleTemp], a
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleStepArg0], a
	ret


jr_052_4de3:
	ld a, $cb
	call SkillFails
	ret


SkillLifeDance::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $7f
	jr c, jr_052_4df9

	ld a, $bb
	call SkillFails
	ret


jr_052_4df9:
	ld a, $04
	ld [wBattleSubStep], a
	ld [wBattleTemp], a
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleStepArg0], a
	ret


SkillDaze::
	call SkillEndsQuietly
	ret


SkillChgDragon::
	ld hl, $9191
	call SkillWorksNoDamage
	ret


SkillSmashlime::
	call CalcSlimeSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillSheldodge::
	call CalcBugSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillBranching::
	call CalcPlantSlayerDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillGigaSlash::
	call CalcSkillDamageRes25
	call SkillDealsDamage
	ret


SkillRunAway::
	ld a, [wSkillUser]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $ff
	ld a, [wSkillUser]
	cp $04
	jr c, jr_052_4e64

	and $03
	ld hl, wEnemyReward
	ld b, a
	add a
	add b
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	call Call_52_7242

jr_052_4e64:
	ld a, $01
	ld [wBattleSubStep], a
	call SkillEndsQuietly
	ret


SkillHalfAttack::
	call SkillAttackDamage
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call ShiftHL1
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld hl, $ca82
	call SkillDealsDamageMsg
	ret


SkillHitAlly::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $40
	jr c, jr_052_4e9e

	call SkillAttackDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


jr_052_4e9e:
	ld a, $b6
	call SkillFails
	ret


SkillHitEnemy::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $c0
	jr c, jr_052_4eb8

	call SkillAttackDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


jr_052_4eb8:
	ld a, $b6
	call SkillFails
	ret


SkillHitSelf::
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, $dced
	call IndexWords
	ld a, [wSkillUser]
	ld [hl], a
	call SkillAttackDamage
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


SkillTrip::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus3
	call AddEightTimes
	set 2, [hl]

SkillNoEffect::
	call SkillEndsQuietly
	ret


SkillCantMove::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 6, [hl]
	ld hl, $cf00
	call SkillWorksAtOnce
	ret


SkillCallHorror::
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	xor a
	ld [hli], a
	ld [hl], a
	ld a, [wSkillUser]
	push af
	ld a, [wSkillTarget]
	ld [wSkillUser], a
	call SkillRunAway
	pop af
	ld [wSkillUser], a
	ld a, $01
	ld [wBattleSubStep], a
	ld hl, $e9e9
	ld a, [wSkillId]
	cp $a4
	jr z, jr_052_4f28

	ld hl, $2929

jr_052_4f28:
	call SkillWorksNoDamage
	ret


SkillHealUsAllSpecial::
	ld a, $2f
	ld [wSkillId], a
	call SkillHeal
	ret


SkillAllChange::
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

jr_052_4f3d:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_4f4c

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 3, [hl]

jr_052_4f4c:
	inc c
	dec b
	jr nz, jr_052_4f3d

	call SkillEndsQuietly
	ret


SkillBigSleep::
	ld a, [wSkillTarget]
	ld c, a
	call CheckBattlerPresent
	jr c, jr_052_4f7b

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 7, [hl]
	jr nz, jr_052_4f75

	ld a, [hl]
	and $73
	or $8c
	ld [hl], a
	ld hl, $cccc
	call SkillWorksSideNoDamage
	ret


jr_052_4f75:
	ld a, $bd
	call SkillFails
	ret


jr_052_4f7b:
	call SkillEndsQuietly
	ret


SkillMP0::
	ld a, [wSkillTarget]
	ld c, a
	call CheckBattlerPresent
	jr c, jr_052_4f9d

	ld a, c
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	or [hl]
	jr z, jr_052_4f9d

	xor a
	ld [hld], a
	ld [hl], a
	ld hl, $7272
	call SkillWorksNoDamage
	ret


jr_052_4f9d:
	call SkillEndsQuietly
	ret


SkillCallEvil::
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
	call CheckBattlerPresent
	jr c, jr_052_4fc8

	call CalcAttack400Damage
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 0, [hl]
	ld hl, $b682
	call SkillDealsDamageMsg
	ret


jr_052_4fc8:
	call SkillEndsQuietly
	ret


SkillFreezy::
	call TargetStatus3
	bit 0, [hl]
	jr nz, jr_052_4fdc

	set 0, [hl]
	ld hl, $b5b5
	call SkillWorksSideNoDamage
	ret


jr_052_4fdc:
	call SkillEndsQuietly
	ret


UnusedRevivedCheck::
	db $fa, $89, $db, $21, $1b, $dd, $85, $6f, $3e, $00, $8c, $67, $7e, $fe, $01, $20
	db $07, $21, $9e, $9e, $cd, $93, $54, $c9, $cd, $8d, $54, $c9

SkillRestoreMP::
	ld a, [wSkillTarget]
	call GetBattlerMaxMP
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	pop bc
	ld a, [hli]
	cp [hl]
	jr z, jr_052_501b

	ld a, b
	ld [hld], a
	ld [hl], c
	ld hl, $7676
	call SkillWorksNoDamage
	ret


jr_052_501b:
	call SkillEndsQuietly
	ret


SkillMeteor::
	ld a, [wHitCount]
	ld c, a
	dec a
	cp $08
	jr nc, jr_052_5066

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_506a

	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
	cp $01
	jr nz, jr_052_5044

	ld a, d
	or a
	jr z, jr_052_5054

jr_052_5044:
	dec de
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [$db57], a
	ld hl, $8585
	call SkillDealsDamageNoSide
	ret


jr_052_5054:
	ld hl, $0001
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld hl, $8282
	call SkillDealsDamageNoSide
	ret


jr_052_5066:
	call SkillEndsQuietly
	ret


jr_052_506a:
	ld a, c
	and $03
	ld b, a
	ld a, c
	cp $04
	jr c, jr_052_507b

	ld a, [wSkillUser]
	and $04
	or b
	jr jr_052_5083

jr_052_507b:
	ld a, [wSkillUser]
	and $04
	xor $04
	or b

jr_052_5083:
	ld b, a
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld [hl], b
	ld a, b
	ld [wSkillTarget], a
	xor a
	ld [wBattleSubStep2], a
	ret


UnusedClearAmountText::
	db $3e, $00, $ea, $56, $db, $3e, $00, $ea, $57, $db

UnusedAmountText::
	db $cd, $e2, $50, $fa, $55, $db
	db $47, $fa, $54, $db, $b7, $28, $07, $fa, $88, $db, $cb, $3f, $cb, $3f, $80, $6f
	db $26, $00, $7c, $ea, $22, $c8, $7d, $ea, $23, $c8, $21, $04, $5f, $d7, $c9

UnusedItemDamageText::
	db $3e
	db $82, $ea, $55, $db, $ea, $54, $db, $fa, $56, $db, $6f, $fa, $57, $db, $67, $7d
	db $b4, $20, $04, $cd, $43, $51, $c9, $cd, $a1, $50, $c9

PrepareDamageText::
	call TargetNameToArg0
	call DamageToText
	ret


DamageToText::
	ld hl, wTextArg1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call Number16ToDecimal
	ret


EndCalledHelp::
	ld a, $05
	ld [$db51], a
	ld a, $02
	ld [wSkillMsgMode], a
	ret


UnusedNoEffectText::
	db $21, $80, $c1, $fa, $89, $db, $ea, $50, $db, $cd, $48, $6b, $3e, $00, $ea, $22
	db $c8, $3e, $b8, $ea, $23, $c8, $3e, $00, $ea, $6b, $dd, $3e, $04, $ea, $ef, $d9
	db $3e, $6f, $cd, $2c, $1b, $c9

UnusedShowText78::
	db $21, $80, $c1, $fa, $89, $db, $ea, $50, $db, $cd
	db $48, $6b, $21, $78, $00, $cd, $5d, $51, $c9

UnusedShowNothingText::
	db $21, $bb, $00, $cd, $5d, $51, $c9

ShowMissMessage::
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	call Call_52_7FCB
	srl a
	srl a
	xor $01
	add $b6
	ld l, a
	ld h, $00
	ld a, h
	ld [wTextGroup], a
	ld a, l
	ld [wTextIndex], a
	ld a, $00
	ld [wSkillMsgMode], a
	ld hl, wBattleStepArg0
	inc [hl]
	ld a, $6f
	call QueueSound
	ret


UnusedShowItemMessage::
	db $21, $80, $c1, $fa, $89, $db, $ea, $50, $db, $cd, $48, $6b, $fa, $55, $db, $ea
	db $23, $c8, $3e, $00, $ea, $22, $c8, $3e, $02, $ea, $6b, $dd, $21, $ef, $d9, $34
	db $3e, $6f, $cd, $2c, $1b, $c9

SkillAttackDamage::
	call CalcAttackDamage
	ret


ClearDamageGetStatus::
	ld a, $00
	ld [wSkillAmount], a
	ld a, $00
	ld [$db57], a
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	ret


UnusedRollIllusionMiss::
	db $cd, $59, $55, $37, $3f, $fa, $88, $db, $21, $03, $db, $cd, $6c, $2f, $cb, $4e
	db $c8, $fa, $99, $c8, $fe, $a0, $c9

UnusedRollSideStepMiss::
	db $fa, $89, $db, $21, $07, $db, $cd, $6c, $2f
	db $7e, $e6, $0c, $c8, $fa, $99, $c8, $fe, $80, $c9

ResetBattler::
	push hl
	push bc
	ld b, a
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
	ld a, b
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
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld c, [hl]
	call LoadBattlerPic
	pop bc
	pop hl
	ret


UnusedResetArgBattler::
	db $fa, $4c, $db, $cd, $dd, $51, $c9

LoadBattlerPic::
	call SetBattlerPicSpecies
	ld a, [wLinkFlags]
	bit 1, a
	ld a, b
	jr z, jr_052_5224

	cp $03
	jr nc, jr_052_5256

	jr jr_052_522e

jr_052_5224:
	cp $04
	jr c, jr_052_5256

	cp $07
	jr z, jr_052_5256

	sub $04

jr_052_522e:
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

jr_052_5256:
	ret


SetBattlerPicSpecies::
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


GetBaseMaxHP::
	push hl
	ld [wBattleTemp], a
	ld hl, far_Call_57_4136
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	ld hl, $03e7
	call CompareHLBC
	jr nc, jr_052_528b

	ld bc, $03e7

jr_052_528b:
	pop hl
	ret


GetBaseMaxMP::
	push hl
	ld [wBattleTemp], a
	ld hl, far_Call_57_4192
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


GetBaseAttack::
	push hl
	ld [wBattleTemp], a
	ld hl, far_Call_57_41EE
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


GetBaseDefense::
	push hl
	ld [wBattleTemp], a
	ld hl, far_Call_57_424A
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


GetBaseAgilityTemp::
	ld a, [wBattleTemp]

GetBaseAgility::
	push hl
	ld [wBattleTemp], a
	ld hl, far_Call_57_42A6
	rst $10
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


LoadBattlerResistances::
	ld b, a
	cp $03
	jr c, jr_052_530d

	and $03
	cp $03
	jr z, jr_052_5315

	ld a, [wLinkActive]
	or a
	ld a, b
	jr nz, jr_052_530d

	and $03
	ld hl, wEncSpecies
	call GetWordAt

jr_052_52f2:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wNewMonNameText]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld hl, wMonResistances
	jr jr_052_5324

jr_052_530d:
	ld hl, wMonResist
	call PartyMonsterField
	jr jr_052_5324

jr_052_5315:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_052_52f2

jr_052_5324:
	ret


FindBattlerSkills::
	ld b, a
	cp $03
	jr c, jr_052_5352

	and $03
	cp $03
	jr z, jr_052_535c

	ld a, [wLinkActive]
	or a
	ld a, b
	jr nz, jr_052_5352

	sub $04
	ld hl, wEncSpecies
	call GetWordAt

jr_052_533f:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld hl, wTemplateSkills
	ld b, $04
	jr jr_052_536b

jr_052_5352:
	ld hl, wMonSkills
	call PartyMonsterField
	ld b, $08
	jr jr_052_536b

jr_052_535c:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_052_533f

jr_052_536b:
	ret


MarkStatUp::
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 6, [hl]
	pop hl
	ret


MarkStatDown::
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	pop hl
	ret


MarkStatsChanged::
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	ld a, [hl]
	or $c0
	ld [hl], a
	pop hl
	ret


SkillDamageByKind::
	ld a, [wSkillId]
	cp $3a
	jr c, jr_052_53dc

	cp $7e
	jr z, jr_052_53dc

	cp $40
	jr c, jr_052_53bc

	jr z, jr_052_53c0

	cp $50
	jr c, jr_052_53c4

	cp $55
	jr c, jr_052_53c8

	cp $58
	jr c, jr_052_53cc

	cp $67
	jr c, jr_052_53d0

	cp $d6
	jr c, jr_052_53d4

	cp $dd
	jr c, jr_052_53d8

	ld a, $1b
	jr jr_052_53de

jr_052_53bc:
	sub $3a
	jr jr_052_53de

jr_052_53c0:
	ld a, $05
	jr jr_052_53de

jr_052_53c4:
	sub $3e
	jr jr_052_53de

jr_052_53c8:
	ld a, $11
	jr jr_052_53de

jr_052_53cc:
	sub $42
	jr jr_052_53de

jr_052_53d0:
	ld a, $14
	jr jr_052_53de

jr_052_53d4:
	sub $51
	jr jr_052_53de

jr_052_53d8:
	sub $bd
	jr jr_052_53de

jr_052_53dc:
	ld a, $00

jr_052_53de:
	ld c, a
	ld b, $00
	ld hl, $53e9
	add hl, bc
	add hl, bc
	jp JumpToPointer


SkillDamageRoutines::
	db $d7, $60, $d7, $60, $14, $62, $d7, $60, $32, $62, $d7, $60, $98, $62, $a9, $62
	db $ba, $62, $cb, $62, $dc, $62, $11, $63, $1f, $63, $2d, $63, $57, $63, $65, $63
	db $73, $63, $d7, $60, $d7, $60, $d7, $60, $1a, $64, $d7, $60, $d7, $60, $d7, $60
	db $04, $63, $49, $63, $3b, $63, $d7, $60, $c9

TargetStatus3::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus3
	call AddEightTimes
	ret


UnusedCheckSkillUsable::
	db $fa, $88, $db, $21, $0b, $dd, $85, $6f, $3e, $00, $8c, $67, $7e, $b7, $c8, $fa
	db $8a, $db, $ea, $4c, $db, $3e, $00, $ea, $4d, $db, $3e, $02, $ea, $4e, $db, $21
	db $00, $54, $d7, $fa, $4c, $db, $e6, $02, $c0, $21, $08, $58, $d7, $3e, $01, $b7
	db $c9

SkillFails::
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
	ld a, $80
	ld [wSkillResult], a
	ret


SkillFailsSide::
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
	ld a, $88
	ld [wSkillResult], a
	ret


SkillFailsNoAnim::
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
	ld a, $84
	ld [wSkillResult], a
	ret


SkillWorksGroup1::
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
	ld a, $93
	ld [wSkillResult], a
	ret


SkillEndsQuietly::
	ld a, $40
	ld [wSkillResult], a
	ret


SkillWorks::
	ld a, $90
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	ret


SkillWorksAtOnce::
	ld a, $d0
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	ret


SkillWorksSide::
	ld a, $98
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	ret


SkillWorksNoDamage::
	ld a, $90
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	xor a
	ld [wSkillAmount], a
	ld [$db57], a
	ret


SkillWorksSideNoDamage::
	ld a, $98
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	xor a
	ld [wSkillAmount], a
	ld [$db57], a
	ret


SkillDealsDamage::
	ld hl, $b882

SkillDealsDamageMsg::
	ld a, $a8
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	ret


SkillDealsDamageNoSide::
	ld a, $a0
	ld [wSkillResult], a
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
	ret


ShowIronizeMessage::
	ld a, [wSkillUser]
	cp $04
	jr nc, jr_052_5512

	ld bc, $0300
	jr jr_052_551b

jr_052_5512:
	ld a, [wLinkActive]
	or a
	jr z, jr_052_5532

	ld bc, $0304

jr_052_551b:
	ld d, $00

jr_052_551d:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_5524

	inc d

jr_052_5524:
	inc c
	dec b
	jr nz, jr_052_551d

	ld a, d
	cp $01
	jr z, jr_052_5532

	ld hl, $9393
	jr jr_052_5535

jr_052_5532:
	ld hl, $9494

jr_052_5535:
	call SkillWorks
	ret


HalveDamageBehindVeil::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 2, [hl]
	ret z

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call ShiftHL1
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


BattleRandom::
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_5563

	call Random
	ret


jr_052_5563:
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


UseBattleItem::
	ld a, $00
	ld [wBattleArg1], a
	ld a, [wBattleItemTarget]
	ld [wSkillTarget], a
	ld a, [wBattleItemEffect]
	ld [wBattleArg0], a
	sub $b0
	ld hl, $55c1
	call GetWordAt
	ld a, [wBattleItemEffect]
	cp $bb
	ld a, [wSkillTarget]
	jr z, jr_052_55b1

	call CheckBattlerPresent
	jr c, jr_052_55b5

jr_052_55b1:
	call JumpToItemEffect
	ret


jr_052_55b5:
	ld a, $00
	ld [wTextGroup], a
	ld a, $bf
	ld [wTextIndex], a
	ret


JumpToItemEffect::
	jp hl


BattleItemEffects::
	db $72, $56, $72, $56, $72, $56, $72, $56, $7a, $57, $7a, $57, $4d, $58, $72, $58
	db $97, $58, $bc, $58, $de, $58, $03, $59, $71, $56, $71, $56, $71, $56, $71, $56
	db $71, $56, $71, $56, $40, $59, $40, $59, $40, $59, $b8, $59, $40, $59, $03, $5a
	db $1b, $5a, $33, $5a, $6a, $5a, $82, $5a, $71, $56, $71, $56, $71, $56, $71, $56
	db $71, $56, $71, $56, $71, $56, $71, $56, $9a, $5a

ItemNoEffect::
	db $fa, $78, $db, $fe, $b3, $28
	db $04, $af, $ea, $8a, $db

ItemNothingHappens::
	db $3e, $bb, $ea, $55, $db

ItemShowFailMessage::
	db $3e, $00, $ea, $22, $c8, $fa
	db $55, $db, $ea, $23, $c8, $3e, $00, $ea, $6b, $dd, $c9

ItemShowUseMessage::
	db $3e, $01, $ea, $8a, $db
	db $fa, $89, $db, $21, $04, $50, $d7, $cd, $23, $6c, $11, $42, $ca, $21, $a0, $c1
	db $cd, $80, $0c, $fa, $78, $db, $fe, $c2, $38, $0f, $fe, $c7, $30, $0b, $21, $09
	db $58, $d7, $3e, $01, $ea, $22, $c8, $18, $0b, $fa, $55, $db, $ea, $23, $c8, $3e
	db $00, $ea, $22, $c8, $fa, $78, $db, $ea, $8a, $db, $3e, $01, $ea, $6b, $dd, $c9
ItemNone::
	db $c9

ItemHealHP::
	db $fa, $78, $db, $fe, $b3, $20, $55, $21, $69, $dd, $34, $fa, $69, $dd, $fe
	db $01, $20, $1f, $fa, $89, $db, $e6, $04, $4f, $06, $03, $79, $cd, $a5, $2f, $38
	db $06, $79, $cd, $ef, $69, $20, $0b, $0c, $05, $20, $f0, $af, $ea, $8a, $db, $c3
	db $16, $56, $fa, $89, $db, $cd, $ef, $69, $ca, $0b, $56, $fa, $89, $db, $21, $a3
	db $db, $cd, $b8, $6a, $2a, $46, $4f, $fa, $89, $db, $cd, $da, $2f, $91, $6f, $7c
	db $98, $67, $7d, $ea, $5a, $db, $7c, $ea, $5b, $db, $c3, $33, $57, $fa, $89, $db
	db $cd, $ef, $69, $ca, $0b, $56, $fa, $89, $db, $fe, $04, $38, $07, $3e, $0f, $ea
	db $4e, $db, $18, $05, $3e, $0b, $ea, $4e, $db, $21, $01, $54, $d7, $fa, $4c, $db
	db $6f, $fa, $4d, $db, $67, $cd, $9c, $67, $7d, $ea, $5a, $db, $7c, $ea, $5b, $db
	db $e5, $fa, $89, $db, $cd, $e8, $2f, $c1, $09, $e5, $fa, $89, $db, $cd, $da, $2f
	db $c1, $cd, $45, $2f, $30, $1c, $79, $95, $4f, $78, $9c, $47, $fa, $5a, $db, $6f
	db $fa, $5b, $db, $67, $7d, $91, $6f, $7c, $98, $67, $7d, $ea, $5a, $db, $7c, $ea
	db $5b, $db, $fa, $89, $db, $21, $a3, $db, $cd, $b8, $6a, $e5, $2a, $66, $6f, $fa
	db $5a, $db, $4f, $fa, $5b, $db, $47, $09, $44, $4d, $e1, $79, $22, $70, $fa, $5a
	db $db, $6f, $fa, $5b, $db, $67, $fa, $89, $db, $cb, $57, $28, $08, $44, $4d, $cd
	db $32, $6b, $cd, $d1, $5b, $3e, $84, $ea, $55, $db, $cd, $2c, $56, $cd, $c4, $5b
	db $21, $06, $5f, $d7, $af, $ea, $6b, $dd, $c9

ItemHealMP::
	db $fa, $78, $db, $fe, $b5, $20, $2b
	db $fa, $89, $db, $cd, $01, $6a, $ca, $0b, $56, $fa, $89, $db, $21, $c3, $db, $cd
	db $b8, $6a, $2a, $46, $4f, $fa, $89, $db, $cd, $e1, $2f, $91, $6f, $7c, $98, $67
	db $7d, $ea, $5a, $db, $7c, $ea, $5b, $db, $c3, $11, $58, $fa, $89, $db, $cd, $01
	db $6a, $ca, $0b, $56, $fa, $89, $db, $fe, $04, $38, $07, $3e, $10, $ea, $4e, $db
	db $18, $05, $3e, $0b, $ea, $4e, $db, $21, $01, $54, $d7, $fa, $4c, $db, $6f, $fa
	db $4d, $db, $67, $cd, $9c, $67, $7d, $ea, $5a, $db, $7c, $ea, $5b, $db, $e5, $fa
	db $89, $db, $cd, $ef, $2f, $c1, $09, $e5, $fa, $89, $db, $cd, $e1, $2f, $c1, $cd
	db $45, $2f, $30, $1c, $79, $95, $4f, $78, $9c, $47, $fa, $5a, $db, $6f, $fa, $5b
	db $db, $67, $7d, $91, $6f, $7c, $98, $67, $7d, $ea, $5a, $db, $7c, $ea, $5b, $db
	db $fa, $89, $db, $21, $c3, $db, $cd, $b8, $6a, $e5, $2a, $66, $6f, $fa, $5a, $db
	db $4f, $fa, $5b, $db, $47, $09, $44, $4d, $e1, $79, $22, $70, $fa, $5a, $db, $6f
	db $fa, $5b, $db, $67, $fa, $89, $db, $cb, $57, $28, $05, $44, $4d, $cd, $d1, $5b
	db $3e, $76, $ea, $55, $db, $cd, $2c, $56, $cd, $c4, $5b, $c9

ItemAntidote::
	db $3e, $9c, $ea, $55
	db $db, $fa, $89, $db, $21, $02, $db, $cd, $6c, $2f, $7e, $e6, $03, $20, $04, $cd
	db $b9, $5b, $c9, $7e, $e6, $fc, $77, $cd, $aa, $5b, $cd, $2c, $56, $cd, $c4, $5b
	db $c9

ItemMoonHerb::
	db $3e, $9d, $ea, $55, $db, $fa, $89, $db, $21, $02, $db, $cd, $6c, $2f, $7e
	db $e6, $40, $20, $04, $cd, $b9, $5b, $c9, $cd, $0b, $6b, $7e, $e6, $bf, $77, $cd
	db $2c, $56, $cd, $c4, $5b, $c9

ItemSkyBell::
	db $3e, $dc, $ea, $55, $db, $fa, $89, $db, $21, $02
	db $db, $cd, $6c, $2f, $7e, $e6, $10, $20, $04, $cd, $b9, $5b, $c9, $cd, $0b, $6b
	db $7e, $e6, $ef, $77, $cd, $2c, $56, $cd, $c4, $5b, $c9

ItemLaurel::
	db $3e, $9f, $ea, $55, $db
	db $fa, $89, $db, $21, $02, $db, $cd, $6c, $2f, $7e, $e6, $20, $20, $04, $cd, $b9
	db $5b, $c9, $7e, $e6, $df, $77, $cd, $2c, $56, $cd, $c4, $5b, $c9

ItemAwakeSand::
	db $3e, $db, $ea
	db $55, $db, $fa, $89, $db, $21, $02, $db, $cd, $6c, $2f, $7e, $e6, $8c, $20, $04
	db $cd, $b9, $5b, $c9, $cd, $0b, $6b, $7e, $e6, $73, $77, $cd, $2c, $56, $cd, $c4
	db $5b, $c9

ItemWorldLeaf::
	db $fa, $77, $db, $cd, $a5, $2f, $30, $31, $28, $2f, $fa, $77, $db, $ea
	db $4c, $db, $21, $0a, $51, $d7, $fa, $77, $db, $47, $cd, $dd, $51, $78, $21, $a3
	db $db, $cd, $b8, $6a, $54, $5d, $78, $21, $b3, $db, $cd, $b8, $6a, $2a, $12, $13
	db $7e, $12, $3e, $9e, $ea, $55, $db, $cd, $2c, $56, $c9, $cd, $b9, $5b, $c9

ItemMeat::
	db $3e
	db $01, $ea, $8a, $db, $fa, $77, $db, $fe, $04, $38, $38, $d6, $04, $21, $83, $db
	db $e5, $2a, $66, $6f, $e5, $3e, $0f, $ea, $4e, $db, $21, $01, $54, $d7, $fa, $99
	db $c8, $6f, $fa, $9a, $c8, $67, $fa, $4c, $db, $4f, $fa, $4d, $db, $47, $e1, $09
	db $01, $40, $06, $cd, $45, $2f, $44, $4d, $38, $03, $01, $40, $06, $e1, $79, $22
	db $70, $18, $2c, $21, $23, $dc, $cd, $b8, $6a, $e5, $2a, $66, $6f, $e5, $3e, $0b
	db $ea, $4e, $db, $21, $01, $54, $d7, $e1, $fa, $4c, $db, $4f, $fa, $4d, $db, $47
	db $7d, $91, $4f, $7c, $98, $47, $30, $03, $01, $00, $00, $e1, $79, $22, $70, $cd
	db $2c, $56, $af, $ea, $33, $da, $c9

ItemBadMeat::
	db $3e, $01, $ea, $8a, $db, $fa, $77, $db, $fe
	db $04, $38, $1c, $d6, $04, $21, $83, $db, $e5, $2a, $66, $6f, $01, $05, $00, $09
	db $01, $00, $04, $cd, $45, $2f, $44, $4d, $38, $1c, $01, $00, $04, $18, $17, $21
	db $23, $dc, $cd, $b8, $6a, $e5, $2a, $66, $d6, $05, $6f, $7c, $de, $00, $67, $44
	db $4d, $30, $03, $01, $00, $00, $e1, $79, $22, $70, $cd, $2c, $56, $af, $ea, $33
	db $da, $c9

ItemBoltStaff::
	db $fa, $89, $db, $cd, $a5, $2f, $d8, $cd, $b2, $5a, $cd, $c0, $67, $cb
	db $37, $e6, $03, $cd, $56, $67, $cd, $d4, $5a, $c9

ItemVacuumStaff::
	db $fa, $89, $db, $cd, $a5, $2f
	db $d8, $cd, $b2, $5a, $cd, $c0, $67, $07, $07, $e6, $03, $cd, $56, $67, $cd, $d4
	db $5a, $c9

ItemBlockStaff::
	db $fa, $89, $db, $cd, $a5, $2f, $d8, $fa, $89, $db, $21, $03, $db, $cd
	db $6c, $2f, $cb, $46, $c0, $cd, $bc, $5c, $30, $17, $3e, $01, $ea, $8a, $db, $fa
	db $77, $db, $21, $03, $db, $cd, $6c, $2f, $cb, $c6, $3e, $88, $ea, $55, $db, $18
	db $04, $cd, $9e, $5b, $c9, $cd, $2c, $56, $c9

ItemLavaStaff::
	db $fa, $89, $db, $cd, $a5, $2f, $d8
	db $cd, $b2, $5a, $cd, $bb, $67, $0f, $0f, $e6, $03, $cd, $56, $67, $cd, $d4, $5a
	db $c9

ItemSnowStaff::
	db $fa, $89, $db, $cd, $a5, $2f, $d8, $cd, $b2, $5a, $cd, $cf, $67, $0f, $0f
	db $e6, $03, $cd, $56, $67, $cd, $d4, $5a, $c9

ItemFireStaff::
	db $fa, $89, $db, $cd, $a5, $2f, $d8
	db $cd, $b2, $5a, $cd, $bb, $67, $cb, $37, $e6, $03, $cd, $56, $67, $cd, $d4, $5a
	db $c9

RollStaffDamage::
	db $3e, $0b, $ea, $4e, $db, $21, $01, $54, $d7, $3e, $82, $ea, $55, $db, $3e
	db $00, $ea, $54, $db, $fa, $4c, $db, $6f, $fa, $4d, $db, $67, $cd, $9c, $67, $21
	db $00, $00, $c9

StaffStrike::
	db $fa, $56, $db, $5f, $fa, $57, $db, $57, $7b, $b2, $28, $12, $cd
	db $f6, $5a, $38, $0d, $cd, $26, $5b, $21, $04, $5f, $d7, $21, $02, $55, $d7, $18
	db $03, $cd, $98, $5b, $c9

StanceReduceDamage::
	db $fa, $89, $db, $21, $09, $db, $cd, $6c, $2f, $7e, $e6
	db $03, $28, $20, $62, $6b, $cb, $4f, $20, $05, $cd, $43, $6b, $18, $05, $3e, $0a
	db $cd, $0d, $1e, $7d, $ea, $56, $db, $7c, $ea, $57, $db, $54, $5d, $7c, $b5, $20
	db $02, $37, $c9, $af, $c9

ItemDealDamage::
	db $3e, $01, $ea, $8a, $db, $fa, $89, $db, $21, $a3, $db
	db $cd, $b8, $6a, $7d, $ea, $61, $db, $7c, $ea, $62, $db, $2a, $66, $93, $4f, $7c
	db $9a, $47, $7b, $ea, $5a, $db, $7a, $ea, $5b, $db, $30, $24, $fa, $61, $db, $6f
	db $fa, $62, $db, $67, $2a, $56, $5f, $7b, $ea, $5a, $db, $7a, $ea, $5b, $db, $01
	db $00, $00, $fa, $89, $db, $21, $1b, $dd, $85, $6f, $3e, $00, $8c, $67, $cb, $c6
	db $c5, $fa, $5a, $db, $4f, $fa, $5b, $db, $47, $cd, $32, $6b, $cd, $e3, $5b, $c1
	db $fa, $61, $db, $6f, $fa, $62, $db, $67, $79, $22, $70, $3e, $82, $ea, $55, $db
	db $cd, $e9, $50, $cd, $2c, $56, $c9

ItemStaffMisses::
	db $01, $02, $00, $cd, $e3, $5b

ItemNoEffectOnTarget::
	db $3e, $b8, $ea
	db $55, $db, $cd, $23, $6c, $cd, $1b, $56, $c9

ItemCuredEnemy::
	db $fa, $89, $db, $cb, $57, $28, $07
	db $01, $64, $00, $cd, $d1, $5b, $c9, $c9

ItemUseless::
	db $fa, $89, $db, $cb, $57, $28, $00, $cd
	db $0b, $56, $c9

ItemHealSound::
	db $fa, $89, $db, $fe, $04, $30, $05, $3e, $70, $cd, $2c, $1b, $c9
AddJoinPoints::
	db $fa, $83, $db, $6f, $fa, $84, $db, $67, $09, $7d, $ea, $83, $db, $7c, $ea, $84
	db $db, $c9

SubJoinPoints::
	db $fa, $83, $db, $6f, $fa, $84, $db, $67, $7d, $91, $6f, $7c, $98, $67
	db $30, $03, $21, $00, $00, $7d, $ea, $83, $db, $7c, $ea, $84, $db, $c9

BlazeDamage::
	call CalcSkillAmount
	call GetResistByte0
	swap a
	and $03
	call ResistDamageA
	ret


FirebalDamage::
	call CalcSkillAmount
	call GetResistByte0
	rrca
	rrca
	and $03
	call ResistDamageA
	ret


BangDamage::
	call CalcSkillAmount
	call GetResistByte0
	and $03
	call ResistDamageA
	ret


InfernosDamage::
	call CalcSkillAmount

InfernosResistDamage::
	call GetResistByte1
	rlca
	rlca
	and $03
	call ResistDamageA
	ret


BoltDamage::
	call CalcSkillAmount
	call GetResistByte1
	swap a
	and $03
	call ResistDamageA
	ret


IceBoltDamage::
	call CalcSkillAmount
	call GetResistByte1
	rrca
	rrca
	and $03
	call ResistDamageA
	ret


RollInstantDeath::
	call CheckSkillAllowed
	jp z, ReturnNoCarry

	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call GetTargetStatus3
	call GetResistByte2
	swap a
	and $03
	ld [wBattleArg2], a
	ld a, [wSkillId]
	cp $72
	jr c, jr_052_5c81

	cp $82
	jr z, jr_052_5c88

	ld a, [wBattleArg2]
	call ResistChanceA
	ret


jr_052_5c81:
	ld a, [wBattleArg2]
	call ResistChanceC
	ret


jr_052_5c88:
	ld a, [wBattleArg2]
	call ResistChanceB
	ret


RollSleep::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call CalcSkillAmount
	call GetResistByte2
	rlca
	rlca
	and $03
	ld [wBattleArg2], a
	call CheckUserFlag42
	jr z, jr_052_5cae

	scf
	ret


jr_052_5cae:
	ld a, [wSkillId]
	cp $15
	ld a, [wBattleArg2]
	jp z, ResistChanceA

	jp ResistChanceC


RollStopSpell::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call GetTargetStatus3
	call GetResistByte2
	and $03
	call CheckUserFlag42
	jr z, jr_052_5cd6

	scf
	ret


jr_052_5cd6:
	call ResistChanceA
	ret


RollSurround::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call GetTargetStatus3
	call GetResistByte1
	and $03
	call CheckUserFlag42
	jr z, jr_052_5cf4

	scf
	ret


jr_052_5cf4:
	ld b, a
	ld a, [wSkillId]
	cp $72
	ld a, b
	jr z, jr_052_5d01

	call ResistChanceA
	ret


jr_052_5d01:
	call ResistChanceC
	ret


RollConfusion::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call GetTargetStatus3
	call GetResistByte3
	rlca
	rlca
	and $03
	call CheckUserFlag42
	jr z, jr_052_5d21

	scf
	ret


jr_052_5d21:
	call ResistChanceC
	ret


RollRobMagic::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [$db5b], a
	call GetTargetStatus3
	call GetResistByte2
	rrca
	rrca
	and $03
	ld [wBattleArg2], a
	call CheckUserFlag42
	jr z, jr_052_5d44

	scf
	ret


jr_052_5d44:
	call ResistChanceA
	ret


RobMagic::
	call DrainTargetMP
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wSkillUser]
	call IsMPFull
	jr nc, jr_052_5d79

	ld a, [wSkillUser]
	ld bc, $dbd4
	add a
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	ld [hld], a
	dec bc
	ld a, [bc]
	ld [hl], a

jr_052_5d79:
	ret


DrainTargetMP::
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, jr_052_5db9

	ld a, [wSkillUser]
	ld de, wBattlerLevel
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	srl a
	srl a
	add $05
	ld c, a
	ld b, $00
	call CompareHLBC
	jr nc, jr_052_5da7

	ld b, h
	ld c, l

jr_052_5da7:
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	jr jr_052_5dc4

jr_052_5db9:
	ld bc, $0000
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a

jr_052_5dc4:
	pop hl
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	ret


RollDefenseDown::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [$db5b], a
	call GetTargetStatus3
	call GetResistByte3
	swap a
	and $03
	ld [wBattleArg2], a
	call CheckUserFlag42
	jr z, jr_052_5deb

	scf
	ret


jr_052_5deb:
	ld b, a
	ld a, [wSkillId]
	cp $7a
	ld a, b
	jr z, jr_052_5df8

	call ResistChanceA
	ret


jr_052_5df8:
	call ResistChanceC
	ret


LowerDefense::
	ld a, [wSkillTarget]
	call GetBattlerDefense
	ld b, h
	ld c, l
	ld hl, $0001
	call CompareHLBC
	jr c, jr_052_5e0e

	xor a
	ret


jr_052_5e0e:
	ld a, [wSkillTarget]
	call GetBaseDefense
	call ShiftBC1
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	or h
	pop hl
	jr z, jr_052_5e3c

	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	jr nc, jr_052_5e3a

	xor a
	ld [hld], a
	ld [hl], a

jr_052_5e3a:
	scf
	ret


jr_052_5e3c:
	xor a
	ret


RaiseDefense::
	ld a, [wSkillTarget]
	call CheckDefenseRaisable
	jr nc, jr_052_5e92

	jr z, jr_052_5e92

	ld a, [wSkillTarget]
	call GetBaseDefense
	call ShiftBC1
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld a, [wSkillTarget]
	push hl
	call CheckDefenseRaisable
	pop hl
	jr c, jr_052_5e90

	ld a, [hld]
	ld e, [hl]
	ld d, a
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld a, [wSkillAmount]
	sub e
	ld e, a
	ld a, [$db57]
	sbc d
	ld d, a
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [$db57], a

jr_052_5e90:
	scf
	ret


jr_052_5e92:
	xor a
	ret


RollSlow::
	ld hl, $0000
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [$db5b], a
	call GetTargetStatus3
	call GetResistByte3
	rrca
	rrca
	and $03
	call CheckUserFlag42
	jr z, jr_052_5eb0

	scf
	ret


jr_052_5eb0:
	call ResistChanceA
	ret


LowerAgility::
	ld a, [wSkillTarget]
	call GetBaseAgility
	call ShiftBC1
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call IndexWords
	push hl
	ld d, $00
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr nz, jr_052_5ed3

	ld d, $01

jr_052_5ed3:
	push bc
	ld bc, $0002
	call CompareHLBC
	pop bc
	pop hl
	jr c, jr_052_5f06

	ld a, c
	sub d
	ld c, a
	ld a, b
	sbc $00
	ld b, a
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ld a, [hl]
	ld e, a
	sub c
	ld [hli], a
	ld a, [hl]
	ld d, a
	sbc b
	ld [hl], a
	jr nc, jr_052_5f04

	xor a
	ld [hld], a
	ld [hl], $01
	dec de
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [$db57], a

jr_052_5f04:
	scf
	ret


jr_052_5f06:
	xor a
	ret


RaiseAgility::
	ld a, [wSkillTarget]
	call CheckAgilityRaisable
	jr nc, jr_052_5f5c

	ld a, [wSkillTarget]
	call GetBaseAgility
	call ShiftBC1
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call IndexWords
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld a, [wSkillTarget]
	push hl
	call CheckAgilityRaisable
	pop hl
	jr c, jr_052_5f5a

	dec hl
	ld a, [hli]
	sub c
	ld e, a
	ld a, [hl]
	sbc b
	ld d, a
	ld a, b
	ld [hld], a
	ld [hl], c
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc d
	ld d, a
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [$db57], a

jr_052_5f5a:
	scf
	ret


jr_052_5f5c:
	xor a
	ret


TransformIntoTarget::
	ld a, [wSkillUser]
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
	call GetBaseMaxHP
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	pop hl
	jr c, jr_052_5f8a

	ld a, c
	ld [hli], a
	ld [hl], b

jr_052_5f8a:
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wSkillTarget]
	call GetBaseMaxMP
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	pop hl
	jr c, jr_052_5fb2

	ld a, c
	ld [hli], a
	ld [hl], b

jr_052_5fb2:
	ld a, [wSkillUser]
	ld hl, wBattlerMaxMP
	call IndexWords
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call IndexWords
	ld a, [wSkillTarget]
	call GetBaseAttack
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wSkillUser]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, [wSkillTarget]
	call GetBaseDefense
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wSkillUser]
	ld hl, wBattlerAgility
	call IndexWords
	ld a, [wSkillTarget]
	call GetBaseAgility
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wSkillTarget]
	call LoadBattlerResistances
	ld a, [wSkillUser]
	ld de, wBattlerResist
	ld b, a
	add a
	add b
	add a
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	call PackResistancesVia
	ld a, [wSkillTarget]
	call FindBattlerSkills
	ld a, [wSkillUser]
	ld de, wBattlerSkills
	swap a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld c, $00

jr_052_6024:
	ld a, [hl]
	ld [wBattleArg0], a
	cp $db
	call z, DropSkillDB
	cp $ff
	jr z, jr_052_605d

	ld a, $00
	ld [wBattleArg1], a
	ld a, $01
	ld [wBattleArg2], a
	push af
	push bc
	push de
	push hl
	ld hl, far_GetSkillWord
	rst $10
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wBattleArg0]
	swap a
	and $0f
	ld a, a
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	inc c
	dec b
	jr nz, jr_052_6024

	ld a, c
	cp $08
	jr z, jr_052_606b

jr_052_605d:
	ld a, $00
	ld [de], a
	inc de
	ld a, $ff
	ld [de], a
	inc de
	inc c
	ld a, c
	cp $08
	jr nz, jr_052_605d

jr_052_606b:
	call GetTargetSpeciesPtr
	ld c, [hl]
	ld a, [wSkillUser]
	ld b, a
	call LoadBattlerPic
	ret


;@ def DropSkillDB() -> a
;@ path: battle/skills/list
;@ Skill $DB is not taken over when a battler's skill list is built: it is turned
;@ into $FF, which ends the list.
DropSkillDB::
;> wBattleArg0 = 0xFF
;> return 0xFF
	ld a, $ff
	ld [wBattleArg0], a
	ret


;@ def HealTarget() -> carry
;@ path: battle/skills/effects
;@ Heals the skill's target. Skills $2D, $2F, $32 and $96 restore its full maximum
;@ HP, the others the amount the skill table gives (CalcSkillAmount). The HP stop
;@ at the maximum. Always succeeds (carry).
HealTarget::
;>@c if wSkillId not in (0x2D, 0x2F, 0x32, 0x96):
	ld a, [wSkillId]
	cp $2d
	jr z, .fullHeal

	cp $2f
	jr z, .fullHeal

;=@c
	cp $32
	jr z, .fullHeal

	cp $96
	jr z, .fullHeal

;>     CalcSkillAmount()
	call CalcSkillAmount
;>     amount = wSkillAmount
	ld a, [wSkillAmount]
	ld e, a
	ld a, [wSkillAmount + 1]
	ld d, a
	jr .add

;> else:
;>@f     amount = mem16[wBattlerMaxHP + 2 * wSkillTarget]
;>@f2     wSkillAmount = amount
.fullHeal
;=@f
	ld a, [wSkillTarget]
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
;=@f2
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a

.add
;>@h hp = (mem16[wBattlerHP + 2 * wSkillTarget] + amount) & 0xFFFF
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@h
	ld l, a
	ld a, l
	add e
	ld c, a
	ld a, h
	adc d
;=@h
	ld b, a
;> hp = min(hp, GetBattlerMaxHP(wSkillTarget))
	ld a, [wSkillTarget]
	call GetBattlerMaxHP
	call CompareHLBC
	jr nc, .store

	ld b, h
	ld c, l

.store
;> mem16[wBattlerHP + 2 * wSkillTarget] = hp
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
;> return True
	scf
	ret


;@ def CalcAttackDamage()
;@ path: battle/skills/damage
;@ The damage of a normal attack by wSkillUser on wSkillTarget, into wSkillAmount.
;@ With attack A and half the target's defense D: when A <= D the attack does 0 or 1.
;@ Otherwise the base damage is B = (A - D) / 2; when that is no more than A / 16 the
;@ damage is a random number below A / 16, else it is B moved up or down by a random
;@ amount of up to B / 16, then by one more up or down (or not). The position cut
;@ (ApplyPositionDamageCut) comes last; a result of 0 becomes 0 or 1 at random.
CalcAttackDamage::
;> BattleRandom()
	call BattleRandom
;>@d half_def = mem16[wBattlerDefense + 2 * wSkillTarget] >> 1
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@d
	call ShiftBC1
;> atk = GetBattlerAttack(wSkillUser)
	ld a, [wSkillUser]
	call GetBattlerAttack
;> if atk <= half_def:
;>@w     dmg = wRandomHigh & 1
	call CompareHLBC
	jr z, .weak

	jr c, .weak

;> else:
;>@b     base = (atk - half_def) >> 1
	ld a, l
	sub c
	ld e, a
	ld a, h
	sbc b
	ld d, a
;=@b
	srl d
	rr e
;>@s     if atk >> 4 >= base:
	push hl
	push bc
	ld b, d
	ld c, e
	call ShiftHL4
	call CompareHLBC
;=@s
	pop bc
	pop hl
	jr z, .small

	jr nc, .small

;>@s1         r = atk >> 4
;>@s2         dmg = (wRandomLow << 8 | wRandomHigh) % r if r else wRandomHigh & 1
;>@e     else:
	jr .normal

.weak
;=@w
	ld a, [wRandomHigh]
	and $01
	ld e, a
	ld d, $00
	jp .done


.small
;=@s1
	call ShiftHL4
;=@s2
	ld a, h
	or l
	jr z, .weak

	ld b, h
	ld c, l
	push hl
;=@s2
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
	pop hl
;=@s2
	ld d, b
	ld e, c
	jp .done


.normal
;>@n1         dmg = base
;>@n2         spread = base >> 3
	push de
	ld h, d
	ld l, e
	call ShiftHL3
	pop de
;>@n3         if spread:
	ld a, h
	or l
	jr z, .plusMinusOne

;>@n4             r = ((wRandomLow << 8 | wRandomHigh) % ((spread & 0xFF) + 1)) >> 1
	push hl
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	pop bc
;=@n4
	ld a, c
	inc a
	push de
	call Divide16
	pop de
;=@n4
	ld c, a
	ld b, $00
	call ShiftBC1
;>@n5             if wRandomLow & 0x0F:
	ld a, [wRandomLow]
	and $0f
	or a
	jr z, .plusMinusOne

;>@n6                 if wRandomLow & 0x08:
;>@p                     dmg += r
	bit 3, a
	jr nz, .plus

;>@n7                 else:
;>@n8                     dmg -= r
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
;=@n8
	jr .plusMinusOne

.plus
;=@p
	ld h, b
	ld l, c
	add hl, de
	ld d, h
	ld e, l

.plusMinusOne
;>@q1         r3 = wRandomHigh & 3
	ld a, [wRandomHigh]
	and $03
	or a
	jr z, .done

;>@q2         if r3 & 1:
;>@q3             dmg += 1
	bit 0, a
	jr z, .minus

	inc de
	jr .done

.minus
;>@q4         elif r3 == 2:
;>@q5             dmg -= 1
	dec de

.done
;> wSkillAmount = dmg & 0xFFFF
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a
;> ApplyPositionDamageCut()
	call ApplyPositionDamageCut
;>@z if wSkillAmount == 0:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, h
	or l
;=@z
	ret nz

;>@y     wSkillAmount = wRandomLow & 1
	ld b, a
	ld a, [wRandomLow]
	and $01
	ld c, a
	ld a, c
	ld [wSkillAmount], a
;=@y
	ld a, b
	ld [wSkillAmount + 1], a
	ret


	; unused: the same check for wSkillUser in a link battle
	db $fa, $56, $db, $6f, $fa, $57, $db, $67, $fa, $88, $db, $e6, $03, $fe, $03, $c8
	db $b7, $c8, $18, $48

;@ def ApplyPositionDamageCutLink()
;@ path: battle/skills/damage
;@ ApplyPositionDamageCut in a link battle: the third monster of either side
;@ (position 2 or 6) takes only 80% of the damage.
;@ test: skip continues inside ApplyPositionDamageCut
ApplyPositionDamageCutLink::
;> amount = wSkillAmount
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;> if wSkillTarget & 3 in (0, 3):
;>     return
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret z

	or a
	ret z

;> if wSkillTarget & 3 == 2:                # the rest is ApplyPositionDamageCut's
;>     wSkillAmount = Percent80(amount)
	jr ApplyPositionDamageCut.cut

	; unused: a check of wSkillUser in a link battle
	db $fa, $6c, $c8, $b7, $20, $d2, $fa, $88, $db, $fe, $03, $d0, $b7, $c8, $fa, $56
	db $db, $6f, $fa, $57, $db, $67, $fa, $88, $db, $18, $19

;@ def ApplyPositionDamageCut()
;@ path: battle/skills/damage
;@ The monster in the third place of the own party (position 2) takes only 80%
;@ of wSkillAmount; in a link battle that goes for both sides
;@ (ApplyPositionDamageCutLink).
;@ test: wLinkActive = 0
ApplyPositionDamageCut::
;> if wLinkActive:
;>     return ApplyPositionDamageCutLink()
	ld a, [wLinkActive]
	or a
	jr nz, ApplyPositionDamageCutLink

;> if wSkillTarget >= 3 or wSkillTarget == 0:
;>     return
	ld a, [wSkillTarget]
	cp $03
	ret nc

	or a
	ret z

;> amount = wSkillAmount
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [wSkillTarget]

.cut
;> if wSkillTarget == 2:
	cp $02
	ret nz

;>     wSkillAmount = Percent80(amount)
	call Percent80
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def CalcHPFractionDamage()
;@ path: battle/skills/damage
;@ Damage of 80% of the target's current HP plus one, cut by the target's
;@ resistance 14 (ResistDamageA).
CalcHPFractionDamage::
;>@a wSkillAmount = Percent80(GetBattlerHP(wSkillTarget)) + 1
	ld a, [wSkillTarget]
	call GetBattlerHP
	call Percent80
	inc hl
	ld a, l
	ld [wSkillAmount], a
;=@a
	ld a, h
	ld [wSkillAmount + 1], a
;> ResistDamageA(GetTargetStatus3(), GetResistByte3() & 3)
	call GetTargetStatus3
	call GetResistByte3
	and $03
	call ResistDamageA
	ret


;@ def CalcLeaveOneHPDamage() -> carry
;@ path: battle/skills/damage
;@ A skill that takes the target down to one HP: it first has to pass the
;@ target's resistance 14 (ResistChanceB), else it does nothing (no carry). In
;@ wild and link battles the damage is the target's HP minus one; in scripted
;@ battles and the tournament it is half of the user's HP minus one. At least 1.
;@ When the word at the address given by the user's HP is 1 (it reads that word
;@ rather than the HP itself), the damage is 1.
CalcLeaveOneHPDamage::
;> if not ResistChanceB(GetTargetStatus3(), GetResistByte3() & 3):
;>@f     wSkillAmount = 0
	call GetTargetStatus3
	call GetResistByte3
	and $03
	call ResistChanceB
	jr nc, .failed

;>@r     return False
;> user_hp = GetBattlerHP(wSkillUser)
;> wSkillAmount = user_hp
	ld a, [wSkillUser]
	call GetBattlerHP
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@o if mem16[user_hp] == 1:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, h
	or a
	jr nz, .notOne

;=@o
	ld a, l
	cp $01
;>     dmg = 1
	jr z, .store

;> else:
.notOne
;>     if wLinkActive or wBattleType == 0:
;>@g         dmg = GetBattlerHP(wSkillTarget) - 1
	ld a, [wLinkActive]
	or a
	jr nz, .targetHP

	ld a, [wBattleType]
	or a
;>@h     else:
	jr nz, .userHP

.targetHP
;=@g
	ld a, [wSkillTarget]
	call GetBattlerHP
	dec hl
	jr .atLeastOne

.userHP
;>@u         dmg = (user_hp - 1) >> 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	dec hl
	call ShiftHL1

.atLeastOne
;>@t     if dmg == 0:
;>@t2         dmg = 1
	ld a, h
	or l
	jr nz, .store

	ld hl, $0001

.store
;> wSkillAmount = dmg
;> return True
	scf
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


.failed
;=@f
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;=@r
	xor a
	ret


;@ def CalcAttackDamageRes0()
;@ path: battle/skills/damage
;@ A normal attack (CalcAttackDamage) whose damage then depends on the target's
;@ resistance 0 (ResistDamageC: 131% at level 0 down to 30% at level 3).
CalcAttackDamageRes0::
;> CalcAttackDamage()
	call CalcAttackDamage
;> ResistDamageC(GetTargetStatus3(), GetResistByte0() >> 4 & 3)
	call GetTargetStatus3
	call GetResistByte0
	swap a
	and $03
	call ResistDamageC
	ret


;@ def CalcAttackDamageRes4()
;@ path: battle/skills/damage
;@ A normal attack whose damage then depends on the target's resistance 4
;@ (ResistDamageC).
CalcAttackDamageRes4::
;> CalcAttackDamage()
	call CalcAttackDamage
;> ResistDamageC(GetTargetStatus3(), GetResistByte1() >> 4 & 3)
	call GetTargetStatus3
	call GetResistByte1
	swap a
	and $03
	call ResistDamageC
	ret


;@ def CalcAttackDamageRes3()
;@ path: battle/skills/damage
;@ A normal attack whose damage then depends on the target's resistance 3
;@ (ResistDamageC).
CalcAttackDamageRes3::
;> CalcAttackDamage()
	call CalcAttackDamage
;>@r ResistDamageC(GetTargetStatus3(), GetResistByte1() >> 6)
	call GetTargetStatus3
	call GetResistByte1
	rlca
	rlca
	and $03
	call ResistDamageC
;=@r
	ret


;@ def CalcAttackDamageRes5()
;@ path: battle/skills/damage
;@ A normal attack whose damage then depends on the target's resistance 5
;@ (ResistDamageC).
CalcAttackDamageRes5::
;> CalcAttackDamage()
	call CalcAttackDamage
;>@r ResistDamageC(GetTargetStatus3(), GetResistByte1() >> 2 & 3)
	call GetTargetStatus3
	call GetResistByte1
	rrca
	rrca
	and $03
	call ResistDamageC
;=@r
	ret


;@ def CalcAttackDamageVsType0()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage plus one to a target with bit 0
;@ of its type bits (wBattlerTypeBits, from bit 0 of MonsterStats byte 5).
CalcAttackDamageVsType0::
;> CalcAttackDamage()
	call CalcAttackDamage
;>@t if wBattlerTypeBits[wSkillTarget] & 0x01:
	ld a, [wSkillTarget]
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	bit 0, [hl]
	jr z, .done

;>@a     wSkillAmount = Percent150(wSkillAmount) + 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent150
	inc hl
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.done
	ret


;@ def CalcSlimeSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the slime family (family 0).
CalcSlimeSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 0:
	call GetTargetFamily
	or a
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcDragonSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the dragon family (family 1).
CalcDragonSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 1:
	call GetTargetFamily
	cp $01
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcBeastSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the beast family (family 2).
CalcBeastSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 2:
	call GetTargetFamily
	cp $02
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcBirdSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the bird family (family 3).
CalcBirdSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 3:
	call GetTargetFamily
	cp $03
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcPlantSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the plant family (family 4).
CalcPlantSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 4:
	call GetTargetFamily
	cp $04
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcBugSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the bug family (family 5).
CalcBugSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 5:
	call GetTargetFamily
	cp $05
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcDevilSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the devil family (family 6).
CalcDevilSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 6:
	call GetTargetFamily
	cp $06
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcZombieSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the zombie family (family 7).
CalcZombieSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 7:
	call GetTargetFamily
	cp $07
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcMaterialSlayerDamage()
;@ path: battle/skills/damage
;@ A normal attack that does 1.5 times the damage to the material family (family 8).
CalcMaterialSlayerDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> if GetTargetFamily() == 8:
	call GetTargetFamily
	cp $08
	jr nz, .done

;>     AmountPercent150()
	call AmountPercent150

.done
	ret


;@ def CalcSkillDamageVsZombie()
;@ path: battle/skills/damage
;@ A spell whose damage comes from the skill table (the value for own monsters,
;@ or the one for wild enemies, plus a random spread), 131% against the zombie
;@ family, then depends on the target's resistance 3 (ResistDamageB).
CalcSkillDamageVsZombie::
;> wBattleArg0 = wSkillId
;> wBattleArg1 = 0
	ld a, [wSkillId]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
;> if not wLinkActive and wSkillUser >= 4:
;>@w     wBattleArg2 = 0x0F                    # skill table field for wild enemies
	ld a, [wLinkActive]
	or a
	jr nz, .own

	ld a, [wSkillUser]
	cp $04
	jr c, .own

;=@w
	ld a, $0f
	ld [wBattleArg2], a
	jr .get

;> else:
;>     wBattleArg2 = 0x0B                    # skill table field for own monsters
.own
	ld a, $0b
	ld [wBattleArg2], a

.get
;> GetSkillValue()
	ld hl, far_GetSkillValue
	rst $10
;> AddSkillSpread(wBattleArg1 << 8 | wBattleArg0)
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	call AddSkillSpread
;> if GetTargetFamily() == 7:
	call GetTargetFamily
	cp $07
	jr nz, .resist

;>@z     wSkillAmount = Percent131(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent131
	ld a, l
;=@z
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.resist
;>@r ResistDamageB(GetTargetStatus3(), GetResistByte1() >> 6)
	call GetTargetStatus3
	call GetResistByte1
	rlca
	rlca
	and $03
	call ResistDamageB
;=@r
	ret


CalcLevelDamageRes24::
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_6403

	ld a, [wSkillUser]
	cp $04
	jr c, jr_052_6403

	ld a, l
	srl a
	add l
	ld l, a
	ld a, h
	adc $00
	ld h, a
	jr jr_052_6404

jr_052_6403:
	add hl, hl

jr_052_6404:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call GetTargetStatus3
	call GetResistByte6
	swap a
	and $03
	call ResistDamageA
	ret


CalcLevelDamage::
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	ld b, h
	ld c, l
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_643d

	ld a, [wSkillUser]
	cp $04
	jr c, jr_052_643d

	call ShiftBC1
	jr jr_052_6442

jr_052_643d:
	add hl, bc
	add hl, bc
	ld bc, $000a

jr_052_6442:
	add hl, bc
	ld bc, $00b4
	call CompareHLBC
	jr c, jr_052_644e

	ld hl, $00b4

jr_052_644e:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call Percent30
	ld b, h
	ld c, l
	call BattleRandom
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	sra b
	rr c
	jr nc, jr_052_647f

	ld a, l
	sub c
	ld c, a
	ld a, h
	sbc b
	ld b, a
	jr jr_052_6482

jr_052_647f:
	add hl, bc
	ld b, h
	ld c, l

jr_052_6482:
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	call GetTargetStatus3
	call InfernosResistDamage
	ret


CalcLevelDamage2::
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_64b1

	cp $04
	jr c, jr_052_64b1

	ld b, h
	ld c, l
	call ShiftBC1
	jr jr_052_64b5

jr_052_64b1:
	add hl, hl
	ld bc, $001e

jr_052_64b5:
	add hl, bc
	ld bc, $0096
	call CompareHLBC
	jr c, jr_052_64c1

	ld hl, $0096

jr_052_64c1:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, $05
	call Divide16
	ld b, h
	ld c, l
	call BattleRandom
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	sra b
	rr c
	jr c, jr_052_64ef

	add hl, bc
	jr jr_052_64f7

jr_052_64ef:
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr c, jr_052_64ff

jr_052_64f7:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a

jr_052_64ff:
	call GetTargetStatus3
	call InfernosResistDamage
	ret


CalcSkillDamageRes24::
	call CalcSkillAmount
	call GetResistByte6
	swap a
	and $03
	call ResistDamageB
	ret


CalcSkillDamageRes16::
	call CalcSkillAmount
	call GetResistByte4
	swap a
	and $03
	call ResistDamageB
	ret


CalcSkillDamageRes17::
	call CalcSkillAmount
	call GetResistByte4
	rrca
	rrca
	and $03
	call ResistDamageB
	ret


CalcSkillDamageRes0::
	call CalcSkillAmount
	call GetResistByte0
	swap a
	and $03
	call ResistDamageB
	ret


CalcMPLevelDamage::
	ld a, [wSkillUser]
	ld e, a
	call GetBattlerMP
	add hl, hl
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, e
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	add hl, bc
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call Percent40
	call ShiftHL2
	ld a, l
	or h
	jr z, jr_052_65a7

	ld b, h
	ld c, l
	call BattleRandom
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, [wRandomHigh]
	and $01
	jr z, jr_052_659e

	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr jr_052_659f

jr_052_659e:
	add hl, bc

jr_052_659f:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a

jr_052_65a7:
	call GetTargetStatus3
	call GetResistByte4
	rlca
	rlca
	and $03
	call ResistDamageB
	ret


TryEffectRes19::
	call CheckSkillAllowed
	jp z, ReturnNoCarry

	call GetTargetStatus3
	call GetResistByte5
	rlca
	rlca
	and $03
	call ResistChanceC
	ret


TryEffectRes18::
	call GetTargetStatus3
	call GetResistByte4
	and $03
	call ResistChanceC
	ret


TryEffectRes20::
	call GetTargetStatus3
	call GetResistByte5
	swap a
	and $03
	call ResistChanceC
	ret


TryEffectRes21::
	call GetTargetStatus3
	call GetResistByte5
	rrca
	rrca
	and $03
	ld b, a
	ld a, [wSkillId]
	cp $7c
	ld a, b
	jr nc, jr_052_65fb

	call ResistChanceA
	jr jr_052_65fe

jr_052_65fb:
	call ResistChanceC

jr_052_65fe:
	ret


TryEffectRes21NotType4::
	ld a, [wSkillTarget]
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 4, [hl]
	ret nz

	call TryEffectRes21
	ret


CanLowerTargetStats::
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	ld a, b
	or c
	jr nz, jr_052_6646

	ld a, $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	ld a, b
	or c
	jr nz, jr_052_6646

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr z, jr_052_6646

	xor a
	ret


jr_052_6646:
	scf
	ret


RunSkill84To86::
	ld a, [wSkillId]
	cp $84
	jr z, jr_052_665d

	cp $85
	jr z, jr_052_6663

	cp $86
	jr z, jr_052_6669

	ld hl, far_SetUpCalledMonster4
	rst $10
	jr jr_052_666d

jr_052_665d:
	ld hl, far_SetUpCalledMonster1
	rst $10
	jr jr_052_666d

jr_052_6663:
	ld hl, far_SetUpCalledMonster2
	rst $10
	jr jr_052_666d

jr_052_6669:
	ld hl, far_SetUpCalledMonster3
	rst $10

jr_052_666d:
	ld a, [wSkillUser]
	and $04
	or $03
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


ShowUserPicC9::
	ld hl, far_TransformSkillUser
	rst $10
	ld c, $c9
	ld a, [wSkillUser]
	ld b, a
	call LoadBattlerPic
	ret


TryEffectRes22::
	call GetTargetStatus3
	call GetResistByte5
	and $03
	call ResistChanceA
	ret


TryEffectRes23::
	call GetTargetStatus3
	call GetResistByte6
	rlca
	rlca
	and $03
	call ResistChanceA
	ret


CalcSkillDamageRes25::
	call CalcSkillAmount
	call GetResistByte6
	rrca
	rrca
	and $03
	call ResistDamageA
	ret


CalcAttack400Damage::
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call IndexWords
	push hl
	ld a, [hli]
	ld b, [hl]
	ld c, a
	push bc
	ld a, $01
	ld [hld], a
	ld [hl], $90
	call SkillAttackDamage
	pop bc
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


CalcSkillAmount::
	ld a, [wSkillId]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_66f2

	ld a, [wSkillUser]
	bit 2, a
	jr z, jr_052_66f2

	ld a, $0f
	jr jr_052_66f4

jr_052_66f2:
	ld a, $0b

jr_052_66f4:
	ld [wBattleArg2], a
	ld hl, far_GetSkillValue
	rst $10
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	call AddSkillSpread

GetTargetStatus3::
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus3
	call AddEightTimes
	ret


ResistChanceA::
	bit 6, [hl]
	jr z, jr_052_6719

	call ChanceByLevel75
	jr jr_052_6725

jr_052_6719:
	bit 7, [hl]
	jr z, jr_052_6722

	call ChanceByLevelLowered
	jr jr_052_6725

jr_052_6722:
	call ChanceByLevel84

jr_052_6725:
	ret


	db $cb, $76, $28, $05, $cd, $ec, $67, $18, $03, $cd, $02, $68, $c9

ResistChanceB::
	bit 6, [hl]
	jr z, jr_052_673c

	call ChanceByLevel75Low
	jr jr_052_6748

jr_052_673c:
	bit 7, [hl]
	jr z, jr_052_6745

	call ChanceByLevelLowered
	jr jr_052_6748

jr_052_6745:
	call ChanceByLevel75

jr_052_6748:
	ret


ResistChanceC::
	bit 7, [hl]
	jr z, jr_052_6752

	call ChanceByLevel84
	jr jr_052_6755

jr_052_6752:
	call ChanceByLevel75Low

jr_052_6755:
	ret


ResistDamageA::
	bit 6, [hl]
	jr z, jr_052_675f

	call DamageByLevel75
	jr jr_052_676b

jr_052_675f:
	bit 7, [hl]
	jr z, jr_052_6768

	call DamageByLevel131
	jr jr_052_676b

jr_052_6768:
	call DamageByLevel85

jr_052_676b:
	ret


ResistDamageB::
	bit 6, [hl]
	jr z, jr_052_6775

	call DamageByLevel75Low
	jr jr_052_6781

jr_052_6775:
	bit 7, [hl]
	jr z, jr_052_677e

	call DamageByLevel131
	jr jr_052_6781

jr_052_677e:
	call DamageByLevel75

jr_052_6781:
	ret


ResistDamageC::
	bit 6, [hl]
	jr z, jr_052_678b

	call DamageByLevel85
	jr jr_052_678e

jr_052_678b:
	call DamageByLevel131

jr_052_678e:
	ret


	db $cb, $7e, $28, $05, $cd, $3c, $68, $18, $03, $cd, $62, $68, $c9

AddSkillSpread::
	ld a, [wBattleArg2]
	or a
	jr z, jr_052_67b2

	inc a
	ld c, a
	ld a, [wRandomHigh]

jr_052_67a7:
	cp c
	jr c, jr_052_67ae

	sub c
	jr nc, jr_052_67a7

	ld a, c

jr_052_67ae:
	ld c, a
	ld b, $00
	add hl, bc

jr_052_67b2:
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


GetResistByte0::
	ld de, wBattlerResist
	jr jr_052_67dc

GetResistByte1::
	ld de, $dd29
	jr jr_052_67dc

GetResistByte2::
	ld de, $dd2a
	jr jr_052_67dc

GetResistByte3::
	ld de, $dd2b
	jr jr_052_67dc

GetResistByte4::
	ld de, $dd2c
	jr jr_052_67dc

GetResistByte5::
	ld de, $dd2d
	jr jr_052_67dc

GetResistByte6::
	ld de, $dd2e

jr_052_67dc:
	ld a, [wSkillTarget]
	ld b, a
	add a
	add b
	add a
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ret


ChanceByLevel84::
	and a
	jr nz, jr_052_67f1

	scf
	ret


jr_052_67f1:
	cp $01
	jr nz, jr_052_67f8

	jp Chance84


jr_052_67f8:
	cp $02
	jr nz, jr_052_67ff

	jp Chance50


jr_052_67ff:
	scf
	ccf
	ret


ChanceByLevelLowered::
	cp $02
	jr nc, jr_052_6807

	ret


jr_052_6807:
	jr nz, jr_052_680c

	jp Chance75


jr_052_680c:
	scf
	ccf
	ret


ChanceByLevel75::
	and a
	jr nz, jr_052_6814

	scf
	ret


jr_052_6814:
	cp $01
	jr nz, jr_052_681b

	jp Chance75


jr_052_681b:
	cp $02
	jr nz, jr_052_6822

	jp Chance40


jr_052_6822:
	scf
	ccf
	ret


ChanceByLevel75Low::
	and a
	jr nz, jr_052_682b

	jp Chance75


jr_052_682b:
	cp $01
	jr nz, jr_052_6832

	jp Chance50


jr_052_6832:
	cp $02
	jr nz, jr_052_6839

	jp Chance25


jr_052_6839:
	scf
	ccf
	ret


DamageByLevel85::
	and a
	ret z

	cp $01
	jr nz, jr_052_6845

	jp AmountPercent85


jr_052_6845:
	cp $02
	jr nz, jr_052_684c

	jp AmountHalf


jr_052_684c:
	jp AmountZero


DamageByLevel75::
	and a
	ret z

	cp $01
	jr nz, jr_052_6858

	jp AmountPercent75


jr_052_6858:
	cp $02
	jr nz, jr_052_685f

	jp AmountPercent40


jr_052_685f:
	jp AmountZero


DamageByLevel131::
	and a
	jr nz, jr_052_6868

	jp AmountPercent131


jr_052_6868:
	cp $01
	jr nz, jr_052_686f

	jp AmountPercent116


jr_052_686f:
	cp $02
	jr nz, jr_052_6876

	jp AmountPercent75


jr_052_6876:
	jp AmountPercent30


DamageByLevel75Low::
	and a
	jr nz, jr_052_687f

	jp AmountPercent75


jr_052_687f:
	cp $01
	jr nz, jr_052_6886

	jp AmountHalf


jr_052_6886:
	cp $02
	jr nz, jr_052_688d

	jp AmountQuarter


jr_052_688d:
	jp AmountZero


Chance84::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $d8
	ret


Chance75::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $bf
	ret


Chance50::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $7f
	ret


Chance40::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $66
	ret


Chance25::
	call BattleRandom
	ld a, [wRandomHigh]
	cp $3f
	ret


AmountPercent131::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent131
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountPercent116::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent116
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountPercent85::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent85
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountPercent75::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent75
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountHalf::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call ShiftHL1
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountPercent40::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent40
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountPercent30::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent30
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountQuarter::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call ShiftHL2
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


AmountZero::
	xor a
	ld [wSkillAmount], a
	ld [$db57], a
	ret


AmountPercent150::
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call Percent150
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ret


Percent150::
	ld b, h
	ld c, l
	call ShiftHL1
	add hl, bc
	ret


Percent131::
	ld b, h
	ld c, l
	call ShiftBC2
	add hl, bc
	call ShiftBC2
	add hl, bc
	ret


Percent116::
	ld b, h
	ld c, l
	call ShiftBC3
	add hl, bc
	call ShiftBC2
	add hl, bc
	ret


	db $cd, $43, $6b, $44, $4d, $cd, $32, $6b, $09, $cd, $32, $6b, $09, $cd, $2e, $6b
	db $09, $c9

Percent85::
	push de
	ld b, h
	ld c, l
	ld a, $55
	call Multiply24
	ld a, $64
	call Divide24
	pop de
	ret


Percent80::
	push de
	ld b, h
	ld c, l
	ld a, $08
	call Multiply24
	ld a, $0a
	call Divide24
	pop de
	ret


Percent75::
	push bc
	call ShiftHL1
	ld b, h
	ld c, l
	call ShiftBC1
	add hl, bc
	pop bc
	ret


Percent60::
	push de
	ld b, h
	ld c, l
	ld a, $06
	call Multiply24
	ld a, $0a
	call Divide24
	pop de
	ret


Percent40::
	call Percent80
	call ShiftHL1
	ret


Percent30::
	call Percent60
	call ShiftHL1
	ret


	db $e5, $c5, $47, $cd, $e8, $2f, $e5, $78, $cd, $da, $2f, $c1, $cd, $45, $2f, $c1
	db $e1, $c9

IsMPFull::
	push hl
	push bc
	ld b, a
	call GetBattlerMP
	push hl
	ld a, b
	call GetBattlerMaxMP
	pop bc
	call CompareHLBC
	pop bc
	pop hl
	ret


CheckDefenseRaisable::
	ld [wBattleArg0], a
	call GetBattlerDefense
	ld bc, $03e7
	call CompareHLBC
	jr nc, jr_052_6a45

	push hl
	ld a, [wBattleArg0]
	call GetBaseDefense
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_6a35

	ld a, [wBattleArg0]
	cp $04
	jr nc, jr_052_6a39

jr_052_6a35:
	sla c
	rl b

jr_052_6a39:
	sla c
	rl b
	pop hl
	call CompareHLBC
	jr nc, jr_052_6a45

jr_052_6a43:
	scf
	ret


jr_052_6a45:
	jr z, jr_052_6a43

	xor a
	ret


CheckAgilityRaisable::
	ld [wBattleArg0], a
	ld hl, wBattlerAgility
	call GetWordAt
	ld bc, $01ff
	call CompareHLBC
	jr z, jr_052_6a73

	jr nc, jr_052_6a73

	push hl
	ld a, [wBattleArg0]
	call GetBaseAgility
	ld a, [wBattleArg0]
	ld [wStatCapPos], a
	call StatLimitTimes
	pop hl
	call CompareHLBC
	jr nc, jr_052_6a73

	ret


jr_052_6a73:
	xor a
	ret


PackResistancesVia::
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld a, e
	ld [wBattleArg2], a
	ld a, d
	ld [wBattleArg3], a
	ld hl, far_PackResistancesFar
	rst $10
	ret


GetResistByte::
	push af
	push bc
	push de
	push hl
	ld a, [wBattleArg0]
	ld hl, $6aa3
	call IndexWords
	call JumpToPointer
	ld [wBattleArg0], a
	pop hl
	pop de
	pop bc
	pop af
	ret


	db $e9, $bb, $67, $c0, $67, $c5, $67, $ca, $67, $cf, $67, $d4, $67, $d9, $67

GetWordAt::
	call IndexWords
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


IndexWords::
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


GetTargetFamily::
	call GetTargetSpeciesPtr
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	ret


GetTargetSpeciesPtr::
	ld a, [wSkillTarget]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ret


CheckUserFlag42::
	cp $03
	ret z

	push bc
	push hl
	ld b, a
	ld a, [wSkillUser]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $04
	ld a, b
	pop hl
	pop bc
	ret


StatLimitTimes::
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_6b02

	ld a, [wStatCapPos]
	cp $04
	jr nc, jr_052_6b06

jr_052_6b02:
	sla c
	rl b

jr_052_6b06:
	sla c
	rl b
	ret


	db $e5, $f5, $fa, $89, $db, $21, $13, $dd, $85, $6f, $3e, $00, $8c, $67, $36, $03
	db $f1, $e1, $c9

ReturnNoCarry::
	scf
	ccf
	ret


CheckSkillAllowed::
	ld hl, far_Call_53_51AA
	rst $10
	ld a, [wBattleArg0]
	or a
	ret


ShiftBC3::
	srl b
	rr c

ShiftBC2::
	srl b
	rr c

ShiftBC1::
	srl b
	rr c
	ret


ShiftHL4::
	srl h
	rr l

ShiftHL3::
	srl h
	rr l

ShiftHL2::
	srl h
	rr l

ShiftHL1::
	srl h
	rr l
	ret


GetBattlerNameTo::
	cp $03
	jr nc, jr_052_6b66

CopyPartyMonName::
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	push hl
	call CopyName
	pop hl

jr_052_6b5b:
	ld a, [hl]
	cp $f0
	ret z

	inc hl
	jr jr_052_6b5b

jr_052_6b62:
	ld a, b
	pop bc
	jr CopyPartyMonName

jr_052_6b66:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
	jr z, jr_052_6b8f

	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_6b62

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
	jr nz, jr_052_6b8c

	ld a, b

jr_052_6b8c:
	pop bc
	jr nz, jr_052_6bb7

jr_052_6b8f:
	push af
	call GetSpeciesNameWithLetter
	pop af
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


GetSpeciesNameWithLetter::
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


jr_052_6bb7:
	call CopyPartyMonName
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
	jr z, jr_052_6be3

	cp $02
	jr z, jr_052_6bed

	ld a, [hli]
	cp [hl]
	jr z, jr_052_6c09

	inc hl
	cp [hl]
	jr z, jr_052_6c09

	jr jr_052_6c18

jr_052_6be3:
	ld a, [hli]
	cp [hl]
	jr z, jr_052_6c0e

	ld a, [hli]
	cp [hl]
	jr z, jr_052_6c09

	jr jr_052_6c18

jr_052_6bed:
	ld d, $00
	inc hl
	inc hl
	ld a, [hld]
	dec hl
	cp [hl]
	jr nz, jr_052_6bf7

	inc d

jr_052_6bf7:
	inc hl
	cp [hl]
	jr nz, jr_052_6bfc

	inc d

jr_052_6bfc:
	ld a, d
	or a
	jr z, jr_052_6c18

	cp $01
	jr z, jr_052_6c0e

	pop hl
	ld a, $03
	jr jr_052_6c11

jr_052_6c09:
	pop hl
	ld a, $01
	jr jr_052_6c11

jr_052_6c0e:
	pop hl
	ld a, $02

jr_052_6c11:
	ld [wBattleArg1], a
	ld [hli], a
	ld [hl], $f0
	ret


jr_052_6c18:
	pop hl
	xor a
	ld [wBattleArg1], a
	ret


	db $21, $a0, $c1, $18, $03

TargetNameToArg0::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	ret


	db $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db, $fa, $88, $db, $ea, $50
	db $db, $cd, $48, $6b, $c9

RunActionStep::
	ld a, [wBattleAnimDone]
	or a
	jr nz, jr_052_6c5c

	ld hl, far_UpdateScreenEffect
	rst $10
	ld a, [wBattleAnimDone]
	or a
	ret z

jr_052_6c5c:
	ld a, [wBattleSubStep]
	rst $00

ActionSteps::
	dw Jump_52_6C98
	dw Jump_52_6CB2
	dw Jump_52_6D56
	dw Jump_52_6E2B
	dw Jump_52_6E74
	dw Jump_52_6F56
	dw Jump_52_6FFA
	dw Jump_52_7227
	dw Call_52_7242
	dw Jump_52_727A
	dw Jump_52_7350
	dw Jump_52_7416
	dw Jump_52_7474
	dw Jump_52_74ED
	dw Jump_52_74F1
	dw Jump_52_7590
	dw Jump_52_7599
	dw Jump_52_75A3
	dw Jump_52_6C98
	dw Jump_52_75A8
	dw Jump_52_75B4
	dw Jump_52_7EB5
	dw Jump_52_7ED9
	dw Jump_52_7EDE
	dw Jump_52_7ED9
	dw Jump_52_7EDE
	dw Jump_52_7EE3
	dw Jump_52_7EE8

Jump_52_6C98::
	ld hl, far_Call_53_44CA
	rst $10
	ld a, [wBattleSubStep]
	cp $09
	ret nz

	xor a
	ld hl, wBattleSubStep2
	ld [hli], a
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld a, $fe
	ld [hl], a
	jp Jump_52_727A


Jump_52_6CB2::
	ld a, [wBattleSubStep2]
	cp $0b
	jr z, jr_052_6cc7

	cp $10
	jr z, jr_052_6cf2

	ld hl, far_Call_53_51E8
	rst $10
	ld a, [wBattleSubStep2]
	cp $0b
	ret nz

jr_052_6cc7:
	ld hl, wBattleSubStep2
	inc [hl]
	xor a
	ld [$c1c9], a
	ld a, [wSkillId]
	ld c, a
	ld b, $00
	ld hl, $4011
	add hl, bc
	add hl, bc
	call JumpToPointer
	ld a, [wBattleSubStep2]
	cp $0c
	ret nz

	ld a, [wBattleSubStep]
	cp $01
	ret nz

	ld hl, far_Call_53_51E8
	rst $10
	ret


	db $2a, $66, $6f, $e9

jr_052_6cf2:
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	ld a, [wSkillId]
	cp $29
	jr z, jr_052_6d20

	cp $aa
	jr z, jr_052_6d0a

	cp $d5
	jp nz, Jump_52_6D56

jr_052_6d0a:
	ld a, $04
	ld [wBattleSubStep], a
	call ShowUserPicC9
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 4, [hl]
	jp Jump_52_6E74


jr_052_6d20:
	ld a, $05
	ld [wBattleSubStep], a
	call TransformIntoTarget
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 5, [hl]
	ld a, [wLinkActive]
	or a
	jp nz, Jump_52_6F56

	ld a, [wSkillUser]
	cp $04
	jp c, Jump_52_6F56

	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillTarget]
	ld [hl], a
	ret


Jump_52_6D56::
	ld a, [wSoundChannels]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

	ld a, [wBattleAnimDone]
	or a
	ret z

	ld a, [wSkillId]
	cp $a4
	jr z, jr_052_6d70

	cp $a2
	jr nz, jr_052_6d77

jr_052_6d70:
	ld hl, wBattleSubStep
	inc [hl]
	jp Jump_052_6e6f


jr_052_6d77:
	xor a
	ld [wBattleTemp], a
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wSkillId]
	cp $1a
	jp z, Jump_052_6df2

	cp $75
	jp z, Jump_052_6df2

	cp $76
	jp z, Jump_052_6df2

	cp $15
	jr c, jr_052_6db0

	cp $71
	jp z, Jump_052_6df2

	cp $37
	jr z, jr_052_6db0

	cp $38
	jr z, jr_052_6db0

	cp $3a
	jp c, Jump_052_6df2

	cp $94
	jp z, Jump_052_6df2

jr_052_6db0:
	ld a, [wSkillId]
	cp $12
	jp z, Jump_052_6df2

	cp $13
	jp z, Jump_052_6df2

	ld a, [wSkillResult]
	bit 5, a
	jp z, Jump_052_6df2

	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	jr c, jr_052_6de8

	ld a, d
	ld [hld], a
	ld [hl], e
	or e
	jp nz, Jump_052_6df2

jr_052_6de8:
	ld a, $1a
	ld [wBattleSubStep], a
	xor a
	ld [wFallStep], a
	ret


Jump_052_6df2:
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, jr_052_6e02

	cp $03
	jr nc, jr_052_6e26

	jr jr_052_6e0a

jr_052_6e02:
	cp $04
	jr c, jr_052_6e26

	cp $07
	jr z, jr_052_6e26

jr_052_6e0a:
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, jr_052_6e26

	ld a, $1a
	ld [wBattleSubStep], a
	xor a
	ld [wFallStep], a
	ret


	db $21, $06, $50, $d7, $3e, $01, $ea, $7e, $c8, $c9

jr_052_6e26:
	ld hl, far_PrintPanelHPMP
	rst $10
	ret


Jump_52_6E2B::
	ld a, [wSkillId]
	cp $14
	jr z, jr_052_6e60

	cp $80
	jr z, jr_052_6e5b

	cp $82
	jr z, jr_052_6e65

	cp $83
	jr z, jr_052_6e5b

	cp $a5
	jr z, jr_052_6e5b

	cp $88
	jr z, jr_052_6e6a

	cp $89
	jr z, jr_052_6e6a

	cp $a2
	jr z, jr_052_6e6f

	cp $a4
	jr z, jr_052_6e6f

	ld hl, wBattleSubStep
	inc [hl]
	inc [hl]
	inc [hl]
	jp Jump_52_6FFA


jr_052_6e5b:
	ld hl, far_Call_53_60B3
	rst $10
	ret


jr_052_6e60:
	ld hl, far_Call_53_670E
	rst $10
	ret


jr_052_6e65:
	ld hl, far_Call_53_65AC
	rst $10
	ret


jr_052_6e6a:
	ld hl, far_Call_53_4F4C
	rst $10
	ret


Jump_052_6e6f:
jr_052_6e6f:
	ld hl, far_Call_53_6BE2
	rst $10
	ret


Jump_52_6E74::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wBattleAnimDone]
	or a
	ret z

	ld a, [wMonStats]
	or a
	jr z, jr_052_6e89

	dec a
	ld [wMonStats], a
	ret


Jump_052_6e89:
jr_052_6e89:
	ld a, [wSkillId]
	cp $32
	jr z, jr_052_6ef1

	cp $96
	jr z, jr_052_6ef1

	cp $3b
	jr z, jr_052_6ef6

	cp $3e
	jr z, jr_052_6f02

	cp $3c
	jr z, jr_052_6f0e

	cp $67
	jr z, jr_052_6f1a

	cp $68
	jr z, jr_052_6f24

	cp $69
	jp z, Jump_052_6f2e

	cp $80
	jp z, Jump_052_6f38

	cp $95
	jp z, Jump_052_6f42

	cp $aa
	jp z, Jump_052_6f4e

	cp $d5
	jp z, Jump_052_6f4e

	call Call_52_6ECF
	jp nz, Jump_052_6f52

	ld hl, wBattleSubStep
	inc [hl]
	jp Jump_52_6F56


	db $c9

Call_52_6ECF::
	ld a, [$dd6e]
	or a
	jr z, jr_052_6ed7

	xor a
	ret


jr_052_6ed7:
	ld a, [$dd6c]
	and $08
	cp $08
	ret z

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	bit 2, [hl]
	ret z

	ld a, [wSkillFlags1]
	bit 7, a
	ret


jr_052_6ef1:
	ld hl, far_Call_53_6A9B
	rst $10
	ret


jr_052_6ef6:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6EFA::
	dw Jump_52_77C8
	dw Jump_52_77E2
	dw Jump_52_7920
	dw Jump_52_797C

jr_052_6f02:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F06::
	dw Jump_52_7892
	dw Jump_52_78A3
	dw Jump_52_7920
	dw Jump_52_797C

jr_052_6f0e:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F12::
	dw Jump_52_79A4
	dw Jump_52_79B5
	dw Jump_52_7920
	dw Jump_52_797C

jr_052_6f1a:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F1E::
	dw Jump_52_7B31
	dw Jump_52_798E
	dw Jump_52_797C

jr_052_6f24:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F28::
	dw Jump_52_7B75
	dw Jump_52_798E
	dw Jump_52_797C

Jump_052_6f2e:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F32::
	dw Jump_52_7BB7
	dw Jump_52_798E
	dw Jump_52_797C

Jump_052_6f38:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F3C::
	dw Jump_52_7A49
	dw Jump_52_7A5F
	dw Jump_52_797C

Jump_052_6f42:
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_6F46::
	dw Jump_52_7A69
	dw Jump_52_7A80
	dw Jump_52_7A95
	dw Jump_52_797C

Jump_052_6f4e:
	call Call_52_7AB5
	ret


Jump_052_6f52:
	call Call_52_7BEC
	ret


Jump_52_6F56::
	ld hl, far_Call_53_5F15
	rst $10
	ret


Jump_052_6f5b:
	res 6, [hl]
	ld a, [wSkillFlags3]
	bit 4, a
	jp z, Jump_052_706c

	call Call_52_7FD8
	jp c, Jump_052_706c

	ld a, $12
	ld [wBattleSubStep], a
	ret


Jump_052_6f71:
	ld a, [wHitCount]
	cp $04
	jp z, Jump_052_706c

	ld hl, far_Call_58_642C
	rst $10
	ld a, $01
	ld [wBattleSubStep], a
	ret


Jump_052_6f83:
	ld a, [wHitCount]
	cp $02
	jp z, Jump_052_706c

	ld a, $01
	ld [wBattleSubStep], a
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret nc

	ld hl, far_Call_58_642C
	rst $10
	ret


Jump_052_6f9c:
	ld a, [wHitCount]
	cp $13
	jp z, Jump_052_706c

	ld b, $03
	jr jr_052_6fb2

Jump_052_6fa8:
	ld a, [wHitCount]
	cp $17
	jp z, Jump_052_706c

	ld b, $07

jr_052_6fb2:
	and b
	ld c, a
	ld a, [wRandomLow]
	and b
	cp c
	jp z, Jump_052_706c

	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 0, [hl]
	jp z, Jump_052_706c

	ld hl, far_Call_58_642C
	rst $10
	ld a, $01
	ld [wBattleSubStep], a
	ret


Jump_052_6fd4:
jr_052_6fd4:
	ld a, [wHitCount]
	cp $04
	jp nc, Jump_052_706c

	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [hl]
	inc a
	ld [hl], a
	and $03
	cp $03
	jr z, jr_052_706c

	ld a, [hl]
	call CheckBattlerPresent
	jr c, jr_052_6fd4

	ld a, $01
	ld [wBattleSubStep], a
	ret


Jump_52_6FFA::
	ld a, [wMonStats]
	or a
	jr z, jr_052_7005

	dec a
	ld [wMonStats], a
	ret


jr_052_7005:
	ld a, [$c1c8]
	cp $ff
	jr z, jr_052_702c

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

jr_052_702c:
	ld hl, far_UpdateStatusIcon_50
	rst $10
	call Call_52_7E85
	call Call_52_7782
	jp c, Jump_052_70e0

	call Call_52_7DD7
	ret c

	xor a
	ld [wSkillMsgMode], a
	ld a, [wSkillId]
	cp $50
	jp z, Jump_052_6f83

	cp $51
	jp z, Jump_052_6f71

	cp $52
	jp z, Jump_052_6f9c

	cp $53
	jp z, Jump_052_6fa8

	cp $57
	jp z, Jump_052_6fd4

	cp $a7
	jp z, Jump_052_714c

	cp $a8
	jp z, Jump_052_714c

	cp $af
	jp z, Jump_052_714c

Jump_052_706c:
jr_052_706c:
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $03
	ld [hl], a
	ld a, [wSkillTargeting]
	and $03
	cp $01
	jp nz, Jump_052_7184

Call_52_7085::
	call Call_52_7D77
	ld a, [$dd6d]
	or a
	call nz, Call_52_7D7C
	call Call_52_7B1A
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	cp $04
	jr nc, jr_052_70a4

	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld hl, far_PrintPanelHPMP
	rst $10

jr_052_70a4:
	call Call_52_7DCD
	bit 6, [hl]
	jp nz, Jump_052_6f5b

	call Call_52_7EF1
	jp nc, Jump_052_706c

jr_052_70b2:
	ld a, [$db82]
	inc a
	ld [$db82], a
	cp $09
	jr nc, jr_052_7120

	call Call_52_7782
	jr c, jr_052_70e0

	ld a, [$db82]
	ld hl, $db79
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_052_7120

	cp $10
	jr z, jr_052_70dc

	call CheckBattlerPresent
	jr c, jr_052_70b2

jr_052_70dc:
	ld hl, wBattleStep
	dec [hl]

Jump_052_70e0:
jr_052_70e0:
	ld a, [wSkillId]
	cp $52
	jr c, Call_52_710E

	cp $54
	jr nc, Call_52_710E

	ld a, [$c1c9]
	or a
	jr z, jr_052_7111

	ld hl, far_Call_56_4485
	rst $10
	ld a, $da
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $1b
	ld [wBattleSubStep], a
	ld a, $07
	ld [wBattleStep], a
	ret


Call_52_710E::
	call Call_52_76C8

jr_052_7111:
	call Call_52_7B1A
	xor a
	ld hl, wBattleSubStep
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret


jr_052_7120:
	xor a
	ld [$db82], a
	ld hl, wBattleStep
	inc [hl]
	ld hl, wSideFlags
	ld a, [hl]
	and $50
	call nz, Call_52_7139
	inc hl
	ld a, [hl]
	and $50
	call nz, Call_52_7139
	ret


Call_52_7139::
	push hl
	ld a, [hl]
	and $af
	ld [hl], a
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	ld [hl], a
	pop hl
	ret


Jump_052_714c:
jr_052_714c:
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [wHitCount]
	cp $08
	jp nc, Jump_052_706c

	cp $04
	jr nz, jr_052_7169

	ld a, [hl]
	and $04
	xor $04
	ld [hl], a
	jr jr_052_7176

jr_052_7169:
	inc [hl]
	ld a, [hl]
	call CheckBattlerPresent
	jr nc, jr_052_7176

	ld hl, wHitCount
	inc [hl]
	jr jr_052_714c

jr_052_7176:
	ld a, $01
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	xor a
	ld [wBattleStepArg0], a
	ret


Jump_052_7184:
jr_052_7184:
	ld a, [$dd6c]
	cp $02
	jp z, Jump_052_71f8

	cp $10
	jr z, jr_052_719c

	cp $04
	jr z, jr_052_7198

	cp $01
	jr nz, jr_052_719c

jr_052_7198:
	call Call_52_7EF1
	ret


jr_052_719c:
	ld a, [wSkillTarget]
	bit 2, a
	push af
	jr z, jr_052_71a8

	ld a, $07
	jr jr_052_71aa

jr_052_71a8:
	ld a, $03

jr_052_71aa:
	ld c, a
	pop af
	cp c
	jp z, Call_52_7085

	inc a
	push af
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	pop af
	ld [hl], a
	ld [wSkillTarget], a
	ld a, [wSkillId]
	cp $95
	jr z, jr_052_71d7

	cp $96
	jr z, jr_052_71d7

	cp $ad
	jr z, jr_052_71d7

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_7184

jr_052_71d7:
	ld hl, wBattlerOrder
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $02
	ld a, $01
	ld [wBattleSubStep], a
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [wSkillTarget]
	ld [hl], a
	ret


Jump_052_71f8:
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jp c, Call_52_7085

	call TargetNameToArg0
	ld a, [wSkillId]
	ld l, a
	ld h, $06
	ld de, wTextArg1
	call CopySystemText
	xor a
	ld [wTextGroup], a
	ld a, $d7
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $40
	ld [wBattleArg0], a
	ld hl, far_Call_53_5E35
	rst $10
	ret


Jump_52_7227::
	xor a
	ld [wBattleSubStep], a
	ld hl, wBattleStep
	inc [hl]
	ret


	db $21, $06, $5f, $d7, $21, $ee, $d9, $34, $c9, $21, $00, $4c, $d7, $21, $ee, $d9
	db $34, $c9

Call_52_7242::
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
	ld hl, far_DefeatBattler
	rst $10
	ld a, [$c87e]
	or a
	jr nz, jr_052_7257

	ld a, [wTextState]
	or a
	ret nz

jr_052_7257:
	ld a, [wBattleStepArg1]
	cp $01
	jr nz, jr_052_7262

	ld hl, far_Call_58_5749
	rst $10

jr_052_7262:
	xor a
	ld [$c87e], a
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
	ld a, [wSkillId]
	cp $3b
	jr z, jr_052_7274

	cp $3e
	ret nz

jr_052_7274:
	ld a, $04
	ld [wBattleSubStep], a
	ret


Jump_52_727A::
	ld a, [wBattleItemEffect]
	cp $d5
	jr nz, jr_052_7286

	ld hl, far_UseBeastTail
	rst $10
	ret


jr_052_7286:
	xor a
	ld [wBattleStepArg0], a
	xor a
	ld [wBattleStepArg1], a
	ld a, $80
	ld [wMenuChoice], a
	ld a, $10
	ld [wSkillUser], a
	ld hl, far_Call_58_6737
	rst $10
	ld a, $00
	ld [wSkillId], a
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
	ld a, [wBattleItemEffect]
	sub $af
	ld l, a
	ld h, $08
	ld de, wTextArg1
	call CopySystemText
	ld hl, wTextArg2
	ld a, [wBattleItemTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld hl, far_Call_58_57A4
	rst $10
	ld a, $18
	ld [wMonStats], a
	ld a, [wBattleArg0]
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, jr_052_72fb

	cp $c7
	jr nc, jr_052_72fb

	ld a, $01
	ld [wTextGroup], a
	ld a, [wBattleItemTarget]
	cp $04
	jr nz, jr_052_72fb

	ld a, [$dc40]
	cp $d7
	jr nz, jr_052_72fb

	ld a, $14
	ld [wBattleSubStep], a

jr_052_72fb:
	ld hl, far_StartText_4C
	rst $10
	ld hl, wBattleSubStep
	inc [hl]
	ld a, [wBattleItemTarget]
	ld [$db52], a
	ld a, $10
	ld [wSkillUser], a
	ret


jr_052_730f:
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld a, $ba
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $0c
	ld [wBattleSubStep], a
	ld a, [wBattleItemEffect]
	cp $c2
	ret c

	ld a, $01
	ld [wSkillId], a
	ret


jr_052_733a:
	ld a, [wBattleItemTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr nz, jr_052_730f

	ld hl, wBattleStepArg0
	inc [hl]
	call UseBattleItem
	ret


Jump_52_7350::
	ld a, [wMonStats]
	or a
	jr z, jr_052_735b

	dec a
	ld [wMonStats], a
	ret


jr_052_735b:
	ld a, [wBattleStepArg0]
	or a
	jr z, jr_052_7375

	cp $01
	jr z, jr_052_73b3

	cp $02
	jr z, jr_052_73bc

	cp $03
	jr z, jr_052_733a

	cp $04
	jp z, Jump_052_73f0

	jp Jump_052_73f0


jr_052_7375:
	ld a, [wBattleItemTarget]
	call CheckBattlerPresent
	jr nc, jr_052_739d

	ld a, [wBattleItemEffect]
	cp $bb
	jr z, jr_052_739d

jr_052_7384:
	ld a, $00
	ld [wTextGroup], a
	ld a, $bb
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $0c
	ld [wBattleSubStep], a
	ld a, $00
	ld [wSkillId], a
	ret


jr_052_739d:
	ld hl, wBattleStepArg0
	inc [hl]
	ld a, [wBattleItemTarget]
	ld [wSkillTarget], a
	ld a, [wBattleItemEffect]
	ld [wSkillId], a
	call Call_52_75B5
	ret c

	jr jr_052_7384

jr_052_73b3:
	ld hl, far_StartSkillVisual
	rst $10
	ld hl, wBattleStepArg0
	inc [hl]
	ret


jr_052_73bc:
	ld hl, wBattleStepArg0
	inc [hl]
	ld hl, wBattleStepArg1
	inc [hl]
	ld a, [wSkillAnimPhase]
	cp $02
	ret nz

	ld a, [wBattleItemUsedUp]
	ld b, a
	ld a, [wBattleStepArg1]
	cp b
	ret z

jr_052_73d3:
	ld a, [wSkillTarget]
	inc a
	ld [wSkillTarget], a
	and $03
	cp $03
	ret z

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_73d3

	ld hl, wBattleStepArg0
	dec [hl]
	ld hl, wBattleStepArg0
	dec [hl]
	ret


Jump_052_73f0:
	xor a
	ld [wBattleStepArg1], a
	ld a, [wSkillMsgMode]
	or a
	jr nz, jr_052_7408

	ld hl, wBattleSubStep
	inc [hl]
	ld a, $04
	ld [wBattleStepArg0], a
	ld hl, far_StartText_4C
	rst $10
	ret


jr_052_7408:
	ld hl, far_StartSkillVisual
	rst $10
	xor a
	ld [wSkillMsgMode], a
	ld a, $0a
	ld [wBattleSubStep], a
	ret


Jump_52_7416::
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_7428

	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleItemUsedUp], a
	jr Jump_52_7474

jr_052_7428:
	ld a, [wSkillTarget]
	and $03
	cp $03
	jr z, jr_052_744b

	ld a, [wBattleItemTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, jr_052_746a

	call Call_52_7242
	ld a, [wBattleItemTarget]
	ld [wJoinCandidate], a

jr_052_744b:
	ld hl, wTextArg0
	ld a, [wBattleItemTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld a, $e4
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $05
	ld [wMonStats], a

jr_052_746a:
	ld a, $0c
	ld [wBattleSubStep], a
	xor a
	ld [wBattleItemUsedUp], a
	ret


Jump_52_7474::
	ld a, [wMonStats]
	or a
	jr z, jr_052_747f

	dec a
	ld [wMonStats], a
	ret


jr_052_747f:
	ld a, [wBattleItemUsedUp]
	or a
	jr nz, jr_052_74d1

	ld hl, far_PrintPanelHPMP
	rst $10
	ld a, [wBattleItemEffect]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
	ld hl, far_GetSkillWord
	rst $10
	ld a, [wBattleArg0]
	bit 0, a
	jr z, jr_052_74d5

jr_052_74a4:
	ld a, [wBattleItemEffect]
	cp $c5
	jr nz, jr_052_74af

	call Call_52_74FB
	ret nc

jr_052_74af:
	ld a, [wBattleItemEffect]
	ld b, a
	ld a, $ff
	ld [wBattleItemTarget], a
	ld a, $ff
	ld [wBattleItemEffect], a
	ld a, [wSkillId]
	or a
	jr nz, jr_052_74c8

	ld a, b
	cp $c9
	jr nz, jr_052_74d1

jr_052_74c8:
	ld hl, far_ConsumeBattleItem
	rst $10
	ld a, [wBattleItemUsedUp]
	or a
	ret nz

jr_052_74d1:
	call Call_52_7085
	ret


jr_052_74d5:
	ld a, [wBattleItemTarget]
	and $03
	cp $03
	jr z, jr_052_74a4

	ld hl, wBattleItemTarget
	inc [hl]
	ld a, [wBattleItemTarget]
	call CheckBattlerPresent
	jr c, jr_052_74d5

	jr Jump_52_74F1

	db $c9

Jump_52_74ED::
	call Call_52_7085
	ret


Jump_52_74F1::
	ld a, $0a
	ld [wBattleSubStep], a
	ld hl, wBattleStepArg0
	dec [hl]
	ret


Call_52_74FB::
	call Random
	ld a, [wHitCount]
	or a
	jr nz, jr_052_7514

	ld a, [wBattleItemTarget]
	bit 2, a
	jr z, jr_052_7511

	ld c, $04
	jr jr_052_7515

jr_052_750f:
	scf
	ret


jr_052_7511:
	ld c, a
	jr jr_052_7515

jr_052_7514:
	ld c, a

jr_052_7515:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_052_7525

	inc c
	ld a, c
	and $03
	cp $02
	jr z, jr_052_750f

	jr jr_052_7515

jr_052_7525:
	ld a, c
	bit 2, a
	jr z, jr_052_7532

	ld a, c
	ld [wHitCount], a
	ld hl, wHitCount
	inc [hl]

jr_052_7532:
	ld a, c
	ld hl, $dd2c
	add a
	add c
	add a
	add c
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $03
	or a
	jr z, jr_052_7552

	cp $01
	jr z, jr_052_7556

	cp $02
	jr z, jr_052_755a

	ld a, $ff
	jr jr_052_755c

jr_052_7552:
	ld a, $40
	jr jr_052_755c

jr_052_7556:
	ld a, $80
	jr jr_052_755c

jr_052_755a:
	ld a, $c0

jr_052_755c:
	ld hl, wRandomHigh
	cp [hl]
	ld a, c
	ld [wSkillTarget], a
	jr nc, jr_052_758a

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, jr_052_758a

	push bc
	set 0, [hl]
	call TargetNameToArg0
	ld a, $ce
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	pop bc
	ld hl, far_UpdateStatusIcon_50
	rst $10

jr_052_758a:
	ld a, [wSkillTarget]
	cp $04
	ret


Jump_52_7590::
	call Call_52_7085
	ld a, $00
	ld [wBattleSubStep], a
	ret


Jump_52_7599::
	xor a
	ld [wBattleSubStep], a
	ld a, $01
	ld [wBattleSubStep2], a
	ret


Jump_52_75A3::
	ld hl, far_Call_53_4BEB
	rst $10
	ret


Jump_52_75A8::
	ld a, [wBattleSubStep2]
	rst $00

JumpTable_52_75AC::
	dw Jump_52_7C76
	dw Jump_52_7CA9
	dw Jump_52_7D6D
	dw Jump_52_7D22

Jump_52_75B4::
	ret


Call_52_75B5::
	cp $c2
	ret c

	cp $c7
	jr c, jr_052_75be

jr_052_75bc:
	scf
	ret


jr_052_75be:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $cc
	jr nz, jr_052_75dd

	inc hl
	inc hl
	ld a, [hli]
	and $3f
	jr nz, jr_052_75dd

	ld a, [hli]
	and $0c
	jr nz, jr_052_75dd

	ld a, [hl]
	and $c0
	jr z, jr_052_75bc

jr_052_75dd:
	ld hl, wSkillTarget
	inc [hl]
	ld a, [hl]
	call CheckBattlerPresent
	jr nc, jr_052_75be

	ld a, [hl]
	and $03
	cp $02
	jr c, jr_052_75dd

	xor a
	ret


	db $7e, $e6, $0c, $28, $14, $fe, $04, $28, $0c, $fe, $08, $28, $04, $06, $60, $18
	db $0a, $06, $a0, $18, $06, $06, $e0, $18, $02, $06, $ff, $fa, $99, $c8, $b8, $28
	db $1c, $38, $1a, $7e, $e6, $f3, $47, $7e, $e6, $0c, $3d, $c5, $f5, $c1, $cb, $69
	db $c1, $20, $04, $e6, $0c, $18, $01, $af, $b0, $77, $3e, $0f, $c9, $7e, $e6, $73
	db $77, $fa, $88, $db, $ea, $89, $db, $21, $04, $50, $d7, $3e, $db, $c9, $fa, $89
	db $db, $21, $07, $db, $cd, $6c, $2f, $7e, $e6, $c0, $28, $0f, $fa, $8a, $db, $fe
	db $80, $28, $3b, $fe, $83, $28, $37, $fe, $a5, $28, $33, $2b, $7e, $e6, $0c, $28
	db $2d, $fa, $8a, $db, $fe, $3a, $38, $26, $fe, $29, $38, $24, $fe, $44, $38, $1e
	db $fe, $5a, $38, $1c, $fe, $5b, $28, $18, $fe, $67, $38, $12, $fe, $7e, $38, $10
	db $fe, $b0, $38, $0a, $fe, $d5, $38, $08, $28, $04, $fe, $da, $38, $02, $37, $c9
	db $3e, $c1, $f5, $3e, $06, $ea, $ed, $d9, $fa, $89, $db, $21, $80, $c1, $ea, $50
	db $db, $cd, $48, $6b, $f1, $ea, $23, $c8, $3e, $00, $ea, $22, $c8, $21, $00, $4c
	db $d7, $37, $3f, $c9, $fa, $89, $db, $21, $07, $db, $cd, $6c, $2f, $7e, $e6, $c0
	db $c8, $3e, $ba, $cd, $92, $76, $37, $c9

Call_52_76C8::
	ld bc, $0300

jr_052_76cb:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_76dc

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, jr_052_7709

jr_052_76dc:
	inc c
	dec b
	jr nz, jr_052_76cb

	ld a, $0e
	ld [wBattleStep], a
	ld a, [wLinkActive]
	or a
	jr z, jr_052_76f6

	ld hl, far_Call_50_5CB4
	rst $10
	ld a, $01
	ld [wBattlerReload], a
	jr jr_052_7743

jr_052_76f6:
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
	ld hl, $00eb
	ld a, $01
	ld [wBattlerReload], a
	jr jr_052_7737

jr_052_7709:
	ld bc, $0304

jr_052_770c:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_052_7723

	ld a, [wLinkActive]
	or a
	jr z, jr_052_777b

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, jr_052_777b

jr_052_7723:
	inc c
	dec b
	jr nz, jr_052_770c

	ld a, $00
	ld [wBattlerReload], a
	ld a, $00
	ld [wBattleArg2], a
	ld hl, far_Call_50_5C78
	rst $10
	jr jr_052_7743

jr_052_7737:
	ld a, h
	ld [wTextGroup], a
	ld a, l
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10

jr_052_7743:
	ld c, $69
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wBattlerReload]
	jr z, jr_052_7754

	xor $01
	ld [wBattlerReload], a

jr_052_7754:
	or a
	jr z, jr_052_775e

	ld a, $ff
	ld [wBattleType], a
	ld c, $4f

jr_052_775e:
	push bc
	ld a, $02
	call QueueMusic
	pop bc
	ld a, c
	call QueueSound
	ld a, $00
	ld [wBattleArg2], a
	ld a, $0a
	ld [wBattleStep], a
	scf
	ld a, [wBattlerReload]
	ld [wSkillMsgMode], a
	ret


jr_052_777b:
	ld a, $ff
	ld [wSkillMsgMode], a
	xor a
	ret


Call_52_7782::
	ld bc, $0300
	call Call_52_77A8
	jr nc, jr_052_7795

	inc c
	call Call_52_77A8
	jr nc, jr_052_7795

	inc c
	call Call_52_77A8
	ret c

jr_052_7795:
	ld bc, $0304
	call Call_52_77A8
	jr nc, jr_052_77a7

	inc c
	call Call_52_77A8
	jr nc, jr_052_77a7

	inc c
	call Call_52_77A8

jr_052_77a7:
	ret


Call_52_77A8::
	ld a, [wLinkActive]
	or a
	jr nz, jr_052_77b7

	ld a, c
	cp $04
	jr c, jr_052_77b7

	call CheckBattlerPresent
	ret


jr_052_77b7:
	ld a, c
	call CheckBattlerPresent
	ret c

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	ret z

	scf
	ret


Jump_52_77C8::
	call Call_52_7997
	ret c

	ld a, [wSkillUser]
	call CheckBattlerPresent
	jp c, Jump_52_797C

	ld hl, far_StartSkillVisual
	rst $10
	ld hl, far_Call_55_4043
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_77E2::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [$db5b], a
	ld a, b
	or c
	jr nz, jr_052_780f

	inc bc
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [$db5b], a

jr_052_780f:
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	ld d, h
	ld e, l
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	ld h, d
	ld l, e
	jr c, jr_052_782e

	jr z, jr_052_782e

	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
	jr Call_52_7840

jr_052_782e:
	xor a
	ld [hld], a
	ld [hl], a
	ld a, $ff
	ld [wBattleStepArg0], a
	ld a, $ff
	ld [wBattleStepArg1], a
	ld a, $02
	ld [wBattleSubStep2], a

Call_52_7840::
	ld hl, wTextArg1
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [$db5b]
	ld b, a
	call Number16ToDecimal
	ld a, $82
	ld [wBattlerReload], a
	call Call_52_7FCB
	cp $04
	jr c, jr_052_785e

	ld hl, wBattlerReload
	inc [hl]

jr_052_785e:
	call Call_52_7868
	call z, Call_52_7875
	call Call_52_78F4
	ret


Call_52_7868::
	ld a, [wSkillUser]
	and $04
	ld b, a
	ld a, [wSkillTarget]
	and $04
	cp b
	ret


Call_52_7875::
	ld a, [wBattlerReload]
	xor $01
	ld [wBattlerReload], a
	ret


Call_52_787E::
	ld a, [wBattlerReload]
	cp $85
	ret z

	cp $e7
	jr z, jr_052_788c

	ld a, $e7
	jr jr_052_788e

jr_052_788c:
	ld a, $ea

jr_052_788e:
	ld [wBattlerReload], a
	ret


Jump_52_7892::
	call Call_52_7997
	ret c

	ld hl, far_StartSkillVisual
	rst $10
	ld hl, far_Call_55_4043
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_78A3::
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	ld a, b
	or c
	jr z, jr_052_78c0

	ld a, $03
	ld [wBattleSubStep2], a
	ld a, $00
	ld [hld], a
	ld [hl], $01
	jr jr_052_78e5

jr_052_78c0:
	xor a
	ld [hld], a
	ld [hl], a
	ld a, $ff
	ld [wBattleStepArg0], a
	ld a, $03
	ld [wBattleStepArg1], a
	ld a, $02
	ld [wBattleSubStep2], a
	ld a, $ea
	ld [wBattlerReload], a
	call Call_52_7FCB
	cp $04
	jr nc, jr_052_78ea

	ld a, $e7
	ld [wBattlerReload], a
	jr jr_052_78ea

jr_052_78e5:
	ld a, $85
	ld [wBattlerReload], a

jr_052_78ea:
	call Call_52_7868
	call z, Call_52_787E
	call Call_52_78F4
	ret


Call_52_78F4::
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattlerReload]
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld hl, far_PrintPanelHPMP
	rst $10
	ret


Jump_52_7920::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wBattleStepArg0]
	cp $ff
	jr z, jr_052_792e

	ld [wBattleSubStep], a

jr_052_792e:
	ld a, [wBattleStepArg1]
	cp $ff
	jr z, jr_052_7938

	ld [wBattleSubStep2], a

jr_052_7938:
	xor a
	ld [wBattleStepArg0], a
	ld [wBattleStepArg1], a
	call Call_52_7A18
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld a, $00
	ld [wTextGroup], a
	call Call_52_7FCB
	cp $04
	jr nc, jr_052_7966

	ld a, $e7
	jr jr_052_7968

jr_052_7966:
	ld a, $ea

jr_052_7968:
	ld [wBattlerReload], a
	call Call_52_7868
	call z, Call_52_787E
	ld a, [wBattlerReload]
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_52_797C::
	call Call_52_6ECF
	jp nz, Call_52_7BEC

Jump_052_7982:
	ld hl, wBattleSubStep
	inc [hl]
	ld a, $00
	ld [wBattleSubStep2], a
	jp Jump_52_6F56


Jump_52_798E::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, far_StartText_4C
	rst $10
	ret


Call_52_7997::
	ld a, [wSkillUser]
	call CheckBattlerPresent
	ret nc

	ld hl, wBattleSubStep
	inc [hl]
	scf
	ret


Jump_52_79A4::
	call Call_52_7997
	ret c

	ld hl, far_StartSkillVisual
	rst $10
	ld hl, far_Call_55_4043
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_79B5::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	call Percent80
	inc hl
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [$db5b], a
	pop bc
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	jr c, jr_052_79e5

	or c
	jr z, jr_052_79e5

	jr jr_052_79e8

jr_052_79e5:
	ld bc, $0000

jr_052_79e8:
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	or c
	jr nz, jr_052_7a02

	ld hl, wBattleSubStep2
	dec [hl]
	ld a, $04
	ld [wBattleStepArg0], a
	ld a, $ff
	ld [wBattleStepArg1], a
	ld a, $02
	ld [wBattleSubStep2], a

jr_052_7a02:
	call Call_52_7840
	ret


	db $fa, $69, $dd, $fe, $01, $20, $06, $3e, $01, $ea, $ed, $d9, $c9, $21, $ee, $d9
	db $34, $c9

Call_52_7A18::
	ld a, [wSkillUser]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $01
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	call Call_52_7242
	pop af
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	cp $04
	jr c, jr_052_7a48

	cp $07
	jr z, jr_052_7a48

	ld a, [wSkillUser]
	ld [wJoinCandidate], a

jr_052_7a48:
	ret


Jump_52_7A49::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_052_7a5a

	ld hl, wBattleSubStep2
	inc [hl]

jr_052_7a5a:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_7A5F::
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	call TransformIntoTarget
	ret


Jump_52_7A69::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr z, jr_052_7a7b

	jr nc, jr_052_7a7b

	call SkillVivify
	ret


jr_052_7a7b:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_7A80::
	ld hl, wBattleSubStep2
	inc [hl]
	call TargetNameToArg0
	ld a, $9e
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_52_7A95::
	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld hl, wSkillTarget
	inc [hl]
	ld a, [hl]
	ld b, a
	and $03
	cp $03
	jr z, jr_052_7ab0

	ld a, b
	call CheckBattlerPresent
	jr z, Jump_52_7A95

	xor a
	ld [wBattleSubStep2], a
	ret


jr_052_7ab0:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Call_52_7AB5::
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	call IndexWords
	push hl
	ld a, [wRandomHigh]
	and $03
	ld hl, $7aff
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
	ld [hli], a
	ld c, a
	push hl
	ld a, [wSkillUser]
	and $04
	xor $04
	ld b, a
	ld a, c
	cp $3a
	jr nz, jr_052_7af6

	ld a, [wRandomHigh]
	and $03
	add b

jr_052_7ae5:
	ld b, a
	call CheckBattlerPresent
	jr nc, jr_052_7af6

	ld a, b
	and $03
	jr nz, jr_052_7af3

	ld b, a
	or $03

jr_052_7af3:
	dec a
	jr jr_052_7ae5

jr_052_7af6:
	pop hl
	ld a, b
	ld [hl], a
	ld a, $00
	ld [wBattleSubStep], a
	ret


	db $3a, $5e, $62, $80, $ff, $f5, $c5, $d5, $e5, $fa, $88, $db, $21, $05, $db, $cd
	db $6c, $2f, $7e, $e6, $c0, $77, $e1, $d1, $c1, $f1, $c9

Call_52_7B1A::
	ld a, [wSkillId]
	cp $32
	jr z, jr_052_7b24

	cp $66
	ret nz

jr_052_7b24:
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	call IndexWords
	xor a
	ld [hli], a
	ld [hl], a
	ret


Jump_52_7B31::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_7b70

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, l
	ld [wSkillStatusPtr], a
	ld a, h
	ld [$db62], a
	ld a, [hl]
	and $03
	jr nz, jr_052_7b70

	call TryEffectRes18
	jr nc, jr_052_7b70

	ld a, [wSkillStatusPtr]
	ld l, a
	ld a, [$db62]
	ld h, a
	set 0, [hl]
	ld a, $ce
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartSkillVisual
	rst $10
	ret


jr_052_7b70:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_7B75::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_7bb2

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 7, [hl]
	jr nz, jr_052_7bb2

	call RollSleep
	jr nc, jr_052_7bb2

	call PutTargetToSleep
	ld c, $cc
	call Call_52_7FCB
	cp $04
	jr nc, jr_052_7ba0

	inc c

jr_052_7ba0:
	ld a, c
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld a, $04
	ld [wBattleSubStep], a
	ld hl, far_StartSkillVisual
	rst $10
	ret


jr_052_7bb2:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Jump_52_7BB7::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_7be7

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr nz, jr_052_7be7

	push hl
	call TryEffectRes19
	pop hl
	jr nc, jr_052_7be7

	set 6, [hl]
	ld a, $cf
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartSkillVisual
	rst $10
	ret


jr_052_7be7:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Call_52_7BEC::
	ld a, [$dd6e]
	or a
	jp nz, Jump_052_6e89

	ld a, $13
	ld [wBattleSubStep], a
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillTarget]
	ld b, a
	call CheckBattlerCanAct
	jp c, Jump_052_7982

	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	call BattleRandom
	ld b, $00
	ld a, [wSkillTarget]
	ld hl, $db42
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr z, jr_052_7c32

	ld hl, wRandomHigh
	res 0, [hl]
	ld b, $01

jr_052_7c32:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call ShiftHL1
	ld a, h
	or l
	or a
	jr nz, jr_052_7c47

	ld a, $01
	ld [wRandomHigh], a

jr_052_7c47:
	ld a, [wRandomHigh]
	and $01
	add $d5
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	bit 0, b
	call nz, Call_52_7C92
	ld hl, far_StartText_4C
	rst $10
	ld a, [wRandomHigh]
	and $01
	ld [wBattleSubStep2], a
	ld a, [wRandomHigh]
	and $01
	ret z

	ld a, [wBattleSubStep2]
	add $01
	ld [wBattleSubStep2], a
	ret


Jump_52_7C76::
	ld hl, wBattleSubStep2
	inc [hl]
	call Call_52_7C98
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

	ld hl, far_StartSkillHitEffect
	rst $10
	ld hl, far_Call_55_401F
	rst $10
	ld a, $80
	ld [wItemMsgGroup], a
	ret


Call_52_7C92::
	ld a, $6a
	ld [wTextIndex], a
	ret


Call_52_7C98::
	ld a, [wSkillUser]
	ld l, a
	ld a, [wSkillTarget]
	ld h, a
	ld a, l
	ld [wSkillTarget], a
	ld a, h
	ld [wSkillUser], a
	ret


Jump_52_7CA9::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, Call_52_7C98

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call ShiftHL1
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, h
	or l
	jr z, jr_052_7d1e

	call PrepareDamageText
	ld c, $82
	call Call_52_7FCB
	bit 2, a
	jr nz, jr_052_7cda

	ld c, $83

jr_052_7cda:
	ld a, c
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $01
	ld [wBattleAnimDone], a
	ld a, $00
	ld [wScreenEffect], a
	call Call_52_7C98
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld [hl], d
	push af
	dec hl
	pop bc
	ld [hl], e
	ld a, d
	or e
	jr z, jr_052_7d16

	push bc
	pop af
	ret nc

jr_052_7d16:
	xor a
	ld [hli], a
	ld [hl], a
	ld hl, wBattleSubStep2
	inc [hl]
	ret


jr_052_7d1e:
	call ShowMissMessage
	ret


Jump_52_7D22::
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerNameTo
	ld a, $00
	ld [wTextGroup], a
	ld b, $e3
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	add b
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ld hl, wBattleSubStep2
	dec [hl]
	ld a, [wSkillUser]
	ld [wBattleArg0], a
	ld hl, far_DefeatBattler
	rst $10
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	ld hl, far_Call_58_5749
	rst $10
	pop af
	ld [wSkillTarget], a
	ret


Jump_52_7D6D::
	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


Call_52_7D77::
	ld hl, far_Call_57_7C44
	rst $10
	ret


Call_52_7D7C::
	ld a, [$dd6d]
	cp $02
	jr nz, jr_052_7dc8

	ld a, [wSkillTarget]
	rrca
	rrca
	and $01
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 5, [hl]
	jr z, jr_052_7dc8

	ld a, [wSkillTarget]
	ld e, a
	and $04
	ld c, a
	cp $04
	jr c, jr_052_7da7

	ld a, [wEnemyCount]
	jr jr_052_7daa

jr_052_7da7:
	ld a, [wPartyBattlers]

jr_052_7daa:
	ld b, a

jr_052_7dab:
	ld a, c
	cp e
	jr z, jr_052_7db1

	jr nc, jr_052_7db7

jr_052_7db1:
	inc c
	dec b
	jr nz, jr_052_7dab

	jr jr_052_7dc8

jr_052_7db7:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_052_7dc3

	inc c
	dec b
	jr nz, jr_052_7db7

	jr jr_052_7dc8

jr_052_7dc3:
	xor a
	ld [$dd6d], a
	ret


jr_052_7dc8:
	ld hl, far_PrintBattleMessage
	rst $10
	ret


Call_52_7DCD::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ret


Call_52_7DD7::
	ld a, [wSkillId]
	cp $7f
	jr nz, jr_052_7de0

jr_052_7dde:
	xor a
	ret


jr_052_7de0:
	ld a, [$dd6e]
	or a
	jr nz, jr_052_7dde

	ld a, [$dd6c]
	or a
	jr z, jr_052_7df9

	cp $08
	jr z, jr_052_7dde

	cp $20
	jr nz, jr_052_7dde

	call Call_52_7EF1
	jr jr_052_7dde

jr_052_7df9:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	cp $0c
	ret z

	ld a, [wSkillTargeting]
	bit 4, a
	jr z, jr_052_7dde

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 3, [hl]
	jr z, jr_052_7dde

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, jr_052_7dde

	ld a, [wSkillFlags3]
	bit 2, a
	jr z, jr_052_7e44

	ld a, $d3
	call Call_52_7E74
	ld a, $08
	ld [$dd6c], a
	ld a, $08
	ld [wBattleArg0], a
	ld hl, far_Call_53_5E35
	rst $10
	xor a
	ld [$c1c9], a
	scf
	ret


jr_052_7e44:
	ld a, $d4
	call Call_52_7E74
	xor a
	ret


	db $fa, $89, $db, $21, $03, $db, $cd, $6c, $2f, $fa, $fd, $dc, $cb, $77, $20, $09
	db $cb, $6f, $20, $0f, $cb, $67, $20, $0e, $c9, $cb, $46, $20, $dc, $fa, $00, $db
	db $cb, $5f, $c9, $cb, $76, $c9, $cb, $7e, $c9

Call_52_7E74::
	push af
	call TargetNameToArg0
	pop af
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


Call_52_7E85::
	ld a, [$dd6e]
	or a
	ret z

	cp $01
	jr z, jr_052_7e96

	ld a, [$dd6d]
	cp $02
	jr z, Call_52_7EA7

	ret


jr_052_7e96:
	call Call_52_7EA7
	ld hl, wBattlerStatus6
	call AddEightTimes
	res 4, [hl]
	inc hl
	ld a, [hl]
	and $0f
	ld [hl], a
	ret


Call_52_7EA7::
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
	ret


Jump_52_7EB5::
	ld a, $bb
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ld a, $01
	ld [wSkillId], a
	ld a, $ff
	ld [wBattleItemTarget], a
	ld a, $ff
	ld [wBattleItemEffect], a
	ld hl, far_ConsumeBattleItem
	rst $10
	call Call_52_7085
	ret


Jump_52_7ED9::
	ld hl, far_Call_57_6E0E
	rst $10
	ret


Jump_52_7EDE::
	ld hl, far_Call_58_5C48
	rst $10
	ret


Jump_52_7EE3::
	ld hl, far_BattlerFallSequence
	rst $10
	ret


Jump_52_7EE8::
	ld a, [wTextState]
	or a
	ret nz

	call Call_52_710E
	ret


Call_52_7EF1::
	ld a, [$dd6c]
	or a
	jp z, Jump_052_7fc9

	ld hl, wPartyBarTiles
	ld a, [hli]
	ld [wSkillUser], a
	ld a, [hli]
	ld [wSkillTarget], a
	ld a, [hli]
	ld [wHitCount], a
	ld a, [wSkillUser]
	ld de, wBattlerAction
	add a
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
	ld a, [wSkillTarget]
	ld de, wBattlerAction
	add a
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
	ld a, [wSkillTarget]
	ld de, wBattlerOrder
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [hl]
	ld [de], a
	ld a, [$dd6c]
	cp $40
	jp z, Jump_052_7fc9

	cp $01
	jr z, jr_052_7f9e

	cp $02
	jr z, jr_052_7f55

	cp $04
	call z, Call_52_7FB2

jr_052_7f4e:
	ld a, $00
	ld [$dd6c], a
	xor a
	ret


jr_052_7f55:
	ld a, [wSkillTarget]
	rrca
	rrca
	and $01
	ld hl, wSuckAllUsers
	add l
	ld l, a
	ld a, [hl]
	rrca
	rrca
	and $03
	ld l, a
	ld a, [wSkillTarget]
	and $04
	or l
	ld [wBattleArg0], a
	call CheckBattlerCanAct
	jr c, jr_052_7f83

	ld a, [wBattleArg0]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, jr_052_7f4e

jr_052_7f83:
	ld a, [wSkillTarget]
	or $03
	ld [wSkillTarget], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or $03
	ld [hl], a
	jr jr_052_7fc9

jr_052_7f9e:
	ld a, $d9
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	xor a
	ld [$dd6d], a
	jr jr_052_7f4e

Call_52_7FB2::
	ld a, [$dd6d]
	cp $07
	ret nz

	ld a, $de
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld [$dd6d], a
	ld hl, far_StartText_4C
	rst $10
	ret


Jump_052_7fc9:
jr_052_7fc9:
	scf
	ret


Call_52_7FCB::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

	ld a, [wSkillUser]
	ret


Call_52_7FD8::
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

jr_052_7fe2:
	ld a, c
	call CheckBattlerPresent
	ret nc

	inc c
	dec b
	jr nz, jr_052_7fe2

	scf
	ret


	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00
