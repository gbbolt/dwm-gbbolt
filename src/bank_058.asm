INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $058", ROMX[$4000], BANK[$58]

;@ path: system/banks
;@ Bank number byte: every switchable bank starts with its own number.
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
;> fill(addr(wSkillAmount), 0, 8)                      # the score scratch
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
	ld a, [wSkillAmount + 1]
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
	ld [wSkillAmount + 1], a
	jr .exposedScore

.exposedNone:
;>         else:
;>             wSkillAmount = 0xFFFF
	ld a, $ff
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a

.exposedScore:
;>         AIMetalPenalty(c)
	pop bc
	call AIMetalPenalty
;>         AISetScore(c, wSkillAmount)
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
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
	ld a, [wSkillAmount + 1]
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
	ld [wSkillAmount + 1], a
	jr .activeScore

.activeNone:
;=@a4
	ld a, $ff
	ld [wSkillAmount], a
	ld [wSkillAmount + 1], a

.activeScore:
;=@a8
	pop bc
	call AIMetalPenalty
;=@a9
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
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
	ld hl, wBattlerAction + 1
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
;> mem[addr(wStatPtr)] = 0                         # flag: no Beserker halving
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
;> mem[addr(wSkillStatusPtr)] = 0                  # index of the lowest score so far
	ld a, $00
	ld [wSkillStatusPtr], a
;> low = wTargetScores
	ld a, [wTargetScores]
	ld c, a
	ld a, [wTargetScores + 1]
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
;>         low = s; mem[addr(wSkillStatusPtr)] = e
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

;> wSkillTarget += mem[addr(wSkillStatusPtr)]
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
;> mem[addr(wStatPtr)] = 1                         # flag: halve a Beserker's defense
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
;>@b if mem[addr(wStatPtr)] and wBattlerStatus[8 * pos + 6] & 0x04:   # Beserker
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


;@ def AITargetWeakAtRandom()
;@ path: battle/ai/targets
;@ Attack target of an enemy monster in a normal battle, and of the pickers that leave the choice to
;@ plain attack aiming (AIAimPlainInstead): a dim monster hits anyone, a smart one ranks the enemies
;@ (AITargetWeakSmart); otherwise one of the opposing monsters still standing is drawn with
;@ AIPickWeighted, the first of the list being the most likely.
;@ test: skip draws random numbers through the link generator
AITargetWeakAtRandom::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;>@cl if wBattlerIntClass[wSkillUser] == 2:
;>@sm     return AITargetWeakSmart()
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
;=@sm
	jr z, AITargetWeakSmart

;> count = AIListPresentEnemies()             # wBattleArg0.. = the positions still standing
	call AIListPresentEnemies
;> AIListStart()
	call AIListStart

;> AIPickWeighted(count)                      # runs into it

;@ def AIPickWeighted(count: d)
;@ path: battle/ai/targets
;@ Draws one of the first `count` (1-3) battle positions listed in wBattleArg0..wBattleArg2 and makes
;@ it the target of the user: of three the first is taken half of the time, the second a third and
;@ the last a sixth of the time; of two the first two thirds of the time.
;@ test: skip draws random numbers through the link generator
AIPickWeighted::
;> wSkillTarget = 0                           # index into the list
	xor a
	ld [wSkillTarget], a

.again:
;> AIPickWeightedTable[count - 1]()
	ld a, d
	dec a
	rst $00

;@ path: battle/ai/targets
;@ AIPickWeighted's jump table, by the number of candidates (1, 2, 3).
AIPickWeightedTable::
	dw AIPickOfOne
	dw AIPickOfTwo
	dw AIPickOfThree

;@ def AIPickOfThree(count: d)
;@ path: battle/ai/targets
;@ Of three listed candidates: index 0 with a chance of 1/2, else on to AIPickOfTwo from index 1.
;@ test: skip draws random numbers through the link generator
AIPickOfThree::
;> BattleRandom_58()
	push bc
	call BattleRandom_58
	pop bc
;> if wRandomHigh < 0x80:
;>     return AIPickOfOne(count)
	ld a, [wRandomHigh]
	cp $80
	jr c, AIPickOfOne

;> wSkillTarget += 1
	ld hl, wSkillTarget
	inc [hl]

;> AIPickOfTwo(count)                              # runs into it

;@ def AIPickOfTwo(count: d)
;@ path: battle/ai/targets
;@ Of two listed candidates (from index wSkillTarget): the first with a chance of 2/3.
;@ test: skip draws random numbers through the link generator
AIPickOfTwo::
;> BattleRandom_58()
	push bc
	call BattleRandom_58
	pop bc
;> if wRandomHigh < 0xAA:
;>     return AIPickOfOne(count)
	ld a, [wRandomHigh]
	cp $aa
	jr c, AIPickOfOne

;> wSkillTarget += 1
	ld hl, wSkillTarget
	inc [hl]

;> AIPickOfOne(count)                              # runs into it

