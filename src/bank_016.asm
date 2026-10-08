INCLUDE "hardware.inc"
INCLUDE "ram.inc"
INCLUDE "far.inc"

SECTION "ROM Bank $016", ROMX[$4000], BANK[$16]

;@ path: breed/offspring
;@ Bank $16 holds the breeding rules (which pair gives which offspring, its plus value, stats,
;@ resistances and skills), the set-up of a monster that joins, and the gate world floors
;@ (which floor comes next, the random floor layout, its stairs, chests and characters, and
;@ the random encounter counter).
BankNumber_16::
	db $16

;@ path: breed/offspring
;@ Far-call entry points of bank $16.
FarTable_16::
	dw MakeOffspring
	dw LookupBreedPair
	dw BreedResult
	dw BreedResultPreview
	dw InitJoinedMonster
	dw NextGateFloor
	dw MakeGateFloor
	dw RollFloorItems
	dw CountEncounterSteps
	dw GetFloorScreenMap

;@ def MakeOffspring()
;@ path: breed/offspring
;@ Makes the egg of a breeding: the parents' records are in wBreedParent1 (the pedigree, slot
;@ $14) and wBreedParent2 (the mate, slot $15). The egg goes into the first free monster slot
;@ (on the farm). Its species comes from BreedResult; its plus value is the parents' plus + 1
;@ (more for high levels), its level limit grows with the plus; its stats and resistances are
;@ inherited from both parents; its sex is random (by the species' sex chance), and it gets
;@ the base skills of its species and of both parents' species and the skills the parents
;@ learned (each skill as the first of its series).
;@ test: skip calls routines in other banks
MakeOffspring::
;> rec = wMonsters
	ld de, wMonsters
;>@find for slot in range(20):         # the first free slot
	ld b, $14
	ld c, $00

.find
;>     if mem[rec] == 0: break
	ld a, [de]
	or a
	jr z, .found

;>     rec += 0x95
	ld a, e
	add $95
	ld e, a
	ld a, d
	adc $00
	ld d, a
;=@find
	inc c
	dec b
	jr nz, .find

;> else:
;>     return                           # no free slot
	ret


.found
;> wCurPartyMember = slot
	ld a, c
	ld [wCurPartyMember], a
;> wLeaderSlot = slot
	ld [wLeaderSlot], a
;> fill(OffspringField(wMonsters), 0, 0x95)
	ld hl, wMonsters
	call OffspringField
	ld bc, $0095
	xor a
	call FillMemory
;> fill(OffspringField(wMonSkills), 0xFF, 8)
	ld hl, wMonSkills
	call OffspringField
	ld bc, $0008
	ld a, $ff
	call FillMemory
;> fill(OffspringField(wMonSkillList), 0xFF, 0x19)
	ld hl, wMonSkillList
	call OffspringField
	ld bc, $0019
	ld a, $ff
	call FillMemory
;> mem[OffspringField(wMonsters)] = 1  # kept on the farm
	ld hl, wMonsters
	call OffspringField
	ld [hl], $01
;> wBreedQuery = wBreedParent1[9]      # the pedigree's species
	ld a, [wBreedParent1 + 9]
	ld [wBreedQuery], a
;> wBreedSpecies2 = wBreedParent2[9]   # the mate's species
	ld a, [wBreedParent2 + 9]
	ld [wBreedSpecies2], a
;> wBreedSlot1 = 0x14; wBreedSlot2 = 0x15
	ld a, $14
	ld [wBreedSlot1], a
	ld a, $15
	ld [wBreedSlot2], a
;> BreedResult()
	call BreedResult
;> mem[OffspringField(wMonRecSpecies)] = wBreedPair[0]
	ld hl, wMonRecSpecies
	call OffspringField
	ld a, [wBreedPair]
	ld [hl], a
;> wMonSpecies = wBreedPair[0]
	ld [wMonSpecies], a
;> GetMonsterStats()
	ld hl, far_GetMonsterStats
	rst $10
;> SetFlag(wLibraryFlags, wMonSpecies)  # the library knows it now
	ld a, [wMonSpecies]
	ld hl, wLibraryFlags
	call SetFlag
;> mem[OffspringField(wMonFamily)] = wMonStats[0]
	ld hl, wMonFamily
	call OffspringField
	ld a, [wMonStats]
	ld [hl], a
;>@plus plus = min(wOffspringPlus, 99)
	ld a, [wOffspringPlus]
	push af
	ld hl, wMonPlus
	call OffspringField
	pop af
	cp $63
;=@plus
	jr c, .plusOk

	ld a, $63

.plusOk
;> mem[OffspringField(wMonPlus)] = plus
	ld [hl], a
;>@limit limit = plus * 2 + wMonStats[1]     # the species' level limit
	ld hl, wMonPlus
	call OffspringField
	ld a, [hl]
	ld l, a
	ld h, $00
	add hl, hl
;=@limit
	ld a, [wMonStats + 1]
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@clamp limit = min(max(limit, 2), 99)
	ld a, h
	or a
	jr nz, .max

;=@clamp
	ld a, l
	cp $02
	jr nc, .notLow

	ld a, $02

.notLow
;=@clamp
	cp $63
	jr c, .limitOk

.max
;=@clamp
	ld a, $63

.limitOk
;> mem[OffspringField(wMonMaxLevel)] = limit
	push af
	ld hl, wMonMaxLevel
	call OffspringField
	pop af
	ld [hl], a
;> mem[OffspringField(wMonLevel)] = 1
	ld hl, wMonLevel
	call OffspringField
	ld [hl], $01
;> hp = InheritStat16(wMonMaxHP)
	ld hl, wMonMaxHP
	call InheritStat16
;>@hp mem16[OffspringField(wMonHP)] = hp
	push bc
	ld hl, wMonHP
	call OffspringField
	pop bc
	ld a, c
	ld [hli], a
;=@hp
	ld [hl], b
;> mp = InheritStat16(wMonMaxMP)
	ld hl, wMonMaxMP
	call InheritStat16
;>@mp mem16[OffspringField(wMonMP)] = mp
	push bc
	ld hl, wMonMP
	call OffspringField
	pop bc
	ld a, c
	ld [hli], a
;=@mp
	ld [hl], b
;> for field in (wMonAttack, wMonDefense, wMonAgility, wMonIntelligence):
;>@s16     InheritStat16(field)
	ld hl, wMonAttack
	call InheritStat16
;=@s16
	ld hl, wMonDefense
	call InheritStat16
	ld hl, wMonAgility
	call InheritStat16
;=@s16
	ld hl, wMonIntelligence
	call InheritStat16
;> for field in (wMonStat64, wMonStat65, wMonStat67, wMonStat66):
;>@s8     InheritStat8(field)
	ld hl, wMonStat64
	call InheritStat8
	ld hl, wMonStat65
	call InheritStat8
;=@s8
	ld hl, wMonStat67
	call InheritStat8
	ld hl, wMonStat66
	call InheritStat8
;> CopyToOffspring(wMonResist, wMonResistances, 27)   # the species' resistances
	ld hl, wMonResist
	ld de, wMonResistances
	ld b, $1b
	call CopyToOffspring
;> InheritResistances()
	call InheritResistances
;> Random()
	call Random
;>@sex if wRandomHigh < SexChanceTable[wMonStats[3]]:
	ld hl, SexChanceTable
	ld a, [wMonStats + 3]
	add l
	ld l, a
	ld a, $00
	adc h
;=@sex
	ld h, a
	ld a, [wRandomHigh]
	cp [hl]
	jr z, .sexDone

;=@sex
	jr nc, .sexDone

;>     mem[OffspringField(wMonGender)] = 1
	ld hl, wMonGender
	call OffspringField
	ld [hl], $01

.sexDone
;> mem[OffspringField(wMonEgg)] = 1     # an egg
	ld hl, wMonEgg
	call OffspringField
	ld [hl], $01
;> SetOffspringParents()
	call SetOffspringParents
;> AddSkillsOfList(wMonStats + 6, 3)    # the offspring species' base skills
	ld de, wMonStats + 6
	ld b, $03
	call AddSkillsOfList
;> wMonSpecies = wBreedParent1[9]; GetMonsterStats()
	ld a, [wBreedParent1 + 9]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;> AddSkillsOfList(wMonStats + 6, 3)    # the pedigree species' base skills
	ld de, wMonStats + 6
	ld b, $03
	call AddSkillsOfList
;> wMonSpecies = wBreedParent2[9]; GetMonsterStats()
	ld a, [wBreedParent2 + 9]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;> AddSkillsOfList(wMonStats + 6, 3)    # the mate species' base skills
	ld de, wMonStats + 6
	ld b, $03
	call AddSkillsOfList
;> AddSkillsOfList(wBreedParent1 + 0x29, 8)   # the skills the pedigree learned
	ld de, wBreedParent1 + $29
	ld b, $08
	call AddSkillsOfList
;> AddSkillsOfList(wBreedParent2 + 0x29, 8)   # the skills the mate learned
	ld de, wBreedParent2 + $29
	ld b, $08
	call AddSkillsOfList
	ret


;@ def OffspringField(field: hl) -> hl
;@ path: breed/offspring
;@ Address of a record field (given as its address in record 0) of monster wCurPartyMember.
;@ test: skip calls MonsterField
OffspringField::
;> return MonsterField(field, wCurPartyMember)
	ld a, [wCurPartyMember]
	call MonsterField
	ret


;@ def InheritStat16(field: hl) -> bc
;@ path: breed/offspring
;@ Inherits a 16-bit stat: q = (pedigree's + mate's value) / 4, plus q * n / 50 where n is
;@ CountForeignMasters (the more foreign masters in the pedigree, the stronger); at least 1.
;@ Stores it in the offspring's record and returns it.
;@ test: skip calls routines through MonsterField
InheritStat16::
;>@p p = field + 0x14 * 0x95             # the pedigree's record (slot 20)
	push hl
	ld a, l
	add $a4
	ld l, a
	ld a, h
	adc $0b
;=@p
	ld h, a
;>@q q = (mem16[p] + mem16[p + 0x95]) // 4   # + the mate's (slot 21)
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld a, l
	add $94
	ld l, a
;=@q
	ld a, h
	adc $00
	ld h, a
	ld a, [hli]
	add c
	ld c, a
;=@q
	ld a, [hl]
	adc b
	ld b, a
	srl b
	rr c
	srl b
;=@q
	rr c
;> dest = OffspringField(field)
	pop hl
	push bc
	call OffspringField
	pop bc
	push hl
	push bc
;>@value value = q + q * CountForeignMasters() // 50
	push bc
	call CountForeignMasters
	pop bc
	call Multiply24
	ld a, $32
	call Divide16
;=@value
	pop bc
	add hl, bc
	ld c, l
	ld b, h
;> if value == 0:
;>     value = 1
	ld a, c
	or b
	jr nz, .store

	ld bc, $0001

.store
;> mem16[dest] = value
	pop hl
	ld a, c
	ld [hli], a
	ld [hl], b
;> return value
	ret


;@ def InheritStat8(field: hl)
;@ path: breed/offspring
;@ Inherits an 8-bit stat: the average of the pedigree's and the mate's value.
;@ test: skip calls routines through MonsterField
InheritStat8::
;>@p p = field + 0x14 * 0x95             # the pedigree's record (slot 20)
	push hl
	ld a, l
	add $a4
	ld l, a
	ld a, h
	adc $0b
;=@p
	ld h, a
;>@value value = (mem[p] + mem[p + 0x95]) // 2
	ld a, [hl]
	ld c, a
	ld b, $00
	ld a, l
	add $95
	ld l, a
;=@value
	ld a, h
	adc $00
	ld h, a
	ld a, [hl]
	add c
	ld c, a
;=@value
	ld a, $00
	add b
	ld b, a
	srl b
	rr c
;> mem[OffspringField(field)] = value
	pop hl
	push bc
	call OffspringField
	pop bc
	ld [hl], c
	ret


;@ def CopyToOffspring(field: hl, src: de, count: b)
;@ path: breed/offspring
;@ Copies `count` bytes from `src` into a field of the offspring's record.
;@ test: skip calls MonsterField
CopyToOffspring::
;> dest = OffspringField(field)
	push bc
	push de
	ld a, [wCurPartyMember]
	call MonsterField
	pop de
	pop bc

.loop
;>@copy copy(dest, src, count)
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .loop

	ret


;@ def SetOffspringParents()
;@ path: breed/offspring
;@ Writes the pedigree into the offspring's record: species, master's name, name and plus of
;@ each parent. The female parent becomes parent 2, so the order depends on the pedigree's sex.
;@ test: skip calls MonsterField
SetOffspringParents::
;> if wBreedParent1[0x0B] & 1:         # the pedigree is female: the mate is parent 1
	ld a, [wBreedParent1 + $0b]
	and $01
	or a
	jp nz, .swapped

;>     mem[OffspringField(wMonParent1)] = wBreedParent1[9]
	ld hl, wMonParent1
	call OffspringField
	ld a, [wBreedParent1 + 9]
	ld [hl], a
;>     CopyToOffspring(wMonParent1Master, wBreedParent1 + 0x0C, 8)
	ld hl, wMonParent1Master
	ld de, wBreedParent1 + $0c
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent1Master + 8)] = wPlayerName[8]
	ld hl, wMonParent1Master + 8
	call OffspringField
	ld a, [wPlayerName + 8]
	ld [hl], a
;>     CopyToOffspring(wMonParent1Name, wBreedParent1 + 1, 8)
	ld hl, wMonParent1Name
	ld de, wBreedParent1 + 1
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent1Plus)] = wBreedParent1[0x62]
	ld hl, wMonParent1Plus
	call OffspringField
	ld a, [wBreedParent1 + $62]
	ld [hl], a
;>     mem[OffspringField(wMonParent2)] = wBreedParent2[9]
	ld hl, wMonParent2
	call OffspringField
	ld a, [wBreedParent2 + 9]
	ld [hl], a
;>     CopyToOffspring(wMonParent2Master, wBreedParent2 + 0x0C, 8)
	ld hl, wMonParent2Master
	ld de, wBreedParent2 + $0c
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent2Master + 8)] = wPlayerName[8]
	ld hl, wMonParent2Master + 8
	call OffspringField
	ld a, [wPlayerName + 8]
	ld [hl], a
;>     CopyToOffspring(wMonParent2Name, wBreedParent2 + 1, 8)
	ld hl, wMonParent2Name
	ld de, wBreedParent2 + 1
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent2Plus)] = wBreedParent2[0x62]
	ld hl, wMonParent2Plus
	call OffspringField
	ld a, [wBreedParent2 + $62]
	ld [hl], a
	ret


;> else:
;>     mem[OffspringField(wMonParent1)] = wBreedParent2[9]
.swapped
	ld hl, wMonParent1
	call OffspringField
	ld a, [wBreedParent2 + 9]
	ld [hl], a
;>     CopyToOffspring(wMonParent1Master, wBreedParent2 + 0x0C, 8)
	ld hl, wMonParent1Master
	ld de, wBreedParent2 + $0c
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent1Master + 8)] = wPlayerName[8]
	ld hl, wMonParent1Master + 8
	call OffspringField
	ld a, [wPlayerName + 8]
	ld [hl], a
;>     CopyToOffspring(wMonParent1Name, wBreedParent2 + 1, 8)
	ld hl, wMonParent1Name
	ld de, wBreedParent2 + 1
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent1Plus)] = wBreedParent2[0x62]
	ld hl, wMonParent1Plus
	call OffspringField
	ld a, [wBreedParent2 + $62]
	ld [hl], a
;>     mem[OffspringField(wMonParent2)] = wBreedParent1[9]
	ld hl, wMonParent2
	call OffspringField
	ld a, [wBreedParent1 + 9]
	ld [hl], a
;>     CopyToOffspring(wMonParent2Master, wBreedParent1 + 0x0C, 8)
	ld hl, wMonParent2Master
	ld de, wBreedParent1 + $0c
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent2Master + 8)] = wPlayerName[8]
	ld hl, wMonParent2Master + 8
	call OffspringField
	ld a, [wPlayerName + 8]
	ld [hl], a
;>     CopyToOffspring(wMonParent2Name, wBreedParent1 + 1, 8)
	ld hl, wMonParent2Name
	ld de, wBreedParent1 + 1
	ld b, $08
	call CopyToOffspring
;>     mem[OffspringField(wMonParent2Plus)] = wBreedParent1[0x62]
	ld hl, wMonParent2Plus
	call OffspringField
	ld a, [wBreedParent1 + $62]
	ld [hl], a
	ret


