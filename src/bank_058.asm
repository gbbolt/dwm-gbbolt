INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $058", ROMX[$4000], BANK[$58]

BankNumber_58::
	db $58

;@ path: battle/ai/targets
;@ Entry points of bank $58, the battle's target choice and turn order. Entries 0-13 are called
;@ directly; entry 14 + n is the target picker of skill n (n = $00-$E5, the skill numbers of
;@ SysText_SkillNames; the item "skills" $B0-$D4 and the last ones simply aim at the user).
;@ RunTargetPicker (entry 8) jumps through it: it reads the monster's chosen skill from wBattlerAction
;@ and goes to entry 14 + skill with JumpToPointer, inside this bank, so these entries are never
;@ far-called by number. Each picker writes the chosen battle position into the target byte of the
;@ user's action (wBattlerAction[2 * wSkillUser + 1]). Many share a plain picker: AITargetEnemySide
;@ (spells that hit the whole enemy group: the first enemy still standing), AITargetOwnSide (the whole
;@ own group), AITargetSelf, AITargetSelfLoadSkill (items, Chance, Focus, the dragon calls),
;@ AITargetRandomEnemy / AITargetRandomAlly.
FarTable_58::
	dw ChooseTargetsAndOrder       ; entry 0
	dw BlankEnemyPicture           ; entry 1
	dw CountTargetNames            ; entry 2
	dw NameTargetForMessage        ; entry 3
	dw AITargetAnyone              ; entry 4
	dw AITargetRandomEnemy         ; entry 5
	dw GetSkillMessage             ; entry 6
	dw GetItemMessage              ; entry 7
	dw RunTargetPicker             ; entry 8
	dw SetNameFormMessage          ; entry 9
	dw AITargetAttack              ; entry 10
	dw AIAttackWeight              ; entry 11
	dw PickTargetForSkill          ; entry 12
	dw FixActionTarget             ; entry 13
	dw AITargetBlaze               ; skill $00 Blaze
	dw AITargetBlaze               ; skill $01 Blazemore
	dw AITargetBlaze               ; skill $02 Blazemost
	dw AITargetEnemySide           ; skill $03 Firebal
	dw AITargetEnemySide           ; skill $04 Firebane
	dw AITargetEnemySide           ; skill $05 Firebolt
	dw AITargetEnemySide           ; skill $06 Bang
	dw AITargetEnemySide           ; skill $07 Boom
	dw AITargetEnemySide           ; skill $08 Explodet
	dw AITargetEnemySide           ; skill $09 Infernos
	dw AITargetEnemySide           ; skill $0A Infermore
	dw AITargetEnemySide           ; skill $0B Infermost
	dw AITargetEnemySide           ; skill $0C IceBolt
	dw AITargetEnemySide           ; skill $0D SnowStorm
	dw AITargetEnemySide           ; skill $0E Blizzard
	dw AITargetEnemySide           ; skill $0F Bolt
	dw AITargetEnemySide           ; skill $10 Zap
	dw AITargetEnemySide           ; skill $11 Thordain
	dw AITargetBeat                ; skill $12 Beat
	dw AITargetEnemySide           ; skill $13 Defeat
	dw AITargetEnemySide           ; skill $14 Sacrifice
	dw AITargetSleep               ; skill $15 Sleep
	dw AITargetEnemySide           ; skill $16 SleepAll
	dw AITargetEnemySide           ; skill $17 StopSpell
	dw AITargetEnemySide           ; skill $18 Surround
	dw AITargetEnemySide           ; skill $19 PanicAll
	dw AITargetRobMagic            ; skill $1A RobMagic
	dw AITargetSelf                ; skill $1B TakeMagic
	dw AITargetSap                 ; skill $1C Sap
	dw AITargetEnemySide           ; skill $1D Defence
	dw AITargetUpper               ; skill $1E Upper
	dw AITargetOwnSide             ; skill $1F Increase
	dw AITargetSlow                ; skill $20 Slow
	dw AITargetEnemySide           ; skill $21 SlowAll
	dw AITargetSpeed               ; skill $22 Speed
	dw AITargetOwnSide             ; skill $23 SpeedUp
	dw AITargetOwnSide             ; skill $24 Barrier
	dw AITargetTwinHits            ; skill $25 TwinHits
	dw AITargetOwnSide             ; skill $26 MagicWall
	dw AITargetSelf                ; skill $27 MagicBack
	dw AITargetSelf                ; skill $28 Bounce
	dw AITargetTransform           ; skill $29 Transform
	dw AITargetOwnSide             ; skill $2A Ironize
	dw AITargetHeal                ; skill $2B Heal
	dw AITargetHeal                ; skill $2C HealMore
	dw AITargetHeal                ; skill $2D HealAll
	dw AITargetOwnSide             ; skill $2E HealUs
	dw AITargetOwnSide             ; skill $2F HealUsAll
	dw AITargetRevive              ; skill $30 Vivify
	dw AITargetRevive              ; skill $31 Revive
	dw AITargetOwnFirst            ; skill $32 Farewell
	dw AITargetAntidote            ; skill $33 Antidote
	dw AITargetOwnSide             ; skill $34 NumbOff
	dw AITargetOwnSide             ; skill $35 DeChaos
	dw AITargetOwnSide             ; skill $36 CurseOff
	dw AITargetAttack              ; skill $37 StepGuard
	dw AITargetAttack              ; skill $38 MapMagic
	dw AITargetSelfLoadSkill       ; skill $39 Chance
	dw AITargetAttack              ; skill $3A Attack
	dw AITargetAttack              ; skill $3B TwinSlash
	dw AITargetRamming             ; skill $3C Ramming
	dw AITargetAttack              ; skill $3D Beserker
	dw AITargetRamming             ; skill $3E Kamikaze
	dw AITargetAnyone              ; skill $3F Massacre
	dw AITargetAttack              ; skill $40 EvilSlash
	dw AITargetSelf                ; skill $41 ChargeUP
	dw AITargetRandomEnemy         ; skill $42 HighJump
	dw AITargetSelf                ; skill $43 SuckAir
	dw AITargetFireSlash           ; skill $44 FireSlash
	dw AITargetBoltSlash           ; skill $45 BoltSlash
	dw AITargetVacuSlash           ; skill $46 VacuSlash
	dw AITargetIceSlash            ; skill $47 IceSlash
	dw AITargetMetalCut            ; skill $48 MetalCut
	dw AITargetDrakSlash           ; skill $49 DrakSlash
	dw AITargetBeastCut            ; skill $4A BeastCut
	dw AITargetBirdBlow            ; skill $4B BirdBlow
	dw AITargetDevilCut            ; skill $4C DevilCut
	dw AITargetZombieCut           ; skill $4D ZombieCut
	dw AITargetCleanCut            ; skill $4E CleanCut
	dw AITargetEnemySide           ; skill $4F MultiCut
	dw AITargetAttack              ; skill $50 BiAttack
	dw AITargetRandomEnemy         ; skill $51 QuadHits
	dw AITargetRandomEnemy         ; skill $52 CallHelp
	dw AITargetRandomEnemy         ; skill $53 YellHelp
	dw AITargetSelfLoadSkill       ; skill $54 Focus
	dw AITargetAttack              ; skill $55 SquallHit
	dw AITargetAttack              ; skill $56 PsycheUp
	dw AITargetEnemySide           ; skill $57 RainSlash
	dw AITargetWindBeast           ; skill $58 WindBeast
	dw AITargetEnemySide           ; skill $59 Vacuum
	dw AITargetEnemySide           ; skill $5A Lightning
	dw AITargetEnemySide           ; skill $5B RockThrow
	dw AITargetEnemySide           ; skill $5C FireAir
	dw AITargetEnemySide           ; skill $5D BlazeAir
	dw AITargetEnemySide           ; skill $5E Scorching
	dw AITargetEnemySide           ; skill $5F WhiteFire
	dw AITargetEnemySide           ; skill $60 FrigidAir
	dw AITargetEnemySide           ; skill $61 IceAir
	dw AITargetEnemySide           ; skill $62 IceStorm
	dw AITargetEnemySide           ; skill $63 WhiteAir
	dw AITargetEnemySide           ; skill $64 Hellblast
	dw AITargetEnemySide           ; skill $65 BigBang
	dw AITargetEnemySide           ; skill $66 MegaMagic
	dw AITargetPoisonHit           ; skill $67 PoisonHit
	dw AITargetNapAttack           ; skill $68 NapAttack
	dw AITargetParalyze            ; skill $69 Paralyze
	dw AITargetEnemySide           ; skill $6A SleepAir
	dw AITargetEnemySide           ; skill $6B PalsyAir
	dw AITargetEnemySide           ; skill $6C PoisonGas
	dw AITargetEnemySide           ; skill $6D PoisonAir
	dw AITargetEnemySide           ; skill $6E PaniDance
	dw AITargetEnemySide           ; skill $6F Curse
	dw AITargetAhhh                ; skill $70 Ahhh
	dw AITargetEnemySide           ; skill $71 K.O.Dan
	dw AITargetEnemySide           ; skill $72 SandStorm
	dw AITargetEnemySide           ; skill $73 Radiant
	dw AITargetEnemySide           ; skill $74 EerieLite
	dw AITargetOddDance            ; skill $75 OddDance
	dw AITargetOddDance            ; skill $76 RobDance
	dw AITargetSelf                ; skill $77 SideStep
	dw AITargetEnemySide           ; skill $78 LureDance
	dw AITargetAhhh                ; skill $79 LushLicks
	dw AITargetSickLick            ; skill $7A SickLick
	dw AITargetLegSweep            ; skill $7B LegSweep
	dw AITargetEnemySide           ; skill $7C BigTrip
	dw AITargetEnemySide           ; skill $7D WarCry
	dw AITargetAttack              ; skill $7E Whistle
	dw AITargetSelf                ; skill $7F Imitate
	dw AITargetEnemySide           ; skill $80 DeMagic
	dw AITargetOwnSide             ; skill $81 Surge
	dw AITargetUltraDown           ; skill $82 UltraDown
	dw AITargetSweep               ; skill $83 ThickFog
	dw AITargetSelfLoadSkill       ; skill $84 TatsuCall
	dw AITargetSelfLoadSkill       ; skill $85 DiagoCall
	dw AITargetSelfLoadSkill       ; skill $86 SamsiCall
	dw AITargetSelfLoadSkill       ; skill $87 BazooCall
	dw AITargetCover               ; skill $88 Cover
	dw AITargetOwnSide             ; skill $89 Guardian
	dw AITargetSelf                ; skill $8A TailWind
	dw AITargetOwnSide             ; skill $8B StormWind
	dw AITargetSelf                ; skill $8C Dodge
	dw AITargetSelf                ; skill $8D Defence
	dw AITargetSelf                ; skill $8E StrongD
	dw AITargetOwnSide             ; skill $8F SuckAll
	dw AITargetSelf                ; skill $90 BladeD
	dw AITargetEnemySide           ; skill $91 DanceShut
	dw AITargetMouthShut           ; skill $92 MouthShut
	dw AITargetSelf                ; skill $93 Meditate
	dw AITargetOwnSide             ; skill $94 Hustle
	dw AITargetOwnFirst            ; skill $95 LifeSong
	dw AITargetOwnFirst            ; skill $96 LifeDance
	dw AITargetSelf                ; skill $97 Run
	dw AITargetSelf                ; skill $98 Daze
	dw AITargetRandomAlly          ; skill $99 HitAlly
	dw AITargetRandomEnemy         ; skill $9A HitEnemy
	dw AITargetSelf                ; skill $9B HitRandom
	dw AITargetSelf                ; skill $9C Scared
	dw AITargetSelf                ; skill $9D Dance
	dw AITargetRandomEnemy         ; skill $9E Trip
	dw AITargetSelf                ; skill $9F Paralyze
	dw AITargetSelf                ; skill $A0 CANTMOVE
	dw AITargetSelf                ; skill $A1 RUN
	dw AITargetSweep               ; skill $A2 CALLHOROR
	dw AITargetOwnSide             ; skill $A3 HealUsAll
	dw AITargetEnemySide           ; skill $A4 Smashed
	dw AITargetSweep               ; skill $A5 FILTHZONE
	dw AITargetOwnSide             ; skill $A6 ALLCHANGE
	dw AITargetEnemySide           ; skill $A7 BIGSLEEP
	dw AITargetEnemySide           ; skill $A8 MP0
	dw AITargetSelf                ; skill $A9 ECHO
	dw AITargetSelf                ; skill $AA CHGDRAGON
	dw AITargetEnemySide           ; skill $AB CALLEVIL
	dw AITargetEnemySide           ; skill $AC FREEZY
	dw AITargetOwnFirst            ; skill $AD ALLREVIVE
	dw AITargetOwnSide             ; skill $AE RESTOREMP
	dw AITargetEnemySide           ; skill $AF METEOR
	dw AITargetSelfLoadSkill       ; skill $B0 HERB
	dw AITargetSelfLoadSkill       ; skill $B1 HEALWATER
	dw AITargetSelfLoadSkill       ; skill $B2 SAGESTONE
	dw AITargetSelfLoadSkill       ; skill $B3 WARLDDEW
	dw AITargetSelfLoadSkill       ; skill $B4 POTION
	dw AITargetSelfLoadSkill       ; skill $B5 ELFWATER
	dw AITargetSelfLoadSkill       ; skill $B6 ANTIDOTE
	dw AITargetSelfLoadSkill       ; skill $B7 MOONHERB
	dw AITargetSelfLoadSkill       ; skill $B8 SKYBELL
	dw AITargetSelfLoadSkill       ; skill $B9 LAUREL
	dw AITargetSelfLoadSkill       ; skill $BA AWAKESAND
	dw AITargetSelfLoadSkill       ; skill $BB WARLDLEAF
	dw AITargetSelfLoadSkill       ; skill $BC LIFEACORN
	dw AITargetSelfLoadSkill       ; skill $BD MYSTICNUT
	dw AITargetSelfLoadSkill       ; skill $BE PWRSEED
	dw AITargetSelfLoadSkill       ; skill $BF DEFSEED
	dw AITargetSelfLoadSkill       ; skill $C0 AGILSEED
	dw AITargetSelfLoadSkill       ; skill $C1 INTSEED
	dw AITargetSelfLoadSkill       ; skill $C2 FEEDMEAT
	dw AITargetSelfLoadSkill       ; skill $C3 BEFFJERKY
	dw AITargetSelfLoadSkill       ; skill $C4 PORKCHOP
	dw AITargetSelfLoadSkill       ; skill $C5 BADMEAT
	dw AITargetSelfLoadSkill       ; skill $C6 SIRLOIN
	dw AITargetSelfLoadSkill       ; skill $C7 BOLTSTAFF
	dw AITargetSelfLoadSkill       ; skill $C8 STAFF
	dw AITargetSelfLoadSkill       ; skill $C9 BLOKSTAFF
	dw AITargetSelfLoadSkill       ; skill $CA LAVASTAFF
	dw AITargetSelfLoadSkill       ; skill $CB SNOWSTAFF
	dw AITargetSelfLoadSkill       ; skill $CC FIRESTAFF
	dw AITargetSelfLoadSkill       ; skill $CD WARPWING
	dw AITargetSelfLoadSkill       ; skill $CE TINYMEDAL
	dw AITargetSelfLoadSkill       ; skill $CF QuestBk
	dw AITargetSelfLoadSkill       ; skill $D0 HORRORBK
	dw AITargetSelfLoadSkill       ; skill $D1 BENICEBK
	dw AITargetSelfLoadSkill       ; skill $D2 CHEATERBK
	dw AITargetSelfLoadSkill       ; skill $D3 SMARTBK
	dw AITargetSelfLoadSkill       ; skill $D4 COMEDYBK
	dw AITargetSelf                ; skill $D5 BeDragon
	dw AITargetSmashlime           ; skill $D6 Smashlime
	dw AITargetSheldodge           ; skill $D7 Sheldodge
	dw AITargetBranching           ; skill $D8 Branching
	dw AITargetGigaSlash           ; skill $D9 GigaSlash
	dw AITargetLife                ; skill $DA LIFE
	dw AITargetSelf                ; skill $DB RUN
	dw AITargetSelf                ; skill $DC IRONIZE
	dw AITargetAttack              ; skill $DD Ahhh
	dw AITargetSelf                ; skill $DE (no name)
	dw AITargetSelf                ; skill $DF (no name)
	dw AITargetSelf                ; skill $E0 (no name)
	dw AITargetSelf                ; skill $E1 (no name)
	dw AITargetSelf                ; skill $E2 (no name)
	dw AITargetSelf                ; skill $E3 (no name)
	dw AITargetSelf                ; skill $E4 (no name)
	dw AITargetSelf                ; skill $E5 (no name)