;@ def AIPickOfOne(count: d)
;@ path: battle/ai/targets
;@ Takes list entry wSkillTarget (wBattleArg0 + index) as the target of the user. Should that
;@ position be empty it draws again (through AIPickWeighted's table, now indexed with the position).
;@ test: skip may loop back into the random draw
AIPickOfOne::
;>@t wSkillTarget = mem[addr(wBattleArg0) + wSkillTarget]
	ld hl, wBattleArg0
	ld a, [wSkillTarget]
	add l
	ld l, a
	ld a, $00
	adc h
;=@t
	ld h, a
	ld a, [hl]
	ld [wSkillTarget], a
;> if CheckBattlerPresent(wSkillTarget):
;>     return AIPickWeightedTable[count - 1]()
	call CheckBattlerPresent
	jr c, AIPickWeighted.again

;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AITargetWeakSmart()
;@ path: battle/ai/targets
;@ Attack target of a smart enemy monster: scores the opposing monsters by HP/2 + defense/2, lists the
;@ ones still standing sorted by that score (lowest first) and draws one with AIPickWeighted, so the
;@ weakest is the most likely.
;@ test: skip draws random numbers through the link generator
AITargetWeakSmart::
;> side, n = AIStartScoresAlt()               # scores go to wSkillAmount.. (pointer in wNameDest)
	call AIStartScoresAlt

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@hp         hp = mem16[addr(wBattlerHP) + 2 * c]
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
;>@sc         score = GetBattlerDefense(c) // 2 + hp // 2
	ld a, c
	call GetBattlerDefense
	srl h
	rr l
	srl d
	rr e
;=@sc
	add hl, de
	ld d, h
	ld e, l
	jr .store

.none:
;>     else:
;>         score = 0xFFFF
	ld de, $ffff

.store:
;>@w     mem16[wNameDest] = score; wNameDest += 2
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, e
	ld [hli], a
;=@w
	ld a, d
	ld [hli], a
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;=@lp
	inc c
	dec b
	jr nz, .loop

;> count = AIListPresentEnemies()             # the empty positions' scores move to the end
	call AIListPresentEnemies
;> AIListStart()
	call AIListStart
;> if count >= 2:
	ld a, d
	cp $02
	jr c, .pick

;>@s1     AISortFirst()                          # lowest score first
	push af
	push bc
	push de
	push hl
	call AISortFirst
;=@s1
	pop hl
	pop de
	pop bc
	pop af
;> if count >= 3:
	ld a, d
	cp $03
	jr c, .pick

;>@s2     AISortSecond()                         # highest score last
	push af
	push bc
	push de
	push hl
	call AISortSecond
;=@s2
	pop hl
	pop de
	pop bc
	pop af

.pick:
;> AIPickWeighted(count)
	call AIPickWeighted
	ret


;@ def AITargetHeal()
;@ path: battle/ai/targets
;@ Target picker of Heal, HealMore and HealAll: a dim monster heals anyone of its side; a smart
;@ one tries AIHealSmart first; otherwise AIHealByRatio picks the monster with the lowest share
;@ of its maximum HP.
;@ test: skip far chain of pickers
AITargetHeal::
;> if AIRandomAllyIfDim():
;>     return
	call AIRandomAllyIfDim
	ret z

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
;>@cl if wBattlerIntClass[wSkillUser] == 2:
;>@sm     return AIHealSmart(side, 3)
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
;=@sm
	jp z, AIHealSmart

;> AIHealByRatio(side, 3)                     # runs into it

;@ def AIHealByRatio(pos: e, count: d)
;@ path: battle/ai/targets
;@ For the `count` positions from `pos` on: max HP / HP as quotient (wTargetScores) and remainder
;@ (wSkillStatusPtr), 0/1 for a monster at full HP and 0/0 for an empty position; then
;@ AIPickLowestHPRatio takes the one with the largest quotient - the lowest share of its HP left.
;@ test: skip writes the score lists through several scratch variables
AIHealByRatio::
.loop:
;> while True:
;>     wBattleArg3 = pos; wNamePos = count     # kept while the registers are busy
	ld a, e
	ld [wBattleArg3], a
	ld a, d
	ld [wNamePos], a
;>     if CheckBattlerPresent(pos):
	ld a, e
	call CheckBattlerPresent
	jr nc, .present

;>         q = 0; r = 0
	ld bc, $0000
	ld hl, $0000
	jr .store

.present:
;>@hp     else:
;>@hp2         hp = mem16[addr(wBattlerHP) + 2 * pos]
	ld a, e
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp2
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>         if GetBattlerMaxHP(pos) == hp:
	ld a, e
	call GetBattlerMaxHP
	call CompareHLBC
	jr nz, .divide

;>             q = 0; r = 1                    # full HP
	ld bc, $0001
	ld hl, $0000
	jr .store

.divide:
;>         else:
;>             q, r = DivideHLBC(GetBattlerMaxHP(pos), hp)
	call DivideHLBC

.store:
;>@r     mem16[addr(wSkillStatusPtr) + 2 * (3 - count)] = r
	push hl
	ld a, [wBattleArg3]
	ld e, a
	ld a, [wNamePos]
	ld d, a
	ld a, $03
;=@r
	sub d
	ld hl, wSkillStatusPtr
	add a
	add l
	ld l, a
	ld a, $00
;=@r
	adc h
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b
	pop hl
;>@q     mem16[addr(wTargetScores) + 2 * (3 - count)] = q
	ld b, h
	ld c, l
	ld a, [wBattleArg3]
	ld e, a
	ld a, [wNamePos]
	ld d, a
;=@q
	ld a, $03
	sub d
	ld hl, wTargetScores
	add a
	add l
	ld l, a
;=@q
	ld a, $00
	adc h
	ld h, a
	ld a, c
	ld [hli], a
	ld [hl], b
;>     pos += 1; count -= 1
	ld a, [wBattleArg3]
	ld e, a
	ld a, [wNamePos]
	ld d, a
	inc e
	dec d
;>     if count == 0:
;>         break
	jr nz, .loop

;> AIPickLowestHPRatio()
	call AIPickLowestHPRatio
	ret


;@ def AIHealSmart(pos: e, count: d)
;@ path: battle/ai/targets
;@ Healing target of a smart monster: works out a limit from the total maximum HP of its side
;@ (divided twice by the number of monsters standing; for a metal monster the code adds 30 times the
;@ loop registers instead of its maximum HP), then picks the monster below full HP with the lowest HP
;@ under that limit (a tie is decided at random). Without one it falls back to AIHealByRatio.
;@ test: skip writes the score lists through several scratch variables
AIHealSmart::
;> wBattleArg0 = 0                            # monsters standing
	xor a
	ld [wBattleArg0], a
	ld b, d
	ld c, e
;> mem16[0xDB51] = 0; wBattleItemUsedUp = 0   # 24-bit total at $DB51-$DB53
	xor a
	ld hl, wAIKindBonus2
	ld [hli], a
	ld [hli], a
	ld [hl], a

.sum:
;>@fs for i in range(count):
;>     c = pos + i; wBattleArg3 = c; wNamePos = count - i
	ld a, c
	ld [wBattleArg3], a
	ld a, b
	ld [wNamePos], a
;>     if not CheckBattlerPresent(c):
;>         wBattleArg0 += 1
	ld a, c
	call CheckBattlerPresent
	jr c, .nextSum

	ld hl, wBattleArg0
	inc [hl]
;>@mx         add = GetBattlerMaxHP(c)
	ld a, c
	call GetBattlerMaxHP
;>@mt         if wBattlerTypeBits[c] & 0x01:      # metal
	ld a, c
	ld de, wBattlerTypeBits
	add e
	ld e, a
	ld a, $00
	adc d
;=@mt
	ld d, a
	ld a, [de]
	bit 0, a
	jr z, .notMetal

;>             add = Multiply24(30, (count - i) * 256 + c)   # (30 x the loop registers)
	ld a, $1e
	call Multiply24
	jr .add

.notMetal:
;=@mx
	ld e, $00

.add:
;>@ad         total = mem16[0xDB51] + wBattleItemUsedUp * 0x10000 + add
	ld a, [wAIKindBonus2]
	add l
	ld [wAIKindBonus2], a
	ld a, [wAIKindBonus3]
	adc h
	ld [wAIKindBonus3], a
;>         mem16[0xDB51] = total & 0xFFFF; wBattleItemUsedUp = total >> 16
	ld a, [wBattleItemUsedUp]
	adc e
	ld [wBattleItemUsedUp], a

.nextSum:
;=@fs
	ld a, [wBattleArg3]
	ld c, a
	ld a, [wNamePos]
	ld b, a
	inc c
	dec b
;=@fs
	jr nz, .sum

;>@lim limit = (mem16[0xDB51] + wBattleItemUsedUp * 0x10000) // wBattleArg0 // wBattleArg0
	ld a, [wAIKindBonus2]
	ld l, a
	ld a, [wAIKindBonus3]
	ld h, a
	ld a, [wBattleItemUsedUp]
	ld e, a
;=@lim
	ld a, [wBattleArg0]
	call Divide24
	ld a, [wBattleArg0]
	call Divide24
;> wSkillStatusPtr = limit & 0xFFFF
	ld a, l
	ld [wSkillStatusPtr], a
	ld a, h
	ld [wSkillStatusPtr + 1], a
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
;> wBattleArg2 = 0xFF                         # best position so far
	ld a, $ff
	ld [wBattleArg2], a

.pick:
;>@pk for e in range(side, side + 3):
;>     wBattleArg0 = e; wBattleArg1 = side + 3 - e
	ld a, e
	ld [wBattleArg0], a
	ld a, d
	ld [wBattleArg1], a
;>     if CheckBattlerPresent(e):
;>         continue
	ld a, e
	call CheckBattlerPresent
	jr c, .nextPick

;>@hp     hp = GetBattlerHP(e)
;>@fl     if hp == mem16[addr(wBattlerMaxHP) + 2 * e]: continue   # full HP
	ld a, e
	ld hl, wBattlerMaxHP
	add a
	add l
	ld l, a
	ld a, $00
;=@fl
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@hp
	ld a, e
	call GetBattlerHP
;=@fl
	call CompareHLBC
	jr z, .nextPick

;>     if hp == wSkillStatusPtr:
	ld a, [wSkillStatusPtr]
	ld c, a
	ld a, [wSkillStatusPtr + 1]
	ld b, a
	call CompareHLBC
	jr z, .tie

;>@tr         BattleRandom_58()
;>@tq         if wRandomHigh >= 0x80:
;>@tw             wBattleArg2 = e
;>     elif hp < wSkillStatusPtr:
	jr nc, .nextPick

;>         wSkillStatusPtr = hp
	ld a, l
	ld [wSkillStatusPtr], a
	ld a, h
	ld [wSkillStatusPtr + 1], a
;>         wBattleArg2 = e
	ld a, [wBattleArg0]
	ld [wBattleArg2], a
	jr .nextPick

.tie:
;=@tr
	call BattleRandom_58
;=@tq
	ld a, [wRandomHigh]
	cp $80
	jr c, .nextPick

;=@tw
	ld a, [wBattleArg0]
	ld [wBattleArg2], a

.nextPick:
;=@pk
	ld a, [wBattleArg0]
	ld e, a
	ld a, [wBattleArg1]
	ld d, a
	inc e
	dec d
;=@pk
	jr nz, .pick

;> if wBattleArg2 == 0xFF:
	ld a, [wBattleArg2]
	cp $ff
	jr z, .ratio

;>@rt     return AIHealByRatio(side, 3)          # nobody under the limit
;>@st wBattlerAction[2 * wSkillUser + 1] = wBattleArg2
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld a, [wBattleArg2]
	ld [hl], a
	ret


.ratio:
;=@rt
	ld a, [wSkillUser]
	and $04
	ld e, a
	ld d, $03
	jp AIHealByRatio


;@ def AITargetRevive()
;@ path: battle/ai/targets
;@ Target picker of Vivify and Revive: the last of the user's side (slot 2 down to 0) that is out of
;@ action but not empty; the user itself if there is none.
;@ test: wSkillUser = rng.randint(0, 6)
AITargetRevive::
;> c = (wSkillUser & 4) | 2
	ld a, [wSkillUser]
	and $04
	or $02
	ld c, a
;>@lp for c in range(c, c - 3, -1):
	ld b, $03

.loop:
;>     if CheckBattlerPresent(c) and wBattlerState[c] != 0xFF:   # defeated, not empty
;>         break
	ld a, c
	call CheckBattlerPresent
	jr nc, .next

	jr nz, .found

.next:
;=@lp
	dec c
	dec b
	jr nz, .loop

;> else:
;>     c = wSkillUser
	ld a, [wSkillUser]
	ld c, a

.found:
;>@st wBattlerAction[2 * wSkillUser + 1] = c
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld [hl], c
	ret


;@ def AITargetAntidote()
;@ path: battle/ai/targets
;@ Target picker of Antidote: from slot 2 of the user's side down, the first monster with poison
;@ bit 1 of its status byte 0, else (slots 2 and 1 only) one with bit 0; failing both, slot 0. A
;@ dim monster picks at random.
;@ test: wSkillUser = rng.randint(0, 6)
AITargetAntidote::
;> if AIRandomAllyIfDim():
;>     return
	call AIRandomAllyIfDim
	ret z

;> c = (wSkillUser & 4) | 2                    # slot 2 of the user's side
	ld a, [wSkillUser]
	and $04
	or $02
	ld c, a
;> wSkillTarget = c
	ld [wSkillTarget], a
;>@l1 for c in range(c, c - 3, -1):
	ld b, $03

.loop1:
;>     if wBattlerStatus[8 * c] & 0x02:
;>         break
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 1, [hl]
	jr nz, .found

;=@l1
	dec c
	dec b
	jr nz, .loop1

;> else:
;>@l2     for c in range(wSkillTarget, wSkillTarget - 2, -1):
	ld a, [wSkillTarget]
	ld c, a
	ld b, $02

.loop2:
;>         if wBattlerStatus[8 * c] & 0x01:
;>             break
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 0, [hl]
	jr nz, .found

;=@l2
	dec c
	dec b
	jr nz, .loop2

;>     else:
;>         c = wSkillTarget - 2                # slot 0
.found:
;>@st wBattlerAction[2 * wSkillUser + 1] = c
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld [hl], c
	ret


;@ def AITargetTwinHits()
;@ path: battle/ai/targets
;@ Target picker of TwinHits (doubles a monster's attack): the monster of the user's side with the
;@ highest attack that is not doubled yet (score 1 when it is, 0 for an empty position). The scores
;@ are picked with the enemy-side picker and the result flipped over to the own side.
;@ test: skip draws random numbers through the link generator
AITargetTwinHits::
;> if AIRandomAllyIfDim():
;>     return
	call AIRandomAllyIfDim
	ret z

;> side = AIStartScores() ^ 4                    # the user's own side
	call AIStartScores
	ld a, c
	xor $04
	ld c, a

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>         if not wBattlerStatus[8 * c + 1] & 0x04:   # attack not doubled yet
	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
	bit 2, [hl]
	jr nz, .store

;>@at             score = mem16[addr(wBattlerAttack) + 2 * c]
	ld a, c
	ld hl, wBattlerAttack
	add a
	add l
	ld l, a
	ld a, $00
;=@at
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
;> AIFlipTargetSide()
	call AIFlipTargetSide
	ret


;@ def AITargetUpper()
;@ path: battle/ai/targets
;@ Target picker of Upper (raises defense): the monster of the user's side with the lowest defense
;@ that can still go up - below 999 and below its limit: 4 x its normal defense for the player's
;@ monsters (and in link battles), 2 x for enemies and for slot 3. Scores $FFFE for a monster at its
;@ limit, $FFFF for an empty position; ties are broken at random.
;@ test: skip loads monster templates through far calls
AITargetUpper::
;> if AIRandomAllyIfDim():
;>     return
	call AIRandomAllyIfDim
	ret z

;> wBattleArg0 = lo(addr(wSkillStatusPtr)); wBattleArg1 = hi(addr(wSkillStatusPtr))   # score pointer
	ld hl, wSkillStatusPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;> wBattleArg2 = wSkillUser & 4                 # position being scored
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
;>@lp for _ in range(3):
	ld b, $03

.loop:
;>     if not CheckBattlerPresent(wBattleArg2):
	push bc
	ld a, [wBattleArg2]
	call CheckBattlerPresent
	jr c, .none

;>         limit = GetBaseDefense_58(wBattleArg2)
	ld a, [wBattleArg2]
	call GetBaseDefense_58
;>         defense = GetBattlerDefense(wBattleArg2)
	ld a, [wBattleArg2]
	call GetBattlerDefense
;>@dbl         if (wLinkActive or wSkillUser < 4) and (wBattleArg2 & 3) != 3:
	ld a, [wLinkActive]
	or a
	jr nz, .ownSide

	ld a, [wSkillUser]
	cp $04
	jr nc, .double

.ownSide:
;=@dbl
	ld a, [wBattleArg2]
	and $03
	cp $03
	cp $03
	jr z, .double

;>             limit *= 2
	sla c
	rl b

.double:
;>         limit *= 2
	sla c
	rl b
;>         if defense >= limit or defense >= 999:
	call CompareHLBC
	jr nc, .atLimit

	ld bc, $03e7
	call CompareHLBC
	jr nc, .atLimit

;>@ft             score = 0xFFFE
;>         else:
;>             score = defense
	jr .store

.atLimit:
;=@ft
	ld hl, hLoopPosHi
	jr .store

.none:
;>     else:
;>         score = 0xFFFF
	ld hl, $ffff

.store:
;>@w     mem16[addr(wBattleArg0) + 256 * wBattleArg1] = score
	push hl
	pop de
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
;=@w
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
;>     wBattleArg0 += 2                          # 16-bit pointer with wBattleArg1
;>@nx     wBattleArg2 += 1
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	pop bc
;=@nx
	ld hl, wBattleArg2
	inc [hl]
;=@lp
	dec b
	jr nz, .loop

;>@lo low = wSkillStatusPtr
	ld hl, wSkillStatusPtr
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> wBattleArg0 = lo(addr(wStatPtr)); wBattleArg1 = hi(addr(wStatPtr))   # the second score
	ld hl, wStatPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;> wBattleArg2 = wSkillUser & 4                 # best position so far
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
;> wBattleArg3 = wBattleArg2 + 1; wNamePos = 2
	inc a
	ld [wBattleArg3], a
	ld a, $02
	ld [wNamePos], a

.pick:
;>@pk while wNamePos:
;>@sc     s = mem16[addr(wBattleArg0) + 256 * wBattleArg1]
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@sc
	ld l, a
;>     take = s < low
	call CompareHLBC
	jr c, .take

;>     if s == low:
	jr nz, .next

;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>         low = s; wBattleArg2 = wBattleArg3
	push hl
	pop bc
	ld a, [wBattleArg3]
	ld [wBattleArg2], a

.next:
;>@ad     wBattleArg0 += 2                          # 16-bit pointer with wBattleArg1
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	inc hl
	inc hl
;=@ad
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;>     wBattleArg3 += 1; wNamePos -= 1
	ld hl, wBattleArg3
	inc [hl]
	ld hl, wNamePos
	dec [hl]
;=@pk
	ld a, [wNamePos]
	or a
	jr nz, .pick

;> wSkillTarget = wBattleArg2
	ld a, [wBattleArg2]
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AITargetSap()
;@ path: battle/ai/targets
;@ Target picker of Sap (lowers defense): the enemy with the highest score - 0 for an empty position,
;@ 1 when its defense is already 0 or 1, 2 when it would bounce the spell back (Bounce, MagicBack),
;@ else its defense with the weakness against Sap (3 - resistance, bits 4-5 of resistance byte 3) on
;@ top, so the least resistant enemy comes first and the strongest defense next.
;@ test: skip far calls into the resistance table
AITargetSap::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>         defense = GetBattlerDefense(c)
	ld a, c
	call GetBattlerDefense
;>         if not ((defense & 0xFF) == 0 or defense == 1):
	cp $01
	jr c, .store

	jr nz, .high

	ld a, h
	or a
	jr z, .store

.high:
;>             score = 2
	inc de
;>@rf             if not wBattlerStatus[8 * c + 2] & 0x22:   # no Bounce / MagicBack
	push hl
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	pop hl
;=@rf
	and $22
	jr nz, .store

;>                 wBattleArg0 = 3; wSkillTarget = c
	push hl
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>                 GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>                 score = defense | ((wBattleArg0 ^ 0x30) & 0x30) << 8
	ld a, [wBattleArg0]
	xor $30
	and $30
	pop de
	or d
	ld d, a
;=@lp
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetSlow()
;@ path: battle/ai/targets
;@ Target picker of Slow (lowers agility), like AITargetSap with agility and the resistance in bits
;@ 2-3 of resistance byte 3. Only an agility whose low byte is 0 counts as already at the bottom; for
;@ a low byte of 1 the code overwrites the high byte with 1.
;@ test: skip far calls into the resistance table
AITargetSlow::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>@ag         agility = mem16[addr(wBattlerAgility) + 2 * c]
	ld a, c
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;=@ag
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@lw         if (agility & 0xFF) != 0:
	cp $01
	jr c, .store

;>             if (agility & 0xFF) == 1:
;>                 agility = 0x0101
	jr nz, .high

	ld h, a
;=@lw
	or a
	jr z, .store

.high:
;>             score = 2
	inc de
;>@rf             if not wBattlerStatus[8 * c + 2] & 0x22:   # no Bounce / MagicBack
	push hl
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	pop hl
;=@rf
	and $22
	jr nz, .store

;>                 wBattleArg0 = 3; wSkillTarget = c
	push hl
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>                 GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>@rs                 score = agility | (((wBattleArg0 << 2) ^ 0x30) & 0x30) << 8
	ld a, [wBattleArg0]
	rlca
	rlca
	xor $30
	and $30
	pop de
;=@rs
	or d
	ld d, a
;=@lp
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetSpeed()
;@ path: battle/ai/targets
;@ Target picker of Speed (raises agility), like AITargetUpper with agility: the monster of the
;@ user's side with the lowest agility below 511 and below its limit (4 x / 2 x its normal agility).
;@ test: skip loads monster templates through far calls
AITargetSpeed::
;> if AIRandomAllyIfDim():
;>     return
	call AIRandomAllyIfDim
	ret z

;> wBattleArg0 = lo(addr(wSkillStatusPtr)); wBattleArg1 = hi(addr(wSkillStatusPtr))   # score pointer
	ld hl, wSkillStatusPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;> wBattleArg2 = wSkillUser & 4                 # position being scored
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
;>@lp for _ in range(3):
	ld b, $03

.loop:
;>     if not CheckBattlerPresent(wBattleArg2):
	push bc
	ld a, [wBattleArg2]
	call CheckBattlerPresent
	jr c, .none

;>         limit = GetBaseAgility_58(wBattleArg2)
	ld a, [wBattleArg2]
	call GetBaseAgility_58
;>@ag         agility = mem16[addr(wBattlerAgility) + 2 * wBattleArg2]
	ld a, [wBattleArg2]
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;=@ag
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>         if agility >= 511:
;>@m1             score = 0xFFFE
	push bc
	ld bc, $01ff
	call CompareHLBC
	pop bc
	jr nc, .atLimit

;>         else:
;>@dbl             if (wLinkActive or wSkillUser < 4) and (wBattleArg2 & 3) != 3:
	ld a, [wLinkActive]
	or a
	jr nz, .ownSide

	ld a, [wSkillUser]
	cp $04
	jr nc, .double

.ownSide:
;=@dbl
	ld a, [wBattleArg2]
	and $03
	cp $03
	jr z, .double

;>                 limit *= 2
	sla c
	rl b

.double:
;>             limit *= 2
	sla c
	rl b
;>             if agility >= limit:
;>@m2                 score = 0xFFFE
	call CompareHLBC
	jr nc, .atLimit

;>             else:
;>                 score = agility
	jr .store

.atLimit:
;=@m1
	ld hl, hLoopPosHi
	jr .store

.none:
;>     else:
;>         score = 0xFFFF
	ld hl, $ffff

.store:
;>@w     mem16[addr(wBattleArg0) + 256 * wBattleArg1] = score
	push hl
	pop de
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
;=@w
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
;>     wBattleArg0 += 2                          # 16-bit pointer with wBattleArg1
;>@nx     wBattleArg2 += 1
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
	pop bc
;=@nx
	ld hl, wBattleArg2
	inc [hl]
;=@lp
	dec b
	jr nz, .loop

;>@lo low = wSkillStatusPtr
	ld hl, wSkillStatusPtr
	ld a, [hli]
	ld b, [hl]
	ld c, a
;> wBattleArg0 = lo(addr(wStatPtr)); wBattleArg1 = hi(addr(wStatPtr))   # the second score
	ld hl, wStatPtr
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;> wBattleArg2 = wSkillUser & 4                 # best position so far
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg2], a
;> wBattleArg3 = wBattleArg2 + 1; wNamePos = 2
	inc a
	ld [wBattleArg3], a
	ld a, $02
	ld [wNamePos], a

.pick:
;>@pk while wNamePos:
;>@sc     s = mem16[addr(wBattleArg0) + 256 * wBattleArg1]
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	ld a, [hli]
	ld h, [hl]
;=@sc
	ld l, a
;>     take = s < low
	call CompareHLBC
	jr c, .take

;>     if s == low:
	jr nz, .next

;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>         low = s; wBattleArg2 = wBattleArg3
	push hl
	pop bc
	ld a, [wBattleArg3]
	ld [wBattleArg2], a

.next:
;>@ad     wBattleArg0 += 2                          # 16-bit pointer with wBattleArg1
	ld a, [wBattleArg0]
	ld l, a
	ld a, [wBattleArg1]
	ld h, a
	inc hl
	inc hl
;=@ad
	ld a, l
	ld [wBattleArg0], a
	ld a, h
	ld [wBattleArg1], a
;>     wBattleArg3 += 1; wNamePos -= 1
	ld hl, wBattleArg3
	inc [hl]
	ld hl, wNamePos
	dec [hl]
;=@pk
	ld a, [wNamePos]
	or a
	jr nz, .pick

;> wSkillTarget = wBattleArg2
	ld a, [wBattleArg2]
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AITargetUltraDown()
;@ path: battle/ai/targets
;@ Target picker of UltraDown (lowers agility and defense): gives each enemy a key - $FF empty, $FE
;@ when its agility or defense is already 0 or 1, else its resistance (bits 4-5 of resistance byte
;@ 2) - and takes the lowest key (AIPickLowestKey).
;@ test: skip far calls into the resistance table
AITargetUltraDown::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> mem[addr(wNamePos) + 0] = 0; mem[addr(wNamePos) + 1] = 0; mem[addr(wNamePos) + 2] = 0   # the keys
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

.loop:
;>@lp for c in range(side, side + 3):
;>     if CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@k0         key = 0xFF
;>@el     elif IsAtMostOne(mem16[addr(wBattlerAgility) + 2 * c]) or IsAtMostOne(GetBattlerDefense(c)):
	ld a, c
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;=@el
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call IsAtMostOne
;=@el
	jr c, .low

	ld a, c
	call GetBattlerDefense
	call IsAtMostOne
	jr c, .low

;>@k1         key = 0xFE
;>     else:
;>         wBattleArg0 = 2; wSkillTarget = c
	push bc
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>@kr         key = wBattleArg0 & 0x30
;>@ks     mem[addr(wNamePos) + (c & 3)] = key
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@kr
	ld a, [wBattleArg0]
	and $30
;=@ks
	ld [hl], a
	jr .next

.low:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k1
	ld a, $fe
;=@ks
	ld [hl], a
	jr .next

.none:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k0
	ld a, $ff
;=@ks
	ld [hl], a

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;>@w1 wBattleArg0 = side; wBattleArg1 = mem[addr(wNamePos) + (side & 3)]   # first as the best so far
	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
;=@w1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@w1
	ld [wBattleArg1], a
;> AIPickLowestKey(side + 1, 2)
	inc c
	dec b
	call AIPickLowestKey
	ret


;@ def AITargetCover()
;@ path: battle/ai/targets
;@ Target picker of Cover (shields an ally): the other monster of the user's side with the lowest
;@ HP (a metal monster counts 512 more); the user itself when nobody else is there.
;@ test: skip draws random numbers through the link generator
AITargetCover::
;> if AIRandomAllyIfDim():
;>     return
	call AIRandomAllyIfDim
	ret z

;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
;> wSkillTarget = side
	ld [wSkillTarget], a
	ld c, a
	ld b, $03

.loop:
;>@lp for c in range(side, side + 3):
;>@ab     if CheckBattlerPresent(c) or c == wSkillUser:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;=@ab
	ld a, [wSkillUser]
	cp c
	jr z, .none

;>@hp         score = 0xFFFF
;>     else:
;>         score = GetBattlerHP(c)
	ld a, c
	call GetBattlerHP
;>@mt         if wBattlerTypeBits[c] & 0x01:       # metal
	push hl
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
;=@mt
	adc h
	ld h, a
	bit 0, [hl]
	pop hl
	jr z, .store

;>             score += 0x200
	ld bc, $0200
	add hl, bc
	jr .store

.none:
;=@hp
	ld hl, $ffff

.store:
;>@w     mem16[addr(wTargetScores) + 2 * (c & 3)] = score
	ld d, h
	ld e, l
	pop bc
	ld a, c
	and $03
	ld hl, wTargetScores
;=@w
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@w
	ld a, e
	ld [hli], a
	ld [hl], d
;=@lp
	inc c
	dec b
	jr nz, .loop

;> AIPickLowestOwnScore()
	call AIPickLowestOwnScore
;>@t t = addr(wBattlerAction) + 2 * wSkillUser + 1
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@t
	adc h
	ld h, a
;> if CheckBattlerPresent(mem[t]):
	ld a, [hl]
	push hl
	call CheckBattlerPresent
	pop hl
	ret nc

;>     mem[t] = wSkillUser                        # nobody to cover: the user itself
	ld a, [wSkillUser]
	ld [hl], a
	ret


;@ def AITargetMouthShut()
;@ path: battle/ai/targets
;@ Target picker of MouthShut (stops breath attacks): the enemy with the highest score - 0 empty, 1
;@ when it knows no breath skill (KnowsBreathSkill) or its mouth is already bound, else $FF with the
;@ weakness (3 - resistance, bits 6-7 of resistance byte 6) in the high byte.
;@ test: skip far calls into the resistance table
AITargetMouthShut::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>@bs         if KnowsBreathSkill(c) and not wBattlerStatus[8 * c + 1] & 0x80:
	ld a, c
	call KnowsBreathSkill
	jr nc, .store

	ld a, c
	ld hl, wBattlerStatus1
	call AddEightTimes
;=@bs
	bit 7, [hl]
	jr nz, .store

;>             wBattleArg0 = 6; wSkillTarget = c
	ld de, $00ff
	push de
	ld a, $06
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>             GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>             score = 0xFF | ((wBattleArg0 ^ 0xC0) & 0xC0) << 8
	ld a, [wBattleArg0]
	xor $c0
	and $c0
	pop de
	or d
	ld d, a
;=@lp
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetSickLick()
;@ path: battle/ai/targets
;@ Target picker of SickLick (lowers defense and stuns): keys per enemy - $FF empty, $FD defense
;@ already 0 or 1, $FE already asleep / paralysed or held by another effect (bits $C0 of status byte
;@ 0, $3F of byte 3), else the resistance (bits 4-5 of resistance byte 3); the lowest key wins.
;@ test: skip far calls into the resistance table
AITargetSickLick::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> mem[addr(wNamePos) + 0] = 0; mem[addr(wNamePos) + 1] = 0; mem[addr(wNamePos) + 2] = 0   # the keys
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

.loop:
;>@lp for c in range(side, side + 3):
;>     if CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, .none

;>@k0         key = 0xFF
;>@el     elif ((d := GetBattlerDefense(c)) & 0xFF) == 0 or d == 1:
	ld a, c
	call GetBattlerDefense
	cp $01
	jr c, .low

	jr nz, .high

;=@el
	ld a, h
	or a
	jr z, .low

.high:
;>@k1         key = 0xFD
;>@e2     elif wBattlerStatus[8 * c] & 0xC0 or wBattlerStatus[8 * c + 3] & 0x3F:
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $c0
	jr nz, .held

;=@e2
	inc hl
	inc hl
	ld a, [hl]
	and $3f
	jr nz, .held

;>@k2         key = 0xFE
;>     else:
;>         wBattleArg0 = 3; wSkillTarget = c
	push bc
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>@kr         key = wBattleArg0 & 0x30
;>@ks     mem[addr(wNamePos) + (c & 3)] = key
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@kr
	ld a, [wBattleArg0]
	and $30
;=@ks
	ld [hl], a
	jr .next

.low:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k1
	ld a, $fd
;=@ks
	ld [hl], a
	jr .next

.held:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k2
	ld a, $fe
;=@ks
	ld [hl], a
	jr .next

.none:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k0
	ld a, $ff
;=@ks
	ld [hl], a

.next:
;=@lp
	inc c
	dec b
	jp nz, .loop

;>@w1 wBattleArg0 = side; wBattleArg1 = mem[addr(wNamePos) + (side & 3)]   # first as the best so far
	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
;=@w1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@w1
	ld [wBattleArg1], a
;> AIPickLowestKey(side, 3)                      # (compares the first with itself, too)
	call AIPickLowestKey
	ret


;@ def AITargetLegSweep()
;@ path: battle/ai/targets
;@ Target picker of LegSweep: the enemy with the highest score - 0 empty, 1 for a monster that
;@ cannot be tripped (bit 4 of wBattlerTypeBits), 2 when it is already held (bits $D0 of status byte
;@ 0, $3F of byte 3), else $FF with the weakness (bits 2-3 of resistance byte 5) in the high byte.
;@ test: skip far calls into the resistance table
AITargetLegSweep::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@ty         score = 1
;>         if not wBattlerTypeBits[c] & 0x10:
	ld de, $0001
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
;=@ty
	adc h
	ld h, a
	bit 4, [hl]
	jr nz, .store

;>             score = 2
	ld de, $0002
;>@hd             if not (wBattlerStatus[8 * c] & 0xD0 or wBattlerStatus[8 * c + 3] & 0x3F):
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $d0
	jr nz, .store

;=@hd
	inc hl
	inc hl
	ld a, [hl]
	and $3f
	jr nz, .store

;>                 wBattleArg0 = 5; wSkillTarget = c
	ld de, $00ff
	push de
	ld a, $05
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>                 GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>                 score = 0xFF | ((wBattleArg0 ^ 0x0C) & 0x0C) << 8
	ld a, [wBattleArg0]
	xor $0c
	and $0c
	pop de
	or d
	ld d, a
;=@lp
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetNapAttack()
;@ path: battle/ai/targets
;@ Target picker of NapAttack: the enemy with the highest score - 0 empty, 1 already asleep (bit 7
;@ of status byte 0), else $FF with the weakness (bits 6-7 of resistance byte 2) in the high byte.
;@ An enemy monster that is not smart aims like a plain attack instead (AIAimPlainInstead).
;@ test: skip far calls into the resistance table
AITargetNapAttack::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>         if not wBattlerStatus[8 * c] & 0x80:        # not asleep
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 7, [hl]
	jr nz, .store

;>             wBattleArg0 = 2; wSkillTarget = c
	ld hl, $00ff
	push hl
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>             GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>             score = 0xFF | ((wBattleArg0 ^ 0xC0) & 0xC0) << 8
	ld a, [wBattleArg0]
	xor $c0
	and $c0
	pop de
	or d
	ld d, a
;=@lp
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetOddDance()
;@ path: battle/ai/targets
;@ Target picker of OddDance and RobDance (take MP): the enemy with the highest score - 0 when empty
;@ or out of MP, else 1 with the weakness (bits 2-3 of resistance byte 2, moved to bits 12-13) on top.
;@ test: skip far calls into the resistance table
AITargetOddDance::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>@mp     if not CheckBattlerPresent(c) and mem16[addr(wBattlerMP) + 2 * c]:
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

	ld a, c
	ld hl, wBattlerMP
;=@mp
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@mp
	ld a, [hli]
	or [hl]
	jr z, .none

;>         wBattleArg0 = 2; wSkillTarget = c
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>@rs         score = 1 | (((wBattleArg0 << 2) ^ 0x30) & 0x30) << 8
	ld de, $0001
	ld a, [wBattleArg0]
	rlca
	rlca
	xor $30
	and $30
;=@rs
	or d
	ld d, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetMetalCut()
;@ path: battle/ai/targets
;@ Target picker of MetalCut: the metal enemy (bit 0 of wBattlerTypeBits) with the lowest HP (score =
;@ HP inverted); 1 for any other monster, 0 for an empty position; the highest score wins.
;@ test: skip draws random numbers through the link generator
AITargetMetalCut::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@mt         score = 1
;>         if wBattlerTypeBits[c] & 0x01:           # metal
	ld de, $0001
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
;=@mt
	adc h
	ld h, a
	bit 0, [hl]
	jr z, .store

;>@hp             score = mem16[addr(wBattlerHP) + 2 * c] ^ 0xFFFF
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	xor $ff
	ld e, a
	ld a, [hl]
;=@hp
	xor $ff
	ld d, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetDrakSlash()
;@ path: battle/ai/targets
;@ Target picker of DrakSlash, strong against the dragon family (1): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetDrakSlash::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 1                            # the family
	ld a, $01
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetBeastCut()
;@ path: battle/ai/targets
;@ Target picker of BeastCut, strong against the beast family (2): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetBeastCut::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 2                            # the family
	ld a, $02
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetBirdBlow()
;@ path: battle/ai/targets
;@ Target picker of BirdBlow, strong against the bird family (3): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetBirdBlow::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 3                            # the family
	ld a, $03
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetDevilCut()
;@ path: battle/ai/targets
;@ Target picker of DevilCut, strong against the devil family (6): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetDevilCut::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 6                            # the family
	ld a, $06
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetZombieCut()
;@ path: battle/ai/targets
;@ Target picker of ZombieCut, strong against the zombie family (7): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetZombieCut::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 7                            # the family
	ld a, $07
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetCleanCut()
;@ path: battle/ai/targets
;@ Target picker of CleanCut, strong against the material family (8): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetCleanCut::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 8                            # the family
	ld a, $08
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetSmashlime()
;@ path: battle/ai/targets
;@ Target picker of Smashlime, strong against the slime family (0): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetSmashlime::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 0                            # the family
	ld a, $00
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetSheldodge()
;@ path: battle/ai/targets
;@ Target picker of Sheldodge, strong against the bug family (5): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetSheldodge::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 5                            # the family
	ld a, $05
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetBranching()
;@ path: battle/ai/targets
;@ Target picker of Branching, strong against the plant family (4): the enemy of that family
;@ with the lowest HP (AIScoreFamily).
;@ test: skip far calls into the monster table
AITargetBranching::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = AIStartScores()
	call AIStartScores
;> wBattleArg0 = 4                            # the family
	ld a, $04
	ld [wBattleArg0], a
;> AIScoreFamily(side, 3)
	call AIScoreFamily
	ret


;@ def AITargetPoisonHit()
;@ path: battle/ai/targets
;@ Target picker of PoisonHit: the enemy with the highest score - 0 empty, 1 already poisoned (bits
;@ 0-1 of status byte 0), else $FF with the weakness (3 - bits 0-1 of resistance byte 4) in the high
;@ byte. An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetPoisonHit::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>         if not wBattlerStatus[8 * c] & 0x03:        # not poisoned yet
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $03
	jr nz, .store

;>             wBattleArg0 = 4; wSkillTarget = c
	ld de, $00ff
	push de
	ld a, $04
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>             GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>             score = 0xFF | ((wBattleArg0 & 0x03) ^ 0x03) << 8
	ld a, [wBattleArg0]
	and $03
	xor $03
	pop de
	ld d, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetParalyze()
;@ path: battle/ai/targets
;@ Target picker of Paralyze: the enemy with the highest score - 0 empty, 1 already asleep, paralysed
;@ or the like (bits $CC of status byte 0), else $FF with the weakness (bits 6-7 of resistance byte
;@ 5) in the high byte. An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetParalyze::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>         if not wBattlerStatus[8 * c] & 0xCC:
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hl]
	and $cc
	jr nz, .store