;@ def CountForeignMasters() -> a
;@ path: breed/offspring
;@ Counts the 9-byte names in the pedigree that differ from the player's name: each parent's
;@ master, and, for a parent that has parents itself, the two names at record offsets $83
;@ and $8C (where SetOffspringParents keeps its parents' names). 0-6.
;@ test: skip compares records in RAM
CountForeignMasters::
;> n = 0
	ld c, $00
;> n += CountIfNotPlayerName(wBreedParent1 + 0x0C)
	ld hl, wBreedParent1 + $0c
	call CountIfNotPlayerName
;> if wBreedParent1[0x15] != 0xFF:     # the pedigree has parents
;>     n += CountIfNotPlayerName(wBreedParent1 + 0x83)
	ld a, [wBreedParent1 + $15]
	cp $ff
	ld hl, wBreedParent1 + $83
	call nz, CountIfNotPlayerName
;> if wBreedParent1[0x16] != 0xFF:
;>     n += CountIfNotPlayerName(wBreedParent1 + 0x8C)
	ld a, [wBreedParent1 + $16]
	cp $ff
	ld hl, wBreedParent1 + $8c
	call nz, CountIfNotPlayerName
;> n += CountIfNotPlayerName(wBreedParent2 + 0x0C)
	ld hl, wBreedParent2 + $0c
	call CountIfNotPlayerName
;> if wBreedParent2[0x15] != 0xFF:
;>     n += CountIfNotPlayerName(wBreedParent2 + 0x83)
	ld a, [wBreedParent2 + $15]
	cp $ff
	ld hl, wBreedParent2 + $83
	call nz, CountIfNotPlayerName
;> if wBreedParent2[0x16] != 0xFF:
;>     n += CountIfNotPlayerName(wBreedParent2 + 0x8C)
	ld a, [wBreedParent2 + $16]
	cp $ff
	ld hl, wBreedParent2 + $8c
	call nz, CountIfNotPlayerName
;> return n
	ld a, c
	ret


;@ def CountIfNotPlayerName(name: hl, n: c) -> c
;@ path: breed/offspring
;@ Compares the 9 bytes at `name` with wPlayerName; returns `n` + 1 if they differ.
;@ test: c = rand(0, 5)
CountIfNotPlayerName::
;> for i in range(9):
	ld de, wPlayerName
	ld b, $09

.loop
;>     if mem[wPlayerName + i] != mem[name + i]:
	ld a, [de]
	cp [hl]
	jr z, .same

;>@next         return n + 1
	inc c
	ret


.same
;=@next
	inc de
	inc hl
	dec b
	jr nz, .loop

;> return n
	ret


;@ def InheritResistances()
;@ path: breed/offspring
;@ Runs InheritResistance for each of the 27 resistances (wBreedTemp is the index).
;@ test: skip calls MonsterField
InheritResistances::
;> wBreedTemp = 0
	xor a
	ld [wBreedTemp], a
;> for i in range(27):
	ld b, $1b

.loop
;>     InheritResistance()
	push bc
	call InheritResistance
;>     wBreedTemp += 1
	ld hl, wBreedTemp
	inc [hl]
	pop bc
	dec b
	jr nz, .loop

	ret


;@ def InheritResistance()
;@ path: breed/offspring
;@ Resistance wBreedTemp of the offspring (0-3, starting as its species' value) may rise by
;@ the sum s of the parents' values (0-6): below 2, s = 3 raises it with a chance of plus/100,
;@ s = 4 plus/30, s = 5 two tries of plus/10 and plus/30, s = 6 always once and then plus/20;
;@ a value of 2 rises to 3 for s = 5 with plus/200, s = 6 plus/40. 3 is the top.
;@ test: skip calls MonsterField
InheritResistance::
;>@r r = mem[OffspringField(wMonResist + wBreedTemp)]
	ld a, [wBreedTemp]
	ld hl, wMonResist
	add l
	ld l, a
	ld a, $00
	adc h
;=@r
	ld h, a
	call OffspringField
	ld a, [hl]
;> if r == 3:
;>     return
	cp $03
	ret z

;> if r == 2:
;>     return InheritTopResistance()    # (the second half of this routine)
	cp $02
	jp z, Jump_016_43fc

;>@s s = wBreedParent1[0x68 + wBreedTemp] + wBreedParent2[0x68 + wBreedTemp]
	ld a, [wBreedTemp]
	ld hl, wBreedParent1 + $68
	add l
	ld l, a
	ld a, $00
	adc h
;=@s
	ld h, a
	ld a, [hl]
	push af
	ld a, [wBreedTemp]
	ld hl, wBreedParent2 + $68
	add l
;=@s
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	add [hl]
;> ResistanceGainTable[s & 7]()
	and $07
	rst $00

;@ path: breed/offspring
;@ What a resistance below 2 gains, by the sum of the parents' values.
ResistanceGainTable::
	dw ResistanceKeep
	dw ResistanceKeep
	dw ResistanceKeep
	dw ResistanceGainPlus100
	dw ResistanceGainPlus30
	dw ResistanceGainPlus10And30
	dw ResistanceGainAndPlus20

;@ def ResistanceKeep()
;@ path: breed/offspring
;@ The resistance stays.
ResistanceKeep::
;> return
	ret


;@ def ResistanceGainPlus100()
;@ path: breed/offspring
;@ The resistance rises by one (to at most 2) with a chance of plus/100.
;@ test: skip calls MonsterField
ResistanceGainPlus100::
;> if PlusChance(100, wOffspringPlus):
;>     RaiseResistanceTo2()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $64
	call PlusChance
	call c, RaiseResistanceTo2
	ret


;@ def ResistanceGainPlus30()
;@ path: breed/offspring
;@ The resistance rises by one (to at most 2) with a chance of plus/30.
;@ test: skip calls MonsterField
ResistanceGainPlus30::
;> if PlusChance(30, wOffspringPlus):
;>     RaiseResistanceTo2()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $1e
	call PlusChance
	call c, RaiseResistanceTo2
	ret


;@ def ResistanceGainPlus10And30()
;@ path: breed/offspring
;@ Two tries: with a chance of plus/10, then of plus/30, the resistance rises by one (to at
;@ most 2).
;@ test: skip calls MonsterField
ResistanceGainPlus10And30::
;> if PlusChance(10, wOffspringPlus):
;>     RaiseResistanceTo2()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $0a
	call PlusChance
	call c, RaiseResistanceTo2
;> if PlusChance(30, wOffspringPlus):
;>     RaiseResistanceTo2()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $1e
	call PlusChance
	call c, RaiseResistanceTo2
	ret


;@ def ResistanceGainAndPlus20()
;@ path: breed/offspring
;@ The resistance rises by one, and once more with a chance of plus/20 (to at most 2).
;@ test: skip calls MonsterField
ResistanceGainAndPlus20::
;> RaiseResistanceTo2()
	call RaiseResistanceTo2
;> if PlusChance(20, wOffspringPlus):
;>     RaiseResistanceTo2()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $14
	call PlusChance
	call c, RaiseResistanceTo2
	ret


;> def InheritTopResistance():          # a resistance of 2
;>@s2     s = wBreedParent1[0x68 + wBreedTemp] + wBreedParent2[0x68 + wBreedTemp]
Jump_016_43fc:
	ld a, [wBreedTemp]
	ld hl, wBreedParent1 + $68
	add l
	ld l, a
	ld a, $00
	adc h
;=@s2
	ld h, a
	ld a, [hl]
	push af
	ld a, [wBreedTemp]
	ld hl, wBreedParent2 + $68
	add l
;=@s2
	ld l, a
	ld a, $00
	adc h
	ld h, a
	pop af
	add [hl]
;>     ResistanceTopTable[s & 7]()
	and $07
	rst $00

;@ path: breed/offspring
;@ What a resistance of 2 gains, by the sum of the parents' values.
ResistanceTopTable::
	dw ResistanceTopKeep
	dw ResistanceTopKeep
	dw ResistanceTopKeep
	dw ResistanceTopKeep
	dw ResistanceTopKeep
	dw ResistanceTopPlus200
	dw ResistanceTopPlus40

;@ def ResistanceTopKeep()
;@ path: breed/offspring
;@ The resistance stays.
ResistanceTopKeep::
;> return
	ret


;@ def ResistanceTopPlus200()
;@ path: breed/offspring
;@ The resistance rises to 3 with a chance of plus/200.
;@ test: skip calls MonsterField
ResistanceTopPlus200::
;> if PlusChance(200, wOffspringPlus):
;>     RaiseResistanceTo3()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $c8
	call PlusChance
	call c, RaiseResistanceTo3
	ret


;@ def ResistanceTopPlus40()
;@ path: breed/offspring
;@ The resistance rises to 3 with a chance of plus/40.
;@ test: skip calls MonsterField
ResistanceTopPlus40::
;> if PlusChance(40, wOffspringPlus):
;>     RaiseResistanceTo3()
	ld a, [wOffspringPlus]
	ld b, a
	ld a, $28
	call PlusChance
	call c, RaiseResistanceTo3
	ret


;@ def PlusChance(range: a, plus: b) -> carry
;@ path: breed/offspring
;@ True (carry) with a chance of `plus` / `range`: a random number below `range` is
;@ compared with `plus`.
;@ test: skip calls Random
PlusChance::
;>@roll return Random() % range < plus
	push bc
	push af
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
;=@roll
	ld h, a
	pop af
	call Divide16
	pop bc
	cp b
	ret


;@ path: unused
;@ Code that nothing calls: lowers resistance wBreedTemp of the offspring by one (not below 0).
UnusedLowerResistance::
	db $fa, $72, $da, $21, $29, $cb, $85, $6f, $3e, $00, $8c, $67, $cd, $b1, $41, $7e
	db $b7, $c8, $35, $c9

;@ def RaiseResistanceTo3()
;@ path: breed/offspring
;@ Raises resistance wBreedTemp of the offspring by one, unless it is 3 already.
;@ test: skip calls MonsterField
RaiseResistanceTo3::
;>@p p = OffspringField(wMonResist + wBreedTemp)
	ld a, [wBreedTemp]
	ld hl, wMonResist
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	call OffspringField
;> if mem[p] != 3:
	ld a, [hl]
	cp $03
	ret z

;>     mem[p] += 1
	inc [hl]
	ret


;@ def RaiseResistanceTo2()
;@ path: breed/offspring
;@ Raises resistance wBreedTemp of the offspring by one, unless it is 2 already.
;@ test: skip calls MonsterField
RaiseResistanceTo2::
;>@p p = OffspringField(wMonResist + wBreedTemp)
	ld a, [wBreedTemp]
	ld hl, wMonResist
	add l
	ld l, a
	ld a, $00
	adc h
;=@p
	ld h, a
	call OffspringField
;> if mem[p] != 2:
	ld a, [hl]
	cp $02
	ret z

;>     mem[p] += 1
	inc [hl]
	ret


;@ def AddSkillsOfList(skills: de, count: b)
;@ path: breed/offspring
;@ Adds the series of each of `count` skills to the offspring's list of skills to learn
;@ (AddBaseSkill).
;@ test: skip calls MonsterField
AddSkillsOfList::
;> for i in range(count):
;>@loop     AddBaseSkill(mem[skills + i])
	ld a, [de]
	inc de
	push bc
	push de
	call AddBaseSkill
	pop de
;=@loop
	pop bc
	dec b
	jr nz, AddSkillsOfList

	ret


;@ def AddBaseSkill(skill: a)
;@ path: breed/offspring
;@ Adds the first skill of `skill`'s series (SkillBaseTable) to the offspring's list of skills
;@ to learn (wMonSkillList, 25 places), unless it is there already or the list is full.
;@ test: skip calls MonsterField
AddBaseSkill::
;> if skill == 0xFF:
;>     return
	cp $ff
	ret z

;>@base base = SkillBaseTable[skill]
	ld hl, SkillBaseTable
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@base
	ld a, [hl]
;> if base == 0xFF:
;>     return
	cp $ff
	ret z

;> p = OffspringField(wMonSkillList)
	push af
	ld hl, wMonSkillList
	call OffspringField
	pop af
	ld b, $19
	ld c, a

.loop
;>@loop for i in range(25):
;>     if mem[p + i] == base: return    # known already
	ld a, [hl]
	cp c
	ret z

;>     if mem[p + i] == 0xFF:           # the first free place
	cp $ff
	jr nz, .next

;>         mem[p + i] = base; return
	ld [hl], c
	ret


.next
;=@loop
	inc hl
	dec b
	jr nz, .loop

	ret


;@ path: breed/rules
;@ Chance (of 256) that the offspring gets sex 1, by the species' sex-ratio class (template stat
;@ 3): never, about 10%, 50%, about 84%.
SexChanceTable::
	db $00, $1a, $80, $d6

;@ def ClearBreedCountUnlinked()
;@ path: breed/rules
;@ Outside link mode clears wBreedCount.
;@ test: wLinkActive = rand(0, 1)
ClearBreedCountUnlinked::
;> if wLinkActive:
;>     return
	ld a, [wLinkActive]
	or a
	ret nz

;> wBreedCount = 0
	xor a
	ld [wBreedCount], a
	ret


;@ path: unused
;@ Code that nothing calls: breeding-count helpers that count the party or farm monsters of a
;@ species (through $1DFB and $453D / $4553) and step wBreedCount, plus two small loops over
;@ the monster list.
UnusedBreedCountRule::
	db $fa, $71, $da, $fe, $ff, $28, $2e, $cd, $d0, $12, $fa, $99, $c8, $fe, $03, $d0
	db $06, $c8, $16, $d7, $cd, $3d, $45, $fa, $9a, $c8, $47, $79, $b7, $c8, $cd, $fb
	db $1d, $06, $c8, $16, $d7, $5f, $cd, $53, $45, $78, $ea, $71, $da, $21, $e6, $d9
	db $34, $fe, $ff, $c8, $c9, $cd, $d0, $12, $fa, $99, $c8, $fe, $0e, $d0, $06, $00
	db $16, $c8, $cd, $3d, $45, $fa, $9a, $c8, $47, $79, $b7, $c8, $cd, $fb, $1d, $06
	db $00, $16, $c8, $5f, $cd, $53, $45, $78, $ea, $71, $da, $fe, $ff, $c8, $21, $e6
	db $d9, $34, $c9, $0e, $00, $c5, $d5, $21, $94, $ca, $78, $cd, $7e, $26, $d1, $c1
	db $28, $01, $0c, $04, $78, $ba, $20, $ed, $c9, $0e, $00, $c5, $d5, $21, $94, $ca
	db $78, $cd, $7e, $26, $d1, $c1, $28, $04, $79, $bb, $c8, $0c, $04, $78, $ba, $20
	db $ea, $06, $ff, $c9

;@ def BreedResult()
;@ path: breed/rules
;@ Works out the offspring of the pedigree wBreedQuery and the mate wBreedSpecies2 (monster
;@ slots wBreedSlot1 / wBreedSlot2) into wBreedPair[0], and its plus value into
;@ wOffspringPlus: first the special pairs (FindSpecialPair), then the pair table by species
;@ and family (FindPairByFamily); with no match the offspring is of the pedigree's species.
;@ test: skip calls routines in other banks
BreedResult::
;> wBreedPair[0] = 0xFF
	ld a, $ff
	ld [wBreedPair], a
;> wBreedTemp = 0xFF
	ld a, $ff
	ld [wBreedTemp], a
;> wBreedFamily1 = 0xFF
	ld a, $ff
	ld [wBreedFamily1], a
;> wBreedFamily2 = 0xFF
	ld a, $ff
	ld [wBreedFamily2], a
;> wOffspringPlus = 0xFF
	ld a, $ff
	ld [wOffspringPlus], a
;> FindSpecialPair()
	call FindSpecialPair
;> if wBreedPair[0] != 0xFF:
;>     return
	ld a, [wBreedPair]
	cp $ff
	ret nz

;> FindPairByFamily()
	call FindPairByFamily
;> ClearBreedCountUnlinked()
	call ClearBreedCountUnlinked
;> if wBreedPair[0] != 0xFF:
;>     return
	ld a, [wBreedPair]
	cp $ff
	ret nz

;> wBreedPair[0] = wBreedQuery          # no rule: the pedigree's species
	ld a, [wBreedQuery]
	ld [wBreedPair], a
	ret


;@ def BreedResultPreview()
;@ path: breed/rules
;@ BreedResult without clearing wBreedCount (used to show the result before breeding).
;@ test: skip calls routines in other banks
BreedResultPreview::
;> wBreedPair[0] = 0xFF
	ld a, $ff
	ld [wBreedPair], a
;> wBreedTemp = 0xFF
	ld a, $ff
	ld [wBreedTemp], a
;> wBreedFamily1 = 0xFF
	ld a, $ff
	ld [wBreedFamily1], a
;> wBreedFamily2 = 0xFF
	ld a, $ff
	ld [wBreedFamily2], a
;> wOffspringPlus = 0xFF
	ld a, $ff
	ld [wOffspringPlus], a
;> FindSpecialPair()
	call FindSpecialPair
;> if wBreedPair[0] != 0xFF:
;>     return
	ld a, [wBreedPair]
	cp $ff
	ret nz

;> FindPairByFamily()
	call FindPairByFamily
;> if wBreedPair[0] != 0xFF:
;>     return
	ld a, [wBreedPair]
	cp $ff
	ret nz

;> wBreedPair[0] = wBreedQuery
	ld a, [wBreedQuery]
	ld [wBreedPair], a
	ret


;@ def FindPairByFamily()
;@ path: breed/rules
;@ Looks the pair up in BreedPairTable: first with the mate's species, then (when nothing
;@ matched) with the mate's family ($F0 + family).
;@ test: skip calls routines in other banks
FindPairByFamily::
;> if wBreedSpecies2 >= 0xF0:          # the mate is given as a family already
;>     return FindPairInTable()
	ld a, [wBreedSpecies2]
	cp $f0
	jr nc, FindPairInTable

;> query = wBreedQuery
	ld a, [wBreedQuery]
	push af
;> FindPairInTable()
	call FindPairInTable
;> wBreedQuery = query
	pop af
	ld [wBreedQuery], a
;> if wBreedPair[0] != 0xFF:
;>     return
	ld a, [wBreedPair]
	cp $ff
	ret nz

;> wMonSpecies = wBreedSpecies2; GetMonsterStats()
	ld a, [wBreedSpecies2]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;> family = 0xF0 + wMonStats[0]        # the mate's family
	ld a, [wMonStats]
	add $f0
;> wBreedSpecies2 = family; return FindPairInTable()   # runs on into it
	ld [wBreedSpecies2], a

;@ def FindPairInTable()
;@ path: breed/rules
;@ Searches BreedPairTable (the entry number is the offspring species) for an entry whose mate
;@ matches wBreedSpecies2 (a family entry $FA matches any family) and whose pedigree is
;@ wBreedQuery (taken at once) or the pedigree's family (remembered, the search goes on).
;@ test: skip reads the pair table
FindPairInTable::
;> if wBreedQuery < 0xF0:
	ld a, [wBreedQuery]
	cp $f0
	jr nc, .search

;>     wMonSpecies = wBreedQuery; GetMonsterStats()
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;>     wBreedTemp = 0xF0 + wMonStats[0] # the pedigree's family
	ld a, [wMonStats]
	add $f0
	ld [wBreedTemp], a

.search
;> p = BreedPairTable; species = -1
	ld hl, BreedPairTable
	ld d, $ff

.loop
;>@loop while True:
;>     species += 1
	inc d
;>     pedigree, mate = mem[p], mem[p + 1]; p += 2
	ld b, [hl]
	inc hl
	ld c, [hl]
	inc hl
;>     if pedigree == 0 and mate == 0:  # the end
;>         return
	ld a, b
	or c
	ret z

;>     if pedigree == 0xFF and mate == 0xFF:
;>         continue
	ld a, b
	and c
	cp $ff
	jr z, .loop

;>@mate     if not (wBreedSpecies2 & 0xF0 == 0xF0 and mate == 0xFA) and mate != wBreedSpecies2:
	ld a, [wBreedSpecies2]
	and $f0
	cp $f0
	jr nz, .compareMate

;=@mate
	ld a, c
	cp $fa
	jr z, .mateOk

.compareMate
;=@mate
	ld a, [wBreedSpecies2]
	cp c
;>         continue
	jr nz, .loop

.mateOk
;>     if pedigree == wBreedQuery:      # this exact species
	ld a, [wBreedQuery]
	cp b
;>@found         wBreedPair[0] = species; return
	jr z, .found

;>     if pedigree == wBreedTemp:       # the pedigree's family: keep looking for a better one
	ld a, [wBreedTemp]
	cp b
	jr nz, .next

;>         wBreedPair[0] = species
	ld a, d
	ld [wBreedPair], a

.next
;=@loop
	jr .loop

.found
;=@found
	ld a, d
	ld [wBreedPair], a
	ret


