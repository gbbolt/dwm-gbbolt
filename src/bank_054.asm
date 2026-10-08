INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $054", ROMX[$4000], BANK[$54]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
BankNumber_54::
	db $54

;@ path: monster/skills
;@ Entry points of bank $54 (skill record helpers, battle items, joining); the skill pointers follow.
FarTable_54::
	dw GetSkillWord
	dw GetSkillValue
	dw LoadSkillFlags
	dw GetSkillBaseAmount
	dw GetSkillBaseAmountCopy
	dw GetBattleItemTarget
	dw ConsumeBattleItem
	dw CheckEnemyJoins
	dw UseBeastTail
;@ path: monster/skills
;@ Pointers to the 19-byte skill records, one per skill number ($00-$DD; format at Skill_Blaze). The
;@ table is also entries 9 and up of the bank's far table; the code reads it as SkillPointers + 2 * skill.
SkillPointers::
	dw Skill_Blaze
	dw Skill_Blazemore
	dw Skill_Blazemost
	dw Skill_Firebal
	dw Skill_Firebane
	dw Skill_Firebolt
	dw Skill_Bang
	dw Skill_Boom
	dw Skill_Explodet
	dw Skill_Infernos
	dw Skill_Infermore
	dw Skill_Infermost
	dw Skill_IceBolt
	dw Skill_SnowStorm
	dw Skill_Blizzard
	dw Skill_Bolt
	dw Skill_Zap
	dw Skill_Thordain
	dw Skill_Beat
	dw Skill_Defeat
	dw Skill_Sacrifice
	dw Skill_Sleep
	dw Skill_SleepAll
	dw Skill_StopSpell
	dw Skill_Surround
	dw Skill_PanicAll
	dw Skill_RobMagic
	dw Skill_TakeMagic
	dw Skill_Sap
	dw Skill_Defence
	dw Skill_Upper
	dw Skill_Increase
	dw Skill_Slow
	dw Skill_SlowAll
	dw Skill_Speed
	dw Skill_SpeedUp
	dw Skill_Barrier
	dw Skill_TwinHits
	dw Skill_MagicWall
	dw Skill_MagicBack
	dw Skill_Bounce
	dw Skill_Transform
	dw Skill_Ironize
	dw Skill_Heal
	dw Skill_HealMore
	dw Skill_HealAll
	dw Skill_HealUs
	dw Skill_HealUsAll
	dw Skill_Vivify
	dw Skill_Revive
	dw Skill_Farewell
	dw Skill_Antidote
	dw Skill_NumbOff
	dw Skill_DeChaos
	dw Skill_CurseOff
	dw Skill_StepGuard
	dw Skill_MapMagic
	dw Skill_Chance
	dw Skill_Attack
	dw Skill_TwinSlash
	dw Skill_Ramming
	dw Skill_Beserker
	dw Skill_Kamikaze
	dw Skill_Massacre
	dw Skill_EvilSlash
	dw Skill_ChargeUP
	dw Skill_HighJump
	dw Skill_SuckAir
	dw Skill_FireSlash
	dw Skill_BoltSlash
	dw Skill_VacuSlash
	dw Skill_IceSlash
	dw Skill_MetalCut
	dw Skill_DrakSlash
	dw Skill_BeastCut
	dw Skill_BirdBlow
	dw Skill_DevilCut
	dw Skill_ZombieCut
	dw Skill_CleanCut
	dw Skill_MultiCut
	dw Skill_BiAttack
	dw Skill_QuadHits
	dw Skill_CallHelp
	dw Skill_YellHelp
	dw Skill_Focus
	dw Skill_SquallHit
	dw Skill_PsycheUp
	dw Skill_RainSlash
	dw Skill_WindBeast
	dw Skill_Vacuum
	dw Skill_Lightning
	dw Skill_RockThrow
	dw Skill_FireAir
	dw Skill_BlazeAir
	dw Skill_Scorching
	dw Skill_WhiteFire
	dw Skill_FrigidAir
	dw Skill_IceAir
	dw Skill_IceStorm
	dw Skill_WhiteAir
	dw Skill_Hellblast
	dw Skill_BigBang
	dw Skill_MegaMagic
	dw Skill_PoisonHit
	dw Skill_NapAttack
	dw Skill_Paralyze
	dw Skill_SleepAir
	dw Skill_PalsyAir
	dw Skill_PoisonGas
	dw Skill_PoisonAir
	dw Skill_PaniDance
	dw Skill_Curse
	dw Skill_Ahhh
	dw Skill_KODance
	dw Skill_SandStorm
	dw Skill_Radiant
	dw Skill_EerieLite
	dw Skill_OddDance
	dw Skill_RobDance
	dw Skill_SideStep
	dw Skill_LureDance
	dw Skill_LushLicks
	dw Skill_SickLick
	dw Skill_LegSweep
	dw Skill_BigTrip
	dw Skill_WarCry
	dw Skill_Whistle
	dw Skill_Imitate
	dw Skill_DeMagic
	dw Skill_Surge
	dw Skill_UltraDown
	dw Skill_ThickFog
	dw Skill_TatsuCall
	dw Skill_DiagoCall
	dw Skill_SamsiCall
	dw Skill_BazooCall
	dw Skill_Cover
	dw Skill_Guardian
	dw Skill_TailWind
	dw Skill_StormWind
	dw Skill_Dodge
	dw Skill_Defence_8D
	dw Skill_StrongD
	dw Skill_SuckAll
	dw Skill_BladeD
	dw Skill_DanceShut
	dw Skill_MouthShut
	dw Skill_Meditate
	dw Skill_Hustle
	dw Skill_LifeSong
	dw Skill_LifeDance
	dw Skill_Run
	dw Skill_Daze
	dw Skill_HitAlly
	dw Skill_HitEnemy
	dw Skill_HitRandom
	dw Skill_Scared
	dw Skill_Dance
	dw Skill_Trip
	dw Skill_Paralyze_9F
	dw Skill_CantMove
	dw Skill_RUN_A1
	dw Skill_CallHorror
	dw Skill_HealUsAll_A3
	dw Skill_Smashed
	dw Skill_FilthZone
	dw Skill_AllChange
	dw Skill_BigSleep
	dw Skill_MPZero
	dw Skill_Echo
	dw Skill_ChangeDragon
	dw Skill_CallEvil
	dw Skill_Freezy
	dw Skill_AllRevive
	dw Skill_RestoreMP
	dw Skill_Meteor
	dw Skill_ItemHerb
	dw Skill_ItemLoveWater
	dw Skill_ItemSageStone
	dw Skill_ItemWorldDew
	dw Skill_ItemPotion
	dw Skill_ItemElfWater
	dw Skill_ItemAntidote
	dw Skill_ItemMoonHerb
	dw Skill_ItemSkyBell
	dw Skill_ItemLaurel
	dw Skill_ItemAwakeSand
	dw Skill_ItemWorldLeaf
	dw Skill_ItemLifeAcorn
	dw Skill_ItemMysticNut
	dw Skill_ItemAtkSeed
	dw Skill_ItemDefSeed
	dw Skill_ItemAglSeed
	dw Skill_ItemIntSeed
	dw Skill_ItemBeefJerky
	dw Skill_ItemPorkChop
	dw Skill_ItemRib
	dw Skill_ItemBadMeat
	dw Skill_ItemSirloin
	dw Skill_ItemBoltStaff
	dw Skill_ItemWindStaff
	dw Skill_ItemMistStaff
	dw Skill_ItemLavaStaff
	dw Skill_ItemSnowStaff
	dw Skill_ItemWarpWing
	dw Skill_ItemTinyMedal
	dw Skill_ItemQuestBk
	dw Skill_ItemHorrorBk
	dw Skill_ItemBeNiceBk
	dw Skill_ItemCheaterBk
	dw Skill_ItemSmartBk
	dw Skill_ItemComedyBk
	dw Skill_ItemFireStaff
	dw Skill_BeDragon
	dw Skill_SmashLime
	dw Skill_ShellDodge
	dw Skill_Branching
	dw Skill_GigaSlash
	dw Skill_Life
	dw Skill_RUN_DB
	dw Skill_Ironize_DC
	dw Skill_Ahhh_DD

