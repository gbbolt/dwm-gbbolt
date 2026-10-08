INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $054", ROMX[$4000], BANK[$54]

BankNumber_54::
	db $54

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

Skill_Blaze::
	db $00, $13, $11, $14, $02, $01, $04, $41, $07, $17, $02, $0c, $00, $03, $00, $07
	db $00, $05, $00

Skill_Blazemore::
	db $00, $13, $11, $14, $04, $01, $04, $41, $07, $17, $02, $46, $00, $14, $00, $1e
	db $00, $0c, $00

Skill_Blazemost::
	db $00, $13, $11, $14, $0a, $01, $04, $41, $07, $17, $02, $b4, $00, $14, $00, $64
	db $00, $14, $00

Skill_Firebal::
	db $01, $13, $12, $0a, $04, $02, $04, $41, $07, $17, $02, $10, $00, $08, $00, $0a
	db $00, $08, $00

Skill_Firebane::
	db $01, $13, $12, $0c, $06, $02, $04, $41, $07, $17, $02, $1e, $00, $0c, $00, $16
	db $00, $0c, $00

Skill_Firebolt::
	db $01, $13, $12, $0e, $0a, $02, $04, $41, $07, $17, $02, $58, $00, $18, $00, $3c
	db $00, $14, $00

Skill_Bang::
	db $02, $13, $12, $0b, $05, $03, $04, $41, $07, $17, $02, $14, $00, $0a, $00, $0f
	db $00, $05, $00

Skill_Boom::
	db $02, $13, $12, $0d, $08, $03, $04, $41, $07, $17, $02, $34, $00, $10, $00, $23
	db $00, $0a, $00

Skill_Explodet::
	db $02, $13, $12, $10, $0f, $03, $04, $41, $07, $17, $02, $82, $00, $14, $00, $5f
	db $00, $14, $00

Skill_Infernos::
	db $03, $13, $12, $0a, $02, $04, $04, $41, $07, $17, $02, $08, $00, $10, $00, $06
	db $00, $0c, $00

Skill_Infermore::
	db $03, $13, $12, $0c, $04, $04, $04, $41, $07, $17, $02, $19, $00, $1e, $00, $0e
	db $00, $14, $00

Skill_Infermost::
	db $03, $13, $12, $0f, $08, $04, $04, $41, $07, $17, $02, $50, $00, $64, $00, $28
	db $00, $37, $00

Skill_IceBolt::
	db $04, $13, $12, $0b, $03, $06, $04, $41, $07, $17, $02, $19, $00, $0a, $00, $0c
	db $00, $08, $00

Skill_SnowStorm::
	db $04, $13, $12, $0c, $05, $06, $04, $41, $07, $17, $02, $2a, $00, $10, $00, $1e
	db $00, $0a, $00

Skill_Blizzard::
	db $04, $13, $12, $0e, $0c, $06, $04, $41, $07, $17, $02, $50, $00, $18, $00, $3c
	db $00, $0a, $00

Skill_Bolt::
	db $05, $13, $12, $0c, $05, $05, $04, $41, $07, $17, $02, $23, $00, $0f, $00, $14
	db $00, $0a, $00

Skill_Zap::
	db $05, $13, $12, $0d, $0a, $05, $04, $41, $07, $17, $02, $46, $00, $14, $00, $2d
	db $00, $1e, $00

Skill_Thordain::
	db $05, $13, $12, $10, $0f, $05, $04, $41, $07, $17, $02, $af, $00, $32, $00, $78
	db $00, $28, $00