;@ def AITargetAttack()
;@ path: battle/ai/targets
;@ Target picker of Attack and the other weapon skills (StepGuard, MapMagic, TwinSlash, Beserker,
;@ EvilSlash, BiAttack, SquallHit, PsycheUp, Whistle, Ahhh $DD). A dim monster (intelligence class 0)
;@ hits a random enemy; an enemy monster in a normal battle uses AITargetWeakAtRandom. Otherwise
;@ the enemies are scored and the lowest score wins: if none can be reached (all high in the sky),
;@ HP + defense of all; if none is exposed (sky, Dodge, a defence stance), HP + defense with a
;@ Beserker's defense halved; else the HP each exposed enemy would keep after the estimated damage
;@ (times 50 for a metal monster) - a smart monster (class 2) only looks at enemies that can still
;@ act. Ties are broken at random.
;@ test: skip far calls into the damage estimate
AITargetAttack::
;> fill(wSkillAmount, 8, 0)                      # the score scratch
	ld hl, wSkillAmount
	ld bc, $0008
	xor a
	call FillMemory
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if not wLinkActive and wSkillUser >= 4:       # an enemy monster
;>     return AITargetWeakAtRandom()
	ld a, [wLinkActive]
	or a
	jp nz, .scoring

	ld a, [wSkillUser]
	cp $04
	jp nc, AITargetWeakAtRandom

.scoring:
;> side = (wSkillUser & 4) ^ 4                   # first position of the enemy side
	ld a, [wSkillUser]
	and $04
	xor $04
;> wSkillTarget = side
	ld [wSkillTarget], a
;>@h if not any(not CheckBattlerPresent(c) and CheckHittable(c) for c in range(side, side + 3)):
	ld b, $03
	ld c, a

.findHittable:
	ld a, c
	call CheckBattlerPresent
	jr c, .nextHittable

;=@h
	call CheckHittable
	jr c, .someHittable

.nextHittable:
;=@h
	inc c
	dec b
	jr nz, .findHittable

;>     AIScoreEnemies()                          # nobody can be reached: HP + defense of all
	call AIScoreEnemies
	jp .store


.someHittable:
;>@x elif not any(not CheckBattlerPresent(c) and CheckTargetExposed(c) for c in range(side, side + 3)):
	ld b, $03
	ld a, [wSkillTarget]
	ld c, a

.findExposed:
	ld a, c
	call CheckBattlerPresent
	jr c, .nextExposed

;=@x
	call CheckTargetExposed
	jr z, .someExposed

.nextExposed:
;=@x
	inc c
	dec b
	jr nz, .findExposed

;>     AIScoreGroundedEnemies()                  # everyone protected
	call AIScoreGroundedEnemies
	jp .store


.someExposed:
;>@cl elif wBattlerIntClass[wSkillUser] == 2:    # a smart monster
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@cl
	ld h, a
	ld a, [hl]
	cp $02
	jr nz, .scoreExposed

;>@s     if not any(CheckTargetExposed(c) and not CheckBattlerCanAct(c) for c in range(side, side + 3)):
	ld b, $03
	ld a, [wSkillTarget]
	ld c, a

.findActive:
	ld a, c
	call CheckTargetExposed
	jr nz, .nextActive

;=@s
	ld a, c
	call CheckBattlerCanAct
	jr nc, .scoreActive

.nextActive:
;=@s
	inc c
	dec b
	jr nz, .findActive

;>         AIScoreGroundedEnemies()
	call AIScoreGroundedEnemies
	jp .store

;>@a1     else:
;>@a2         for c in range(side, side + 3):
;>@a3             if not CheckBattlerCanAct(c) and CheckTargetExposed(c):
;>@a6                 AIEstimateDamage()
;>@a7                 wSkillAmount = max(GetBattlerHP(c) - wSkillAmount, 0)   # HP left after the hit
;>@a4             else:
;>@a5                 wSkillAmount = 0xFFFF
;>@a8             AIMetalPenalty(c)
;>@a9             AISetScore(c, wSkillAmount)
;>@a10         AIPickLowestScore()
;> else:
;>     for c in range(side, side + 3):
.scoreExposed:
	ld b, $03
	ld a, [wSkillTarget]
	ld c, a