;>             wBattleArg0 = 5; wSkillTarget = c
	ld de, $00ff
	push de
	ld a, $05
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>             GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>             score = 0xFF | ((wBattleArg0 & 0xC0) ^ 0xC0) << 8
	ld a, [wBattleArg0]
	and $c0
	xor $c0
	pop de
	ld d, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetAhhh()
;@ path: battle/ai/targets
;@ Target picker of Ahhh and LushLicks: the enemy with the highest score - 0 empty, 1 already held
;@ (bits $D0 of status byte 0, $3F of byte 3), else $FF with the weakness (bits 2-3 of resistance
;@ byte 5) in the high byte. An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetAhhh::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScores()
	call AIStartScores

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>@hd         if not (wBattlerStatus[8 * c] & 0xD0 or wBattlerStatus[8 * c + 3] & 0x3F):
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $d0
	jr nz, .store

;=@hd
	inc hl
	inc hl
	ld a, [hl]
	and $3f
	jr nz, .store

;>             wBattleArg0 = 5; wSkillTarget = c
	ld de, $00ff
	push de
	ld a, $05
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>             GetResistByte()
	ld hl, far_GetResistByte
	rst $10
;>             score = 0xFF | ((wBattleArg0 & 0x0C) ^ 0x0C) << 8
	ld a, [wBattleArg0]
	and $0c
	xor $0c
	pop de
	ld d, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def AITargetTransform()
;@ path: battle/ai/targets
;@ Target picker of Transform (the user turns into a copy of the target): the enemy with the largest
;@ maximum HP + maximum MP (24 bits in wSkillAmount and the low byte of wTargetScores); on a tie the
;@ later one.
;@ test: wSkillUser = rng.randint(0, 6)
AITargetTransform::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> wBattleArg0 = (wSkillUser & 4) ^ 4            # best so far: the first enemy
	ld a, [wSkillUser]
	and $04
	xor $04
	ld [wBattleArg0], a
;> wBattleArg1 = wBattleArg0 + 1; wBattleArg2 = 2   # candidate, candidates left
	inc a
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
;> if not CheckBattlerPresent(wBattleArg0):
	ld a, [wBattleArg0]
	call CheckBattlerPresent
	jr c, .none0

;>@b0     best = mem16[addr(wBattlerMaxHP) + 2 * wBattleArg0] + mem16[addr(wBattlerMaxMP) + 2 * wBattleArg0]
	ld hl, wBattlerMaxHP
	ld a, [wBattleArg0]
	add a
	add l
	ld l, a
	ld a, $00
;=@b0
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@b0
	ld hl, wBattlerMaxMP
	ld a, [wBattleArg0]
	add a
	add l
	ld l, a
	ld a, $00
;=@b0
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
;=@b0
	call Add16To24
	jr .save0

.none0:
;> else:
;>     best = 0
	ld bc, $0000
	ld e, $00

.save0:
;>@sv wSkillAmount = best & 0xFFFF; mem[addr(wTargetScores)] = best >> 16
	ld hl, wSkillAmount
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
;=@sv
	ld [hl], a

.loop:
;>@lp while True:
;>     if not CheckBattlerPresent(wBattleArg1):
	ld a, [wBattleArg1]
	call CheckBattlerPresent
	jr c, .none

;>@s1         s = mem16[addr(wBattlerMaxHP) + 2 * wBattleArg1] + mem16[addr(wBattlerMaxMP) + 2 * wBattleArg1]
	ld hl, wBattlerMaxHP
	ld a, [wBattleArg1]
	add a
	add l
	ld l, a
	ld a, $00
;=@s1
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;=@s1
	ld hl, wBattlerMaxMP
	ld a, [wBattleArg1]
	add a
	add l
	ld l, a
	ld a, $00
;=@s1
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
;=@s1
	call Add16To24
	jr .compare

.none:
;>     else:
;>         s = 0
	ld bc, $0000
	ld e, $00

.compare:
;>@cm     if s >= wSkillAmount + (mem[addr(wTargetScores)] << 16):
	ld hl, wTargetScores
	ld a, e
	cp [hl]
	jr c, .next

	jr nz, .take

;=@cm
	dec hl
	ld a, b
	cp [hl]
	jr c, .next

	jr nz, .take

;=@cm
	dec hl
	ld a, c
	cp [hl]
	jr c, .next

.take:
;>@tk         wSkillAmount = s & 0xFFFF; mem[addr(wTargetScores)] = s >> 16
	ld hl, wSkillAmount
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
;=@tk
	ld [hl], a
;>         wBattleArg0 = wBattleArg1
	ld a, [wBattleArg1]
	ld [wBattleArg0], a

.next:
;>     wBattleArg1 += 1; wBattleArg2 -= 1
	ld hl, wBattleArg1
	inc [hl]
	ld hl, wBattleArg2
	dec [hl]
;>     if not wBattleArg2:
;>         break
	ld a, [wBattleArg2]
	or a
;=@lp
	jp nz, .loop

;> wSkillTarget = wBattleArg0
	ld a, [wBattleArg0]
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AIMetalPenalty(pos: c)
;@ path: battle/ai/targets
;@ For a metal monster at `pos` (bit 0 of wBattlerTypeBits) multiplies the score in wSkillAmount by
;@ 50, so that a weapon attack aims at it last.
;@ test: pos = rng.randint(0, 7)
AIMetalPenalty::
;>@mt if wBattlerTypeBits[pos] & 0x01:
	ld a, c
	ld hl, wBattlerTypeBits
	add l
	ld l, a
	ld a, $00
	adc h
;=@mt
	ld h, a
	bit 0, [hl]
	ret z

;>@ml     wSkillAmount = (50 * wSkillAmount) & 0xFFFF
	push af
	push bc
	push de
	push hl
	ld a, [wSkillAmount]
	ld c, a
;=@ml
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, $32
	call Multiply24
	ld a, l
	ld [wSkillAmount], a
;=@ml
	ld a, h
	ld [wSkillAmount + 1], a
;=@ml
	pop hl
	pop de
	pop bc
	pop af
	ret


;@ def AITargetBeat()
;@ path: battle/ai/targets
;@ Target picker of Beat (a death spell): gives each enemy a key - its resistance (bits 4-5 of
;@ resistance byte 2), +$40 when it would reflect the spell, $FF for an empty position - and its HP
;@ as the score; the lowest key wins, between equal keys the highest HP (AIPickBestKeyHighScore).
;@ An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetBeat::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         wBattleArg0 = 2; wSkillTarget = c
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
	push bc
;>@k         mem[addr(wNamePos) + (c & 3)] = wBattleArg0 & 0x30
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
;=@k
	adc d
	ld d, a
	ld a, [wBattleArg0]
	and $30
	ld [de], a
;>         if CheckReflects(c):
;>             mem[addr(wNamePos) + (c & 3)] |= 0x40
	push de
	call CheckReflects
	pop hl
	jr z, .hp

	set 6, [hl]

.hp:
;>@hp         score = mem16[addr(wBattlerHP) + 2 * c]
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr .store

.none:
;>@no     else:
;>@n1         mem[addr(wNamePos) + (c & 3)] = 0xFF
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
;=@n1
	adc d
	ld d, a
	ld a, $ff
	ld [de], a
;>         score = 0
	ld de, $0000

.store:
;>@w     mem16[wNameDest] = score; wNameDest += 2
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, e
	ld [hli], a
;=@w
	ld a, d
	ld [hl], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
;=@w
	adc $00
	ld [wNameDest + 1], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
;=@w
	adc $00
	ld [wNameDest + 1], a
;=@lp
	pop bc
	inc c
	dec b
	jp nz, .loop

;> AIPickBestKeyHighScore()
	call AIPickBestKeyHighScore
;> AISetTargetFromBest()
	call AISetTargetFromBest
	ret


;@ def AITargetBlaze()
;@ path: battle/ai/targets
;@ Target picker of Blaze, Blazemore and Blazemost: like AITargetBeat with the fire resistance (bits
;@ 4-5 of resistance byte 0) as the key and the lowest HP winning between equal keys ($FFFF for an
;@ empty position).
;@ test: skip far calls into the resistance table
AITargetBlaze::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         wBattleArg0 = 0; wSkillTarget = c
	ld a, $00
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
	push bc
;>@k         mem[addr(wNamePos) + (c & 3)] = wBattleArg0 & 0x30
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
;=@k
	adc d
	ld d, a
	ld a, [wBattleArg0]
	and $30
	ld [de], a
;>         if CheckReflects(c):
;>             mem[addr(wNamePos) + (c & 3)] |= 0x40
	push de
	call CheckReflects
	pop hl
	jr z, .hp

	set 6, [hl]

.hp:
;>@hp         score = mem16[addr(wBattlerHP) + 2 * c]
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr .store

.none:
;>@no     else:
;>@n1         mem[addr(wNamePos) + (c & 3)] = 0xFF
	ld a, c
	and $03
	ld de, wNamePos
	add e
	ld e, a
	ld a, $00
;=@n1
	adc d
	ld d, a
	ld a, $ff
	ld [de], a
;>         score = 0xFFFF
	ld de, $ffff

.store:
;>@w     mem16[wNameDest] = score; wNameDest += 2
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, e
	ld [hli], a
;=@w
	ld a, d
	ld [hl], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
;=@w
	adc $00
	ld [wNameDest + 1], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
;=@w
	adc $00
	ld [wNameDest + 1], a
;=@lp
	pop bc
	inc c
	dec b
	jp nz, .loop

;> AIPickBestKeyLowScore()
	call AIPickBestKeyLowScore
;> AISetTargetFromBest()
	call AISetTargetFromBest
	ret


;@ def AITargetRamming()
;@ path: battle/ai/targets
;@ Target picker of Ramming and Kamikaze: the enemy with the highest HP that is not dodging (Dodge)
;@ and not in the Defence or BladeD stance (score 1 then, 0 for an empty position).
;@ An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip draws random numbers through the link generator
AITargetRamming::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wNamePos = 0; mem16[0xDB51] = 0; wBattleItemUsedUp = 0   # the keys: all equal
	xor a
	ld [wNamePos], a
	ld [wAIKindBonus2], a
	ld [wAIKindBonus3], a
	ld [wBattleItemUsedUp], a

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>         score = 1
	ld de, $0001
;>@dg         if not wBattlerStatus[8 * c + 6] & 0x20 and not wBattlerStatus[8 * c + 7] & 0x05:
	ld a, c
	ld hl, wBattlerStatus6
	call AddEightTimes
	bit 5, [hl]
	jr nz, .store

;=@dg
	inc hl
	ld a, [hl]
	and $05
	jr nz, .store

;>@hp             score = mem16[addr(wBattlerHP) + 2 * c]
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr .store

.none:
;>     else:
;>         score = 0
	ld de, $0000

.store:
;>@w     mem16[wNameDest] = score; wNameDest += 2
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld [hl], e
	inc hl
;=@w
	ld [hl], d
	inc hl
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;=@lp
	inc c
	dec b
	jr nz, .loop

;> AIPickBestKeyHighScore()
	call AIPickBestKeyHighScore
;> AISetTargetFromBest()
	call AISetTargetFromBest
	ret


;@ def AITargetLife()
;@ path: battle/ai/targets
;@ Target picker of skill $DA (LIFE, an enemy-only skill): in link battles and for the player's
;@ monsters the whole enemy side; otherwise the player's monster with the lowest key - $FF empty, $FE
;@ with bit 4 of status byte 0 set, else bits 6-7 of resistance byte 3 - a tie decided at random.
;@ test: skip far calls into the resistance table
AITargetLife::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> if wLinkActive or wSkillUser < 4:
;>     return AITargetEnemySide()
	ld a, [wLinkActive]
	or a
	jp nz, AITargetEnemySide

	ld a, [wSkillUser]
	cp $04
	jp c, AITargetEnemySide

;> c = AIStartScoresAlt()                         # the player's side
	call AIStartScoresAlt
;> wNameBattler = c                                # best so far
	ld a, c
	ld [wNameBattler], a
;> if CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none0

;>@k0     key = 0xFF
;> elif wBattlerStatus[8 * c] & 0x10:
	ld d, $fe
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, .save0

;>     key = 0xFE
;> else:
;>     wBattleArg0 = 3; wSkillTarget = c
	push bc
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>     GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>     key = wBattleArg0 & 0xC0
	ld a, [wBattleArg0]
	and $c0
	ld d, a
	jr .save0

.none0:
;=@k0
	ld d, $ff

.save0:
;> wNamePos = key; wNameBattler = c               # the best key so far
	ld a, d
	ld [wNamePos], a
	ld a, c
	ld [wNameBattler], a
;>@lp for c in range(c + 1, c + 3):
	inc c
	dec b

.loop:
;>     if CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@n1         key = 0xFF
;>     elif wBattlerStatus[8 * c] & 0x10:
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	bit 4, [hl]
	jr nz, .held

;>@h1         key = 0xFE
;>     else:
;>         wBattleArg0 = 3; wSkillTarget = c
	push bc
	ld a, $03
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>         key = wBattleArg0 & 0xC0
	ld a, [wBattleArg0]
	and $c0
	jr .compare

.held:
;=@h1
	ld a, $fe
	jr .compare

.none:
;=@n1
	ld a, $ff

.compare:
;>     take = key < wNamePos
	ld d, a
	ld hl, wNamePos
	cp [hl]
	jr c, .take

;>     if key == wNamePos:
	jr nz, .next

;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>         wNamePos = key; wNameBattler = c
	ld a, d
	ld [wNamePos], a
	ld a, c
	ld [wNameBattler], a

.next:
;=@lp
	inc c
	dec b
	jp nz, .loop

;> AISetTargetFromBest()
	call AISetTargetFromBest
	ret


;@ def AITargetSleep()
;@ path: battle/ai/targets
;@ Target picker of Sleep: keys per enemy - $FF empty, $FE already asleep or paralysed (bits $C0 of
;@ status byte 0), bouncing spells back (Bounce, MagicBack) or held by another effect (bits $3F of
;@ byte 3), else the resistance (bits 6-7 of resistance byte 2); the lowest key wins. An enemy
;@ monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetSleep::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> mem[addr(wNamePos) + 0] = 0; mem[addr(wNamePos) + 1] = 0; mem[addr(wNamePos) + 2] = 0   # the keys
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

.loop:
;>@lp for c in range(side, side + 3):
;>     if CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, .none

;>@k0         key = 0xFF
;>@el     elif (wBattlerStatus[8 * c] & 0xC0 or wBattlerStatus[8 * c + 2] & 0x22
;>             or wBattlerStatus[8 * c + 3] & 0x3F):
	ld a, c
	ld hl, wBattlerStatus
	call AddEightTimes
	ld a, [hli]
	and $c0
	jr nz, .held

;=@el
	inc hl
	ld a, [hli]
	and $22
	jr nz, .held

;=@el
	ld a, [hl]
	and $3f
	jr nz, .held

;>@k1         key = 0xFE
;>     else:
;>         wBattleArg0 = 2; wSkillTarget = c
	push bc
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>@kr         key = wBattleArg0 & 0xC0
;>@ks     mem[addr(wNamePos) + (c & 3)] = key
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@kr
	ld a, [wBattleArg0]
	and $c0
;=@ks
	ld [hl], a
	jr .next

.held:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k1
	ld a, $fe
;=@ks
	ld [hl], a
	jr .next

.none:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k0
	ld a, $ff
;=@ks
	ld [hl], a

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;>@w1 wBattleArg0 = side; wBattleArg1 = mem[addr(wNamePos) + (side & 3)]   # first as the best so far
	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
;=@w1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@w1
	ld [wBattleArg1], a
;> AIPickLowestKey(side, 3)
	call AIPickLowestKey
	ret


;@ def AITargetRobMagic()
;@ path: battle/ai/targets
;@ Target picker of RobMagic (steals MP): keys per enemy - $FF empty or out of MP, $FE when it would
;@ bounce the spell back, else the resistance (bits 2-3 of resistance byte 2); the lowest key wins.
;@ test: skip far calls into the resistance table
AITargetRobMagic::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
;> mem[addr(wNamePos) + 0] = 0; mem[addr(wNamePos) + 1] = 0; mem[addr(wNamePos) + 2] = 0   # the keys
	push bc
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a

.loop:
;>@lp for c in range(side, side + 3):
;>@k0     if CheckBattlerPresent(c) or not GetBattlerMP(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, .none

;=@k0
	ld a, c
	call GetBattlerMP
	or h
	jr z, .none

;>@k1         key = 0xFF
;>@el     elif wBattlerStatus[8 * c + 2] & 0x22:
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	jr nz, .held

;>@k2         key = 0xFE
;>     else:
;>         wBattleArg0 = 2; wSkillTarget = c
	push bc
	ld a, $02
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>         GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>@kr         key = wBattleArg0 & 0x0C
;>@ks     mem[addr(wNamePos) + (c & 3)] = key
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@kr
	ld a, [wBattleArg0]
	and $0c
;=@ks
	ld [hl], a
	jr .next

.held:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k2
	ld a, $fe
;=@ks
	ld [hl], a
	jr .next

.none:
;=@ks
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@ks
	adc h
	ld h, a
;=@k1
	ld a, $ff
;=@ks
	ld [hl], a

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;>@w1 wBattleArg0 = side; wBattleArg1 = mem[addr(wNamePos) + (side & 3)]   # first as the best so far
	pop bc
	ld a, c
	ld [wBattleArg0], a
	and $03
	ld hl, wNamePos
;=@w1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@w1
	ld [wBattleArg1], a
;> AIPickLowestKey(side, 3)
	call AIPickLowestKey
	ret


;@ def AITargetFireSlash()
;@ path: battle/ai/targets
;@ Target picker of FireSlash: the enemy with the lowest resistance (bits 6-7 of resistance byte 0), between equal ones
;@ the lowest HP + defense (AITargetResistHPDef). An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetFireSlash::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wBattleArg2 = 0; wBattleArg3 = 0xC0               # resistance byte and its bits
	ld a, $00
	ld [wBattleArg2], a
	ld a, $c0
	ld [wBattleArg3], a
;> AITargetResistHPDef(side, 3)
	call AITargetResistHPDef
	ret


;@ def AITargetBoltSlash()
;@ path: battle/ai/targets
;@ Target picker of BoltSlash: the enemy with the lowest resistance (bits 4-5 of resistance byte 1), between equal ones
;@ the lowest HP + defense (AITargetResistHPDef). An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetBoltSlash::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wBattleArg2 = 1; wBattleArg3 = 0x30               # resistance byte and its bits
	ld a, $01
	ld [wBattleArg2], a
	ld a, $30
	ld [wBattleArg3], a
;> AITargetResistHPDef(side, 3)
	call AITargetResistHPDef
	ret


;@ def AITargetVacuSlash()
;@ path: battle/ai/targets
;@ Target picker of VacuSlash: the enemy with the lowest resistance (bits 6-7 of resistance byte 1), between equal ones
;@ the lowest HP + defense (AITargetResistHPDef). An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetVacuSlash::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wBattleArg2 = 1; wBattleArg3 = 0xC0               # resistance byte and its bits
	ld a, $01
	ld [wBattleArg2], a
	ld a, $c0
	ld [wBattleArg3], a
;> AITargetResistHPDef(side, 3)
	call AITargetResistHPDef
	ret


;@ def AITargetIceSlash()
;@ path: battle/ai/targets
;@ Target picker of IceSlash: the enemy with the lowest resistance (bits 2-3 of resistance byte 1), between equal ones
;@ the lowest HP + defense (AITargetResistHPDef). An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetIceSlash::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wBattleArg2 = 1; wBattleArg3 = 0x0C               # resistance byte and its bits
	ld a, $01
	ld [wBattleArg2], a
	ld a, $0c
	ld [wBattleArg3], a
;> AITargetResistHPDef(side, 3)
	call AITargetResistHPDef
	ret


;@ def AITargetWindBeast()
;@ path: battle/ai/targets
;@ Target picker of WindBeast: the enemy with the lowest resistance (bits 6-7 of resistance byte 1), between equal ones
;@ the lowest HP (AITargetResistHP). An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetWindBeast::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wBattleArg2 = 1; wBattleArg3 = 0xC0               # resistance byte and its bits
	ld a, $01
	ld [wBattleArg2], a
	ld a, $c0
	ld [wBattleArg3], a
;> AITargetResistHP(side, 3)
	call AITargetResistHP
	ret


;@ def AITargetGigaSlash()
;@ path: battle/ai/targets
;@ Target picker of GigaSlash: the enemy with the lowest resistance (bits 2-3 of resistance byte 6), between equal ones
;@ the lowest HP (AITargetResistHP). An enemy monster that is not smart aims like a plain attack instead.
;@ test: skip far calls into the resistance table
AITargetGigaSlash::
;> if AIRandomEnemyIfDim():
;>     return
	call AIRandomEnemyIfDim
	ret z

;> if AIAimPlainInstead():
;>     return
	call AIAimPlainInstead
	ret z

;> side = AIStartScoresAlt()
	call AIStartScoresAlt
;> wBattleArg2 = 6; wBattleArg3 = 0x0C               # resistance byte and its bits
	ld a, $06
	ld [wBattleArg2], a
	ld a, $0c
	ld [wBattleArg3], a
;> AITargetResistHP(side, 3)
	call AITargetResistHP
	ret


;@ def ChooseTargetsAndOrder()
;@ path: battle/turn
;@ Battle sub-step machine (far entry 0) that runs once all commands are given: for every monster
;@ (wSkillUser 0-7) whose command is chosen it lets the tactic pick a skill (bank $57) and then the
;@ skill's target picker, then rolls everyone's speed and sorts the turn order into wTurnOrder.
;@ test: skip runs a whole step machine with far calls
ChooseTargetsAndOrder::
;> ChooseTargetsSteps[wBattleSubStep]()
	ld a, [wBattleSubStep]
	rst $00

;@ path: battle/turn
;@ The steps of ChooseTargetsAndOrder, by wBattleSubStep.
ChooseTargetsSteps::
	dw ChooseTargetsNext
	dw ChooseTargetsTactic
	dw ChooseTargetsPick
	dw TurnOrderRollSpeeds
	dw TurnOrderSort
	dw ChooseTargetsDone

;@ def ChooseTargetsNext()
;@ path: battle/turn
;@ Step 0: looks at monster wSkillUser. Once all eight positions are done it goes on to the turn
;@ order (step 3); a monster whose command is chosen (wBattlerOrder 1) goes to step 1, any other one
;@ is skipped.
;@ test: skip draws random numbers through the link generator
ChooseTargetsNext::
;> if wLinkActive:
;>     LinkRandom()                               # keeps both Game Boys' generators in step
	ld a, [wLinkActive]
	or a
	call nz, LinkRandom
;>@a8 if wSkillUser == 8:
;>@a3     wBattleSubStep += 3                        # on to TurnOrderRollSpeeds
	ld a, [wSkillUser]
	cp $08
	jr z, .allDone

;>@od elif wBattlerOrder[wSkillUser] == 1:
;>@s1     wBattleSubStep += 1; wBattleSubStep2 = 0   # step 1 for this monster
	ld e, a
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@od
	ld h, a
	ld a, [hl]
	cp $01
	jr z, .chosen

;> else:
;>     wSkillUser += 1
	inc e
	ld a, e
	ld [wSkillUser], a
	jr .done

.chosen:
;=@od
	ld a, e
	ld [wSkillUser], a
;=@s1
	ld hl, wBattleSubStep
	inc [hl]
	xor a
	ld [wBattleSubStep2], a
	jr .done

.allDone:
;=@a3
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]
	ld hl, wBattleSubStep
	inc [hl]