Skill_Beat::
	db $06, $13, $11, $14, $04, $09, $03, $40, $07, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Defeat::
	db $06, $13, $12, $0a, $07, $09, $03, $40, $07, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Sacrifice::
	db $07, $13, $11, $00, $01, $0f, $01, $40, $07, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Sleep::
	db $08, $23, $11, $0a, $03, $08, $00, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SleepAll::
	db $08, $23, $12, $0c, $05, $08, $03, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_StopSpell::
	db $09, $23, $12, $0f, $03, $0b, $00, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Surround::
	db $0a, $23, $12, $0f, $03, $07, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PanicAll::
	db $0b, $22, $12, $0f, $05, $0c, $03, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_RobMagic::
	db $0c, $23, $11, $0a, $00, $0a, $00, $40, $07, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_TakeMagic::
	db $0d, $23, $41, $0c, $02, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Sap::
	db $0e, $23, $11, $0a, $03, $0d, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Defence::
	db $0e, $23, $12, $0c, $04, $0d, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Upper::
	db $0f, $23, $21, $0a, $02, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Increase::
	db $0f, $23, $22, $0f, $03, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Slow::
	db $10, $23, $11, $0a, $03, $0e, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SlowAll::
	db $10, $23, $12, $0f, $04, $0e, $00, $40, $07, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Speed::
	db $11, $23, $21, $0a, $02, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SpeedUp::
	db $11, $23, $22, $0f, $03, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Barrier::
	db $12, $23, $21, $10, $03, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_TwinHits::
	db $13, $23, $21, $10, $06, $00, $00, $40, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MagicWall::
	db $14, $23, $21, $0a, $03, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MagicBack::
	db $15, $23, $41, $0a, $04, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Bounce::
	db $15, $23, $41, $10, $04, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Transform::
	db $16, $23, $11, $0a, $05, $00, $00, $40, $00, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Ironize::
	db $17, $33, $21, $00, $02, $00, $00, $48, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Heal::
	db $18, $33, $21, $14, $02, $00, $00, $40, $04, $12, $03, $1e, $00, $0a, $00, $1e
	db $00, $0a, $00

Skill_HealMore::
	db $18, $33, $21, $14, $05, $00, $00, $40, $04, $12, $03, $4b, $00, $0f, $00, $4b
	db $00, $0f, $00

Skill_HealAll::
	db $18, $33, $21, $14, $07, $00, $00, $40, $04, $12, $03, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_HealUs::
	db $19, $33, $22, $0a, $12, $00, $00, $40, $04, $12, $03, $5a, $00, $1e, $00, $46
	db $00, $1e, $00

Skill_HealUsAll::
	db $19, $33, $22, $0a, $24, $00, $00, $40, $04, $02, $03, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_Vivify::
	db $1a, $33, $21, $0f, $0a, $00, $00, $40, $04, $12, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Revive::
	db $1a, $33, $21, $14, $14, $00, $00, $40, $04, $12, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Farewell::
	db $1b, $33, $21, $00, $01, $00, $00, $40, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Antidote::
	db $1c, $33, $21, $14, $02, $00, $00, $40, $04, $12, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_NumbOff::
	db $1d, $33, $22, $14, $02, $00, $00, $40, $04, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_DeChaos::
	db $1e, $33, $22, $14, $02, $00, $00, $40, $04, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_CurseOff::
	db $1f, $33, $22, $14, $02, $00, $00, $40, $04, $02, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_StepGuard::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MapMagic::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Chance::
	db $22, $23, $00, $14, $14, $00, $00, $40, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Attack::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_TwinSlash::
	db $24, $13, $11, $0a, $02, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Ramming::
	db $25, $13, $11, $00, $01, $0f, $04, $83, $8e, $3b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Beserker::
	db $26, $13, $11, $0a, $01, $00, $04, $83, $8e, $3b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Kamikaze::
	db $27, $13, $11, $00, $01, $0f, $04, $82, $8e, $2b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Massacre::
	db $28, $13, $11, $0a, $03, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_EvilSlash::
	db $29, $13, $11, $0a, $03, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ChargeUP::
	db $2a, $23, $41, $0f, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_HighJump::
	db $2b, $13, $11, $0a, $05, $00, $00, $83, $8e, $03, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SuckAir::
	db $2c, $23, $41, $14, $00, $00, $00, $10, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_FireSlash::
	db $2d, $13, $11, $0a, $03, $01, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BoltSlash::
	db $2e, $13, $11, $0a, $03, $05, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_VacuSlash::
	db $2f, $13, $11, $0a, $03, $04, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_IceSlash::
	db $30, $13, $11, $0a, $03, $06, $06, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MetalCut::
	db $31, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_DrakSlash::
	db $32, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BeastCut::
	db $33, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BirdBlow::
	db $34, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_DevilCut::
	db $35, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ZombieCut::
	db $36, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_CleanCut::
	db $37, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MultiCut::
	db $38, $13, $12, $10, $14, $04, $05, $01, $06, $17, $02, $b4, $00, $1e, $00, $5a
	db $00, $32, $00