.exposedLoop:
;>         if not CheckBattlerPresent(c) and CheckTargetExposed(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .exposedNone

	call CheckTargetExposed
	jr nz, .exposedNone

;>             AIEstimateDamage()
	call AIEstimateDamage
;>@hp             hp = GetBattlerHP(c) - wSkillAmount     # HP left after the hit
	ld a, c
	call GetBattlerHP
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
;=@hp
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;>             if hp < 0:
;>                 hp = 0
	jr nc, .exposedLeft

	ld hl, $0000

.exposedLeft:
;>             wSkillAmount = hp
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr .exposedScore

.exposedNone:
;>         else:
;>             wSkillAmount = 0xFFFF
	ld a, $ff
	ld [wSkillAmount], a
	ld [$db57], a

.exposedScore:
;>         AIMetalPenalty(c)
	pop bc
	call AIMetalPenalty
;>         AISetScore(c, wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call AISetScore
;=@a2
	inc c
	dec b
	jr nz, .exposedLoop

;>     AIPickLowestScore()
	call AIPickLowestScore
	jr .store

.scoreActive:
;=@a2
	ld b, $03
	ld a, [wSkillTarget]
	ld c, a

.activeLoop:
;=@a3
	push bc
	ld a, c
	call CheckBattlerCanAct
	jr c, .activeNone

;=@a3
	call CheckTargetExposed
	jr nz, .activeNone

;=@a6
	call AIEstimateDamage
;=@a7
	ld a, c
	call GetBattlerHP
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
;=@a7
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;=@a7
	jr nc, .activeLeft

	ld hl, $0000

.activeLeft:
;=@a7
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	jr .activeScore

.activeNone:
;=@a4
	ld a, $ff
	ld [wSkillAmount], a
	ld [$db57], a

.activeScore:
;=@a8
	pop bc
	call AIMetalPenalty
;=@a9
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	call AISetScore
;=@a2
	inc c
	dec b
	jr nz, .activeLoop

;=@a10
	call AIPickLowestScore

.store:
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld a, [wSkillTarget]
	ld [hl], a
	ret


;@ def AIScoreEnemies()
;@ path: battle/ai/targets
;@ Scores the three positions from wSkillTarget on by HP + defense (empty ones $FFFF) and picks the
;@ lowest (AIPickLowestScore, which this runs into).
;@ test: wSkillTarget = rng.choice([0, 4])
AIScoreEnemies::
;> mem[wStatPtr] = 0                         # flag: no Beserker halving
	ld a, $00
	ld [wStatPtr], a
;>@f for c in range(wSkillTarget, wSkillTarget + 3):
	ld b, $03
	ld a, [wSkillTarget]
	ld c, a

.loop:
;>     AIScoreHPDefense(c)
	call AIScoreHPDefense
;=@f
	inc c
	dec b
	jr nz, .loop

;> AIPickLowestScore()                       # runs into it

;@ def AIPickLowestScore()
;@ path: battle/ai/targets
;@ Adds to wSkillTarget (the first position of a side) the index 0-2 of the lowest of the three
;@ scores in wTargetScores; on a tie a random draw decides. The index is kept in the low byte of
;@ wSkillStatusPtr meanwhile.
;@ test: wSkillTarget = rng.choice([0, 4])
AIPickLowestScore::
;> mem[wSkillStatusPtr] = 0                  # index of the lowest score so far
	ld a, $00
	ld [wSkillStatusPtr], a
;> low = wTargetScores
	ld a, [wTargetScores]
	ld c, a
	ld a, [$db59]
	ld b, a
;>@l for e in (1, 2):
	ld de, $0201

.loop:
;>@sc     s = mem16[addr(wTargetScores) + 2 * e]
	ld a, e
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
;=@sc
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>     if s == low:
	call CompareHLBC
	jr z, .tie

;>@t1         BattleRandom_58()
;>@t2         take = not (wRandomHigh & 0x02)
;>     else:
;>         take = s < low
	jr nc, .next

.take:
;>     if take:
;>         low = s; mem[wSkillStatusPtr] = e
	ld b, h
	ld c, l
	ld a, e
	ld [wSkillStatusPtr], a
	jr .next

.tie:
;=@t1
	call BattleRandom_58
;=@t2
	ld a, [wRandomHigh]
	bit 1, a
	jr z, .take

.next:
;=@l
	inc e
	dec d
	jr nz, .loop

;> wSkillTarget += mem[wSkillStatusPtr]
	ld hl, wSkillTarget
	ld a, [wSkillStatusPtr]
	add [hl]
	ld [wSkillTarget], a
	ret


;@ def AIScoreGroundedEnemies()
;@ path: battle/ai/targets
;@ Like AIScoreEnemies, but a monster high in the sky (HighJump) gets no score and a Beserker's
;@ defense counts half; then picks the lowest score.
;@ test: wSkillTarget = rng.choice([0, 4])
AIScoreGroundedEnemies::
;> mem[wStatPtr] = 1                         # flag: halve a Beserker's defense
	ld a, $01
	ld [wStatPtr], a
;>@lp for c in range(wSkillTarget, wSkillTarget + 3):
	ld b, $03
	ld a, [wSkillTarget]
	ld c, a

.loop:
;>     if not wBattlerStatus[8 * c + 4] & 0x04:     # not high in the sky
	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, .sky

;>         AIScoreHPDefense(c)
	call AIScoreHPDefense
	jr .next

.sky:
;>     else:
;>         AISetNoScore(c)
	call AISetNoScore

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> AIPickLowestScore()
	call AIPickLowestScore
	ret


;@ def AIScoreHPDefense(pos: c)
;@ path: battle/ai/targets
;@ Score of position `pos`: HP + defense ($FFFF when the position is empty or out of action); with
;@ the flag in wStatPtr set, a Beserker's defense counts half.
;@ test: pos = rng.randint(0, 7)
AIScoreHPDefense::
;> if CheckBattlerPresent(pos):
;>     return AISetNoScore(pos)
	ld a, c
	call CheckBattlerPresent
	jr c, AISetNoScore

;> hp = GetBattlerHP(pos)
	call GetBattlerHP
	push hl
;> defense = GetBattlerDefense(pos)
	ld a, c
	call GetBattlerDefense
;>@b if mem[wStatPtr] and wBattlerStatus[8 * pos + 6] & 0x04:   # Beserker
	ld a, [wStatPtr]
	or a
	jr z, .add

	push hl
	ld a, c
	ld hl, wBattlerStatus6
;=@b
	call AddEightTimes
	ld a, [hl]
	pop hl
	bit 2, a
	jr z, .add

;>     defense >>= 1
	srl h
	rr l

.add:
;> AISetScore(pos, hp + defense)             # runs into it
	pop de
	add hl, de
	jr AISetScore

;@ def AISetNoScore(pos: c)
;@ path: battle/ai/targets
;@ Gives position `pos` the score $FFFF (never the lowest).
;@ test: pos = rng.randint(0, 7)
AISetNoScore::
;> AISetScore(pos, 0xFFFF)
	ld hl, $ffff

;@ def AISetScore(pos: c, score: hl)
;@ path: battle/ai/targets
;@ Stores `score` as the score of position `pos` (its slot 0-2 on the side) in wTargetScores.
;@ test: pos = rng.randint(0, 6)
AISetScore::
;>@w mem16[addr(wTargetScores) + 2 * (pos & 3)] = score
	ld a, c
	and $03
	add a
	ld de, wTargetScores
	add e
	ld e, a
;=@w
	ld a, $00
	adc d
	ld d, a
	ld a, l
	ld [de], a
	inc de
;=@w
	ld a, h
	ld [de], a
	ret


;@ def CheckTargetExposed(pos: a) -> zero
;@ path: battle/ai/targets
;@ Zero (True) when the monster at `pos` is open to a weapon attack: not high in the sky (HighJump),
;@ not dodging (Dodge) and in no defence stance (Defence, StrongD, BladeD).
;@ test: pos = rng.randint(0, 7)
CheckTargetExposed::
;> if wBattlerStatus[8 * pos + 4] & 0x04:       # high in the sky
;>     return False
	ld hl, wBattlerStatus4
	call AddEightTimes
	bit 2, [hl]
	jr nz, .done

;> if wBattlerStatus[8 * pos + 6] & 0x20:       # Dodge
;>     return False
	inc hl
	inc hl
	ld a, [hli]
	and $20
	jr nz, .done

;> return not wBattlerStatus[8 * pos + 7] & 0x07   # defence stance
	ld a, [hl]
	and $07

.done:
	ret


;@ def AIEstimateDamage()
;@ path: battle/ai/targets
;@ Works out the amount of skill wSkillId into wSkillAmount for the target choice: the spells (below
;@ $37), GigaSlash ($D9) and Ahhh ($DD) through GetSkillBaseAmount (bank $54), the other skills
;@ through SkillDamageByKind (bank $52).
;@ test: skip far calls into the damage routines
AIEstimateDamage::
;>@i if wSkillId < 0x37 or wSkillId == 0xD9 or wSkillId == 0xDD:
	push bc
	ld a, [wSkillId]
	cp $37
	jr c, .base

;=@i
	cp $d9
	jr z, .base

	cp $dd
	jr z, .base

;>@b     GetSkillBaseAmount()
;> else:
;>     SkillDamageByKind()
	ld hl, far_SkillDamageByKind
	rst $10
	jr .done

.base:
;=@b
	ld hl, far_GetSkillBaseAmount
	rst $10

.done:
	pop bc
	ret


AITargetWeakAtRandom::
	call AIRandomEnemyIfDim
	ret z

	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	jr z, AITargetWeakSmart

	call AIListPresentEnemies
	call AIListStart

AIPickWeighted::
	xor a
	ld [wSkillTarget], a

jr_058_443a:
	ld a, d
	dec a
	rst $00

AIPickWeightedTable::
	dw AIPickOfOne
	dw AIPickOfTwo
	dw AIPickOfThree

AIPickOfThree::
	push bc
	call BattleRandom_58
	pop bc
	ld a, [wRandomHigh]
	cp $80
	jr c, AIPickOfOne

	ld hl, wSkillTarget
	inc [hl]

AIPickOfTwo::
	push bc
	call BattleRandom_58
	pop bc
	ld a, [wRandomHigh]
	cp $aa
	jr c, AIPickOfOne

	ld hl, wSkillTarget
	inc [hl]

AIPickOfOne::
	ld hl, wBattleArg0
	ld a, [wSkillTarget]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a
	call CheckBattlerPresent
	jr c, jr_058_443a

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
	ret


AITargetWeakSmart::
	call AIStartScoresAlt

jr_058_448d:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_44b2

	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, c
	call GetBattlerDefense
	srl h
	rr l
	srl d
	rr e
	add hl, de
	ld d, h
	ld e, l
	jr jr_058_44b5

jr_058_44b2:
	ld de, $ffff

jr_058_44b5:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	inc c
	dec b
	jr nz, jr_058_448d

	call AIListPresentEnemies
	call AIListStart
	ld a, d
	cp $02
	jr c, jr_058_44f3

	push af
	push bc
	push de
	push hl
	call AISortFirst
	pop hl
	pop de
	pop bc
	pop af
	ld a, d
	cp $03
	jr c, jr_058_44f3

	push af
	push bc
	push de
	push hl
	call AISortSecond
	pop hl
	pop de
	pop bc
	pop af

jr_058_44f3:
	call AIPickWeighted
	ret


AITargetHeal::
	call AIRandomAllyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	jp z, AIHealSmart

AIHealByRatio::
jr_058_4515:
	ld a, e
	ld [wBattleArg3], a
	ld a, d
	ld [wNamePos], a
	ld a, e
	call CheckBattlerPresent
	jr nc, jr_058_452b

	ld bc, $0000
	ld hl, $0000
	jr jr_058_454d

jr_058_452b:
	ld a, e
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, e
	call GetBattlerMaxHP
	call CompareHLBC
	jr nz, jr_058_454a

	ld bc, $0001
	ld hl, $0000
	jr jr_058_454d

jr_058_454a:
	call DivideHLBC

jr_058_454d:
	push hl
	ld a, [wBattleArg3]
	ld e, a
	ld a, [wNamePos]
	ld d, a
	ld a, $03
	sub d
	ld hl, wSkillStatusPtr
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b
	pop hl
	ld b, h
	ld c, l
	ld a, [wBattleArg3]
	ld e, a
	ld a, [wNamePos]
	ld d, a
	ld a, $03
	sub d
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wBattleArg3]
	ld e, a
	ld a, [wNamePos]
	ld d, a
	inc e
	dec d
	jr nz, jr_058_4515

	call AIPickLowestHPRatio
	ret


AIHealSmart::
	xor a
	ld [wBattleArg0], a
	ld b, d
	ld c, e
	xor a
	ld hl, $db51
	ld [hli], a
	ld [hli], a
	ld [hl], a

jr_058_459e:
	ld a, c
	ld [wBattleArg3], a
	ld a, b
	ld [wNamePos], a
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_45e1

	ld hl, wBattleArg0
	inc [hl]
	ld a, c
	call GetBattlerMaxHP
	ld a, c
	ld de, wBattlerTypeBits
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	bit 0, a
	jr z, jr_058_45ca

	ld a, $1e
	call Multiply24
	jr jr_058_45cc

jr_058_45ca:
	ld e, $00

jr_058_45cc:
	ld a, [$db51]
	add l
	ld [$db51], a
	ld a, [$db52]
	adc h
	ld [$db52], a
	ld a, [wBattleItemUsedUp]
	adc e
	ld [wBattleItemUsedUp], a

jr_058_45e1:
	ld a, [wBattleArg3]
	ld c, a
	ld a, [wNamePos]
	ld b, a
	inc c
	dec b
	jr nz, jr_058_459e

	ld a, [$db51]
	ld l, a
	ld a, [$db52]
	ld h, a
	ld a, [wBattleItemUsedUp]
	ld e, a
	ld a, [wBattleArg0]
	call Divide24
	ld a, [wBattleArg0]
	call Divide24
	ld a, l
	ld [wSkillStatusPtr], a
	ld a, h
	ld [$db62], a
	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
	ld a, $ff
	ld [wBattleArg2], a

jr_058_461a:
	ld a, e
	ld [wBattleArg0], a
	ld a, d
	ld [wBattleArg1], a
	ld a, e
	call CheckBattlerPresent
	jr c, jr_058_466e

	ld a, e
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, e
	call GetBattlerHP
	call CompareHLBC
	jr z, jr_058_466e

	ld a, [wSkillStatusPtr]
	ld c, a
	ld a, [$db62]
	ld b, a
	call CompareHLBC
	jr z, jr_058_465e

	jr nc, jr_058_466e

	ld a, l
	ld [wSkillStatusPtr], a
	ld a, h
	ld [$db62], a
	ld a, [wBattleArg0]
	ld [wBattleArg2], a
	jr jr_058_466e

jr_058_465e:
	call BattleRandom_58
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_466e

	ld a, [wBattleArg0]
	ld [wBattleArg2], a

jr_058_466e:
	ld a, [wBattleArg0]
	ld e, a
	ld a, [wBattleArg1]
	ld d, a
	inc e
	dec d
	jr nz, jr_058_461a

	ld a, [wBattleArg2]
	cp $ff
	jr z, jr_058_4693

	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg2]
	ld [hl], a
	ret


jr_058_4693:
	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
	jp AIHealByRatio


AITargetRevive::
	ld a, [wSkillUser]
	and $04
	or $02
	ld c, a
	ld b, $03

jr_058_46a8:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_46b0

	jr nz, jr_058_46b8

jr_058_46b0:
	dec c
	dec b
	jr nz, jr_058_46a8

	ld a, [wSkillUser]
	ld c, a

jr_058_46b8:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ret


AITargetAntidote::
	call AIRandomAllyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	or $02
	ld c, a
	ld [wSkillTarget], a
	ld b, $03

jr_058_46d8:
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 1, [hl]
	jr nz, jr_058_46fc

	dec c
	dec b
	jr nz, jr_058_46d8

	ld a, [wSkillTarget]
	ld c, a
	ld b, $02

jr_058_46ed:
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 0, [hl]
	jr nz, jr_058_46fc

	dec c
	dec b
	jr nz, jr_058_46ed

jr_058_46fc:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ret


AITargetTwinHits::
	call AIRandomAllyIfDim
	ret z

	call AIStartScores
	ld a, c
	xor $04
	ld c, a

jr_058_4716:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_473a

	ld de, $0001
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	jr nz, jr_058_473d

	ld a, c
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr jr_058_473d

jr_058_473a:
	ld de, $0000

jr_058_473d:
	call AIStoreScore
	inc c
	dec b
	jr nz, jr_058_4716

	call AIPickHighestScore
	call AIFlipTargetSide
	ret


AITargetUpper::
	call AIRandomAllyIfDim
	ret z

	ld hl, wSkillStatusPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
	ld b, $03

jr_058_4764:
	push bc
	ld a, [wBattleArg2]
	call CheckBattlerPresent
	jr c, jr_058_47ad

	ld a, [wBattleArg2]
	call GetBaseDefense_58
	ld a, [wBattleArg2]
	call GetBattlerDefense
	ld a, [wLinkActive]
	or a
	jr nz, jr_058_4786

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_058_4795

jr_058_4786:
	ld a, [wBattleArg2]
	and $03
	cp $03
	cp $03
	jr z, jr_058_4795

	sla c
	rl b

jr_058_4795:
	sla c
	rl b
	call CompareHLBC
	jr nc, jr_058_47a8

	ld bc, $03e7
	call CompareHLBC
	jr nc, jr_058_47a8

	jr jr_058_47b0