.done:
;=@a8
	ret


;@ def ChooseTargetsTactic()
;@ path: battle/turn
;@ Step 1: bank $57's step machine lets the monster's tactic choose its skill.
;@ test: skip far call into bank $57
ChooseTargetsTactic::
;> AIChooseAction()
	ld hl, far_AIChooseAction
	rst $10
	ret


;@ path: unused
;@ Leftover bytes after ChooseTargetsTactic, never reached: the code of a jump through the pointer at
;@ hl (ld a, [hli] / ld h, [hl] / ld l, a / jp hl), like JumpToPointer.
UnusedJumpToPointer::
	db $2a, $66, $6f, $e9

;@ def ChooseTargetsPick()
;@ path: battle/turn
;@ Step 2: unless the monster's target is already set, a monster that cannot act is given Attack on
;@ itself; otherwise (after the forced skill of MaybeForceSkill, and Attack when the tactic chose
;@ nothing) RunTargetPicker aims its skill. Then the personality notes, the monster is marked done
;@ (wBattlerOrder 2) and step 0 looks at the next one at once.
;@ test: skip runs the target pickers and the next step
ChooseTargetsPick::
;> wHitCount = 0
	xor a
	ld [wHitCount], a
;>@tg if wBattlerAction[2 * wSkillUser + 1] == 0xFF:   # no target yet
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@tg
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
	jr nz, .notes

;>     if CheckBattlerCanAct(wSkillUser):         # cannot act
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	jr nc, .canAct

;>@at         wBattlerAction[2 * wSkillUser] = 0x3A   # Attack
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@at
	adc h
	ld h, a
	ld a, $3a
	ld [hli], a
;>         wBattlerAction[2 * wSkillUser + 1] = wSkillUser
	ld a, [wSkillUser]
	ld [hl], a
	jr .notes

.canAct:
;>     else:
;>         if wGameModeStep:
;>             MaybeForceSkill()
	ld a, [wGameModeStep]
	or a
	call nz, MaybeForceSkill
;>@nt         if wBattlerAction[2 * wSkillUser] == 0xFF:
;>@sa             SetActionAttack(addr(wBattlerAction) + 2 * wSkillUser)
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@nt
	adc h
	ld h, a
	ld a, [hl]
	cp $ff
;=@sa
	call z, SetActionAttack
;>         RunTargetPicker()
	call RunTargetPicker

.notes:
;> NotePersonalitySkill()
	call NotePersonalitySkill
;> NotePersonalityAttack()
	call NotePersonalityAttack
;>@od wBattlerOrder[wSkillUser] = 2                  # done
	ld a, [wSkillUser]
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@od
	ld h, a
	ld a, $02
	ld [hl], a
;> wBattleSubStep = 0
	xor a
	ld [wBattleSubStep], a
;> wSkillUser += 1
	ld hl, wSkillUser
	inc [hl]
;> ChooseTargetsNext()
	jp ChooseTargetsNext


;@ def RunTargetPicker()
;@ path: battle/ai/targets
;@ Far entry 8: aims the skill of monster wSkillUser - jumps to FarTable_58 entry 14 + skill, the
;@ skill's target picker. Called again later in the turn (wBattleSubStep $16 and up) the old target
;@ is cleared first.
;@ test: skip jumps to one of the target pickers
RunTargetPicker::
;> if wBattleSubStep >= 0x16:
	ld a, [wBattleSubStep]
	cp $16
	jr c, .first

;>@cl     wBattlerAction[2 * wSkillUser + 1] = 0xFF
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@cl
	adc h
	ld h, a
	ld a, $ff
	ld [hld], a
	jr .skill

.first:
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

.skill:
;=@sk
	ld a, [hl]
	ld [wSkillId], a
;>@j FarTable_58[14 + wSkillId]()
	ld hl, FarTable_58 + 2 * 14
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
;=@j
	call JumpToPointer
	ret


;@ def SetActionAttack(action: hl)
;@ path: battle/turn
;@ Sets the skill of an action to Attack ($3A).
;@ test: action = 0xDCEC + 2 * rng.randint(0, 7)
SetActionAttack::
;> mem[action] = 0x3A
	ld [hl], $3a
	ret


;@ def TurnOrderRollSpeeds()
;@ path: battle/turn
;@ Step 3: rolls the speed of every monster that has its command (wBattlerOrder 2): agility spread at
;@ random (RollSpeed), at least 2, $600 more for the skills that always go first (IsFirstMoveSkill),
;@ $200 more for SquallHit, 1 for PsycheUp. Speeds go to the word list at wSkillStatusPtr, the
;@ positions to wBattleArg0.., Terry's item (position $10) with speed $200. Then the sort.
;@ test: skip runs the sort step and draws random numbers
TurnOrderRollSpeeds::
;> fill(wTurnOrder, 0xFF, 9)
	ld hl, wTurnOrder
	ld bc, $0009
	ld a, $ff
	call FillMemory
;> fill(addr(wBattleArg0), 0xFF, 9)                     # positions
	ld hl, wBattleArg0
	ld bc, $0009
	ld a, $ff
	call FillMemory
;> fill(addr(wSkillStatusPtr), 0, 16)                    # speeds
	ld hl, wSkillStatusPtr
	ld bc, $0010
	ld a, $00
	call FillMemory
;> wTurnOrderPos = 0
;> wBattlerReload = 0                              # entries so far
	xor a
	ld [wTurnOrderPos], a
	ld [wBattlerReload], a
;> wNameDest = addr(wSkillStatusPtr)
	ld hl, wSkillStatusPtr
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;>@lp for e in range(8):
	ld de, $0800

.loop:
;>     if wLinkActive:
;>         LinkRandom()
	push de
	ld a, [wLinkActive]
	or a
	call nz, LinkRandom
	pop de
;>     if CheckBattlerPresent(e):
;>         continue
	ld a, e
	call CheckBattlerPresent
	jr c, .next

;>@od     if wBattlerOrder[e] != 2:
;>@o2         continue
	ld a, e
	ld hl, wBattlerOrder
	add l
	ld l, a
	ld a, $00
	adc h
;=@od
	ld h, a
	ld a, [hl]
	cp $02
;=@o2
	jr nz, .next

;>@ag     speed = RollSpeed(e, mem16[addr(wBattlerAgility) + 2 * e])
	ld a, e
	ld hl, wBattlerAgility
	add a
	add l
	ld l, a
	ld a, $00
;=@ag
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, e
;=@ag
	call RollSpeed
;>@s2     if speed < 2:
	ld a, b
	or a
	jr nz, .fast

	ld a, c
	cp $02
	jr nc, .fast

;>         speed = 2
	ld bc, $0002

.fast:
;>     if IsFirstMoveSkill(e):
	ld a, e
	call IsFirstMoveSkill
	jr c, .first

;>@f6         speed += 0x600
;>     else:
;>@sk         skill = wBattlerAction[2 * e]
	ld a, e
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@sk
	adc h
	ld h, a
	ld a, [hl]
;>         if skill == 0x55:                       # SquallHit
;>             speed = SpeedBonusSquallHit(speed)
	cp $55
	call z, SpeedBonusSquallHit
;>         if skill == 0x56:                       # PsycheUp (after SquallHit the new high byte is compared)
;>             speed = SpeedSlowest()
	cp $56
	call z, SpeedSlowest
	jr .store

.first:
;=@f6
	ld a, b
	add $06
	ld b, a

.store:
;>@w     mem16[wNameDest] = speed
	ld hl, wNameDest
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
	ld [hli], a
;=@w
	ld [hl], b
;>@ps     mem[addr(wBattleArg0) + wBattlerReload] = e
	ld a, [wBattlerReload]
	ld hl, wBattleArg0
	add l
	ld l, a
	ld a, $00
	adc h
;=@ps
	ld h, a
	ld [hl], e
;>     wBattlerReload += 1; wNameDest += 2
	ld hl, wBattlerReload
	inc [hl]
	ld hl, wNameDest
	inc [hl]
	ld hl, wNameDest
	inc [hl]

.next:
;=@lp
	inc e
	dec d
	jp nz, .loop

;> if not wLinkActive and wBattleItemTarget != 0xFF:   # Terry uses an item
	ld a, [wLinkActive]
	or a
	jr nz, .sort

	ld a, [wBattleItemTarget]
	cp $ff
	jr z, .sort

;>@it     mem16[wNameDest] = 0x200
	ld bc, $0200
	ld hl, wNameDest
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, c
;=@it
	ld [hli], a
	ld [hl], b
;>@ip     mem[addr(wBattleArg0) + wBattlerReload] = 0x10
	ld a, [wBattlerReload]
	ld hl, wBattleArg0
	add l
	ld l, a
	ld a, $00
	adc h
;=@ip
	ld h, a
	ld [hl], $10

.sort:
;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> TurnOrderSort()
	jr TurnOrderSort

;@ def SpeedBonusSquallHit(speed: bc) -> bc
;@ path: battle/turn
;@ SquallHit strikes early: speed + $200.
;@ test: speed = rng.randint(0, 0xFDFF)
SpeedBonusSquallHit::
;> return speed + 0x200
	ld a, b
	add $02
	ld b, a
	ret


;@ def SpeedSlowest() -> bc
;@ path: battle/turn
;@ PsycheUp waits until the end of the turn: speed 1.
SpeedSlowest::
;> return 1
	ld bc, $0001
	ret


;@ def TurnOrderSort()
;@ path: battle/turn
;@ Step 4: sorts the speed list (wSkillStatusPtr..) with the positions (wBattleArg0..) by bubble sort,
;@ fastest first (equal speeds are swapped too), and copies the positions up to the first $FF into
;@ wTurnOrder. Then step 5.
;@ test: skip sorts lists kept in several scratch variables
TurnOrderSort::
;>@ps for passes in range(8, 0, -1):
	ld d, $08

.pass:
;>     wNameDest = addr(wSkillStatusPtr)
	ld hl, wSkillStatusPtr
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;>     first = wSkillStatusPtr; second = wStatPtr
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wStatPtr
	ld a, [hli]
	ld h, [hl]
;=@ps
	ld l, a
	ld e, $00

.compare:
;>@e     for e in range(passes):
;>         if second >= first:                    # swap the speeds and the positions
	call CompareHLBC
	jr c, .noSwap

;>@sw             wSkillAmount = second; wTargetScores = first      # scratch for the swap
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
	ld a, c
	ld [wTargetScores], a
;=@sw
	ld a, b
	ld [wTargetScores + 1], a
;>@wr             mem16[wNameDest] = wSkillAmount; mem16[wNameDest + 2] = wTargetScores
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, [wSkillAmount]
	ld [hli], a
;=@wr
	ld a, [wSkillAmount + 1]
	ld [hli], a
	ld a, [wTargetScores]
	ld [hli], a
	ld a, [wTargetScores + 1]
	ld [hl], a
;>@xp             p = addr(wBattleArg0) + e; mem[p], mem[p + 1] = mem[p + 1], mem[p]
	ld a, e
	ld hl, wBattleArg0
	add l
	ld l, a
	ld a, $00
	adc h
;=@xp
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld [hld], a
	ld [hl], b

.noSwap:
;>         if e + 1 == passes:
;>             break
	inc e
	ld a, e
	cp d
	jr z, .passDone

;>@nx         wNameDest += 2
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	inc hl
	inc hl
;=@nx
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;>@ld         first = mem16[wNameDest]; second = mem16[wNameDest + 2]
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc hl
	ld a, [hli]
	ld h, [hl]
;=@ld
	ld l, a
;=@e
	jr .compare

.passDone:
;=@ps
	dec d
	jr nz, .pass

;>@cp de = addr(wTurnOrder) + wTurnOrderPos
	ld a, [wTurnOrderPos]
	ld de, wTurnOrder
	add e
	ld e, a
	ld a, $00
	adc d
;=@cp
	ld d, a
;> for i in range(8):                             # copy the positions up to the first $FF
	ld a, [wTurnOrderPos]
	ld hl, wBattleArg0
	ld b, $08

.copy:
;>@cc     if mem[addr(wBattleArg0) + i] == 0xFF:
;>         break
	ld a, [hli]
	cp $ff
	jr z, .copied

;>     mem[de] = mem[addr(wBattleArg0) + i]; de += 1
	ld [de], a
	inc de
;=@cc
	dec b
	jr nz, .copy

.copied:
;> wTurnOrderPos = 0
	ld a, $00
	ld [wTurnOrderPos], a
;> wBattleSubStep += 1
	ld hl, wBattleSubStep
	inc [hl]
;> ChooseTargetsDone()
	jp ChooseTargetsDone


;@ def RollSpeed(pos: a, agility: bc) -> bc
;@ path: battle/turn
;@ The speed of a monster this turn: a random value between agility - spread and agility, spread =
;@ 1 + agility/4 + agility/16 (agility 0 counts as 1). $200 more for SquallHit, 0 for PsycheUp.
;@ test: skip draws random numbers through the link generator
RollSpeed::
;> BattleRandom_58()
	push hl
	push de
	push af
	push bc
	call BattleRandom_58
;> spread = 1
	ld hl, $0001
;> if agility == 0:
;>     agility = 1
	pop bc
	ld a, b
	or c
	jr nz, .spread

	ld bc, $0001

.spread:
;>@sp spread += agility // 4 + agility // 16
	ld d, b
	ld e, c
	srl b
	rr c
	srl b
	rr c
;=@sp
	add hl, bc
	srl b
	rr c
	srl b
	rr c
	add hl, bc
;> low = agility - spread
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
;>@r r = (wRandomLow & 3) * 256 + wRandomHigh
	ld b, h
	ld c, l
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
;=@r
	ld a, h
	and $03
	ld h, a

.reduce:
;>@rr while r > spread:
;>     r -= spread
	call CompareHLBC
	jr z, .done

	jr c, .done

	ld a, l
	sub c
	ld l, a
;=@rr
	ld a, h
	sbc b
	ld h, a
	jr .reduce

.done:
;> speed = low + r
	add hl, de
	ld b, h
	ld c, l
;>@sk skill = wBattlerAction[2 * pos]
	pop af
	ld e, a
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
;=@sk
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;> if skill == 0x55:                              # SquallHit
	cp $55
	jr nz, .notSquall

;>     speed += 0x200
	ld a, b
	add $02
	ld b, a
	jr .end

.notSquall:
;> elif skill == 0x56:                            # PsycheUp
;>     speed = 0
	cp $56
	jr nz, .end

	ld bc, $0000

.end:
;> return speed
	pop de
	pop hl
	ret


;@ def IsFirstMoveSkill(pos: a) -> carry
;@ path: battle/turn
;@ Carry when the monster at `pos` has chosen a skill that always comes first in the turn: Ironize,
;@ Imitate, Cover, Guardian, Dodge, Defence, StrongD, SuckAll, BladeD or IRONIZE ($DC).
;@ test: pos = rng.randint(0, 7)
IsFirstMoveSkill::
;>@sk skill = wBattlerAction[2 * pos]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@sk
	ld h, a
	ld a, [hl]
;>@f return skill in (0x2A, 0x7F, 0x88, 0x89, 0x8C, 0x8D, 0x8E, 0x8F, 0x90, 0xDC)
	cp $2a
	jr z, .yes

	cp $7f
	jr z, .yes

	cp $88
	jr z, .yes

;=@f
	cp $89
	jr z, .yes

	cp $8c
	jr z, .yes

	cp $8d
	jr z, .yes

;=@f
	cp $8e
	jr z, .yes

	cp $8f
	jr z, .yes

	cp $90
	jr z, .yes

;=@f
	cp $dc
	jr z, .yes

	xor a
	jr .done

.yes:
;=@f
	scf

.done:
	ret


;@ def ChooseTargetsDone()
;@ path: battle/turn
;@ Step 5: clears the step and the skill variables and moves the battle on (wBattleStep + 1).
ChooseTargetsDone::
;> wBattleSubStep = 0
;> wTurnOrderPos = 0
	xor a
	ld [wBattleSubStep], a
	ld [wTurnOrderPos], a
;> wSkillUser = 0
;> wSkillTarget = 0
	ld [wSkillUser], a
	ld [wSkillTarget], a
;> wSkillId = 0
	ld [wSkillId], a
;> wBattleStep += 1
	ld hl, wBattleStep
	inc [hl]
	ret


;@ path: unused
;@ Code nothing calls (45 bytes): puts a random one of the user's eight skills (or its first skill,
;@ or Attack $3A when it has none) at hl.
UnusedRandomSkill::
	db $e5, $fa, $88, $db, $21, $65, $dc, $cb, $37, $85, $6f, $3e, $00, $8c, $67, $44
	db $4d, $fa, $99, $c8, $e6, $07, $87, $85, $6f, $3e, $00, $8c, $67, $7e, $fe, $ff
	db $20, $07, $0a, $fe, $ff, $20, $02, $3e, $3a, $4f, $e1, $71, $c9

;@ def BlankEnemyPicture()
;@ path: battle/screen
;@ Far entry 1: wipes the picture of the opposing monster at wSkillTarget (the far side: positions
;@ 4-6, for the link master 0-2) - its 36 tiles at $9000, $9240 or $9480 become plain colour 1 - and
;@ sets wBattleSubStep to 5. Nothing happens for a position on the near side.
;@ test: skip writes VRAM while waiting for the LCD
BlankEnemyPicture::
;> wBattleStepArg1 = 2
	ld a, $02
	ld [wBattleStepArg1], a
;> if wLinkActive and wLinkFlags & 2:            # link master: the partner's monsters are 0-2
	ld a, [wLinkActive]
	or a
	jr z, .normal

	ld a, [wLinkFlags]
	bit 1, a
	jr z, .normal

;>     if wSkillTarget & 4:
;>         return
	ld a, [wSkillTarget]
	bit 2, a
	ret nz

;>@sl     slot = wSkillTarget
	ld a, [wSkillTarget]
	jr .slot

.normal:
;> else:
;>     if not wSkillTarget & 4:
;>         return
	ld a, [wSkillTarget]
	bit 2, a
	ret z

;>     slot = wSkillTarget - 4
	ld a, [wSkillTarget]
	sub $04

.slot:
;> if slot == 2:
;>@t2     dest = 0x9480
	cp $02
	jr z, .third

;> elif slot == 1:
;>@t1     dest = 0x9240
	cp $01
	jr z, .second

;> else:
;>     dest = 0x9000
	ld hl, $9000
	jr .fill

.second:
;=@t1
	ld hl, $9240
	jr .fill

.third:
;=@t2
	ld hl, $9480

.fill:
;>@o for _ in range(0x24):
	ld c, $24

.tile:
;>@i     for _ in range(8):
	ld b, $08

.row:
;>         disable_interrupts()
	di

.wait:
;>         while rSTAT & 0x02:                    # VRAM busy
;>             wait_hblank()
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .wait

;>         mem[dest] = 0xFF; mem[dest + 1] = 0x00; dest += 2
	ld a, $ff
	ld [hli], a
	ld a, $00
	ld [hli], a
;>         enable_interrupts()
	ei
;=@i
	dec b
	jr nz, .row

;=@o
	dec c
	jr nz, .tile

;> wBattleSubStep = 5
	ld a, $05
	ld [wBattleSubStep], a
	ret


;@ def GetItemMessage()
;@ path: battle/items
;@ Far entry 7: the battle message number (wBattleArg0) for Terry's item: for the meats FEEDMEAT ..
;@ SIRLOIN (effects $C2-$C6) text group 1 and MeatMessage (by the number of enemies fed); for the
;@ other items the entry of SkillMessages for the item's effect.
;@ test: skip reads the message tables
GetItemMessage::
;> if not 0xC2 <= wBattleItemEffect < 0xC7:
	ld a, [wBattleItemEffect]
	cp $c2
	jr c, GetSkillMessage.lookup

	cp $c7
	jr nc, GetSkillMessage.lookup

;>     wBattleArg0 = mem[SkillMessages + wBattleItemEffect]; return   # (GetSkillMessage's lookup)
;> wTextGroup = 1
	ld b, a
	ld a, $01
	ld [wTextGroup], a
;> if wBattleItemTarget < 4:                     # a meat for the own monster
	ld a, [wBattleItemTarget]
	cp $04
	jr nc, .enemies

;>     CountTargetsOne()
	call CountTargetsOne
;>     MeatMessage()
	jp MeatMessage