Skill_BiAttack::
	db $39, $13, $11, $0c, $03, $00, $00, $83, $fe, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_QuadHits::
	db $39, $13, $11, $0e, $06, $00, $00, $83, $fe, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_CallHelp::
	db $3a, $13, $11, $0c, $04, $19, $04, $01, $0e, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_YellHelp::
	db $3a, $13, $11, $0e, $08, $19, $04, $01, $0e, $3a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Focus::
	db $3b, $23, $41, $14, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SquallHit::
	db $3c, $13, $11, $0c, $02, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PsycheUp::
	db $3d, $13, $11, $14, $03, $00, $00, $83, $8e, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_RainSlash::
	db $3e, $13, $12, $0a, $05, $00, $04, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_WindBeast::
	db $3f, $13, $11, $14, $03, $04, $04, $01, $06, $1f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Vacuum::
	db $3f, $13, $12, $0d, $06, $04, $04, $01, $06, $17, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Lightning::
	db $40, $13, $12, $0c, $03, $05, $04, $01, $06, $17, $02, $28, $00, $14, $00, $19
	db $00, $0f, $00

Skill_RockThrow::
	db $41, $13, $12, $0e, $05, $19, $04, $01, $06, $3f, $02, $5a, $00, $28, $00, $28
	db $00, $1e, $00

Skill_FireAir::
	db $42, $13, $12, $0a, $02, $11, $05, $15, $06, $17, $02, $0e, $00, $08, $00, $0a
	db $00, $06, $00

Skill_BlazeAir::
	db $42, $13, $12, $0c, $04, $11, $05, $15, $06, $17, $02, $20, $00, $10, $00, $14
	db $00, $10, $00

Skill_Scorching::
	db $42, $13, $12, $0e, $08, $11, $05, $15, $06, $17, $02, $4b, $00, $19, $00, $2d
	db $00, $19, $00

Skill_WhiteFire::
	db $42, $13, $12, $10, $10, $11, $05, $15, $06, $17, $02, $96, $00, $14, $00, $55
	db $00, $23, $00

Skill_FrigidAir::
	db $43, $13, $12, $0a, $02, $12, $05, $15, $06, $17, $02, $10, $00, $08, $00, $0e
	db $00, $04, $00

Skill_IceAir::
	db $43, $13, $12, $0c, $04, $12, $05, $15, $06, $17, $02, $2a, $00, $0c, $00, $19
	db $00, $0f, $00

Skill_IceStorm::
	db $43, $13, $12, $0e, $08, $12, $05, $15, $06, $17, $02, $52, $00, $1e, $00, $32
	db $00, $1e, $00

Skill_WhiteAir::
	db $43, $13, $12, $10, $10, $12, $05, $15, $06, $17, $02, $a0, $00, $14, $00, $5a
	db $00, $28, $00

Skill_Hellblast::
	db $44, $13, $12, $10, $19, $05, $00, $01, $06, $17, $02, $d2, $00, $50, $00, $aa
	db $00, $1e, $00

Skill_BigBang::
	db $45, $13, $12, $10, $1e, $01, $05, $01, $06, $17, $02, $2c, $01, $64, $00, $f0
	db $00, $3c, $00