;@ path: monster/skills
;@ Skill record $00 (Blaze). SkillPointers holds one pointer per skill number to a 19-byte record:
;@   +0  skill family: the skills of one upgrade line share it (Blaze, Blazemore, Blazemost = 0); $FF = no
;@       learnable skill (actions of a confused monster, boss skills, battle items)
;@   +1  kind in the high nibble: 1 attack spell or breath, 2 status / assist, 3 healing / support, 4 Run and
;@       Daze, 5 what a confused or scared monster does, 6 boss skills, 8 battle item; low nibble 1-3
;@   +2  targets (copied to wSkillTargeting): high nibble 1 enemies, 2 own side, 3 either side, 4 the user;
;@       low nibble 1 one monster, 2 the whole side
;@   +3  AI weight: the enemy AI's base score for picking the skill (a random 0-15 is added to it)
;@   +4  MP cost
;@   +5  resistance the target defends with (0 = none; 1 Blaze line, 2 Firebal line, 3 Bang line, ...)
;@   +6  0-6, meaning not worked out
;@   +7, +8, +9  flag bytes, copied to wSkillFlags1-3 for the battle code (+7 also selects how the message reads)
;@   +10 where it can be used: 1 outside battle only, 2 in battle only, 3 both
;@   +11 base amount (u16) when a monster of your side (positions 0-3) uses it, +13 its random spread
;@   +15 base amount (u16) when an enemy (positions 4-7) uses it, +17 its random spread
;@   +18 always 0
;@ An amount of 999 means "all" (HealAll, Vivify...). Numbers $00-$AE are monster skills, $B0-$D4 the battle
;@ effects of items ($AF + item number), $D5-$DD late additions (BeDragon, GigaSlash, ...).
Skill_Blaze::
	db $00, $13, $11, $14, $02, $01, $04, $41, $07, $17, $02, $0c, $00, $03, $00, $07
	db $00, $05, $00

;@ path: monster/skills
;@ Skill record $01: Blazemore.
Skill_Blazemore::
	db $00, $13, $11, $14, $04, $01, $04, $41, $07, $17, $02, $46, $00, $14, $00, $1e
	db $00, $0c, $00

;@ path: monster/skills
;@ Skill record $02: Blazemost.
Skill_Blazemost::
	db $00, $13, $11, $14, $0a, $01, $04, $41, $07, $17, $02, $b4, $00, $14, $00, $64
	db $00, $14, $00

;@ path: monster/skills
;@ Skill record $03: Firebal.
Skill_Firebal::
	db $01, $13, $12, $0a, $04, $02, $04, $41, $07, $17, $02, $10, $00, $08, $00, $0a
	db $00, $08, $00

;@ path: monster/skills
;@ Skill record $04: Firebane.
Skill_Firebane::
	db $01, $13, $12, $0c, $06, $02, $04, $41, $07, $17, $02, $1e, $00, $0c, $00, $16
	db $00, $0c, $00

;@ path: monster/skills
;@ Skill record $05: Firebolt.
Skill_Firebolt::
	db $01, $13, $12, $0e, $0a, $02, $04, $41, $07, $17, $02, $58, $00, $18, $00, $3c
	db $00, $14, $00

;@ path: monster/skills
;@ Skill record $06: Bang.
Skill_Bang::
	db $02, $13, $12, $0b, $05, $03, $04, $41, $07, $17, $02, $14, $00, $0a, $00, $0f
	db $00, $05, $00

;@ path: monster/skills
;@ Skill record $07: Boom.
Skill_Boom::
	db $02, $13, $12, $0d, $08, $03, $04, $41, $07, $17, $02, $34, $00, $10, $00, $23
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $08: Explodet.
Skill_Explodet::
	db $02, $13, $12, $10, $0f, $03, $04, $41, $07, $17, $02, $82, $00, $14, $00, $5f
	db $00, $14, $00

;@ path: monster/skills
;@ Skill record $09: Infernos.
Skill_Infernos::
	db $03, $13, $12, $0a, $02, $04, $04, $41, $07, $17, $02, $08, $00, $10, $00, $06
	db $00, $0c, $00

;@ path: monster/skills
;@ Skill record $0A: Infermore.
Skill_Infermore::
	db $03, $13, $12, $0c, $04, $04, $04, $41, $07, $17, $02, $19, $00, $1e, $00, $0e
	db $00, $14, $00

;@ path: monster/skills
;@ Skill record $0B: Infermost.
Skill_Infermost::
	db $03, $13, $12, $0f, $08, $04, $04, $41, $07, $17, $02, $50, $00, $64, $00, $28
	db $00, $37, $00

;@ path: monster/skills
;@ Skill record $0C: IceBolt.
Skill_IceBolt::
	db $04, $13, $12, $0b, $03, $06, $04, $41, $07, $17, $02, $19, $00, $0a, $00, $0c
	db $00, $08, $00

;@ path: monster/skills
;@ Skill record $0D: SnowStorm.
Skill_SnowStorm::
	db $04, $13, $12, $0c, $05, $06, $04, $41, $07, $17, $02, $2a, $00, $10, $00, $1e
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $0E: Blizzard.
Skill_Blizzard::
	db $04, $13, $12, $0e, $0c, $06, $04, $41, $07, $17, $02, $50, $00, $18, $00, $3c
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $0F: Bolt.
Skill_Bolt::
	db $05, $13, $12, $0c, $05, $05, $04, $41, $07, $17, $02, $23, $00, $0f, $00, $14
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $10: Zap.
Skill_Zap::
	db $05, $13, $12, $0d, $0a, $05, $04, $41, $07, $17, $02, $46, $00, $14, $00, $2d
	db $00, $1e, $00

;@ path: monster/skills
;@ Skill record $11: Thordain.
Skill_Thordain::
	db $05, $13, $12, $10, $0f, $05, $04, $41, $07, $17, $02, $af, $00, $32, $00, $78
	db $00, $28, $00

;@ path: monster/skills
;@ Skill record $12: Beat.
Skill_Beat::
	db $06, $13, $11, $14, $04, $09, $03, $40, $07, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $13: Defeat.
Skill_Defeat::
	db $06, $13, $12, $0a, $07, $09, $03, $40, $07, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $14: Sacrifice.
Skill_Sacrifice::
	db $07, $13, $11, $00, $01, $0f, $01, $40, $07, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $15: Sleep.
Skill_Sleep::
	db $08, $23, $11, $0a, $03, $08, $00, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $16: SleepAll.
Skill_SleepAll::
	db $08, $23, $12, $0c, $05, $08, $03, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $17: StopSpell.
Skill_StopSpell::
	db $09, $23, $12, $0f, $03, $0b, $00, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $18: Surround.
Skill_Surround::
	db $0a, $23, $12, $0f, $03, $07, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $19: PanicAll.
Skill_PanicAll::
	db $0b, $22, $12, $0f, $05, $0c, $03, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $1A: RobMagic.
Skill_RobMagic::
	db $0c, $23, $11, $0a, $00, $0a, $00, $40, $07, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $1B: TakeMagic.
Skill_TakeMagic::
	db $0d, $23, $41, $0c, $02, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $1C: Sap.
Skill_Sap::
	db $0e, $23, $11, $0a, $03, $0d, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $1D: Defence.
Skill_Defence::
	db $0e, $23, $12, $0c, $04, $0d, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $1E: Upper.
Skill_Upper::
	db $0f, $23, $21, $0a, $02, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $1F: Increase.
Skill_Increase::
	db $0f, $23, $22, $0f, $03, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $20: Slow.
Skill_Slow::
	db $10, $23, $11, $0a, $03, $0e, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $21: SlowAll.
Skill_SlowAll::
	db $10, $23, $12, $0f, $04, $0e, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $22: Speed.
Skill_Speed::
	db $11, $23, $21, $0a, $02, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $23: SpeedUp.
Skill_SpeedUp::
	db $11, $23, $22, $0f, $03, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $24: Barrier.
Skill_Barrier::
	db $12, $23, $21, $10, $03, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $25: TwinHits.