;@ def FindSpecialPair()
;@ path: breed/rules
;@ Works out the offspring's plus value, then searches SpecialPairTable. Plus: the pedigree's
;@ plus (outside link mode the higher of both parents') + 1, + 1/2/3/4 when the parents'
;@ levels add up to at least 40/60/76/100, at most 99. A special pair found sets the offspring
;@ and adds its plus bonus.
;@ test: skip calls routines in other banks
FindSpecialPair::
;> plus = mem[MonsterField(wMonPlus, wBreedSlot1)]
	ld a, [wBreedSlot1]
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	ld b, a
;> if not wLinkActive:
	ld a, [wLinkActive]
	or a
	jr nz, .linked

;>@max     plus = max(plus, mem[MonsterField(wMonPlus, wBreedSlot2)])
	ld a, [wBreedSlot1]
	ld hl, wMonPlus
	call MonsterField
	ld b, [hl]
	push bc
	ld a, [wBreedSlot2]
;=@max
	ld hl, wMonPlus
	call MonsterField
	ld a, [hl]
	pop bc
	cp b
	jr nc, .plusOne

.linked
;=@max
	ld a, b

.plusOne
;> wOffspringPlus = plus + 1
	inc a
	ld [wOffspringPlus], a
;>@levels levels = mem[MonsterField(wMonLevel, wBreedSlot1)] + mem[MonsterField(wMonLevel, wBreedSlot2)]
	ld a, [wBreedSlot1]
	ld hl, wMonLevel
	call MonsterField
	ld b, [hl]
	push bc
	ld a, [wBreedSlot2]
;=@levels
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	pop bc
	add b
;>@bonus bonus = 4 if levels >= 100 else 3 if levels >= 76 else 2 if levels >= 60 else 1 if levels >= 40 else 0
	ld c, $04
	cp $64
	jr nc, .bonus

;=@bonus
	ld c, $03
	cp $4c
	jr nc, .bonus

;=@bonus
	ld c, $02
	cp $3c
	jr nc, .bonus

;=@bonus
	ld c, $01
	cp $28
	jr nc, .bonus

;=@bonus
	ld c, $00

.bonus
;> wOffspringPlus += bonus
	ld a, [wOffspringPlus]
	add c
	ld [wOffspringPlus], a
;> if wOffspringPlus >= 99:
;>     wOffspringPlus = 99
	ld a, [wOffspringPlus]
	cp $63
	jr c, .plusOk

	ld a, $63
	ld [wOffspringPlus], a

.plusOk
;> if wBreedQuery < 0xF0:
	ld a, [wBreedQuery]
	cp $f0
	jr nc, .family2

;>     wMonSpecies = wBreedQuery; GetMonsterStats()
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;>     wBreedFamily1 = 0xF0 + wMonStats[0]
	ld a, [wMonStats]
	add $f0
	ld [wBreedFamily1], a

.family2
;> if wBreedSpecies2 < 0xF0:
	ld a, [wBreedSpecies2]
	cp $f0
	jr nc, .search

;>     wMonSpecies = wBreedSpecies2; GetMonsterStats()
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;>     wBreedFamily2 = 0xF0 + wMonStats[0]
	ld a, [wMonStats]
	add $f0
	ld [wBreedFamily2], a

.search
;> p = SpecialPairTable
	ld hl, SpecialPairTable

.loop
;>@loop while mem[p] != 0xFF:
	ld a, [hl]
	cp $ff
	jr z, .done

;>     CheckSpecialPair(p)
	push hl
	call CheckSpecialPair
	pop hl
;>     if wBreedPair[0] != 0xFF: break
	ld a, [wBreedPair]
	cp $ff
	jr nz, .done

;>     p += 5
	ld a, l
	add $05
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@loop
	jr .loop

.done
;> if wOffspringPlus >= 99:
;>     wOffspringPlus = 99
	ld a, [wOffspringPlus]
	cp $63
	ret c

	ld a, $63
	ld [wOffspringPlus], a
	ret


;@ def CheckSpecialPair(entry: hl)
;@ path: breed/rules
;@ Tests one SpecialPairTable entry (pedigree, mate, lowest plus, offspring, plus bonus): the
;@ pedigree and mate bytes match a species or a family ($F0 + family); when they match and
;@ the offspring's plus is high enough, sets the offspring and adds the bonus.
;@ test: skip reads the pair table
CheckSpecialPair::
;>@ped if entry[0] in (wBreedQuery, wBreedFamily1):
	ld a, [wBreedQuery]
	cp [hl]
	jr z, .pedigreeOk

;=@ped
	ld a, [wBreedFamily1]
	cp [hl]
	jr nz, .done

.pedigreeOk
;>@mate     if entry[1] in (wBreedSpecies2, wBreedFamily2):
	inc hl
	ld a, [wBreedSpecies2]
	cp [hl]
	jr z, .mateOk

;=@mate
	ld a, [wBreedFamily2]
	cp [hl]
	jr nz, .done

.mateOk
;>         if wOffspringPlus >= entry[2]:
	inc hl
	ld a, [wOffspringPlus]
	cp [hl]
	jr c, .done

;>             wBreedPair[0] = entry[3]
	inc hl
	ld a, [hl]
	ld [wBreedPair], a
;>             wOffspringPlus += entry[4]
	inc hl
	ld a, [wOffspringPlus]
	add [hl]
	ld [wOffspringPlus], a

.done
	ret


;@ def InitJoinedMonster()
;@ path: monster/join
;@ Sets up monster wCurPartyMember when it joins (after a battle or hatching): wildness 0,
;@ Terry as its master, and a new list of skills to learn: first the series of its species'
;@ and (when it has parents) its parents' species' base skills, then those already in its
;@ list. It is no egg any more.
;@ test: skip calls routines in other banks
InitJoinedMonster::
;> mem16[CurMonField(wMonWildness)] = 0
	ld hl, wMonWildness
	call CurMonField
	xor a
	ld [hli], a
	ld [hl], a
;> CopyToCurMon(wMonMaster, wPlayerName, 8)
	ld hl, wMonMaster
	ld de, wPlayerName
	ld b, $08
	call CopyToCurMon
;> mem[CurMonField(wMonMaster + 8)] = wPlayerName[8]
	ld hl, wMonMaster + 8
	call CurMonField
	ld a, [wPlayerName + 8]
	ld [hl], a
;> fill(wSceneObjects, 0xFF, 0x19)      # the new list
	ld hl, wSceneObjects
	ld bc, $0019
	ld a, $ff
	call FillMemory
;> wMonSpecies = mem[CurMonField(wMonRecSpecies)]; GetMonsterStats()
	ld hl, wMonRecSpecies
	call CurMonField
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;> AddSkillsToScratch(wMonStats + 6, 3)
	ld de, wMonStats + 6
	ld b, $03
	call AddSkillsToScratch
;> parent = mem[CurMonField(wMonParent1)]
	ld hl, wMonParent1
	call CurMonField
	ld a, [hl]
;> if parent != 0xFF:
	cp $ff
	jr z, .own

;>     wMonSpecies = parent; GetMonsterStats()
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;>     AddSkillsToScratch(wMonStats + 6, 3)
	ld de, wMonStats + 6
	ld b, $03
	call AddSkillsToScratch
;>     wMonSpecies = mem[CurMonField(wMonParent2)]; GetMonsterStats()
	ld hl, wMonParent2
	call CurMonField
	ld a, [hl]
	ld [wMonSpecies], a
	ld hl, far_GetMonsterStats
	rst $10
;>     AddSkillsToScratch(wMonStats + 6, 3)
	ld de, wMonStats + 6
	ld b, $03
	call AddSkillsToScratch

.own
;> AddSkillsByChance(CurMonField(wMonSkillList), 0x19)   # then the old list
	ld hl, wMonSkillList
	call CurMonField
	ld e, l
	ld d, h
	ld b, $19
	call AddSkillsByChance
;>@copy copy(CurMonField(wMonSkillList), wSceneObjects, 0x19)
	ld hl, wMonSkillList
	call CurMonField
	ld de, wSceneObjects
	ld b, $19

.copy
;=@copy
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .copy

;> mem[CurMonField(wMonEgg)] = 0
	ld hl, wMonEgg
	call CurMonField
	ld [hl], $00
	ret


;@ def CurMonField(field: hl) -> hl
;@ path: monster/join
;@ Address of a record field (given as its address in record 0) of monster wCurPartyMember.
;@ test: skip calls MonsterField
CurMonField::
;> return MonsterField(field, wCurPartyMember)
	ld a, [wCurPartyMember]
	call MonsterField
	ret


;@ def CopyToCurMon(field: hl, src: de, count: b)
;@ path: monster/join
;@ Copies `count` bytes from `src` into a field of monster wCurPartyMember.
;@ test: skip calls MonsterField
CopyToCurMon::
;> dest = CurMonField(field)
	push bc
	push de
	ld a, [wCurPartyMember]
	call MonsterField
	pop de
	pop bc

.loop
;>@copy copy(dest, src, count)
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .loop

	ret


;@ def AddSkillsToScratch(skills: de, count: b)
;@ path: monster/join
;@ Adds the series of each of `count` skills to the skill list being built in wSceneObjects.
;@ test: skip reads the skill table
AddSkillsToScratch::
;> for i in range(count):
;>@loop     AddSkillToScratch(mem[skills + i])
	ld a, [de]
	inc de
	push bc
	push de
	call AddSkillToScratch
	pop de
;=@loop
	pop bc
	dec b
	jr nz, AddSkillsToScratch

	ret


;@ def AddSkillsByChance(skills: de, count: b)
;@ path: monster/join
;@ Meant to add each of `count` skills with a chance of plus/100 (a random number below 100
;@ compared with the monster's plus), but the result of the comparison is jumped over: every
;@ skill is added (AddSkillToScratch).
;@ test: skip calls Random
AddSkillsByChance::
;> for i in range(count):
;>@roll     roll = Random() % 100            # (not used)
	push bc
	push de
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
;=@roll
	ld h, a
	ld a, $64
	call Divide16
	ld b, a
	push bc
	ld hl, wMonPlus
;=@roll
	call CurMonField
	pop bc
	ld a, [hl]
	cp b
	pop de
	pop bc
;=@roll
	jr .add

	db $13, $05, $20, $db, $c9

.add
;>@add     AddSkillToScratch(mem[skills + i])
	ld a, [de]
	inc de
	push bc
	push de
	call AddSkillToScratch
	pop de
;=@add
	pop bc
	dec b
	jr nz, AddSkillsByChance

	ret


;@ def AddSkillToScratch(skill: a)
;@ path: monster/join
;@ Adds the first skill of `skill`'s series (SkillBaseTable) to the 25-place skill list in
;@ wSceneObjects, unless it is there already or the list is full.
;@ test: skip reads the skill table
AddSkillToScratch::
;> if skill == 0xFF:
;>     return
	cp $ff
	ret z

;>@base base = SkillBaseTable[skill]
	ld hl, SkillBaseTable
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@base
	ld a, [hl]
;> if base == 0xFF:
;>     return
	cp $ff
	ret z

;> p = wSceneObjects
	ld hl, wSceneObjects
	ld b, $19
	ld c, a

.loop
;>@loop for i in range(25):
;>     if mem[p + i] == base: return
	ld a, [hl]
	cp c
	ret z

;>     if mem[p + i] == 0xFF:
	cp $ff
	jr nz, .next

;>         mem[p + i] = base; return
	ld [hl], c
	ret


.next
;=@loop
	inc hl
	dec b
	jr nz, .loop

	ret


;@ def LookupBreedPair()
;@ path: breed/rules
;@ Reads the BreedPairTable entry of offspring species wBreedQuery: the pedigree into
;@ wBreedPair[0], the mate into wBreedPair[1] (species, or $F0 + family; $FF none).
;@ test: wBreedQuery = rand(0, 0xD9)
LookupBreedPair::
;>@p p = BreedPairTable + 2 * wBreedQuery
	ld a, [wBreedQuery]
	ld l, a
	ld h, $00
	add hl, hl
	ld a, l
	add LOW(BreedPairTable)
;=@p
	ld l, a
	ld a, h
	adc HIGH(BreedPairTable)
	ld h, a
;> wBreedPair[0] = mem[p]
	ld a, [hli]
	ld [wBreedPair], a
;> wBreedPair[1] = mem[p + 1]
	ld a, [hl]
	ld [wBreedTemp], a
	ret


;@ path: breed/rules
;@ For each of the 256 skill ids the first skill of its series ($FF: none), so an offspring
;@ learns a series from its start.
SkillBaseTable::
	db $00, $00, $00, $03, $03, $03, $06, $06, $06, $09, $09, $09, $0c, $0c, $0c, $0f
	db $0f, $0f, $12, $12, $14, $15, $15, $17, $18, $19, $1a, $1a, $1c, $1c, $1e, $1e
	db $20, $20, $22, $22, $24, $25, $26, $27, $27, $29, $2a, $2b, $2b, $2b, $2e, $2e
	db $30, $30, $32, $33, $34, $35, $36, $37, $38, $39, $ff, $3b, $3c, $3d, $3e, $3f
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
	db $50, $50, $52, $52, $54, $55, $56, $57, $58, $58, $5a, $5b, $5c, $5c, $5c, $5c
	db $60, $60, $60, $60, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6c, $6e, $6f
	db $70, $71, $72, $73, $74, $75, $75, $77, $78, $79, $79, $7b, $7b, $7d, $7e, $7f
	db $80, $81, $82, $83, $84, $84, $84, $84, $88, $88, $8a, $8a, $8c, $ff, $8e, $8f
	db $90, $91, $92, $93, $94, $95, $96, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $d5, $d6, $d7, $d8, $d9, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
;@ path: breed/rules
;@ The breeding pairs, 2 bytes per offspring species (the entry number is the species):
;@ pedigree, mate. A byte below $F0 is a species, $F0 + n stands for any monster of family n,
;@ $FA for any family; $FF $FF marks a species with no pair, $00 $00 ends the table.
BreedPairTable::
	db $f0, $f1, $f0, $f2, $f0, $f3, $f0, $f4, $f0, $f5, $f0, $f6, $f0, $f7, $f0, $f8
	db $ff, $ff, $f0, $5a, $f0, $2e, $f0, $c6, $f0, $bd, $f0, $33, $ff, $ff, $f0, $f9
	db $f0, $b9, $10, $10, $11, $11, $12, $12, $f1, $f0, $f1, $f2, $f1, $f3, $f1, $f4
	db $f1, $f5, $f1, $f6, $f1, $f7, $f1, $f8, $14, $14, $f1, $46, $f1, $32, $f1, $53
	db $f1, $b8, $f1, $77, $f1, $5f, $f1, $06, $f1, $7d, $ff, $ff, $f1, $4f, $26, $26
	db $27, $27, $22, $8c, $f1, $8d, $f1, $55, $2b, $29, $f2, $f0, $f2, $f1, $f2, $f3
	db $f2, $f4, $f2, $f5, $ff, $ff, $f2, $f7, $f2, $f8, $ff, $ff, $f2, $a4, $f2, $15
	db $f2, $4a, $f2, $62, $f2, $f6, $f2, $8f, $f2, $bb, $f2, $21, $f2, $0a, $f2, $00
	db $f2, $4b, $40, $40, $41, $41, $f2, $f9, $f2, $1c, $f2, $87, $f3, $f0, $f3, $f1
	db $f3, $f2, $f3, $f4, $f3, $f5, $f3, $f6, $f3, $f7, $f3, $f8, $ff, $ff, $ff, $ff
	db $f3, $0b, $ff, $ff, $f3, $7c, $f3, $b2, $f3, $c1, $f3, $bf, $f3, $f9, $f3, $1f
	db $f3, $64, $54, $55, $f4, $f0, $f4, $f1, $f4, $f2, $f4, $f3, $f4, $f5, $f4, $f6
	db $f4, $f7, $f4, $f8, $ff, $ff, $f4, $70, $f4, $b3, $f4, $82, $f4, $a5, $f4, $58
	db $f4, $30, $f4, $86, $69, $69, $6a, $6a, $f4, $f9, $ff, $ff, $f5, $f0, $f5, $f1
	db $f5, $f2, $f5, $f3, $f5, $f4, $f5, $f6, $f5, $f7, $f5, $f8, $ff, $ff, $ff, $ff
	db $f5, $5c, $f5, $37, $f5, $61, $f5, $31, $f5, $9b, $f5, $a0, $f5, $3d, $75, $75
	db $7f, $7f, $f5, $f9, $f6, $f0, $f6, $f9, $ff, $ff, $f6, $f3, $f6, $f4, $f6, $f5
	db $f6, $f7, $f6, $f8, $ff, $ff, $f6, $f2, $f6, $f1, $f6, $19, $f6, $43, $f6, $68
	db $f6, $39, $85, $85, $8a, $8a, $f6, $1e, $93, $93, $f6, $b6, $f6, $45, $ff, $ff
	db $f6, $79, $94, $59, $97, $c7, $f7, $f0, $f7, $1b, $f7, $f2, $f7, $f3, $f7, $f4
	db $f7, $f5, $f7, $f6, $f7, $f8, $ff, $ff, $f7, $6e, $f7, $4d, $f7, $f1, $f7, $34
	db $f7, $72, $a1, $a1, $f7, $f9, $a3, $a3, $ab, $ab, $ac, $ac, $ff, $ff, $f8, $f0
	db $f8, $f1, $f8, $f2, $f8, $f3, $f8, $f4, $f8, $f5, $f8, $f6, $f8, $f7, $ff, $ff
	db $f8, $74, $f8, $22, $f8, $f9, $f8, $73, $f8, $5d, $f8, $88, $f8, $04, $b7, $5b
	db $b9, $83, $bd, $42, $f8, $07, $b7, $b7, $c3, $c3, $c4, $c4, $b4, $b4, $c1, $c0
	db $ad, $25, $c8, $2c, $aa, $12, $99, $6c, $ca, $29, $c8, $cb, $9a, $2c, $ce, $42
	db $cf, $13, $d0, $24, $cc, $43, $cd, $d0, $d3, $80, $d4, $d2, $d5, $6d, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00

;@ path: breed/rules
;@ The special pairs that need a minimum plus value, 5 bytes each: pedigree, mate (species or
;@ $F0 + family), lowest plus, offspring species, plus bonus; $FF ends the table.
SpecialPairTable::
	db $00, $1b, $00, $0c
	db $00, $00, $24, $00, $0c, $00, $00, $25, $00, $0c, $00, $00, $2a, $00, $0c, $00
	db $00, $2b, $00, $0c, $00, $05, $1b, $00, $0c, $00, $05, $24, $00, $0c, $00, $05
	db $25, $00, $0c, $00, $05, $2a, $00, $0c, $00, $05, $2b, $00, $0c, $00, $0b, $1b
	db $00, $0c, $00, $0b, $24, $00, $0c, $00, $0b, $25, $00, $0c, $00, $0b, $2a, $00
	db $0c, $00, $0b, $2b, $00, $0c, $00, $11, $1b, $00, $0c, $00, $11, $24, $00, $0c
	db $00, $11, $25, $00, $0c, $00, $11, $2a, $00, $0c, $00, $11, $2b, $00, $0c, $00
	db $0f, $25, $00, $0e, $00, $0f, $2a, $00, $0e, $00, $0f, $2c, $00, $0e, $00, $0f
	db $3e, $00, $0e, $00, $0f, $42, $00, $0e, $00, $0f, $53, $00, $0e, $00, $0f, $56
	db $00, $0e, $00, $0f, $57, $00, $0e, $00, $0f, $96, $00, $0e, $00, $0f, $97, $00
	db $0e, $00, $0f, $a9, $00, $0e, $00, $0f, $aa, $00, $0e, $00, $12, $25, $00, $0e
	db $00, $12, $2a, $00, $0e, $00, $12, $2c, $00, $0e, $00, $12, $3e, $00, $0e, $00
	db $12, $42, $00, $0e, $00, $12, $53, $00, $0e, $00, $12, $56, $00, $0e, $00, $12
	db $57, $00, $0e, $00, $12, $96, $00, $0e, $00, $12, $97, $00, $0e, $00, $12, $a9
	db $00, $0e, $00, $12, $aa, $00, $0e, $00, $0e, $25, $00, $0f, $00, $0e, $2a, $00
	db $0f, $00, $0e, $2c, $00, $0f, $00, $0e, $3e, $00, $0f, $00, $0e, $42, $00, $0f
	db $00, $0e, $53, $00, $0f, $00, $0e, $56, $00, $0f, $00, $0e, $57, $00, $0f, $00
	db $0e, $96, $00, $0f, $00, $0e, $97, $00, $0f, $00, $0e, $a9, $00, $0f, $00, $0e
	db $aa, $00, $0f, $00, $08, $08, $05, $0f, $00, $01, $01, $05, $0e, $00, $0e, $c7
	db $00, $13, $00, $0f, $c7, $00, $13, $00, $12, $c7, $00, $13, $00, $0e, $b9, $00
	db $12, $00, $0f, $b9, $00, $12, $00, $14, $14, $04, $25, $00, $14, $14, $00, $1c
	db $00, $1c, $1c, $04, $25, $00, $17, $3f, $00, $22, $00, $17, $41, $00, $22, $00
	db $17, $53, $00, $22, $00, $17, $57, $00, $22, $00, $17, $58, $00, $22, $00, $17
	db $83, $00, $22, $00, $17, $8d, $00, $22, $00, $17, $8e, $00, $22, $00, $17, $90
	db $00, $22, $00, $17, $94, $00, $22, $00, $17, $a9, $00, $22, $00, $17, $c4, $00
	db $22, $00, $1e, $3f, $00, $22, $00, $1e, $41, $00, $22, $00, $1e, $53, $00, $22
	db $00, $1e, $57, $00, $22, $00, $1e, $58, $00, $22, $00, $1e, $83, $00, $22, $00
	db $1e, $8d, $00, $22, $00, $1e, $8e, $00, $22, $00, $1e, $90, $00, $22, $00, $1e
	db $94, $00, $22, $00, $1e, $a9, $00, $22, $00, $1e, $c4, $00, $22, $00, $2a, $3f
	db $00, $22, $00, $2a, $41, $00, $22, $00, $2a, $53, $00, $22, $00, $2a, $57, $00
	db $22, $00, $2a, $58, $00, $22, $00, $2a, $83, $00, $22, $00, $2a, $8d, $00, $22
	db $00, $2a, $8e, $00, $22, $00, $2a, $90, $00, $22, $00, $2a, $94, $00, $22, $00
	db $2a, $a9, $00, $22, $00, $2a, $c4, $00, $22, $00, $2b, $3f, $00, $22, $00, $2b
	db $41, $00, $22, $00, $2b, $53, $00, $22, $00, $2b, $57, $00, $22, $00, $2b, $58
	db $00, $22, $00, $2b, $83, $00, $22, $00, $2b, $8d, $00, $22, $00, $2b, $8e, $00
	db $22, $00, $2b, $90, $00, $22, $00, $2b, $94, $00, $22, $00, $2b, $a9, $00, $22
	db $00, $2b, $c4, $00, $22, $00, $19, $02, $00, $1f, $00, $19, $41, $00, $1f, $00
	db $19, $44, $00, $1f, $00, $19, $66, $00, $1f, $00, $19, $8d, $00, $1f, $00, $19
	db $8e, $00, $1f, $00, $19, $91, $00, $1f, $00, $19, $96, $00, $1f, $00, $16, $43
	db $00, $28, $00, $16, $95, $00, $28, $00, $16, $ae, $00, $28, $00, $16, $c5, $00
	db $28, $00, $17, $43, $00, $28, $00, $17, $95, $00, $28, $00, $17, $ae, $00, $28
	db $00, $17, $c5, $00, $28, $00, $19, $43, $00, $28, $00, $19, $95, $00, $28, $00
	db $19, $ae, $00, $28, $00, $19, $c5, $00, $28, $00, $2a, $43, $00, $28, $00, $2a
	db $95, $00, $28, $00, $2a, $ae, $00, $28, $00, $2a, $c5, $00, $28, $00, $2b, $43
	db $00, $28, $00, $2b, $95, $00, $28, $00, $2b, $ae, $00, $28, $00, $2b, $c5, $00
	db $28, $00, $22, $0c, $00, $b9, $00, $22, $0f, $00, $b9, $00, $22, $81, $00, $b9
	db $00, $22, $9c, $00, $b9, $00, $22, $bd, $00, $b9, $00, $22, $c4, $00, $b9, $00
	db $22, $c5, $00, $b9, $00, $24, $0c, $00, $b9, $00, $24, $0f, $00, $b9, $00, $24
	db $81, $00, $b9, $00, $24, $9c, $00, $b9, $00, $24, $bd, $00, $b9, $00, $24, $c4
	db $00, $b9, $00, $24, $c5, $00, $b9, $00, $25, $0c, $00, $b9, $00, $25, $0f, $00
	db $b9, $00, $25, $81, $00, $b9, $00, $25, $9c, $00, $b9, $00, $25, $bd, $00, $b9
	db $00, $25, $c4, $00, $b9, $00, $25, $c5, $00, $b9, $00, $22, $8c, $00, $29, $00
	db $25, $8c, $00, $29, $00, $37, $16, $00, $3b, $00, $37, $17, $00, $3b, $00, $37
	db $1b, $00, $3b, $00, $37, $1e, $00, $3b, $00, $37, $2a, $00, $3b, $00, $37, $2b
	db $00, $3b, $00, $3f, $16, $00, $3b, $00, $3f, $17, $00, $3b, $00, $3f, $1b, $00
	db $3b, $00, $3f, $1e, $00, $3b, $00, $3f, $2a, $00, $3b, $00, $3f, $2b, $00, $3b
	db $00, $40, $16, $00, $3b, $00, $40, $17, $00, $3b, $00, $40, $1b, $00, $3b, $00
	db $40, $1e, $00, $3b, $00, $40, $2a, $00, $3b, $00, $40, $2b, $00, $3b, $00, $44
	db $16, $00, $3b, $00, $44, $17, $00, $3b, $00, $44, $1b, $00, $3b, $00, $44, $1e
	db $00, $3b, $00, $44, $2a, $00, $3b, $00, $44, $2b, $00, $3b, $00, $2d, $03, $00
	db $36, $00, $2d, $0a, $00, $36, $00, $2d, $1e, $00, $36, $00, $2d, $58, $00, $36
	db $00, $2d, $5a, $00, $36, $00, $2d, $66, $00, $36, $00, $2d, $74, $00, $36, $00
	db $2d, $85, $00, $36, $00, $2d, $8b, $00, $36, $00, $2d, $ae, $00, $36, $00, $2d
	db $af, $00, $36, $00, $2d, $c2, $00, $36, $00, $32, $03, $00, $36, $00, $32, $0a
	db $00, $36, $00, $32, $1e, $00, $36, $00, $32, $58, $00, $36, $00, $32, $5a, $00
	db $36, $00, $32, $66, $00, $36, $00, $32, $74, $00, $36, $00, $32, $85, $00, $36
	db $00, $32, $8b, $00, $36, $00, $32, $ae, $00, $36, $00, $32, $af, $00, $36, $00
	db $32, $c2, $00, $36, $00, $2d, $51, $00, $41, $00, $2d, $53, $00, $41, $00, $2d
	db $56, $00, $41, $00, $2d, $57, $00, $41, $00, $32, $51, $00, $41, $00, $32, $53
	db $00, $41, $00, $32, $56, $00, $41, $00, $32, $57, $00, $41, $00, $3a, $51, $00
	db $41, $00, $3a, $53, $00, $41, $00, $3a, $56, $00, $41, $00, $3a, $57, $00, $41
	db $00, $3b, $51, $00, $41, $00, $3b, $53, $00, $41, $00, $3b, $56, $00, $41, $00
	db $3b, $57, $00, $41, $00, $2d, $81, $00, $32, $00, $2d, $9c, $00, $32, $00, $2d
	db $a9, $00, $32, $00, $2d, $aa, $00, $32, $00, $2d, $ac, $00, $32, $00, $3a, $81
	db $00, $32, $00, $3a, $9c, $00, $32, $00, $3a, $a9, $00, $32, $00, $3a, $aa, $00
	db $32, $00, $3a, $ac, $00, $32, $00, $3b, $81, $00, $32, $00, $3b, $9c, $00, $32
	db $00, $3b, $a9, $00, $32, $00, $3b, $aa, $00, $32, $00, $3b, $ac, $00, $32, $00
	db $3e, $81, $00, $32, $00, $3e, $9c, $00, $32, $00, $3e, $a9, $00, $32, $00, $3e
	db $aa, $00, $32, $00, $3e, $ac, $00, $32, $00, $40, $81, $00, $32, $00, $40, $9c
	db $00, $32, $00, $40, $a9, $00, $32, $00, $40, $aa, $00, $32, $00, $40, $ac, $00
	db $32, $00, $41, $81, $00, $32, $00, $41, $9c, $00, $32, $00, $41, $a9, $00, $32
	db $00, $41, $aa, $00, $32, $00, $41, $ac, $00, $32, $00, $37, $b9, $00, $32, $00
	db $37, $bd, $00, $32, $00, $37, $c0, $00, $32, $00, $37, $c1, $00, $32, $00, $37
	db $c4, $00, $32, $00, $37, $c5, $00, $32, $00, $3a, $b9, $00, $32, $00, $3a, $bd
	db $00, $32, $00, $3a, $c0, $00, $32, $00, $3a, $c1, $00, $32, $00, $3a, $c4, $00
	db $32, $00, $3a, $c5, $00, $32, $00, $3b, $b9, $00, $32, $00, $3b, $bd, $00, $32
	db $00, $3b, $c0, $00, $32, $00, $3b, $c1, $00, $32, $00, $3b, $c4, $00, $32, $00
	db $3b, $c5, $00, $32, $00, $3e, $b9, $00, $32, $00, $3e, $bd, $00, $32, $00, $3e
	db $c0, $00, $32, $00, $3e, $c1, $00, $32, $00, $3e, $c4, $00, $32, $00, $3e, $c5
	db $00, $32, $00, $3f, $b9, $00, $32, $00, $3f, $bd, $00, $32, $00, $3f, $c0, $00
	db $32, $00, $3f, $c1, $00, $32, $00, $3f, $c4, $00, $32, $00, $3f, $c5, $00, $32
	db $00, $40, $b9, $00, $32, $00, $40, $bd, $00, $32, $00, $40, $c0, $00, $32, $00
	db $40, $c1, $00, $32, $00, $40, $c4, $00, $32, $00, $40, $c5, $00, $32, $00, $32
	db $b9, $00, $41, $00, $32, $ba, $00, $41, $00, $32, $bd, $00, $41, $00, $32, $c0
	db $00, $41, $00, $32, $c1, $00, $41, $00, $32, $c4, $00, $41, $00, $32, $c5, $00
	db $41, $00, $41, $b9, $00, $42, $00, $41, $ba, $00, $42, $00, $41, $c7, $00, $42
	db $00, $51, $0b, $00, $57, $00, $51, $0c, $00, $57, $00, $51, $81, $00, $57, $00
	db $51, $b9, $00, $57, $00, $51, $c4, $00, $57, $00, $51, $c5, $00, $57, $00, $52
	db $0b, $00, $57, $00, $52, $0c, $00, $57, $00, $52, $81, $00, $57, $00, $52, $b9
	db $00, $57, $00, $52, $c4, $00, $57, $00, $52, $c5, $00, $57, $00, $53, $0b, $00
	db $57, $00, $53, $0c, $00, $57, $00, $53, $81, $00, $57, $00, $53, $b9, $00, $57
	db $00, $53, $c4, $00, $57, $00, $53, $c5, $00, $57, $00, $54, $0b, $00, $57, $00
	db $54, $0c, $00, $57, $00, $54, $81, $00, $57, $00, $54, $b9, $00, $57, $00, $54
	db $c4, $00, $57, $00, $54, $c5, $00, $57, $00, $56, $0b, $00, $57, $00, $56, $0c
	db $00, $57, $00, $56, $81, $00, $57, $00, $56, $b9, $00, $57, $00, $56, $c4, $00
	db $57, $00, $56, $c5, $00, $57, $00, $53, $bf, $00, $56, $00, $55, $bf, $00, $56
	db $00, $57, $bf, $00, $56, $00, $71, $71, $00, $7c, $00, $71, $78, $00, $7c, $00
	db $71, $7a, $00, $7c, $00, $78, $71, $00, $7c, $00, $78, $78, $00, $7c, $00, $78
	db $7a, $00, $7c, $00, $7a, $71, $00, $7c, $00, $7a, $78, $00, $7c, $00, $7a, $7a
	db $00, $7c, $00, $84, $0e, $00, $83, $00, $84, $0f, $00, $83, $00, $84, $12, $00
	db $83, $00, $84, $22, $00, $83, $00, $84, $25, $00, $83, $00, $84, $29, $00, $83
	db $00, $84, $41, $00, $83, $00, $84, $42, $00, $83, $00, $84, $56, $00, $83, $00
	db $84, $57, $00, $83, $00, $84, $b9, $00, $83, $00, $84, $c5, $00, $83, $00, $93
	db $0e, $00, $83, $00, $93, $0f, $00, $83, $00, $93, $12, $00, $83, $00, $93, $22
	db $00, $83, $00, $93, $25, $00, $83, $00, $93, $29, $00, $83, $00, $93, $41, $00
	db $83, $00, $93, $42, $00, $83, $00, $93, $56, $00, $83, $00, $93, $57, $00, $83
	db $00, $93, $b9, $00, $83, $00, $93, $c5, $00, $83, $00, $96, $0e, $00, $83, $00
	db $96, $0f, $00, $83, $00, $96, $12, $00, $83, $00, $96, $22, $00, $83, $00, $96
	db $25, $00, $83, $00, $96, $29, $00, $83, $00, $96, $41, $00, $83, $00, $96, $42
	db $00, $83, $00, $96, $56, $00, $83, $00, $96, $57, $00, $83, $00, $96, $b9, $00
	db $83, $00, $96, $c5, $00, $83, $00, $84, $0c, $00, $91, $00, $84, $1b, $00, $91
	db $00, $84, $28, $00, $91, $00, $84, $4d, $00, $91, $00, $84, $53, $00, $91, $00
	db $84, $6c, $00, $91, $00, $84, $7b, $00, $91, $00, $84, $9c, $00, $91, $00, $84
	db $a9, $00, $91, $00, $84, $aa, $00, $91, $00, $93, $0c, $00, $91, $00, $93, $1b
	db $00, $91, $00, $93, $28, $00, $91, $00, $93, $4d, $00, $91, $00, $93, $53, $00
	db $91, $00, $93, $6c, $00, $91, $00, $93, $7b, $00, $91, $00, $93, $9c, $00, $91
	db $00, $93, $a9, $00, $91, $00, $93, $aa, $00, $91, $00, $96, $0c, $00, $91, $00
	db $96, $1b, $00, $91, $00, $96, $28, $00, $91, $00, $96, $4d, $00, $91, $00, $96
	db $53, $00, $91, $00, $96, $6c, $00, $91, $00, $96, $7b, $00, $91, $00, $96, $9c
	db $00, $91, $00, $96, $a9, $00, $91, $00, $96, $aa, $00, $91, $00, $84, $32, $00
	db $90, $00, $84, $3e, $00, $90, $00, $84, $81, $00, $90, $00, $84, $bd, $00, $90
	db $00, $93, $32, $00, $90, $00, $93, $3e, $00, $90, $00, $93, $81, $00, $90, $00
	db $93, $bd, $00, $90, $00, $96, $32, $00, $90, $00, $96, $3e, $00, $90, $00, $96
	db $81, $00, $90, $00, $96, $bd, $00, $90, $00, $83, $91, $00, $94, $00, $9f, $0b
	db $00, $ab, $00, $9f, $0c, $00, $ab, $00, $9f, $51, $00, $ab, $00, $9f, $52, $00
	db $ab, $00, $9f, $5c, $00, $ab, $00, $9f, $7f, $00, $ab, $00, $9f, $8b, $00, $ab
	db $00, $a1, $0b, $00, $ab, $00, $a1, $0c, $00, $ab, $00, $a1, $51, $00, $ab, $00
	db $a1, $52, $00, $ab, $00, $a1, $5c, $00, $ab, $00, $a1, $7f, $00, $ab, $00, $a1
	db $8b, $00, $ab, $00, $a3, $0b, $00, $ab, $00, $a3, $0c, $00, $ab, $00, $a3, $51
	db $00, $ab, $00, $a3, $52, $00, $ab, $00, $a3, $5c, $00, $ab, $00, $a3, $7f, $00
	db $ab, $00, $a3, $8b, $00, $ab, $00, $9f, $32, $00, $ac, $00, $9f, $3a, $00, $ac
	db $00, $9f, $44, $00, $ac, $00, $9f, $4c, $00, $ac, $00, $9f, $53, $00, $ac, $00
	db $9f, $89, $00, $ac, $00, $9f, $90, $00, $ac, $00, $9f, $c4, $00, $ac, $00, $9f
	db $c5, $00, $ac, $00, $a1, $32, $00, $ac, $00, $a1, $3a, $00, $ac, $00, $a1, $44
	db $00, $ac, $00, $a1, $4c, $00, $ac, $00, $a1, $53, $00, $ac, $00, $a1, $89, $00
	db $ac, $00, $a1, $90, $00, $ac, $00, $a1, $c4, $00, $ac, $00, $a1, $c5, $00, $ac
	db $00, $a3, $32, $00, $ac, $00, $a3, $3a, $00, $ac, $00, $a3, $44, $00, $ac, $00
	db $a3, $4c, $00, $ac, $00, $a3, $53, $00, $ac, $00, $a3, $89, $00, $ac, $00, $a3
	db $90, $00, $ac, $00, $a3, $c4, $00, $ac, $00, $a3, $c5, $00, $ac, $00, $a4, $32
	db $00, $ac, $00, $a4, $3a, $00, $ac, $00, $a4, $44, $00, $ac, $00, $a4, $4c, $00
	db $ac, $00, $a4, $53, $00, $ac, $00, $a4, $89, $00, $ac, $00, $a4, $90, $00, $ac
	db $00, $a4, $c4, $00, $ac, $00, $a4, $c5, $00, $ac, $00, $a4, $83, $00, $a9, $00
	db $a4, $8d, $00, $a9, $00, $a4, $91, $00, $a9, $00, $a4, $b9, $00, $a9, $00, $a4
	db $bd, $00, $a9, $00, $a6, $83, $00, $a9, $00, $a6, $8d, $00, $a9, $00, $a6, $91
	db $00, $a9, $00, $a6, $b9, $00, $a9, $00, $a6, $bd, $00, $a9, $00, $ab, $83, $00
	db $a9, $00, $ab, $8d, $00, $a9, $00, $ab, $91, $00, $a9, $00, $ab, $b9, $00, $a9
	db $00, $ab, $bd, $00, $a9, $00, $ac, $83, $00, $a9, $00, $ac, $8d, $00, $a9, $00
	db $ac, $91, $00, $a9, $00, $ac, $b9, $00, $a9, $00, $ac, $bd, $00, $a9, $00, $9c
	db $0e, $00, $aa, $00, $9c, $0f, $00, $aa, $00, $9c, $12, $00, $aa, $00, $9c, $22
	db $00, $aa, $00, $9c, $25, $00, $aa, $00, $9c, $42, $00, $aa, $00, $9c, $54, $00
	db $aa, $00, $9c, $56, $00, $aa, $00, $9c, $57, $00, $aa, $00, $9c, $c7, $00, $aa
	db $00, $a9, $0e, $00, $aa, $00, $a9, $0f, $00, $aa, $00, $a9, $12, $00, $aa, $00
	db $a9, $22, $00, $aa, $00, $a9, $25, $00, $aa, $00, $a9, $42, $00, $aa, $00, $a9
	db $54, $00, $aa, $00, $a9, $56, $00, $aa, $00, $a9, $57, $00, $aa, $00, $a9, $c7
	db $00, $aa, $00, $ab, $0e, $00, $aa, $00, $ab, $0f, $00, $aa, $00, $ab, $12, $00
	db $aa, $00, $ab, $22, $00, $aa, $00, $ab, $25, $00, $aa, $00, $ab, $42, $00, $aa
	db $00, $ab, $54, $00, $aa, $00, $ab, $56, $00, $aa, $00, $ab, $57, $00, $aa, $00
	db $ab, $c7, $00, $aa, $00, $ac, $0e, $00, $aa, $00, $ac, $0f, $00, $aa, $00, $ac
	db $12, $00, $aa, $00, $ac, $22, $00, $aa, $00, $ac, $25, $00, $aa, $00, $ac, $42
	db $00, $aa, $00, $ac, $54, $00, $aa, $00, $ac, $56, $00, $aa, $00, $ac, $57, $00
	db $aa, $00, $ac, $c7, $00, $aa, $00, $9c, $ae, $00, $a9, $00, $a1, $ae, $00, $a9
	db $00, $a4, $ae, $00, $a9, $00, $ab, $ae, $00, $a9, $00, $ac, $ae, $00, $a9, $00
	db $c4, $00, $00, $b8, $00, $c4, $04, $00, $b8, $00, $c4, $05, $00, $b8, $00, $c4
	db $0b, $00, $b8, $00, $c5, $00, $00, $b8, $00, $c5, $04, $00, $b8, $00, $c5, $05
	db $00, $b8, $00, $c5, $0b, $00, $b8, $00, $b0, $51, $00, $bb, $00, $b0, $52, $00
	db $bb, $00, $b0, $55, $00, $bb, $00, $b0, $58, $00, $bb, $00, $b8, $51, $00, $bb
	db $00, $b8, $52, $00, $bb, $00, $b8, $55, $00, $bb, $00, $b8, $58, $00, $bb, $00
	db $c4, $51, $00, $bb, $00, $c4, $52, $00, $bb, $00, $c4, $55, $00, $bb, $00, $c4
	db $58, $00, $bb, $00, $c5, $51, $00, $bb, $00, $c5, $52, $00, $bb, $00, $c5, $55
	db $00, $bb, $00, $c5, $58, $00, $bb, $00, $b1, $00, $00, $bf, $00, $b1, $47, $00
	db $bf, $00, $b1, $4d, $00, $bf, $00, $b1, $55, $00, $bf, $00, $b1, $5b, $00, $bf
	db $00, $b1, $69, $00, $bf, $00, $b5, $00, $00, $bf, $00, $b5, $47, $00, $bf, $00
	db $b5, $4d, $00, $bf, $00, $b5, $55, $00, $bf, $00, $b5, $5b, $00, $bf, $00, $b5
	db $69, $00, $bf, $00, $b7, $00, $00, $bf, $00, $b7, $47, $00, $bf, $00, $b7, $4d
	db $00, $bf, $00, $b7, $55, $00, $bf, $00, $b7, $5b, $00, $bf, $00, $b7, $69, $00
	db $bf, $00, $bb, $0c, $00, $bd, $00, $bb, $25, $00, $bd, $00, $bb, $3e, $00, $bd
	db $00, $bb, $90, $00, $bd, $00, $bb, $93, $00, $bd, $00, $bb, $98, $00, $bd, $00
	db $bb, $a9, $00, $bd, $00, $bb, $ac, $00, $bd, $00, $b9, $9c, $00, $c1, $00, $b9
	db $aa, $00, $c1, $00, $b9, $29, $00, $c0, $00, $b9, $42, $00, $c0, $00, $b9, $56
	db $00, $c0, $00, $b9, $83, $00, $c0, $00, $b9, $97, $00, $c0, $00, $bd, $32, $00
	db $42, $00, $bd, $36, $00, $42, $00, $bd, $3e, $00, $42, $00, $bd, $41, $00, $42
	db $00, $bd, $43, $00, $42, $00, $bd, $44, $00, $42, $00, $bd, $42, $00, $c1, $00
	db $94, $59, $00, $99, $00, $59, $94, $00, $99, $00, $c7, $97, $00, $9a, $00, $97
	db $c7, $00, $9a, $00, $ad, $22, $00, $c8, $00, $ad, $25, $00, $c8, $00, $aa, $12
	db $00, $ca, $00, $99, $6c, $00, $cb, $00, $ca, $29, $00, $cc, $00, $c8, $cb, $00
	db $cd, $00, $c9, $cb, $00, $cd, $00, $9a, $2c, $00, $ce, $00, $ce, $42, $00, $cf
	db $00, $cf, $13, $00, $d0, $00, $d0, $24, $00, $d1, $00, $cc, $43, $00, $d2, $00
	db $cd, $d0, $00, $d3, $00, $cd, $d1, $00, $d3, $00, $d0, $cd, $00, $d3, $00, $d1
	db $cd, $00, $d3, $00, $d3, $80, $00, $d4, $00, $d4, $d2, $00, $d5, $00, $d5, $6d
	db $00, $d6, $00, $17, $f2, $00, $1e, $00, $3a, $f1, $00, $32, $00, $3b, $f1, $00
	db $32, $00, $41, $f1, $00, $32, $00, $45, $f1, $00, $32, $00, $2e, $f1, $00, $40
	db $00, $36, $f1, $00, $41, $00, $2d, $f0, $00, $3e, $00, $32, $f0, $00, $3e, $00
	db $3a, $f0, $00, $3e, $00, $3b, $f0, $00, $3e, $00, $3f, $f0, $00, $3e, $00, $40
	db $f0, $00, $3e, $00, $41, $f0, $00, $3e, $00, $2f, $f3, $00, $34, $00, $3a, $f6
	db $00, $32, $00, $31, $f1, $00, $35, $00, $47, $f1, $00, $52, $00, $51, $f1, $00
	db $52, $00, $53, $f1, $00, $52, $00, $55, $f1, $00, $52, $00, $48, $f2, $00, $51
	db $00, $51, $f6, $00, $53, $00, $47, $f7, $00, $52, $00, $51, $f7, $00, $52, $00
	db $53, $f7, $00, $52, $00, $55, $f7, $00, $52, $00, $46, $f0, $00, $4e, $00, $5a
	db $f2, $00, $64, $00, $64, $f6, $00, $67, $00, $67, $f1, $00, $66, $00, $61, $f2
	db $00, $62, $00, $6e, $f0, $00, $76, $00, $74, $f0, $00, $7c, $00, $6f, $f2, $00
	db $7a, $00, $73, $f8, $00, $79, $00, $71, $f6, $00, $7b, $00, $7a, $f7, $00, $7e
	db $00, $7c, $f7, $00, $7e, $00, $72, $f4, $00, $78, $00, $7c, $f1, $00, $79, $00
	db $79, $f6, $00, $7f, $00, $82, $f0, $00, $8a, $00, $85, $f0, $00, $8a, $00, $87
	db $f0, $00, $8a, $00, $86, $f7, $00, $8c, $00, $8a, $f7, $00, $8c, $00, $8b, $f7
	db $00, $8c, $00, $88, $f1, $00, $84, $00, $89, $f1, $00, $84, $00, $8b, $f1, $00
	db $84, $00, $8c, $f1, $00, $84, $00, $88, $f2, $00, $93, $00, $89, $f2, $00, $93
	db $00, $8b, $f2, $00, $93, $00, $8c, $f2, $00, $93, $00, $88, $f7, $00, $96, $00
	db $89, $f7, $00, $96, $00, $8b, $f7, $00, $96, $00, $8c, $f7, $00, $96, $00, $83
	db $f1, $00, $97, $00, $83, $f8, $00, $98, $00, $83, $f7, $00, $8d, $00, $83, $f2
	db $00, $8e, $00, $91, $f1, $00, $90, $00, $91, $f8, $00, $98, $00, $91, $f7, $00
	db $83, $00, $91, $f2, $00, $97, $00, $90, $f1, $00, $83, $00, $90, $f8, $00, $98
	db $00, $90, $f2, $00, $97, $00, $90, $f7, $00, $91, $00, $9b, $f2, $00, $a3, $00
	db $9b, $f6, $00, $a8, $00, $a3, $f6, $00, $a8, $00, $a0, $f6, $00, $a5, $00, $a6
	db $f6, $00, $a5, $00, $9c, $f3, $00, $a6, $00, $a1, $f3, $00, $a6, $00, $a4, $f3
	db $00, $a6, $00, $a9, $f3, $00, $a6, $00, $ab, $f3, $00, $a6, $00, $ac, $f3, $00
	db $a6, $00, $9e, $f3, $00, $a7, $00, $aa, $f6, $00, $ad, $00, $9c, $f1, $00, $9c
	db $00, $a9, $f1, $00, $9c, $00, $aa, $f1, $00, $9c, $00, $ab, $f1, $00, $9c, $00
	db $ac, $f1, $00, $9c, $00, $a6, $f1, $00, $ac, $00, $af, $f0, $00, $b7, $00, $bd
	db $f1, $00, $b9, $00, $bf, $f6, $00, $be, $00, $c0, $f6, $00, $ba, $00, $c1, $f6
	db $00, $ba, $00, $b9, $f1, $00, $b9, $02, $bd, $f5, $00, $c6, $00, $bd, $f7, $00
	db $c2, $00, $bd, $f3, $00, $bc, $00, $f0, $30, $00, $09, $00, $f0, $58, $00, $09
	db $00, $f0, $ae, $00, $09, $00, $f0, $1a, $00, $06, $00, $f0, $7b, $00, $06, $00
	db $f0, $f9, $00, $0f, $02, $f0, $a1, $00, $0b, $00, $f0, $c4, $00, $0b, $00, $f0
	db $c5, $00, $0b, $00, $f0, $32, $00, $0a, $00, $f0, $41, $00, $0a, $00, $f0, $42
	db $00, $0a, $00, $f0, $43, $00, $0a, $00, $f0, $44, $00, $0a, $00, $f0, $b9, $00
	db $10, $00, $f0, $81, $00, $0b, $00, $f1, $f9, $00, $29, $00, $f1, $0e, $00, $25
	db $00, $f1, $0f, $00, $25, $00, $f1, $12, $00, $25, $00, $f1, $2a, $00, $25, $00
	db $f1, $3e, $00, $25, $00, $f1, $56, $00, $25, $00, $f1, $57, $00, $25, $00, $f1
	db $96, $00, $25, $00, $f1, $97, $00, $25, $00, $f1, $42, $00, $2a, $00, $f1, $90
	db $00, $2a, $00, $f1, $95, $00, $2a, $00, $f1, $98, $00, $2a, $00, $f1, $9c, $00
	db $9c, $00, $f1, $a9, $00, $9c, $00, $f1, $aa, $00, $9c, $00, $f1, $ad, $00, $9c
	db $00, $f1, $81, $00, $24, $00, $f2, $19, $00, $3f, $00, $f2, $b9, $00, $3a, $00
	db $f2, $bd, $00, $3a, $00, $f2, $c0, $00, $3a, $00, $f2, $c1, $00, $3a, $00, $f2
	db $c4, $00, $3a, $00, $f2, $c5, $00, $3a, $00, $f3, $00, $00, $55, $00, $f3, $32
	db $00, $55, $00, $f3, $37, $00, $55, $00, $f3, $3a, $00, $55, $00, $f3, $83, $00
	db $55, $00, $f3, $ae, $00, $55, $00, $f3, $c0, $00, $55, $00, $f3, $10, $00, $54
	db $00, $f3, $11, $00, $54, $00, $f3, $36, $00, $54, $00, $f3, $3b, $00, $54, $00
	db $f3, $3f, $00, $54, $00, $f3, $41, $00, $54, $00, $f3, $9c, $00, $54, $00, $f3
	db $a9, $00, $54, $00, $f3, $aa, $00, $54, $00, $f3, $ac, $00, $54, $00, $f3, $ad
	db $00, $54, $00, $f4, $0b, $00, $69, $00, $f4, $45, $00, $69, $00, $f4, $4a, $00
	db $69, $00, $f4, $71, $00, $69, $00, $f4, $7a, $00, $69, $00, $f4, $87, $00, $69
	db $00, $f4, $b5, $00, $69, $00, $f7, $1b, $00, $9c, $00, $f7, $1b, $00, $9c, $00
	db $f7, $1f, $00, $9c, $00, $f7, $22, $00, $9c, $00, $f7, $25, $00, $9c, $00, $f7
	db $29, $00, $9c, $00, $f7, $2a, $00, $9c, $00, $f7, $2c, $00, $9c, $00, $f7, $07
	db $00, $a4, $00, $f7, $0a, $00, $a4, $00, $f7, $2d, $00, $a4, $00, $f7, $3b, $00
	db $a4, $00, $f7, $58, $00, $a4, $00, $f7, $5a, $00, $a4, $00, $f7, $64, $00, $a4
	db $00, $f7, $74, $00, $a4, $00, $f7, $7c, $00, $a4, $00, $f8, $32, $00, $bd, $00
	db $f8, $3a, $00, $bd, $00, $f8, $41, $00, $bd, $00, $f8, $42, $00, $bd, $00, $f8
	db $7f, $00, $c5, $00, $f8, $81, $00, $c5, $00, $ff

;@ def NextGateFloor()
;@ path: field/gatefloor
;@ Picks where the stairs of a gate floor lead. Entering the gate (bit 7 of wOnGateFloor clear)
;@ starts its world at floor 0. The world's GateWorldTable entry gives its tables; on the last
;@ floor the way leads to the boss room (a fixed map), on every third floor of the later
;@ worlds there is a 50% chance of a special floor (SpecialFloorChances, SpecialFloorTable),
;@ else the next floor's map is drawn from FloorMapTables.
;@ test: skip calls routines in other banks
NextGateFloor::
;> if not wOnGateFloor:
;>     return
	ld a, [wOnGateFloor]
	or a
	ret z

;> if wGameStarted & 0x80:              # a continued game: the floor is restored
;>     return
	ld a, [wGameStarted]
	bit 7, a
	ret nz

;> wGateFloor += 1
	ld hl, wGateFloor
	inc [hl]
;> wWorldFlags = 0
	xor a
	ld [wWorldFlags], a
;> if not wOnGateFloor & 0x80:          # just came through the gate
	ld a, [wOnGateFloor]
	bit 7, a
	jr nz, .known

;>     wGateWorld = wMapId
	ld a, [wMapId]
	ld [wGateWorld], a
;>     wGateFloor = 0
	xor a
	ld [wGateFloor], a

.known
;> LoadFloorMusic()
	ld hl, far_LoadFloorMusic
	rst $10
;>@world world = GateWorldTable + wGateWorld * 8
	ld a, [wGateWorld]
	add a
	add a
	add a
	ld hl, GateWorldTable
	add l
;=@world
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wGateFloorSet = mem[world]
	ld a, [hli]
	ld [wGateFloorSet], a
;> wGateSpecialSet = mem[world + 1]
	ld a, [hli]
	ld [wGateSpecialSet], a
;> wGateClass = mem[world + 2]
	ld a, [hli]
	ld [wGateClass], a
;> wGateFloors = mem[world + 3]
	push hl
	ld a, [hli]
	ld [wGateFloors], a
;> wGateWorldMap = mem[world + 4]
	ld a, [hli]
	ld [wGateWorldMap], a
;> wFloorLoot = mem[world + 7]
	inc hl
	inc hl
	ld a, [hl]
	ld [wFloorLoot], a
;> if wGateFloor + 1 != wGateFloors:    # not yet the last floor
	pop hl
	ld a, [wGateFloor]
	ld b, a
	inc a
	cp [hl]
	jr z, .last

;>@special     if wGateWorld and wRandomHigh & 0x10 and wGateFloor % 3 == 2:
	ld a, [wGateWorld]
	or a
	jr z, .normal

;=@special
	ld a, [wRandomHigh]
	bit 4, a
	jr z, .normal

;=@special
	ld a, $03
	call Divide8
	cp $02
;>         return SpecialFloor()        # (below)
	jr z, .special

.normal
;>@pick     wGateFloorSet = PickByPercent(FloorMapTables + wGateFloorSet * 16)
	ld a, [wGateFloorSet]
	add a
	add a
	add a
	add a
	ld hl, FloorMapTables
;=@pick
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call PickByPercent
;=@pick
	ld [wGateFloorSet], a
;>     wMapId = wGateFloorSet
	ld a, [wGateFloorSet]
	ld [wMapId], a
;>     wOnGateFloor = 1
	ld a, $01
	ld [wOnGateFloor], a
;>     return
	ret


;>@last boss = GateWorldTable + wGateWorld * 8 + 4    # the last floor: the boss room
.last
	ld a, [wGateWorld]
	add a
	add a
	add a
	ld hl, GateWorldTable + 4
	add l
;=@last
	ld l, a
	ld a, $00
	adc h
	ld h, a
;> wMapId = mem[boss]
	ld a, [hli]
	ld [wMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>@wx wWarpX = (mem[boss + 1] << 4) + 8    # tile column to pixels
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	or $08
	ld [wWarpX], a
;=@wx
	ld a, b
	and $0f
	ld [$c970], a
;>@wy wWarpY = (mem[boss + 2] << 4) + 8
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	or $08
	ld [wWarpY], a
;=@wy
	ld a, b
	and $0f
	ld [$c972], a
;> return
	ret


;> def SpecialFloor():
;>@sp     wGateSpecialSet = PickByPercent(SpecialFloorChances + wGateSpecialSet * 8)
.special
	ld a, [wGateSpecialSet]
	add a
	add a
	add a
	ld hl, SpecialFloorChances
	add l
;=@sp
	ld l, a
	ld a, $00
	adc h
	ld h, a
	call PickByPercent
	ld [wGateSpecialSet], a
;>     SpecialFloorTable[wGateSpecialSet]()    # jump table right below
	rst $00

;@ path: field/gatefloor
;@ The special floors a gate world may hold (picked by SpecialFloorChances): rooms with items,
;@ a battle room with three monster teams, and several fixed rooms (maps $50-$5C).
SpecialFloorTable::
	dw SpecialFloorItems
	dw SpecialFloorArenaItems
	dw SpecialFloorRoom53
	dw SpecialFloorRoom51
	dw SpecialFloorRoom50
	dw SpecialFloorTeams
	dw SpecialFloorRooms57
	dw SpecialFloorRooms54

;@ def SpecialFloorItems()
;@ path: field/gatefloor
;@ Special floor 0: rolls eight items (RollFloorItems), then one of the rooms $5A-$5C.
;@ test: skip calls Random
SpecialFloorItems::
;> RollFloorItems()
	call RollFloorItems

;@ def WarpToRandomRoom5A()
;@ path: field/gatefloor
;@ Warps to one of the rooms $5A, $5B (both at 72, 72) or $5C (at 104, 72), picked at random.
;@ test: wRandomHigh = rand(0, 255)
WarpToRandomRoom5A::
;> room = wRandomHigh % 3
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
;> if room == 0:
	cp $01
	jr z, .room1

	cp $02
	jr z, .room2

;>     wMapId = 0x5A
	ld a, $5a
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;> elif room == 1:
;>     wMapId = 0x5B
.room1
	ld a, $5b
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;> else:
;>     wMapId = 0x5C
.room2
	ld a, $5c
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x0068
	ld hl, $0068
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;@ def SpecialFloorArenaItems()
;@ path: field/gatefloor
;@ Special floor 1: clears the 8 bytes from wArenaWins on, puts one special item in one of the
;@ first four (RollSpecialItem), then one of the rooms $5A-$5C.
;@ test: skip calls Random
SpecialFloorArenaItems::
;> fill(wArenaWins, 0xFF, 8)
	ld hl, wArenaWins
	ld bc, $0008
	ld a, $ff
	call FillMemory
;> RollSpecialItem()
	call RollSpecialItem
;> WarpToRandomRoom5A()
	call WarpToRandomRoom5A
	ret


;@ def SpecialFloorRoom53()
;@ path: field/gatefloor
;@ Special floor 2: the fixed room $53, arriving at (72, 104).
;@ test: wMapId = rand(0, 255)
SpecialFloorRoom53::
;> wMapId = 0x53
	ld a, $53
	ld [wMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;> wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;> wWarpY = 0x0068
	ld hl, $0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;@ def SpecialFloorRoom51()
;@ path: field/gatefloor
;@ Special floor 3: the fixed room $51, arriving at (72, 104).
;@ test: wMapId = rand(0, 255)
SpecialFloorRoom51::
;> wMapId = 0x51
	ld a, $51
	ld [wMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;> wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;> wWarpY = 0x0068
	ld hl, $0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;@ def SpecialFloorRoom50()
;@ path: field/gatefloor
;@ Special floor 4: the fixed room $50, arriving at (72, 104).
;@ test: wMapId = rand(0, 255)
SpecialFloorRoom50::
;> wMapId = 0x50
	ld a, $50
	ld [wMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;> wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;> wWarpY = 0x0068
	ld hl, $0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;@ def SpecialFloorTeams()
;@ path: field/gatefloor
;@ Special floor 5: the battle room $52. Rolls three teams of three monsters matched to the
;@ party's average level (RollLevelEncounter): two are stored as wArenaTeam1/wArenaTeam2, the
;@ third stays the current encounter and gets its graphics set up. Arrival at (104, 104).
;@ test: skip calls routines in other banks
SpecialFloorTeams::
;> wArenaWins = 0
	xor a
	ld [wArenaWins], a
;> wArenaPrize = 0
	ld [wArenaPrize], a
;> RollLevelEncounter()
	call RollLevelEncounter
;>@t1a wArenaTeam1[0] = wEncSpecies[0]       # three u16 species
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [wArenaTeam1], a
;=@t1a
	ld a, h
	ld [$d9d2], a
;>@t1b wArenaTeam1[1] = wEncSpecies[1]
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$d9d3], a
;=@t1b
	ld a, h
	ld [$d9d4], a
;>@t1c wArenaTeam1[2] = wEncSpecies[2]
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$d9d5], a
;=@t1c
	ld a, h
	ld [$d9d6], a
;> RollLevelEncounter()
	call RollLevelEncounter
;>@t2a wArenaTeam2[0] = wEncSpecies[0]
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
	ld [wArenaTeam2], a
;=@t2a
	ld a, h
	ld [$d9da], a
;>@t2b wArenaTeam2[1] = wEncSpecies[1]
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
	ld [$d9db], a
;=@t2b
	ld a, h
	ld [$d9dc], a
;>@t2c wArenaTeam2[2] = wEncSpecies[2]
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
	ld [$d9dd], a
;=@t2c
	ld a, h
	ld [$d9de], a
;> RollLevelEncounter()
	call RollLevelEncounter
;> SetGateTeamGfx(wEncGfx)
	ld hl, wEncGfx
	call SetGateTeamGfx
;> wMapId = 0x52
	ld a, $52
	ld [wMapId], a
;> wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;> wWarpX = 0x0068
	ld hl, $0068
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;> wWarpY = 0x0068
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
;> wArenaRound = 0
	xor a
	ld [wArenaRound], a
	ret


;@ def SetGateTeamGfx(dest: hl)
;@ path: field/gatefloor
;@ Fills the three 2-byte graphics entries at dest for the encounter monsters: unused entries
;@ get $FF, 0; each monster (wEncCount + 1 of them) gets its template's graphics id and 1.
;@ test: skip calls routines in other banks
SetGateTeamGfx::
;>@clr mem[dest:dest+6] = [0xFF, 0, 0xFF, 0, 0xFF, 0]
	push hl
	ld a, $ff
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
;=@clr
	ld [hli], a
	xor a
	ld [hli], a
	ld a, $ff
	ld [hli], a
	xor a
;=@clr
	ld [hl], a
	pop hl
;>@m0 wNewMonId = wEncSpecies[0]
	push hl
	ld a, [wEncSpecies]
	ld l, a
	ld a, [$da04]
	ld h, a
	ld a, l
;=@m0
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
;> mem[dest] = MonTemplateGfx()
	call MonTemplateGfx
	pop hl
	ld [hli], a
;> mem[dest + 1] = 1
	ld a, $01
	ld [hli], a
;> if wEncCount == 0:
;>     return
	ld a, [wEncCount]
	or a
	ret z

;>@m1 wNewMonId = wEncSpecies[1]
	push hl
	ld a, [$da05]
	ld l, a
	ld a, [$da06]
	ld h, a
	ld a, l
;=@m1
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
;> mem[dest + 2] = MonTemplateGfx()
	call MonTemplateGfx
	pop hl
	ld [hli], a
;> mem[dest + 3] = 1
	ld a, $01
	ld [hli], a
;> if wEncCount == 1:
;>     return
	ld a, [wEncCount]
	cp $01
	ret z

;>@m2 wNewMonId = wEncSpecies[2]
	push hl
	ld a, [$da07]
	ld l, a
	ld a, [$da08]
	ld h, a
	ld a, l
;=@m2
	ld [wNewMonId], a
	ld a, h
	ld [$da13], a
;> mem[dest + 4] = MonTemplateGfx()
	call MonTemplateGfx
	pop hl
	ld [hli], a
;> mem[dest + 5] = 1
	ld a, $01
	ld [hli], a
	ret


;@ def MonTemplateGfx() -> a
;@ path: field/gatefloor
;@ Loads the template of species wNewMonId and returns its graphics id (template byte + $10).
;@ test: skip calls routines in other banks
MonTemplateGfx::
;> LoadMonTemplate2()
	ld hl, far_LoadMonTemplate2
	rst $10
;> return wNewMonNameText + 0x10
	ld a, [wNewMonNameText]
	add $10
	ret


;@ def RollLevelEncounter()
;@ path: field/gatefloor
;@ Rolls an encounter of three monsters fitting the party: the average level of the party's
;@ monsters picks a species range (9 species ids from 2 below level 4, then 18-species ranges
;@ $0D, $21, $39, $51, $69, $81, $9D, $B5 at levels 4, 10, 16, 22, 28, 34, 40, 46), and each
;@ of the three species is drawn at random from it.
;@ test: skip calls routines in other banks
RollLevelEncounter::
;> total = 0
	ld hl, $0000
;> count = 0
	ld c, $00
;> total, count = AddMonLevel(wParty[0], total, count)
	ld a, [wParty]
	call AddMonLevel
;> total, count = AddMonLevel(wParty[1], total, count)
	ld a, [$ca8f]
	call AddMonLevel
;> total, count = AddMonLevel(wParty[2], total, count)
	ld a, [$ca90]
	call AddMonLevel
;> level = total // count
	ld a, c
	call Divide16
	ld a, l
;> first, size = 0x02, 0x09
	ld hl, $0209
;> if level >= 4:
;>     first, size = 0x0D, 0x12
	cp $04
	jr c, jr_016_5ea7

	ld hl, $0d12
;> if level >= 10:
;>     first, size = 0x21, 0x12
	cp $0a
	jr c, jr_016_5ea7

	ld hl, $2112
;> if level >= 16:
;>     first, size = 0x39, 0x12
	cp $10
	jr c, jr_016_5ea7

	ld hl, $3912
;> if level >= 22:
;>     first, size = 0x51, 0x12
	cp $16
	jr c, jr_016_5ea7

	ld hl, $5112
;> if level >= 28:
;>     first, size = 0x69, 0x12
	cp $1c
	jr c, jr_016_5ea7

	ld hl, $6912
;> if level >= 34:
;>     first, size = 0x81, 0x12
	cp $22
	jr c, jr_016_5ea7

	ld hl, $8112
;> if level >= 40:
;>     first, size = 0x9D, 0x12
	cp $28
	jr c, jr_016_5ea7

	ld hl, $9d12
;> if level >= 46:
;>     first, size = 0xB5, 0x12
	cp $2e
	jr c, jr_016_5ea7

	ld hl, $b512
;> RollEncounterSpecies(first, size)    # (below)
	jr jr_016_5ea7

;@ def AddMonLevel(slot: a, total: hl, count: c) -> (hl, c)
;@ path: field/gatefloor
;@ Adds the level of the monster in slot to total and counts it; an empty slot ($FF) is skipped.
;@ test: skip calls routines in other banks
AddMonLevel::
;> if slot == 0xFF:
;>     return total, count
	cp $ff
	ret z

;>@lv level = MonsterField(slot, wMonLevel)
	push bc
	push hl
	ld hl, wMonLevel
	call MonsterField
	ld a, [hl]
	pop hl
;=@lv
	pop bc
;>@g1 return total + level, count + 1
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	inc c
;=@g1
	ret


;> def RollEncounterSpecies(first, size):
;>     wEncCount = 2                    # three monsters
jr_016_5ea7:
	ld a, $02
	ld [wEncCount], a
;>     wEncSpecies[0] = RandomInRange(first, size)
	call RandomInRange
	ld [wEncSpecies], a
;>     wEncSpecies[1] = RandomInRange(first, size)
	call RandomInRange
	ld [$da05], a
;>     wEncSpecies[2] = RandomInRange(first, size)
	call RandomInRange
	ld [$da07], a
;>     clear_high_bytes(wEncSpecies)   # the species ids are below 256
	xor a
	ld [$da04], a
	ld [$da06], a
	ld [$da08], a
	ret


;@ def RandomInRange(first: h, size: l) -> a
;@ path: field/gatefloor
;@ Returns a random number from first to first + size - 1.
;@ test: skip calls Random
RandomInRange::
;> Random()
	push hl
	call Random
;>@g2 return wRandomHigh % size + first
	ld a, [wRandomHigh]
	ld b, a
	ld a, l
	call Divide8
	pop hl
	add h
;=@g2
	ret


;@ def SpecialFloorRooms57()
;@ path: field/gatefloor
;@ Special floor 6: one of the rooms $57 (arriving at 248, 184), $58 or $59 (both at 24, 40),
;@ picked at random.
;@ test: wRandomHigh = rand(0, 255)
SpecialFloorRooms57::
;> room = wRandomHigh % 3
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
;> if room == 0:
	cp $01
	jr z, .room1

	cp $02
	jr z, .room2

;>     wMapId = 0x57
	ld a, $57
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x00F8
	ld hl, $00f8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x00B8
	ld hl, $00b8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;> elif room == 1:
;>     wMapId = 0x58
.room1
	ld a, $58
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x0018
	ld hl, $0018
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x0028
	ld hl, $0028
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;> else:
;>     wMapId = 0x59
.room2
	ld a, $59
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x0018
	ld hl, $0018
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x0028
	ld hl, $0028
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;@ def SpecialFloorRooms54()
;@ path: field/gatefloor
;@ Special floor 7: one of the rooms $54 (arriving at 216, 216), $55 (at 72, 360) or $56
;@ (at 232, 184), picked at random.
;@ test: wRandomHigh = rand(0, 255)
SpecialFloorRooms54::
;> room = wRandomHigh % 3
	ld a, [wRandomHigh]
	ld b, a
	ld a, $03
	call Divide8
;> if room == 0:
	cp $01
	jr z, .room1

	cp $02
	jr z, .room2

;>     wMapId = 0x54
	ld a, $54
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x00D8
	ld hl, $00d8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x00D8
	ld hl, $00d8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;> elif room == 1:
;>     wMapId = 0x55
.room1
	ld a, $55
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x0048
	ld hl, $0048
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x0168
	ld hl, $0168
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;> else:
;>     wMapId = 0x56
.room2
	ld a, $56
	ld [wMapId], a
;>     wOnGateFloor = 0
	ld a, $00
	ld [wOnGateFloor], a
;>     wWarpX = 0x00E8
	ld hl, $00e8
	ld a, l
	ld [wWarpX], a
	ld a, h
	ld [$c970], a
;>     wWarpY = 0x00B8
	ld hl, $00b8
	ld a, l
	ld [wWarpY], a
	ld a, h
	ld [$c972], a
	ret


;@ def PickByPercent(list: hl) -> a
;@ path: field/gatefloor
;@ Picks an index from a cumulative percent list: rolls 0-99 and returns the index of the first
;@ entry above the roll. Entries of 0 are never picked; an entry of 100 always ends the search.
;@ test: skip calls Random
PickByPercent::
;>@roll roll = Random() % 100
	push hl
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
;=@roll
	ld a, $64
	call Divide16
	pop hl
	ld c, a
;> index = -1
;> while True:
	ld b, $ff

;>     index += 1; entry = list[index]
.loop
	ld a, [hl]
	inc b
	inc hl
;>     if entry != 0 and (entry == 100 or entry >= roll):
;>@hit         return index
	or a
	jr z, .loop

;=@hit
	cp $64
	jr z, .found

;=@hit
	cp c
	jr c, .loop

.found
	ld a, b
	ret


;@ def MakeGateFloor()
;@ path: field/gatefloor
;@ Builds a new gate floor. Off the gate floors it only clears the floor's character. On a gate
;@ floor it loads the floor tiles and, unless the floor comes from a save, makes a random floor:
;@ a 4 x 4 grid of screens (wFloorLayout: screen shape in the high nibble, variant in the low;
;@ $F_ = no screen), either a preset layout or screens joined by matching exits, then the
;@ stairs, the floor's special character, Terry's arrival spot and the objects (chests, pots and
;@ the like, up to 3 per screen). Whenever one of these finds no room in 64 tries, the whole
;@ floor is made again.
;@ test: skip calls routines in other banks
MakeGateFloor::
;> ResetEncounterCounter()
	call ResetEncounterCounter
;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_016_6002

;>     wFloorNpcScreen = 0xFF
	ld a, $ff
	ld [wFloorNpcScreen], a
;>     wFloorNpcKind = 0
	xor a
	ld [wFloorNpcKind], a
;>     wFloorNpcVariant = 0
	ld [wFloorNpcVariant], a
;>     wFloorEvent = 0
	xor a
	ld [wFloorEvent], a
;>     wFloorSteps = 0
	xor a
	ld [wFloorSteps], a
;>     return
	ret


;> for i in range(8):                   # the floor tiles
;>@g3     DecompressVRAM(0x2E, 0x15 + i, 0x8500 + i * 0x40)
jr_016_6002:
	ld de, $2e15
	ld hl, $8500
	call DecompressVRAM
	ld de, $2e16
	ld hl, $8540
	call DecompressVRAM
;=@g3
	ld de, $2e17
	ld hl, $8580
	call DecompressVRAM
	ld de, $2e18
	ld hl, $85c0
	call DecompressVRAM
;=@g3
	ld de, $2e19
	ld hl, $8600
	call DecompressVRAM
	ld de, $2e1a
	ld hl, $8640
	call DecompressVRAM
;=@g3
	ld de, $2e1b
	ld hl, $8680
	call DecompressVRAM
	ld de, $2e1c
	ld hl, $86c0
	call DecompressVRAM
;> if not wGameStarted & 0x80:          # a saved floor is already in memory
;>     return NewGateFloor()            # (right below the table)
	ld a, [wGameStarted]
	bit 7, a
	jr z, jr_016_605b

;> wMenuOverlay = 0
	xor a
	ld [wMenuOverlay], a
	ret


;@ path: field/gatefloor
;@ The kinds of floor layout NewGateFloor picks from (wFloorKind): random screens three times in
;@ five, random screens without variants and a preset layout once each.
FloorKindTable::
	db $00, $00, $00, $01, $02

;@ def NewGateFloor()
;@ path: field/gatefloor
;@ Makes a random gate floor (see MakeGateFloor): the layout of screens, then the stairs, the
;@ floor's special character, Terry's arrival spot and the objects. Starts over whenever a spot
;@ cannot be found in 64 tries.
;@ test: skip calls routines in other banks
NewGateFloor::
jr_016_605b:
;>@g6 wFloorKind = FloorKindTable[Random() % 5]
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	ld hl, FloorKindTable
;=@g6
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;=@g6
	ld [wFloorKind], a
;> fill(wFloorsSeen, 0, 16)
	ld hl, wFloorsSeen
	ld bc, $0010
	xor a
	call FillMemory
;> fill(wFloorLayout, 0xFF, 16)
	ld hl, wFloorLayout
	ld bc, $0010
	ld a, $ff
	call FillMemory
;> if wFloorKind == 2:
	ld a, [wFloorKind]
	cp $02
	jr nz, jr_016_60b9

;>@g8     preset = PresetLayouts + (Random() % 21) * 16
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $15
	call Divide8
	ld l, a
;=@g8
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
;=@g8
	add $36
	ld l, a
	ld a, h
	adc $77
	ld h, a
;>@g10     wFloorLayout[0:16] = preset[0:16]
	ld de, wFloorLayout
	ld b, $10

jr_016_60b0:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
;=@g10
	jr nz, jr_016_60b0

	jp Jump_016_616c


;> else:
;>     order = FloorFillOrder           # the screens in the order they are filled
jr_016_60b9:
	ld hl, FloorFillOrder
;>@g11     left = wFloorMusic + 1           # number of screens of this floor
	ld a, [wFloorMusic]
	inc a
	ld b, a
	push hl
	ld a, [hl]
	ld c, a
;=@g11
	push bc
;>     opens = 0
	ld a, b
	cp $09
	ld bc, $0000
;>     if left < 9:                     # small floors: the first screen opens right and/or down
;>@g12         opens = next(m for n in range(1, 257) if (m := (wRandomHigh + n) & 5))
	jr nc, jr_016_60d8

	ld a, [wRandomHigh]
	ld b, a

jr_016_60d1:
	inc b
	ld a, b
	and $05
;=@g12
	jr z, jr_016_60d1

	ld b, a

;>     while (shape := PickScreenShape(opens, 0)) == 0x0F:
;>         pass                         # until a fitting shape comes up
jr_016_60d8:
	push bc
	call PickScreenShape
	pop bc
	cp $0f
	jr z, jr_016_60d8

;>@g13     wFloorLayout[order[0]] = shape
	pop bc
	push af
	ld a, c
	ld hl, wFloorLayout
	add l
	ld l, a
;=@g13
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a
	pop hl
;=@g13
	inc hl
	dec b

;>     for screen in order[1:left]:     # each joins the screens placed before it
;>         opens, closed = GetScreenExits(screen)
jr_016_60f2:
	push hl
	ld a, [hl]
	ld c, a
	push bc
	call GetScreenExits
;>         shape = 0xFF if not opens else PickScreenShape(opens, closed)
	ld a, b
	or a
	ld a, $ff
	jr z, jr_016_6102

	call PickScreenShape

;>@g15         wFloorLayout[screen] = shape
jr_016_6102:
	pop bc
	push af
	ld a, c
	ld hl, wFloorLayout
	add l
	ld l, a
;=@g15
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a
	pop hl
;=@g15
	inc hl
	dec b
	jr nz, jr_016_60f2

;>     for screen in FloorFillOrder:    # close every exit that leads nowhere
	ld hl, FloorFillOrder
	ld b, $10

jr_016_611a:
	push hl
	ld a, [hl]
	cp $ff
	jr z, jr_016_6140

;>         opens, closed = GetScreenExits(screen)
	ld c, a
	push bc
	call GetScreenExits
;>@g17         shape = 0x0F if not opens else PickScreenShape(opens, opens ^ 0x0F)
	ld a, b
	or a
	ld a, $0f
	jr z, jr_016_6132

	ld a, b
	xor $0f
;=@g17
	ld c, a
	call PickScreenShape

;>@g18         wFloorLayout[screen] = shape
jr_016_6132:
	pop bc
	push af
	ld a, c
	ld hl, wFloorLayout
	add l
	ld l, a
;=@g18
	ld a, $00
	adc h
	ld h, a
	pop af
	ld [hl], a

jr_016_6140:
	pop hl
;=@g18
	inc hl
	dec b
	jr nz, jr_016_611a

;>     for i in range(16):              # shape to the high nibble, add a variant
	ld hl, wFloorLayout
	ld b, $10

jr_016_614a:
	push bc
	push hl
;>@g20         variant = 12 if wFloorKind == 1 else Random() % 12
	ld c, $0c
	ld a, [wFloorKind]
	cp $01
	jr z, jr_016_6162

	call Random
	ld a, [wRandomHigh]
;=@g20
	ld b, a
	ld a, $0c
	call Divide8
	ld c, a

;>@g21         wFloorLayout[i] = swap(wFloorLayout[i]) + variant
jr_016_6162:
	pop hl
	ld a, [hl]
	swap a
	add c
	ld [hli], a
	pop bc
;=@g21
	dec b
	jr nz, jr_016_614a

;> wFloorTries = 64                     # the stairs
Jump_016_616c:
	ld a, $40
	ld [wFloorTries], a

;> while True:
;>     wFloorTries -= 1
jr_016_6171:
	ld a, [wFloorTries]
	dec a
	ld [wFloorTries], a
;>     if wFloorTries == 0:
;>         return NewGateFloor()     # start again
	jp z, NewGateFloor

;>     PickStairsSpot()
	call PickStairsSpot
;>     wStairsScreen = wMapScreen
	ld a, [wMapScreen]
	ld [wStairsScreen], a
;>@g22     stairs = (hTestX, hTestY)
	ldh a, [hTestX]
	ld [$c0a5], a
	ldh a, [$ffa6]
	ld [$c0a6], a
	ldh a, [hTestY]
	ld [$c0a7], a
;=@g22
	ldh a, [$ffa8]
	ld [$c0a8], a
;>     if CheckStairsSpace():
;>         break
	call CheckStairsSpace
	jr z, jr_016_6171

;>@g23 wStairsOffset = (stairs.y & 0xF0) * 4 + (stairs.x >> 3 & 0x1E)    # tilemap offset
	ld a, [$c0a7]
	ld [wGoalY], a
	and $f0
	ld l, a
	ld a, [$c0a8]
	ld [$c967], a
;=@g23
	sla l
	rla
	sla l
	rla
	ld h, a
	ld a, [$c0a6]
;=@g23
	ld [$c965], a
	ld d, a
	ld a, [$c0a5]
	ld [wGoalX], a
	srl d
	rra
;=@g23
	srl d
	rra
	srl d
	rra
	and $1e
	ld e, a
;=@g23
	ld d, $00
	add hl, de
	ld a, l
	ld [wStairsOffset], a
	ld a, h
	ld [$c963], a
;>@g27 wGoalX = stairs.x + ScreenOrigins[wStairsScreen].x    # (bank 0, 4 bytes per screen)
	ld a, [wStairsScreen]
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
;=@g27
	ld a, $00
	adc h
	ld h, a
	ld a, [wGoalX]
	add [hl]
	ld [wGoalX], a
;=@g27
	inc hl
	ld a, [$c965]
	adc [hl]
	ld [$c965], a
	inc hl
;>@g29 wGoalY = stairs.y + ScreenOrigins[wStairsScreen].y
	ld a, [wGoalY]
	add [hl]
	ld [wGoalY], a
	inc hl
	ld a, [$c967]
	adc [hl]
;=@g29
	ld [$c967], a
	inc hl
;> wFloorTries = 64                     # the floor's special character
	ld a, $40
	ld [wFloorTries], a

;> while True:
;>     wFloorTries -= 1
jr_016_620a:
	ld a, [wFloorTries]
	dec a
	ld [wFloorTries], a
;>     if wFloorTries == 0:
;>         return NewGateFloor()     # start again
	jp z, NewGateFloor

;>     PickNpcSpot()
	call PickNpcSpot
;>     if wMapScreen != wStairsScreen:
;>         break
	ld a, [wStairsScreen]
	ld b, a
	ld a, [wMapScreen]
	cp b
	jr z, jr_016_620a

;> wFloorNpcScreen = wMapScreen
	ld a, [wMapScreen]
	ld [wFloorNpcScreen], a
;>@g30 wFloorNpcX = ScreenOrigins[wMapScreen].x + hTestX
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
;=@g30
	adc h
	ld h, a
	ld a, [hli]
	ld [wFloorNpcX], a
	ld a, [hli]
	ld [$c928], a
;>@npcx wFloorNpcY = ScreenOrigins[wMapScreen].y + hTestY
	ld a, [hli]
	ld [wFloorNpcY], a
	ld a, [hli]
	ld [$c92a], a
;=@npcx
	ld hl, wFloorNpcX
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
;=@npcx
	ld [hl], a
;=@npcx
	ld hl, wFloorNpcY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
;=@npcx
	ld [hl], a
;> if wScriptBossIndex in (0, 1):
;>@g33     wFloorEvent = 0
	ld a, [wScriptBossIndex]
	or a
	jr z, jr_016_6262

	cp $01
	jr nz, jr_016_6266

jr_016_6262:
	xor a
;=@g33
	ld [wFloorEvent], a

;> wFloorNpcKind = wFloorEvent
jr_016_6266:
	ld a, [wFloorEvent]
	ld [wFloorNpcKind], a
;>@g34 if wFloorEvent in (4, 5, 6, 7):      # a story character: shown on half of the floors
	cp $04
	jr z, jr_016_627e

	cp $05
	jr z, jr_016_627e

	cp $06
	jr z, jr_016_627e

;=@g34
	cp $07
	jr z, jr_016_627e

	jr jr_016_628a

;>     show = not Random() & 1
;>     roll_kind = False
jr_016_627e:
	call Random
	ld a, [wRandomHigh]
	bit 0, a
	jr z, jr_016_62cf

	jr jr_016_629f

;> else:
;>@g35     show = Random() < FloorNpcChance[wGateClass]
jr_016_628a:
	call Random
	ld a, [wGateClass]
	ld hl, FloorNpcChance
	add l
	ld l, a
	ld a, $00
;=@g35
	adc h
	ld h, a
	ld a, [wRandomHigh]
	cp [hl]
;>     roll_kind = show
	jr c, jr_016_62b5

;> if not show:                         # no character on this floor
;>     wFloorNpcKind = 0
jr_016_629f:
	xor a
	ld [wFloorNpcKind], a
;>     wFloorNpcVariant = 0
	ld [wFloorNpcVariant], a
;>     wFloorEvent = 0
	xor a
	ld [wFloorEvent], a
;>     wFloorSteps = 0
	xor a
	ld [wFloorSteps], a
;>     wFloorNpcScreen = 0xFF
	ld a, $ff
	ld [wFloorNpcScreen], a
	jr jr_016_62cf

;> elif roll_kind:
;>     wFloorNpcVariant = Random() % 5
jr_016_62b5:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $05
	call Divide8
	ld [wFloorNpcVariant], a
;>     wFloorNpcKind = Random() & 3
	call Random
	ld a, [wRandomHigh]
	and $03
	ld [wFloorNpcKind], a

;> wFloorEvent = 0
jr_016_62cf:
	xor a
	ld [wFloorEvent], a
;> wFloorTries = 64                     # where Terry arrives
	ld a, $40
	ld [wFloorTries], a

;> while True:
;>     wFloorTries -= 1
Jump_016_62d8:
jr_016_62d8:
	ld a, [wFloorTries]
	dec a
	ld [wFloorTries], a
;>     if wFloorTries == 0:
;>         return NewGateFloor()     # start again
	jp z, NewGateFloor

;>     PickArrivalSpot()
	call PickArrivalSpot
;>     if wMapScreen == wStairsScreen:  # one more try for another screen
;>         PickArrivalSpot()
	ld hl, wStairsScreen
	ld a, [wMapScreen]
	cp [hl]
	jr nz, jr_016_62f1

	call PickArrivalSpot

;>     wArrivalScreen = wMapScreen
jr_016_62f1:
	ld a, [wMapScreen]
	ld [wArrivalScreen], a
;>     if not IsStairsSpot() and wMapScreen != wFloorNpcScreen:
;>@arr         break
	call IsStairsSpot
	jp z, Jump_016_62d8

;=@arr
	ld a, [wFloorNpcScreen]
	ld b, a
	ld a, [wMapScreen]
	cp b
	jr z, jr_016_62d8

;> arrival = (wMapScreen, hTestX, hTestY)    # in wNumberBackup and the 4 bytes after it
	ld a, [wMapScreen]
	ld [wNumberBackup], a
;>@g36 wWarpX = ScreenOrigins[wMapScreen].x + hTestX
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
	ld a, $00
;=@g36
	adc h
	ld h, a
	ld a, [hli]
	ld [wWarpX], a
	ld a, [hli]
	ld [$c970], a
;>@arrxy wWarpY = ScreenOrigins[wMapScreen].y + hTestY
	ld a, [hli]
	ld [wWarpY], a
	ld a, [hli]
	ld [$c972], a
;=@arrxy
	ldh a, [hTestX]
	ld [$c0a1], a
	ldh a, [$ffa6]
	ld [$c0a2], a
	ldh a, [hTestY]
	ld [wLineUpOrder], a
;=@arrxy
	ldh a, [$ffa8]
	ld [$c0a4], a
;=@arrxy
	ld hl, wWarpX
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
;=@arrxy
	ld [hl], a
;=@arrxy
	ld hl, wWarpY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
;=@arrxy
	ld [hl], a
;> per_screen = [0] * 16                # objects on each screen (in wLineScroll)
	ld hl, wLineScroll
	ld bc, $0010
	xor a
	call FillMemory
;>@g40 rule = FloorObjectTable + wGateClass * 16 + 9
	ld a, [wGateClass]
	ld hl, FloorObjectTable + 9
	add a
	add a
	add a
	add a
;=@g40
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>@g41 count = rule[0] + wRandomHigh % (rule[1] + 1)
	ld a, [hli]
	push af
	ld a, [wRandomHigh]
	ld b, a
	ld a, [hli]
	inc a
;=@g41
	push hl
	call Divide8
	pop hl
	ld b, a
	pop af
	add b
;=@g41
	ld b, a
;> chance = rule[2]
	ld c, [hl]
	push bc
;>@g43 screens = sum(1 for s in wFloorLayout if s < 0xF0)
	ld hl, wFloorLayout
	ld b, $10
	ld c, $00

jr_016_6386:
	ld a, [hli]
	and $f0
	cp $f0
;=@g43
	jr z, jr_016_638e

	inc c

jr_016_638e:
	dec b
	jr nz, jr_016_6386

;> if screens < 6:
;>     count = count >> 1
	ld a, c
	pop bc
	cp $06
	jr nc, jr_016_639b

	srl b
	res 7, b

;> dest = wFloorObjects
jr_016_639b:
	ld hl, wFloorObjects
;> for i in range(count):
	ld a, b
	or a
	jr z, jr_016_63ac

;>     mem[dest] = 0xFF
jr_016_63a2:
	push bc
	ld [hl], $ff
;>     dest = PlaceFloorObject(dest, chance)
	call PlaceFloorObject
	pop bc
	dec b
	jr nz, jr_016_63a2

;> mem[dest] = 0xFF                     # end of the list
jr_016_63ac:
	ld [hl], $ff
	ret


;@ def PickFloorSpot()
;@ path: field/gatefloor/spots
;@ Picks a random spot for an object: a random screen of the floor (the next one present after a
;@ random start), whose map is loaded into wSavedTilemap, and in it a random tile 1-8 across,
;@ 1-6 down, until that tile is plain floor (collision kind $0C or $0D). The result is wMapScreen
;@ and the pixel position in hTestX, hTestY.
;@ test: skip calls routines in other banks
PickFloorSpot::
;> screen = Random()                   # wRandomHigh
	call Random
	ld a, [wRandomHigh]
	ld b, a

;> while True:                          # the next screen that exists
;>     screen += 1
jr_016_63b6:
	inc b
	ld a, b
;>     wMapScreen = screen & 15
	and $0f
	ld [wMapScreen], a
;>     if wFloorLayout[wMapScreen] < 0xF0:
;>@k1         break
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@k1
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_63b6

;> Decompress(GetScreenTilemapRef(), wSavedTilemap)
	ld hl, far_GetScreenTilemapRef
	rst $10
	ld hl, wSavedTilemap
	call Decompress
;> hScrollX = 0
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
;> hScrollY = 0
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a

;> while True:
;>@g44     hTestX = (Random() % 8 + 1) * 16 + 8
jr_016_63e1:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $08
	call Divide8
	add $01
;=@g44
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g44
	and $0f
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
;>@g46     hTestY = (Random() % 6 + 1) * 16 + 8
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $01
;=@g46
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g46
	and $0f
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>     GetCollisionAt()
	call GetCollisionAt
;>     if hTestTile >> 2 in (0x0C, 0x0D):
;>@g48         return
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
;=@g48
	ret z

	jr jr_016_63e1

;@ def PlaceFloorObject(dest: hl, chance: c) -> hl
;@ path: field/gatefloor/spots
;@ Places one object of the floor: its kind comes from the class's FloorObjectTable list, + $10
;@ with the given percent chance. Up to 16 random spots are tried; a spot must leave room around
;@ it (CheckObjectSpace), not be the stairs, the arrival spot or another object, not lie on the
;@ character's screen, and a screen holds at most 3 objects (the stairs and arrival screens and
;@ screens that already have one are avoided while other picks come up). The 4-byte entry at dest
;@ is the kind, the contents (an item from FloorItemTables for chests), and the floor tile column
;@ and row; dest is returned past it. If no spot is found, nothing is written.
;@ test: skip calls routines in other banks
PlaceFloorObject::
;> wFloorTries = 16
	push hl
	ld a, $10
	ld [wFloorTries], a
;>@g49 wFloorObjKind = PickByPercent(FloorObjectTable + wGateClass * 16)
	push bc
	ld a, [wGateClass]
	ld hl, FloorObjectTable
	add a
	add a
	add a
;=@g49
	add a
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@g49
	call PickByPercent
	ld [wFloorObjKind], a
;> if Random() % 100 < chance:
;>@g51     wFloorObjKind += 0x10
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $64
;=@g51
	call Divide16
	pop bc
	cp c
	jr z, Jump_016_646d

	jr nc, Jump_016_646d

	ld a, [wFloorObjKind]
;=@g51
	add $10
	ld [wFloorObjKind], a

;> while True:
;>     wFloorTries -= 1
Jump_016_646d:
jr_016_646d:
	ld a, [wFloorTries]
	dec a
	ld [wFloorTries], a
;>     if wFloorTries == 0:
;>         return dest
	jr nz, jr_016_6478

	pop hl
	ret


;>     PickFloorSpot()
jr_016_6478:
	call PickFloorSpot
;>     if wMapScreen == wStairsScreen:
;>         PickFloorSpot()
	ld a, [wMapScreen]
	ld b, a
	ld a, [wStairsScreen]
	cp b
	jr nz, jr_016_6488

	call PickFloorSpot

;>     if wMapScreen == wArrivalScreen:
;>         PickFloorSpot()
jr_016_6488:
	ld a, [wMapScreen]
	ld b, a
	ld a, [wArrivalScreen]
	cp b
	jr nz, jr_016_6495

	call PickFloorSpot

;>     if per_screen[wMapScreen]:          # per_screen is wLineScroll[16]
;>@g53         PickFloorSpot()
jr_016_6495:
	ld a, [wMapScreen]
	ld hl, wLineScroll
	add l
	ld l, a
	ld a, $00
	adc h
;=@g53
	ld h, a
	ld a, [hl]
	or a
	jr z, jr_016_64a8

	call PickFloorSpot

;>@g54     spot = (hTestX, hTestY)
jr_016_64a8:
	ldh a, [hTestX]
	ld [$c0aa], a
	ldh a, [$ffa6]
	ld [$c0ab], a
	ldh a, [hTestY]
	ld [$c0ac], a
;=@g54
	ldh a, [$ffa8]
	ld [$c0ad], a
;>     if not CheckObjectSpace():
;>         continue
	call CheckObjectSpace
	jr z, jr_016_646d

;>     hTestX = spot.x                      # CheckObjectSpace moved the test position
	ld a, [$c0aa]
	ldh [hTestX], a
	ld a, [$c0ab]
	ldh [$ffa6], a
;>     hTestY = spot.y
	ld a, [$c0ac]
	ldh [hTestY], a
	ld a, [$c0ad]
	ldh [$ffa8], a
;>     if IsStairsSpot() or IsArrivalSpot() or IsObjectSpot():
;>@k1         continue
	call IsStairsSpot
	jr z, jr_016_646d

;=@k1
	call IsArrivalSpot
	jr z, jr_016_646d

;=@k1
	call IsObjectSpot
	jr z, jr_016_646d

;>     if wMapScreen == wFloorNpcScreen:
;>         continue
	ld a, [wMapScreen]
	ld b, a
	ld a, [wFloorNpcScreen]
	cp b
	jp z, Jump_016_646d

;>     if per_screen[wMapScreen] == 3:
;>@g55         continue
	ld a, [wMapScreen]
	ld hl, wLineScroll
	add l
	ld l, a
	ld a, $00
	adc h
;=@g55
	ld h, a
;=@g55
	ld a, [hl]
	cp $03
	jp z, Jump_016_646d

;>     per_screen[wMapScreen] += 1
	inc [hl]
;>@x     x = ScreenOrigins[wMapScreen].x + hTestX    # floor pixel position
	ld a, [wMapScreen]
	add a
	add a
	ld hl, $2da7
	add l
	ld l, a
;=@x
	ld a, $00
	adc h
	ld h, a
	ld a, [hli]
	ldh [hDivisorHigh], a
	ld a, [hli]
;=@x
	ldh [$ffdc], a
;>@y     y = ScreenOrigins[wMapScreen].y + hTestY
	ld a, [hli]
	ldh [hFindY], a
	ld a, [hli]
	ldh [$ffde], a
;=@x
	ld hl, hDivisorHigh
	ldh a, [hTestX]
	add [hl]
	ld [hli], a
	ldh a, [$ffa6]
	adc [hl]
;=@y
	ld [hl], a
;=@y
	ld hl, hFindY
	ldh a, [hTestY]
	add [hl]
	ld [hli], a
	ldh a, [$ffa8]
	adc [hl]
;=@y
	ld [hl], a
;>     mem[dest] = wFloorObjKind
	pop hl
	ld a, [wFloorObjKind]
	ld [hli], a
;>@g58     contents = ObjectIsChestTable[wFloorObjKind & 0x0F]
	push hl
	ld a, [wFloorObjKind]
	and $0f
	ld hl, ObjectIsChestTable
	add l
	ld l, a
;=@g58
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>     if contents == 1:                    # a chest: roll its item
;>@g59         contents = PickByPercent(FloorItemTables + wGateClass * 48)
	cp $01
	jr nz, jr_016_6564

	ld a, [wGateClass]
	ld l, a
	ld h, $00
	add hl, hl
;=@g59
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, l
	ld d, h
	add hl, hl
;=@g59
	add hl, de
	ld a, l
	add $36
	ld l, a
	ld a, h
	adc $74
;=@g59
	ld h, a
	call PickByPercent

;>     mem[dest + 1] = contents
jr_016_6564:
	pop hl
	ld [hli], a
;>@g62     mem[dest + 2] = x >> 4               # floor tile column
	ldh a, [hDivisorHigh]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffdc]
	swap a
;=@g62
	and $f0
	or b
	ld [hli], a
;>@g63     mem[dest + 3] = y >> 4               # floor tile row
	ldh a, [hFindY]
	swap a
	and $0f
	ld b, a
	ldh a, [$ffde]
	swap a
;=@g63
	and $f0
	or b
	ld [hli], a
;>     return dest + 4
	ret


;@ def PickNpcSpot()
;@ path: field/gatefloor/spots
;@ Picks a random spot for the floor's special character: a random screen of the floor (map
;@ loaded into wSavedTilemap), then up to 64 random tiles 1-8 across, 1-6 down, until one has
;@ collision kind $0C, $0D or $0E; failing that, the next screen is tried.
;@ test: skip calls routines in other banks
PickNpcSpot::
;> screen = Random()                   # wRandomHigh
	call Random
	ld a, [wRandomHigh]
	ld b, a

;> while True:                          # the next screen that exists
;>     screen += 1
Jump_016_658c:
jr_016_658c:
	inc b
	ld a, b
;>     wMapScreen = screen & 15
	and $0f
	ld [wMapScreen], a
;>     if wFloorLayout[wMapScreen] >= 0xF0:
;>@k1         continue
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@k1
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_658c

;>     Decompress(GetScreenTilemapRef(), wSavedTilemap)
	ld hl, far_GetScreenTilemapRef
	rst $10
	ld hl, wSavedTilemap
	call Decompress
;>     hScrollX = 0
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
;>     hScrollY = 0
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a
;>     for hNumber in range(64, 0, -1):
	ld a, $40
	ldh [hNumber], a

;>@g64         hTestX = (Random() % 8 + 1) * 16 + 8
jr_016_65bb:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $08
	call Divide8
	add $01
;=@g64
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g64
	and $0f
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
;>@g66         hTestY = (Random() % 6 + 1) * 16 + 8
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $01
;=@g66
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g66
	and $0f
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>         GetCollisionAt()
	call GetCollisionAt
;>         if hTestTile >> 2 in (0x0C, 0x0D, 0x0E):
;>@g68             return
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
;=@g68
	ret z

	cp $0e
	ret z

	ldh a, [hNumber]
	dec a
	ldh [hNumber], a
;=@g68
	jr nz, jr_016_65bb

;>     screen = wMapScreen
	ld a, [wMapScreen]
	ld b, a
	jp Jump_016_658c


;@ def PickArrivalSpot()
;@ path: field/gatefloor/spots
;@ Picks a random spot where Terry arrives on the floor: like PickNpcSpot, but only tiles with
;@ collision kind $0C or $0D count.
;@ test: skip calls routines in other banks
PickArrivalSpot::
;> screen = Random()                   # wRandomHigh
	call Random
	ld a, [wRandomHigh]
	ld b, a

;> while True:                          # the next screen that exists
;>     screen += 1
Jump_016_6622:
jr_016_6622:
	inc b
	ld a, b
;>     wMapScreen = screen & 15
	and $0f
	ld [wMapScreen], a
;>     if wFloorLayout[wMapScreen] >= 0xF0:
;>@k1         continue
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@k1
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_6622

;>     Decompress(GetScreenTilemapRef(), wSavedTilemap)
	ld hl, far_GetScreenTilemapRef
	rst $10
	ld hl, wSavedTilemap
	call Decompress
;>     hScrollX = 0
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
;>     hScrollY = 0
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a
;>     for hNumber in range(64, 0, -1):
	ld a, $40
	ldh [hNumber], a

;>@g70         hTestX = (Random() % 8 + 1) * 16 + 8
jr_016_6651:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $08
	call Divide8
	add $01
;=@g70
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g70
	and $0f
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
;>@g72         hTestY = (Random() % 6 + 1) * 16 + 8
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $01
;=@g72
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g72
	and $0f
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>         GetCollisionAt()
	call GetCollisionAt
;>         if hTestTile >> 2 in (0x0C, 0x0D):
;>@g74             return
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
;=@g74
	ret z

	ldh a, [hNumber]
	dec a
	ldh [hNumber], a
	jr nz, jr_016_6651

;>     screen = wMapScreen
	ld a, [wMapScreen]
	ld b, a
	jp Jump_016_6622


;@ def PickStairsSpot()
;@ path: field/gatefloor/spots
;@ Picks a random spot for the stairs: like PickNpcSpot (collision kinds $0C-$0E), but only tiles
;@ 2-7 across and 2-5 down, away from the screen edges.
;@ test: skip calls routines in other banks
PickStairsSpot::
;> screen = Random()                   # wRandomHigh
	call Random
	ld a, [wRandomHigh]
	ld b, a

;> while True:                          # the next screen that exists
;>     screen += 1
Jump_016_66b5:
jr_016_66b5:
	inc b
	ld a, b
;>     wMapScreen = screen & 15
	and $0f
	ld [wMapScreen], a
;>     if wFloorLayout[wMapScreen] >= 0xF0:
;>@k1         continue
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@k1
	ld a, [hl]
	and $f0
	cp $f0
	jr z, jr_016_66b5

;>     Decompress(GetScreenTilemapRef(), wSavedTilemap)
	ld hl, far_GetScreenTilemapRef
	rst $10
	ld hl, wSavedTilemap
	call Decompress
;>     hScrollX = 0
	xor a
	ldh [hScrollX], a
	ldh [$ffb8], a
;>     hScrollY = 0
	xor a
	ldh [hScrollY], a
	ldh [$ffbc], a
;>     for hNumber in range(64, 0, -1):
	ld a, $40
	ldh [hNumber], a

;>@g75         hTestX = (Random() % 6 + 2) * 16 + 8
jr_016_66e4:
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $06
	call Divide8
	add $02
;=@g75
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g75
	and $0f
	ld h, a
	ld a, l
	ldh [hTestX], a
	ld a, h
	ldh [$ffa6], a
;>@g77         hTestY = (Random() % 4 + 2) * 16 + 8
	call Random
	ld a, [wRandomHigh]
	ld b, a
	ld a, $04
	call Divide8
	add $02
;=@g77
	swap a
	ld h, a
	and $f0
	or $08
	ld l, a
	ld a, h
;=@g77
	and $0f
	ld h, a
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
;>         GetCollisionAt()
	call GetCollisionAt
;>         if hTestTile >> 2 in (0x0C, 0x0D, 0x0E):
;>@g79             return
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

	cp $0d
;=@g79
	ret z

	cp $0e
	ret z

	ldh a, [hNumber]
	dec a
	ldh [hNumber], a
;=@g79
	jr nz, jr_016_66e4

;>     screen = wMapScreen
	ld a, [wMapScreen]
	ld b, a
	jp Jump_016_66b5


;@ def GetScreenExits(screen: a) -> (b, c)
;@ path: field/gatefloor/layout
;@ Works out which exits a screen of the 4 x 4 floor grid needs. Exit bits: 8 up, 4 down,
;@ 2 left, 1 right. For each side, a neighbour screen whose shape (ScreenShapeTable) has an exit
;@ towards this one sets the bit in b (must be open); a neighbour without that exit, or the edge
;@ of the grid, sets it in c (must be closed); an empty neighbour ($FF) leaves both clear.
;@ test: skip reads table entries as named fields
GetScreenExits::
;> opens = 0
;> closed = 0
	ld bc, $0000
	ld d, a
;>@k1 above = wFloorLayout[screen - 4] if screen >= 4 else None    # the screen above
	sub $04
	jr c, jr_016_676f

	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
;=@k1
	adc h
	ld h, a
	ld a, [hl]
;>@k2 if above is not None and above != 0xFF and ScreenShapeTable[above].exits & 4:
	cp $ff
	jr z, jr_016_6773

	add a
	add a
	ld hl, ScreenShapeTable
	add l
;=@k2
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 2, [hl]
	jr z, jr_016_676f

;>     opens |= 8                       # it has an exit down to this screen
	ld a, $08
	or b
	ld b, a
	jr jr_016_6773

;> elif above != 0xFF:                  # no exit there, or the edge of the grid
;>     closed |= 8
jr_016_676f:
	ld a, $08
	or c
	ld c, a

;>@k3 below = wFloorLayout[screen + 4] if screen + 4 < 16 else None    # the screen below
jr_016_6773:
	ld a, d
	add $04
	cp $10
	jr nc, jr_016_679d

	ld hl, wFloorLayout
	add l
;=@k3
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@k4 if below is not None and below != 0xFF and ScreenShapeTable[below].exits & 8:
	cp $ff
	jr z, jr_016_67a1

	add a
	add a
	ld hl, ScreenShapeTable
	add l
;=@k4
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 3, [hl]
	jr z, jr_016_679d

;>     opens |= 4                       # it has an exit up to this screen
	ld a, $04
	or b
	ld b, a
	jr jr_016_67a1

;> elif below != 0xFF:
;>     closed |= 4
jr_016_679d:
	ld a, $04
	or c
	ld c, a

;>@k5 left = wFloorLayout[screen - 1] if screen & 3 else None    # the screen to the left
jr_016_67a1:
	ld a, d
	and $03
	jr z, jr_016_67cb

	ld a, d
	dec a
	ld hl, wFloorLayout
;=@k5
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
	ld a, [hl]
;>@k6 if left is not None and left != 0xFF and ScreenShapeTable[left].exits & 1:
	cp $ff
	jr z, jr_016_67cf

	add a
	add a
	ld hl, ScreenShapeTable
	add l
;=@k6
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 0, [hl]
	jr z, jr_016_67cb

;>     opens |= 2                       # it has an exit right to this screen
	ld a, $02
	or b
	ld b, a
	jr jr_016_67cf

;> elif left != 0xFF:
;>     closed |= 2
jr_016_67cb:
	ld a, $02
	or c
	ld c, a

;>@k7 right = wFloorLayout[screen + 1] if screen & 3 != 3 else None    # the screen to the right
jr_016_67cf:
	ld a, d
	and $03
	cp $03
	jr z, jr_016_67fb

	ld a, d
	inc a
;=@k7
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
	ld h, a
;=@k7
	ld a, [hl]
;>@k8 if right is not None and right != 0xFF and ScreenShapeTable[right].exits & 2:
	cp $ff
	jr z, jr_016_67ff

	add a
	add a
	ld hl, ScreenShapeTable
	add l
;=@k8
	ld l, a
	ld a, $00
	adc h
	ld h, a
	bit 1, [hl]
	jr z, jr_016_67fb

;>     opens |= 1                       # it has an exit left to this screen
	ld a, $01
	or b
	ld b, a
	jr jr_016_67ff

;> elif right != 0xFF:
;>     closed |= 1
jr_016_67fb:
	ld a, $01
	or c
	ld c, a

;> return opens, closed
jr_016_67ff:
	ret


;@ def PickScreenShape(opens: b, closed: c) -> a
;@ path: field/gatefloor/layout
;@ Picks a random screen shape with all exits in opens and none in closed. The fitting entries
;@ of ScreenShapeTable (4 bytes: exits, shape, weight class, unused) are listed in
;@ wTilemapBuffer; weight class 1-4 shares a weight of 20, 40, 60 or 80 among its fitting shapes
;@ (class 0 is never picked). Returns $0F when nothing fits.
;@ test: skip reads table entries as named fields
PickScreenShape::
;> fits = wTilemapBuffer                # (shape, class) pairs, $FF $FF at the end
	ld de, wTilemapBuffer
	ld hl, ScreenShapeTable

;>@fe for entry in ScreenShapeTable:    # 4 bytes each, $FF at the end
jr_016_6806:
	ld a, [hl]
	cp $ff
	jr z, jr_016_6826

;>@k1     if entry.exits & closed == 0 and entry.exits & opens == opens:
	and c
	jr nz, jr_016_681c

;=@k1
	ld a, [hl]
	and b
	cp b
	jr nz, jr_016_681c

;>@k2         fits.append((entry.shape, entry.weight_class))
	push hl
	inc hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
;=@k2
	ld [de], a
	inc de
	pop hl

jr_016_681c:
;=@fe
	ld a, l
	add $04
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@k2
	jr jr_016_6806

;> fits.append((0xFF, 0xFF))
jr_016_6826:
	ld [de], a
	inc de
	ld [de], a
;> in_class = [0] * 5                   # shapes per class, in wNumberBackup[5]
	ld hl, wNumberBackup
	ld bc, $0005
	ld a, $00
	call FillMemory
;> for shape, cls in fits:
;>@g82     in_class[cls] += 1
	ld hl, $c501

jr_016_6837:
	ld a, [hli]
	cp $ff
	jr z, jr_016_684b

	inc hl
	ld de, wNumberBackup
;=@g82
	add e
;=@g82
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	inc a
;=@g82
	ld [de], a
	jr jr_016_6837

;>@g83 weight = [0, 20 // in_class[1], 40 // in_class[2], 60 // in_class[3], 80 // in_class[4]]
jr_016_684b:
	xor a
	ld [wNumberBackup], a
	ld a, [$c0a1]
	ld b, $14
	call Divide8
	ld a, b
;=@g83
	ld [$c0a1], a
	ld a, [$c0a2]
	ld b, $28
	call Divide8
	ld a, b
	ld [$c0a2], a
;=@g83
	ld a, [wLineUpOrder]
	ld b, $3c
	call Divide8
	ld a, b
	ld [wLineUpOrder], a
	ld a, [$c0a4]
;=@g83
	ld b, $50
	call Divide8
	ld a, b
	ld [$c0a4], a
;> total = 0
;> for fit in fits:                     # the class byte becomes the running total
	ld hl, $c501
	ld b, $00

;>@k4     total += weight[fit.cls]; fit.cls = total
jr_016_6884:
	ld a, [hl]
	cp $ff
	jr z, jr_016_689a

	ld de, wNumberBackup
	add e
	ld e, a
;=@k4
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	add b
	ld b, a
;=@k4
	ld [hl], a
	inc hl
	inc hl
	jr jr_016_6884

;>@g86 roll = Random() % total if total else Random()
jr_016_689a:
	push bc
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
;=@g86
	pop af
	or a
	jr z, jr_016_68ad

	call Divide16

;>@ff for fit in fits:
jr_016_68ad:
	ld b, a
	ld hl, $c501

;>     if fit.cls == 0xFF:
;>         return 0x0F
jr_016_68b1:
	ld a, [hl]
	cp $ff
	jr nz, jr_016_68ba

	ld a, $0f
	jr jr_016_68c5

;>     if fit.cls >= roll:
;>         return fit.shape
jr_016_68ba:
	cp b
	jr c, jr_016_68c1

	dec hl
	ld a, [hl]
	jr jr_016_68c5

jr_016_68c1:
;=@ff
	inc hl
	inc hl
	jr jr_016_68b1

jr_016_68c5:
	ret


;@ def IsStairsSpot() -> z
;@ path: field/gatefloor/spots
;@ Sets z when the test spot (wMapScreen, hTestX, hTestY) is where the stairs were placed.
;@ test: skip returns the z flag
IsStairsSpot::
;> if wMapScreen != wStairsScreen:
;>     return nz
	ld hl, wStairsScreen
	ld a, [wMapScreen]
	cp [hl]
	ret nz

;> if hTestX != stairs.x:
;>@k1     return nz
	ld hl, hTestX
	ld a, [$c0a5]
	cp [hl]
	ret nz

;=@k1
	inc hl
	ld a, [$c0a6]
	cp [hl]
	ret nz

;>@k2 return z if hTestY == stairs.y else nz
	ld hl, hTestY
	ld a, [$c0a7]
	cp [hl]
	ret nz

;=@k2
	inc hl
	ld a, [$c0a8]
	cp [hl]
	ret


;@ def IsArrivalSpot() -> z
;@ path: field/gatefloor/spots
;@ Sets z when the test spot (wMapScreen, hTestX, hTestY) is where Terry arrives.
;@ test: skip returns the z flag
IsArrivalSpot::
;> if wMapScreen != arrival.screen:
;>     return nz
	ld hl, wNumberBackup
	ld a, [wMapScreen]
	cp [hl]
	ret nz

;> if hTestX != arrival.x:
;>@k1     return nz
	ld hl, hTestX
	ld a, [$c0a1]
	cp [hl]
	ret nz

;=@k1
	inc hl
	ld a, [$c0a2]
	cp [hl]
	ret nz

;>@k2 return z if hTestY == arrival.y else nz
	ld hl, hTestY
	ld a, [wLineUpOrder]
	cp [hl]
	ret nz

;=@k2
	inc hl
	ld a, [$c0a4]
	cp [hl]
	ret


;@ def IsObjectSpot() -> z
;@ path: field/gatefloor/spots
;@ Sets z when one of the objects placed so far (wFloorObjects, $FF at the end) is at the test
;@ spot (see IsObjectAt).
;@ test: skip returns the z flag
IsObjectSpot::
;>@fo for obj in wFloorObjects:         # 4 bytes each
	ld hl, wFloorObjects

;>     if obj[0] == 0xFF:
;>         return nz
jr_016_6911:
	ld a, [hl]
	cp $ff
	jr nz, jr_016_6918

	or a
	ret


;>     if IsObjectAt(obj):
;>         return z
jr_016_6918:
	push hl
	call IsObjectAt
	pop hl
	ret z

;=@fo
	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_016_6911

;@ def IsObjectAt(obj: hl) -> z
;@ path: field/gatefloor/spots
;@ Sets z when the object entry at obj lies on screen wMapScreen in the row of hTestY. The floor
;@ is 4 x 4 screens of 10 x 8 tiles; the entry holds the floor tile column and row. Only the row
;@ is compared, not the column.
;@ test: skip returns the z flag
IsObjectAt::
;>@g87 screen = obj[2] // 10                # screen column
	inc hl
	inc hl
	ld b, [hl]
	inc hl
	push hl
	ld a, $0a
;=@g87
	call Divide8
	ld a, b
	ldh [$ffda], a
;>@g88 screen += (obj[3] // 8) * 4           # screen row
	pop hl
	ld a, [hl]
	and $f8
	srl a
	ld b, a
	ldh a, [$ffda]
;=@g88
	add b
	ldh [$ffda], a
;> y = (obj[3] & 7) * 16 + 8            # pixel row in the screen
	ld a, [hl]
	and $07
	swap a
	or $08
	ldh [hDivisorHigh], a
;> if screen != wMapScreen:
;>     return nz
	ld hl, $ffda
	ld a, [wMapScreen]
	cp [hl]
	ret nz

;> return z if y == hTestY else nz
	ld hl, hTestY
	ldh a, [hDivisorHigh]
	cp [hl]
	ret


;@ def CheckObjectSpace() -> z
;@ path: field/gatefloor/spots
;@ Checks that an object at the spot saved in $C0AA-$C0AD does not cut off a way: object kinds
;@ with $10 added test the 3 x 3 tiles around the spot (wSpotAround) and run the shared checks of
;@ CheckStairsSpace. Returns nz when the spot is fine, z when it would block; kinds below $10
;@ always fit.
;@ test: skip calls routines in other banks
CheckObjectSpace::
;> if wFloorObjKind & 0xF0 == 0:
;>     return nz
	ld a, [wFloorObjKind]
	and $f0
	jp z, Jump_016_6d93

;>@sp for i, (dx, dy) in enumerate([(-16, -16), (0, -16), (16, -16), (-16, 0), (0, 0), (16, 0), (-16, 16), (0, 16), (16, 16)]):
;>@g89     hTestX = spot.x + dx
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $f0
;=@g89
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g89
	ld a, h
	ldh [$ffa6], a
;>@ty     hTestY = spot.y + dy
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
	ld a, l
	add $f0
;=@ty
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
;=@ty
	ld a, h
	ldh [$ffa8], a
;>@g93     wSpotAround[i] = IsSpotFree()        # 0 free, 1 blocked
	call IsSpotFree
	ld a, b
	ld [wSpotAround], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b1], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $10
;=@g93
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b2], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $f0
;=@g93
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b3], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b4], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $10
;=@g93
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b5], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $f0
;=@g93
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b6], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b7], a
;=@sp
	ld a, [$c0aa]
	ld l, a
	ld a, [$c0ab]
	ld h, a
	ld a, l
	add $10