.enemies:
;> else:
;>     MeatMessageEnemies()
	jp MeatMessageEnemies


;@ def GetSkillMessage()
;@ path: battle/messages
;@ Far entry 6: the battle message number (wBattleArg0) for the skill monster wSkillUser uses:
;@ $33 while it is high in the sky (HighJump), $4F during LifeSong, else its entry of SkillMessages.
;@ test: wSkillUser = rng.randint(0, 7)
GetSkillMessage::
;> if wBattlerStatus[8 * wSkillUser + 4] & 0x0C:   # high in the sky
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, .sky

;>@sy     wBattleArg0 = 0x33
;> elif wBattlerStatus[8 * wSkillUser + 5] & 0x10:   # LifeSong
;>@ls     wBattleArg0 = 0x4F
	inc hl
	bit 4, [hl]
	jr nz, .song

;> else:
;>@sk     skill = wBattlerAction[2 * wSkillUser]
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

.lookup:
;>@lu     wBattleArg0 = mem[SkillMessages + skill]
	ld hl, SkillMessages
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@lu
	ld a, [hl]
	ld [wBattleArg0], a
	ret


.sky:
;=@sy
	ld a, $33
	ld [wBattleArg0], a
	ret


.song:
;=@ls
	ld a, $4f
	ld [wBattleArg0], a
	ret


;@ path: unused
;@ Leftover code nothing calls: wBattleArg0 = $FF (ld a, $FF / ld [wBattleArg0], a / ret).
UnusedClearArg0::
	db $3e, $ff, $ea, $4c, $db, $c9

;@ path: battle/messages
;@ The battle message number (text group 0) shown when each skill is used, by skill number $00-$E1
;@ (GetSkillMessage; the items read it by their effect number): $22-$77, $FF none. Most spells share
;@ $23, the weapon skills $24/$25.
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

;@ def MeatMessageEnemies()
;@ path: battle/items
;@ A meat thrown to the enemies: counts them for the name form (CountTargetNames on the enemy side),
;@ then MeatMessage.
;@ test: skip copies names in another bank
MeatMessageEnemies::
;> saved = wSkillTarget
	ld a, [wSkillTarget]
	push af
;> wSkillTarget = 4
	ld a, $04
	ld [wSkillTarget], a
;> CountTargetNames()
	call CountTargetNames
;> wSkillTarget = saved
	pop af
	ld [wSkillTarget], a

;> MeatMessage()                                  # runs into it

;@ def MeatMessage()
;@ path: battle/items
;@ The message number of a meat: MeatMessages[wBattleTemp] (0 one monster, 1 several of one kind, 2
;@ mixed), three further for BADMEAT ($C5).
;@ test: wBattleTemp = rng.randint(0, 2)
MeatMessage::
;> if wBattleItemEffect == 0xC5:                  # BADMEAT
;>     wBattleTemp += 3
	ld a, [wBattleItemEffect]
	cp $c5
	jr nz, .lookup

	ld a, [wBattleTemp]
	add $03
	ld [wBattleTemp], a

.lookup:
;>@lu wBattleArg0 = mem[MeatMessages + wBattleTemp]
	ld a, [wBattleTemp]
	ld hl, MeatMessages
	add l
	ld l, a
	ld a, $00
	adc h
;=@lu
	ld h, a
	ld a, [hl]
	ld [wBattleArg0], a
	ret


;@ path: battle/items
;@ Message numbers (text group 1) of a meat by MeatMessage's index: 0-2 for the good meats, 3-5 for
;@ BADMEAT (one monster, several of one kind, mixed).
MeatMessages::
	db $00, $01, $02, $00, $01, $02

;@ def SetNameFormMessage()
;@ path: battle/messages
;@ Far entry 9: picks the message (wTextIndex) by the name form in wBattleTemp from NameFormMessages;
;@ for an enemy (as the message side sees it) the position letter is cut from wTextArg0 first.
;@ test: skip searches memory for the end mark (StripLetterArg0)
SetNameFormMessage::
;> if GetMessageSidePos() >= 4:
;>     StripLetterArg0()
	call GetMessageSidePos
	cp $04
	call nc, StripLetterArg0
;>@lu wTextIndex = mem[NameFormMessages + wBattleTemp]
	ld a, [wBattleTemp]
	ld hl, NameFormMessages
	add l
	ld l, a
	ld a, $00
	adc h
;=@lu
	ld h, a
	ld a, [hl]
	ld [wTextIndex], a
	ret


;@ path: battle/messages
;@ Message numbers of SetNameFormMessage, by wBattleTemp (0-5).
NameFormMessages::
	db $03, $05, $07, $04, $06, $08

;@ def StripLetterArg0()
;@ path: battle/messages
;@ Cuts the position letter (a last character below $24) from the name in wTextArg0.
;@ test: skip searches memory for the end mark
StripLetterArg0::
;> p = addr(wTextArg0)
	ld hl, wTextArg0
;> pass                                          # goes on in StripLetterArg2 (.find) with this p
	jr StripLetterArg2.find

;@ def StripLetterArg2()
;@ path: battle/messages
;@ Cuts the position letter (a last character below $24) from the name in wTextArg2: finds the $F0
;@ end mark and ends the text one character earlier when that character is below $24.
;@ test: skip searches memory for the end mark
StripLetterArg2::
;> p = addr(wTextArg2)
	ld hl, wTextArg2

.find:
;> while mem[p] != 0xF0:
;>     p += 1
	ld a, [hl]
	cp $f0
	jr z, .found

	inc hl
	jr .find

.found:
;> if mem[p - 1] < 0x24:
;>     mem[p - 1] = 0xF0
	dec hl
	ld a, [hl]
	cp $24
	ret nc

	ld [hl], $f0
	ret


;@ def CountTargetNames()
;@ path: battle/messages
;@ Far entry 2: the name form of the side of wSkillTarget for a message, in wBattleTemp: own side
;@ (and link battles) 0 for one monster, 1 for more; enemy side 0 for one, 1 when all are of one
;@ species (then the letter is cut from wTextArg2), 2 for mixed species.
;@ test: wSkillTarget = rng.randint(0, 7)
CountTargetNames::
;> wBattleTemp = 0                               # monsters standing
;> wBattleTempHigh = 0                           # species among them
	xor a
	ld [wBattleTemp], a
	ld [wBattleTempHigh], a
;> side = wSkillTarget & 4
	ld a, [wSkillTarget]
	and $04
	ld c, a
	ld b, $03
;> if wLinkActive or side < 4:
	ld a, [wLinkActive]
	or a
	jr nz, .own

	ld a, c
	cp $04
	jr nc, .enemies

.own:
;>@lo     for c in range(side, side + 3):
;>         if not CheckBattlerPresent(c):
;>             wBattleTemp += 1
	ld a, c
	call CheckBattlerPresent
	jr c, .nextOwn

	ld hl, wBattleTemp
	inc [hl]

.nextOwn:
;=@lo
	inc c
	dec b
	jr nz, .own

;>     wBattleTemp = 0 if wBattleTemp == 1 else 1    # (stored by CountTargetsOne's tail)
	ld a, [wBattleTemp]
	dec a
	or a
	jr z, CountTargetsOne.store

	ld a, $01
	jr CountTargetsOne.store

.enemies:
;>@le else:
;>@e1     for c in range(side, side + 3):
;>         if not CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .nextEnemy

;>             wBattleTemp += 1
	ld hl, wBattleTemp
	inc [hl]
;>             if wBattleTempHigh == 0:
	ld hl, wBattleTempHigh
	ld a, [hl]
	or a
	jr nz, .compare

;>@e5                 first = wBattlerSpecies[c]; wBattleTempHigh = 1
	ld a, c
	ld de, wBattlerSpecies
	add e
	ld e, a
	ld a, $00
	adc d
;=@e5
	ld d, a
	ld a, [de]
	ld d, a
	inc [hl]
	jr .nextEnemy

.compare:
;>@e6             elif wBattlerSpecies[c] != first:
	push bc
	ld a, c
	ld bc, wBattlerSpecies
	add c
	ld c, a
	ld a, $00
;=@e6
	adc b
	ld b, a
	ld a, [bc]
	pop bc
	cp d
	jr z, .nextEnemy

;>                 wBattleTempHigh += 1
	inc [hl]

.nextEnemy:
;=@e1
	inc c
	dec b
	jr nz, .enemies

;>     if wBattleTemp == 1:
;>         return CountTargetsOne()
	ld a, [wBattleTemp]
	cp $01
	jr z, CountTargetsOne

;>     if wBattleTempHigh == 1:                 # all of one species: "the Slimes", no letter
;>         StripLetterArg2(); wBattleTemp = 1   # (CountTargetsOne's tail)
	ld a, [wBattleTempHigh]
	cp $01
	jr z, CountTargetsOne.same

;>     else:
;>         wBattleTemp = 2
	ld a, $02
	jr CountTargetsOne.store

;@ def CountTargetsOne()
;@ path: battle/messages
;@ The name form of a single monster: wBattleTemp = 0. Its tail (.same: cut the letter from
;@ wTextArg2, form 1; .store: wBattleTemp = a) also ends CountTargetNames.
CountTargetsOne::
;> wBattleTemp = 0
	ld a, $00
	jr .store

.same:
	call StripLetterArg2
	ld a, $01

.store:
	ld [wBattleTemp], a
	ret


;@ def NameTargetForMessage()
;@ path: battle/messages
;@ Far entry 3: copies the name of the monster at wSkillTarget into wTextArg0 - the species name for
;@ an enemy (position 3 and up, normal battles), else the party monster's name - and works out the
;@ name form (CountTargetNames).
;@ test: skip copies names from another bank
NameTargetForMessage::
;>@i if not wLinkActive and wSkillTarget >= 3:
	ld hl, wTextArg0
;=@i
	ld a, [wLinkActive]
	or a
	jr nz, .party

	ld a, [wSkillTarget]
	cp $03
	jr c, .party

;>@sp     CopySpeciesName(wSkillTarget, addr(wTextArg0))
;> else:
;>@pn     CopyName(PartyMonsterField(wSkillTarget, addr(wMonName)), addr(wTextArg0))
;=@sp
	call CopySpeciesName
	jr .count

.party:
;=@pn
	push hl
	ld hl, wMonName
	call PartyMonsterField
	ld e, l
	ld d, h
	pop hl
;=@pn
	call CopyName

.count:
;> CountTargetNames()
	call CountTargetNames
	ret


;@ def CopySpeciesName(pos: a, dest: hl)
;@ path: battle/messages
;@ Copies the species name of the monster at `pos` (system text group 5) to `dest`; wNameBattler
;@ and wNameDest are set for the enemy letter.
;@ test: skip copies a text from another bank
CopySpeciesName::
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
;>@wd wNameDest = dest
	ld l, a
	ld h, $05
	pop de
	ld a, e
	ld [wNameDest], a
	ld a, d
;=@wd
	ld [wNameDest + 1], a
;> CopySystemText(0x0500 + species, dest)
	call CopySystemText
	ret


;@ def MaybeForceSkill()
;@ path: battle/turn
;@ When wGameModeStep is set: with a chance of (wOpeningScene + 1) / 256 (always when it is 0) the
;@ skill of monster wSkillUser is replaced by wOpeningLogo - the two bytes of the mode that started
;@ the battle hold a chance and a skill then.
;@ test: skip draws random numbers through the link generator
MaybeForceSkill::
;> BattleRandom_58()
	call BattleRandom_58
;> if wOpeningScene and wOpeningScene < wRandomHigh:
;>     return
	ld a, [wOpeningScene]
	or a
	jr z, .force

	ld hl, wRandomHigh
	cp [hl]
	ret c

.force:
;>@ac wBattlerAction[2 * wSkillUser] = wOpeningLogo
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@ac
	adc h
	ld h, a
	ld a, [wOpeningLogo]
	ld [hl], a
	ret


;@ def NotePersonalitySkill()
;@ path: battle/personality
;@ After a monster's skill is chosen: for the player's own monsters (positions 0-2; in link battles
;@ every position but slot 3) that can act and are not high in the sky, notes a possible personality
;@ change in wPersonalityNudge by the kind of skill - side-stepping: personality 3 down; healing and
;@ support spells ($2B-$36, Surge, $93-$95): personality 2 up; Dodge: personality 2 down; Attack, the
;@ weapon skills and blows ($3A, $44-$51, SquallHit, $67-$69, $D6-$D8): personality 1 up; the defence
;@ stances: personality 1 down; status spells and breaths: byte +$67 up. A chance decides
;@ (NoteIfHigh / NoteIfLow with the random number drawn here).
;@ test: skip draws random numbers through the link generator
NotePersonalitySkill::
;> if CheckBattlerCanAct(wSkillUser):
;>     return
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	ret c

;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .normal

;>     LinkRandom()
	call LinkRandom
;>     if (wSkillUser & 3) == 3:
;>         return
	ld a, [wSkillUser]
	and $03
	cp $03
	ret z

	jr .check

.normal:
;> else:
;>     if wSkillUser >= 3:
;>         return
	ld a, [wSkillUser]
	cp $03
	ret nc

;>     BattleRandom_58()
	call BattleRandom_58

.check:
;> if wBattlerStatus[8 * wSkillUser + 4] & 0x0C:   # high in the sky
;>     return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hli]
	and $0c
	ret nz

;> if wBattlerStatus[8 * wSkillUser + 5] & 0x0C:   # side-stepping
;>     return NotePersonality3Low()
	ld a, [hl]
	and $0c
	jp nz, NotePersonality3Low

;>@sk skill = wBattlerAction[2 * wSkillUser]
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
;> if skill < 0x12 or skill in (0x14, 0x1B): return
	cp $12
	ret c

	cp $14
	ret z

	cp $1b
	ret z

;> if skill < 0x1E or skill in (0x20, 0x21): return NoteStat67High()
	cp $1e
	jr c, NoteStat67High

	cp $20
	jr z, NoteStat67High

	cp $21
	jr z, NoteStat67High

;> if skill < 0x2B or skill == 0x32: return
	cp $2b
	ret c

	cp $32
	ret z

;> if skill < 0x37: return NotePersonality2High()
	cp $37
	jr c, NotePersonality2High

;> if skill == 0x3A: return NotePersonality1High()
	cp $3a
	jr z, NotePersonality1High

;> if skill < 0x44 or skill == 0x4F: return
	cp $44
	ret c

	cp $4f
	ret z

;> if skill < 0x52 or skill == 0x55: return NotePersonality1High()
	cp $52
	jr c, NotePersonality1High

	cp $55
	jr z, NotePersonality1High

;> if skill < 0x67: return
	cp $67
	ret c

;> if skill < 0x6A: return NotePersonality1High()
	cp $6a
	jr c, NotePersonality1High

;> if skill == 0x77: return NotePersonality3Low()     # SideStep
	cp $77
	jr z, jr_058_5b1e

;> if skill < 0x7E or skill == 0x82: return NoteStat67High()
;> if skill == 0x81: return NotePersonality2High()
	cp $7e
	jr c, NoteStat67High

	cp $81
	jr z, NotePersonality2High

	cp $82
	jr z, NoteStat67High

;> if skill == 0x8C: return NotePersonality2Low()     # Dodge
;> if skill in (0x8D, 0x8E, 0x90): return NotePersonality1Low()
	cp $8c
	jr z, NotePersonality2Low

	cp $8d
	jr z, NotePersonality1Low

	cp $8e
	jr z, NotePersonality1Low

;=@p1
	cp $90
	jr z, NotePersonality1Low

;>@p1 if skill < 0x90: return
	ret c

;> if skill < 0x93: return NoteStat67High()
;> if skill < 0x96: return NotePersonality2High()
	cp $93
	jr c, NoteStat67High

	cp $96
	jr c, NotePersonality2High

;> if 0xD6 <= skill < 0xD9: return NotePersonality1High()
	cp $d6
	ret c

	cp $d9
	jr c, NotePersonality1High

	ret


;@ def NotePersonality1High()
;@ path: battle/personality
;@ Notes bit 0 (personality 1 up) through NoteIfHigh.
;@ test: skip uses the random number drawn before
NotePersonality1High::
;> NoteIfHigh(addr(wBattlerPersonality1), 0x01)
	ld hl, wBattlerPersonality1
	ld d, $01
	jr NoteIfHigh

;@ def NotePersonality1Low()
;@ path: battle/personality
;@ Notes bit 1 (personality 1 down) through NoteIfLow.
;@ test: skip uses the random number drawn before
NotePersonality1Low::
;> NoteIfLow(addr(wBattlerPersonality1), 0x02)
	ld hl, wBattlerPersonality1
	ld d, $02
	jr NoteIfLow

;@ def NoteStat67High()
;@ path: battle/personality
;@ Notes bit 2 (record byte +$67 up) through NoteIfHigh.
;@ test: skip uses the random number drawn before
NoteStat67High::
;> NoteIfHigh(addr(wBattlerStat67), 0x04)
	ld hl, wBattlerStat67
	ld d, $04
	jr NoteIfHigh

;@ def NoteStat67Low()
;@ path: battle/personality
;@ Notes bit 3 (record byte +$67 down) through NoteIfLow.
;@ test: skip uses the random number drawn before
NoteStat67Low::
;> NoteIfLow(addr(wBattlerStat67), 0x08)
	ld hl, wBattlerStat67
	ld d, $08
	jr NoteIfLow

;@ def NotePersonality2High()
;@ path: battle/personality
;@ Notes bit 4 (personality 2 up) through NoteIfHigh.
;@ test: skip uses the random number drawn before
NotePersonality2High::
;> NoteIfHigh(addr(wBattlerPersonality2), 0x10)
	ld hl, wBattlerPersonality2
	ld d, $10
	jr NoteIfHigh

;@ def NotePersonality2Low()
;@ path: battle/personality
;@ Notes bit 5 (personality 2 down) through NoteIfLow.
;@ test: skip uses the random number drawn before
NotePersonality2Low::
;> NoteIfLow(addr(wBattlerPersonality2), 0x20)
	ld hl, wBattlerPersonality2
	ld d, $20
	jr NoteIfLow

;@ def NotePersonality3High()
;@ path: battle/personality
;@ Notes bit 6 (personality 3 up) through NoteIfHigh.
;@ test: skip uses the random number drawn before
NotePersonality3High::
;> NoteIfHigh(addr(wBattlerPersonality3), 0x40)
	ld hl, wBattlerPersonality3
	ld d, $40
	jr NoteIfHigh

;@ def NotePersonality3Low()
;@ path: battle/personality
;@ Notes bit 7 (personality 3 down) through NoteIfLow.
;@ test: skip uses the random number drawn before
NotePersonality3Low::
jr_058_5b1e:
;> NoteIfLow(addr(wBattlerPersonality3), 0x80)
	ld hl, wBattlerPersonality3
	ld d, $80
	jr NoteIfLow

;@ def NoteIfHigh(table: hl, flag: d)
;@ path: battle/personality
;@ When the user's byte in `table` is $81 or more, sets `flag` in its wPersonalityNudge with a chance
;@ that grows with the value: 1, 2, 4 or 8 in 256 (below $A2, $C3, $E4, from $E4), tested against the
;@ random number drawn before.
;@ test: wSkillUser = rng.randint(0, 7)
NoteIfHigh::
;>@v v = mem[table + wSkillUser]
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@v
	ld a, [hl]
;> if v < 0x81:
;>     return
	cp $81
	ret c

;>@ch chance = 1 if v < 0xA2 else 2 if v < 0xC3 else 4 if v < 0xE4 else 8
	cp $a2
	jr c, .one

	cp $c3
	jr c, .two

	cp $e4
	jr c, .four

;=@ch
	jr .eight

.one:
;=@ch
	ld b, $01
	jr .roll

.two:
;=@ch
	ld b, $02
	jr .roll

.four:
;=@ch
	ld b, $04
	jr .roll

.eight:
;=@ch
	ld b, $08

.roll:
;> if wRandomHigh < chance:
	ld a, [wRandomHigh]
	cp b
	ret nc

;>@nd     wPersonalityNudge[wSkillUser] |= flag
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nd
	ld h, a
	ld a, [hl]
	or d
	ld [hl], a
	ret


;@ def NoteIfLow(table: hl, flag: d)
;@ path: battle/personality
;@ When the user's byte in `table` is below $80, sets `flag` in its wPersonalityNudge with a chance
;@ that grows as the value falls: 2, 4, 8 or 16 in 256 (from $60, $3F, $1E, below $1E).
;@ test: wSkillUser = rng.randint(0, 7)
NoteIfLow::
;>@v v = mem[table + wSkillUser]
	ld a, [wSkillUser]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@v
	ld a, [hl]
;> if v >= 0x80:
;>     return
	cp $80
	ret nc

;>@ch chance = 2 if v >= 0x60 else 4 if v >= 0x3F else 8 if v >= 0x1E else 16
	cp $60
	jr nc, .two

	cp $3f
	jr nc, .four

	cp $1e
	jr nc, .eight

;=@ch
	jr .sixteen

.two:
;=@ch
	ld b, $02
	jr .roll

.four:
;=@ch
	ld b, $04
	jr .roll

.eight:
;=@ch
	ld b, $08
	jr .roll

.sixteen:
;=@ch
	ld b, $10

.roll:
;> if wRandomHigh < chance:
	ld a, [wRandomHigh]
	cp b
	ret nc

;>@nd     wPersonalityNudge[wSkillUser] |= flag
	ld a, [wSkillUser]
	ld hl, wPersonalityNudge
	add l
	ld l, a
	ld a, $00
	adc h
;=@nd
	ld h, a
	ld a, [hl]
	or d
	ld [hl], a
	ret


;@ def NotePersonalityAttack()
;@ path: battle/personality
;@ The second personality note after a skill is chosen (same monsters as NotePersonalitySkill, not
;@ in the sky and not side-stepping): BladeD notes byte +$67 down, the attack spells (below $12),
;@ Attack, the weapon skills ($44-$51), $55-$69 and $D6-$D9 note personality 3 up.
;@ test: skip draws random numbers through the link generator
NotePersonalityAttack::
;> if CheckBattlerCanAct(wSkillUser):
;>     return
	ld a, [wSkillUser]
	call CheckBattlerCanAct
	ret c

;> if wLinkActive:
	ld a, [wLinkActive]
	or a
	jr z, .normal