Skill_TwinHits::
	db $13, $23, $21, $10, $06, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $26: MagicWall.
Skill_MagicWall::
	db $14, $23, $21, $0a, $03, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $27: MagicBack.
Skill_MagicBack::
	db $15, $23, $41, $0a, $04, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $28: Bounce.
Skill_Bounce::
	db $15, $23, $41, $10, $04, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $29: Transform.
Skill_Transform::
	db $16, $23, $11, $0a, $05, $00, $00, $40, $00, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $2A: Ironize.
Skill_Ironize::
	db $17, $33, $21, $00, $02, $00, $00, $48, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $2B: Heal.
Skill_Heal::
	db $18, $33, $21, $14, $02, $00, $00, $40, $04, $12, $03, $1e, $00, $0a, $00, $1e
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $2C: HealMore.
Skill_HealMore::
	db $18, $33, $21, $14, $05, $00, $00, $40, $04, $12, $03, $4b, $00, $0f, $00, $4b
	db $00, $0f, $00

;@ path: monster/skills
;@ Skill record $2D: HealAll.
Skill_HealAll::
	db $18, $33, $21, $14, $07, $00, $00, $40, $04, $12, $03, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $2E: HealUs.
Skill_HealUs::
	db $19, $33, $22, $0a, $12, $00, $00, $40, $04, $12, $03, $5a, $00, $1e, $00, $46
	db $00, $1e, $00

;@ path: monster/skills
;@ Skill record $2F: HealUsAll.
Skill_HealUsAll::
	db $19, $33, $22, $0a, $24, $00, $00, $40, $04, $02, $03, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $30: Vivify.
Skill_Vivify::
	db $1a, $33, $21, $0f, $0a, $00, $00, $40, $04, $12, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $31: Revive.
Skill_Revive::
	db $1a, $33, $21, $14, $14, $00, $00, $40, $04, $12, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $32: Farewell.
Skill_Farewell::
	db $1b, $33, $21, $00, $01, $00, $00, $40, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $33: Antidote.
Skill_Antidote::
	db $1c, $33, $21, $14, $02, $00, $00, $40, $04, $12, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $34: NumbOff.
Skill_NumbOff::
	db $1d, $33, $22, $14, $02, $00, $00, $40, $04, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $35: DeChaos.
Skill_DeChaos::
	db $1e, $33, $22, $14, $02, $00, $00, $40, $04, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $36: CurseOff.
Skill_CurseOff::
	db $1f, $33, $22, $14, $02, $00, $00, $40, $04, $02, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $37: StepGuard.
Skill_StepGuard::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $38: MapMagic.
Skill_MapMagic::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $39: Chance.
Skill_Chance::
	db $22, $23, $00, $14, $14, $00, $00, $40, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $3A: Attack.
Skill_Attack::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $3B: TwinSlash.
Skill_TwinSlash::
	db $24, $13, $11, $0a, $02, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $3C: Ramming.
Skill_Ramming::
	db $25, $13, $11, $00, $01, $0f, $04, $83, $8e, $3b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $3D: Beserker.
Skill_Beserker::
	db $26, $13, $11, $0a, $01, $00, $04, $83, $8e, $3b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $3E: Kamikaze.
Skill_Kamikaze::
	db $27, $13, $11, $00, $01, $0f, $04, $82, $8e, $2b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $3F: Massacre.
Skill_Massacre::
	db $28, $13, $11, $0a, $03, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $40: EvilSlash.
Skill_EvilSlash::
	db $29, $13, $11, $0a, $03, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $41: ChargeUP.
Skill_ChargeUP::
	db $2a, $23, $41, $0f, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $42: HighJump.
Skill_HighJump::
	db $2b, $13, $11, $0a, $05, $00, $00, $83, $8e, $03, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $43: SuckAir.
Skill_SuckAir::
	db $2c, $23, $41, $14, $00, $00, $00, $10, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $44: FireSlash.
Skill_FireSlash::
	db $2d, $13, $11, $0a, $03, $01, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $45: BoltSlash.
Skill_BoltSlash::
	db $2e, $13, $11, $0a, $03, $05, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $46: VacuSlash.
Skill_VacuSlash::
	db $2f, $13, $11, $0a, $03, $04, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $47: IceSlash.
Skill_IceSlash::
	db $30, $13, $11, $0a, $03, $06, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $48: MetalCut.
Skill_MetalCut::
	db $31, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $49: DrakSlash.
Skill_DrakSlash::
	db $32, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $4A: BeastCut.
Skill_BeastCut::
	db $33, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $4B: BirdBlow.
Skill_BirdBlow::
	db $34, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $4C: DevilCut.
Skill_DevilCut::
	db $35, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $4D: ZombieCut.
Skill_ZombieCut::
	db $36, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $4E: CleanCut.
Skill_CleanCut::
	db $37, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $4F: MultiCut.
Skill_MultiCut::
	db $38, $13, $12, $10, $14, $04, $05, $01, $06, $17, $02, $b4, $00, $1e, $00, $5a
	db $00, $32, $00

;@ path: monster/skills
;@ Skill record $50: BiAttack.
Skill_BiAttack::
	db $39, $13, $11, $0c, $03, $00, $00, $83, $fe, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $51: QuadHits.
Skill_QuadHits::
	db $39, $13, $11, $0e, $06, $00, $00, $83, $fe, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $52: CallHelp.
Skill_CallHelp::
	db $3a, $13, $11, $0c, $04, $19, $04, $01, $0e, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $53: YellHelp.
Skill_YellHelp::
	db $3a, $13, $11, $0e, $08, $19, $04, $01, $0e, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $54: Focus.
Skill_Focus::
	db $3b, $23, $41, $14, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $55: SquallHit.
Skill_SquallHit::
	db $3c, $13, $11, $0c, $02, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $56: PsycheUp.
Skill_PsycheUp::
	db $3d, $13, $11, $14, $03, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $57: RainSlash.
Skill_RainSlash::
	db $3e, $13, $12, $0a, $05, $00, $04, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $58: WindBeast.
Skill_WindBeast::
	db $3f, $13, $11, $14, $03, $04, $04, $01, $06, $1f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $59: Vacuum.
Skill_Vacuum::
	db $3f, $13, $12, $0d, $06, $04, $04, $01, $06, $17, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $5A: Lightning.
Skill_Lightning::
	db $40, $13, $12, $0c, $03, $05, $04, $01, $06, $17, $02, $28, $00, $14, $00, $19
	db $00, $0f, $00

;@ path: monster/skills
;@ Skill record $5B: RockThrow.
Skill_RockThrow::
	db $41, $13, $12, $0e, $05, $19, $04, $01, $06, $3f, $02, $5a, $00, $28, $00, $28
	db $00, $1e, $00

;@ path: monster/skills
;@ Skill record $5C: FireAir.
Skill_FireAir::
	db $42, $13, $12, $0a, $02, $11, $05, $15, $06, $17, $02, $0e, $00, $08, $00, $0a
	db $00, $06, $00

;@ path: monster/skills
;@ Skill record $5D: BlazeAir.
Skill_BlazeAir::
	db $42, $13, $12, $0c, $04, $11, $05, $15, $06, $17, $02, $20, $00, $10, $00, $14
	db $00, $10, $00

;@ path: monster/skills
;@ Skill record $5E: Scorching.
Skill_Scorching::
	db $42, $13, $12, $0e, $08, $11, $05, $15, $06, $17, $02, $4b, $00, $19, $00, $2d
	db $00, $19, $00

;@ path: monster/skills
;@ Skill record $5F: WhiteFire.
Skill_WhiteFire::
	db $42, $13, $12, $10, $10, $11, $05, $15, $06, $17, $02, $96, $00, $14, $00, $55
	db $00, $23, $00

;@ path: monster/skills
;@ Skill record $60: FrigidAir.
Skill_FrigidAir::
	db $43, $13, $12, $0a, $02, $12, $05, $15, $06, $17, $02, $10, $00, $08, $00, $0e
	db $00, $04, $00