Skill_MegaMagic::
	db $46, $12, $12, $00, $01, $10, $05, $01, $06, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PoisonHit::
	db $47, $13, $11, $0a, $02, $13, $03, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_NapAttack::
	db $48, $13, $11, $0a, $02, $08, $03, $83, $fe, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Paralyze::
	db $49, $13, $11, $0a, $03, $14, $03, $83, $fe, $3b, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SleepAir::
	db $4a, $23, $12, $0c, $03, $08, $03, $10, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PalsyAir::
	db $4b, $23, $12, $10, $04, $14, $03, $10, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PoisonGas::
	db $4c, $23, $12, $0c, $03, $13, $03, $10, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PoisonAir::
	db $4c, $23, $12, $10, $04, $13, $03, $10, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_PaniDance::
	db $4d, $23, $12, $0f, $04, $0c, $04, $20, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Curse::
	db $4e, $23, $12, $10, $03, $15, $04, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Ahhh::
	db $4f, $23, $11, $0a, $01, $16, $00, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_KODance::
	db $50, $13, $12, $0a, $06, $09, $03, $20, $06, $12, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SandStorm::
	db $51, $23, $12, $0c, $02, $07, $02, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Radiant::
	db $52, $23, $12, $0c, $02, $07, $00, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_EerieLite::
	db $53, $23, $12, $0c, $02, $09, $00, $00, $06, $37, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_OddDance::
	db $54, $23, $11, $0a, $00, $0a, $00, $20, $06, $36, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_RobDance::
	db $54, $23, $11, $0f, $00, $0a, $00, $20, $06, $36, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SideStep::
	db $55, $23, $41, $0c, $01, $00, $00, $20, $06, $62, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_LureDance::
	db $56, $23, $12, $0c, $02, $16, $00, $20, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_LushLicks::
	db $57, $23, $11, $0a, $02, $16, $00, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SickLick::
	db $57, $23, $11, $0a, $04, $0d, $00, $00, $06, $73, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_LegSweep::
	db $58, $23, $11, $0a, $01, $16, $00, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BigTrip::
	db $58, $23, $12, $0c, $03, $16, $03, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_WarCry::
	db $59, $23, $12, $0f, $03, $16, $03, $00, $06, $33, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Whistle::
	db $23, $13, $11, $14, $00, $00, $00, $83, $fe, $3e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Imitate::
	db $5b, $21, $41, $0a, $04, $00, $00, $08, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_DeMagic::
	db $5c, $23, $11, $0a, $07, $00, $00, $00, $00, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Surge::
	db $5d, $33, $22, $14, $07, $00, $00, $00, $04, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_UltraDown::
	db $5e, $23, $11, $0a, $07, $09, $02, $00, $04, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ThickFog::
	db $5f, $23, $01, $00, $08, $00, $00, $00, $00, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_TatsuCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_DiagoCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SamsiCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BazooCall::
	db $60, $23, $21, $14, $14, $00, $00, $00, $04, $52, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Cover::
	db $61, $33, $21, $0a, $02, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Guardian::
	db $61, $33, $21, $0a, $04, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_TailWind::
	db $62, $23, $41, $0c, $06, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_StormWind::
	db $62, $23, $21, $10, $0a, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Dodge::
	db $63, $33, $41, $10, $04, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Defence_8D::
	db $64, $33, $41, $00, $00, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_StrongD::
	db $65, $33, $41, $10, $03, $00, $00, $08, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SuckAll::
	db $66, $33, $21, $0a, $02, $00, $00, $18, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BladeD::
	db $67, $33, $41, $0c, $03, $00, $00, $08, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_DanceShut::
	db $68, $23, $12, $0f, $06, $17, $00, $20, $06, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MouthShut::
	db $69, $23, $11, $0f, $06, $18, $00, $00, $06, $57, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Meditate::
	db $6a, $33, $41, $14, $08, $00, $00, $00, $04, $12, $02, $f4, $01, $00, $00, $f4
	db $01, $00, $00

Skill_Hustle::
	db $6b, $33, $22, $14, $0c, $00, $00, $20, $04, $12, $02, $46, $00, $0a, $00, $46
	db $00, $0a, $00