;=@g93
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g93
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0ac]
	ld l, a
	ld a, [$c0ad]
	ld h, a
;=@g93
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@g93
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g93
	ld [$c0b8], a
;> return CheckSpotAround()              # the checks at the end of CheckStairsSpace
	jp Jump_016_6c96


;@ def CheckStairsSpace() -> z
;@ path: field/gatefloor/spots
;@ Checks that the stairs at the spot saved in $C0A5-$C0A8 do not cut off a way. The 3 x 3 tiles
;@ around it are tested (wSpotAround: 0 1 2 / 3 4 5 / 6 7 8, 1 = blocked): a blocked side next
;@ to blocked tiles on the opposite side, or a blocked corner next to a blocked tile it does not
;@ touch through a free one, would split the floor. Returns nz when the spot is fine, z if not.
;@ test: skip calls routines in other banks
CheckStairsSpace::
;>@sp for i, (dx, dy) in enumerate([(-16, -16), (0, -16), (16, -16), (-16, 0), (0, 0), (16, 0), (-16, 16), (0, 16), (16, 16)]):
;>@g127     hTestX = stairs.x + dx
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $f0
;=@g127
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g127
	ld a, h
	ldh [$ffa6], a
;>@ty     hTestY = stairs.y + dy
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
	ld a, l
	add $f0