jr_058_47a8:
	ld hl, $fffe
	jr jr_058_47b0

jr_058_47ad:
	ld hl, $ffff

jr_058_47b0:
	push hl
	pop de
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	pop bc
	ld hl, wBattleArg2
	inc [hl]
	dec b
	jr nz, jr_058_4764

	ld hl, wSkillStatusPtr
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wStatPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
	inc a
	ld [wBattleArg3], a
	ld a, $02
	ld [wNamePos], a

jr_058_47f0:
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr c, jr_058_4814

	jr nz, jr_058_481c

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_481c

jr_058_4814:
	push hl
	pop bc
	ld a, [wBattleArg3]
	ld [wBattleArg2], a

jr_058_481c:
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	inc hl
	inc hl
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld hl, wBattleArg3
	inc [hl]
	ld hl, wNamePos
	dec [hl]
	ld a, [wNamePos]
	or a
	jr nz, jr_058_47f0

	ld a, [wBattleArg2]
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
	ret


AITargetSap::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores

jr_058_485b:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_489c

	ld de, $0001
	ld a, c
	call GetBattlerDefense
	cp $01
	jr c, jr_058_489f

	jr nz, jr_058_4873

	ld a, h
	or a
	jr z, jr_058_489f

jr_058_4873:
	inc de
	push hl
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	pop hl
	and $22
	jr nz, jr_058_489f

	push hl
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	xor $30
	and $30
	pop de
	or d
	ld d, a
	jr jr_058_489f

jr_058_489c:
	ld de, $0000

jr_058_489f:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_485b

	call AIPickHighestScore
	ret


AITargetSlow::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores

jr_058_48b2:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_48ff

	ld de, $0001
	ld a, c
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	cp $01
	jr c, jr_058_4902

	jr nz, jr_058_48d4

	ld h, a
	or a
	jr z, jr_058_4902

jr_058_48d4:
	inc de
	push hl
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	pop hl
	and $22
	jr nz, jr_058_4902

	push hl
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	rlca
	rlca
	xor $30
	and $30
	pop de
	or d
	ld d, a
	jr jr_058_4902

jr_058_48ff:
	ld de, $0000

jr_058_4902:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_48b2

	call AIPickHighestScore
	ret


AITargetSpeed::
	call AIRandomAllyIfDim
	ret z

	ld hl, wSkillStatusPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
	ld b, $03

jr_058_4927:
	push bc
	ld a, [wBattleArg2]
	call CheckBattlerPresent
	jr c, jr_058_497a

	ld a, [wBattleArg2]
	call GetBaseAgility_58
	ld a, [wBattleArg2]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push bc
	ld bc, $01ff
	call CompareHLBC
	pop bc
	jr nc, jr_058_4975

	ld a, [wLinkActive]
	or a
	jr nz, jr_058_495d

	ld a, [wSkillUser]
	cp $04
	jr nc, jr_058_496a

jr_058_495d:
	ld a, [wBattleArg2]
	and $03
	cp $03
	jr z, jr_058_496a

	sla c
	rl b

jr_058_496a:
	sla c
	rl b
	call CompareHLBC
	jr nc, jr_058_4975

	jr jr_058_497d

jr_058_4975:
	ld hl, $fffe
	jr jr_058_497d

jr_058_497a:
	ld hl, $ffff

jr_058_497d:
	push hl
	pop de
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	pop bc
	ld hl, wBattleArg2
	inc [hl]
	dec b
	jr nz, jr_058_4927

	ld hl, wSkillStatusPtr
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wStatPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
	inc a
	ld [wBattleArg3], a
	ld a, $02
	ld [wNamePos], a

jr_058_49bd:
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr c, jr_058_49e1

	jr nz, jr_058_49e9

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_49e9

jr_058_49e1:
	push hl
	pop bc
	ld a, [wBattleArg3]
	ld [wBattleArg2], a

jr_058_49e9:
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	inc hl
	inc hl
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	ld hl, wBattleArg3
	inc [hl]
	ld hl, wNamePos
	dec [hl]
	ld a, [wNamePos]
	or a
	jr nz, jr_058_49bd

	ld a, [wBattleArg2]
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
	ret


AITargetUltraDown::
	call AIRandomEnemyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

jr_058_4a37:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4a8d

	ld a, c
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call IsAtMostOne
	jr c, jr_058_4a7c

	ld a, c
	call GetBattlerDefense
	call IsAtMostOne
	jr c, jr_058_4a7c

	push bc
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	and $30
	ld [hl], a
	jr jr_058_4a9c

jr_058_4a7c:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fe
	ld [hl], a
	jr jr_058_4a9c

jr_058_4a8d:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hl], a

jr_058_4a9c:
	inc c
	dec b
	jr nz, jr_058_4a37

	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg1], a
	inc c
	dec b
	call AIPickLowestKey
	ret


AITargetCover::
	call AIRandomAllyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	ld [wSkillTarget], a
	ld c, a
	ld b, $03

jr_058_4ac9:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4af0

	ld a, [wSkillUser]
	cp c
	jr z, jr_058_4af0

	ld a, c
	call GetBattlerHP
	push hl
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	pop hl
	jr z, jr_058_4af3

	ld bc, $0200
	add hl, bc
	jr jr_058_4af3

jr_058_4af0:
	ld hl, $ffff

jr_058_4af3:
	ld d, h
	ld e, l
	pop bc
	ld a, c
	and $03
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, e
	ld [hli], a
	ld [hl], d
	inc c
	dec b
	jr nz, jr_058_4ac9

	call AIPickLowestOwnScore
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	push hl
	call CheckBattlerPresent
	pop hl
	ret nc

	ld a, [wSkillUser]
	ld [hl], a
	ret


AITargetMouthShut::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores

jr_058_4b2d:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4b65

	ld de, $0001
	ld a, c
	call KnowsBreathSkill
	jr nc, jr_058_4b68

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 7, [hl]
	jr nz, jr_058_4b68

	ld de, $00ff
	push de
	ld a, $06
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	xor $c0
	and $c0
	pop de
	or d
	ld d, a
	jr jr_058_4b68

jr_058_4b65:
	ld de, $0000

jr_058_4b68:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4b2d

	call AIPickHighestScore
	ret


AITargetSickLick::
	call AIRandomEnemyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

Jump_058_4b8a:
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, jr_058_4bf8

	ld a, c
	call GetBattlerDefense
	cp $01
	jr c, jr_058_4bd6

	jr nz, jr_058_4ba0

	ld a, h
	or a
	jr z, jr_058_4bd6

jr_058_4ba0:
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $c0
	jr nz, jr_058_4be7

	inc hl
	inc hl
	ld a, [hl]
	and $3f
	jr nz, jr_058_4be7

	push bc
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	and $30
	ld [hl], a
	jr jr_058_4c07

jr_058_4bd6:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fd
	ld [hl], a
	jr jr_058_4c07

jr_058_4be7:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fe
	ld [hl], a
	jr jr_058_4c07

jr_058_4bf8:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hl], a

jr_058_4c07:
	inc c
	dec b
	jp nz, Jump_058_4b8a

	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg1], a
	call AIPickLowestKey
	ret


AITargetLegSweep::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores

jr_058_4c2b:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4c76

	ld de, $0001
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 4, [hl]
	jr nz, jr_058_4c79

	ld de, $0002
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $d0
	jr nz, jr_058_4c79

	inc hl
	inc hl
	ld a, [hl]
	and $3f
	jr nz, jr_058_4c79

	ld de, $00ff
	push de
	ld a, $05
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	xor $0c
	and $0c
	pop de
	or d
	ld d, a
	jr jr_058_4c79

jr_058_4c76:
	ld de, $0000

jr_058_4c79:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4c2b

	call AIPickHighestScore
	ret


AITargetNapAttack::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScores

jr_058_4c90:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4cc2

	ld de, $0001
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 7, [hl]
	jr nz, jr_058_4cc5

	ld hl, $00ff
	push hl
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	xor $c0
	and $c0
	pop de
	or d
	ld d, a
	jr jr_058_4cc5

jr_058_4cc2:
	ld de, $0000

jr_058_4cc5:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4c90

	call AIPickHighestScore
	ret


AITargetOddDance::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores

jr_058_4cd8:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4d0b

	ld a, c
	ld hl, wBattlerMP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	or [hl]
	jr z, jr_058_4d0b

	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld de, $0001
	ld a, [wBattleArg0]
	rlca
	rlca
	xor $30
	and $30
	or d
	ld d, a
	jr jr_058_4d0e

jr_058_4d0b:
	ld de, $0000

jr_058_4d0e:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4cd8

	call AIPickHighestScore
	ret


AITargetMetalCut::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores

jr_058_4d21:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4d4e

	ld de, $0001
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	jr z, jr_058_4d51

	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	xor $ff
	ld e, a
	ld a, [hl]
	xor $ff
	ld d, a
	jr jr_058_4d51

jr_058_4d4e:
	ld de, $0000

jr_058_4d51:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4d21

	call AIPickHighestScore
	ret


AITargetDrakSlash::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $01
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetBeastCut::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $02
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetBirdBlow::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $03
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetDevilCut::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $06
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetZombieCut::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $07
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetCleanCut::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $08
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetSmashlime::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $00
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetSheldodge::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $05
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetBranching::
	call AIRandomEnemyIfDim
	ret z

	call AIStartScores
	ld a, $04
	ld [wBattleArg0], a
	call AIScoreFamily
	ret


AITargetPoisonHit::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScores

jr_058_4df8:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4e2a

	ld de, $0001
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, jr_058_4e2d

	ld de, $00ff
	push de
	ld a, $04
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	and $03
	xor $03
	pop de
	ld d, a
	jr jr_058_4e2d

jr_058_4e2a:
	ld de, $0000

jr_058_4e2d:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4df8

	call AIPickHighestScore
	ret


AITargetParalyze::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScores

jr_058_4e44:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4e76

	ld de, $0001
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $cc
	jr nz, jr_058_4e79

	ld de, $00ff
	push de
	ld a, $05
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	and $c0
	xor $c0
	pop de
	ld d, a
	jr jr_058_4e79

jr_058_4e76:
	ld de, $0000

jr_058_4e79:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4e44

	call AIPickHighestScore
	ret


AITargetAhhh::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScores

jr_058_4e90:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_4ec9

	ld de, $0001
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $d0
	jr nz, jr_058_4ecc

	inc hl
	inc hl
	ld a, [hl]
	and $3f
	jr nz, jr_058_4ecc

	ld de, $00ff
	push de
	ld a, $05
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	ld a, [wBattleArg0]
	and $0c
	xor $0c
	pop de
	ld d, a
	jr jr_058_4ecc

jr_058_4ec9:
	ld de, $0000

jr_058_4ecc:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, jr_058_4e90

	call AIPickHighestScore
	ret


AITargetTransform::
	call AIRandomEnemyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	xor $04
	ld [wBattleArg0], a
	inc a
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
	ld a, [wBattleArg0]
	call CheckBattlerPresent
	jr c, jr_058_4f1c

	ld hl, wBattlerMaxHP
	ld a, [wBattleArg0]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wBattlerMaxMP
	ld a, [wBattleArg0]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	call Add16To24
	jr jr_058_4f21

jr_058_4f1c:
	ld bc, $0000
	ld e, $00

jr_058_4f21:
	ld hl, wSkillAmount
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hl], a

Jump_058_4f2a:
	ld a, [wBattleArg1]
	call CheckBattlerPresent
	jr c, jr_058_4f57

	ld hl, wBattlerMaxHP
	ld a, [wBattleArg1]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wBattlerMaxMP
	ld a, [wBattleArg1]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	call Add16To24
	jr jr_058_4f5c

jr_058_4f57:
	ld bc, $0000
	ld e, $00

jr_058_4f5c:
	ld hl, wTargetScores
	ld a, e
	cp [hl]
	jr c, jr_058_4f80

	jr nz, jr_058_4f71

	dec hl
	ld a, b
	cp [hl]
	jr c, jr_058_4f80

	jr nz, jr_058_4f71

	dec hl
	ld a, c
	cp [hl]
	jr c, jr_058_4f80

jr_058_4f71:
	ld hl, wSkillAmount
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hl], a
	ld a, [wBattleArg1]
	ld [wBattleArg0], a

jr_058_4f80:
	ld hl, wBattleArg1
	inc [hl]
	ld hl, wBattleArg2
	dec [hl]
	ld a, [wBattleArg2]
	or a
	jp nz, Jump_058_4f2a

	ld a, [wBattleArg0]
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
	ret


AIMetalPenalty::
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	ret z

	push af
	push bc
	push de
	push hl
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, $32
	call Multiply24
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	pop hl
	pop de
	pop bc
	pop af
	ret


AITargetBeat::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt

Jump_058_4fdd:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_501e

	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	push bc
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wBattleArg0]
	and $30
	ld [de], a
	push de
	call CheckReflects
	pop hl
	jr z, jr_058_500e

	set 6, [hl]

jr_058_500e:
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr jr_058_5030

jr_058_501e:
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, $ff
	ld [de], a
	ld de, $0000

jr_058_5030:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	pop bc
	inc c
	dec b
	jp nz, Jump_058_4fdd

	call AIPickBestKeyHighScore
	call AISetTargetFromBest
	ret


AITargetBlaze::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt

Jump_058_5074:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_50b5

	ld a, $00
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	push bc
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wBattleArg0]
	and $30
	ld [de], a
	push de
	call CheckReflects
	pop hl
	jr z, jr_058_50a5

	set 6, [hl]

jr_058_50a5:
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr jr_058_50c7

jr_058_50b5:
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, $ff
	ld [de], a
	ld de, $ffff

jr_058_50c7:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	pop bc
	inc c
	dec b
	jp nz, Jump_058_5074

	call AIPickBestKeyLowScore
	call AISetTargetFromBest
	ret


AITargetRamming::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	xor a
	ld [wNamePos], a
	ld [$db51], a
	ld [$db52], a
	ld [wBattleItemUsedUp], a

jr_058_5118:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_5142

	ld de, $0001
	ld a, c
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 5, [hl]
	jr nz, jr_058_5145

	inc hl
	ld a, [hl]
	and $05
	jr nz, jr_058_5145

	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr jr_058_5145

jr_058_5142:
	ld de, $0000

jr_058_5145:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	inc c
	dec b
	jr nz, jr_058_5118

	call AIPickBestKeyHighScore
	call AISetTargetFromBest
	ret


AITargetLife::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	ld a, [wLinkActive]
	or a
	jp nz, AITargetEnemySide

	ld a, [wSkillUser]
	cp $04
	jp c, AITargetEnemySide

	call AIStartScoresAlt
	ld a, c
	ld [wNameBattler], a
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_51ac

	ld d, $fe
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_058_51ae

	push bc
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	ld a, [wBattleArg0]
	and $c0
	ld d, a
	jr jr_058_51ae

jr_058_51ac:
	ld d, $ff

jr_058_51ae:
	ld a, d
	ld [wNamePos], a
	ld a, c
	ld [wNameBattler], a
	inc c
	dec b

Jump_058_51b8:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_51e3

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, jr_058_51df

	push bc
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	ld a, [wBattleArg0]
	and $c0
	jr jr_058_51e5

jr_058_51df:
	ld a, $fe
	jr jr_058_51e5

jr_058_51e3:
	ld a, $ff

jr_058_51e5:
	ld d, a
	ld hl, wNamePos
	cp [hl]
	jr c, jr_058_5200

	jr nz, jr_058_5208

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_5208

jr_058_5200:
	ld a, d
	ld [wNamePos], a
	ld a, c
	ld [wNameBattler], a

jr_058_5208:
	inc c
	dec b
	jp nz, Jump_058_51b8

	call AISetTargetFromBest
	ret


AITargetSleep::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

jr_058_522b:
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, jr_058_527e

	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $c0
	jr nz, jr_058_526d

	inc hl
	ld a, [hli]
	and $22
	jr nz, jr_058_526d

	ld a, [hl]
	and $3f
	jr nz, jr_058_526d

	push bc
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	and $c0
	ld [hl], a
	jr jr_058_528d

jr_058_526d:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fe
	ld [hl], a
	jr jr_058_528d

jr_058_527e:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hl], a

jr_058_528d:
	inc c
	dec b
	jr nz, jr_058_522b

	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg1], a
	call AIPickLowestKey
	ret


AITargetRobMagic::
	call AIRandomEnemyIfDim
	ret z

	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

jr_058_52bf:
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, jr_058_530e

	ld a, c
	call GetBattlerMP
	or h
	jr z, jr_058_530e

	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	jr nz, jr_058_52fd

	push bc
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wBattleArg0]
	and $0c
	ld [hl], a
	jr jr_058_531d

jr_058_52fd:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $fe
	ld [hl], a
	jr jr_058_531d

jr_058_530e:
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hl], a

jr_058_531d:
	inc c
	dec b
	jr nz, jr_058_52bf

	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg1], a
	call AIPickLowestKey
	ret


AITargetFireSlash::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	ld a, $00
	ld [wBattleArg2], a
	ld a, $c0
	ld [wBattleArg3], a
	call AITargetResistHPDef
	ret


AITargetBoltSlash::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	ld a, $01
	ld [wBattleArg2], a
	ld a, $30
	ld [wBattleArg3], a
	call AITargetResistHPDef
	ret


AITargetVacuSlash::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	ld a, $01
	ld [wBattleArg2], a
	ld a, $c0
	ld [wBattleArg3], a
	call AITargetResistHPDef
	ret


AITargetIceSlash::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	ld a, $01
	ld [wBattleArg2], a
	ld a, $0c
	ld [wBattleArg3], a
	call AITargetResistHPDef
	ret


AITargetWindBeast::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	ld a, $01
	ld [wBattleArg2], a
	ld a, $c0
	ld [wBattleArg3], a
	call AITargetResistHP
	ret


AITargetGigaSlash::
	call AIRandomEnemyIfDim
	ret z

	call AIUsesScoring
	ret z

	call AIStartScoresAlt
	ld a, $06
	ld [wBattleArg2], a
	ld a, $0c
	ld [wBattleArg3], a
	call AITargetResistHP
	ret


ChooseTargetsAndOrder::
	ld a, [wBattleSubStep]
	rst $00

ChooseTargetsSteps::
	dw ChooseTargetsNext
	dw ChooseTargetsTactic
	dw ChooseTargetsPick
	dw TurnOrderRollSpeeds
	dw TurnOrderSort
	dw ChooseTargetsDone

ChooseTargetsNext::
	ld a, [wLinkActive]
	or a
	call nz, LinkRandom
	ld a, [wSkillUser]
	cp $08
	jr z, jr_058_5411

	ld e, a
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $01
	jr z, jr_058_5403

	inc e
	ld a, e
	ld [wSkillUser], a
	jr jr_058_541d

jr_058_5403:
	ld a, e
	ld [wSkillUser], a
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	jr jr_058_541d

jr_058_5411:
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]

jr_058_541d:
	ret


ChooseTargetsTactic::
	ld hl, far_Call_57_6E0E
	rst $10
	ret


UnusedJumpToPointer::
	db $2a, $66, $6f, $e9

ChooseTargetsPick::
	xor a
	ld [wHitCount], a
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr nz, jr_058_5478

	ld a, [wSkillUser]
	call CheckBattlerCanAct
	jr nc, jr_058_545b

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $3a
	ld [hli], a
	ld a, [wSkillUser]
	ld [hl], a
	jr jr_058_5478

jr_058_545b:
	ld a, [wGameModeStep]
	or a
	call nz, MaybeForceSkill
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	call z, SetActionAttack
	call RunTargetPicker

jr_058_5478:
	call NotePersonalitySkill
	call NotePersonalityAttack
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $02
	ld [hl], a
	xor a
	ld [wBattleSubStep], a
	ld hl, wSkillUser
	inc [hl]
	jp ChooseTargetsNext


RunTargetPicker::
	ld a, [wBattleSubStep]
	cp $16
	jr c, jr_058_54b1

	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, $ff
	ld [hld], a
	jr jr_058_54be

jr_058_54b1:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a

jr_058_54be:
	ld a, [hl]
	ld [wSkillId], a
	ld hl, $401d
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	call JumpToPointer
	ret


SetActionAttack::
	ld [hl], $3a
	ret


TurnOrderRollSpeeds::
	ld hl, wTurnOrder
	ld bc, $0009
	ld a, $ff
	call FillMemory
	ld hl, wBattleArg0
	ld bc, $0009
	ld a, $ff
	call FillMemory
	ld hl, wSkillStatusPtr
	ld bc, $0010
	ld a, $00
	call FillMemory
	xor a
	ld [wTurnOrderPos], a
	ld [wBattlerReload], a
	ld hl, wSkillStatusPtr
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld de, $0800

Jump_058_5507:
	push de
	ld a, [wLinkActive]
	or a
	call nz, LinkRandom
	pop de
	ld a, e
	call CheckBattlerPresent
	jr c, jr_058_5587

	ld a, e
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	jr nz, jr_058_5587

	ld a, e
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, e
	call RollSpeed
	ld a, b
	or a
	jr nz, jr_058_5543

	ld a, c
	cp $02
	jr nc, jr_058_5543

	ld bc, $0002

jr_058_5543:
	ld a, e
	call IsFirstMoveSkill
	jr c, jr_058_5561

	ld a, e
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $55
	call z, SpeedBonusSquallHit
	cp $56
	call z, SpeedSlowest
	jr jr_058_5565

jr_058_5561:
	ld a, b
	add $06
	ld b, a

jr_058_5565:
	ld hl, wNameDest
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wBattlerReload]
	ld hl, wBattleArg0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	ld hl, wBattlerReload
	inc [hl]
	ld hl, wNameDest
	inc [hl]
	ld hl, wNameDest
	inc [hl]

jr_058_5587:
	inc e
	dec d
	jp nz, Jump_058_5507

	ld a, [wLinkActive]
	or a
	jr nz, jr_058_55b3

	ld a, [wBattleItemTarget]
	cp $ff
	jr z, jr_058_55b3

	ld bc, $0200
	ld hl, wNameDest
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	ld [hli], a
	ld [hl], b
	ld a, [wBattlerReload]
	ld hl, wBattleArg0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], $10

jr_058_55b3:
	ld hl, wBattleSubStep
	inc [hl]
	jr TurnOrderSort

SpeedBonusSquallHit::
	ld a, b
	add $02
	ld b, a
	ret


SpeedSlowest::
	ld bc, $0001
	ret


TurnOrderSort::
	ld d, $08

jr_058_55c4:
	ld hl, wSkillStatusPtr
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wStatPtr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld e, $00

jr_058_55da:
	call CompareHLBC
	jr c, jr_058_5615

	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	ld a, c
	ld [wTargetScores], a
	ld a, b
	ld [$db59], a
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, [wSkillAmount]
	ld [hli], a
	ld a, [$db57]
	ld [hli], a
	ld a, [wTargetScores]
	ld [hli], a
	ld a, [$db59]
	ld [hl], a
	ld a, e
	ld hl, wBattleArg0
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld [hld], a
	ld [hl], b

jr_058_5615:
	inc e
	ld a, e
	cp d
	jr z, jr_058_5635

	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	inc hl
	inc hl
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jr jr_058_55da

jr_058_5635:
	dec d
	jr nz, jr_058_55c4

	ld a, [wTurnOrderPos]
	ld de, wTurnOrder
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [wTurnOrderPos]
	ld hl, wBattleArg0
	ld b, $08

jr_058_564c:
	ld a, [hli]
	cp $ff
	jr z, jr_058_5656

	ld [de], a
	inc de
	dec b
	jr nz, jr_058_564c

jr_058_5656:
	ld a, $00
	ld [wTurnOrderPos], a
	ld hl, wBattleSubStep
	inc [hl]
	jp ChooseTargetsDone


RollSpeed::
	push hl
	push de
	push af
	push bc
	call BattleRandom_58
	ld hl, $0001
	pop bc
	ld a, b
	or c
	jr nz, jr_058_5674

	ld bc, $0001

jr_058_5674:
	ld d, b
	ld e, c
	srl b
	rr c
	srl b
	rr c
	add hl, bc
	srl b
	rr c
	srl b
	rr c
	add hl, bc
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ld b, h
	ld c, l
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, h
	and $03
	ld h, a

jr_058_569c:
	call CompareHLBC
	jr z, jr_058_56ab

	jr c, jr_058_56ab

	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr jr_058_569c

jr_058_56ab:
	add hl, de
	ld b, h
	ld c, l
	pop af
	ld e, a
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $55
	jr nz, jr_058_56c5

	ld a, b
	add $02
	ld b, a
	jr jr_058_56cc

jr_058_56c5:
	cp $56
	jr nz, jr_058_56cc

	ld bc, $0000

jr_058_56cc:
	pop de
	pop hl
	ret


IsFirstMoveSkill::
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $2a
	jr z, jr_058_5705

	cp $7f
	jr z, jr_058_5705

	cp $88
	jr z, jr_058_5705

	cp $89
	jr z, jr_058_5705

	cp $8c
	jr z, jr_058_5705

	cp $8d
	jr z, jr_058_5705

	cp $8e
	jr z, jr_058_5705

	cp $8f
	jr z, jr_058_5705

	cp $90
	jr z, jr_058_5705

	cp $dc
	jr z, jr_058_5705

	xor a
	jr jr_058_5706

jr_058_5705:
	scf

jr_058_5706:
	ret