Skill_LifeSong::
	db $6c, $33, $21, $0a, $14, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_LifeDance::
	db $6d, $33, $21, $00, $01, $00, $00, $20, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Run::
	db $6e, $42, $22, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Daze::
	db $6f, $41, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_HitAlly::
	db $ff, $53, $21, $00, $00, $00, $00, $83, $ae, $1a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_HitEnemy::
	db $ff, $53, $11, $00, $00, $00, $00, $83, $be, $1e, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_HitRandom::
	db $ff, $53, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Scared::
	db $ff, $53, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Dance::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Trip::
	db $ff, $53, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Paralyze_9F::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_CantMove::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_RUN_A1::
	db $ff, $51, $41, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_CallHorror::
	db $ff, $62, $02, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_HealUsAll_A3::
	db $ff, $63, $22, $00, $00, $00, $00, $00, $04, $02, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_Smashed::
	db $ff, $62, $12, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_FilthZone::
	db $ff, $63, $02, $00, $00, $00, $00, $00, $00, $40, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_AllChange::
	db $ff, $63, $21, $00, $00, $00, $00, $00, $04, $40, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_BigSleep::
	db $ff, $63, $01, $00, $00, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_MPZero::
	db $ff, $63, $01, $00, $00, $00, $00, $00, $04, $00, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_Echo::
	db $ff, $63, $41, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ChangeDragon::
	db $ff, $63, $41, $00, $00, $00, $00, $00, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_CallEvil::
	db $ff, $63, $12, $00, $00, $00, $00, $83, $8e, $0a, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Freezy::
	db $ff, $63, $12, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_AllRevive::
	db $ff, $63, $22, $00, $00, $00, $00, $00, $04, $02, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_RestoreMP::
	db $ff, $63, $22, $00, $00, $00, $00, $00, $04, $02, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_Meteor::
	db $ff, $63, $01, $00, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemHerb::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $1e, $00, $0a, $00, $1e
	db $00, $0a, $00

Skill_ItemLoveWater::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $3c, $00, $0a, $00, $3c
	db $00, $0a, $00

Skill_ItemSageStone::
	db $ff, $84, $32, $00, $00, $00, $00, $00, $04, $23, $02, $2d, $00, $0a, $00, $2d
	db $00, $0a, $00

Skill_ItemWorldDew::
	db $ff, $84, $32, $00, $00, $00, $00, $00, $04, $23, $02, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_ItemPotion::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $14, $00, $0a, $00, $14
	db $00, $0a, $00

Skill_ItemElfWater::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $e7, $03, $00, $00, $e7
	db $03, $00, $00

Skill_ItemAntidote::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemMoonHerb::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemSkyBell::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemLaurel::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemAwakeSand::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemWorldLeaf::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemLifeAcorn::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemMysticNut::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemAtkSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemDefSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemAglSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemIntSeed::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemBeefJerky::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $05, $00, $00, $00, $0a
	db $00, $00, $00

Skill_ItemPorkChop::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $0a, $00, $00, $00, $1e
	db $00, $00, $00

Skill_ItemRib::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $14, $00, $00, $00, $64
	db $00, $00, $00

Skill_ItemBadMeat::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $05, $00, $00, $00, $05
	db $00, $00, $00

Skill_ItemSirloin::
	db $ff, $84, $31, $00, $00, $00, $00, $00, $04, $23, $03, $64, $00, $00, $00, $90
	db $01, $00, $00

Skill_ItemBoltStaff::
	db $ff, $84, $12, $00, $00, $05, $00, $01, $06, $23, $02, $23, $00, $0f, $00, $00
	db $00, $00, $00

Skill_ItemWindStaff::
	db $ff, $84, $12, $00, $00, $04, $00, $01, $06, $23, $02, $08, $00, $10, $00, $00
	db $00, $00, $00

Skill_ItemMistStaff::
	db $ff, $84, $12, $00, $00, $07, $00, $01, $06, $63, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemLavaStaff::
	db $ff, $84, $12, $00, $00, $02, $00, $01, $06, $23, $02, $1e, $00, $0c, $00, $00
	db $00, $00, $00

Skill_ItemSnowStaff::
	db $ff, $84, $12, $00, $00, $12, $00, $01, $06, $23, $02, $50, $00, $1e, $00, $00
	db $00, $00, $00

Skill_ItemWarpWing::
	db $ff, $84, $22, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemTinyMedal::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemQuestBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemHorrorBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemBeNiceBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemCheaterBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemSmartBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemComedyBk::
	db $ff, $84, $21, $00, $00, $00, $00, $00, $04, $23, $01, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ItemFireStaff::
	db $ff, $84, $11, $00, $00, $01, $00, $01, $06, $23, $02, $8c, $00, $1e, $00, $00
	db $00, $00, $00