;>     LinkRandom()
	call LinkRandom
;>     if (wSkillUser & 3) == 3:
;>         return
	ld a, [wSkillUser]
	and $03
	cp $03
	ret z

	jr .check

.normal:
;> else:
;>     if wSkillUser >= 3:
;>         return
	ld a, [wSkillUser]
	cp $03
	ret nc

;>     BattleRandom_58()
	call BattleRandom_58

.check:
;> if wBattlerStatus[8 * wSkillUser + 4] & 0x0C or wBattlerStatus[8 * wSkillUser + 5] & 0x0C:
;>     return
	ld a, [wSkillUser]
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hli]
	and $0c
	ret nz

;=@x
	ld a, [hl]
	and $0c
	ret nz

;>@x skill = wBattlerAction[2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@x
	adc h
	ld h, a
	ld a, [hl]
;> if skill == 0x90:                            # BladeD
;>@bd     return NoteStat67Low()
	cp $90
	jr z, .blade

;> if skill < 0x12 or skill == 0x3A: return NotePersonality3High()
	cp $12
	jr c, .high

	cp $3a
	jr z, .high

;> if skill < 0x44: return
;> if skill < 0x52: return NotePersonality3High()
	cp $44
	ret c

	cp $52
	jr c, .high

;> if skill < 0x55: return
;> if skill < 0x6A: return NotePersonality3High()
	cp $55
	ret c

	cp $6a
	jr c, .high

;> if not 0xD6 <= skill < 0xDA: return
	cp $d6
	ret c

	cp $da
	ret nc

.high:
;> NotePersonality3High()
	call NotePersonality3High
	ret


.blade:
;=@bd
	call NoteStat67Low
	ret


;@ def GetMessageSidePos() -> a
;@ path: battle/messages
;@ The position a message is told from: wSkillUser for the link master, else wSkillTarget.
;@ test: wSkillUser = rng.randint(0, 7)
GetMessageSidePos::
;> if not wLinkFlags & 2:
;>     return wSkillTarget
	ld a, [wLinkFlags]
	bit 1, a
	ld a, [wSkillTarget]
	ret z

;> return wSkillUser
	ld a, [wSkillUser]
	ret


;@ def LinkRandom()
;@ path: battle/link
;@ Draws a random number from the generator both Game Boys share in a link battle: wLinkRandom is
;@ loaded into wRandomHigh/wRandomLow, stepped by Random and stored back.
;@ test: skip steps the shared random generator
LinkRandom::
;> wRandomHigh = lo(wLinkRandom); wRandomLow = hi(wLinkRandom)
	push hl
	ld a, [wLinkRandom]
	ld l, a
	ld a, [wLinkRandom + 1]
	ld h, a
	ld a, l
;=@lr
	ld [wRandomHigh], a
	ld a, h
	ld [wRandomLow], a
;> Random()
	call Random
;>@lr wLinkRandom = wRandomHigh + 256 * wRandomLow
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, l
	ld [wLinkRandom], a
;=@lr
	ld a, h
	ld [wLinkRandom + 1], a
	pop hl
	ret


;@ def BattleRandom_58()
;@ path: battle/link
;@ A random number for the battle: from the shared link generator in a link battle, else Random.
;@ test: skip steps the random generators
BattleRandom_58::
;> if wLinkActive:
;>     return LinkRandom()
	ld a, [wLinkActive]
	or a
	jr nz, LinkRandom

;> Random()
	call Random
	ret


;@ def PickTargetForSkill()
;@ path: battle/turn
;@ Far entry 12: aims the skill of wSkillUser again (RunTargetPicker), loads wSkillId and
;@ wSkillTarget from its action and sets up the next battle steps (wBattleStepArg0 1 when called in
;@ sub-step $17, else 2; wBattleSubStep2 2, or 3 for a smart monster when wBattleTemp is 0).
;@ test: skip runs the target pickers
PickTargetForSkill::
;> RunTargetPicker()
	call RunTargetPicker
;>@ac wSkillId = wBattlerAction[2 * wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
;=@ac
	adc h
	ld h, a
	ld a, [hli]
	ld [wSkillId], a
;> wSkillTarget = wBattlerAction[2 * wSkillUser + 1]
	ld a, [hl]
	ld [wSkillTarget], a
;>@w0 wBattleStepArg0 = 1 if wBattleSubStep == 0x17 else 2
	ld a, [wBattleSubStep]
	cp $17
	jr z, .seventeen

	ld a, $02
	ld [wBattleStepArg0], a
;=@w0
	jr .steps

.seventeen:
	ld a, $01
	ld [wBattleStepArg0], a

.steps:
;> wBattleSubStep = 0
	xor a
	ld [wBattleSubStep], a
;> wBattleSubStep2 = 2
	ld a, $02
	ld [wBattleSubStep2], a
;>@cl if wBattlerIntClass[wSkillUser] == 2 and wBattleTemp == 0:
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
	ret nz

;=@cl
	ld a, [wBattleTemp]
	or a
	ret nz

;>     wBattleSubStep2 += 1
	ld hl, wBattleSubStep2
	inc [hl]
	ret


;@ def GetBaseDefense_58(pos: a) -> bc
;@ path: battle/ai/targets
;@ The normal (unboosted) defense of the monster at `pos`: the party record's for the player's
;@ positions 0-2, the monster template of the encounter's species for enemies 4-6, the species
;@ template for slot 3 / 7 (in link battles the party record for all but slot 3).
;@ test: skip loads monster templates through far calls
GetBaseDefense_58::
;> if not wLinkActive:
	push hl
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, .link

;>     if pos < 3:
;>@pm         return GetPartyMonsterWord(pos, addr(wMonDefense))
	ld a, b
	cp $03
	jr c, .party

;>     if (pos & 3) == 3:
;>@sp         template = 0x100 + wBattlerSpecies[pos]
	and $03
	cp $03
	jr z, .species

;>@en     template = mem16[addr(wEncSpecies) + 2 * (pos - 4)]
	ld a, b
	sub $04
	ld hl, wEncSpecies
	add a
	add l
	ld l, a
;=@en
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a

.load:
;>@ld     wNewMonId = template & 0xFF; mem[0xDA13] = template >> 8
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>     return wTemplateDefense + 256 * mem[0xDA24]
	ld a, [wTemplateDefense]
	ld c, a
	ld a, [wTemplateDefense + 1]
	ld b, a
	jr .done

.link:
;> elif (pos & 3) == 3:
;>@ls     template = 0x100 + wBattlerSpecies[pos]   # then as above
	ld a, b
	and $03
	cp $03
	jr z, .species

.party:
;> else:
;>     return GetPartyMonsterWord(pos, addr(wMonDefense))
;=@pm
	ld hl, wMonDefense
	call GetPartyMonsterWord
	jr .done

.species:
;=@sp
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .load

.done:
	pop hl
	ret


;@ def AIPickBestKeyLowScore()
;@ path: battle/ai/targets
;@ Picks the best of three candidates into wNameBattler (index 0-2): the lowest key (wNamePos..+2),
;@ between equal keys the lowest score (wSkillAmount, wTargetScores, wSkillAmount2), a tie of both
;@ decided at random (a number is drawn for every comparison).
;@ test: skip draws random numbers through the link generator
AIPickBestKeyLowScore::
;> wNameDest = addr(wTargetScores)                # pointer to the next score
	ld hl, wTargetScores
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;> wNameBattler = 0                                # best index
	ld a, $00
	ld [wNameBattler], a
;> best = wSkillAmount                             # score 0
	ld hl, wSkillAmount
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@lp for e in (1, 2):
	ld de, $0201

.loop:
;>     BattleRandom_58()
	push hl
	push de
	push bc
	call BattleRandom_58
;>@kb     kb = mem[addr(wNamePos) + (wNameBattler & 3)]
	ld a, [wNameBattler]
	ld hl, wNamePos
	and $03
	add l
	ld l, a
	ld a, $00
;=@kb
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
;>@ke     ke = mem[addr(wNamePos) + (e & 3)]
	ld a, e
	and $03
	ld hl, wNamePos
	add l
	ld l, a
;=@ke
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@cp     s = mem16[wNameDest]
;>     if ke < kb:
;>@tk         best = s; wNameBattler = e
	cp b
	pop bc
	pop de
	pop hl
	jr c, .lower

;>     elif ke == kb:
	jr nz, .next

;=@cp
	push hl
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, [hli]
;=@cp
	ld b, [hl]
	ld c, a
	pop hl
;>@ti         if s < best or (s == best and wRandomHigh >= 0x80):
;>             best = s; wNameBattler = e
	call CompareHLBC
	jr c, .next

	jr nz, .take

	ld a, [wRandomHigh]
	cp $80
	jr c, .next

;=@ti
	jr .take

.lower:
;=@cp
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, [hli]
	ld b, [hl]
;=@cp
	ld c, a

.take:
;=@tk
	ld h, b
	ld l, c
	ld a, e
	ld [wNameBattler], a

.next:
;>@nx     wNameDest += 2
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
	adc $00
	ld [wNameDest + 1], a
;=@nx
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
	adc $00
	ld [wNameDest + 1], a
;=@lp
	inc e
	dec d
	jr nz, .loop

	ret


;@ def AIPickBestKeyHighScore()
;@ path: battle/ai/targets
;@ Like AIPickBestKeyLowScore, but between equal keys the highest score wins.
;@ test: skip draws random numbers through the link generator
AIPickBestKeyHighScore::
;> wNameDest = addr(wTargetScores)                # pointer to the next score
	ld hl, wTargetScores
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;> wNameBattler = 0                                # best index
	ld a, $00
	ld [wNameBattler], a
;> best = wSkillAmount                             # score 0
	ld hl, wSkillAmount
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@lp for e in (1, 2):
	ld de, $0201

.loop:
;>     BattleRandom_58()
	push hl
	push de
	push bc
	call BattleRandom_58
;>@kb     kb = mem[addr(wNamePos) + (wNameBattler & 3)]
	ld a, [wNameBattler]
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@kb
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
;>@ke     ke = mem[addr(wNamePos) + (e & 3)]
	ld a, e
	ld hl, wNamePos
	add l
	ld l, a
;=@ke
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@cp     s = mem16[wNameDest]
;>     if ke < kb:
;>@tk         best = s; wNameBattler = e
	cp b
	pop bc
	pop de
	pop hl
	jr c, .lower

;>     elif ke == kb:
	jr nz, .next

;=@cp
	push hl
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, [hli]
;=@cp
	ld b, [hl]
	ld c, a
	pop hl
;>@ti         if s > best or (s == best and wRandomHigh >= 0x80):
;>             best = s; wNameBattler = e
	call CompareHLBC
	jr c, .take

	jr nz, .next

	ld a, [wRandomHigh]
	cp $80
	jr c, .next

;=@ti
	jr .take

.lower:
;=@cp
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, [hli]
	ld b, [hl]
;=@cp
	ld c, a

.take:
;=@tk
	ld h, b
	ld l, c
	ld a, e
	ld [wNameBattler], a

.next:
;>@nx     wNameDest += 2
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
	adc $00
	ld [wNameDest + 1], a
;=@nx
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
	adc $00
	ld [wNameDest + 1], a
;=@lp
	inc e
	dec d
	jr nz, .loop

	ret


;@ def AIStartScoresAlt() -> c
;@ path: battle/ai/targets
;@ Starts a score list at wSkillAmount (pointer in wNameDest) and returns the first position of the
;@ enemy side in c (and 3 in b).
;@ test: wSkillUser = rng.randint(0, 7)
AIStartScoresAlt::
;> wNameDest = addr(wSkillAmount)
	ld hl, wSkillAmount
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;> return (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	ret


;@ def CheckReflects(pos: c) -> a
;@ path: battle/ai/targets
;@ Nonzero when the monster at `pos` sends spells or attacks back (Bounce or MagicBack, bits $22 of
;@ status byte 2).
;@ test: pos = rng.randint(0, 7)
CheckReflects::
;> return wBattlerStatus[8 * pos + 2] & 0x22
	ld a, c
	ld hl, wBattlerStatus2
	call AddEightTimes
	ld a, [hl]
	and $22
	ret


;@ def AISetTargetFromBest()
;@ path: battle/ai/targets
;@ Makes enemy position wNameBattler (0-2 on the enemy side) the target of the user.
;@ test: wNameBattler = rng.randint(0, 2); wSkillUser = rng.randint(0, 7)
AISetTargetFromBest::
;> wSkillTarget = ((wSkillUser & 4) ^ 4) + wNameBattler
	ld a, [wNameBattler]
	ld c, a
	ld a, [wSkillUser]
	and $04
	xor $04
	add c
;=@st
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AIListPresentEnemies() -> d
;@ path: battle/ai/targets
;@ Lists the enemy positions still standing in wBattleArg0.. and returns their number; the score of
;@ an empty position is moved to the end of the list at wSkillAmount (AIDropScore), so the scores
;@ stay beside their positions.
;@ test: wSkillUser = rng.randint(0, 7)
AIListPresentEnemies::
;> p, c = AIListStart()
	call AIListStart
;> d = 0
	ld b, $03
	ld d, $00

.loop:
;>@lp for c in range(c, c + 3):
;>     if not CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .empty

;>         mem[p] = c; p += 1; d += 1
	ld a, c
	ld [hli], a
	inc d
	jr .next

.empty:
;>     else:
;>         AIDropScore(c)
	call AIDropScore

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> return d
	ret


;@ def AIListStart() -> (hl, c)
;@ path: battle/ai/targets
;@ Returns the list address wBattleArg0 and the first enemy position.
;@ test: wSkillUser = rng.randint(0, 7)
AIListStart::
;> return addr(wBattleArg0), (wSkillUser & 4) ^ 4
	ld hl, wBattleArg0
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ret


;@ def AISortFirst()
;@ path: battle/ai/targets
;@ Moves the candidate with the lowest score to the front: clears the keys, picks with
;@ AIPickBestKeyLowScore and swaps position and score with entry 0.
;@ test: skip draws random numbers through the link generator
AISortFirst::
;> mem[addr(wNamePos)] = 0; mem[addr(wNamePos) + 1] = 0; mem[addr(wNamePos) + 2] = 0
	xor a
	ld hl, wNamePos
	ld [hli], a
	ld [hli], a
	ld [hl], a
;> AIPickBestKeyLowScore()
	call AIPickBestKeyLowScore
;>@sw i = wNameBattler; swap(mem[addr(wBattleArg0)], mem[addr(wBattleArg0) + i])
	ld a, [wNameBattler]
	ld hl, wBattleArg0
	ld de, wBattleArg0
	add e
	ld e, a
	ld a, $00
;=@sw
	adc d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl]
	ld [de], a
;=@sw
	ld a, b
	ld [hl], a
;>@sc swap(mem16[addr(wSkillAmount)], mem16[addr(wSkillAmount) + 2 * i])
	ld hl, wSkillAmount
	ld a, [wNameBattler]
	add a
	add l
	ld l, a
	ld a, $00
;=@sc
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	push hl
	ld e, a
;=@sc
	ld hl, wSkillAmount
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, d
	ld [hld], a
;=@sc
	ld [hl], e
	pop hl
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


;@ def AISortSecond()
;@ path: battle/ai/targets
;@ Moves the candidate with the highest score to the end: picks with AIPickBestKeyHighScore and
;@ swaps position and score with entry 2.
;@ test: skip draws random numbers through the link generator
AISortSecond::
;> AIPickBestKeyHighScore()
	call AIPickBestKeyHighScore
;>@sw i = wNameBattler; swap(mem[addr(wBattleArg2)], mem[addr(wBattleArg0) + i])
	ld a, [wNameBattler]
	ld hl, wBattleArg2
	ld de, wBattleArg0
	add e
	ld e, a
	ld a, $00
;=@sw
	adc d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl]
	ld [de], a
;=@sw
	ld a, b
	ld [hl], a
;>@sc swap(mem16[addr(wSkillAmount2)], mem16[addr(wSkillAmount) + 2 * i])
	ld hl, wSkillAmount
	ld a, [wNameBattler]
	add a
	add l
	ld l, a
	ld a, $00
;=@sc
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	push hl
	ld e, a
;=@sc
	ld hl, wSkillAmount2
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, d
	ld [hld], a
;=@sc
	ld [hl], e
	pop hl
	ld a, b
	ld [hld], a
	ld [hl], c
	ret


;@ path: unused
;@ Leftover code nothing calls: e:hl = hl + bc with the carry in e (ld a, l / add c / ld l, a /
;@ ld a, h / adc b / ld h, a / xor a / adc 0 / ld c, a / ret - the result lands in c, not e).
UnusedAddHLBC24::
	db $7d, $81, $6f, $7c, $88, $67, $af, $ce, $00, $4f, $c9

;@ def Add16To24(x: bc, y: de) -> (e, bc)
;@ path: system/math
;@ 16-bit add with the carry as a third byte: e:bc = x + y.
;@ test: x = rng.randint(0, 0xFFFF)
Add16To24::
;> s = x + y
	ld a, c
	add e
	ld c, a
	ld a, b
	adc d
	ld b, a
;> return 0, s & 0xFFFF                          # (xor a clears the carry first: e is always 0)
	xor a
	adc $00
	ld e, a
	ret


;@ def AIPickLowestKey(pos: c, count: b)
;@ path: battle/ai/targets
;@ Goes on with a lowest-key choice: wBattleArg0 / wBattleArg1 hold the best position and its key so
;@ far; each of the `count` positions from `pos` with a lower key (an equal one at random) takes
;@ over. The winner becomes the user's target.
;@ test: skip draws random numbers through the link generator
AIPickLowestKey::
.loop:
;>@lp for c in range(pos, pos + count):
;>@k     key = mem[addr(wNamePos) + (c & 3)]
	ld a, c
	and $03
	ld hl, wNamePos
	add l
	ld l, a
	ld a, $00
;=@k
	adc h
	ld h, a
	ld d, [hl]
;>     take = key < wBattleArg1
	ld a, [wBattleArg1]
	cp d
	jr c, .next

;>     if key == wBattleArg1:
	jr nz, .take

;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>         wBattleArg0 = c; wBattleArg1 = key
	ld a, c
	ld [wBattleArg0], a
	ld a, d
	ld [wBattleArg1], a

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> wSkillTarget = wBattleArg0
	ld a, [wBattleArg0]
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AIScoreHPDef(pos: c) -> de
;@ path: battle/ai/targets
;@ Score of `pos` for the slash pickers: HP + defense ($FFFF when it overflows); for an empty
;@ position $FFFF and wBattleArg0 = $FF (its "resistance").
;@ test: pos = rng.randint(0, 7)
AIScoreHPDef::
;> if not CheckBattlerPresent(pos):
	push hl
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, .none

;>@hp     s = mem16[addr(wBattlerHP) + 2 * pos] + GetBattlerDefense(pos)
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
;=@hp
	ld a, c
	call GetBattlerDefense
	add hl, de
;>@ov     return min(s, 0xFFFF)
	jr nc, .done

	jr .full

.none:
;>@n1 wBattleArg0 = 0xFF; return 0xFFFF
	ld a, $ff
	ld [wBattleArg0], a

.full:
;=@n1
	ld hl, $ffff

.done:
;=@ov
	ld d, h
	ld e, l
	pop hl
	ret


;@ def AIScoreHP(pos: c) -> de
;@ path: battle/ai/targets
;@ Score of `pos` for WindBeast and GigaSlash: its HP; for an empty position $FFFF and wBattleArg0 =
;@ $FF.
;@ test: pos = rng.randint(0, 7)
AIScoreHP::
;> if not CheckBattlerPresent(pos):
	push hl
	push bc
	ld a, c
	call CheckBattlerPresent
	pop bc
	jr c, .none

;>@hp     return mem16[addr(wBattlerHP) + 2 * pos]
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
	ld l, a
	ld a, $00
;=@hp
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr .done

.none:
;> wBattleArg0 = 0xFF; return 0xFFFF
	ld a, $ff
	ld [wBattleArg0], a
	ld de, $ffff

.done:
	pop hl
	ret


;@ def AITargetResistHPDef(pos: c, count: b)
;@ path: battle/ai/targets
;@ Shared end of the slash pickers: for the `count` positions from `pos`, key = resistance byte
;@ wBattleArg2 masked with wBattleArg3 ($FF masked for an empty position), score = HP + defense (AIScoreHPDef); the
;@ lowest key wins, between equal keys the lowest score, a full tie at random. The winner becomes
;@ the user's target.
;@ test: skip far calls into the resistance table
AITargetResistHPDef::
;> wNameBattler = pos                               # best position so far
	ld a, c
	ld [wNameBattler], a
;> wBattleArg0 = wBattleArg2; wSkillTarget = pos
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;> GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;> s = AIScoreHPDef(pos)
	call AIScoreHPDef
;> wNamePos = wBattleArg0 & wBattleArg3               # best key
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
;> wSkillAmount = s                                  # best score
	ld hl, wSkillAmount
	ld a, e
	ld [hli], a
	ld [hl], d
;>@lp for c in range(pos + 1, pos + count):
	inc c
	dec b

.loop:
;>     wBattleArg0 = wBattleArg2; wSkillTarget = c
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>     GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>     s = AIScoreHPDef(c)
	call AIScoreHPDef
;>@ky     key = wBattleArg0 & wBattleArg3
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld h, a
;>@cm     take = key < wNamePos or (key == wNamePos and s < wSkillAmount)
	ld a, [wNamePos]
	cp h
	jr c, .next

	jr nz, .take

;=@cm
	ld hl, wSkillAmount + 1
	ld a, [hld]
	cp d
	jr c, .next

	jr nz, .take

;=@cm
	ld a, [hl]
	cp e
	jr c, .next

	jr nz, .take

;>     if key == wNamePos and s == wSkillAmount:
;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>@tk         wNamePos = key; wSkillAmount = s; wNameBattler = c
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
	ld hl, wSkillAmount
	ld a, e
;=@tk
	ld [hli], a
	ld [hl], d
	ld a, c
	ld [wNameBattler], a

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> wSkillTarget = wNameBattler
	ld a, [wNameBattler]
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AITargetResistHP(pos: c, count: b)
;@ path: battle/ai/targets
;@ Shared end of the slash pickers: for the `count` positions from `pos`, key = resistance byte
;@ wBattleArg2 masked with wBattleArg3 ($FF masked for an empty position), score = HP (AIScoreHP); the
;@ lowest key wins, between equal keys the lowest score, a full tie at random. The winner becomes
;@ the user's target.
;@ test: skip far calls into the resistance table
AITargetResistHP::
;> wNameBattler = pos                               # best position so far
	ld a, c
	ld [wNameBattler], a
;> wBattleArg0 = wBattleArg2; wSkillTarget = pos
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;> GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;> s = AIScoreHP(pos)
	call AIScoreHP
;> wNamePos = wBattleArg0 & wBattleArg3               # best key
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
;> wSkillAmount = s                                  # best score
	ld hl, wSkillAmount
	ld a, e
	ld [hli], a
	ld [hl], d
;>@lp for c in range(pos + 1, pos + count):
	inc c
	dec b

.loop:
;>     wBattleArg0 = wBattleArg2; wSkillTarget = c
	push bc
	ld a, [wBattleArg2]
	ld [wBattleArg0], a
	ld a, c
	ld [wSkillTarget], a
;>     GetResistByte()
	ld hl, far_GetResistByte
	rst $10
	pop bc
;>     s = AIScoreHP(c)
	call AIScoreHP
;>@ky     key = wBattleArg0 & wBattleArg3
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld h, a
;>@cm     take = key < wNamePos or (key == wNamePos and s < wSkillAmount)
	ld a, [wNamePos]
	cp h
	jr c, .next

	jr nz, .take

;=@cm
	ld hl, wSkillAmount + 1
	ld a, [hld]
	cp d
	jr c, .next

	jr nz, .take

;=@cm
	ld a, [hl]
	cp e
	jr c, .next

	jr nz, .take

;>     if key == wNamePos and s == wSkillAmount:
;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>@tk         wNamePos = key; wSkillAmount = s; wNameBattler = c
	ld a, [wBattleArg0]
	ld hl, wBattleArg3
	and [hl]
	ld [wNamePos], a
	ld hl, wSkillAmount
	ld a, e
;=@tk
	ld [hli], a
	ld [hl], d
	ld a, c
	ld [wNameBattler], a

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> wSkillTarget = wNameBattler
	ld a, [wNameBattler]
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def IsAtMostOne(x: hl) -> carry
;@ path: battle/ai/targets
;@ Carry when `x` is 0 or 1.
;@ test: x = rng.choice([0, 1, 2, 0x100, 0x101, rng.randint(0, 0xFFFF)])
IsAtMostOne::
;> if x >> 8:
;>     return False
	ld a, h
	or a
	jr nz, .no

;>@r return (x & 0xFF) <= 1
	ld a, l
	or a
	jr z, .yes

	cp $01
	jr nz, .no

.yes:
;=@r
	scf
	ret


.no:
;=@r
	ld a, $02
	cp $01
	ret


;@ def GetBaseAgility_58(pos: a) -> bc
;@ path: battle/ai/targets
;@ The normal (unboosted) agility of the monster at `pos`, found like GetBaseDefense_58.
;@ test: skip loads monster templates through far calls
GetBaseAgility_58::
;> if not wLinkActive:
	push hl
	ld b, a
	ld a, [wLinkActive]
	or a
	jr nz, .link

;>     if pos < 3:
;>@pm         return GetPartyMonsterWord(pos, addr(wMonAgility))
	ld a, b
	cp $03
	jr c, .party

;>     if (pos & 3) == 3:
;>@sp         template = 0x100 + wBattlerSpecies[pos]
	and $03
	cp $03
	jr z, .species

;>@en     template = mem16[addr(wEncSpecies) + 2 * (pos - 4)]
	ld a, b
	sub $04
	ld hl, wEncSpecies
	add a
	add l
	ld l, a
;=@en
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a

.load:
;>     wNewMonId = template & 0xFF; mem[0xDA13] = template >> 8
	ld a, l
	ld [wNewMonId], a
	ld a, h
	ld [wNewMonId + 1], a
;>     LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;>     return wTemplateAgility + 256 * mem[0xDA26]
	ld a, [wTemplateAgility]
	ld c, a
	ld a, [wTemplateAgility + 1]
	ld b, a
	jr .done

.link:
;> elif (wLinkActive & 3) == 3:                    # (tests wLinkActive, not pos: a bug)
;>     template = 0x100 + wBattlerSpecies[pos]   # then as above
	and $03
	cp $03
	jr z, .species

.party:
;> else:
;>     return GetPartyMonsterWord(pos, addr(wMonAgility))
;=@pm
	ld hl, wMonAgility
	call GetPartyMonsterWord
	jr .done

.species:
;=@sp
	ld a, b
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld l, [hl]
	ld h, $01
	jr .load

.done:
	pop hl
	ret


;@ path: unused
;@ Code nothing calls (61 bytes): the average agility of the enemies still standing, returned in bc
;@ (sum of wBattlerAgility, count in wNamePos, divided with the routine at $1E0D).
UnusedAverageEnemyAgility::
	db $e5, $01, $00, $00, $fa, $88, $db, $e6, $04, $ee, $04, $5f, $16, $03, $af, $ea
	db $50, $db, $7b, $cd, $a5, $2f, $38, $15, $7b, $21, $03, $dc, $87, $85, $6f, $3e
	db $00, $8c, $67, $2a, $66, $6f, $09, $44, $4d, $21, $50, $db, $34, $1c, $15, $20
	db $e1, $fa, $50, $db, $60, $69, $cd, $0d, $1e, $44, $4d, $e1, $c9

;@ def AIFlipTargetSide()
;@ path: battle/ai/targets
;@ Moves the user's target to the same slot on the other side.
;@ test: wSkillUser = rng.randint(0, 7)
AIFlipTargetSide::
;>@t wBattlerAction[2 * wSkillUser + 1] ^= 4
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
	xor $04
	ld [hl], a
	ret


;@ def AIPickHighestScore()
;@ path: battle/ai/targets
;@ Targets the enemy with the highest of the three scores at wSkillAmount, wTargetScores and
;@ wSkillAmount2 (a tie decided at random).
;@ test: skip draws random numbers through the link generator
AIPickHighestScore::
;> wNameDest = addr(wTargetScores)
	ld hl, wTargetScores
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;> wNameBattler = 0
	ld a, $00
	ld [wNameBattler], a
;> best = wSkillAmount
	ld hl, wSkillAmount
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>@lp for e in (1, 2):
	ld de, $0201

.loop:
;>@s     s = mem16[wNameDest]
	push hl
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, [hli]
;=@s
	ld b, [hl]
	ld c, a
	pop hl
;>     take = best < s
	call CompareHLBC
	jr c, .take

;>     if best == s:
	jr nz, .next

;>@rn         BattleRandom_58()
	push af
	push bc
	push de
	push hl
	call BattleRandom_58
;=@rn
	pop hl
	pop de
	pop bc
	pop af
;>         take = wRandomHigh >= 0x80
	ld a, [wRandomHigh]
	cp $80
	jr c, .next

.take:
;>     if take:
;>         best = s; wNameBattler = e
	ld h, b
	ld l, c
	ld a, e
	ld [wNameBattler], a

.next:
;>@nx     wNameDest += 2
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
	adc $00
	ld [wNameDest + 1], a
;=@nx
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
	adc $00
	ld [wNameDest + 1], a
;=@lp
	inc e
	dec d
	jr nz, .loop

;> wSkillTarget = ((wSkillUser & 4) ^ 4) + wNameBattler
	ld a, [wNameBattler]
	ld c, a
	ld a, [wSkillUser]
	and $04
	xor $04
	add c
;=@st
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AIPickLowestOwnScore()
;@ path: battle/ai/targets
;@ Targets the monster of the user's own side with the lowest of the three scores at wTargetScores,
;@ wSkillAmount2 and wSkillTempPtr (on a tie the later one).
;@ test: wSkillUser = rng.randint(0, 7)
AIPickLowestOwnScore::
;> wNameBattler = 0; low = wTargetScores
	ld a, $00
	ld [wNameBattler], a
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
;> if not low < wSkillAmount2:
	ld a, [wSkillAmount2]
	ld c, a
	ld a, [wSkillAmount2 + 1]
	ld b, a
	call CompareHLBC
	jr c, .third

;>     wNameBattler = 1; low = wSkillAmount2
	ld a, $01
	ld [wNameBattler], a
	ld a, [wSkillAmount2]
	ld l, a
	ld a, [wSkillAmount2 + 1]
	ld h, a

.third:
;> if not low < wSkillTempPtr:
;>@w2     wNameBattler = 2
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [wSkillTempPtr + 1]
	ld b, a
	call CompareHLBC
	jr c, .done

;=@w2
	ld a, $02
	ld [wNameBattler], a

.done:
;> wSkillTarget = (wSkillUser & 4) + wNameBattler
	ld a, [wNameBattler]
	ld c, a
	ld a, [wSkillUser]
	and $04
	add c
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AIStartScores() -> c
;@ path: battle/ai/targets
;@ Starts a score list at wSkillAmount (pointer in wNameDest, filled by AIStoreScore) and returns
;@ the first enemy position in c (and 3 in b).
;@ test: wSkillUser = rng.randint(0, 7)
AIStartScores::
;> wNameDest = addr(wSkillAmount)
	ld hl, wSkillAmount
	ld a, l
	ld [wNameDest], a
	ld a, h
	ld [wNameDest + 1], a
;> return (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03
	ret


;@ def AIStoreScore(score: de)
;@ path: battle/ai/targets
;@ Stores `score` at the score list pointer wNameDest and moves it on by 2.
;@ test: skip writes through the pointer in wNameDest
AIStoreScore::
;>@w mem16[wNameDest] = score
	ld a, [wNameDest]
	ld l, a
	ld a, [wNameDest + 1]
	ld h, a
	ld a, e
	ld [hli], a
;=@w
	ld a, d
	ld [hl], a
;>@n wNameDest += 2
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
;=@n
	adc $00
	ld [wNameDest + 1], a
	ld a, [wNameDest]
	add $01
	ld [wNameDest], a
	ld a, [wNameDest + 1]
;=@n
	adc $00
	ld [wNameDest + 1], a
	ret


;@ def AITargetEnemySide()
;@ path: battle/ai/targets
;@ Target picker of the skills that hit the whole enemy group (most attack spells, breaths, the
;@ group status spells): the first enemy still standing.
;@ test: wSkillUser = rng.randint(0, 7)
AITargetEnemySide::
;> wBattleArg0 = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld [wBattleArg0], a
;> AITargetFirstPresent()
	call AITargetFirstPresent
	ret


;@ def AITargetOwnSide()
;@ path: battle/ai/targets
;@ Target picker of the skills for the whole own group (Increase, HealUs, Barrier, ...): the first
;@ monster of the user's side still standing.
;@ test: wSkillUser = rng.randint(0, 7)
AITargetOwnSide::
;> wBattleArg0 = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld [wBattleArg0], a
;> AITargetFirstPresent()
	call AITargetFirstPresent
	ret


;@ def AITargetFirstPresent()
;@ path: battle/ai/targets
;@ Targets the first position still standing of the side starting at wBattleArg0 (its first slot
;@ when there is none).
;@ test: wBattleArg0 = rng.choice([0, 4]); wSkillUser = rng.randint(0, 7)
AITargetFirstPresent::
;> c = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a
;>@lp for c in range(c, c + 3):
	ld b, $03

.loop:
;>     if not CheckBattlerPresent(c):
;>         break
	ld a, c
	call CheckBattlerPresent
	jr nc, jr_058_62ed

;=@lp
	inc c
	dec b
	jr nz, .loop

;> else:
;>     c = wBattleArg0
	ld a, [wBattleArg0]
	ld c, a

jr_058_62ed:
;>@st wBattlerAction[2 * wSkillUser + 1] = c
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld a, c
	ld [hl], a
	ret


;@ def AITargetSweep()
;@ path: battle/ai/targets
;@ Target picker of ThickFog, CALLHOROR and FILTHZONE, called for every hit: the first hit takes the
;@ first enemy standing; later hits move on to the next one standing (up to slot 3); from slot 3 the
;@ target goes back to the first slot of the user's own side when the target was on the other side.
;@ test: skip the case of nobody before slot 3 is written as a break (it goes on as a later hit)
AITargetSweep::
;> if wHitCount == 0:
	ld a, [wHitCount]
	or a
	jr nz, .later

;>     c = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a

.first:
;>@f1     while CheckBattlerPresent(c):
;>@f2         if (c & 3) == 3:                       # nobody before slot 3:
;>             break                              # (goes on as a later hit, below)
	ld a, c
	call CheckBattlerPresent
	jr nc, .store

	ld a, c
	and $03
;=@f2
	cp $03
	jr z, .later

;>         c += 1
	inc c
;=@f1
	jr .first

.store:
;>@st     wBattlerAction[2 * wSkillUser + 1] = c
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld [hl], c
	ret


.later:
;> else:
;>@t     c = wBattlerAction[2 * wSkillUser + 1]
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
	ld c, a
;>     if (c & 3) >= 3:
	ld a, c
	and $03
	cp $03
	jr c, .next

;>         b = (c & 4) ^ 4
	ld a, c
	and $04
	xor $04
	ld b, a
;>         if (wSkillUser & 4) == b:
;>             wBattlerAction[2 * wSkillUser + 1] = b
	ld a, [wSkillUser]
	and $04
	cp b
	ret nz

	ld [hl], b
	ret


.next:
;>@nx     else:
;>@n1         c += 1
	inc c

.scan:
;>@n2         while CheckBattlerPresent(c):
;>             if (c & 3) == 3:
;>                 return
	ld a, c
	call CheckBattlerPresent
	jr nc, .store

	ld a, c
	and $03
;=@n2
	cp $03
	ret z

;>             c += 1
	inc c
;=@n2
	jr .scan

;>         wBattlerAction[2 * wSkillUser + 1] = c     # (.store)

;@ def AITargetOwnFirst()
;@ path: battle/ai/targets
;@ Target picker of Farewell, LifeSong, LifeDance and ALLREVIVE: the first slot of the user's side
;@ (taken as the whole side).
;@ test: wSkillUser = rng.randint(0, 7)
AITargetOwnFirst::
;> c = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld c, a
;> wBattlerAction[2 * wSkillUser + 1] = c       # AITargetFirstPresent's ending
	jr jr_058_62ed

;@ def AITargetSelf()
;@ path: battle/ai/targets
;@ Target picker of the skills that work on the user itself (ChargeUP, Imitate, Dodge, the defence
;@ stances, Meditate, Run, ...): the user.
;@ test: wSkillUser = rng.randint(0, 7)
AITargetSelf::
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillUser
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
	add a
	add l
	ld l, a
	ld a, $00
;=@st
	adc h
	ld h, a
	ld a, [wSkillUser]
	ld [hl], a
	ret


;@ def AITargetAnyone()
;@ path: battle/ai/targets
;@ Far entry 4 and the picker of Massacre: any of the eight positions still standing, drawn from the
;@ current random number: wRandomHigh, wRandomLow, their or and their sum (each & 7) are tried in turn,
;@ then wRandomLow counts down until a position standing is found. Also loads wSkillId.
;@ test: skip loops for ever when no position is standing
AITargetAnyone::
;> c = wRandomHigh
	ld a, [wRandomHigh]
	ld c, a
;> if not CheckBattlerPresent(c & 7):
;>@p1     pick = c
	and $07
	call CheckBattlerPresent
	jr nc, .pickC

;> else:
;>     b = wRandomLow
	ld a, [wRandomLow]
	ld b, a
;>     if not CheckBattlerPresent(b & 7):
;>@p2         pick = b
	and $07
	call CheckBattlerPresent
	jr nc, .pickB

;>     elif not CheckBattlerPresent((c := ((b & 7) | c) & 7)):
;>@p3         pick = c
	or c
	and $07
	call CheckBattlerPresent
	ld c, a
	jr nc, .pickC

;>     elif not CheckBattlerPresent((c | b) & 7):
;>@p4         pick = c | b
	or b
	and $07
	call CheckBattlerPresent
	jr nc, .pickOr

;>     elif not CheckBattlerPresent((b + c) & 7):
;>@p5         pick = b + c
	ld a, b
	add c
	and $07
	call CheckBattlerPresent
	jr nc, .pickSum

.down:
;>     else:
;>         b -= 1
;>         while CheckBattlerPresent(b & 7): b -= 1
	dec b
	ld a, b
	and $07
	call CheckBattlerPresent
	jr c, .down

;>         pick = b
	jr .pickB

.pickC:
;=@p1
;=@p3
	ld a, c
	jr .set

.pickB:
;=@p2
	ld a, b
	jr .set

.pickOr:
;=@p4
	ld a, c
	or b
	jr .set

.pickSum:
;=@p5
	ld a, b
	add c

.set:
;> c = pick & 7
	and $07
	ld c, a
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
	ld a, [hli]
	ld [wSkillId], a
;> wBattlerAction[2 * wSkillUser + 1] = c
	ld [hl], c
	ret


;@ def AITargetSelfLoadSkill()
;@ path: battle/ai/targets
;@ Target picker of the items, Chance, Focus and the dragon calls: loads wSkillId and aims at the
;@ user.
;@ test: wSkillUser = rng.randint(0, 7)
AITargetSelfLoadSkill::
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
	ld a, [hli]
	ld [wSkillId], a
;> wBattlerAction[2 * wSkillUser + 1] = wSkillUser
	ld a, [wSkillUser]
	ld [hl], a
	ret


;@ def CountPresent(side: e) -> d
;@ path: battle/ai/targets
;@ Number of monsters standing among the three positions from `side` (also returns c = side, b = 0).
;@ test: side = rng.choice([0, 4])
CountPresent::
;> d = 0
	ld c, e
	ld b, $03
	ld d, $00

.loop:
;>@lp for c in range(side, side + 3):
;>     if not CheckBattlerPresent(c):
;>         d += 1
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	inc d

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> return d
	ret


;@ def AITargetRandomPresent(count: d, side: e)
;@ path: battle/ai/targets
;@ Aims at one of the `count` monsters standing from `side` on, drawn at random (random number
;@ modulo count), and loads wSkillId.
;@ test: skip draws random numbers through the link generator
AITargetRandomPresent::
;> BattleRandom_58()
	call BattleRandom_58
;>@k k = wRandomHigh % count + 1; c = side
	ld a, [wRandomHigh]
	ld b, a
	ld a, d
	push de
	call Divide8
;=@k
	pop bc
	inc a
	ld e, a

.loop:
;>@wl while True:
;>     if not CheckBattlerPresent(c):
;>@w2         k -= 1
;>@w3         if k == 0: break
;>@w4     c += 1
	ld a, c
	call CheckBattlerPresent
	jr nc, .found

.skip:
;=@w4
	inc c
	jr .loop

.found:
;=@w2
	dec e
;=@w3
	jr nz, .skip

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
	ld a, [hli]
	ld [wSkillId], a
;> wBattlerAction[2 * wSkillUser + 1] = c
	ld a, c
	ld [hl], a
	ret


;@ def AITargetRandomEnemy()
;@ path: battle/ai/targets
;@ Far entry 5 and the picker of HighJump, QuadHits, CallHelp, YellHelp, HitEnemy and Trip, and of
;@ every skill for a dim monster: a random enemy still standing.
;@ test: skip draws random numbers through the link generator
AITargetRandomEnemy::
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld e, a
;> AITargetRandomPresent(CountPresent(side), side)
	call CountPresent
	call AITargetRandomPresent
	ret


;@ path: unused
;@ Code nothing calls (62 bytes): an older random-enemy picker - a random slot 0-3 of the enemy side,
;@ walked down to a position standing (wrapping to slot 3), stored as the target with wSkillId.
UnusedRandomEnemy::
	db $cd, $3e, $5c, $fa, $88, $db, $e6, $04, $ee, $04, $47, $fa, $99, $c8, $e6, $03
	db $b0, $4f, $79, $cd, $a5, $2f, $30, $0f, $79, $d6, $01, $4f, $38, $03, $b8, $30
	db $f1, $78, $f6, $03, $4f, $18, $eb, $78, $b1, $4f, $fa, $88, $db, $21, $ec, $dc
	db $87, $85, $6f, $3e, $00, $8c, $67, $2a, $ea, $8a, $db, $79, $77, $c9

;@ def AITargetRandomAlly()
;@ path: battle/ai/targets
;@ Picker of HitAlly, and of the support skills for a dim monster: a random monster of the user's
;@ side still standing.
;@ test: skip draws random numbers through the link generator
AITargetRandomAlly::
;> side = wSkillUser & 4
	ld a, [wSkillUser]
	and $04
	ld e, a
;> AITargetRandomPresent(CountPresent(side), side)
	call CountPresent
	call AITargetRandomPresent
	ret


;@ path: unused
;@ Code nothing calls (118 bytes): an older random-ally picker - a random slot of the user's side
;@ walked down to a position standing; for Vivify / Revive ($30, $31) it looks for an empty or
;@ defeated position instead.
UnusedRandomAlly::
	db $fa, $88, $db, $e6, $04, $47, $fa, $99, $c8, $e6, $03, $b0, $4f, $fa, $88, $db
	db $21, $ec, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $7e, $fe, $30, $28, $07, $fe
	db $31, $28, $03, $79, $18, $1f, $79, $4f, $21, $1b, $dd, $85, $6f, $3e, $00, $8c
	db $67, $7e, $fe, $ff, $20, $25, $79, $d6, $01, $38, $03, $b8, $30, $e9, $fa, $88
	db $db, $f6, $03, $18, $e2, $4f, $cd, $a5, $2f, $30, $10, $79, $d6, $01, $4f, $38
	db $03, $b8, $30, $f1, $fa, $88, $db, $f6, $03, $18, $ea, $fa, $88, $db, $e6, $04
	db $b1, $4f, $fa, $88, $db, $21, $ec, $dc, $87, $85, $6f, $3e, $00, $8c, $67, $2a
	db $ea, $8a, $db, $79, $77, $c9

;@ def AIScoreFamily(pos: c, count: b)
;@ path: battle/ai/targets
;@ Scores the `count` enemies from `pos` for the family slashes (DrakSlash, BeastCut, ...): 0 for an
;@ empty position, 1 for a monster of another family than wBattleArg0, else its HP inverted (the
;@ weakest of the family scores highest); then AIPickHighestScore.
;@ test: skip far calls into the monster table
AIScoreFamily::
.loop:
;>@lp for c in range(pos, pos + count):
;>     if CheckBattlerPresent(c):
	push bc
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@n0         score = 0
;>     elif CheckFamily(c):
	call CheckFamily
	jr nz, .other

;>@hp         score = mem16[addr(wBattlerHP) + 2 * c] ^ 0xFFFF
	pop bc
	push bc
	ld a, c
	ld hl, wBattlerHP
	add a
	add l
;=@hp
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	xor $ff
;=@hp
	ld e, a
	ld a, [hl]
	xor $ff
	ld d, a
	jr .store

.none:
;=@n0
	ld de, $0000
	jr .store

.other:
;>     else:
;>         score = 1
	ld de, $0001

.store:
;>     AIStoreScore(score)
	call AIStoreScore
;=@lp
	pop bc
	inc c
	dec b
	jr nz, .loop

;> AIPickHighestScore()
	call AIPickHighestScore
	ret


;@ def CheckFamily(pos: c) -> zero
;@ path: battle/ai/targets
;@ Zero (True) when the monster at `pos` belongs to family wBattleArg0 (byte 0 of its MonsterStats
;@ record, loaded into wMonStats).
;@ test: skip far call into the monster table
CheckFamily::
;>@sp wMonSpecies = wBattlerSpecies[pos]
	ld a, c
	ld hl, wBattlerSpecies
	add l
	ld l, a
	ld a, $00
	adc h
;=@sp
	ld h, a
	ld a, [hl]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> return wMonStats[0] == wBattleArg0
	ld a, [wMonStats]
	ld hl, wBattleArg0
	cp [hl]
	ret


;@ def AIRandomEnemyIfDim() -> zero
;@ path: battle/ai/targets
;@ A dim monster (intelligence class 0) aims at a random enemy: returns zero (True) when it did so.
;@ test: skip draws random numbers through the link generator
AIRandomEnemyIfDim::
;> if GetUserIntClass():
;>     return False
	call GetUserIntClass
	ret nz

;> AITargetRandomEnemy()
;> return True
	call AITargetRandomEnemy
	xor a
	ret


;@ def AIRandomAllyIfDim() -> zero
;@ path: battle/ai/targets
;@ A dim monster aims a support skill at a random monster of its side: returns zero (True) when it
;@ did so.
;@ test: skip draws random numbers through the link generator
AIRandomAllyIfDim::
;> if GetUserIntClass():
;>     return False
	call GetUserIntClass
	ret nz

;> AITargetRandomAlly()
;> return True
	call AITargetRandomAlly
	xor a
	ret


;@ def GetUserIntClass() -> a
;@ path: battle/ai/targets
;@ Intelligence class of the monster using the skill (0 dim, 1 normal, 2 smart).
;@ test: wSkillUser = rng.randint(0, 7)
GetUserIntClass::
;>@c return wBattlerIntClass[wSkillUser]
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	ld a, [hl]
	or a
	ret


;@ def KnowsBreathSkill(pos: a) -> carry
;@ path: battle/ai/targets
;@ Carry when one of the eight skills of the monster at `pos` is a breath or air skill: SuckAir ($43),
;@ FireAir .. WhiteAir ($5C-$63), SleepAir .. PoisonAir ($6A-$6D) or SuckAll ($8F).
;@ test: pos = rng.randint(0, 7)
KnowsBreathSkill::
;> p = addr(wBattlerSkills) + 16 * pos + 1           # skill numbers, 2 bytes apart
	ld hl, wBattlerSkills + 1
	swap a
	add l
	ld l, a
	ld a, $00
	adc h
;=@lp
	ld h, a
	ld b, $08

.loop:
;>@lp for i in range(8):
;>     s = mem[p + 2 * i]
;>@br     if s == 0x43 or 0x5C <= s < 0x64 or 0x6A <= s < 0x6E or s == 0x8F:
;>@yes         return True
	ld a, [hl]
	cp $43
	jr z, .yes

	cp $5c
	jr c, .next

;=@br
	cp $64
	jr c, .yes

	cp $6a
	jr c, .next

	cp $6e
	jr c, .yes

;=@br
	cp $8f
	jr z, .yes

.next:
;=@lp
	inc hl
	inc hl
	dec b
	jr nz, .loop

;> return False
	xor a
	ret


.yes:
;=@yes
	scf
	ret


;@ path: unused
;@ Code nothing calls (112 bytes), two routines: carry when every enemy standing is protected
;@ (high in the sky, dodging or in a defence stance), and carry when the monster at wSkillTarget is.
UnusedEnemiesProtected::
	db $c5, $d5, $e5, $fa, $88, $db, $e6, $04, $ee, $04, $4f, $06, $03, $1e, $00, $16
	db $00, $79, $d5, $cd, $a5, $2f, $d1, $38, $19, $1c, $79, $21, $06, $db, $cd, $6c
	db $2f, $2a, $e6, $0c, $20, $0b, $23, $2a, $e6, $28, $20, $05, $7e, $e6, $07, $28
	db $01, $14, $0c, $05, $20, $db, $7a, $bb, $28, $03, $37, $18, $04, $3e, $0a, $fe
	db $01, $e1, $d1, $c1, $c9, $e5, $fa, $89, $db, $cd, $a5, $2f, $38, $1c, $fa, $89
	db $db, $21, $06, $db, $cd, $6c, $2f, $2a, $e6, $0c, $20, $0e, $23, $2a, $e6, $28
	db $20, $08, $7e, $e6, $07, $20, $03, $37, $18, $04, $3e, $0a, $fe, $01, $e1, $c9

;@ def CheckHittable(pos: c) -> carry
;@ path: battle/ai/targets
;@ Carry when the monster at `pos` is standing and not high in the sky (HighJump).
;@ test: pos = rng.randint(0, 7)
CheckHittable::
;> if CheckBattlerPresent(pos):
;>     return False
	push hl
	ld a, c
	call CheckBattlerPresent
	jr c, .no

;>@r return not wBattlerStatus[8 * pos + 4] & 0x0C
	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
	ld a, [hl]
	and $0c
	jr nz, .no

;=@r
	scf
	jr .done

.no:
;=@r
	ld a, $0a
	cp $01

.done:
	pop hl
	ret


;@ def AIAimPlainInstead() -> zero
;@ path: battle/ai/targets
;@ For the status and attack spell pickers: a monster that is not smart and is an enemy in a normal
;@ battle (or in slot 3) aims like a plain attack (AITargetWeakAtRandom) instead of scoring the
;@ targets. Zero (True) when it did.
;@ test: skip draws random numbers through the link generator
AIAimPlainInstead::
;>@c if wBattlerIntClass[wSkillUser] == 2:
;>@f     return False
	ld a, [wSkillUser]
	ld hl, wBattlerIntClass
	add l
	ld l, a
	ld a, $00
	adc h
;=@c
	ld h, a
	ld a, [hl]
	cp $02
	jr z, .score

;> if (wSkillUser & 3) != 3 and (wLinkActive or wSkillUser < 4):
;>@g     return False
	ld a, [wSkillUser]
	and $03
	cp $03
	jr z, .plain

	ld a, [wLinkActive]
	or a
;=@g
	jr nz, .score

	ld a, [wSkillUser]
	cp $04
	jr c, .score

.plain:
;> AITargetWeakAtRandom()
;> return True
	call AITargetWeakAtRandom
	xor a
	or a
	ret


.score:
;=@f
	ld a, $01
	or a
	ret


;@ def AIPickLowestHPRatio()
;@ path: battle/ai/targets
;@ Healing choice of AIHealByRatio: the own position with the largest max HP / HP quotient
;@ (wTargetScores list), between equal ones the larger remainder (wSkillStatusPtr list); the first
;@ wins ties.
;@ test: skip compares lists kept in scratch variables
AIPickLowestHPRatio::
;> wNameDest = 0; mem[0xDB5F] = 1; wNameBattler = 2   # best, candidate, candidates left
	ld a, $00
	ld [wNameDest], a
	ld a, $01
	ld [wNameDest + 1], a
	ld a, $02
	ld [wNameBattler], a

.loop:
;>@lp while wNameBattler:
;>@qc     qc = mem16[addr(wTargetScores) + 2 * mem[0xDB5F]]
	ld a, [wNameDest + 1]
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
;=@qc
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>@qb     qb = mem16[addr(wTargetScores) + 2 * mem[addr(wNameDest)]]
	ld a, [wNameDest]
	ld hl, wTargetScores
	add a
	add l
	ld l, a
	ld a, $00
;=@qb
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
;>     take = qb < qc
	call CompareHLBC
	jr c, .take

;>     if qb == qc:
	jr nz, .next

;>@rc         rc = mem16[addr(wSkillStatusPtr) + 2 * mem[0xDB5F]]
	ld a, [wNameDest + 1]
	ld hl, wSkillStatusPtr
	add a
	add l
	ld l, a
	ld a, $00
;=@rc
	adc h
	ld h, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
;>@rb         take = mem16[addr(wSkillStatusPtr) + 2 * mem[addr(wNameDest)]] < rc
	ld a, [wNameDest]
	ld hl, wSkillStatusPtr
	add a
	add l
	ld l, a
	ld a, $00
;=@rb
	adc h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CompareHLBC
;=@rb
	jr nc, .next

.take:
;>     if take:
;>         mem[addr(wNameDest)] = mem[0xDB5F]
	ld a, [wNameDest + 1]
	ld [wNameDest], a

.next:
;>     mem[0xDB5F] += 1; wNameBattler -= 1
	ld hl, wNameDest + 1
	inc [hl]
	ld a, [wNameBattler]
	dec a
	ld [wNameBattler], a
;=@lp
	jr nz, .loop

;> wSkillTarget = (wSkillUser & 4) + mem[addr(wNameDest)]
	ld a, [wNameDest]
	ld c, a
	ld a, [wSkillUser]
	and $04
	add c
	ld [wSkillTarget], a
;>@st wBattlerAction[2 * wSkillUser + 1] = wSkillTarget
	ld a, [wSkillUser]
	ld hl, wBattlerAction + 1
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


;@ def AIDropScore(pos: c)
;@ path: battle/ai/targets
;@ Moves the score of slot `pos & 3` (an empty position) to the end of the three scores at
;@ wSkillAmount, wTargetScores, wSkillAmount2 by swapping it down.
;@ test: pos = rng.randint(0, 6)
AIDropScore::
;> slot = pos & 3
	push hl
	push de
	ld a, c
	and $03
;> if slot == 2:
;>     return
	cp $02
	jr z, .done

;> if slot != 1:                                # slot 0 (or 3)
	cp $01
	jr z, .second

;>@s1     t = wSkillAmount; wSkillAmount = wTargetScores; wTargetScores = t
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	ld a, [wTargetScores]
	ld e, a
;=@s1
	ld a, [wTargetScores + 1]
	ld d, a
	ld a, l
	ld [wTargetScores], a
	ld a, h
	ld [wTargetScores + 1], a
;=@s1
	ld a, e
	ld [wSkillAmount], a
	ld a, d
	ld [wSkillAmount + 1], a

.second:
;>@s2 t = wTargetScores; wTargetScores = wSkillAmount2; wSkillAmount2 = t
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [wSkillAmount2]
	ld e, a
;=@s2
	ld a, [wSkillAmount2 + 1]
	ld d, a
	ld a, l
	ld [wSkillAmount2], a
	ld a, h
	ld [wSkillAmount2 + 1], a
;=@s2
	ld a, e
	ld [wTargetScores], a
	ld a, d
	ld [wTargetScores + 1], a

.done:
;=@s2
	pop de
	pop hl
	ret


;@ def FixActionTarget()
;@ path: battle/items
;@ Far entry 13: checks the target of an action before it runs. For a monster (FixGroupTarget) a
;@ group skill's target moves to the first position of the group still standing. For Terry's meat
;@ ($C2-$C6) thrown at the enemies: the first enemy standing that is not an iron lump (Ironize),
;@ else the first one standing; other items go through FixGroupTarget too.
;@ test: skip far call into the skill table
FixActionTarget::
;> if wSkillUser != 0x10:                          # a monster
	ld a, [wSkillUser]
	cp $10
	jr z, .item

;>@sk     wBattleArg0 = wBattlerAction[2 * wSkillUser]
	ld hl, wBattlerAction
	add a
	add l
	ld l, a
	ld a, $00
	adc h
;=@sk
	ld h, a
	ld a, [hli]
	ld [wBattleArg0], a
;>     return FixGroupTarget(addr(wBattlerAction) + 2 * wSkillUser + 1)
	call FixGroupTarget
	ret


.item:
;> wBattleArg0 = wBattleItemEffect
	ld hl, wBattleItemEffect
	ld a, [hld]
	ld [wBattleArg0], a
;> if not 0xC2 <= wBattleItemEffect < 0xC7:
;>     return FixGroupTarget(addr(wBattleItemTarget))
	cp $c2
	jr c, FixGroupTarget

	cp $c7
	jr nc, FixGroupTarget

;> if wBattleItemTarget < 4:
;>     return
	ld a, [hl]
	cp $04
	ret c

;> c = wBattleItemTarget & 4; first = 0xFF
	and $04
	ld c, a
	ld b, $03
	ld d, $ff

.loop:
;>@lp for c in range(c, c + 3):
;>     if not CheckBattlerPresent(c):
;>@f1         if first == 0xFF:
;>@f2             first = RememberFirst(c)
;>@ir         if not wBattlerStatus[8 * c + 5] & 0xC0:   # no iron lump
;>@br             break
	ld a, c
	call CheckBattlerPresent
	jr nc, .standing

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> else:
;>     if first == 0xFF:
;>         return
	ld a, d
	cp $ff
	ret z

;>     c = first
	ld c, d
	jr .set

.standing:
;=@f1
	ld a, d
	cp $ff
;=@f2
	call z, RememberFirst
;=@ir
	ld a, c
	ld hl, wBattlerStatus5
	call AddEightTimes
	ld a, [hl]
	and $c0
;=@br
	jr nz, .next

.set:
;> wBattleItemTarget = c
	ld hl, wBattleItemTarget
	ld [hl], c
	ret


;@ def RememberFirst(c: c) -> d
;@ path: battle/items
;@ Returns c (the first enemy standing, for FixActionTarget).
;@ test: c = rng.randint(0, 7)
RememberFirst::
;> return c
	ld d, c
	ret


;@ def FixGroupTarget(target: hl)
;@ path: battle/ai/targets
;@ For skill wBattleArg0 (record byte 2 from GetSkillWord): unless it hits one monster, moves the
;@ target at `target` on to the next position standing (not past slot 2).
;@ test: skip far call into the skill table
FixGroupTarget::
;> wBattleArg1 = 0; wBattleArg2 = 2
	ld a, $00
	ld [wBattleArg1], a
	ld a, $02
	ld [wBattleArg2], a
;> GetSkillWord()
	push hl
	ld hl, far_GetSkillWord
	rst $10
	pop hl
;> if (wBattleArg0 & 3) == 1:                        # one target
;>     return
	ld a, [wBattleArg0]
	and $03
	cp $01
	ret z

.loop:
;>@lp while CheckBattlerPresent(mem[target]):
;>     if (mem[target] & 3) == 2:
;>@r2         return
	ld a, [hl]
	call CheckBattlerPresent
	ret nc

	ld a, [hl]
	and $03
;=@r2
	cp $02
	ret z

;>     mem[target] += 1
	inc [hl]
;=@lp
	jr .loop

;@ def AIAttackWeight()
;@ path: battle/ai/targets
;@ Far entry 11: how much the AI likes the plain Attack, into wAttackWeight: 20, +10 for each step the
;@ user's attack reaches over the lowest enemy defense (1, 1.5, 2, 2.5 times it), +30 when its attack
;@ is doubled or charged (status byte 1 bits 2-3, byte 4 bits 0-1); 1 when no enemy can be hit (all
;@ in the sky, dodging or in the BladeD stance). Values are capped at 255.
;@ test: skip compares stats of all positions
AIAttackWeight::
;> wAttackWeight = 20
	ld a, $14
	ld [wAttackWeight], a
;> AILowestEnemyDefense()                          # into wSkillAmount
	call AILowestEnemyDefense
;>@a1 if GetBattlerAttack(wSkillUser) >= wSkillAmount:
	ld a, [wSkillUser]
	call GetBattlerAttack
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
;=@a1
	call CompareHLBC
	jp c, .boosts

;>     AddCapped(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped
;>@a2     if GetBattlerAttack(wSkillUser) >= wSkillAmount + wSkillAmount // 2:
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	srl b
	rr c
;=@a2
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	add hl, bc
	push hl
;=@a2
	ld a, [wSkillUser]
	call GetBattlerAttack
	pop bc
	call CompareHLBC
	jr c, .boosts

;>         AddCapped(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped
;>@a3         if GetBattlerAttack(wSkillUser) >= 2 * wSkillAmount:
	ld a, [wSkillAmount]
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	ld a, [wSkillAmount]
	ld l, a
;=@a3
	ld a, [wSkillAmount + 1]
	ld h, a
	add hl, bc
	push hl
	ld a, [wSkillUser]
	call GetBattlerAttack
;=@a3
	pop bc
	call CompareHLBC
	jr c, .boosts

;>             AddCapped(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped
;>@a4             if GetBattlerAttack(wSkillUser) >= 2 * wSkillAmount + wSkillAmount // 2:
	ld a, [wSkillAmount]
	ld l, a
	ld a, [wSkillAmount + 1]
	ld h, a
	add hl, hl
	ld a, [wSkillAmount]
;=@a4
	ld c, a
	ld a, [wSkillAmount + 1]
	ld b, a
	srl b
	rr c
	add hl, bc
;=@a4
	push hl
	ld a, [wSkillUser]
	call GetBattlerAttack
	pop bc
	call CompareHLBC
	jr c, .boosts

;>                 AddCapped(addr(wAttackWeight), 10)
	ld hl, wAttackWeight
	ld b, $0a
	call AddCapped

.boosts:
;>@bo if wBattlerStatus[8 * wSkillUser + 1] & 0x0C or wBattlerStatus[8 * wSkillUser + 4] & 0x03:
	ld a, [wSkillUser]
	ld hl, wBattlerStatus1
	call AddEightTimes
	ld a, [hli]
	and $0c
	jr nz, .boosted

;=@bo
	inc hl
	inc hl
	ld a, [hl]
	and $03
	jr z, .targets

.boosted:
;>     AddCapped(addr(wAttackWeight), 30)
	ld hl, wAttackWeight
	ld b, $1e
	call AddCapped

.targets:
;> c = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

.loop:
;>@lp for c in range(c, c + 3):
;>@ok     if (not CheckBattlerPresent(c) and not wBattlerStatus[8 * c + 4] & 0x0C
;>             and not wBattlerStatus[8 * c + 6] & 0x20 and not wBattlerStatus[8 * c + 7] & 0x04): return
	ld a, c
	call CheckBattlerPresent
	jr c, .next

	ld a, c
	ld hl, wBattlerStatus4
	call AddEightTimes
;=@ok
	ld a, [hli]
	and $0c
	jr nz, .next

	inc hl
	bit 5, [hl]
	jr nz, .next

;=@ok
	inc hl
	bit 2, [hl]
;=@ok
	ret z

.next:
;=@lp
	inc c
	dec b
	jr nz, .loop

;> wAttackWeight = 1
	ld a, $01
	ld [wAttackWeight], a
	ret


;@ def AILowestEnemyDefense()
;@ path: battle/ai/targets
;@ The lowest defense among the enemies standing (empty positions $FFFF) into wSkillAmount; the
;@ three values go to wTargetScores, wSkillAmount2 and wSkillTempPtr.
;@ test: wSkillUser = rng.randint(0, 7)
AILowestEnemyDefense::
;> side = (wSkillUser & 4) ^ 4
	ld a, [wSkillUser]
	and $04
	xor $04
	ld c, a
	ld b, $03

.loop:
;>@lp for i, c in enumerate(range(side, side + 3)):
;>     if not CheckBattlerPresent(c):
	ld a, c
	call CheckBattlerPresent
	jr c, .none

;>@df         d = mem16[addr(wBattlerDefense) + 2 * c]
	ld a, c
	ld hl, wBattlerDefense
	add a
	add l
	ld l, a
	ld a, $00
;=@df
	adc h
	ld h, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	jr .store

.none:
;>     else:
;>         d = 0xFFFF
	ld de, $ffff

.store:
;>@w     mem16[addr(wTargetScores) + 2 * i] = d
	ld a, $03
	sub b
	ld hl, wTargetScores
	add a
	add l
	ld l, a
;=@w
	ld a, $00
	adc h
	ld h, a
	ld [hl], e
	inc hl
	ld [hl], d
;=@lp
	inc c
	dec b
	jr nz, .loop

;>@m1 low = wTargetScores; wSkillAmount = low
	ld a, [wTargetScores]
	ld l, a
	ld a, [wTargetScores + 1]
	ld h, a
	ld a, [wSkillAmount2]
	ld c, a
;=@m1
	ld a, [wSkillAmount2 + 1]
	ld b, a
	ld a, l
	ld [wSkillAmount], a
	ld a, h
	ld [wSkillAmount + 1], a
;> if not low < wSkillAmount2:
	call CompareHLBC
	jr c, .third

;>     low = wSkillAmount2; wSkillAmount = low
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
	ld h, b
	ld l, c

.third:
;> if not low < wSkillTempPtr:
	ld a, [wSkillTempPtr]
	ld c, a
	ld a, [wSkillTempPtr + 1]
	ld b, a
	call CompareHLBC
	ret c

;>     wSkillAmount = wSkillTempPtr
	ld a, c
	ld [wSkillAmount], a
	ld a, b
	ld [wSkillAmount + 1], a
	ret


;@ def AddCapped(p: hl, n: b)
;@ path: battle/ai/targets
;@ mem[p] += n, capped at 255.
;@ test: p = rng.randint(0xC100, 0xCFFF); n = rng.randint(0, 255)
AddCapped::
;>@m mem[p] = min(mem[p] + n, 0xFF)
	ld a, [hl]
	add b
	ld [hl], a
	ret nc

;=@m
	ld a, $ff
	ld [hl], a
	ret


;@ path: unused
;@ Unused space at the end of the bank, all zero.
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
