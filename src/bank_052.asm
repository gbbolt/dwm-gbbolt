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
;@ for the message and animation steps that follow. Numbers $B0-$D4 are the battle items,
;@ which have their own routines (UseBattleItem, BattleItemEffects); their entries here
;@ point at SkillAttack.
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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

;>@g1     if wSkillTarget != ((wSkillTarget & 4) | 2):
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;> CureAilments_53()
	ld hl, far_CureAilments_53
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
;@ test: wSkillTarget = rand(0, 7)
;@ test: wSkillUser = rand(0, 7)
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
;> SetUpCalledMonster()                   # the one for wSkillId
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
;@ test: wSkillUser = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
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
;@ test: wSkillTarget = rand(0, 7)
;@ test: wSkillUser = rand(0, 7)
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
;@ test: pos = rand(0, 7)
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
;@ MonsterPicRefs (bank, entry), then the battle palettes are rebuilt.
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
;>@r ref = mem16[MonsterPicRefs + 2 * species]
	push hl
	ld l, c
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(MonsterPicRefs)
;=@r
	ld l, a
	ld a, h
	adc HIGH(MonsterPicRefs)
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
;@ test: pos = rand(0, 7)
GetBaseMaxHP::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> CalcBaseMaxHP()
	ld hl, far_CalcBaseMaxHP
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
;@ test: pos = rand(0, 7)
GetBaseMaxMP::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> CalcBaseMaxMP()
	ld hl, far_CalcBaseMaxMP
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
;@ test: pos = rand(0, 7)
GetBaseAttack::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> CalcBaseAttack()
	ld hl, far_CalcBaseAttack
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
;@ test: pos = rand(0, 7)
GetBaseDefense::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> CalcBaseDefense()
	ld hl, far_CalcBaseDefense
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
;@ test: pos = rand(0, 7)
GetBaseAgility::
;> wBattleTemp = pos
	push hl
	ld [wBattleTemp], a
;> CalcBaseAgility()
	ld hl, far_CalcBaseAgility
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
;@ test: pos = rand(0, 7)
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
;@ test: pos = rand(0, 7)
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
;@ test: pos = rand(0, 7)
MarkStatsChanged::
;> wBattlerStatus[8 * pos + 6] |= 0xC0
	push hl
	ld hl, wBattlerStatus6
	call AddEightTimes
	ld a, [hl]
	or $c0
	ld [hl], a
;> return
	pop hl
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
;@ test: wSkillTarget = rand(0, 7)
TargetStatus3::
;> return wBattlerStatus + 8 * wSkillTarget + 3    # address of status byte 3
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
;@ test: wSkillTarget = rand(0, 7)
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


;@ path: battle/item/effects
;@ Effect routine of each battle item, by item effect number - $B0 (wBattleItemEffect, from
;@ the item data): Herb, HealWater, SageStone, WorldDew, Potion, ElfWater, Antidote, MoonHerb,
;@ SkyBell, Laurel, AwakeSand, WorldLeaf, the six seeds and nuts ($BC-$C1, no battle effect),
;@ FeedMeat, BeefJerky, PorkChop, BadMeat, Sirloin, the staffs Bolt, Vacuum, Block, Lava and
;@ Snow ($C7-$CB), nothing for $CC-$D3, and the fire staff routine at $D4.
BattleItemEffects::
	dw ItemHealHP       ; $B0 Herb
	dw ItemHealHP       ; $B1 HealWater
	dw ItemHealHP       ; $B2 SageStone
	dw ItemHealHP       ; $B3 WorldDew
	dw ItemHealMP       ; $B4 Potion
	dw ItemHealMP       ; $B5 ElfWater
	dw ItemAntidote     ; $B6 Antidote
	dw ItemMoonHerb     ; $B7 MoonHerb
	dw ItemSkyBell      ; $B8 SkyBell
	dw ItemLaurel       ; $B9 Laurel
	dw ItemAwakeSand    ; $BA AwakeSand
	dw ItemWorldLeaf    ; $BB WorldLeaf
	dw ItemNone         ; $BC LifeAcorn
	dw ItemNone         ; $BD MysticNut
	dw ItemNone         ; $BE PwrSeed
	dw ItemNone         ; $BF DefSeed
	dw ItemNone         ; $C0 AgilSeed
	dw ItemNone         ; $C1 IntSeed
	dw ItemMeat         ; $C2 FeedMeat
	dw ItemMeat         ; $C3 BeefJerky
	dw ItemMeat         ; $C4 PorkChop
	dw ItemBadMeat      ; $C5 BadMeat
	dw ItemMeat         ; $C6 Sirloin
	dw ItemBoltStaff    ; $C7 BoltStaff
	dw ItemVacuumStaff  ; $C8 (Vacuum) Staff
	dw ItemBlockStaff   ; $C9 BlockStaff
	dw ItemLavaStaff    ; $CA LavaStaff
	dw ItemSnowStaff    ; $CB SnowStaff
	dw ItemNone         ; $CC
	dw ItemNone         ; $CD
	dw ItemNone         ; $CE
	dw ItemNone         ; $CF
	dw ItemNone         ; $D0
	dw ItemNone         ; $D1
	dw ItemNone         ; $D2
	dw ItemNone         ; $D3
	dw ItemFireStaff    ; $D4

;@ def ItemNoEffect()
;@ path: battle/item/effects
;@ The item does nothing: "But nothing happens!" (message $BB). wSkillId is cleared, except
;@ for WorldDew ($B3), whose later steps go on.
ItemNoEffect::
;> if wBattleItemEffect != 0xB3:
;>     wSkillId = 0
	ld a, [wBattleItemEffect]
	cp $b3
	jr z, ItemNothingHappens

	xor a
	ld [wSkillId], a
;> ItemNothingHappens()                              # (falls through)
;> return

;@ def ItemNothingHappens()
;@ path: battle/item/effects
;@ Message $BB "But nothing happens!" (ItemShowFailMessage).
ItemNothingHappens::
;> wBattlerReload = 0xBB
	ld a, $bb
	ld [wBattlerReload], a
;> ItemShowFailMessage()                             # (falls through)
;> return

;@ def ItemShowFailMessage()
;@ path: battle/item/effects
;@ Shows battle message wBattlerReload (text group 0) as the item's result, message mode 0.
ItemShowFailMessage::
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;> wTextIndex = wBattlerReload
	ld a, [wBattlerReload]
	ld [wTextIndex], a
;> wSkillMsgMode = 0
	ld a, $00
	ld [wSkillMsgMode], a
;> return
	ret

;@ def ItemShowUseMessage()
;@ path: battle/item/effects
;@ Shows the item's result: refreshes the target's status icon, puts the target's name into
;@ wTextArg0 and the player's name into wTextArg2; for the meats ($C2-$C6) bank $58's
;@ SetNameFormMessage (entry 9) picks a text of group 1, otherwise message wBattlerReload of
;@ group 0. wSkillId becomes the item's effect number, message mode 1.
;@ test: skip far calls into the battle panel and message banks
ItemShowUseMessage::
;> wSkillId = 1
	ld a, $01
	ld [wSkillId], a
;> UpdateStatusIcon_50()
	ld a, [wSkillTarget]
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> TargetNameToArg0()
	call TargetNameToArg0
;> CopyName(wPlayerName, wTextArg2)
	ld de, wPlayerName
	ld hl, wTextArg2
	call CopyName
;> if 0xC2 <= wBattleItemEffect < 0xC7:              # the meats
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, .plain

	cp $c7
	jr nc, .plain

;>     SetNameFormMessage()                          # bank $58 entry 9
	ld hl, far_SetNameFormMessage
	rst $10
;>     wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
	jr .done

;> else:
;>@p1     wTextIndex = wBattlerReload
.plain
;=@p1
	ld a, [wBattlerReload]
	ld [wTextIndex], a
;>@p2     wTextGroup = 0
;=@p2
	ld a, $00
	ld [wTextGroup], a

.done
;> wSkillId = wBattleItemEffect
	ld a, [wBattleItemEffect]
	ld [wSkillId], a
;> wSkillMsgMode = 1
	ld a, $01
	ld [wSkillMsgMode], a
;> return
	ret
;@ def ItemNone()
;@ path: battle/item/effects
;@ Items without an effect in battle: nothing.
ItemNone::
;> return
	ret

;@ def ItemHealHP()
;@ path: battle/item/effects
;@ Herb, HealWater, SageStone and WorldDew ($B0-$B3): heal the target's HP by the item table's
;@ amount plus its random spread (GetSkillValue + AddSkillSpread, own-side or enemy field), up
;@ to the maximum; WorldDew heals fully. WorldDew covers the whole side one monster per step
;@ (wHitCount): on its first step it checks that some monster of that side is in the fight
;@ without full HP, else "But nothing happens!". Healing an enemy adds half the amount to
;@ wJoinPoints. Message "X's wound heals!", sound $70 for own monsters, the skill visual.
;@ test: skip far calls into the skill table and IsHPFull (still data)
ItemHealHP::
;> if wBattleItemEffect == 0xB3:                     # WorldDew
	ld a, [wBattleItemEffect]
	cp $b3
	jr nz, .normal

;>     wHitCount += 1
	ld hl, wHitCount
	inc [hl]
;>@first     if wHitCount == 1:
	ld a, [wHitCount]
	cp $01
	jr nz, .dew

;>@side         pos = wSkillTarget & 4
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $03

;>@loop         for pos in range(pos, pos + 3):
.check
;>             if not CheckBattlerPresent(pos) and not IsHPFull(pos):   # IsHPFull at $69EF
;>@br                 break
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	ld a, c
	call IsHPFull
	jr nz, .dew

.next
;=@loop
	inc c
	dec b
	jr nz, .check

;>@el         else:
;>             wSkillId = 0
	xor a
	ld [wSkillId], a
;>             return ItemNothingHappens()
	jp ItemNothingHappens

;>@dew     if IsHPFull(wSkillTarget):
.dew
;=@dew
	ld a, [wSkillTarget]
	call IsHPFull
	jp z, ItemNoEffect