Skill_BeDragon::
	db $70, $22, $41, $14, $09, $00, $00, $40, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_SmashLime::
	db $71, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_ShellDodge::
	db $72, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Branching::
	db $73, $13, $11, $0a, $03, $00, $00, $83, $fe, $3f, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_GigaSlash::
	db $74, $13, $11, $10, $14, $1a, $04, $83, $8e, $3f, $02, $5e, $01, $3c, $00, $0e
	db $01, $32, $00

Skill_Life::
	db $75, $21, $11, $0a, $05, $0c, $03, $40, $07, $53, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_RUN_DB::
	db $76, $31, $41, $28, $00, $00, $00, $00, $04, $00, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Ironize_DC::
	db $77, $31, $41, $0a, $02, $00, $00, $48, $04, $42, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

Skill_Ahhh_DD::
	db $78, $13, $11, $0a, $02, $00, $00, $83, $9e, $13, $02, $00, $00, $00, $00, $00
	db $00, $00, $00

GetSkillWord::
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
	ld hl, $4013
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wBattleArg2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, c
	ld [wBattleArg0], a
	ld a, b
	ld [wBattleArg1], a
	ret


GetSkillValue::
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
	ld hl, $4013
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wBattleArg2]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc hl
	ld a, [hl]
	ld [wBattleArg2], a
	ld a, c
	ld [wBattleArg0], a
	ld a, b
	ld [wBattleArg1], a
	ret


LoadSkillFlags::
	ld a, [wSkillId]
	ld c, a
	ld b, $00
	ld hl, $4013
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, $02
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTargeting], a
	ld a, $05
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wSkillFlags1], a
	ld a, [hli]
	ld [wSkillFlags2], a
	ld a, [hl]
	ld [wSkillFlags3], a
	ret


GetSkillBaseAmount::
	ld a, [wSkillId]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, [wSkillUser]
	bit 2, a
	jr z, jr_054_52e0

	ld a, $0f
	ld [wBattleArg2], a
	jr jr_054_52e5

jr_054_52e0:
	ld a, $0b
	ld [wBattleArg2], a

jr_054_52e5:
	call GetSkillValue
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	jr z, jr_054_530a

	ld a, [wBattleArg2]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a

jr_054_530a:
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ret


GetSkillBaseAmountCopy::
	ld a, [wSkillId]
	ld [wBattleArg0], a
	ld a, $00
	ld [wBattleArg1], a
	ld a, [wSkillUser]
	bit 2, a
	jr z, jr_054_532c

	ld a, $0f
	ld [wBattleArg2], a
	jr jr_054_5331

jr_054_532c:
	ld a, $0b
	ld [wBattleArg2], a

jr_054_5331:
	call GetSkillValue
	ld a, [wBattleArg0]
	ld c, a
	ld a, [wBattleArg1]
	ld b, a
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	jr z, jr_054_5356

	ld a, [wBattleArg2]
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a

jr_054_5356:
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ret


GetBattleItemTarget::
	ld a, [wBattleArg0]
	cp $d5
	jr z, jr_054_539d

	jr nc, jr_054_53a6

	ld a, $00
	ld [wBattleArg1], a
	ld a, $0a
	ld [wBattleArg2], a
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	push hl
	call GetSkillWord
	pop hl
	ld a, [wBattleArg0]
	cp $01
	jr z, jr_054_53a6

	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	push hl
	ld a, $02
	ld [wBattleArg2], a
	call GetSkillWord
	pop hl
	ld a, l
	ld [wBattleArg1], a
	ret


jr_054_539d:
	ld [wBattleArg1], a
	ld a, $12
	ld [wBattleArg0], a
	ret


jr_054_53a6:
	ld a, $00
	ld [wBattleArg0], a
	ret


ConsumeBattleItem::
	xor a
	ld [wBattleItemUsedUp], a
	ld a, [wConfirmChoice]
	add a
	add a
	ld b, a
	ld a, [wMenuChoice2]
	and $7f
	add b
	ld a, a
	ld [wBattleArg0], a
	ld hl, wBagItems
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wItemId], a
	ld hl, far_GetItemData
	rst $10
	ld a, [wBattleArg0]
	ld [wItemBagSlot], a
	ld hl, far_MaybeUseUpItem
	rst $10
	ld a, [wItemId]
	cp $ff
	jr nz, jr_054_53f5

	ld a, [wItemUseUpChance]
	cp $64
	jr z, jr_054_53f5

	ld a, $01
	ld [wBattleItemUsedUp], a
	call CopyBattleItemName
	ld hl, far_Call_50_5B58
	rst $10