;@ path: monster/skills
;@ Skill record $61: IceAir.
Skill_IceAir::
	db $43, $13, $12, $0c, $04, $12, $05, $15, $06, $17, $02, $2a, $00, $0c, $00, $19
	db $00, $0f, $00

;@ path: monster/skills
;@ Skill record $62: IceStorm.
Skill_IceStorm::
	db $43, $13, $12, $0e, $08, $12, $05, $15, $06, $17, $02, $52, $00, $1e, $00, $32
	db $00, $1e, $00

;@ path: monster/skills
;@ Skill record $63: WhiteAir.
Skill_WhiteAir::
	db $43, $13, $12, $10, $10, $12, $05, $15, $06, $17, $02, $a0, $00, $14, $00, $5a
	db $00, $28, $00

;@ path: monster/skills
;@ Skill record $64: Hellblast.
Skill_Hellblast::
	db $44, $13, $12, $10, $19, $05, $00, $01, $06, $17, $02, $d2, $00, $50, $00, $aa
	db $00, $1e, $00

;@ path: monster/skills
;@ Skill record $65: BigBang.
Skill_BigBang::
	db $45, $13, $12, $10, $1e, $01, $05, $01, $06, $17, $02, $2c, $01, $64, $00, $f0
	db $00, $3c, $00

;@ path: monster/skills
;@ Skill record $66: MegaMagic.
Skill_MegaMagic::
	db $46, $12, $12, $00, $01, $10, $05, $01, $06, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $67: PoisonHit.
Skill_PoisonHit::
	db $47, $13, $11, $0a, $02, $13, $03, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $68: NapAttack.
Skill_NapAttack::
	db $48, $13, $11, $0a, $02, $08, $03, $83, $fe, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $69: Paralyze.
Skill_Paralyze::
	db $49, $13, $11, $0a, $03, $14, $03, $83, $fe, $3b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $6A: SleepAir.
Skill_SleepAir::
	db $4a, $23, $12, $0c, $03, $08, $03, $10, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $6B: PalsyAir.
Skill_PalsyAir::
	db $4b, $23, $12, $10, $04, $14, $03, $10, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $6C: PoisonGas.
Skill_PoisonGas::
	db $4c, $23, $12, $0c, $03, $13, $03, $10, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $6D: PoisonAir.
Skill_PoisonAir::
	db $4c, $23, $12, $10, $04, $13, $03, $10, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $6E: PaniDance.
Skill_PaniDance::
	db $4d, $23, $12, $0f, $04, $0c, $04, $20, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $6F: Curse.
Skill_Curse::
	db $4e, $23, $12, $10, $03, $15, $04, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $70: Ahhh.
Skill_Ahhh::
	db $4f, $23, $11, $0a, $01, $16, $00, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $71: KODance.
Skill_KODance::
	db $50, $13, $12, $0a, $06, $09, $03, $20, $06, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $72: SandStorm.
Skill_SandStorm::
	db $51, $23, $12, $0c, $02, $07, $02, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $73: Radiant.
Skill_Radiant::
	db $52, $23, $12, $0c, $02, $07, $00, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $74: EerieLite.
Skill_EerieLite::
	db $53, $23, $12, $0c, $02, $09, $00, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $75: OddDance.
Skill_OddDance::
	db $54, $23, $11, $0a, $00, $0a, $00, $20, $06, $36, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $76: RobDance.
Skill_RobDance::
	db $54, $23, $11, $0f, $00, $0a, $00, $20, $06, $36, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $77: SideStep.
Skill_SideStep::
	db $55, $23, $41, $0c, $01, $00, $00, $20, $06, $62, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $78: LureDance.
Skill_LureDance::
	db $56, $23, $12, $0c, $02, $16, $00, $20, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $79: LushLicks.
Skill_LushLicks::
	db $57, $23, $11, $0a, $02, $16, $00, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $7A: SickLick.
Skill_SickLick::
	db $57, $23, $11, $0a, $04, $0d, $00, $00, $06, $73, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $7B: LegSweep.
Skill_LegSweep::
	db $58, $23, $11, $0a, $01, $16, $00, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $7C: BigTrip.
Skill_BigTrip::
	db $58, $23, $12, $0c, $03, $16, $03, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $7D: WarCry.
Skill_WarCry::
	db $59, $23, $12, $0f, $03, $16, $03, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $7E: Whistle.
Skill_Whistle::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $7F: Imitate.
Skill_Imitate::
	db $5b, $21, $41, $0a, $04, $00, $00, $08, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $80: DeMagic.
Skill_DeMagic::
	db $5c, $23, $11, $0a, $07, $00, $00, $00, $00, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $81: Surge.
Skill_Surge::
	db $5d, $33, $22, $14, $07, $00, $00, $00, $04, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $82: UltraDown.
Skill_UltraDown::
	db $5e, $23, $11, $0a, $07, $09, $02, $00, $04, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $83: ThickFog.
Skill_ThickFog::
	db $5f, $23, $01, $00, $08, $00, $00, $00, $00, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $84: TatsuCall.
Skill_TatsuCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $85: DiagoCall.
Skill_DiagoCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $86: SamsiCall.
Skill_SamsiCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $87: BazooCall.
Skill_BazooCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $88: Cover.
Skill_Cover::
	db $61, $33, $21, $0a, $02, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $89: Guardian.
Skill_Guardian::
	db $61, $33, $21, $0a, $04, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $8A: TailWind.
Skill_TailWind::
	db $62, $23, $41, $0c, $06, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $8B: StormWind.
Skill_StormWind::
	db $62, $23, $21, $10, $0a, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $8C: Dodge.
Skill_Dodge::
	db $63, $33, $41, $10, $04, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $8D: Defence.
Skill_Defence_8D::
	db $64, $33, $41, $00, $00, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $8E: StrongD.
Skill_StrongD::
	db $65, $33, $41, $10, $03, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $8F: SuckAll.
Skill_SuckAll::
	db $66, $33, $21, $0a, $02, $00, $00, $18, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $90: BladeD.
Skill_BladeD::
	db $67, $33, $41, $0c, $03, $00, $00, $08, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $91: DanceShut.
Skill_DanceShut::
	db $68, $23, $12, $0f, $06, $17, $00, $20, $06, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $92: MouthShut.
Skill_MouthShut::
	db $69, $23, $11, $0f, $06, $18, $00, $00, $06, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $93: Meditate.
Skill_Meditate::
	db $6a, $33, $41, $14, $08, $00, $00, $00, $04, $12, $02, $f4, $01, $00, $00, $f4
	db $01, $00, $00

;@ path: monster/skills
;@ Skill record $94: Hustle.
Skill_Hustle::
	db $6b, $33, $22, $14, $0c, $00, $00, $20, $04, $12, $02, $46, $00, $0a, $00, $46
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $95: LifeSong.
Skill_LifeSong::
	db $6c, $33, $21, $0a, $14, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $96: LifeDance.
Skill_LifeDance::
	db $6d, $33, $21, $00, $01, $00, $00, $20, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $97: Run.
Skill_Run::
	db $6e, $42, $22, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $98: Daze.
Skill_Daze::
	db $6f, $41, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $99: HitAlly.
Skill_HitAlly::
	db $ff, $53, $21, $00, $00, $00, $00, $83, $ae, $1a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $9A: HitEnemy.
Skill_HitEnemy::
	db $ff, $53, $11, $00, $00, $00, $00, $83, $be, $1e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $9B: HitRandom.
Skill_HitRandom::
	db $ff, $53, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $9C: Scared.
Skill_Scared::
	db $ff, $53, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $9D: Dance.
Skill_Dance::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $9E: Trip.
Skill_Trip::
	db $ff, $53, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $9F: Paralyze.
Skill_Paralyze_9F::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A0: CANTMOVE.
Skill_CantMove::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A1: RUN.
Skill_RUN_A1::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A2: CALLHOROR.
Skill_CallHorror::
	db $ff, $62, $02, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A3: HealUsAll.
Skill_HealUsAll_A3::
	db $ff, $63, $22, $00, $00, $00, $00, $00, $04, $02, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $A4: Smashed.
Skill_Smashed::
	db $ff, $62, $12, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A5: FILTHZONE.