;>@dew1         return ItemNoEffect()
;>@full     wSkillAmount2 = GetBattlerMaxHP(wSkillTarget) - mem16[wBattlerHP + 2 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@full
	ld a, [wSkillTarget]
	call GetBattlerMaxHP
	sub c
	ld l, a
	ld a, h
	sbc b
;=@full
	ld h, a
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
	jp .apply

;> else:
;>@n1     if IsHPFull(wSkillTarget):
.normal
;=@n1
	ld a, [wSkillTarget]
	call IsHPFull
	jp z, ItemNoEffect

;>@n2         return ItemNoEffect()
;>@n3     wBattleArg2 = 0x0F if wSkillTarget >= 4 else 0x0B   # enemy / own table field
;=@n3
	ld a, [wSkillTarget]
	cp $04
	jr c, .own

	ld a, $0f
	ld [wBattleArg2], a
	jr .value

.own
;=@n3
	ld a, $0b
	ld [wBattleArg2], a

.value
;>     GetSkillValue()
	ld hl, far_GetSkillValue
	rst $10
;>@sp     wSkillAmount2 = AddSkillSpread(wBattleArg0 | wBattleArg1 << 8)
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	call AddSkillSpread
	ld a, l
;=@sp
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;>@hp     hp = (GetBattlerHP(wSkillTarget) + wSkillAmount2) & 0xFFFF
	push hl
	ld a, [wSkillTarget]
	call GetBattlerHP
	pop bc
	add hl, bc
;>@cmp     if GetBattlerMaxHP(wSkillTarget) < hp:
	push hl
	ld a, [wSkillTarget]
	call GetBattlerMaxHP
	pop bc
	call CompareHLBC
	jr nc, .apply

;>@cut         wSkillAmount2 -= hp - GetBattlerMaxHP(wSkillTarget)
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;=@cut
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [wSkillAmount2 + 1]
	ld h, a
	ld a, l
	sub c
;=@cut
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, l
	ld [wSkillAmount2], a
;=@cut
	ld a, h
	ld [wSkillAmount2 + 1], a

.apply
;>@ad mem16[wBattlerHP + 2 * wSkillTarget] += wSkillAmount2
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@ad
	ld l, a
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
	add hl, bc
;=@ad
	ld b, h
	ld c, l
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
;>@ie if wSkillTarget & 4:                              # an enemy
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [wSkillAmount2 + 1]
	ld h, a
	ld a, [wSkillTarget]
	bit 2, a
;=@ie
	jr z, .msg

;>     AddJoinPoints(wSkillAmount2 >> 1)
	ld b, h
	ld c, l
	call ShiftBC1
	call AddJoinPoints

.msg
;> wBattlerReload = 0x84                             # "X's wound heals!"
	ld a, $84
	ld [wBattlerReload], a
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;> wSkillMsgMode = 0
	xor a
	ld [wSkillMsgMode], a
;> return
	ret

;@ def ItemHealMP()
;@ path: battle/item/effects
;@ Potion and ElfWater ($B4, $B5): restore the target's MP by the item table's amount plus its
;@ random spread, up to the maximum; ElfWater fills them. At full MP "But nothing happens!".
;@ Restoring an enemy's MP adds the amount to wJoinPoints. Message "X recovers MP!", sound $70
;@ for own monsters.
;@ test: skip far calls into the skill table
ItemHealMP::
;> if wBattleItemEffect == 0xB5:                     # ElfWater
	ld a, [wBattleItemEffect]
	cp $b5
	jr nz, .normal

;>     if IsMPFull(wSkillTarget):
;>@e1         return ItemNoEffect()
	ld a, [wSkillTarget]
	call IsMPFull
	jp z, ItemNoEffect

;>@full     wSkillAmount2 = GetBattlerMaxMP(wSkillTarget) - mem16[wBattlerMP + 2 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@full
	ld a, [wSkillTarget]
	call GetBattlerMaxMP
	sub c
	ld l, a
	ld a, h
	sbc b
;=@full
	ld h, a
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
	jp .apply

;> else:
;>@n1     if IsMPFull(wSkillTarget):
.normal
;=@n1
	ld a, [wSkillTarget]
	call IsMPFull
	jp z, ItemNoEffect

;>@n2         return ItemNoEffect()
;>@n3     wBattleArg2 = 0x10 if wSkillTarget >= 4 else 0x0B
;=@n3
	ld a, [wSkillTarget]
	cp $04
	jr c, .own

	ld a, $10
	ld [wBattleArg2], a
	jr .value

.own
;=@n3
	ld a, $0b
	ld [wBattleArg2], a

.value
;>     GetSkillValue()
	ld hl, far_GetSkillValue
	rst $10
;>@sp     wSkillAmount2 = AddSkillSpread(wBattleArg0 | wBattleArg1 << 8)
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	call AddSkillSpread
	ld a, l
;=@sp
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;>@mp     mp = (GetBattlerMP(wSkillTarget) + wSkillAmount2) & 0xFFFF
	push hl
	ld a, [wSkillTarget]
	call GetBattlerMP
	pop bc
	add hl, bc
;>@cmp     if GetBattlerMaxMP(wSkillTarget) < mp:
	push hl
	ld a, [wSkillTarget]
	call GetBattlerMaxMP
	pop bc
	call CompareHLBC
	jr nc, .apply

;>@cut         wSkillAmount2 -= mp - GetBattlerMaxMP(wSkillTarget)
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
;=@cut
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [wSkillAmount2 + 1]
	ld h, a
	ld a, l
	sub c
;=@cut
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, l
	ld [wSkillAmount2], a
;=@cut
	ld a, h
	ld [wSkillAmount2 + 1], a

.apply
;>@ad mem16[wBattlerMP + 2 * wSkillTarget] += wSkillAmount2
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@ad
	ld l, a
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
	add hl, bc
;=@ad
	ld b, h
	ld c, l
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
;>@ie if wSkillTarget & 4:                              # an enemy
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [wSkillAmount2 + 1]
	ld h, a
	ld a, [wSkillTarget]
	bit 2, a
;=@ie
	jr z, .msg

;>     AddJoinPoints(wSkillAmount2)
	ld b, h
	ld c, l
	call AddJoinPoints

.msg
;> wBattlerReload = 0x76                             # "X recovers MP!"
	ld a, $76
	ld [wBattlerReload], a
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> return
	ret

;@ def ItemAntidote()
;@ path: battle/item/effects
;@ Antidote ($B6): cures poison (bits 0-1 of status byte 0): "X is no longer poisoned!"; an
;@ enemy cured adds 100 join points. Not poisoned: "But nothing happens!".
ItemAntidote::
;> wBattlerReload = 0x9C                             # "X is no longer poisoned!"
	ld a, $9c
	ld [wBattlerReload], a
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not wBattlerStatus[st] & 0x03:
;>@u     return ItemUseless()
	ld a, [hl]
	and $03
	jr nz, .cure

	call ItemUseless
	ret


.cure
;> wBattlerStatus[st] &= 0xFC
	ld a, [hl]
	and $fc
	ld [hl], a
;> ItemCuredEnemy()
	call ItemCuredEnemy
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> return
	ret

;@ def ItemMoonHerb()
;@ path: battle/item/effects
;@ MoonHerb ($B7): cures paralysis (bit 6 of status byte 0), the monster loses this turn
;@ (code at $6B0B): "X is no longer paralyzed!". Not paralyzed: "But nothing happens!".
;@ test: skip calls code at $6B0B that has no label yet
ItemMoonHerb::
;> wBattlerReload = 0x9D                             # "X is no longer paralyzed!"
	ld a, $9d
	ld [wBattlerReload], a
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not wBattlerStatus[st] & 0x40:
;>@u     return ItemUseless()
	ld a, [hl]
	and $40
	jr nz, .cure

	call ItemUseless
	ret


.cure
;> TargetLosesTurn()
	call TargetLosesTurn
;> wBattlerStatus[st] &= 0xBF
	ld a, [hl]
	and $bf
	ld [hl], a
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> return
	ret

;@ def ItemSkyBell()
;@ path: battle/item/effects
;@ SkyBell ($B8): ends confusion (bit 4 of status byte 0), the monster loses this turn: "X
;@ returns to normal!". Not confused: "But nothing happens!".
;@ test: skip calls code at $6B0B that has no label yet
ItemSkyBell::
;> wBattlerReload = 0xDC                             # "X returns to normal!"
	ld a, $dc
	ld [wBattlerReload], a
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not wBattlerStatus[st] & 0x10:
;>@u     return ItemUseless()
	ld a, [hl]
	and $10
	jr nz, .cure

	call ItemUseless
	ret


.cure
;> TargetLosesTurn()
	call TargetLosesTurn
;> wBattlerStatus[st] &= 0xEF
	ld a, [hl]
	and $ef
	ld [hl], a
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> return
	ret

;@ def ItemLaurel()
;@ path: battle/item/effects
;@ Laurel ($B9): lifts the curse (bit 5 of status byte 0): "X is no longer cursed!". Not
;@ cursed: "But nothing happens!".
ItemLaurel::
;> wBattlerReload = 0x9F                             # "X is no longer cursed!"
	ld a, $9f
	ld [wBattlerReload], a
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not wBattlerStatus[st] & 0x20:
;>@u     return ItemUseless()
	ld a, [hl]
	and $20
	jr nz, .cure

	call ItemUseless
	ret


.cure
;> wBattlerStatus[st] &= 0xDF
	ld a, [hl]
	and $df
	ld [hl], a
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> return
	ret

;@ def ItemAwakeSand()
;@ path: battle/item/effects
;@ AwakeSand ($BA): wakes the target (clears the sleep bits $8C of status byte 0), which loses
;@ this turn: "X wakes up!". Not asleep: "But nothing happens!".
;@ test: skip calls code at $6B0B that has no label yet
ItemAwakeSand::
;> wBattlerReload = 0xDB                             # "X wakes up!"
	ld a, $db
	ld [wBattlerReload], a
;> st = 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;> if not wBattlerStatus[st] & 0x8C:
;>@u     return ItemUseless()
	ld a, [hl]
	and $8c
	jr nz, .cure

	call ItemUseless
	ret


.cure
;> TargetLosesTurn()
	call TargetLosesTurn
;> wBattlerStatus[st] &= 0x73
	ld a, [hl]
	and $73
	ld [hl], a
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> ItemHealSound()
	call ItemHealSound
;> return
	ret

;@ def ItemWorldLeaf()
;@ path: battle/item/effects
;@ WorldLeaf ($BB): brings a fallen monster back with full HP (its skills reloaded by bank
;@ $51, ResetBattler): "X is revived!". A standing monster or an empty position: "But nothing
;@ happens!".
;@ test: skip far call that reloads the battler's skills
ItemWorldLeaf::
;>@st if CheckBattlerPresent(wBattleItemTarget) and wBattlerState[wBattleItemTarget] != 0xFF:
	ld a, [wBattleItemTarget]
	call CheckBattlerPresent
	jr nc, .useless

	jr z, .useless

;>     wBattleArg0 = wBattleItemTarget
	ld a, [wBattleItemTarget]
	ld [wBattleArg0], a
;>     LoadBattlerSkills()
	ld hl, far_LoadBattlerSkills
	rst $10
;>     ResetBattler(wBattleItemTarget)
	ld a, [wBattleItemTarget]
	ld b, a
	call ResetBattler
;>@hp     mem16[wBattlerHP + 2 * pos] = mem16[wBattlerMaxHP + 2 * pos]
	ld a, b
	ld hl, wBattlerHP
	call IndexWords
	ld d, h
	ld e, l
	ld a, b
;=@hp
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
;=@hp
	ld [de], a
;>     wBattlerReload = 0x9E                         # "X is revived!"
	ld a, $9e
	ld [wBattlerReload], a
;>     return ItemShowUseMessage()
	call ItemShowUseMessage
	ret


.useless
;> ItemUseless()
	call ItemUseless
;> return
	ret

;@ def ItemMeat()
;@ path: battle/item/effects
;@ FeedMeat, BeefJerky, PorkChop and Sirloin ($C2-$C4, $C6): thrown to an enemy they add the
;@ item table's value to wJoinPoints (at most 1600); given to an own monster they lower its
;@ wildness by that value (not below 0). Then the treat message (ItemShowUseMessage).
;@ test: skip far call into the skill table
ItemMeat::
;> wSkillId = 1
	ld a, $01
	ld [wSkillId], a
;> if wBattleItemTarget >= 4:                         # an enemy
	ld a, [wBattleItemTarget]
	cp $04
	jr c, .own

;>@pt     points = wJoinPoints
	sub $04
	ld hl, wJoinPoints
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@pt
	push hl
;>     wBattleArg2 = 0x0F
	ld a, $0f
	ld [wBattleArg2], a
;>     GetSkillValue()
	ld hl, far_GetSkillValue
	rst $10
;>@add     wJoinPoints = min(points + (wBattleArg0 | wBattleArg1 << 8), 0x640)
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, [wBattleArg0]
	ld c, a
;=@add
	ld a, [wBattleArg1]
	ld b, a
	pop hl
	add hl, bc
	ld bc, $0640
	call CompareHLBC
;=@add
	ld b, h
	ld c, l
	jr c, .storePoints

	ld bc, $0640

.storePoints
;=@add
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
	jr .msg

;> else:
;>@w1     p = wBattlerWildness + 2 * wBattleItemTarget
.own
;=@w1
	ld hl, wBattlerWildness
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@w1
	push hl
;>@w2     wBattleArg2 = 0x0B
;=@w2
	ld a, $0b
	ld [wBattleArg2], a
;>@w3     GetSkillValue()
;=@w3
	ld hl, far_GetSkillValue
	rst $10
;>@w4     mem16[p] = max(mem16[p] - (wBattleArg0 | wBattleArg1 << 8), 0)
;=@w4
	pop hl
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
	ld a, l
;=@w4
	sub c
	ld c, a
	ld a, h
	sbc b
	ld b, a
	jr nc, .storeWild

;=@w4
	ld bc, $0000

.storeWild
;=@w4
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b

.msg
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> wMonStats = 0
	xor a
	ld [wMonStats], a
;> return
	ret

;@ def ItemBadMeat()
;@ path: battle/item/effects
;@ BadMeat ($C5): an enemy's join points go up by just 5 (at most 1024), an own monster's
;@ wildness down by 5 (not below 0). Then the treat message.
;@ test: skip the treat message calls other banks
ItemBadMeat::
;> wSkillId = 1
	ld a, $01
	ld [wSkillId], a
;> if wBattleItemTarget >= 4:
	ld a, [wBattleItemTarget]
	cp $04
	jr c, .own

;>@pt     wJoinPoints = min(wJoinPoints + 5, 0x400)
	sub $04
	ld hl, wJoinPoints
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
;=@pt
	ld bc, $0005
	add hl, bc
	ld bc, $0400
	call CompareHLBC
	ld b, h
	ld c, l
;=@pt
	jr c, .store

	ld bc, $0400
	jr .store

;> else:
;>@w     p = wBattlerWildness + 2 * wBattleItemTarget; mem16[p] = max(mem16[p] - 5, 0)
.own
;=@w
	ld hl, wBattlerWildness
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
	sub $05
;=@w
	ld l, a
	ld a, h
	sbc $00
	ld h, a
	ld b, h
	ld c, l
;=@w
	jr nc, .store

	ld bc, $0000

.store
;=@pt
;=@w
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> wMonStats = 0
	xor a
	ld [wMonStats], a
;> return
	ret

;@ def ItemBoltStaff()
;@ path: battle/item/effects
;@ BoltStaff ($C7): "The bolt bursts out of the staff": the item table's damage scaled by the
;@ target's resistance 4 (lightning), then StaffStrike. Nothing when the target is gone.
;@ ResistDamageA gets hl = 0 from RollStaffDamage instead of the status address, so its
;@ magic-wall bits come from ROM address 0.
;@ test: skip far call into the skill table
ItemBoltStaff::
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> status = RollStaffDamage()                        # always 0
	call RollStaffDamage
;> ResistDamageA(status, (GetResistByte1() >> 4) & 3)
	call GetResistByte1
	swap a
	and $03
	call ResistDamageA
;> StaffStrike()
	call StaffStrike
;> return
	ret

;@ def ItemVacuumStaff()
;@ path: battle/item/effects
;@ The vacuum staff ($C8, "It creates a whirling vacuum"): damage scaled by resistance 3
;@ (wind), then StaffStrike.
;@ test: skip far call into the skill table
ItemVacuumStaff::
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> status = RollStaffDamage()
	call RollStaffDamage
;> ResistDamageA(status, (GetResistByte1() >> 6) & 3)
	call GetResistByte1
	rlca
	rlca
	and $03
	call ResistDamageA
;> StaffStrike()
	call StaffStrike
;> return
	ret

;@ def ItemBlockStaff()
;@ path: battle/item/effects
;@ BlockStaff ($C9, "A mysterious mist covers everything"): suspends the target's spells like
;@ StopSpell when RollStopSpell works: "X's spells are all suspended!", else "Has no effect on
;@ X!". Nothing when the target is gone or already blocked.
;@ test: skip the messages call other banks
ItemBlockStaff::
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> if wBattlerStatus[8 * wSkillTarget + 1] & 0x01:
;>     return
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 0, [hl]
	ret nz

;>@r if not RollStopSpell():
	call RollStopSpell
	jr nc, .resisted

;>@r1     return ItemNoEffectOnTarget()
;> wSkillId = 1
	ld a, $01
	ld [wSkillId], a
;> wBattlerStatus[8 * wBattleItemTarget + 1] |= 0x01
	ld a, [wBattleItemTarget]
	ld hl, wBattlerStatus1
	call AddEightTimes
	set 0, [hl]
;> wBattlerReload = 0x88                             # "X's spells are all suspended!"
	ld a, $88
	ld [wBattlerReload], a
	jr .msg

.resisted
;=@r1
	call ItemNoEffectOnTarget
	ret

.msg
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> return
	ret

;@ def ItemLavaStaff()
;@ path: battle/item/effects
;@ LavaStaff ($CA, "Hot lava floods the ground"): damage scaled by resistance 1, then
;@ StaffStrike.
;@ test: skip far call into the skill table
ItemLavaStaff::
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> status = RollStaffDamage()
	call RollStaffDamage
;> ResistDamageA(status, (GetResistByte0() >> 2) & 3)
	call GetResistByte0
	rrca
	rrca
	and $03
	call ResistDamageA
;> StaffStrike()
	call StaffStrike
;> return
	ret

;@ def ItemSnowStaff()
;@ path: battle/item/effects
;@ SnowStaff ($CB, "An icy blizzard blasts out"): damage scaled by resistance 17 (bits 2-3 of
;@ resistance byte 4, the ice breaths), then StaffStrike.
;@ test: skip far call into the skill table
ItemSnowStaff::
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> status = RollStaffDamage()
	call RollStaffDamage
;> ResistDamageA(status, (GetResistByte4() >> 2) & 3)
	call GetResistByte4
	rrca
	rrca
	and $03
	call ResistDamageA
;> StaffStrike()
	call StaffStrike
;> return
	ret

;@ def ItemFireStaff()
;@ path: battle/item/effects
;@ The fire staff (effect $D4, the last entry of BattleItemEffects): damage scaled by
;@ resistance 0 (Blaze), then StaffStrike.
;@ test: skip far call into the skill table
ItemFireStaff::
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> status = RollStaffDamage()
	call RollStaffDamage
;> ResistDamageA(status, (GetResistByte0() >> 4) & 3)
	call GetResistByte0
	swap a
	and $03
	call ResistDamageA
;> StaffStrike()
	call StaffStrike
;> return
	ret

;@ def RollStaffDamage() -> hl
;@ path: battle/item/effects
;@ A staff's damage: the item table's value (own-side field $0B) plus its random spread into
;@ wSkillAmount; the message will be $82 ("X takes N damage pts!"). Returns hl = 0.
;@ test: skip far call into the skill table
RollStaffDamage::
;> wBattleArg2 = 0x0B
	ld a, $0b
	ld [wBattleArg2], a
;> GetSkillValue()
	ld hl, far_GetSkillValue
	rst $10
;> wBattlerReload = 0x82
	ld a, $82
	ld [wBattlerReload], a
;> wItemMsgGroup = 0
	ld a, $00
	ld [wItemMsgGroup], a
;> AddSkillSpread(wBattleArg0 | wBattleArg1 << 8)
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	call AddSkillSpread
;> return 0
	ld hl, $0000
	ret

;@ def StaffStrike()
;@ path: battle/item/effects
;@ A staff hits with wSkillAmount: unless it is 0 or the target's stance takes it all
;@ (StanceReduceDamage), the damage is dealt (ItemDealDamage), the hit effect starts and the
;@ skill sound plays; otherwise ItemStaffMisses.
;@ test: skip starts the hit effects in other banks
StaffStrike::
;> dmg = wSkillAmount
	ld a, [wSkillAmount]
	ld e, a
	ld a, [wSkillAmount + 1]
	ld d, a
;> if dmg and not StanceReduceDamage(dmg):
	ld a, e
	or d
	jr z, .miss

	call StanceReduceDamage
	jr c, .miss

;>     ItemDealDamage(wSkillAmount)
	call ItemDealDamage
;>     StartSkillHitEffect()
	ld hl, far_StartSkillHitEffect
	rst $10
;>     PlaySkillSound2()
	ld hl, far_PlaySkillSound2
	rst $10
	jr .done

;> else:
;>@m     ItemStaffMisses()
.miss
;=@m
	call ItemStaffMisses

.done
;> return
	ret

;@ def StanceReduceDamage(dmg: de) -> carry
;@ path: battle/item/effects
;@ The target's defence stance (low bits of status byte 7) cuts a staff's damage: StrongD
;@ (bit 1) to a tenth, Defence (bit 0) to half; the result goes into wSkillAmount. Carry when
;@ nothing is left; no carry without a stance.
;@ test: wSkillTarget = rand(0, 7)
StanceReduceDamage::
;> stance = wBattlerStatus[8 * wSkillTarget + 7] & 3
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	ld a, [hl]
	and $03
;> if stance == 0:
;>@n     return False
	jr z, .none

;> if not stance & 2:
;>     dmg >>= 1
	ld h, d
	ld l, e
	bit 1, a
	jr nz, .tenth

	call ShiftHL1
	jr .store

;> else:
;>@t     dmg = dmg // 10
.tenth
;=@t
	ld a, $0a
	call Divide16

.store
;> wSkillAmount = dmg
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;>@z return dmg == 0
	ld d, h
	ld e, l
	ld a, h
	or l
	jr nz, .none

;=@z
	scf
	ret

.none
;=@n
	xor a
	ret

;@ def ItemDealDamage(dmg: de)
;@ path: battle/item/effects
;@ A staff's damage to the target: its HP drop by `dmg` (wSkillAmount2 holds what was taken);
;@ at 0 the target falls (bit 0 of its wBattlerState). Half the damage comes off wJoinPoints
;@ (whichever side the target is on). Message $82 with the number (DamageToText).
;@ test: skip the message calls other banks
ItemDealDamage::
;> wSkillId = 1
	ld a, $01
	ld [wSkillId], a
;>@p wSkillStatusPtr = wBattlerHP + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerHP
	call IndexWords
	ld a, l
	ld [wSkillStatusPtr], a
	ld a, h
;=@p
	ld [wSkillStatusPtr + 1], a
;>@h hp = mem16[wSkillStatusPtr] - dmg
	ld a, [hli]
	ld h, [hl]
	sub e
	ld c, a
	ld a, h
	sbc d
;=@h
	ld b, a
;>@a wSkillAmount2 = dmg
	ld a, e
	ld [wSkillAmount2], a
	ld a, d
	ld [wSkillAmount2 + 1], a
;> if hp < 0:
	jr nc, .store

;>@all     wSkillAmount2 = mem16[wSkillStatusPtr]     # all it had
	ld a, [wSkillStatusPtr]
	ld l, a
	ld a, [wSkillStatusPtr + 1]
	ld h, a
	ld a, [hli]
	ld d, [hl]
;=@all
	ld e, a
	ld a, e
	ld [wSkillAmount2], a
	ld a, d
	ld [wSkillAmount2 + 1], a
;>     hp = 0
	ld bc, $0000
;>@f     wBattlerState[wSkillTarget] |= 0x01           # falls
	ld a, [wSkillTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@f
	ld h, a
	set 0, [hl]

.store
;>@sj SubJoinPoints(wSkillAmount2 >> 1)
	push bc
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
	call ShiftBC1
;=@sj
	call SubJoinPoints
	pop bc
;>@w mem16[wSkillStatusPtr] = hp
	ld a, [wSkillStatusPtr]
	ld l, a
	ld a, [wSkillStatusPtr + 1]
	ld h, a
	ld a, c
	ld [hli], a
;=@w
	ld [hl], b
;> wBattlerReload = 0x82                             # "X takes N damage pts!"
	ld a, $82
	ld [wBattlerReload], a
;> DamageToText()
	call DamageToText
;> ItemShowUseMessage()
	call ItemShowUseMessage
;> return
	ret

;@ def ItemStaffMisses()
;@ path: battle/item/effects
;@ A staff that does no damage: 2 join points are lost, then ItemNoEffectOnTarget.
ItemStaffMisses::
;> SubJoinPoints(2)
	ld bc, $0002
	call SubJoinPoints
;> ItemNoEffectOnTarget()                            # (falls through)
;> return

;@ def ItemNoEffectOnTarget()
;@ path: battle/item/effects
;@ "Has no effect on X!" ($B8) with the target's name.
ItemNoEffectOnTarget::
;> wBattlerReload = 0xB8
	ld a, $b8
	ld [wBattlerReload], a
;> TargetNameToArg0()
	call TargetNameToArg0
;> ItemShowFailMessage()
	call ItemShowFailMessage
;> return
	ret

;@ def ItemCuredEnemy()
;@ path: battle/item/effects
;@ Curing an enemy with an item adds 100 join points.
ItemCuredEnemy::
;> if wSkillTarget & 4:
;>     AddJoinPoints(100)
	ld a, [wSkillTarget]
	bit 2, a
	jr z, .done

	ld bc, $0064
	call AddJoinPoints
	ret

.done
;> return
	ret

;@ def ItemUseless()
;@ path: battle/item/effects
;@ The item does nothing (ItemNoEffect). It tests whether the target is an enemy, but both
;@ ways lead to the same call.
ItemUseless::
;> ItemNoEffect()
	ld a, [wSkillTarget]
	bit 2, a
	jr z, .same

.same
	call ItemNoEffect
;> return
	ret

;@ def ItemHealSound()
;@ path: battle/item/effects
;@ Sound $70 when an own monster was healed.
ItemHealSound::
;> if wSkillTarget < 4:
;>     QueueSound(0x70)
	ld a, [wSkillTarget]
	cp $04
	jr nc, .done

	ld a, $70
	call QueueSound

.done
;> return
	ret
;@ def AddJoinPoints(points: bc)
;@ path: battle/item/effects
;@ wJoinPoints += points.
AddJoinPoints::
;>@s wJoinPoints = (wJoinPoints + points) & 0xFFFF
	ld a, [wJoinPoints]
	ld l, a
	ld a, [wJoinPoints + 1]
	ld h, a
	add hl, bc
	ld a, l
;=@s
	ld [wJoinPoints], a
	ld a, h
	ld [wJoinPoints + 1], a
;> return
	ret

;@ def SubJoinPoints(points: bc)
;@ path: battle/item/effects
;@ wJoinPoints -= points, not below 0.
SubJoinPoints::
;>@m wJoinPoints = max(wJoinPoints - points, 0)
	ld a, [wJoinPoints]
	ld l, a
	ld a, [wJoinPoints + 1]
	ld h, a
	ld a, l
	sub c
;=@m
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, .store

	ld hl, $0000

.store
;=@m
	ld a, l
	ld [wJoinPoints], a
	ld a, h
	ld [wJoinPoints + 1], a
;> return
	ret

;@ def BlazeDamage()
;@ path: battle/skills/resist
;@ Damage of the Blaze skills: the skill table's amount (CalcSkillAmount) scaled by the
;@ target's resistance 0 (bits 4-5 of resistance byte 0) with ResistDamageA.
BlazeDamage::
;> status = CalcSkillAmount()                       # hl: the target's status byte 3
	call CalcSkillAmount
;> ResistDamageA(status, (GetResistByte0() >> 4) & 3)
	call GetResistByte0
	swap a
	and $03
	call ResistDamageA
;> return
	ret


;@ def FirebalDamage()
;@ path: battle/skills/resist
;@ Damage of the Firebal skills: the skill table's amount scaled by resistance 1 (bits 2-3 of
;@ resistance byte 0).
FirebalDamage::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageA(status, (GetResistByte0() >> 2) & 3)
	call GetResistByte0
	rrca
	rrca
	and $03
	call ResistDamageA
;> return
	ret


;@ def BangDamage()
;@ path: battle/skills/resist
;@ Damage of the Bang skills: the skill table's amount scaled by resistance 2 (bits 0-1 of
;@ resistance byte 0).
BangDamage::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageA(status, GetResistByte0() & 3)
	call GetResistByte0
	and $03
	call ResistDamageA
;> return
	ret


;@ def InfernosDamage()
;@ path: battle/skills/resist
;@ Damage of the Infernos skills: the skill table's amount scaled by resistance 3
;@ (InfernosResistDamage).
InfernosDamage::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> InfernosResistDamage(status)                      # (falls through)
;> return

;@ def InfernosResistDamage(status: hl)
;@ path: battle/skills/resist
;@ Scales wSkillAmount by the target's resistance 3 (bits 6-7 of resistance byte 1); also
;@ used by other damage routines.
InfernosResistDamage::
;> ResistDamageA(status, (GetResistByte1() >> 6) & 3)
	call GetResistByte1
	rlca
	rlca
	and $03
	call ResistDamageA
;> return
	ret


;@ def BoltDamage()
;@ path: battle/skills/resist
;@ Damage of the lightning skills: the skill table's amount scaled by resistance 4 (bits 4-5
;@ of resistance byte 1).
BoltDamage::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageA(status, (GetResistByte1() >> 4) & 3)
	call GetResistByte1
	swap a
	and $03
	call ResistDamageA
;> return
	ret


;@ def IceBoltDamage()
;@ path: battle/skills/resist
;@ Damage of the IceBolt skills: the skill table's amount scaled by resistance 5 (bits 2-3 of
;@ resistance byte 1).
IceBoltDamage::
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> ResistDamageA(status, (GetResistByte1() >> 2) & 3)
	call GetResistByte1
	rrca
	rrca
	and $03
	call ResistDamageA
;> return
	ret