jr_054_53f5:
	ret


CopyBattleItemName::
	ld a, [wSkillId]
	sub $af
	ld l, a
	ld h, $08
	ld de, wTextArg1
	call CopySystemText
	ret


UseBeastTail::
	ld a, [wBattleSubStep2]
	rst $00

BeastTailSteps::
	dw BeastTail_TakeOut
	dw BeastTail_Point
	dw BeastTail_EnemyA
	dw BeastTail_EnemyB
	dw BeastTail_EnemyC
	dw BeastTail_Done

BeastTail_TakeOut::
	ld a, [wTextState]
	or a
	ret nz

	ld a, $04
	ld [wTextGroup], a
	ld a, $00
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	call SetMessagePauseLong
	ld hl, wBattleSubStep2
	inc [hl]
	ret


BeastTail_Point::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_054_5440

	dec a
	ld [wMonStats], a
	ret


jr_054_5440:
	ld a, $04
	ld [wTextGroup], a
	ld a, $01
	ld [wTextIndex], a
	ld hl, far_StartText_4C
	rst $10
	call SetMessagePause
	ld hl, wBattleSubStep2
	inc [hl]
	ret


BeastTail_EnemyA::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_054_5466

	dec a
	ld [wMonStats], a
	ret


jr_054_5466:
	ld a, $04
	call CheckBattlerPresent
	jr c, jr_054_54a2

	ld de, wTextArg0
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [$db5f], a
	ld a, [$dc40]
	ld l, a
	ld h, $05
	call CopySystemText
	ld a, [$dc40]
	ld [wBattleStepArg0], a
	ld hl, wLibraryFlags
	call TestFlag
	ld a, $02
	jr nz, jr_054_5493

	ld a, $03

jr_054_5493:
	ld [wTextIndex], a
	ld a, $04
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call SetMessagePause

jr_054_54a2:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


BeastTail_EnemyB::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_054_54b7

	dec a
	ld [wMonStats], a
	ret


jr_054_54b7:
	ld a, $05
	call CheckBattlerPresent
	jr c, jr_054_5503

	ld de, wTextArg0
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [$db5f], a
	ld a, [$dc41]
	ld l, a
	ld h, $05
	call CopySystemText
	ld a, [$dc41]
	ld hl, $dc40
	cp [hl]
	jr nz, jr_054_54e2

	ld a, $04
	call CheckBattlerPresent
	jr nc, jr_054_5503

jr_054_54e2:
	ld [wBattleStepArg1], a
	ld a, [$dc41]
	ld hl, wLibraryFlags
	call TestFlag
	ld a, $02
	jr nz, jr_054_54f4

	ld a, $03

jr_054_54f4:
	ld [wTextIndex], a
	ld a, $04
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call SetMessagePause

jr_054_5503:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


BeastTail_EnemyC::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_054_5518

	dec a
	ld [wMonStats], a
	ret


jr_054_5518:
	ld a, $06
	call CheckBattlerPresent
	jr c, jr_054_5572

	ld de, wTextArg0
	ld a, e
	ld [wNameDest], a
	ld a, d
	ld [$db5f], a
	ld a, [$dc42]
	ld l, a
	ld h, $05
	call CopySystemText
	ld a, [$dc42]
	ld hl, $dc40
	cp [hl]
	jr nz, jr_054_5543

	ld a, $04
	call CheckBattlerPresent
	jr nc, jr_054_5572

jr_054_5543:
	ld a, [$dc42]
	inc hl
	cp [hl]
	jr nz, jr_054_5551

	ld a, $05
	call CheckBattlerPresent
	jr nc, jr_054_5572

jr_054_5551:
	ld [wFallStep], a
	ld a, [$dc42]
	ld hl, wLibraryFlags
	call TestFlag
	ld a, $02
	jr nz, jr_054_5563

	ld a, $03