Skill_FilthZone::
	db $ff, $63, $02, $00, $00, $00, $00, $00, $00, $40, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A6: ALLCHANGE.
Skill_AllChange::
	db $ff, $63, $21, $00, $00, $00, $00, $00, $04, $40, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A7: BIGSLEEP.
Skill_BigSleep::
	db $ff, $63, $01, $00, $00, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $A8: MP.
Skill_MPZero::
	db $ff, $63, $01, $00, $00, $00, $00, $00, $04, $00, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $A9: ECHO.
Skill_Echo::
	db $ff, $63, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $AA: CHGDRAGON.
Skill_ChangeDragon::
	db $ff, $63, $41, $00, $00, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $AB: CALLEVIL.
Skill_CallEvil::
	db $ff, $63, $12, $00, $00, $00, $00, $83, $8e, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $AC: FREEZY.
Skill_Freezy::
	db $ff, $63, $12, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $AD: ALLREVIVE.
Skill_AllRevive::
	db $ff, $63, $22, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $AE: RESTOREMP.
Skill_RestoreMP::
	db $ff, $63, $22, $00, $00, $00, $00, $00, $04, $02, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $AF: METEOR.
Skill_Meteor::
	db $ff, $63, $01, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $B0: what using the item Herb in battle does.
Skill_ItemHerb::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $1e, $00, $0a, $00, $1e
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $B1: what using the item LoveWater in battle does.
Skill_ItemLoveWater::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $3c, $00, $0a, $00, $3c
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $B2: what using the item SageStone in battle does.
Skill_ItemSageStone::
	db $ff, $84, $32, $00, $00, $00, $00, $00, $04, $23, $02, $2d, $00, $0a, $00, $2d
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $B3: what using the item WorldDew in battle does.
Skill_ItemWorldDew::
	db $ff, $84, $32, $00, $00, $00, $00, $00, $04, $23, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $B4: what using the item Potion in battle does.
Skill_ItemPotion::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $14, $00, $0a, $00, $14
	db $00, $0a, $00

;@ path: monster/skills
;@ Skill record $B5: what using the item ElfWater in battle does.
Skill_ItemElfWater::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $e7, $03, $00, $00, $e7
	db $03, $00, $00

;@ path: monster/skills
;@ Skill record $B6: what using the item Antidote in battle does.
Skill_ItemAntidote::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $B7: what using the item MoonHerb in battle does.
Skill_ItemMoonHerb::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $B8: what using the item SkyBell in battle does.
Skill_ItemSkyBell::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $B9: what using the item Laurel in battle does.
Skill_ItemLaurel::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $BA: what using the item AwakeSand in battle does.
Skill_ItemAwakeSand::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $BB: what using the item WorldLeaf in battle does.
Skill_ItemWorldLeaf::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $BC: what using the item LifeAcorn in battle does.
Skill_ItemLifeAcorn::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $BD: what using the item MysticNut in battle does.
Skill_ItemMysticNut::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $BE: what using the item AtkSeed in battle does.
Skill_ItemAtkSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $BF: what using the item DefSeed in battle does.
Skill_ItemDefSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C0: what using the item AglSeed in battle does.
Skill_ItemAglSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C1: what using the item IntSeed in battle does.
Skill_ItemIntSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C2: what using the item BeefJerky in battle does.
Skill_ItemBeefJerky::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $05, $00, $00, $00, $0a
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C3: what using the item PorkChop in battle does.
Skill_ItemPorkChop::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $0a, $00, $00, $00, $1e
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C4: what using the item Rib in battle does.
Skill_ItemRib::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $14, $00, $00, $00, $64
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C5: what using the item BadMeat in battle does.
Skill_ItemBadMeat::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $05, $00, $00, $00, $05
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C6: what using the item Sirloin in battle does.
Skill_ItemSirloin::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $64, $00, $00, $00, $90
	db $01, $00, $00

;@ path: monster/skills
;@ Skill record $C7: what using the item BoltStaff in battle does.
Skill_ItemBoltStaff::
	db $ff, $84, $12, $00, $00, $05, $00, $01, $06, $23, $02, $23, $00, $0f, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C8: what using the item WindStaff in battle does.
Skill_ItemWindStaff::
	db $ff, $84, $12, $00, $00, $04, $00, $01, $06, $23, $02, $08, $00, $10, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $C9: what using the item MistStaff in battle does.
Skill_ItemMistStaff::
	db $ff, $84, $12, $00, $00, $07, $00, $01, $06, $63, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $CA: what using the item LavaStaff in battle does.
Skill_ItemLavaStaff::
	db $ff, $84, $12, $00, $00, $02, $00, $01, $06, $23, $02, $1e, $00, $0c, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $CB: what using the item SnowStaff in battle does.
Skill_ItemSnowStaff::
	db $ff, $84, $12, $00, $00, $12, $00, $01, $06, $23, $02, $50, $00, $1e, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $CC: what using the item WarpWing in battle does.
Skill_ItemWarpWing::
	db $ff, $84, $22, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $CD: what using the item TinyMedal in battle does.
Skill_ItemTinyMedal::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $CE: what using the item QuestBk in battle does.
Skill_ItemQuestBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $CF: what using the item HorrorBk in battle does.
Skill_ItemHorrorBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D0: what using the item BeNiceBk in battle does.
Skill_ItemBeNiceBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D1: what using the item CheaterBk in battle does.
Skill_ItemCheaterBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D2: what using the item SmartBk in battle does.
Skill_ItemSmartBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D3: what using the item ComedyBk in battle does.
Skill_ItemComedyBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D4: what using the item FireStaff in battle does.
Skill_ItemFireStaff::
	db $ff, $84, $11, $00, $00, $01, $00, $01, $06, $23, $02, $8c, $00, $1e, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D5: BeDragon.
Skill_BeDragon::
	db $70, $22, $41, $14, $09, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D6: Smashlime.
Skill_SmashLime::
	db $71, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D7: Sheldodge.
Skill_ShellDodge::
	db $72, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D8: Branching.
Skill_Branching::
	db $73, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $D9: GigaSlash.
Skill_GigaSlash::
	db $74, $13, $11, $10, $14, $1a, $04, $83, $8e, $3f, $02, $5e, $01, $3c, $00, $0e
	db $01, $32, $00

;@ path: monster/skills
;@ Skill record $DA: LIFE.
Skill_Life::
	db $75, $21, $11, $0a, $05, $0c, $03, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $DB: RUN.
Skill_RUN_DB::
	db $76, $31, $41, $28, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $DC: IRONIZE.
Skill_Ironize_DC::
	db $77, $31, $41, $0a, $02, $00, $00, $48, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ path: monster/skills
;@ Skill record $DD: Ahhh.
Skill_Ahhh_DD::
	db $78, $13, $11, $0a, $02, $00, $00, $83, $9e, $13, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