;=@ty
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestY], a
;=@ty
	ld a, h
	ldh [$ffa8], a
;>@g131     wSpotAround[i] = IsSpotFree()        # 0 free, 1 blocked
	call IsSpotFree
	ld a, b
	ld [wSpotAround], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b1], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $10
;=@g131
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	add $f0
	ld l, a
	ld a, h
	adc $ff
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b2], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $f0
;=@g131
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b3], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b4], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $10
;=@g131
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b5], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $f0
;=@g131
	ld l, a
	ld a, h
	adc $ff
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b6], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b7], a
;=@sp
	ld a, [$c0a5]
	ld l, a
	ld a, [$c0a6]
	ld h, a
	ld a, l
	add $10
;=@g131
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ld a, l
	ldh [hTestX], a
;=@g131
	ld a, h
	ldh [$ffa6], a
	ld a, [$c0a7]
	ld l, a
	ld a, [$c0a8]
	ld h, a
;=@g131
	ld a, l
	add $10
	ld l, a
	ld a, h
	adc $00
	ld h, a
;=@g131
	ld a, l
	ldh [hTestY], a
	ld a, h
	ldh [$ffa8], a
	call IsSpotFree
	ld a, b
;=@g131
	ld [$c0b8], a

;> def CheckSpotAround():               # also used by CheckObjectSpace
;>@fail     if s[3] and (s[2] or s[5] or s[8]): return z    # s = wSpotAround
Jump_016_6c96:
	ld a, [$c0b3]
	or a
	jr z, jr_016_6cb1

	ld a, [$c0b2]
	or a
	jp nz, Jump_016_6d97