jr_054_5563:
	ld [wTextIndex], a
	ld a, $04
	ld [wTextGroup], a
	ld hl, far_StartText_4C
	rst $10
	call SetMessagePause

jr_054_5572:
	ld hl, wBattleSubStep2
	inc [hl]
	ret


BeastTail_Done::
	ld a, [wTextState]
	or a
	ret nz

	ld a, [wMonStats]
	or a
	jr z, jr_054_5587

	dec a
	ld [wMonStats], a
	ret


jr_054_5587:
	ld a, $0d
	ld [wBattleSubStep], a
	xor a
	ld [wBattleSubStep2], a
	ret


SetMessagePause::
	ld a, [wMessageSpeed]
	cp $07
	jr z, jr_054_55b6

	inc a
	ld b, a
	ld a, $00
	ld c, $0a
	jr jr_054_55b0

SetMessagePauseLong::
	ld a, [wMessageSpeed]
	cp $07
	jr z, jr_054_55b6

	inc a
	ld b, a
	ld a, $20
	dec b
	jr z, jr_054_55b7

	ld c, $0a

jr_054_55b0:
	add c
	dec b
	jr nz, jr_054_55b0

	jr jr_054_55b7

jr_054_55b6:
	xor a

jr_054_55b7:
	ld [wMonStats], a
	ret


CheckEnemyJoins::
	call Random
	ld a, [wJoinCandidate]
	or a
	jr z, jr_054_5609

	and $03
	ld hl, wEnemyTemplate3
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg1], a
	cp $07
	jr z, jr_054_5609

	ld a, [wJoinCandidate]
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld hl, wLibraryFlags
	call TestFlag
	push af
	pop bc
	ld a, c
	ld [wBattleArg0], a
	push bc
	ld a, [wJoinPoints]
	ld l, a
	ld a, [$db84]
	ld h, a
	pop af
	jr nz, jr_054_5601

	call ScaleJoinPointsNew
	jr jr_054_5604

jr_054_5601:
	call ScaleJoinPointsKnown

jr_054_5604:
	call RollEnemyJoins
	jr c, jr_054_560d

jr_054_5609:
	ld hl, wBattleStep
	inc [hl]

jr_054_560d:
	ret


ScaleJoinPointsNew::
	ld a, [wBattleArg1]
	ld d, h
	ld e, l
	cp $01
	jr z, jr_054_562d

	cp $02
	jr z, jr_054_5632

	cp $03
	jr z, jr_054_5635

	cp $04
	jr z, jr_054_5637

	cp $05
	jr z, jr_054_563d

	cp $06
	jr z, jr_054_5644

	jr jr_054_5654

jr_054_562d:
	add hl, hl
	add hl, hl
	add hl, de
	jr jr_054_5654

jr_054_5632:
	add hl, hl
	jr jr_054_5654

jr_054_5635:
	jr jr_054_5654

jr_054_5637:
	srl h
	rr l
	jr jr_054_5654

jr_054_563d:
	ld a, $05
	call Divide16
	jr jr_054_5654

jr_054_5644:
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l

jr_054_5654:
	ret


ScaleJoinPointsKnown::
	ld a, [wBattleArg1]
	or a
	jr z, jr_054_5682

	cp $03
	jr c, jr_054_566c

	cp $06
	jr c, jr_054_5676

	jr nz, jr_054_5682

	ld a, $14
	call Divide16
	jr jr_054_5682

jr_054_566c:
	srl h
	rr l
	srl h
	rr l
	jr jr_054_5682

jr_054_5676:
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l

jr_054_5682:
	ret


RollEnemyJoins::
	ld a, [wBattleArg1]
	or a
	jr z, jr_054_56c5

	cp $07
	jr z, jr_054_56c7

	push hl
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $5b
	call Divide16
	add $0a
	ld c, a
	ld b, $00
	pop hl
	call CompareHLBC
	jr c, jr_054_56c7

	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $64
	call Divide16
	inc a
	ld c, a
	ld b, $00
	ld hl, $005a
	call CompareHLBC
	jr c, jr_054_56c7

jr_054_56c5:
	scf
	ret


jr_054_56c7:
	scf
	ccf
	ret


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