;@ def RollInstantDeath() -> carry
;@ path: battle/skills/resist
;@ Whether an instant-death style skill takes hold (carry): never when CheckSkillAllowed
;@ refuses it; otherwise by the target's resistance 8 (bits 4-5 of resistance byte 2, also in
;@ wBattleArg2): skills below $72 (Beat, Defeat, K.O.Dance) with ResistChanceC, UltraDown
;@ ($82) with ResistChanceB, the others (EerieLite, UltraDown's helpers) with ResistChanceA.
;@ Clears wSkillAmount.
RollInstantDeath::
;> if not CheckSkillAllowed():
;>     return ReturnNoCarry()
	call CheckSkillAllowed
	jp z, ReturnNoCarry

;> wSkillAmount = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> wBattleArg2 = (GetResistByte2() >> 4) & 3
	call GetResistByte2
	swap a
	and $03
	ld [wBattleArg2], a
;>@c if wSkillId < 0x72:
	ld a, [wSkillId]
	cp $72
	jr c, .hardest

;>@c1     return ResistChanceC(status, wBattleArg2)
;>@b if wSkillId == 0x82:
	cp $82
	jr z, .ultraDown

;>@b1     return ResistChanceB(status, wBattleArg2)
;> return ResistChanceA(status, wBattleArg2)
	ld a, [wBattleArg2]
	call ResistChanceA
	ret


.hardest
;=@c1
	ld a, [wBattleArg2]
	call ResistChanceC
	ret


.ultraDown
;=@b1
	ld a, [wBattleArg2]
	call ResistChanceB
	ret


;@ def RollSleep() -> carry
;@ path: battle/skills/resist
;@ Whether a sleep skill takes hold (carry), by the target's resistance 7 (bits 6-7 of
;@ resistance byte 2): always when the user's nudge bit is set (CheckUserNudgeBit2, level not 3), else Sleep ($15) with
;@ ResistChanceA, SleepAll and SleepAir with ResistChanceC. Clears wSkillAmount.
RollSleep::
;> wSkillAmount = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> status = CalcSkillAmount()
	call CalcSkillAmount
;> wBattleArg2 = (GetResistByte2() >> 6) & 3
	call GetResistByte2
	rlca
	rlca
	and $03
	ld [wBattleArg2], a
;>@f if not CheckUserNudgeBit2(wBattleArg2):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> if wSkillId == 0x15:
;>     return ResistChanceA(status, wBattleArg2)
	ld a, [wSkillId]
	cp $15
	ld a, [wBattleArg2]
	jp z, ResistChanceA

;> return ResistChanceC(status, wBattleArg2)
	jp ResistChanceC


;@ def RollStopSpell() -> carry
;@ path: battle/skills/resist
;@ Whether StopSpell takes hold (carry), by the target's resistance 10 (bits 0-1 of resistance
;@ byte 2): always when CheckUserNudgeBit2 allows it, else ResistChanceA. Clears wSkillAmount.
RollStopSpell::
;> wSkillAmount = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> level = GetResistByte2() & 3
	call GetResistByte2
	and $03
;>@f if not CheckUserNudgeBit2(level):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> return ResistChanceA(status, level)
	call ResistChanceA
	ret


;@ def RollSurround() -> carry
;@ path: battle/skills/resist
;@ Whether Surround (and the blinding skills) take hold (carry), by the target's resistance 6
;@ (bits 0-1 of resistance byte 1): always when CheckUserNudgeBit2 allows it, else SandStorm ($72)
;@ with ResistChanceC, the others with ResistChanceA. Clears wSkillAmount.
RollSurround::
;> wSkillAmount = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> level = GetResistByte1() & 3
	call GetResistByte1
	and $03
;>@f if not CheckUserNudgeBit2(level):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> if wSkillId != 0x72:
	ld b, a
	ld a, [wSkillId]
	cp $72
	ld a, b
	jr z, .sandStorm

;>     return ResistChanceA(status, level)
	call ResistChanceA
	ret


.sandStorm
;> return ResistChanceC(status, level)
	call ResistChanceC
	ret


;@ def RollConfusion() -> carry
;@ path: battle/skills/resist
;@ Whether a confusing skill takes hold (carry), by the target's resistance 11 (bits 6-7 of
;@ resistance byte 3): always when CheckUserNudgeBit2 allows it, else ResistChanceC. Clears
;@ wSkillAmount.
RollConfusion::
;> wSkillAmount = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> level = (GetResistByte3() >> 6) & 3
	call GetResistByte3
	rlca
	rlca
	and $03
;>@f if not CheckUserNudgeBit2(level):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> return ResistChanceC(status, level)
	call ResistChanceC
	ret


;@ def RollRobMagic() -> carry
;@ path: battle/skills/resist
;@ Whether RobMagic or OddDance takes hold (carry), by the target's resistance 9 (bits 2-3 of
;@ resistance byte 2): always when CheckUserNudgeBit2 allows it, else ResistChanceA. Clears
;@ wSkillAmount2.
RollRobMagic::
;> wSkillAmount2 = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> wBattleArg2 = (GetResistByte2() >> 2) & 3
	call GetResistByte2
	rrca
	rrca
	and $03
	ld [wBattleArg2], a
;>@f if not CheckUserNudgeBit2(wBattleArg2):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> return ResistChanceA(status, wBattleArg2)
	call ResistChanceA
	ret


;@ def RobMagic()
;@ path: battle/skills/effects/status
;@ RobMagic's transfer: drains MP from the target (DrainTargetMP) and gives them to the user,
;@ whose MP stop at its maximum.
;@ test: wSkillUser = rand(0, 7)
RobMagic::
;> drained = DrainTargetMP()
	call DrainTargetMP
;>@a mem16[wBattlerMP + 2 * wSkillUser] += drained
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@a
	ld l, a
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ld a, c
;=@a
	ld [hli], a
	ld [hl], b
;> if IsMPFull(wSkillUser):                         # over the maximum
	ld a, [wSkillUser]
	call IsMPFull
	jr nc, .done

;>@m     mem16[wBattlerMP + 2 * wSkillUser] = mem16[wBattlerMaxMP + 2 * wSkillUser]
	ld a, [wSkillUser]
	ld bc, wBattlerMaxMP + 1
	add a
	add c
	ld c, a
	ld a, $00
;=@m
	adc b
	ld b, a
	ld a, [bc]
	ld [hld], a
	dec bc
	ld a, [bc]
;=@m
	ld [hl], a

.done
;> return
	ret


;@ def DrainTargetMP() -> bc
;@ path: battle/skills/effects/status
;@ Takes MP from the target: the user's level / 4 + 5, at most what the target has. The amount
;@ goes into wSkillAmount and is returned.
;@ test: wSkillTarget = rand(0, 7)
;@ test: wSkillUser = rand(0, 7)
DrainTargetMP::
;>@m0 mp = mem16[wBattlerMP + 2 * wSkillTarget]
	ld a, [wSkillTarget]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@m0
	ld l, a
;> if mp == 0:
	or h
	jr z, .none

;>@n1     drain = 0
;> else:
;>@lv     drain = min((wBattlerLevel[wSkillUser] >> 2) + 5, mp)
	ld a, [wSkillUser]
	ld de, wBattlerLevel
	add e
	ld e, a
	ld a, $00
	adc d
;=@lv
	ld d, a
	ld a, [de]
	srl a
	srl a
	add $05
	ld c, a
;=@lv
	ld b, $00
	call CompareHLBC
	jr nc, .keep

	ld b, h
	ld c, l

.keep
;=@s
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
;=@s
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	jr .sub

.none
;=@n1
	ld bc, $0000
;=@s
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a

.sub
;>@s wSkillAmount = drain
;> mem16[wBattlerMP + 2 * wSkillTarget] = mp - drain
	pop hl
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
;=@r
	ld [hl], a
;>@r return drain
	ret


;@ def RollDefenseDown() -> carry
;@ path: battle/skills/resist
;@ Whether Sap, Defence or SickLick take hold (carry), by the target's resistance 12 (bits 4-5
;@ of resistance byte 3): always when CheckUserNudgeBit2 allows it, else SickLick ($7A) with
;@ ResistChanceC, the others with ResistChanceA. Clears wSkillAmount2.
RollDefenseDown::
;> wSkillAmount2 = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> wBattleArg2 = (GetResistByte3() >> 4) & 3
	call GetResistByte3
	swap a
	and $03
	ld [wBattleArg2], a
;>@f if not CheckUserNudgeBit2(wBattleArg2):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> if wSkillId != 0x7A:
	ld b, a
	ld a, [wSkillId]
	cp $7a
	ld a, b
	jr z, .sickLick

;>     return ResistChanceA(status, wBattleArg2)
	call ResistChanceA
	ret


.sickLick
;> return ResistChanceC(status, wBattleArg2)
	call ResistChanceC
	ret


;@ def LowerDefense() -> carry
;@ path: battle/skills/effects/status
;@ Lowers the target's defense by half its base defense (GetBaseDefense), not below 0, the
;@ drop into wSkillAmount. No carry (nothing done) when the defense is 1 or less.
LowerDefense::
;> if GetBattlerDefense(wSkillTarget) <= 1:
;>@f     return False
	ld a, [wSkillTarget]
	call GetBattlerDefense
	ld b, h
	ld c, l
	ld hl, $0001
	call CompareHLBC
;=@f
	jr c, .lower

	xor a
	ret


.lower
;> drop = GetBaseDefense(wSkillTarget) >> 1
	ld a, [wSkillTarget]
	call GetBaseDefense
	call ShiftBC1
;> p = wBattlerDefense + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
;> if mem16[p] == 0:
;>@z     return False
	push hl
	ld a, [hli]
	ld h, [hl]
	or h
	pop hl
	jr z, .no

;> wSkillAmount = drop
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
;>@mx mem16[p] = max(mem16[p] - drop, 0)
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
;=@mx
	jr nc, .done

	xor a
	ld [hld], a
	ld [hl], a

.done
;> return True
	scf
	ret


.no
;=@z
	xor a
	ret


;@ def RaiseDefense() -> carry
;@ path: battle/skills/effects/status
;@ Raises the target's defense by half its base defense, the rise into wSkillAmount. The
;@ defense stops at the limit CheckDefenseRaisable gives (the amount shrinks by what is cut
;@ off). No carry when it is at the limit already.
;@ test: skip uses the limit CheckDefenseRaisable leaves in bc
RaiseDefense::
;> if not CheckDefenseRaisable(wSkillTarget):        # carry and not zero: room to rise
;>@f     return False
	ld a, [wSkillTarget]
	call CheckDefenseRaisable
	jr nc, .no

	jr z, .no

;> rise = GetBaseDefense(wSkillTarget) >> 1
	ld a, [wSkillTarget]
	call GetBaseDefense
	call ShiftBC1
;> wSkillAmount = rise
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
;>@add p = wBattlerDefense + 2 * wSkillTarget; mem16[p] += rise
	ld a, [wSkillTarget]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, [hl]
	add c
	ld [hli], a
;=@add
	ld a, [hl]
	adc b
	ld [hl], a
;> if not CheckDefenseRaisable(wSkillTarget):        # above the limit (left in bc as `limit`)
	ld a, [wSkillTarget]
	push hl
	call CheckDefenseRaisable
	pop hl
	jr c, .done

;>@cut1     wSkillAmount -= mem16[p] - limit
;>@cut2     mem16[p] = limit
;=@cut1
	ld a, [hld]
	ld e, [hl]
	ld d, a
;=@cut2
	ld a, c
	ld [hli], a
	ld [hl], b
;=@cut1
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
;=@cut1
	ld a, [wSkillAmount]
	sub e
	ld e, a
	ld a, [wSkillAmount + 1]
	sbc d
	ld d, a
;=@cut1
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a

.done
;> return True
	scf
	ret


.no
;=@f
	xor a
	ret


;@ def RollSlow() -> carry
;@ path: battle/skills/resist
;@ Whether Slow or SlowAll takes hold (carry), by the target's resistance 13 (bits 2-3 of
;@ resistance byte 3): always when CheckUserNudgeBit2 allows it, else ResistChanceA. Clears
;@ wSkillAmount2.
RollSlow::
;> wSkillAmount2 = 0
	ld hl, $0000
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;> status = GetTargetStatus3()
	call GetTargetStatus3
;> level = (GetResistByte3() >> 2) & 3
	call GetResistByte3
	rrca
	rrca
	and $03
;>@f if not CheckUserNudgeBit2(level):
	call CheckUserNudgeBit2
	jr z, .roll

;>     return True
	scf
	ret


.roll
;=@f
;> return ResistChanceA(status, level)
	call ResistChanceA
	ret


;@ def LowerAgility() -> carry
;@ path: battle/skills/effects/status
;@ Lowers the target's agility by half its base agility (one less when that equals the
;@ agility), not below 1; the drop goes into wSkillAmount. No carry when the agility is below 2.
LowerAgility::
;> drop = GetBaseAgility(wSkillTarget) >> 1
	ld a, [wSkillTarget]
	call GetBaseAgility
	call ShiftBC1
;> p = wBattlerAgility + 2 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call IndexWords
;>@e agility = mem16[p]; one = 1 if agility == drop else 0
	push hl
	ld d, $00
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
;=@e
	jr nz, .notEqual

	ld d, $01

.notEqual
;> if agility < 2:
;>@f     return False
	push bc
	ld bc, $0002
	call CompareHLBC
	pop bc
	pop hl
	jr c, .no

;>@d drop -= one
	ld a, c
	sub d
	ld c, a
	ld a, b
	sbc $00
	ld b, a
;> wSkillAmount = drop
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
;>@sb mem16[p] = agility - drop
	ld a, [hl]
	ld e, a
	sub c
	ld [hli], a
	ld a, [hl]
	ld d, a
;=@sb
	sbc b
	ld [hl], a
;>@lw if agility < drop:                           # would go below 0: stop at 1
	jr nc, .done

;>@lw1     mem16[p] = 1
	xor a
	ld [hld], a
	ld [hl], $01
;>     wSkillAmount = agility - 1
	dec de
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a

.done
;> return True
	scf
	ret


.no
;=@f
	xor a
	ret


;@ def RaiseAgility() -> carry
;@ path: battle/skills/effects/status
;@ Raises the target's agility by half its base agility, the rise into wSkillAmount; it stops
;@ at the limit CheckAgilityRaisable gives (the amount shrinks by what is cut off). No carry
;@ when there is no room to rise.
;@ test: skip uses the limit CheckAgilityRaisable leaves in bc
RaiseAgility::
;> if not CheckAgilityRaisable(wSkillTarget):
;>@f     return False
	ld a, [wSkillTarget]
	call CheckAgilityRaisable
	jr nc, .no

;> rise = GetBaseAgility(wSkillTarget) >> 1
	ld a, [wSkillTarget]
	call GetBaseAgility
	call ShiftBC1
;> wSkillAmount = rise
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
;>@add p = wBattlerAgility + 2 * wSkillTarget; mem16[p] += rise
	ld a, [wSkillTarget]
	ld hl, wBattlerAgility
	call IndexWords
	ld a, [hl]
	add c
	ld [hli], a
;=@add
	ld a, [hl]
	adc b
	ld [hl], a
;> if not CheckAgilityRaisable(wSkillTarget):        # above the limit (left in bc as `limit`)
	ld a, [wSkillTarget]
	push hl
	call CheckAgilityRaisable
	pop hl
	jr c, .done

;>@cut1     wSkillAmount -= mem16[p] - limit
;>@cut2     mem16[p] = limit
;=@cut1
	dec hl
	ld a, [hli]
	sub c
	ld e, a
	ld a, [hl]
	sbc b
;=@cut1
	ld d, a
;=@cut2
	ld a, b
	ld [hld], a
	ld [hl], c
;=@cut1
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, c
	sub e
;=@cut1
	ld e, a
	ld a, b
	sbc d
	ld d, a
	ld a, e
	ld [wSkillAmount], a
;=@cut1
	ld a, d
	ld [wSkillAmount + 1], a

.done
;> return True
	scf
	ret


.no
;=@f
	xor a
	ret