;=@fail
	ld a, [$c0b5]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b8]
	or a
	jp nz, Jump_016_6d97

;>@g166     if s[7] and (s[0] or s[1] or s[2]): return z
jr_016_6cb1:
	ld a, [$c0b7]
	or a
	jr z, jr_016_6ccc

	ld a, [wSpotAround]
	or a
	jp nz, Jump_016_6d97

;=@g166
	ld a, [$c0b1]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b2]
	or a
	jp nz, Jump_016_6d97

;>@g167     if s[1] and (s[6] or s[7] or s[8]): return z
jr_016_6ccc:
	ld a, [$c0b1]
	or a
	jr z, jr_016_6ce7

	ld a, [$c0b6]
	or a
	jp nz, Jump_016_6d97

;=@g167
	ld a, [$c0b7]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b8]
	or a
	jp nz, Jump_016_6d97

;>@g168     if s[5] and (s[0] or s[3] or s[6]): return z
jr_016_6ce7:
	ld a, [$c0b5]
	or a
	jr z, jr_016_6d02

	ld a, [wSpotAround]
	or a
	jp nz, Jump_016_6d97

;=@g168
	ld a, [$c0b3]
	or a
	jp nz, Jump_016_6d97

	ld a, [$c0b6]
	or a
	jp nz, Jump_016_6d97

