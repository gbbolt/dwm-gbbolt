INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $052", ROMX[$4000], BANK[$52]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_52::
	db $52

;@ path: battle/skills/effects
;@ Entry points of bank $52, the skill effects. Entries 0-7 are far-call entries used by
;@ other banks (RunActionStep runs one step of a battler's action, CalcAttackDamage works out
;@ a normal attack, ...). Entries 8-229 are the effect routines of the 222 skills, in skill
;@ order: the effect of skill n is entry 8 + n. They are not reached with far-call numbers:
;@ the skill step of the action (ActionStepSkill, in this bank) indexes the table directly,
;@ `call JumpToPointer` on mem16[$4011 + 2 * wSkillId] ($4011 = entry 8). Every effect
;@ routine sets wSkillResult and its two messages (SkillFails, SkillWorks and the like)
;@ for the message and animation steps that follow; the skills from $B0 on are the
;@ battle items, which have their own routines (UseBattleItem) and get SkillAttack here.
FarTable_52::
	dw RunActionStep  ; entry 0
	dw CheckBattleOver  ; entry 1
	dw UserFalls  ; entry 2
	dw SkillDamageByKind  ; entry 3
	dw GetBaseAgilityTemp  ; entry 4
	dw CalcAttackDamage  ; entry 5
	dw GetResistByte  ; entry 6
	dw RestoreInterruptedAction  ; entry 7
	dw SkillBlaze  ; skill $00 Blaze
	dw SkillBlaze  ; skill $01 Blazemore
	dw SkillBlaze  ; skill $02 Blazemost
	dw SkillFirebal  ; skill $03 Firebal
	dw SkillFirebal  ; skill $04 Firebane
	dw SkillFirebal  ; skill $05 Firebolt
	dw SkillBang  ; skill $06 Bang
	dw SkillBang  ; skill $07 Boom
	dw SkillBang  ; skill $08 Explodet
	dw SkillInfernos  ; skill $09 Infernos
	dw SkillInfernos  ; skill $0A Infermore
	dw SkillInfernos  ; skill $0B Infermost
	dw SkillIceBolt  ; skill $0C IceBolt
	dw SkillIceBolt  ; skill $0D SnowStorm
	dw SkillIceBolt  ; skill $0E Blizzard
	dw SkillBolt  ; skill $0F Bolt
	dw SkillBolt  ; skill $10 Zap
	dw SkillBolt  ; skill $11 Thordain
	dw SkillBeat  ; skill $12 Beat
	dw SkillBeat  ; skill $13 Defeat
	dw SkillSacrifice  ; skill $14 Sacrifice
	dw SkillSleep  ; skill $15 Sleep
	dw SkillSleep  ; skill $16 SleepAll
	dw SkillStopSpell  ; skill $17 StopSpell
	dw SkillSurround  ; skill $18 Surround
	dw SkillPanicAll  ; skill $19 PanicAll
	dw SkillRobMagic  ; skill $1A RobMagic
	dw SkillTakeMagic  ; skill $1B TakeMagic
	dw SkillSap  ; skill $1C Sap
	dw SkillSap  ; skill $1D Defence
	dw SkillUpper  ; skill $1E Upper
	dw SkillUpper  ; skill $1F Increase
	dw SkillSlow  ; skill $20 Slow
	dw SkillSlow  ; skill $21 SlowAll
	dw SkillSpeed  ; skill $22 Speed
	dw SkillSpeed  ; skill $23 SpeedUp
	dw SkillBarrier  ; skill $24 Barrier
	dw SkillTwinHits  ; skill $25 TwinHits
	dw SkillMagicWall  ; skill $26 MagicWall
	dw SkillMagicBack  ; skill $27 MagicBack
	dw SkillMagicBack  ; skill $28 Bounce
	dw SkillTransform  ; skill $29 Transform
	dw SkillIronize  ; skill $2A Ironize
	dw SkillHeal  ; skill $2B Heal
	dw SkillHeal  ; skill $2C HealMore
	dw SkillHeal  ; skill $2D HealAll
	dw SkillHeal  ; skill $2E HealUs
	dw SkillHeal  ; skill $2F HealUsAll
	dw SkillVivify  ; skill $30 Vivify
	dw SkillVivify  ; skill $31 Revive
	dw SkillFarewell  ; skill $32 Farewell
	dw SkillAntidote  ; skill $33 Antidote
	dw SkillNumbOff  ; skill $34 NumbOff
	dw SkillDeChaos  ; skill $35 DeChaos
	dw SkillCurseOff  ; skill $36 CurseOff
	dw SkillAttack  ; skill $37 StepGuard
	dw SkillAttack  ; skill $38 MapMagic
	dw SkillChance  ; skill $39 Chance
	dw SkillAttack  ; skill $3A Attack
	dw SkillTwinSlash  ; skill $3B TwinSlash
	dw SkillRamming  ; skill $3C Ramming
	dw SkillBeserker  ; skill $3D Beserker
	dw SkillKamikaze  ; skill $3E Kamikaze
	dw SkillMassacre  ; skill $3F Massacre
	dw SkillMassacre  ; skill $40 EvilSlash
	dw SkillChargeUp  ; skill $41 ChargeUP
	dw SkillHighJump  ; skill $42 HighJump
	dw SkillSuckAir  ; skill $43 SuckAir
	dw SkillFireSlash  ; skill $44 FireSlash
	dw SkillBoltSlash  ; skill $45 BoltSlash
	dw SkillVacuSlash  ; skill $46 VacuSlash
	dw SkillIceSlash  ; skill $47 IceSlash
	dw SkillMetalCut  ; skill $48 MetalCut
	dw SkillDrakSlash  ; skill $49 DrakSlash
	dw SkillBeastCut  ; skill $4A BeastCut
	dw SkillBirdBlow  ; skill $4B BirdBlow
	dw SkillDevilCut  ; skill $4C DevilCut
	dw SkillZombieCut  ; skill $4D ZombieCut
	dw SkillCleanCut  ; skill $4E CleanCut
	dw SkillMultiCut  ; skill $4F MultiCut
	dw SkillBiAttack  ; skill $50 BiAttack
	dw SkillBiAttack  ; skill $51 QuadHits
	dw SkillCallHelp  ; skill $52 CallHelp
	dw SkillCallHelp  ; skill $53 YellHelp
	dw SkillFocus  ; skill $54 Focus
	dw SkillSquallHit  ; skill $55 SquallHit
	dw SkillTwinSlash  ; skill $56 PsycheUp
	dw SkillRainSlash  ; skill $57 RainSlash
	dw SkillWindBeast  ; skill $58 WindBeast
	dw SkillWindBeast  ; skill $59 Vacuum
	dw SkillBolt  ; skill $5A Lightning
	dw SkillRockThrow  ; skill $5B RockThrow
	dw SkillFireAir  ; skill $5C FireAir
	dw SkillFireAir  ; skill $5D BlazeAir
	dw SkillFireAir  ; skill $5E Scorching
	dw SkillFireAir  ; skill $5F WhiteFire
	dw SkillFrigidAir  ; skill $60 FrigidAir
	dw SkillFrigidAir  ; skill $61 IceAir
	dw SkillFrigidAir  ; skill $62 IceStorm
	dw SkillFrigidAir  ; skill $63 WhiteAir
	dw SkillBolt  ; skill $64 Hellblast
	dw SkillBigBang  ; skill $65 BigBang
	dw SkillMegaMagic  ; skill $66 MegaMagic
	dw SkillAttack  ; skill $67 PoisonHit
	dw SkillAttack  ; skill $68 NapAttack
	dw SkillAttack  ; skill $69 Paralyze
	dw SkillSleep  ; skill $6A SleepAir
	dw SkillPalsyAir  ; skill $6B PalsyAir
	dw SkillPoisonGas  ; skill $6C PoisonGas
	dw SkillPoisonGas  ; skill $6D PoisonAir
	dw SkillPanicAll  ; skill $6E PaniDance
	dw SkillCurse  ; skill $6F Curse
	dw SkillAhhh  ; skill $70 Ahhh
	dw SkillBeat  ; skill $71 K.O.Dance
	dw SkillSandStorm  ; skill $72 SandStorm
	dw SkillSandStorm  ; skill $73 Radiant
	dw SkillEerieLite  ; skill $74 EerieLite
	dw SkillOddDance  ; skill $75 OddDance
	dw SkillRobMagic  ; skill $76 RobDance
	dw SkillSideStep  ; skill $77 SideStep
	dw SkillLureDance  ; skill $78 LureDance
	dw SkillLushLicks  ; skill $79 LushLicks
	dw SkillLushLicks  ; skill $7A SickLick
	dw SkillLegSweep  ; skill $7B LegSweep
	dw SkillLegSweep  ; skill $7C BigTrip
	dw SkillWarCry  ; skill $7D WarCry
	dw SkillAttack  ; skill $7E Whistle
	dw SkillImitate  ; skill $7F Imitate
	dw SkillDeMagic  ; skill $80 DeMagic
	dw SkillSurge  ; skill $81 Surge
	dw SkillUltraDown  ; skill $82 UltraDown
	dw SkillDeMagic  ; skill $83 ThickFog
	dw SkillTatsuCall  ; skill $84 TatsuCall
	dw SkillTatsuCall  ; skill $85 DiagoCall
	dw SkillTatsuCall  ; skill $86 SamsiCall
	dw SkillTatsuCall  ; skill $87 BazooCall
	dw SkillCover  ; skill $88 Cover
	dw SkillCover  ; skill $89 Guardian
	dw SkillTailWind  ; skill $8A TailWind
	dw SkillTailWind  ; skill $8B StormWind
	dw SkillDodge  ; skill $8C Dodge
	dw SkillDefence  ; skill $8D Defence
	dw SkillDefence  ; skill $8E StrongD
	dw SkillSuckAll  ; skill $8F SuckAll
	dw SkillDefence  ; skill $90 BladeD
	dw SkillDanceShut  ; skill $91 DanceShut
	dw SkillMouthShut  ; skill $92 MouthShut
	dw SkillMeditate  ; skill $93 Meditate
	dw SkillHeal  ; skill $94 Hustle
	dw SkillLifeSong  ; skill $95 LifeSong
	dw SkillLifeDance  ; skill $96 LifeDance
	dw SkillAttack  ; skill $97 Run
	dw SkillDaze  ; skill $98 Daze
	dw SkillHitAlly  ; skill $99 HitAlly
	dw SkillHitEnemy  ; skill $9A HitEnemy
	dw SkillHitSelf  ; skill $9B HitRandom
	dw SkillNoEffect  ; skill $9C Scared
	dw SkillNoEffect  ; skill $9D Dance
	dw SkillTrip  ; skill $9E Trip
	dw SkillCantMove  ; skill $9F Paralyze
	dw SkillCantMove  ; skill $A0 CANTMOVE
	dw SkillRunAway  ; skill $A1 RUN
	dw SkillCallHorror  ; skill $A2 CALLHOROR
	dw SkillHealUsAllSpecial  ; skill $A3 HealUsAll
	dw SkillCallHorror  ; skill $A4 Smashed
	dw SkillDeMagic  ; skill $A5 FILTHZONE
	dw SkillAllChange  ; skill $A6 ALLCHANGE
	dw SkillBigSleep  ; skill $A7 BIGSLEEP
	dw SkillMP0  ; skill $A8 MP0
	dw SkillNoEffect  ; skill $A9 ECHO
	dw SkillChgDragon  ; skill $AA CHGDRAGON
	dw SkillCallEvil  ; skill $AB CALLEVIL
	dw SkillFreezy  ; skill $AC FREEZY
	dw SkillVivify  ; skill $AD ALLREVIVE
	dw SkillRestoreMP  ; skill $AE RESTOREMP
	dw SkillMeteor  ; skill $AF METEOR
	dw SkillAttack  ; skill $B0 HERB
	dw SkillAttack  ; skill $B1 HEALWATER
	dw SkillAttack  ; skill $B2 SAGESTONE
	dw SkillAttack  ; skill $B3 WARLDDEW
	dw SkillAttack  ; skill $B4 POTION
	dw SkillAttack  ; skill $B5 ELFWATER
	dw SkillAttack  ; skill $B6 ANTIDOTE
	dw SkillAttack  ; skill $B7 MOONHERB
	dw SkillAttack  ; skill $B8 SKYBELL
	dw SkillAttack  ; skill $B9 LAUREL
	dw SkillAttack  ; skill $BA AWAKESAND
	dw SkillAttack  ; skill $BB WARLDLEAF
	dw SkillAttack  ; skill $BC LIFEACORN
	dw SkillAttack  ; skill $BD MYSTICNUT
	dw SkillAttack  ; skill $BE PWRSEED
	dw SkillAttack  ; skill $BF DEFSEED
	dw SkillAttack  ; skill $C0 AGILSEED
	dw SkillAttack  ; skill $C1 INTSEED
	dw SkillAttack  ; skill $C2 FEEDMEAT
	dw SkillAttack  ; skill $C3 BEFFJERKY
	dw SkillAttack  ; skill $C4 PORKCHOP
	dw SkillAttack  ; skill $C5 BADMEAT
	dw SkillAttack  ; skill $C6 SIRLOIN
	dw SkillAttack  ; skill $C7 BOLTSTAFF
	dw SkillAttack  ; skill $C8 STAFF
	dw SkillAttack  ; skill $C9 BLOKSTAFF
	dw SkillAttack  ; skill $CA LAVASTAFF
	dw SkillAttack  ; skill $CB SNOWSTAFF
	dw SkillAttack  ; skill $CC FIRESTAFF
	dw SkillAttack  ; skill $CD WARPWING
	dw SkillAttack  ; skill $CE TINYMEDAL
	dw SkillAttack  ; skill $CF QuestBk
	dw SkillAttack  ; skill $D0 HORRORBK
	dw SkillAttack  ; skill $D1 BENICEBK
	dw SkillAttack  ; skill $D2 CHEATERBK
	dw SkillAttack  ; skill $D3 SMARTBK
	dw SkillAttack  ; skill $D4 COMEDYBK
	dw SkillChgDragon  ; skill $D5 BeDragon
	dw SkillSmashlime  ; skill $D6 Smashlime
	dw SkillSheldodge  ; skill $D7 Sheldodge
	dw SkillBranching  ; skill $D8 Branching
	dw SkillGigaSlash  ; skill $D9 GigaSlash
	dw SkillPanicAll  ; skill $DA LIFE
	dw SkillRunAway  ; skill $DB RUN
	dw SkillIronizeSelf  ; skill $DC IRONIZE
	dw SkillHalfAttack  ; skill $DD Ahhh

;@ def SkillBlaze()
;@ path: battle/skills/effects/spells
;@ Effect of Blaze, Blazemore and Blazemost (skills $00-$02): fire damage taken from the
;@ skill table and cut by the target's resistance, shown as "takes N damage".
SkillBlaze::
;> BlazeDamage()
	call BlazeDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillFirebal()
;@ path: battle/skills/effects/spells
;@ Effect of Firebal, Firebane and Firebolt (skills $03-$05): damage from the skill table,
;@ cut by the target's resistance.
SkillFirebal::
;> FirebalDamage()
	call FirebalDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillBang()
;@ path: battle/skills/effects/spells
;@ Effect of Bang, Boom and Explodet (skills $06-$08): explosion damage from the skill table,
;@ cut by the target's resistance.
SkillBang::
;> BangDamage()
	call BangDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillInfernos()
;@ path: battle/skills/effects/spells
;@ Effect of Infernos, Infermore and Infermost (skills $09-$0B): wind damage from the skill
;@ table, cut by the target's resistance.
SkillInfernos::
;> InfernosDamage()
	call InfernosDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillIceBolt()
;@ path: battle/skills/effects/spells
;@ Effect of IceBolt, SnowStorm and Blizzard (skills $0C-$0E): ice damage from the skill
;@ table, cut by the target's resistance.
SkillIceBolt::
;> IceBoltDamage()
	call IceBoltDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillBolt()
;@ path: battle/skills/effects/spells
;@ Effect of the lightning skills Bolt, Zap, Thordain, Lightning and Hellblast (skills
;@ $0F-$11, $5A, $64): damage from the skill table, cut by the target's resistance.
SkillBolt::
;> BoltDamage()
	call BoltDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillBeat()
;@ path: battle/skills/effects/status
;@ Effect of Beat, Defeat and K.O.Dance (skills $12, $13, $71): if the instant-death roll
;@ against the target's resistance works, the target is knocked out (state 1, HP 0) with
;@ "X is finished!"; otherwise "Has no effect on X!".
SkillBeat::
;> wBattleStepArg1 = 0
	xor a
	ld [wBattleStepArg1], a
;>@miss if not RollInstantDeath():
	call RollInstantDeath
	jr nc, .resisted

;>@miss1     return SkillFails(0xB8)          # "Has no effect on X!"
;>@st wBattlerState[wSkillTarget] = 1         # knocked out
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@st
	ld h, a
	ld [hl], $01
;> SkillWorksSide(0xB8E8)                     # "X is finished!" / "Has no effect on X!"
	ld hl, $b8e8
	call SkillWorksSide
;>@hp0 mem16[wBattlerHP + 2 * wSkillTarget] = 0
	push hl
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, $00
	ld [hli], a
;=@hp0
	ld [hl], $00
	pop hl
;> return
	ret


.resisted
;=@miss1
	ld a, $b8
	call SkillFails
	ret


;@ def SkillSacrifice()
;@ path: battle/skills/effects/special
;@ Effect of Sacrifice (skill $14): goes on with battle sub-step 3 (the user gives its life
;@ to defeat the enemies) from its first stage.
SkillSacrifice::
;> wBattleSubStep = 3
	ld a, $03
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> return
	ret


;@ def SkillSleep()
;@ path: battle/skills/effects/status
;@ Effect of Sleep, SleepAll and SleepAir (skills $15, $16, $6A): the target's name goes
;@ into the message; a target already asleep gives "X is already sleeping!", a resisted roll
;@ "X doesn't fall asleep!"; otherwise "X is sent to sleep!" and the sleep bits
;@ ($8C of status byte 0) are set (PutTargetToSleep).
SkillSleep::
;> wBattleArg2 = lo(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
;> wBattleArg3 = hi(wTextArg0)
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo()
	call GetBattlerNameTo
;>@slp if wBattlerStatus[8 * wSkillTarget] & 0x8C:     # already asleep
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $8c
	jr nz, SleepAlready

;>     return SkillFailsNoAnim(0xBD)                 # "X is already sleeping!" (code after PutTargetToSleep)
;> if not RollSleep():
	call RollSleep
	jr nc, SleepResisted

;>     return SkillFails(0xBC)                       # "X doesn't fall asleep!" (code after PutTargetToSleep)
;> SkillWorksSideNoDamage(0xBCCC)                    # "X is sent to sleep!"
	ld hl, $bccc
	call SkillWorksSideNoDamage
;> PutTargetToSleep()                                # (falls through)
;> return

;@ def PutTargetToSleep()
;@ path: battle/skills/effects/status
;@ Sets the sleep bits ($8C) of the target's status byte 0. The end of SkillSleep; the
;@ battle flow of this bank also calls it on its own.
PutTargetToSleep::
;> wBattlerStatus[8 * wSkillTarget] |= 0x8C
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	or $8c
	ld [hl], a
;> return
	ret


SleepResisted:
;> # (SkillSleep, roll resisted: SkillFails(0xBC))
	ld a, $bc
	call SkillFails
	ret


SleepAlready:
;> # (SkillSleep, already asleep: SkillFailsNoAnim(0xBD))
	ld a, $bd
	call SkillFailsNoAnim
	ret


;@ def SkillStopSpell()
;@ path: battle/skills/effects/status
;@ Effect of StopSpell (skill $17): suspends the target's spells (bit 0 of status byte 1,
;@ wBattlerStatus1) when the roll against its resistance works: "X's spells are all
;@ suspended!", else "Has no effect on X!". Already suspended: ends without a message.
SkillStopSpell::
;>@on if wBattlerStatus[8 * wSkillTarget + 1] & 0x01:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not RollStopSpell():
	call RollStopSpell
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget + 1] |= 0x01
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 0, [hl]
;> SkillWorksSideNoDamage(0xB888)                    # "X's spells are all suspended!"
	ld hl, $b888
	call SkillWorksSideNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


;@ def SkillSurround()
;@ path: battle/skills/effects/status
;@ Effect of Surround (skill $18): an illusion engulfs the target (bit 1 of status byte 1)
;@ when the roll works: "An illusion engulfs X!", else "Has no effect on X!".
SkillSurround::
;>@on if wBattlerStatus[8 * wSkillTarget + 1] & 0x02:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not RollSurround():
	call RollSurround
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget + 1] |= 0x02
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 1, [hl]
;> SkillWorks(0xB898)                                # "An illusion engulfs X!"
	ld hl, $b898
	call SkillWorks
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


;@ def SkillPanicAll()
;@ path: battle/skills/effects/status
;@ Effect of PanicAll, PaniDance and LIFE (skills $19, $6E, $DA): confuses the target (bit 4
;@ of status byte 0): "X is confused!". An already confused target gives "X becomes more
;@ confused!", a resisted roll "Has no effect on X!".
SkillPanicAll::
;>@on if wBattlerStatus[8 * wSkillTarget] & 0x10:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr z, .notConfused

;>     return SkillFailsNoAnim(0xBE)                 # "X becomes more confused!"
	ld a, $be
	call SkillFailsNoAnim
	ret


.notConfused
;>@res if not RollConfusion():
	call RollConfusion
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget] |= 0x10
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 4, [hl]
;> SkillWorksSide(0xB88E)                            # "X is confused!"
	ld hl, $b88e
	call SkillWorksSide
;> return
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


;@ def SkillRobMagic()
;@ path: battle/skills/effects/status
;@ Effect of RobMagic and RobDance (skills $1A, $76): when the target has MP and the roll
;@ works, drains MP from it into the user (RobMagic): "X's MP is drained by Y!". A target
;@ without MP: "But nothing happens!"; resisted: "Has no effect on X!".
SkillRobMagic::
;>@mp0 if mem16[wBattlerMP + 2 * wSkillTarget] == 0:
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	or [hl]
	jr z, .noMP

;>@mp1     return SkillFails(0xBB)                  # "But nothing happens!"
;>@res if not RollRobMagic():
	call RollRobMagic
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;> RobMagic()
	call RobMagic
;> SkillWorksSide(0xB88A)                            # "X's MP is drained by Y!"
	ld hl, $b88a
	call SkillWorksSide
;> return
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


.noMP
;=@mp1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillTakeMagic()
;@ path: battle/skills/effects/status
;@ Effect of TakeMagic (skill $1B): the user starts to glow (bit 0 of status byte 2); the
;@ message "X starts to glow faintly!" is shown at once. Already glowing: no message.
SkillTakeMagic::
;>@on if wBattlerStatus[8 * wSkillUser + 2] & 0x01:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 0, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;> wBattlerStatus[8 * wSkillUser + 2] |= 0x01
	set 0, [hl]
;> SkillWorksAtOnce(0x8C00)                          # "X starts to glow faintly!"
	ld hl, $8c00
	call SkillWorksAtOnce
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillSap()
;@ path: battle/skills/effects/status
;@ Effect of Sap and Defence (skills $1C, $1D): when the roll against the target's resistance
;@ works, its defense drops by half its base defense (LowerDefense): "X loses N defense!".
;@ A defense that cannot drop further: "But nothing happens!"; resisted: "Has no effect on X!".
SkillSap::
;>@res if not RollDefenseDown():
	call RollDefenseDown
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;>@low if not LowerDefense():
	call LowerDefense
	jr nc, .noChange

;>@low1     return SkillFailsNoAnim(0xBB)            # "But nothing happens!"
;> MarkStatDown(wSkillTarget)
	ld a, [wSkillTarget]
	call MarkStatDown
;> SkillWorksSide(0xB886)                            # "X loses N defense!"
	ld hl, $b886
	call SkillWorksSide
;> return
	ret


.noChange
;=@low1
	ld a, $bb
	call SkillFailsNoAnim
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


;@ def SkillUpper()
;@ path: battle/skills/effects/status
;@ Effect of Upper and Increase (skills $1E, $1F): raises the target's defense (RaiseDefense):
;@ "X's defense goes up by N!"; at its limit "But nothing happens!".
SkillUpper::
;>@up if not RaiseDefense():
	call RaiseDefense
	jr nc, .noChange

;>@up1     return SkillFailsNoAnim(0xBB)             # "But nothing happens!"
;> SkillWorks(0x9292)                                # "X's defense goes up by N!"
	ld hl, $9292
	call SkillWorks
;> MarkStatUp(wSkillTarget)
	ld a, [wSkillTarget]
	call MarkStatUp
;> return
	ret


.noChange
;=@up1
	ld a, $bb
	call SkillFailsNoAnim
	ret


;@ def SkillSlow()
;@ path: battle/skills/effects/status
;@ Effect of Slow and SlowAll (skills $20, $21): when the roll works the target's agility
;@ drops (LowerAgility): "X's speed goes down by N!". Cannot drop: "But nothing happens!";
;@ resisted: "Has no effect on X!".
SkillSlow::
;>@res if not RollSlow():
	call RollSlow
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;>@low if not LowerAgility():
	call LowerAgility
	jr nc, .noChange

;>@low1     return SkillFailsNoAnim(0xBB)            # "But nothing happens!"
;> MarkStatDown(wSkillTarget)
	ld a, [wSkillTarget]
	call MarkStatDown
;> SkillWorksSide(0xB895)                            # "X's speed goes down by N!"
	ld hl, $b895
	call SkillWorksSide
;> return
	ret


.noChange
;=@low1
	ld a, $bb
	call SkillFailsNoAnim
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


;@ def SkillSpeed()
;@ path: battle/skills/effects/status
;@ Effect of Speed and SpeedUp (skills $22, $23): raises the target's agility (RaiseAgility):
;@ "X's speed goes up by N!"; at its limit "But nothing happens!".
SkillSpeed::
;>@up if not RaiseAgility():
	call RaiseAgility
	jr nc, .noChange

;>@up1     return SkillFailsNoAnim(0xBB)             # "But nothing happens!"
;> SkillWorks(0x9797)                                # "X's speed goes up by N!"
	ld hl, $9797
	call SkillWorks
;> MarkStatUp(wSkillTarget)
	ld a, [wSkillTarget]
	call MarkStatUp
;> return
	ret


.noChange
;=@up1
	ld a, $bb
	call SkillFailsNoAnim
	ret


;@ def SkillBarrier()
;@ path: battle/skills/effects/status
;@ Effect of Barrier (skill $24): a veil of light (bit 2 of status byte 2) covers every
;@ monster of the target's side that does not have one yet; positions without a monster lose
;@ the flag. If any monster got the veil, the group-1 message $09-$0B "A veil of light covers
;@ X / the X's gang / the monsters" (the far routine of bank $58 picks which in wBattleTemp),
;@ else no message.
SkillBarrier::
;> pos = wSkillTarget & 4                           # first position of that side
	ld a, [wSkillTarget]
	and $04
	ld c, a
;> new = 0
	ld b, $04
	ld d, $00

;>@loop for pos in range(pos, pos + 4):
.loop
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
;>@pr     if CheckBattlerPresent(pos):              # no monster: drop the veil
	ld a, c
	call CheckBattlerPresent
	jr c, .absent

;>@pr1         wBattlerStatus[8 * pos + 2] &= ~0x04
;>     elif not wBattlerStatus[8 * pos + 2] & 0x04:
	bit 2, [hl]
	jr nz, .next