;@ def TransformIntoTarget()
;@ path: battle/skills/effects/special
;@ Transform's change: the user takes over the target's base maximum HP and MP (its current
;@ HP and MP cut down to them), attack, defense, agility, resistances (packed into its
;@ wBattlerResist entry by PackResistancesVia) and skills: up to 8 entries of (skill kind
;@ from the skill table's word, skill number) in wBattlerSkills; skill $DB is dropped and the
;@ rest of the list is filled with (0, $FF). Its picture becomes the target's (LoadBattlerPic).
;@ Only bit 7 of its wBattlerMenuMemory entry is kept.
;@ test: skip loads monster templates and graphics from other banks
TransformIntoTarget::
;>@mm wBattlerMenuMemory[wSkillUser] &= 0x80
	ld a, [wSkillUser]
	ld hl, wBattlerMenuMemory
	add l
	ld l, a
	ld a, $00
	adc h
;=@mm
	ld h, a
	ld a, [hl]
	and $80
	ld [hl], a
;> maxhp = GetBaseMaxHP(wSkillTarget)
	ld a, [wSkillTarget]
	call GetBaseMaxHP
;>@hp if mem16[wBattlerHP + 2 * wSkillUser] >= maxhp:
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@hp
	ld l, a
	call CompareHLBC
	pop hl
	jr c, .hpOk

;>     mem16[wBattlerHP + 2 * wSkillUser] = maxhp
	ld a, c
	ld [hli], a
	ld [hl], b

.hpOk
;> mem16[wBattlerMaxHP + 2 * wSkillUser] = maxhp
	ld a, [wSkillUser]
	ld hl, wBattlerMaxHP
	call IndexWords
	ld a, c
	ld [hli], a
	ld [hl], b
;> maxmp = GetBaseMaxMP(wSkillTarget)
	ld a, [wSkillTarget]
	call GetBaseMaxMP
;>@mp if mem16[wBattlerMP + 2 * wSkillUser] >= maxmp:
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;=@mp
	ld l, a
	call CompareHLBC
	pop hl
	jr c, .mpOk

;>     mem16[wBattlerMP + 2 * wSkillUser] = maxmp
	ld a, c
	ld [hli], a
	ld [hl], b

.mpOk
;> mem16[wBattlerMaxMP + 2 * wSkillUser] = maxmp
	ld a, [wSkillUser]
	ld hl, wBattlerMaxMP
	call IndexWords
	ld a, c
	ld [hli], a
	ld [hl], b
;>@at mem16[wBattlerAttack + 2 * wSkillUser] = GetBaseAttack(wSkillTarget)
	ld a, [wSkillUser]
	ld hl, wBattlerAttack
	call IndexWords
	ld a, [wSkillTarget]
	call GetBaseAttack
	ld a, c
;=@at
	ld [hli], a
	ld [hl], b
;>@df mem16[wBattlerDefense + 2 * wSkillUser] = GetBaseDefense(wSkillTarget)
	ld a, [wSkillUser]
	ld hl, wBattlerDefense
	call IndexWords
	ld a, [wSkillTarget]
	call GetBaseDefense
	ld a, c
;=@df
	ld [hli], a
	ld [hl], b
;>@ag mem16[wBattlerAgility + 2 * wSkillUser] = GetBaseAgility(wSkillTarget)
	ld a, [wSkillUser]
	ld hl, wBattlerAgility
	call IndexWords
	ld a, [wSkillTarget]
	call GetBaseAgility
	ld a, c
;=@ag
	ld [hli], a
	ld [hl], b
;> res = LoadBattlerResistances(wSkillTarget)
	ld a, [wSkillTarget]
	call LoadBattlerResistances
;>@rs PackResistancesVia(res, wBattlerResist + 7 * wSkillUser)
	ld a, [wSkillUser]
	ld de, wBattlerResist
	ld b, a
	add a
	add b
	add a
;=@rs
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;=@rs
	call PackResistancesVia
;> skills, count = FindBattlerSkills(wSkillTarget)
	ld a, [wSkillTarget]
	call FindBattlerSkills
;>@de dest = wBattlerSkills + 16 * wSkillUser
	ld a, [wSkillUser]
	ld de, wBattlerSkills
	swap a
	add e
	ld e, a
	ld a, $00
;=@de
	adc d
	ld d, a
;> n = 0
	ld c, $00

;>@loop for skill in skills[:count]:
.copy
;>     wBattleArg0 = skill
	ld a, [hl]
	ld [wBattleArg0], a
;>     if skill == 0xDB:
;>         skill = DropSkillDB()                     # $FF: the list ends
	cp $db
	call z, DropSkillDB
;>     if skill == 0xFF:
;>@br         break
	cp $ff
	jr z, .fill

;>     wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;>     wBattleArg2 = 1
	ld a, $01
	ld [wBattleArg2], a
;>@gw     GetSkillWord()                            # word 1 of the skill's record
	push af
	push bc
	push de
	push hl
	ld hl, far_GetSkillWord
	rst $10
;=@gw
	pop hl
	pop de
	pop bc
	pop af
;>@k     mem[dest + 2 * n] = (wBattleArg0 >> 4) & 0x0F  # the skill's kind
	ld a, [wBattleArg0]
	swap a
	and $0f
	ld a, a
	ld [de], a
	inc de
;>     mem[dest + 2 * n + 1] = skill
	ld a, [hli]
	ld [de], a
	inc de
;>     n += 1
	inc c
;=@loop
	dec b
	jr nz, .copy

;> if n != 8:
	ld a, c
	cp $08
	jr z, .pic

;>@f     while n != 8:                              # fill with (0, $FF)
.fill
;>         mem[dest + 2 * n] = 0
	ld a, $00
	ld [de], a
	inc de
;>         mem[dest + 2 * n + 1] = 0xFF
	ld a, $ff
	ld [de], a
	inc de
;>         n += 1
	inc c
;=@f
	ld a, c
	cp $08
	jr nz, .fill

.pic
;> LoadBattlerPic(wSkillUser, mem[GetTargetSpeciesPtr()])
	call GetTargetSpeciesPtr
	ld c, [hl]
	ld a, [wSkillUser]
	ld b, a
	call LoadBattlerPic
;> return
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
;> if (wSkillTarget & 3) in (0, 3):
;>     return
	ld a, [wSkillTarget]
	and $03
	cp $03
	ret z

	or a
	ret z

;> if (wSkillTarget & 3) == 2:                # the rest is ApplyPositionDamageCut's
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

;>@s return not (wBattlerStatus[8 * wSkillTarget + 1] & 0x02)
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
;>@f fill(status, 0, 8)
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
;> return u16(wBattlerStatus + 3 + (8 * wSkillTarget & 0xFF))
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
;> return wBattlerResist[(7 * wSkillTarget & 0xFF)]
	ld de, wBattlerResist
	jr jr_052_67dc

;@ def GetResistByte1() -> a
;@ path: battle/skills/resist
;@ Byte 1 of the target's packed resistances: 3 (Infernos) in bits 6-7, 4 (Bolt)
;@ in 4-5, 5 (IceBolt) in 2-3, 6 in 0-1.
GetResistByte1::
;> return wBattlerResist[(7 * wSkillTarget & 0xFF) + 1]
	ld de, wBattlerResist + 1
	jr jr_052_67dc

;@ def GetResistByte2() -> a
;@ path: battle/skills/resist
;@ Byte 2 of the target's packed resistances: 7, 8, 9 and 10 from bits 6-7 down.
GetResistByte2::
;> return wBattlerResist[(7 * wSkillTarget & 0xFF) + 2]
	ld de, wBattlerResist + 2
	jr jr_052_67dc

;@ def GetResistByte3() -> a
;@ path: battle/skills/resist
;@ Byte 3 of the target's packed resistances: 11, 12, 13 and 14 from bits 6-7
;@ down.
GetResistByte3::
;> return wBattlerResist[(7 * wSkillTarget & 0xFF) + 3]
	ld de, wBattlerResist + 3
	jr jr_052_67dc

;@ def GetResistByte4() -> a
;@ path: battle/skills/resist
;@ Byte 4 of the target's packed resistances: 15, 16, 17 and 18 from bits 6-7
;@ down.
GetResistByte4::
;> return wBattlerResist[(7 * wSkillTarget & 0xFF) + 4]
	ld de, wBattlerResist + 4
	jr jr_052_67dc

;@ def GetResistByte5() -> a
;@ path: battle/skills/resist
;@ Byte 5 of the target's packed resistances: 19, 20, 21 and 22 from bits 6-7
;@ down.
GetResistByte5::
;> return wBattlerResist[(7 * wSkillTarget & 0xFF) + 5]
	ld de, wBattlerResist + 5
	jr jr_052_67dc

;@ def GetResistByte6() -> a
;@ path: battle/skills/resist
;@ Byte 6 of the target's packed resistances: 23, 24 and 25 from bits 6-7 down
;@ (bits 0-1 unused). The other GetResistByte routines end here too.
GetResistByte6::
;>@x return wBattlerResist[(7 * wSkillTarget & 0xFF) + 6]
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
;@ def IsHPFull(pos: a) -> zero
;@ path: battle/state
;@ Zero flag when the monster at battle position `pos` has all its HP (the
;@ battle items check it). Keeps the other registers.
IsHPFull::
;> hp = GetBattlerHP(pos)
	push hl
	push bc
	ld b, a
	call GetBattlerHP
	push hl
;>@r return GetBattlerMaxHP(pos) == hp
	ld a, b
	call GetBattlerMaxHP
	pop bc
	call CompareHLBC
	pop bc
	pop hl
;=@r
	ret

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
;@ test: pos = rand(0, 7)
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
;> return defense <= (limit & 0xFFFF)
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
;@ def TargetLosesTurn()
;@ path: battle/state
;@ The skill target loses its turn this round: wBattlerOrder[wSkillTarget] = 3.
;@ Keeps af and hl.
TargetLosesTurn::
;>@o wBattlerOrder[wSkillTarget] = 3
	push hl
	push af
	ld a, [wSkillTarget]
	ld hl, wBattlerOrder
	add l
	ld l, a
;=@o
	ld a, $00
	adc h
	ld h, a
	ld [hl], $03
	pop af
	pop hl
;=@o
	ret

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
;@ test: skip follows name and record pointers that random states leave invalid
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

;@ def CopyLinkPartnerName(pos: b, dest: hl) -> hl
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
;>@l2         return CopyLinkPartnerName(pos, dest)
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
;@ test: pos = rand(0, 7)
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
;@ test: skip follows name and record pointers that random states leave invalid
CopyMorphedEnemyName::
;> end = CopyPartyMonName(party_pos, dest)
	call CopyPartyMonName
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
;>@e JumpToPointer(FarTable_52 + 0x10 + 2 * wSkillId)   # the skill's effect routine
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
;>@t4     wBattlerStatus[8 * wSkillUser + 1] |= 0x20
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
;>@p     wBattlerStatus[8 * wSkillUser + 1] |= 0x10
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
;> if (wSoundChannels[0] & wSoundChannels[26]) != 0xFF:   # wait for two free sound channels
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
;>@h handler = {0x14: RunDeathStages_53, 0x80: RunDispelStages_53, 0x82: RunWeakenStages_53, 0x83: RunDispelStages_53, 0xA5: RunDispelStages_53, 0x88: RunCoverStages_53, 0x89: RunCoverStages_53, 0xA2: RunCallHorrorStep, 0xA4: RunCallHorrorStep}.get(wSkillId)
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
	ld hl, far_RunDispelStages_53
	rst $10
	ret


.sacrifice
;=@r
	ld hl, far_RunDeathStages_53
	rst $10
	ret


.ultraDown
;=@r
	ld hl, far_RunWeakenStages_53
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
;> ShowShockedNext_53()
	ld hl, far_ShowShockedNext_53
	rst $10
	ret


;@ def ActionStepFollowUp()
;@ path: battle/actions
;@ Action step 4: waits for the text and the animation, then a short delay
;@ (counted down in wMonStats[0]), then the skill's follow-up (SkillFollowUp).
ActionStepFollowUp::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if not wBattleAnimDone:
;>     return
	ld a, [wBattleAnimDone]
	or a
	ret z

;> if not wMonStats[0]:
;>     return SkillFollowUp()
	ld a, [wMonStats]
	or a
	jr z, SkillFollowUp

;> wMonStats[0] -= 1
	dec a
	ld [wMonStats], a
	ret


;@ def SkillFollowUp()
;@ path: battle/actions
;@ What comes after a skill's effect: Farewell and LifeDance, the recoil skills
;@ ($3B, Kamikaze, Ramming), the hits that also poison, put to sleep or
;@ paralyse, DeMagic, LifeSong and CHGDRAGON have stages of their own (by
;@ wBattleSubStep2). A target in the BladeD stance hit by a physical skill
;@ strikes back (StartBladeCounter). Everything else goes on to step 5.
SkillFollowUp::
;>@f handler = {0x32: FarewellFollowUp, 0x96: FarewellFollowUp, 0x3B: Skill3BStages, 0x3E: KamikazeStages, 0x3C: RammingStages, 0x67: PoisonHitStages, 0x68: NapAttackStages, 0x69: ParalyzeStages, 0x80: DeMagicStages, 0x95: LifeSongStages, 0xAA: ChgDragonFollowUp, 0xD5: ChgDragonFollowUp}.get(wSkillId)
;>@g if handler:
;>@g     return handler()
	ld a, [wSkillId]
	cp $32
	jr z, FarewellFollowUp

	cp $96
	jr z, FarewellFollowUp

;=@g
	cp $3b
	jr z, Skill3BStages

	cp $3e
	jr z, KamikazeStages

	cp $3c
	jr z, RammingStages

;=@g
	cp $67
	jr z, PoisonHitStages

	cp $68
	jr z, NapAttackStages

	cp $69
	jp z, ParalyzeStages

;=@g
	cp $80
	jp z, DeMagicStages

	cp $95
	jp z, LifeSongStages

	cp $aa
	jp z, ChgDragonFollowUp

;=@g
	cp $d5
	jp z, ChgDragonFollowUp

;> if CheckBladeCounter():
;>     return BladeCounterFollowUp()
	call CheckBladeCounter
	jp nz, BladeCounterFollowUp

;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> return ActionStepNext()
	jp ActionStepNext


	db $c9                                  ; unused

;@ def CheckBladeCounter() -> a
;@ path: battle/actions
;@ Nonzero (and the zero flag clear) when the target strikes back: it stands in
;@ the BladeD stance (bit 2 of wBattlerStatus7), the skill is a physical one
;@ (bit 7 of wSkillFlags1), and the hit was neither intercepted nor itself a
;@ counter (wReactionKind bit 3).
;@ test: skip result only in the flags
CheckBladeCounter::
;> if wInterceptState:
;>     return 0
	ld a, [wInterceptState]
	or a
	jr z, .notIntercepted

	xor a
	ret


.notIntercepted
;> if wReactionKind & 0x08:
;>     return 0
	ld a, [wReactionKind]
	and $08
	cp $08
	ret z

;> if not wBattlerStatus[8 * wSkillTarget + 7] & 0x04:
;>     return 0
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus7
	call AddEightTimes
	bit 2, [hl]
	ret z

;> return wSkillFlags1 & 0x80
	ld a, [wSkillFlags1]
	bit 7, a
	ret


;@ def FarewellFollowUp()
;@ path: battle/actions
;@ Follow-up of Farewell and LifeDance, in bank $53.
FarewellFollowUp::
;> RunReviveAllStages_53()
	ld hl, far_RunReviveAllStages_53
	rst $10
	ret


;@ def Skill3BStages()
;@ path: battle/actions
;@ Follow-up stages of skill $3B, by wBattleSubStep2 (Skill3BStageTable).
Skill3BStages::
;> return Skill3BStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after skill $3B: the user takes a quarter of the damage back, may go
;@ down, then the action goes on.
Skill3BStageTable::
	dw Skill3BStage0
	dw Skill3BStage1
	dw RecoilStageUserDown
	dw StagesEnd

;@ def KamikazeStages()
;@ path: battle/actions
;@ Follow-up stages of Kamikaze, by wBattleSubStep2.
KamikazeStages::
;> return KamikazeStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after Kamikaze: the user drops to 1 HP (or falls when it had only 1).
KamikazeStageTable::
	dw KamikazeStage0
	dw KamikazeStage1
	dw RecoilStageUserDown
	dw StagesEnd

;@ def RammingStages()
;@ path: battle/actions
;@ Follow-up stages of Ramming, by wBattleSubStep2.
RammingStages::
;> return RammingStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after Ramming: the user loses 80% of its HP plus one.
RammingStageTable::
	dw RammingStage0
	dw RammingStage1
	dw RecoilStageUserDown
	dw StagesEnd

;@ def PoisonHitStages()
;@ path: battle/actions
;@ Follow-up stages of PoisonHit, by wBattleSubStep2.
PoisonHitStages::
;> return PoisonHitStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after PoisonHit: the target may be poisoned, the message, the end.
PoisonHitStageTable::
	dw PoisonHitStage0
	dw StageShowText
	dw StagesEnd

;@ def NapAttackStages()
;@ path: battle/actions
;@ Follow-up stages of NapAttack, by wBattleSubStep2.
NapAttackStages::
;> return NapAttackStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after NapAttack: the target may fall asleep, the message, the end.
NapAttackStageTable::
	dw NapAttackStage0
	dw StageShowText
	dw StagesEnd

;@ def ParalyzeStages()
;@ path: battle/actions
;@ Follow-up stages of the Paralyze hit, by wBattleSubStep2.
ParalyzeStages::
;> return ParalyzeStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after the Paralyze hit: the target may be paralysed, the message,
;@ the end.
ParalyzeStageTable::
	dw ParalyzeStage0
	dw StageShowText
	dw StagesEnd

;@ def DeMagicStages()
;@ path: battle/actions
;@ Follow-up stages of DeMagic, by wBattleSubStep2.
DeMagicStages::
;> return DeMagicStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after DeMagic.
DeMagicStageTable::
	dw DeMagicStage0
	dw DeMagicStage1
	dw StagesEnd

;@ def LifeSongStages()
;@ path: battle/actions
;@ Follow-up stages of LifeSong, by wBattleSubStep2.
LifeSongStages::
;> return LifeSongStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages after LifeSong: one fallen monster after the other of the side is
;@ looked at (LifeSongStage0-2).
LifeSongStageTable::
	dw LifeSongStage0
	dw LifeSongStage1
	dw LifeSongStage2
	dw StagesEnd

;@ def ChgDragonFollowUp()
;@ path: battle/actions
;@ After CHGDRAGON: the changed monster picks its next action
;@ (ChgDragonPickAction).
;@ test: skip needs valid battle or party records; random states send the original code astray
ChgDragonFollowUp::
;> ChgDragonPickAction()
	call ChgDragonPickAction
	ret


;@ def BladeCounterFollowUp()
;@ path: battle/actions
;@ The target strikes back from its BladeD stance (StartBladeCounter).
BladeCounterFollowUp::
;> StartBladeCounter()
	call StartBladeCounter
	ret


;@ def ActionStepNext()
;@ path: battle/actions
;@ Action step 5, in bank $53 (the next hit or target of the action).
ActionStepNext::
;> RunHitWakeStages_53()
	ld hl, far_RunHitWakeStages_53
	rst $10
	ret


;@ def ActionRepeatCheck(status: hl)
;@ path: battle/actions
;@ Clears bit 6 of the user's status byte 4 (`status`); a skill with bit 4 of
;@ wSkillFlags3 then goes again (step $12) while the far side still has
;@ monsters, else the action ends.
ActionRepeatCheck::
;> mem[status] &= ~0x40
	res 6, [hl]
;> if not wSkillFlags3 & 0x10 or CheckFarSideEmpty():
;>     return EndBattlerAction()
	ld a, [wSkillFlags3]
	bit 4, a
	jp z, EndBattlerAction

	call CheckFarSideEmpty
	jp c, EndBattlerAction

;> wBattleSubStep = 0x12
	ld a, $12
	ld [wBattleSubStep], a
	ret


;@ def QuadHitsNext()
;@ path: battle/actions
;@ QuadHits strikes four times, each time at a random enemy.
QuadHitsNext::
;> if wHitCount == 4:
;>     return EndBattlerAction()
	ld a, [wHitCount]
	cp $04
	jp z, EndBattlerAction

;> AITargetRandomEnemy()
	ld hl, far_AITargetRandomEnemy
	rst $10
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
	ret


;@ def BiAttackNext()
;@ path: battle/actions
;@ BiAttack strikes twice; when the first target is gone, a random enemy.
BiAttackNext::
;> if wHitCount == 2:
;>     return EndBattlerAction()
	ld a, [wHitCount]
	cp $02
	jp z, EndBattlerAction

;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
;> if CheckBattlerPresent(wSkillTarget):
;>     AITargetRandomEnemy()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret nc

	ld hl, far_AITargetRandomEnemy
	rst $10
	ret


;@ def CallHelpNext()
;@ path: battle/actions
;@ The helpers CallHelp brought attack once more each, until a random number
;@ matches the count (low 2 bits) or the count reaches $13.
CallHelpNext::
;> if wHitCount == 0x13:
;>     return EndBattlerAction()
	ld a, [wHitCount]
	cp $13
	jp z, EndBattlerAction

;> mask = 3
	ld b, $03
	jr jr_052_6fb2

;@ def YellHelpNext()
;@ path: battle/actions
;@ Like CallHelpNext for YellHelp (low 3 bits, up to $17); the attacks go on
;@ only while the user has called for help (bit 0 of wBattlerStatus6).
;@ test: skip shares its end with CallHelpNext
YellHelpNext::
;> if wHitCount == 0x17:
;>     return EndBattlerAction()
	ld a, [wHitCount]
	cp $17
	jp z, EndBattlerAction

;> mask = 7
	ld b, $07

jr_052_6fb2:
;> if (wHitCount & mask) == (wRandomLow & mask):
;>     return EndBattlerAction()
	and b
	ld c, a
	ld a, [wRandomLow]
	and b
	cp c
	jp z, EndBattlerAction

;> if not wBattlerStatus[8 * wSkillUser + 6] & 0x01:
;>     return EndBattlerAction()
	ld a, [wSkillUser]
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 0, [hl]
	jp z, EndBattlerAction

;> AITargetRandomEnemy()
	ld hl, far_AITargetRandomEnemy
	rst $10
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
	ret


;@ def RainSlashNext()
;@ path: battle/actions
;@ RainSlash hits up to four times, going through the far side's monsters in
;@ turn (skipping empty places) until it runs past the last.
RainSlashNext::
.loop
;> while True:
	ld a, [wHitCount]
;>     if wHitCount >= 4:
;>         return EndBattlerAction()
	cp $04
	jp nc, EndBattlerAction

;>     wBattlerAction[2 * wSkillUser + 1] += 1          # the next target
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [hl]
	inc a
	ld [hl], a
;>     if (wBattlerAction[2 * wSkillUser + 1] & 3) == 3:
;>         return EndBattlerAction()
	and $03
	cp $03
	jr z, EndBattlerAction

;>     if not CheckBattlerPresent(wBattlerAction[2 * wSkillUser + 1]):
;>@b         break
	ld a, [hl]
	call CheckBattlerPresent
	jr c, .loop

;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
	ret


;@ def ActionStepEnd()
;@ path: battle/actions
;@ Action step 6, after a short delay (wMonStats[0]): puts the target back when
;@ another monster took the hit in its place (wShieldTarget), redraws the status
;@ icons, and ends the action when a side is beaten. A reaction of the target
;@ (CheckTargetReacts) comes first; skills that strike again (BiAttack,
;@ QuadHits, CallHelp, YellHelp, RainSlash, BIGSLEEP, MP0, METEOR) pick their
;@ next target; otherwise the user's action is over (EndBattlerAction).
ActionStepEnd::
;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .go

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret


.go
;> if wShieldTarget != 0xFF:
	ld a, [wShieldTarget]
	cp $ff
	jr z, .icons

;>     UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;>     wSkillTarget = wShieldTarget
	ld a, [wShieldTarget]
	ld [wSkillTarget], a
;>@a     wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@a
	adc h
	ld h, a
	ld a, [wSkillTarget]
	ld [hl], a
;>     wShieldTarget = 0xFF
	ld a, $ff
	ld [wShieldTarget], a

.icons
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> PrepareRedirect()
	call PrepareRedirect
;> if CheckSideDefeated():
;>     return FinishActionOrHelp()
	call CheckSideDefeated
	jp c, FinishActionOrHelp

;> if CheckTargetReacts():
;>     return
	call CheckTargetReacts
	ret c

;> wSkillMsgMode = 0
	xor a
	ld [wSkillMsgMode], a
;>@h handler = {0x50: BiAttackNext, 0x51: QuadHitsNext, 0x52: CallHelpNext, 0x53: YellHelpNext, 0x57: RainSlashNext, 0xA7: AllPositionsNextTarget, 0xA8: AllPositionsNextTarget, 0xAF: AllPositionsNextTarget}.get(wSkillId)
	ld a, [wSkillId]
	cp $50
	jp z, BiAttackNext

	cp $51
	jp z, QuadHitsNext

;=@h
	cp $52
	jp z, CallHelpNext

	cp $53
	jp z, YellHelpNext

	cp $57
	jp z, RainSlashNext

;=@h
	cp $a7
	jp z, AllPositionsNextTarget

	cp $a8
	jp z, AllPositionsNextTarget

;> if handler:                               # else it runs on into EndBattlerAction
;>     return handler()
	cp $af
	jp z, AllPositionsNextTarget

;@ def EndBattlerAction()
;@ path: battle/actions
;@ The user is done for this turn (wBattlerOrder 3). A skill for a whole group
;@ goes on to its next target (NextTargetOfGroup), else FinishAction.
EndBattlerAction::
;>@o wBattlerOrder[wSkillUser] = 3
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld a, $03
	ld [hl], a
;> if (wSkillTargeting & 3) != 1:               # not a single target
;>     return NextTargetOfGroup()           # else it runs on into FinishAction
	ld a, [wSkillTargeting]
	and $03
	cp $01
	jp nz, NextTargetOfGroup

;@ def FinishAction()
;@ path: battle/actions
;@ After an action: redraws, shows a reflected skill's message, empties the MP
;@ of Farewell and MegaMagic users, updates an own user's icon and panel. A user
;@ with bit 6 of status byte 4 may go again (ActionRepeatCheck); an interrupted
;@ action is taken up again (RestoreInterruptedAction). Otherwise the next
;@ monster in wTurnOrder that is still in the fight gets its turn; past the end
;@ of the order the turn is over (NextBattlerTurn).
FinishAction::
;> BattleRedraw57()
	call BattleRedraw57
;> if wReflectAnim:
;>     PrintActionMessage()
	ld a, [wReflectAnim]
	or a
	call nz, PrintActionMessage
;> ClearMPAfterSkill()
	call ClearMPAfterSkill
;> wSkillTarget = wSkillUser
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> if wSkillUser < 4:
	cp $04
	jr nc, .repeat

;>     UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;>     PrintPanelHPMP()
	ld hl, far_PrintPanelHPMP
	rst $10

.repeat
;> status = GetUserStatus4()
	call GetUserStatus4
;> if mem[status] & 0x40:
;>     return ActionRepeatCheck(status)
	bit 6, [hl]
	jp nz, ActionRepeatCheck

;> if not RestoreInterruptedAction():
;>     return EndBattlerAction()
	call RestoreInterruptedAction
	jp nc, EndBattlerAction

.next
;> while True:
;>@p     wTurnOrderPos += 1
	ld a, [wTurnOrderPos]
	inc a
	ld [wTurnOrderPos], a
;>     if wTurnOrderPos >= 9:
;>@n         return NextBattlerTurn()
	cp $09
	jr nc, NextBattlerTurn

;>     if CheckSideDefeated():
;>@q         return FinishActionOrHelp()
	call CheckSideDefeated
	jr c, FinishActionOrHelp

;>@r     pos = wTurnOrder[wTurnOrderPos]
	ld a, [wTurnOrderPos]
	ld hl, wTurnOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@r
	ld h, a
	ld a, [hl]
;>     if pos == 0xFF:
;>@s         return NextBattlerTurn()
	cp $ff
	jr z, NextBattlerTurn

;>     if pos == 0x10 or not CheckBattlerPresent(pos):   # Terry's item, or a monster in the fight
;>@t         break
	cp $10
	jr z, .found

	call CheckBattlerPresent
	jr c, .next

.found
;> wBattleStep -= 1                          # the turn step runs once more
;>@u return FinishActionOrHelp()              # runs on into it
	ld hl, wBattleStep
	dec [hl]

;@ def FinishActionOrHelp()
;@ path: battle/actions
;@ Closes the action (CloseAction). After CallHelp or YellHelp whose helpers
;@ came, bank $56 sets them up and message $DA follows (step $1B, battle step
;@ 7); when none came, the action closes without the check for the battle's
;@ end.
FinishActionOrHelp::
;> if wSkillId not in (0x52, 0x53):
;>     return CloseAction()
	ld a, [wSkillId]
	cp $52
	jr c, CloseAction

	cp $54
	jr nc, CloseAction

;> if not wHitShown:
;>     return CloseActionNoCheck()             # CloseAction without CheckBattleOver
	ld a, [wHitShown]
	or a
	jr z, CloseActionNoCheck

;> ClearTextBoxTiles()
	ld hl, far_ClearTextBoxTiles
	rst $10
;> wTextIndex = 0xDA
;> wTextGroup = 0
	ld a, $da
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep = 0x1B
	ld a, $1b
	ld [wBattleSubStep], a
;> wBattleStep = 7
	ld a, $07
	ld [wBattleStep], a
	ret


;@ def CloseAction()
;@ path: battle/actions
;@ Checks whether the battle is over, empties the MP of Farewell and MegaMagic
;@ users and clears the action's step variables (wBattleSubStep up to
;@ wAbsorbMP). FinishActionOrHelp enters at CloseActionNoCheck, after the check.
CloseAction::
;> CheckBattleOver()
;> return CloseActionNoCheck()                # runs on into it
	call CheckBattleOver