ChooseTargetsDone::
	xor a
	ld [wBattleSubStep], a
	ld [wTurnOrderPos], a
	ld [wSkillUser], a
	ld [wSkillTarget], a
	ld [wSkillId], a
	ld hl, wBattleStep
	inc [hl]
	ret


UnusedRandomSkill::
	db $e5, $fa, $88, $db, $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $44
	db $4d, $fa, $99, $c8, $e6, $07, $87, $85, $6f, $3e, $00, $8c, $67, $7e, $fe, $ff
	db $20, $07, $0a, $fe, $ff, $20, $02, $3e, $3a, $4f, $e1, $71, $c9

BlankEnemyPicture::
	ld a, $02
	ld [wBattleStepArg1], a
	ld a, [wLinkActive]
	or a
	jr z, jr_058_5766

	ld a, [wLinkFlags]
	bit 1, a
	jr z, jr_058_5766

	ld a, [wSkillTarget]
	bit 2, a
	ret nz

	ld a, [wSkillTarget]
	jr jr_058_5771

jr_058_5766:
	ld a, [wSkillTarget]
	bit 2, a
	ret z

	ld a, [wSkillTarget]
	sub $04

jr_058_5771:
	cp $02
	jr z, jr_058_5783

	cp $01
	jr z, jr_058_577e

	ld hl, $9000
	jr jr_058_5786

jr_058_577e:
	ld hl, $9240
	jr jr_058_5786

jr_058_5783:
	ld hl, $9480

jr_058_5786:
	ld c, $24

jr_058_5788:
	ld b, $08

jr_058_578a:
	di

jr_058_578b:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, jr_058_578b

	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
	ei
	dec b
	jr nz, jr_058_578a

	dec c
	jr nz, jr_058_5788

	ld a, $05
	ld [wBattleSubStep], a
	ret


GetItemMessage::
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, jr_058_57e6

	cp $c7
	jr nc, jr_058_57e6

	ld b, a
	ld a, $01
	ld [wTextGroup], a
	ld a, [wBattleItemTarget]
	cp $04
	jr nc, jr_058_57c2

	call CountTargetsOne
	jp Jump_058_58f8


jr_058_57c2:
	jp Jump_058_58e8


GetSkillMessage::
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, jr_058_57f4

	inc hl
	bit 4, [hl]
	jr nz, jr_058_57fa

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]

jr_058_57e6:
	ld hl, $5806
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg0], a
	ret


jr_058_57f4:
	ld a, $33
	ld [wBattleArg0], a
	ret


jr_058_57fa:
	ld a, $4f
	ld [wBattleArg0], a
	ret


UnusedClearArg0::
	db $3e, $ff, $ea, $4c, $db, $c9

SkillMessages::
	db $23, $23, $23, $23, $23, $23, $23, $23, $23, $23
	db $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23
	db $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23
	db $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $23, $22, $22, $23
	db $22, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $34, $24, $24, $24, $24, $24, $24
	db $24, $24, $24, $24, $24, $35, $24, $24, $36, $37, $38, $39, $3a, $24, $24, $3b
	db $3c, $3d, $25, $25, $25, $25, $25, $25, $25, $25, $3e, $3f, $40, $22, $22, $22
	db $25, $25, $25, $25, $26, $41, $44, $26, $42, $24, $24, $26, $26, $43, $26, $45
	db $45, $46, $24, $48, $22, $50, $27, $27, $27, $70, $49, $49, $49, $49, $51, $52
	db $4a, $4b, $53, $28, $54, $56, $55, $26, $4c, $4d, $26, $4e, $26, $2a, $18, $22
	db $22, $57, $58, $5c, $59, $5a, $5b, $29, $6f, $ff, $ff, $70, $71, $ff, $ff, $73
	db $ff, $74, $75, $ff, $ff, $77, $5d, $5d, $5f, $60, $5d, $5d, $5d, $5d, $5d, $5d
	db $5d, $5d, $ff, $ff, $ff, $ff, $ff, $ff, $5e, $5e, $5e, $5e, $5e, $61, $62, $63
	db $64, $65, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $66, $23, $24, $24, $24, $24
	db $23, $29, $23, $44, $67, $68, $ff, $6a

Jump_058_58e8:
	ld a, [wSkillTarget]
	push af
	ld a, $04
	ld [wSkillTarget], a
	call CountTargetNames
	pop af
	ld [wSkillTarget], a

Jump_058_58f8:
	ld a, [wBattleItemEffect]
	cp $c5
	jr nz, jr_058_5907

	ld a, [wBattleTemp]
	add $03
	ld [wBattleTemp], a

jr_058_5907:
	ld a, [wBattleTemp]
	ld hl, $5918
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wBattleArg0], a
	ret


MeatMessages::
	db $00, $01, $02, $00, $01, $02

SetNameFormMessage::
	call GetMessageSidePos
	cp $04
	call nc, StripLetterArg0
	ld a, [wBattleTemp]
	ld hl, $5937
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wTextIndex], a
	ret


NameFormMessages::
	db $03, $05, $07, $04, $06, $08

StripLetterArg0::
	ld hl, wTextArg0
	jr jr_058_5945

StripLetterArg2::
	ld hl, wTextArg2

jr_058_5945:
	ld a, [hl]
	cp $f0
	jr z, jr_058_594d

	inc hl
	jr jr_058_5945

jr_058_594d:
	dec hl
	ld a, [hl]
	cp $24
	ret nc

	ld [hl], $f0
	ret


CountTargetNames::
	xor a
	ld [wBattleTemp], a
	ld [wBattleTempHigh], a
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $03
	ld a, [wLinkActive]
	or a
	jr nz, jr_058_596f

	ld a, c
	cp $04
	jr nc, jr_058_5988

jr_058_596f:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_5979

	ld hl, wBattleTemp
	inc [hl]

jr_058_5979:
	inc c
	dec b
	jr nz, jr_058_596f

	ld a, [wBattleTemp]
	dec a
	or a
	jr z, jr_058_59d8

	ld a, $01
	jr jr_058_59d8

jr_058_5988:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_59b9

	ld hl, wBattleTemp
	inc [hl]
	ld hl, wBattleTempHigh
	ld a, [hl]
	or a
	jr nz, jr_058_59a8

	ld a, c
	ld de, wBattlerSpecies
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld d, a
	inc [hl]
	jr jr_058_59b9

jr_058_59a8:
	push bc
	ld a, c
	ld bc, wBattlerSpecies
	add c
	ld c, a
	ld a, $00
	adc b
	ld b, a
	ld a, [bc]
	pop bc
	cp d
	jr z, jr_058_59b9

	inc [hl]

jr_058_59b9:
	inc c
	dec b
	jr nz, jr_058_5988

	ld a, [wBattleTemp]
	cp $01
	jr z, CountTargetsOne

	ld a, [wBattleTempHigh]
	cp $01
	jr z, jr_058_59d3

	ld a, $02
	jr jr_058_59d8

CountTargetsOne::
	ld a, $00
	jr jr_058_59d8

jr_058_59d3:
	call StripLetterArg2
	ld a, $01

jr_058_59d8:
	ld [wBattleTemp], a
	ret


NameTargetForMessage::
	ld hl, wTextArg0
	ld a, [wLinkActive]
	or a
	jr nz, jr_058_59f1

	ld a, [wSkillTarget]
	cp $03
	jr c, jr_058_59f1

	call CopySpeciesName
	jr jr_058_59fe

jr_058_59f1:
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
	call CopyName

jr_058_59fe:
	call CountTargetNames
	ret


CopySpeciesName::
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


MaybeForceSkill::
	call BattleRandom_58
	ld a, [wOpeningScene]
	or a
	jr z, jr_058_5a2e

	ld hl, wRandomHigh
	cp [hl]
	ret c

jr_058_5a2e:
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wOpeningLogo]
	ld [hl], a
	ret


NotePersonalitySkill::
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	ret c

	ld a, [wLinkActive]
	or a
	jr z, jr_058_5a5a

	call LinkRandom
	ld a, [wSkillUser]
	and $03
	cp $03
	ret z

	jr jr_058_5a63

jr_058_5a5a:
	ld a, [wSkillUser]
	cp $03
	ret nc

	call BattleRandom_58

jr_058_5a63:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hli]
	and $0c
	ret nz

	ld a, [hl]
	and $0c
	jp nz, Jump_058_5b1e

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $12
	ret c

	cp $14
	ret z

	cp $1b
	ret z

	cp $1e
	jr c, jr_058_5afb

	cp $20
	jr z, jr_058_5afb

	cp $21
	jr z, jr_058_5afb

	cp $2b
	ret c

	cp $32
	ret z

	cp $37
	jr c, jr_058_5b09

	cp $3a
	jr z, jr_058_5aed

	cp $44
	ret c

	cp $4f
	ret z

	cp $52
	jr c, jr_058_5aed

	cp $55
	jr z, jr_058_5aed

	cp $67
	ret c

	cp $6a
	jr c, jr_058_5aed

	cp $77
	jr z, jr_058_5b1e

	cp $7e
	jr c, jr_058_5afb

	cp $81
	jr z, jr_058_5b09

	cp $82
	jr z, jr_058_5afb

	cp $8c
	jr z, jr_058_5b10

	cp $8d
	jr z, jr_058_5af4

	cp $8e
	jr z, jr_058_5af4

	cp $90
	jr z, jr_058_5af4

	ret c

	cp $93
	jr c, jr_058_5afb

	cp $96
	jr c, jr_058_5b09

	cp $d6
	ret c

	cp $d9
	jr c, jr_058_5aed

	ret


jr_058_5aed:
	ld hl, wBattlerPersonality1
	ld d, $01
	jr jr_058_5b25

jr_058_5af4:
	ld hl, wBattlerPersonality1
	ld d, $02
	jr jr_058_5b63

jr_058_5afb:
	ld hl, wBattlerStat67
	ld d, $04
	jr jr_058_5b25

NoteStat67Low::
	ld hl, wBattlerStat67
	ld d, $08
	jr jr_058_5b63

jr_058_5b09:
	ld hl, wBattlerPersonality2
	ld d, $10
	jr jr_058_5b25

jr_058_5b10:
	ld hl, wBattlerPersonality2
	ld d, $20
	jr jr_058_5b63

NotePersonality3High::
	ld hl, wBattlerPersonality3
	ld d, $40
	jr jr_058_5b25

Jump_058_5b1e:
jr_058_5b1e:
	ld hl, wBattlerPersonality3
	ld d, $80
	jr jr_058_5b63

jr_058_5b25:
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $81
	ret c

	cp $a2
	jr c, jr_058_5b40

	cp $c3
	jr c, jr_058_5b44

	cp $e4
	jr c, jr_058_5b48

	jr jr_058_5b4c

jr_058_5b40:
	ld b, $01
	jr jr_058_5b4e

jr_058_5b44:
	ld b, $02
	jr jr_058_5b4e

jr_058_5b48:
	ld b, $04
	jr jr_058_5b4e

jr_058_5b4c:
	ld b, $08

jr_058_5b4e:
	ld a, [wRandomHigh]
	cp b
	ret nc

	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or d
	ld [hl], a
	ret


jr_058_5b63:
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $80
	ret nc

	cp $60
	jr nc, jr_058_5b7e

	cp $3f
	jr nc, jr_058_5b82

	cp $1e
	jr nc, jr_058_5b86

	jr jr_058_5b8a

jr_058_5b7e:
	ld b, $02
	jr jr_058_5b8c

jr_058_5b82:
	ld b, $04
	jr jr_058_5b8c

jr_058_5b86:
	ld b, $08
	jr jr_058_5b8c

jr_058_5b8a:
	ld b, $10

jr_058_5b8c:
	ld a, [wRandomHigh]
	cp b
	ret nc

	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or d
	ld [hl], a
	ret


NotePersonalityAttack::
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	ret c

	ld a, [wLinkActive]
	or a
	jr z, jr_058_5bbb

	call LinkRandom
	ld a, [wSkillUser]
	and $03
	cp $03
	ret z

	jr jr_058_5bc4

jr_058_5bbb:
	ld a, [wSkillUser]
	cp $03
	ret nc

	call BattleRandom_58

jr_058_5bc4:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hli]
	and $0c
	ret nz

	ld a, [hl]
	and $0c
	ret nz

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $90
	jr z, jr_058_5c07

	cp $12
	jr c, jr_058_5c03

	cp $3a
	jr z, jr_058_5c03

	cp $44
	ret c

	cp $52
	jr c, jr_058_5c03

	cp $55
	ret c

	cp $6a
	jr c, jr_058_5c03

	cp $d6
	ret c

	cp $da
	ret nc

jr_058_5c03:
	call NotePersonality3High
	ret


jr_058_5c07:
	call NoteStat67Low
	ret


GetMessageSidePos::
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

	ld a, [wSkillUser]
	ret


LinkRandom::
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


BattleRandom_58::
	ld a, [wLinkActive]
	or a
	jr nz, LinkRandom

	call Random
	ret