;>         new += 1
	inc d
;>         wBattlerStatus[8 * pos + 2] |= 0x04
	set 2, [hl]

.next
;=@loop
	inc c
	dec b
	jr nz, .loop

;> if new == 0:
;>@q     return SkillEndsQuietly()
	ld a, d
	or a
	jr z, .none

;> NameTargetForMessage()                            # wBattleTemp: 0 one monster, 1 its gang, 2 mixed
	ld hl, far_NameTargetForMessage
	rst $10
;> SkillWorksGroup1(wBattleTemp + 9)                 # group-1 messages $09-$0B
	ld a, [wBattleTemp]
	add $09
	call SkillWorksGroup1
;> return
	ret


.absent
;=@pr1
	res 2, [hl]
	jr .next

.none
;=@q
	call SkillEndsQuietly
	ret


;@ def SkillTwinHits()
;@ path: battle/skills/effects/status
;@ Effect of TwinHits (skill $25): doubles the target's attack power (bit 2 of status byte 1):
;@ "X's attack power is doubled!". Already doubled: no message.
SkillTwinHits::
;>@on if wBattlerStatus[8 * wSkillTarget + 1] & 0x04:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;> wBattlerStatus[8 * wSkillTarget + 1] |= 0x04
	set 2, [hl]
;> SkillWorksNoDamage(0x9090)                        # "X's attack power is doubled!"
	ld hl, $9090
	call SkillWorksNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillMagicWall()
;@ path: battle/skills/effects/status
;@ Effect of MagicWall (skill $26): every monster on the user's side gets the magic wall (bit 6
;@ of status byte 3); no message of its own.
SkillMagicWall::
;> pos = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@loop for pos in range(pos, pos + 3):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wBattlerStatus[8 * pos + 3] |= 0x40
	ld a, c
	ld hl, wBattlerStatus3
	call AddEightTimes
	set 6, [hl]

.next
;=@loop
	inc c
	dec b
	jr nz, .loop

;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillMagicBack()
;@ path: battle/skills/effects/status
;@ Effect of MagicBack and Bounce (skills $27, $28): the user raises a wall of light that
;@ reflects spells (MagicBack, bit 5 of status byte 2: "A wall of light rises before X!") or
;@ attacks (Bounce, bit 1: "A wall of light is created before X!"); the other wall goes away.
;@ The same wall again: "But nothing happens!".
SkillMagicBack::
;> st = 8 * wSkillUser + 2
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
;>@b if wSkillId != 0x28:                           # MagicBack
	ld a, [wSkillId]
	cp $28
	jr z, .bounce

;>@m1     if wBattlerStatus[st] & 0x20:
	bit 5, [hl]
	jr nz, .nothing

;>@m2         return SkillFailsNoAnim(0xBB)          # "But nothing happens!"
;>     wBattlerStatus[st] = wBattlerStatus[st] & 0xDD | 0x20
	ld a, [hl]
	and $dd
	or $20
	ld [hl], a
;>     return SkillWorksNoDamage(0x9999)             # "A wall of light rises before X!"
	ld hl, $9999
	call SkillWorksNoDamage
	ret

;> if wBattlerStatus[st] & 0x02:                    # Bounce
;>@m3     return SkillFailsNoAnim(0xBB)
.bounce
;=@b
	bit 1, [hl]
	jr nz, .nothing

;> wBattlerStatus[st] = wBattlerStatus[st] & 0xDD | 0x02
	ld a, [hl]
	and $dd
	or $02
	ld [hl], a
;> SkillWorks(0x9A9A)                                # "A wall of light is created before X!"
	ld hl, $9a9a
	call SkillWorks
;> return
	ret


.nothing
;=@m2
;=@m3
	ld a, $bb
	call SkillFailsNoAnim
	ret