;@ def CloseActionNoCheck()
;@ path: battle/actions
;@ The second half of CloseAction, without the check for the battle's end:
;@ empties the MP of Farewell and MegaMagic users and clears the 7 step
;@ variables from wBattleSubStep on.
CloseActionNoCheck::
;> ClearMPAfterSkill()
	call ClearMPAfterSkill
;>@f fill(addr(wBattleSubStep), 0, 7)
	xor a
	ld hl, wBattleSubStep
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
;=@f
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret


;@ def NextBattlerTurn()
;@ path: battle/actions
;@ The turn order is used up: on to the next battle step, and the bits $50 of
;@ both sides' flags (wSideFlags) end with the turn (ClearSideBits50).
NextBattlerTurn::
;> wTurnOrderPos = 0
	xor a
	ld [wTurnOrderPos], a
;> wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
;> if mem[wSideFlags] & 0x50:
;>     ClearSideBits50(wSideFlags)
	ld hl, wSideFlags
	ld a, [hl]
	and $50
	call nz, ClearSideBits50
;> if mem[wSideFlags + 1] & 0x50:
;>     ClearSideBits50(wSideFlags + 1)
	inc hl
	ld a, [hl]
	and $50
	call nz, ClearSideBits50
	ret


;@ def ClearSideBits50(flags: hl)
;@ path: battle/actions
;@ Clears bits 4 and 6 of a side's flags and all but the low two bits of the
;@ side's byte $4A further on.
ClearSideBits50::
;> mem[flags] &= 0xAF
	push hl
	ld a, [hl]
	and $af
	ld [hl], a
;>@b mem[flags + 0x4A] &= 0x03
	ld a, $4a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@b
	ld a, [hl]
	and $03
	ld [hl], a
	pop hl
	ret


;@ def AllPositionsNextTarget()
;@ path: battle/actions
;@ BIGSLEEP, MP0 and METEOR go through every battle position: the user's target
;@ (wBattlerAction) steps on, after the fourth hit over to the other side,
;@ skipping empty places, up to eight.
AllPositionsNextTarget::
.loop
;> while True:
;>     ptr = IndexWords(wSkillUser, wBattlerAction + 1)
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
;>     if wHitCount >= 8:
;>@e         return EndBattlerAction()
	ld a, [wHitCount]
	cp $08
	jp nc, EndBattlerAction

;>     if wHitCount == 4:
	cp $04
	jr nz, .step

;>@w         mem[ptr] = mem[ptr] & 4 ^ 4         # first place of the other side
	ld a, [hl]
	and $04
	xor $04
	ld [hl], a
;>@x         break
	jr .found

.step
;>     mem[ptr] += 1
	inc [hl]
;>     if not CheckBattlerPresent(mem[ptr]):
;>@y         break
	ld a, [hl]
	call CheckBattlerPresent
	jr nc, .found

;>     wHitCount += 1
	ld hl, wHitCount
	inc [hl]
	jr .loop

.found
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
;> wBattleStepArg0 = 0
	xor a
	ld [wBattleStepArg0], a
	ret


;@ def NextTargetOfGroup()
;@ path: battle/actions
;@ A skill aimed at a whole side goes on to the next position of that side
;@ (LifeSong, LifeDance and ALLREVIVE also to empty places); after the last one
;@ the action is finished. A reaction instead goes back to what it interrupted.
NextTargetOfGroup::
.loop
;> while True:
	ld a, [wReactionKind]
;>     if wReactionKind == 2:
;>         return InterruptUseSkill()
	cp $02
	jp z, InterruptUseSkill

;>     if wReactionKind in (4, 1):
;>@r         return RestoreInterruptedAction()
	cp $10
	jr z, .next

	cp $04
	jr z, .restore

	cp $01
	jr nz, .next

.restore
;=@r
	call RestoreInterruptedAction
	ret


.next
;>@l     last = 7 if wSkillTarget & 4 else 3
	ld a, [wSkillTarget]
	bit 2, a
	push af
	jr z, .own

	ld a, $07
	jr .compare

.own
;=@l
	ld a, $03

.compare
;>     if wSkillTarget == last:
;>@f         return FinishAction()
	ld c, a
	pop af
	cp c
	jp z, FinishAction

;>     wSkillTarget += 1
;>@a     wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	inc a
	push af
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	pop af
;=@a
	ld [hl], a
	ld [wSkillTarget], a
;>     if wSkillId in (0x95, 0x96, 0xAD) or not CheckBattlerPresent(wSkillTarget):
;>@b         break
	ld a, [wSkillId]
	cp $95
	jr z, .found

	cp $96
	jr z, .found

;=@b
	cp $ad
	jr z, .found

	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .loop

.found
;>@o wBattlerOrder[wSkillUser] = 2
	ld hl, wBattlerOrder
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
;=@o
	ld h, a
	ld [hl], $02
;> wBattleSubStep = 1
	ld a, $01
	ld [wBattleSubStep], a
;> wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [wSkillTarget]
	ld [hl], a
	ret