;>@g169     if s[0] and ((not s[1] and s[2]) or (not s[3] and s[6]) or s[8]): return z
jr_016_6d02:
	ld a, [wSpotAround]
	or a
	jr z, jr_016_6d27

	ld a, [$c0b1]
	or a
	jr nz, jr_016_6d15

;=@g169
	ld a, [$c0b2]
	or a
	jp nz, Jump_016_6d97

jr_016_6d15:
	ld a, [$c0b3]
	or a
	jr nz, jr_016_6d21

;=@g169
	ld a, [$c0b6]
	or a
	jr nz, jr_016_6d97

jr_016_6d21:
	ld a, [$c0b8]
	or a
	jr nz, jr_016_6d97

;>@g171     if s[2] and ((not s[1] and s[0]) or (not s[5] and s[8]) or s[6]): return z
jr_016_6d27:
	ld a, [$c0b2]
	or a
	jr z, jr_016_6d4b

	ld a, [$c0b1]
	or a
	jr nz, jr_016_6d39

;=@g171
	ld a, [wSpotAround]
	or a
	jr nz, jr_016_6d97

jr_016_6d39:
	ld a, [$c0b5]
	or a
	jr nz, jr_016_6d45

;=@g171
	ld a, [$c0b8]
	or a
	jr nz, jr_016_6d97

jr_016_6d45:
	ld a, [$c0b6]
	or a
	jr nz, jr_016_6d97

;>@g173     if s[6] and ((not s[3] and s[0]) or (not s[7] and s[8]) or s[2]): return z
jr_016_6d4b:
	ld a, [$c0b6]
	or a
	jr z, jr_016_6d6f

	ld a, [$c0b3]
	or a
	jr nz, jr_016_6d5d

;=@g173
	ld a, [wSpotAround]
	or a
	jr nz, jr_016_6d97

jr_016_6d5d:
	ld a, [$c0b7]
	or a
	jr nz, jr_016_6d69

;=@g173
	ld a, [$c0b8]
	or a
	jr nz, jr_016_6d97

jr_016_6d69:
	ld a, [$c0b2]
	or a
	jr nz, jr_016_6d97

;>@g175     if s[8] and ((not s[5] and s[2]) or (not s[7] and s[6]) or s[0]): return z
jr_016_6d6f:
	ld a, [$c0b8]
	or a
	jr z, jr_016_6d93

	ld a, [$c0b5]
	or a
	jr nz, jr_016_6d81

;=@g175
	ld a, [$c0b2]
	or a
	jr nz, jr_016_6d97

jr_016_6d81:
	ld a, [$c0b7]
	or a
	jr nz, jr_016_6d8d

;=@g175
	ld a, [$c0b6]
	or a
	jr nz, jr_016_6d97

jr_016_6d8d:
	ld a, [wSpotAround]
	or a
	jr nz, jr_016_6d97

;>     return nz                            # every way stays open
Jump_016_6d93:
jr_016_6d93:
	ld a, $01
	or a
	ret


Jump_016_6d97:
jr_016_6d97:
;=@fail
	xor a
	ret


;@ def IsSpotFree() -> b
;@ path: field/gatefloor/spots
;@ Tests the tile at hTestX, hTestY of the loaded screen: b = 0 when it is walkable floor
;@ (collision kind $0C-$0E), else 1.
;@ test: skip calls routines in other banks
IsSpotFree::
;> GetCollisionAt()
	call GetCollisionAt
;> if hTestTile >> 2 in (0x0C, 0x0D, 0x0E):
;>@g177     return 0
	ld b, $00
	ldh a, [hTestTile]
	srl a
	srl a
	cp $0c
	ret z

;=@g177
	cp $0d
	ret z

	cp $0e
	ret z

;> return 1
	ld b, $01
	ret


;@ def RollFloorItems()
;@ path: field/gatefloor/items
;@ Rolls the eight items of the item room (special floor 0) into the 8 bytes from wArenaWins on.
;@ test: skip calls Random
RollFloorItems::
;> for i in range(8):
;>@g178     wArenaWins[i] = RollFloorItem()
	ld hl, wArenaWins
	ld b, $08

jr_016_6db5:
	push bc
	push hl
	call RollFloorItem
	pop hl
;=@g178
	pop bc
	ld [hli], a
	dec b
	jr nz, jr_016_6db5

	ret


;@ def RollFloorItem() -> a
;@ path: field/gatefloor/items
;@ Rolls a random item for the gate world's class from its FloorItemTables list.
;@ test: skip calls Random
RollFloorItem::
;>@g179 return PickByPercent(FloorItemTables + wGateClass * 48)
	ld a, [wGateClass]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
;=@g179
	add hl, hl
	ld e, l
	ld d, h
	add hl, hl
	add hl, de
	ld a, l
;=@g179
	add $36
	ld l, a
	ld a, h
	adc $74
	ld h, a
	call PickByPercent
;=@g179
	ret


;@ def RollSpecialItem()
;@ path: field/gatefloor/items
;@ Puts one random item of SpecialItemTable into one of the first four of the 8 bytes from
;@ wArenaWins on.
;@ test: skip calls Random
RollSpecialItem::
;>@g182 slot = Random() & 3
	call Random
	ld a, [wRandomHigh]
	and $03
	ld hl, wArenaWins
	add l
	ld l, a
;=@g182
	ld a, $00
	adc h
	ld h, a
;>@g183 wArenaWins[slot] = SpecialItemTable[Random() & 15]
	ld de, SpecialItemTable
	push de
	push hl
	call Random
	ld a, [wRandomHigh]
	and $0f
;=@g183
	pop hl
	pop de
	add e
	ld e, a
	ld a, $00
	adc d
;=@g183
	ld d, a
	ld a, [de]
	ld [hl], a
	ret


;@ path: field/gatefloor/items
;@ The 16 items RollSpecialItem picks from (item ids; $1A-$1C and $25 twice as likely).
SpecialItemTable::
	db $03, $04, $06, $0c, $15, $17, $18, $19, $1a, $1b, $1c, $25, $1a, $1b, $1c, $25

;@ def ResetEncounterCounter()
;@ path: battle/encounter
;@ Sets a new random step counter for the next battle on a gate floor: a roll of 0-100 picks
;@ the first EncounterCounterTable entry whose threshold is at least the roll.
;@ test: skip calls Random
ResetEncounterCounter::
;>@g185 roll = Random() % 101
	call Random
	ld a, [wRandomHigh]
	ld l, a
	ld a, [wRandomLow]
	ld h, a
	ld a, $65
;=@g185
	call Divide16
;> entry = EncounterCounterTable
	ld hl, EncounterCounterTable

;> while roll > entry.threshold:        # 4 bytes each
;>@g186     entry += 4
jr_016_6e27:
	cp [hl]
	jr z, jr_016_6e32

	jr c, jr_016_6e32

	inc hl
	inc hl
	inc hl
;=@g186
	inc hl
	jr jr_016_6e27

;>@g187 wEncounterCounter = entry.counter
jr_016_6e32:
	inc hl
	inc hl
	ld a, [hli]
	ld [wEncounterCounter], a
	ld a, [hli]
	ld [$ca3a], a
;=@g187
	ret


;@ path: battle/encounter
;@ Step counters for the next battle: 4 bytes per entry (u16 threshold for a roll of 0-100,
;@ u16 counter), thresholds 2, 4, ... 98, then $FF. The counter grows from 1100 by 100 per
;@ entry up to 6000.
EncounterCounterTable::
	db $02, $00, $4c, $04, $04, $00, $b0, $04, $06, $00, $14, $05, $08, $00, $78, $05
	db $0a, $00, $dc, $05, $0c, $00, $40, $06, $0e, $00, $a4, $06, $10, $00, $08, $07
	db $12, $00, $6c, $07, $14, $00, $d0, $07, $16, $00, $34, $08, $18, $00, $98, $08
	db $1a, $00, $fc, $08, $1c, $00, $60, $09, $1e, $00, $c4, $09, $20, $00, $28, $0a
	db $22, $00, $8c, $0a, $24, $00, $f0, $0a, $26, $00, $54, $0b, $28, $00, $b8, $0b
	db $2a, $00, $1c, $0c, $2c, $00, $80, $0c, $2e, $00, $e4, $0c, $30, $00, $48, $0d
	db $32, $00, $ac, $0d, $34, $00, $10, $0e, $36, $00, $74, $0e, $38, $00, $d8, $0e
	db $3a, $00, $3c, $0f, $3c, $00, $a0, $0f, $3e, $00, $04, $10, $40, $00, $68, $10
	db $42, $00, $cc, $10, $44, $00, $30, $11, $46, $00, $94, $11, $48, $00, $f8, $11
	db $4a, $00, $5c, $12, $4c, $00, $c0, $12, $4e, $00, $24, $13, $50, $00, $88, $13
	db $52, $00, $ec, $13, $54, $00, $50, $14, $56, $00, $b4, $14, $58, $00, $18, $15
	db $5a, $00, $7c, $15, $5c, $00, $e0, $15, $5e, $00, $44, $16, $60, $00, $a8, $16
	db $62, $00, $0c, $17, $ff, $00, $70, $17

;@ def CountEncounterSteps()
;@ path: battle/encounter
;@ Counts a step towards the next random battle. Nothing counts while a battle, a fade or a
;@ scripted event is going on. Outside the gate floors a step costs 100 (80 in rooms $54-$56);
;@ on a gate floor it costs the EncounterRateTable value of the floor map for the tile kind
;@ stepped on (none for other tiles). The cost is scaled by the floor style
;@ (EncounterStyleFactor / 64). When wEncounterCounter runs out, a battle starts.
;@ test: skip calls routines in other banks
CountEncounterSteps::
;> if wFieldFlags & 0x64 or wFadeState or wWorldFlags & 2:
;>@g188     return
	ld a, [wFieldFlags]
	bit 2, a
	ret nz

	bit 5, a
	ret nz

	bit 6, a
;=@g188
	ret nz

	ld a, [wFadeState]
	or a
	ret nz

	ld a, [wWorldFlags]
	bit 1, a
;=@g188
	ret nz

;> if not wOnGateFloor:
	ld a, [wOnGateFloor]
	or a
	jr nz, jr_016_6f39

;>@g190     cost = 80 if wMapId in (0x54, 0x55, 0x56) else 100
	ld bc, $0050
	ld a, [wMapId]
	cp $54
	jr z, jr_016_6f62

	cp $55
	jr z, jr_016_6f62

;=@g190
	cp $56
	jr z, jr_016_6f62

	ld bc, $0064
	jr jr_016_6f62