;@ def SkillTransform()
;@ path: battle/skills/effects/special
;@ Effect of Transform (skill $29): marks the user's stats as changed both ways and shows
;@ "Y turns into X!" (taking over the target's form happens in TransformIntoTarget).
SkillTransform::
;> MarkStatsChanged(wSkillUser)
	ld a, [wSkillUser]
	call MarkStatsChanged
;> SkillWorksNoDamage(0xA0A0)                        # "Y turns into X!"
	ld hl, $a0a0
	call SkillWorksNoDamage
;> return
	ret


;@ def SkillIronizeSelf()
;@ path: battle/skills/effects/status
;@ Effect of IRONIZE (skill $DC): Ironize aimed at the user itself.
SkillIronizeSelf::
;> wSkillTarget = wSkillUser
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> SkillIronize()                                    # (falls through)
;> return

;@ def SkillIronize()
;@ path: battle/skills/effects/status
;@ Effect of Ironize (skill $2A): turns monsters into iron lumps (bits 6-7 of status byte 5).
;@ An enemy using it (outside link battles) turns only itself, otherwise the whole side of
;@ the target turns. Then the "iron lump" message for one monster or the gang.
SkillIronize::
;>@one if not wLinkActive and wSkillTarget & 4:      # an enemy: only itself
	ld a, [wLinkActive]
	or a
	jr nz, .side

	ld a, [wSkillTarget]
	bit 2, a
	jr z, .side

;>     first, count = wSkillTarget, 1
	ld hl, wBattlerStatus5
	call AddEightTimes
	push hl
	pop hl
;=@one2
	ld b, $01
	ld a, [wSkillTarget]
	ld c, a
	jr .turn

;> else:
;>@one2     first, count = wSkillTarget & 4, 4
.side
	ld b, $04
	ld a, [wSkillTarget]
	and $04
	ld c, a
;=@one2
	ld hl, wBattlerStatus5
	call AddEightTimes

;>@loop for pos in range(first, first + count):
.turn
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wBattlerStatus[8 * pos + 5] |= 0xC0
	ld a, [hl]
	or $c0
	ld [hl], a

.next
;=@loop
	ld a, $08
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@loop
	inc c
	dec b
	jr nz, .turn

;> ShowIronizeMessage()
	call ShowIronizeMessage
;> return
	ret


;@ def SkillHeal()
;@ path: battle/skills/effects/heal
;@ Effect of Heal, HealMore, HealAll, HealUs, HealUsAll and Hustle (skills $2B-$2F, $94):
;@ heals the target (HealTarget) with "X's wound heals!". A fallen target or one with full
;@ HP: "But nothing happens!".
SkillHeal::
;>@abs if CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, .standing

;>@nothing     return SkillFails(0xBB)               # "But nothing happens!"
.nothing
;=@nothing
	ld a, $bb
	call SkillFails
	ret


.standing
;>@full if mem16[wBattlerHP + 2 * wSkillTarget] == mem16[wBattlerMaxHP + 2 * wSkillTarget]:
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@full
	ld a, $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@full
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr z, .nothing

;>@nothing2     return SkillFails(0xBB)
;> HealTarget()
	call HealTarget
;> SkillDealsDamageNoSide(0xBB84)                    # "X's wound heals!"
	ld hl, $bb84
	call SkillDealsDamageNoSide
;> return
	ret


;@ def SkillVivify()
;@ path: battle/skills/effects/heal
;@ Effect of Vivify, Revive and ALLREVIVE (skills $30, $31, $AD): brings a fallen monster
;@ back. Vivify works half the time and gives half the maximum HP ("X isn't revived!" when it
;@ fails); the others always work with full HP. Revive and ALLREVIVE aimed at a monster that
;@ still stands take the first fallen one of the user's side instead (and remember it as the
;@ action's target). "X is revived!"; nobody to revive: "But nothing happens!".
SkillVivify::
;>@st if not CheckBattlerPresent(wSkillTarget):      # still standing
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, .standing

;>@st1     if wSkillId == 0x30:
;>@st2         return SkillFails(0xBB)               # "But nothing happens!"
;>@srch     for pos in range(wSkillUser & 4, (wSkillUser & 4) | 3):
;>@srch2         if CheckBattlerPresent(pos) and wBattlerState[pos] != 0xFF:   # fallen
;>@srch3             wSkillTarget = pos
;>@srch4             mem[wBattlerAction + 1 + 2 * wSkillUser] = pos
;>@srch5             break
;>@srch6     else:
;>@srch7         return SkillFails(0xBB)
;>@emp elif wSkillTarget >= 8 or wBattlerState[wSkillTarget] == 0xFF:   # empty position
	jr z, .empty

;>@emp1     return SkillEndsQuietly()
;> elif wSkillId == 0x30:                            # Vivify: half the time
	ld a, [wSkillId]
	cp $30
	jr nz, .revive

;>     BattleRandom()
	call BattleRandom
;>@fail     if wRandomHigh >= 0x80:
	ld a, [wRandomHigh]
	cp $80
	jr nc, .failed

	jr .revive

;>@fail1         return SkillFails(0xC0)             # "X isn't revived!"
.search
;=@srch
	ld a, [wSkillUser]
	and $04
	ld c, a
	or $03
	ld b, a

.searchLoop
;=@srch2
	ld a, c
	call CheckBattlerPresent
	jr z, .searchNext

	jr c, .found

.searchNext
;=@srch
	inc a
	ld c, a
	cp b
	jr c, .searchLoop

;=@srch7
	jr .nothing

.found
;=@srch3
	ld [wSkillTarget], a
;=@srch4
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld [hl], c

;>@hp hp = mem16[wBattlerMaxHP + 2 * wSkillTarget]
.revive
	ld a, [wSkillTarget]
	ld b, a
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
;=@hp
	ld e, a
;> if wSkillId == 0x30:
	ld a, [wSkillId]
	cp $30
	jr nz, .setHP

;>     hp >>= 1
	srl d
	rr e

.setHP
;> mem16[wBattlerHP + 2 * wSkillTarget] = hp
	ld a, b
	ld hl, wBattlerHP
	call IndexWords
	ld a, e
	ld [hli], a
	ld [hl], d
;> ResetBattler(wSkillTarget)
	ld a, b
	call ResetBattler
;> SkillWorksNoDamage(0x9E9E)                        # "X is revived!"
	ld hl, $9e9e
	call SkillWorksNoDamage
;> return
	ret


.failed
;=@fail1
	ld a, $c0
	call SkillFails
	ret


.standing
;=@st1
	ld a, [wSkillId]
	cp $30
	jr nz, .search

.nothing
;=@st2
	ld a, $bb
	call SkillFails
	ret


.empty
;=@emp1
	call SkillEndsQuietly
	ret


;@ def SkillFarewell()
;@ path: battle/skills/effects/special
;@ Effect of Farewell (skill $32): goes on with battle sub-step 4 from its first stage.
SkillFarewell::
;> wBattleSubStep = 4
	ld a, $04
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> wBattleTemp = 0
	ld [wBattleTemp], a
;> wBattleStepArg0 = 0
	xor a
	ld [wBattleStepArg0], a
;> return
	ret


;@ def SkillAntidote()
;@ path: battle/skills/effects/heal
;@ Effect of Antidote (skill $33): cures the target's poison (bits 0-1 of status byte 0):
;@ "X is no longer poisoned!"; not poisoned: "But nothing happens!".
SkillAntidote::
;> status = ClearDamageGetStatus()                  # status byte 0 of the target
	call ClearDamageGetStatus
;>@no if not status & 0x03:
	and $03
	jr z, .nothing

;>@no1     return SkillFails(0xBB)                  # "But nothing happens!"
;> wBattlerStatus[8 * wSkillTarget] = status & 0xFC
	ld a, [hl]
	and $fc
	ld [hl], a
;> SkillWorksNoDamage(0x9C9C)                        # "X is no longer poisoned!"
	ld hl, $9c9c
	call SkillWorksNoDamage
;> return
	ret


.nothing
;=@no1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillNumbOff()
;@ path: battle/skills/effects/heal
;@ Effect of NumbOff (skill $34): ends paralysis (bit 6 of status byte 0: "X is no longer
;@ paralyzed!") and sleep (bits $8C: "X wakes up!"); the cured monster loses this turn
;@ (wBattlerOrder 3). Neither: "But nothing happens!".
SkillNumbOff::
;> status = ClearDamageGetStatus()
	call ClearDamageGetStatus
;>@no if not status & 0xCC:
	and $cc
	jr z, .nothing

;>@no1     return SkillFails(0xBB)                  # "But nothing happens!"
;> if status & 0x40:
	push hl
	bit 6, [hl]
	jr z, .asleep

;>     SkillWorksNoDamage(0x9D9D)                    # "X is no longer paralyzed!"
	ld hl, $9d9d
	jr .msg

;> else:
;>@s     SkillWorksNoDamage(0xDBDB)                  # "X wakes up!"
.asleep
	ld hl, $dbdb

.msg
;=@s
	call SkillWorksNoDamage
;> wBattlerStatus[8 * wSkillTarget] = status & 0x33
	pop hl
	ld a, [hl]
	and $33
	ld [hl], a
;>@ord wBattlerOrder[wSkillTarget] = 3                 # loses the turn
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@ord
	ld h, a
	ld [hl], $03
;> return
	ret


.nothing
;=@no1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillDeChaos()
;@ path: battle/skills/effects/heal
;@ Effect of DeChaos (skill $35): ends confusion (bit 4 of status byte 0); the monster loses
;@ this turn. "X returns to normal!"; not confused: "But nothing happens!".
SkillDeChaos::
;> status = ClearDamageGetStatus()
	call ClearDamageGetStatus
;>@no if not status & 0x10:
	and $10
	jr z, .nothing

;>@no1     return SkillFails(0xBB)                  # "But nothing happens!"
;> wBattlerStatus[8 * wSkillTarget] = status & 0xEF
	ld a, [hl]
	and $ef
	ld [hl], a
;>@ord wBattlerOrder[wSkillTarget] = 3                 # loses the turn
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@ord
	ld h, a
	ld [hl], $03
;> SkillWorksNoDamage(0xDCDC)                        # "X returns to normal!"
	ld hl, $dcdc
	call SkillWorksNoDamage
;> return
	ret


.nothing
;=@no1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillCurseOff()
;@ path: battle/skills/effects/heal
;@ Effect of CurseOff (skill $36): lifts the curse (bit 5 of status byte 0): "X is no longer
;@ cursed!"; not cursed: "But nothing happens!".
SkillCurseOff::
;> status = ClearDamageGetStatus()
	call ClearDamageGetStatus
;>@no if not status & 0x20:
	and $20
	jr z, .nothing

;>@no1     return SkillFails(0xBB)                  # "But nothing happens!"
;> wBattlerStatus[8 * wSkillTarget] = status & 0xDF
	ld a, [hl]
	and $df
	ld [hl], a
;> SkillWorksNoDamage(0x9F9F)                        # "X is no longer cursed!"
	ld hl, $9f9f
	call SkillWorksNoDamage
;> return
	ret


.nothing
;=@no1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillChance()
;@ path: battle/skills/effects/special
;@ Effect of Chance (skill $39): the far routine of bank $53 picks what happens; the battle
;@ goes on with sub-step 1.
SkillChance::
;> PickChanceEffect_53()
	ld hl, far_PickChanceEffect_53
	rst $10
;> wSkillMsgMode = 0
	ld a, $00
	ld [wSkillMsgMode], a
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
;> return
	ret


;@ def SkillAttack()
;@ path: battle/skills/effects/attacks
;@ The plain attack (Attack, skill $3A), also used by StepGuard, MapMagic, PoisonHit,
;@ NapAttack, Paralyze, Whistle, Run and the battle-item entries: the normal attack damage
;@ (CalcAttackDamage): "X takes N damage pts!", or "Misses! X is unharmed!" for 0.
SkillAttack::
;> SkillAttackDamage()
	call SkillAttackDamage
;> SkillDealsDamageMsg(0xB682)                       # "X takes N damage pts!" / "Misses! ..."
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillTwinSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of TwinSlash and PsycheUp (skills $3B, $56): a normal attack doing 1.5 times the
;@ damage.
SkillTwinSlash::
;> SkillAttackDamage()
	call SkillAttackDamage
;>@p wSkillAmount = Percent150(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent150
;=@p
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> SkillDealsDamageMsg(0xB682)                       # "X takes N damage pts!" / "Misses! ..."
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillRamming()
;@ path: battle/skills/effects/attacks
;@ Effect of Ramming (skill $3C): damage from CalcHPFractionDamage.
SkillRamming::
;> CalcHPFractionDamage()
	call CalcHPFractionDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillBeserker()
;@ path: battle/skills/effects/attacks
;@ Effect of Beserker (skill $3D): the user goes berserk (bit 2 of status byte 6) and attacks
;@ for double damage.
SkillBeserker::
;> wBattlerStatus[8 * wSkillUser + 6] |= 0x04
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 2, [hl]
;> SkillAttackDamage()
	call SkillAttackDamage
;>@d wSkillAmount = (wSkillAmount << 1) & 0xFFFF
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	sla l
	rl h
;=@d
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillKamikaze()
;@ path: battle/skills/effects/attacks
;@ Effect of Kamikaze (skill $3E): damage from CalcLeaveOneHPDamage.
SkillKamikaze::
;> CalcLeaveOneHPDamage()
	call CalcLeaveOneHPDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillMassacre()
;@ path: battle/skills/effects/attacks
;@ Effect of Massacre and EvilSlash (skills $3F, $40): marks the user (bit 7 of status byte 2)
;@ for the damage step. EvilSlash on a target that can still act misses when the random byte
;@ is below $A0: "X easily dodges the attack!". No target: no message.
SkillMassacre::
;>@gone if CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .gone

;>@gone1     return SkillEndsQuietly()
;>@ev if wSkillId != 0x3F and not CheckBattlerCanAct(wSkillTarget) and wRandomHigh < 0xA0:
	ld a, [wSkillId]
	cp $3f
	jr z, .hit

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
;=@ev
	jr c, .hit

	ld b, $a0
	ld a, [wRandomHigh]
	cp b
	jr c, .dodged

;>@ev1     return SkillFails(0x78)                   # "X easily dodges the attack!"
.hit
;> wBattlerStatus[8 * wSkillUser + 2] |= 0x80
	ld a, [wSkillUser]
	ld hl, wBattlerStatus2
	call AddEightTimes
	set 7, [hl]
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


.gone
;=@gone1
	call SkillEndsQuietly
	ret


.dodged
;=@ev1
	ld a, $78
	call SkillFails
	ret


;@ def SkillChargeUp()
;@ path: battle/skills/effects/attacks
;@ Effect of ChargeUP (skill $41): the user charges its attack (bits 0-1 of status byte 4);
;@ no message here.
SkillChargeUp::
;> wBattlerStatus[8 * wSkillUser + 4] |= 0x03
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	or $03
	ld [hl], a
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillHighJump()
;@ path: battle/skills/effects/attacks
;@ Effect of HighJump (skill $42), two turns: the first use takes the user high into the sky
;@ (bits 2-3 of status byte 4) and ends the action (battle sub-step 6); the next one brings it
;@ down with a normal attack doing 1.5 times the damage.
SkillHighJump::
;> st = 8 * wSkillUser + 4
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
;>@up if not wBattlerStatus[st] & 0x0C:
	ld a, [hl]
	and $0c
	jr nz, .comeDown

;>     wBattlerStatus[st] |= 0x0C
	ld a, [hl]
	or $0c
	ld [hl], a
;>     SkillEndsQuietly()
	call SkillEndsQuietly
;>     wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;>     wBattleSubStep = 6
	ld a, $06
	ld [wBattleSubStep], a
;>     return
	ret


.comeDown
;> wBattlerStatus[st] &= 0xF3
	ld a, [hl]
	and $f3
	ld [hl], a
;> SkillAttackDamage()
	call SkillAttackDamage
;>@p wSkillAmount = Percent150(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent150
;=@p
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillSuckAir()
;@ path: battle/skills/effects/attacks
;@ Effect of SuckAir (skill $43): the user takes a deep breath (bits 4-5 of status byte 4);
;@ no message here.
SkillSuckAir::
;> wBattlerStatus[8 * wSkillUser + 4] |= 0x30
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	or $30
	ld [hl], a
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillFireSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of FireSlash (skill $44): an attack cut by the target's resistance (CalcAttackDamageRes0).
SkillFireSlash::
;> CalcAttackDamageRes0()
	call CalcAttackDamageRes0
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillBoltSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of BoltSlash (skill $45): an attack cut by the target's resistance (CalcAttackDamageRes4).
SkillBoltSlash::
;> CalcAttackDamageRes4()
	call CalcAttackDamageRes4
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillVacuSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of VacuSlash (skill $46): an attack cut by the target's resistance (CalcAttackDamageRes3).
SkillVacuSlash::
;> CalcAttackDamageRes3()
	call CalcAttackDamageRes3
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillIceSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of IceSlash (skill $47): an attack cut by the target's resistance (CalcAttackDamageRes5).
SkillIceSlash::
;> CalcAttackDamageRes5()
	call CalcAttackDamageRes5
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillMetalCut()
;@ path: battle/skills/effects/attacks
;@ Effect of MetalCut (skill $48): an attack that does more against one monster type
;@ (CalcAttackDamageVsType0).
SkillMetalCut::
;> CalcAttackDamageVsType0()
	call CalcAttackDamageVsType0
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillDrakSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of DrakSlash (skill $49): an attack that does more against dragons.
SkillDrakSlash::
;> CalcDragonSlayerDamage()
	call CalcDragonSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillBeastCut()
;@ path: battle/skills/effects/attacks
;@ Effect of BeastCut (skill $4A): an attack that does more against beasts.
SkillBeastCut::
;> CalcBeastSlayerDamage()
	call CalcBeastSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillBirdBlow()
;@ path: battle/skills/effects/attacks
;@ Effect of BirdBlow (skill $4B): an attack that does more against birds.
SkillBirdBlow::
;> CalcBirdSlayerDamage()
	call CalcBirdSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillDevilCut()
;@ path: battle/skills/effects/attacks
;@ Effect of DevilCut (skill $4C): an attack that does more against devils.
SkillDevilCut::
;> CalcDevilSlayerDamage()
	call CalcDevilSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillZombieCut()
;@ path: battle/skills/effects/attacks
;@ Effect of ZombieCut (skill $4D): an attack that does more against zombies.
SkillZombieCut::
;> CalcZombieSlayerDamage()
	call CalcZombieSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillCleanCut()
;@ path: battle/skills/effects/attacks
;@ Effect of CleanCut (skill $4E): an attack that does more against material monsters.
SkillCleanCut::
;> CalcMaterialSlayerDamage()
	call CalcMaterialSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillMultiCut()
;@ path: battle/skills/effects/attacks
;@ Effect of MultiCut (skill $4F): damage from CalcSkillDamageVsZombie.
SkillMultiCut::
;> CalcSkillDamageVsZombie()
	call CalcSkillDamageVsZombie
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillBiAttack()
;@ path: battle/skills/effects/attacks
;@ Effect of BiAttack and QuadHits (skills $50, $51), one hit each time it runs. The attack is
;@ worked out with the user's attack lowered for the hit: to 3/4 for BiAttack (whose target, if
;@ gone, is picked anew by RetargetSkill), to 5/8 for QuadHits (which hits the target stored in
;@ the user's action). The attack value is put back afterwards.
SkillBiAttack::
;>@q if wSkillId != 0x51:                           # BiAttack
	ld a, [wSkillId]
	cp $51
	jr z, .quad

;>     if CheckBattlerPresent(wSkillTarget):
;>         RetargetSkill()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	call c, RetargetSkill
;>     quad = False
	ld d, $00
	jr .attack

;> else:
;>@q1     wSkillTarget = mem[wBattlerAction + 1 + 2 * wSkillUser]
.quad
;=@q1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
;>@q2     quad = True
;=@q2
	ld d, $01

.attack
;>@sp wStatPtr = wBattlerAttack + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call IndexWords
	ld a, l
	ld [wStatPtr], a
	ld a, h
;=@sp
	ld [wStatPtr + 1], a
;> attack = mem16[wStatPtr]
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
;> if not quad:
	ld a, d
	or a
	jr nz, .fiveEighths

;>     lowered = Percent75(attack)
	call Percent75
	jr .set

;> else:
;>@f     lowered = ((attack >> 1) + (attack >> 3)) & 0xFFFF   # 1/2 + 1/8
.fiveEighths
;=@f
	call ShiftHL1
	ld b, h
	ld c, l
	call ShiftBC2
	add hl, bc

.set
;>@s1 mem16[wStatPtr] = lowered
	ld a, [wStatPtr]
	ld c, a
	ld a, [wStatPtr + 1]
	ld b, a
	ld a, l
	ld [bc], a
;=@s1
	inc bc
	ld a, h
	ld [bc], a
;> SkillAttackDamage()
	call SkillAttackDamage
;>@s2 mem16[wStatPtr] = attack
	pop hl
	ld a, [wStatPtr]
	ld c, a
	ld a, [wStatPtr + 1]
	ld b, a
	ld a, l
;=@s2
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def RetargetSkill()
;@ path: battle/skills/effects/attacks
;@ Picks a new target for an attack whose target is gone (the far routine of bank $58).
RetargetSkill::
;> AITargetAttack()
	ld hl, far_AITargetAttack
	rst $10
;> return
	ret


;@ def SkillCallHelp()
;@ path: battle/skills/effects/special
;@ Effect of CallHelp and YellHelp (skills $52, $53). On the first call (wHitCount 1) the
;@ call is heard half the time: "Allies appear from nowhere!" is printed, the user is marked
;@ (bit 0 of status byte 6) and wHitCount becomes $0F - for an enemy outside link battles $10
;@ (CallHelp) or $11 (YellHelp); otherwise "But the call is not heard!". Each later run is one
;@ helper's hit on the action's target (CalcLevelDamageRes24), or ends the help
;@ (EndCalledHelp) when that target is gone.
SkillCallHelp::
;>@first if wHitCount == 1:
	ld a, [wHitCount]
	cp $01
	jr nz, .helperHit

;>     BattleRandom()
	call BattleRandom
;>@heard     if not wRandomHigh & 1:
	ld a, [wRandomHigh]
	and $01
	jr z, .notHeard

;>@nh1         wHitCount = 0xFF
;>@nh2         wSkillAmount = 0
;>@nh3         return SkillFails(0xC2)               # "But the call is not heard!"
;>     wBattleStepArg0 = 3
	ld a, $03
	ld [wBattleStepArg0], a
;>     wHitCount = 0x0F
	ld a, $0f
	ld [wHitCount], a
;>     wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;>     wTextGroup = 0
	ld [wTextGroup], a
;>     wTextIndex = 0xA1                             # "Allies appear from nowhere!"
	ld a, $a1
	ld [wTextIndex], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     wBattlerStatus[8 * wSkillUser + 6] |= 0x01
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 0, [hl]
;>     if wLinkActive or wSkillUser < 4:
;>         return
	ld a, [wLinkActive]
	or a
	ret nz

	ld a, [wSkillUser]
	cp $04
	ret c

;>     wHitCount += 1                                # an enemy's helpers
	ld hl, wHitCount
	inc [hl]
;>     if wSkillId == 0x52:
;>         return
	ld a, [wSkillId]
	cp $52
	ret z

;>     wHitCount += 1
	inc [hl]
;>     return
	ret


.notHeard
;=@nh1
	ld a, $ff
	ld [wHitCount], a
;=@nh2
	xor a
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a
;=@nh3
	ld a, $c2
	call SkillFails
	ret


.helperHit
;>@t wSkillTarget = mem[wBattlerAction + 1 + 2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
;> if CheckBattlerPresent(wSkillTarget):
;>     return EndCalledHelp()
	call CheckBattlerPresent
	jp c, EndCalledHelp

;> CalcLevelDamageRes24()
	call CalcLevelDamageRes24
;> SkillDealsDamageMsg(0xB682)                       # "X takes N damage pts!" / "Misses! ..."
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillFocus()
;@ path: battle/skills/effects/attacks
;@ Effect of Focus (skill $54): the user calms itself and focuses (bit 7 of status byte 4);
;@ no message here.
SkillFocus::
;> wBattlerStatus[8 * wSkillUser + 4] |= 0x80
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	set 7, [hl]
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillSquallHit()
;@ path: battle/skills/effects/attacks
;@ Effect of SquallHit (skill $55): a normal attack doing 80 % of the damage.
SkillSquallHit::
;> SkillAttackDamage()
	call SkillAttackDamage
;>@p wSkillAmount = Percent80(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent80
;=@p
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillRainSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of RainSlash (skill $57), one hit per run (wHitCount 1-4): a normal attack doing
;@ 80 % of the damage on the first hit, 60 % on the second, 40 % after that. When the target
;@ is gone the slashes move on to the next position of its side (and the action remembers
;@ it), without a hit this time. From the fifth run on: nothing.
SkillRainSlash::
;> if wHitCount >= 5:
;>@q     return SkillEndsQuietly()
	ld a, [wHitCount]
	cp $05
	jr nc, .quiet

;>@gone if CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .nextTarget

;>@g1     if wSkillTarget != (wSkillTarget & 4) | 2:
;>@g2         wSkillTarget += 1
;>@g3         mem[wBattlerAction + 1 + 2 * wSkillUser] = wSkillTarget
;>@g4     return SkillEndsQuietly()
;> SkillAttackDamage()
	call SkillAttackDamage
;> dmg = wSkillAmount
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
;>@h1 if wHitCount == 1:
	ld a, [wHitCount]
	cp $01
	jr z, .first

;>@h1a     dmg = Percent80(dmg)
;>@h2 elif wHitCount == 2:
	cp $02
	jr z, .second

;>@h2a     dmg = Percent60(dmg)
;> else:
;>     dmg = Percent40(dmg)
	call Percent40
	jr .store

.first
;=@h1a
	call Percent80
	jr .store

.second
;=@h2a
	call Percent60

.store
;> wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


.nextTarget
;=@g1
	ld a, [wSkillTarget]
	and $04
	or $02
	ld b, a
	ld a, [wSkillTarget]
	cp b
;=@g1
	jr z, .quiet

;=@g2
	inc a
	ld [wSkillTarget], a
;=@g3
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [wSkillTarget]
	ld [hl], a

.quiet
;=@q
;=@g4
	call SkillEndsQuietly
	ret


;@ def SkillWindBeast()
;@ path: battle/skills/effects/spells
;@ Effect of WindBeast and Vacuum (skills $58, $59): damage from the user's level
;@ (CalcLevelDamage, for Vacuum CalcLevelDamage2).
SkillWindBeast::
;> if wSkillId != 0x59:
;>     CalcLevelDamage()
	ld a, [wSkillId]
	cp $59
	jr z, .vacuum

	call CalcLevelDamage
	jr .done

;> else:
;>@v     CalcLevelDamage2()
.vacuum
;=@v
	call CalcLevelDamage2

.done
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillRockThrow()
;@ path: battle/skills/effects/spells
;@ Effect of RockThrow (skill $5B): skill-table damage cut by the target's resistance.
SkillRockThrow::
;> CalcSkillDamageRes24()
	call CalcSkillDamageRes24
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillFireAir()
;@ path: battle/skills/effects/spells
;@ Effect of the fire breaths FireAir, BlazeAir, Scorching and WhiteFire (skills $5C-$5F):
;@ skill-table damage cut by the target's resistance, halved behind a veil of light.
SkillFireAir::
;> CalcSkillDamageRes16()
	call CalcSkillDamageRes16
;> HalveDamageBehindVeil()
	call HalveDamageBehindVeil
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillFrigidAir()
;@ path: battle/skills/effects/spells
;@ Effect of the ice breaths FrigidAir, IceAir, IceStorm and WhiteAir (skills $60-$63):
;@ skill-table damage cut by the target's resistance, halved behind a veil of light.
SkillFrigidAir::
;> CalcSkillDamageRes17()
	call CalcSkillDamageRes17
;> HalveDamageBehindVeil()
	call HalveDamageBehindVeil
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillBigBang()
;@ path: battle/skills/effects/spells
;@ Effect of BigBang (skill $65): skill-table damage cut by the target's resistance.
SkillBigBang::
;> CalcSkillDamageRes0()
	call CalcSkillDamageRes0
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillMegaMagic()
;@ path: battle/skills/effects/spells
;@ Effect of MegaMagic (skill $66): damage from the user's MP and level (CalcMPLevelDamage).
SkillMegaMagic::
;> CalcMPLevelDamage()
	call CalcMPLevelDamage
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillPalsyAir()
;@ path: battle/skills/effects/status
;@ Effect of PalsyAir (skill $6B): paralyzes the target (bit 6 of status byte 0): "X is
;@ paralyzed!"; resisted: "X dodges the air attack!". Already paralyzed: no message.
SkillPalsyAir::
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;>@on if wBattlerStatus[st] & 0x40:
	bit 6, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;> if not TryEffectRes19():
	push hl
	call TryEffectRes19
	pop hl
	jr c, .works

;>     return SkillFailsSide(0xC3)                   # "X dodges the air attack!"
	ld a, $c3
	call SkillFailsSide
	ret


.works
;> wBattlerStatus[st] |= 0x40
	set 6, [hl]
;> SkillWorksNoDamage(0xCFCF)                        # "X is paralyzed!"
	ld hl, $cfcf
	call SkillWorksNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillPoisonGas()
;@ path: battle/skills/effects/status
;@ Effect of PoisonGas and PoisonAir (skills $6C, $6D): poisons the target - PoisonGas sets
;@ bit 0 of status byte 0 ("X is poisoned!"), PoisonAir bit 1 ("X is severely poisoned!"),
;@ each clearing the other. Resisted: "X dodges the air attack!". Already poisoned (any
;@ poison for PoisonGas, the severe one for PoisonAir): no message.
SkillPoisonGas::
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;>@air if wSkillId != 0x6D:                         # PoisonGas
	ld a, [wSkillId]
	cp $6d
	jr z, .air

;>     wBattleArg0 = 0xCE                            # "X is poisoned!"
	ld a, $ce
	ld [wBattleArg0], a
;>     if wBattlerStatus[st] & 0x03:
;>@q1         return SkillEndsQuietly()
	ld a, [hl]
	and $03
	jr nz, .quiet

	jr .roll

;> else:
;>@a1     wBattleArg0 = 0xD0                        # "X is severely poisoned!"
.air
;=@a1
	ld a, $d0
	ld [wBattleArg0], a
;>@a2     if wBattlerStatus[st] & 0x02:
;=@a2
	bit 1, [hl]
	jr nz, .quiet

;>@q2         return SkillEndsQuietly()
.roll
;> if not TryEffectRes18():
	call TryEffectRes18
	jr c, .works

;>     return SkillFailsSide(0xC3)                   # "X dodges the air attack!"
	ld a, $c3
	call SkillFailsSide
	ret


.works
;> if wSkillId != 0x6D:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [wSkillId]
	cp $6d
	jr z, .severe

;>     wBattlerStatus[st] = (wBattlerStatus[st] | 0x01) & ~0x02
	set 0, [hl]
	res 1, [hl]
	jr .msg

;> else:
;>@s     wBattlerStatus[st] = (wBattlerStatus[st] | 0x02) & ~0x01
.severe
;=@s
	set 1, [hl]
	res 0, [hl]

.msg
;> SkillWorksNoDamage(wBattleArg0 * 0x101)
	ld a, [wBattleArg0]
	ld h, a
	ld l, a
	call SkillWorksNoDamage
;> return
	ret


.quiet
;=@q1
;=@q2
	call SkillEndsQuietly
	ret


;@ def SkillCurse()
;@ path: battle/skills/effects/status
;@ Effect of Curse (skill $6F): curses the target (bit 5 of status byte 0): "X is cursed!";
;@ resisted: "Has no effect on X!". Already cursed: no message.
SkillCurse::
;>@on if wBattlerStatus[8 * wSkillTarget] & 0x20:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 5, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;> if not TryEffectRes20():
	call TryEffectRes20
	jr c, .works

;>     return SkillFailsSide(0xB8)                   # "Has no effect on X!"
	ld a, $b8
	call SkillFailsSide
	ret


.works
;> wBattlerStatus[8 * wSkillTarget] |= 0x20
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 5, [hl]
;> SkillWorksNoDamage(0xD1D1)                        # "X is cursed!"
	ld hl, $d1d1
	call SkillWorksNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillAhhh()
;@ path: battle/skills/effects/status
;@ Effect of Ahhh (skill $70): the target feels good (bit 5 of status byte 3): "X seems to be
;@ feeling good!"; resisted: "Has no effect on X!". Already: no message.
SkillAhhh::
;>@on if wBattlerStatus[8 * wSkillTarget + 3] & 0x20:
	call TargetStatus3
	bit 5, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not TryEffectRes21():
	call TryEffectRes21
	jr nc, .resisted

;>@res1     return SkillFailsSide(0xB8)              # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x20
	call TargetStatus3
	set 5, [hl]
;> SkillWorks(0xA7A7)                                # "X seems to be feeling good!"
	ld hl, $a7a7
	call SkillWorks
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFailsSide
	ret


;@ def SkillSandStorm()
;@ path: battle/skills/effects/status
;@ Effect of SandStorm and Radiant (skills $72, $73): blinds the target (bits 0-1 of status
;@ byte 5) when the roll works: "X gets sand in its eyes!" / "X is blinded!" (message
;@ wSkillId + $30); resisted: "Has no effect on X!". Already blinded: no message.
SkillSandStorm::
;>@on if wBattlerStatus[8 * wSkillTarget + 5] & 0x03:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not RollSurround():
	call RollSurround
	jr nc, .resisted

;>@res1     return SkillFailsSide(0xB8)              # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget + 5] |= 0x03
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	set 1, [hl]
	set 0, [hl]
;> SkillWorks((wSkillId + 0x30) * 0x101)            # $A2 / $A3
	ld a, [wSkillId]
	add $30
	ld h, a
	ld l, a
	call SkillWorks
;> return
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFailsSide
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillEerieLite()
;@ path: battle/skills/effects/status
;@ Effect of EerieLite (skill $74): leaves the target open to spells (bit 7 of status byte
;@ 3) when the roll works: "X is now vulnerable to magic spells!"; resisted: "Has no effect
;@ on X!"; already: "But nothing happens!".
SkillEerieLite::
;>@on if wBattlerStatus[8 * wSkillTarget + 3] & 0x80:
	call TargetStatus3
	bit 7, [hl]
	jr nz, .already

;>@on1     return SkillFailsNoAnim(0xBB)             # "But nothing happens!"
;>@res if not RollInstantDeath():
	call RollInstantDeath
	jr nc, .resisted

;>@res1     return SkillFailsSide(0xB8)              # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x80
	call TargetStatus3
	set 7, [hl]
;> SkillWorks(0xA4A4)                                # "X is now vulnerable to magic spells!"
	ld hl, $a4a4
	call SkillWorks
;> return
	ret


.already
;=@on1
	ld a, $bb
	call SkillFailsNoAnim
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFailsSide
	ret


;@ def SkillOddDance()
;@ path: battle/skills/effects/status
;@ Effect of OddDance (skill $75): when the target has MP and the roll works, it loses MP
;@ (DrainTargetMP): "X lost N MP!". No MP: "But nothing happens!"; resisted: "Has no
;@ effect on X!".
SkillOddDance::
;>@mp0 if mem16[wBattlerMP + 2 * wSkillTarget] == 0:
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	or [hl]
	jr z, .noMP

;>@mp1     return SkillFails(0xBB)                  # "But nothing happens!"
;>@res if not RollRobMagic():
	call RollRobMagic
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;> DrainTargetMP()
	call DrainTargetMP
;> SkillWorks(0xA5A5)                                # "X lost N MP!"
	ld hl, $a5a5
	call SkillWorks
;> return
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


.noMP
;=@mp1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillSideStep()
;@ path: battle/skills/effects/status
;@ Effect of SideStep (skill $77): unless the user is already side-stepping, bits 2-3 of its
;@ status byte 5 become 1 or 2 at random; no message here.
SkillSideStep::
;> BattleRandom()
	call BattleRandom
;> st = 8 * wSkillUser + 5
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
;> if not wBattlerStatus[st] & 0x0C:
	ld a, [hl]
	and $0c
	jr nz, .done

;>@s     wBattlerStatus[st] = wBattlerStatus[st] & 0xF3 | (4 + (wRandomHigh & 4))
	ld a, [wRandomHigh]
	and $04
	add $04
	ld b, a
	ld a, [hl]
	and $f3
;=@s
	or b
	ld [hl], a

.done
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillLureDance()
;@ path: battle/skills/effects/status
;@ Effect of LureDance (skill $78): lures the target into dancing (bit 1 of status byte 3):
;@ "X is lured into dancing!"; resisted: "X isn't lured in!". Already: no message.
SkillLureDance::
;>@on if wBattlerStatus[8 * wSkillTarget + 3] & 0x02:
	call TargetStatus3
	bit 1, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not TryEffectRes21():
	call TryEffectRes21
	jr nc, .resisted

;>@res1     return SkillFails(0xC8)                  # "X isn't lured in!"
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x02
	call TargetStatus3
	set 1, [hl]
;> SkillWorks(0xA6A6)                                # "X is lured into dancing!"
	ld hl, $a6a6
	call SkillWorks
;> return
	ret


.resisted
;=@res1
	ld a, $c8
	call SkillFails
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillLushLicks()
;@ path: battle/skills/effects/status
;@ Effect of LushLicks and SickLick (skills $79, $7A): licks the target (bit 3 of status byte
;@ 3): "X gets goose bumps!". SickLick (rolled like Sap) also drops its defense to 1 ("... X's
;@ defense drops to 1"). Resisted: "X isn't affected!"; already licked: no message.
SkillLushLicks::
;>@on if wBattlerStatus[8 * wSkillTarget + 3] & 0x08:
	call TargetStatus3
	bit 3, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;> if wSkillId != 0x7A:
;>     works = TryEffectRes21()
	ld a, [wSkillId]
	cp $7a
	jr z, .sick

	call TryEffectRes21
	jr .check

;> else:
;>@s     works = RollDefenseDown()
.sick
;=@s
	call RollDefenseDown

.check
;>@res if not works:
;=@res
	jr nc, .resisted

;>@res1     return SkillFailsSide(0xCA)              # "X isn't affected!"
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x08
	call TargetStatus3
	set 3, [hl]
;> if wSkillId != 0x79:                              # SickLick
	ld a, [wSkillId]
	cp $79
	jr z, .msg

;>     mem16[wBattlerDefense + 2 * wSkillTarget] = 1
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, $01
	ld [hli], a
	ld [hl], $00
;>     MarkStatDown(wSkillTarget)
	ld a, [wSkillTarget]
	call MarkStatDown

.msg
;> SkillWorksNoDamage((wSkillId + 0x2F) * 0x101)    # $A8 / $A9
	ld a, [wSkillId]
	add $2f
	ld h, a
	ld l, a
	call SkillWorksNoDamage
;> return
	ret


.resisted
;=@res1
	ld a, $ca
	call SkillFailsSide
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillLegSweep()
;@ path: battle/skills/effects/status
;@ Effect of LegSweep and BigTrip (skills $7B, $7C): the target stumbles (bit 2 of status byte
;@ 3): "X stumbles!". Resisted: "But it doesn't reach X!" for a target with bit 4 of its type
;@ bits (a flier), else "But X dodges easily!". Already stumbling: no message.
SkillLegSweep::
;>@on if wBattlerStatus[8 * wSkillTarget + 3] & 0x04:
	call TargetStatus3
	bit 2, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not TryEffectRes21NotType4():
	call TryEffectRes21NotType4
	jr nc, .resisted

;>@r1     if wBattlerTypeBits[wSkillTarget] & 0x10:
;>@r2         return SkillFails(0xC1)               # "But it doesn't reach X!"
;>@r3     return SkillFails(0xC9)                   # "But X dodges easily!"
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x04
	call TargetStatus3
	set 2, [hl]
;> SkillWorksNoDamage(0xABAB)                        # "X stumbles!"
	ld hl, $abab
	call SkillWorksNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


.resisted
;=@r1
	ld a, [wSkillTarget]
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@r1
	ld h, a
	bit 4, [hl]
;=@r3
	ld a, $c9
;=@r1
	jr z, .msg

;=@r2
	ld a, $c1

.msg
;=@r2
	call SkillFails
	ret


;@ def SkillWarCry()
;@ path: battle/skills/effects/status
;@ Effect of WarCry (skill $7D): the target freezes in shock (bit 4 of status byte 3):
;@ "X freezes in shock!"; resisted: "X isn't affected!". No target or already shocked: no
;@ message.
SkillWarCry::
;> if CheckBattlerPresent(wSkillTarget):
;>@q     return SkillEndsQuietly()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .quiet

;> if wBattlerStatus[8 * wSkillTarget + 3] & 0x10:
;>@q2     return SkillEndsQuietly()
	call TargetStatus3
	bit 4, [hl]
	jr nz, .quiet

;>@res if not TryEffectRes21():
	call TryEffectRes21
	jr nc, .resisted

;>@res1     return SkillFailsSide(0xCA)              # "X isn't affected!"
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x10
	call TargetStatus3
	set 4, [hl]
;> SkillWorksNoDamage(0xAAAA)                        # "X freezes in shock!"
	ld hl, $aaaa
	call SkillWorksNoDamage
;> return
	ret


.quiet
;=@q
;=@q2
	call SkillEndsQuietly
	ret


.resisted
;=@res1
	ld a, $ca
	call SkillFailsSide
	ret


;@ def SkillImitate()
;@ path: battle/skills/effects/special
;@ Effect of Imitate (skill $7F): marks the user (bit 3 of status byte 6); no message here.
SkillImitate::
;> wBattlerStatus[8 * wSkillUser + 6] |= 0x08
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 3, [hl]
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillDeMagic()
;@ path: battle/skills/effects/special
;@ Effect of DeMagic, ThickFog and FILTHZONE (skills $80, $83, $A5): goes on with battle
;@ sub-step 3 from its first stage.
SkillDeMagic::
;> wBattleSubStep = 3
	ld a, $03
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> return
	ret


;@ def SkillSurge()
;@ path: battle/skills/effects/heal
;@ Effect of Surge (skill $81): the far routine of bank $53 does the curing; "X is
;@ completely cured!".
SkillSurge::
;> Call_53_601C()
	ld hl, far_Call_53_601C
	rst $10
;> SkillWorks(0xAEAE)                                # "X is completely cured!"
	ld hl, $aeae
	call SkillWorks
;> return
	ret


;@ def SkillUltraDown()
;@ path: battle/skills/effects/status
;@ Effect of UltraDown (skill $82): when the roll works and the target's stats can drop
;@ (CanLowerTargetStats), the battle goes on with sub-step 3; otherwise "Has no effect on X!".
SkillUltraDown::
;> if RollInstantDeath() and CanLowerTargetStats():
	call RollInstantDeath
	jr nc, .fails

	call CanLowerTargetStats
	jr nc, .fails

;>     wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;>     wBattleSubStep = 3
	ld a, $03
	ld [wBattleSubStep], a
;>     return
	ret


.fails
;> SkillFails(0xB8)                                  # "Has no effect on X!"
	ld a, $b8
	call SkillFails
;> return
	ret


;@ def SkillTatsuCall()
;@ path: battle/skills/effects/special
;@ Effect of TatsuCall, DiagoCall, SamsiCall and BazooCall (skills $84-$87): once per battle
;@ and side (bit 2 of wSideFlags), with a 3/4 chance, a monster joins the battle
;@ (SetUpCalledMonster picks the free position, wBattleArg0): it is put in the fight as species
;@ wSkillId + $54 and becomes the target: "Wow! X joined the battle!". Already called: "But
;@ nothing happens!"; random byte $C0 or more: "But the prayer isn't heard!".
SkillTatsuCall::
;> BattleRandom()
	call BattleRandom
;>@s side = (wSkillUser >> 2) & 1
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
;>@on if wSideFlags[side] & 0x04:
	bit 2, [hl]
	jr nz, .already

;>@on1     return SkillFailsNoAnim(0xBB)             # "But nothing happens!"
;>@rnd if wRandomHigh >= 0xC0:
	ld a, $c0
	ld b, a
	ld a, [wRandomHigh]
	cp b
	jr nc, .notHeard

;>@rnd1     return SkillFails(0xCB)                  # "But the prayer isn't heard!"
;> wSideFlags[side] |= 0x04
	set 2, [hl]
;> SetUpCalledMonster(wSkillId)
	ld a, [wSkillId]
	call SetUpCalledMonster
;>@st wBattlerState[wBattleArg0] = 0
	ld a, [wBattleArg0]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@st
	ld h, a
	ld [hl], $00
;>@sp wBattlerSpecies[wBattleArg0] = u8(wSkillId + 0x54)
	ld a, [wBattleArg0]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld a, [wSkillId]
	add $54
	ld [hl], a
;> wSkillTarget = wBattleArg0
	ld a, [wBattleArg0]
	ld [wSkillTarget], a
;> SkillWorks(0xAFAF)                                # "Wow! X joined the battle!"
	ld hl, $afaf
	call SkillWorks
;> return
	ret


.already
;=@on1
	ld a, $bb
	call SkillFailsNoAnim
	ret


.notHeard
;=@rnd1
	ld a, $cb
	call SkillFails
	ret


;@ def SkillCover()
;@ path: battle/skills/effects/special
;@ Effect of Cover and Guardian (skills $88, $89): goes on with battle sub-step 3 from its
;@ first stage.
SkillCover::
;> wBattleSubStep = 3
	ld a, $03
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> return
	ret


;@ def SkillTailWind()
;@ path: battle/skills/effects/status
;@ Effect of TailWind and StormWind (skills $8A, $8B): a wind protects the target (bit 6 of
;@ status byte 2). StormWind covers every position of the target's side from the target up
;@ to the third (wSkillTarget ends there) and marks the side (bit 5 of wSideFlags). No
;@ message here.
SkillTailWind::
;>@loop for _ in forever():
;>     wBattlerStatus[8 * wSkillTarget + 2] |= 0x40
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	set 6, [hl]
;>     if wSkillId == 0x8A:
;>@q         break
	ld a, [wSkillId]
	cp $8a
	jr z, .done

;>     if (wSkillTarget & 3) == 2:
	ld a, [wSkillTarget]
	and $03
	cp $02
	jr z, .lastOfSide

;>@ls1         wSideFlags[(wSkillTarget >> 2) & 1] |= 0x20
;>@ls2         break
;>     wSkillTarget += 1
	ld hl, wSkillTarget
	inc [hl]
;=@loop
	jr SkillTailWind

.lastOfSide
;=@ls1
	ld a, [wSkillTarget]
	rra
	rra
	and $01
	ld hl, wSideFlags
	add l
;=@ls1
	ld l, a
	ld a, $00
	adc h
	ld h, a
	set 5, [hl]

.done
;=@q
;=@ls2
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillDodge()
;@ path: battle/skills/effects/status
;@ Effect of Dodge (skill $8C): the user gets ready to dodge (bit 5 of status byte 6); no
;@ message here.
SkillDodge::
;> wBattlerStatus[8 * wSkillUser + 6] |= 0x20
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 5, [hl]
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillDefence()
;@ path: battle/skills/effects/status
;@ Effect of the stances Defence, StrongD and BladeD (skills $8D, $8E, $90): the low nibble of
;@ the user's status byte 7 becomes 1, 2 or 4; no message here.
SkillDefence::
;> st = 8 * wSkillUser + 7
	ld a, [wSkillUser]
	ld hl, wBattlerStatus7
	call AddEightTimes
;> if wSkillId != 0x90:
	ld a, [wSkillId]
	cp $90
	jr z, .blade

;>@d     wBattlerStatus[st] = wBattlerStatus[st] & 0xF0 | (wSkillId - 0x8C)
	sub $8c
	ld b, a
	ld a, [hl]
	and $f0
	or b
	ld [hl], a
;=@d
	jr .done

;> else:
;>@b     wBattlerStatus[st] = wBattlerStatus[st] & 0xF0 | 4
.blade
;=@b
	ld a, [hl]
	and $f0
	or $04
	ld [hl], a

.done
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillSuckAll()
;@ path: battle/skills/effects/special
;@ Effect of SuckAll (skill $8F): once per side (bit 6 of wSideFlags) the user opens its mouth
;@ to suck everything in: its position is noted in wSuckAllUsers (bit 2 + position) and it
;@ is marked (bit 1 of status byte 6). No message here.
SkillSuckAll::
;> side = 1 if wSkillUser >= 4 else 0
	ld a, [wSkillUser]
	cp $04
	jr c, .own

	ld hl, wSideFlags + 1
	jr .check

.own
	ld hl, wSideFlags

.check
;> if not wSideFlags[side] & 0x40:
	bit 6, [hl]
	jr nz, .done

;>     wSideFlags[side] |= 0x40
	set 6, [hl]
;>@u     wSuckAllUsers[side] |= (wSkillUser & 3) << 2
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@u
	ld a, [wSkillUser]
	and $03
	rla
	rla
	ld b, a
	ld a, [hl]
;=@u
	or b
	ld [hl], a
;>     wBattlerStatus[8 * wSkillUser + 6] |= 0x02
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 1, [hl]

.done
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillDanceShut()
;@ path: battle/skills/effects/status
;@ Effect of DanceShut (skill $91): stops the target's dancing (bit 6 of status byte 1):
;@ "X's hypnotic dance is stopped!"; resisted: "Has no effect on X!". Already: no message.
SkillDanceShut::
;>@on if wBattlerStatus[8 * wSkillTarget + 1] & 0x40:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 6, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not TryEffectRes22():
	call TryEffectRes22
	jr nc, .resisted

;>@res1     return SkillFails(0xB8)                  # "Has no effect on X!"
;> wBattlerStatus[8 * wSkillTarget + 1] |= 0x40
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 6, [hl]
;> SkillWorksSideNoDamage(0xB0B0)                    # "X's hypnotic dance is stopped!"
	ld hl, $b0b0
	call SkillWorksSideNoDamage
;> return
	ret


.resisted
;=@res1
	ld a, $b8
	call SkillFails
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def SkillMouthShut()
;@ path: battle/skills/effects/status
;@ Effect of MouthShut (skill $92): binds the target's mouth (bit 7 of status byte 1): "X's
;@ mouth is bound shut!"; resisted: "But X dodges easily!". Already: no message.
SkillMouthShut::
;>@on if wBattlerStatus[8 * wSkillTarget + 1] & 0x80:
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;>@res if not TryEffectRes23():
	call TryEffectRes23
	jr nc, .resisted

;>@res1     return SkillFailsSide(0xC9)              # "But X dodges easily!"
;> wBattlerStatus[8 * wSkillTarget + 1] |= 0x80
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 7, [hl]
;> SkillWorksSideNoDamage(0xB2B2)                    # "X's mouth is bound shut!"
	ld hl, $b2b2
	call SkillWorksSideNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


.resisted
;=@res1
	ld a, $c9
	call SkillFailsSide
	ret


;@ def SkillMeditate()
;@ path: battle/skills/effects/heal
;@ Effect of Meditate (skill $93): the user heals 500 HP (up to its maximum): "X's wound
;@ heals!"; at full HP "But nothing happens!".
SkillMeditate::
;>@mx wSkillAmount2 = mem16[wBattlerMaxHP + 2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@mx
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [wSkillAmount2 + 1], a
;>@p wSkillTempPtr = wBattlerHP + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	ld a, l
	ld [wSkillTempPtr], a
	ld a, h
;=@p
	ld [wSkillTempPtr + 1], a
;> hp = mem16[wSkillTempPtr]
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@full if hp == wSkillAmount2:
	call CompareHLBC
	jr z, .full

;>@full1     return SkillFails(0xBB)                 # "But nothing happens!"
;>@mn hp = min(hp + 500, wSkillAmount2)
	ld bc, $01f4
	add hl, bc
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
;=@mn
	call CompareHLBC
	jr c, .store

	ld h, b
	ld l, c

.store
;>@sv mem16[wSkillTempPtr] = hp
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [wSkillTempPtr + 1]
	ld b, a
	ld a, l
	ld [bc], a
;=@sv
	inc bc
	ld a, h
	ld [bc], a
;> SkillWorks(0x8484)                                # "X's wound heals!"
	ld hl, $8484
	call SkillWorks
;> return
	ret


.full
;=@full1
	ld a, $bb
	call SkillFails
	ret


;@ def SkillLifeSong()
;@ path: battle/skills/effects/heal
;@ Effect of LifeSong (skill $95), over two turns (bits 4-5 of the user's status byte 5): the
;@ first use starts the song (state 2) without a message. The next one ends it; then, half
;@ the time and only if a monster of the user's side has fallen (wBattlerState 1), the battle
;@ goes on with sub-step 4 (the revival), else "But the prayer isn't heard!".
SkillLifeSong::
;> st = 8 * wSkillUser + 5
	ld a, [wSkillUser]
	ld hl, wBattlerStatus5
	call AddEightTimes
;>@sing if not wBattlerStatus[st] & 0x10:
	ld a, [hl]
	and $10
	jr nz, .finish

;>     wBattlerStatus[st] = wBattlerStatus[st] & 0xCF | 0x20
	ld a, [hl]
	and $cf
	or $20
	ld [hl], a
;>     return SkillEndsQuietly()
	call SkillEndsQuietly
	ret


.finish
;> wBattlerStatus[st] &= 0xCF
	ld a, [hl]
	and $cf
	ld [hl], a
;> BattleRandom()
	call BattleRandom
;>@r if wRandomHigh < 0x80:
	ld a, [wRandomHigh]
	cp $80
	jr c, .notHeard

;>@r1     return SkillFails(0xCB)                    # "But the prayer isn't heard!"
;>@f for pos in range(wSkillUser & 4, (wSkillUser & 4) + 3):
	ld a, [wSkillUser]
	and $04
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
;=@f
	adc h
	ld h, a
	ld b, $03

.search
;>@f1     if wBattlerState[pos] == 1:                 # fallen
	ld a, [hli]
	cp $01
	jr z, .revive

;=@f
	dec b
	jr nz, .search

;=@f3
	jr .notHeard

;>@f2         break
;>@f3 else:
;>@f4     return SkillFails(0xCB)
.revive
;=@f2
;> wBattleSubStep = 4
	ld a, $04
	ld [wBattleSubStep], a
;> wBattleTemp = 4
	ld [wBattleTemp], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> wBattleStepArg0 = 0
	xor a
	ld [wBattleStepArg0], a
;> return
	ret


.notHeard
;=@r1
;=@f4
	ld a, $cb
	call SkillFails
	ret


;@ def SkillLifeDance()
;@ path: battle/skills/effects/heal
;@ Effect of LifeDance (skill $96): with a random byte below $7F the battle goes on with
;@ sub-step 4 (the revival dance), else "But nothing happens!".
SkillLifeDance::
;> BattleRandom()
	call BattleRandom
;> if wRandomHigh >= 0x7F:
	ld a, [wRandomHigh]
	cp $7f
	jr c, .dance

;>     return SkillFails(0xBB)                       # "But nothing happens!"
	ld a, $bb
	call SkillFails
	ret


.dance
;> wBattleSubStep = 4
	ld a, $04
	ld [wBattleSubStep], a
;> wBattleTemp = 4
	ld [wBattleTemp], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> wBattleStepArg0 = 0
	xor a
	ld [wBattleStepArg0], a
;> return
	ret


;@ def SkillDaze()
;@ path: battle/skills/effects/special
;@ Effect of Daze (skill $98): nothing happens and no message.
SkillDaze::
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillChgDragon()
;@ path: battle/skills/effects/special
;@ Effect of CHGDRAGON and BeDragon (skills $AA, $D5): "X changes into a big dragon!".
SkillChgDragon::
;> SkillWorksNoDamage(0x9191)                        # "X changes into a big dragon!"
	ld hl, $9191
	call SkillWorksNoDamage
;> return
	ret


;@ def SkillSmashlime()
;@ path: battle/skills/effects/attacks
;@ Effect of Smashlime (skill $D6): an attack that does more against slimes.
SkillSmashlime::
;> CalcSlimeSlayerDamage()
	call CalcSlimeSlayerDamage
;> SkillDealsDamageMsg(0xB682)                       # "X takes N damage pts!" / "Misses! ..."
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillSheldodge()
;@ path: battle/skills/effects/attacks
;@ Effect of Sheldodge (skill $D7): an attack that does more against bugs.
SkillSheldodge::
;> CalcBugSlayerDamage()
	call CalcBugSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillBranching()
;@ path: battle/skills/effects/attacks
;@ Effect of Branching (skill $D8): an attack that does more against plants.
SkillBranching::
;> CalcPlantSlayerDamage()
	call CalcPlantSlayerDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillGigaSlash()
;@ path: battle/skills/effects/attacks
;@ Effect of GigaSlash (skill $D9): skill-table damage cut by the target's resistance.
SkillGigaSlash::
;> CalcSkillDamageRes25()
	call CalcSkillDamageRes25
;> SkillDealsDamage()
	call SkillDealsDamage
;> return
	ret


;@ def SkillRunAway()
;@ path: battle/skills/effects/special
;@ Effect of RUN (skills $A1, $DB): the user leaves the battle (wBattlerState $FF). An enemy
;@ that runs also takes its reward with it (its 3 bytes of wEnemyReward cleared) and
;@ ActionStepDefeat runs. The battle goes on with sub-step 1, no message.
SkillRunAway::
;>@st wBattlerState[wSkillUser] = 0xFF
	ld a, [wSkillUser]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@st
	ld h, a
	ld [hl], $ff
;> if wSkillUser >= 4:
	ld a, [wSkillUser]
	cp $04
	jr c, .done

;>@r     fill(wEnemyReward + 3 * (wSkillUser & 3), 0, 3)
	and $03
	ld hl, wEnemyReward
	ld b, a
	add a
	add b
	add l
;=@r
	ld l, a
	ld a, $00
	adc h
	ld h, a
	xor a
	ld [hli], a
;=@r
	ld [hli], a
	ld [hl], a
;>     ActionStepDefeat()
	call ActionStepDefeat

.done
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillHalfAttack()
;@ path: battle/skills/effects/attacks
;@ Effect of Ahhh (skill $DD, the monster-only version): a normal attack doing half the
;@ damage; for 0 "X isn't affected!".
SkillHalfAttack::
;> SkillAttackDamage()
	call SkillAttackDamage
;>@h wSkillAmount >>= 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call ShiftHL1
;=@h
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> SkillDealsDamageMsg(0xCA82)                       # "X takes N damage pts!" / "X isn't affected!"
	ld hl, $ca82
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillHitAlly()
;@ path: battle/skills/effects/attacks
;@ Effect of HitAlly (skill $99, a confused monster hitting its own side): a normal attack
;@ that misses ("Misses! X is unharmed!") when the random byte is below $40.
SkillHitAlly::
;> BattleRandom()
	call BattleRandom
;>@m if wRandomHigh < 0x40:
	ld a, [wRandomHigh]
	cp $40
	jr c, .miss

;>@m1     return SkillFails(0xB6)                    # "Misses! X is unharmed!"
;> SkillAttackDamage()
	call SkillAttackDamage
;> SkillDealsDamageMsg(0xB682)                       # "X takes N damage pts!" / "Misses! ..."
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


.miss
;=@m1
	ld a, $b6
	call SkillFails
	ret


;@ def SkillHitEnemy()
;@ path: battle/skills/effects/attacks
;@ Effect of HitEnemy (skill $9A): a normal attack that misses when the random byte is below
;@ $C0 (3 times in 4).
SkillHitEnemy::
;> BattleRandom()
	call BattleRandom
;>@m if wRandomHigh < 0xC0:
	ld a, [wRandomHigh]
	cp $c0
	jr c, .miss

;>@m1     return SkillFails(0xB6)                    # "Misses! X is unharmed!"
;> SkillAttackDamage()
	call SkillAttackDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


.miss
;=@m1
	ld a, $b6
	call SkillFails
	ret


;@ def SkillHitSelf()
;@ path: battle/skills/effects/attacks
;@ Effect of HitRandom (skill $9B, "attacks wildly - but it hits itself"): the user attacks
;@ itself (also stored as its action's target).
SkillHitSelf::
;> wSkillTarget = wSkillUser
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> mem[wBattlerAction + 1 + 2 * wSkillUser] = wSkillUser
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [wSkillUser]
	ld [hl], a
;> SkillAttackDamage()
	call SkillAttackDamage
;> SkillDealsDamageMsg(0xB682)
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


;@ def SkillTrip()
;@ path: battle/skills/effects/status
;@ Effect of Trip (skill $9E, a monster that stumbles): the user is marked as stumbling (bit 2
;@ of status byte 3); no message here.
SkillTrip::
;> wBattlerStatus[8 * wSkillUser + 3] |= 0x04
	ld a, [wSkillUser]
	ld hl, wBattlerStatus3
	call AddEightTimes
	set 2, [hl]
;> SkillNoEffect()                                   # (falls through)
;> return

;@ def SkillNoEffect()
;@ path: battle/skills/effects/special
;@ Effect of Scared, Dance and ECHO (skills $9C, $9D, $A9): ends without a message (their
;@ text was shown when the action started).
SkillNoEffect::
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillCantMove()
;@ path: battle/skills/effects/status
;@ Effect of Paralyze and CANTMOVE (skills $9F, $A0): the user is paralyzed (bit 6 of status
;@ byte 0); "X is paralyzed!" is shown at once.
SkillCantMove::
;> wBattlerStatus[8 * wSkillUser] |= 0x40
	ld a, [wSkillUser]
	ld hl, wBattlerStatus
	call AddEightTimes
	set 6, [hl]
;> SkillWorksAtOnce(0xCF00)                          # "X is paralyzed!"
	ld hl, $cf00
	call SkillWorksAtOnce
;> return
	ret


;@ def SkillCallHorror()
;@ path: battle/skills/effects/special
;@ Effect of CALLHOROR and Smashed (skills $A2, $A4): the target's HP drop to 0 and it leaves
;@ the battle like a monster running away (SkillRunAway done in its name); the battle goes on
;@ with sub-step 1. Message "X falls to pieces!" (Smashed) or "X tries to escape!".
SkillCallHorror::
;> mem16[wBattlerHP + 2 * wSkillTarget] = 0
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	xor a
	ld [hli], a
	ld [hl], a
;> user = wSkillUser
	ld a, [wSkillUser]
	push af
;> wSkillUser = wSkillTarget
	ld a, [wSkillTarget]
	ld [wSkillUser], a
;> SkillRunAway()
	call SkillRunAway
;> wSkillUser = user
	pop af
	ld [wSkillUser], a
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
;> if wSkillId == 0xA4:
;>     SkillWorksNoDamage(0xE9E9)                    # "X falls to pieces!"
	ld hl, $e9e9
	ld a, [wSkillId]
	cp $a4
	jr z, .msg

;> else:
;>     SkillWorksNoDamage(0x2929)                    # "X tries to escape!"
	ld hl, $2929

.msg
	call SkillWorksNoDamage
;> return
	ret


;@ def SkillHealUsAllSpecial()
;@ path: battle/skills/effects/heal
;@ Effect of the second HealUsAll (skill $A3): works as HealUsAll (skill $2F).
SkillHealUsAllSpecial::
;> wSkillId = 0x2F
	ld a, $2f
	ld [wSkillId], a
;> SkillHeal()
	call SkillHeal
;> return
	ret


;@ def SkillAllChange()
;@ path: battle/skills/effects/special
;@ Effect of ALLCHANGE (skill $A6): every monster on the user's side gets bit 3 of its status
;@ byte 1; no message here.
SkillAllChange::
;> pos = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
	ld b, $03

;>@loop for pos in range(pos, pos + 3):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         wBattlerStatus[8 * pos + 1] |= 0x08
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 3, [hl]

.next
;=@loop
	inc c
	dec b
	jr nz, .loop

;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret


;@ def SkillBigSleep()
;@ path: battle/skills/effects/status
;@ Effect of BIGSLEEP (skill $A7): puts the target to sleep (the sleep bits $8C of status
;@ byte 0) without a roll: "X is sent to sleep!". Asleep already (bit 7): "X is already
;@ sleeping!"; no target: no message.
SkillBigSleep::
;> if CheckBattlerPresent(wSkillTarget):
;>@q     return SkillEndsQuietly()
	ld a, [wSkillTarget]
	ld c, a
	call CheckBattlerPresent
	jr c, .quiet

;> st = 8 * wSkillTarget
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;>@on if wBattlerStatus[st] & 0x80:
	bit 7, [hl]
	jr nz, .asleep

;>@on1     return SkillFails(0xBD)                   # "X is already sleeping!"
;> wBattlerStatus[st] = wBattlerStatus[st] & 0x73 | 0x8C
	ld a, [hl]
	and $73
	or $8c
	ld [hl], a
;> SkillWorksSideNoDamage(0xCCCC)                    # "X is sent to sleep!"
	ld hl, $cccc
	call SkillWorksSideNoDamage
;> return
	ret


.asleep
;=@on1
	ld a, $bd
	call SkillFails
	ret


.quiet
;=@q
	call SkillEndsQuietly
	ret


;@ def SkillMP0()
;@ path: battle/skills/effects/status
;@ Effect of MP0 (skill $A8): the target's MP drop to 0: "X is out of MP!". No target or no
;@ MP: no message.
SkillMP0::
;> if CheckBattlerPresent(wSkillTarget):
;>@q     return SkillEndsQuietly()
	ld a, [wSkillTarget]
	ld c, a
	call CheckBattlerPresent
	jr c, .quiet

;> if mem16[wBattlerMP + 2 * wSkillTarget] == 0:
;>@q2     return SkillEndsQuietly()
	ld a, c
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	or [hl]
	jr z, .quiet

;> mem16[wBattlerMP + 2 * wSkillTarget] = 0
	xor a
	ld [hld], a
	ld [hl], a
;> SkillWorksNoDamage(0x7272)                        # "X is out of MP!"
	ld hl, $7272
	call SkillWorksNoDamage
;> return
	ret


.quiet
;=@q
;=@q2
	call SkillEndsQuietly
	ret


;@ def SkillCallEvil()
;@ path: battle/skills/effects/special
;@ Effect of CALLEVIL (skill $AB): the summoned devil strikes the action's target
;@ (CalcAttack400Damage) and the user is marked (bit 0 of status byte 6). No target: no
;@ message.
SkillCallEvil::
;> wSkillTarget = mem[wBattlerAction + 1 + 2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
;> if CheckBattlerPresent(wSkillTarget):
;>@q     return SkillEndsQuietly()
	call CheckBattlerPresent
	jr c, .quiet

;> CalcAttack400Damage()
	call CalcAttack400Damage
;> wBattlerStatus[8 * wSkillUser + 6] |= 0x01
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 0, [hl]
;> SkillDealsDamageMsg(0xB682)                       # "X takes N damage pts!" / "Misses! ..."
	ld hl, $b682
	call SkillDealsDamageMsg
;> return
	ret


.quiet
;=@q
	call SkillEndsQuietly
	ret


;@ def SkillFreezy()
;@ path: battle/skills/effects/status
;@ Effect of FREEZY (skill $AC): freezes the target (bit 0 of status byte 3) without a roll:
;@ "X is frozen!". Already frozen: no message.
SkillFreezy::
;>@on if wBattlerStatus[8 * wSkillTarget + 3] & 0x01:
	call TargetStatus3
	bit 0, [hl]
	jr nz, .already

;>@on1     return SkillEndsQuietly()
;> wBattlerStatus[8 * wSkillTarget + 3] |= 0x01
	set 0, [hl]
;> SkillWorksSideNoDamage(0xB5B5)                    # "X is frozen!"
	ld hl, $b5b5
	call SkillWorksSideNoDamage
;> return
	ret


.already
;=@on1
	call SkillEndsQuietly
	ret


;@ def UnusedRevivedCheck()
;@ path: unused/battle
;@ Not called: "X is revived!" when the target's wBattlerState is 1, else no message.
UnusedRevivedCheck::
;>@st if wBattlerState[wSkillTarget] == 1:
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@st
	ld h, a
	ld a, [hl]
	cp $01
	jr nz, .quiet

;>     return SkillWorks(0x9E9E)                     # "X is revived!"
	ld hl, $9e9e
	call SkillWorks
	ret

.quiet
;> SkillEndsQuietly()
	call SkillEndsQuietly
;> return
	ret

;@ def SkillRestoreMP()
;@ path: battle/skills/effects/heal
;@ Effect of RESTOREMP (skill $AE): fills the target's MP: "X recovers MP!". It is meant to do
;@ nothing at full MP, but the check compares the two bytes of the current MP with each other,
;@ so it ends quietly only when they happen to be equal.
SkillRestoreMP::
;> mx = GetBattlerMaxMP(wSkillTarget)
	ld a, [wSkillTarget]
	call GetBattlerMaxMP
	push hl
;> p = wBattlerMP + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	pop bc
;>@eq if mem[p] == mem[p + 1]:                      # (low byte against high byte)
	ld a, [hli]
	cp [hl]
	jr z, .quiet

;>@eq1     return SkillEndsQuietly()
;> mem16[p] = mx
	ld a, b
	ld [hld], a
	ld [hl], c
;> SkillWorksNoDamage(0x7676)                        # "X recovers MP!"
	ld hl, $7676
	call SkillWorksNoDamage
;> return
	ret


.quiet
;=@eq1
	call SkillEndsQuietly
	ret


;@ def SkillMeteor()
;@ path: battle/skills/effects/special
;@ Effect of METEOR (skill $AF), one shooting star per run (wHitCount 1-8): it takes all but
;@ 1 HP of the target ("X receives a fatal blow!"), or the last 1 HP ("X takes 1 damage
;@ pts!"). When the target is gone the star goes to position (wHitCount & 3) - of the
;@ opposing side for the first three, of the user's own side after that - which becomes the
;@ action's target, and the skill steps start over. From the ninth run: nothing.
SkillMeteor::
;> n = wHitCount
	ld a, [wHitCount]
	ld c, a
;> if not 1 <= n <= 8:
;>@q     return SkillEndsQuietly()
	dec a
	cp $08
	jr nc, .quiet

;>@g if CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .newTarget

;>@g1     side = (wSkillUser & 4) ^ 4 if n < 4 else wSkillUser & 4
;>@g2     pos = side | (n & 3)
;>@g3     mem[wBattlerAction + 1 + 2 * wSkillUser] = pos
;>@g4     wSkillTarget = pos
;>@g5     wBattleSubStep2 = 0
;>@g6     return
;> hp = mem16[wBattlerHP + 2 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@one if hp == 1:
	cp $01
	jr nz, .fatal

	ld a, d
	or a
	jr z, .lastHP

;>@one1     wSkillAmount = 1
;>@one2     return SkillDealsDamageNoSide(0x8282)   # "X takes 1 damage pts!"
.fatal
;> wSkillAmount = hp - 1
	dec de
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a
;> SkillDealsDamageNoSide(0x8585)                    # "X receives a fatal blow!"
	ld hl, $8585
	call SkillDealsDamageNoSide
;> return
	ret


.lastHP
;=@one1
	ld hl, $0001
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;=@one2
	ld hl, $8282
	call SkillDealsDamageNoSide
	ret


.quiet
;=@q
	call SkillEndsQuietly
	ret


.newTarget
;=@g2
	ld a, c
	and $03
	ld b, a
;=@g1
	ld a, c
	cp $04
	jr c, .opposing

	ld a, [wSkillUser]
	and $04
;=@g2
	or b
	jr .setTarget

.opposing
;=@g1
	ld a, [wSkillUser]
	and $04
	xor $04
;=@g2
	or b

.setTarget
;=@g3
	ld b, a
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld [hl], b
;=@g4
	ld a, b
	ld [wSkillTarget], a
;=@g5
	xor a
	ld [wBattleSubStep2], a
;=@g6
	ret


;@ def UnusedClearAmountText()
;@ path: unused/battle
;@ Not called: clears wSkillAmount and falls into UnusedAmountText.
UnusedClearAmountText::
;> wSkillAmount = 0
	ld a, $00
	ld [wSkillAmount], a
	ld a, $00
	ld [wSkillAmount + 1], a
;> UnusedAmountText()                                # (falls through)
;> return

;@ def UnusedAmountText()
;@ path: unused/battle
;@ Not called (only from UnusedItemDamageText): puts the target's name and the amount into
;@ the message arguments and starts the hit effect with message wBattlerReload (moved on by
;@ the user's side when wItemMsgGroup is set).
UnusedAmountText::
;> PrepareDamageText()
	call PrepareDamageText
;> msg = wBattlerReload
	ld a, [wBattlerReload]
	ld b, a
;> if wItemMsgGroup:
	ld a, [wItemMsgGroup]
	or a
	jr z, .add

;>     msg += wSkillUser >> 2
	ld a, [wSkillUser]
	srl a
	srl a

.add
	add b
;> wTextGroup = 0
	ld l, a
	ld h, $00
	ld a, h
	ld [wTextGroup], a
;> wTextIndex = u8(msg)
	ld a, l
	ld [wTextIndex], a
;> StartSkillHitEffect()
	ld hl, far_StartSkillHitEffect
	rst $10
;> return
	ret

;@ def UnusedItemDamageText()
;@ path: unused/battle
;@ Not called: shows "X takes N damage pts!" through UnusedAmountText, or the miss message
;@ (ShowMissMessage) when wSkillAmount is 0.
UnusedItemDamageText::
;> wBattlerReload = 0x82
	ld a, $82
	ld [wBattlerReload], a
;> wItemMsgGroup = 0x82
	ld [wItemMsgGroup], a
;>@if if wSkillAmount == 0:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, l
	or h
;=@if
	jr nz, .amount

;>@z     return ShowMissMessage()
	call ShowMissMessage
	ret

.amount
;> UnusedAmountText()
	call UnusedAmountText
;> return
	ret

;@ def PrepareDamageText()
;@ path: battle/skills/result
;@ The target's name into wTextArg0 and the amount (wSkillAmount) as a number into wTextArg1,
;@ for messages like "X takes N damage pts!".
PrepareDamageText::
;> TargetNameToArg0()
	call TargetNameToArg0
;> DamageToText()
	call DamageToText
;> return
	ret


;@ def DamageToText()
;@ path: battle/skills/result
;@ wSkillAmount as a decimal number into wTextArg1.
DamageToText::
;> Number16ToDecimal(wSkillAmount, wTextArg1)
	ld hl, wTextArg1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	call Number16ToDecimal
;> return
	ret


;@ def EndCalledHelp()
;@ path: battle/skills/effects/special
;@ CallHelp's helpers stop when their target is gone: battle scratch byte $DB51 = 5 and
;@ message mode 2.
EndCalledHelp::
;> mem[0xDB51] = 5
	ld a, $05
	ld [$db51], a
;> wSkillMsgMode = 2
	ld a, $02
	ld [wSkillMsgMode], a
;> return
	ret


;@ def UnusedNoEffectText()
;@ path: unused/battle
;@ Not called: sets up "Has no effect on X!" (the target's name, message $B8, step counter
;@ 4) and plays sound $6F.
UnusedNoEffectText::
;> wNamePos = wSkillTarget
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	call GetBattlerNameTo
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;> wTextIndex = 0xB8
	ld a, $b8
	ld [wTextIndex], a
;> wSkillMsgMode = 0
	ld a, $00
	ld [wSkillMsgMode], a
;> wBattleStepArg0 = 4
	ld a, $04
	ld [wBattleStepArg0], a
;> QueueSound(0x6F)
	ld a, $6f
	call QueueSound
;> return
	ret

;@ def UnusedShowText78()
;@ path: unused/battle
;@ Not called: the target's name, then battle message $78 ("X easily dodges the attack!")
;@ through the message part of ShowMissMessage.
;@ test: skip calls into the middle of ShowMissMessage
UnusedShowText78::
;> wNamePos = wSkillTarget
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	call GetBattlerNameTo
;> ShowBattleMessage(0x0078)                         # ShowMissMessage + $1A
	ld hl, $0078
	call ShowMissMessage + $1a
;> return
	ret

;@ def UnusedShowNothingText()
;@ path: unused/battle
;@ Not called: battle message $BB ("But nothing happens!") through the message part of
;@ ShowMissMessage.
;@ test: skip calls into the middle of ShowMissMessage
UnusedShowNothingText::
;> ShowBattleMessage(0x00BB)                         # ShowMissMessage + $1A
	ld hl, $00bb
	call ShowMissMessage + $1a
;> return
	ret

;@ def ShowMissMessage()
;@ path: battle/skills/result
;@ Sets up the miss message: the target's name into wTextArg0 and "Misses! X is unharmed!"
;@ ($B6) or "Missed X! No damage!" ($B7, for a target on the other side as seen from this Game
;@ Boy, GetViewSidePos); message mode 0, one more message step, sound $6F. From $515D on (hl =
;@ text number) it is also the plain "show this message" tail.
ShowMissMessage::
;> wNamePos = wSkillTarget
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	call GetBattlerNameTo
;> msg = 0xB6 + (((GetViewSidePos() >> 2) & 0x3F) ^ 1)
	call GetViewSidePos
	srl a
	srl a
	xor $01
	add $b6
;> wTextGroup = 0
	ld l, a
	ld h, $00
	ld a, h
	ld [wTextGroup], a
;> wTextIndex = msg
	ld a, l
	ld [wTextIndex], a
;> wSkillMsgMode = 0
	ld a, $00
	ld [wSkillMsgMode], a
;> wBattleStepArg0 += 1
	ld hl, wBattleStepArg0
	inc [hl]
;> QueueSound(0x6F)
	ld a, $6f
	call QueueSound
;> return
	ret


;@ def UnusedShowItemMessage()
;@ path: unused/battle
;@ Not called: the target's name and battle message wBattlerReload, message mode 2, one more
;@ message step, sound $6F.
UnusedShowItemMessage::
;> wNamePos = wSkillTarget
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	call GetBattlerNameTo
;> wTextIndex = wBattlerReload
	ld a, [wBattlerReload]
	ld [wTextIndex], a
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;> wSkillMsgMode = 2
	ld a, $02
	ld [wSkillMsgMode], a
;> wBattleStepArg0 += 1
	ld hl, wBattleStepArg0
	inc [hl]
;> QueueSound(0x6F)
	ld a, $6f
	call QueueSound
;> return
	ret

;@ def SkillAttackDamage()
;@ path: battle/skills/damage
;@ The normal attack damage (CalcAttackDamage) into wSkillAmount.
SkillAttackDamage::
;> CalcAttackDamage()
	call CalcAttackDamage
;> return
	ret


;@ def ClearDamageGetStatus() -> a
;@ path: battle/skills/effects/heal
;@ Clears wSkillAmount and returns status byte 0 of the target (hl points to it).
ClearDamageGetStatus::
;> wSkillAmount = 0
	ld a, $00
	ld [wSkillAmount], a
	ld a, $00
	ld [wSkillAmount + 1], a
;> return wBattlerStatus[8 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	ret


;@ def UnusedRollIllusionMiss() -> carry
;@ path: unused/battle
;@ Not called: carry (a miss) when the user is under an illusion (bit 1 of status byte 1) and
;@ the random byte is below $A0.
UnusedRollIllusionMiss::
;> BattleRandom()
	call BattleRandom
	scf
	ccf
;> if not wBattlerStatus[8 * wSkillUser + 1] & 0x02:
;>     return False
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	ret z

;> return wRandomHigh < 0xA0
	ld a, [wRandomHigh]
	cp $a0
	ret

;@ def UnusedRollSideStepMiss() -> carry
;@ path: unused/battle
;@ Not called: carry (a miss) when the target is side-stepping (bits 2-3 of status byte 5)
;@ and the random byte is below $80.
UnusedRollSideStepMiss::
;> if not wBattlerStatus[8 * wSkillTarget + 5] & 0x0C:
;>     return False
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $0c
	ret z

;> return wRandomHigh < 0x80
	ld a, [wRandomHigh]
	cp $80
	ret

;@ def ResetBattler(pos: a)
;@ path: battle/skills/effects/heal
;@ Puts battle position `pos` back into the fight with all 8 status bytes cleared, and draws
;@ its monster picture again (LoadBattlerPic with its species).
ResetBattler::
;>@st wBattlerState[pos] = 0
	push hl
	push bc
	ld b, a
	ld hl, wBattlerState
	add l
	ld l, a
;=@st
	ld a, $00
	adc h
	ld h, a
	ld [hl], $00
;>@clr fill(wBattlerStatus + 8 * pos, 0, 8)
	ld a, b
	ld hl, wBattlerStatus
	call AddEightTimes
	xor a
	ld [hli], a
	ld [hli], a
;=@clr
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
;>@pic LoadBattlerPic(pos, wBattlerSpecies[pos])
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@pic
	ld h, a
	ld c, [hl]
	call LoadBattlerPic
;> return
	pop bc
	pop hl
	ret


;@ def UnusedResetArgBattler()
;@ path: unused/battle
;@ Not called: ResetBattler(wBattleArg0).
UnusedResetArgBattler::
;> ResetBattler(wBattleArg0)
	ld a, [wBattleArg0]
	call ResetBattler
;> return
	ret

;@ def LoadBattlerPic(pos: b, species: c)
;@ path: battle/screen
;@ Draws the monster picture of battle position `pos` again: on a Game Boy Color the species
;@ is noted for the palettes (SetBattlerPicSpecies). Only the enemy positions 4-6 have
;@ pictures (positions 0-2 on the Game Boy that drives a link battle); picture slot n sits at
;@ VRAM $9000 + $240 * n. The graphics are decompressed from the species' entry of the
;@ picture table at ActorGfx + $C0 (bank, entry), then the battle palettes are rebuilt.
;@ test: skip draws to VRAM through the decompressor and other banks
LoadBattlerPic::
;> SetBattlerPicSpecies(pos, species)
	call SetBattlerPicSpecies
;> if wLinkFlags & 0x02:                             # this Game Boy drives the link
	ld a, [wLinkFlags]
	bit 1, a
	ld a, b
	jr z, .notMaster

;>     if pos >= 3:
;>@r1         return
	cp $03
	jr nc, .done

;>     slot = pos
	jr .draw

;> else:
;>@nm     if pos < 4 or pos == 7:
.notMaster
;=@nm
	cp $04
	jr c, .done

	cp $07
	jr z, .done

;>@r2         return
;>     slot = pos - 4
	sub $04

.draw
;>@d dest = 0x9000 + 0x240 * slot
	push bc
	ld bc, $0240
	call Multiply24
	ld bc, $9000
	add hl, bc
	pop bc
;>@r ref = mem16[ActorGfx + 0xC0 + 2 * species]
	push hl
	ld l, c
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(ActorGfx + $c0)
;=@r
	ld l, a
	ld a, h
	adc HIGH(ActorGfx + $c0)
	ld h, a
	ld e, [hl]
	inc hl
;=@r
	ld d, [hl]
	pop hl
;> DecompressVRAM(hi(ref), lo(ref), dest)
	call DecompressVRAM
;> SetBattlePicPalettes()
	ld hl, far_SetBattlePicPalettes
	rst $10
;> UploadCGBPalettes()
	ld hl, far_UploadCGBPalettes
	rst $10

.done
;=@r1
;=@r2
;> return
	ret


;@ def SetBattlerPicSpecies(pos: b, species: c)
;@ path: battle/screen
;@ Game Boy Color only: notes the species shown at battle position `pos` in the table at $DB00
;@ of WRAM bank 2 (read when the battle palettes are built).
;@ test: skip writes to WRAM bank 2
SetBattlerPicSpecies::
;> if not wOnCGB:
;>     return
	ld a, [wOnCGB]
	or a
	ret z

;> rSVBK = 2
	ld a, $02
	ldh [rSVBK], a
;>@w mem[0xDB00 + pos] = species                     # WRAM bank 2
	ld a, b
	ld hl, $db00
	add l
	ld l, a
	ld a, $00
	adc h
;=@w
	ld h, a
	ld [hl], c
;> rSVBK = 0
	ld a, $00
	ldh [rSVBK], a
;> return
	ret


;@ def GetBaseMaxHP(pos: a) -> bc
;@ path: battle/skills/effects/special
;@ The maximum HP the monster at battle position `pos` has without battle changes (the far
;@ routine of bank $57 works it out into wBattleTemp / wBattleTempHigh), at most 999.
GetBaseMaxHP::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> Call_57_4136()
	ld hl, far_Call_57_4136
	rst $10
;> value = wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
;> return min(value, 999)
	ld hl, $03e7
	call CompareHLBC
	jr nc, .ok

	ld bc, $03e7

.ok
	pop hl
	ret


;@ def GetBaseMaxMP(pos: a) -> bc
;@ path: battle/skills/effects/special
;@ The maximum MP of the monster at battle position `pos` without battle changes (bank $57).
GetBaseMaxMP::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> Call_57_4192()
	ld hl, far_Call_57_4192
	rst $10
;> return wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


;@ def GetBaseAttack(pos: a) -> bc
;@ path: battle/skills/effects/special
;@ The attack of the monster at battle position `pos` without battle changes (bank $57).
GetBaseAttack::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> Call_57_41EE()
	ld hl, far_Call_57_41EE
	rst $10
;> return wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


;@ def GetBaseDefense(pos: a) -> bc
;@ path: battle/skills/effects/special
;@ The defense of the monster at battle position `pos` without battle changes (bank $57).
GetBaseDefense::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> Call_57_424A()
	ld hl, far_Call_57_424A
	rst $10
;> return wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


;@ def GetBaseAgilityTemp() -> bc
;@ path: battle/skills/effects/special
;@ Far entry 4: GetBaseAgility for the battle position in wBattleTemp.
GetBaseAgilityTemp::
;> return GetBaseAgility(wBattleTemp)
	ld a, [wBattleTemp]

;@ def GetBaseAgility(pos: a) -> bc
;@ path: battle/skills/effects/special
;@ The agility of the monster at battle position `pos` without battle changes (bank $57).
GetBaseAgility::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> Call_57_42A6()
	ld hl, far_Call_57_42A6
	rst $10
;> return wBattleTemp | wBattleTempHigh << 8
	ld a, [wBattleTemp]
	ld c, a
	ld a, [wBattleTempHigh]
	ld b, a
	pop hl
	ret


;@ def LoadBattlerResistances(pos: a) -> hl
;@ path: battle/skills/effects/special
;@ Address of the resistance list of the monster at battle position `pos`: for an own monster
;@ (0-2) and for the other side of a link battle its record field (PartyMonsterField
;@ wMonResist); for a called monster (position 3 or 7) and for wild enemies the monster's
;@ template is loaded (species $100 + wBattlerSpecies, or the encounter's wEncSpecies entry)
;@ and its stats looked up: wMonResistances.
;@ test: skip loads monster templates from other banks
LoadBattlerResistances::
;>@i if pos < 3 or ((pos & 3) != 3 and wLinkActive):
;>@p     return PartyMonsterField(pos, wMonResist)
	ld b, a
	cp $03
	jr c, .party

	and $03
	cp $03
	jr z, .called

;=@i
	ld a, [wLinkActive]
	or a
	ld a, b
	jr nz, .party

;>@c if (pos & 3) == 3:
;>@c1     mon = 0x100 | wBattlerSpecies[pos]
;> else:
;>     mon = mem16[wEncSpecies + 2 * (pos & 3)]
	and $03
	ld hl, wEncSpecies
	call GetWordAt

.load
;> wNewMonId = mon
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> wMonSpecies = wNewMonNameText
	ld a, [wNewMonNameText]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> return wMonResistances
	ld hl, wMonResistances
	jr .done

.party
;=@p
	ld hl, wMonResist
	call PartyMonsterField
	jr .done

.called
;=@c
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
;=@c1
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .load

.done
	ret


;@ def FindBattlerSkills(pos: a) -> (hl, b)
;@ path: battle/skills/effects/special
;@ The skill list of the monster at battle position `pos` and its length: for an own monster
;@ (and the other side of a link battle) the record's 8 skills (wMonSkills field); for a
;@ called monster or a wild enemy the 4 skills of its template (wTemplateSkills).
;@ test: skip loads monster templates from other banks
FindBattlerSkills::
;>@i if pos < 3 or ((pos & 3) != 3 and wLinkActive):
;>@p     return PartyMonsterField(pos, wMonSkills), 8
	ld b, a
	cp $03
	jr c, .party

	and $03
	cp $03
	jr z, .called

;=@i
	ld a, [wLinkActive]
	or a
	ld a, b
	jr nz, .party

;>@c if (pos & 3) == 3:
;>@c1     mon = 0x100 | wBattlerSpecies[pos]
;> else:
;>     mon = mem16[wEncSpecies + 2 * (pos - 4)]
	sub $04
	ld hl, wEncSpecies
	call GetWordAt

.load
;> wNewMonId = mon
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> return wTemplateSkills, 4
	ld hl, wTemplateSkills
	ld b, $04
	jr .done

.party
;=@p
	ld hl, wMonSkills
	call PartyMonsterField
	ld b, $08
	jr .done

.called
;=@c
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
;=@c1
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .load

.done
	ret


;@ def MarkStatUp(pos: a)
;@ path: battle/skills/effects/status
;@ Notes that a stat of battle position `pos` went up (bit 6 of status byte 6).
MarkStatUp::
;> wBattlerStatus[8 * pos + 6] |= 0x40
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 6, [hl]
	pop hl
;> return
	ret


;@ def MarkStatDown(pos: a)
;@ path: battle/skills/effects/status
;@ Notes that a stat of battle position `pos` went down (bit 7 of status byte 6).
MarkStatDown::
;> wBattlerStatus[8 * pos + 6] |= 0x80
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	set 7, [hl]
	pop hl
;> return
	ret


;@ def MarkStatsChanged(pos: a)
;@ path: battle/skills/effects/status
;@ Notes that stats of battle position `pos` went both up and down (bits 6-7 of status
;@ byte 6), as after Transform.
MarkStatsChanged::
;> wBattlerStatus[8 * pos + 6] |= 0xC0
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	ld a, [hl]
	or $c0
	ld [hl], a
;=@x
	pop hl
;>@x return
	ret


;@ def SkillDamageByKind()
;@ path: battle/skills/damage
;@ Far entry 3, used by the battle AI of bank $58: works out the damage of skill wSkillId with
;@ the damage routine of its kind (SkillDamageRoutines): kind 0 (CalcAttackDamage) for the
;@ spells and other skills below $3A and for Whistle ($7E); $3A-$3F -> 0-5, EvilSlash $40 -> 5,
;@ $41-$4F -> 3-$11 (the slashes FireSlash to CleanCut get their own routine), $50-$54 -> $11,
;@ $55-$57 -> $13-$15, $58-$66 -> $14 (CalcLevelDamage), $67-$D5 -> wSkillId - $51 (which
;@ indexes past the 28 entries from $6D on), $D6-$DC -> $19-$1F (one entry later than the
;@ routines Smashlime, Sheldodge and Branching use themselves), the rest $1B.
;@ test: skip jumps through a table of routines
SkillDamageByKind::
;>@k1 if wSkillId < 0x3A or wSkillId == 0x7E:
	ld a, [wSkillId]
	cp $3a
	jr c, .kind0

	cp $7e
	jr z, .kind0

;>@k1a     kind = 0
;>@k2 elif wSkillId <= 0x40:
	cp $40
	jr c, .from3A

;=@k2
	jr z, .evilSlash

;>@k2a     kind = 5 if wSkillId == 0x40 else wSkillId - 0x3A
;>@k3 elif wSkillId < 0x50:
	cp $50
	jr c, .from3E

;>@k3a     kind = wSkillId - 0x3E
;>@k4 elif wSkillId < 0x55:
	cp $55
	jr c, .kind11

;>@k4a     kind = 0x11
;>@k5 elif wSkillId < 0x58:
	cp $58
	jr c, .from42

;>@k5a     kind = wSkillId - 0x42
;>@k6 elif wSkillId < 0x67:
	cp $67
	jr c, .kind14

;>@k6a     kind = 0x14
;>@k7 elif wSkillId < 0xD6:
	cp $d6
	jr c, .from51

;>@k7a     kind = wSkillId - 0x51
;>@k8 elif wSkillId < 0xDD:
	cp $dd
	jr c, .fromBD

;>@k8a     kind = wSkillId - 0xBD
;> else:
;>     kind = 0x1B
	ld a, $1b
	jr .jump

.from3A
;=@k2a
	sub $3a
	jr .jump

.evilSlash
;=@k2a
	ld a, $05
	jr .jump

.from3E
;=@k3a
	sub $3e
	jr .jump

.kind11
;=@k4a
	ld a, $11
	jr .jump

.from42
;=@k5a
	sub $42
	jr .jump

.kind14
;=@k6a
	ld a, $14
	jr .jump

.from51
;=@k7a
	sub $51
	jr .jump

.fromBD
;=@k8a
	sub $bd
	jr .jump

.kind0
;=@k1a
	ld a, $00

.jump
;> return JumpToPointer(SkillDamageRoutines + 2 * kind)
	ld c, a
	ld b, $00
	ld hl, SkillDamageRoutines
	add hl, bc
	add hl, bc
	jp JumpToPointer


;@ path: battle/skills/damage
;@ Damage routine of each skill kind (index from SkillDamageByKind), 28 entries; a lone `ret`
;@ byte follows.
SkillDamageRoutines::
	dw CalcAttackDamage            ; 0 attacks, spells
	dw CalcAttackDamage            ; 1 TwinSlash
	dw CalcHPFractionDamage        ; 2 Ramming
	dw CalcAttackDamage            ; 3 Beserker, ChargeUP
	dw CalcLeaveOneHPDamage        ; 4 Kamikaze, HighJump
	dw CalcAttackDamage            ; 5 Massacre, EvilSlash, SuckAir
	dw CalcAttackDamageRes0        ; 6 FireSlash
	dw CalcAttackDamageRes4        ; 7 BoltSlash
	dw CalcAttackDamageRes3        ; 8 VacuSlash
	dw CalcAttackDamageRes5        ; 9 IceSlash
	dw CalcAttackDamageVsType0     ; $0A MetalCut
	dw CalcDragonSlayerDamage      ; $0B DrakSlash
	dw CalcBeastSlayerDamage       ; $0C BeastCut
	dw CalcBirdSlayerDamage        ; $0D BirdBlow
	dw CalcDevilSlayerDamage       ; $0E DevilCut
	dw CalcZombieSlayerDamage      ; $0F ZombieCut
	dw CalcMaterialSlayerDamage    ; $10 CleanCut
	dw CalcAttackDamage            ; $11 MultiCut, BiAttack-Focus
	dw CalcAttackDamage            ; $12
	dw CalcAttackDamage            ; $13 SquallHit
	dw CalcLevelDamage             ; $14 PsycheUp, WindBeast-MegaMagic
	dw CalcAttackDamage            ; $15 RainSlash
	dw CalcAttackDamage            ; $16 PoisonHit
	dw CalcAttackDamage            ; $17 NapAttack
	dw CalcSlimeSlayerDamage       ; $18 Paralyze ($69)
	dw CalcBugSlayerDamage         ; $19 SleepAir, Smashlime
	dw CalcPlantSlayerDamage       ; $1A PalsyAir, Sheldodge
	dw CalcAttackDamage            ; $1B PoisonGas, Branching, skills $DD and up
	db $c9

;@ def TargetStatus3() -> hl
;@ path: battle/state
;@ Address of the target's status byte 3 (the same as GetTargetStatus3).
TargetStatus3::
;> return wBattlerStatus3 + 8 * wSkillTarget       # address
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus3
	call AddEightTimes
	ret


;@ def UnusedCheckSkillUsable() -> zero
;@ path: unused/battle
;@ Not called: for a user of intelligence class 1 or 2, reads byte 2 of the skill's table
;@ record (GetSkillWord); without its bit 1 the target picker of bank $58 runs. Zero only
;@ for intelligence class 0.
;@ test: skip far calls into the skill table and target picker
UnusedCheckSkillUsable::
;>@ic if wBattlerIntClass[wSkillUser] == 0:
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@ic
	ld h, a
	ld a, [hl]
	or a
	ret z

;>@ic1     return True
;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 2
	ld a, $02
	ld [wBattleArg2], a
;> GetSkillWord()
	ld hl, far_GetSkillWord
	rst $10
;> if wBattleArg0 & 0x02:
;>     return False
	ld a, [wBattleArg0]
	and $02
	ret nz

;> RunTargetPicker()
	ld hl, far_RunTargetPicker
	rst $10
;> return False
	ld a, $01
	or a
	ret

;@ def SkillFails(msg: a)
;@ path: battle/skills/result
;@ The skill fails with battle message `msg` (wSkillResult $80: no hit, the miss message is
;@ shown after the skill's own text).
;@ The results the effect routines leave, bits of wSkillResult: 7 with bit 6 print the message
;@ at once, 6 end the action here without the hit, 5 the amount (wSkillAmount) is damage taken
;@ from the target (bit 4 is then set when it is not 0), 4 the skill worked (hit effect and
;@ wSkillResultValue's message), 3 the message has a variant for the player's side, 2 no hit
;@ effect, 1/0 the miss/hit message is from text group 1. wSkillResultValue holds the hit
;@ message (low byte) and wSkillMsgMiss the miss message.
SkillFails::
;> wSkillResultValue = msg * 0x101
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
;> wSkillResult = 0x80
	ld a, $80
	ld [wSkillResult], a
;> return
	ret


;@ def SkillFailsSide(msg: a)
;@ path: battle/skills/result
;@ The skill fails with message `msg`, which has a variant for the player's side
;@ (wSkillResult $88).
SkillFailsSide::
;> wSkillResultValue = msg * 0x101
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
;> wSkillResult = 0x88
	ld a, $88
	ld [wSkillResult], a
;> return
	ret


;@ def SkillFailsNoAnim(msg: a)
;@ path: battle/skills/result
;@ The skill fails with message `msg` and no hit effect (wSkillResult $84).
SkillFailsNoAnim::
;> wSkillResultValue = msg * 0x101
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
;> wSkillResult = 0x84
	ld a, $84
	ld [wSkillResult], a
;> return
	ret


;@ def SkillWorksGroup1(msg: a)
;@ path: battle/skills/result
;@ The skill works with message `msg` of text group 1 (wSkillResult $93).
SkillWorksGroup1::
;> wSkillResultValue = msg * 0x101
	ld [wSkillResultValue], a
	ld [wSkillMsgMiss], a
;> wSkillResult = 0x93
	ld a, $93
	ld [wSkillResult], a
;> return
	ret


;@ def SkillEndsQuietly()
;@ path: battle/skills/result
;@ The action ends here without a message or hit (wSkillResult $40).
SkillEndsQuietly::
;> wSkillResult = 0x40
	ld a, $40
	ld [wSkillResult], a
;> return
	ret


;@ def SkillWorks(msgs: hl)
;@ path: battle/skills/result
;@ The skill works: hit message lo(msgs), miss message hi(msgs) (wSkillResult $90).
SkillWorks::
;> wSkillResult = 0x90
	ld a, $90
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> return
	ret


;@ def SkillWorksAtOnce(msgs: hl)
;@ path: battle/skills/result
;@ The skill works and its message lo(msgs) is printed at once, ending the action
;@ (wSkillResult $D0).
SkillWorksAtOnce::
;> wSkillResult = 0xD0
	ld a, $d0
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> return
	ret


;@ def SkillWorksSide(msgs: hl)
;@ path: battle/skills/result
;@ The skill works; its message has a variant for the player's side (wSkillResult $98).
SkillWorksSide::
;> wSkillResult = 0x98
	ld a, $98
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> return
	ret


;@ def SkillWorksNoDamage(msgs: hl)
;@ path: battle/skills/result
;@ SkillWorks with wSkillAmount cleared.
SkillWorksNoDamage::
;> wSkillResult = 0x90
	ld a, $90
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> wSkillAmount = 0
	xor a
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a
;> return
	ret


;@ def SkillWorksSideNoDamage(msgs: hl)
;@ path: battle/skills/result
;@ SkillWorksSide with wSkillAmount cleared.
SkillWorksSideNoDamage::
;> wSkillResult = 0x98
	ld a, $98
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> wSkillAmount = 0
	xor a
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a
;> return
	ret


;@ def SkillDealsDamage()
;@ path: battle/skills/result
;@ The usual end of a damage skill: SkillDealsDamageMsg with "X takes N damage pts!" ($82) or,
;@ for 0 damage, "Has no effect on X!" ($B8).
SkillDealsDamage::
;> SkillDealsDamageMsg(0xB882)                       # (falls through)
	ld hl, $b882
;> return

;@ def SkillDealsDamageMsg(msgs: hl)
;@ path: battle/skills/result
;@ The skill does wSkillAmount damage to the target (wSkillResult $A8: damage, side variant):
;@ hit message lo(msgs), miss message hi(msgs) for 0 damage.
SkillDealsDamageMsg::
;> wSkillResult = 0xA8
	ld a, $a8
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> return
	ret


;@ def SkillDealsDamageNoSide(msgs: hl)
;@ path: battle/skills/result
;@ Like SkillDealsDamageMsg without the side variant (wSkillResult $A0).
SkillDealsDamageNoSide::
;> wSkillResult = 0xA0
	ld a, $a0
	ld [wSkillResult], a
;> wSkillResultValue = msgs
	ld a, l
	ld [wSkillResultValue], a
	ld a, h
	ld [wSkillMsgMiss], a
;> return
	ret


;@ def ShowIronizeMessage()
;@ path: battle/skills/effects/status
;@ The message after Ironize: "X turns into an iron lump!" ($94) when one monster of the
;@ user's side is in the fight (always for a wild enemy), else "X's gang become iron lumps!"
;@ ($93).
ShowIronizeMessage::
;> if wSkillUser < 4:
	ld a, [wSkillUser]
	cp $04
	jr nc, .enemy

;>     first = 0
	ld bc, $0300
	jr .count

;> elif not wLinkActive:
;>@one     return SkillWorks(0x9494)
.enemy
	ld a, [wLinkActive]
	or a
	jr z, .one

;> else:
;>     first = 4
	ld bc, $0304

.count
;> n = 0
	ld d, $00

;>@loop for pos in range(first, first + 3):
.loop
;>     if not CheckBattlerPresent(pos):
	ld a, c
	call CheckBattlerPresent
	jr c, .next

;>         n += 1
	inc d

.next
;=@loop
	inc c
	dec b
	jr nz, .loop

;> if n == 1:
;>@one2     return SkillWorks(0x9494)                 # "X turns into an iron lump!"
	ld a, d
	cp $01
	jr z, .one

;> SkillWorks(0x9393)                                # "X's gang become iron lumps!"
	ld hl, $9393
	jr .msg

.one
;=@one
;=@one2
	ld hl, $9494

.msg
	call SkillWorks
;> return
	ret


;@ def HalveDamageBehindVeil()
;@ path: battle/skills/damage
;@ Halves wSkillAmount when the target is behind a veil of light (Barrier, bit 2 of status
;@ byte 2).
HalveDamageBehindVeil::
;> if not wBattlerStatus[8 * wSkillTarget + 2] & 0x04:
;>     return
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus2
	call AddEightTimes
	bit 2, [hl]
	ret z

;>@h wSkillAmount >>= 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call ShiftHL1
;=@h
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> return
	ret


;@ def BattleRandom() -> a
;@ path: battle/skills/effects
;@ The battle's random number (Random). In a link battle both Game Boys draw from the shared
;@ state wLinkRandom, so they roll the same numbers.
;@ test: skip draws from the random number generator
BattleRandom::
;> if not wLinkActive:
;>     return Random()
	ld a, [wLinkActive]
	or a
	jr nz, .link

	call Random
	ret


.link
;>@rh wRandomHigh = lo(wLinkRandom)
	push hl
	ld a, [wLinkRandom]
	ld l, a
	ld a, [wLinkRandom + 1]
	ld h, a
	ld a, l
;=@rh
	ld [wRandomHigh], a
;> wRandomLow = hi(wLinkRandom)
	ld a, h
	ld [wRandomLow], a
;> Random()
	call Random
;>@lr wLinkRandom = wRandomHigh | wRandomLow << 8
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, l
	ld [wLinkRandom], a
;=@lr
	ld a, h
	ld [wLinkRandom + 1], a
;> return wRandomHigh
	pop hl
	ret


;@ def UseBattleItem()
;@ path: battle/item/effects
;@ Uses the battle item chosen this turn: the target is wBattleItemTarget, the effect number
;@ wBattleItemEffect ($B0 and up, also in wBattleArg0) picks the routine from
;@ BattleItemEffects. A target that is no longer in the fight gives "X isn't revived!"
;@ instead - except for WorldLeaf ($BB), which revives.
;@ test: skip jumps through the item effect table
UseBattleItem::
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wSkillTarget = wBattleItemTarget
	ld a, [wBattleItemTarget]
	ld [wSkillTarget], a
;> wBattleArg0 = wBattleItemEffect
	ld a, [wBattleItemEffect]
	ld [wBattleArg0], a
;> effect = GetWordAt(wBattleItemEffect - 0xB0, BattleItemEffects)
	sub $b0
	ld hl, BattleItemEffects
	call GetWordAt
;> if wBattleItemEffect == 0xBB or not CheckBattlerPresent(wSkillTarget):
	ld a, [wBattleItemEffect]
	cp $bb
	ld a, [wSkillTarget]
	jr z, .use

	call CheckBattlerPresent
	jr c, .gone

;>@u     return JumpToItemEffect(effect)
.use
;=@u
	call JumpToItemEffect
	ret


.gone
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;> wTextIndex = 0xBF                                 # "X isn't revived!"
	ld a, $bf
	ld [wTextIndex], a
;> return
	ret


;@ def JumpToItemEffect(effect: hl)
;@ path: battle/item/effects
;@ `jp hl`: runs the item effect routine at `effect`.
;@ test: skip jumps to a computed address
JumpToItemEffect::
;> return goto(effect)
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
	call CheckUserNudgeBit2
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
	call CheckUserNudgeBit2
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
	call CheckUserNudgeBit2
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
	call CheckUserNudgeBit2
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
	call CheckUserNudgeBit2
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
	call CheckUserNudgeBit2
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
	call CheckUserNudgeBit2
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


;@ def CalcLevelDamageRes24()
;@ path: battle/skills/damage
;@ Damage from the user's level (CallHelp): twice the level, for a wild enemy
;@ 1.5 times; then cut by the target's resistance 24 (ResistDamageA).
CalcLevelDamageRes24::
;>@l level = wBattlerLevel[wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;=@l
	ld h, a
	ld l, [hl]
	ld h, $00
;> if not wLinkActive and wSkillUser >= 4:
	ld a, [wLinkActive]
	or a
	jr nz, .double

	ld a, [wSkillUser]
	cp $04
	jr c, .double

;>@h     dmg = level + (level >> 1)
	ld a, l
	srl a
	add l
	ld l, a
	ld a, h
	adc $00
;=@h
	ld h, a
	jr .store

;> else:
;>     dmg = 2 * level
.double
	add hl, hl

.store
;> wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@r ResistDamageA(GetTargetStatus3(), GetResistByte6() >> 4 & 3)
	call GetTargetStatus3
	call GetResistByte6
	swap a
	and $03
	call ResistDamageA
;=@r
	ret


;@ def CalcLevelDamage()
;@ path: battle/skills/damage
;@ Damage from the user's level (WindBeast): three times the level plus 10, for a
;@ wild enemy 1.5 times the level, at most 180. A random amount of up to 15% of
;@ that is added or taken off, then the target's Infernos resistance counts
;@ (InfernosResistDamage).
CalcLevelDamage::
;>@l level = wBattlerLevel[wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;=@l
	ld h, a
	ld l, [hl]
	ld h, $00
	ld b, h
	ld c, l
;> if not wLinkActive and wSkillUser >= 4:
	ld a, [wLinkActive]
	or a
	jr nz, .own

	ld a, [wSkillUser]
	cp $04
	jr c, .own

;>@w     dmg = level + (level >> 1)
	call ShiftBC1
	jr .cap

;> else:
;>@o     dmg = 3 * level + 10
.own
	add hl, bc
	add hl, bc
	ld bc, $000a

.cap
;=@w
	add hl, bc
;> dmg = min(dmg, 180)
	ld bc, $00b4
	call CompareHLBC
	jr c, .store

	ld hl, $00b4

.store
;> wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> spread = Percent30(dmg)
	call Percent30
	ld b, h
	ld c, l
;> BattleRandom()
	call BattleRandom
;> r = DivideHLBC(wRandomLow << 8 | wRandomHigh, spread)[1]
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
;> if r & 1:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	sra b
	rr c
;=@i
	jr nc, .plus

;>@i     dmg = (dmg - (r >> 1)) & 0xFFFF
	ld a, l
	sub c
	ld c, a
	ld a, h
	sbc b
	ld b, a
;=@i
	jr .done

;> else:
;>     dmg = dmg + (r >> 1)
.plus
	add hl, bc
	ld b, h
	ld c, l

.done
;> wSkillAmount = dmg
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
;> InfernosResistDamage(GetTargetStatus3())
	call GetTargetStatus3
	call InfernosResistDamage
	ret


;@ def CalcLevelDamage2()
;@ path: battle/skills/damage
;@ Damage from the user's level (WindBeast used by an enemy): twice the level
;@ plus 30, at most 150, with a random amount of up to a tenth added or taken
;@ off (taking off stops at 0), then the target's Infernos resistance counts.
;@ The check meant to give wild enemies 1.5 times the level compares
;@ wLinkActive instead of the user's position, so it never picks that.
CalcLevelDamage2::
;>@l level = wBattlerLevel[wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;=@l
	ld h, a
	ld l, [hl]
	ld h, $00
;> if not wLinkActive and wLinkActive >= 4:   # never true
	ld a, [wLinkActive]
	or a
	jr nz, .own

	cp $04
	jr c, .own

;>@w     dmg = level + (level >> 1)
	ld b, h
	ld c, l
	call ShiftBC1
	jr .cap

;> else:
;>@o     dmg = 2 * level + 30
.own
	add hl, hl
	ld bc, $001e

.cap
;=@w
	add hl, bc
;> dmg = min(dmg, 150)
	ld bc, $0096
	call CompareHLBC
	jr c, .store

	ld hl, $0096

.store
;> wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> spread = Divide16(dmg, 5)[0]
	ld a, $05
	call Divide16
	ld b, h
	ld c, l
;> BattleRandom()
	call BattleRandom
;> r = DivideHLBC(wRandomLow << 8 | wRandomHigh, spread)[1]
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
;> if not r & 1:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	sra b
	rr c
;=@i
	jr c, .minus

;>@i     wSkillAmount = dmg + (r >> 1)
	add hl, bc
	jr .done

;> elif dmg >= r >> 1:
;>@m     wSkillAmount = dmg - (r >> 1)
.minus
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;=@m
	jr c, .resist

.done
;=@i
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.resist
;> InfernosResistDamage(GetTargetStatus3())
	call GetTargetStatus3
	call InfernosResistDamage
	ret


;@ def CalcSkillDamageRes24()
;@ path: battle/skills/damage
;@ Spell damage from the skill table (RockThrow), then the target's resistance
;@ 24 counts (ResistDamageB).
CalcSkillDamageRes24::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageB(status, GetResistByte6() >> 4 & 3)
	call GetResistByte6
	swap a
	and $03
	call ResistDamageB
	ret


;@ def CalcSkillDamageRes16()
;@ path: battle/skills/damage
;@ Spell damage from the skill table (FireAir), then the target's resistance 16
;@ counts (ResistDamageB).
CalcSkillDamageRes16::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageB(status, GetResistByte4() >> 4 & 3)
	call GetResistByte4
	swap a
	and $03
	call ResistDamageB
	ret


;@ def CalcSkillDamageRes17()
;@ path: battle/skills/damage
;@ Spell damage from the skill table (FrigidAir), then the target's resistance
;@ 17 counts (ResistDamageB).
CalcSkillDamageRes17::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageB(status, GetResistByte4() >> 2 & 3)
	call GetResistByte4
	rrca
	rrca
	and $03
	call ResistDamageB
	ret


;@ def CalcSkillDamageRes0()
;@ path: battle/skills/damage
;@ Spell damage from the skill table (BigBang), then the target's resistance 0
;@ (Blaze) counts (ResistDamageB).
CalcSkillDamageRes0::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageB(status, GetResistByte0() >> 4 & 3)
	call GetResistByte0
	swap a
	and $03
	call ResistDamageB
	ret


;@ def CalcMPLevelDamage()
;@ path: battle/skills/damage
;@ MegaMagic: twice the user's MP plus twice its level, with a random amount of
;@ up to a tenth added or taken off, then the target's resistance 15 counts
;@ (ResistDamageB).
CalcMPLevelDamage::
;>@a wSkillAmount = 2 * GetBattlerMP(wSkillUser) & 0xFFFF
	ld a, [wSkillUser]
	ld e, a
	call GetBattlerMP
	add hl, hl
	ld a, l
	ld [wSkillAmount], a
;=@a
	ld a, h
	ld [wSkillAmount + 1], a
;>@m dmg = (2 * wBattlerLevel[wSkillUser] + wSkillAmount) & 0xFFFF
	ld a, e
	ld hl, wBattlerLevel
	add l
	ld l, a
	ld a, $00
	adc h
;=@m
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	ld a, [wSkillAmount]
	ld c, a
;=@m
	ld a, [wSkillAmount + 1]
	ld b, a
	add hl, bc
;> wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> spread = Percent40(dmg) >> 2
	call Percent40
	call ShiftHL2
;> if spread:
	ld a, l
	or h
	jr z, .resist

;>     BattleRandom()
	ld b, h
	ld c, l
	call BattleRandom
;>@r     r = DivideHLBC(wRandomLow << 8 | wRandomHigh, spread)[1]
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	call DivideHLBC
;>@d     if wRandomHigh & 1:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [wRandomHigh]
	and $01
;=@d
	jr z, .plus

;>@s         dmg = (dmg - r) & 0xFFFF
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;=@s
	jr .store

;>     else:
;>         dmg = (dmg + r) & 0xFFFF
.plus
	add hl, bc

.store
;>     wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a

.resist
;>@x ResistDamageB(GetTargetStatus3(), GetResistByte4() >> 6)
	call GetTargetStatus3
	call GetResistByte4
	rlca
	rlca
	and $03
	call ResistDamageB
;=@x
	ret


;@ def TryEffectRes19() -> carry
;@ path: battle/skills/chance
;@ Whether a paralysing skill (PalsyAir) takes hold: not on bosses in scripted
;@ battles (CheckSkillAllowed), else by the target's resistance 19
;@ (ResistChanceC). Carry when it works.
TryEffectRes19::
;> if not CheckSkillAllowed():
;>     return ReturnNoCarry()
	call CheckSkillAllowed
	jp z, ReturnNoCarry

;>@r return ResistChanceC(GetTargetStatus3(), GetResistByte5() >> 6)
	call GetTargetStatus3
	call GetResistByte5
	rlca
	rlca
	and $03
	call ResistChanceC
;=@r
	ret


;@ def TryEffectRes18() -> carry
;@ path: battle/skills/chance
;@ Whether a poisoning skill (PoisonGas) takes hold, by the target's resistance
;@ 18 (ResistChanceC).
TryEffectRes18::
;> return ResistChanceC(GetTargetStatus3(), GetResistByte4() & 3)
	call GetTargetStatus3
	call GetResistByte4
	and $03
	call ResistChanceC
	ret


;@ def TryEffectRes20() -> carry
;@ path: battle/skills/chance
;@ Whether a curse (Curse) takes hold, by the target's resistance 20
;@ (ResistChanceC).
TryEffectRes20::
;> return ResistChanceC(GetTargetStatus3(), GetResistByte5() >> 4 & 3)
	call GetTargetStatus3
	call GetResistByte5
	swap a
	and $03
	call ResistChanceC
	ret


;@ def TryEffectRes21() -> carry
;@ path: battle/skills/chance
;@ Whether one of the dance and trick skills (Ahhh, LureDance, LushLicks, LegSweep,
;@ WarCry) takes hold, by the target's resistance 21: with ResistChanceA for
;@ skills below $7C, ResistChanceC from $7C on.
TryEffectRes21::
;> status = GetTargetStatus3()
	call GetTargetStatus3
;>@l level = GetResistByte5() >> 2 & 3
	call GetResistByte5
	rrca
	rrca
	and $03
	ld b, a
;> if wSkillId < 0x7C:
	ld a, [wSkillId]
	cp $7c
	ld a, b
	jr nc, .harder

;>     return ResistChanceA(status, level)
	call ResistChanceA
	jr .done

;> return ResistChanceC(status, level)
.harder
	call ResistChanceC

.done
	ret


;@ def TryEffectRes21NotType4() -> carry
;@ path: battle/skills/chance
;@ TryEffectRes21, but never on a target with bit 4 of its type bits
;@ (wBattlerTypeBits); LegSweep uses it.
TryEffectRes21NotType4::
;>@t if wBattlerTypeBits[wSkillTarget] & 0x10:
	ld a, [wSkillTarget]
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	bit 4, [hl]
;>     return False
	ret nz

;> return TryEffectRes21()
	call TryEffectRes21
	ret


;@ def CanLowerTargetStats() -> carry
;@ path: battle/skills/effects
;@ No carry only when there is nothing left to lower (UltraDown): the target's
;@ defense and agility are both 1 and bit 1 of its status byte 1 (illusion,
;@ Surround) is set.
CanLowerTargetStats::
;>@d if mem16[wBattlerDefense + 2 * wSkillTarget] != 1:
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;=@d
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
;=@d
	ld a, b
	or c
;>@y     return True
	jr nz, .yes

;>@a if mem16[wBattlerAgility + 2 * wSkillTarget] != 1:
	ld a, $0f
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	dec bc
	ld a, b
	or c
;>@y2     return True
	jr nz, .yes

;>@s return not (mem[wBattlerStatus1 + 8 * wSkillTarget] & 0x02)
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 1, [hl]
	jr z, .yes

;=@s
	xor a
	ret


.yes
;=@y
	scf
	ret


;@ def SetUpCalledMonster()
;@ path: battle/skills/effects
;@ Brings in the monster a calling skill summons: skills $84, $85 and $86 each
;@ set up their own one (SetUpCalledMonster1-3), the others the fourth kind.
;@ The called monster's place (position 3 of the user's side) starts with all
;@ status bytes clear.
SetUpCalledMonster::
;> if wSkillId == 0x84:
	ld a, [wSkillId]
	cp $84
;>@1     SetUpCalledMonster1()
	jr z, .one

;> elif wSkillId == 0x85:
	cp $85
;>@2     SetUpCalledMonster2()
	jr z, .two

;> elif wSkillId == 0x86:
	cp $86
;>@3     SetUpCalledMonster3()
	jr z, .three

;> else:
;>     SetUpCalledMonster4()
	ld hl, far_SetUpCalledMonster4
	rst $10
	jr .clear

.one
;=@1
	ld hl, far_SetUpCalledMonster1
	rst $10
	jr .clear

.two
;=@2
	ld hl, far_SetUpCalledMonster2
	rst $10
	jr .clear

.three
;=@3
	ld hl, far_SetUpCalledMonster3
	rst $10

.clear
;> status = wBattlerStatus + 8 * (wSkillUser & 4 | 3)
	ld a, [wSkillUser]
	and $04
	or $03
	ld hl, wBattlerStatus
	call AddEightTimes
;>@f fill(status, 8, 0)
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@f
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret


;@ def TransformUserPic()
;@ path: battle/skills/effects
;@ Changes the skill's user (TransformSkillUser) and loads picture $C9 for it.
TransformUserPic::
;> TransformSkillUser()
	ld hl, far_TransformSkillUser
	rst $10
;> LoadBattlerPic(wSkillUser, 0xC9)
	ld c, $c9
	ld a, [wSkillUser]
	ld b, a
	call LoadBattlerPic
	ret


;@ def TryEffectRes22() -> carry
;@ path: battle/skills/chance
;@ Whether DanceShut takes hold, by the target's resistance 22 (ResistChanceA).
TryEffectRes22::
;> return ResistChanceA(GetTargetStatus3(), GetResistByte5() & 3)
	call GetTargetStatus3
	call GetResistByte5
	and $03
	call ResistChanceA
	ret


;@ def TryEffectRes23() -> carry
;@ path: battle/skills/chance
;@ Whether MouthShut takes hold, by the target's resistance 23 (ResistChanceA).
TryEffectRes23::
;>@r return ResistChanceA(GetTargetStatus3(), GetResistByte6() >> 6)
	call GetTargetStatus3
	call GetResistByte6
	rlca
	rlca
	and $03
	call ResistChanceA
;=@r
	ret


;@ def CalcSkillDamageRes25()
;@ path: battle/skills/damage
;@ GigaSlash: damage from the skill table, then the target's resistance 25
;@ counts (ResistDamageA).
CalcSkillDamageRes25::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageA(status, GetResistByte6() >> 2 & 3)
	call GetResistByte6
	rrca
	rrca
	and $03
	call ResistDamageA
	ret


;@ def CalcAttack400Damage()
;@ path: battle/skills/damage
;@ A normal attack worked out as if the user's attack were 400 (CallEvil); its
;@ real attack is put back afterwards.
CalcAttack400Damage::
;> ptr = wBattlerAttack + 2 * wSkillUser
;> atk = mem16[ptr]
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call IndexWords
	push hl
	ld a, [hli]
	ld b, [hl]
;>@s mem16[ptr] = 400
	ld c, a
	push bc
	ld a, $01
	ld [hld], a
	ld [hl], $90
;> SkillAttackDamage()
	call SkillAttackDamage
;> mem16[ptr] = atk
	pop bc
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	ret


;@ def CalcSkillAmount() -> hl
;@ path: battle/skills/damage
;@ The base amount of the skill being used into wSkillAmount: the skill table
;@ (GetSkillValue) has a value and a random spread for own monsters (field $0B)
;@ and for wild enemies (field $0F); AddSkillSpread adds the random part. Runs on
;@ into GetTargetStatus3, so it returns the target's status byte 3.
CalcSkillAmount::
;> wBattleArg0 = wSkillId
;> wBattleArg1 = 0
	ld a, [wSkillId]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
;> if not wLinkActive and wSkillUser & 4:
;>@w     wBattleArg2 = 0x0F                    # wild enemy
	ld a, [wLinkActive]
	or a
	jr nz, .own

	ld a, [wSkillUser]
	bit 2, a
	jr z, .own

;=@w
	ld a, $0f
	jr .get

;> else:
;>@o     wBattleArg2 = 0x0B                    # own monster or link battle
.own
	ld a, $0b

.get
;=@w
	ld [wBattleArg2], a
;> GetSkillValue()
	ld hl, far_GetSkillValue
	rst $10
;> AddSkillSpread(wBattleArg1 << 8 | wBattleArg0)
;> return GetTargetStatus3()                 # runs on into it
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	call AddSkillSpread

;@ def GetTargetStatus3() -> hl
;@ path: battle/state
;@ Address of the skill target's status byte 3 (wBattlerStatus3: magic wall,
;@ open to spells and the like), which the resistance routines read.
GetTargetStatus3::
;> return u16(wBattlerStatus3 + (8 * wSkillTarget & 0xFF))
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus3
	call AddEightTimes
	ret


;@ def ResistChanceA(status: hl, level: a) -> carry
;@ path: battle/skills/resist
;@ Whether a skill takes hold on a target with resistance `level` (0-3), for
;@ the easier skills: normally 100/84/50/0% (ChanceByLevel84), behind a magic
;@ wall (bit 6 of status byte 3 `status`) 100/75/40/0%, when the target is open
;@ to spells (bit 7) 100/100/75/0%.
ResistChanceA::
;> if mem[status] & 0x40:
;>@w     return ChanceByLevel75(level)
	bit 6, [hl]
	jr z, .notWall

;=@w
	call ChanceByLevel75
	jr .done

;> elif mem[status] & 0x80:
.notWall
	bit 7, [hl]
	jr z, .normal

;>     return ChanceByLevelLowered(level)
	call ChanceByLevelLowered
	jr .done

;> return ChanceByLevel84(level)
.normal
	call ChanceByLevel84

.done
	ret


	; unused: ChanceByLevel84 behind a magic wall, else ChanceByLevelLowered
	db $cb, $76, $28, $05, $cd, $ec, $67, $18, $03, $cd, $02, $68, $c9

;@ def ResistChanceB(status: hl, level: a) -> carry
;@ path: battle/skills/resist
;@ Like ResistChanceA for harder skills: normally 100/75/40/0%, behind a magic
;@ wall 75/50/25/0%, when open to spells 100/100/75/0%.
ResistChanceB::
;> if mem[status] & 0x40:
;>@w     return ChanceByLevel75Low(level)
	bit 6, [hl]
	jr z, .notWall

;=@w
	call ChanceByLevel75Low
	jr .done

;> elif mem[status] & 0x80:
.notWall
	bit 7, [hl]
	jr z, .normal

;>     return ChanceByLevelLowered(level)
	call ChanceByLevelLowered
	jr .done

;> return ChanceByLevel75(level)
.normal
	call ChanceByLevel75

.done
	ret


;@ def ResistChanceC(status: hl, level: a) -> carry
;@ path: battle/skills/resist
;@ Like ResistChanceA for the hardest skills: normally (and behind a magic
;@ wall) 75/50/25/0%, when the target is open to spells 100/84/50/0%.
ResistChanceC::
;> if mem[status] & 0x80:
;>@o     return ChanceByLevel84(level)
	bit 7, [hl]
	jr z, .normal

;=@o
	call ChanceByLevel84
	jr .done

;> return ChanceByLevel75Low(level)
.normal
	call ChanceByLevel75Low

.done
	ret


;@ def ResistDamageA(status: hl, level: a)
;@ path: battle/skills/resist
;@ Scales wSkillAmount by the target's resistance `level` (0-3): normally to
;@ 100/85/50/0%, behind a magic wall (bit 6 of status byte 3) 100/75/40/0%, when
;@ open to spells (bit 7) 131/116/75/30%.
ResistDamageA::
;> if mem[status] & 0x40:
;>@w     return DamageByLevel75(level)
	bit 6, [hl]
	jr z, .notWall

;=@w
	call DamageByLevel75
	jr .done

;> elif mem[status] & 0x80:
.notWall
	bit 7, [hl]
	jr z, .normal

;>     return DamageByLevel131(level)
	call DamageByLevel131
	jr .done

;> return DamageByLevel85(level)
.normal
	call DamageByLevel85

.done
	ret


;@ def ResistDamageB(status: hl, level: a)
;@ path: battle/skills/resist
;@ Like ResistDamageA for stronger resistances: normally 100/75/40/0%, behind a
;@ magic wall 75/50/25/0%, when open to spells 131/116/75/30%.
ResistDamageB::
;> if mem[status] & 0x40:
;>@w     return DamageByLevel75Low(level)
	bit 6, [hl]
	jr z, .notWall

;=@w
	call DamageByLevel75Low
	jr .done

;> elif mem[status] & 0x80:
.notWall
	bit 7, [hl]
	jr z, .normal

;>     return DamageByLevel131(level)
	call DamageByLevel131
	jr .done

;> return DamageByLevel75(level)
.normal
	call DamageByLevel75

.done
	ret


;@ def ResistDamageC(status: hl, level: a)
;@ path: battle/skills/resist
;@ For the elemental slashes: normally 131/116/75/30% (so a target without the
;@ resistance takes extra damage), behind a magic wall 100/85/50/0%.
ResistDamageC::
;> if mem[status] & 0x40:
;>@w     return DamageByLevel85(level)
	bit 6, [hl]
	jr z, .normal

;=@w
	call DamageByLevel85
	jr .done

;> return DamageByLevel131(level)
.normal
	call DamageByLevel131

.done
	ret


	; unused: a choice between DamageByLevel85 and DamageByLevel131 by bit 7
	db $cb, $7e, $28, $05, $cd, $3c, $68, $18, $03, $cd, $62, $68, $c9

;@ def AddSkillSpread(base: hl)
;@ path: battle/skills/damage
;@ wSkillAmount = `base` plus a random number from 0 to wBattleArg2 (the skill's
;@ spread; none when it is 0).
AddSkillSpread::
;> if wBattleArg2:
	ld a, [wBattleArg2]
	or a
	jr z, .store

;>@r     base += wRandomHigh % (wBattleArg2 + 1)
	inc a
	ld c, a
	ld a, [wRandomHigh]

.mod
;=@r
	cp c
	jr c, .add

	sub c
	jr nc, .mod

	ld a, c

.add
;=@r
	ld c, a
	ld b, $00
	add hl, bc

.store
;> wSkillAmount = base & 0xFFFF
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def GetResistByte0() -> a
;@ path: battle/skills/resist
;@ Byte 0 of the target's packed resistances (wBattlerResist, 7 bytes per
;@ position): resistance 26 in bits 6-7, 0 (Blaze) in 4-5, 1 (Firebal) in 2-3,
;@ 2 (Bang) in 0-1. Each is a level 0-3.
GetResistByte0::
;> return wBattlerResist[7 * wSkillTarget]
	ld de, wBattlerResist
	jr jr_052_67dc

;@ def GetResistByte1() -> a
;@ path: battle/skills/resist
;@ Byte 1 of the target's packed resistances: 3 (Infernos) in bits 6-7, 4 (Bolt)
;@ in 4-5, 5 (IceBolt) in 2-3, 6 in 0-1.
GetResistByte1::
;> return wBattlerResist[7 * wSkillTarget + 1]
	ld de, wBattlerResist + 1
	jr jr_052_67dc

;@ def GetResistByte2() -> a
;@ path: battle/skills/resist
;@ Byte 2 of the target's packed resistances: 7, 8, 9 and 10 from bits 6-7 down.
GetResistByte2::
;> return wBattlerResist[7 * wSkillTarget + 2]
	ld de, wBattlerResist + 2
	jr jr_052_67dc

;@ def GetResistByte3() -> a
;@ path: battle/skills/resist
;@ Byte 3 of the target's packed resistances: 11, 12, 13 and 14 from bits 6-7
;@ down.
GetResistByte3::
;> return wBattlerResist[7 * wSkillTarget + 3]
	ld de, wBattlerResist + 3
	jr jr_052_67dc

;@ def GetResistByte4() -> a
;@ path: battle/skills/resist
;@ Byte 4 of the target's packed resistances: 15, 16, 17 and 18 from bits 6-7
;@ down.
GetResistByte4::
;> return wBattlerResist[7 * wSkillTarget + 4]
	ld de, wBattlerResist + 4
	jr jr_052_67dc

;@ def GetResistByte5() -> a
;@ path: battle/skills/resist
;@ Byte 5 of the target's packed resistances: 19, 20, 21 and 22 from bits 6-7
;@ down.
GetResistByte5::
;> return wBattlerResist[7 * wSkillTarget + 5]
	ld de, wBattlerResist + 5
	jr jr_052_67dc

;@ def GetResistByte6() -> a
;@ path: battle/skills/resist
;@ Byte 6 of the target's packed resistances: 23, 24 and 25 from bits 6-7 down
;@ (bits 0-1 unused). The other GetResistByte routines end here too.
GetResistByte6::
;>@x return wBattlerResist[7 * wSkillTarget + 6]
	ld de, wBattlerResist + 6

jr_052_67dc:
;=@x
	ld a, [wSkillTarget]
	ld b, a
	add a
	add b
	add a
	add b
;=@x
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;=@x
	ld a, [de]
	ret


;@ def ChanceByLevel84(level: a) -> carry
;@ path: battle/skills/resist
;@ Resistance check: level 0 always works, 1 in 84% of cases, 2 in 50%, 3 never.
ChanceByLevel84::
;> if level == 0:
;>     return True
	and a
	jr nz, .one

	scf
	ret


.one
;> if level == 1:
;>     return Chance84()
	cp $01
	jr nz, .two

	jp Chance84


.two
;> if level == 2:
;>     return Chance50()
	cp $02
	jr nz, .never

	jp Chance50


.never
;> return False
	scf
	ccf
	ret


;@ def ChanceByLevelLowered(level: a) -> carry
;@ path: battle/skills/resist
;@ Resistance check on a target open to spells: levels 0 and 1 always work, 2 in
;@ 75% of cases, 3 never.
ChanceByLevelLowered::
;> if level < 2:
;>     return True
	cp $02
	jr nc, .two

	ret


.two
;> if level == 2:
;>     return Chance75()
	jr nz, .never

	jp Chance75


.never
;> return False
	scf
	ccf
	ret


;@ def ChanceByLevel75(level: a) -> carry
;@ path: battle/skills/resist
;@ Resistance check: level 0 always works, 1 in 75% of cases, 2 in 40%, 3 never.
ChanceByLevel75::
;> if level == 0:
;>     return True
	and a
	jr nz, .one

	scf
	ret


.one
;> if level == 1:
;>     return Chance75()
	cp $01
	jr nz, .two

	jp Chance75


.two
;> if level == 2:
;>     return Chance40()
	cp $02
	jr nz, .never

	jp Chance40


.never
;> return False
	scf
	ccf
	ret


;@ def ChanceByLevel75Low(level: a) -> carry
;@ path: battle/skills/resist
;@ Resistance check: level 0 works in 75% of cases, 1 in 50%, 2 in 25%, 3 never.
ChanceByLevel75Low::
;> if level == 0:
;>     return Chance75()
	and a
	jr nz, .one

	jp Chance75


.one
;> if level == 1:
;>     return Chance50()
	cp $01
	jr nz, .two

	jp Chance50


.two
;> if level == 2:
;>     return Chance25()
	cp $02
	jr nz, .never

	jp Chance25


.never
;> return False
	scf
	ccf
	ret


;@ def DamageByLevel85(level: a)
;@ path: battle/skills/resist
;@ Scales wSkillAmount by resistance level: 0 keeps it, 1 85%, 2 half, 3 none.
DamageByLevel85::
;> if level == 0:
;>     return
	and a
	ret z

;> if level == 1:
;>     return AmountPercent85()
	cp $01
	jr nz, .two

	jp AmountPercent85


.two
;> if level == 2:
;>     return AmountHalf()
	cp $02
	jr nz, .three

	jp AmountHalf


.three
;> return AmountZero()
	jp AmountZero


;@ def DamageByLevel75(level: a)
;@ path: battle/skills/resist
;@ Scales wSkillAmount by resistance level: 0 keeps it, 1 75%, 2 40%, 3 none.
DamageByLevel75::
;> if level == 0:
;>     return
	and a
	ret z

;> if level == 1:
;>     return AmountPercent75()
	cp $01
	jr nz, .two

	jp AmountPercent75


.two
;> if level == 2:
;>     return AmountPercent40()
	cp $02
	jr nz, .three

	jp AmountPercent40


.three
;> return AmountZero()
	jp AmountZero


;@ def DamageByLevel131(level: a)
;@ path: battle/skills/resist
;@ Scales wSkillAmount for a target open to spells: level 0 to 131%, 1 116%,
;@ 2 75%, 3 30%.
DamageByLevel131::
;> if level == 0:
;>     return AmountPercent131()
	and a
	jr nz, .one

	jp AmountPercent131


.one
;> if level == 1:
;>     return AmountPercent116()
	cp $01
	jr nz, .two

	jp AmountPercent116


.two
;> if level == 2:
;>     return AmountPercent75()
	cp $02
	jr nz, .three

	jp AmountPercent75


.three
;> return AmountPercent30()
	jp AmountPercent30


;@ def DamageByLevel75Low(level: a)
;@ path: battle/skills/resist
;@ Scales wSkillAmount behind a magic wall: level 0 to 75%, 1 half, 2 a quarter,
;@ 3 none.
DamageByLevel75Low::
;> if level == 0:
;>     return AmountPercent75()
	and a
	jr nz, .one

	jp AmountPercent75


.one
;> if level == 1:
;>     return AmountHalf()
	cp $01
	jr nz, .two

	jp AmountHalf


.two
;> if level == 2:
;>     return AmountQuarter()
	cp $02
	jr nz, .three

	jp AmountQuarter


.three
;> return AmountZero()
	jp AmountZero


;@ def Chance84() -> carry
;@ path: battle/skills/resist
;@ Carry in 216 of 256 cases (84%), from a fresh battle random number.
Chance84::
;> BattleRandom()
	call BattleRandom
;> return wRandomHigh < 0xD8
	ld a, [wRandomHigh]
	cp $d8
	ret


;@ def Chance75() -> carry
;@ path: battle/skills/resist
;@ Carry in 191 of 256 cases (75%).
Chance75::
;> BattleRandom()
	call BattleRandom
;> return wRandomHigh < 0xBF
	ld a, [wRandomHigh]
	cp $bf
	ret


;@ def Chance50() -> carry
;@ path: battle/skills/resist
;@ Carry in 127 of 256 cases (50%).
Chance50::
;> BattleRandom()
	call BattleRandom
;> return wRandomHigh < 0x7F
	ld a, [wRandomHigh]
	cp $7f
	ret


;@ def Chance40() -> carry
;@ path: battle/skills/resist
;@ Carry in 102 of 256 cases (40%).
Chance40::
;> BattleRandom()
	call BattleRandom
;> return wRandomHigh < 0x66
	ld a, [wRandomHigh]
	cp $66
	ret


;@ def Chance25() -> carry
;@ path: battle/skills/resist
;@ Carry in 63 of 256 cases (25%).
Chance25::
;> BattleRandom()
	call BattleRandom
;> return wRandomHigh < 0x3F
	ld a, [wRandomHigh]
	cp $3f
	ret


;@ def AmountPercent131()
;@ path: battle/skills/damage
;@ wSkillAmount to 131% (Percent131).
AmountPercent131::
;>@a wSkillAmount = Percent131(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent131
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountPercent116()
;@ path: battle/skills/damage
;@ wSkillAmount to 116% (Percent116).
AmountPercent116::
;>@a wSkillAmount = Percent116(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent116
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountPercent85()
;@ path: battle/skills/damage
;@ wSkillAmount to 85% (Percent85).
AmountPercent85::
;>@a wSkillAmount = Percent85(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent85
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountPercent75()
;@ path: battle/skills/damage
;@ wSkillAmount to 75% (Percent75).
AmountPercent75::
;>@a wSkillAmount = Percent75(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent75
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountHalf()
;@ path: battle/skills/damage
;@ Halves wSkillAmount.
AmountHalf::
;>@a wSkillAmount = wSkillAmount >> 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call ShiftHL1
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountPercent40()
;@ path: battle/skills/damage
;@ wSkillAmount to 40% (Percent40).
AmountPercent40::
;>@a wSkillAmount = Percent40(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent40
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountPercent30()
;@ path: battle/skills/damage
;@ wSkillAmount to 30% (Percent30).
AmountPercent30::
;>@a wSkillAmount = Percent30(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent30
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountQuarter()
;@ path: battle/skills/damage
;@ wSkillAmount to a quarter.
AmountQuarter::
;>@a wSkillAmount = wSkillAmount >> 2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call ShiftHL2
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def AmountZero()
;@ path: battle/skills/damage
;@ The skill does nothing: wSkillAmount = 0.
AmountZero::
;> wSkillAmount = 0
	xor a
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a
	ret


;@ def AmountPercent150()
;@ path: battle/skills/damage
;@ wSkillAmount to 150% (Percent150).
AmountPercent150::
;>@a wSkillAmount = Percent150(wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call Percent150
;=@a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ret


;@ def Percent150(x: hl) -> hl
;@ path: battle/skills/damage
;@ x + x / 2.
Percent150::
;> return (x + (x >> 1)) & 0xFFFF
	ld b, h
	ld c, l
	call ShiftHL1
	add hl, bc
	ret


;@ def Percent131(x: hl) -> hl
;@ path: battle/skills/damage
;@ x + x / 4 + x / 16 (131.25%).
Percent131::
;>@r return (x + (x >> 2) + (x >> 4)) & 0xFFFF
	ld b, h
	ld c, l
	call ShiftBC2
	add hl, bc
	call ShiftBC2
	add hl, bc
;=@r
	ret


;@ def Percent116(x: hl) -> hl
;@ path: battle/skills/damage
;@ x + x / 8 + x / 32 (115.6%).
Percent116::
;>@r return (x + (x >> 3) + (x >> 5)) & 0xFFFF
	ld b, h
	ld c, l
	call ShiftBC3
	add hl, bc
	call ShiftBC2
	add hl, bc
;=@r
	ret


	; unused: x/2 + x/4 + x/8 + x/32 (about 90%)
	db $cd, $43, $6b, $44, $4d, $cd, $32, $6b, $09, $cd, $32, $6b, $09, $cd, $2e, $6b
	db $09, $c9

;@ def Percent85(x: hl) -> hl
;@ path: battle/skills/damage
;@ x * 85 / 100 (24-bit product, so no overflow; keeps de).
Percent85::
;>@r return (x * 85 // 100) & 0xFFFF
	push de
	ld b, h
	ld c, l
	ld a, $55
	call Multiply24
	ld a, $64
;=@r
	call Divide24
	pop de
	ret


;@ def Percent80(x: hl) -> hl
;@ path: battle/skills/damage
;@ x * 8 / 10 (keeps de).
Percent80::
;>@r return (x * 8 // 10) & 0xFFFF
	push de
	ld b, h
	ld c, l
	ld a, $08
	call Multiply24
	ld a, $0a
;=@r
	call Divide24
	pop de
	ret


;@ def Percent75(x: hl) -> hl
;@ path: battle/skills/damage
;@ x / 2 + x / 4 (keeps bc).
Percent75::
;>@r return (x >> 1) + (x >> 2)
	push bc
	call ShiftHL1
	ld b, h
	ld c, l
	call ShiftBC1
	add hl, bc
;=@r
	pop bc
	ret


;@ def Percent60(x: hl) -> hl
;@ path: battle/skills/damage
;@ x * 6 / 10 (keeps de).
Percent60::
;>@r return (x * 6 // 10) & 0xFFFF
	push de
	ld b, h
	ld c, l
	ld a, $06
	call Multiply24
	ld a, $0a
;=@r
	call Divide24
	pop de
	ret


;@ def Percent40(x: hl) -> hl
;@ path: battle/skills/damage
;@ Half of Percent80: x * 8 / 10 / 2.
Percent40::
;> return Percent80(x) >> 1
	call Percent80
	call ShiftHL1
	ret


;@ def Percent30(x: hl) -> hl
;@ path: battle/skills/damage
;@ Half of Percent60: x * 6 / 10 / 2.
Percent30::
;> return Percent60(x) >> 1
	call Percent60
	call ShiftHL1
	ret


	; a routine reached only from code still in data form (the battle items):
	; IsHPFull, compares the HP of battle position a with its maximum HP (zero
	; flag when equal), like IsMPFull below
	db $e5, $c5, $47, $cd, $e8, $2f, $e5, $78, $cd, $da, $2f, $c1, $cd, $45, $2f, $c1
	db $e1, $c9

;@ def IsMPFull(pos: a) -> zero
;@ path: battle/state
;@ Zero flag when the monster at battle position `pos` has all its MP. Keeps
;@ the other registers.
IsMPFull::
;> mp = GetBattlerMP(pos)
	push hl
	push bc
	ld b, a
	call GetBattlerMP
	push hl
;>@r return GetBattlerMaxMP(pos) == mp
	ld a, b
	call GetBattlerMaxMP
	pop bc
	call CompareHLBC
	pop bc
	pop hl
;=@r
	ret


;@ def CheckDefenseRaisable(pos: a) -> carry
;@ path: battle/skills/stats
;@ Carry while the defense of battle position `pos` may still go up (Upper):
;@ up to 999, and no higher than four times its base defense (twice for a wild
;@ enemy, GetBaseDefense).
CheckDefenseRaisable::
;> wBattleArg0 = pos
;> defense = GetBattlerDefense(pos)
	ld [wBattleArg0], a
	call GetBattlerDefense
;> if defense >= 999:
;>@m     return defense == 999
	ld bc, $03e7
	call CompareHLBC
	jr nc, .atLeast

;> limit = GetBaseDefense(pos)
	push hl
	ld a, [wBattleArg0]
	call GetBaseDefense
;> if wLinkActive or pos < 4:
;>@o     limit *= 2
	ld a, [wLinkActive]
	or a
	jr nz, .times4

	ld a, [wBattleArg0]
	cp $04
	jr nc, .times2

.times4
;=@o
	sla c
	rl b

.times2
;> limit *= 2
	sla c
	rl b
;> return defense <= limit & 0xFFFF
	pop hl
	call CompareHLBC
	jr nc, .atLeast

.yes
	scf
	ret


.atLeast
;=@m
	jr z, .yes

	xor a
	ret


;@ def CheckAgilityRaisable(pos: a) -> carry
;@ path: battle/skills/stats
;@ Carry while the agility of battle position `pos` may still go up (Speed):
;@ below 511, and below four times its base agility (twice for a wild enemy).
CheckAgilityRaisable::
;> wBattleArg0 = pos
;> agility = GetWordAt(pos, wBattlerAgility)
	ld [wBattleArg0], a
	ld hl, wBattlerAgility
	call GetWordAt
;> if agility >= 511:
;>@n     return False
	ld bc, $01ff
	call CompareHLBC
	jr z, .no

	jr nc, .no

;> base = GetBaseAgility(pos)
	push hl
	ld a, [wBattleArg0]
	call GetBaseAgility
;> wStatCapPos = pos
	ld a, [wBattleArg0]
	ld [wStatCapPos], a
;> return agility < StatLimitTimes(base)
	call StatLimitTimes
	pop hl
	call CompareHLBC
	jr nc, .no

	ret


.no
;=@n
	xor a
	ret


;@ def PackResistancesVia(src: hl, dest: de)
;@ path: battle/skills/resist
;@ Packs the 27 resistance values at `src` into the 7 bytes at `dest`
;@ (PackResistancesFar in bank $51).
PackResistancesVia::
;> wBattleArg0 = lo(src)
;> wBattleArg1 = hi(src)
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;> wBattleArg2 = lo(dest)
;> wBattleArg3 = hi(dest)
	ld a, e
	ld [wBattleArg2], a
	ld a, d
	ld [wBattleArg3], a
;> PackResistancesFar()
	ld hl, far_PackResistancesFar
	rst $10
	ret


;@ def GetResistByte()
;@ path: battle/skills/resist
;@ Far entry for the enemy AI: wBattleArg0 = byte wBattleArg0 (0-6) of the
;@ packed resistances of wSkillTarget. Keeps all registers.
;@ test: skip calls through a table of routines
GetResistByte::
;>@r wBattleArg0 = [GetResistByte0, GetResistByte1, GetResistByte2, GetResistByte3, GetResistByte4, GetResistByte5, GetResistByte6][wBattleArg0]()
	push af
	push bc
	push de
	push hl
	ld a, [wBattleArg0]
	ld hl, .getters
;=@r
	call IndexWords
	call JumpToPointer
	ld [wBattleArg0], a
	pop hl
	pop de
	pop bc
;=@r
	pop af
	ret


	db $e9                                  ; unused byte

.getters
	dw GetResistByte0, GetResistByte1, GetResistByte2, GetResistByte3
	dw GetResistByte4, GetResistByte5, GetResistByte6

;@ def GetWordAt(index: a, table: hl) -> hl
;@ path: system/memory
;@ Entry `index` of a table of 16-bit words.
GetWordAt::
;> return mem16[IndexWords(index, table)]
	call IndexWords
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret


;@ def IndexWords(index: a, table: hl) -> hl
;@ path: system/memory
;@ Address of entry `index` of a table of 16-bit words (2 * index must fit in a
;@ byte).
IndexWords::
;>@r return u16(table + (2 * index & 0xFF))
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@r
	ret


;@ def GetTargetFamily() -> a
;@ path: battle/state
;@ Family of the skill target's species (MonsterStats byte 0: 0 slime, 1 dragon,
;@ 2 beast, 3 bird, 4 plant, 5 bug, 6 devil, 7 zombie, 8 material, ...).
GetTargetFamily::
;> wMonSpecies = mem[GetTargetSpeciesPtr()]
	call GetTargetSpeciesPtr
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> return wMonStats[0]
	ld a, [wMonStats]
	ret


;@ def GetTargetSpeciesPtr() -> hl
;@ path: battle/state
;@ Address of the skill target's entry in wBattlerSpecies.
GetTargetSpeciesPtr::
;>@r return wBattlerSpecies + wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@r
	ld h, a
	ret


;@ def CheckUserNudgeBit2(value: a) -> zero
;@ path: battle/skills/effects
;@ Zero flag when `value` is 3, or when bit 2 of the skill user's personality
;@ flags (wPersonalityNudge) is clear. Keeps a, bc and hl.
CheckUserNudgeBit2::
;> if value == 3:
;>     return True
	cp $03
	ret z

;>@r return not wPersonalityNudge[wSkillUser] & 0x04
	push bc
	push hl
	ld b, a
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
;=@r
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	and $04
;=@r
	ld a, b
	pop hl
	pop bc
	ret


;@ def StatLimitTimes(base: bc) -> bc
;@ path: battle/skills/stats
;@ The limit a raised stat may reach: four times `base` for own monsters and in
;@ link battles, twice for a wild enemy (wStatCapPos >= 4).
StatLimitTimes::
;> if wLinkActive or wStatCapPos < 4:
;>@f     base *= 2
	ld a, [wLinkActive]
	or a
	jr nz, .four

	ld a, [wStatCapPos]
	cp $04
	jr nc, .two

.four
;=@f
	sla c
	rl b

.two
;> return base * 2 & 0xFFFF
	sla c
	rl b
	ret


	; reached only from code still in data form: wBattlerOrder[wSkillTarget] = 3
	; (the target loses its turn), keeping af and hl
	db $e5, $f5, $fa, $89, $db, $21, $13, $dd, $85, $6f, $3e, $00, $8c, $67, $36, $03
	db $f1, $e1, $c9

;@ def ReturnNoCarry() -> carry
;@ path: battle/skills/effects
;@ Returns with carry clear (the skill did not work).
ReturnNoCarry::
;> return False
	scf
	ccf
	ret


;@ def CheckSkillAllowed() -> a
;@ path: battle/skills/effects
;@ Asks bank $53 whether the skill may work on its target (some skills never
;@ work on the enemies of scripted battles); 0 = not allowed, with the zero flag.
CheckSkillAllowed::
;> CheckBossImmunity_53()
	ld hl, far_CheckBossImmunity_53
	rst $10
;> return wBattleArg0
	ld a, [wBattleArg0]
	or a
	ret


;@ def ShiftBC3(v: bc) -> bc
;@ path: system/math
;@ v / 8 (runs on into ShiftBC2 and ShiftBC1).
ShiftBC3::
;> return v >> 3
	srl b
	rr c

;@ def ShiftBC2(v: bc) -> bc
;@ path: system/math
;@ v / 4 (runs on into ShiftBC1).
ShiftBC2::
;> return v >> 2
	srl b
	rr c

;@ def ShiftBC1(v: bc) -> bc
;@ path: system/math
;@ v / 2.
ShiftBC1::
;> return v >> 1
	srl b
	rr c
	ret


;@ def ShiftHL4(v: hl) -> hl
;@ path: system/math
;@ v / 16 (runs on into ShiftHL3 to ShiftHL1).
ShiftHL4::
;> return v >> 4
	srl h
	rr l

;@ def ShiftHL3(v: hl) -> hl
;@ path: system/math
;@ v / 8 (runs on into ShiftHL2 and ShiftHL1).
ShiftHL3::
;> return v >> 3
	srl h
	rr l

;@ def ShiftHL2(v: hl) -> hl
;@ path: system/math
;@ v / 4 (runs on into ShiftHL1).
ShiftHL2::
;> return v >> 2
	srl h
	rr l

;@ def ShiftHL1(v: hl) -> hl
;@ path: system/math
;@ v / 2.
ShiftHL1::
;> return v >> 1
	srl h
	rr l
	ret


;@ def GetBattlerNameTo(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Writes the name of the monster at battle position `pos` to `dest`: an own
;@ monster's (and in a link battle the partner's) own name from its record; a
;@ wild enemy's species name with its letter (CopyBattlerSpeciesName, AppendEnemyLetter),
;@ or, when it has transformed, the name of the monster it became plus "Like"
;@ (CopyMorphedEnemyName). Position 3 or 7 always gets the species name.
;@ test: skip calls routines in other banks
GetBattlerNameTo::
;> if pos >= 3:
	cp $03
;>     return CopyEnemyName(pos, dest)
;> return CopyPartyMonName(pos, dest)       # runs on into it
	jr nc, CopyEnemyName

;@ def CopyPartyMonName(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ Copies the name of party monster `pos` (the record's own name) to `dest` and
;@ returns the address of its $F0 end mark.
CopyPartyMonName::
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

;@ def CopyLinkPartnerName()
;@ path: battle/names
;@ Part of CopyEnemyName: in a link battle the partner's monsters have party
;@ records too (positions 4-6), so their own names are copied.
;@ test: skip a piece of CopyEnemyName (works on its pushed registers)
CopyLinkPartnerName::
;> return CopyPartyMonName(pos, dest)
	ld a, b
	pop bc
	jr CopyPartyMonName

;@ def CopyEnemyName(pos: a, dest: hl) -> hl
;@ path: battle/names
;@ The name of the monster at battle position `pos` of the far side: the link
;@ partner's own name, a transformed enemy's "Like" name (CopyMorphedEnemyName),
;@ or the species name with the enemy's letter (CopyBattlerSpeciesName,
;@ AppendEnemyLetter); slot 3 (the called helper) always the species name.
;@ test: skip calls routines in other banks
CopyEnemyName::
;>@x if pos & 3 != 3:
	push bc
	ld b, a
	and $03
	cp $03
	ld a, b
	pop bc
;=@x
	jr z, .species

;>@l     if wLinkActive:
;>@l2         return CopyLinkPartnerName()
	push bc
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, CopyLinkPartnerName

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
;>@t         return CopyMorphedEnemyName(morph, dest)
	cp $ff
	jr nz, .morphed

	ld a, b

.morphed
;=@t
	pop bc
	jr nz, CopyMorphedEnemyName

.species
;> CopyBattlerSpeciesName(pos, dest)
	push af
	call CopyBattlerSpeciesName
	pop af
;> AppendEnemyLetter()
	ld hl, far_AppendEnemyLetter
	rst $10
	ret


;@ def CopyBattlerSpeciesName(pos: a, dest: hl)
;@ path: battle/names
;@ Copies the species name of battle position `pos` (system text group 5) to
;@ `dest`, and notes both for AppendEnemyLetter (wNameBattler, wNameDest).
CopyBattlerSpeciesName::
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


;@ def CopyMorphedEnemyName(party_pos: a, dest: hl)
;@ path: battle/names
;@ Name of an enemy that transformed into own monster `party_pos`: that monster's
;@ name followed by "Like". When another enemy turned into the same monster, a
;@ number 1-3 follows, counted by the enemy's place (wNamePos); it is also left in
;@ wBattleArg1 (0 = none).
CopyMorphedEnemyName::
;> end = CopyPartyMonName(party_pos, dest)
	call CopyPartyMonName
;>@k copy(end, [0x2F, 0x46, 0x48, 0x42, 0xF0])   # "Like"
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
;>@s slot = wNamePos & 3
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
;>     copy(end, [n, 0xF0])
	ld [hli], a
	ld [hl], $f0
	ret


.none
;=@z
	pop hl
	xor a
	ld [wBattleArg1], a
	ret


	; unused: the same with the name going to wTextArg2
	db $21, $a0, $c1, $18, $03

;@ def TargetNameToArg0()
;@ path: battle/names
;@ Writes the skill target's name to wTextArg0 for the next message
;@ (GetBattlerNameTo; wBattleArg2/3 hold the buffer's address).
TargetNameToArg0::
;> wBattleArg2 = lo(wTextArg0)
;> wBattleArg3 = hi(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillTarget
	ld a, [wSkillTarget]
	ld [wNamePos], a
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	call GetBattlerNameTo
	ret


	; unused: the same for wSkillUser
	db $21, $80, $c1, $7d, $ea, $4e, $db, $7c, $ea, $4f, $db, $fa, $88, $db, $ea, $50
	db $db, $cd, $48, $6b, $c9

;@ def RunActionStep()
;@ path: battle/actions
;@ Far entry 0: runs one step of the battle action being carried out (a skill
;@ or an item), by wBattleSubStep (ActionSteps). While a battle animation is
;@ still running (wBattleAnimDone 0) it only drives that animation.
RunActionStep::
;> if not wBattleAnimDone:
	ld a, [wBattleAnimDone]
	or a
	jr nz, .run

;>     UpdateScreenEffect()
	ld hl, far_UpdateScreenEffect
	rst $10
;>     if not wBattleAnimDone:
;>         return
	ld a, [wBattleAnimDone]
	or a
	ret z

.run
;> return ActionSteps[wBattleSubStep]()
	ld a, [wBattleSubStep]
	rst $00

;@ path: battle/actions
;@ The steps of a battle action, by wBattleSubStep: 0 start (and 18), 1 the
;@ skill's effect routine, 2 the damage goes off the target's HP, 3 skills with
;@ their own steps, 4 follow-up stages, 5 next hit or target, 6 end of the
;@ action, 7 done, 8 a monster is defeated, 9-14 an item used by Terry, 15-17
;@ restarts, 19 a counterattack (BladeD), 20 nothing, 21 an item that does
;@ nothing, 22-25 steps in banks $57 and $58, 26 a monster falls, 27 close.
ActionSteps::
	dw ActionStepStart
	dw ActionStepSkill
	dw ActionStepDamage
	dw ActionStepSpecial
	dw ActionStepFollowUp
	dw ActionStepNext
	dw ActionStepEnd
	dw ActionStepDone
	dw ActionStepDefeat
	dw ActionStepItem
	dw ActionStepItemEffect
	dw ActionStepItemTarget
	dw ActionStepItemEnd
	dw ActionStepFinish
	dw ActionStepItemAgain
	dw ActionStepFinishReset
	dw ActionStepRestart
	dw ActionStep17
	dw ActionStepStart
	dw ActionStepCounter
	dw ActionStepNone
	dw ActionStepItemFails
	dw ActionStep6E0E
	dw ActionStep5C48
	dw ActionStep6E0E
	dw ActionStep5C48
	dw ActionStepFall
	dw ActionStepWaitClose

;@ def ActionStepStart()
;@ path: battle/actions
;@ Action step 0: bank $53 starts the action (RunActionStart_53). When that
;@ turns out to be Terry using an item (step 9), the item steps start at once.
ActionStepStart::
;> RunActionStart_53()
	ld hl, far_RunActionStart_53
	rst $10
;> if wBattleSubStep != 9:
;>     return
	ld a, [wBattleSubStep]
	cp $09
	ret nz

;>@s wBattleSubStep2 = 0
	xor a
	ld hl, wBattleSubStep2
	ld [hli], a
;>@a wBattleStepArg0 = 0xFF
;>@b wBattleStepArg1 = 0xFF
	ld a, $ff
	ld [hli], a
	ld [hli], a
;>@c wFallStep = 0xFF
	ld [hli], a
;>@d wAbsorbMP = 0xFE
	ld a, $fe
	ld [hl], a
;> return ActionStepItem()
	jp ActionStepItem


;@ def ActionStepSkill()
;@ path: battle/actions
;@ Action step 1: bank $53 shows the skill (RunSkillHit_53, its stages counted in
;@ wBattleSubStep2). At stage $0B the skill's effect routine runs: entry 8 +
;@ wSkillId of FarTable_52. At stage $10 the skill is over (SkillStepDone).
ActionStepSkill::
;> if wBattleSubStep2 != 0x0B:
	ld a, [wBattleSubStep2]
	cp $0b
	jr z, .effect

;>     if wBattleSubStep2 == 0x10:
;>         return SkillStepDone()
	cp $10
	jr z, SkillStepDone

;>     RunSkillHit_53()
	ld hl, far_RunSkillHit_53
	rst $10
;>     if wBattleSubStep2 != 0x0B:
;>         return
	ld a, [wBattleSubStep2]
	cp $0b
	ret nz

.effect
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> wHitShown = 0
	xor a
	ld [wHitShown], a
;>@e call(mem16[FarTable_52 + 0x10 + 2 * wSkillId])   # the skill's effect routine
	ld a, [wSkillId]
	ld c, a
	ld b, $00
	ld hl, FarTable_52 + $10
	add hl, bc
	add hl, bc
;=@e
	call JumpToPointer
;> if wBattleSubStep2 == 0x0C and wBattleSubStep == 1:
	ld a, [wBattleSubStep2]
	cp $0c
	ret nz

	ld a, [wBattleSubStep]
	cp $01
	ret nz

;>     RunSkillHit_53()
	ld hl, far_RunSkillHit_53
	rst $10
	ret


	; unused: a copy of JumpToPointer
	db $2a, $66, $6f, $e9

;@ def SkillStepDone()
;@ path: battle/actions
;@ The skill has been shown: on to the damage step (2). Transform ($29) instead
;@ turns the user into its target (TransformIntoTarget) and marks it (status 1
;@ bit 5); a wild enemy also notes whom it copied (wEnemyMorph), for its name.
;@ CHGDRAGON ($AA) and $D5 change the user's picture (TransformUserPic, status 1
;@ bit 4) and go on with the follow-up step.
SkillStepDone::
;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> if wSkillId == 0x29:
	ld a, [wSkillId]
	cp $29
;>@t     wBattleSubStep = 5
;>@t2     TransformIntoTarget()
;>@t3     wBattleSubStep += 1
;>@t4     mem[wBattlerStatus1 + 8 * wSkillUser] |= 0x20
;>@t5     if wLinkActive or wSkillUser < 4:
;>@t6         return ActionStepNext()
;>@t7     wEnemyMorph[wSkillUser & 3] = wSkillTarget
	jr z, .transform

;> elif wSkillId not in (0xAA, 0xD5):
;>     return ActionStepDamage()
	cp $aa
	jr z, .changePic

	cp $d5
	jp nz, ActionStepDamage

;> else:
;>     wBattleSubStep = 4
.changePic
	ld a, $04
	ld [wBattleSubStep], a
;>     TransformUserPic()
	call TransformUserPic
;>@p     mem[wBattlerStatus1 + 8 * wSkillUser] |= 0x10
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 4, [hl]
;>     return ActionStepFollowUp()
	jp ActionStepFollowUp


.transform
;=@t
	ld a, $05
	ld [wBattleSubStep], a
;=@t2
	call TransformIntoTarget
;=@t3
	ld hl, wBattleSubStep
	inc [hl]
;=@t4
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 5, [hl]
;=@t5
	ld a, [wLinkActive]
	or a
	jp nz, ActionStepNext

	ld a, [wSkillUser]
	cp $04
	jp c, ActionStepNext

;=@t7
	and $03
	ld hl, wEnemyMorph
	add l
	ld l, a
	ld a, $00
	adc h
;=@t7
	ld h, a
	ld a, [wSkillTarget]
	ld [hl], a
	ret


;@ def ActionStepDamage()
;@ path: battle/actions
;@ Action step 2, once the sound channels are free and the animation is done:
;@ takes wSkillAmount off the target's HP when the effect routine said so
;@ (wSkillResult bit 5) and the skill is one that hurts. A target at 0 HP, or an
;@ enemy that is gone, goes to the falling step ($1A); otherwise the party
;@ panel shows the new HP. CALLHOROR and Smashed have their own step instead.
ActionStepDamage::
;> if wSoundChannels[0] & mem[0xDD9A] != 0xFF:   # wait for two free sound channels
;>     return
	ld a, [wSoundChannels]
	ld hl, $dd9a
	and [hl]
	cp $ff
	ret nz

;> if not wBattleAnimDone:
;>     return
	ld a, [wBattleAnimDone]
	or a
	ret z

;> if wSkillId in (0xA4, 0xA2):
	ld a, [wSkillId]
	cp $a4
	jr z, .callHorror

	cp $a2
	jr nz, .normal

.callHorror
;>     wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;>     return RunCallHorrorStep()
	jp RunCallHorrorStep


.normal
;> wBattleTemp = 0
	xor a
	ld [wBattleTemp], a
;> wBattleSubStep += 2
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
;>@h hurts = wSkillId not in (0x12, 0x13, 0x71, 0x75, 0x76, 0x94) and not (0x15 <= wSkillId < 0x3A and wSkillId not in (0x37, 0x38))
	ld a, [wSkillId]
	cp $1a
	jp z, .check

	cp $75
	jp z, .check

;=@h
	cp $76
	jp z, .check

	cp $15
	jr c, .hurtsCheck

	cp $71
	jp z, .check

;=@h
	cp $37
	jr z, .hurtsCheck

	cp $38
	jr z, .hurtsCheck

	cp $3a
	jp c, .check

;=@h
	cp $94
	jp z, .check

.hurtsCheck
;=@h
	ld a, [wSkillId]
	cp $12
	jp z, .check

	cp $13
	jp z, .check

;> if hurts and wSkillResult & 0x20:
	ld a, [wSkillResult]
	bit 5, a
	jp z, .check

;>@p     hp = mem16[wBattlerHP + 2 * wSkillTarget] - wSkillAmount
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
;=@p
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, e
	sub c
;=@p
	ld e, a
	ld a, d
	sbc b
	ld d, a
;>     if hp >= 0:
	jr c, .falls

;>         mem16[wBattlerHP + 2 * wSkillTarget] = hp
	ld a, d
	ld [hld], a
	ld [hl], e
;>     if hp <= 0:
	or e
	jp nz, .check

.falls
;>         wBattleSubStep = 0x1A
	ld a, $1a
	ld [wBattleSubStep], a
;>         wFallStep = 0
	xor a
	ld [wFallStep], a
;>         return
	ret


.check
;> if wLinkFlags & 0x02:
;>@m     far_side = wSkillTarget < 3
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	jr z, .slave

;=@m
	cp $03
	jr nc, .panel

	jr .gone

;> else:
;>     far_side = wSkillTarget >= 4 and wSkillTarget != 7
.slave
	cp $04
	jr c, .panel

	cp $07
	jr z, .panel

.gone
;> if far_side and CheckBattlerPresent(wSkillTarget):   # an enemy that is gone
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr nc, .panel

;>     wBattleSubStep = 0x1A
	ld a, $1a
	ld [wBattleSubStep], a
;>     wFallStep = 0
	xor a
	ld [wFallStep], a
;>     return
	ret


	; unused: PrintPanelHPMP, then $C87E = 1
	db $21, $06, $50, $d7, $3e, $01, $ea, $7e, $c8, $c9

.panel
;> PrintPanelHPMP()
	ld hl, far_PrintPanelHPMP
	rst $10
	ret


;@ def ActionStepSpecial()
;@ path: battle/actions
;@ Action step 3: skills with steps of their own go to them in bank $53
;@ (Sacrifice, DeMagic, ThickFog and FILTHZONE, UltraDown, Cover and Guardian,
;@ CALLHOROR and Smashed); all others skip to the end of the action (step 6).
ActionStepSpecial::
;>@h handler = {0x14: Call_53_670E, 0x80: Call_53_60B3, 0x82: Call_53_65AC, 0x83: Call_53_60B3, 0xA5: Call_53_60B3, 0x88: RunCoverStages_53, 0x89: RunCoverStages_53, 0xA2: RunCallHorrorStep, 0xA4: RunCallHorrorStep}.get(wSkillId)
	ld a, [wSkillId]
	cp $14
	jr z, .sacrifice

	cp $80
	jr z, .deMagic

;=@h
	cp $82
	jr z, .ultraDown

	cp $83
	jr z, .deMagic

	cp $a5
	jr z, .deMagic

;=@h
	cp $88
	jr z, .cover

	cp $89
	jr z, .cover

	cp $a2
	jr z, RunCallHorrorStep

;=@h
	cp $a4
	jr z, RunCallHorrorStep

;> if handler:
;>@r     return handler()
;> wBattleSubStep += 3
	ld hl, wBattleSubStep
	inc [hl]
	inc [hl]
	inc [hl]
;> return ActionStepEnd()
	jp ActionStepEnd


.deMagic
;=@r
	ld hl, far_Call_53_60B3
	rst $10
	ret


.sacrifice
;=@r
	ld hl, far_Call_53_670E
	rst $10
	ret


.ultraDown
;=@r
	ld hl, far_Call_53_65AC
	rst $10
	ret


.cover
;=@r
	ld hl, far_RunCoverStages_53
	rst $10
	ret


;@ def RunCallHorrorStep()
;@ path: battle/actions
;@ The own steps of CALLHOROR and Smashed, in bank $53.
RunCallHorrorStep::
;> Call_53_6BE2()
	ld hl, far_Call_53_6BE2
	rst $10
	ret


ActionStepFollowUp::
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


SkillFollowUp::
jr_052_6e89:
	ld a, [wSkillId]
	cp $32
	jr z, FarewellFollowUp

	cp $96
	jr z, FarewellFollowUp

	cp $3b
	jr z, Skill3BStages

	cp $3e
	jr z, KamikazeStages

	cp $3c
	jr z, RammingStages

	cp $67
	jr z, PoisonHitStages

	cp $68
	jr z, NapAttackStages

	cp $69
	jp z, ParalyzeStages

	cp $80
	jp z, DeMagicStages

	cp $95
	jp z, LifeSongStages

	cp $aa
	jp z, ChgDragonFollowUp

	cp $d5
	jp z, ChgDragonFollowUp

	call CheckBladeCounter
	jp nz, BladeCounterFollowUp

	ld hl, wBattleSubStep
	inc [hl]
	jp ActionStepNext


	db $c9

CheckBladeCounter::
	ld a, [wInterceptState]
	or a
	jr z, jr_052_6ed7

	xor a
	ret


jr_052_6ed7:
	ld a, [wReactionKind]
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


FarewellFollowUp::
	ld hl, far_Call_53_6A9B
	rst $10
	ret


Skill3BStages::
	ld a, [wBattleSubStep2]
	rst $00

Skill3BStageTable::
	dw Skill3BStage0
	dw Skill3BStage1
	dw RecoilStageUserDown
	dw StagesEnd

KamikazeStages::
	ld a, [wBattleSubStep2]
	rst $00

KamikazeStageTable::
	dw KamikazeStage0
	dw KamikazeStage1
	dw RecoilStageUserDown
	dw StagesEnd

RammingStages::
	ld a, [wBattleSubStep2]
	rst $00

RammingStageTable::
	dw RammingStage0
	dw RammingStage1
	dw RecoilStageUserDown
	dw StagesEnd

PoisonHitStages::
	ld a, [wBattleSubStep2]
	rst $00

PoisonHitStageTable::
	dw PoisonHitStage0
	dw StageShowText
	dw StagesEnd

NapAttackStages::
	ld a, [wBattleSubStep2]
	rst $00

NapAttackStageTable::
	dw NapAttackStage0
	dw StageShowText
	dw StagesEnd

ParalyzeStages::
	ld a, [wBattleSubStep2]
	rst $00

ParalyzeStageTable::
	dw ParalyzeStage0
	dw StageShowText
	dw StagesEnd

DeMagicStages::
	ld a, [wBattleSubStep2]
	rst $00

DeMagicStageTable::
	dw DeMagicStage0
	dw DeMagicStage1
	dw StagesEnd

LifeSongStages::
	ld a, [wBattleSubStep2]
	rst $00

LifeSongStageTable::
	dw LifeSongStage0
	dw LifeSongStage1
	dw LifeSongStage2
	dw StagesEnd

ChgDragonFollowUp::
	call ChgDragonPickAction
	ret


BladeCounterFollowUp::
	call StartBladeCounter
	ret


ActionStepNext::
	ld hl, far_Call_53_5F15
	rst $10
	ret


ActionRepeatCheck::
	res 6, [hl]
	ld a, [wSkillFlags3]
	bit 4, a
	jp z, EndBattlerAction

	call CheckFarSideEmpty
	jp c, EndBattlerAction

	ld a, $12
	ld [wBattleSubStep], a
	ret


QuadHitsNext::
	ld a, [wHitCount]
	cp $04
	jp z, EndBattlerAction

	ld hl, far_AITargetRandomEnemy
	rst $10
	ld a, $01
	ld [wBattleSubStep], a
	ret


BiAttackNext::
	ld a, [wHitCount]
	cp $02
	jp z, EndBattlerAction

	ld a, $01
	ld [wBattleSubStep], a
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret nc

	ld hl, far_AITargetRandomEnemy
	rst $10
	ret


CallHelpNext::
	ld a, [wHitCount]
	cp $13
	jp z, EndBattlerAction

	ld b, $03
	jr jr_052_6fb2

YellHelpNext::
	ld a, [wHitCount]
	cp $17
	jp z, EndBattlerAction

	ld b, $07

jr_052_6fb2:
	and b
	ld c, a
	ld a, [wRandomLow]
	and b
	cp c
	jp z, EndBattlerAction

	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 0, [hl]
	jp z, EndBattlerAction

	ld hl, far_AITargetRandomEnemy
	rst $10
	ld a, $01
	ld [wBattleSubStep], a
	ret


RainSlashNext::
jr_052_6fd4:
	ld a, [wHitCount]
	cp $04
	jp nc, EndBattlerAction

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


ActionStepEnd::
	ld a, [wMonStats]
	or a
	jr z, jr_052_7005

	dec a
	ld [wMonStats], a
	ret


jr_052_7005:
	ld a, [wShieldTarget]
	cp $ff
	jr z, jr_052_702c

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

jr_052_702c:
	ld hl, far_UpdateStatusIcon_50
	rst $10
	call PrepareRedirect
	call CheckSideDefeated
	jp c, FinishActionOrHelp

	call CheckTargetReacts
	ret c

	xor a
	ld [wSkillMsgMode], a
	ld a, [wSkillId]
	cp $50
	jp z, BiAttackNext

	cp $51
	jp z, QuadHitsNext

	cp $52
	jp z, CallHelpNext

	cp $53
	jp z, YellHelpNext

	cp $57
	jp z, RainSlashNext

	cp $a7
	jp z, AllPositionsNextTarget

	cp $a8
	jp z, AllPositionsNextTarget

	cp $af
	jp z, AllPositionsNextTarget

EndBattlerAction::
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
	jp nz, NextTargetOfGroup

FinishAction::
	call BattleRedraw57
	ld a, [wReflectAnim]
	or a
	call nz, PrintActionMessage
	call ClearMPAfterSkill
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	cp $04
	jr nc, jr_052_70a4

	ld hl, far_UpdateStatusIcon_50
	rst $10
	ld hl, far_PrintPanelHPMP
	rst $10

jr_052_70a4:
	call GetUserStatus4
	bit 6, [hl]
	jp nz, ActionRepeatCheck

	call RestoreInterruptedAction
	jp nc, EndBattlerAction

jr_052_70b2:
	ld a, [wTurnOrderPos]
	inc a
	ld [wTurnOrderPos], a
	cp $09
	jr nc, NextBattlerTurn

	call CheckSideDefeated
	jr c, jr_052_70e0

	ld a, [wTurnOrderPos]
	ld hl, wTurnOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr z, NextBattlerTurn

	cp $10
	jr z, jr_052_70dc

	call CheckBattlerPresent
	jr c, jr_052_70b2

jr_052_70dc:
	ld hl, wBattleStep
	dec [hl]

FinishActionOrHelp::
jr_052_70e0:
	ld a, [wSkillId]
	cp $52
	jr c, CloseAction

	cp $54
	jr nc, CloseAction

	ld a, [wHitShown]
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


CloseAction::
	call CheckBattleOver

jr_052_7111:
	call ClearMPAfterSkill
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


NextBattlerTurn::
	xor a
	ld [wTurnOrderPos], a
	ld hl, wBattleStep
	inc [hl]
	ld hl, wSideFlags
	ld a, [hl]
	and $50
	call nz, ClearSideBits50
	inc hl
	ld a, [hl]
	and $50
	call nz, ClearSideBits50
	ret


ClearSideBits50::
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


AllPositionsNextTarget::
jr_052_714c:
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [wHitCount]
	cp $08
	jp nc, EndBattlerAction

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


NextTargetOfGroup::
jr_052_7184:
	ld a, [wReactionKind]
	cp $02
	jp z, InterruptUseSkill

	cp $10
	jr z, jr_052_719c

	cp $04
	jr z, jr_052_7198

	cp $01
	jr nz, jr_052_719c

jr_052_7198:
	call RestoreInterruptedAction
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
	jp z, FinishAction

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


InterruptUseSkill::
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jp c, FinishAction

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
	ld hl, far_StartReactionFar_53
	rst $10
	ret


ActionStepDone::
	xor a
	ld [wBattleSubStep], a
	ld hl, wBattleStep
	inc [hl]
	ret


	db $21, $06, $5f, $d7, $21, $ee, $d9, $34, $c9, $21, $00, $4c, $d7, $21, $ee, $d9
	db $34, $c9

ActionStepDefeat::
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

	ld hl, far_BlankEnemyPicture
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


ActionStepItem::
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
	ld hl, far_FixActionTarget
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
	ld hl, far_GetItemMessage
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


ItemTargetUnfit::
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


ItemCheckTarget::
	ld a, [wBattleItemTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr nz, ItemTargetUnfit

	ld hl, wBattleStepArg0
	inc [hl]
	call UseBattleItem
	ret


ActionStepItemEffect::
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
	jr z, ItemCheckTarget

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
	call FindMeatTarget
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


ActionStepItemTarget::
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, jr_052_7428

	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleItemUsedUp], a
	jr ActionStepItemEnd

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

	call ActionStepDefeat
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


ActionStepItemEnd::
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

	call BadMeatEffect
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
	call FinishAction
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

	jr ActionStepItemAgain

	db $c9

ActionStepFinish::
	call FinishAction
	ret


ActionStepItemAgain::
	ld a, $0a
	ld [wBattleSubStep], a
	ld hl, wBattleStepArg0
	dec [hl]
	ret


BadMeatEffect::
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


ActionStepFinishReset::
	call FinishAction
	ld a, $00
	ld [wBattleSubStep], a
	ret


ActionStepRestart::
	xor a
	ld [wBattleSubStep], a
	ld a, $01
	ld [wBattleSubStep2], a
	ret


ActionStep17::
	ld hl, far_PickConfusedAction_53
	rst $10
	ret


ActionStepCounter::
	ld a, [wBattleSubStep2]
	rst $00

CounterStageTable::
	dw CounterStage0
	dw CounterStageHit
	dw CounterStageEnd
	dw CounterStageUserDown

ActionStepNone::
	ret


FindMeatTarget::
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

CheckBattleOver::
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

	ld hl, far_ShowLinkResultMessage
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
	ld hl, far_ShowVictoryMessage
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


CheckSideDefeated::
	ld bc, $0300
	call IsBattlerOut
	jr nc, jr_052_7795

	inc c
	call IsBattlerOut
	jr nc, jr_052_7795

	inc c
	call IsBattlerOut
	ret c

jr_052_7795:
	ld bc, $0304
	call IsBattlerOut
	jr nc, jr_052_77a7

	inc c
	call IsBattlerOut
	jr nc, jr_052_77a7

	inc c
	call IsBattlerOut

jr_052_77a7:
	ret


IsBattlerOut::
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


Skill3BStage0::
	call CheckUserGone
	ret c

	ld a, [wSkillUser]
	call CheckBattlerPresent
	jp c, StagesEnd

	ld hl, far_StartSkillVisual
	rst $10
	ld hl, far_PlaySkillSound4
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


Skill3BStage1::
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
	jr ShowUserHPLossMessage

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

ShowUserHPLossMessage::
	ld hl, wTextArg1
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [$db5b]
	ld b, a
	call Number16ToDecimal
	ld a, $82
	ld [wBattlerReload], a
	call GetViewSidePos
	cp $04
	jr c, jr_052_785e

	ld hl, wBattlerReload
	inc [hl]

jr_052_785e:
	call IsTargetSameSide
	call z, FlipMessageVariant
	call PrintUserMessage
	ret


IsTargetSameSide::
	ld a, [wSkillUser]
	and $04
	ld b, a
	ld a, [wSkillTarget]
	and $04
	cp b
	ret


FlipMessageVariant::
	ld a, [wBattlerReload]
	xor $01
	ld [wBattlerReload], a
	ret


PickUserDownMessage::
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


KamikazeStage0::
	call CheckUserGone
	ret c

	ld hl, far_StartSkillVisual
	rst $10
	ld hl, far_PlaySkillSound4
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


KamikazeStage1::
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
	call GetViewSidePos
	cp $04
	jr nc, jr_052_78ea

	ld a, $e7
	ld [wBattlerReload], a
	jr jr_052_78ea

jr_052_78e5:
	ld a, $85
	ld [wBattlerReload], a

jr_052_78ea:
	call IsTargetSameSide
	call z, PickUserDownMessage
	call PrintUserMessage
	ret


PrintUserMessage::
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


RecoilStageUserDown::
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
	call UserFalls
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
	call GetViewSidePos
	cp $04
	jr nc, jr_052_7966

	ld a, $e7
	jr jr_052_7968

jr_052_7966:
	ld a, $ea

jr_052_7968:
	ld [wBattlerReload], a
	call IsTargetSameSide
	call z, PickUserDownMessage
	ld a, [wBattlerReload]
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	ret


StagesEnd::
	call CheckBladeCounter
	jp nz, StartBladeCounter

StagesNext::
	ld hl, wBattleSubStep
	inc [hl]
	ld a, $00
	ld [wBattleSubStep2], a
	jp ActionStepNext


StageShowText::
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, far_StartText_4C
	rst $10
	ret


CheckUserGone::
	ld a, [wSkillUser]
	call CheckBattlerPresent
	ret nc

	ld hl, wBattleSubStep
	inc [hl]
	scf
	ret


RammingStage0::
	call CheckUserGone
	ret c

	ld hl, far_StartSkillVisual
	rst $10
	ld hl, far_PlaySkillSound4
	rst $10
	ld hl, wBattleSubStep2
	inc [hl]
	ret


RammingStage1::
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
	call ShowUserHPLossMessage
	ret


	db $fa, $69, $dd, $fe, $01, $20, $06, $3e, $01, $ea, $ed, $d9, $c9, $21, $ee, $d9
	db $34, $c9

UserFalls::
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
	call ActionStepDefeat
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


DeMagicStage0::
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


DeMagicStage1::
	ld a, [wSkillUser]
	ld [wSkillTarget], a
	call TransformIntoTarget
	ret


LifeSongStage0::
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


LifeSongStage1::
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


LifeSongStage2::
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
	jr z, LifeSongStage2

	xor a
	ld [wBattleSubStep2], a
	ret


jr_052_7ab0:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


ChgDragonPickAction::
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

ClearMPAfterSkill::
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


PoisonHitStage0::
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


NapAttackStage0::
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
	call GetViewSidePos
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


ParalyzeStage0::
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


StartBladeCounter::
	ld a, [wInterceptState]
	or a
	jp nz, SkillFollowUp

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
	jp c, StagesNext

	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
	call BattleRandom
	ld b, $00
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
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
	call nz, CounterTextVariant
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


CounterStage0::
	ld hl, wBattleSubStep2
	inc [hl]
	call SwapUserAndTarget
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

	ld hl, far_StartSkillHitEffect
	rst $10
	ld hl, far_PlaySkillSound0
	rst $10
	ld a, $80
	ld [wItemMsgGroup], a
	ret


CounterTextVariant::
	ld a, $6a
	ld [wTextIndex], a
	ret


SwapUserAndTarget::
	ld a, [wSkillUser]
	ld l, a
	ld a, [wSkillTarget]
	ld h, a
	ld a, l
	ld [wSkillTarget], a
	ld a, h
	ld [wSkillUser], a
	ret


CounterStageHit::
	ld hl, wBattleSubStep2
	inc [hl]
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, SwapUserAndTarget

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
	call GetViewSidePos
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
	call SwapUserAndTarget
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


CounterStageUserDown::
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
	ld hl, far_BlankEnemyPicture
	rst $10
	pop af
	ld [wSkillTarget], a
	ret


CounterStageEnd::
	ld a, $05
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


BattleRedraw57::
	ld hl, far_Call_57_7C44
	rst $10
	ret


PrintActionMessage::
	ld a, [wReflectAnim]
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
	ld [wReflectAnim], a
	ret


jr_052_7dc8:
	ld hl, far_PrintBattleMessage
	rst $10
	ret


GetUserStatus4::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ret


CheckTargetReacts::
	ld a, [wSkillId]
	cp $7f
	jr nz, jr_052_7de0

jr_052_7dde:
	xor a
	ret


jr_052_7de0:
	ld a, [wInterceptState]
	or a
	jr nz, jr_052_7dde

	ld a, [wReactionKind]
	or a
	jr z, jr_052_7df9

	cp $08
	jr z, jr_052_7dde

	cp $20
	jr nz, jr_052_7dde

	call RestoreInterruptedAction
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
	call PrintTargetMessage
	ld a, $08
	ld [wReactionKind], a
	ld a, $08
	ld [wBattleArg0], a
	ld hl, far_StartReactionFar_53
	rst $10
	xor a
	ld [wHitShown], a
	scf
	ret


jr_052_7e44:
	ld a, $d4
	call PrintTargetMessage
	xor a
	ret


	db $fa, $89, $db, $21, $03, $db, $cd, $6c, $2f, $fa, $fd, $dc, $cb, $77, $20, $09
	db $cb, $6f, $20, $0f, $cb, $67, $20, $0e, $c9, $cb, $46, $20, $dc, $fa, $00, $db
	db $cb, $5f, $c9, $cb, $76, $c9, $cb, $7e, $c9

PrintTargetMessage::
	push af
	call TargetNameToArg0
	pop af
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	ret


PrepareRedirect::
	ld a, [wInterceptState]
	or a
	ret z

	cp $01
	jr z, jr_052_7e96

	ld a, [wReflectAnim]
	cp $02
	jr z, LoadActionTarget

	ret


jr_052_7e96:
	call LoadActionTarget
	ld hl, wBattlerStatus6
	call AddEightTimes
	res 4, [hl]
	inc hl
	ld a, [hl]
	and $0f
	ld [hl], a
	ret


LoadActionTarget::
	ld a, [wSkillUser]
	ld hl, $dced
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
	ret


ActionStepItemFails::
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
	call FinishAction
	ret


ActionStep6E0E::
	ld hl, far_Call_57_6E0E
	rst $10
	ret


ActionStep5C48::
	ld hl, far_PickTargetForSkill
	rst $10
	ret


ActionStepFall::
	ld hl, far_BattlerFallSequence
	rst $10
	ret


ActionStepWaitClose::
	ld a, [wTextState]
	or a
	ret nz

	call CloseAction
	ret


RestoreInterruptedAction::
	ld a, [wReactionKind]
	or a
	jp z, ReturnCarry52

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
	ld a, [wReactionKind]
	cp $40
	jp z, ReturnCarry52

	cp $01
	jr z, jr_052_7f9e

	cp $02
	jr z, jr_052_7f55

	cp $04
	call z, InterruptEndMessage

jr_052_7f4e:
	ld a, $00
	ld [wReactionKind], a
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
	ld [wReflectAnim], a
	jr jr_052_7f4e

InterruptEndMessage::
	ld a, [wReflectAnim]
	cp $07
	ret nz

	ld a, $de
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
	ld [wReflectAnim], a
	ld hl, far_StartText_4C
	rst $10
	ret


ReturnCarry52::
jr_052_7fc9:
	scf
	ret


GetViewSidePos::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

	ld a, [wSkillUser]
	ret


CheckFarSideEmpty::
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