;@ def InterruptUseSkill()
;@ path: battle/actions
;@ A reaction of kind 2: the target answers with the same skill (message $D7
;@ with its name and the skill's name), set up in bank $53 with argument $40;
;@ when it cannot act, the action is just finished.
InterruptUseSkill::
;> if CheckBattlerCanAct(wSkillTarget):        # carry: cannot act
;>     return FinishAction()
	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jp c, FinishAction

;> TargetNameToArg0()
	call TargetNameToArg0
;> CopySystemText(0x0600 | wSkillId, wTextArg1)   # the skill's name
	ld a, [wSkillId]
	ld l, a
	ld h, $06
	ld de, wTextArg1
	call CopySystemText
;> wTextGroup = 0
;> wTextIndex = 0xD7
	xor a
	ld [wTextGroup], a
	ld a, $d7
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleArg0 = 0x40
	ld a, $40
	ld [wBattleArg0], a
;> StartReactionFar_53()
	ld hl, far_StartReactionFar_53
	rst $10
	ret


;@ def ActionStepDone()
;@ path: battle/actions
;@ Action step 7: the action is over, on to the next battle step.
ActionStepDone::
;> wBattleSubStep = 0
	xor a
	ld [wBattleSubStep], a
;> wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
	ret


	; unused: two follow-up stages (bank $5F's routine, a message), each then
	; wBattleSubStep2 += 1
	db $21, $06, $5f, $d7, $21, $ee, $d9, $34, $c9, $21, $00, $4c, $d7, $21, $ee, $d9
	db $34, $c9

;@ def ActionStepDefeat()
;@ path: battle/actions
;@ Action step 8: the target is defeated (DefeatBattler). Once the text is out
;@ (or right away when $C87E is set) the enemy's picture is blanked if asked
;@ (wBattleStepArg1 1), and the screen is redrawn. After skill $3B and Kamikaze
;@ the follow-up step (4) comes next.
ActionStepDefeat::
;> wBattleArg0 = wSkillTarget
	ld a, [wSkillTarget]
	ld [wBattleArg0], a
;> DefeatBattler()
	ld hl, far_DefeatBattler
	rst $10
;> if not mem[0xC87E] and wTextState:
;>     return
	ld a, [$c87e]
	or a
	jr nz, .shown

	ld a, [wTextState]
	or a
	ret nz

.shown
;> if wBattleStepArg1 == 1:
;>     BlankEnemyPicture()
	ld a, [wBattleStepArg1]
	cp $01
	jr nz, .redraw

	ld hl, far_BlankEnemyPicture
	rst $10

.redraw
;> mem[0xC87E] = 0
	xor a
	ld [$c87e], a
;> CopyTilemapBufferToScreen_50()
	ld hl, far_CopyTilemapBufferToScreen_50
	rst $10
;> if wSkillId in (0x3B, 0x3E):
	ld a, [wSkillId]
	cp $3b
	jr z, .followUp

	cp $3e
	ret nz

.followUp
;>     wBattleSubStep = 4
	ld a, $04
	ld [wBattleSubStep], a
	ret


;@ def ActionStepItem()
;@ path: battle/items
;@ Action step 9: Terry uses an item. Sets up the message "<Terry> used <item>
;@ on <target>" (the item's name is system text group 8, item - $AF), with a
;@ delay, and goes on to the item's effect (step 10). The meats ($C2-$C6) use
;@ text group 1; thrown at the enemy species $D7 in the first enemy place they
;@ go to step $14 instead. Item $D5 has its own routine (UseBeastTail).
ActionStepItem::
;> if wBattleItemEffect == 0xD5:
	ld a, [wBattleItemEffect]
	cp $d5
	jr nz, .normal

;>     return UseBeastTail()
	ld hl, far_UseBeastTail
	rst $10
	ret


.normal
;> wBattleStepArg0 = 0
;> wBattleStepArg1 = 0
	xor a
	ld [wBattleStepArg0], a
	xor a
	ld [wBattleStepArg1], a
;> wMenuChoice = 0x80
;> wSkillUser = 0x10                        # Terry
	ld a, $80
	ld [wMenuChoice], a
	ld a, $10
	ld [wSkillUser], a
;> FixActionTarget()
	ld hl, far_FixActionTarget
	rst $10
;> wSkillId = 0
	ld a, $00
	ld [wSkillId], a
;> CopyName(wPlayerName, wTextArg0)
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
;>@n CopySystemText(0x0800 | wBattleItemEffect - 0xAF, wTextArg1)   # the item's name
	ld a, [wBattleItemEffect]
	sub $af
	ld l, a
	ld h, $08
	ld de, wTextArg1
;=@n
	call CopySystemText
;> wNamePos = wBattleItemTarget
;> GetBattlerNameTo(wBattleItemTarget, wTextArg2)
	ld hl, wTextArg2
	ld a, [wBattleItemTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
;> GetItemMessage()
	ld hl, far_GetItemMessage
	rst $10
;> wMonStats[0] = 0x18                      # delay
	ld a, $18
	ld [wMonStats], a
;> wTextIndex = wBattleArg0
;> wTextGroup = 0
	ld a, [wBattleArg0]
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
;> if 0xC2 <= wBattleItemEffect < 0xC7:    # the meats
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, .text

	cp $c7
	jr nc, .text

;>     wTextGroup = 1
	ld a, $01
	ld [wTextGroup], a
;>     if wBattleItemTarget == 4 and wBattlerSpecies[4] == 0xD7:
	ld a, [wBattleItemTarget]
	cp $04
	jr nz, .text

	ld a, [wBattlerSpecies + 4]
	cp $d7
	jr nz, .text

;>         wBattleSubStep = 0x14
	ld a, $14
	ld [wBattleSubStep], a

.text
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> mem[0xDB52] = wBattleItemTarget
	ld a, [wBattleItemTarget]
	ld [$db52], a
;> wSkillUser = 0x10
	ld a, $10
	ld [wSkillUser], a
	ret


;@ def ItemTargetUnfit()
;@ path: battle/items
;@ The item cannot be used on its target: message $BA with the target's name,
;@ then step $0C. After a meat wSkillId becomes 1.
ItemTargetUnfit::
;> wNamePos = wSkillTarget
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	ld hl, wTextArg0
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
;> wTextIndex = 0xBA
;> wTextGroup = 0
	ld a, $ba
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep = 0x0C
	ld a, $0c
	ld [wBattleSubStep], a
;> if wBattleItemEffect >= 0xC2:
;>     wSkillId = 1
	ld a, [wBattleItemEffect]
	cp $c2
	ret c

	ld a, $01
	ld [wSkillId], a
	ret


;@ def ItemCheckTarget()
;@ path: battle/items
;@ Item stage 3: a target turned into an iron lump (Ironize, wBattlerStatus5
;@ bits 6-7) takes no item; else the item works (UseBattleItem).
ItemCheckTarget::
;> if wBattlerStatus[8 * wBattleItemTarget + 5] & 0xC0:
;>     return ItemTargetUnfit()
	ld a, [wBattleItemTarget]
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr nz, ItemTargetUnfit

;> wBattleStepArg0 += 1
	ld hl, wBattleStepArg0
	inc [hl]
;> UseBattleItem()
	call UseBattleItem
	ret


;@ def ActionStepItemEffect()
;@ path: battle/items
;@ Action step 10, after the delay, by stage (wBattleStepArg0): 0 checks the
;@ target (gone, and the item is not WARLDLEAF: message $BB "no effect"; a meat
;@ looks for a target with FindMeatTarget), 1 starts the item's animation, 2
;@ moves on to the next target of an item for several (wBattleStepArg1
;@ counts them up to wBattleItemUsedUp), 3 uses it (ItemCheckTarget), then the
;@ result message (step 11) or, with wSkillMsgMode set, the animation again.
;@ test: skip calls routines in other banks
ActionStepItemEffect::
;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .stage

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret


.stage
;>@s stage = wBattleStepArg0
	ld a, [wBattleStepArg0]
	or a
	jr z, .check

	cp $01
	jr z, .anim

;=@s
	cp $02
	jr z, .nextTarget

	cp $03
	jr z, ItemCheckTarget

;=@s
	cp $04
	jp z, .done

	jp .done


.check
;> if stage == 0:
;>     if CheckBattlerPresent(wBattleItemTarget) and wBattleItemEffect != 0xBB:   # gone, and not WARLDLEAF
;>@f         return ItemNoEffect()
	ld a, [wBattleItemTarget]
	call CheckBattlerPresent
	jr nc, .begin

	ld a, [wBattleItemEffect]
	cp $bb
	jr z, .begin

.noEffect
;=@f
	ld a, $00
	ld [wTextGroup], a
	ld a, $bb
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
;=@f
	ld a, $0c
	ld [wBattleSubStep], a
	ld a, $00
	ld [wSkillId], a
	ret


.begin
;>     wBattleStepArg0 += 1
	ld hl, wBattleStepArg0
	inc [hl]
;>     wSkillTarget = wBattleItemTarget
	ld a, [wBattleItemTarget]
	ld [wSkillTarget], a
;>     wSkillId = wBattleItemEffect
	ld a, [wBattleItemEffect]
	ld [wSkillId], a
;>     if not FindMeatTarget(wBattleItemEffect):
;>         return ItemNoEffect()           # message $BB, step $0C, wSkillId 0
	call FindMeatTarget
	ret c

	jr .noEffect

.anim
;> elif stage == 1:
;>     StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;>     wBattleStepArg0 += 1
	ld hl, wBattleStepArg0
	inc [hl]
	ret


.nextTarget
;> elif stage == 2:
;>     wBattleStepArg0 += 1
	ld hl, wBattleStepArg0
	inc [hl]
;>     wBattleStepArg1 += 1
	ld hl, wBattleStepArg1
	inc [hl]
;>     if wSkillAnimPhase != 2:
;>         return
	ld a, [wSkillAnimPhase]
	cp $02
	ret nz

;>     if wBattleStepArg1 == wBattleItemUsedUp:
;>         return
	ld a, [wBattleItemUsedUp]
	ld b, a
	ld a, [wBattleStepArg1]
	cp b
	ret z

.findNext
;>     while True:
;>@n         wSkillTarget += 1
	ld a, [wSkillTarget]
	inc a
	ld [wSkillTarget], a
;>         if (wSkillTarget & 3) == 3:
;>             return
	and $03
	cp $03
	ret z

;>         if not CheckBattlerPresent(wSkillTarget):
;>@b             break
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .findNext

;>     wBattleStepArg0 -= 2                  # back to stage 1 for it
	ld hl, wBattleStepArg0
	dec [hl]
	ld hl, wBattleStepArg0
	dec [hl]
	ret


.done
;> else:
;>     wBattleStepArg1 = 0
	xor a
	ld [wBattleStepArg1], a
;>     if not wSkillMsgMode:
	ld a, [wSkillMsgMode]
	or a
	jr nz, .again

;>         wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;>         wBattleStepArg0 = 4
	ld a, $04
	ld [wBattleStepArg0], a
;>         StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


.again
;>     else:
;>         StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;>         wSkillMsgMode = 0
	xor a
	ld [wSkillMsgMode], a
;>         wBattleSubStep = 0x0A
	ld a, $0a
	ld [wBattleSubStep], a
	ret


;@ def ActionStepItemTarget()
;@ path: battle/items
;@ Action step 11: when the target is still in the fight, on to step 12. A
;@ target that is out (not the helper's place 3) is defeated
;@ (ActionStepDefeat) and becomes wJoinCandidate (a monster that may want to
;@ join); message $E4 follows. Then step $0C.
ActionStepItemTarget::
;> if not CheckBattlerPresent(wSkillTarget):
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .out

;>     wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;>     wBattleItemUsedUp = 0
	xor a
	ld [wBattleItemUsedUp], a
;>     return ActionStepItemEnd()
	jr ActionStepItemEnd

.out
;> show = True
;> if (wSkillTarget & 3) != 3:
	ld a, [wSkillTarget]
	and $03
	cp $03
	jr z, .message

;>@e     if wBattlerState[wBattleItemTarget] == 0xFF:
	ld a, [wBattleItemTarget]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@e
	ld h, a
	ld a, [hl]
	cp $ff
;>         show = False
	jr z, .end

;>     else:
;>         ActionStepDefeat()
	call ActionStepDefeat
;>         wJoinCandidate = wBattleItemTarget
	ld a, [wBattleItemTarget]
	ld [wJoinCandidate], a

.message
;> if show:
;>@m     GetBattlerNameTo(wBattleItemTarget, wTextArg0)
	ld hl, wTextArg0
	ld a, [wBattleItemTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
;>     wTextIndex = 0xE4
;>     wTextGroup = 0
	ld a, $e4
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     wMonStats[0] = 5
	ld a, $05
	ld [wMonStats], a

.end
;> wBattleSubStep = 0x0C
	ld a, $0c
	ld [wBattleSubStep], a
;> wBattleItemUsedUp = 0
	xor a
	ld [wBattleItemUsedUp], a
	ret


;@ def ActionStepItemEnd()
;@ path: battle/items
;@ Action step 12, after the delay: the panel is redrawn; an item for several
;@ targets (bit 0 of its skill word 2 clear) goes on with the next one in the
;@ fight (step 10 again). Then BADMEAT poisons (BadMeatEffect), the item is
;@ used up (ConsumeBattleItem) and the action finishes.
ActionStepItemEnd::
;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .go

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret


.go
;> if not wBattleItemUsedUp:
	ld a, [wBattleItemUsedUp]
	or a
	jr nz, .finish

;>     PrintPanelHPMP()
	ld hl, far_PrintPanelHPMP
	rst $10
;>     wBattleArg0 = wBattleItemEffect
;>     wBattleArg1 = 0
	ld a, [wBattleItemEffect]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
;>     wBattleArg2 = 2
	ld a, $02
	ld [wBattleArg2], a
;>     GetSkillWord()
	ld hl, far_GetSkillWord
	rst $10
;>     if not wBattleArg0 & 0x01:
;>@l         while (wBattleItemTarget & 3) != 3:
;>@l2             wBattleItemTarget += 1
;>@l3             if not CheckBattlerPresent(wBattleItemTarget):
;>@l4                 return ActionStepItemAgain()
	ld a, [wBattleArg0]
	bit 0, a
	jr z, .nextTarget

.consume
;>     if wBattleItemEffect == 0xC5 and not BadMeatEffect():
;>         return
	ld a, [wBattleItemEffect]
	cp $c5
	jr nz, .usedUp

	call BadMeatEffect
	ret nc

.usedUp
;>     item = wBattleItemEffect
;>@t     wBattleItemTarget = 0xFF
	ld a, [wBattleItemEffect]
	ld b, a
	ld a, $ff
	ld [wBattleItemTarget], a
;>     wBattleItemEffect = 0xFF
	ld a, $ff
	ld [wBattleItemEffect], a
;>     if wSkillId or item == 0xC9:
	ld a, [wSkillId]
	or a
	jr nz, .consumeItem

	ld a, b
	cp $c9
	jr nz, .finish

.consumeItem
;>         ConsumeBattleItem()
	ld hl, far_ConsumeBattleItem
	rst $10
;>         if wBattleItemUsedUp:
;>             return
	ld a, [wBattleItemUsedUp]
	or a
	ret nz

.finish
;> FinishAction()
	call FinishAction
	ret


.nextTarget
;=@l
	ld a, [wBattleItemTarget]
	and $03
	cp $03
	jr z, .consume

;=@l2
	ld hl, wBattleItemTarget
	inc [hl]
;=@l3
	ld a, [wBattleItemTarget]
	call CheckBattlerPresent
	jr c, .nextTarget

;=@l4
	jr ActionStepItemAgain

	db $c9                                  ; unused

;@ def ActionStepFinish()
;@ path: battle/actions
;@ Action step 13: finishes the action.
ActionStepFinish::
;> FinishAction()
	call FinishAction
	ret


;@ def ActionStepItemAgain()
;@ path: battle/items
;@ Action step 14: back to step 10, one stage earlier (the item's next target).
ActionStepItemAgain::
;> wBattleSubStep = 0x0A
	ld a, $0a
	ld [wBattleSubStep], a
;> wBattleStepArg0 -= 1
	ld hl, wBattleStepArg0
	dec [hl]
	ret


;@ def BadMeatEffect() -> carry
;@ path: battle/items
;@ BADMEAT poisons a monster: from the item's target (or the next place,
;@ wHitCount) the first one in the fight, with a chance by its poison resistance
;@ (resistance 18: 75%, 50%, 25%, never), message $CE. Returns carry for an own
;@ monster or when none was found, no carry for an enemy (the item then ends
;@ there).
;@ test: skip calls routines in other banks
BadMeatEffect::
;> Random()
	call Random
;> if wHitCount:
;>     c = wHitCount
	ld a, [wHitCount]
	or a
	jr nz, .fromCount

;> elif wBattleItemTarget & 4:
;>@f     c = 4
	ld a, [wBattleItemTarget]
	bit 2, a
	jr z, .fromTarget

;=@f
	ld c, $04
	jr .find

.none
;=@n
	scf
	ret


.fromTarget
;> else:
;>     c = wBattleItemTarget
	ld c, a
	jr .find

.fromCount
	ld c, a

.find
;> while CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr nc, .found

;>     c += 1
	inc c
;>     if (c & 3) == 2:
;>@n         return True
	ld a, c
	and $03
	cp $02
	jr z, .none

	jr .find

.found
;> if c & 4:
;>@h     wHitCount = c + 1
	ld a, c
	bit 2, a
	jr z, .resist

;=@h
	ld a, c
	ld [wHitCount], a
	ld hl, wHitCount
	inc [hl]

.resist
;>@r level = wBattlerResist[7 * c + 4] & 3        # resistance 18 (poison)
	ld a, c
	ld hl, wBattlerResist + 4
	add a
	add c
	add a
	add c
;=@r
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@r
	and $03
;>@l limit = (0x40, 0x80, 0xC0, 0xFF)[level]
	or a
	jr z, .level0

	cp $01
	jr z, .level1

;=@l
	cp $02
	jr z, .level2

	ld a, $ff
	jr .roll

.level0
;=@l
	ld a, $40
	jr .roll

.level1
;=@l
	ld a, $80
	jr .roll

.level2
;=@l
	ld a, $c0

.roll
;> wSkillTarget = c
;>@q if wRandomHigh > limit and not wBattlerStatus[8 * c] & 0x03:
	ld hl, wRandomHigh
	cp [hl]
	ld a, c
	ld [wSkillTarget], a
	jr nc, .done

;=@q
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, .done

;>     wBattlerStatus[8 * c] |= 0x01                # poisoned
	push bc
	set 0, [hl]
;>     TargetNameToArg0()
	call TargetNameToArg0
;>     wTextIndex = 0xCE
;>     wTextGroup = 0
	ld a, $ce
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     UpdateStatusIcon_50()
	pop bc
	ld hl, far_UpdateStatusIcon_50
	rst $10

.done
;> return wSkillTarget < 4
	ld a, [wSkillTarget]
	cp $04
	ret


;@ def ActionStepFinishReset()
;@ path: battle/actions
;@ Action step 15: finishes the action and starts over at step 0.
ActionStepFinishReset::
;> FinishAction()
	call FinishAction
;> wBattleSubStep = 0
	ld a, $00
	ld [wBattleSubStep], a
	ret


;@ def ActionStepRestart()
;@ path: battle/actions
;@ Action step 16: back to step 0, stage 1.
ActionStepRestart::
;> wBattleSubStep = 0
	xor a
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 1
	ld a, $01
	ld [wBattleSubStep2], a
	ret


;@ def ActionStep17()
;@ path: battle/actions
;@ Action step 17: a confused monster picks what it does (bank $53).
ActionStep17::
;> PickConfusedAction_53()
	ld hl, far_PickConfusedAction_53
	rst $10
	ret


;@ def ActionStepCounter()
;@ path: battle/actions
;@ Action step 19: the stages of a counterattack (CounterStageTable).
ActionStepCounter::
;> return CounterStageTable[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: battle/actions
;@ Stages of a BladeD counterattack.
CounterStageTable::
	dw CounterStage0
	dw CounterStageHit
	dw CounterStageEnd
	dw CounterStageUserDown

;@ def ActionStepNone()
;@ path: battle/actions
;@ Action step 20: nothing.
ActionStepNone::
;> return
	ret


;@ def FindMeatTarget(item: a) -> carry
;@ path: battle/items
;@ Carry for items other than the meats ($C2-$C6). For a meat: from wSkillTarget
;@ on, the first monster in the fight without any of the ailments in status
;@ bytes 0 (bits $CC), 3 ($3F), 4 ($0C) and 5 ($C0) is taken (carry); none
;@ found up to place 2 of the side: no carry.
FindMeatTarget::
;> if not 0xC2 <= item < 0xC7:
;>@y     return True
	cp $c2
	ret c

	cp $c7
	jr c, .loop

.yes
;=@y
	scf
	ret


.loop
;> while True:
;>@s     status = wBattlerStatus + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;>     if not (mem[status] & 0xCC or mem[status + 3] & 0x3F or mem[status + 4] & 0x0C or mem[status + 5] & 0xC0):
;>@t         return True
	ld a, [hli]
	and $cc
	jr nz, .next

	inc hl
	inc hl
;=@t
	ld a, [hli]
	and $3f
	jr nz, .next

	ld a, [hli]
	and $0c
	jr nz, .next

;=@t
	ld a, [hl]
	and $c0
	jr z, .yes

.next
;>     while True:
;>@w         wSkillTarget += 1
	ld hl, wSkillTarget
	inc [hl]
;>         if not CheckBattlerPresent(wSkillTarget):
;>@b             break
	ld a, [hl]
	call CheckBattlerPresent
	jr nc, .loop

;>         if (wSkillTarget & 3) >= 2:
;>@r             return False
	ld a, [hl]
	and $03
	cp $02
	jr c, .next

;=@r
	xor a
	ret


;@ path: unused
;@ Unused battle code nothing calls, a few small routines: one compares the ailment
;@ level in a status byte (bits 2-3) with $C899 and rewrites the byte; others look at
;@ the skill in $DB8A (ranges of skill numbers) and print a battle message.
UnusedBattleItemChecks::
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

;@ def CheckBattleOver() -> carry
;@ path: battle/actions
;@ Far entry 1: carry when the battle is decided. All own monsters out (gone,
;@ or bit 6 of status byte 0): lost, message $EB with Terry's name (in a link
;@ battle bank $50's result message), battle step $0E. All enemies out (in a
;@ link battle also those with bit 6): won (ShowVictoryMessage). Then the
;@ end music and sound ($69, or $4F for the loser; wBattleType $FF after a
;@ loss) and battle step $0A; wSkillMsgMode keeps the result (1 lost, 0 won,
;@ seen from the master in a link battle). Not decided: wSkillMsgMode $FF.
;@ test: skip calls routines in other banks
CheckBattleOver::
;>@a own_alive = any(not CheckBattlerPresent(c) and not wBattlerStatus[8 * c] & 0x40 for c in range(3))
	ld bc, $0300

.own
;=@a
	ld a, c
	call CheckBattlerPresent
	jr c, .nextOwn

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
;=@a
	bit 6, [hl]
	jr z, .enemies

.nextOwn
;=@a
	inc c
	dec b
	jr nz, .own

;> if not own_alive:
;>     wBattleStep = 0x0E                    # lost
	ld a, $0e
	ld [wBattleStep], a
;>     if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .lostText

;>         ShowLinkResultMessage()
	ld hl, far_ShowLinkResultMessage
	rst $10
;>         wBattlerReload = 1
	ld a, $01
	ld [wBattlerReload], a
	jr .music

;>     else:
;>         CopyName(wPlayerName, wTextArg0)
.lostText
	ld de, wPlayerName
	ld hl, wTextArg0
	call CopyName
;>         wBattlerReload = 1
;>@t1         wTextGroup = 0
;>@t2         wTextIndex = 0xEB
;>@t3         StartText_4C()
	ld hl, $00eb
	ld a, $01
	ld [wBattlerReload], a
	jr .text

.enemies
;> else:
;>@e     if any(not CheckBattlerPresent(c) and (not wLinkActive or not wBattlerStatus[8 * c] & 0x40) for c in range(4, 7)): wSkillMsgMode = 0xFF; return False
	ld bc, $0304

.enemy
;=@e
	ld a, c
	call CheckBattlerPresent
	jr c, .nextEnemy

	ld a, [wLinkActive]
	or a
	jr z, .notOver

;=@e
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	jr z, .notOver

.nextEnemy
;=@e
	inc c
	dec b
	jr nz, .enemy

;>     wBattlerReload = 0                    # won
	ld a, $00
	ld [wBattlerReload], a
;>     wBattleArg2 = 0
	ld a, $00
	ld [wBattleArg2], a
;>     ShowVictoryMessage()
	ld hl, far_ShowVictoryMessage
	rst $10
	jr .music

.text
;=@t1
	ld a, h
	ld [wTextGroup], a
;=@t2
	ld a, l
	ld [wTextIndex], a
;=@t3
	ld hl, far_StartText_4C
	rst $10

.music
;> sound = 0x69
;> lost = wBattlerReload
	ld c, $69
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wBattlerReload]
	jr z, .side

;> if wLinkFlags & 0x02:
;>     lost ^= 1
	xor $01
;>     wBattlerReload = lost
	ld [wBattlerReload], a

.side
;> if lost:
	or a
	jr z, .play

;>     wBattleType = 0xFF
;>     sound = 0x4F
	ld a, $ff
	ld [wBattleType], a
	ld c, $4f

.play
;> QueueMusic(2)
	push bc
	ld a, $02
	call QueueMusic
	pop bc
;> QueueSound(sound)
	ld a, c
	call QueueSound
;> wBattleArg2 = 0
;> wBattleStep = 0x0A
	ld a, $00
	ld [wBattleArg2], a
	ld a, $0a
	ld [wBattleStep], a
;> wSkillMsgMode = wBattlerReload
;> return True
	scf
	ld a, [wBattlerReload]
	ld [wSkillMsgMode], a
	ret


.notOver
;=@e
	ld a, $ff
	ld [wSkillMsgMode], a
	xor a
	ret


;@ def CheckSideDefeated() -> carry
;@ path: battle/actions
;@ Carry when all three monsters of one side are out (IsBattlerOut), own side
;@ first.
CheckSideDefeated::
;>@i if IsBattlerOut(0) and IsBattlerOut(1) and IsBattlerOut(2):
;>     return True
	ld bc, $0300
	call IsBattlerOut
	jr nc, .enemies

	inc c
	call IsBattlerOut
;=@i
	jr nc, .enemies

	inc c
	call IsBattlerOut
	ret c

.enemies
;>@a return IsBattlerOut(4) and IsBattlerOut(5) and IsBattlerOut(6)
	ld bc, $0304
	call IsBattlerOut
	jr nc, .done

	inc c
	call IsBattlerOut
;=@a
	jr nc, .done

	inc c
	call IsBattlerOut

.done
	ret


;@ def IsBattlerOut(c: c) -> carry
;@ path: battle/actions
;@ Carry when battle position `c` is out of the fight; an own monster (and in a
;@ link battle any) also counts as out with bit 6 of its status byte 0.
IsBattlerOut::
;> if not wLinkActive and c >= 4:
	ld a, [wLinkActive]
	or a
	jr nz, .withStatus

	ld a, c
	cp $04
	jr c, .withStatus

;>     return CheckBattlerPresent(c)
	call CheckBattlerPresent
	ret


.withStatus
;> if CheckBattlerPresent(c):
;>     return True
	ld a, c
	call CheckBattlerPresent
	ret c

;>@r return (wBattlerStatus[8 * c] & 0x40) != 0
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 6, [hl]
	ret z

;=@r
	scf
	ret


;@ def Skill3BStage0()
;@ path: battle/actions
;@ First stage after skill $3B: when the user is still there, its animation
;@ and sound play again.
Skill3BStage0::
;> if CheckUserGone():
;>     return
	call CheckUserGone
	ret c

;> if CheckBattlerPresent(wSkillUser):
;>     return StagesEnd()
	ld a, [wSkillUser]
	call CheckBattlerPresent
	jp c, StagesEnd

;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;> PlaySkillSound4()
	ld hl, far_PlaySkillSound4
	rst $10
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def Skill3BStage1()
;@ path: battle/actions
;@ The user of skill $3B loses a quarter of the damage it did (at least 1,
;@ wSkillAmount2); at 0 HP it goes down next (RecoilStageUserDown).
Skill3BStage1::
;> wBattleSubStep2 += 2
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
;>@a loss = wSkillAmount >> 2
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	srl b
	rr c
;=@a
	srl b
	rr c
;> wSkillAmount2 = loss
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [wSkillAmount2 + 1], a
;> if loss == 0:
	ld a, b
	or c
	jr nz, .lose

;>     loss = 1
	inc bc
;>     wSkillAmount2 = loss
	ld a, c
	ld [wSkillAmount2], a
	ld a, b
	ld [wSkillAmount2 + 1], a

.lose
;>@h hp = wBattlerHP + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	ld d, h
	ld e, l
;> if mem16[hp] > loss:
;>@k     mem16[hp] -= loss
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	ld h, d
	ld l, e
;=@k
	jr c, .down

	jr z, .down

;=@k
	ld a, [hl]
	sub c
	ld [hli], a
	ld a, [hl]
	sbc b
	ld [hl], a
;>@s     return ShowUserHPLossMessage()
	jr ShowUserHPLossMessage

.down
;> mem16[hp] = 0
	xor a
	ld [hld], a
	ld [hl], a
;> wBattleStepArg0 = 0xFF
;> wBattleStepArg1 = 0xFF
	ld a, $ff
	ld [wBattleStepArg0], a
	ld a, $ff
	ld [wBattleStepArg1], a
;> wBattleSubStep2 = 2
;> return ShowUserHPLossMessage()           # runs on into it
	ld a, $02
	ld [wBattleSubStep2], a

;@ def ShowUserHPLossMessage()
;@ path: battle/actions
;@ "<user> lost <wSkillAmount2> HP": message $82, $83 when the side seen from
;@ this Game Boy is the far one, the other one of the pair when the target is
;@ on the user's side (PrintUserMessage).
ShowUserHPLossMessage::
;> Number16ToDecimal(wSkillAmount2, wTextArg1)
	ld hl, wTextArg1
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
	call Number16ToDecimal
;> wBattlerReload = 0x82                   # the message number
	ld a, $82
	ld [wBattlerReload], a
;> if GetViewSidePos() >= 4:
;>     wBattlerReload += 1
	call GetViewSidePos
	cp $04
	jr c, .same

	ld hl, wBattlerReload
	inc [hl]

.same
;> if IsTargetSameSide():
;>     FlipMessageVariant()
	call IsTargetSameSide
	call z, FlipMessageVariant
;> PrintUserMessage()
	call PrintUserMessage
	ret


;@ def IsTargetSameSide() -> zero
;@ path: battle/actions
;@ Zero flag when the skill's user and target are on the same side.
IsTargetSameSide::
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld b, a
;> return (wSkillTarget & 4) == side
	ld a, [wSkillTarget]
	and $04
	cp b
	ret


;@ def FlipMessageVariant()
;@ path: battle/actions
;@ Switches the message number in wBattlerReload to the other of its pair.
FlipMessageVariant::
;> wBattlerReload ^= 1
	ld a, [wBattlerReload]
	xor $01
	ld [wBattlerReload], a
	ret


;@ def PickUserDownMessage()
;@ path: battle/actions
;@ For a user on the target's side: message $E7 becomes $EA and the others
;@ $E7 ($85 stays).
PickUserDownMessage::
;> if wBattlerReload == 0x85:
;>     return
	ld a, [wBattlerReload]
	cp $85
	ret z

;>@m wBattlerReload = 0xEA if wBattlerReload == 0xE7 else 0xE7
	cp $e7
	jr z, .ea

	ld a, $e7
	jr .store

.ea
;=@m
	ld a, $ea

.store
	ld [wBattlerReload], a
	ret


;@ def KamikazeStage0()
;@ path: battle/actions
;@ First stage after Kamikaze: the user's animation and sound again.
KamikazeStage0::
;> if CheckUserGone():
;>     return
	call CheckUserGone
	ret c

;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;> PlaySkillSound4()
	ld hl, far_PlaySkillSound4
	rst $10
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def KamikazeStage1()
;@ path: battle/actions
;@ After Kamikaze the user is left with 1 HP (message $85); when it had only 1
;@ it falls (0 HP, message $E7 or $EA, then RecoilStageUserDown).
KamikazeStage1::
;>@h hp = wBattlerHP + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> if mem16[hp] != 1:
	dec bc
	ld a, b
	or c
	jr z, .falls

;>     wBattleSubStep2 = 3
	ld a, $03
	ld [wBattleSubStep2], a
;>     mem16[hp] = 1
	ld a, $00
	ld [hld], a
	ld [hl], $01
;>@o     wBattlerReload = 0x85
	jr .one

.falls
;> else:
;>     mem16[hp] = 0
	xor a
	ld [hld], a
	ld [hl], a
;>     wBattleStepArg0 = 0xFF
;>     wBattleStepArg1 = 3
	ld a, $ff
	ld [wBattleStepArg0], a
	ld a, $03
	ld [wBattleStepArg1], a
;>     wBattleSubStep2 = 2
	ld a, $02
	ld [wBattleSubStep2], a
;>@r     wBattlerReload = 0xEA if GetViewSidePos() >= 4 else 0xE7
	ld a, $ea
	ld [wBattlerReload], a
	call GetViewSidePos
	cp $04
	jr nc, .print

;=@r
	ld a, $e7
	ld [wBattlerReload], a
	jr .print

.one
;=@o
	ld a, $85
	ld [wBattlerReload], a

.print
;> if IsTargetSameSide():
;>     PickUserDownMessage()
	call IsTargetSameSide
	call z, PickUserDownMessage
;> PrintUserMessage()
	call PrintUserMessage
	ret


;@ def PrintUserMessage()
;@ path: battle/actions
;@ Updates the icons, then message wBattlerReload with the user's name and
;@ the panel's HP and MP.
PrintUserMessage::
;> UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;> wBattleArg2 = lo(wTextArg0)
;> wBattleArg3 = hi(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser
;> GetBattlerNameTo(wSkillUser, wTextArg0)
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerNameTo
;> wTextGroup = 0
;> wTextIndex = wBattlerReload
	ld a, $00
	ld [wTextGroup], a
	ld a, [wBattlerReload]
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> PrintPanelHPMP()
	ld hl, far_PrintPanelHPMP
	rst $10
	ret


;@ def RecoilStageUserDown()
;@ path: battle/actions
;@ The user went down from its own skill: the steps noted in wBattleStepArg0/1
;@ come next ($FF keeps them), the user falls (UserFalls) and message $E7 or
;@ $EA names it.
RecoilStageUserDown::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if wBattleStepArg0 != 0xFF:
;>     wBattleSubStep = wBattleStepArg0
	ld a, [wBattleStepArg0]
	cp $ff
	jr z, .keepStep

	ld [wBattleSubStep], a

.keepStep
;> if wBattleStepArg1 != 0xFF:
;>     wBattleSubStep2 = wBattleStepArg1
	ld a, [wBattleStepArg1]
	cp $ff
	jr z, .keepStage

	ld [wBattleSubStep2], a

.keepStage
;> wBattleStepArg0 = 0
;> wBattleStepArg1 = 0
	xor a
	ld [wBattleStepArg0], a
	ld [wBattleStepArg1], a
;> UserFalls()
	call UserFalls
;> wBattleArg2 = lo(wTextArg0)
;> wBattleArg3 = hi(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser
;> GetBattlerNameTo(wSkillUser, wTextArg0)
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerNameTo
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>@m wBattlerReload = 0xEA if GetViewSidePos() >= 4 else 0xE7
	call GetViewSidePos
	cp $04
	jr nc, .far

	ld a, $e7
	jr .store

.far
;=@m
	ld a, $ea

.store
;=@m
	ld [wBattlerReload], a
;> if IsTargetSameSide():
;>     PickUserDownMessage()
	call IsTargetSameSide
	call z, PickUserDownMessage
;> wTextIndex = wBattlerReload
	ld a, [wBattlerReload]
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def StagesEnd()
;@ path: battle/actions
;@ Last follow-up stage: a target in the BladeD stance strikes back, else on
;@ to step 5 (StagesNext).
StagesEnd::
;> if CheckBladeCounter():
;>     return StartBladeCounter()            # else it runs on into StagesNext
	call CheckBladeCounter
	jp nz, StartBladeCounter

;@ def StagesNext()
;@ path: battle/actions
;@ On to action step 5 (ActionStepNext).
StagesNext::
;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> wBattleSubStep2 = 0
	ld a, $00
	ld [wBattleSubStep2], a
;> return ActionStepNext()
	jp ActionStepNext


;@ def StageShowText()
;@ path: battle/actions
;@ A follow-up stage that shows the message set up before.
StageShowText::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def CheckUserGone() -> carry
;@ path: battle/actions
;@ When the skill's user is no longer in the fight: on to the next step,
;@ carry.
CheckUserGone::
;> if not CheckBattlerPresent(wSkillUser):
;>     return False
	ld a, [wSkillUser]
	call CheckBattlerPresent
	ret nc

;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> return True
	scf
	ret


;@ def RammingStage0()
;@ path: battle/actions
;@ First stage after Ramming: the user's animation and sound again.
RammingStage0::
;> if CheckUserGone():
;>     return
	call CheckUserGone
	ret c

;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
;> PlaySkillSound4()
	ld hl, far_PlaySkillSound4
	rst $10
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def RammingStage1()
;@ path: battle/actions
;@ The user of Ramming loses 80% of its HP plus one (wSkillAmount2); at 0 it
;@ goes down (RecoilStageUserDown, then step 4).
RammingStage1::
;> wBattleSubStep2 += 2
	ld hl, wBattleSubStep2
	inc [hl]
	ld hl, wBattleSubStep2
	inc [hl]
;>@h hp = wBattlerHP + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerHP
	call IndexWords
	push hl
	ld a, [hli]
	ld h, [hl]
;> loss = Percent80(mem16[hp]) + 1
	ld l, a
	push hl
	call Percent80
	inc hl
;> wSkillAmount2 = loss
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;>@n new = max(mem16[hp] - loss, 0)
	pop bc
	ld a, c
	sub l
	ld c, a
	ld a, b
;=@n
	sbc h
	ld b, a
	jr c, .zero

	or c
	jr z, .zero

	jr .store

.zero
;=@n
	ld bc, $0000

.store
;> mem16[hp] = new
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
;> if new == 0:
	or c
	jr nz, .message

;>@d     wBattleSubStep2 -= 1
	ld hl, wBattleSubStep2
	dec [hl]
;>     wBattleStepArg0 = 4
;>     wBattleStepArg1 = 0xFF
	ld a, $04
	ld [wBattleStepArg0], a
	ld a, $ff
	ld [wBattleStepArg1], a
;>     wBattleSubStep2 = 2
	ld a, $02
	ld [wBattleSubStep2], a

.message
;> ShowUserHPLossMessage()
	call ShowUserHPLossMessage
	ret


	; unused: wBattleSubStep = 1 when wHitCount is 1, else wBattleSubStep2 += 1
	db $fa, $69, $dd, $fe, $01, $20, $06, $3e, $01, $ea, $ed, $d9, $c9, $21, $ee, $d9
	db $34, $c9

;@ def UserFalls()
;@ path: battle/actions
;@ Far entry 2: the skill's user falls (wBattlerState 1, ActionStepDefeat on
;@ it); a fallen wild enemy (not the helper's place 7) becomes wJoinCandidate.
UserFalls::
;>@s wBattlerState[wSkillUser] = 1
	ld a, [wSkillUser]
	ld hl, wBattlerState
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld [hl], $01
;> target = wSkillTarget
;> wSkillTarget = wSkillUser
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> ActionStepDefeat()
	call ActionStepDefeat
;> wSkillTarget = target
	pop af
	ld [wSkillTarget], a
;> if wSkillUser >= 4 and wSkillUser != 7:
	ld a, [wSkillUser]
	cp $04
	jr c, .done

	cp $07
	jr z, .done

;>     wJoinCandidate = wSkillUser
	ld a, [wSkillUser]
	ld [wJoinCandidate], a

.done
	ret


;@ def DeMagicStage0()
;@ path: battle/actions
;@ First stage after DeMagic: a user that has transformed (status 1 bit 4)
;@ goes to stage 1, others skip it.
DeMagicStage0::
;> if not wBattlerStatus[8 * wSkillUser + 1] & 0x10:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 4, [hl]
	jr nz, .next

;>     wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]

.next
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def DeMagicStage1()
;@ path: battle/actions
;@ The transformed user turns back into itself (TransformIntoTarget on itself).
DeMagicStage1::
;> wSkillTarget = wSkillUser
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> TransformIntoTarget()
	call TransformIntoTarget
	ret


;@ def LifeSongStage0()
;@ path: battle/actions
;@ LifeSong: a target that is down (not empty) is revived (SkillVivify).
LifeSongStage0::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget) and wBattlerState[wSkillTarget] != 0xFF:   # down, not empty
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr z, .skip

	jr nc, .skip

;>     return SkillVivify()
	call SkillVivify
	ret


.skip
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def LifeSongStage1()
;@ path: battle/actions
;@ LifeSong: message $9E with the target's name.
LifeSongStage1::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> TargetNameToArg0()
	call TargetNameToArg0
;> wTextIndex = 0x9E
;> wTextGroup = 0
	ld a, $9e
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def LifeSongStage2()
;@ path: battle/actions
;@ LifeSong goes on with the next place of the side that is down (back to
;@ stage 0), until the side's third place.
LifeSongStage2::
;> while True:
;>     UpdateStatusIcon_50()
	ld hl, far_UpdateStatusIcon_50
	rst $10
;>     wSkillTarget += 1
	ld hl, wSkillTarget
	inc [hl]
	ld a, [hl]
;>     if (wSkillTarget & 3) == 3:
;>@e         wBattleSubStep2 += 1
;>@r         return
	ld b, a
	and $03
	cp $03
	jr z, .end

;>     if wBattlerState[wSkillTarget] != 0xFF:      # not an empty place
;>@z         wBattleSubStep2 = 0
;>         return
	ld a, b
	call CheckBattlerPresent
	jr z, LifeSongStage2

;=@z
	xor a
	ld [wBattleSubStep2], a
	ret


.end
;=@e
	ld hl, wBattleSubStep2
	inc [hl]
;=@r
	ret


;@ def ChgDragonPickAction()
;@ path: battle/actions
;@ After CHGDRAGON the dragon picks its next action at random from Attack,
;@ Scorching, IceStorm and DeMagic. Its target is the far side's first place;
;@ for Attack a random place of the far side, moving back over empty places
;@ (that search loses the side bit, so it then looks at places 0-2).
;@ test: skip needs valid battle or party records; random states send the original code astray
ChgDragonPickAction::
;> ptr = wBattlerAction + 2 * wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	call IndexWords
;>@s skill = (0x3A, 0x5E, 0x62, 0x80)[wRandomHigh & 3]   # Attack, Scorching, IceStorm, DeMagic
	push hl
	ld a, [wRandomHigh]
	and $03
	ld hl, .skills
	add l
	ld l, a
;=@s
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	pop hl
;> mem[ptr] = skill
	ld [hli], a
	ld c, a
	push hl
;> t = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld b, a
;> if skill == 0x3A:
	ld a, c
	cp $3a
	jr nz, .store

;>     t += wRandomHigh & 3
	ld a, [wRandomHigh]
	and $03
	add b

.find
;>     while CheckBattlerPresent(t):
	ld b, a
	call CheckBattlerPresent
	jr nc, .store

;>@d         t = (t & 3) - 1 if t & 3 else 2
	ld a, b
	and $03
	jr nz, .back

	ld b, a
	or $03

.back
;=@d
	dec a
	jr .find

.store
;> mem[ptr + 1] = t
	pop hl
	ld a, b
	ld [hl], a
;> wBattleSubStep = 0
	ld a, $00
	ld [wBattleSubStep], a
	ret


.skills
	db $3a, $5e, $62, $80                   ; Attack, Scorching, IceStorm, DeMagic

	; unused: $FF, then a routine that clears the low six bits of the user's
	; status byte 3
	db $ff, $f5, $c5, $d5, $e5, $fa, $88, $db, $21, $05, $db, $cd
	db $6c, $2f, $7e, $e6, $c0, $77, $e1, $d1, $c1, $f1, $c9

;@ def ClearMPAfterSkill()
;@ path: battle/actions
;@ Farewell ($32) and MegaMagic ($66) use up all of the user's MP.
ClearMPAfterSkill::
;> if wSkillId in (0x32, 0x66):
	ld a, [wSkillId]
	cp $32
	jr z, .clear

	cp $66
	ret nz

.clear
;>@m     mem16[wBattlerMP + 2 * wSkillUser] = 0
	ld a, [wSkillUser]
	ld hl, wBattlerMP
	call IndexWords
;=@m
	xor a
	ld [hli], a
	ld [hl], a
	ret


;@ def PoisonHitStage0()
;@ path: battle/actions
;@ PoisonHit: a target in the fight that is not poisoned yet may be poisoned
;@ (TryEffectRes18): status byte 0 bit 0, message $CE with the animation.
PoisonHitStage0::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget):
;>@x     wBattleSubStep2 += 1
;>@y     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .skip

;>@p wSkillStatusPtr = wBattlerStatus + 8 * wSkillTarget
	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, l
	ld [wSkillStatusPtr], a
;=@p
	ld a, h
	ld [wSkillStatusPtr + 1], a
;> if mem[wSkillStatusPtr] & 0x03 or not TryEffectRes18(): wBattleSubStep2 += 1; return
	ld a, [hl]
	and $03
	jr nz, .skip

	call TryEffectRes18
	jr nc, .skip

;> mem[wSkillStatusPtr] |= 0x01
	ld a, [wSkillStatusPtr]
	ld l, a
	ld a, [wSkillStatusPtr + 1]
	ld h, a
	set 0, [hl]
;> wTextIndex = 0xCE
;> wTextGroup = 0
	ld a, $ce
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
	ret


.skip
;=@x
	ld hl, wBattleSubStep2
	inc [hl]
;=@y
	ret


;@ def NapAttackStage0()
;@ path: battle/actions
;@ NapAttack: a target in the fight that is not asleep may fall asleep
;@ (RollSleep, PutTargetToSleep): message $CC or $CD, then step 4.
NapAttackStage0::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget) or wBattlerStatus[8 * wSkillTarget] & 0x80 or not RollSleep():
;>@x     wBattleSubStep2 += 1
;>@y     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .skip

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;=@x
	bit 7, [hl]
	jr nz, .skip

	call RollSleep
	jr nc, .skip

;> PutTargetToSleep()
	call PutTargetToSleep
;>@i wTextIndex = 0xCC if GetViewSidePos() >= 4 else 0xCD
	ld c, $cc
	call GetViewSidePos
	cp $04
	jr nc, .text

	inc c

.text
;=@i
	ld a, c
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> wBattleSubStep = 4
	ld a, $04
	ld [wBattleSubStep], a
;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
	ret


.skip
;=@x
	ld hl, wBattleSubStep2
	inc [hl]
;=@y
	ret


;@ def ParalyzeStage0()
;@ path: battle/actions
;@ The Paralyze hit: a target in the fight that is not paralysed may be
;@ (TryEffectRes19): status byte 0 bit 6, message $CF with the animation.
ParalyzeStage0::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget) or wBattlerStatus[8 * wSkillTarget] & 0x40 or not TryEffectRes19():
;>@x     wBattleSubStep2 += 1
;>@y     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, .skip

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus
	call AddEightTimes
;=@x
	bit 6, [hl]
	jr nz, .skip

	push hl
	call TryEffectRes19
	pop hl
	jr nc, .skip

;> wBattlerStatus[8 * wSkillTarget] |= 0x40
	set 6, [hl]
;> wTextIndex = 0xCF
;> wTextGroup = 0
	ld a, $cf
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartSkillVisual()
	ld hl, far_StartSkillVisual
	rst $10
	ret


.skip
;=@x
	ld hl, wBattleSubStep2
	inc [hl]
;=@y
	ret


;@ def StartBladeCounter()
;@ path: battle/actions
;@ The target strikes back from its BladeD stance (step $13): when it can act,
;@ message $D5 or $D6 (a counter that hits or one that misses, chosen at random;
;@ a target with personality flag bit 3 always gets $D5's variant $6A) and
;@ stage 0 or 2 of CounterStageTable. A hit worth nothing (half of the damage
;@ is 0) always counts as a miss. An intercepted hit goes back to SkillFollowUp.
;@ test: skip calls routines in other banks
StartBladeCounter::
;> if wInterceptState:
;>     return SkillFollowUp()
	ld a, [wInterceptState]
	or a
	jp nz, SkillFollowUp

;> wBattleSubStep = 0x13
	ld a, $13
	ld [wBattleSubStep], a
;> wBattleArg2 = lo(wTextArg0)
;> wBattleArg3 = hi(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> if CheckBattlerCanAct(wSkillTarget):        # carry: cannot act
;>     return StagesNext()
	ld a, [wSkillTarget]
	ld b, a
	call CheckBattlerCanAct
	jp c, StagesNext

;> wNamePos = wSkillTarget
;> GetBattlerNameTo(wSkillTarget, wTextArg0)
	ld a, [wSkillTarget]
	ld [wNamePos], a
	call GetBattlerNameTo
;> BattleRandom()
	call BattleRandom
;>@p sure = wPersonalityNudge[wSkillTarget] & 0x08
	ld b, $00
	ld a, [wSkillTarget]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
;=@p
	adc h
	ld h, a
	bit 3, [hl]
	jr z, .amount

;> if sure:
;>     wRandomHigh &= 0xFE
	ld hl, wRandomHigh
	res 0, [hl]
	ld b, $01

.amount
;> if wSkillAmount >> 1 == 0:
;>@m     wRandomHigh = 1                        # a miss
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call ShiftHL1
	ld a, h
;=@m
	or l
	or a
	jr nz, .text

	ld a, $01
	ld [wRandomHigh], a

.text
;> wTextIndex = 0xD5 + (wRandomHigh & 1)
;> wTextGroup = 0
	ld a, [wRandomHigh]
	and $01
	add $d5
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
;> if sure:
;>     CounterTextVariant()
	bit 0, b
	call nz, CounterTextVariant
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>@s wBattleSubStep2 = 2 if wRandomHigh & 1 else 0
	ld a, [wRandomHigh]
	and $01
	ld [wBattleSubStep2], a
	ld a, [wRandomHigh]
	and $01
	ret z

;=@s
	ld a, [wBattleSubStep2]
	add $01
	ld [wBattleSubStep2], a
	ret


;@ def CounterStage0()
;@ path: battle/actions
;@ The counter begins: user and target change places; when the old user is
;@ still there, the hit's effect and sound play.
CounterStage0::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> SwapUserAndTarget()
	call SwapUserAndTarget
;> if CheckBattlerPresent(wSkillTarget):
;>     return
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	ret c

;> StartSkillHitEffect()
	ld hl, far_StartSkillHitEffect
	rst $10
;> PlaySkillSound0()
	ld hl, far_PlaySkillSound0
	rst $10
;> wItemMsgGroup = 0x80
	ld a, $80
	ld [wItemMsgGroup], a
	ret


;@ def CounterTextVariant()
;@ path: battle/actions
;@ The counter's message becomes $6A.
CounterTextVariant::
;> wTextIndex = 0x6A
	ld a, $6a
	ld [wTextIndex], a
	ret


;@ def SwapUserAndTarget()
;@ path: battle/actions
;@ Exchanges wSkillUser and wSkillTarget.
SwapUserAndTarget::
;> user = wSkillUser
	ld a, [wSkillUser]
	ld l, a
;> target = wSkillTarget
	ld a, [wSkillTarget]
	ld h, a
;> wSkillTarget = user
	ld a, l
	ld [wSkillTarget], a
;> wSkillUser = target
	ld a, h
	ld [wSkillUser], a
	ret


;@ def CounterStageHit()
;@ path: battle/actions
;@ The counter deals half of the damage back to the attacker (message $82 or
;@ $83); at 0 HP it goes down next (stage 3). Half of 0: a miss
;@ (ShowMissMessage). An attacker already gone: just swap back.
CounterStageHit::
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
;> if CheckBattlerPresent(wSkillTarget):
;>     return SwapUserAndTarget()
	ld a, [wSkillTarget]
	call CheckBattlerPresent
	jr c, SwapUserAndTarget

;>@h wSkillAmount >>= 1
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	call ShiftHL1
	ld a, l
;=@h
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> if wSkillAmount == 0:
;>@z     return ShowMissMessage()
	ld a, h
	or l
	jr z, .miss

;> PrepareDamageText()
	call PrepareDamageText
;>@i wTextIndex = 0x82 if GetViewSidePos() & 4 else 0x83
	ld c, $82
	call GetViewSidePos
	bit 2, a
	jr nz, .text

	ld c, $83

.text
;=@i
	ld a, c
	ld [wTextIndex], a
;> wTextGroup = 0
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleAnimDone = 1
;> wScreenEffect = 0
	ld a, $01
	ld [wBattleAnimDone], a
	ld a, $00
	ld [wScreenEffect], a
;> SwapUserAndTarget()
	call SwapUserAndTarget
;>@d hp = mem16[wBattlerHP + 2 * wSkillUser] - wSkillAmount      # the attacker
	ld hl, wBattlerHP
	call IndexWords
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wSkillAmount]
;=@d
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, e
	sub c
	ld e, a
;=@d
	ld a, d
	sbc b
	ld d, a
;> mem16[wBattlerHP + 2 * wSkillUser] = hp & 0xFFFF
	ld [hl], d
	push af
	dec hl
	pop bc
	ld [hl], e
;> if hp > 0:
;>     return
	ld a, d
	or e
	jr z, .down

	push bc
	pop af
	ret nc

.down
;> mem16[wBattlerHP + 2 * wSkillUser] = 0
	xor a
	ld [hli], a
	ld [hl], a
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


.miss
;=@z
	call ShowMissMessage
	ret


;@ def CounterStageUserDown()
;@ path: battle/actions
;@ The attacker fell to the counter: message $E3 or $E4 by its side, it is
;@ defeated and (as wSkillTarget for a moment) its picture blanked.
CounterStageUserDown::
;> wBattleArg2 = lo(wTextArg0)
;> wBattleArg3 = hi(wTextArg0)
	ld hl, wTextArg0
	ld a, l
	ld [wBattleArg2], a
	ld a, h
	ld [wBattleArg3], a
;> wNamePos = wSkillUser
;> GetBattlerNameTo(wSkillUser, wTextArg0)
	ld a, [wSkillUser]
	ld [wNamePos], a
	call GetBattlerNameTo
;> wTextGroup = 0
	ld a, $00
	ld [wTextGroup], a
;>@t wTextIndex = 0xE3 + (wSkillUser >> 2 & 1)
	ld b, $e3
	ld a, [wSkillUser]
	rrca
	rrca
	and $01
	add b
;=@t
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wBattleSubStep2 -= 1
	ld hl, wBattleSubStep2
	dec [hl]
;> wBattleArg0 = wSkillUser
	ld a, [wSkillUser]
	ld [wBattleArg0], a
;> DefeatBattler()
	ld hl, far_DefeatBattler
	rst $10
;> target = wSkillTarget
;> wSkillTarget = wSkillUser
	ld a, [wSkillTarget]
	push af
	ld a, [wSkillUser]
	ld [wSkillTarget], a
;> BlankEnemyPicture()
	ld hl, far_BlankEnemyPicture
	rst $10
;> wSkillTarget = target
	pop af
	ld [wSkillTarget], a
	ret


;@ def CounterStageEnd()
;@ path: battle/actions
;@ The counter is over: on to step 5.
CounterStageEnd::
;> wBattleSubStep = 5
	ld a, $05
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def BattleRedraw57()
;@ path: battle/actions
;@ Calls bank $57's routine Call_57_7C44 after an action.
BattleRedraw57::
;> Call_57_7C44()
	ld hl, far_Call_57_7C44
	rst $10
	ret


;@ def PrintActionMessage()
;@ path: battle/actions
;@ The battle message of a reflected skill (PrintBattleMessage). For a wind
;@ (wReflectAnim 2) on a side with bit 5 of wSideFlags, it is left out while a
;@ monster after the target on that side is still in the fight (wReflectAnim
;@ cleared instead).
PrintActionMessage::
;>@i if wReflectAnim == 2 and wSideFlags[wSkillTarget >> 2 & 1] & 0x20:
	ld a, [wReflectAnim]
	cp $02
	jr nz, .print

	ld a, [wSkillTarget]
	rrca
	rrca
;=@i
	and $01
	ld hl, wSideFlags
	add l
	ld l, a
	ld a, $00
	adc h
;=@i
	ld h, a
	bit 5, [hl]
	jr z, .print

;>@c     side = wSkillTarget & 4
	ld a, [wSkillTarget]
	ld e, a
	and $04
	ld c, a
;>@w     count = wEnemyCount if side else wPartyBattlers
	cp $04
	jr c, .own

	ld a, [wEnemyCount]
	jr .count

.own
;=@w
	ld a, [wPartyBattlers]

.count
;>     for c in range(side, side + count):
;>@g         if c > wSkillTarget and not CheckBattlerPresent(c):
;>@z             wReflectAnim = 0
;>@r             return
	ld b, a

.skip
;=@g
	ld a, c
	cp e
	jr z, .skipNext

	jr nc, .check

.skipNext
;=@g
	inc c
	dec b
	jr nz, .skip

	jr .print

.check
;=@g
	ld a, c
	call CheckBattlerPresent
	jr nc, .clear

;=@g
	inc c
	dec b
	jr nz, .check

	jr .print

.clear
;=@z
	xor a
	ld [wReflectAnim], a
;=@r
	ret


.print
;> PrintBattleMessage()
	ld hl, far_PrintBattleMessage
	rst $10
	ret


;@ def GetUserStatus4() -> hl
;@ path: battle/state
;@ Address of the skill user's status byte 4 (wBattlerStatus4).
GetUserStatus4::
;> return u16(wBattlerStatus + 4 + (8 * wSkillUser & 0xFF))
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ret


;@ def CheckTargetReacts() -> carry
;@ path: battle/actions
;@ Carry when the target answers the skill with Imitate (bit 3 of status byte
;@ 6): for a skill aimed at enemies, a target that can act copies it when the
;@ skill allows (wSkillFlags3 bit 2: message $D3, a reaction of kind 8 set up
;@ in bank $53), else message $D4 says it could not. Not for Imitate itself,
;@ an intercepted hit, or a user charging (status byte 4 bits 2-3); during a
;@ reaction of kind $20 the interrupted action is taken up again.
;@ test: skip calls routines in other banks
CheckTargetReacts::
;> if wSkillId == 0x7F or wInterceptState:
;>@n     return False
	ld a, [wSkillId]
	cp $7f
	jr nz, .notImitate

.no
;=@n
	xor a
	ret


.notImitate
;=@n
	ld a, [wInterceptState]
	or a
	jr nz, .no

;> if wReactionKind:
	ld a, [wReactionKind]
	or a
	jr z, .check

;>     if wReactionKind == 0x20:
	cp $08
	jr z, .no

	cp $20
	jr nz, .no

;>         RestoreInterruptedAction()
;>     return False
	call RestoreInterruptedAction
	jr .no

.check
;>@s if (wBattlerStatus[8 * wSkillUser + 4] & 0x0C) == 0x0C:
;>     return False
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	cp $0c
;=@s
	ret z

;>@e if not wSkillTargeting & 0x10 or not wBattlerStatus[8 * wSkillTarget + 6] & 0x08 or CheckBattlerCanAct(wSkillTarget):
;>@f     return False
	ld a, [wSkillTargeting]
	bit 4, a
	jr z, .no

	ld a, [wSkillTarget]
	ld hl, wBattlerStatus6
	call AddEightTimes
;=@e
	bit 3, [hl]
	jr z, .no

	ld a, [wSkillTarget]
	call CheckBattlerCanAct
	jr c, .no

;> if wSkillFlags3 & 0x04:
	ld a, [wSkillFlags3]
	bit 2, a
	jr z, .cannot

;>     PrintTargetMessage(0xD3)
	ld a, $d3
	call PrintTargetMessage
;>     wReactionKind = 8
;>     wBattleArg0 = 8
	ld a, $08
	ld [wReactionKind], a
	ld a, $08
	ld [wBattleArg0], a
;>     StartReactionFar_53()
	ld hl, far_StartReactionFar_53
	rst $10
;>     wHitShown = 0
;>     return True
	xor a
	ld [wHitShown], a
	scf
	ret


.cannot
;> PrintTargetMessage(0xD4)
	ld a, $d4
	call PrintTargetMessage
;> return False
	xor a
	ret


	; unused: a check of the target's status byte 1 against the skill's flags
	; (wSkillFlags1 bits 4-6)
	db $fa, $89, $db, $21, $03, $db, $cd, $6c, $2f, $fa, $fd, $dc, $cb, $77, $20, $09
	db $cb, $6f, $20, $0f, $cb, $67, $20, $0e, $c9, $cb, $46, $20, $dc, $fa, $00, $db
	db $cb, $5f, $c9, $cb, $76, $c9, $cb, $7e, $c9

;@ def PrintTargetMessage(msg: a)
;@ path: battle/actions
;@ Message `msg` (group 0) with the skill target's name.
PrintTargetMessage::
;> TargetNameToArg0()
	push af
	call TargetNameToArg0
	pop af
;> wTextIndex = msg
;> wTextGroup = 0
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def PrepareRedirect()
;@ path: battle/actions
;@ After an intercepted hit the target is the one the user chose again
;@ (LoadActionTarget); after Cover or Guardian (wInterceptState 1) the covering
;@ monster's Cover state (status 6 bit 4, the low nibble of status 7) ends.
;@ For a dodge only with a wind (wReflectAnim 2).
PrepareRedirect::
;> if not wInterceptState:
;>     return
	ld a, [wInterceptState]
	or a
	ret z

;> if wInterceptState != 1:
	cp $01
	jr z, .covered

;>     if wReflectAnim == 2:
;>         return LoadActionTarget()
	ld a, [wReflectAnim]
	cp $02
	jr z, LoadActionTarget

;>     return
	ret


.covered
;> t = LoadActionTarget()
	call LoadActionTarget
;> wBattlerStatus[8 * t + 6] &= ~0x10
	ld hl, wBattlerStatus6
	call AddEightTimes
	res 4, [hl]
;> wBattlerStatus[8 * t + 7] &= 0x0F
	inc hl
	ld a, [hl]
	and $0f
	ld [hl], a
	ret


;@ def LoadActionTarget() -> a
;@ path: battle/actions
;@ wSkillTarget = the target the user chose (wBattlerAction).
LoadActionTarget::
;> wSkillTarget = wBattlerAction[2 * wSkillUser + 1]
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	call IndexWords
	ld a, [hl]
	ld [wSkillTarget], a
;> return wSkillTarget
	ret


;@ def ActionStepItemFails()
;@ path: battle/items
;@ Action step 21: the item has no effect (message $BB); it is used up all
;@ the same and the action finishes.
ActionStepItemFails::
;> wTextIndex = 0xBB
;> wTextGroup = 0
	ld a, $bb
	ld [wTextIndex], a
	xor a
	ld [wTextGroup], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> wSkillId = 1
	ld a, $01
	ld [wSkillId], a
;> wBattleItemTarget = 0xFF
;> wBattleItemEffect = 0xFF
	ld a, $ff
	ld [wBattleItemTarget], a
	ld a, $ff
	ld [wBattleItemEffect], a
;> ConsumeBattleItem()
	ld hl, far_ConsumeBattleItem
	rst $10
;> FinishAction()
	call FinishAction
	ret


;@ def ActionStep6E0E()
;@ path: battle/actions
;@ Action steps 22 and 24, in bank $57.
ActionStep6E0E::
;> Call_57_6E0E()
	ld hl, far_Call_57_6E0E
	rst $10
	ret


;@ def ActionStep5C48()
;@ path: battle/actions
;@ Action steps 23 and 25: a target is picked for the skill (bank $58).
ActionStep5C48::
;> PickTargetForSkill()
	ld hl, far_PickTargetForSkill
	rst $10
	ret


;@ def ActionStepFall()
;@ path: battle/actions
;@ Action step 26: a monster at 0 HP falls (BattlerFallSequence).
ActionStepFall::
;> BattlerFallSequence()
	ld hl, far_BattlerFallSequence
	rst $10
	ret


;@ def ActionStepWaitClose()
;@ path: battle/actions
;@ Action step 27: once the text is out, the action is closed.
ActionStepWaitClose::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> CloseAction()
	call CloseAction
	ret


;@ def RestoreInterruptedAction() -> carry
;@ path: battle/actions
;@ Far entry 7: when a reaction (wReactionKind) interrupted an action, puts
;@ the interrupted one back from its copy in wPartyBarTiles: user, target,
;@ wHitCount, both their wBattlerAction entries and the target's
;@ wBattlerOrder. Kind 1 then shows message $D9, kind 4 the MagicBack message
;@ (InterruptEndMessage); kind 2 (SuckAll) makes the target the whole side when
;@ the SuckAll user cannot go on; kind $40 and no reaction: carry (nothing
;@ taken up), else no carry and wReactionKind cleared.
;@ test: skip calls routines in other banks
RestoreInterruptedAction::
;> if not wReactionKind:
;>     return ReturnCarry52()
	ld a, [wReactionKind]
	or a
	jp z, ReturnCarry52

;> saved = wPartyBarTiles
;> wSkillUser = saved[0]
	ld hl, wPartyBarTiles
	ld a, [hli]
	ld [wSkillUser], a
;> wSkillTarget = saved[1]
;> wHitCount = saved[2]
	ld a, [hli]
	ld [wSkillTarget], a
	ld a, [hli]
	ld [wHitCount], a
;>@u copy(wBattlerAction + 2 * wSkillUser, saved + 3, 2)
	ld a, [wSkillUser]
	ld de, wBattlerAction
	add a
	add e
	ld e, a
	ld a, $00
;=@u
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
;=@u
	ld [de], a
;>@t copy(wBattlerAction + 2 * wSkillTarget, saved + 5, 2)
	ld a, [wSkillTarget]
	ld de, wBattlerAction
	add a
	add e
	ld e, a
;=@t
	ld a, $00
	adc d
	ld d, a
	ld a, [hli]
	ld [de], a
	inc de
;=@t
	ld a, [hli]
	ld [de], a
;>@o wBattlerOrder[wSkillTarget] = saved[7]
	ld a, [wSkillTarget]
	ld de, wBattlerOrder
	add e
	ld e, a
	ld a, $00
	adc d
;=@o
	ld d, a
	ld a, [hl]
	ld [de], a
;> if wReactionKind == 0x40:
;>     return ReturnCarry52()
	ld a, [wReactionKind]
	cp $40
	jp z, ReturnCarry52

;> if wReactionKind == 1:
;>@1     wTextIndex = 0xD9; wTextGroup = 0; StartText_4C(); wReflectAnim = 0
	cp $01
	jr z, .kind1

;> elif wReactionKind == 2:
;>@2a     su = (wSkillTarget & 4) | (wSuckAllUsers[wSkillTarget >> 2 & 1] >> 2 & 3)   # the SuckAll user
;>@2b     wBattleArg0 = su
;>@2c     if CheckBattlerCanAct(su) or wBattlerStatus[8 * su] & 0xC0:
;>@2d         wSkillTarget |= 3
;>@2e         wBattlerAction[2 * wSkillUser + 1] |= 3
;>@2f         return True
	cp $02
	jr z, .kind2

;> elif wReactionKind == 4:
;>     InterruptEndMessage()
	cp $04
	call z, InterruptEndMessage

.done
;> wReactionKind = 0
;> return False
	ld a, $00
	ld [wReactionKind], a
	xor a
	ret


.kind2
;=@2a
	ld a, [wSkillTarget]
	rrca
	rrca
	and $01
	ld hl, wSuckAllUsers
	add l
;=@2a
	ld l, a
	ld a, [hl]
	rrca
	rrca
	and $03
	ld l, a
;=@2a
	ld a, [wSkillTarget]
	and $04
	or l
;=@2b
	ld [wBattleArg0], a
;=@2c
	call CheckBattlerCanAct
	jr c, .wholeSide

;=@2c
	ld a, [wBattleArg0]
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr z, .done

.wholeSide
;=@2d
	ld a, [wSkillTarget]
	or $03
	ld [wSkillTarget], a
;=@2e
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@2e
	adc h
	ld h, a
	ld a, [hl]
	or $03
	ld [hl], a
;=@2f
	jr ReturnCarry52

.kind1
;=@1
	ld a, $d9
	ld [wTextIndex], a
	ld a, $00
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
;=@1
	xor a
	ld [wReflectAnim], a
	jr .done

;@ def InterruptEndMessage()
;@ path: battle/actions
;@ After MagicBack (wReflectAnim 7): message $DE, and wReflectAnim cleared.
InterruptEndMessage::
;> if wReflectAnim != 7:
;>     return
	ld a, [wReflectAnim]
	cp $07
	ret nz

;> wTextIndex = 0xDE
	ld a, $de
	ld [wTextIndex], a
;> wTextGroup = 0
;> wReflectAnim = 0
	xor a
	ld [wTextGroup], a
	ld [wReflectAnim], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
	ret


;@ def ReturnCarry52() -> carry
;@ path: battle/actions
;@ Returns with carry set.
ReturnCarry52::
;> return True
	scf
	ret


;@ def GetViewSidePos() -> a
;@ path: battle/actions
;@ The position that tells which side a message is about: the skill target,
;@ on the link master the user.
GetViewSidePos::
;> if not wLinkFlags & 0x02:
;>     return wSkillTarget
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

;> return wSkillUser
	ld a, [wSkillUser]
	ret


;@ def CheckFarSideEmpty() -> carry
;@ path: battle/actions
;@ Carry when none of the three places of the side opposite the user has a
;@ monster in the fight.
CheckFarSideEmpty::
;> for c in range((wSkillUser & 4) ^ 4, ((wSkillUser & 4) ^ 4) + 3):
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

.loop
;>     if not CheckBattlerPresent(c):
;>         return False
	ld a, c
	call CheckBattlerPresent
	ret nc

	inc c
	dec b
	jr nz, .loop

;> return True
	scf
	ret


	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00                        ; unused space at the end of the bank