PickTargetForSkill::
	call RunTargetPicker
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wSkillId], a
	ld a, [hl]
	ld [wSkillTarget], a
	ld a, [wBattleSubStep]
	cp $17
	jr z, jr_058_5c6e

	ld a, $02
	ld [wBattleStepArg0], a
	jr jr_058_5c73

jr_058_5c6e:
	ld a, $01
	ld [wBattleStepArg0], a

jr_058_5c73:
	xor a
	ld [wBattleSubStep], a
	ld a, $02
	ld [wBattleSubStep2], a
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	ret nz

	ld a, [wBattleTemp]
	or a
	ret nz

	ld hl, wBattleSubStep2
	inc [hl]
	ret


GetBaseDefense_58::
	push hl
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_058_5ccf

	ld a, b
	cp $03
	jr c, jr_058_5cd6

	and $03
	cp $03
	jr z, jr_058_5cde

	ld a, b
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

jr_058_5cb9:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateDefense]
	ld c, a
	ld a, [$da24]
	ld b, a
	jr jr_058_5ced

jr_058_5ccf:
	ld a, b
	and $03
	cp $03
	jr z, jr_058_5cde

jr_058_5cd6:
	ld hl, wMonDefense
	call GetPartyMonsterWord
	jr jr_058_5ced

jr_058_5cde:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_058_5cb9

jr_058_5ced:
	pop hl
	ret


AIPickBestKeyLowScore::
	ld hl, wTargetScores
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, $00
	ld [wNameBattler], a
	ld hl, wSkillAmount
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, $0201

jr_058_5d08:
	push hl
	push de
	push bc
	call BattleRandom_58
	ld a, [wNameBattler]
	ld hl, wNamePos
	and $03
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
	ld a, e
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp b
	pop bc
	pop de
	pop hl
	jr c, jr_058_5d50

	jr nz, jr_058_5d61

	push hl
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	call CompareHLBC
	jr c, jr_058_5d61

	jr nz, jr_058_5d5b

	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_5d61

	jr jr_058_5d5b

jr_058_5d50:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a

jr_058_5d5b:
	ld h, b
	ld l, c
	ld a, e
	ld [wNameBattler], a

jr_058_5d61:
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	inc e
	dec d
	jr nz, jr_058_5d08

	ret


AIPickBestKeyHighScore::
	ld hl, wTargetScores
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, $00
	ld [wNameBattler], a
	ld hl, wSkillAmount
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, $0201

jr_058_5d9f:
	push hl
	push de
	push bc
	call BattleRandom_58
	ld a, [wNameBattler]
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
	ld a, e
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp b
	pop bc
	pop de
	pop hl
	jr c, jr_058_5de3

	jr nz, jr_058_5df4

	push hl
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	call CompareHLBC
	jr c, jr_058_5dee

	jr nz, jr_058_5df4

	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_5df4

	jr jr_058_5dee

jr_058_5de3:
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a

jr_058_5dee:
	ld h, b
	ld l, c
	ld a, e
	ld [wNameBattler], a

jr_058_5df4:
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	inc e
	dec d
	jr nz, jr_058_5d9f

	ret


AIStartScoresAlt::
	ld hl, wSkillAmount
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	ret


CheckReflects::
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	ret


AISetTargetFromBest::
	ld a, [wNameBattler]
	ld c, a
	ld a, [wSkillUser]
	and $04
	xor $04
	add c
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
	ret


AIListPresentEnemies::
	call AIListStart
	ld b, $03
	ld d, $00

jr_058_5e62:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_5e6d

	ld a, c
	ld [hli], a
	inc d
	jr jr_058_5e70

jr_058_5e6d:
	call AIDropScore

jr_058_5e70:
	inc c
	dec b
	jr nz, jr_058_5e62

	ret


AIListStart::
	ld hl, wBattleArg0
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ret


AISortFirst::
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a
	call AIPickBestKeyLowScore
	ld a, [wNameBattler]
	ld hl, wBattleArg0
	ld de, wBattleArg0
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl]
	ld [de], a
	ld a, b
	ld [hl], a
	ld hl, wSkillAmount
	ld a, [wNameBattler]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	push hl
	ld e, a
	ld hl, wSkillAmount
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, d
	ld [hld], a
	ld [hl], e
	pop hl
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


AISortSecond::
	call AIPickBestKeyHighScore
	ld a, [wNameBattler]
	ld hl, wBattleArg2
	ld de, wBattleArg0
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl]
	ld [de], a
	ld a, b
	ld [hl], a
	ld hl, wSkillAmount
	ld a, [wNameBattler]
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	push hl
	ld e, a
	ld hl, wSkillAmount2
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, d
	ld [hld], a
	ld [hl], e
	pop hl
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


UnusedAddHLBC24::
	db $7d, $81, $6f, $7c, $88, $67, $af, $ce, $00, $4f, $c9

Add16To24::
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
	xor a
	adc $00
	ld e, a
	ret


AIPickLowestKey::
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld d, [hl]
	ld a, [wBattleArg1]
	cp d
	jr c, jr_058_5f3b

	jr nz, jr_058_5f33

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_5f3b

jr_058_5f33:
	ld a, c
	ld [wBattleArg0], a
	ld a, d
	ld [wBattleArg1], a

jr_058_5f3b:
	inc c
	dec b
	jr nz, AIPickLowestKey

	ld a, [wBattleArg0]
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
	ret


AIScoreHPDef::
	push hl
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, jr_058_5f77

	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, c
	call GetBattlerDefense
	add hl, de
	jr nc, jr_058_5f7f

	jr jr_058_5f7c

jr_058_5f77:
	ld a, $ff
	ld [wBattleArg0], a

jr_058_5f7c:
	ld hl, $ffff

jr_058_5f7f:
	ld d, h
	ld e, l
	pop hl
	ret


AIScoreHP::
	push hl
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, jr_058_5f9c

	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr jr_058_5fa4

jr_058_5f9c:
	ld a, $ff
	ld [wBattleArg0], a
	ld de, $ffff

jr_058_5fa4:
	pop hl
	ret


AITargetResistHPDef::
	ld a, c
	ld [wNameBattler], a
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	call AIScoreHPDef
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
	ld hl, wSkillAmount
	ld a, e
	ld [hli], a
	ld [hl], d
	inc c
	dec b

jr_058_5fcf:
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	call AIScoreHPDef
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld h, a
	ld a, [wNamePos]
	cp h
	jr c, jr_058_6027

	jr nz, jr_058_6013

	ld hl, $db57
	ld a, [hld]
	cp d
	jr c, jr_058_6027

	jr nz, jr_058_6013

	ld a, [hl]
	cp e
	jr c, jr_058_6027

	jr nz, jr_058_6013

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_6027

jr_058_6013:
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
	ld hl, wSkillAmount
	ld a, e
	ld [hli], a
	ld [hl], d
	ld a, c
	ld [wNameBattler], a

jr_058_6027:
	inc c
	dec b
	jr nz, jr_058_5fcf

	ld a, [wNameBattler]
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
	ret


AITargetResistHP::
	ld a, c
	ld [wNameBattler], a
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	call AIScoreHP
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
	ld hl, wSkillAmount
	ld a, e
	ld [hli], a
	ld [hl], d
	inc c
	dec b

jr_058_606c:
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
	ld hl, far_GetResistByte
	rst $10
	pop bc
	call AIScoreHP
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld h, a
	ld a, [wNamePos]
	cp h
	jr c, jr_058_60c4

	jr nz, jr_058_60b0

	ld hl, $db57
	ld a, [hld]
	cp d
	jr c, jr_058_60c4

	jr nz, jr_058_60b0

	ld a, [hl]
	cp e
	jr c, jr_058_60c4

	jr nz, jr_058_60b0

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_60c4

jr_058_60b0:
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
	ld hl, wSkillAmount
	ld a, e
	ld [hli], a
	ld [hl], d
	ld a, c
	ld [wNameBattler], a

jr_058_60c4:
	inc c
	dec b
	jr nz, jr_058_606c

	ld a, [wNameBattler]
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
	ret


IsAtMostOne::
	ld a, h
	or a
	jr nz, jr_058_60ee

	ld a, l
	or a
	jr z, jr_058_60ec

	cp $01
	jr nz, jr_058_60ee

jr_058_60ec:
	scf
	ret


jr_058_60ee:
	ld a, $02
	cp $01
	ret


GetBaseAgility_58::
	push hl
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, jr_058_612c

	ld a, b
	cp $03
	jr c, jr_058_6132

	and $03
	cp $03
	jr z, jr_058_613a

	ld a, b
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

jr_058_6116:
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
	ld hl, far_LoadMonTemplate2
	rst $10
	ld a, [wTemplateAgility]
	ld c, a
	ld a, [$da26]
	ld b, a
	jr jr_058_6149

jr_058_612c:
	and $03
	cp $03
	jr z, jr_058_613a

jr_058_6132:
	ld hl, wMonAgility
	call GetPartyMonsterWord
	jr jr_058_6149

jr_058_613a:
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld l, [hl]
	ld h, $01
	jr jr_058_6116

jr_058_6149:
	pop hl
	ret


UnusedAverageEnemyAgility::
	db $e5, $01, $00, $00, $fa, $88, $db, $e6, $04, $ee, $04, $5f, $16, $03, $af, $ea
	db $50, $db, $7b, $cd, $a5, $2f, $38, $15, $7b, $21, $03, $dc, $87, $85, $6f, $3e
	db $00, $8c, $67, $2a, $66, $6f, $09, $44, $4d, $21, $50, $db, $34, $1c, $15, $20
	db $e1, $fa, $50, $db, $60, $69, $cd, $0d, $1e, $44, $4d, $e1, $c9

AIFlipTargetSide::
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	xor $04
	ld [hl], a
	ret


AIPickHighestScore::
	ld hl, wTargetScores
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, $00
	ld [wNameBattler], a
	ld hl, wSkillAmount
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, $0201

jr_058_61b3:
	push hl
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	call CompareHLBC
	jr c, jr_058_61d9

	jr nz, jr_058_61df

	push af
	push bc
	push de
	push hl
	call BattleRandom_58
	pop hl
	pop de
	pop bc
	pop af
	ld a, [wRandomHigh]
	cp $80
	jr c, jr_058_61df

jr_058_61d9:
	ld h, b
	ld l, c
	ld a, e
	ld [wNameBattler], a

jr_058_61df:
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	inc e
	dec d
	jr nz, jr_058_61b3

	ld a, [wNameBattler]
	ld c, a
	ld a, [wSkillUser]
	and $04
	xor $04
	add c
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
	ret


AIPickLowestOwnScore::
	ld a, $00
	ld [wNameBattler], a
	ld a, [wTargetScores]
	ld l, a
	ld a, [$db59]
	ld h, a
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [$db5b]
	ld b, a
	call CompareHLBC
	jr c, jr_058_624b

	ld a, $01
	ld [wNameBattler], a
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [$db5b]
	ld h, a

jr_058_624b:
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [$db5d]
	ld b, a
	call CompareHLBC
	jr c, jr_058_625d

	ld a, $02
	ld [wNameBattler], a

jr_058_625d:
	ld a, [wNameBattler]
	ld c, a
	ld a, [wSkillUser]
	and $04
	add c
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
	ret


AIStartScores::
	ld hl, wSkillAmount
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [$db5f], a
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	ret


AIStoreScore::
	ld a, [wNameDest]
	ld l, a
	ld a, [$db5f]
	ld h, a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [$db5f]
	adc $00
	ld [$db5f], a
	ret


AITargetEnemySide::
	ld a, [wSkillUser]
	and $04
	xor $04
	ld [wBattleArg0], a
	call AITargetFirstPresent
	ret


AITargetOwnSide::
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg0], a
	call AITargetFirstPresent
	ret


AITargetFirstPresent::
	ld a, [wBattleArg0]
	ld c, a
	ld b, $03

jr_058_62df:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_62ed

	inc c
	dec b
	jr nz, jr_058_62df

	ld a, [wBattleArg0]
	ld c, a

jr_058_62ed:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, c
	ld [hl], a
	ret


AITargetSweep::
	ld a, [wHitCount]
	or a
	jr nz, jr_058_632a

	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a

jr_058_630b:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_631b

	ld a, c
	and $03
	cp $03
	jr z, jr_058_632a

	inc c
	jr jr_058_630b

jr_058_631b:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], c
	ret


jr_058_632a:
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld c, a
	ld a, c
	and $03
	cp $03
	jr c, jr_058_634f

	ld a, c
	and $04
	xor $04
	ld b, a
	ld a, [wSkillUser]
	and $04
	cp b
	ret nz

	ld [hl], b
	ret


jr_058_634f:
	inc c

jr_058_6350:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_631b

	ld a, c
	and $03
	cp $03
	ret z

	inc c
	jr jr_058_6350