;@ def GetSkillWord()
;@ path: monster/skills
;@ Reads the 16-bit word at byte wBattleArg2 of the record of skill wBattleArg0 (wBattleArg1 = high
;@ byte of the skill number, always 0) and returns it in wBattleArg0 (low byte) and wBattleArg1 (high).
;@ Callers mostly want the first of the two bytes. The record format is described at Skill_Blaze.
;@ test: wBattleArg0 = rand(0, 0xDD); wBattleArg1 = 0; wBattleArg2 = rand(0, 17)
GetSkillWord::
;> skill = wBattleArg0 | wBattleArg1 << 8
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
;> rec = mem16[SkillPointers + 2 * skill]
	ld hl, SkillPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> p = rec + wBattleArg2
	ld a, [wBattleArg2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> value = mem16[p]
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> wBattleArg0 = value & 0xFF
	ld a, c
	ld [wBattleArg0], a
;> wBattleArg1 = value >> 8
	ld a, b
	ld [wBattleArg1], a
	ret


;@ def GetSkillValue()
;@ path: monster/skills
;@ Like GetSkillWord, and also returns the byte after the word in wBattleArg2: used for the base
;@ amount (u16) and random spread (u8) at record +11 / +15.
;@ test: wBattleArg0 = rand(0, 0xDD); wBattleArg1 = 0; wBattleArg2 = rand(0, 16)
GetSkillValue::
;> skill = wBattleArg0 | wBattleArg1 << 8
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
;> rec = mem16[SkillPointers + 2 * skill]
	ld hl, SkillPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> p = rec + wBattleArg2
	ld a, [wBattleArg2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> value = mem16[p]
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> wBattleArg2 = mem[p + 2]
	inc hl
	ld a, [hl]
	ld [wBattleArg2], a
;> wBattleArg0 = value & 0xFF
	ld a, c
	ld [wBattleArg0], a
;> wBattleArg1 = value >> 8
	ld a, b
	ld [wBattleArg1], a
	ret


;@ def LoadSkillFlags()
;@ path: monster/skills
;@ Copies the targets byte (+2) and the three flag bytes (+7..+9) of skill wSkillId's record to
;@ wSkillTargeting and wSkillFlags1-3, where the battle code tests them.
;@ test: wSkillId = rand(0, 0xDD)
LoadSkillFlags::
;> skill = wSkillId
	ld a, [wSkillId]
	ld c, a
	ld b, $00
;> rec = mem16[SkillPointers + 2 * skill]
	ld hl, SkillPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
;> p = rec + 2
	ld a, $02
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wSkillTargeting = mem[p]
	ld a, [hl]
	ld [wSkillTargeting], a
;> p += 5
	ld a, $05
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wSkillFlags1 = mem[p]
	ld a, [hli]
	ld [wSkillFlags1], a
;> wSkillFlags2 = mem[p + 1]
	ld a, [hli]
	ld [wSkillFlags2], a
;> wSkillFlags3 = mem[p + 2]
	ld a, [hl]
	ld [wSkillFlags3], a
	ret


;@ def GetSkillBaseAmount()
;@ path: battle/damage
;@ Puts the base amount of skill wSkillId used by battle position wSkillUser into wSkillAmount: the
;@ word at record +11 for a monster of your side, +15 for an enemy, plus the spread byte after it
;@ unless the user's intelligence class is 2.
;@ test: wSkillId = rand(0, 0xDD); wSkillUser = rand(0, 7)
GetSkillBaseAmount::
;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> if wSkillUser & 4:                     # an enemy uses it
	ld a, [wSkillUser]
	bit 2, a
	jr z, .ownSide

;>     wBattleArg2 = 15
	ld a, $0f
	ld [wBattleArg2], a
	jr .read

;> else:
.ownSide
;>     wBattleArg2 = 11
	ld a, $0b
	ld [wBattleArg2], a

.read
;> GetSkillValue()                       # base in wBattleArg0/1, spread in wBattleArg2
	call GetSkillValue
;> amount = wBattleArg0 | wBattleArg1 << 8
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
;>@c cls = wBattlerIntClass[wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	ld a, [hl]
;> if cls != 2:
	cp $02
	jr z, .store

;>     amount += wBattleArg2
	ld a, [wBattleArg2]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a

.store
;> wSkillAmount = amount
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
	ret


;@ def GetSkillBaseAmountCopy()
;@ path: unused
;@ An identical copy of GetSkillBaseAmount, reachable as far entry 4 of bank $54; nothing calls it.
;@ test: wSkillId = rand(0, 0xDD); wSkillUser = rand(0, 7)
GetSkillBaseAmountCopy::
;> wBattleArg0 = wSkillId
	ld a, [wSkillId]
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> if wSkillUser & 4:                     # an enemy uses it
	ld a, [wSkillUser]
	bit 2, a
	jr z, .ownSide

;>     wBattleArg2 = 15
	ld a, $0f
	ld [wBattleArg2], a
	jr .read

;> else:
.ownSide
;>     wBattleArg2 = 11
	ld a, $0b
	ld [wBattleArg2], a

.read
;> GetSkillValue()
	call GetSkillValue
;> amount = wBattleArg0 | wBattleArg1 << 8
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
;>@c cls = wBattlerIntClass[wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	ld a, [hl]
;> if cls != 2:
	cp $02
	jr z, .store

;>     amount += wBattleArg2
	ld a, [wBattleArg2]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a

.store
;> wSkillAmount = amount
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
	ret


;@ def GetBattleItemTarget()
;@ path: item/battle
;@ For the battle effect wBattleArg0 of an item ($AF + item number) returns its targets byte in
;@ wBattleArg0 and the effect in wBattleArg1, or wBattleArg0 = 0 when the item can't be used in
;@ battle (record +10 = 1, or past the table). The BeastTail ($D5) aims at all enemies.
;@ test: wBattleArg0 = rand(0xAF, 0xFF)
GetBattleItemTarget::
;> if wBattleArg0 == 0xD5:                # the BeastTail
	ld a, [wBattleArg0]
	cp $d5
	jr z, .beastTail

;>@b1     wBattleArg1 = 0xD5
;>@b2     wBattleArg0 = 0x12                # all enemies
;>@b3     return
;> if wBattleArg0 > 0xD5:
	jr nc, .none

;>@n1     wBattleArg0 = 0
;>@n2     return
;> wBattleArg1 = 0
	ld a, $00
	ld [wBattleArg1], a
;> wBattleArg2 = 10                      # record +10: where it can be used
	ld a, $0a
	ld [wBattleArg2], a
;> effect = wBattleArg0
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
;> GetSkillWord()
	push hl
	call GetSkillWord
	pop hl
;> if wBattleArg0 == 1:                  # outside battle only
	ld a, [wBattleArg0]
	cp $01
	jr z, .none

;>@o1     wBattleArg0 = 0
;>@o2     return
;> wBattleArg0 = effect
	ld a, l
	ld [wBattleArg0], a
;> wBattleArg1 = 0
	ld a, h
	ld [wBattleArg1], a
;> wBattleArg2 = 2                       # record +2: targets
	push hl
	ld a, $02
	ld [wBattleArg2], a
;> GetSkillWord()
	call GetSkillWord
	pop hl
;> wBattleArg1 = effect
	ld a, l
	ld [wBattleArg1], a
	ret

.beastTail
;=@b1
	ld [wBattleArg1], a
;=@b2
	ld a, $12
	ld [wBattleArg0], a
;=@b3
	ret

.none
;=@n1
;=@o1
	ld a, $00
	ld [wBattleArg0], a
;=@n2
;=@o2
	ret


;@ def ConsumeBattleItem()
;@ path: item/battle
;@ Uses up the item chosen in the battle item list (page wConfirmChoice, line wMenuChoice2): looks the
;@ item up, lets MaybeUseUpItem remove it, and when it is gone and could have stayed (use-up chance
;@ below 100%) sets wBattleItemUsedUp, puts its name in wTextArg1 and calls far 50_5B58.
;@ test: skip calls routines in other banks
ConsumeBattleItem::
;> wBattleItemUsedUp = 0
	xor a
	ld [wBattleItemUsedUp], a
;>@slot slot = wConfirmChoice * 4 + (wMenuChoice2 & 0x7F)
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
;=@slot
	add b
	ld a, a
;> wBattleArg0 = slot
	ld [wBattleArg0], a
;>@item wItemId = wBagItems[slot]
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@item
	ld a, [hl]
	ld [wItemId], a
;> GetItemData()
	ld hl, far_GetItemData
	rst $10
;> wItemBagSlot = slot
	ld a, [wBattleArg0]
	ld [wItemBagSlot], a
;> MaybeUseUpItem()
	ld hl, far_MaybeUseUpItem
	rst $10
;> if wItemId == 0xFF and wItemUseUpChance != 100:
	ld a, [wItemId]
	cp $ff
	jr nz, .done

	ld a, [wItemUseUpChance]
	cp $64
	jr z, .done

;>     wBattleItemUsedUp = 1
	ld a, $01
	ld [wBattleItemUsedUp], a
;>     CopyBattleItemName()
	call CopyBattleItemName
;>     ShowItemBrokeMessage()
	ld hl, far_ShowItemBrokeMessage
	rst $10

.done
	ret


;@ def CopyBattleItemName()
;@ path: item/battle
;@ Copies the name of the item behind battle effect wSkillId (item wSkillId - $AF, system text group
;@ 8) to wTextArg1.
;@ test: skip calls a routine in another bank
CopyBattleItemName::
;> item = wSkillId - 0xAF
	ld a, [wSkillId]
	sub $af
;> CopySystemText(0x0800 + item, wTextArg1)
	ld l, a
	ld h, $08
	ld de, wTextArg1
	call CopySystemText
	ret


;@ def UseBeastTail()
;@ path: item/battle
;@ Battle effect of the BeastTail item, one step per frame (wBattleSubStep2): "<Terry> takes out the
;@ BeastTail", "Points the BeastTail at the enemy", then for each enemy species present (once per
;@ species) "<name> has been your pal before" or "...hasn't been your pal yet", decided by the
;@ library flags. Between the messages wMonStats[0] counts down a pause set by SetMessagePause.
;@ test: skip jump table dispatch
UseBeastTail::
;> BeastTailSteps[wBattleSubStep2]()
	ld a, [wBattleSubStep2]
	rst $00

;@ path: item/battle
;@ Steps of UseBeastTail.
BeastTailSteps::
	dw BeastTail_TakeOut
	dw BeastTail_Point
	dw BeastTail_EnemyA
	dw BeastTail_EnemyB
	dw BeastTail_EnemyC
	dw BeastTail_Done

;@ def BeastTail_TakeOut()
;@ path: item/battle
;@ Step 0: once no text is running, prints "<Terry> takes out the BeastTail".
;@ test: skip calls routines in other banks
BeastTail_TakeOut::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> wTextGroup = 4
	ld a, $04
	ld [wTextGroup], a
;> wTextIndex = 0                         # "<Terry> takes out the BeastTail"
	ld a, $00
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> SetMessagePauseLong()
	call SetMessagePauseLong
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def BeastTail_Point()
;@ path: item/battle
;@ Step 1: after the message and its pause, prints "Points the BeastTail at the enemy".
;@ test: skip calls routines in other banks
BeastTail_Point::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wMonStats[0]:                       # pause after the last message
	ld a, [wMonStats]
	or a
	jr z, .print

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret

.print
;> wTextGroup = 4
	ld a, $04
	ld [wTextGroup], a
;> wTextIndex = 1                         # "Points the BeastTail at the enemy"
	ld a, $01
	ld [wTextIndex], a
;> StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;> SetMessagePause()
	call SetMessagePause
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def BeastTail_EnemyA()
;@ path: item/battle
;@ Step 2: if enemy A (battle position 4) is there, tells whether its species has been your pal.
;@ test: skip calls routines in other banks
BeastTail_EnemyA::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .check

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret

.check
;> if not CheckBattlerPresent(4):
	ld a, $04
	call CheckBattlerPresent
	jr c, .next

;>     wNameDest = wTextArg0
	ld de, wTextArg0
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [wNameDest + 1], a
;>     CopySystemText(0x0500 + wBattlerSpecies[4], wTextArg0)   # the species name
	ld a, [wBattlerSpecies + 4]
	ld l, a
	ld h, $05
	call CopySystemText
;>     wBattleStepArg0 = wBattlerSpecies[4]
	ld a, [wBattlerSpecies + 4]
	ld [wBattleStepArg0], a
;>     known = TestFlag(wBattlerSpecies[4], wLibraryFlags)
	ld hl, wLibraryFlags
	call TestFlag
;>     wTextIndex = 2 if known else 3     # "...has been your pal before" / "...hasn't been your pal yet"
	ld a, $02
	jr nz, .text

	ld a, $03

.text
	ld [wTextIndex], a
;>     wTextGroup = 4
	ld a, $04
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     SetMessagePause()
	call SetMessagePause

.next
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def BeastTail_EnemyB()
;@ path: item/battle
;@ Step 3: the same for enemy B (position 5), unless it is the species of enemy A and A is there.
;@ test: skip calls routines in other banks
BeastTail_EnemyB::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .check

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret

.check
;> if not CheckBattlerPresent(5):
	ld a, $05
	call CheckBattlerPresent
	jr c, .next

;>     wNameDest = wTextArg0
	ld de, wTextArg0
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [wNameDest + 1], a
;>     CopySystemText(0x0500 + wBattlerSpecies[5], wTextArg0)
	ld a, [wBattlerSpecies + 5]
	ld l, a
	ld h, $05
	call CopySystemText
;>     if wBattlerSpecies[5] == wBattlerSpecies[4]:
	ld a, [wBattlerSpecies + 5]
	ld hl, wBattlerSpecies + 4
	cp [hl]
	jr nz, .tell

;>         if not CheckBattlerPresent(4):   # enemy A told it already
;>             wBattleSubStep2 += 1; return
	ld a, $04
	call CheckBattlerPresent
	jr nc, .next

.tell
;>     wBattleStepArg1 = wBattlerSpecies[5]
	ld [wBattleStepArg1], a
;>     known = TestFlag(wBattlerSpecies[5], wLibraryFlags)
	ld a, [wBattlerSpecies + 5]
	ld hl, wLibraryFlags
	call TestFlag
;>     wTextIndex = 2 if known else 3
	ld a, $02
	jr nz, .text

	ld a, $03

.text
	ld [wTextIndex], a
;>     wTextGroup = 4
	ld a, $04
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     SetMessagePause()
	call SetMessagePause

.next
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def BeastTail_EnemyC()
;@ path: item/battle
;@ Step 4: the same for enemy C (position 6), unless its species was already told for A or B.
;@ test: skip calls routines in other banks
BeastTail_EnemyC::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .check

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret

.check
;> if not CheckBattlerPresent(6):
	ld a, $06
	call CheckBattlerPresent
	jr c, .next

;>     wNameDest = wTextArg0
	ld de, wTextArg0
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [wNameDest + 1], a
;>     CopySystemText(0x0500 + wBattlerSpecies[6], wTextArg0)
	ld a, [wBattlerSpecies + 6]
	ld l, a
	ld h, $05
	call CopySystemText
;>     if wBattlerSpecies[6] == wBattlerSpecies[4]:
	ld a, [wBattlerSpecies + 6]
	ld hl, wBattlerSpecies + 4
	cp [hl]
	jr nz, .notA

;>         if not CheckBattlerPresent(4):
;>             wBattleSubStep2 += 1; return
	ld a, $04
	call CheckBattlerPresent
	jr nc, .next

.notA
;>     if wBattlerSpecies[6] == wBattlerSpecies[5]:
	ld a, [wBattlerSpecies + 6]
	inc hl
	cp [hl]
	jr nz, .tell

;>         if not CheckBattlerPresent(5):
;>             wBattleSubStep2 += 1; return
	ld a, $05
	call CheckBattlerPresent
	jr nc, .next

.tell
;>     wFallStep = wBattlerSpecies[6]
	ld [wFallStep], a
;>     known = TestFlag(wBattlerSpecies[6], wLibraryFlags)
	ld a, [wBattlerSpecies + 6]
	ld hl, wLibraryFlags
	call TestFlag
;>     wTextIndex = 2 if known else 3
	ld a, $02
	jr nz, .text

	ld a, $03

.text
	ld [wTextIndex], a
;>     wTextGroup = 4
	ld a, $04
	ld [wTextGroup], a
;>     StartText_4C()
	ld hl, far_StartText_4C
	rst $10
;>     SetMessagePause()
	call SetMessagePause

.next
;> wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def BeastTail_Done()
;@ path: item/battle
;@ Step 5: after the last pause, goes on with battle sub-step $0D.
;@ test: wMonStats[0] = rand(0, 3)
BeastTail_Done::
;> if wTextState:
;>     return
	ld a, [wTextState]
	or a
	ret nz

;> if wMonStats[0]:
	ld a, [wMonStats]
	or a
	jr z, .done

;>     wMonStats[0] -= 1
;>     return
	dec a
	ld [wMonStats], a
	ret

.done
;> wBattleSubStep = 0x0D
	ld a, $0d
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 0
	xor a
	ld [wBattleSubStep2], a
	ret


;@ def SetMessagePause()
;@ path: battle/messages
;@ Sets the pause after a battle message (counted down in wMonStats[0]): 10 frames per step of the
;@ message speed setting, (wMessageSpeed + 1) * 10, or none at the fastest setting 7.
;@ test: wMessageSpeed = rand(0, 7)
SetMessagePause::
;> if wMessageSpeed == 7:                 # fastest: no pause
	ld a, [wMessageSpeed]
	cp $07
	jr z, jr_054_55b6

;>     wMonStats[0] = 0; return           # (at jr_054_55b6)
;> wMonStats[0] = (wMessageSpeed + 1) * 10   # (the loop in SetMessagePauseLong)
	inc a
	ld b, a
	ld a, $00
	ld c, $0a
	jr jr_054_55b0

;@ def SetMessagePauseLong()
;@ path: battle/messages
;@ Like SetMessagePause, but a longer pause: $20 + wMessageSpeed * 10 frames (none at speed 7).
;@ test: wMessageSpeed = rand(0, 7)
SetMessagePauseLong::
;> if wMessageSpeed == 7:
	ld a, [wMessageSpeed]
	cp $07
	jr z, jr_054_55b6

;>@z     pause = 0
;> else:
;>     n = wMessageSpeed + 1
	inc a
	ld b, a
;>     pause = 0x20
	ld a, $20
;>@lp     for _ in range(n - 1): pause += 10
	dec b
	jr z, jr_054_55b7

	ld c, $0a

jr_054_55b0:
;=@lp
	add c
	dec b
	jr nz, jr_054_55b0

	jr jr_054_55b7

jr_054_55b6:
;=@z
	xor a

jr_054_55b7:
;> wMonStats[0] = pause
	ld [wMonStats], a
	ret


;@ def CheckEnemyJoins()
;@ path: battle/recruit
;@ After a won battle: decides whether the enemy defeated last (wJoinCandidate) asks to join. Its
;@ template byte 3 (wEnemyTemplate3) is a join class 0-7 (0 always joins, 7 never); wJoinPoints are
;@ scaled by that class, much more harshly when the species has been your pal before (library flag),
;@ then RollEnemyJoins rolls. If it doesn't join, wBattleStep skips the joining step.
;@ test: skip calls Random
CheckEnemyJoins::
;> Random()
	call Random
;> if wJoinCandidate != 0:
	ld a, [wJoinCandidate]
	or a
	jr z, .noJoin

;>@cls     wBattleArg1 = wEnemyTemplate3[wJoinCandidate & 3]   # join class
	and $03
	ld hl, wEnemyTemplate3
	add l
	ld l, a
	ld a, $00
	adc h
;=@cls
	ld h, a
	ld a, [hl]
	ld [wBattleArg1], a
;>     if wBattleArg1 != 7:
	cp $07
	jr z, .noJoin

;>@sp         known = TestFlag(wBattlerSpecies[wJoinCandidate], wLibraryFlags)
	ld a, [wJoinCandidate]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld a, [hl]
	ld hl, wLibraryFlags
	call TestFlag
;>         wBattleArg0 = 0x20 if known else 0xA0   # the CPU flags of that test (not used)
	push af
	pop bc
	ld a, c
	ld [wBattleArg0], a
;>         points = wJoinPoints
	push bc
	ld a, [wJoinPoints]
	ld l, a
	ld a, [wJoinPoints + 1]
	ld h, a
;>         if not known:
	pop af
	jr nz, .known

;>             points = ScaleJoinPointsNew(points)
	call ScaleJoinPointsNew
	jr .roll

;>         else:
.known
;>             points = ScaleJoinPointsKnown(points)
	call ScaleJoinPointsKnown

.roll
;>         if RollEnemyJoins(points):
;>             return                     # the next battle step has it join
	call RollEnemyJoins
	jr c, .done

.noJoin
;> wBattleStep += 1                       # skip the joining step
	ld hl, wBattleStep
	inc [hl]

.done
	ret


;@ def ScaleJoinPointsNew(points: hl) -> hl
;@ path: battle/recruit
;@ Scales the join points by the join class wBattleArg1 for a species that has never been your pal:
;@ class 1 x5, 2 x2, 3 x1, 4 /2, 5 /5, 6 /16, other classes unchanged.
;@ test: wBattleArg1 = rand(0, 7); points = rand(0, 1600)
ScaleJoinPointsNew::
;> cls = wBattleArg1
	ld a, [wBattleArg1]
;> orig = points
	ld d, h
	ld e, l
;> if cls == 1:
	cp $01
	jr z, .times5

;>@x5     return points * 5 & 0xFFFF
;> if cls == 2:
	cp $02
	jr z, .times2

;>@x2     return points * 2 & 0xFFFF
;> if cls == 3:
	cp $03
	jr z, .same

;>@x1     return points
;> if cls == 4:
	cp $04
	jr z, .half

;>@d2     return points >> 1
;> if cls == 5:
	cp $05
	jr z, .fifth

;>@d5     return points // 5
;> if cls == 6:
	cp $06
	jr z, .sixteenth

;>@d16     return points >> 4
;> return points
	jr .done

.times5
;=@x5
	add hl, hl
	add hl, hl
	add hl, de
	jr .done

.times2
;=@x2
	add hl, hl
	jr .done

.same
;=@x1
	jr .done

.half
;=@d2
	srl h
	rr l
	jr .done

.fifth
;=@d5
	ld a, $05
	call Divide16
	jr .done

.sixteenth
;=@d16
	srl h
	rr l
	srl h
	rr l
;=@d16
	srl h
	rr l
	srl h
	rr l

.done
	ret


;@ def ScaleJoinPointsKnown(points: hl) -> hl
;@ path: battle/recruit
;@ Scales the join points by the join class wBattleArg1 for a species that has been your pal before:
;@ class 1-2 /4, 3-5 /8, 6 /20, class 0 and 7 unchanged.
;@ test: wBattleArg1 = rand(0, 7); points = rand(0, 1600)
ScaleJoinPointsKnown::
;> cls = wBattleArg1
	ld a, [wBattleArg1]
;> if cls == 0:
;>     return points
	or a
	jr z, .done

;> if cls < 3:
	cp $03
	jr c, .quarter

;>@q     return points >> 2
;> if cls < 6:
	cp $06
	jr c, .eighth

;>@e     return points >> 3
;> if cls != 6:
;>     return points
	jr nz, .done

;> return points // 20
	ld a, $14
	call Divide16
	jr .done

.quarter
;=@q
	srl h
	rr l
	srl h
	rr l
	jr .done

.eighth
;=@e
	srl h
	rr l
	srl h
	rr l
;=@e
	srl h
	rr l

.done
	ret


;@ def RollEnemyJoins(points: hl) -> carry
;@ path: battle/recruit
;@ Carry when the enemy joins: always for join class 0, never for class 7; otherwise the scaled
;@ points must reach a random 10-100, and then a 90% roll must succeed.
;@ test: skip calls Random
RollEnemyJoins::
;> cls = wBattleArg1
	ld a, [wBattleArg1]
;> if cls == 0:
	or a
	jr z, .join

;>@j1     return True
;> if cls == 7:
	cp $07
	jr z, .no

;>@n1     return False
;> Random()
	push hl
	call Random
;> seed = wRandomHigh | wRandomLow << 8
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
;> need = seed % 91 + 10
	ld a, $5b
	call Divide16
	add $0a
	ld c, a
	ld b, $00
;> if points < need:
	pop hl
	call CompareHLBC
	jr c, .no

;>@n2     return False
;> Random()
	call Random
;> seed = wRandomHigh | wRandomLow << 8
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
;> roll = seed % 100 + 1
	ld a, $64
	call Divide16
	inc a
	ld c, a
	ld b, $00
;> if roll > 90:                          # it may still refuse
	ld hl, $005a
	call CompareHLBC
	jr c, .no

;>@n3     return False
;> return True

.join
;=@j1
	scf
	ret

.no
;=@n1
;=@n2
;=@n3
	scf
	ccf
	ret


;@ path: unused
;@ Unused space at the end of bank $54 (zeros).
Bank54Padding::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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