;> else:
;>@g191     rates = EncounterRateTable + wMapId * 8
jr_016_6f39:
	ld hl, EncounterRateTable
	ld a, [wMapId]
	add a
	add a
	add a
	add l
;=@g191
	ld l, a
	ld a, $00
	adc h
	ld h, a
;>     kind = hTestTile >> 2                # the tile stepped on
	ldh a, [hTestTile]
	srl a
	srl a
;>     if kind not in (0x0C, 0x0D, 0x0E):
;>@g192         return
	cp $0c
	jr z, jr_016_6f5f

	inc hl
	inc hl
	cp $0d
	jr z, jr_016_6f5f

;=@g192
	inc hl
	inc hl
	cp $0e
	jr z, jr_016_6f5f

	ret


;>     cost = rates[kind - 0x0C]            # u16
jr_016_6f5f:
	ld a, [hli]
	ld b, [hl]
	ld c, a

;> SelectFloorTable()
jr_016_6f62:
	push bc
	ld hl, far_SelectFloorTable
	rst $10
;>@g193 cost = cost * EncounterStyleFactor[wFloorStyle] // 64
	ld hl, EncounterStyleFactor
	ld a, [wFloorStyle]
	add l
	ld l, a
	ld a, $00
	adc h
;=@g193
	ld h, a
	ld a, [hl]
	pop bc
	call Multiply24
	ld a, $40
	call Divide24
;>@g194 left = wEncounterCounter - cost
	ld e, l
	ld d, h
	ld a, [wEncounterCounter]
	ld l, a
	ld a, [$ca3a]
	ld h, a
;=@g194
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
;> if left < 0:                         # a battle
	jr nc, jr_016_6fa2

;>     RollEncounterGroup()
	ld hl, far_RollEncounterGroup
	rst $10
;>     wFieldFlags |= 0x40
	ld hl, wFieldFlags
	set 6, [hl]
;>     wMenuStep = 0
	xor a
	ld [wMenuStep], a
;>     wBattleKind = 0
	ld a, $00
	ld [wBattleKind], a
	ret


;> else:
;>     wEncounterCounter = left
jr_016_6fa2:
	ld a, l
	ld [wEncounterCounter], a
	ld a, h
	ld [$ca3a], a
	ret


;@ path: battle/encounter
;@ Step costs on the 16 gate floor maps: 8 bytes per map, the u16 costs for tile kinds $0C,
;@ $0D and $0E, then two unused bytes. Most floors cost 138 per step (a few 140 or 150); the
;@ last maps 100, 180 or 250.
EncounterRateTable::
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $8a, $00, $8a, $00, $8a, $00, $00, $00
	db $8a, $00, $96, $00, $8a, $00, $00, $00, $8a, $00, $8a, $00, $8c, $00, $00, $00
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $8a, $00, $8a, $00, $8a, $00, $00, $00
	db $8a, $00, $8a, $00, $8c, $00, $00, $00, $8a, $00, $8a, $00, $8a, $00, $00, $00
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $96, $00, $96, $00, $96, $00, $00, $00
	db $8a, $00, $8a, $00, $8a, $00, $00, $00, $64, $00, $b4, $00, $fa, $00, $00, $00
	db $64, $00, $b4, $00, $b4, $00, $00, $00, $64, $00, $b4, $00, $fa, $00, $00, $00
	db $64, $00, $b4, $00, $b4, $00, $00, $00, $96, $00, $b4, $00, $96, $00, $00, $00
;@ path: battle/encounter
;@ Step cost factor per floor style (wFloorStyle), in 64ths.
EncounterStyleFactor::
	db $10, $15, $20, $40, $50, $60, $70, $80

;@ def GetFloorScreenMap() -> de
;@ path: field/gatefloor/layout
;@ Returns the map reference (Decompress entry in e, group in d) for screen wMapScreen of the
;@ floor: wFloorLayout's byte (shape * 16 + variant) indexes ScreenMapRefs, or
;@ PresetScreenMapRefs on a preset floor.
;@ test: skip reads the map reference tables by name
GetFloorScreenMap::
;> refs = PresetScreenMapRefs if wFloorKind == 2 else ScreenMapRefs
	ld de, ScreenMapRefs
	ld a, [wFloorKind]
	cp $02
	jr nz, jr_016_7040

	ld de, PresetScreenMapRefs

;>@g195 return refs[wFloorLayout[wMapScreen]]    # 2 bytes each
jr_016_7040:
	ld a, [wMapScreen]
	ld hl, wFloorLayout
	add l
	ld l, a
	ld a, $00
	adc h
;=@g195
	ld h, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	add hl, de
	ld e, [hl]
;=@g195
	inc hl
	ld d, [hl]
	ret


;@ path: field/gatefloor/layout
;@ The 16 screen shapes of the gate floors, 4 bytes each: exits (8 up, 4 down, 2 left,
;@ 1 right), the shape's own number, its weight class (PickScreenShape) and an unused byte;
;@ $FF ends the list. Shape 0 opens on all four sides, shape 15 has no exits.
ScreenShapeTable::
	db $0f, $00, $04, $00, $07, $01, $03, $00, $0b, $02, $03, $00, $0d, $03, $03, $00
	db $0e, $04, $03, $00, $03, $05, $02, $00, $05, $06, $02, $00, $06, $07, $02, $00
	db $09, $08, $02, $00, $0a, $09, $02, $00, $0c, $0a, $02, $00, $08, $0b, $01, $00
	db $04, $0c, $01, $00, $02, $0d, $01, $00, $01, $0e, $01, $00, $00, $0f, $00, $00
	db $ff

;@ path: field/gatefloor/layout
;@ The order in which MakeGateFloor fills the 16 screens of the 4 x 4 grid: the middle four
;@ first, then around them.
FloorFillOrder::
	db $05, $06, $0a, $09, $08, $04, $00, $01, $02, $03, $07, $0b, $0f, $0e, $0d
	db $0c

;@ path: field/gatefloor
;@ The gate worlds, 8 bytes each (indexed by wGateWorld, the map of the gate): floor set
;@ (FloorMapTables), special floor set (SpecialFloorChances), class (items, objects,
;@ characters), number of floors, boss map, boss room arrival tile x and y, loot.
GateWorldTable::
	db $00, $00, $00, $05, $30, $07, $02, $01, $01, $01, $01, $05, $31, $01, $06
	db $01, $01, $01, $02, $06, $32, $05, $01, $01, $02, $01, $02, $05, $33, $04, $06
	db $01, $02, $02, $03, $06, $34, $00, $07, $01, $03, $02, $03, $09, $35, $01, $06
	db $01, $03, $02, $04, $08, $36, $05, $01, $02, $03, $03, $04, $09, $37, $05, $07
	db $02, $04, $03, $05, $0c, $38, $08, $03, $02, $04, $04, $05, $0b, $39, $02, $01
	db $02, $04, $04, $05, $0b, $3c, $02, $06, $02, $04, $04, $06, $0c, $10, $08, $05
	db $02, $05, $06, $06, $0e, $3b, $04, $01, $02, $05, $06, $06, $0f, $3a, $01, $07
	db $02, $05, $06, $07, $10, $3d, $04, $07, $02, $06, $07, $07, $12, $3e, $04, $01
	db $03, $07, $07, $08, $14, $3f, $06, $03, $03, $07, $05, $08, $13, $40, $04, $06
	db $03, $08, $08, $09, $17, $42, $04, $06, $03, $08, $09, $09, $19, $43, $05, $05
	db $03, $08, $05, $09, $19, $44, $00, $03, $03, $09, $0a, $0a, $1d, $45, $04, $07
	db $03, $0a, $0b, $0b, $1e, $46, $05, $06, $03, $0a, $0b, $0b, $1d, $47, $05, $06
	db $03, $0a, $0b, $0b, $1b, $48, $04, $07, $03, $0b, $0c, $0c, $1e, $49, $04, $07
	db $03, $0b, $0c, $0c, $1e, $4a, $09, $07, $03, $0b, $0d, $0d, $1e, $4b, $04, $07
	db $03, $0c, $0d, $0d, $1e, $4c, $05, $05, $03, $0d, $0e, $0e, $1b, $4d, $05, $07
	db $03, $0e, $0e, $0e, $1e, $4e, $08, $0c, $03, $0f, $0f, $0f, $63, $4f, $05, $06
	db $03

;@ path: field/gatefloor
;@ The floor map choices, 16 bytes per floor set: cumulative percent chances (PickByPercent) of
;@ the 16 gate floor maps.
FloorMapTables::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $28, $00, $64, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $28, $00, $00, $00, $64, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $14, $00, $1e, $28, $64, $00
	db $00, $14, $28, $3c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $00, $00, $1e, $3c, $00, $00, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $1e, $3c, $00, $00, $00, $00, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $00, $00, $00, $00, $1e, $3c, $00, $00, $00, $00, $50, $64
	db $00, $00, $00, $00, $00, $00, $00, $14, $00, $28, $00, $00, $00, $3c, $00, $64
	db $00, $0a, $14, $1e, $23, $28, $00, $32, $00, $3c, $46, $00, $00, $50, $00, $64
	db $00, $00, $00, $00, $0a, $00, $00, $14, $00, $28, $00, $00, $00, $3c, $00, $50
	db $64, $00, $00, $00, $0a, $00, $00, $14, $00, $28, $00, $3c, $00, $50, $00, $64
	db $00, $0a, $00, $00, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $00, $0a, $00, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $00, $00, $0a, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64, $05, $0a, $00, $14, $1e, $00, $28, $00, $32, $3c, $46, $00, $50, $00, $5a
	db $64

;@ path: field/gatefloor
;@ The special floor choices, 8 bytes per special floor set: cumulative percent chances
;@ (PickByPercent) of the eight special floors of SpecialFloorTable.
SpecialFloorChances::
	db $14, $00, $00, $46, $64, $00, $00, $00, $00, $00, $00, $32, $64, $00, $00
	db $00, $28, $00, $00, $46, $64, $00, $00, $00, $00, $00, $00, $1e, $3c, $00, $64
	db $00, $00, $00, $28, $46, $64, $00, $00, $00, $00, $00, $00, $2d, $4b, $64, $00
	db $00, $00, $00, $00, $1e, $3c, $00, $00, $64, $0f, $14, $1e, $3c, $5a, $64, $00
	db $00, $0f, $14, $00, $32, $50, $00, $5a, $64, $1e, $00, $2d, $3c, $4b, $5a, $5f
	db $64, $0a, $1e, $28, $37, $46, $50, $5a, $64, $05, $19, $28, $2d, $32, $3c, $50
	db $64, $05, $1e, $28, $32, $37, $46, $50, $64, $05, $23, $32, $3c, $41, $50, $5a
	db $64, $05, $23, $32, $46, $4b, $5a, $5f, $64, $05, $19, $23, $2d, $37, $50, $5a
	db $64

;@ path: field/gatefloor/items
;@ The objects of each class (wGateClass), 16 bytes: cumulative percent chances of the object
;@ kinds 0-8, then the base count, the random extra count and the percent chance of the $10
;@ variant (see MakeGateFloor), and unused bytes.
FloorObjectTable::
	db $64, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02, $00, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $64, $00, $04, $02, $00, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $64, $00, $02, $04, $0a, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5f, $64, $02, $04, $0a, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5f, $64, $02, $04, $0a, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $06, $1e, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $06, $1e, $00, $00, $00
	db $00, $4b, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $06, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $50, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $04, $1e, $00, $00, $00
	db $00, $46, $00, $00, $00, $00, $00, $00, $5a, $64, $00, $02, $1e, $00, $00, $00
	db $00

;@ path: field/gatefloor/items
;@ For each object kind: 1 when it holds an item (a chest), otherwise the value stored instead.
ObjectIsChestTable::
	db $01, $01, $01, $01, $01, $01, $01, $00, $ff, $01, $01, $01, $01, $01, $01
	db $01

;@ path: field/gatefloor/items
;@ The items found in chests, 48 bytes per class: cumulative percent chances (PickByPercent)
;@ over the item ids 0-47.
FloorItemTables::
	db $00, $5d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $62, $63
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $33, $00
	db $34, $35, $00, $00, $53, $58, $5b, $00, $00, $00, $00, $00, $00, $00, $60, $61
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $33
	db $00, $00, $34, $35, $53, $58, $5b, $00, $00, $00, $00, $00, $00, $00, $60, $61
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $24, $2a, $00, $00, $00, $00, $2c, $2e, $30, $32, $34, $00, $35, $00
	db $36, $37, $00, $00, $4f, $54, $57, $00, $00, $00, $5a, $5b, $00, $00, $60, $61
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $16, $20, $00, $00, $25, $00, $2a, $2c, $2e, $30, $32, $00, $00, $33
	db $00, $00, $34, $35, $49, $4e, $51, $52, $53, $00, $56, $58, $59, $00, $5e, $5f
	db $00, $00, $00, $00, $00, $00, $00, $00, $61, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $11, $25, $00, $00, $29, $2a, $2f, $31, $33, $35, $37, $38, $39, $00
	db $3a, $3b, $00, $00, $40, $4f, $52, $53, $54, $55, $00, $57, $59, $00, $5d, $5e
	db $00, $00, $00, $00, $00, $00, $00, $00, $61, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $02, $1b, $00, $20, $23, $24, $29, $2b, $2d, $2f, $31, $32, $00, $33
	db $00, $00, $34, $35, $00, $49, $53, $54, $55, $56, $00, $58, $00, $59, $5c, $5d
	db $00, $00, $00, $00, $00, $00, $00, $00, $61, $00, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $1f, $00, $24, $26, $28, $2a, $2c, $2e, $30, $32, $33, $34, $00
	db $35, $00, $00, $00, $00, $44, $53, $54, $55, $56, $00, $58, $00, $59, $5b, $5c
	db $00, $00, $00, $00, $00, $00, $00, $00, $60, $61, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $1b, $00, $20, $21, $24, $26, $28, $2a, $2c, $2e, $2f, $30, $00
	db $00, $31, $32, $33, $00, $3d, $51, $53, $55, $56, $00, $58, $00, $59, $5b, $5c
	db $00, $00, $00, $00, $00, $00, $00, $00, $60, $61, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $12, $00, $17, $00, $1b, $1d, $1f, $21, $23, $25, $26, $27, $28
	db $00, $29, $2a, $2b, $00, $30, $49, $4b, $4e, $4f, $00, $50, $00, $52, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $12, $00, $17, $00, $1b, $1d, $1f, $21, $23, $25, $26, $27, $00
	db $28, $29, $2a, $2b, $00, $00, $49, $4b, $4e, $4f, $00, $50, $00, $52, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1b, $1e, $20, $22, $24, $25, $00, $26
	db $28, $00, $29, $00, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1c, $1e, $20, $22, $24, $25, $26, $00
	db $00, $27, $00, $29, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1c, $1e, $20, $22, $24, $25, $00, $27
	db $28, $00, $29, $00, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $11, $00, $16, $00, $1a, $1c, $1e, $20, $22, $24, $25, $26, $00
	db $00, $28, $00, $29, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00, $00, $00, $0f, $00, $14, $00, $18, $1a, $1c, $1e, $20, $22, $23, $24, $25
	db $26, $27, $28, $29, $00, $00, $45, $47, $4c, $00, $00, $4d, $00, $50, $54, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $5d, $5f, $00, $64, $00, $00, $00, $00
	db $00

;@ path: field/gatefloor/layout
;@ The 21 preset floor layouts, 16 bytes each: the wFloorLayout bytes (shape * 16 + variant,
;@ $F0 = no screen) of a 4 x 4 grid.
PresetLayouts::
	db $60, $10, $10, $70, $30, $00, $00, $40, $30, $00, $00, $40, $80, $20, $20
	db $90, $60, $70, $60, $70, $30, $40, $30, $40, $30, $40, $30, $40, $80, $22, $23
	db $90, $60, $70, $60, $70, $80, $0c, $0d, $90, $60, $0b, $0a, $70, $80, $90, $80
	db $90, $60, $70, $60, $70, $30, $40, $33, $90, $30, $40, $31, $70, $80, $22, $23
	db $90, $60, $70, $60, $70, $30, $40, $80, $42, $30, $07, $10, $41, $80, $20, $20
	db $90, $61, $72, $61, $72, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $b0, $82, $92
	db $b0, $64, $50, $50, $74, $a0, $f0, $f0, $a0, $a0, $f0, $f0, $a0, $84, $50, $50
	db $94, $64, $50, $12, $74, $a0, $60, $41, $a0, $a0, $80, $90, $a0, $84, $50, $50
	db $94, $64, $16, $16, $74, $36, $01, $01, $46, $36, $01, $01, $46, $84, $26, $26
	db $94, $64, $50, $50, $74, $84, $50, $50, $45, $64, $50, $50, $44, $84, $50, $50
	db $94, $64, $14, $15, $74, $35, $94, $84, $45, $34, $74, $64, $44, $84, $24, $25
	db $94, $64, $16, $16, $74, $35, $26, $26, $94, $34, $16, $16, $74, $84, $26, $26
	db $94, $64, $12, $50, $74, $a0, $34, $74, $a0, $a0, $84, $94, $a0, $84, $50, $50
	db $94, $60, $10, $70, $c0, $30, $00, $40, $a0, $80, $20, $42, $a0, $e0, $50, $21
	db $94, $60, $70, $e0, $74, $30, $07, $11, $43, $30, $08, $90, $a0, $80, $90, $e0
	db $94, $e0, $71, $c0, $c0, $64, $21, $45, $a0, $a0, $64, $21, $45, $b0, $b0, $e0
	db $91, $f0, $64, $74, $f0, $64, $94, $84, $74, $84, $74, $64, $94, $f0, $84, $94
	db $f0, $64, $16, $16, $74, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $84, $26, $26
	db $94, $e0, $71, $62, $d0, $61, $0a, $0b, $72, $b0, $33, $42, $b0, $e0, $91, $81
	db $d0, $64, $71, $62, $74, $a0, $31, $41, $a0, $a0, $33, $42, $a0, $84, $91, $81
	db $94, $64, $71, $62, $74, $b0, $a1, $a1, $b0, $62, $94, $84, $71, $81, $51, $52
	db $91

;@ path: field/gatefloor
;@ Chance (of 256) per class that a floor has a special character.
FloorNpcChance::
	db $00, $0d, $0d, $0d, $0d, $0d, $1a, $1a, $1a, $1a, $1a, $26, $26, $26, $26
	db $26

;@ path: field/gatefloor/layout
;@ Map references of the random floor screens: 2 bytes (Decompress entry, group) for each
;@ wFloorLayout byte, 16 variants per shape (12 used).
ScreenMapRefs::
	db $10, $28, $11, $28, $12, $28, $13, $28, $14, $28, $15, $28, $00, $2b, $01
	db $2b, $02, $2b, $03, $2b, $04, $2b, $05, $2b, $14, $2c, $10, $28, $10, $28, $10
	db $28, $16, $28, $17, $28, $18, $28, $19, $28, $1a, $28, $1b, $28, $06, $2b, $07
	db $2b, $08, $2b, $09, $2b, $0a, $2b, $0b, $2b, $15, $2c, $10, $28, $10, $28, $10
	db $28, $00, $27, $01, $27, $02, $27, $03, $27, $04, $27, $05, $27, $0c, $2b, $0d
	db $2b, $0e, $2b, $0f, $2b, $10, $2b, $11, $2b, $16, $2c, $10, $28, $10, $28, $10
	db $28, $06, $27, $07, $27, $08, $27, $09, $27, $0a, $27, $0b, $27, $12, $2b, $13
	db $2b, $14, $2b, $15, $2b, $16, $2b, $17, $2b, $17, $2c, $10, $28, $10, $28, $10
	db $28, $0c, $27, $0d, $27, $0e, $27, $0f, $27, $10, $27, $11, $27, $18, $2b, $19
	db $2b, $1a, $2b, $1b, $2b, $1c, $2b, $1d, $2b, $18, $2c, $10, $28, $10, $28, $10
	db $28, $12, $27, $13, $27, $14, $27, $15, $27, $16, $27, $17, $27, $1e, $2b, $1f
	db $2b, $20, $2b, $21, $2b, $22, $2b, $23, $2b, $19, $2c, $10, $28, $10, $28, $10
	db $28, $18, $27, $19, $27, $1a, $27, $1b, $27, $1c, $27, $1d, $27, $24, $2b, $25
	db $2b, $26, $2b, $27, $2b, $28, $2b, $29, $2b, $1a, $2c, $10, $28, $10, $28, $10
	db $28, $1e, $27, $1f, $27, $20, $27, $21, $27, $22, $27, $23, $27, $2a, $2b, $2b
	db $2b, $2c, $2b, $2d, $2b, $2e, $2b, $2f, $2b, $1b, $2c, $10, $28, $10, $28, $10
	db $28, $24, $27, $25, $27, $26, $27, $27, $27, $28, $27, $29, $27, $30, $2b, $31
	db $2b, $32, $2b, $33, $2b, $34, $2b, $35, $2b, $1c, $2c, $10, $28, $10, $28, $10
	db $28, $2a, $27, $2b, $27, $2c, $27, $2d, $27, $2e, $27, $2f, $27, $36, $2b, $37
	db $2b, $38, $2b, $39, $2b, $3a, $2b, $3b, $2b, $1d, $2c, $10, $28, $10, $28, $10
	db $28, $30, $27, $31, $27, $32, $27, $33, $27, $34, $27, $35, $27, $3c, $2b, $3d
	db $2b, $3e, $2b, $3f, $2b, $40, $2b, $41, $2b, $1e, $2c, $10, $28, $10, $28, $10
	db $28, $36, $27, $37, $27, $38, $27, $39, $27, $3a, $27, $3b, $27, $42, $2b, $43
	db $2b, $44, $2b, $45, $2b, $46, $2b, $47, $2b, $1f, $2c, $10, $28, $10, $28, $10
	db $28, $3c, $27, $3d, $27, $3e, $27, $3f, $27, $40, $27, $41, $27, $02, $2c, $03
	db $2c, $04, $2c, $05, $2c, $06, $2c, $07, $2c, $20, $2c, $10, $28, $10, $28, $10
	db $28, $42, $27, $43, $27, $44, $27, $45, $27, $46, $27, $47, $27, $08, $2c, $09
	db $2c, $0a, $2c, $0b, $2c, $0c, $2c, $0d, $2c, $21, $2c, $10, $28, $10, $28, $10
	db $28, $48, $27, $49, $27, $4a, $27, $4b, $27, $4c, $27, $4d, $27, $0e, $2c, $0f
	db $2c, $10, $2c, $11, $2c, $12, $2c, $13, $2c, $22, $2c, $10, $28, $10, $28, $10
	db $28, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27

;@ path: field/gatefloor/layout
;@ Map references of the preset floor screens (same layout as ScreenMapRefs), followed by unused
;@ zero bytes up to the end of the bank.
PresetScreenMapRefs::
	db $23, $2c, $24, $2c, $25, $2c, $26, $2c, $27, $2c, $28, $2c, $29, $2c, $2a
	db $2c, $2b, $2c, $2c, $2c, $2d, $2c, $2e, $2c, $2f, $2c, $30, $2c, $23, $2c, $23
	db $2c, $00, $3b, $01, $3b, $02, $3b, $03, $3b, $04, $3b, $05, $3b, $06, $3b, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $07, $3b, $08, $3b, $09, $3b, $0a, $3b, $0b, $3b, $0c, $3b, $0d, $3b, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $0e, $3b, $0f, $3b, $10, $3b, $11, $3b, $12, $3b, $13, $3b, $14, $3b, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $37, $3a, $38, $3a, $39, $3a, $3a, $3a, $3b, $3a, $3c, $3a, $3d, $3a, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $3e, $3a, $3f, $3a, $40, $3a, $41, $3a, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $42, $3a, $43, $3a, $44, $3a, $45, $3a, $46, $3a, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $47, $3a, $48, $3a, $49, $3a, $4a, $3a, $4b, $3a, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $4c, $3a, $4d, $3a, $4e, $3a, $4f, $3a, $50, $3a, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $15, $3b, $16, $3b, $17, $3b, $18, $3b, $19, $3b, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $1a, $3b, $1b, $3b, $1c, $3b, $1d, $3b, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $1e, $3b, $1f, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $20, $3b, $21, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $22, $3b, $23, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $24, $3b, $25, $3b, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23, $2c, $23
	db $2c, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e, $27, $4e
	db $27, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