AITargetOwnFirst::
	ld a, [wSkillUser]
	and $04
	ld c, a
	jr jr_058_62ed

AITargetSelf::
	ld a, [wSkillUser]
	ld hl, $dced
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [wSkillUser]
	ld [hl], a
	ret


AITargetAnyone::
	ld a, [wRandomHigh]
	ld c, a
	and $07
	call CheckBattlerPresent
	jr nc, jr_058_63b4

	ld a, [wRandomLow]
	ld b, a
	and $07
	call CheckBattlerPresent
	jr nc, jr_058_63b7

	or c
	and $07
	call CheckBattlerPresent
	ld c, a
	jr nc, jr_058_63b4

	or b
	and $07
	call CheckBattlerPresent
	jr nc, jr_058_63ba

	ld a, b
	add c
	and $07
	call CheckBattlerPresent
	jr nc, jr_058_63be

jr_058_63a9:
	dec b
	ld a, b
	and $07
	call CheckBattlerPresent
	jr c, jr_058_63a9

	jr jr_058_63b7

jr_058_63b4:
	ld a, c
	jr jr_058_63c0

jr_058_63b7:
	ld a, b
	jr jr_058_63c0

jr_058_63ba:
	ld a, c
	or b
	jr jr_058_63c0

jr_058_63be:
	ld a, b
	add c

jr_058_63c0:
	and $07
	ld c, a
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wSkillId], a
	ld [hl], c
	ret


AITargetSelfLoadSkill::
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wSkillId], a
	ld a, [wSkillUser]
	ld [hl], a
	ret


CountPresent::
	ld c, e
	ld b, $03
	ld d, $00

jr_058_63f1:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_63f8

	inc d

jr_058_63f8:
	inc c
	dec b
	jr nz, jr_058_63f1

	ret


AITargetRandomPresent::
	call BattleRandom_58
	ld a, [wRandomHigh]
	ld b, a
	ld a, d
	push de
	call Divide8
	pop bc
	inc a
	ld e, a

jr_058_640c:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_6415

jr_058_6412:
	inc c
	jr jr_058_640c

jr_058_6415:
	dec e
	jr nz, jr_058_6412

	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wSkillId], a
	ld a, c
	ld [hl], a
	ret


AITargetRandomEnemy::
	ld a, [wSkillUser]
	and $04
	xor $04
	ld e, a
	call CountPresent
	call AITargetRandomPresent
	ret


UnusedRandomEnemy::
	db $cd, $3e, $5c, $fa, $88, $db, $e6, $04, $ee, $04, $47, $fa, $99, $c8, $e6, $03
	db $b0, $4f, $79, $cd, $a5, $2f, $30, $0f, $79, $d6, $01, $4f, $38, $03, $b8, $30
	db $f1, $78, $f6, $03, $4f, $18, $eb, $78, $b1, $4f, $fa, $88, $db, $21, $ec, $dc
	db $87, $85, $6f, $3e, $00, $8c, $67, $2a, $ea, $8a, $db, $79, $77, $c9

AITargetRandomAlly::
	ld a, [wSkillUser]
	and $04
	ld e, a
	call CountPresent
	call AITargetRandomPresent
	ret


UnusedRandomAlly::
	db $fa, $88, $db, $e6, $04, $47, $fa, $99, $c8, $e6, $03, $b0, $4f, $fa, $88, $db
	db $21, $ec, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $7e, $fe, $30, $28, $07, $fe
	db $31, $28, $03, $79, $18, $1f, $79, $4f, $21, $1b, $dd, $85, $6f, $3e, $00, $8c
	db $67, $7e, $fe, $ff, $20, $25, $79, $d6, $01, $38, $03, $b8, $30, $e9, $fa, $88
	db $db, $f6, $03, $18, $e2, $4f, $cd, $a5, $2f, $30, $10, $79, $d6, $01, $4f, $38
	db $03, $b8, $30, $f1, $fa, $88, $db, $f6, $03, $18, $ea, $fa, $88, $db, $e6, $04
	db $b1, $4f, $fa, $88, $db, $21, $ec, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $2a
	db $ea, $8a, $db, $79, $77, $c9

AIScoreFamily::
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_651f

	call CheckFamily
	jr nz, jr_058_6524

	pop bc
	push bc
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	xor $ff
	ld e, a
	ld a, [hl]
	xor $ff
	ld d, a
	jr jr_058_6527

jr_058_651f:
	ld de, $0000
	jr jr_058_6527

jr_058_6524:
	ld de, $0001

jr_058_6527:
	call AIStoreScore
	pop bc
	inc c
	dec b
	jr nz, AIScoreFamily

	call AIPickHighestScore
	ret


CheckFamily::
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
	ld a, [wMonStats]
	ld hl, wBattleArg0
	cp [hl]
	ret


AIRandomEnemyIfDim::
	call GetUserIntClass
	ret nz

	call AITargetRandomEnemy
	xor a
	ret


AIRandomAllyIfDim::
	call GetUserIntClass
	ret nz

	call AITargetRandomAlly
	xor a
	ret


GetUserIntClass::
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	or a
	ret


KnowsBreathSkill::
	ld hl, $dc65
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld b, $08

jr_058_657b:
	ld a, [hl]
	cp $43
	jr z, jr_058_659b

	cp $5c
	jr c, jr_058_6594

	cp $64
	jr c, jr_058_659b

	cp $6a
	jr c, jr_058_6594

	cp $6e
	jr c, jr_058_659b

	cp $8f
	jr z, jr_058_659b

jr_058_6594:
	inc hl
	inc hl
	dec b
	jr nz, jr_058_657b

	xor a
	ret


jr_058_659b:
	scf
	ret


UnusedEnemiesProtected::
	db $c5, $d5, $e5, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $1e, $00, $16
	db $00, $79, $d5, $cd, $a5, $2f, $d1, $38, $19, $1c, $79, $21, $06, $db, $cd, $6c
	db $2f, $2a, $e6, $0c, $20, $0b, $23, $2a, $e6, $28, $20, $05, $7e, $e6, $07, $28
	db $01, $14, $0c, $05, $20, $db, $7a, $bb, $28, $03, $37, $18, $04, $3e, $0a, $fe
	db $01, $e1, $d1, $c1, $c9, $e5, $fa, $89, $db, $cd, $a5, $2f, $38, $1c, $fa, $89
	db $db, $21, $06, $db, $cd, $6c, $2f, $2a, $e6, $0c, $20, $0e, $23, $2a, $e6, $28
	db $20, $08, $7e, $e6, $07, $20, $03, $37, $18, $04, $3e, $0a, $fe, $01, $e1, $c9

CheckHittable::
	push hl
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_6623

	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, jr_058_6623

	scf
	jr jr_058_6627

jr_058_6623:
	ld a, $0a
	cp $01

jr_058_6627:
	pop hl
	ret


AIUsesScoring::
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
	cp $02
	jr z, jr_058_6656

	ld a, [wSkillUser]
	and $03
	cp $03
	jr z, jr_058_6650

	ld a, [wLinkActive]
	or a
	jr nz, jr_058_6656

	ld a, [wSkillUser]
	cp $04
	jr c, jr_058_6656

jr_058_6650:
	call AITargetWeakAtRandom
	xor a
	or a
	ret


jr_058_6656:
	ld a, $01
	or a
	ret


AIPickLowestHPRatio::
	ld a, $00
	ld [wNameDest], a
	ld a, $01
	ld [$db5f], a
	ld a, $02
	ld [wNameBattler], a

jr_058_6669:
	ld a, [$db5f]
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, [wNameDest]
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr c, jr_058_66b5

	jr nz, jr_058_66bb

	ld a, [$db5f]
	ld hl, wSkillStatusPtr
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, [wNameDest]
	ld hl, wSkillStatusPtr
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
	jr nc, jr_058_66bb

jr_058_66b5:
	ld a, [$db5f]
	ld [wNameDest], a

jr_058_66bb:
	ld hl, $db5f
	inc [hl]
	ld a, [wNameBattler]
	dec a
	ld [wNameBattler], a
	jr nz, jr_058_6669

	ld a, [wNameDest]
	ld c, a
	ld a, [wSkillUser]
	and $04
	add c
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
	ret


AIDropScore::
	push hl
	push de
	ld a, c
	and $03
	cp $02
	jr z, jr_058_6734

	cp $01
	jr z, jr_058_6714

	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	ld a, [wTargetScores]
	ld e, a
	ld a, [$db59]
	ld d, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [$db59], a
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [$db57], a

jr_058_6714:
	ld a, [wTargetScores]
	ld l, a
	ld a, [$db59]
	ld h, a
	ld a, [wSkillAmount2]
	ld e, a
	ld a, [$db5b]
	ld d, a
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [$db5b], a
	ld a, e
	ld [wTargetScores], a
	ld a, d
	ld [$db59], a

jr_058_6734:
	pop de
	pop hl
	ret


FixActionTarget::
	ld a, [wSkillUser]
	cp $10
	jr z, jr_058_6750

	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld [wBattleArg0], a
	call FixGroupTarget
	ret


jr_058_6750:
	ld hl, wBattleItemEffect
	ld a, [hld]
	ld [wBattleArg0], a
	cp $c2
	jr c, FixGroupTarget

	cp $c7
	jr nc, FixGroupTarget

	ld a, [hl]
	cp $04
	ret c

	and $04
	ld c, a
	ld b, $03
	ld d, $ff

jr_058_676a:
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_677b

jr_058_6770:
	inc c
	dec b
	jr nz, jr_058_676a

	ld a, d
	cp $ff
	ret z

	ld c, d
	jr jr_058_678d

jr_058_677b:
	ld a, d
	cp $ff
	call z, RememberFirst
	ld a, c
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
	jr nz, jr_058_6770

jr_058_678d:
	ld hl, wBattleItemTarget
	ld [hl], c
	ret


RememberFirst::
	ld d, c
	ret


FixGroupTarget::
	ld a, $00
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
	push hl
	ld hl, far_GetSkillWord
	rst $10
	pop hl
	ld a, [wBattleArg0]
	and $03
	cp $01
	ret z

jr_058_67ac:
	ld a, [hl]
	call CheckBattlerPresent
	ret nc

	ld a, [hl]
	and $03
	cp $02
	ret z

	inc [hl]
	jr jr_058_67ac

AIAttackWeight::
	ld a, $14
	ld [wAttackWeight], a
	call AILowestEnemyDefense
	ld a, [wSkillUser]
	call GetBattlerAttack
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	call CompareHLBC
	jp c, Jump_058_6859

	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	srl b
	rr c
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	add hl, bc
	push hl
	ld a, [wSkillUser]
	call GetBattlerAttack
	pop bc
	call CompareHLBC
	jr c, jr_058_6859

	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	add hl, bc
	push hl
	ld a, [wSkillUser]
	call GetBattlerAttack
	pop bc
	call CompareHLBC
	jr c, jr_058_6859

	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped
	ld a, [wSkillAmount]
	ld l, a
	ld a, [$db57]
	ld h, a
	add hl, hl
	ld a, [wSkillAmount]
	ld c, a
	ld a, [$db57]
	ld b, a
	srl b
	rr c
	add hl, bc
	push hl
	ld a, [wSkillUser]
	call GetBattlerAttack
	pop bc
	call CompareHLBC
	jr c, jr_058_6859

	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped

Jump_058_6859:
jr_058_6859:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, [hli]
	and $0c
	jr nz, jr_058_686e

	inc hl
	inc hl
	ld a, [hl]
	and $03
	jr z, jr_058_6876

jr_058_686e:
	ld hl, wAttackWeight
	ld b, $1e
	call AddCapped

jr_058_6876:
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

jr_058_6880:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_689b

	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hli]
	and $0c
	jr nz, jr_058_689b

	inc hl
	bit 5, [hl]
	jr nz, jr_058_689b

	inc hl
	bit 2, [hl]
	ret z

jr_058_689b:
	inc c
	dec b
	jr nz, jr_058_6880

	ld a, $01
	ld [wAttackWeight], a
	ret


AILowestEnemyDefense::
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

jr_058_68af:
	ld a, c
	call CheckBattlerPresent
	jr c, jr_058_68c5

	ld a, c
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr jr_058_68c8

jr_058_68c5:
	ld de, $ffff

jr_058_68c8:
	ld a, $03
	sub b
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
	inc c
	dec b
	jr nz, jr_058_68af

	ld a, [wTargetScores]
	ld l, a
	ld a, [$db59]
	ld h, a
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [$db5b]
	ld b, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [$db57], a
	call CompareHLBC
	jr c, jr_058_6903

	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ld h, b
	ld l, c

jr_058_6903:
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [$db5d]
	ld b, a
	call CompareHLBC
	ret c

	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [$db57], a
	ret


AddCapped::
	ld a, [hl]
	add b
	ld [hl], a
	ret nc

	ld a, $ff
	ld [hl], a
	ret


Bank58Padding::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
